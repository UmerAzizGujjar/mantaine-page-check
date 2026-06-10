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
    public partial class AnnexureDashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        private class MenuNode
        {
            public int Menu_ID { get; set; }
            public string Menu_Description { get; set; }
            public int? Parent_ID { get; set; }
            public string URL { get; set; }
        }

        private static List<MenuNode> GetDescendants(List<MenuNode> all, int parentId)
        {
            var result = new List<MenuNode>();
            var kids = all.Where(m => m.Parent_ID == parentId).ToList();
            foreach (var k in kids)
            {
                result.Add(k);
                result.AddRange(GetDescendants(all, k.Menu_ID));
            }
            return result;
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object GetMenuSkeleton()
        {
            using (var db = new DataBaseDataContext())
            {
                var allMenus = db.Menus
                                .Where(m => m.IsActive == true)
                                .Select(m => new MenuNode
                                {
                                    Menu_ID = m.Menu_ID,
                                    Menu_Description = m.Menu_Description,
                                    Parent_ID = m.Parent_ID,
                                    URL = m.URL
                                })
                                .ToList();

                var parents = allMenus.Where(m => m.Parent_ID == 0)
                                      .OrderBy(m => m.Menu_ID)
                                      .ToList();

                var roleMenuIds = db.aspnet_RolesInMenus
                                   .Where(rm => rm.Access == true)
                                   .Select(rm => rm.Menu_Id.Value)
                                   .Distinct()
                                   .ToList();

                var result = parents.Select(p =>
                {
                    var desc = GetDescendants(allMenus, p.Menu_ID)
                               .Where(d => d.URL != "~/Modules/Dashboards/ShortCuts.aspx"
                                        && roleMenuIds.Contains(d.Menu_ID))
                               .Select(d => new { Menu_ID = d.Menu_ID, Menu_Name = d.Menu_Description })
                               .ToList();
                    return new
                    {
                        CategoryName = p.Menu_Description,
                        Menus = desc
                    };
                }).ToList();

                return result;
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object GetSelect2Data()
        {
            using (var db = new DataBaseDataContext())
            {
                var roles = db.aspnet_Roles
                              .Where(r => r.iscancel != true)
                              .Select(r => new
                              {
                                  id = "role_" + r.RoleId.ToString(),
                                  text = r.RoleName + " (Role)"
                              })
                              .ToList();

                var users = db.aspnet_Users
                              .Where(u => u.BlockUser != true)
                              .Select(u => new
                              {
                                  id = "user_" + u.UserId.ToString(),
                                  text = u.UserName + " (User)"
                              })
                              .ToList();

                return roles.Concat(users).ToList();
            }
        }

        private static List<object> GetExportMenuList()
        {
            using (var db = new DataBaseDataContext())
            {
                var allMenus = db.Menus
                                .Where(m => m.IsActive == true)
                                .Select(m => new MenuNode
                                {
                                    Menu_ID = m.Menu_ID,
                                    Menu_Description = m.Menu_Description,
                                    Parent_ID = m.Parent_ID,
                                    URL = m.URL
                                })
                                .ToList();

                var roleMenuIds = db.aspnet_RolesInMenus
                                   .Where(rm => rm.Access == true)
                                   .Select(rm => rm.Menu_Id.Value)
                                   .Distinct()
                                   .ToList();

                var parents = allMenus.Where(m => m.Parent_ID == 0)
                                      .OrderBy(m => m.Menu_ID)
                                      .ToList();

                return parents.SelectMany(p =>
                {
                    var desc = GetDescendants(allMenus, p.Menu_ID)
                               .Where(d => d.URL != "~/Modules/Dashboards/ShortCuts.aspx"
                                        && roleMenuIds.Contains(d.Menu_ID));
                    return desc.Select(d => (object)new
                    {
                        Menu_ID = d.Menu_ID,
                        Menu_Name = d.Menu_Description,
                        CategoryName = p.Menu_Description
                    });
                }).ToList();
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object GetAllUsersExportData()
        {
            var menus = GetExportMenuList();

            using (var db = new DataBaseDataContext())
            {
                var users = db.aspnet_Users
                              .Where(u => u.BlockUser != true)
                              .Select(u => new { u.UserId, u.UserName })
                              .ToList();

                var userRoles = db.aspnet_UsersInRoles.ToList();
                var roleMenus = db.aspnet_RolesInMenus
                                 .Where(rm => rm.Access == true)
                                 .ToList();

                var allowedMap = new Dictionary<Guid, HashSet<int>>();
                foreach (var ur in userRoles)
                {
                    var ids = new HashSet<int>(roleMenus
                        .Where(rm => rm.RoleId == ur.RoleId)
                        .Select(rm => rm.Menu_Id.Value));
                    allowedMap[ur.UserId] = ids;
                }

                var permissions = users.Select(u => new
                {
                    Name = u.UserName,
                    AllowedIds = allowedMap.ContainsKey(u.UserId) ? allowedMap[u.UserId].ToList() : new List<int>()
                }).ToList();

                return new { menus, permissions };
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object GetAllRolesExportData()
        {
            var menus = GetExportMenuList();

            using (var db = new DataBaseDataContext())
            {
                var roles = db.aspnet_Roles
                              .Where(r => r.iscancel != true)
                              .Select(r => new { r.RoleId, r.RoleName })
                              .ToList();

                var roleMenus = db.aspnet_RolesInMenus
                                 .Where(rm => rm.Access == true)
                                 .ToList();

                var allowedMap = new Dictionary<Guid, HashSet<int>>();
                foreach (var g in roleMenus.GroupBy(x => x.RoleId.Value))
                {
                    allowedMap[g.Key] = new HashSet<int>(g.Select(x => x.Menu_Id.Value));
                }

                var permissions = roles.Select(r => new
                {
                    Name = r.RoleName,
                    AllowedIds = allowedMap.ContainsKey(r.RoleId) ? allowedMap[r.RoleId].ToList() : new List<int>()
                }).ToList();

                return new { menus, permissions };
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static List<int> GetAllowedMenuIds(string selectedValue)
        {
            if (string.IsNullOrEmpty(selectedValue))
                return new List<int>();

            bool isUser = selectedValue.StartsWith("user_");
            bool isRole = selectedValue.StartsWith("role_");

            if (!isUser && !isRole)
                return new List<int>();

            string guidStr = selectedValue.Substring(5);
            Guid parsedGuid;
            if (!Guid.TryParse(guidStr, out parsedGuid))
                return new List<int>();

            using (var db = new DataBaseDataContext())
            {
                Guid? matchedRoleId = null;

                if (isUser)
                {
                    var userRole = db.aspnet_UsersInRoles
                                     .Where(ur => ur.UserId == parsedGuid)
                                     .Select(ur => (Guid?)ur.RoleId)
                                     .FirstOrDefault();
                    if (userRole == null)
                        return new List<int>();

                    matchedRoleId = userRole;
                }
                else
                {
                    matchedRoleId = parsedGuid;
                }

                var menuIds = db.aspnet_RolesInMenus
                                .Where(rm => rm.RoleId == matchedRoleId && rm.Access == true)
                                .Select(rm => rm.Menu_Id.Value)
                                .ToList();

                return menuIds;
            }
        }
    }
}
