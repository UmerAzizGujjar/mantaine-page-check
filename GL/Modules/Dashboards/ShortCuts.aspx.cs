using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Dashboards
{
    public partial class ShortCuts : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static List<string> GetUserAllowedMenus()
        {
            try
            {
                var context = HttpContext.Current;
                if (context == null) return new List<string>();

                string userName = context.Session["UserName"]?.ToString().Trim();
                if (string.IsNullOrEmpty(userName)) return new List<string>();

                string[] roles = System.Web.Security.Roles.GetRolesForUser(userName);
                if (roles == null || roles.Length == 0) return new List<string>();

                int companyId = AppConfig.Company_ID;
                if (companyId == 0) return new List<string>();

                
                var roleNamesUpper = roles.Select(r => r.ToUpper()).ToArray();

                using (var db = new DataBaseDataContext())
                {
                    var query = from m in db.Menus
                                join rm in db.aspnet_RolesInMenus on m.Menu_ID equals rm.Menu_Id
                                join r in db.aspnet_Roles on rm.RoleId equals r.RoleId
                                join ur in db.aspnet_UsersInRoles on r.RoleId equals ur.RoleId
                                where roleNamesUpper.Contains(r.RoleName.ToUpper())
                                   && m.IsActive == true
                                   && (ur.Company_ID == companyId || ur.AllCompany == true)
                                select m.Menu_Name;

                    var result = query.Distinct().ToList();

                    System.Diagnostics.Debug.WriteLine("🔍 All allowed menus: " + string.Join(", ", result));
                    return result;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("❌ Exception: " + ex.Message);
                System.Diagnostics.Debug.WriteLine("Stack: " + ex.StackTrace);
#if DEBUG
                throw;
#else
        return new List<string>();
#endif
            }
        }
    }
}