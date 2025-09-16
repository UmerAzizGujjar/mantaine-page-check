using System;
using System.Collections.Generic;
using System.Data;
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


            }
            else
            {
            }
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
                        data.Emergency_Patient_ID = Convert.ToInt32(DBClass.getField("select (isnull(max(Emergency_ID),0)+1) from Emergency_Patient").ToString());

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
        [WebMethod]
        public static string SaveRecord(int Patient_ID, string btnsave, string txtAdmission_Date, string ddlDepartment, string ddlDoctor, string ddlCallToDoctor, string txtHealth_Complaints, string ddlIssuance_Of, string ddlWard_No, string txtBed_No, string RateBeats, string BP_mm_Hg, string Temp_C, string Respiration_Min, string txtRN_Special_Instruction, string txtReceiving_Date, string Provisional_Diagnosis, string Reffer_To, string HistoryOfPeresentIllness, string HistoryOfFamily, string HistoryOfPastIllness, string SocioEconomicHistory, string Birth_History, string Reffer_No, string Drug_History, string Personal_History, string ObstetricHistory, string AllergiesHistory, string TreatmentHistory, string VaccinationHistory, string AnyOtherHistory, string ENT_Throat_IDL, string ENT_Throat_Nose, string ENT_Ear_Right, string Ent_Ear_Left, bool ENT_Rinnes_Right_PosNeg, bool ENT_Rinnes_Lft_PosNeg, bool ENT_Rinnes_Right_FalseNeg, bool ENT_Rinnes_Lft_FalseNeg, bool ENT_Webber_Central, bool ENT_Webber_Lateralized, bool ENT_Investigation_PTA, bool ENT_Investigation_Tympanometry, bool ENT_Rinnes_Right_Neg, bool ENT_Rinnes_Lft_Neg, bool ENT_Rinnes_Right_FNeg, bool ENT_Rinnes_Lft_FNeg, string txtInformant, string txtSourceOfReferral, bool chkNeckHolding, bool chkWalking, bool chkTalking, bool chkOthers, string txtMenarche, string txtMenstrual, string txtAttachmentSeparationfromParents, string txtHealth, bool chkNailBiting, bool chkTemperTantrums, bool chkBedWetting, string txtAcademics, string txtPeerRelationship, string txtBehaviour, string txtOccupationalHistory, string txtMaritalRelationshipSexualHistory, string txtSubstanceUse, string txtForensicUse, string txtRelationship, string txtLeisureActivities, string txtAttitudetoSelfandStandards, string txtPrevallingMood, string txtReactionPattrentoStress, string txtReligiousPracticesAttitute, string txtFather, string txtMother, string txtSiblings, string txtHomeAtmosphererelationshipsocialclass, string txtFamilialIllness, string txtActualandapparentage, string txtRace, string txtTattoosbodypiercingandscars, string txtBodyHabitus, string txttxtDress, string txtHygiene, string txtPsychomotorActivity, string txtInvoluntarymovements, string txtDystoniaEPS, string txtTardivedyskinesia, string txtTics, string txtTremors, string txtAttentivenesstointerview, string txtEyeContact, string txtLevelofConsciousness, string txtRate, string txtRhythm, string txtVolume, string txtTone, string txtModulationvar, string txtDepressed, string txtElated, string txtIrritable, string txtLabile, string txtIncongruent, string txtbluntingflatteningapathy, string txtThinkingPremeditation, string txtPlans,
           string txtActions, string txtPreservative, string txtLoosAssociation, string txtTangentiaility, string txtCircumstantiality, string txtFlightofIdeas, string txtThoughtInsertion, string txtThoughtWithdrawal, string txtThoughBroadcasting, string txtThoughControl, string txtDellusion, string txtovervaluedideas, string txtDepresonalization, string txtDerealization, string txtthrougObsession, string txtthrougPhobies, string txtthrougHomocidialIdeas, string txtillusion, string txtHallucinationAuditoryVisualOlfactoryGustatoryTactile, string txtorientationtime, string txtplace, string txtperson, string txtAttentionConcentrationSerial7Test, string txtOrDaysOfWeekReverseOrder, string txtImmediatememory, string txtshorttermrecentevents, string txtadressrecallafter2minutes, string txtlongtermremoteevents, string txtadressrecallafter5minues, string txtgeneralknowledgequestion, string txtsimplearthemeticcalculation, string txtabstrationconcertethinking, string txtinsight, string DermaFace, string DermaNeck, string DermaTrunk, string DermaUpperLimb, string DermaLowerLimb, string DermaFlexures, string DermaGenitalias, string DermaHair, string DermaNail, string DermaMucousMembrane, string DermaEyes, string DermaEars, string DermaNose, string DermaLips, string HBM_Problem, string HBM_Caused, string HBM_Started, string HBM_Course, string HBM_Treatment, string HBM_Effects, string PE_Pluse, string PE_BP, string PE_Temperature, string PE_Weight, string PE_RespiratoryRate, string PE_Jaundice, string PE_Anemia, string PE_Cyanosis, string PE_Clubbing, string PE_JVP, string PE_LymphNodes, string PE_Edema, string PE_Respiratory, string PE_Cardiovascular, string PE_Gastro_Intestinal, string PE_Observation, string PE_Cranial_Nerves, string PE_Limb_Strength, string PE_Spasticity, string PE_Position, string PE_Vibration, string PE_Stereognosis, string PE_Pain, string PE_Biceps, string PE_Triceps, string PE_Brachioradialis, string PE_Quadriceps, string PE_Patellar, string PE_Achilles, string PE_Extensor, string PE_Frontal, string PE_Finger, string PE_Heel, string PE_Movements, string PE_Gait, bool PE_Neck_Rigidity, bool PE_Kerning_Sign, bool PE_Brudzinki_Sign, string For_Summary, string For_Diagnosis, string For_AxisI, string For_AxisII, string For_AxisIII, string For_AxisIV, string For_AxisV, string For_PredisposingFactors, string For_PrecipitatingFactors, string For_PrepetuatingFactors, string For_Investigation, string For_Medical, string For_Psychological, string For_Major_Issues, string For_Strengths, string For_Goals, string For_Strategies, string txtPeads_weight, string txtPeads_Length, string txtPeads_HC, string txtPeads_General_Appearance, bool chkPeads_Cyanosis, bool chkPeads_Jaundice, bool chkPeads_Lethargy, bool chkPeads_Rash, string txtPeads_Others, bool chkPeads_Caput, bool chkPeads_Cephalhematoma, bool rdbPeads_Anterioropen, bool rdbPeads_AnteriorClose, bool chkPeads_Dextrocardia, bool chkPeads_Bulging, bool chkPeads_Murmur, string txtPeads_HeartSound, bool chkPeads_Nasal, bool chkPeads_Recessions, string txtPeads_AddedSounds, bool rdbPeads_Flat, bool rdbPeads_Distended, bool rdbPeads_Scaphoid, bool chkPeads_Liver, bool chkPeads_Spleen, string txtPeads_GITOthers, bool chkPeads_Sucking, bool chkPeads_Rooting, bool chkPeads_Moro, string txtPeads_CNSOthers, bool chkPeads_FullTerm, bool chkPeads_PreTerm, DateTime txtPeads_DateOfDelivery, string txtPeads_TimeOfDelivery, bool rdbPeads_Booked, bool rdbPeads_UnBooked, bool chkPeads_DAIHandling, bool chkPeads_ANTURash, bool chkPeads_PIH, bool chkPeads_GDM, bool chkPeads_Vacinated, string txtPeads_ANTOthers, bool rdbPeads_SVD, bool rdbPeads_LSCS, bool rdbPeads_Emergency, bool rdbPeads_Elective, string txtPeads_PlaceOfDelivery, string txtPeads_IndicationForLSCS, string Peads_apgerScore1min, string Peads_apgerScore5min, bool chkPeads_Resuscitation, string txtPeads_NatalOthers, bool chkPeads_Moaning, bool chkPeads_RespDistress, bool chkPeads_PostNATALCyanosis, bool chkPeads_Fits, bool chkPeads_ReluctanceToFeed, string txtPeads_PostNatalOthers, string txtDischarge_On, string ddlDischarge_By, string txtNext_Visit, string ddlPatientCondition, string txtAdvice, bool chkdischarge, string patienttype, string Saturation, string OthersRN, string DischargeStatus, string ddlEmrgRhythm, string ddlEmrgVolume, string Procedure_Recommended, string IdentificationMarks, string Diagnosis, string DateOfDeath, string TimeOfDeath, string PlaceOfDeath, string CauseOfDeath, string IssuingOfficerName, string DeathCertifiedby1, string DeathCertifiedby2, string BodyHandedOverTo, string FamilyPersonName, string CNIC, string RelationWithDeceased, string CMO_Police, string TreatmentGiven, string PhysicalFinding, string GeneralPhysicalExamination, string ClinicalSummary, string TreatmentAtDischarge, string FollowUpPlanInstructions, string CauseOfReferral, string ReferredTo, string TreatmentTime, string CallingDoctorDepartment, string CallingDoctorMobile, string O2_Saturation_Oxygen1, string O2_Saturation_Oxygen2, bool? HMFIntact, bool? CranialNerves, bool? SignsOfMeningism, bool? HeartSound, bool? Arrhythmias, bool? Murmur, bool? AnyOtherAddedSound, bool? AnyOtherFindings, bool? NVB_Right, bool? NVB_Left, bool? Crepitation_Right, bool? Crepitation_Left, bool? Wheeze, bool? Ranchi, bool? AnyOtherSound, bool? AbdomenSoft, bool? Tenderness, bool? Guarding, bool? BowelSound, bool? Distention, bool? FluidThrill, bool? ShiftingDullness, bool? EpigastriaDiscomfort, bool? RetrosternalBurning, bool? Jondus, bool? Pallor, bool? Dehydration, bool? GCSOrientation, bool? ConsciousOrientely, string FurtherExplanation, string ID, string TextBoxCns, string TextBoxCvs, string TextBoxResp, string TextBoxGit, string TextBoxGpe, string eye_response, string motor_response, string verbal_Response, string accumulated_response, string PulseRate, string BPDischarge, string Rhythmdischarge, string Tempdisch, string volumedisc, string RespRateDesc, string Oxygen2_desc, string saturationDis, string Oxygen1, string otherecdesc, string Special_Instruction_Desc, string Receiving_DateDesc, string remrks_call_to_doc, bool ReferToOPD)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    Emergency_Patient OPD;
                    if (btnsave == "Save")
                    {
                        OPD = new Emergency_Patient();
                        OPD.Patient_ID = Convert.ToInt32(Patient_ID);
                        OPD.Admission_Date = Convert.ToDateTime(txtAdmission_Date);

                    }
                    else
                    {

                        OPD = (from tbl in db.Emergency_Patients
                               where tbl.Emergency_ID == Convert.ToInt32(ID)
                               select tbl).FirstOrDefault();
                        OPD.Updated_By = AppConfig.UserID;
                        OPD.Updated_Time = DateTime.Now;
                    }
                    string fee = DBClass.getParameter("Emergency Fee").ToString();
                    if (fee.Trim() == string.Empty)
                        fee = "0";

                    OPD.Admission_Fees = int.Parse(fee);


                    OPD.Department = ddlDepartment;

                    #region old Code don't delete

                    #endregion

                    OPD.isReferred = false;
                    if (ddlIssuance_Of == "001")
                    {
                        OPD.Ward_ID = Convert.ToInt32(ddlWard_No);
                        if (string.IsNullOrWhiteSpace(txtBed_No))
                        {
                            OPD.Bed_No = 0; // or null if nullable
                        }
                        else if (int.TryParse(txtBed_No, out int bedNo))
                        {
                            OPD.Bed_No = bedNo;
                        }

                    }
                    else
                    {

                    }
                    if (ReferToOPD == null)
                    {
                        OPD.Refer_To_OPD = Convert.ToBoolean(0);
                    }
                    else
                    {
                        OPD.Refer_To_OPD = ReferToOPD;
                    }
                    //OPD.Refer_To_OPD = ReferToOPD;
                    OPD.Health_Complaints = txtHealth_Complaints;
                    OPD.Doctor = ddlDoctor;
                    OPD.Emergency_Pat_Condition = ddlPatientCondition;

                    OPD.Issuance_Of = ddlIssuance_Of;

                    OPD.Discharge_Status = DischargeStatus;
                    OPD.Emergency_Rhythm = ddlEmrgRhythm;
                    OPD.Emergency_Volume = ddlEmrgVolume;
                    OPD.OthersRecieveNote = OthersRN;
                    OPD.O2_Saturation = Saturation;

                    OPD.CallingDoctor_Mobile = CallingDoctorMobile;
                    OPD.O2_Saturation_Oxygen1 = O2_Saturation_Oxygen1;
                    OPD.O2_Saturation_Oxygen2 = O2_Saturation_Oxygen2;
                    OPD.HMFIntact = HMFIntact;
                    OPD.CranialNerves = CranialNerves;
                    OPD.SignsOfMeningism = SignsOfMeningism;
                    OPD.HeartSound = HeartSound;
                    OPD.Arrhythmias = Arrhythmias;
                    OPD.Murmur = Murmur;
                    OPD.AnyOtherAddedSound = AnyOtherAddedSound;
                    OPD.AnyOtherFindings = AnyOtherFindings;
                    OPD.NVB_Right = NVB_Right;
                    OPD.NVB_Left = NVB_Left;
                    OPD.Crepitation_Right = Crepitation_Right;
                    OPD.Crepitation_Left = Crepitation_Left;
                    OPD.Wheeze = Wheeze;
                    OPD.Ranchi = Ranchi;
                    OPD.AnyOtherSound = AnyOtherSound;
                    OPD.AbdomenSoft = AbdomenSoft;
                    OPD.Tenderness = Tenderness;
                    OPD.Guarding = Guarding;
                    OPD.BowelSound = BowelSound;
                    OPD.Distention = Distention;
                    OPD.FluidThrill = FluidThrill;
                    OPD.ShiftingDullness = ShiftingDullness;
                    OPD.EpigastriaDiscomfort = EpigastriaDiscomfort;
                    OPD.RetrosternalBurning = RetrosternalBurning;
                    OPD.Jondus = Jondus;
                    OPD.Pallor = Pallor;
                    OPD.Dehydration = Dehydration;
                    OPD.GCSOrientation = GCSOrientation;
                    OPD.Conscious_Orientely = ConsciousOrientely;
                    OPD.FurtherExplanation = FurtherExplanation;

                    OPD.Procedure_Recommended = Procedure_Recommended;
                    OPD.IdentificationMarks = IdentificationMarks;
                    OPD.Diagnosis = Diagnosis;
                    if (!string.IsNullOrEmpty(DateOfDeath))
                    {
                        OPD.DateOfDeath = Convert.ToDateTime(DateOfDeath);
                    }
                    if (!string.IsNullOrEmpty(TimeOfDeath))
                    {
                        OPD.TimeOfDeath = Convert.ToDateTime(TimeOfDeath).TimeOfDay;
                    }
                    OPD.PlaceOfDeath = PlaceOfDeath;
                    OPD.CauseOfDeath = CauseOfDeath;
                    OPD.IssuingOfficerName = IssuingOfficerName;
                    OPD.DeathCertifiedBy1 = DeathCertifiedby1;
                    OPD.DeathCertifiedBy2 = DeathCertifiedby2;
                    OPD.BodyHandedOverTo = BodyHandedOverTo;
                    OPD.FamilyPersonName = FamilyPersonName;
                    OPD.CNIC = CNIC;
                    OPD.RelationWithDeceased = RelationWithDeceased;
                    OPD.CMO_Police = CMO_Police;

                    OPD.TreatmentAtDischarge = TreatmentAtDischarge;
                    OPD.FollowUpPlanInstructions = FollowUpPlanInstructions;
                    OPD.CauseOfReferral = CauseOfReferral;
                    OPD.ReferredTo = ReferredTo;
                    DateTime parsedTime;
                    if (DateTime.TryParse(TreatmentTime, out parsedTime))
                    {
                        OPD.TreatmentTime = parsedTime;
                    }
                    else
                    {

                        OPD.TreatmentTime = DateTime.Now;
                    }
                    //OPD.TreatmentTime = Convert.ToDateTime(TreatmentTime);
                    OPD.CNS_Value = TextBoxCns;
                    OPD.CVS_Value = TextBoxCvs;
                    OPD.RESP_Value = TextBoxResp;
                    OPD.GIT_Value = TextBoxGit;
                    OPD.GPE_Value = TextBoxGpe;

                    OPD.BP_mm_Hg = BP_mm_Hg;
                    OPD.Temp_C = Temp_C;
                    OPD.Respiration_Min = Respiration_Min;
                    OPD.Eye_Opening_Response = eye_response;
                    OPD.Motor_Response = motor_response;
                    OPD.Verbal_Response = verbal_Response;
                    OPD.Accumulated_Response = accumulated_response;

                    OPD.Receiving_date = Convert.ToDateTime(txtReceiving_Date);
                    OPD.RN_Special_Instruction = txtRN_Special_Instruction;
                    OPD.Provisional_Diagnosis = Provisional_Diagnosis;
                    OPD.HistoryOfPeresentIllness = HistoryOfPeresentIllness;
                    OPD.HistoryOfFamily = HistoryOfFamily;
                    OPD.HistoryOfPastIllness = HistoryOfPastIllness;

                    OPD.AllergiesHistory = AllergiesHistory;
                    OPD.TreatmentHistory = TreatmentHistory;
                    OPD.Vaccination_History = VaccinationHistory;
                    OPD.Other_History = AnyOtherHistory;
                    OPD.SocioEconomicHistory = SocioEconomicHistory;


                    OPD.ObstetricHistory = ObstetricHistory;

                    OPD.Birth_History = Birth_History;


                    OPD.Reffer_No = Reffer_No;
                    OPD.Drug_History = Drug_History;
                    OPD.Personal_History = Personal_History;

                    OPD.ENT_Throat_IDL = ENT_Throat_IDL.ToString();
                    OPD.ENT_Throat_Nose = ENT_Throat_Nose.ToString();
                    OPD.ENT_Ear_Right = ENT_Ear_Right.ToString();
                    OPD.Ent_Ear_Left = Ent_Ear_Left.ToString();
                    OPD.ENT_Rinnes_Right_PosNeg = ENT_Rinnes_Right_PosNeg;
                    OPD.ENT_Rinnes_Lft_PosNeg = ENT_Rinnes_Lft_PosNeg;
                    OPD.ENT_Rinnes_Right_FalseNeg = ENT_Rinnes_Right_FalseNeg;
                    OPD.ENT_Rinnes_Lft_FalseNeg = ENT_Rinnes_Lft_FalseNeg;
                    OPD.ENT_Webber_Central = ENT_Webber_Central;
                    OPD.ENT_Webber_Lateralized = ENT_Webber_Lateralized;
                    OPD.ENT_Investigation_PTA = ENT_Investigation_PTA;
                    OPD.ENT_Investigation_Tympanometry = ENT_Investigation_Tympanometry;
                    OPD.ENT_Rinnes_Right_Neg = ENT_Rinnes_Right_Neg;
                    OPD.ENT_Rinnes_Lft_Neg = ENT_Rinnes_Lft_Neg;
                    OPD.ENT_Rinnes_Right_FNeg = ENT_Rinnes_Right_FNeg;
                    OPD.ENT_Rinnes_Lft_FNeg = ENT_Rinnes_Lft_FNeg;
                    OPD.Psychiatry_Informant = txtInformant;
                    OPD.Psychiatry_Source_Referral = txtSourceOfReferral;
                    OPD.Psychiatry_Neck_Holding = chkNeckHolding;
                    OPD.Psychiatry_Walking = chkWalking;
                    OPD.Psychiatry_Talking = chkTalking;
                    OPD.Psychiatry_Others = chkOthers;
                    OPD.Psychiatry_Menarche = txtMenarche;
                    OPD.Psychiatry_Menstrual = txtMenstrual;
                    OPD.Psychiatry_Attachment_Separation = txtAttachmentSeparationfromParents;
                    OPD.Psychiatry_Health = txtHealth;
                    OPD.Psychiatry_Nail_Biting = chkNailBiting.ToString();
                    OPD.Psychiatry_Temper_Tantrums = chkTemperTantrums.ToString();
                    OPD.Psychiatry_Bed_Wetting = chkBedWetting.ToString();
                    OPD.Psychiatry_Academics = txtAcademics;
                    OPD.Psychiatry_Peer_Relationship = txtPeerRelationship;
                    OPD.Psychiatry_Behaviour = txtBehaviour;
                    OPD.Psychiatry_Occupational_History = txtOccupationalHistory;
                    OPD.Psychiatry_Sexual_History = txtMaritalRelationshipSexualHistory;
                    OPD.Psychiatry_Substance_Use = txtSubstanceUse;
                    OPD.Psychiatry_Forensic_Use = txtForensicUse;
                    OPD.Psychiatry_Relationship = txtRelationship;
                    OPD.Psychiatry_Leisure_Activities = txtLeisureActivities;
                    OPD.Psychiatry_Attitude_Standards = txtAttitudetoSelfandStandards;
                    OPD.Psychiatry_Prevalling_Mood = txtPrevallingMood;
                    OPD.Psychiatry_Reaction_Stress = txtReactionPattrentoStress;
                    OPD.Psychiatry_Religious_Practices = txtReligiousPracticesAttitute;
                    OPD.Psychiatry_Father = txtFather;
                    OPD.Psychiatry_Mother = txtMother;
                    OPD.Psychiatry_Siblings = txtSiblings;
                    OPD.Psychiatry_Home_Atmosphere = txtHomeAtmosphererelationshipsocialclass;
                    OPD.Psychiatry_Familial_Illness = txtFamilialIllness;
                    OPD.Psychiatry_Actual_age = txtActualandapparentage;
                    OPD.Psychiatry_Race = txtRace;
                    OPD.Psychiatry_Tattoos_body_scars = txtTattoosbodypiercingandscars;
                    OPD.Psychiatry_Body_Habitus = txtBodyHabitus;
                    OPD.Psychiatry_Dress = txttxtDress;
                    OPD.Psychiatry_Hygiene = txtHygiene;
                    OPD.Psychiatry_Psychomotor_Activity = txtPsychomotorActivity;
                    OPD.Psychiatry_Involuntary_movements = txtInvoluntarymovements;
                    OPD.Psychiatry_Dystonia_EPS = txtDystoniaEPS;
                    OPD.Psychiatry_Tardive_dyskinesia = txtTardivedyskinesia;
                    OPD.Psychiatry_Tics = txtTics;
                    OPD.Psychiatry_Tremors = txtTremors;
                    OPD.Psychiatry_Attentiveness_interview = txtAttentivenesstointerview;
                    OPD.Psychiatry_Eye_Contact = txtEyeContact;
                    OPD.Psychiatry_Level_Consciousness = txtLevelofConsciousness;
                    OPD.Psychiatry_Rate = txtRate;
                    OPD.Psychiatry_Rhythm = txtRhythm;
                    OPD.Psychiatry_Volume = txtVolume;
                    OPD.Psychiatry_Tone = txtTone;
                    OPD.Psychiatry_Modulation = txtModulationvar;
                    OPD.Psychiatry_Depressed = txtDepressed;
                    OPD.Psychiatry_Elated = txtElated;
                    OPD.Psychiatry_Irritable = txtIrritable;
                    OPD.Psychiatry_Labile = txtLabile;
                    OPD.Psychiatry_Incongruent = txtIncongruent;
                    OPD.Psychiatry_Blunting_Flattening_Apathy = txtbluntingflatteningapathy;
                    OPD.Psychiatry_Thinking = txtThinkingPremeditation;
                    OPD.Psychiatry_Plans = txtPlans;
                    OPD.Psychiatry_Actions = txtActions;
                    OPD.Psychiatry_Preservative = txtPreservative;
                    OPD.Psychiatry_LoosAssociation = txtLoosAssociation;
                    OPD.Psychiatry_Tangentiaility = txtTangentiaility;
                    OPD.Psychiatry_Circumstantiality = txtCircumstantiality;
                    OPD.Psychiatry_Flight_Ideas = txtFlightofIdeas;
                    OPD.Psychiatry_Thought_Insertion = txtThoughtInsertion;
                    OPD.Psychiatry_Thought_Withdrawal = txtThoughtWithdrawal;
                    OPD.Psychiatry_Thought_Broadcasting = txtThoughBroadcasting;
                    OPD.Psychiatry_Thought_Control = txtThoughControl;
                    OPD.Psychiatry_Dellusion = txtDellusion;
                    OPD.Psychiatry_Overvalued_Ideas = txtovervaluedideas;
                    OPD.Psychiatry_Depresonalization = txtDepresonalization;
                    OPD.Psychiatry_Derealization = txtDerealization;
                    OPD.Psychiatry_Obsession = txtthrougObsession;
                    OPD.Psychiatry_Phobies = txtthrougPhobies;
                    OPD.Psychiatry_Homocidial_Ideas = txtthrougHomocidialIdeas;
                    OPD.Psychiatry_Illusion = txtillusion;
                    OPD.Psychiatry_Hallucination = txtHallucinationAuditoryVisualOlfactoryGustatoryTactile;
                    OPD.Psychiatry_Orientation_Time = txtorientationtime;
                    OPD.Psychiatry_Place = txtplace;
                    OPD.Psychiatry_Person = txtperson;
                    OPD.Psychiatry_Attention_Concentration = txtAttentionConcentrationSerial7Test;
                    OPD.Psychiatry_Days_Week = txtOrDaysOfWeekReverseOrder;
                    OPD.Psychiatry_Immediate_Memory = txtImmediatememory;
                    OPD.Psychiatry_Recent_Events = txtshorttermrecentevents;
                    OPD.Psychiatry_Adress_Recall_Two = txtadressrecallafter2minutes;
                    OPD.Psychiatry_Remote_Events = txtlongtermremoteevents;
                    OPD.Psychiatry_Adress_Recall_Five = txtadressrecallafter5minues;
                    OPD.Psychiatry_General_knowledge = txtgeneralknowledgequestion;
                    OPD.Psychiatry_Arthemetic_Calculation = txtsimplearthemeticcalculation;
                    OPD.Psychiatry_Abstraction = txtabstrationconcertethinking;
                    OPD.Psychiatry_Insight = txtinsight;
                    OPD.DermaFace = DermaFace;
                    OPD.DermaNeck = DermaNeck;
                    OPD.DermaTrunk = DermaTrunk;
                    OPD.DermaUpperLimb = DermaUpperLimb;
                    OPD.DermaLowerLimb = DermaLowerLimb;
                    OPD.DermaFlexures = DermaFlexures;
                    OPD.DermaGenitalias = DermaGenitalias;
                    OPD.DermaHair = DermaHair;
                    OPD.DermaNail = DermaNail;
                    OPD.DermaMucousMembrane = DermaMucousMembrane;
                    OPD.DermaEyes = DermaEyes;
                    OPD.DermaEars = DermaEars;
                    OPD.DermaNose = DermaNose;
                    OPD.DermaLips = DermaLips;
                    OPD.Psychiatry_HBM_Problem = HBM_Problem;
                    OPD.Psychiatry_HBM_Caused = HBM_Caused;
                    OPD.Psychiatry_HBM_Started = HBM_Started;
                    OPD.Psychiatry_HBM_Course = HBM_Course;
                    OPD.Psychiatry_HBM_Treatment = HBM_Treatment;
                    OPD.Psychiatry_HBM_Effects = HBM_Effects;
                    OPD.Psychiatry_PE_Pluse = PE_Pluse;
                    OPD.Psychiatry_PE_BP = PE_BP;
                    OPD.Psychiatry_PE_Temperature = PE_Temperature;
                    OPD.Psychiatry_PE_Weight = PE_Weight;
                    OPD.Psychiatry_PE_RespiratoryRate = PE_RespiratoryRate;
                    OPD.Psychiatry_PE_Jaundice = PE_Jaundice;
                    OPD.Psychiatry_PE_Anemia = PE_Anemia;
                    OPD.Psychiatry_PE_Cyanosis = PE_Cyanosis;
                    OPD.Psychiatry_PE_Clubbing = PE_Clubbing;
                    OPD.Psychiatry_PE_JVP = PE_JVP;
                    OPD.Psychiatry_PE_LymphNodes = PE_LymphNodes;
                    OPD.Psychiatry_PE_Edema = PE_Edema;
                    OPD.Psychiatry_PE_Respiratory = PE_Respiratory;
                    OPD.Psychiatry_PE_Cardiovascular = PE_Cardiovascular;
                    OPD.Psychiatry_PE_Gastro_Intestinal = PE_Gastro_Intestinal;
                    OPD.Psychiatry_PE_Observation = PE_Observation;
                    OPD.Psychiatry_PE_Cranial_Nerves = PE_Cranial_Nerves;
                    OPD.Psychiatry_PE_Limb_Strength = PE_Limb_Strength;
                    OPD.Psychiatry_PE_Spasticity = PE_Spasticity;
                    OPD.Psychiatry_PE_Position = PE_Position;
                    OPD.Psychiatry_PE_Vibration = PE_Vibration;
                    OPD.Psychiatry_PE_Stereognosis = PE_Stereognosis;
                    OPD.Psychiatry_PE_Pain = PE_Pain;
                    OPD.Psychiatry_PE_Biceps = PE_Biceps;
                    OPD.Psychiatry_PE_Triceps = PE_Triceps;
                    OPD.Psychiatry_PE_Brachioradialis = PE_Brachioradialis;
                    OPD.Psychiatry_PE_Quadriceps = PE_Quadriceps;
                    OPD.Psychiatry_PE_Patellar = PE_Patellar;
                    OPD.Psychiatry_PE_Achilles = PE_Achilles;
                    OPD.Psychiatry_PE_Extensor = PE_Extensor;
                    OPD.Psychiatry_PE_Frontal = PE_Frontal;
                    OPD.Psychiatry_PE_Finger = PE_Finger;
                    OPD.Psychiatry_PE_Heel = PE_Heel;
                    OPD.Psychiatry_PE_Movements = PE_Movements;
                    OPD.Psychiatry_PE_Gait = PE_Gait;
                    OPD.Psychiatry_PE_Neck_Rigidity = PE_Neck_Rigidity;
                    OPD.Psychiatry_PE_Kerning_Sign = PE_Kerning_Sign;
                    OPD.Psychiatry_PE_Brudzinki_Sign = PE_Brudzinki_Sign;
                    OPD.Psychiatry_For_Summary = For_Summary;
                    OPD.Psychiatry_For_Diagnosis = For_Diagnosis;
                    OPD.Psychiatry_For_AxisI = For_AxisI;
                    OPD.Psychiatry_For_AxisII = For_AxisII;
                    OPD.Psychiatry_For_AxisIII = For_AxisIII;
                    OPD.Psychiatry_For_AxisIV = For_AxisIV;
                    OPD.Psychiatry_For_AxisV = For_AxisV;
                    OPD.Psychiatry_For_PredisposingFactors = For_PredisposingFactors;
                    OPD.Psychiatry_For_PrecipitatingFactors = For_PrecipitatingFactors;
                    OPD.Psychiatry_For_PrepetuatingFactors = For_PrepetuatingFactors;
                    OPD.Psychiatry_For_Investigation = For_Investigation;
                    OPD.Psychiatry_For_Medical = For_Medical;
                    OPD.Psychiatry_For_Psychological = For_Psychological;
                    OPD.Psychiatry_Major_Issues = For_Major_Issues;
                    OPD.Psychiatry_For_Strengths = For_Strengths;
                    OPD.Psychiatry_For_Goals = For_Goals;
                    OPD.Psychiatry_For_Strategies = For_Strategies;

                    OPD.Peads_weight = txtPeads_weight;
                    OPD.Peads_Length = txtPeads_Length;
                    OPD.Peads_HC = txtPeads_HC;
                    OPD.Peads_General_Appearance = txtPeads_General_Appearance;
                    OPD.Peads_Cyanosis = chkPeads_Cyanosis;
                    OPD.Peads_Jaundice = chkPeads_Jaundice;
                    OPD.Peads_Lethargy = chkPeads_Lethargy;
                    OPD.Peads_Rash = chkPeads_Rash;
                    OPD.Peads_Others = txtPeads_Others;
                    OPD.Peads_Caput = chkPeads_Caput;
                    OPD.Peads_Cephalhematoma = chkPeads_Cephalhematoma;
                    OPD.Peads_Anterioropen = rdbPeads_Anterioropen;
                    OPD.Peads_AnteriorClose = rdbPeads_AnteriorClose;
                    OPD.Peads_Dextrocardia = chkPeads_Dextrocardia;
                    OPD.Peads_Bulging = chkPeads_Bulging;
                    OPD.Peads_Murmur = chkPeads_Murmur;
                    OPD.Peads_HeartSound = txtPeads_HeartSound;
                    OPD.Peads_Nasal = chkPeads_Nasal;
                    OPD.Peads_Recessions = chkPeads_Recessions;
                    OPD.Peads_AddedSounds = txtPeads_AddedSounds;
                    OPD.Peads_Flat = rdbPeads_Flat;
                    OPD.Peads_Distended = rdbPeads_Distended;
                    OPD.Peads_Scaphoid = rdbPeads_Scaphoid;
                    OPD.Peads_Liver = chkPeads_Liver;
                    OPD.Peads_Spleen = chkPeads_Spleen;
                    OPD.Peads_GITOthers = txtPeads_GITOthers;
                    OPD.Peads_Sucking = chkPeads_Sucking;
                    OPD.Peads_Rooting = chkPeads_Rooting;
                    OPD.Peads_Moro = chkPeads_Moro;
                    OPD.Peads_CNSOthers = txtPeads_CNSOthers;
                    OPD.Peads_FullTerm = chkPeads_FullTerm;
                    OPD.Peads_PreTerm = chkPeads_PreTerm;
                    if (txtPeads_DateOfDelivery != null)
                        OPD.Peads_DateOfDelivery = Convert.ToDateTime(txtPeads_DateOfDelivery);
                    OPD.Peads_TimeOfDelivery = txtPeads_TimeOfDelivery;
                    OPD.Peads_Booked = rdbPeads_Booked;
                    OPD.Peads_UnBooked = rdbPeads_UnBooked;
                    OPD.Peads_DAIHandling = chkPeads_DAIHandling;
                    OPD.Peads_ANTURash = chkPeads_ANTURash;
                    OPD.Peads_PIH = chkPeads_PIH;
                    OPD.Peads_GDM = chkPeads_GDM;
                    OPD.Peads_Vacinated = chkPeads_Vacinated;
                    OPD.Peads_ANTOthers = txtPeads_ANTOthers;
                    OPD.Peads_SVD = rdbPeads_SVD;
                    OPD.Peads_LSCS = rdbPeads_LSCS;
                    OPD.Peads_Emergency = rdbPeads_Emergency;
                    OPD.Peads_Elective = rdbPeads_Elective;
                    OPD.Peads_PlaceOfDelivery = txtPeads_PlaceOfDelivery;
                    OPD.Peads_IndicationForLSCS = txtPeads_IndicationForLSCS;
                    OPD.Peads_apgerScore1min = Peads_apgerScore1min;
                    OPD.Peads_apgerScore5min = Peads_apgerScore5min;
                    OPD.Peads_Resuscitation = chkPeads_Resuscitation;
                    OPD.Peads_NatalOthers = txtPeads_NatalOthers;
                    OPD.Peads_Moaning = chkPeads_Moaning;
                    OPD.Peads_RespDistress = chkPeads_RespDistress;
                    OPD.Peads_PostNATALCyanosis = chkPeads_PostNATALCyanosis;
                    OPD.Peads_Fits = chkPeads_Fits;
                    OPD.Peads_ReluctanceToFeed = chkPeads_ReluctanceToFeed;
                    OPD.Peads_PostNatalOthers = txtPeads_PostNatalOthers;

                    OPD.Discharge_By = ddlDischarge_By;
                    if (chkdischarge == true)
                    {
                        if (!string.IsNullOrEmpty(txtDischarge_On))
                            OPD.Discharge_On = Convert.ToDateTime(txtDischarge_On);
                        if (!string.IsNullOrEmpty(txtNext_Visit))
                            OPD.Next_Visit = Convert.ToDateTime(txtNext_Visit);

                        string SMS_Contant = "عارف میموریل ٹیچنگ ہسپتال کی سہولیات پر اعتمادکرنےکاشکریہ ہماری سہولیات کی بہتری کے لیےآپ نیچےدیئے گے نمبرپر رابطہ کریں۔ 03138458018";
                        string msg = "";

                        string CellNumber = (from tbl in db.Reg_patients
                                             where tbl.pat_id == Patient_ID
                                             select tbl.Mobile1).FirstOrDefault();

                    }
                    OPD.Discharge = chkdischarge;

                    OPD.Prevention_Precaution = txtAdvice;
                    if (btnsave == "Save")
                    {
                        OPD.Book_ID = AppConfig.Book_ID;
                        OPD.Created_By = AppConfig.UserID;
                        OPD.Created_Time = DateTime.Now;
                        OPD.Company_ID = AppConfig.Company_ID;
                        db.Emergency_Patients.InsertOnSubmit(OPD);

                        string ward = Convert.ToString((from tbl in db.Ward_Definitions
                                                        where tbl.Ward_ID == Convert.ToInt32(ddlWard_No)
                                                        select tbl.Ward_No).FirstOrDefault());
                        string SMS_Contant = "عارف میموریل ہسپتال پراعتماد کرنےکا شکریہ۔ آپکاداخلہ '" + ward + "' میں تجویز ہوا ہے-شکایات کیصورت میں اس نمبر پر رابطہ کریں۔ 03138458018";
                        string msg = "";

                        string CellNumber = (from tbl in db.Reg_patients
                                             where tbl.pat_id == Patient_ID
                                             select tbl.Mobile1).FirstOrDefault();

                    }
                    db.SubmitChanges();

                    if ((!string.IsNullOrEmpty(CallingDoctorDepartment) && CallingDoctorDepartment != "0") || (!string.IsNullOrEmpty(ddlCallToDoctor) && ddlCallToDoctor != "0") || (!string.IsNullOrEmpty(CallingDoctorMobile) && CallingDoctorMobile != "____-_______") ||
                    (!string.IsNullOrEmpty(remrks_call_to_doc) && remrks_call_to_doc != ""))
                    {
                        Emergency_Doctor_Note edn = new Emergency_Doctor_Note();
                        edn.Department = CallingDoctorDepartment;
                        edn.DoctorToCall = ddlCallToDoctor;
                        edn.DoctorMobile = CallingDoctorMobile;
                        edn.DoctorNotes = remrks_call_to_doc;
                        edn.EmergencyId = 0;
                        edn.PatientId = Patient_ID;
                        db.Emergency_Doctor_Notes.InsertOnSubmit(edn);
                        db.SubmitChanges();
                    }

                    if (ddlIssuance_Of == "001")
                    {
                        List<Ward_Allocation> wlist = db.Ward_Allocations.Where(p => p.InPatient_ID == "0").ToList();
                        foreach (Ward_Allocation med in wlist)
                        {
                            med.InPatient_ID = OPD.Emergency_ID.ToString();
                        }
                    }
                    else
                    {
                        List<Room_Allocation> kklist = db.Room_Allocations.Where(p => p.In_Patient_ID == 0).ToList();
                        foreach (Room_Allocation med in kklist)
                        {
                            med.In_Patient_ID = OPD.Emergency_ID;
                        }
                    }
                    List<In_Patient_Medicine> list = db.In_Patient_Medicines.Where(p => p.Patient_ID == 0 && p.Transaction_Type == "Emergency Patient").ToList();
                    foreach (In_Patient_Medicine med in list)
                    {
                        med.Patient_ID = OPD.Emergency_ID;
                    }
                    List<In_Patient_Medicine> lists = db.In_Patient_Medicines.Where(p => p.Patient_ID == 0 && p.Transaction_Type == "Emergency Patient Discharge").ToList();
                    foreach (In_Patient_Medicine med in lists)
                    {
                        med.Patient_ID = OPD.Emergency_ID;
                    }

                    List<InPatient_Instruction> Inslist = db.InPatient_Instructions.Where(p => p.In_Patient_ID == 0).ToList();
                    foreach (InPatient_Instruction Ins in Inslist)
                    {
                        Ins.In_Patient_ID = OPD.Emergency_ID;
                    }
                    List<Emergency_Doctor_Note> emdnList = db.Emergency_Doctor_Notes.Where(w => w.EmergencyId == 0).ToList();
                    foreach (PMS.Emergency_Doctor_Note item in emdnList)
                    {
                        item.EmergencyId = OPD.Emergency_ID;
                    }

                    List<InPatient_Doctor_Note> DOclist = db.InPatient_Doctor_Notes.Where(p => p.In_Patient_ID == 0).ToList();
                    foreach (InPatient_Doctor_Note DOd in DOclist)
                    {
                        DOd.In_Patient_ID = OPD.Emergency_ID;
                    }
                    List<Lab_Resultrpt> lablist = db.Lab_Resultrpts.Where(p => p.In_Patient_ID == 0).ToList();
                    foreach (Lab_Resultrpt DOd in lablist)
                    {
                        DOd.In_Patient_ID = OPD.Emergency_ID;
                    }
                    List<PMS.EyeDetail> eyelist = db.EyeDetails.Where(t => t.TransactionType == "Emergency Patient" && t.TransactionID == 0).ToList();
                    foreach (PMS.EyeDetail eye in eyelist)
                    {
                        eye.TransactionID = OPD.Emergency_ID;
                    }
                    Laboratory_Test test = db.Laboratory_Tests.Where(p => p.Patient_ID == 0 && p.Transaction_Type == "Emergency Patient").FirstOrDefault();
                    if (test != null)
                        test.Patient_ID = OPD.Emergency_ID;
                    var INPATID = OPD.Emergency_ID;
                    List<PMS.Ortho> ortholist = db.Orthos.Where(t => t.Patient_Type == "Emergency Patient" && t.Transaction_ID == 0).ToList();
                    foreach (PMS.Ortho orth in ortholist)
                    {
                        orth.Transaction_ID = OPD.Emergency_ID;
                    }
                    db.SubmitChanges();

                    if (RateBeats != "" || (!string.IsNullOrEmpty(ddlEmrgRhythm) && ddlEmrgRhythm != "0") || (!string.IsNullOrEmpty(ddlEmrgVolume) && ddlEmrgVolume != "0") || OthersRN != "" || BP_mm_Hg != "" || Temp_C != "" || Respiration_Min != "" || Saturation != "" || txtRN_Special_Instruction != "")
                    {
                        ReceivingNote rcvNote = new ReceivingNote();
                        rcvNote.Patient_ID = Convert.ToInt32(Patient_ID);
                        rcvNote.Emergency_ID = OPD.Emergency_ID;
                        rcvNote.RateBeats = RateBeats;
                        rcvNote.Emergency_Rhythm = ddlEmrgRhythm;
                        rcvNote.Emergency_Volume = ddlEmrgVolume;
                        rcvNote.OthersRecieveNote = OthersRN;
                        rcvNote.BloodPressure = BP_mm_Hg;
                        rcvNote.Temperature = Temp_C;
                        rcvNote.RespirationRate = Respiration_Min;
                        rcvNote.O2_Saturation = Saturation;
                        rcvNote.RN_Special_Instruction = txtRN_Special_Instruction;
                        rcvNote.Receiving_Date = Convert.ToDateTime(txtReceiving_Date);
                        rcvNote.O2_Saturation_Oxygen1 = O2_Saturation_Oxygen1;
                        rcvNote.O2_Saturation_Oxygen2 = O2_Saturation_Oxygen2;
                        rcvNote.user_id = AppConfig.UserID;
                        rcvNote.Type_Nursing = "Receiving Note Emergency";
                        db.ReceivingNotes.InsertOnSubmit(rcvNote);
                        db.SubmitChanges();
                    }
                    if (PulseRate != "" || (!string.IsNullOrEmpty(Rhythmdischarge) && Rhythmdischarge != "0") || (!string.IsNullOrEmpty(volumedisc) && volumedisc != "0") || otherecdesc != "" || BPDischarge != "" || Tempdisch != "" || RespRateDesc != "" || Oxygen2_desc != "" || Special_Instruction_Desc != "")
                    {
                        ReceivingNote rcvNote = new ReceivingNote();
                        rcvNote.Patient_ID = Convert.ToInt32(Patient_ID);
                        rcvNote.Emergency_ID = OPD.Emergency_ID;
                        rcvNote.RateBeats = PulseRate;
                        rcvNote.Emergency_Rhythm = Rhythmdischarge;
                        rcvNote.Emergency_Volume = volumedisc;
                        rcvNote.OthersRecieveNote = otherecdesc;
                        rcvNote.BloodPressure = BPDischarge;
                        rcvNote.Temperature = Tempdisch;
                        rcvNote.RespirationRate = RespRateDesc;
                        rcvNote.O2_Saturation = saturationDis;
                        rcvNote.RN_Special_Instruction = Special_Instruction_Desc;
                        rcvNote.Receiving_Date = Convert.ToDateTime(Receiving_DateDesc);
                        rcvNote.O2_Saturation_Oxygen1 = Oxygen1;
                        rcvNote.O2_Saturation_Oxygen2 = Oxygen2_desc;
                        rcvNote.user_id = AppConfig.UserID;
                        rcvNote.Type_Nursing = "Discharge Receiving Note";
                        db.ReceivingNotes.InsertOnSubmit(rcvNote);
                        db.SubmitChanges();
                    }

                    var Emergency_ID = OPD.Emergency_ID;
                    return Emergency_ID.ToString();
                }
            }
            catch (Exception ex)
            {
                return ex.Message.ToString();
            }
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

                // Only apply the search filter if searchString is not empty
                if (!string.IsNullOrEmpty(searchString))
                {
                    query = query.Where(d => d.Description.Contains(searchString));
                }

                var pharmacyItems = query.OrderByDescending(d => d.Item_ID)
                                       .Select(d => new
                                       {
                                           d.Item_Code,
                                           Description = d.Description
                                       }).Take(10)
                                       .ToList();

                return (new JavaScriptSerializer().Serialize(pharmacyItems));
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