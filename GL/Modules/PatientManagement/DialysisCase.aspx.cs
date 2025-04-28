using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class DialysisCase : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtTreatment_From.Text = DateTime.Now.ToString(AppConfig.DateFormat);
                txtTreatment_To.Text = DateTime.Now.ToString(AppConfig.DateFormat);

                if (Request.QueryString["ID"] != null)
                {
                    PopulateDialysisCaseData(Convert.ToInt32(Request.QueryString["ID"]));
                }
            }
        }

        private void PopulateDialysisCaseData(int dialysis_Case_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            Dialysis_Case dialysis_Case = (from tbl in db.Dialysis_Cases
                                            where tbl.Dialysis_Case_ID == dialysis_Case_ID
                                            select tbl).FirstOrDefault();

            if (dialysis_Case != null)
            {
                txtDialysis_Case_ID.Text = dialysis_Case.Dialysis_Case_ID.ToString();
                txtPatient_ID.Text = dialysis_Case.Patient_ID.ToString();
                hdfPatient_ID.Value = dialysis_Case.Patient_ID.ToString();

                if (dialysis_Case.Height_Cm != null)
                    txtHeight_Cm.Text = dialysis_Case.Height_Cm.ToString();

                if (dialysis_Case.Weight_Kg != null)
                    txtWeight_Kg.Text = dialysis_Case.Weight_Kg.ToString();
                
                if (dialysis_Case.Treatment_From != null)
                    txtTreatment_From.Text = dialysis_Case.Treatment_From.Value.ToString(AppConfig.DateFormat);

                if (dialysis_Case.Treatment_To != null)
                    txtTreatment_To.Text = dialysis_Case.Treatment_To.Value.ToString(AppConfig.DateFormat);
                
                txtVisits_Per_Week.Text = dialysis_Case.Visits_Per_Week.ToString();

                if (dialysis_Case.Dialysis_Charges != null)
                    txtDialysis_Charges.Text= dialysis_Case.Dialysis_Charges.ToString();

                btnSave.Text = "Update";
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                Dialysis_Case dialysisCase = new Dialysis_Case();

                if (btnSave.Text == "Save")
                {
                    dialysisCase.Created_By = AppConfig.UserID;
                    dialysisCase.Created_Time = DateTime.Now;
                    dialysisCase.Book_ID = AppConfig.Book_ID;
                    dialysisCase.Company_ID = AppConfig.Company_ID;
                }
                else
                {
                    dialysisCase = (from tbl in db.Dialysis_Cases
                                         where tbl.Dialysis_Case_ID == Convert.ToInt32(Request.QueryString["ID"])
                                         select tbl).FirstOrDefault();

                    dialysisCase.Updated_By = AppConfig.UserID;
                    dialysisCase.Updated_Time = DateTime.Now;
                }

                dialysisCase.Patient_ID = Convert.ToInt32(txtPatient_ID.Text);

                if (!string.IsNullOrEmpty(txtHeight_Cm.Text))
                    dialysisCase.Height_Cm = Convert.ToDecimal(txtHeight_Cm.Text);

                if (!string.IsNullOrEmpty(txtWeight_Kg.Text))
                    dialysisCase.Weight_Kg = Convert.ToDecimal(txtWeight_Kg.Text);

                if (!string.IsNullOrEmpty(txtTreatment_From.Text))
                    dialysisCase.Treatment_From = Convert.ToDateTime(txtTreatment_From.Text);

                if (!string.IsNullOrEmpty(txtTreatment_To.Text))
                    dialysisCase.Treatment_To = Convert.ToDateTime(txtTreatment_To.Text);

                if (!string.IsNullOrEmpty(txtVisits_Per_Week.Text))
                    dialysisCase.Visits_Per_Week = Convert.ToInt32(txtVisits_Per_Week.Text);

                if (!string.IsNullOrEmpty(txtDialysis_Charges.Text))
                    dialysisCase.Dialysis_Charges = Convert.ToDecimal(txtDialysis_Charges.Text);

                if (btnSave.Text == "Save")
                {
                    db.Dialysis_Cases.InsertOnSubmit(dialysisCase);
                    lblMessage.CssClass = "Data Inserted Successfully";
                }
                else
                {
                    lblMessage.CssClass = "Data Updated Successfully";
                }

                db.SubmitChanges();

                Response.Redirect("~/DialysisCaseView.aspx", false);
                lblMessage.CssClass = "sucessfullMessage";
            }


            catch (Exception ex)
            {
                throw;
            }
        }
    }
}