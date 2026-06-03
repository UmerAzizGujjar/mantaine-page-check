using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Inventory
{
    public partial class AddPurchaseReturn : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        private class ddlListItems
        {
            public string DataValueName;
            public string DataValueDescription;
            public string Type;
        }

        [WebMethod]
        public static string getVendorDDLlist()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var listItems = (from tbl in db.AP_Vendors where tbl.IsActive==true
                             select new
                             {
                                 VendorID = tbl.Vendor_ID,
                                 VendorName = tbl.Vendor_Name,
                                 Active = tbl.IsActive,
                             }).ToList();
            return (new JavaScriptSerializer()).Serialize(listItems);
        }
        [WebMethod]
        public static string getDDLlist()
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
                             DataValueDescription = p.DataValue_Description                             
                         }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);
        }

        [WebMethod]
        public static string GetGRNDetail(string vendorId, string ddltype, string InvOrgId)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_GetGRNDetailforPurchaseReturn(Convert.ToInt32(vendorId), Convert.ToInt32(ddltype), InvOrgId);
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static int SavePurchaseReturn(string btnSave, string AllItemDetail)
        {
            string PurchaseReturnId = "";
            Purchase_Return_Master PO = new Purchase_Return_Master();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<MasterPurchaseReturnList>(AllItemDetail);

            if (btnSave == "Update")
            {
                var lstItem = (from t in db.Purchase_Return_Masters
                               where t.Purchase_Return_No == int.Parse(record.PurchaseReturnNum)
                               select t).FirstOrDefault();
                lstItem.Purchase_Return_Date = record.PurchaseReturndate;
                lstItem.UpdatedDate = DateTime.Now;
                lstItem.UpdatedBy = Convert.ToString(AppConfig.UserID);
                lstItem.Purchase_Return_No = Convert.ToInt32(record.PurchaseReturnNum);
                lstItem.WareHouse = record.ReturnFormInventoryOrg;
                lstItem.Vendor_ID = record.VendorId;
                lstItem.Remarks = record.Remarks;
                lstItem.Invoice_Type = Convert.ToInt32(record.InvoiceType);
                db.SubmitChanges();
                PurchaseReturnId = lstItem.Purchase_Return_ID.ToString();
            }
            else
            {
                PO.Vendor_ID = record.VendorId;
                PO.Purchase_Return_No = DBClass.GetNewNumber("Purchase_Return_No", "Purchase_Return_Master", "");
                PO.Purchase_Return_Date = record.PurchaseReturndate;
                PO.Remarks = record.Remarks;
                PO.Invoice_Type = Convert.ToInt32(record.InvoiceType);
                PO.WareHouse = record.ReturnFormInventoryOrg;
                PO.CreatedDate = DateTime.Now;
                PO.CreatedBy =Convert.ToString(AppConfig.UserID);
                PO.Company_ID = AppConfig.Company_ID;
                PO.Status = "Created";
                PO.IsDeleted = false;
                db.Purchase_Return_Masters.InsertOnSubmit(PO);
                db.SubmitChanges();
                PurchaseReturnId = PO.Purchase_Return_ID.ToString();
            }

            if (btnSave == "Update")
            {
                List<Purchase_Return_Detail> lstPaymnentInvocieDetails = db.Purchase_Return_Details.Where(t => t.Purchase_Return_ID == int.Parse(PurchaseReturnId)).ToList();
                db.Purchase_Return_Details.DeleteAllOnSubmit(lstPaymnentInvocieDetails);
                db.SubmitChanges();
            }

            foreach (var Purchaseitem in record.ItemList)
            {
                Purchase_Return_Detail ltd = new Purchase_Return_Detail();
                ltd.Purchase_Return_ID = Convert.ToInt64(PurchaseReturnId);
                ltd.Item_ID = Convert.ToInt64(Purchaseitem.ItemId);
                ltd.Batch_No = Purchaseitem.BatchNum;
                ltd.Inventory_Org = record.ReturnFormInventoryOrg;
                ltd.Qty = Convert.ToDecimal(Purchaseitem.Qty);
                ltd.Rate = Convert.ToDecimal(Purchaseitem.Rate);
                ltd.Amount = Convert.ToDecimal(Purchaseitem.Amount);
                ltd.Trans_Type = Purchaseitem.TransType;
                ltd.GRN_ID = Convert.ToInt64(Purchaseitem.GRNId);
                ltd.GRN_Detail_ID = Convert.ToInt64(Purchaseitem.GRNDetailId);
                ltd.GRN_Num = Convert.ToInt64(Purchaseitem.GRNNum);
                ltd.GRN_Date = Convert.ToDateTime(Purchaseitem.GRNDate);
                db.Purchase_Return_Details.InsertOnSubmit(ltd);
                db.SubmitChanges();
            }
            return int.Parse(PurchaseReturnId);
        }

        [WebMethod]
        public static string LoadPurchaseReturnInvocieDetail(int ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Header = (from m in db.Purchase_Return_Masters
                          where m.Purchase_Return_ID == ID
                          select new
                          {
                              m.Vendor_ID,
                              m.Purchase_Return_No,
                              m.Purchase_Return_Date,
                              m.Invoice_Type,
                              m.UpdatedDate,
                              m.UpdatedBy,
                              m.Remarks,
                              m.Status,
                              m.WareHouse,
                              Vendor_Name = db.AP_Vendors.Where(po => po.Vendor_ID == Convert.ToInt32(m.Vendor_ID)).Select(po => po.Vendor_Name),
                          }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(Header);
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
        public static string LoadPurchaseReturn_Detail(int ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_LoadDetailforPurchaseReturn(Convert.ToInt64(ID));
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string ApprovePurchaseReturn(string PRTId)
        {
            var userid = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_ApprovePurchaseReturn(Convert.ToInt32(PRTId), Convert.ToString(userid));
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string UnApprovePurchaseReturn(string PRTId)
        {
            var userid = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.spUnApprovePurchaseReturn(Convert.ToInt32(PRTId), Convert.ToString(userid));
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        public class MasterPurchaseReturnList
        {
            public string DepartmentId { get; set; }
            public string VendorId { get; set; }
            public string BranchID { get; set; }
            public string PurchaseReturnNum { get; set; }
            public DateTime PurchaseReturndate { get; set; }
            public string ReturnFormInventoryOrg { get; set; }

            public string Remarks { get; set; }
            public int InvoiceType { get; set; }
            public List<PurchaseReturnDetailList> ItemList { get; set; }
        }
        public class PurchaseReturnDetailList
        {
            public string Purchase_Return_ID { get; set; }
            public string ItemId { get; set; }
            public string BatchNum { get; set; }
            public string Qty { get; set; }
            public decimal Amount { get; set; }
            public decimal Rate { get; set; }
            public string TransType { get; set; }
            public string GRNId { get; set; }
            public string GRNDetailId { get; set; }
            public DateTime GRNDate { get; set; }
            public string GRNNum { get; set; }
        }
    }
}