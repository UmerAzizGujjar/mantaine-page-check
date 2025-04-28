using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Script.Serialization;

namespace PMS
{
    public partial class PatientManagementSection : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string GetDashBoardDetails()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var Menus = (from usrinRoles in db.aspnet_UsersInRoles
                         join usrs in db.aspnet_Users
                         on usrinRoles.UserId equals usrs.UserId
                         join rolesinMenus in db.aspnet_RolesInMenus
                         on usrinRoles.RoleId equals rolesinMenus.RoleId
                         join m in db.Menus
                         on rolesinMenus.Menu_Id equals m.Menu_ID
                         where m.IsActive == true
                         && usrs.UserId == AppConfig.UserID
                         select m
                      ).Distinct().ToList();
            return (new JavaScriptSerializer().Serialize(Menus));
        }
    }
}