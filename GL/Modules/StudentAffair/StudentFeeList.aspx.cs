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
    public partial class StudentFeeList : System.Web.UI.Page
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
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Fees = _dbContext.Student_Fees.Count();
                    var Student_Fees = from SF in _dbContext.Student_Fees
                                        where (SF.IsCancel == false || SF.IsCancel == null) &&
                                            ((SF.Student_Name.ToString().Contains(searchValue) || SF.Roll_No.ToString().Contains(searchValue) || SF.Total_Amount.ToString().Contains(searchValue) || SF.Fee_No.ToString().Contains(searchValue)))


                                        select new
                                        {
                                            Fee_ID = SF.Fee_ID ,
                                            Fee_No = SF.Fee_No,
                                            Roll_No = SF.Roll_No,
                                            Student_Name = SF.Student_Name,
                                            Father_Name = SF.Father_Name,
                                            Total_Amount = SF.Total_Amount,
                                            Status = SF.Status,
                                            StudentClass = _dbContext.GetDataValueName("Student Class", SF.Student_Class),
                                        };

                    var FilteredCount = Student_Fees.Count();
                    switch (sortColumn)
                    {
                        case "Fee_No":
                            Student_Fees = sortColumnDirection == "asc" ? Student_Fees.OrderBy(a => a.Fee_No) : Student_Fees.OrderByDescending(a => a.Fee_No);
                            break;
                        case "Roll_No":
                            Student_Fees = sortColumnDirection == "asc" ? Student_Fees.OrderBy(b => b.Roll_No) : Student_Fees.OrderByDescending(a => a.Roll_No);
                            break;
                        default:
                            Student_Fees = Student_Fees.OrderByDescending(a => a.Fee_ID);
                            break;
                    }

                    var StudentFeesList = Student_Fees.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Fees, data = StudentFeesList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Student Fees list", ex);
            }
        }

        [WebMethod]
        public static bool CancelFee(int FeeId)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            try
            {
                using (SqlConnection con = new SqlConnection(DBClass.ConnectionString()))
                {
                    con.Open();
                    string query = "UPDATE Student_Fee SET IsCancel = 1 WHERE Fee_ID = @Fee_ID";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@Fee_ID", FeeId);
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