using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Inventory
{
    public partial class Panel_Packages_List : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string DeletePackage(string Package_ID)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

                // Try to find the package by ID
                var package = db.PanelPackages.FirstOrDefault(p => p.Pan_Packages_ID.ToString() == Package_ID);

                if (package != null)
                {
                    package.isCancelled = true;
                    package.CancelledBy = AppConfig.UserID;
                    package.CancelledTime = DateTime.Now;
                    db.SubmitChanges();
                    return "Package cancelled successfully.";
                }
                else
                {
                    return "Package not found.";
                }
            }
            catch (Exception ex)
            {
                // Optional: Log the exception if needed
                return "Error occurred: " + ex.Message;
            }
        }
        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();
                    var query = from a in _dbContext.PanelPackages
                                select new
                                {
                                    a.Pan_Packages_ID,
                                    a.Package_Name,
                                    a.Duration,
                                    a.Remarks,
                                    PanelNames = (from p in _dbContext.Panels
                                                  join pck in _dbContext.Panel_Packages_Details on a.Pan_Packages_ID equals pck.Pan_Pakages_Id
                                                  where p.Panel_ID == Convert.ToInt32(pck.Panel_Id)
                                                  select p.Company_Name).Distinct().ToList()
                                };
                    var data = query.ToList();
                    var transformedData = data.Select(a => new
                    {
                        Package_ID = a.Pan_Packages_ID,
                        Companyname = string.Join(", ", a.PanelNames),
                        Package_name = a.Package_Name,
                        Duration = a.Duration,
                        Remarks = a.Remarks
                    }).ToList();
                    var filteredData = transformedData.Where(a =>
                        a.Package_ID.ToString().Contains(searchValue) ||
                        a.Companyname.Contains(searchValue) ||
                        a.Package_name.Contains(searchValue)).ToList();
                    switch (sortColumn)
                    {
                        case "Package_ID":
                            filteredData = sortColumnDirection == "asc" ? filteredData.OrderBy(a => a.Package_ID).ToList() : filteredData.OrderByDescending(a => a.Package_ID).ToList();
                            break;
                        case "Companyname":
                            filteredData = sortColumnDirection == "asc" ? filteredData.OrderBy(a => a.Companyname).ToList() : filteredData.OrderByDescending(a => a.Companyname).ToList();
                            break;
                        case "Package_name":
                            filteredData = sortColumnDirection == "asc" ? filteredData.OrderBy(a => a.Package_name).ToList() : filteredData.OrderByDescending(a => a.Package_name).ToList();
                            break;
                        default:
                            filteredData = filteredData.OrderByDescending(a => a.Package_ID).ToList();
                            break;
                    }
                    var paginatedData = filteredData.Skip(start).Take(length).ToList();
                    var jsonData = new
                    {
                        draw = draw,
                        recordsFiltered = filteredData.Count,
                        recordsTotal = data.Count,
                        data = paginatedData
                    };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Package list", ex);
            }
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "PanelPackagesList";

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
                string pageName = "PanelPackagesList";

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