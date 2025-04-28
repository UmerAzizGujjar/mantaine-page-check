using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class BloodDonor : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtDonation_Date.Text = DateTime.Now.Date.ToString(AppConfig.DateFormat);
                txtDOB.Text = DateTime.Now.Date.ToString(AppConfig.DateFormat);
                txtExpiryDate.Text = DateTime.Now.Date.ToString(AppConfig.DateFormat);
                txtDateOfLastDonation.Text = DateTime.Now.Date.ToString(AppConfig.DateFormat);                
                BindingDropDown();


                if (Request.QueryString["ID"] != null)
                {
                    PopulateDonorData(Convert.ToInt32(Request.QueryString["ID"]));

                }
            }
        }

        private void BindingDropDown()
        {
            object valueset;
            valueset = DBClass.GetValueSet("Blood Group");
            ddlBlood_Group.DataSource = valueset;
            ddlBlood_Group.DataTextField = "DataValue_Description";
            ddlBlood_Group.DataValueField = "DataValue_Name";
            ddlBlood_Group.Items.Add(new ListItem("Please Select", "0"));
            ddlBlood_Group.DataBind();

            valueset = DBClass.GetValueSet("Gender");
            ddlGender.DataSource = valueset;
            ddlGender.DataTextField = "DataValue_Description";
            ddlGender.DataValueField = "DataValue_Name";
            ddlGender.Items.Add(new ListItem("Please Select", "0"));
            ddlGender.DataBind();
        }

        private void PopulateDonorData(int donor_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            Blood_Donor donor_Obj = (from tbl in db.Blood_Donors
                                     where tbl.Blood_Donor_ID == donor_ID
                                    select tbl).FirstOrDefault();



            if (donor_Obj != null)
            {
                txtBlood_Donor_ID.Text = donor_Obj.Blood_Donor_ID.ToString();
                txtDonor_Name.Text = donor_Obj.Donor_Name;
                ddlBlood_Group.SelectedValue = donor_Obj.Blood_Group;
                txtNo_Of_Bags.Text = donor_Obj.No_Of_Bags.ToString();
                txtDonation_Date.Text = donor_Obj.Donation_Date.Value.ToString(AppConfig.DateFormat);
                txtEmail.Text = donor_Obj.Email;
                txtAddress.Text = donor_Obj.Address;
                txtMobile.Text = donor_Obj.Mobile;
                ddlGender.SelectedValue = donor_Obj.Gender;
                txtDOB.Text = donor_Obj.DOB.Value.ToString(AppConfig.DateFormat);
                txtRemarks.Text = donor_Obj.Remarks;
                hdnDonee_ID.Value = donor_Obj.Donee_Id;                
                txtBlood_Condition.Text = donor_Obj.Blood_Condition;
                ChkBlood_Pre_Sceening.Checked = Convert.ToBoolean(donor_Obj.Blood_Pre_Sceening);
                txtExpiryDate.Text = Convert.ToDateTime(donor_Obj.ExpiryDate).ToString(AppConfig.DateFormat);
                txtFatherName.Text = donor_Obj.Father_Name.ToString();
                txtCNIC.Text = donor_Obj.CNIC.ToString();
                txtOccupation.Text = donor_Obj.Occupation.ToString();
                txtStateOfHealth.Text = donor_Obj.StateOf_Health.ToString();
                txtCenterOfDonation.Text = donor_Obj.CenterOf_Donation.ToString();
                txtDateOfLastDonation.Text = Convert.ToDateTime(donor_Obj.DateOfLast_Donation).ToString(AppConfig.DateFormat);
                txtAge.Text = donor_Obj.Age.ToString();
                if (hdnDonee_ID.Value == "")
                    hdnDonee_ID.Value = "(New)";
                btnSave.Text = "Update";
            }
        }
        private void ClearData()
        {
            txtBlood_Donor_ID.Text = "";
            txtDonor_Name.Text = "";
            ddlBlood_Group.SelectedValue = "0";
            txtNo_Of_Bags.Text = "";
            txtDonation_Date.Text = "";
            txtEmail.Text = "";
            txtAddress.Text = "";
            txtMobile.Text = "";
            ddlGender.SelectedValue = "0";
            txtDOB.Text = "";
            txtRemarks.Text = "";
            hdnDonee_ID.Value = "";
            txtBlood_Condition.Text = "";
            ChkBlood_Pre_Sceening.Checked = false;
            txtExpiryDate.Text = "";
            txtFatherName.Text = "";
            txtCNIC.Text = "";
            txtOccupation.Text = "";
            txtStateOfHealth.Text = "";
            txtCenterOfDonation.Text = "";
            txtDateOfLastDonation.Text = "";
            txtAge.Text = "";
            
                hdnDonee_ID.Value = "(New)";
            btnSave.Text = "Save";
        }

        protected void btnNew_Click(object sender, EventArgs e)
        {
            ClearData();
            Response.Redirect("~/Modules/BloodBank/BloodDonor.aspx", false);
        }
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;

            try
            {
                //if (Page.IsValid)
                //{
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                Blood_Donor donor_Obj = new Blood_Donor();

                if (btnSave.Text == "Save")
                {
                    donor_Obj.Created_By = AppConfig.UserID;
                    donor_Obj.Created_Time = DateTime.Now;
                    donor_Obj.Book_ID = AppConfig.Book_ID;
                    donor_Obj.Company_ID = AppConfig.Company_ID;
                }
                else
                {
                    donor_Obj = (from tbl in db.Blood_Donors
                                 where tbl.Blood_Donor_ID == Convert.ToInt32(Request.QueryString["ID"])
                                 select tbl).FirstOrDefault();

                    donor_Obj.Updated_By = AppConfig.UserID;
                    donor_Obj.Updated_Time = DateTime.Now;
                }

                donor_Obj.Donor_Name = txtDonor_Name.Text;
                donor_Obj.Blood_Group = ddlBlood_Group.SelectedValue;
                donor_Obj.No_Of_Bags = Convert.ToInt32(txtNo_Of_Bags.Text);
                donor_Obj.Donation_Date = Convert.ToDateTime(txtDonation_Date.Text);
                donor_Obj.Email = txtEmail.Text;
                donor_Obj.Address = txtAddress.Text;
                donor_Obj.Mobile = txtMobile.Text;
                donor_Obj.Gender = ddlGender.SelectedValue;
                donor_Obj.DOB = Convert.ToDateTime(txtDOB.Text);
                donor_Obj.Remarks = txtRemarks.Text;
                donor_Obj.Blood_Pre_Sceening = ChkBlood_Pre_Sceening.Checked;
                donor_Obj.Donee_Id = hdnDonee_ID.Value;
                donor_Obj.Blood_Condition = txtBlood_Condition.Text;
                donor_Obj.ExpiryDate = Convert.ToDateTime(txtExpiryDate.Text);

                donor_Obj.Father_Name = txtFatherName.Text;
                donor_Obj.CNIC = txtCNIC.Text.ToString();
                donor_Obj.Occupation = txtOccupation.Text.ToString();                

                donor_Obj.StateOf_Health = txtStateOfHealth.Text;
                donor_Obj.CenterOf_Donation = txtCenterOfDonation.Text.ToString();
                donor_Obj.DateOfLast_Donation = Convert.ToDateTime(txtDateOfLastDonation.Text);
                donor_Obj.Age = Convert.ToInt16(txtAge.Text);


                if (btnSave.Text == "Save")
                {
                    db.Blood_Donors.InsertOnSubmit(donor_Obj);
                    lblMessage.CssClass = "Data Inserted Successfully";

                }
                else
                {
                    lblMessage.CssClass = "Data Updated Successfully";
                }

                db.SubmitChanges();

               
                lblMessage.CssClass = "sucessfullMessage";
            }


            catch (Exception ex)
            {
                throw;
            }
        }


        protected void btnPrint_Click(object sender, EventArgs e)
        {
            string path = @"\ReportViewer.aspx?ReportName=BloodDonorInfo&ReportTitle=Donor History Card&BloodDonor_ID=" + txtBlood_Donor_ID.Text;
            ScriptManager.RegisterStartupScript(this, typeof(string), "", "window.open('" + path + "')", true);
        }

        protected void btnCompatibilityReport_Click(object sender, EventArgs e)
        {
            string path = @"\ReportViewer.aspx?ReportName=BloodDonorCompatibilityReport&BloodDonor_ID=" + txtBlood_Donor_ID.Text;
            ScriptManager.RegisterStartupScript(this, typeof(string), "", "window.open('" + path + "')", true);
        }
    }
}