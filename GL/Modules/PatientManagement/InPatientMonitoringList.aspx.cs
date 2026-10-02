using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class InPatientMonitoringList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }


        [WebMethod]
        public static bool DeleteRecord(string InvID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                var Inv_Id = (from itm in db.InPatient_Monitorings
                              where (itm.InPatient_Mon_ID == int.Parse(InvID))
                              select itm.InPatient_Mon_ID).FirstOrDefault();
                if (Inv_Id != 0)
                {
                    DBClass.exectueQuery("delete InPatient_Monitoring where InPatient_Mon_ID =" + Inv_Id, tranObj, con);

                    tranObj.Commit();
                }
                else
                {
                    tranObj.Rollback();
                    return false;
                }
            }
#pragma warning disable CS0168 
            catch (Exception ex)
#pragma warning restore CS0168 
            {
                if (tranObj != null)
                    tranObj.Rollback();
                return false;
            }
            return true;
        }



        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue, string fromDate, string toDate)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Patients = _dbContext.Patients.Count();
                    var IN_Monitoring = from P in _dbContext.Reg_patients
                                    join IPM in _dbContext.InPatient_Monitorings on P.pat_id equals IPM.Patient_ID
                                    where 
                                     ((IPM.InPatient_Mon_ID.ToString().Contains(searchValue) || P.mr_no_sequence.Contains(searchValue) || P.Full_Name.Contains(searchValue)))
                                    select new
                                    {
                                        InPatient_Mon_ID = IPM.InPatient_Mon_ID,
                                        Created_Time = IPM.Created_Time,
                                        mr_no_sequence = P.mr_no_sequence,
                                        Full_Name = P.Full_Name,
                                        Father_Name = P.Father_Name,
                                        Ward_Name = (from IP in _dbContext.In_Patients
                                                     join w in _dbContext.Ward_Definitions on IP.Ward_ID equals w.Ward_ID
                                                     where IP.Patient_ID == IPM.Patient_ID
                                                     select w.Ward_Type).FirstOrDefault(),

                                        Bed_No = (from IP in _dbContext.In_Patients
                                                  where IP.Patient_ID == IPM.Patient_ID
                                                  select IP.Bed_No).FirstOrDefault()
                                    };

                    // Start / End date filter (yyyy-MM-dd). Blank = no filter (all data).
                    DateTime fromDt, toDt;
                    if (DateTime.TryParseExact(fromDate, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out fromDt))
                    {
                        DateTime fromDateValue = fromDt.Date;
                        IN_Monitoring = IN_Monitoring.Where(a => a.Created_Time >= fromDateValue);
                    }
                    if (DateTime.TryParseExact(toDate, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out toDt))
                    {
                        DateTime toDateExclusive = toDt.Date.AddDays(1);
                        IN_Monitoring = IN_Monitoring.Where(a => a.Created_Time < toDateExclusive);
                    }

                    var FilteredCount = IN_Monitoring.Count();
                    switch (sortColumn)
                    {
                        case "InPatient_Mon_ID":
                            IN_Monitoring = sortColumnDirection == "asc" ? IN_Monitoring.OrderBy(a => a.InPatient_Mon_ID) : IN_Monitoring.OrderByDescending(a => a.InPatient_Mon_ID);
                            break;
                        case "mr_no_sequence":
                            IN_Monitoring = sortColumnDirection == "asc" ? IN_Monitoring.OrderBy(b => b.mr_no_sequence) : IN_Monitoring.OrderByDescending(a => a.mr_no_sequence);
                            break;
                        default:
                            IN_Monitoring = IN_Monitoring.OrderByDescending(a => a.InPatient_Mon_ID);
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
                string pageName = "InPatientMonitoringlist";

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
                string pageName = "InPatientMonitoringlist";

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