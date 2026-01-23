using PMS.Modules.Dashboards;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web;
using static PMS.WebForm9;

namespace PMS.Modules.PatientManagement
{
    public partial class OPD : System.Web.UI.Page
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
        public static string GetVisitDays(int regPatId)
        {
            using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var visits = (from p in db.Patients
                              where p.Reg_PatId == regPatId
                              orderby p.Patient_ID descending
                              select p.Created_Time)
                             .Take(2)
                             .ToList();

                var result = new
                {
                    recentVisitDays = visits.Count > 0 && visits[0].HasValue
                        ? (DateTime.Now.Date - visits[0].Value.Date).Days
                        : 0,

                    recentVisitDate = visits.Count > 0 && visits[0].HasValue
                        ? visits[0].Value.ToString("dd-MMM-yyyy")
                        : "",

                    previousVisitDays = visits.Count > 1 && visits[1].HasValue
                        ? (DateTime.Now.Date - visits[1].Value.Date).Days
                        : 0,

                    previousVisitDate = visits.Count > 1 && visits[1].HasValue
                        ? visits[1].Value.ToString("dd-MMM-yyyy")
                        : ""
                };

                return new JavaScriptSerializer().Serialize(result);
            }
        }



        private static string SanitizeInput(string input)
        {
            if (string.IsNullOrWhiteSpace(input))
                return input;

            return Regex.Replace(input.Trim(), @"<[^>]*>", "", RegexOptions.IgnoreCase);
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

        public static class ValidationHelper
        {
            public static bool IsValidMobile(string mobile)
            {
                return !string.IsNullOrWhiteSpace(mobile) &&
                       Regex.IsMatch(mobile, @"^\+92[0-9]{10}$");
            }
            public static bool IsValidCNIC(string cnic)
            {
                return string.IsNullOrWhiteSpace(cnic) || 
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
            public static bool IsValidPositiveDecimal(decimal value)
            {
                return value >= 0;
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
            public string CNIC_Masked { get; set; }
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
                int companyId = AppConfig.Company_ID;
                if (companyId == 0)
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
                return new Dictionary<string, bool>();
            }
        }
        [WebMethod]
        public static string ApproveRegpatient(string Pat_Id)
        {
            var UserId = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_ApprovePatientCardFee(Convert.ToInt32(Pat_Id), UserId);
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string approvepatient(string pat_id, string Pat_Category)
        {
            var user_id = AppConfig.UserID;
            var company_name = AppConfig.Company_Name;

            using (var db = new DataBaseDataContext()) // 👈 best practice: dispose context
            {
                object Details;

                //if (company_name == "As-Siraat Serving Humanity")
                //{
                //    // Call client-specific SP
                //    Details = db.SpApprove_OPD_AsSiraat(Convert.ToInt32(pat_id), Pat_Category, user_id);
                //}
                //else
                //{
                    // Default for other clients (e.g., Noor Hospital, KDC Lab, etc.)
                    Details = db.SpApprove_OPD(Convert.ToInt32(pat_id), Pat_Category, user_id);
               // }

                return new JavaScriptSerializer().Serialize(Details);
            }
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
        public static string loadSpecialFees(string Doc)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var data = (from emp in db.HR_Employees
                        where emp.Emp_ID == Convert.ToInt32(Doc) && emp.IsDoctor == true
                        select new
                        {
                            Consultant_Charges = emp.Consultant_Charges,
                            Doctor_Amount = emp.Doctor_Amount,
                            Hospital_Amount = emp.Hospital_Amount
                        }).FirstOrDefault();

            return new JavaScriptSerializer().Serialize(data);
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
        public static string GetCasher()
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
        //[WebMethod]
        //public static string GetCasher()
        //{
        //    using (DataBaseDataContext db = new DataBaseDataContext())
        //    {
        //        var result = (from u in db.aspnet_Users
        //                      where u.UserId == AppConfig.UserID
        //                      && u.cashier != null
        //                      select new
        //                      {
        //                          Cashier_ID = u.cashier,
        //                          Cashier_Name = db.GetDataValueName("Casher", u.cashier)
        //                      }).ToList();

        //        return new JavaScriptSerializer().Serialize(result);
        //    }
        //}

        [WebMethod]
        public static string GetDoctorBlockInfo(string Doc)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

                var employee = (from emp in db.HR_Employees
                                where emp.Emp_ID == Convert.ToInt32(Doc) && emp.IsDoctor == true
                                select new
                                {
                                    emp.Block_category,
                                    emp.st_day,
                                    emp.end_day,
                                    emp.Timings_In,
                                    emp.Timings_Out,
                                    emp.Patient_Type,
                                    emp.Off_Days_Names
                                }).FirstOrDefault();

                if (employee == null)
                {
                    return new JavaScriptSerializer().Serialize(new { error = "Doctor not found" });
                }

                string timingsIn = employee.Timings_In?.ToString(@"hh\:mm") ?? "";
                string timingsOut = employee.Timings_Out?.ToString(@"hh\:mm") ?? "";

                var result = new
                {
                    Block_category = employee.Block_category != null &&
                    (employee.Block_category == true ||
                     employee.Block_category.ToString() == "1"),
                    st_day = employee.st_day?.ToString("yyyy-MM-dd"),
                    end_day = employee.end_day?.ToString("yyyy-MM-dd"),
                    Timings_In = employee.Timings_In?.ToString(@"hh\:mm"),
                    Timings_Out = employee.Timings_Out?.ToString(@"hh\:mm"),
                    Patient_Type = employee.Patient_Type?.ToString(),
                    offDays = employee.Off_Days_Names?.ToString()
                };

                return new JavaScriptSerializer().Serialize(result);
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { error = ex.Message });
            }
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
                                  DataValue_Name = dv.Item_ID,
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
        public static List<PatientsResultRFf> SearchPatients_Rff(string SearchString)
        {
            string SearchSql = "";

            if (string.IsNullOrWhiteSpace(SearchString))
            {
                SearchSql = @"
            SELECT TOP 10 
                rg.pat_id,
                ISNULL(rg.mr_no_sequence, '') AS Patient_No,
                ISNULL(rg.Full_Name, '') AS Full_Name,
                ISNULL(p.NIC, '') AS NIC,
                [dbo].[GetDoctorName](op.reffer_doc) AS ContactNo,
                ISNULL(rg.Father_Name, '') AS Father_Name,
                ISNULL(op.Out_Patient_ID, '') AS OPDID 
            FROM reg_patient rg 
            INNER JOIN patients p ON rg.pat_id = p.Reg_PatId 
            INNER JOIN Out_Patient op ON p.Patient_ID = op.Patient_ID 
            WHERE op.reffer_doc != 0 
              AND ISNULL(p.isCancel, 0) != 1

            ORDER BY op.Out_Patient_ID DESC";
            }
            else
            {
                string safeSearch = SearchString.Trim().Replace("'", "''");

                SearchSql = $@"
            SELECT TOP 10 
                rg.pat_id,
                ISNULL(rg.mr_no_sequence, '') AS Patient_No,
                ISNULL(rg.Full_Name, '') AS Full_Name,
                ISNULL(p.NIC, '') AS NIC,
               [dbo].[GetDoctorName](op.reffer_doc) AS ContactNo,
                ISNULL(rg.Father_Name, '') AS Father_Name,
                ISNULL(op.Out_Patient_ID, '') AS OPDID 
            FROM reg_patient rg 
            INNER JOIN patients p ON rg.pat_id = p.Reg_PatId 
            INNER JOIN Out_Patient op ON p.Patient_ID = op.Patient_ID 
            WHERE rg.Patient_No <> 0 
              AND rg.Patient_No IS NOT NULL 
              AND ISNULL(rg.isCancel, 0) != 1 
              AND (
                  LTRIM(RTRIM(rg.patient_no)) LIKE '%{safeSearch}%' 
                  OR LTRIM(RTRIM(rg.full_name)) LIKE '%{safeSearch}%' 
                  OR LTRIM(RTRIM(rg.mobile1)) LIKE '%{safeSearch}%' 
                  OR LTRIM(RTRIM(rg.nic)) LIKE '%{safeSearch}%'
              )
            ORDER BY op.Out_Patient_ID DESC";
            }

            DataTable dt = DBClass.getDataTable(SearchSql);
            List<PatientsResultRFf> rff_list = new List<PatientsResultRFf>();

            foreach (DataRow dr in dt.Rows)
            {
                rff_list.Add(new PatientsResultRFf
                {
                    Reg_Patient_ID = dr["pat_id"]?.ToString() ?? "",
                    Patient_No = dr["Patient_No"]?.ToString() ?? "",
                    Full_Name = dr["Full_Name"]?.ToString() ?? "",
                    NIC = dr["NIC"]?.ToString() ?? "",
                    Mobile1 = dr["ContactNo"]?.ToString() ?? "", 
                    Father_Name = dr["Father_Name"]?.ToString() ?? "",
                    OPDID = dr["OPDID"]?.ToString() ?? ""
                });
            }
            return rff_list;
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
        public static string Getpanel()
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from pnl in db.Panels
                              select new
                              {
                                  DataValue_Name = pnl.Panel_ID,
                                  DataValue_Description = pnl.Company_Name
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
                                  DataValue_Name = account.Account_ID,
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
        public static string LoadAllDoctor()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatmedicineList = (from emp in db.HR_Employees
                                         where emp.Resign_Date == null && emp.IsDoctor == true
                                         select new { emp.Emp_ID, emp.Emp_Name }).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
            }
            return "";
        }
        //[WebMethod]
        //public static string LoadDepartmentByDoc(string doc)
        //{
        //    using (DataBaseDataContext db = new DataBaseDataContext())
        //    {
        //        var inPatmedicineList = (from emp in db.HR_Employees
        //                                 where emp.Emp_ID == Convert.ToInt32(doc)
        //                                 && emp.Resign_Date == null && emp.IsDoctor == true
        //                                 select new {
        //                                     emp.Department, 
        //                                     Department_text = db.GetDataValueName("Patient Main Category" , emp.Department)
        //                                 }).ToList();
        //        return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
        //    }
        //    return "";
        //}

        [WebMethod]
        public static string LoadDepartment(string Doc)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var department = (from emp in db.HR_Employees
                                  where emp.Emp_ID == Convert.ToInt32(Doc)
                                  select new
                                  {
                                      emp.Department,
                                      Department_text = db.GetDataValueName("Patient Main Category", emp.Department)
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
                               Receipt_fee = (tbl.Fees ?? 0) - (tbl.Discount_Amount ?? 0),
                                Discount_Percentage = tbl.Discount_Percentage,
                               D_Share = tbl.Doctor_Share,
                               H_Share = tbl.Hospital_Share
                           }).FirstOrDefault();
                return (new JavaScriptSerializer()).Serialize(fee);
            }
        }

        [WebMethod]
        public static string loadRegistrationFees(string Doc)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            int docId;
            if (!int.TryParse(Doc, out docId))
            {
                return new JavaScriptSerializer().Serialize(new { success = false, message = "Invalid doctor ID." });
            }

            int? policyId = (from emp in db.HR_Employees
                             where emp.Emp_ID == docId && emp.IsDoctor == true
                             select emp.Policy_id).FirstOrDefault();

            if (policyId == null)
                return new JavaScriptSerializer().Serialize(new { success = false, message = "No policy found for this doctor." });

            DateTime now = DateTime.Now;
            DayOfWeek dow = now.DayOfWeek;

            // 📅 Convert to 1=Mon ... 7=Sun
            int currentDayNum;
            switch (dow)
            {
                case DayOfWeek.Monday: currentDayNum = 1; break;
                case DayOfWeek.Tuesday: currentDayNum = 2; break;
                case DayOfWeek.Wednesday: currentDayNum = 3; break;
                case DayOfWeek.Thursday: currentDayNum = 4; break;
                case DayOfWeek.Friday: currentDayNum = 5; break;
                case DayOfWeek.Saturday: currentDayNum = 6; break;
                case DayOfWeek.Sunday: currentDayNum = 7; break;
                default: currentDayNum = 0; break;
            }

            TimeSpan currentTime = now.TimeOfDay;

            // 🔽 Fetch all policy details (run query once)
            var policies = (
                from pd in db.Policy_Details
                where pd.Policy_ID == policyId
                orderby pd.Policy_Detail_ID descending
                select new
                {
                    pd.Policy_Detail_ID,
                    pd.Fees,
                    pd.Hospital_Share,
                    pd.Doctor_Share,
                    pd.Expiry_Date,
                    pd.IsTime,
                    pd.Start_Time,
                    pd.End_Time,
                    pd.Discount_Percentage,
                    pd.Day_Check,
                    pd.St_Day,
                    pd.En_Day
                }
            ).ToList();

            if (policies.Count == 0)
                return new JavaScriptSerializer().Serialize(new { success = false, message = "No policy details configured." });

            // 🔁 Helper: robust day name → number
            int ParseDay(string dayStr)
            {
                if (string.IsNullOrWhiteSpace(dayStr)) return -1;
                string s = dayStr.Trim().ToLower();
                if (s.StartsWith("mon")) return 1;
                if (s.StartsWith("tue")) return 2;
                if (s.StartsWith("wed")) return 3;
                if (s.StartsWith("thu")) return 4;
                if (s.StartsWith("fri")) return 5;
                if (s.StartsWith("sat")) return 6;
                if (s.StartsWith("sun")) return 7;
                return -1;
            }

            // 🔍 Find FIRST matching policy
            var matched = policies.FirstOrDefault(pd =>
            {
                // 1️⃣ Expiry check
                if (!pd.Expiry_Date.HasValue || now.Date > pd.Expiry_Date.Value.Date)
                    return false;

                // 2️⃣ Day check (only if Day_Check is logically true)
                bool dayCheckEnabled = false;
                if (pd.Day_Check != null)
                {
                    string v = pd.Day_Check.ToString().Trim();
                    dayCheckEnabled = v == "1" || v.Equals("true", StringComparison.OrdinalIgnoreCase);
                }

                bool dayOk = true;
                if (dayCheckEnabled)
                {
                    int st = ParseDay(pd.St_Day);
                    int en = ParseDay(pd.En_Day);
                    if (st == -1 || en == -1) return false;

                    if (st <= en)
                        dayOk = currentDayNum >= st && currentDayNum <= en;
                    else
                        dayOk = currentDayNum >= st || currentDayNum <= en;

                    if (!dayOk) return false;
                }

                // 3️⃣ Time check (only if IsTime is true AND times provided)
                bool timeOk = true;
                if (pd.IsTime == true && pd.Start_Time.HasValue && pd.End_Time.HasValue)
                {
                    TimeSpan start = pd.Start_Time.Value;
                    TimeSpan end = pd.End_Time.Value;

                    if (start <= end)
                    {
                        // Normal range (e.g., 10:00–23:00)
                        timeOk = currentTime >= start && currentTime <= end;
                    }
                    else
                    {
                        // Overnight (e.g., 22:00–06:00)
                        timeOk = currentTime >= start || currentTime <= end;
                    }

                    if (!timeOk) return false;
                }

                return true;
            });

            // ✅ If no policy matches → show clear error
            if (matched == null)
            {
                // Optional: Log for admin/debug
                // System.Diagnostics.Debug.WriteLine($"No policy matched for doctor {docId} at {now:yyyy-MM-dd HH:mm}");

                return new JavaScriptSerializer().Serialize(new
                {
                    success = false,
                    message = "Doctor registration policy is not defined for the current day and time."
                });
            }

            // ✅ Return matched policy
            return new JavaScriptSerializer().Serialize(new
            {
                success = true,
                fee = matched.Fees ?? 0m,
                discount_percentage = matched.Discount_Percentage ?? 0,
                Hospital_Share = matched.Hospital_Share ?? 0m,
                Doctor_Share = matched.Doctor_Share ?? 0m
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
        public static string SavePatientDetail(
            string Full_Name, string RelationType, string Relation, string Gender,
            string Mobile, string Date_Of_Birth, string CNIC, string Address,
            string PatientID, string martail_status, string Age,
           string stno, string city, string area,
            string city_val, string area_val, string Province, string Country, string cardfee)
        {
            Full_Name = SanitizeInput(Full_Name);
            Relation = SanitizeInput(Relation);
         
          
            stno = SanitizeInput(stno);
            city = SanitizeInput(city);
            area = SanitizeInput(area);

            DataBaseDataContext db = new DataBaseDataContext();
            Reg_patient pat = null;
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
                    pat.DOB = Convert.ToDateTime(Date_Of_Birth);
                    pat.NIC = CNIC;
                    pat.Permanent_Address = Address;
                    pat.Martial_Status = martail_status;
                   
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
              
                pat.stno_mno = stno;
                pat.city = city;
                pat.area = area;
                pat.val_city = city_val;
                pat.val_area = area_val;
                pat.Created_time = DateTime.Now;
                pat.Created_by = AppConfig.UserID;
                pat.iscancel = false;
                pat.Martial_Status = martail_status;
                pat.Country = Country;
                pat.Card_fee = Convert.ToDecimal(cardfee);
                pat.Province = Province;

                var company = db.sys_Companies.FirstOrDefault(c => c.Company_ID == AppConfig.Company_ID);
                string companyCode = company?.CompanyCode ?? "HOSP";
                pat.mr_no_sequence = $"{companyCode}-{PatientNumber}";
                pat.Card_fee = Convert.ToDecimal(
                         (from tbl in db.sys_Parms
                          where tbl.Name == "OPD Fee"
                          select tbl.Code).FirstOrDefault());

                db.Reg_patients.InsertOnSubmit(pat);
                db.SubmitChanges();
            }
            return pat?.pat_id.ToString() ?? "0";
        }
        [WebMethod]
        public static string Getcardvalidation()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dept = (from data in db.sys_Parms
                        where data.Name == "Card Fee"
                        select
                          data.Code
                        ).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(dept);
        }
        [WebMethod]
        public static string ChargeCardFee(int reg_id)
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var patient = db.Reg_patients.FirstOrDefault(p => p.pat_id == reg_id);

                    if (patient != null)
                    {
                        patient.Card_fee = 100;
                        db.SubmitChanges(); // LINQ-to-SQL uses SubmitChanges()
                        return new JavaScriptSerializer().Serialize(new { success = true });
                    }
                    else
                    {
                        return new JavaScriptSerializer().Serialize(new { success = false, msg = "Patient not found." });
                    }
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { success = false, msg = ex.Message });
            }
        }
        [WebMethod]
        public static string checkcardfee(int reg_id)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var cardFee = (from data in db.Reg_patients
                                   where data.pat_id == reg_id
                                   select data.Card_fee).FirstOrDefault();

                    // Handle null or zero
                    bool hasCardFee = cardFee.HasValue && cardFee.Value > 0;

                    var result = new
                    {
                        hasCardFee = hasCardFee,
                        cardFee = cardFee ?? 0, // return 0 if null
                        message = !hasCardFee ? "Patient has no card fee." : "Card fee already charged."
                    };

                    return new JavaScriptSerializer().Serialize(result);
                }
            }
            catch (Exception ex)
            {
                var errorResult = new
                {
                    hasCardFee = false,
                    cardFee = 0,
                    message = "Error: " + ex.Message
                };
                return new JavaScriptSerializer().Serialize(errorResult);
            }
        }
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static string SaveOpdData(MasterList data, string opdid)
        {
            if (HttpContext.Current.Session["UserID"] == null)
                return "ERROR: Unauthorized Access. Please login.";

            string storedToken = HttpContext.Current.Session["AntiForgeryToken"] as string;
            if (string.IsNullOrEmpty(storedToken) || !storedToken.Equals(data?.AntiForgeryToken))
                return "ERROR: Invalid request. Possible CSRF attack.";

            if (data != null)
            {
                data.Full_Name = SanitizeInput(data.Full_Name);
                data.StudentName = SanitizeInput(data.StudentName);
                data.Father_name = SanitizeInput(data.Father_name);
                data.Address = SanitizeInput(data.Address);
                data.EmployeeName = SanitizeInput(data.EmployeeName);
                data.EmployeeDept = SanitizeInput(data.EmployeeDept);
                data.reffer_no = SanitizeInput(data.reffer_no);
                data.dependent = SanitizeInput(data.dependent);
            }

            var errors = new List<string>();
            if (string.IsNullOrWhiteSpace(data?.patient_no) || data.patient_no == "0")
                errors.Add("Patient MR No is required.");
            if (string.IsNullOrWhiteSpace(data?.pat_category) || data.pat_category == "0")
                errors.Add("Patient category is required.");

            var category = data?.pat_category;
            if (category == "01" || category == "02" || category == "04" || category == "05")
            {
                if (string.IsNullOrWhiteSpace(data?.Department) || data.Department == "0")
                    errors.Add("Department is required for this patient category.");
            }
            if (category == "02" || category == "03")
            {
                if (string.IsNullOrWhiteSpace(data?.doctor) || data.doctor == "0")
                    errors.Add("Doctor is required for this patient category.");
            }
            if (category == "03")
            {
                if (string.IsNullOrWhiteSpace(data?.panel) || data.panel == "0")
                    errors.Add("Panel company is required for this patient category.");
            }
            if (string.IsNullOrWhiteSpace(data?.accountid) || data.accountid == "0")
                errors.Add("Cash In Hand account is required.");
            if (!ValidationHelper.IsValidPositiveDecimal(data?.Fees ?? 0))
                errors.Add("Fee amount must be zero or positive.");
            if (!ValidationHelper.IsValidPositiveDecimal(data?.Actual_Fees ?? 0))
                errors.Add("Actual fee must be zero or positive.");
            if (!string.IsNullOrWhiteSpace(data?.discount))
            {
                if (!decimal.TryParse(data.discount, out decimal discountValue) || discountValue < 0)
                {
                    errors.Add("Discount must be a valid non-negative number.");
                }
            }

            if (errors.Any())
                return "ERROR: " + string.Join("; ", errors);

            try
            {
                using (var db = new DataBaseDataContext())
                {
                    Patient pat = null;
                    bool isNew = string.IsNullOrEmpty(opdid) || opdid == "0" || opdid == "(New)";

                    if (!isNew)
                    {
                        int opdId = Convert.ToInt32(opdid);
                        pat = db.Patients.FirstOrDefault(w => w.Patient_ID == opdId);
                        if (pat == null)
                            return "ERROR: OPD record not found.";
                    }
                    else
                    {
                        pat = new Patient();
                        pat.Opd_No = DBClass.getMaxEntry_No("Patients", "Opd_No");
                        pat.Reg_PatId = data.regid;
                        if (!string.IsNullOrEmpty(data.appid))
                            pat.appointment_id = Convert.ToInt32(data.appid);

                        if (string.IsNullOrWhiteSpace(data.doctor) || data.doctor == "0")
                        {
                            // Non-doctor registration → department-based token
                            pat.Doc_Token = 0;
                            pat.tokenNo = db.Patients.Count(p =>
                                p.Created_Time.HasValue &&
                                p.Created_Time.Value.Date == DateTime.Now.Date &&
                                p.Patient_Main_Category == data.Department) + 1;
                        }
                        else
                        {
                            pat.tokenNo = 0;

                            // 🔹 Get CURRENT active slot (e.g., 10:00–12:00 and now is 11:30)
                            var currentSlot = GetCurrentActivePolicySlot(data.doctor);

                            // 🔹 If no slot is active now, get NEXT slot today (e.g., next is 13:00–15:00)
                            if (currentSlot == null)
                            {
                                currentSlot = GetNextPolicySlotForToday(data.doctor);
                            }

                            // 🔹 Count tokens ONLY in this slot (reset per slot + per day)
                            if (currentSlot != null)
                            {
                                DateTime now = DateTime.Now;
                                DateTime today = now.Date;
                                int count;

                                if (currentSlot.Start_Time <= currentSlot.End_Time)
                                {
                                    // Normal slot: 10:00–12:00
                                    count = db.Patients.Count(p =>
                                        p.Doctor_ID == data.doctor &&
                                        p.Created_Time.HasValue &&
                                        p.Created_Time.Value.Date == today &&
                                        p.Created_Time.Value.TimeOfDay >= currentSlot.Start_Time &&
                                        p.Created_Time.Value.TimeOfDay < currentSlot.End_Time
                                    );
                                }
                                else
                                {
                                    // Overnight slot: 22:00–02:00
                                    DateTime slotStartDate = today;
                                    if (now.TimeOfDay < currentSlot.End_Time)
                                        slotStartDate = today.AddDays(-1);

                                    count = db.Patients.Count(p =>
                                        p.Doctor_ID == data.doctor &&
                                        p.Created_Time.HasValue &&
                                        (
                                            (p.Created_Time.Value.Date == slotStartDate &&
                                             p.Created_Time.Value.TimeOfDay >= currentSlot.Start_Time) ||
                                            (p.Created_Time.Value.Date == slotStartDate.AddDays(1) &&
                                             p.Created_Time.Value.TimeOfDay < currentSlot.End_Time)
                                        )
                                    );
                                }

                                pat.Doc_Token = count + 1;
                            }
                            else
                            {
                                // Fallback: no slot defined → daily count (but token resets per day)
                                pat.Doc_Token = db.Patients.Count(p =>
                                    p.Doctor_ID == data.doctor &&
                                    p.Created_Time.HasValue &&
                                    p.Created_Time.Value.Date == DateTime.Now.Date) + 1;
                            }
                        }

                        pat.Created_By = Guid.TryParse(HttpContext.Current.Session["UserID"]?.ToString(), out Guid userId) ? userId : Guid.Empty;
                        pat.Created_Time = DateTime.Now;
                        pat.Entry_Date = DateTime.Now;
                        pat.Company_ID = AppConfig.Company_ID;
                        pat.Book_ID = AppConfig.Book_ID;
                        pat.isCancel = false;
                        pat.AppointmentType = data.hdnAppointmentType;
                        pat.Status = "Created";
                        pat.Is_billed = false;

                        if (!string.IsNullOrEmpty(data.appid))
                        {
                            if(data.hdnAppointmentType == "Derma")
                            {
                                DBClass.executeNonQueryWithoutBegin("UPDATE Derma_Appointment SET Status='Visited' WHERE Derma_Appointment_Id=" + data.appid);
                                
                            }
                            else if(data.hdnAppointmentType == "OPD")
                            {
                                DBClass.executeNonQueryWithoutBegin("UPDATE Appointment_Form SET Status='Visited' WHERE Appointment_ID=" + data.appid);
                            }
                        }
                           
                    }

                    // 🔹 Fill patient data
                    pat.Full_Name = data.Full_Name;
                    pat.Student_Name = data.StudentName;
                    pat.Age_years = data.Age;
                    pat.Mode_Of_Registration = data.modeof_presentation;
                    pat.Patient_Type = data.pat_category;
                    pat.Father_Name = data.Father_name;
                    pat.Gender = data.Gender;
                    pat.NIC = data.NIC;
                    pat.Mobile1 = data.MobileNo;
                    pat.Permanent_Address = data.Address;
                    pat.Marital_Status = data.Martial_Status;
                    pat.Patient_Main_Category = data.hdnDepartment ?? data.Department;
                    pat.Doctor_ID = data.doctor;
                    pat.filter_clinic = data.FilterClinic;
                    pat.Service_id = data.Services;
                    pat.mr_no_sequence = data.patient_no;
                    pat.Patient_No = Convert.ToInt32(data.pat_no);
                    pat.Refference_No = data.reffer_no;
                    pat.Employee_Name = data.EmployeeName;
                    pat.Emp_Department = data.EmployeeDept;
                    pat.Actual_amount = data.Actual_Fees;

                    if (data.FreeCheck == true)
                    {
                        pat.Receipt_Amount = 0;
                        pat.discount_amt = 100;
                    }
                    else
                    {
                        pat.Receipt_Amount = data.Fees;
                        pat.discount_amt = string.IsNullOrEmpty(data.discount) ? 0 : Convert.ToInt32(data.discount);
                    }

                    pat.PanelCompany = string.IsNullOrEmpty(data.panel) ? 0 : Convert.ToInt32(data.panel);
                    pat.employee_ID = data.employee_id?.ToString();
                    pat.Dependent = data.dependent;
                    pat.RollNo = string.IsNullOrEmpty(data.rollno) ? 0 : Convert.ToInt32(data.rollno);
                    pat.Class = string.IsNullOrEmpty(data.Class) ? 0 : Convert.ToInt32(data.Class);
                    pat.Section = string.IsNullOrEmpty(data.section) ? 0 : Convert.ToInt32(data.section);
                    pat.Casher = data.Cashier;
                    pat.AccountID = string.IsNullOrEmpty(data.accountid) ? 0 : Convert.ToInt32(data.accountid);
                    pat.Card_Issued = data.IssueCard ?? false;
                    pat.free_check = data.FreeCheck ?? false;
                    decimal netAmount = data.Fees;

                    if (category == "11")
                    {
                        pat.Hospital_share = Math.Round(netAmount / 2, 2);
                        pat.doc_share = Math.Round(netAmount / 2, 2).ToString("F2");
                    }
                    else
                    {
                        decimal hospitalSharePct = data.Hosp_share; 
                        decimal doctorSharePct = data.Doc_Share;

                        pat.Hospital_share = Math.Round((netAmount * hospitalSharePct) / 100, 2);
                        pat.doc_share = Math.Round((netAmount * doctorSharePct) / 100, 2).ToString("F2");
                    }


                    pat.Share_Transfered = (category == "02");

                    if (isNew)
                        db.Patients.InsertOnSubmit(pat);

                    db.SubmitChanges();
                    return pat.Patient_ID.ToString();
                }
            }
            catch (Exception ex)
            {
                
                return "ERROR: Failed to save OPD record. Please try again.";
            }
        }
        private static PolicySlot GetCurrentActivePolicySlot(string doctorIdStr)
        {
            if (string.IsNullOrWhiteSpace(doctorIdStr) || !int.TryParse(doctorIdStr, out int docId))
                return null;

            using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var policyId = (from emp in db.HR_Employees
                                where emp.Emp_ID == docId && emp.IsDoctor == true
                                select emp.Policy_id).FirstOrDefault();

                if (!policyId.HasValue) return null;

                var now = DateTime.Now;
                var currentTime = now.TimeOfDay;

                var activeSlot = (
                    from pd in db.Policy_Details
                    where pd.Policy_ID == policyId &&
                          pd.IsTime == true &&
                          pd.Start_Time.HasValue && pd.End_Time.HasValue &&
                          (!pd.Expiry_Date.HasValue || pd.Expiry_Date.Value.Date >= now.Date)
                    let start = pd.Start_Time.Value
                    let end = pd.End_Time.Value
                    where
                        (start <= end && currentTime >= start && currentTime < end) || // normal
                        (start > end && (currentTime >= start || currentTime < end))   // overnight
                    select new PolicySlot
                    {
                        Start_Time = start,
                        End_Time = end
                    }
                ).FirstOrDefault();

                return activeSlot;
            }
        }

        // 🔹 Helper 2: Get next future slot today (if no active slot)
        private static PolicySlot GetNextPolicySlotForToday(string doctorIdStr)
        {
            if (string.IsNullOrWhiteSpace(doctorIdStr) || !int.TryParse(doctorIdStr, out int docId))
                return null;

            using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var policyId = (from emp in db.HR_Employees
                                where emp.Emp_ID == docId && emp.IsDoctor == true
                                select emp.Policy_id).FirstOrDefault();

                if (!policyId.HasValue) return null;

                var now = DateTime.Now;
                var currentTime = now.TimeOfDay;
                var today = now.Date;

                var slots = (
                    from pd in db.Policy_Details
                    where pd.Policy_ID == policyId &&
                          pd.IsTime == true &&
                          pd.Start_Time.HasValue && pd.End_Time.HasValue &&
                          (!pd.Expiry_Date.HasValue || pd.Expiry_Date.Value.Date >= today)
                    select new
                    {
                        Start = pd.Start_Time.Value,
                        End = pd.End_Time.Value
                    }
                ).ToList();

                // Find the next slot that starts AFTER current time
                var nextSlot = slots
                    .Where(s => s.Start > currentTime)
                    .OrderBy(s => s.Start)
                    .FirstOrDefault();

                if (nextSlot != null)
                {
                    return new PolicySlot
                    {
                        Start_Time = nextSlot.Start,
                        End_Time = nextSlot.End
                    };
                }

                return null; // No upcoming slot today
            }
        }
        private class PolicySlot
        {
            public TimeSpan Start_Time { get; set; }
            public TimeSpan End_Time { get; set; }
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
                var patientRecord = db.Reg_patients.FirstOrDefault(x => x.pat_id == reg_id);
                if (patientRecord == null)
                {
                    return new JavaScriptSerializer().Serialize(null);
                }
                if (patientRecord.DOB.HasValue)
                {
                    DateTime dob = patientRecord.DOB.Value;
                    DateTime today = DateTime.Today;

                    int years = today.Year - dob.Year;
                    int months = today.Month - dob.Month;
                    int days = today.Day - dob.Day;
                    if (days < 0)
                    {
                        months--;
                        days += DateTime.DaysInMonth(today.Year, (today.Month == 1 ? 12 : today.Month - 1));
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

                    if (patientRecord.Age_years != formattedAge)
                    {
                        patientRecord.Age_years = formattedAge;
                        db.SubmitChanges();
                    }
                }

                //Old Code for DOB
                //if (patientRecord.DOB.HasValue)
                //{
                //    DateTime dob = patientRecord.DOB.Value;
                //    DateTime today = DateTime.Today;
                //    int calculatedAge = today.Year - dob.Year;
                //    if (dob > today.AddYears(-calculatedAge))
                //        calculatedAge--;
                //    string currentAgeStr = calculatedAge.ToString();
                //    if (patientRecord.Age_years != currentAgeStr)
                //    {
                //        patientRecord.Age_years = currentAgeStr;
                //        db.SubmitChanges();
                //    }
                //}
                int numberOfDaysLatest = 0;
                int numberOfDaysSecondLatest = 0;
                var opd_time = (from pt in db.Patients
                                where pt.Reg_PatId == reg_id
                                orderby pt.Patient_ID descending
                                select pt.Created_Time).FirstOrDefault();
                if (opd_time != null)
                {
                    numberOfDaysLatest = (int)(DateTime.Now.Date - opd_time.Value.Date).TotalDays;
                }
                var opd_time2 = (from pt in db.Patients
                                 where pt.Reg_PatId == reg_id
                                 orderby pt.Patient_ID descending
                                 select pt.Created_Time)
                                 .Skip(1)
                                 .FirstOrDefault();
                if (opd_time2 != null)
                {
                    numberOfDaysSecondLatest = (int)(DateTime.Now.Date - opd_time2.Value.Date).TotalDays;
                }
                var query = (from rg in db.Reg_patients
                             where rg.pat_id == reg_id
                             select new
                             {
                                 Name = HttpUtility.HtmlEncode(rg.Full_Name),
                                 FatherName = HttpUtility.HtmlEncode(rg.Father_Name),
                                 Relation = HttpUtility.HtmlEncode(rg.Relation_prefix),
                                 Gender = rg.Gender,
                                 DOB = rg.DOB,
                                 Age = rg.Age_years,
                                 MaritalStatus = rg.Martial_Status,
                                 MaritalStatus_text = HttpUtility.HtmlEncode(db.GetDataValueName("Marital Status", rg.Martial_Status)),
                                 Gender_text = HttpUtility.HtmlEncode(db.GetDataValueName("Gender", rg.Gender)),
                                 Mr_No = HttpUtility.HtmlEncode(rg.mr_no_sequence),
                                 pat_no = rg.Patient_No,
                                 Address = HttpUtility.HtmlEncode(rg.Permanent_Address),
                                 Mobile = HttpUtility.HtmlEncode(rg.Mobile1),
                                 CNIC_Masked = MaskCNIC(rg.NIC),
                                 HouseNo = HttpUtility.HtmlEncode(rg.House_No),
                                 Area = HttpUtility.HtmlEncode(rg.area),
                                 StreetNo = HttpUtility.HtmlEncode(rg.stno_mno),
                                 City = HttpUtility.HtmlEncode(rg.city),
                                 ValArea = HttpUtility.HtmlEncode(rg.val_area),
                                 ValCity = HttpUtility.HtmlEncode(rg.val_city),
                                 Reg_PatientID = rg.pat_id,
                                 opdCount = db.Patients.Count(count => count.Reg_PatId == reg_id),
                                 DaysSinceLatestVisit = numberOfDaysLatest,
                                 DaysSinceSecondLatestVisit = numberOfDaysSecondLatest
                             }).FirstOrDefault();
                return new JavaScriptSerializer().Serialize(query);
            }
        }

        //[WebMethod]
        //public static string GetBasicInfoOFReffer(int reg_id)
        //{
        //    using (DataBaseDataContext db = new DataBaseDataContext())
        //    {
        //        var patientRecord = db.Reg_patients.FirstOrDefault(x => x.pat_id == reg_id);
        //        if (patientRecord == null)
        //        {
        //            return new JavaScriptSerializer().Serialize(null);
        //        }
        //        if (patientRecord.DOB.HasValue)
        //        {
        //            DateTime dob = patientRecord.DOB.Value;
        //            DateTime today = DateTime.Today;

        //            int years = today.Year - dob.Year;
        //            int months = today.Month - dob.Month;
        //            int days = today.Day - dob.Day;
        //            if (days < 0)
        //            {
        //                months--;
        //                days += DateTime.DaysInMonth(today.Year, (today.Month == 1 ? 12 : today.Month - 1));
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

        //            if (patientRecord.Age_years != formattedAge)
        //            {
        //                patientRecord.Age_years = formattedAge;
        //                db.SubmitChanges();
        //            }
        //        }

               
        //        int numberOfDaysLatest = 0;
        //        int numberOfDaysSecondLatest = 0;
        //        var opd_time = (from pt in db.Patients
        //                        where pt.Reg_PatId == reg_id
        //                        orderby pt.Patient_ID descending
        //                        select pt.Created_Time).FirstOrDefault();
        //        if (opd_time != null)
        //        {
        //            numberOfDaysLatest = (int)(DateTime.Now.Date - opd_time.Value.Date).TotalDays;
        //        }
        //        var opd_time2 = (from pt in db.Patients
        //                         where pt.Reg_PatId == reg_id
        //                         orderby pt.Patient_ID descending
        //                         select pt.Created_Time)
        //                         .Skip(1)
        //                         .FirstOrDefault();
        //        if (opd_time2 != null)
        //        {
        //            numberOfDaysSecondLatest = (int)(DateTime.Now.Date - opd_time2.Value.Date).TotalDays;
        //        }
        //        var query = (from rg in db.Reg_patients join p in db.Patients
        //                     on rg.pat_id equals p.Reg_PatId join
        //                     opd in db.Out_Patients on p.Patient_ID equals opd.Patient_ID
        //                     where rg.pat_id == reg_id orderby opd.Out_Patient_ID descending
        //                     select new
        //                     {
        //                         Name = HttpUtility.HtmlEncode(rg.Full_Name),
        //                         FatherName = HttpUtility.HtmlEncode(rg.Father_Name),
        //                         Relation = HttpUtility.HtmlEncode(rg.Relation_prefix),
        //                         Gender = rg.Gender,
        //                         DOB = rg.DOB,
        //                         Age = rg.Age_years,
        //                         MaritalStatus = rg.Martial_Status,
        //                         MaritalStatus_text = HttpUtility.HtmlEncode(db.GetDataValueName("Marital Status", rg.Martial_Status)),
        //                         Gender_text = HttpUtility.HtmlEncode(db.GetDataValueName("Gender", rg.Gender)),
        //                         Reffer = HttpUtility.HtmlEncode(db.GetDataValueName("Gender", rg.Gender)),
        //                         Mr_No = HttpUtility.HtmlEncode(rg.mr_no_sequence),
        //                         pat_no = rg.Patient_No,
        //                         Address = HttpUtility.HtmlEncode(rg.Permanent_Address),
        //                         Mobile = HttpUtility.HtmlEncode(rg.Mobile1),
        //                         CNIC_Masked = MaskCNIC(rg.NIC),
        //                         HouseNo = HttpUtility.HtmlEncode(rg.House_No),
        //                         Area = HttpUtility.HtmlEncode(rg.area),
        //                         StreetNo = HttpUtility.HtmlEncode(rg.stno_mno),
        //                         City = HttpUtility.HtmlEncode(rg.city),
        //                         ValArea = HttpUtility.HtmlEncode(rg.val_area),
        //                         ValCity = HttpUtility.HtmlEncode(rg.val_city),
        //                         Reg_PatientID = rg.pat_id,
        //                         opdCount = db.Patients.Count(count => count.Reg_PatId == reg_id),
        //                         DaysSinceLatestVisit = numberOfDaysLatest,
        //                         DaysSinceSecondLatestVisit = numberOfDaysSecondLatest
        //                     }).FirstOrDefault();
        //        return new JavaScriptSerializer().Serialize(query);
        //        string pat_type_Val = "02";
        //        string pat_type_text = HttpUtility.HtmlEncode(db.GetDataValueName("Patient Type", pat_type_Val));
        //    }
        //}

        [WebMethod]
        public static string GetBasicInfoOFReffer(int reg_id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
           
                var patient = (from rg in db.Reg_patients
                               join p in db.Patients
                               on rg.pat_id equals p.Reg_PatId
                               join opd in db.Out_Patients 
                               on p.Patient_ID equals opd.Patient_ID
                               where rg.pat_id == reg_id
                               orderby opd.Out_Patient_ID descending
                               
                               select new
                               {
                                   Full_Name = rg.Full_Name,
                                   Father_Name = rg.Father_Name,
                                   Relation_prefix = rg.Relation_prefix,
                                   Gender = rg.Gender,
                                   Age_years = rg.Age_years,
                                   Martial_Status = rg.Martial_Status,
                                   mr_no_sequence = rg.mr_no_sequence,
                                   Patient_No = rg.Patient_No,
                                   House_No = rg.House_No,
                                   stno_mno = rg.stno_mno,
                                   area = rg.area,
                                   city = rg.city,
                                   Permanent_Address = rg.Permanent_Address,
                                   Mobile1 = rg.Mobile1,
                                   NIC = rg.NIC,
                                   val_area = rg.val_area,
                                   val_city = rg.val_city,
                                   pat_id = rg.pat_id,
                                   Reffto = opd.reffer_doc,
                                   Reffdep = opd.Reffer_To
                               }).FirstOrDefault();

                if (patient == null)
                    return new JavaScriptSerializer().Serialize(null);

                string doctorId = null;
                string departmentid = null;
                string DoctorName = "";

                string pat_type_Val = "02";
                string pat_type_text = HttpUtility.HtmlEncode(db.GetDataValueName("Patient Type", pat_type_Val));
                string maritalStatus_text = HttpUtility.HtmlEncode(db.GetDataValueName("Marital Status", patient.Martial_Status));
                string gender_text = HttpUtility.HtmlEncode(db.GetDataValueName("Gender", patient.Gender));
                string department_Text = HttpUtility.HtmlEncode(db.GetDataValueName("Patient Main Category", patient.Reffdep));
                 departmentid = HttpUtility.HtmlEncode( patient.Reffdep);
                DoctorName = db.HR_Employees
                .Where(e => e.Emp_ID == patient.Reffto)
                .Select(e => e.Emp_Name)
                .FirstOrDefault() ?? "";
                DoctorName = HttpUtility.HtmlEncode(DoctorName);
                doctorId = Convert.ToString( patient.Reffto);
 

                

         
                int numberOfDaysLatest = 0;
                int numberOfDaysSecondLatest = 0;

                var latestVisit = db.Patients
                                    .Where(p => p.Reg_PatId == patient.pat_id)
                                    .OrderByDescending(p => p.Patient_ID)
                                    .Take(2)
                                    .ToList();

                if (latestVisit.Count > 0 && latestVisit[0].Created_Time.HasValue)
                    numberOfDaysLatest = (int)(DateTime.Now.Date - latestVisit[0].Created_Time.Value.Date).TotalDays;

                if (latestVisit.Count > 1 && latestVisit[1].Created_Time.HasValue)
                    numberOfDaysSecondLatest = (int)(DateTime.Now.Date - latestVisit[1].Created_Time.Value.Date).TotalDays;

                var result = new
                {
                    Name = HttpUtility.HtmlEncode(patient.Full_Name),
                    FatherName = HttpUtility.HtmlEncode(patient.Father_Name),
                    Relation = HttpUtility.HtmlEncode(patient.Relation_prefix),
                    Gender = patient.Gender,
                    Gender_text = gender_text,
                    Age = patient.Age_years,
                    MaritalStatus = patient.Martial_Status,
                    MaritalStatus_text = maritalStatus_text,
                    Mr_No = HttpUtility.HtmlEncode(patient.mr_no_sequence),
                    pat_no = patient.Patient_No,
                    Address = HttpUtility.HtmlEncode($"H# {patient.House_No} {patient.stno_mno} {patient.area} {patient.city}"),
                    PermanentAdrress = HttpUtility.HtmlEncode(patient.Permanent_Address),
                    Mobile = HttpUtility.HtmlEncode(patient.Mobile1),
                    CNIC_Masked = MaskCNIC(patient.NIC),
                    HouseNo = HttpUtility.HtmlEncode(patient.House_No),
                    Area = HttpUtility.HtmlEncode(patient.area),
                    StreetNo = HttpUtility.HtmlEncode(patient.stno_mno),
                    City = HttpUtility.HtmlEncode(patient.city),
                    ValArea = HttpUtility.HtmlEncode(patient.val_area),
                    ValCity = HttpUtility.HtmlEncode(patient.val_city),
                    Reg_PatientID = patient.pat_id,

                    doctorId = doctorId,
                    DoctorName = DoctorName,
                    departmentid = departmentid,
                    department_Text = department_Text,

                    pat_type_Val = pat_type_Val,
                    pat_type_text = pat_type_text,

                    DaysSinceLatestVisit = numberOfDaysLatest,
                    DaysSinceSecondLatestVisit = numberOfDaysSecondLatest,
                };

                return new JavaScriptSerializer().Serialize(result);
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
                                   Full_Name = rg.Full_Name,
                                   Father_Name = rg.Father_Name,
                                   Relation_prefix = rg.Relation_prefix,
                                   Gender = rg.Gender,
                                   Age_years = rg.Age_years,
                                   Martial_Status = rg.Martial_Status,
                                   mr_no_sequence = rg.mr_no_sequence,
                                   Patient_No = rg.Patient_No,
                                   House_No = rg.House_No,
                                   stno_mno = rg.stno_mno,
                                   area = rg.area,
                                   city = rg.city,
                                   Permanent_Address = rg.Permanent_Address,
                                   Mobile1 = rg.Mobile1,
                                   NIC = rg.NIC,
                                   val_area = rg.val_area,
                                   val_city = rg.val_city,
                                   pat_id = rg.pat_id
                               }).FirstOrDefault();

                if (patient == null)
                    return new JavaScriptSerializer().Serialize(null);

            
                string pat_type_Val = "02";
                string pat_type_text = HttpUtility.HtmlEncode(db.GetDataValueName("Patient Type", pat_type_Val));
                string maritalStatus_text = HttpUtility.HtmlEncode(db.GetDataValueName("Marital Status", patient.Martial_Status));
                string gender_text = HttpUtility.HtmlEncode(db.GetDataValueName("Gender", patient.Gender));

                string doctorId = null;
                string departmentid = null;
                string appointmentType = null; 

                var opdApt = db.Appointment_Forms.FirstOrDefault(a => a.Appointment_ID == apt_Id);
                if (opdApt != null)
                {
                    doctorId = opdApt.Consultant_ID;
                    departmentid = opdApt.Sub_Department;
                    appointmentType = "OPD";
                }
                else
                {
                    // Try Derma Appointment
                    var dermApt = db.Derma_Appointments.FirstOrDefault(a => a.Derma_Appointment_Id == apt_Id);
                    if (dermApt != null)
                    {
                        doctorId = dermApt.Doctor_Id;

                        departmentid = db.HR_Employees
                                         .Where(a => a.Emp_ID == Convert.ToInt32(doctorId))
                                         .Select(a => a.Department)
                                         .FirstOrDefault();

                        appointmentType = "Derma";
                    }
                    else
                    {
                        return new JavaScriptSerializer().Serialize(new { error = "Appointment not found" });
                    }

                }

                string DoctorName = "";
                if (!string.IsNullOrEmpty(doctorId) && int.TryParse(doctorId, out int docId))
                {
                    DoctorName = db.HR_Employees
                                    .Where(e => e.Emp_ID == docId)
                                    .Select(e => e.Emp_Name)
                                    .FirstOrDefault() ?? "";
                    DoctorName = HttpUtility.HtmlEncode(DoctorName);
                }

                string department_Text = HttpUtility.HtmlEncode(db.GetDataValueName("Patient Main Category", departmentid));

         
                int numberOfDaysLatest = 0;
                int numberOfDaysSecondLatest = 0;

                var latestVisit = db.Patients
                                    .Where(p => p.Reg_PatId == patient.pat_id)
                                    .OrderByDescending(p => p.Patient_ID)
                                    .Take(2)
                                    .ToList();

                if (latestVisit.Count > 0 && latestVisit[0].Created_Time.HasValue)
                    numberOfDaysLatest = (int)(DateTime.Now.Date - latestVisit[0].Created_Time.Value.Date).TotalDays;

                if (latestVisit.Count > 1 && latestVisit[1].Created_Time.HasValue)
                    numberOfDaysSecondLatest = (int)(DateTime.Now.Date - latestVisit[1].Created_Time.Value.Date).TotalDays;

                var result = new
                {
                    Name = HttpUtility.HtmlEncode(patient.Full_Name),
                    FatherName = HttpUtility.HtmlEncode(patient.Father_Name),
                    Relation = HttpUtility.HtmlEncode(patient.Relation_prefix),
                    Gender = patient.Gender,
                    Gender_text = gender_text,
                    Age = patient.Age_years,
                    MaritalStatus = patient.Martial_Status,
                    MaritalStatus_text = maritalStatus_text,
                    Mr_No = HttpUtility.HtmlEncode(patient.mr_no_sequence),
                    pat_no = patient.Patient_No,
                    Address = HttpUtility.HtmlEncode($"H# {patient.House_No} {patient.stno_mno} {patient.area} {patient.city}"),
                    PermanentAdrress = HttpUtility.HtmlEncode(patient.Permanent_Address),
                    Mobile = HttpUtility.HtmlEncode(patient.Mobile1),
                    CNIC_Masked = MaskCNIC(patient.NIC),
                    HouseNo = HttpUtility.HtmlEncode(patient.House_No),
                    Area = HttpUtility.HtmlEncode(patient.area),
                    StreetNo = HttpUtility.HtmlEncode(patient.stno_mno),
                    City = HttpUtility.HtmlEncode(patient.city),
                    ValArea = HttpUtility.HtmlEncode(patient.val_area),
                    ValCity = HttpUtility.HtmlEncode(patient.val_city),
                    Reg_PatientID = patient.pat_id,

                    doctorId = doctorId,
                    DoctorName = DoctorName,
                    departmentid = departmentid,
                    department_Text = department_Text,

                    pat_type_Val = pat_type_Val,
                    pat_type_text = pat_type_text,

                    DaysSinceLatestVisit = numberOfDaysLatest,
                    DaysSinceSecondLatestVisit = numberOfDaysSecondLatest,

                    AppointmentType = appointmentType
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

                string Encode(string input) => string.IsNullOrEmpty(input) ? "" : HttpUtility.HtmlEncode(input);

                var result = new
                {
                    mr_no_sequence = Encode(patient.mr_no_sequence),
                    Opd_No = patient.Opd_No,
                    Name = Encode(patient.Full_Name),
                    StudentName = Encode(patient.Student_Name),
                    Father_Name = Encode(patient.Father_Name),
                    Mode_Of_Registration = Encode(patient.Mode_Of_Registration),
                    Patient_Type = Encode(patient.Patient_Type),
                    Age_years = patient.Age_years,
                    Gender_text = Encode(db.GetDataValueName("Gender", patient.Gender)),
                    Mobile1 = MaskMobile(patient.Mobile1),
                    CNIC_Masked = MaskCNIC(patient.NIC),
                    MaritalStatus_text = Encode(db.GetDataValueName("Marital Status", patient.Marital_Status)),
                    Permanent_Address = Encode(patient.Permanent_Address),
                    Receipt_Amount = patient.Receipt_Amount,
                    Actual_amount = patient.Actual_amount,
                    Category_text = Encode(db.GetDataValueName("Patient Main Category", patient.Patient_Main_Category)),
                    Type_text = Encode(db.GetDataValueName("Patient Type", patient.Patient_Type)),
                    Doc_text = Encode(
                        patient.Doctor_ID == null || !int.TryParse(patient.Doctor_ID.ToString(), out _)
                            ? ""
                            : db.HR_Employees
                                .Where(e => e.Emp_ID == Convert.ToInt32(patient.Doctor_ID))
                                .Select(e => e.Emp_Name)
                                .FirstOrDefault() ?? ""
                    ),
                    PanelCompany_text = Encode(
                        db.Panels
                            .Where(p => p.Panel_ID == patient.PanelCompany)
                            .Select(p => p.Company_Name)
                            .FirstOrDefault() ?? ""
                    ),
                    employee_text = Encode(
                        patient.employee_ID == null || !int.TryParse(patient.employee_ID.ToString(), out _)
                            ? ""
                            : db.HR_Employees
                                .Where(e => e.Emp_ID == Convert.ToInt32(patient.employee_ID))
                                .Select(e => e.Emp_Name)
                                .FirstOrDefault() ?? ""
                    ),
                    Refference_No = Encode(patient.Refference_No),
                    Employee_Name = Encode(patient.Employee_Name),
                    discount_amt = patient.discount_amt,
                    Dependent = Encode(patient.Dependent),
                    RollNo = patient.RollNo,
                    Class = patient.Class,
                    Section = patient.Section,
                    Casher = Encode(patient.Casher),
                    Card_Issued = patient.Card_Issued,
                    free_check = patient.free_check,
                    opdid = patient.Patient_ID,
                    status = Encode(patient.Status),
                    account_id = patient.AccountID,
                    Clinic_text = Encode(db.GetDataValueName("Filter Clinic", patient.filter_clinic)),
                    Service_text = Encode(
                        db.INV_Items
                            .Where(i => i.Item_ID == patient.Service_id)
                            .Select(i => i.Description)
                            .FirstOrDefault() ?? ""
                    )
                };
                return new JavaScriptSerializer().Serialize(result);
            }
        }

        [WebMethod]
        public static List<PatientsResult> SearchPatients(string SearchString)
        {
            string SearchSql = "";
            if (string.IsNullOrEmpty(SearchString))
                SearchSql = "SELECT top 10 pat_id,isnull(mr_no_sequence,'')Patient_No,isnull(Full_Name,'')Full_Name,isnull(NIC,'')NIC,isnull(Mobile1,'') ContactNo,isnull(Father_Name,'')Father_Name FROM reg_patient where(1=1) and Patient_No<>0 and Patient_No is not null and isnull(isCancel,0)!=1 order by pat_id desc";
            else
                SearchSql = "SELECT pat_id,isnull(mr_no_sequence,'')Patient_No,isnull(Full_Name,'')Full_Name,isnull(NIC,'')NIC,isnull(Mobile1,'') ContactNo,isnull(Father_Name,'')Father_Name FROM reg_patient where(1=1) and Patient_No<>0 and Patient_No is not null and isnull(isCancel,0)!=1 and (LTRIM(RTRIM(patient_no)) like '%" + SearchString.Trim() + "%' or  LTRIM(RTRIM(full_name)) like '%" + SearchString.Trim() + "%' or LTRIM(RTRIM(mobile1))  like '%" + SearchString.Trim() + "%' or LTRIM(RTRIM(nic))  like '%" + SearchString.Trim() + "%') order by pat_id desc";

            DataTable dt = DBClass.getDataTable(SearchSql);
            List<PatientsResult> list = new List<PatientsResult>();
            foreach (DataRow dr in dt.Rows)
            {
                PatientsResult rslt = new PatientsResult()
                {
                    Reg_Patient_ID = dr[0] == DBNull.Value ? "" : dr[0].ToString(),
                    Patient_No = dr[1] == DBNull.Value ? "" : HttpUtility.HtmlEncode(dr[1].ToString()),
                    Full_Name = dr[2] == DBNull.Value ? "" : HttpUtility.HtmlEncode(dr[2].ToString()),
                    NIC = dr[3] == DBNull.Value ? "" : HttpUtility.HtmlEncode(dr[3].ToString()),
                    Mobile1 = dr[4] == DBNull.Value ? "" : HttpUtility.HtmlEncode(dr[4].ToString()),
                    Father_Name = dr[5] == DBNull.Value ? "" : HttpUtility.HtmlEncode(dr[5].ToString()),
                };
                list.Add(rslt);
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
            string safeSearch = SearchString?.Replace("'", "''").Trim() ?? "";

            // 🔹 OPD Appointments — ✅ Add SortOrderID
            string opdQuery = @"
        SELECT 
            CAST(a.Appointment_ID AS VARCHAR) AS Appointment_ID,
            ISNULL(CAST(a.Appointment_No AS VARCHAR), '') AS Appointment_No,
            CONVERT(VARCHAR(11), a.App_Date, 106) AS App_Date,
            ISNULL(a.Patient_Name, '') AS Patient_Name,
            ISNULL(a.Consultant_ID, '') AS Consultant_ID,
            ISNULL(a.Age, '') AS Age,
            ISNULL(a.Phone, '') AS Phone,
            ISNULL((SELECT TOP 1 e.Emp_Name FROM HR_Employees e WHERE e.Emp_ID = a.Consultant_ID), '') AS Emp_name,
            ISNULL(CAST(a.Reg_id AS VARCHAR), '') AS pat_id,
            a.Appointment_ID AS SortOrderID   -- ✅ numeric, for ordering
        FROM Appointment_Form a
        INNER JOIN Reg_patient r ON r.pat_id = a.Reg_id
        WHERE a.Appointment_No <> 0 
          AND a.Appointment_No IS NOT NULL 
          AND a.Status = 'Booked'";

            // 🔹 Derma Appointments — ✅ Add SortOrderID
            string dermaQuery = @"
        SELECT 
            CAST(d.Derma_Appointment_Id AS VARCHAR) AS Appointment_ID,
            ISNULL(CAST(d.Appointment_No AS VARCHAR), '') AS Appointment_No,
            CONVERT(VARCHAR(11), d.Appointment_Date, 106) AS App_Date,
            ISNULL(r.Full_Name, '') AS Patient_Name,
            ISNULL(d.Doctor_Id, '') AS Consultant_ID,
            ISNULL(CAST(r.Age_years AS VARCHAR), '') AS Age,
            ISNULL(r.Mobile1, '') AS Phone,
            ISNULL((SELECT TOP 1 e.Emp_Name FROM HR_Employees e WHERE e.Emp_ID = d.Doctor_Id), '') AS Emp_name,
            ISNULL(CAST(d.Patient_Id AS VARCHAR), '') AS pat_id,
            d.Derma_Appointment_Id AS SortOrderID   -- ✅ numeric, for ordering
        FROM Derma_Appointment d
        INNER JOIN Reg_patient r ON r.pat_id = d.Patient_Id
        WHERE d.Status = 'Booked'";

            string unionQuery = $"({opdQuery}) UNION ALL ({dermaQuery})";


            string whereClause = "1=1";
            if (!string.IsNullOrEmpty(safeSearch))
            {
                whereClause += $@"
            AND (
                LTRIM(RTRIM(Appointment_No)) LIKE '%{safeSearch}%' OR
                LTRIM(RTRIM(Patient_Name)) LIKE '%{safeSearch}%' OR
                LTRIM(RTRIM(Consultant_ID)) LIKE '%{safeSearch}%' OR
                LTRIM(RTRIM(Age)) LIKE '%{safeSearch}%' OR
                LTRIM(RTRIM(Phone)) LIKE '%{safeSearch}%' OR
                Consultant_ID = ISNULL((SELECT TOP 1 Emp_ID FROM HR_Employees WHERE Emp_Name LIKE '%{safeSearch}%'), '0')
            )";
            }

            string finalQuery = $@"
        SELECT TOP 100
            Appointment_ID, Appointment_No,App_Date, Patient_Name, Consultant_ID, 
            Age, Phone, Emp_name, pat_id
        FROM (
            {unionQuery}
        ) AS Combined
        WHERE {whereClause}
        ORDER BY SortOrderID DESC";

            try
            {
                DataTable dt = DBClass.getDataTable(finalQuery);
                var list = new List<Search_App>();

                foreach (DataRow dr in dt.Rows)
                {
                    list.Add(new Search_App
                    {
                        Appointment_ID = dr["Appointment_ID"]?.ToString() ?? "",
                        Appointment_No = HttpUtility.HtmlEncode(dr["Appointment_No"]?.ToString() ?? ""),
                        App_Date = HttpUtility.HtmlEncode(dr["App_Date"]?.ToString() ?? ""),
                        Patient_Name = HttpUtility.HtmlEncode(dr["Patient_Name"]?.ToString() ?? ""),
                        Consultant_ID = dr["Consultant_ID"]?.ToString() ?? "",
                        Age = HttpUtility.HtmlEncode(dr["Age"]?.ToString() ?? ""),
                        Phone = HttpUtility.HtmlEncode(dr["Phone"]?.ToString() ?? ""),
                        Emp_name = HttpUtility.HtmlEncode(dr["Emp_name"]?.ToString() ?? ""),
                        pat_id = dr["pat_id"]?.ToString() ?? ""
                    });
                }
                return list;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Search Error: " + ex.Message);
                return new List<Search_App>();
            }
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
                    Patient_No = dr["Patient_No"] == DBNull.Value ? "" : HttpUtility.HtmlEncode(dr["Patient_No"].ToString()),
                    Full_Name = dr["Full_Name"] == DBNull.Value ? "" : HttpUtility.HtmlEncode(dr["Full_Name"].ToString()),
                    NIC = dr["NIC"] == DBNull.Value ? "" : HttpUtility.HtmlEncode(dr["NIC"].ToString()),
                    Mobile1 = dr["ContactNo"] == DBNull.Value ? "" : HttpUtility.HtmlEncode(dr["ContactNo"].ToString()),
                    Father_Name = dr["Father_Name"] == DBNull.Value ? "" : HttpUtility.HtmlEncode(dr["Father_Name"].ToString()),
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
                       // DBClass.exectueQuery("update Patients set Card_Receipt_Amount = " + totalRec + " where Patient_ID =" + PatID, tranObj, con);
                        DBClass.exectueQuery("UPDATE Patients SET cardReprint = " + rep + " where Patient_ID =" + PatID, tranObj, con);
                        tranObj.Commit();
                    }
                    else
                    {
                        //DBClass.exectueQuery("update Patients set Card_Receipt_Amount = " + sysParm + " where Patient_ID =" + PatID, tranObj, con);
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
#pragma warning disable CS0168
            catch (Exception ex)
#pragma warning restore CS0168
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
            public string App_Date;
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
            public int? employee_id { get; set; }
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
            public int? designation { get; set; }
            public string dependent { get; set; }
            public string rollno { get; set; }
            public string Class { get; set; }
            public string section { get; set; }
            public string Cashier { get; set; }
            public int Services { get; set; }
            public decimal Doc_Share { get; set; }
            public decimal Hosp_share { get; set; }
            public string accountid { get; set; }
            public string FilterClinic { get; set; }
            public string hdnAppointmentType { get; set; }
            public string EmployeeName { get; set; }
            public string EmployeeDept { get; set; }
            public string AntiForgeryToken { get; set; }
            public bool? IssueCard { get; set; }
            public bool? FreeCheck { get; set; }
            public int Fees { get; set; }
            public int Actual_Fees { get; set; }
        }
    }
}