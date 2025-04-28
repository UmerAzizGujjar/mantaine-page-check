using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class LaundaryIssuance : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtIssue_Date.Text = DateTime.Now.ToString(AppConfig.DateFormat);
                txtIssue_Time.Text = DateTime.Now.ToShortTimeString();
                BindingDropDown();

                if (Request.QueryString["ID"] != null)
                {
                    PopulateLaundaryIssuanceData(Convert.ToInt32(Request.QueryString["ID"]));
                }
            }
        }

        public void BindingDropDown()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            object valueset;

            valueset = DBClass.GetValueSet("Laundary From To");
            ddlIssue_To.DataSource = valueset;
            ddlIssue_To.DataTextField = "DataValue_Description";
            ddlIssue_To.DataValueField = "DataValue_Name";
            ddlIssue_To.Items.Add(new ListItem("Please Select", "0"));
            ddlIssue_To.DataBind();

            valueset = DBClass.GetValueSet("Laundary Item");
            ddlLaundary_Item.DataSource = valueset;
            ddlLaundary_Item.DataTextField = "DataValue_Description";
            ddlLaundary_Item.DataValueField = "DataValue_Name";
            ddlLaundary_Item.Items.Add(new ListItem("Please Select", "0"));
            ddlLaundary_Item.DataBind();

            List<Room> rooms = (from tbl in db.Rooms
                                select tbl).ToList();

            ddlRoom_No.DataSource = rooms;
            ddlRoom_No.DataTextField = "Room_No";
            ddlRoom_No.DataValueField = "Room_ID";
            ddlRoom_No.Items.Add(new ListItem("Please Select", "0"));
            ddlRoom_No.DataBind();

            var wards = (from tbl2 in db.Ward_Definitions
                         select tbl2).ToList();

            ddlWard_No.DataSource = wards;
            ddlWard_No.DataTextField = "Ward_No";
            ddlWard_No.DataValueField = "Ward_ID";
            ddlWard_No.Items.Add(new ListItem("Please Select", "0"));
            ddlWard_No.DataBind();
        }

        private void PopulateLaundaryIssuanceData(int laundary_Issuance_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            Laundary_Issuance lndry_Issuance = (from tbl in db.Laundary_Issuances
                                           where tbl.Laundary_Issuance_ID == laundary_Issuance_ID
                                           select tbl).FirstOrDefault();

            if (lndry_Issuance != null)
            {
                txtLaundary_Issuance_ID.Text = lndry_Issuance.Laundary_Issuance_ID.ToString();
                ddlIssue_To.SelectedValue = lndry_Issuance.Issue_To;

                if (lndry_Issuance.Room_No != null && lndry_Issuance.Room_No != 0)
                ddlRoom_No.SelectedValue = lndry_Issuance.Room_No.ToString();

                if (lndry_Issuance.Ward_No != null && lndry_Issuance.Ward_No != 0)
                ddlWard_No.SelectedValue = lndry_Issuance.Ward_No.ToString();

                ddlLaundary_Item.SelectedValue = lndry_Issuance.Laundary_Item;
                txtQuantity.Text = lndry_Issuance.Quantity.ToString();
                txtIssue_Date.Text = lndry_Issuance.Issue_Date.Value.ToString(AppConfig.DateFormat);
                txtIssue_Time.Text = lndry_Issuance.Issue_Time;

                btnSave.Text = "Update";
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                Laundary_Issuance laundary_Issuance = new Laundary_Issuance();

                if (btnSave.Text == "Save")
                {
                    laundary_Issuance.Created_By = AppConfig.UserID;
                    laundary_Issuance.Created_Time = DateTime.Now;
                    laundary_Issuance.Book_ID = AppConfig.Book_ID;
                    laundary_Issuance.Company_ID = AppConfig.Company_ID;
                }
                else
                {
                    laundary_Issuance = (from tbl in db.Laundary_Issuances
                                  where tbl.Laundary_Issuance_ID == Convert.ToInt32(Request.QueryString["ID"])
                                  select tbl).FirstOrDefault();

                    laundary_Issuance.Updated_By = AppConfig.UserID;
                    laundary_Issuance.Updated_Time = DateTime.Now;
                }

                laundary_Issuance.Issue_To = ddlIssue_To.SelectedValue;

                if (ddlRoom_No.SelectedValue != null && ddlRoom_No.SelectedValue != "0")
                {
                    laundary_Issuance.Room_No = Convert.ToInt32(ddlRoom_No.SelectedValue);
                    laundary_Issuance.Ward_No = null;
                }

                if (ddlWard_No.SelectedValue != null && ddlWard_No.SelectedValue != "0")
                {
                    laundary_Issuance.Ward_No = Convert.ToInt32(ddlWard_No.SelectedValue);
                    laundary_Issuance.Room_No = null;
                }
                
                laundary_Issuance.Laundary_Item = ddlLaundary_Item.SelectedValue;
                laundary_Issuance.Quantity = Convert.ToInt32(txtQuantity.Text);
                laundary_Issuance.Issue_Date = Convert.ToDateTime(txtIssue_Date.Text);
                laundary_Issuance.Issue_Time = txtIssue_Time.Text;

                if (btnSave.Text == "Save")
                {
                    db.Laundary_Issuances.InsertOnSubmit(laundary_Issuance);
                    lblMessage.CssClass = "Data Inserted Successfully";

                }
                else
                {
                    lblMessage.CssClass = "Data Updated Successfully";
                }

                db.SubmitChanges();

                Response.Redirect("~/LaundaryIssuanceView.aspx", false);
                lblMessage.CssClass = "sucessfullMessage";
            }


            catch (Exception ex)
            {
                throw;
            }
        }
    }
}