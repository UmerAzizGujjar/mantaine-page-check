using PMS.Modules.PatientManagement;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Linq.SqlClient;
using System.Data.SqlClient;
using System.Linq;
using System.Net.PeerToPeer;
using System.Web;
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
        [WebMethod]
        public static object DischargePatients(List<int> patientIds)
        {
            if (patientIds == null || patientIds.Count == 0)
                return new { success = false, message = "No patients selected." };

            var userId = HttpContext.Current.Session["UserId"]?.ToString();
            if (string.IsNullOrEmpty(userId))
                return new { success = false, message = "Session expired. Please log in again." };

            try
            {
                using (var db = new DataBaseDataContext())
                {
                    foreach (int inPatId in patientIds)
                    {
                        var ip = db.In_Patients.FirstOrDefault(x => x.In_Patient_ID == inPatId);
                        if (ip == null || ip.Discharge == true) continue; // skip if missing or already discharged

                        // ✅ Discharge patient
                        ip.Discharge = true;
                        ip.Discharge_On = DateTime.Now;
                        ip.Discharge_By = userId;

                        // ✅ Discharge active ward allocations
                        var wards = db.Ward_Allocations
                            .Where(w => w.InPatient_ID == inPatId.ToString() && w.IsDischarge == false)
                            .ToList();
                        foreach (var w in wards)
                        {
                            w.IsDischarge = true;
                            w.To_TimeDate = DateTime.Now;
                        }

                        // ✅ Mark discount as discharged
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
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

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
                                        select new
                                        {
                                            In_Patient_ID = IP.In_Patient_ID,
                                            Admission_Date = IP.Admission_Date,
                                            mr_no_sequence = P.mr_no_sequence,
                                            Full_Name = P.Full_Name,
                                            Father_Name = P.Father_Name,
                                            Department = _dbContext.GetDataValueName("Patient Main Category", IP.Department),
                                            Patient_Type = _dbContext.GetDataValueName("Patient Type", IP.Patient_Discount_Type),
                                            Discharge_ON = IP.Discharge_On,
                                            AdmitDays = SqlMethods.DateDiffDay(IP.Admission_Date, DateTime.Now)
                                        };

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
    }
}