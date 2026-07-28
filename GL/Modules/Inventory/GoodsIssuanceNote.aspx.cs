using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Inventory
{
    public partial class GoodsIssuanceNote : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            HyperLink1.Visible = false;
            if (!IsPostBack)
            {
                if (Request.QueryString["SI_ID"] != null)
                {
                    DataBaseDataContext db = new DataBaseDataContext();
                    var getID = Request.QueryString["SI_ID"];
                    var gettype = (from a in db.Store_Issues where a.Store_Issue_Id == Convert.ToInt32(getID) select a.File_Path).FirstOrDefault();
                    if (!string.IsNullOrEmpty(gettype))
                    {
                        HyperLink1.NavigateUrl = gettype;
                        HyperLink1.Visible = true;
                    }
                }
            }
        }
        [WebMethod]
        public static string GetAllitem(string searchText, string warehouseId)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext();

                var Details = db.INV_Items
                    .Where(x => (string.IsNullOrEmpty(searchText)
                                || x.Item_Code.Contains(searchText)
                                || x.Description.Contains(searchText))

                             && x.Active == true
                             && x.Services != true
                            // && x.InventoryOrg == warehouseId
                            && (x.InventoryOrg == warehouseId
                        || db.Item_Warehouse_Mappings.Any(m =>
                        m.Item_ID == x.Item_ID
                        && m.Warehouse_Id == warehouseId))                
                         )
                    .OrderBy(x => x.Item_Code)
                    .Take(200)
                    .Select(x => new
                    {
                        Item_ID = x.Item_ID,
                        Item_Code = x.Item_Code,
                        Description = x.Description,
                        Unit = db.GetDataValueName("UOM", x.Unit) ?? "",
                        Purchase_Rate = x.Purchase_Rate != null ? x.Purchase_Rate : 0,
                        UOM_Qty = x.UOM_Qty != null ? x.UOM_Qty : 1
                    })
                    .ToList();

                return (new JavaScriptSerializer()).Serialize(Details);
            }
            catch (Exception)
            {
                return (new JavaScriptSerializer()).Serialize(new List<object>());
            }
        }
        [WebMethod]
        public static string GetWareHouseCondition()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dept = (from data in db.sys_Parms
                        where data.Name == "WareHouse For PO"
                        select
                          data.Code
                        ).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(dept);
        }
        [WebMethod]
        public static string GetGIRCloseCondition()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dept = (from data in db.sys_Parms
                        where data.Name == "GIR Close"
                        select
                          data.Code
                        ).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(dept);
        }
        [WebMethod]
        public static String getMIR(string warehouse, string department)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());         
            var result = db.sp_GetMIR(warehouse, department);
            return (new JavaScriptSerializer()).Serialize(result);
        }

        [WebMethod]
        public static string LoadMRNo(string savedMRNo = null, string search = null)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = db.Reg_patients.Where(p => p.iscancel == false);
            if (!string.IsNullOrEmpty(search))
            {
                query = query.Where(p => p.mr_no_sequence.Contains(search));
            }
            // Take top 40 results
            var result = query.OrderBy(p => p.mr_no_sequence)
                              .Take(40)
                              .Select(p => new
                              {
                                  p.mr_no_sequence
                              }).ToList();
            // Include saved MR_No in edit mode, if not already in the list
            if (!string.IsNullOrEmpty(savedMRNo))
            {
                var savedMR = db.Reg_patients
                                .Where(p => p.mr_no_sequence.Trim() == savedMRNo)
                                .Select(p => new
                                {
                                    p.mr_no_sequence
                                }).FirstOrDefault();

                if (savedMR != null && !result.Any(x => x.mr_no_sequence == savedMR.mr_no_sequence))
                {
                    result.Add(savedMR);
                }
            }
            return new JavaScriptSerializer().Serialize(result);
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
                                    .Any(temp => temp.SATM.IsActive == true && temp.SATM.IsDeleted == false && temp.SATDF.FormId == 6 && temp.SATDO.UserId == uid);

                return hasEntryRights;
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
        public static string Getbatchs(string itemcode)
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var PICondition = (from sys in db.sys_Parms
                                   where sys.Name == "Direct PO ON Purchase Invoice"
                                   select sys.Code).FirstOrDefault();

                // ✅ Declare outside
                List<dynamic> grnResult;

                if (PICondition == "01")
                {
                    grnResult = (from dv in db.INV_Items
                                 join ds in db.Purchase_Invoice_Details
                                 on dv.Item_ID equals ds.ItemId
                                 where ds.ItemId == Convert.ToInt32(itemcode)
                                 select new
                                 {
                                     BatchNum = ds.BatchNum ?? string.Empty
                                 }).ToList<dynamic>();
                }
                else
                {
                    grnResult = (from dv in db.INV_Items
                                 join ds in db.GRN_Details
                                 on dv.Item_ID equals ds.Item_Id
                                 where ds.ItemCode == itemcode
                                 select new
                                 {
                                     BatchNum = ds.BatchNum ?? string.Empty
                                 }).ToList<dynamic>();
                }

                var stockAdjustmentResult = (from inv in db.INV_Stock_Adjustments
                                             where inv.Item_Code == itemcode
                                                   && inv.Status == "Approved"
                                             orderby inv.Creation_Time ascending
                                             select new
                                             {
                                                 BatchNum = inv.Batch_No ?? string.Empty
                                             }).ToList();

                if (!grnResult.Any() && !stockAdjustmentResult.Any())
                {
                    grnResult.Add(new { BatchNum = string.Empty });
                }

                var combinedResult = new
                {
                    GRN_Details = grnResult,
                    Stock_Adjustment_Details = stockAdjustmentResult
                };

                data = new JavaScriptSerializer().Serialize(combinedResult);
            }

            return data;
        }


        [WebMethod]
        public static string getStoreIssueByID(string MIR_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            int MIRid = Convert.ToInt32(MIR_id);
            var detail = db.sp_GetMIRDetailByMIRID(MIRid).ToList();
            return (new JavaScriptSerializer()).Serialize(detail);
        }
        [WebMethod]
        public static decimal GetCGSRate(string itemCode, string batchNo, string wareHouse)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var item = db.INV_Items.FirstOrDefault(i => i.Item_Code == itemCode);
                if (item == null)
                    return 0;

                int itemId = item.Item_ID;

                // Get correct batch based on warehouse
                //string effectiveBatch = (wareHouse == "008") ? batchNo : "0";

                decimal? rate = db.GetCGSAmounts(itemId, wareHouse, batchNo);

                return rate ?? 0;
            }
        }
        [WebMethod]
        public static decimal GetStock(string itemCode, string batchNo, string wareHouse)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            int ItemId = Convert.ToInt32(DBClass.getField("select Item_ID from INV_Items where Item_Code='" + itemCode + "'"));
            decimal st = (decimal)db.GetItemBatchStock(ItemId, batchNo, wareHouse);
            return st;
        }
        [WebMethod]
        public static int Save(string btnSave, string AllItemDetail)
        {
            string store_issue_id = "";
            Store_Issue si = new Store_Issue();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<StoreIssue>(AllItemDetail);
            var lstItem = (from t in db.Store_Issues
                           where t.Store_Issue_Id == int.Parse(record.StoreIssue_id)
                           select t).FirstOrDefault();
            if (btnSave == "Update")
            {
                lstItem.Organization_Id = record.inventory_id;
                lstItem.Department_Id = record.department_id;
                lstItem.Update_Time = DateTime.Now;
                lstItem.Updated_By = AppConfig.UserID;
                lstItem.Store_Issue_No = Convert.ToInt32(record.Store_Issue_No);
                db.SubmitChanges();
                store_issue_id = record.StoreIssue_id;
            }
            else
            {
                si.Company_Id = AppConfig.Company_ID.ToString();
                si.Organization_Id = record.inventory_id;
                si.Department_Id = record.department_id;
                si.Created_Time = DateTime.Now;
                si.Created_by = AppConfig.UserID;
                si.MR_No = record.MRNo;
                si.Store_Issue_No = DBClass.GetNewNumber("Store_Issue_No", "Store_Issue", "");
                si.Status = "Created";
                si.IsDeleted = false;
                db.Store_Issues.InsertOnSubmit(si);
                db.SubmitChanges();
                store_issue_id = si.Store_Issue_Id.ToString();
            }
            if (btnSave == "Update")
            {
                List<Store_Issue_Detail> lstItemDetails = db.Store_Issue_Details.Where(t => t.Store_Issue_Id == int.Parse(store_issue_id)).ToList();
                db.Store_Issue_Details.DeleteAllOnSubmit(lstItemDetails);
                db.SubmitChanges();
            }
            foreach (var item in record.ItemList)
            {
                Store_Issue_Detail sid = new Store_Issue_Detail();
                sid.MIR_Detail_Id = Convert.ToInt32(item.mirDetailId);
                sid.Store_Issue_Id = int.Parse(store_issue_id);
                sid.Item_Id = Convert.ToInt32(item.ItemId);
                sid.MIR_Id = Convert.ToInt32(item.mir_id);
                sid.MIR_Qty = Convert.ToDecimal(item.Qty);
                sid.Issue_Qty = Convert.ToDecimal(item.IssueQty);
                sid.Balance_Qty = Convert.ToDecimal(item.BalanceQty);
                sid.Store_Stock = item.StoreStock;
                sid.Department = item.Department;
                sid.Remarks = item.Remarks;
                sid.BatchNum = item.BatchNum;
                if (item.lastIssueDate != "")
                {
                    sid.Last_issue_date = Convert.ToDateTime(item.lastIssueDate);
                }
                sid.CGS = item.CGS;
                db.Store_Issue_Details.InsertOnSubmit(sid);
                db.SubmitChanges();
            }
            return int.Parse(store_issue_id);
        }
        [WebMethod]
        public static string LoadMaster(string SI_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = db.Store_Issues.Where(x => x.Store_Issue_Id.Equals(SI_ID));
            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static string LoadDetail(string SI_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from data in db.Store_Issue_Details.Where(x => x.Store_Issue_Id.Equals(SI_ID))
                         select new
                         {
                             Mir_Date = DBClass.getField("select Replace(convert(varchar, MIRDate, 106), ' ','-') from MaterialIssueRequest where MaterialRequest_Id=" + data.MIR_Id),
                             data.MIR_Detail_Id,
                             data.Balance_Qty,
                             data.Department,
                             data.Issue_Qty,
                             data.Item_Id,
                             data.MIR_Id,
                             data.MIR_Qty,
                             data.Last_issue_date,
                             data.CGS,
                             data.Remarks,
                             data.Store_Issue_Detail_Id,
                             data.Store_Issue_Id,
                             Store_Stock = DBClass.getField("Select dbo.GetItemBatchStock(" + data.Item_Id + ", '','')"),
                             data.BatchNum,
                             Item_code = DBClass.getField("select Item_Code from inv_items where Item_Id=" + data.Item_Id),
                             Unit = (from st in db.Store_Issue_Details
                                     join item in db.INV_Items on st.Item_Id equals item.Item_ID
                                     select db.GetDataValueName("UOM", item.Unit)).FirstOrDefault(),
                             Description = DBClass.getField("select Description from inv_items where Item_Id=" + data.Item_Id),
                             IsBatch = DBClass.getField("select IsBatch from inv_items where Item_Id=" + data.Item_Id),
                             SaveTimeStock=data.Store_Stock,
                             ExpiryDate = (from igp in db.Igp_Details
                                           where igp.Item_Id == data.Item_Id && igp.ExpiryDate != null
                                           orderby igp.Igp_item_ID descending
                                           select igp.ExpiryDate).FirstOrDefault()
                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(query);
        }   
        [WebMethod]
        public static string LoadDepartments()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Department"
                         select new
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static string LoadOrganizations()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Ware House"
                         select new
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,

                         }).ToList();

            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static string LoadEmployees()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from data in db.HR_Employees
                         where data.IsDoctor == false
                         select new
                         {
                             data.Emp_ID,
                             data.Emp_Name

                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static string LoadCompanies()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from data in db.sys_Companies select new { data.Company_ID, data.Company_Name }).ToList();
            return (new JavaScriptSerializer()).Serialize(query);
        }

        [WebMethod]
        public static string GetNewSINNo()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var SIN_No = DBClass.GetNewNumber("Store_Issue_No", "Store_Issue", "");
            return SIN_No.ToString();
        }
        public class StoreIssue
        {
            public string StoreIssue_id { get; set; }
            public string comapny_id { get; set; }
            public string inventory_id { get; set; }
            public string department_id { get; set; }
            public string Store_Issue_No { get; set; }
            public string MRNo { get; set; }
        public List<StoreIssueDetail> ItemList { get; set; }
        }
        public class StoreIssueDetail
        {
            public string mirDetailId { get; set; }
            public string ItemId { get; set; }
            public string mir_id { get; set; }
            public string Unit { get; set; }
            public string Qty { get; set; }
            public string IssueQty { get; set; }
            public string BalanceQty { get; set; }
            public string StoreStock { get; set; }
            public string Department { get; set; }
            public string Remarks { get; set; }
            public string BatchNum { get; set; }
            public string lastIssueDate { get; set; }
            public decimal CGS { get; set; }
        }

        [WebMethod]
        public static string ApproveSIN(string SINId, Guid user_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.spApproveStore_Issue(Convert.ToInt32(SINId), user_id);
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string UnApproveSIN(string SINId)
        {
            var userid = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.spUnApproveSIN(Convert.ToInt32(SINId), Convert.ToString(userid));
            return (new JavaScriptSerializer()).Serialize(Details);
        }

        [WebMethod]
        public static string CloseGIR(string GIR, string remarks)
        {
            var userid = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            string status = "Fail";

            try
            {
                var query = db.MaterialIssueRequests.SingleOrDefault(x => x.MaterialRequest_Id == Convert.ToInt32(GIR));
                if (query != null)
                {
                    query.Is_Closed_GIR = true;
                    query.Closing_Remarks = remarks; // Save remarks to new column
                    //query.Closed_By = userid; // Optional: track who closed it
                    //query.Closed_Date = DateTime.Now; // Optional: track when it was closed

                    db.SubmitChanges();
                    status = "success";
                }
            }
            catch (Exception ex)
            {
                // Log error if needed
                status = "Fail";
            }

            return status;
        }

        [WebMethod]
        public static bool CheckGINApprovalRights()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var form_id = 6;
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
        public static string GetGINApprovalInfo(string SINId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var sinId = Convert.ToInt32(SINId);
                var user_id = AppConfig.UserID;
                var form_id = 6;

                var SIN = db.Store_Issues.Where(p => p.Store_Issue_Id == sinId).FirstOrDefault();
                if (SIN == null)
                    return (new JavaScriptSerializer()).Serialize(new { CanApprove = false, MaxApprovalLimit = 0m, Amount = 0m });

                var maxApprovalLimit = db.ExecuteQuery<decimal?>(
                    "SELECT MAX(SASD.MaxApprovalLimit) " +
                    "FROM Sys_Approval_Stage_Detail SASD " +
                    "INNER JOIN Sys_Approval_Stage_Master SASM ON SASD.Stage_ID = SASM.Stage_ID " +
                    "INNER JOIN Sys_Approval_Tempelate_Detail_Stages SATD ON SASM.Stage_ID = SATD.StageId " +
                    "INNER JOIN Sys_Approval_Tempelate_Detail_Forms SATF ON SATD.Tempelate_ID = SATF.Tempelate_ID " +
                    "INNER JOIN Sys_Approval_Tempelate_Master SATM ON SATD.Tempelate_ID = SATM.Tempelate_ID " +
                    "WHERE SASD.UserId = {0} AND SATF.FormId = {1} AND SATM.IsActive = 1 AND SASM.IsDeleted = 0",
                    user_id, form_id).FirstOrDefault() ?? 0m;

                var canApprove = maxApprovalLimit == -1m || maxApprovalLimit >= 0m;

                var result = new
                {
                    CanApprove = canApprove,
                    MaxApprovalLimit = maxApprovalLimit,
                    Amount = 0m
                };

                return (new JavaScriptSerializer()).Serialize(result);
            }
        }

        [WebMethod]
        public static String getMIRAll()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var result = db.sp_GetMIRAll();
            return (new JavaScriptSerializer()).Serialize(result);
        }

        [WebMethod]
        public static string ApproveSingleGIN(string SINId, string approvalRemarks)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var sinId = Convert.ToInt32(SINId);
                var user_id = AppConfig.UserID;
                var form_id = 6;

                var SIN = db.Store_Issues.Where(p => p.Store_Issue_Id == sinId).SingleOrDefault();
                if (SIN == null)
                    return "Error: GIN not found";

                var isFinalApprovals = (from SASD in db.Sys_Approval_Stage_Details
                                        join SASM in db.Sys_Approval_Stage_Masters on SASD.Stage_ID equals SASM.Stage_ID
                                        join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                                        join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATD.Tempelate_ID equals SATF.Tempelate_ID
                                        where SASD.UserId == user_id && SATF.FormId == form_id && SASM.IsDeleted == false
                                        select new { SASM.IsFinalApproval, SATF.FormId }).ToList();

                if (isFinalApprovals.Any(a => a.IsFinalApproval == true && a.FormId == form_id))
                {
                    var Details = db.spApproveStore_Issue(SIN.Store_Issue_Id, user_id);
                    db.SubmitChanges();

                    var detailsList = Details.ToList();
                    var resultMsg = detailsList.FirstOrDefault()?.Message ?? "";
                    if (resultMsg != "Approved Successfully")
                    {
                        return "Error: " + resultMsg;
                    }

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
                            log.Entry_ID = SIN.Store_Issue_Id;
                            log.Form_ID = form_id;
                            log.From_Name = "Goods Issuance Note";
                            log.Remarks = string.Empty;
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
                    SIN.Status = "Pending";
                    SIN.Approved_Time = DateTime.Now;
                    SIN.Approved_By = user_id;
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
                            log.Entry_ID = SIN.Store_Issue_Id;
                            log.Form_ID = form_id;
                            log.From_Name = "Goods Issuance Note";
                            log.Remarks = string.Empty;
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
    }
}
