using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class Employee_Roster_List : System.Web.UI.Page
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

                    var Total_Employees = _dbContext.Doctor_Rouster_Masters.Count();
                    var Employees = from DRM in _dbContext.Doctor_Rouster_Masters
                                    where (
                                          (DRM.Rouster_Month.ToString().Contains(searchValue) || (from hr in _dbContext.HR_Employees where hr.Emp_ID == DRM.Doctor_Id select hr.Emp_Name).FirstOrDefault().Contains(searchValue) ))
                                    select new
                                    {
                                        RousterID = DRM.Rouster_id,
                                        Month = DRM.Rouster_Month,
                                        Doctor_Id = (from hr in _dbContext.HR_Employees where hr.Emp_ID == DRM.Doctor_Id select hr.Emp_Name).FirstOrDefault(),
                                    };

                    var FilteredCount = Employees.Count();
                    switch (sortColumn)
                    {
                        case "Month":
                            Employees = sortColumnDirection == "asc" ? Employees.OrderBy(a => a.Month) : Employees.OrderByDescending(a => a.Month);
                            break;                      
                        default:
                            Employees = Employees.OrderByDescending(a => a.Month);
                            break;
                    }


                    var EmployeeList = Employees.Skip(start).Take(length).ToList();


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
        public static string DeleteRecord(string labID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var remove = (from aremove in db.Doctor_Rouster_Masters
                              where aremove.Rouster_id == Convert.ToInt32(labID)
                              select aremove).FirstOrDefault();
                if (remove != null)
                {
                    db.Doctor_Rouster_Masters.DeleteOnSubmit(remove);
                    db.SubmitChanges();
                }
            }
            return "";
        }
    }
}
