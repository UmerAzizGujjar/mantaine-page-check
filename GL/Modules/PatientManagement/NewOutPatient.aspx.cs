using CrystalDecisions.CrystalReports.ViewerObjectModel;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web;
using static PMS.WebForm11;

namespace PMS.Modules.PatientManagement
{
    public partial class NewOutPatient : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            DataBaseDataContext db = new DataBaseDataContext();
              



            if (!Page.IsPostBack)
            {
                BindDropDownList();
                if (Request.QueryString["ID"] != null)
                {
                    OutpatientID = Convert.ToInt32(Request.QueryString["ID"]);
                }
            }
            lblDoctor.Text = (from a in db.HR_Employees
                           where a.userid == AppConfig.UserID.ToString()
                           select a.Emp_Name).FirstOrDefault();


            hdndoctors_id.Value = (from a in db.HR_Employees
                                   where a.userid == AppConfig.UserID.ToString()
                                   select a.Emp_ID.ToString()).FirstOrDefault();
        }
        [WebMethod]
        public static string GetAvailableDates(int DocID)
        {
            List<string> availableDates = new List<string>();

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                // First get DateTime list from DB (no formatting in SQL)
                var rawDates = (from r in db.Doctor_Rouster_Masters
                                join d in db.Doctor_Rouster_Details
                                on r.Rouster_id equals d.Rouster_id
                                where r.Doctor_Id == DocID
                                && d.Rouster_Date >= DateTime.Today
                                select d.Rouster_Date.Value).Distinct().ToList();

                // Format in C#
                availableDates = rawDates.Select(d => d.ToString("yyyy-MM-dd")).ToList();
            }

            return new JavaScriptSerializer().Serialize(availableDates);
        }
        [WebMethod]
        public static string SaveRecord(PatientVisitData data)
        {
            try
            {
                var id = "";
                var doctor_id =""; 
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    Out_Patient OPD;
                    if (data.btnsave == "Save")
                    {
                        OPD = new Out_Patient();
                        OPD.Patient_ID = Convert.ToInt32(data.Patient_ID);
                        OPD.Reg_PatId = Convert.ToInt32(data.reg_ID);

                        // Required fields for new records
                        OPD.Book_ID = AppConfig.Book_ID;
                        OPD.Created_By = AppConfig.UserID;
                        OPD.Created_Time = DateTime.Now;
                        OPD.Company_ID = AppConfig.Company_ID;
                        OPD.OPD_Entry_Date = DateTime.Now.Date;
                       
                    }
                    else
                    {
                        int outPatientId;
                        if (!int.TryParse(data.Out_Patient_ID, out outPatientId))
                        {
                            throw new Exception("Invalid Out_Patient_ID for update operation");
                        }

                        OPD = db.Out_Patients.FirstOrDefault(tbl => tbl.Out_Patient_ID == outPatientId);

                        if (OPD == null)
                        {
                            throw new Exception("Patient record not found for update");
                        }

                        OPD.Updated_By = AppConfig.UserID;
                        OPD.Updated_Time = DateTime.Now;
                    }

                    // Initialize only fields that aren't being set elsewhere in the code

                    // General Fields
                    OPD.Suffering_Days = "";
                    OPD.Recommended_Department = "";
                    OPD.Recommended_Doctor = "";
                    OPD.Health_Complaints = "";
                    OPD.Refering_Doctor = "";
                    OPD.Patient_Status = "";
                    OPD.Refer_To_Hospital = "";
                    OPD.Complaints = "";
                    OPD.Prior_Reports = "";
                    OPD.Medical_Reports = "";
                    OPD.Physical_Condition = "";
                    OPD.EDD = "";
                    OPD.Special_Test = "";
                    OPD.Area_Of_Interest = "";
                    

                    // ENT Fields
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

                    // Derma Fields
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

                    // Psychiatry Fields
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

                    // Paeds Fields
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
                    OPD.Peads_DateOfDelivery = null;
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

                    // Other Fields
                    OPD.DRE = false;
                    OPD.Proctoscopy = false;
                    OPD.PA_Gynae = "";
                    OPD.PS_Gynae = "";
                    OPD.Uterus = "";
                    OPD.FX = "";
                    OPD.PS_Obs = "";
                    OPD.PV_Obs = "";
                    OPD.SFH = "";
                    OPD.LIE = "";
                    OPD.Presentation = "";
                    OPD.FHR = "";
                    OPD.Engagement = "";
                    OPD.Ent_Com_Right_pos = "";
                    OPD.Ent_Com_Left_pos = "";
                    OPD.Ent_Com_Right_Neg = "";
                    OPD.Ent_Com_Left_Neg = "";
                    OPD.Ent_Com_Right_False = "";
                    OPD.Ent_Com_Left_False = "";
                    OPD.Ent_Com_Right_False_Neg = "";
                    OPD.Ent_Com_Left_False_Neg = "";
                    OPD.Ent_Com_Central = "";
                    OPD.Ent_Com_Lateralized = "";
                    OPD.Ent_Com_PTA = "";
                    OPD.Ent_Com_Tympanometry = "";
                    OPD.MUAC = "";
                    OPD.OFC = "";
                    OPD.Heptomology = "";
                    OPD.Splenomegaly = "";
                    OPD.NextPlan = "";
                    OPD.No_medicine = false;
                    OPD.No_LabTest = false;
                    OPD.Prepared_Status = false;
                    OPD.PDF_File = "";
                    OPD.Folllow_Date = null;
                    OPD.chk6 = false;
                    OPD.chk7 = false;
                    OPD.chk8 = false;
                    OPD.ENT_Rinnes_Right_Neg = false;
                    OPD.ENT_Rinnes_Lft_Neg = false;
                    OPD.ENT_Rinnes_Right_FNeg = false;
                    OPD.ENT_Rinnes_Lft_FNeg = false;
                    var checkpat_type = (from a in db.Patients
                                          where a.Patient_ID == data.Patient_ID
                                          select a.Patient_Type).FirstOrDefault();
                    doctor_id = data.doc_id_hdn;

                    if (doctor_id != "" && checkpat_type == "01" )
                    {
                        DBClass.executeNonQueryWithoutBegin("update Patients set Share_Transfered=1, Doctor_ID =" + doctor_id + " where Patient_ID=" + data.Patient_ID);
                    }
                
                    
                    if (data.L_M_P != null) OPD.L_M_P = data.L_M_P;
                    if (data.SPO2 != null) OPD.spo2 = data.SPO2;
                    if (data.Bsr != null) OPD.BSR = data.Bsr;
                    if (data.Bmi != null) OPD.BMI = data.Bmi;
                    if (data.pulse_Min != null) OPD.pulse_Min = data.pulse_Min;
                    if (data.BP_mm_Hg != null) OPD.BP_mm_Hg = data.BP_mm_Hg;
                    if (data.Temp_C != null) OPD.Temp_C = data.Temp_C;
                    if (data.Respiration_Min != null) OPD.Respiration_Min = data.Respiration_Min;
                    if (data.Height_Cm != null) OPD.Height_Cm = data.Height_Cm;
                    if (data.Weight_Kg != null) OPD.Weight_Kg = data.Weight_Kg;
                    if (data.Provisional_Diagnosis != null) OPD.ProvisionalDiagnosis = data.Provisional_Diagnosis;
                    if (data.HistoryOfPeresentIllness != null) OPD.HistoryOfPeresentIllness = data.HistoryOfPeresentIllness;
                    if (data.HistoryOfFamily != null) OPD.HistoryOfFamily = data.HistoryOfFamily;
                    if (data.HistoryOfPastIllness != null) OPD.HistoryOfPastIllness = data.HistoryOfPastIllness;
                    if (data.DevelopmentHistory != null) OPD.DevelopmentHistory = data.DevelopmentHistory;
                    if (data.VaccinationHistory != null) OPD.VaccinationHistory = data.VaccinationHistory;
                    if (data.NutritionHistory != null) OPD.NutritionHistory = data.NutritionHistory;
                    if (data.CVS != null) OPD.CVS = data.CVS;
                    if (data.GIT != null) OPD.GIT = data.GIT;
                    if (data.RESP != null) OPD.RESP = data.RESP;
                    if (data.AllergiesHistory != null) OPD.AllergiesHistory = data.AllergiesHistory;
                    if (data.TreatmentHistory != null) OPD.TreatmentHistory = data.TreatmentHistory;
                    if (data.SocioEconomicHistory != null) OPD.SocioEconomicHistory = data.SocioEconomicHistory;
                    if (data.CNS != null) OPD.CNS = data.CNS;
                    if (data.URG != null) OPD.URG = data.URG;
                    if (data.GYNAE != null) OPD.GYNAE = data.GYNAE;
                    if (data.Local != null) OPD.Local = data.Local;
                    if (data.Mucculor != null) OPD.Mucculor = data.Mucculor;
                    if (data.ObstetricHistory != null) OPD.ObstetricHistory = data.ObstetricHistory;
                    if (data.txtRemarksHistory != null) OPD.txtRemarksHistory = data.txtRemarksHistory;
                     OPD.chkJVP = data.chkJVP;
                      OPD.chkPallor = data.chkPallor;
                      OPD.chkaganoris = data.chkaganoris;
                    OPD.chkunconceed = data.chkunconceed;
                    OPD.chkjaundice = data.chkjaundice;
                    OPD.hydration = data.hydration;
                    OPD.edema = data.edema;
                    OPD.chk1 = data.chk1;
                    OPD.chk2 = data.chk2;
                    OPD.chk3 = data.chk3;
                    OPD.chk4 = data.chk4;
                    OPD.chk5 = data.chk5;
                    OPD.Discharge = data.Discharged;
                    OPD.txtInputBox1 = data.Other;

                    if (data.Discharged == true)
                    {
                        OPD.discharge_date = DateTime.Now;
                    }

                    if (data.Doctor_ID != null) OPD.Doctor_ID = data.Doctor_ID;
                    if (data.Designation != null) OPD.Designation = data.Designation;
                    if (data.Final_Rec != null) OPD.Final_Rec = data.Final_Rec;
                    if (data.FinalDiagnosis != null) OPD.Final_Diagnosis = data.FinalDiagnosis;
                    if (data.Administration != null) OPD.Administration = data.Administration.ToString();
                    OPD.Control_Date = DateTime.Now;
                    if (data.Follow_Up != null) OPD.Follow_Up = data.Follow_Up.ToString();
                    if (data.Proto != null) OPD.Proto = data.Proto.ToString();
                    if (data.Advice != null) OPD.Advice = data.Advice;
                    if (data.Birth_History != null) OPD.Birth_History = data.Birth_History;

                    // Handle referral logic only if Reffer_To is provided
                    if (!string.IsNullOrEmpty(data.Reffer_To))
                    {
                        var P = db.Patients.FirstOrDefault(tbl => tbl.Patient_ID == data.Patient_ID);
                        if (P != null)
                        {
                            P.Patient_Main_Category = data.Reffer_To;
                            db.SubmitChanges();

                            var D = db.Previous_Dpts.FirstOrDefault(tbl =>
                                tbl.Patient_ID == data.Patient_ID &&
                                tbl.Perivious_Dpt_Name == data.Reffer_To);
                            if (D == null)
                            {
                                Previous_Dpt Previous_Dpt = new Previous_Dpt();
                                Previous_Dpt.Patient_ID = data.Patient_ID;
                                Previous_Dpt.Perivious_Dpt_Name = data.Reffer_To;
                                Previous_Dpt.Created_Time = DateTime.Now;
                                db.Previous_Dpts.InsertOnSubmit(Previous_Dpt);
                                db.SubmitChanges();
                            }
                        }
                    }

                    if (data.Reffer_To != null) OPD.Reffer_To = data.Reffer_To;
                    if (data.Reffer_No != null) OPD.Reffer_No = data.Reffer_No;
                    if (data.Reffer_doc != null && int.TryParse(data.Reffer_doc, out int refferDocId))
                    {
                        OPD.reffer_doc = refferDocId;
                    }

                    if (data.Drug_History != null) OPD.Drug_History = data.Drug_History;
                    if (data.Personal_History != null) OPD.Personal_History = data.Personal_History;
                    if (data.Abdominal != null) OPD.Abdominal = data.Abdominal;

                    if (data.btnsave == "Save")
                    {
                        db.Out_Patients.InsertOnSubmit(OPD);
                    }

                    db.SubmitChanges();
                    id = OPD.Out_Patient_ID.ToString();

                    // Update related records with the new Out_Patient_ID
                    UpdateRelatedRecords(db, OPD.Out_Patient_ID);
                }

                return id;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"SaveRecord Error: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Stack Trace: {ex.StackTrace}");
                return $"Error: {ex.Message}";
            }
        }

        private static void UpdateRelatedRecords(DataBaseDataContext db, int outPatientId)
        {
            // Update medicines
            var medicines = db.In_Patient_Medicines
                .Where(p => p.Patient_ID == 0 && p.Transaction_Type == "OutPatient")
                .ToList();
            foreach (var med in medicines)
            {
                med.Patient_ID = outPatientId;
            }

            // Update eye details
            var eyeDetails = db.EyeDetails
                .Where(t => t.TransactionType == "OutPatient" && t.TransactionID == 0)
                .ToList();
            foreach (var eye in eyeDetails)
            {
                eye.TransactionID = outPatientId;
            }

            // Update lab tests
            var labTest = db.Laboratory_Tests
                .FirstOrDefault(p => p.Patient_ID == 0 && p.Transaction_Type == "OutPatient");
            if (labTest != null)
            {
                labTest.Patient_ID = outPatientId;
            }

            // Update protocols
            var protocols = db.OutPatients_Protos
                .Where(t => t.Outpatient_id == 0)
                .ToList();
            foreach (var proto in protocols)
            {
                proto.Outpatient_id = outPatientId;
            }

            // Update primary diagnoses
            var primaryDiagnoses = db.OutPatientPrimaryDiagnosis
                .Where(t => t.OutPatientID == 0)
                .ToList();
            foreach (var oppd in primaryDiagnoses)
            {
                oppd.OutPatientID = outPatientId;
            }

            // Update final diagnoses
            var finalDiagnoses = db.OutPatientFinalDiagnosis
                .Where(t => t.OutPatientID == 0)
                .ToList();
            foreach (var opfd in finalDiagnoses)
            {
                opfd.OutPatientID = outPatientId;
            }

            // Update complaints
            var complaints = db.OutPatientComplaints
                .Where(t => t.OutPatientID == 0)
                .ToList();
            foreach (var opc in complaints)
            {
                opc.OutPatientID = outPatientId;
            }

            db.SubmitChanges();
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
                    List<In_Patient_Medicine> In_Patient_MedicineList = db.In_Patient_Medicines.Where(i => i.Patient_ID == 0 && i.Transaction_Type == "OutPatient").ToList();
                    db.In_Patient_Medicines.DeleteAllOnSubmit(In_Patient_MedicineList);
                    db.SubmitChanges();

                    int couterNewRecords = 0;

                    if (MedicineDetail.PatientID != 0)
                    {
                        /*********************Deleting Previous Entry On Every Insert Or Update*************************/
                        List<In_Patient_Medicine> inPatmedicineList = db.In_Patient_Medicines.Where(p => p.Patient_ID == MedicineDetail.PatientID && p.Transaction_Type == "OutPatient").ToList();
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
                            Transaction_Type = "OutPatient",
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
            List<Laboratory_Test> Laboratory_TestList = db.Laboratory_Tests.Where(i => i.Patient_ID == 0 && i.Transaction_Type == "OutPatient").ToList();
            db.Laboratory_Tests.DeleteAllOnSubmit(Laboratory_TestList);
            db.SubmitChanges();

            if (record.PatientID != null && record.PatientID != "(New)")
            {
                var lstTests = (from t in db.Laboratory_Tests
                                where t.Patient_ID == int.Parse(record.PatientID) && t.Transaction_Type == "OutPatient"
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
                    lt.Transaction_Type = "OutPatient";
                    lt.Created_Time = DateTime.Now;
                    db.Laboratory_Tests.InsertOnSubmit(lt);
                    db.SubmitChanges();
                    LabtestID = lt.Lab_Test_ID.ToString();
                }
            }
            else
            {
                lt.Patient_ID = Convert.ToInt32(record.PatientID);
                lt.Transaction_Type = "OutPatient";
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
                    if (data.OutPatientID == 0)
                        data.OutPatientID = Convert.ToInt32(DBClass.getField("select (isnull(max(Out_Patient_id),0)+1) from Out_Patient").ToString());
                    int couterNewRecords = 0;
                    /*********************Deleting Previous Entry On Every Insert Or Update*************************/
                    List<Sysmtopm> SysmtopmList = db.Sysmtopms.Where(p => p.Out_Patient_ID == data.OutPatientID).ToList();
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
                            Out_Patient_ID = data.OutPatientID,
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
        public static string SaveProto(string btnSave, string ProtoDetailss)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var ProtDetailList = js.Deserialize<Proto>(ProtoDetailss);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {

                    var pat_id = (from p in db.Reg_patients
                                  join vs in db.Patients on p.pat_id equals vs.Reg_PatId
                                  where vs.Patient_ID == Convert.ToInt32(ProtDetailList.PatId)
                                  select p.pat_id).FirstOrDefault();

                    if (btnSave == "Update")
                    {
                        List<OutPatients_Proto> outpatient_protos = db.OutPatients_Protos.Where(w => w.Outpatient_id == ProtDetailList.opdid).ToList();
                        db.OutPatients_Protos.DeleteAllOnSubmit(outpatient_protos);
                        db.SubmitChanges();
                    }
                    foreach (var item in ProtDetailList.ProtoList)
                    {
                        OutPatients_Proto ipser = new OutPatients_Proto
                        {
                            Patient_Id = pat_id,
                            ProtoId = item.ProtoId,
                            Outpatient_id = 0,
                            Proto_Description = item.Proto_Description
                        };

                        db.OutPatients_Protos.InsertOnSubmit(ipser);
                    }

                    db.SubmitChanges();
                }
            }
            catch (Exception ex)
            {

                Console.WriteLine(ex.Message);
                return "Error: " + ex.Message;
            }

            return "Success";
        }
        [WebMethod]
        public static string SaveComplaintsOfPatient(string ComplaintsList)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                // Deserialize as a List of complaints
                var complaints = js.Deserialize<List<complainList>>(ComplaintsList);

                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    if (complaints.Count > 0)
                    {
                        int outPatientId = complaints[0].OutPatientID;


                        /*********************Deleting Previous Complaints*************************/
                        var existingComplaints = db.OutPatientComplaints.Where(p => p.OutPatientID == outPatientId).ToList();
                        if (existingComplaints != null && existingComplaints.Count > 0)
                        {
                            db.OutPatientComplaints.DeleteAllOnSubmit(existingComplaints);
                        }

                        /*********************Inserting New Complaints*************************/
                        foreach (var complaint in complaints)
                        {
                            OutPatientComplaint newComplaint = new OutPatientComplaint()
                            {
                                OutPatientID = outPatientId,
                                ComplaintID = complaint.ComplaintID,
                                PatientID = 0 // You might want to set this properly
                            };
                            db.OutPatientComplaints.InsertOnSubmit(newComplaint);
                        }

                        db.SubmitChanges();
                        return "Success"; // Return meaningful status
                    }
                    return "No complaints to save";
                }
            }
            catch (Exception ex)
            {
                // Log the exception
                return "Error: " + ex.Message; // Return error message
            }
        }
        [WebMethod]
        public static string SavePrimaryDiagnosisOfPatient(string PrimaryDiagnosisList)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                // Deserialize as a List of PrimaryDiagnosis
                var PrimaryDiagnosis = js.Deserialize<List<PrimaryDiagnosisList>>(PrimaryDiagnosisList);

                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    if (PrimaryDiagnosis.Count > 0)
                    {
                        int outPatientId = PrimaryDiagnosis[0].OutPatientID;

                        /*********************Deleting Previous PrimaryDiagnosis*************************/
                        var existingPrimaryDiagnosis = db.OutPatientPrimaryDiagnosis.Where(p => p.OutPatientID == outPatientId).ToList();
                        if (existingPrimaryDiagnosis != null && existingPrimaryDiagnosis.Count > 0)
                        {
                            db.OutPatientPrimaryDiagnosis.DeleteAllOnSubmit(existingPrimaryDiagnosis);
                        }

                        /*********************Inserting New PrimaryDiagnosis*************************/
                        foreach (var primaryDiagnosis in PrimaryDiagnosis)
                        {
                            OutPatientPrimaryDiagnosi newprimaryDiagnosis = new OutPatientPrimaryDiagnosi()
                            {
                                OutPatientID = outPatientId,
                                DiagnosisID = primaryDiagnosis.DiagnosisID,
                                PatientID = 0,
                                Remarks = primaryDiagnosis.Remarks

                            };
                            db.OutPatientPrimaryDiagnosis.InsertOnSubmit(newprimaryDiagnosis);
                        }

                        db.SubmitChanges();
                        return "Success"; // Return meaningful status
                    }
                    return "No PrimaryDiagnosis to save";
                }
            }
            catch (Exception ex)
            {
                // Log the exception
                return "Error: " + ex.Message; // Return error message
            }
        }
        [WebMethod]
        public static string SaveFinalDiagnosisOfPatient(string FinalDiagnosisList)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                // Deserialize as a List of FinalDiagnosis
                var FinalDiagnosis = js.Deserialize<List<FinalDiagnosisList>>(FinalDiagnosisList);

                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    if (FinalDiagnosis.Count > 0)
                    {
                        int outPatientId = FinalDiagnosis[0].OutPatientID;

                        /*********************Deleting Previous FinalDiagnosis*************************/
                        var existingFinalDiagnosis = db.OutPatientFinalDiagnosis.Where(p => p.OutPatientID == outPatientId).ToList();
                        if (existingFinalDiagnosis != null && existingFinalDiagnosis.Count > 0)
                        {
                            db.OutPatientFinalDiagnosis.DeleteAllOnSubmit(existingFinalDiagnosis);
                        }

                        /*********************Inserting New FinalDiagnosis*************************/
                        foreach (var finalDiagnosis in FinalDiagnosis)
                        {
                            OutPatientFinalDiagnosi newFinalDiagnosis = new OutPatientFinalDiagnosi()
                            {
                                OutPatientID = outPatientId,
                                DiagnosisID = finalDiagnosis.DiagnosisID,
                                PatientID = 0,
                                Remarks = finalDiagnosis.Remarks

                            };
                            db.OutPatientFinalDiagnosis.InsertOnSubmit(newFinalDiagnosis);
                        }

                        db.SubmitChanges();
                        return "Success"; // Return meaningful status
                    }
                    return "No FinalDiagnosis to save";
                }
            }
            catch (Exception ex)
            {
                // Log the exception
                return "Error: " + ex.Message; // Return error message
            }
        }
        [WebMethod]
        public static string GetPatientFormData(int PatientID)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

                var doctorId = db.Out_Patients
                    .Where(dt => dt.Out_Patient_ID == PatientID)
                    .Select(dt => dt.Doctor_ID)
                    .FirstOrDefault();

                var qry = db.sp_FillOutPatientForm(PatientID).FirstOrDefault();

                if (qry == null)
                {
                    return JsonConvert.SerializeObject(new { success = false, message = "Patient data not found" });
                }

                var patientData = new
                {
                    success = true,
                    data = new
                    {
                        // Doctor Information
                        DoctorId = doctorId?.ToString() ?? "",

                        // Basic Patient Info
                        PatientName = qry.Full_Name ?? "",
                        Age = qry.Age_years ?? "",
                        Contact = qry.Mobile1 ?? "",
                        Address = qry.Permanent_Address ?? "",
                        OutPatientId = PatientID.ToString(),
                        PatientId = qry.Patient_ID.ToString(),
                        RegId = qry.Reg_PatId?.ToString() ?? "",

                        // Vital Signs
                        Pulse = qry.pulse_Min ?? "",
                        BP = qry.BP_mm_Hg ?? "",
                        Temperature = qry.Temp_C ?? "",
                        Respiration = qry.Respiration_Min ?? "",
                        Height = qry.Height_Cm ?? "",
                        Weight = qry.Weight_Kg ?? "",
                        SPO2 = qry.spo2 ?? "",
                        BMI = qry.BMI ?? "",
                        BSR = qry.BSR ?? "",
                        MUAC = qry.MUAC ?? "",
                        OFC = qry.OFC ?? "",

                        // Medical History
                        LMP = qry.L_M_P ?? "",
                        EDD = qry.EDD ?? "",
                        DevelopmentHistory = qry.DevelopmentHistory ?? "",
                        VaccinationHistory = qry.VaccinationHistory ?? "",
                        NutritionHistory = qry.NutritionHistory ?? "",
                        HistoryOfPresentIllness = qry.HistoryOfPeresentIllness ?? "",
                        HistoryOfFamily = qry.HistoryOfFamily ?? "",
                        HistoryOfPastIllness = qry.HistoryOfPastIllness ?? "",
                        SocioEconomicHistory = qry.SocioEconomicHistory ?? "",
                        ObstetricHistory = qry.ObstetricHistory ?? "",
                        AllergiesHistory = qry.AllergiesHistory ?? "",
                        TreatmentHistory = qry.TreatmentHistory ?? "",
                        DrugHistory = qry.Drug_History ?? "",
                        PersonalHistory = qry.Personal_History ?? "",
                        BirthHistory = qry.Birth_History ?? "",

                        // Physical Examination
                        CVS = qry.CVS ?? "",
                        GIT = qry.GIT ?? "",
                        RESP = qry.RESP ?? "",
                        CNS = qry.CNS ?? "",
                        GYNAE = qry.GYNAE ?? "",
                        UGS = qry.URG ?? "",
                        Local = qry.Local ?? "",
                        Muscular = qry.Mucculor ?? "",
                        Abdominal = qry.Abdominal ?? "",

                        // Checkboxes - General Examination
                        Pallor = qry.chkPallor?.ToString().ToLower() ?? "false",
                        JVP = qry.chkJVP?.ToString().ToLower() ?? "false",
                        Cyanosis = qry.chkaganoris?.ToString().ToLower() ?? "false",
                        Disoriented = qry.chkunconceed?.ToString().ToLower() ?? "false",
                        Jaundice = qry.chkjaundice?.ToString().ToLower() ?? "false",
                        Dehydration = qry.hydration?.ToString().ToLower() ?? "false",
                        Edema = qry.edema?.ToString().ToLower() ?? "false",
                        Lymphadenopathy = qry.chk1?.ToString().ToLower() ?? "false",
                        Clubbing = qry.chk2?.ToString().ToLower() ?? "false",
                        Dyspnoea = qry.chk3?.ToString().ToLower() ?? "false",
                        NeckSwelling = qry.chk4?.ToString().ToLower() ?? "false",
                        SkinLesions = qry.chk5?.ToString().ToLower() ?? "false",

                        // Special Checkboxes
                        DRE = qry.DRE?.ToString().ToLower() ?? "false",
                        Proctoscopy = qry.Proctoscopy?.ToString().ToLower() ?? "false",

                        // Diagnosis and Treatment
                        ProvisionalDiagnosis = qry.ProvisionalDiagnosis ?? "",
                        FinalDiagnosis = qry.Final_Diagnosis ?? "",
                        FinalRecommendation = qry.Final_Rec ?? "",
                        Advice = qry.Advice ?? "",
                        ReferToHospital = qry.Refer_To_Hospital ?? "",
                        Designation = qry.Designation ?? "",
                        referDoc = qry.reffer_doc ?? 0,

                        // Dropdowns
                        IssuanceOf = qry.Administration ?? "",
                        FollowUp = qry.Follow_Up ?? "",
                        Proto = qry.Proto ?? "",
                        PatientMainCategory = qry.Reffer_To ?? "",

                        // Dates
                        FollowDate = qry.Folllow_Date?.ToString("dd/MM/yyyy") ?? "",

                        // Additional Fields
                        InputBox1 = qry.txtInputBox1 ?? "",
                        ReferNote = qry.Reffer_No ?? "",
                        RemarksHistory = qry.txtRemarksHistory ?? "",

                        // Status
                        Discharge = qry.Discharge?.ToString().ToLower() ?? "false"
                    }
                };

                return JsonConvert.SerializeObject(patientData);
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new { success = false, message = ex.Message });
            }
        }
        [WebMethod]
        public static string LoadSymtompsHistory(int OutPatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
 
            var OutPatientlist = (
                from s in db.Sysmtopms
                where s.Out_Patient_ID == OutPatientID
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
                obj.Status = "OutPatient";
                list.Add(obj);
            }
            return (new JavaScriptSerializer().Serialize(list));
        }
        [WebMethod]
        public static string GetTestList(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var testDetailst = (from lbtM in db.Laboratory_Tests
                                join lbtD in db.Lab_Test_Details
                                on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                join outpat in db.Out_Patients
                                on lbtM.Patient_ID equals outpat.Out_Patient_ID
                                where outpat.Out_Patient_ID == id && lbtM.Transaction_Type == "OutPatient"
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
                List<In_Patient_Medicine> inPatmedicineList = db.In_Patient_Medicines.Where(p => p.Patient_ID == PatientID && p.Transaction_Type == "OutPatient").ToList();
                return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
            }
            return "";
        }
        [WebMethod]
        public static string LoadComplaints(int OutPatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var Complaints = from opc in db.OutPatientComplaints
                                       join cd in db.ComplaintsDefinitions
                                       on opc.ComplaintID equals cd.ID
                                       where opc.OutPatientID == OutPatientID
                                       select new
                                       {
                                           ComplaintID = opc.ComplaintID,
                                           ComplaintName = cd.ComplaintName
                                       };
                return (new JavaScriptSerializer()).Serialize(Complaints.ToList());
            }
            return "";
        }
        [WebMethod]
        public static string LoadPrimaryDiagnosis(int OutPatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var PrimaryDiagnosis = from oppd in db.OutPatientPrimaryDiagnosis
                                       join pdd in db.DiagnosisDefinitions
                                       on oppd.DiagnosisID equals pdd.ID
                                       where oppd.OutPatientID == OutPatientID
                                       select new
                                       {
                                           PrimaryDiagnosisID = oppd.DiagnosisID,
                                           Remarks = oppd.Remarks,
                                           DiagnosisName = pdd.DiagnosisName
                                       };
                return (new JavaScriptSerializer()).Serialize(PrimaryDiagnosis.ToList());
            }
        }
        [WebMethod]
        public static string LoadFinalDiagnosis(int OutPatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var FinalDiagnosis = from oppd in db.OutPatientFinalDiagnosis
                                       join pdd in db.DiagnosisDefinitions
                                       on oppd.DiagnosisID equals pdd.ID
                                       where oppd.OutPatientID == OutPatientID
                                       select new
                                       {
                                           FinalDiagnosisID = oppd.DiagnosisID,
                                           Remarks = oppd.Remarks,
                                           DiagnosisName = pdd.DiagnosisName
                                       };
                return (new JavaScriptSerializer()).Serialize(FinalDiagnosis.ToList());
            }
        }

        [System.Web.Services.WebMethod]
        public static Detail GetDetail(string PatientID)
        {
            int Patien_No = DBClass.GetMRNOBy_PatientID(Convert.ToInt32(PatientID));
            Detail pt = new Detail();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Patient pat = new Patient();
            pat = (from tbl in db.Patients
                   where tbl.Patient_No == Patien_No
                   orderby tbl.Entry_Date descending

                   select tbl).FirstOrDefault();
            Out_Patient OutPat = db.Out_Patients
     .FirstOrDefault(tbl => tbl.Patient_ID.ToString() == PatientID);
            var OutpatientID = "0";
            if (OutPat != null && OutPat.Out_Patient_ID.ToString() != "0")
            {
                  OutpatientID = OutPat.Out_Patient_ID.ToString();
            }
           
            if (pat != null)
            {
                pt.OutPatientID = OutpatientID ?? "0"; // This replaces null with "0"
                pt.Name = pat.Full_Name;
                pt.Gender = pat.Gender;
                pt.Age = pat.Age_years.ToString();
                if (pat.Entry_Date.HasValue)
                    pt.Entry_Date = pat.Entry_Date.ToString();
                pt.Address = pat.Permanent_Address;
                pt.Mobile = pat.Mobile1;
                pt.Entry_Date = pat.Created_Time.ToString();
                pt.department = db.GetDataValueName("Patient Main Category", pat.Patient_Main_Category);
                pt.Patient_type = db.GetDataValueName("Patient Type", pat.Patient_Type);
                HR_Employee doctor = null;

                if (!string.IsNullOrEmpty(pat.Doctor_ID) )
                {
                    doctor = db.HR_Employees.FirstOrDefault(e => e.Emp_ID == Convert.ToInt32(pat.Doctor_ID));
                }
                pt.dotorname = doctor != null ? doctor.Emp_Name : "";
               
                pt.Gender = db.GetDataValueName("Gender", pat.Gender);
                var Patientno = pat.Patient_No.ToString();
                var count = (db.Patients.Where(v => v.Patient_No == Convert.ToInt32(Patientno)).ToList());
                pt.Follow = count.Count.ToString();
                return pt;
            }
            else
                return pt;
        }
        public class Detail
        {
            public string OutPatientID;
            public string Name;
            public string Gender;
            public string Age;
            public string Mobile;
            public string Address;
            public string Entry_Date;
            public string department;
            public string Follow;
            public string Patient_type;
            public string dotorname;

        }
        [WebMethod]
        public static string Getdoctors()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from hr in db.HR_Employees
                              where hr.IsDoctor == true && hr.userid == Convert.ToString(AppConfig.UserID)

                              select new
                              {
                                  hr.Emp_ID,
                                  hr.Emp_Name
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }
        [WebMethod]
        public static string PendingPatients(string filterDepartment, string doc_name)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var data = (from p in db.Patients
                        join u in db.aspnet_Users
                        on p.Created_By equals u.UserId
                        where Convert.ToDateTime(p.Created_Time).Month == DateTime.Now.Month &&
                              Convert.ToDateTime(p.Created_Time).Year == DateTime.Now.Year &&
                              Convert.ToDateTime(p.Created_Time).Day == DateTime.Now.Day /*&&*/
                              //p.Patient_Type == "01"

                        select new
                        {
                            p.Patient_ID,
                            p.Reg_PatId,
                            Patient_No = p.Opd_No,
                            p.Full_Name,
                            p.NIC,
                            DoctorName = (from d in db.HR_Employees
                                          where d.Emp_ID == Convert.ToInt32(p.Doctor_ID)
                                          select d.Emp_Name).FirstOrDefault(),
                            Department = db.GetDataValueName("Patient Main Category", p.Patient_Main_Category),
                            Gender = db.GetDataValueName("Gender", p.Gender),
                            p.Created_Time,
                            u.UserName,
                            p.Age_years,
                            p.Patient_Type,
                            p.Doctor_ID,
                            Checked = ((from op in db.Out_Patients
                                        where op.Patient_ID == p.Patient_ID
                                        && op.Doctor_ID != null && op.Doctor_ID != ""
                                        select op.Doctor_ID).FirstOrDefault()),
                            Token_No = (from t in db.Patients
                                        where t.Patient_ID < p.Patient_ID
                                           && t.Created_Time.Value.Date == p.Created_Time.Value.Date
                                           && t.Created_Time.Value.Month == p.Created_Time.Value.Month
                                           && t.Created_Time.Value.Year == p.Created_Time.Value.Year
                                           && t.Patient_Main_Category == p.Patient_Main_Category
                                        select t).Count() + 1
                        });

            if (!string.IsNullOrEmpty(filterDepartment) && filterDepartment != "" && doc_name == "")
            {
                data = data.Where(p => p.Department == db.GetDataValueName("Patient Main Category", filterDepartment));
            }

            else if (!string.IsNullOrEmpty(filterDepartment) && filterDepartment != "" && !string.IsNullOrEmpty(doc_name))
            {
                data = data.Where(p => p.Department == db.GetDataValueName("Patient Main Category", filterDepartment) && p.Doctor_ID == doc_name);
            }

            else if (!string.IsNullOrEmpty(doc_name) && (string.IsNullOrEmpty(filterDepartment) || filterDepartment == ""))
            {
                data = data.Where(p => p.Doctor_ID == doc_name);
            }

            var result = data.ToList();
            return (new JavaScriptSerializer()).Serialize(result);
        }
        [WebMethod]
        public static string GetAllDeparmtent()
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
        public static string LoadProtoDetails(string patients_id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                List<ProtoDetailss> list = new List<ProtoDetailss>();
                var OutPatients_Proto = db.OutPatients_Protos.DefaultIfEmpty().Where(w => w.Outpatient_id == Convert.ToInt32(patients_id)).ToList();

                if (OutPatients_Proto.Count > 0 && OutPatients_Proto != null)
                {
                    //ServiceDetails sd = new ServiceDetails();
                    //    sd.Service_ProcedureName=
                    foreach (var item in OutPatients_Proto)
                    {
                        ProtoDetailss sd = new ProtoDetailss();
                        sd.ProtoId = item.ProtoId;
                        sd.Proto_Description = item.Proto_Description;

                        list.Add(sd);
                    }
                }

                return (new JavaScriptSerializer().Serialize(list));
            }

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
        
        public class Symtom
        {
            public int OutPatientID { get; set; }
            public List<SymtomsList> SymtomsList { get; set; }
        }
        public class SymtomsList
        {
            public string SymtomID { get; set; }
            public string Duration { get; set; }
            public string DayYearMonth { get; set; }
            public string Remarks { get; set; }
        }
        
        public class PatientVisitData
        {
            // Tab02 - Vitals
            public string pulse_Min { get; set; }
            public string BP_mm_Hg { get; set; }
            public string Temp_C { get; set; }
            public string Respiration_Min { get; set; }
            public string Height_Cm { get; set; }
            public string Weight_Kg { get; set; }
            public string SPO2 { get; set; }
            public string L_M_P { get; set; }
            public string Bsr { get; set; }
            public string Bmi { get; set; }

            // Tab03 - History
            public string HistoryOfPeresentIllness { get; set; }
            public string HistoryOfPastIllness { get; set; }
            public string Birth_History { get; set; }
            public string GYNAE { get; set; }
            public string Drug_History { get; set; }
            public string Personal_History { get; set; }
            public string ObstetricHistory { get; set; }
            public string AllergiesHistory { get; set; }
            public string TreatmentHistory { get; set; }
            public string DevelopmentHistory { get; set; }
            public string VaccinationHistory { get; set; }
            public string NutritionHistory { get; set; }
            public string HistoryOfFamily { get; set; }
            public string SocioEconomicHistory { get; set; }

            // Tab04 - Examination
            public bool chkPallor { get; set; }
            public bool chkJVP { get; set; }
            public bool chkaganoris { get; set; }
            public bool chkunconceed { get; set; }
            public bool chkjaundice { get; set; }
            public bool hydration { get; set; }
            public bool edema { get; set; }
            public bool chk1 { get; set; }
            public bool chk2 { get; set; }
            public bool chk3 { get; set; }
            public bool chk4 { get; set; }
            public bool chk5 { get; set; }
            public string Other { get; set; }
            public string CNS { get; set; }
            public string CVS { get; set; }
            public string RESP { get; set; }
            public string GIT { get; set; }
            public string Abdominal { get; set; }
            public string URG { get; set; }
            public string Mucculor { get; set; }
            public string Local { get; set; }
            public string Provisional_Diagnosis { get; set; }
            public string txtRemarksHistory { get; set; }

            // Tab05 - Referral
            public string Reffer_To { get; set; }
            public string Reffer_doc { get; set; }
            public string Reffer_No { get; set; }

            // Tab12 - Follow Up
            public string Doctor_ID { get; set; }
            public string Designation { get; set; }
            public string Issuance_Of { get; set; }
            public string Follow_Up { get; set; }
            public string FollowNoDate { get; set; }

            // Tab13 - Disposal
            public string FinalDiagnosis { get; set; }
            public string Advice { get; set; }
            public string Final_Rec { get; set; }
            public string Proto { get; set; }

            // Common Fields
            public int Patient_ID { get; set; }
            public string reg_ID { get; set; }
            public string doc_id_hdn { get; set; }
            public string btnsave { get; set; }
            public bool Discharged { get; set; }
            public string Administration { get; set; }
            public string Out_Patient_ID { get; set; }
        }
        

        [WebMethod]
        public static string SaveNewDiagnosis(string Text)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                try
                {

                    // Trim input and check for existing complaint (case-insensitive match)
                    string trimmedText = Text.Trim();

                    bool exists = db.ComplaintsDefinitions
                                    .Any(c => c.ComplaintName.ToLower() == trimmedText.ToLower());

                    if (exists)
                    {
                        return "0";
                    }

                    // Create and insert the new complaint
                    DiagnosisDefinition newDiagnosis = new DiagnosisDefinition
                    {
                        DiagnosisName = trimmedText
                    };

                    db.DiagnosisDefinitions.InsertOnSubmit(newDiagnosis);
                    db.SubmitChanges();

                    return "1";
                }
                catch (Exception ex)
                {
                    // Log the error if needed
                    return "Error saving symptom: " + ex.Message;
                }
            }

        }
        [WebMethod]
        public static string GetDiagnosis(string searchValue)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    IQueryable<DiagnosisDefinition> query = db.DiagnosisDefinitions;

                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        // Filter based on search
                        query = query.Where(c => c.DiagnosisName.ToLower().Contains(searchValue.ToLower()));
                    }
                    else
                    {
                        // If no search, take top 6
                        query = query.Take(6);
                    }

                    // Select only necessary fields
                    var result = query
                        .Select(c => new
                        {
                            DiagnosisId = c.ID,
                            DiagnosisName = c.DiagnosisName
                        })
                        .ToList();

                    return new JavaScriptSerializer().Serialize(result);
                }
            }
            catch (Exception ex)
            {
                // Log error
                System.Diagnostics.Debug.WriteLine($"Error in GetComplaints: {ex}");
                return "[]"; // Return empty array on error
            }
        }

        [WebMethod]
        public static string GetComplaints(string searchValue)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    IQueryable<ComplaintsDefinition> query = db.ComplaintsDefinitions;

                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        // Filter based on search
                        query = query.Where(c => c.ComplaintName.ToLower().Contains(searchValue.ToLower()));
                    }
                    else
                    {
                        // If no search, take top 6
                        query = query.Take(6);
                    }

                    // Select only necessary fields
                    var result = query
                        .Select(c => new
                        {
                            ComplaintId = c.ID,
                            ComplaintName = c.ComplaintName
                        })
                        .ToList();

                    return new JavaScriptSerializer().Serialize(result);
                }
            }
            catch (Exception ex)
            {
                // Log error
                System.Diagnostics.Debug.WriteLine($"Error in GetComplaints: {ex}");
                return "[]"; // Return empty array on error
            }
        }
      

        // Renamed to singular since it represents a single complaint
        public class complainList
        {
            public int OutPatientID { get; set; }
            public int ComplaintID { get; set; }
            public string ComplaintText { get; set; }
        }

   

        // Renamed to singular since it represents a single complaint
        public class PrimaryDiagnosisList
        {
            public int OutPatientID { get; set; }
            public int DiagnosisID { get; set; }
            public string Remarks { get; set; }
        }

       

        // Renamed to singular since it represents a single complaint
        public class FinalDiagnosisList
        {
            public int OutPatientID { get; set; }
            public int DiagnosisID { get; set; }
            public string Remarks { get; set; }
        }
        [WebMethod]
        public static string SaveNewComplaint(string complaintText)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                try
                {

                    // Trim input and check for existing complaint (case-insensitive match)
                    string trimmedComplaint = complaintText.Trim();

                    bool exists = db.ComplaintsDefinitions
                                    .Any(c => c.ComplaintName.ToLower() == trimmedComplaint.ToLower());

                    if (exists)
                    {
                        return "0";
                    }

                    // Create and insert the new complaint
                    ComplaintsDefinition newComplaint = new ComplaintsDefinition
                    {
                        ComplaintName = trimmedComplaint
                    };

                    db.ComplaintsDefinitions.InsertOnSubmit(newComplaint);
                    db.SubmitChanges();

                    return "1";
                }
                catch (Exception ex)
                {
                    // Log the error if needed
                    return "Error saving symptom: " + ex.Message;
                }
            }

        }
        [WebMethod]
        public static string LoadDoctor()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var doctor = (from emp in db.HR_Employees

                              where emp.Resign_Date == null && emp.IsDoctor == true
                              select new { emp.Emp_ID, emp.Emp_Name }).ToList();
                return (new JavaScriptSerializer()).Serialize(doctor);
            }
            return "";
        }
        [WebMethod]
        public static string LoadDoctor_bydep(string depart)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var doctor = (from emp in db.HR_Employees
                              where emp.IsDoctor == true
                              select new { emp.Emp_ID, emp.Emp_Name,emp.Department });

                // Apply search filter if searchTerm is not empty
                if (!string.IsNullOrEmpty(depart))
                {
                    doctor = doctor.Where(t => t.Department == depart);
                }
                return (new JavaScriptSerializer()).Serialize(doctor);
            }
            return "";
        }
        [WebMethod]
        public static string LoadDesignation(int DocID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var Designation = (from emp in db.HR_Employees

                                   where emp.Emp_ID == DocID && emp.Resign_Date == null && emp.IsDoctor == true
                                   select new { Emp_designatin = db.GetDataValueName("Designation", emp.Designation), }).FirstOrDefault();
                return (new JavaScriptSerializer()).Serialize(Designation);
            }
            return "";
        }
        private void BindDropDownList()
        {
            object valueset;   //declare a single object for all valueset            
            valueset = DBClass.GetValueSet("Patient Status");
            DataBaseDataContext db = new DataBaseDataContext();
            List<HR_Employee> EmpList = new List<HR_Employee>();
            EmpList = (from tbl in db.HR_Employees
                       where tbl.IsDoctor == true
                       select tbl).ToList();

            valueset = DBClass.GetValueSet("FollowUp");
            ddlFOllowUp.DataSource = valueset;
            ddlFOllowUp.DataTextField = "DataValue_Description";
            ddlFOllowUp.DataValueField = "DataValue_Name";
            ddlFOllowUp.Items.Add(new ListItem("Please Select", "0"));
            ddlFOllowUp.DataBind();

            valueset = DBClass.GetValueSet("Proto");
            ddlProto.DataSource = valueset;
            ddlProto.DataTextField = "DataValue_Description";
            ddlProto.DataValueField = "DataValue_Name";
            ddlProto.Items.Add(new ListItem("Please Select", "0"));
            ddlProto.DataBind();

            valueset = DBClass.GetValueSet("Laundary From To");
            ddlIssuance_Of.DataSource = valueset;
            ddlIssuance_Of.DataTextField = "DataValue_Description";
            ddlIssuance_Of.DataValueField = "DataValue_Name";
            ddlIssuance_Of.Items.Add(new ListItem("Please Select", "0"));
            ddlIssuance_Of.DataBind();

            valueset = DBClass.GetValueSet("Patient Main Category");
            ddlPatient_Main_Category.DataSource = valueset;
            ddlPatient_Main_Category.DataTextField = "DataValue_Description";
            ddlPatient_Main_Category.DataValueField = "DataValue_Name";
            ddlPatient_Main_Category.Items.Add(new ListItem("Please Select", "0"));
            ddlPatient_Main_Category.DataBind();
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
    }
}