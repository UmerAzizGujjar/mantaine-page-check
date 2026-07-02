using CrystalDecisions.Shared.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using static PMS.IssueMedicine;

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
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static string Getbatch_grn(int item_id)
        {
            string data = string.Empty;
            var batchStockListgrn = new List<BatchStock>();
            var batchStockListst = new List<BatchStock>();

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var PICondition = (from sys in db.sys_Parms where sys.Name == "Direct PO ON Purchase Invoice" select sys.Code).FirstOrDefault();

                if (PICondition == "01")
                {
                    var grnResult = (from dv in db.INV_Items
                                     join ds in db.Purchase_Invoice_Details
                                     on dv.Item_ID equals ds.ItemId
                                     where ds.ItemId == item_id
                                     select new
                                     {
                                         BatchNum = ds.BatchNum,
                                         uomqty = Convert.ToInt32(dv.UOM_Qty),
                                     }).ToList();
                    foreach (var batchNum in grnResult)
                    {
                        batchStockListgrn.Add(new BatchStock
                        {
                            BatchNum = batchNum.BatchNum,
                            uomqty = batchNum.uomqty,
                        });
                    }
                }
                else
                {
                    var grnResult = (from dv in db.INV_Items
                                     join ds in db.GRN_Details
                                     on dv.Item_ID equals ds.Item_Id
                                     join gm in db.GRN_Masters on ds.GRNId equals gm.GRN_ID
                                     where ds.Item_Id == item_id
                                     select new
                                     {
                                         BatchNum = ds.BatchNum,
                                         uomqty = ds.UOM_Qty,
                                         GRNNumber = gm.GRN_Num
                                     }).ToList();
                    foreach (var batchNum in grnResult)
                    {
                        batchStockListgrn.Add(new BatchStock
                        {
                            BatchNum = batchNum.BatchNum,
                            uomqty = batchNum.uomqty,
                            ReferenceNumber = batchNum.GRNNumber != null ? batchNum.GRNNumber.ToString() : ""
                        });
                    }
                }

                var stockAdjustmentResult = (from inv in db.INV_Stock_Adjustments
                                             where inv.Item_Id == Convert.ToString(item_id)
                                              && inv.Status == "Approved"
                                             orderby inv.Creation_Time descending
                                             select new
                                             {
                                                 BatchNum = inv.Batch_No,
                                                 AdjustmentNo = inv.Adjustment_No
                                             }).ToList();
                foreach (var batchNum in stockAdjustmentResult)
                {
                    batchStockListst.Add(new BatchStock
                    {
                        BatchNum = batchNum.BatchNum,
                        ReferenceNumber = batchNum.AdjustmentNo != null ? batchNum.AdjustmentNo.ToString() : ""
                    });
                }

                var combinedResult = new
                {
                    GRN_Details = batchStockListgrn,
                    Stock_Adjustment_Details = batchStockListst
                };
                data = new JavaScriptSerializer().Serialize(combinedResult);
            }
            return data;
        }
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
            string gridJson = hdnGridData.Value;
            if (!string.IsNullOrEmpty(gridJson) && gridJson != "[]")
            {
                try
                {
                    var serializer = new JavaScriptSerializer();
                    List<TempStockItem> gridItems = serializer.Deserialize<List<TempStockItem>>(gridJson);

                    if (gridItems != null && gridItems.Count > 0)
                    {
                        SaveGridItems(gridItems);
                        return;
                    }
                }
                catch (Exception ex)
                {
                    lblMessage.Text = "Error reading grid data: " + ex.Message;
                    return;
                }
            }
            if (!Page.IsValid)
                return;

            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            INV_Stock_Adjustment Stock_Adj;

            var hiddenbatch = hdbatch.Value;
            var hiddenDate = hdDate.Value;
            var hiddenallowblank = hdallowblank.Value;
            var batchFromHidden = hdnSelectedBatchValue.Value != null ? hdnSelectedBatchValue.Value.Trim() : "";
            var batchText = txtBatchNo.Text != null ? txtBatchNo.Text.Trim() : "";

            var getitemcode = "";
            if (hiddenDate == "1" || hiddenbatch == "1")
            {
                ScriptManager.RegisterStartupScript(this, typeof(string), "OPEN_WINDOW", "hiddenVal('" + hiddenDate + "','" + hiddenbatch + "','" + hiddenallowblank + "');", true);
                return;
            }

            decimal qty = 0;
            if (!decimal.TryParse(txtQuantity.Text, out qty))
            {
                ScriptManager.RegisterStartupScript(this, typeof(string), "QUANTITY_ALERT", "alert('Invalid Quantity.');", true);
                return;
            }

            var getbatch = hndcheckbatch.Value;

            if (getbatch == "true" && string.IsNullOrWhiteSpace(batchText) && string.IsNullOrWhiteSpace(batchFromHidden))
            {
                ScriptManager.RegisterStartupScript(this, typeof(string), "Batch_ALERT", "alert('Please Select Batch. This item is a Batch Item.');", true);
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

            if (txtQuantity.Text != "")
                Stock_Adj.Qty = Convert.ToDecimal(txtQuantity.Text);

            if (txtRate.Text != "")
                Stock_Adj.Rate = Convert.ToDecimal(txtRate.Text);

            var Amount = Convert.ToDecimal(txtQuantity.Text) * Convert.ToDecimal(txtRate.Text);
            Stock_Adj.Ware_House = ddl_Ware_House.SelectedValue;
            Stock_Adj.Amount = Convert.ToDecimal(Amount);

            if (txtRemarks.Text != "")
                Stock_Adj.Remarks = txtRemarks.Text;
            string finalBatch = string.Empty;
            if (!string.IsNullOrWhiteSpace(batchText))
            {
                finalBatch = batchText;
            }
            else if (!string.IsNullOrWhiteSpace(batchFromHidden))
            {
                finalBatch = batchFromHidden;
            }

            Stock_Adj.Batch_No = finalBatch;

            if (txtAdustment_date.Text != "")
            {
                DateTime dateOnly = Convert.ToDateTime(txtAdustment_date.Text);
                DateTime fullDateTime = dateOnly.Date.Add(DateTime.Now.TimeOfDay);
                Stock_Adj.Adjustment_Date = fullDateTime;
            }

            if (txtExpiredate.Text != "")
                Stock_Adj.Expire_Date = Convert.ToDateTime(txtExpiredate.Text);

            if (btnSave.Text == "Save")
            {
                db.INV_Stock_Adjustments.InsertOnSubmit(Stock_Adj);
                lblMessage.Text = "Data has been saved successfully";
            }
            else
            {
                lblMessage.Text = "Data has been updated successfully";
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
        public static string GetWareHouseCondition()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dept = (from data in db.sys_Parms
                        where data.Name == "WareHouse For Stockadjustment"
                        select
                          data.Code
                        ).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(dept);
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
        [WebMethod]
        public static string ReamrksValidation()
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var Adjustment = (from tbl in db.sys_Parms
                                    where tbl.Name == "Adjustment Remarks"
                                    select tbl.Code)
                              .FirstOrDefault();

                    return Adjustment ?? "01";
                }
            }
            catch (Exception ex)
            {
                return "0";
            }
        }

        public class BatchStock
        {
            public string BatchNum { get; set; }
            public int? uomqty { get; set; }
            public string ReferenceNumber { get; set; }
        }

        public class TempStockItem
        {
            public string ItemId { get; set; }
            public string ItemCode { get; set; }
            public string ItemName { get; set; }
            public string BatchNo { get; set; }
            public string ExpireDate { get; set; }
            public decimal Qty { get; set; }
            public decimal Rate { get; set; }
            public decimal Amount { get; set; }
            public string Warehouse { get; set; }
        }

        private void SaveGridItems(List<TempStockItem> items)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            try
            {
                foreach (var item in items)
                {
                    INV_Stock_Adjustment Stock_Adj = new INV_Stock_Adjustment();

                    Stock_Adj.Status = "Created";

                    
                    Stock_Adj.Adjustment_No = DBClass.GetNewNumber("Adjustment_No", "INV_Stock_Adjustment", "");

                    Stock_Adj.Created_By = AppConfig.UserID;
                    Stock_Adj.Creation_Time = DateTime.Now;
                    Stock_Adj.Company_ID = AppConfig.Company_ID;
                    Stock_Adj.Book_ID = AppConfig.Book_ID;

                    Stock_Adj.Item_Id = item.ItemId;
                    Stock_Adj.Item_Code = item.ItemCode;
                    Stock_Adj.Qty = item.Qty;
                    Stock_Adj.Rate = item.Rate;
                    Stock_Adj.Amount = item.Amount;
                    Stock_Adj.Ware_House = item.Warehouse;
                    Stock_Adj.Batch_No = item.BatchNo;

                    Stock_Adj.Remarks = txtRemarks.Text;
                    Stock_Adj.Reason_Why = ddlReasonNeeded.SelectedValue;

                    if (!string.IsNullOrEmpty(item.ExpireDate))
                        Stock_Adj.Expire_Date = Convert.ToDateTime(item.ExpireDate);

                    if (txtAdustment_date.Text != "")
                    {
                        DateTime dateOnly = Convert.ToDateTime(txtAdustment_date.Text);
                        DateTime fullDateTime = dateOnly.Date.Add(DateTime.Now.TimeOfDay);
                        Stock_Adj.Adjustment_Date = fullDateTime;
                    }

                    db.INV_Stock_Adjustments.InsertOnSubmit(Stock_Adj);
                    
                    db.SubmitChanges();
                }

                lblMessage.Text = "Multiple Items saved successfully";
                lblMessage.CssClass = "sucessfullMessage";

                //var lastSavedId = db.INV_Stock_Adjustments.Max(x => x.Adjustment_ID).ToString();
                Response.Redirect("~/Modules/Inventory/StockAdjustment.aspx" , true);
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Error saving grid items: " + ex.Message;
                lblMessage.CssClass = "errorMessage";
            }
        }
        [WebMethod]
        public static string MultipleBatchValidation()
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var Batch = (from tbl in db.sys_Parms
                                      where tbl.Name == "Multiple Batch Working"
                                      select tbl.Code)
                              .FirstOrDefault();

                    return Batch ?? "01";
                }
            }
            catch (Exception ex)
            {
                return "0";
            }
        }
    }
}