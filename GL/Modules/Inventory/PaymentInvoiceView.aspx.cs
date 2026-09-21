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
    public partial class PaymentInvoiceView : System.Web.UI.Page
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
                var query = db.spGetAuditRecordAginstPay(invoiceId).ToList<object>();

                return query;
            }

        }
        [WebMethod]
        public static object GetMasterAndDetail(int invoiceId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                // Master record
                var master = (from m in db.Payment_Invoices
                              where m.PaymentInvoiceId == invoiceId
                              select new
                              {
                                  ID = m.PaymentInvoiceId,
                                  Number = m.PaymentNum,
                                  Date = m.PaymentDate,
                                  VendorName = DBClass.getField("select Vendor_Name from AP_Vendors where Vendor_ID=" + m.Vendor_ID),
                                  Status = m.Status,
                                  Remarks = m.Remarks
                              }).FirstOrDefault();

                // Detail rows
                var detail = (from d in db.Payment_Invoice_Details                             
                              where d.PaymentInvoiceId == invoiceId
                              select new
                              {
                                  d.AdjustedAmount,
                                  d.TotalPaidAmount,
                                  d.Withholdtaxamount,
                                  d.Payable,
                                  // d.BounusQty

                              }).ToList();

                return new
                {
                    Master = master,
                    Detail = detail
                };
            }
        }
        [WebMethod]
        public static bool isDeleteAllow()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            bool value = Convert.ToBoolean(DBClass.getField("select  isnull(AllowPatientDelete,0) from aspnet_users where username='" + AppConfig.UserName + "'"));
            return value;

        }

        [WebMethod]
        public static bool DeleteRecord(string InvID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                var Inv_Id = (from itm in db.Payment_Invoices
                              where (itm.PaymentInvoiceId == int.Parse(InvID))
                              select itm.PaymentInvoiceId).FirstOrDefault();
                if (Inv_Id != 0)
                {
                    DBClass.exectueQuery("delete Payment_Invoice_Detail where PaymentInvoiceId =" + Inv_Id, tranObj, con);
                    DBClass.exectueQuery("delete Payment_Invoice where PaymentInvoiceId =" + Inv_Id, tranObj, con);
                    tranObj.Commit();
                }
                else
                {
                    tranObj.Rollback();
                    return false;
                }
            }
#pragma warning disable CS0168 
            catch (Exception ex)
#pragma warning restore CS0168
            {
                if (tranObj != null)
                    tranObj.Rollback();
                return false;
            }
            return true;
        }


        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Invoices = _dbContext.Payment_Invoices.Count();
                    var Payment_Invoices = from PI in _dbContext.Payment_Invoices                                          
                                           where
                                        ((PI.PaymentNum.ToString().Contains(searchValue) || PI.Remarks.ToString().Contains(searchValue) || PI.InvoiceAdjusted.ToString().Contains(searchValue) || PI.Remarks.ToString().Contains(searchValue) || PI.Status.ToString().Contains(searchValue)))
                                           select new
                                           {
                                               PaymentInvoiceId = PI.PaymentInvoiceId,
                                               PaymentNum = Convert.ToInt32(PI.PaymentNum),
                                               PaymentDate = PI.PaymentDate,
                                               Status = PI.Status,
                                               PaidAmount = PI.PaidAmount,
                                               Amount = PI.InvoiceAdjusted,
                                               Remarks = PI.Remarks,
                                            PurchaseNo = (from gmm in _dbContext.Purchase_Invoice_Masters where gmm.PurchaseInvoiceId == (from gm in _dbContext.Payment_Invoice_Details where gm.Invoice_Type == "PUR" && gm.PaymentInvoiceId == PI.PaymentInvoiceId select gm.PurchaseInvoiceId).FirstOrDefault() select gmm.InvoiceNum).FirstOrDefault(),
                                            ManualNo = (from gmm in _dbContext.Manual_Invoices where gmm.ManualInvoiceId == (from gm in _dbContext.Payment_Invoice_Details where gm.Invoice_Type == "MINV" && gm.PaymentInvoiceId == PI.PaymentInvoiceId select gm.PurchaseInvoiceId).FirstOrDefault() select gmm.ManualInvoiceNum).FirstOrDefault(),
                                               VoucherNo = (from gm in _dbContext.GL_Vouchers where gm.Voucher_ID == PI.Voucher_ID select gm.Voucher_No.ToString()).FirstOrDefault(),
                                               
                                           };

                    var FilteredCount = Payment_Invoices.Count();
                    switch (sortColumn)
                    {
                        case "PaymentNum":
                            Payment_Invoices = sortColumnDirection == "asc" ? Payment_Invoices.OrderBy(a => a.PaymentNum) : Payment_Invoices.OrderByDescending(a => a.PaymentNum);
                            break;
                        case "ManualNo":
                            Payment_Invoices = sortColumnDirection == "asc" ? Payment_Invoices.OrderBy(b => b.ManualNo) : Payment_Invoices.OrderByDescending(a => a.ManualNo);
                            break;
                        default:
                            Payment_Invoices = Payment_Invoices.OrderByDescending(a => a.PaymentNum);
                            break;
                    }

                    var PaymentList = Payment_Invoices.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Invoices, data = PaymentList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Payment Invoice list", ex);
            }
        }


        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "PaymentInvoiceView";

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
                string pageName = "PaymentInvoiceView";

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

        // ================= PAYMENT INVOICE CHANGE HISTORY (Payment_Invoice_Logs) =================

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

        private static object BuildPaymentMasterSnapshot(Payment_Invoice pi, DataBaseDataContext db)
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

        [WebMethod]
        public static string GetPaymentLogs(long invId)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var logRows = (from l in db.Payment_Invoice_Logs
                                   join u in db.aspnet_Users on l.Loged_By equals u.UserId into userJoin
                                   from u in userJoin.DefaultIfEmpty()
                                   where l.PaymentInvoiceId == invId
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

                    var pi = db.Payment_Invoices.FirstOrDefault(x => x.PaymentInvoiceId == invId);

                    object currentMaster = null;
                    object currentDetails = null;

                    if (pi != null)
                    {
                        currentMaster = BuildPaymentMasterSnapshot(pi, db);
                        currentDetails = BuildPaymentDetailSnapshot(db, pi.PaymentInvoiceId);
                    }

                    var approvalRows = (from a in db.Sys_Approval_Logs
                                        join st in db.Sys_Approval_Stage_Masters on a.Approval_Stage_ID equals st.Stage_ID into stageJoin
                                        from st in stageJoin.DefaultIfEmpty()
                                        join au in db.aspnet_Users on a.Approve_By equals au.UserId into apprJoin
                                        from au in apprJoin.DefaultIfEmpty()
                                        join ru in db.aspnet_Users on a.Rejected_By equals ru.UserId into rejJoin
                                        from ru in rejJoin.DefaultIfEmpty()
                                        where a.Entry_ID == invId && a.Form_ID == 11
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


