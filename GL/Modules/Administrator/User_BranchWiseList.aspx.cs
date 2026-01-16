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
    public partial class User_BranchWiseList : System.Web.UI.Page
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

                    var totalRecords = db.Branch_Wise_Users.Count();

                    var query = from bwu in db.Branch_Wise_Users
                                join usr in db.aspnet_Users on bwu.User_Id equals usr.UserId
                                where (
                                    usr.UserName.Contains(searchValue) ||
                                    (isDateSearch && bwu.Created_Time >= searchDate && bwu.Created_Time < searchDate.AddDays(1))
                                )
                                select new
                                {
                                    Branch_wise_User_Id = bwu.Branch_wise_User_Id,
                                    UserName = usr.UserName,
                                    Created_Time = bwu.Created_Time
                                };

                    var filteredCount = query.Count();

                    switch (sortColumn)
                    {
                        case "UserName":
                            query = sortColumnDirection == "asc"
                                ? query.OrderBy(x => x.UserName)
                                : query.OrderByDescending(x => x.UserName);
                            break;
                        default:
                            query = query.OrderBy(x => x.Branch_wise_User_Id);
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
                throw new Exception("Error fetching Branch-wise user list", ex);
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
                DBClass.exectueQuery($"DELETE FROM Branch_Wise_User_Detail WHERE Branch_wise_User_Id = {mainId}", tran, con);
                DBClass.exectueQuery($"DELETE FROM Branch_Wise_User WHERE Branch_wise_User_Id = {mainId}", tran, con);

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