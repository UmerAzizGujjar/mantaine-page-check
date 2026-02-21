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
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_pat = _dbContext.Reg_patients.Count();
                    var pat = from a in _dbContext.Reg_patients
                              where (
                                    (a.Patient_No.ToString().Contains(searchValue) || a.Mobile1.Contains(searchValue) ||a.mr_no_sequence.Contains(searchValue) || a.Full_Name.Contains(searchValue) || a.NIC.Contains(searchValue)))
                              select new
                              {
                                  pat_id = a.pat_id,
                                  MRNO = a.mr_no_sequence,
                                  Patient_No = a.Patient_No,
                                  Full_Name = a.Full_Name,
                                  Age_years = a.Age_years,
                                  Mobile1 = a.Mobile1,
                                  NIC = a.NIC,
                                  Permanent_Address = a.Permanent_Address,
                                  Created_time = a.Created_time,
                              };

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
    }
}