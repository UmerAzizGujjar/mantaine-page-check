using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web;

namespace PMS.Modules.Billing
{
    public partial class ZakatDonationForm : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string token = Guid.NewGuid().ToString();
                Session["AntiForgeryToken"] = token;
            }
        }

        // ===== INPUT SANITIZATION HELPER =====
        private static string SanitizeInput(string input)
        {
            if (string.IsNullOrWhiteSpace(input))
                return input;

            return Regex.Replace(input.Trim(), @"<[^>]*>", "", RegexOptions.IgnoreCase);
        }

        // ===== VALIDATION HELPERS =====
        public static class DonationValidationHelper
        {
            public static bool IsValidName(string name)
            {
                return !string.IsNullOrWhiteSpace(name) &&
                       name.Length <= 255 &&
                       Regex.IsMatch(name, @"^[a-zA-Z\s\.\-']+$");
            }

            public static bool IsValidPhone(string phone)
            {
                if (string.IsNullOrWhiteSpace(phone)) return true; // Optional field
                return Regex.IsMatch(phone, @"^\+?92?[0-9]{10}$|^[0-9\-\s\(\)]{10,20}$");
            }

            public static bool IsValidAmount(string amountStr)
            {
                if (string.IsNullOrWhiteSpace(amountStr)) return false;
                return decimal.TryParse(amountStr.Trim(), NumberStyles.Number,
                    CultureInfo.InvariantCulture, out decimal amount) && amount > 0;
            }

            public static bool IsValidChequeNo(string chequeNo)
            {
                if (string.IsNullOrWhiteSpace(chequeNo)) return true; // Optional if not cheque payment
                return Regex.IsMatch(chequeNo, @"^\d{6,20}$");
            }

            public static bool IsValidAddress(string address)
            {
                if (string.IsNullOrWhiteSpace(address)) return true; // Optional field
                return address.Length <= 500;
            }

            public static bool IsValidDonationDetail(string detail)
            {
                if (string.IsNullOrWhiteSpace(detail)) return true; // Optional field
                return detail.Length <= 1000;
            }
        }

        // ===== DONATION DATA MODEL =====
        public class DonationDTO
        {
            public int RecordID { get; set; }
            public int DonorID { get; set; }
            public int DonorReceiptNo { get; set; }
            public string DonorName { get; set; }
            public string PhoneNo { get; set; }
            public string DonorAddress { get; set; }
            public string ProjectName { get; set; }
            public string DonationType { get; set; }
            public string PaymentType { get; set; }
            public string ChequeNo { get; set; }
            public string DonorDetail { get; set; }
            public decimal ReceiptAmount { get; set; }
            public DateTime TransactionDateTime { get; set; }
        }

        // ===== RESPONSE MODEL =====
        public class SaveResponse
        {
            public bool Success { get; set; }
            public int RecordID { get; set; }
            public int NextDonorID { get; set; }
            public int NextReceiptNo { get; set; }
            public string Message { get; set; }
        }

        // ===== GET NEXT DONOR ID =====
        [WebMethod]
        public static string GetNextDonorID()
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    int? maxDonorID = db.DonationRecords.Max(d => (int?)d.DonorID);
                    int nextID = (maxDonorID ?? 0) + 1;
                    return nextID.ToString();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error getting next Donor ID: {ex.Message}");
                return "1";
            }
        }

        // ===== GET NEXT RECEIPT NO =====
        [WebMethod]
        public static string GetNextReceiptNo()
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    int? maxReceiptNo = db.DonationRecords.Max(d => (int?)d.DonorReceiptNo);
                    int nextReceiptNo = (maxReceiptNo ?? 0) + 1;
                    return nextReceiptNo.ToString();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error getting next Receipt No: {ex.Message}");
                return "1";
            }
        }

        // ===== LOAD DROPDOWNS FROM DATAVALUES =====
        [WebMethod]
        public static string GetProjectNames()
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var result = (from dv in db.DataValues
                                  join ds in db.ValueSets on dv.ValueSet_ID equals ds.ValueSet_ID
                                  where ds.ValueSet_Name == "ProjectName"
                                  orderby dv.DataValue_Name
                                  select new { dv.DataValue_Name, dv.DataValue_Description }).ToList();
                    return new JavaScriptSerializer().Serialize(result);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error loading Project Names: {ex.Message}");
                return new JavaScriptSerializer().Serialize(new List<object>());
            }
        }

        [WebMethod]
        public static string GetDonationTypes()
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var result = (from dv in db.DataValues
                                  join ds in db.ValueSets on dv.ValueSet_ID equals ds.ValueSet_ID
                                  where ds.ValueSet_Name == "DonationType"
                                  orderby dv.DataValue_Name
                                  select new { dv.DataValue_Name, dv.DataValue_Description }).ToList();
                    return new JavaScriptSerializer().Serialize(result);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error loading Donation Types: {ex.Message}");
                return new JavaScriptSerializer().Serialize(new List<object>());
            }
        }

        [WebMethod]
        public static string GetPaymentTypes()
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var result = (from dv in db.DataValues
                                  join ds in db.ValueSets on dv.ValueSet_ID equals ds.ValueSet_ID
                                  where ds.ValueSet_Name == "PaymentType"
                                  orderby dv.DataValue_Name
                                  select new { dv.DataValue_Name, dv.DataValue_Description }).ToList();
                    return new JavaScriptSerializer().Serialize(result);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error loading Payment Types: {ex.Message}");
                return new JavaScriptSerializer().Serialize(new List<object>());
            }
        }

        // ===== SAVE DONATION (CREATE/UPDATE) =====
        [WebMethod]
        public static string SaveDonation(DonationDTO donation, string AntiForgeryToken)
        {
            // Validate Session
            if (HttpContext.Current.Session["UserID"] == null)
                return new JavaScriptSerializer().Serialize(
                    new { Success = false, Message = "ERROR: Unauthorized. Please log in." });

            // Validate CSRF Token
            string storedToken = HttpContext.Current.Session["AntiForgeryToken"] as string;
            if (string.IsNullOrEmpty(storedToken) || !storedToken.Equals(AntiForgeryToken))
                return new JavaScriptSerializer().Serialize(
                    new { Success = false, Message = "ERROR: Invalid request. Possible CSRF attack." });

            // Sanitize Inputs
            donation.DonorName = SanitizeInput(donation.DonorName);
            donation.DonorAddress = SanitizeInput(donation.DonorAddress);
            donation.ProjectName = SanitizeInput(donation.ProjectName);
            donation.DonorDetail = SanitizeInput(donation.DonorDetail);
            donation.ChequeNo = SanitizeInput(donation.ChequeNo);

            // Validate Required Fields
            if (!DonationValidationHelper.IsValidName(donation.DonorName))
                return new JavaScriptSerializer().Serialize(
                    new { Success = false, Message = "ERROR: Invalid donor name. Use letters, spaces, dots, or hyphens (max 255 chars)." });

            if (!DonationValidationHelper.IsValidAmount(donation.ReceiptAmount.ToString()))
                return new JavaScriptSerializer().Serialize(
                    new { Success = false, Message = "ERROR: Invalid amount. Please enter a valid positive number." });

            if (!DonationValidationHelper.IsValidPhone(donation.PhoneNo))
                return new JavaScriptSerializer().Serialize(
                    new { Success = false, Message = "ERROR: Invalid phone number format." });

            if (donation.PaymentType == "Cheque" && !DonationValidationHelper.IsValidChequeNo(donation.ChequeNo))
                return new JavaScriptSerializer().Serialize(
                    new { Success = false, Message = "ERROR: Cheque number must be 6-20 digits for cheque payments." });

            if (!DonationValidationHelper.IsValidAddress(donation.DonorAddress))
                return new JavaScriptSerializer().Serialize(
                    new { Success = false, Message = "ERROR: Address must be 500 characters or less." });

            if (!DonationValidationHelper.IsValidDonationDetail(donation.DonorDetail))
                return new JavaScriptSerializer().Serialize(
                    new { Success = false, Message = "ERROR: Details must be 1000 characters or less." });

            try
            {
                using (var db = new DataBaseDataContext())
                {
                    DonationRecord record;
                    bool isNew = donation.RecordID == 0;

                    if (!isNew)
                    {
                        // Edit Mode
                        record = db.DonationRecords.FirstOrDefault(r => r.RecordID == donation.RecordID);
                        if (record == null)
                            return new JavaScriptSerializer().Serialize(
                                new { Success = false, Message = "ERROR: Donation record not found." });

                        record.UpdatedBy = GetUserGuid();
                        record.UpdatedAt = DateTime.Now;
                    }
                    else
                    {
                        // Create Mode
                        record = new DonationRecord
                        {
                            CreatedBy = GetUserGuid(),
                            CreatedAt = DateTime.Now
                        };
                        db.DonationRecords.InsertOnSubmit(record);
                    }

                    // Assign values
                    record.DonorID = donation.DonorID;
                    record.DonorReceiptNo = donation.DonorReceiptNo;
                    record.DonorName = donation.DonorName;
                    record.PhoneNo = donation.PhoneNo;
                    record.DonorAddress = donation.DonorAddress;
                    record.ProjectName = donation.ProjectName;
                    record.DonationType = donation.DonationType;
                    record.PaymentType = donation.PaymentType;
                    record.ChequeNo = donation.ChequeNo;
                    record.DonorDetail = donation.DonorDetail;
                    record.ReceiptAmount = donation.ReceiptAmount;
                    record.TransactionDateTime = donation.TransactionDateTime;

                    db.SubmitChanges();

                    // Get next IDs for UI
                    int nextDonorID = (db.DonationRecords.Max(d => (int?)d.DonorID) ?? 0) + 1;
                    int nextReceiptNo = (db.DonationRecords.Max(d => (int?)d.DonorReceiptNo) ?? 0) + 1;

                    return new JavaScriptSerializer().Serialize(new SaveResponse
                    {
                        Success = true,
                        RecordID = record.RecordID,
                        NextDonorID = nextDonorID,
                        NextReceiptNo = nextReceiptNo,
                        Message = isNew ? "Donation saved successfully." : "Donation updated successfully."
                    });
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error saving donation: {ex.Message}");
                return new JavaScriptSerializer().Serialize(
                    new { Success = false, Message = "ERROR: Failed to save donation. Please try again." });
            }
        }

        // ===== GET DONATION FOR EDIT =====
        [WebMethod]
        public static string GetDonation(int recordId)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var record = (from d in db.DonationRecords
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
                                      d.TransactionDateTime
                                  }).FirstOrDefault();

                    if (record == null)
                        return new JavaScriptSerializer().Serialize((object)null);

                    var safeData = new
                    {
                        RecordID = record.RecordID,
                        DonorID = record.DonorID,
                        DonorReceiptNo = record.DonorReceiptNo,
                        DonorName = HttpUtility.HtmlEncode(record.DonorName ?? ""),
                        PhoneNo = record.PhoneNo,
                        DonorAddress = HttpUtility.HtmlEncode(record.DonorAddress ?? ""),
                        ProjectName = HttpUtility.HtmlEncode(record.ProjectName ?? ""),
                        DonationType = record.DonationType,
                        PaymentType = record.PaymentType,
                        ChequeNo = record.ChequeNo,
                        DonorDetail = HttpUtility.HtmlEncode(record.DonorDetail ?? ""),
                        ReceiptAmount = record.ReceiptAmount,
                        TransactionDateTime = record.TransactionDateTime
                    };

                    return new JavaScriptSerializer().Serialize(safeData);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error loading donation record: {ex.Message}");
                return new JavaScriptSerializer().Serialize((object)null);
            }
        }

        // ===== HELPER METHOD TO GET USER GUID =====
        private static Guid GetUserGuid()
        {
            var userIdObj = HttpContext.Current.Session["UserID"];
            if (userIdObj != null && Guid.TryParse(userIdObj.ToString(), out Guid userId))
                return userId;
            return Guid.Empty;
        }
    }
}