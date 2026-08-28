using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class ShiftAppointment : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }


        [WebMethod]
        public static string getlist(string startDate, string endDate, string doc_id)
        {
            string result = string.Empty;
            DateTime dTimestDate;
            DateTime dTimeenDate;

            int? doctorId = null;
            if (!string.IsNullOrEmpty(doc_id) && doc_id != "0")
            {
                doctorId = Convert.ToInt32(doc_id);
            }

            if (startDate == "" || endDate == "")
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    DateTime last24Hours = DateTime.Now.AddHours(-24);

                    var query = (from a in db.Appointment_Forms
                                 where a.Status == "Booked"
                                    && (doctorId == null || a.Consultant_ID == doctorId.Value.ToString())
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
                                     emp_name = (from data in db.HR_Employees
                                                 where data.Emp_ID == Convert.ToInt32(a.Consultant_ID)
                                                 select data.Emp_Name).FirstOrDefault(),
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
                                 where a.App_Date.Value.Date >= dTimestDate
                                    && a.App_Date.Value.Date <= dTimeenDate
                                    && a.Status == "Booked"
                                    && (doctorId == null || a.Consultant_ID == doctorId.Value.ToString())
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
                                     emp_name = (from data in db.HR_Employees
                                                 where data.Emp_ID == Convert.ToInt32(a.Consultant_ID)
                                                 select data.Emp_Name).FirstOrDefault(),
                                 }).ToList().OrderByDescending(x => x.App_Date);

                    result = (new JavaScriptSerializer()).Serialize(query).ToString();
                }
            }

            return result;
        }

        [WebMethod]
        public static string ShiftAPT(string appid, string ShiftDate, string ShiftTime)
        {
            if (!DateTime.TryParseExact(ShiftTime, "h:mm tt", CultureInfo.InvariantCulture, DateTimeStyles.None, out DateTime parsedTime))
            {
                parsedTime = DateTime.Parse(ShiftTime);
            }

            string formattedDate = ShiftDate + " 00:00:00.000";
            string formattedTime = parsedTime.ToString("HH:mm:ss.fffffff");

            string updateSql = $@"
                UPDATE appointment_form 
                SET App_Date = '{formattedDate}', 
                    Time = '{formattedTime}'
                WHERE Appointment_ID = {appid}";

            return DBClass.getField(updateSql).ToString();
        }

        [WebMethod]
        public static string ShiftAPTWithDoctor(string appid, string ShiftDate, string newDoctorId, string ShiftTime)
        {
            if (!DateTime.TryParseExact(ShiftTime, "h:mm tt", CultureInfo.InvariantCulture, DateTimeStyles.None, out DateTime parsedTime))
            {
                parsedTime = DateTime.Parse(ShiftTime);
            }

            string formattedDate = ShiftDate + " 00:00:00.000";
            string formattedTime = parsedTime.ToString("HH:mm:ss.fffffff");

            string updateSql = $@"
                UPDATE appointment_form 
                SET App_Date = '{formattedDate}', 
                    Consultant_ID = '{newDoctorId}',
                    Time = '{formattedTime}'
                WHERE Appointment_ID = {appid}";

            return DBClass.getField(updateSql).ToString();
        }

        [WebMethod]
        public static bool CheckDoctorRosterForDate(string doctorId, string shiftDate)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                DateTime date = Convert.ToDateTime(shiftDate).Date;
                int docId = Convert.ToInt32(doctorId);

                bool exists = (from m in db.Doctor_Rouster_Masters
                               join d in db.Doctor_Rouster_Details on m.Rouster_id equals d.Rouster_id
                               where m.Doctor_Id == docId && d.Rouster_Date.HasValue && d.Rouster_Date.Value.Date == date
                               select d).Any();

                return exists;
            }
        }

        [WebMethod]
        public static bool CheckAppointmentConflict(string doctorId, string shiftDate)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                DateTime date = Convert.ToDateTime(shiftDate).Date;

                bool hasAppointment = db.Appointment_Forms
                    .Any(a => a.Consultant_ID == doctorId && a.App_Date.HasValue && a.App_Date.Value.Date == date && a.Status == "Booked");

                return hasAppointment;
            }
        }

        [WebMethod]
        public static string LoadDoctor()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var doctor = (from emp in db.HR_Employees
                              where emp.Resign_Date == null && emp.IsDoctor == true
                              select new { emp.Emp_ID, emp.Emp_Name }).ToList();
                return (new JavaScriptSerializer()).Serialize(doctor);
            }
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


        [WebMethod]
        public static bool CheckTimeConflict(string doctorId, string shiftDate, string shiftTime)
        {
            using (var db = new DataBaseDataContext())
            {
                DateTime date = Convert.ToDateTime(shiftDate).Date;
                if (!DateTime.TryParseExact(shiftTime, "h:mm tt", CultureInfo.InvariantCulture, DateTimeStyles.None, out DateTime parsedTime))
                {
                    parsedTime = DateTime.Parse(shiftTime);
                }
                TimeSpan timeSpan = parsedTime.TimeOfDay;

                bool conflict = db.Appointment_Forms
                    .Any(a => a.Consultant_ID == doctorId
                              && a.App_Date.HasValue
                              && a.App_Date.Value.Date == date
                              && a.Time.HasValue
                              && a.Time.Value == timeSpan
                              && a.Status == "Booked");
                return conflict;
            }
        }

        [WebMethod]
        public static List<object> GetDoctorAvailableSlots(string doctorId, string shiftDate)
        {
            var slots = new List<object>();
            using (var db = new DataBaseDataContext())
            {
                DateTime date = Convert.ToDateTime(shiftDate).Date;
                int docId = Convert.ToInt32(doctorId);

                var roster = (from m in db.Doctor_Rouster_Masters
                              join d in db.Doctor_Rouster_Details on m.Rouster_id equals d.Rouster_id
                              where m.Doctor_Id == docId && d.Rouster_Date.HasValue && d.Rouster_Date.Value.Date == date
                              select new { d.Time_In, d.Time_Out, d.Slot }).FirstOrDefault();

                if (roster != null)
                {
                    string timeInStr = roster.Time_In?.ToString();
                    string timeOutStr = roster.Time_Out?.ToString();
                    string slotStr = roster.Slot?.ToString();

                    if (!string.IsNullOrEmpty(timeInStr) && !string.IsNullOrEmpty(timeOutStr) && !string.IsNullOrEmpty(slotStr))
                    {
                        if (TimeSpan.TryParse(timeInStr, out TimeSpan start) &&
                            TimeSpan.TryParse(timeOutStr, out TimeSpan end) &&
                            int.TryParse(slotStr, out int slotMinutes))
                        {
                            var bookedTimes = db.Appointment_Forms
                                .Where(a => a.Consultant_ID == doctorId
                                            && a.App_Date.HasValue
                                            && a.App_Date.Value.Date == date
                                            && a.Status == "Booked"
                                            && a.Time.HasValue)
                                .Select(a => a.Time.Value)
                                .ToList();

                            for (TimeSpan t = start; t < end; t = t.Add(TimeSpan.FromMinutes(slotMinutes)))
                            {
                                DateTime dtStart = DateTime.Today.Add(t);
                                DateTime dtEnd = DateTime.Today.Add(t.Add(TimeSpan.FromMinutes(slotMinutes)));
                                string startStr = dtStart.ToString("h:mm tt", CultureInfo.InvariantCulture);
                                string endStr = dtEnd.ToString("h:mm tt", CultureInfo.InvariantCulture);
                                string display = startStr + " - " + endStr;

                                bool isBooked = bookedTimes.Contains(t);

                                slots.Add(new
                                {
                                    value = startStr,
                                    display = display,
                                    booked = isBooked
                                });
                            }
                        }
                    }
                }
            }
            return slots;
        }
    }
}