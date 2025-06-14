using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web;
using static PMS.DonorReceivingForm;

namespace PMS.Modules.Accounts
{
    public partial class UserList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string Delete_User(string UserID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var user = (from p in db.aspnet_Users
                        where p.UserId.ToString() == UserID
                        select p).FirstOrDefault();
            user.BlockUser = true;
            db.SubmitChanges();
            return "User Deleted Successfully!";
        }

        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    DateTime searchDate;
                    bool isDateSearch = DateTime.TryParse(searchValue, out searchDate);
                    var Total_users = _dbContext.aspnet_Users.Count();
                    var users = from p in _dbContext.aspnet_Users
                                join rg in _dbContext.aspnet_Memberships on p.UserId equals rg.UserId
                                where ((p.LoweredUserName.ToString().Contains(searchValue) || rg.LoweredEmail.Contains(searchValue) || rg.mobileno.Contains(searchValue)))
                                select new
                                {
                                  UserId = p.UserId.ToString(),
                                  UserName = p.UserName,
                                  Email = rg.Email,
                                  mobileno = rg.mobileno,
                                  LastActivityDate = p.LastActivityDate,
                                  BlockUser = p.BlockUser.HasValue ? (p.BlockUser.Value ? "Yes" : "No") : "No"
                                };
                    var FilteredCount = users.Count();
                    switch (sortColumn)
                    {
                        case "UserName":
                            users = sortColumnDirection == "asc" ? users.OrderBy(a => a.UserName) : users.OrderByDescending(a => a.UserName);
                            break;
                        case "LastActivityDate":
                            users = sortColumnDirection == "asc" ? users.OrderBy(a => a.LastActivityDate) : users.OrderByDescending(a => a.LastActivityDate);
                            break;
                        case "BlockUser":
                            users = sortColumnDirection == "asc" ? users.OrderBy(a => a.BlockUser) : users.OrderByDescending(a => a.BlockUser);
                            break; 
                    }
                    var usersientList = users.Skip(start).Take(length).ToList();
                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_users, data = usersientList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching usersient list", ex);
            }
        }
    }
}