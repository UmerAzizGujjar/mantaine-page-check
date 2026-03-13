using CrystalDecisions.CrystalReports.Engine;
using CrystalDecisions.Shared;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Threading;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;


namespace PMS
{
    public partial class EmergencyCase : System.Web.UI.Page
    {
        DataTable dt;
        DataBaseDataContext db;
        public static int InPatient_Case_id;
        public bool PatientDischargeStatus = false;
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
                txtDischarge_On.Text = DateTime.Now.ToString();
                LoadAllDoctors();
                BindingDropDown();
                BlankForm();
             

                if (Request.QueryString["ID"] != null)
                {
                    string QS = id.Split('=')[1];
                    PopulateGetEmergencyPatientData(Convert.ToInt32(QS));
                    InPatient_Case_id = Convert.ToInt32(QS);
                    ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "", "FillInstruction();", true);
                }
            }
            else
            {
            }
        }
        [WebMethod]
        public static string GetPatients(string searchValue)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var patients = (from p in db.Reg_patients
                                    where (p.mr_no_sequence != null && p.mr_no_sequence.ToString().Contains(searchValue))
                                          || (p.Full_Name != null && p.Full_Name.Contains(searchValue))
                                    select new
                                    {
                                        PatientNo = p.mr_no_sequence,
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
            ddlPerformed_By.DataSource = EmpList;
            ddlPerformed_By.DataTextField = "Emp_Name";
            ddlPerformed_By.DataValueField = "Emp_ID";
            ddlPerformed_By.Items.Add(new ListItem("Please Select", "0"));
            ddlPerformed_By.DataBind();

            valueset = DBClass.GetValueSet("Room Type");

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



            var wards = (from tbl2 in db.Ward_Definitions
                         where (tbl2.Ward_Type != null && tbl2.Ward_Type.ToLower().Contains("Emergency"))
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
        public static string checkEMRG_tabs()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var ups = (from St in db.aspnet_Users
                       where St.UserName == AppConfig.UserName
                       select St.Emergency_adm_dis).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(ups);
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
        public static List<PatientsResult> GetReferredPatients(string SearchString)
        {
            if (string.IsNullOrWhiteSpace(SearchString))
            {
                SearchString = "";
            }
            else
            {
                SearchString = SearchString.Replace("'", "''").Trim();
            }

            string baseSql = @"
                SELECT TOP 10  
                    rg.pat_id,
                    ISNULL(rg.mr_no_sequence, '') AS Patient_No,
                    ISNULL(rg.Full_Name, '') AS Full_Name,
                    ISNULL(rg.NIC, '') AS NIC,
                    ISNULL(rg.Mobile1, '') AS ContactNo,
                    ISNULL(rg.Father_Name, '') AS Father_Name 
                FROM reg_patient rg
                INNER JOIN Emergency_Patient Em ON rg.pat_id = Em.Patient_ID
                WHERE 
                    rg.Patient_No <> 0 
                    AND rg.Patient_No IS NOT NULL 
                    AND ISNULL(rg.isCancel, 0) != 1 
                    AND Em.ReferredTo = '001'";

            string whereClause = "";
            if (!string.IsNullOrEmpty(SearchString))
            {
                whereClause = $@" AND (
            LTRIM(RTRIM(rg.mr_no_sequence)) LIKE '%{SearchString}%' OR
            LTRIM(RTRIM(rg.Full_Name)) LIKE '%{SearchString}%' OR
            LTRIM(RTRIM(rg.NIC)) LIKE '%{SearchString}%' OR
            LTRIM(RTRIM(rg.Mobile1)) LIKE '%{SearchString}%'
              )";
            }

            string sql = baseSql + whereClause + " ORDER BY rg.pat_id DESC";

            DataTable dt = DBClass.getDataTable(sql);

            List<PatientsResult> list = new List<PatientsResult>();
            foreach (DataRow dr in dt.Rows)
            {
                list.Add(new PatientsResult
                {
                    Reg_Patient_ID = dr["pat_id"]?.ToString() ?? "",
                    Patient_No = dr["Patient_No"]?.ToString() ?? "",
                    Full_Name = dr["Full_Name"]?.ToString() ?? "",
                    NIC = dr["NIC"]?.ToString() ?? "",
                    Mobile1 = dr["ContactNo"]?.ToString() ?? "",
                    Father_Name = dr["Father_Name"]?.ToString() ?? ""
                });
            }

            return list;
        }

        [WebMethod]
        public static string CheckEditRights()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var ups = (from St in db.aspnet_Users
                       where St.UserId == AppConfig.UserID
                       select St.EditEmergency).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(ups);
        }
        [WebMethod]
        public static string CheckDiscountRights()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var ups = (from St in db.aspnet_Users
                       where St.UserId == AppConfig.UserID
                       select St.Allow_emer_disc).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(ups);
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

        public class PatientDetail_Reg
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
        }

        [WebMethod]
        public static PatientDetail_Reg GetEditPatientDetails(string Reg_Patient_ID)
        {
            PatientDetail_Reg pts = new PatientDetail_Reg();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Reg_patient pat = new Reg_patient();
            pat = (from tbl in db.Reg_patients
                   where tbl.pat_id == Convert.ToInt32(Reg_Patient_ID)
                   orderby tbl.Created_time descending
                   select tbl).FirstOrDefault();
            if (pat != null)
            {
                string[] PatientName = pat.Full_Name.Split('.');
                pts.Title = PatientName[0] + ".";
                pts.Name = PatientName[PatientName.Length - 1];
                pts.FatherName = pat.Father_Name;
                pts.Gender = pat.Gender;
                pts.Relation = pat.Relation_prefix;
                pts.DOB = Convert.ToDateTime(pat.DOB);
                pts.Age = pat.Age_years.ToString();
                pts.MaritalStatus = pat.Martial_Status;
                pts.Mr_No = Convert.ToString(pat.mr_no_sequence);
                pts.Address = pat.Permanent_Address;
                pts.Mobile = pat.Mobile1;
                pts.CNIC = pat.NIC;
                pts.Gender = pat.Gender;
                pts.Reg_PatientID = Reg_Patient_ID;
                return pts;
            }
            return pts;
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
            txttxtReceiving_DateDesc.Text= DateTime.Now.ToString();

            txtRN_Special_Instruction.Text = "";

            txtBP.Text = "";
            txtTemp.Text = "";
            txtRespiration.Text = "";

            ddlDepartment.SelectedIndex = 0;
            ddlDoctor.SelectedIndex = 0;

            txtOperation_No.Text = "";
            ddlPerformed_By.SelectedIndex = 0;
            txtBrief_Description.Text = "";
            txtSurgeon_Note.Text = "";
            txtPost_Operative_Care.Text = "";
            cbShifted_To_ICU.Checked = false;
            cbShifted_To_CCU.Checked = false;
            cbShifted_To_Observation_Room.Checked = false;
 
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

     

        private void PopulateGetEmergencyPatientData(int Emergency_ID)
        {
            try
            {
                db = new DataBaseDataContext(DBClass.ConnectionString());
                var qry = db.sp_GetEmergencyPatientDetail(Emergency_ID).FirstOrDefault();
                #region Old Code

                #endregion

                if (qry != null)
                {
                    ReferToOPD.Checked = Convert.ToBoolean(qry.Refer_To_OPD);
                    hdfPatient_ID.Value = qry.Patient_ID.ToString();
                    txtPatient_ID.Text = qry.Patient_ID.ToString();
                    txtIn_Patient_ID.Text = qry.Emergency_ID.ToString();
                    vlblPatients_Name.Text = qry.Full_Name;
                    vLbl_Contact.Text = qry.Mobile1;
                    vLbl_Adress.Text = qry.Permanent_Address;
                    vLbl_Gender.Text = db.GetDataValueName("Gender", qry.Gender);
                    vLbl_Age.Text = qry.Age_years;
                    //if (qry.Entry_Date == null)
                    //    vLbl_RegDate.Text = qry.Created_time.Value.ToString(AppConfig.DateFormat);
                    //else
                        //vLbl_RegDate.Text = qry.Entry_Date.Value.ToString(AppConfig.DateFormat);
                    vLbl_RegDate.Text = qry.Created_time.Value.ToString(AppConfig.DateFormat);
                    txtAdmission_Date.Text = qry.Admission_Date.Value.ToString();

                    txtRN_Special_Instruction.Text = qry.RN_Special_Instruction;
                    ddlIssuance_Of.SelectedValue = qry.Issuance_Of;
                    vLbl_Patient_Type.Text = db.GetDataValueName("Patient Type", qry.Patient_Type);
                    vLbl_Patient_AdmitCatagory.Text = db.GetDataValueName("Patient Type", qry.Patient_Discount_Type);
                    if (qry.Issuance_Of == "002")
                    {
                        
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
                    txtDiscount.Text = Convert.ToString(qry.Discount);
                    ddlCategory.SelectedValue = qry.Patient_Category;

                 

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

                    ddlRhythm.SelectedValue = qry.Emergency_Rhythm;
                    ddlVolume.SelectedValue = qry.Emergency_Volume;
                    ddlDischargeStatus.SelectedValue = qry.Discharge_Status;

                    if (qry.Expected_Discharge_Date != null)
                      
                        txtBP.Text = qry.BP_mm_Hg;
                    ctl00_MainContent_txtEOR.Text = qry.Eye_Opening_Response;
                    txtMR.Text = qry.Motor_Response;
                    txtVR.Text = qry.Verbal_Response;
                    txtAcc.Text = qry.Accumulated_Response;
                    txtTemp.Text = qry.Temp_C;
                    txtRespiration.Text = qry.Respiration_Min;
                    txtRateBeats.Text = qry.RateBeats;
                    txtOthersRcvNote.Text = qry.OthersRecieveNote;
                    txtSaturation.Text = qry.O2_Saturation;
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
                            HMFIntact2.Checked = true;
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
                            CranialNerves2.Checked = true;
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
                            SignsOfMeningism2.Checked = true;
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
                            HeartSound2.Checked = true;
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
                            Arrhythmias2.Checked = true;
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
                            Murmur2.Checked = true;
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
                            AnyOtherAddedSound2.Checked = true;
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
                            AnyOtherFindings2.Checked = true;
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
                            Wheeze2.Checked = true;
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
                            Ranchi2.Checked = true;
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
                            AnyOtherSound2.Checked = true;
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
                            AbdomenSoft2.Checked = true;
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
                            Tenderness2.Checked = true;
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
                            Guarding2.Checked = true;
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
                            BowelSound2.Checked = true;
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
                            Distention2.Checked = true;
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
                            FluidThrill2.Checked = true;
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
                            ShiftingDullness2.Checked = true;
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
                            EpigastriaDiscomfort2.Checked = true;
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
                            RetrosternalBurning2.Checked = true;
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
                            Jondus2.Checked = true;
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
                            Pallor2.Checked = true;
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
                            Dehydration2.Checked = true;
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
                            GCSOrientation2.Checked = true;
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
                            ConsciousOrientely2.Checked = true;
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
                            NVB_Right2.Checked = true;
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
                            NVB_Left2.Checked = true;
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
                            Crepitation_Right2.Checked = true;
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
                            Crepitation_Left2.Checked = true;
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
                    txtTreatmentGiven.Text = qry.TreatmentGiven;
                    txtPhysicalFinding.Text = qry.PhysicalFinding;
                    txtGeneralPhysicalExamination.Text = qry.GeneralPhysicalExamination;
                    txtClinicalSummary.Text = qry.ClinicalSummary;
                    txtTreatmentAtDischarge.Text = qry.TreatmentAtDischarge;
                    txtFollowUpPlanInstructions.Text = qry.FollowUpPlanInstructions;
                    txtCauseOfReferral.Text = qry.CauseOfReferral;
                    txtProvisionalDiagnosis.Text = qry.Provisional_Diagnosis;
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
                    ddlPatient_Main_Category.SelectedValue = qry.Reffer_To;
                    txt_remarks.Text = qry.remarks;
 
                    txtPersonalHistory.Text = qry.Personal_History;


                    txtmidl.Text = qry.ENT_Throat_IDL;
                    txtmNose.Text = qry.ENT_Throat_Nose;
                    txtmRight.Text = qry.ENT_Ear_Right;
                    txtmLeft.Text = qry.Ent_Ear_Left;
                    mchkRightPos.Checked = qry.ENT_Rinnes_Right_PosNeg.Value;
                    mchkLeftPos.Checked = qry.ENT_Rinnes_Lft_PosNeg.Value;
                    mchkRightF.Checked = qry.ENT_Rinnes_Right_FalseNeg.Value;
                    mchkLeftF.Checked = qry.ENT_Rinnes_Lft_FalseNeg.Value;

                    mchkcentral.Checked = qry.ENT_Webber_Central.Value;
                    mchkLateralized.Checked = qry.ENT_Webber_Lateralized.Value;
                    mchkPTA.Checked = qry.ENT_Investigation_PTA.Value;
                    mchkTympanometry.Checked = qry.ENT_Investigation_Tympanometry.Value;
                    mchkRightNeg.Checked = qry.ENT_Rinnes_Right_Neg.Value;
                    mchkLeftNeg.Checked = qry.ENT_Rinnes_Lft_Neg.Value;
                    mchkRightFNeg.Checked = qry.ENT_Rinnes_Right_FNeg.Value;
                    mchkLeftFNeg.Checked = qry.ENT_Rinnes_Lft_FNeg.Value;


                    txtInformant.Text = qry.Psychiatry_Informant;
                    txtSourceOfReferral.Text = qry.Psychiatry_Source_Referral;
                    chkNeckHolding.Checked = Convert.ToBoolean(qry.Psychiatry_Neck_Holding);
                    chkWalking.Checked = qry.Psychiatry_Walking.Value;
                    chkTalking.Checked = qry.Psychiatry_Talking.Value;
                    chkOthers.Checked = qry.Psychiatry_Others.Value;
                    txtMenarche.Text = qry.Psychiatry_Menarche;
                    txtMenstrual.Text = qry.Psychiatry_Menstrual;
                    txtAttachmentSeparationfromParents.Text = qry.Psychiatry_Attachment_Separation;
                    txtHealth.Text = qry.Psychiatry_Health;
                    chkNailBiting.Checked = Convert.ToBoolean(qry.Psychiatry_Nail_Biting);
                    chkTemperTantrums.Checked = Convert.ToBoolean(qry.Psychiatry_Temper_Tantrums);
                    chkBedWetting.Checked = Convert.ToBoolean(qry.Psychiatry_Bed_Wetting);
                    txtAcademics.Text = qry.Psychiatry_Academics;
                    txtPeerRelationship.Text = qry.Psychiatry_Peer_Relationship;
                    txtBehaviour.Text = qry.Psychiatry_Behaviour;
                    txtOccupationalHistory.Text = qry.Psychiatry_Occupational_History;
                    txtMaritalRelationshipSexualHistory.Text = qry.Psychiatry_Sexual_History;
                    txtSubstanceUse.Text = qry.Psychiatry_Substance_Use;
                    txtForensicUse.Text = qry.Psychiatry_Forensic_Use;
                    txtRelationship.Text = qry.Psychiatry_Relationship;
                    txtLeisureActivities.Text = qry.Psychiatry_Leisure_Activities;
                    txtAttitudetoSelfandStandards.Text = qry.Psychiatry_Attitude_Standards;
                    txtPrevallingMood.Text = qry.Psychiatry_Prevalling_Mood;
                    txtReactionPattrentoStress.Text = qry.Psychiatry_Reaction_Stress;
                    txtReligiousPracticesAttitute.Text = qry.Psychiatry_Religious_Practices;
                    txtFather.Text = qry.Psychiatry_Father;
                    txtMother.Text = qry.Psychiatry_Mother;
                    txtSiblings.Text = qry.Psychiatry_Siblings;
                    txtHomeAtmosphererelationshipsocialclass.Text = qry.Psychiatry_Home_Atmosphere;
                    txtFamilialIllness.Text = qry.Psychiatry_Familial_Illness;
                    txtActualandapparentage.Text = qry.Psychiatry_Actual_age;
                    txtRace.Text = qry.Psychiatry_Race;
                    txtTattoosbodypiercingandscars.Text = qry.Psychiatry_Tattoos_body_scars;
                    txtBodyHabitus.Text = qry.Psychiatry_Body_Habitus;
                    txtDress.Text = qry.Psychiatry_Dress;
                    txtHygiene.Text = qry.Psychiatry_Hygiene;
                    txtPsychomotorActivity.Text = qry.Psychiatry_Psychomotor_Activity;
                    txtInvoluntarymovements.Text = qry.Psychiatry_Involuntary_movements;
                    txtDystoniaEPS.Text = qry.Psychiatry_Dystonia_EPS;
                    txtTardivedyskinesia.Text = qry.Psychiatry_Tardive_dyskinesia;
                    txtTics.Text = qry.Psychiatry_Tics;
                    txtTremors.Text = qry.Psychiatry_Tremors;
                    txtAttentivenesstointerview.Text = qry.Psychiatry_Attentiveness_interview;
                    txtEyeContact.Text = qry.Psychiatry_Eye_Contact;
                    txtLevelofConsciousness.Text = qry.Psychiatry_Level_Consciousness;
                    txtRate.Text = qry.Psychiatry_Rate;
                    txtRhythm.Text = qry.Psychiatry_Rhythm;
                    txtVolume.Text = qry.Psychiatry_Volume;
                    txtTone.Text = qry.Psychiatry_Tone;
                    txtModulationvar.Text = qry.Psychiatry_Modulation;
                    txtDepressed.Text = qry.Psychiatry_Depressed;
                    txtElated.Text = qry.Psychiatry_Elated;
                    txtIrritable.Text = qry.Psychiatry_Irritable;
                    txtLabile.Text = qry.Psychiatry_Labile;
                    txtIncongruent.Text = qry.Psychiatry_Incongruent;
                    txtBluntingFlatteningApathy.Text = qry.Psychiatry_Blunting_Flattening_Apathy;
                    txtThinkingPremeditation.Text = qry.Psychiatry_Thinking;
                    txtPlans.Text = qry.Psychiatry_Plans;
                    txtActions.Text = qry.Psychiatry_Actions;
                    txtPreservative.Text = qry.Psychiatry_Preservative;
                    txtLoosAssociation.Text = qry.Psychiatry_LoosAssociation;
                    txtTangentiaility.Text = qry.Psychiatry_Tangentiaility;
                    txtCircumstantiality.Text = qry.Psychiatry_Circumstantiality;
                    txtFlightofIdeas.Text = qry.Psychiatry_Flight_Ideas;
                    txtThoughtInsertion.Text = qry.Psychiatry_Thought_Insertion;
                    txtThoughtWithdrawal.Text = qry.Psychiatry_Thought_Withdrawal;
                    txtThoughBroadcasting.Text = qry.Psychiatry_Thought_Broadcasting;
                    txtThoughControl.Text = qry.Psychiatry_Thought_Control;
                    txtDellusion.Text = qry.Psychiatry_Dellusion;
                    txtovervaluedideas.Text = qry.Psychiatry_Overvalued_Ideas;
                    txtDepresonalization.Text = qry.Psychiatry_Depresonalization;
                    txtDerealization.Text = qry.Psychiatry_Derealization;
                    txtthrougObsession.Text = qry.Psychiatry_Informant;
                    txtthrougPhobies.Text = qry.Psychiatry_Phobies;
                    txtthrougHomocidialIdeas.Text = qry.Psychiatry_Homocidial_Ideas;
                    txtillusion.Text = qry.Psychiatry_Illusion;
                    txtHallucinationAuditoryVisualOlfactoryGustatoryTactile.Text = qry.Psychiatry_Hallucination;
                    txtorientationtime.Text = qry.Psychiatry_Orientation_Time;
                    txtplace.Text = qry.Psychiatry_Place;
                    txtperson.Text = qry.Psychiatry_Person;
                    txtAttentionConcentrationSerial7Test.Text = qry.Psychiatry_Attention_Concentration;
                    txtOrDaysOfWeekReverseOrder.Text = qry.Psychiatry_Days_Week;
                    txtImmediatememory.Text = qry.Psychiatry_Immediate_Memory;
                    txtshorttermrecentevents.Text = qry.Psychiatry_Recent_Events;
                    txtadressrecallafter2minutes.Text = qry.Psychiatry_Adress_Recall_Two;
                    longtermremoteevents.Text = qry.Psychiatry_Remote_Events;
                    txtadressrecallafter5minues.Text = qry.Psychiatry_Adress_Recall_Five;
                    txtgeneralknowledgequestion.Text = qry.Psychiatry_General_knowledge;
                    txtsimplearthemeticcalculation.Text = qry.Psychiatry_Arthemetic_Calculation;
                    txtabstrationconcertethinking.Text = qry.Psychiatry_Abstraction;
                    txtinsight.Text = qry.Psychiatry_Insight;

                    txtDermaFace.Text = qry.DermaFace;
                    txtDermaNeck.Text = qry.DermaNeck;
                    txtDermaTrunk.Text = qry.DermaTrunk;
                    txtDermaUpperLimb.Text = qry.DermaUpperLimb;
                    txtDermaLowerLimb.Text = qry.DermaLowerLimb;
                    txtDermaFlexures.Text = qry.DermaFlexures;
                    txtDermaGenitalias.Text = qry.DermaGenitalias;
                    txtDermaHair.Text = qry.DermaHair;
                    txtDermaNail.Text = qry.DermaNail;
                    txtDermaMucousMembrane.Text = qry.DermaMucousMembrane;
                    txtDermaEyes.Text = qry.DermaEyes;
                    txtDermaEars.Text = qry.DermaEars;
                    txtDermaNose.Text = qry.DermaNose;
                    txtDermaLips.Text = qry.DermaLips;

                    txtHBM_Problem.Text = qry.Psychiatry_HBM_Problem;
                    txtHBM_Caused.Text = qry.Psychiatry_HBM_Caused;
                    txtHBM_Started.Text = qry.Psychiatry_HBM_Started;
                    txtHBM_Course.Text = qry.Psychiatry_HBM_Course;
                    txtHBM_Treatment.Text = qry.Psychiatry_HBM_Treatment;
                    txtHBM_Effects.Text = qry.Psychiatry_HBM_Effects;
                    txtPE_Pluse.Text = qry.Psychiatry_PE_Pluse;
                    txtPE_BP.Text = qry.Psychiatry_PE_BP;
                    txtPE_Temperature.Text = qry.Psychiatry_PE_Temperature;
                    txtPE_Weight.Text = qry.Psychiatry_PE_Weight;
                    txtPE_RespiratoryRate.Text = qry.Psychiatry_PE_RespiratoryRate;
                    txtPE_Jaundice.Text = qry.Psychiatry_PE_Jaundice;
                    txtPE_Anemia.Text = qry.Psychiatry_PE_Anemia;
                    txtPE_Cyanosis.Text = qry.Psychiatry_PE_Cyanosis;
                    txtPE_Clubbing.Text = qry.Psychiatry_PE_Clubbing;
                    txtPE_JVP.Text = qry.Psychiatry_PE_JVP;
                    txtPE_LymphNodes.Text = qry.Psychiatry_PE_LymphNodes;
                    txtPE_Edema.Text = qry.Psychiatry_PE_Edema;
                    txtPE_Respiratory.Text = qry.Psychiatry_PE_Respiratory;
                    txtPE_Cardiovascular.Text = qry.Psychiatry_PE_Cardiovascular;
                    txtPE_Gastro_Intestinal.Text = qry.Psychiatry_PE_Gastro_Intestinal;
                    txtPE_Observation.Text = qry.Psychiatry_PE_Observation;
                    txtPE_Cranial_Nerves.Text = qry.Psychiatry_PE_Cranial_Nerves;
                    txtPE_Limb_Strength.Text = qry.Psychiatry_PE_Limb_Strength;
                    txtPE_Spasticity.Text = qry.Psychiatry_PE_Spasticity;
                    txtPE_Position.Text = qry.Psychiatry_PE_Position;
                    txtPE_Vibration.Text = qry.Psychiatry_PE_Vibration;
                    txtPE_Stereognosis.Text = qry.Psychiatry_PE_Stereognosis;
                    txtPE_Pain.Text = qry.Psychiatry_PE_Pain;
                    txtPE_Biceps.Text = qry.Psychiatry_PE_Biceps;
                    txtPE_Triceps.Text = qry.Psychiatry_PE_Triceps;
                    txtPE_Brachioradialis.Text = qry.Psychiatry_PE_Brachioradialis;
                    txtPE_Quadriceps.Text = qry.Psychiatry_PE_Quadriceps;
                    txtPE_Patellar.Text = qry.Psychiatry_PE_Patellar;
                    txtPE_Achilles.Text = qry.Psychiatry_PE_Achilles;
                    txtPE_Extensor.Text = qry.Psychiatry_PE_Extensor;
                    txtPE_Frontal.Text = qry.Psychiatry_PE_Frontal;
                    txtPE_Finger.Text = qry.Psychiatry_PE_Finger;
                    txtPE_Heel.Text = qry.Psychiatry_PE_Heel;
                    txtPE_Movements.Text = qry.Psychiatry_PE_Movements;
                    txtPE_Gait.Text = qry.Psychiatry_PE_Gait;
                    chkPE_Neck_Rigidity.Checked = qry.Psychiatry_PE_Neck_Rigidity.Value;
                    chkPE_Kerning_Sign.Checked = qry.Psychiatry_PE_Kerning_Sign.Value;
                    chkPE_Brudzinki_Sign.Checked = qry.Psychiatry_PE_Brudzinki_Sign.Value;
                    txtFor_Summary.Text = qry.Psychiatry_For_Summary;
                    txtFor_Diagnosis.Text = qry.Psychiatry_For_Diagnosis;
                    txtFor_AxisI.Text = qry.Psychiatry_For_AxisI;
                    txtFor_AxisIII.Text = qry.Psychiatry_For_AxisIII;
                    txtFor_AxisII.Text = qry.Psychiatry_For_AxisII;

                    txtFor_AxisIV.Text = qry.Psychiatry_For_AxisIV;
                    txtFor_AxisV.Text = qry.Psychiatry_For_AxisV;
                    txtFor_PredisposingFactors.Text = qry.Psychiatry_For_PredisposingFactors;
                    txtFor_PrecipitatingFactors.Text = qry.Psychiatry_For_PrecipitatingFactors;
                    txtFor_PrepetuatingFactors.Text = qry.Psychiatry_For_PrepetuatingFactors;
                    txtFor_Investigation.Text = qry.Psychiatry_For_Investigation;
                    txtFor_Medical.Text = qry.Psychiatry_For_Medical;
                    txtFor_Psychological.Text = qry.Psychiatry_For_Psychological;
                    txtFor_Major_Issues.Text = qry.Psychiatry_Major_Issues;
                    txtFor_Strengths.Text = qry.Psychiatry_For_Strengths;
                    txtFor_Goals.Text = qry.Psychiatry_For_Goals;
                    txtFor_Strategies.Text = qry.Psychiatry_For_Strategies;

                    txtPeads_weight.Text = qry.Peads_weight;
                    txtPeads_Length.Text = qry.Peads_Length;
                    txtPeads_HC.Text = qry.Peads_HC;
                    txtPeads_General_Appearance.Text = qry.Peads_General_Appearance;
                    chkPeads_Cyanosis.Checked = qry.Peads_Cyanosis.Value;
                    chkPeads_Jaundice.Checked = qry.Peads_Jaundice.Value;
                    chkPeads_Lethargy.Checked = qry.Peads_Lethargy.Value;
                    chkPeads_Rash.Checked = qry.Peads_Rash.Value;
                    txtPeads_Others.Text = qry.Peads_Others;
                    chkPeads_Caput.Checked = qry.Peads_Caput.Value;

                    chkPeads_Cephalhematoma.Checked = qry.Peads_Cephalhematoma.Value;
                    rdbPeads_Anterioropen.Checked = qry.Peads_Anterioropen.Value;
                    rdbPeads_AnteriorClose.Checked = qry.Peads_AnteriorClose.Value;
                    chkPeads_Dextrocardia.Checked = qry.Peads_Dextrocardia.Value;
                    chkPeads_Bulging.Checked = qry.Peads_Bulging.Value;
                    chkPeads_Murmur.Checked = qry.Peads_Murmur.Value;
                    txtPeads_HeartSound.Text = qry.Peads_HeartSound;
                    chkPeads_Nasal.Checked = qry.Peads_Nasal.Value;
                    chkPeads_Recessions.Checked = qry.Peads_Recessions.Value;
                    txtPeads_AddedSounds.Text = qry.Peads_AddedSounds;

                    rdbPeads_Flat.Checked = qry.Peads_Flat.Value;
                    rdbPeads_Distended.Checked = qry.Peads_Distended.Value;
                    rdbPeads_Scaphoid.Checked = qry.Peads_Scaphoid.Value;
                    chkPeads_Liver.Checked = qry.Peads_Liver.Value;
                    chkPeads_Spleen.Checked = qry.Peads_Spleen.Value;
                    txtPeads_GITOthers.Text = qry.Peads_GITOthers;
                    chkPeads_Sucking.Checked = qry.Peads_Sucking.Value;
                    chkPeads_Rooting.Checked = qry.Peads_Rooting.Value;
                    chkPeads_Moro.Checked = qry.Peads_Moro.Value;
                    txtPeads_CNSOthers.Text = qry.Peads_CNSOthers;

                    chkPeads_FullTerm.Checked = qry.Peads_FullTerm.Value;
                    chkPeads_PreTerm.Checked = qry.Peads_PreTerm.Value;
                    if (qry.Peads_DateOfDelivery != null)
                        txtPeads_DateOfDelivery.Text = qry.Peads_DateOfDelivery.Value.ToString(AppConfig.DateFormat);
                    txtPeads_TimeOfDelivery.Text = qry.Peads_TimeOfDelivery;
                    rdbPeads_Booked.Checked = qry.Peads_Booked.Value;
                    rdbPeads_UnBooked.Checked = qry.Peads_UnBooked.Value;
                    chkPeads_DAIHandling.Checked = qry.Peads_DAIHandling.Value;
                    chkPeads_ANTURash.Checked = qry.Peads_ANTURash.Value;
                    chkPeads_PIH.Checked = qry.Peads_PIH.Value;
                    chkPeads_GDM.Checked = qry.Peads_GDM.Value;
                    chkPeads_Vacinated.Checked = qry.Peads_Vacinated.Value;

                    txtPeads_ANTOthers.Text = qry.Peads_ANTOthers;
                    rdbPeads_SVD.Checked = qry.Peads_SVD.Value;
                    rdbPeads_LSCS.Checked = qry.Peads_LSCS.Value;
                    rdbPeads_Emergency.Checked = qry.Peads_Emergency.Value;
                    rdbPeads_Elective.Checked = qry.Peads_Elective.Value;

                    txtPeads_PlaceOfDelivery.Text = qry.Peads_PlaceOfDelivery;
                    txtPeads_IndicationForLSCS.Text = qry.Peads_IndicationForLSCS;
                    ddlPeads_apgerScore1min.SelectedValue = qry.Peads_apgerScore1min;
                    ddlPeads_apgerScore5min.SelectedValue = qry.Peads_apgerScore5min;
                    chkPeads_Resuscitation.Checked = qry.Peads_Resuscitation.Value;

                    txtPeads_NatalOthers.Text = qry.Peads_NatalOthers;
                    chkPeads_Moaning.Checked = qry.Peads_Moaning.Value;
                    chkPeads_RespDistress.Checked = qry.Peads_RespDistress.Value;
                    chkPeads_PostNATALCyanosis.Checked = qry.Peads_PostNATALCyanosis.Value;
                    chkPeads_Fits.Checked = qry.Peads_Fits.Value;
                    chkPeads_ReluctanceToFeed.Checked = qry.Peads_ReluctanceToFeed.Value;
                    txtPeads_PostNatalOthers.Text = qry.Peads_PostNatalOthers;



                    ddlDischarge_By.SelectedValue = qry.Discharge_By;
                    // Show existing file link if it exists
                    if (!string.IsNullOrEmpty(qry.emergecny_pat_file))
                    {
                        string fileUrl = ResolveUrl(qry.emergecny_pat_file);
                        hlExistingFile.NavigateUrl = fileUrl;
                        hlExistingFile.Text = "View File: " + System.IO.Path.GetFileName(qry.emergecny_pat_file);
                        hlExistingFile.Visible = true;
                    }
                    else
                    {
                        hlExistingFile.Visible = false;
                    }

                    txtPrevention_Precaution.Text = qry.Prevention_Precaution;
                    if (qry.Next_Visit != null)
                        txtNext_Visit.Text = qry.Next_Visit.Value.ToString(AppConfig.DateFormat);
                    if (qry.Discharge_On != null)
                        txtDischarge_On.Text = qry.Discharge_On.Value.ToString(AppConfig.DateFormat);
                    cbDicharg_Slip.Checked = qry.Discharge.Value;
                    if (qry.Discharge_On != null && qry.Discharge == true)
                    {
                        PatientDischargeStatus = true;
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

            var PatCase = (from ep in db.Emergency_Patients
                           join p in db.Reg_patients
                          on ep.Patient_ID equals p.pat_id
                           where p.Patient_No == Patien_No
                           select new
                           {
                               ep.Peads_weight,
                               ep.Peads_Length,
                               ep.Peads_HC,
                               ep.Peads_General_Appearance,
                               ep.Peads_Cyanosis,
                               ep.Peads_Jaundice,
                               ep.Peads_Lethargy,
                               ep.Peads_Rash,
                               ep.Peads_Others,
                               ep.Peads_Caput,
                               ep.Peads_Cephalhematoma,
                               ep.Peads_Anterioropen,
                               ep.Peads_AnteriorClose,
                               ep.Peads_Dextrocardia,
                               ep.Peads_Bulging,
                               ep.Peads_Murmur,
                               ep.Peads_HeartSound,
                               ep.Peads_Nasal,
                               ep.Peads_Recessions,
                               ep.Peads_AddedSounds,
                               ep.Peads_Flat,
                               ep.Peads_Distended,
                               ep.Peads_Scaphoid,
                               ep.Peads_Liver,
                               ep.Peads_Spleen,
                               ep.Peads_GITOthers,
                               ep.Peads_Sucking,
                               ep.Peads_Rooting,
                               ep.Peads_Moro,
                               ep.Peads_CNSOthers,
                               ep.Peads_FullTerm,
                               ep.Peads_PreTerm,
                               ep.Peads_DateOfDelivery,
                               ep.Peads_TimeOfDelivery,
                               ep.Peads_Booked,
                               ep.Peads_UnBooked,
                               ep.Peads_DAIHandling,
                               ep.Peads_ANTURash,
                               ep.Peads_PIH,
                               ep.Peads_GDM,
                               ep.Peads_Vacinated,
                               ep.Peads_ANTOthers,
                               ep.Peads_SVD,
                               ep.Peads_LSCS,
                               ep.Peads_Emergency,
                               ep.Peads_Elective,
                               ep.Peads_PlaceOfDelivery,
                               ep.Peads_IndicationForLSCS,
                               ep.Peads_apgerScore1min,
                               ep.Peads_apgerScore5min,
                               ep.Peads_Resuscitation,
                               ep.Peads_NatalOthers,
                               ep.Peads_Moaning,
                               ep.Peads_RespDistress,
                               ep.Peads_PostNATALCyanosis,
                               ep.Peads_Fits,
                               ep.Peads_ReluctanceToFeed,
                               ep.Peads_PostNatalOthers,
                               ep.Created_Time
                           }).ToList();
            return ((new JavaScriptSerializer()).Serialize(PatCase));
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
                    return "OPD"; // Already a string, no need to serialize
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
        public static string SaveRecord(int Patient_ID, string btnsave, string txtAdmission_Date, string ddlDepartment, string ddlDoctor, string ddlCallToDoctor, string txtHealth_Complaints, string ddlIssuance_Of, string ddlWard_No, string txtBed_No, string RateBeats,  string BP_mm_Hg, string Temp_C, string Respiration_Min, string txtRN_Special_Instruction, string txtReceiving_Date, string Provisional_Diagnosis, string Reffer_To, string HistoryOfPeresentIllness, string HistoryOfFamily, string HistoryOfPastIllness, string SocioEconomicHistory, string Birth_History, string Reffer_No, string Drug_History, string Personal_History, string ObstetricHistory, string AllergiesHistory, string TreatmentHistory, string VaccinationHistory, string AnyOtherHistory, string ENT_Throat_IDL, string ENT_Throat_Nose, string ENT_Ear_Right, string Ent_Ear_Left, bool ENT_Rinnes_Right_PosNeg, bool ENT_Rinnes_Lft_PosNeg, bool ENT_Rinnes_Right_FalseNeg, bool ENT_Rinnes_Lft_FalseNeg, bool ENT_Webber_Central, bool ENT_Webber_Lateralized, bool ENT_Investigation_PTA, bool ENT_Investigation_Tympanometry, bool ENT_Rinnes_Right_Neg, bool ENT_Rinnes_Lft_Neg, bool ENT_Rinnes_Right_FNeg, bool ENT_Rinnes_Lft_FNeg, string txtInformant, string txtSourceOfReferral, bool chkNeckHolding, bool chkWalking, bool chkTalking, bool chkOthers, string txtMenarche, string txtMenstrual, string txtAttachmentSeparationfromParents, string txtHealth, bool chkNailBiting, bool chkTemperTantrums, bool chkBedWetting, string txtAcademics, string txtPeerRelationship, string txtBehaviour, string txtOccupationalHistory, string txtMaritalRelationshipSexualHistory, string txtSubstanceUse, string txtForensicUse, string txtRelationship, string txtLeisureActivities, string txtAttitudetoSelfandStandards, string txtPrevallingMood, string txtReactionPattrentoStress, string txtReligiousPracticesAttitute, string txtFather, string txtMother, string txtSiblings, string txtHomeAtmosphererelationshipsocialclass, string txtFamilialIllness, string txtActualandapparentage, string txtRace, string txtTattoosbodypiercingandscars, string txtBodyHabitus, string txttxtDress, string txtHygiene, string txtPsychomotorActivity, string txtInvoluntarymovements, string txtDystoniaEPS, string txtTardivedyskinesia, string txtTics, string txtTremors, string txtAttentivenesstointerview, string txtEyeContact, string txtLevelofConsciousness, string txtRate, string txtRhythm, string txtVolume, string txtTone, string txtModulationvar, string txtDepressed, string txtElated, string txtIrritable, string txtLabile, string txtIncongruent, string txtbluntingflatteningapathy, string txtThinkingPremeditation, string txtPlans,
            string txtActions, string txtPreservative, string txtLoosAssociation, string txtTangentiaility, string txtCircumstantiality, string txtFlightofIdeas, string txtThoughtInsertion, string txtThoughtWithdrawal, string txtThoughBroadcasting, string txtThoughControl, string txtDellusion, string txtovervaluedideas, string txtDepresonalization, string txtDerealization, string txtthrougObsession, string txtthrougPhobies, string txtthrougHomocidialIdeas, string txtillusion, string txtHallucinationAuditoryVisualOlfactoryGustatoryTactile, string txtorientationtime, string txtplace, string txtperson, string txtAttentionConcentrationSerial7Test, string txtOrDaysOfWeekReverseOrder, string txtImmediatememory, string txtshorttermrecentevents, string txtadressrecallafter2minutes, string txtlongtermremoteevents, string txtadressrecallafter5minues, string txtgeneralknowledgequestion, string txtsimplearthemeticcalculation, string txtabstrationconcertethinking, string txtinsight, string DermaFace, string DermaNeck, string DermaTrunk, string DermaUpperLimb, string DermaLowerLimb, string DermaFlexures, string DermaGenitalias, string DermaHair, string DermaNail, string DermaMucousMembrane, string DermaEyes, string DermaEars, string DermaNose, string DermaLips, string HBM_Problem, string HBM_Caused, string HBM_Started, string HBM_Course, string HBM_Treatment, string HBM_Effects, string PE_Pluse, string PE_BP, string PE_Temperature, string PE_Weight, string PE_RespiratoryRate, string PE_Jaundice, string PE_Anemia, string PE_Cyanosis, string PE_Clubbing, string PE_JVP, string PE_LymphNodes, string PE_Edema, string PE_Respiratory, string PE_Cardiovascular, string PE_Gastro_Intestinal, string PE_Observation, string PE_Cranial_Nerves, string PE_Limb_Strength, string PE_Spasticity, string PE_Position, string PE_Vibration, string PE_Stereognosis, string PE_Pain, string PE_Biceps, string PE_Triceps, string PE_Brachioradialis, string PE_Quadriceps, string PE_Patellar, string PE_Achilles, string PE_Extensor, string PE_Frontal, string PE_Finger, string PE_Heel, string PE_Movements, string PE_Gait, bool PE_Neck_Rigidity, bool PE_Kerning_Sign, bool PE_Brudzinki_Sign, string For_Summary, string For_Diagnosis, string For_AxisI, string For_AxisII, string For_AxisIII, string For_AxisIV, string For_AxisV, string For_PredisposingFactors, string For_PrecipitatingFactors, string For_PrepetuatingFactors, string For_Investigation, string For_Medical, string For_Psychological, string For_Major_Issues, string For_Strengths, string For_Goals, string For_Strategies, string txtPeads_weight, string txtPeads_Length, string txtPeads_HC, string txtPeads_General_Appearance, bool chkPeads_Cyanosis, bool chkPeads_Jaundice, bool chkPeads_Lethargy, bool chkPeads_Rash, string txtPeads_Others, bool chkPeads_Caput, bool chkPeads_Cephalhematoma, bool rdbPeads_Anterioropen, bool rdbPeads_AnteriorClose, bool chkPeads_Dextrocardia, bool chkPeads_Bulging, bool chkPeads_Murmur, string txtPeads_HeartSound, bool chkPeads_Nasal, bool chkPeads_Recessions, string txtPeads_AddedSounds, bool rdbPeads_Flat, bool rdbPeads_Distended, bool rdbPeads_Scaphoid, bool chkPeads_Liver, bool chkPeads_Spleen, string txtPeads_GITOthers, bool chkPeads_Sucking, bool chkPeads_Rooting, bool chkPeads_Moro, string txtPeads_CNSOthers, bool chkPeads_FullTerm, bool chkPeads_PreTerm, DateTime txtPeads_DateOfDelivery, string txtPeads_TimeOfDelivery, bool rdbPeads_Booked, bool rdbPeads_UnBooked, bool chkPeads_DAIHandling, bool chkPeads_ANTURash, bool chkPeads_PIH, bool chkPeads_GDM, bool chkPeads_Vacinated, string txtPeads_ANTOthers, bool rdbPeads_SVD, bool rdbPeads_LSCS, bool rdbPeads_Emergency, bool rdbPeads_Elective, string txtPeads_PlaceOfDelivery, string txtPeads_IndicationForLSCS, string Peads_apgerScore1min, string Peads_apgerScore5min, bool chkPeads_Resuscitation, string txtPeads_NatalOthers, bool chkPeads_Moaning, bool chkPeads_RespDistress, bool chkPeads_PostNATALCyanosis, bool chkPeads_Fits, bool chkPeads_ReluctanceToFeed, string txtPeads_PostNatalOthers, string txtDischarge_On, string ddlDischarge_By, string txtNext_Visit, string ddlPatientCondition, string txtAdvice, bool chkdischarge, string patienttype, string Saturation, string OthersRN, string DischargeStatus, string ddlEmrgRhythm, string ddlEmrgVolume, string Procedure_Recommended, string IdentificationMarks, string Diagnosis, string DateOfDeath, string TimeOfDeath, string PlaceOfDeath, string CauseOfDeath, string IssuingOfficerName, string DeathCertifiedby1, string DeathCertifiedby2, string BodyHandedOverTo, string FamilyPersonName, string CNIC, string RelationWithDeceased, string CMO_Police, string TreatmentGiven, string PhysicalFinding, string GeneralPhysicalExamination, string ClinicalSummary, string TreatmentAtDischarge, string FollowUpPlanInstructions, string CauseOfReferral, string ReferredTo, string TreatmentTime, string CallingDoctorDepartment, string CallingDoctorMobile, string O2_Saturation_Oxygen1, string O2_Saturation_Oxygen2, bool? HMFIntact, bool? CranialNerves, bool? SignsOfMeningism, bool? HeartSound, bool? Arrhythmias, bool? Murmur, bool? AnyOtherAddedSound, bool? AnyOtherFindings, bool? NVB_Right, bool? NVB_Left, bool? Crepitation_Right, bool? Crepitation_Left, bool? Wheeze, bool? Ranchi, bool? AnyOtherSound, bool? AbdomenSoft, bool? Tenderness, bool? Guarding, bool? BowelSound, bool? Distention, bool? FluidThrill, bool? ShiftingDullness, bool? EpigastriaDiscomfort, bool? RetrosternalBurning, bool? Jondus, bool? Pallor, bool? Dehydration, bool? GCSOrientation, bool? ConsciousOrientely, string FurtherExplanation, string ID, string TextBoxCns, string TextBoxCvs, string TextBoxResp, string TextBoxGit, string TextBoxGpe, string eye_response, string motor_response, string verbal_Response, string accumulated_response, string PulseRate, string BPDischarge, string Rhythmdischarge, string Tempdisch, string volumedisc, string RespRateDesc, string Oxygen2_desc, string saturationDis, string Oxygen1, string otherecdesc, string Special_Instruction_Desc, string Receiving_DateDesc,string remrks_call_to_doc,bool ReferToOPD,string Discount,string patientcateg,string Remarks)
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
                    if (!string.IsNullOrWhiteSpace(Discount))
                    {
                        OPD.Discount = Convert.ToDecimal(Discount);
                    }
                    else
                    {
                        OPD.Discount = 0; // or whatever default value makes sense (e.g.,
                    }

                        OPD.Department = ddlDepartment;
                    OPD.remarks = Remarks ?? string.Empty;
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
                    OPD.Patient_Category = patientcateg;
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

        public class Detail
        {
            public string Name;
            public string PatientType;
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
                        join p in db.Patients
                        on op.Patient_ID equals p.Patient_ID
                        where op.Follow_Up == "002" &&
              Convert.ToDateTime(op.Created_Time).Month == DateTime.Now.Month && Convert.ToDateTime(op.Created_Time).Year == DateTime.Now.Year && Convert.ToDateTime(op.Created_Time).Day == DateTime.Now.Day
                        select new
                        {
                            p.Patient_ID,
                            p.Patient_No,
                            p.Full_Name,
                            p.NIC,
                            Department = db.GetDataValueName("Patient Main Category", p.Patient_Main_Category),
                            Gender = db.GetDataValueName("Gender", p.Gender),
                            p.Created_Time,
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
        public static string Load_Category()
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
            var Type = (from tbl in db.Emergency_Patients
                        where tbl.Patient_ID == int.Parse(PatientID)
                        && tbl.Discharge != true
                        orderby tbl.Created_Time descending
                        select tbl.Patient_Discount_Type).FirstOrDefault();
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
                Type = db.GetDataValueName("Patient Type", Type);
                return pt;
            }
            else
                return pt;
        }
        protected void btnNew_Click(object sender, EventArgs e)
        {
            if (Request.QueryString["ID"] != null)
            {
                Response.Redirect("~/EmergencyCase.aspx", false);
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
            var tests = (from t in db.Lab_Tests
                         where t.Main_Department == "005"
                         select new
                         {
                             t.Test_ID,
                             TestName = t.Test_Name,
                         }).Distinct().ToList();
            List<TestIDsAndGroupCategory> listOfTest = new List<TestIDsAndGroupCategory>();
            int counter = 1;
            foreach (var test in tests)
            {
                TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                obj.TestID = test.Test_ID.ToString();
                obj.TestName = test.TestName.ToString();
                obj.SerialNo = counter.ToString();
                obj.IsGroupCategory = false;

                listOfTest.Add(obj);
                counter++;
            }
           
            var listNew = (from t in db.DataValues
                           where t.Division == "005" && t.ValueSet_ID == 70
                           select new
                           {
                               Test_ID = t.DataValue_Name,
                               Test_Name = t.DataValue_Description

                           }).ToList();
            foreach (var category in listNew)
            {
                TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                obj.TestID = category.Test_ID.ToString();
                obj.TestName = category.Test_Name.ToString();
                obj.SerialNo = counter.ToString();
                obj.IsGroupCategory = true;
                obj.CategoryID = category.Test_ID;
                listOfTest.Add(obj);
                counter++;
            }

            return (new JavaScriptSerializer().Serialize(listOfTest));
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

            var PatCase = (from ep in db.Emergency_Patients
                           join p in db.Reg_patients
                          on ep.Patient_ID equals p.pat_id
                           where p.Patient_No == Patien_No
                           select new
                           {

                               ep.Psychiatry_Informant,
                               ep.Psychiatry_Source_Referral,
                               ep.Psychiatry_Neck_Holding,
                               ep.Psychiatry_Walking,
                               ep.Psychiatry_Talking,
                               ep.Psychiatry_Others,
                               ep.Psychiatry_Menarche,
                               ep.Psychiatry_Menstrual,
                               ep.Psychiatry_Attachment_Separation,
                               ep.Psychiatry_Health,

                               ep.Psychiatry_Nail_Biting,
                               ep.Psychiatry_Temper_Tantrums,
                               ep.Psychiatry_Bed_Wetting,
                               ep.Psychiatry_Academics,

                               ep.Psychiatry_Peer_Relationship,
                               ep.Psychiatry_Behaviour,
                               ep.Psychiatry_Occupational_History,
                               ep.Psychiatry_Sexual_History,
                               ep.Psychiatry_Substance_Use,
                               ep.Psychiatry_Forensic_Use,
                               ep.Psychiatry_Relationship,
                               ep.Psychiatry_Leisure_Activities,
                               ep.Psychiatry_Attitude_Standards,
                               ep.Psychiatry_Prevalling_Mood,
                               ep.Psychiatry_Reaction_Stress,
                               ep.Psychiatry_Religious_Practices,
                               ep.Psychiatry_Father,
                               ep.Psychiatry_Mother,

                               ep.Psychiatry_Siblings,
                               ep.Psychiatry_Home_Atmosphere,
                               ep.Psychiatry_Familial_Illness,
                   
                               ep.Psychiatry_Actual_age,
                               ep.Psychiatry_Race,
                               ep.Psychiatry_Tattoos_body_scars,
                               ep.Psychiatry_Body_Habitus,
                               ep.Psychiatry_Dress,
                               ep.Psychiatry_Hygiene,
                               ep.Psychiatry_Psychomotor_Activity,
                               ep.Psychiatry_Involuntary_movements,
                               ep.Psychiatry_Dystonia_EPS,
                               ep.Psychiatry_Tardive_dyskinesia,

                               ep.Psychiatry_Tics,
                               ep.Psychiatry_Tremors,
                               ep.Psychiatry_Attentiveness_interview,
                               ep.Psychiatry_Eye_Contact,
                               ep.Psychiatry_Level_Consciousness,
                               ep.Psychiatry_Rate,
                               ep.Psychiatry_Rhythm,
                               ep.Psychiatry_Volume,
                               ep.Psychiatry_Tone,
                               ep.Psychiatry_Modulation,
                               ep.Psychiatry_Depressed,
                               ep.Psychiatry_Elated,

                               ep.Psychiatry_Irritable,
                               ep.Psychiatry_Labile,
                               ep.Psychiatry_Incongruent,
                               ep.Psychiatry_Blunting_Flattening_Apathy,
                               ep.Psychiatry_Thinking,
                               ep.Psychiatry_Plans,
                               ep.Psychiatry_Actions,
                               ep.Psychiatry_Preservative,
                               ep.Psychiatry_LoosAssociation,
                               ep.Psychiatry_Tangentiaility,
                               ep.Psychiatry_Circumstantiality,
                               ep.Psychiatry_Flight_Ideas,
                               ep.Psychiatry_Thought_Insertion,
                               ep.Psychiatry_Thought_Withdrawal,
                               ep.Psychiatry_Thought_Broadcasting,
                               ep.Psychiatry_Thought_Control,
                               ep.Psychiatry_Dellusion,
                               ep.Psychiatry_Overvalued_Ideas,
                               ep.Psychiatry_Depresonalization,
                               ep.Psychiatry_Derealization,

                               ep.Psychiatry_Obsession,
                               ep.Psychiatry_Phobies,
                               ep.Psychiatry_Homocidial_Ideas,
                               ep.Psychiatry_Illusion,
                               ep.Psychiatry_Hallucination,
                               ep.Psychiatry_Orientation_Time,
                               ep.Psychiatry_Place,
                               ep.Psychiatry_Person,
                               ep.Psychiatry_Attention_Concentration,
                               ep.Psychiatry_Days_Week,
                               ep.Psychiatry_Immediate_Memory,
                               ep.Psychiatry_Recent_Events,
                               ep.Psychiatry_Adress_Recall_Two,
                               ep.Psychiatry_Remote_Events,
                               ep.Psychiatry_Adress_Recall_Five,
                               ep.Psychiatry_General_knowledge,
                               ep.Psychiatry_Arthemetic_Calculation,
                               ep.Psychiatry_Abstraction,
                               ep.Psychiatry_Insight,
                               ep.Created_Time,
                               ep.Psychiatry_HBM_Problem,
                               ep.Psychiatry_HBM_Caused,
                               ep.Psychiatry_HBM_Started,
                               ep.Psychiatry_HBM_Course,
                               ep.Psychiatry_HBM_Treatment,
                               ep.Psychiatry_HBM_Effects,
                               ep.Psychiatry_PE_Pluse,
                               ep.Psychiatry_PE_BP,
                               ep.Psychiatry_PE_Temperature,
                               ep.Psychiatry_PE_Weight,
                               ep.Psychiatry_PE_RespiratoryRate,
                               ep.Psychiatry_PE_Jaundice,
                               ep.Psychiatry_PE_Anemia,
                               ep.Psychiatry_PE_Cyanosis,
                               ep.Psychiatry_PE_Clubbing,
                               ep.Psychiatry_PE_JVP,
                               ep.Psychiatry_PE_LymphNodes,
                               ep.Psychiatry_PE_Edema,
                               ep.Psychiatry_PE_Respiratory,
                               ep.Psychiatry_PE_Cardiovascular,
                               ep.Psychiatry_PE_Gastro_Intestinal,
                               ep.Psychiatry_PE_Observation,
                               ep.Psychiatry_PE_Cranial_Nerves,
                               ep.Psychiatry_PE_Limb_Strength,
                               ep.Psychiatry_PE_Spasticity,
                               ep.Psychiatry_PE_Position,
                               ep.Psychiatry_PE_Vibration,
                               ep.Psychiatry_PE_Stereognosis,
                               ep.Psychiatry_PE_Pain,
                               ep.Psychiatry_PE_Biceps,
                               ep.Psychiatry_PE_Triceps,
                               ep.Psychiatry_PE_Brachioradialis,
                               ep.Psychiatry_PE_Quadriceps,
                               ep.Psychiatry_PE_Patellar,
                               ep.Psychiatry_PE_Achilles,
                               ep.Psychiatry_PE_Extensor,
                               ep.Psychiatry_PE_Frontal,
                               ep.Psychiatry_PE_Finger,
                               ep.Psychiatry_PE_Heel,
                               ep.Psychiatry_PE_Movements,
                               ep.Psychiatry_PE_Gait,
                               ep.Psychiatry_PE_Neck_Rigidity,
                               ep.Psychiatry_PE_Kerning_Sign,
                               ep.Psychiatry_PE_Brudzinki_Sign,
                               ep.Psychiatry_For_Summary,
                               ep.Psychiatry_For_Diagnosis,
                               ep.Psychiatry_For_AxisI,
                               ep.Psychiatry_For_AxisIII,
                               ep.Psychiatry_For_AxisII,
                               ep.Psychiatry_For_AxisIV,
                               ep.Psychiatry_For_AxisV,
                               ep.Psychiatry_For_PredisposingFactors,
                               ep.Psychiatry_For_PrecipitatingFactors,
                               ep.Psychiatry_For_PrepetuatingFactors,
                               ep.Psychiatry_For_Investigation,
                               ep.Psychiatry_For_Medical,
                               ep.Psychiatry_For_Psychological,
                               ep.Psychiatry_Major_Issues,
                               ep.Psychiatry_For_Strengths,
                               ep.Psychiatry_For_Goals,
                               ep.Psychiatry_For_Strategies,
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
     
        }

        [WebMethod]
        public static string checkRepeat(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {

                var checkRepeat = (from  emrp in db.Emergency_Patients
                                 
                                   where emrp.Patient_ID == PatientID
                                   && (emrp.Discharge == false || emrp.Discharge == null)
                                   select emrp.Emergency_ID).FirstOrDefault();

                return (new JavaScriptSerializer()).Serialize(checkRepeat);
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
                                      where op.Patient_ID == PatientID && op.Discharge_On == null
                                      select new
                                      {
                                          op.In_Patient_ID,
                                      }).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatROomsList);
            }
            
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
                    List<Ortho> InPatient_Instruction = db.Orthos.Where(i => i.Transaction_ID == OrthoDetail.outPatientID && i.Patient_Type == "Emergency Patient").ToList();
                    db.Orthos.DeleteAllOnSubmit(InPatient_Instruction);
                    db.SubmitChanges();
                }
                foreach (var test in OrthoDetail.OrthoList)
                {
                    Ortho oInPatient_Ortho = new PMS.Ortho();
                    oInPatient_Ortho.Transaction_ID = OrthoDetail.outPatientID;
                    oInPatient_Ortho.Patient_Type = "Emergency Patient";
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
                                 join op in db.Emergency_Patients
                                 on pm.Transaction_ID equals op.Emergency_ID
                                 where op.Emergency_ID == PatientID && pm.Patient_Type == "Emergency Patient"
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
                    obj.Status = "Emergency Patient";
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

            var InPatCase = (from op in db.Emergency_Patients
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
                obj.Status = "Emergency Patient";
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

            var InPatCase = (from op in db.Emergency_Patients
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
                obj.Status = "Emergency Patient";
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
        public static string LoadDoctorNoteForHistory(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatientID));

                var inPatDOcList = (from rm in db.InPatient_Doctor_Notes
                                    join op in db.Emergency_Patients
                                       on rm.In_Patient_ID equals op.Emergency_ID
                                    join p in db.Reg_patients
                                    on op.Patient_ID equals p.pat_id
                                    where p.Patient_No == Patien_No

                                    select new
                                    {
                                        rm.Doctor_Note_Date,
                                        rm.Doctor_Instruction,
                                        rm.Doctor_Status,
                                        DoctorStatus = db.GetDataValueName("Doctor Status", op.Department),
                                        rm.Doctor_ID,
                                        DoctorName = (from d in db.HR_Employees
                                                      where d.Emp_ID == Convert.ToInt32(rm.Doctor_ID)
                                                      select d.Emp_Name).FirstOrDefault(),
                                        rm.Progress_Note
                                    }).ToList();

                return (new JavaScriptSerializer()).Serialize(inPatDOcList);
            }
            return "";
        }
        [WebMethod]
        public static string LoadRoomsForHistory(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatientID));

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
            var result = (from data in db.Emergency_Patients
                          where data.Patient_ID == Convert.ToInt32(PatientID)
                          select new
                          {
                              data.Ward_ID,
                              Room_No = DBClass.getField("select isnull(Room_No,'0') from Rooms where room_id=" + data.Room_ID),
                              Description = DBClass.getField("select isnull(ward_no,'0') from Ward_Definition where ward_id=" + data.Ward_ID),

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
                                      join op in db.Emergency_Patients
                                      on rm.EmergencyID equals op.Emergency_ID
                                      join p in db.Reg_patients
                                     on op.Patient_ID equals p.pat_id
                                      where p.Patient_No == Patien_No
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
                                          Emergency_Pat_Condition = db.GetDataValueName("Patient Condition", op.Emergency_Pat_Condition), 
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
                    var lastRowWard = db.Ward_Allocatrion_Histories.Where(m => m.Patient_ID == Convert.ToInt32(txtPatient_ID.Text)).Skip(countOfWardRows - 1).FirstOrDefault();
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
            public int Pat { get; set; }
            public int PatientID { get; set; }
            public List<MedicineDetails> MedicineList { get; set; }
          
        }
        public class Medicine2
        {
            public int Pat { get; set; }
            public int PatientID { get; set; }
         
            public List<MedicinesList2> MedicineList2 { get; set; }
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

            public string Remarks;

            public string Nurse_Name;

            public string Date;
        }
        public class MedicinesList2
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

            public string Remarks;

            public string Nurse_Name;
        }
        public class DoctotNote
        {
            public int EmergencyPatientID { get; set; }
            public int Pat { get; set; }
            public List<DoctotNoteDetails> NoteList { get; set; }
        }
        public class LabResultrpt
        {
            public int EmergencyPatientID { get; set; }
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
                if (btnsave == "Update")
                {
                    List<InPatient_Doctor_Note> InPatient_Doctor_Note = db.InPatient_Doctor_Notes.Where(i => i.In_Patient_ID == DoctorDetail.EmergencyPatientID).ToList();
                    db.InPatient_Doctor_Notes.DeleteAllOnSubmit(InPatient_Doctor_Note);
                    db.SubmitChanges();
                }
                foreach (var test in DoctorDetail.NoteList)
                {
                    InPatient_Doctor_Note oInPatient_Doctor_Note = new PMS.InPatient_Doctor_Note();
                    oInPatient_Doctor_Note.EmergencyID = DoctorDetail.EmergencyPatientID;
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
                if (btnsave == "Update")
                {
                    List<Lab_Resultrpt> InPatient_Lab_Resultrpt = db.Lab_Resultrpts.Where(i => i.Lab_Result_ID == LabResulttrptDetail.EmergencyPatientID).ToList();
                    db.Lab_Resultrpts.DeleteAllOnSubmit(InPatient_Lab_Resultrpt);
                    db.SubmitChanges();
                }
                foreach (var test in LabResulttrptDetail.Resulttrpt)
                {
                    Lab_Resultrpt oInPatient_Lab_Resultrpt = new PMS.Lab_Resultrpt();
                    oInPatient_Lab_Resultrpt.EmergencyID = LabResulttrptDetail.EmergencyPatientID;
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
            public int EmergencyPatientID { get; set; }
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
                if (btnsave == "Update")
                {
                    List<InPatient_Instruction> InPatient_Instruction = db.InPatient_Instructions.Where(i => i.EmergencyID == InsDetail.EmergencyPatientID).ToList();
                    db.InPatient_Instructions.DeleteAllOnSubmit(InPatient_Instruction);
                    db.SubmitChanges();
                }
                foreach (var test in InsDetail.ListIns)
                {
                    InPatient_Instruction oInPatient_Doctor_Note = new PMS.InPatient_Instruction();
                    oInPatient_Doctor_Note.In_Patient_ID = InsDetail.EmergencyPatientID;
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
            var PreviousEyeDetails = db.EyeDetails.Where(t => t.TransactionID == Convert.ToInt32(Details.TransactionID) && t.TransactionType == "Emergency Patient").ToList();
            db.EyeDetails.DeleteAllOnSubmit(PreviousEyeDetails);
            db.SubmitChanges();
            foreach (EyeDetail eye in Details.EyeDetails)
            {
                db.EyeDetails.InsertOnSubmit(new PMS.EyeDetail() { TransactionID = Convert.ToInt32(Details.TransactionID), EyeMainTypeID = eye.EyeMainTypeID, EyeSubTypeID = eye.EyeSubTypeID, RightEye = eye.RightEye, LeftEye = eye.LeftEye, TransactionType = "Emergency Patient" });
            }
            db.SubmitChanges();
            return "";
        }
        [WebMethod]
        public static string GetEyeList(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var EyeList = (from e in db.EyeDetails
                           where e.TransactionType == "Emergency Patient" && e.TransactionID == id
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
                                join o in db.Emergency_Patients
                                on e.TransactionID equals o.Emergency_ID
                                join p in db.Reg_patients
                               on o.Patient_ID equals p.pat_id
                                where p.Patient_No == Patien_No && e.TransactionType == "Emergency Patient"
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
                                on o.Patient_ID equals p.pat_id
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
                obj.Status = "Emergency Patient";
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
        public class MedicineDischarge
        {
            public int PatientID { get; set; }
            public List<MedicineDDetails> MedicineDList { get; set; }
        }
        public class MedicineDDetails
        {
            public DateTime Date { get; set; }
            public string Medicine_Name { get; set; }
            public string Recomended_Dosage { get; set; }
            public string Oral { get; set; }
            public string Injection { get; set; }
            public string AttendingParamedical_Staff { set; get; }
            public string Frequency { set; get; }
            public string Doctor_ID { set; get; }
            public string chkDiccharge { set; get; }
            public string ItemCode { get; set; }
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
                    List<In_Patient_Medicine> In_Patient_MedicineList = db.In_Patient_Medicines.Where(i => i.Patient_ID == 0 && i.Transaction_Type == "Emergency Patient").ToList();
                    List<In_Patient_Medicine> In_Patient_MedicineList2 = db.In_Patient_Medicines.Where(i => i.Patient_ID == 0 && i.Transaction_Type == "Emergency Patient Nursing Monitoring").ToList();
                    db.In_Patient_Medicines.DeleteAllOnSubmit(In_Patient_MedicineList);
                    db.SubmitChanges();

                    db.In_Patient_Medicines.DeleteAllOnSubmit(In_Patient_MedicineList2);
                    db.SubmitChanges();

                    int couterNewRecords = 0;
                

                    if (MedicineDetail.PatientID != 0)
                    {
                        List<In_Patient_Medicine> inPatmedicineList = db.In_Patient_Medicines.Where(p => p.Patient_ID == MedicineDetail.PatientID && p.Transaction_Type == "Emergency Patient").ToList();
                        if (inPatmedicineList != null)
                        {
                            db.In_Patient_Medicines.DeleteAllOnSubmit(inPatmedicineList);
                            couterNewRecords++;
                        }
                    }
                   
                    couterNewRecords = 0;
                   
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
                            Other_Instruction = oIn_Patient_Medicine.Other_Instruction,
                             Nurse_Name = oIn_Patient_Medicine.Nurse_Name,
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
        public static string SaveMedicinesMonitoring(string MedicineDetails)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var MedicineDetail = js.Deserialize<Medicine>(MedicineDetails);
             

                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    List<In_Patient_Medicine> In_Patient_MedicineList = db.In_Patient_Medicines.Where(i => i.Patient_ID == 0 && i.Transaction_Type == "Emergency Patient Nursing Monitoring").ToList();
                  
                    db.In_Patient_Medicines.DeleteAllOnSubmit(In_Patient_MedicineList);
                    db.SubmitChanges();


                    int couterNewRecords = 0;
                  

                    if (MedicineDetail.PatientID != 0)
                    {
                        List<In_Patient_Medicine> inPatmedicineList = db.In_Patient_Medicines.Where(p => p.Patient_ID == MedicineDetail.PatientID && p.Transaction_Type == "Emergency Patient Nursing Monitoring").ToList();
                        if (inPatmedicineList != null)
                        {
                            db.In_Patient_Medicines.DeleteAllOnSubmit(inPatmedicineList);
                            couterNewRecords++;
                        }
                    }
                    
                    couterNewRecords = 0;
                 
                    foreach (MedicineDetails oIn_Patient_Medicine in MedicineDetail.MedicineList)
                    {
                        In_Patient_Medicine oIn_Patient_Medicine1 = new In_Patient_Medicine()
                        {

                            Patient_ID = Convert.ToInt32(MedicineDetail.PatientID),
                            Item_Code = oIn_Patient_Medicine.ItemCode,
                            Medicine_Name = oIn_Patient_Medicine.Medicine_Name,
                            Transaction_Type = "Emergency Patient Nursing Monitoring",
                            Medicine_Date = Convert.ToDateTime(oIn_Patient_Medicine.Date),
                            Oral = oIn_Patient_Medicine.Oral,
                            Injections = oIn_Patient_Medicine.Injection,
                            Dosage_From = oIn_Patient_Medicine.Dosage_From,
                            AttendingParamedical_Staff = oIn_Patient_Medicine.AttendingParamedical_Staff,
                            Frequency = oIn_Patient_Medicine.Frequency,
                            Dosage_Qty = oIn_Patient_Medicine.Dosage_Qty,
                            Other_Instruction = oIn_Patient_Medicine.Other_Instruction,
                            Nurse_Name = oIn_Patient_Medicine.Nurse_Name,
                            Remarks = oIn_Patient_Medicine.Remarks,
                        };
                    
                        DBClass.executeNonQueryWithoutBegin("update In_Patient_Medicines set Assigned=1 where Medicine_Name like '%" + oIn_Patient_Medicine.Medicine_Name + "%' and transaction_type='Emergency Patient' and Patient_ID=" + MedicineDetail.PatientID);
                        

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
        public static string LoadMedicinesMonitoring(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                List<In_Patient_Medicine> inPatmedicineList = db.In_Patient_Medicines.Where(p => p.Patient_ID == PatientID && p.Transaction_Type == "Emergency Patient Nursing Monitoring").ToList();
                return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
            }
            return "";
        }
        [WebMethod]
        public static string SaveDischargeMedicines    (string MedicineDetails)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var MedicineDetail = js.Deserialize<Medicine>(MedicineDetails);

                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    List<In_Patient_Medicine> In_Patient_MedicineList = db.In_Patient_Medicines.Where(i => i.Patient_ID == 0 && i.Transaction_Type == "Emergency Patient Discharge").ToList();
                    db.In_Patient_Medicines.DeleteAllOnSubmit(In_Patient_MedicineList);
                    db.SubmitChanges();

                    int couterNewRecords = 0;

                    if (MedicineDetail.PatientID != 0)
                    {
                        List<In_Patient_Medicine> inPatmedicineList = db.In_Patient_Medicines.Where(p => p.Patient_ID == MedicineDetail.PatientID && p.Transaction_Type == "Emergency Patient Discharge").ToList();
                        if (inPatmedicineList != null)
                        {
                            db.In_Patient_Medicines.DeleteAllOnSubmit(inPatmedicineList);
                            couterNewRecords++;
                        }
                    }
                    couterNewRecords = 0;
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
                                     where inPatmedicineList.Patient_ID == PatientID && inPatmedicineList.Transaction_Type == "Emergency Patient" &&
                                     (inPatmedicineList.chkDiccharge == false || inPatmedicineList.chkDiccharge == null)
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
                                         inPatmedicineList.Item_Code,
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
                                     where inPatmedicineList.Patient_ID == PatientID && inPatmedicineList.Transaction_Type == "Emergency Patient Discharge" && (inPatmedicineList.chkDiccharge == true || inPatmedicineList.chkDiccharge == null)
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
                                         inPatmedicineList.Item_Code,
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

            public DateTime? AdmissionDate { get; set; }
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

                    DateTime? admDate = null;

                    if (patID != null)
                    {
                        admDate = db.Emergency_Patients
                                   .Where(e => e.Patient_ID == patID)
                                   .Select(e => e.Admission_Date)
                                   .FirstOrDefault();

                        if (admDate == null)
                        {
                            admDate = db.Reg_patients
                                       .Where(r => r.pat_id == patID)
                                       .Select(r => r.Created_time)  
                                       .FirstOrDefault();
                        }
                    }


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
                    b.AdmissionDate = admDate;
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

        public class Service
        {
            public int PatId { get; set; }
            public int EmergencyId { get; set; }
            public List<ServiceDetails> ServicesList { get; set; }
        }

        public class ServiceDetails
        {
            public DateTime? ServiceDate { get; set; }
            public string Service_ProcedureName { get; set; }
            public string ServiceItemId { get; set; }
            public string ServiceItemAmount { get; set; }
            public string ServiceItemType { get; set; }
            public string PatientType { get; set; }
            public string UserName { get; set; }
        }

        [WebMethod]
        public static string SaveServicesDetail(string btnSave, string ServiceDetails)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var ServiceDetailList = js.Deserialize<Service>(ServiceDetails);
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    if (btnSave == "Update")
                    {
                        List<InPatientService> InPatientService = db.InPatientServices.DefaultIfEmpty().Where(w => w.PatientId == ServiceDetailList.PatId && w.EmergencyId == ServiceDetailList.EmergencyId).ToList();

                        db.InPatientServices.DeleteAllOnSubmit(InPatientService);
                    }

                    foreach (var item in ServiceDetailList.ServicesList)
                    {
                        InPatientService ipser = new PMS.InPatientService();
                        ipser.In_Patient_Id = 0;
                        ipser.Ou_Patient_Id = "0";
                        ipser.isbilled = false;
                        ipser.PatientId = ServiceDetailList.PatId;
                        ipser.EmergencyId = ServiceDetailList.EmergencyId;
                        ipser.PatientType = item.PatientType;
                        ipser.Services_Procedure_ItemName = item.Service_ProcedureName;
                        ipser.Service_ItemId = item.ServiceItemId;
                        ipser.ServiceType = item.ServiceItemType;
                        ipser.ServiceAmount = Convert.ToDecimal(item.ServiceItemAmount);
                        ipser.CreatedDate = item.ServiceDate;
                        ipser.UserName = item.UserName;
                        db.InPatientServices.InsertOnSubmit(ipser);
                    }
                    db.SubmitChanges();
                }

            }
            catch (Exception ex) { }
            return "";
        }

        [WebMethod]
        public static string LoadServicesDetail(int PatientId, int emergencyId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                List<ServiceDetails> list = new List<ServiceDetails>();

                var emergencyPatientServices = db.InPatientServices.DefaultIfEmpty().Where(w => w.PatientId == PatientId && w.EmergencyId == emergencyId && w.PatientType == "Emergency").ToList();

                if (emergencyPatientServices.Count > 0 && emergencyPatientServices != null)
                {
                    
                    foreach (var item in emergencyPatientServices)
                    {
                        ServiceDetails sd = new ServiceDetails();
                        sd.Service_ProcedureName = item.Services_Procedure_ItemName;
                        sd.ServiceItemType = item.ServiceType;
                        sd.ServiceItemId = item.Service_ItemId;
                        sd.ServiceItemAmount = Convert.ToString(item.ServiceAmount);
                        sd.PatientType = item.PatientType;
                        sd.ServiceDate = item.CreatedDate == null ? DateTime.Now : item.CreatedDate;
                        sd.UserName = item.UserName;
                        list.Add(sd);
                    }
                }

                return (new JavaScriptSerializer().Serialize(list));
            }

        }

        [WebMethod]
        public static string SaveRoomInformation(string btnsave, int PatID, int InPatID, string ddlRoom_No, string txtRoom_Type, string txtExpected_Discharge_Date, string ddlDoctor, bool DichargChk)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                Room_Allocation room_aloct;
                room_aloct = (from tbl in db.Room_Allocations
                              where tbl.Room_Type == txtRoom_Type
                               && tbl.In_Patient_ID == InPatID && tbl.Patient_ID == Convert.ToInt32(PatID)
                               && tbl.Room_ID == Convert.ToInt32(ddlRoom_No) && tbl.IsDischarge == false
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
                                               where tbl.In_Patient_ID == Convert.ToInt32(InPatID) && tbl.Patient_ID == Convert.ToInt32(PatID)
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
                room_aloct.In_Patient_ID = InPatID;
                room_aloct.Patient_ID = Convert.ToInt32(PatID);
                room_aloct.Room_ID = Convert.ToInt32(ddlRoom_No);

                room_aloct.Room_Type = txtRoom_Type;

                if (DichargChk == true)
                {
                    room_aloct.IsDischarge = true;
                }
                else
                {
                    room_aloct.IsDischarge = false;
                }
                var PreviousWardHistory = (from tbl in db.Ward_Allocations
                                           join inpat in db.Emergency_Patients
                                           on tbl.EmergencyID equals inpat.Emergency_ID
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
                db.SubmitChanges();
            }
            catch (Exception ex)
            {
                throw;
            }
            return "";
        }

        [WebMethod]
        public static string SaveWardInformation(string btnsave, string PatID, string EmergencyID, string ddlWard_No, string txtBed_No, string ddlDoctor, bool DichargChk)
        {
            try
            {
                Ward_Allocation ward_aloct;
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

                if (btnsave == "Update")
                {
                    ward_aloct = db.Ward_Allocations.Where(w => w.EmergencyID == Convert.ToInt32(EmergencyID)
                        && w.Patient_ID == Convert.ToInt32(PatID)
                        && w.Ward_ID == Convert.ToInt32(ddlWard_No)
                        && w.Bed_No_Assigned == Convert.ToInt32(txtBed_No)
                        ).FirstOrDefault();

                    if (ward_aloct != null && DichargChk != true) 
                    {
                        ward_aloct.Updated_By = AppConfig.UserID;
                        ward_aloct.Updated_Time = DateTime.Now;
                    }
                    else if (ward_aloct != null && DichargChk == true)
                    {
                        ward_aloct.Updated_By = AppConfig.UserID;
                        ward_aloct.Updated_Time = DateTime.Now;
                        ward_aloct.IsDischarge = true;
                    }

                    else
                    {
                        ward_aloct = (from tbl in db.Ward_Allocations
                                      where tbl.EmergencyID == Convert.ToInt32(EmergencyID) && tbl.Patient_ID == Convert.ToInt32(PatID)
                                       && tbl.IsDischarge == false
                                      select tbl).FirstOrDefault();
                        if (ward_aloct != null)
                        {
                            ward_aloct.IsDischarge = true;
                            ward_aloct = new Ward_Allocation();
                            ward_aloct.Created_By = AppConfig.UserID;
                            ward_aloct.Created_Time = DateTime.Now;
                            ward_aloct.Book_ID = AppConfig.Book_ID;
                            ward_aloct.Company_ID = AppConfig.Company_ID;
                            ward_aloct.From_TimeDate = Convert.ToDateTime(DateTime.Now);
                            ward_aloct.EmergencyID = Convert.ToInt32(EmergencyID);
                            ward_aloct.Patient_ID = Convert.ToInt32(PatID);
                            ward_aloct.Ward_ID = Convert.ToInt32(ddlWard_No);
                            ward_aloct.Bed_No_Assigned = Convert.ToInt32(txtBed_No);
                            ward_aloct.Doctor_Assigned = Convert.ToInt32(ddlDoctor);
                            ward_aloct.IsDischarge = false;
                            db.Ward_Allocations.InsertOnSubmit(ward_aloct);

                            if (DichargChk == true)
                            {
                                ward_aloct.IsDischarge = true;
                            }
                        }

                    }
                }
                else if (btnsave == "Save")
                {

                    ward_aloct = (from tbl in db.Ward_Allocations
                                  where tbl.Ward_ID == Convert.ToInt32(ddlWard_No)
                                   && tbl.EmergencyID == Convert.ToInt32(EmergencyID) && tbl.Patient_ID == Convert.ToInt32(PatID)
                                   && tbl.Bed_No_Assigned == Convert.ToInt32(txtBed_No) && tbl.IsDischarge == false
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
                                                   join inpat in db.Emergency_Patients
                                                   on tbl.EmergencyID equals inpat.Emergency_ID
                                                   where tbl.EmergencyID == Convert.ToInt32(EmergencyID) && tbl.Patient_ID == Convert.ToInt32(PatID)
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
                                            where tbl.Ward_ID == Convert.ToInt32(ddlWard_No)
                               && tbl.EmergencyID != Convert.ToInt32(EmergencyID) && tbl.Patient_ID != Convert.ToInt32(PatID)
                               && tbl.Bed_No_Assigned == Convert.ToInt32(txtBed_No) && tbl.IsDischarge == false
                                            select tbl).FirstOrDefault();
                        if (DuplicateBed != null)
                        {
                            DuplicateBed.IsDischarge = true;
                            DuplicateBed.To_TimeDate = Convert.ToDateTime(DateTime.Now);
                        }
                        if (btnsave != "Update")
                        {

                            ward_aloct.EmergencyID = DBClass.getMaxEntry_No("Emergency_Patient", "Emergency_ID");
                        }
                       
                    }
                    else
                    {

                        ward_aloct.Updated_By = AppConfig.UserID;
                        ward_aloct.Updated_Time = DateTime.Now;
                    }
                    ward_aloct.Patient_ID = Convert.ToInt32(PatID);
                    ward_aloct.Ward_ID = Convert.ToInt32(ddlWard_No);
                    ward_aloct.Bed_No_Assigned = Convert.ToInt32(txtBed_No);

                    ward_aloct.Doctor_Assigned = Convert.ToInt32(ddlDoctor);
                    if (DichargChk == true)
                    {
                        ward_aloct.IsDischarge = true;
                    }
                    else
                    {
                        ward_aloct.IsDischarge = false;
                    }
                   
                }

                db.SubmitChanges();
                var records = (from tbl in db.Ward_Allocations
                               where
                  tbl.EmergencyID == Convert.ToInt32(EmergencyID) &&
                   tbl.IsDischarge == false
                               select tbl).ToList();
                if (DichargChk == true)
                {
                    if (records.Count > 0)
                    {
                        DBClass.executeNonQueryWithoutBegin("update Ward_Allocation set IsDischarge=1 where emergencyid=" + EmergencyID);
                    }
                }
            }
            catch (Exception ex)
            {
                throw;
            }
            return "";
        }

        [WebMethod]
        public static string GetLabTestDDLDetails(string SerialNo)
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
                        where t.Main_Department == "001" && t.Test_Name == testName && t.Group_Category == groupCategory
                        select new { t.Test_ID, t.Rate, Test_Name = SerialNo, t.Group_Category, TestMainDepartmentName = db.GetDataValueName("Main Test Departments", t.Main_Department.ToString()).ToString(), GroupCategoryName = db.GetDataValueName("Test Groups", t.Group_Category.ToString()).ToString() }).ToList();
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
                                       select new { Test_ID = 0, Group_Category = dv.DataValue_Name, Test_Name = dv.DataValue_Description, TestMainDepartmentName = "Lab Test", Main_Department = "001", Rate = dv.Segment1 }).ToList();
                return (new JavaScriptSerializer()).Serialize(GroupCategories);
            }

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

            List<TestIDsAndGroupCategory> listOfTest = new List<TestIDsAndGroupCategory>();
            int counter = 1;
            var groupTests = from t in db.Lab_Tests
                             where t.Main_Department == "001" && t.Active == true && t.Group_Category != ""
                             select new { t.Test_ID, t.Test_Name, t.Group_Category };

            foreach (var test in groupTests)
            {
                TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                obj.TestID = test.Test_ID.ToString();
                obj.TestName = test.Test_Name + " | " +
                               DBClass.getField("select DataValue_Description from DataValues where DataValue_Name = '" + test.Group_Category + "' and ValueSet_ID = 70");
                obj.SerialNo = counter.ToString();
                obj.IsGroupCategory = false;
                listOfTest.Add(obj);
                counter++;
            }
            var singleTests = from t in db.Lab_Tests
                              where t.Main_Department == "001" && t.Active == true && (t.Group_Category == "" || t.Group_Category == null)
                              select new { t.Test_ID, t.Test_Name };

            foreach (var test in singleTests)
            {
                TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                obj.TestID = test.Test_ID.ToString();
                obj.TestName = test.Test_Name;
                obj.SerialNo = counter.ToString();
                obj.IsGroupCategory = false;
                listOfTest.Add(obj);
                counter++;
            }

            var GroupCategories = from dv in db.DataValues
                                  join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                  where vs.ValueSet_Name == "Test Groups" && dv.Division == "001"
                                  select new { dv.DataValue_Name, dv.DataValue_Description };

            foreach (var category in GroupCategories)
            {
                TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                obj.TestID = category.DataValue_Name;
                obj.TestName = category.DataValue_Description;
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
            public int Emergency_Patient_ID;
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
            //int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(id));

            var InPatienttestilst = (from lbtM in db.Laboratory_Tests
                                     join lbtD in db.Lab_Test_Details
                                     on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                     join outpat in db.Emergency_Patients
                                     on lbtM.Patient_ID equals outpat.Emergency_ID
                                     join p in db.Reg_patients
                                     on outpat.Patient_ID equals p.pat_id
                                     where p.pat_id == id && lbtM.Transaction_Type == "Emergency Patient"
                                     select new
                                     {
                                         outpat.Emergency_ID,
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
                                      join outpat in db.Emergency_Patients
                                      on lbtM.Patient_ID equals outpat.Patient_ID
                                      join p in db.Reg_patients
                                      on outpat.Patient_ID equals p.pat_id
                                      where p.pat_id == id && lbtM.Transaction_Type == "Emergency Patient"
                                      select new
                                      {

                                          outpat.Emergency_ID,
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
                                          lbtD.Is_Result
                                          //outpat.Doctor
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
                obj.Emergency_Patient_ID = item.Emergency_ID;
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
                obj.Status = "Emergency Patient";
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
                obj.Emergency_Patient_ID = item.Emergency_ID;
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
                obj.DoctorName = item.Doctor;
                obj.Status = "Emergency Patient";
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
                                join inpat in db.Emergency_Patients
                                on lbtM.Patient_ID equals inpat.Emergency_ID
                                where inpat.Emergency_ID == id && lbtM.Transaction_Type == "Emergency Patient"
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
                                join inpat in db.Emergency_Patients
                                on lbtM.Patient_ID equals inpat.Emergency_ID
                                where inpat.Emergency_ID == id && lbtM.Transaction_Type == "Emergency Patient"
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
                                join inpat in db.Emergency_Patients
                                on lbtM.Patient_ID equals inpat.Patient_ID
                                where inpat.Patient_ID == id && lbtM.Transaction_Type == "Emergency Patient"
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
                                    DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(lbtD.Doctor) select d.Emp_Name).FirstOrDefault(),
                                    TestMainDepartmentName = db.GetDataValueName("Main Test Departments", (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Main_Department).FirstOrDefault()).ToString()
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
                ltd.Actual_Patient_ID = Convert.ToInt32(record.PatientID);
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
                 where s.EmergencyID == outPatID
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
                 where s.EmergencyID == outPatID
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
                 join o in db.Emergency_Patients
                 on s.EmergencyID equals o.Emergency_ID
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
                 on o.Patient_ID equals p.pat_id
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
                obj.Status = "Emergency Patient";
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
            public string TreatmentGiven;
            public string PhysicalFinding;
            public string GeneralPhysicalExamination;
            public string Vaccination_History { get; set; }
            public string ClinicalSummary { get; set; }
            public string Other_History { get; set; }
        }
        [WebMethod]
        public static string LoadHistoryTabHistory(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatientID));

            var EmergencyPatientCase = (from op in db.Emergency_Patients
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
                                            op.txtInputBox1,                                            
                                            op.Vaccination_History,
                                            op.Other_History
                                        }).ToList();



            var OutPatCase = (from op in db.Out_Patients
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
                                  op.Mucculor,

                              }).ToList();



            List<PatientHistoryClass> list = new List<PatientHistoryClass>();
            foreach (var item in EmergencyPatientCase)
            {
                PatientHistoryClass obj = new PatientHistoryClass();


                obj.txtInputBox1 = item.txtInputBox1;

                obj.ObstetricHistory = item.ObstetricHistory;
                obj.AllergiesHistory = item.AllergiesHistory;
                obj.TreatmentHistory = item.TreatmentHistory;

                obj.HistoryOfPeresentIllness = item.HistoryOfPeresentIllness;
                obj.HistoryOfPastIllness = item.HistoryOfPastIllness;
                obj.HistoryOfFamily = item.HistoryOfFamily;
                obj.SocioEconomicHistory = item.SocioEconomicHistory;
                obj.Birth_History = item.Birth_History;
                obj.Drug_History = item.Drug_History;
                obj.Personal_History = item.Personal_History;

                obj.Created_Time = Convert.ToDateTime(item.Created_Time);
                obj.Vaccination_History = item.Vaccination_History;
                obj.Other_History = item.Other_History;
                obj.Status = "Emergency Patient";
              



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
            public string Rate_Beats;
            public string Weight_Kg;
            public string Height_Cm;
            public string Rhythm;
            public string Volume;
            public string OthersRcvNote;
            public string BP_mm_Hg;
            public string O2_Saturation;
            public string O2_Saturation_Oxygen1;
            public string O2_Saturation_Oxygen2;
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
            public string user;
        }

        [WebMethod]
        public static string LoadVitalParametersHistoryDicharge(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatientID));

           
            var EmergencyPatientList = (from op in db.ReceivingNotes
                                        join p in db.Reg_patients
                                       on op.Patient_ID equals p.pat_id
                                        where p.Patient_No == Patien_No
                                        && op.Type_Nursing== "Discharge Receiving Note"

                                        select new
                                        {
                                            op.RateBeats,
                                            op.BloodPressure,
                                            op.Emergency_Rhythm,
                                            op.Emergency_Volume,
                                            op.OthersRecieveNote,
                                            op.RespirationRate,
                                            op.Temperature,
                                            op.Receiving_Date,
                                            op.RN_Special_Instruction,
                                            op.O2_Saturation,
                                            op.O2_Saturation_Oxygen1,
                                            op.O2_Saturation_Oxygen2,
                                            user=db.aspnet_Users.Where(x=>x.UserId==op.user_id).Select(x=>x.UserName).FirstOrDefault(),
                                 
                                        }).ToList();

            var outpatientlist = (from op in db.Out_Patients
                                  join p in db.Reg_patients
                                 on op.Patient_ID equals p.pat_id
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
            foreach (var item in outpatientlist)
            {
                VitalParameterClass obj = new VitalParameterClass();
                obj.Pulse_Min = item.pulse_Min;
                obj.BP_mm_Hg = item.BP_mm_Hg;
                obj.Weight_Kg = item.Weight_Kg;
                obj.Height_Cm = item.Height_Cm;
                obj.Respiration_Min = item.Respiration_Min;
                obj.Temp_C = item.Temp_C;
                obj.L_M_P = item.L_M_P;
                obj.Receiving_date = DateTime.Now;
                obj.RN_Special_Instruction = "";
                obj.RN_Patient_General_Condition = "";
                obj.Created_Time = Convert.ToDateTime(item.Created_Time);
                obj.Status = "OutPatient";
                obj.BMI = item.BMI;
              
                list.Add(obj);
            }

            foreach (var item in EmergencyPatientList)
            {
                VitalParameterClass obj = new VitalParameterClass();
                obj.Rhythm = db.GetDataValueName("Emergency Rhythm", item.Emergency_Rhythm);
                obj.Volume = db.GetDataValueName("Emergency Volume", item.Emergency_Volume);
                obj.BP_mm_Hg = item.BloodPressure;
                obj.Rate_Beats = item.RateBeats;
                obj.OthersRcvNote = item.OthersRecieveNote;
                obj.O2_Saturation = item.O2_Saturation;
                obj.O2_Saturation_Oxygen1 = item.O2_Saturation_Oxygen1;
                obj.O2_Saturation_Oxygen2 = item.O2_Saturation_Oxygen2;

                obj.Respiration_Min = item.RespirationRate;
                obj.Temp_C = item.Temperature;
                obj.Receiving_date = Convert.ToDateTime(item.Receiving_Date);
                obj.RN_Special_Instruction = item.RN_Special_Instruction;
             
                obj.Status = "Emergency Patient";
                obj.user = item.user;
                list.Add(obj);
            }
            return (new JavaScriptSerializer()).Serialize(list);
        }

        [WebMethod]
        public static string LoadVitalParametersHistory(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatientID));

            var EmergencyPatientList = (from op in db.ReceivingNotes
                                        join p in db.Reg_patients
                                       on op.Patient_ID equals p.pat_id
                                        where p.Patient_No == Patien_No
                                           && op.Type_Nursing == "Receiving Note Emergency"
                                        select new
                                        {
                                            op.RateBeats,
                                            op.BloodPressure,
                                            op.Emergency_Rhythm,
                                            op.Emergency_Volume,
                                            op.OthersRecieveNote,
                                            op.RespirationRate,
                                            op.Temperature,
                                            op.Receiving_Date,
                                            op.RN_Special_Instruction,
                                            op.O2_Saturation,
                                            op.O2_Saturation_Oxygen1,
                                            op.O2_Saturation_Oxygen2,
                                            user = db.aspnet_Users.Where(x => x.UserId == op.user_id).Select(x => x.UserName).FirstOrDefault(),
                                        }).ToList();

            var outpatientlist = (from op in db.Out_Patients
                                  join p in db.Reg_patients
                                 on op.Patient_ID equals p.pat_id
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
            foreach (var item in outpatientlist)
            {
                VitalParameterClass obj = new VitalParameterClass();
                obj.Pulse_Min = item.pulse_Min;
                obj.BP_mm_Hg = item.BP_mm_Hg;
                obj.Weight_Kg = item.Weight_Kg;
                obj.Height_Cm = item.Height_Cm;
                obj.Respiration_Min = item.Respiration_Min;
                obj.Temp_C = item.Temp_C;
                obj.L_M_P = item.L_M_P;
                obj.Receiving_date = DateTime.Now;
                obj.RN_Special_Instruction = "";
                obj.RN_Patient_General_Condition = "";
                obj.Created_Time = Convert.ToDateTime(item.Created_Time);
                obj.Status = "OutPatient";
                obj.BMI = item.BMI;
                list.Add(obj);
            }

            foreach (var item in EmergencyPatientList)
            {
                VitalParameterClass obj = new VitalParameterClass();
                obj.Rhythm = db.GetDataValueName("Emergency Rhythm", item.Emergency_Rhythm);
                obj.Volume = db.GetDataValueName("Emergency Volume", item.Emergency_Volume);
                obj.BP_mm_Hg = item.BloodPressure;
                obj.Rate_Beats = item.RateBeats;
                obj.OthersRcvNote = item.OthersRecieveNote;
                obj.O2_Saturation = item.O2_Saturation;
                obj.O2_Saturation_Oxygen1 = item.O2_Saturation_Oxygen1;
                obj.O2_Saturation_Oxygen2 = item.O2_Saturation_Oxygen2;
                obj.Respiration_Min = item.RespirationRate;
                obj.Temp_C = item.Temperature;
                obj.Receiving_date = Convert.ToDateTime(item.Receiving_Date);
                obj.RN_Special_Instruction = item.RN_Special_Instruction;
                obj.Status = "Emergency Patient";
                obj.user = item.user;
                list.Add(obj);
            }
            return (new JavaScriptSerializer()).Serialize(list);
        }

        [WebMethod]
        public static string LoadDischargeNoteHistory(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatientID));

            var EmergencyPatCaselist = (from op in db.Emergency_Patients
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
                                            op.Expected_Discharge_Date,
                                            op.TreatmentAtDischarge,
                                            op.Procedure_Recommended,
                                            op.CauseOfReferral,
                                            Reffer_To = db.GetDataValueName("Referred To", op.Reffer_To),
                                            op.FollowUpPlanInstructions,
                                            Discharge_Status = db.GetDataValueName("Discharge Status", op.Discharge_Status),

                                        }).ToList();
            return ((new JavaScriptSerializer()).Serialize(EmergencyPatCaselist));
        }

        public class EmergPatientExamDetail
        {
            public string HMFIntact { get; set; }
            public string CranialNerves { get; set; }
            public string SignsOfMeningism { get; set; }
            public string HeartSound { get; set; }
            public string Arrhythmias { get; set; }
            public string Murmur { get; set; }
            public string AnyOtherAddedSound { get; set; }
            public string AnyOtherFindings { get; set; }
            public string Wheeze { get; set; }
            public string Ranchi { get; set; }
            public string AnyOtherSound { get; set; }
            public string AbdomenSoft { get; set; }
            public string Tenderness { get; set; }
            public string Guarding { get; set; }
            public string BowelSound { get; set; }
            public string Distention { get; set; }
            public string FluidThrill { get; set; }
            public string ShiftingDullness { get; set; }
            public string EpigastriaDiscomfort { get; set; }
            public string RetrosternalBurning { get; set; }
            public string Jondus { get; set; }
            public string Pallor { get; set; }
            public string Dehydration { get; set; }
            public string GCSOrientation { get; set; }
            public string Conscious_Orientely { get; set; }
            public string NVB_Right { get; set; }
            public string NVB_Left { get; set; }
            public string Crepitation_Right { get; set; }
            public string Crepitation_Left { get; set; }
            public string FurtherExplanation { get; set; }

        }

        [WebMethod]
        public static string LoadExaminationHistory(int PatientID)  
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            int Patient_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatientID));

            var EmergencyPatientExamList = (from ep in db.Emergency_Patients
                                            join pat in db.Reg_patients
                                            on ep.Patient_ID equals pat.pat_id
                                            where pat.Patient_No == Patient_No
                                            select new
                                            {
                            
                                                HMFIntact = ep.HMFIntact == null ? "none" : (ep.HMFIntact == true ? "Yes" : "False"),
                                                CranialNerves = ep.CranialNerves == null ? "none" : (ep.CranialNerves == true ? "Yes" : "No"),
                                                SignsOfMeningism = ep.SignsOfMeningism == null ? "none" : (ep.SignsOfMeningism == true ? "Yes" : "No"),
                                                HeartSound = ep.HeartSound == null ? "none" : (ep.HeartSound == true ? "Yes" : "No"),
                                                Arrhythmias = ep.Arrhythmias == null ? "none" : (ep.Arrhythmias == true ? "Yes" : "No"),
                                                Murmur = ep.Murmur == null ? "none" : (ep.Murmur == true ? "Yes" : "No"),
                                                AnyOtherAddedSound = ep.AnyOtherAddedSound == null ? "none" : (ep.AnyOtherAddedSound == true ? "Yes" : "No"),
                                                AnyOtherFindings = ep.AnyOtherFindings == null ? "none" : (ep.AnyOtherFindings == true ? "Yes" : "No"),
                                                Wheeze = ep.Wheeze == null ? "none" : (ep.Wheeze == true ? "Yes" : "No"),
                                                Ranchi = ep.Ranchi == null ? "none" : (ep.Ranchi == true ? "Yes" : "No"),
                                                AnyOtherSound = ep.AnyOtherSound == null ? "none" : (ep.AnyOtherSound == true ? "Yes" : "No"),
                                                AbdomenSoft = ep.AbdomenSoft == null ? "none" : (ep.AbdomenSoft == true ? "Yes" : "No"),
                                                Tenderness = ep.Tenderness == null ? "none" : (ep.Tenderness == true ? "Yes" : "No"),
                                                Guarding = ep.Guarding == null ? "none" : (ep.Guarding == true ? "Yes" : "No"),
                                                BowelSound = ep.BowelSound == null ? "none" : (ep.BowelSound == true ? "Yes" : "No"),
                                                Distention = ep.Distention == null ? "none" : (ep.Distention == true ? "Yes" : "No"),
                                                FluidThrill = ep.FluidThrill == null ? "none" : (ep.FluidThrill == true ? "Yes" : "No"),
                                                ShiftingDullness = ep.ShiftingDullness == null ? "none" : (ep.ShiftingDullness == true ? "Yes" : "No"),
                                                EpigastriaDiscomfort = ep.EpigastriaDiscomfort == null ? "none" : (ep.EpigastriaDiscomfort == true ? "Yes" : "No"),
                                                RetrosternalBurning = ep.RetrosternalBurning == null ? "none" : (ep.RetrosternalBurning == true ? "Yes" : "No"),
                                                Jondus = ep.Jondus == null ? "none" : (ep.Jondus == true ? "Yes" : "No"),
                                                Pallor = ep.Pallor == null ? "none" : (ep.Pallor == true ? "Yes" : "No"),
                                                Dehydration = ep.Dehydration == null ? "none" : (ep.Dehydration == true ? "Yes" : "No"),
                                                GCSOrientation = ep.GCSOrientation == null ? "none" : (ep.GCSOrientation == true ? "Yes" : "No"),
                                                Conscious_Orientely = ep.Conscious_Orientely == null ? "none" : (ep.Conscious_Orientely == true ? "Yes" : "No"),
                                                NVB_Right = ep.NVB_Right == null ? "none" : (ep.NVB_Right == true ? "Yes" : "No"),
                                                NVB_Left = ep.NVB_Left == null ? "none" : (ep.NVB_Left == true ? "Yes" : "No"),
                                                Crepitation_Right = ep.Crepitation_Right == null ? "none" : (ep.Crepitation_Right == true ? "Yes" : "No"),
                                                Crepitation_Left = ep.Crepitation_Left == null ? "none" : (ep.Crepitation_Left == true ? "Yes" : "No"),
                                                FurtherExplanation = ep.FurtherExplanation == null ? "none" : ep.FurtherExplanation
                                            }).ToList();


            return new JavaScriptSerializer().Serialize(EmergencyPatientExamList);

        }

        public class MedicationClass
        {
            public string chkDiccharge;
            public string AttendingParamedical_Staff;
            public string Frequency;
            public string Emergency_Patient_Medicine_ID;
            public DateTime Medicine_Date;
            public string Injections;
            public string Medicine_Name;
            public string Oral;
            public int Patient_ID;
            public string Recomended_Dosage;
            public string Created_Time;
            public string Doctor_ID;
            public string DoctorName;
            public string Status { get; set; }
            public string Dosage_From { get; set; }
            public string Dosage_Qty { get; set; }
            public string Other_Instruction { get; set; }

        }
        [WebMethod]
        public static string LoadMedicinesForHistoryNursing(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatmedicineList = (from pm in db.In_Patient_Medicines
                                         join op in db.Emergency_Patients
                                         on pm.Patient_ID equals op.Emergency_ID
                                         where op.Patient_ID == PatientID && pm.Transaction_Type == "Emergency Patient" && (pm.Assigned==null || pm.Assigned==false)
                                         select new { pm.chkDiccharge, pm.AttendingParamedical_Staff, pm.Frequency, pm.In_Patient_Medicine_ID, pm.Injections, pm.Medicine_Date, pm.Medicine_Name, pm.Oral, pm.Patient_ID, pm.Recomended_Dosage, op.Created_Time, pm.Doctor_ID, DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(op.Doctor) select d.Emp_Name).FirstOrDefault() }).ToList();

                return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
            }
            return "";
        }

        [WebMethod]
        public static string LoadMedicinesForHistory(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {

                int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatientID));

                var inPatmedicineList = (from pm in db.In_Patient_Medicines
                                         join op in db.Emergency_Patients
                                         on pm.Patient_ID equals op.Emergency_ID
                                         join p in db.Reg_patients
                                         on op.Patient_ID equals p.pat_id
                                         where p.Patient_No == Patien_No && pm.Transaction_Type == "Emergency Patient"
                                         select new { pm.chkDiccharge, pm.AttendingParamedical_Staff, pm.Frequency, pm.In_Patient_Medicine_ID, pm.Injections, pm.Medicine_Date, pm.Medicine_Name, pm.Oral, pm.Patient_ID, pm.Recomended_Dosage, pm.Dosage_From, pm.Dosage_Qty, pm.Other_Instruction, op.Created_Time, pm.Doctor_ID, DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(pm.Doctor_ID) select d.Emp_Name).FirstOrDefault() }).ToList();


                var OutPatmedicineList = (from pm in db.In_Patient_Medicines
                                          join op in db.Out_Patients
                                          on pm.Patient_ID equals op.Out_Patient_ID
                                          join p in db.Reg_patients
                                          on op.Patient_ID equals p.pat_id
                                          where p.Patient_No == Patien_No && pm.Transaction_Type == "Emergency Patient"
                                          select new { pm.chkDiccharge, pm.AttendingParamedical_Staff, pm.Frequency, pm.In_Patient_Medicine_ID, pm.Injections, pm.Medicine_Date, pm.Medicine_Name, pm.Oral, pm.Patient_ID, pm.Recomended_Dosage, pm.Dosage_From, pm.Dosage_Qty, pm.Other_Instruction, op.Created_Time, pm.Doctor_ID, DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(pm.Doctor_ID) select d.Emp_Name).FirstOrDefault() }).ToList();


                List<MedicationClass> list = new List<MedicationClass>();
                foreach (var item in inPatmedicineList)
                {
                    MedicationClass obj = new MedicationClass();

                    obj.AttendingParamedical_Staff = item.AttendingParamedical_Staff;
                    obj.Frequency = item.Frequency;
                    obj.Medicine_Date = Convert.ToDateTime(item.Medicine_Date);
                    obj.Injections = item.Injections;

                    obj.Medicine_Name = item.Medicine_Name;
                    obj.Oral = item.Oral;

                    obj.Recomended_Dosage = item.Recomended_Dosage;
                    obj.Dosage_From = item.Dosage_From;
                    obj.Dosage_Qty = item.Dosage_Qty;
                    obj.Other_Instruction = item.Other_Instruction;
                    obj.Status = "Emergency Patient";

                    list.Add(obj);
                }
                foreach (var item in OutPatmedicineList)
                {
                    MedicationClass obj = new MedicationClass();

                    obj.AttendingParamedical_Staff = item.AttendingParamedical_Staff;
                    obj.Frequency = item.Frequency;
                    obj.Medicine_Date = Convert.ToDateTime(item.Medicine_Date);
                    obj.Injections = item.Injections;

                    obj.Medicine_Name = item.Medicine_Name;
                    obj.Oral = item.Oral;

                    obj.Recomended_Dosage = item.Recomended_Dosage;
                    obj.Dosage_From = item.Dosage_From;
                    obj.Dosage_Qty = item.Dosage_Qty;
                    obj.Other_Instruction = item.Other_Instruction;

                    obj.Status = "Emergency Patient"; 
                    list.Add(obj);
                }
                return (new JavaScriptSerializer()).Serialize(list);
            }
            return "";
        }

        [WebMethod]
        public static string LoadDoctorNoteDetail(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var DoctorNoteDetails = (from pm in db.Emergency_Doctor_Notes
                                         join op in db.Emergency_Patients
                                         on pm.EmergencyId equals op.Emergency_ID
                                         where op.Patient_ID == PatientID
                                         select new { pm.DoctorMobile, pm.DoctorNotes, DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(pm.DoctorToCall) select d.Emp_Name).FirstOrDefault(), DepartmentName = db.GetDataValueName("Patient Main Category", pm.Department) }).ToList();

                return (new JavaScriptSerializer()).Serialize(DoctorNoteDetails);
            }
            return "";
        }

     

        [WebMethod]
        public static string LoadLabResultrptDetail(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatmedicineList = (from pm in db.Lab_Resultrpts
                                         join op in db.Emergency_Patients
                                         on pm.EmergencyID equals op.Emergency_ID
                                         where op.Emergency_ID == PatientID
                                         select new { pm.Lab_Resultrpt_ID, Lab_Resultrpt = db.GetDataValueName("Lab Result", pm.Lab_Resultrpt_ID), pm.Lab_Resultrpt_Name }).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
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
                            EmergencyID= data.Emergency_Patient_ID,
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
                                         where pm.EmergencyID == id
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
                            join outP in db.Emergency_Patients on tbl.pat_id equals outP.Patient_ID
                            where outP.Emergency_ID == OUTPatientID
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
                                //Patient_Type = (from d in db.DataValues join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID where v.ValueSet_Name == "Patient Type" && d.DataValue_Name == tbl. select d.DataValue_Description).FirstOrDefault(), tibit
                                tbl.Age_years,
                                tbl.Permanent_Address,
                                tbl.val_area,
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
                    if (Data.Room_Name == null)
                    {
                        recieptP.Room_Name = "";
                    }
                    else
                    {
                        recieptP.Room_Name = Data.Room_Name.ToString();
                    }
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
                    //recieptP.Patient_Type = Data.Patient_Type;
                    recieptP.Age_years = Data.Age_years;
                    recieptP.Permanent_Address = Data.Permanent_Address.ToString();
                    recieptP.Temporary_Address = Data.val_area.ToString();
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
                                         join op in db.Emergency_Patients
                                         on pm.Patient_ID equals op.Emergency_ID
                                         where op.Patient_ID == PatientID && pm.Transaction_Type == "Emergency Patient" && pm.Patient_ID == oUTID && pm.chkDiccharge == false
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
                                     join op in db.Emergency_Patients
                                     on pm.Patient_ID equals op.Emergency_ID
                                     where op.Patient_ID == PatientID && pm.Transaction_Type == "Emergency Patient" && pm.Patient_ID == oUTID && pm.chkDiccharge == true
                                     select new { pm.AttendingParamedical_Staff, pm.Frequency, pm.In_Patient_Medicine_ID, pm.Injections, pm.Medicine_Date, pm.Medicine_Name, pm.Oral, pm.Patient_ID, pm.Recomended_Dosage, op.Created_Time }).ToList();
            return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
        }


    }
}