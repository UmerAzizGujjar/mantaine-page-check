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
    public partial class AddPaymentInvoice : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            HyperLink1.Visible = false;
            if (!IsPostBack)
            {
                if (Request.QueryString["ID"] != null)
                {
                    DataBaseDataContext db = new DataBaseDataContext();
                    var getID = Request.QueryString["ID"];
                    var gettype = (from a in db.Payment_Invoices where a.PaymentInvoiceId == Convert.ToInt32(getID) select a.FilePath).FirstOrDefault();
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
            var query = (from a in db.WithHold_Taxes
                         select new
                         {
                             a.WithHold_Tax_ID,
                             a.WithHold_Tax_Perc,
                         }).ToList();
            string data = string.Empty;          
            return (new JavaScriptSerializer()).Serialize(query);
        } 
        [WebMethod]
        public static string getStaxtype()
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
        public static string GetNewPaymentInvoiceNo()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var Payment_No = DBClass.GetNewNumber("PaymentNum", "Payment_Invoice", "");
            return Payment_No.ToString();
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
                                   .Any(temp => temp.SATM.IsActive == true && temp.SATM.IsDeleted == false && temp.SATDF.FormId == 11 && temp.SATDO.UserId == uid);

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
        public static string GetBank()
        {
            string result = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            var itemsList = (from i in db.GL_Accounts where i.Levels == 4 && (i.Bank == true || i.Cash == true) select new { i.Account_ID, name = i.Account_Code.ToString() + '-' + i.Account_Name }).ToList();
            if (itemsList != null)
            {
                result = (new JavaScriptSerializer()).Serialize(itemsList);
            }
            return result;
           
        }
        [WebMethod]
        public static string GetManualInvoiceDetailAndGetPurchaseInvoiceNDetailByVendorId(string vendorId)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            int vendId = Convert.ToInt32(vendorId);
            var listPurchaseDetails = db.sp_GetManualInvoiceDetailAndGetPurchaseInvoiceNDetailByVendorId(vendId).ToList();
            return (new JavaScriptSerializer()).Serialize(listPurchaseDetails);
        }
        [WebMethod]
        public static string getVendorDDLlist()
        {
            DataBaseDataContext db = new DataBaseDataContext();
           
            var listItems = db.sp_LoadVendorPayment();
            return (new JavaScriptSerializer()).Serialize(listItems);
        }

        [WebMethod]
        public static string getzeroVendorDDLlist(string invid)
        {
            DataBaseDataContext db = new DataBaseDataContext();
          
            var listItems = db.sp_LoadzeroVendorPayment(Convert.ToInt32(invid));
            return (new JavaScriptSerializer()).Serialize(listItems);
        }


        [WebMethod]
        public static string GetPaymentMode()

        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Payment_Mode"
                         select new ddlListItems
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                             Type = v.ValueSet_Description == "Payment_Mode" ? "Pay" : "ComTyp"
                         }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);
        }

        [WebMethod]
        public static int SavePaymentInvoice(string btnSave, string AllItemDetail)
        {
            string PaymentInvoiceId = "";
            Payment_Invoice PO = new Payment_Invoice();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<MasterInoviceList>(AllItemDetail);
            var lstItem = (from t in db.Payment_Invoices
                           where t.PaymentNum == int.Parse(record.PaymentNum)
                           select t).FirstOrDefault();
            if (btnSave == "Update")
            {
                lstItem.PaymentNum = Convert.ToInt32(record.PaymentNum);
                lstItem.PaymentDate = Convert.ToDateTime(record.PaymentDate);
                lstItem.UpdatedDate = DateTime.Now;
                lstItem.UpdatedBy = AppConfig.UserID;
                lstItem.AccountId = Convert.ToInt32(record.AccountId);
                lstItem.PaymentModeId = record.PaymentModeId;
                lstItem.DocumentNo = record.DocumentNum;
                lstItem.DocumentDate = Convert.ToDateTime(record.DocumentDate);
                lstItem.Vendor_ID = Convert.ToInt32(record.Vendorid);
                if (record.Expenses != "")
                {
                    lstItem.Expenses = Convert.ToDecimal(record.Expenses);
                }
                if (record.PaidAmount != "")
                {
                    lstItem.PaidAmount = Convert.ToDecimal(record.PaidAmount);
                }
                if (record.InvoiceAdjusted != "")
                {
                    lstItem.InvoiceAdjusted = Convert.ToDecimal(record.InvoiceAdjusted);
                }
                if (record.WTaxAmount != "")
                {
                    lstItem.WTaxAmount = Convert.ToDecimal(record.WTaxAmount);
                }
                lstItem.Remarks = record.Remarks;
                db.SubmitChanges();
                PaymentInvoiceId = lstItem.PaymentInvoiceId.ToString();
            }
            else
            {
                PO.PaymentNum = Convert.ToInt32(record.PaymentNum);
                PO.PaymentDate = Convert.ToDateTime(record.PaymentDate);              
                PO.AccountId = Convert.ToInt32(record.AccountId);
                PO.PaymentModeId = record.PaymentModeId;
                PO.DocumentNo = record.DocumentNum;
                PO.DocumentDate = Convert.ToDateTime(record.DocumentDate);
                PO.Vendor_ID = Convert.ToInt32(record.Vendorid);
                if (record.Expenses != "")
                {
                    PO.Expenses = Convert.ToDecimal(record.Expenses);
                }
                if (record.PaidAmount != "")
                {
                    PO.PaidAmount = Convert.ToDecimal(record.PaidAmount);
                }
                if (record.InvoiceAdjusted != "")
                {
                    PO.InvoiceAdjusted = Convert.ToDecimal(record.InvoiceAdjusted);
                }
                if (record.WTaxAmount != "")
                {
                    PO.WTaxAmount = Convert.ToDecimal(record.WTaxAmount);
                }
                PO.Remarks = record.Remarks;
                PO.CreatedDate = DateTime.Now;
                PO.CreatedBy = AppConfig.UserID;
                PO.Company_ID = AppConfig.Company_ID;
                PO.Status = "Created";
                db.Payment_Invoices.InsertOnSubmit(PO);
                db.SubmitChanges();
                PaymentInvoiceId = PO.PaymentInvoiceId.ToString();
            }

            if (btnSave == "Update")
            {
                List<Payment_Invoice_Detail> lstPaymnentInvocieDetails = db.Payment_Invoice_Details.Where(t => t.PaymentInvoiceId == int.Parse(PaymentInvoiceId)).ToList();
                db.Payment_Invoice_Details.DeleteAllOnSubmit(lstPaymnentInvocieDetails);
                db.SubmitChanges();
            }
            foreach (var Invoiceitem in record.ItemList)
            {
                Payment_Invoice_Detail ltd = new Payment_Invoice_Detail();
                ltd.PaymentInvoiceId = Convert.ToInt64(PaymentInvoiceId);
                ltd.AdjustedAmount = Convert.ToDecimal(Invoiceitem.AdjustedAmount);
                ltd.TotalPaidAmount = Convert.ToDecimal(Invoiceitem.TotalPaidAmount);
                ltd.PurchaseInvoiceId = Convert.ToInt64(Invoiceitem.PurchaseInoviceId);
                ltd.Withholdinvadj = Convert.ToDecimal(Invoiceitem.withholdtaxadj);
                ltd.Payable = Convert.ToDecimal(Invoiceitem.InvoicePayable);
                ltd.Withholdtaxamount = Convert.ToDecimal(Invoiceitem.withholdtaxamou);
                ltd.Withholdtaxper = Invoiceitem.wthtaxper;
                ltd.WithHoldtax_ID = Convert.ToInt32(Invoiceitem.withholdtaxid);
                ltd.Invoice_Type = Invoiceitem.InvoiceType;
                ltd.Total_Advance_Adjusted = Convert.ToDecimal(Invoiceitem.txtadvamount);
                ltd.Stax_Amount = Convert.ToDecimal(Invoiceitem.SalTaxAmount);
                ltd.Stax_ID = Convert.ToInt32(Invoiceitem.ddlSalTaxid);
                db.Payment_Invoice_Details.InsertOnSubmit(ltd);
                db.SubmitChanges();
            }
            return int.Parse(PaymentInvoiceId);
        }

        [WebMethod]
        public static string LoadPaymentInvoiceHeaderDetail(int Inv_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Header = (from m in db.Payment_Invoices
                          where m.PaymentInvoiceId == Inv_ID
                          select new
                          {
                              m.PaymentNum,
                              m.PaymentDate,
                              m.UpdatedDate,
                              m.UpdatedBy,
                              m.AccountId,
                              m.PaymentModeId,
                              m.DocumentNo,
                              m.Vendor_ID,
                              m.PaidAmount,
                              m.InvoiceAdjusted,
                              m.WTaxAmount,
                              m.DocumentDate,
                              m.Remarks,
                              m.Expenses,
                              m.Status,
                              m.FilePath,
                              m.FileType,
                              Vendor_Name = db.AP_Vendors.Where(po => po.Vendor_ID == Convert.ToInt32(m.Vendor_ID)).Select(po => po.Vendor_Name),
                          }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(Header);
        }
        [WebMethod]
        public static string LoadPaymentInvoiceDetail(int Inv_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_LoadPaymentInvoice(Inv_ID).ToList();
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string getPurchaseInvoiceNDetailByVendorId(string vendorId)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            int vendId = Convert.ToInt32(vendorId);
            var listPurchaseDetails = db.sp_GetPurchaseInvoiceNDetailByVendorId(vendId).ToList();
            return (new JavaScriptSerializer()).Serialize(listPurchaseDetails);
        }
       
        [WebMethod]
        public static string getManualInvoiceNDetailByVendorId(string vendorId)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            int vendId = Convert.ToInt32(vendorId);
            var listPurchaseDetails = db.sp_GetManualInvoiceDetailByVendorId(vendId).ToList();
            return (new JavaScriptSerializer()).Serialize(listPurchaseDetails);
        }
        [WebMethod]
        public static string ApprovePayment(string InvId)
        {
            var user_id = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.SpApprovePayment(Convert.ToInt32(InvId), user_id);
            return (new JavaScriptSerializer()).Serialize(Details);
        }
     
        [WebMethod]
        public static string UnApprovePayment(string InvId)
        {
            var user_id = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.spUnApprovePayment(Convert.ToInt32(InvId),Convert.ToString(user_id));
            return (new JavaScriptSerializer()).Serialize(Details);
        }

        private class ddlListItems
        {
            public string DataValueName;
            public string DataValueDescription;
            public string Type;
        }

        public class MasterInoviceList
        {
            public string PaymentNum { get; set; }
            public string PaymentDate { get; set; }
            public string AccountId { get; set; }
            public string PaymentModeId { get; set; }
            public string DocumentNum { get; set; }
            public string Branch { get; set; }
            public string DocumentDate { get; set; }
            public string Vendorid { get; set; }
            public string Expenses { get; set; }
            public string PaidAmount { get; set; }
            public string InvoiceAdjusted { get; set; }
            public string WTaxAmount { get; set; }
            public string Remarks { get; set; }
            public List<InoiceDetailList> ItemList { get; set; }
        }
        public class InoiceDetailList
        {
            public string PurchaseInoviceId { get; set; }
            public string InvoiceNum { get; set; }
            public string InvoiceAmount { get; set; }
            public string AdjustedAmount { get; set; }
            public string InvoicePayable { get; set; }
            public string withholdtaxamou { get; set; }
            public string withholdtaxadj { get; set; }
            public string wthtaxper { get; set; }
            public string withholdtaxid { get; set; }
            public string TotalPaidAmount { get; set; }
            public string InvoiceType { get; set; }
            public string txtadvamount { get; set; }
            public int AdvPoId { get; set; }
            public string ddlSalTaxid { get; set; }
            public string SalTaxAmount { get; set; }
        }
    }
}