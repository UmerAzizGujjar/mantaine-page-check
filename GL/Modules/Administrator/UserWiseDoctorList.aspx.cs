using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Administrator
{
    public partial class UserWiseDoctorList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    DateTime searchDate;
                    bool isDateSearch = DateTime.TryParse(searchValue, out searchDate);
                    var totalRecords = db.User_Wise_Templates.Count();
                    var query = from uwt in db.User_Wise_Templates
                                join usr in db.aspnet_Users on uwt.User_Id equals usr.UserId
                                where (
                                    usr.UserName.Contains(searchValue) ||
                                    (isDateSearch && uwt.Created_Time >= searchDate && uwt.Created_Time < searchDate.AddDays(1))
                                )
                                select new
                                {
                                    User_Wise_Template_Id = uwt.User_Wise_Template_Id,
                                    UserName = usr.UserName,
                                    Created_Time = uwt.Created_Time
                                };

                    var filteredCount = query.Count();
                    switch (sortColumn)
                    {
                        case "UserName":
                            query = sortColumnDirection == "asc"
                                ? query.OrderBy(x => x.UserName)
                                : query.OrderByDescending(x => x.UserName);
                            break;
                        case "Created_Time":
                            query = sortColumnDirection == "asc"
                               ? query.OrderBy(x => x.Created_Time)
                               : query.OrderByDescending(x => x.Created_Time);
                            break;
                        default:
                            query = query.OrderBy(x => x.User_Wise_Template_Id);
                            break;
                    }
                    var data = query.Skip(start).Take(length).ToList();

                    return new
                    {
                        draw,
                        recordsTotal = totalRecords,
                        recordsFiltered = filteredCount,
                        data
                    };
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching User-Wise Template list", ex);
            }
        }

        [WebMethod]
        public static bool DeleteRecord(string Id)
        {
            if (!int.TryParse(Id, out int mainId)) return false;

            SqlConnection con = null;
            SqlTransaction tran = null;

            try
            {
                con = new SqlConnection(DBClass.ConnectionString());
                con.Open();
                tran = con.BeginTransaction();
                DBClass.exectueQuery($"DELETE FROM User_Wise_Template_Detail WHERE User_Wise_Template_Id = {mainId}", tran, con);
                DBClass.exectueQuery($"DELETE FROM User_Wise_Template WHERE User_Wise_Template_Id = {mainId}", tran, con);

                tran.Commit();
                return true;
            }
            catch (Exception)
            {
                tran?.Rollback();
                return false;
            }
            finally
            {
                con?.Close();
            }
        }
    }
}