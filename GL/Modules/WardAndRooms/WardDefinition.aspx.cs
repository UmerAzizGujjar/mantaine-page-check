using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class WardDefinition : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindingDropDown();

                if (Request.QueryString["ID"] != null)
                {
                    PopulateWardDefinitionData(Convert.ToInt32(Request.QueryString["ID"]));
                }
            }
        }

        public void BindingDropDown()
        {
            object valueset; //declare a single object for all valueset
            valueset = DBClass.GetValueSet("Patient Main Category");
            ddlDepartment.DataSource = valueset;
            ddlDepartment.DataTextField = "DataValue_Description";
            ddlDepartment.DataValueField = "DataValue_Name";
            ddlDepartment.Items.Add(new ListItem("Please Select", "0"));
            ddlDepartment.DataBind();

            valueset = DBClass.GetValueSet("Ward Type");
         
        }

        private void PopulateWardDefinitionData(int ward_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            Ward_Definition ward_df = (from tbl in db.Ward_Definitions
                                       where tbl.Ward_ID == ward_ID
                                       select tbl).FirstOrDefault();

            if (ward_df != null)
            {
                txtWard_ID.Text = ward_df.Ward_No.ToString();
                txtWard_Type.Text = ward_df.Ward_Type;
                ddlDepartment.SelectedValue = ward_df.Department;
              
               txtNo_Of_Beds.Text = ward_df.No_Of_Beds.ToString();

               
                btnSave.Text = "Update";
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                Ward_Definition ward_df = new Ward_Definition();

                if (btnSave.Text == "Save")
                {
                    ward_df.Created_By = AppConfig.UserID;
                    ward_df.Created_Time = DateTime.Now;
                    ward_df.Book_ID = AppConfig.Book_ID;
                    ward_df.Company_ID = AppConfig.Company_ID;
                    ward_df.Ward_No = Convert.ToString(DBClass.getMaxEntry_No("Ward_Definition", "Ward_No"));
                }
                else
                {
                    ward_df = (from tbl in db.Ward_Definitions
                             where tbl.Ward_ID == Convert.ToInt32(Request.QueryString["ID"])
                             select tbl).FirstOrDefault();

                    ward_df.Updated_By = AppConfig.UserID;
                    ward_df.Updated_Time = DateTime.Now;
                }
               
                ward_df.Ward_Type = txtWard_Type.Text;
                ward_df.Department = ddlDepartment.SelectedValue;
            
                if (txtNo_Of_Beds.Text != "")
                    ward_df.No_Of_Beds = Convert.ToInt32(txtNo_Of_Beds.Text);


                if (btnSave.Text == "Save")
                {
                    db.Ward_Definitions.InsertOnSubmit(ward_df);
                    lblMessage.CssClass = "Data Inserted Successfully";

                }
                else
                {
                    lblMessage.CssClass = "Data Updated Successfully";
                }

                db.SubmitChanges();

                Response.Redirect("WardDefinitionView.aspx", false);
                lblMessage.CssClass = "sucessfullMessage";
            }


            catch (Exception ex)
            {
                throw;
            }
        }
    }
}