using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.PatientManagement
{
    public partial class ERRefundView : System.Web.UI.Page
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
                    var OPDRefund = db.Emergency_refunds.FirstOrDefault(b => b.Refund_ID == RefundID);
                    if (OPDRefund == null)
                        return "Error: Emergency not found.";

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
                string pageName = "ERRefundView";

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
                string pageName = "ERRefundView";

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
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    // Count total non-cancelled emergency refunds
                    var Total_Refunds = _dbContext.Emergency_refunds
                        .Count(r => r.isCancelled == false || r.isCancelled == null);

                    // Query emergency refunds with patient details
                    var Refunds = from R in _dbContext.Emergency_refunds
                                  join reg in _dbContext.Reg_patients on R.pat_id equals reg.pat_id
                                  where (R.isCancelled == false || R.isCancelled == null) &&
                                        ((reg.Full_Name.ToString().Contains(searchValue) ||
                                          R.Refund_Amount.ToString().Contains(searchValue) ||
                                          R.emergency_No.ToString().Contains(searchValue)))
                                  select new
                                  {
                                      Refund_ID = R.Refund_ID,
                                      emergency_No = R.emergency_No,
                                      Full_Name = reg.Full_Name,
                                      Refund_Date = R.Refund_Date,
                                      Refund_Amount = R.Refund_Amount,
                                      Hospital_Refund = R.Hospital_Refund,
                                      Doctor_Refund = R.Doctor_Refund,
                                      Remarks = R.Remarks
                                  };

                    var FilteredCount = Refunds.Count();

                    // Apply sorting
                    switch (sortColumn)
                    {
                        case "emergency_No":
                            Refunds = sortColumnDirection == "asc" ? Refunds.OrderBy(a => a.emergency_No) : Refunds.OrderByDescending(a => a.emergency_No);
                            break;
                        case "Refund_Date":
                            Refunds = sortColumnDirection == "asc" ? Refunds.OrderBy(a => a.Refund_Date) : Refunds.OrderByDescending(a => a.Refund_Date);
                            break;
                        case "Refund_ID":
                            Refunds = sortColumnDirection == "asc" ? Refunds.OrderBy(a => a.Refund_ID) : Refunds.OrderByDescending(a => a.Refund_ID);
                            break;
                        default:
                            Refunds = Refunds.OrderByDescending(a => a.Refund_ID);
                            break;
                    }

                    var RefundList = Refunds.Skip(start).Take(length).ToList();

                    var jsonData = new
                    {
                        draw = draw,
                        recordsFiltered = FilteredCount,
                        recordsTotal = Total_Refunds,
                        data = RefundList
                    };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Emergency Refund list", ex);
            }
        }
    }
}