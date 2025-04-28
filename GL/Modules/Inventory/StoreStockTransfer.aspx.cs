using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Inventory
{
    public partial class StoreStockTransfer : System.Web.UI.Page
    {
        protected static int lastId = -1;
        Stock stockVm = new Stock();
        Stock_Transfer stockTranfer = new Stock_Transfer();
        Stock_Transfer_Item stockTransferItem = new Stock_Transfer_Item();
        protected void Page_Load(object sender, EventArgs e)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            object valueset;
            valueset = (from a in db.DataValues join v in db.ValueSets on a.ValueSet_ID equals v.ValueSet_ID where v.ValueSet_Name == "Ware House"
                        select new
                        {
                            a.DataValue_Name,
                            a.DataValue_Description
                        }
                ).ToList();
            Select_wareHouseFrom.DataSource = valueset;
            Select_wareHouseFrom.DataTextField = "DataValue_Description";
            Select_wareHouseFrom.DataValueField = "DataValue_Name";
            Select_wareHouseFrom.Items.Add(new ListItem("Please Select", "0"));
            Select_wareHouseFrom.DataBind();

            Select_wareHouseTo.DataSource = valueset;
            Select_wareHouseTo.DataTextField = "DataValue_Description";
            Select_wareHouseTo.DataValueField = "DataValue_Name";
            Select_wareHouseTo.Items.Add(new ListItem("Please Select", "0"));
            Select_wareHouseTo.DataBind();
        }

        [WebMethod]
        public static string getbatchno(string itemid, string warehouse,string transferdate)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = db.spGetItemsPending_Batches(Convert.ToInt64(itemid), warehouse, Convert.ToDateTime(transferdate)).ToList();
            return (new JavaScriptSerializer()).Serialize(query);
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
                                   .Any(temp => temp.SATM.IsActive == true && temp.SATM.IsDeleted == false && temp.SATDF.FormId == 8 && temp.SATDO.UserId == uid);

                return hasEntryRights;
            }
        }
        [WebMethod]
        public static string Approvercvstats(string stockid)
        {
            var user_id = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_approvestocknew(Convert.ToInt32(stockid), user_id);
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string UnApprovercvstats(string stockid)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_Unapprovestocknew(Convert.ToInt32(stockid));
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        //GET available stock
        [WebMethod]
        public static Stock GetStock(string itemCode, string batchNo, string wareHouse)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            Stock st = new Stock();
            int ItemId = Convert.ToInt32(DBClass.getField("select Item_ID from INV_Items where Item_Code='" + itemCode + "'"));
            st.stockAvailable = (decimal)db.GetItemBatchStock(ItemId, batchNo, wareHouse);
            return st;
        }   
        [WebMethod]
        public static string AddStockMain(DateTime stockTransferDate, string wareHouseFrom, string wareHouseTo, string stnStatus, string remarks, string trsnfrstatus)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Stock_Transfer stockTranfer = new Stock_Transfer();
            stockTranfer.Stock_Transfer_No = DBClass.GetNewNumber("Stock_Transfer_No", "Stock_Transfer", "");
            stockTranfer.Stock_Transfer_Date = stockTransferDate;
            stockTranfer.Ware_House_From = wareHouseFrom;
            stockTranfer.Ware_House_To = wareHouseTo;
            stockTranfer.Created_By = AppConfig.UserID;
            stockTranfer.Creation_Time = DateTime.Now;
            stockTranfer.STN_Status = stnStatus;
            stockTranfer.Remarks = remarks;
            stockTranfer.Status = "Created";
            stockTranfer.Transfer_Status = trsnfrstatus;
            db.Stock_Transfers.InsertOnSubmit(stockTranfer);
            db.SubmitChanges();
            lastId = (int)stockTranfer.Stock_Transfer_ID; 
            return "Successfully saved main Stock.";
        }
        [WebMethod]
        public static string AddStockDetails(List<Stock> stk)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Stock_Transfer_Item stockTransferItem;
            if (stk != null)
            {
                foreach (var item in stk)
                {
                    stockTransferItem = new Stock_Transfer_Item();
                    stockTransferItem.Item_Code = item.itemCode;
                    stockTransferItem.Batch_No = item.batchNo;
                    stockTransferItem.Qty = item.quantity;
                    stockTransferItem.Stock_Transfer_ID = lastId;
                    stockTransferItem.Expiry_Date = item.expiryDate;
                    stockTransferItem.Item_Id = Convert.ToInt32(DBClass.getField("Select Item_ID from Inv_items where Item_Code=" + item.itemCode));
                    db.Stock_Transfer_Items.InsertOnSubmit(stockTransferItem);
                    db.SubmitChanges();
                }
                return "Successfully Saved.-" + lastId;
            }
            else
                return "Could not save stock details.";
        }

        [WebMethod]
        public static string UpdateStockDetails(List<Stock> stk)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Stock_Transfer_Item stockTransferItem;
            if (stk != null && stk.Count > 0)
            {
                var stkId = stk[0].stockTransferId;
                lastId = stkId;
                if (stkId != -1)
                {
                    SqlTransaction tranObj = null;
                    SqlConnection con = new SqlConnection(DBClass.ConnectionString());
                    con.Open();
                    tranObj = con.BeginTransaction();
                    try
                    {
                        var skIDitem = (from itm in db.Stock_Transfer_Items where (itm.Stock_Transfer_ID == stkId) select itm.Stock_Transfer_Items_ID).ToList();
                        if (skIDitem.Count > 0)
                        {
                            if (!DBClass.exectueQuery("delete Stock_Transfer_Items where Stock_Transfer_ID =" + stkId, tranObj, con))
                            {
                                if (tranObj != null)
                                {
                                    tranObj.Rollback();
                                    tranObj = null;
                                }
                            }
                        }
                        if (tranObj != null)
                        {
                            tranObj.Commit();
                            foreach (var Stkitem in stk)
                            {
                                stockTransferItem = new Stock_Transfer_Item();
                                stockTransferItem.Item_Code = Stkitem.itemCode;
                                stockTransferItem.Batch_No = Stkitem.batchNo;
                                stockTransferItem.Qty = Stkitem.quantity;
                                stockTransferItem.Stock_Transfer_ID = lastId;
                                stockTransferItem.Expiry_Date = Stkitem.expiryDate;
                                stockTransferItem.Item_Id = Convert.ToInt32(DBClass.getField("Select Item_ID from Inv_items where Item_Code=" + Stkitem.itemCode));
                                db.Stock_Transfer_Items.InsertOnSubmit(stockTransferItem);
                                db.SubmitChanges();
                            }
                            return "Successfully Saved.-" + lastId;
                        }
                        else
                            return "Error";
                    }
                    catch (Exception ex)
                    {
                        if (tranObj != null)
                            tranObj.Rollback();
                        return "Error";
                    }
                }
                else
                    return "Error";
            }
            else
                return "Could not update stock details.";
        }

        [WebMethod]
        public static int GetMax()
        {
            Stock st = new Stock();
            return st.stockTransferNo = DBClass.getMaxEntry_No("Stock_Transfer", "Stock_Transfer_No");
        }
        [WebMethod]
        public static List<Stock> FillStockdetails(int Stock_Transfer_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            List<Stock> stockList = new List<Stock>();
            var query = (from st in db.Stock_Transfers where (st.Stock_Transfer_ID == Stock_Transfer_ID)
                         select new
                         {
                             st.Stock_Transfer_ID,
                             st.Stock_Transfer_Date,
                             st.Ware_House_From,
                             st.Ware_House_To,
                             st.Stock_Transfer_No,
                             st.Remarks,
                             st.Transfer_Status,
                             st.Status,
                         }).ToList();
            var queryItems = (from sti in db.Stock_Transfer_Items where (sti.Stock_Transfer_ID == Stock_Transfer_ID)
                              select new
                              {
                                  sti.Stock_Transfer_Items_ID,
                                  sti.Item_Code,
                                  sti.Batch_No,
                                  sti.Qty,
                                  sti.Expiry_Date,
                                  sti.Amount,
                                  sti.Rate,
                                  sti.Item_Id,
                                  sti.Stock_Transfer_ID
                              }).ToList();
            try
            {
                DateTime date = new DateTime();
                Stock stock;
                string wareHouseFrom = "";
                foreach (var stk in query)
                {
                    stock = new Stock();
                    if (stockList.Count < 1)
                    {
                        stock.stockTransferId = int.Parse(stk.Stock_Transfer_ID.ToString());
                        stock.stockTransferDate = Convert.ToDateTime(stk.Stock_Transfer_Date);
                        stock.wareHouseFrom = stk.Ware_House_From;
                        stock.wareHouseTo = stk.Ware_House_To;
                        stock.stockTransferNo = (int)stk.Stock_Transfer_No;
                        date = stock.stockTransferDate;
                        wareHouseFrom = stk.Ware_House_From;
                        stock.remarks = (!string.IsNullOrEmpty(stk.Remarks)) ? stk.Remarks.ToString() : "";
                        stock.Transfer_Status = stk.Transfer_Status;
                        stockList.Add(stock);
                    }
                }
                foreach (var item in queryItems)
                {
                    stock = new Stock();
                    stock.itemCode = item.Item_Code;
                    stock.batchNo = item.Batch_No;
                    stock.quantity = (int)item.Qty;
                    stock.description = (from itm in db.INV_Items where itm.Item_Code == stock.itemCode select itm.Description).FirstOrDefault();
                    stock.stockAvailable = GetStock(stock.itemCode, stock.batchNo, wareHouseFrom).stockAvailable;
                    stock.expiryDate = (!string.IsNullOrEmpty(item.Expiry_Date)) ? item.Expiry_Date.ToString() : "";
                    stockList.Add(stock);
                }
                return stockList;
            }
            catch (Exception ex)
            {
                return null;
            }
        }
        [WebMethod]
        public static string DeleteStockItem(string itemcode, string batch, string stn, string stId)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Stock_Transfer_Item stkItem = new Stock_Transfer_Item();
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                var skIDitem = (from itm in db.Stock_Transfer_Items where (itm.Batch_No == batch && itm.Item_Code == itemcode && itm.Stock_Transfer_ID == int.Parse(stId)) select itm.Stock_Transfer_Items_ID).FirstOrDefault();
                var deltRow = DBClass.exectueQuery("delete Stock_Transfer_Items where Stock_Transfer_Items_ID =" + skIDitem, tranObj, con);
                tranObj.Commit();
                return "Successfully Deleted";
            }
            catch (Exception ex)
            {
                if (tranObj != null)
                    tranObj.Rollback();
                return "Error";
            }
        }
        [WebMethod]
        public static decimal PerformBatchNoSearch(int ItemId, string wareHouse, string batchNo, string dateTime)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            decimal stockAvailable;
            stockAvailable = (decimal)db.StockTransfer_GetItemBatchStock(ItemId, batchNo, wareHouse);
            return stockAvailable;
        }       
    }
}