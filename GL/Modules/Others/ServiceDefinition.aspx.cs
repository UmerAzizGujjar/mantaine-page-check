using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class ServiceDefinition : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindingDropDown();

                if (Request.QueryString["ID"] != null)
                {
                    PopulateServiceDefinitionData(Convert.ToInt32(Request.QueryString["ID"]));
                }
            }
        }

        public void BindingDropDown()
        {
            object valueset; //declare a single object for all valueset
            valueset = DBClass.GetValueSet("Service Type");
            ddlService_Type.DataSource = valueset;
            ddlService_Type.DataTextField = "DataValue_Description";
            ddlService_Type.DataValueField = "DataValue_Name";
            ddlService_Type.Items.Add(new ListItem("Please Select", "0"));
            ddlService_Type.DataBind();
        }

        private void PopulateServiceDefinitionData(int service_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            Service_Definition service_df = (from tbl in db.Service_Definitions
                                       where tbl.Service_Definition_ID == service_ID
                                       select tbl).FirstOrDefault();

            if (service_df != null)
            {
                txtService_Definition_ID.Text = service_df.Service_Definition_ID.ToString();
                //txtAccount_ID.Text = service_df.Account_ID.ToString();
                hdfAccount_ID.Value = service_df.Account_ID.ToString();
                txtService_Name.Text = service_df.Service_Name;
                ddlService_Type.SelectedValue = service_df.Service_Type;



                //int Accountid = Convert.ToInt32(service_df.Account_ID);

                //var AccQry = (from acc_tbl in db.GL_Accounts
                //              where acc_tbl.Account_ID == Accountid
                //              select acc_tbl).FirstOrDefault();

                //string code = AccQry.Account_Code;
                //string name = AccQry.Account_Name;
                //ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "loadtokenInputsByAccount_ID", "loadtokenInputsByAccount_ID();", true);
                //hdfAccount_Code.Value = code;
                //string Account_CodeAndName = code.Trim() + " - " + name.Trim();
                //string inputString = String.Format(@"id:" + Accountid + @",name: '{0}'", Account_CodeAndName);
                //if (txtAccountName.Text != "")
                //    ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "clearToken", "$('#ctl00_MainContent_txtAccountName').tokenInput('clear');", true);
                //ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "tmp", "$('#ctl00_MainContent_txtAccountName').tokenInput('add', { " + inputString + " });", true);
            


                if (service_df.Service_Charges != null)
                    txtService_Charges.Text = service_df.Service_Charges.ToString();

                btnSave.Text = "Update";
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                Service_Definition srvc_df = new Service_Definition();

                if (btnSave.Text == "Save")
                {
                    srvc_df.Created_By = AppConfig.UserID;
                    srvc_df.Created_Time = DateTime.Now;
                    srvc_df.Book_ID = AppConfig.Book_ID;
                    srvc_df.Company_ID = AppConfig.Company_ID;
                }
                else
                {
                    srvc_df = (from tbl in db.Service_Definitions
                               where tbl.Service_Definition_ID == Convert.ToInt32(Request.QueryString["ID"])
                               select tbl).FirstOrDefault();

                    srvc_df.Updated_By = AppConfig.UserID;
                    srvc_df.Updated_Time = DateTime.Now;
                }

                srvc_df.Account_ID = Convert.ToInt32(txtAccount_ID.Text);
                srvc_df.Service_Name = txtService_Name.Text;
                srvc_df.Service_Type = ddlService_Type.SelectedValue;

                if (!string.IsNullOrEmpty(txtService_Charges.Text))
                    srvc_df.Service_Charges = Convert.ToDecimal(txtService_Charges.Text);

                if (btnSave.Text == "Save")
                {
                    db.Service_Definitions.InsertOnSubmit(srvc_df);
                    lblMessage.CssClass = "Data Inserted Successfully";

                }
                else
                {
                    lblMessage.CssClass = "Data Updated Successfully";
                }

                db.SubmitChanges();

                Response.Redirect("~/ServiceDefinitionView.aspx", false);
                lblMessage.CssClass = "sucessfullMessage";
            }


            catch (Exception ex)
            {
                throw;
            }
        }
    }
}