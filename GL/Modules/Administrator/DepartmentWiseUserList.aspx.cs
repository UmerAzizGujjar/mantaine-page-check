using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class DepartmentWiseUserList : System.Web.UI.Page
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

                    DateTime searchDate;
                    bool isDateSearch = DateTime.TryParse(searchValue, out searchDate);


                    var Total_Department_Wise_User = _dbContext.Department_Wise_Users.Count();
                    var Department = from DP in _dbContext.Department_Wise_Users
                                     join As in _dbContext.aspnet_Users on DP.User_Id equals As.UserId                            
                               where (
                               As.UserName.Contains(searchValue) || (isDateSearch && DP.Created_Time >= searchDate && DP.Created_Time < searchDate.AddDays(1)))
                               select new
                               {
                                   Dept_Wise_User_Id = DP.Dept_Wise_User_Id,
                                   UserName = As.UserName,
                                   Created_Time = DP.Created_Time,
                               };

                    var FilteredCount = Department.Count();
                    switch (sortColumn)
                    {
                        case "UserName":
                            Department = sortColumnDirection == "asc" ? Department.OrderBy(a => a.UserName) : Department.OrderByDescending(a => a.UserName);                   
                            break;
                        default:
                            Department = Department.OrderBy(a => a.Dept_Wise_User_Id);
                            break;
                    }


                    var DepartmentWiseList = Department.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Department_Wise_User, data = DepartmentWiseList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Ward list", ex);
            }
        }
        [WebMethod]
        public static bool DeleteRecord(string Id)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Department_Wise_User st = new Department_Wise_User();
            Department_Wise_User_Detail stkItem = new Department_Wise_User_Detail();

            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                var MainId = (from itm in db.Department_Wise_Users
                              where (itm.Dept_Wise_User_Id == int.Parse(Id))
                              select itm.Dept_Wise_User_Id).FirstOrDefault();
                if (MainId != 0)
                {
                    DBClass.exectueQuery("delete Department_Wise_User where Dept_Wise_User_Id =" + MainId, tranObj, con);
                    DBClass.exectueQuery("delete Department_Wise_User_Detail  where Dept_Wise_User_Id =" + MainId, tranObj, con);

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