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