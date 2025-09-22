using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.PatientManagement
{
    public partial class OPD : System.Web.UI.Page
    {

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Generate unique anti-forgery token
                string token = Guid.NewGuid().ToString();
                Session["AntiForgeryToken"] = token;
                hfAntiForgery.Value = token; // Assign to hidden field
            }
        }
        // ========= HELPER: Mask Mobile & CNIC =========
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

        // ========= SAFE DTO CLASS FOR OPD =========
        public class SafeOPDPatientData
        {
            public string Name { get; set; }
            public string FatherName { get; set; }
            public string Relation { get; set; }
            public string Gender_text { get; set; }
            public string Age { get; set; }
            public string MaritalStatus_text { get; set; }
            public string Mr_No { get; set; }
            public string pat_no { get; set; }
            public string Address { get; set; }
            public string Mobile { get; set; }
            public string CNIC_Masked { get; set; } // 👈 Masked CNIC for display
            public string HouseNo { get; set; }
            public string Area { get; set; }
            public string StreetNo { get; set; }
            public string City { get; set; }
            public string ValArea { get; set; }
            public string ValCity { get; set; }
            public int Reg_PatientID { get; set; }
            public int opdCount { get; set; }
        }
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static Dictionary<string, bool> GetCompanyOPDPermissions()
        {
            try
            {
                int companyId = AppConfig.Company_ID; // Make sure this is accessible

                if (companyId == 0 || companyId == null)
                    return new Dictionary<string, bool>();

                using (var db = new DataBaseDataContext())
                {
                    var permissions = db.company_opd_policies
                                       .Where(p => p.company_id == companyId)
                                       .ToDictionary(
                                           p => p.field_name.Trim(),
                                           p => p.is_enabled
                                       );

                    return permissions;
                }
            }
            catch
            {
                // Return empty to avoid crashing
                return new Dictionary<string, bool>();
            }
        }
        [WebMethod]
        public static string approvepatient(string pat_id, string Pat_Category)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.SpApproveOPD(Convert.ToInt32(pat_id), Pat_Category);
            return (new JavaScriptSerializer()).Serialize(Details);
        }


        [WebMethod]
        public static string ModePresentation()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Mode Of Registration"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }
        [WebMethod]
        public static string GetClinics()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Filter Clinic"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }
        [WebMethod]
        public static string GetServices()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.INV_Items
                              where dv.Services == true
                              && dv.Active == true

                              select new
                              {
                                  DataValue_Name =dv.Item_ID,
                                  DataValue_Description = dv.Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }
        [WebMethod]
        public static string PatientType()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Patient Type"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }
        [WebMethod]
        public static string GetGender()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Gender"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }
        [WebMethod]
        public static string GetMartailStatus()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Marital Status"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }
        [WebMethod]
        public static string GetCashier()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Casher"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }


        [WebMethod]
        public static string GetUserAccount()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var userAccount = (from u in db.aspnet_Users
                                   where u.UserId == AppConfig.UserID
                                   select u.Gl_Account).FirstOrDefault();

                if (userAccount != null)
                {
                    var result = (from gl in db.GL_Accounts
                                  where gl.Account_ID == Convert.ToInt32(userAccount)
                                  select new
                                  {
                                      gl.Account_ID,
                                      gl.Account_Name
                                  }).ToList();

                    data = new JavaScriptSerializer().Serialize(result);
                }
            }
            return data;
        }


        [WebMethod]
        public static string Getpanel()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from pnl in db.Panels

                              select new
                              {
                                  DataValue_Name = pnl.Panel_ID,
                                  DataValue_Description= pnl.Company_Name
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        [WebMethod]
        public static string GetRollNo()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from pnl in db.Reg_Students
                              where pnl.Is_Active == false

                              select new
                              {
                                  DataValue_Name = pnl.Student_Id,
                                  DataValue_Description = pnl.Roll_No
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        [WebMethod]
        public static string GetGLAccounts()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from account in db.GL_Accounts
                              where account.Parent_Code == 244
                              select new
                              {
                                  DataValue_Name= account.Account_ID,
                                  DataValue_Description = account.Account_Name,
                                  account.Parent_Code,
                              }).ToList();

                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        [WebMethod]
        public static string GetEmployee()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from emp in db.HR_Employees
                              where emp.IsDoctor == false
                              select new
                              {
                                  DataValue_Name = emp.Emp_ID,
                                  DataValue_Description = emp.Emp_Name
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }
        [WebMethod]
        public static string GetDoctor()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from emp in db.HR_Employees
                              where emp.IsDoctor == true
                              select new
                              {
                                  DataValue_Name = emp.Emp_ID,
                                  DataValue_Description = emp.Emp_Name
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }
        [WebMethod]
        public static string LoadDoctor(string dpt)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatmedicineList = (from emp in db.HR_Employees

                                         where emp.Department == dpt && emp.Resign_Date == null && emp.IsDoctor == true
                                         select new { emp.Emp_ID, emp.Emp_Name }).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
            }
            return "";
        }
        [WebMethod]
        public static string LoadDepartment(string Doc)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var department = (from emp in db.HR_Employees
                                  where emp.Emp_ID == Convert.ToInt32(Doc)
                                  select new
                                  {
                                      Department = emp.Department
                                  }).FirstOrDefault();
                return (new JavaScriptSerializer()).Serialize(department);
            }
            return "";
        }
        [WebMethod]
        public static string GetFees(string Department_id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var today = DateTime.Today.Date;
                string formattedDate = DateTime.Today.ToString("yyyy-MM-dd");


                var fee = (from tbl in db.Policy_Department_Assignments
                           where tbl.Department_ID == Department_id
                                 && tbl.IsActive == true
                                 && tbl.Expiry_Date >= Convert.ToDateTime(formattedDate)
                           orderby tbl.Policy_Assign_Dep_id descending
                           select new
                           {
                               Code = tbl.Fees,
                               D_Share = tbl.Doctor_Share,
                               H_Share = tbl.Hospital_Share
                           }).FirstOrDefault();
                return (new JavaScriptSerializer()).Serialize(fee);
            }
        }



        //[WebMethod]
        //public static string loadRegistrationFees(string Doc)
        //{
        //    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

        //    int? policyId = (from emp in db.HR_Employees
        //                     where emp.Emp_ID == Convert.ToInt32(Doc) && emp.IsDoctor == true
        //                     select emp.Policy_id).FirstOrDefault();

        //    if (policyId == null)
        //        return (new JavaScriptSerializer()).Serialize(new { success = false, message = "No policy found." });

        //    DateTime today = DateTime.Now;
        //    TimeSpan currentTime = today.TimeOfDay;

        //    // Get all policy details for the policy
        //    var policyDetails = (
        //        from pd in db.Policy_Details
        //        where pd.Policy_ID == policyId
        //        orderby pd.Policy_Detail_ID descending
        //        select new { pd.Start_Time, pd.End_Time, pd.Fees,pd.Hospital_Share,pd.Doctor_Share,pd.Expiry_Date }
        //    ).ToList();

        //    if (policyDetails.Count == 0)
        //        return (new JavaScriptSerializer()).Serialize(new { success = false, message = "No policy details found." });

        //    var matchingPolicy = policyDetails.FirstOrDefault(pd =>
        //        (pd.Start_Time <= pd.End_Time && 
        //         currentTime >= pd.Start_Time && currentTime <= pd.End_Time)
        //        ||
        //        (pd.Start_Time > pd.End_Time &&
        //         (currentTime >= pd.Start_Time || currentTime <= pd.End_Time)
        //         && today <= pd.Expiry_Date
        //         )
        //    );

        //    if (matchingPolicy == null)
        //    {
        //        return (new JavaScriptSerializer()).Serialize(new
        //        {
        //            success = false,
        //            message = "You cannot register at this time."
        //        });
        //    }
        //    return (new JavaScriptSerializer()).Serialize(new
        //    {
        //        success = true,
        //        fee = matchingPolicy.Fees,
        //        Hospital_Share = matchingPolicy.Hospital_Share,
        //        Doctor_Share = matchingPolicy.Doctor_Share
        //    });
        //}
        [WebMethod]
        public static string loadRegistrationFees(string Doc)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            int? policyId = (from emp in db.HR_Employees
                             where emp.Emp_ID == Convert.ToInt32(Doc) && emp.IsDoctor == true
                             select emp.Policy_id).FirstOrDefault();

            if (policyId == null)
                return (new JavaScriptSerializer()).Serialize(new { success = false, message = "No policy found." });

            DateTime today = DateTime.Now;
            TimeSpan currentTime = today.TimeOfDay;

            // Get all policy details for the policy
            var policyDetails = (
                from pd in db.Policy_Details
                where pd.Policy_ID == policyId
                orderby pd.Policy_Detail_ID descending
                select new
                {
                    pd.Start_Time,
                    pd.End_Time,
                    pd.Fees,
                    pd.Hospital_Share,
                    pd.Doctor_Share,
                    pd.Expiry_Date,
                    pd.IsTime
                }
            ).ToList();

            if (policyDetails.Count == 0)
                return (new JavaScriptSerializer()).Serialize(new { success = false, message = "No policy details found." });

            // Matching policy logic
            var matchingPolicy = policyDetails.FirstOrDefault(pd =>
                pd.IsTime == true
                ? // ✅ Check BOTH time and expiry date
                    (
                        (
                            pd.Start_Time <= pd.End_Time &&
                            currentTime >= pd.Start_Time && currentTime <= pd.End_Time
                        )
                        ||
                        (
                            pd.Start_Time > pd.End_Time &&
                            (currentTime >= pd.Start_Time || currentTime <= pd.End_Time)
                        )
                    ) && today <= pd.Expiry_Date
                : // ❌ Check ONLY expiry date
                    today <= pd.Expiry_Date
            );

            if (matchingPolicy == null)
            {
                return (new JavaScriptSerializer()).Serialize(new
                {
                    success = false,
                    message = "You cannot register at this time or policy has expired."
                });
            }

            return (new JavaScriptSerializer()).Serialize(new
            {
                success = true,
                fee = matchingPolicy.Fees,
                Hospital_Share = matchingPolicy.Hospital_Share,
                Doctor_Share = matchingPolicy.Doctor_Share
            });
        }


        [WebMethod]
        public static string LoadEmplData(string employeeid)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var doc = (from emp in db.HR_Employees
                       where emp.Emp_ID == Convert.ToInt32(employeeid)
                       select new
                       {
                           Name = emp.Emp_Name,
                           Dependent = emp.Dependent
                       }).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(doc);
        }
        [WebMethod]
        public static string GetCount()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var totpatients = db.Patients.Where(p => p.Created_Time.Value.Year == DateTime.Now.Year && p.Created_Time.Value.Month == DateTime.Now.Month && p.Created_Time.Value.Day == DateTime.Now.Day).Count();

            return (new JavaScriptSerializer()).Serialize(totpatients);
        }

        [WebMethod]
        public static string GetCountry()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Country"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        [WebMethod]
        public static string GetProvince()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Province"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }
        [WebMethod]
        public static string LoadPanelInfo(string panelid)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var doc = (from emp in db.Panels
                       where emp.Panel_ID == Convert.ToInt32(panelid)
                       select new
                       {
                           Fees = emp.Panel_Rate
                       }).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(doc);
        }
        [WebMethod]
        public static string Getmr()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            Reg_patient pat = null;
            int? maxPatNo = db.Reg_patients.Max(p => (int?)p.Patient_No);
            int newPatNo = (maxPatNo.HasValue ? maxPatNo.Value : 0) + 1;

            return newPatNo.ToString();
        }
        [WebMethod]
        public static string SavePatientDetail(string Full_Name, string RelationType, string Relation, string Gender, string Mobile, string Date_Of_Birth, string CNIC, string Address, string PatientID, string martail_status, string Age, string houseno, string stno, string city, string area, string city_val, string area_val, string Province, string Country)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            Reg_patient pat = null;
            if (!string.IsNullOrEmpty(PatientID) && PatientID != "0" && PatientID != "(New)")
            {
                pat = db.Reg_patients.Where(w => w.pat_id == Convert.ToInt32(PatientID)).FirstOrDefault();

                if (pat != null)
                {
                    pat.Relation_prefix = RelationType;
                    pat.Full_Name = Full_Name;

                    pat.Father_Name = Relation;
                    pat.Gender = Gender;
                    pat.Mobile1 = Mobile;
                    pat.Age_years = Age;

                    pat.DOB = Convert.ToDateTime(Date_Of_Birth);
                    pat.NIC = CNIC;
                    pat.Permanent_Address = Address;
                    pat.Martial_Status = martail_status;
                    pat.Permanent_Address = houseno;
                    pat.stno_mno = stno;
                    pat.city = city;
                    pat.area = area;

                    pat.val_city = city_val;
                    pat.val_area = area_val;
                    pat.Country = Country;
                    pat.Province = Province;


                    db.SubmitChanges();
                }
            }
            else
            {
                pat = new Reg_patient();
                string PatientNumber = (DBClass.getMaxEntry_No("Reg_patient", "Patient_No")).ToString();
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
                pat.Created_by = AppConfig.UserID;
                pat.iscancel = false;
                pat.Martial_Status = martail_status;
                pat.Permanent_Address = houseno;

                pat.stno_mno = stno;
                pat.city = city;
                pat.area = area;
                pat.val_city = city_val;
                pat.val_area = area_val;
                var companyID = AppConfig.Company_ID;
                var company = (from dt in db.sys_Companies
                               where dt.Company_ID == companyID
                               select dt).FirstOrDefault();
                string companyCode = company.CompanyCode;
                string MR_Sequence = companyCode + "-" + PatientNumber;
                pat.mr_no_sequence = MR_Sequence;
                pat.Country = Country;
                pat.Province = Province;


                db.Reg_patients.InsertOnSubmit(pat);
                db.SubmitChanges();
            }
            return pat.pat_id.ToString();
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static string SaveOpdData(MasterList data, string opdid)
        {
            if (HttpContext.Current.Session["UserID"] == null)
            {
                return "ERROR: Unauthorized Access. Please login.";
            }
            string storedToken = HttpContext.Current.Session["AntiForgeryToken"] as string;
            if (string.IsNullOrEmpty(storedToken) || !storedToken.Equals(data.AntiForgeryToken))
            {
                return "ERROR: Invalid request. CSRF attack detected.";
            }
            DataBaseDataContext db = new DataBaseDataContext();
            Patient pat = null;

            if (!string.IsNullOrEmpty(opdid) && opdid != "0" && opdid != "(New)")
            {
                pat = db.Patients.Where(w => w.Patient_ID == Convert.ToInt32(opdid)).FirstOrDefault();

                if (pat != null)
                {
                    pat.Reg_PatId = data.regid;
                    pat.Full_Name = data.Full_Name;
                    pat.Age_years = data.Age;
                    pat.Mode_Of_Registration = data.modeof_presentation;
                    pat.Patient_Type = data.pat_category;
                    pat.Father_Name = data.Father_name;
                    pat.Age_years = data.Age;
                    pat.Gender = data.Gender;
                    pat.NIC = data.NIC;
                    pat.Mobile1 = data.MobileNo;
                    pat.Permanent_Address = data.Address;
                    pat.Marital_Status = data.Martial_Status;
                    pat.Patient_Main_Category = data.Department;
                    pat.Doctor_ID = data.doctor;
                    pat.filter_clinic = data.FilterClinic;
                    pat.Service_id = data.Services;
                    pat.mr_no_sequence = data.patient_no;
                    pat.Actual_amount = data.Actual_Fees;
                    pat.Updated_By = AppConfig.UserID;
                    pat.Updated_Time = DateTime.Now;
                    pat.Employee_Name = data.EmployeeName;
                    pat.Emp_Department = data.EmployeeDept;
                    db.SubmitChanges();
                }
            }
            else
            {
                pat = new Patient();
                pat.Opd_No = DBClass.getMaxEntry_No("Patients", "Opd_No");
                pat.Reg_PatId = data.regid;
                if (data.appid == "")
                {

                }
                else
                {
                    pat.appointment_id = Convert.ToInt32(data.appid);
                }
                //var opdfee = (from tbl in db.sys_Parms
                //              where tbl.Name == "OPD Fee"
                //              select tbl.Code).FirstOrDefault(); from system params 

                var opdfee = data.Fees;
                pat.Full_Name = data.Full_Name;
                pat.Student_Name = data.StudentName;
                pat.Age_years = data.Age;
                pat.Mode_Of_Registration = data.modeof_presentation;
                pat.Patient_Type = data.pat_category;
                pat.Father_Name = data.Father_name;
                pat.Age_years = data.Age;
                pat.Gender = data.Gender;
                pat.NIC = data.NIC;
                pat.Mobile1 = data.MobileNo;
                pat.filter_clinic = data.FilterClinic;
                pat.Service_id = data.Services;
                pat.Permanent_Address = data.Address;
                pat.Marital_Status = data.Martial_Status;
                pat.Patient_Main_Category = data.Department;
                
                pat.Doctor_ID = data.doctor;
                pat.mr_no_sequence = data.patient_no;
                pat.Patient_No = Convert.ToInt32(data.pat_no);
                pat.Refference_No = data.reffer_no;
                pat.Employee_Name = data.EmployeeName;
                pat.Emp_Department = data.EmployeeDept;
                pat.Patient_Main_Category = data.hdnDepartment;
                pat.Actual_amount = data.Actual_Fees;


                if (data.FreeCheck == true)
                {
                    pat.Receipt_Amount = 0;
                    pat.discount_amt = data.Actual_Fees;
                }
                else
                {
                    if (data.pat_category == "01" && data.discount == "")
                    {
                        pat.Receipt_Amount = Convert.ToDecimal(opdfee);
                    }
                    else
                    {
                        pat.Receipt_Amount = data.Fees;
                    }
                    if (data.discount == "")
                    {
                        pat.discount_amt = 0;

                    }
                    else
                    {
                        pat.discount_amt = Convert.ToInt32(data.discount);
                    }
                }


                if (data.doctor == "0" || data.doctor == "")
                {
                    pat.Doc_Token = 0;

                    pat.tokenNo = db.Patients.Where(p => p.Created_Time.Value.Year == DateTime.Now.Year
                                && p.Created_Time.Value.Month == DateTime.Now.Month
                                && p.Created_Time.Value.Day == DateTime.Now.Day
                                && p.Patient_Main_Category == data.pat_category).Count() + 1;
                }
                else
                {
                    pat.tokenNo = 0;
                    pat.Doc_Token = db.Patients.Where(p => p.Created_Time.Value.Year == DateTime.Now.Year
                                  && p.Created_Time.Value.Month == DateTime.Now.Month
                                  && p.Created_Time.Value.Day == DateTime.Now.Day
                                  && p.Doctor_ID == data.doctor).Count() + 1;
                }

                //pat.Employee_Name = data.employee;
                pat.PanelCompany = Convert.ToInt32(data.panel);
                pat.employee_ID = Convert.ToString(data.employee_id);
                pat.Designation = data.designation ?? 0; // 👈 Safe — if null, use 0
                pat.Dependent = data.dependent;
                pat.RollNo = Convert.ToInt32(data.rollno);
                pat.Class = Convert.ToInt32(data.Class);
                pat.Section = Convert.ToInt32(data.section);
                pat.Casher = data.Cashier;
                pat.AccountID = Convert.ToInt32(data.accountid);
                pat.Card_Issued = data.IssueCard;
                pat.free_check = data.FreeCheck;
                if (Guid.TryParse(HttpContext.Current.Session["UserID"]?.ToString(), out Guid userId))
                {
                    pat.Created_By = userId;
                }
                else
                {
                    // Handle error — maybe log or throw
                    return "ERROR: Invalid user ID format.";
                } // ✅ Use session user
                pat.Created_Time = DateTime.Now;
                pat.Entry_Date = DateTime.Now;
                pat.Company_ID = AppConfig.Company_ID;
                pat.Book_ID = AppConfig.Book_ID;
                pat.isCancel = false;
                if (data.appid == "")
                {

                }
                else
                {
                    DBClass.executeNonQueryWithoutBegin("update Appointment_Form set Status='Visited' where Appointment_ID=" + data.appid);
                }


                decimal opdfees = data.Fees; // This is already discounted final fee (receipt amount)

                // Percentages from DB
                decimal hospital_share = data.Hosp_share;   // e.g. 60
                decimal doctor_share = data.Doc_Share;      // e.g. 40

                // No need to calculate discount again, just use opdfees directly
                decimal Net_Amount = opdfees;

                // Save discount % just for reference
                //decimal disc = 0;
                //if (!string.IsNullOrEmpty(data.discount))
                //{
                //    disc = Convert.ToDecimal(data.discount);
                //}
                //pat.discount_amt = disc;

                // Calculate shares
                decimal Hospital_Amount = Math.Round((Net_Amount * hospital_share) / 100, 2);
                decimal Doctor_Amount = Math.Round((Net_Amount * doctor_share) / 100, 2);

                // Assign
                pat.Hospital_share = Hospital_Amount;
                pat.doc_share = Doctor_Amount.ToString("F2");





                if (data.pat_category == "02")
                {
                    pat.Share_Transfered = true;
                }
                else if (data.pat_category == "01")
                {
                    pat.Share_Transfered = false;
                }

                db.Patients.InsertOnSubmit(pat);
                db.SubmitChanges();
            }
            return pat.Patient_ID.ToString();
        }

        [WebMethod]
        public static string GetArea()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Area"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }
        [WebMethod]
        public static string GetCity()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "City"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        [WebMethod]
        public static string GetDepartment()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Patient Main Category"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }
        [WebMethod]
        public static string checlkeditRights()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var ups = (from St in db.aspnet_Users
                       where St.UserName == AppConfig.UserName
                       select St.AllowPatientEdit).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(ups);
        }
        [WebMethod]
        public static string GetBasicInfo(int reg_id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var patient = (from rg in db.Reg_patients
                               where rg.pat_id == reg_id
                               select new SafeOPDPatientData
                               {
                                   Name = rg.Full_Name,
                                   FatherName = rg.Father_Name,
                                   Relation = rg.Relation_prefix,
                                   Gender_text = db.GetDataValueName("Gender", rg.Gender),
                                   Age = rg.Age_years,
                                   MaritalStatus_text = db.GetDataValueName("Marital Status", rg.Martial_Status),
                                   Mr_No = rg.mr_no_sequence,
                                   pat_no = Convert.ToString(rg.Patient_No),
                                   Address = rg.Permanent_Address,
                                   Mobile = rg.Mobile1,
                                   CNIC_Masked = rg.NIC,
                                   HouseNo = rg.House_No,
                                   Area = rg.area,
                                   StreetNo = rg.stno_mno,
                                   City = rg.city,
                                   ValArea = rg.val_area,
                                   ValCity = rg.val_city,
                                   Reg_PatientID = rg.pat_id,
                                   opdCount = db.Patients.Count(p => p.Reg_PatId == reg_id)
                               }).FirstOrDefault();

                if (patient == null)
                {
                    return new JavaScriptSerializer().Serialize(null);
                }

                var patientRecord = db.Reg_patients.FirstOrDefault(x => x.pat_id == reg_id);
                if (patientRecord != null && patientRecord.DOB.HasValue)
                {
                    DateTime dob = patientRecord.DOB.Value;
                    DateTime today = DateTime.Today;
                    int calculatedAge = today.Year - dob.Year;
                    if (dob > today.AddYears(-calculatedAge))
                        calculatedAge--;
                    string currentAgeStr = calculatedAge.ToString();
                    if (patientRecord.Age_years != currentAgeStr)
                    {
                        patientRecord.Age_years = currentAgeStr; 
                        db.SubmitChanges(); 
                    }
                }

                int numberOfDaysLatest = 0;
                int numberOfDaysSecondLatest = 0;

                var opd_time = (from pt in db.Patients
                                where pt.Reg_PatId == patient.Reg_PatientID
                                orderby pt.Patient_ID descending
                                select pt.Created_Time).FirstOrDefault();

                if (opd_time != null)
                {
                    DateTime currentTimeRounded = DateTime.Now.Date;
                    DateTime createdTimeRounded = opd_time.Value.Date;
                    TimeSpan daysSinceCreation = currentTimeRounded - createdTimeRounded;
                    numberOfDaysLatest = (int)daysSinceCreation.TotalDays;
                }

                var opd_time2 = (from pt in db.Patients
                                 where pt.Reg_PatId == patient.Reg_PatientID
                                 orderby pt.Patient_ID descending
                                 select pt.Created_Time)
                                 .Skip(1)
                                 .FirstOrDefault();

                if (opd_time2 != null)
                {
                    DateTime currentTimeRounded = DateTime.Now.Date;
                    DateTime createdTimeRounded = opd_time2.Value.Date;
                    TimeSpan daysSinceCreation = currentTimeRounded - createdTimeRounded;
                    numberOfDaysSecondLatest = (int)daysSinceCreation.TotalDays;
                }
                else
                {
                    numberOfDaysSecondLatest = 0;
                }

                var query = (from rg in db.Reg_patients
                             where rg.pat_id == reg_id
                             select new
                             {
                                 Name = rg.Full_Name,
                                 FatherName = rg.Father_Name,
                                 Relation = rg.Relation_prefix,
                                 Gender = rg.Gender,
                                 DOB = rg.DOB,
                                 Age = rg.Age_years, // 👈 Now this will be UPDATED age!
                                 MaritalStatus = rg.Martial_Status,
                                 MaritalStatus_text = db.GetDataValueName("Marital Status", rg.Martial_Status),
                                 Gender_text = db.GetDataValueName("Gender", rg.Gender),
                                 Mr_No = rg.mr_no_sequence,
                                 pat_no = rg.Patient_No,
                                 Address = rg.Permanent_Address,
                                 Mobile = rg.Mobile1,
                                 CNIC_Masked = rg.NIC,
                                 HouseNo = rg.House_No,
                                 Area = rg.area,
                                 StreetNo = rg.stno_mno,
                                 City = rg.city,
                                 ValArea = rg.val_area,
                                 ValCity = rg.val_city,
                                 Reg_PatientID = rg.pat_id,
                                 opdCount = db.Patients.Count(count => count.Reg_PatId == reg_id),
                                 DaysSinceLatestVisit = numberOfDaysLatest,
                                 DaysSinceSecondLatestVisit = numberOfDaysSecondLatest
                             }).FirstOrDefault();

                return (new JavaScriptSerializer()).Serialize(query);
            }
        }



        [WebMethod]
        public static string GetBasicInfo_Apt(int reg_id, int apt_Id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var patient = (from rg in db.Reg_patients
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
                                   rg.Patient_No,
                                   rg.House_No,
                                   rg.stno_mno,
                                   rg.area,
                                   rg.city,
                                   rg.Permanent_Address,
                                   rg.Mobile1,
                                   rg.NIC,
                                   rg.val_area,
                                   rg.val_city,
                                   rg.pat_id
                               }).FirstOrDefault();

                if (patient == null)
                    return new JavaScriptSerializer().Serialize(null);

                string pat_type_Val = "02";
                string pat_type_text = db.GetDataValueName("Patient Type", pat_type_Val);
                string maritalStatus_text = db.GetDataValueName("Marital Status", patient.Martial_Status);
                string gender_text = db.GetDataValueName("Gender", patient.Gender);

                var doctorId = db.Appointment_Forms
                                 .Where(a => a.Appointment_ID == apt_Id)
                                 .Select(a => a.Consultant_ID)
                                 .FirstOrDefault();

                string DoctorName = db.HR_Employees
                                 .Where(a => a.Emp_ID == Convert.ToInt32(doctorId))
                                 .Select(a => a.Emp_Name)
                                 .FirstOrDefault();

                var departmentid = db.Appointment_Forms
                                     .Where(a => a.Appointment_ID == apt_Id)
                                     .Select(a => a.Sub_Department)
                                     .FirstOrDefault();

                string department_Text = db.GetDataValueName("Patient Main Category", departmentid);

             
            int numberOfDaysLatest = 0;
            int numberOfDaysSecondLatest = 0;
            var opd_time = (from pt in db.Patients
                            where pt.Reg_PatId == patient.pat_id
                            orderby pt.Patient_ID descending
                            select pt.Created_Time).FirstOrDefault();

            if (opd_time != null)
            {
                DateTime currentTimeRounded = DateTime.Now.Date;
                DateTime createdTimeRounded = opd_time.Value.Date;
                TimeSpan daysSinceCreation = currentTimeRounded - createdTimeRounded;
                numberOfDaysLatest = (int)daysSinceCreation.TotalDays;
            }
            var opd_time2 = (from pt in db.Patients
                             where pt.Reg_PatId == patient.pat_id
                             orderby pt.Patient_ID descending
                             select pt.Created_Time)
                             .Skip(1)
                             .FirstOrDefault();

            if (opd_time2 != null)
            {
                DateTime currentTimeRounded = DateTime.Now.Date;
                DateTime createdTimeRounded = opd_time2.Value.Date;

                TimeSpan daysSinceCreation = currentTimeRounded - createdTimeRounded;
                numberOfDaysSecondLatest = (int)daysSinceCreation.TotalDays;
            }
            else
            {
                numberOfDaysSecondLatest = 0;
            }


                var result = new
                {
                    Name = patient.Full_Name,
                    FatherName = patient.Father_Name,
                    Relation = patient.Relation_prefix,
                    Gender_text = gender_text,
                    Age = patient.Age_years,
                    MaritalStatus_text = maritalStatus_text,
                    Mr_No = patient.mr_no_sequence,
                    pat_no = patient.Patient_No,
                    Address = $"H# {patient.House_No} {patient.stno_mno} {patient.area} {patient.city}",
                    PermanentAdrress = patient.Permanent_Address,
                    Mobile = patient.Mobile1,
                    CNIC_Masked = patient.NIC, // 👈 Masked!
                    HouseNo = patient.House_No,
                    Area = patient.area,
                    StreetNo = patient.stno_mno,
                    City = patient.city,
                    ValArea = patient.val_area,
                    ValCity = patient.val_city,
                    Reg_PatientID = patient.pat_id,
                    doctorId = doctorId,
                    DoctorName = DoctorName,
                    departmentid = departmentid,
                    department_Text = department_Text,
                    pat_type_Val = pat_type_Val,
                    pat_type_text = pat_type_text,
                    DaysSinceLatestVisit = numberOfDaysLatest,
                    DaysSinceSecondLatestVisit = numberOfDaysSecondLatest
                };

                return new JavaScriptSerializer().Serialize(result);
            }
        }


        [WebMethod]
        public static string GetPatientDetail(int OPDID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var patient = db.Patients.FirstOrDefault(p => p.Patient_ID == OPDID);
                if (patient == null) return "null";

                var result = new
                {
                    mr_no_sequence = patient.mr_no_sequence,
                    Opd_No = patient.Opd_No,
                    Name = patient.Full_Name,
                    StudentName = patient.Student_Name,
                    Father_Name = patient.Father_Name,
                    Mode_Of_Registration = patient.Mode_Of_Registration,
                    Patient_Type = patient.Patient_Type,
                    Age_years = patient.Age_years,
                    Gender_text = db.GetDataValueName("Gender", patient.Gender),
                    Mobile1 = MaskMobile(patient.Mobile1),
                    CNIC_Masked = MaskCNIC(patient.NIC),
                    MaritalStatus_text = db.GetDataValueName("Marital Status", patient.Marital_Status),
                    Permanent_Address = patient.Permanent_Address,
                    Receipt_Amount = patient.Receipt_Amount,
                    Actual_amount = patient.Actual_amount,
                    Category_text = db.GetDataValueName("Patient Main Category", patient.Patient_Main_Category),
                    Type_text = db.GetDataValueName("Patient Type", patient.Patient_Type),

                    // ✅ FIXED: Safe check for Doctor_ID
                    Doc_text = patient.Doctor_ID == null || !int.TryParse(patient.Doctor_ID.ToString(), out _) ? "" : db.HR_Employees.Where(e => e.Emp_ID == Convert.ToInt32(patient.Doctor_ID)).Select(e => e.Emp_Name).FirstOrDefault(),

                    PanelCompany_text = db.Panels.Where(p => p.Panel_ID == patient.PanelCompany).Select(p => p.Company_Name).FirstOrDefault(),

                    // ✅ FIXED: Safe check for employee_ID
                    employee_text = patient.employee_ID == null || !int.TryParse(patient.employee_ID.ToString(), out _) ? "" : db.HR_Employees.Where(e => e.Emp_ID == Convert.ToInt32(patient.employee_ID)).Select(e => e.Emp_Name).FirstOrDefault(),

                    Refference_No = patient.Refference_No,
                    Employee_Name = patient.Employee_Name,
                    discount_amt = patient.discount_amt,
                    Dependent = patient.Dependent,
                    RollNo = patient.RollNo,
                    Class = patient.Class,
                    Section = patient.Section,
                    Casher = patient.Casher,
                    Card_Issued = patient.Card_Issued,
                    free_check = patient.free_check,
                    opdid = patient.Patient_ID,
                    status = patient.Status,
                    account_id = patient.AccountID,
                    Clinic_text = db.GetDataValueName("Filter Clinic", patient.filter_clinic),
                    Service_text = db.INV_Items.Where(i => i.Item_ID == patient.Service_id).Select(i => i.Description).FirstOrDefault()
                };

                return new JavaScriptSerializer().Serialize(result);
            }
        }
        [WebMethod]
        public static List<PatientsResult> SearchPatients(string SearchString)
        {

            string SearchSql = "";

            if (SearchString == "")

                SearchSql = "SELECT top 10 pat_id,isnull(mr_no_sequence,'')Patient_No,isnull(Full_Name,'')Full_Name,isnull(NIC,'')NIC,isnull(Mobile1,'') ContactNo,isnull(Father_Name,'')Father_Name FROM reg_patient where(1=1) and Patient_No<>0 and Patient_No is not null and isnull(isCancel,0)!=1 order by pat_id desc";
            else
                SearchSql = "SELECT pat_id,isnull(mr_no_sequence,'')Patient_No,isnull(Full_Name,'')Full_Name,isnull(NIC,'')NIC,isnull(Mobile1,'') ContactNo,isnull(Father_Name,'')Father_Name FROM reg_patient where(1=1) and Patient_No<>0 and Patient_No is not null and isnull(isCancel,0)!=1 and (LTRIM(RTRIM(patient_no)) like '%" + SearchString.Trim() + "%' or  LTRIM(RTRIM(full_name)) like '%" + SearchString.Trim() + "%' or LTRIM(RTRIM(mobile1))  like '%" + SearchString.Trim() + "%' or LTRIM(RTRIM(nic))  like '%" + SearchString.Trim() + "%') order by pat_id desc";

            DataTable dt = DBClass.getDataTable(SearchSql);

            List<PatientsResult> list = new List<PatientsResult>();

            foreach (DataRow dr in dt.Rows)
            {
                PatientsResult rslt = new PatientsResult()
                {
                    Reg_Patient_ID = dr[0] == DBNull.Value ? "" : (string)dr[0].ToString(),
                    Patient_No = dr[1] == DBNull.Value ? "" : (string)dr[1].ToString(),
                    Full_Name = dr[2] == DBNull.Value ? "" : (string)dr[2],
                    NIC = dr[3] == DBNull.Value ? "" : (string)dr[3],
                    Mobile1 = dr[4] == DBNull.Value ? "" : (string)dr[4],
                    Father_Name = dr[5] == DBNull.Value ? "" : (string)dr[5],
                };
                list.Add(rslt);

                int number;
                string value = "Hello";
                bool result = Int32.TryParse(value, out number);

            }
            return list;
        }
        public class PatientsResult
        {
            public string Full_Name;
            public string NIC;
            public string Reg_Patient_ID;
            public string Age_years;
            public string Patient_No;
            public string Mobile1;
            public string Father_Name;

        }
        [WebMethod]
        public static List<Search_App> SearchAppointment(string SearchString)
        {

            string SearchSql = "";

            if (SearchString == "")

                SearchSql = "SELECT Appointment_ID, isnull(Appointment_No,'')Appointment_No,isnull(Patient_Name,'')Patient_Name,isnull(Consultant_ID,'')Consultant_ID,isnull(Age,'')Age,isnull(Phone,'') Phone, (select top 1 emp_name from HR_Employees where Emp_ID=Consultant_ID ) Emp_name,rg.pat_id FROM Appointment_Form app inner join Reg_patient rg on rg.pat_id = app.Reg_id  where(1=1) and Appointment_No<>0 and Appointment_No is not null and Status = 'Booked' order by Appointment_ID desc";
            else
                SearchSql = "SELECT Appointment_ID,isnull(Appointment_No,'')Appointment_No,isnull(Patient_Name,'')Patient_Name,isnull(Consultant_ID,'')Consultant_ID,isnull(Age,'') Age,isnull(Phone,'')Phone, (select top 1 emp_name from HR_Employees where Emp_ID=Consultant_ID ) Emp_name,Reg_id FROM Appointment_Form where(1=1) and Appointment_No<>0 and Appointment_No is not null and Status = 'Booked' and (LTRIM(RTRIM(Appointment_No)) like '%" + SearchString.Trim() + "%' or  LTRIM(RTRIM(Patient_Name)) like '%" + SearchString.Trim() + "%' or LTRIM(RTRIM(Consultant_ID))  like '%" + SearchString.Trim() + "%' or LTRIM(RTRIM(Age))  like '%" + SearchString.Trim() + "%' or LTRIM(RTRIM(Phone)) like '%" + SearchString.Trim() + "%' or Consultant_ID = isnull((select top 1 Emp_ID from HR_Employees where Emp_Name like '%" + SearchString.Trim() + "%'),'0'))";




            DataTable dt = DBClass.getDataTable(SearchSql);

            List<Search_App> list = new List<Search_App>();

            foreach (DataRow dr in dt.Rows)
            {
                Search_App rsslt = new Search_App()
                {
                    Appointment_ID = dr[0] == DBNull.Value ? "" : (string)dr[0].ToString(),
                    Appointment_No = dr[1] == DBNull.Value ? "" : (string)dr[1].ToString(),
                    Patient_Name = dr[2] == DBNull.Value ? "" : (string)dr[2],
                    Consultant_ID = dr[3] == DBNull.Value ? "" : (string)dr[3],
                    Age = dr[4] == DBNull.Value ? "" : (string)dr[4],
                    Phone = dr[5] == DBNull.Value ? "" : (string)dr[5],
                    Emp_name = dr[6] == DBNull.Value ? "" : (string)dr[6],
                    pat_id = dr[7] == DBNull.Value ? "" : (string)dr[7].ToString(),

                };
                list.Add(rsslt);

                int number;
                string value = "Hello";
                bool result = Int32.TryParse(value, out number);

            }
            return list;
        }
        [WebMethod]
        public static List<EmergencyResult> SearchEmergencyPatients(string SearchString)
        {
            string SearchSql = "";

            if (string.IsNullOrEmpty(SearchString))
            {
                SearchSql = @"SELECT TOP 10  
                            r.pat_id, 
                            ISNULL(r.mr_no_sequence,'') AS Patient_No,
                            ISNULL(r.Full_Name,'') AS Full_Name,
                            ISNULL(r.NIC,'') AS NIC,
                            ISNULL(r.Mobile1,'') AS ContactNo,
                            ISNULL(r.Father_Name,'') AS Father_Name,
                            e.Patient_ID, 
                            ISNULL(e.Refer_To_OPD,0) AS Refer_To_OPD
                          FROM Reg_Patient r 
                          INNER JOIN Emergency_Patient e ON r.pat_id = e.Patient_ID
                          WHERE r.Patient_No <> 0  
                            AND r.Patient_No IS NOT NULL 
                            AND ISNULL(r.isCancel,0) != 1   
                            AND ISNULL(e.Refer_To_OPD,0) = 1 
                          ORDER BY r.pat_id DESC";
            }
            else
            {
                SearchSql = @"SELECT 
                            r.pat_id,
                            ISNULL(r.mr_no_sequence,'') AS Patient_No,
                            ISNULL(r.Full_Name,'') AS Full_Name,
                            ISNULL(r.NIC,'') AS NIC, 
                            ISNULL(r.Mobile1,'') AS ContactNo,
                            ISNULL(r.Father_Name,'') AS Father_Name,
                            e.Patient_ID,
                            ISNULL(e.Refer_To_OPD,0) AS Refer_To_OPD
                          FROM Reg_Patient r 
                          INNER JOIN Emergency_Patient e ON r.pat_id = e.Patient_ID
                          WHERE r.Patient_No <> 0 
                            AND r.Patient_No IS NOT NULL 
                            AND ISNULL(r.isCancel,0) != 1
                            AND ISNULL(e.Refer_To_OPD,0) = 1 
                            AND (LTRIM(RTRIM(r.patient_no)) LIKE '%" + SearchString.Trim() + @"%' 
                                 OR LTRIM(RTRIM(r.full_name)) LIKE '%" + SearchString.Trim() + @"%' 
                                 OR LTRIM(RTRIM(r.mobile1)) LIKE '%" + SearchString.Trim() + @"%' 
                                 OR LTRIM(RTRIM(r.nic)) LIKE '%" + SearchString.Trim() + @"%')
                          ORDER BY r.pat_id DESC";
            }

            DataTable dt = DBClass.getDataTable(SearchSql);

            List<EmergencyResult> list = new List<EmergencyResult>();

            foreach (DataRow dr in dt.Rows)
            {
                EmergencyResult rslt = new EmergencyResult()
                {
                    Reg_Patient_ID = dr["pat_id"] == DBNull.Value ? "" : dr["pat_id"].ToString(),
                    Patient_No = dr["Patient_No"] == DBNull.Value ? "" : dr["Patient_No"].ToString(),
                    Full_Name = dr["Full_Name"] == DBNull.Value ? "" : dr["Full_Name"].ToString(),
                    NIC = dr["NIC"] == DBNull.Value ? "" : dr["NIC"].ToString(),
                    Mobile1 = dr["ContactNo"] == DBNull.Value ? "" : dr["ContactNo"].ToString(),
                    Father_Name = dr["Father_Name"] == DBNull.Value ? "" : dr["Father_Name"].ToString(),
                    Emergency_ID = dr["Patient_ID"] == DBNull.Value ? "" : dr["Patient_ID"].ToString(),
                    Refer_To_OPD = dr["Refer_To_OPD"] == DBNull.Value ? "0" : dr["Refer_To_OPD"].ToString()
                };
                list.Add(rslt);
            }

            return list;
        }

        public class EmergencyResult
        {
            public string Reg_Patient_ID { get; set; }
            public string Patient_No { get; set; }
            public string Full_Name { get; set; }
            public string NIC { get; set; }
            public string Mobile1 { get; set; }
            public string Father_Name { get; set; }
            public string Emergency_ID { get; set; }
            public string Refer_To_OPD { get; set; }
        }
    
    [WebMethod]
        public static bool CardFee(string PatID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                var sysParm = (from tbl in db.sys_Parms
                               where tbl.Name == "Patient Card No"
                               select tbl.Code).FirstOrDefault();
                var bio_id = (from itm in db.Patients
                              where (itm.Patient_ID == int.Parse(PatID))
                              select itm.Patient_ID).FirstOrDefault();
                var cardissue = (from itm in db.Patients
                                 where (itm.Patient_ID == int.Parse(PatID))
                                 select itm.Card_Issued).FirstOrDefault();
                var receiptamount = (from itm in db.Patients
                                     where (itm.Patient_ID == int.Parse(PatID))
                                     select itm.Card_Receipt_Amount).FirstOrDefault();
                var reprint = (from itm in db.Patients
                               where (itm.Patient_ID == int.Parse(PatID))
                               select itm.cardReprint).FirstOrDefault();

                var totalRec = (Convert.ToInt32(sysParm) + Convert.ToInt32(receiptamount));
                var rep = Convert.ToInt32(reprint) + 1;
                if (bio_id != 0)
                {
                    if (cardissue == true)
                    {
                        DBClass.exectueQuery("update Patients set Card_Receipt_Amount = " + totalRec + " where Patient_ID =" + PatID, tranObj, con);
                        DBClass.exectueQuery("UPDATE Patients SET cardReprint = " + rep + " where Patient_ID =" + PatID, tranObj, con);
                        tranObj.Commit();
                    }
                    else
                    {
                        DBClass.exectueQuery("update Patients set Card_Receipt_Amount = " + sysParm + " where Patient_ID =" + PatID, tranObj, con);
                        DBClass.exectueQuery("UPDATE Patients SET Card_Issued = 1 where Patient_ID =" + PatID, tranObj, con);
                        DBClass.exectueQuery("UPDATE Patients SET cardReprint = 1 where Patient_ID =" + PatID, tranObj, con);
                        tranObj.Commit();
                    }
                }
                else
                {
                    tranObj.Rollback();
                    return false;
                }
            }
#pragma warning disable CS0168 // The variable 'ex' is declared but never used
            catch (Exception ex)
#pragma warning restore CS0168 // The variable 'ex' is declared but never used
            {
                if (tranObj != null)
                    tranObj.Rollback();
                return false;
            }
            return true;
        }
        public class Search_App
        {
            public string Patient_Name;
            public string Appointment_Code;
            public string Appointment_ID;
            public string Age;
            public string Phone;
            public string Appointment_No;
            public string Consultant_ID;
            public string Emp_name;
            public string Status;
            public string pat_id;

        }

        public class MasterList
        {
            public int regid { get; set; }
            public int? employee_id { get; set; }           // 👈 Nullable
            public string appid { get; set; }
            public string Full_Name { get; set; }
            public string StudentName { get; set; }
            public string patient_no { get; set; }
            public string pat_no { get; set; }
            public string modeof_presentation { get; set; }
            public string pat_category { get; set; }
            public string Father_name { get; set; }
            public string Age { get; set; }
            public string Gender { get; set; }
            public string NIC { get; set; }
            public string MobileNo { get; set; }
            public string Martial_Status { get; set; }
            public string Address { get; set; }
            public string doctor { get; set; }
            public string Department { get; set; }
            public string hdnDepartment { get; set; }
            public string employee { get; set; }
            public string panel { get; set; }
            public string reffer_no { get; set; }
            public string discount { get; set; }
            public string employee_name { get; set; }
            public int? designation { get; set; } // 👈 Change to nullable int
            public string dependent { get; set; }           // 👈 Already string (nullable)
            public string rollno { get; set; }
            public string Class { get; set; }
            public string section { get; set; }
            public string Cashier { get; set; }
            public int Services { get; set; }
            public decimal Doc_Share { get; set; }
            public decimal Hosp_share { get; set; }
            public string accountid { get; set; }
            public string FilterClinic { get; set; }
            public string EmployeeName { get; set; }
            public string EmployeeDept { get; set; }
            public string AntiForgeryToken { get; set; }
            public bool? IssueCard { get; set; }    // 👈 Added "?"
            public bool? FreeCheck { get; set; }    // 👈 Added "?"
            public int Fees { get; set; }
            public int Actual_Fees { get; set; }
        }
    }
}
