using CrystalDecisions.CrystalReports.Engine;
using CrystalDecisions.Shared;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Drawing.Printing;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using System.Web.Script.Serialization;

namespace PMS
{
    public partial class WebForm9 : System.Web.UI.Page
    {
        DataBaseDataContext db = new DataBaseDataContext();

        public bool IsPatientRevisit = false;
        public string IsDublicate = "0";

        protected void Page_Load(object sender, EventArgs e)
        {


            if (!IsPostBack)
            {
                DBClass.executeNonQueryWithoutBegin("delete patients where Full_Name is null");
                Session["Dublicate"] = "0";
                BindingDropDown();
            
                trGeneral.Visible = false;

                TimeSpan time = DateTime.Now.TimeOfDay;
               
                if (time > new TimeSpan(08, 00, 00)       
                 && time < new TimeSpan(13, 59, 59))
                {
                    txtRegistration_Fee.Text = "100";
                    hdnregisterfee.Value = "100";
                }

                else
                {
                    txtRegistration_Fee.Text = "100";
                    hdnregisterfee.Value = "100";
                }
                var apt_id = Request.QueryString["apt_id"];
                var opd_id = Request.QueryString["opd_id"];
                if (apt_id == "undefined")
                {
                    apt_id = "0";
                }
                if (Request.QueryString["ID"] != null)
                {
                    FillPatientForm(Convert.ToInt32(Request.QueryString["ID"]), Convert.ToInt32(apt_id), Convert.ToInt32(opd_id));
                }
            }


            selected_tabs.Value = Request.Form[selected_tabs.UniqueID];
            if (HttpContext.Current.Session["UserID"] != null)
                btnSave.Enabled = Convert.ToBoolean(DBClass.getField("select dbo.GetRights('AllowPatientEdit','" + AppConfig.UserID + "')"));
        }

        private void studentDetail(bool visible)
        {

        }

        private void employeeDetail(bool visible)
        {

        }

        private void discountDetail(bool visible)
        {

        }
        protected void btnGet_Doctor_Click(object sender, EventArgs e)
        {
            db = new DataBaseDataContext(DBClass.ConnectionString());
            List<HR_Employee> EmpList = new List<HR_Employee>();
            EmpList = (from tbl in db.HR_Employees
                       where (tbl.Department == ddlPatient_Main_Category.SelectedValue)
                       select tbl).ToList();
            ddlDoctorName.Items.Clear();
            ddlDoctorName.DataSource = EmpList;
            ddlDoctorName.DataTextField = "Emp_Name";
            ddlDoctorName.DataValueField = "Emp_ID";
            ddlDoctorName.Items.Add(new ListItem("Please Select", "0"));
            ddlDoctorName.DataBind();

            ddlDoctorName.Visible = true;
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
        public static string loadRegistrationFees(string Doc)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var doc = (from emp in db.HR_Employees
                       where emp.Emp_ID == Convert.ToInt32(Doc) && emp.IsDoctor == true
                       select new { Amount = emp.Doctor_Amount + emp.Hospital_Amount }).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(doc);
        }  
        [WebMethod]
        public static string loadDpt(string doc)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var doct = (from emp in db.HR_Employees
                       where emp.Emp_ID == Convert.ToInt32(doc) && emp.IsDoctor == true
                       select new {emp.Department}).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(doct);
        }
        private void BindingDropDown()
        {
            object valueset;


            DataTable dtPanel = DBClass.getDataTable("Select Panel_ID,Company_Name from Panel");
            ddlPanelCompany.DataSource = dtPanel;

            ddlPanelCompany.DataTextField = "Company_Name";
            ddlPanelCompany.DataValueField = "Panel_ID";
            ddlPanelCompany.Items.Add(new ListItem("Please Select", "0"));
            ddlPanelCompany.DataBind();

            valueset = DBClass.GetValueSet("Gender");
            ddlGender.DataSource = valueset;
            ddlGender.DataTextField = "DataValue_Description";
            ddlGender.DataValueField = "DataValue_Name";
            ddlGender.Items.Add(new ListItem("Please Select", "0"));
            ddlGender.DataBind();

            valueset = DBClass.GetValueSet("Filter Clinic");
            ddlFilterClininc.DataSource = valueset;
            ddlFilterClininc.DataTextField = "DataValue_Description";
            ddlFilterClininc.DataValueField = "DataValue_Name";
            
            ddlFilterClininc.DataBind();

            valueset = DBClass.GetValueSet("Casher");
            ddlcaher.DataSource = valueset;
            ddlcaher.DataTextField = "DataValue_Description";
            ddlcaher.DataValueField = "DataValue_Name";
            ddlcaher.Items.Add(new ListItem("Please Select", "0"));
            ddlcaher.DataBind();




            valueset = DBClass.GetValueSet("Mode Of Registration");
            ddlMode_Of_Registration.DataSource = valueset;
            ddlMode_Of_Registration.DataTextField = "DataValue_Description";
            ddlMode_Of_Registration.DataValueField = "DataValue_Name";
            //ddlMode_Of_Registration.Items.Add(new ListItem("Please Select", "0"));
            ddlMode_Of_Registration.DataBind();


            valueset = DBClass.GetValueSet("Patient Main Category");
            ddlPatient_Main_Category.DataSource = valueset;
            ddlPatient_Main_Category.DataTextField = "DataValue_Description";
            ddlPatient_Main_Category.DataValueField = "DataValue_Name";
            ddlPatient_Main_Category.Items.Add(new ListItem("Please Select", "0"));
            ddlPatient_Main_Category.DataBind();

            valueset = DBClass.GetValueSet("Marital Status");
            ddlMarital_Status.DataSource = valueset;
            ddlMarital_Status.DataTextField = "DataValue_Description";
            ddlMarital_Status.DataValueField = "DataValue_Name";
            ddlMarital_Status.Items.Add(new ListItem("Please Select", "0"));
            ddlMarital_Status.DataBind();






            valueset = DBClass.GetValueSet("Patient Type");
            ddlPatient_Type.DataSource = valueset;
            ddlPatient_Type.DataTextField = "DataValue_Description";
            ddlPatient_Type.DataValueField = "DataValue_Name";

            ddlPatient_Type.DataBind();




            valueset = DBClass.GetValueSet("Province");

            valueset = DBClass.GetValueSet("District");
            ddlDistrict.DataSource = valueset;
            ddlDistrict.DataTextField = "DataValue_Description";
            ddlDistrict.DataValueField = "DataValue_Name";
            ddlDistrict.Items.Add(new ListItem("Please Select", "0"));
            ddlDistrict.DataBind();

            valueset = DBClass.GetValueSet("General Category");
            ddlGeneral_Category.DataSource = valueset;
            ddlGeneral_Category.DataTextField = "DataValue_Description";
            ddlGeneral_Category.DataValueField = "DataValue_Name";
            ddlGeneral_Category.Items.Add(new ListItem("Please Select", "0"));
            ddlGeneral_Category.DataBind();

        

            db = new DataBaseDataContext(DBClass.ConnectionString());
            List<HR_Employee> Doctors = new List<HR_Employee>();
            Doctors = (from tbl in db.HR_Employees
                       where tbl.IsDoctor == true
                       select tbl).ToList();




            db = new DataBaseDataContext(DBClass.ConnectionString());
            List<HR_Employee> DoctorName = new List<HR_Employee>();
            DoctorName = (from tbl in db.HR_Employees

                          select tbl).ToList();

            ddlDoctorName.DataSource = DoctorName;
            ddlDoctorName.DataTextField = "Emp_Name";
            ddlDoctorName.DataValueField = "Emp_ID";
            ddlDoctorName.Items.Add(new ListItem("Please Select", "0"));
            ddlDoctorName.DataBind();


        }

        public static Int32 GetGLPatientAccount(string Patient_Type, string Patient_Department)
        {

            DataBaseDataContext db = new DataBaseDataContext();
            if (Patient_Type != "02")
            {
                var GeneralAccount = (from acc in db.GL_Accounts
                                      join sys in db.sys_Parms on acc.Account_Code equals sys.Code
                                      where sys.Segment1 == Patient_Department
                                      && sys.Segment2 == "01"
                                      && sys.Segment3 == "Is Income Account"
                                      select acc).FirstOrDefault();
                return GeneralAccount.Account_ID;
            }
            else
            {

                var PrivateAccount = (from acc in db.GL_Accounts
                                      join sys in db.sys_Parms on acc.Account_Code equals sys.Code
                                      where sys.Segment1 == Patient_Department
                                      && sys.Segment2 == Patient_Type
                                      && sys.Segment3 == "Is Income Account"
                                      select acc).FirstOrDefault();
                return PrivateAccount.Account_ID;
            }
        }



        private void FillPatientForm(int PatientID, int apt_id,int opd_id)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            DBClass.executeNonQueryWithoutBegin("delete patients where Full_Name is null");
            hdnPatientID.Value = PatientID.ToString();
            hdnVoucherID.Value = "";
 

            Patient pat = db.Patients.Where(p => p.Patient_ID == PatientID).FirstOrDefault();
            Out_Patient opd = db.Out_Patients.Where(out_p => out_p.Out_Patient_ID == opd_id).FirstOrDefault();

           
            if (pat == null)
            {
                Reg_patient reg_pat = db.Reg_patients.Where(p => p.pat_id == PatientID).FirstOrDefault();
                txtPatient_ID.Text = Convert.ToString(reg_pat.pat_id);
                txtFather_Name.Text = reg_pat.Father_Name;
                txtPatient_NIC.Text = reg_pat.NIC;
                txtPatientNo.Text = reg_pat.Patient_No.ToString();
                txtAge_years.Text = reg_pat.Age_years.ToString();
             
                txtPatientNo.Text = Convert.ToString(reg_pat.mr_no_sequence);
                txt_reg_patno.Text = Convert.ToString(reg_pat.Patient_No);
                txtFull_Name.Text = reg_pat.Full_Name;
                txtPermanent_Address.Text = "H# " + reg_pat.House_No  +" " + reg_pat.stno_mno  + " " + reg_pat.area + " " +reg_pat.city ;
              
                txtMobile1.Text = reg_pat.Mobile1;
                ddlMarital_Status.SelectedValue = reg_pat.Martial_Status;
                ddlGender.SelectedValue = reg_pat.Gender;
                hdnAptId.Value = Convert.ToString(apt_id);
                var a = reg_pat.Created_time;
               
                var opd_time = (from patient in db.Patients
                                where patient.Reg_PatId == PatientID orderby patient.Patient_ID descending
                                select patient.Created_Time).FirstOrDefault();
               
                if (opd_time != null)
                {
                    
                    DateTime currentTimeRounded = DateTime.Now.Date;
                    DateTime createdTimeRounded = opd_time.Value.Date;

                
                    TimeSpan daysSinceCreation = currentTimeRounded - createdTimeRounded;
                    int numberOfDays = (int)daysSinceCreation.TotalDays;
                    lblNoOfDays.InnerText = Convert.ToString(numberOfDays);
                }

                var opd_time2 = (from patient in db.Patients
                                 where patient.Reg_PatId == PatientID
                                 orderby patient.Patient_ID descending
                                 select patient.Created_Time)
                 .Skip(1) 
                 .FirstOrDefault(); 


                if (opd_time2 != null)
                {
                    DateTime currentTimeRounded = DateTime.Now.Date;
                    DateTime createdTimeRounded = opd_time2.Value.Date;

                
                    TimeSpan daysSinceCreation = currentTimeRounded - createdTimeRounded;
                    int numberOfDays = (int)daysSinceCreation.TotalDays;
                    lblNoOfDays2.InnerText = Convert.ToString(numberOfDays);
                }
                else
                {
                    lblNoOfDays2.InnerText = Convert.ToString("0");
                }
               
                var doctorId = (from appointment in db.Appointment_Forms
                                where appointment.Appointment_ID == apt_id
                                select appointment.Consultant_ID).FirstOrDefault();

                if (doctorId != null)
                {
                    ddlDoctorName.SelectedValue = doctorId.ToString();
                }
                else
                {

                }


                var departmentid = (from appointment in db.Appointment_Forms
                                    where appointment.Appointment_ID == apt_id
                                    select appointment.Sub_Department).FirstOrDefault();

                if (departmentid != null)
                {
                    ddlPatient_Main_Category.SelectedValue = departmentid.ToString();
                }
                else
                {

                }

                var type = (from appointment in db.Appointment_Forms
                            where appointment.Appointment_ID == apt_id
                            select appointment.pat_type).FirstOrDefault();

                if (departmentid != null)
                {
                    ddlPatient_Type.SelectedValue = type.ToString();
                }
                else
                {

                }

            }
         
            if (opd != null)
            {
                Reg_patient reg_pat = db.Reg_patients.Where(p => p.pat_id == PatientID).FirstOrDefault();
                txtPatient_ID.Text = Convert.ToString(reg_pat.pat_id);
                txtFather_Name.Text = reg_pat.Father_Name;
                txtPatient_NIC.Text = reg_pat.NIC;
                txtPatientNo.Text = reg_pat.Patient_No.ToString();
                txtAge_years.Text = reg_pat.Age_years.ToString();
               
                txtPatientNo.Text = Convert.ToString(reg_pat.mr_no_sequence);
                txt_reg_patno.Text = Convert.ToString(reg_pat.Patient_No);
                txtFull_Name.Text = reg_pat.Full_Name;
                txtPermanent_Address.Text = reg_pat.Permanent_Address;
                txtMobile1.Text = reg_pat.Mobile1;
                ddlMarital_Status.SelectedValue = reg_pat.Martial_Status;
                ddlGender.SelectedValue = reg_pat.Gender;
                hdnAptId.Value = Convert.ToString(apt_id);


                
                var doctorId = (from Out_Patient in db.Out_Patients
                                where Out_Patient.Out_Patient_ID == opd_id
                                select Out_Patient.reffer_doc).FirstOrDefault();

                if (doctorId != null)
                {
                    ddlDoctorName.SelectedValue = doctorId.ToString();
                    hdnRffId.Value = Convert.ToString(opd_id);
                }
                else
                {

                }


                var departmentid = (from Out_Patient in db.Out_Patients
                                    where Out_Patient.Out_Patient_ID == opd_id
                                    select Out_Patient.Reffer_To).FirstOrDefault();

                if (departmentid != null)
                {
                    ddlPatient_Main_Category.SelectedValue = departmentid.ToString();
                }
                else
                {

                }

            }

            else
            {
                
                if (pat != null)
                {
                    txtPatient_ID.Text = Convert.ToString(pat.Reg_PatId);
                    if (pat.Full_Name.Contains("."))
                    {

                        var name_reg = (from reg in db.Reg_patients
                                        join pt in db.Patients on reg.pat_id equals pt.Reg_PatId
                                        where pt.Patient_ID == PatientID
                                        select reg.Full_Name).FirstOrDefault();

                        txtFull_Name.Text = name_reg.Split('.')[1];
                     
                     
                    }
                    else
                        txtFull_Name.Text = pat.Full_Name;

                    var f_name = (from reg in db.Reg_patients
                                    join pt in db.Patients on reg.pat_id equals pt.Reg_PatId
                                    where pt.Patient_ID == PatientID
                                    select reg.Father_Name).FirstOrDefault();


                    txtFather_Name.Text = f_name;
                    txtPatient_NIC.Text = pat.NIC;
                    txtPatientNo.Text = pat.mr_no_sequence.ToString();
                    if (txtBirth_Date.Text != "")
                    {
                        txtBirth_Date.Text = Convert.ToDateTime(pat.Birth_Date).ToString(AppConfig.DateFormat);
                    }
                    txtAge_years.Text = pat.Age_years.ToString();
                    ddlGender.SelectedValue = pat.Gender;
                    txtEmail_ID.Text = pat.Email;
                    txtdiscount.Text = Convert.ToString(pat.discount_amt);
                    txt_reg_patno.Text = Convert.ToString(pat.Patient_No);
                    ddlPanelCompany.SelectedValue = pat.Panel_Companies;
                    ddlFilterClininc.SelectedValue = pat.filter_clinic;
                    ddlcaher.SelectedValue = pat.Casher;
                   
                    ddlPatient_Main_Category.SelectedValue = pat.Patient_Main_Category;
                    txtAge_years.Text = pat.Age_years.ToString();
                    ddlMarital_Status.SelectedValue = pat.Marital_Status;
                    ddlMode_Of_Registration.SelectedValue = pat.Mode_Of_Registration;
                    txtPermanent_Address.Text = pat.Permanent_Address;
                    txt_opd_no.Text = Convert.ToString(pat.Opd_No);

                    txtRegistration_Fee.Text = Convert.ToString(Convert.ToInt32(pat.Receipt_Amount));
                    hdnregisterfee.Value = Convert.ToString(Convert.ToInt32(pat.Receipt_Amount));

                    if (pat.Patient_Type == "01")
                    {
                        trGeneral.Visible = true;
                       
                        if (pat.General_Category != null)
                        {
                            ddlGeneral_Category.SelectedValue = pat.General_Category;
                            if (pat.General_Category == "002")
                            {
                                studentDetail(true);
                                employeeDetail(false);
                                discountDetail(false);
                            }
                            else if (pat.General_Category == "003")
                            {
                                studentDetail(false);
                                employeeDetail(true);
                                discountDetail(false);
                            }

                            else
                            {
                                studentDetail(false);
                                employeeDetail(false);
                                discountDetail(false);
                            }
                        }
                        else
                        {
                            studentDetail(false);
                            employeeDetail(false);
                            discountDetail(false);
                        }
                    }
                    else if (pat.Patient_Type == "02")
                    {
                        ddlDoctorName.Visible = true;
                        ddlDoctorName.SelectedValue = pat.Doctor_ID;

                    }


                    if (pat.Mode_Of_Registration == "Emergency")
                       
                        txtPermanent_Address.Text = pat.Permanent_Address;

                
                    txtPhone.Text = pat.Phone;
                    txtMobile1.Text = pat.Mobile1;
                    txtMobile2.Text = pat.Mobile2;

                  
                    ddlDistrict.SelectedValue = pat.District;
               
                    ddlPatient_Type.SelectedValue = pat.Patient_Type;


              
                    btnSave.Text = "Update";
                    btnSaveAndPrint.Visible = false;
                  
                    hdnVoucherID.Value = pat.Voucher_ID.ToString();

                }
            }

        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;


            int Counter = 1;
            int patid = 0;
          
            string filterclininc = ddlFilterClininc.SelectedValue;
            string Doctor_Token = ddlDoctorName.SelectedValue;


            var Age = txtAge_years.Text.Trim();
            var DOB = txtBirth_Date.Text.Trim();

            if ((DOB != "" && Age != "") || (DOB == "" && Age == ""))
            { Response.Write("<script>alert('Plese provide DOB Or Age');</script>"); return; }

            if (ddlMode_Of_Registration.SelectedItem.Text != "Emergency")
            {
                if (ddlPatient_Type.SelectedValue == "0")
                { Response.Write("<script>alert('Plese Provide Patient Type');</script>"); return; }
            }
            if (ddlPatient_Type.SelectedValue == "10")
            {
                if (ddlPanelCompany.SelectedValue == "0")
                {
                    Response.Write("<script>alert('Please Select Panel Company');</script>"); return;

                }

            }
            if (ddlPatient_Type.SelectedItem.Text == "Private")
            {
                if (ddlDoctorName.SelectedValue == "0")
                    if (ddlDoctorName.SelectedValue == "0")
                    { Response.Write("<script>alert('Plese Provide Doctor Name');</script>"); return; }
            }
            if (ddlPatient_Type.SelectedItem.Text == "General")
            {
                if (ddlFilterClininc.SelectedValue == "0")
                    if (ddlFilterClininc.SelectedValue == "0")
                    { Response.Write("<script>alert('Plese Select Filter Clinic');</script>"); return; }
            }

            btnSave.Enabled = false;
            btnSaveAndPrint.Enabled = false;
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                DBClass.executeNonQueryWithoutBegin("delete patients where Full_Name is null");

                var sysParm = (from tbl in db.sys_Parms
                               where tbl.Name == "Patient Card No"
                               select tbl.Code).FirstOrDefault();

                Patient pat;
                if (btnSave.Text == "Save & Print")
                {
                    pat = new Patient();

                    pat.Opd_No = DBClass.getMaxEntry_No("Patients", "Opd_No");
                    pat.tokenNo = db.Patients.Where(p => p.Created_Time.Value.Year == DateTime.Now.Year
                                  && p.Created_Time.Value.Month == DateTime.Now.Month
                                  && p.Created_Time.Value.Day == DateTime.Now.Day
                                  && p.filter_clinic == filterclininc).Count() + 1;

                
                    if (Doctor_Token == "0")
                    {
                        pat.Doc_Token = 0;

                        pat.tokenNo = db.Patients.Where(p => p.Created_Time.Value.Year == DateTime.Now.Year
                                    && p.Created_Time.Value.Month == DateTime.Now.Month
                                    && p.Created_Time.Value.Day == DateTime.Now.Day
                                    && p.filter_clinic == filterclininc).Count() + 1;
                    }
                    else
                    {
                        pat.tokenNo = 0;
                        pat.Doc_Token = db.Patients.Where(p => p.Created_Time.Value.Year == DateTime.Now.Year
                                      && p.Created_Time.Value.Month == DateTime.Now.Month
                                      && p.Created_Time.Value.Day == DateTime.Now.Day
                                      && p.Doctor_ID == Doctor_Token).Count() + 1;
                    }
                 
                    var a = txt_doc_fee.Text;
                    pat.doc_share = txt_doc_fee.Text;
                    if(txtdiscount.Text == "")
                    {
                        txtdiscount.Text = "0";
                    }
                    else
                    {

                        pat.discount_amt = Convert.ToDecimal(txtdiscount.Text);
                    }

                }
                else
                {
                    pat = (from tbl in db.Patients
                           where tbl.Patient_ID == Convert.ToInt32(Request.QueryString["ID"])
                           select tbl).FirstOrDefault();

                    pat.Updated_By = AppConfig.UserID;
                    pat.Updated_Time = DateTime.Now;
                    if (txtdiscount.Text == "")
                    {
                        txtdiscount.Text = "0";
                    }
                    else
                    {

                        pat.discount_amt = Convert.ToDecimal(txtdiscount.Text);
                    }
                }
                
                pat.Full_Name = txtFull_Name.Text;
                pat.Reg_PatId = Convert.ToInt32(txtPatient_ID.Text);
                var ab = hdnRffId.Value;
                if(ab == "")
                {
                    hdnRffId.Value = null;

                }
                else
                {

                    pat.opd_doc_reffered = Convert.ToInt32(hdnRffId.Value);
                }
                pat.Father_Name = txtFather_Name.Text;   
                pat.mr_no_sequence = Convert.ToString(txtPatientNo.Text);
                pat.Gender = ddlGender.SelectedValue;
                pat.NIC = txtPatient_NIC.Text;
                pat.Patient_No = Convert.ToInt32(txt_reg_patno.Text);
                pat.Email = txtEmail_ID.Text;
                pat.Panel_Companies = ddlPanelCompany.SelectedValue;

                var filter = ddlFilterClininc.SelectedValue;
                if(filter != "0")
                {
                    pat.filter_clinic = ddlFilterClininc.SelectedValue;

                }
                else{
                    pat.Patient_Main_Category = ddlPatient_Main_Category.SelectedValue;

                }


                pat.Casher = ddlcaher.SelectedValue;
                var app_id = hdnAptId.Value;
                if (hdnAptId.Value == "0" )
                {
                    pat.appointment_id = 0;
                }
                else if (hdnAptId.Value == "")
                {
                    pat.appointment_id = 0;
                }
                else
                {
                    pat.appointment_id = Convert.ToInt32(app_id);
                }
                
                pat.Age_years = txtAge_years.Text;

                if (txtBirth_Date.Text != "")
                {
                    pat.Birth_Date = Convert.ToDateTime(txtBirth_Date.Text);
                    pat.Age_years = CalculateYourAge((DateTime)pat.Birth_Date);
                }
                pat.Marital_Status = ddlMarital_Status.SelectedValue;
               
                pat.Patient_Type = ddlPatient_Type.SelectedValue;
                pat.Mode_Of_Registration = ddlMode_Of_Registration.SelectedValue;
                

                if (ddlPatient_Type.SelectedValue == "01")
                {
                    var generalCategory = ddlGeneral_Category.SelectedValue;
                    pat.General_Category = generalCategory;

                    if (generalCategory == "001")
                    {
                    }
                    else if (generalCategory == "002")
                    {
                    }
                    else if (generalCategory == "003")
                    {
                        
                    }
                 
                }

                if (ddlPatient_Type.SelectedValue == "02")
                {
                    pat.Doctor_ID = ddlDoctorName.SelectedValue;
                }


                pat.District = ddlDistrict.SelectedValue;

                pat.Permanent_Address = txtPermanent_Address.Text;

                pat.Phone = txtPhone.Text;
                pat.Mobile1 = txtMobile1.Text;
                pat.Mobile2 = txtMobile2.Text;
                var filter_CLNC = ddlFilterClininc.SelectedValue;
                if (filter_CLNC != "0")
                {
                    pat.Receipt_Amount = Convert.ToInt32(txtRegistration_Fee.Text);
                    pat.free_check = false;

                }
                else
                {
                    pat.Receipt_Amount = Convert.ToInt32(hdnregisterfee.Value);
                    pat.free_check = false;
                }
               
                var checkfreepat = chckfreecheckup.Checked;
                if(checkfreepat == true)
                {
                    pat.Receipt_Amount = 0;
                    pat.free_check = true;
                }
               



                pat.Entry_Date = DateTime.Now;

                var IsFree = (from v in db.ValueSets
                              join d in db.DataValues
                              on v.ValueSet_ID equals d.ValueSet_ID
                              where v.ValueSet_Name == "Patient Type"
                              && ((d.DataValue_Description == "Student" && d.DataValue_Name == pat.Patient_Type) || (d.DataValue_Description == "Company" && d.DataValue_Name == pat.Patient_Type) || (d.DataValue_Description == "walk-In" && d.DataValue_Name == pat.Patient_Type) || (d.DataValue_Description == "walk-In" && d.DataValue_Name == pat.Patient_Type) || (d.DataValue_Description == "Employee" && d.DataValue_Name == pat.Patient_Type) || (d.DataValue_Name == "07" && d.DataValue_Name == pat.Patient_Type) || (d.DataValue_Name == "08" && d.DataValue_Name == pat.Patient_Type) || (d.DataValue_Name == "09" && d.DataValue_Name == pat.Patient_Type))
                              select d
                                 ).ToList();

             

                var IsPrivate = (from v in db.ValueSets
                                 join d in db.DataValues
                                 on v.ValueSet_ID equals d.ValueSet_ID
                                 where v.ValueSet_Name == "Patient Type"
                                 && (d.DataValue_Description == "Private" && d.DataValue_Name == pat.Patient_Type)
                                 select d
                ).ToList();



                var ReceiptCharges = (from d in db.DataValues
                                      join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID
                                      where v.ValueSet_Name == "Patient Main Category" && d.DataValue_Name == pat.Patient_Main_Category
                                      && (d.System_Value == false || d.System_Value == null)
                                      select d.Segment1).FirstOrDefault();

                var PrivateReceiptCharges = (from d in db.DataValues
                                             join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID
                                             where v.ValueSet_Name == "Patient Type" && d.DataValue_Name == pat.Patient_Type
                                             select d.Segment1).FirstOrDefault();


               
                if (btnSave.Text == "Save & Print")
                {
                    pat.Created_By = AppConfig.UserID;
                    pat.Created_Time = DateTime.Now;
                    pat.Book_ID = AppConfig.Book_ID;
                    pat.Company_ID = AppConfig.Company_ID;

                    var mr_no = txtPatientNo.Text;
                    pat.mr_no_sequence = Convert.ToString(txtPatientNo.Text);
                    var MrNo = (from data in db.Patients

                                where data.Patient_No == pat.Patient_No
                                && (data.IsRevisit == false || data.IsRevisit == null)


                                select data).ToList();
                    if (MrNo.Count > 0)
                    {
                        var P_N = DBClass.getField("select isnull(max(Patient_no), 0)  from Patients");
                        var pn = Convert.ToInt32(P_N) + 1; 
                     
                        pat.Patient_No = pn;


                    }

                    lblMessage.Text = "Data has been save sucessfully";

                    db.Patients.InsertOnSubmit(pat);
                }
                else
                {
                    lblMessage.Text = "Data has been update sucessfully";
                }

                {
                    lblMessage.CssClass = "sucessfullMessage";
                    db.SubmitChanges();
                    if (hdnAptId.Value == "")
                    {

                    }
                    else
                    {
                        DBClass.executeNonQueryWithoutBegin("update Appointment_Form set Status='Visited' where Appointment_ID=" + hdnAptId.Value);
                    }
                }
                var Patientno = pat.mr_no_sequence.ToString();


                string SMS_Contant = "عارف میموریل ٹیچنگ ہسپتال پر اعتماد کرنے کا شکریہ اب آپکا شناختی کارڈ ہی صحت کارڈ ہے۔اپنا اور اپنے خاندان کا فری علاج پروفیسرز ڈاکٹر کی زیرنگرانی کروائیں اور مریض کے فری کھانے کی سہولت بھی ہے۔ رابطہ نمبر-03138458018";
                string DocumentName = "PatientReg";
                string msg = "";
                string CellNumber = txtMobile1.Text;
                bool Send_Status = DBClass.sendSMS(CellNumber, SMS_Contant, out msg, DocumentName, Patientno);

                // SMS Configration End


                var count = (db.Patients.Where(v => v.mr_no_sequence == Convert.ToString(Patientno)).ToList());
                var Follow = count.Count;
                lblFollowNo.InnerHtml = Follow.ToString();
                patid = Convert.ToInt32(pat.Patient_ID);
                hdnPatientID.Value = pat.Patient_ID.ToString();

                txtPatient_ID.Text = pat.Patient_ID.ToString();

            }

            if (patid != 0)
            {
           

                string script = "window.open('ReportViewer.aspx?ReportName=PatientSlip&ReportTitle=OPD Slip&Patient_ID=" + patid + "','_blank');";
                script += "window.location.href = 'patients.aspx?ID=" + patid + "';";
                Page.ClientScript.RegisterStartupScript(this.GetType(), "OpenWindow", script, true);

            }

        }
        private void OpenReportAndRedirect(int patid)
        {
            string reportUrl = "/ReportViewer.aspx?ReportName=PatientSlip&ReportTitle=OPD Slip&Patient_ID=" + Server.UrlEncode(Convert.ToString(patid));
            string openWindowScript = "window.open('" + reportUrl + "', '_blank');";
            ScriptManager.RegisterStartupScript(this, typeof(string), "OPEN_WINDOW", openWindowScript, true);

          
        }


        public struct Receipt
        {
            public string ReceiptNo;
            public string PatientName;
            public string FatherName;
            public string ReceiptDate;
            public string Department;
            public string Operator;
            public string Marital_Status;
            public string Created_By;
            public string NIC;
            public string Age_years;
            public string PatientType;
            public string TokenNo;
            public string ReceiptCharges;
        }
        public class PatientDetail
        {
            public string Name;
            public string Title;

            public string Gender;
            public string Age;
            public DateTime DOB;

            public string Mobile;
            public string Address;

            public string Mr_No { get; set; }

            public string MaritalStatus { get; set; }

            public string FatherName { get; set; }

            public string Relation { get; set; }

            public string CNIC { get; set; }


            public string Reg_PatientID { get; set; }
            public string houseno { get; set; }
            public string city { get; set; }
            public string area { get; set; }
            public string val_area { get; set; }
            public string val_city { get; set; }
            public string strno { get; set; }




        }



        [WebMethod]
        public static bool CardFee(string Pat_idforCard)
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
                              where (itm.Patient_ID == int.Parse(Pat_idforCard))
                              select itm.Patient_ID).FirstOrDefault();
                var cardissue = (from itm in db.Patients
                                 where (itm.Patient_ID == int.Parse(Pat_idforCard))
                                 select itm.Card_Issued).FirstOrDefault();
                var receiptamount = (from itm in db.Patients
                                     where (itm.Patient_ID == int.Parse(Pat_idforCard))
                                     select itm.Card_Receipt_Amount).FirstOrDefault();
                var reprint = (from itm in db.Patients
                               where (itm.Patient_ID == int.Parse(Pat_idforCard))
                               select itm.cardReprint).FirstOrDefault();

                var totalRec = (Convert.ToInt32(sysParm) + Convert.ToInt32(receiptamount));
                var rep = Convert.ToInt32(reprint) + 1;
                if (bio_id != 0)
                {
                    if (cardissue == true)
                    {
                        DBClass.exectueQuery("update Patients set Card_Receipt_Amount = " + totalRec + " where Patient_ID =" + Pat_idforCard, tranObj, con);
                        DBClass.exectueQuery("UPDATE Patients SET cardReprint = " + rep + " where Patient_ID =" + Pat_idforCard, tranObj, con);
                    
                        tranObj.Commit();
                    }
                    else
                    {
                        DBClass.exectueQuery("update Patients set Card_Receipt_Amount = " + sysParm + " where Patient_ID =" + Pat_idforCard, tranObj, con);
                        DBClass.exectueQuery("UPDATE Patients SET Card_Issued = 1 where Patient_ID =" + Pat_idforCard, tranObj, con);
                        DBClass.exectueQuery("UPDATE Patients SET cardReprint = 1 where Patient_ID =" + Pat_idforCard, tranObj, con);
                      
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
        [WebMethod]
        public static PatientDetail GetEditPatientDetails(string Reg_Patient_ID)
        {
         
            PatientDetail pt = new PatientDetail();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Reg_patient pat = new Reg_patient();
            pat = (from tbl in db.Reg_patients
                   where tbl.pat_id == Convert.ToInt32(Reg_Patient_ID)
                   orderby tbl.Created_time descending
                   select tbl).FirstOrDefault();

            if (pat != null)
            {


                string[] PatientName = pat.Full_Name.Split('.');
                pt.Title = PatientName[0] + ".";
                pt.Name = PatientName[PatientName.Length - 1];
                pt.FatherName = pat.Father_Name;
                pt.Relation = pat.Relation_prefix;
                pt.Gender = pat.Gender;
                pt.DOB = Convert.ToDateTime(pat.DOB);
                pt.Age = pat.Age_years.ToString();
                pt.MaritalStatus = pat.Martial_Status;
            
                pt.Mr_No = Convert.ToString(pat.mr_no_sequence);
                pt.Address = pat.Permanent_Address;
                pt.Mobile = pat.Mobile1;
                pt.CNIC = pat.NIC;
                pt.Gender = pat.Gender;
                pt.houseno = pat.House_No;
                pt.area = pat.area;
                pt.strno = pat.stno_mno;
                pt.city = pat.city;
                pt.val_area = pat.val_area;
                pt.val_city = pat.val_city;
                pt.Reg_PatientID = Reg_Patient_ID;
                return pt;
            }


            return pt;
        }
        [WebMethod]
        public static string SavePatientDetail(string Full_Name, string RelationType, string Relation, string Gender, string Mobile, string Date_Of_Birth, string CNIC, string Address, string PatientID, string martail_status, string Age,string houseno,string stno,string city, string area,string city_val, string area_val , string Province,string Country)
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
                    pat.House_No = houseno;
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
                pat.Patient_No = DBClass.getMaxEntry_No("Reg_patient", "Patient_No");
              
                pat.Full_Name = Full_Name;
                pat.walkin = false;
                
                pat.Father_Name = Relation;
                pat.Relation_prefix = RelationType;
                pat.Gender = Gender;
                pat.Mobile1 = Mobile;
                pat.Age_years = Age;
                pat.DOB = Convert.ToDateTime(Date_Of_Birth);
                pat.NIC = CNIC;
                pat.Permanent_Address = Address;
                pat.Created_time = DateTime.Now;
                pat.Created_by = AppConfig.UserID;
                pat.iscancel = false;
                pat.Martial_Status = martail_status;
                pat.House_No = houseno;
                pat.stno_mno = stno;
                pat.city = city;
                pat.area = area;
                pat.val_city = city_val;
                pat.val_area = area_val;
                pat.Country = Country;
                pat.Province = Province;
                pat.mr_no_sequence = db.GetSequentialMrNo();


                db.Reg_patients.InsertOnSubmit(pat);
                db.SubmitChanges();
            }
            return pat.pat_id.ToString();
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
        }  [WebMethod]
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
        public static string Getmr()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            Reg_patient pat = null;
            int? maxPatNo = db.Reg_patients.Max(p => (int?)p.Patient_No);
            int newPatNo = (maxPatNo.HasValue ? maxPatNo.Value : 0) + 1;

            return newPatNo.ToString();
        }

        [WebMethod]
        public static string GetOPDNo()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            Patient pat = null;
            int? maxPatNo = db.Patients.Max(p => (int?)p.Opd_No);
            int newPatNo = (maxPatNo.HasValue ? maxPatNo.Value : 0) + 1;

            return newPatNo.ToString();
        }

        [WebMethod]
        public static List<Searchnew> Search(string SearchString)
        {

            string SearchSql = "";

            if (SearchString == "")

                SearchSql = "SELECT Appointment_ID, isnull(Appointment_No,'')Appointment_No,isnull(Patient_Name,'')Patient_Name,isnull(Consultant_ID,'')Consultant_ID,isnull(Age,'')Age,isnull(Phone,'') Phone, (select top 1 emp_name from HR_Employees where Emp_ID=Consultant_ID ) Emp_name,rg.pat_id FROM Appointment_Form app inner join Reg_patient rg on rg.pat_id = app.Reg_id  where(1=1) and Appointment_No<>0 and Appointment_No is not null and Status = 'Booked'";
            else
                SearchSql = "SELECT Appointment_ID,isnull(Appointment_No,'')Appointment_No,isnull(Patient_Name,'')Patient_Name,isnull(Consultant_ID,'')Consultant_ID,isnull(Age,'') Age,isnull(Phone,'')Phone, (select top 1 emp_name from HR_Employees where Emp_ID=Consultant_ID ) Emp_name,Reg_id FROM Appointment_Form where(1=1) and Appointment_No<>0 and Appointment_No is not null and Status = 'Booked' and (LTRIM(RTRIM(Appointment_No)) like '%" + SearchString.Trim() + "%' or  LTRIM(RTRIM(Patient_Name)) like '%" + SearchString.Trim() + "%' or LTRIM(RTRIM(Consultant_ID))  like '%" + SearchString.Trim() + "%' or LTRIM(RTRIM(Age))  like '%" + SearchString.Trim() + "%' or LTRIM(RTRIM(Phone)) like '%" + SearchString.Trim() + "%' or Consultant_ID = isnull((select top 1 Emp_ID from HR_Employees where Emp_Name like '%" + SearchString.Trim() + "%'),'0'))";




            DataTable dt = DBClass.getDataTable(SearchSql);

            List<Searchnew> list = new List<Searchnew>();

            foreach (DataRow dr in dt.Rows)
            {
                Searchnew rsslt = new Searchnew()
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
        public class Searchnew
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
        [WebMethod]
        public static string AptPatient(string app_id)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = (from a in db.Appointment_Forms
                             where a.Appointment_ID == Convert.ToInt32(app_id)

                             select new
                             {
                                 a.Appointment_ID,
                                 a.Age,
                                 a.Patient_Name,
                                 a.Appointment_Code,
                                 a.Phone,
                                 a.Consultant_ID,

                             }).FirstOrDefault();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
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
        public static List<PatientsResultRFf> SearchPatients_Rff(string SearchString)
        {

            string SearchSql = "";

            if (SearchString == "")

                SearchSql = "SELECT top 10 rg.pat_id,isnull(rg.mr_no_sequence,'')Patient_No,isnull(rg.Full_Name,'')Full_Name,isnull(p.NIC,'')NIC,[dbo].[GetDoctorName](op.reffer_doc)ContactNo,isnull(rg.Father_Name,'')Father_Name,isnull(op.Out_Patient_ID,'')as OPDID FROM reg_patient rg inner join  patients p on rg.pat_id = p.Reg_PatId inner join Out_Patient op on p.Patient_ID = op.Patient_ID where op.reffer_doc !=0 and isnull(p.isCancel,0)!=1";
            else
                SearchSql = "SELECT top 10 rg.pat_id,isnull(rg.mr_no_sequence,'')Patient_No,isnull(rg.Full_Name,'')Full_Name,isnull(p.NIC,'')NIC,[dbo].[GetDoctorName](op.reffer_doc)ContactNo,isnull(rg.Father_Name,'')Father_Name,isnull(op.Out_Patient_ID,'')as OPDID FROM reg_patient rg inner join  patients p on rg.pat_id = p.Reg_PatId inner join Out_Patient op on p.Patient_ID = op.Patient_ID where(1=1) and rg.Patient_No<>0 and rg.Patient_No is not null and isnull(rg.isCancel,0)!=1 and (LTRIM(RTRIM(rg.patient_no)) like '%" + SearchString.Trim() + "%' or  LTRIM(RTRIM(rg.full_name)) like '%" + SearchString.Trim() + "%' or LTRIM(RTRIM(rg.mobile1))  like '%" + SearchString.Trim() + "%' or LTRIM(RTRIM(rg.nic))  like '%" + SearchString.Trim() + "%') order by pat_id desc";

            DataTable dt = DBClass.getDataTable(SearchSql);

            List<PatientsResultRFf> rff_list = new List<PatientsResultRFf>();

            foreach (DataRow dr in dt.Rows)
            {
               
                PatientsResultRFf rslt = new PatientsResultRFf()
                {
                    Reg_Patient_ID = dr[0] == DBNull.Value ? "" : dr[0].ToString(),
                    Patient_No = dr[1] == DBNull.Value ? "" : dr[1].ToString(),
                    Full_Name = dr[2] == DBNull.Value ? "" : dr[2].ToString(),
                    NIC = dr[3] == DBNull.Value ? "" : dr[3].ToString(),
                    Mobile1 = dr[4] == DBNull.Value ? "" : dr[4].ToString(),
                    Father_Name = dr[5] == DBNull.Value ? "" : dr[5].ToString(),
                    OPDID = dr[6] == DBNull.Value ? "" : dr[6].ToString(),
                };
                rff_list.Add(rslt);
            }
            return rff_list;
        }
        public class PatientsResultRFf
        {
            public string Full_Name;
            public string NIC;
            public string Reg_Patient_ID;
            public string Age_years;
            public string Patient_No;
            public string Mobile1;
            public string Father_Name;
            public string OPDID;

        }  
     
        [WebMethod]
        public static Receipt PrintReceipt(string PatientID)
        {
            Receipt receipt = new Receipt();
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var pat = (from tbl in db.Patients
                           where tbl.Patient_ID == Convert.ToInt32(PatientID)
                           select new
                           {
                               tbl.Patient_No,
                               tbl.Father_Name,
                               tbl.Full_Name,
                               tbl.Entry_Date,
                               tbl.Age_years,
                               tbl.NIC,
                               tbl.Created_Time,
                               tbl.Receipt_Amount,
                               Department = (from d in db.DataValues join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID where v.ValueSet_Name == "Patient Main Category" && d.DataValue_Name == tbl.Patient_Main_Category select d.DataValue_Description).FirstOrDefault(),
                               Updated_By = (from users in db.aspnet_Users where users.UserId == tbl.Updated_By select users.UserName).FirstOrDefault(),
                               Created_By = (from users in db.aspnet_Users where users.UserId == tbl.Created_By select users.UserName).FirstOrDefault(),
                               PatientType = (from d in db.DataValues join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID where v.ValueSet_Name == "Patient Type" && d.DataValue_Name == tbl.Patient_Type select d.DataValue_Description).FirstOrDefault(),
                               Marital_Status = (from d in db.DataValues join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID where v.ValueSet_Name == "Marital Status" && d.DataValue_Name == tbl.Marital_Status select d.DataValue_Description).FirstOrDefault(),
                              
                               PrivateReceiptCharges = (from d in db.DataValues join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID where v.ValueSet_Name == "Patient Type" && d.DataValue_Name == tbl.Patient_Type select d.Segment1).FirstOrDefault(),
                              
                               TokenNo = (from t in db.Patients
                                          where t.Patient_Main_Category == tbl.Patient_Main_Category
                                          && t.Patient_No < Convert.ToInt32(tbl.Patient_No)
                                          && Convert.ToDateTime(t.Created_Time).Year == DateTime.Now.Date.Year
                                          && Convert.ToDateTime(t.Created_Time).Month == DateTime.Now.Date.Month
                                          && Convert.ToDateTime(t.Created_Time).Day == DateTime.Now.Date.Day
                                          select t).Count() + 1
                           }).FirstOrDefault();
                receipt.ReceiptNo = pat.Patient_No.ToString();
                receipt.PatientName = pat.Full_Name;
                receipt.FatherName = pat.Father_Name;
                receipt.ReceiptCharges = int.Parse(Convert.ToDouble(pat.Receipt_Amount).ToString()).ToString();
                receipt.Operator = pat.Updated_By;
                receipt.Department = pat.Department;
                receipt.ReceiptDate = Convert.ToDateTime(pat.Created_Time).ToString("dd-MM-yyyy h:mm:ss tt");
                receipt.Created_By = pat.Created_By;
                receipt.NIC = pat.NIC;
                receipt.Age_years = pat.Age_years;
                receipt.PatientType = pat.PatientType;
                receipt.Marital_Status = pat.Marital_Status;
                receipt.TokenNo = pat.TokenNo.ToString();
              
                if (receipt.PatientType == "Private")
                    receipt.ReceiptCharges = pat.PrivateReceiptCharges;
            }
            return receipt;

        }
        [WebMethod]
        public static string FillDoctoreByDepartment(string dept)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var doc = from emp in db.HR_Employees
                      where emp.Department == dept && emp.Resign_Date == null
                      select new { Emp_ID = emp.Emp_ID, Emp_Name = emp.Emp_Name };

            return (new JavaScriptSerializer()).Serialize(doc);
        }
        protected void btnNew_Click(object sender, EventArgs e)
        {

            Response.Redirect("~/Modules/PatientManagement/Patients.aspx", false);
        }

        public void Clear(ControlCollection controls)
        {
            foreach (Control ctrl in controls)
            {
                if (ctrl is TextBox)
                    ((TextBox)ctrl).Text = "";
                if (ctrl is DropDownList)
                    ((DropDownList)ctrl).SelectedIndex = 0;
                if (ctrl is CheckBox)
                    ((CheckBox)ctrl).Checked = false;
                if (ctrl is Image)
                    ((Image)ctrl).ImageUrl = "";
                Clear(ctrl.Controls);
            }
        }

        protected void btnSaveAndNew_Click(object sender, EventArgs e)
        {
            btnSave_Click(sender, e);
            btnNew_Click(sender, e);
        }

        protected void btnSaveAndPrint_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;
           
            btnSave_Click(sender, e);
            Session["pntID"] = hdnPatientID.Value;
            Page.ClientScript.RegisterStartupScript(this.GetType(), "OpenWindow", "window.location.href='Patients.aspx?action=print';", true);
          
        }

        protected void ddlPatient_Type_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        protected void ddlGeneral_Category_SelectedIndexChanged(object sender, EventArgs e)
        {

        }


        public void DeletingExtraGeneratedVouchers()
        {
            

            string Sql = "DELETE FROM GL_Vouchers WHERE Voucher_Type='PCard' AND Voucher_ID NOT IN (SELECT convert(int,PatientCard_VoucherID) FROM Patients)DELETE FROM GL_Voucher_Accounts WHERE Voucher_ID NOT IN (SELECT Voucher_ID FROM GL_Vouchers)";

          

            Sql += "update g set g.voucher_date=format(p.created_time,'dd-MMM-yyyy') from patients p,GL_Vouchers g where p.Voucher_ID=g.Voucher_ID update g set g.voucher_date=format(p.created_time,'dd-MMM-yyyy') from patients p,GL_Vouchers g where p.PatientCard_VoucherID=g.Voucher_ID";

            DBClass.executeNonQueryWithoutBegin(Sql);
        }

        public void InsertMissingVouchers()
        {
            List<Patient> patList = new List<Patient>();

            patList = (from p in db.Patients
                       where p.Voucher_ID == 0 || p.Voucher_ID == null
                       select p).ToList();

            foreach (Patient pat in patList)
            {
                string Revisit = (bool)(pat.IsRevisit) ? " Revisit with MR NO." + pat.Patient_No : " ";

                Int32 GL_Cash_Account = Convert.ToInt32(DBClass.getField("select account_id from gl_accounts where account_code='" + DBClass.getParameter("GL_Cash_Account") + "'"));
                Int32 GL_Patient_Account = Convert.ToInt32(DBClass.getField("select account_id from gl_accounts where account_code='" + DBClass.getParameter("GL_Patient_Account") + "'"));


                if (pat.Voucher_ID == null || pat.Voucher_ID == 0)
                {
                   

                    int VoucherNo = DBClass.GetNewVoucherNo("PR", DateTime.Now);
                    string PeriodID = DBClass.getField("select Period_ID from GL_Periods where '" + DateTime.Now.ToString("yyyy-MM-dd") + "' between Period_start_date and Period_end_date").ToString();
                    GL_Voucher gvm = new GL_Voucher();
                    gvm.Voucher_Type = "PR";
                    gvm.Voucher_No = VoucherNo;
                    gvm.Remarks = "Auto Entry of Patient Receipt Voucher.";
                    gvm.Company_ID = AppConfig.Company_ID;
                    gvm.Period_ID = PeriodID;
                    gvm.Voucher_Status = "Approved";
                    //gvm.Voucher_Date = Convert.ToDateTime(DateTime.Now.ToString("yyyy-MM-dd"));
                    gvm.Voucher_Date = Convert.ToDateTime(pat.Created_Time);
                    gvm.Created_By = AppConfig.UserID;
                    gvm.Creation_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                    gvm.Updated_By = AppConfig.UserID;
                    gvm.Update_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                    gvm.Approved_By = AppConfig.UserID;
                    gvm.Approved_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                    gvm.Closing = false;
                    gvm.Cancel = false;
                    db.GL_Vouchers.InsertOnSubmit(gvm);
                    db.SubmitChanges();


                    pat.Voucher_ID = Convert.ToInt32(gvm.Voucher_ID);


                    /******Deleting Previous Details********/

                    List<GL_Voucher_Account> OldVoucherDetails = db.GL_Voucher_Accounts.Where(v => v.Voucher_ID == Convert.ToInt32(pat.Voucher_ID)).ToList();
                    db.GL_Voucher_Accounts.DeleteAllOnSubmit(OldVoucherDetails);
                    db.SubmitChanges();

                    /*****Inserting Cash Details***************/

                    GL_Voucher_Account gvc = new GL_Voucher_Account();
                    gvc.Voucher_ID = Convert.ToInt32(pat.Voucher_ID);
                    gvc.Cheque_No = pat.Patient_No.ToString();
                    gvc.Narration = pat.Full_Name + ", " + (from d in db.DataValues
                                                            join v in db.ValueSets
                                                                on d.ValueSet_ID equals v.ValueSet_ID
                                                            join p in db.Patients
                                                            on d.DataValue_Name equals pat.Patient_Main_Category
                                                            where v.ValueSet_Name == "Patient Main Category" && (d.System_Value == false || d.System_Value == null)

                                                            select
                                                            d.DataValue_Description
                                                              ).FirstOrDefault() + Revisit;
                    gvc.DR = pat.Receipt_Amount;
                    gvc.CR = 0;
                    gvc.Account_ID = GL_Cash_Account;
                    db.GL_Voucher_Accounts.InsertOnSubmit(gvc);

                    /*****Inserting Patient Details***************/

                    GL_Voucher_Account gvp = new GL_Voucher_Account();
                    gvp.Voucher_ID = Convert.ToInt32(pat.Voucher_ID);
                    gvc.Cheque_No = pat.Patient_No.ToString();
                    gvc.Narration = pat.Full_Name + ", " + (from d in db.DataValues
                                                            join v in db.ValueSets
                                                            on d.ValueSet_ID equals v.ValueSet_ID
                                                            join p in db.Patients
                                                            on d.DataValue_Name equals pat.Patient_Main_Category
                                                            where v.ValueSet_Name == "Patient Main Category" && (d.System_Value == false || d.System_Value == null)
                                                            select
                                                                d.DataValue_Description
                                                              ).FirstOrDefault() + Revisit;
                    gvp.CR = pat.Receipt_Amount;
                    gvp.DR = 0;
                    gvp.Account_ID = GL_Patient_Account;
                    db.GL_Voucher_Accounts.InsertOnSubmit(gvp);

                    db.SubmitChanges();
                }
            }
            DeletingExtraGeneratedVouchers();
        }



        protected void btnRevist_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;
            var pat_id = hdnPatientID.Value;
            var rec = (from data in db.In_Patients.Where(x => x.Patient_ID == Convert.ToInt32(pat_id) && x.Discharge == false)
                       select data.In_Patient_ID).FirstOrDefault();
            if (rec == 0)
            {
                IsPatientRevisit = true;
                PatientRevisit();

            }
            else
            {
                Response.Write("<script>alert('Please Discharge Patient First');</script>");
                Page.ClientScript.RegisterStartupScript(
                this.GetType(), "OpenWindow", "window.open('Patients.aspx?ID=" + hdnPatientID.Value + "','_blank');", true);

            }



          
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {

            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            string GlReceiptVoucher_ID = DBClass.getField("select voucher_id from Patients Where Patient_ID=" + Convert.ToInt32(hdnPatientID.Value) + "").ToString();
            try
            {
                bool rowDeleted = DBClass.exectueQuery("Delete Patients Where Patient_ID=" + Convert.ToInt32(hdnPatientID.Value) + "", tranObj, con);

                if (rowDeleted)
                {
                    Response.Redirect("~/Patients.aspx", false);

                }
                tranObj.Commit();

                /********Deleting Gl Receipt Voucher Details*******/

                if (GlReceiptVoucher_ID != "")
                {
                    List<GL_Voucher_Account> GlReceiptVoucher = db.GL_Voucher_Accounts.Where(v => v.Voucher_ID == Convert.ToInt32(GlReceiptVoucher_ID)).ToList();
                    db.GL_Voucher_Accounts.DeleteAllOnSubmit(GlReceiptVoucher);
                    db.SubmitChanges();
                }
            }
            catch (Exception exc)
            {
                if (tranObj != null)
                    tranObj.Rollback();
                throw new Exception(exc.Message);
            }
            finally
            {
                con.Close();
            }
        }



        public struct Result
        {
            public string Gender;
            public string Full_Name;
            public string Birth_Date;
            public string NowDate;
            public string ContectNo;
            public string NIC;
            public string Blood_Group;
            public string Created_By;


            public string Permanent_Address;
            public string MR_No;
            public string Printed_By;
            public string Patient_Type;

            public string Department;
            public string Age_years;
            public string Created_Time;
            public string Referring_Doctor;





        }
        [WebMethod]
        public static Result GetPatRegCardDetails(int PatID)
        {

            Result receipt = new Result();
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var patient = (from p in db.Patients
                               where p.Patient_ID == PatID

                               select new
                               {
                                   p.Full_Name,
                                   p.Birth_Date,
                                   p.Mobile1,
                                   p.NIC,
                                   p.Gender,

                                   p.Permanent_Address,
                                   p.Patient_No,

                                   Printed_By = AppConfig.UserName,
                                   Patient_Type = db.GetDataValueName("Patient Type", p.Patient_Type),
                                   Blood_Group = db.GetDataValueName("Blood Group", p.Blood_Group),
                                   Room_No = "33",
                                   Doctor_Name = "faizan",

                               }
                         ).FirstOrDefault();

                receipt.MR_No = patient.Patient_No.ToString();
                receipt.Full_Name = patient.Full_Name;
                receipt.Birth_Date = Convert.ToDateTime(patient.Birth_Date).ToString("dd-MM-yyyy");
                receipt.ContectNo = patient.Mobile1;
                if (receipt.ContectNo == "")
                {
                    receipt.ContectNo = "";
                }


                receipt.NIC = patient.NIC;
                receipt.Gender = patient.Gender;
                receipt.Blood_Group = patient.Blood_Group;
                receipt.Permanent_Address = patient.Permanent_Address;


                receipt.Printed_By = patient.Printed_By.ToString();
                receipt.Patient_Type = patient.Patient_Type;

                receipt.NowDate = Convert.ToDateTime(DateTime.Now).ToString();

            }
            InsertVoucherFor_PatientCard(PatID.ToString());
            return receipt;
        }

        [WebMethod]
        public static string SetPatientCardIssuance(int PatID)
        {

            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var patient = (from p in db.Patients
                               where p.Reg_PatId == PatID
                               select p).FirstOrDefault();
                if (patient != null)
                {
                    
                    return "success";
                }
            }
            return "Error";
        }

        public void PatientRevisit()
        {
            if (!Page.IsValid)
                return;

        

            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {

                var sysParm = (from tbl in db.sys_Parms
                               where tbl.Name == "Patient Card No"
                               select tbl.Code).FirstOrDefault();

                Patient pat;


                pat = new Patient();

                pat.Full_Name = txtFull_Name.Text;
                pat.Father_Name = txtFather_Name.Text;

                pat.Patient_No = Convert.ToInt32(txtPatientNo.Text);

                pat.Gender = ddlGender.SelectedValue;
                pat.NIC = txtPatient_NIC.Text;

                pat.Email = txtEmail_ID.Text;
                pat.Patient_Main_Category = ddlPatient_Main_Category.SelectedValue;
                pat.Panel_Companies = ddlPanelCompany.SelectedValue;
               
                pat.Age_years = txtAge_years.Text;
                if (txtBirth_Date.Text != "")
                    pat.Birth_Date = Convert.ToDateTime(txtBirth_Date.Text);
                pat.Marital_Status = ddlMarital_Status.SelectedValue;
               
                pat.Patient_Type = ddlPatient_Type.SelectedValue;
                pat.Mode_Of_Registration = ddlMode_Of_Registration.SelectedValue;
          

                if (ddlPatient_Type.SelectedValue == "01")
                {
                    var generalCategory = ddlGeneral_Category.SelectedValue;
                    pat.General_Category = generalCategory;

                    if (generalCategory == "001")
                    {
                    }
                    else if (generalCategory == "002")
                    {

                    }
                    else if (generalCategory == "003")
                    {
                        
                    }
               
                }
            
                if (ddlPatient_Type.SelectedValue == "02")
                {
                    pat.Doctor_ID = ddlDoctorName.SelectedValue;
                }
                if (chckPatientCard.Checked == true)
                {
                    pat.Card_Issued = true;

                    pat.Card_Receipt_Amount = Convert.ToDecimal(sysParm);
                }
                else
                {
                    pat.Card_Issued = false;

                    pat.Card_Receipt_Amount = (decimal)0.00;
                }
                // 2nd tab
                pat.Receipt_Amount = Convert.ToDecimal(txtRegistration_Fee.Text);
           
                pat.District = ddlDistrict.SelectedValue;
              
                pat.Permanent_Address = txtPermanent_Address.Text;
            
                pat.Phone = txtPhone.Text;
                pat.Mobile1 = txtMobile1.Text;
                pat.Mobile2 = txtMobile2.Text;


                pat.IsRevisit = true;

           
                var IsFree = (from v in db.ValueSets
                              join d in db.DataValues
                              on v.ValueSet_ID equals d.ValueSet_ID
                              where v.ValueSet_Name == "Patient Type"
                              && ((d.DataValue_Description == "Student" && d.DataValue_Name == pat.Patient_Type) || (d.DataValue_Description == "Company" && d.DataValue_Name == pat.Patient_Type) || (d.DataValue_Description == "walk-In" && d.DataValue_Name == pat.Patient_Type) || (d.DataValue_Description == "walk-In" && d.DataValue_Name == pat.Patient_Type) || (d.DataValue_Description == "Employee" && d.DataValue_Name == pat.Patient_Type || (d.DataValue_Name == "07" && d.DataValue_Name == pat.Patient_Type) || (d.DataValue_Name == "08" && d.DataValue_Name == pat.Patient_Type) || (d.DataValue_Name == "09" && d.DataValue_Name == pat.Patient_Type)))
                              select d
                                 ).ToList();

                //Checking that is Private....

                var IsPrivate = (from v in db.ValueSets
                                 join d in db.DataValues
                                 on v.ValueSet_ID equals d.ValueSet_ID
                                 where v.ValueSet_Name == "Patient Type"
                                 && (d.DataValue_Description == "Private" && d.DataValue_Name == pat.Patient_Type)
                                 select d
                ).ToList();

                var ReceiptCharges = (from d in db.DataValues
                                      join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID
                                      where v.ValueSet_Name == "Patient Main Category" && d.DataValue_Name == pat.Patient_Main_Category
                                      && (d.System_Value == false || d.System_Value == null)
                                      select d.Segment1).FirstOrDefault();

                var PrivateReceiptCharges = (from d in db.DataValues
                                             join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID
                                             where v.ValueSet_Name == "Patient Type" && d.DataValue_Name == pat.Patient_Type
                                             select d.Segment1).FirstOrDefault();


                // For Private Charges....

                if (IsPrivate.Count > 0)
                {

                    var PrivateDoctorCharges = (from emp in db.HR_Employees
                                                where emp.Emp_ID == Convert.ToInt32(ddlDoctorName.SelectedValue)
                                                select emp.Doctor_Amount).FirstOrDefault();
                    if (PrivateDoctorCharges == null)
                    {
                        PrivateDoctorCharges = 0;
                    }

                    var PrivateHospitalCharges = (from emp in db.HR_Employees
                                                  where emp.Emp_ID == Convert.ToInt32(ddlDoctorName.SelectedValue)
                                                  select emp.Hospital_Amount).FirstOrDefault();
                    if (PrivateHospitalCharges == null)
                    {
                        PrivateHospitalCharges = 0;
                    }



                    pat.Receipt_Amount = Convert.ToInt32(PrivateHospitalCharges);
                    pat.Doctor_Amount = Convert.ToInt32(PrivateDoctorCharges);
                }



                else if (IsFree.Count > 0)
                {
                    var FreeRecieptAMount = "0.00";
                    FreeRecieptAMount = (from d in db.DataValues join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID where v.ValueSet_Name == "Patient Type" && d.DataValue_Name == pat.Patient_Type select d.Segment1).FirstOrDefault();
                    pat.Receipt_Amount = Convert.ToDecimal(FreeRecieptAMount);
                    pat.Doctor_Amount = (decimal)0.00;
                }
                else if (ddlPatient_Type.SelectedValue == "10")
                {
                    pat.Receipt_Amount = (decimal)1000.00;
                    pat.Doctor_Amount = (decimal)0.00;
                }

                else if (ddlPatient_Type.SelectedValue == "08")
                {
                    pat.Receipt_Amount = (decimal)0.00;
                    pat.Doctor_Amount = (decimal)0.00;
                }
                else if (ddlPatient_Type.SelectedValue == "14")
                {
                    pat.Receipt_Amount = (decimal)0.00;
                    pat.Doctor_Amount = (decimal)0.00;
                }
                // Default Charges for General .
                else
                {
                    if (ReceiptCharges != "" && ReceiptCharges != null)
                    {
                        pat.Receipt_Amount = Convert.ToDecimal(ReceiptCharges);
                        pat.Doctor_Amount = (decimal)0.00;
                    }
                    else
                    {
                        TimeSpan time = DateTime.Now.TimeOfDay;
                        if (time > new TimeSpan(08, 00, 00)        //Hours, Minutes, Seconds
                         && time < new TimeSpan(13, 59, 59))
                        {
                            txtRegistration_Fee.Text = "20";
                        }
                        else
                        {
                            txtRegistration_Fee.Text = "20";
                        }
                        pat.Receipt_Amount = Convert.ToInt32(txtRegistration_Fee.Text);
                        pat.Doctor_Amount = (decimal)0.00;
                    }
                }
                if (ddlMode_Of_Registration.Text == "Emergency")
                {

                    var EmerygancyReceiptCharges = (from d in db.DataValues
                                                    join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID
                                                    where v.ValueSet_Name == "Mode Of Registration" && d.DataValue_Name == pat.Mode_Of_Registration
                                                    select d.Segment1).FirstOrDefault();

                    if (EmerygancyReceiptCharges != "")
                    {
                        pat.Receipt_Amount = Convert.ToDecimal(EmerygancyReceiptCharges);
                        pat.Doctor_Amount = (decimal)0.00;
                        pat.Patient_Type = "01";
                    }
                }
                if (ddlPatient_Type.SelectedItem.Text == "Insurance Company")
                {
                    pat.Receipt_Amount = 0;
                    pat.Doctor_Amount = (decimal)0.00;

                }

                if (ddlPatient_Type.SelectedItem.Text == "Free Camp")
                {
                    pat.Receipt_Amount = 0;
                    pat.Doctor_Amount = (decimal)0.00;
                }
                if (ddlPatient_Type.SelectedItem.Text == "promotion camp")
                {
                    pat.Receipt_Amount = 0;
                    pat.Doctor_Amount = (decimal)0.00;
                }
               
                var TokenNo = (from t in db.Patients
                               where t.Patient_Main_Category == ddlPatient_Main_Category.SelectedValue
                               && t.Patient_No < Convert.ToInt32(txtPatientNo.Text.Trim())
                               && Convert.ToDateTime(t.Created_Time).Year == DateTime.Now.Date.Year
                               && Convert.ToDateTime(t.Created_Time).Month == DateTime.Now.Date.Month
                               && Convert.ToDateTime(t.Created_Time).Day == DateTime.Now.Date.Day
                               select t).Count() + 1;
                string roomNo = DBClass.getField("select Segment2 from DataValues where ValueSet_ID = 9 and DataValue_Name = '" + ddlPatient_Main_Category.SelectedValue + "'").ToString();

                string pageurl = "ReportViewer.aspx?ReportName=PatientSlip&Patient_ID=" + txtPatient_ID.Text.Trim() + "&Patient_No=" + txtPatientNo.Text.Trim() + "&Full_Name=" + txtFull_Name.Text.Trim() + "&Patient_Main_Categpry=" + ddlPatient_Main_Category.SelectedItem.Text + "&TokenNo=" + TokenNo + "&RoomNo=" + roomNo + "&ReportTitle=Patient Slip";
                Response.Write("<script> window.open('" + pageurl + "','_blank'); </script>");
                {
                    pat.Created_By = AppConfig.UserID;
                    pat.Created_Time = DateTime.Now;
                    pat.Book_ID = AppConfig.Book_ID;
                    pat.Company_ID = AppConfig.Company_ID;
                    lblMessage.Text = "Data has been save sucessfully";
                    db.Patients.InsertOnSubmit(pat);
                }

                {
                    lblMessage.Text = "Data has been update sucessfully";
                }

                {
                    lblMessage.CssClass = "sucessfullMessage";
                    db.SubmitChanges();
                    if (hdnAptId.Value == "")
                    {

                    }
                    else
                    {
                        DBClass.executeNonQueryWithoutBegin("update Appointment_Form set Status='Visited' where Appointment_ID=" + hdnAptId.Value);
                    }
                }

                var Patientno = pat.Patient_No.ToString();
              
                string SMS_Contant = "عارف میموریل ٹیچنگ ہسپتال پر اعتماد کرنے کا شکریہ اب آپکا شناختی کارڈ ہی صحت کارڈ ہے۔اپنا اور اپنے خاندان کا فری علاج پروفیسرز ڈاکٹر کی زیرنگرانی کروائیں اور مریض کے فری کھانے کی سہولت بھی ہے۔ رابطہ نمبر-03138458018";
                string msg = "";

                string DocumentName = "PatientReg";
                string CellNumber = txtMobile1.Text;
                bool Send_Status = DBClass.sendSMS(CellNumber, SMS_Contant, out msg, DocumentName, Patientno);

              

                var count = (db.Patients.Where(v => v.Patient_No == Convert.ToInt32(Patientno)).ToList());
                var Follow = count.Count;
                lblFollowNo.InnerHtml = Follow.ToString();
                hdnPatientID.Value = pat.Patient_ID.ToString();

               
            }
        }

        [WebMethod]
        public static string SaveBroughtByInformation(string BroughtBy, string ShiftedTo, string ReferedTo, string Discharge, string BroughtName, string BroughtCNIC, string BroughtRelation, string BroughtMobile, string BroughtAddress, string BroughtOccupation, string BroughtVehicleNo, string PatientID)
        {

            DataBaseDataContext db = new DataBaseDataContext();
            Patient pat = new Patient();
            bool isNew = true;
            try
            {
                if (PatientID != "")
                {
                    pat = (from tbl in db.Patients
                           where tbl.Patient_ID == Convert.ToInt32(PatientID)
                           select tbl).FirstOrDefault();


                    if (pat == null)
                    {
                        pat = new Patient();
                        pat.Patient_No = (Convert.ToInt32(db.Patients.Where(p => p.Company_ID == Convert.ToInt16(AppConfig.Company_ID)).Max(p => p.Patient_No)) + 1);
                    }
                    else
                    {
                        pat.Updated_By = AppConfig.UserID;
                        pat.Updated_Time = DateTime.Now;
                        isNew = false;
                    }
                }

                pat.Brought_By = BroughtBy;
                pat.ShiftedTo = ShiftedTo;
                pat.ReferedTo = ReferedTo;
                pat.Discharge = Discharge == "1" ? true : false;
                pat.BroughtPerson_Name = BroughtName;
                pat.BroughtPerson_CNIC = BroughtCNIC;
                pat.BroughtPerson_Relation = BroughtRelation;
                pat.BroughtPerson_Mobile = BroughtMobile;
                pat.BroughtPerson_Address = BroughtAddress;
                pat.BroughtPerson_Occupation = BroughtOccupation;
                pat.BroughtPerson_VehicleNo = BroughtVehicleNo;
                pat.Updated_By = AppConfig.UserID;
                pat.Updated_Time = DateTime.Now;
                if (isNew)
                    db.Patients.InsertOnSubmit(pat);
                db.SubmitChanges();
            }
            catch (Exception exc)
            {

            }

            return pat.Patient_ID.ToString();
        }

        [WebMethod]
        public static Patient LoadBroughtByInformation(string ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            Patient data = db.Patients.Where(em => em.Patient_ID == Convert.ToInt32(ID)).FirstOrDefault();

            return data;
        }
        [WebMethod]
        public static string GetDefinitions(string ValueSet_Name)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var depts = (from v in db.ValueSets
                         join d in db.DataValues
                         on v.ValueSet_ID equals d.ValueSet_ID
                         where v.ValueSet_Name == ValueSet_Name
                         select new { d.DataValue_Name, d.DataValue_Description }
                       ).ToList();
            return (new JavaScriptSerializer()).Serialize(depts);
        }

        [WebMethod]
        public static string GetMaxPatNo()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var no = (from p in db.Patients
                      where p.Company_ID == AppConfig.Company_ID
                      select p.Patient_ID).Max();
            return (new JavaScriptSerializer()).Serialize(no);
        }
       
        [WebMethod]
        public static string GetCount()
        {
            DataBaseDataContext db = new DataBaseDataContext();


            int Filter1 = db.Patients
                .Where(p => p.Created_Time.Value.Year == DateTime.Now.Year && p.Created_Time.Value.Month == DateTime.Now.Month && p.Created_Time.Value.Day == DateTime.Now.Day && p.filter_clinic == "001")
                .Count();

            int Filter2 = db.Patients
                .Where(p => p.Created_Time.Value.Year == DateTime.Now.Year && p.Created_Time.Value.Month == DateTime.Now.Month && p.Created_Time.Value.Day == DateTime.Now.Day && p.filter_clinic == "002")
                .Count();

            int Filter3 = db.Patients
                .Where(p => p.Created_Time.Value.Year == DateTime.Now.Year && p.Created_Time.Value.Month == DateTime.Now.Month && p.Created_Time.Value.Day == DateTime.Now.Day && p.filter_clinic == "003")
                .Count();

            int TotalPatients = db.Patients.Where(p => p.Created_Time.Value.Year == DateTime.Now.Year && p.Created_Time.Value.Month == DateTime.Now.Month && p.Created_Time.Value.Day == DateTime.Now.Day).Count();

            // Create an anonymous object to store the counts
            var counts = new
            {
                Filter1,
                Filter2,
                Filter3,
                TotalPatients
            };

          
            return (new JavaScriptSerializer()).Serialize(counts);

        }
        [WebMethod]
        public static void InsertVoucherFor_PatientCard(string PatientID)
        {

            
        }

        public static string CalculateYourAge(DateTime Dob)
        {
            DateTime Now = DateTime.Now;
            int Years = new DateTime(DateTime.Now.Subtract(Dob).Ticks).Year - 1;
            DateTime PastYearDate = Dob.AddYears(Years);
            int Months = 0;
            for (int i = 1; i <= 12; i++)
            {
                if (PastYearDate.AddMonths(i) == Now)
                {
                    Months = i;
                    break;
                }
                else if (PastYearDate.AddMonths(i) >= Now)
                {
                    Months = i - 1;
                    break;
                }
            }
            int Days = Now.Subtract(PastYearDate.AddMonths(Months)).Days;
          
            return String.Format("{0}y - {1}m - {2}d",
            Years, Months, Days);
        }
    }
}