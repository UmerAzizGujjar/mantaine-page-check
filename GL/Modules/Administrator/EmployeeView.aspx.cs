using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class EmployeeView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string DeleteRecord(string AppID)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                var remove = (from aremove in db.HR_Employees
                              where aremove.Emp_ID == Convert.ToInt32(AppID)
                              select aremove).FirstOrDefault();

                if (remove != null)
                {
                    db.HR_Employees.DeleteOnSubmit(remove);
                    db.SubmitChanges();
                    return "success";
                }
                return "Record not found";
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue, string filterStatus = "all")
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"]?.ToString() ?? "";

                    var Total_Employees = _dbContext.HR_Employees.Count();

                    var EmployeesQuery = from p in _dbContext.HR_Employees
                                         select new
                                         {
                                             Emp_id = p.Emp_ID,
                                             Emp_No = p.Emp_No ?? "",
                                             Emp_Name = p.Emp_Name ?? "",
                                             Department = _dbContext.GetDataValueName("Patient Main Category", p.Department) ?? "",
                                             Designation = _dbContext.GetDataValueName("Designation", p.Designation) ?? "",
                                             Email = p.Email ?? "",
                                             Mobile1 = p.Mobile ?? "",
                                             Account_ID = p.Account_ID,
                                             AccountID = (from a in _dbContext.GL_Accounts
                                                          where a.Account_ID == p.Account_ID
                                                          select a.Account_Name).FirstOrDefault() ?? "N/A",
                                         };

                    if (filterStatus == "mapped")
                    {
                        EmployeesQuery = EmployeesQuery.Where(e => e.Account_ID != null && e.Account_ID > 0);
                    }
                    else if (filterStatus == "unmapped")
                    {
                        EmployeesQuery = EmployeesQuery.Where(e => e.Account_ID == null || e.Account_ID == 0);
                    }

                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        EmployeesQuery = EmployeesQuery.Where(p =>
                            p.Emp_id.ToString().Contains(searchValue) ||
                            (p.Emp_No != null && p.Emp_No.Contains(searchValue)) ||
                            (p.Emp_Name != null && p.Emp_Name.Contains(searchValue)) ||
                            (p.Mobile1 != null && p.Mobile1.Contains(searchValue)) ||
                            (p.Department != null && p.Department.Contains(searchValue)) ||
                            (p.Designation != null && p.Designation.Contains(searchValue))
                        );
                    }

                    var FilteredCount = EmployeesQuery.Count();

                    if (length == -1 || length > 100000)
                    {
                        start = 0;
                        length = FilteredCount;
                    }

                    switch (sortColumn)
                    {
                        case "Emp_No":
                            EmployeesQuery = sortColumnDirection == "asc" ? EmployeesQuery.OrderBy(a => a.Emp_No) : EmployeesQuery.OrderByDescending(a => a.Emp_No);
                            break;
                        case "Emp_Name":
                            EmployeesQuery = sortColumnDirection == "asc" ? EmployeesQuery.OrderBy(a => a.Emp_Name) : EmployeesQuery.OrderByDescending(a => a.Emp_Name);
                            break;
                        default:
                            EmployeesQuery = EmployeesQuery.OrderByDescending(a => a.Emp_id);
                            break;
                    }

                    var EmployeeList = EmployeesQuery.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Employees, data = EmployeeList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Employee list", ex);
            }
        }


        [WebMethod]
        public static void SavePageState(int pageIndex)
        {
            if (HttpContext.Current.Session != null)
            {
                HttpContext.Current.Session["EmployeeView_PageIndex"] = pageIndex;
            }
        }

        [WebMethod]
        public static int GetPageState()
        {
            if (HttpContext.Current.Session != null && HttpContext.Current.Session["EmployeeView_PageIndex"] != null)
            {
                return Convert.ToInt32(HttpContext.Current.Session["EmployeeView_PageIndex"]);
            }
            return 0;
        }

        [WebMethod]
        public static void SaveFilterState(string filterValue)
        {
            if (HttpContext.Current.Session != null)
            {
                HttpContext.Current.Session["EmployeeView_Filter"] = filterValue;
            }
        }

        [WebMethod]
        public static string GetFilterState()
        {
            if (HttpContext.Current.Session != null && HttpContext.Current.Session["EmployeeView_Filter"] != null)
            {
                return HttpContext.Current.Session["EmployeeView_Filter"].ToString();
            }
            return "all";
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "EmployeeView";

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

        // MISSING: Save column preferences
        [WebMethod]
        public static void SaveUserColumnPreferences(string visibilityJson)
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "EmployeeView";

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