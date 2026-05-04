using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web;

namespace PMS.Modules.StudentAffair
{
    public partial class StudentReceiptView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static object GetClassOptions()
        {
            using (var _dbContext = new DataBaseDataContext())
            {
                var classes = _dbContext.Student_Receipts
                    .Select(s => _dbContext.GetDataValueName("Student Class", s.Class))
                    .Distinct()
                    .OrderBy(c => c)
                    .ToList();

                return new { Classes = classes };
            }
        }




        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue, string filterClass)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    var Total_Student_Receipts = _dbContext.Student_Receipts.Count();

                    var Student_Receipts = from SR in _dbContext.Student_Receipts
                                           join RS in _dbContext.Reg_Students on SR.Student_ID equals RS.Student_Id
                                           select new
                                           {
                                               Student_Receipt_ID = SR.Student_Receipt_ID,
                                               Student_Receipt_No = SR.Student_Receipt_No,
                                               Student_Receipt_Date = SR.Student_Receipt_Date,
                                               Student_ID = SR.Student_ID,
                                               Status = SR.Status,
                                               RollNo = (from a in _dbContext.Reg_Students where a.Student_Id == SR.Student_ID select a.Roll_No).FirstOrDefault(),
                                               Balance = SR.Balance,
                                               Remarks = SR.Remarks,
                                               Full_Name = RS.Full_Name,
                                               Net_Payable = SR.Net_Payable,
                                               Amount_Received = SR.Amount_Received,
                                               ClassName = _dbContext.GetDataValueName("Student Class", SR.Class),
                                               RawClass = SR.Class 
                                           };
                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        Student_Receipts = Student_Receipts.Where(SR =>
                            SR.Student_Receipt_No.ToString().Contains(searchValue) ||
                            SR.Student_ID.ToString().Contains(searchValue) ||
                            SR.Full_Name.ToString().Contains(searchValue) ||
                            SR.ClassName.Contains(searchValue)
                        );
                    }
                    if (!string.IsNullOrEmpty(filterClass))
                    {
                        Student_Receipts = Student_Receipts.Where(SR => SR.ClassName == filterClass);
                    }

                    var FilteredCount = Student_Receipts.Count();
                    switch (sortColumn)
                    {
                        case "Student_Receipt_No":
                            Student_Receipts = sortColumnDirection == "asc" ? Student_Receipts.OrderBy(a => a.Student_Receipt_No) : Student_Receipts.OrderByDescending(a => a.Student_Receipt_No);
                            break;
                        case "Student_Receipt_Date":
                            Student_Receipts = sortColumnDirection == "asc" ? Student_Receipts.OrderBy(a => a.Student_Receipt_Date) : Student_Receipts.OrderByDescending(a => a.Student_Receipt_Date);
                            break;
                        case "Student_ID":
                            Student_Receipts = sortColumnDirection == "asc" ? Student_Receipts.OrderBy(a => a.Student_ID) : Student_Receipts.OrderByDescending(a => a.Student_ID);
                            break;
                        case "Class":
                            Student_Receipts = sortColumnDirection == "asc" ? Student_Receipts.OrderBy(a => a.ClassName) : Student_Receipts.OrderByDescending(a => a.ClassName);
                            break;
                        default:
                            Student_Receipts = Student_Receipts.OrderByDescending(a => a.Student_Receipt_ID);
                            break;
                    }

                    var StudentReceiptslist = Student_Receipts.Skip(start).Take(length)
                        .Select(s => new {
                            s.Student_Receipt_ID,
                            s.Student_Receipt_No,
                            s.Student_Receipt_Date,
                            s.Student_ID,
                            s.Status,
                            s.RollNo,
                            s.Balance,
                            s.Remarks,
                            s.Full_Name,
                            s.Net_Payable,
                            s.Amount_Received,
                            Class = s.ClassName 
                        }).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Student_Receipts, data = StudentReceiptslist };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Student Receipt list: " + ex.Message);
            }
        }

        [WebMethod]
        public static bool CancelReceipt(int ReceiptId)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            try
            {
                using (SqlConnection con = new SqlConnection(DBClass.ConnectionString()))
                {
                    con.Open();
                    string query = "UPDATE Student_Receipt SET isCancel = 1 WHERE Student_Receipt_ID = @Student_Receipt_ID";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@Student_Receipt_ID", ReceiptId);
                        int rowsAffected = cmd.ExecuteNonQuery();
                        return rowsAffected > 0;
                    }
                }
            }
            catch (Exception ex)
            {
                return false;
            }
        }
    }
}