using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Account
{
    public partial class RolesView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
            }
        }
        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {


                    var roles = _dbContext.aspnet_Roles.Count();
                    var role = from a in _dbContext.aspnet_Roles
                               where a.iscancel == false && (a.RoleName.ToString().Contains(searchValue))
                               orderby a.RoleName descending
                              select new
                              {
                                  RoleId = a.RoleId,
                                  RoleName = a.RoleName,
                                  Description = a.Description

                              };
                    var FilteredCount = role.Count();
                    switch (sortColumn)
                    {
                        case "TemplateName":
                            role = sortColumnDirection == "asc" ? role.OrderBy(a => a.RoleName) : role.OrderByDescending(a => a.Description);
                            break;

                    }


                    var rolelist = role.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = roles, data = rolelist };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching patient list", ex);
            }
        }

        [WebMethod]
        public static string CancelRecord(string RoleID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var record = (from r in db.aspnet_Roles
                          where r.RoleId == new Guid(RoleID)
                          select r).FirstOrDefault();

            if (record != null)
            {
               
                record.iscancel = true;
                db.SubmitChanges();
            }

            return "";
        }

    }
}