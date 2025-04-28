using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Accounts
{
    public partial class RoleAssignment : System.Web.UI.Page
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


                    var wards = _dbContext.aspnet_Users.Count();
                    var ward = from user in _dbContext.aspnet_Users
                               join member in _dbContext.aspnet_Memberships on user.UserId equals member.UserId
                               join role in _dbContext.aspnet_Roles on member.RoleID equals role.RoleId into roleGroup
                               from role in roleGroup.DefaultIfEmpty()
                               where (user.UserName.ToString().Contains(searchValue) || member.Email.Contains(searchValue) || role.RoleName.Contains(searchValue))
                               orderby user.UserName
                               select new
                               {
                                   UserId = user.UserId,
                                   UserName = user.UserName,
                                   Email = member.Email,
                                   RoleID = member.RoleID,
                                   RoleName = role != null ? role.RoleName : null
                               };
                    var FilteredCount = ward.Count();
                    switch (sortColumn)
                    {
                        case "UserName":
                            ward = sortColumnDirection == "asc" ? ward.OrderBy(a => a.UserName) : ward.OrderByDescending(a => a.UserName);
                            break;

                    }


                    var templatelist = ward.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = wards, data = templatelist };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Medicine Template list", ex);
            }
        }

        [WebMethod]
        public static bool DeleteRecord(string itemID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                try
                {
                    int id = int.Parse(itemID);
                    var item = db.INV_Items.SingleOrDefault(i => i.Item_ID == id);

                    if (item != null)
                    {
                        db.INV_Items.DeleteOnSubmit(item);
                        db.SubmitChanges();
                        return true;
                    }
                    return false;
                }
                catch (Exception)
                {
                    return false;
                }
            }
        }

    }
}