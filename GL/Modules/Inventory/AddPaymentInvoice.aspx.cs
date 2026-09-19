using System;
using System.Collections.Generic;
using System.Globalization;
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
                if (Request.QueryString["Inv_ID"] != null)
                {
                    DataBaseDataContext db = new DataBaseDataContext();
                    var getID = Request.QueryString["Inv_ID"];
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

        // ================= PAYMENT INVOICE CHANGE LOG HELPERS =================

        private static string StrVal(object v)
        {
            if (v == null) return "";
            return Convert.ToString(v, CultureInfo.InvariantCulture);
        }

        private static string NumVal(object v)
        {
            if (v == null) return "";
            try { return Convert.ToDecimal(v).ToString("0.##", CultureInfo.InvariantCulture); }
            catch { return ""; }
        }

        private static string DateVal(object v)
        {
            if (v == null) return "";
            try { return Convert.ToDateTime(v).ToString("yyyy-MM-dd", CultureInfo.InvariantCulture); }
            catch { return ""; }
        }

        private static Dictionary<string, string> BuildPaymentMasterSnapshot(Payment_Invoice pi, DataBaseDataContext db)
        {
            string accountName = "";
            if (pi.AccountId.HasValue)
            {
                var acc = (from a in db.GL_Accounts where a.Account_ID == pi.AccountId.Value
                           select new { a.Account_Code, a.Account_Name }).FirstOrDefault();
                if (acc != null) accountName = StrVal(acc.Account_Code) + "-" + StrVal(acc.Account_Name);
            }

            string vendorName = "";
            if (pi.Vendor_ID.HasValue)
            {
                var vn = (from v in db.AP_Vendors where v.Vendor_ID == pi.Vendor_ID.Value select v.Vendor_Name).FirstOrDefault();
                if (vn != null) vendorName = vn;
            }

            string paymentModeName = "";
            if (!string.IsNullOrEmpty(pi.PaymentModeId))
            {
                try { paymentModeName = db.GetDataValueName("Payment_Mode", pi.PaymentModeId) ?? ""; }
                catch { paymentModeName = ""; }
            }

            var snap = new Dictionary<string, string>();
            snap["PaymentNum"] = pi.PaymentNum.HasValue ? pi.PaymentNum.Value.ToString() : "";
            snap["Payment_Date"] = DateVal(pi.PaymentDate);
            snap["Account"] = accountName;
            snap["Payment_Mode"] = paymentModeName;
            snap["Document_No"] = StrVal(pi.DocumentNo);
            snap["Document_Date"] = DateVal(pi.DocumentDate);
            snap["Vendor_Name"] = vendorName;
            snap["Paid_Amount"] = NumVal(pi.PaidAmount);
            snap["Invoice_Adjusted"] = NumVal(pi.InvoiceAdjusted);
            snap["WTax_Amount"] = NumVal(pi.WTaxAmount);
            snap["Expenses"] = NumVal(pi.Expenses);
            snap["Remarks"] = StrVal(pi.Remarks);
            snap["Status"] = StrVal(pi.Status);
            snap["Update_Time"] = DateVal(pi.UpdatedDate);
            return snap;
        }

        private static object BuildPaymentDetailSnapshot(DataBaseDataContext db, long paymentInvoiceId)
        {
            var rows = db.Payment_Invoice_Details.Where(t => t.PaymentInvoiceId == paymentInvoiceId).ToList();

            var result = new List<object>();
            foreach (var i in rows)
            {
                string invoiceNo = "";
                if (i.PurchaseInvoiceId.HasValue)
                {
                    if (i.Invoice_Type == "PUR")
                    {
                        var num = (from m in db.Purchase_Invoice_Masters
                                   where m.PurchaseInvoiceId == i.PurchaseInvoiceId.Value
                                   select m.InvoiceNum).FirstOrDefault();
                        if (num.HasValue) invoiceNo = num.Value.ToString();
                    }
                    else
                    {
                        var num = (from m in db.Manual_Invoices
                                   where m.ManualInvoiceId == i.PurchaseInvoiceId.Value
                                   select m.ManualInvoiceNum).FirstOrDefault();
                        if (num.HasValue) invoiceNo = num.Value.ToString();
                    }
                }

                result.Add(new
                {
                    Invoice_Type = StrVal(i.Invoice_Type),
                    Invoice_No = invoiceNo,
                    Payable = NumVal(i.Payable),
                    Advance_Amount = NumVal(i.Advance_Amount),
                    AdjustedAmount = NumVal(i.AdjustedAmount),
                    Deduction = NumVal(i.Deduction),
                    Withholdtaxper = StrVal(i.Withholdtaxper),
                    Withholdtaxamount = NumVal(i.Withholdtaxamount),
                    Stax_Amount = NumVal(i.Stax_Amount),
                    TotalPaidAmount = NumVal(i.TotalPaidAmount)
                });
            }

            return new { Items = result };
        }

        private static void WritePaymentChangeLog(DataBaseDataContext db, Payment_Invoice pi, JavaScriptSerializer serializer)
        {
            if (pi == null) return;

            Payment_Invoice_Log log = new Payment_Invoice_Log
            {
                PaymentInvoiceId = pi.PaymentInvoiceId,
                Master_Log = serializer.Serialize(BuildPaymentMasterSnapshot(pi, db)),
                Details_Log = serializer.Serialize(BuildPaymentDetailSnapshot(db, pi.PaymentInvoiceId)),
                Loged_By = AppConfig.UserID,
                Log_Time = DateTime.Now
            };

            db.Payment_Invoice_Logs.InsertOnSubmit(log);
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
                WritePaymentChangeLog(db, lstItem, oJS);

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
            ///**********Deleting Previous details**************/

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
                ltd.Payable = Convert.ToDecimal(Invoiceitem.InvoiceAmount);
                ltd.Advance_Amount = Convert.ToDecimal(Invoiceitem.AdvanceAmount);
                ltd.AdjustedAmount = Convert.ToDecimal(Invoiceitem.AdjustedAmount);
                ltd.Deduction = Convert.ToDecimal(Invoiceitem.Deduction);
                ltd.TotalPaidAmount = Convert.ToDecimal(Invoiceitem.TotalPaidAmount);
                ltd.PurchaseInvoiceId = Convert.ToInt64(Invoiceitem.PurchaseInoviceId);
                ltd.Withholdinvadj = Convert.ToDecimal(Invoiceitem.withholdtaxadj);
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
            var Details = db.spUnApprovePayment(Convert.ToInt32(InvId), Convert.ToString(user_id));
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
            public string AdvanceAmount { get; set; }
            public string AdjustedAmount { get; set; }
            public string Deduction { get; set; }
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

        [WebMethod]
        public static bool CheckPAYMENTApprovalRights()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var form_id = 11;
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
        public static string GetPAYMENTApprovalInfo(string InvId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var invId = Convert.ToInt32(InvId);
                var user_id = AppConfig.UserID;
                var form_id = 11;

                var totalAmount = db.Payment_Invoices
                    .Where(p => p.PaymentInvoiceId == invId)
                    .Select(p => (decimal?)p.PaidAmount)
                    .FirstOrDefault() ?? 0m;

                var maxApprovalLimit = db.ExecuteQuery<decimal?>(
                    "SELECT MAX(SASD.MaxApprovalLimit) " +
                    "FROM Sys_Approval_Stage_Detail SASD " +
                    "INNER JOIN Sys_Approval_Stage_Master SASM ON SASD.Stage_ID = SASM.Stage_ID " +
                    "INNER JOIN Sys_Approval_Tempelate_Detail_Stages SATD ON SASM.Stage_ID = SATD.StageId " +
                    "INNER JOIN Sys_Approval_Tempelate_Detail_Forms SATF ON SATD.Tempelate_ID = SATF.Tempelate_ID " +
                    "INNER JOIN Sys_Approval_Tempelate_Master SATM ON SATD.Tempelate_ID = SATM.Tempelate_ID " +
                    "WHERE SASD.UserId = {0} AND SATF.FormId = {1} AND SATM.IsActive = 1 AND SASM.IsDeleted = 0",
                    user_id, form_id).FirstOrDefault() ?? 0m;

                var canApprove = maxApprovalLimit == -1m || totalAmount <= maxApprovalLimit;

                var result = new
                {
                    CanApprove = canApprove,
                    MaxApprovalLimit = maxApprovalLimit,
                    Amount = totalAmount
                };

                return (new JavaScriptSerializer()).Serialize(result);
            }
        }

        [WebMethod]
        public static string ApproveSinglePAYMENT(string InvId, string approvalRemarks)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var invId = Convert.ToInt32(InvId);
                var user_id = AppConfig.UserID;
                var form_id = 11;

                var PAYMENT = db.Payment_Invoices
                    .Where(p => p.PaymentInvoiceId == invId)
                    .SingleOrDefault();

                if (PAYMENT == null)
                    return "Error: Payment Invoice not found";

                var isFinalApprovals = (from SASD in db.Sys_Approval_Stage_Details
                                        join SASM in db.Sys_Approval_Stage_Masters on SASD.Stage_ID equals SASM.Stage_ID
                                        join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                                        join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATD.Tempelate_ID equals SATF.Tempelate_ID
                                        where SASD.UserId == user_id && SATF.FormId == form_id && SASM.IsDeleted == false
                                        select new { SASM.IsFinalApproval, SATF.FormId }).ToList();

                if (isFinalApprovals.Any(a => a.IsFinalApproval == true && a.FormId == form_id))
                {
                    var Details = db.SpApprovePayment(invId, user_id);
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
                            log.Entry_ID = (int)PAYMENT.PaymentInvoiceId;
                            log.Form_ID = form_id;
                            log.From_Name = "Payment";
                            log.Remarks = PAYMENT.Remarks;
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
                    PAYMENT.Status = "Pending";
                    PAYMENT.Approved_Time = DateTime.Now;
                    PAYMENT.Approved_By = user_id;
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
                            log.Entry_ID = (int)PAYMENT.PaymentInvoiceId;
                            log.Form_ID = form_id;
                            log.From_Name = "Payment";
                            log.Remarks = PAYMENT.Remarks;
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