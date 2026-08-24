using CrystalDecisions.CrystalReports.Engine;
using CrystalDecisions.Shared;
using PMS.Modules.PatientManagement;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static PMS.InPatientsCase;

namespace PMS
{
    public partial class InPatientMonitoring : System.Web.UI.Page
    {
        DataTable dt;
        DataBaseDataContext db;
        string connectionString = ConfigurationManager.ConnectionStrings["ASPGLConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                db = new DataBaseDataContext(connectionString);
                blankform();
                BindingDropDown();
                txtDate.Text = DateTime.Now.ToString();
                if (Request.QueryString["PatientID"] != null)
                {
                    txtPatient_ID.Text = Request.QueryString["PatientID"].ToString();
                    hdfPatient_ID.Value = Request.QueryString["PatientID"].ToString();
                    txtInPatient_Mon_ID.Text = "";
                }
                if (Request.QueryString["ID"] != null)
                {
                    fill(Request.QueryString["ID"], "InPatient_Monitoring");
                    ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "", "GetMonDetail('" + Convert.ToInt32(Request.QueryString["ID"]) + "');", true);
                }
                if (Request.QueryString["InPatientID"] != null)
                {
                    PopulateInPatientDataForMonitoring(Convert.ToInt32(Request.QueryString["InPatientID"]));
                }
            }
            else
            {
                dt = Session["PatientMonitoring"] as DataTable;
                GRD.DataSource = dt;
                GRD.DataBind();
            }
        }

        void blankform()
        {
            txtPatient_ID.Text = "";
            txtInPatient_Mon_ID.Text = "(New)";
            vlblPatients_Name.Text = "";
            vLbl_Contact.Text = "";
            vLbl_Adress.Text = "";
            vLbl_Gender.Text = "";
            vLbl_Age.Text = "";
            vLbl_RegDate.Text = "";
            txtPulse_Min.Text = "";
            txtBP_mm_Hg.Text = "";
            txtTemp_C.Text = "";
            txtRespiration_Min.Text = "";
            txtSaturation.Text = "";
            txtWeight_Kg.Text = "";
            ddlMedicine_Type.SelectedIndex = 0;
            ddlMedicine_Name.SelectedIndex = 0;
            ddlNurse.SelectedIndex = 0;
            txtNo_Of_Item.Text = "";
            txtMedicine_Given_Date.Text = DateTime.Now.ToString(AppConfig.DateFormat);
            txtCharges.Text = "0";
            txtDescription.Text = "";
            dt = new DataTable();
            Session["PatientMonitoring"] = dt;
            DataColumn[] keys = new DataColumn[1];
            DataColumn index = new DataColumn("Index", Type.GetType("System.Int32"));
            DataColumn medicine_Type = new DataColumn("Medicine_Type", Type.GetType("System.String"));
            DataColumn medicine_Name = new DataColumn("Medicine_Name", Type.GetType("System.String"));
            DataColumn nurse = new DataColumn("Nurse", Type.GetType("System.String"));
            DataColumn no_Of_Item = new DataColumn("No_Of_Item", Type.GetType("System.String"));
            DataColumn medicine_Given_Date = new DataColumn("Medicine_Given_Date", Type.GetType("System.DateTime"));
            DataColumn description = new DataColumn("Description", Type.GetType("System.String"));
            DataColumn charges = new DataColumn("Charges", Type.GetType("System.String"));
            dt.Columns.Add(index);
            dt.Columns.Add(medicine_Type);
            dt.Columns.Add(medicine_Name);
            dt.Columns.Add(nurse);
            dt.Columns.Add(no_Of_Item);
            dt.Columns.Add(medicine_Given_Date);
            dt.Columns.Add(description);
            dt.Columns.Add(charges);
            keys[0] = index;
            dt.PrimaryKey = keys;
            GRD.DataSource = dt;
            GRD.DataBind();
            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "", "bindDate();", true);
        }

        public void Cleartxt()
        {
            ddlMedicine_Type.SelectedIndex = 0;
            ddlMedicine_Name.SelectedIndex = 0;
            ddlNurse.SelectedIndex = 0;
            txtNo_Of_Item.Text = "";
            txtMedicine_Given_Date.Text = DateTime.Now.ToString(AppConfig.DateFormat);
            txtCharges.Text = "0";
            txtDescription.Text = "";
        }

        public void fill(string id, string tblname)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

                var qry1 = (from InPtMon in db.InPatient_Monitorings
                            join pat in db.Reg_patients
                            on InPtMon.Patient_ID equals pat.pat_id
                            where InPtMon.InPatient_Mon_ID == Convert.ToInt32(id)
                            select new
                            {
                                InPtMon.Patient_ID,
                                InPtMon.InPatient_Mon_ID,
                                pat.Full_Name,
                                pat.Mobile1,
                                pat.Permanent_Address,
                                pat.Gender,
                                pat.Age_years,
                                pat.Created_time,
                                InPtMon.Nurse_Name_Nurse_Note,
                                //inptmi.Patient_Main_Category,
                                InPtMon.Nursing_Plan,

                                in_Patient = (from tbl in db.In_Patients
                                              where tbl.Patient_ID == Convert.ToInt32(InPtMon.Patient_ID)

                                              orderby tbl.Created_Time descending
                                              select tbl.In_Patient_ID).FirstOrDefault(),
                            }).FirstOrDefault();
                hdnInpatient_id.Value = qry1.in_Patient.ToString();
                txtPatient_ID.Text = qry1.Patient_ID.ToString();
                hdfPatient_ID.Value = qry1.Patient_ID.ToString();
                txtInPatient_Mon_ID.Text = qry1.InPatient_Mon_ID.ToString();
                vlblPatients_Name.Text = qry1.Full_Name;
                vLbl_Contact.Text = qry1.Mobile1;
                vLbl_Adress.Text = qry1.Permanent_Address;
                vLbl_Gender.Text = db.GetDataValueName("Gender", qry1.Gender);
                vLbl_Age.Text = qry1.Age_years;
                vLbl_RegDate.Text = qry1.Created_time.Value.ToString(AppConfig.DateFormat);
                if (qry1.Nursing_Plan != null)
                {
                    txt_Nursing_plan.Text = qry1.Nursing_Plan.Replace("<li>", "•").Trim().Replace("</li>", "").Trim();
                }
                if (qry1.Nurse_Name_Nurse_Note != null)
                {
                    txt_Nurse_Name_Nursing.Text = qry1.Nurse_Name_Nurse_Note.Replace("<li>", "•").Trim().Replace("</li>", "").Trim();

                }

                var inPatientData = (from ip in db.In_Patients
                                     join wd in db.Ward_Definitions on ip.Ward_ID equals wd.Ward_ID into wardJoin
                                     from ward in wardJoin.DefaultIfEmpty()
                                     where ip.In_Patient_ID == Convert.ToInt32(qry1.in_Patient)
                                     select new
                                     {
                                         WardName = ward != null ? ward.Ward_Type : "",
                                         BedNo = ip.Bed_No
                                     }).FirstOrDefault();

                if (inPatientData != null)
                {
                    vLbl_WardName.Text = inPatientData.WardName ?? "";
                    vLbl_BedNo.Text = inPatientData.BedNo != null ? inPatientData.BedNo.ToString() : "";
                }

            }
            catch (Exception ex)
            {
                lblMessage.CssClass = "errorMessage";
                lblMessage.Text = ex.Message;
            }

        }
        [WebMethod]
        public static string GetMonitringDetail(int id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                List<InPatient_Monitoring_Detail> inPatmedicineList = db.InPatient_Monitoring_Details.Where(p => p.InPatient_Mon_ID == id).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
            }
            return "";
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
                          }).ToList().Take(20);

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
        public static string LoadInTakeHistory(int id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatmedicineList = (from pm in db.InPatient_Mon_InTakes
                                         where pm.Patient_ID == id
                                         select new { pm.Intake_Date, pm.Qty, pm.Item, pm.Main_Item, Main_ItemName = db.GetDataValueName("Intake", pm.Main_Item) }).ToList();

                return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
            }
            return "";
        }
        [WebMethod]
        public static string GetInTakeDetail(int id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatmedicineList = (from pm in db.InPatient_Mon_InTakes
                                         where pm.InPatient_Mon_ID == id
                                         select new { pm.Intake_Date, pm.Qty, pm.Item, pm.Main_Item, Main_ItemName = db.GetDataValueName("Intake", pm.Main_Item) }).ToList();

                return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
            }
            return "";
        }

        [WebMethod]
        public static string GetOutputDetail(int id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                List<InPatient_Mon_Output> inPatOutput = db.InPatient_Mon_Outputs.Where(p => p.InPatient_Mon_ID == id).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatOutput);
            }
            return "";
        }
        [WebMethod]
        public static string GetProgressNotesDetail(int id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                List<InPatient_Mon_Progress_Note> inPatProgressNote = db.InPatient_Mon_Progress_Notes.Where(p => p.InPatient_Mon_ID == id).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatProgressNote);
            }
            return "";
        }
        [WebMethod]
        public static string LoadMedicines(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                List<In_Patient_Medicine> inPatmedicineList = db.In_Patient_Medicines.Where(p => p.Patient_ID == PatientID && p.Transaction_Type == "InPatientMonitring").OrderByDescending(p => p.In_Patient_Medicine_ID).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
            }
            return "";
        }
        [WebMethod]
        public static string LoadMonitertingForHistory(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatmedicineList = (from pm in db.InPatient_Monitoring_Details

                                         where pm.Patient_ID == PatientID

                                         select new { pm.Mon_Date, pm.Pulse_Min, pm.BP_mm_Hg, pm.Temp_C, pm.Respiration_Min, pm.Blood_Suger, pm.Weight_Kg, pm.Saturation, pm.With_Oxygen, pm.Room_Air, pm.Height_Cm, pm.BMI }).ToList();


                return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
            }
            return "";
        }

        [WebMethod]
        public static string LoadOutputHistory(int id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatmedicineList = (from pm in db.InPatient_Mon_Outputs
                                         where pm.Patient_ID == id
                                         select new { pm.Output_Date, pm.Urine, pm.Drain1, pm.Drain2, pm.Drain3, pm.Vomiting, pm.NG, pm.Stool, pm.Stoma, pm.Other }).ToList();

                return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
            }
            return "";
        }
        [WebMethod]
        public static string LoadProgressNoteHistory(int id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatmedicineList = (from pm in db.InPatient_Mon_Progress_Notes
                                         where pm.Patient_ID == id
                                         select new { pm.Progress_Notes_Date, pm.Nurse_Name, pm.Progress_Note, pm.Over_Instruction }).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
            }
            return "";
        }
        protected void btnAdd_Click(object sender, EventArgs e)
        {
            try
            {
                lblValidation.Text = "";

                Boolean bol = Convert.ToBoolean(ViewState["check"]);
                int Index = Convert.ToInt32(ViewState["Index"]);

                if (bol == true)
                {
                    bol = false;
                    DataRow[] row = dt.Select("Index = '" + Index + "'");
                    row[0]["Index"] = Index;
                    row[0]["Medicine_Type"] = ddlMedicine_Type.SelectedValue;
                    row[0]["Medicine_Name"] = ddlMedicine_Name.SelectedValue;
                    row[0]["Nurse"] = ddlNurse.SelectedValue;
                    row[0]["No_Of_Item"] = Convert.ToInt32(txtNo_Of_Item.Text);
                    row[0]["Medicine_Given_Date"] = txtMedicine_Given_Date.Text;
                    row[0]["Description"] = txtDescription.Text;
                    row[0]["Charges"] = txtCharges.Text;
                    ViewState.Remove("check");
                    ViewState.Add("check", bol);
                    btnAdd.Text = "Add";
                }
                else
                {
                    DataRow row = dt.NewRow();
                    string index;
                    index = Convert.ToString(dt.Compute("Max(Index)", ""));
                    if (index != "")
                        index = Convert.ToString(Convert.ToInt32(index) + 1);
                    else
                        index = "0";
                    row["Index"] = index;
                    row["Medicine_Type"] = ddlMedicine_Type.SelectedValue;
                    row["Medicine_Name"] = ddlMedicine_Name.SelectedValue;
                    row["Nurse"] = ddlNurse.SelectedValue;
                    row["No_Of_Item"] = Convert.ToInt32(txtNo_Of_Item.Text);
                    row["Medicine_Given_Date"] = txtMedicine_Given_Date.Text;
                    row["Description"] = txtDescription.Text;
                    row["Charges"] = txtCharges.Text;
                    dt.Rows.Add(row);
                }
                ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "", " bindDate();", true);
                GRD.DataSource = dt;
                GRD.DataBind();
                Cleartxt();
            }
            catch (Exception exc)
            {
                lblValidation.Text = exc.Message;
            }
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
        protected void GRD_SelectedIndexChanging(object sender, GridViewSelectEventArgs e)
        {

            Boolean bol = true;
            btnAdd.Text = "Update";
            ViewState.Remove("check");
            ViewState.Add("check", bol);
            Label lblIndex = (Label)GRD.Rows[e.NewSelectedIndex].FindControl("lblIndex");
            int Index = Convert.ToInt32(lblIndex.Text);
            ViewState.Add("Index", Index);
            DataRow[] row = dt.Select("Index = '" + Index + "'");
            string medicineType = Convert.ToString(row[0]["Medicine_Type"]);
            string medicineName = Convert.ToString(row[0]["Medicine_Name"]);
            string nurse = Convert.ToString(row[0]["Nurse"]);
            string noOfItem = Convert.ToString(row[0]["No_Of_Item"]);
            string medicineGivenDate = Convert.ToString(row[0]["Medicine_Given_Date"]);
            string charges = Convert.ToString(row[0]["Charges"]);
            string description = Convert.ToString(row[0]["Description"]);
            ddlMedicine_Type.SelectedValue = medicineType;
            ddlMedicine_Name.SelectedValue = medicineName;
            ddlNurse.SelectedValue = nurse;
            txtNo_Of_Item.Text = noOfItem;
            txtMedicine_Given_Date.Text = medicineGivenDate;
            txtDescription.Text = description;
            txtCharges.Text = charges;
            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "", " bindDate();", true);
            e.NewSelectedIndex = -1;
            e.Cancel = true;
            upInPatForm.Update();
        }
        [WebMethod]
        public static string checkRepeat(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatROomsList = (from ipm in db.InPatient_Monitorings

                                      where ipm.Patient_ID == PatientID && ipm.Dischage_ID ==
                                      "0"
                                      select new
                                      {
                                          ipm.InPatient_Mon_ID,
                                      }).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatROomsList);
            }
            return "";
        }

        [WebMethod]
        public static string CountQty(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatROomsList = (from ipm in db.InPatient_Mon_InTakes

                                      where ipm.Patient_ID == PatientID

                                      select new
                                      {
                                          ipm.Qty,
                                      }).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatROomsList);
            }
            return "";
        }
        [WebMethod]
        public static string CountQtyOutput(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatROomsList = (from ipm in db.InPatient_Mon_Outputs

                                      where ipm.Patient_ID == PatientID && Convert.ToDateTime(ipm.Output_Date).Month == DateTime.Now.Month && Convert.ToDateTime(ipm.Output_Date).Year == DateTime.Now.Year && Convert.ToDateTime(ipm.Output_Date).Day == DateTime.Now.Day
                                      group ipm by new
                                      {
                                          ipm.Urine,
                                          ipm.Drain1,
                                          ipm.Drain2,
                                          ipm.Drain3,
                                          ipm.NG,
                                          ipm.Stool,
                                          ipm.Vomiting,
                                          ipm.Other
                                      } into g
                                      select new
                                      {

                                          Qty = g.Sum(x => Convert.ToDouble(x.Urine) + Convert.ToDouble(x.Drain1) + Convert.ToDouble(x.Drain2) +
                                              Convert.ToDouble(x.Drain3) + Convert.ToDouble(x.NG) + Convert.ToDouble(x.Stool) + Convert.ToDouble(x.Vomiting) +
                                              Convert.ToDouble(x.Other))
                                      }).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatROomsList);
            }
            return "";
        }
        [WebMethod]
        public static string CountPerQty(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatROomsList = (from ipm in db.InPatient_Mon_InTakes

                                      where ipm.Patient_ID == PatientID && Convert.ToDateTime(ipm.Intake_Date).Month == DateTime.Now.Month && Convert.ToDateTime(ipm.Intake_Date).Year == DateTime.Now.Year && Convert.ToDateTime(ipm.Intake_Date).Day == DateTime.Now.Day

                                      select new
                                      {
                                          ipm.Qty,
                                      }).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatROomsList);
            }
            return "";
        }

        [WebMethod]
        public static string CountPerQtyOutput(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatROomsList = (from ipm in db.InPatient_Mon_Outputs

                                      where ipm.Patient_ID == PatientID && Convert.ToDateTime(ipm.Output_Date).Month == DateTime.Now.Month && Convert.ToDateTime(ipm.Output_Date).Year == DateTime.Now.Year && Convert.ToDateTime(ipm.Output_Date).Day == DateTime.Now.Day
                                      group ipm by new
                                      {
                                          ipm.Urine,
                                          ipm.Drain1,
                                          ipm.Drain2,
                                          ipm.Drain3,
                                          ipm.NG,
                                          ipm.Stool,
                                          ipm.Vomiting,
                                          ipm.Other
                                      } into g
                                      select new
                                      {

                                          Qty = g.Sum(x => Convert.ToDouble(x.Urine) + Convert.ToDouble(x.Drain1) + Convert.ToDouble(x.Drain2) +
                                              Convert.ToDouble(x.Drain3) + Convert.ToDouble(x.NG) + Convert.ToDouble(x.Stool) + Convert.ToDouble(x.Vomiting) +
                                              Convert.ToDouble(x.Other))
                                      }).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatROomsList);
            }
            return "";
        }
        [WebMethod]
        public static string LoadMedicinesForHistory(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatmedicineList = (from pm in db.In_Patient_Medicines
                                         join op in db.In_Patients
                                         on pm.Patient_ID equals op.In_Patient_ID
                                         where op.Patient_ID == PatientID && pm.Transaction_Type == "InPatient"
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
                                             DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(pm.Doctor_ID) select d.Emp_Name).FirstOrDefault(),
                                             pm.Dosage_From,
                                             pm.Dosage_Qty,
                                             pm.Other_Instruction,
                                             pm.Regular,
                                             pm.STAT,
                                             pm.PRN,
                                             pm.Req_Qty,
                                             pm.Rcv_Qty,
                                             pm.Stop_Date_Time,

                                         }).ToList();

                return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
            }
            return "";
        }

        [WebMethod]
        public static string LoadMedicinesForHistory1(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatmedicineList = (from pm in db.In_Patient_Medicines
                                         join op in db.In_Patients
                                         on pm.Patient_ID equals op.In_Patient_ID
                                         where op.Patient_ID == PatientID && pm.Transaction_Type == "InPatient"
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
                                             DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(pm.Doctor_ID) select d.Emp_Name).FirstOrDefault(),
                                             pm.Dosage_From,
                                             pm.Dosage_Qty,
                                             pm.Other_Instruction,
                                             pm.Regular,
                                             pm.STAT,
                                             pm.PRN,

                                         }).ToList();

                return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
            }
            return "";
        }

        [WebMethod]
        public static int SavePatientMonitiring(string btnsave, string In_Mon_ID, string Nursing_Plan, string PatID, string Nurse_Name_N)
        {
            InPatient_Monitoring ipm;
            int inPatMonID;
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            if (btnsave == "Save")
            {
                #region "New Entry"
                ipm = new InPatient_Monitoring();

                ipm.Patient_ID = Convert.ToInt32(PatID);
                ipm.Created_By = AppConfig.UserID;
                ipm.Created_Time = DateTime.Now;
                ipm.Company_ID = AppConfig.Company_ID;
                ipm.Book_ID = AppConfig.Book_ID;
                ipm.Nursing_Plan = Nursing_Plan;
                ipm.Nurse_Name_Nurse_Note = Nurse_Name_N;
                ipm.Dischage_ID = "0";

                db.InPatient_Monitorings.InsertOnSubmit(ipm);
                db.SubmitChanges();
                inPatMonID = ipm.InPatient_Mon_ID;

                #endregion
            }
            else
            {
                #region "Edit Entry"
                inPatMonID = Convert.ToInt32(In_Mon_ID);
                ipm = new InPatient_Monitoring();

                ipm = (from tbl in db.InPatient_Monitorings
                       where tbl.InPatient_Mon_ID == Convert.ToInt32(In_Mon_ID)
                       select tbl).FirstOrDefault();


                ipm.Patient_ID = Convert.ToInt32(PatID);
                ipm.Updated_By = AppConfig.UserID;
                ipm.Updated_Time = DateTime.Now;
                ipm.Nursing_Plan = Nursing_Plan;
                ipm.Nurse_Name_Nurse_Note = Nurse_Name_N;
                db.SubmitChanges();
                #endregion
            }
            int InPatientMonID = Convert.ToInt32(ipm.InPatient_Mon_ID);
            List<InPatient_Monitoring_Detail> list = db.InPatient_Monitoring_Details.Where(p => p.InPatient_Mon_ID == 0).ToList();
            foreach (InPatient_Monitoring_Detail med in list)
            {
                med.InPatient_Mon_ID = InPatientMonID;
                db.SubmitChanges();
            }

            List<InPatient_Mon_Output> listOutput = db.InPatient_Mon_Outputs.Where(p => p.InPatient_Mon_ID == 0).ToList();
            foreach (InPatient_Mon_Output med in listOutput)
            {
                med.InPatient_Mon_ID = InPatientMonID;
                db.SubmitChanges();
            }

            List<InPatient_Mon_Progress_Note> listNote = db.InPatient_Mon_Progress_Notes.Where(p => p.InPatient_Mon_ID == 0).ToList();
            foreach (InPatient_Mon_Progress_Note med in listNote)
            {
                med.InPatient_Mon_ID = InPatientMonID;
                db.SubmitChanges();
            }

            List<InPatient_Mon_InTake> listIntak = db.InPatient_Mon_InTakes.Where(p => p.InPatient_Mon_ID == 0).ToList();
            foreach (InPatient_Mon_InTake med in listIntak)
            {
                med.InPatient_Mon_ID = InPatientMonID;
                db.SubmitChanges();
            }
            /***********Update temporary medicines (Patient_ID == 0) to current In patient id - NO DELETION ****************/
            // Update temporary inpatient medicines
            // Update temporary medicines - ONLY change Patient_ID, NOTHING ELSE
            var tempMedicines = db.In_Patient_Medicines
                .Where(p => p.Patient_ID == 0 && p.Transaction_Type == "InPatientMonitring")
                .ToList();

            foreach (In_Patient_Medicine med in tempMedicines)
            {
                med.Patient_ID = InPatientMonID;  // ONLY THIS - NO DELETE
            }



            db.SubmitChanges();
            var InPatient = (from tbl in db.In_Patients
                             where tbl.Patient_ID == Convert.ToInt32(PatID) && tbl.Discharge != true
                             select tbl).FirstOrDefault();
            if (InPatient == null)
            {
                ipm.Dischage_ID = "1";
                db.SubmitChanges();
            }

            return InPatientMonID;
        }

        public class Monitering
        {
            public int Nursing_Plan { get; set; }
            public int InPatient_Mon_ID { get; set; }
            public int Patient_ID { get; set; }
            public List<MoniteringDetails> MonList { get; set; }
        }
        public class MoniteringDetails
        {
            public DateTime Date { get; set; }
            public string Pulse_Min { get; set; }
            public string BP_mm_Hg { get; set; }
            public string Temp_C { get; set; }
            public string Respiration_Min { get; set; }
            public string Weight_Kg { set; get; }
            public string Blood_Suger { set; get; }
            public string Height { set; get; }
            public string BMI { set; get; }
            public string Saturation { set; get; }
            public string Room_Air { set; get; }

            public string With_Oxygen { set; get; }

        }
        [WebMethod]
        public static string SavePatientMonitiringDetail(string btnsave, string MonDetails)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var MoniteringDetail = js.Deserialize<Monitering>(MonDetails);
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                //{
                /********************Deleting Previous 0 Value Saved Rows.***********************************/
                if (btnsave == "Update")
                {
                    List<InPatient_Monitoring_Detail> InPatient_Doctor_Note = db.InPatient_Monitoring_Details.Where(i => i.InPatient_Mon_ID == MoniteringDetail.InPatient_Mon_ID).ToList();
                    db.InPatient_Monitoring_Details.DeleteAllOnSubmit(InPatient_Doctor_Note);
                    db.SubmitChanges();
                }

                /*********************Inserting New Entry On Every Insert Or Update*************************/

                foreach (var test in MoniteringDetail.MonList)
                {
                    InPatient_Monitoring_Detail oInPatient_MoniteringDetail = new InPatient_Monitoring_Detail();
                    oInPatient_MoniteringDetail.InPatient_Mon_ID = MoniteringDetail.InPatient_Mon_ID;
                    oInPatient_MoniteringDetail.Patient_ID = MoniteringDetail.Patient_ID;
                    oInPatient_MoniteringDetail.Pulse_Min = test.Pulse_Min;
                    oInPatient_MoniteringDetail.BP_mm_Hg = test.BP_mm_Hg;
                    oInPatient_MoniteringDetail.Temp_C = test.Temp_C;
                    oInPatient_MoniteringDetail.Respiration_Min = test.Respiration_Min;
                    oInPatient_MoniteringDetail.Blood_Suger = test.Blood_Suger;
                    oInPatient_MoniteringDetail.Weight_Kg = test.Weight_Kg;
                    oInPatient_MoniteringDetail.Height_Cm = test.Height;
                    oInPatient_MoniteringDetail.BMI = test.BMI;
                    oInPatient_MoniteringDetail.Saturation = test.Saturation;

                    oInPatient_MoniteringDetail.Room_Air = test.Room_Air;

                    oInPatient_MoniteringDetail.With_Oxygen = test.With_Oxygen;
                    oInPatient_MoniteringDetail.Mon_Date = test.Date;

                    db.InPatient_Monitoring_Details.InsertOnSubmit(oInPatient_MoniteringDetail);
                    db.SubmitChanges();
                }
            }
            catch (Exception ex)
            {

            }

            return "";
        }

        public class IntakeList
        {
            public int InPatient_Mon_ID { get; set; }
            public int Patient_ID { get; set; }
            public List<IntakeListDetails> IntakeListt { get; set; }
        }
        public class IntakeListDetails
        {
            public DateTime IntakeDate { get; set; }
            public string Item { get; set; }
            public string Qty { get; set; }
            public string Intake { get; set; }
            public string Main_Item { get; set; }
        }

        [WebMethod]
        public static string SaveIntakeDetail(string btnsave, string IntakeList)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var IntakeListDetail = js.Deserialize<IntakeList>(IntakeList);
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                /********************Deleting Previous 0 Value Saved Rows.***********************************/
                if (btnsave == "Update")
                {
                    List<InPatient_Mon_InTake> InPatient_Mon_InTake = db.InPatient_Mon_InTakes.Where(i => i.InPatient_Mon_ID == IntakeListDetail.InPatient_Mon_ID).ToList();
                    db.InPatient_Mon_InTakes.DeleteAllOnSubmit(InPatient_Mon_InTake);
                    db.SubmitChanges();
                }
                /*********************Inserting New Entry On Every Insert Or Update*************************/

                foreach (var test in IntakeListDetail.IntakeListt)
                {
                    InPatient_Mon_InTake oInPatient__Mon_InTake = new InPatient_Mon_InTake();

                    oInPatient__Mon_InTake.InPatient_Mon_ID = IntakeListDetail.InPatient_Mon_ID;
                    oInPatient__Mon_InTake.Patient_ID = IntakeListDetail.Patient_ID;
                    oInPatient__Mon_InTake.Item = test.Item;
                    oInPatient__Mon_InTake.Qty = test.Qty;
                    oInPatient__Mon_InTake.Intake_Date = test.IntakeDate;
                    oInPatient__Mon_InTake.Main_Item = test.Main_Item;
                    db.InPatient_Mon_InTakes.InsertOnSubmit(oInPatient__Mon_InTake);
                    db.SubmitChanges();
                }
            }
            catch (Exception ex)
            {

            }

            return "";
        }
        public class OutputList
        {
            public int InPatient_Mon_ID { get; set; }
            public int Patient_ID { get; set; }
            public List<OutputListDetails> OutputListt { get; set; }
        }
        public class OutputListDetails
        {
            public DateTime Date { get; set; }
            public string Urine { get; set; }
            public string Drain1 { get; set; }
            public string Drain2 { get; set; }
            public string Drain3 { get; set; }
            public string NG { get; set; }
            public string Stool { get; set; }
            public string Vomiting { get; set; }
            public string Stoma { get; set; }
            public string Other { get; set; }

        }
        [WebMethod]
        public static string SaveOutputDetail(string btnsave, string OutputDetails)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var OutputListDetail = js.Deserialize<OutputList>(OutputDetails);
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                /********************Deleting Previous 0 Value Saved Rows.***********************************/
                if (btnsave == "Update")
                {
                    List<InPatient_Mon_Output> InPatient_Mon_Output = db.InPatient_Mon_Outputs.Where(i => i.InPatient_Mon_ID == OutputListDetail.InPatient_Mon_ID).ToList();
                    db.InPatient_Mon_Outputs.DeleteAllOnSubmit(InPatient_Mon_Output);
                    db.SubmitChanges();
                }

                /*********************Inserting New Entry On Every Insert Or Update*************************/

                foreach (var test in OutputListDetail.OutputListt)
                {
                    InPatient_Mon_Output oInPatient_Mon_Output = new InPatient_Mon_Output();

                    oInPatient_Mon_Output.InPatient_Mon_ID = OutputListDetail.InPatient_Mon_ID;
                    oInPatient_Mon_Output.Patient_ID = OutputListDetail.Patient_ID;
                    oInPatient_Mon_Output.Urine = test.Urine;
                    oInPatient_Mon_Output.Drain1 = test.Drain1;
                    oInPatient_Mon_Output.Drain2 = test.Drain2;

                    oInPatient_Mon_Output.Drain3 = test.Drain3;
                    oInPatient_Mon_Output.NG = test.NG;
                    oInPatient_Mon_Output.Stool = test.Stool;
                    oInPatient_Mon_Output.Vomiting = test.Vomiting;
                    oInPatient_Mon_Output.Stoma = test.Stoma;
                    oInPatient_Mon_Output.Other = test.Other;
                    oInPatient_Mon_Output.Output_Date = test.Date;
                    db.InPatient_Mon_Outputs.InsertOnSubmit(oInPatient_Mon_Output);
                    db.SubmitChanges();
                }
            }
            catch (Exception ex)
            {

            }
            return "";
        }

        public class ProgressNotesList
        {
            public int InPatient_Mon_ID { get; set; }
            public int Patient_ID { get; set; }
            public List<ProgressNotesListDetails> ProgressNotesListt { get; set; }
        }
        public class ProgressNotesListDetails
        {
            public DateTime Date { get; set; }
            public string ProgressNote { get; set; }
            public string NurseName { get; set; }
            public string OverInstruction { get; set; }
        }

        [WebMethod]
        public static string SaveProgressNotesDetail(string btnsave, string ProgressNotesListDetails)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var Progress_NoteListDetail = js.Deserialize<ProgressNotesList>(ProgressNotesListDetails);
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                /********************Deleting Previous 0 Value Saved Rows.***********************************/
                if (btnsave == "Update")
                {
                    List<InPatient_Mon_Progress_Note> InPatient_MonProgress_Note = db.InPatient_Mon_Progress_Notes.Where(i => i.InPatient_Mon_ID == Progress_NoteListDetail.InPatient_Mon_ID).ToList();
                    db.InPatient_Mon_Progress_Notes.DeleteAllOnSubmit(InPatient_MonProgress_Note);
                    db.SubmitChanges();
                }
                /*********************Inserting New Entry On Every Insert Or Update*************************/

                foreach (var test in Progress_NoteListDetail.ProgressNotesListt)
                {
                    InPatient_Mon_Progress_Note oInPatient_ProgressNotesList = new InPatient_Mon_Progress_Note();

                    oInPatient_ProgressNotesList.InPatient_Mon_ID = Progress_NoteListDetail.InPatient_Mon_ID;
                    oInPatient_ProgressNotesList.Patient_ID = Progress_NoteListDetail.Patient_ID;
                    oInPatient_ProgressNotesList.Nurse_Name = test.NurseName;
                    oInPatient_ProgressNotesList.Over_Instruction = test.OverInstruction;
                    oInPatient_ProgressNotesList.Progress_Note = test.ProgressNote;
                    oInPatient_ProgressNotesList.Progress_Notes_Date = test.Date;
                    db.InPatient_Mon_Progress_Notes.InsertOnSubmit(oInPatient_ProgressNotesList);
                    db.SubmitChanges();
                }
            }
            catch (Exception ex)
            {

            }
            return "";
        }

        public class Medicine
        {
            public int PatientID { get; set; }

            public int ActualPatientID { get; set; }
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
            public string Rec_Qty;
            public string Rtn_Qty;
            public string Issue_Qty;

            public string Regular;

            public string STAT;

            public string PRN;

            public string Start_Date_Time { get; set; }

            public string Stop_Date_Time { get; set; }

            public string High_Risk { get; set; }

            public string Max_PRN { get; set; }
            public string Nurse_Name { get; set; }
            public string chkDiccharge { get; set; }

            public string User { get; set; }
        }
        [WebMethod]
        public static string LoadMedicinesForMon(int PatientID)
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
                                         inPatmedicineList.Rcv_Qty,
                                         inPatmedicineList.Req_Qty,
                                         inPatmedicineList.Rtn_Qty,
                                         inPatmedicineList.Username,
                                         inPatmedicineList.Max_PRN_Dose,
                                         inPatmedicineList.Start_Date_Time,
                                         inPatmedicineList.Stop_Date_Time,
                                         inPatmedicineList.High_Risk_Drug,

                                         DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(inPatmedicineList.Doctor_ID) select d.Emp_Name).FirstOrDefault(),

                                         AllowMedicationEdit = allowMedicationEdit





                                     }
                    ).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatmedicine);
            }
        }
        [WebMethod]
        public static string LoadMedicinesFormInPat(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var ups = (from St in db.aspnet_Users
                           where St.UserId == AppConfig.UserID
                           select St.Allow_Medication_Edit).FirstOrDefault();

                bool allowMedicationEdit = ups == true;

                var In_pat = (from ip in db.In_Patients
                              where ip.Patient_ID == PatientID
                              orderby ip.In_Patient_ID descending
                              select ip.In_Patient_ID).FirstOrDefault();

                var inPatmedicine = (from inPatmedicineList in db.In_Patient_Medicines
                                     where inPatmedicineList.Patient_ID == In_pat && inPatmedicineList.Transaction_Type == "InPatient"
                                     orderby inPatmedicineList.Medicine_Date descending
                                     select new
                                     {
                                         inPatmedicineList.Doctor_ID,
                                         inPatmedicineList.Frequency,
                                         inPatmedicineList.Item_Code,
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
                                         inPatmedicineList.Rcv_Qty,
                                         inPatmedicineList.Req_Qty,
                                         inPatmedicineList.Rtn_Qty,
                                         inPatmedicineList.Username,
                                         inPatmedicineList.Max_PRN_Dose,
                                         inPatmedicineList.Start_Date_Time,
                                         inPatmedicineList.Stop_Date_Time,
                                         inPatmedicineList.High_Risk_Drug,

                                         DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(inPatmedicineList.Doctor_ID) select d.Emp_Name).FirstOrDefault(),

                                         AllowMedicationEdit = allowMedicationEdit





                                     }
                    ).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatmedicine);
            }
        }
        [WebMethod]
        public static string SaveMedicinesforMon(string MedicineDetails)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var MedicineDetail = js.Deserialize<Medicine>(MedicineDetails);
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    int targetPatientId = 0;

                    if (MedicineDetail.PatientID > 0)
                    {
                        var In_pat = (from ip in db.In_Patients
                                      join ipm in db.InPatient_Monitorings on ip.Patient_ID equals ipm.Patient_ID
                                      where ipm.InPatient_Mon_ID == MedicineDetail.PatientID
                                      orderby ip.In_Patient_ID descending
                                      select ip.In_Patient_ID).FirstOrDefault();
                        targetPatientId = In_pat;
                    }
                    else
                    {
                        var latestInPatient = (from ip in db.In_Patients
                                               where ip.Patient_ID == MedicineDetail.ActualPatientID
                                               orderby ip.In_Patient_ID descending
                                               select ip.In_Patient_ID).FirstOrDefault();
                        targetPatientId = latestInPatient;
                    }

                    if (targetPatientId > 0)
                    {
                        var existingMedicines = db.In_Patient_Medicines
                            .Where(p => p.Patient_ID == targetPatientId && p.Transaction_Type == "InPatient")
                            .ToList();

                        System.Diagnostics.Debug.WriteLine("=== SaveMedicinesforMon Debug ===");
                        System.Diagnostics.Debug.WriteLine("Target Patient ID: " + targetPatientId);
                        System.Diagnostics.Debug.WriteLine("Transaction Type: InPatient");
                        System.Diagnostics.Debug.WriteLine("Existing medicines count: " + existingMedicines.Count);

                        int insertedCount = 0;
                        int updatedCount = 0;

                        foreach (MedicineDetails oIn_Patient_Medicine in MedicineDetail.MedicineList)
                        {
                            string medicineName = oIn_Patient_Medicine.Medicine_Name?.Trim() ?? "";
                            if (string.IsNullOrEmpty(medicineName)) continue;
                            var existingMedicine = existingMedicines
                                .FirstOrDefault(p => p.Medicine_Name.Trim() == medicineName);



                            if (existingMedicine != null)
                            {
                                bool hasChanges = false;
                                if (existingMedicine.Frequency != oIn_Patient_Medicine.Frequency) hasChanges = true;
                                else if (existingMedicine.Injections != oIn_Patient_Medicine.Injection) hasChanges = true;
                                else if (existingMedicine.Oral != oIn_Patient_Medicine.Oral) hasChanges = true;
                                else if (existingMedicine.Dosage_From != oIn_Patient_Medicine.Dosage_From) hasChanges = true;
                                else if (existingMedicine.Dosage_Qty != oIn_Patient_Medicine.Dosage_Qty) hasChanges = true;
                                else if (existingMedicine.Other_Instruction != oIn_Patient_Medicine.Other_Instruction) hasChanges = true;
                                else if (existingMedicine.AttendingParamedical_Staff != oIn_Patient_Medicine.AttendingParamedical_Staff) hasChanges = true;
                                else if (existingMedicine.Req_Qty != Convert.ToDecimal(oIn_Patient_Medicine.Issue_Qty)) hasChanges = true;
                                else if (existingMedicine.Rcv_Qty != Convert.ToDecimal(oIn_Patient_Medicine.Rec_Qty)) hasChanges = true;
                                else if (existingMedicine.Rtn_Qty != Convert.ToDecimal(oIn_Patient_Medicine.Rtn_Qty)) hasChanges = true;
                                else if (existingMedicine.Regular != Convert.ToBoolean(oIn_Patient_Medicine.Regular)) hasChanges = true;
                                else if (existingMedicine.STAT != Convert.ToBoolean(oIn_Patient_Medicine.STAT)) hasChanges = true;
                                else if (existingMedicine.PRN != Convert.ToBoolean(oIn_Patient_Medicine.PRN)) hasChanges = true;

                                if (hasChanges)
                                {
                                    System.Diagnostics.Debug.WriteLine("UPDATING inpatient medicine: " + medicineName);

                                    existingMedicine.Frequency = oIn_Patient_Medicine.Frequency;
                                    existingMedicine.Injections = oIn_Patient_Medicine.Injection;
                                    existingMedicine.Oral = oIn_Patient_Medicine.Oral;
                                    existingMedicine.Dosage_From = oIn_Patient_Medicine.Dosage_From;
                                    existingMedicine.Dosage_Qty = oIn_Patient_Medicine.Dosage_Qty;
                                    existingMedicine.Other_Instruction = oIn_Patient_Medicine.Other_Instruction;
                                    existingMedicine.AttendingParamedical_Staff = oIn_Patient_Medicine.AttendingParamedical_Staff;
                                    existingMedicine.Req_Qty = Convert.ToDecimal(oIn_Patient_Medicine.Issue_Qty);
                                    existingMedicine.Rcv_Qty = Convert.ToDecimal(oIn_Patient_Medicine.Rec_Qty);
                                    existingMedicine.Rtn_Qty = Convert.ToDecimal(oIn_Patient_Medicine.Rtn_Qty);
                                    existingMedicine.Regular = Convert.ToBoolean(oIn_Patient_Medicine.Regular);
                                    existingMedicine.STAT = Convert.ToBoolean(oIn_Patient_Medicine.STAT);
                                    existingMedicine.PRN = Convert.ToBoolean(oIn_Patient_Medicine.PRN);
                                    existingMedicine.Username = oIn_Patient_Medicine.User ?? AppConfig.UserName;
                                    existingMedicine.High_Risk_Drug = oIn_Patient_Medicine.High_Risk;
                                    existingMedicine.Max_PRN_Dose = oIn_Patient_Medicine.Max_PRN;

                                    if (!string.IsNullOrEmpty(oIn_Patient_Medicine.Start_Date_Time) &&
                                        oIn_Patient_Medicine.Start_Date_Time != "null" &&
                                        oIn_Patient_Medicine.Start_Date_Time != "1/1/0001")
                                    {
                                        DateTime startDate;
                                        if (DateTime.TryParse(oIn_Patient_Medicine.Start_Date_Time, out startDate) && startDate > DateTime.MinValue)
                                        {
                                            existingMedicine.Start_Date_Time = startDate;
                                        }
                                    }

                                    if (!string.IsNullOrEmpty(oIn_Patient_Medicine.Stop_Date_Time) &&
                                        oIn_Patient_Medicine.Stop_Date_Time != "null")
                                    {
                                        DateTime stopDateTime;
                                        if (DateTime.TryParse(oIn_Patient_Medicine.Stop_Date_Time, out stopDateTime))
                                        {
                                            existingMedicine.Stop_Date_Time = stopDateTime;
                                        }
                                    }

                                    updatedCount++;
                                }
                                else
                                {
                                    System.Diagnostics.Debug.WriteLine("SKIPPING (no changes) inpatient medicine: " + medicineName);
                                }
                            }
                            else
                            {
                                System.Diagnostics.Debug.WriteLine("INSERTING new inpatient medicine: " + medicineName);

                                //var inventoryItem = db.INV_Items
                                //    .Where(p => p.Item_Code == oIn_Patient_Medicine.ItemCode || p.Description == medicineName)
                                //    .FirstOrDefault();

                                //string itemId = inventoryItem != null ? inventoryItem.Item_ID.ToString() : oIn_Patient_Medicine.ItemCode;

                                string Item_Id;
                                if (oIn_Patient_Medicine.ItemCode == "0")
                                {
                                    int Item_Ids = (from inv in db.INV_Items where inv.Description == medicineName && inv.Is_Active == true && (inv.isCancel == null || inv.isCancel == false) select inv.Item_ID).FirstOrDefault();
                                    Item_Id = Convert.ToString(Item_Ids);
                                }
                                else
                                {
                                    Item_Id = oIn_Patient_Medicine.ItemCode;
                                }


                                In_Patient_Medicine oIn_Patient_Medicine1 = new In_Patient_Medicine
                                {
                                    Patient_ID = targetPatientId,
                                    Item_Code = Item_Id,
                                    Medicine_Name = medicineName,
                                    Transaction_Type = "InPatient",
                                    Medicine_Date = oIn_Patient_Medicine.Medicine_Date,
                                    Oral = oIn_Patient_Medicine.Oral,
                                    Injections = oIn_Patient_Medicine.Injection,
                                    Dosage_From = oIn_Patient_Medicine.Dosage_From,
                                    AttendingParamedical_Staff = oIn_Patient_Medicine.AttendingParamedical_Staff,
                                    Frequency = oIn_Patient_Medicine.Frequency,
                                    Dosage_Qty = oIn_Patient_Medicine.Dosage_Qty,
                                    Rtn_Qty = Convert.ToDecimal(oIn_Patient_Medicine.Rtn_Qty),
                                    Rcv_Qty = Convert.ToDecimal(oIn_Patient_Medicine.Rec_Qty),
                                    Req_Qty = Convert.ToDecimal(oIn_Patient_Medicine.Issue_Qty),
                                    Other_Instruction = oIn_Patient_Medicine.Other_Instruction,
                                    Regular = Convert.ToBoolean(oIn_Patient_Medicine.Regular),
                                    STAT = Convert.ToBoolean(oIn_Patient_Medicine.STAT),
                                    PRN = Convert.ToBoolean(oIn_Patient_Medicine.PRN),
                                    chkDiccharge = false,
                                    Username = oIn_Patient_Medicine.User ?? AppConfig.UserName,
                                    High_Risk_Drug = oIn_Patient_Medicine.High_Risk,
                                    Max_PRN_Dose = oIn_Patient_Medicine.Max_PRN,
                                    is_rejected = false,
                                    Status = null
                                };

                                if (!string.IsNullOrEmpty(oIn_Patient_Medicine.Start_Date_Time) &&
                                    oIn_Patient_Medicine.Start_Date_Time != "null" &&
                                    oIn_Patient_Medicine.Start_Date_Time != "1/1/0001")
                                {
                                    DateTime startDate;
                                    if (DateTime.TryParse(oIn_Patient_Medicine.Start_Date_Time, out startDate) && startDate > DateTime.MinValue)
                                    {
                                        oIn_Patient_Medicine1.Start_Date_Time = startDate;
                                    }
                                }

                                if (!string.IsNullOrEmpty(oIn_Patient_Medicine.Stop_Date_Time) &&
                                    oIn_Patient_Medicine.Stop_Date_Time != "null")
                                {
                                    DateTime stopDateTime;
                                    if (DateTime.TryParse(oIn_Patient_Medicine.Stop_Date_Time, out stopDateTime))
                                    {
                                        oIn_Patient_Medicine1.Stop_Date_Time = stopDateTime;
                                    }
                                }

                                db.In_Patient_Medicines.InsertOnSubmit(oIn_Patient_Medicine1);
                                insertedCount++;
                            }
                        }

                        db.SubmitChanges();
                        System.Diagnostics.Debug.WriteLine($"=== SaveMedicinesforMon Complete - Inserted {insertedCount}, Updated {updatedCount} medicines ===");
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("SaveMedicinesforMon Error: " + ex.Message);
                System.Diagnostics.Debug.WriteLine("Stack Trace: " + ex.StackTrace);
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
                    /******************** Deleting Previous 0 Value Saved Rows ***********************************/
                    // Keeping your garbage collection logic for invalid Patient_ID == 0
                    List<In_Patient_Medicine> In_Patient_MedicineList = db.In_Patient_Medicines
                        .Where(i => i.Patient_ID == 0 && i.Transaction_Type == "InPatientMonitring")
                        .ToList();

                    if (In_Patient_MedicineList.Count > 0)
                    {
                        db.In_Patient_Medicines.DeleteAllOnSubmit(In_Patient_MedicineList);
                        db.SubmitChanges();
                    }

                    if (MedicineDetail.PatientID != 0)
                    {
                        // Get ALL existing medicine names for this patient under "InPatientMonitring"
                        var existingNames = db.In_Patient_Medicines
                            .Where(p => p.Patient_ID == MedicineDetail.PatientID && p.Transaction_Type == "InPatientMonitring")
                            .Select(p => p.Medicine_Name.Trim())
                            .ToList();

                        System.Diagnostics.Debug.WriteLine("=== SaveMedicines (Monitoring) Debug ===");
                        System.Diagnostics.Debug.WriteLine("Patient ID: " + MedicineDetail.PatientID);
                        System.Diagnostics.Debug.WriteLine("Transaction Type: InPatientMonitring");
                        System.Diagnostics.Debug.WriteLine("Existing medicines: " + string.Join(", ", existingNames));

                        int insertedCount = 0;

                        foreach (MedicineDetails oIn_Patient_Medicine in MedicineDetail.MedicineList)
                        {
                            string medicineName = !string.IsNullOrEmpty(oIn_Patient_Medicine.Medicine_Name)
                                ? oIn_Patient_Medicine.Medicine_Name.Trim()
                                : string.Empty;

                            if (string.IsNullOrEmpty(medicineName)) continue;

                            // Only insert if name NOT in existing list
                            if (!existingNames.Contains(medicineName))
                            {
                                System.Diagnostics.Debug.WriteLine("INSERTING new monitoring medicine: " + medicineName);

                                In_Patient_Medicine oIn_Patient_Medicine1 = new In_Patient_Medicine()
                                {
                                    Patient_ID = Convert.ToInt32(MedicineDetail.PatientID),
                                    Medicine_Name = medicineName,
                                    Medicine_Date = oIn_Patient_Medicine.Medicine_Date,
                                    Oral = oIn_Patient_Medicine.Oral,
                                    Transaction_Type = "InPatientMonitring",  // Keep as InPatientMonitring
                                    Injections = oIn_Patient_Medicine.Injection,
                                    Recomended_Dosage = oIn_Patient_Medicine.Recomended_Dosage,
                                    Frequency = oIn_Patient_Medicine.Frequency,
                                    Nurse_Name = oIn_Patient_Medicine.Nurse_Name,
                                    Dosage_Qty = oIn_Patient_Medicine.Dosage_Qty,
                                    Dosage_From = oIn_Patient_Medicine.Dosage_From,
                                    Other_Instruction = oIn_Patient_Medicine.Other_Instruction,
                                    AttendingParamedical_Staff = oIn_Patient_Medicine.AttendingParamedical_Staff,
                                    Regular = oIn_Patient_Medicine.Regular == "REGULAR" ? true : false,
                                    STAT = oIn_Patient_Medicine.STAT == "STAT" ? true : false,
                                    PRN = oIn_Patient_Medicine.PRN == "PRN" ? true : false,
                                    chkDiccharge = Convert.ToBoolean(oIn_Patient_Medicine.chkDiccharge),
                                    Username = AppConfig.UserName,
                                    is_rejected = false,
                                    Status = null
                                };

                                db.In_Patient_Medicines.InsertOnSubmit(oIn_Patient_Medicine1);
                                insertedCount++;
                            }
                            else
                            {
                                System.Diagnostics.Debug.WriteLine("SKIPPING existing monitoring medicine: " + medicineName);
                            }
                        }
                        db.SubmitChanges();
                        System.Diagnostics.Debug.WriteLine($"=== SaveMedicines Complete - Inserted {insertedCount} medicines ===");
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("SaveMedicines Error: " + ex.Message);
            }
            return "";
        }
        public class Detail
        {
            public string Name;
            public string Gender;
            public string Age;
            public string Mobile;
            public string Address;
            public string Entry_Date;
            public string inPatient;
            public string in_patient_id;
            public string Ward_Name; 
            public string Bed_No;
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
                if (pat.Created_time.HasValue)
                    pt.Entry_Date = pat.Created_time.ToString();
                else
                    pt.Entry_Date = pat.Created_time.Value.ToShortDateString();
                pt.Address = pat.Permanent_Address;
                pt.Mobile = pat.Mobile1;
                pt.Gender = db.GetDataValueName("Gender", pat.Gender);
                pt.inPatient = pat.pat_id.ToString();
                pt.in_patient_id = DBClass.getField("select In_Patient_ID from In_Patient where Patient_ID =" + PatientID + " order by Created_Time desc");

                var inPatientData = (from ip in db.In_Patients
                                     join wd in db.Ward_Definitions on ip.Ward_ID equals wd.Ward_ID into wardJoin
                                     from ward in wardJoin.DefaultIfEmpty()
                                     where ip.Patient_ID == int.Parse(PatientID)
                                     orderby ip.Created_Time descending
                                     select new
                                     {
                                         WardName = ward != null ? ward.Ward_Type : "",
                                         BedNo = ip.Bed_No
                                     }).FirstOrDefault();

                if (inPatientData != null)
                {
                    pt.Ward_Name = inPatientData.WardName ?? "";
                    pt.Bed_No = inPatientData.BedNo != null ? inPatientData.BedNo.ToString() : "";
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
        protected void BtnDelete_Click(object sender, EventArgs e)
        {

            Boolean bol = Convert.ToBoolean(ViewState["check"]);
            int Index = Convert.ToInt32(ViewState["Index"]);
            if (bol == true)
            {
                bol = false;
                DataRow[] dr = dt.Select("Index = '" + Index + "'");
                dt.Rows.Remove(dr[0]);
                dt.AcceptChanges();
                Session["PatientMonitoring"] = dt;
                ViewState.Remove("check");
                ViewState.Add("check", bol);
                Cleartxt();
                GRD.DataSource = dt;
                GRD.DataBind();
            }
        }
        protected void btnNew_Click(object sender, EventArgs e)
        {
            blankform();
            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "bindControls", "bindControls();", true);
        }
        protected void btnClear_Click(object sender, EventArgs e)
        {
            Cleartxt();
        }
        private void BindingDropDown()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            object valueset;
            valueset = DBClass.GetValueSet("Intake");
            ddlPerformed_By.DataSource = valueset;
            ddlPerformed_By.DataTextField = "DataValue_Description";
            ddlPerformed_By.DataValueField = "DataValue_Name";
            ddlPerformed_By.Items.Add(new ListItem("Please Select", "0"));
            ddlPerformed_By.DataBind();
            var EmpList = (from tblEmp in db.HR_Employees
                           join tblDv in db.DataValues
                           on tblEmp.Designation equals tblDv.DataValue_Name
                           where tblDv.DataValue_Description == "Nurse"
                           select new
                           {
                               tblEmp.Emp_ID,
                               tblEmp.Emp_Name
                           }).ToList();
            ddlNurse.DataSource = EmpList;
            ddlNurse.DataTextField = "Emp_Name";
            ddlNurse.DataValueField = "Emp_ID";
            ddlNurse.Items.Add(new ListItem("Please Select", "0"));
            ddlNurse.DataBind();
            var MdcnList = (from Itm in db.INV_Items
                            join Dv in db.DataValues
                            on Itm.Item_Category equals Dv.DataValue_Name
                            where Dv.DataValue_Description == "Medicine"
                            select new
                            {
                                Itm.Item_ID,
                                Itm.Description
                            }).ToList();
            ddlMedicine_Name.DataSource = MdcnList;
            ddlMedicine_Name.DataTextField = "Description";
            ddlMedicine_Name.DataValueField = "Item_ID";
            ddlMedicine_Name.Items.Add(new ListItem("Please Select", "0"));
            ddlMedicine_Name.DataBind();
            var ItmSbCatList = (from Vs in db.ValueSets
                                join Dv in db.DataValues
                                on Vs.ValueSet_ID equals Dv.ValueSet_ID
                                where Vs.ValueSet_Description == "Item Sub Category"
                                select new
                                {
                                    Dv.DataValue_Name,
                                    Dv.DataValue_Description
                                }).ToList();
            ddlMedicine_Type.DataSource = ItmSbCatList;
            ddlMedicine_Type.DataTextField = "DataValue_Description";
            ddlMedicine_Type.DataValueField = "DataValue_Name";
            ddlMedicine_Type.Items.Add(new ListItem("Please Select", "0"));
            ddlMedicine_Type.DataBind();

        }
        public class List2
        {
            public DateTime Mon_Date { get; set; }
            public string InPatient_Mon_Dtl_ID { get; set; }
            public int Pulse_Min { get; set; }
            public string BP_mm_Hg { get; set; }
            public int Temp_C { get; set; }
            public int Respiration_Min { get; set; }
            public int Weight_Kg { get; set; }
            public int Blood_Suger { get; set; }
            public int BMI { get; set; }
            public int Height { get; set; }
            public int Saturation { get; set; }
        }

        [WebMethod]
        public static List<List2> GetChartData(int ID)
        {
            DataTable dt = new DataTable();
            dt = DBClass.getDataTable("select InPatient_Mon_Dtl_ID, Pulse_Min,BP_mm_Hg,Temp_C,Respiration_Min,Weight_Kg,Saturation,Blood_Suger from InPatient_Monitoring_Detail   where InPatient_Mon_ID=" + ID + "");
            List<List2> dataList = new List<List2>();
            foreach (DataRow dtrow in dt.Rows)
            {
                List2 details = new List2();
                details.InPatient_Mon_Dtl_ID = dtrow[0].ToString();
                details.Pulse_Min = Convert.ToInt32(dtrow[1]);
                details.Temp_C = Convert.ToInt32(dtrow[3]);
                details.Respiration_Min = Convert.ToInt32(dtrow[4]);
                details.Weight_Kg = Convert.ToInt32(dtrow[5]);
                details.Saturation = Convert.ToInt32(dtrow[6]);

                details.Blood_Suger = Convert.ToInt32(dtrow[7]);
                dataList.Add(details);
            }
            return dataList;
        }
        [WebMethod]
        public static List<List2> GetChartPulseData(int ID)
        {
            DataTable dt = new DataTable();
            dt = DBClass.getDataTable("select Mon_Date,Pulse_Min from InPatient_Monitoring_Detail where InPatient_Mon_ID=" + ID + "");
            List<List2> dataList = new List<List2>();
            foreach (DataRow dtrow in dt.Rows)
            {
                List2 details = new List2();
                details.Mon_Date = Convert.ToDateTime(dtrow[0].ToString());
                details.Pulse_Min = Convert.ToInt32(dtrow[1]);
                dataList.Add(details);
            }
            return dataList;
        }
        [WebMethod]
        public static List<List2> GetChartDataBP(int ID)
        {
            DataTable dt = new DataTable();
            dt = DBClass.getDataTable("select Mon_Date,BP_mm_Hg from InPatient_Monitoring_Detail where InPatient_Mon_ID=" + ID + "");
            List<List2> dataList = new List<List2>();
            foreach (DataRow dtrow in dt.Rows)
            {
                List2 details = new List2();
                details.Mon_Date = Convert.ToDateTime(dtrow[0].ToString());
                details.BP_mm_Hg = dtrow[1].ToString();
                dataList.Add(details);
            }
            return dataList;
        }
        public class InstructionNote
        {
            public int InPatientID { get; set; }
            public int Pat { get; set; }
            public List<InstructionNoteeDetails> ListIns { get; set; }
            public List<InstructionNoteDel> listDel { get; set; }
        }
        public class InstructionNoteeDetails
        {
            public DateTime Instruction_Date { get; set; }
            public string Doctor_Status { get; set; }
            public string Doctor_ID { get; set; }
            public string Doctor_Instruction { get; set; }
            public string ChekInstruction { get; set; }
            public string Nurse_Name { get; set; }
            public string Progress_Note { get; set; }
        }

        public class InstructionNoteDel
        {
            public string Doctor_Note_ID { get; set; }
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
                    List<InPatient_Doctor_Note> InPatient_Instruction = db.InPatient_Doctor_Notes.Where(i => i.In_Patient_ID == InsDetail.InPatientID && i.status == "Saved").ToList();
                    db.InPatient_Doctor_Notes.DeleteAllOnSubmit(InPatient_Instruction);
                    db.SubmitChanges();
                }
                foreach (var test in InsDetail.ListIns)
                {
                    InPatient_Doctor_Note oInPatient_Doctor_Note = new PMS.InPatient_Doctor_Note();
                    oInPatient_Doctor_Note.In_Patient_ID = InsDetail.InPatientID;
                    oInPatient_Doctor_Note.Patient_ID = InsDetail.Pat;
                    oInPatient_Doctor_Note.Doctor_Status = test.Doctor_Status;
                    oInPatient_Doctor_Note.Doctor_ID = test.Doctor_ID;
                    oInPatient_Doctor_Note.Doctor_Instruction = test.Doctor_Instruction;
                    oInPatient_Doctor_Note.Doctor_Note_Date = test.Instruction_Date;
                    oInPatient_Doctor_Note.IsLatest = Convert.ToBoolean(test.ChekInstruction);
                    oInPatient_Doctor_Note.Nurse_Name = test.Nurse_Name;
                    oInPatient_Doctor_Note.Progress_Note = test.Progress_Note;
                    oInPatient_Doctor_Note.status = "Saved";

                    db.InPatient_Doctor_Notes.InsertOnSubmit(oInPatient_Doctor_Note);
                    db.SubmitChanges();
                }

                foreach (var del in InsDetail.listDel)
                {
                    var Doc_note_id = db.InPatient_Doctor_Notes.Where(x => x.Doctor_Note_ID == Convert.ToInt32(del.Doctor_Note_ID));
                    db.InPatient_Doctor_Notes.DeleteAllOnSubmit(Doc_note_id);
                    db.SubmitChanges();
                }



            }
            catch (Exception ex)
            {

            }
            return "";
        }

        [WebMethod]
        public static string GetInstructionEdit(int Patid)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatmedicineList = (from inpat in db.In_Patients
                                         join pm in db.InPatient_Doctor_Notes
                                         on inpat.In_Patient_ID equals pm.In_Patient_ID
                                         where pm.Patient_ID == Patid && (inpat.Discharge == false || inpat.Discharge == null) && pm.IsLatest == true && pm.status == "Saved"
                                         select new
                                         {
                                             pm.IsLatest,
                                             pm.Doctor_Note_Date,
                                             pm.Doctor_Instruction,
                                             pm.Progress_Note,
                                             pm.Doctor_Status,
                                             pm.Doctor_ID,
                                             pm.Nurse_Name,
                                             DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(pm.Doctor_ID) select d.Emp_Name).FirstOrDefault(),
                                             DoctorStatus = db.GetDataValueName("Doctor Status", pm.Doctor_Status)

                                         }).ToList();

                return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
            }
            return "";
        }
        [WebMethod]
        public static string GetInstruction(int Patid)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatmedicineList = (from inpat in db.In_Patients
                                         join pm in db.InPatient_Doctor_Notes
                                         on inpat.In_Patient_ID equals pm.In_Patient_ID
                                         where pm.Patient_ID == Patid && (inpat.Discharge == false || inpat.Discharge == null) && (pm.IsLatest == false || pm.IsLatest == null) && pm.status == "Create"
                                         select new
                                         {
                                             pm.Doctor_Note_ID,
                                             Admission_Date = pm.Doctor_Note_Date,
                                             RN_Special_Instruction = pm.Doctor_Instruction,
                                             pm.Doctor_Status,
                                             pm.Progress_Note,
                                             pm.Doctor_ID,
                                             pm.Nurse_Name,
                                             DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(pm.Doctor_ID) select d.Emp_Name).FirstOrDefault(),
                                             DoctorStatus = db.GetDataValueName("Doctor Status", pm.Doctor_Status)

                                         }).ToList();

                return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
            }
            return "";
        }
        [WebMethod]
        public static List<List2> GetChartDataTemp(int ID)
        {
            DataTable dt = new DataTable();
            dt = DBClass.getDataTable("select Mon_Date,Temp_C from InPatient_Monitoring_Detail where InPatient_Mon_ID=" + ID + "");
            List<List2> dataList = new List<List2>();
            foreach (DataRow dtrow in dt.Rows)
            {
                List2 details = new List2();
                details.Mon_Date = Convert.ToDateTime(dtrow[0].ToString());
                details.Temp_C = Convert.ToInt32(dtrow[1]);
                dataList.Add(details);
            }
            return dataList;
        }
        [WebMethod]
        public static List<List2> GetChartDataResp(int ID)
        {
            DataTable dt = new DataTable();
            dt = DBClass.getDataTable("select Mon_Date,Respiration_Min from InPatient_Monitoring_Detail where InPatient_Mon_ID=" + ID + "");
            List<List2> dataList = new List<List2>();
            foreach (DataRow dtrow in dt.Rows)
            {
                List2 details = new List2();
                details.Mon_Date = Convert.ToDateTime(dtrow[0].ToString());
                details.Respiration_Min = Convert.ToInt32(dtrow[1]);
                dataList.Add(details);
            }
            return dataList;
        }
        [WebMethod]
        public static List<List2> GetChartDataBlood(int ID)
        {
            DataTable dt = new DataTable();
            dt = DBClass.getDataTable("select Mon_Date,Blood_Suger from InPatient_Monitoring_Detail where InPatient_Mon_ID=" + ID + "");
            List<List2> dataList = new List<List2>();
            foreach (DataRow dtrow in dt.Rows)
            {
                List2 details = new List2();
                details.Mon_Date = Convert.ToDateTime(dtrow[0].ToString());
                details.Blood_Suger = Convert.ToInt32(dtrow[1]);
                dataList.Add(details);
            }
            return dataList;
        }
        [WebMethod]
        public static List<List2> GetChartDataWeight(int ID)
        {
            DataTable dt = new DataTable();
            dt = DBClass.getDataTable("select Mon_Date,Weight_Kg from InPatient_Monitoring_Detail where InPatient_Mon_ID=" + ID + "");
            List<List2> dataList = new List<List2>();
            foreach (DataRow dtrow in dt.Rows)
            {
                List2 details = new List2();
                details.Mon_Date = Convert.ToDateTime(dtrow[0].ToString());
                details.Weight_Kg = Convert.ToInt32(dtrow[1]);
                dataList.Add(details);
            }
            return dataList;
        }
        [WebMethod]

        public static List<List2> GetChartSaturation(int ID)

        {

            DataTable dt = new DataTable();

            dt = DBClass.getDataTable("select Mon_Date,Saturation from InPatient_Monitoring_Detail where InPatient_Mon_ID=" + ID + "");

            List<List2> dataList = new List<List2>();

            foreach (DataRow dtrow in dt.Rows)

            {

                List2 details = new List2();

                details.Mon_Date = Convert.ToDateTime(dtrow[0].ToString());

                details.Saturation = Convert.ToInt32(dtrow[1]);

                dataList.Add(details);

            }

            return dataList;

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
        private class ddlAdd
        {
            public string DataValueName;
            public string DataValueDescription;

        }
        private class ddlInsVol
        {
            public string DataValueName;
            public string DataValueDescription;

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
        public static string getpharmacyitems(string searchString)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var pharmacyItems = (from d in db.INV_Items
                                     where d.IsPharmacyItem == true && d.Description.Contains(searchString)
                                     && (d.Short_Item == false || d.Short_Item == null)
                                     orderby d.Item_ID descending
                                     select new
                                     {
                                         d.Item_ID,
                                         Description = d.Description
                                     }).Take(20).ToList();

                return (new JavaScriptSerializer().Serialize(pharmacyItems));
            }
        }

        [WebMethod]
        public static string GetDepartments_WL()
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
        public static string GetWards_WL(string departmentId)
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var wards = (from w in db.Ward_Definitions
                             where (departmentId == "0" || w.Department == departmentId)
                             select new
                             {
                                 w.Ward_ID,
                                 w.Ward_Type
                             }).ToList();

                data = new JavaScriptSerializer().Serialize(wards);
            }
            return data;
        }

        [WebMethod]
        public static string PendingPatients_WL(string DeptID, string WardID)
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
                             DepartmentName = db.GetDataValueName("Patient Main Category", ip.Department),
                             WardName = (from w in db.Ward_Definitions where w.Ward_ID == ip.Ward_ID select w.Ward_Type).FirstOrDefault(),
                             Checked = ((from op in db.ReceivingNotes
                                         where ip.In_Patient_ID == op.In_Patient_ID
                                         && op.Type_Nursing == "IPD Receiving Note"
                                         select op.In_Patient_ID).FirstOrDefault()),
                             Gender = db.GetDataValueName("Gender", p.Gender),
                             ip.Created_Time,
                             u.UserName,
                             p.Age_years,
                             DepartmentID = ip.Department,
                             WardID_Value = ip.Ward_ID,
                             Patient_Type = (from dv in db.DataValues
                                             join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                             where vs.ValueSet_Name == "Patient Type" && dv.DataValue_Name == ip.Patient_Discount_Type
                                             select dv.DataValue_Description).FirstOrDefault()
                         }).AsQueryable();

            if (!string.IsNullOrEmpty(DeptID) && DeptID != "0")
            {
                query = query.Where(x => x.DepartmentID == DeptID);
            }

            if (!string.IsNullOrEmpty(WardID) && WardID != "0")
            {
                query = query.Where(x => x.WardID_Value == Convert.ToInt32(WardID));
            }

            var data = query.OrderByDescending(x => x.Created_Time).ToList();

            return (new JavaScriptSerializer()).Serialize(data);
        }

        [WebMethod]
        public static string MonitoringMedicines()
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var Monitoring = (from tbl in db.sys_Parms
                                      where tbl.Name == "Monitoring Medicines tab"
                                      select tbl.Code)
                              .FirstOrDefault();

                    return Monitoring ?? "01";
                }
            }
            catch (Exception ex)
            {
                return "0";
            }
        }

        [WebMethod]
        public static string loadAllUsers()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var user = (from u in db.aspnet_Users
                            where u.UserId == AppConfig.UserID
                            select new
                            {
                                u.UserId,
                                u.UserName
                            }).ToList();

                return new JavaScriptSerializer().Serialize(user);
            }
        }

        [WebMethod]
        public static bool IsPatientDischarged(int InPatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                return db.In_Patients
                    .Any(ip => ip.In_Patient_ID == InPatientID && ip.Discharge == true);
            }
        }
        private void PopulateInPatientDataForMonitoring(int InPatient_ID)
        {
            try
            {
                db = new DataBaseDataContext(DBClass.ConnectionString());
                var qry = (from ip in db.In_Patients
                           join p in db.Reg_patients on ip.Patient_ID equals p.pat_id
                           where ip.In_Patient_ID == InPatient_ID
                           select new
                           {
                               ip,
                               p,
                               WardName = (from wd in db.Ward_Definitions
                                           where wd.Ward_ID == ip.Ward_ID
                                           select wd.Ward_Type).FirstOrDefault(),
                               BedNo = ip.Bed_No
                           }).FirstOrDefault();

                if (qry != null)
                {
                    hdfPatient_ID.Value = qry.p.pat_id.ToString();
                    txtPatient_ID.Text = qry.p.pat_id.ToString();
                    hdnInpatient_id.Value = qry.ip.In_Patient_ID.ToString();
                    txtInPatient_Mon_ID.Text = "(New)";
                    vlblPatients_Name.Text = qry.p.Full_Name;
                    vLbl_Contact.Text = qry.p.Mobile1;
                    vLbl_Adress.Text = qry.p.Permanent_Address;
                    vLbl_Gender.Text = db.GetDataValueName("Gender", qry.p.Gender);
                    vLbl_Age.Text = qry.p.Age_years;
                    vLbl_RegDate.Text = qry.p.Created_time?.ToString(AppConfig.DateFormat) ?? "";
                    vLbl_WardName.Text = qry.WardName ?? "";
                    vLbl_BedNo.Text = qry.BedNo != null ? qry.BedNo.ToString() : "";
                }
            }
            catch (Exception ex)
            {
                lblMessage.CssClass = "errorMessage";
                lblMessage.Text = ex.Message;
            }
        }
        [WebMethod]
        public static string GetTestListForHistoryIPD(int in_patient_Id)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var InPatienttestilst = (from lbtM in db.Laboratory_Tests
                                     join lbtD in db.Lab_Test_Details
                                     on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                     join lab in db.Lab_Tests on lbtD.Test_ID equals lab.Test_ID
                                     join outpat in db.In_Patients
                                     on lbtM.Patient_ID equals outpat.In_Patient_ID
                                     join rp in db.Reg_patients
                                     on outpat.Patient_ID equals rp.pat_id
                                     join bd in db.Ar_Billing_Details
                                     on lbtD.BillDetailID equals bd.Bill_Details_ID
                                     where outpat.In_Patient_ID == in_patient_Id &&
                                     lbtM.Transaction_Type == "InPatient" && lbtD.IsBilled == true && (bd.Is_Group_Category == null ? false : bd.Is_Group_Category) == false
                                     select new
                                     {
                                         //outpat.Out_Patient_ID,
                                         Lab_Test_Detail_ID = (from t in db.Lab_Test_Details where t.BillDetailID == lbtD.BillDetailID orderby t.Lab_Test_Detail_ID descending select t.Lab_Test_Detail_ID).FirstOrDefault(),
                                         lbtD.Date,
                                         lbtD.Remark,
                                         lbtD.Catagory_ID,
                                         Lab_Test_ID = (from t in db.Lab_Test_Details where t.BillDetailID == lbtD.BillDetailID orderby t.Lab_Test_Detail_ID descending select t.Lab_Test_ID).FirstOrDefault(),
                                         lbtD.Test_ID,
                                         lbtD.Dept_ID,
                                         lbtD.L_R_Rotation_ID,
                                         Value_Type = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Value_Type).FirstOrDefault(),
                                         Value_TypeGroup = (from t in db.Lab_Tests where t.Group_Category == lbtD.Catagory_ID select t.Value_Type).FirstOrDefault(),
                                         Test_Name = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Test_Name).FirstOrDefault(),
                                         Group_Department = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Group_Department).FirstOrDefault(),
                                         Group_Category = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Group_Category).FirstOrDefault(),
                                         DepartmentName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test Departments", t.Main_Department)).FirstOrDefault(),
                                         Department_ID = lbtD.Dept_ID, //(from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Main_Department).FirstOrDefault(),
                                         GroupName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Test Groups", t.Group_Category)).FirstOrDefault(),
                                         Group_Name = db.GetDataValueName("Test Groups", lbtD.Catagory_ID),
                                         lbtD.Rotation_ID,
                                         Rotation = ((from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test Departments", t.Main_Department)).FirstOrDefault()) == "X-Ray"
                                             ? db.GetDataValueName("Test XRay Rotations", lbtD.Rotation_ID)
                                             : db.GetDataValueName("Test CT Scan Rotations", lbtD.Rotation_ID),
                                         DataValue_Description = (from dv in db.DataValues
                                                                  join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                                                  where vs.ValueSet_Name == "Test XRay Rotations" && dv.DataValue_Name == lbtD.Rotation_ID
                                                                  select dv.DataValue_Description).FirstOrDefault(),
                                         DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(outpat.Doctor) select d.Emp_Name).FirstOrDefault(),
                                         lbtD.Special_Tests,
                                         lbtD.Area_Of_Interest,
                                         Doctor = outpat.Doctor,
                                         lbtD.Recieved_ID,
                                         lbtD.Is_Result,
                                         Patient_Id = rp.pat_id,
                                         isApproved = (from t in db.Lab_Test_Details where t.BillDetailID == lbtD.BillDetailID orderby t.Lab_Test_Detail_ID descending select t.isApproved).FirstOrDefault(),
                                         BillDetailID = (from t in db.Lab_Test_Details where t.BillDetailID == lbtD.BillDetailID orderby t.Lab_Test_Detail_ID descending select t.BillDetailID).FirstOrDefault(),
                                         Report_Colum = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Report_Colum).FirstOrDefault(),
                                         //outpat.Doctor_ID
                                     }
            ).ToList();

            List<LabTestClass> list = new List<LabTestClass>();
            List<LabTestClass> AlltestListRefined = new List<LabTestClass>();

            foreach (var item in InPatienttestilst)
            {
                LabTestClass obj = new LabTestClass
                {
                    Lab_Test_Detail_ID = item.Lab_Test_Detail_ID.ToString(),
                    Date = Convert.ToDateTime(item.Date),
                    Remark = item.Remark,
                    Catagory_ID = item.Catagory_ID,
                    Lab_Test_ID = item.Lab_Test_ID.ToString(),
                    Test_ID = item.Test_ID,
                    Dept_ID = item.Dept_ID,
                    L_R_Rotation_ID = item.L_R_Rotation_ID,
                    Value_Type = item.Value_Type,
                    Value_TypeGroup = item.Value_TypeGroup,
                    Test_Name = item.Test_Name,
                    Group_Department = item.Group_Department,
                    Group_Category = item.Group_Category,
                    DepartmentName = item.DepartmentName,
                    Department_ID = item.Department_ID,
                    GroupName = item.GroupName,
                    Group_Name = item.Group_Name,
                    Rotation_ID = item.Rotation_ID,
                    Rotation = item.Rotation,
                    DataValue_Description = item.DataValue_Description,
                    Special_Tests = item.Special_Tests,
                    Area_Of_Interest = item.Area_Of_Interest,
                    Doctor = item.Doctor,
                    Recieved_ID = item.Recieved_ID,
                    Is_Result = item.Is_Result ?? false,
                    Report_Column = item.Report_Colum,
                    isApproved = item.isApproved ?? false,
                    Patient_ID = Convert.ToString(item.Patient_Id),
                    Bill_Details_ID = item.BillDetailID.ToString(),
                    DoctorName = item.DoctorName,
                    Status = "InPatient"
                };
                list.Add(obj);
            }
            AlltestListRefined = list;
            //For Group Tests
            DataTable GroupTest = DBClass.getDataTable("Select Distinct ld.Lab_Test_ID,(select Segment2 from Datavalues where Datavalue_Name = (Select Group_Category from Lab_TEsts where TEst_ID = ld.Test_ID) and ValueSet_ID = 70) as [Segment2] ,(select Datavalue_ID from Datavalues where Datavalue_Name = (Select Group_Category from Lab_TEsts where TEst_ID = ld.Test_ID) and ValueSet_ID = 70) as [Test_ID], (Select Group_Category from Lab_TEsts where TEst_ID = ld.Test_ID) as [Group_Category], dbo.GetDataValueName('Test Groups', (Select Group_Category from Lab_TEsts where TEst_ID = ld.Test_ID)) as [Group_Test_Name], bd.Bill_Details_ID,ld.Is_Result,ld.Rejected_Reason,bd.Service_Date,isnull(ld.isApproved,'') as IsApproved,ltm.patient_id,isnull(bd.Test_Main_Department,'') Test_Main_Department from Lab_Test_Detail ld, Lab_Tests lt, Laboratory_Test ltm, AR_Billing_Details bd, Reg_patient pat,Ar_Billings ab where bd.Bill_Details_ID = ld.BillDetailID and isnull(bd.Is_Group_Category,0) = 1 and ld.Patient_ID = pat.pat_id  and ab.In_Patient_ID = " + in_patient_Id + "  and lt.Test_ID = ld.Test_ID /* and lt.Group_Category <> ''*/ and ltm.Lab_Test_ID = ld.Lab_Test_ID");

            foreach (DataRow item in GroupTest.Rows)
            {
                LabTestClass TestObj = new LabTestClass()
                {
                    Lab_Test_ID = item[0] == DBNull.Value ? "" : item[0].ToString(),
                    Report_Column = item[1] == DBNull.Value ? "" : item[1].ToString(),
                    Test_ID = item[2] == DBNull.Value ? 0 : Convert.ToInt32(item[2]),
                    Group_Category = item[3] == DBNull.Value ? "" : item[3].ToString(),
                    Test_Name = item[4] == DBNull.Value ? "" : item[4].ToString(),
                    Bill_Details_ID = item[5] == DBNull.Value ? "" : item[5].ToString(),
                    Is_Result = Convert.ToBoolean(item[6] == DBNull.Value ? "" : item[6]),
                    Rejected_Reason = item[7] == DBNull.Value ? "" : item[7].ToString(),
                    Service_Date = item[8] == DBNull.Value ? "" : item[8].ToString(),
                    isApproved = Convert.ToBoolean(item[9] == DBNull.Value ? "" : item[9]),
                    Test_Main_Department = item[11] == DBNull.Value ? "" : item[11].ToString(),
                };

                TestObj.ListOfTestIDs = DBClass.getField("select dbo.[GetGroupSubTests]('" + TestObj.Group_Category + "')");

                AlltestListRefined.Add(TestObj);
            }

            return (new JavaScriptSerializer()).Serialize(AlltestListRefined);
        }

        public class LabTestClass
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
            public string Bill_Details_ID;
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
            public string doctornames;
            public string DataValue_Description;
            public bool Is_Result;
            public bool isApproved;
            public string Rotation;
            public string Doctor;
            public string Status;
            public string Report_Column;
            public string ListOfTestIDs;
            public string Rejected_Reason;
            public string Service_Date;
            public bool Is_Approve;
            public string Test_Main_Department;
        }
    }
}