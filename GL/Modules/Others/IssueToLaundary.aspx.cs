using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class IssueToLaundary : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtDate.Text = DateTime.Now.ToString(AppConfig.DateFormat);
                BindingDropDown();

                if (Request.QueryString["ID"] != null)
                {
                    PopulateIssueToLaundaryData(Convert.ToInt32(Request.QueryString["ID"]));
                }
            }
        }

        public void BindingDropDown()
        {
            object valueset;

            valueset = DBClass.GetValueSet("Laundary Item");
            ddlLaundary_Item.DataSource = valueset;
            ddlLaundary_Item.DataTextField = "DataValue_Description";
            ddlLaundary_Item.DataValueField = "DataValue_Name";
            ddlLaundary_Item.Items.Add(new ListItem("Please Select", "0"));
            ddlLaundary_Item.DataBind();
        }

        private void PopulateIssueToLaundaryData(int issuance_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            Issue_To_Laundary issue_To_Lndry = (from tbl in db.Issue_To_Laundaries
                                                where tbl.Issue_To_Laundary_ID == issuance_ID
                                                select tbl).FirstOrDefault();

            if (issuance_ID != null)
            {
                txtIssue_To_Laundary_ID.Text = issue_To_Lndry.Issue_To_Laundary_ID.ToString();
                ddlLaundary_Item.SelectedValue = issue_To_Lndry.Laundary_Item;
                txtQuantity.Text = issue_To_Lndry.Quantity.ToString();
                txtDate.Text = issue_To_Lndry.Date.Value.ToString(AppConfig.DateFormat);

                btnSave.Text = "Update";
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                Issue_To_Laundary issue_To_Laundary = new Issue_To_Laundary();

                if (btnSave.Text == "Save")
                {
                    issue_To_Laundary.Created_By = AppConfig.UserID;
                    issue_To_Laundary.Created_Time = DateTime.Now;
                    issue_To_Laundary.Book_ID = AppConfig.Book_ID;
                    issue_To_Laundary.Company_ID = AppConfig.Company_ID;
                }
                else
                {
                    issue_To_Laundary = (from tbl in db.Issue_To_Laundaries
                                         where tbl.Issue_To_Laundary_ID == Convert.ToInt32(Request.QueryString["ID"])
                                         select tbl).FirstOrDefault();

                    issue_To_Laundary.Updated_By = AppConfig.UserID;
                    issue_To_Laundary.Updated_Time = DateTime.Now;
                }

                issue_To_Laundary.Laundary_Item = ddlLaundary_Item.SelectedValue;

                if (!string.IsNullOrEmpty(txtQuantity.Text))
                issue_To_Laundary.Quantity = Convert.ToInt32(txtQuantity.Text);

                if (!string.IsNullOrEmpty(txtDate.Text))
                issue_To_Laundary.Date = Convert.ToDateTime(txtDate.Text);

                if (btnSave.Text == "Save")
                {
                    db.Issue_To_Laundaries.InsertOnSubmit(issue_To_Laundary);
                    lblMessage.CssClass = "Data Inserted Successfully";

                }
                else
                {
                    lblMessage.CssClass = "Data Updated Successfully";
                }

                db.SubmitChanges();

                Response.Redirect("~/IssueToLaundaryView.aspx", false);
                lblMessage.CssClass = "sucessfullMessage";
            }


            catch (Exception ex)
            {
                throw;
            }
        }
    }
}