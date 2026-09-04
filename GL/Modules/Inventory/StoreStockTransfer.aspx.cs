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
            DateTime date = Convert.ToDateTime(transferdate);
            DateTime endDate = date.Date.AddDays(1).AddMilliseconds(-1);
            var query = db.spGetItemsPending_Batches(Convert.ToInt64(itemid), warehouse, endDate).ToList();
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
        public static string AddStockMain(DateTime stockTransferDate, string wareHouseFrom, string wareHouseTo, string stnStatus, string remarks, string trsnfrstatus, int grnId)
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
            stockTranfer.GRN_ID = grnId > 0 ? (int?)grnId : null;
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
                    stockTransferItem.Rate = item.Rate;
                    stockTransferItem.Amount = item.Amount;
                    stockTransferItem.Stock_Transfer_ID = lastId;
                    stockTransferItem.Expiry_Date = item.expiryDate;
                    stockTransferItem.Item_Id = Convert.ToInt32(DBClass.getField("Select Item_ID from Inv_items where Item_Code=" + item.itemCode));
                    if (item.grnDetailId > 0)
                        stockTransferItem.GRN_Detail_ID = item.grnDetailId;
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
                                stockTransferItem.Rate = Stkitem.Rate;
                                stockTransferItem.Amount = Stkitem.Amount;
                                stockTransferItem.Stock_Transfer_ID = lastId;
                                stockTransferItem.Expiry_Date = Stkitem.expiryDate;
                                stockTransferItem.Item_Id = Convert.ToInt32(DBClass.getField("Select Item_ID from Inv_items where Item_Code=" + Stkitem.itemCode));
                                if (Stkitem.grnDetailId > 0)
                                    stockTransferItem.GRN_Detail_ID = Stkitem.grnDetailId;
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
                             st.GRN_ID
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
                                  sti.Stock_Transfer_ID,
                                  sti.GRN_Detail_ID
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
                        stock.grnId = stk.GRN_ID ?? 0;
                        stockList.Add(stock);
                    }
                }
                foreach (var item in queryItems)
                {
                    stock = new Stock();
                    stock.itemCode = item.Item_Code;
                    stock.batchNo = item.Batch_No;
                    stock.quantity = (int)item.Qty;
                    stock.Rate = item.Rate ?? 0;
                    stock.Amount = item.Amount ?? 0;
                    stock.description = (from itm in db.INV_Items where itm.Item_Code == stock.itemCode select itm.Description).FirstOrDefault();
                    stock.stockAvailable = GetStock(stock.itemCode, stock.batchNo, wareHouseFrom).stockAvailable;
                    stock.expiryDate = (!string.IsNullOrEmpty(item.Expiry_Date)) ? item.Expiry_Date.ToString() : "";
                    stock.grnDetailId = item.GRN_Detail_ID ?? 0;
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
        public static string GRNWorking()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var GRN = (from data in db.sys_Parms
                        where data.Name == "Stock Transfer GRN Working"
                        select
                          data.Code
                        ).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(GRN);
        }
        //[WebMethod]
        //public static decimal PerformBatchNoSearch(int ItemId, string wareHouse, string batchNo, string dateTime)
        //{
        //    DataBaseDataContext db = new DataBaseDataContext();
        //    decimal stockAvailable;
        //    decimal Item_Rate;
        //    stockAvailable = (decimal)db.StockTransfer_GetItemBatchStock(ItemId, batchNo, wareHouse);
        //    Item_Rate = (decimal)db.GetCGSAmounts(ItemId, wareHouse, batchNo);
        //    return stockAvailable;
        //}       
        [WebMethod]
        public static string PerformBatchNoSearch(int ItemId, string wareHouse, string batchNo, string dateTime)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            decimal stockAvailable = Convert.ToDecimal(db.StockTransfer_GetItemBatchStock(ItemId, batchNo, wareHouse));
            decimal itemRate = Convert.ToDecimal(db.GetCGSAmounts(ItemId, wareHouse, batchNo));

            var result = new
            {
                StockAvailable = stockAvailable,
                ItemRate = itemRate
            };

            JavaScriptSerializer js = new JavaScriptSerializer();
            return js.Serialize(result);
        }

        [WebMethod]
        public static bool CheckSTORESTOCKTRANSFERApprovalRights()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var form_id = 8;
                var user_id = AppConfig.UserID;

                return (from SASD in db.Sys_Approval_Stage_Details
                        join SASM in db.Sys_Approval_Stage_Masters on SASD.Stage_ID equals SASM.Stage_ID
                        join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                        join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATD.Tempelate_ID equals SATF.Tempelate_ID
                        join SATM in db.Sys_Approval_Tempelate_Masters on SATD.Tempelate_ID equals SATM.Tempelate_ID
                        where SASD.UserId == user_id && SATF.FormId == form_id && SATM.IsActive == true && SASM.IsDeleted == false
                        select SASD).Any();
            }
        }

        [WebMethod]
        public static string GetSTORESTOCKTRANSFERApprovalInfo(string StockTransferId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var stId = Convert.ToInt32(StockTransferId);
                var user_id = AppConfig.UserID;
                var form_id = 8;

                var maxApprovalLimit = db.ExecuteQuery<decimal?>(
                    "SELECT MAX(SASD.MaxApprovalLimit) " +
                    "FROM Sys_Approval_Stage_Detail SASD " +
                    "INNER JOIN Sys_Approval_Stage_Master SASM ON SASD.Stage_ID = SASM.Stage_ID " +
                    "INNER JOIN Sys_Approval_Tempelate_Detail_Stages SATD ON SASM.Stage_ID = SATD.StageId " +
                    "INNER JOIN Sys_Approval_Tempelate_Detail_Forms SATF ON SATD.Tempelate_ID = SATF.Tempelate_ID " +
                    "INNER JOIN Sys_Approval_Tempelate_Master SATM ON SATD.Tempelate_ID = SATM.Tempelate_ID " +
                    "WHERE SASD.UserId = {0} AND SATF.FormId = {1} AND SATM.IsActive = 1 AND SASM.IsDeleted = 0",
                    user_id, form_id).FirstOrDefault() ?? 0m;

                var canApprove = maxApprovalLimit == -1m;

                var result = new
                {
                    CanApprove = canApprove,
                    MaxApprovalLimit = maxApprovalLimit,
                    Amount = 0
                };

                return (new JavaScriptSerializer()).Serialize(result);
            }
        }

        [WebMethod]
        public static string ApproveSingleSTORESTOCKTRANSFER(string StockTransferId, string approvalRemarks)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var stId = Convert.ToInt32(StockTransferId);
                var user_id = AppConfig.UserID;
                var form_id = 8;

                Stock_Transfer st = db.Stock_Transfers
                    .Where(s => s.Stock_Transfer_ID == stId)
                    .SingleOrDefault();

                if (st == null)
                    return "Error: Stock Transfer not found";

                var isFinalApprovals = (from SASD in db.Sys_Approval_Stage_Details
                                        join SASM in db.Sys_Approval_Stage_Masters on SASD.Stage_ID equals SASM.Stage_ID
                                        join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                                        join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATD.Tempelate_ID equals SATF.Tempelate_ID
                                        where SASD.UserId == user_id && SATF.FormId == form_id && SASM.IsDeleted == false
                                        select new { SASM.IsFinalApproval, SATF.FormId }).ToList();

                if (isFinalApprovals.Any(a => a.IsFinalApproval == true && a.FormId == form_id))
                {
                    var Details = db.sp_approvestocknew(st.Stock_Transfer_ID, user_id);
                    db.SubmitChanges();

                    var sasd = (from tbl in db.Sys_Approval_Stage_Details
                                join SASM in db.Sys_Approval_Stage_Masters on tbl.Stage_ID equals SASM.Stage_ID
                                join SATDS in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATDS.StageId
                                join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATDS.Tempelate_ID equals SATF.Tempelate_ID
                                where tbl.UserId == user_id && SASM.IsFinalApproval == true && SATF.FormId == form_id && SASM.IsDeleted == false
                                select tbl).FirstOrDefault();

                    if (sasd != null)
                    {
                        var satds = (from tbl in db.Sys_Approval_Tempelate_Detail_Stages
                                     join SATF in db.Sys_Approval_Tempelate_Detail_Forms on tbl.Tempelate_ID equals SATF.Tempelate_ID
                                     where tbl.StageId == sasd.Stage_ID && SATF.FormId == form_id
                                     select tbl).FirstOrDefault();

                        if (satds != null)
                        {
                            var log = new Sys_Approval_Log();
                            log.Approval_Template_ID = satds.Tempelate_ID;
                            log.Approval_Stage_ID = sasd.Stage_ID;
                            log.Entry_ID = (int)st.Stock_Transfer_ID;
                            log.Form_ID = form_id;
                            log.From_Name = "Store Stock Transfer";
                            log.Remarks = st.Remarks;
                            log.Company_ID = AppConfig.Company_ID;
                            log.IsFinalAprroval = true;
                            log.Entry_Status = "Approved";
                            log.Approve_By = user_id;
                            log.Approve_Date = DateTime.Now;
                            log.IsRejected = false;
                            log.Approval_Remarks = approvalRemarks;
                            db.Sys_Approval_Logs.InsertOnSubmit(log);
                            db.SubmitChanges();
                        }
                    }
                }
                else
                {
                    st.Status = "Pending";
                    st.Approved_Time = DateTime.Now;
                    st.Approved_By = user_id;
                    db.SubmitChanges();

                    var sasd = (from tbl in db.Sys_Approval_Stage_Details
                                join SASM in db.Sys_Approval_Stage_Masters on tbl.Stage_ID equals SASM.Stage_ID
                                join SATDS in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATDS.StageId
                                join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATDS.Tempelate_ID equals SATF.Tempelate_ID
                                where tbl.UserId == user_id && SASM.IsFinalApproval == false && SATF.FormId == form_id && SASM.IsDeleted == false
                                select tbl).FirstOrDefault();

                    if (sasd != null)
                    {
                        var satds = (from tbl in db.Sys_Approval_Tempelate_Detail_Stages
                                     join SATF in db.Sys_Approval_Tempelate_Detail_Forms on tbl.Tempelate_ID equals SATF.Tempelate_ID
                                     where tbl.StageId == sasd.Stage_ID && SATF.FormId == form_id
                                     select tbl).FirstOrDefault();

                        if (satds != null)
                        {
                            var log = new Sys_Approval_Log();
                            log.Approval_Template_ID = satds.Tempelate_ID;
                            log.Approval_Stage_ID = sasd.Stage_ID;
                            log.Entry_ID = (int)st.Stock_Transfer_ID;
                            log.Form_ID = form_id;
                            log.From_Name = "Store Stock Transfer";
                            log.Remarks = st.Remarks;
                            log.Company_ID = AppConfig.Company_ID;
                            log.IsFinalAprroval = false;
                            log.Entry_Status = "Pending";
                            log.Approve_By = user_id;
                            log.Approve_Date = DateTime.Now;
                            log.IsRejected = false;
                            log.Approval_Remarks = approvalRemarks;
                            db.Sys_Approval_Logs.InsertOnSubmit(log);
                            db.SubmitChanges();
                        }
                    }
                }
                db.SubmitChanges();
                return "Success";
            }
        }

        [WebMethod]
        public static string GetApprovedGRNList()
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var data = (from grn in db.GRN_Masters
                              join v in db.AP_Vendors on grn.VendorId equals v.Vendor_ID.ToString()
                              where grn.Status == "Approved"
                              orderby grn.GRN_Date descending
                              select new
                              {
                                  grn.GRN_ID,
                                  grn.GRN_Num,
                                  grn.GRN_Date,
                                  VendorName = v.Vendor_Name
                              }).ToList();
                var result = data.Select(x => new {
                    x.GRN_ID,
                    x.GRN_Num,
                    GRN_Date_Str = x.GRN_Date.ToString("dd MMM yyyy"),
                    x.VendorName
                }).ToList();
                return (new JavaScriptSerializer()).Serialize(result);
            }
        }

        [WebMethod]
        public static string GetGRNDetails(int grnId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var grn = db.GRN_Masters.Where(x => x.GRN_ID == grnId).FirstOrDefault();
                string warehouse = grn != null ? grn.InvOrgId : "";
                var data = (from d in db.GRN_Details
                              join i in db.INV_Items on d.Item_Id equals i.Item_ID into itemJoin
                              from item in itemJoin.DefaultIfEmpty()
                              where d.GRNId == grnId
                              select new
                              {
                                  d.GRN_detail_Id,
                                  d.ItemCode,
                                  d.BatchNum,
                                  d.GRNQty,
                                  d.Rate,
                                  d.Amount,
                                  d.ExpiryDate,
                                  Description = item != null ? item.Description : ""
                              }).ToList();
                var result = data.Select(x => new {
                    x.GRN_detail_Id,
                    x.ItemCode,
                    x.BatchNum,
                    x.GRNQty,
                    x.Rate,
                    x.Amount,
                    ExpiryDate_Str = x.ExpiryDate.HasValue ? x.ExpiryDate.Value.ToString("dd MMM yyyy") : "",
                    x.Description,
                    GRN_WareHouse = warehouse
                }).ToList();
                return (new JavaScriptSerializer()).Serialize(result);
            }
        }
    }
}