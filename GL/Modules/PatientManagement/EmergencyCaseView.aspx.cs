using Infragistics.Documents.Reports.Report;
using Infragistics.Web.UI.GridControls;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Linq.SqlClient;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class EmergencyCaseView : System.Web.UI.Page
    {
        DataBaseDataContext db = new DataBaseDataContext();
  

        protected override void OnInit(EventArgs e)
        {
            if (Session["Company_ID"] != null)
            {
                base.OnInit(e);
            }
            else
            {
                Session.Abandon();
                Response.Redirect("~/Account/Login.aspx", true);
            }

        }

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string DeleteRecord(int Emergency_PatientID)
        {

            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var patID = (int)(from tbl in db.Emergency_Patients
                              where tbl.Emergency_ID == (int)Emergency_PatientID
                              select tbl.Patient_ID).FirstOrDefault();

            var patbill = (from tbl in db.Ar_Billings
                           where tbl.Patient_ID == (int)patID && (tbl.isCancel == null ? false : tbl.isCancel) == false
                           select tbl).FirstOrDefault();
            if (patbill == null)
            {
                SqlTransaction tranObj = null;
                SqlConnection con = new SqlConnection(DBClass.ConnectionString());
                con.Open();
                tranObj = con.BeginTransaction();
                try
                {
                    var username = AppConfig.UserID;
                    string id = Convert.ToInt32(Emergency_PatientID).ToString();

                    string query = $@"
    UPDATE Emergency_Patient 
    SET isCancelled = 1, CancelledBy = '{username}', CancelledTime = GETDATE() 
    WHERE Emergency_ID = {id};

    UPDATE Ward_Allocation 
    SET isCancelled = 1, CancelledBy = '{username}', CancelledTime = GETDATE() 
    WHERE EmergencyID = {id};
";

                    bool rowDeleted = DBClass.exectueQuery(query, tranObj, con);


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
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "EmergencyCaseView";

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
                string pageName = "EmergencyCaseView";

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
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue, string filterStatus)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_EmergencyCase = _dbContext.Emergency_Patients.Count();
                    var EmergencyCase = from EP in _dbContext.Emergency_Patients
                                        join p in _dbContext.Reg_patients on EP.Patient_ID equals p.pat_id
                                        where (
                                         (EP.Emergency_ID.ToString().Contains(searchValue) || p.mr_no_sequence.Contains(searchValue) || p.Full_Name.Contains(searchValue) || _dbContext.GetDataValueName("Patient Main Category", EP.Department).Contains(searchValue)))
                                        select new
                                  {
                                      Emergency_ID = EP.Emergency_ID,
                                      Admission_Date = EP.Admission_Date,
                                      mr_no_sequence = p.mr_no_sequence,
                                      Full_Name = p.Full_Name,
                                      Father_Name = p.Father_Name,
                                      Department =  EP.Department,
                                      Discharge_On = EP.Discharge_On,
                                      CreatedBy = _dbContext.aspnet_Users.Where(x => x.UserId == EP.Created_By).Select(x => x.UserName).FirstOrDefault(),
                                      Created_time = EP.Created_Time,
                                      updatedBy = _dbContext.aspnet_Users.Where(x => x.UserId == EP.Created_By).Select(x => x.UserName).FirstOrDefault(),
                                      updated_time = EP.Created_Time,

                                      Patinet_Condition = _dbContext.GetDataValueName("Patient Condition", EP.Emergency_Pat_Condition),
                                      AdmitDays = SqlMethods.DateDiffDay(EP.Admission_Date, DateTime.Now),
                                      DateOfDeath = EP.DateOfDeath
                                        };

                    if (filterStatus == "Admitted")
                    {
                        EmergencyCase = EmergencyCase.Where(x => x.Discharge_On == null);
                    }
                    else if (filterStatus == "Discharged")
                    {
                        EmergencyCase = EmergencyCase.Where(x => x.Discharge_On != null);
                    }

                    var FilteredCount = EmergencyCase.Count();
                    switch (sortColumn)
                    {
                        case "Emergency_ID":
                            EmergencyCase = sortColumnDirection == "asc" ? EmergencyCase.OrderBy(a => a.Emergency_ID) : EmergencyCase.OrderByDescending(a => a.Emergency_ID);
                            break;
                        case "mr_no_sequence":
                            EmergencyCase = sortColumnDirection == "asc" ? EmergencyCase.OrderBy(b => b.mr_no_sequence) : EmergencyCase.OrderByDescending(a => a.mr_no_sequence);
                            break;
                        case "Discharge_On":
                            EmergencyCase = sortColumnDirection == "asc" ? EmergencyCase.OrderBy(a => a.Discharge_On) : EmergencyCase.OrderByDescending(a => a.Discharge_On);
                            break;
                        case "CreatedBy":
                            EmergencyCase = sortColumnDirection == "asc" ? EmergencyCase.OrderBy(a => a.CreatedBy) : EmergencyCase.OrderByDescending(a => a.CreatedBy);
                            break;
                        case "Created_time":
                            EmergencyCase = sortColumnDirection == "asc" ? EmergencyCase.OrderBy(a => a.Created_time) : EmergencyCase.OrderByDescending(a => a.Created_time);
                            break;
                        case "updatedBy":
                            EmergencyCase = sortColumnDirection == "asc" ? EmergencyCase.OrderBy(a => a.updatedBy) : EmergencyCase.OrderByDescending(a => a.updatedBy);
                            break;
                        case "updated_time":
                            EmergencyCase = sortColumnDirection == "asc" ? EmergencyCase.OrderBy(a => a.updated_time) : EmergencyCase.OrderByDescending(a => a.updated_time);
                            break;
                        default:
                            EmergencyCase = EmergencyCase.OrderByDescending(a => a.Emergency_ID);
                            break;
                    }

                    var patientList = EmergencyCase.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_EmergencyCase, data = patientList };
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
