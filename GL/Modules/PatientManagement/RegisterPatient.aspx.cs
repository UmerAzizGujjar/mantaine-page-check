using QRCoder;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Configuration;
using System.Data;
using System.Data.Entity;
using System.Data.SqlClient;

using System.Text;

using System.Web.UI.WebControls;
using System.Windows;
using Telerik.Web;
using Telerik.Web.UI.ImageEditor;

namespace PMS.Modules.PatientManagement
{
   
   
    public partial class RegisterPatient : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string token = Guid.NewGuid().ToString();
                Session["AntiForgeryToken"] = token;
                hfAntiForgery.Value = token;
            }
        }

        private static string GenerateAndSaveQRCode(Reg_patient pat)
        {
            try
            {
                // SAFE null handling for QR content
                string mrNo = pat.mr_no_sequence?.Trim() ?? "N/A";
                string fullName = pat.Full_Name?.Trim() ?? "N/A";
                string age = pat.Age_years?.Trim() ?? "N/A";
                string gender = pat.Gender?.Trim() ?? "N/A";

                // Minimal secure payload (NO sensitive data)
                string qrContent = $"MR:{mrNo}|N:{fullName}|A:{age}|G:{gender}";

                using (var qrGenerator = new QRCodeGenerator())
                using (var qrCodeData = qrGenerator.CreateQrCode(qrContent, QRCodeGenerator.ECCLevel.Q))
                using (var qrCode = new QRCode(qrCodeData))
                using (var qrCodeImage = qrCode.GetGraphic(10))
                {
                    // Create secure folder path
                    string qrFolder = HttpContext.Current.Server.MapPath("~/PatientQRs");
                    if (!Directory.Exists(qrFolder))
                        Directory.CreateDirectory(qrFolder);

                    // Sanitize filename (prevent path traversal)
                    string safeMrNo = Regex.Replace(mrNo, @"[^\w\-\.]", "_");
                    string fileName = $"{safeMrNo}_{DateTime.Now:yyyyMMddHHmmssfff}.png";
                    string fullPath = Path.Combine(qrFolder, fileName);

                    // Save image
                    qrCodeImage.Save(fullPath, ImageFormat.Png);
                    return $"/PatientQRs/{fileName}"; // Relative path for DB
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError(
                    $"QR generation failed for MR:{pat?.mr_no_sequence}: {ex.Message}");
                return null; // NEVER fail registration due to QR issue
            }
        }
        //Added newly 


        // ===== XSS SANITIZATION HELPER =====
        private static string SanitizeInput(string input)
        {
            if (string.IsNullOrWhiteSpace(input))
                return input;

            // Remove any HTML/script tags to prevent Stored XSS
            return Regex.Replace(input.Trim(), @"<[^>]*>", "", RegexOptions.IgnoreCase);
        }

        public static class ValidationHelper
        {
            public static bool IsValidMobile(string mobile)
            {
                return !string.IsNullOrWhiteSpace(mobile) &&
                       Regex.IsMatch(mobile, @"^\+92[0-9]{10}$");
            }

            public static bool IsValidCNIC(string cnic)
            {
                return !string.IsNullOrWhiteSpace(cnic) &&
                       Regex.IsMatch(cnic, @"^\d{5}-\d{7}-\d$");
            }

            public static bool IsValidName(string name)
            {
                return !string.IsNullOrWhiteSpace(name) &&
                       name.Length <= 100 &&
                       Regex.IsMatch(name, @"^[a-zA-Z\s\.\-]+$");
            }

            public static bool IsValidAddress(string address)
            {
                return !string.IsNullOrWhiteSpace(address) && address.Length <= 500;
            }

            public static bool IsValidAge(string ageStr)
            {
                if (string.IsNullOrWhiteSpace(ageStr)) return false;
                if (!int.TryParse(ageStr, out int age)) return false;
                return age >= 0 && age <= 150;
            }

            public static bool IsValidDate(string dateStr)
            {
                return DateTime.TryParseExact(dateStr, "dd/MM/yyyy", null, System.Globalization.DateTimeStyles.None, out _);
            }
        }
        [WebMethod]
        public static string approvepatient(string Pat_Id)
        {
            var UserId = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_ApprovePatientCardFee(Convert.ToInt32(Pat_Id), UserId);
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string GetCardFee()
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var fee = (from tbl in db.sys_Parms
                               where tbl.Name == "OPD Fee"
                               select tbl.Code) 
                              .FirstOrDefault();

                    return fee ?? "0";
                }
            }
            catch (Exception ex)
            {
                
                return "0";
            }
        }
        public class SafePatientData
        {
            public string Name { get; set; }
            public string FatherName { get; set; }
            public string Relation { get; set; }
            public string Gender_text { get; set; }
            public string Age { get; set; }
            public string MaritalStatus_text { get; set; }
            public string Mr_No { get; set; }
            public string Address { get; set; }
            public string Mobile { get; set; }
            public string BloodGroup_text { get; set; }
            public string Country_text { get; set; }
            public string State_text { get; set; }
            public string City_text { get; set; }
            public string Area_text { get; set; }
            public int Reg_PatientID { get; set; }
            public string CNIC_Masked { get; set; }
            public string other_cnic { get; set; }
            public string DOB { get; set; }

            public decimal Card_fee { get; set; }
            public bool Monitoring { get; set; }
            public bool IsRefunded { get; set; }
            public string bank_cash { get; set; }
            public string bank_account_id { get; set; }
            public string Gender { get; set; }
            public string Martial_Status { get; set; }
            public string Prefix { get; set; }
            public string Prefix_text { get; set; }
            public string Country { get; set; }
            public string Blood_Group { get; set; }
            public string val_area { get; set; }
            public string State { get; set; }
            public string val_city { get; set; }

        }

        private static string MaskMobile(string mobile)
        {
            if (string.IsNullOrEmpty(mobile) || mobile.Length < 8) return mobile;
            return mobile.Length > 7
                ? mobile.Substring(0, 5) + new string('*', mobile.Length - 7) + mobile.Substring(mobile.Length - 2)
                : mobile;
        }

        private static string MaskCNIC(string cnic)
        {
            if (string.IsNullOrEmpty(cnic)) return "";
            if (cnic.Length >= 13)
                return "*****-" + cnic.Substring(6, 7) + "-*";
            return "*****-*******-*";
        }
        [WebMethod]
        public static string checkRightsForRefund()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var ups = (from St in db.aspnet_Users
                       where St.UserName == AppConfig.UserName
                       select St.AllowRegisterRefund).FirstOrDefault();

            // If null, return false (0)
            bool result = ups.HasValue ? ups.Value : false;

            return (new JavaScriptSerializer()).Serialize(result);
        }
        [WebMethod]
        public static string GetGender()
        {
            using (var db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Gender"
                              select new { dv.DataValue_Name, dv.DataValue_Description }).ToList();
                return new JavaScriptSerializer().Serialize(result);
            }
        }

        [WebMethod]
        public static string GetMartailStatus()
        {
            using (var db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Marital Status"
                              select new { dv.DataValue_Name, dv.DataValue_Description }).ToList();
                return new JavaScriptSerializer().Serialize(result);
            }
        }

        [WebMethod]
        public static string GetCountry()
        {
            using (var db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Country"
                              select new { dv.DataValue_Name, dv.DataValue_Description }).ToList();
                return new JavaScriptSerializer().Serialize(result);
            }
        }

        [WebMethod]
        public static string GetProvince()
        {
            using (var db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Province"
                              select new { dv.DataValue_Name, dv.DataValue_Description }).ToList();
                return new JavaScriptSerializer().Serialize(result);
            }
        }

        [WebMethod]
        public static string GetBloodBank()
        {
            using (var db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Blood Group"
                              select new { dv.DataValue_Name, dv.DataValue_Description }).ToList();
                return new JavaScriptSerializer().Serialize(result);
            }
        }

        [WebMethod]
        public static string GetPrefix()
        {
            using (var db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Prefix"
                              select new { dv.DataValue_Name, dv.DataValue_Description }).ToList();
                return new JavaScriptSerializer().Serialize(result);
            }
        }

        [WebMethod]
        public static string GetArea()
        {
            using (var db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Area"
                              select new { dv.DataValue_Name, dv.DataValue_Description }).ToList();
                return new JavaScriptSerializer().Serialize(result);
            }
        }

        [WebMethod]
        public static string GetCity()
        {
            using (var db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "City"
                              select new { dv.DataValue_Name, dv.DataValue_Description }).ToList();
                return new JavaScriptSerializer().Serialize(result);
            }
        }

        [WebMethod]
        public static string Getmr()
        {
            using (var db = new DataBaseDataContext())
            {
                int? maxPatNo = db.Reg_patients.Max(p => (int?)p.Patient_No);
                int newPatNo = (maxPatNo ?? 0) + 1;
                return newPatNo.ToString();
            }
        }


        //[WebMethod]
        [WebMethod]
        public static string SavePatientDetail(
                      string Full_Name, string RelationType, string Relation, string Gender,
                      string Mobile, string Date_Of_Birth, string CNIC, string Address,
                      string PatientID, string martail_status, string Age, string city, string area,
                      string city_val, string area_val, string Blood_Group, string State, string Country,
                       string cardfee, string OtherCnic, bool Monitoring, string AntiForgeryToken,
                       string bank_cash, string bank_account_id, string Prefix)

        {

            // Validate Session
            if (HttpContext.Current.Session["UserID"] == null)
                return "ERROR: Unauthorized. Please log in.";

            JavaScriptSerializer JSS = new JavaScriptSerializer();
            // Validate CSRF Token
            string storedToken = HttpContext.Current.Session["AntiForgeryToken"] as string;
            if (string.IsNullOrEmpty(storedToken) || !storedToken.Equals(AntiForgeryToken))
                return "ERROR: Invalid request. Possible CSRF attack.";

            // Sanitize Inputs
            Full_Name = SanitizeInput(Full_Name);
            Relation = SanitizeInput(Relation);
            Address = SanitizeInput(Address);

            // ---------------------------
            // Parse Date of Birth (Nullable)
            // ---------------------------
            DateTime? parsedDOB = null;

            if (!string.IsNullOrWhiteSpace(Date_Of_Birth))
            {
                if (!DateTime.TryParseExact(Date_Of_Birth, "dd/MM/yyyy",
                    CultureInfo.InvariantCulture, DateTimeStyles.None, out DateTime tempDOB))
                {
                    return "ERROR: Invalid Date of Birth format. Use dd/MM/yyyy.";
                }

                parsedDOB = tempDOB;
            }

            try
            {
                using (var db = new DataBaseDataContext())
                {
                    Reg_patient pat;
                    bool isNew = string.IsNullOrEmpty(PatientID) || PatientID == "0" || PatientID == "(New)";

                    // CNIC VALIDATION CHECK
                    if (isNew && !string.IsNullOrWhiteSpace(CNIC))
                    {
                        var cnicValidation = db.sys_Parms.FirstOrDefault(p => p.Name == "CNIC Validation" && p.Code == "01");
                        if (cnicValidation != null)
                        {
                            var existingPatient = db.Reg_patients.FirstOrDefault(p => p.NIC == CNIC && p.iscancel == false);
                            if (existingPatient != null)
                            {
                                return "CNIC_EXISTS";
                            }
                        }
                    }
                    // END OF CNIC VALIDATION

                    if (!isNew)
                    {
                        int patId = Convert.ToInt32(PatientID);
                        pat = db.Reg_patients.FirstOrDefault(w => w.pat_id == patId);

                        if (pat == null)
                            return "ERROR: Patient record not found.";
                        var previousRegData = new
                        {
                            PatData = new
                            {
                                pat.Patient_No,
                                pat.mr_no_sequence,
                                CreationDate = pat.Created_time ?? DateTime.MinValue,
                                pat.Full_Name,
                                pat.Father_Name,
                                pat.Gender,
                                pat.Mobile1,
                                pat.Age_years,
                                pat.NIC,
                                pat.Permanent_Address,
                                pat.Martial_Status,
                                pat.Relation_prefix,
                                pat.walkin,
                                pat.city,
                                pat.val_city,
                                pat.val_area,
                                pat.area,
                                pat.Country,
                                pat.Province,
                                pat.Card_fee,
                                pat.other_cnic,
                                DOB = pat.DOB ?? DateTime.MinValue,

                            }

                        };

                        string masterLogJson = JSS.Serialize(previousRegData.PatData);
                        Reg_Patient_Log RegLog = new Reg_Patient_Log
                        {
                            Pat_Id = pat.pat_id,
                            Updated_data = masterLogJson,
                            Loged_Time = DateTime.Now,
                            Loged_by = AppConfig.UserID
                        };

                        db.Reg_Patient_Logs.InsertOnSubmit(RegLog);




                        pat.updated_by = AppConfig.UserID;
                        pat.updated_time = DateTime.Now;                       
                    }
                    else
                    {
                        pat = new Reg_patient();

                        string PatientNumber = DBClass.getMaxEntry_No("Reg_patient", "Patient_No").ToString();
                        pat.Patient_No = Convert.ToInt32(PatientNumber);
                        pat.walkin = false;
                        pat.Created_time = DateTime.Now;
                        pat.charge_time = DateTime.Now;
                        pat.Remarks = "Card Fee Charge Via OPD Time";
                        pat.Charged_by = AppConfig.UserID;

                        if (Guid.TryParse(HttpContext.Current.Session["UserID"]?.ToString(), out Guid userId))
                            pat.Created_by = userId;
                        else
                            return "ERROR: Invalid user session.";

                        pat.iscancel = false;

                        var company = db.sys_Companies.FirstOrDefault(c => c.Company_ID == AppConfig.Company_ID);
                        string companyCode = company?.CompanyCode ?? "HOSP";
                        pat.mr_no_sequence = string.IsNullOrWhiteSpace(companyCode) ? PatientNumber : $"{companyCode}-{PatientNumber}";

                    }

                    // Assign Values
                    pat.Relation_prefix = RelationType;
                    pat.Full_Name = Full_Name;
                    pat.Father_Name = Relation;
                    pat.Gender = Gender;
                    pat.Mobile1 = Mobile;
                    pat.NIC = CNIC;
                    pat.other_cnic = OtherCnic;
                    pat.Permanent_Address = Address;
                    pat.Martial_Status = martail_status;
                    pat.city = city;
                    pat.area = area;
                    pat.val_city = city_val;
                    pat.val_area = area_val;
                    pat.State = State;
                    pat.Blood_Group = Blood_Group;
                    pat.Country = Country;
                    pat.Monitoring = Monitoring;
                    pat.bank_cash = bank_cash;
                    pat.bank_account_id = bank_account_id;
                    pat.Prefix = Prefix;
                    pat.Reprint = "1";
                    
                    //pat.charge_time = DateTime.Now;
                    //pat.Remarks = "Card Fee Charge Via OPD Time";
                    // Card Fee Safe Parse
                    decimal cardFeeValue = 0;
                    if (!string.IsNullOrWhiteSpace(cardfee))
                    {
                        if (!decimal.TryParse(cardfee.Trim(), NumberStyles.Number,
                            CultureInfo.InvariantCulture, out cardFeeValue))
                        {
                            return "ERROR: Invalid card fee. Please enter a valid number (e.g., 100.50).";
                        }
                    }
                    pat.Card_fee = cardFeeValue;

                    // Save DOB (Nullable)
                    pat.DOB = parsedDOB;

                    // ---------------------------
                    // Age Calculation (Only if DOB exists)
                    // ---------------------------
                    if (parsedDOB.HasValue)
                    {
                        DateTime dob = parsedDOB.Value.Date;
                        DateTime today = DateTime.Today;

                        int years = today.Year - dob.Year;
                        int months = today.Month - dob.Month;
                        int days = today.Day - dob.Day;

                        if (days < 0)
                        {
                            months--;
                            DateTime previousMonth = today.AddMonths(-1);
                            days += DateTime.DaysInMonth(previousMonth.Year, previousMonth.Month);
                        }

                        if (months < 0)
                        {
                            years--;
                            months += 12;
                        }

                        string formattedAge = "";

                        if (years > 0)
                        {
                            formattedAge = $"{years}Y";
                            if (months > 0) formattedAge += $" {months}M";
                            if (days > 0) formattedAge += $" {days}D";
                        }
                        else if (months > 0)
                        {
                            formattedAge = $"{months}M";
                            if (days > 0) formattedAge += $" {days}D";
                        }
                        else
                        {
                            formattedAge = $"{days}D";
                        }

                        pat.Age_years = formattedAge;
                    }
                    else
                    {
                        // If DOB not provided, use manually entered age
                        pat.Age_years = Age;
                    }

                    if (isNew)
                        db.Reg_patients.InsertOnSubmit(pat);

                    db.SubmitChanges();

                    return pat.pat_id.ToString();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"SavePatientDetail failed: {ex.Message}");
                return "ERROR: " + ex.Message;
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object ProcessRefund(string regId)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                   
                    var patient = db.Reg_patients.FirstOrDefault(p => p.pat_id == Convert.ToInt32(regId));

                    if (patient != null)
                    {
                        
                        patient.Card_fee = 0;
                        patient.IsRefunded = true; 
                        patient.Refund_by = AppConfig.UserID; 
                        patient.Refund_date = DateTime.Now; 

                        db.SubmitChanges();

                        return new { success = true, message = "Card fee refunded successfully!" };
                    }
                    else
                    {
                        return new { success = false, message = "Patient not found!" };
                    }
                }
            }
            catch (Exception ex)
            {
                return new { success = false, message = "Error: " + ex.Message };
            }
        }

        [WebMethod]
        public static string GetRegData(int reg_id)
        {
            using (var db = new DataBaseDataContext())
            {
                var patientRaw = (from rg in db.Reg_patients
                                  where rg.pat_id == reg_id
                                  select new
                                  {
                                      rg.Full_Name,
                                      rg.Father_Name,
                                      rg.Relation_prefix,
                                      rg.Gender,
                                      rg.Age_years,
                                      rg.Martial_Status,
                                      rg.mr_no_sequence,
                                      rg.NIC,
                                      rg.Permanent_Address,
                                      rg.Mobile1,
                                      rg.Blood_Group,
                                      rg.Country,
                                      rg.State,
                                      rg.val_city,
                                      rg.Card_fee,
                                      rg.val_area,
                                      rg.pat_id,
                                      rg.other_cnic,
                                       rg.Monitoring,
                                       rg.DOB,
                                       rg.IsRefunded,
                                        rg.bank_cash,
                                        rg.bank_account_id,
                                        rg.Prefix
                                   }).FirstOrDefault();

                if (patientRaw == null)
                    return new JavaScriptSerializer().Serialize((object)null);

                var patient = new SafePatientData
                {
                    Name = HttpUtility.HtmlEncode(patientRaw.Full_Name ?? ""),
                    FatherName = HttpUtility.HtmlEncode(patientRaw.Father_Name ?? ""),
                    Relation = HttpUtility.HtmlEncode(patientRaw.Relation_prefix ?? ""),
                    Gender_text = HttpUtility.HtmlEncode(db.GetDataValueName("Gender", patientRaw.Gender) ?? ""),
                    Age = patientRaw.Age_years,
                    Card_fee = patientRaw.Card_fee ?? 0,
                    MaritalStatus_text = HttpUtility.HtmlEncode(db.GetDataValueName("Marital Status", patientRaw.Martial_Status) ?? ""),
                    Mr_No = HttpUtility.HtmlEncode(patientRaw.mr_no_sequence ?? ""),
                    CNIC_Masked = (patientRaw.NIC),
                    other_cnic = (patientRaw.other_cnic),
                    Address = HttpUtility.HtmlEncode(patientRaw.Permanent_Address ?? ""),
                    Mobile = (patientRaw.Mobile1),
                    BloodGroup_text = HttpUtility.HtmlEncode(db.GetDataValueName("Blood Group", patientRaw.Blood_Group) ?? ""),
                    Country_text = HttpUtility.HtmlEncode(db.GetDataValueName("Country", patientRaw.Country) ?? ""),
                    State_text = HttpUtility.HtmlEncode(db.GetDataValueName("Province", patientRaw.State) ?? ""),
                    City_text = HttpUtility.HtmlEncode(db.GetDataValueName("City", patientRaw.val_city) ?? ""),
                    Area_text = HttpUtility.HtmlEncode(db.GetDataValueName("Area", patientRaw.val_area) ?? ""),
                    Reg_PatientID = patientRaw.pat_id,
                    DOB = patientRaw.DOB.HasValue
                          ? patientRaw.DOB.Value.ToString("dd/MM/yyyy")
                          : "",
                          Monitoring = patientRaw.Monitoring ?? false,
                          IsRefunded = patientRaw.IsRefunded ?? false,
                          bank_cash = patientRaw.bank_cash ?? "",
                          bank_account_id = patientRaw.bank_account_id ?? "",
                          Gender = patientRaw.Gender ?? "",
                          Martial_Status = patientRaw.Martial_Status ?? "",
                          Prefix = patientRaw.Prefix ?? "",
                          Prefix_text = HttpUtility.HtmlEncode(db.GetDataValueName("Prefix", patientRaw.Prefix) ?? ""),
                          Country = patientRaw.Country ?? "",
                          Blood_Group = patientRaw.Blood_Group ?? "",
                          val_area = patientRaw.val_area ?? "",
                          State = patientRaw.State ?? "",
                          val_city = patientRaw.val_city ?? ""
                };

                return new JavaScriptSerializer().Serialize(patient);
            }
        }

        [WebMethod]
        public static string CNICValidation()
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var linedisc = (from tbl in db.sys_Parms
                                    where tbl.Name == "CNIC Validation"
                                    select tbl.Code)
                              .FirstOrDefault();

                    return linedisc ?? "01";
                }
            }
            catch (Exception ex)
            {
                return "0";
            }
        }

        [WebMethod]
        public static string MonitoringCheckbox()
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var linedisc = (from tbl in db.sys_Parms
                                    where tbl.Name == "Monitoring checkbox"
                                    select tbl.Code)
                              .FirstOrDefault();

                    return linedisc ?? "01";
                }
            }
            catch (Exception ex)
            {
                return "0";
            }
        }
        [WebMethod]
        public static string GetBankAccounts()
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var accounts = (from acc in db.GL_Accounts
                                    where acc.Bank == true
                                    select new
                                    {
                                        id = acc.Account_ID,
                                        name = acc.Account_Name
                                    }).ToList();

                    return new JavaScriptSerializer().Serialize(accounts);
                }
            }
            catch (Exception ex)
            {
                // Log error if needed
                return "[]"; // return empty array on error
            }
        }
        [WebMethod]
        public static string IncrementReprintCount(string regId)
        {
            try
            {
                if (string.IsNullOrEmpty(regId))
                    return "ERROR: Invalid patient ID";

                using (var db = new DataBaseDataContext())
                {
                    var patient = db.Reg_patients.FirstOrDefault(p => p.pat_id == Convert.ToInt32(regId));

                    if (patient == null)
                        return "ERROR: Patient not found";

                    
                    int currentCount = 1;
                    if (!string.IsNullOrEmpty(patient.Reprint) && int.TryParse(patient.Reprint, out int parsed))
                    {
                        currentCount = parsed;
                    }

                    
                    currentCount++;
                    patient.Reprint = currentCount.ToString();

                    db.SubmitChanges();

                    return "SUCCESS:" + currentCount.ToString();
                }
            }
            catch (Exception ex)
            {
                return "ERROR: " + ex.Message;
            }
        }

    }
}