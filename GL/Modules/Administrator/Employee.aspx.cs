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

namespace PMS
{
    public partial class Employee : System.Web.UI.Page
    {
        DataBaseDataContext db;
        protected void Page_Load(object sender, EventArgs e)
        {
            

            if (!IsPostBack)
            {
                BindDropDownList();
                txtEmployee_Date_of_Birth.Text = DateTime.Now.ToString(AppConfig.DateFormat);
                txtEmployee_DOJ.Text = DateTime.Now.ToString(AppConfig.DateFormat);
                if (Request.QueryString["ID"] != null)
                {
                    PopulateEmployeeData(Convert.ToInt32(Request.QueryString["ID"]));
                }
                else
                    txtEmployeeID.Text = "(New)";

            }
        }

        private void BindDropDownList()
        {
            object valueset;

            valueset = DBClass.GetValueSet("Patient Main Category");
            ddlDepartment.DataSource = valueset;
            ddlDepartment.DataTextField = "DataValue_Description";
            ddlDepartment.DataValueField = "DataValue_Name";
            ddlDepartment.Items.Add(new ListItem("Please Select", "0"));
            ddlDepartment.DataBind();

            valueset = DBClass.GetValueSet("Doctor Building");
            ddlDoctorBuilding.DataSource = valueset;
            ddlDoctorBuilding.DataTextField = "DataValue_Description";
            ddlDoctorBuilding.DataTextField = "DataValue_Description";
            ddlDoctorBuilding.DataValueField = "DataValue_Name";
            ddlDoctorBuilding.Items.Add(new ListItem("Please Select", "0"));
            ddlDoctorBuilding.DataBind();

            valueset = DBClass.GetValueSet("Designation");
            ddlDesignation.DataSource = valueset;
            ddlDesignation.DataTextField = "DataValue_Description";
            ddlDesignation.DataValueField = "DataValue_Name";
            ddlDesignation.Items.Add(new ListItem("Please Select", "0"));
            ddlDesignation.DataBind();

            valueset = DBClass.GetValueSet("Patient Type");
            ddlPatientType.DataSource = valueset;
            ddlPatientType.DataTextField = "DataValue_Description";
            ddlPatientType.DataValueField = "DataValue_Name";
            ddlPatientType.Items.Add(new ListItem("Please Select", "0"));
            ddlPatientType.DataBind();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var roomList = (from tbl in db.Rooms
                               
                            where tbl.OPDRoom == true
                            select new
                            {
                                Room_No = tbl.Room_No.ToString(),
                                Location = db.GetDataValueName("Building Type", tbl.Location),
                            }).ToList();
            ddlRoom.DataSource = roomList;
            ddlRoom.DataTextField = "Room_No";
            ddlRoom.DataValueField = "Room_No";
            ddlRoom.Items.Add(new ListItem("Please Select", "0"));
            ddlRoom.DataBind();
            ddlRoom.ClearSelection();




            var ddlusers = (from tbl in db.aspnet_Users
                            select new
                            {
                                UserId = tbl.UserId.ToString(),
                                UserName = tbl.UserName.ToString(),
                            }).ToList();
            ddluser.DataSource = ddlusers;
            ddluser.DataTextField = "UserName";
            ddluser.DataValueField = "UserId";
            ddluser.Items.Add(new ListItem("Please Select", "0"));
            ddluser.DataBind();


            valueset = DBClass.GetValueSet("Building Type");

            ddlFloor.DataSource = valueset;
            ddlFloor.DataTextField = "DataValue_Description";
            ddlFloor.DataValueField = "DataValue_Name";
            ddlFloor.Items.Add(new ListItem("Please Select", "0"));
            ddlFloor.DataBind();
        }

        private void PopulateEmployeeData(int Emp_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            HR_Employee employee = (from tbl in db.HR_Employees
                                    where tbl.Emp_ID == Emp_ID
                                    select tbl).FirstOrDefault();
            if (employee != null)
            {
                txtEmployeeID.Text = employee.Emp_ID.ToString();
                txtEmployeeCode.Text = employee.Emp_No;
                txtEmployee_Name.Text = employee.Emp_Name;
                txtdependent.Text = employee.Dependent;
                txtFather_Name.Text = employee.Father_Name;
                txtEmployee_Date_of_Birth.Text = employee.DOB.Value.ToString(AppConfig.DateFormat);
                ddlDepartment.SelectedValue = employee.Department;
                
                ddlDoctorBuilding.SelectedValue = employee.Doctor_Building;
                
                ddlDesignation.SelectedValue = employee.Designation;
                txtEmployee_Address.Text = employee.Address;
                txtEmployee_Phone1.Text = employee.Home_Phone;
                txtEmployee_Phone2.Text = employee.Mobile;

                txtGovt_Hospital.Text = employee.Govt_Hospital;
                ddlPatientType.SelectedValue = employee.Patient_Type;
                ddluser.SelectedValue = employee.userid;
                if (employee.Timings_In == null)
                {
                }
                else
                {
                    TxtTime_In.Text = employee.Timings_In.Value.ToString("hh:mm tt"); // "hh:mm:ss tt"
                }
                if (employee.Timings_Out == null)
                {
                }
                else
                {
                    TxtTime_Out.Text = employee.Timings_Out.Value.ToString("hh:mm tt");
                }
                txtPatient_Time.Text = employee.Patient_Time.ToString();
                if (employee.Room_No == null)
                {
                }
                else
                {
                    ddlRoom.SelectedValue = employee.Room_No.Value.ToString();
                }
                ddlFloor.SelectedValue = employee.Floor_No;
                Ext_txt.Text = employee.Extension_No;
                if (employee.Off_Days_Names == null)
                {

                }
                else
                {
                    if (employee.Off_Days_Names.Contains("Sun"))
                    {
                        sun.Checked = true;
                    }
                    if (employee.Off_Days_Names.Contains("Mon"))
                    {
                        mon.Checked = true;
                    }
                    if (employee.Off_Days_Names.Contains("Tue"))
                    {
                        tue.Checked = true;
                    }
                    if (employee.Off_Days_Names.Contains("Wed"))
                    {
                        wed.Checked = true;
                    }
                    if (employee.Off_Days_Names.Contains("Thu"))
                    {
                        thur.Checked = true;
                    }
                    if (employee.Off_Days_Names.Contains("Fri"))
                    {
                        fri.Checked = true;
                    }
                    if (employee.Off_Days_Names.Contains("Sat"))
                    {
                        sat.Checked = true;
                    }
                }
                txtEmployee_NTN_No.Text = employee.NTN_No;
                txtEmployee_Email.Text = employee.Email;
                txtEmployee_DOJ.Text = employee.DOJ.Value.ToString(AppConfig.DateFormat);
                if (employee.Account_ID != null)
                {
                    LoadGLAccount(employee.Account_ID);
                }
              
                txtDoctorShare.Text = employee.Doctor_Amount.ToString();
                txtHospital_Share.Text = employee.Hospital_Amount.ToString();

                if (employee.Resign_Date != null)
                    txtEmployee_Resign.Text = employee.Resign_Date.Value.ToString(AppConfig.DateFormat);
                txtGrossPay.Text = employee.Gross_Pay.ToString();
                txtRemarks.Text = employee.Remarks;
                ChkDoctor.Checked = employee.IsDoctor.HasValue ? Convert.ToBoolean(employee.IsDoctor) : false;

                ChkVisting.Checked = employee.IS_Visting.HasValue ? Convert.ToBoolean(employee.IS_Visting) : false;
                if (employee.Panel_Rate != null)
                    txtPanelAmount.Text = employee.Panel_Rate;

                
                txtConsultant_Charges.Text = employee.Consultant_Charges.ToString();
                btnSave.Text = "Update";
            }
        }

        protected void btnGet_SubDepartment_Click(object sender, EventArgs e)
        {
            db = new DataBaseDataContext(DBClass.ConnectionString());

            

        }
        private void LoadGLAccount(int? AccountID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var qury = (from a in db.GL_Accounts
                        where a.Account_ID == AccountID
                        select a).FirstOrDefault();
            if (qury != null)
            {
                hdfAccount_Serial.Value = qury.Account_Serial;
                hdfLevel.Value = qury.Levels.ToString();
                hdfParent_Code.Value = qury.Parent_Code.ToString();
                hdfAccount_Code.Value = qury.Account_Code;
                hdfAccount_Name.Value = qury.Account_Name;
                hdfAccount_ID.Value = qury.Account_ID.ToString();
                txtAccount_Code_Name.Text = qury.Account_Code + " - " + qury.Account_Name;
            }
        }
        private void LoadNewAccountToCreate()
        {
            string sql = "";
            string[] accountLength;
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            sys_Parm AccountPram = new sys_Parm();
            AccountPram = (from tbl in db.sys_Parms
                           where tbl.Name == "Doctors Payable"
                          
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
                if (value == "There is no row at position 0.")
                {
                    hdfParent_Code.Value = AccountPram.Code.ToString();
                }
                else
                    hdfParent_Code.Value = value;
                sql = "Select isNUll(MAX(Convert(int, Account_Serial)),0) from gl_accounts where parent_code=" + value;
                string maxcode = DBClass.getField(sql);
                int newcode = Convert.ToInt32(maxcode);
                newcode += 1;
                string newAccountcode = newcode.ToString("000");
                hdfAccount_Code.Value = AccountPram.Code + newAccountcode;
                hdfAccount_Serial.Value = newAccountcode;
                hdfLevel.Value = "4";
            }
            else
            {
                lblMessage.Text = "Please assign Customers account in sys_Params table.";
                lblMessage.CssClass = "errorMessage";
            }
        }
        [WebMethod]
        public static bool saveData(string id, string[][] Data)
        {
            bool status = false;
            DataBaseDataContext db = new DataBaseDataContext();
            for (int i = 0; i < Data.Length; i++)
            {
                if (Data[i] != null)
                {
                    Test_Defination_Detail_Rate tdr = new Test_Defination_Detail_Rate();
                    tdr.Test_ID = Convert.ToInt32(id);
                    tdr.Patient_Type = "Panel";
                    tdr.Patient_Category = Data[i][0].ToString();
                    tdr.Test_Rate = Convert.ToInt32(Data[i][1]);
                    tdr.isGroupTest = false;
                    tdr.Created_By = AppConfig.UserID.ToString();
                    tdr.Created_Time = System.DateTime.Now;

                    db.Test_Defination_Detail_Rates.InsertOnSubmit(tdr);
                    db.SubmitChanges();
                }
                status = true;
            }

            return status;
        }
        [WebMethod]
        public static string Getusers()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.aspnet_Users
                             
                              select new
                              {
                                  dv.UserId,
                                  dv.UserName
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }
        [WebMethod]
        public static string GetPanel()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var panel = (from tbl in db.Panels

                             select tbl).ToList();

                return (new JavaScriptSerializer()).Serialize(panel);
            }
        }
        [WebMethod]
        public static string LoadPanel(string Id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var panel = (from tbl in db.Test_Defination_Detail_Rates
                             where tbl.Test_ID == Convert.ToInt32(Id) && tbl.Patient_Type == "Panel"
                             select tbl).ToList();

                return (new JavaScriptSerializer()).Serialize(panel);
            }

        }
        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                string customerJSON = Request.Form["CustomerJSON"];

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
                if (btnSave.Text == "Save")
                {
                    employee = new HR_Employee();

                    employee.Emp_No = DBClass.GetNewNumber("Emp_No", "HR_Employees", "").ToString();
                }
                else
                {
                    employee = (from tbl in db.HR_Employees
                                where tbl.Emp_ID == Convert.ToInt32(txtEmployeeID.Text)
                                select tbl).FirstOrDefault();

                    employee.Updated_By = AppConfig.UserID;
                    employee.Updated_Time = DateTime.Now;

                }
                if (hdfAccount_ID.Value != "")
                {
                    accountID = Convert.ToInt32(hdfAccount_ID.Value);
                    accounts = (from tbl in db.GL_Accounts
                                where tbl.Account_ID == accountID
                                select tbl).FirstOrDefault();
                    accounts.Account_Name = txtEmployee_Name.Text;
                    db.SubmitChanges();
                }
                else
                {
                    LoadNewAccountToCreate();
                    if (hdfParent_Code.Value == "")
                        return;
                    accounts.Account_Name = txtEmployee_Name.Text;
                    accounts.Account_Code = hdfAccount_Code.Value;
                    accounts.Parent_Code = Convert.ToInt32(hdfParent_Code.Value);
                    accounts.Levels = Convert.ToInt32(hdfLevel.Value);
                    accounts.Account_Serial = hdfAccount_Serial.Value;
                    accounts.Active = true;
                    accounts.Book_ID = AppConfig.Book_ID;
                    db.GL_Accounts.InsertOnSubmit(accounts);
                    db.SubmitChanges();
                    accountID = accounts.Account_ID;
                }

                employee.Emp_Name = txtEmployee_Name.Text;
                employee.Father_Name = txtFather_Name.Text;
                employee.DOB = Convert.ToDateTime(txtEmployee_Date_of_Birth.Text);
                employee.Department = ddlDepartment.SelectedValue;
                employee.userid = Convert.ToString(ddluser.SelectedValue);
                employee.Designation = ddlDesignation.SelectedValue;
                employee.Address = txtEmployee_Address.Text;
                employee.Home_Phone = txtEmployee_Phone1.Text;
                employee.Govt_Hospital = txtGovt_Hospital.Text;
                employee.Patient_Type = ddlPatientType.SelectedValue;
                employee.Dependent = txtdependent.Text;
             

                if (!string.IsNullOrEmpty(TxtTime_In.Text))
                {
                    employee.Timings_In = Convert.ToDateTime(TxtTime_In.Text);
                }

                if (!string.IsNullOrEmpty(TxtTime_Out.Text))
                {
                    employee.Timings_Out = Convert.ToDateTime(TxtTime_Out.Text);
                }

                if (!string.IsNullOrEmpty(txtPatient_Time.Text.Trim()))
                    employee.Patient_Time = Convert.ToInt32(txtPatient_Time.Text);


                employee.Doctor_Building = ddlDoctorBuilding.SelectedValue;
               
                employee.Room_No = ddlRoom.SelectedItem == null ? 0 : Convert.ToInt32(ddlRoom.SelectedItem.Value);
              
                employee.Floor_No = ddlFloor.SelectedValue;
                employee.Extension_No = Ext_txt.Text;

                if (sun.Checked == true)
                {
                    SelectedDays = Sunday;
                   
                }

                if (mon.Checked == true)
                {
                    SelectedDays += "," + Monday;

                }
                if (tue.Checked == true)
                {
                    SelectedDays += "," + Tuesday;

                }
                if (wed.Checked == true)
                {
                    SelectedDays += "," + Wednesday;

                }

                if (thur.Checked == true)
                {
                    SelectedDays += "," + Thursday;

                }
                if (fri.Checked == true)
                {
                    SelectedDays += "," + Friday;

                }
                if (sat.Checked == true)
                {
                    SelectedDays += "," + Saturday;

                }

                employee.Off_Days_Names = SelectedDays;



                employee.Mobile = txtEmployee_Phone2.Text;
                employee.NTN_No = txtEmployee_NTN_No.Text;
                employee.Email = txtEmployee_Email.Text;
                employee.DOJ = Convert.ToDateTime(txtEmployee_DOJ.Text);
                employee.Account_ID = accountID;


                if (txtConsultant_Charges.Text == "")
                    txtConsultant_Charges.Text = "0";
                employee.Consultant_Charges = Convert.ToDecimal(txtConsultant_Charges.Text);

                if (txtDoctorShare.Text == "")
                    txtDoctorShare.Text = "0";
                employee.Doctor_Amount = Convert.ToDecimal(txtDoctorShare.Text);

                if (txtEmployee_Resign.Text != "")
                    employee.Resign_Date = Convert.ToDateTime(txtEmployee_Resign.Text);
                if (txtGrossPay.Text == "")
                    txtGrossPay.Text = "0.00";
                employee.Gross_Pay = Convert.ToDecimal(txtGrossPay.Text);
                employee.Remarks = txtRemarks.Text;
                if (txtHospital_Share.Text == "")
                    txtHospital_Share.Text = "0";
                employee.Hospital_Amount = Convert.ToDecimal(txtHospital_Share.Text);

                employee.Panel_Rate = txtPanelAmount.Text;

                if (ChkDoctor.Checked)
                    employee.IsDoctor = Convert.ToBoolean(true);
                else
                    employee.IsDoctor = false;

                if (ChkVisting.Checked)
                    employee.IS_Visting = Convert.ToBoolean(true);
                else
                    employee.IS_Visting = false;

                if (btnSave.Text == "Save")
                {
                    employee.Created_By = AppConfig.UserID;
                    employee.Created_Time = DateTime.Now;
                    employee.Book_ID = AppConfig.Book_ID;
                    employee.Company_ID = AppConfig.Company_ID;

                    db.HR_Employees.InsertOnSubmit(employee);
                    lblMessage.CssClass = "Data Inserted Successfully";
                }
                else

                {
                    lblMessage.CssClass = "Data Updated Successfully";
                }
                db.SubmitChanges();
                hdnEmp.Value = employee.Emp_ID.ToString();

                DataTable data = JsonConvert.DeserializeObject<DataTable>(customerJSON);
                var Query = db.Test_Defination_Detail_Rates.Where(t => t.Test_ID == Convert.ToInt32(hdnEmp.Value) && t.Patient_Type == "Panel").ToList();
                if (Query.Count > 0)
                {
                    db.Test_Defination_Detail_Rates.DeleteAllOnSubmit(Query);
                    db.SubmitChanges();
                }
                

                for (int i = 0; i < data.Rows.Count; i++)
                {

                    Test_Defination_Detail_Rate s = new Test_Defination_Detail_Rate();
                    s.Test_ID = Convert.ToInt32(hdnEmp.Value);
                    s.Patient_Category = Convert.ToString(data.Rows[i].ItemArray[0]);
                    s.Test_Rate = Convert.ToInt32(data.Rows[i].ItemArray[1]);
                    s.Patient_Type = "Panel";
                    s.Created_By = AppConfig.UserID.ToString();
                    s.Created_Time = DateTime.Now;

                    db.Test_Defination_Detail_Rates.InsertOnSubmit(s);
                    db.SubmitChanges();
                }

             
                Response.Redirect("~/Modules/Administrator/Employee.aspx", false);
            }


            catch (Exception ex)
            {
                throw ex;
            }
        }



    }
}