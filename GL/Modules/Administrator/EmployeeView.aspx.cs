using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Net;
using System.Data.SqlClient;
using System.IO;
using System.Web.Services;
using System.Drawing.Printing;
using CrystalDecisions.CrystalReports.Engine;
using System.Configuration;
using CrystalDecisions.Shared;
using System.Web.Script.Serialization;
using System.Web.Script.Services;

namespace PMS
{
    public partial class EmployeeView : System.Web.UI.Page
    {

        protected override void OnInit(EventArgs e)
        {

        }

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string DeleteRecord(string AppID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var remove = (from aremove in db.HR_Employees
                          where aremove.Emp_ID == Convert.ToInt32(AppID)

                          select aremove).FirstOrDefault();
            db.HR_Employees.DeleteOnSubmit(remove);

            db.SubmitChanges();
            return "";

        }


        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Employees = _dbContext.HR_Employees.Count();
                    var Employees = from p in _dbContext.HR_Employees
                              where (
                                    (p.Emp_ID.ToString().Contains(searchValue) || p.Emp_No.Contains(searchValue) || p.Emp_Name.Contains(searchValue) || p.Mobile.Contains(searchValue) || _dbContext.GetDataValueName("Patient Main Category", p.Department).Contains(searchValue) || _dbContext.GetDataValueName("Designation", p.Designation).Contains(searchValue)))
                              select new
                              {
                                  Emp_id = p.Emp_ID,
                                  Emp_No = p.Emp_No,
                                  Emp_Name = p.Emp_Name,
                                  Department = _dbContext.GetDataValueName("Patient Main Category", p.Department),
                                  Designation = _dbContext.GetDataValueName("Designation", p.Designation),
                                  Email = p.Email,
                                  Mobile1 = p.Mobile,
                              };

                    var FilteredCount = Employees.Count();
                    switch (sortColumn)
                    {
                        case "Emp_No":
                            Employees = sortColumnDirection == "asc" ? Employees.OrderBy(a => a.Emp_No) : Employees.OrderByDescending(a => a.Emp_No);
                            break;
                        case "Emp_Name":
                            Employees = sortColumnDirection == "asc" ? Employees.OrderBy(a => a.Emp_Name) : Employees.OrderByDescending(a => a.Emp_Name);
                            break;
                        default:
                            Employees = Employees.OrderByDescending(a => a.Emp_No); 
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
    }
}