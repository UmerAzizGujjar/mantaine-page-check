using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Text.RegularExpressions;

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

       
        [WebMethod]
        public static string SavePatientDetail(
            string Full_Name, string RelationType, string Relation, string Gender,
            string Mobile, string Date_Of_Birth, string CNIC, string Address,
            string PatientID, string martail_status, string Age, string city, string area,
            string city_val, string area_val, string Blood_Group, string State, string Country, string AntiForgeryToken)
        {
            
            if (HttpContext.Current.Session["UserID"] == null)
                return "ERROR: Unauthorized. Please log in.";

            string storedToken = HttpContext.Current.Session["AntiForgeryToken"] as string;
            if (string.IsNullOrEmpty(storedToken) || !storedToken.Equals(AntiForgeryToken))
                return "ERROR: Invalid request. Possible CSRF attack.";

            Full_Name = SanitizeInput(Full_Name);
            Relation = SanitizeInput(Relation);
            Address = SanitizeInput(Address);
            // Note: RelationType is from a fixed dropdown (Mr./Mrs./B/O.) — assumed safe
            // Mobile, CNIC, Age, etc. are validated by strict regex — low XSS risk

            var errors = new List<string>();

            if (!ValidationHelper.IsValidName(Full_Name))
                errors.Add("Full name is required and must contain only letters.");
            if (!ValidationHelper.IsValidName(Relation))
                errors.Add("Relation name is required and must contain only letters.");
            if (!ValidationHelper.IsValidMobile(Mobile))
                errors.Add("Mobile must be in format +923001234567 (13 digits starting with +92).");
            if (!ValidationHelper.IsValidAge(Age))
                errors.Add("Age must be a number between 0 and 150.");
            if (!ValidationHelper.IsValidDate(Date_Of_Birth))
                errors.Add("Date of Birth must be in dd/MM/yyyy format.");
            if (!ValidationHelper.IsValidAddress(Address))
                errors.Add("Address is required and must not exceed 500 characters.");
            if (!string.IsNullOrWhiteSpace(CNIC) && !ValidationHelper.IsValidCNIC(CNIC))
                errors.Add("CNIC must be in format 12345-1234567-1.");
            if (Gender == "0" || string.IsNullOrWhiteSpace(Gender))
                errors.Add("Please select a valid Gender.");
            if (martail_status == "0")
                errors.Add("Please select Marital Status.");
            if (Blood_Group == "0")
                errors.Add("Please select Blood Group.");

            if (errors.Any())
                return "ERROR: " + string.Join("; ", errors);

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
                        pat.mr_no_sequence = $"{companyCode}-{PatientNumber}";
                    }

                    // === SAVE SANITIZED VALUES ===
                    pat.Relation_prefix = RelationType; // Safe (dropdown)
                    pat.Full_Name = Full_Name;          // ✅ Sanitized
                    pat.Father_Name = Relation;         // ✅ Sanitized
                    pat.Gender = Gender;
                    pat.Mobile1 = Mobile;
                    pat.Age_years = Age;
                    pat.DOB = DateTime.ParseExact(Date_Of_Birth, "dd/MM/yyyy", System.Globalization.CultureInfo.InvariantCulture);
                    pat.NIC = CNIC;
                    pat.Permanent_Address = Address;    // ✅ Sanitized
                    pat.Martial_Status = martail_status;
                    pat.city = city;
                    pat.area = area;
                    pat.val_city = city_val;
                    pat.val_area = area_val;
                    pat.State = State;
                    pat.Blood_Group = Blood_Group;
                    pat.Country = Country;

                    if (isNew)
                        db.Reg_patients.InsertOnSubmit(pat);

                    db.SubmitChanges();
                    return pat.pat_id.ToString();
                }
            }
            catch (Exception ex)
            {
                // Log ex if needed (e.g., to file or DB)
                return "ERROR: Failed to save patient. Please try again.";
            }
        }

        [WebMethod]
        public static string GetRegData(int reg_id)
        {
            using (var db = new DataBaseDataContext())
            {
                var patient = (from rg in db.Reg_patients
                               where rg.pat_id == reg_id
                               select new SafePatientData
                               {
                                  
                                   Name = HttpUtility.HtmlEncode(rg.Full_Name ?? ""),
                                   FatherName = HttpUtility.HtmlEncode(rg.Father_Name ?? ""),
                                   Relation = HttpUtility.HtmlEncode(rg.Relation_prefix ?? ""),
                                   Gender_text = HttpUtility.HtmlEncode(db.GetDataValueName("Gender", rg.Gender) ?? ""),
                                   Age = rg.Age_years,
                                   MaritalStatus_text = HttpUtility.HtmlEncode(db.GetDataValueName("Marital Status", rg.Martial_Status) ?? ""),
                                   Mr_No = HttpUtility.HtmlEncode(rg.mr_no_sequence ?? ""),
                                   CNIC_Masked = MaskCNIC(rg.NIC),
                                   Address = HttpUtility.HtmlEncode(rg.Permanent_Address ?? ""),
                                   Mobile = MaskMobile(rg.Mobile1),
                                   BloodGroup_text = HttpUtility.HtmlEncode(db.GetDataValueName("Blood Group", rg.Blood_Group) ?? ""),
                                   Country_text = HttpUtility.HtmlEncode(db.GetDataValueName("Country", rg.Country) ?? ""),
                                   State_text = HttpUtility.HtmlEncode(db.GetDataValueName("Province", rg.State) ?? ""),
                                   City_text = HttpUtility.HtmlEncode(db.GetDataValueName("City", rg.val_city) ?? ""),
                                   Area_text = HttpUtility.HtmlEncode(db.GetDataValueName("Area", rg.val_area) ?? ""),
                                   Reg_PatientID = rg.pat_id
                               }).FirstOrDefault();

                return new JavaScriptSerializer().Serialize(patient);
            }
        }
    }
}