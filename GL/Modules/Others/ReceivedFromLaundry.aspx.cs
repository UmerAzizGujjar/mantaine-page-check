using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class ReceivedFromLaundry : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtDate.Text = DateTime.Now.ToString(AppConfig.DateFormat);
                BindingDropDown();

                if (Request.QueryString["ID"] != null)
                {
                    PopulateReceivedFromLaundryData(Convert.ToInt32(Request.QueryString["ID"]));
                }
            }
        }

        public void BindingDropDown()
        {
            object valueset;

            valueset = DBClass.GetValueSet("Laundary Item");
            ddlLaundry_Item.DataSource = valueset;
            ddlLaundry_Item.DataTextField = "DataValue_Description";
            ddlLaundry_Item.DataValueField = "DataValue_Name";
            ddlLaundry_Item.Items.Add(new ListItem("Please Select", "0"));
            ddlLaundry_Item.DataBind();
        }

        private void PopulateReceivedFromLaundryData (int receiving_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            Received_From_Laundry received_From_Laundry = (from tbl in db.Received_From_Laundries
                                                    where tbl.Received_From_Laundry_ID == receiving_ID
                                                    select tbl).FirstOrDefault();

            if (receiving_ID != null)
            {
                txtReceived_From_Laundry_ID.Text = received_From_Laundry.Received_From_Laundry_ID.ToString();
                ddlLaundry_Item.SelectedValue = received_From_Laundry.Laundry_Item;
                txtQuantity.Text = received_From_Laundry.Quantity.ToString();
                txtDate.Text = received_From_Laundry.Date.Value.ToString(AppConfig.DateFormat);

                btnSave.Text = "Update";
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                Received_From_Laundry receivedFromLaundry = new Received_From_Laundry();

                if (btnSave.Text == "Save")
                {
                    receivedFromLaundry.Created_By = AppConfig.UserID;
                    receivedFromLaundry.Created_Time = DateTime.Now;
                    receivedFromLaundry.Book_ID = AppConfig.Book_ID;
                    receivedFromLaundry.Company_ID = AppConfig.Company_ID;
                }
                else
                {
                    receivedFromLaundry = (from tbl in db.Received_From_Laundries
                                         where tbl.Received_From_Laundry_ID == Convert.ToInt32(Request.QueryString["ID"])
                                         select tbl).FirstOrDefault();

                    receivedFromLaundry.Updated_By = AppConfig.UserID;
                    receivedFromLaundry.Updated_Time = DateTime.Now;
                }

                receivedFromLaundry.Laundry_Item = ddlLaundry_Item.SelectedValue;

                if (!string.IsNullOrEmpty(txtQuantity.Text))
                    receivedFromLaundry.Quantity = Convert.ToInt32(txtQuantity.Text);

                if (!string.IsNullOrEmpty(txtDate.Text))
                    receivedFromLaundry.Date = Convert.ToDateTime(txtDate.Text);

                if (btnSave.Text == "Save")
                {
                    db.Received_From_Laundries.InsertOnSubmit(receivedFromLaundry);
                    lblMessage.CssClass = "Data Inserted Successfully";

                }
                else
                {
                    lblMessage.CssClass = "Data Updated Successfully";
                }

                db.SubmitChanges();

                Response.Redirect("~/ReceivedFromLaundryView.aspx", false);
                lblMessage.CssClass = "sucessfullMessage";
            }


            catch (Exception ex)
            {
                throw;
            }
        }
    }
}