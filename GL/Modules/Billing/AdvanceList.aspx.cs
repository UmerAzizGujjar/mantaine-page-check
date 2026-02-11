using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web;

namespace PMS
{
    public partial class AdvanceList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string Search(int Patient_No) 
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var querySearch=(from data in db.AR_Advances join pat in db.Patients on data.Patient_ID equals pat.Patient_ID where pat.Patient_No.Equals(Patient_No) select new
            {
                data.Advance_ID,
                data.Advance_Date,
                data.Advance_Amount,
                data.Remarks,
                MrNo = DBClass.GetMRNOBy_RegID(Convert.ToInt32(data.Patient_ID)),
            
            
            }).ToList();

            return (new JavaScriptSerializer()).Serialize(querySearch);
        }
        [WebMethod]
        public static bool DeleteRecord(string advId)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
          

            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                var advid = (from itm in db.AR_Advances
                             where (itm.Advance_ID == int.Parse(advId))
                                   select itm.Advance_ID).FirstOrDefault();
                if (advid != 0)
                {
                    string query = $@"
                        UPDATE AR_Advances 
                        SET isCancelled = 1, 
                            CancelledBy = '{AppConfig.UserID}', 
                            CancelledTime = GETDATE() 
                        WHERE Advance_ID = {Convert.ToInt32(advid)};
                    ";

                    bool rowUpdated = DBClass.exectueQuery(query, tranObj, con);



                 
                    tranObj.Commit();
                }
                else
                {
                    tranObj.Rollback();
                    return false;
                }
            }
            catch (Exception ex)
            {
                if (tranObj != null)
                    tranObj.Rollback();
                return false;
            }
            return true;
        }

        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Advances = _dbContext.AR_Advances.Count();
                    var Advances = from AR in _dbContext.AR_Advances
                                   where
                                       ((AR.Advance_Amount.ToString().Contains(searchValue) || AR.Remarks.ToString().Contains(searchValue)))
                                  select new
                                  {
                                      Advance_ID = AR.Advance_ID,
                                      Advance_Date = AR.Advance_Date,
                                      Advance_Amount = AR.Advance_Amount,
                                      Remarks = AR.Remarks,
                                     // MrNo = DBClass.GetMRNOBy_PatientID(Convert.ToInt32(AR.Patient_ID)),
                                      MrNo = (from bl in _dbContext.Reg_patients where bl.pat_id == AR.Patient_ID select bl.Patient_No).FirstOrDefault(),
                                  };

                    var FilteredCount = Advances.Count();
                    switch (sortColumn)
                    {
                        case "Advance_Date":
                            Advances = sortColumnDirection == "asc" ? Advances.OrderBy(b => b.Advance_Date) : Advances.OrderByDescending(a => a.Advance_Date);
                            break;
                        case "MrNo":
                            Advances = sortColumnDirection == "asc" ? Advances.OrderBy(a => a.MrNo) : Advances.OrderByDescending(a => a.MrNo);
                           break;
                        default:
                            Advances = Advances.OrderByDescending(a => a.Advance_ID);
                            break;
                    }

                    var AdvanceList = Advances.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Advances, data = AdvanceList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Advance list", ex);
            }
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "AdvanceList";

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
                string pageName = "AdvanceList";

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