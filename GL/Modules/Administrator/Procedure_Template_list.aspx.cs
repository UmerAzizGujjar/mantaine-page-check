using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Administrator
{
    public partial class Procedure_Template_list : System.Web.UI.Page
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
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Procedure = _dbContext.ProcedureLevels.Count();
                    var Procedure = from P in _dbContext.ProcedureLevels
                              where (
                                    (P.TemplateName.ToString().Contains(searchValue)))
                              select new
                              {
                                  ProcedureLevel_ID = P.ProcedureLevel_ID,
                                  TemplateName = P.TemplateName,
                              };

                    var FilteredCount = Procedure.Count();
                    switch (sortColumn)
                    {
                        case "ProcedureLevel_ID":
                            Procedure = sortColumnDirection == "asc" ? Procedure.OrderBy(a => a.ProcedureLevel_ID) : Procedure.OrderByDescending(a => a.ProcedureLevel_ID);
                            break;
                        case "TemplateName":
                            Procedure = sortColumnDirection == "asc" ? Procedure.OrderBy(a => a.TemplateName) : Procedure.OrderByDescending(a => a.TemplateName);
                            break;
                        default:
                            Procedure = Procedure.OrderByDescending(a => a.ProcedureLevel_ID);
                            break;
                    }


                    var Procedurelist = Procedure.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Procedure, data = Procedurelist };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Procedure list", ex);
            }
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "OutPatientsView";

                using (var db = new DataBaseDataContext())
                {
                    var pref = db.UserDataTablePreferences
                                  .FirstOrDefault(p => p.UserID == userId && p.PageName == pageName);

                    if (pref != null)
                        return pref.ColumnVisibility;
                    else
                        return "";
                }
            }
            catch (Exception ex)
            {
                return "";
            }
        }

        [WebMethod]
        public static void SaveUserColumnPreferences(string visibilityJson)
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "ProcedureTemplateView";

                using (var db = new DataBaseDataContext())
                {
                    var existing = db.UserDataTablePreferences
                                     .FirstOrDefault(p => p.UserID == userId && p.PageName == pageName);

                    if (existing != null)
                    {
                        existing.ColumnVisibility = visibilityJson;
                    }
                    else
                    {
                        db.UserDataTablePreferences.InsertOnSubmit(new UserDataTablePreference
                        {
                            UserID = userId,
                            PageName = pageName,
                            ColumnVisibility = visibilityJson
                        });
                    }

                    db.SubmitChanges();
                }
            }
            catch (Exception ex)
            {
                throw;
            }
        }
    }
}