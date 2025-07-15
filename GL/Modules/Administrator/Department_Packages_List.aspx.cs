using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Inventory
{
    public partial class Department_Packages_List : System.Web.UI.Page
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
                var package = db.DepartmentPackages.FirstOrDefault(p => p.Dep_Packages_ID.ToString() == Package_ID);

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
                    var query = from a in _dbContext.DepartmentPackages
                                select new
                                {
                                    a.Dep_Packages_ID,
                                    a.Package_Name,
                                    a.Duration,
                                    a.Remarks,
                                    DepartmentIds = (from p in _dbContext.ValueSets join dpck in _dbContext.Department_Packages_Detail_Rates
                                                     on a.Dep_Packages_ID equals dpck.Dep_Pakages_Id join d in _dbContext.DataValues
                                                     on p.ValueSet_ID equals d.ValueSet_ID where p.ValueSet_Description == "Patient Main Category"
                                                     && d.DataValue_Name == dpck.Department_Id select d.DataValue_Description).Distinct().ToList()
                                };
                    var data = query.ToList();

                    var transformedData = data.Select(a => new
                    {
                        Package_ID = a.Dep_Packages_ID,
                        Department = string.Join(", ", a.DepartmentIds),
                        Package_name = a.Package_Name,
                        Duration = a.Duration,
                        Remarks = a.Remarks
                    }).ToList();
                    var filteredData = transformedData.Where(a =>
                        a.Package_ID.ToString().Contains(searchValue) ||
                        a.Package_name.Contains(searchValue) ||
                        a.Department.Contains(searchValue)).ToList();
                    switch (sortColumn)
                    {
                        case "Package_ID":
                            filteredData = sortColumnDirection == "asc" ? filteredData.OrderBy(a => a.Package_ID).ToList() : filteredData.OrderByDescending(a => a.Package_ID).ToList();
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
    }
}