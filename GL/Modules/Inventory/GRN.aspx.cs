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
    public partial class GRN : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            HyperLink1.Visible = false;
            if (!IsPostBack)
            {
                if (Request.QueryString["GRN_ID"] != null)
                {
                    DataBaseDataContext db = new DataBaseDataContext();
                    var getID = Request.QueryString["GRN_ID"];
                    var gettype = (from a in db.GRN_Masters where a.GRN_ID == Convert.ToInt32(getID) select a.File_Path).FirstOrDefault();
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
                             && (string.IsNullOrEmpty(warehouseId)
                         || x.InventoryOrg == warehouseId
                         || db.Item_Warehouse_Mappings.Any(m =>
                              m.Item_ID == x.Item_ID
                              && m.Warehouse_Id == warehouseId)
                         ))
                    .OrderBy(x => x.Item_Code)
                    .Take(200)
                    .Select(x => new
                    {
                        Item_ID = x.Item_ID,
                        Item_Code = x.Item_Code,
                        Description = x.Description,
                        Unit = db.GetDataValueName("UOM", x.Unit) ?? "",
                        Purchase_Rate = x.Purchase_Rate != null ? x.Purchase_Rate : 0,
                        UOM_Qty = x.UOM_Qty != null ? x.UOM_Qty : 1,
                        Last_GRN_Rate = (from pd in db.GRN_Details
                                        join ph in db.GRN_Masters on pd.GRNId equals ph.GRN_ID
                                        where pd.Item_Id == x.Item_ID
                                        orderby ph.Creation_Date descending
                                        select pd.Rate)
                            .FirstOrDefault() ?? 0,
                        TotalStock = db.GetInvenrtoryItemUomTotalStock(x.Item_ID, x.InventoryOrg)
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
        public static int SaveGRNDetail(string btnSave, string AllItemDetail)
        {
            GRN_Master obj = new GRN_Master();
            string GRNNo = "";
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<MasterGRNList>(AllItemDetail);
            var lstItem = (from t in db.GRN_Masters
                           where t.GRN_Num == int.Parse(record.GRN_Num)
                           select t).FirstOrDefault();
            if (btnSave == "Update")
            {
                lstItem.GRN_Num = Convert.ToInt32(record.GRN_Num);
                lstItem.GRN_Date = Convert.ToDateTime(record.Date);
                lstItem.VendorId = record.VendorId;
                lstItem.InvOrgId = record.InvOrg;
                lstItem.Project = record.project;
                lstItem.is_Direct = record.Is_Direct;
                lstItem.Update_Date = DateTime.Now;
                lstItem.Updated_By = AppConfig.UserID;
                lstItem.Company_ID = AppConfig.Company_ID;
                db.SubmitChanges();
                GRNNo = lstItem.GRN_ID.ToString();
            }
            else
            {
                obj.GRN_Num = Convert.ToInt32(record.GRN_Num);
                obj.GRN_Date = Convert.ToDateTime(record.Date);
                obj.VendorId = record.VendorId;
                obj.Remarks = record.remarks;
                obj.InvOrgId = record.InvOrg;
                obj.Project = record.project;
                obj.is_Direct = record.Is_Direct;
                obj.Creation_Date = DateTime.Now;
                obj.Created_By = AppConfig.UserID;
                obj.Company_ID = AppConfig.Company_ID;
                obj.Status = "Created";
                db.GRN_Masters.InsertOnSubmit(obj);
                db.SubmitChanges();
                GRNNo = obj.GRN_ID.ToString();
            }
            ///**********Deleting Previous details**************/

            if (btnSave == "Update")
            {
                List<GRN_Detail> lstGRNItemDetails = db.GRN_Details.Where(t => t.GRNId == int.Parse(GRNNo)).ToList();
                db.GRN_Details.DeleteAllOnSubmit(lstGRNItemDetails);
                db.SubmitChanges();
            }
            if (record.ItemList != null)
            {
                foreach (var item in record.ItemList)
                {
                    GRN_Detail ltd = new GRN_Detail();
                    ltd.ItemCode = item.ItemCode;
                    ltd.GRNId = int.Parse(GRNNo);
                    ltd.MfgDate = Convert.ToDateTime(item.Mfgdate);
                    ltd.ExpiryDate = Convert.ToDateTime(item.Expdate);
                    ltd.IGPDetailId = Convert.ToInt32(item.IGPDetailId);
                    ltd.GRNQty = Convert.ToDecimal(item.AccQty);
                    ltd.Item_Id = Convert.ToInt32(DBClass.getField("select Item_Id from inv_items where Item_Code=" + Convert.ToInt32(item.ItemCode)));
                    db.GRN_Details.InsertOnSubmit(ltd);
                    db.SubmitChanges();
                }

            }
            if (record.ItemListDir != null)
            {
                foreach (var item in record.ItemListDir)
                {
                    GRN_Detail ltd = new GRN_Detail();
                    ltd.ItemCode = item.ItemCodeDir;
                    ltd.GRNId = int.Parse(GRNNo);
                    ltd.MfgDate = Convert.ToDateTime(item.MfgdateDir);
                    ltd.ExpiryDate = Convert.ToDateTime(item.ExpdateDir);
                    ltd.BatchNum = item.BatchNoDir;
                    ltd.UOM_Qty = Convert.ToInt32(item.UOMQtyDir);
                    ltd.BounusQty = Convert.ToInt32(item.BONQtyDir);
                    //ltd.IGPDetailId = Convert.ToInt32(item.IGPDetailId);
                    ltd.GRNQty = Convert.ToDecimal(item.GRNQtyDir);
                    ltd.Rate = Convert.ToDecimal(item.RateDir);
                    ltd.Amount = Convert.ToDecimal(item.AmountDir);
                    ltd.Item_Id = Convert.ToInt32(DBClass.getField("select Item_Id from inv_items where Item_Code=" + Convert.ToInt32(item.ItemCodeDir)));
                    db.GRN_Details.InsertOnSubmit(ltd);
                    db.SubmitChanges();
                }
            }
                return int.Parse(GRNNo);
            
        }

        [WebMethod]
        public static string LoadGRNHeaderDetail(int GRN_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Header = (from m in db.GRN_Masters
                          where m.GRN_ID == GRN_ID
                          select new
                          {
                              m.GRN_ID,
                              m.GRN_Num,
                              m.VendorId,
                              m.Remarks,
                              //m.DepartmentId,
                              m.GRN_Date,
                              m.IGP_Id,
                              m.InvOrgId,
                              m.Status,
                              m.Project,
                              m.is_Direct,
                              Vendor_Name = db.AP_Vendors.Where(po => po.Vendor_ID == Convert.ToInt32(m.VendorId)).Select(po => po.Vendor_Name),
                          }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(Header);
        }

        [WebMethod]
        public static string GetIGPNoByVendor(string venId)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var IGPList = (from tbl in db.Igp_masters
                           select new
                           {
                               Igp_Id = tbl.Igp_Id,
                               Igp_num = tbl.Igp_num,
                               vendorId = Convert.ToInt32(tbl.Vendor),
                               Status = tbl.Status,
                           }).Where(x => x.vendorId == Convert.ToInt32(venId) && x.Status == "Approved").ToList();
            return (new JavaScriptSerializer()).Serialize(IGPList);
        }
        [WebMethod]
        public static string LoadGRNDetailDir(int GRN_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var result = (from d in db.GRN_Details
                          join i in db.INV_Items
                              on d.Item_Id equals i.Item_ID
                          where d.GRNId == GRN_ID
                                && (d.IGPDetailId == null || d.IGPDetailId == 0)
                          select new
                          {
                              d.Item_Id,
                              d.ItemCode,
                              Description = i.Description,
                              d.GRNQty,
                              d.UOM_Qty,
                              d.BatchNum,
                              d.MfgDate,
                              d.ExpiryDate,
                              BounusQty = d.BounusQty,
                              d.Rate,
                              d.Amount
                          }).ToList();

            JavaScriptSerializer js = new JavaScriptSerializer();
            return js.Serialize(result);
        }

        [WebMethod]
        public static string LoadGRNDetail(int GRN_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_LoadGRNDetailByGRNId(GRN_ID).ToList();
            return (new JavaScriptSerializer()).Serialize(Details);
        }


        [WebMethod]
        public static string GetNewGRNNo()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var GRN_No = DBClass.GetNewNumber("GRN_Num", "GRN_Master", "");
            return GRN_No.ToString();
        }

        [WebMethod]
        public static string getVendorDDLlist()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var listItems = (from tbl in db.AP_Vendors
                                 //where tbl.IsActive==true
                             select new
                             {
                                 VendorID = tbl.Vendor_ID,
                                 VendorName = tbl.Vendor_Name,
                                 Active = tbl.IsActive,
                             }).ToList();
            return (new JavaScriptSerializer()).Serialize(listItems);
        }

        [WebMethod]
        public static string GetDepartments()
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
                             Type = v.ValueSet_Description == "Department" ? "Dept" : v.ValueSet_Description == "Ware House" ? "WareHouse" : "ComTyp"
                         }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);
        }
        
        [WebMethod]
        public static string GetProjects()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Cost Center"
                         select new ddlListItems
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(listItems);
        }
        [WebMethod]
        public static string getIGPByID(string IGPID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            int IGPId = Convert.ToInt32(IGPID);
            var listPurchaseOrderDetails = db.sp_GetIGP_DetailByIgpId(IGPId).ToList();
            return (new JavaScriptSerializer()).Serialize(listPurchaseOrderDetails);
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
        public static string ApproveGRN(string GRNId)
        {
            var userid = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.spApproveGRN(Convert.ToInt32(GRNId), userid);
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string UnApproveGRN(string GRNId)
        {
            var userid = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.spUnApproveGRN(Convert.ToInt32(GRNId), Convert.ToString(userid));
            return (new JavaScriptSerializer()).Serialize(Details);
        }

        private class ddlListItems
        {
            public string DataValueName;
            public string DataValueDescription;
            public string Type;
        }

        public class MasterGRNList
        {
            public string GRN_Num { get; set; }
            public string Date { get; set; }
            public string VendorId { get; set; }
            public string remarks { get; set; }

            public string InvOrg { get; set; }
            public string project { get; set; }
            public bool Is_Direct { get; set; }
            public List<DetailGRNList> ItemList { get; set; }
            public List<DetailGRNListDir> ItemListDir { get; set; }
        }

        public class DetailGRNList
        {
            public string ItemCode { get; set; }
            public string Mfgdate { get; set; }
            public string Expdate { get; set; }
            public string AccQty { get; set; }
            public string GRNQty { get; set; }
            public string IGPDetailId { get; set; }

        }

        public class DetailGRNListDir
        {
            public string ItemIdDir { get; set; }
            public string ItemCodeDir { get; set; }
            public string MfgdateDir { get; set; }
            public string ExpdateDir { get; set; }
            public string GRNQtyDir { get; set; }
            public string RateDir { get; set; }
            public string AmountDir { get; set; }
            public string UOMQtyDir { get; set; }
            public string BONQtyDir { get; set; }
            public string BatchNoDir { get; set; }
            public string IGPDetailId { get; set; }

        }
    }
}