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

namespace PMS
{
    public partial class InPatientsCase : System.Web.UI.Page
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

                txtExpected_Discharge_Date.Text = DateTime.Now.Date.ToString(AppConfig.DateFormat);
                txtAdmission_Date.Text = DateTime.Now.ToString();
                txtReceiving_Date.Text = DateTime.Now.ToString();

                txtDischarge_On.Text = DateTime.Now.ToString();
                txtMo_Date.Text = DateTime.Now.ToString();
                txtExpected_Discharge_Date.Text = DateTime.Now.Date.ToString(AppConfig.DateFormat);
                BindingDropDown();
                BlankForm();

                if (Request.QueryString["ID"] != null)
                {
                    string QS = id.Split('=')[1];
                    PopulateInPatientData(Convert.ToInt32(QS));
                    InPatient_Case_id = Convert.ToInt32(QS);
                    SetWardAndBedLabels(Convert.ToInt32(QS));
                    ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "", "FillInstruction();", true);
                }
            }
            else
            {
            }
        }

        private void SetWardAndBedLabels(int inPatientId)
        {
            try
            {
                db = new DataBaseDataContext(DBClass.ConnectionString());
                var data = (from ip in db.In_Patients
                            join wd in db.Ward_Definitions on ip.Ward_ID equals wd.Ward_ID into wardJoin
                            from ward in wardJoin.DefaultIfEmpty()
                            where ip.In_Patient_ID == inPatientId
                            select new
                            {
                                WardName = ward != null ? ward.Ward_Type : "",
                                BedNo = ip.Bed_No
                            }).FirstOrDefault();

                if (data != null)
                {
                    vLbl_WardName.Text = data.WardName ?? "";
                    vLbl_BedNo.Text = data.BedNo != null ? data.BedNo.ToString() : "";
                }
            }
            catch (Exception ex)
            {
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

            valueset = DBClass.GetValueSet("Discharge Type");
            ddlDischarge_Type.DataSource = valueset;
            ddlDischarge_Type.DataTextField = "DataValue_Description";
            ddlDischarge_Type.DataValueField = "DataValue_Name";
            ddlDischarge_Type.Items.Add(new ListItem("Please Select", "0"));
            ddlDischarge_Type.DataBind();

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

            valueset = DBClass.GetValueSet("Doctor Status");
            DocStatus.DataSource = valueset;
            DocStatus.DataTextField = "DataValue_Description";
            DocStatus.DataValueField = "DataValue_Name";
            DocStatus.Items.Add(new ListItem("Select", "0"));
            DocStatus.DataBind();

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

            ddlDoctorClinicalSummary.DataSource = EmpList;
            ddlDoctorClinicalSummary.DataTextField = "Emp_Name";
            ddlDoctorClinicalSummary.DataValueField = "Emp_ID";
            ddlDoctorClinicalSummary.Items.Add(new ListItem("Please Select", "0"));
            ddlDoctorClinicalSummary.DataBind();


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
            ddlWard_No.DataTextField = "Ward_No";
            ddlWard_No.DataValueField = "Ward_ID";
            ddlWard_No.Items.Add(new ListItem("Please Select", "0"));
            ddlWard_No.DataBind();
            ddlwards.DataSource = wards;
            ddlwards.DataTextField = "Ward_Type";
            ddlwards.DataValueField = "Ward_ID";
            ddlwards.Items.Add(new ListItem("Please Select", "0"));
            ddlwards.DataBind();

            valueset = DBClass.GetValueSet("Patient Type");
            ddlPatientType.DataSource = valueset;
            ddlPatientType.DataTextField = "DataValue_Description";
            ddlPatientType.DataValueField = "DataValue_Name";
            ddlPatientType.Items.Add(new ListItem("Select Type", "0"));
            ddlPatientType.DataBind();
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
            ddlDoctor.SelectedIndex = 0;
            txtHealth_Complaints.Text = "";
            txttxtReceiving_DateDesc.Text = DateTime.Now.ToString();
            txtExpected_Discharge_Date.Text = DateTime.Now.Date.ToString(AppConfig.DateFormat);
            txtReceiving_Date.Text = DateTime.Now.Date.ToString(AppConfig.DateFormat);
            txtAdmission_Date.Text = DateTime.Now.ToString();
            //txtReceiving_Date.Text = DateTime.Now.ToString();
            //txtRN_Patient_General_Condition.Text = "";
            //txtRN_Special_Instruction.Text = "";
            //txtPuls.Text = "";
            //txtBP.Text = "";
            //txtTemp.Text = "";
            //txtRespiration.Text = "";
            //txtHeight.Text = "";
            //txtWeight.Text = "";
            //txtLMP.Text = "";
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
                    if (qry.Entry_Date == null)
                        vLbl_RegDate.Text = qry.Created_Time.Value.ToString(AppConfig.DateFormat);
                    else
                        vLbl_RegDate.Text = qry.Entry_Date.Value.ToString(AppConfig.DateFormat);
                    txtAdmission_Date.Text = qry.Admission_Date.Value.ToString();
                    txtReceiving_Date.Text = qry.Receiving_date == null ? qry.Admission_Date.Value.ToString() : qry.Receiving_date.Value.ToString();

                    ddlIssuance_Of.SelectedValue = qry.Issuance_Of;
                    ddlPatientType.SelectedValue = qry.Patient_Discount_Type;
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
                               && tbl.Department == ddlDepartment.SelectedValue && (tbl.Designation == "004" || tbl.Designation == "005" || tbl.Designation == "005" || tbl.Designation == "006" || tbl.Designation == "007" || tbl.Designation == "008"))
                               select tbl).ToList();
                    ddlDoctor.Items.Clear();
                    ddlDoctor.DataSource = EmpList;
                    ddlDoctor.DataTextField = "Emp_Name";
                    ddlDoctor.DataValueField = "Emp_ID";
                    ddlDoctor.Items.Add(new ListItem("Please Select", "0"));
                    ddlDoctor.DataBind();
                    ddlDoctor.SelectedValue = qry.Doctor;

                    ddlDischarge_By.Items.Clear();
                    ddlDischarge_By.DataSource = EmpList;
                    ddlDischarge_By.DataTextField = "Emp_Name";
                    ddlDischarge_By.DataValueField = "Emp_ID";
                    ddlDischarge_By.Items.Add(new ListItem("Please Select", "0"));
                    ddlDischarge_By.DataBind();
                    ddlDischarge_By.SelectedValue = qry.Discharge_By;

                    txtHealth_Complaints.Text = qry.Health_Complaints;
                    if (qry.Expected_Discharge_Date != null)
                        txtExpected_Discharge_Date.Text = qry.Expected_Discharge_Date.Value.ToString(AppConfig.DateFormat);

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

                    if (qry.JVP_Param != null)
                    {
                        if (qry.JVP_Param == true)
                        {
                            JVP1.Checked = true;
                        }
                        else
                        {
                            JVP2.Checked = true;
                        }
                    }

                    if (qry.Edema_Param != null)
                    {
                        if (qry.Edema_Param == true)
                        {
                            Edema1.Checked = true;
                        }
                        else
                        {
                            Edema2.Checked = true;
                        }
                    }

                    if (qry.Cyanosis_Param != null)
                    {
                        if (qry.Cyanosis_Param == true)
                        {
                            Cyanosis1.Checked = true;
                        }
                        else
                        {
                            Cyanosis2.Checked = true;
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

                    if (!string.IsNullOrEmpty(qry.DateOfDeath.ToString()))
                    {
                        txtDateofDeath.Text = Convert.ToDateTime(qry.DateOfDeath.Value).ToString("MM/dd/yyyy");
                    }
                    if (!string.IsNullOrEmpty(qry.TimeOfDeath.ToString()))
                    {

                        DateTime dateTime = DateTime.ParseExact(qry.TimeOfDeath.ToString(), "HH:mm:ss", CultureInfo.InvariantCulture);
                        txtTimeOfDeath.Text = dateTime.ToString("hh:mm tt", CultureInfo.CurrentCulture);
                    }

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
                    txtIdentificationMarks.Text = qry.IdentificationMarks;
                    txtMR_No.Text = qry.MR_No ?? "";


                    //**********************History Tab**********************//
                    if (qry.TruckTorso != null)
                    {
                        txtTorsoTruck.Text = qry.TruckTorso.Replace("<li>", "•").Trim().Replace("</li>", "").Trim();
                    }
                    if (qry.Clinical_Summary != null)
                    {

                    }
                    if (qry.Doctors_Note != null)
                    {
                        txtDoctoNotes.Text = qry.Doctors_Note.Replace("<li>", "•").Trim().Replace("</li>", "").Trim();
                    }
                    if (qry.HistoryOfPeresentIllness != null)
                    {
                        txtHistoryOfPeresentIllness.Text = qry.HistoryOfPeresentIllness.Replace("<li>", "•").Trim().Replace("</li>", "").Trim();
                    }
                    if (qry.HistoryOfFamily != null)
                    {
                        txtHistoryOfFamily.Text = qry.HistoryOfFamily.Replace("<li>", "•").Trim().Replace("</li>", "").Trim();
                    }
                    if (qry.HistoryOfPastIllness != null)
                    {
                        txtHistoryOfPastIllness.Text = qry.HistoryOfPastIllness.Replace("<li>", "•").Trim().Replace("</li>", "").Trim();
                    }

                    if (qry.SocioEconomicHistory != null)
                    {
                        txtSocioEconomicHistory.Text = qry.SocioEconomicHistory.Replace("<li>", "•").Trim().Replace("</li>", "").Trim();
                    }


                    if (qry.ObstetricHistory != null)
                    {
                        txtObstetricHistory.Text = qry.ObstetricHistory.Replace("<li>", "•").Trim().Replace("</li>", "").Trim(); ;
                    }
                    if (qry.AllergiesHistory != null)
                    {
                        txtAllergiesHistory.Text = qry.AllergiesHistory.Replace("<li>", "•").Trim().Replace("</li>", "").Trim();
                    }
                    if (qry.TreatmentHistory != null)
                    {

                        txtTreatmentHistory.Text = qry.TreatmentHistory.Replace("<li>", "•").Trim().Replace("</li>", "").Trim();
                    }
                    if (qry.ProvisionalDiagnosis != null)
                    {

                        txtProvisionalDiagnosis.Text = qry.ProvisionalDiagnosis.Replace("<li>", "•").Trim().Replace("</li>", "").Trim();
                    }
                    if (qry.Provisional_Diagnosis_Examination != null)
                    {

                        txtProDiagExami.Text = qry.Provisional_Diagnosis_Examination.Replace("<li>", "•").Trim().Replace("</li>", "").Trim();
                    }
                    if (qry.Vaccination_History != null)
                    {
                        txtVaccinationHistory.Text = qry.Vaccination_History.Replace("<li>", "•").Trim().Replace("</li>", "").Trim();
                    }
                    if (qry.Other_History != null)
                    {
                        txtAnyOtherHistory.Text = qry.Other_History.Replace("<li>", "•").Trim().Replace("</li>", "").Trim();
                    }
                    TxtR_Upper.Text = qry.PU_R;
                    TxtL_Upper.Text = qry.PU_L;
                    TxtR_Lower.Text = qry.PL_R;
                    TxtL_Lower.Text = qry.PL_L;

                    if (qry.SU_R != null)
                    {
                        if (qry.SU_R == true)
                        {
                            SUL_RY.Checked = true;
                        }
                        else
                        {
                            SUL_RN.Checked = true;
                        }
                    }

                    if (qry.SU_L != null)
                    {
                        if (qry.SU_L == true)
                        {
                            SUL_LY.Checked = true;
                        }
                        else
                        {
                            SUL_LN.Checked = true;
                        }
                    }

                    if (qry.SL_R != null)
                    {
                        if (qry.SL_R == true)
                        {
                            SLL_RY.Checked = true;
                        }
                        else
                        {
                            SLL_RN.Checked = true;
                        }
                    }
                    if (qry.SL_L != null)
                    {
                        if (qry.SL_L == true)
                        {
                            SLL_LY.Checked = true;
                        }
                        else
                        {
                            SLL_LN.Checked = true;
                        }
                    }


                    TextBoxCns.Text = qry.CNS_Value;
                    TextBoxCvs.Text = qry.CVS_Value;
                    TextBoxResp.Text = qry.RESP_Value;
                    TextBoxGit.Text = qry.GIT_Value;
                    TextBoxGpe.Text = qry.GPE_Value;
                    ctl00_MainContent_txtEOR.Text = qry.Eye_Opening_Response;
                    txtMR.Text = qry.Motor_Response;
                    txtVR.Text = qry.Verbal_Response;
                    txtAcc.Text = qry.Accumulated_Response;
                    txtFurtherExplanation.Text = qry.FurtherExplanation;

                    if (qry.Birth_History != null)
                    {
                        txtBirthHistory.Text = qry.Birth_History.Replace("<li>", "•").Trim().Replace("</li>", "").Trim();
                    }

                    if (qry.Drug_History != null)
                    {
                        txtDrugHistory.Text = qry.Drug_History.Replace("<li>", "•").Trim().Replace("</li>", "").Trim();
                    }
                    if (qry.Personal_History != null)
                    {
                        txtPersonalHistory.Text = qry.Personal_History.Replace("<li>", "•").Trim().Replace("</li>", "").Trim();
                    }
                    txtmidl.Text = qry.ENT_Throat_IDL;
                    txtmNose.Text = qry.ENT_Throat_Nose;
                    txtmRight.Text = qry.ENT_Ear_Right;
                    txtmLeft.Text = qry.Ent_Ear_Left;
                    mchkRightPos.Checked = qry.ENT_Rinnes_Right_PosNeg == null ? false : qry.ENT_Rinnes_Right_PosNeg.Value;
                    mchkLeftPos.Checked = qry.ENT_Rinnes_Lft_PosNeg == null ? false : qry.ENT_Rinnes_Lft_PosNeg.Value;
                    mchkRightF.Checked = qry.ENT_Rinnes_Right_FalseNeg == null ? false : qry.ENT_Rinnes_Right_FalseNeg.Value;
                    mchkLeftF.Checked = qry.ENT_Rinnes_Lft_FalseNeg == null ? false : qry.ENT_Rinnes_Lft_FalseNeg.Value;

                    mchkcentral.Checked = qry.ENT_Webber_Central == null ? false : qry.ENT_Webber_Central.Value;
                    mchkLateralized.Checked = qry.ENT_Webber_Lateralized == null ? false : qry.ENT_Webber_Lateralized.Value;
                    mchkPTA.Checked = qry.ENT_Investigation_PTA == null ? false : qry.ENT_Investigation_PTA.Value;
                    mchkTympanometry.Checked = qry.ENT_Investigation_Tympanometry == null ? false : qry.ENT_Investigation_Tympanometry.Value;
                    mchkRightNeg.Checked = qry.ENT_Rinnes_Right_Neg == null ? false : qry.ENT_Rinnes_Right_Neg.Value;
                    mchkLeftNeg.Checked = qry.ENT_Rinnes_Lft_Neg == null ? false : qry.ENT_Rinnes_Lft_Neg.Value;
                    mchkRightFNeg.Checked = qry.ENT_Rinnes_Right_FNeg == null ? false : qry.ENT_Rinnes_Right_FNeg.Value;
                    mchkLeftFNeg.Checked = qry.ENT_Rinnes_Lft_FNeg == null ? false : Convert.ToBoolean(qry.ENT_Rinnes_Lft_FNeg.Value);

                    //**********************Psychiatry Detail**********************//
                    txtInformant.Text = qry.Psychiatry_Informant;
                    txtSourceOfReferral.Text = qry.Psychiatry_Source_Referral;
                    chkNeckHolding.Checked = qry.Psychiatry_Neck_Holding == null ? false : Convert.ToBoolean(qry.Psychiatry_Neck_Holding);
                    chkWalking.Checked = qry.Psychiatry_Walking == null ? false : Convert.ToBoolean(qry.Psychiatry_Walking.Value);
                    chkTalking.Checked = qry.Psychiatry_Talking == null ? false : Convert.ToBoolean(qry.Psychiatry_Talking.Value);
                    chkOthers.Checked = qry.Psychiatry_Others == null ? false : Convert.ToBoolean(qry.Psychiatry_Others.Value);    // Psychiatry_Others.Value;
                    txtMenarche.Text = qry.Psychiatry_Menarche;
                    txtMenstrual.Text = qry.Psychiatry_Menstrual;
                    txtAttachmentSeparationfromParents.Text = qry.Psychiatry_Attachment_Separation;
                    txtHealth.Text = qry.Psychiatry_Health;
                    chkNailBiting.Checked = qry.Psychiatry_Nail_Biting == null ? false : Convert.ToBoolean(qry.Psychiatry_Nail_Biting);
                    chkTemperTantrums.Checked = qry.Psychiatry_Temper_Tantrums == null ? false : Convert.ToBoolean(qry.Psychiatry_Temper_Tantrums);
                    chkBedWetting.Checked = qry.Psychiatry_Bed_Wetting == null ? false : Convert.ToBoolean(qry.Psychiatry_Bed_Wetting);
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
                    //**********************Derma Detail**********************//
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
                    chkPE_Neck_Rigidity.Checked = qry.Psychiatry_PE_Neck_Rigidity == null ? false : qry.Psychiatry_PE_Neck_Rigidity.Value;
                    chkPE_Kerning_Sign.Checked = qry.Psychiatry_PE_Kerning_Sign == null ? false : qry.Psychiatry_PE_Kerning_Sign.Value;
                    chkPE_Brudzinki_Sign.Checked = qry.Psychiatry_PE_Brudzinki_Sign == null ? false : qry.Psychiatry_PE_Brudzinki_Sign.Value;
                    txtFor_Summary.Text = qry.Psychiatry_For_Summary;
                    txtFor_Diagnosis.Text = qry.Psychiatry_For_Diagnosis;
                    txtFor_AxisI.Text = qry.Psychiatry_For_AxisI;
                    txtFor_AxisIII.Text = qry.Psychiatry_For_AxisIII;
                    txtFor_AxisII.Text = qry.Psychiatry_For_AxisII;
                    //     For_AxisII.Text=qry.psychiatr_For,
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

                    ///////////////Peads////////////
                    txtPeads_weight.Text = qry.Peads_weight;
                    txtPeads_Length.Text = qry.Peads_Length;
                    txtPeads_HC.Text = qry.Peads_HC;
                    txtPeads_General_Appearance.Text = qry.Peads_General_Appearance;
                    chkPeads_Cyanosis.Checked = qry.Peads_Cyanosis == null ? false : qry.Peads_Cyanosis.Value;
                    chkPeads_Jaundice.Checked = qry.Peads_Jaundice == null ? false : qry.Peads_Jaundice.Value;
                    chkPeads_Lethargy.Checked = qry.Peads_Lethargy == null ? false : qry.Peads_Lethargy.Value;
                    chkPeads_Rash.Checked = qry.Peads_Rash == null ? false : qry.Peads_Rash.Value;
                    txtPeads_Others.Text = qry.Peads_Others;
                    chkPeads_Caput.Checked = qry.Peads_Caput == null ? false : qry.Peads_Caput.Value;

                    chkPeads_Cephalhematoma.Checked = qry.Peads_Cephalhematoma == null ? false : qry.Peads_Cephalhematoma.Value;
                    rdbPeads_Anterioropen.Checked = qry.Peads_Anterioropen == null ? false : qry.Peads_Anterioropen.Value;
                    rdbPeads_AnteriorClose.Checked = qry.Peads_AnteriorClose == null ? false : qry.Peads_AnteriorClose.Value;
                    chkPeads_Dextrocardia.Checked = qry.Peads_Dextrocardia == null ? false : qry.Peads_Dextrocardia.Value;
                    chkPeads_Bulging.Checked = qry.Peads_Bulging == null ? false : qry.Peads_Bulging.Value;
                    chkPeads_Murmur.Checked = qry.Peads_Murmur == null ? false : qry.Peads_Murmur.Value;
                    txtPeads_HeartSound.Text = qry.Peads_HeartSound;
                    chkPeads_Nasal.Checked = qry.Peads_Nasal == null ? false : qry.Peads_Nasal.Value;
                    chkPeads_Recessions.Checked = qry.Peads_Recessions == null ? false : qry.Peads_Recessions.Value;
                    txtPeads_AddedSounds.Text = qry.Peads_AddedSounds;

                    rdbPeads_Flat.Checked = qry.Peads_Flat == null ? false : qry.Peads_Flat.Value;
                    rdbPeads_Distended.Checked = qry.Peads_Distended == null ? false : qry.Peads_Distended.Value;
                    rdbPeads_Scaphoid.Checked = qry.Peads_Scaphoid == null ? false : qry.Peads_Scaphoid.Value;
                    chkPeads_Liver.Checked = qry.Peads_Liver == null ? false : qry.Peads_Liver.Value;
                    chkPeads_Spleen.Checked = qry.Peads_Spleen == null ? false : qry.Peads_Spleen.Value;
                    txtPeads_GITOthers.Text = qry.Peads_GITOthers;
                    chkPeads_Sucking.Checked = qry.Peads_Sucking == null ? false : qry.Peads_Sucking.Value;
                    chkPeads_Rooting.Checked = qry.Peads_Rooting == null ? false : qry.Peads_Rooting.Value;
                    chkPeads_Moro.Checked = qry.Peads_Moro == null ? false : qry.Peads_Moro.Value;
                    txtPeads_CNSOthers.Text = qry.Peads_CNSOthers;

                    chkPeads_FullTerm.Checked = qry.Peads_FullTerm == null ? false : qry.Peads_FullTerm.Value;
                    chkPeads_PreTerm.Checked = qry.Peads_PreTerm == null ? false : qry.Peads_PreTerm.Value;
                    if (qry.Peads_DateOfDelivery != null)
                        txtPeads_DateOfDelivery.Text = qry.Peads_DateOfDelivery.Value.ToString(AppConfig.DateFormat);
                    txtPeads_TimeOfDelivery.Text = qry.Peads_TimeOfDelivery;
                    rdbPeads_Booked.Checked = qry.Peads_Booked == null ? false : qry.Peads_Booked.Value;
                    rdbPeads_UnBooked.Checked = qry.Peads_UnBooked == null ? false : qry.Peads_UnBooked.Value;
                    chkPeads_DAIHandling.Checked = qry.Peads_DAIHandling == null ? false : qry.Peads_DAIHandling.Value;
                    chkPeads_ANTURash.Checked = qry.Peads_ANTURash == null ? false : qry.Peads_ANTURash.Value;
                    chkPeads_PIH.Checked = qry.Peads_PIH == null ? false : qry.Peads_PIH.Value;
                    chkPeads_GDM.Checked = qry.Peads_GDM == null ? false : qry.Peads_GDM.Value;
                    chkPeads_Vacinated.Checked = qry.Peads_Vacinated == null ? false : qry.Peads_Vacinated.Value;

                    txtPeads_ANTOthers.Text = qry.Peads_ANTOthers;
                    rdbPeads_SVD.Checked = qry.Peads_SVD == null ? false : qry.Peads_SVD.Value;
                    rdbPeads_LSCS.Checked = qry.Peads_LSCS == null ? false : qry.Peads_LSCS.Value;
                    rdbPeads_Emergency.Checked = qry.Peads_Emergency == null ? false : qry.Peads_Emergency.Value;
                    rdbPeads_Elective.Checked = qry.Peads_Elective == null ? false : qry.Peads_Elective.Value;

                    txtPeads_PlaceOfDelivery.Text = qry.Peads_PlaceOfDelivery;
                    txtPeads_IndicationForLSCS.Text = qry.Peads_IndicationForLSCS;
                    ddlPeads_apgerScore1min.SelectedValue = qry.Peads_apgerScore1min;
                    ddlPeads_apgerScore5min.SelectedValue = qry.Peads_apgerScore5min;
                    chkPeads_Resuscitation.Checked = qry.Peads_Resuscitation == null ? false : qry.Peads_Resuscitation.Value;

                    txtPeads_NatalOthers.Text = qry.Peads_NatalOthers;
                    chkPeads_Moaning.Checked = qry.Peads_Moaning == null ? false : qry.Peads_Moaning.Value;
                    chkPeads_RespDistress.Checked = qry.Peads_RespDistress == null ? false : qry.Peads_RespDistress.Value;
                    chkPeads_PostNATALCyanosis.Checked = qry.Peads_PostNATALCyanosis == null ? false : qry.Peads_PostNATALCyanosis.Value;
                    chkPeads_Fits.Checked = qry.Peads_Fits == null ? false : qry.Peads_Fits.Value;
                    chkPeads_ReluctanceToFeed.Checked = qry.Peads_ReluctanceToFeed == null ? false : qry.Peads_ReluctanceToFeed.Value;
                    txtPeads_PostNatalOthers.Text = qry.Peads_PostNatalOthers == null ? "" : qry.Peads_PostNatalOthers;


                    //**********************Discharge Tab **********************//
                    ddlDischarge_By.SelectedValue = qry.Discharge_By;
                    ddlDischarge_Type.SelectedValue = qry.Discharge_Type;
                    txtProcedure_Operation.Text = qry.Procedure_Operation;
                    //qry.Discharge_Request;
                    if (qry.Discharge_Request == true)
                    {
                        DischargeRequest.Value = "true";
                    }
                    txtMedication.Text = qry.Diagonosis;
                    txtBilling.Text = qry.Procedure_Detail;
                    txtPrevention_Precaution.Text = qry.Prevention_Precaution;
                    if (qry.Next_Visit != null)
                        txtNext_Visit.Text = qry.Next_Visit.Value.ToString(AppConfig.DateFormat);
                    if (qry.Discharge_On != null)
                        txtDischarge_On.Text = qry.Discharge_On.Value.ToString(AppConfig.DateFormat);
                    cbDicharg_Slip.Checked = qry.Discharge.Value;

                }

                if (qry != null)
                {

                    if (qry.ProcedureLevel_ID != null && qry.ProcedureLevel_ID != 0)
                    {
                        string script = "$('#hdnProcedureLevelID').val('" + qry.ProcedureLevel_ID.ToString() + "');";

                        if (!string.IsNullOrEmpty(qry.ProcedureTemplateContent))
                        {
                            string content = qry.ProcedureTemplateContent.Replace("'", "\\'").Replace("\n", "\\n").Replace("\r", "\\r");
                            script += "$('#hdnProcedureContent').val('" + content + "');";
                        }

                        ScriptManager.RegisterStartupScript(this, this.GetType(), "SetProcedureData", script, true);
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
        public static string LoadClinicalSummaryHistory(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            int Patient_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatientID));
            var IPD_PatientList = (from op in db.History_Datas
                                   join p in db.Reg_patients
                                   on op.Patient_Id equals p.pat_id
                                   join inpat in db.In_Patients
                                   on p.pat_id equals inpat.Patient_ID
                                   where p.pat_id == PatientID

                                   orderby op.Date_Time descending
                                   select new
                                   {
                                       op.In_Patient_Id,
                                       op.Patient_Id,
                                       op.Clinical_Notes,
                                       op.Doctor_Id,
                                       op.Date_Time,
                                       DoctorName = (from d in db.HR_Employees
                                                     where d.Emp_ID == Convert.ToInt32(op.Doctor_Id)
                                                     select d.Emp_Name).FirstOrDefault(),
                                       inpat.Updated_Time,

                                   }).ToList();

            return new JavaScriptSerializer().Serialize(IPD_PatientList);
        }
        [WebMethod]
        public static string LoadExaminationHistory(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            int Patient_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatientID));

            var In_PatientsExamList = (from in_Pat in db.In_Patients
                                       join pat in db.Reg_patients
                                       on in_Pat.Patient_ID equals pat.pat_id
                                       where pat.Patient_No == Patient_No
                                       orderby in_Pat.Created_Time
                                       select new
                                       {
                                           HMFIntact = in_Pat.HMFIntact == null ? "-" : (in_Pat.HMFIntact == true ? "Yes" : "False"),
                                           CranialNerves = in_Pat.CranialNerves == null ? "-" : (in_Pat.CranialNerves == true ? "Yes" : "No"),
                                           SignsOfMeningism = in_Pat.SignsOfMeningism == null ? "-" : (in_Pat.SignsOfMeningism == true ? "Yes" : "No"),
                                           HeartSound = in_Pat.HeartSound == null ? "-" : (in_Pat.HeartSound == true ? "Yes" : "No"),
                                           Arrhythmias = in_Pat.Arrhythmias == null ? "-" : (in_Pat.Arrhythmias == true ? "Yes" : "No"),
                                           Murmur = in_Pat.Murmur == null ? "-" : (in_Pat.Murmur == true ? "Yes" : "No"),
                                           AnyOtherAddedSound = in_Pat.AnyOtherAddedSound == null ? "-" : (in_Pat.AnyOtherAddedSound == true ? "Yes" : "No"),
                                           AnyOtherFindings = in_Pat.AnyOtherFindings == null ? "-" : (in_Pat.AnyOtherFindings == true ? "Yes" : "No"),
                                           Wheeze = in_Pat.Wheeze == null ? "-" : (in_Pat.Wheeze == true ? "Yes" : "No"),
                                           Ranchi = in_Pat.Ranchi == null ? "-" : (in_Pat.Ranchi == true ? "Yes" : "No"),
                                           AnyOtherSound = in_Pat.AnyOtherSound == null ? "-" : (in_Pat.AnyOtherSound == true ? "Yes" : "No"),
                                           AbdomenSoft = in_Pat.AbdomenSoft == null ? "-" : (in_Pat.AbdomenSoft == true ? "Yes" : "No"),
                                           Tenderness = in_Pat.Tenderness == null ? "-" : (in_Pat.Tenderness == true ? "Yes" : "No"),
                                           Guarding = in_Pat.Guarding == null ? "-" : (in_Pat.Guarding == true ? "Yes" : "No"),
                                           BowelSound = in_Pat.BowelSound == null ? "-" : (in_Pat.BowelSound == true ? "Yes" : "No"),
                                           Distention = in_Pat.Distention == null ? "-" : (in_Pat.Distention == true ? "Yes" : "No"),
                                           FluidThrill = in_Pat.FluidThrill == null ? "-" : (in_Pat.FluidThrill == true ? "Yes" : "No"),
                                           ShiftingDullness = in_Pat.ShiftingDullness == null ? "-" : (in_Pat.ShiftingDullness == true ? "Yes" : "No"),
                                           EpigastriaDiscomfort = in_Pat.EpigastriaDiscomfort == null ? "-" : (in_Pat.EpigastriaDiscomfort == true ? "Yes" : "No"),
                                           RetrosternalBurning = in_Pat.RetrosternalBurning == null ? "-" : (in_Pat.RetrosternalBurning == true ? "Yes" : "No"),
                                           Jondus = in_Pat.Jondus == null ? "-" : (in_Pat.Jondus == true ? "Yes" : "No"),
                                           Pallor = in_Pat.Pallor == null ? "-" : (in_Pat.Pallor == true ? "Yes" : "No"),
                                           Dehydration = in_Pat.Dehydration == null ? "-" : (in_Pat.Dehydration == true ? "Yes" : "No"),
                                           GCSOrientation = in_Pat.GCSOrientation == null ? "-" : (in_Pat.GCSOrientation == true ? "Yes" : "No"),
                                           Conscious_Orientely = in_Pat.Conscious_Orientely == null ? "-" : (in_Pat.Conscious_Orientely == true ? "Yes" : "No"),
                                           NVB_Right = in_Pat.NVB_Right == null ? "-" : (in_Pat.NVB_Right == true ? "Yes" : "No"),
                                           NVB_Left = in_Pat.NVB_Left == null ? "-" : (in_Pat.NVB_Left == true ? "Yes" : "No"),
                                           Crepitation_Right = in_Pat.Crepitation_Right == null ? "-" : (in_Pat.Crepitation_Right == true ? "Yes" : "No"),
                                           Crepitation_Left = in_Pat.Crepitation_Left == null ? "-" : (in_Pat.Crepitation_Left == true ? "Yes" : "No"),


                                           FurtherExplanation = in_Pat.FurtherExplanation == null ? "-" : in_Pat.FurtherExplanation,

                                           GPE_Value = in_Pat.GPE_Value == null ? "-" : in_Pat.GPE_Value,

                                           CNS_Value = in_Pat.CNS_Value == null ? "-" : in_Pat.CNS_Value,
                                           CVS_Value = in_Pat.CVS_Value == null ? "-" : in_Pat.CVS_Value,

                                           RESP_Value = in_Pat.RESP_Value == null ? "-" : in_Pat.RESP_Value,

                                           GIT_Value = in_Pat.GIT_Value == null ? "-" : in_Pat.GIT_Value,

                                           TruckTorso = in_Pat.TruckTorso == null ? "-" : in_Pat.TruckTorso,

                                           Provisional_Diagnosis_Examination = in_Pat.Provisional_Diagnosis_Examination == null ? "-" : in_Pat.Provisional_Diagnosis_Examination,


                                       }).ToList();

            #region Old Code



            #endregion

            return new JavaScriptSerializer().Serialize(In_PatientsExamList);

        }
        [WebMethod]
        public static string RemoveExtraDepts(Guid UserID)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var allDepts = (from d in db.DataValues
                            join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID
                            where v.ValueSet_Name == "Patient Main Category"
                            select new { Department_ID = d.DataValue_Name, Department_Name = d.DataValue_Description }
                       ).ToList();

            allDepts.Insert(0, new { Department_ID = "0", Department_Name = "All Departments" });

            return (new JavaScriptSerializer().Serialize(allDepts));
        }

        [WebMethod]
        public static string GetDoctors(int departmentId)
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var doctors = (from emp in db.HR_Employees
                               where emp.IsDoctor == true && emp.userid == Convert.ToString(AppConfig.UserID)
                               select new
                               {
                                   Emp_ID = (int)emp.Emp_ID,
                                   emp.Emp_Name
                               }).ToList();

                doctors.Insert(0, new { Emp_ID = 0, Emp_Name = "All Doctors" });

                data = new JavaScriptSerializer().Serialize(doctors);
            }
            return data;
        }





        [WebMethod]
        public static string PendingPatients(string DeptID, string DoctorID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            DateTime startDate = System.DateTime.Now.AddDays(-5);

            var query = (from p in db.Reg_patients
                         join ip in db.In_Patients
                         on p.pat_id equals ip.Patient_ID
                         join u in db.aspnet_Users
                         on ip.Created_By equals u.UserId
                         where ip.Created_Time.Value.Date >= startDate
                         select new
                         {
                             p.pat_id,
                             ip.In_Patient_ID,
                             p.Patient_No,
                             p.Full_Name,
                             p.NIC,
                             DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(ip.Doctor) select d.Emp_Name).FirstOrDefault(),
                             DepartmentName = db.GetDataValueName("Patient Main Category", ip.Department),  // Changed from Department to DepartmentName
                             Checked = ((from op in db.ReceivingNotes
                                         where ip.In_Patient_ID == op.In_Patient_ID
                                         && op.Type_Nursing == "IPD Receiving Note"
                                         select op.In_Patient_ID).FirstOrDefault()),
                             Gender = db.GetDataValueName("Gender", p.Gender),
                             ip.Created_Time,
                             u.UserName,
                             p.Age_years,
                             DepartmentID = ip.Department,  // For filtering
                             DoctorID_Value = ip.Doctor,    // For filtering
                             Patient_Type = (from dv in db.DataValues
                                             join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                             where vs.ValueSet_Name == "Patient Type" && dv.DataValue_Name == ip.Patient_Discount_Type
                                             select dv.DataValue_Description).FirstOrDefault()
                         }).AsQueryable();

            // Apply department filter if provided and not "0"
            if (!string.IsNullOrEmpty(DeptID) && DeptID != "0")
            {
                query = query.Where(x => x.DepartmentID == DeptID);
            }

            // Apply doctor filter if provided and not "0"
            if (!string.IsNullOrEmpty(DoctorID) && DoctorID != "0")
            {
                query = query.Where(x => x.DoctorID_Value == DoctorID);
            }

            var data = query.OrderByDescending(x => x.Created_Time).ToList();

            return (new JavaScriptSerializer()).Serialize(data);
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
        public static string SaveRecord(int Patient_ID, string btnsave, string txtAdmission_Date, string ddlWard_No, string txtHealth_Complaints,/* DateTime txtExpected_Discharge_Date */ string BP_mm_Hg, string Temp_C, string BMI, string Weight, string Height, string BSR, string Respiration_Min, string txtRN_Special_Instruction, string Provisional_Diagnosis, string Reffer_To, string HistoryOfPeresentIllness, string HistoryOfFamily, string HistoryOfPastIllness, string SocioEconomicHistory, string Birth_History, string Reffer_No, string Drug_History, string Personal_History, string ObstetricHistory, string AllergiesHistory, string TreatmentHistory, string VaccinationHistory, string AnyOtherHistory, string ENT_Throat_IDL, string ENT_Throat_Nose, string ENT_Ear_Right, string Ent_Ear_Left, bool ENT_Rinnes_Right_PosNeg, bool ENT_Rinnes_Lft_PosNeg, bool ENT_Rinnes_Right_FalseNeg, bool ENT_Rinnes_Lft_FalseNeg, bool ENT_Webber_Central, bool ENT_Webber_Lateralized, bool ENT_Investigation_PTA, bool ENT_Investigation_Tympanometry, bool ENT_Rinnes_Right_Neg, bool ENT_Rinnes_Lft_Neg, bool ENT_Rinnes_Right_FNeg, bool ENT_Rinnes_Lft_FNeg, string txtInformant, string txtSourceOfReferral, bool chkNeckHolding, bool chkWalking, bool chkTalking, bool chkOthers, string txtMenarche, string txtMenstrual, string txtAttachmentSeparationfromParents, string txtHealth, bool chkNailBiting, bool chkTemperTantrums, bool chkBedWetting, string txtAcademics, string txtPeerRelationship, string txtBehaviour, string txtOccupationalHistory, string txtMaritalRelationshipSexualHistory, string txtSubstanceUse, string txtForensicUse, string txtRelationship, string txtLeisureActivities, string txtAttitudetoSelfandStandards, string txtPrevallingMood, string txtReactionPattrentoStress, string txtReligiousPracticesAttitute, string txtFather, string txtMother, string txtSiblings, string txtHomeAtmosphererelationshipsocialclass, string txtFamilialIllness, string txtActualandapparentage, string txtRace, string txtTattoosbodypiercingandscars, string txtBodyHabitus, string txttxtDress, string txtHygiene, string txtPsychomotorActivity, string txtInvoluntarymovements, string txtDystoniaEPS, string txtTardivedyskinesia, string txtTics, string txtTremors, string txtAttentivenesstointerview, string txtEyeContact, string txtLevelofConsciousness, string txtRate, string txtRhythm, string txtVolume, string txtTone, string txtModulationvar, string txtDepressed, string txtElated, string txtIrritable, string txtLabile, string txtIncongruent, string txtbluntingflatteningapathy, string txtThinkingPremeditation, string txtPlans,
             string txtActions, string txtPreservative, string txtLoosAssociation, string txtTangentiaility, string txtCircumstantiality, string txtFlightofIdeas, string txtThoughtInsertion, string txtThoughtWithdrawal, string txtThoughBroadcasting, string txtThoughControl, string txtDellusion, string txtovervaluedideas, string txtDepresonalization, string txtDerealization, string txtthrougObsession, string txtthrougPhobies, string txtthrougHomocidialIdeas, string txtillusion, string txtHallucinationAuditoryVisualOlfactoryGustatoryTactile, string txtorientationtime, string txtplace, string txtperson, string txtAttentionConcentrationSerial7Test, string txtOrDaysOfWeekReverseOrder, string txtImmediatememory, string txtshorttermrecentevents, string txtadressrecallafter2minutes, string txtlongtermremoteevents, string txtadressrecallafter5minues, string txtgeneralknowledgequestion, string txtsimplearthemeticcalculation, string txtabstrationconcertethinking, string txtinsight, string DermaFace, string DermaNeck, string DermaTrunk, string DermaUpperLimb, string DermaLowerLimb, string DermaFlexures, string DermaGenitalias, string DermaHair, string DermaNail, string DermaMucousMembrane, string DermaEyes, string DermaEars, string DermaNose, string DermaLips, string HBM_Problem, string HBM_Caused, string HBM_Started, string HBM_Course, string HBM_Treatment, string HBM_Effects, string PE_Pluse, string PE_BP, string PE_Temperature, string PE_Weight, string PE_RespiratoryRate, string PE_Jaundice, string PE_Anemia, string PE_Cyanosis, string PE_Clubbing, string PE_JVP, string PE_LymphNodes, string PE_Edema, string PE_Respiratory, string PE_Cardiovascular, string PE_Gastro_Intestinal, string PE_Observation, string PE_Cranial_Nerves, string PE_Limb_Strength, string PE_Spasticity, string PE_Position, string PE_Vibration, string PE_Stereognosis, string PE_Pain, string PE_Biceps, string PE_Triceps, string PE_Brachioradialis, string PE_Quadriceps, string PE_Patellar, string PE_Achilles, string PE_Extensor, string PE_Frontal, string PE_Finger, string PE_Heel, string PE_Movements, string PE_Gait, bool PE_Neck_Rigidity, bool PE_Kerning_Sign, bool PE_Brudzinki_Sign, string For_Summary, string For_Diagnosis, string For_AxisI, string For_AxisII, string For_AxisIII, string For_AxisIV, string For_AxisV, string For_PredisposingFactors, string For_PrecipitatingFactors, string For_PrepetuatingFactors, string For_Investigation, string For_Medical, string For_Psychological, string For_Major_Issues, string For_Strengths, string For_Goals, string For_Strategies, string txtPeads_weight, string txtPeads_Length, string txtPeads_HC, string txtPeads_General_Appearance, bool chkPeads_Cyanosis, bool chkPeads_Jaundice, bool chkPeads_Lethargy, bool chkPeads_Rash, string txtPeads_Others, bool chkPeads_Caput, bool chkPeads_Cephalhematoma, bool rdbPeads_Anterioropen, bool rdbPeads_AnteriorClose, bool chkPeads_Dextrocardia, bool chkPeads_Bulging, bool chkPeads_Murmur, string txtPeads_HeartSound, bool chkPeads_Nasal, bool chkPeads_Recessions, string txtPeads_AddedSounds, bool rdbPeads_Flat, bool rdbPeads_Distended, bool rdbPeads_Scaphoid, bool chkPeads_Liver, bool chkPeads_Spleen, string txtPeads_GITOthers, bool chkPeads_Sucking, bool chkPeads_Rooting, bool chkPeads_Moro, string txtPeads_CNSOthers, bool chkPeads_FullTerm, bool chkPeads_PreTerm, DateTime txtPeads_DateOfDelivery, string txtPeads_TimeOfDelivery, bool rdbPeads_Booked, bool rdbPeads_UnBooked, bool chkPeads_DAIHandling, bool chkPeads_ANTURash, bool chkPeads_PIH, bool chkPeads_GDM, bool chkPeads_Vacinated, string txtPeads_ANTOthers, bool rdbPeads_SVD, bool rdbPeads_LSCS, bool rdbPeads_Emergency, bool rdbPeads_Elective, string txtPeads_PlaceOfDelivery, string txtPeads_IndicationForLSCS, string Peads_apgerScore1min, string Peads_apgerScore5min, bool chkPeads_Resuscitation, string txtPeads_NatalOthers, bool chkPeads_Moaning, bool chkPeads_RespDistress, bool chkPeads_PostNATALCyanosis, bool chkPeads_Fits, bool chkPeads_ReluctanceToFeed, string txtPeads_PostNatalOthers, string txtProcedure_Operation, string txtProcedure_Detail, string txtDignosis, string txtDischarge_On, string ddlDischarge_By, string txtNext_Visit, string txtAdvice, bool chkdischarge, string patienttype, string referto, string referward, string referbed_no, string referroomno, string referroomtype, string RateBeats, string ddlEmrgRhythm, string ddlEmrgVolume, string OthersRN, string O2_Saturation_Oxygen1, string O2_Saturation_Oxygen2, string Saturation, bool? HMFIntact, bool? CranialNerves, bool? SignsOfMeningism, bool? HeartSound, bool? Arrhythmias, bool? AnyOtherAddedSound, bool? AnyOtherFindings, bool? NVB_Right, bool? NVB_Left, bool? Crepitation_Right, bool? Crepitation_Left, bool? Wheeze, bool? Ranchi, bool? AnyOtherSound, bool? AbdomenSoft, bool? Tenderness, bool? Guarding, bool? BowelSound, bool? Distention, bool? FluidThrill, bool? ShiftingDullness, bool? EpigastriaDiscomfort, bool? RetrosternalBurning, bool? Jondus, bool? Pallor, bool? Dehydration, bool? GCSOrientation, bool? ConsciousOrientely, bool? Murmur, string TextBoxCns, string TextBoxCvs, string TextBoxResp, string TextBoxGit, string TextBoxGpe, string eye_response, string motor_response, string verbal_Response, string accumulated_response, string FurtherExplanation, string PulseRate, string BPDischarge, string WeightDischarge, string HeightDischarge, string BMIDischarge, string BSRDischarge, string Tempdisch, string volumedisc, string RespRateDesc, string Rhythmdischarge, string Oxygen2_desc, string saturationDis, string Oxygen1, string otherecdesc, string Special_Instruction_Desc, string FollowUpInstruction, string OperationalDetails, string Receiving_Date_Discharge, string IdentificationMarks, string DateOfDeath, string TimeOfDeath, string PlaceOfDeath, string CauseOfDeath, string IssuingOfficerName, string DeathCertifiedby1, string DeathCertifiedby2, string BodyHandedOverTo, string FamilyPersonName, string CNIC, string RelationWithDeceased, string CMO_Police, string ID, bool? SULR, bool? SULL, bool? SLLR, bool? SLLL, string PULR, string PULL, string PLLR, string PLLL, string Torso, string clinical_Notes, string Doctor_Notes, string Provisional_Diagnosis_Examination, string doc, bool? JVP, bool? Edema, bool? Cyanosis, bool Discharge_Request, string ddlDischarge_Type, string ProcedureTemplateContent, string ProcedureLevel_ID, string Medication_Doctor, string hdfReceivingNoteID, string hdfVitalDischargeID, string MR_No)
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

                }
                OPD.Health_Complaints = txtHealth_Complaints;

                if (referto != "0")
                {
                    OPD.Issuance_Of = referto;
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
                OPD.Clinical_Summary = clinical_Notes;
                OPD.Doctors_Note = Doctor_Notes;
                OPD.BP_mm_Hg = BP_mm_Hg;
                OPD.Temp_C = Temp_C;
                OPD.MR_No = MR_No;
                OPD.Respiration_Min = Respiration_Min;
                OPD.RN_Special_Instruction = txtRN_Special_Instruction;
                OPD.ProvisionalDiagnosis = Provisional_Diagnosis;
                OPD.Provisional_Diagnosis_Examination = Provisional_Diagnosis_Examination;
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
                OPD.JVP_Param = JVP;
                OPD.Edema_Param = Edema;
                OPD.Cyanosis_Param = Cyanosis;
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
                OPD.PU_R = PULR;
                OPD.PU_L = PULL;
                OPD.PL_L = PLLL;
                OPD.PL_R = PLLR;
                OPD.SU_L = SULL;
                OPD.SU_R = SULR;
                OPD.SL_L = SLLL;
                OPD.SL_R = SLLR;
                OPD.TruckTorso = Torso;
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
                OPD.Discharge_Request = Discharge_Request;
                OPD.Discharge_Type = ddlDischarge_Type;
                OPD.Medication_Refer_Doctor = Medication_Doctor;
                if (!string.IsNullOrEmpty(ProcedureTemplateContent))
                {
                    OPD.ProcedureTemplateContent = ProcedureTemplateContent;
                }

                if (!string.IsNullOrEmpty(ProcedureLevel_ID) && ProcedureLevel_ID != "0")
                {
                    OPD.ProcedureLevel_ID = Convert.ToInt32(ProcedureLevel_ID);
                }
                if (chkdischarge == true)
                {
                    if (!string.IsNullOrEmpty(txtDischarge_On))
                        OPD.Discharge_On = Convert.ToDateTime(txtDischarge_On);
                    if (!string.IsNullOrEmpty(txtNext_Visit))
                        OPD.Next_Visit = Convert.ToDateTime(txtNext_Visit);
                    string SMS_Contant = "عارف میموریل ٹیچنگ ہسپتال کی سہولیات پر اعتمادکرنےکاشکریہ ہماری سہولیات کی بہتری کے لیےآپ نیچےدیئے گے نمبرپر رابطہ کریں۔ 03060682558";
                    string msg = "";
                    //string CellNumber = txtMobile1.Text;
                    string CellNumber = (from tbl in db.Reg_patients
                                         where tbl.pat_id == Patient_ID
                                         select tbl.Mobile1).FirstOrDefault();

                    string DocumentName = "PatientReg";

                    var Patientno = (from tbl in db.Reg_patients
                                     where tbl.pat_id == Patient_ID
                                     select tbl.Patient_No).FirstOrDefault();
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
                    string SMS_Contant = "عارف میموریل ہسپتال پراعتماد کرنےکا شکریہ۔ آپکاداخلہ '" + ward + "' میں تجویز ہوا ہے-شکایات کیصورت میں اس نمبر پر رابطہ کریں۔ 03060682558";
                    string msg = "";

                    string CellNumber = (from tbl in db.Reg_patients
                                         where tbl.pat_id == Patient_ID
                                         select tbl.Mobile1).FirstOrDefault();

                    string DocumentName = "PatientReg";

                    var Patientno = (from tbl in db.Reg_patients
                                     where tbl.pat_id == Patient_ID
                                     select tbl.Patient_No).FirstOrDefault();
                }
                db.SubmitChanges();
                if (txtRN_Special_Instruction == "<li></li>") txtRN_Special_Instruction = "";


                if (RateBeats == "" && (ddlEmrgRhythm == null || ddlEmrgRhythm == "0") && (ddlEmrgVolume == null || ddlEmrgVolume == "0") && (OthersRN == "" || OthersRN == "<li></li>") && (BP_mm_Hg == "" || BP_mm_Hg == "___/___") && Temp_C == "" && Respiration_Min == "" && Saturation == "" && txtRN_Special_Instruction == "")
                {


                }
                else
                {
                    int existingNoteId = 0;
                    int.TryParse(hdfReceivingNoteID, out existingNoteId);

                    ReceivingNote rcvNote;

                    if (existingNoteId > 0)
                    {
                        rcvNote = db.ReceivingNotes.FirstOrDefault(r => r.ReceivingNoteID == existingNoteId);
                        if (rcvNote == null)
                        {
                            rcvNote = new ReceivingNote();
                            db.ReceivingNotes.InsertOnSubmit(rcvNote);
                        }
                    }
                    else
                    {
                        rcvNote = new ReceivingNote();
                        db.ReceivingNotes.InsertOnSubmit(rcvNote);
                    }

                    rcvNote.Patient_ID = Convert.ToInt32(Patient_ID);
                    rcvNote.Emergency_ID = null;
                    rcvNote.In_Patient_ID = OPD.In_Patient_ID;
                    rcvNote.RateBeats = RateBeats;
                    rcvNote.Emergency_Rhythm = ddlEmrgRhythm;
                    rcvNote.Emergency_Volume = ddlEmrgVolume;
                    rcvNote.OthersRecieveNote = OthersRN;
                    rcvNote.BloodPressure = BP_mm_Hg;
                    rcvNote.Blood_Suger = BSR;
                    rcvNote.Weight_Kg = Weight;
                    rcvNote.Height_cm = Height;
                    rcvNote.BMI = BMI;
                    rcvNote.Temperature = Temp_C;
                    rcvNote.RespirationRate = Respiration_Min;
                    rcvNote.O2_Saturation = Saturation;
                    rcvNote.RN_Special_Instruction = txtRN_Special_Instruction;
                    rcvNote.Receiving_Date = DateTime.Now;
                    rcvNote.O2_Saturation_Oxygen1 = O2_Saturation_Oxygen1;
                    rcvNote.O2_Saturation_Oxygen2 = O2_Saturation_Oxygen2;
                    rcvNote.user_id = AppConfig.UserID;
                    rcvNote.Type_Nursing = "IPD Receiving Note";

                    db.SubmitChanges();
                }

                if (PulseRate == "" && (Rhythmdischarge == null || Rhythmdischarge == "0") && (volumedisc == null || volumedisc == "0") && (otherecdesc == "" || otherecdesc == "<li></li>") && (BPDischarge == "" || BPDischarge == "___/___") && Tempdisch == "" && RespRateDesc == "" && (Oxygen2_desc == "" || Oxygen2_desc == "<li></li>") && (Special_Instruction_Desc == "" || Special_Instruction_Desc == "<li></li>" || Special_Instruction_Desc == "• "))
                {

                }
                else
                {
                    int existingNoteId = 0;
                    int.TryParse(hdfVitalDischargeID, out existingNoteId);

                    ReceivingNote rcvNote;

                    if (existingNoteId > 0)
                    {
                        rcvNote = db.ReceivingNotes.FirstOrDefault(r => r.ReceivingNoteID == existingNoteId);
                        if (rcvNote == null)
                        {
                            rcvNote = new ReceivingNote();
                            db.ReceivingNotes.InsertOnSubmit(rcvNote);
                        }
                    }
                    else
                    {
                        rcvNote = new ReceivingNote();
                        db.ReceivingNotes.InsertOnSubmit(rcvNote);
                    }

                    rcvNote.Patient_ID = Convert.ToInt32(Patient_ID);
                    rcvNote.Emergency_ID = null;
                    rcvNote.In_Patient_ID = OPD.In_Patient_ID;
                    rcvNote.RateBeats = PulseRate;
                    rcvNote.Emergency_Rhythm = Rhythmdischarge;
                    rcvNote.Emergency_Volume = volumedisc;
                    rcvNote.OthersRecieveNote = otherecdesc;
                    rcvNote.BloodPressure = BPDischarge;
                    rcvNote.Blood_Suger = BSRDischarge;
                    rcvNote.BMI = BMIDischarge;
                    rcvNote.Weight_Kg = WeightDischarge;
                    rcvNote.Height_cm = HeightDischarge;
                    rcvNote.Temperature = Tempdisch;
                    rcvNote.RespirationRate = RespRateDesc;
                    rcvNote.O2_Saturation = saturationDis;
                    rcvNote.RN_Special_Instruction = Special_Instruction_Desc;
                    rcvNote.operation_details_box = OperationalDetails;
                    rcvNote.follow_up_instructions = FollowUpInstruction;
                    rcvNote.Receiving_Date = Convert.ToDateTime(Receiving_Date_Discharge);
                    rcvNote.O2_Saturation_Oxygen1 = Oxygen1;
                    rcvNote.O2_Saturation_Oxygen2 = Oxygen2_desc;
                    rcvNote.user_id = AppConfig.UserID;
                    rcvNote.Type_Nursing = "Discharge IPD Receiving Note";

                    db.SubmitChanges();
                }
                if (doc == "0")
                {

                }
                else
                {
                    History_Data h_data = new History_Data();
                    h_data.Patient_Id = Convert.ToInt32(Patient_ID);
                    h_data.Emergency_Id = null;
                    h_data.In_Patient_Id = OPD.In_Patient_ID;
                    h_data.Doctor_Id = Convert.ToInt32(doc);
                    h_data.Clinical_Notes = clinical_Notes;
                    h_data.Date_Time = DateTime.Now;
                    db.History_Datas.InsertOnSubmit(h_data);
                    db.SubmitChanges();
                }

                /***********Setting 0 Inpatient id inserted medicine to current In patient id****************/
                /***********Update temporary medicines (Patient_ID == 0) to current In patient id - NO DELETION ****************/
                // Update temporary inpatient medicines
                // Update temporary medicines - ONLY change Patient_ID, NOTHING ELSE
                var tempMedicines = db.In_Patient_Medicines
                    .Where(p => p.Patient_ID == 0 && p.Transaction_Type == "InPatient")
                    .ToList();

                foreach (In_Patient_Medicine med in tempMedicines)
                {
                    med.Patient_ID = OPD.In_Patient_ID;  // ONLY THIS - NO DELETE
                }

                var tempDischargeMedicines = db.In_Patient_Medicines
                    .Where(p => p.Patient_ID == 0 && p.Transaction_Type == "InPatient Discharge Medicine")
                    .ToList();

                foreach (In_Patient_Medicine med in tempDischargeMedicines)
                {
                    med.Patient_ID = OPD.In_Patient_ID;  // ONLY THIS - NO DELETE
                }

                db.SubmitChanges();
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
            public string Gender;
            public string Age;
            public string Mobile;
            public string Address;
            public string Entry_Date;
            public string IPD_ID;
            public string Ward_Name;
            public string Bed_No;
        }

        [WebMethod]
        public static string PendingAdmisionPatients()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var data = (from op in db.Out_Patients
                        join p in db.Reg_patients
                        on op.Reg_PatId equals p.pat_id
                        where op.Follow_Up == "002" &&
              Convert.ToDateTime(op.Created_Time).Month == DateTime.Now.Month && Convert.ToDateTime(op.Created_Time).Year == DateTime.Now.Year && Convert.ToDateTime(op.Created_Time).Day == DateTime.Now.Day
                        select new
                        {
                            p.pat_id,
                            p.Patient_No,
                            p.Full_Name,
                            p.NIC,
                            //tibitt
                            //Department = db.GetDataValueName("Patient Main Category", op.),
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
        public static string Sides()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Sides = from d in db.DataValues
                        join v in db.ValueSets
                        on d.ValueSet_ID equals v.ValueSet_ID
                        where v.ValueSet_Name == "Sides"
                        select new
                        {
                            d.DataValue_Name,
                            d.DataValue_Description,

                        };
            return (new JavaScriptSerializer().Serialize(Sides));
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
        public static string getpharmacyitems(string searchString)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                string term = (searchString ?? "").Trim();

                var pharmacyItems = (from d in db.INV_Items
                                     where d.IsPharmacyItem == true
                                     && (d.Short_Item == false || d.Short_Item == null)
                                     && (d.Description.ToLower().Contains(term.ToLower())
                                         || (d.Salt != null && d.Salt.ToLower().Contains(term.ToLower())))
                                     orderby d.Item_ID descending
                                     select new
                                     {
                                         d.Item_ID,
                                         Description = (d.Salt != null ? (d.Salt + "-" + d.Description) : d.Description)
                                     }).Take(50).ToList();

                return (new JavaScriptSerializer().Serialize(pharmacyItems));
            }
        }
        [WebMethod]
        public static string FillPharmacyItemDropDown()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Routes = (from d in db.INV_Items

                          where d.Pharmacy_Item == true
                          select new
                          {
                              d.Item_ID,
                              Description = (d.Salt != null ? (d.Salt + "-" + d.Description) : d.Description),
                          }).ToList().Take(20);

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
            var ipd_id = (from tbl in db.In_Patients
                          where tbl.Patient_ID == int.Parse(PatientID)
                          && tbl.Discharge != true
                          orderby tbl.Created_Time descending
                          select tbl.In_Patient_ID).FirstOrDefault();

            var wardBed = (from tbl in db.In_Patients
                           where tbl.Patient_ID == int.Parse(PatientID)
                           && tbl.Discharge != true
                           orderby tbl.Created_Time descending
                           select new
                           {
                               Ward_Name = (from w in db.Ward_Definitions
                                            where w.Ward_ID == tbl.Ward_ID
                                            select w.Ward_Type).FirstOrDefault(),
                               tbl.Bed_No
                           }).FirstOrDefault();

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
                //pt.PatientType = db.GetDataValueName("Patient Type", pat.Patient_Type);
                Type = db.GetDataValueName("Patient Type", Type);
                pt.IPD_ID = ipd_id.ToString();

                if (wardBed != null)
                {
                    pt.Ward_Name = wardBed.Ward_Name ?? "";
                    pt.Bed_No = wardBed.Bed_No != null ? wardBed.Bed_No.ToString() : "";
                }
                else
                {
                    pt.Ward_Name = "";
                    pt.Bed_No = "";
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
                Response.Redirect("~/Modules/PatientManagement/InPatientsCase.aspx", false);
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
                        List<InPatientService> InPatientService = db.InPatientServices.Where(w => w.PatientId == ServiceDetailList.PatId && w.In_Patient_Id == ServiceDetailList.InPatId).ToList();

                        db.InPatientServices.DeleteAllOnSubmit(InPatientService);
                        db.SubmitChanges();
                    }

                    foreach (var item in ServiceDetailList.ServicesList)
                    {
                        InPatientService ipser = new PMS.InPatientService();
                        ipser.In_Patient_Id = ServiceDetailList.InPatId;
                        ipser.PatientId = ServiceDetailList.PatId;
                        ipser.EmergencyId = 0;
                        ipser.Ou_Patient_Id = "0";
                        ipser.PatientType = item.PatientType;
                        ipser.Services_Procedure_ItemName = item.Service_ProcedureName;
                        ipser.Service_ItemId = item.ServiceItemId;
                        ipser.ServiceType = item.ServiceItemType;
                        ipser.ServiceAmount = Convert.ToDecimal(item.ServiceItemAmount);
                        ipser.CreatedDate = item.ServiceDate;
                        ipser.UserName = item.UserName;
                        ipser.isbilled = false;
                        db.InPatientServices.InsertOnSubmit(ipser);
                    }
                    db.SubmitChanges();

                }

            }
            catch (Exception ex) { }
            return "";
        }

        [WebMethod]
        public static string LoadServicesDetail(int PatientId, int in_PatientId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                List<ServiceDetails> list = new List<ServiceDetails>();

                var InpatientServices = db.InPatientServices.DefaultIfEmpty().Where(w => w.PatientId == PatientId && w.In_Patient_Id == in_PatientId).OrderByDescending(x => x.CreatedDate).ToList();

                if (InpatientServices.Count > 0 && InpatientServices != null)
                {
                    foreach (var item in InpatientServices)
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

        public class Service
        {
            public int PatId { get; set; }
            public int InPatId { get; set; }
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
            //public string Status;
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
            //public string Status;
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
                obj.DermaLowerLimb = item.DermaLowerLimb == null ? "" : item.DermaLowerLimb.ToString();
                obj.DermaFlexures = item.DermaFlexures == null ? "" : item.DermaFlexures.ToString();

                obj.DermaGenitalias = item.DermaGenitalias == null ? "" : item.DermaGenitalias.ToString();
                obj.DermaHair = item.DermaHair == null ? "" : item.DermaHair.ToString();
                obj.DermaNail = item.DermaNail == null ? "" : item.DermaNail.ToString();
                obj.DermaMucousMembrane = item.DermaMucousMembrane == null ? "" : item.DermaMucousMembrane.ToString();
                obj.DermaEyes = item.DermaEyes == null ? "" : item.DermaEyes.ToString();
                obj.DermaEars = item.DermaEars == null ? "" : item.DermaEars.ToString();
                obj.DermaNose = item.DermaNose == null ? "" : item.DermaNose.ToString();
                obj.Created_Time = Convert.ToDateTime(item.Created_Time);

                obj.DermaLips = item.DermaLips == null ? "" : item.DermaLips.ToString();
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
                                    orderby rm.Doctor_Note_Date descending
                                    select new
                                    {
                                        rm.Doctor_Note_Date,
                                        rm.Doctor_Instruction,
                                        rm.Doctor_Status,
                                        DoctorStatus = db.GetDataValueName("Doctor Status", rm.Doctor_Status),
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
        public static string CheckReferIPDRights()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var referIPD = (from u in db.aspnet_Users
                            where u.UserId == AppConfig.UserID
                            select u.Refer_IPD).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(referIPD?.ToString() ?? "false");
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
                              Description = DBClass.getField("select isnull(Ward_Type,'0') from Ward_Definition where ward_id=" + data.Ward_ID),

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
        public class Infusion
        {
            public int PatientID { get; set; }

            public int InPatientID { get; set; }
            public List<InfusionDetails> InfusionDetails { get; set; }
        }
        public class Medicine
        {
            public int PatientID { get; set; }
            public List<MedicineDetails> MedicineList { get; set; }
        }
        public class MedicineDetails
        {
            public int ID { get; set; }
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

            public string Issue_Qty;
            public string Rec_Qty;
            public string Rtn_Qty;

            public string Regular;

            public string STAT;

            public string PRN;

            public string Unlisted_Med;

            public string Start_Date_Time { get; set; }

            public string Stop_Date_Time { get; set; }

            public string High_Risk { get; set; }

            public string Max_PRN { get; set; }

            public string User { get; set; }
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
                    List<InPatient_Doctor_Note> InPatient_Doctor_Note = db.InPatient_Doctor_Notes.Where(i => i.In_Patient_ID == DoctorDetail.InPatientID && i.status == "Create").ToList();
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
                    oInPatient_Doctor_Note.status = "Create";


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

                // Safety check: ensure we have a list even if empty
                MedicineDetail.MedicineList = MedicineDetail.MedicineList ?? new List<MedicineDetails>();

                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    // 1. Fetch existing discharge medicines for this patient
                    var existingMedicines = db.In_Patient_Medicines
                        .Where(p => p.Patient_ID == MedicineDetail.PatientID && p.Transaction_Type == "InPatient Discharge Medicine")
                        .ToList();

                    // 2. Determine if the incoming list has any new items (ID == 0)
                    bool hasNewItems = MedicineDetail.MedicineList.Any(m => m.ID == 0);

                    // 3. DELETE LOGIC – only perform deletion when:
                    //    - the incoming list is NOT empty
                    //    - there are NO new items (pure edit/delete mode)
                    //    This prevents accidental deletion when adding new medicines or when the list is empty.
                    if (MedicineDetail.MedicineList.Any() && !hasNewItems)
                    {
                        var incomingIds = MedicineDetail.MedicineList.Where(m => m.ID != 0).Select(m => m.ID).ToList();
                        var toDelete = existingMedicines
                            .Where(e => !incomingIds.Contains(e.In_Patient_Medicine_ID))
                            .ToList();

                        if (toDelete.Any())
                        {
                            db.In_Patient_Medicines.DeleteAllOnSubmit(toDelete);
                            System.Diagnostics.Debug.WriteLine($"DELETED {toDelete.Count} discharge medicines.");
                        }
                    }
                    else
                    {
                        System.Diagnostics.Debug.WriteLine("Skipping deletion (empty list or new items present).");
                    }

                    // 4. INSERT or UPDATE each incoming medicine
                    foreach (MedicineDetails newMed in MedicineDetail.MedicineList)
                    {
                        // If the item has an ID > 0, try to update it
                        if (newMed.ID > 0)
                        {
                            var existing = existingMedicines.FirstOrDefault(e => e.In_Patient_Medicine_ID == newMed.ID);
                            if (existing != null)
                            {
                                // Update all relevant fields
                                string medicineNameUpd = (newMed.Medicine_Name ?? "").Trim();
                                existing.Medicine_Name = medicineNameUpd;
                                existing.Dosage_Qty = newMed.Dosage_Qty;
                                existing.Frequency = newMed.Frequency;
                                existing.Injections = newMed.Injection;
                                existing.Oral = newMed.Oral;
                                existing.Dosage_From = newMed.Dosage_From;
                                existing.Other_Instruction = newMed.Other_Instruction;
                                existing.AttendingParamedical_Staff = newMed.AttendingParamedical_Staff;
                                var inventoryItemUpd = db.INV_Items
                                    .Where(p => p.Description.Trim() == medicineNameUpd)
                                    .FirstOrDefault();
                                existing.Item_Code = inventoryItemUpd != null ? inventoryItemUpd.Item_ID.ToString() : newMed.ItemCode;
                                // If you have Unlisted_Med as a string, convert accordingly
                                existing.Unlisted_Med = (newMed.Unlisted_Med == "1" || newMed.Unlisted_Med == "true") ? true : false;
                                // If you have other fields like Req_Qty, Rcv_Qty, update them here
                                continue; // skip insertion
                            }
                        }

                        // Otherwise, insert a new record (ID == 0 or not found)
                        bool.TryParse(newMed.Regular, out bool isRegular);
                        bool.TryParse(newMed.STAT, out bool isStat);
                        bool.TryParse(newMed.PRN, out bool isPrn);
                        bool.TryParse(newMed.Unlisted_Med, out bool isUnlistedMed);

                        string medicineName = (newMed.Medicine_Name ?? "").Trim();
                        string itemCode = newMed.ItemCode;
                        var inventoryItem = db.INV_Items
                            .Where(p => p.Description.Trim() == medicineName)
                            .FirstOrDefault();
                        if (inventoryItem != null)
                        {
                            itemCode = inventoryItem.Item_ID.ToString();
                        }

                        In_Patient_Medicine newMedicine = new In_Patient_Medicine()
                        {
                            Patient_ID = Convert.ToInt32(MedicineDetail.PatientID),
                            Item_Code = itemCode,
                            Medicine_Name = medicineName,
                            Transaction_Type = "InPatient Discharge Medicine",
                            Medicine_Date = newMed.Medicine_Date,
                            Oral = newMed.Oral,
                            Injections = newMed.Injection,
                            Dosage_From = newMed.Dosage_From,
                            AttendingParamedical_Staff = newMed.AttendingParamedical_Staff,
                            Frequency = newMed.Frequency,
                            Dosage_Qty = newMed.Dosage_Qty,
                            Other_Instruction = newMed.Other_Instruction,
                            Username = newMed.User,
                            Regular = isRegular,
                            STAT = isStat,
                            PRN = isPrn,
                            Unlisted_Med = isUnlistedMed,
                            chkDiccharge = true,
                            is_rejected = false,
                            Status = null
                        };

                        db.In_Patient_Medicines.InsertOnSubmit(newMedicine);
                    }

                    db.SubmitChanges();
                    System.Diagnostics.Debug.WriteLine("=== SaveDischargeMedicines Complete ===");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("SaveDischargeMedicines Error: " + ex.Message);
                return ex.Message;
            }
            return "Success";
        }
        [WebMethod]
        public static string SaveMedicines(string MedicineDetails)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var MedicineDetail = js.Deserialize<Medicine>(MedicineDetails);

                // Safety check
                MedicineDetail.MedicineList = MedicineDetail.MedicineList ?? new List<MedicineDetails>();

                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    // 1. Fetch existing entity objects
                    var existingMedicines = db.In_Patient_Medicines
                        .Where(p => p.Patient_ID == MedicineDetail.PatientID && p.Transaction_Type == "InPatient")
                        .ToList();

                    var existingNames = existingMedicines.Select(p => p.Medicine_Name.Trim()).ToList();
                    var incomingNames = MedicineDetail.MedicineList.Select(m => m.Medicine_Name.Trim()).ToList();

                    System.Diagnostics.Debug.WriteLine("=== SaveMedicines Debug ===");

                    // 2. DELETE LOGIC: only delete rows when ALL payload rows have IDs (pure edit mode).
                    // If any payload row has ID == 0 (new row added), skip DELETE to preserve existing rows.
                    bool isAddingNew = MedicineDetail.MedicineList.Any(m => m.ID == 0);
                    if (MedicineDetail.MedicineList.Any() && !isAddingNew)
                    {
                        var medicinesToDelete = existingMedicines
                            .Where(p => !incomingNames.Contains(p.Medicine_Name.Trim()))
                            .ToList();

                        if (medicinesToDelete.Any())
                        {
                            System.Diagnostics.Debug.WriteLine($"DELETING {medicinesToDelete.Count} removed medicines.");
                            db.In_Patient_Medicines.DeleteAllOnSubmit(medicinesToDelete);
                        }
                    }
                    else
                    {
                        System.Diagnostics.Debug.WriteLine("ADD or empty-list mode: skipping DELETE to preserve existing rows.");
                    }

                    // 3. INSERT LOGIC
                    foreach (MedicineDetails newMed in MedicineDetail.MedicineList)
                    {
                        string medicineName = newMed.Medicine_Name.Trim();

                        if (true)
                        {
                            System.Diagnostics.Debug.WriteLine("INSERTING new medicine: " + medicineName);

                            string itemCode = newMed.ItemCode;
                            var inventoryItem = db.INV_Items
                            .Where(p => p.Description.Trim() == newMed.Medicine_Name.Trim())
                            .FirstOrDefault();

                            if (inventoryItem != null)
                            {
                                itemCode = inventoryItem.Item_ID.ToString();
                            }

                            // Safely parse booleans
                            bool.TryParse(newMed.Regular, out bool isRegular);
                            bool.TryParse(newMed.STAT, out bool isStat);
                            bool.TryParse(newMed.PRN, out bool isPrn);
                            bool.TryParse(newMed.Unlisted_Med, out bool isUnlistedMed);

                            In_Patient_Medicine newMedicine = new In_Patient_Medicine()
                            {
                                Patient_ID = Convert.ToInt32(MedicineDetail.PatientID),
                                Item_Code = itemCode,
                                Medicine_Name = medicineName,
                                Transaction_Type = "InPatient",
                                Medicine_Date = newMed.Medicine_Date,
                                Oral = newMed.Oral,
                                Injections = newMed.Injection,
                                Dosage_From = newMed.Dosage_From,
                                AttendingParamedical_Staff = newMed.AttendingParamedical_Staff,
                                Frequency = newMed.Frequency,
                                Dosage_Qty = newMed.Dosage_Qty,
                                Other_Instruction = newMed.Other_Instruction,
                                Regular = isRegular,
                                STAT = isStat,
                                PRN = isPrn,
                                Unlisted_Med = isUnlistedMed,
                                Max_PRN_Dose = newMed.Max_PRN,
                                Username = newMed.User,
                                High_Risk_Drug = newMed.High_Risk,
                                is_rejected = false,
                                Status = null,
                                Start_Date_Time = null,
                                Stop_Date_Time = null,
                                Req_Qty = decimal.TryParse(newMed.Issue_Qty, out decimal issueQty) ? issueQty : 0,
                                Rcv_Qty = decimal.TryParse(newMed.Rec_Qty, out decimal recQty) ? recQty : 0,
                                Rtn_Qty = decimal.TryParse(newMed.Rtn_Qty, out decimal rtnQty) ? rtnQty : 0
                            };

                            if (!string.IsNullOrEmpty(newMed.Start_Date_Time) && newMed.Start_Date_Time != "null" && newMed.Start_Date_Time != "1/1/0001")
                            {
                                if (DateTime.TryParse(newMed.Start_Date_Time, out DateTime startDate) && startDate > DateTime.MinValue)
                                    newMedicine.Start_Date_Time = startDate;
                            }

                            if (!string.IsNullOrEmpty(newMed.Stop_Date_Time) && newMed.Stop_Date_Time != "null" && newMed.Stop_Date_Time != "1/1/0001")
                            {
                                if (DateTime.TryParse(newMed.Stop_Date_Time, out DateTime stopDate) && stopDate > DateTime.MinValue)
                                    newMedicine.Stop_Date_Time = stopDate;
                            }

                            db.In_Patient_Medicines.InsertOnSubmit(newMedicine);
                        }
                    }

                    // 3b. UPDATE LOGIC: Persist qty changes for medicines already in DB
                    foreach (MedicineDetails newMed in MedicineDetail.MedicineList)
                    {
                        if (!existingNames.Contains(newMed.Medicine_Name.Trim()))
                            continue;

                        decimal issueQty = decimal.TryParse(newMed.Issue_Qty, out decimal issueVal) ? issueVal : 0;
                        decimal recQty = decimal.TryParse(newMed.Rec_Qty, out decimal recVal) ? recVal : 0;
                        decimal rtnQty = decimal.TryParse(newMed.Rtn_Qty, out decimal rtnVal) ? rtnVal : 0;

                        var existingMedicine = existingMedicines
                            .FirstOrDefault(p => p.Medicine_Name.Trim() == newMed.Medicine_Name.Trim());

                        if (existingMedicine != null &&
                            (existingMedicine.Req_Qty != issueQty ||
                             existingMedicine.Rcv_Qty != recQty ||
                             existingMedicine.Rtn_Qty != rtnQty))
                        {
                            System.Diagnostics.Debug.WriteLine("UPDATING qty for medicine: " + existingMedicine.Medicine_Name);
                            existingMedicine.Req_Qty = issueQty;
                            existingMedicine.Rcv_Qty = recQty;
                            existingMedicine.Rtn_Qty = rtnQty;
                        }
                    }

                    // 4. Save both deletes and inserts
                    db.SubmitChanges();
                    System.Diagnostics.Debug.WriteLine("=== SaveMedicines Complete ===");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("SaveMedicines Error: " + ex.Message);
                return ex.Message;
            }
            return "Success";
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
        public static string Load_Infusion(int inPatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var infusion = (from data in db.Infusion_Orders
                                where data.In_Patient_Id == inPatientID
                                orderby data.Create_Time descending
                                select new
                                {
                                    data.Infusion_Type,
                                    data.Infusion_Fluid,
                                    data.Infusion_Volume,
                                    data.Infusion_Rate,
                                    data.Infusion_Hours,
                                    data.Additive,
                                    data.Additive_Dose,
                                    data.Route,
                                    data.Infusion_Side,
                                    data.Create_Time,
                                    data.Start_Date_time,
                                    data.Infusion_Stop_DateTime,
                                    data.Infusion_Stop_time,

                                    Username = DBClass.getField("select UserName from aspnet_users where UserId='" + data.Create_By + "'")



                                }

                    ).ToList();
                return (new JavaScriptSerializer()).Serialize(infusion);
            }
        }
        [WebMethod]
        public static string LoadMedicines(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var ups = (from St in db.aspnet_Users
                           where St.UserId == AppConfig.UserID
                           select St.Allow_Medication_Edit).FirstOrDefault();

                bool allowMedicationEdit = ups == true;

                var inPatmedicine = (from inPatmedicineList in db.In_Patient_Medicines
                                     where inPatmedicineList.Patient_ID == PatientID && inPatmedicineList.Transaction_Type == "InPatient"
                                     orderby inPatmedicineList.Medicine_Date descending
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
                                         inPatmedicineList.PRN,
                                         inPatmedicineList.Regular,
                                         inPatmedicineList.STAT,
                                         inPatmedicineList.Username,
                                         inPatmedicineList.Max_PRN_Dose,
                                         inPatmedicineList.Start_Date_Time,
                                         inPatmedicineList.Stop_Date_Time,
                                         inPatmedicineList.High_Risk_Drug,
                                         inPatmedicineList.Item_Code,
                                         inPatmedicineList.Req_Qty,
                                         inPatmedicineList.Rcv_Qty,
                                         inPatmedicineList.Rtn_Qty,
                                         inPatmedicineList.Unlisted_Med,

                                         DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(inPatmedicineList.Doctor_ID) select d.Emp_Name).FirstOrDefault(),

                                         AllowMedicationEdit = allowMedicationEdit





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
                                         inPatmedicineList.STAT,
                                         inPatmedicineList.Regular,
                                         inPatmedicineList.PRN,
                                         inPatmedicineList.Unlisted_Med,
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
                                     where inPatmedicineList.Patient_ID == PatientID
                                     && inPatmedicineList.Transaction_Type == "InPatient Discharge Medicine"
                                     && inPatmedicineList.chkDiccharge == true
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
                                         // --- ADD THESE MISSING FIELDS ---
                                         inPatmedicineList.Dosage_From,
                                         inPatmedicineList.Dosage_Qty,
                                         inPatmedicineList.Other_Instruction,

                                         inPatmedicineList.Item_Code,
                                         inPatmedicineList.Unlisted_Med,
                                         DoctorName = inPatmedicineList.Username,
                                         //DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(inPatmedicineList.Doctor_ID) select d.Emp_Name).FirstOrDefault(),
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
                string wardName = db.Ward_Definitions
                            .Where(w => w.Ward_ID == WardID)
                            .Select(w => w.Ward_Type)
                            .FirstOrDefault();

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
            public int In_Patient_ID;
            public string Value_Type;
            public string Value_TypeGroup;
            public string Test_Name;
            public string SampleDate;
            public string SampleID;
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
            public string ISSample;
            public string ISRZlt;
            public string ISAppRove;
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
                                     join p in db.Patients
                                     on outpat.Patient_ID equals p.Patient_ID
                                     join rp in db.Reg_patients
                                     on p.Reg_PatId equals rp.pat_id
                                     where rp.Patient_No == Patien_No && lbtM.Transaction_Type == "InPatient"


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
                                         DepartmentName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test                 Departments", t.Main_Department)).FirstOrDefault(),
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
                                         Is_Result = (from t in db.Lab_Test_Details where t.BillDetailID == lbtD.BillDetailID orderby t.Lab_Test_Detail_ID descending select t.isApproved).FirstOrDefault(),
                                         Doctor_ID = outpat.Doctor
                                     }
     ).ToList();

            ApprTest.Clear();
            SampleTest.Clear();
            AckTest.Clear();
            ResTest.Clear();


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

        public static IDictionary<string, int> AckTest = new Dictionary<string, int>();
        public static string Aknowledgment(string a, string b, string c)
        {
            int count = 0;

            if (AckTest.ContainsKey(a))
            {
                AckTest.TryGetValue(a, out count);
                AckTest.Remove(a);
                count = count + 1;
                AckTest.Add(a, count);
            }
            else
            {
                AckTest.Add(a, count);
            }
            var bill_detail_Id_Sample = a == "0" ? DBClass.newgetField("select  sd.Bill_Detail_ID from Sample_Master sm join Sample_Detail sd on sm.Sample_ID=sd.Sample_ID join Ar_Billing_Details abd on sd.Bill_Detail_ID = abd.Bill_Details_ID  where abd.Category_ID=" + b + " and sm.Patient_ID = " + c + "", count) : DBClass.newgetField("select  sd.Bill_Detail_ID from Sample_Master sm join Sample_Detail sd on sm.Sample_ID=sd.Sample_ID join Ar_Billing_Details abd on sd.Bill_Detail_ID = abd.Bill_Details_ID  where  abd.item_id=" + a + " and sm.Patient_ID = " + c, count);
            if (bill_detail_Id_Sample.Contains("row")) bill_detail_Id_Sample = "0";
            var std = DBClass.getField("select top 1  ltd.Lab_Test_Detail_ID from Lab_Test_Detail ltd where ltd.Bill_Details_ID= " + bill_detail_Id_Sample + " and  ltd.Patient_ID =" + c);
            if (std.Contains("row")) std = "0";
            return std;
        }

        public static IDictionary<string, int> ResTest = new Dictionary<string, int>();
        public static string IsResult(string a, string b, string c)
        {
            int count = 0;

            if (ResTest.ContainsKey(a))
            {
                ResTest.TryGetValue(a, out count);
                ResTest.Remove(a);
                count = count + 1;
                ResTest.Add(a, count);
            }
            else
            {
                ResTest.Add(a, count);
            }
            var bill_detail_Id_Sample = a == "0" ? DBClass.newgetField("select  sd.Bill_Detail_ID from Sample_Master sm join Sample_Detail sd on sm.Sample_ID=sd.Sample_ID join Ar_Billing_Details abd on sd.Bill_Detail_ID = abd.Bill_Details_ID  where abd.Category_ID=" + b + " and sm.Patient_ID = " + c + "", count) : DBClass.newgetField("select  sd.Bill_Detail_ID from Sample_Master sm join Sample_Detail sd on sm.Sample_ID=sd.Sample_ID join Ar_Billing_Details abd on sd.Bill_Detail_ID = abd.Bill_Details_ID  where  abd.item_id=" + a + " and sm.Patient_ID = " + c, count);
            if (bill_detail_Id_Sample.Contains("row")) bill_detail_Id_Sample = "0";
            var std = DBClass.getField("select top 1  isnull(ltd.Is_Result,'0')  from Lab_Test_Detail ltd where ltd.Bill_Details_ID= " + bill_detail_Id_Sample + " and  ltd.Patient_ID =" + c);
            if (std.Contains("row")) std = "0";
            return std;
        }

        //string[] ArrTest;

        public static IDictionary<string, int> ApprTest = new Dictionary<string, int>();

        public static string IsApproved(string a, string b, string c)
        {
            int count = 0;

            if (ApprTest.ContainsKey(a))
            {
                ApprTest.TryGetValue(a, out count);
                ApprTest.Remove(a);
                count = count + 1;
                ApprTest.Add(a, count);
            }
            else
            {
                ApprTest.Add(a, count);
            }
            var bill_detail_Id_Sample = a == "0" ? DBClass.newgetField("select  sd.Bill_Detail_ID from Sample_Master sm join Sample_Detail sd on sm.Sample_ID=sd.Sample_ID join Ar_Billing_Details abd on sd.Bill_Detail_ID = abd.Bill_Details_ID  where abd.Category_ID=" + b + " and sm.Patient_ID = " + c + "", count) : DBClass.newgetField("select  sd.Bill_Detail_ID from Sample_Master sm join Sample_Detail sd on sm.Sample_ID=sd.Sample_ID join Ar_Billing_Details abd on sd.Bill_Detail_ID = abd.Bill_Details_ID  where  abd.item_id=" + a + " and sm.Patient_ID = " + c, count);
            if (bill_detail_Id_Sample.Contains("row")) bill_detail_Id_Sample = "0";
            var std = DBClass.getField("select top 1  isnull(ltd.IsApproved,'0')  from Lab_Test_Detail ltd where ltd.Bill_Details_ID= " + bill_detail_Id_Sample + " and  ltd.Patient_ID =" + c);
            if (std.Contains("row")) std = "0";
            return std;
        }

        public static IDictionary<string, int> SampleTest = new Dictionary<string, int>();
        public static string IsSample(string a, string b, string c)
        {
            int count = 0;

            if (SampleTest.ContainsKey(a))
            {
                SampleTest.TryGetValue(a, out count);
                SampleTest.Remove(a);
                count = count + 1;
                SampleTest.Add(a, count);
            }
            else
            {
                SampleTest.Add(a, count);
            }

            var isSample = a == "0" ? DBClass.newgetField("select  sm.sample_id from Sample_Master sm join Sample_Detail sd on sm.Sample_ID=sd.Sample_ID join Ar_Billing_Details abd on sd.Bill_Detail_ID = abd.Bill_Details_ID  where abd.Category_ID=" + b + " and sm.Patient_ID = " + c + "", count) : DBClass.newgetField("select  sm.sample_id from Sample_Master sm join Sample_Detail sd on sm.Sample_ID=sd.Sample_ID join Ar_Billing_Details abd on sd.Bill_Detail_ID = abd.Bill_Details_ID  where  abd.item_id=" + a + " and sm.Patient_ID = " + c, count);
            if (isSample.Contains("row")) isSample = "0";
            return isSample;
        }
        [WebMethod]
        public static string GetTestList(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var InPatId = DBClass.getField("select In_Patient_ID from In_Patient where Patient_ID =" + id);
            var testDetailst = (from lbtM in db.Laboratory_Tests
                                join lbtD in db.Lab_Test_Details
                                on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                join inpat in db.In_Patients
                                on lbtM.Patient_ID equals inpat.In_Patient_ID

                                where inpat.Patient_ID == id && lbtM.Transaction_Type == "InPatient"
                                orderby lbtD.Date descending
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
                                    lbtD.Doctor,
                                    lbtD.Recieved_ID,
                                    lbtD.Is_Result,
                                    lbtD.IsBilled,
                                    lbtD.Bill_Details_ID,
                                    inpat.Patient_ID,
                                    DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(lbtD.Doctor) select d.Emp_Name).FirstOrDefault(),
                                    SampleID = (from s in db.Sample_Masters where s.Patient_ID == lbtD.Patient_ID select s).FirstOrDefault(),

                                    IsSample = IsSample(lbtD.Test_ID.ToString(), lbtD.Catagory_ID.ToString(), id.ToString()),


                                    bill_detail_Id_Sample = lbtD.Test_ID == 0 ? DBClass.getField("select  sd.Bill_Detail_ID from Sample_Master sm join Sample_Detail sd on sm.Sample_ID=sd.Sample_ID join Ar_Billing_Details abd on sd.Bill_Detail_ID = abd.Bill_Details_ID  where abd.Category_ID=" + lbtD.Catagory_ID + " and sm.Patient_ID = " + id + "") : DBClass.getField("select  sd.Bill_Detail_ID from Sample_Master sm join Sample_Detail sd on sm.Sample_ID=sd.Sample_ID join Ar_Billing_Details abd on sd.Bill_Detail_ID = abd.Bill_Details_ID  where  abd.item_id=" + lbtD.Test_ID + " and sm.Patient_ID = " + id),



                                    IsAknowledgment = Aknowledgment(lbtD.Test_ID.ToString(), lbtD.Catagory_ID.ToString(), id.ToString()),



                                    isResult = IsResult(lbtD.Test_ID.ToString(), lbtD.Catagory_ID.ToString(), id.ToString()),

                                    Is_Approved = IsApproved(lbtD.Test_ID.ToString(), lbtD.Catagory_ID.ToString(), id.ToString()),


                                }
                ).ToList();
            ApprTest.Clear();
            SampleTest.Clear();
            AckTest.Clear();
            ResTest.Clear();
            return (new JavaScriptSerializer()).Serialize(testDetailst);
        }
        public static bool isBilled(string InPatId, int LabTestDetail)
        {
            var isBilled = DBClass.getField("select Lab_Test_Detail_ID from Lab_Test_Detail  where Patient_ID =" + InPatId + "and Lab_Test_Detail_ID =" + LabTestDetail + "  and IsBilled = 1").Contains("row") ? false : true;

            return isBilled;
        }



        [WebMethod]
        public static string SaveTest(string tlist)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<LabTest>(tlist);

            /******************** 1. Deleting Previous 0 Value Saved Rows *******************/
            List<Laboratory_Test> invalidTests = db.Laboratory_Tests
                .Where(i => i.Patient_ID == 0 && i.Transaction_Type == "InPatient").ToList();
            db.Laboratory_Tests.DeleteAllOnSubmit(invalidTests);
            db.SubmitChanges(); // Clean up orphans first

            /******************** 2. Master Record Management *******************************/
            // Safely parse the Patient ID to prevent crashes if UI sends "(New)"
            int patientId = 0;
            int.TryParse(record.PatientID, out patientId);

            string LabtestID = "";
            Laboratory_Test masterTest = null;

            if (patientId > 0)
            {
                masterTest = db.Laboratory_Tests.FirstOrDefault(t =>
                    t.Patient_ID == patientId && t.Transaction_Type == "InPatient");
            }

            if (masterTest != null)
            {
                masterTest.Created_Time = DateTime.Now; // Update existing
            }
            else
            {
                // Create brand new master record
                masterTest = new Laboratory_Test();
                masterTest.Patient_ID = patientId;
                masterTest.Transaction_Type = "InPatient";
                masterTest.Created_Time = DateTime.Now;
                db.Laboratory_Tests.InsertOnSubmit(masterTest);
            }

            // Save master record so we have a valid Lab_Test_ID for the details
            db.SubmitChanges();
            LabtestID = masterTest.Lab_Test_ID.ToString();
            int labID = masterTest.Lab_Test_ID;

            /******************** 3. Fetch Data Once (Performance Fix) **********************/
            // Fetch the actual patient registration ID ONCE, outside the loop
            var reg_id = (from rg in db.Reg_patients
                          join p in db.In_Patients on rg.pat_id equals p.Patient_ID
                          where p.In_Patient_ID == patientId
                          orderby p.Reg_PatId descending
                          select p.Patient_ID).FirstOrDefault();

            // Load existing detail records into memory
            List<Lab_Test_Detail> existingDetails = db.Lab_Test_Details.Where(t => t.Lab_Test_ID == labID).ToList();

            // Create a list to track which ones to delete. We start with ALL existing records, 
            // and remove them from this list as we find matches.
            List<Lab_Test_Detail> detailsToDelete = existingDetails.ToList();

            /******************** 4. Sync Details (Update or Insert) ************************/
            foreach (var test in record.TestList)
            {
                int currentTestID = Convert.ToInt32(test.TestID);

                // Find match based on the original code's logic (Match by Test_ID or Category_ID)
                var matchedExistingRecord = existingDetails.FirstOrDefault(tst =>
                    (currentTestID != 0 && tst.Test_ID == currentTestID) ||
                    (currentTestID == 0 && tst.Catagory_ID == test.Catagory_ID)
                );

                if (matchedExistingRecord != null)
                {
                    // UPDATE: We found a match, so update its values
                    matchedExistingRecord.Date = Convert.ToDateTime(test.Date);
                    matchedExistingRecord.Doctor = test.Doctor.ToString();
                    matchedExistingRecord.Actual_Patient_ID = reg_id;
                    matchedExistingRecord.Special_Tests = test.Special_Tests;
                    matchedExistingRecord.Rotation_ID = test.RotationID;
                    matchedExistingRecord.Catagory_ID = test.Catagory_ID;
                    matchedExistingRecord.L_R_Rotation_ID = test.L_R_Rotation_ID;
                    matchedExistingRecord.Dept_ID = test.Dept_ID;
                    matchedExistingRecord.Area_Of_Interest = test.Area_Of_Interest;

                    if (!string.IsNullOrEmpty(test.Is_Result))
                        matchedExistingRecord.Is_Result = Convert.ToBoolean(test.Is_Result);
                    if (!string.IsNullOrEmpty(test.IsBIllied))
                        matchedExistingRecord.IsBilled = Convert.ToBoolean(test.IsBIllied);
                    if (!string.IsNullOrEmpty(test.RecievedID))
                        matchedExistingRecord.Recieved_ID = test.RecievedID;

                    // Remove this record from our deletion tracker so it survives
                    detailsToDelete.Remove(matchedExistingRecord);
                }
                else
                {
                    // ADD: This is a brand new test, so insert it
                    Lab_Test_Detail newDetail = new Lab_Test_Detail();
                    newDetail.Lab_Test_ID = labID;
                    newDetail.Patient_ID = patientId;
                    newDetail.Date = Convert.ToDateTime(test.Date);
                    newDetail.Doctor = test.Doctor.ToString();
                    newDetail.Actual_Patient_ID = reg_id;
                    newDetail.Special_Tests = test.Special_Tests;
                    newDetail.Rotation_ID = test.RotationID;
                    newDetail.Catagory_ID = test.Catagory_ID;
                    newDetail.L_R_Rotation_ID = test.L_R_Rotation_ID;
                    newDetail.Dept_ID = test.Dept_ID;
                    newDetail.Area_Of_Interest = test.Area_Of_Interest;
                    newDetail.Discharge = false;
                    newDetail.Test_ID = currentTestID;

                    if (!string.IsNullOrEmpty(test.Is_Result))
                        newDetail.Is_Result = Convert.ToBoolean(test.Is_Result);
                    if (!string.IsNullOrEmpty(test.IsBIllied))
                        newDetail.IsBilled = Convert.ToBoolean(test.IsBIllied);
                    if (!string.IsNullOrEmpty(test.RecievedID))
                        newDetail.Recieved_ID = test.RecievedID;

                    db.Lab_Test_Details.InsertOnSubmit(newDetail);
                }
            }

            /******************** 5. Delete Missing Records *********************************/
            // Any records left in 'detailsToDelete' were not sent in the UI payload
            if (detailsToDelete.Any())
            {
                db.Lab_Test_Details.DeleteAllOnSubmit(detailsToDelete);
            }

            // Save everything in one single, efficient database transaction
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
            //public string Area_Of_Interest { get; set; }
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


            //var OutPatientlist = (
            //    from s in db.Sysmtopms
            //    join o in db.Out_Patients
            //    on s.Out_Patient_ID equals o.Out_Patient_ID
            //    join p in db.Reg_patients
            //     on o.Reg_PatId equals p.pat_id
            //    where p.Patient_No == Patien_No
            //    select new { s.Symtom_ID, Symtom_Name = (DBClass.getField("select Datavalue_Description from ValueSet vs,DataValues dv where                                            vs.ValueSet_ID=dv.ValueSet_ID and vs.ValueSet_Name='Symtoms' and dv.DataValue_Name='" + s.Symtom_ID + "'").ToString()), s.Duration, Days_Years_Months = db.GetDataValueName("Days_Years_Months", s.Days_Years_Months), s.Remarks }
            //    ).ToList();


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

            //foreach (var item in OutPatientlist)
            //{
            //    SysmtopmsHistoryClass obj = new SysmtopmsHistoryClass();

            //    obj.Symtom_ID = item.Symtom_ID;
            //    obj.Duration = item.Duration;
            //    obj.Symtom_Name = item.Symtom_Name;
            //    obj.Days_Years_Months = item.Days_Years_Months;
            //    obj.Remarks = item.Remarks;
            //    obj.Status = "OutPatient";
            //    list.Add(obj);
            //}
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



            //var OutPatCase = (from op in db.Out_Patients
            //                  join p in db.Reg_patients
            //                  on op.Reg_PatId equals p.pat_id
            //                  where p.Patient_No == Patien_No

            //                  select new
            //                  {
            //                      op.HistoryOfPeresentIllness,
            //                      op.HistoryOfPastIllness,
            //                      op.HistoryOfFamily,
            //                      op.SocioEconomicHistory,
            //                      op.Birth_History,
            //                      op.Drug_History,
            //                      op.Personal_History,
            //                      op.ObstetricHistory,
            //                      op.AllergiesHistory,
            //                      op.TreatmentHistory,
            //                      op.Created_Time,
            //                      op.GIT,
            //                      op.GYNAE,
            //                      op.RESP,
            //                      op.CNS,
            //                      CVS = op.CVS.Replace("null", " "),
            //                      op.ProvisionalDiagnosis,
            //                      op.txtRemarksHistory,
            //                      op.Reffer_No,
            //                      Reffer_To = db.GetDataValueName("Patient Main Category", op.Reffer_To),
            //                      op.txtInputBox1,
            //                      op.Local,
            //                      op.Mucculor
            //                  }).ToList();



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

            //foreach (var item in OutPatCase)
            //{
            //    PatientHistoryClass obj = new PatientHistoryClass();

            //    obj.CVS = item.CVS;
            //    obj.ProvisionalDiagnosis = item.ProvisionalDiagnosis;
            //    obj.txtRemarksHistory = item.txtRemarksHistory;
            //    obj.Reffer_No = item.Reffer_No;
            //    obj.txtInputBox1 = item.txtInputBox1;
            //    obj.Local = item.Local;
            //    obj.Mucculor = item.Mucculor;

            //    obj.ObstetricHistory = item.ObstetricHistory;
            //    obj.AllergiesHistory = item.AllergiesHistory;
            //    obj.TreatmentHistory = item.TreatmentHistory;
            //    obj.GIT = item.GIT;
            //    obj.GYNAE = item.GYNAE;
            //    obj.RESP = item.RESP;
            //    obj.CNS = item.CNS;
            //    obj.HistoryOfPeresentIllness = item.HistoryOfPeresentIllness;
            //    obj.HistoryOfPastIllness = item.HistoryOfPastIllness;
            //    obj.HistoryOfFamily = item.HistoryOfFamily;
            //    obj.SocioEconomicHistory = item.SocioEconomicHistory;
            //    obj.Birth_History = item.Birth_History;
            //    obj.Drug_History = item.Drug_History;
            //    obj.Personal_History = item.Personal_History;

            //    obj.Created_Time = Convert.ToDateTime(item.Created_Time);
            //    obj.Status = "OutPatient";

            //    list.Add(obj);
            //}
            return ((new JavaScriptSerializer()).Serialize(list));
        }

        public class VitalParameterClass
        {
            public string ReceivingNoteID { get; set; }
            public string Pulse_Min;
            public string BP_mm_Hg;
            public string Weight_Kg;
            public string Height_cm;
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
            public string Blood_Suger;
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
                                   orderby op.Receiving_Date descending
                                   select new
                                   {
                                       op.ReceivingNoteID,
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
                                       op.BMI,
                                       op.Blood_Suger,
                                       op.Weight_Kg,
                                       op.Height_cm,
                                       user = db.aspnet_Users.Where(x => x.UserId == op.user_id).Select(x => x.UserName).FirstOrDefault(),


                                   }).ToList();

            //var outpatientlist = (from op in db.Out_Patients
            //                      join p in db.Reg_patients
            //                     on op.Reg_PatId equals p.pat_id
            //                      where p.Patient_No == Patien_No
            //                      orderby op.Created_Time descending
            //                      select new
            //                      {
            //                          op.pulse_Min,
            //                          op.BP_mm_Hg,
            //                          op.Weight_Kg,
            //                          op.Height_Cm,
            //                          op.Respiration_Min,
            //                          op.Temp_C,
            //                          op.L_M_P,
            //                          op.BMI,

            //                          op.Created_Time
            //                      }).ToList();

            List<VitalParameterClass> list = new List<VitalParameterClass>();
            //foreach (var item in outpatientlist)
            //{
            //    VitalParameterClass obj = new VitalParameterClass();
            //    obj.Pulse_Min = item.pulse_Min;
            //    obj.BP_mm_Hg = item.BP_mm_Hg;
            //    obj.Weight_Kg = item.Weight_Kg;
            //    obj.Height_Cm = item.Height_Cm;
            //    obj.Respiration_Min = item.Respiration_Min;
            //    obj.Temp_C = item.Temp_C;
            //    obj.L_M_P = item.L_M_P;
            //    obj.Receiving_date = DateTime.Now;
            //    obj.RN_Special_Instruction = "";
            //    obj.RN_Patient_General_Condition = "";
            //    obj.Created_Time = Convert.ToDateTime(item.Created_Time);
            //    obj.Status = "OutPatient";
            //    obj.BMI = item.BMI;

            //    list.Add(obj);
            //}

            foreach (var item in IPD_PatientList)
            {
                VitalParameterClass obj = new VitalParameterClass();
                obj.ReceivingNoteID = item.ReceivingNoteID.ToString();
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
                obj.BMI = item.BMI != null ? item.BMI.ToString() : "";
                obj.Blood_Suger = item.Blood_Suger != null ? item.Blood_Suger.ToString() : "";
                obj.Weight_Kg = item.Weight_Kg != null ? item.Weight_Kg.ToString() : "";
                obj.Height_cm = item.Height_cm != null ? item.Height_cm.ToString() : "";

                list.Add(obj);
            }
            return (new JavaScriptSerializer()).Serialize(list);
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
                                 orderby rcv.Receiving_Date descending
                                 select new
                                 {
                                     rcv.ReceivingNoteID,
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
                                     rcv.BMI,
                                     rcv.Blood_Suger,
                                     rcv.Weight_Kg,
                                     rcv.Height_cm,
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
                obj.ReceivingNoteID = item.ReceivingNoteID.ToString();
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
        public static string GetReceivingNoteByID(int NoteID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                // 1. Fetch the data from the DB first (without formatting)
                // This executes the SQL and brings the record into C# memory
                var rawNote = (from op in db.ReceivingNotes
                               where op.ReceivingNoteID == NoteID
                               select op).FirstOrDefault();

                if (rawNote == null) return "";

                // 2. Project into your anonymous object in C# (In-Memory)
                // Since rawNote is now a local C# object, we can use any C# methods like .ToString()
                var note = new
                {
                    rawNote.ReceivingNoteID,
                    rawNote.RateBeats,
                    rawNote.BSR,
                    rawNote.BloodPressure,
                    rawNote.Emergency_Rhythm,
                    rawNote.Emergency_Volume,
                    rawNote.OthersRecieveNote,
                    rawNote.RespirationRate,
                    rawNote.Temperature,
                    Receiving_Date = rawNote.Receiving_Date.HasValue
                                     ? rawNote.Receiving_Date.Value.ToString("MM/dd/yyyy hh:mm tt")
                                     : "",
                    rawNote.RN_Special_Instruction,
                    rawNote.O2_Saturation,
                    rawNote.O2_Saturation_Oxygen1,
                    rawNote.O2_Saturation_Oxygen2
                };

                // 3. Serialize the local object to JSON
                return (new System.Web.Script.Serialization.JavaScriptSerializer()).Serialize(note);
            }
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
            public bool Regular;
            public bool STAT;
            public bool PRN;
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
                                         orderby pm.Medicine_Date descending
                                         select new
                                         {
                                             pm.chkDiccharge,
                                             pm.AttendingParamedical_Staff,
                                             pm.Frequency,
                                             pm.In_Patient_Medicine_ID,
                                             pm.Injections,
                                             pm.Medicine_Date,
                                             pm.Medicine_Name,
                                             pm.Oral,
                                             pm.Patient_ID,
                                             pm.Recomended_Dosage,
                                             op.Created_Time,
                                             pm.Doctor_ID,
                                             pm.Dosage_From,
                                             pm.Dosage_Qty,
                                             pm.Other_Instruction,
                                             pm.Regular,
                                             pm.STAT,
                                             pm.PRN,
                                             DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(pm.Doctor_ID) select d.Emp_Name).FirstOrDefault()
                                         }).ToList();


                //var OutPatmedicineList = (from pm in db.In_Patient_Medicines
                //                          join op in db.Out_Patients
                //                          on pm.Patient_ID equals op.Out_Patient_ID
                //                          join p in db.Reg_patients
                //                          on op.Reg_PatId equals p.pat_id
                //                          where p.Patient_No == Patien_No && pm.Transaction_Type == "OutPatient"
                //                          select new { pm.chkDiccharge, pm.AttendingParamedical_Staff, pm.Frequency, pm.In_Patient_Medicine_ID, pm.Injections, pm.Medicine_Date, pm.Medicine_Name, pm.Oral, pm.Patient_ID, pm.Recomended_Dosage, op.Created_Time, pm.Doctor_ID, pm.Dosage_From, pm.Dosage_Qty, pm.Other_Instruction,pm.Regular,pm.STAT,pm.PRN, DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(pm.Doctor_ID) select d.Emp_Name).FirstOrDefault() }).ToList();


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
                    obj.Regular = Convert.ToBoolean(item.Regular);
                    obj.STAT = Convert.ToBoolean(item.STAT);
                    obj.PRN = Convert.ToBoolean(item.PRN);
                    obj.Recomended_Dosage = item.Recomended_Dosage;
                    obj.Status = "InPatient";
                    list.Add(obj);
                }
                //foreach (var item in OutPatmedicineList)
                //{
                //    MadicationClass obj = new MadicationClass();

                //    obj.AttendingParamedical_Staff = item.AttendingParamedical_Staff;
                //    obj.Frequency = item.Frequency;
                //    obj.Medicine_Date = Convert.ToDateTime(item.Medicine_Date);
                //    obj.Injections = item.Injections;

                //    obj.Medicine_Name = item.Medicine_Name;
                //    obj.Dosage_From = item.Dosage_From;
                //    obj.Dosage_Qty = item.Dosage_Qty;
                //    obj.Other_Instruction = item.Other_Instruction;
                //    obj.Regular = Convert.ToBoolean(item.Regular);
                //    obj.STAT = Convert.ToBoolean(item.STAT);
                //    obj.PRN = Convert.ToBoolean(item.PRN);
                //    obj.Oral = item.Oral;

                //    obj.Recomended_Dosage = item.Recomended_Dosage;

                //    obj.Status = "OutPatient";
                //    list.Add(obj);
                //}
                return (new JavaScriptSerializer()).Serialize(list);
            }
            return "";
        }



        [WebMethod]
        public static string LoadDoctorNoteDetail(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatmedicineList = (from pm in db.InPatient_Doctor_Notes
                                         join op in db.In_Patients
                                         on pm.In_Patient_ID equals op.In_Patient_ID
                                         where op.In_Patient_ID == PatientID && pm.status == "Create"
                                         orderby pm.Doctor_Note_Date descending
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
                                //Patient_Type = (from d in db.DataValues join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID where v.ValueSet_Name == "Patient Type" && d.DataValue_Name == tbl.Patient_Type select d.DataValue_Description).FirstOrDefault(),
                                tbl.Age_years,
                                tbl.Permanent_Address,
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
                    //recieptP.Patient_Type = Data.Patient_Type;
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
        public class InfusionDetails
        {
            public int Infusion_Order_ID { get; set; }
            public int Patient_ID { get; set; }
            public int In_Patient_ID { get; set; }
            public string Infusion_Fluid { get; set; }
            public string Additive { get; set; }
            public string Infusion_Volume { get; set; }
            public string Additive_Dose { get; set; }
            public string Infusion_Rate { get; set; }
            public string Route { get; set; }
            public string Created_time { get; set; }
            public string Created_by { get; set; }
            public string Updated_time { get; set; }
            public string Updated_by { get; set; }

            public string Duration { get; set; }

            public string Sides { get; set; }

            public string stop_Date { get; set; }

            public string Start_Date { get; set; }

            public string Infusion_Type { get; set; }
            public string Created_Date { get; set; }
        }

        [WebMethod]
        public static string SaveInfusion(string InfusionDetails)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var InfusionDetail = js.Deserialize<Infusion>(InfusionDetails);
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    /********************Deleting Previous 0 Value Saved Rows.***********************************/
                    List<Infusion_Order> InfusionList = db.Infusion_Orders.Where(i => i.In_Patient_Id == InfusionDetail.InPatientID).ToList();
                    db.Infusion_Orders.DeleteAllOnSubmit(InfusionList);
                    db.SubmitChanges();
                    int couterNewRecords = 0;

                    couterNewRecords = 0;

                    /*********************Inserting New Entry On Every Insert Or Update*************************/
                    foreach (InfusionDetails data in InfusionDetail.InfusionDetails)
                    {
                        Infusion_Order Infusion_Order = new Infusion_Order();

                        Infusion_Order.Patient_Id = Convert.ToInt32(InfusionDetail.PatientID);
                        Infusion_Order.In_Patient_Id = Convert.ToInt32(InfusionDetail.InPatientID);
                        Infusion_Order.Infusion_Fluid = data.Infusion_Fluid;
                        Infusion_Order.Additive = data.Additive;
                        Infusion_Order.Additive_Dose = data.Additive_Dose;
                        Infusion_Order.Create_By = AppConfig.UserID;
                        Infusion_Order.Create_Time = Convert.ToDateTime(data.Created_Date);
                        Infusion_Order.Infusion_Rate = data.Infusion_Rate;
                        Infusion_Order.Infusion_Volume = data.Infusion_Volume;
                        Infusion_Order.Route = data.Route;
                        Infusion_Order.Infusion_Hours = data.Duration;
                        Infusion_Order.Infusion_Side = data.Sides;
                        Infusion_Order.Infusion_Type = data.Infusion_Type;
                        if (data.Start_Date == null || data.Start_Date == "null" || data.Start_Date == "") { }
                        else
                        {
                            Infusion_Order.Start_Date_time = Convert.ToDateTime(data.Start_Date);
                        }
                        if (data.stop_Date == null || data.stop_Date == "null" || data.stop_Date == " " || data.stop_Date == "") { }
                        else
                        {
                            Infusion_Order.Infusion_Stop_time = Convert.ToDateTime(data.stop_Date);
                        }
                        db.Infusion_Orders.InsertOnSubmit(Infusion_Order);
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
        public static string InfusionVOL()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlInsVol> listInfVOL = new List<ddlInsVol>();
            string data = string.Empty;
            listInfVOL = (from p in db.DataValues
                          join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                          where v.ValueSet_Description == "Infusion Volume"
                          select new ddlInsVol
                          {
                              DataValueName = p.DataValue_Name,
                              DataValueDescription = p.DataValue_Description,
                          }).ToList();

            return (new JavaScriptSerializer()).Serialize(listInfVOL);
        }


        [WebMethod]
        public static string AdditiveDose()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlAdd> listadd = new List<ddlAdd>();
            string data = string.Empty;
            listadd = (from p in db.DataValues
                       join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                       where v.ValueSet_Description == "Additive Dose"
                       select new ddlAdd
                       {
                           DataValueName = p.DataValue_Name,
                           DataValueDescription = p.DataValue_Description,
                       }).ToList();

            return (new JavaScriptSerializer()).Serialize(listadd);
        }


        [WebMethod]
        public static string InfusionRate()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlInsRate> listinfRate = new List<ddlInsRate>();
            string data = string.Empty;
            listinfRate = (from p in db.DataValues
                           join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                           where v.ValueSet_Description == "Infusion Rate"
                           select new ddlInsRate
                           {
                               DataValueName = p.DataValue_Name,
                               DataValueDescription = p.DataValue_Description,
                           }).ToList();

            return (new JavaScriptSerializer()).Serialize(listinfRate);
        }


        [WebMethod]
        public static string Routes()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlRoute> listRoute = new List<ddlRoute>();
            string data = string.Empty;
            listRoute = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Routes"
                         select new ddlRoute
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                         }).ToList();

            return (new JavaScriptSerializer()).Serialize(listRoute);


        }


        [WebMethod]
        public static string InfussionPharmacy()
        {

            DataBaseDataContext dbs = new DataBaseDataContext();
            var infspharm = (from data in dbs.INV_Items
                             where (data.Pharmacy_Item == true && data.Infusion_Fluid == true)
                             select new
                             {
                                 data.Item_ID,
                                 data.Description,
                             }).ToList();
            return (new JavaScriptSerializer()).Serialize(infspharm);

        }

        [WebMethod]
        public static string GetMedicineStock(string itemId)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    // Parse the Item_ID
                    if (int.TryParse(itemId, out int itemID))
                    {
                        var item = db.INV_Items.FirstOrDefault(i => i.Item_ID == itemID);
                        if (item != null)
                        {
                            // Call your stock function
                            var stockTotal = db.GetInvenrtoryItemUomTotalStock(item.Item_ID, item.InventoryOrg);
                            return stockTotal.ToString();
                        }
                    }
                    return "0";
                }
            }
            catch (Exception ex)
            {
                return "0";
            }
        }

        [WebMethod]
        public static string additive()
        {

            DataBaseDataContext dbs = new DataBaseDataContext();
            var add_ddl = (from data in dbs.INV_Items
                           where (data.Pharmacy_Item == true && data.Additive_Dose == true)
                           select new
                           {
                               data.Item_ID,
                               data.Description,
                           }).ToList();
            return (new JavaScriptSerializer()).Serialize(add_ddl);

        }

        [WebMethod]
        public static string checkDeathDetails()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var ups = (from St in db.aspnet_Users
                       where St.UserId == AppConfig.UserID
                       select St.IPD_ALlow_Death_Details).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(ups);
        }

        private class ddlInsVol
        {
            public string DataValueName;
            public string DataValueDescription;

        }


        private class ddlAdd
        {
            public string DataValueName;
            public string DataValueDescription;

        }

        private class ddlInsRate
        {
            public string DataValueName;
            public string DataValueDescription;

        }


        private class ddlRoute
        {
            public string DataValueName;
            public string DataValueDescription;

        }


        [WebMethod]
        public static string GetProcedureTemplates()
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var templates = (from p in db.ProcedureLevels
                                     orderby p.TemplateName
                                     select new
                                     {
                                         ProcedureLevel_ID = p.ProcedureLevel_ID,
                                         TemplateName = p.TemplateName
                                     }).ToList();

                    return new JavaScriptSerializer().Serialize(templates);
                }
            }
            catch (Exception ex)
            {
                return "[]";
            }
        }

        [WebMethod]
        public static string GetProcedureTemplateById(int templateId)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var template = (from p in db.ProcedureLevels
                                    where p.ProcedureLevel_ID == templateId
                                    select new
                                    {
                                        ProcedureLevel_ID = p.ProcedureLevel_ID,
                                        TemplateName = p.TemplateName,
                                        FixValues = p.FixValues
                                    }).FirstOrDefault();

                    return new JavaScriptSerializer().Serialize(template);
                }
            }
            catch (Exception ex)
            {
                return "{}";
            }
        }

        [WebMethod]
        public static string ProcedureTabRights()
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var Procedure = (from tbl in db.sys_Parms
                                     where tbl.Name == "Procedure Template Tab"
                                     select tbl.Code)
                              .FirstOrDefault();

                    return Procedure ?? "01";
                }
            }
            catch (Exception ex)
            {
                return "0";
            }
        }

        [WebMethod]
        public static string MedicationRequestQty()
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var Medication = (from tbl in db.sys_Parms
                                      where tbl.Name == "Medication Request Qty"
                                      select tbl.Code)
                              .FirstOrDefault();

                    return Medication ?? "01";
                }
            }
            catch (Exception ex)
            {
                return "0";
            }
        }

        [WebMethod]
        public static string GetMedicationDoctor()
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                //var userin = AppConfig.UserID.ToString();
                var result = (from dv in db.HR_Employees
                              where dv.IsDoctor == true
                              select new
                              {
                                  dv.Emp_ID,
                                  dv.Emp_Name
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        [WebMethod]
        public static string CheckFinalBillAndDischargePermission(int InPatientID)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var sysParm = db.sys_Parms
                        .Where(p => p.Name == "InPatient Discharge Details"
                                 && p.Company_ID == AppConfig.Company_ID)
                        .Select(p => p.Code)
                        .FirstOrDefault();

                    if (sysParm != null && sysParm != "1")
                    {
                        return new JavaScriptSerializer().Serialize(new { allowed = false, reason = "Button is disabled in settings." });
                    }

                    var existingOPDId = 0;
                    try
                    {
                        var existingOPD = db.Out_Patients
                            .Where(o => o.Patient_ID == InPatientID)
                            .Select(o => (int?)o.Out_Patient_ID)
                            .FirstOrDefault();
                        existingOPDId = existingOPD ?? 0;
                    }
                    catch
                    {
                        // Ignore lookup errors
                    }

                    var billingExists = db.Ar_Billings
                        .Any(b => b.In_Patient_ID == (long)InPatientID);

                    if (!billingExists)
                    {
                        return new JavaScriptSerializer().Serialize(new { allowed = true, existingOutPatientID = existingOPDId });
                    }

                    var finalBillDone = db.Ar_Billings
                        .Any(b => b.In_Patient_ID == (long)InPatientID && b.final_bill_ipd == true);

                    if (finalBillDone)
                    {
                        return new JavaScriptSerializer().Serialize(new { allowed = true, existingOutPatientID = existingOPDId });
                    }

                    return new JavaScriptSerializer().Serialize(new { allowed = false, reason = "Please complete final billing first." });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { allowed = false, reason = ex.Message });
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
                        query = query.Where(c => c.DiagnosisName.ToLower().Contains(searchValue.ToLower()));
                    }
                    else
                    {
                        query = query.Take(6);
                    }

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
                return "[]";
            }
        }

        [WebMethod]
        public static string SaveNewDiagnosis(string Text)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                try
                {
                    string trimmedText = Text.Trim();
                    bool exists = db.DiagnosisDefinitions.Any(c => c.DiagnosisName.ToLower() == trimmedText.ToLower());
                    if (exists) return "0";

                    DiagnosisDefinition newDiagnosis = new DiagnosisDefinition { DiagnosisName = trimmedText };
                    db.DiagnosisDefinitions.InsertOnSubmit(newDiagnosis);
                    db.SubmitChanges();
                    return "1";
                }
                catch (Exception ex)
                {
                    return "Error saving diagnosis: " + ex.Message;
                }
            }
        }

        [WebMethod]
        public static string SavePrimaryDiagnosisForInPatient(string PrimaryDiagnosisList, int InPatientID)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var list = js.Deserialize<List<DiagnosisSaveItem>>(PrimaryDiagnosisList);

                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var existing = db.OutPatientPrimaryDiagnosis.Where(p => p.In_Patient_ID == InPatientID).ToList();
                    if (existing != null && existing.Count > 0)
                        db.OutPatientPrimaryDiagnosis.DeleteAllOnSubmit(existing);

                    foreach (var item in list)
                    {
                        OutPatientPrimaryDiagnosi newItem = new OutPatientPrimaryDiagnosi()
                        {
                            DiagnosisID = item.DiagnosisID,
                            PatientID = 0,
                            Remarks = item.Remarks,
                            In_Patient_ID = InPatientID,
                            OutPatientID = 0
                        };
                        db.OutPatientPrimaryDiagnosis.InsertOnSubmit(newItem);
                    }
                    db.SubmitChanges();
                    return "Success";
                }
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        [WebMethod]
        public static string SaveFinalDiagnosisForInPatient(string FinalDiagnosisList, int InPatientID)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var list = js.Deserialize<List<DiagnosisSaveItem>>(FinalDiagnosisList);

                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var existing = db.OutPatientFinalDiagnosis.Where(p => p.In_Patient_ID == InPatientID).ToList();
                    if (existing != null && existing.Count > 0)
                        db.OutPatientFinalDiagnosis.DeleteAllOnSubmit(existing);

                    foreach (var item in list)
                    {
                        OutPatientFinalDiagnosi newItem = new OutPatientFinalDiagnosi()
                        {
                            DiagnosisID = item.DiagnosisID,
                            PatientID = 0,
                            Remarks = item.Remarks,
                            In_Patient_ID = InPatientID,
                            OutPatientID = 0
                        };
                        db.OutPatientFinalDiagnosis.InsertOnSubmit(newItem);
                    }
                    db.SubmitChanges();
                    return "Success";
                }
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        [WebMethod]
        public static string LoadPrimaryDiagnosis(int InPatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var data = from oppd in db.OutPatientPrimaryDiagnosis
                           join pdd in db.DiagnosisDefinitions on oppd.DiagnosisID equals pdd.ID
                           where oppd.In_Patient_ID == InPatientID
                           select new
                           {
                               DiagnosisId = oppd.DiagnosisID,
                               Remarks = oppd.Remarks,
                               DiagnosisName = pdd.DiagnosisName
                           };
                return new JavaScriptSerializer().Serialize(data.ToList());
            }
        }

        [WebMethod]
        public static string LoadFinalDiagnosis(int InPatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var data = from oppd in db.OutPatientFinalDiagnosis
                           join pdd in db.DiagnosisDefinitions on oppd.DiagnosisID equals pdd.ID
                           where oppd.In_Patient_ID == InPatientID
                           select new
                           {
                               DiagnosisId = oppd.DiagnosisID,
                               Remarks = oppd.Remarks,
                               DiagnosisName = pdd.DiagnosisName
                           };
                return new JavaScriptSerializer().Serialize(data.ToList());
            }
        }

        public class DiagnosisSaveItem
        {
            public int DiagnosisID { get; set; }
            public string Remarks { get; set; }
            public int InPatientID { get; set; }
        }

    }
}