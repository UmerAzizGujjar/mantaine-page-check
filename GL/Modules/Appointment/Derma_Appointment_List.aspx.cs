using System;
using System.Collections.Generic;
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
                              where (DA.Appointment_No.ToString().Contains(searchValue) ||
                                     (from rp in _dbContext.Reg_patients
                                      where rp.pat_id == DA.Patient_Id
                                      select rp.Full_Name).FirstOrDefault().Contains(searchValue))
                              select new
                              {
                                  Derma_Appointment_Id = DA.Derma_Appointment_Id,
                                  Appointment_No = DA.Appointment_No,
                                  Full_Name = (from rp in _dbContext.Reg_patients where rp.pat_id == DA.Patient_Id select rp.Full_Name).FirstOrDefault(),
                                  Phone = (from rp in _dbContext.Reg_patients where rp.pat_id == DA.Patient_Id select rp.Mobile1).FirstOrDefault(),
                                  Age = (from rp in _dbContext.Reg_patients where rp.pat_id == DA.Patient_Id select rp.Age_years).FirstOrDefault(),
                                  Doctor_Id = (from hr in _dbContext.HR_Employees where hr.Emp_ID == Convert.ToInt32(DA.Doctor_Id) select hr.Emp_Name).FirstOrDefault(),
                                  Appointment_Date = DA.Appointment_Date,
                                  Status = DA.Status,
                                  CreatedBY = _dbContext.aspnet_Users.Where(x => x.UserId == DA.Created_By).Select(x => x.UserName).FirstOrDefault(),
                                  Creation_Date = DA.Created_Date,
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
    }
}