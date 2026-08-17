using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.Script.Services;

namespace PMS.Modules.PatientManagement
{
    public partial class Physiotherapy_Assessment : System.Web.UI.Page
    {
        private static readonly JavaScriptSerializer _json = new JavaScriptSerializer();
        private static int? _currentUserId;

        protected void Page_Load(object sender, EventArgs e)
        {
            try { _currentUserId = GetCurrentEmpId(); } catch { }

            if (!Page.IsPostBack)
            {
                if (Request.QueryString["ID"] == null)
                {
                    Response.Write("<script>alert('Error: No patient ID provided. Please access this form from the patient record.');window.location.href='OutPatients.aspx';</script>");
                    Response.End();
                    return;
                }

                int outPatientId = Convert.ToInt32(Request.QueryString["ID"]);
                LoadPatientData(outPatientId);
            }
        }

        private int GetCurrentEmpId()
        {
            return -1;
        }

        private void LoadPatientData(int outPatientId)
        {
            using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var qry = (from op in db.Out_Patients
                           join p in db.Patients on op.Patient_ID equals p.Patient_ID
                           join rp in db.Reg_patients on p.Reg_PatId equals rp.pat_id
                           where op.Out_Patient_ID == outPatientId
                           select new
                           {
                               op.Patient_ID,
                               rp.pat_id,
                               op.OPD_Entry_Date,
                               op.pulse_Min, op.BP_mm_Hg, op.Temp_C,
                               op.Respiration_Min, op.Height_Cm, op.Weight_Kg,
                               op.Recommended_Department, op.Refering_Doctor,
                               p.Full_Name, p.Age_years, p.Gender, p.Mobile1,
                               p.Patient_No, p.Patient_Main_Category
                           }).FirstOrDefault();

                if (qry != null)
                {
                    string mrNo = "MR-" + (qry.Patient_No?.ToString() ?? "");
                    string genderDisplay = GetDisplayName(db, "Gender", qry.Gender);
                    string deptDisplay = GetDisplayName(db, "Patient Main Category", qry.Patient_Main_Category);

                    var data = new
                    {
                        opId = outPatientId,
                        regPatId = qry.pat_id,
                        display = mrNo + " - " + qry.Full_Name,
                        age = qry.Age_years ?? "",
                        gender = genderDisplay,
                        contact = qry.Mobile1 ?? "",
                        referredBy = deptDisplay,
                        pulse = qry.pulse_Min ?? "--",
                        bp = qry.BP_mm_Hg ?? "--",
                        temp = qry.Temp_C ?? "--",
                        resp = qry.Respiration_Min ?? "--",
                        height = qry.Height_Cm ?? "--",
                        weight = qry.Weight_Kg ?? "--"
                    };

                    string script = "populatePatient(" + _json.Serialize(data) + ");";

                    var existing = db.Physiotherapy_Assessments.FirstOrDefault(x => x.Out_Patient_ID == outPatientId);
                    if (existing != null)
                    {
                        var plans = db.Physiotherapy_Treatment_Plans.Where(x => x.Physio_ID == existing.Physio_ID).ToList();
                    var romRows = db.Physiotherapy_ROMs.Where(x => x.Physio_ID == existing.Physio_ID).ToList();
                        var loadData = BuildAssessmentLoadData(existing, plans, romRows);
                        script += "setTimeout(function(){ populateAssessment(" + _json.Serialize(loadData) + "); }, 100);";
                    }

                    ClientScript.RegisterStartupScript(GetType(), "loadPatient", script, true);
                }
            }
        }

        private object BuildAssessmentLoadData(PMS.Physiotherapy_Assessment entity, List<PMS.Physiotherapy_Treatment_Plan> plans = null, List<PMS.Physiotherapy_ROM> romRows = null)
        {
            string pv(List<PMS.Physiotherapy_Treatment_Plan> list, string mod, string field)
            {
                var p = list?.FirstOrDefault(x => x.Modality == mod);
                if (p == null) return null;
                switch (field)
                {
                    case "details": return p.Details;
                    case "duration": return p.Duration;
                    case "freq": return p.Frequency;
                    case "intensity": return p.Intensity;
                    case "start": return p.Start_Date?.ToString("dd/MM/yyyy");
                    case "end": return p.End_Date?.ToString("dd/MM/yyyy");
                    default: return null;
                }
            }
            string rv(List<PMS.Physiotherapy_ROM> list, string mov, string side)
            {
                var r = list?.FirstOrDefault(x => x.Movement == mov);
                if (r == null) return null;
                return side == "L" ? r.Left_Value : r.Right_Value;
            }
            return new
            {
                occupation = entity.Occupation,
                reasonForReferral = entity.Reason_For_Referral,
                chiefComplaint = entity.Chief_Complaint,
                duration = entity.CC_Duration,
                onset = entity.CC_Onset,
                mode = entity.CC_Mode,
                condDiabetes = entity.Cond_Diabetes,
                condHypertension = entity.Cond_Hypertension,
                condCardiac = entity.Cond_Cardiac,
                condSurgery = entity.Cond_Surgery,
                condNeuro = entity.Cond_Neuro,
                condResp = entity.Cond_Resp,
                condThyroid = entity.Cond_Thyroid,
                condArthritis = entity.Cond_Arthritis,
                condOther = entity.Cond_Other,
                condOtherSpec = entity.Cond_Other_Spec,
                surgicalHistory = entity.Surgical_History,
                currentMedications = entity.Current_Medications,
                allergies = entity.Allergies,
                painScale = entity.Pain_Scale,
                painType = entity.Pain_Type,
                bodyChartJson = entity.Body_Chart_JSON,
                postNormal = entity.Post_Normal, postKyphosis = entity.Post_Kyphosis,
                postLordosis = entity.Post_Lordosis, postScoliosis = entity.Post_Scoliosis,
                postAntalgic = entity.Post_Antalgic, postOther = entity.Post_Other,
                postOtherSpec = entity.Post_Other_Spec,
                mmtRight = entity.MMT_Right, mmtLeft = entity.MMT_Left,
                mmtUpperLimb = entity.MMT_Upper_Limb, mmtLowerLimb = entity.MMT_Lower_Limb,
                areaNeck = entity.Area_Neck, areaShoulder = entity.Area_Shoulder,
                areaElbow = entity.Area_Elbow, areaWrist = entity.Area_Wrist,
                areaBack = entity.Area_Back, areaHip = entity.Area_Hip,
                areaKnee = entity.Area_Knee, areaAnkle = entity.Area_Ankle,
                areaOther = entity.Area_Other, areaOtherSpec = entity.Area_Other_Spec,
                aggravatingFactors = entity.Aggravating_Factors,
                relMedication = entity.Rel_Medication, relRest = entity.Rel_Rest,
                relExercise = entity.Rel_Exercise, relOther = entity.Rel_Other,
                relOtherSpec = entity.Rel_Other_Spec,
                sensIntact = entity.Sens_Intact, sensReduced = entity.Sens_Reduced,
                sensAbsent = entity.Sens_Absent, sensHyperalgesia = entity.Sens_Hyperalgesia,
                sensAllodynia = entity.Sens_Allodynia,
                refNormal = entity.Ref_Normal, refDecreased = entity.Ref_Decreased,
                refIncreased = entity.Ref_Increased, refAbsent = entity.Ref_Absent,
                refOther = entity.Ref_Other, refOtherSpec = entity.Ref_Other_Spec,
                specialTests = entity.Special_Tests,
                palpWarmth = entity.Palp_Warmth, palpTenderness = entity.Palp_Tenderness,
                palpCrepitus = entity.Palp_Crepitus, palpSwelling = entity.Palp_Swelling,
                palpSpasm = entity.Palp_Spasm, palpTemperature = entity.Palp_Temperature,
                palpOther = entity.Palp_Other, palpOtherSpec = entity.Palp_Other_Spec,
                dermatomeMyotome = entity.Dermatome_Myotome,
                redTENS = entity.Red_TENS, redEMS = entity.Red_EMS, redUS = entity.Red_US,
                redHeat = entity.Red_Heat, redCold = entity.Red_Cold,
                redTraction = entity.Red_Traction, redMobilization = entity.Red_Mobilization,
                redExercise = entity.Red_Exercise, redOther = entity.Red_Other,
                redOtherSpec = entity.Red_Other_Spec,
                redFracture = entity.Red_Fracture, redCancer = entity.Red_Cancer,
                redPacemaker = entity.Red_Pacemaker, redPregnancy = entity.Red_Pregnancy,
                redThrombosis = entity.Red_Thrombosis, redInfection = entity.Red_Infection,
                redBladderBowel = entity.Red_Bladder_Bowel,
                diagnosis = entity.Diagnosis,
                diagCervical = entity.Diag_Cervical, diagThoracic = entity.Diag_Thoracic,
                diagLumbar = entity.Diag_Lumbar, diagShoulder = entity.Diag_Shoulder,
                diagElbow = entity.Diag_Elbow, diagWrist = entity.Diag_Wrist,
                diagHip = entity.Diag_Hip, diagKnee = entity.Diag_Knee,
                diagAnkle = entity.Diag_Ankle,
                shortTermGoals = entity.Short_Term_Goals,
                longTermGoals = entity.Long_Term_Goals,
                homeExerciseProgram = entity.Home_Exercise_Program,
                patientEducation = entity.Patient_Education,
                nextReviewDate = entity.Next_Review_Date?.ToString("dd/MM/yyyy"),
                reviewedBy = entity.Reviewed_By,
                reviewNotes = entity.Review_Notes,
                romFlexL = rv(romRows, "Flexion", "L"), romFlexR = rv(romRows, "Flexion", "R"),
                romExtL = rv(romRows, "Extension", "L"), romExtR = rv(romRows, "Extension", "R"),
                romAbdL = rv(romRows, "Abduction", "L"), romAbdR = rv(romRows, "Abduction", "R"),
                romAddL = rv(romRows, "Adduction", "L"), romAddR = rv(romRows, "Adduction", "R"),
                romRotL = rv(romRows, "Rotation", "L"), romRotR = rv(romRows, "Rotation", "R"),
                ulGrade0 = entity.UL_Grade_0, ulGrade1 = entity.UL_Grade_1,
                ulGrade2 = entity.UL_Grade_2, ulGrade3 = entity.UL_Grade_3,
                ulGrade4 = entity.UL_Grade_4, ulGrade5 = entity.UL_Grade_5,
                llGrade0 = entity.LL_Grade_0, llGrade1 = entity.LL_Grade_1,
                llGrade2 = entity.LL_Grade_2, llGrade3 = entity.LL_Grade_3,
                llGrade4 = entity.LL_Grade_4, llGrade5 = entity.LL_Grade_5,
                txExSel = plans?.Any(p => p.Modality == "Therapeutic Exercise"),
                txExDetails = pv(plans, "Therapeutic Exercise", "details"),
                txExDuration = pv(plans, "Therapeutic Exercise", "duration"),
                txExFreq = pv(plans, "Therapeutic Exercise", "freq"),
                txExIntensity = pv(plans, "Therapeutic Exercise", "intensity"),
                txExStart = pv(plans, "Therapeutic Exercise", "start"),
                txExEnd = pv(plans, "Therapeutic Exercise", "end"),
                txElSel = plans?.Any(p => p.Modality == "Electrotherapy"),
                txElDetails = pv(plans, "Electrotherapy", "details"),
                txElDuration = pv(plans, "Electrotherapy", "duration"),
                txElFreq = pv(plans, "Electrotherapy", "freq"),
                txElIntensity = pv(plans, "Electrotherapy", "intensity"),
                txElStart = pv(plans, "Electrotherapy", "start"),
                txElEnd = pv(plans, "Electrotherapy", "end"),
                txManSel = plans?.Any(p => p.Modality == "Manual Therapy"),
                txManDetails = pv(plans, "Manual Therapy", "details"),
                txManDuration = pv(plans, "Manual Therapy", "duration"),
                txManFreq = pv(plans, "Manual Therapy", "freq"),
                txManIntensity = pv(plans, "Manual Therapy", "intensity"),
                txManStart = pv(plans, "Manual Therapy", "start"),
                txManEnd = pv(plans, "Manual Therapy", "end"),
                txOthSel = plans?.Any(p => p.Modality == "Other Modalities"),
                txOthDetails = pv(plans, "Other Modalities", "details"),
                txOthDuration = pv(plans, "Other Modalities", "duration"),
                txOthFreq = pv(plans, "Other Modalities", "freq"),
                txOthIntensity = pv(plans, "Other Modalities", "intensity"),
                txOthStart = pv(plans, "Other Modalities", "start"),
                txOthEnd = pv(plans, "Other Modalities", "end")
            };
        }

        private string GetDisplayName(DataBaseDataContext db, string valueSet, string valueName)
        {
            if (string.IsNullOrEmpty(valueName)) return "";
            return db.GetDataValueName(valueSet, valueName) ?? valueName;
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object LoadAssessment(int outPatientId)
        {
            using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var entity = db.Physiotherapy_Assessments.FirstOrDefault(x => x.Out_Patient_ID == outPatientId);
                if (entity == null) return null;

                var plans = db.Physiotherapy_Treatment_Plans.Where(x => x.Physio_ID == entity.Physio_ID).ToList();
                var romRows = db.Physiotherapy_ROMs.Where(x => x.Physio_ID == entity.Physio_ID).ToList();

                return new
                {
                    physioId = entity.Physio_ID,
                    occupation = entity.Occupation,
                    reasonForReferral = entity.Reason_For_Referral,
                    chiefComplaint = entity.Chief_Complaint,
                    duration = entity.CC_Duration,
                    onset = entity.CC_Onset,
                    mode = entity.CC_Mode,
                    condDiabetes = entity.Cond_Diabetes,
                    condHypertension = entity.Cond_Hypertension,
                    condCardiac = entity.Cond_Cardiac,
                    condSurgery = entity.Cond_Surgery,
                    condNeuro = entity.Cond_Neuro,
                    condResp = entity.Cond_Resp,
                    condThyroid = entity.Cond_Thyroid,
                    condArthritis = entity.Cond_Arthritis,
                    condOther = entity.Cond_Other,
                    condOtherSpec = entity.Cond_Other_Spec,
                    surgicalHistory = entity.Surgical_History,
                    currentMedications = entity.Current_Medications,
                    allergies = entity.Allergies,
                    painScale = entity.Pain_Scale,
                    painType = entity.Pain_Type,
                    bodyChartJson = entity.Body_Chart_JSON != null ? entity.Body_Chart_JSON : "{\"front\":[],\"back\":[]}",
                    postNormal = entity.Post_Normal, postKyphosis = entity.Post_Kyphosis,
                    postLordosis = entity.Post_Lordosis, postScoliosis = entity.Post_Scoliosis,
                    postAntalgic = entity.Post_Antalgic, postOther = entity.Post_Other,
                    postOtherSpec = entity.Post_Other_Spec,
                    mmtRight = entity.MMT_Right, mmtLeft = entity.MMT_Left,
                    mmtUpperLimb = entity.MMT_Upper_Limb, mmtLowerLimb = entity.MMT_Lower_Limb,
                    areaNeck = entity.Area_Neck, areaShoulder = entity.Area_Shoulder,
                    areaElbow = entity.Area_Elbow, areaWrist = entity.Area_Wrist,
                    areaBack = entity.Area_Back, areaHip = entity.Area_Hip,
                    areaKnee = entity.Area_Knee, areaAnkle = entity.Area_Ankle,
                    areaOther = entity.Area_Other, areaOtherSpec = entity.Area_Other_Spec,
                    aggravatingFactors = entity.Aggravating_Factors,
                    relMedication = entity.Rel_Medication, relRest = entity.Rel_Rest,
                    relExercise = entity.Rel_Exercise, relOther = entity.Rel_Other,
                    relOtherSpec = entity.Rel_Other_Spec,
                    sensIntact = entity.Sens_Intact, sensReduced = entity.Sens_Reduced,
                    sensAbsent = entity.Sens_Absent, sensHyperalgesia = entity.Sens_Hyperalgesia,
                    sensAllodynia = entity.Sens_Allodynia,
                    refNormal = entity.Ref_Normal, refDecreased = entity.Ref_Decreased,
                    refIncreased = entity.Ref_Increased, refAbsent = entity.Ref_Absent,
                    refOther = entity.Ref_Other, refOtherSpec = entity.Ref_Other_Spec,
                    specialTests = entity.Special_Tests,
                    palpWarmth = entity.Palp_Warmth, palpTenderness = entity.Palp_Tenderness,
                    palpCrepitus = entity.Palp_Crepitus, palpSwelling = entity.Palp_Swelling,
                    palpSpasm = entity.Palp_Spasm, palpTemperature = entity.Palp_Temperature,
                    palpOther = entity.Palp_Other, palpOtherSpec = entity.Palp_Other_Spec,
                    dermatomeMyotome = entity.Dermatome_Myotome,
                    redTENS = entity.Red_TENS, redEMS = entity.Red_EMS, redUS = entity.Red_US,
                    redHeat = entity.Red_Heat, redCold = entity.Red_Cold,
                    redTraction = entity.Red_Traction, redMobilization = entity.Red_Mobilization,
                    redExercise = entity.Red_Exercise, redOther = entity.Red_Other,
                    redOtherSpec = entity.Red_Other_Spec,
                    redFracture = entity.Red_Fracture, redCancer = entity.Red_Cancer,
                    redPacemaker = entity.Red_Pacemaker, redPregnancy = entity.Red_Pregnancy,
                    redThrombosis = entity.Red_Thrombosis, redInfection = entity.Red_Infection,
                    redBladderBowel = entity.Red_Bladder_Bowel,
                    diagnosis = entity.Diagnosis,
                    diagCervical = entity.Diag_Cervical, diagThoracic = entity.Diag_Thoracic,
                    diagLumbar = entity.Diag_Lumbar, diagShoulder = entity.Diag_Shoulder,
                    diagElbow = entity.Diag_Elbow, diagWrist = entity.Diag_Wrist,
                    diagHip = entity.Diag_Hip, diagKnee = entity.Diag_Knee,
                    diagAnkle = entity.Diag_Ankle,
                    shortTermGoals = entity.Short_Term_Goals,
                    longTermGoals = entity.Long_Term_Goals,
                    homeExerciseProgram = entity.Home_Exercise_Program,
                    patientEducation = entity.Patient_Education,
                    nextReviewDate = entity.Next_Review_Date?.ToString("dd/MM/yyyy"),
                    reviewedBy = entity.Reviewed_By,
                    reviewNotes = entity.Review_Notes,
                    romFlexL = romRows.Where(r => r.Movement == "Flexion").Select(r => r.Left_Value).FirstOrDefault(),
                    romFlexR = romRows.Where(r => r.Movement == "Flexion").Select(r => r.Right_Value).FirstOrDefault(),
                    romExtL = romRows.Where(r => r.Movement == "Extension").Select(r => r.Left_Value).FirstOrDefault(),
                    romExtR = romRows.Where(r => r.Movement == "Extension").Select(r => r.Right_Value).FirstOrDefault(),
                    romAbdL = romRows.Where(r => r.Movement == "Abduction").Select(r => r.Left_Value).FirstOrDefault(),
                    romAbdR = romRows.Where(r => r.Movement == "Abduction").Select(r => r.Right_Value).FirstOrDefault(),
                    romAddL = romRows.Where(r => r.Movement == "Adduction").Select(r => r.Left_Value).FirstOrDefault(),
                    romAddR = romRows.Where(r => r.Movement == "Adduction").Select(r => r.Right_Value).FirstOrDefault(),
                    romRotL = romRows.Where(r => r.Movement == "Rotation").Select(r => r.Left_Value).FirstOrDefault(),
                    romRotR = romRows.Where(r => r.Movement == "Rotation").Select(r => r.Right_Value).FirstOrDefault(),
                    ulGrade0 = entity.UL_Grade_0, ulGrade1 = entity.UL_Grade_1,
                    ulGrade2 = entity.UL_Grade_2, ulGrade3 = entity.UL_Grade_3,
                    ulGrade4 = entity.UL_Grade_4, ulGrade5 = entity.UL_Grade_5,
                    llGrade0 = entity.LL_Grade_0, llGrade1 = entity.LL_Grade_1,
                    llGrade2 = entity.LL_Grade_2, llGrade3 = entity.LL_Grade_3,
                    llGrade4 = entity.LL_Grade_4, llGrade5 = entity.LL_Grade_5,
                    txExSel = plans.Any(p => p.Modality == "Therapeutic Exercise"),
                    txExDetails = plans.Where(p => p.Modality == "Therapeutic Exercise").Select(p => p.Details).FirstOrDefault(),
                    txExDuration = plans.Where(p => p.Modality == "Therapeutic Exercise").Select(p => p.Duration).FirstOrDefault(),
                    txExFreq = plans.Where(p => p.Modality == "Therapeutic Exercise").Select(p => p.Frequency).FirstOrDefault(),
                    txExIntensity = plans.Where(p => p.Modality == "Therapeutic Exercise").Select(p => p.Intensity).FirstOrDefault(),
                    txExStart = plans.Where(p => p.Modality == "Therapeutic Exercise").Select(p => p.Start_Date?.ToString("dd/MM/yyyy")).FirstOrDefault(),
                    txExEnd = plans.Where(p => p.Modality == "Therapeutic Exercise").Select(p => p.End_Date?.ToString("dd/MM/yyyy")).FirstOrDefault(),
                    txElSel = plans.Any(p => p.Modality == "Electrotherapy"),
                    txElDetails = plans.Where(p => p.Modality == "Electrotherapy").Select(p => p.Details).FirstOrDefault(),
                    txElDuration = plans.Where(p => p.Modality == "Electrotherapy").Select(p => p.Duration).FirstOrDefault(),
                    txElFreq = plans.Where(p => p.Modality == "Electrotherapy").Select(p => p.Frequency).FirstOrDefault(),
                    txElIntensity = plans.Where(p => p.Modality == "Electrotherapy").Select(p => p.Intensity).FirstOrDefault(),
                    txElStart = plans.Where(p => p.Modality == "Electrotherapy").Select(p => p.Start_Date?.ToString("dd/MM/yyyy")).FirstOrDefault(),
                    txElEnd = plans.Where(p => p.Modality == "Electrotherapy").Select(p => p.End_Date?.ToString("dd/MM/yyyy")).FirstOrDefault(),
                    txManSel = plans.Any(p => p.Modality == "Manual Therapy"),
                    txManDetails = plans.Where(p => p.Modality == "Manual Therapy").Select(p => p.Details).FirstOrDefault(),
                    txManDuration = plans.Where(p => p.Modality == "Manual Therapy").Select(p => p.Duration).FirstOrDefault(),
                    txManFreq = plans.Where(p => p.Modality == "Manual Therapy").Select(p => p.Frequency).FirstOrDefault(),
                    txManIntensity = plans.Where(p => p.Modality == "Manual Therapy").Select(p => p.Intensity).FirstOrDefault(),
                    txManStart = plans.Where(p => p.Modality == "Manual Therapy").Select(p => p.Start_Date?.ToString("dd/MM/yyyy")).FirstOrDefault(),
                    txManEnd = plans.Where(p => p.Modality == "Manual Therapy").Select(p => p.End_Date?.ToString("dd/MM/yyyy")).FirstOrDefault(),
                    txOthSel = plans.Any(p => p.Modality == "Other Modalities"),
                    txOthDetails = plans.Where(p => p.Modality == "Other Modalities").Select(p => p.Details).FirstOrDefault(),
                    txOthDuration = plans.Where(p => p.Modality == "Other Modalities").Select(p => p.Duration).FirstOrDefault(),
                    txOthFreq = plans.Where(p => p.Modality == "Other Modalities").Select(p => p.Frequency).FirstOrDefault(),
                    txOthIntensity = plans.Where(p => p.Modality == "Other Modalities").Select(p => p.Intensity).FirstOrDefault(),
                    txOthStart = plans.Where(p => p.Modality == "Other Modalities").Select(p => p.Start_Date?.ToString("dd/MM/yyyy")).FirstOrDefault(),
                    txOthEnd = plans.Where(p => p.Modality == "Other Modalities").Select(p => p.End_Date?.ToString("dd/MM/yyyy")).FirstOrDefault()
                };
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object SaveAssessment(int outPatientId, int regPatId, string formData)
        {
            using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var serializer = new JavaScriptSerializer();
                var data = serializer.Deserialize<AssessmentFormData>(formData);

                var existing = db.Physiotherapy_Assessments.FirstOrDefault(x => x.Out_Patient_ID == outPatientId);
                bool isNew = (existing == null);

                var entity = existing ?? new PMS.Physiotherapy_Assessment();
                var userId = AppConfig.UserID;

                if (isNew)
                {
                    entity.Out_Patient_ID = outPatientId;
                    entity.Reg_Pat_ID = regPatId;
                    entity.Created_By = userId;
                    entity.Created_Time = DateTime.Now;
                    if (!string.IsNullOrEmpty(data.assessmentDate))
                    {
                        DateTime dt;
                        if (DateTime.TryParseExact(data.assessmentDate, "dd/MM/yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dt))
                            entity.Assessment_Date = dt;
                    }
                    db.Physiotherapy_Assessments.InsertOnSubmit(entity);
                }
                else
                {
                    entity.Updated_By = userId;
                    entity.Updated_Time = DateTime.Now;
                }

                string val(string s) => string.IsNullOrEmpty(s) ? null : s;
                bool? bval(bool? v) => v.HasValue && v.Value ? (bool?)true : null;
                int? ival(int? v) => v.HasValue ? v : null;

                entity.Occupation = val(data.occupation);
                entity.Reason_For_Referral = val(data.reasonForReferral);
                entity.Chief_Complaint = val(data.chiefComplaint);
                entity.CC_Duration = val(data.duration);
                entity.CC_Onset = val(data.onset);
                entity.CC_Mode = val(data.mode);

                entity.Cond_Diabetes = bval(data.condDiabetes);
                entity.Cond_Hypertension = bval(data.condHypertension);
                entity.Cond_Cardiac = bval(data.condCardiac);
                entity.Cond_Surgery = bval(data.condSurgery);
                entity.Cond_Neuro = bval(data.condNeuro);
                entity.Cond_Resp = bval(data.condResp);
                entity.Cond_Thyroid = bval(data.condThyroid);
                entity.Cond_Arthritis = bval(data.condArthritis);
                entity.Cond_Other = bval(data.condOther);
                entity.Cond_Other_Spec = val(data.condOtherSpec);
                entity.Surgical_History = val(data.surgicalHistory);
                entity.Current_Medications = val(data.currentMedications);
                entity.Allergies = val(data.allergies);

                entity.Pain_Scale = ival(data.painScale);
                entity.Pain_Type = val(data.painType);
                entity.Body_Chart_JSON = val(data.bodyChartJson);

                entity.Post_Normal = bval(data.postNormal);
                entity.Post_Kyphosis = bval(data.postKyphosis);
                entity.Post_Lordosis = bval(data.postLordosis);
                entity.Post_Scoliosis = bval(data.postScoliosis);
                entity.Post_Antalgic = bval(data.postAntalgic);
                entity.Post_Other = bval(data.postOther);
                entity.Post_Other_Spec = val(data.postOtherSpec);

                entity.MMT_Right = val(data.mmtRight);
                entity.MMT_Left = val(data.mmtLeft);
                entity.MMT_Upper_Limb = val(data.mmtUpperLimb);
                entity.MMT_Lower_Limb = val(data.mmtLowerLimb);

                entity.Area_Neck = bval(data.areaNeck);
                entity.Area_Shoulder = bval(data.areaShoulder);
                entity.Area_Elbow = bval(data.areaElbow);
                entity.Area_Wrist = bval(data.areaWrist);
                entity.Area_Back = bval(data.areaBack);
                entity.Area_Hip = bval(data.areaHip);
                entity.Area_Knee = bval(data.areaKnee);
                entity.Area_Ankle = bval(data.areaAnkle);
                entity.Area_Other = bval(data.areaOther);
                entity.Area_Other_Spec = val(data.areaOtherSpec);
                entity.Aggravating_Factors = val(data.aggravatingFactors);

                entity.Rel_Medication = bval(data.relMedication);
                entity.Rel_Rest = bval(data.relRest);
                entity.Rel_Exercise = bval(data.relExercise);
                entity.Rel_Other = bval(data.relOther);
                entity.Rel_Other_Spec = val(data.relOtherSpec);

                entity.Sens_Intact = bval(data.sensIntact);
                entity.Sens_Reduced = bval(data.sensReduced);
                entity.Sens_Absent = bval(data.sensAbsent);
                entity.Sens_Hyperalgesia = bval(data.sensHyperalgesia);
                entity.Sens_Allodynia = bval(data.sensAllodynia);

                entity.Ref_Normal = bval(data.refNormal);
                entity.Ref_Decreased = bval(data.refDecreased);
                entity.Ref_Increased = bval(data.refIncreased);
                entity.Ref_Absent = bval(data.refAbsent);
                entity.Ref_Other = bval(data.refOther);
                entity.Ref_Other_Spec = val(data.refOtherSpec);
                entity.Special_Tests = val(data.specialTests);

                entity.Palp_Warmth = bval(data.palpWarmth);
                entity.Palp_Tenderness = bval(data.palpTenderness);
                entity.Palp_Crepitus = bval(data.palpCrepitus);
                entity.Palp_Swelling = bval(data.palpSwelling);
                entity.Palp_Spasm = bval(data.palpSpasm);
                entity.Palp_Temperature = bval(data.palpTemperature);
                entity.Palp_Other = bval(data.palpOther);
                entity.Palp_Other_Spec = val(data.palpOtherSpec);
                entity.Dermatome_Myotome = val(data.dermatomeMyotome);

                entity.Red_TENS = bval(data.redTENS);
                entity.Red_EMS = bval(data.redEMS);
                entity.Red_US = bval(data.redUS);
                entity.Red_Heat = bval(data.redHeat);
                entity.Red_Cold = bval(data.redCold);
                entity.Red_Traction = bval(data.redTraction);
                entity.Red_Mobilization = bval(data.redMobilization);
                entity.Red_Exercise = bval(data.redExercise);
                entity.Red_Fracture = bval(data.redFracture);
                entity.Red_Cancer = bval(data.redCancer);
                entity.Red_Pacemaker = bval(data.redPacemaker);
                entity.Red_Pregnancy = bval(data.redPregnancy);
                entity.Red_Thrombosis = bval(data.redThrombosis);
                entity.Red_Infection = bval(data.redInfection);
                entity.Red_Bladder_Bowel = bval(data.redBladderBowel);
                entity.Red_Other = bval(data.redOther);
                entity.Red_Other_Spec = val(data.redOtherSpec);

                entity.Diagnosis = val(data.diagnosis);
                entity.Diag_Cervical = val(data.diagCervical);
                entity.Diag_Thoracic = val(data.diagThoracic);
                entity.Diag_Lumbar = val(data.diagLumbar);
                entity.Diag_Shoulder = val(data.diagShoulder);
                entity.Diag_Elbow = val(data.diagElbow);
                entity.Diag_Wrist = val(data.diagWrist);
                entity.Diag_Hip = val(data.diagHip);
                entity.Diag_Knee = val(data.diagKnee);
                entity.Diag_Ankle = val(data.diagAnkle);

                entity.Short_Term_Goals = val(data.shortTermGoals);
                entity.Long_Term_Goals = val(data.longTermGoals);
                entity.Home_Exercise_Program = val(data.homeExerciseProgram);
                entity.Patient_Education = val(data.patientEducation);

                if (!string.IsNullOrEmpty(data.nextReviewDate))
                {
                    DateTime dt;
                    if (DateTime.TryParseExact(data.nextReviewDate, "dd/MM/yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out dt))
                        entity.Next_Review_Date = dt;
                }
                entity.Reviewed_By = data.reviewedBy;
                entity.Review_Notes = val(data.reviewNotes);

                db.SubmitChanges();

                var oldRows = db.Physiotherapy_ROMs.Where(x => x.Physio_ID == entity.Physio_ID);
                db.Physiotherapy_ROMs.DeleteAllOnSubmit(oldRows);
                db.SubmitChanges();

                void addROM(string mov, string l, string r)
                {
                    var row = new PMS.Physiotherapy_ROM
                    {
                        Physio_ID = entity.Physio_ID,
                        Movement = mov,
                        Left_Value = val(l),
                        Right_Value = val(r)
                    };
                    db.Physiotherapy_ROMs.InsertOnSubmit(row);
                }
                addROM("Flexion", data.romFlexL, data.romFlexR);
                addROM("Extension", data.romExtL, data.romExtR);
                addROM("Abduction", data.romAbdL, data.romAbdR);
                addROM("Adduction", data.romAddL, data.romAddR);
                addROM("Rotation", data.romRotL, data.romRotR);

                entity.UL_Grade_0 = bval(data.ulGrade0);
                entity.UL_Grade_1 = bval(data.ulGrade1);
                entity.UL_Grade_2 = bval(data.ulGrade2);
                entity.UL_Grade_3 = bval(data.ulGrade3);
                entity.UL_Grade_4 = bval(data.ulGrade4);
                entity.UL_Grade_5 = bval(data.ulGrade5);
                entity.LL_Grade_0 = bval(data.llGrade0);
                entity.LL_Grade_1 = bval(data.llGrade1);
                entity.LL_Grade_2 = bval(data.llGrade2);
                entity.LL_Grade_3 = bval(data.llGrade3);
                entity.LL_Grade_4 = bval(data.llGrade4);
                entity.LL_Grade_5 = bval(data.llGrade5);

                db.SubmitChanges();

                var oldPlans = db.Physiotherapy_Treatment_Plans.Where(x => x.Physio_ID == entity.Physio_ID);
                db.Physiotherapy_Treatment_Plans.DeleteAllOnSubmit(oldPlans);
                db.SubmitChanges();

                DateTime? pdt(string s) { DateTime d; return DateTime.TryParseExact(s, "dd/MM/yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out d) ? d : (DateTime?)null; }
                void addPlan(string mod, string det, string dur, string freq, string intens, string st, string en)
                {
                    var plan = new PMS.Physiotherapy_Treatment_Plan
                    {
                        Physio_ID = entity.Physio_ID,
                        Modality = mod,
                        Details = val(det),
                        Duration = val(dur),
                        Frequency = val(freq),
                        Intensity = val(intens),
                        Start_Date = pdt(st),
                        End_Date = pdt(en)
                    };
                    db.Physiotherapy_Treatment_Plans.InsertOnSubmit(plan);
                }
                if (data.txExSel == true) addPlan("Therapeutic Exercise", data.txExDetails, data.txExDuration, data.txExFreq, data.txExIntensity, data.txExStart, data.txExEnd);
                if (data.txElSel == true) addPlan("Electrotherapy", data.txElDetails, data.txElDuration, data.txElFreq, data.txElIntensity, data.txElStart, data.txElEnd);
                if (data.txManSel == true) addPlan("Manual Therapy", data.txManDetails, data.txManDuration, data.txManFreq, data.txManIntensity, data.txManStart, data.txManEnd);
                if (data.txOthSel == true) addPlan("Other Modalities", data.txOthDetails, data.txOthDuration, data.txOthFreq, data.txOthIntensity, data.txOthStart, data.txOthEnd);

                db.SubmitChanges();

                return new { success = true, physioId = entity.Physio_ID, isNew = isNew };
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object LoadDoctors()
        {
            using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var doctors = db.HR_Employees
                    .Where(x => x.IsDoctor == true)
                    .Select(x => new { x.Emp_ID, x.Emp_Name })
                    .ToList();
                return doctors;
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object LoadDataValues(string valueSetName)
        {
            using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var items = (from vs in db.ValueSets
                             join dv in db.DataValues on vs.ValueSet_ID equals dv.ValueSet_ID
                             where vs.ValueSet_Name == valueSetName
                             select new { dv.DataValue_Name, dv.DataValue_Description })
                             .ToList();
                return items;
            }
        }

        public class AssessmentFormData
        {
            public string assessmentDate { get; set; }
            public string occupation { get; set; }
            public string reasonForReferral { get; set; }
            public string chiefComplaint { get; set; }
            public string duration { get; set; }
            public string onset { get; set; }
            public string mode { get; set; }
            public bool? condDiabetes { get; set; }
            public bool? condHypertension { get; set; }
            public bool? condCardiac { get; set; }
            public bool? condSurgery { get; set; }
            public bool? condNeuro { get; set; }
            public bool? condResp { get; set; }
            public bool? condThyroid { get; set; }
            public bool? condArthritis { get; set; }
            public bool? condOther { get; set; }
            public string condOtherSpec { get; set; }
            public string surgicalHistory { get; set; }
            public string currentMedications { get; set; }
            public string allergies { get; set; }
            public int? painScale { get; set; }
            public string painType { get; set; }
            public string bodyChartJson { get; set; }
            public bool? postNormal { get; set; }
            public bool? postKyphosis { get; set; }
            public bool? postLordosis { get; set; }
            public bool? postScoliosis { get; set; }
            public bool? postAntalgic { get; set; }
            public bool? postOther { get; set; }
            public string postOtherSpec { get; set; }
            public string mmtRight { get; set; }
            public string mmtLeft { get; set; }
            public string mmtUpperLimb { get; set; }
            public string mmtLowerLimb { get; set; }
            public bool? areaNeck { get; set; }
            public bool? areaShoulder { get; set; }
            public bool? areaElbow { get; set; }
            public bool? areaWrist { get; set; }
            public bool? areaBack { get; set; }
            public bool? areaHip { get; set; }
            public bool? areaKnee { get; set; }
            public bool? areaAnkle { get; set; }
            public bool? areaOther { get; set; }
            public string areaOtherSpec { get; set; }
            public string aggravatingFactors { get; set; }
            public bool? relMedication { get; set; }
            public bool? relRest { get; set; }
            public bool? relExercise { get; set; }
            public bool? relOther { get; set; }
            public string relOtherSpec { get; set; }
            public bool? sensIntact { get; set; }
            public bool? sensReduced { get; set; }
            public bool? sensAbsent { get; set; }
            public bool? sensHyperalgesia { get; set; }
            public bool? sensAllodynia { get; set; }
            public bool? refNormal { get; set; }
            public bool? refDecreased { get; set; }
            public bool? refIncreased { get; set; }
            public bool? refAbsent { get; set; }
            public bool? refOther { get; set; }
            public string refOtherSpec { get; set; }
            public string specialTests { get; set; }
            public bool? palpWarmth { get; set; }
            public bool? palpTenderness { get; set; }
            public bool? palpCrepitus { get; set; }
            public bool? palpSwelling { get; set; }
            public bool? palpSpasm { get; set; }
            public bool? palpTemperature { get; set; }
            public bool? palpOther { get; set; }
            public string palpOtherSpec { get; set; }
            public string dermatomeMyotome { get; set; }
            public bool? redTENS { get; set; }
            public bool? redEMS { get; set; }
            public bool? redUS { get; set; }
            public bool? redHeat { get; set; }
            public bool? redCold { get; set; }
            public bool? redTraction { get; set; }
            public bool? redMobilization { get; set; }
            public bool? redExercise { get; set; }
            public bool? redFracture { get; set; }
            public bool? redCancer { get; set; }
            public bool? redPacemaker { get; set; }
            public bool? redPregnancy { get; set; }
            public bool? redThrombosis { get; set; }
            public bool? redInfection { get; set; }
            public bool? redBladderBowel { get; set; }
            public bool? redOther { get; set; }
            public string redOtherSpec { get; set; }
            public string diagnosis { get; set; }
            public string diagCervical { get; set; }
            public string diagThoracic { get; set; }
            public string diagLumbar { get; set; }
            public string diagShoulder { get; set; }
            public string diagElbow { get; set; }
            public string diagWrist { get; set; }
            public string diagHip { get; set; }
            public string diagKnee { get; set; }
            public string diagAnkle { get; set; }
            public string shortTermGoals { get; set; }
            public string longTermGoals { get; set; }
            public string homeExerciseProgram { get; set; }
            public string patientEducation { get; set; }
            public string nextReviewDate { get; set; }
            public int? reviewedBy { get; set; }
            public string reviewNotes { get; set; }
            public bool? txExSel { get; set; }
            public string txExDetails { get; set; }
            public string txExDuration { get; set; }
            public string txExFreq { get; set; }
            public string txExIntensity { get; set; }
            public string txExStart { get; set; }
            public string txExEnd { get; set; }
            public bool? txElSel { get; set; }
            public string txElDetails { get; set; }
            public string txElDuration { get; set; }
            public string txElFreq { get; set; }
            public string txElIntensity { get; set; }
            public string txElStart { get; set; }
            public string txElEnd { get; set; }
            public bool? txManSel { get; set; }
            public string txManDetails { get; set; }
            public string txManDuration { get; set; }
            public string txManFreq { get; set; }
            public string txManIntensity { get; set; }
            public string txManStart { get; set; }
            public string txManEnd { get; set; }
            public bool? txOthSel { get; set; }
            public string txOthDetails { get; set; }
            public string txOthDuration { get; set; }
            public string txOthFreq { get; set; }
            public string txOthIntensity { get; set; }
            public string txOthStart { get; set; }
            public string txOthEnd { get; set; }
            public string romFlexL { get; set; }
            public string romFlexR { get; set; }
            public string romExtL { get; set; }
            public string romExtR { get; set; }
            public string romAbdL { get; set; }
            public string romAbdR { get; set; }
            public string romAddL { get; set; }
            public string romAddR { get; set; }
            public string romRotL { get; set; }
            public string romRotR { get; set; }
            public bool? ulGrade0 { get; set; }
            public bool? ulGrade1 { get; set; }
            public bool? ulGrade2 { get; set; }
            public bool? ulGrade3 { get; set; }
            public bool? ulGrade4 { get; set; }
            public bool? ulGrade5 { get; set; }
            public bool? llGrade0 { get; set; }
            public bool? llGrade1 { get; set; }
            public bool? llGrade2 { get; set; }
            public bool? llGrade3 { get; set; }
            public bool? llGrade4 { get; set; }
            public bool? llGrade5 { get; set; }
        }
    }
}
