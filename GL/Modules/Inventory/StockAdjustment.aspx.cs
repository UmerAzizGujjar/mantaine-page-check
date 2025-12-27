using CrystalDecisions.Shared.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class WebForm5 : System.Web.UI.Page
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
                else
                {
                    txtAdustment_date.Text = DateTime.Now.ToString(AppConfig.DateFormat);
                }
            }
        }
        /// <summary>
        ///  Load BranChes Only
        /// </summary>


        [WebMethod]
        public static string calculateStock(string Item_code, string ware_house)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var stock = Convert.ToDecimal(db.GetItemTotalStock(Convert.ToInt64(Item_code), ware_house));
            return Convert.ToString(stock);
        }
        private void BindDropDownList()
        {
            object valueset; 
            valueset = DBClass.GetValueSet("Ware House");
            ddl_Ware_House.DataSource = valueset;
            ddl_Ware_House.DataTextField = "DataValue_Description";
            ddl_Ware_House.DataValueField = "DataValue_Name";
            ddl_Ware_House.Items.Add(new ListItem("Please Select", "0"));
            ddl_Ware_House.DataBind();

            valueset = DBClass.GetValueSet("Reason Needed");
            ddlReasonNeeded.DataSource = valueset;
            ddlReasonNeeded.DataTextField = "DataValue_Description";
            ddlReasonNeeded.DataValueField = "DataValue_Name";
            ddlReasonNeeded.Items.Add(new ListItem("Please Select", "0"));
            ddlReasonNeeded.DataBind();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            lblMessage.Text = "";
            string StockAdjID = "";
            if (!Page.IsValid)
                return;
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            INV_Stock_Adjustment Stock_Adj;
            var hiddenbatch = hdbatch.Value;
            var hiddenDate = hdDate.Value;
            var hiddenallowblank = hdallowblank.Value;
            var getitemcode = "";
            if (hiddenDate == "1" || hiddenbatch == "1")
            {
                ScriptManager.RegisterStartupScript(this, typeof(string), "OPEN_WINDOW", "hiddenVal('" + hiddenDate + "','" + hiddenbatch + "','" + hiddenallowblank + "');", true);
                return;
            }
            decimal qty = 0;
            qty = Convert.ToDecimal(txtQuantity.Text);
            var getbatch = hndcheckbatch.Value;
            var batch = txtBatchNo.Text;
            if (getbatch == "true" && batch == "")
            {
                ScriptManager.RegisterStartupScript(this, typeof(string), "Batch_ALERT", "alert('Please Select Batch This item is Batch Item.');", true);
                return;
            }
            if (qty == 0)
            {
                ScriptManager.RegisterStartupScript(this, typeof(string), "QUANTITY_ALERT", "alert('Quantity must be greater than 0.');", true);
                return;
            }
            if (btnSave.Text == "Save")
            {
                Stock_Adj = new INV_Stock_Adjustment();
                Stock_Adj.Status = "Created";
                Stock_Adj.Adjustment_No = DBClass.GetNewNumber("Adjustment_No", "INV_Stock_Adjustment", "");
                Stock_Adj.Created_By = AppConfig.UserID;
                Stock_Adj.Creation_Time = DateTime.Now;
                Stock_Adj.Company_ID = AppConfig.Company_ID;
                Stock_Adj.Book_ID = AppConfig.Book_ID;
            }
            else
            {
                #region "Edit"
                Stock_Adj = (from tbl in db.INV_Stock_Adjustments
                             where tbl.Adjustment_ID == Convert.ToInt32(txtAdjustment_ID.Text)
                             select tbl).SingleOrDefault();
                Stock_Adj.Updated_By = AppConfig.UserID;
                Stock_Adj.Update_Time = DateTime.Now;
                Stock_Adj.Adjustment_No = Convert.ToInt32(txtAdjustment_ID.Text);
                #endregion
            }
            var itemcodess = txtItem_Code.Text;
            if (btnSave.Text == "Save")
            {
                getitemcode = DBClass.getField("select Item_Code from INV_Items where Item_ID=" + itemcodess);
                Stock_Adj.Item_Code = getitemcode;
                Stock_Adj.Item_Id = txtItem_Code.Text;
            }
            else
            {
                getitemcode = DBClass.getField("select Item_ID from INV_Items where Item_ID=" + itemcodess);
                Stock_Adj.Item_Id = getitemcode;
                Stock_Adj.Item_Code = txtItem_Code.Text;
            }
            Stock_Adj.Reason_Why = ddlReasonNeeded.SelectedValue;
            var itemcode = Stock_Adj.Item_Code;
            if (txtQuantity.Text != "")
                Stock_Adj.Qty = Convert.ToDecimal(txtQuantity.Text);
            if (txtRate.Text != "")
            Stock_Adj.Rate = Convert.ToDecimal(txtRate.Text);
            var Amount = Convert.ToDecimal(txtQuantity.Text) * Convert.ToDecimal(txtRate.Text);
            Stock_Adj.Ware_House = ddl_Ware_House.SelectedValue;
            Stock_Adj.Amount = Convert.ToDecimal(Amount);
            if (txtRemarks.Text != "")
            Stock_Adj.Remarks = txtRemarks.Text;
            var checkbatch = txtBatchNo.Text;
            Stock_Adj.Batch_No = txtBatchNo.Text;
            if (txtAdustment_date.Text != "")
                Stock_Adj.Adjustment_Date = Convert.ToDateTime(txtAdustment_date.Text);
            if (txtExpiredate.Text != "")
                Stock_Adj.Expire_Date = Convert.ToDateTime(txtExpiredate.Text);
            
            if (btnSave.Text == "Save")
            {
                db.INV_Stock_Adjustments.InsertOnSubmit(Stock_Adj);
                lblMessage.Text = "Data has been save successfully";
            }
            else
            {
                lblMessage.Text = "Data has been update successfully";
            }
            db.SubmitChanges();
            StockAdjID = Stock_Adj.Adjustment_ID.ToString();
            lblMessage.CssClass = "sucessfullMessage";
            Response.Redirect("~/Modules/Inventory/StockAdjustment.aspx?ID=" + StockAdjID, true);
        }

        private void FillCustomerForm(int AdjustmentId)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            INV_Stock_Adjustment Stock_adj = new INV_Stock_Adjustment();
            Stock_adj = (from tbl in db.INV_Stock_Adjustments
                         where tbl.Adjustment_ID == AdjustmentId
                         select tbl).FirstOrDefault();
            if (Stock_adj != null)
            {
                var Item_NAme = (from t in db.INV_Items where t.Item_ID == Convert.ToInt32(Stock_adj.Item_Id) select t.Description).FirstOrDefault();
                txtItem_Code.Text = Stock_adj.Item_Code;
                hdfItem_ID.Value = Stock_adj.Item_Id;
                hdfItem_Code.Text = Stock_adj.Item_Code;
                txtAdjustment_ID.Text = AdjustmentId.ToString();
                txtAdustment_date.Text = Convert.ToDateTime(Stock_adj.Adjustment_Date).ToString("dd MMM yy");
                if (Stock_adj.Expire_Date != null)
                {
                    txtExpiredate.Text = Stock_adj.Expire_Date.ToString();
                }
                if (Stock_adj.Batch_No != "")
                {
                    if (Stock_adj.Batch_No == "Non-Batch") Stock_adj.Batch_No = "";
                    txtBatchNo.Text = Stock_adj.Batch_No;
                }
                txtQuantity.Text = Stock_adj.Qty.ToString();
                txtRate.Text = Stock_adj.Rate.ToString();
                txtAmount.Text = Stock_adj.Amount.ToString();
                txtRemarks.Text = Stock_adj.Remarks;
                txt_status.Text = Stock_adj.Status;
                ddlReasonNeeded.SelectedValue = Stock_adj.Reason_Why;
                hdnDescription.Value = Item_NAme;
                if (ddl_Ware_House.Items.FindByValue(Stock_adj.Ware_House) != null)
                    ddl_Ware_House.SelectedValue = Stock_adj.Ware_House;
                btnSave.Text = "Update";
            }
        }
        [WebMethod]
        public static bool UserUnApproveEntryRights()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var userPermissions = (from data in db.aspnet_Users
                                       where data.UserId == AppConfig.UserID
                                       select new
                                       {
                                           data.IsInventoryUnApprove
                                       }).FirstOrDefault();
                bool UnApproveRight = userPermissions?.IsInventoryUnApprove ?? false;
                return UnApproveRight;
            }
        }
        [WebMethod]
        public static bool checkbatch(string batchitem)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var chckbatch = (from data in db.INV_Items
                                       where data.Item_ID == Convert.ToInt32(batchitem)
                                       select new
                                       {
                                           data.IsBatch
                                       }).FirstOrDefault();
                bool batch = chckbatch?.IsBatch ?? false;
                return batch;
            }
        }
        [WebMethod]
        public static string ApproveStock(string Stock_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var user_id = AppConfig.UserID;
            var Details = db.spApproveAdjustment(Convert.ToInt32(Stock_ID), "", user_id);
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string UnApproveStock(string Stock_ID)
        {
            var user_id = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.spUnApproveAdjustment(Convert.ToInt32(Stock_ID),Convert.ToString(user_id));
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static bool UserEntryRights()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var uid = AppConfig.UserID;
                var hasEntryRights = db.Sys_Inv_OrignatorTempelate_Masters
                                   .Join(db.Sys_Inv_OrignatorTempelate_Detail_Forms,
                                         SATM => SATM.OrignatorTempelate_ID,
                                         SATDF => SATDF.OrignatorTempelate_ID,
                                         (SATM, SATDF) => new { SATM, SATDF })
                                   .Join(db.Sys_Inv_OrignatorTempelate_Details,
                                         temp => temp.SATM.OrignatorTempelate_ID,
                                         SATDO => SATDO.OrignatorTempelate_ID,
                                         (temp, SATDO) => new { temp.SATM, temp.SATDF, SATDO })
                                   .Any(temp => temp.SATM.IsActive == true && temp.SATM.IsDeleted == false && temp.SATDF.FormId == 7 && temp.SATDO.UserId == uid);

                return hasEntryRights;
            }
        }
    }
}