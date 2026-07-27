using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class PanelView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue, string filterStatus = "all")
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Panels = _dbContext.Panels.Count();

                    // Start with base query
                    var PanelsQuery = from P in _dbContext.Panels
                                      select new
                                      {
                                          Panel_ID = P.Panel_ID,
                                          Company_Name = P.Company_Name,
                                          No_Of_Employees = P.No_Of_Employees,
                                          Contact_No = P.Contact_No,
                                          Address = P.Address,
                                          Discount = P.Discount,
                                          Email = P.Email,
                                          Account_ID = P.gl_account,
                                          AccountID = (from a in _dbContext.GL_Accounts
                                                       where a.Account_ID == P.gl_account
                                                       select new { Account = a.Account_Name }).FirstOrDefault().Account.ToString(),
                                      };

                    if (filterStatus == "mapped")
                    {
                        PanelsQuery = PanelsQuery.Where(p => p.Account_ID != null && p.Account_ID > 0);
                    }
                    else if (filterStatus == "unmapped")
                    {
                        PanelsQuery = PanelsQuery.Where(p => p.Account_ID == null || p.Account_ID == 0);
                    }

                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        PanelsQuery = PanelsQuery.Where(p =>
                            p.Panel_ID.ToString().Contains(searchValue) ||
                            p.Company_Name.Contains(searchValue) ||
                            p.No_Of_Employees.ToString().Contains(searchValue) ||
                            p.Contact_No.Contains(searchValue) ||
                            p.Address.Contains(searchValue) ||
                            p.Email.Contains(searchValue)
                        );
                    }

                    var FilteredCount = PanelsQuery.Count();

                    if (length == -1 || length > 100000)
                    {
                        start = 0;
                        length = FilteredCount;
                    }

                    switch (sortColumn)
                    {
                        case "Company_Name":
                            PanelsQuery = sortColumnDirection == "asc" ? PanelsQuery.OrderBy(a => a.Company_Name) : PanelsQuery.OrderByDescending(a => a.Company_Name);
                            break;
                        case "No_Of_Employees":
                            PanelsQuery = sortColumnDirection == "asc" ? PanelsQuery.OrderBy(a => a.No_Of_Employees) : PanelsQuery.OrderByDescending(a => a.No_Of_Employees);
                            break;
                        default:
                            PanelsQuery = PanelsQuery.OrderByDescending(a => a.Panel_ID);
                            break;
                    }

                    var PanelList = PanelsQuery.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Panels, data = PanelList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Panel list", ex);
            }
        }

        [WebMethod]
        public static string Delete(string panel_id)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            try 
            {
               DBClass.executeNonQueryWithoutBegin("delete from panel where panel_id=" + panel_id);

                return "success";
            }
            catch(Exception ex)
            {
                return "Error";
            }
          
        
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "PanelView";

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
                string pageName = "PanelView";

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

        [WebMethod]
        public static void SavePageState(int pageIndex)
        {
            if (HttpContext.Current.Session != null)
            {
                HttpContext.Current.Session["PanelView_PageIndex"] = pageIndex;
            }
        }

        [WebMethod]
        public static int GetPageState()
        {
            if (HttpContext.Current.Session != null && HttpContext.Current.Session["PanelView_PageIndex"] != null)
            {
                return Convert.ToInt32(HttpContext.Current.Session["PanelView_PageIndex"]);
            }
            return 0; 
        }

        [WebMethod]
        public static void SaveFilterState(string filterValue)
        {
            if (HttpContext.Current.Session != null)
            {
                HttpContext.Current.Session["PanelView_Filter"] = filterValue;
            }
        }

        [WebMethod]
        public static string GetFilterState()
        {
            if (HttpContext.Current.Session != null && HttpContext.Current.Session["PanelView_Filter"] != null)
            {
                return HttpContext.Current.Session["PanelView_Filter"].ToString();
            }
            return "all"; 
        }
    }
}