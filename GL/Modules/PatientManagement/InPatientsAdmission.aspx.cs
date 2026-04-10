using CrystalDecisions.CrystalReports.Engine;
using CrystalDecisions.Shared;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class InPatientsAdmission : System.Web.UI.Page
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
                // Initializing controls with default values
                txtExpected_Discharge_Date.Text = DateTime.Now.Date.ToString(AppConfig.DateFormat);
                txtAdmission_Date.Text = DateTime.Now.ToString();
                txtReceiving_Date.Text = DateTime.Now.ToString();
                txtDischarge_On.Text = DateTime.Now.ToString();
                txtMo_Date.Text = DateTime.Now.ToString();
                txtExpected_Discharge_Date.Text = DateTime.Now.Date.ToString(AppConfig.DateFormat);
                txtadmissionfee.Text = Convert.ToString(
                        (from tbl in db.sys_Parms
                         where tbl.Name == "In Patient Fee"
                         select tbl.Code).FirstOrDefault());

                BindingDropDown();
                BlankForm();

                // Handle query string and populate data if present
                if (Request.QueryString["ID"] != null)
                {
                    string QS = id.Split('=')[1];
                    PopulateInPatientData(Convert.ToInt32(QS));
                    InPatient_Case_id = Convert.ToInt32(QS);
                    ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "", "FillInstruction();", true);
                }
            }
            else
            {
                // Ensure the else block does not interfere with dropdown postback
                // No need to call methods like BindingDropDown or PopulateInPatientData here unless absolutely necessary.
            }
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

            DataTable dtPanels = DBClass.getDataTable("Select Panel_ID,Company_Name from Panel");
            ddlpanelcompanys.DataSource = dtPanels;

            ddlpanelcompanys.DataTextField = "Company_Name";
            ddlpanelcompanys.DataValueField = "Panel_ID";
            ddlpanelcompanys.Items.Add(new ListItem("Please Select", "0"));
            ddlpanelcompanys.DataBind();

            valueset = DBClass.GetValueSet("Laundary From To");
            ddlIssuance_Of.DataSource = valueset;
            ddlIssuance_Of.DataTextField = "DataValue_Description";
            ddlIssuance_Of.DataValueField = "DataValue_Name";
            ddlIssuance_Of.Items.Add(new ListItem("Please Select", "0"));
            ddlIssuance_Of.DataBind();

            ddlReferTo.DataSource = valueset;
            ddlReferTo.DataTextField = "DataValue_Description";
            ddlReferTo.DataValueField = "DataValue_Name";
            ddlReferTo.Items.Add(new ListItem("Please Select", "0"));
            ddlReferTo.DataBind();




            valueset = DBClass.GetValueSet("Patient Main Category");
            ddlDepartment.DataSource = valueset;
            ddlDepartment.DataTextField = "DataValue_Description";
            ddlDepartment.DataValueField = "DataValue_Name";
            ddlDepartment.Items.Add(new ListItem("Please Select", "0"));
            ddlDepartment.DataBind();


            //valueset = DBClass.GetValueSet("Mode Of Registration");
            //ddl_mainCategory.DataSource = valueset;
            //ddl_mainCategory.DataTextField = "DataValue_Description";
            //ddl_mainCategory.DataValueField = "DataValue_Name";
            //ddl_mainCategory.Items.Add(new ListItem("Please Select", "0"));
            //ddl_mainCategory.DataBind();

            valueset = DBClass.GetValueSet("Mode Of Registration");
            ddl_mainCategory.DataSource = valueset;
            ddl_mainCategory.DataTextField = "DataValue_Description";
            ddl_mainCategory.DataValueField = "DataValue_Name";
            ddl_mainCategory.DataBind();

            ddl_mainCategory.Items.Insert(0, new ListItem("Please Select", "0"));

            if (ddl_mainCategory.Items.FindByValue("03") != null)
            {
                ddl_mainCategory.SelectedValue = "03";
            }

            valueset = DBClass.GetValueSet("IPD PacakgeType");
            ddlpacakagetype.DataSource = valueset;
            ddlpacakagetype.DataTextField = "DataValue_Description";
            ddlpacakagetype.DataValueField = "DataValue_Name";
            ddlpacakagetype.Items.Add(new ListItem("Please Select", "0"));
            ddlpacakagetype.DataBind();
            
            valueset = DBClass.GetValueSet("IPD Procedures");
            ddlipdProcedures.DataSource = valueset;
            ddlipdProcedures.DataTextField = "DataValue_Description";
            ddlipdProcedures.DataValueField = "DataValue_Name";
            ddlipdProcedures.Items.Add(new ListItem("Please Select", "0"));
            ddlipdProcedures.DataBind();

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
            valueset = DBClass.GetValueSet("Doctor Status");
            ddlMO_Doctor_Status.DataSource = valueset;
            ddlMO_Doctor_Status.DataTextField = "DataValue_Description";
            ddlMO_Doctor_Status.DataValueField = "DataValue_Name";
            ddlMO_Doctor_Status.Items.Add(new ListItem("Select", "0"));
            ddlMO_Doctor_Status.DataBind();

           

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
                    ddlMo_Doctor_Name.Items.Clear();
                    ddlMo_Doctor_Name.DataSource = loginEmpName;
                    ddlMo_Doctor_Name.DataTextField = "Emp_Name";
                    ddlMo_Doctor_Name.DataValueField = "Emp_ID";

                    ddlMo_Doctor_Name.DataBind();
                }

                var Empstatus = (from tbl in db.HR_Employees
                                 where tbl.IsDoctor == true && tbl.Emp_No == EmpCode
                                 select tbl.Designation).FirstOrDefault();


                ddlMO_Doctor_Status.SelectedValue = Empstatus;

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

            ddlDeathCertifiedbyDr1.Items.Clear();
            ddlDeathCertifiedbyDr1.DataSource = EmpList;
            ddlDeathCertifiedbyDr1.DataTextField = "Emp_Name";
            ddlDeathCertifiedbyDr1.DataValueField = "Emp_ID";
            ddlDeathCertifiedbyDr1.Items.Add(new ListItem("Please Select", "0"));
            ddlDeathCertifiedbyDr1.DataBind();

            ddlDeathCertifiedbyDr2.Items.Clear();
            ddlDeathCertifiedbyDr2.DataSource = EmpList;
            ddlDeathCertifiedbyDr2.DataTextField = "Emp_Name";
            ddlDeathCertifiedbyDr2.DataValueField = "Emp_ID";
            ddlDeathCertifiedbyDr2.Items.Add(new ListItem("Please Select", "0"));
            ddlDeathCertifiedbyDr2.DataBind();

            valueset = DBClass.GetValueSet("Room Type");

            txtRoom_Type.DataSource = valueset;
            txtRoom_Type.DataTextField = "DataValue_Description";
            txtRoom_Type.DataValueField = "DataValue_Name";
            txtRoom_Type.Items.Add(new ListItem("Please Select", "0"));
            txtRoom_Type.DataBind();
            ddlRoomType.DataSource = valueset;
            ddlRoomType.DataTextField = "DataValue_Description";
            ddlRoomType.DataValueField = "DataValue_Name";
            ddlRoomType.Items.Add(new ListItem("Please Select", "0"));
            ddlRoomType.DataBind();

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

            valueset = DBClass.GetValueSet("Place Of Death");
            ddlPlaceOfDeath.DataSource = valueset;
            ddlPlaceOfDeath.DataTextField = "DataValue_Description";
            ddlPlaceOfDeath.DataValueField = "DataValue_Name";
            ddlPlaceOfDeath.Items.Add(new ListItem("Please Select", "0"));
            ddlPlaceOfDeath.DataBind();

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

            valueset = DBClass.GetValueSet("Lab Result");
            ddlLabResult.DataSource = valueset;
            ddlLabResult.DataTextField = "DataValue_Description";
            ddlLabResult.DataValueField = "DataValue_Name";
            ddlLabResult.Items.Add(new ListItem("Select", "0"));
            ddlLabResult.DataBind();

            List<Room> rooms = (from tbl in db.Rooms
                                select tbl).ToList();
            ddlRoom_No.DataSource = rooms;
            ddlRoom_No.DataTextField = "Room_No";
            ddlRoom_No.DataValueField = "Room_ID";
            ddlRoom_No.Items.Add(new ListItem("Please Select", "0"));
            ddlRoom_No.DataBind();

            ddlroom.DataSource = rooms;
            ddlroom.DataTextField = "Room_No";
            ddlroom.DataValueField = "Room_ID";
            ddlroom.Items.Add(new ListItem("Please Select", "0"));
            ddlroom.DataBind();



            var wards = (from tbl2 in db.Ward_Definitions
                         select tbl2).ToList();
            ddlWard_No.DataSource = wards;
            ddlWard_No.DataTextField = "Ward_Type";
            ddlWard_No.DataValueField = "Ward_ID";
            ddlWard_No.Items.Add(new ListItem("Please Select", "0"));
            ddlWard_No.DataBind();
            ddlwards.DataSource = wards;
            ddlwards.DataTextField = "Ward_No";
            ddlwards.DataValueField = "Ward_ID";
            ddlwards.Items.Add(new ListItem("Please Select", "0"));
            ddlwards.DataBind();

            valueset = DBClass.GetValueSet("Patient Type");
            ddlPatientType.DataSource = valueset;
            ddlPatientType.DataTextField = "DataValue_Description";
            ddlPatientType.DataValueField = "DataValue_Name";
            ddlPatientType.Items.Add(new ListItem("Select Type", "0"));
            ddlPatientType.DataBind();

            valueset = DBClass.GetValueSet("Sehat Sahulat Admission Type");
            ddl_AdmissionType.DataSource = valueset;
            ddl_AdmissionType.DataTextField = "DataValue_Description";
            ddl_AdmissionType.DataValueField = "DataValue_Name";
            ddl_AdmissionType.Items.Add(new ListItem("Select Type", "0"));
            ddl_AdmissionType.DataBind();

        }

        public void BlankForm()
        {
            ddlIssuance_Of.SelectedIndex = 0;
            ddlRoom_No.SelectedIndex = 0;
            ddlPlaceOfDeath.SelectedIndex = 0;
            txtRoom_Type.SelectedIndex = 0;
            ddlWard_No.SelectedIndex = 0;
            txtBed_No.Text = "";
            ddlDepartment.SelectedIndex = 0;
           
            txtHealth_Complaints.Text = "";
            txttxtReceiving_DateDesc.Text = DateTime.Now.ToString();
            txtExpected_Discharge_Date.Text = DateTime.Now.Date.ToString(AppConfig.DateFormat);
            txtAdmission_Date.Text = DateTime.Now.ToString();
          
            ddlVolume.SelectedIndex = 0;
            ddlRhythm.SelectedIndex = 0;
            ddlDepartment.SelectedIndex = 0;
            ddlDoctor.SelectedIndex = 0;
            txtHealth_Complaints.Text = "";
            txtExpected_Discharge_Date.Text = DateTime.Now.Date.ToString(AppConfig.DateFormat);
            txtOperation_No.Text = "";
            ddlPerformed_By.SelectedIndex = 0;
            txtBrief_Description.Text = "";
            txtSurgeon_Note.Text = "";
            txtPost_Operative_Care.Text = "";
            cbShifted_To_ICU.Checked = false;
            cbShifted_To_CCU.Checked = false;
            cbShifted_To_Observation_Room.Checked = false;
            //Tab 4
            ddlDischarge_By.SelectedIndex = 0;
            ddlRhythmdischarge.SelectedIndex = 0;
            ddlvolumedisc.SelectedIndex = 0;
            txtPrevention_Precaution.Text = "";
            txtNext_Visit.Text = "";
            cbDeath_Certificate.Checked = false;
            txtBilling.Text = "";
            ddlMo_Doctor_Name.SelectedIndex = 0;
            txtMo_Date.Text = DateTime.Now.ToString();
            ddlDeathCertifiedbyDr1.SelectedIndex = 0;
            ddlDeathCertifiedbyDr2.SelectedIndex = 0;
        }

       


        private void PopulateInPatientData(int InPatient_ID)
        {
            try
            {
                db = new DataBaseDataContext(DBClass.ConnectionString());
                var qry = db.sp_GetInPatientDetail(InPatient_ID).FirstOrDefault();
                #region Old code
                
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
                    txtDiscount.Text = Convert.ToString(qry.Discount);
                    if (qry.Entry_Date == null)
                        vLbl_RegDate.Text = qry.Created_Time.Value.ToString(AppConfig.DateFormat);
                    else
                        vLbl_RegDate.Text = qry.Entry_Date.Value.ToString(AppConfig.DateFormat);
                    txtAdmission_Date.Text = qry.Admission_Date.Value.ToString();
                    
                    ddlIssuance_Of.SelectedValue = qry.Issuance_Of;
                    ddlPatientType.SelectedValue = qry.Patient_Discount_Type;
                    ddlPatientType.Enabled = false;


                    if (ddlPatientType.SelectedValue == "03")
                    {
                          panelshow.Style["display"] = "block";
                    }
                    vLbl_Patient_Type.Text = db.GetDataValueName("Patient Type", qry.Patient_Type);
                    vLbl_Patient_AdmitCatagory.Text = db.GetDataValueName("Patient Type", qry.Patient_Discount_Type);
                    if (qry.Issuance_Of == "002")
                    {
                        ddlRoom_No.SelectedValue = qry.Room_ID.ToString();
                        txtRoom_Type.SelectedValue = qry.Room_Type.ToString();
                    }
                    if (qry.Issuance_Of == "001")
                    {
                        ddlWard_No.SelectedValue = qry.Ward_ID.ToString();
                        if (qry.Bed_No != null && qry.Bed_No != 0)
                            txtBed_No.Text = qry.Bed_No.ToString();
                    }
                    ddlDepartment.SelectedValue = qry.Department;
                    db = new DataBaseDataContext(DBClass.ConnectionString());
                    List<HR_Employee> EmpList = new List<HR_Employee>();
                    EmpList = (from tbl in db.HR_Employees
                               where (tbl.IsDoctor == true
                               && tbl.Department == ddlDepartment.SelectedValue )
                               select tbl).ToList();
                    ddlDoctor.Items.Clear();
                    ddlDoctor.DataSource = EmpList;
                    ddlDoctor.DataTextField = "Emp_Name";
                    ddlDoctor.DataValueField = "Emp_ID";
                    ddlDoctor.Items.Add(new ListItem("Please Select", "0"));
                    ddlDoctor.DataBind();
                    ddlDoctor.SelectedValue = qry.Doctor;
                    ddl_mainCategory.SelectedValue = qry.patient_main_department;
                    ddlpacakagetype.SelectedValue = qry.packagae_type;
                    ddlpackagename.SelectedValue = Convert.ToString(qry.packagae_name);
                    ddlipdProcedures.SelectedValue = qry.ipd_Procedure;
                    txtprocedurename.Text = qry.Procedure_Desc;

                    txtVisitId.Text = qry.VisitId;
                  
                    ddlpacakagetype_SelectedIndexChanged();
                    txtSehatCardNo.Text = qry.SehatCardNo;
                    txtSehatHolder.Text = qry.Sehat_Card_Holder_CNIC;
                    ddl_AdmissionType.SelectedValue = qry.AdmissionType == null ? "0" : qry.AdmissionType;
                    txtPolicyHolderName.Text = qry.PolicyHolderName;
                    txtcardHolderName.Text = qry.CardHolderName;
                    txtInsuranceCardNo.Text = qry.InsuranceCardNo;
                    ddlpanelcompanys.SelectedValue = qry.Panel_Company;
                    cardno.Text = qry.InsuranceCardNo;
                    txtcardHolderName.Text = qry.CardHolderName;
                    txtcompanyname.Text = qry.CompanyNAme;
                    txtroomlimit.Text = qry.RoomLimit;
                    txtapprovelimit.Text = qry.ApproveLimit;
                    txtcardlimit.Text = qry.CardLimit;
                    txtapprovedays.Text = qry.ApproveDays;
                    txtpvtcharges.Text = qry.Private_Charges_instruction;
                    txtadvamount.Text = Convert.ToString(qry.Advance_Amount);
                    if (!string.IsNullOrEmpty(qry.Patient_Discount_Type) && qry.Patient_Discount_Type == "10")
                    {
                        ddlPanelCompany.SelectedValue = string.IsNullOrEmpty(qry.Panel_Company) ? "0" : qry.Panel_Company;
                    }
                    if (qry.Guardian_Id > 0)
                    {
                        hdnGuardianId.Value = qry.Guardian_Id.ToString();
                        txtGuardianName.Text = qry.G_Name ?? string.Empty;
                        txtG_Relationship.Text = qry.G_RelationShip ?? string.Empty;
                        txtG_Address.Text = qry.G_Address ?? string.Empty;
                        txtG_CNIC.Text = qry.G_CNIC ?? string.Empty;
                        txtG_Phone.Text = qry.G_Phone ?? string.Empty;
                    }
                    else
                    {
                        hdnGuardianId.Value = "0";
                        txtGuardianName.Text = string.Empty;
                        txtG_Relationship.Text = string.Empty;
                        txtG_Address.Text = string.Empty;
                        txtG_CNIC.Text = string.Empty;
                        txtG_Phone.Text = string.Empty;
                    }


                    txtHealth_Complaints.Text = qry.Health_Complaints;
                    if (qry.Expected_Discharge_Date != null)
                        txtExpected_Discharge_Date.Text = qry.Expected_Discharge_Date.Value.ToString(AppConfig.DateFormat);

                    #region old Code
                   

                    #endregion

                }
            }
            catch (Exception ex)
            {
                lblMessage.CssClass = "errorMessage";
                lblMessage.Text = ex.Message;
            }
        }
        [WebMethod]
        public static string LoadBirthCertificateData(string InPatientID)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var result = (from ip in db.In_Patients
                                  where ip.In_Patient_ID.ToString() == InPatientID
                                  select new
                                  {
                                      ip.Birth_Child_Name,
                                      ip.Birth_Gender,
                                      ip.Birth_Date,
                                      ip.Birth_Time,
                                      ip.Birth_Place,
                                      ip.Birth_Weight,
                                      ip.Birth_Type,
                                      ip.Birth_Order,
                                      ip.Birth_Father_Name,
                                      ip.Birth_Father_CNIC,
                                      ip.Birth_Father_Occupation,
                                      ip.Birth_Father_Nationality,
                                      ip.Birth_Mother_Name,
                                      ip.Birth_Mother_CNIC,
                                      ip.Birth_Mother_Occupation,
                                      ip.Birth_Mother_Nationality,
                                      ip.Birth_Reg_Number,
                                      ip.Birth_Reg_Date,
                                      ip.Birth_Registrar,
                                      ip.Birth_Union_Council,
                                      ip.Birth_Address,
                                      ip.Birth_City,
                                      ip.Birth_Province,
                                      ip.Birth_Postal_Code,
                                      ip.Birth_Religion,
                                      ip.Birth_Attendant,
                                      ip.Birth_Remarks
                                  }).FirstOrDefault();

                    if (result != null)
                    {
                        return Newtonsoft.Json.JsonConvert.SerializeObject(result);
                    }
                    return "null";
                }
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
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
        private void ddlpacakagetype_SelectedIndexChanged()
        {
            try
            {
                string selectedPackageType = ddlpacakagetype.SelectedValue;
                if (!string.IsNullOrEmpty(selectedPackageType))
                {
                    using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                    {
                        var packageNames = new List<dynamic>();

                      
                        if (selectedPackageType == "01") 
                        {
                            packageNames = db.DoctorPackages
                                .Select(p => new
                                {
                                    PackageID = p.Doc_Packages_ID, 
                    PackageName = p.Package_Name ?? "Unknown Package"
                                })
                                .AsEnumerable() 
                                .Select(p => (dynamic)p)
                                .ToList();
                        }

                        // Clear the dropdown and add a default item
                        ddlpackagename.Items.Clear();
                        ddlpackagename.Items.Add(new ListItem("Please Select", "0"));

                        // Bind the dropdown if packageNames has data
                        if (packageNames.Any())
                        {
                            ddlpackagename.DataSource = packageNames;
                            ddlpackagename.DataTextField = "PackageName";
                            ddlpackagename.DataValueField = "PackageID";
                            ddlpackagename.DataBind();
                        }
                    }
                }

                else
                {
                    // Clear the dropdown and add default item if no package type is selected
                    ddlpackagename.Items.Clear();
                    ddlpackagename.Items.Add(new ListItem("Please Select", "0"));
                }
            }
            catch (Exception ex)
            {
                // Display error message
                lblMessage.CssClass = "errorMessage";
                lblMessage.Text = ex.Message;
            }
        }


        [WebMethod]
        public static string loadDoctorPacakges(string pkg_type)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatmedicineList = (from emp in db.DoctorPackages
                                         select new { emp.Doc_Packages_ID, emp.Package_Name }).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
            }
            return "";
        } 
        [WebMethod]
        public static string loadDepartmentPacakges(string pkg_type)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatmedicineList = (from emp in db.DepartmentPackages
                                         select new { emp.Dep_Packages_ID, emp.Package_Name }).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
            }
            return "";
        } 
        [WebMethod]
        public static string loadpanelpackages(string pkg_type)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatmedicineList = (from emp in db.PanelPackages
                                         select new { emp.Pan_Packages_ID, emp.Package_Name }).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
            }
            return "";
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
                          on op.Reg_PatId equals p.pat_id
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
                                    where OPD.Reg_PatId == Patient_ID
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


        [WebMethod]
        public static string SaveAllRecord(
      int Patient_ID, string btnsave, string txtAdmission_Date, string patient_name,
      string patient_age, string patient_number, string ddlDepartment, string ddlDoctor,
      string txtHealth_Complaints, DateTime txtExpected_Discharge_Date, string ddlIssuance_Of,
      string ddlWard_No, string txtBed_No, string ddlRoom_No, string txtRoom_Type,
      string PatientDiscountType, string panelCompany, string admissionType, string sehatCardNo,
      string visitId, string CardHolderName, string InsuranceCardNo, string PolicyHolderName,
      string Sehat_Holder, string main_department, string packagetype, string packagename,
      string packagetypename, string packagenamess, string ipdProcedures, string proc_name,
      string panelcompanys, string CardNo, string Cardholdername, string CompanyName,
      string Approvelimit, string Roomlimit, string Cardlimit, string ApproveDays,
      string Discount, string Privatecharges,
      // Birth Certificate Parameters
      string BirthChildName, string BirthGender, string BirthDate, string BirthTime,
      string BirthPlace, string BirthWeight, string BirthType, string BirthOrder,
      string BirthFatherName, string BirthFatherCNIC, string BirthFatherOccupation,
      string BirthFatherNationality, string BirthMotherName, string BirthMotherCNIC,
      string BirthMotherOccupation, string BirthMotherNationality, string BirthRegNumber,
      string BirthRegDate, string BirthRegistrar, string BirthUnionCouncil,
      string BirthAddress, string BirthCity, string BirthProvince, string BirthPostalCode,
      string BirthReligion, string BirthAttendant, string BirthRemarks,bool isCertificateGenrate)
        {
            In_Patient OPD = null;
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var InPatientID = 0;
                try
                {
                    if (btnsave == "Save")
                    {
                        OPD = new In_Patient();
                        OPD.Patient_ID = Convert.ToInt32(Patient_ID);
                        OPD.IPD_No = DBClass.getMaxEntry_No("In_Patient", "IPD_No");

                        if (PatientDiscountType == "02")
                        {
                            var query = (from v in db.ValueSets
                                         join d in db.DataValues
                                         on v.ValueSet_ID equals d.ValueSet_ID
                                         where v.ValueSet_Name == "Patient Type"
                                         && (d.DataValue_Description == "Private")
                                         select d.Segment1).FirstOrDefault();
                        }
                        OPD.pat_name = patient_name;
                        OPD.pat_number = patient_number;
                        OPD.pat_age = patient_age;
                    }
                    else
                    {
                        OPD = (from tbl in db.In_Patients
                               where tbl.In_Patient_ID == InPatient_Case_id
                               select tbl).FirstOrDefault();
                        OPD.Updated_By = AppConfig.UserID;
                        OPD.Updated_Time = DateTime.Now;

                        if (PatientDiscountType == "02")
                        {
                            var query = (from v in db.ValueSets
                                         join d in db.DataValues
                                         on v.ValueSet_ID equals d.ValueSet_ID
                                         where v.ValueSet_Name == "Patient Type"
                                         && (d.DataValue_Description == "Private")
                                         select d.Segment1).FirstOrDefault();
                        }
                    }

                    string fee = DBClass.getParameter("In Patient Fee").ToString();
                    if (fee.Trim() == string.Empty)
                        fee = "0";

                    OPD.Admission_Fees = int.Parse(fee);
                    OPD.Admission_Date = Convert.ToDateTime(txtAdmission_Date);
                    OPD.Department = ddlDepartment;

                    decimal discountValue = 0;
                    if (!decimal.TryParse(Discount, out discountValue))
                    {
                        discountValue = 0;
                    }
                    OPD.Discount = discountValue;

                    if (ddlIssuance_Of == "001")
                    {
                        OPD.Ward_ID = Convert.ToInt32(ddlWard_No);
                        OPD.Bed_No = Convert.ToInt32(txtBed_No);
                        OPD.Room_ID = null;
                        OPD.Room_Type = null;
                        Room_Allocation Room = db.Room_Allocations.Where(w => w.Patient_ID == Patient_ID).FirstOrDefault();
                        if (Room != null)
                            Room.IsDischarge = true;
                    }
                    else if (ddlIssuance_Of == "003")
                    {
                        OPD.Ward_ID = Convert.ToInt32(ddlWard_No);
                        OPD.Bed_No = Convert.ToInt32(txtBed_No);
                        OPD.Room_ID = Convert.ToInt32(ddlRoom_No);
                        OPD.Room_Type = txtRoom_Type.ToString();
                    }
                    else
                    {
                        OPD.Room_ID = Convert.ToInt32(ddlRoom_No);
                        OPD.Room_Type = txtRoom_Type.ToString();
                        OPD.Ward_ID = null;
                        OPD.Bed_No = null;
                        Ward_Allocation ward = db.Ward_Allocations.Where(w => w.Patient_ID == Patient_ID).FirstOrDefault();
                        if (ward != null)
                            ward.IsDischarge = true;
                    }

                    OPD.Health_Complaints = txtHealth_Complaints;
                    OPD.Doctor = ddlDoctor;
                    OPD.patient_main_department = main_department;
                    OPD.packagae_type = packagetype;
                    OPD.Package_Type_Id = packagetypename;
                    OPD.packagae_name = packagename;
                    OPD.Package_Name_Id = packagenamess;
                    OPD.ipd_Procedure = ipdProcedures;
                    OPD.Procedure_Desc = proc_name;
                    OPD.Panel_Company = panelcompanys;
                    OPD.Issuance_Of = ddlIssuance_Of;
                    OPD.Patient_Discount_Type = PatientDiscountType;
                    OPD.Discharge = false;
                    OPD.Panel_Company = panelCompany;
                    OPD.InsuranceCardNo = CardNo;
                    OPD.CardHolderName = Cardholdername;
                    OPD.CompanyNAme = CompanyName;
                    OPD.ApproveLimit = Approvelimit;
                    OPD.RoomLimit = Roomlimit;
                    OPD.CardLimit = Cardlimit;
                    OPD.ApproveDays = ApproveDays;
                    OPD.Private_Charges_instruction = Privatecharges;
                    OPD.AdmissionType = admissionType;
                    OPD.SehatCardNo = sehatCardNo;
                    OPD.VisitId = visitId;
                    OPD.CardHolderName = CardHolderName;
                    OPD.InsuranceCardNo = InsuranceCardNo;
                    OPD.PolicyHolderName = PolicyHolderName;
                    OPD.Sehat_Card_Holder_CNIC = Sehat_Holder;
                    OPD.GenrateBirthCertificate = isCertificateGenrate;

                    // Birth Certificate Fields Assignment
                    OPD.Birth_Child_Name = string.IsNullOrEmpty(BirthChildName) ? null : BirthChildName;
                    OPD.Birth_Gender = string.IsNullOrEmpty(BirthGender) ? null : BirthGender;

                    if (!string.IsNullOrEmpty(BirthDate))
                    {
                        try
                        {
                            OPD.Birth_Date = Convert.ToDateTime(BirthDate);
                        }
                        catch
                        {
                            OPD.Birth_Date = null;
                        }
                    }
                    else
                    {
                        OPD.Birth_Date = null;
                    }

                    OPD.Birth_Time = string.IsNullOrEmpty(BirthTime) ? null : BirthTime;
                    OPD.Birth_Place = string.IsNullOrEmpty(BirthPlace) ? null : BirthPlace;

                    if (!string.IsNullOrEmpty(BirthWeight))
                    {
                        decimal weightValue;
                        if (decimal.TryParse(BirthWeight, out weightValue))
                        {
                            OPD.Birth_Weight = weightValue;
                        }
                        else
                        {
                            OPD.Birth_Weight = null;
                        }
                    }

                    OPD.Birth_Type = string.IsNullOrEmpty(BirthType) ? null : BirthType;
                    OPD.Birth_Order = string.IsNullOrEmpty(BirthOrder) ? null : BirthOrder;
                    OPD.Birth_Father_Name = string.IsNullOrEmpty(BirthFatherName) ? null : BirthFatherName;
                    OPD.Birth_Father_CNIC = string.IsNullOrEmpty(BirthFatherCNIC) ? null : BirthFatherCNIC;
                    OPD.Birth_Father_Occupation = string.IsNullOrEmpty(BirthFatherOccupation) ? null : BirthFatherOccupation;
                    OPD.Birth_Father_Nationality = string.IsNullOrEmpty(BirthFatherNationality) ? null : BirthFatherNationality;
                    OPD.Birth_Mother_Name = string.IsNullOrEmpty(BirthMotherName) ? null : BirthMotherName;
                    OPD.Birth_Mother_CNIC = string.IsNullOrEmpty(BirthMotherCNIC) ? null : BirthMotherCNIC;
                    OPD.Birth_Mother_Occupation = string.IsNullOrEmpty(BirthMotherOccupation) ? null : BirthMotherOccupation;
                    OPD.Birth_Mother_Nationality = string.IsNullOrEmpty(BirthMotherNationality) ? null : BirthMotherNationality;
                    OPD.Birth_Reg_Number = string.IsNullOrEmpty(BirthRegNumber) ? null : BirthRegNumber;

                    if (!string.IsNullOrEmpty(BirthRegDate))
                    {
                        try
                        {
                            OPD.Birth_Reg_Date = Convert.ToDateTime(BirthRegDate);
                        }
                        catch
                        {
                            OPD.Birth_Reg_Date = null;
                        }
                    }
                    else
                    {
                        OPD.Birth_Reg_Date = null;
                    }

                    OPD.Birth_Registrar = string.IsNullOrEmpty(BirthRegistrar) ? null : BirthRegistrar;
                    OPD.Birth_Union_Council = string.IsNullOrEmpty(BirthUnionCouncil) ? null : BirthUnionCouncil;
                    OPD.Birth_Address = string.IsNullOrEmpty(BirthAddress) ? null : BirthAddress;
                    OPD.Birth_City = string.IsNullOrEmpty(BirthCity) ? null : BirthCity;
                    OPD.Birth_Province = string.IsNullOrEmpty(BirthProvince) ? null : BirthProvince;
                    OPD.Birth_Postal_Code = string.IsNullOrEmpty(BirthPostalCode) ? null : BirthPostalCode;
                    OPD.Birth_Religion = string.IsNullOrEmpty(BirthReligion) ? null : BirthReligion;
                    OPD.Birth_Attendant = string.IsNullOrEmpty(BirthAttendant) ? null : BirthAttendant;
                    OPD.Birth_Remarks = string.IsNullOrEmpty(BirthRemarks) ? null : BirthRemarks;

                    if (btnsave == "Save")
                    {
                        OPD.Book_ID = AppConfig.Book_ID;
                        OPD.Created_By = AppConfig.UserID;
                        OPD.Created_Time = DateTime.Now;
                        OPD.Company_ID = AppConfig.Company_ID;
                        db.In_Patients.InsertOnSubmit(OPD);
                    }

                    db.SubmitChanges();

                    if (OPD.In_Patient_ID > 0)
                    {
                        if (ddlIssuance_Of == "001")
                        {
                            List<Ward_Allocation> wlist = db.Ward_Allocations.Where(p => p.InPatient_ID == "0").ToList();
                            foreach (Ward_Allocation med in wlist)
                            {
                                med.InPatient_ID = OPD.In_Patient_ID.ToString();
                            }
                        }
                        else if (ddlIssuance_Of == "003")
                        {
                            List<Ward_Allocation> wlist = db.Ward_Allocations.Where(p => p.InPatient_ID == "0").ToList();
                            foreach (Ward_Allocation med in wlist)
                            {
                                med.InPatient_ID = OPD.In_Patient_ID.ToString();
                            }
                            List<Room_Allocation> kklist = db.Room_Allocations.Where(p => p.In_Patient_ID == 0).ToList();
                            foreach (Room_Allocation med in kklist)
                            {
                                med.In_Patient_ID = OPD.In_Patient_ID;
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
                        List<In_Patient_Medicine> list = db.In_Patient_Medicines.Where(p => p.Patient_ID == 0 && p.Transaction_Type == "OutPatient").ToList();
                        foreach (In_Patient_Medicine med in list)
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
                    }
                    else
                    {
                        RemoveWardAndRooms_Allocation(txtBed_No, ddlRoom_No, Patient_ID, db);
                    }

                    InPatientID = OPD.In_Patient_ID;
                }
                catch (Exception ex)
                {
                    if (OPD.In_Patient_ID == 0)
                    {
                        RemoveWardAndRooms_Allocation(txtBed_No, ddlRoom_No, Patient_ID, db);
                    }
                    throw ex;
                }

                DBClass.executeNonQueryWithoutBegin("delete from Room_Allocation where Patient_ID not in (select Patient_ID from In_Patient)");
                DBClass.executeNonQueryWithoutBegin("delete from Ward_Allocation where Patient_ID not in (select Patient_ID from In_Patient)");
                return InPatientID.ToString();
            }
        }


        private static void RemoveWardAndRooms_Allocation(string BedNo, string RoomNo, int Patient_ID, DataBaseDataContext db)
        {
            if (db != null)
            {
                if (!string.IsNullOrEmpty(BedNo) && BedNo != "0")
                {
                    Ward_Allocation ward = db.Ward_Allocations.Where(w => w.Patient_ID == Patient_ID && w.InPatient_ID == "0").FirstOrDefault();
                    db.Ward_Allocations.DeleteOnSubmit(ward);
                    db.SubmitChanges();
                }

                if (!string.IsNullOrEmpty(RoomNo) && RoomNo != "0")
                {
                    Room_Allocation room = db.Room_Allocations.Where(w => w.Patient_ID == Patient_ID && w.In_Patient_ID == 0).FirstOrDefault();
                    db.Room_Allocations.DeleteOnSubmit(room);
                    db.SubmitChanges();
                }

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
            public string AdvanceAmount;
            public string RevisitMsg { get; set; }
        }
        [WebMethod]
        public static string SendToNADRA(int InPatientID)
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    // 1. Get patient record
                    var patient = db.In_Patients.FirstOrDefault(p => p.In_Patient_ID == InPatientID);
                    if (patient == null)
                    {
                        return "ERROR: Patient not found";
                    }

                    // 2. Get NADRA credentials from sys_Parms
                    string baseUrl = DBClass.getField("SELECT Code FROM sys_Parms WHERE Name = 'NADRA_API_BaseUrl'");
                    string username = DBClass.getField("SELECT Code FROM sys_Parms WHERE Name = 'NADRA_API_Username'");
                    string password = DBClass.getField("SELECT Code FROM sys_Parms WHERE Name = 'NADRA_API_Password'");
                    string hospitalName = DBClass.getField("SELECT Code FROM sys_Parms WHERE Name = 'NADRA_API_HospitalName'");
                    string hospitalAddress = DBClass.getField("SELECT Code FROM sys_Parms WHERE Name = 'NADRA_API_HospitalAddress'");

                    // 3. Validate credentials
                    if (string.IsNullOrEmpty(baseUrl) || string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
                    {
                        return "ERROR: NADRA credentials not configured in sys_Parms";
                    }

                    // 4. Prepare birth data
                    var birthData = new
                    {
                        hospitalName = hospitalName,
                        hospitalAddress = hospitalAddress,
                        issuanceDate = DateTime.Now.ToString("dd/MM/yyyy"),
                        refNumber = patient.Birth_Reg_Number ?? $"REF-{DateTime.Now:yyyyMMdd}-{new Random().Next(1000, 9999)}",
                        childName = patient.Birth_Child_Name ?? "",
                        childDateofBirth = patient.Birth_Date?.ToString("dd/MM/yyyy HH:mm:ss") ?? DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss"),
                        childGender = patient.Birth_Gender?.ToLower() ?? "",
                        placeofOccurrence = "hospital",
                        placeofBirth = patient.Birth_Place ?? "",
                        districtofBirth = patient.Birth_City ?? "",
                        typeofBirth = "Single",
                        disability = "N",
                        fatherName = patient.Birth_Father_Name ?? "",
                        motherName = patient.Birth_Mother_Name ?? "",
                        FatherIdentityType = "cnic",
                        FatherIdentityValue = patient.Birth_Father_CNIC ?? "",
                        MotherIdentityType = "cnic",
                        MotherIdentityValue = patient.Birth_Mother_CNIC ?? "",
                        motherBloodGroup = "O+",
                        childBloodGroup = "O+",
                        contactNumber = patient.pat_number ?? "",
                        doctorName = "Dr. Default",
                        registrationNo = "REG123456"
                    };

                    // 5. Authenticate with NADRA
                    using (var client = new HttpClient())
                    {
                        // Step 1: Get Token
                        var authData = new { username = username, password = password };
                        var authJson = new JavaScriptSerializer().Serialize(authData);
                        var authContent = new StringContent(authJson, Encoding.UTF8, "application/json");

                        var authResponse = client.PostAsync($"{baseUrl}/Authenticate", authContent).Result;
                        string authResponseString = authResponse.Content.ReadAsStringAsync().Result;

                        // Parse authentication response properly
                        var authDict = new JavaScriptSerializer().Deserialize<Dictionary<string, object>>(authResponseString);
                        string token = authDict.ContainsKey("token") ? authDict["token"]?.ToString() : null;
                        string authCode = authDict.ContainsKey("code") ? authDict["code"]?.ToString() : null;
                        string authMessage = authDict.ContainsKey("message") ? authDict["message"]?.ToString() : null;

                        if (string.IsNullOrEmpty(token) || token == "null")
                        {
                            return $"ERROR: Authentication failed - {authMessage} (Code: {authCode})";
                        }

                        // Step 2: Send Birth Data
                        var request = new { BirthData = birthData };
                        var birthJson = new JavaScriptSerializer().Serialize(request);
                        var birthContent = new StringContent(birthJson, Encoding.UTF8, "application/json");

                        client.DefaultRequestHeaders.Clear();
                        client.DefaultRequestHeaders.Add("Authorization", $"Bearer {token}");

                        var birthResponse = client.PostAsync($"{baseUrl}/AddBirthData", birthContent).Result;
                        string birthResponseString = birthResponse.Content.ReadAsStringAsync().Result;

                        // Parse birth response
                        var birthDict = new JavaScriptSerializer().Deserialize<Dictionary<string, object>>(birthResponseString);
                        string birthCode = birthDict.ContainsKey("code") ? birthDict["code"]?.ToString() : null;
                        string birthMessage = birthDict.ContainsKey("message") ? birthDict["message"]?.ToString() : null;

                        // 6. Update database
                        patient.IsCertificateSentToNADRA = true;
                        patient.CertificateSentDate = DateTime.Now;
                        patient.NADRA_Response = birthResponseString;
                        db.SubmitChanges();

                        // 7. Return result
                        if (birthCode == "200")
                        {
                            return $"SUCCESS: Birth certificate sent to NADRA successfully. {birthMessage}";
                        }
                        else
                        {
                            return $"SUCCESS but NADRA returned: {birthMessage} (Code: {birthCode})";
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                return $"ERROR: {ex.Message}";
            }
        }
        [WebMethod]
        public static string PendingAdmisionPatients()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var data = (from op in db.In_Patients
                        join p in db.Reg_patients
                        on op.Patient_ID equals p.pat_id where
              Convert.ToDateTime(op.Created_Time).Month == DateTime.Now.Month && Convert.ToDateTime(op.Created_Time).Year == DateTime.Now.Year && Convert.ToDateTime(op.Created_Time).Day == DateTime.Now.Day
                        select new
                        {
                            p.pat_id,
                            p.Patient_No,
                            p.Full_Name,
                            p.NIC,
                            //tibit
                            Department = db.GetDataValueName("Patient Main Category", op.Department),
                            Gender = db.GetDataValueName("Gender", p.Gender),
                            p.Created_time,
                        }
                       ).ToList();
            return (new JavaScriptSerializer()).Serialize(data);
        }
        [WebMethod]
        public static string PendingAdmisionPatients(string searchValue = "")
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var data = (from op in db.In_Patients
                        join p in db.Reg_patients
                        on op.Patient_ID equals p.pat_id
                        where
                            Convert.ToDateTime(op.Created_Time).Month == DateTime.Now.Month &&
                            Convert.ToDateTime(op.Created_Time).Year == DateTime.Now.Year &&
                            Convert.ToDateTime(op.Created_Time).Day == DateTime.Now.Day
                        select new
                        {
                            p.pat_id,
                            p.Patient_No,
                            p.Full_Name,
                            p.NIC,
                            Department = db.GetDataValueName("Patient Main Category", op.Department),
                            Gender = db.GetDataValueName("Gender", p.Gender),
                            p.Created_time,
                        }
                       ).ToList();

            if (!string.IsNullOrEmpty(searchValue))
            {
                searchValue = searchValue.ToLower();
                data = data.Where(x =>
                    (x.Patient_No != null && x.Patient_No.ToString().ToLower().Contains(searchValue)) ||
                    (x.Department != null && x.Department.ToLower().Contains(searchValue))
                ).ToList();
            }

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
        public static string getprvdetail()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var data = (from td in db.In_Patients
                        orderby td.In_Patient_ID descending
                        select new
                        {
                            td.Patient_ID,
                            td.pat_name,
                            td.pat_age,
                            td.pat_number,
                        }).FirstOrDefault();
            return (new JavaScriptSerializer().Serialize(data));
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
            var Type = (from tbl in db.In_Patients
                        where tbl.Patient_ID == int.Parse(PatientID)
                        && tbl.Discharge != true
                        orderby tbl.Created_Time descending
                        select tbl.Patient_Discount_Type).FirstOrDefault();
            var discharge_InPatient = db.In_Patients.Where(w => w.Patient_ID == pat.pat_id && w.Discharge == true && w.Discharge_On != null).OrderByDescending(w => w.Admission_Date).FirstOrDefault();

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
                var inpatid = DBClass.getField("select In_Patient_ID from AR_Advances where Patient_ID=" + PatientID + "order by Advance_ID desc");
                if(inpatid != "There is no row at position 0.")
                {
                    pt.AdvanceAmount = DBClass.getField("select sum(Advance_Amount) from AR_Advances where In_Patient_ID=" + inpatid);
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
                          on op.Reg_PatId equals p.pat_id
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

                                      where op.Reg_PatId == PatientID && op.Discharge == true && op.Administration != ""
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
                                   where op.Patient_ID == PatientID && op.Discharge_On == null
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
                                      where op.Patient_ID == PatientID && op.Discharge_On == null
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
        public static string LoadDoctorNoteForHistory(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatientID));

                var inPatDOcList = (from rm in db.InPatient_Doctor_Notes
                                    join op in db.In_Patients
                                       on rm.In_Patient_ID equals op.In_Patient_ID
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
            var result = (from data in db.In_Patients
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
                        ddlIssuance_Of.Enabled = true;
                        ddlRoom_No.Enabled = true;
                        ddlRoom_No.SelectedValue = lastRowRoom.Room_ID.ToString();
                        ddlIssuance_Of.SelectedIndex = 0;
                        ddlIssuance_Of.Enabled = false;
                        ddlRoom_No.Enabled = false;
                        ddlRoom_No.CssClass = "dropdownBackgroud";
                        txtRoom_Type.SelectedValue = roomType.DataValue_Description;
                        vlblCurrent_Allocated_Room_Ward.Text = "";
                        vlblCurrent_Allocated_Room_Ward.CssClass = "Success";
                    }
                }
                else
                {
                    ddlRoom_No.Enabled = false;
                    ddlRoom_No.CssClass = "dropdownBackgroud";
                    txtRoom_Type.SelectedIndex = 0;
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
                        ddlReferTo.Enabled = true;
                        ddlroom.Enabled = true;
                        ddlroom.SelectedValue = lastRowRoom.Room_ID.ToString();
                        ddlReferTo.SelectedIndex = 0;
                        ddlReferTo.Enabled = false;
                        ddlroom.Enabled = false;
                        ddlroom.CssClass = "dropdownBackgroud";
                        ddlRoomType.SelectedValue = roomType.DataValue_Description;
                        Label43.Text = "";
                        Label43.CssClass = "Success";
                    }
                }
                else
                {
                    ddlroom.Enabled = false;
                    ddlroom.CssClass = "dropdownBackgroud";
                    ddlRoomType.SelectedIndex = 0;
                }
                if (countOfWardRows > 0)
                {
                    var lastRowWard = db.Ward_Allocatrion_Histories.Where(m => m.Patient_ID == Convert.ToInt32(txtPatient_ID.Text)).Skip(countOfWardRows - 1).FirstOrDefault();
                    if (lastRowWard != null)
                    {
                        ddlReferTo.CausesValidation = false;
                        ddlReferTo.Enabled = true;
                        ddlwards.Enabled = true;
                        ddlwards.SelectedValue = lastRowWard.Ward_ID.ToString();
                        ddlReferTo.SelectedIndex = 0;
                        ddlReferTo.Enabled = false;
                        ddlwards.Enabled = false;
                        ddlwards.CssClass = "dropdownBackgroud";
                        txtBedno.Text = lastRowWard.Bed_No.ToString();
                        txtBedno.ReadOnly = true;
                        Label43.Text = "";
                        Label43.CssClass = "Success";
                    }
                }
                else
                {
                    ddlwards.Enabled = false;
                    ddlwards.CssClass = "dropdownBackgroud";
                    txtBedno.Text = "";
                    txtBedno.ReadOnly = true;
                }
            }
            else
            {
                ddlReferTo.Enabled = true;
                ddlReferTo.CssClass = "dropdownBackgroudWhite";
                Label43.Text = "No Room And Ward Assigned.";
                Label43.CssClass = "Error";
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
            public string Full_Name { get; set; }
            public DateTime? AdmissionDate { get; set; }
        }
        [WebMethod]
        public static string FillWardBeds(int WardID)
        {
            if (WardID <= 0)
            {
                return new JavaScriptSerializer().Serialize(new List<Beds>());
            }
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
                    var patient = (from p in db.Ward_Allocations
                                   join rp in db.Reg_patients on p.Patient_ID equals rp.pat_id
                                   where p.Bed_No_Assigned == (int)(i) && p.Ward_ID == WardID && p.IsDischarge == false
                                   select new { p.Patient_ID, rp.Patient_No, rp.Full_Name }).FirstOrDefault();

                    Beds b = new Beds();
                    b.BedNo = i;
                    b.WardID = WardID;

                    if (patient != null)
                    {
                        b.PatientNo = (int)patient.Patient_No;
                        b.Full_Name = patient.Full_Name;
                        b.AdmissionDate = (from ip in db.In_Patients
                                           where ip.Patient_ID == patient.Patient_ID
                                           select (DateTime?)ip.Admission_Date).FirstOrDefault();
                    }
                    else
                    {
                        b.PatientNo = 0;
                        b.Full_Name = "";
                        b.AdmissionDate = null;
                    }

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
            public string Full_Name { get; set; }
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
                                PatientNmae = (from room in db.Room_Allocations join p in db.Reg_patients on room.Patient_ID equals p.pat_id where room.Room_ID == rm.Room_ID && room.IsDischarge == false
                                               select (p.Patient_No + " - " + p.Full_Name)).FirstOrDefault(),
                            }
               ).ToList();
            return (new JavaScriptSerializer()).Serialize(Rmdetail);
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
                db.SubmitChanges();
            }
            catch (Exception ex)
            {
                throw;
            }
            return "";
        }
        [WebMethod]
        public static string SaveWardInformation(string btnsave, string PatID, string InPatID, string ddlWard_No, string txtBed_No, string txtExpected_Discharge_Date, string ddlDoctor, bool DichargChk)
        {
            try
            {
                Ward_Allocation ward_aloct;
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                ward_aloct = (from tbl in db.Ward_Allocations
                              where tbl.Ward_ID == Convert.ToInt32(ddlWard_No)
                               && tbl.InPatient_ID == (InPatID).ToString() && tbl.Patient_ID == Convert.ToInt32(PatID)
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
                                               join inpat in db.In_Patients
                                               on tbl.InPatient_ID equals inpat.In_Patient_ID.ToString()
                                               where tbl.InPatient_ID == (InPatID).ToString() && tbl.Patient_ID == Convert.ToInt32(PatID)
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
                           && tbl.InPatient_ID != (InPatID).ToString() && tbl.Patient_ID != Convert.ToInt32(PatID)
                           && tbl.Bed_No_Assigned == Convert.ToInt32(txtBed_No) && tbl.IsDischarge == false
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
                ward_aloct.InPatient_ID = InPatID.ToString();
                ward_aloct.Patient_ID = Convert.ToInt32(PatID);
                ward_aloct.Ward_ID = Convert.ToInt32(ddlWard_No);
                ward_aloct.Bed_No_Assigned = Convert.ToInt32(txtBed_No);

                ward_aloct.Doctor_Assigned = Convert.ToInt32(ddlDoctor);
                if (DichargChk == true)
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
                var records = (from tbl in db.Ward_Allocations
                               where
                  tbl.InPatient_ID == (InPatID).ToString() &&
                   tbl.IsDischarge == false
                               select tbl).ToList();
                if (DichargChk == true)
                {
                    if (records.Count > 0)
                    {
                        DBClass.executeNonQueryWithoutBegin("update Ward_Allocation set IsDischarge=1 where InPatient_ID=" + InPatID);
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
        public static string LoadVitalParametersHistoryDischarge(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatientID));

            

            var IPD_PatientList = (from op in db.ReceivingNotes
                                   join p in db.Reg_patients
                                   on op.Patient_ID equals p.pat_id
                                   join inpat in db.In_Patients
                                   on p.pat_id equals inpat.Patient_ID
                                   where p.Patient_No == Patien_No
                                   && op.Type_Nursing == "Discharge IPD Receiving Note" && op.In_Patient_ID == inpat.In_Patient_ID
                                   && op.Emergency_ID == null

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

            foreach (var item in IPD_PatientList)
            {
                VitalParameterClass obj = new VitalParameterClass();
                obj.Emergency_Rhythm = db.GetDataValueName("Emergency Rhythm", item.Emergency_Rhythm);
                obj.Emergency_Volume = db.GetDataValueName("Emergency Volume", item.Emergency_Volume);
                obj.BP_mm_Hg = item.BloodPressure;
                obj.RateBeats = item.RateBeats;
                obj.OthersRecieveNote = item.OthersRecieveNote;
                obj.O2_Saturation = item.O2_Saturation;
                obj.O2_Saturation_Oxygen1 = item.O2_Saturation_Oxygen1;
                obj.O2_Saturation_Oxygen2 = item.O2_Saturation_Oxygen2;
              
                obj.Respiration_Min = item.RespirationRate;
                obj.Temp_C = item.Temperature;
               
                obj.Receiving_date = Convert.ToDateTime(item.Receiving_Date);
                obj.RN_Special_Instruction = item.RN_Special_Instruction;
                obj.Status = "IPD Discharge Patient";
                obj.User_Name = item.user;
                
                list.Add(obj);
            }
            return (new JavaScriptSerializer()).Serialize(list);
        }

        [WebMethod]
        public static string LoadDoctorNoteDetail(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatmedicineList = (from pm in db.InPatient_Doctor_Notes
                                         join op in db.In_Patients
                                         on pm.In_Patient_ID equals op.In_Patient_ID
                                         where op.In_Patient_ID == PatientID
                                         select new { pm.Progress_Note, pm.Doctor_Note_Date, pm.Doctor_Instruction, pm.Doctor_Status, pm.Doctor_ID, DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(pm.Doctor_ID) select d.Emp_Name).FirstOrDefault(), DoctorStatus = db.GetDataValueName("Doctor Status", pm.Doctor_Status) }).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
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
        protected void btnGet_Doctor_Click(object sender, EventArgs e)
        {
            db = new DataBaseDataContext(DBClass.ConnectionString());
            List<HR_Employee> EmpList = new List<HR_Employee>();
            EmpList = (from tbl in db.HR_Employees
                       where (tbl.IsDoctor == true
                       && tbl.Department == ddlDepartment.SelectedValue  )
                       select tbl).ToList();
            ddlDoctor.Items.Clear();
            ddlDoctor.DataSource = EmpList;
            ddlDoctor.DataTextField = "Emp_Name";
            ddlDoctor.DataValueField = "Emp_ID";
            ddlDoctor.Items.Add(new ListItem("Please Select", "0"));
            ddlDoctor.DataBind();

          

            txtRoom_Type.Enabled = false;
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
                                Patient_Type = (from d in db.DataValues join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID where v.ValueSet_Name == "Patient Type" && d.DataValue_Name == outP.Department select d.DataValue_Description).FirstOrDefault(),
                                tbl.Age_years,
                                tbl.Permanent_Address,
                                //tibit
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
                    if (Data.Room_Name == null) {
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
                    recieptP.Patient_Type = Data.Patient_Type;
                    recieptP.Age_years = Data.Age_years;
                    recieptP.Permanent_Address = Data.Permanent_Address.ToString();
                    //recieptP.Temporary_Address = Data.Temporary_Address.ToString();
                    if (Data.Province == null)
                    {
                        recieptP.Province = "";
                    }
                    else
                    {
                        recieptP.Province = Data.Province.ToString();
                    }
                    
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
                //pat.DOB = Convert.ToDateTime(Date_Of_Birth);
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
        public static string Getmr_noss()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            Reg_patient pat = null;
            int? maxPatNo = db.Reg_patients.Max(p => (int?)p.Patient_No);
            int newPatNo = (maxPatNo.HasValue ? maxPatNo.Value : 0) + 1;
            return newPatNo.ToString();
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

        [WebMethod]
        public static string GetBirthType()
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Birth Type"
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
        public static string GetNationality()
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Nationality"
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
        public static string GetReligion()
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Religion"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
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
        public static string CheckPatientDischarge(int patientId)
        {
            using (var db = new DataBaseDataContext())
            {
                var latestOutPatientDischarge = (
                    from op in db.Out_Patients
                    where op.Reg_PatId == patientId
                    orderby op.Created_Time descending
                    select op.Discharge
                ).FirstOrDefault();

                var latestEmergencyDischarge = (
                    from ep in db.Emergency_Patients
                    where ep.Patient_ID == patientId
                    orderby ep.Admission_Date descending
                    select ep.Discharge
                ).FirstOrDefault();

                bool blockedOpd = latestOutPatientDischarge == false;
                bool blockedEmerg = latestEmergencyDischarge == false;

                if (blockedOpd && blockedEmerg)
                {
                    return "{\"Status\":\"BLOCK\",\"Reason\":\"OPD_AND_EMERGENCY\"}";
                }
                if (blockedOpd)
                {
                    return "{\"Status\":\"BLOCK\",\"Reason\":\"OPD\"}";
                }
                if (blockedEmerg)
                {
                    return "{\"Status\":\"BLOCK\",\"Reason\":\"EMERGENCY\"}";
                }

                return "{\"Status\":\"ALLOW\",\"Reason\":\"NONE\"}";
            }
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
        public static string SaveNextOfKin(string patientId, string guardianId, string guardianName,string relationship, string address, string cnic, string phone)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(patientId) || patientId == "(New)")
                {
                    return "Patient admission must be saved before adding Next of Kin details.";
                }

                int parsedGuardianId;
                bool isUpdate = int.TryParse(guardianId, out parsedGuardianId) && parsedGuardianId > 0;

                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    Next_To_Kin kinRecord;

                    if (isUpdate)
                    {
                        kinRecord = db.Next_To_Kins.FirstOrDefault(k => k.Guardian_Id == parsedGuardianId);
                        if (kinRecord == null)
                        {
                            return "Next of Kin record not found for update.";
                        }

                        kinRecord.G_Name = guardianName;
                        kinRecord.G_RelationShip = relationship;
                        kinRecord.G_Address = address;
                        kinRecord.G_CNIC = cnic;
                        kinRecord.G_Phone = phone;
                        kinRecord.Updated_By = AppConfig.UserID;
                        kinRecord.Updated_Date = DateTime.Now;
                    }
                    else
                    {
                        var existing = db.Next_To_Kins.FirstOrDefault(k => k.Patient_Id == patientId);
                        if (existing != null)
                        {
                            existing.G_Name = guardianName;
                            existing.G_RelationShip = relationship;
                            existing.G_Address = address;
                            existing.G_CNIC = cnic;
                            existing.G_Phone = phone;
                            existing.Updated_By = AppConfig.UserID;
                            existing.Updated_Date = DateTime.Now;
                            kinRecord = existing;
                        }
                        else
                        {
                            kinRecord = new Next_To_Kin
                            {
                                Patient_Id = patientId,
                                G_Name = guardianName,
                                G_RelationShip = relationship,
                                G_Address = address,
                                G_CNIC = cnic,
                                G_Phone = phone,
                                Created_By = AppConfig.UserID,
                                Created_Date = DateTime.Now
                            };
                            db.Next_To_Kins.InsertOnSubmit(kinRecord);
                        }
                    }

                    db.SubmitChanges();
                    return "success";
                }
            }
            catch (Exception ex)
            {
                return "Error saving Next of Kin details: " + ex.Message;
            }
        }

        [WebMethod]
        public static string CheckBirthCertificateTab()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var ups = (from St in db.aspnet_Users
                       where St.UserId == AppConfig.UserID
                       select St.IPD_Allow_birth_Certifcate).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(ups);
        }
    }
}