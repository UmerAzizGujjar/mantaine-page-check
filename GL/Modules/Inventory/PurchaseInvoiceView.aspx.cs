using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace PMS.Inventory
{
    public partial class PurchaseInvoiceView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }
        [WebMethod]
        public static List<object> GetAuditInfo(int invoiceId)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.spGetAuditRecordAginstPurIvo(invoiceId).ToList<object>();
                
                return query;
            }
           
        }
        [WebMethod]
        public static object GetMasterAndDetail(int invoiceId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                // Master record
                var master = (from m in db.Purchase_Invoice_Masters
                              where m.PurchaseInvoiceId == invoiceId
                              select new
                              {
                                  m.PurchaseInvoiceId,
                                  m.InvoiceNum,
                                  m.CreatedDate,
                                  VendorName  = DBClass.getField("select Vendor_Name from AP_Vendors where Vendor_ID=" + m.VendorId),
                                  m.Status,
                                  m.Remarks
                              }).FirstOrDefault();

                // Detail rows
                var detail = (from d in db.Purchase_Invoice_Details
                              join inv in db.INV_Items on d.ItemId equals inv.Item_ID
                              where d.PurchaseInvoiceId == invoiceId
                              select new
                              {
                                  inv.Description,
                                  d.Qty,
                                  d.Rate,
                                  d.Amount,
                                  d.TotalAmount,
                                  d.DiscAmt,
                                  d.Stax_Amount,

                              }).ToList();

                return new
                {
                    Master = master,
                    Detail = detail
                };
            }
        }

        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Invoices = _dbContext.Purchase_Invoice_Masters.Count();
                    var Puchase_Invoices = from PIM in _dbContext.Purchase_Invoice_Masters
                                            join PID in _dbContext.Purchase_Invoice_Details on PIM.PurchaseInvoiceId equals PID.PurchaseInvoiceId
                                            where
                                            ((PIM.InvoiceNum.ToString().Contains(searchValue) || ((from gm in _dbContext.GRN_Masters where gm.GRN_ID == PID.GRN_ID select gm.GRN_Num).FirstOrDefault().ToString().Contains(searchValue) || (from gmm in _dbContext.Igp_masters where gmm.Igp_Id == (from gm in _dbContext.GRN_Masters where gm.GRN_ID == PID.GRN_ID select gm.IGP_Id).FirstOrDefault() select gmm.Igp_num).FirstOrDefault().ToString().Contains(searchValue))))
                                            group PIM by PIM.PurchaseInvoiceId into MasterGroup
                                            select new
                                            {
                                                VendorId = MasterGroup.FirstOrDefault().VendorId,
                                                PurchaseInvoiceId = MasterGroup.Key,
                                                InvoiceNum = MasterGroup.FirstOrDefault().InvoiceNum,
                                                VendorName = DBClass.getField("select Vendor_Name from AP_Vendors where Vendor_ID=" + MasterGroup.FirstOrDefault().VendorId),
                                                InvoiceDate = MasterGroup.FirstOrDefault().InvoiceDate,
                                                GrnNumber = (from gm in _dbContext.GRN_Masters where gm.GRN_ID == (from pid in _dbContext.Purchase_Invoice_Details  where pid.PurchaseInvoiceId == MasterGroup.Key
                                                                                 select pid.GRN_ID).FirstOrDefault() select gm.GRN_Num).FirstOrDefault(),
                                                IGPNumber = (from gmm in _dbContext.Igp_masters where gmm.Igp_Id == (from gm in _dbContext.GRN_Masters where gm.GRN_ID == (from pid in _dbContext.Purchase_Invoice_Details where pid.PurchaseInvoiceId == MasterGroup.Key select pid.GRN_ID).FirstOrDefault()
                                                                     select gm.IGP_Id).FirstOrDefault() select gmm.Igp_num).FirstOrDefault(),
                                                Remarks = MasterGroup.FirstOrDefault().Remarks,
                                                Status = MasterGroup.FirstOrDefault().Status,
                                                Amount = MasterGroup.FirstOrDefault().Total_Invoice_Amount,
                                                VoucherNo = (from gm in _dbContext.GL_Vouchers where gm.Voucher_ID == MasterGroup.FirstOrDefault().Voucher_ID
                                                             select gm.Voucher_No.ToString()).FirstOrDefault(),
                                            };

                    var FilteredCount = Puchase_Invoices.Count();
                    switch (sortColumn)
                    {
                        case "InvoiceNum":
                            Puchase_Invoices = sortColumnDirection == "asc" ? Puchase_Invoices.OrderBy(a => a.InvoiceNum) : Puchase_Invoices.OrderByDescending(a => a.InvoiceNum);
                            break;
                        case "GrnNumber":
                            Puchase_Invoices = sortColumnDirection == "asc" ? Puchase_Invoices.OrderBy(b => b.GrnNumber) : Puchase_Invoices.OrderByDescending(a => a.GrnNumber);
                            break;
                        default:
                            Puchase_Invoices = Puchase_Invoices.OrderByDescending(a => a.PurchaseInvoiceId);
                            break;
                    }

                    var PurchaseInvoiceList = Puchase_Invoices.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Invoices, data = PurchaseInvoiceList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Purchase Invoice list", ex);
            }
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "PurchaseInvoiceView";

                using (var db = new DataBaseDataContext())
                {
                    var pref = db.UserDataTablePreferences
                                  .FirstOrDefault(p => p.UserID == userId && p.PageName == pageName);

                    if (pref != null)
                        return pref.ColumnVisibility;
                    else
                        return "";
                }
            }
            catch (Exception ex)
            {
                return "";
            }
        }

        [WebMethod]
        public static void SaveUserColumnPreferences(string visibilityJson)
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "PurchaseInvoiceView";

                using (var db = new DataBaseDataContext())
                {
                    var existing = db.UserDataTablePreferences
                                     .FirstOrDefault(p => p.UserID == userId && p.PageName == pageName);

                    if (existing != null)
                    {
                        existing.ColumnVisibility = visibilityJson;
                    }
                    else
                    {
                        db.UserDataTablePreferences.InsertOnSubmit(new UserDataTablePreference
                        {
                            UserID = userId,
                            PageName = pageName,
                            ColumnVisibility = visibilityJson
                        });
                    }

                    db.SubmitChanges();
                }
            }
            catch (Exception ex)
            {
                throw;
            }
        }

        // ================= PURCHASE INVOICE CHANGE HISTORY (Purchase_Invoice_Logs) =================

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

        private static JToken ParseLogJson(string json)
        {
            if (string.IsNullOrWhiteSpace(json))
                return null;

            try { return JsonConvert.DeserializeObject<JToken>(json); }
            catch { return null; }
        }

        private static object BuildPIMasterSnapshot(Purchase_Invoice_Master pi, DataBaseDataContext db)
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

        [WebMethod]
        public static string GetPILogs(long invId)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var logRows = (from l in db.Purchase_Invoice_Logs
                                   join u in db.aspnet_Users on l.Loged_By equals u.UserId into userJoin
                                   from u in userJoin.DefaultIfEmpty()
                                   where l.PurchaseInvoiceId == invId
                                   orderby l.Log_Time, l.Log_Id
                                   select new
                                   {
                                       l.Log_Id,
                                       l.Log_Time,
                                       l.Master_Log,
                                       l.Details_Log,
                                       UserName = u != null ? u.UserName : null
                                   }).ToList();

                    var logs = logRows.Select(r => new
                    {
                        Log_Id = r.Log_Id,
                        TimeText = r.Log_Time.HasValue ? r.Log_Time.Value.ToString("dd MMM yyyy hh:mm tt") : "",
                        UserName = string.IsNullOrEmpty(r.UserName) ? "" : r.UserName,
                        Master = ParseLogJson(r.Master_Log),
                        Details = ParseLogJson(r.Details_Log)
                    }).ToList();

                    var pi = db.Purchase_Invoice_Masters.FirstOrDefault(x => x.PurchaseInvoiceId == invId);

                    object currentMaster = null;
                    object currentDetails = null;

                    if (pi != null)
                    {
                        currentMaster = BuildPIMasterSnapshot(pi, db);
                        currentDetails = BuildPIDetailSnapshot(db, pi.PurchaseInvoiceId);
                    }

                    var approvalRows = (from a in db.Sys_Approval_Logs
                                        join st in db.Sys_Approval_Stage_Masters on a.Approval_Stage_ID equals st.Stage_ID into stageJoin
                                        from st in stageJoin.DefaultIfEmpty()
                                        join au in db.aspnet_Users on a.Approve_By equals au.UserId into apprJoin
                                        from au in apprJoin.DefaultIfEmpty()
                                        join ru in db.aspnet_Users on a.Rejected_By equals ru.UserId into rejJoin
                                        from ru in rejJoin.DefaultIfEmpty()
                                        where a.Entry_ID == invId && a.Form_ID == 10
                                        orderby a.Approve_Date, a.ID
                                        select new
                                        {
                                            a.ID,
                                            StageName = st != null ? st.Stage_Name : null,
                                            a.Entry_Status,
                                            a.IsFinalAprroval,
                                            a.IsRejected,
                                            a.Is_ByPassed,
                                            a.IsEditableAfterApproval,
                                            Approver = au != null ? au.UserName : null,
                                            Rejector = ru != null ? ru.UserName : null,
                                            a.Approve_Date,
                                            a.Rejected_Date,
                                            a.Approval_Remarks,
                                            a.Rejection_Remarks,
                                            a.Remarks,
                                            a.From_Name
                                        }).ToList();

                    var approvals = approvalRows.Select(r => new
                    {
                        ID = r.ID,
                        StageName = StrVal(r.StageName),
                        Status = StrVal(r.Entry_Status),
                        IsFinal = r.IsFinalAprroval ?? false,
                        IsRejected = r.IsRejected ?? false,
                        IsByPassed = r.Is_ByPassed ?? false,
                        IsEditableAfterApproval = r.IsEditableAfterApproval ?? false,
                        User = !string.IsNullOrEmpty(r.Rejector) ? r.Rejector : StrVal(r.Approver),
                        DateText = (r.Rejected_Date ?? r.Approve_Date).HasValue
                            ? (r.Rejected_Date ?? r.Approve_Date).Value.ToString("dd MMM yyyy hh:mm tt")
                            : "",
                        Remarks = !string.IsNullOrEmpty(r.Rejection_Remarks)
                            ? r.Rejection_Remarks
                            : (!string.IsNullOrEmpty(r.Approval_Remarks) ? r.Approval_Remarks : StrVal(r.Remarks)),
                        FromName = StrVal(r.From_Name)
                    }).ToList();

                    return JsonConvert.SerializeObject(new
                    {
                        logs = logs,
                        current = new { master = currentMaster, details = currentDetails },
                        approvals = approvals
                    });
                }
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new { error = ex.Message });
            }
        }

    }
}