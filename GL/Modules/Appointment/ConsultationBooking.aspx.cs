using System;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Collections.Generic;

namespace PMS
{
    public partial class ConsultationBooking : System.Web.UI.Page
    {
        DataTable dt;
        DataTable dt1;
        DataBaseDataContext db;
        
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                db = new DataBaseDataContext();
                Blankform();
                BindDropDownList();

                if (Request.QueryString["ID"] != null)
                {
                    fill(Request.QueryString["ID"], "Consultation_Booking");
                    btnSave.Text = "Update";

                }

                txtDate.Text = DateTime.Now.ToString(DateFormate());
            }
            else
            {
                dt = Session["ConsultationBooking"] as DataTable;
                GRD.DataSource = dt;
                GRD.DataBind();

                dt1 = Session["ConsultationBooking1"] as DataTable;
                GRD_2.DataSource = dt1;
                GRD_2.DataBind();
            }
        }
        private string DateFormate()
        {
            return "MM/dd/yyyy";
        }

        private void BindDropDownList()
        {
            #region "Bind Drop DownList"
            object valueset;
            
            valueset = DBClass.GetValueSet("Medical Test");

            ddlRecommendedTest.DataSource = valueset;
            ddlRecommendedTest.DataTextField = "DataValue_Description";
            ddlRecommendedTest.DataValueField = "DataValue_Name";
            ddlRecommendedTest.Items.Add(new ListItem("Please Select", "0"));
            ddlRecommendedTest.DataBind();

            valueset = DBClass.GetValueSet("Medical Test");
            ddlMedical_Test.DataSource = valueset;
            ddlMedical_Test.DataTextField = "DataValue_Description";
            ddlMedical_Test.DataValueField = "DataValue_Name";
            ddlMedical_Test.Items.Add(new ListItem("Please Select", "0"));
            ddlMedical_Test.DataBind();
            
            valueset = DBClass.GetValueSet("Consultation Type");

            ddlConsultationType.DataSource = valueset;
            ddlConsultationType.DataTextField = "DataValue_Description";
            ddlConsultationType.DataValueField = "DataValue_Name";
            ddlConsultationType.Items.Add(new ListItem("Please Select", "0"));
            ddlConsultationType.DataBind();

            db = new DataBaseDataContext(DBClass.ConnectionString());
            List<HR_Employee> Doctors = new List<HR_Employee>();
            Doctors = (from tbl in db.HR_Employees
                       where tbl.IsDoctor == true
                       select tbl).ToList();

            ddlDoctorName.DataSource = Doctors;
            ddlDoctorName.DataTextField = "Emp_name";
            ddlDoctorName.DataValueField = "Emp_ID";
            ddlDoctorName.Items.Add(new ListItem("Please Select", "0"));
            ddlDoctorName.DataBind();
            #endregion
        }

        void Blankform()
        {
            #region "Blank Form"
            txtPatient_ID.Text = "";
            txtConsultation_B_ID.Text = "(New)";
            lblReg_Date.Text = "";
            lblPatients_Name.Text = "";
            lbl_Contact.Text = "";
            lbl_Adress.Text = "";
            lbl_Gender.Text = "";
            lbl_Age.Text = "";
            ddlRecommendedTest.SelectedIndex = 0;
            txtDate.Text=DateTime.Now.ToString(AppConfig.DateFormat);
            txtConsultationCharges.Text = "";
            ddlDoctorName.SelectedIndex = 0;
            ddlConsultationType.SelectedIndex = 0;
            ddlMedical_Test.SelectedIndex = 0;

            txtPatientHistory.Text = "";
            txtMedincineName.Text = "";
            txtNoOfDoses.Text = "";
            txtPrecaution.Text = "";
            txtCharges.Text = "";
            txtDoctorComment.Text = "";


            //Grid part
            dt = new DataTable();
            Session["ConsultationBooking"] = dt;
            DataColumn[] keys = new DataColumn[1];
            DataColumn index = new DataColumn("Index", Type.GetType("System.Int32"));
            DataColumn Test_Name = new DataColumn("Test_Name", Type.GetType("System.String"));
            DataColumn BloodTest_Name = new DataColumn("BloodTest_Name", Type.GetType("System.String"));
            dt.Columns.Add(index);
            dt.Columns.Add(Test_Name);
            dt.Columns.Add(BloodTest_Name);
            keys[0] = index;
            dt.PrimaryKey = keys;
            GRD.DataSource = dt;
            GRD.DataBind();

            //Grid_2 part
            dt1 = new DataTable();
            Session["ConsultationBooking1"] = dt1;
            DataColumn[] keys1 = new DataColumn[1];
            DataColumn index1 = new DataColumn("Index1", Type.GetType("System.Int32"));
            DataColumn Medicine_Name = new DataColumn("Medicine_Name", Type.GetType("System.String"));
            DataColumn No_of_Doses = new DataColumn("No_of_Doses", Type.GetType("System.String"));
            DataColumn Precaution = new DataColumn("Precaution", Type.GetType("System.String"));
            DataColumn Charges = new DataColumn("Charges", Type.GetType("System.String"));
            dt1.Columns.Add(index1);
            dt1.Columns.Add(Medicine_Name);
            dt1.Columns.Add(No_of_Doses);
            dt1.Columns.Add(Precaution);
            dt1.Columns.Add(Charges);

            keys1[0] = index1;
            dt1.PrimaryKey = keys1;
            GRD_2.DataSource = dt1;
            GRD_2.DataBind();

            #endregion
        }

        public class Detail
         {
             #region "Class Detail"
             public string Name;

            public string Gender;
            public string Age;

            public string Mobile;
            public string Address;
            public string Entry_Date;
            public string Patient_Category;
             #endregion

         }

        [System.Web.Services.WebMethod]
        public static Detail GetDetail(string PatientID)
         {
             #region "GetDetail For Patient ID"
             int Patien_No = Convert.ToInt32(PatientID);
            Detail pt = new Detail();
            DataBaseDataContext db = new DataBaseDataContext();
            Patient pat = new Patient();

            pat = (from tbl in db.Patients
                   where tbl.Patient_ID == Patien_No
                   select tbl).FirstOrDefault();
            if (pat != null)
            {

                pt.Name = pat.Full_Name;
                pt.Gender = pat.Gender;



                pt.Age = pat.Age_years.ToString();

                if (pat.Entry_Date.HasValue)
                    pt.Entry_Date = pat.Entry_Date.ToString();

                pt.Address = pat.Address;

                pt.Mobile = pat.Mobile;

                pt.Gender = db.GetDataValueName("Gender", pat.Gender);
                return pt;
            }
            else
                return pt;
             #endregion
         }

        public void fill(string id, string tblname)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

                var qry1 = (from tbl in db.Consultation_Bookings
                            join pat in db.Patients
                            on tbl.Patient_ID equals pat.Patient_ID
                            where tbl.Consultation_B_ID == Convert.ToInt32(id)
                            select new
                            {
                                tbl.Patient_ID,
                                tbl.Consultation_B_ID,
                                tbl.Recommended_Test,
                                tbl.Consultation_Charges,
                                tbl.Consultation_Type,
                                tbl.Date,
                                tbl.Doctor_Name,
                                tbl.Patient_History,
                                tbl.Doctor_Comment,

                                pat.Full_Name,
                                pat.Mobile,
                                pat.Address,
                                pat.Gender,
                                pat.Age_years,
                                pat.Entry_Date,
                                pat.Patient_Main_Category

                            }).FirstOrDefault();

                txtPatient_ID.Text = qry1.Patient_ID.ToString();
                hdfPatient.Value = qry1.Patient_ID.ToString();
                txtConsultation_B_ID.Text = qry1.Consultation_B_ID.ToString();
                lblPatients_Name.Text = qry1.Full_Name;
                lbl_Contact.Text = qry1.Mobile;
                lbl_Adress.Text = qry1.Address;
                lbl_Gender.Text = db.GetDataValueName("Gender", qry1.Gender);
                lbl_Age.Text = qry1.Age_years;
                lblReg_Date.Text = qry1.Entry_Date.Value.ToString(AppConfig.DateFormat);

                ddlRecommendedTest.SelectedValue = qry1.Recommended_Test;
                ddlDoctorName.SelectedValue = qry1.Doctor_Name;
                ddlConsultationType.SelectedValue = qry1.Consultation_Type;
                txtConsultationCharges.Text = Convert.ToString(qry1.Consultation_Charges);
                txtDate.Text = qry1.Date.Value.ToString(DateFormate());
                txtPatientHistory.Text = qry1.Patient_History;
                txtDoctorComment.Text = qry1.Doctor_Comment;


                ////// For Grid //////////

                var qry = (from tbl in db.Consultation_Test_Details
                           where tbl.Consultation_B_ID == Convert.ToInt32(id)
                           select tbl).ToList();

                Int32 index = 0;
                dt.Rows.Clear();

                foreach (var item in qry)
                {
                    DataRow row = dt.NewRow();

                    row["Index"] = index;
                    row["Test_Name"] = item.Test_Name;
                    string test = ddlMedical_Test.Items.FindByValue(item.Test_Name).ToString();
                    row["BloodTest_Name"] = test;
                    dt.Rows.Add(row);
                    index++;
                }
                GRD.DataSource = dt;
                GRD.DataBind();

                ////// For Grid_2 ///////

                var qry2 = (from tbl in db.Consultation_Prescribed_Medicine_Details
                            where tbl.Consultation_B_ID == Convert.ToInt32(id)
                            select tbl).ToList();

                Int32 index1 = 0;
                dt1.Rows.Clear();

                foreach (var item1 in qry2)
                {
                    DataRow row = dt1.NewRow();

                    row["Index1"] = index1;
                    row["Medicine_Name"] = item1.Medicine_Name;
                    row["No_of_Doses"] = item1.No_of_Doses;
                    row["Precaution"] = item1.Precaution;
                    row["Charges"] = item1.Charges;


                    dt1.Rows.Add(row);
                    index1++;
                }
                GRD_2.DataSource = dt1;
                GRD_2.DataBind();


            }
            catch (Exception ex)
            {
                lblMessage.CssClass = "errorMessage";
                lblMessage.Text = ex.Message;
            }
        }


        protected void GRD_SelectedIndexChanging(object sender, GridViewSelectEventArgs e)
        {

            Boolean bol = true;
            btnSaveTest.Text = "Update";
            ViewState.Remove("check");
            ViewState.Add("check", bol);
            Label lblIndex = (Label)GRD.Rows[e.NewSelectedIndex].FindControl("lblIndex");
            int Index = Convert.ToInt32(lblIndex.Text);
            ViewState.Add("Index", Index);

            DataRow[] row = dt.Select("Index = '" + Index + "'");
            string testname = Convert.ToString(row[0]["Test_Name"]);
            string bloodtestname = Convert.ToString(row[0]["BloodTest_Name"]);

            //txtTestName.Text = testname;
            ddlMedical_Test.SelectedValue = testname;

            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "", " bindDate();", true);
            e.NewSelectedIndex = -1;
            e.Cancel = true;
            upTestForm.Update();
        }

        protected void GRD_2_SelectedIndexChanging(object sender, GridViewSelectEventArgs e)
        {
            #region "GridView 2 "

            Boolean bol = true;
            btnAdd.Text = "Update";
            ViewState.Remove("check1");
            ViewState.Add("check1", bol);
            Label lblIndex1 = (Label)GRD_2.Rows[e.NewSelectedIndex].FindControl("lblIndex1");
            int Index1 = Convert.ToInt32(lblIndex1.Text);
            ViewState.Add("Index1", Index1);

            DataRow[] row = dt1.Select("Index1 = '" + Index1 + "'");
            string medicinename = Convert.ToString(row[0]["Medicine_Name"]);
            string Doses = Convert.ToString(row[0]["No_of_Doses"]);
            string precaution = Convert.ToString(row[0]["Precaution"]);
            string charges = Convert.ToString(row[0]["Charges"]);

             
            txtMedincineName.Text = medicinename;
            txtNoOfDoses.Text = Doses;
            txtPrecaution.Text = precaution;
            txtCharges.Text = charges;
          

            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "", " bindDate();", true);
            e.NewSelectedIndex = -1;
            e.Cancel = true;
            upMdcnForm.Update();
            #endregion
        }

        private void Cleartxt()
        {
            ddlMedical_Test.SelectedValue = "0";
        }

        private void Cleartxt_MdcnForm()
        {
            txtMedincineName.Text = "";
            txtNoOfDoses.Text = "";
            txtPrecaution.Text = "";
            txtCharges.Text = "";
        }

        protected void btnSaveTest_Click(object sender, EventArgs e)
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
                    row[0]["Test_Name"] = ddlMedical_Test.SelectedValue;
                    row[0]["BloodTest_Name"] = ddlMedical_Test.SelectedItem.ToString();
                    ViewState.Remove("check");
                    ViewState.Add("check", bol);

                    btnSaveTest.Text = "Add Test";
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
                    row["Test_Name"] = ddlMedical_Test.SelectedValue;
                    row["BloodTest_Name"] = ddlMedical_Test.SelectedItem.ToString();
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

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            #region "Button Add For GridView 2"
            try
            {
                lblValidation1.Text = "";

                Boolean bol = Convert.ToBoolean(ViewState["check1"]);
                int Index1 = Convert.ToInt32(ViewState["Index1"]);

                if (bol == true)
                {

                    bol = false;
                    DataRow[] row = dt1.Select("Index1 = '" + Index1 + "'");
                    row[0]["Index1"] = Index1;
                    row[0]["Medicine_Name"] = txtMedincineName.Text;
                    row[0]["No_of_Doses"] = txtNoOfDoses.Text;
                    row[0]["Precaution"] = txtPrecaution.Text;
                    row[0]["Charges"] = txtCharges.Text;
                    ViewState.Remove("check1");
                    ViewState.Add("check1", bol);

                    btnAdd.Text = "Add";
                }
                else
                {
                    DataRow row = dt1.NewRow();
                    string index1;
                    index1 = Convert.ToString(dt1.Compute("Max(Index1)", ""));
                    if (index1 != "")
                        index1 = Convert.ToString(Convert.ToInt32(index1) + 1);
                    else
                        index1 = "0";
                    row["Index1"] = index1;
                    row["Medicine_Name"] = txtMedincineName.Text;
                    row["No_of_Doses"] = txtNoOfDoses.Text;
                    row["Precaution"] = txtPrecaution.Text;
                    row["Charges"] = txtCharges.Text;

                    dt1.Rows.Add(row);
                }

                ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "", " bindDate();", true);
                GRD_2.DataSource = dt1;
                GRD_2.DataBind();
                Cleartxt_MdcnForm();
            }
            catch (Exception exc)
            {
                lblValidation1.Text = exc.Message;
            }

            #endregion
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            #region "Button Save"

            lblMessage.Text = "";
            db = new DataBaseDataContext();
            int count = dt.Rows.Count;
            int count1 = dt1.Rows.Count;
            int con_b_id = 0;

            try
            {
                Consultation_Booking cons;

               if (txtConsultation_B_ID.Text == "(New)")
               {
                   #region "New Entry"
                   cons = new Consultation_Booking();
                   
                    cons.Patient_ID = Convert.ToInt32(txtPatient_ID.Text);
                    cons.Created_By = AppConfig.UserID;
                    cons.Created_Time = DateTime.Now;
                    cons.Company_ID = AppConfig.Company_ID;
                    cons.Book_ID = AppConfig.Book_ID;

                    db.Consultation_Bookings.InsertOnSubmit(cons);
                    db.SubmitChanges();
                    con_b_id = cons.Consultation_B_ID;
                   
                   #endregion
                }
               else
               {
                   #region "Edit Entry"
                   con_b_id = Convert.ToInt32(txtConsultation_B_ID.Text);
                   cons = new Consultation_Booking();
                   cons = (from tbl in db.Consultation_Bookings
                           where tbl.Consultation_B_ID == con_b_id
                                 select tbl).SingleOrDefault();

                    

                   cons.Patient_ID = Convert.ToInt32(txtPatient_ID.Text);
                   cons.Updated_By = AppConfig.UserID;
                   cons.Updated_Time = DateTime.Now;

                   ///////Grid Update////////

                   var dtl = (from tbl in db.Consultation_Test_Details
                              where tbl.Consultation_B_ID == con_b_id
                              select tbl);
                   db.Consultation_Test_Details.DeleteAllOnSubmit(dtl);

                   db.SubmitChanges();

                   /////////Grid_2 Update//////////

                   var dtl2 = (from tbl in db.Consultation_Prescribed_Medicine_Details
                               where tbl.Consultation_B_ID == con_b_id
                               select tbl);
                   db.Consultation_Prescribed_Medicine_Details.DeleteAllOnSubmit(dtl2);

                   db.SubmitChanges();

                   #endregion
               }

               cons.Recommended_Test = ddlRecommendedTest.SelectedValue;
               cons.Consultation_Charges = Convert.ToInt32(txtConsultationCharges.Text);
               cons.Consultation_Type = ddlConsultationType.SelectedValue;
               cons.Date = Convert.ToDateTime(txtDate.Text);
               cons.Doctor_Name = ddlDoctorName.SelectedValue;
               cons.Patient_History = txtPatientHistory.Text;
               cons.Doctor_Comment = txtDoctorComment.Text;


               DataRow[] rows = dt.Select();
               for (int i = 0; i < count; i++)
               {
                   string test_Name = Convert.ToString(rows[i]["Test_Name"]);

                   Consultation_Test_Detail tstdtl = new Consultation_Test_Detail();
                   
                   tstdtl.Consultation_B_ID = con_b_id;
                   tstdtl.Test_Name = test_Name;

                   db.Consultation_Test_Details.InsertOnSubmit(tstdtl);
               }

               DataRow[] rows1 = dt1.Select();
               for (int i = 0; i < count1; i++)
               {
                   string medicine_Name = Convert.ToString(rows1[i]["Medicine_Name"]);
                   string no_of_Doses = Convert.ToString(rows1[i]["No_of_Doses"]);
                   string precaution = Convert.ToString(rows1[i]["Precaution"]);
                   string charges = Convert.ToString(rows1[i]["Charges"]);

                   Consultation_Prescribed_Medicine_Detail mdcndtl = new Consultation_Prescribed_Medicine_Detail();

                   mdcndtl.Consultation_B_ID = con_b_id;
                   mdcndtl.Medicine_Name = medicine_Name;
                   mdcndtl.No_of_Doses = Convert.ToInt32(no_of_Doses);
                   mdcndtl.Precaution = precaution;
                   mdcndtl.Charges = Convert.ToInt32(charges);

                   db.Consultation_Prescribed_Medicine_Details.InsertOnSubmit(mdcndtl);
               }

               db.SubmitChanges();
               Response.Redirect("~/ConsultationBookingView.aspx", false);
               lblMessage.CssClass = "SuccessfullMessage";
                //Response.Redirect("~/ConsultationBookingView.aspx");
            }
            catch (Exception exc)
            {
                  lblMessage.CssClass = "errorMessage";
                  lblMessage.Text = exc.Message;
            }

            Blankform();
            #endregion

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
                Session["ConsultationBooking"] = dt;
                ViewState.Remove("check");
                ViewState.Add("check", bol);

                Cleartxt();
                GRD.DataSource = dt;
                GRD.DataBind();
            }

        }

        protected void btnMdcnDelete_Click(object sender, EventArgs e)
        {

            Boolean bol = Convert.ToBoolean(ViewState["check1"]);
            int Index1 = Convert.ToInt32(ViewState["Index1"]);

            if (bol == true)
            {
                bol = false;
                DataRow[] dr = dt1.Select("Index1 = '" + Index1 + "'");
                dt1.Rows.Remove(dr[0]);
                dt1.AcceptChanges();
                Session["ConsultationBooking1"] = dt1;
                ViewState.Remove("check1");
                ViewState.Add("check1", bol);

                Cleartxt_MdcnForm();
                GRD_2.DataSource = dt1;
                GRD_2.DataBind();
            }

        }

        protected void btnNew_Click(object sender, EventArgs e)
        {
            if (Request.QueryString["ID"] != null)
            {
                Response.Redirect("~/ConsultationBooking.aspx", false);
            }

            Blankform();
            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "bindControls", "bindControls();", true);
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            Cleartxt();
        }

        protected void btnMdcnClear_Click(object sender, EventArgs e)
        {
            Cleartxt_MdcnForm();
        }

        

    }
}