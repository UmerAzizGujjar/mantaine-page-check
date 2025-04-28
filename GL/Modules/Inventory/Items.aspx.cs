using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.Services;
using System.Web.Script.Serialization;

namespace PMS
{
    public partial class Items : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindDropDownList();
                BindDropDowns();
                BindManufacDropDownList();
                BindPackDropDownList();

                if (Request.QueryString["ID"] != null)
                {
                    FillCustomerForm(Convert.ToInt32(Request.QueryString["ID"]));
                }
            }
        }

        private void BindDropDownList()
        {
            object valueset; //declare a single object for all valueset   
            valueset = DBClass.GetValueSet("Procedure Types");
            ddlProcedureTypes.DataSource = valueset;
            ddlProcedureTypes.DataTextField = "DataValue_Description";
            ddlProcedureTypes.DataValueField = "DataValue_Name";
            ddlProcedureTypes.Items.Add(new ListItem("Please Select", "0"));
            ddlProcedureTypes.DataBind();
        }

        private void BindManufacDropDownList()
        {
            object valueset; //declare a single object for all valueset   
            valueset = DBClass.GetValueSet("Manufacture Company");
            ddlmanu.DataSource = valueset;
            ddlmanu.DataTextField = "DataValue_Description";
            ddlmanu.DataValueField = "DataValue_Name";
            ddlmanu.Items.Add(new ListItem("Please Select", "0"));
            ddlmanu.DataBind();
        }

        private void BindPackDropDownList()
        {
            object valueset; //declare a single object for all valueset   
            valueset = DBClass.GetValueSet("UOM");
            ddlpack_unit.DataSource = valueset;
            ddlpack_unit.DataTextField = "DataValue_Description";
            ddlpack_unit.DataValueField = "DataValue_Name";
            ddlpack_unit.Items.Add(new ListItem("Please Select", "0"));
            ddlpack_unit.DataBind();
        }


        protected void btnSave_Click(object sender, EventArgs e)
        {
            lblMessage.Text = "";
            if (!Page.IsValid)
                return;

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
                inv_Item.Updated_By = AppConfig.UserID;
                inv_Item.Updated_Time = DateTime.Now;

                #endregion

            }

            if (txtDescription.Text != "")

                inv_Item.Description = txtDescription.Text;

            if (txtManufacture_Part_No.Text != "")

                inv_Item.Manufacture_Part_No = txtManufacture_Part_No.Text;

            if (txtSales_Rate.Text != "")

                inv_Item.Sale_Rate = Convert.ToDecimal(txtSales_Rate.Text);

            if (TxtNotes.Text != "")

                inv_Item.Notes = TxtNotes.Text;
            inv_Item.Services = chkPallor.Checked;

            inv_Item.LabOR_RadiologyCharges = chkLaborRadiologyCharges.Checked;

            inv_Item.Liability_Item = chkLiabilityItem.Checked;

            inv_Item.Physio_Item = chkPhysioItem.Checked;
            inv_Item.Dental_Item = chkDentalItem.Checked;
            inv_Item.Hospital_Services = chkHospital_services.Checked;
          
            inv_Item.Derma_Item = chkDermaItem.Checked;
            inv_Item.IsBill_Item = ChkBillingItem.Checked;
            inv_Item.OTProcedure = chkOTProcedure.Checked;
            inv_Item.Created_By = AppConfig.UserID;
            inv_Item.Created_Time = DateTime.Now;
            inv_Item.Book_ID = AppConfig.Book_ID;
            inv_Item.Company_ID = AppConfig.Company_ID;
            inv_Item.Procedure_types = ddlProcedureTypes.SelectedValue;
            inv_Item.Payment = chkPayment.Checked;
            inv_Item.Expensive_Medicine = chkExpensiveMedicine.Checked;
            inv_Item.Infusion_Fluid = chkInfusion_Fluid.Checked;
            inv_Item.Additive_Dose = chkAdditive_Dose.Checked;
            inv_Item.Special_Test = chkSpecialTest.Checked;
            inv_Item.Item_Account_category = Convert.ToInt32(ddlfiance_integration.SelectedValue.ToString());

            inv_Item.IsPharmacyItem = CheckPharmacy.Checked;
            var medicines = inv_Item.IsPharmacyItem;

            if (medicines == false || medicines == null)
            {
               // inv_Item.Pharmacy_Item = true;

                if (inv_Item.Services == false)
                    inv_Item.Pharmacy_Item = true;
                else
                    inv_Item.Pharmacy_Item = false;

            }
            else
            {
                //inv_Item.IsPharmacyItem = CheckPharmacy.Checked;
            }




            inv_Item.Controller_Drug = controller_drug.Checked;
            inv_Item.Narcotics = Narcotics.Checked;
            inv_Item.Refregrator = Refregrator.Checked;
            inv_Item.Generic_Name = GenericName.Text;
            inv_Item.IsBatch = IsBatch.Checked;
            inv_Item.ATC = ATC.Text;
            inv_Item.Manufacturer_Name = ddlmanu.SelectedValue;
            inv_Item.UOM_Qty =Convert.ToDecimal( txt_UOMQty.Text);
            inv_Item.Unit = ddlpack_unit.SelectedValue;
            inv_Item.Active = true;
            if (Minimum_Stock.Text != "")
                inv_Item.Mini_Stock = Minimum_Stock.Text;
            if (Reorder_Stock.Text != "")
                inv_Item.Reorder_Stock = Reorder_Stock.Text;
            if (Maximum_Stock.Text != "")
                inv_Item.Max_Stock = Maximum_Stock.Text;
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
            Response.Redirect("~/inventory/Items.aspx?ID=" + inv_Item.Item_ID);
        }
        public void BindDropDowns()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var accountcategory = (from p in db.Account_Categories
                                   select new
                                   {
                                       p.Account_Category_Id,
                                       p.CategoryName

                                   }).ToList();
            //object valueset;

           // valueset = DBClass.GetValueSet("Patient Main Category");
            ddlfiance_integration.DataSource = accountcategory;
            ddlfiance_integration.DataTextField = "CategoryName";
            ddlfiance_integration.DataValueField = "Account_Category_Id";
            ddlfiance_integration.Items.Add(new ListItem("Please Select", "0"));
          //  ddlfiance_integration.Items.Add(new ListItem("All Departments", "All_Departments"));
            ddlfiance_integration.DataBind();
        }

        [WebMethod]
        public static string getAccountCategory()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var accountcategory = (from p in db.Account_Categories
                                   select new
                                   {
                                       p.Account_Category_Id,
                                       p.CategoryName

                                   }).ToList();
            return (new JavaScriptSerializer()).Serialize(accountcategory);


        }
        [WebMethod]
        public static string CheckAccount(string ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.SP_CheckAssetAccounts(Convert.ToInt32(ID)).ToList();
            return (new JavaScriptSerializer()).Serialize(Details);
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
                if (inv_item.Liability_Item != null)
                    chkLiabilityItem.Checked = inv_item.Liability_Item.Value;
                txtDescription.Text = inv_item.Description;
                txtManufacture_Part_No.Text = inv_item.Manufacture_Part_No;

                if (inv_item.Sale_Rate != null)
                    txtSales_Rate.Text = inv_item.Sale_Rate.ToString();

                if (inv_item.Notes != null)
                    TxtNotes.Text = inv_item.Notes.ToString();

                if (inv_item.Expensive_Medicine != null)
                    chkExpensiveMedicine.Checked = inv_item.Expensive_Medicine.Value;

                if (inv_item.Payment != null)
                    chkPayment.Checked = inv_item.Payment.Value;

                chkPallor.Checked = Convert.ToBoolean(inv_item.Services);
                if (inv_item.Physio_Item != null)
                    chkPhysioItem.Checked = inv_item.Physio_Item.Value;
                if (inv_item.Dental_Item != null)
                    chkDentalItem.Checked = inv_item.Dental_Item.Value;
                if (inv_item.IsBill_Item != null)
                    ChkBillingItem.Checked = inv_item.IsBill_Item.Value;

                if (inv_item.Infusion_Fluid != null)
                    chkInfusion_Fluid.Checked = Convert.ToBoolean(inv_item.Infusion_Fluid);
                if (inv_item.Additive_Dose != null)
                    chkAdditive_Dose.Checked = Convert.ToBoolean(inv_item.Additive_Dose);
                if(inv_item.Special_Test != null)
                    chkSpecialTest.Checked = Convert.ToBoolean(inv_item.Special_Test);
                if (inv_item.IsPharmacyItem != null)
                   CheckPharmacy.Checked = Convert.ToBoolean(inv_item.IsPharmacyItem);



                //RLMC
                //if (inv_item.IsPharmacyItem != null)
                //    CheckPharmacy.Checked = Convert.ToBoolean(inv_item.IsPharmacyItem);



                if (inv_item.Controller_Drug != null)
                    controller_drug.Checked = Convert.ToBoolean(inv_item.Controller_Drug);
                if (inv_item.Narcotics != null)
                    Narcotics.Checked = Convert.ToBoolean(inv_item.Narcotics);
                if (inv_item.Refregrator != null)
                    Refregrator.Checked = Convert.ToBoolean(inv_item.Refregrator);
                if (inv_item.Generic_Name != null)
                    GenericName.Text = Convert.ToString(inv_item.Generic_Name);

                if (inv_item.Mini_Stock != null)
                    Minimum_Stock.Text = Convert.ToString(inv_item.Mini_Stock);
                if (inv_item.Reorder_Stock != null)
                    Reorder_Stock.Text = Convert.ToString(inv_item.Reorder_Stock);
                if (inv_item.Max_Stock != null)
                    Maximum_Stock.Text = Convert.ToString(inv_item.Max_Stock);


                if (inv_item.IsBatch != null)
                {
                    IsBatch.Checked = Convert.ToBoolean(inv_item.IsBatch);
                }


                if (inv_item.ATC != null)
                    ATC.Text = Convert.ToString(inv_item.ATC);
                if (inv_item.Manufacturer_Name != null)
                    ddlmanu.SelectedValue = Convert.ToString(inv_item.Manufacturer_Name);
                if (inv_item.Item_Account_category != null)
                    ddlfiance_integration.SelectedValue = Convert.ToString(inv_item.Item_Account_category);
                if (inv_item.UOM_Qty != null)
                    txt_UOMQty.Text = Convert.ToString(inv_item.UOM_Qty);
                if (inv_item.Unit != null)
                    ddlpack_unit.SelectedValue = Convert.ToString(inv_item.Unit);


                //  inv_Item.UOM_Qty = Convert.ToDecimal(txt_UOMQty.Text);
                //  inv_Item.Unit = txt_UOMQty.Text;
                if (inv_item.Hospital_Services != null)
                    chkHospital_services.Checked = inv_item.Hospital_Services.Value;
                if (inv_item.Derma_Item != null)
                    chkDermaItem.Checked = inv_item.Derma_Item.Value;
                if (inv_item.LabOR_RadiologyCharges != null)
                    chkLaborRadiologyCharges.Checked = inv_item.LabOR_RadiologyCharges.Value;
                if (inv_item.OTProcedure != null)
                    chkOTProcedure.Checked = inv_item.OTProcedure.Value;
                if (inv_item.Procedure_types != null)
                    ddlProcedureTypes.SelectedValue = inv_item.Procedure_types;
                btnSave.Text = "Update";

            }
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/inventory/ItemsView.aspx", true);
        }

        protected void btnNew_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/inventory/Items.aspx", true);
        }

        protected void btnPharmacy_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/PharmacyItemsView.aspx", true);
        }
    }
}