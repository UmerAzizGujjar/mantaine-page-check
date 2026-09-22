using CrystalDecisions.CrystalReports.Engine;
using CrystalDecisions.Shared;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class InPatientsDischarge : System.Web.UI.Page
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

                txtDischarge_On.Text = DateTime.Now.ToString();

                BindingDropDown();
                BlankForm();
                if (Request.QueryString["ID"] != null)
                {
                    string QS = id.Split('=')[1];
                    PopulateInPatientData(Convert.ToInt32(QS));
                    InPatient_Case_id = Convert.ToInt32(QS);
                    ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "", "", true);
                }
            }
            else
            {
            }
        }
        private void BindingDropDown()
        {

            object valueset;




            valueset = DBClass.GetValueSet("Apgar Score");
            ddlPeads_apgerScore1min.DataSource = valueset;
            ddlPeads_apgerScore1min.DataTextField = "DataValue_Description";
            ddlPeads_apgerScore1min.DataValueField = "DataValue_Name";
            ddlPeads_apgerScore1min.Items.Add(new ListItem("Select Score", "0"));
            ddlPeads_apgerScore1min.DataBind();

            valueset = DBClass.GetValueSet("Apgar Score");
            ddlPeads_apgerScore5min.DataSource = valueset;
            ddlPeads_apgerScore5min.DataTextField = "DataValue_Description";
            ddlPeads_apgerScore5min.DataValueField = "DataValue_Name";
            ddlPeads_apgerScore5min.Items.Add(new ListItem("Select Score", "0"));
            ddlPeads_apgerScore5min.DataBind();
            db = new DataBaseDataContext(DBClass.ConnectionString());



            List<HR_Employee> EmpList = new List<HR_Employee>();
            EmpList = (from tbl in db.HR_Employees
                       where (tbl.IsDoctor == true &&
                      (tbl.Designation == "004" || tbl.Designation == "005" || tbl.Designation == "005" || tbl.Designation == "006" || tbl.Designation == "007" || tbl.Designation == "008"))
                       select tbl).ToList();


            ddlDischarge_By.Items.Clear();
            ddlDischarge_By.DataSource = EmpList;
            ddlDischarge_By.DataTextField = "Emp_Name";
            ddlDischarge_By.DataValueField = "Emp_ID";
            ddlDischarge_By.Items.Add(new ListItem("Please Select", "0"));
            ddlDischarge_By.DataBind();



            var ss = AppConfig.UserID;


            List<Service_Definition> SrvcList = new List<Service_Definition>();
            SrvcList = (from tbl in db.Service_Definitions
                        join tbl2 in db.DataValues on tbl.Service_Type equals tbl2.DataValue_Name
                        join tbl3 in db.ValueSets on tbl2.ValueSet_ID equals tbl3.ValueSet_ID
                        where tbl2.DataValue_Description == "In-Patient"
                        select tbl).ToList();


            valueset = DBClass.GetValueSet("Ortho Examination");
            ddlOrthoType.DataSource = valueset;
            ddlOrthoType.DataTextField = "DataValue_Description";
            ddlOrthoType.DataValueField = "DataValue_Name";
            ddlOrthoType.Items.Add(new ListItem("Please Select", "0"));
            ddlOrthoType.DataBind();

            ddlOrthoSide.Items.Add(new ListItem("Please Select", "0"));
            ddlOrthoSide.Items.Add(new ListItem("Left", "Left"));
            ddlOrthoSide.Items.Add(new ListItem("Right", "Right"));
            ddlOrthoSide.DataBind();

            valueset = DBClass.GetValueSet("Discharge Type");
            ddlDischarge_Type.DataSource = valueset;
            ddlDischarge_Type.DataTextField = "DataValue_Description";
            ddlDischarge_Type.DataValueField = "DataValue_Name";
            ddlDischarge_Type.Items.Add(new ListItem("Please Select", "0"));
            ddlDischarge_Type.DataBind();

            valueset = DBClass.GetValueSet("Lab Result");
            ddlLabResult.DataSource = valueset;
            ddlLabResult.DataTextField = "DataValue_Description";
            ddlLabResult.DataValueField = "DataValue_Name";
            ddlLabResult.Items.Add(new ListItem("Select", "0"));
            ddlLabResult.DataBind();


        }

        public void BlankForm()
        {

            //Tab 4
            ddlDischarge_By.SelectedIndex = 0;

        }

        #region Old PopulateInPatientData

        #endregion

        private void PopulateInPatientData(int InPatient_ID)
        {
            try
            {
                db = new DataBaseDataContext(DBClass.ConnectionString());
                var qry = db.sp_GetInPatientDetail(InPatient_ID).FirstOrDefault();
                #region Old code
                //var qry = (from ip in db.In_Patients
                //           join pt in db.Patients
                //           on ip.Patient_ID equals pt.Patient_ID
                //           where ip.In_Patient_ID == InPatient_ID
                //           select new
                //           {
                //               pt.Patient_Type,
                //               pt.Patient_ID,
                //               pt.Full_Name,
                //               pt.Entry_Date,
                //               pt.Created_Time,
                //               pt.Mobile1,
                //               pt.Permanent_Address,
                //               pt.Gender,
                //               pt.Age_years,
                //               ip.In_Patient_ID,
                //               ip.Admission_Date,
                //               ip.Issuance_Of,
                //               ip.Room_ID,
                //               ip.Ward_ID,
                //               ip.Bed_No,
                //               ip.Department,
                //               ip.Doctor,
                //               ip.Health_Complaints,
                //               ip.Expected_Discharge_Date,
                //               ip.Diabetes_Value,
                //               ip.Referring_Doctor,
                //               ip.Recommended_Diet,
                //               ip.Provisional_Diagnosis,
                //               ip.Pulse_Min,
                //               ip.BP_mm_Hg,
                //               ip.Temp_C,
                //               ip.Respiration_Min,
                //               ip.Height_Cm,
                //               ip.Weight_Kg,
                //               //ip.Refer_To_Hospital,
                //               //ip.Discharge_Recommended,
                //               ip.Discharge_By,
                //               //ip.Discharge_Slip,
                //               //ip.MO_Condition_Observed,
                //               //ip.MO_Date,
                //               //ip.MO_Doctor_Name,
                //               //ip.MO_FAO_Sm_Officer,
                //               //ip.MO_FAO_Consultant,
                //               //ip.MO_Next_Visit,
                //               //ip.MO_Operation_Date,
                //               //ip.MO_Operation_Recomended,
                //               //ip.MO_Recomended_Med,
                //               //ip.MO_Test_Performed,
                //               //ip.MO_Visit,
                //               //ip.MO_Special_Instruction,
                //               //ip.MO_Time,
                //               //ip.MO_Operation_Type,
                //               // ip.MO_Recomended_Surgeon,
                //               // ip.SMO_Condition_Observed,
                //               //ip.SMO_Date,
                //               ///ip.SMO_Doctor_Name,
                //               //ip.SMO_FAO_Sm_Officer,
                //               //ip.SMO_FAO_Consultant,
                //               //ip.SMO_Next_Visit,
                //               //ip.SMO_Operation_Date,
                //               //ip.SMO_Operation_Recomended,
                //               //ip.SMO_Recomended_Med,
                //               //ip.SMO_Test_Performed,
                //               //ip.SMO_Visit,
                //               //ip.SMO_Special_Instruction,
                //               //ip.SMO_Time,
                //               //ip.SMO_Operation_Type,
                //               //ip.SMO_Recomended_Surgeon,
                //               //ip.Cnslt_Condition_Observed,
                //               //ip.Cnslt_Date,
                //               //ip.Cnslt_Doctor_Name,
                //               //ip.Cnslt_FAO_Consultant,
                //               //ip.Cnslt_FAO_Sm_Officer,
                //               //ip.Cnslt_Next_Visit,
                //               //ip.Cnslt_Operation_Date,
                //               //ip.Cnslt_Operation_Recomended,
                //               // ip.Cnslt_Operation_Type,
                //               //ip.Cnslt_Recomended_Med,
                //               //ip.Cnslt_Recomended_Surgeon,
                //               //ip.Cnslt_Special_Instruction,
                //               //ip.Cnslt_Test_Performed,
                //               //ip.Cnslt_Time,
                //               //ip.Cnslt_Visit,
                //               ip.Discharge_On,
                //               //ip.Medicine_Name,
                //               //ip.Recomended_Dosage,
                //               //ip.Oral,
                //               //ip.Injections,
                //               ip.Prevention_Precaution,
                //               //ip.Medications,
                //               //ip.Medicine_Provided,
                //               ip.Next_Visit,
                //               //ip.Death_Certificate,
                //               //ip.Billing,
                //               //ip.Total_Amount,
                //               //ip.Lab_Test_By,
                //               //ip.Test_Performed,
                //               //ip.Results,
                //               //ip.Operation_No,
                //               // ip.Performed_By,
                //               //ip.Brief_Description,
                //               //ip.Surgeon_Note,
                //               //ip.Medication_Precautions,
                //               //ip.Post_Operative_Care,
                //               //ip.Shifted_ICU,
                //               //ip.Shifted_CCU,
                //               //ip.Shifted_Observation_Room,
                //               ip.L_M_P,
                //               ip.Receiving_date,
                //               ip.RN_Special_Instruction,
                //               ip.RN_Patient_General_Condition,
                //               ip.HistoryOfPeresentIllness,
                //               ip.HistoryOfFamily,
                //               ip.HistoryOfPastIllness,
                //               ip.CVS,
                //               ip.GIT,
                //               ip.RESP,
                //               ip.SocioEconomicHistory,
                //               ip.CNS,
                //               ip.GYNAE,
                //               ip.ObstetricHistory,
                //               ip.AllergiesHistory,
                //               ip.ProvisionalDiagnosis,
                //               ip.TreatmentHistory,
                //               ip.txtRemarksHistory,
                //               ip.chkPallor,
                //               ip.chkJVP,
                //               ip.chkaganoris,
                //               ip.chkunconceed,
                //               ip.chkjaundice,
                //               ip.hydration,
                //               ip.edema,
                //               ip.chk1,
                //               ip.chk2,
                //               ip.chk3,
                //               ip.chk4,
                //               ip.chk5,
                //               ip.chk6,
                //               ip.chk7,
                //               ip.chk8,
                //               ip.txtInputBox1,
                //               ip.Reffer_No,
                //               ip.Reffer_To,
                //               ip.Birth_History,
                //               ip.Drug_History,
                //               ip.Personal_History,
                //               ip.Local,
                //               ip.Mucculor,
                //               ip.ENT_Throat_IDL,
                //               ip.ENT_Throat_Nose,
                //               ip.ENT_Ear_Right,
                //               ip.Ent_Ear_Left,
                //               ip.ENT_Rinnes_Right_PosNeg,
                //               ip.ENT_Rinnes_Lft_PosNeg,
                //               ip.ENT_Rinnes_Right_FalseNeg,
                //               ip.ENT_Rinnes_Lft_FalseNeg,
                //               ip.ENT_Webber_Central,
                //               ip.ENT_Webber_Lateralized,
                //               ip.ENT_Investigation_PTA,
                //               ip.ENT_Investigation_Tympanometry,
                //               ip.ENT_Rinnes_Right_Neg,
                //               ip.ENT_Rinnes_Lft_Neg,
                //               ip.ENT_Rinnes_Right_FNeg,
                //               ip.ENT_Rinnes_Lft_FNeg,
                //               ip.Psychiatry_Informant,
                //               ip.Psychiatry_Source_Referral,
                //               ip.Psychiatry_Walking,
                //               ip.Psychiatry_Talking,
                //               ip.Psychiatry_Others,
                //               ip.Psychiatry_Menstrual,
                //               ip.Psychiatry_Attachment_Separation,
                //               ip.Psychiatry_Health,
                //               ip.Psychiatry_Neck_Holding,
                //               ip.Psychiatry_Nail_Biting,
                //               ip.Psychiatry_Temper_Tantrums,
                //               ip.Psychiatry_Bed_Wetting,
                //               ip.Psychiatry_Academics,
                //               ip.Psychiatry_Menarche,
                //               ip.Psychiatry_Peer_Relationship,
                //               ip.Psychiatry_Behaviour,
                //               ip.Psychiatry_Occupational_History,
                //               ip.Psychiatry_Substance_Use,
                //               ip.Psychiatry_Forensic_Use,
                //               ip.Psychiatry_Relationship,
                //               ip.Psychiatry_Leisure_Activities,
                //               ip.Psychiatry_Attitude_Standards,
                //               ip.Psychiatry_Prevalling_Mood,
                //               ip.Psychiatry_Reaction_Stress,
                //               ip.Psychiatry_Religious_Practices,
                //               ip.Psychiatry_Father,
                //               ip.Psychiatry_Mother,
                //               ip.Psychiatry_Siblings,
                //               ip.Psychiatry_Home_Atmosphere,
                //               ip.Psychiatry_Familial_Illness,
                //               // ip.Psychiatry_Rel,
                //               ip.Psychiatry_Actual_age,
                //               ip.Psychiatry_Race,
                //               ip.Psychiatry_Tattoos_body_scars,
                //               ip.Psychiatry_Body_Habitus,
                //               ip.Psychiatry_Dress,
                //               ip.Psychiatry_Hygiene,
                //               ip.Psychiatry_Psychomotor_Activity,
                //               ip.Psychiatry_Involuntary_movements,
                //               ip.Psychiatry_Dystonia_EPS,
                //               ip.Psychiatry_Tardive_dyskinesia,
                //               ip.Psychiatry_Tics,
                //               ip.Psychiatry_Tremors,
                //               ip.Psychiatry_Attentiveness_interview,
                //               ip.Psychiatry_Eye_Contact,
                //               ip.Psychiatry_Level_Consciousness,
                //               ip.Psychiatry_Rate,
                //               ip.Psychiatry_Rhythm,
                //               ip.Psychiatry_Volume,
                //               ip.Psychiatry_Tone,
                //               ip.Psychiatry_Modulation,
                //               ip.Psychiatry_Depressed,
                //               ip.Psychiatry_Elated,
                //               ip.Psychiatry_Irritable,
                //               ip.Psychiatry_Labile,
                //               ip.Psychiatry_Incongruent,
                //               ip.Psychiatry_Blunting_Flattening_Apathy,
                //               ip.Psychiatry_Thinking,
                //               ip.Psychiatry_Plans,
                //               ip.Psychiatry_Actions,
                //               ip.Psychiatry_Preservative,
                //               ip.Psychiatry_LoosAssociation,
                //               ip.Psychiatry_Tangentiaility,
                //               ip.Psychiatry_Circumstantiality,
                //               ip.Psychiatry_Flight_Ideas,
                //               ip.Psychiatry_Thought_Insertion,
                //               ip.Psychiatry_Thought_Withdrawal,
                //               ip.Psychiatry_Thought_Broadcasting,
                //               ip.Psychiatry_Thought_Control,
                //               ip.Psychiatry_Dellusion,
                //               ip.Psychiatry_Overvalued_Ideas,
                //               ip.Psychiatry_Depresonalization,
                //               ip.Psychiatry_Derealization,
                //               ip.Psychiatry_Sexual_History,
                //               ip.Psychiatry_Phobies,
                //               ip.Psychiatry_Homocidial_Ideas,
                //               ip.Psychiatry_Illusion,
                //               ip.Psychiatry_Hallucination,
                //               ip.Psychiatry_Orientation_Time,
                //               ip.Psychiatry_Place,
                //               ip.Psychiatry_Person,
                //               ip.Psychiatry_Attention_Concentration,
                //               ip.Psychiatry_Days_Week,
                //               ip.Psychiatry_Immediate_Memory,
                //               ip.Psychiatry_Recent_Events,
                //               ip.Psychiatry_Adress_Recall_Two,
                //               ip.Psychiatry_Remote_Events,
                //               ip.Psychiatry_Adress_Recall_Five,
                //               ip.Psychiatry_General_knowledge,
                //               ip.Psychiatry_Arthemetic_Calculation,
                //               ip.Psychiatry_Abstraction,
                //               ip.Psychiatry_Insight,
                //               ip.DermaFace,
                //               ip.DermaNeck,
                //               ip.DermaTrunk,
                //               ip.DermaUpperLimb,
                //               ip.DermaLowerLimb,
                //               ip.DermaFlexures,
                //               ip.DermaGenitalias,
                //               ip.DermaHair,
                //               ip.DermaNail,
                //               ip.DermaMucousMembrane,
                //               ip.DermaEyes,
                //               ip.DermaEars,
                //               ip.DermaNose,
                //               ip.DermaLips,
                //               ip.Psychiatry_HBM_Problem,
                //               ip.Psychiatry_HBM_Caused,
                //               ip.Psychiatry_HBM_Started,
                //               ip.Psychiatry_HBM_Course,
                //               ip.Psychiatry_HBM_Treatment,
                //               ip.Psychiatry_HBM_Effects,
                //               ip.Psychiatry_PE_Pluse,
                //               ip.Psychiatry_PE_BP,
                //               ip.Psychiatry_PE_Temperature,
                //               ip.Psychiatry_PE_Weight,
                //               ip.Psychiatry_PE_RespiratoryRate,
                //               ip.Psychiatry_PE_Jaundice,
                //               ip.Psychiatry_PE_Anemia,
                //               ip.Psychiatry_PE_Cyanosis,
                //               ip.Psychiatry_PE_Clubbing,
                //               ip.Psychiatry_PE_JVP,
                //               ip.Psychiatry_PE_LymphNodes,
                //               ip.Psychiatry_PE_Edema,
                //               ip.Psychiatry_PE_Respiratory,
                //               ip.Psychiatry_PE_Cardiovascular,
                //               ip.Psychiatry_PE_Gastro_Intestinal,
                //               ip.Psychiatry_PE_Observation,
                //               ip.Psychiatry_PE_Cranial_Nerves,
                //               ip.Psychiatry_PE_Limb_Strength,
                //               ip.Psychiatry_PE_Spasticity,
                //               ip.Psychiatry_PE_Position,
                //               ip.Psychiatry_PE_Vibration,
                //               ip.Psychiatry_PE_Stereognosis,
                //               ip.Psychiatry_PE_Pain,
                //               ip.Psychiatry_PE_Biceps,
                //               ip.Psychiatry_PE_Triceps,
                //               ip.Psychiatry_PE_Brachioradialis,
                //               ip.Psychiatry_PE_Quadriceps,
                //               ip.Psychiatry_PE_Patellar,
                //               ip.Psychiatry_PE_Achilles,
                //               ip.Psychiatry_PE_Extensor,
                //               ip.Psychiatry_PE_Frontal,
                //               ip.Psychiatry_PE_Finger,
                //               ip.Psychiatry_PE_Heel,
                //               ip.Psychiatry_PE_Movements,
                //               ip.Psychiatry_PE_Gait,
                //               ip.Psychiatry_PE_Neck_Rigidity,
                //               ip.Psychiatry_PE_Kerning_Sign,
                //               ip.Psychiatry_PE_Brudzinki_Sign,
                //               ip.Psychiatry_For_Summary,
                //               ip.Psychiatry_For_Diagnosis,
                //               ip.Psychiatry_For_AxisI,
                //               ip.Psychiatry_For_AxisII,
                //               ip.Psychiatry_For_AxisIII,
                //               ip.Psychiatry_For_AxisIV,
                //               ip.Psychiatry_For_AxisV,
                //               ip.Psychiatry_For_PredisposingFactors,
                //               ip.Psychiatry_For_PrecipitatingFactors,
                //               ip.Psychiatry_For_PrepetuatingFactors,
                //               ip.Psychiatry_For_Investigation,
                //               ip.Psychiatry_For_Medical,
                //               ip.Psychiatry_For_Psychological,
                //               ip.Psychiatry_Major_Issues,
                //               ip.Psychiatry_For_Strengths,
                //               ip.Psychiatry_For_Goals,
                //               ip.Psychiatry_For_Strategies,
                //               ip.Procedure_Operation,
                //               ip.Procedure_Detail,
                //               ip.Diagonosis,
                //               ip.Room_Type,
                //               ip.Discharge,
                //               ip.Patient_Discount_Type,
                //               ip.Peads_weight,
                //               ip.Peads_Length,
                //               ip.Peads_HC,
                //               ip.Peads_General_Appearance,
                //               ip.Peads_Cyanosis,
                //               ip.Peads_Jaundice,
                //               ip.Peads_Lethargy,
                //               ip.Peads_Rash,
                //               ip.Peads_Others,
                //               ip.Peads_Caput,

                //               ip.Peads_Cephalhematoma,
                //               ip.Peads_Anterioropen,
                //               ip.Peads_AnteriorClose,
                //               ip.Peads_Dextrocardia,
                //               ip.Peads_Bulging,
                //               ip.Peads_Murmur,
                //               ip.Peads_HeartSound,
                //               ip.Peads_Nasal,
                //               ip.Peads_Recessions,
                //               ip.Peads_AddedSounds,

                //               ip.Peads_Flat,
                //               ip.Peads_Distended,
                //               ip.Peads_Scaphoid,
                //               ip.Peads_Liver,
                //               ip.Peads_Spleen,
                //               ip.Peads_GITOthers,
                //               ip.Peads_Sucking,
                //               ip.Peads_Rooting,
                //               ip.Peads_Moro,
                //               ip.Peads_CNSOthers,

                //               ip.Peads_FullTerm,
                //               ip.Peads_PreTerm,
                //               ip.Peads_DateOfDelivery,
                //               ip.Peads_TimeOfDelivery,
                //               ip.Peads_Booked,
                //               ip.Peads_UnBooked,
                //               ip.Peads_DAIHandling,
                //               ip.Peads_ANTURash,
                //               ip.Peads_PIH,
                //               ip.Peads_GDM,
                //               ip.Peads_Vacinated,

                //               ip.Peads_ANTOthers,
                //               ip.Peads_SVD,
                //               ip.Peads_LSCS,
                //               ip.Peads_Emergency,
                //               ip.Peads_Elective,


                //               ip.Peads_PlaceOfDelivery,
                //               ip.Peads_IndicationForLSCS,
                //               ip.Peads_apgerScore1min,
                //               ip.Peads_apgerScore5min,
                //               ip.Peads_Resuscitation,

                //               ip.Peads_NatalOthers,
                //               ip.Peads_Moaning,
                //               ip.Peads_RespDistress,
                //               ip.Peads_PostNATALCyanosis,
                //               ip.Peads_Fits,
                //               ip.Peads_ReluctanceToFeed,
                //               ip.Peads_PostNatalOthers,



                //           }).FirstOrDefault();
                #endregion

                if (qry != null)
                {
                    //*************** Admission Tab*************************//       
                    hdfPatient_ID.Value = qry.Patient_ID.ToString();
                    txtPatient_ID.Text = qry.Patient_ID.ToString();
                    txtIn_Patient_ID.Text = qry.In_Patient_ID.ToString();
                    vlblPatients_Name.Text = qry.Full_Name;
                    vLbl_Contact.Text = qry.Mobile1;
                    vLbl_Adress.Text = qry.Permanent_Address;
                    vLbl_Gender.Text = db.GetDataValueName("Gender", qry.Gender);
                    vLbl_Age.Text = qry.Age_years;
                    if (qry.Entry_Date == null)
                        vLbl_RegDate.Text = qry.Created_Time.Value.ToString(AppConfig.DateFormat);
                    else
                        vLbl_RegDate.Text = qry.Entry_Date.Value.ToString(AppConfig.DateFormat);

                    vLbl_Patient_Type.Text = db.GetDataValueName("Patient Type", qry.Patient_Type);
                    vLbl_Patient_AdmitCatagory.Text = db.GetDataValueName("Patient Type", qry.Patient_Discount_Type);

                    db = new DataBaseDataContext(DBClass.ConnectionString());
                    List<HR_Employee> EmpList = new List<HR_Employee>();
                    EmpList = (from tbl in db.HR_Employees
                               where (tbl.IsDoctor == true
                               && tbl.Department == qry.Department && (tbl.Designation == "004" || tbl.Designation == "005" || tbl.Designation == "005" || tbl.Designation == "006" || tbl.Designation == "007" || tbl.Designation == "008"))
                               select tbl).ToList();

                    ddlDischarge_By.Items.Clear();
                    ddlDischarge_By.DataSource = EmpList;
                    ddlDischarge_By.DataTextField = "Emp_Name";
                    ddlDischarge_By.DataValueField = "Emp_ID";
                    ddlDischarge_By.Items.Add(new ListItem("Please Select", "0"));
                    ddlDischarge_By.DataBind();
                    ddlDischarge_By.SelectedValue = qry.Discharge_By;

                    #region old Code

                    //txtHealth_Complaints.Text = qry.Health_Complaints;
                    //if (qry.Expected_Discharge_Date != null)
                    //    txtExpected_Discharge_Date.Text = qry.Expected_Discharge_Date.Value.ToString(AppConfig.DateFormat);
                    //ddlPlaceOfDeath.SelectedValue = qry.PlaceOfDeath;



                    //if (!string.IsNullOrEmpty(qry.DateOfDeath.ToString()))
                    //{
                    //    txtDateofDeath.Text = Convert.ToDateTime(qry.DateOfDeath.Value).ToString("MM/dd/yyyy");
                    //}
                    //if (!string.IsNullOrEmpty(qry.TimeOfDeath.ToString()))
                    //{
                    //    // txtTimeOfDeath.Text = Convert.ToString(qry.TimeOfDeath);

                    //    DateTime dateTime = DateTime.ParseExact(qry.TimeOfDeath.ToString(), "HH:mm:ss", CultureInfo.InvariantCulture);

                    //    // txtTimeOfDeath.Text = dateTime.ToShortTimeString();
                    //    txtTimeOfDeath.Text = dateTime.ToString("hh:mm tt", CultureInfo.CurrentCulture);
                    //}

                    //ddlPlaceOfDeath.SelectedValue = qry.PlaceOfDeath;
                    //txtCause_Of_Death.Text = qry.CauseOfDeath;
                    //txtIssuingOfficerName.Text = qry.IssuingOfficerName;
                    //ddlDeathCertifiedbyDr1.SelectedValue = qry.DeathCertifiedBy1;
                    //ddlDeathCertifiedbyDr2.SelectedValue = qry.DeathCertifiedBy2;
                    //txtBodyHandedOverTo.Text = qry.BodyHandedOverTo;
                    //txtFamilyPersonName.Text = qry.FamilyPersonName;
                    //txtCNIC.Text = qry.CNIC;
                    //txtRelationWithDeceased.Text = qry.RelationWithDeceased;
                    //txtCMO_Police.Text = qry.CMO_Police;
                    //txtIdentificationMarks.Text = qry.IdentificationMarks;

                    //**********************Reciving Note Tab**********************//
                    //txtPuls.Text = qry.Pulse_Min;
                    //txtBP.Text = qry.BP_mm_Hg;
                    //txtTemp.Text = qry.Temp_C;
                    //txtRespiration.Text = qry.Respiration_Min;
                    //txtHeight.Text = qry.Height_Cm;
                    //txtWeight.Text = qry.Weight_Kg;
                    //txtLMP.Text = qry.L_M_P;
                    //txtRN_Patient_General_Condition.Text = qry.RN_Patient_General_Condition;
                    //txtRN_Special_Instruction.Text = qry.RN_Special_Instruction;

                    //**********************History Tab**********************//
                    //txtHistoryOfPeresentIllness.Text = qry.HistoryOfPeresentIllness;
                    //txtHistoryOfFamily.Text = qry.HistoryOfFamily;
                    //txtHistoryOfPastIllness.Text = qry.HistoryOfPastIllness;
                    //txtCVS.Text = qry.CVS;
                    //txtGIT.Text = qry.GIT;
                    //txtRESP.Text = qry.RESP;
                    //txtSocioEconomicHistory.Text = qry.SocioEconomicHistory;
                    //txtCNS.Text = qry.CNS;
                    //txtGYNAE.Text = qry.GYNAE;
                    //txtLocal.Text = qry.Local;
                    //txtMucculor.Text = qry.Mucculor;
                    //txtObstetricHistory.Text = qry.ObstetricHistory;
                    //txtAllergiesHistory.Text = qry.AllergiesHistory;
                    //txtProvisionalDiagnosis.Text = qry.ProvisionalDiagnosis;
                    //txtTreatmentHistory.Text = qry.TreatmentHistory;
                    //txtVaccinationHistory.Text = qry.Vaccination_History;
                    //txtAnyOtherHistory.Text = qry.Other_History;
                    //TextBoxCns.Text = qry.CNS_Value;
                    //TextBoxCvs.Text = qry.CVS_Value;
                    //TextBoxResp.Text = qry.RESP_Value;
                    //TextBoxGit.Text = qry.GIT_Value;
                    //TextBoxGpe.Text = qry.GPE_Value;
                    //ctl00_MainContent_txtEOR.Text = qry.Eye_Opening_Response;
                    //txtMR.Text = qry.Motor_Response;
                    //txtVR.Text = qry.Verbal_Response;
                    //txtAcc.Text = qry.Accumulated_Response;
                    //txtFurtherExplanation.Text = qry.FurtherExplanation;
                    //txtRemarksHistory.Text = qry.txtRemarksHistory;
                    //chkPallor.Checked = qry.chkPallor.Value;
                    //chkJVP.Checked = qry.chkJVP.Value;
                    //chkaganoris.Checked = qry.chkaganoris.Value;
                    //chkunconceed.Checked = qry.chkunconceed.Value;
                    //chkjaundice.Checked = qry.chkjaundice.Value;
                    //hydration.Checked = qry.hydration.Value;
                    //edema.Checked = qry.edema.Value;


                    //chk2.Checked = qry.chk2.Value;
                    //chk3.Checked = qry.chk3.Value;
                    //chk4.Checked = qry.chk4.Value;
                    //chk5.Checked = qry.chk5.Value;
                    //txtInputBox1.Text = qry.txtInputBox1;
                    //txtBirthHistory.Text = qry.Birth_History;
                    ////ddlPatient_Main_Category.SelectedValue = qry.Reffer_To;
                    //////txtRefferNote.Text = qry.Reffer_No;
                    //txtDrugHistory.Text = qry.Drug_History;
                    //txtPersonalHistory.Text = qry.Personal_History;

                    //**********************ENT**********************//
                    //txtmidl.Text = qry.ENT_Throat_IDL;
                    //txtmNose.Text = qry.ENT_Throat_Nose;
                    //txtmRight.Text = qry.ENT_Ear_Right;
                    //txtmLeft.Text = qry.Ent_Ear_Left;
                    //mchkRightPos.Checked = qry.ENT_Rinnes_Right_PosNeg.Value;
                    //mchkLeftPos.Checked = qry.ENT_Rinnes_Lft_PosNeg.Value;
                    //mchkRightF.Checked = qry.ENT_Rinnes_Right_FalseNeg.Value;
                    //mchkLeftF.Checked = qry.ENT_Rinnes_Lft_FalseNeg.Value;

                    //mchkcentral.Checked = qry.ENT_Webber_Central.Value;
                    //mchkLateralized.Checked = qry.ENT_Webber_Lateralized.Value;
                    //mchkPTA.Checked = qry.ENT_Investigation_PTA.Value;
                    //mchkTympanometry.Checked = qry.ENT_Investigation_Tympanometry.Value;
                    //mchkRightNeg.Checked = qry.ENT_Rinnes_Right_Neg.Value;
                    //mchkLeftNeg.Checked = qry.ENT_Rinnes_Lft_Neg.Value;
                    //mchkRightFNeg.Checked = qry.ENT_Rinnes_Right_FNeg.Value;
                    //mchkLeftFNeg.Checked = qry.ENT_Rinnes_Lft_FNeg.Value;

                    ////**********************Psychiatry Detail**********************//
                    //txtInformant.Text = qry.Psychiatry_Informant;
                    //txtSourceOfReferral.Text = qry.Psychiatry_Source_Referral;
                    //chkNeckHolding.Checked = Convert.ToBoolean(qry.Psychiatry_Neck_Holding);
                    //chkWalking.Checked = qry.Psychiatry_Walking.Value;
                    //chkTalking.Checked = qry.Psychiatry_Talking.Value;
                    //chkOthers.Checked = qry.Psychiatry_Others.Value;
                    //txtMenarche.Text = qry.Psychiatry_Menarche;
                    //txtMenstrual.Text = qry.Psychiatry_Menstrual;
                    //txtAttachmentSeparationfromParents.Text = qry.Psychiatry_Attachment_Separation;
                    //txtHealth.Text = qry.Psychiatry_Health;
                    //chkNailBiting.Checked = Convert.ToBoolean(qry.Psychiatry_Nail_Biting);
                    //chkTemperTantrums.Checked = Convert.ToBoolean(qry.Psychiatry_Temper_Tantrums);
                    //chkBedWetting.Checked = Convert.ToBoolean(qry.Psychiatry_Bed_Wetting);
                    //txtAcademics.Text = qry.Psychiatry_Academics;
                    //txtPeerRelationship.Text = qry.Psychiatry_Peer_Relationship;
                    //txtBehaviour.Text = qry.Psychiatry_Behaviour;
                    //txtOccupationalHistory.Text = qry.Psychiatry_Occupational_History;
                    //txtMaritalRelationshipSexualHistory.Text = qry.Psychiatry_Sexual_History;
                    //txtSubstanceUse.Text = qry.Psychiatry_Substance_Use;
                    //txtForensicUse.Text = qry.Psychiatry_Forensic_Use;
                    //txtRelationship.Text = qry.Psychiatry_Relationship;
                    //txtLeisureActivities.Text = qry.Psychiatry_Leisure_Activities;
                    //txtAttitudetoSelfandStandards.Text = qry.Psychiatry_Attitude_Standards;
                    //txtPrevallingMood.Text = qry.Psychiatry_Prevalling_Mood;
                    //txtReactionPattrentoStress.Text = qry.Psychiatry_Reaction_Stress;
                    //txtReligiousPracticesAttitute.Text = qry.Psychiatry_Religious_Practices;
                    //txtFather.Text = qry.Psychiatry_Father;
                    //txtMother.Text = qry.Psychiatry_Mother;
                    //txtSiblings.Text = qry.Psychiatry_Siblings;
                    //txtHomeAtmosphererelationshipsocialclass.Text = qry.Psychiatry_Home_Atmosphere;
                    //txtFamilialIllness.Text = qry.Psychiatry_Familial_Illness;
                    //txtActualandapparentage.Text = qry.Psychiatry_Actual_age;
                    //txtRace.Text = qry.Psychiatry_Race;
                    //txtTattoosbodypiercingandscars.Text = qry.Psychiatry_Tattoos_body_scars;
                    //txtBodyHabitus.Text = qry.Psychiatry_Body_Habitus;
                    //txtDress.Text = qry.Psychiatry_Dress;
                    //txtHygiene.Text = qry.Psychiatry_Hygiene;
                    //txtPsychomotorActivity.Text = qry.Psychiatry_Psychomotor_Activity;
                    //txtInvoluntarymovements.Text = qry.Psychiatry_Involuntary_movements;
                    //txtDystoniaEPS.Text = qry.Psychiatry_Dystonia_EPS;
                    //txtTardivedyskinesia.Text = qry.Psychiatry_Tardive_dyskinesia;
                    //txtTics.Text = qry.Psychiatry_Tics;
                    //txtTremors.Text = qry.Psychiatry_Tremors;
                    //txtAttentivenesstointerview.Text = qry.Psychiatry_Attentiveness_interview;
                    //txtEyeContact.Text = qry.Psychiatry_Eye_Contact;
                    //txtLevelofConsciousness.Text = qry.Psychiatry_Level_Consciousness;
                    //txtRate.Text = qry.Psychiatry_Rate;
                    //txtRhythm.Text = qry.Psychiatry_Rhythm;
                    //txtVolume.Text = qry.Psychiatry_Volume;
                    //txtTone.Text = qry.Psychiatry_Tone;
                    //txtModulationvar.Text = qry.Psychiatry_Modulation;
                    //txtDepressed.Text = qry.Psychiatry_Depressed;
                    //txtElated.Text = qry.Psychiatry_Elated;
                    //txtIrritable.Text = qry.Psychiatry_Irritable;
                    //txtLabile.Text = qry.Psychiatry_Labile;
                    //txtIncongruent.Text = qry.Psychiatry_Incongruent;
                    //txtBluntingFlatteningApathy.Text = qry.Psychiatry_Blunting_Flattening_Apathy;
                    //txtThinkingPremeditation.Text = qry.Psychiatry_Thinking;
                    //txtPlans.Text = qry.Psychiatry_Plans;
                    //txtActions.Text = qry.Psychiatry_Actions;
                    //txtPreservative.Text = qry.Psychiatry_Preservative;
                    //txtLoosAssociation.Text = qry.Psychiatry_LoosAssociation;
                    //txtTangentiaility.Text = qry.Psychiatry_Tangentiaility;
                    //txtCircumstantiality.Text = qry.Psychiatry_Circumstantiality;
                    //txtFlightofIdeas.Text = qry.Psychiatry_Flight_Ideas;
                    //txtThoughtInsertion.Text = qry.Psychiatry_Thought_Insertion;
                    //txtThoughtWithdrawal.Text = qry.Psychiatry_Thought_Withdrawal;
                    //txtThoughBroadcasting.Text = qry.Psychiatry_Thought_Broadcasting;
                    //txtThoughControl.Text = qry.Psychiatry_Thought_Control;
                    //txtDellusion.Text = qry.Psychiatry_Dellusion;
                    //txtovervaluedideas.Text = qry.Psychiatry_Overvalued_Ideas;
                    //txtDepresonalization.Text = qry.Psychiatry_Depresonalization;
                    //txtDerealization.Text = qry.Psychiatry_Derealization;
                    //txtthrougObsession.Text = qry.Psychiatry_Informant;
                    //txtthrougPhobies.Text = qry.Psychiatry_Phobies;
                    //txtthrougHomocidialIdeas.Text = qry.Psychiatry_Homocidial_Ideas;
                    //txtillusion.Text = qry.Psychiatry_Illusion;
                    //txtHallucinationAuditoryVisualOlfactoryGustatoryTactile.Text = qry.Psychiatry_Hallucination;
                    //txtorientationtime.Text = qry.Psychiatry_Orientation_Time;
                    //txtplace.Text = qry.Psychiatry_Place;
                    //txtperson.Text = qry.Psychiatry_Person;
                    //txtAttentionConcentrationSerial7Test.Text = qry.Psychiatry_Attention_Concentration;
                    //txtOrDaysOfWeekReverseOrder.Text = qry.Psychiatry_Days_Week;
                    //txtImmediatememory.Text = qry.Psychiatry_Immediate_Memory;
                    //txtshorttermrecentevents.Text = qry.Psychiatry_Recent_Events;
                    //txtadressrecallafter2minutes.Text = qry.Psychiatry_Adress_Recall_Two;
                    //longtermremoteevents.Text = qry.Psychiatry_Remote_Events;
                    //txtadressrecallafter5minues.Text = qry.Psychiatry_Adress_Recall_Five;
                    //txtgeneralknowledgequestion.Text = qry.Psychiatry_General_knowledge;
                    //txtsimplearthemeticcalculation.Text = qry.Psychiatry_Arthemetic_Calculation;
                    //txtabstrationconcertethinking.Text = qry.Psychiatry_Abstraction;
                    //txtinsight.Text = qry.Psychiatry_Insight;
                    ////**********************Derma Detail**********************//
                    //txtDermaFace.Text = qry.DermaFace;
                    //txtDermaNeck.Text = qry.DermaNeck;
                    //txtDermaTrunk.Text = qry.DermaTrunk;
                    //txtDermaUpperLimb.Text = qry.DermaUpperLimb;
                    //txtDermaLowerLimb.Text = qry.DermaLowerLimb;
                    //txtDermaFlexures.Text = qry.DermaFlexures;
                    //txtDermaGenitalias.Text = qry.DermaGenitalias;
                    //txtDermaHair.Text = qry.DermaHair;
                    //txtDermaNail.Text = qry.DermaNail;
                    //txtDermaMucousMembrane.Text = qry.DermaMucousMembrane;
                    //txtDermaEyes.Text = qry.DermaEyes;
                    //txtDermaEars.Text = qry.DermaEars;
                    //txtDermaNose.Text = qry.DermaNose;
                    //txtDermaLips.Text = qry.DermaLips;

                    //txtHBM_Problem.Text = qry.Psychiatry_HBM_Problem;
                    //txtHBM_Caused.Text = qry.Psychiatry_HBM_Caused;
                    //txtHBM_Started.Text = qry.Psychiatry_HBM_Started;
                    //txtHBM_Course.Text = qry.Psychiatry_HBM_Course;
                    //txtHBM_Treatment.Text = qry.Psychiatry_HBM_Treatment;
                    //txtHBM_Effects.Text = qry.Psychiatry_HBM_Effects;
                    //txtPE_Pluse.Text = qry.Psychiatry_PE_Pluse;
                    //txtPE_BP.Text = qry.Psychiatry_PE_BP;
                    //txtPE_Temperature.Text = qry.Psychiatry_PE_Temperature;
                    //txtPE_Weight.Text = qry.Psychiatry_PE_Weight;
                    //txtPE_RespiratoryRate.Text = qry.Psychiatry_PE_RespiratoryRate;
                    //txtPE_Jaundice.Text = qry.Psychiatry_PE_Jaundice;
                    //txtPE_Anemia.Text = qry.Psychiatry_PE_Anemia;
                    //txtPE_Cyanosis.Text = qry.Psychiatry_PE_Cyanosis;
                    //txtPE_Clubbing.Text = qry.Psychiatry_PE_Clubbing;
                    //txtPE_JVP.Text = qry.Psychiatry_PE_JVP;
                    //txtPE_LymphNodes.Text = qry.Psychiatry_PE_LymphNodes;
                    //txtPE_Edema.Text = qry.Psychiatry_PE_Edema;
                    //txtPE_Respiratory.Text = qry.Psychiatry_PE_Respiratory;
                    //txtPE_Cardiovascular.Text = qry.Psychiatry_PE_Cardiovascular;
                    //txtPE_Gastro_Intestinal.Text = qry.Psychiatry_PE_Gastro_Intestinal;
                    //txtPE_Observation.Text = qry.Psychiatry_PE_Observation;
                    //txtPE_Cranial_Nerves.Text = qry.Psychiatry_PE_Cranial_Nerves;
                    //txtPE_Limb_Strength.Text = qry.Psychiatry_PE_Limb_Strength;
                    //txtPE_Spasticity.Text = qry.Psychiatry_PE_Spasticity;
                    //txtPE_Position.Text = qry.Psychiatry_PE_Position;
                    //txtPE_Vibration.Text = qry.Psychiatry_PE_Vibration;
                    //txtPE_Stereognosis.Text = qry.Psychiatry_PE_Stereognosis;
                    //txtPE_Pain.Text = qry.Psychiatry_PE_Pain;
                    //txtPE_Biceps.Text = qry.Psychiatry_PE_Biceps;
                    //txtPE_Triceps.Text = qry.Psychiatry_PE_Triceps;
                    //txtPE_Brachioradialis.Text = qry.Psychiatry_PE_Brachioradialis;
                    //txtPE_Quadriceps.Text = qry.Psychiatry_PE_Quadriceps;
                    //txtPE_Patellar.Text = qry.Psychiatry_PE_Patellar;
                    //txtPE_Achilles.Text = qry.Psychiatry_PE_Achilles;
                    //txtPE_Extensor.Text = qry.Psychiatry_PE_Extensor;
                    //txtPE_Frontal.Text = qry.Psychiatry_PE_Frontal;
                    //txtPE_Finger.Text = qry.Psychiatry_PE_Finger;
                    //txtPE_Heel.Text = qry.Psychiatry_PE_Heel;
                    //txtPE_Movements.Text = qry.Psychiatry_PE_Movements;
                    //txtPE_Gait.Text = qry.Psychiatry_PE_Gait;
                    //chkPE_Neck_Rigidity.Checked = qry.Psychiatry_PE_Neck_Rigidity.Value;
                    //chkPE_Kerning_Sign.Checked = qry.Psychiatry_PE_Kerning_Sign.Value;
                    //chkPE_Brudzinki_Sign.Checked = qry.Psychiatry_PE_Brudzinki_Sign.Value;
                    //txtFor_Summary.Text = qry.Psychiatry_For_Summary;
                    //txtFor_Diagnosis.Text = qry.Psychiatry_For_Diagnosis;
                    //txtFor_AxisI.Text = qry.Psychiatry_For_AxisI;
                    //txtFor_AxisIII.Text = qry.Psychiatry_For_AxisIII;
                    //txtFor_AxisII.Text = qry.Psychiatry_For_AxisII;
                    ////     For_AxisII.Text=qry.psychiatr_For,
                    //txtFor_AxisIV.Text = qry.Psychiatry_For_AxisIV;
                    //txtFor_AxisV.Text = qry.Psychiatry_For_AxisV;
                    //txtFor_PredisposingFactors.Text = qry.Psychiatry_For_PredisposingFactors;
                    //txtFor_PrecipitatingFactors.Text = qry.Psychiatry_For_PrecipitatingFactors;
                    //txtFor_PrepetuatingFactors.Text = qry.Psychiatry_For_PrepetuatingFactors;
                    //txtFor_Investigation.Text = qry.Psychiatry_For_Investigation;
                    //txtFor_Medical.Text = qry.Psychiatry_For_Medical;
                    //txtFor_Psychological.Text = qry.Psychiatry_For_Psychological;
                    //txtFor_Major_Issues.Text = qry.Psychiatry_Major_Issues;
                    //txtFor_Strengths.Text = qry.Psychiatry_For_Strengths;
                    //txtFor_Goals.Text = qry.Psychiatry_For_Goals;
                    //txtFor_Strategies.Text = qry.Psychiatry_For_Strategies;

                    /////////////////Peads////////////
                    //txtPeads_weight.Text = qry.Peads_weight;
                    //txtPeads_Length.Text = qry.Peads_Length;
                    //txtPeads_HC.Text = qry.Peads_HC;
                    //txtPeads_General_Appearance.Text = qry.Peads_General_Appearance;
                    //chkPeads_Cyanosis.Checked = qry.Peads_Cyanosis.Value;
                    //chkPeads_Jaundice.Checked = qry.Peads_Jaundice.Value;
                    //chkPeads_Lethargy.Checked = qry.Peads_Lethargy.Value;
                    //chkPeads_Rash.Checked = qry.Peads_Rash.Value;
                    //txtPeads_Others.Text = qry.Peads_Others;
                    //chkPeads_Caput.Checked = qry.Peads_Caput.Value;

                    //chkPeads_Cephalhematoma.Checked = qry.Peads_Cephalhematoma.Value;
                    //rdbPeads_Anterioropen.Checked = qry.Peads_Anterioropen.Value;
                    //rdbPeads_AnteriorClose.Checked = qry.Peads_AnteriorClose.Value;
                    //chkPeads_Dextrocardia.Checked = qry.Peads_Dextrocardia.Value;
                    //chkPeads_Bulging.Checked = qry.Peads_Bulging.Value;
                    //chkPeads_Murmur.Checked = qry.Peads_Murmur.Value;
                    //txtPeads_HeartSound.Text = qry.Peads_HeartSound;
                    //chkPeads_Nasal.Checked = qry.Peads_Nasal.Value;
                    //chkPeads_Recessions.Checked = qry.Peads_Recessions.Value;
                    //txtPeads_AddedSounds.Text = qry.Peads_AddedSounds;

                    //rdbPeads_Flat.Checked = qry.Peads_Flat.Value;
                    //rdbPeads_Distended.Checked = qry.Peads_Distended.Value;
                    //rdbPeads_Scaphoid.Checked = qry.Peads_Scaphoid.Value;
                    //chkPeads_Liver.Checked = qry.Peads_Liver.Value;
                    //chkPeads_Spleen.Checked = qry.Peads_Spleen.Value;
                    //txtPeads_GITOthers.Text = qry.Peads_GITOthers;
                    //chkPeads_Sucking.Checked = qry.Peads_Sucking.Value;
                    //chkPeads_Rooting.Checked = qry.Peads_Rooting.Value;
                    //chkPeads_Moro.Checked = qry.Peads_Moro.Value;
                    //txtPeads_CNSOthers.Text = qry.Peads_CNSOthers;

                    //chkPeads_FullTerm.Checked = qry.Peads_FullTerm.Value;
                    //chkPeads_PreTerm.Checked = qry.Peads_PreTerm.Value;
                    //if (qry.Peads_DateOfDelivery != null)
                    //    txtPeads_DateOfDelivery.Text = qry.Peads_DateOfDelivery.Value.ToString(AppConfig.DateFormat);
                    //txtPeads_TimeOfDelivery.Text = qry.Peads_TimeOfDelivery;
                    //rdbPeads_Booked.Checked = qry.Peads_Booked.Value;
                    //rdbPeads_UnBooked.Checked = qry.Peads_UnBooked.Value;
                    //chkPeads_DAIHandling.Checked = qry.Peads_DAIHandling.Value;
                    //chkPeads_ANTURash.Checked = qry.Peads_ANTURash.Value;
                    //chkPeads_PIH.Checked = qry.Peads_PIH.Value;
                    //chkPeads_GDM.Checked = qry.Peads_GDM.Value;
                    //chkPeads_Vacinated.Checked = qry.Peads_Vacinated.Value;

                    //txtPeads_ANTOthers.Text = qry.Peads_ANTOthers;
                    //rdbPeads_SVD.Checked = qry.Peads_SVD.Value;
                    //rdbPeads_LSCS.Checked = qry.Peads_LSCS.Value;
                    //rdbPeads_Emergency.Checked = qry.Peads_Emergency.Value;
                    //rdbPeads_Elective.Checked = qry.Peads_Elective.Value;

                    //txtPeads_PlaceOfDelivery.Text = qry.Peads_PlaceOfDelivery;
                    //txtPeads_IndicationForLSCS.Text = qry.Peads_IndicationForLSCS;
                    //ddlPeads_apgerScore1min.SelectedValue = qry.Peads_apgerScore1min;
                    //ddlPeads_apgerScore5min.SelectedValue = qry.Peads_apgerScore5min;
                    //chkPeads_Resuscitation.Checked = qry.Peads_Resuscitation.Value;

                    //txtPeads_NatalOthers.Text = qry.Peads_NatalOthers;
                    //chkPeads_Moaning.Checked = qry.Peads_Moaning.Value;
                    //chkPeads_RespDistress.Checked = qry.Peads_RespDistress.Value;
                    //chkPeads_PostNATALCyanosis.Checked = qry.Peads_PostNATALCyanosis.Value;
                    //chkPeads_Fits.Checked = qry.Peads_Fits.Value;
                    //chkPeads_ReluctanceToFeed.Checked = qry.Peads_ReluctanceToFeed.Value;
                    //txtPeads_PostNatalOthers.Text = qry.Peads_PostNatalOthers;


                    //**********************Discharge Tab **********************//
                    // ddlDischarge_By.SelectedValue = qry.Discharge_By;
                    #endregion

                    txtProcedure_Operation.Text = qry.Procedure_Operation;
                    txtMedication.Text = qry.Diagonosis;
                    txtBilling.Text = qry.Procedure_Detail;
                    txtPrevention_Precaution.Text = qry.Prevention_Precaution;
                    if (qry.Next_Visit != null)
                        txtNext_Visit.Text = qry.Next_Visit.Value.ToString(AppConfig.DateFormat);
                    if (qry.Discharge_On != null)
                        txtDischarge_On.Text = qry.Discharge_On.Value.ToString(AppConfig.DateFormat);
                    cbDicharg_Slip.Checked = qry.Discharge.Value;

                    if (!string.IsNullOrEmpty(qry.Discharge_Type))
                    {
                        ddlDischarge_Type.SelectedValue = qry.Discharge_Type;
                    }
                    else
                    {
                        ddlDischarge_Type.SelectedIndex = 0;
                    }

                }
            }
            catch (Exception ex)
            {
                lblMessage.CssClass = "errorMessage";
                lblMessage.Text = ex.Message;
            }
        }

        [WebMethod]
        public static string LoadExaminationHistory(int PatientID)  // LoadExaminationTabHistory()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            int Patient_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatientID));

            var In_PatientsExamList = (from in_Pat in db.In_Patients
                                       join pat in db.Reg_patients
                                       on in_Pat.Patient_ID equals pat.pat_id
                                       where pat.Patient_No == Patient_No
                                       select new
                                       {
                                           // in_Pat.HMFIntact,
                                           HMFIntact = in_Pat.HMFIntact == null ? "none" : (in_Pat.HMFIntact == true ? "Yes" : "False"),
                                           CranialNerves = in_Pat.CranialNerves == null ? "none" : (in_Pat.CranialNerves == true ? "Yes" : "No"),
                                           SignsOfMeningism = in_Pat.SignsOfMeningism == null ? "none" : (in_Pat.SignsOfMeningism == true ? "Yes" : "No"),
                                           HeartSound = in_Pat.HeartSound == null ? "none" : (in_Pat.HeartSound == true ? "Yes" : "No"),
                                           Arrhythmias = in_Pat.Arrhythmias == null ? "none" : (in_Pat.Arrhythmias == true ? "Yes" : "No"),
                                           Murmur = in_Pat.Murmur == null ? "none" : (in_Pat.Murmur == true ? "Yes" : "No"),
                                           AnyOtherAddedSound = in_Pat.AnyOtherAddedSound == null ? "none" : (in_Pat.AnyOtherAddedSound == true ? "Yes" : "No"),
                                           AnyOtherFindings = in_Pat.AnyOtherFindings == null ? "none" : (in_Pat.AnyOtherFindings == true ? "Yes" : "No"),
                                           Wheeze = in_Pat.Wheeze == null ? "none" : (in_Pat.Wheeze == true ? "Yes" : "No"),
                                           Ranchi = in_Pat.Ranchi == null ? "none" : (in_Pat.Ranchi == true ? "Yes" : "No"),
                                           AnyOtherSound = in_Pat.AnyOtherSound == null ? "none" : (in_Pat.AnyOtherSound == true ? "Yes" : "No"),
                                           AbdomenSoft = in_Pat.AbdomenSoft == null ? "none" : (in_Pat.AbdomenSoft == true ? "Yes" : "No"),
                                           Tenderness = in_Pat.Tenderness == null ? "none" : (in_Pat.Tenderness == true ? "Yes" : "No"),
                                           Guarding = in_Pat.Guarding == null ? "none" : (in_Pat.Guarding == true ? "Yes" : "No"),
                                           BowelSound = in_Pat.BowelSound == null ? "none" : (in_Pat.BowelSound == true ? "Yes" : "No"),
                                           Distention = in_Pat.Distention == null ? "none" : (in_Pat.Distention == true ? "Yes" : "No"),
                                           FluidThrill = in_Pat.FluidThrill == null ? "none" : (in_Pat.FluidThrill == true ? "Yes" : "No"),
                                           ShiftingDullness = in_Pat.ShiftingDullness == null ? "none" : (in_Pat.ShiftingDullness == true ? "Yes" : "No"),
                                           EpigastriaDiscomfort = in_Pat.EpigastriaDiscomfort == null ? "none" : (in_Pat.EpigastriaDiscomfort == true ? "Yes" : "No"),
                                           RetrosternalBurning = in_Pat.RetrosternalBurning == null ? "none" : (in_Pat.RetrosternalBurning == true ? "Yes" : "No"),
                                           Jondus = in_Pat.Jondus == null ? "none" : (in_Pat.Jondus == true ? "Yes" : "No"),
                                           Pallor = in_Pat.Pallor == null ? "none" : (in_Pat.Pallor == true ? "Yes" : "No"),
                                           Dehydration = in_Pat.Dehydration == null ? "none" : (in_Pat.Dehydration == true ? "Yes" : "No"),
                                           GCSOrientation = in_Pat.GCSOrientation == null ? "none" : (in_Pat.GCSOrientation == true ? "Yes" : "No"),
                                           Conscious_Orientely = in_Pat.Conscious_Orientely == null ? "none" : (in_Pat.Conscious_Orientely == true ? "Yes" : "No"),
                                           NVB_Right = in_Pat.NVB_Right == null ? "none" : (in_Pat.NVB_Right == true ? "Yes" : "No"),
                                           NVB_Left = in_Pat.NVB_Left == null ? "none" : (in_Pat.NVB_Left == true ? "Yes" : "No"),
                                           Crepitation_Right = in_Pat.Crepitation_Right == null ? "none" : (in_Pat.Crepitation_Right == true ? "Yes" : "No"),
                                           Crepitation_Left = in_Pat.Crepitation_Left == null ? "none" : (in_Pat.Crepitation_Left == true ? "Yes" : "No"),
                                           FurtherExplanation = in_Pat.FurtherExplanation == null ? "none" : in_Pat.FurtherExplanation
                                       }).ToList();

            #region Old Code

            //EmergPatientExamDetail EmergPatientDetail = new EmergPatientExamDetail();

            //foreach (var item in EmergencyPatientExamList)
            //{               
            //        EmergPatientDetail.HMFIntact = item.HMFIntact == null ? "none" : (item.HMFIntact == true ? "Yes" : "False");
            //        EmergPatientDetail.CranialNerves = item.CranialNerves == null ? "none" : (item.CranialNerves == true ? "Yes" : "No");
            //        EmergPatientDetail.SignsOfMeningism = item.SignsOfMeningism == null ? "none" : (item.SignsOfMeningism == true ? "Yes" : "No");
            //        EmergPatientDetail.HeartSound = item.HeartSound == null ? "none" : (item.HeartSound == true ? "Yes" : "No");
            //        EmergPatientDetail.Arrhythmias = item.Arrhythmias == null ? "none" : (item.Arrhythmias == true ? "Yes" : "No");
            //        EmergPatientDetail.Murmur = item.Murmur == null ? "none" : (item.Murmur == true ? "Yes" : "No");
            //        EmergPatientDetail.AnyOtherAddedSound = item.AnyOtherAddedSound == null ? "none" : (item.AnyOtherAddedSound == true ? "Yes" : "No");
            //        EmergPatientDetail.AnyOtherFindings = item.AnyOtherFindings == null ? "none" : (item.AnyOtherFindings == true ? "Yes" : "No");
            //        EmergPatientDetail.NVB_Right = item.NVB_Right == null ? "none" : (item.NVB_Right == true ? "Yes" : "No");
            //        EmergPatientDetail.NVB_Left = item.NVB_Left == null ? "none" : (item.NVB_Left == true ? "Yes" : "No");
            //        EmergPatientDetail.Crepitation_Right = item.Crepitation_Right == null ? "none" : (item.Crepitation_Right == true ? "Yes" : "No");
            //        EmergPatientDetail.Crepitation_Left = item.Crepitation_Left == null ? "none" : (item.Crepitation_Left == true ? "Yes" : "No");
            //        EmergPatientDetail.Wheeze = item.Wheeze == null ? "none" : (item.Wheeze == true ? "Yes" : "No");
            //        EmergPatientDetail.Ranchi = item.Ranchi == null ? "none" : (item.Ranchi == true ? "Yes" : "No");
            //        EmergPatientDetail.AnyOtherSound = item.AnyOtherSound == null ? "none" : (item.AnyOtherSound == true ? "Yes" : "No");
            //        EmergPatientDetail.AbdomenSoft = item.AbdomenSoft == null ? "none" : (item.AbdomenSoft == true ? "Yes" : "No");
            //        EmergPatientDetail.Tenderness = item.Tenderness == null ? "none" : (item.Tenderness == true ? "Yes" : "No");
            //        EmergPatientDetail.Guarding = item.Guarding == null ? "none" : (item.Guarding == true ? "Yes" : "No");
            //        EmergPatientDetail.BowelSound = item.BowelSound == null ? "none" : (item.BowelSound == true ? "Yes" : "No");
            //        EmergPatientDetail.Distention = item.Distention == null ? "none" : (item.Distention == true ? "Yes" : "No");
            //        EmergPatientDetail.FluidThrill = item.FluidThrill == null ? "none" : (item.FluidThrill == true ? "Yes" : "No");
            //        EmergPatientDetail.ShiftingDullness = item.ShiftingDullness == null ? "none" : (item.ShiftingDullness == true ? "Yes" : "No");
            //        EmergPatientDetail.EpigastriaDiscomfort = item.EpigastriaDiscomfort == null ? "none" : (item.EpigastriaDiscomfort == true ? "Yes" : "No");
            //        EmergPatientDetail.RetrosternalBurning = item.RetrosternalBurning == null ? "none" : (item.RetrosternalBurning == true ? "Yes" : "No");
            //        EmergPatientDetail.Jondus = item.Jondus == null ? "none" : (item.Jondus == true ? "Yes" : "No");
            //        EmergPatientDetail.Pallor = item.Pallor == null ? "none" : (item.Pallor == true ? "Yes" : "No");
            //        EmergPatientDetail.Dehydration = item.Dehydration == null ? "none" : (item.Dehydration == true ? "Yes" : "No");
            //        EmergPatientDetail.GCSOrientation = item.GCSOrientation == null ? "none" : (item.GCSOrientation == true ? "Yes" : "No");
            //        EmergPatientDetail.Conscious_Orientely = item.Conscious_Orientely == null ? "none" : (item.Conscious_Orientely == true ? "Yes" : "No");
            //        EmergPatientDetail.FurtherExplanation = item.FurtherExplanation == null ? "none" : item.FurtherExplanation;

            //}

            #endregion

            return new JavaScriptSerializer().Serialize(In_PatientsExamList);

        }


        [WebMethod]
        public static string LoadPeadsHistory(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatientID));

            var PatCase = (from op in db.Out_Patients
                           join p in db.Reg_patients
                          on op.Patient_ID equals p.pat_id
                           where p.Patient_No == Patien_No
                           select new
                           {
                               op.Peads_weight,
                               op.Peads_Length,
                               op.Peads_HC,
                               op.Peads_General_Appearance,
                               op.Peads_Cyanosis,
                               op.Peads_Jaundice,
                               op.Peads_Lethargy,
                               op.Peads_Rash,
                               op.Peads_Others,
                               op.Peads_Caput,
                               op.Peads_Cephalhematoma,
                               op.Peads_Anterioropen,
                               op.Peads_AnteriorClose,
                               op.Peads_Dextrocardia,
                               op.Peads_Bulging,
                               op.Peads_Murmur,
                               op.Peads_HeartSound,
                               op.Peads_Nasal,
                               op.Peads_Recessions,
                               op.Peads_AddedSounds,
                               op.Peads_Flat,
                               op.Peads_Distended,
                               op.Peads_Scaphoid,
                               op.Peads_Liver,
                               op.Peads_Spleen,
                               op.Peads_GITOthers,
                               op.Peads_Sucking,
                               op.Peads_Rooting,
                               op.Peads_Moro,
                               op.Peads_CNSOthers,
                               op.Peads_FullTerm,
                               op.Peads_PreTerm,
                               op.Peads_DateOfDelivery,
                               op.Peads_TimeOfDelivery,
                               op.Peads_Booked,
                               op.Peads_UnBooked,
                               op.Peads_DAIHandling,
                               op.Peads_ANTURash,
                               op.Peads_PIH,
                               op.Peads_GDM,
                               op.Peads_Vacinated,
                               op.Peads_ANTOthers,
                               op.Peads_SVD,
                               op.Peads_LSCS,
                               op.Peads_Emergency,
                               op.Peads_Elective,
                               op.Peads_PlaceOfDelivery,
                               op.Peads_IndicationForLSCS,
                               op.Peads_apgerScore1min,
                               op.Peads_apgerScore5min,
                               op.Peads_Resuscitation,
                               op.Peads_NatalOthers,
                               op.Peads_Moaning,
                               op.Peads_RespDistress,
                               op.Peads_PostNATALCyanosis,
                               op.Peads_Fits,
                               op.Peads_ReluctanceToFeed,
                               op.Peads_PostNatalOthers,
                               op.Created_Time
                           }).ToList();
            return ((new JavaScriptSerializer()).Serialize(PatCase));
        }
        [WebMethod]
        public static string LoadPeadsHistoryInpat(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatientID));

            var PatCase = (from ip in db.In_Patients
                           join p in db.Reg_patients
                          on ip.Patient_ID equals p.pat_id
                           where p.Patient_No == Patien_No
                           select new
                           {
                               ip.Peads_weight,
                               ip.Peads_Length,
                               ip.Peads_HC,
                               ip.Peads_General_Appearance,
                               ip.Peads_Cyanosis,
                               ip.Peads_Jaundice,
                               ip.Peads_Lethargy,
                               ip.Peads_Rash,
                               ip.Peads_Others,
                               ip.Peads_Caput,
                               ip.Peads_Cephalhematoma,
                               ip.Peads_Anterioropen,
                               ip.Peads_AnteriorClose,
                               ip.Peads_Dextrocardia,
                               ip.Peads_Bulging,
                               ip.Peads_Murmur,
                               ip.Peads_HeartSound,
                               ip.Peads_Nasal,
                               ip.Peads_Recessions,
                               ip.Peads_AddedSounds,
                               ip.Peads_Flat,
                               ip.Peads_Distended,
                               ip.Peads_Scaphoid,
                               ip.Peads_Liver,
                               ip.Peads_Spleen,
                               ip.Peads_GITOthers,
                               ip.Peads_Sucking,
                               ip.Peads_Rooting,
                               ip.Peads_Moro,
                               ip.Peads_CNSOthers,
                               ip.Peads_FullTerm,
                               ip.Peads_PreTerm,
                               ip.Peads_DateOfDelivery,
                               ip.Peads_TimeOfDelivery,
                               ip.Peads_Booked,
                               ip.Peads_UnBooked,
                               ip.Peads_DAIHandling,
                               ip.Peads_ANTURash,
                               ip.Peads_PIH,
                               ip.Peads_GDM,
                               ip.Peads_Vacinated,
                               ip.Peads_ANTOthers,
                               ip.Peads_SVD,
                               ip.Peads_LSCS,
                               ip.Peads_Emergency,
                               ip.Peads_Elective,
                               ip.Peads_PlaceOfDelivery,
                               ip.Peads_IndicationForLSCS,
                               ip.Peads_apgerScore1min,
                               ip.Peads_apgerScore5min,
                               ip.Peads_Resuscitation,
                               ip.Peads_NatalOthers,
                               ip.Peads_Moaning,
                               ip.Peads_RespDistress,
                               ip.Peads_PostNATALCyanosis,
                               ip.Peads_Fits,
                               ip.Peads_ReluctanceToFeed,
                               ip.Peads_PostNatalOthers,
                               ip.Created_Time
                           }).ToList();
            return ((new JavaScriptSerializer()).Serialize(PatCase));
        }

        [WebMethod]
        public static string CheckExistOutPatient(int Patient_ID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var PatientExist = (from OPD in db.Out_Patients
                                    where OPD.Patient_ID == Patient_ID
                                    && OPD.Discharge == false
                                    select new
                                    {
                                        OPD.Patient_ID,
                                        OPD.Out_Patient_ID,
                                    }).ToList();

                if (PatientExist.Count != 0)
                {
                    return (new JavaScriptSerializer().Serialize("Exist"));
                }
                else
                    return (new JavaScriptSerializer().Serialize("Not Exist"));
            }
        }

        public class PatientDetail
        {
            public string Name;
            public string FatherName;
            public string Gender;
            public string Age;
            public string Patient_Type;
            public string Patient_Discount_Type;
            public string Mobile;
            public string Address;
            public string Entry_Date;
            public string department;
            public string Follow;
            public string Created_Time;
            public string Mr_No { get; set; }
            public string City { get; set; }
            public string PanelComany;
            public string DoctorName;
            // public string AdmissionDate;
            public DateTime? AdmissionDate;
            public int PatientID;
            public int In_PatientID;
            public int? Bed_No;
            public int? Ward_ID;
            public int? Room_ID;
            public string RoomType;

        }

        [System.Web.Services.WebMethod]
        public static PatientDetail GetPatientDetails(string PatientID)
        {

            int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatientID));
            PatientDetail pt = new PatientDetail();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Reg_patient pat = new Reg_patient();

            var inPatient = (from ip in db.In_Patients
                             join p in db.Reg_patients
                             on ip.Patient_ID equals p.pat_id
                             where p.Patient_No == Patien_No // && ip.Discharge != true
                             orderby ip.Admission_Date descending
                             select new
                             {
                                 p.pat_id,
                                 p.Full_Name,
                                 p.Father_Name,
                                 p.NIC,
                                 ip.Bed_No,
                                 ip.Ward_ID,
                                 ip.Room_ID,
                                 ip.Room_Type,
                                 ip.In_Patient_ID
                             }).FirstOrDefault();

            pat = (from tbl in db.Reg_patients
                   where tbl.Patient_No == Patien_No
                   orderby tbl.Created_time descending
                   select tbl).FirstOrDefault();
            var Type = (from tbl in db.In_Patients
                        where tbl.Patient_ID == int.Parse(PatientID)
                        && tbl.Discharge != true
                        orderby tbl.Created_Time descending
                        select tbl.Patient_Discount_Type).FirstOrDefault();

            if (pat != null)
            {
                pt.Name = inPatient.Full_Name;
                pt.FatherName = inPatient.Father_Name;
                pt.Bed_No = inPatient.Bed_No;
                pt.Ward_ID = inPatient.Ward_ID;
                pt.Room_ID = inPatient.Room_ID;
                pt.RoomType = inPatient.Room_Type;
                pt.PatientID = inPatient.pat_id;
                pt.In_PatientID = inPatient.In_Patient_ID;

                pt.Gender = pat.Gender;
                pt.Age = pat.Age_years.ToString();

                if (pat.Created_time.HasValue)
                {
                    pt.Entry_Date = pat.Created_time.ToString();
                }
                else
                {
                    pt.Entry_Date = pat.Created_time.ToString();
                }

                pt.Address = pat.Permanent_Address;
                pt.Mobile = pat.Mobile1;

                //pt.department = db.GetDataValueName("Patient Main Category", pat.Patient_Main_Category);
                //pt.Patient_Type = db.GetDataValueName("Patient Type", pat.Patient_Type);
                pt.Gender = db.GetDataValueName("Gender", pat.Gender);
                var Patientno = pat.Patient_No.ToString();
                var count = (db.Reg_patients.Where(v => v.Patient_No == Convert.ToInt32(Patientno)).ToList());
                pt.Follow = count.Count.ToString();
                pt.Patient_Discount_Type = db.GetDataValueName("Patient Type", Type);
                pt.Mr_No = Convert.ToString(pat.Patient_No);
                pt.City = pat.city;
                //pt.DoctorName = (from emp in db.HR_Employees where emp.Emp_ID == Convert.ToInt32(pat.Doctor_ID) select emp.Emp_Name).FirstOrDefault();
                //pt.PanelComany = (from pn in db.Panels
                //                  where pn.Panel_ID == Convert.ToInt16(pat.Panel_Companies)
                //                  select pn.Company_Name).FirstOrDefault();
                //tibit
                pt.AdmissionDate = (from i in db.In_Patients
                                    where i.Patient_ID == int.Parse(PatientID)
                                    select i.Admission_Date).FirstOrDefault();
                return pt;
            }


            else
                return pt;
        }


        [WebMethod]
        public static string SaveRecord(int Patient_ID, string btnsave, string txtAdmission_Date, string ddlDepartment, string ddlDoctor, string txtHealth_Complaints, DateTime txtExpected_Discharge_Date, string ddlIssuance_Of, string ddlWard_No, string txtBed_No, string ddlRoom_No, string txtRoom_Type, string BP_mm_Hg, string Temp_C, string Respiration_Min, string txtRN_Special_Instruction, string txtReceiving_Date, string Provisional_Diagnosis, string Reffer_To, string HistoryOfPeresentIllness, string HistoryOfFamily, string HistoryOfPastIllness, string SocioEconomicHistory, string Birth_History, string Reffer_No, string Drug_History, string Personal_History, string ObstetricHistory, string AllergiesHistory, string TreatmentHistory, string VaccinationHistory, string AnyOtherHistory, string ENT_Throat_IDL, string ENT_Throat_Nose, string ENT_Ear_Right, string Ent_Ear_Left, bool ENT_Rinnes_Right_PosNeg, bool ENT_Rinnes_Lft_PosNeg, bool ENT_Rinnes_Right_FalseNeg, bool ENT_Rinnes_Lft_FalseNeg, bool ENT_Webber_Central, bool ENT_Webber_Lateralized, bool ENT_Investigation_PTA, bool ENT_Investigation_Tympanometry, bool ENT_Rinnes_Right_Neg, bool ENT_Rinnes_Lft_Neg, bool ENT_Rinnes_Right_FNeg, bool ENT_Rinnes_Lft_FNeg, string txtInformant, string txtSourceOfReferral, bool chkNeckHolding, bool chkWalking, bool chkTalking, bool chkOthers, string txtMenarche, string txtMenstrual, string txtAttachmentSeparationfromParents, string txtHealth, bool chkNailBiting, bool chkTemperTantrums, bool chkBedWetting, string txtAcademics, string txtPeerRelationship, string txtBehaviour, string txtOccupationalHistory, string txtMaritalRelationshipSexualHistory, string txtSubstanceUse, string txtForensicUse, string txtRelationship, string txtLeisureActivities, string txtAttitudetoSelfandStandards, string txtPrevallingMood, string txtReactionPattrentoStress, string txtReligiousPracticesAttitute, string txtFather, string txtMother, string txtSiblings, string txtHomeAtmosphererelationshipsocialclass, string txtFamilialIllness, string txtActualandapparentage, string txtRace, string txtTattoosbodypiercingandscars, string txtBodyHabitus, string txttxtDress, string txtHygiene, string txtPsychomotorActivity, string txtInvoluntarymovements, string txtDystoniaEPS, string txtTardivedyskinesia, string txtTics, string txtTremors, string txtAttentivenesstointerview, string txtEyeContact, string txtLevelofConsciousness, string txtRate, string txtRhythm, string txtVolume, string txtTone, string txtModulationvar, string txtDepressed, string txtElated, string txtIrritable, string txtLabile, string txtIncongruent, string txtbluntingflatteningapathy, string txtThinkingPremeditation, string txtPlans,
            string txtActions, string txtPreservative, string txtLoosAssociation, string txtTangentiaility, string txtCircumstantiality, string txtFlightofIdeas, string txtThoughtInsertion, string txtThoughtWithdrawal, string txtThoughBroadcasting, string txtThoughControl, string txtDellusion, string txtovervaluedideas, string txtDepresonalization, string txtDerealization, string txtthrougObsession, string txtthrougPhobies, string txtthrougHomocidialIdeas, string txtillusion, string txtHallucinationAuditoryVisualOlfactoryGustatoryTactile, string txtorientationtime, string txtplace, string txtperson, string txtAttentionConcentrationSerial7Test, string txtOrDaysOfWeekReverseOrder, string txtImmediatememory, string txtshorttermrecentevents, string txtadressrecallafter2minutes, string txtlongtermremoteevents, string txtadressrecallafter5minues, string txtgeneralknowledgequestion, string txtsimplearthemeticcalculation, string txtabstrationconcertethinking, string txtinsight, string DermaFace, string DermaNeck, string DermaTrunk, string DermaUpperLimb, string DermaLowerLimb, string DermaFlexures, string DermaGenitalias, string DermaHair, string DermaNail, string DermaMucousMembrane, string DermaEyes, string DermaEars, string DermaNose, string DermaLips, string HBM_Problem, string HBM_Caused, string HBM_Started, string HBM_Course, string HBM_Treatment, string HBM_Effects, string PE_Pluse, string PE_BP, string PE_Temperature, string PE_Weight, string PE_RespiratoryRate, string PE_Jaundice, string PE_Anemia, string PE_Cyanosis, string PE_Clubbing, string PE_JVP, string PE_LymphNodes, string PE_Edema, string PE_Respiratory, string PE_Cardiovascular, string PE_Gastro_Intestinal, string PE_Observation, string PE_Cranial_Nerves, string PE_Limb_Strength, string PE_Spasticity, string PE_Position, string PE_Vibration, string PE_Stereognosis, string PE_Pain, string PE_Biceps, string PE_Triceps, string PE_Brachioradialis, string PE_Quadriceps, string PE_Patellar, string PE_Achilles, string PE_Extensor, string PE_Frontal, string PE_Finger, string PE_Heel, string PE_Movements, string PE_Gait, bool PE_Neck_Rigidity, bool PE_Kerning_Sign, bool PE_Brudzinki_Sign, string For_Summary, string For_Diagnosis, string For_AxisI, string For_AxisII, string For_AxisIII, string For_AxisIV, string For_AxisV, string For_PredisposingFactors, string For_PrecipitatingFactors, string For_PrepetuatingFactors, string For_Investigation, string For_Medical, string For_Psychological, string For_Major_Issues, string For_Strengths, string For_Goals, string For_Strategies, string txtPeads_weight, string txtPeads_Length, string txtPeads_HC, string txtPeads_General_Appearance, bool chkPeads_Cyanosis, bool chkPeads_Jaundice, bool chkPeads_Lethargy, bool chkPeads_Rash, string txtPeads_Others, bool chkPeads_Caput, bool chkPeads_Cephalhematoma, bool rdbPeads_Anterioropen, bool rdbPeads_AnteriorClose, bool chkPeads_Dextrocardia, bool chkPeads_Bulging, bool chkPeads_Murmur, string txtPeads_HeartSound, bool chkPeads_Nasal, bool chkPeads_Recessions, string txtPeads_AddedSounds, bool rdbPeads_Flat, bool rdbPeads_Distended, bool rdbPeads_Scaphoid, bool chkPeads_Liver, bool chkPeads_Spleen, string txtPeads_GITOthers, bool chkPeads_Sucking, bool chkPeads_Rooting, bool chkPeads_Moro, string txtPeads_CNSOthers, bool chkPeads_FullTerm, bool chkPeads_PreTerm, DateTime txtPeads_DateOfDelivery, string txtPeads_TimeOfDelivery, bool rdbPeads_Booked, bool rdbPeads_UnBooked, bool chkPeads_DAIHandling, bool chkPeads_ANTURash, bool chkPeads_PIH, bool chkPeads_GDM, bool chkPeads_Vacinated, string txtPeads_ANTOthers, bool rdbPeads_SVD, bool rdbPeads_LSCS, bool rdbPeads_Emergency, bool rdbPeads_Elective, string txtPeads_PlaceOfDelivery, string txtPeads_IndicationForLSCS, string Peads_apgerScore1min, string Peads_apgerScore5min, bool chkPeads_Resuscitation, string txtPeads_NatalOthers, bool chkPeads_Moaning, bool chkPeads_RespDistress, bool chkPeads_PostNATALCyanosis, bool chkPeads_Fits, bool chkPeads_ReluctanceToFeed, string txtPeads_PostNatalOthers, string txtProcedure_Operation, string txtProcedure_Detail, string txtDignosis, string txtDischarge_On, string ddlDischarge_By, string txtNext_Visit, string txtAdvice, bool chkdischarge, string PatientDiscountType, string PanelCompany, string patienttype, string referto, string referward, string referbed_no, string referroomno, string referroomtype, string RateBeats, string ddlEmrgRhythm, string ddlEmrgVolume, string OthersRN, string O2_Saturation_Oxygen1, string O2_Saturation_Oxygen2, string Saturation, bool? HMFIntact, bool? CranialNerves, bool? SignsOfMeningism, bool? HeartSound, bool? Arrhythmias, bool? AnyOtherAddedSound, bool? AnyOtherFindings, bool? NVB_Right, bool? NVB_Left, bool? Crepitation_Right, bool? Crepitation_Left, bool? Wheeze, bool? Ranchi, bool? AnyOtherSound, bool? AbdomenSoft, bool? Tenderness, bool? Guarding, bool? BowelSound, bool? Distention, bool? FluidThrill, bool? ShiftingDullness, bool? EpigastriaDiscomfort, bool? RetrosternalBurning, bool? Jondus, bool? Pallor, bool? Dehydration, bool? GCSOrientation, bool? ConsciousOrientely, bool? Murmur, string TextBoxCns, string TextBoxCvs, string TextBoxResp, string TextBoxGit, string TextBoxGpe, string eye_response, string motor_response, string verbal_Response, string accumulated_response, string FurtherExplanation, string PulseRate, string BPDischarge, string Tempdisch, string volumedisc, string RespRateDesc, string Rhythmdischarge, string Oxygen2_desc, string saturationDis, string Oxygen1, string otherecdesc, string Special_Instruction_Desc, string Receiving_Date_Discharge, string IdentificationMarks, string DateOfDeath, string TimeOfDeath, string PlaceOfDeath, string CauseOfDeath, string IssuingOfficerName, string DeathCertifiedby1, string DeathCertifiedby2, string BodyHandedOverTo, string FamilyPersonName, string CNIC, string RelationWithDeceased, string CMO_Police, string ID)
        {

            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                In_Patient OPD;
                if (btnsave == "Save")
                {
                    OPD = new In_Patient();
                    OPD.Patient_ID = Convert.ToInt32(Patient_ID);
                    OPD.Admission_Date = Convert.ToDateTime(txtAdmission_Date);
                }
                else
                {


                    OPD = (from tbl in db.In_Patients
                           where tbl.In_Patient_ID == Convert.ToInt32(ID)
                           select tbl).FirstOrDefault();
                    OPD.Updated_By = AppConfig.UserID;
                    OPD.Updated_Time = DateTime.Now;
                }
                string fee = DBClass.getParameter("In Patient Fee").ToString();
                if (fee.Trim() == string.Empty)
                    fee = "0";
                if (ddlDepartment == "019")
                {
                    OPD.Admission_Fees = 0;
                }
                else if (PatientDiscountType == "02")
                {
                    var query = (from v in db.ValueSets
                                 join d in db.DataValues
                                 on v.ValueSet_ID equals d.ValueSet_ID
                                 where v.ValueSet_Name == "Patient Type"
                                 && (d.DataValue_Description == "Private")
                                 select d.Segment1
                       ).FirstOrDefault();

                    OPD.Admission_Fees = Convert.ToInt32(query);
                }
                else if (PatientDiscountType == "10")
                {
                    OPD.Admission_Fees = 0;
                }
                else if (PatientDiscountType == "12")
                {
                    OPD.Admission_Fees = 0;
                }
                else
                {
                    OPD.Admission_Fees = int.Parse(fee);
                }

                OPD.Department = ddlDepartment;
                if (referto != "0")
                {
                    OPD.isReferred = true;



                    OPD = (from tbl in db.In_Patients
                           where tbl.In_Patient_ID == Convert.ToInt32(ID)
                           select tbl).FirstOrDefault();
                    if (referto == "001")
                    {
                        OPD.Ward_ID = Convert.ToInt32(referward);
                        OPD.Bed_No = Convert.ToInt32(referbed_no);
                        OPD.Issuance_Of = referto;

                        OPD.Room_ID = null;
                        OPD.Room_Type = null;


                        Ward_Allocation ward_aloct;

                        ward_aloct = (from tbl in db.Ward_Allocations
                                      where tbl.Ward_ID == Convert.ToInt32(referward)
                                       && tbl.InPatient_ID == (Convert.ToInt32(ID)).ToString() && tbl.Patient_ID == Convert.ToInt32(Patient_ID)
                                       && tbl.Bed_No_Assigned == Convert.ToInt32(referbed_no) && tbl.IsDischarge == false
                                      select tbl).FirstOrDefault();
                        if (ward_aloct == null)
                        {
                            ward_aloct = new Ward_Allocation();

                            ward_aloct.Created_By = AppConfig.UserID;
                            ward_aloct.Created_Time = DateTime.Now;
                            ward_aloct.Book_ID = AppConfig.Book_ID;
                            ward_aloct.Company_ID = AppConfig.Company_ID;
                            ward_aloct.From_TimeDate = Convert.ToDateTime(DateTime.Now);
                            db.Ward_Allocations.InsertOnSubmit(ward_aloct);
                            var PreviousWardHistory = (from tbl in db.Ward_Allocations
                                                       join inpat in db.In_Patients
                                                       on tbl.InPatient_ID equals inpat.In_Patient_ID.ToString()
                                                       where tbl.InPatient_ID == (Convert.ToInt32(ID)).ToString() && tbl.Patient_ID == Convert.ToInt32(Patient_ID)
                                                       && tbl.IsDischarge == false
                                                       select tbl).ToList();
                            if (PreviousWardHistory.Count != 0)
                            {

                                foreach (var ward in PreviousWardHistory)
                                {
                                    ward.IsDischarge = true;
                                    ward.To_TimeDate = Convert.ToDateTime(DateTime.Now);
                                }
                            }
                            var DuplicateBed = (from tbl in db.Ward_Allocations
                                                where tbl.Ward_ID == Convert.ToInt32(referward)
                                   && tbl.InPatient_ID != (Convert.ToInt32(ID)).ToString() && tbl.Patient_ID != Convert.ToInt32(Patient_ID)
                                   && tbl.Bed_No_Assigned == Convert.ToInt32(referbed_no) && tbl.IsDischarge == false
                                                select tbl).FirstOrDefault();
                            if (DuplicateBed != null)
                            {
                                DuplicateBed.IsDischarge = true;
                                DuplicateBed.To_TimeDate = Convert.ToDateTime(DateTime.Now);
                            }
                        }
                        else
                        {

                            ward_aloct.Updated_By = AppConfig.UserID;
                            ward_aloct.Updated_Time = DateTime.Now;
                        }
                        ward_aloct.InPatient_ID = Convert.ToInt32(ID).ToString();
                        ward_aloct.Patient_ID = Convert.ToInt32(Patient_ID);
                        ward_aloct.Ward_ID = Convert.ToInt32(referward);
                        ward_aloct.Bed_No_Assigned = Convert.ToInt32(referbed_no);

                        ward_aloct.Doctor_Assigned = Convert.ToInt32(ddlDoctor);
                        if (chkdischarge == true)
                        {
                            ward_aloct.IsDischarge = true;
                            ward_aloct.To_TimeDate = Convert.ToDateTime(txtExpected_Discharge_Date);
                        }
                        else
                        {
                            ward_aloct.IsDischarge = false;
                        }
                        var PreviousRoomHistory = (from tbl in db.Room_Allocations
                                                   join inpat in db.In_Patients
                                                   on tbl.In_Patient_ID equals inpat.In_Patient_ID
                                                   where tbl.In_Patient_ID == Convert.ToInt32(ID) && tbl.Patient_ID == Convert.ToInt32(Patient_ID)
                                                   && tbl.IsDischarge == false
                                                   select tbl).ToList();
                        if (PreviousRoomHistory.Count != 0)
                        {
                            foreach (var room in PreviousRoomHistory)
                            {
                                room.IsDischarge = true;
                                room.To_Date = Convert.ToDateTime(DateTime.Now);

                            }
                        }

                        db.SubmitChanges();

                    }
                    else
                    {

                        OPD.Room_ID = Convert.ToInt32(referroomno);
                        OPD.Room_Type = referroomtype.ToString();
                        OPD.Issuance_Of = referto;

                        OPD.Ward_ID = null;
                        OPD.Bed_No = null;

                        Room_Allocation room_aloct;
                        room_aloct = (from tbl in db.Room_Allocations
                                      where tbl.Room_Type == referroomtype
                                       && tbl.In_Patient_ID == Convert.ToInt32(ID) && tbl.Patient_ID == Convert.ToInt32(Patient_ID)
                                       && tbl.Room_ID == Convert.ToInt32(referroomno) && tbl.IsDischarge == false
                                      select tbl).FirstOrDefault();

                        if (room_aloct == null)
                        {
                            room_aloct = new Room_Allocation();
                            room_aloct.Created_By = AppConfig.UserID;
                            room_aloct.Created_Time = DateTime.Now;
                            room_aloct.Book_ID = AppConfig.Book_ID;
                            room_aloct.Company_ID = AppConfig.Company_ID;
                            room_aloct.From_Date = Convert.ToDateTime(DateTime.Now);
                            db.Room_Allocations.InsertOnSubmit(room_aloct);
                            var PreviousRoomHistory = (from tbl in db.Room_Allocations
                                                       join inpat in db.In_Patients
                                                       on tbl.In_Patient_ID equals inpat.In_Patient_ID
                                                       where tbl.In_Patient_ID == Convert.ToInt32(ID) && tbl.Patient_ID == Convert.ToInt32(Patient_ID)
                                                       && tbl.IsDischarge == false
                                                       select tbl).ToList();
                            if (PreviousRoomHistory.Count != 0)
                            {
                                foreach (var rm in PreviousRoomHistory)
                                {
                                    rm.IsDischarge = true;
                                    rm.To_Date = Convert.ToDateTime(DateTime.Now);
                                }
                            }
                        }
                        else
                        {
                            room_aloct.Updated_By = AppConfig.UserID;
                            room_aloct.Updated_Time = DateTime.Now;
                        }
                        room_aloct.In_Patient_ID = Convert.ToInt32(ID);
                        room_aloct.Patient_ID = Convert.ToInt32(Patient_ID);
                        room_aloct.Room_ID = Convert.ToInt32(referroomno);

                        room_aloct.Room_Type = referroomtype;

                        if (chkdischarge == true)
                        {
                            room_aloct.IsDischarge = true;
                        }
                        else
                        {
                            room_aloct.IsDischarge = false;
                        }
                        var PreviousWardHistory = (from tbl in db.Ward_Allocations
                                                   join inpat in db.In_Patients
                                                   on tbl.InPatient_ID equals inpat.In_Patient_ID.ToString()
                                                   where tbl.InPatient_ID == Convert.ToInt32(ID).ToString() && tbl.Patient_ID == Convert.ToInt32(Patient_ID)
                                                   && tbl.IsDischarge == false
                                                   select tbl).ToList();
                        if (PreviousWardHistory.Count != 0)
                        {
                            foreach (var ward in PreviousWardHistory)
                            {
                                ward.IsDischarge = true;
                                ward.To_TimeDate = Convert.ToDateTime(DateTime.Now);

                            }
                        }
                        db.SubmitChanges();
                    }
                    db.SubmitChanges();

                }
                else
                {
                    OPD.isReferred = false;
                    if (ddlIssuance_Of == "001")
                    {
                        OPD.Ward_ID = Convert.ToInt32(ddlWard_No);
                        OPD.Bed_No = Convert.ToInt32(txtBed_No);

                    }
                    else
                    {
                        OPD.Room_ID = Convert.ToInt32(ddlRoom_No);
                        OPD.Room_Type = txtRoom_Type.ToString();

                    }
                }
                OPD.Health_Complaints = txtHealth_Complaints;
                OPD.Expected_Discharge_Date = Convert.ToDateTime(txtExpected_Discharge_Date);
                OPD.Doctor = ddlDoctor;
                if (referto != "0")
                {
                    OPD.Issuance_Of = referto;
                }
                else
                {
                    OPD.Issuance_Of = ddlIssuance_Of;
                }

                OPD.IdentificationMarks = IdentificationMarks;
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

                OPD.Patient_Discount_Type = PatientDiscountType;
                OPD.Panel_Company = PanelCompany;

                OPD.BP_mm_Hg = BP_mm_Hg;
                OPD.Temp_C = Temp_C;
                OPD.Respiration_Min = Respiration_Min;

                OPD.Receiving_date = Convert.ToDateTime(txtReceiving_Date);
                OPD.RN_Special_Instruction = txtRN_Special_Instruction;


                OPD.ProvisionalDiagnosis = Provisional_Diagnosis;
                OPD.HistoryOfPeresentIllness = HistoryOfPeresentIllness;
                OPD.HistoryOfFamily = HistoryOfFamily;
                OPD.HistoryOfPastIllness = HistoryOfPastIllness;

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
                OPD.CNS_Value = TextBoxCns;
                OPD.CVS_Value = TextBoxCvs;
                OPD.RESP_Value = TextBoxResp;
                OPD.GIT_Value = TextBoxGit;
                OPD.GPE_Value = TextBoxGpe;
                OPD.Eye_Opening_Response = eye_response;
                OPD.Motor_Response = motor_response;
                OPD.Verbal_Response = verbal_Response;
                OPD.Accumulated_Response = accumulated_response;
                OPD.Jondus = Jondus;
                OPD.Pallor = Pallor;
                OPD.Dehydration = Dehydration;
                OPD.GCSOrientation = GCSOrientation;
                OPD.Conscious_Orientely = ConsciousOrientely;
                OPD.FurtherExplanation = FurtherExplanation;


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
                OPD.Procedure_Operation = txtProcedure_Operation;
                OPD.Procedure_Detail = txtProcedure_Detail;
                OPD.Diagonosis = txtDignosis;
                OPD.Discharge_By = ddlDischarge_By;
                if (chkdischarge == true)
                {
                    if (!string.IsNullOrEmpty(txtDischarge_On))
                        OPD.Discharge_On = Convert.ToDateTime(txtDischarge_On);
                    if (!string.IsNullOrEmpty(txtNext_Visit))
                        OPD.Next_Visit = Convert.ToDateTime(txtNext_Visit);

                    // SMS Configration
                    string SMS_Contant = "عارف میموریل ٹیچنگ ہسپتال کی سہولیات پر اعتمادکرنےکاشکریہ ہماری سہولیات کی بہتری کے لیےآپ نیچےدیئے گے نمبرپر رابطہ کریں۔ 03138458018";
                    string msg = "";
                    //string CellNumber = txtMobile1.Text;
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
                    db.In_Patients.InsertOnSubmit(OPD);
                    // SMS Configration
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

                if (RateBeats != "" || (!string.IsNullOrEmpty(ddlEmrgRhythm) && ddlEmrgRhythm != "0") || (!string.IsNullOrEmpty(ddlEmrgVolume) && ddlEmrgVolume != "0") || OthersRN != "" || BP_mm_Hg != "" || Temp_C != "" || Respiration_Min != "" || Saturation != "" || txtRN_Special_Instruction != "")
                {
                    ReceivingNote rcvNote = new ReceivingNote();
                    rcvNote.Patient_ID = Convert.ToInt32(Patient_ID);
                    rcvNote.Emergency_ID = null;
                    rcvNote.In_Patient_ID = OPD.In_Patient_ID;
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
                    rcvNote.Type_Nursing = "IPD Receiving Note";
                    db.ReceivingNotes.InsertOnSubmit(rcvNote);
                    db.SubmitChanges();
                }

                if (PulseRate != "" || (!string.IsNullOrEmpty(Rhythmdischarge) && Rhythmdischarge != "0") || (!string.IsNullOrEmpty(volumedisc) && volumedisc != "0") || otherecdesc != "" || BPDischarge != "" || Tempdisch != "" || RespRateDesc != "" || Oxygen2_desc != "" || Special_Instruction_Desc != "")
                {
                    ReceivingNote rcvNote = new ReceivingNote();
                    rcvNote.Patient_ID = Convert.ToInt32(Patient_ID);
                    rcvNote.Emergency_ID = null;
                    rcvNote.In_Patient_ID = OPD.In_Patient_ID;
                    rcvNote.RateBeats = PulseRate;
                    rcvNote.Emergency_Rhythm = Rhythmdischarge;
                    rcvNote.Emergency_Volume = volumedisc;
                    rcvNote.OthersRecieveNote = otherecdesc;
                    rcvNote.BloodPressure = BPDischarge;
                    rcvNote.Temperature = Tempdisch;
                    rcvNote.RespirationRate = RespRateDesc;
                    rcvNote.O2_Saturation = saturationDis;
                    rcvNote.RN_Special_Instruction = Special_Instruction_Desc;
                    rcvNote.Receiving_Date = Convert.ToDateTime(Receiving_Date_Discharge);
                    rcvNote.O2_Saturation_Oxygen1 = Oxygen1;
                    rcvNote.O2_Saturation_Oxygen2 = Oxygen2_desc;
                    rcvNote.user_id = AppConfig.UserID;
                    rcvNote.Type_Nursing = "Discharge IPD Receiving Note";
                    db.ReceivingNotes.InsertOnSubmit(rcvNote);
                    db.SubmitChanges();
                }

                if (ddlIssuance_Of == "001")
                {
                    List<Ward_Allocation> wlist = db.Ward_Allocations.Where(p => p.InPatient_ID == "0").ToList();
                    foreach (Ward_Allocation med in wlist)
                    {
                        med.InPatient_ID = OPD.In_Patient_ID.ToString();
                    }
                }
                else
                {
                    List<Room_Allocation> kklist = db.Room_Allocations.Where(p => p.In_Patient_ID == 0).ToList();
                    foreach (Room_Allocation med in kklist)
                    {
                        med.In_Patient_ID = OPD.In_Patient_ID;
                    }
                }
                /***********Setting 0 Inpatient id inserted medicine to current In patient id****************/
                List<In_Patient_Medicine> list = db.In_Patient_Medicines.Where(p => p.Patient_ID == 0 && p.Transaction_Type == "InPatient").ToList();
                foreach (In_Patient_Medicine med in list)
                {
                    med.Patient_ID = OPD.In_Patient_ID;
                }
                List<In_Patient_Medicine> lists = db.In_Patient_Medicines.Where(p => p.Patient_ID == 0 && p.Transaction_Type == "InPatient Discharge Medicine").ToList();
                foreach (In_Patient_Medicine med in lists)
                {
                    med.Patient_ID = OPD.In_Patient_ID;
                }
                /***********Setting 0 Inpatient id inserted Instruction to current In patient id****************/
                List<InPatient_Instruction> Inslist = db.InPatient_Instructions.Where(p => p.In_Patient_ID == 0).ToList();
                foreach (InPatient_Instruction Ins in Inslist)
                {
                    Ins.In_Patient_ID = OPD.In_Patient_ID;
                }
                List<InPatient_Doctor_Note> DOclist = db.InPatient_Doctor_Notes.Where(p => p.In_Patient_ID == 0).ToList();
                foreach (InPatient_Doctor_Note DOd in DOclist)
                {
                    DOd.In_Patient_ID = OPD.In_Patient_ID;
                }
                List<Lab_Resultrpt> lablist = db.Lab_Resultrpts.Where(p => p.In_Patient_ID == 0).ToList();
                foreach (Lab_Resultrpt DOd in lablist)
                {
                    DOd.In_Patient_ID = OPD.In_Patient_ID;
                }
                /***********Setting 0 Inpatient id inserted eyes to current In patient id****************/
                List<PMS.EyeDetail> eyelist = db.EyeDetails.Where(t => t.TransactionType == "InPatient" && t.TransactionID == 0).ToList();
                foreach (PMS.EyeDetail eye in eyelist)
                {
                    eye.TransactionID = OPD.In_Patient_ID;
                }
                /***********Setting 0 patient id inserted test to current In patient id****************/
                Laboratory_Test test = db.Laboratory_Tests.Where(p => p.Patient_ID == 0 && p.Transaction_Type == "InPatient").FirstOrDefault();
                if (test != null)
                    test.Patient_ID = OPD.In_Patient_ID;
                var INPATID = OPD.In_Patient_ID;
                /***********Setting 0 patient id inserted Ortho to current out patient id****************/
                List<PMS.Ortho> ortholist = db.Orthos.Where(t => t.Patient_Type == "InPatient" && t.Transaction_ID == 0).ToList();
                foreach (PMS.Ortho orth in ortholist)
                {
                    orth.Transaction_ID = OPD.In_Patient_ID;
                }
                db.SubmitChanges();
                var InPatientID = OPD.In_Patient_ID;
                return InPatientID.ToString();
            }
        }

        public class Detail
        {
            public string Name;
            public string PatientType;
            public string InPatient_AdmitCategory { get; set; }
            public string InPatient_Id { get; set; }
            public string DoctorId { get; set; }
            public string Department { get; set; }
            public string Gender;
            public string Age;
            public string Mobile;
            public string Address;
            public string Entry_Date;
        }

        [WebMethod]
        public static string PendingAdmisionPatients()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var data = (from op in db.Out_Patients
                        join p in db.Reg_patients
                        on op.Patient_ID equals p.pat_id
                        where op.Follow_Up == "002" &&
              Convert.ToDateTime(op.Created_Time).Month == DateTime.Now.Month && Convert.ToDateTime(op.Created_Time).Year == DateTime.Now.Year && Convert.ToDateTime(op.Created_Time).Day == DateTime.Now.Day
                        select new
                        {
                            p.pat_id,
                            p.Patient_No,
                            p.Full_Name,
                            p.NIC,
                            //tibit
                            //Department = db.GetDataValueName("Patient Main Category", p.Patient_Main_Category),
                            Gender = db.GetDataValueName("Gender", p.Gender),
                            p.Created_time,
                        }
                       ).ToList();
            return (new JavaScriptSerializer()).Serialize(data);
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
        public static string FillPharmacyItemDropDown()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Routes = (from d in db.INV_Items

                          where d.Pharmacy_Item == true
                          select new
                          {
                              d.Item_Code,
                              Description = (d.Salt != null ? (d.Salt + "-" + d.Description) : d.Description),
                          }).ToList();

            return (new JavaScriptSerializer().Serialize(Routes));
        }

        [WebMethod]
        public static string GetDoctorsAgainstMO(string status)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from d in db.HR_Employees.Where(x => x.Designation.Equals(status) && x.IsDoctor == true)


                         select new
                         {
                             d.Emp_ID,
                             d.Emp_Name
                         }).ToList();

            return (new JavaScriptSerializer().Serialize(query));
        }

        [WebMethod]
        public static string LoadAllTestResultCatagory(string LabDTestID, string CatID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var LabTestID = (from pat in db.Lab_Test_Details where pat.Lab_Test_Detail_ID == Convert.ToInt32(LabDTestID) select pat.Lab_Test_ID).FirstOrDefault();

            var inPatmedicineList = (from lbtM in db.Laboratory_Tests
                                     join lbtD in db.Lab_Test_Details
                                     on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                     join t in db.Lab_Tests
                                     on lbtD.Test_ID equals t.Test_ID
                                     where lbtD.Lab_Test_ID == Convert.ToInt32(LabTestID)
                                     select new
                                     {
                                         lbtM.Lab_Test_ID,
                                         lbtD.Lab_Test_Detail_ID,
                                         lbtD.Test_ID,
                                         Test_Name = ((from pat in db.Lab_Tests where pat.Test_ID == lbtD.Test_ID select pat.Test_Name).FirstOrDefault()),
                                         lbtD.IsBilled,
                                         lbtD.Catagory_ID,
                                     }).ToList();

            return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
        }

        [WebMethod]
        public static string LoadimagesDetail(string TestDetailID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var data = (from td in db.Test_Images

                        where td.Lab_Test_Detail_ID == int.Parse(TestDetailID)
                        select new
                        {
                            td.Image_path,
                            td.Lab_Test_ID,
                        }).ToList();
            return (new JavaScriptSerializer().Serialize(data));
        }

        //[WebMethod]
        //public static string FillDoctorsByDepartment(string DepartmentId)
        //{
        //    DataBaseDataContext db = new DataBaseDataContext();

        //    List<HR_Employee> EmpList = new List<HR_Employee>();
        //    EmpList = (from tbl in db.HR_Employees
        //               where tbl.IsDoctor == true
        //               //&& tbl.Department == DepartmentId && (tbl.Designation == "004" || tbl.Designation == "005" || tbl.Designation == "005" || tbl.Designation == "006" || tbl.Designation == "007" || tbl.Designation == "008"))
        //               select tbl).ToList();
        //    return (new JavaScriptSerializer().Serialize(EmpList));

        //}

        [WebMethod]
        public static string FillDoctorsByDepartment(string DepartmentId)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            List<HR_Employee> EmpList = new List<HR_Employee>();
            EmpList = (from tbl in db.HR_Employees
                       where tbl.IsDoctor == true
                       && tbl.Department == DepartmentId                  
                       select tbl).ToList();

            return (new JavaScriptSerializer()).Serialize(EmpList);
        }

        [System.Web.Services.WebMethod]
        public static Detail GetDetail(string PatientID)
        {
            int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatientID));

            Detail pt = new Detail();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Reg_patient pat = new Reg_patient();
            pat = (from tbl in db.Reg_patients
                   where tbl.Patient_No == Patien_No
                   orderby tbl.Created_time descending
                   select tbl).FirstOrDefault();
            var Type = (from tbl in db.In_Patients
                        where tbl.Patient_ID == Convert.ToInt32(pat.pat_id)
                        && tbl.Discharge != true
                        orderby tbl.Created_Time descending

                        select new
                        {
                            Patient_Discount_Type = tbl.Patient_Discount_Type,
                            InPatient_Id = tbl.In_Patient_ID,

                            Department = tbl.Department
                        }).FirstOrDefault();
            if (Type == null)
            {
                Type = (from tbl in db.In_Patients
                        where tbl.Patient_ID == Convert.ToInt32(PatientID)
                        && tbl.Discharge != true
                        orderby tbl.Created_Time descending

                        select new
                        {
                            Patient_Discount_Type = tbl.Patient_Discount_Type,
                            InPatient_Id = tbl.In_Patient_ID,

                            Department = tbl.Department
                        }).FirstOrDefault();
                if (Type == null)
                {
                    var result = db.Reg_patients.Where(x => x.Patient_No.Equals(Patien_No)).Select(x => x.pat_id).ToList();
                    Type = (from d in db.In_Patients
                            where result.Contains(Convert.ToInt32(d.Patient_ID))
                            select new
                            {
                                Patient_Discount_Type = d.Patient_Discount_Type,
                                InPatient_Id = d.In_Patient_ID,

                                Department = d.Department


                            }).FirstOrDefault();

                }

            }
            if (pat != null)
            {
                pt.Name = pat.Full_Name;
                pt.Gender = pat.Gender;
                pt.Age = pat.Age_years.ToString();
                if (pat.Created_time.HasValue)
                    pt.Entry_Date = pat.Created_time.ToString();
                pt.Address = pat.Permanent_Address;
                pt.Mobile = pat.Mobile1;
                pt.Gender = db.GetDataValueName("Gender", pat.Gender);
                //tibit
                //pt.PatientType = db.GetDataValueName("Patient Type", pat.Patient_Type);

                if (Type != null)
                {
                    pt.InPatient_AdmitCategory = db.GetDataValueName("Patient Type", Type.Patient_Discount_Type);
                    pt.InPatient_Id = Convert.ToString(Type.InPatient_Id);
                    pt.Department = Type.Department;
                }


                return pt;
            }
            else
                return pt;
        }

        protected void btnNew_Click(object sender, EventArgs e)
        {
            if (Request.QueryString["ID"] != null)
            {
                Response.Redirect("~/InPatientsCase.aspx", false);
            }
            BlankForm();
            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "", "Combination();", true);
        }
        private int? TryPrs(string s)
        {
            int i = 1;
            if (!int.TryParse(s, out i))
            {
                return null;
            }
            else
            {
                return i;
            }
        }
        [WebMethod]
        public static string FillOtherTest(string dpt)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var INV_Items = from itm in db.Lab_Tests

                            where itm.Main_Department == dpt
                            select new
                            {
                                itm.Main_Department,
                                itm.Test_ID,
                                itm.Test_Name,
                                Main_Department_Name = (db.GetDataValueName("Main Test Departments", itm.Main_Department))
                            };
            return (new JavaScriptSerializer().Serialize(INV_Items));
        }

        [WebMethod]
        public static string GetProcedure(string dpt)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var INV_Items = from itm in db.Lab_Tests

                            where itm.Main_Department == dpt
                            select new
                            {
                                itm.Main_Department,
                                itm.Test_ID,
                                itm.Test_Name,
                                Main_Department_Name = (db.GetDataValueName("Main Test Departments", itm.Main_Department))
                            };
            return (new JavaScriptSerializer().Serialize(INV_Items));
        }

        [WebMethod]
        public static string GetBBDDLDetails(string SerialNo)
        {

            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var test = (from t in db.Lab_Tests
                        where t.Main_Department == "005" && t.Test_Name == SerialNo
                        select new { t.Test_ID, t.Test_Name, t.Group_Category, TestMainDepartmentName = db.GetDataValueName("Main Test Departments", t.Main_Department.ToString()).ToString(), GroupCategoryName = db.GetDataValueName("Test Groups", t.Group_Category.ToString()).ToString() }).ToList();
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
                                       select new { Test_ID = 0, Group_Category = dv.DataValue_Name, Test_Name = dv.DataValue_Description, TestMainDepartmentName = "Blood Bank", Main_Department = "005" }).ToList();
                return (new JavaScriptSerializer()).Serialize(GroupCategories);
            }

        }

        [WebMethod]
        public static string LoadPsychiatryHistoryInpat(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatientID));

            var PatCase = (from op in db.In_Patients
                           join p in db.Reg_patients
                          on op.Patient_ID equals p.pat_id
                           where p.Patient_No == Patien_No
                           select new
                           {

                               op.Psychiatry_Informant,

                               op.Psychiatry_Source_Referral,
                               op.Psychiatry_Neck_Holding,
                               op.Psychiatry_Walking,
                               op.Psychiatry_Talking,
                               op.Psychiatry_Others,
                               op.Psychiatry_Menarche,
                               op.Psychiatry_Menstrual,
                               op.Psychiatry_Attachment_Separation,
                               op.Psychiatry_Health,

                               op.Psychiatry_Nail_Biting,
                               op.Psychiatry_Temper_Tantrums,
                               op.Psychiatry_Bed_Wetting,
                               op.Psychiatry_Academics,

                               op.Psychiatry_Peer_Relationship,
                               op.Psychiatry_Behaviour,
                               op.Psychiatry_Occupational_History,
                               op.Psychiatry_Sexual_History,
                               op.Psychiatry_Substance_Use,
                               op.Psychiatry_Forensic_Use,
                               op.Psychiatry_Relationship,
                               op.Psychiatry_Leisure_Activities,
                               op.Psychiatry_Attitude_Standards,
                               op.Psychiatry_Prevalling_Mood,
                               op.Psychiatry_Reaction_Stress,
                               op.Psychiatry_Religious_Practices,
                               op.Psychiatry_Father,
                               op.Psychiatry_Mother,

                               op.Psychiatry_Siblings,
                               op.Psychiatry_Home_Atmosphere,
                               op.Psychiatry_Familial_Illness,

                               op.Psychiatry_Actual_age,
                               op.Psychiatry_Race,
                               op.Psychiatry_Tattoos_body_scars,
                               op.Psychiatry_Body_Habitus,
                               op.Psychiatry_Dress,
                               op.Psychiatry_Hygiene,
                               op.Psychiatry_Psychomotor_Activity,
                               op.Psychiatry_Involuntary_movements,
                               op.Psychiatry_Dystonia_EPS,
                               op.Psychiatry_Tardive_dyskinesia,

                               op.Psychiatry_Tics,
                               op.Psychiatry_Tremors,
                               op.Psychiatry_Attentiveness_interview,
                               op.Psychiatry_Eye_Contact,
                               op.Psychiatry_Level_Consciousness,
                               op.Psychiatry_Rate,
                               op.Psychiatry_Rhythm,
                               op.Psychiatry_Volume,
                               op.Psychiatry_Tone,
                               op.Psychiatry_Modulation,
                               op.Psychiatry_Depressed,
                               op.Psychiatry_Elated,

                               op.Psychiatry_Irritable,
                               op.Psychiatry_Labile,
                               op.Psychiatry_Incongruent,
                               op.Psychiatry_Blunting_Flattening_Apathy,
                               op.Psychiatry_Thinking,
                               op.Psychiatry_Plans,
                               op.Psychiatry_Actions,
                               op.Psychiatry_Preservative,
                               op.Psychiatry_LoosAssociation,
                               op.Psychiatry_Tangentiaility,
                               op.Psychiatry_Circumstantiality,
                               op.Psychiatry_Flight_Ideas,
                               op.Psychiatry_Thought_Insertion,
                               op.Psychiatry_Thought_Withdrawal,
                               op.Psychiatry_Thought_Broadcasting,
                               op.Psychiatry_Thought_Control,
                               op.Psychiatry_Dellusion,
                               op.Psychiatry_Overvalued_Ideas,
                               op.Psychiatry_Depresonalization,
                               op.Psychiatry_Derealization,

                               op.Psychiatry_Obsession,
                               op.Psychiatry_Phobies,
                               op.Psychiatry_Homocidial_Ideas,
                               op.Psychiatry_Illusion,
                               op.Psychiatry_Hallucination,
                               op.Psychiatry_Orientation_Time,
                               op.Psychiatry_Place,
                               op.Psychiatry_Person,
                               op.Psychiatry_Attention_Concentration,
                               op.Psychiatry_Days_Week,
                               op.Psychiatry_Immediate_Memory,
                               op.Psychiatry_Recent_Events,
                               op.Psychiatry_Adress_Recall_Two,
                               op.Psychiatry_Remote_Events,
                               op.Psychiatry_Adress_Recall_Five,
                               op.Psychiatry_General_knowledge,
                               op.Psychiatry_Arthemetic_Calculation,
                               op.Psychiatry_Abstraction,
                               op.Psychiatry_Insight,
                               op.Created_Time,
                               op.Psychiatry_HBM_Problem,
                               op.Psychiatry_HBM_Caused,
                               op.Psychiatry_HBM_Started,
                               op.Psychiatry_HBM_Course,
                               op.Psychiatry_HBM_Treatment,
                               op.Psychiatry_HBM_Effects,
                               op.Psychiatry_PE_Pluse,
                               op.Psychiatry_PE_BP,
                               op.Psychiatry_PE_Temperature,
                               op.Psychiatry_PE_Weight,
                               op.Psychiatry_PE_RespiratoryRate,
                               op.Psychiatry_PE_Jaundice,
                               op.Psychiatry_PE_Anemia,
                               op.Psychiatry_PE_Cyanosis,
                               op.Psychiatry_PE_Clubbing,
                               op.Psychiatry_PE_JVP,
                               op.Psychiatry_PE_LymphNodes,
                               op.Psychiatry_PE_Edema,
                               op.Psychiatry_PE_Respiratory,
                               op.Psychiatry_PE_Cardiovascular,
                               op.Psychiatry_PE_Gastro_Intestinal,
                               op.Psychiatry_PE_Observation,
                               op.Psychiatry_PE_Cranial_Nerves,
                               op.Psychiatry_PE_Limb_Strength,
                               op.Psychiatry_PE_Spasticity,
                               op.Psychiatry_PE_Position,
                               op.Psychiatry_PE_Vibration,
                               op.Psychiatry_PE_Stereognosis,
                               op.Psychiatry_PE_Pain,
                               op.Psychiatry_PE_Biceps,
                               op.Psychiatry_PE_Triceps,
                               op.Psychiatry_PE_Brachioradialis,
                               op.Psychiatry_PE_Quadriceps,
                               op.Psychiatry_PE_Patellar,
                               op.Psychiatry_PE_Achilles,
                               op.Psychiatry_PE_Extensor,
                               op.Psychiatry_PE_Frontal,
                               op.Psychiatry_PE_Finger,
                               op.Psychiatry_PE_Heel,
                               op.Psychiatry_PE_Movements,
                               op.Psychiatry_PE_Gait,
                               op.Psychiatry_PE_Neck_Rigidity,
                               op.Psychiatry_PE_Kerning_Sign,
                               op.Psychiatry_PE_Brudzinki_Sign,
                               op.Psychiatry_For_Summary,
                               op.Psychiatry_For_Diagnosis,
                               op.Psychiatry_For_AxisI,
                               op.Psychiatry_For_AxisIII,
                               op.Psychiatry_For_AxisII,
                               op.Psychiatry_For_AxisIV,
                               op.Psychiatry_For_AxisV,
                               op.Psychiatry_For_PredisposingFactors,
                               op.Psychiatry_For_PrecipitatingFactors,
                               op.Psychiatry_For_PrepetuatingFactors,
                               op.Psychiatry_For_Investigation,
                               op.Psychiatry_For_Medical,
                               op.Psychiatry_For_Psychological,
                               op.Psychiatry_Major_Issues,
                               op.Psychiatry_For_Strengths,
                               op.Psychiatry_For_Goals,
                               op.Psychiatry_For_Strategies,
                           }).ToList();
            return ((new JavaScriptSerializer()).Serialize(PatCase));
        }
        [WebMethod]
        public static string LoadPsychiatryHistory(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatientID));

            var PatCase = (from op in db.Out_Patients
                           join p in db.Reg_patients
                          on op.Patient_ID equals p.pat_id
                           where p.Patient_No == Patien_No
                           select new
                           {

                               op.Psychiatry_Informant,

                               op.Psychiatry_Source_Referral,
                               op.Psychiatry_Neck_Holding,
                               op.Psychiatry_Walking,
                               op.Psychiatry_Talking,
                               op.Psychiatry_Others,
                               op.Psychiatry_Menarche,
                               op.Psychiatry_Menstrual,
                               op.Psychiatry_Attachment_Separation,
                               op.Psychiatry_Health,

                               op.Psychiatry_Nail_Biting,
                               op.Psychiatry_Temper_Tantrums,
                               op.Psychiatry_Bed_Wetting,
                               op.Psychiatry_Academics,

                               op.Psychiatry_Peer_Relationship,
                               op.Psychiatry_Behaviour,
                               op.Psychiatry_Occupational_History,
                               op.Psychiatry_Sexual_History,
                               op.Psychiatry_Substance_Use,
                               op.Psychiatry_Forensic_Use,
                               op.Psychiatry_Relationship,
                               op.Psychiatry_Leisure_Activities,
                               op.Psychiatry_Attitude_Standards,
                               op.Psychiatry_Prevalling_Mood,
                               op.Psychiatry_Reaction_Stress,
                               op.Psychiatry_Religious_Practices,
                               op.Psychiatry_Father,
                               op.Psychiatry_Mother,

                               op.Psychiatry_Siblings,
                               op.Psychiatry_Home_Atmosphere,
                               op.Psychiatry_Familial_Illness,
                               // op.Psychiatry_Rel,
                               op.Psychiatry_Actual_age,
                               op.Psychiatry_Race,
                               op.Psychiatry_Tattoos_body_scars,
                               op.Psychiatry_Body_Habitus,
                               op.Psychiatry_Dress,
                               op.Psychiatry_Hygiene,
                               op.Psychiatry_Psychomotor_Activity,
                               op.Psychiatry_Involuntary_movements,
                               op.Psychiatry_Dystonia_EPS,
                               op.Psychiatry_Tardive_dyskinesia,

                               op.Psychiatry_Tics,
                               op.Psychiatry_Tremors,
                               op.Psychiatry_Attentiveness_interview,
                               op.Psychiatry_Eye_Contact,
                               op.Psychiatry_Level_Consciousness,
                               op.Psychiatry_Rate,
                               op.Psychiatry_Rhythm,
                               op.Psychiatry_Volume,
                               op.Psychiatry_Tone,
                               op.Psychiatry_Modulation,
                               op.Psychiatry_Depressed,
                               op.Psychiatry_Elated,

                               op.Psychiatry_Irritable,
                               op.Psychiatry_Labile,
                               op.Psychiatry_Incongruent,
                               op.Psychiatry_Blunting_Flattening_Apathy,
                               op.Psychiatry_Thinking,
                               op.Psychiatry_Plans,
                               op.Psychiatry_Actions,
                               op.Psychiatry_Preservative,
                               op.Psychiatry_LoosAssociation,
                               op.Psychiatry_Tangentiaility,
                               op.Psychiatry_Circumstantiality,
                               op.Psychiatry_Flight_Ideas,
                               op.Psychiatry_Thought_Insertion,
                               op.Psychiatry_Thought_Withdrawal,
                               op.Psychiatry_Thought_Broadcasting,
                               op.Psychiatry_Thought_Control,
                               op.Psychiatry_Dellusion,
                               op.Psychiatry_Overvalued_Ideas,
                               op.Psychiatry_Depresonalization,
                               op.Psychiatry_Derealization,

                               op.Psychiatry_Obsession,
                               op.Psychiatry_Phobies,
                               op.Psychiatry_Homocidial_Ideas,
                               op.Psychiatry_Illusion,
                               op.Psychiatry_Hallucination,
                               op.Psychiatry_Orientation_Time,
                               op.Psychiatry_Place,
                               op.Psychiatry_Person,
                               op.Psychiatry_Attention_Concentration,
                               op.Psychiatry_Days_Week,
                               op.Psychiatry_Immediate_Memory,
                               op.Psychiatry_Recent_Events,
                               op.Psychiatry_Adress_Recall_Two,
                               op.Psychiatry_Remote_Events,
                               op.Psychiatry_Adress_Recall_Five,
                               op.Psychiatry_General_knowledge,
                               op.Psychiatry_Arthemetic_Calculation,
                               op.Psychiatry_Abstraction,
                               op.Psychiatry_Insight,
                               op.Created_Time,
                               op.Psychiatry_HBM_Problem,
                               op.Psychiatry_HBM_Caused,
                               op.Psychiatry_HBM_Started,
                               op.Psychiatry_HBM_Course,
                               op.Psychiatry_HBM_Treatment,
                               op.Psychiatry_HBM_Effects,
                               op.Psychiatry_PE_Pluse,
                               op.Psychiatry_PE_BP,
                               op.Psychiatry_PE_Temperature,
                               op.Psychiatry_PE_Weight,
                               op.Psychiatry_PE_RespiratoryRate,
                               op.Psychiatry_PE_Jaundice,
                               op.Psychiatry_PE_Anemia,
                               op.Psychiatry_PE_Cyanosis,
                               op.Psychiatry_PE_Clubbing,
                               op.Psychiatry_PE_JVP,
                               op.Psychiatry_PE_LymphNodes,
                               op.Psychiatry_PE_Edema,
                               op.Psychiatry_PE_Respiratory,
                               op.Psychiatry_PE_Cardiovascular,
                               op.Psychiatry_PE_Gastro_Intestinal,
                               op.Psychiatry_PE_Observation,
                               op.Psychiatry_PE_Cranial_Nerves,
                               op.Psychiatry_PE_Limb_Strength,
                               op.Psychiatry_PE_Spasticity,
                               op.Psychiatry_PE_Position,
                               op.Psychiatry_PE_Vibration,
                               op.Psychiatry_PE_Stereognosis,
                               op.Psychiatry_PE_Pain,
                               op.Psychiatry_PE_Biceps,
                               op.Psychiatry_PE_Triceps,
                               op.Psychiatry_PE_Brachioradialis,
                               op.Psychiatry_PE_Quadriceps,
                               op.Psychiatry_PE_Patellar,
                               op.Psychiatry_PE_Achilles,
                               op.Psychiatry_PE_Extensor,
                               op.Psychiatry_PE_Frontal,
                               op.Psychiatry_PE_Finger,
                               op.Psychiatry_PE_Heel,
                               op.Psychiatry_PE_Movements,
                               op.Psychiatry_PE_Gait,
                               op.Psychiatry_PE_Neck_Rigidity,
                               op.Psychiatry_PE_Kerning_Sign,
                               op.Psychiatry_PE_Brudzinki_Sign,
                               op.Psychiatry_For_Summary,
                               op.Psychiatry_For_Diagnosis,
                               op.Psychiatry_For_AxisI,
                               op.Psychiatry_For_AxisIII,
                               op.Psychiatry_For_AxisII,
                               op.Psychiatry_For_AxisIV,
                               op.Psychiatry_For_AxisV,
                               op.Psychiatry_For_PredisposingFactors,
                               op.Psychiatry_For_PrecipitatingFactors,
                               op.Psychiatry_For_PrepetuatingFactors,
                               op.Psychiatry_For_Investigation,
                               op.Psychiatry_For_Medical,
                               op.Psychiatry_For_Psychological,
                               op.Psychiatry_Major_Issues,
                               op.Psychiatry_For_Strengths,
                               op.Psychiatry_For_Goals,
                               op.Psychiatry_For_Strategies,

                           }).ToList();
            return ((new JavaScriptSerializer()).Serialize(PatCase));
        }

        [WebMethod]
        public static string checkOPDTrasfer(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatROomsList = (from op in db.Out_Patients

                                      where op.Patient_ID == PatientID && op.Discharge == true && op.Administration != ""
                                      select new
                                      {
                                          op.pulse_Min,
                                          op.Temp_C,
                                          op.BP_mm_Hg,
                                          op.Respiration_Min,
                                          op.Height_Cm,
                                          op.Weight_Kg,
                                          op.Out_Patient_ID,
                                      }).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatROomsList);
            }
            return "";
        }

        [WebMethod]
        public static string checkRepeat(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var checkRepeat = (from rm in db.Ward_Allocations
                                   join op in db.In_Patients
                                   on rm.InPatient_ID equals op.In_Patient_ID.ToString()
                                   where op.Patient_ID == PatientID && op.Discharge_On != null
                                   select op.In_Patient_ID).FirstOrDefault();

                return (new JavaScriptSerializer()).Serialize(checkRepeat);
            }
            return "";
        }

        [WebMethod]
        public static string FillTestMainDepartment()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var dpt = (from d in db.DataValues
                       join v in db.ValueSets
                       on d.ValueSet_ID equals v.ValueSet_ID
                       where v.ValueSet_Name == "Main Test Departments"
                       select new
                       {
                           d.DataValue_Name,
                           d.DataValue_Description
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
        }

        [WebMethod]
        public static string checkRepeatRooms(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatROomsList = (from rm in db.Room_Allocations
                                      join op in db.In_Patients
                                      on rm.In_Patient_ID equals op.In_Patient_ID
                                      where op.Patient_ID == PatientID && op.Discharge_On != null
                                      select new
                                      {
                                          op.In_Patient_ID,
                                      }).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatROomsList);
            }
            return "";
        }

        public class Orthor
        {
            public int outPatientID { get; set; }
            public int Pat { get; set; }
            public List<OrthoDetails> OrthoList { get; set; }
        }
        public class OrthoDetails
        {
            public DateTime Date { get; set; }
            public string Organ_Name { get; set; }
            public string Organ_Side { get; set; }
            public string Ortho_History { get; set; }
            public string DM { get; set; }
            public string HTN { set; get; }
            public string IHD { get; set; }
            public string Look { set; get; }
            public string Feel { set; get; }
            public string Move { get; set; }
            public string Special_Tests { set; get; }
            public string Sensory { set; get; }
            public string Motor { get; set; }
            public string Reflexes { set; get; }
            public string Vascular_Status { set; get; }
            public string Others { set; get; }
        }
        [WebMethod]
        public static string SaveOrthoDetail(string btnsave, string OrthoDetails)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var OrthoDetail = js.Deserialize<Orthor>(OrthoDetails);
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                if (btnsave == "Update")
                {
                    List<Ortho> InPatient_Instruction = db.Orthos.Where(i => i.Transaction_ID == OrthoDetail.outPatientID && i.Patient_Type == "InPatient").ToList();
                    db.Orthos.DeleteAllOnSubmit(InPatient_Instruction);
                    db.SubmitChanges();
                }
                foreach (var test in OrthoDetail.OrthoList)
                {
                    Ortho oInPatient_Ortho = new PMS.Ortho();
                    oInPatient_Ortho.Transaction_ID = OrthoDetail.outPatientID;
                    oInPatient_Ortho.Patient_Type = "InPatient";
                    oInPatient_Ortho.Organ_Name = test.Organ_Name;
                    oInPatient_Ortho.Organ_Side = test.Organ_Side;
                    oInPatient_Ortho.Ortho_History = test.Ortho_History;
                    oInPatient_Ortho.DM = test.DM;
                    oInPatient_Ortho.HTN = test.HTN;
                    oInPatient_Ortho.IHD = test.IHD;
                    oInPatient_Ortho.Look = test.Look;
                    oInPatient_Ortho.Feel = test.Feel;
                    oInPatient_Ortho.Move = test.Move;
                    oInPatient_Ortho.Special_Tests = test.Special_Tests;
                    oInPatient_Ortho.Sensory = test.Sensory;
                    oInPatient_Ortho.Motor = test.Motor;
                    oInPatient_Ortho.Reflexes = test.Reflexes;
                    oInPatient_Ortho.Vascular_Status = test.Vascular_Status;
                    oInPatient_Ortho.Others = test.Others;
                    db.Orthos.InsertOnSubmit(oInPatient_Ortho);
                    db.SubmitChanges();
                }
                db.SubmitChanges();
            }
            catch (Exception ex)
            {

            }
            return "";
        }
        [WebMethod]
        public static string LoadOrthoDetail(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var InPatCase = (from pm in db.Orthos
                                 join op in db.In_Patients
                                 on pm.Transaction_ID equals op.In_Patient_ID
                                 where op.In_Patient_ID == PatientID && pm.Patient_Type == "InPatient"
                                 select new
                                 {
                                     pm.Organ_Name,
                                     pm.Organ_Side,
                                     pm.Ortho_History,
                                     pm.DM,
                                     pm.HTN,
                                     pm.IHD,
                                     pm.Look,
                                     pm.Feel,
                                     pm.Move,
                                     pm.Special_Tests,
                                     pm.Sensory,
                                     pm.Motor,
                                     pm.Reflexes,
                                     pm.Vascular_Status,
                                     pm.Others
                                 }).ToList();

                var OutPatCase = (from pm in db.Orthos
                                  join op in db.Out_Patients
                                  on pm.Transaction_ID equals op.Out_Patient_ID
                                  where op.Out_Patient_ID == PatientID && pm.Patient_Type == "OutPatient"
                                  select new
                                  {
                                      pm.Organ_Name,
                                      pm.Organ_Side,
                                      pm.Ortho_History,
                                      pm.DM,
                                      pm.HTN,
                                      pm.IHD,
                                      pm.Look,
                                      pm.Feel,
                                      pm.Move,
                                      pm.Special_Tests,
                                      pm.Sensory,
                                      pm.Motor,
                                      pm.Reflexes,
                                      pm.Vascular_Status,
                                      pm.Others
                                  }).ToList();
                List<OrthoDetailClass> list = new List<OrthoDetailClass>();

                foreach (var item in InPatCase)
                {
                    OrthoDetailClass obj = new OrthoDetailClass();

                    obj.Organ_Name = item.Organ_Name;
                    obj.Organ_Side = item.Organ_Side;

                    obj.Ortho_History = item.Ortho_History;
                    obj.DM = item.DM;
                    obj.HTN = item.HTN.ToString();
                    obj.Look = item.Look.ToString();

                    obj.Move = item.Move.ToString();
                    obj.Feel = item.Feel.ToString();
                    obj.Special_Tests = item.Special_Tests.ToString();
                    obj.Sensory = item.Sensory.ToString();
                    obj.Motor = item.Motor.ToString();
                    obj.Reflexes = item.Reflexes.ToString();
                    obj.Vascular_Status = item.Vascular_Status.ToString();
                    obj.Status = "InPatient";
                    list.Add(obj);
                }
                foreach (var item in OutPatCase)
                {
                    OrthoDetailClass obj = new OrthoDetailClass();

                    obj.Organ_Name = item.Organ_Name;
                    obj.Organ_Side = item.Organ_Side;

                    obj.Ortho_History = item.Ortho_History;
                    obj.DM = item.DM;
                    obj.HTN = item.HTN.ToString();
                    obj.Look = item.Look.ToString();

                    obj.Move = item.Move.ToString();
                    obj.Feel = item.Feel.ToString();
                    obj.Special_Tests = item.Special_Tests.ToString();
                    obj.Sensory = item.Sensory.ToString();
                    obj.Motor = item.Motor.ToString();
                    obj.Reflexes = item.Reflexes.ToString();
                    obj.Vascular_Status = item.Vascular_Status.ToString();

                    obj.Status = "OutPatient";
                    list.Add(obj);
                }
                return ((new JavaScriptSerializer()).Serialize(list));
            }
        }

        public class OrthoDetailClass
        {

            public string Organ_Name;
            public string Organ_Side;
            public string Ortho_History;
            public string DM;
            public DateTime Medicine_Date;
            public string HTN;
            public string IHD;
            public string Status;
            public string Look;
            public string Move;
            public string Feel;
            public string Special_Tests;
            public DateTime Created_Time;
            public string Sensory;
            public string Motor;
            public string Reflexes;
            public string Vascular_Status;

        }
        [WebMethod]
        public static string LoadENTHistory(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatientID));

            var InPatCase = (from op in db.In_Patients
                             join p in db.Reg_patients
                             on op.Patient_ID equals p.pat_id
                             where p.Patient_No == Patien_No

                             select new
                             {
                                 op.ENT_Throat_IDL,
                                 op.ENT_Throat_Nose,
                                 op.ENT_Ear_Right,
                                 op.Ent_Ear_Left,
                                 op.ENT_Rinnes_Right_PosNeg,
                                 op.ENT_Rinnes_Right_Neg,
                                 op.ENT_Rinnes_Right_FalseNeg,
                                 op.ENT_Rinnes_Right_FNeg,
                                 op.ENT_Rinnes_Lft_PosNeg,
                                 op.ENT_Rinnes_Lft_Neg,
                                 op.ENT_Rinnes_Lft_FalseNeg,
                                 op.ENT_Rinnes_Lft_FNeg,
                                 op.ENT_Webber_Central,
                                 op.ENT_Webber_Lateralized,
                                 op.ENT_Investigation_PTA,
                                 op.ENT_Investigation_Tympanometry,
                                 op.Created_Time
                             }).ToList();
            var OutPatCase = (from op in db.Out_Patients
                              join p in db.Reg_patients
                              on op.Reg_PatId equals p.pat_id
                              where p.Patient_No == Patien_No

                              select new
                              {
                                  op.ENT_Throat_IDL,
                                  op.ENT_Throat_Nose,
                                  op.ENT_Ear_Right,
                                  op.Ent_Ear_Left,
                                  op.ENT_Rinnes_Right_PosNeg,
                                  op.ENT_Rinnes_Right_Neg,
                                  op.ENT_Rinnes_Right_FalseNeg,
                                  op.ENT_Rinnes_Right_FNeg,
                                  op.ENT_Rinnes_Lft_PosNeg,
                                  op.ENT_Rinnes_Lft_Neg,
                                  op.ENT_Rinnes_Lft_FalseNeg,
                                  op.ENT_Rinnes_Lft_FNeg,
                                  op.ENT_Webber_Central,
                                  op.ENT_Webber_Lateralized,
                                  op.ENT_Investigation_PTA,
                                  op.ENT_Investigation_Tympanometry,
                                  op.Created_Time
                              }).ToList();
            List<ENTDetailClass> list = new List<ENTDetailClass>();

            foreach (var item in InPatCase)
            {
                ENTDetailClass obj = new ENTDetailClass();

                obj.ENT_Throat_IDL = item.ENT_Throat_IDL;
                obj.ENT_Throat_Nose = item.ENT_Throat_Nose;
                obj.Created_Time = Convert.ToDateTime(item.Created_Time);
                obj.ENT_Ear_Right = item.ENT_Ear_Right;
                obj.Ent_Ear_Left = item.Ent_Ear_Left;
                obj.ENT_Rinnes_Right_PosNeg = item.ENT_Rinnes_Right_PosNeg.ToString();
                obj.ENT_Rinnes_Right_Neg = item.ENT_Rinnes_Right_Neg.ToString();

                obj.ENT_Rinnes_Right_FalseNeg = item.ENT_Rinnes_Right_FalseNeg.ToString();
                obj.ENT_Rinnes_Right_FNeg = item.ENT_Rinnes_Right_FNeg.ToString();
                obj.ENT_Rinnes_Lft_PosNeg = item.ENT_Rinnes_Lft_PosNeg.ToString();
                obj.ENT_Rinnes_Lft_Neg = item.ENT_Rinnes_Lft_Neg.ToString();
                obj.ENT_Rinnes_Lft_FNeg = item.ENT_Rinnes_Lft_FNeg.ToString();
                obj.ENT_Webber_Central = item.ENT_Webber_Central.ToString();
                obj.ENT_Investigation_PTA = item.ENT_Investigation_PTA.ToString();
                obj.ENT_Investigation_Tympanometry = item.ENT_Investigation_Tympanometry.ToString();
                obj.ENT_Rinnes_Lft_FalseNeg = item.ENT_Rinnes_Lft_FalseNeg.ToString();
                obj.ENT_Webber_Lateralized = item.ENT_Webber_Lateralized.ToString();
                obj.ENT_Rinnes_Lft_FNeg = item.ENT_Rinnes_Lft_FNeg.ToString();
                obj.Status = "InPatient";
                list.Add(obj);
            }
            foreach (var item in OutPatCase)
            {
                ENTDetailClass obj = new ENTDetailClass();

                obj.ENT_Throat_IDL = item.ENT_Throat_IDL;
                obj.ENT_Throat_Nose = item.ENT_Throat_Nose;
                obj.Created_Time = Convert.ToDateTime(item.Created_Time);
                obj.ENT_Ear_Right = item.ENT_Ear_Right;
                obj.Ent_Ear_Left = item.Ent_Ear_Left;
                obj.ENT_Rinnes_Right_PosNeg = item.ENT_Rinnes_Right_PosNeg.ToString();
                obj.ENT_Rinnes_Right_Neg = item.ENT_Rinnes_Right_Neg.ToString();

                obj.ENT_Rinnes_Right_FalseNeg = item.ENT_Rinnes_Right_FalseNeg.ToString();
                obj.ENT_Rinnes_Right_FNeg = item.ENT_Rinnes_Right_FNeg.ToString();
                obj.ENT_Rinnes_Lft_PosNeg = item.ENT_Rinnes_Lft_PosNeg.ToString();
                obj.ENT_Rinnes_Lft_Neg = item.ENT_Rinnes_Lft_Neg.ToString();
                obj.ENT_Rinnes_Lft_FNeg = item.ENT_Rinnes_Lft_FNeg.ToString();
                obj.ENT_Webber_Central = item.ENT_Webber_Central.ToString();
                obj.ENT_Investigation_PTA = item.ENT_Investigation_PTA.ToString();
                obj.ENT_Investigation_Tympanometry = item.ENT_Investigation_Tympanometry.ToString();
                obj.ENT_Rinnes_Lft_FalseNeg = item.ENT_Rinnes_Lft_FalseNeg.ToString();
                obj.ENT_Webber_Lateralized = item.ENT_Webber_Lateralized.ToString();
                obj.ENT_Rinnes_Lft_FNeg = item.ENT_Rinnes_Lft_FNeg.ToString();
                obj.Status = "OutPatient";
                list.Add(obj);
            }
            return ((new JavaScriptSerializer()).Serialize(list));
        }
        public class ENTDetailClass
        {

            public string ENT_Throat_IDL;
            public string ENT_Throat_Nose;
            public string ENT_Ear_Right;
            public string Ent_Ear_Left;
            public DateTime Medicine_Date;
            public string ENT_Rinnes_Right_PosNeg;
            public string ENT_Rinnes_Right_Neg;
            public string Status;
            public string ENT_Rinnes_Right_FalseNeg;
            public string ENT_Rinnes_Right_FNeg;
            public string ENT_Rinnes_Lft_PosNeg;
            public string ENT_Rinnes_Lft_Neg;
            public DateTime Created_Time;
            public string ENT_Rinnes_Lft_FalseNeg;
            public string ENT_Rinnes_Lft_FNeg;
            public string ENT_Webber_Central;
            public string ENT_Webber_Lateralized;
            public string ENT_Investigation_PTA;
            public string ENT_Investigation_Tympanometry;
        }
        public class DermaDetailClass
        {
            public string DermaFace;
            public string DermaNeck;
            public string DermaUpperLimb;
            public string DermaTrunk;
            public DateTime Medicine_Date;
            public string DermaLowerLimb;
            public string DermaFlexures;
            public string Status;
            public string DermaGenitalias;
            public string DermaHair;
            public string DermaNail;
            public string DermaMucousMembrane;
            public DateTime Created_Time;
            public string DermaEyes;
            public string DermaEars;
            public string DermaNose;
            public string DermaLips;
        }

        [WebMethod]
        public static string LoadDermaHistory(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatientID));

            var InPatCase = (from op in db.In_Patients
                             join p in db.Reg_patients
                             on op.Patient_ID equals p.pat_id
                             where p.Patient_No == Patien_No

                             select new
                             {
                                 op.DermaFace,
                                 op.DermaNeck,
                                 op.DermaTrunk,
                                 op.DermaUpperLimb,
                                 op.DermaLowerLimb,
                                 op.DermaFlexures,
                                 op.DermaGenitalias,
                                 op.DermaHair,
                                 op.DermaNail,
                                 op.DermaMucousMembrane,
                                 op.DermaEyes,
                                 op.DermaEars,
                                 op.DermaNose,
                                 op.DermaLips,
                                 op.Created_Time
                             }).ToList();


            var OutPatCase = (from op in db.Out_Patients
                              join p in db.Reg_patients
                              on op.Reg_PatId equals p.pat_id
                              where p.Patient_No == Patien_No

                              select new
                              {
                                  op.DermaFace,
                                  op.DermaNeck,
                                  op.DermaTrunk,
                                  op.DermaUpperLimb,
                                  op.DermaLowerLimb,
                                  op.DermaFlexures,
                                  op.DermaGenitalias,
                                  op.DermaHair,
                                  op.DermaNail,
                                  op.DermaMucousMembrane,
                                  op.DermaEyes,
                                  op.DermaEars,
                                  op.DermaNose,
                                  op.DermaLips,
                                  op.Created_Time
                              }).ToList();
            List<DermaDetailClass> list = new List<DermaDetailClass>();

            foreach (var item in InPatCase)
            {
                DermaDetailClass obj = new DermaDetailClass();

                obj.DermaFace = item.DermaFace;
                obj.DermaNeck = item.DermaNeck;

                obj.DermaTrunk = item.DermaTrunk;
                obj.DermaUpperLimb = item.DermaUpperLimb;
                obj.DermaLowerLimb = item.DermaLowerLimb.ToString();
                obj.DermaFlexures = item.DermaFlexures.ToString();

                obj.DermaGenitalias = item.DermaGenitalias.ToString();
                obj.DermaHair = item.DermaHair.ToString();
                obj.DermaNail = item.DermaNail.ToString();
                obj.DermaMucousMembrane = item.DermaMucousMembrane.ToString();
                obj.DermaEyes = item.DermaEyes.ToString();
                obj.DermaEars = item.DermaEars.ToString();
                obj.DermaNose = item.DermaNose.ToString();
                obj.Created_Time = Convert.ToDateTime(item.Created_Time);

                obj.DermaLips = item.DermaLips.ToString();
                obj.Status = "InPatient";
                list.Add(obj);
            }
            foreach (var item in OutPatCase)
            {
                DermaDetailClass obj = new DermaDetailClass();
                obj.DermaFace = item.DermaFace;
                obj.DermaNeck = item.DermaNeck;
                obj.DermaTrunk = item.DermaTrunk;
                obj.DermaUpperLimb = item.DermaUpperLimb;
                obj.DermaLowerLimb = item.DermaLowerLimb.ToString();
                obj.DermaFlexures = item.DermaFlexures.ToString();
                obj.DermaGenitalias = item.DermaGenitalias.ToString();
                obj.DermaHair = item.DermaHair.ToString();
                obj.DermaNail = item.DermaNail.ToString();
                obj.DermaMucousMembrane = item.DermaMucousMembrane.ToString();
                obj.DermaEyes = item.DermaEyes.ToString();
                obj.DermaEars = item.DermaEars.ToString();
                obj.DermaNose = item.DermaNose.ToString();
                obj.DermaLips = item.DermaLips.ToString();
                obj.Created_Time = Convert.ToDateTime(item.Created_Time);
                obj.Status = "OutPatient";
                list.Add(obj);
            }
            return ((new JavaScriptSerializer()).Serialize(list));
        }

        [WebMethod]
        public static string LoadRoomsForHistory(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                int Patien_No = DBClass.GetMRNOBy_PatientID(Convert.ToInt32(PatientID));

                var inPatROomsList = (from rm in db.Room_Allocations
                                      join op in db.In_Patients
                                       on rm.In_Patient_ID equals op.In_Patient_ID
                                      join p in db.Reg_patients
                                     on op.Patient_ID equals p.pat_id
                                      where p.pat_id == PatientID
                                      select new
                                      {
                                          op.Admission_Date,
                                          op.Department,
                                          DepartmentName = db.GetDataValueName("Patient Main Category", op.Department),
                                          op.Doctor,
                                          DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(op.Doctor) select d.Emp_Name).FirstOrDefault(),
                                          op.Health_Complaints,
                                          op.Expected_Discharge_Date,
                                          rm.To_Date,
                                          rm.From_Date,
                                          rm.Room_ID,
                                          RoomNo = (from r in db.Rooms where rm.Room_ID == r.Room_ID select r.Room_No).FirstOrDefault(),
                                          Room_Type = (from r in db.Rooms where rm.Room_ID == r.Room_ID select r.Room_Type).FirstOrDefault(),
                                          RoomType = db.GetDataValueName("Room Type", rm.Room_Type),
                                      }).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatROomsList);
            }
            return "";
        }
        [WebMethod]
        public static string FillDays_Years_MonthsDropDown()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Routes = from d in db.DataValues
                         join v in db.ValueSets
                         on d.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Name == "Days_Years_Months"
                         select new
                         {
                             d.DataValue_Name,
                             d.DataValue_Description
                         };
            return (new JavaScriptSerializer().Serialize(Routes));
        }
        [WebMethod]
        public static string loadReferenceInformation(string PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var result = (from data in db.In_Patients
                          where data.Patient_ID == Convert.ToInt32(PatientID)
                          select new
                          {
                              data.Ward_ID,
                              Room_No = DBClass.getField("select isnull(Room_No,'0') from Rooms where room_id=" + data.Room_ID),
                              Description = DBClass.getField("select isnull(ward_no,'0') from Ward_Definition where ward_id=" + data.Ward_ID),
                              data.packagae_type,
                              data.packagae_name,
                              data.Room_ID,

                              data.Bed_No,
                              Room_Type = db.GetDataValueName("Room Type", data.Room_Type.ToString()),
                              Reffer_To = db.GetDataValueName("Patient Main Category", data.Department.ToString()),

                          }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(result);
        }
        [WebMethod]
        public static string LoadWardForHistory(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatientID));

                var inPatROomsList = (from rm in db.Ward_Allocations
                                      join op in db.In_Patients
                                      on rm.InPatient_ID equals op.In_Patient_ID.ToString()
                                      join p in db.Reg_patients
                                     on op.Patient_ID equals p.pat_id
                                      where p.pat_id == PatientID
                                      select new
                                      {
                                          op.Admission_Date,
                                          op.Department,
                                          DepartmentName = db.GetDataValueName("Patient Main Category", op.Department),
                                          op.Doctor,
                                          DoctorName = (from d in db.HR_Employees
                                                        where d.Emp_ID == Convert.ToInt32(op.Doctor)
                                                        select
                                                            d.Emp_Name).FirstOrDefault(),
                                          op.Health_Complaints,
                                          op.Expected_Discharge_Date,
                                          rm.Ward_ID,
                                          Ward_No = (from d in db.Ward_Definitions where d.Ward_ID == Convert.ToInt32(rm.Ward_ID) select d.Ward_No).FirstOrDefault(),
                                          rm.Bed_No_Assigned,
                                          rm.To_TimeDate,
                                          rm.From_TimeDate,
                                          op.Discharge_On
                                      }).ToList();
                string s = (new JavaScriptSerializer()).Serialize(inPatROomsList);
                return s;
            }
            return "";
        }
        protected void btnAllocatedRoomWardChkTriggerBtn_Click(object sender, EventArgs e)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var countOfRoomRows = db.Room_Allocatrion_Histories.Where(m => m.Patient_ID == Convert.ToInt32(txtPatient_ID.Text)).Count();
            var countOfWardRows = db.Ward_Allocatrion_Histories.Where(m => m.Patient_ID == Convert.ToInt32(txtPatient_ID.Text)).Count();
            if (countOfRoomRows > 0 || countOfWardRows > 0)
            {
                if (countOfRoomRows > 0)
                {
                    var lastRowRoom = db.Room_Allocatrion_Histories.Where(m => m.Patient_ID == Convert.ToInt32(txtPatient_ID.Text)).Skip(countOfRoomRows - 1).FirstOrDefault();
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

                    }
                }
                else
                {

                }
                if (countOfWardRows > 0)
                {
                    var lastRowWard = db.Ward_Allocatrion_Histories.Where(m => m.Patient_ID == Convert.ToInt32(txtPatient_ID.Text)).Skip(countOfWardRows - 1).FirstOrDefault();
                    if (lastRowWard != null)
                    {

                    }
                }
                else
                {

                }
            }
            else
            {

            }
        }
        protected void btnAllocatedRoomwardCheckRefer_Click(object sender, EventArgs e)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var countOfRoomRows = db.Room_Allocatrion_Histories.Where(m => m.Patient_ID == Convert.ToInt32(txtPatient_ID.Text)).Count();
            var countOfWardRows = db.Ward_Allocatrion_Histories.Where(m => m.Patient_ID == Convert.ToInt32(txtPatient_ID.Text)).Count();
            if (countOfRoomRows > 0 || countOfWardRows > 0)
            {
                if (countOfRoomRows > 0)
                {
                    var lastRowRoom = db.Room_Allocatrion_Histories.Where(m => m.Patient_ID == Convert.ToInt32(txtPatient_ID.Text)).Skip(countOfRoomRows - 1).FirstOrDefault();
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

                    }
                }
                else
                {

                }
                if (countOfWardRows > 0)
                {
                    var lastRowWard = db.Ward_Allocatrion_Histories.Where(m => m.Patient_ID == Convert.ToInt32(txtPatient_ID.Text)).Skip(countOfWardRows - 1).FirstOrDefault();
                    if (lastRowWard != null)
                    {

                    }
                }
                else
                {

                }
            }
            else
            {

            }
        }
        public void PrintReport(int PatientID)
        {
            string reportPath = Server.MapPath("~/Reports/");
            ReportDocument rd = new ReportDocument();
            reportPath += "rptPatientBillingReceipt.rpt";
            rd.Load(reportPath);
            rd.SetParameterValue("@Patient_ID", Convert.ToInt32(PatientID));
            SqlConnectionStringBuilder SSB = new SqlConnectionStringBuilder(ConfigurationManager.ConnectionStrings["ASPGLConnectionString"].ConnectionString);
            string UserID = SSB.UserID;
            string Password = SSB.Password;
            string DBName = SSB.InitialCatalog;
            string ServerName = SSB.DataSource;
            rd.SetDatabaseLogon(UserID, Password, ServerName, DBName);
            TableLogOnInfo logOnInfo = new TableLogOnInfo();
            logOnInfo = rd.Database.Tables[0].LogOnInfo;
            ConnectionInfo connectionInfo = new ConnectionInfo();
            connectionInfo = rd.Database.Tables[0].LogOnInfo.ConnectionInfo;
            connectionInfo.DatabaseName = DBName;
            connectionInfo.ServerName = ServerName;
            connectionInfo.Password = Password;
            connectionInfo.UserID = UserID;
            rd.Database.Tables[0].ApplyLogOnInfo(logOnInfo);
        }

        [WebMethod]
        public static string FillMedicineDropDown()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Routes = (from d in db.DataValues
                          join v in db.ValueSets
                          on d.ValueSet_ID equals v.ValueSet_ID
                          where v.ValueSet_Name == "Medicine"
                          select new
                          {
                              d.DataValue_Name,
                              d.DataValue_Description
                          }).ToList();

            return (new JavaScriptSerializer().Serialize(Routes));
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
        public static string GeMedicineNew(string medicine)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                DataValue data = new DataValue();
                data.ValueSet_ID = 83;
                var sQuery =
                              (from staff in db.DataValues
                               orderby staff.DataValue_Name ascending
                               select staff.DataValue_Name).Distinct().ToList();
                int counter = sQuery.Count;
                int snumber = counter + 1;
                data.DataValue_Name = Convert.ToInt32(snumber).ToString();
                data.DataValue_Description = medicine;
                db.DataValues.InsertOnSubmit(data);
                db.SubmitChanges();
            }
            return "";
        }
        public class Medicine
        {
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
        public class DoctotNote
        {
            public int InPatientID { get; set; }
            public int Pat { get; set; }
            public List<DoctotNoteDetails> NoteList { get; set; }
        }
        public class LabResultrpt
        {
            public int InPatientID { get; set; }
            public int Pat { get; set; }
            public List<LabResultrptDetaild> Resulttrpt { get; set; }
        }
        public class DoctotNoteDetails
        {
            public DateTime Doctor_Note_Date { get; set; }
            public string Doctor_Status { get; set; }
            public string Doctor_ID { get; set; }
            public string Progress_Note { get; set; }
            public string Instruction { get; set; }

        }
        public class LabResultrptDetaild
        {
            public DateTime Result_Date { get; set; }
            public string Result_ID { get; set; }
            public string Result_Name { get; set; }
        }

        [WebMethod]
        public static string InsertDoctorNoteDetail(string btnsave, string NoteDetails)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var DoctorDetail = js.Deserialize<DoctotNote>(NoteDetails);
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                /********************Deleting Previous 0 Value Saved Rows.***********************************/
                if (btnsave == "Update")
                {
                    List<InPatient_Doctor_Note> InPatient_Doctor_Note = db.InPatient_Doctor_Notes.Where(i => i.In_Patient_ID == DoctorDetail.InPatientID).ToList();
                    db.InPatient_Doctor_Notes.DeleteAllOnSubmit(InPatient_Doctor_Note);
                    db.SubmitChanges();
                }
                foreach (var test in DoctorDetail.NoteList)
                {
                    InPatient_Doctor_Note oInPatient_Doctor_Note = new PMS.InPatient_Doctor_Note();
                    oInPatient_Doctor_Note.In_Patient_ID = DoctorDetail.InPatientID;
                    oInPatient_Doctor_Note.Patient_ID = DoctorDetail.Pat;
                    oInPatient_Doctor_Note.Doctor_Status = test.Doctor_Status;
                    oInPatient_Doctor_Note.Doctor_ID = test.Doctor_ID;
                    oInPatient_Doctor_Note.Progress_Note = test.Progress_Note;
                    oInPatient_Doctor_Note.Doctor_Instruction = test.Instruction;
                    oInPatient_Doctor_Note.Doctor_Note_Date = test.Doctor_Note_Date;
                    db.InPatient_Doctor_Notes.InsertOnSubmit(oInPatient_Doctor_Note);
                    db.SubmitChanges();
                }
            }
            catch (Exception ex)
            {

            }
            return "";
        }
        [WebMethod]
        public static string SaveLabResultrpt(string btnsave, string ResulttrptDetail)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var LabResulttrptDetail = js.Deserialize<LabResultrpt>(ResulttrptDetail);
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                /********************Deleting Previous 0 Value Saved Rows.***********************************/
                if (btnsave == "Update")
                {
                    List<Lab_Resultrpt> InPatient_Lab_Resultrpt = db.Lab_Resultrpts.Where(i => i.Lab_Result_ID == LabResulttrptDetail.InPatientID).ToList();
                    db.Lab_Resultrpts.DeleteAllOnSubmit(InPatient_Lab_Resultrpt);
                    db.SubmitChanges();
                }
                foreach (var test in LabResulttrptDetail.Resulttrpt)
                {
                    Lab_Resultrpt oInPatient_Lab_Resultrpt = new PMS.Lab_Resultrpt();
                    oInPatient_Lab_Resultrpt.In_Patient_ID = LabResulttrptDetail.InPatientID;
                    oInPatient_Lab_Resultrpt.Patient_ID = LabResulttrptDetail.Pat;
                    oInPatient_Lab_Resultrpt.Lab_Resultrpt_ID = test.Result_ID.ToString();
                    oInPatient_Lab_Resultrpt.Date = DateTime.Now;
                    oInPatient_Lab_Resultrpt.Lab_Resultrpt_Name = test.Result_Name;
                    db.Lab_Resultrpts.InsertOnSubmit(oInPatient_Lab_Resultrpt);
                    db.SubmitChanges();
                }
            }
            catch (Exception ex)
            {

            }
            return "";
        }
        public class InstructionNote
        {
            public int InPatientID { get; set; }
            public int Pat { get; set; }
            public List<InstructionNoteeDetails> ListIns { get; set; }
        }
        public class InstructionNoteeDetails
        {
            public DateTime Instruction_Date { get; set; }
            public string Doctor_Status { get; set; }
            public string Doctor_ID { get; set; }
            public string Doctor_Instruction { get; set; }
            public string ChekInstruction { get; set; }
        }
        [WebMethod]
        public static string InsertInstuctionDetail(string btnsave, string IntructionDetails)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var InsDetail = js.Deserialize<InstructionNote>(IntructionDetails);
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                /********************Deleting Previous 0 Value Saved Rows.***********************************/
                if (btnsave == "Update")
                {
                    List<InPatient_Instruction> InPatient_Instruction = db.InPatient_Instructions.Where(i => i.In_Patient_ID == InsDetail.InPatientID).ToList();
                    db.InPatient_Instructions.DeleteAllOnSubmit(InPatient_Instruction);
                    db.SubmitChanges();
                }
                foreach (var test in InsDetail.ListIns)
                {
                    InPatient_Instruction oInPatient_Doctor_Note = new PMS.InPatient_Instruction();
                    oInPatient_Doctor_Note.In_Patient_ID = InsDetail.InPatientID;
                    oInPatient_Doctor_Note.Patient_ID = InsDetail.Pat;
                    oInPatient_Doctor_Note.Doctor_Status = test.Doctor_Status;
                    oInPatient_Doctor_Note.Doctor_ID = test.Doctor_ID;
                    oInPatient_Doctor_Note.Doctor_Instruction = test.Doctor_Instruction;
                    oInPatient_Doctor_Note.Instruction_Date = test.Instruction_Date;
                    oInPatient_Doctor_Note.IsLatest = Convert.ToBoolean(test.ChekInstruction);
                    db.InPatient_Instructions.InsertOnSubmit(oInPatient_Doctor_Note);
                    db.SubmitChanges();
                }
            }
            catch (Exception ex)
            {

            }
            return "";
        }
        public class EyeDetail
        {
            public string EyeMainTypeID { get; set; }
            public string EyeSubTypeID { get; set; }
            public string RightEye { get; set; }
            public string LeftEye { get; set; }
        }
        public class EyeHeader
        {
            public string TransactionID { get; set; }
            public List<EyeDetail> EyeDetails { get; set; }
        }
        [WebMethod]
        public static string SaveEyeList(string data)
        {
            JavaScriptSerializer js = new JavaScriptSerializer();
            var Details = js.Deserialize<EyeHeader>(data);
            DataBaseDataContext db = new DataBaseDataContext();
            var PreviousEyeDetails = db.EyeDetails.Where(t => t.TransactionID == Convert.ToInt32(Details.TransactionID) && t.TransactionType == "InPatient").ToList();
            db.EyeDetails.DeleteAllOnSubmit(PreviousEyeDetails);
            db.SubmitChanges();
            // Insert New
            foreach (EyeDetail eye in Details.EyeDetails)
            {
                db.EyeDetails.InsertOnSubmit(new PMS.EyeDetail() { TransactionID = Convert.ToInt32(Details.TransactionID), EyeMainTypeID = eye.EyeMainTypeID, EyeSubTypeID = eye.EyeSubTypeID, RightEye = eye.RightEye, LeftEye = eye.LeftEye, TransactionType = "InPatient" });
            }
            db.SubmitChanges();
            return "";
        }
        [WebMethod]
        public static string GetEyeList(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var EyeList = (from e in db.EyeDetails
                           where e.TransactionType == "InPatient" && e.TransactionID == id
                           select new
                           {
                               EyeMainTypeName = (from em in db.EyeMainTypes_Definitions
                                                  where em.MainTypeID == Convert.ToInt32(e.EyeMainTypeID)
                                                  select em.MainTypeName),
                               EyeSubTypeName = (from es in db.EyeSubTypes_Definitions
                                                 where es.SubTypeID == Convert.ToInt32(e.EyeSubTypeID)
                                                 select es.SubTypeName),
                               e.EyeMainTypeID,
                               e.EyeSubTypeID,
                               e.RightEye,
                               e.LeftEye
                           }
                );
            return (new JavaScriptSerializer()).Serialize(EyeList);
        }
        [WebMethod]
        public static string GetEyeSubType(int MainTypeID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var dep = from Eye in db.EyeSubTypes_Definitions
                      where Eye.MainTypeID == MainTypeID
                      select new { DataValue_Name = Eye.SubTypeID, DataValue_Description = Eye.SubTypeName, Eye.MainTypeID };
            return (new JavaScriptSerializer()).Serialize(dep);
        }
        [WebMethod]
        public static string GetEyeMainType()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dep = from Eye in db.EyeMainTypes_Definitions
                      select new { DataValue_Name = Eye.MainTypeID, DataValue_Description = Eye.MainTypeName };
            return (new JavaScriptSerializer()).Serialize(dep);
        }
        [WebMethod]
        public static string GetEyeListHistory(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatientID));

            var InPatEyeList = (from e in db.EyeDetails
                                join o in db.In_Patients
                                on e.TransactionID equals o.In_Patient_ID
                                join p in db.Reg_patients
                               on o.Patient_ID equals p.pat_id
                                where p.Patient_No == Patien_No && e.TransactionType == "InPatient"
                                select new
                                {
                                    EyeMainTypeName = (from em in db.EyeMainTypes_Definitions
                                                       where em.MainTypeID == Convert.ToInt32(e.EyeMainTypeID)
                                                       select em.MainTypeName).FirstOrDefault(),
                                    EyeSubTypeName = (from es in db.EyeSubTypes_Definitions
                                                      where es.SubTypeID == Convert.ToInt32(e.EyeSubTypeID)
                                                      select es.SubTypeName).FirstOrDefault(),
                                    e.EyeMainTypeID,
                                    e.EyeSubTypeID,
                                    e.RightEye,
                                    e.LeftEye
                                }
                ).ToList();
            var OutPatEyeList = (from e in db.EyeDetails
                                 join o in db.Out_Patients
                                 on e.TransactionID equals o.Out_Patient_ID
                                 join p in db.Reg_patients
                                on o.Reg_PatId equals p.pat_id
                                 where p.Patient_No == Patien_No && e.TransactionType == "OutPatient"
                                 select new
                                 {
                                     EyeMainTypeName = (from em in db.EyeMainTypes_Definitions
                                                        where em.MainTypeID == Convert.ToInt32(e.EyeMainTypeID)
                                                        select em.MainTypeName).FirstOrDefault(),
                                     EyeSubTypeName = (from es in db.EyeSubTypes_Definitions
                                                       where es.SubTypeID == Convert.ToInt32(e.EyeSubTypeID)
                                                       select es.SubTypeName).FirstOrDefault(),
                                     e.EyeMainTypeID,
                                     e.EyeSubTypeID,
                                     e.RightEye,
                                     e.LeftEye
                                 }
               ).ToList();

            List<EyeDetailClass> list = new List<EyeDetailClass>();
            foreach (var item in InPatEyeList)
            {
                EyeDetailClass obj = new EyeDetailClass();

                obj.EyeMainTypeName = item.EyeMainTypeName.ToString();
                obj.EyeSubTypeName = item.EyeSubTypeName.ToString();

                obj.EyeMainTypeID = item.EyeMainTypeID;
                obj.EyeSubTypeID = item.EyeSubTypeID;
                obj.LeftEye = item.LeftEye;
                obj.RightEye = item.RightEye;
                obj.Status = "InPatient";
                list.Add(obj);
            }
            foreach (var item in OutPatEyeList)
            {
                EyeDetailClass obj = new EyeDetailClass();
                obj.EyeMainTypeName = item.EyeMainTypeName.ToString();
                obj.EyeSubTypeName = item.EyeSubTypeName.ToString();

                obj.EyeMainTypeID = item.EyeMainTypeID;
                obj.EyeSubTypeID = item.EyeSubTypeID;
                obj.LeftEye = item.LeftEye;
                obj.RightEye = item.RightEye;
                obj.Status = "OutPatient";
                list.Add(obj);
            }
            return (new JavaScriptSerializer()).Serialize(list);
        }
        public class EyeDetailClass
        {
            public string EyeMainTypeName;
            public string EyeSubTypeName;
            public string EyeMainTypeID;
            public string EyeSubTypeID;
            public DateTime Medicine_Date;
            public string LeftEye;
            public string RightEye;
            public string Status;
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
                    List<In_Patient_Medicine> In_Patient_MedicineList = db.In_Patient_Medicines.Where(i => i.Patient_ID == 0 && i.Transaction_Type == "InPatient Discharge Medicine" && i.chkDiccharge == true).ToList();
                    db.In_Patient_Medicines.DeleteAllOnSubmit(In_Patient_MedicineList);
                    db.SubmitChanges();
                    int couterNewRecords = 0;
                    if (MedicineDetail.PatientID != 0)
                    {
                        /*********************Deleting Previous Entry On Every Insert Or Update*************************/
                        List<In_Patient_Medicine> inPatmedicineList = db.In_Patient_Medicines.Where(p => p.Patient_ID == MedicineDetail.PatientID && p.Transaction_Type == "InPatient Discharge Medicine" && p.chkDiccharge == true).ToList();
                        if (inPatmedicineList != null)
                        {
                            db.In_Patient_Medicines.DeleteAllOnSubmit(inPatmedicineList);
                            couterNewRecords++;
                        }
                    }
                    couterNewRecords = 0;
                    /*********************Inserting New Entry On Every Insert Or Update*************************/
                    foreach (MedicineDetails oIn_Patient_DMedicine in MedicineDetail.MedicineList)
                    {
                        In_Patient_Medicine oIn_Patient_DMedicine1 = new In_Patient_Medicine()
                        {

                            Patient_ID = Convert.ToInt32(MedicineDetail.PatientID),
                            Item_Code = oIn_Patient_DMedicine.ItemCode,
                            Medicine_Name = oIn_Patient_DMedicine.Medicine_Name,
                            Transaction_Type = "InPatient Discharge Medicine",
                            Medicine_Date = oIn_Patient_DMedicine.Medicine_Date,
                            Oral = oIn_Patient_DMedicine.Oral,
                            Injections = oIn_Patient_DMedicine.Injection,

                            Dosage_From = oIn_Patient_DMedicine.Dosage_From,
                            AttendingParamedical_Staff = oIn_Patient_DMedicine.AttendingParamedical_Staff,
                            Frequency = oIn_Patient_DMedicine.Frequency,
                            Dosage_Qty = oIn_Patient_DMedicine.Dosage_Qty,
                            Other_Instruction = oIn_Patient_DMedicine.Other_Instruction
                        };
                        db.In_Patient_Medicines.InsertOnSubmit(oIn_Patient_DMedicine1);
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
        public static string SaveMedicines(string MedicineDetails)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var MedicineDetail = js.Deserialize<Medicine>(MedicineDetails);
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    /********************Deleting Previous 0 Value Saved Rows.***********************************/
                    List<In_Patient_Medicine> In_Patient_MedicineList = db.In_Patient_Medicines.Where(i => i.Patient_ID == 0 && i.Transaction_Type == "InPatient" && i.chkDiccharge == false).ToList();
                    db.In_Patient_Medicines.DeleteAllOnSubmit(In_Patient_MedicineList);
                    db.SubmitChanges();
                    int couterNewRecords = 0;
                    if (MedicineDetail.PatientID != 0)
                    {
                        /*********************Deleting Previous Entry On Every Insert Or Update*************************/
                        List<In_Patient_Medicine> inPatmedicineList = db.In_Patient_Medicines.Where(p => p.Patient_ID == MedicineDetail.PatientID && p.Transaction_Type == "InPatient" && (p.chkDiccharge == false || p.chkDiccharge == null)).ToList();
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
                            Transaction_Type = "InPatient",
                            Medicine_Date = oIn_Patient_Medicine.Medicine_Date,
                            Oral = oIn_Patient_Medicine.Oral,
                            Injections = oIn_Patient_Medicine.Injection,
                            // Recomended_Dosage = oIn_Patient_Medicine.Recomended_Dosage,
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
        public static string LoadMedicines(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatmedicine = (from inPatmedicineList in db.In_Patient_Medicines
                                     where inPatmedicineList.Patient_ID == PatientID && inPatmedicineList.Transaction_Type == "InPatient"

                                     select new
                                     {
                                         inPatmedicineList.Doctor_ID,
                                         inPatmedicineList.Frequency,
                                         inPatmedicineList.Injections,
                                         inPatmedicineList.Medicine_Name,
                                         inPatmedicineList.Medicine_Date,
                                         inPatmedicineList.Patient_ID,
                                         inPatmedicineList.In_Patient_Medicine_ID,
                                         inPatmedicineList.Recomended_Dosage,
                                         inPatmedicineList.Oral,
                                         inPatmedicineList.AttendingParamedical_Staff,
                                         inPatmedicineList.chkDiccharge,
                                         inPatmedicineList.Dosage_From,
                                         inPatmedicineList.Dosage_Qty,
                                         inPatmedicineList.Other_Instruction,
                                         DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(inPatmedicineList.Doctor_ID) select d.Emp_Name).FirstOrDefault(),
                                     }
                    ).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatmedicine);
            }
        }
        [WebMethod]
        public static string LoadDischargeMedicines(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatmedicine = (from inPatmedicineList in db.In_Patient_Medicines
                                     where inPatmedicineList.Patient_ID == PatientID && inPatmedicineList.Transaction_Type == "InPatient Discharge Medicine"

                                     select new
                                     {
                                         inPatmedicineList.Doctor_ID,
                                         inPatmedicineList.Frequency,
                                         inPatmedicineList.Injections,
                                         inPatmedicineList.Medicine_Name,
                                         inPatmedicineList.Medicine_Date,
                                         inPatmedicineList.Patient_ID,
                                         inPatmedicineList.In_Patient_Medicine_ID,
                                         inPatmedicineList.Recomended_Dosage,
                                         inPatmedicineList.Oral,
                                         inPatmedicineList.AttendingParamedical_Staff,
                                         inPatmedicineList.chkDiccharge,
                                         inPatmedicineList.Dosage_From,
                                         inPatmedicineList.Dosage_Qty,
                                         inPatmedicineList.Other_Instruction,
                                         DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(inPatmedicineList.Doctor_ID) select d.Emp_Name).FirstOrDefault(),
                                     }
                    ).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatmedicine);
            }
        }
        [WebMethod]
        public static string LoadDischageMedicines(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatmedicine = (from inPatmedicineList in db.In_Patient_Medicines
                                     where inPatmedicineList.Patient_ID == PatientID && inPatmedicineList.Transaction_Type == "InPatient" && inPatmedicineList.chkDiccharge == true
                                     select new
                                     {
                                         inPatmedicineList.Doctor_ID,
                                         inPatmedicineList.Frequency,
                                         inPatmedicineList.Injections,
                                         inPatmedicineList.Medicine_Name,
                                         inPatmedicineList.Medicine_Date,
                                         inPatmedicineList.Patient_ID,
                                         inPatmedicineList.In_Patient_Medicine_ID,
                                         inPatmedicineList.Recomended_Dosage,
                                         inPatmedicineList.Oral,
                                         inPatmedicineList.AttendingParamedical_Staff,
                                         inPatmedicineList.chkDiccharge,
                                         DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(inPatmedicineList.Doctor_ID) select d.Emp_Name).FirstOrDefault(),

                                     }
                    ).ToList();

                return (new JavaScriptSerializer()).Serialize(inPatmedicine);
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
        public class Rooms
        {
            public int WardID { get; set; }
            public int PatientNo { get; set; }
            public int BedNo { get; set; }
        }
        [WebMethod]
        public static string FillRooms(string RoomType)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var Rmdetail = (from rm in db.Rooms
                            where rm.Room_Type == RoomType
                            select new
                            {
                                rm.Room_No,
                                rm.Room_ID,
                                rm.Name,
                                rm.Room_Type,
                                PatientNmae = ((from room in db.Room_Allocations join p in db.Reg_patients on room.Patient_ID equals p.pat_id where room.Room_ID == rm.Room_ID && room.IsDischarge == false select p.Patient_No).FirstOrDefault()),
                            }
               ).ToList();
            return (new JavaScriptSerializer()).Serialize(Rmdetail);
        }

        [WebMethod]
        public static string SaveRoomInformation(string btnsave, int PatID, int InPatID, string ddlRoom_No, string txtRoom_Type, string txtExpected_Discharge_On_Date, string ddlDoctor, bool DischargeChk, string txtAdvice, string txtProcedure_Operation, string txtProcedure_Detail, string txtDignosis, string txtNext_Visit,string DischargeType)
        {
            string InPatientStatus = string.Empty;
            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                Room_Allocation room_aloct;
                In_Patient in_Patient = new In_Patient();

                in_Patient = (from tbl in db.In_Patients
                              where tbl.Patient_ID == Convert.ToInt32(PatID)
                              && tbl.In_Patient_ID == Convert.ToInt32(InPatID)
                              select tbl).FirstOrDefault();

                if (DischargeChk == false)
                {
                    if (in_Patient.Discharge == true && in_Patient.Discharge_On != null)
                    {
                        in_Patient.Discharge = false;
                        in_Patient.Discharge_On = null;
                        in_Patient.Discharge_Type = null;
                        db.SubmitChanges();
                        return InPatientStatus = "Patient is undischarged Successfully !," + InPatID;

                    }
                }

                room_aloct = (from tbl in db.Room_Allocations
                              where tbl.Room_Type == txtRoom_Type
                               && tbl.In_Patient_ID == InPatID && tbl.Patient_ID == Convert.ToInt32(PatID)
                               && tbl.Room_ID == Convert.ToInt32(ddlRoom_No) && tbl.IsDischarge == false
                              select tbl).FirstOrDefault();

                if (DischargeChk == true && room_aloct == null && in_Patient.Discharge == false && in_Patient.Discharge_On == null)
                {
                    in_Patient.Discharge = true;
                    in_Patient.Discharge_On = Convert.ToDateTime(txtExpected_Discharge_On_Date.ToString());
                    in_Patient.Discharge_By = ddlDoctor;
                    in_Patient.Prevention_Precaution = txtAdvice;
                    in_Patient.Procedure_Operation = txtProcedure_Operation;
                    in_Patient.Procedure_Detail = txtProcedure_Detail;
                    in_Patient.Discharge_Type = DischargeType;
                    if (!string.IsNullOrEmpty(txtNext_Visit))
                        in_Patient.Next_Visit = Convert.ToDateTime(txtNext_Visit);
                    in_Patient.Diagonosis = txtDignosis;
                    db.SubmitChanges();
                    InPatientStatus = "Patient is Discharged Successfully !," + InPatID;
                    DBClass.executeNonQueryWithoutBegin("update Discount_Assigned_Patient set IsDischarge=1 where Patient_Id=" + PatID);
                }



                if (room_aloct != null)
                {
                    in_Patient.Discharge_On = Convert.ToDateTime(txtExpected_Discharge_On_Date.ToString());
                    in_Patient.Discharge = true;
                    in_Patient.Discharge_By = ddlDoctor;
                    InPatientStatus = "Patient is Discharged Successfully !," + InPatID;
                    DBClass.executeNonQueryWithoutBegin("update Discount_Assigned_Patient set IsDischarge=1 where Patient_Id=" + PatID);
                    in_Patient.Prevention_Precaution = txtAdvice;
                    in_Patient.Procedure_Operation = txtProcedure_Operation;
                    in_Patient.Procedure_Detail = txtProcedure_Detail;
                    if (!string.IsNullOrEmpty(txtNext_Visit))
                        in_Patient.Next_Visit = Convert.ToDateTime(txtNext_Visit);
                    in_Patient.Diagonosis = txtDignosis;

                    room_aloct.Updated_By = AppConfig.UserID;
                    room_aloct.Updated_Time = DateTime.Now;

                    room_aloct.In_Patient_ID = InPatID;
                    room_aloct.Patient_ID = Convert.ToInt32(PatID);
                    room_aloct.Room_ID = Convert.ToInt32(ddlRoom_No);

                    room_aloct.Room_Type = txtRoom_Type;

                    if (DischargeChk == true)
                    {
                        room_aloct.IsDischarge = true;
                        // SMS Configration
                        string SMS_Contant = "عارف میموریل ٹیچنگ ہسپتال کی سہولیات پر اعتمادکرنےکاشکریہ ہماری سہولیات کی بہتری کے لیےآپ نیچےدیئے گے نمبرپر رابطہ کریں۔ 03138458018";
                        string msg = "";

                        string CellNumber = (from tbl in db.Reg_patients
                                             where tbl.pat_id == Convert.ToInt32(PatID)
                                             select tbl.Mobile1).FirstOrDefault();

                    }
                    else
                    {
                        room_aloct.IsDischarge = false;
                    }
                    var PreviousWardHistory = (from tbl in db.Ward_Allocations
                                               join inpat in db.In_Patients
                                               on tbl.InPatient_ID equals inpat.In_Patient_ID.ToString()
                                               where tbl.InPatient_ID == InPatID.ToString() && tbl.Patient_ID == Convert.ToInt32(PatID)
                                               && tbl.IsDischarge == false
                                               select tbl).ToList();
                    if (PreviousWardHistory.Count != 0)
                    {
                        foreach (var ward in PreviousWardHistory)
                        {
                            ward.IsDischarge = true;
                            ward.To_TimeDate = Convert.ToDateTime(DateTime.Now);
                        }
                    }
                }
                db.SubmitChanges();
            }
            catch (Exception ex)
            {
                throw;
            }
            return InPatientStatus;
        }



        [WebMethod]
        public static string SaveWardInformation(string btnsave, string PatID, string InPatID, string ddlWard_No, string txtBed_No, string txtExpected_Discharge_On_Date, string ddlDoctor, bool DischargeChk, string txtAdvice, string txtProcedure_Operation, string txtProcedure_Detail, string txtDignosis, string txtNext_Visit, string DischargeType)
        {
            string InPatientStatus = string.Empty;


            try
            {
                Ward_Allocation ward_aloct;
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                In_Patient in_Pat = new In_Patient();

                in_Pat = (from tbl in db.In_Patients
                          where tbl.Patient_ID == Convert.ToInt32(PatID)
                          && tbl.In_Patient_ID == Convert.ToInt32(InPatID)
                          select tbl).FirstOrDefault();

                if (DischargeChk == false && in_Pat != null)
                {
                    if (in_Pat.Discharge == true && in_Pat.Discharge_On != null)
                    {
                        in_Pat.Discharge = false;
                        in_Pat.Discharge_On = null;
                        in_Pat.Discharge_Type = null;
                        db.SubmitChanges();
                        return InPatientStatus = "Patient is undischarged Successfully !," + InPatID;
                    }
                }

                ward_aloct = (from tbl in db.Ward_Allocations
                              where tbl.Ward_ID == Convert.ToInt32(ddlWard_No)
                               && tbl.InPatient_ID == (InPatID).ToString() && tbl.Patient_ID == Convert.ToInt32(PatID)
                               && tbl.Bed_No_Assigned == Convert.ToInt32(txtBed_No) && tbl.IsDischarge == false
                              select tbl).FirstOrDefault();

                if (DischargeChk == true && ward_aloct == null && in_Pat.Discharge == false && in_Pat.Discharge_On == null)
                {
                    in_Pat.Discharge = true;
                    in_Pat.Discharge_On = Convert.ToDateTime(txtExpected_Discharge_On_Date.ToString());
                    in_Pat.Discharge_By = ddlDoctor;
                    in_Pat.Prevention_Precaution = txtAdvice;
                    in_Pat.Procedure_Operation = txtProcedure_Operation;
                    in_Pat.Procedure_Detail = txtProcedure_Detail;
                    in_Pat.Discharge_Type = DischargeType;
                    if (!string.IsNullOrEmpty(txtNext_Visit))
                        in_Pat.Next_Visit = Convert.ToDateTime(txtNext_Visit);
                    in_Pat.Diagonosis = txtDignosis;
                    db.SubmitChanges();
                    InPatientStatus = "Patient is Discharged Successfully !," + InPatID;
                    DBClass.executeNonQueryWithoutBegin("update Discount_Assigned_Patient set IsDischarge=1 where Patient_Id=" + PatID);
                }

                if (ward_aloct != null)
                {
                    in_Pat.Discharge_On = Convert.ToDateTime(txtExpected_Discharge_On_Date.ToString());
                    in_Pat.Discharge = true;
                    in_Pat.Discharge_By = ddlDoctor;
                    in_Pat.Prevention_Precaution = txtAdvice;
                    in_Pat.Procedure_Operation = txtProcedure_Operation;
                    in_Pat.Procedure_Detail = txtProcedure_Detail;
                    in_Pat.Discharge_Type = DischargeType;
                    if (!string.IsNullOrEmpty(txtNext_Visit))
                        in_Pat.Next_Visit = Convert.ToDateTime(txtNext_Visit);
                    in_Pat.Diagonosis = txtDignosis;

                    InPatientStatus = "Patient is Discharged Successfully !," + InPatID;
                    DBClass.executeNonQueryWithoutBegin("update Discount_Assigned_Patient set IsDischarge=1 where Patient_Id=" + PatID);

                    ward_aloct.Updated_By = AppConfig.UserID;
                    ward_aloct.Updated_Time = DateTime.Now;

                    ward_aloct.InPatient_ID = InPatID.ToString();
                    ward_aloct.Patient_ID = Convert.ToInt32(PatID);
                    ward_aloct.Ward_ID = Convert.ToInt32(ddlWard_No);
                    ward_aloct.Bed_No_Assigned = Convert.ToInt32(txtBed_No);

                    ward_aloct.Doctor_Assigned = Convert.ToInt32(ddlDoctor);
                    if (DischargeChk == true)
                    {
                        ward_aloct.IsDischarge = true;
                        ward_aloct.To_TimeDate = Convert.ToDateTime(txtExpected_Discharge_On_Date);

                        // SMS Configration
                        string SMS_Contant = "عارف میموریل ٹیچنگ ہسپتال کی سہولیات پر اعتمادکرنےکاشکریہ ہماری سہولیات کی بہتری کے لیےآپ نیچےدیئے گے نمبرپر رابطہ کریں۔ 03138458018";
                        string msg = "";

                        string CellNumber = (from tbl in db.Reg_patients
                                             where tbl.pat_id == Convert.ToInt32(PatID)
                                             select tbl.Mobile1).FirstOrDefault();

                    }
                    else
                    {
                        ward_aloct.IsDischarge = false;
                    }
                    var PreviousRoomHistory = (from tbl in db.Room_Allocations
                                               join inpat in db.In_Patients
                                               on tbl.In_Patient_ID equals inpat.In_Patient_ID
                                               where tbl.In_Patient_ID == Convert.ToInt32(InPatID) && tbl.Patient_ID == Convert.ToInt32(PatID)
                                               && tbl.IsDischarge == false
                                               select tbl).ToList();
                    if (PreviousRoomHistory.Count != 0)
                    {
                        foreach (var room in PreviousRoomHistory)
                        {
                            room.IsDischarge = true;
                            room.To_Date = Convert.ToDateTime(DateTime.Now);
                        }
                    }
                    db.SubmitChanges();
                }

            }
            catch (Exception ex)
            {
                throw ex;
            }

            return InPatientStatus;



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
        public static string GetLabTestDDLDetails(string SerialNo)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var test = (from t in db.Lab_Tests
                        where t.Main_Department == "001" && t.Test_Name == SerialNo
                        select new { t.Test_ID, t.Test_Name, t.Group_Category, TestMainDepartmentName = db.GetDataValueName("Main Test Departments", t.Main_Department.ToString()).ToString(), GroupCategoryName = db.GetDataValueName("Test Groups", t.Group_Category.ToString()).ToString() }).ToList();
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
                                       select new { Test_ID = 0, Group_Category = dv.DataValue_Name, Test_Name = dv.DataValue_Description, TestMainDepartmentName = "Lab Test", Main_Department = "001" }).ToList();
                return (new JavaScriptSerializer()).Serialize(GroupCategories);
            }
            return "";
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
        public class TestGroupCategory
        {
            public string TestID { get; set; }
            public string TestName { get; set; }
            public string SerialNo { get; set; }
            public string CategoryID { get; set; }
            public bool IsGroupCategory { get; set; }
            public string GroupName { get; set; }
            public string MainDepartmentName { get; set; }
        }
        [WebMethod]
        public static string GetLabTests()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var tests = from t in db.Lab_Tests
                        where t.Main_Department == "001" && t.Active == true
                        select new { t.Test_ID, t.Test_Name };
            List<TestIDsAndGroupCategory> listOfTest = new List<TestIDsAndGroupCategory>();
            int counter = 1;
            foreach (var test in tests)
            {
                TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                obj.TestID = test.Test_ID.ToString();
                obj.TestName = test.Test_Name.ToString();
                obj.SerialNo = counter.ToString();
                obj.IsGroupCategory = false;
                listOfTest.Add(obj);
                counter++;
            }
            var GroupCategories = from dv in db.DataValues
                                  join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                  where vs.ValueSet_Name == "Test Groups"
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
            return (new JavaScriptSerializer()).Serialize(listOfTest);
        }
        [WebMethod]
        public static string GetTestMainDepartmentDetails(int TestID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var TestMainDepartmentName = (from t in db.Lab_Tests
                                          where t.Test_ID == TestID
                                          select new
                                          {
                                              TestMainDepartmentName123 = db.GetDataValueName("Main Test Departments", t.Main_Department.ToString()).ToString(),
                                              estMainDepartmen = t.Main_Department
                                          });
            return (new JavaScriptSerializer().Serialize(TestMainDepartmentName));
        }
        [WebMethod]
        public static string GetRotations()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dep = from dv in db.DataValues
                      join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                      where vs.ValueSet_Name == "Rotations"
                      select new { dv.DataValue_Name, dv.DataValue_Description };
            return (new JavaScriptSerializer()).Serialize(dep);
        }
        [WebMethod]
        public static string FillTestsByCategory(string CategoryID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var tests = from t in db.Lab_Tests
                        where t.Main_Department == CategoryID && t.Active == true
                        select new { t.Test_ID, t.Test_Name };
            return (new JavaScriptSerializer()).Serialize(tests);
        }

        public class PendingLabTestClass
        {
            public string chkPackages;
            public bool IsBilled;
            public string Lab_Test_Detail_ID;
            public string L_R_Rotation_ID;
            public DateTime Date;
            public string Remark;
            public string Catagory_ID;
            public string Lab_Test_ID;
            public int Test_ID;
            public string Dept_ID;
            public string Recieved_ID;
            public string Parent_Transaction_Type;
            public string Parent_Transaction_Type_ID;
            public string Transaction_Type;
            public string Doctor_ID;
            public int Patient_No;
            public string Patient_ID;
            public string Name;
            public string Out_Patient_ID;
            public string Special_Tests;
            public string Area_Of_Interest;
            public int In_Patient_ID;
            public string Value_Type;
            public string Value_TypeGroup;
            public string Test_Name;
            public string Group_Department;
            public string Group_Category;
            public string DepartmentName;
            public string Department_ID;
            public string GroupName;
            public string Group_Name;
            public string Rotation_ID;
            public string DoctorName;
            public string DataValue_Description;
            public bool Is_Result;
            public string Rotation;
            public string Doctor;
            public string Status;
        }

        [WebMethod]
        public static string GetTestListForHistory(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(id));

            var InPatienttestilst = (from lbtM in db.Laboratory_Tests
                                     join lbtD in db.Lab_Test_Details
                                     on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                     join outpat in db.In_Patients
                                     on lbtM.Patient_ID equals outpat.In_Patient_ID
                                     join p in db.Reg_patients
                                     on outpat.Patient_ID equals p.pat_id
                                     where p.Patient_No == Patien_No && lbtM.Transaction_Type == "InPatient"
                                     select new
                                     {
                                         outpat.In_Patient_ID,
                                         lbtD.Lab_Test_Detail_ID,
                                         lbtD.Date,
                                         lbtD.Remark,
                                         lbtD.Catagory_ID,
                                         lbtM.Lab_Test_ID,
                                         lbtD.Test_ID,
                                         lbtD.Dept_ID,
                                         lbtD.L_R_Rotation_ID,
                                         Value_Type = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Value_Type).FirstOrDefault(),
                                         Value_TypeGroup = (from t in db.Lab_Tests where t.Group_Category == lbtD.Catagory_ID select t.Value_Type).FirstOrDefault(),
                                         Test_Name = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Test_Name).FirstOrDefault(),
                                         Group_Department = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Group_Department).FirstOrDefault(),
                                         Group_Category = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Group_Category).FirstOrDefault(),
                                         DepartmentName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test                                               Departments", t.Main_Department)).FirstOrDefault(),
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
                                         lbtD.Doctor,
                                         lbtD.Recieved_ID,
                                         lbtD.Is_Result,
                                         DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(lbtD.Doctor) select d.Emp_Name).FirstOrDefault()
                                     }
                ).ToList();
            var OutPatienttestilst = (from lbtM in db.Laboratory_Tests
                                      join lbtD in db.Lab_Test_Details
                                      on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                      join outpat in db.Out_Patients
                                      on lbtM.Patient_ID equals outpat.Out_Patient_ID
                                      join p in db.Reg_patients
                                      on outpat.Reg_PatId equals p.pat_id
                                      where p.Patient_No == Patien_No && lbtM.Transaction_Type == "OutPatient"
                                      select new
                                      {

                                          outpat.Out_Patient_ID,
                                          lbtD.Lab_Test_Detail_ID,
                                          lbtD.Date,
                                          lbtD.Remark,
                                          lbtD.Catagory_ID,
                                          lbtM.Lab_Test_ID,
                                          lbtD.Test_ID,
                                          lbtD.Dept_ID,
                                          lbtD.L_R_Rotation_ID,
                                          Value_Type = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Value_Type).FirstOrDefault(),
                                          Value_TypeGroup = (from t in db.Lab_Tests where t.Group_Category == lbtD.Catagory_ID select t.Value_Type).FirstOrDefault(),
                                          Test_Name = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Test_Name).FirstOrDefault(),
                                          Group_Department = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Group_Department).FirstOrDefault(),
                                          Group_Category = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Group_Category).FirstOrDefault(),
                                          DepartmentName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test                                               Departments", t.Main_Department)).FirstOrDefault(),
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
                                          lbtD.Doctor,
                                          lbtD.Recieved_ID,
                                          lbtD.Is_Result,
                                          outpat.Doctor_ID
                                      }
               ).ToList();


            List<PendingLabTestClass> list = new List<PendingLabTestClass>();

            foreach (var item in InPatienttestilst)
            {
                PendingLabTestClass obj = new PendingLabTestClass();

                obj.Lab_Test_Detail_ID = item.Lab_Test_Detail_ID.ToString();
                obj.Date = Convert.ToDateTime(item.Date);
                obj.Remark = item.Remark;
                obj.Catagory_ID = item.Catagory_ID;
                obj.Lab_Test_ID = item.Lab_Test_ID.ToString();
                obj.Test_ID = item.Test_ID;
                obj.Dept_ID = item.Dept_ID;
                obj.L_R_Rotation_ID = item.L_R_Rotation_ID;
                obj.In_Patient_ID = item.In_Patient_ID;
                obj.Value_Type = item.Value_Type;
                obj.Value_TypeGroup = item.Value_TypeGroup;
                obj.Test_Name = item.Test_Name;
                obj.Group_Department = item.Group_Department;
                obj.Group_Category = item.Group_Category;
                obj.DepartmentName = item.DepartmentName;

                obj.Department_ID = item.Department_ID;
                obj.GroupName = item.GroupName;
                obj.Group_Name = item.Group_Name;
                obj.Rotation_ID = item.Rotation_ID;
                obj.Rotation = item.Rotation;
                obj.DataValue_Description = item.DataValue_Description;
                obj.Special_Tests = item.Special_Tests;
                obj.Area_Of_Interest = item.Area_Of_Interest;
                obj.Doctor = item.Doctor;
                obj.Recieved_ID = item.Recieved_ID;
                if (item.Is_Result == null)
                    obj.Is_Result = false;
                else
                    obj.Is_Result = (bool)item.Is_Result;
                obj.Status = "InPatient";
                obj.DoctorName = item.DoctorName;
                list.Add(obj);
            }

            foreach (var item in OutPatienttestilst)
            {
                PendingLabTestClass obj = new PendingLabTestClass();


                obj.Lab_Test_Detail_ID = item.Lab_Test_Detail_ID.ToString();
                obj.Date = Convert.ToDateTime(item.Date);
                obj.Remark = item.Remark;
                obj.Catagory_ID = item.Catagory_ID;
                obj.Lab_Test_ID = item.Lab_Test_ID.ToString();
                obj.Test_ID = item.Test_ID;
                obj.Dept_ID = item.Dept_ID;
                obj.L_R_Rotation_ID = item.L_R_Rotation_ID;
                obj.In_Patient_ID = item.Out_Patient_ID;
                obj.Value_Type = item.Value_Type;
                obj.Value_TypeGroup = item.Value_TypeGroup;
                obj.Test_Name = item.Test_Name;
                obj.Group_Department = item.Group_Department;
                obj.Group_Category = item.Group_Category;
                obj.DepartmentName = item.DepartmentName;

                obj.Department_ID = item.Department_ID;
                obj.GroupName = item.GroupName;
                obj.Group_Name = item.Group_Name;
                obj.Rotation_ID = item.Rotation_ID;
                obj.Rotation = item.Rotation;
                obj.DataValue_Description = item.DataValue_Description;
                obj.Special_Tests = item.Special_Tests;
                obj.Area_Of_Interest = item.Area_Of_Interest;
                obj.Doctor = item.Doctor;
                obj.Recieved_ID = item.Recieved_ID;
                if (item.Is_Result == null)
                    obj.Is_Result = false;
                else
                    obj.Is_Result = (bool)item.Is_Result;
                obj.DoctorName = item.Doctor_ID;
                obj.Status = "OutPatient";
                list.Add(obj);
            }

            return (new JavaScriptSerializer()).Serialize(list);
        }

        [WebMethod]
        public static string PrintTestList(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var testDetailst = (from lbtM in db.Laboratory_Tests
                                join lbtD in db.Lab_Test_Details
                                on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                join inpat in db.In_Patients
                                on lbtM.Patient_ID equals inpat.In_Patient_ID
                                where inpat.In_Patient_ID == id && lbtM.Transaction_Type == "InPatient"
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
                                    DepartmentName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test                                               Departments", t.Main_Department)).FirstOrDefault(),
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
                                    lbtD.Doctor,
                                    lbtD.Recieved_ID,
                                    lbtD.Is_Result,
                                    lbtD.IsBilled,
                                    DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(lbtD.Doctor) select d.Emp_Name).FirstOrDefault()
                                }
                ).ToList();
            return (new JavaScriptSerializer()).Serialize(testDetailst);
        }

        [WebMethod]
        public static string PrintMedicationList(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var testDetailst = (from lbtM in db.In_Patient_Medicines
                                join inpat in db.In_Patients
                                on lbtM.Patient_ID equals inpat.In_Patient_ID
                                where inpat.In_Patient_ID == id && lbtM.Transaction_Type == "InPatient"
                                select new
                                {
                                    lbtM.Medicine_Name,
                                    lbtM.Doctor_ID,
                                    lbtM.Recomended_Dosage,
                                    lbtM.Frequency,
                                    lbtM.Oral,
                                    lbtM.Injections,
                                    DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(lbtM.Doctor_ID) select d.Emp_Name).FirstOrDefault()
                                }
                ).ToList();
            return (new JavaScriptSerializer()).Serialize(testDetailst);
        }

        [WebMethod]
        public static string GetTestList(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var testDetailst = (from lbtM in db.Laboratory_Tests
                                join lbtD in db.Lab_Test_Details
                                on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                join inpat in db.In_Patients
                                on lbtM.Patient_ID equals inpat.In_Patient_ID

                                where inpat.Patient_ID == id && lbtM.Transaction_Type == "InPatient"
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
                                    DepartmentName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test                                               Departments", t.Main_Department)).FirstOrDefault(),
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
                                    lbtD.Doctor,
                                    lbtD.Recieved_ID,
                                    lbtD.Is_Result,
                                    lbtD.IsBilled,
                                    DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(lbtD.Doctor) select d.Emp_Name).FirstOrDefault()
                                }
                ).ToList();
            return (new JavaScriptSerializer()).Serialize(testDetailst);
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
            List<Laboratory_Test> Laboratory_TestList = db.Laboratory_Tests.Where(i => i.Patient_ID == 0 && i.Transaction_Type == "InPatient").ToList();
            db.Laboratory_Tests.DeleteAllOnSubmit(Laboratory_TestList);
            db.SubmitChanges();
            if (record.PatientID != null && record.PatientID != "(New)")
            {
                var lstTests = (from t in db.Laboratory_Tests
                                where t.Patient_ID == int.Parse(record.PatientID) && t.Transaction_Type == "InPatient"
                                select t).FirstOrDefault();
                if (lstTests != null)
                {
                    lstTests.Created_Time = DateTime.Now;
                    LabtestID = lstTests.Lab_Test_ID.ToString();
                }
                else
                {
                    lt.Patient_ID = Convert.ToInt32(record.PatientID);
                    lt.Transaction_Type = "InPatient";
                    lt.Created_Time = DateTime.Now;
                    db.Laboratory_Tests.InsertOnSubmit(lt);
                    db.SubmitChanges();
                    LabtestID = lt.Lab_Test_ID.ToString();
                }
            }
            else
            {
                lt.Patient_ID = Convert.ToInt32(record.PatientID);
                lt.Transaction_Type = "InPatient";
                lt.Created_Time = DateTime.Now;
                db.Laboratory_Tests.InsertOnSubmit(lt);
                db.SubmitChanges();
                LabtestID = lt.Lab_Test_ID.ToString();
            }
            /**********Getting Previous details to delete**************/
            List<Lab_Test_Detail> lstTestDetails = db.Lab_Test_Details.Where(t => t.Lab_Test_ID == int.Parse(LabtestID)).ToList();
            var labID = int.Parse(LabtestID);
            Discharge_Detail dischargeLine = null;
            foreach (var test in record.TestList)
            {
                Lab_Test_Detail ltd = new Lab_Test_Detail();
                ltd.Lab_Test_ID = labID;
                ltd.Patient_ID = Convert.ToInt32(record.PatientID);
                ltd.Date = Convert.ToDateTime(test.Date);
                ltd.Doctor = test.Doctor.ToString();
                ltd.Special_Tests = test.Special_Tests;
                ltd.Rotation_ID = test.RotationID;
                ltd.Catagory_ID = test.Catagory_ID;
                ltd.L_R_Rotation_ID = test.L_R_Rotation_ID;
                ltd.Dept_ID = test.Dept_ID;
                ltd.Area_Of_Interest = test.Area_Of_Interest;
                ltd.Discharge = false;
                ltd.Test_ID = Convert.ToInt32(test.TestID);
                if (test.Is_Result != "")
                    ltd.Is_Result = Convert.ToBoolean(test.Is_Result);
                if (test.IsBIllied != "")
                    ltd.IsBilled = Convert.ToBoolean(test.IsBIllied);
                if (test.RecievedID != "")
                    ltd.Recieved_ID = test.RecievedID;
                bool Duplicate = false;
                db.Lab_Test_Details.InsertOnSubmit(ltd);
                db.SubmitChanges();


                Lab_Test_Detail chkasTest = lstTestDetails.Where(tst => tst.Test_ID == ltd.Test_ID && tst.Test_ID != 0 && tst.Lab_Test_ID == ltd.Lab_Test_ID).FirstOrDefault();

                if (chkasTest != null)
                {

                    ltd.Discharge = chkasTest.Discharge;

                    db.SubmitChanges();
                    dischargeLine = db.Discharge_Details.Where(d => d.Parent_Trans_ID == chkasTest.Lab_Test_Detail_ID && d.Transaction_Type == "Test").FirstOrDefault();
                    Duplicate = true;
                }

                if (chkasTest == null)
                {
                    var chkasCategory = lstTestDetails.Where(tst => tst.Catagory_ID == ltd.Catagory_ID && tst.Test_ID == 0 && tst.Lab_Test_ID == ltd.Lab_Test_ID).FirstOrDefault();
                    if (chkasCategory != null)
                    {

                        ltd.Discharge = chkasCategory.Discharge;

                        db.SubmitChanges();
                        dischargeLine = db.Discharge_Details.Where(d => d.Parent_Trans_ID == chkasCategory.Lab_Test_Detail_ID && d.Transaction_Type == "Test").FirstOrDefault();
                        Duplicate = true;
                    }
                }
                if (!Duplicate)
                {


                }

                if (dischargeLine != null)
                    dischargeLine.Parent_Trans_ID = ltd.Lab_Test_Detail_ID;
            }

            /**********Deleting Previous details**************/
            db.Lab_Test_Details.DeleteAllOnSubmit(lstTestDetails);
            db.SubmitChanges();
            return "";
        }

        public class TestValue
        {
            public string Date { get; set; }
            public string TestID { get; set; }
            public string Doctor { get; set; }
            public string RotationID { get; set; }
            public string L_R_Rotation_ID { get; set; }
            public string Catagory_ID { get; set; }
            public string Dept_ID { get; set; }
            public string Special_Tests { get; set; }
            public string Area_Of_Interest { get; set; }
            public string RecievedID { get; set; }
            public string Is_Result { get; set; }
            public string IsBIllied { get; set; }

        }

        public class LabTest
        {
            public string PatientID { get; set; }
            public List<TestValue> TestList { get; set; }
        }

        [WebMethod]
        public static string LoadExamrpt(int outPatID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var list = (
                 from s in db.Sysmtopms
                 where s.In_Patient_ID == outPatID
                 select new { s.Symtom_ID, Symtom_Name = (DBClass.getField("select Datavalue_Description from ValueSet vs,DataValues dv where  vs.ValueSet_ID=dv.ValueSet_ID and vs.ValueSet_Name='Symtoms' and dv.DataValue_Name='" + s.Symtom_ID + "'").ToString()), s.Duration, Days_Years_Months = db.GetDataValueName("Days_Years_Months", s.Days_Years_Months), s.Remarks }
                 ).ToList();
            return (new JavaScriptSerializer().Serialize(list));
        }
        [WebMethod]
        public static string LoadSymtomps(int outPatID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var list = (
                 from s in db.Sysmtopms
                 where s.In_Patient_ID == outPatID
                 select new { s.Symtom_ID, Symtom_Name = (DBClass.getField("select Datavalue_Description from ValueSet vs,DataValues dv where vs.ValueSet_ID=dv.ValueSet_ID and vs.ValueSet_Name='Symtoms' and dv.DataValue_Name='" + s.Symtom_ID + "'").ToString()), s.Duration, Days_Years_Months = db.GetDataValueName("Days_Years_Months", s.Days_Years_Months), s.Remarks }
                 ).ToList();
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
        public static string LoadSymtompsHistory(int PatID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatID));

            var InPatientlist = (
                 from s in db.Sysmtopms
                 join o in db.In_Patients
                 on s.In_Patient_ID equals o.In_Patient_ID
                 join p in db.Reg_patients
                  on o.Patient_ID equals p.pat_id
                 where p.Patient_No == Patien_No
                 select new { s.Symtom_ID, Symtom_Name = (DBClass.getField("select Datavalue_Description from ValueSet vs,DataValues dv where                                            vs.ValueSet_ID=dv.ValueSet_ID and vs.ValueSet_Name='Symtoms' and dv.DataValue_Name='" + s.Symtom_ID + "'").ToString()), s.Duration, Days_Years_Months = db.GetDataValueName("Days_Years_Months", s.Days_Years_Months), s.Remarks }
                 ).ToList();


            var OutPatientlist = (
                from s in db.Sysmtopms
                join o in db.Out_Patients
                on s.Out_Patient_ID equals o.Out_Patient_ID
                join p in db.Reg_patients
                 on o.Reg_PatId equals p.pat_id
                where p.Patient_No == Patien_No
                select new { s.Symtom_ID, Symtom_Name = (DBClass.getField("select Datavalue_Description from ValueSet vs,DataValues dv where                                            vs.ValueSet_ID=dv.ValueSet_ID and vs.ValueSet_Name='Symtoms' and dv.DataValue_Name='" + s.Symtom_ID + "'").ToString()), s.Duration, Days_Years_Months = db.GetDataValueName("Days_Years_Months", s.Days_Years_Months), s.Remarks }
                ).ToList();


            List<SysmtopmsHistoryClass> list = new List<SysmtopmsHistoryClass>();
            foreach (var item in InPatientlist)
            {
                SysmtopmsHistoryClass obj = new SysmtopmsHistoryClass();

                obj.Symtom_ID = item.Symtom_ID;
                obj.Duration = item.Duration;
                obj.Symtom_Name = item.Symtom_Name;
                obj.Days_Years_Months = item.Days_Years_Months;
                obj.Remarks = item.Remarks;
                obj.Status = "InPatient";
                list.Add(obj);
            }

            foreach (var item in OutPatientlist)
            {
                SysmtopmsHistoryClass obj = new SysmtopmsHistoryClass();

                obj.Symtom_ID = item.Symtom_ID;
                obj.Duration = item.Duration;
                obj.Symtom_Name = item.Symtom_Name;
                obj.Days_Years_Months = item.Days_Years_Months;
                obj.Remarks = item.Remarks;
                obj.Status = "OutPatient";
                list.Add(obj);
            }
            return (new JavaScriptSerializer().Serialize(list));
        }

        public class PatientHistoryClass
        {
            public string HistoryOfPeresentIllness;
            public string HistoryOfPastIllness;
            public string SocioEconomicHistory;
            public string Birth_History;
            public DateTime Created_Time;
            public string Reffer_No;
            public string Reffer_To;
            public string txtInputBox1;
            public string Local;
            public string Mucculor;
            public string GIT;
            public string GYNAE;
            public string RESP;
            public string CNS;
            public string CVS;
            public string ProvisionalDiagnosis;
            public string txtRemarksHistory;
            public string HistoryOfFamily;
            public string Drug_History;
            public string Personal_History;
            public string ObstetricHistory;
            public string AllergiesHistory;
            public string TreatmentHistory;
            public string Status;
            public string Vaccination_History;
            public string Other_History;
        }

        [WebMethod]
        public static string LoadHistoryTabHistory(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatientID));

            var InPatCase = (from op in db.In_Patients
                             join p in db.Reg_patients
                             on op.Patient_ID equals p.pat_id
                             where p.Patient_No == Patien_No

                             select new
                             {
                                 op.HistoryOfPeresentIllness,
                                 op.HistoryOfPastIllness,
                                 op.HistoryOfFamily,
                                 op.SocioEconomicHistory,
                                 op.Birth_History,
                                 op.Drug_History,
                                 op.Personal_History,
                                 op.ObstetricHistory,
                                 op.AllergiesHistory,
                                 op.TreatmentHistory,
                                 op.Created_Time,
                                 op.Vaccination_History,
                                 op.Other_History,
                                 op.GIT,
                                 op.GYNAE,
                                 op.RESP,
                                 op.CNS,
                                 CVS = op.CVS.Replace("null", " "),
                                 op.ProvisionalDiagnosis,
                                 op.txtRemarksHistory,
                                 op.Reffer_No,
                                 Reffer_To = db.GetDataValueName("Patient Main Category", op.Reffer_To),
                                 op.txtInputBox1,
                                 op.Local,
                                 op.Mucculor
                             }).ToList();



            var OutPatCase = (from op in db.Out_Patients
                              join p in db.Reg_patients
                              on op.Reg_PatId equals p.pat_id
                              where p.Patient_No == Patien_No

                              select new
                              {
                                  op.HistoryOfPeresentIllness,
                                  op.HistoryOfPastIllness,
                                  op.HistoryOfFamily,
                                  op.SocioEconomicHistory,
                                  op.Birth_History,
                                  op.Drug_History,
                                  op.Personal_History,
                                  op.ObstetricHistory,
                                  op.AllergiesHistory,
                                  op.TreatmentHistory,
                                  op.Created_Time,
                                  op.GIT,
                                  op.GYNAE,
                                  op.RESP,
                                  op.CNS,
                                  CVS = op.CVS.Replace("null", " "),
                                  op.ProvisionalDiagnosis,
                                  op.txtRemarksHistory,
                                  op.Reffer_No,
                                  Reffer_To = db.GetDataValueName("Patient Main Category", op.Reffer_To),
                                  op.txtInputBox1,
                                  op.Local,
                                  op.Mucculor
                              }).ToList();



            List<PatientHistoryClass> list = new List<PatientHistoryClass>();
            foreach (var item in InPatCase)
            {
                PatientHistoryClass obj = new PatientHistoryClass();

                obj.CVS = item.CVS;
                obj.ProvisionalDiagnosis = item.ProvisionalDiagnosis;
                obj.txtRemarksHistory = item.txtRemarksHistory;
                obj.Reffer_No = item.Reffer_No;
                obj.txtInputBox1 = item.txtInputBox1;
                obj.Local = item.Local;
                obj.Mucculor = item.Mucculor;

                obj.ObstetricHistory = item.ObstetricHistory;
                obj.AllergiesHistory = item.AllergiesHistory;
                obj.TreatmentHistory = item.TreatmentHistory;
                obj.GIT = item.GIT;
                obj.GYNAE = item.GYNAE;
                obj.RESP = item.RESP;
                obj.CNS = item.CNS;
                obj.HistoryOfPeresentIllness = item.HistoryOfPeresentIllness;
                obj.HistoryOfPastIllness = item.HistoryOfPastIllness;
                obj.HistoryOfFamily = item.HistoryOfFamily;
                obj.SocioEconomicHistory = item.SocioEconomicHistory;
                obj.Birth_History = item.Birth_History;
                obj.Drug_History = item.Drug_History;
                obj.Personal_History = item.Personal_History;
                obj.Vaccination_History = item.Vaccination_History;
                obj.Other_History = item.Other_History;

                obj.Created_Time = Convert.ToDateTime(item.Created_Time);
                obj.Status = "InPatient";

                list.Add(obj);
            }

            foreach (var item in OutPatCase)
            {
                PatientHistoryClass obj = new PatientHistoryClass();

                obj.CVS = item.CVS;
                obj.ProvisionalDiagnosis = item.ProvisionalDiagnosis;
                obj.txtRemarksHistory = item.txtRemarksHistory;
                obj.Reffer_No = item.Reffer_No;
                obj.txtInputBox1 = item.txtInputBox1;
                obj.Local = item.Local;
                obj.Mucculor = item.Mucculor;

                obj.ObstetricHistory = item.ObstetricHistory;
                obj.AllergiesHistory = item.AllergiesHistory;
                obj.TreatmentHistory = item.TreatmentHistory;
                obj.GIT = item.GIT;
                obj.GYNAE = item.GYNAE;
                obj.RESP = item.RESP;
                obj.CNS = item.CNS;
                obj.HistoryOfPeresentIllness = item.HistoryOfPeresentIllness;
                obj.HistoryOfPastIllness = item.HistoryOfPastIllness;
                obj.HistoryOfFamily = item.HistoryOfFamily;
                obj.SocioEconomicHistory = item.SocioEconomicHistory;
                obj.Birth_History = item.Birth_History;
                obj.Drug_History = item.Drug_History;
                obj.Personal_History = item.Personal_History;

                obj.Created_Time = Convert.ToDateTime(item.Created_Time);
                obj.Status = "OutPatient";

                list.Add(obj);
            }
            return ((new JavaScriptSerializer()).Serialize(list));
        }

        public class VitalParameterClass
        {
            public string Pulse_Min;
            public string BP_mm_Hg;
            public string Weight_Kg;
            public string Height_Cm;
            public DateTime Created_Time;
            public string Respiration_Min;
            public string Temp_C;
            public string L_M_P;
            public string Test_ID;
            public DateTime Receiving_date;
            public string RN_Special_Instruction;
            public string RN_Patient_General_Condition;
            public string Status;
            public string BMI;
            public string GCS;
            public string RateBeats;
            public string Emergency_Rhythm;
            public string Emergency_Volume;
            public string OthersRecieveNote;
            public string RespirationRate;
            public string O2_Saturation;
            public string O2_Saturation_Oxygen1;
            public string O2_Saturation_Oxygen2;
            public string User_Name;

        }

        [WebMethod]
        public static string LoadVitalParametersHistory(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatientID));


            var Inpatientlist = (from op in db.In_Patients
                                 join p in db.Reg_patients
                                 on op.Patient_ID equals p.pat_id
                                 join rcv in db.ReceivingNotes
                                 on op.In_Patient_ID equals rcv.In_Patient_ID
                                 where p.Patient_No == Patien_No && rcv.Patient_ID == PatientID
                                       && rcv.Type_Nursing == "IPD Receiving Note" && rcv.Emergency_ID == null
                                 select new
                                 {
                                     rcv.RateBeats,
                                     Emergency_Rhythm = db.GetDataValueName("Emergency Rhythm", rcv.Emergency_Rhythm),   // 
                                     Emergency_Volume = db.GetDataValueName("Emergency Volume", rcv.Emergency_Volume),   // 
                                     rcv.OthersRecieveNote,
                                     rcv.RespirationRate,
                                     rcv.RN_Special_Instruction,
                                     rcv.Receiving_Date,
                                     rcv.Temperature,
                                     rcv.BloodPressure,
                                     rcv.O2_Saturation,
                                     rcv.O2_Saturation_Oxygen1,
                                     rcv.O2_Saturation_Oxygen2,
                                     rcv.Type_Nursing,
                                     rcv.user_id,
                                 }).ToList();

            var outpatientlist = (from op in db.Out_Patients
                                  join p in db.Reg_patients
                                 on op.Reg_PatId equals p.pat_id
                                  where p.Patient_No == Patien_No

                                  select new
                                  {
                                      op.pulse_Min,
                                      op.BP_mm_Hg,
                                      op.Weight_Kg,
                                      op.Height_Cm,
                                      op.Respiration_Min,
                                      op.Temp_C,
                                      op.L_M_P,
                                      op.BMI,

                                      op.Created_Time
                                  }).ToList();
            List<VitalParameterClass> list = new List<VitalParameterClass>();


            foreach (var item in Inpatientlist)
            {
                VitalParameterClass obj = new VitalParameterClass();
                obj.RateBeats = item.RateBeats;
                obj.Emergency_Rhythm = item.Emergency_Rhythm;
                obj.Emergency_Volume = item.Emergency_Volume;
                obj.OthersRecieveNote = item.OthersRecieveNote;
                obj.RespirationRate = item.RespirationRate;
                obj.Temp_C = item.Temperature;
                obj.BP_mm_Hg = item.BloodPressure;
                obj.Receiving_date = Convert.ToDateTime(item.Receiving_Date);
                obj.RN_Special_Instruction = item.RN_Special_Instruction;

                obj.O2_Saturation = item.O2_Saturation;
                obj.O2_Saturation_Oxygen1 = item.O2_Saturation_Oxygen1;
                obj.O2_Saturation_Oxygen2 = item.O2_Saturation_Oxygen2;
                obj.Status = item.Type_Nursing;
                obj.User_Name = db.aspnet_Users.Where(x => x.UserId == item.user_id).Select(x => x.UserName).FirstOrDefault();
                list.Add(obj);
            }
            return (new JavaScriptSerializer()).Serialize(list);
        }

        [WebMethod]
        public static string LoadDischargeNoteHistory(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatientID));

            var PatCaselist = (from op in db.In_Patients
                               join p in db.Reg_patients
                               on op.Patient_ID equals p.pat_id
                               where p.Patient_No == Patien_No

                               select new
                               {
                                   op.Discharge_By,
                                   DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(op.Discharge_By) select d.Emp_Name),
                                   op.Discharge_On,
                                   op.Prevention_Precaution,
                                   op.Procedure_Detail,
                                   op.Procedure_Operation,
                                   op.Diagonosis,
                                   op.Next_Visit,
                               }).ToList();
            return ((new JavaScriptSerializer()).Serialize(PatCaselist));
        }

        public class MadicationClass
        {
            public string chkDiccharge;
            public string AttendingParamedical_Staff;
            public string Frequency;
            public string In_Patient_Medicine_ID;
            public DateTime Medicine_Date;
            public string Injections;
            public string Medicine_Name;
            public string Oral;
            public int Patient_ID;
            public string Recomended_Dosage;
            public string Created_Time;
            public string Doctor_ID;
            public string DoctorName;
            public string Status;
            public string Dosage_From;
            public string Dosage_Qty;
            public string Other_Instruction;
        }

        [WebMethod]
        public static string LoadMedicinesForHistory(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {

                int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatientID));

                var inPatmedicineList = (from pm in db.In_Patient_Medicines
                                         join op in db.In_Patients
                                         on pm.Patient_ID equals op.In_Patient_ID
                                         join p in db.Reg_patients
                                         on op.Patient_ID equals p.pat_id
                                         where p.Patient_No == Patien_No && pm.Transaction_Type == "InPatient"
                                         select new { pm.chkDiccharge, pm.AttendingParamedical_Staff, pm.Frequency, pm.In_Patient_Medicine_ID, pm.Injections, pm.Medicine_Date, pm.Medicine_Name, pm.Oral, pm.Patient_ID, pm.Recomended_Dosage, op.Created_Time, pm.Doctor_ID, pm.Dosage_From, pm.Dosage_Qty, pm.Other_Instruction, DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(pm.Doctor_ID) select d.Emp_Name).FirstOrDefault() }).ToList();


                var OutPatmedicineList = (from pm in db.In_Patient_Medicines
                                          join op in db.Out_Patients
                                          on pm.Patient_ID equals op.Out_Patient_ID
                                          join p in db.Reg_patients
                                          on op.Reg_PatId equals p.pat_id
                                          where p.Patient_No == Patien_No && pm.Transaction_Type == "OutPatient"
                                          select new { pm.chkDiccharge, pm.AttendingParamedical_Staff, pm.Frequency, pm.In_Patient_Medicine_ID, pm.Injections, pm.Medicine_Date, pm.Medicine_Name, pm.Oral, pm.Patient_ID, pm.Recomended_Dosage, op.Created_Time, pm.Doctor_ID, pm.Dosage_From, pm.Dosage_Qty, pm.Other_Instruction, DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(pm.Doctor_ID) select d.Emp_Name).FirstOrDefault() }).ToList();


                List<MadicationClass> list = new List<MadicationClass>();
                foreach (var item in inPatmedicineList)
                {
                    MadicationClass obj = new MadicationClass();

                    obj.AttendingParamedical_Staff = item.AttendingParamedical_Staff;
                    obj.Frequency = item.Frequency;
                    obj.Medicine_Date = Convert.ToDateTime(item.Medicine_Date);
                    obj.Injections = item.Injections;

                    obj.Medicine_Name = item.Medicine_Name;
                    obj.Oral = item.Oral;
                    obj.Dosage_From = item.Dosage_From;
                    obj.Dosage_Qty = item.Dosage_Qty;
                    obj.Other_Instruction = item.Other_Instruction;
                    obj.Recomended_Dosage = item.Recomended_Dosage;
                    obj.Status = "InPatient";
                    list.Add(obj);
                }
                foreach (var item in OutPatmedicineList)
                {
                    MadicationClass obj = new MadicationClass();

                    obj.AttendingParamedical_Staff = item.AttendingParamedical_Staff;
                    obj.Frequency = item.Frequency;
                    obj.Medicine_Date = Convert.ToDateTime(item.Medicine_Date);
                    obj.Injections = item.Injections;

                    obj.Medicine_Name = item.Medicine_Name;
                    obj.Dosage_From = item.Dosage_From;
                    obj.Dosage_Qty = item.Dosage_Qty;
                    obj.Other_Instruction = item.Other_Instruction;
                    obj.Oral = item.Oral;

                    obj.Recomended_Dosage = item.Recomended_Dosage;

                    obj.Status = "OutPatient";
                    list.Add(obj);
                }
                return (new JavaScriptSerializer()).Serialize(list);
            }
            return "";
        }





        [WebMethod]
        public static string LoadLabResultrptDetail(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatmedicineList = (from pm in db.Lab_Resultrpts
                                         join op in db.In_Patients
                                         on pm.In_Patient_ID equals op.In_Patient_ID
                                         where op.In_Patient_ID == PatientID
                                         select new { pm.Lab_Resultrpt_ID, Lab_Resultrpt = db.GetDataValueName("Lab Result", pm.Lab_Resultrpt_ID), pm.Lab_Resultrpt_Name }).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
            }
            return "";
        }
        public class Symtom
        {
            public int In_Patient_ID { get; set; }
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
        public static string SaveSymtoms(string SymtomsList)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var data = js.Deserialize<Symtom>(SymtomsList);
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    if (data.In_Patient_ID == 0)
                        data.In_Patient_ID = Convert.ToInt32(DBClass.getField("select (isnull(max(In_Patient_id),0)+1) from In_Patient").ToString());
                    int couterNewRecords = 0;
                    /*********************Deleting Previous Entry On Every Insert Or Update*************************/
                    List<Sysmtopm> SysmtopmList = db.Sysmtopms.Where(p => p.In_Patient_ID == data.In_Patient_ID).ToList();
                    if (SysmtopmList != null)
                    {
                        db.Sysmtopms.DeleteAllOnSubmit(SysmtopmList);
                        couterNewRecords++;
                    }
                    couterNewRecords = 0;
                    /*********************Inserting New Entry On Every Insert Or Update*************************/
                    foreach (SymtomsList oSymtomsList in data.SymtomsList)
                    {
                        Sysmtopm oSysmtopm = new Sysmtopm()
                        {
                            In_Patient_ID = data.In_Patient_ID,
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
        [WebMethod]
        public static string SyptumNew(string syptum)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {

                DataValue data = new DataValue();
                var CountRepeat = db.DataValues.Where(i => i.DataValue_Description == syptum && i.ValueSet_ID == 1083).ToList();

                if (CountRepeat.Count == 0)
                {
                    data.ValueSet_ID = 1083;
                    var sQuery =
                                  (from staff in db.DataValues
                                   orderby staff.DataValue_Name ascending
                                   select staff.DataValue_Name).Distinct().ToList();
                    var snumber = Convert.ToInt32(DBClass.getField("select (isnull(max(convert(int,DataValue_Name)),0)+1) from DataValues where  ValueSet_ID=1083").ToString());

                    data.DataValue_Name = Convert.ToInt32(snumber).ToString();
                    data.DataValue_Description = syptum;
                    db.DataValues.InsertOnSubmit(data);
                    db.SubmitChanges();
                }
            }
            return "";

        }
        [WebMethod]
        public static string GetInstruction(int id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatmedicineList = (from pm in db.InPatient_Instructions
                                         where pm.In_Patient_ID == id
                                         select new { pm.IsLatest, pm.Instruction_Date, pm.Doctor_Instruction, pm.Doctor_Status, pm.Doctor_ID, DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(pm.Doctor_ID) select d.Emp_Name).FirstOrDefault(), DoctorStatus = db.GetDataValueName("Doctor Status", pm.Doctor_Status) }).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
            }
            return "";
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



        List<Med> mdddddcns;
        public class Med
        {
            public string Medicine_Name;
        }
        public class ResultP
        {
            public List<Med> Medicene;
            public string Follow_Up;
            public string Follow_Date;
            public string ProvisionalD;
            public string PrintedBy;
            public string Gender;
            public string ReceiptCharges;
            public string Full_Name;
            public string FatherName;
            public string Birth_Date;
            public string NowDate;
            public string ContectNo;
            public string NIC;
            public string Blood_Group;
            public string Created_By;
            public string Token_No;
            public string Prisentation;
            public string RoomNo;
            public string ReceiptNo;
            public int follow;
            public string Pulse_Min;
            public string BP;
            public string Temp_C;
            public string Respiration_Min;
            public string Permanent_Address;
            public string MR_No;
            public string Printed_By;
            public string Patient_Type;
            public string Department;
            public string Age_years;
            public string Created_Time;
            public string Referring_Doctor;
            public string Province;
            public string Temporary_Address;
            public string Procedure_Operation;
            public string Diagonosis;
            public string Advice;
            public string Next_Visit;
            public string Procedure_Detail;
            public string Admission_Date;
            public string Discharge_On;
            public string Room_ID;
            public string Bed_No;
            public string Ward_ID;
            public string CNS;
            public string CVS;
            public string RESP;
            public string GIT;
            public string GYNAE;
            public string Mucculor;
            public string Local;
            public string Ward_Name;
            public string Room_Name;
            public string Patient_Discount_Type;
            public string Operator;
            public string Admission_Fee;
        }
        [WebMethod]
        public static ResultP PrintInPatientReceipt(int InPatientID, int OUTPatientID)
        {
            ResultP recieptP = new ResultP();
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var Data = (from tbl in db.Reg_patients
                            join outP in db.In_Patients on tbl.pat_id equals outP.Patient_ID
                            where outP.In_Patient_ID == OUTPatientID
                            select new
                            {
                                outP.Procedure_Operation,
                                outP.Diagonosis,
                                tbl.Patient_No,
                                tbl.Full_Name,
                                tbl.Father_Name,
                                Admission_Fee = outP.Admission_Fees == null ? "0" : outP.Admission_Fees.ToString().Trim(),
                                outP.Prevention_Precaution,
                                outP.Next_Visit,
                                outP.Ward_ID,
                                Ward_Name = (from i in db.Ward_Definitions where i.Ward_ID == outP.Ward_ID select i.Ward_No).FirstOrDefault(),
                                outP.Bed_No,
                                outP.Room_ID,
                                Room_Name = (from i in db.Rooms where i.Room_ID == outP.Room_ID select i.Room_No).FirstOrDefault(),
                                tbl.NIC,
                                outP.Discharge_On,
                                outP.Admission_Date,
                                tbl.Gender,
                                tbl.Mobile1,
                                Department = (from d in db.DataValues join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID where v.ValueSet_Name == "Patient Main Category" && d.DataValue_Name == outP.Department select d.DataValue_Description).FirstOrDefault(),
                                Patient_Type = (from d in db.DataValues join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID where v.ValueSet_Name == "Patient Type" && d.DataValue_Name == outP.AdmissionType select d.DataValue_Description).FirstOrDefault(),
                                tbl.Age_years,
                                tbl.Permanent_Address,
                                //tibitt
                                //tbl.Temporary_Address,
                                tbl.city,
                                tbl.Province,
                                Referring_Doctor = (from i in db.HR_Employees where i.Emp_ID == Convert.ToInt32(outP.Doctor) select i.Emp_Name).FirstOrDefault(),
                                ptientNO = (from i in db.Reg_patients where i.pat_id == tbl.pat_id select i.Patient_No).FirstOrDefault(),
                                outP.Created_Time,

                                Printed_By = (from us in db.aspnet_Users where us.UserId == outP.Created_By select us.UserName).FirstOrDefault(),
                                outP.CNS,
                                outP.CVS,
                                outP.RESP,
                                outP.GIT,
                                outP.GYNAE,
                                outP.Mucculor,
                                outP.Local,
                                outP.Procedure_Detail,
                                Patient_Discount_Type = db.GetDataValueName("Patient Type", outP.Patient_Discount_Type)
                            }

                    ).FirstOrDefault();
                if (Data != null)
                {
                    recieptP.CVS = Data.CVS;
                    recieptP.CNS = Data.CNS;
                    if (Data.Ward_ID != null)
                    {
                        recieptP.Ward_ID = Data.Ward_ID.ToString();
                        recieptP.Ward_Name = Data.Ward_Name.ToString();
                        recieptP.Bed_No = Data.Bed_No.ToString();
                    }
                    recieptP.Admission_Fee = Data.Admission_Fee.ToString();
                    recieptP.Room_ID = Data.Room_ID.ToString();
                    recieptP.Room_Name = Data.Room_Name.ToString();
                    recieptP.Discharge_On = Data.Discharge_On.ToString();
                    recieptP.Admission_Date = Convert.ToDateTime(Data.Admission_Date).ToString("MM-dd-yy hh:mm tt");
                    recieptP.Operator = Data.Printed_By.ToString();
                    recieptP.Procedure_Detail = Data.Procedure_Detail;
                    recieptP.Local = Data.Local;
                    recieptP.Mucculor = Data.Mucculor;
                    recieptP.GYNAE = Data.GYNAE;
                    recieptP.GIT = Data.GIT;
                    recieptP.RESP = Data.RESP;
                    recieptP.MR_No = Data.Patient_No.ToString();
                    recieptP.Full_Name = Data.Full_Name;
                    recieptP.FatherName = Data.Father_Name;
                    recieptP.Procedure_Operation = Data.Procedure_Operation;
                    recieptP.Diagonosis = Data.Diagonosis;
                    recieptP.Advice = Data.Prevention_Precaution;
                    if (Data.Next_Visit != null)
                    {
                        recieptP.Next_Visit = Convert.ToDateTime(Data.Next_Visit).ToString("MM-dd-yy hh:mm tt");
                    }
                    recieptP.NIC = Data.NIC.ToString();
                    recieptP.Gender = Data.Gender.ToString();
                    recieptP.ContectNo = Data.Mobile1.ToString();
                    recieptP.Department = Data.Department;
                    recieptP.Patient_Type = Data.Patient_Type;
                    recieptP.Age_years = Data.Age_years;
                    recieptP.Permanent_Address = Data.Permanent_Address.ToString();
                    //recieptP.Temporary_Address = Data.Temporary_Address.ToString();
                    recieptP.Province = Data.Province.ToString();
                    recieptP.Referring_Doctor = Data.Referring_Doctor;
                    recieptP.Patient_Discount_Type = Data.Patient_Discount_Type;
                    recieptP.Created_Time = Convert.ToDateTime(Data.Created_Time).ToString("MM-dd-yy hh:mm tt");
                }
            }
            return recieptP;
        }

        [WebMethod]
        public static string LoadMedicinesForHistoryrpt(int PatientID, int oUTID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatmedicineList = (from pm in db.In_Patient_Medicines
                                         join op in db.In_Patients
                                         on pm.Patient_ID equals op.In_Patient_ID
                                         where op.Patient_ID == PatientID && pm.Transaction_Type == "InPatient" && pm.Patient_ID == oUTID && pm.chkDiccharge == false
                                         select new { pm.AttendingParamedical_Staff, pm.Frequency, pm.In_Patient_Medicine_ID, pm.Injections, pm.Medicine_Date, pm.Medicine_Name, pm.Oral, pm.Patient_ID, pm.Recomended_Dosage, op.Created_Time }).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
            }
            return "";
        }

        [WebMethod]
        public static string LoadDischargeMedicinesrpt(int PatientID, int oUTID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var inPatmedicineList = (from pm in db.In_Patient_Medicines
                                     join op in db.In_Patients
                                     on pm.Patient_ID equals op.In_Patient_ID
                                     where op.Patient_ID == PatientID && pm.Transaction_Type == "InPatient" && pm.Patient_ID == oUTID && pm.chkDiccharge == true
                                     select new { pm.AttendingParamedical_Staff, pm.Frequency, pm.In_Patient_Medicine_ID, pm.Injections, pm.Medicine_Date, pm.Medicine_Name, pm.Oral, pm.Patient_ID, pm.Recomended_Dosage, op.Created_Time }).ToList();
            return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
        }
        [WebMethod]
        public static string SetDischargeRequest(int InPatientID)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

                // Find the In_Patient record
                var inPatient = db.In_Patients.FirstOrDefault(x => x.In_Patient_ID == InPatientID);

                if (inPatient != null)
                {
                    inPatient.Discharge_Request = true;
                    db.SubmitChanges();
                    return "Success";
                }
                else
                {
                    return "NotFound";
                }
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        [WebMethod]
        public static string GetDischargeRequestStatus(int InPatientID)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

                var inPatient = db.In_Patients
                    .Where(x => x.In_Patient_ID == InPatientID)
                    .Select(x => x.Discharge_Request)
                    .FirstOrDefault();

                // Return "1" if true, "0" if false or null
                return (inPatient == true) ? "1" : "0";
            }
            catch (Exception ex)
            {
                return "0";
            }
        }
        [WebMethod]
        public static string GetPendingBalance(int PatientID, int InPatientID)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    // First check the patient_discount_type from in_patient table
                    var inPatient = (from ip in db.In_Patients
                                     where ip.In_Patient_ID == InPatientID
                                     select ip).FirstOrDefault();

                    // If discount type is '03', return special value to skip the check
                    if (inPatient != null && inPatient.Patient_Discount_Type == "03")
                    {
                        return "SKIP_CHECK"; // Special flag to indicate skip
                    }

                    // Get billing records based on final bill existence
                    var billingRecords = (from b in db.Ar_Billings
                                          where b.In_Patient_ID == InPatientID
                                          select b).ToList();

                    // Check if any final bill exists
                    bool hasFinalBill = billingRecords.Any(b => b.final_bill_ipd == true);

                    // Filter records based on scenario
                    var filteredBillingRecords = hasFinalBill
                        ? billingRecords.Where(b => b.final_bill_ipd == true).ToList()
                        : billingRecords.Where(b => b.final_bill_ipd == false || b.final_bill_ipd == null).ToList();

                    // Get all advance records for this inpatient
                    var advanceRecords = (from a in db.AR_Advances
                                          where a.In_Patient_ID == InPatientID
                                          select a).ToList();
                    var previousRecords = (from a in db.Ar_Billings
                                          where a.In_Patient_ID == InPatientID
                                          select a).ToList();

                    decimal totalBillAmount = filteredBillingRecords.Sum(b => b.Total_Amount ?? 0);
                    decimal totalReceivedAmount = filteredBillingRecords.Sum(b => b.Received_Amount ?? 0);
                    decimal totalDiscountAmount = filteredBillingRecords.Sum(b => b.Discount_Amount ?? 0);
                    decimal totalAdvanceAmount = advanceRecords.Sum(a => a.Advance_Amount ?? 0);
                    decimal totalPrevious = previousRecords.Sum(a => a.Previous_Paid ?? 0);

                    // Calculate pending balance
                    decimal pendingBalance = totalBillAmount - (totalReceivedAmount + totalDiscountAmount + totalAdvanceAmount+ totalPrevious);

                    return (pendingBalance < 0 ? 0 : pendingBalance).ToString("F2");
                }
            }
            catch (Exception ex)
            {
                return "0";
            }
        }
    }
}