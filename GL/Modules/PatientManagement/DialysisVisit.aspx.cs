using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class DialysisVisit : System.Web.UI.Page
    {
        DataTable dt;
        DataBaseDataContext db;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtVisit_Date.Text = DateTime.Now.ToString(AppConfig.DateFormat);
                BindingDropDown();
                BlankForm();

                if (Request.QueryString["ID"] != null)
                {
                    PopulateDialysisVisitData(Convert.ToInt32(Request.QueryString["ID"]));
                }
            }
            else
            {
                dt = ViewState["IncludeServices"] as DataTable;
                GRD_SRVC.DataSource = dt;
                GRD_SRVC.DataBind();
            }
        }

        private void ClearService()
        {
            ddlService.SelectedValue = "0";
            btnAddService.Text = "Add Service";
            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "chkService_Select", "chkService_Select();", true);
        }

        public void BlankForm()
        {
            txtDialysis_Visit_ID.Text = "(New)";
            ddlDialysis_Case.SelectedIndex = 0;
            ddlDoctor.SelectedIndex = 0;
            ddlDialysis_Type.SelectedIndex = 0;
            txtPhosphataemia_mg_dl.Text = "";
            txtCalcaemia_mg_dl.Text = "";
            txtDialyzer.Text = "";
            txtBlood_Pressure_mmHg.Text = "";
            txtAllergies.Text = "";
            txtIntradialytic_Problems.Text = "";
            txtSpecial_Needs.Text = "";
            txtVisit_Date.Text = DateTime.Now.ToString(AppConfig.DateFormat);
            
            //Grid part
            btnAddService.Text = "Add Service";
            ddlService.SelectedIndex = 0;

            dt = new DataTable();
            ViewState["IncludeServices"] = dt;
            DataColumn[] keys = new DataColumn[1];
            DataColumn index = new DataColumn("Index", Type.GetType("System.Int32"));
            DataColumn service_Name = new DataColumn("Service_Name", Type.GetType("System.String"));
            DataColumn svc_Name = new DataColumn("Svc_Name", Type.GetType("System.String"));

            dt.Columns.Add(index);
            dt.Columns.Add(service_Name);
            dt.Columns.Add(svc_Name);

            keys[0] = index;
            dt.PrimaryKey = keys;
            GRD_SRVC.DataSource = dt;
            GRD_SRVC.DataBind();
        }

        public void BindingDropDown()
        {
            db = new DataBaseDataContext(DBClass.ConnectionString());

            //List<Dialysis_Case> DialysisCases = new List<Dialysis_Case>();

            var DialysisCases = (from tblDC in db.Dialysis_Cases
                             join tblPT in db.Patients
                             on tblDC.Patient_ID equals tblPT.Patient_ID
                            select new {
                                tblDC.Dialysis_Case_ID,
                                Dialysis_Case_Patient = tblDC.Dialysis_Case_ID + " - " + tblPT.Full_Name
                            }).ToList();

            ddlDialysis_Case.DataSource = DialysisCases;
            ddlDialysis_Case.DataTextField = "Dialysis_Case_Patient";
            ddlDialysis_Case.DataValueField = "Dialysis_Case_ID";
            ddlDialysis_Case.Items.Add(new ListItem("Please Select", "0"));
            ddlDialysis_Case.DataBind();

            var EmpList = (from tblEmp in db.HR_Employees
                           where tblEmp.IsDoctor == true
                           select new
                           {
                               tblEmp.Emp_ID,
                               tblEmp.Emp_Name
                           }).ToList();

            ddlDoctor.DataSource = EmpList;
            ddlDoctor.DataTextField = "Emp_Name";
            ddlDoctor.DataValueField = "Emp_ID";
            ddlDoctor.Items.Add(new ListItem("Please Select", "0"));
            ddlDoctor.DataBind();

            List<Service_Definition> SrvcList = new List<Service_Definition>();
            SrvcList = (from tbl in db.Service_Definitions
                        join tbl2 in db.DataValues on tbl.Service_Type equals tbl2.DataValue_Name
                        join tbl3 in db.ValueSets on tbl2.ValueSet_ID equals tbl3.ValueSet_ID
                        where tbl2.DataValue_Description == "Dialysis"
                        select tbl).ToList();

            ddlService.DataSource = SrvcList;
            ddlService.DataTextField = "Service_Name";
            ddlService.DataValueField = "Service_Definition_ID";
            ddlService.Items.Add(new ListItem("Please Select", "0"));
            ddlService.DataBind();

            object valueset;
            valueset = DBClass.GetValueSet("Dialysis Type");
            ddlDialysis_Type.DataSource = valueset;
            ddlDialysis_Type.DataTextField = "DataValue_Description";
            ddlDialysis_Type.DataValueField = "DataValue_Name";
            ddlDialysis_Type.Items.Add(new ListItem("Please Select", "0"));
            ddlDialysis_Type.DataBind();
        }

        private void PopulateDialysisVisitData(int dialysis_Visit_ID)
        {
            try
            {
                db = new DataBaseDataContext(DBClass.ConnectionString());

                Dialysis_Visit dialysis_Visit = (from tbl in db.Dialysis_Visits
                                                 where tbl.Dialysis_Visit_ID == dialysis_Visit_ID
                                                 select tbl).FirstOrDefault();

                if (dialysis_Visit != null)
                {
                    txtDialysis_Visit_ID.Text = dialysis_Visit.Dialysis_Visit_ID.ToString();
                    ddlDialysis_Case.SelectedValue = dialysis_Visit.Dialysis_Case.ToString();
                    ddlDoctor.SelectedValue = dialysis_Visit.Doctor.ToString();
                    ddlDialysis_Type.SelectedValue = dialysis_Visit.Dialysis_Type;

                    if (dialysis_Visit.Phosphataemia_mg_dl != null)
                        txtPhosphataemia_mg_dl.Text = dialysis_Visit.Phosphataemia_mg_dl.ToString();

                    if (dialysis_Visit.Calcaemia_mg_dl != null)
                        txtCalcaemia_mg_dl.Text = dialysis_Visit.Calcaemia_mg_dl.ToString();

                    txtDialyzer.Text = dialysis_Visit.Dialyzer;

                    if (dialysis_Visit.Blood_Pressure_mmHg != null)
                        txtBlood_Pressure_mmHg.Text = dialysis_Visit.Blood_Pressure_mmHg.ToString();

                    txtAllergies.Text = dialysis_Visit.Allergies;
                    txtIntradialytic_Problems.Text = dialysis_Visit.Intradialytic_Problems;
                    txtSpecial_Needs.Text = dialysis_Visit.Special_Needs;

                    if (dialysis_Visit.Visit_Date != null)
                        txtVisit_Date.Text = dialysis_Visit.Visit_Date.Value.ToString(AppConfig.DateFormat);

                    /////// For Grid Binding ////////

                    var qry = (from tbl in db.Dialysis_Visit_Srvc_Dtls
                               where tbl.Dialysis_Visit_ID == dialysis_Visit_ID
                               select tbl).ToList();

                    Int32 index = 0;
                    dt.Rows.Clear();

                    foreach (var item in qry)
                    {
                        DataRow row = dt.NewRow();

                        row["Index"] = index;
                        row["Service_Name"] = item.Dialysis_Service;
                        string srcv = ddlService.Items.FindByValue(item.Dialysis_Service.ToString()).ToString();
                        row["Svc_Name"] = srcv;
                        dt.Rows.Add(row);
                        index++;
                    }
                    GRD_SRVC.DataSource = dt;
                    GRD_SRVC.DataBind();

                    btnSave.Text = "Update";
                }
            }
            catch (Exception ex)
            {
                lblMessage.CssClass = "errorMessage";
                lblMessage.Text = ex.Message;
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            lblMessage.Text = "";
            db = new DataBaseDataContext();
            int count = dt.Rows.Count;
            int Dialysis_Vst_id = 0;

            try
            {
                Dialysis_Visit dialysisVisit = new Dialysis_Visit();

                if (btnSave.Text == "Save")
                {
                    dialysisVisit.Created_By = AppConfig.UserID;
                    dialysisVisit.Created_Time = DateTime.Now;
                    dialysisVisit.Book_ID = AppConfig.Book_ID;
                    dialysisVisit.Company_ID = AppConfig.Company_ID;

                    db.Dialysis_Visits.InsertOnSubmit(dialysisVisit);
                    db.SubmitChanges();
                    lblMessage.CssClass = "Data Inserted Successfully";
                    Dialysis_Vst_id = dialysisVisit.Dialysis_Visit_ID;
                }
                else
                {
                    Dialysis_Vst_id = Convert.ToInt32(txtDialysis_Visit_ID.Text);
                    dialysisVisit = (from tbl in db.Dialysis_Visits
                                  where tbl.Dialysis_Visit_ID == Convert.ToInt32(Request.QueryString["ID"])
                                  select tbl).FirstOrDefault();

                    dialysisVisit.Updated_By = AppConfig.UserID;
                    dialysisVisit.Updated_Time = DateTime.Now;

                    var Dialysis_Vst_Srvc_Dtl = (from tbl in db.Dialysis_Visit_Srvc_Dtls
                                          where tbl.Dialysis_Visit_ID == Dialysis_Vst_id
                                          select tbl);
                    db.Dialysis_Visit_Srvc_Dtls.DeleteAllOnSubmit(Dialysis_Vst_Srvc_Dtl);

                    db.SubmitChanges();

                    lblMessage.CssClass = "Data Updated Successfully";
                }

                dialysisVisit.Dialysis_Case = Convert.ToInt32(ddlDialysis_Case.SelectedValue);
                dialysisVisit.Doctor = Convert.ToInt32(ddlDoctor.SelectedValue);
                dialysisVisit.Dialysis_Type = ddlDialysis_Type.SelectedValue;

                if (!string.IsNullOrEmpty(txtPhosphataemia_mg_dl.Text))
                    dialysisVisit.Phosphataemia_mg_dl = Convert.ToDecimal(txtPhosphataemia_mg_dl.Text);

                if (!string.IsNullOrEmpty(txtCalcaemia_mg_dl.Text))
                    dialysisVisit.Calcaemia_mg_dl = Convert.ToDecimal(txtCalcaemia_mg_dl.Text);
                
                dialysisVisit.Dialyzer = txtDialyzer.Text;

                if (!string.IsNullOrEmpty(txtBlood_Pressure_mmHg.Text))
                    dialysisVisit.Blood_Pressure_mmHg = Convert.ToDecimal(txtBlood_Pressure_mmHg.Text);

                dialysisVisit.Allergies = txtAllergies.Text;
                dialysisVisit.Intradialytic_Problems = txtIntradialytic_Problems.Text;
                dialysisVisit.Special_Needs = txtSpecial_Needs.Text;

                if (!string.IsNullOrEmpty(txtVisit_Date.Text))
                    dialysisVisit.Visit_Date = Convert.ToDateTime(txtVisit_Date.Text);

                DataRow[] rows = dt.Select();
                for (int i = 0; i < count; i++)
                {
                    int srvc_Name = Convert.ToInt32(rows[i]["Service_Name"]);

                    Dialysis_Visit_Srvc_Dtl dlys_Visit_Srvc_Dtl = new Dialysis_Visit_Srvc_Dtl();

                    dlys_Visit_Srvc_Dtl.Dialysis_Visit_ID = Dialysis_Vst_id;
                    dlys_Visit_Srvc_Dtl.Dialysis_Service = srvc_Name;

                    db.Dialysis_Visit_Srvc_Dtls.InsertOnSubmit(dlys_Visit_Srvc_Dtl);
                }

                db.SubmitChanges();
                Response.Redirect("~/DialysisVisitView.aspx", false);
            }

            catch (Exception exc)
            {
                lblMessage.CssClass = "errorMessage";
                lblMessage.Text = exc.Message;
            }

            BlankForm();
        }

        protected void GRD_SRVC_SelectedIndexChanging(object sender, GridViewSelectEventArgs e)
        {
            Boolean bol = true;
            btnAddService.Text = "Update";
            ViewState.Remove("check");
            ViewState.Add("check", bol);
            Label lblIndex = (Label)GRD_SRVC.Rows[e.NewSelectedIndex].FindControl("lblIndex");
            int Index = Convert.ToInt32(lblIndex.Text);
            ViewState.Add("Index", Index);

            DataRow[] row = dt.Select("Index = '" + Index + "'");
            string svcName = Convert.ToString(row[0]["Service_Name"]);
            //string bloodtestname = Convert.ToString(row[0]["BloodTest_Name"]);

            //txtTestName.Text = testname;
            ddlService.SelectedValue = svcName;

            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "", "bindDate();", true);
            e.NewSelectedIndex = -1;
            e.Cancel = true;
            upServiceForm.Update();
        }

        protected void btnNew_Click(object sender, EventArgs e)
        {
            if (Request.QueryString["ID"] != null)
            {
                Response.Redirect("~/DialysisVisit.aspx", false);
            }

            BlankForm();
            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "", "Combination();", true);
        }

        protected void btnClearService_Click(object sender, EventArgs e)
        {
            ClearService();
        }

        protected void btnAddService_Click(object sender, EventArgs e)
        {
            if (ddlService.SelectedValue == "0")
                return;

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
                    row[0]["Service_Name"] = ddlService.SelectedValue;
                    row[0]["Svc_Name"] = ddlService.SelectedItem.ToString();
                    ViewState.Remove("check");
                    ViewState.Add("check", bol);

                    btnAddService.Text = "Add Test";
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
                    row["Service_Name"] = ddlService.SelectedValue;
                    row["Svc_Name"] = ddlService.SelectedItem.ToString();
                    dt.Rows.Add(row);
                }

                ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "", " bindDate();", true);
                GRD_SRVC.DataSource = dt;
                GRD_SRVC.DataBind();
                ClearService();
            }
            catch (Exception exc)
            {
                lblValidation.Text = exc.Message;
            }
        }

        protected void BtnDeleteService_Click(object sender, EventArgs e)
        {
            Boolean bol = Convert.ToBoolean(ViewState["check"]);
            int Index = Convert.ToInt32(ViewState["Index"]);

            if (bol == true)
            {
                bol = false;
                DataRow[] dr = dt.Select("Index = '" + Index + "'");
                dt.Rows.Remove(dr[0]);
                dt.AcceptChanges();
                ViewState["IncludeServices"] = dt;
                ViewState.Remove("check");
                ViewState.Add("check", bol);

                ClearService();
                GRD_SRVC.DataSource = dt;
                GRD_SRVC.DataBind();
            }
        }
    }
}