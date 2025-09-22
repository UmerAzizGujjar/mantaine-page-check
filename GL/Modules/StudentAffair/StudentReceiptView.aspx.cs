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
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    var Total_Student_Receipts = _dbContext.Student_Receipts.Count();
                    var Student_Receipts = from SR in _dbContext.Student_Receipts
                                           join RS in _dbContext.Reg_Students on SR.Student_ID equals RS.Student_Id
                                           where (SR.isCancel== false && (SR.Student_Receipt_No.ToString().Contains(searchValue) ||SR.Student_ID.ToString().Contains(searchValue)))
                                     select new
                                     {
                                         Student_Receipt_ID = SR.Student_Receipt_ID,
                                         Student_Receipt_No = SR.Student_Receipt_No,
                                         Student_Receipt_Date = SR.Student_Receipt_Date,
                                         Student_ID = SR.Student_ID,
                                         Status = SR.Status,
                                         RollNo = (from a in _dbContext.Reg_Students where a.Student_Id == SR.Student_ID select a.Roll_No),
                                         Balance = SR.Balance,
                                         Remarks = SR.Remarks,
                                         Full_Name = RS.Full_Name,
                                         Class = _dbContext.GetDataValueName("Student Class", SR.Class)
                                     };

                    var FilteredCount = Student_Receipts.Count();
                    switch (sortColumn)
                    {
                        case "Student_Receipt_No":
                            Student_Receipts = sortColumnDirection == "asc" ? Student_Receipts.OrderBy(a => a.Student_Receipt_No) : Student_Receipts.OrderByDescending(a => a.Student_Receipt_No);
                            break;
                        case "Student_ID":
                            Student_Receipts = sortColumnDirection == "asc" ? Student_Receipts.OrderBy(a => a.Student_ID) : Student_Receipts.OrderByDescending(a => a.Student_ID);
                            break;
                        default:
                            Student_Receipts = Student_Receipts.OrderByDescending(a => a.Student_Receipt_ID);
                            break;
                    }

                    var StudentReceiptslist = Student_Receipts.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Student_Receipts, data = StudentReceiptslist };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Student Receipt list", ex);
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