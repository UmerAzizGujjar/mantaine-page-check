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

    public partial class AddManualInvoice : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            HyperLink1.Visible = false;
            if (!IsPostBack)
            {
                if (Request.QueryString["Inv_ID"] != null)
                {
                    DataBaseDataContext db = new DataBaseDataContext();
                    var getID = Request.QueryString["Inv_ID"];
                    var gettype = (from a in db.Manual_Invoices where a.ManualInvoiceId == Convert.ToInt32(getID) select a.File_Path).FirstOrDefault();
                    if (!string.IsNullOrEmpty(gettype))
                    {

                        HyperLink1.NavigateUrl = gettype;
                        HyperLink1.Visible = true;
                    }
                }
            }

        }

        [WebMethod]
        public static string getwtaxtype()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from a in db.Sales_Taxes
                         select new
                         {
                             a.Sales_Tax_ID,
                             a.Sales_Tax_Perc,
                         }).ToList();

            string data = string.Empty;

            return (new JavaScriptSerializer()).Serialize(query);
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
                                  .Any(temp => temp.SATM.IsActive == true && temp.SATM.IsDeleted == false && temp.SATDF.FormId == 9 && temp.SATDO.UserId == uid);
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
        public static string loadAccountList()
        {
            string result = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            var itemsList = (from i in db.GL_Accounts
                             where i.Levels == 4
                             select new
                             {
                                 i.Account_ID,
                                 name = i.Account_Code.ToString() + '-' + i.Account_Name
                             }).ToList();
            if (itemsList != null)
            {
                result = (new JavaScriptSerializer()).Serialize(itemsList);
            }
            return result;
        }

        [WebMethod]
        public static string getDDLlist()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Ware House" || v.ValueSet_Description == "Department"
                         select new ddlListItems
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                             Type = v.ValueSet_Description == "Department" ? "DPT" : "INV"
                         }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);
        }

        [WebMethod]
        public static int SaveInvoice(string btnSave, string AllItemDetail)
        {
            Manual_Invoice obj = new Manual_Invoice();
            string InvNo = "";
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<MasterInvoiceList>(AllItemDetail);
            if (btnSave == "Update")
            {
                var lstItem = (from t in db.Manual_Invoices
                               where t.ManualInvoiceNum == int.Parse(record.Invoice_num)
                               select t).FirstOrDefault();
                lstItem.ManualInvoiceNum = Convert.ToInt32(record.Invoice_num);
                lstItem.ManualInvoiceDate = Convert.ToDateTime(record.Date);
                lstItem.RefInvoiceNum = record.RefInvoicenum;
                lstItem.VendorId = Convert.ToInt32(record.VendorId);
                lstItem.UpdatedDate = DateTime.Now;
                lstItem.UpdatedBy = AppConfig.UserID;
                lstItem.Status = "Created";
                lstItem.Remarks = record.Remarks;
                db.SubmitChanges();
                InvNo = lstItem.ManualInvoiceId.ToString();
            }
            else
            {
                obj.ManualInvoiceNum = DBClass.GetNewNumber("ManualInvoiceNum", "Manual_Invoice", "");
                obj.ManualInvoiceDate = Convert.ToDateTime(record.Date);
                obj.RefInvoiceNum = record.RefInvoicenum;
                obj.VendorId = Convert.ToInt32(record.VendorId);
                obj.CreatedDate = DateTime.Now;
                obj.CreatedBy = AppConfig.UserID;
                obj.Status = "Created";
                obj.Remarks = record.Remarks;
                obj.IsDeleted = false;
                db.Manual_Invoices.InsertOnSubmit(obj);
                db.SubmitChanges();
                InvNo = obj.ManualInvoiceId.ToString();
            }

            if (btnSave == "Update")
            {
                List<Manual_Invoice_Detail> lstItemDetails = db.Manual_Invoice_Details.Where(t => t.ManualInvoiceId == int.Parse(InvNo)).ToList();
                db.Manual_Invoice_Details.DeleteAllOnSubmit(lstItemDetails);
                db.SubmitChanges();
            }

            foreach (var POitem in record.ItemList)
            {
                Manual_Invoice_Detail ltd = new Manual_Invoice_Detail();
                ltd.AccountId = Convert.ToInt32(POitem.AccountId);
                ltd.ManualInvoiceId = long.Parse(InvNo);
                ltd.Qty = Convert.ToDecimal(POitem.Qty);
                ltd.Rate = Convert.ToDecimal(POitem.Rate);
                ltd.DepartmentId = POitem.DepartmentId;
                ltd.Description = POitem.Description;
                ltd.TotalAmount = Convert.ToDecimal(POitem.TotalAmount);
                ltd.SalTax_Id = POitem.ddlstax;
                if (POitem.stamount != "")
                {
                    ltd.SalTax_Percentage = Convert.ToDecimal(POitem.stamount);
                }
                db.Manual_Invoice_Details.InsertOnSubmit(ltd);
                db.SubmitChanges();
            }
            return int.Parse(InvNo);
        }

        [WebMethod]
        public static string LoadManualInvoiceHeaderDetail(int Inv_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Header = (from m in db.Manual_Invoices
                          where m.ManualInvoiceId == Inv_ID
                          select new
                          {
                              m.ManualInvoiceNum,
                              m.ManualInvoiceDate,
                              m.RefInvoiceNum,
                              m.VendorId,
                              m.Remarks,
                              m.Status,
                              Vendor_Name = db.AP_Vendors.Where(po => po.Vendor_ID == Convert.ToInt32(m.VendorId)).Select(po => po.Vendor_Name),
                          }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(Header);
        }

        [WebMethod]
        public static string LoadInvocieDetail(int Inv_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_GetManualInvoiceDetailId(Inv_ID);
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string GetNewInvNo()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var PO_No = DBClass.GetNewNumber("ManualInvoiceNum", "Manual_Invoice", "");
            return PO_No.ToString();
        }

        [WebMethod]
        public static string ApproveManualInvoice(string InvId)
        {
            var userid = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.spApproveManualInvoice(Convert.ToInt32(InvId), Convert.ToString(userid));
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string UnApproveManualInvoice(string InvId)
        {
            var userid = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.spUnApproveManualInvoice(Convert.ToInt32(InvId), Convert.ToString(userid));
            return (new JavaScriptSerializer()).Serialize(Details);
        }

        private class ddlListItems
        {
            public string DataValueName;
            public string DataValueDescription;
            public string Type;
        }

        public class MasterInvoiceList
        {
            public string Invoice_num{get;set;}
            public string Date{get;set;}
            public string RefInvoicenum{get;set;}
            public string VendorId{get;set;}
            public string project{get;set;}
            public string Remarks{get;set;}
            public List<DetailInvoiceList> ItemList{get;set;}
        }

        public class DetailInvoiceList
        {
            public string AccountId{get;set;}
            public string Description{get;set;}
            public string DepartmentId{get;set;}
            public string Qty{get;set;}
            public string Rate{get;set;}
            public string ddlstax{get;set;}
            public string stamount{get;set;}
            public string TotalAmount{get;set;}
        }
    }
}