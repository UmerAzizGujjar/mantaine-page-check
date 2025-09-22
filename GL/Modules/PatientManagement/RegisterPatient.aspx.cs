using System;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;

namespace PMS.Modules.PatientManagement
{
    public partial class RegisterPatient : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Nothing needed here for now
        }

        // ========= SAFE DTO CLASS =========
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

            // 👇 ADD THIS NEW FIELD
            public string CNIC_Masked { get; set; }
        }
        // ========= HELPER: Mask Mobile Number =========
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
            // Format: 12345-1234567-1 → *****-1234567-*
            if (cnic.Length >= 13)
                return "*****-" + cnic.Substring(6, 7) + "-*";
            return "*****-*******-*"; // fallback mask
        }
        // ========= WEB METHODS =========

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
      string city_val, string area_val, string Blood_Group, string State, string Country)
        {
            // 🔐 SECURITY CHECK — Check if user is logged in
            if (HttpContext.Current.Session["UserID"] == null)
            {
                return "ERROR: Unauthorized Access. Please login.";
            }

            // ✅ If authorized, proceed with logic
            using (var db = new DataBaseDataContext())
            {
                Reg_patient pat;
                if (!string.IsNullOrEmpty(PatientID) && PatientID != "0" && PatientID != "(New)")
                {
                    pat = db.Reg_patients.FirstOrDefault(w => w.pat_id == Convert.ToInt32(PatientID));
                    if (pat != null)
                    {
                        pat.Relation_prefix = RelationType;
                        pat.Full_Name = Full_Name;
                        pat.Father_Name = Relation;
                        pat.Gender = Gender;
                        pat.Mobile1 = Mobile;
                        pat.Age_years = Age;
                        pat.DOB = DateTime.ParseExact(Date_Of_Birth, "dd/MM/yyyy", System.Globalization.CultureInfo.InvariantCulture);
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
                        db.SubmitChanges();
                    }
                }
                else
                {
                    pat = new Reg_patient();
                    string PatientNumber = DBClass.getMaxEntry_No("Reg_patient", "Patient_No").ToString();
                    pat.Patient_No = Convert.ToInt32(PatientNumber);
                    pat.Full_Name = Full_Name;
                    pat.walkin = false;
                    pat.Father_Name = Relation;
                    pat.Relation_prefix = RelationType;
                    pat.Gender = Gender;
                    pat.Mobile1 = Mobile;
                    pat.Age_years = Age;
                    pat.DOB = DateTime.ParseExact(Date_Of_Birth, "dd/MM/yyyy", System.Globalization.CultureInfo.InvariantCulture);
                    pat.NIC = CNIC;
                    pat.Permanent_Address = Address;
                    pat.Created_time = DateTime.Now;
                    if (Guid.TryParse(HttpContext.Current.Session["UserID"]?.ToString(), out Guid userId))
                    {
                        pat.Created_by = userId;
                    }
                    else
                    {
                        // Handle error — maybe log or throw
                        return "ERROR: Invalid user ID format.";
                    } // ✅ Use session user
                    pat.iscancel = false;
                    pat.Martial_Status = martail_status;
                    pat.city = city;
                    pat.area = area;
                    pat.val_city = city_val;
                    pat.val_area = area_val;
                    pat.State = State;
                    pat.Blood_Group = Blood_Group;
                    pat.Country = Country;

                    var company = db.sys_Companies.FirstOrDefault(c => c.Company_ID == AppConfig.Company_ID);
                    string companyCode = company?.CompanyCode ?? "HOSP";
                    pat.mr_no_sequence = $"{companyCode}-{PatientNumber}";

                    db.Reg_patients.InsertOnSubmit(pat);
                    db.SubmitChanges();
                }
                return pat?.pat_id.ToString() ?? "0";
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
                                   Name = rg.Full_Name,
                                   FatherName = rg.Father_Name,
                                   Relation = rg.Relation_prefix,
                                   Gender_text = db.GetDataValueName("Gender", rg.Gender),
                                   Age = rg.Age_years,
                                   MaritalStatus_text = db.GetDataValueName("Marital Status", rg.Martial_Status),
                                   Mr_No = rg.mr_no_sequence,
                                   CNIC_Masked = MaskCNIC(rg.NIC),
                                   Address = rg.Permanent_Address,
                                   Mobile = MaskMobile(rg.Mobile1),
                                   BloodGroup_text = db.GetDataValueName("Blood Group", rg.Blood_Group),
                                   Country_text = db.GetDataValueName("Country", rg.Country),
                                   State_text = db.GetDataValueName("Province", rg.State),
                                   City_text = db.GetDataValueName("City", rg.val_city),
                                   Area_text = db.GetDataValueName("Area", rg.val_area),
                                   Reg_PatientID = rg.pat_id
                               }).FirstOrDefault();

                return new JavaScriptSerializer().Serialize(patient);
            }
        }
    }
}