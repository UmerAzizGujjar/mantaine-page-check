using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using static PMS.Modules.Administrator.Department_Assign_Policy;

namespace PMS
{
    public partial class Employee : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string PopulateEmployeeData(int Emp_ID)
        {
            string data = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            HR_Employee employee = (from tbl in db.HR_Employees
                                    where tbl.Emp_ID == Emp_ID
                                    select tbl).FirstOrDefault();
            if (employee != null)
            {
                var TxtTime_In = "";
                var TxtTime_Out = "";
                var ddlRoom = "";
                var sun = false; var mon = false; var tue = false; var wed = false; var thur = false; var fri = false; var sat = false;
                var txtEmployee_Resign = "";
                var txtPanelAmount = "";
                if (employee.Timings_In.HasValue)
                {
                    TxtTime_In = employee.Timings_In.Value.ToString(@"hh\:mm");
                }
                else
                {
                    TxtTime_In = "";
                }

                if (employee.Timings_Out.HasValue)
                {
                    TxtTime_Out = employee.Timings_Out.Value.ToString(@"hh\:mm"); 
                }
                else
                {
                    TxtTime_Out = "";
                }
                if (employee.Room_No == null)
                {
                    ddlRoom = "";
                }
                else
                {
                    ddlRoom = employee.Room_No.Value.ToString();
                }
                if (employee.Off_Days_Names == null)
                {

                }
                else
                {
                    if (employee.Off_Days_Names.Contains("Sun"))
                    {
                        sun = true;
                    }
                    if (employee.Off_Days_Names.Contains("Mon"))
                    {
                        mon = true;
                    }
                    if (employee.Off_Days_Names.Contains("Tue"))
                    {
                        tue = true;
                    }
                    if (employee.Off_Days_Names.Contains("Wed"))
                    {
                        wed = true;
                    }
                    if (employee.Off_Days_Names.Contains("Thu"))
                    {
                        thur = true;
                    }
                    if (employee.Off_Days_Names.Contains("Fri"))
                    {
                        fri = true;
                    }
                    if (employee.Off_Days_Names.Contains("Sat"))
                    {
                        sat = true;
                    }
                }
                if (employee.Account_ID != null)
                {
                    LoadGLAccount(employee.Account_ID);
                }
                if (employee.Resign_Date != null)
                {
                    txtEmployee_Resign = employee.Resign_Date.Value.ToString(AppConfig.DateFormat);
                }
                if (employee.Panel_Rate != null)
                {
                    txtPanelAmount = employee.Panel_Rate;

                }
                var DataFromTable = new
                {
                    Account_ID = employee.Account_ID,
                    panelrate = employee.Panel_Rate,
                    dependent = employee.Dependent,
                    user = employee.userid,
                    txtEmployeeID = employee.Emp_ID,
                    txtEmployeeCode = employee.Emp_No ?? string.Empty,
                    txtEmployee_Name = employee.Emp_Name ?? string.Empty,
                    txtdependent = employee.Dependent ?? string.Empty,
                    txtdoc_qualification = employee.Doc_qualification ?? string.Empty,
                    txtFather_Name = employee.Father_Name ?? string.Empty,

                    // Safe handling for nullable DateTime
                    txtEmployee_Date_of_Birth = employee.DOB?.ToString(AppConfig.DateFormat) ?? string.Empty,

                    ddlDepartment = employee.Department ?? string.Empty,
                    ddlPolicy = employee.Policy_id,
                    ddlDoctorBuilding = employee.Doctor_Building ?? string.Empty,
                    ddlDesignation = employee.Designation ?? string.Empty,
                    txtEmployee_Address = employee.Address ?? string.Empty,
                    txtEmployee_Phone1 = employee.Home_Phone ?? string.Empty,
                    txtEmployee_Phone2 = employee.Mobile ?? string.Empty,
                    txtGovt_Hospital = employee.Govt_Hospital ?? string.Empty,
                    ddlPatientType = employee.Patient_Type ?? string.Empty,
                    ddluser = employee.userid,

                    // Safe handling for nullable TimeSpan? or DateTime?
                    txtPatient_Time = employee.Patient_Time?.ToString() ?? string.Empty,

                    // Ensure TxtTime_In / TxtTime_Out are string inputs — if they come from nullable DateTime/TimeOnly:
                    TxtTime_In = TxtTime_In ?? string.Empty,
                    TxtTime_Out = TxtTime_Out ?? string.Empty,

                    ddlRoom = ddlRoom ?? string.Empty, // assuming ddlRoom is string
                    ddlFloor = employee.Floor_No ?? string.Empty,
                    Ext_txt = employee.Extension_No ?? string.Empty,

                    // Boolean flags from nullable bools (safe fallback to false)
                    isSun = sun,
                    isMon = mon,
                    isTue = tue,
                    isWed = wed,
                    isThur = thur,
                    isFri = fri,
                    isSat = sat,

                    txtEmployee_NTN_No = employee.NTN_No ?? string.Empty,
                    txtEmployee_Email = employee.Email ?? string.Empty,

                    // Another critical nullable DateTime — DOJ
                    txtEmployee_DOJ = employee.DOJ?.ToString(AppConfig.DateFormat) ?? string.Empty,

                    // Start/End dates (nullable)
                    txtStartDate = employee.st_day?.ToString(AppConfig.DateFormat) ?? string.Empty,
                    txtEndDate = employee.end_day?.ToString(AppConfig.DateFormat) ?? string.Empty,

                    // Monetary/numeric values — convert safely
                    txtDoctorShare = employee.Doctor_Amount?.ToString() ?? "0",
                    txtHospital_Share = employee.Hospital_Amount?.ToString() ?? "0",
                    txtEmployee_Resign = txtEmployee_Resign ?? string.Empty, // if it's a string input
                    txtGrossPay = employee.Gross_Pay?.ToString() ?? "0",
                    txtRemarks = employee.Remarks ?? string.Empty,

                    // Boolean flags (nullable bool → bool)
                    ChkDoctor = employee.IsDoctor ?? false,
                    ChkVisting = employee.IS_Visting ?? false,
                    ChkEmployee = employee.is_Employee ?? false,
                    ChkBlockCategory = employee.Block_category ?? false,

                    txtConsultant_Charges = employee.Consultant_Charges?.ToString() ?? "0",

                    btnSave = "Update"
                };

                data = new JavaScriptSerializer().Serialize(DataFromTable);
            }
            return data;

        }
        [WebMethod]
        public static string LoadGLAccount(int? AccountID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            string data = string.Empty;
            var qury = (from a in db.GL_Accounts
                        where a.Account_ID == AccountID
                        select a).FirstOrDefault();
            if (qury != null)
            {
                var details = new
                {
                    hdfAccount_Serial = qury.Account_Serial,
                    hdfLevel = qury.Levels.ToString(),
                    hdfParent_Code = qury.Parent_Code.ToString(),
                    hdfAccount_Code = qury.Account_Code,
                    hdfAccount_Name = qury.Account_Name,
                    hdfAccount_ID = qury.Account_ID.ToString(),
                    txtAccount_Code_Name = qury.Account_Code + " - " + qury.Account_Name,
                };
                data = new JavaScriptSerializer().Serialize(details);
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
        public static string GetPatientType()
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
        public static string GetDesignation()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Designation"
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
        public static string GetBuildingType()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Building Type"
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
        public static string GetDoctorBuilding()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Doctor Building"
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
        public static string GetUsers()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from tbl in db.aspnet_Users
                              select new
                              {
                                  UserId = tbl.UserId.ToString(),
                                  UserName = tbl.UserName.ToString(),
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        [WebMethod]
        public static string GetRoom()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from tbl in db.Rooms

                              where tbl.OPDRoom == true
                              select new
                              {
                                  Room_No = tbl.Room_No.ToString(),
                                  Location = db.GetDataValueName("Building Type", tbl.Location),
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        [WebMethod]
        public static string GetAllPolicies()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var policies = db.Policies
                                 .Where(p => p.Active == true && p.Is_Cancel == false)
                                 .Select(p => new
                                 {
                                     p.Policy_ID,
                                     p.Policy_Name
                                 })
                                 .ToList();

                return new JavaScriptSerializer().Serialize(policies);
            }
        }


        [WebMethod]
        public static string SaveData(EmployeeData dataa)
        {
            try
            {


                var SelectedDays = string.Empty;
                var Sunday = "Sun";
                var Monday = "Mon";
                var Tuesday = "Tue";
                var Wednesday = "Wed";
                var Thursday = "Thur";
                var Friday = "Fri";
                var Saturday = "Sat";


                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                HR_Employee employee;
                GL_Account accounts = new GL_Account();
                int accountID = 0;
                if (dataa.buttonVal == "Save")
                {
                    employee = new HR_Employee();

                    employee.Emp_No = DBClass.GetNewNumber("Emp_No", "HR_Employees", "").ToString();
                }
                else
                {
                    employee = (from tbl in db.HR_Employees
                                where tbl.Emp_ID == Convert.ToInt32(dataa.txtEmployeeID)
                                select tbl).FirstOrDefault();

                    employee.Updated_By = AppConfig.UserID;
                    employee.Updated_Time = DateTime.Now;

                }
                if (dataa.hdfAccount_ID != "")
                {
                    accountID = Convert.ToInt32(dataa.hdfAccount_ID);
                    accounts = (from tbl in db.GL_Accounts
                                where tbl.Account_ID == accountID
                                select tbl).FirstOrDefault();
                    accounts.Account_Name = dataa.txtEmployee_Name;
                    db.SubmitChanges();
                }
                else
                {

                    if (dataa.hdfParent_Code == "")
                    {
                        return "";
                    }

                    accounts.Account_Name = dataa.txtEmployee_Name;
                    accounts.Account_Code = dataa.hdfAccount_Code;
                    accounts.Parent_Code = Convert.ToInt32(dataa.hdfParent_Code);
                    accounts.Levels = Convert.ToInt32(dataa.hdfLevel);
                    accounts.Account_Serial = dataa.hdfAccount_Serial;
                    accounts.Active = true;
                    accounts.Book_ID = AppConfig.Book_ID;
                    db.GL_Accounts.InsertOnSubmit(accounts);
                    db.SubmitChanges();
                    accountID = accounts.Account_ID;
                }

                employee.Emp_Name = dataa.txtEmployee_Name;
                employee.Father_Name = dataa.txtFather_Name;
                employee.DOB = Convert.ToDateTime(dataa.txtEmployee_Date_of_Birth);
                employee.Department = dataa.ddlDepartment;
                employee.Policy_id = dataa.ddlPolicy;
                employee.userid = Convert.ToString(dataa.ddluser);
                employee.Designation = dataa.ddlDesignation;
                employee.Address = dataa.txtEmployee_Address;
                employee.Home_Phone = dataa.txtEmployee_Phone1;
                employee.Govt_Hospital = dataa.txtGovt_Hospital;
                employee.Patient_Type = dataa.ddlPatientType;
                employee.Dependent = dataa.txtdependent;
                employee.Doc_qualification = dataa.txtdoc_qualification;


                    employee.Timings_In = dataa.TxtTime_In;
               

              
                    employee.Timings_Out = dataa.TxtTime_Out;
          

                if (!string.IsNullOrEmpty(dataa.txtPatient_Time.Trim()))
                    employee.Patient_Time = Convert.ToInt32(dataa.txtPatient_Time);


                employee.Doctor_Building = dataa.ddlDoctorBuilding;

                employee.Room_No = dataa.ddlRoom == null ? 0 : Convert.ToInt32(dataa.ddlRoom);

                employee.Floor_No = dataa.ddlFloor;
                employee.Extension_No = dataa.Ext_txt;

                if (dataa.isSun == true)
                {
                    SelectedDays = Sunday;

                }

                if (dataa.isMon == true)
                {
                    SelectedDays += "," + Monday;

                }
                if (dataa.isTue == true)
                {
                    SelectedDays += "," + Tuesday;

                }
                if (dataa.isWed == true)
                {
                    SelectedDays += "," + Wednesday;

                }

                if (dataa.isThur == true)
                {
                    SelectedDays += "," + Thursday;

                }
                if (dataa.isFri == true)
                {
                    SelectedDays += "," + Friday;

                }
                if (dataa.isSat == true)
                {
                    SelectedDays += "," + Saturday;

                }

                employee.Off_Days_Names = SelectedDays;



                employee.Mobile = dataa.txtEmployee_Phone2;
                employee.NTN_No = dataa.txtEmployee_NTN_No;
                employee.Email = dataa.txtEmployee_Email;
                employee.DOJ = Convert.ToDateTime(dataa.txtEmployee_DOJ);
                if (!string.IsNullOrEmpty(dataa.txtStartDate))
                {
                    employee.st_day = Convert.ToDateTime(dataa.txtStartDate);
                }
                else
                {
                    employee.st_day = null;
                }
                if (!string.IsNullOrEmpty(dataa.txtEndDate))
                {
                    employee.end_day = Convert.ToDateTime(dataa.txtEndDate);
                }
                else
                {
                    employee.end_day = null;
                }
                employee.Account_ID = accountID;


                if (dataa.txtConsultant_Charges == "")
                    dataa.txtConsultant_Charges = "0";
                employee.Consultant_Charges = Convert.ToDecimal(dataa.txtConsultant_Charges);

                if (dataa.txtDoctorShare == "")
                    dataa.txtDoctorShare = "0";
                employee.Doctor_Amount = Convert.ToDecimal(dataa.txtDoctorShare);

                if (dataa.txtEmployee_Resign != "")
                    employee.Resign_Date = Convert.ToDateTime(dataa.txtEmployee_Resign);
                if (dataa.txtGrossPay == "")
                    dataa.txtGrossPay = "0.00";
                employee.Gross_Pay = Convert.ToDecimal(dataa.txtGrossPay);
                employee.Remarks = dataa.txtRemarks;
                if (dataa.txtHospital_Share == "")
                    dataa.txtHospital_Share = "0";
                employee.Hospital_Amount = Convert.ToDecimal(dataa.txtHospital_Share);

                employee.Panel_Rate = dataa.txtPanelAmount;

                if (dataa.isDoc)
                    employee.IsDoctor = Convert.ToBoolean(true);
                else
                    employee.IsDoctor = false;

                if (dataa.isVisiting)
                    employee.IS_Visting = Convert.ToBoolean(true);
                else
                    employee.IS_Visting = false;

                if (dataa.IsEmployee)
                    employee.is_Employee = Convert.ToBoolean(true);
                else
                    employee.is_Employee = false;

                if (dataa.BlockCategory)
                    employee.Block_category = Convert.ToBoolean(true);
                else
                    employee.Block_category = false;

                if (dataa.buttonVal == "Save")
                {
                    employee.Created_By = AppConfig.UserID;
                    employee.Created_Time = DateTime.Now;
                    employee.Book_ID = AppConfig.Book_ID;
                    employee.Company_ID = AppConfig.Company_ID;

                    db.HR_Employees.InsertOnSubmit(employee);
                    dataa.lblMessage = "Data Inserted Successfully";
                }
                else

                {
                    dataa.lblMessage = "Data Updated Successfully";
                }
                db.SubmitChanges();
               




            }


            catch (Exception ex)
            {
                return ex.Message;
            }
            return "Saved Successfully!";
        }

        [WebMethod]
        public static string LoadNewAccountToCreate()
        {
            string sql = "";
            string[] accountLength;
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            sys_Parm AccountPram = new sys_Parm();
            AccountPram = (from tbl in db.sys_Parms
                           where tbl.Name == "Consultant Payables"

                           select tbl).FirstOrDefault();
            if (AccountPram != null && AccountPram.Code != null)
            {
                GL_Account account = new GL_Account();

                var tbl = (from config in db.Configurations
                           where config.Configuration_Name == "Chart of Accounts Level"
                           select config).SingleOrDefault();
                accountLength = tbl.Configuration_Value.Split(',');
                sql = "Select account_id from gl_Accounts where Account_Code='" + AccountPram.Code + "' and Book_ID=" + AppConfig.Book_ID;
                string value = DBClass.getField(sql);
                var NewhdfParent_Code = "";
                if (value == "There is no row at position 0.")
                {
                    NewhdfParent_Code = AccountPram.Code.ToString();
                }
                else
                {
                    NewhdfParent_Code = value;
                }

                sql = "Select isNUll(MAX(Convert(int, Account_Serial)),0) from gl_accounts where parent_code=" + value;
                string maxcode = DBClass.getField(sql);
                int newcode = Convert.ToInt32(maxcode);
                newcode += 1;
                string newAccountcode = newcode.ToString("000");
                var NewhdfAccount_Code = AccountPram.Code + newAccountcode;
                var NewhdfAccount_Serial = newAccountcode;
                var NewhdfLevel = "4";

                var result = new
                {
                    NewhdfParent_Code,
                    NewhdfAccount_Code,
                    NewhdfAccount_Serial,
                    NewhdfLevel,

                };


                JavaScriptSerializer js = new JavaScriptSerializer();
                return js.Serialize(result);
            }
            else
            {
                var Newlblmessage = "Please assign Customers account in sys_Params table.";
                var result = new
                {
                    Newlblmessage,

                };


                JavaScriptSerializer js = new JavaScriptSerializer();
                return js.Serialize(result);
            }

        }

        public class EmployeeData
        {
            public string buttonVal { get; set; }
            public string txtEmployeeID { get; set; }
            public string txtEmployee_Name { get; set; }
            public string txtFather_Name { get; set; }
            public string txtEmployee_Date_of_Birth { get; set; }
            public string txtPanelAmount { get; set; }
            public string ddlPatientType { get; set; }
            public string ddlDepartment { get; set; }
            public int ddlPolicy { get; set; }
            public string ddlDesignation { get; set; }
            public string txtEmployee_Phone2 { get; set; }
            public string txtEmployee_Phone1 { get; set; }
            public string txtEmployee_Email { get; set; }
            public string txtPatient_Time { get; set; }
            public TimeSpan TxtTime_In { get; set; }
            public TimeSpan TxtTime_Out { get; set; }
            public string txtEmployee_NTN_No { get; set; }
            public string ddlRoom { get; set; }
            public string txtEmployee_DOJ { get; set; }
            public string txtStartDate { get; set; }
            public string txtEndDate { get; set; }
            public string txtEmployee_Resign { get; set; }
            public string ddlFloor { get; set; }
            public string txtDoctorShare { get; set; }
            public string txtHospital_Share { get; set; }
            public string Ext_txt { get; set; }
            public string txtGrossPay { get; set; }
            public string txtConsultant_Charges { get; set; }
            public string ddlDoctorBuilding { get; set; }
            public string txtEmployee_Address { get; set; }
            public string txtRemarks { get; set; }
            public string ddluser { get; set; }
            public string txtdependent { get; set; }
            public string txtdoc_qualification { get; set; }
            public bool isSun { get; set; }
            public bool isMon { get; set; }
            public bool isTue { get; set; }
            public bool isWed { get; set; }
            public bool isThur { get; set; }
            public bool isFri { get; set; }
            public bool isSat { get; set; }
            public bool isDoc { get; set; }
            public bool isVisiting { get; set; }
            public bool IsEmployee { get; set; }
            public bool BlockCategory { get; set; }
            public string hdfAccount_ID { get; set; }
            public string hdfParent_Code { get; set; }
            public string hdfAccount_Serial { get; set; }
            public string hdfLevel { get; set; }
            public string hdfAccount_Code { get; set; }
            public string txtGovt_Hospital { get; set; }
            public string hdnEmp { get; set; }
            public string lblMessage { get; set; }
            public string CustomerJSON { get; set; }
        }
    }
}