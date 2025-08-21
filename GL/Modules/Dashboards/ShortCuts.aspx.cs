using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Infragistics.Documents.Reports.Report.Tree;

namespace PMS.Modules.Dashboards
{
    public partial class ShortCuts : System.Web.UI.Page
    {
     
        protected void Page_Load(object sender, EventArgs e)
        {
            string UserName = Session["UserName"].ToString().Trim();
            List<string> navigateURL = new List<string>();
            string[] roles = System.Web.Security.Roles.GetRolesForUser(UserName);
            string roleName = "";
            foreach (string role in roles)
            {
                if (roleName != "")
                    roleName += ",";
                roleName += "'" + role + "'";
            }
            string cmd = "";
            if (roleName != "")
            {
                cmd = "select distinct(m.Menu_ID),Menu_Name,Menu_Description,URL,Parent_ID,order_By,Isactive from menus m inner join aspnet_rolesinmenus rm on m.Menu_ID=rm.Menu_ID" +
                       " INNER JOIN aspnet_roles r on rm.roleID=r.roleID inner join aspnet_UsersInRoles userinroles on r.roleID=userinroles.roleid" +
                       " where r.roleName in(" + roleName + ") AND IsActive=1  and (userinroles.company_id=" + AppConfig.Company_ID + " or userinroles.allCompany=1)order by Order_by ";
            }
            else
            {
                cmd = "select distinct(m.Menu_ID),Menu_Name,Menu_Description,URL,Parent_ID,order_By,Isactive from menus m inner join aspnet_rolesinmenus rm on m.Menu_ID=rm.Menu_ID" +
                           " INNER JOIN aspnet_roles r on rm.roleID=r.roleID" +
                           " where r.roleName='user' AND IsActive=1 order by Order_by ";
            }
            DataTable dt;
            dt = DBClass.getDataTable(cmd);
            foreach (DataRow item in dt.Rows)
            {
                navigateURL.Add(item["URL"].ToString());
            }

            DataRow[] dr = dt.Select("Parent_Id=" + 0);
            foreach (DataRow item in dr)
            {
                MenuItem mi = new MenuItem(Convert.ToString(item["Menu_Description"]),
                              Convert.ToString(item["Menu_Id"]),
                              "", Convert.ToString(item["URL"]));
            }

            String pageName = Request.Url.AbsolutePath;
            string requestedPage = pageName.Substring(pageName.LastIndexOf("/") + 1);

            string query = "select URL from Menus m inner join aspnet_RolesInMenus rm on m.Menu_ID=rm.Menu_Id " +
                "where rm.RoleId in (select RoleId from aspnet_UsersInRoles ur inner join aspnet_Users u  " +
                "on ur.UserId=u.UserId where UserName='" + UserName + "' and ((ur.Company_ID=" + AppConfig.Company_ID + " AND AllCompany=0)or (ur.Company_ID=0 AND AllCompany=1))) " +
                "and ( Menu_Description like '%" + requestedPage + "%')";
            DataTable dtMenus = DBClass.getDataTable(query);
            if (dtMenus.Rows.Count < 1)
            {
                if (requestedPage != "Default.aspx")
                    Response.Redirect("~/Default.aspx", false);
            }
        }
    }
}