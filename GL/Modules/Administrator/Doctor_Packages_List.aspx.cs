using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Inventory
{
    public partial class Doctor_Packages_List : System.Web.UI.Page
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
                var package = db.DoctorPackages.FirstOrDefault(p => p.Doc_Packages_ID.ToString() == Package_ID);

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
                    var query = from a in _dbContext.DoctorPackages
                                where (a.isCancelled == false || a.isCancelled == null)
                                select new
                                {
                                    a.Doc_Packages_ID,
                                    a.Package_Name,
                                    a.Duration,
                                    a.Remarks,
                                    DoctorIds = (from p in _dbContext.HR_Employees join dpck in _dbContext.Doctor_Packages_Details on a.Doc_Packages_ID equals dpck.Doc_Pakages_Id
                                                 where p.Emp_ID == Convert.ToInt32(dpck.Doctor_Id) select p.Emp_Name).ToList(),
                                    DepartmentIds = (from p in _dbContext.ValueSets join dpck in _dbContext.Doctor_Packages_Details on a.Doc_Packages_ID equals dpck.Doc_Pakages_Id
                                                     join d in _dbContext.DataValues on p.ValueSet_ID equals d.ValueSet_ID where p.ValueSet_Description == "Patient Main Category" && d.DataValue_Name == dpck.Department_Id
                                                     select d.DataValue_Description).ToList()
                                };

                    var data = query.ToList();

                    var filteredData = data.Select(a => new
                    {
                        Package_ID = a.Doc_Packages_ID,
                        Package_name = a.Package_Name,
                        Doctorname = string.Join(", ", a.DoctorIds),
                        Department = string.Join(", ", a.DepartmentIds),
                        Duration = a.Duration,
                        Remarks = a.Remarks
                    }).Where(a => a.Package_ID.ToString().Contains(searchValue) || a.Package_name.Contains(searchValue) ||  a.Doctorname.Contains(searchValue) || a.Department.Contains(searchValue))
                    .ToList();

                    var Total_pat = data.Count;
                    var FilteredCount = filteredData.Count;
                    switch (sortColumn)
                    {
                        case "Package_ID":
                            filteredData = sortColumnDirection == "asc" ? filteredData.OrderBy(a => a.Package_ID).ToList() : filteredData.OrderByDescending(a => a.Package_ID).ToList();
                            break;
                        case "Doctorname":
                            filteredData = sortColumnDirection == "asc" ? filteredData.OrderBy(a => a.Doctorname).ToList() : filteredData.OrderByDescending(a => a.Doctorname).ToList();
                            break;
                        default:
                            filteredData = filteredData.OrderByDescending(a => a.Package_ID).ToList();
                            break;
                    }
                    var paginatedData = filteredData.Skip(start).Take(length).ToList();
                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_pat, data = paginatedData };
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
                string pageName = "DoctorPackagesList";

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
                string pageName = "DoctorPackagesList";

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