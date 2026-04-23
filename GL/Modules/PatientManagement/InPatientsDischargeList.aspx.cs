using PMS.Modules.PatientManagement;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Linq.SqlClient;
using System.Data.SqlClient;
using System.Linq;
using System.Security.Cryptography;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class InPatientsDischargeList : System.Web.UI.Page
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
        public static bool CanUnDischarge()
        {
            try
            {
                var currentUserId = AppConfig.UserID;
                if (currentUserId == Guid.Empty)
                {
                    return false;
                }

                using (var db = new DataBaseDataContext())
                {
                    var user = db.aspnet_Users.FirstOrDefault(u => u.UserId == currentUserId);
                    if (user == null)
                    {
                        return false;
                    }

                    // return user.allow_undischarge == true;

                    return false;
                }
            }
            catch
            {
                return false;
            }
        }

        [WebMethod]
        public static string UnDischargePatients(int[] inPatientIds)
        {
            // TODO: Keep backend authorization check once `allow_undischarge` is added.
            // if (!CanUnDischarge())
            // {
            //     return "You are not authorized to undischage patients.";
            // }

            if (inPatientIds == null || inPatientIds.Length == 0)
            {
                return "Please select at least one patient.";
            }

            using (var db = new DataBaseDataContext())
            {
                foreach (var inPatientId in inPatientIds.Distinct())
                {
                    var inPatient = db.In_Patients.FirstOrDefault(p => p.In_Patient_ID == inPatientId);
                    if (inPatient != null)
                    {
                        inPatient.Discharge = false;
                        inPatient.Discharge_On = null;
                    }

                    var ward = db.Ward_Allocations.Where(w => w.Patient_ID == inPatientId).FirstOrDefault();
                    if (ward != null)
                    {
                        ward.IsDischarge = false;
                    }
                }

                db.SubmitChanges();
            }

            return "Patient(s) undischarged successfully.";
        }

        [WebMethod]
        public static string DeleteRecord(int InPatientID)
        {


            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());


            var patID = (int)(from tbl in db.In_Patients
                              where tbl.In_Patient_ID == (int)InPatientID
                              select tbl.Patient_ID).FirstOrDefault();

            var patbill = (from tbl in db.Ar_Billings
                           where tbl.Patient_ID == (int)patID
                           select tbl).FirstOrDefault();
            if (patbill == null)
            {
                SqlTransaction tranObj = null;
                SqlConnection con = new SqlConnection(DBClass.ConnectionString());
                con.Open();
                tranObj = con.BeginTransaction();
                try
                {
                    bool rowDeleted = DBClass.exectueQuery("Delete In_Patient Where In_Patient_ID=" + Convert.ToInt32(InPatientID) + "", tranObj, con);


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
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"]?.ToString() ?? "N/A";

                    var Total_Patients = _dbContext.Reg_patients.Count();
                    var baseQuery = from P in _dbContext.Reg_patients
                                    join opd in _dbContext.In_Patients on P.pat_id equals opd.Patient_ID
                                    where opd.Discharge == true
                                          && (opd.is_cancel ?? false) == false
                                          && (
                                              P.mr_no_sequence.Contains(searchValue)
                                              || P.Full_Name.Contains(searchValue)
                                              || _dbContext.GetDataValueName("Patient Main Category", opd.Department).Contains(searchValue)
                                              || _dbContext.GetDataValueName("Patient Type", opd.Patient_Discount_Type).Contains(searchValue)
                                          )
                                    select new
                                    {
                                        opd.In_Patient_ID,
                                        opd.Admission_Date,
                                        P.mr_no_sequence,
                                        P.Full_Name,
                                        P.Father_Name,
                                        Department = _dbContext.GetDataValueName("Patient Main Category", opd.Department),
                                        Patient_Type = _dbContext.GetDataValueName("Patient Type", opd.Patient_Discount_Type),
                                        opd.Discharge_By,   // ← Keep as raw string
                                        opd.Discharge_On,
                                        AdmitDays = SqlMethods.DateDiffDay(opd.Admission_Date, DateTime.Now)
                                    };

                    var filteredCount = baseQuery.Count();

                    switch (sortColumn)
                    {
                        case "Department":
                            baseQuery = sortColumnDirection == "asc"
                                ? baseQuery.OrderBy(x => x.Department)
                                : baseQuery.OrderByDescending(x => x.Department);
                            break;
                        case "mr_no_sequence":
                            baseQuery = sortColumnDirection == "asc"
                                ? baseQuery.OrderBy(x => x.mr_no_sequence)
                                : baseQuery.OrderByDescending(x => x.mr_no_sequence);
                            break;
                        case "Patient_Type":
                            baseQuery = sortColumnDirection == "asc"
                                ? baseQuery.OrderBy(x => x.Patient_Type)
                                : baseQuery.OrderByDescending(x => x.Patient_Type);
                            break;
                        case "Discharge_On":
                            baseQuery = sortColumnDirection == "asc"
                                ? baseQuery.OrderBy(x => x.Discharge_On)
                                : baseQuery.OrderByDescending(x => x.Discharge_On);
                            break;
                        default:
                            baseQuery = baseQuery.OrderByDescending(x => x.In_Patient_ID);
                            break;
                    }

                    var pagedData = baseQuery.Skip(start).Take(length).ToList();

                    var possibleEmpIds = pagedData
                        .Select(x => x.Discharge_By)
                        .Where(s => !string.IsNullOrWhiteSpace(s))
                        .Where(s => int.TryParse(s, out _))
                        .Select(s => int.Parse(s))
                        .Distinct()
                        .ToList();

                    var possibleUserIds = pagedData
                        .Select(x => x.Discharge_By)
                        .Where(s => !string.IsNullOrWhiteSpace(s))
                        .Where(s => Guid.TryParse(s, out _))
                        .Select(s => Guid.Parse(s))
                        .Distinct()
                        .ToList();

                    var empDict = _dbContext.HR_Employees
                        .Where(e => possibleEmpIds.Contains(e.Emp_ID))
                        .ToDictionary(e => e.Emp_ID, e => e.Emp_Name);

                    var userDict = _dbContext.aspnet_Users
                        .Where(u => possibleUserIds.Contains(u.UserId))
                        .ToDictionary(u => u.UserId, u => u.UserName);

                    var patientList = pagedData.Select(x =>
                    {
                        string dischargeByName = "N/A";

                        if (int.TryParse(x.Discharge_By, out int empId) && empDict.TryGetValue(empId, out string empName))
                        {
                            dischargeByName = empName;
                        }
                        else if (Guid.TryParse(x.Discharge_By, out Guid userGuid) && userDict.TryGetValue(userGuid, out string userName))
                        {
                            dischargeByName = userName;
                        }
                        else
                        {
                            dischargeByName = x.Discharge_By ?? "N/A";
                        }

                        return new
                        {
                            x.In_Patient_ID,
                            x.Admission_Date,
                            x.mr_no_sequence,
                            x.Full_Name,
                            x.Father_Name,
                            x.Department,
                            x.Patient_Type,
                            Discharge_By = dischargeByName,
                            x.Discharge_On,
                            AdmitDays = SqlMethods.DateDiffDay(x.Admission_Date, DateTime.Now)
                        };
                    }).ToList();

                    return new
                    {
                        draw,
                        recordsFiltered = filteredCount,
                        recordsTotal = Total_Patients,
                        data = patientList
                    };
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
                string pageName = "InPatientDischargelist";

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
                string pageName = "InPatientDischargelist";

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
