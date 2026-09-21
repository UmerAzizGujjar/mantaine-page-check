using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Configuration;
using System.Data.SqlClient;

namespace PMS
{
    public partial class WebForm2 : System.Web.UI.Page
    {

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindDropDownList();

                if (Request.QueryString["ID"] != null)
                {
                    FillCustomerForm(Convert.ToInt32(Request.QueryString["ID"]));
                }
            }
        }

        private void BindDropDownList()
        {
            object valueset; //declare a single object for all valueset


            valueset = DBClass.GetValueSet("UOM");
            ddlUnit.DataSource = valueset;
            ddlUnit.DataTextField = "DataValue_Description";
            ddlUnit.DataValueField = "DataValue_Name";
            ddlUnit.Items.Add(new ListItem("Please Select", "0"));
            ddlUnit.DataBind();


            valueset = DBClass.GetValueSet("Item Category");
            ddlMainCatagory.DataSource = valueset;
            ddlMainCatagory.DataTextField = "DataValue_Description";
            ddlMainCatagory.DataValueField = "DataValue_Name";
            ddlMainCatagory.Items.Add(new ListItem("Please Select", "0"));
            ddlMainCatagory.DataBind();

            valueset = DBClass.GetValueSet("Item Type");
            ddlItem_Type.DataSource = valueset;
            ddlItem_Type.DataTextField = "DataValue_Description";
            ddlItem_Type.DataValueField = "DataValue_Name";
            ddlItem_Type.Items.Add(new ListItem("Please Select", "0"));
            ddlItem_Type.DataBind();

            valueset = DBClass.GetValueSet("Manufacturer");
            ddlManufacturer.DataSource = valueset;
            ddlManufacturer.DataTextField = "DataValue_Description";
            ddlManufacturer.DataValueField = "DataValue_Name";
            ddlManufacturer.Items.Add(new ListItem("Please Select", "0"));
            ddlManufacturer.DataBind();
            //valueset = DBClass.GetValueSet("Salt");
            //ddlSalt.DataSource = valueset;
            //ddlSalt.DataTextField = "DataValue_Description";
            //ddlSalt.DataValueField = "DataValue_Name";
            //ddlSalt.Items.Add(new ListItem("Please Select", "0"));
            //ddlSalt.DataBind();

            valueset = DBClass.GetValueSet("Pack Unit");
            ddlPackUnit.DataSource = valueset;
            ddlPackUnit.DataTextField = "DataValue_Description";
            ddlPackUnit.DataValueField = "DataValue_Name";
            ddlPackUnit.Items.Add(new ListItem("Please Select", "0"));
            ddlPackUnit.DataBind();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (chckPack.Checked == true)
            {
                if (txtQuantity.Text == "0" || txtQuantity.Text == "")
                {
                    return;

                }
            }

            lblMessage.Text = "";
            if (!Page.IsValid)
                return;

            

            btnSave.Enabled = false;

            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            INV_Item inv_Item;

            if (btnSave.Text == "Save")
            {
                inv_Item = new INV_Item();

                var snumber = Convert.ToInt32(DBClass.getField("select (isnull(max(convert(int,Item_Code)),0)+1) from INV_Items ").ToString());
                inv_Item.Item_Code = snumber.ToString();
            }
            else
            {
                #region "Edit "

                inv_Item = (from tbl in db.INV_Items
                            where tbl.Item_ID == Convert.ToInt32(hdfItem_Code.Value)
                            select tbl).FirstOrDefault();
                INVItemLogHelper.WriteItemChangeLog(db, inv_Item, new System.Web.Script.Serialization.JavaScriptSerializer());
                inv_Item.Updated_By = AppConfig.UserID;
                inv_Item.Updated_Time = DateTime.Now;

                #endregion

            }

            if (txtDescription.Text != "")
                inv_Item.Description = txtDescription.Text;

            

            if (txtSales_Rate.Text != "")
                inv_Item.Sale_Rate = Convert.ToDecimal(txtSales_Rate.Text);

            if (txtPurchase_Rate.Text != "")
                inv_Item.Purchase_Rate = Convert.ToDecimal(txtPurchase_Rate.Text);

            if (TxtNotes.Text != "")
                inv_Item.Notes = TxtNotes.Text;

            if (ddlItem_Type.SelectedValue != "")
                inv_Item.Item_Type = ddlItem_Type.SelectedValue;

            if (ddlMainCatagory.SelectedValue != "")
                inv_Item.Item_Category = ddlMainCatagory.SelectedValue;

            if (ddlSalt.Text != "")
                inv_Item.Salt = ddlSalt.Text;

            if (ddlUnit.SelectedValue != "")
                inv_Item.Unit = ddlUnit.SelectedValue;

            if (txtMinimum_Stock.Text != "")
                inv_Item.Mini_Stock = txtMinimum_Stock.Text;

            if (txtMaximum_Stock.Text != "")
                inv_Item.Max_Stock = txtMaximum_Stock.Text;

            if (txtReorder_Stock.Text != "")
                inv_Item.Reorder_Stock = txtReorder_Stock.Text;
            if (txtATC.Text != "")
                inv_Item.ATC = txtATC.Text;
            if (ddlManufacturer.SelectedValue != "")
                inv_Item.Manufacturer_Name = ddlManufacturer.SelectedValue;
            inv_Item.Is_Active = chckActive.Checked;
            inv_Item.Refigrator = chckRefigrator.Checked;
            inv_Item.Infusion_Fluid = Checkinfs.Checked;
            inv_Item.Additive_Dose = Checkadd.Checked;
            if (chckPack.Checked == true)
            {
                if (ddlPackUnit.SelectedValue != "")
                    inv_Item.Pack_Unit = ddlPackUnit.SelectedValue;

                if (txtQuantity.Text != "")
                    inv_Item.Pack_Quantity =Convert.ToInt32(txtQuantity.Text);

                inv_Item.Pack = chckPack.Checked;
            }         
            else
            {

                inv_Item.Pack_Unit = "0";


                inv_Item.Pack_Quantity = 0;

                inv_Item.Pack = false;
            }
           // inv_Item.Services = chkPallor.Checked;
            //inv_Item.LabOR_RadiologyCharges = chkLaborRadiologyCharges.Checked;
            //inv_Item.Liability_Item = chkLiabilityItem.Checked;
           // inv_Item.Physio_Item = chkPhysioItem.Checked;
           // inv_Item.Dental_Item = chkDentalItem.Checked;
           // inv_Item.Derma_Item = chkDermaItem.Checked;
            inv_Item.Pharmacy_Item = true;
            inv_Item.Created_By = AppConfig.UserID;
            inv_Item.Created_Time = DateTime.Now;
            inv_Item.Book_ID = AppConfig.Book_ID;
            inv_Item.Company_ID = AppConfig.Company_ID;
            if (btnSave.Text == "Save")
            {
                db.INV_Items.InsertOnSubmit(inv_Item);
                lblMessage.Text = "Data has been save successfully";
            }
            else
            {
                lblMessage.Text = "Data has been update successfully";
            }


            db.SubmitChanges();
            lblMessage.CssClass = "sucessfullMessage";
            Response.Redirect("~/Inventory/MedicineView.aspx", true);
      
            //Response.Redirect("~/inventory/PharmacyItems.aspx?ID=" + inv_Item.Item_ID);
        }

        private void FillCustomerForm(int ItemCode)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            INV_Item inv_item = new INV_Item();

            inv_item = (from tbl in db.INV_Items
                        where tbl.Item_ID == ItemCode
                        select tbl).FirstOrDefault();

            if (inv_item != null)
            {
                hdfItem_Code.Value = ItemCode.ToString();

                txtItem_Code.Text = inv_item.Item_Code.ToString();
               // chkLiabilityItem.Checked = inv_item.Liability_Item.Value;
                txtDescription.Text = inv_item.Description;
                //txtManufacture_Part_No.Text = inv_item.Manufacture_Part_No;

                if (inv_item.Sale_Rate != null)
                    txtSales_Rate.Text = inv_item.Sale_Rate.ToString();

                if (inv_item.Purchase_Rate != null)
                    txtPurchase_Rate.Text = inv_item.Purchase_Rate.ToString();

                if (inv_item.Notes != null)
                    TxtNotes.Text = inv_item.Notes.ToString();

                ddlItem_Type.SelectedValue = inv_item.Item_Type;
                ddlMainCatagory.SelectedValue = inv_item.Item_Category;
                if (ddlManufacturer.SelectedValue != null)
                ddlManufacturer.SelectedValue = inv_item.Manufacturer_Name;
                ddlSalt.Text = inv_item.Salt;
                ddlUnit.SelectedValue = inv_item.Unit;
                txtMinimum_Stock.Text = inv_item.Mini_Stock;
                txtMaximum_Stock.Text = inv_item.Max_Stock;
                txtReorder_Stock.Text = inv_item.Reorder_Stock;
                txtATC.Text = inv_item.ATC;
                chckPack.Checked = Convert.ToBoolean(inv_item.Pack);
                ddlPackUnit.SelectedValue = inv_item.Pack_Unit;
                txtQuantity.Text = inv_item.Pack_Quantity.ToString();        
                chckActive.Checked = Convert.ToBoolean(inv_item.Is_Active);
                chckRefigrator.Checked = Convert.ToBoolean(inv_item.Refigrator);
                Checkinfs.Checked = Convert.ToBoolean(inv_item.Infusion_Fluid);
                Checkadd.Checked = Convert.ToBoolean(inv_item.Additive_Dose);

                //chkPallor.Checked = Convert.ToBoolean(inv_item.Services);
                // chkPhysioItem.Checked = inv_item.Physio_Item.Value;
                //chkPharmacyItem.Checked = inv_item.Pharmacy_Item.Value;
                //chkDentalItem.Checked = inv_item.Dental_Item.Value;
                // chkDermaItem.Checked = inv_item.Derma_Item.Value;
                // chkLaborRadiologyCharges.Checked = inv_item.LabOR_RadiologyCharges.Value;
                btnSave.Text = "Update";
             

            }
        }

        

    }
}