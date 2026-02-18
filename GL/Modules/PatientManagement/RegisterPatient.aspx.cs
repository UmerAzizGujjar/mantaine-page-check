using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Text.RegularExpressions;
using System.Globalization;

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
            public string DOB { get; set; }

            public decimal Card_fee { get; set; }

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
    string cardfee, string AntiForgeryToken)
        {
            // Validate Session
            if (HttpContext.Current.Session["UserID"] == null)
                return "ERROR: Unauthorized. Please log in.";

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

                    if (!isNew)
                    {
                        int patId = Convert.ToInt32(PatientID);
                        pat = db.Reg_patients.FirstOrDefault(w => w.pat_id == patId);

                        if (pat == null)
                            return "ERROR: Patient record not found.";
                    }
                    else
                    {
                        pat = new Reg_patient();

                        string PatientNumber = DBClass.getMaxEntry_No("Reg_patient", "Patient_No").ToString();
                        pat.Patient_No = Convert.ToInt32(PatientNumber);
                        pat.walkin = false;
                        pat.Created_time = DateTime.Now;

                        if (Guid.TryParse(HttpContext.Current.Session["UserID"]?.ToString(), out Guid userId))
                            pat.Created_by = userId;
                        else
                            return "ERROR: Invalid user session.";

                        pat.iscancel = false;

                        var company = db.sys_Companies.FirstOrDefault(c => c.Company_ID == AppConfig.Company_ID);
                        string companyCode = company?.CompanyCode ?? "HOSP";
                        pat.mr_no_sequence = string.IsNullOrWhiteSpace(companyCode)? PatientNumber: $"{companyCode}-{PatientNumber}";

                    }

                    // Assign Values
                    pat.Relation_prefix = RelationType;
                    pat.Full_Name = Full_Name;
                    pat.Father_Name = Relation;
                    pat.Gender = Gender;
                    pat.Mobile1 = Mobile;
                    pat.NIC = CNIC;
                    pat.Permanent_Address = Address;
                    pat.Martial_Status = martail_status;
                    pat.city = city;
                    pat.area = area;
                    pat.val_city = city_val;
                    pat.val_area = area_val;
                    pat.State = State;
                    pat.Blood_Group = Blood_Group;
                    pat.Country = Country;

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
            catch (Exception)
            {
                return "ERROR: Failed to save patient. Please try again.";
            }
        }

        //public static string SavePatientDetail(
        //    string Full_Name, string RelationType, string Relation, string Gender,
        //    string Mobile, string Date_Of_Birth, string CNIC, string Address,
        //    string PatientID, string martail_status, string Age, string city, string area,
        //    string city_val, string area_val, string Blood_Group, string State, string Country,string cardfee, string AntiForgeryToken)
        //{
        //    if(Date_Of_Birth == "")
        //    {
        //        Date_Of_Birth = null;
        //    }
        //    else
        //    {
        //        if (!DateTime.TryParseExact(Date_Of_Birth, "dd/MM/yyyy",
        //     CultureInfo.InvariantCulture, DateTimeStyles.None, out DateTime parsedDOB))
        //        {
        //            return "ERROR: Invalid Date of Birth format. Use dd/MM/yyyy.";
        //        }
        //    }

        //    if (HttpContext.Current.Session["UserID"] == null)
        //        return "ERROR: Unauthorized. Please log in.";

        //    string storedToken = HttpContext.Current.Session["AntiForgeryToken"] as string;
        //    if (string.IsNullOrEmpty(storedToken) || !storedToken.Equals(AntiForgeryToken))
        //        return "ERROR: Invalid request. Possible CSRF attack.";

        //    Full_Name = SanitizeInput(Full_Name);
        //    Relation = SanitizeInput(Relation);
        //    Address = SanitizeInput(Address);
        //    // Note: RelationType is from a fixed dropdown (Mr./Mrs./B/O.) — assumed safe
        //    // Mobile, CNIC, Age, etc. are validated by strict regex — low XSS risk

        //    var errors = new List<string>();



        //    if (errors.Any())
        //        return "ERROR: " + string.Join("; ", errors);

        //    try
        //    {
        //        using (var db = new DataBaseDataContext())
        //        {
        //            Reg_patient pat;
        //            bool isNew = string.IsNullOrEmpty(PatientID) || PatientID == "0" || PatientID == "(New)";

        //            if (!isNew)
        //            {
        //                int patId = Convert.ToInt32(PatientID);
        //                pat = db.Reg_patients.FirstOrDefault(w => w.pat_id == patId);
        //                if (pat == null)
        //                    return "ERROR: Patient record not found.";
        //            }
        //            else
        //            {
        //                pat = new Reg_patient();
        //                string PatientNumber = DBClass.getMaxEntry_No("Reg_patient", "Patient_No").ToString();
        //                pat.Patient_No = Convert.ToInt32(PatientNumber);
        //                pat.walkin = false;
        //                pat.Created_time = DateTime.Now;
        //                if (Guid.TryParse(HttpContext.Current.Session["UserID"]?.ToString(), out Guid userId))
        //                    pat.Created_by = userId;
        //                else
        //                    return "ERROR: Invalid user session.";
        //                pat.iscancel = false;

        //                var company = db.sys_Companies.FirstOrDefault(c => c.Company_ID == AppConfig.Company_ID);
        //                string companyCode = company?.CompanyCode ?? "HOSP";
        //                pat.mr_no_sequence = $"{companyCode}-{PatientNumber}";
        //            }

        //            pat.Relation_prefix = RelationType; 
        //            pat.Full_Name = Full_Name;        
        //            pat.Father_Name = Relation;   
        //            pat.Gender = Gender;
        //            pat.Mobile1 = Mobile;
        //            pat.Age_years = Age;
        //            //pat.DOB = DateTime.ParseExact(Date_Of_Birth, "dd/MM/yyyy", System.Globalization.CultureInfo.InvariantCulture);
        //            pat.NIC = CNIC;
        //            pat.Permanent_Address = Address;    
        //            pat.Martial_Status = martail_status;
        //            pat.city = city;
        //            pat.area = area;
        //            pat.val_city = city_val;
        //            pat.val_area = area_val;
        //            pat.State = State;
        //            pat.Blood_Group = Blood_Group;
        //            pat.Country = Country;
        //            //pat.Card_fee = Convert.ToDecimal(cardfee);
        //            // Parse Card Fee safely
        //            decimal cardFeeValue = 0;
        //            if (!string.IsNullOrWhiteSpace(cardfee))
        //            {
        //                if (!decimal.TryParse(cardfee.Trim(), NumberStyles.Number, CultureInfo.InvariantCulture, out cardFeeValue))
        //                {
        //                    return "ERROR: Invalid card fee. Please enter a valid number (e.g., 100.50).";
        //                }
        //            }
        //            pat.Card_fee = cardFeeValue;
        //            pat.DOB = parsedDOB;
        //            DateTime dob = pat.DOB.Value.Date;
        //            DateTime today = DateTime.Today;

        //            int years = today.Year - dob.Year;
        //            int months = today.Month - dob.Month;
        //            int days = today.Day - dob.Day;

        //            if (days < 0)
        //            {
        //                months--;
        //                days += DateTime.DaysInMonth(today.Year, today.Month == 1 ? 12 : today.Month - 1);
        //            }
        //            if (months < 0)
        //            {
        //                years--;
        //                months += 12;
        //            }

        //            string formattedAge = "";
        //            if (years > 0)
        //            {
        //                formattedAge = $"{years}Y";
        //                if (months > 0) formattedAge += $" {months}M";
        //                if (days > 0) formattedAge += $" {days}D";
        //            }
        //            else if (months > 0)
        //            {
        //                formattedAge = $"{months}M";
        //                if (days > 0) formattedAge += $" {days}D";
        //            }
        //            else
        //            {
        //                formattedAge = $"{days}D";
        //            }

        //            pat.Age_years = formattedAge;

        //            if (isNew)
        //                db.Reg_patients.InsertOnSubmit(pat);

        //            db.SubmitChanges();
        //            return pat.pat_id.ToString();
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        // Log ex if needed (e.g., to file or DB)
        //        return "ERROR: Failed to save patient. Please try again.";
        //    }
        //}

        [WebMethod]
        public static string GetRegData(int reg_id)
        {
            using (var db = new DataBaseDataContext())
            {
                // Fetch raw data first — minimal projection, no formatting
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
                                      rg.DOB  // Keep as raw DateTime? or string? depends on DB schema
                                  }).FirstOrDefault();

                if (patientRaw == null)
                    return new JavaScriptSerializer().Serialize((object)null);

                // Now format in-memory (after query is executed)
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
                          : ""
                };

                return new JavaScriptSerializer().Serialize(patient);
            }
        }
    }
}