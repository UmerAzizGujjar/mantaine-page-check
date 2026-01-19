using AjaxControlToolkit;
using Infragistics.Documents.Reports.Report;
using System;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Inventory
{
    public partial class InversionGatePass : System.Web.UI.Page
    {
        DataBaseDataContext db = new DataBaseDataContext();
        protected void Page_Load(object sender, EventArgs e)
        {
            HyperLink1.Visible = false;
            if (!IsPostBack)
            {
                if (Request.QueryString["IGP_ID"] != null)
                {
                    DataBaseDataContext db = new DataBaseDataContext();
                    var getID = Request.QueryString["IGP_ID"];
                    var gettype = (from a in db.Igp_masters where a.Igp_Id == Convert.ToInt32(getID) select a.File_Path).FirstOrDefault();
                    if (!string.IsNullOrEmpty(gettype))
                    {
                        HyperLink1.NavigateUrl = gettype;
                        HyperLink1.Visible = true;
                    }
                }
            }

        }
        public class MasterIGPList
        {
            public string Igp_num { get; set; }
            public string Date { get; set; }
            public string Vendor { get; set; }
            public string DriverName { get; set; }
            public string VehicleNum { get; set; }
            public string BilityNum { get; set; }
            public string remarks { get; set; }
            public string InvOrg { get; set; }
            public string InvType { get; set; }
            public List<DetailIGPList> ItemList { get; set; }
        }

        public class DetailIGPList
        {
            public string ItemCode { get; set; }
            public string ItemName { get; set; }
            public string Unit { get; set; }
            public string BatchNo { get; set; }
            public string Qty { get; set; }
            public string RcvQty { get; set; }
            public string POQty { get; set; }
            public string BlncQty { get; set; }
            public string IgpQty { get; set; }
            public string BounusQty { get; set; }
            public int PODetailId { get; set; }
            public string Mfgdate { get; set; }
            public string Expdate { get; set; }
        }
        public class IsnpIGPMasterList
        {
            public string IgpId { get; set; }
            public List<DetailIGPInspectionList> ItemList { get; set; }
        }
        public class DetailIGPInspectionList
        {
            public string ItemCode { get; set; }
            public string InspQty { get; set; }
            public string InspRemarks { get; set; }
            public int PODetailId { get; set; }
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
        private class ddlListItems
        {
            public string DataValueName;
            public string DataValueDescription;
            public string Type;
        }

        [WebMethod]
        public static int SaveIgpDetail(string btnSave, string AllItemDetail)
        {
            Igp_master obj = new Igp_master();
            string IgpNo = "";
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<MasterIGPList>(AllItemDetail);
            var lstItem = (from t in db.Igp_masters where t.Igp_num == int.Parse(record.Igp_num) select t).FirstOrDefault();
            if (btnSave == "Update")
            {
                lstItem.Igp_num = Convert.ToInt32(record.Igp_num);
                lstItem.Igp_date = Convert.ToDateTime(record.Date);
                lstItem.VehicleNum = record.VehicleNum;
                lstItem.DriverName = record.DriverName;
                lstItem.BilityNum = record.BilityNum;
                lstItem.Update_Date = DateTime.Now;
                lstItem.Updated_By = AppConfig.UserID;
                lstItem.InvOrgId = record.InvOrg;
                db.SubmitChanges();
                IgpNo = lstItem.Igp_Id.ToString();
            }
            else
            {
                obj.Igp_num = Convert.ToInt32(record.Igp_num);
                obj.Igp_date = Convert.ToDateTime(record.Date);
                obj.VehicleNum = record.VehicleNum;
                obj.DriverName = record.DriverName;
                obj.BilityNum = record.BilityNum;
                obj.Vendor = record.Vendor;
                obj.InvType = "SmpPO";
                obj.Remarks = record.remarks;
                obj.Creation_Date = DateTime.Now;
                obj.Created_By = AppConfig.UserID;
                obj.Company_ID = AppConfig.Company_ID;
                obj.IsDeleted = false;
                obj.Status = "Created";
                obj.InvOrgId = record.InvOrg;
                db.Igp_masters.InsertOnSubmit(obj);
                db.SubmitChanges();
                IgpNo = obj.Igp_Id.ToString();
            }
            ///**********Deleting Previous details**************/

            if (btnSave == "Update")
            {
                List<Igp_Detail> lstPOItemDetails = db.Igp_Details.Where(t => t.Igp_Id == int.Parse(IgpNo)).ToList(); db.Igp_Details.DeleteAllOnSubmit(lstPOItemDetails);
                db.SubmitChanges();
            }
            foreach (var POitem in record.ItemList)
            {
                Igp_Detail ltd = new Igp_Detail();
                ltd.Item_Code = Convert.ToInt32(POitem.ItemCode);
                ltd.Igp_Id = int.Parse(IgpNo);
                ltd.Qty = Convert.ToDecimal(POitem.Qty);
                ltd.RcvQty = Convert.ToDecimal(POitem.RcvQty);
                ltd.BlncQty = Convert.ToDecimal(POitem.BlncQty);
                ltd.POQty = Convert.ToDecimal(POitem.POQty);
                ltd.IGPQty = Convert.ToDecimal(POitem.IgpQty);
                ltd.BounusQty = Convert.ToDecimal(POitem.BounusQty);
                ltd.POQty = Convert.ToDecimal(POitem.POQty);
                ltd.PO_Item_ID = Convert.ToInt32(POitem.PODetailId);
                ltd.Item_Id = Convert.ToInt32(DBClass.getField("select Item_Id from inv_items where Item_Code=" + Convert.ToInt32(POitem.ItemCode)));
                ltd.BatchNum = POitem.BatchNo;
                if (POitem.Mfgdate != "")
                {
                    ltd.MfgDate = Convert.ToDateTime(POitem.Mfgdate);
                }
                if (POitem.Expdate != "")
                {
                    ltd.ExpiryDate = Convert.ToDateTime(POitem.Expdate);
                }
                db.Igp_Details.InsertOnSubmit(ltd);
                db.SubmitChanges();
            }
            return int.Parse(IgpNo);
        }



        [WebMethod]
        public static int SaveIgpInspectonDetail(string AllItemDetail)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<IsnpIGPMasterList>(AllItemDetail);
            try
            {
                foreach (var Igpitem in record.ItemList)
                {
                    var igpDetail = db.Igp_Details.FirstOrDefault(t => t.Igp_Id == int.Parse(record.IgpId) && t.PO_Item_ID == Igpitem.PODetailId && t.Item_Code == Convert.ToInt32(Igpitem.ItemCode));
                    if (igpDetail == null)
                    {
                        continue;
                    }
                    igpDetail.InspecQty = Convert.ToDecimal(Igpitem.InspQty);
                    igpDetail.RcvQty = Convert.ToDecimal(Igpitem.InspQty);
                    igpDetail.InspecRemarks = Convert.ToString(Igpitem.InspRemarks);
                }
                db.SubmitChanges();
                return 1;
            }
            catch (Exception ex)
            {
                return 0;
            }
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
                                   .Any(temp => temp.SATM.IsActive == true && temp.SATM.IsDeleted == false && temp.SATDF.FormId == 4 && temp.SATDO.UserId == uid);

                return hasEntryRights;
            }
        }


        [WebMethod]
        public static string LoadIGPHeaderDetail(int IGP_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Header = (from m in db.Igp_masters
                          where m.Igp_Id == IGP_ID
                          select new
                          {
                              m.Igp_num,
                              m.Igp_date,
                              m.Vendor,
                              m.Remarks,
                              m.DriverName,
                              m.VehicleNum,
                              m.BilityNum,
                              m.Status,
                              m.InvOrgId,
                              m.Inspec_Status,
                              Vendor_Name = db.AP_Vendors.Where(po => po.Vendor_ID == Convert.ToInt32(m.Vendor)).Select(po => po.Vendor_Name),
                              PO_ID = (from d in db.Igp_Details
                                       where d.Igp_Id == IGP_ID
                                       join poi in db.AP_Purchase_Order_Items on d.PO_Item_ID equals poi.PO_Item_ID
                                       select poi.PO_ID).FirstOrDefault(),
                              PO_No = (from d in db.Igp_Details
                                       where d.Igp_Id == IGP_ID
                                       join poi in db.AP_Purchase_Order_Items on d.PO_Item_ID equals poi.PO_Item_ID
                                       join po in db.AP_Purchase_Orders on poi.PO_ID equals po.PO_ID
                                       select po.PO_No).FirstOrDefault(),
                          }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(Header);
        }
        [WebMethod]
        public static string LoadIGPetail(int IGP_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_GetIGPDetailByIGPID(IGP_ID).ToList();
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string GetNewIgpNo()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var PO_No = DBClass.GetNewNumber("Igp_num", "Igp_master", "");
            return PO_No.ToString();
        }
        [WebMethod]
        public static string getVendorDDLlist()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var listItems = db.sp_LoadVendorIgp();
            return (new JavaScriptSerializer()).Serialize(listItems);
        }
        [WebMethod]
        public static string getVendorAfterApproveDDLlist()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var listItems = db.sp_LoadVendorAfterApproveIgp();
            return (new JavaScriptSerializer()).Serialize(listItems);
        }
       
        [WebMethod]

        public static string GetPONoByVendor(string venId)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var POList = db.sp_GetPOByVendorId(Convert.ToInt32(venId));
            return (new JavaScriptSerializer()).Serialize(POList);
        }
        [WebMethod]
        public static string GetWareHouses()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Department" || v.ValueSet_Description == "Ware House"
                         select new ddlListItems
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                             Type = v.ValueSet_Description == "Department" ? "Dept" : v.ValueSet_Description == "Ware House" ? "WareHouse" : "ComTyp"
                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(listItems);
        }


        //[WebMethod]
        //public static string getPurchaseOrderByID(string POID)
        //{
        //    DataBaseDataContext db = new DataBaseDataContext();
        //    int POId = Convert.ToInt32(POID);
        //    var listPurchaseOrderDetails = db.sp_GetPODetailByPOID(POId).ToList();

        //    var WareHouse = (from po in db.AP_Purchase_Orders
        //                     where po.PO_ID == POId
        //                     select po.Ware_House).FirstOrDefault();


        //    return (new JavaScriptSerializer()).Serialize(listPurchaseOrderDetails);
        //}
        [WebMethod]
        public static string getPurchaseOrderByID(string POID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            int POId = Convert.ToInt32(POID);

            var listPurchaseOrderDetails = db.sp_GetPODetailByPOID(POId).ToList();

            var WareHouse = (from po in db.AP_Purchase_Orders
                             where po.PO_ID == POId
                             select po.Ware_House).FirstOrDefault();

            var result = new
            {
                PurchaseOrderDetails = listPurchaseOrderDetails,
                WareHouse = WareHouse
            };

            return (new JavaScriptSerializer()).Serialize(result);
        }

        [WebMethod]
        public static string ApproveIgp(string IgpId)
        {
            var userid = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.spApproveIgp(Convert.ToInt32(IgpId), userid);
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string ApproveIgpInspec(string IgpId)
        {
            var user_id = AppConfig.UserID;
            var form_id = 4;
            var Details = "";
            DataBaseDataContext db = new DataBaseDataContext();
            Igp_master IGP = (from tbl in db.Igp_masters
                              where tbl.Igp_Id == Convert.ToInt32(IgpId)
                              select tbl).SingleOrDefault();
            if (IGP != null)
            {                  
                var IsFinalApprovals = (from SASD in db.Sys_Approval_Stage_Details
                                        join SASM in db.Sys_Approval_Stage_Masters on SASD.Stage_ID equals SASM.Stage_ID
                                        join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                                        join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATD.Tempelate_ID equals SATF.Tempelate_ID
                                        where SASD.UserId == user_id && SATF.FormId == form_id && SASM.IsDeleted == false
                                        select new { SASM.IsFinalApproval, SATF.FormId }).ToList();

                if (IsFinalApprovals.Any(approval => approval.IsFinalApproval == true && approval.FormId == form_id))
                {
                    if (IGP.Status == "Approved" && (IGP.Inspec_Status == null || IGP.Inspec_Status == "" || IGP.Inspec_Status == "Pending"))
                    {
                        var Det = db.spApproveIgpInspec(Convert.ToInt32(IGP.Igp_Id), Convert.ToString(user_id));
                        Details = "1";
                    }
                    db.SubmitChanges();
                }
                else
                {
                    IGP.Inspec_Status = "Pending";
                    IGP.InspApproved_Time = DateTime.Now;
                    IGP.InspApprovedBy = user_id;
                    Details = "1";
                    db.SubmitChanges();
                }
                db.SubmitChanges();
            }
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string UnApproveIgpInspec(string IgpId)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.spUnApproveIgpInspec(Convert.ToInt32(IgpId));
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string UnApproveIgP(string IgpId)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.spUnApproveIgp(Convert.ToInt32(IgpId));
            return (new JavaScriptSerializer()).Serialize(Details);
        }
    }
}