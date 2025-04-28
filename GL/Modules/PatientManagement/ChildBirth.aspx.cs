using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class ChildBirth : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "enabledisable", "enabledisable();", true);

            if (!IsPostBack)
            {
                txtDOB.Text = DateTime.Now.Date.ToString(AppConfig.DateFormat);
                txtDischarged_On.Text = DateTime.Now.Date.ToString(AppConfig.DateFormat);
                txtTOB.Text = DateTime.Now.ToShortTimeString();

                BindingDropDown();

                if (Request.QueryString["ID"] != null)
                {
                    PopulateChildData(Convert.ToInt32(Request.QueryString["ID"]));
                }
            }
        }

        public void BindingDropDown()
        {
            object valueset; //declare a single object for all valueset
            valueset = DBClass.GetValueSet("Birth Condition");
            ddlBirth_Condition.DataSource = valueset;
            ddlBirth_Condition.DataTextField = "DataValue_Description";
            ddlBirth_Condition.DataValueField = "DataValue_Name";
            ddlBirth_Condition.Items.Add(new ListItem("Please Select", "0"));
            ddlBirth_Condition.DataBind();
            
            valueset = DBClass.GetValueSet("Physical Condition");
            ddlPhysical_Condition.DataSource = valueset;
            ddlPhysical_Condition.DataTextField = "DataValue_Description";
            ddlPhysical_Condition.DataValueField = "DataValue_Name";
            ddlPhysical_Condition.Items.Add(new ListItem("Please Select", "0"));
            ddlPhysical_Condition.DataBind();

            valueset = DBClass.GetValueSet("Delivery Type");
            ddlDelivery_Type.DataSource = valueset;
            ddlDelivery_Type.DataTextField = "DataValue_Description";
            ddlDelivery_Type.DataValueField = "DataValue_Name";
            ddlDelivery_Type.Items.Add(new ListItem("Please Select", "0"));
            ddlDelivery_Type.DataBind();

            valueset = DBClass.GetValueSet("No. Of Babies");
            ddlNo_Of_Babies.DataSource = valueset;
            ddlNo_Of_Babies.DataTextField = "DataValue_Description";
            ddlNo_Of_Babies.DataValueField = "DataValue_Name";
            ddlNo_Of_Babies.DataBind();

            valueset = DBClass.GetValueSet("Gender");
            ddlBaby1_Gender.DataSource = valueset;
            ddlBaby1_Gender.DataTextField = "DataValue_Description";
            ddlBaby1_Gender.DataValueField = "DataValue_Name";
            ddlBaby1_Gender.Items.Add(new ListItem("Please Select", "0"));
            ddlBaby1_Gender.DataBind();

            valueset = DBClass.GetValueSet("Gender");
            ddlBaby2_Gender.DataSource = valueset;
            ddlBaby2_Gender.DataTextField = "DataValue_Description";
            ddlBaby2_Gender.DataValueField = "DataValue_Name";
            ddlBaby2_Gender.Items.Add(new ListItem("Please Select", "0"));
            ddlBaby2_Gender.DataBind();

            valueset = DBClass.GetValueSet("Gender");
            ddlBaby3_Gender.DataSource = valueset;
            ddlBaby3_Gender.DataTextField = "DataValue_Description";
            ddlBaby3_Gender.DataValueField = "DataValue_Name";
            ddlBaby3_Gender.Items.Add(new ListItem("Please Select", "0"));
            ddlBaby3_Gender.DataBind();

            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            List<HR_Employee> EmpList = new List<HR_Employee>();
            EmpList = (from tbl in db.HR_Employees
                       where tbl.IsDoctor == true
                       select tbl).ToList();

            ddlOperated_By.DataSource = EmpList;
            ddlOperated_By.DataTextField = "Emp_Name";
            ddlOperated_By.DataValueField = "Emp_ID";
            ddlOperated_By.Items.Add(new ListItem("Please Select", "0"));
            ddlOperated_By.DataBind();
        }

        private void PopulateChildData(int child_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            Child_Birth child = (from tbl in db.Child_Births
                                 where tbl.Enrollment_ID == child_ID
                                 select tbl).FirstOrDefault();



            if (child != null)
            {
                txtEnrollment_ID.Text = child.Enrollment_ID.ToString();
                //txtBaby1_Name.Text = child.Baby_Name;
                txtFather_Name.Text = child.Father_Name;
                hdfPatient_ID.Value = child.Mother_Name.ToString();
                txtPatient_ID.Text = child.Mother_Name.ToString();
                txtDOB.Text = child.DOB.Value.ToString(AppConfig.DateFormat);
                txtTOB.Text = child.Time_Of_Birth;
                ddlNo_Of_Babies.SelectedValue = child.No_Of_Babies;
                ddlBaby1_Gender.SelectedValue = child.Baby1_Gender;
                ddlBaby2_Gender.SelectedValue = child.Baby2_Gender;
                ddlBaby3_Gender.SelectedValue = child.Baby3_Gender;
                ddlBirth_Condition.SelectedValue = child.Birth_Condition;
                ddlPhysical_Condition.SelectedValue = child.Physical_Condition;
                ddlOperated_By.SelectedValue = child.Operated_By.ToString();

                if (child.Discharged_On != null)
                txtDischarged_On.Text = child.Discharged_On.Value.ToString(AppConfig.DateFormat);
                
                ddlDelivery_Type.SelectedValue = child.Delivery_Type;

                if (child.Delivery_Charges != null)
                txtDelivery_Charges.Text = child.Delivery_Charges.ToString();

                btnSave.Text = "Update";
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            //if (!Page.IsValid)
            //    return;

            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                Child_Birth child = new Child_Birth();

                if (btnSave.Text == "Save")
                {
                    child.Created_By = AppConfig.UserID;
                    child.Created_Time = DateTime.Now;
                    child.Book_ID = AppConfig.Book_ID;
                    child.Company_ID = AppConfig.Company_ID;
                }
                else
                {
                    child = (from tbl in db.Child_Births
                             where tbl.Enrollment_ID == Convert.ToInt32(Request.QueryString["ID"])
                             select tbl).FirstOrDefault();

                    child.Updated_By = AppConfig.UserID;
                    child.Updated_Time = DateTime.Now;
                }

                //child.Baby_Name = txtBaby_Name.Text;
                child.Father_Name = txtFather_Name.Text;
                child.Mother_Name = Convert.ToInt32(txtPatient_ID.Text);
                child.DOB = Convert.ToDateTime(txtDOB.Text);
                child.Time_Of_Birth = txtTOB.Text;
                child.No_Of_Babies = ddlNo_Of_Babies.SelectedValue;
                child.Baby1_Gender = ddlBaby1_Gender.SelectedValue;
                child.Baby2_Gender = ddlBaby2_Gender.SelectedValue;
                child.Baby3_Gender = ddlBaby3_Gender.SelectedValue;
                child.Birth_Condition = ddlBirth_Condition.SelectedValue;
                child.Physical_Condition = ddlPhysical_Condition.SelectedValue;
                child.Operated_By = Convert.ToInt32(ddlOperated_By.SelectedValue);
                child.Discharged_On = Convert.ToDateTime(txtDischarged_On.Text);
                child.Delivery_Type = ddlDelivery_Type.SelectedValue;

                if (txtDelivery_Charges.Text != "")
                child.Delivery_Charges = Convert.ToDecimal(txtDelivery_Charges.Text);


                if (btnSave.Text == "Save")
                {
                    db.Child_Births.InsertOnSubmit(child);
                    lblMessage.CssClass = "Data Inserted Successfully";

                }
                else
                {
                    lblMessage.CssClass = "Data Updated Successfully";
                }

                db.SubmitChanges();

                Response.Redirect("~/ChildBirthView.aspx", false);
                lblMessage.CssClass = "sucessfullMessage";
            }


            catch (Exception ex)
            {
                throw;
            }
        }
    }
}