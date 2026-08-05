using PMS;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web.Data.Extensions;
using Newtonsoft.Json;
namespace PMS.AP
{
    public partial class PurchaseRequistion : System.Web.UI.Page
    {
        string detail_id = string.Empty;

        private class ddlListItems
        {
            public string DataValueName;
            public string DataValueDescription;
            public string Type;
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            HyperLink1.Visible = false;
            if (!IsPostBack)
            {
                LoadGIRNum();
                if (Request.QueryString["ID"] != null)
                {
                    DataBaseDataContext db = new DataBaseDataContext();
                    var getID = Request.QueryString["ID"];
                    var gettype = (from a in db.Purchase_Requisitions where a.PR_Id == Convert.ToInt32(getID) select a.File_Path).FirstOrDefault();
                    if (!string.IsNullOrEmpty(gettype))
                    {
                        HyperLink1.NavigateUrl = gettype;
                        HyperLink1.Visible = true;
                    }

                }
            }
        }

        [WebMethod]
        public static string filldepartments()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dept = (from data in db.Department_Wise_User_Details
                        where data.User_Id == AppConfig.UserID
                        select new
                        {
                            DataValueName = data.Department,
                            DataValueDescription = db.GetDataValueName("Department", data.Department),
                        }).ToList();
            return (new JavaScriptSerializer()).Serialize(dept);
        }

        [WebMethod]
        public static string GetWareHouseCondition()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dept = (from data in db.sys_Parms
                        where data.Name == "WareHouse For PR"
                        select                       
                          data.Code
                        ).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(dept);
        }

        private void LoadGIRNum()
        {
            #region "Bind GIRNUM in Dropdown"
            DataTable dt = new DataTable();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var vendor = db.sp_LoadGIRNum();
            ddlGIR.DataSource = vendor;
            ddlGIR.DataTextField = "Request_No";
            ddlGIR.DataValueField = "MaterialRequest_Id";
            ddlGIR.DataBind();
            if (!IsPostBack)
            {
                ddlGIR.Items.Insert(0, new ListItem("Please Select", "0"));
            }
            #endregion
        }
        [WebMethod]
        public static string getGIRByID(string GIRId)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            int GirId = Convert.ToInt32(GIRId);
            var listDetails = db.sp_GetGIRDetailByGIRID(GirId).ToList();
            return (new JavaScriptSerializer()).Serialize(listDetails);
        }
        [WebMethod]
        public static string fillpriorities()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Priority Type"
                         select new ddlListItems
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(listItems);
        }

        [WebMethod]
        public static string fillWarehouse()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Ware House"
                         select new ddlListItems
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(listItems);
        }

        [WebMethod]
        public static String Getitem(int ItemID, string PRDate)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var itemDetail = db.spGetitemsDetailswithStock(ItemID, PRDate, "").ToList();
                return (new JavaScriptSerializer()).Serialize(itemDetail);
            }
        }
        [WebMethod]
        public static string GetAllitem(string searchText,string warehouse)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var userPermissions = (from data in db.aspnet_Users
                                       where data.UserId == AppConfig.UserID
                                       select new
                                       {
                                           data.AllowPharmacy,
                                           data.AllowGeneralItems
                                       }).FirstOrDefault();

                bool allowPharmacy = userPermissions?.AllowPharmacy ?? false;
                bool allowGeneralItem = userPermissions?.AllowGeneralItems ?? false;

                var itemDetail = db.spGetAllitemsDetails(searchText, allowPharmacy, allowGeneralItem,Convert.ToInt32(warehouse)).ToList();
                return (new JavaScriptSerializer()).Serialize(itemDetail);
            }
        }
        [WebMethod]
        public static int GetPR()
        {
            int max = DBClass.getMaxEntry_No("Purchase_Requisition", "PR_Num");
            return max;
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
                                    .Any(temp => temp.SATM.IsActive == true && temp.SATM.IsDeleted == false && temp.SATDF.FormId == 1 && temp.SATDO.UserId == uid);

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
                                           data.PurchaseUnApprove
                                       }).FirstOrDefault();
                bool UnApproveRight = userPermissions?.PurchaseUnApprove ?? false;
                return UnApproveRight;
            }
        }



        [WebMethod]
        public static string SavePurchaseRequistion(int PRid, string PrNum, string PrDate, string dept, string Pirority, string Warehouse, string RefNum, string remarks, string btnValue)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            Purchase_Requisition obj = new Purchase_Requisition();
            Purchase_Requisition query = new Purchase_Requisition();
            var Purchaseid = string.Empty;
            if (btnValue == "Save")
            {
                obj.PR_Num = Convert.ToInt32(PrNum);
                obj.PR_Date = Convert.ToDateTime(PrDate);
                obj.Priority = Pirority;
                obj.Warehouse = Warehouse;
                obj.Department = dept;
                obj.Ref_Num = RefNum;
                obj.Remarks = remarks;
                obj.Creation_Date = DateTime.Now;
                obj.Created_By = AppConfig.UserID;
                obj.Status = "Created";
                obj.IsDeleted = false;
                obj.IsClosed = false;
                obj.IsNotificationViewed = false;
                var Pr_Num = PrNum;
                DataTable dt = DBClass.getDataTable("select PR_Num from Purchase_Requisition where PR_Num='" + Pr_Num + "'");
                if (dt.Rows.Count > 0)
                {
                    obj.PR_Num = (Convert.ToInt32(db.Purchase_Requisitions.Max(p => p.PR_Num)) + 1);
                }
                db.Purchase_Requisitions.InsertOnSubmit(obj);
            }
            else
            {
                query = (from data in db.Purchase_Requisitions.Where(x => x.PR_Id.Equals(PRid))
                         select data).FirstOrDefault();
                query.PR_Date = Convert.ToDateTime(PrDate);
                query.Priority = Pirority;
                query.Warehouse = Warehouse;
                query.Department = dept;
                query.Ref_Num = RefNum;
                query.Remarks = remarks;
                query.Update_Date = DateTime.Now;
                query.Updated_By = AppConfig.UserID;
            }
            try
            {
                db.SubmitChanges();
            }
            catch (Exception)
            {
                return "Error";
            }
            Purchaseid = Convert.ToString(obj.PR_Id);
            if (Purchaseid == "0")
            {
                Purchaseid = Convert.ToString(query.PR_Id);
            }
            return "Success-" + Purchaseid;
        }
        [WebMethod]
        public static string SavePurchaseRequistionDetails(int PRid, string btnValue, List<PurchaseRequistionDetails> PurchaseRequistionDetails)
        {

            DataBaseDataContext db = new DataBaseDataContext();
            var purchaseRequisition = db.Purchase_Requisitions.SingleOrDefault(pr => pr.PR_Id == PRid);
            if (purchaseRequisition == null)
            {
                return "Error: Purchase Requisition not found";
            }
            if (btnValue == "Update")
            {
                var PurchaseList = from PurchaseRequistion in db.Purchase_Requisition_Details where PurchaseRequistion.PR_ID == PRid select PurchaseRequistion;
                foreach (var del in PurchaseList)
                {
                    db.Purchase_Requisition_Details.DeleteOnSubmit(del);
                }
                db.SubmitChanges();
            }
            bool proceed = true;
            foreach (var item in PurchaseRequistionDetails)
            {
                Purchase_Requisition_Detail obj = new Purchase_Requisition_Detail();
                obj.Item_ID = Convert.ToInt32(item.itemId);
                obj.PR_ID = Convert.ToInt32(item.PRId);
                if (item.Qty == "")
                {
                    obj.Qty = 0;
                }
                obj.Qty = Convert.ToDecimal(item.Qty);
                if (item.UnitPrice == "")
                {
                    obj.UnitPrice = 0;
                }
                else
                {
                    obj.UnitPrice = Convert.ToDecimal(item.UnitPrice);
                }
                if (item.EstimateCost == "")
                {
                    obj.EstimateCost = 0;
                }
                else
                {
                    obj.EstimateCost = Convert.ToDecimal(item.EstimateCost);
                }
                obj.Remarks = Convert.ToString(item.Remarks);
                obj.Required_Date = Convert.ToDateTime(item.RDate);
                obj.MaterialRequestDetail_Id = Convert.ToInt32(item.MaterialRequestDetail_Id);
                obj.MaterialRequest_Id = Convert.ToInt32(item.MaterialRequest_Id);
                obj.Req_Num = Convert.ToInt32(item.Req_Num);
                db.Purchase_Requisition_Details.InsertOnSubmit(obj);

                try
                {
                    db.SubmitChanges();
                    var max = db.Purchase_Requisition_Details.Max(x => x.PR_Detail_ID);
                }
                catch (Exception ex)
                {
                    proceed = true;
                    return "Error";
                }
            }
            // Update MaterialRequest_Id in Purchase_Requisition
            var firstDetail = PurchaseRequistionDetails.FirstOrDefault();
            if (firstDetail != null)
            {
                purchaseRequisition.MaterialRequest_Id = firstDetail.MaterialRequest_Id;
                try
                {
                    db.SubmitChanges();
                }
                catch (Exception ex)
                {
                    return "Error: " + ex.Message;
                }
            }

            return "Success-" + PRid;
        }

        [WebMethod]
        public static string LoadPurchaseRequistion(int ID)
        {
            string result = string.Empty;
            if (ID > 0)
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var query = (from pr in db.Purchase_Requisitions
                                 join mir in db.MaterialIssueRequests on Convert.ToInt32(pr.MaterialRequest_Id) equals mir.MaterialRequest_Id into mirGroup
                                 from mir in mirGroup.DefaultIfEmpty()
                                 join createdUser in db.aspnet_Users on mir.Created_By equals createdUser.UserId into createdGroup
                                 from createdUser in createdGroup.DefaultIfEmpty()
                                 join approvedUser in db.aspnet_Users on mir.Approved_By equals approvedUser.UserId into approvedGroup
                                 from approvedUser in approvedGroup.DefaultIfEmpty()
                                 where pr.PR_Id == ID
                                 select new
                                 {
                                     pr.PR_Num,
                                     pr.Priority,
                                     pr.Warehouse,
                                     pr.Remarks,
                                     pr.PR_Id,
                                     pr.Ref_Num,
                                     pr.PR_Date,
                                     pr.Department,
                                     pr.Status,
                                     pr.MaterialRequest_Id,
                                     Created_By = (from asp in db.aspnet_Users where asp.UserId == pr.Created_By select asp.UserName).FirstOrDefault(),
                                     pr.Creation_Date,
                                     UpdatedBy = (from asp in db.aspnet_Users where asp.UserId == pr.Updated_By select asp.UserName).FirstOrDefault(),
                                     pr.Update_Date,
                                     GIRCreatedBy = mir != null && mir.MaterialRequest_Id > 0 ? createdUser.UserName : string.Empty,
                                     GIRApprovedBy = mir != null && mir.MaterialRequest_Id > 0 ? approvedUser.UserName : string.Empty,
                                     GIRNum = mir != null && mir.MaterialRequest_Id > 0 ? mir.Request_No : 0,
                                 }).FirstOrDefault();

                    result = (new JavaScriptSerializer()).Serialize(query).ToString();
                }
            }
            return result;
        }
        [WebMethod]
        public static string LoadPurchaseRequistionDetail(int ID)
        {
            List<PurchaseRequistionDetails> listItems = new List<PurchaseRequistionDetails>();
            string result = string.Empty;
            if (ID > 0)
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var transDate = db.Purchase_Requisitions.Where(p => p.PR_Id == ID).Select(p => p.PR_Date).FirstOrDefault();
                    listItems = (from data in db.Purchase_Requisition_Details
                                 join inv in db.INV_Items
                                 on data.Item_ID equals inv.Item_ID
                                 where data.PR_ID == ID
                                 select new PurchaseRequistionDetails
                                 {
                                     PR_Detail_ID = Convert.ToString(data.PR_Detail_ID),
                                     itemCode = Convert.ToString(inv.Item_Code),
                                     Description = Convert.ToString(inv.Description),
                                     itemId = Convert.ToString(data.Item_ID),
                                     PRId = Convert.ToString(data.PR_ID),
                                     Qty = Convert.ToString(data.Qty),
                                     UnitPrice = Convert.ToString(data.UnitPrice),
                                     EstimateCost = Convert.ToString(data.EstimateCost),
                                     RDate = Convert.ToDateTime(data.Required_Date),
                                     Remarks = data.Remarks,
                                     UOM = db.GetDataValueName("UOM", inv.Unit),
                                     stock = db.GetItemBatchStock(data.Item_ID, string.Empty, "") ?? 0,
                                     MaterialRequestDetail_Id = Convert.ToInt32(data.MaterialRequestDetail_Id),
                                     MaterialRequest_Id = Convert.ToInt32(data.MaterialRequest_Id),
                                     Req_Num = Convert.ToInt32(data.Req_Num),
                                     LastQty = (from prd in db.Purchase_Requisition_Details
                                                join pr in db.Purchase_Requisitions on prd.PR_ID equals pr.PR_Id
                                                where prd.Item_ID == data.Item_ID && pr.Status != "Cancelled"
                                                orderby pr.Creation_Date descending
                                                select prd.Qty).FirstOrDefault() ?? 0,

                                     LastRequiredDate = (from prd in db.Purchase_Requisition_Details
                                                         join pr in db.Purchase_Requisitions on prd.PR_ID equals pr.PR_Id
                                                         where prd.Item_ID == data.Item_ID && pr.Status != "Cancelled"
                                                         orderby pr.Creation_Date descending
                                                         select prd.Required_Date).FirstOrDefault()

                                 }).ToList();
                    result = (new JavaScriptSerializer()).Serialize(listItems).ToString();
                }
            }
            return result;
        }

        [WebMethod]
        public static string ApprovePR(string PRId)
        {
            var userid = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.spApprovePurchaseRequisition(Convert.ToInt32(PRId), userid);
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string UnApprovePR(string PRId)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.spUnApprovePurchaseRequisition(Convert.ToInt32(PRId));
            return (new JavaScriptSerializer()).Serialize(Details);
        }

        [WebMethod]
        public static bool CheckApprovalRights()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var form_id = 1;
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
        public static string GetApprovalInfo(string PRId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var prId = Convert.ToInt32(PRId);
                var user_id = AppConfig.UserID;
                var form_id = 1;

                var prDept = db.Purchase_Requisitions
                    .Where(p => p.PR_Id == prId)
                    .Select(p => p.Department)
                    .FirstOrDefault();

                var userApprovalLimit = (from SASD in db.Sys_Approval_Stage_Details
                                         join SASM in db.Sys_Approval_Stage_Masters on SASD.Stage_ID equals SASM.Stage_ID
                                         join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                                         join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATD.Tempelate_ID equals SATF.Tempelate_ID
                                         where SASD.UserId == user_id && SATF.FormId == form_id && SASM.IsDeleted == false
                                         select SASD.MaxApprovalLimit).FirstOrDefault() ?? 0m;

                var totalApprovedForDept = (from prd in db.Purchase_Requisition_Details
                                            join pr in db.Purchase_Requisitions on prd.PR_ID equals pr.PR_Id
                                            where pr.Status == "Approved" && pr.Department == prDept
                                            select (decimal?)prd.EstimateCost).Sum() ?? 0m;

                var prAmount = (from prd in db.Purchase_Requisition_Details
                                where prd.PR_ID == prId
                                select (decimal?)prd.EstimateCost).Sum() ?? 0m;

                var totalBudget = (from ba in db.Budget_Accounts
                                   join b in db.Budgets on ba.Budget_ID equals b.Budget_ID
                                   where b.Budget_Status == "Approved" && ba.DepartmentId == prDept
                                   select (decimal?)ba.DR).Sum() ?? 0m;

                var remainingAmount = totalBudget - totalApprovedForDept;

                var budgetEnabled = db.sys_Parms
                    .Where(s => s.Name == "Budget Working")
                    .Select(s => s.Code)
                    .FirstOrDefault() == "01";

                var canApprove = userApprovalLimit == -1m || totalApprovedForDept <= userApprovalLimit;

                var result = new
                {
                    CanApprove = canApprove,
                    RemainingAmount = remainingAmount,
                    PRAmount = prAmount,
                    UserApprovalLimit = userApprovalLimit,
                    BudgetEnabled = budgetEnabled
                };

                return (new JavaScriptSerializer()).Serialize(result);
            }
        }

        [WebMethod]
        public static string ApproveSinglePR(string PRId, string approvalRemarks)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var prId = Convert.ToInt32(PRId);
                var user_id = AppConfig.UserID;
                var form_id = 1;

                var PR = db.Purchase_Requisitions
                    .Where(p => p.PR_Id == prId)
                    .SingleOrDefault();

                if (PR == null)
                    return "Error: Purchase Requisition not found";

                var budgetEnabled = db.sys_Parms
                    .Where(s => s.Name == "Budget Working")
                    .Select(s => s.Code)
                    .FirstOrDefault() == "01";

                if (budgetEnabled)
                {
                    var prDept = PR.Department;
                    var totalBudget = (from ba in db.Budget_Accounts
                                       join b in db.Budgets on ba.Budget_ID equals b.Budget_ID
                                       where b.Budget_Status == "Approved" && ba.DepartmentId == prDept
                                       select (decimal?)ba.DR).Sum() ?? 0m;

                    var totalApprovedForDept = (from prd in db.Purchase_Requisition_Details
                                                join p in db.Purchase_Requisitions on prd.PR_ID equals p.PR_Id
                                                where p.Status == "Approved" && p.Department == prDept
                                                select (decimal?)prd.EstimateCost).Sum() ?? 0m;

                    var remainingAmount = totalBudget - totalApprovedForDept;

                    var prAmount = (from prd in db.Purchase_Requisition_Details
                                    where prd.PR_ID == prId
                                    select (decimal?)prd.EstimateCost).Sum() ?? 0m;

                    if (prAmount > remainingAmount)
                    {
                        return "Error: PR Amount exceeds remaining budget";
                    }
                }

                var isFinalApprovals = (from SASD in db.Sys_Approval_Stage_Details
                                        join SASM in db.Sys_Approval_Stage_Masters on SASD.Stage_ID equals SASM.Stage_ID
                                        join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                                        join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATD.Tempelate_ID equals SATF.Tempelate_ID
                                        where SASD.UserId == user_id && SATF.FormId == form_id && SASM.IsDeleted == false
                                        select new { SASM.IsFinalApproval, SATF.FormId }).ToList();

                if (isFinalApprovals.Any(a => a.IsFinalApproval == true && a.FormId == form_id))
                {
                    var Details = db.spApprovePurchaseRequisition(PR.PR_Id, user_id);
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
                            log.Entry_ID = PR.PR_Id;
                            log.Form_ID = form_id;
                            log.From_Name = "Purchase Requisition";
                            log.Remarks = PR.Remarks;
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
                    PR.Status = "Pending";
                    PR.Approved_Time = DateTime.Now;
                    PR.Approved_By = user_id;
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
                            log.Entry_ID = PR.PR_Id;
                            log.Form_ID = form_id;
                            log.From_Name = "Purchase Requisition";
                            log.Remarks = PR.Remarks;
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

        public class PurchaseRequistionDetails
        {
            public string itemCode { get; set; }
            public string Description { get; set; }
            public string Qty { get; set; }
            public decimal stock { get; set; }
            public DateTime RDate { get; set; }
            public string Remarks { get; set; }
            public string PRId { get; set; }
            public string itemId { get; set; }
            public string PR_Detail_ID { get; set; }
            public string UOM { get; set; }
            public string UnitPrice { get; set; }
            public string EstimateCost { get; set; }
            public int MaterialRequestDetail_Id { get; set; }
            public int MaterialRequest_Id { get; set; }
            public int Req_Num { get; set; }

            public decimal LastQty { get; set; }
            public DateTime? LastRequiredDate { get; set; }

        }
    }
}