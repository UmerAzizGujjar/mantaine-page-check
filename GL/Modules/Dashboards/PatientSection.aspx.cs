using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class PatientSection : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Optional: Clear cache or refresh session if needed
            // Session["UserAllowedMenus"] = null; // Uncomment during testing
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

                // 🔍 Debug: Log user and roles
                System.Diagnostics.Debug.WriteLine($"🔍 User: {userName}, Roles: {string.Join(", ", roles)}");

                using (var db = new DataBaseDataContext())
                {
                    var query = from m in db.Menus

                                join rm in db.aspnet_RolesInMenus on m.Menu_ID equals rm.Menu_Id
                                join r in db.aspnet_Roles on rm.RoleId equals r.RoleId
                                join ur in db.aspnet_UsersInRoles on r.RoleId equals ur.RoleId
                                where roleNamesUpper.Contains(r.RoleName.ToUpper())
                                   && m.IsActive == true
                                   && rm.Access == true
                                   && (ur.Company_ID == companyId || ur.AllCompany == true)
                                select m.Menu_Name;  // Make sure Menu_Name matches frontend

                    var result = query.Distinct().ToList();

                    // 🔍 Debug: Show which menus are allowed
                    System.Diagnostics.Debug.WriteLine("✅ Allowed Menus: " + string.Join(", ", result));

                    return result;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("❌ GetUserAllowedMenus Error: " + ex.Message);
                System.Diagnostics.Debug.WriteLine("Stack: " + ex.StackTrace);
#if DEBUG
                throw; // Show error in dev
#else
                return new List<string>();
#endif
            }
        }
    }
}