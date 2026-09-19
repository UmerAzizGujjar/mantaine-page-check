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
    public partial class AddPurchaseInvoice : System.Web.UI.Page
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
                    var gettype = (from a in db.Purchase_Invoice_Masters where a.PurchaseInvoiceId == Convert.ToInt32(getID) select a.FilePath).FirstOrDefault();
                    if (!string.IsNullOrEmpty(gettype))
                    {
                        HyperLink1.NavigateUrl = gettype;
                        HyperLink1.Visible = true;
                    }

                }
            }
        }
 
        [WebMethod]
        public static string Loadadvancepaymentdetail(int Inv_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_LoadAdvancePaymentforPurchaseInvoice(Inv_ID);
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string loadadvanceamount(string ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var decription = (from i in db.Advance_Payments
                              where i.Advance_ID == Convert.ToInt32(ID)
                              select new
                              {
                                  i.Advance_Amount,
                                  i.Paid_Amount,
                                  i.WithHoldTax_Amount,
                              }).ToList();
            return (new JavaScriptSerializer()).Serialize(decription);
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
                                  .Any(temp => temp.SATM.IsActive == true && temp.SATM.IsDeleted == false && temp.SATDF.FormId == 10 && temp.SATDO.UserId == uid);

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
        public static string loadadvancedetail(string venid)
        {
            string result = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            var itemsList = (from a in db.Advance_Payments
                             where a.Vendor_ID == Convert.ToInt32(venid)
                             select new
                             {
                                 a.Advance_ID,
                                 a.Advance_No,
                             }).ToList();
            if (itemsList != null)
            {
                result = (new JavaScriptSerializer()).Serialize(itemsList);
            }
            return result;
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
        public static string GetNewInvoiceNo()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var GRN_No = DBClass.GetNewNumber("InvoiceNum", "Purchase_Invoice_Master", "");
            return GRN_No.ToString();
        }
        [WebMethod]
        public static string GetDepartments()

        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Department" || v.ValueSet_Description == "Invoice Type" ||
                         v.ValueSet_Description == "Currency"
                         select new ddlListItems
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                             Type = v.ValueSet_Description == "Department" ? "Dept" : v.ValueSet_Description == "Invoice Type" ? "InvTyp" : v.ValueSet_Description == "Currency" ? "Cur" : "ComTyp"
                         }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);
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
            var code = db.sys_Parms.Where(x => x.Name == "Direct PO ON Purchase Invoice").Select(x => x.Code).FirstOrDefault();
            object listItems;
            if (code == "01")
            {
                listItems = db.sp_LoadVendorPurchaseOrders();
            }
            else
            {
                listItems = db.sp_LoadVendorPurchase();
            }

            return (new JavaScriptSerializer()).Serialize(listItems);
        }

        [WebMethod]
        public static string GetPOType()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var code = db.sys_Parms
                         .Where(x => x.Name == "Direct PO ON Purchase Invoice")
                         .Select(x => x.Code)
                         .FirstOrDefault();

            return code;
        }
        [WebMethod]
        public static string AllowDirectGRN()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var code = (from data in db.sys_Parms
                        where data.Name == "DirectGRN"
                        select data.Code).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(code);
        }
        [WebMethod]
        public static string getGRNDetailByVendorId(string vendorId,bool Is_Direct)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var listPurchaseDetails = db.sp_GetGRNDetailByVendorId_DirectGRN(Convert.ToInt32(vendorId), Is_Direct).ToList();
            return (new JavaScriptSerializer()).Serialize(listPurchaseDetails);
        }
        // ================= PURCHASE INVOICE CHANGE LOG HELPERS =================

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

        private static Dictionary<string, string> BuildPIMasterSnapshot(Purchase_Invoice_Master pi, DataBaseDataContext db)
        {
            string vendorName = "";
            if (!string.IsNullOrEmpty(pi.VendorId))
            {
                int vid;
                if (int.TryParse(pi.VendorId, out vid))
                {
                    var vn = (from v in db.AP_Vendors where v.Vendor_ID == vid select v.Vendor_Name).FirstOrDefault();
                    if (vn != null) vendorName = vn;
                }
            }

            string currencyName = "";
            if (!string.IsNullOrEmpty(pi.CurrencyId))
            {
                try { currencyName = db.GetDataValueName("Currency", pi.CurrencyId) ?? ""; }
                catch { currencyName = ""; }
            }

            string invoiceTypeName = "";
            if (!string.IsNullOrEmpty(pi.InvoiceTypeId))
            {
                try { invoiceTypeName = db.GetDataValueName("Invoice Type", pi.InvoiceTypeId) ?? ""; }
                catch { invoiceTypeName = ""; }
            }

            var snap = new Dictionary<string, string>();
            snap["InvoiceNum"] = pi.InvoiceNum.HasValue ? pi.InvoiceNum.Value.ToString() : "";
            snap["Invoice_Type"] = invoiceTypeName;
            snap["Invoice_Date"] = DateVal(pi.InvoiceDate);
            snap["Vendor_Name"] = vendorName;
            snap["Ref_Invoice_Num"] = StrVal(pi.RefInvoiceNum);
            snap["SalTax_Invoice_Num"] = StrVal(pi.SalTaxInvocieNum);
            snap["Accounting_Date"] = DateVal(pi.AccountingDate);
            snap["Due_Date"] = DateVal(pi.DueDate);
            snap["Currency"] = currencyName;
            snap["ExRate"] = NumVal(pi.ExRate);
            snap["Ex_Date"] = DateVal(pi.ExDate);
            snap["Total_Invoice_Amount"] = NumVal(pi.Total_Invoice_Amount);
            snap["Total_Advance_Adjusted"] = NumVal(pi.Total_Advance_Adjusted);
            snap["Discount_Amount"] = NumVal(pi.Discount_Amount);
            snap["Net_Amount"] = NumVal(pi.Net_Amount);
            snap["Direct_GRN"] = (pi.is_DirtGRN.HasValue && pi.is_DirtGRN.Value) ? "Yes" : "No";
            snap["Remarks"] = StrVal(pi.Remarks);
            snap["Status"] = StrVal(pi.Status);
            snap["Update_Time"] = DateVal(pi.UpdatedDate);
            return snap;
        }

        private static object BuildPIDetailSnapshot(DataBaseDataContext db, long purchaseInvoiceId)
        {
            var rows = db.Purchase_Invoice_Details.Where(t => t.PurchaseInvoiceId == purchaseInvoiceId).ToList();

            var ids = rows.Where(r => r.ItemId.HasValue).Select(r => (int)r.ItemId.Value).Distinct().ToList();
            var itemNames = new Dictionary<int, string>();
            var itemCodes = new Dictionary<int, string>();
            foreach (var id in ids)
            {
                var itm = db.INV_Items.Where(x => x.Item_ID == id)
                                       .Select(x => new { x.Description, x.Item_Code })
                                       .FirstOrDefault();
                itemNames[id] = itm != null ? (itm.Description ?? "") : "";
                itemCodes[id] = itm != null ? (itm.Item_Code ?? "") : "";
            }

            return new
            {
                Items = rows.Select(i =>
                {
                    string name = "";
                    string code = "";
                    if (i.ItemId.HasValue)
                    {
                        int key = (int)i.ItemId.Value;
                        if (itemNames.ContainsKey(key)) name = itemNames[key];
                        if (itemCodes.ContainsKey(key)) code = itemCodes[key];
                    }

                    return new
                    {
                        Item_Name = name,
                        Item_Code = code,
                        GRNDetailId = i.GRN_detail_Id.HasValue ? i.GRN_detail_Id.Value.ToString() : "",
                        BatchNum = StrVal(i.BatchNum),
                        Qty = NumVal(i.Qty),
                        Rate = NumVal(i.Rate),
                        Amount = NumVal(i.Amount),
                        TotalAmount = NumVal(i.TotalAmount),
                        DiscPer = NumVal(i.DiscPer),
                        DiscAmt = NumVal(i.DiscAmt),
                        Stax_Amount = NumVal(i.Stax_Amount),
                        AdvTax_Amount = NumVal(i.AdvTax_Amount),
                        FurtherTax_Amount = NumVal(i.FurtherTax_Amount),
                        Bonus_Qty = NumVal(i.Bonus_Qty),
                        Bonus_Tax = NumVal(i.Bonus_Tax)
                    };
                }).ToList()
            };
        }

        private static void WritePIChangeLog(DataBaseDataContext db, Purchase_Invoice_Master pi, JavaScriptSerializer serializer)
        {
            if (pi == null) return;

            Purchase_Invoice_Log log = new Purchase_Invoice_Log
            {
                PurchaseInvoiceId = pi.PurchaseInvoiceId,
                Master_Log = serializer.Serialize(BuildPIMasterSnapshot(pi, db)),
                Details_Log = serializer.Serialize(BuildPIDetailSnapshot(db, pi.PurchaseInvoiceId)),
                Loged_By = AppConfig.UserID,
                Log_Time = DateTime.Now
            };

            db.Purchase_Invoice_Logs.InsertOnSubmit(log);
        }

        [WebMethod]
        public static int SaveInvoice(string btnSave, string AllItemDetail)
        {
            string InvoiceId = "";
            Purchase_Invoice_Master PO = new Purchase_Invoice_Master();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();

            var record = oJS.Deserialize<MasterInoviceList>(AllItemDetail);
            var count = record.ItemList2.Count;
            int x = 1;
            var lstItem = (from t in db.Purchase_Invoice_Masters
                           where t.InvoiceNum == int.Parse(record.InvoiceNum)
                           select t).FirstOrDefault();
            if (btnSave == "Update")
            {
                WritePIChangeLog(db, lstItem, oJS);

                lstItem.InvoiceNum = Convert.ToInt64(record.InvoiceNum);
                lstItem.InvoiceTypeId = record.InvoiceType;
                lstItem.UpdatedDate = DateTime.Now;
                lstItem.UpdatedBy = AppConfig.UserID;
                lstItem.VendorId = record.VendorId;
                lstItem.RefInvoiceNum = record.RefInvoiceNum;
                lstItem.InvoiceDate = Convert.ToDateTime(record.InvoiceDate);
                lstItem.Company_ID = AppConfig.Company_ID;
                lstItem.AccountingDate = Convert.ToDateTime(record.InvoiceDate);
                lstItem.DueDate = Convert.ToDateTime(record.DueDate);
                lstItem.CurrencyId = record.Currency;
                lstItem.is_DirtGRN = record.Is_Direct;
                lstItem.SalTaxInvocieNum = record.SalTaxInvoiceNum;
                if (record.disc_amount != "")
                {
                    lstItem.Discount_Amount = Convert.ToDecimal(record.disc_amount);
                }
                if (record.ExRate != "")
                {
                    lstItem.ExRate = Convert.ToDecimal(record.ExRate);
                }
                if (record.totaladvanceadjusted != "")
                {
                    lstItem.Total_Advance_Adjusted = Convert.ToDecimal(record.totaladvanceadjusted);
                }
                if (record.totalinvoiceamount != "")
                {
                    lstItem.Total_Invoice_Amount = Convert.ToDecimal(record.totalinvoiceamount);
                }
                if (record.totalnetamount != "")
                {
                    lstItem.Net_Amount = Convert.ToDecimal(record.totalnetamount);
                }
                lstItem.Remarks = record.Remarks;
                lstItem.ExDate = Convert.ToDateTime(record.ExDate);
                db.SubmitChanges();
                InvoiceId = lstItem.PurchaseInvoiceId.ToString();
            }
            else
            {
                PO.InvoiceNum = Convert.ToInt64(record.InvoiceNum);
                PO.InvoiceTypeId = record.InvoiceType;
                PO.UpdatedDate = DateTime.Now;
                PO.UpdatedBy = AppConfig.UserID;
                PO.VendorId = record.VendorId;
                PO.RefInvoiceNum = record.RefInvoiceNum;
                PO.SalTaxInvocieNum = record.SalTaxInvoiceNum;
                PO.InvoiceDate = Convert.ToDateTime(record.InvoiceDate);
                PO.Company_ID = AppConfig.Company_ID;
                PO.AccountingDate = Convert.ToDateTime(record.InvoiceDate);
                PO.DueDate = Convert.ToDateTime(record.DueDate);
                PO.CurrencyId = record.Currency;
                PO.is_DirtGRN = record.Is_Direct;
                if (record.disc_amount != "")
                {
                    PO.Discount_Amount = Convert.ToDecimal(record.disc_amount);
                }
                if (record.ExRate != "")
                {
                    PO.ExRate = Convert.ToDecimal(record.ExRate);
                }
                if (record.totaladvanceadjusted != "")
                {
                    PO.Total_Advance_Adjusted = Convert.ToDecimal(record.totaladvanceadjusted);
                }
                if (record.totalinvoiceamount != "")
                {
                    PO.Total_Invoice_Amount = Convert.ToDecimal(record.totalinvoiceamount);
                }
                if (record.totalnetamount != "")
                {
                    PO.Net_Amount = Convert.ToDecimal(record.totalnetamount);
                }
                PO.Remarks = record.Remarks;
                PO.ExDate = Convert.ToDateTime(record.ExDate);
                PO.CreatedDate = DateTime.Now;
                PO.CreatedBy = AppConfig.UserID;
                PO.Company_ID = AppConfig.Company_ID;
                PO.Status = "Created";
                db.Purchase_Invoice_Masters.InsertOnSubmit(PO);
                db.SubmitChanges();
                InvoiceId = PO.PurchaseInvoiceId.ToString();
            }
            ///**********Deleting Previous details**************/
            if (btnSave == "Update")
            {
                List<Purchase_Invoice_Detail> lstPurchaseInvocieDetails = db.Purchase_Invoice_Details.Where(t => t.PurchaseInvoiceId == int.Parse(InvoiceId)).ToList();
                db.Purchase_Invoice_Details.DeleteAllOnSubmit(lstPurchaseInvocieDetails);
                db.SubmitChanges();
            }
            foreach (var Invoiceitem in record.ItemList)
            {
                Purchase_Invoice_Detail ltd = new Purchase_Invoice_Detail();
                ltd.PurchaseInvoiceId = Convert.ToInt64(InvoiceId);
                ltd.ItemId = Convert.ToInt32(Invoiceitem.ItemId);
                ltd.Qty = Convert.ToDecimal(Invoiceitem.Qty);
                ltd.Rate = Convert.ToDecimal(Invoiceitem.Rate);
                ltd.GRN_detail_Id = Convert.ToInt32(Invoiceitem.GRNDetailId);
                ltd.Po_Item_Id = Convert.ToInt32(Invoiceitem.PODetailId);
                ltd.Po_Id = Convert.ToInt32(Invoiceitem.POID);
                ltd.GRN_ID = Convert.ToInt32(Invoiceitem.GRNId);
                ltd.Amount = Convert.ToDecimal(Invoiceitem.TotalAmount);
                ltd.TotalAmount = Convert.ToDecimal(Invoiceitem.Amount);
                ltd.Stax_ID = Convert.ToInt32(Invoiceitem.staxid);
                ltd.Stax_Amount = Convert.ToDecimal(Invoiceitem.staxperc);
                ltd.DiscPer = Convert.ToDecimal(Invoiceitem.DiscPer);
                //ltd.DiscAmt = Convert.ToDecimal(Invoiceitem.DiscAmt);
                ltd.DiscAmt = string.IsNullOrEmpty(Invoiceitem.DiscAmt) ? 0 : Convert.ToDecimal(Invoiceitem.DiscAmt);
                ltd.Adv_Po_ID = Invoiceitem.AdvigpagainstPo;
                ltd.AdvTax_Id = string.IsNullOrEmpty(Invoiceitem.AdvTaxId) ? 0 : Convert.ToInt32(Invoiceitem.AdvTaxId);
                ltd.AdvTax_Amount = string.IsNullOrEmpty(Invoiceitem.AdvTaxAmount) ? 0 : Convert.ToDecimal(Invoiceitem.AdvTaxAmount);
                ltd.AdvTotalAmount = string.IsNullOrEmpty(Invoiceitem.AdvTotalAmount) ? 0 : Convert.ToDecimal(Invoiceitem.AdvTotalAmount);
                ltd.FurtherTax_Id = string.IsNullOrEmpty(Invoiceitem.FurtherTax_Id) ? 0 : Convert.ToInt32(Invoiceitem.FurtherTax_Id);
                ltd.FurtherTax_Amount = string.IsNullOrEmpty(Invoiceitem.FurtherTax_Amount) ? 0 : Convert.ToDecimal(Invoiceitem.FurtherTax_Amount);
                ltd.Bonus_Qty = string.IsNullOrEmpty(Invoiceitem.Bonus_Qty) ? 0 : Convert.ToDecimal(Invoiceitem.Bonus_Qty);
                ltd.Bonus_Tax = string.IsNullOrEmpty(Invoiceitem.Bonus_Tax) ? 0 : Convert.ToDecimal(Invoiceitem.Bonus_Tax);
                ltd.BatchNum = Invoiceitem.BatchNum;
                db.Purchase_Invoice_Details.InsertOnSubmit(ltd);
                db.SubmitChanges();
            }
            if (btnSave == "Update")
            {
                var xyzs = (from t in db.Advance_Payment_Purchase_Invoices
                           where t.PurchaseInvoiceId == int.Parse(InvoiceId) 
                           select t).FirstOrDefault();

                if (xyzs == null) {
                    foreach (var a in record.ItemList2)
                    {
                        Advance_Payment_Purchase_Invoice abc = new Advance_Payment_Purchase_Invoice();
                        abc.AdvancePayment_ID = Convert.ToInt32(a.advpaymentid);
                        abc.AdvancePayment_No = Convert.ToInt32(a.advpaymentno);
                        abc.Advance_Adjusted = Convert.ToDecimal(a.advadjusted);
                        abc.PurchaseInvoiceId = Convert.ToInt32(InvoiceId);
                        db.Advance_Payment_Purchase_Invoices.InsertOnSubmit(abc);
                        db.SubmitChanges();
                        var asd = (from t in db.Advance_Payments
                                   where t.Advance_ID == int.Parse(a.advpaymentid)
                                   select t).FirstOrDefault();
                        var adddd = asd.Advance_Amount;
                        var lesssss = adddd - Convert.ToDecimal(a.advadjusted);
                        asd.Advance_Amount = lesssss;
                        db.SubmitChanges();
                    }
                }
                else {
                    foreach (var a in record.ItemList2)
                    {
                        var asd = (from t in db.Advance_Payments
                                   where t.Advance_ID == int.Parse(a.advpaymentid)
                                   select t.Advance_Amount).FirstOrDefault();

                        var asd2 = (from t in db.Advance_Payments
                                    where t.Advance_ID == int.Parse(a.advpaymentid)
                                    select t).FirstOrDefault();

                        var ppp = (from t in db.Advance_Payment_Purchase_Invoices
                                   where t.PurchaseInvoiceId == int.Parse(InvoiceId) && t.AdvancePayment_ID == Convert.ToInt32(a.advpaymentid)

                                   select t.Advance_Adjusted).FirstOrDefault();

                        var yyy = ppp + asd;
                        asd2.Advance_Amount = yyy;
                        db.SubmitChanges();
                        var xyz = (from t in db.Advance_Payment_Purchase_Invoices
                                   where t.PurchaseInvoiceId == int.Parse(InvoiceId) && t.AdvancePayment_ID == Convert.ToInt32(a.advpaymentid)
                                   select t).FirstOrDefault();

                        xyz.AdvancePayment_ID = Convert.ToInt32(a.advpaymentid);
                        xyz.AdvancePayment_No = Convert.ToInt32(a.advpaymentno);
                        xyz.Advance_Adjusted = Convert.ToDecimal(a.advadjusted);
                        xyz.PurchaseInvoiceId = Convert.ToInt32(InvoiceId);
                        db.SubmitChanges();
                        var rrr = (from t in db.Advance_Payments
                                   where t.Advance_ID == int.Parse(a.advpaymentid)
                                   select t).FirstOrDefault();
                        var adddd = rrr.Advance_Amount;
                        var lesssss = adddd - Convert.ToDecimal(a.advadjusted);
                        rrr.Advance_Amount = lesssss;
                        db.SubmitChanges();
                    }
                }
                
            }
            else
            {
                foreach (var a in record.ItemList2)
                {
                    Advance_Payment_Purchase_Invoice abc = new Advance_Payment_Purchase_Invoice();
                    abc.AdvancePayment_ID = Convert.ToInt32(a.advpaymentid);
                    abc.AdvancePayment_No = Convert.ToInt32(a.advpaymentno);
                    abc.Advance_Adjusted = Convert.ToDecimal(a.advadjusted);
                    abc.PurchaseInvoiceId = Convert.ToInt32(InvoiceId);
                    db.Advance_Payment_Purchase_Invoices.InsertOnSubmit(abc);
                    db.SubmitChanges();
                    var asd = (from t in db.Advance_Payments
                               where t.Advance_ID == int.Parse(a.advpaymentid)
                               select t).FirstOrDefault();
                    var adddd = asd.Advance_Amount;
                    var lesssss = adddd - Convert.ToDecimal(a.advadjusted);
                    asd.Advance_Amount = lesssss;
                    db.SubmitChanges();
                }
            }

            return int.Parse(InvoiceId);
        }
        [WebMethod]
        public static string LoadInvoiceHeaderDetail(int Inv_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Header = (from m in db.Purchase_Invoice_Masters
                          where m.PurchaseInvoiceId == Inv_ID
                          select new
                          {
                              m.InvoiceNum,
                              m.InvoiceTypeId,
                              m.RefInvoiceNum,
                              m.VendorId,
                              m.SalTaxInvocieNum,
                              m.InvoiceDate,
                              m.AccountingDate,
                              m.DueDate,
                              m.CurrencyId,
                              m.ExRate,
                              m.Remarks,
                              m.ExDate,
                              m.Status,
                              m.Total_Advance_Adjusted,
                              m.Total_Invoice_Amount,
                              m.Net_Amount,
                              m.is_DirtGRN,
                              m.Discount_Amount,
                              Vendor_Name = db.AP_Vendors.Where(po => po.Vendor_ID == Convert.ToInt32(m.VendorId)).Select(po => po.Vendor_Name),
                          }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(Header);
        }
        [WebMethod]
        public static string LoadInvocieDetail(int Inv_ID, bool isDirct)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var code = db.sys_Parms.Where(x => x.Name == "Direct PO ON Purchase Invoice").Select(x => x.Code).FirstOrDefault();

            try
            {
                object Details;
                if (code == "01")
                    Details = db.sp_LoadPurchaseDetailInvoice_DirectPO(Inv_ID).ToList();
                else
                    Details = db.sp_LoadPurchaseDetailInvoice_DirctGRN(Inv_ID, isDirct).ToList();

                return new JavaScriptSerializer().Serialize(Details);
            }
            catch (InvalidCastException ex)
            {
                throw new Exception($"Cast Error in LoadInvocieDetail: {ex.Message}");
            }
        }
        [WebMethod]
        public static string ApprovePurchaseInvoice(string InvId)
        {
            var user_id = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.spApprovePurchase(Convert.ToInt32(InvId), user_id);
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string UnApprovePurchaseInvoice(string InvId)
        {
            var user_id = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.spUnApprovePurchase(Convert.ToInt32(InvId), Convert.ToString(user_id));
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        public class MasterInoviceList
        {
            public string InvoiceType { get; set; }
            public string InvoiceDate { get; set; }
            public string InvoiceNum { get; set; }
            public string VendorId { get; set; }
            public string RefInvoiceNum { get; set; }
            public string SalTaxInvoiceNum { get; set; }
            public string AccountingDate { get; set; }
            public string DueDate { get; set; }
            public string CurrencyId { get; set; }
            public string Branch { get; set; }
            public string ExRate { get; set; }
            public string Remarks { get; set; }
            public string ExDate { get; set; }
            public string Purchase_Date { get; set; }
            public string Currency { get; set; }
            public string totalinvoiceamount { get; set; }
            public string totaladvanceadjusted { get; set; }
            public string totalnetamount { get; set; }
            public bool Is_Direct { get; set; }
            public string disc_amount { get; set; }
            
            public List<InoiceDetailList> ItemList { get; set; }
            public List<InoiceDetailList2> ItemList2 { get; set; }
            public List<InoiceDetailList3> ItemList3 { get; set; }
        }
        public class InoiceDetailList
        {
            public string ItemId { get; set; }
            public string GRNId { get; set; }
            public string AdvTaxId { get; set; }
            public string AdvTaxAmount { get; set; }
            public string AdvTotalAmount { get; set; }
            public string GRNDetailId { get; set; }
            public string PODetailId { get; set; }
            public string POID { get; set; }
            public string PurchAseInvoiceId { get; set; }
            public string Rate { get; set; }
            public string Qty { get; set; }
            public string staxperc { get; set; }
            public string staxid { get; set; }
            public string DiscAmt { get; set; }
            public string DiscPer { get; set; }
            public string TotalAmount { get; set; }
            public string Amount { get; set; }
            public int AdvigpagainstPo { get; set; }
            public string FurtherTax_Id { get; set; }
            public string FurtherTax_Amount { get; set; }
            public string Bonus_Qty { get; set; }
            public string Bonus_Tax { get; set; }

            public string BatchNum { get; set; }
        }

        public class InoiceDetailList2
        {
            public string advpaymentno { get; set; }
            public string advpaymentid { get; set; }
            public string advadjusted { get; set; }
        }

        public class InoiceDetailList3
        {
            public string ddl_glcode { get; set; }
            public string accounting_descrip { get; set; }
            public string accounting_qty { get; set; }
            public string accounting_rate { get; set; }
            public string accounting_amount { get; set; }
        }

        [WebMethod]
        public static string getPODetailByVendorId(string vendorId)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            int vendorIdInt = Convert.ToInt32(vendorId);

            var query = from po in db.AP_Purchase_Orders
                        join pod in db.AP_Purchase_Order_Items
                            on po.PO_ID equals pod.PO_ID
                        join item in db.INV_Items
                            on pod.Item_Code.ToString() equals item.Item_Code.ToString()
                        join vendor in db.AP_Vendors
                            on po.Vendor_ID equals vendor.Vendor_ID
                        where po.Vendor_ID == vendorIdInt
                        && po.Status == "Approved"
                        && po.IsDeleted == false
                        && pod.Qty > 0
                        select new
                        {
                            PO_ID = po.PO_ID,
                            PO_Detail_ID = pod.PO_Item_ID,
                            PO_No = po.PO_No,
                            Item_Code = pod.Item_Code,
                            Description = item.Description,
                            Qty = pod.Qty,
                            Rate = pod.Rate,
                            Bonus_qty = pod.Bonus_Qty,
                            bonus_tax = pod.Bonus_Tax,
                            Sales_Tax = pod.SalTax_Id,
                            sale_tax_amt = pod.SalTax_Amount,
                            advancetax = pod.AdvanceTax_Amount,
                            advancetaxid = pod.AdvanceTax_ID,
                            further_tax = pod.FurtherTax_Amount,
                            further_taxid = pod.FurtherTax_Id,
                            //TotalAmount = pod.Qty * pod.Rate,
                            TotalAmountc = pod.Amount,
                            discount_per = pod.Discount_Percentage,
                            discount_amount = pod.Discount_Amount,
                            Vendor_Name = vendor.Vendor_Name,
                            PO_Date = po.PO_Date,
                            Delivery_Date = pod.Delivery_Date,
                            IsBatch = item.IsBatch,
                        };

            var result = query.ToList();
            return (new JavaScriptSerializer()).Serialize(result);
        }

        [WebMethod]
        public static bool CheckPIApprovalRights()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var form_id = 10;
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
        public static string GetPIApprovalInfo(string InvId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var invId = Convert.ToInt32(InvId);
                var user_id = AppConfig.UserID;
                var form_id = 10;

                var pi = db.Purchase_Invoice_Masters
                    .Where(p => p.PurchaseInvoiceId == invId)
                    .Select(p => new { p.Total_Invoice_Amount })
                    .FirstOrDefault();

                var totalAmount = pi != null ? (pi.Total_Invoice_Amount ?? 0m) : 0m;

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
        public static string ApproveSinglePI(string InvId, string approvalRemarks)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var invId = Convert.ToInt32(InvId);
                var user_id = AppConfig.UserID;
                var form_id = 10;

                var PIM = db.Purchase_Invoice_Masters
                    .Where(p => p.PurchaseInvoiceId == invId)
                    .SingleOrDefault();

                if (PIM == null)
                    return "Error: Purchase Invoice not found";

                var isFinalApprovals = (from SASD in db.Sys_Approval_Stage_Details
                                        join SASM in db.Sys_Approval_Stage_Masters on SASD.Stage_ID equals SASM.Stage_ID
                                        join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                                        join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATD.Tempelate_ID equals SATF.Tempelate_ID
                                        where SASD.UserId == user_id && SATF.FormId == form_id && SASM.IsDeleted == false
                                        select new { SASM.IsFinalApproval, SATF.FormId }).ToList();

                if (isFinalApprovals.Any(a => a.IsFinalApproval == true && a.FormId == form_id))
                {
                    var PICondition = (from sys in db.sys_Parms
                                       where sys.Name == "Direct PO ON Purchase Invoice"
                                       select sys.Code).FirstOrDefault();

                    if (PICondition == "01")
                    {
                        var Details = db.spApprovePurchaseInvoice_DirectFromPO(PIM.PurchaseInvoiceId, user_id);
                    }
                    else
                    {
                        var Details = db.spApprovePurchase(PIM.PurchaseInvoiceId, user_id);
                    }

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
                            log.Entry_ID = (int)PIM.PurchaseInvoiceId;
                            log.Form_ID = form_id;
                            log.From_Name = "Purchase Invoice";
                            log.Remarks = PIM.Remarks;
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
                    PIM.Status = "Pending";
                    PIM.Approved_Time = DateTime.Now;
                    PIM.Approved_By = user_id;
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
                            log.Entry_ID = (int)PIM.PurchaseInvoiceId;
                            log.Form_ID = form_id;
                            log.From_Name = "Purchase Invoice";
                            log.Remarks = PIM.Remarks;
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