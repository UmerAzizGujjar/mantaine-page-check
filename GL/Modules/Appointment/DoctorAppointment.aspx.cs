using System;
using System.Collections.Generic;
using System.Data;
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
        public static string getlist(string startDate, string endDate, string doc_id)
        {

            if (string.IsNullOrEmpty(doc_id))
                return new JavaScriptSerializer().Serialize(new { error = "Doctor ID is required." });

            string sql;

            if (string.IsNullOrEmpty(startDate) || string.IsNullOrEmpty(endDate))
            {

                sql = @"
            -- OPD Appointments (last 24h)
            SELECT 
                CAST(a.Appointment_ID AS VARCHAR) AS Appointment_ID,
                ISNULL(a.Patient_Name, '') AS Patient_Name,
                ISNULL(a.Phone, '') AS Phone,
                ISNULL(a.Age, '') AS Age,
                ISNULL(a.Consultant_ID, '') AS Consultant_ID,
                ISNULL(CAST(a.Appointment_No AS VARCHAR), '') AS Appointment_No,
                ISNULL(a.Appointment_Code, '') AS Appointment_Code,
                a.App_Date,
                a.Time,
                ISNULL(a.Status, '') AS Status,
                a.created_time,
                ISNULL((SELECT TOP 1 e.Emp_Name FROM HR_Employees e WHERE e.Emp_ID = a.Consultant_ID), '') AS emp_name,
                'OPD' AS Source
            FROM Appointment_Forms a
            WHERE a.Consultant_ID = @doc_id
              AND a.created_time >= DATEADD(HOUR, -24, GETDATE())

            UNION ALL

            -- Derma Appointments (last 24h)
            SELECT 
                CAST(d.Derma_Appointment_Id AS VARCHAR) AS Appointment_ID,
                ISNULL(r.Full_Name, '') AS Patient_Name,
                ISNULL(r.Mobile1, '') AS Phone,
                ISNULL(CAST(r.Age_years AS VARCHAR), '') AS Age,
                ISNULL(d.Doctor_Id, '') AS Consultant_ID,
                ISNULL(CAST(d.Appointment_No AS VARCHAR), '') AS Appointment_No,
                '' AS Appointment_Code,  -- Derma may not have this
                d.Appointment_Date AS App_Date,
                CAST(d.Doctor_Start_Time AS VARCHAR) AS Time,
                ISNULL(d.Status, '') AS Status,
                d.Created_Date AS created_time,
                ISNULL((SELECT TOP 1 e.Emp_Name FROM HR_Employees e WHERE e.Emp_ID = d.Doctor_Id), '') AS emp_name,
                'Derma' AS Source
            FROM Derma_Appointment d
            INNER JOIN Reg_patient r ON r.pat_id = d.Patient_Id
            WHERE d.Doctor_Id = @doc_id
              AND d.Created_Date >= DATEADD(HOUR, -24, GETDATE())
            ORDER BY created_time DESC";
            }
            else
            {

                DateTime startDateParsed, endDateParsed;
                if (!DateTime.TryParse(startDate, out startDateParsed) || !DateTime.TryParse(endDate, out endDateParsed))
                    return new JavaScriptSerializer().Serialize(new { error = "Invalid date format." });

                sql = $@"
            -- OPD Appointments (date range)
            SELECT 
                CAST(a.Appointment_ID AS VARCHAR) AS Appointment_ID,
                ISNULL(a.Patient_Name, '') AS Patient_Name,
                ISNULL(a.Phone, '') AS Phone,
                ISNULL(a.Age, '') AS Age,
                ISNULL(a.Consultant_ID, '') AS Consultant_ID,
                ISNULL(CAST(a.Appointment_No AS VARCHAR), '') AS Appointment_No,
                ISNULL(a.Appointment_Code, '') AS Appointment_Code,
                a.App_Date,
                a.Time,
                ISNULL(a.Status, '') AS Status,
                a.created_time,
                ISNULL((SELECT TOP 1 e.Emp_Name FROM HR_Employees e WHERE e.Emp_ID = a.Consultant_ID), '') AS emp_name,
                'OPD' AS Source
            FROM Appointment_Form a
            WHERE a.Consultant_ID = @doc_id
              AND CAST(a.App_Date AS DATE) BETWEEN '{startDateParsed:yyyy-MM-dd}' AND '{endDateParsed:yyyy-MM-dd}'

            UNION ALL

            -- Derma Appointment (date range)
            SELECT 
                CAST(d.Derma_Appointment_Id AS VARCHAR) AS Appointment_ID,
                ISNULL(r.Full_Name, '') AS Patient_Name,
                ISNULL(r.Mobile1, '') AS Phone,
                ISNULL(CAST(r.Age_years AS VARCHAR), '') AS Age,
                ISNULL(d.Doctor_Id, '') AS Consultant_ID,
                ISNULL(CAST(d.Appointment_No AS VARCHAR), '') AS Appointment_No,
                '' AS Appointment_Code,
                d.Appointment_Date AS App_Date,
                CAST(d.Doctor_Start_Time AS VARCHAR) AS Time,
                ISNULL(d.Status, '') AS Status,
                d.Created_Date AS created_time,
                ISNULL((SELECT TOP 1 e.Emp_Name FROM HR_Employees e WHERE e.Emp_ID = d.Doctor_Id), '') AS emp_name,
                'Derma' AS Source
            FROM Derma_Appointment d
            INNER JOIN Reg_patient r ON r.pat_id = d.Patient_Id
            WHERE d.Doctor_Id = @doc_id
              AND CAST(d.Appointment_Date AS DATE) BETWEEN '{startDateParsed:yyyy-MM-dd}' AND '{endDateParsed:yyyy-MM-dd}'
            ORDER BY App_Date DESC, created_time DESC";
            }

            try
            {

                if (doc_id.Length > 50) return new JavaScriptSerializer().Serialize(new { error = "Invalid Doctor ID." });

                string finalSql = sql.Replace("@doc_id", "'" + doc_id.Replace("'", "''") + "'");
                var dt = DBClass.getDataTable(finalSql);


                var list = dt.AsEnumerable().Select(row => new
                {
                    Appointment_ID = row["Appointment_ID"].ToString(),
                    Patient_Name = row["Patient_Name"].ToString(),
                    Phone = row["Phone"].ToString(),
                    Age = row["Age"].ToString(),
                    Consultant_ID = row["Consultant_ID"].ToString(),
                    Appointment_No = row["Appointment_No"].ToString(),
                    Appointment_Code = row["Appointment_Code"].ToString(),
                    App_Date = row["App_Date"] == DBNull.Value ? (DateTime?)null : (DateTime)row["App_Date"],
                    Time = row["Time"].ToString(),
                    Status = row["Status"].ToString(),
                    created_time = row["created_time"] == DBNull.Value ? (DateTime?)null : (DateTime)row["created_time"],
                    emp_name = row["emp_name"].ToString(),
                    Source = row["Source"].ToString()
                }).ToList();

                return new JavaScriptSerializer().Serialize(list);
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { error = "Query failed: " + ex.Message });
            }
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