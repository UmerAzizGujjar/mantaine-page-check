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
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue, string patientStatusFilter)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Advances = _dbContext.AR_Advances.Count();
                    var Advances = from AR in _dbContext.AR_Advances
                                   join rp in _dbContext.Reg_patients on AR.Patient_ID equals rp.pat_id into rpJoin
                                   from rp in rpJoin.DefaultIfEmpty()
                                   join ip in _dbContext.In_Patients on AR.In_Patient_ID equals ip.In_Patient_ID into ipJoin
                                   from ip in ipJoin.DefaultIfEmpty()
                                   where
                                       ((AR.Advance_Amount.ToString().Contains(searchValue) || AR.Remarks.ToString().Contains(searchValue)))
                                       && (string.IsNullOrEmpty(patientStatusFilter)
                                           || patientStatusFilter == "all"
                                           || (patientStatusFilter == "discharge" && ip.Discharge == true)
                                           || (patientStatusFilter == "admit"     && (ip.Discharge == false || ip.Discharge == null)))
                                  select new
                                  {
                                      Advance_ID = AR.Advance_ID,
                                      Advance_Date = AR.Advance_Date,
                                      Advance_Amount = AR.Advance_Amount,
                                      Remarks = AR.Remarks,
                                      Status = AR.Status ?? "Created",
                                      MrNo = rp != null ? rp.Patient_No : (int?)null,
                                      PatientStatus = ip != null && ip.Discharge == true ? "Discharge" : "Admit",
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
                        case "PatientStatus":
                            Advances = sortColumnDirection == "asc" ? Advances.OrderBy(a => a.PatientStatus) : Advances.OrderByDescending(a => a.PatientStatus);
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
        [WebMethod]
        public static string ApproveAdvances(string advanceIds)
        {
            var user_id = AppConfig.UserID;
            var results = new List<object>();
            int approvedCount = 0;
            int failedCount = 0;

            try
            {
                string[] ids = advanceIds.Split(',');

                string sysCode = "";
                using (var db = new DataBaseDataContext())
                {
                    sysCode = db.sys_Parms
                                .Where(x => x.Name == "Billing Approval")
                                .Select(x => x.Code)
                                .FirstOrDefault();
                }

                foreach (string advanceid in ids)
                {
                    if (!string.IsNullOrEmpty(advanceid))
                    {
                        try
                        {
                            string message = "";
                            int voucherId = 0;
                            if (sysCode == "01")
                            {
                                using (var db = new DataBaseDataContext())
                                {
                                    using (var conn = new SqlConnection(db.Connection.ConnectionString))
                                    {
                                        using (var cmd = new SqlCommand("SpApprove_Advance", conn))
                                        {
                                            cmd.CommandType = CommandType.StoredProcedure;
                                            cmd.Parameters.AddWithValue("@advanceid", Convert.ToInt32(advanceid));
                                            cmd.Parameters.AddWithValue("@user_id", user_id);

                                            conn.Open();

                                            using (var reader = cmd.ExecuteReader())
                                            {
                                                if (reader.Read())
                                                {
                                                    message = reader["Message"].ToString();
                                                    voucherId = Convert.ToInt32(reader["Voucher_ID"]);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            else if (sysCode == "02")
                            {
                                using (var db = new DataBaseDataContext())
                                {
                                    var record = db.AR_Advances
                                                   .FirstOrDefault(x => x.Advance_ID == Convert.ToInt32(advanceid));

                                    if (record != null)
                                    {
                                        record.Status = "Approved";
                                        record.Approve_by = user_id;
                                        record.Approve_date = DateTime.Now;

                                        db.SubmitChanges();

                                        message = "Approved Successfully";
                                        voucherId = 1; 
                                    }
                                    else
                                    {
                                        message = "Record not found";
                                    }
                                }
                            }
                            if (voucherId > 0)
                            {
                                approvedCount++;
                                results.Add(new
                                {
                                    AdvanceID = advanceid,
                                    Success = true,
                                    Message = message,
                                    Voucher_ID = voucherId
                                });
                            }
                            else
                            {
                                failedCount++;
                                results.Add(new
                                {
                                    AdvanceID = advanceid,
                                    Success = false,
                                    Message = message,
                                    Voucher_ID = 0
                                });
                            }
                        }
                        catch (Exception ex)
                        {
                            failedCount++;
                            results.Add(new
                            {
                                AdvanceID = advanceid,
                                Success = false,
                                Message = ex.Message,
                                Voucher_ID = 0
                            });
                        }
                    }
                }

                var finalResponse = new
                {
                    TotalRecords = ids.Length,
                    ApprovedCount = approvedCount,
                    FailedCount = failedCount,
                    Details = results,
                    Success = approvedCount > 0
                };

                return new JavaScriptSerializer().Serialize(finalResponse);
            }
            catch (Exception ex)
            {
                var errorResponse = new
                {
                    Success = false,
                    Message = ex.Message,
                    TotalRecords = 0,
                    ApprovedCount = 0,
                    FailedCount = 0
                };
                return new JavaScriptSerializer().Serialize(errorResponse);
            }
        }
    }
}