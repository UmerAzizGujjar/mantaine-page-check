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
                                           data.IsInventoryUnApprove
                                       }).FirstOrDefault();
                bool UnApproveRight = userPermissions?.IsInventoryUnApprove ?? false;
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

        }
    }
}