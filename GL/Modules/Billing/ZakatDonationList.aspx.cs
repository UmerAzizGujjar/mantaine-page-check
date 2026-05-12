using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Billing
{
    public partial class ZakatDonationList : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Check authorization
                if (HttpContext.Current.Session["UserID"] == null)
                    Response.Redirect("~/Login.aspx");
            }
        }

        // ===== GET USER COLUMN PREFERENCES =====
        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "ZakatDonationList";

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
                System.Diagnostics.Trace.TraceError($"Error loading column preferences: {ex.Message}");
                return "";
            }
        }

        // ===== SAVE USER COLUMN PREFERENCES =====
        [WebMethod]
        public static void SaveUserColumnPreferences(string visibilityJson)
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "ZakatDonationList";

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
                System.Diagnostics.Trace.TraceError($"Error saving column preferences: {ex.Message}");
            }
        }

        // ===== GET DONATION LIST WITH FILTERING AND SORTING =====
        [WebMethod]
        public static object GetDonationList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    // Get total count
                    int totalRecords = db.DonationRecords.Count();

                    // Build query with search filtering
                    var donations = from d in db.DonationRecords
                                    where (string.IsNullOrEmpty(searchValue) ||
                                           d.DonorName.Contains(searchValue) ||
                                           d.PhoneNo.Contains(searchValue) ||
                                           d.ProjectName.Contains(searchValue) ||
                                           d.DonationType.Contains(searchValue) ||
                                           d.DonorID.ToString().Contains(searchValue) ||
                                           d.DonorReceiptNo.ToString().Contains(searchValue))
                                    select new
                                    {
                                        d.RecordID,
                                        d.DonorID,
                                        d.DonorReceiptNo,
                                        d.DonorName,
                                        d.PhoneNo,
                                        d.DonorAddress,
                                        d.ProjectName,
                                        d.DonationType,
                                        d.PaymentType,
                                        d.ChequeNo,
                                        d.DonorDetail,
                                        d.ReceiptAmount,
                                        d.TransactionDateTime,
                                        d.CreatedAt,
                                        d.UpdatedAt
                                    };

                    int filteredRecords = donations.Count();

                    // Apply sorting
                    switch (sortColumn)
                    {
                        case "DonorID":
                            donations = sortColumnDirection == "asc" 
                                ? donations.OrderBy(a => a.DonorID) 
                                : donations.OrderByDescending(a => a.DonorID);
                            break;
                        case "TransactionDateTime":
                            donations = sortColumnDirection == "asc" 
                                ? donations.OrderBy(a => a.TransactionDateTime) 
                                : donations.OrderByDescending(a => a.TransactionDateTime);
                            break;
                        case "ReceiptAmount":
                            donations = sortColumnDirection == "asc" 
                                ? donations.OrderBy(a => a.ReceiptAmount) 
                                : donations.OrderByDescending(a => a.ReceiptAmount);
                            break;
                        case "DonorName":
                            donations = sortColumnDirection == "asc" 
                                ? donations.OrderBy(a => a.DonorName) 
                                : donations.OrderByDescending(a => a.DonorName);
                            break;
                        default:
                            donations = donations.OrderByDescending(a => a.TransactionDateTime);
                            break;
                    }

                    // Apply pagination
                    var donationList = donations.Skip(start).Take(length).ToList();

                    var jsonData = new
                    {
                        draw = draw,
                        recordsFiltered = filteredRecords,
                        recordsTotal = totalRecords,
                        data = donationList
                    };

                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error fetching donation list: {ex.Message}");
                return new
                {
                    draw = draw,
                    recordsFiltered = 0,
                    recordsTotal = 0,
                    data = new List<object>()
                };
            }
        }

        // ===== GET DONATION DETAILS =====
        [WebMethod]
        public static string GetDonationDetails(int recordId)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var donation = (from d in db.DonationRecords
                                    where d.RecordID == recordId
                                    select new
                                    {
                                        d.RecordID,
                                        d.DonorID,
                                        d.DonorReceiptNo,
                                        d.DonorName,
                                        d.PhoneNo,
                                        d.DonorAddress,
                                        d.ProjectName,
                                        d.DonationType,
                                        d.PaymentType,
                                        d.ChequeNo,
                                        d.DonorDetail,
                                        d.ReceiptAmount,
                                        d.TransactionDateTime,
                                        d.CreatedAt,
                                        d.UpdatedAt
                                    }).FirstOrDefault();

                    if (donation == null)
                        return new JavaScriptSerializer().Serialize((object)null);

                    var safeData = new
                    {
                        RecordID = donation.RecordID,
                        DonorID = donation.DonorID,
                        DonorReceiptNo = donation.DonorReceiptNo,
                        DonorName = HttpUtility.HtmlEncode(donation.DonorName ?? ""),
                        PhoneNo = donation.PhoneNo ?? "",
                        DonorAddress = HttpUtility.HtmlEncode(donation.DonorAddress ?? ""),
                        ProjectName = HttpUtility.HtmlEncode(donation.ProjectName ?? ""),
                        DonationType = donation.DonationType ?? "",
                        PaymentType = donation.PaymentType ?? "",
                        ChequeNo = donation.ChequeNo ?? "",
                        DonorDetail = HttpUtility.HtmlEncode(donation.DonorDetail ?? ""),
                        ReceiptAmount = donation.ReceiptAmount,
                        TransactionDateTime = donation.TransactionDateTime,
                        CreatedAt = donation.CreatedAt,
                        UpdatedAt = donation.UpdatedAt
                    };

                    return new JavaScriptSerializer().Serialize(safeData);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error loading donation details: {ex.Message}");
                return new JavaScriptSerializer().Serialize((object)null);
            }
        }

        // ===== DELETE DONATION =====
        [WebMethod]
        public static string DeleteDonation(int recordId)
        {
            // Authorization check
            if (HttpContext.Current.Session["UserID"] == null)
                return new JavaScriptSerializer().Serialize(
                    new { Success = false, Message = "ERROR: Unauthorized. Please log in." });

            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var record = db.DonationRecords.FirstOrDefault(r => r.RecordID == recordId);
                    
                    if (record == null)
                        return new JavaScriptSerializer().Serialize(
                            new { Success = false, Message = "ERROR: Donation record not found." });

                    db.DonationRecords.DeleteOnSubmit(record);
                    db.SubmitChanges();

                    System.Diagnostics.Trace.TraceInformation($"Donation Record {recordId} deleted by user {AppConfig.UserID}");

                    return new JavaScriptSerializer().Serialize(
                        new { Success = true, Message = "Donation record deleted successfully." });
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error deleting donation record: {ex.Message}");
                return new JavaScriptSerializer().Serialize(
                    new { Success = false, Message = "ERROR: Failed to delete donation record. " + ex.Message });
            }
        }

        // ===== GET DONATION SUMMARY STATISTICS =====
        [WebMethod]
        public static string GetDonationSummary()
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var summary = new
                    {
                        TotalDonations = db.DonationRecords.Count(),
                        TotalAmount = db.DonationRecords.Sum(d => (decimal?)d.ReceiptAmount) ?? 0m,
                        CashDonations = db.DonationRecords.Count(d => d.PaymentType == "Cash"),
                        ChequeDonations = db.DonationRecords.Count(d => d.PaymentType == "Cheque"),
                        AverageAmount = db.DonationRecords.Count() > 0 
                            ? db.DonationRecords.Average(d => (decimal?)d.ReceiptAmount) ?? 0m 
                            : 0m
                    };

                    return new JavaScriptSerializer().Serialize(summary);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error getting donation summary: {ex.Message}");
                return new JavaScriptSerializer().Serialize(
                    new { TotalDonations = 0, TotalAmount = 0m, CashDonations = 0, ChequeDonations = 0, AverageAmount = 0m });
            }
        }

        // ===== GET DONATIONS BY PROJECT =====
        [WebMethod]
        public static string GetDonationsByProject()
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var summary = (from d in db.DonationRecords
                                   group d by d.ProjectName into g
                                   select new
                                   {
                                       ProjectName = g.Key,
                                       TotalAmount = g.Sum(x => x.ReceiptAmount),
                                       Count = g.Count()
                                   }).OrderByDescending(x => x.TotalAmount).ToList();

                    return new JavaScriptSerializer().Serialize(summary);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error getting donations by project: {ex.Message}");
                return new JavaScriptSerializer().Serialize(new List<object>());
            }
        }
    }
}