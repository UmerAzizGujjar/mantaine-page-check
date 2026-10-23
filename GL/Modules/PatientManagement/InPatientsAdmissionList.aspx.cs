using PMS.Modules.PatientManagement;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Linq.SqlClient;
using System.Data.SqlClient;
using System.Linq;
using System.Net.PeerToPeer;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class InPatientsAdmissionList : System.Web.UI.Page
    {
        DataBaseDataContext db = new DataBaseDataContext();
        static string FilePath = "";

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        public class Result
        {
            public string Referring_Doctor;
            public string Refer_To_Hospital;
            public string Discharge_Recommended;
            public string Admission_Date;
            public string Expected_Discharge_Date;
            public string Full_Name;
            public string Father_Name;
            public string NIC;
            public string Patient_ID;
            public string Patient_Type;
            public string Department;
            public string Age_years;
            public string Patient_No;
            public string In_Patient_ID;
            public string Discharge_On;
            public int allowDelete;
            public int allowEdit;
        }
        [WebMethod(EnableSession = true)]
        public static object DischargePatientsWithDoctor(List<int> patientIds, int dischargeDoctorId)
        {
            if (patientIds == null || patientIds.Count == 0)
                return new { success = false, message = "No patients selected." };

            var currentUserId = HttpContext.Current.Session["UserId"]?.ToString();
            if (string.IsNullOrEmpty(currentUserId))
                return new { success = false, message = "Session expired." };

            try
            {
                using (var db = new DataBaseDataContext())
                {
                    foreach (int inPatId in patientIds)
                    {
                        var ip = db.In_Patients.FirstOrDefault(x => x.In_Patient_ID == inPatId);
                        if (ip == null || ip.Discharge == true) continue;
                        ip.Discharge = true;
                        ip.Discharge_On = DateTime.Now;
                        ip.Discharge_By = dischargeDoctorId.ToString();


                        var wards = db.Ward_Allocations
                            .Where(w => w.InPatient_ID == inPatId.ToString() && w.IsDischarge == false)
                            .ToList();
                        foreach (var w in wards)
                        {
                            w.IsDischarge = true;
                            w.To_TimeDate = DateTime.Now;
                        }

                        var rooms = db.Room_Allocations
                            .Where(r => r.In_Patient_ID == inPatId && r.IsDischarge == false)
                            .ToList();
                        foreach (var r in rooms)
                        {
                            r.IsDischarge = true;
                            r.To_Date = DateTime.Now;
                        }

                        DBClass.executeNonQueryWithoutBegin(
                            $"UPDATE Discount_Assigned_Patient SET IsDischarge = 1 WHERE Patient_Id = {ip.Patient_ID}");
                    }
                    db.SubmitChanges();
                }
                return new { success = true, message = $"{patientIds.Count} patient(s) discharged successfully." };
            }
            catch (Exception ex)
            {
                return new { success = false, message = "An error occurred. Please try again." };
            }
        }

        [WebMethod(EnableSession = true)]
        public static string GetDoctor()
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.HR_Employees
                              where dv.IsDoctor == true
                              select new
                              {
                                  dv.Emp_ID,
                                  dv.Emp_Name
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        public static string GetQoute()
        {
            return @"""";
        }

        [WebMethod]
        public static string DeleteRecord(int InPatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var patID = (int)(from tbl in db.In_Patients
                              where tbl.In_Patient_ID == InPatientID
                              select tbl.Patient_ID).FirstOrDefault();

            var ipdid = InPatientID;

            var patbill = (from tbl in db.Ar_Billings
                           where tbl.Patient_ID == patID && (tbl.isCancel ?? false) == false
                           select tbl).FirstOrDefault();

            var wardcheck = (from tbl in db.Ward_Allocations
                             where tbl.InPatient_ID == Convert.ToString((int)ipdid)
                             orderby tbl.Ward_Allocation_ID descending
                             select tbl.IsDischarge).FirstOrDefault();

            if (wardcheck == false)
            {
                return "DischargePending";
            }

            if (patbill != null)
            {
                return "BillingPending";
            }

            var user = AppConfig.UserID.ToString();

            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();

            try
            {
                bool rowUpdated = DBClass.exectueQuery(
                    "UPDATE In_Patient SET is_cancel = 1, cancel_by = '" + user + "' WHERE In_Patient_ID = " + InPatientID + "; " +
                    "DELETE FROM Ward_Allocation WHERE InPatient_ID = " + InPatientID,
                    tranObj,
                    con
                );

                tranObj.Commit();
                return "Delete";
            }
            catch (Exception exc)
            {
                if (tranObj != null)
                    tranObj.Rollback();
                throw new Exception(exc.Message);
            }
            finally
            {
                con.Close();
            }
        }

        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue, string locationFilter, string fromDate, string toDate)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    string wardIdFilter = null;
                    string roomIdFilter = null;
                    if (!string.IsNullOrEmpty(locationFilter) && locationFilter != "all")
                    {
                        if (locationFilter.StartsWith("W_"))
                        {
                            int wid;
                            if (int.TryParse(locationFilter.Substring(2), out wid))
                                wardIdFilter = wid.ToString();
                        }
                        else if (locationFilter.StartsWith("R_"))
                        {
                            int rid;
                            if (int.TryParse(locationFilter.Substring(2), out rid))
                                roomIdFilter = rid.ToString();
                        }
                    }

                    var Total_Patients = _dbContext.In_Patients.Count();
                    var IN_Monitoring = from P in _dbContext.Reg_patients
                                        join IP in _dbContext.In_Patients on P.pat_id equals IP.Patient_ID
                                        where IP.Discharge_On == null && (IP.is_cancel ?? false) == false
                                        && (
                                            IP.In_Patient_ID.ToString().Contains(searchValue) ||
                                            P.mr_no_sequence.Contains(searchValue) ||
                                            P.Full_Name.Contains(searchValue) ||
                                            _dbContext.GetDataValueName("Patient Main Category", IP.Department).Contains(searchValue) ||
                                            _dbContext.GetDataValueName("Patient Type", IP.Patient_Discount_Type).Contains(searchValue) ||
                                            SqlMethods.DateDiffDay(IP.Admission_Date, DateTime.Now).ToString().Contains(searchValue)
                                        )
                                        && (
                                            wardIdFilter == null || (IP.Ward_ID != null && IP.Ward_ID.ToString() == wardIdFilter)
                                        )
                                        && (
                                            roomIdFilter == null || (IP.Room_ID != null && IP.Room_ID.ToString() == roomIdFilter)
                                        )
                                        select new
                                        {
                                            In_Patient_ID = IP.In_Patient_ID,
                                            Admission_Date = IP.Admission_Date,
                                            mr_no_sequence = P.mr_no_sequence,
                                            Full_Name = P.Full_Name,
                                            Father_Name = P.Father_Name,
                                            Birth_Date = IP.Birth_Reg_Date,


                                            Department = _dbContext.GetDataValueName("Patient Main Category", IP.Department),
                                            Patient_Type = _dbContext.GetDataValueName("Patient Type", IP.Patient_Discount_Type),
                                            Discharge_ON = IP.Discharge_On,
                                            Created_by = Convert.ToString(_dbContext.getUserName(Convert.ToString(IP.Created_By))),
                                            AdmitDays = SqlMethods.DateDiffDay(IP.Admission_Date, DateTime.Now),
                                            Ward_Name = (from W in _dbContext.Ward_Definitions
                                                         where W.Ward_ID == IP.Ward_ID
                                                         select W.Ward_Type).FirstOrDefault(),
                                            // Simple subquery for Room
                                            Room_Name = (from R in _dbContext.Rooms
                                                         where R.Room_ID == IP.Room_ID
                                                         select R.Name).FirstOrDefault(),
                                            Bed_No = IP.Bed_No
                                        };

                    // Start / End date filter (yyyy-MM-dd). Blank = no filter (all data).
                    DateTime fromDt, toDt;
                    if (DateTime.TryParseExact(fromDate, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out fromDt))
                    {
                        DateTime fromDateValue = fromDt.Date;
                        IN_Monitoring = IN_Monitoring.Where(a => a.Admission_Date >= fromDateValue);
                    }
                    if (DateTime.TryParseExact(toDate, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out toDt))
                    {
                        DateTime toDateExclusive = toDt.Date.AddDays(1);
                        IN_Monitoring = IN_Monitoring.Where(a => a.Admission_Date < toDateExclusive);
                    }

                    var FilteredCount = IN_Monitoring.Count();
                    switch (sortColumn)
                    {
                        case "In_Patient_ID":
                            IN_Monitoring = sortColumnDirection == "asc" ? IN_Monitoring.OrderBy(a => a.In_Patient_ID) : IN_Monitoring.OrderByDescending(a => a.In_Patient_ID);
                            break;
                        case "mr_no_sequence":
                            IN_Monitoring = sortColumnDirection == "asc" ? IN_Monitoring.OrderBy(b => b.mr_no_sequence) : IN_Monitoring.OrderByDescending(a => a.mr_no_sequence);
                            break;
                        case "Department":
                            IN_Monitoring = sortColumnDirection == "asc" ? IN_Monitoring.OrderBy(b => b.Department) : IN_Monitoring.OrderByDescending(a => a.Department);
                            break;
                        case "Patient_Type":
                            IN_Monitoring = sortColumnDirection == "asc" ? IN_Monitoring.OrderBy(b => b.Patient_Type) : IN_Monitoring.OrderByDescending(a => a.Patient_Type);
                            break;
                        case "AdmitDays":
                            IN_Monitoring = sortColumnDirection == "asc" ? IN_Monitoring.OrderBy(b => b.AdmitDays) : IN_Monitoring.OrderByDescending(a => a.AdmitDays);
                            break;
                        case "Admission_Date":
                            IN_Monitoring = sortColumnDirection == "asc" ? IN_Monitoring.OrderBy(b => b.Admission_Date) : IN_Monitoring.OrderByDescending(a => a.Admission_Date);
                            break;
                        default:
                            IN_Monitoring = IN_Monitoring.OrderByDescending(a => a.In_Patient_ID);
                            break;
                    }

                    var patientList = IN_Monitoring.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Patients, data = patientList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching patient list", ex);
            }
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "InPatientsAdmissinList";

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
                string pageName = "InPatientsAdmissinList";

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

        [WebMethod]
        public static string GetWardsAndRooms()
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var wards = (from w in db.Ward_Definitions
                                 select new
                                 {
                                     Id = "W_" + w.Ward_ID,
                                     Name = "Ward: " + w.Ward_Type,
                                     SortOrder = 1
                                 }).ToList();

                    var rooms = (from r in db.Rooms
                                 select new
                                 {
                                     Id = "R_" + r.Room_ID,
                                     Name = "Room: " + r.Name,
                                     SortOrder = 2
                                 }).ToList();

                    var combined = wards.Concat(rooms)
                                         .OrderBy(x => x.SortOrder)
                                         .ThenBy(x => x.Name)
                                         .ToList();

                    return new JavaScriptSerializer().Serialize(combined);
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new List<object>());
            }
        }

        // Read-only detail of one admission (row click on the list), with its billed services
        [WebMethod]
        public static object GetAdmissionDetail(int In_Patient_ID)
        {
            DataTable dtAdmission = DBClass.getDataTable(@"
                SELECT IP.In_Patient_ID, IP.IPD_No, P.Gender, P.Age_years, P.NIC, P.Mobile1, P.Permanent_Address,
                       FORMAT(IP.Admission_Date, 'dd-MMM-yyyy hh:mm tt') AS Admission_Date,
                       FORMAT(IP.Expected_Discharge_Date, 'dd-MMM-yyyy') AS Expected_Discharge_Date,
                       (SELECT TOP 1 hr.Emp_Name FROM HR_Employees hr WHERE CONVERT(varchar(20), hr.Emp_ID) = IP.Doctor) AS Doctor,
                       (SELECT TOP 1 hr.Emp_Name FROM HR_Employees hr WHERE CONVERT(varchar(20), hr.Emp_ID) = IP.Referred_Doctor) AS Referred_Doctor,
                       IP.Provisional_Diagnosis, IP.Health_Complaints, IP.packagae_name, IP.Room_Type, IP.Admission_Fees
                FROM In_Patient IP
                JOIN Reg_patient P ON P.pat_id = IP.Patient_ID
                WHERE IP.In_Patient_ID = @In_Patient_ID",
                DBClass.Param("@In_Patient_ID", In_Patient_ID));

            DataTable dtServices = DBClass.getDataTable(@"
                SELECT b.Bill_No, d.Item_Name, d.Qty, d.Amount, d.Discount_Amount, d.Net_Amount, ISNULL(b.isCancel, 0) AS isCancel
                FROM Ar_Billings b
                JOIN Ar_Billing_Details d ON d.Bill_ID = b.Bill_ID
                WHERE b.In_Patient_ID = @In_Patient_ID
                ORDER BY b.Bill_ID, d.Bill_Details_ID",
                DBClass.Param("@In_Patient_ID", In_Patient_ID));

            return new { admission = ToRows(dtAdmission).FirstOrDefault(), services = ToRows(dtServices) };
        }

        private static List<Dictionary<string, object>> ToRows(DataTable dt)
        {
            var rows = new List<Dictionary<string, object>>();
            foreach (DataRow dr in dt.Rows)
            {
                var row = new Dictionary<string, object>();
                foreach (DataColumn col in dt.Columns)
                {
                    row[col.ColumnName] = dr[col] == DBNull.Value ? null : dr[col];
                }
                rows.Add(row);
            }
            return rows;
        }
    }
}