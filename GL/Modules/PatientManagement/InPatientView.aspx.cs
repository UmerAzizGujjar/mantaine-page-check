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
using PMS.Modules.PatientManagement;
using System.Net.PeerToPeer;

namespace PMS
{
    public partial class InPatientView : System.Web.UI.Page
    {
        DataBaseDataContext db = new DataBaseDataContext();
        static string FilePath = "";
        protected void Page_Load(object sender, EventArgs e)
        {

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
                              where tbl.In_Patient_ID == (int)InPatientID
                              select tbl.Patient_ID).FirstOrDefault();
            var ipdid = InPatientID;
            var patbill = (from tbl in db.Ar_Billings
                           where tbl.Patient_ID == (int)patID && (tbl.isCancel == null ? false : tbl.isCancel) == false
                           select tbl).FirstOrDefault();
            var wardcheck = (from tbl in db.Ward_Allocations
                             where tbl.InPatient_ID == Convert.ToString((int)ipdid)
                             orderby tbl.Ward_Allocation_ID descending
                             select tbl.IsDischarge).FirstOrDefault();


            var user = AppConfig.UserID.ToString();


            if (patbill == null && wardcheck == false)
            {
                SqlTransaction tranObj = null;
                SqlConnection con = new SqlConnection(DBClass.ConnectionString());
                con.Open();
                tranObj = con.BeginTransaction();
                try
                {
                    string id = Convert.ToInt32(InPatientID).ToString();

                    string query = $@"
    UPDATE In_Patient 
    SET is_cancel = 1, cancel_by = '{user}', CancelledTime = GETDATE() 
    WHERE In_Patient_ID = {id};

    UPDATE Ward_Allocation 
    SET isCancelled = 1, CancelledBy = '{user}', CancelledTime = GETDATE() 
    WHERE InPatient_ID = {id};
";

                    bool rowUpdated = DBClass.exectueQuery(query, tranObj, con);



                    




                    tranObj.Commit();

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
                return "Delete";
            }
            return patbill.ToString();

        }



        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue, string fromDate, string toDate)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_pat = _dbContext.In_Patients.Count();
                    var pat = from ipd in _dbContext.In_Patients
                              join p in _dbContext.Reg_patients on ipd.Patient_ID equals p.pat_id
                              where (
                                    (ipd.In_Patient_ID.ToString().Contains(searchValue) || p.mr_no_sequence.ToString().Contains(searchValue) || p.Full_Name.Contains(searchValue) || p.pat_id.ToString().Contains(searchValue) || p.Father_Name.Contains(searchValue) || _dbContext.GetDataValueName("Patient Main Category", ipd.Department).Contains(searchValue)))
                                     && (ipd.is_cancel ?? false) == false
                              select new
                              {
                                  mr_no_sequence = p.mr_no_sequence,
                                  Admission_Date = ipd.Admission_Date,
                                  IN_Patient_ID = ipd.In_Patient_ID,
                                  Full_Name = p.Full_Name,
                                  Father_Name = p.Father_Name,
                                  Death_Date = ipd.DateOfDeath,
                                  Department = _dbContext.GetDataValueName("Patient Main Category", ipd.Department),
                                  Discharge_On = ipd.Discharge_On,
                                  Bed_No  = ipd.Bed_No,
                                  Ward_Name = (from w in _dbContext.Ward_Definitions
                                               where w.Ward_ID == ipd.Ward_ID
                                               select w.Ward_Type).FirstOrDefault(),

                              };

                    // Start / End date filter (yyyy-MM-dd). Blank = no filter (all data).
                    DateTime fromDt, toDt;
                    if (DateTime.TryParseExact(fromDate, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out fromDt))
                    {
                        DateTime fromDateValue = fromDt.Date;
                        pat = pat.Where(a => a.Admission_Date >= fromDateValue);
                    }
                    if (DateTime.TryParseExact(toDate, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out toDt))
                    {
                        DateTime toDateExclusive = toDt.Date.AddDays(1);
                        pat = pat.Where(a => a.Admission_Date < toDateExclusive);
                    }

                    var FilteredCount = pat.Count();
                    switch (sortColumn)
                    {
                        case "MRNO":
                            pat = sortColumnDirection == "asc" ? pat.OrderBy(a => a.mr_no_sequence) : pat.OrderByDescending(a => a.mr_no_sequence);
                            break;
                        case "Patient_ID":
                            pat = sortColumnDirection == "asc" ? pat.OrderBy(a => a.Department) : pat.OrderByDescending(a => a.Department);
                            break;
                        case "DATE":
                            pat = sortColumnDirection == "asc" ? pat.OrderBy(a => a.Admission_Date) : pat.OrderByDescending(a => a.Admission_Date);
                            break;
                        default:
                            pat = pat.OrderByDescending(a => a.IN_Patient_ID);
                            break;
                    }


                    var patientList = pat.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_pat, data = patientList };
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
                string pageName = "InPatientView";

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
                string pageName = "InPatientView";

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
    }
}
