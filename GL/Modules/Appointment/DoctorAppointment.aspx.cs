using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class DoctorAppointment : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string getlist(string startDate, string endDate,string doc_id)
        {
            string result = string.Empty;
            DateTime dTimestDate;
            DateTime dTimeenDate;

            if (startDate == "" || endDate == "")
            {



                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    DateTime last24Hours = DateTime.Now.AddHours(-24);

                    var query = (from a in db.Appointment_Forms
                                 where a.Consultant_ID == doc_id
                                 select new
                                 {
                                     a.Appointment_ID,
                                     a.Patient_Name,
                                     a.Phone,
                                     a.Age,
                                     a.Consultant_ID,
                                     a.Appointment_No,
                                     a.Appointment_Code,
                                     a.App_Date,
                                     a.Time,
                                     a.Status,
                                     a.created_time,
                                     emp_name = (from data in db.HR_Employees where data.Emp_ID == Convert.ToInt32(a.Consultant_ID) select data.Emp_Name).FirstOrDefault(),
                                 }).ToList().OrderByDescending(x => x.created_time);

                    result = (new JavaScriptSerializer()).Serialize(query).ToString();
                }


            }
            else
            {

                dTimestDate = Convert.ToDateTime(startDate);
                dTimeenDate = Convert.ToDateTime(endDate);
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var query = (from a in db.Appointment_Forms
                                 where a.App_Date.Value.Date >= dTimestDate && a.App_Date.Value.Date <= dTimeenDate && a.Consultant_ID == doc_id

                                 select new
                                 {
                                     a.Appointment_ID,
                                     a.Patient_Name,
                                     a.Phone,
                                     a.Age,
                                     a.Consultant_ID,
                                     a.Appointment_No,
                                     a.Appointment_Code,
                                     a.App_Date,
                                     a.Time,
                                     a.Status,
                                     emp_name = (from data in db.HR_Employees where data.Emp_ID == Convert.ToInt32(a.Consultant_ID) select data.Emp_Name).FirstOrDefault(),
                                 }).ToList().OrderByDescending(x => x.App_Date);
                    result = (new JavaScriptSerializer()).Serialize(query).ToString();
                }
            }


            return result;
        }
        [WebMethod]
        public static string LoadDoctor()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var doctor = (from emp in db.HR_Employees

                              where emp.Resign_Date == null && emp.IsDoctor == true
                              && emp.userid == Convert.ToString(AppConfig.UserID)
                              select new { emp.Emp_ID, emp.Emp_Name }).ToList();
                return (new JavaScriptSerializer()).Serialize(doctor);
            }
            return "";
        }
        [WebMethod]
        public static string ViewList(int doc_id)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                DateTime currentDate = DateTime.Today;

                var query = (from a in db.HR_Employees
                             where a.Emp_ID == doc_id
                             select new
                             {
                                 a.Emp_Name,
                                 Designation = db.GetDataValueName("Designation", a.Designation),
                                 a.Govt_Hospital,
                                 Patient_Type = db.GetDataValueName("Patient Type", a.Patient_Type),
                                 a.Consultant_Charges,
                                 a.Timings_In,
                                 a.Timings_Out,
                                 a.Patient_Time,
                                 a.Off_Days_Names,
                                 a.Mobile,
                                 a.Room_No,
                                 a.Floor_No,
                                 a.Extension_No,
                                 a.Emp_ID,
                                 a.Remarks,
                                 a.TodayStatus,

                             }).FirstOrDefault();
                DateTime currentDateStart = new DateTime(currentDate.Year, currentDate.Month, currentDate.Day, 0, 0, 0);
                DateTime currentDateEnd = currentDateStart.AddDays(1).AddTicks(-1);
                var appointments = (from app in db.Appointment_Forms
                                    where app.Consultant_ID == Convert.ToString(doc_id)
                                          && app.created_time >= currentDateStart
                                          && app.created_time <= currentDateEnd
                                    select new
                                    {
                                        StartTime = app.Time,
                                    }).ToList();

                var response = new
                {
                    DoctorData = query,
                    Appointments = appointments
                };
                result = (new JavaScriptSerializer()).Serialize(response);
            }

            return result;
        }
    }
}