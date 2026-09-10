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

        private static List<MenuNode> GetAllMenus(DataBaseDataContext db)
        {
            return db.Menus
                     .Where(m => m.IsActive == true)
                     .Select(m => new MenuNode
                     {
                         Menu_ID = m.Menu_ID,
                         Menu_Description = m.Menu_Description,
                         Parent_ID = m.Parent_ID,
                         URL = m.URL
                     })
                     .ToList();
        }

        private static MenuNode GetParentMenu(List<MenuNode> all, int menuId)
        {
            var menu = all.FirstOrDefault(m => m.Menu_ID == menuId);
            if (menu == null) return null;
            if (menu.Parent_ID == null || menu.Parent_ID == 0) return null;
            return all.FirstOrDefault(m => m.Menu_ID == menu.Parent_ID.Value);
        }

        private static object BuildRoleRight(int menuId, List<MenuNode> all)
        {
            var parent = GetParentMenu(all, menuId);
            var menu = all.FirstOrDefault(m => m.Menu_ID == menuId);
            return new
            {
                module = parent != null ? parent.Menu_Description : "",
                right = menu != null ? menu.Menu_Description : "",
                desc = menu != null && !string.IsNullOrEmpty(menu.URL) ? menu.URL : (menu != null ? menu.Menu_Description : "")
            };
        }

        private static object BuildRolePayload(Guid roleId, List<MenuNode> all)
        {
            using (var db = new DataBaseDataContext())
            {
                return BuildRolePayloadInContext(db, roleId, all);
            }
        }

        private static object BuildRolePayloadInContext(DataBaseDataContext db, Guid roleId, List<MenuNode> all)
        {
            var role = db.aspnet_Roles.FirstOrDefault(r => r.RoleId == roleId);
            if (role == null) return null;

            var menuIds = db.aspnet_RolesInMenus
                           .Where(rm => rm.RoleId == roleId && rm.Access == true && rm.Menu_Id != null)
                           .Select(rm => rm.Menu_Id.Value)
                           .ToList();

            var rights = menuIds.Select(id => BuildRoleRight(id, all)).ToList();

            var moduleName = "";
            if (rights.Count > 0)
            {
                var firstRight = rights[0];
                var prop = firstRight.GetType().GetProperty("module");
                moduleName = prop != null ? (prop.GetValue(firstRight, null) ?? "").ToString() : "";
            }

            return new
            {
                roleId = role.RoleId,
                roleName = role.RoleName,
                roleDescription = role.Description ?? "",
                module = moduleName,
                status = role.iscancel == true ? "Inactive" : "Active",
                rights = rights
            };
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object GetSearchOptions(string mode)
        {
            using (var db = new DataBaseDataContext())
            {
                if (mode == "users-by-role")
                {
                    var roles = db.aspnet_Roles
                                  .Where(r => r.iscancel != true)
                                  .Select(r => new
                                  {
                                      id = "role_" + r.RoleId.ToString(),
                                      text = r.RoleName
                                  })
                                  .ToList();
                    return roles;
                }

                if (mode == "roles-users-by-module")
                {
                    var modules = db.Menus
                                    .Where(m => m.IsActive == true && m.Parent_ID == 0)
                                    .OrderBy(m => m.Menu_ID)
                                    .Select(m => new
                                    {
                                        id = "module_" + m.Menu_ID.ToString(),
                                        text = m.Menu_Description
                                    })
                                    .ToList();
                    return modules;
                }

                var users = db.aspnet_Users
                              .Where(u => u.BlockUser != true)
                              .OrderBy(u => u.UserName)
                              .Select(u => new
                              {
                                  id = "user_" + u.UserId.ToString(),
                                  text = u.UserName
                              })
                              .ToList();
                return users;
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object SearchRolesByUser(string selectedValue)
        {
            if (string.IsNullOrEmpty(selectedValue) || !selectedValue.StartsWith("user_"))
                return new { userName = "", roles = new List<object>() };

            Guid userGuid;
            if (!Guid.TryParse(selectedValue.Substring(5), out userGuid))
                return new { userName = "", roles = new List<object>() };

            using (var db = new DataBaseDataContext())
            {
                var user = db.aspnet_Users.FirstOrDefault(u => u.UserId == userGuid);
                if (user == null)
                    return new { userName = "", roles = new List<object>() };

                var roleIds = db.aspnet_UsersInRoles
                                .Where(ur => ur.UserId == userGuid)
                                .Select(ur => ur.RoleId)
                                .Distinct()
                                .ToList();

                var all = GetAllMenus(db);

                var roles = roleIds
                    .Select(rid => BuildRolePayloadInContext(db, rid, all))
                    .Where(r => r != null)
                    .ToList();

                return new { userName = user.UserName, roles = roles };
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object SearchUsersByRole(string selectedValue)
        {
            if (string.IsNullOrEmpty(selectedValue) || !selectedValue.StartsWith("role_"))
                return new { roleName = "", users = new List<object>() };

            Guid roleGuid;
            if (!Guid.TryParse(selectedValue.Substring(5), out roleGuid))
                return new { roleName = "", users = new List<object>() };

            using (var db = new DataBaseDataContext())
            {
                var role = db.aspnet_Roles.FirstOrDefault(r => r.RoleId == roleGuid);
                if (role == null)
                    return new { roleName = "", users = new List<object>() };

                var users = (from ur in db.aspnet_UsersInRoles
                             join u in db.aspnet_Users on ur.UserId equals u.UserId
                             where ur.RoleId == roleGuid
                             select new
                             {
                                 userId = u.UserId,
                                 userName = u.UserName,
                                 status = u.BlockUser == true ? "Inactive" : "Active"
                             }).ToList();

                return new { roleName = role.RoleName, users = users };
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object SearchRolesUsersByModule(string selectedValue)
        {
            if (string.IsNullOrEmpty(selectedValue) || !selectedValue.StartsWith("module_"))
                return new { moduleName = "", roles = new List<object>() };

            int moduleId;
            if (!int.TryParse(selectedValue.Substring(7), out moduleId))
                return new { moduleName = "", roles = new List<object>() };

            using (var db = new DataBaseDataContext())
            {
                var module = db.Menus.FirstOrDefault(m => m.Menu_ID == moduleId);
                if (module == null)
                    return new { moduleName = "", roles = new List<object>() };

                var all = GetAllMenus(db);

                var menuIdsInModule = db.Menus
                                         .Where(m => m.IsActive == true && m.Parent_ID == moduleId)
                                         .Select(m => m.Menu_ID)
                                         .ToList();

                var roleIds = db.aspnet_RolesInMenus
                                .Where(rm => rm.Access == true
                                          && rm.Menu_Id != null
                                          && menuIdsInModule.Contains(rm.Menu_Id.Value))
                                .Select(rm => rm.RoleId.Value)
                                .Distinct()
                                .ToList();

                var roles = roleIds.Select(rid =>
                {
                    var payload = BuildRolePayloadInContext(db, rid, all);
                    if (payload == null) return null;

                    var users = (from ur in db.aspnet_UsersInRoles
                                 join u in db.aspnet_Users on ur.UserId equals u.UserId
                                 where ur.RoleId == rid
                                 select new
                                 {
                                     userName = u.UserName,
                                     status = u.BlockUser == true ? "Inactive" : "Active"
                                 }).ToList();

                    object GetProp(object o, string n)
                    {
                        return o == null ? null : o.GetType().GetProperty(n) != null
                            ? o.GetType().GetProperty(n).GetValue(o, null)
                            : null;
                    }

                    return new
                    {
                        roleId = GetProp(payload, "roleId"),
                        roleName = GetProp(payload, "roleName"),
                        roleDescription = GetProp(payload, "roleDescription"),
                        module = module.Menu_Description,
                        status = GetProp(payload, "status"),
                        rights = GetProp(payload, "rights"),
                        users = users
                    };
                }).Where(r => r != null).ToList();

                return new { moduleName = module.Menu_Description, roles = roles };
            }
        }
    }
}
