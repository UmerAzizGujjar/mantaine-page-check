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

namespace PMS.Modules.PatientManagement
{
    public partial class OPD_Refund_List : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string CancelRefund(int RefundID)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var OPDRefund = db.OPD_Refunds.FirstOrDefault(b => b.Refund_ID == RefundID);
                    if (OPDRefund == null)
                        return "Error: OPD not found.";

                    OPDRefund.isCancelled = true;
                    OPDRefund.CancelledBy = AppConfig.UserID;
                    OPDRefund.CancelledTime = DateTime.Now;
                    db.SubmitChanges();

                    return "Refund canceled successfully.";
                }
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "OPD_Refund_List";

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
                string pageName = "OPD_Refund_List";

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
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue, string fromDate, string toDate)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Refunds = _dbContext.OPD_Refunds.Count();
                    var Refunds = from R in _dbContext.OPD_Refunds
                                  join reg in _dbContext.Reg_patients on R.Reg_PatId equals reg.pat_id
                                  where ((reg.Full_Name.ToString().Contains(searchValue) || R.Refund_Amount.ToString().Contains(searchValue) || R.OPD_No.ToString().Contains(searchValue)))
                                  select new
                                  {
                                      Refund_ID = R.Refund_ID,
                                      OPD_No = R.OPD_No,
                                      Full_Name = reg.Full_Name,
                                      Refund_Date = R.Refund_Date,
                                      Refund_Amount = R.Refund_Amount,
                                      Hospital_Refund = R.Hospital_Refund,
                                      Doctor_Refund = R.Doctor_Refund,
                                      Status = R.Status ?? "Created",
                                      Remarks = R.Remarks,
                                      isCancelled = R.isCancelled,
                                  };

                    // Start / End date filter (yyyy-MM-dd). Blank = no filter (all data).
                    DateTime fromDt, toDt;
                    if (DateTime.TryParseExact(fromDate, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out fromDt))
                    {
                        DateTime fromDateValue = fromDt.Date;
                        Refunds = Refunds.Where(a => a.Refund_Date >= fromDateValue);
                    }
                    if (DateTime.TryParseExact(toDate, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out toDt))
                    {
                        DateTime toDateExclusive = toDt.Date.AddDays(1);
                        Refunds = Refunds.Where(a => a.Refund_Date < toDateExclusive);
                    }

                    var FilteredCount = Refunds.Count();
                    switch (sortColumn)
                    {
                        case "Refund_ID":
                            Refunds = sortColumnDirection == "asc" ? Refunds.OrderBy(a => a.Refund_ID) : Refunds.OrderByDescending(a => a.Refund_ID);
                            break;
                        case "Refund_Date":
                            Refunds = sortColumnDirection == "asc" ? Refunds.OrderBy(a => a.Refund_Date) : Refunds.OrderByDescending(a => a.Refund_Date);
                            break;
                        default:
                            Refunds = Refunds.OrderByDescending(a => a.Refund_ID);
                            break;
                    }

                    var RefundList = Refunds.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Refunds, data = RefundList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching OPD Refund list", ex);
            }
        }

        [WebMethod]
        public static string ApproveOPDRefunds(string refundIds)
        {
            var user_id = AppConfig.UserID;
            var results = new List<object>();
            int approvedCount = 0;
            int failedCount = 0;

            try
            {
                if (string.IsNullOrEmpty(refundIds))
                {
                    return new JavaScriptSerializer().Serialize(new
                    {
                        Success = false,
                        Message = "No refund IDs provided"
                    });
                }

                string[] ids = refundIds.Split(',');

                string sysCode = "";
                using (var db = new DataBaseDataContext())
                {
                    sysCode = db.sys_Parms
                                .Where(x => x.Name == "Billing Approval")
                                .Select(x => x.Code)
                                .FirstOrDefault();
                }

                foreach (string refundId in ids)
                {
                    if (!string.IsNullOrEmpty(refundId))
                    {
                        try
                        {
                            string message = "";
                            int voucherId = 0;

                            if (sysCode == "01")
                            {
                                // Use stored procedure approval (same as ApproveRefund method)
                                int refundIdInt = Convert.ToInt32(refundId);
                                int patientID;

                                using (var dbFetch = new DataBaseDataContext())
                                {
                                    var refund = dbFetch.OPD_Refunds.FirstOrDefault(r => r.Refund_ID == refundIdInt);
                                    if (refund == null)
                                    {
                                        message = "Record not found";
                                        voucherId = 0;
                                        goto AddResult;
                                    }

                                    if (refund.Status == "Approved")
                                    {
                                        message = "Already approved";
                                        voucherId = 0;
                                        goto AddResult;
                                    }

                                    patientID = (int)refund.pat_id;
                                }

                                using (var dbSP = new DataBaseDataContext())
                                {
                                    var result = dbSP.SpApprove_OPDRefund(patientID, user_id).FirstOrDefault();

                                    if (result == null || string.IsNullOrEmpty(result.Message))
                                    {
                                        message = "Stored procedure did not return a valid response";
                                        voucherId = 0;
                                        goto AddResult;
                                    }

                                    if (!result.Message.Contains("successfully"))
                                    {
                                        message = "Voucher Generation Failed: " + result.Message;
                                        voucherId = 0;
                                        goto AddResult;
                                    }

                                    message = result.Message;
                                    voucherId = 1;
                                }

                                if (voucherId > 0)
                                {
                                    using (var dbUpdate = new DataBaseDataContext())
                                    {
                                        var refund = dbUpdate.OPD_Refunds.FirstOrDefault(r => r.Refund_ID == refundIdInt);
                                        if (refund != null)
                                        {
                                            refund.Status = "Approved";
                                            refund.approve_by = user_id;
                                            refund.approve_date = DateTime.Now;
                                            dbUpdate.SubmitChanges();
                                        }
                                    }
                                }
                            }
                            else if (sysCode == "02")
                            {
                                // Simple approval (same as your working ApproveRefund for code 02)
                                using (var db = new DataBaseDataContext())
                                {
                                    var record = db.OPD_Refunds
                                                   .FirstOrDefault(x => x.Refund_ID == Convert.ToInt32(refundId));

                                    if (record != null)
                                    {
                                        if (record.Status == "Approved")
                                        {
                                            message = "Already approved";
                                            voucherId = 0;
                                        }
                                        else
                                        {
                                            record.Status = "Approved";
                                            record.approve_by = user_id;
                                            record.approve_date = DateTime.Now;

                                            db.SubmitChanges();

                                            message = "Approved Successfully";
                                            voucherId = 1;
                                        }
                                    }
                                    else
                                    {
                                        message = "Record not found";
                                    }
                                }
                            }
                            else
                            {
                                message = "Invalid approval code configuration";
                            }

                            AddResult:
                            if (voucherId > 0)
                            {
                                approvedCount++;
                                results.Add(new
                                {
                                    RefundID = refundId,
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
                                    RefundID = refundId,
                                    Success = false,
                                    Message = string.IsNullOrEmpty(message) ? "Approval failed" : message,
                                    Voucher_ID = 0
                                });
                            }
                        }
                        catch (Exception ex)
                        {
                            failedCount++;
                            results.Add(new
                            {
                                RefundID = refundId,
                                Success = false,
                                Message = "Error: " + ex.Message,
                                Voucher_ID = 0
                            });
                        }
                    }
                }

                var finalResponse = new
                {
                    Success = approvedCount > 0,
                    TotalRecords = ids.Length,
                    ApprovedCount = approvedCount,
                    FailedCount = failedCount,
                    Details = results
                };

                return new JavaScriptSerializer().Serialize(finalResponse);
            }
            catch (Exception ex)
            {
                var errorResponse = new
                {
                    Success = false,
                    Message = "Error: " + ex.Message,
                    TotalRecords = 0,
                    ApprovedCount = 0,
                    FailedCount = 0
                };
                return new JavaScriptSerializer().Serialize(errorResponse);
            }
        }

        public Guid? approve_by { get; set; }
        public DateTime? approve_date { get; set; }
        public string Status { get; set; }
    }
}