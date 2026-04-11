using System;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.PatientManagement
{
    public partial class NewEmergencyCase : System.Web.UI.Page
    {
        DataTable dt;
        DataBaseDataContext db;
        public static int InPatient_Case_id;
        protected void Page_Load(object sender, EventArgs e)
        {
           
            if (!IsPostBack)
            {
                var id = Request.Url.PathAndQuery;
                var s = Request.QueryString;

                db = new DataBaseDataContext(DBClass.ConnectionString());
                txtadmissionfee.Text = Convert.ToString(
                         (from tbl in db.sys_Parms
                          where tbl.Name == "Emergency Fee"
                          select tbl.Code).FirstOrDefault());
                txtAdmission_Date.Text = DateTime.Now.ToString();
                txtReceiving_Date.Text = DateTime.Now.ToString();
                //smth here
                 BindingDropDown();
                LoadAllDoctors();
                BlankForm();
                if (Request.QueryString["ID"] != null)
                {
                    string QS = id.Split('=')[1];
                    PopulateGetEmergencyPatientData(Convert.ToInt32(QS));
                    InPatient_Case_id = Convert.ToInt32(QS);
                }

            }
          
        }

        [WebMethod]
        public static string CheckExistOutPatient(int Patient_ID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var patientExistOPD = (from OPD in db.Out_Patients
                                       where OPD.Reg_PatId == Patient_ID
                                             && OPD.Discharge == false
                                       orderby OPD.Out_Patient_ID descending
                                       select new
                                       {
                                           OPD.Patient_ID,
                                           OPD.Out_Patient_ID,
                                       }).FirstOrDefault();

                var patientExistIPD = (from IPD in db.In_Patients
                                       where IPD.Patient_ID == Patient_ID
                                             && IPD.Discharge == false
                                       orderby IPD.In_Patient_ID descending
                                       select new
                                       {
                                           IPD.Patient_ID,
                                           IPD.In_Patient_ID,
                                       }).FirstOrDefault();

                if (patientExistOPD != null)
                {
                    return "OPD"; 
                }
                else if (patientExistIPD != null)
                {
                    return "IPD";
                }
                else
                {
                    return "Not Exist";
                }
            }
        }

        [WebMethod]
        public static string SavePatientDetail(string Full_Name, string RelationType, string Relation, string Gender, string Mobile, string Date_Of_Birth, string CNIC, string Address, string PatientID, string martail_status, string Age)
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
                    if (string.IsNullOrWhiteSpace(Date_Of_Birth))
                    {
                        pat.DOB = null;
                    }
                    else
                    {
                        if (!DateTime.TryParseExact(
                            Date_Of_Birth.Trim(),
                            "dd/MM/yyyy",
                            System.Globalization.CultureInfo.InvariantCulture,
                            System.Globalization.DateTimeStyles.None,
                            out DateTime dob))
                        {
                            return "ERROR: Date must be in dd/MM/yyyy format (e.g., 19/12/2000).";
                        }
                        pat.DOB = dob;
                    }
                    pat.NIC = CNIC;
                    pat.Permanent_Address = Address;
                    pat.Martial_Status = martail_status;
                    pat.walkin = true;
                    db.SubmitChanges();
                }
            }
            else
            {
                pat = new Reg_patient();
                string PatientNumber = (DBClass.getMaxEntry_No("Reg_patient", "Patient_No")).ToString();
                pat.Patient_No = Convert.ToInt32(PatientNumber);
                pat.Full_Name = Full_Name;
                pat.Father_Name = Relation;
                pat.Relation_prefix = RelationType;
                pat.Gender = Gender;
                pat.Mobile1 = Mobile;
                pat.Age_years = Age;
                pat.NIC = CNIC;
                pat.Permanent_Address = Address;
                pat.Created_time = DateTime.Now;
                pat.Created_by = AppConfig.UserID;
                pat.iscancel = false;
                pat.Martial_Status = martail_status;
                if (string.IsNullOrWhiteSpace(Date_Of_Birth))
                {
                    pat.DOB = null;
                    pat.Age_years = null;
                }
                else
                {
                    if (!DateTime.TryParseExact(
                        Date_Of_Birth,
                        "dd/MM/yyyy",
                        System.Globalization.CultureInfo.InvariantCulture,
                        System.Globalization.DateTimeStyles.None,
                        out DateTime dob))
                    {
                        return "ERROR: Invalid date format. Use dd/MM/yyyy (e.g., 19/12/2000).";
                    }

                    pat.DOB = dob;
                    DateTime today = DateTime.Today;
                    int years = today.Year - dob.Year;
                    int months = today.Month - dob.Month;
                    int days = today.Day - dob.Day;

                    if (days < 0)
                    {
                        months--;
                        int prevMonth = today.Month == 1 ? 12 : today.Month - 1;
                        int prevYear = today.Month == 1 ? today.Year - 1 : today.Year;
                        days += DateTime.DaysInMonth(prevYear, prevMonth);
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

                var companyID = AppConfig.Company_ID;
                var company = (from dt in db.sys_Companies
                               where dt.Company_ID == companyID
                               select dt).FirstOrDefault();
                string companyCode = company.CompanyCode;
                string MR_Sequence = companyCode + "-" + PatientNumber;
                pat.mr_no_sequence = MR_Sequence;
                pat.walkin = true;
                db.Reg_patients.InsertOnSubmit(pat);
                db.SubmitChanges();
            }
            return pat.pat_id.ToString();
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
        private void LoadAllDoctors()
        {
            db = new DataBaseDataContext(DBClass.ConnectionString());
            List<HR_Employee> EmpList = new List<HR_Employee>();
            List<HR_Employee> EmpList2 = new List<HR_Employee>();
            EmpList = (from tbl in db.HR_Employees
                       where tbl.IsDoctor == true
                       select tbl).ToList();
            EmpList2 = (from tbl in db.HR_Employees
                        where tbl.IsDoctor == true
                        select tbl).ToList();
            ddlDoctor.Items.Clear();
            ddlDoctor.DataSource = EmpList;
            ddlDoctor.DataTextField = "Emp_Name";
            ddlDoctor.DataValueField = "Emp_ID";
            ddlDoctor.Items.Add(new ListItem("Please Select", "0"));
            ddlDoctor.DataBind();


            ddlDeathCertifiedbyDr1.Items.Clear();
            ddlDeathCertifiedbyDr1.DataSource = EmpList2;
            ddlDeathCertifiedbyDr1.DataTextField = "Emp_Name";
            ddlDeathCertifiedbyDr1.DataValueField = "Emp_ID";
            ddlDeathCertifiedbyDr1.Items.Add(new ListItem("Please Select", "0"));
            ddlDeathCertifiedbyDr1.DataBind();

            ddlDeathCertifiedbyDr2.Items.Clear();
            ddlDeathCertifiedbyDr2.DataSource = EmpList2;
            ddlDeathCertifiedbyDr2.DataTextField = "Emp_Name";
            ddlDeathCertifiedbyDr2.DataValueField = "Emp_ID";
            ddlDeathCertifiedbyDr2.Items.Add(new ListItem("Please Select", "0"));
            ddlDeathCertifiedbyDr2.DataBind();


            ddlDischarge_By.Items.Clear();
            ddlDischarge_By.DataSource = EmpList2;
            ddlDischarge_By.DataTextField = "Emp_Name";
            ddlDischarge_By.DataValueField = "Emp_ID";
            ddlDischarge_By.Items.Add(new ListItem("Please Select", "0"));
            ddlDischarge_By.DataBind();

        }
        public void BlankForm()
        {
            ddlIssuance_Of.SelectedIndex = 0;
            ddlPlaceOfDeath.SelectedIndex = 0;

            ddlWard_No.SelectedIndex = 0;
            txtBed_No.Text = "";
            ddlDepartment.SelectedIndex = 0;
            ddlDoctor.SelectedIndex = 0;
            ddlCallToDoctor.SelectedIndex = 0;
            ddlReferredTo.SelectedIndex = 0;

            txtAdmission_Date.Text = DateTime.Now.ToString();
            txtReceiving_Date.Text = DateTime.Now.ToString();
            txttxtReceiving_DateDesc.Text = DateTime.Now.ToString();

            txtRN_Special_Instruction.Text = "";

            txtBP.Text = "";
            txtTemp.Text = "";
            txtRespiration.Text = "";

            ddlDepartment.SelectedIndex = 0;
            ddlDoctor.SelectedIndex = 0;

       

            ddlDischarge_By.SelectedIndex = 0;
            txtPrevention_Precaution.Text = "";
            txtNext_Visit.Text = "";
            cbDeath_Certificate.Checked = false;

            ddlPatientCondition.SelectedIndex = 0;
            ddlRhythm.SelectedIndex = 0;
            ddlVolume.SelectedIndex = 0;
            ddlRhythmdischarge.SelectedIndex = 0;
            ddlvolumedisc.SelectedIndex = 0;
            ddlDischargeStatus.SelectedIndex = 0;
            ddlDeathCertifiedbyDr1.SelectedIndex = 0;
            ddlDeathCertifiedbyDr2.SelectedIndex = 0;

        }
        private void BindingDropDown()
        {

            object valueset;

            valueset = DBClass.GetValueSet("Laundary From To");
            ddlIssuance_Of.DataSource = valueset;
            ddlIssuance_Of.DataTextField = "DataValue_Description";
            ddlIssuance_Of.DataValueField = "DataValue_Name";
            ddlIssuance_Of.DataBind();



            db = new DataBaseDataContext(DBClass.ConnectionString());
            var qry = from d in db.DataValues
                      where d.ValueSet_ID == 20 && d.DataValue_Name == "02"
                      select new { d.DataValue_Name, d.DataValue_Description };

            ddlDepartment.DataSource = qry;
            ddlDepartment.DataTextField = "DataValue_Description";
            ddlDepartment.DataValueField = "DataValue_Name";
            ddlDepartment.DataBind();

            valueset = DBClass.GetValueSet("Patient Main Category");
            ddl_Department.DataSource = valueset;
            ddl_Department.DataTextField = "DataValue_Description";
            ddl_Department.DataValueField = "DataValue_Name";
            ddl_Department.Items.Add(new ListItem("Please Select", "0"));
            ddl_Department.DataBind();
 
            valueset = DBClass.GetValueSet("Doctor Status");




            var ss = AppConfig.UserID;

            var EmpCode = (from tbl in db.aspnet_Users
                           where tbl.UserId == AppConfig.UserID
                           select tbl.Emp_Code).FirstOrDefault();
            if (EmpCode != null)
            {
                List<HR_Employee> loginEmpName = new List<HR_Employee>();
                loginEmpName = (from tbl in db.HR_Employees
                                where tbl.IsDoctor == true && tbl.Emp_No == EmpCode
                                select tbl).ToList();
                if (loginEmpName != null)
                {

                }

                var Empstatus = (from tbl in db.HR_Employees
                                 where tbl.IsDoctor == true && tbl.Emp_No == EmpCode
                                 select tbl.Designation).FirstOrDefault();

            }

            List<HR_Employee> EmpList = new List<HR_Employee>();
            EmpList = (from tbl in db.HR_Employees
                       where tbl.IsDoctor == true
                       select tbl).ToList();
            List<Service_Definition> SrvcList = new List<Service_Definition>();
            SrvcList = (from tbl in db.Service_Definitions
                        join tbl2 in db.DataValues on tbl.Service_Type equals tbl2.DataValue_Name
                        join tbl3 in db.ValueSets on tbl2.ValueSet_ID equals tbl3.ValueSet_ID
                        where tbl2.DataValue_Description == "In-Patient"
                        select tbl).ToList();
           



            var wards = (from tbl2 in db.Ward_Definitions
                         select tbl2).ToList();

            ddlWard_No.DataSource = wards;
            ddlWard_No.DataTextField = "Ward_Type";
            ddlWard_No.DataValueField = "Ward_ID";
            ddlWard_No.Items.Add(new ListItem("Please Select", "0"));
            ddlWard_No.DataBind();


            valueset = DBClass.GetValueSet("Emergency Rhythm");
            ddlRhythm.DataSource = valueset;
            ddlRhythm.DataTextField = "DataValue_Description";
            ddlRhythm.DataValueField = "DataValue_Name";
            ddlRhythm.Items.Add(new ListItem("Please Select", "0"));
            ddlRhythm.DataBind();
            ddlRhythmdischarge.DataSource = valueset;
            ddlRhythmdischarge.DataTextField = "DataValue_Description";
            ddlRhythmdischarge.DataValueField = "DataValue_Name";
            ddlRhythmdischarge.Items.Add(new ListItem("Please Select", "0"));
            ddlRhythmdischarge.DataBind();


            valueset = DBClass.GetValueSet("Emergency Volume");
            ddlVolume.DataSource = valueset;
            ddlVolume.DataTextField = "DataValue_Description";
            ddlVolume.DataValueField = "DataValue_Name";
            ddlVolume.Items.Add(new ListItem("Please Select", "0"));
            ddlVolume.DataBind();
            ddlvolumedisc.DataSource = valueset;
            ddlvolumedisc.DataTextField = "DataValue_Description";
            ddlvolumedisc.DataValueField = "DataValue_Name";
            ddlvolumedisc.Items.Add(new ListItem("Please Select", "0"));
            ddlvolumedisc.DataBind();


            valueset = DBClass.GetValueSet("Discharge Status");
            ddlDischargeStatus.DataSource = valueset;
            ddlDischargeStatus.DataTextField = "DataValue_Description";
            ddlDischargeStatus.DataValueField = "DataValue_Name";
            ddlDischargeStatus.Items.Add(new ListItem("Please Select", "0"));
            ddlDischargeStatus.DataBind();

            valueset = DBClass.GetValueSet("Place Of Death");
            ddlPlaceOfDeath.DataSource = valueset;
            ddlPlaceOfDeath.DataTextField = "DataValue_Description";
            ddlPlaceOfDeath.DataValueField = "DataValue_Name";
            ddlPlaceOfDeath.Items.Add(new ListItem("Please Select", "0"));
            ddlPlaceOfDeath.DataBind();

            valueset = DBClass.GetValueSet("Referred To");
            ddlReferredTo.DataSource = valueset;
            ddlReferredTo.DataTextField = "DataValue_Description";
            ddlReferredTo.DataValueField = "DataValue_Name";
            ddlReferredTo.Items.Add(new ListItem("Please Select", "0"));
            ddlReferredTo.DataBind();



            var PatientConditionData = (from vs in db.ValueSets
                                        join dv in db.DataValues on vs.ValueSet_ID equals dv.ValueSet_ID
                                        where vs.ValueSet_Name.Contains("Patient Condition")
                                        select new
                                        {
                                            dv.DataValue_Name,
                                            dv.DataValue_Description,
                                            dv.Segment1
                                        }).ToList();
            ddlPatientCondition.DataSource = PatientConditionData;
            ddlPatientCondition.DataTextField = "DataValue_Description";
            ddlPatientCondition.DataValueField = "DataValue_Name";
            ddlPatientCondition.Items.Add(new ListItem("Please Select", "0"));
            ddlPatientCondition.DataBind();
            int i = 1;
            foreach (var item in PatientConditionData)
            {
                ddlPatientCondition.Items[i].Attributes.Add("name", item.Segment1);
                i++;
            }

        }

        private void PopulateGetEmergencyPatientData(int Emergency_ID)
        {
            try
            {
                object valueset;
                db = new DataBaseDataContext(DBClass.ConnectionString());
                var qry = db.sp_GetEmergencyPatientDetail(Emergency_ID).FirstOrDefault();
                #region Old Code
                
                #endregion
                          var Emergency_Doctor_Notes = (from rn in db.Emergency_Doctor_Notes
                                                        where rn.EmergencyId == Emergency_ID
                                                  orderby rn.Emergency_Doc_Id descending
                                                  select rn).FirstOrDefault();
                // Get the latest Receiving Note for this Emergency_ID
                var receivingNoteQry = (from rn in db.ReceivingNotes
                                        where rn.Emergency_ID == Emergency_ID &&
                                              rn.Type_Nursing == "Receiving Note Emergency"
                                        orderby rn.ReceivingNoteID descending
                                        select rn).FirstOrDefault();

                if (receivingNoteQry != null)
                {
                    // Populate Receiving Notes tab (tab02) fields
                    txtRateBeats.Text = receivingNoteQry.RateBeats ?? "";
                    txtBP.Text = receivingNoteQry.BloodPressure ?? "";
                    txtTemp.Text = receivingNoteQry.Temperature ?? "";
                    txtRespiration.Text = receivingNoteQry.RespirationRate ?? "";
                    txtSaturation_Oxygen2.Text = receivingNoteQry.O2_Saturation_Oxygen2 ?? "";
                    txtOthersRcvNote.Text = receivingNoteQry.OthersRecieveNote ?? "";
                    txtSaturation.Text = receivingNoteQry.O2_Saturation ?? "";
                    txtSaturation_Oxygen1.Text = receivingNoteQry.O2_Saturation_Oxygen1 ?? "";
                    txtRN_Special_Instruction.Text = receivingNoteQry.RN_Special_Instruction ?? "";

                    if (receivingNoteQry.Receiving_Date.HasValue)
                    {
                        txtReceiving_Date.Text = receivingNoteQry.Receiving_Date.Value.ToString("MM/dd/yyyy hh:mm tt");
                    }

                    // Set dropdown values if they exist
                    if (!string.IsNullOrEmpty(receivingNoteQry.Emergency_Rhythm))
                    {
                        if (ddlRhythm.Items.FindByValue(receivingNoteQry.Emergency_Rhythm) != null)
                        {
                            ddlRhythm.SelectedValue = receivingNoteQry.Emergency_Rhythm;
                        }
                    }

                    if (!string.IsNullOrEmpty(receivingNoteQry.Emergency_Volume))
                    {
                        if (ddlVolume.Items.FindByValue(receivingNoteQry.Emergency_Volume) != null)
                        {
                            ddlVolume.SelectedValue = receivingNoteQry.Emergency_Volume;
                        }
                    }

                    // Set checkboxes - you may need to add logic based on your business rules
                    // For example, if certain values indicate Room Air or With O2
                    // chk_OnRoomAir.Checked = // your logic here
                    // chk_WithOxygen.Checked = // your logic here
                }

                // Get the latest Discharge Receiving Note for this Emergency_ID
                var dischargeNoteQry = (from rn in db.ReceivingNotes
                                        where rn.Emergency_ID == Emergency_ID &&
                                              rn.Type_Nursing == "Discharge Receiving Note"
                                        orderby rn.ReceivingNoteID descending
                                        select rn).FirstOrDefault();

                if (dischargeNoteQry != null)
                {
                    // Populate Discharge tab (tab07) fields
                    txtPulseRate.Text = dischargeNoteQry.RateBeats ?? "";
                    txtBPDischarge.Text = dischargeNoteQry.BloodPressure ?? "";
                    txtTempdisch.Text = dischargeNoteQry.Temperature ?? "";
                    txtRespRateDesc.Text = dischargeNoteQry.RespirationRate ?? "";
                    txtSaturation_Oxygen2_desc.Text = dischargeNoteQry.O2_Saturation_Oxygen2 ?? "";
                    txtotherecdesc.Text = dischargeNoteQry.OthersRecieveNote ?? "";
                    txtRN_Special_Instruction_Desc.Text = dischargeNoteQry.RN_Special_Instruction ?? "";
                    txtsaturationDis.Text = dischargeNoteQry.O2_Saturation ?? "";
                    txtOxygen1.Text = dischargeNoteQry.O2_Saturation_Oxygen1 ?? "";

                    if (dischargeNoteQry.Receiving_Date.HasValue)
                    {
                        txttxtReceiving_DateDesc.Text = dischargeNoteQry.Receiving_Date.Value.ToString("MM/dd/yyyy hh:mm tt");
                    }

                    // Set dropdown values for discharge
                    if (!string.IsNullOrEmpty(dischargeNoteQry.Emergency_Rhythm))
                    {
                        if (ddlRhythmdischarge.Items.FindByValue(dischargeNoteQry.Emergency_Rhythm) != null)
                        {
                            ddlRhythmdischarge.SelectedValue = dischargeNoteQry.Emergency_Rhythm;
                        }
                    }

                    if (!string.IsNullOrEmpty(dischargeNoteQry.Emergency_Volume))
                    {
                        if (ddlvolumedisc.Items.FindByValue(dischargeNoteQry.Emergency_Volume) != null)
                        {
                            ddlvolumedisc.SelectedValue = dischargeNoteQry.Emergency_Volume;
                        }
                    }

                    // Set discharge checkboxes based on your business logic
                    // chk_OnRoomAirDesc.Checked = // your logic here
                    // chk_WithOxygenDesc.Checked = // your logic here
                }
                if (qry != null)
                {
                    ReferToOPD.Checked = Convert.ToBoolean(qry.Refer_To_OPD);
                    hdfReg_ID.Value = qry.Patient_ID.ToString();
                    vlblPatients_Name.Text = qry.Full_Name;
                    vLbl_Contact.Text = qry.Mobile1;
                    vLbl_Adress.Text = qry.Permanent_Address;
                    vLbl_Age.Text = qry.Age_years;

                    //if (qry.Entry_Date == null)
                    //    vLbl_RegDate.Text = qry.Created_time.Value.ToString(AppConfig.DateFormat);
                    //else
                    //    vLbl_RegDate.Text = qry.Entry_Date.Value.ToString(AppConfig.DateFormat);

                    txtAdmission_Date.Text = qry.Admission_Date.Value.ToString();
                    ddlIssuance_Of.SelectedValue = qry.Issuance_Of;

                    if (qry.Issuance_Of == "002")
                    {
                        // your logic if required
                    }

                    if (qry.Issuance_Of == "001")
                    {
                        ddlWard_No.SelectedValue = qry.Ward_ID.ToString();
                        if (qry.Bed_No != null && qry.Bed_No != 0)
                            txtBed_No.Text = qry.Bed_No.ToString();
                    }

                    ddlDepartment.SelectedValue = qry.Department;
                    ddlPatientCondition.SelectedValue = qry.Emergency_Pat_Condition;
                    txtCallToDoctor.Text = qry.remarks_call_to_doctor;

                    db = new DataBaseDataContext(DBClass.ConnectionString());
                    List<HR_Employee> EmpList = (from tbl in db.HR_Employees
                                                 where tbl.IsDoctor == true
                                                 select tbl).ToList();

                    List<HR_Employee> EmpList2 = (from tbl in db.HR_Employees
                                                  where tbl.IsDoctor == true
                                                  select tbl).ToList();

                    ddlDoctor.Items.Clear();
                    ddlDoctor.DataSource = EmpList;
                    ddlDoctor.DataTextField = "Emp_Name";
                    ddlDoctor.DataValueField = "Emp_ID";
                    ddlDoctor.Items.Add(new ListItem("Please Select", "0"));
                    ddlDoctor.DataBind();
                    ddlDoctor.SelectedValue = qry.Doctor;

                    ddlCallToDoctor.Items.Clear();
                    ddlCallToDoctor.DataSource = EmpList2;
                    ddlCallToDoctor.DataTextField = "Emp_Name";
                    ddlCallToDoctor.DataValueField = "Emp_ID";
                    ddlCallToDoctor.Items.Add(new ListItem("Please Select", "0"));
                    ddlCallToDoctor.DataBind();

                    ddlDischarge_By.Items.Clear();
                    ddlDischarge_By.DataSource = EmpList2;
                    ddlDischarge_By.DataTextField = "Emp_Name";
                    ddlDischarge_By.DataValueField = "Emp_ID";
                    ddlDischarge_By.Items.Add(new ListItem("Please Select", "0"));
                    ddlDischarge_By.DataBind();
                    ddlDischarge_By.SelectedValue = qry.Discharge_By;

                    valueset = DBClass.GetValueSet("Patient Main Category");
                    ddl_Department.DataSource = valueset;
                    ddl_Department.DataTextField = "DataValue_Description";
                    ddl_Department.DataValueField = "DataValue_Name";
                    ddl_Department.Items.Add(new ListItem("Please Select", "0"));
                    ddl_Department.DataBind();

                    //txtMobileNo.Text = Emergency_Doctor_Notes.DoctorMobile;
                    //ddl_Department.SelectedValue = Emergency_Doctor_Notes.Department;
                    //ddlCallToDoctor.SelectedValue = Emergency_Doctor_Notes.DoctorToCall;
                    if (Emergency_Doctor_Notes != null)
                    {
                        txtMobileNo.Text = Emergency_Doctor_Notes.DoctorMobile ?? "";
                        if (!string.IsNullOrEmpty(Emergency_Doctor_Notes.Department) && ddl_Department.Items.FindByValue(Emergency_Doctor_Notes.Department) != null)
                        {
                            ddl_Department.SelectedValue = Emergency_Doctor_Notes.Department;
                        }
                        if (!string.IsNullOrEmpty(Emergency_Doctor_Notes.DoctorToCall) && ddlCallToDoctor.Items.FindByValue(Emergency_Doctor_Notes.DoctorToCall) != null)
                        {
                            ddlCallToDoctor.SelectedValue = Emergency_Doctor_Notes.DoctorToCall;
                        }
                    }
                    else
                    {
                        txtMobileNo.Text = "";
                        ddl_Department.SelectedIndex = 0;
                        ddlCallToDoctor.SelectedIndex = 0;
                    }


                    ddlDischargeStatus.SelectedValue = qry.Discharge_Status;
                    ddlDischarge_By.SelectedValue = qry.Discharge_By;
                    txtVaccinationHistory.Text = qry.Vaccination_History;
                    txtAnyOtherHistory.Text = qry.Other_History;
                    txtProcedureRecommended.Text = qry.Procedure_Recommended;
                    txtIdentificationMarks.Text = qry.IdentificationMarks;
                    txtDiagnosis.Text = qry.Diagnosis;
                    TextBoxCns.Text = qry.CNS_Value;
                    TextBoxCvs.Text = qry.CVS_Value;
                    TextBoxResp.Text = qry.RESP_Value;
                    TextBoxGit.Text = qry.GIT_Value;
                    TextBoxGpe.Text = qry.GPE_Value;

                    if (!string.IsNullOrEmpty(qry.DateOfDeath.ToString()))
                    {
                        txtDateofDeath.Text = Convert.ToDateTime(qry.DateOfDeath.Value).ToString("MM/dd/yyyy");
                    }
                    if (!string.IsNullOrEmpty(qry.TimeOfDeath.ToString()))
                    {
                        txtTimeOfDeath.Text = Convert.ToString(qry.TimeOfDeath);
                    }

                    if (qry.HMFIntact != null)
                    {
                        if (qry.HMFIntact == true)
                        {
                            HMFIntact1.Checked = true;
                        }
                        else
                        {
                            HMFIntact1.Checked = false;
                        }
                    }

                    if (qry.CranialNerves != null)
                    {
                        if (qry.CranialNerves == true)
                        {
                            CranialNerves1.Checked = true;
                        }
                        else
                        {
                            CranialNerves1.Checked = false;
                        }
                    }


                    if (qry.SignsOfMeningism != null)
                    {
                        if (qry.SignsOfMeningism == true)
                        {
                            SignsOfMeningism1.Checked = true;
                        }
                        else
                        {
                            SignsOfMeningism1.Checked = false;
                        }
                    }


                    if (qry.HeartSound != null)
                    {
                        if (qry.HeartSound == true)
                        {
                            HeartSound1.Checked = true;
                        }
                        else
                        {
                            HeartSound1.Checked = false;
                        }
                    }



                    if (qry.Arrhythmias != null)
                    {
                        if (qry.Arrhythmias == true)
                        {
                            Arrhythmias1.Checked = true;
                        }
                        else
                        {
                            Arrhythmias1.Checked = false;
                        }
                    }


                    if (qry.Murmur != null)
                    {
                        if (qry.Murmur == true)
                        {
                            Murmur1.Checked = true;
                        }
                        else
                        {
                            Murmur1.Checked = false;
                        }
                    }


                    if (qry.AnyOtherAddedSound != null)
                    {
                        if (qry.AnyOtherAddedSound == true)
                        {
                            AnyOtherAddedSound1.Checked = true;
                        }
                        else
                        {
                            AnyOtherAddedSound1.Checked = false;
                        }
                    }


                    if (qry.AnyOtherFindings != null)
                    {
                        if (qry.AnyOtherFindings == true)
                        {
                            AnyOtherFindings1.Checked = true;
                        }
                        else
                        {
                            AnyOtherFindings1.Checked = false;
                        }
                    }


                    if (qry.Wheeze != null)
                    {
                        if (qry.Wheeze == true)
                        {
                            Wheeze1.Checked = true;
                        }
                        else
                        {
                            Wheeze1.Checked = false;
                        }
                    }

                    if (qry.Ranchi != null)
                    {
                        if (qry.Ranchi == true)
                        {
                            Ranchi1.Checked = true;
                        }
                        else
                        {
                            Ranchi1.Checked = false;
                        }
                    }



                    if (qry.AnyOtherSound != null)
                    {
                        if (qry.AnyOtherSound == true)
                        {
                            AnyOtherSound1.Checked = true;
                        }
                        else
                        {
                         }
                    }


                    if (qry.AbdomenSoft != null)
                    {
                        if (qry.AbdomenSoft == true)
                        {
                            AbdomenSoft1.Checked = true;
                        }
                        else
                        {
                         }
                    }



                    if (qry.Tenderness != null)
                    {
                        if (qry.Tenderness == true)
                        {
                            Tenderness1.Checked = true;
                        }
                        else
                        {
                         }
                    }



                    if (qry.Guarding != null)
                    {
                        if (qry.Guarding == true)
                        {
                            Guarding1.Checked = true;
                        }
                        else
                        {
                         }
                    }



                    if (qry.BowelSound != null)
                    {
                        if (qry.BowelSound == true)
                        {
                            BowelSound1.Checked = true;
                        }
                        else
                        {
                         }
                    }



                    if (qry.Distention != null)
                    {
                        if (qry.Distention == true)
                        {
                            Distention1.Checked = true;
                        }
                        else
                        {
                         }
                    }



                    if (qry.FluidThrill != null)
                    {
                        if (qry.FluidThrill == true)
                        {
                            FluidThrill1.Checked = true;
                        }
                        else
                        {
                         }
                    }


                    if (qry.ShiftingDullness != null)
                    {
                        if (qry.ShiftingDullness == true)
                        {
                            ShiftingDullness1.Checked = true;
                        }
                        else
                        {
                         }
                    }



                    if (qry.EpigastriaDiscomfort != null)
                    {
                        if (qry.EpigastriaDiscomfort == true)
                        {
                            EpigastriaDiscomfort1.Checked = true;
                        }
                        else
                        {
                         }
                    }


                    if (qry.RetrosternalBurning != null)
                    {
                        if (qry.RetrosternalBurning == true)
                        {
                            RetrosternalBurning1.Checked = true;
                        }
                        else
                        {
                         }
                    }



                    if (qry.Jondus != null)
                    {
                        if (qry.Jondus == true)
                        {
                            Jondus1.Checked = true;
                        }
                        else
                        {
                         }
                    }



                    if (qry.Pallor != null)
                    {
                        if (qry.Pallor == true)
                        {
                            Pallor1.Checked = true;
                        }
                        else
                        {
                         }
                    }




                    if (qry.Dehydration != null)
                    {
                        if (qry.Dehydration == true)
                        {
                            Dehydration1.Checked = true;
                        }
                        else
                        {
                         }
                    }

                    if (qry.GCSOrientation != null)
                    {
                        if (qry.GCSOrientation == true)
                        {
                            GCSOrientation1.Checked = true;
                        }
                        else
                        {
                         }
                    }

                    if (qry.Conscious_Orientely != null)
                    {
                        if (qry.Conscious_Orientely == true)
                        {
                            ConsciousOrientely1.Checked = true;
                        }
                        else
                        {
                         }
                    }

                    if (qry.NVB_Right != null)
                    {
                        if (qry.NVB_Right == true)
                        {
                            NVB_Right1.Checked = true;
                        }
                        else
                        {
                         }
                    }

                    if (qry.NVB_Left != null)
                    {
                        if (qry.NVB_Left == true)
                        {
                            NVB_Left1.Checked = true;
                        }
                        else
                        {
                         }
                    }

                    if (qry.Crepitation_Right != null)
                    {
                        if (qry.Crepitation_Right == true)
                        {
                            Crepitation_Right1.Checked = true;
                        }
                        else
                        {
                         }
                    }

                    if (qry.Crepitation_Left != null)
                    {
                        if (qry.Crepitation_Left == true)
                        {
                            Crepitation_Left1.Checked = true;
                        }
                        else
                        {
                         }
                    }

                    txtFurtherExplanation.Text = qry.FurtherExplanation;
                    txtSaturation_Oxygen1.Text = qry.O2_Saturation_Oxygen1;
                    txtSaturation_Oxygen2.Text = qry.O2_Saturation_Oxygen2;


                    ddlPlaceOfDeath.SelectedValue = qry.PlaceOfDeath;
                    txtCause_Of_Death.Text = qry.CauseOfDeath;
                    txtIssuingOfficerName.Text = qry.IssuingOfficerName;
                    ddlDeathCertifiedbyDr1.SelectedValue = qry.DeathCertifiedBy1;
                    ddlDeathCertifiedbyDr2.SelectedValue = qry.DeathCertifiedBy2;
                    txtBodyHandedOverTo.Text = qry.BodyHandedOverTo;
                    txtFamilyPersonName.Text = qry.FamilyPersonName;
                    txtCNIC.Text = qry.CNIC;
                    txtRelationWithDeceased.Text = qry.RelationWithDeceased;
                    txtCMO_Police.Text = qry.CMO_Police;
                     
                    txtTreatmentAtDischarge.Text = qry.TreatmentAtDischarge;
                    txtFollowUpPlanInstructions.Text = qry.FollowUpPlanInstructions;
                    txtCauseOfReferral.Text = qry.CauseOfReferral;
                     txtTreatmentTime.Text = (qry.TreatmentTime == null) ? "" : qry.TreatmentTime.ToString();
                    ddlReferredTo.SelectedValue = qry.ReferredTo;


                    txtRN_Special_Instruction.Text = qry.RN_Special_Instruction;


                    txtHistoryOfPeresentIllness.Text = qry.HistoryOfPeresentIllness;
                    txtHistoryOfFamily.Text = qry.HistoryOfFamily;
                    txtHistoryOfPastIllness.Text = qry.HistoryOfPastIllness;

                    txtSocioEconomicHistory.Text = qry.SocioEconomicHistory;

                    txtObstetricHistory.Text = qry.ObstetricHistory;
                    txtAllergiesHistory.Text = qry.AllergiesHistory;

                    txtTreatmentHistory.Text = qry.TreatmentHistory;
                    txtDrugHistory.Text = qry.Drug_History;

                    txtBirthHistory.Text = qry.Birth_History;
                   

                    txtPersonalHistory.Text = qry.Personal_History;

 


                   

                    txtPrevention_Precaution.Text = qry.Prevention_Precaution;
                    if (qry.Next_Visit != null)
                        txtNext_Visit.Text = qry.Next_Visit.Value.ToString(AppConfig.DateFormat);
                    if (qry.Discharge_On != null)
                        txtDischarge_On.Text = qry.Discharge_On.Value.ToString(AppConfig.DateFormat);
                    cbDicharg_Slip.Checked = qry.Discharge.Value;
                    if (qry.Discharge_On != null && qry.Discharge == true)
                    {
                     }
                  
                }
            }
            catch (Exception ex)
            {
             
            }
        }

        [WebMethod]
        public static string SaveMedicines(string MedicineDetails)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var MedicineDetail = js.Deserialize<Medicine>(MedicineDetails);

                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    /********************Deleting Previous 0 Value Saved Rows.***********************************/
                    List<In_Patient_Medicine> In_Patient_MedicineList = db.In_Patient_Medicines.Where(i => i.Patient_ID == 0 && i.Transaction_Type == "Emergency Patient").ToList();
                    db.In_Patient_Medicines.DeleteAllOnSubmit(In_Patient_MedicineList);
                    db.SubmitChanges();

                    int couterNewRecords = 0;

                    if (MedicineDetail.PatientID != 0)
                    {
                        /*********************Deleting Previous Entry On Every Insert Or Update*************************/
                        List<In_Patient_Medicine> inPatmedicineList = db.In_Patient_Medicines.Where(p => p.Patient_ID == MedicineDetail.PatientID && p.Transaction_Type == "Emergency Patient").ToList();
                        if (inPatmedicineList != null)
                        {
                            db.In_Patient_Medicines.DeleteAllOnSubmit(inPatmedicineList);
                            couterNewRecords++;
                        }
                    }
                    couterNewRecords = 0;
                    /*********************Inserting New Entry On Every Insert Or Update*************************/
                    foreach (MedicineDetails oIn_Patient_Medicine in MedicineDetail.MedicineList)
                    {
                        In_Patient_Medicine oIn_Patient_Medicine1 = new In_Patient_Medicine()
                        {

                            Patient_ID = Convert.ToInt32(MedicineDetail.PatientID),
                            Item_Code = oIn_Patient_Medicine.ItemCode,
                            Medicine_Name = oIn_Patient_Medicine.Medicine_Name,
                            Transaction_Type = "Emergency Patient",
                            Medicine_Date = oIn_Patient_Medicine.Medicine_Date,
                            Oral = oIn_Patient_Medicine.Oral,
                            Injections = oIn_Patient_Medicine.Injection,
                            Dosage_From = oIn_Patient_Medicine.Dosage_From,
                            AttendingParamedical_Staff = oIn_Patient_Medicine.AttendingParamedical_Staff,
                            Frequency = oIn_Patient_Medicine.Frequency,
                            Dosage_Qty = oIn_Patient_Medicine.Dosage_Qty,
                            Other_Instruction = oIn_Patient_Medicine.Other_Instruction

                        };
                        db.In_Patient_Medicines.InsertOnSubmit(oIn_Patient_Medicine1);
                        couterNewRecords++;
                    }
                    db.SubmitChanges();
                }
            }
            catch (Exception ex)
            {
            }
            return "";
        }
        [WebMethod]
        public static string SaveDischargeMedicines(string MedicineDetails)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var MedicineDetail = js.Deserialize<Medicine>(MedicineDetails);

                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    /********************Deleting Previous 0 Value Saved Rows.***********************************/
                    List<In_Patient_Medicine> In_Patient_MedicineList = db.In_Patient_Medicines.Where(i => i.Patient_ID == 0 && i.Transaction_Type == "Emergency Patient Discharge").ToList();
                    db.In_Patient_Medicines.DeleteAllOnSubmit(In_Patient_MedicineList);
                    db.SubmitChanges();

                    int couterNewRecords = 0;

                    if (MedicineDetail.PatientID != 0)
                    {
                        /*********************Deleting Previous Entry On Every Insert Or Update*************************/
                        List<In_Patient_Medicine> inPatmedicineList = db.In_Patient_Medicines.Where(p => p.Patient_ID == MedicineDetail.PatientID && p.Transaction_Type == "Emergency Patient Discharge").ToList();
                        if (inPatmedicineList != null)
                        {
                            db.In_Patient_Medicines.DeleteAllOnSubmit(inPatmedicineList);
                            couterNewRecords++;
                        }
                    }
                    couterNewRecords = 0;
                    /*********************Inserting New Entry On Every Insert Or Update*************************/
                    foreach (MedicineDetails oIn_Patient_Medicine in MedicineDetail.MedicineList)
                    {
                        In_Patient_Medicine oIn_Patient_Medicine1 = new In_Patient_Medicine()
                        {

                            Patient_ID = Convert.ToInt32(MedicineDetail.PatientID),
                            Item_Code = oIn_Patient_Medicine.ItemCode,
                            Medicine_Name = oIn_Patient_Medicine.Medicine_Name,
                            Transaction_Type = "Emergency Patient Discharge",
                            Medicine_Date = oIn_Patient_Medicine.Medicine_Date,
                            Oral = oIn_Patient_Medicine.Oral,
                            Injections = oIn_Patient_Medicine.Injection,
                            Dosage_From = oIn_Patient_Medicine.Dosage_From,
                            AttendingParamedical_Staff = oIn_Patient_Medicine.AttendingParamedical_Staff,
                            Frequency = oIn_Patient_Medicine.Frequency,
                            Dosage_Qty = oIn_Patient_Medicine.Dosage_Qty,
                            Other_Instruction = oIn_Patient_Medicine.Other_Instruction

                        };
                        db.In_Patient_Medicines.InsertOnSubmit(oIn_Patient_Medicine1);
                        couterNewRecords++;
                    }
                    db.SubmitChanges();
                }
            }
            catch (Exception ex)
            {
            }
            return "";
        }
        [WebMethod]
        public static string SaveTest(string tlist)
        {
            string LabtestID = "";
            Laboratory_Test lt = new Laboratory_Test();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<LabTest>(tlist);
            /********************Deleting Previous 0 Value Saved Rows.***********************************/
            List<Laboratory_Test> Laboratory_TestList = db.Laboratory_Tests.Where(i => i.Patient_ID == 0 && i.Transaction_Type == "Emergency Patient").ToList();
            db.Laboratory_Tests.DeleteAllOnSubmit(Laboratory_TestList);
            db.SubmitChanges();

            if (record.PatientID != null && record.PatientID != "(New)")
            {
                var lstTests = (from t in db.Laboratory_Tests
                                where t.Patient_ID == int.Parse(record.PatientID) && t.Transaction_Type == "Emergency Patient"
                                select t).FirstOrDefault();
                if (lstTests != null)
                {
                    lstTests.Created_Time = DateTime.Now;
                    LabtestID = lstTests.Lab_Test_ID.ToString();
                    lt.Patient_ID = Convert.ToInt32(record.PatientID);
                }
                else
                {
                    lt.Patient_ID = Convert.ToInt32(record.PatientID);
                    lt.Transaction_Type = "Emergency Patient";
                    lt.Created_Time = DateTime.Now;
                    db.Laboratory_Tests.InsertOnSubmit(lt);
                    db.SubmitChanges();
                    LabtestID = lt.Lab_Test_ID.ToString();
                }
            }
            else
            {
                lt.Patient_ID = Convert.ToInt32(record.PatientID);
                lt.Transaction_Type = "Emergency Patient";
                lt.Created_Time = DateTime.Now;
                db.Laboratory_Tests.InsertOnSubmit(lt);
                db.SubmitChanges();
                LabtestID = lt.Lab_Test_ID.ToString();
            }
            /**********Getting Previous details to delete**************/
            var lstTestDetails = db.Lab_Test_Details.Where(t => t.Lab_Test_ID == int.Parse(LabtestID)).ToList();
            var labID = int.Parse(LabtestID);
            DBClass.executeNonQueryWithoutBegin("delete from Lab_Test_Detail where Actual_Patient_ID='" + record.PatID + "'");
            foreach (var test in record.TestList)
            {
                Lab_Test_Detail ltd = new Lab_Test_Detail();

                ltd.Lab_Test_ID = labID;
                ltd.Patient_ID = Convert.ToInt32(record.PatientID);
                var reg_id = (from rg in db.Reg_patients
                              join p in db.Patients on rg.pat_id equals p.Reg_PatId
                              where p.Patient_ID == int.Parse(record.PatID)
                              orderby p.Reg_PatId descending
                              select p.Reg_PatId).FirstOrDefault();


                //ltd.Actual_Patient_ID = Convert.ToInt32(record.PatID);

                ltd.Date = DateTime.Now;
                //ltd.Date = Convert.ToDateTime(test.Date);
                ltd.Test_ID = Convert.ToInt32(test.TestID);
                ltd.Rotation_ID = test.RotationID;
                ltd.L_R_Rotation_ID = test.L_R_Rotation_ID;
                ltd.Catagory_ID = test.Catagory_ID;
                ltd.Dept_ID = test.Dept_ID;
                ltd.Actual_Patient_ID = reg_id;
                ltd.Special_Tests = test.Special_Tests;
                ltd.Area_Of_Interest = test.Area_Of_Interest;
                ltd.Test_Description = test.rotation;
                ltd.showTestDescription = test.showTestDescription;
                bool Duplicate = false;
                Lab_Test_Detail chkasTest = lstTestDetails.Where(tst => tst.Test_ID == ltd.Test_ID && tst.Test_ID != 0).FirstOrDefault();
                if (chkasTest != null)
                {
                    ltd.Recieved_ID = chkasTest.Recieved_ID;
                    ltd.IsBilled = chkasTest.IsBilled;
                    ltd.Is_Result = chkasTest.Is_Result;
                    db.Lab_Test_Details.InsertOnSubmit(ltd);
                    db.SubmitChanges();
                    Duplicate = true;
                }

                if (chkasTest == null)
                {
                    var chkasCategory = lstTestDetails.Where(tst => tst.Catagory_ID == ltd.Catagory_ID && tst.Test_ID == 0).FirstOrDefault();
                    if (chkasCategory != null)
                    {
                        ltd.Recieved_ID = chkasCategory.Recieved_ID;
                        ltd.IsBilled = chkasCategory.IsBilled;
                        ltd.Is_Result = chkasCategory.Is_Result;
                        Duplicate = true;
                        if (chkasCategory != null)
                        {
                            var PrntID = db.Laboratory_Tests.Where(t => t.Parent_Transaction_Type_ID == chkasCategory.Lab_Test_Detail_ID).FirstOrDefault();
                            db.Lab_Test_Details.InsertOnSubmit(ltd);
                            db.SubmitChanges();
                            if (PrntID != null)
                            {
                                PrntID.Parent_Transaction_Type_ID = ltd.Lab_Test_Detail_ID;
                                db.SubmitChanges();
                            }
                        }
                    }
                }
                if (!Duplicate)
                {
                    db.Lab_Test_Details.InsertOnSubmit(ltd);
                    db.SubmitChanges();
                }

            }
            /**********Deleting Previous details**************/
            db.Lab_Test_Details.DeleteAllOnSubmit(lstTestDetails);
            db.SubmitChanges();
            return "";
        }
        [WebMethod]
        public static string SaveSymtoms(string SymtomsList)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var data = js.Deserialize<Symtom>(SymtomsList);
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    if (data.Emergency_Patient_ID == 0)
                        data.Emergency_Patient_ID = data.OutPatientID;

                    int couterNewRecords = 0;
                    List<Sysmtopm> SysmtopmList = db.Sysmtopms.Where(p => p.EmergencyID == data.Emergency_Patient_ID).ToList();
                    if (SysmtopmList != null)
                    {
                        db.Sysmtopms.DeleteAllOnSubmit(SysmtopmList);
                        couterNewRecords++;
                    }
                    couterNewRecords = 0;
                    foreach (SymtomsList oSymtomsList in data.SymtomsList)
                    {
                        Sysmtopm oSysmtopm = new Sysmtopm()
                        {
                            In_Patient_ID = 0,
                            EmergencyID = data.Emergency_Patient_ID,
                            Out_Patient_ID = 0,
                            Symtom_ID = oSymtomsList.SymtomID.Replace(" ", ""),
                            Duration = oSymtomsList.Duration,
                            Days_Years_Months = oSymtomsList.DayYearMonth,
                            Remarks = oSymtomsList.Remarks
                        };
                        db.Sysmtopms.InsertOnSubmit(oSysmtopm);
                        couterNewRecords++;
                    }
                    db.SubmitChanges();
                }
            }
            catch (Exception ex)
            {

            }
            return "";
        }
        public class Symtom
        {
            
                public int OutPatientID { get; set; }
            public int Emergency_Patient_ID { get; set; }
            public List<SymtomsList> SymtomsList { get; set; }
        }
        public class SymtomsList
        {
            public string SymtomID { get; set; }
            public string Duration { get; set; }
            public string DayYearMonth { get; set; }
            public string Remarks { get; set; }
        }
        public class EmergencyPatientData
        {
            public int Emergency_ID { get; set; }
            public int Patient_ID { get; set; }
            public string btnsave { get; set; }
            public string txtAdmission_Date { get; set; }
            public string ddlDepartment { get; set; }
            public string ddlDoctor { get; set; }
            public string ddlCallToDoctor { get; set; }
            public bool ReferToOPD { get; set; }
            public string txtHealth_Complaints { get; set; }
            public string ddlIssuance_Of { get; set; }
            public string ddlWard_No { get; set; }
            public string patienttype { get; set; }
            public string txtBed_No { get; set; }
            public string BP_mm_Hg { get; set; }
            public string Temp_C { get; set; }
            public string Respiration_Min { get; set; }
            public string txtRN_Special_Instruction { get; set; }
            public string txtReceiving_Date { get; set; }
            public string Provisional_Diagnosis { get; set; }
            public string Refer_To_Hospital { get; set; }
            public string Reffer_To { get; set; }
            public string HistoryOfPeresentIllness { get; set; }
            public string HistoryOfFamily { get; set; }
            public string HistoryOfPastIllness { get; set; }
            public string SocioEconomicHistory { get; set; }
            public string Birth_History { get; set; }
            public string Reffer_No { get; set; }
            public string Drug_History { get; set; }
            public string Personal_History { get; set; }
            public string ObstetricHistory { get; set; }
            public string AllergiesHistory { get; set; }
            public string TreatmentHistory { get; set; }
            public string VaccinationHistory { get; set; }
            public string AnyOtherHistory { get; set; }
            public string txtSourceOfReferral { get; set; }
            public string ddlDischarge_By { get; set; }
            public string txtDischarge_On { get; set; }
            public string txtNext_Visit { get; set; }
            public string ddlPatientCondition { get; set; }
            public string txtAdvice { get; set; }
            public bool chkdischarge { get; set; }
            public string RateBeats { get; set; }
            public string Saturation { get; set; }
            public string OthersRN { get; set; }
            public string DischargeStatus { get; set; }
            public string ddlEmrgRhythm { get; set; }
            public string ddlEmrgVolume { get; set; }
            public string Procedure_Recommended { get; set; }
            public string IdentificationMarks { get; set; }
            public string Diagnosis { get; set; }
            public string DateOfDeath { get; set; }
            public string TimeOfDeath { get; set; }
            public string PlaceOfDeath { get; set; }
            public string CauseOfDeath { get; set; }
            public string IssuingOfficerName { get; set; }
            public string DeathCertifiedby1 { get; set; }
            public string DeathCertifiedby2 { get; set; }
            public string BodyHandedOverTo { get; set; }
            public string FamilyPersonName { get; set; }
            public string CNIC { get; set; }
            public string RelationWithDeceased { get; set; }
            public string CMO_Police { get; set; }
            public string TreatmentGiven { get; set; }
            public string PhysicalFinding { get; set; }
            public string GeneralPhysicalExamination { get; set; }
            public string ClinicalSummary { get; set; }
            public string TreatmentAtDischarge { get; set; }
            public string FollowUpPlanInstructions { get; set; }
            public string CauseOfReferral { get; set; }
            public string ReferredTo { get; set; }
            public string TreatmentTime { get; set; }
            public string CallingDoctorDepartment { get; set; }
            public string CallingDoctorMobile { get; set; }
            public string O2_Saturation_Oxygen1 { get; set; }
            public string O2_Saturation_Oxygen2 { get; set; }
            public bool? HMFIntact { get; set; }
            public bool? CranialNerves { get; set; }
            public bool? SignsOfMeningism { get; set; }
            public bool? HeartSound { get; set; }
            public bool? Arrhythmias { get; set; }
            public bool? AnyOtherAddedSound { get; set; }
            public bool? AnyOtherFindings { get; set; }
            public bool? NVB_Right { get; set; }
            public bool? NVB_Left { get; set; }
            public bool? Crepitation_Right { get; set; }
            public bool? Crepitation_Left { get; set; }
            public bool? Wheeze { get; set; }
            public bool? Ranchi { get; set; }
            public bool? AnyOtherSound { get; set; }
            public bool? AbdomenSoft { get; set; }
            public bool? Tenderness { get; set; }
            public bool? Guarding { get; set; }
            public bool? BowelSound { get; set; }
            public bool? Distention { get; set; }
            public bool? FluidThrill { get; set; }
            public bool? ShiftingDullness { get; set; }
            public bool? EpigastriaDiscomfort { get; set; }
            public bool? RetrosternalBurning { get; set; }
            public bool? Jondus { get; set; }
            public bool? Pallor { get; set; }
            public bool? Dehydration { get; set; }
            public bool? GCSOrientation { get; set; }
            public bool? ConsciousOrientely { get; set; }
            public bool? Murmur { get; set; }
            public string FurtherExplanation { get; set; }
            public string TextBoxCns { get; set; }
            public string TextBoxCvs { get; set; }
            public string TextBoxResp { get; set; }
            public string TextBoxGit { get; set; }
            public string TextBoxGpe { get; set; }
            public string PulseRate { get; set; }
            public string BPDischarge { get; set; }
            public string Rhythmdischarge { get; set; }
            public string Tempdisch { get; set; }
            public string volumedisc { get; set; }
            public string RespRateDesc { get; set; }
            public string Oxygen2_desc { get; set; }
            public string saturationDis { get; set; }
            public string Oxygen1 { get; set; }
            public string otherecdesc { get; set; }
            public string Special_Instruction_Desc { get; set; }
            public string Receiving_DateDesc { get; set; }
            public string remrks_call_to_doc { get; set; }
        }
        [WebMethod]
        public static string SaveRecord(EmergencyPatientData data)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    Emergency_Patient OPD;
                    if (data.btnsave == "Save")
                    {
                        OPD = new Emergency_Patient();
                        OPD.Patient_ID = data.Patient_ID;
                        OPD.Admission_Date = !string.IsNullOrEmpty(data.txtAdmission_Date) ?
                            Convert.ToDateTime(data.txtAdmission_Date) : DateTime.Now;
                    }
                    else
                    {
                        // For update, you'll need to pass Emergency_ID in your data class
                         // You should add Emergency_ID to your data class
                        OPD = (from tbl in db.Emergency_Patients
                               where tbl.Emergency_ID == data.Emergency_ID
                               select tbl).FirstOrDefault();
                        if (OPD == null)
                            return "Error: Record not found for update";

                        OPD.Updated_By = AppConfig.UserID;
                        OPD.Updated_Time = DateTime.Now;
                    }

                    string fee = DBClass.getParameter("Emergency Fee")?.ToString() ?? "0";
                    if (fee.Trim() == string.Empty)
                        fee = "0";

                    OPD.Admission_Fees = int.Parse(fee);
                    OPD.Department = data.ddlDepartment ?? "";
                    OPD.isReferred = false;

                    if (data.ddlIssuance_Of == "001")
                    {
                        OPD.Ward_ID = !string.IsNullOrEmpty(data.ddlWard_No) ?
                            Convert.ToInt32(data.ddlWard_No) : 0;

                        OPD.Bed_No = !string.IsNullOrEmpty(data.txtBed_No) && int.TryParse(data.txtBed_No, out int bedNo) ?
                            bedNo : 0;
                    }
                    OPD.Prevention_Precaution = data.txtAdvice;
                    if (DateTime.TryParse(data.txtNext_Visit, out DateTime parsedDate))
                    {
                        OPD.Next_Visit = parsedDate;
                    }
                    else
                    {
                        OPD.Next_Visit = null;
                    }
                    OPD.remarks_call_to_doctor = data.remrks_call_to_doc;
                    OPD.Refer_To_OPD = data.ReferToOPD;
                    OPD.Health_Complaints = data.txtHealth_Complaints ?? "";
                    OPD.Doctor = data.ddlDoctor ?? "";
                    OPD.Emergency_Pat_Condition = data.ddlPatientCondition ?? "01";
                    OPD.Issuance_Of = data.ddlIssuance_Of ?? "";
                    OPD.Discharge_Status = data.DischargeStatus ?? "";
                    OPD.Emergency_Rhythm = data.ddlEmrgRhythm ?? "";
                    OPD.Emergency_Volume = data.ddlEmrgVolume ?? "";
                    OPD.OthersRecieveNote = data.OthersRN ?? "";
                    OPD.O2_Saturation = data.Saturation ?? "";
                    OPD.CallingDoctor_Mobile = data.CallingDoctorMobile ?? "";
                    OPD.O2_Saturation_Oxygen1 = data.O2_Saturation_Oxygen1 ?? "";
                    OPD.O2_Saturation_Oxygen2 = data.O2_Saturation_Oxygen2 ?? "";
                    OPD.HMFIntact = data.HMFIntact;
                    OPD.CranialNerves = data.CranialNerves;
                    OPD.SignsOfMeningism = data.SignsOfMeningism;
                    OPD.HeartSound = data.HeartSound;
                    OPD.Arrhythmias = data.Arrhythmias;
                    OPD.Murmur = data.Murmur;
                    OPD.AnyOtherAddedSound = data.AnyOtherAddedSound;
                    OPD.AnyOtherFindings = data.AnyOtherFindings;
                    OPD.NVB_Right = data.NVB_Right;
                    OPD.NVB_Left = data.NVB_Left;
                    OPD.Crepitation_Right = data.Crepitation_Right;
                    OPD.Crepitation_Left = data.Crepitation_Left;
                    OPD.Wheeze = data.Wheeze;
                    OPD.Ranchi = data.Ranchi;
                    OPD.AnyOtherSound = data.AnyOtherSound;
                    OPD.AbdomenSoft = data.AbdomenSoft;
                    OPD.Tenderness = data.Tenderness;
                    OPD.Guarding = data.Guarding;
                    OPD.BowelSound = data.BowelSound;
                    OPD.Distention = data.Distention;
                    OPD.FluidThrill = data.FluidThrill;
                    OPD.ShiftingDullness = data.ShiftingDullness;
                    OPD.EpigastriaDiscomfort = data.EpigastriaDiscomfort;
                    OPD.RetrosternalBurning = data.RetrosternalBurning;
                    OPD.Jondus = data.Jondus;
                    OPD.Pallor = data.Pallor;
                    OPD.Dehydration = data.Dehydration;
                    OPD.GCSOrientation = data.GCSOrientation;
                    OPD.Conscious_Orientely = data.ConsciousOrientely;
                    OPD.FurtherExplanation = data.FurtherExplanation ?? "";
                    OPD.Procedure_Recommended = data.Procedure_Recommended ?? "";
                    OPD.IdentificationMarks = data.IdentificationMarks ?? "";
                    OPD.Diagnosis = data.Diagnosis ?? "";
                    OPD.Discharge_By = data.ddlDischarge_By;
                    if (!string.IsNullOrEmpty(data.DateOfDeath))
                        OPD.DateOfDeath = Convert.ToDateTime(data.DateOfDeath);

                    if (!string.IsNullOrEmpty(data.TimeOfDeath))
                        OPD.TimeOfDeath = Convert.ToDateTime(data.TimeOfDeath).TimeOfDay;

                    OPD.PlaceOfDeath = data.PlaceOfDeath ?? "";
                    OPD.CauseOfDeath = data.CauseOfDeath ?? "";
                    OPD.IssuingOfficerName = data.IssuingOfficerName ?? "";
                    OPD.DeathCertifiedBy1 = data.DeathCertifiedby1 ?? "";
                    OPD.DeathCertifiedBy2 = data.DeathCertifiedby2 ?? "";
                    OPD.BodyHandedOverTo = data.BodyHandedOverTo ?? "";
                    OPD.FamilyPersonName = data.FamilyPersonName ?? "";
                    OPD.CNIC = data.CNIC ?? "";
                    OPD.RelationWithDeceased = data.RelationWithDeceased ?? "";
                    OPD.CMO_Police = data.CMO_Police ?? "";
                    OPD.TreatmentAtDischarge = data.TreatmentAtDischarge ?? "";
                    OPD.FollowUpPlanInstructions = data.FollowUpPlanInstructions ?? "";
                    OPD.CauseOfReferral = data.CauseOfReferral ?? "";
                    OPD.ReferredTo = data.ReferredTo ?? "";

                    if (!string.IsNullOrEmpty(data.TreatmentTime) && DateTime.TryParse(data.TreatmentTime, out DateTime parsedTime))
                        OPD.TreatmentTime = parsedTime;
                    else
                        OPD.TreatmentTime = DateTime.Now;

                    OPD.CNS_Value = data.TextBoxCns ?? "";
                    OPD.CVS_Value = data.TextBoxCvs ?? "";
                    OPD.RESP_Value = data.TextBoxResp ?? "";
                    OPD.GIT_Value = data.TextBoxGit ?? "";
                    OPD.GPE_Value = data.TextBoxGpe ?? "";
                    OPD.BP_mm_Hg = data.BP_mm_Hg ?? "";
                    OPD.Temp_C = data.Temp_C ?? "";
                    OPD.Respiration_Min = data.Respiration_Min ?? "";
                    OPD.Receiving_date = !string.IsNullOrEmpty(data.txtReceiving_Date) ?
                        Convert.ToDateTime(data.txtReceiving_Date) : DateTime.Now;
                    OPD.RN_Special_Instruction = data.txtRN_Special_Instruction ?? "";
                    OPD.Provisional_Diagnosis = data.Provisional_Diagnosis ?? "";
                    OPD.HistoryOfPeresentIllness = data.HistoryOfPeresentIllness ?? "";
                    OPD.HistoryOfFamily = data.HistoryOfFamily ?? "";
                    OPD.HistoryOfPastIllness = data.HistoryOfPastIllness ?? "";
                    OPD.AllergiesHistory = data.AllergiesHistory ?? "";
                    OPD.TreatmentHistory = data.TreatmentHistory ?? "";
                    OPD.Vaccination_History = data.VaccinationHistory ?? "";
                    OPD.Other_History = data.AnyOtherHistory ?? "";
                    OPD.SocioEconomicHistory = data.SocioEconomicHistory ?? "";
                    OPD.ObstetricHistory = data.ObstetricHistory ?? "";
                    OPD.Birth_History = data.Birth_History ?? "";
                    OPD.Reffer_No = data.Reffer_No ?? "";
                    OPD.Drug_History = data.Drug_History ?? "";
                    OPD.Personal_History = data.Personal_History ?? "";

                    // Set default values for other properties that might be in your database
                    OPD.ENT_Throat_IDL = "";
                    OPD.ENT_Throat_Nose = "";
                    OPD.ENT_Ear_Right = "";
                    OPD.Ent_Ear_Left = "";
                    OPD.ENT_Rinnes_Right_PosNeg = false;
                    OPD.ENT_Rinnes_Lft_PosNeg = false;
                    OPD.ENT_Rinnes_Right_FalseNeg = false;
                    OPD.ENT_Rinnes_Lft_FalseNeg = false;
                    OPD.ENT_Webber_Central = false;
                    OPD.ENT_Webber_Lateralized = false;
                    OPD.ENT_Investigation_PTA = false;
                    OPD.ENT_Investigation_Tympanometry = false;
                    OPD.ENT_Rinnes_Right_Neg = false;
                    OPD.ENT_Rinnes_Lft_Neg = false;
                    OPD.ENT_Rinnes_Right_FNeg = false;
                    OPD.ENT_Rinnes_Lft_FNeg = false;
                    OPD.Psychiatry_Informant = "";
                    OPD.Psychiatry_Source_Referral = "";
                    OPD.Psychiatry_Neck_Holding = false;
                    OPD.Psychiatry_Walking = false;
                    OPD.Psychiatry_Talking = false;
                    OPD.Psychiatry_Others = false;
                    OPD.Psychiatry_Menarche = "";
                    OPD.Psychiatry_Menstrual = "";
                    OPD.Psychiatry_Attachment_Separation = "";
                    OPD.Psychiatry_Health = "";
                    OPD.Psychiatry_Nail_Biting = "";
                    OPD.Psychiatry_Temper_Tantrums = "";
                    OPD.Psychiatry_Bed_Wetting = "";
                    OPD.Psychiatry_Academics = "";
                    OPD.Psychiatry_Peer_Relationship = "";
                    OPD.Psychiatry_Behaviour = "";
                    OPD.Psychiatry_Occupational_History = "";
                    OPD.Psychiatry_Sexual_History = "";
                    OPD.Psychiatry_Substance_Use = "";
                    OPD.Psychiatry_Forensic_Use = "";
                    OPD.Psychiatry_Relationship = "";
                    OPD.Psychiatry_Leisure_Activities = "";
                    OPD.Psychiatry_Attitude_Standards = "";
                    OPD.Psychiatry_Prevalling_Mood = "";
                    OPD.Psychiatry_Reaction_Stress = "";
                    OPD.Psychiatry_Religious_Practices = "";
                    OPD.Psychiatry_Father = "";
                    OPD.Psychiatry_Mother = "";
                    OPD.Psychiatry_Siblings = "";
                    OPD.Psychiatry_Home_Atmosphere = "";
                    OPD.Psychiatry_Familial_Illness = "";
                    OPD.Psychiatry_Actual_age = "";
                    OPD.Psychiatry_Race = "";
                    OPD.Psychiatry_Tattoos_body_scars = "";
                    OPD.Psychiatry_Body_Habitus = "";
                    OPD.Psychiatry_Dress = "";
                    OPD.Psychiatry_Hygiene = "";
                    OPD.Psychiatry_Psychomotor_Activity = "";
                    OPD.Psychiatry_Involuntary_movements = "";
                    OPD.Psychiatry_Dystonia_EPS = "";
                    OPD.Psychiatry_Tardive_dyskinesia = "";
                    OPD.Psychiatry_Tics = "";
                    OPD.Psychiatry_Tremors = "";
                    OPD.Psychiatry_Attentiveness_interview = "";
                    OPD.Psychiatry_Eye_Contact = "";
                    OPD.Psychiatry_Level_Consciousness = "";
                    OPD.Psychiatry_Rate = "";
                    OPD.Psychiatry_Rhythm = "";
                    OPD.Psychiatry_Volume = "";
                    OPD.Psychiatry_Tone = "";
                    OPD.Psychiatry_Modulation = "";
                    OPD.Psychiatry_Depressed = "";
                    OPD.Psychiatry_Elated = "";
                    OPD.Psychiatry_Irritable = "";
                    OPD.Psychiatry_Labile = "";
                    OPD.Psychiatry_Incongruent = "";
                    OPD.Psychiatry_Blunting_Flattening_Apathy = "";
                    OPD.Psychiatry_Thinking = "";
                    OPD.Psychiatry_Plans = "";
                    OPD.Psychiatry_Actions = "";
                    OPD.Psychiatry_Preservative = "";
                    OPD.Psychiatry_LoosAssociation = "";
                    OPD.Psychiatry_Tangentiaility = "";
                    OPD.Psychiatry_Circumstantiality = "";
                    OPD.Psychiatry_Flight_Ideas = "";
                    OPD.Psychiatry_Thought_Insertion = "";
                    OPD.Psychiatry_Thought_Withdrawal = "";
                    OPD.Psychiatry_Thought_Broadcasting = "";
                    OPD.Psychiatry_Thought_Control = "";
                    OPD.Psychiatry_Dellusion = "";
                    OPD.Psychiatry_Overvalued_Ideas = "";
                    OPD.Psychiatry_Depresonalization = "";
                    OPD.Psychiatry_Derealization = "";
                    OPD.Psychiatry_Obsession = "";
                    OPD.Psychiatry_Phobies = "";
                    OPD.Psychiatry_Homocidial_Ideas = "";
                    OPD.Psychiatry_Illusion = "";
                    OPD.Psychiatry_Hallucination = "";
                    OPD.Psychiatry_Orientation_Time = "";
                    OPD.Psychiatry_Place = "";
                    OPD.Psychiatry_Person = "";
                    OPD.Psychiatry_Attention_Concentration = "";
                    OPD.Psychiatry_Days_Week = "";
                    OPD.Psychiatry_Immediate_Memory = "";
                    OPD.Psychiatry_Recent_Events = "";
                    OPD.Psychiatry_Adress_Recall_Two = "";
                    OPD.Psychiatry_Remote_Events = "";
                    OPD.Psychiatry_Adress_Recall_Five = "";
                    OPD.Psychiatry_General_knowledge = "";
                    OPD.Psychiatry_Arthemetic_Calculation = "";
                    OPD.Psychiatry_Abstraction = "";
                    OPD.Psychiatry_Insight = "";
                    OPD.DermaFace = "";
                    OPD.DermaNeck = "";
                    OPD.DermaTrunk = "";
                    OPD.DermaUpperLimb = "";
                    OPD.DermaLowerLimb = "";
                    OPD.DermaFlexures = "";
                    OPD.DermaGenitalias = "";
                    OPD.DermaHair = "";
                    OPD.DermaNail = "";
                    OPD.DermaMucousMembrane = "";
                    OPD.DermaEyes = "";
                    OPD.DermaEars = "";
                    OPD.DermaNose = "";
                    OPD.DermaLips = "";
                    OPD.Psychiatry_HBM_Problem = "";
                    OPD.Psychiatry_HBM_Caused = "";
                    OPD.Psychiatry_HBM_Started = "";
                    OPD.Psychiatry_HBM_Course = "";
                    OPD.Psychiatry_HBM_Treatment = "";
                    OPD.Psychiatry_HBM_Effects = "";
                    OPD.Psychiatry_PE_Pluse = "";
                    OPD.Psychiatry_PE_BP = "";
                    OPD.Psychiatry_PE_Temperature = "";
                    OPD.Psychiatry_PE_Weight = "";
                    OPD.Psychiatry_PE_RespiratoryRate = "";
                    OPD.Psychiatry_PE_Jaundice = "";
                    OPD.Psychiatry_PE_Anemia = "";
                    OPD.Psychiatry_PE_Cyanosis = "";
                    OPD.Psychiatry_PE_Clubbing = "";
                    OPD.Psychiatry_PE_JVP = "";
                    OPD.Psychiatry_PE_LymphNodes = "";
                    OPD.Psychiatry_PE_Edema = "";
                    OPD.Psychiatry_PE_Respiratory = "";
                    OPD.Psychiatry_PE_Cardiovascular = "";
                    OPD.Psychiatry_PE_Gastro_Intestinal = "";
                    OPD.Psychiatry_PE_Observation = "";
                    OPD.Psychiatry_PE_Cranial_Nerves = "";
                    OPD.Psychiatry_PE_Limb_Strength = "";
                    OPD.Psychiatry_PE_Spasticity = "";
                    OPD.Psychiatry_PE_Position = "";
                    OPD.Psychiatry_PE_Vibration = "";
                    OPD.Psychiatry_PE_Stereognosis = "";
                    OPD.Psychiatry_PE_Pain = "";
                    OPD.Psychiatry_PE_Biceps = "";
                    OPD.Psychiatry_PE_Triceps = "";
                    OPD.Psychiatry_PE_Brachioradialis = "";
                    OPD.Psychiatry_PE_Quadriceps = "";
                    OPD.Psychiatry_PE_Patellar = "";
                    OPD.Psychiatry_PE_Achilles = "";
                    OPD.Psychiatry_PE_Extensor = "";
                    OPD.Psychiatry_PE_Frontal = "";
                    OPD.Psychiatry_PE_Finger = "";
                    OPD.Psychiatry_PE_Heel = "";
                    OPD.Psychiatry_PE_Movements = "";
                    OPD.Psychiatry_PE_Gait = "";
                    OPD.Psychiatry_PE_Neck_Rigidity = false;
                    OPD.Psychiatry_PE_Kerning_Sign = false;
                    OPD.Psychiatry_PE_Brudzinki_Sign = false;
                    OPD.Psychiatry_For_Summary = "";
                    OPD.Psychiatry_For_Diagnosis = "";
                    OPD.Psychiatry_For_AxisI = "";
                    OPD.Psychiatry_For_AxisII = "";
                    OPD.Psychiatry_For_AxisIII = "";
                    OPD.Psychiatry_For_AxisIV = "";
                    OPD.Psychiatry_For_AxisV = "";
                    OPD.Psychiatry_For_PredisposingFactors = "";
                    OPD.Psychiatry_For_PrecipitatingFactors = "";
                    OPD.Psychiatry_For_PrepetuatingFactors = "";
                    OPD.Psychiatry_For_Investigation = "";
                    OPD.Psychiatry_For_Medical = "";
                    OPD.Psychiatry_For_Psychological = "";
                    OPD.Psychiatry_Major_Issues = "";
                    OPD.Psychiatry_For_Strengths = "";
                    OPD.Psychiatry_For_Goals = "";
                    OPD.Psychiatry_For_Strategies = "";

                    OPD.Peads_weight = "";
                    OPD.Peads_Length = "";
                    OPD.Peads_HC = "";
                    OPD.Peads_General_Appearance = "";
                    OPD.Peads_Cyanosis = false;
                    OPD.Peads_Jaundice = false;
                    OPD.Peads_Lethargy = false;
                    OPD.Peads_Rash = false;
                    OPD.Peads_Others = "";
                    OPD.Peads_Caput = false;
                    OPD.Peads_Cephalhematoma = false;
                    OPD.Peads_Anterioropen = false;
                    OPD.Peads_AnteriorClose = false;
                    OPD.Peads_Dextrocardia = false;
                    OPD.Peads_Bulging = false;
                    OPD.Peads_Murmur = false;
                    OPD.Peads_HeartSound = "";
                    OPD.Peads_Nasal = false;
                    OPD.Peads_Recessions = false;
                    OPD.Peads_AddedSounds = "";
                    OPD.Peads_Flat = false;
                    OPD.Peads_Distended = false;
                    OPD.Peads_Scaphoid = false;
                    OPD.Peads_Liver = false;
                    OPD.Peads_Spleen = false;
                    OPD.Peads_GITOthers = "";
                    OPD.Peads_Sucking = false;
                    OPD.Peads_Rooting = false;
                    OPD.Peads_Moro = false;
                    OPD.Peads_CNSOthers = "";
                    OPD.Peads_FullTerm = false;
                    OPD.Peads_PreTerm = false;
                     OPD.Peads_TimeOfDelivery = "";
                    OPD.Peads_Booked = false;
                    OPD.Peads_UnBooked = false;
                    OPD.Peads_DAIHandling = false;
                    OPD.Peads_ANTURash = false;
                    OPD.Peads_PIH = false;
                    OPD.Peads_GDM = false;
                    OPD.Peads_Vacinated = false;
                    OPD.Peads_ANTOthers = "";
                    OPD.Peads_SVD = false;
                    OPD.Peads_LSCS = false;
                    OPD.Peads_Emergency = false;
                    OPD.Peads_Elective = false;
                    OPD.Peads_PlaceOfDelivery = "";
                    OPD.Peads_IndicationForLSCS = "";
                    OPD.Peads_apgerScore1min = "";
                    OPD.Peads_apgerScore5min = "";
                    OPD.Peads_Resuscitation = false;
                    OPD.Peads_NatalOthers = "";
                    OPD.Peads_Moaning = false;
                    OPD.Peads_RespDistress = false;
                    OPD.Peads_PostNATALCyanosis = false;
                    OPD.Peads_Fits = false;
                    OPD.Peads_ReluctanceToFeed = false;
                    OPD.Peads_PostNatalOthers = "";
                    if (data.btnsave == "Save")
                    {
                        OPD.Book_ID = AppConfig.Book_ID;
                        OPD.Created_By = AppConfig.UserID;
                        OPD.Created_Time = DateTime.Now;
                        OPD.Company_ID = AppConfig.Company_ID;
                        db.Emergency_Patients.InsertOnSubmit(OPD);
                    }

                    db.SubmitChanges();

                    // Handle related records
                    if ((!string.IsNullOrEmpty(data.CallingDoctorDepartment) && data.CallingDoctorDepartment != "0") ||
                        (!string.IsNullOrEmpty(data.ddlCallToDoctor) && data.ddlCallToDoctor != "0") ||
                        (!string.IsNullOrEmpty(data.CallingDoctorMobile) && data.CallingDoctorMobile != "____-_______") ||
                        (!string.IsNullOrEmpty(data.remrks_call_to_doc)))
                    {
                        Emergency_Doctor_Note edn = new Emergency_Doctor_Note();
                        edn.Department = data.CallingDoctorDepartment ?? "";
                        edn.DoctorToCall = data.ddlCallToDoctor ?? "";
                        edn.DoctorMobile = data.CallingDoctorMobile ?? "";
                        edn.DoctorNotes = data.remrks_call_to_doc ?? "";
                        edn.EmergencyId = OPD.Emergency_ID;
                        edn.PatientId = data.Patient_ID;
                        db.Emergency_Doctor_Notes.InsertOnSubmit(edn);
                        db.SubmitChanges();
                    }

                    // Handle receiving notes
                    if (data.RateBeats != "" || data.ddlEmrgRhythm != "0" || data.ddlEmrgVolume != "0" ||
                        data.OthersRN != "" || data.BP_mm_Hg != "" || data.Temp_C != "" ||
                        data.Respiration_Min != "" || data.Saturation != "" || data.txtRN_Special_Instruction != "")
                    {
                        ReceivingNote rcvNote = new ReceivingNote();
                        rcvNote.Patient_ID = data.Patient_ID;
                        rcvNote.Emergency_ID = OPD.Emergency_ID;
                        rcvNote.RateBeats = data.RateBeats ?? "";
                        rcvNote.Emergency_Rhythm = data.ddlEmrgRhythm ?? "";
                        rcvNote.Emergency_Volume = data.ddlEmrgVolume ?? "";
                        rcvNote.OthersRecieveNote = data.OthersRN ?? "";
                        rcvNote.BloodPressure = data.BP_mm_Hg ?? "";
                        rcvNote.Temperature = data.Temp_C ?? "";
                        rcvNote.RespirationRate = data.Respiration_Min ?? "";
                        rcvNote.O2_Saturation = data.Saturation ?? "";
                        rcvNote.RN_Special_Instruction = data.txtRN_Special_Instruction ?? "";
                        rcvNote.Receiving_Date = !string.IsNullOrEmpty(data.txtReceiving_Date) ?
                            Convert.ToDateTime(data.txtReceiving_Date) : DateTime.Now;
                        rcvNote.O2_Saturation_Oxygen1 = data.O2_Saturation_Oxygen1 ?? "";
                        rcvNote.O2_Saturation_Oxygen2 = data.O2_Saturation_Oxygen2 ?? "";
                        rcvNote.user_id = AppConfig.UserID;
                        rcvNote.Type_Nursing = "Receiving Note Emergency";
                        db.ReceivingNotes.InsertOnSubmit(rcvNote);
                        db.SubmitChanges();
                    }

                    // Handle discharge receiving notes
                    if (data.PulseRate != "" || data.Rhythmdischarge != "0" || data.volumedisc != "0" ||
                        data.otherecdesc != "" || data.BPDischarge != "" || data.Tempdisch != "" ||
                        data.RespRateDesc != "" || data.Oxygen2_desc != "" || data.Special_Instruction_Desc != "")
                    {
                        ReceivingNote rcvNote = new ReceivingNote();
                        rcvNote.Patient_ID = data.Patient_ID;
                        rcvNote.Emergency_ID = OPD.Emergency_ID;
                        rcvNote.RateBeats = data.PulseRate ?? "";
                        rcvNote.Emergency_Rhythm = data.Rhythmdischarge ?? "";
                        rcvNote.Emergency_Volume = data.volumedisc ?? "";
                        rcvNote.OthersRecieveNote = data.otherecdesc ?? "";
                        rcvNote.BloodPressure = data.BPDischarge ?? "";
                        rcvNote.Temperature = data.Tempdisch ?? "";
                        rcvNote.RespirationRate = data.RespRateDesc ?? "";
                        rcvNote.O2_Saturation = data.saturationDis ?? "";
                        rcvNote.RN_Special_Instruction = data.Special_Instruction_Desc ?? "";
                        rcvNote.Receiving_Date = !string.IsNullOrEmpty(data.Receiving_DateDesc) ?
                            Convert.ToDateTime(data.Receiving_DateDesc) : DateTime.Now;
                        rcvNote.O2_Saturation_Oxygen1 = data.Oxygen1 ?? "";
                        rcvNote.O2_Saturation_Oxygen2 = data.Oxygen2_desc ?? "";
                        rcvNote.user_id = AppConfig.UserID;
                        rcvNote.Type_Nursing = "Discharge Receiving Note";
                        db.ReceivingNotes.InsertOnSubmit(rcvNote);
                        db.SubmitChanges();
                    }
                   
                    // Update related records with the new Out_Patient_ID
                    UpdateRelatedRecords(db, OPD.Emergency_ID);
                    return OPD.Emergency_ID.ToString();
                }
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }
        private static void UpdateRelatedRecords(DataBaseDataContext db, int outPatientId)
        {
            // Update medicines
            var medicines = db.In_Patient_Medicines
                .Where(p => p.Patient_ID == 0 && (p.Transaction_Type == "Emergency Patient" || p.Transaction_Type == "Emergency Patient Discharge"))
                .ToList();
            foreach (var med in medicines)
            {
                med.Patient_ID = outPatientId;
            }
 

            // Update lab tests
            var labTest = db.Laboratory_Tests
                .FirstOrDefault(p => p.Patient_ID == 0 && p.Transaction_Type == "OutPatient");
            if (labTest != null)
            {
                labTest.Patient_ID = outPatientId;
            }

          
            db.SubmitChanges();
        }

        [WebMethod]
        public static string LoadSymtompsHistory(int EmergencyID)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var OutPatientlist = (
                from s in db.Sysmtopms
                where s.EmergencyID == EmergencyID
                select new { s.Symtom_ID, Symtom_Name = (DBClass.getField("select Datavalue_Description from ValueSet vs,DataValues dv where                                            vs.ValueSet_ID=dv.ValueSet_ID and vs.ValueSet_Name='Symtoms' and dv.DataValue_Name='" + s.Symtom_ID + "'").ToString()), s.Duration, Days_Years_Months = db.GetDataValueName("Days_Years_Months", s.Days_Years_Months), s.Remarks }
                ).ToList();


            List<SysmtopmsHistoryClass> list = new List<SysmtopmsHistoryClass>();


            foreach (var item in OutPatientlist)
            {
                SysmtopmsHistoryClass obj = new SysmtopmsHistoryClass();

                obj.Symtom_ID = item.Symtom_ID;
                obj.Duration = item.Duration;
                obj.Symtom_Name = item.Symtom_Name;
                obj.Days_Years_Months = item.Days_Years_Months;
                obj.Remarks = item.Remarks;
                obj.Status = "Emergency";
                list.Add(obj);
            }
            return (new JavaScriptSerializer().Serialize(list));
        }
        public class SysmtopmsHistoryClass
        {
            public string Symtom_ID;
            public string Symtom_Name;
            public string Duration;
            public string Days_Years_Months;
            public DateTime Created_Time;

            public string Remarks;
            public string Status;


        }
        [WebMethod]
        public static string GetTestList(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var testDetailst = (from lbtM in db.Laboratory_Tests
                                join lbtD in db.Lab_Test_Details
                                on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                               
                                where lbtM.Patient_ID == id && lbtM.Transaction_Type == "Emergency Patient"
                                select new
                                {
                                    lbtD.Lab_Test_Detail_ID,
                                    lbtD.Date,
                                    lbtD.Remark,
                                    lbtD.Catagory_ID,
                                    lbtM.Lab_Test_ID,
                                    lbtD.Test_ID,
                                    lbtD.Dept_ID,
                                    lbtD.L_R_Rotation_ID,
                                    Test_Name = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Test_Name).FirstOrDefault(),
                                    Value_Type = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Value_Type).FirstOrDefault(),
                                    Value_TypeGroup = (from t in db.Lab_Tests where t.Group_Category == lbtD.Catagory_ID select t.Value_Type).FirstOrDefault(),
                                    Group_Department = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Group_Department).FirstOrDefault(),
                                    Group_Category = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Group_Category).FirstOrDefault(),
                                    DepartmentName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test Departments", t.Main_Department)).FirstOrDefault(),
                                    Department_ID = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Main_Department).FirstOrDefault(),
                                    GroupName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Test Groups", t.Group_Category)).FirstOrDefault(),
                                    Group_Name = db.GetDataValueName("Test Groups", lbtD.Catagory_ID),
                                    lbtD.Rotation_ID,
                                    Rotation = ((from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test Departments", t.Main_Department)).FirstOrDefault()) == "X-Ray" ? db.GetDataValueName("Test XRay Rotations", lbtD.Rotation_ID) : db.GetDataValueName("Test CT Scan Rotations", lbtD.Rotation_ID),
                                    DataValue_Description = (from dv in db.DataValues
                                                             join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                                             where vs.ValueSet_Name == ("Test XRay Rotations").ToString() && dv.DataValue_Name == lbtD.Rotation_ID
                                                             select dv.DataValue_Description).FirstOrDefault(),
                                    lbtD.Special_Tests,
                                    lbtD.Area_Of_Interest,
                                    lbtD.Recieved_ID,
                                    lbtD.Is_Result,

                                }
                ).ToList();
            return (new JavaScriptSerializer()).Serialize(testDetailst);
        }

        [WebMethod]
        public static string LoadMedicines(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                List<In_Patient_Medicine> inPatmedicineList = db.In_Patient_Medicines.Where(p => p.Patient_ID == PatientID && p.Transaction_Type == "Emergency Patient").ToList();
                return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
            }
            return "";
        }
        [WebMethod]
        public static string LoadDischargeMedicines(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                List<In_Patient_Medicine> inPatmedicineList = db.In_Patient_Medicines.Where(p => p.Patient_ID == PatientID && p.Transaction_Type == "Emergency Patient Discharge").ToList();
                return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
            }
            return "";
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
        public static List<PatientsResult> AddPatient(string SearchString)
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
        [WebMethod]
        public static Detail GetDetail(string PatientID)
        {
        
            Detail pt = new Detail();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Reg_patient pat = new Reg_patient();
            pat = (from tbl in db.Reg_patients
                   where tbl.pat_id.ToString() == PatientID
                   orderby tbl.Created_time descending
                   select tbl).FirstOrDefault();

            Emergency_Patient EmerPat = db.Emergency_Patients
     .FirstOrDefault(tbl => tbl.Patient_ID.ToString() == PatientID);
            var EmergencypatientID = "0";
            if (EmerPat != null && EmerPat.Emergency_ID.ToString() != "0")
            {
                EmergencypatientID = EmerPat.Emergency_ID.ToString();
            }

            if (pat != null)
            {
                pt.EmergencyID = EmergencypatientID ?? "0"; // This replaces null with "0"
                pt.Name = pat.Full_Name;
                pt.Gender = pat.Gender;
                pt.Reg_Patient_ID = pat.pat_id;
                pt.Age = pat.Age_years.ToString();
                
                pt.Address = pat.Permanent_Address;
                pt.Mobile = pat.Mobile1;
               
               
                pt.Gender = db.GetDataValueName("Gender", pat.Gender);
                
                return pt;
            }
            else
                return pt;
        }
        public class Detail
        {
            public string EmergencyID;
            public int Reg_Patient_ID;
            public string Name;
            public string Gender;
            public string Age;
            public string Mobile;
            public string Address;
 
        }
        [WebMethod]
        public static string GetPatients(string searchValue)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var patients = (from p in db.Reg_patients
                                    where (p.Patient_No != null && p.Patient_No.ToString().Contains(searchValue))
                                          || (p.Full_Name != null && p.Full_Name.Contains(searchValue))
                                    select new
                                    {
                                        PatientNo = p.Patient_No,
                                        FullName = p.Full_Name,
                                        RegID = p.pat_id,
                                    }).Take(5).ToList();

                    return new JavaScriptSerializer().Serialize(patients);
                }
            }
            catch (Exception ex)
            {
                // Log error if needed
                return new JavaScriptSerializer().Serialize(new { error = ex.Message });
            }
        }
        [WebMethod]
        public static string GetRotationsCategoryWise(string testCategory)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dep = from dv in db.DataValues
                      join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                      where vs.ValueSet_Name == testCategory
                      select new { dv.DataValue_Name, dv.DataValue_Description };

            return (new JavaScriptSerializer()).Serialize(dep);
        }
        [WebMethod]
        public static string FillTestsByCategory(string CategoryID, string searchTerm)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var tests = from t in db.Lab_Tests
                        where t.Main_Department == CategoryID && t.Active == true
                        select new { t.Test_ID, t.Test_Name };

            // Apply search filter if searchTerm is not empty
            if (!string.IsNullOrEmpty(searchTerm))
            {
                tests = tests.Where(t => t.Test_Name.ToLower().Contains(searchTerm.ToLower()));
            }

            return (new JavaScriptSerializer()).Serialize(tests);
        }

        [WebMethod]
        public static string GetTemplateMedicine(int Templateid)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var dpt = (from dt in db.Doctor_Template_Masters
                       join dtm in db.Doctor_Template_Medicines
                       on dt.Template_Id equals dtm.Template_Id
                       join mt in db.Medicines_Templates
                       on dtm.Medicine_id equals mt.Item_Code
                       where dt.Template_Id == Templateid
                       select new
                       {
                           mt.Medicine_Date,
                           mt.Medicine_Name,
                           mt.Dosage_From,
                           mt.Dosage_Qty,
                           mt.AttendingParamedical_Staff,
                           mt.Item_Code,
                           mt.Other_Instruction,
                           mt.Frequency,
                           mt.Injections,
                           mt.Oral,
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
        }

        [WebMethod]
        public static string GetTemplate(string searchString)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var dpt = (from d in db.Doctor_Template_Masters
                       join hr in db.HR_Employees
on d.Doctor_Id equals hr.Emp_ID
                       where hr.userid == Convert.ToString(AppConfig.UserID) && d.isActive == true
                       select new
                       {
                           d.Template_Id,
                           d.Template_Name
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
        }

        [WebMethod]
        public static string FillRoutesDropDown()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Routes = from d in db.DataValues
                         join v in db.ValueSets
                         on d.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Name == "Routes"
                         select new
                         {
                             d.DataValue_Name,
                             d.DataValue_Description
                         };
            return (new JavaScriptSerializer().Serialize(Routes));
        }
        [WebMethod]
        public static string FillFrequencyDropDown()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Routes = from d in db.DataValues
                         join v in db.ValueSets
                         on d.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Name == "Frequency"
                         select new
                         {
                             d.DataValue_Name,
                             d.DataValue_Description,
                             d.Segment1
                         };
            return (new JavaScriptSerializer().Serialize(Routes));
        }
        [WebMethod]
        public static string FillDosageDropDown()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Routes = from d in db.DataValues
                         join v in db.ValueSets
                         on d.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Name == "Dosage Form"
                         select new
                         {
                             d.DataValue_Name,
                             d.DataValue_Description,

                         };
            return (new JavaScriptSerializer().Serialize(Routes));
        }
        [WebMethod]
        public static string FillDosageQty()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Routes = from d in db.DataValues
                         join v in db.ValueSets
                         on d.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Name == "Dosage Quantity"
                         select new
                         {
                             d.DataValue_Name,
                             d.DataValue_Description,

                         };
            return (new JavaScriptSerializer().Serialize(Routes));
        }
        [WebMethod]
        public static string FillOtherInstruction()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Routes = from d in db.DataValues
                         join v in db.ValueSets
                         on d.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Name == "Other Instruction"
                         select new
                         {
                             d.DataValue_Name,
                             DataValue_Description = d.Segment1,

                         };
            return (new JavaScriptSerializer().Serialize(Routes));
        }
        [WebMethod]
        public static string getpharmacyitems(string searchString)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                IQueryable<INV_Item> query = db.INV_Items.Where(d => d.IsPharmacyItem == true);

                if (!string.IsNullOrEmpty(searchString))
                {
                    query = query.Where(d => d.Description.Contains(searchString));
                }

                var pharmacyItems = query.OrderByDescending(d => d.Item_ID)
                                       .Select(d => new
                                       {
                                           d.Item_ID,
                                           d.Item_Code,
                                           Description = d.Description,
                                           d.InventoryOrg
                                       }).Take(10)
                                       .ToList();
                var result = new List<object>();
                foreach (var item in pharmacyItems)
                {
                    decimal totalStock = db.GetInvenrtoryItemUomTotalStock(item.Item_ID, item.InventoryOrg) ?? 0;

                    result.Add(new
                    {
                        Item_Code = item.Item_Code,
                        Description = item.Description,
                        TotalStock = totalStock,
                        StockDisplay = totalStock > 0 ? totalStock.ToString("0.##") : "Out of Stock",
                        StockStatus = totalStock > 0 ? "In Stock" : "Out of Stock"
                    });
                }

                return (new JavaScriptSerializer().Serialize(result));
            }
        }
        [WebMethod]
        public static string FillTestMainDepartment()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var dpt = (from d in db.DataValues
                       join v in db.ValueSets
                       on d.ValueSet_ID equals v.ValueSet_ID
                       where v.ValueSet_Name == "Main Test Departments"
                       && d.DataValue_Name != "001"
                       select new
                       {
                           d.DataValue_Name,
                           d.DataValue_Description
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
        }
        [WebMethod]
        public static string GetLabTestDDLDetails(string SerialNo, string maindpt)
        {
            string groupCategory = string.Empty;
            string testName = SerialNo;

            string[] testFullName = SerialNo.Split('|');
            if (testFullName.Length > 1)
            {
                testName = testFullName[0];
                groupCategory = DBClass.getField("select Datavalue_Name from Datavalues where valueset_ID = 70 and Datavalue_Description = '" + testFullName[1].Trim() + "'").ToString();
            }

            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var test = (from t in db.Lab_Tests
                        where t.Main_Department == maindpt && t.Test_Name == testName && t.Group_Category == groupCategory
                        select new
                        {
                            t.Test_ID,
                            t.Rate, /*= DBClass.getField(""),t.Test_Name*/
                            Test_Name = SerialNo,
                            t.Group_Category,
                            TestMainDepartmentName = db.GetDataValueName("Main Test Departments", t.Main_Department.ToString()).ToString(),
                            GroupCategoryName = db.GetDataValueName("Test Groups", t.Group_Category.ToString()).ToString(),


                        }).ToList();
            var count = test.Count;

            if (count != 0)
            {

                return (new JavaScriptSerializer()).Serialize(test);

            }
            else
            {
                var GroupCategories = (from dv in db.DataValues
                                       join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                       where vs.ValueSet_Name == "Test Groups" && dv.DataValue_Description == SerialNo
                                       select new
                                       {
                                           Test_ID = 0,
                                           Group_Category = dv.DataValue_Name,
                                           Test_Name = dv.DataValue_Description,
                                           TestMainDepartmentName = "Lab Test",
                                           Main_Department = "001",
                                           Rate = dv.Segment1,


                                       }).ToList();
                return (new JavaScriptSerializer()).Serialize(GroupCategories);

            }
        }
        [WebMethod]
        public static string GetLabTests(string searchValue)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            // Get tests with optional search filter
            var testsQuery = from t in db.Lab_Tests
                             where t.Main_Department == "001"
                             && t.Active == true
                             select t;

            if (!string.IsNullOrEmpty(searchValue))
            {
                testsQuery = testsQuery.Where(t => t.Test_Name.Contains(searchValue));
            }

            var tests = testsQuery.Select(t => new {
                t.Test_ID,
                Test_Name = t.Test_Name,
                t.Group_Category
            });

            List<TestIDsAndGroupCategory> listOfTest = new List<TestIDsAndGroupCategory>();
            int counter = 1;

            // Process tests (same as original)
            foreach (var test in tests)
            {
                TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                obj.TestID = test.Test_ID.ToString();
                obj.TestName = test.Test_Name.ToString() +
                              (test.Group_Category != string.Empty ?
                               " | " + DBClass.getField("select Datavalue_Description from Datavalues where Datavalue_Name = '" + test.Group_Category + "' and Valueset_ID = 70") :
                               string.Empty);
                obj.SerialNo = counter.ToString();
                obj.IsGroupCategory = false;
                listOfTest.Add(obj);
                counter++;
            }

            // Only add categories if no search value (maintain original behavior)
            if (string.IsNullOrEmpty(searchValue))
            {
                var GroupCategories = from dv in db.DataValues
                                      join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                      where vs.ValueSet_Name == "Test Groups" && dv.Division == "001"
                                      select new { dv.DataValue_Name, dv.DataValue_Description };

                foreach (var category in GroupCategories)
                {
                    TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                    obj.TestID = category.DataValue_Name.ToString();
                    obj.TestName = category.DataValue_Description.ToString();
                    obj.SerialNo = counter.ToString();
                    obj.IsGroupCategory = true;
                    obj.CategoryID = category.DataValue_Name;
                    listOfTest.Add(obj);
                    counter++;
                }
            }

            return (new JavaScriptSerializer()).Serialize(listOfTest);
        }
        public class TestIDsAndGroupCategory
        {
            public string TestID { get; set; }
            public string TestName { get; set; }
            public string SerialNo { get; set; }
            public string CategoryID { get; set; }
            public bool IsGroupCategory { get; set; }
            public string GroupName { get; set; }
            public string MainDepartmentName { get; set; }
        }

        public class Medicine
        {
            public int Pat { get; set; }
            public int PatientID { get; set; }
            public List<MedicineDetails> MedicineList { get; set; }
        }
        public class MedicineDetails
        {
            public DateTime Medicine_Date { get; set; }
            public string Medicine_Name { get; set; }
            public string Recomended_Dosage { get; set; }
            public string Dosage_From { get; set; }
            public string Oral { get; set; }
            public string Injection { get; set; }
            public string AttendingParamedical_Staff { set; get; }
            public string Frequency { set; get; }
            public string ItemCode { get; set; }
            public string Dosage_Qty;
            public string Other_Instruction;
        }

        public class TestValue
        {
            public string Date { get; set; }
            public string TestID { get; set; }
            public string RotationID { get; set; }
            public string L_R_Rotation_ID { get; set; }
            public string Catagory_ID { get; set; }
            public string Dept_ID { get; set; }
            public string Special_Tests { get; set; }
            public string Area_Of_Interest { get; set; }
            public string rotation { get; set; }
            public bool showTestDescription { get; set; }
        }
        public class LabTest
        {
            public string PatientID { get; set; }
            public string PatID { get; set; }
            public List<TestValue> TestList { get; set; }
        }

        [WebMethod]
        public static string Get_Doctor(string department_Id)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            List<HR_Employee> EmpList = new List<HR_Employee>();
            EmpList = (from tbl in db.HR_Employees
                       where (tbl.IsDoctor == true
                       && tbl.Department == department_Id)
                       select tbl).ToList();
            return (new JavaScriptSerializer().Serialize(EmpList));
        }
        [WebMethod]
        public static string Get_Doctor_Mobile(string DoctorId)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            string Number = (from tbl in db.HR_Employees
                             where (tbl.IsDoctor == true
                             && tbl.Emp_ID == Convert.ToInt32(DoctorId))
                             select tbl.Mobile).FirstOrDefault();

            return Number;
        }
        protected void btnGet_Doctor_Click(object sender, EventArgs e)
        {
            db = new DataBaseDataContext(DBClass.ConnectionString());
            List<HR_Employee> EmpList = new List<HR_Employee>();
            EmpList = (from tbl in db.HR_Employees
                       where (tbl.IsDoctor == true
                       && tbl.Department == ddlDepartment.SelectedValue && (tbl.Designation == "004" || tbl.Designation == "005" || tbl.Designation == "005" || tbl.Designation == "006" || tbl.Designation == "007" || tbl.Designation == "008"))
                       select tbl).ToList();
            ddlDoctor.Items.Clear();
            ddlDoctor.DataSource = EmpList;
            ddlDoctor.DataTextField = "Emp_Name";
            ddlDoctor.DataValueField = "Emp_ID";
            ddlDoctor.Items.Add(new ListItem("Please Select", "0"));
            ddlDoctor.DataBind();

            ddlDischarge_By.Items.Clear();
            ddlDischarge_By.DataSource = EmpList;
            ddlDischarge_By.DataTextField = "Emp_Name";
            ddlDischarge_By.DataValueField = "Emp_ID";
            ddlDischarge_By.Items.Add(new ListItem("Please Select", "0"));
            ddlDischarge_By.DataBind();

        }
        protected void btnAllocatedRoomWardChkTriggerBtn_Click(object sender, EventArgs e)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var countOfRoomRows = db.Room_Allocatrion_Histories.Where(m => m.Patient_ID == Convert.ToInt32(hdfReg_ID)).Count();
            var countOfWardRows = db.Ward_Allocatrion_Histories.Where(m => m.Patient_ID == Convert.ToInt32(hdfReg_ID)).Count();
            if (countOfRoomRows > 0 || countOfWardRows > 0)
            {
                if (countOfRoomRows > 0)
                {
                    var lastRowRoom = db.Room_Allocatrion_Histories.Where(m => m.Patient_ID == Convert.ToInt32(hdfReg_ID)).Skip(countOfRoomRows - 1).FirstOrDefault();
                    if (lastRowRoom != null)
                    {
                        var roomType = (from rm in db.Rooms
                                        join dv in db.DataValues on rm.Room_Type equals dv.DataValue_Name
                                        join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                        where rm.Room_ID == lastRowRoom.Room_ID && vs.ValueSet_Name == "Room Type"
                                        select new
                                        {
                                            dv.DataValue_Description
                                        }).FirstOrDefault();
                        ddlIssuance_Of.Enabled = true;

                        ddlIssuance_Of.SelectedIndex = 0;
                        ddlIssuance_Of.Enabled = false;

                        vlblCurrent_Allocated_Room_Ward.Text = "";
                        vlblCurrent_Allocated_Room_Ward.CssClass = "Success";
                    }
                }
                else
                {

                }
                if (countOfWardRows > 0)
                {
                    var lastRowWard = db.Ward_Allocatrion_Histories.Where(m => m.Patient_ID == Convert.ToInt32(hdfReg_ID)).Skip(countOfWardRows - 1).FirstOrDefault();
                    if (lastRowWard != null)
                    {
                        ddlIssuance_Of.CausesValidation = false;
                        ddlIssuance_Of.Enabled = true;
                        ddlWard_No.Enabled = true;
                        ddlWard_No.SelectedValue = lastRowWard.Ward_ID.ToString();
                        ddlIssuance_Of.SelectedIndex = 0;
                        ddlIssuance_Of.Enabled = false;
                        ddlWard_No.Enabled = false;
                        ddlWard_No.CssClass = "dropdownBackgroud";
                        txtBed_No.Text = lastRowWard.Bed_No.ToString();
                        txtBed_No.ReadOnly = true;
                        vlblCurrent_Allocated_Room_Ward.Text = "";
                        vlblCurrent_Allocated_Room_Ward.CssClass = "Success";
                    }
                }
                else
                {
                    ddlWard_No.Enabled = false;
                    ddlWard_No.CssClass = "dropdownBackgroud";
                    txtBed_No.Text = "";
                    txtBed_No.ReadOnly = true;
                }
            }
            else
            {
                ddlIssuance_Of.Enabled = true;
                ddlIssuance_Of.CssClass = "dropdownBackgroudWhite";
                vlblCurrent_Allocated_Room_Ward.Text = "No Room And Ward Assigned.";
                vlblCurrent_Allocated_Room_Ward.CssClass = "Error";
            }
        }
        public class Beds
        {
            public int WardID { get; set; }
            public int PatientNo { get; set; }
            public int BedNo { get; set; }
        }
        [WebMethod]
        public static string FillWardBeds(int WardID)
        {
            List<Beds> bdsList = new List<Beds>();
            if (WardID > 0)
            {
                DataBaseDataContext db = new DataBaseDataContext();
                int Beds = (int)(from bds in db.Ward_Definitions
                                 where bds.Ward_ID == WardID
                                 select bds.No_Of_Beds
                            ).SingleOrDefault();
                List<Ward_Allocation> Ward_AllocationList = db.Ward_Allocations.Where(w => w.Ward_ID == WardID).ToList();
                for (int i = 1; i <= Beds; i++)
                {
                    var patID = (from p in db.Ward_Allocations
                                 where p.Bed_No_Assigned == (int)(i) && p.Ward_ID == WardID && p.IsDischarge == false
                                 select p.Patient_ID).FirstOrDefault();
                    if (patID == null)
                    {
                        patID = 0;
                    }
                    else
                    {
                        patID = (from p in db.Reg_patients
                                 where p.pat_id == patID
                                 select p.Patient_No).FirstOrDefault();
                    }
                    if (patID == null)
                    {
                        patID = 0;
                    }

                    Beds b = new Beds();
                    b.BedNo = i;
                    b.PatientNo = (int)patID;
                    b.WardID = WardID;
                    bdsList.Add(b);
                }
            }
            return (new JavaScriptSerializer().Serialize(bdsList));
        }



        [WebMethod]
        public static bool SaveSymptoms(List<SymptomData> symptoms)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    // 1. Delete ALL existing symptom categorizations
                    db.SymptomsCategorizations.DeleteAllOnSubmit(db.SymptomsCategorizations);
                    db.SubmitChanges();
                    foreach (var symptom in symptoms)
                    {

                        SymptomsCategorization newSymptom = new SymptomsCategorization
                        {
                            CategoryId = symptom.DepartmentId,
                            SymptomId = symptom.SymptomId,
                            CreatedBy = AppConfig.UserID.ToString(),
                            CreatedTime = DateTime.Now
                        };
                        db.SymptomsCategorizations.InsertOnSubmit(newSymptom);

                        db.SubmitChanges();
                    }
                }
                return true;
            }
            catch (Exception ex)
            {

                return false;
            }
        }
        [WebMethod]
        public static string GetSymptomsData()
            {
            try
            {

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var result = (from dv in db.DataValues
                                  join ds in db.ValueSets on dv.ValueSet_ID equals ds.ValueSet_ID
                                  join sc in db.SymptomsCategorizations on dv.DataValue_Name equals sc.SymptomId
                                  where ds.ValueSet_Name == "Symtoms"
                                  select new
                                  {
                                      SymptomId = sc.SymptomId,
                                      Description = dv.DataValue_Description,
                                      CategoryId = sc.CategoryId
                                  }).ToList();

                    return new JavaScriptSerializer().Serialize(result);
                }


            }
            catch (Exception ex)
            {
                return "[]";
            }
        }
        public class SymptomData
        {
            public string DepartmentId { get; set; }
            public string SymptomId { get; set; }
        }
        [WebMethod]
        public static string GetSymptoms(string searchValue)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var query = from dv in db.DataValues
                        join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                        where vs.ValueSet_Name == "Symtoms"
                        select dv;

            // If searchValue is not null or empty, apply the filter
            if (!string.IsNullOrEmpty(searchValue))
            {
                query = query.Where(dv => dv.DataValue_Description.ToLower().Contains(searchValue.ToLower())).Take(5);
            }
            else
            {
                // Return only 5 records when no search value is provided
                query = query.Take(5);
            }

            // Project to anonymous type to avoid serialization issues
            var result = query.Select(dv => new {
                DataValue_Name = dv.DataValue_Name,
                DataValue_Description = dv.DataValue_Description
                // Add other fields you need
            }).ToList();

            return (new JavaScriptSerializer()).Serialize(result);
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
        public static string GetCategorizedSymptoms(string categoryId, string searchValue)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    // Base query
                    var query = from dv in db.DataValues
                                join ds in db.ValueSets on dv.ValueSet_ID equals ds.ValueSet_ID
                                join sc in db.SymptomsCategorizations on dv.DataValue_Name equals sc.SymptomId
                                where ds.ValueSet_Name == "Symtoms"
                                      && sc.CategoryId == categoryId
                                select new
                                {
                                    SymptomId = sc.SymptomId,
                                    Description = dv.DataValue_Description,

                                };

                    // Apply search filter if provided
                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        query = query.Where(x => x.Description.ToLower().Contains(searchValue.ToLower()));
                    }

                    // Execute query based on categoryId
                    var resultList = query.ToList();


                    return new JavaScriptSerializer().Serialize(resultList);
                }
            }
            catch (Exception ex)
            {
                // Log error
                System.Diagnostics.Debug.WriteLine($"Error in GetCategorizedSymptoms: {ex}");
                return "[]"; // Return empty array on error
            }
        }

        [WebMethod]
        public static string SaveNewSymptom(string name)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                try
                {
                    // Get the maximum DataValueName where ValueSet_ID = 1083
                    int? maxValue = db.DataValues
                        .Where(dv => dv.ValueSet_ID == 1083)
                        .Max(dv => (int?)Convert.ToInt32((dv.DataValue_Name)));

                    // If no records found, start with 1, otherwise increment the max value
                    int newValue = (maxValue.HasValue) ? maxValue.Value + 1 : 1;

                    // Create new DataValue record
                    DataValue newSymptom = new DataValue
                    {
                        ValueSet_ID = 1083,
                        DataValue_Name = newValue.ToString(),
                        DataValue_Description = name,
                        // Add other required fields with default values if needed
                        // For example:
                        // IsActive = true,
                        // CreatedDate = DateTime.Now
                    };

                    db.DataValues.InsertOnSubmit(newSymptom);
                    db.SubmitChanges();

                    return "Symptom saved successfully";
                }
                catch (Exception ex)
                {
                    // Log the error if needed
                    return "Error saving symptom: " + ex.Message;
                }
            }
        }
    }
}