using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Appointment
{
    public partial class Derma_Appointment_List : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static object GetDoctors()
        {
            using (var _dbContext = new DataBaseDataContext())
            {
                var doctors = _dbContext.HR_Employees
                    .Where(hr => hr.IS_Active == true) 
                    .Select(hr => new { Emp_ID = hr.Emp_ID, Emp_Name = hr.Emp_Name })
                    .ToList();
                return doctors;
            }
        }

        [WebMethod]
        public static object ViewList(int draw,int start,int length,string sortColumn,string sortColumnDirection,string searchValue,string doctorFilter = "",string statusFilter = "") 
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    DateTime searchDate;
                    bool isDateSearch = DateTime.TryParse(searchValue, out searchDate);

                    var query = _dbContext.Derma_Appointments.AsQueryable();

                    if (!string.IsNullOrEmpty(doctorFilter))
                    {
                        query = query.Where(da => da.Doctor_Id == doctorFilter);
                    }

                    if (!string.IsNullOrEmpty(statusFilter))
                    {
                        query = query.Where(da => da.Status == statusFilter);
                    }

                    var Total_Appointment = query.Count();

                    var pat = from DA in query
                              join rp in _dbContext.Reg_patients on DA.Patient_Id equals rp.pat_id
                              where DA.Appointment_No.ToString().Contains(searchValue) || rp.Full_Name.Contains(searchValue) || rp.Mobile1.Contains(searchValue) || (from hr in _dbContext.HR_Employees where hr.Emp_ID == Convert.ToInt32(DA.Doctor_Id) select hr.Emp_Name).FirstOrDefault().Contains(searchValue) || _dbContext.GetDataValueName("Machine", DA.Machine_Id).Contains(searchValue) || _dbContext.aspnet_Users.Where(x => x.UserId == DA.Created_By).Select(x => x.UserName).FirstOrDefault().Contains(searchValue)
                              || DA.Status.Contains(searchValue) || (isDateSearch && DA.Created_Date >= searchDate && DA.Created_Date < searchDate.AddDays(1))
                              select new
                              {
                                  Derma_Appointment_Id = DA.Derma_Appointment_Id,
                                  Appointment_No = DA.Appointment_No,
                                  Full_Name = rp.Full_Name,
                                  Phone = rp.Mobile1,
                                  Age = rp.Age_years,
                                  Doctor_Id = (from hr in _dbContext.HR_Employees where hr.Emp_ID == Convert.ToInt32(DA.Doctor_Id) select hr.Emp_Name).FirstOrDefault(),
                                  Appointment_Date = DA.Appointment_Date,
                                  Status = DA.Status,
                                  CreatedBY = _dbContext.aspnet_Users.Where(x => x.UserId == DA.Created_By).Select(x => x.UserName).FirstOrDefault(),
                                  Creation_Date = DA.Created_Date,
                                  Machine_Name = _dbContext.GetDataValueName("Machine", DA.Machine_Id),
                                  Patient_Id = DA.Patient_Id
                              };

                    var FilteredCount = pat.Count();

                    switch (sortColumn)
                    {
                        case "Patient_Id":
                            pat = sortColumnDirection == "asc" ? pat.OrderBy(a => a.Patient_Id) : pat.OrderByDescending(a => a.Patient_Id);
                            break;
                        default:
                            pat = pat.OrderByDescending(a => a.Derma_Appointment_Id);
                            break;
                    }

                    var AppointmentList = pat.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Appointment, data = AppointmentList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Appointment list", ex);
            }
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "DermaAppointmentlist";

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
                string pageName = "DermaAppointmentlist";

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