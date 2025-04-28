using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.StudentAffair
{
    public partial class StudentChallanView : System.Web.UI.Page
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
                    var Total_Challan_Amounts = _dbContext.Challan_Amounts.Count();
                    var Challan_Amounts = from CA in _dbContext.Challan_Amounts
                                          where CA.isCancel == false && (_dbContext.Reg_Students.Any(a => a.Student_Id == CA.Student_ID && a.Roll_No.Contains(searchValue)) || CA.Challan_No.ToString().Contains(searchValue) || _dbContext.Students.Any(v => v.Student_ID == CA.Student_ID && v.Student_Name.Contains(searchValue)))
                                          select new
                                           {
                                               Challan_ID = CA.Challan_ID,
                                               DueDate = CA.DueDate,
                                               IssueDate = CA.IssueDate,
                                               Challan_No = CA.Challan_No,
                                               Seq_Challan_No = CA.Seq_Challan_No,
                                               RollNo = _dbContext.Reg_Students.Where(a => a.Student_Id == CA.Student_ID).Select(a => a.Roll_No).FirstOrDefault(),
                                               StudentName = _dbContext.Reg_Students.Where(v => v.Student_Id == CA.Student_ID).Select(v => v.Full_Name).FirstOrDefault(),

                                          };

                    var FilteredCount = Challan_Amounts.Count();
                    switch (sortColumn)
                    {
                        case "Challan_No":
                            Challan_Amounts = sortColumnDirection == "asc" ? Challan_Amounts.OrderBy(a => a.Challan_No) : Challan_Amounts.OrderByDescending(a => a.Challan_No);
                            break;
                        case "RollNo":
                            Challan_Amounts = sortColumnDirection == "asc" ? Challan_Amounts.OrderBy(a => a.RollNo) : Challan_Amounts.OrderByDescending(a => a.RollNo);
                            break;
                        default:
                            Challan_Amounts = Challan_Amounts.OrderByDescending(a => a.Challan_ID);
                            break;
                    }

                    var StudentChalanlist = Challan_Amounts.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Challan_Amounts, data = StudentChalanlist };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Student Chalan list", ex);
            }
        }

        [WebMethod]
        public static bool CancelChallan(int challanId)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            try
            {
                using (SqlConnection con = new SqlConnection(DBClass.ConnectionString()))
                {
                    con.Open();
                    string query = "UPDATE Challan_Amounts SET IsCancel = 1 WHERE Challan_ID = @Challan_ID";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@Challan_ID", challanId);
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


        [WebMethod]
        public static bool DeleteRecord(string ChallanID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                var Challan_ID = (from itm in db.Challan_Amounts
                                  where (itm.Challan_ID == int.Parse(ChallanID))
                                  select itm.Challan_ID).FirstOrDefault();
                if (Challan_ID != 0)
                {
                    DBClass.exectueQuery("delete Challan_Amounts where Challan_ID =" + Challan_ID, tranObj, con);
                    tranObj.Commit();
                }
                else
                {
                    tranObj.Rollback();
                    return false;
                }
            }
#pragma warning disable CS0168 // The variable 'ex' is declared but never used
            catch (Exception ex)
#pragma warning restore CS0168 // The variable 'ex' is declared but never used
            {
                if (tranObj != null)
                    tranObj.Rollback();
                return false;
            }
            return true;
        }

    }
}