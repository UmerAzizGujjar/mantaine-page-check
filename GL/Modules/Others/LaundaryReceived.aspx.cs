using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class LaundaryReceived : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtReceived_Date.Text = DateTime.Now.ToString(AppConfig.DateFormat);
                BindingDropDown();

                if (Request.QueryString["ID"] != null)
                {
                    PopulateLaundaryReceivedData(Convert.ToInt32(Request.QueryString["ID"]));
                }
            }
        }

        public void BindingDropDown()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            object valueset;

            valueset = DBClass.GetValueSet("Laundary From To");
            ddlReceived_From.DataSource = valueset;
            ddlReceived_From.DataTextField = "DataValue_Description";
            ddlReceived_From.DataValueField = "DataValue_Name";
            ddlReceived_From.Items.Add(new ListItem("Please Select", "0"));
            ddlReceived_From.DataBind();

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

        private void PopulateLaundaryReceivedData(int laundary_Received_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            Laundary_Received lndry_Received = (from tbl in db.Laundary_Receiveds
                                                where tbl.Laundary_Received_ID == laundary_Received_ID
                                                select tbl).FirstOrDefault();

            if (lndry_Received != null)
            {
                txtLaundary_Received_ID.Text = lndry_Received.Laundary_Received_ID.ToString();
                ddlReceived_From.SelectedValue = lndry_Received.Received_From;

                if (lndry_Received.Room_No != null && lndry_Received.Room_No != 0)
                    ddlRoom_No.SelectedValue = lndry_Received.Room_No.ToString();

                if (lndry_Received.Ward_No != null && lndry_Received.Ward_No != 0)
                    ddlWard_No.SelectedValue = lndry_Received.Ward_No.ToString();

                ddlLaundary_Item.SelectedValue = lndry_Received.Laundary_Item;
                txtQuantity.Text = lndry_Received.Quantity.ToString();
                txtReceived_Date.Text = lndry_Received.Received_Date.Value.ToString(AppConfig.DateFormat);

                if (lndry_Received.No_Of_Dirty_Clothes > -1 && lndry_Received.No_Of_Dirty_Clothes != null)
                txtNo_Of_Dirty_Clothes.Text = lndry_Received.No_Of_Dirty_Clothes.ToString();

                if (lndry_Received.No_Of_Damaged_Clothes > -1 && lndry_Received.No_Of_Damaged_Clothes != null)
                    txtNo_Of_Damaged_Clothes.Text = lndry_Received.No_Of_Damaged_Clothes.ToString();

                btnSave.Text = "Update";
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                Laundary_Received laundary_Received = new Laundary_Received();

                if (btnSave.Text == "Save")
                {
                    laundary_Received.Created_By = AppConfig.UserID;
                    laundary_Received.Created_Time = DateTime.Now;
                    laundary_Received.Book_ID = AppConfig.Book_ID;
                    laundary_Received.Company_ID = AppConfig.Company_ID;
                }
                else
                {
                    laundary_Received = (from tbl in db.Laundary_Receiveds
                                         where tbl.Laundary_Received_ID == Convert.ToInt32(Request.QueryString["ID"])
                                         select tbl).FirstOrDefault();

                    laundary_Received.Updated_By = AppConfig.UserID;
                    laundary_Received.Updated_Time = DateTime.Now;
                }

                laundary_Received.Received_From = ddlReceived_From.SelectedValue;

                if (ddlRoom_No.SelectedValue != null && ddlRoom_No.SelectedValue != "0")
                {
                    laundary_Received.Room_No = Convert.ToInt32(ddlRoom_No.SelectedValue);
                    laundary_Received.Ward_No = null;
                }

                if (ddlWard_No.SelectedValue != null && ddlWard_No.SelectedValue != "0")
                {
                    laundary_Received.Ward_No = Convert.ToInt32(ddlWard_No.SelectedValue);
                    laundary_Received.Room_No = null;
                }

                laundary_Received.Laundary_Item = ddlLaundary_Item.SelectedValue;
                laundary_Received.Quantity = Convert.ToInt32(txtQuantity.Text);
                laundary_Received.Received_Date = Convert.ToDateTime(txtReceived_Date.Text);

                if (!string.IsNullOrEmpty(txtNo_Of_Dirty_Clothes.Text))
                laundary_Received.No_Of_Dirty_Clothes = Convert.ToInt32(txtNo_Of_Dirty_Clothes.Text);

                if (!string.IsNullOrEmpty(txtNo_Of_Damaged_Clothes.Text))
                laundary_Received.No_Of_Damaged_Clothes = Convert.ToInt32(txtNo_Of_Damaged_Clothes.Text);

                if (btnSave.Text == "Save")
                {
                    db.Laundary_Receiveds.InsertOnSubmit(laundary_Received);
                    lblMessage.CssClass = "Data Inserted Successfully";

                }
                else
                {
                    lblMessage.CssClass = "Data Updated Successfully";
                }

                db.SubmitChanges();

                Response.Redirect("~/LaundaryReceivedView.aspx", false);
                lblMessage.CssClass = "sucessfullMessage";
            }


            catch (Exception ex)
            {
                throw;
            }
        }
    }
}