using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Data;
using System.Web.Services;
using System.Web.Script.Serialization;
using System.IO;

namespace PMS
{
    public partial class OperationBooking : System.Web.UI.Page
    {
#pragma warning disable CS0169 
        DataTable dt;
#pragma warning restore CS0169
        DataBaseDataContext db;
        string OperationTheaterName = "";
        public static int Operation_Booking_id;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                db = new DataBaseDataContext();
                BindingDropDown();
                BlankForm();
                
                txtDate_Operation.Text = DateTime.Now.Date.ToString(AppConfig.DateFormat);
                txtOperation_Booking_ID.Text = "(New)";
                txtProcedure.Attributes.Add("readonly", "readonly");

                if (Request.QueryString["ID"] != null)
                {
                    PopulateOperationBookingData(Convert.ToInt32(Request.QueryString["ID"]));
                }
            }

            // Operation Notes shows only after the patient's Anesthesia step 1 and step 2 are saved
            string patientText = string.IsNullOrEmpty(txtPatient_ID.Text) ? Request.QueryString["ID"] : txtPatient_ID.Text;
            int patientId;
            bool stepsSaved = int.TryParse(patientText, out patientId) && AnesthesiaStepsSaved(patientId);
            liOpNotes.Visible = stepsSaved;
            phOpNotes.Visible = stepsSaved;
        }

        /// <summary>True when the patient has an Anesthesia record with Pre-op (step 1) and Intra-op (step 2) saved.</summary>
        private static bool AnesthesiaStepsSaved(int patientId)
        {
            using (var adb = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                int companyId = AppConfig.Company_ID;
                return adb.Anesthesia_PreOps.Any(p => p.Patient_ID == patientId && p.Company_ID == companyId
                                                   && adb.Anesthesia_IntraOps.Any(i => i.Anesthesia_ID == p.Anesthesia_ID));
            }
        }

        private void ClearService()
        {
            
        }

        public void BlankForm()
        {
            txtPatient_ID.Text = "";
        

            txtDate_Operation.Text = DateTime.Now.Date.ToString(AppConfig.DateFormat);

            ddlRelative_Approval.SelectedIndex = 0;
            ddlPO_Condition.SelectedIndex = 0;
            ddlDrain.SelectedIndex = 0;
            ddlImplant.SelectedIndex = 0;
            ddlSutureUsed.SelectedIndex = 0;
            txtDate_Of_Approval.Text = DateTime.Now.Date.ToString(AppConfig.DateFormat);
            txtRelation_With_Patient.Text = "";
            ddlSurgeon_Name.SelectedIndex = 0;
            ddlDoctors.SelectedIndex = 0;
            ddlProcedureNames.SelectedIndex = 0;
            txtAssistant_Surgeon.Text = "";
            txtSecondAssistant.Text = "";
            txtJuniorAssistantStaff.Text = "";
            txtAnesthetist.Text = "";
            txtAssistantAnesthetist.Text = "";
            txtStaffNurse.Text = "";
            txtOTHealth_Complaints.Text = "";
            vlblAdress.Text = "";
            vlblAge_Year.Text = "";
            vlblContact.Text = "";
            vlblEntry_Date.Text = "";
            vlblGender.Text = "";
            vlblPatient_Name.Text = "";

          
        }

        public void BindingDropDown()
        {
            object valueset; 
            valueset = DBClass.GetValueSet("Department");



            db = new DataBaseDataContext();

            List<Service_Definition> SrvcList = new List<Service_Definition>();
            SrvcList = (from tbl in db.Service_Definitions
                        join tbl2 in db.DataValues on tbl.Service_Type equals tbl2.DataValue_Name
                        join tbl3 in db.ValueSets on tbl2.ValueSet_ID equals tbl3.ValueSet_ID
                        where tbl2.DataValue_Description == "Operation Theater"
                        select tbl).ToList();

            var operations = db.ValueSets.Where(v => v.ValueSet_Name.StartsWith("Operation Theater")).ToList();

            ddlOperationTherter.DataSource = operations;
            ddlOperationTherter.DataTextField = "ValueSet_Name";
            ddlOperationTherter.DataValueField = "ValueSet_ID";
            ddlOperationTherter.Items.Add(new ListItem("Please Select", "0"));
            ddlOperationTherter.DataBind();
           

            valueset = DBClass.GetValueSet("Patient Main Category");
            ddlDepartment.DataSource = valueset;
            ddlDepartment.DataTextField = "DataValue_Description";
            ddlDepartment.DataValueField = "DataValue_Name";
            ddlDepartment.Items.Add(new ListItem("Please Select", "0"));
            ddlDepartment.DataBind();

            valueset = DBClass.GetValueSet("Surgery");


          

            List<HR_Employee> EmpList = new List<HR_Employee>();
            EmpList = (from dr in db.HR_Employees
                       where dr.IsDoctor == true
                       select dr).ToList();

            ddlSurgeon_Name.DataSource = EmpList;
            ddlSurgeon_Name.DataTextField = "Emp_Name";
            ddlSurgeon_Name.DataValueField = "Emp_ID";
            ddlSurgeon_Name.Items.Add(new ListItem("Please Select", "0"));
            ddlSurgeon_Name.DataBind();

            ddlDoctors.DataSource = EmpList;
            ddlDoctors.DataTextField = "Emp_Name";
            ddlDoctors.DataValueField = "Emp_ID";
            ddlDoctors.Items.Add(new ListItem("Please Select", "0"));
            ddlDoctors.DataBind();

            var StaffList = (from st in db.HR_Employees
                             where st.Resign_Date == null
                             orderby st.Emp_Name
                             select st).ToList();

            ddlOpN_Surgeon.DataSource = EmpList;
            ddlOpN_Surgeon.DataTextField = "Emp_Name";
            ddlOpN_Surgeon.DataValueField = "Emp_ID";
            ddlOpN_Surgeon.Items.Add(new ListItem("Please Select", "0"));
            ddlOpN_Surgeon.DataBind();

            ddlOpN_Anaesthetist.DataSource = EmpList;
            ddlOpN_Anaesthetist.DataTextField = "Emp_Name";
            ddlOpN_Anaesthetist.DataValueField = "Emp_ID";
            ddlOpN_Anaesthetist.Items.Add(new ListItem("Please Select", "0"));
            ddlOpN_Anaesthetist.DataBind();

            ddlOpN_Scrub_Nurse.DataSource = StaffList;
            ddlOpN_Scrub_Nurse.DataTextField = "Emp_Name";
            ddlOpN_Scrub_Nurse.DataValueField = "Emp_ID";
            ddlOpN_Scrub_Nurse.Items.Add(new ListItem("Please Select", "0"));
            ddlOpN_Scrub_Nurse.DataBind();

            

            ddlProcedureNames.Items.Clear();
            valueset = DBClass.GetValueSet("IPD Procedures");
            ddlProcedureNames.DataSource = valueset;
            ddlProcedureNames.DataTextField = "DataValue_Description";
            ddlProcedureNames.DataValueField = "DataValue_Name";
            ddlProcedureNames.Items.Add(new ListItem("Please Select", "0"));
            ddlProcedureNames.DataBind();


            ddlRelative_Approval.Items.Add(new ListItem("No", "false"));
            ddlRelative_Approval.Items.Add(new ListItem("Yes", "true"));
            ddlRelative_Approval.DataBind();

            valueset = DBClass.GetValueSet("Laundary From To");
            ddlReferTo.DataSource = valueset;
            ddlReferTo.DataTextField = "DataValue_Description";
            ddlReferTo.DataValueField = "DataValue_Name";
            ddlReferTo.Items.Add(new ListItem("Please Select", "0"));
            ddlReferTo.DataBind();

            var wards = (from tbl2 in db.Ward_Definitions
                         select tbl2).ToList();
            ddlwards.DataSource = wards;
            ddlwards.DataTextField = "Ward_No";
            ddlwards.DataValueField = "Ward_ID";
            ddlwards.Items.Add(new ListItem("Please Select", "0"));
            ddlwards.DataBind();

            List<Room> rooms = (from tbl in db.Rooms
                                select tbl).ToList();
            ddlroom.DataSource = rooms;
            ddlroom.DataTextField = "Room_No";
            ddlroom.DataValueField = "Room_ID";
            ddlroom.Items.Add(new ListItem("Please Select", "0"));
            ddlroom.DataBind();

            valueset = DBClass.GetValueSet("Room Type");
            ddlRoomType.DataSource = valueset;
            ddlRoomType.DataTextField = "DataValue_Description";
            ddlRoomType.DataValueField = "DataValue_Name";
            ddlRoomType.Items.Add(new ListItem("Please Select", "0"));
            ddlRoomType.DataBind();

            valueset = DBClass.GetValueSet("Drain");
            ddlDrain.DataSource = valueset;
            ddlDrain.DataTextField = "DataValue_Description";
            ddlDrain.DataValueField = "DataValue_Name";
            ddlDrain.Items.Add(new ListItem("Please Select", "0"));
            ddlDrain.DataBind();

            valueset = DBClass.GetValueSet("Suture Used");
            ddlSutureUsed.DataSource = valueset;
            ddlSutureUsed.DataTextField = "DataValue_Description";
            ddlSutureUsed.DataValueField = "DataValue_Name";
            ddlSutureUsed.Items.Add(new ListItem("Please Select", "0"));
            ddlSutureUsed.DataBind();

            valueset = DBClass.GetValueSet("Implant");
            ddlImplant.DataSource = valueset;
            ddlImplant.DataTextField = "DataValue_Description";
            ddlImplant.DataValueField = "DataValue_Name";
            ddlImplant.Items.Add(new ListItem("Please Select", "0"));
            ddlImplant.DataBind();

            valueset = DBClass.GetValueSet("Post Order Condition");
            ddlPO_Condition.DataSource = valueset;
            ddlPO_Condition.DataTextField = "DataValue_Description";
            ddlPO_Condition.DataValueField = "DataValue_Name";
            ddlPO_Condition.Items.Add(new ListItem("Please Select", "0"));
            ddlPO_Condition.DataBind();

        }

        [WebMethod]
        public static string getGender()
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
        public static string GetMarital_Status()
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
        public static string GetPanel()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from panel in db.Panels
                              select new
                              {
                                  panel.Panel_ID,
                                  panel.Company_Name
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        public class PatientDetail
        {
            public string Name;
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
            public DateTime? AdmissionDate;

            public string AdvanceAmount { get; set; }
            public string FatherName { get; set; }

            public string Relation { get; set; }

            public string CNIC { get; set; }

            public string Blood_Group { get; set; }

            public string MaritalStatus { get; set; }
            public string PatientID { get; set; }
            public string PanelID { get; set; }

            

            public string Rh_Factor { get; set; }
        }

        [System.Web.Services.WebMethod]
        public static PatientDetail GetPatientDetails(string PatientID)
        {

            int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatientID));
            PatientDetail pt = new PatientDetail();
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
            if (pat != null)
            {

                pt.Name = pat.Full_Name;
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
                
                //pt.department = db.GetDataValueName("Patient Main Category", pat.Patient_Main_Category) + " ( " + db.GetDataValueName("Sub Departments", pat.Sub_Department) + " )";
                //pt.Patient_Type = db.GetDataValueName("Patient Type", pat.Patient_Type);
                pt.Gender = db.GetDataValueName("Gender", pat.Gender);
                var Patientno = pat.Patient_No.ToString();
                var count = (db.Reg_patients.Where(v => v.Patient_No == Convert.ToInt32(Patientno)).ToList());
                pt.Follow = count.Count.ToString();
                pt.Patient_Discount_Type = db.GetDataValueName("Patient Type", Type);
                pt.Mr_No = Convert.ToString(pat.Patient_No);
                pt.City = pat.city;
                //pt.DoctorName = (from emp in db.HR_Employees where emp.Emp_ID == Convert.ToInt32(pat.Doctor_ID) select emp.Emp_Name).FirstOrDefault();
                //pt.PanelID = pat.Panel_Companies;
                //pt.PanelComany = (from pn in db.Panels
                //                  where pn.Panel_ID == Convert.ToInt16(pat.Panel_Companies)
                //                  select pn.Company_Name).FirstOrDefault();
                pt.AdmissionDate = (from i in db.In_Patients
                                    where i.Patient_ID == int.Parse(PatientID)
                                    select i.Admission_Date).FirstOrDefault();
                return pt;
            }
            else
                return pt;
        }

        [WebMethod]
        public static string GetPatient_Type()
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
        public static string GetBloodgroup()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Blood"
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
        public static string FillRhFactor()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Rh Factor"
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
        public static string GetDepartment()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var qry = (from p in db.aspnet_Roles
                           join roles in db.aspnet_UsersInRoles
                           on p.RoleId equals roles.RoleId
                           join users in db.aspnet_Users on roles.UserId equals users.UserId
                           where users.UserId == AppConfig.UserID
                           select p).FirstOrDefault();
                if (qry.Department_ID == "All_Departments")
                {
                    var result = (from dv in db.DataValues
                                  join ds in db.ValueSets
                                  on dv.ValueSet_ID equals ds.ValueSet_ID
                                  where ds.ValueSet_Name == "Patient Main Category"
                                  select new
                                  {
                                      qry.Department_ID,
                                      dv.DataValue_Name,
                                      dv.DataValue_Description
                                  }).ToList();
                    data = new JavaScriptSerializer().Serialize(result);
                }
                else
                {
                    var result = (from dv in db.DataValues
                                  join ds in db.ValueSets
                                  on dv.ValueSet_ID equals ds.ValueSet_ID
                                  where ds.ValueSet_Name == "Patient Main Category" && dv.DataValue_Name == qry.Department_ID
                                  select new
                                  {
                                      qry.Department_ID,
                                      dv.DataValue_Name,
                                      dv.DataValue_Description
                                  }).ToList();
                    data = new JavaScriptSerializer().Serialize(result);

                }


            }
            return data;
        }

        [WebMethod]
        public static string GetSubDepartment()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Sub Departments"
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
        public static string FillPharmacyItemDropDown()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Routes = (from d in db.INV_Items
                          where d.IsPharmacyItem == true
                          select new
                          {
                              d.Item_Code,
                              Description = (d.Salt != null ? (d.Salt + "-" + d.Description) : d.Description),
                          }).ToList();

            return (new JavaScriptSerializer().Serialize(Routes));
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
            public string Doctor_Id { get; set; }
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
                    List<In_Patient_Medicine> In_Patient_MedicineList = db.In_Patient_Medicines.Where(i => i.Patient_ID == 0 && i.Transaction_Type == "OT").ToList();
                    db.In_Patient_Medicines.DeleteAllOnSubmit(In_Patient_MedicineList);
                    db.SubmitChanges();

                    int couterNewRecords = 0;

                    if (MedicineDetail.PatientID != 0)
                    {
                        /*********************Deleting Previous Entry On Every Insert Or Update*************************/
                        List<In_Patient_Medicine> inPatmedicineList = db.In_Patient_Medicines.Where(p => p.Patient_ID == MedicineDetail.PatientID && p.Transaction_Type == "OT").ToList();
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
                            Medicine_Name = oIn_Patient_Medicine.Medicine_Name,
                            Transaction_Type = "OT",     // Operation Theater
                            Medicine_Date = oIn_Patient_Medicine.Medicine_Date,
                            Dosage_From = oIn_Patient_Medicine.Dosage_From,
                            Dosage_Qty = oIn_Patient_Medicine.Dosage_Qty,
                            Oral = oIn_Patient_Medicine.Oral,
                            Doctor_ID = oIn_Patient_Medicine.Doctor_Id,
                            

                        };
                        db.In_Patient_Medicines.InsertOnSubmit(oIn_Patient_Medicine1);
                        couterNewRecords++;
                    }
                    db.SubmitChanges();
                }
            }
            catch (Exception ex)
            {
                throw ex;
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
                                         join op in db.Operation_Bookings
                                         on pm.Patient_ID equals op.Patient_ID
                                         join p in db.Reg_patients
                                         on op.Patient_ID equals p.pat_id
                                         where p.Patient_No == Patien_No && pm.Transaction_Type == "OT"
                                         select new { pm.chkDiccharge, pm.AttendingParamedical_Staff, pm.Frequency, pm.In_Patient_Medicine_ID, pm.Medicine_Name, pm.Medicine_Date, pm.Dosage_From, pm.Dosage_Qty, pm.Oral, pm.Patient_ID, op.Created_Time, pm.Doctor_ID, DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(pm.Doctor_ID) select d.Emp_Name).FirstOrDefault() }).ToList();


                var OutPatmedicineList = (from pm in db.In_Patient_Medicines
                                          join op in db.Out_Patients
                                          on pm.Patient_ID equals op.Out_Patient_ID
                                          join p in db.Reg_patients
                                          on op.Patient_ID equals p.pat_id
                                          where p.Patient_No == Patien_No && pm.Transaction_Type == "OT"
                                          select new { op.No_LabTest, op.No_medicine, pm.chkDiccharge, pm.AttendingParamedical_Staff, pm.Frequency, pm.In_Patient_Medicine_ID, pm.Injections, pm.Medicine_Date, pm.Medicine_Name, pm.Oral, pm.Patient_ID, pm.Recomended_Dosage, op.Created_Time, pm.Doctor_ID, DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(pm.Doctor_ID) select d.Emp_Name).FirstOrDefault() }).ToList();


                List<MadicationClass> list = new List<MadicationClass>();
                foreach (var item in inPatmedicineList)
                {
                    MadicationClass obj = new MadicationClass();

                    obj.AttendingParamedical_Staff = item.AttendingParamedical_Staff;
                    obj.Frequency = item.Frequency;
                    obj.Medicine_Date = Convert.ToDateTime(item.Medicine_Date);
                    obj.Dosage_From = item.Dosage_From;
                    obj.Dosage_Qty = item.Dosage_Qty;
                    obj.Medicine_Name = item.Medicine_Name;
                    obj.Oral = item.Oral;

                    
                    obj.Status = "OT";

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
                    obj.Oral = item.Oral;

                    obj.Recomended_Dosage = item.Recomended_Dosage;
                   
                    obj.Status = "OT";
                    list.Add(obj);
                }
                return (new JavaScriptSerializer()).Serialize(list);
            }
            return "";
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
            public string Dosage_From;
            public string Created_Time;
            public string Doctor_ID;
            public string DoctorName;
            public string Status;
            public string Dosage_Qty;
            public string Other_Instruction;
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


        public static  int OP_Count = 0;
        static int AT_Count = 0;

        [WebMethod]
        public static void Save(string OPCount,string ATCount)
        {
            OP_Count = Convert.ToInt32( OPCount);
            AT_Count = Convert.ToInt32(ATCount);
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

        // Operation Notes tab: a nullable employee id from a dropdown ("0" = Please Select).
        private static int? OpNId(string value)
        {
            int id;
            return int.TryParse(value, out id) && id > 0 ? (int?)id : null;
        }

        private static void SelectOpNId(DropDownList ddl, int? id)
        {
            ListItem item = id == null ? null : ddl.Items.FindByValue(id.ToString());
            ddl.SelectedValue = item == null ? "0" : item.Value;
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {

            lblMessage.Text = "";
            db = new DataBaseDataContext(DBClass.ConnectionString());
         
            int Opr_bk_id = 0;

            try
            {
               
                Operation_Booking operationBooking = new Operation_Booking();
                if (btnSave.Text == "Save")
                {
                    operationBooking.Created_By = AppConfig.UserID;
                    operationBooking.Created_Time = DateTime.Now;
                    operationBooking.Book_ID = AppConfig.Book_ID;
                    operationBooking.Company_ID = AppConfig.Company_ID;
                    db.Operation_Bookings.InsertOnSubmit(operationBooking);
                    db.SubmitChanges();
                    lblMessage.CssClass = "Data Inserted Successfully";
                    Opr_bk_id = operationBooking.Operation_Booking_ID;
                }
                else
                {
                    Opr_bk_id = Convert.ToInt32(txtOperation_Booking_ID.Text);
                    int id = Convert.ToInt32(Request.QueryString["ID"]);
                   
                    operationBooking = (from tbl in db.Operation_Bookings
                                        where tbl.Patient_ID == id
                                        select tbl).FirstOrDefault();


                  

                    operationBooking.Updated_By = AppConfig.UserID;
                    operationBooking.Updated_Time = DateTime.Now;

                    var Op_Booking_Dtl = (from tbl in db.Operation_Booking_Srvc_Dtls
                                          where tbl.Operation_Booking_ID == Opr_bk_id
                                          select tbl);
                    db.Operation_Booking_Srvc_Dtls.DeleteAllOnSubmit(Op_Booking_Dtl);

                    db.SubmitChanges();

                    lblMessage.CssClass = "Data Updated Successfully";
                }

                operationBooking.Patient_ID = Convert.ToInt32(txtPatient_ID.Text);
             
                operationBooking.Operation_Procedure = txtProcedure.Text;
                             
                operationBooking.Date = Convert.ToDateTime(txtDate_Operation.Text);
                operationBooking.Relative_Approval = Convert.ToBoolean(ddlRelative_Approval.SelectedValue);

                if (!string.IsNullOrEmpty(txtDate_Of_Approval.Text))
                    operationBooking.Date_Of_Approval = Convert.ToDateTime(txtDate_Of_Approval.Text);

                if (!string.IsNullOrEmpty(txtOperationDate.Text))
                    operationBooking.OperationDate = Convert.ToDateTime(txtOperationDate.Text);


                operationBooking.Relation_With_Patient = txtRelation_With_Patient.Text;
                operationBooking.Doctor_ID = Convert.ToInt32(ddlSurgeon_Name.SelectedValue);
                operationBooking.Operation_Theater = Convert.ToInt32(ddlOperationTherter.SelectedValue);
                operationBooking.Department = ddlDepartment.SelectedValue;
                operationBooking.Assistant_Doctor = txtAssistant_Surgeon.Text.ToString();
                operationBooking.Second_Assistant_Doctor = txtSecondAssistant.Text.ToString();
                operationBooking.Junior_Doctor = txtJuniorAssistantStaff.Text.ToString();
                operationBooking.Anesthetist1 = txtAnesthetist.Text.ToString();
                operationBooking.Anesthetist2 = txtAssistantAnesthetist.Text.ToString();
                operationBooking.Nurse1 = txtStaffNurse.Text.ToString();
                operationBooking.Operation_Theater_No = ddlOperationTherter.SelectedValue;
                
                operationBooking.Department = (ddlDepartment.SelectedValue).ToString();
                if (!string.IsNullOrEmpty(txtTimeOfStartOperation.Text))
                    operationBooking.TimeOfStart_Operation = Convert.ToDateTime(txtTimeOfStartOperation.Text).ToString("HH:mm:ss");

                if (!string.IsNullOrEmpty(txtTimeOfFinishOperation.Text))
                    operationBooking.TimeOfFinish_Operation = Convert.ToDateTime(txtTimeOfFinishOperation.Text).ToString("HH:mm:ss");

                if (!string.IsNullOrEmpty(txtOperationTime.Text))
                    operationBooking.OperationTime = Convert.ToDateTime(txtOperationTime.Text).ToString("HH:mm:ss");

                operationBooking.DoctorName = ddlDoctors.SelectedValue;
                operationBooking.ProcedureName = ddlProcedureNames.SelectedValue;
                operationBooking.Patient_Procedure = txtOTHealth_Complaints.Text;

                if ((txtTimeOfStartOperation.Text == "00:00:00" || txtTimeOfStartOperation.Text == "00 : 00" || txtTimeOfStartOperation.Text == "") &&
                    (txtTimeOfFinishOperation.Text == "00:00:00" || txtTimeOfFinishOperation.Text == "00 : 00" || txtTimeOfFinishOperation.Text == "") &&
                    ddlOperationTherter.SelectedValue == "0")
                {
                    operationBooking.OperationStatus = "pending";
                }
                else
                {
                    operationBooking.OperationStatus = "done";
                }

                operationBooking.Operation_Theater_Name = ddlOperationTheaterRoomNo.SelectedValue.ToString();
                operationBooking.RecoveryDetails = txtRecoveryDetails.Text;
                operationBooking.PO_Findings = txtFindings.Text;
                operationBooking.PO_Procedure = txtProcedure_PO.Text;
                operationBooking.Drain = ddlDrain.SelectedValue;
                operationBooking.SutureUsed = ddlSutureUsed.SelectedValue;
                operationBooking.Implant = ddlImplant.SelectedValue;
                operationBooking.PO_Condition = ddlPO_Condition.SelectedValue;

                
                operationBooking.NPO_Yes = (rdbNpo_Yes.Checked == false && rdbNpo_No.Checked == false) ? null : (rdbNpo_No.Checked == true ? null : (bool?)rdbNpo_Yes.Checked);

                operationBooking.NPO_No = (rdbNpo_Yes.Checked == false && rdbNpo_No.Checked == false) ? null : (rdbNpo_Yes.Checked == true ? null : (bool?)rdbNpo_No.Checked);


                operationBooking.SpecialInstruction = txtSpecialInstruction.Text;
                operationBooking.Est_Blood_Loose = chk_Bloodloose.Checked;
                operationBooking.Intra_Operative_Fluid = chk_Bloodtrans.Checked;
                operationBooking.Intra_Operative_Urine = chk_Urine.Checked;
                operationBooking.Swab_Instrument = chk_Swab_Instrument.Checked;

                if (AnesthesiaStepsSaved(operationBooking.Patient_ID ?? 0))
                {
                    operationBooking.OpN_Bed_Room_No = txtOpN_Bed_Room_No.Text;
                    operationBooking.OpN_Op_Date = string.IsNullOrEmpty(txtOpN_Op_Date.Text) ? (DateTime?)null : Convert.ToDateTime(txtOpN_Op_Date.Text);
                    operationBooking.OpN_Op_Time = txtOpN_Op_Time.Text;
                    operationBooking.OpN_PreOp_Dx = txtOpN_PreOp_Dx.Text;
                    operationBooking.OpN_PostOp_Dx = txtOpN_PostOp_Dx.Text;
                    operationBooking.OpN_Surgeon_ID = OpNId(ddlOpN_Surgeon.SelectedValue);
                    operationBooking.OpN_Assistants = txtOpN_Assistants.Text;
                    operationBooking.OpN_Anaesthetist_ID = OpNId(ddlOpN_Anaesthetist.SelectedValue);
                    operationBooking.OpN_Type_Of_Anaesthesia = txtOpN_Type_Of_Anaesthesia.Text;
                    operationBooking.OpN_Procedure_Name = txtOpN_Procedure_Name.Text;
                    operationBooking.OpN_Duration = txtOpN_Duration.Text;
                    operationBooking.OpN_Thread_Catgut = txtOpN_Thread_Catgut.Text;
                    operationBooking.OpN_Thread_Vicryl = txtOpN_Thread_Vicryl.Text;
                    operationBooking.OpN_Thread_Proline = txtOpN_Thread_Proline.Text;
                    operationBooking.OpN_Thread_Silk = txtOpN_Thread_Silk.Text;
                    operationBooking.OpN_Procedure_Notes = txtOpN_Procedure_Notes.Text;
                    operationBooking.OpN_Blood_Loss = txtOpN_Blood_Loss.Text;
                    operationBooking.OpN_IV_Fluids = txtOpN_IV_Fluids.Text;
                    operationBooking.OpN_Blood_Transfused = txtOpN_Blood_Transfused.Text;
                    operationBooking.OpN_Urine_Output = txtOpN_Urine_Output.Text;
                    operationBooking.OpN_Swab_Instrument_Count = txtOpN_Swab_Instrument_Count.Text;
                    operationBooking.OpN_Scrub_Nurse_ID = OpNId(ddlOpN_Scrub_Nurse.SelectedValue);
                }

                

                db.SubmitChanges();

                if (fileUpload_CF_OP.HasFile)
                {
                    var _HttpFileCollection = Request.Files;

                    var count = _HttpFileCollection.Count -  OP_Count;

                    try
                    {
                        for (int i = 0; i < OP_Count  ; i++)
                        {
                            HttpPostedFile _HttpPostedFile = _HttpFileCollection[i];
                            
                            string Op_booking_id = Convert.ToString(Opr_bk_id);
                            string stimg = string.Empty;

                                                




                            string filenameWithoutExt = System.IO.Path.GetFileNameWithoutExtension(_HttpPostedFile.FileName);
                            string fileExt = System.IO.Path.GetExtension(_HttpPostedFile.FileName);
                            string filename = System.IO.Path.GetFileName(_HttpPostedFile.FileName);
#pragma warning disable CS0219 
                            var max = "0";
#pragma warning restore CS0219 
                            var ID = Request.QueryString["ID"];
                            

                            stimg = "OperationDetail-" + Op_booking_id +"-"+i+ "_OP.jpg";

                            filename = Path.GetFileName(_HttpPostedFile.FileName);
                            var fullPath = "~/Operation_Booking_Images/" + stimg;
                            if (File.Exists(Server.MapPath(fullPath)))
                            {
                           
                                string savePath = HttpContext.Current.Server.MapPath("~/Operation_Booking_Images/") + stimg;
                                File.Delete(savePath);

                            }

                            _HttpPostedFile.SaveAs(Server.MapPath("~/Operation_Booking_Images/") + stimg);

                            if(i==0)
                            {
                                operationBooking.Consent_Form_Image = stimg;
                            }
                            else if (i == 1)
                            {
                                operationBooking.Consent_Form_Image_1 = stimg;
                            }
                            if (i == 2)
                            {
                                operationBooking.Consent_Form_Image_2 = stimg;
                            }
                            if (i == 3)
                            {
                                operationBooking.Consent_Form_Image_3 = stimg;
                            }
                            if (i == 4)
                            {
                                operationBooking.Consent_Form_Image_4 = stimg;
                            }


                            
                            db.SubmitChanges();
                           

                        }
                        Response.Write("Data Successfully Saved");

                    }
                    catch (Exception ex)
                    {
                        lblMessage.Text = "Upload status: The file could not be uploaded. The following error occured: " + ex.Message;
                    }
                }

                if (fileUpload_CF_AT.HasFile)
                {

                    var _HttpFileCollection = Request.Files;
                    try
                    {
                        for (int i = OP_Count; i < _HttpFileCollection.Count; i++)
                        {
                            HttpPostedFile _HttpPostedFile = _HttpFileCollection[i];

                            
                            string Op_booking_id = Convert.ToString(Opr_bk_id);
                            string stimg = string.Empty;

                            string filenameWithoutExt = System.IO.Path.GetFileNameWithoutExtension(_HttpPostedFile.FileName);
                            string fileExt = System.IO.Path.GetExtension(_HttpPostedFile.FileName);
                            string filename = System.IO.Path.GetFileName(_HttpPostedFile.FileName);
#pragma warning disable CS0219 
                            var max = "0";
#pragma warning restore CS0219 
                            var ID = Request.QueryString["ID"];
                           
                            var ii = i - OP_Count;
                            stimg = "OperationDetail-" + Op_booking_id + "-" + ii + "_AT.jpg";

                            filename = System.IO.Path.GetFileName(_HttpPostedFile.FileName);
                            var fullPath = "~/Operation_Booking_Images/" + stimg;
                            if (System.IO.File.Exists(Server.MapPath(fullPath)))
                            {
                               
                                string savePath = HttpContext.Current.Server.MapPath("~/Operation_Booking_Images/") + stimg;
                                File.Delete(savePath);
                            }




                            _HttpPostedFile.SaveAs(Server.MapPath("~/Operation_Booking_Images/") + stimg);

                            if (i - OP_Count == 0)
                            {
                                operationBooking.CF_Image_Anesthesia = stimg;
                            }
                            else if (i - OP_Count == 1)
                            {
                                operationBooking.CF_Image_Anesthesia_1 = stimg;
                            }
                            if (i - OP_Count == 2)
                            {
                                operationBooking.CF_Image_Anesthesia_2 = stimg;
                            }
                            if (i - OP_Count == 3)
                            {
                                operationBooking.CF_Image_Anesthesia_3 = stimg;
                            }
                            if (i - OP_Count == 4)
                            {
                                operationBooking.CF_Image_Anesthesia_4 = stimg;
                            }

                            
                            db.SubmitChanges();
                        }
                        Response.Write("Data Successfully Saved");
                     
                    }
                    catch (Exception ex)
                    {
                        lblMessage.Text = "Upload status: The file could not be uploaded. The following error occured: " + ex.Message;
                    }
                }

                Response.Redirect("~/Modules/OT/OperationBooking.aspx?ID=" + operationBooking.Patient_ID, false);
            
            }
            catch (Exception exc)
            {
                lblMessage.CssClass = "errorMessage";
                lblMessage.Text = exc.Message;
            }

            BlankForm();
        }

        [WebMethod]
        public static string LoadConsentImages(string patientId, string Op_Booking_Id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var data = (from op in db.Operation_Bookings

                        where op.Patient_ID == int.Parse(patientId) && op.Operation_Booking_ID == Convert.ToInt32(Op_Booking_Id)
                        select new
                        {
                            Image_path_OP = op.Consent_Form_Image,
                            Image_path_OP_1 = op.Consent_Form_Image_1,
                            Image_path_OP_2 = op.Consent_Form_Image_2,
                            Image_path_OP_3 = op.Consent_Form_Image_3,
                            Image_path_OP_4 = op.Consent_Form_Image_4,
                            Image_path_AT = op.CF_Image_Anesthesia,
                            Image_path_AT_1 = op.CF_Image_Anesthesia_1,
                            Image_path_AT_2 = op.CF_Image_Anesthesia_2,
                            Image_path_AT_3 = op.CF_Image_Anesthesia_3,
                            Image_path_AT_4 = op.CF_Image_Anesthesia_4
                        }).FirstOrDefault();

            return (new JavaScriptSerializer().Serialize(data));
        }


        [WebMethod]
        public static string DeleteImage(string imagSrc, string Op_Booking_Id, string patientId, string CF_Type)
        {
            string imageFilePath = HttpContext.Current.Server.MapPath(imagSrc);

            System.IO.File.Delete(imageFilePath);
            string splitedImageFilePAth = imagSrc.Split('/')[1];
            string sql = string.Empty;
            string status = string.Empty;
          
            if (CF_Type == "op")
            {
                sql = "update Operation_Booking set Consent_Form_Image = null where Operation_Booking_ID='" + Convert.ToInt32(Op_Booking_Id) + "' and Patient_ID='" + Convert.ToInt32(patientId) + "'";
                status = "Success_op";
            }

            if (CF_Type == "at")
            {
                sql = "update Operation_Booking set CF_Image_Anesthesia = null where Operation_Booking_ID='" + Convert.ToInt32(Op_Booking_Id) + "' and Patient_ID='" + Convert.ToInt32(patientId) + "'";
                status = "Success_at";

            }

            DBClass.executeNonQueryWithoutBegin(sql);
            
            return status;
        }


        

        private void PopulateOperationBookingData(int PatientId)
        {
            try
            {
                db = new DataBaseDataContext();

                var operationBooking = (from ob in db.Operation_Bookings
                                        join pt in db.Reg_patients
                                        on ob.Patient_ID equals pt.pat_id
                                        where ob.Patient_ID == PatientId
                                        select new
                                        {
                                            pt.Patient_No,
                                            pt.Full_Name,
                                            pt.Created_time,
                                            pt.Mobile1,
                                            pt.Permanent_Address,
                                            pt.Gender,
                                            pt.Age_years,
                                            ob.Operation_Booking_ID,
                                            ob.OpN_Bed_Room_No,
                                            ob.OpN_Op_Date,
                                            ob.OpN_Op_Time,
                                            ob.OpN_PreOp_Dx,
                                            ob.OpN_PostOp_Dx,
                                            ob.OpN_Surgeon_ID,
                                            ob.OpN_Assistants,
                                            ob.OpN_Anaesthetist_ID,
                                            ob.OpN_Type_Of_Anaesthesia,
                                            ob.OpN_Procedure_Name,
                                            ob.OpN_Duration,
                                            ob.OpN_Thread_Catgut,
                                            ob.OpN_Thread_Vicryl,
                                            ob.OpN_Thread_Proline,
                                            ob.OpN_Thread_Silk,
                                            ob.OpN_Procedure_Notes,
                                            ob.OpN_Blood_Loss,
                                            ob.OpN_IV_Fluids,
                                            ob.OpN_Blood_Transfused,
                                            ob.OpN_Urine_Output,
                                            ob.OpN_Swab_Instrument_Count,
                                            ob.OpN_Scrub_Nurse_ID,
                                            ob.Operation_Name,
                                            ob.Operation_Theater_No,
                                            ob.Operation_Theater_Name,
                                            ob.Time_Allocation_Hour,
                                            ob.Time_Allocation_Min,
                                            ob.Date,
                                            ob.Transferred_From_Dept,
                                            ob.Recommended_By_Hospital,
                                            ob.Relative_Approval,
                                            ob.Date_Of_Approval,
                                            ob.Relation_With_Patient,
                                            ob.Doctor_ID,
                                            ob.Operation_Charges,
                                            ob.Assistant_Doctor,
                                            ob.Second_Assistant_Doctor,
                                            ob.Junior_Doctor,
                                            ob.Anesthetist1,
                                            ob.Anesthetist2,
                                            ob.Nurse1,
                                            ob.Nurse2,
                                            ob.Patient_ID,
                                            ob.Anesthetist,
                                            ob.Surgery,
                                            ob.Department,
                                            ob.TimeOfStart_Operation,
                                            ob.TimeOfFinish_Operation,
                                            ob.System_Type,
                                            ob.Operation_Procedure,
                                            ob.Shifted_To,
                                            ob.Operation_Notes,                                         
                                            ob.Follow_Date,
                                            ob.Consent_Form_Image,
                                            ob.RecoveryDetails,
                                            ob.PO_Findings,
                                            ob.PO_Procedure,
                                            ob.Drain,
                                            ob.SutureUsed,
                                            ob.Implant,
                                            ob.PO_Condition,
                                            ob.NPO_Yes,
                                            ob.NPO_No,
                                            ob.SpecialInstruction,
                                            ob.Est_Blood_Loose,
                                            ob.Intra_Operative_Fluid,
                                            ob.Intra_Operative_Urine,
                                            ob.Swab_Instrument,
                                            ob.ProcedureName,
                                            ob.Patient_Procedure,
                                            ob.OperationDate,
                                            ob.OperationTime,
                                            ob.DoctorName
                                          
                                        }).FirstOrDefault();
                

                if (operationBooking != null)
                {
                    hdfPatient_ID.Value = operationBooking.Patient_ID.ToString();
                    hdfPatoentNo.Value = operationBooking.Patient_No.ToString();
                    hdnFullName.Value = operationBooking.Full_Name.ToString();
                    txtPatient_ID.Text = operationBooking.Patient_ID.ToString();
                    txtOperation_Booking_ID.Text = operationBooking.Operation_Booking_ID.ToString();
                    vlblAdress.Text = operationBooking.Permanent_Address;
                    vlblAge_Year.Text = operationBooking.Age_years;
                    vlblContact.Text = operationBooking.Mobile1;
                    vlblEntry_Date.Text = operationBooking.Created_time.Value.ToString(AppConfig.DateFormat);
                    vlblGender.Text = db.GetDataValueName("Gender", operationBooking.Gender);
                    vlblPatient_Name.Text = operationBooking.Full_Name;
                    
                    txtDate_Operation.Text = operationBooking.Date.Value.ToString(AppConfig.DateFormat);
                    ddlSurgeon_Name.SelectedValue = operationBooking.Doctor_ID.ToString();

                   
                    ddlRelative_Approval.ClearSelection();
                    ddlRelative_Approval.Items.FindByValue(operationBooking.Relative_Approval.ToString().ToLower()).Selected = true;

                    if (operationBooking.Date_Of_Approval.ToString() != "")
                        txtDate_Of_Approval.Text = operationBooking.Date_Of_Approval.Value.ToString(AppConfig.DateFormat);
                    txtRelation_With_Patient.Text = operationBooking.Relation_With_Patient;

                    txtAssistant_Surgeon.Text = operationBooking.Assistant_Doctor.ToString();
                    txtSecondAssistant.Text = operationBooking.Second_Assistant_Doctor.ToString();
                    txtJuniorAssistantStaff.Text = operationBooking.Junior_Doctor.ToString();
                    txtAnesthetist.Text = operationBooking.Anesthetist1.ToString();
                    txtStaffNurse.Text = operationBooking.Nurse1.ToString();

                    

                    ddlOperationTherter.SelectedValue = operationBooking.Operation_Theater_No;
                    ddlDepartment.SelectedValue = operationBooking.Department.ToString();
                   
                    var Valuesetid = db.ValueSets.Where(x => x.ValueSet_Description.Contains("IPD Procedures")).FirstOrDefault().ValueSet_ID;
                    if (string.IsNullOrEmpty(operationBooking.ProcedureName) || operationBooking.ProcedureName == "0")
                    {
                        txtProcedure.Text = operationBooking.Patient_Procedure;
                    }
                    else
                    {
                        if (!string.IsNullOrEmpty(operationBooking.ProcedureName))
                        {
                            txtProcedure.Text = db.DataValues.DefaultIfEmpty()
                                                             .Where(w => w.ValueSet_ID == Valuesetid && w.DataValue_Name == operationBooking.ProcedureName)
                                                             .Select(w => w.DataValue_Description).FirstOrDefault();
                        }
                    }

                    

                    txtRecoveryDetails.Text = operationBooking.RecoveryDetails;
                  

                    txtTimeOfFinishOperation.Text = Convert.ToDateTime(operationBooking.TimeOfFinish_Operation).ToString("HH:mm:ss");
                    txtTimeOfStartOperation.Text = Convert.ToDateTime(operationBooking.TimeOfStart_Operation).ToString("HH:mm:ss");
                    txtOperationTime.Text = Convert.ToDateTime(operationBooking.OperationTime).ToString("HH:mm:ss");
                    if (operationBooking.OperationDate.ToString() != "")
                        txtOperationDate.Text = operationBooking.OperationDate.Value.ToString(AppConfig.DateFormat);

                    ddlProcedureNames.SelectedValue = operationBooking.ProcedureName.ToString();
                    ddlDoctors.SelectedValue = operationBooking.DoctorName.ToString();
                    txtOTHealth_Complaints.Text = operationBooking.Patient_Procedure;

                    OperationTheaterName = operationBooking.Operation_Theater_Name;
                    txtAssistantAnesthetist.Text = operationBooking.Anesthetist2;
                    txtProcedure_PO.Text = operationBooking.PO_Procedure;
                    txtFindings.Text = operationBooking.PO_Findings;
                    ddlDrain.SelectedValue = operationBooking.Drain;
                    ddlSutureUsed.SelectedValue = operationBooking.SutureUsed;
                    ddlImplant.SelectedValue = operationBooking.Implant;
                    ddlPO_Condition.SelectedValue = operationBooking.PO_Condition;
                    if (operationBooking.NPO_Yes != null)
                    {
                        rdbNpo_Yes.Checked = operationBooking.NPO_Yes.Value;
                    }
                    if (operationBooking.NPO_No != null)
                    {
                        rdbNpo_No.Checked = operationBooking.NPO_No.Value;
                    }

                    txtSpecialInstruction.Text = operationBooking.SpecialInstruction;
                    chk_Bloodloose.Checked = operationBooking.Est_Blood_Loose.Value;
                    chk_Bloodtrans.Checked = operationBooking.Intra_Operative_Fluid.Value;
                    chk_Urine.Checked = operationBooking.Intra_Operative_Urine.Value;
                    chk_Swab_Instrument.Checked = operationBooking.Swab_Instrument.Value;

                    txtOpN_Bed_Room_No.Text = operationBooking.OpN_Bed_Room_No;
                    txtOpN_Op_Date.Text = operationBooking.OpN_Op_Date == null ? "" : operationBooking.OpN_Op_Date.Value.ToString(AppConfig.DateFormat);
                    txtOpN_Op_Time.Text = operationBooking.OpN_Op_Time;
                    txtOpN_PreOp_Dx.Text = operationBooking.OpN_PreOp_Dx;
                    txtOpN_PostOp_Dx.Text = operationBooking.OpN_PostOp_Dx;
                    SelectOpNId(ddlOpN_Surgeon, operationBooking.OpN_Surgeon_ID);
                    txtOpN_Assistants.Text = operationBooking.OpN_Assistants;
                    SelectOpNId(ddlOpN_Anaesthetist, operationBooking.OpN_Anaesthetist_ID);
                    txtOpN_Type_Of_Anaesthesia.Text = operationBooking.OpN_Type_Of_Anaesthesia;
                    txtOpN_Procedure_Name.Text = operationBooking.OpN_Procedure_Name;
                    txtOpN_Duration.Text = operationBooking.OpN_Duration;
                    txtOpN_Thread_Catgut.Text = operationBooking.OpN_Thread_Catgut;
                    txtOpN_Thread_Vicryl.Text = operationBooking.OpN_Thread_Vicryl;
                    txtOpN_Thread_Proline.Text = operationBooking.OpN_Thread_Proline;
                    txtOpN_Thread_Silk.Text = operationBooking.OpN_Thread_Silk;
                    txtOpN_Procedure_Notes.Text = operationBooking.OpN_Procedure_Notes;
                    txtOpN_Blood_Loss.Text = operationBooking.OpN_Blood_Loss;
                    txtOpN_IV_Fluids.Text = operationBooking.OpN_IV_Fluids;
                    txtOpN_Blood_Transfused.Text = operationBooking.OpN_Blood_Transfused;
                    txtOpN_Urine_Output.Text = operationBooking.OpN_Urine_Output;
                    txtOpN_Swab_Instrument_Count.Text = operationBooking.OpN_Swab_Instrument_Count;
                    SelectOpNId(ddlOpN_Scrub_Nurse, operationBooking.OpN_Scrub_Nurse_ID);


                    

                    btnSave.Text = "Update";
                }
            }
            catch (Exception ex)
            {
                lblMessage.CssClass = "errorMessage";
                lblMessage.Text = ex.Message;
            }
        }

     


        protected void btnClearService_Click(object sender, EventArgs e)
        {
            ClearService();
        }

      

        public void ClearPatientDetail()
        {
            vlblAdress.Text = "";
            vlblAge_Year.Text = "";
            vlblContact.Text = "";
            vlblEntry_Date.Text = "";
            vlblGender.Text = "";
            vlblPatient_Name.Text = "";
        }

        public class Detail
        {
            public string Name;
            public string Gender;
            public string Age;
            public string Mobile;
            public string Address;
            public string Entry_Date;
            public int Branch { get; set; }
        }

        [System.Web.Services.WebMethod]
        public static Detail GetDetail(string PatientID)
        {

            int Patien_No = Convert.ToInt32(PatientID);
            Detail pt = new Detail();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Reg_patient pat = new Reg_patient();

            pat = (from tbl in db.Reg_patients
                   where tbl.pat_id == Patien_No
                   select tbl).FirstOrDefault();
            if (pat != null)
            {

                pt.Name = pat.Full_Name;
                pt.Gender = pat.Gender;
                pt.Age = pat.Age_years.ToString();

                pt.Entry_Date = pat.Created_time.ToString();
                pt.Address = pat.Permanent_Address;
                pt.Mobile = pat.Mobile1;
                pt.Gender = db.GetDataValueName("Gender", pat.Gender);
               
                return pt;
            }
            else
                return pt;
        }

        [WebMethod]
        public static string SaveTransferDetails(string PreviousDepartment, string PreviousWard_Bed, string PreviousRoom_Bed, string referTo, string Ward_No, string Ward_BedNo, string Room_No, string Room_Type, string PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            In_Patient inpat = new In_Patient();
            string Status = string.Empty;
            string DeptId = string.Empty;
            try
            {

                string InPatient = DBClass.GetInPatientIdBy_PatientId(Convert.ToInt32(PatientID));

                string InPatientId = InPatient.Contains("row") ? "0": InPatient;

                if (referTo == "001")
                {
                    SaveWardInformation(PatientID, InPatientId, Ward_No, Ward_BedNo);

                    DeptId = db.Ward_Definitions.Where(w => w.Ward_ID == Convert.ToInt32(Ward_No)).Select(w => w.Department).FirstOrDefault();

                    inpat = db.In_Patients.Where(w => w.Patient_ID == Convert.ToInt32(PatientID) && w.In_Patient_ID == Convert.ToInt32(InPatientId)).FirstOrDefault();
                    if(inpat != null)
                    {
                        inpat.Department = DeptId;
                        inpat.Ward_ID = Convert.ToInt32(Ward_No);
                        inpat.Bed_No = Convert.ToInt32(Ward_BedNo);
                    }
                    
                    db.SubmitChanges();
                    Status = "Record Transfer Successfully !";
                }
                else if (referTo == "002")
                {
                    SaveRoomInformation(Convert.ToInt32(PatientID), Convert.ToInt32(InPatientId), Room_No, Room_Type);

                    inpat = db.In_Patients.Where(w => w.Patient_ID == Convert.ToInt32(PatientID) && w.In_Patient_ID == Convert.ToInt32(InPatientId)).FirstOrDefault();

                    inpat.Room_Type = Room_Type;
                    inpat.Room_ID = Convert.ToInt32(Room_No);
                    db.SubmitChanges();
                    Status = "Record Transfer Successfully !";
                }
            }
            catch (Exception ex)
            {
                Status = ex.Message;
                throw ex;
            }

            return Status;
        }


        public static string SaveWardInformation(string PatID, string InPatID, string ddlWard_No, string txtBed_No)
        {
            try
            {
                Ward_Allocation ward_aloct;
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                ward_aloct = (from tbl in db.Ward_Allocations
                              where tbl.InPatient_ID == (InPatID).ToString() && tbl.Patient_ID == Convert.ToInt32(PatID)
                              && (tbl.IsDischarge == false || tbl.IsDischarge == null)
                              select tbl).FirstOrDefault();

                if (ward_aloct != null)
                {
                    ward_aloct.IsDischarge = true;
                }
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

               
                ward_aloct.InPatient_ID = InPatID.ToString();
                ward_aloct.Patient_ID = Convert.ToInt32(PatID);
                ward_aloct.Ward_ID = Convert.ToInt32(ddlWard_No);
                ward_aloct.Bed_No_Assigned = Convert.ToInt32(txtBed_No);
                ward_aloct.IsDischarge = false;

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
               
            }
            catch (Exception ex)
            {
                throw;
            }
            return "";
        }
        [WebMethod]
        public static List<Result> Search(string SearchString)
        {

            string SearchSql = "";




            if (SearchString == "")
                SearchSql = "SELECT top 10 pat_id,isnull(mr_no_sequence,'')Patient_No,isnull(Full_Name,'')Full_Name,isnull(NIC,'')NIC,isnull(Mobile1,'') ContactNo,isnull(Father_Name,'')Father_Name FROM reg_patient where(1=1) and Patient_No<>0 and Patient_No is not null and isnull(isCancel,0)!=1 order by pat_id desc";
            else
                SearchSql = "SELECT top 10  pat_id,isnull(mr_no_sequence,'')Patient_No,isnull(Full_Name,'')Full_Name,isnull(NIC,'')NIC,isnull(Mobile1,'') ContactNo,isnull(Father_Name,'')Father_Name FROM reg_patient where(1=1) and Patient_No<>0 and Patient_No is not null and isnull(isCancel,0)!=1 and (LTRIM(RTRIM(patient_no)) like '%" + SearchString.Trim() + "%' or  LTRIM(RTRIM(full_name)) like '%" + SearchString.Trim() + "%' or LTRIM(RTRIM(mobile1))  like '%" + SearchString.Trim() + "%' or LTRIM(RTRIM(nic))  like '%" + SearchString.Trim() + "%') order by pat_id desc";



            DataTable dt = DBClass.getDataTable(SearchSql);

            List<Result> list = new List<Result>();

            foreach (DataRow dr in dt.Rows)
            {
                Result rslt = new Result()
                {
                    Patient_ID = dr[0] == DBNull.Value ? "" : (string)dr[0].ToString(),
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
        public class Result
        {
            public string Full_Name;
            public string NIC;
            public string Patient_ID;
            public string Age_years;
            public string Patient_No;
            public string Mobile1;
            public string Father_Name;

        }
        public static string SaveRoomInformation(int PatID, int InPatID, string ddlRoom_No, string txtRoom_Type)
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

        protected void ddlOperationTherter_SelectedIndexChanged(object sender, EventArgs e)
        {

            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "", "Combination();", true);
        }

        

        [WebMethod]
        public static string preparedPatients()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var Valuesetid = db.ValueSets.Where(x => x.ValueSet_Description.Contains("IPD Procedures")).FirstOrDefault().ValueSet_ID;

            var result = (from p in db.Reg_patients
                          join OB in db.Operation_Bookings on p.pat_id equals OB.Patient_ID  
                          select new
                          {
                              p.pat_id,
                              p.Patient_No,
                              p.Full_Name,
                              p.Age_years,
                              p.Gender,
                              DoctorName = db.HR_Employees.DefaultIfEmpty().Where(w => w.IsDoctor == true && w.Emp_ID == Convert.ToInt32(OB.DoctorName)).Select(w => w.Emp_Name).FirstOrDefault(),
                           
                              File_No = DBClass.getField("select ISNULL(ip.File_No, 0) from In_Patient ip where ip.Patient_ID = " + p.pat_id + "  and ip.Discharge = 0"),

                              In_Patient_ID = DBClass.getField("select ISNULL(ip.In_Patient_ID, 0) from In_Patient ip where ip.Patient_ID = " + p.pat_id + " and ip.Discharge = 0"),


                              ProcedureName = (OB.ProcedureName != null && OB.ProcedureName != "" && OB.ProcedureName != "0") ?
                                                             (db.DataValues.DefaultIfEmpty()
                                                             .Where(w => w.ValueSet_ID == Valuesetid && w.DataValue_Name == OB.ProcedureName)
                                                             .Select(w => w.DataValue_Description).FirstOrDefault())
                                                             : OB.Patient_Procedure,

                              PatientType = db.GetDataValueName("Patient Main Category", OB.Department),
                              OB.OperationStatus

                          }).ToList();

            return (new JavaScriptSerializer()).Serialize(result);

        }

     

        [WebMethod]
        public static string OT()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());


            List<Service_Definition> SrvcList = new List<Service_Definition>();
            SrvcList = (from tbl in db.Service_Definitions
                        join tbl2 in db.DataValues on tbl.Service_Type equals tbl2.DataValue_Name
                        join tbl3 in db.ValueSets on tbl2.ValueSet_ID equals tbl3.ValueSet_ID
                        where tbl2.DataValue_Description == "Operation Theater"
                        select tbl).ToList();

            var operations = db.ValueSets.Where(v => v.ValueSet_Name.StartsWith("Operation Theater")).ToList();

            return (new JavaScriptSerializer()).Serialize(operations);
        }
        [WebMethod]
        public static string Department()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var qry = from d in db.DataValues
                      join v in db.ValueSets on
                      d.ValueSet_ID equals v.ValueSet_ID
                      where v.ValueSet_Name.Equals("Patient Main Category")
                      select new { d.DataValue_Name, d.DataValue_Description };
            return (new JavaScriptSerializer()).Serialize(qry);
        }
        [WebMethod]
        public static string Surgeon()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var EmpList = (from tbl in db.HR_Employees
                           where tbl.IsDoctor == true
                           select tbl).ToList();
            return (new JavaScriptSerializer()).Serialize(EmpList);
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


    }
}