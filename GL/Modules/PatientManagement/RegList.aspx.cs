using Infragistics.Documents.Reports.Report;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class RegList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "RegList";

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
                string pageName = "RegList";

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
                // Log error
                throw;
            }
        }



        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue, string fromDate, string toDate)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_pat = _dbContext.Reg_patients.Count();
                    var pat = from a in _dbContext.Reg_patients
                              where (
                                    (a.Patient_No.ToString().Contains(searchValue) || a.Mobile1.Contains(searchValue) ||a.mr_no_sequence.Contains(searchValue) || a.Old_Mr_no_sequence.Contains(searchValue) || a.Full_Name.Contains(searchValue) || a.NIC.Contains(searchValue)))
                              select new
                              {
                                  pat_id = a.pat_id,
                                  MRNO = a.mr_no_sequence,
                                  Old_Mr_no_sequence = a.Old_Mr_no_sequence,
                                  Patient_No = a.Patient_No,
                                  Full_Name = a.Full_Name,
                                  Age_years = a.Age_years,
                                  Mobile1 = a.Mobile1,
                                  NIC = a.NIC,
                                  Permanent_Address = a.Permanent_Address,
                                  Created_time = a.Created_time,
                                  CreatedBy = _dbContext.aspnet_Users.Where(x => x.UserId == a.Created_by).Select(x => x.UserName).FirstOrDefault() ?? "",
                                  Updated_By = _dbContext.aspnet_Users.Where(x => x.UserId == a.updated_by).Select(x => x.UserName).FirstOrDefault() ?? "",
                                  Charged_by = _dbContext.aspnet_Users.Where(x => x.UserId == a.Charged_by).Select(x => x.UserName).FirstOrDefault() ?? "",
                              };

                    // Start / End date filter (yyyy-MM-dd) on registration date. Blank = no filter (all data).
                    DateTime fromDt, toDt;
                    if (DateTime.TryParseExact(fromDate, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out fromDt))
                    {
                        DateTime fromDateValue = fromDt.Date;
                        pat = pat.Where(a => a.Created_time >= fromDateValue);
                    }
                    if (DateTime.TryParseExact(toDate, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out toDt))
                    {
                        DateTime toDateExclusive = toDt.Date.AddDays(1);
                        pat = pat.Where(a => a.Created_time < toDateExclusive);
                    }

                    var FilteredCount = pat.Count();
                    switch (sortColumn)
                    {
                        case "Age_years":
                            pat = sortColumnDirection == "asc" ? pat.OrderBy(a => a.Age_years) : pat.OrderByDescending(a => a.Age_years);
                            break;
                        case "Created_time":
                            pat = sortColumnDirection == "asc" ? pat.OrderBy(a => a.Created_time) : pat.OrderByDescending(a => a.Created_time);
                            break;
                        default:
                            pat = pat.OrderByDescending(a => a.Created_time); 
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
        public static string EditPatient(string PatID)
        {
            // Get permission value from DB function (returns '0' or '1' as string)
            string allowValue = DBClass.getField(
                $"SELECT dbo.GetRights('AllowPatientEdit', '{AppConfig.UserID}')"
            );

            // Treat null/empty as '0' (not allowed) for safety
            if (Convert.ToBoolean(allowValue) == true)
            {
                return "Allowed";
            }
            else
            {
                return "NotAllowed";
            }
        }

        [WebMethod]
        public static string checkeditPrintRights()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var ups = (from St in db.aspnet_Users
                       where St.UserName == AppConfig.UserName
                       select St.AllowRegListPrint).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(ups);
        }

        [WebMethod]
        public static string GetCurrentPatientData(int pat_id)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var pat = db.Reg_patients.FirstOrDefault(p => p.pat_id == pat_id);
                    if (pat == null) return "null";

                    var data = new
                    {
                        Patient_No = pat.Patient_No,
                        mr_no_sequence = pat.mr_no_sequence,
                        CreationDate = pat.Created_time ?? DateTime.MinValue,
                        Full_Name = pat.Full_Name,
                        Father_Name = pat.Father_Name,
                        Gender = pat.Gender,
                        Mobile1 = pat.Mobile1,
                        Age_years = pat.Age_years,
                        NIC = pat.NIC,
                        Permanent_Address = pat.Permanent_Address,
                        Martial_Status = pat.Martial_Status,
                        Relation_prefix = pat.Relation_prefix,
                        walkin = pat.walkin,
                        city = pat.city,
                        val_city = pat.val_city,
                        val_area = pat.val_area,
                        area = pat.area,
                        Country = pat.Country,
                        Province = pat.Province,
                        Card_fee = pat.Card_fee,
                        other_cnic = pat.other_cnic,
                        DOB = pat.DOB ?? DateTime.MinValue
                    };

                    return new JavaScriptSerializer().Serialize(data);
                }
            }
            catch (Exception ex)
            {
                return "null";
            }
        }

        [WebMethod]
        public static string GetPatientLogs(int pat_id)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var logs = (from l in db.Reg_Patient_Logs
                                where l.Pat_Id == pat_id
                                orderby l.Loged_Time ascending
                                select new
                                {
                                    Log_Id = l.Log_Id,
                                    Loged_Time = l.Loged_Time,
                                    UserName = db.aspnet_Users.Where(u => u.UserId == l.Loged_by).Select(u => u.UserName).FirstOrDefault(),
                                    Updated_data = l.Updated_data
                                }).ToList();

                    return new JavaScriptSerializer().Serialize(logs);
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new List<object>());
            }
        }

        [WebMethod]
        public static string IncrementReprintCount(string pat_id)
        {
            try
            {
                if (string.IsNullOrEmpty(pat_id))
                    return "Error: Invalid ID";

                int id = Convert.ToInt32(pat_id);

                using (var db = new DataBaseDataContext())
                {
                    var patient = db.Reg_patients.FirstOrDefault(p => p.pat_id == id);

                    if (patient != null)
                    {
                        
                        int currentCount = 0;
                        if (!string.IsNullOrEmpty(patient.Reprint) && int.TryParse(patient.Reprint, out int parsed))
                        {
                            currentCount = parsed;
                        }

                        
                        patient.Reprint = (currentCount + 1).ToString();

                        db.SubmitChanges();
                        return "Success";
                    }
                    else
                    {
                        return "Error: Patient not found";
                    }
                }
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }
    }
}