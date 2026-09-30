using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Runtime.Remoting.Contexts;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static PMS.BillingProcess;

namespace PMS
{
    public partial class BillingProcessView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string DeleteRecord(int Bill_ID)
        {
            List<string> ReceiptNos = new List<string>();

            DataBaseDataContext db = new DataBaseDataContext();

            #region "Checking receipts."

            var rcptList = (from r in db.Receipts
                            where r.Bill_ID == Bill_ID
                            select new { r.Receipt_No, r.Bill_ID }).ToList();
            StringBuilder data = new StringBuilder();

            foreach (var item in rcptList)
            {
                data.Append(item.Receipt_No);
                data.Append(",");
            }
            if (data.Length > 0)
            {
                return "Delete Following Receipts." + data;
            }

            #endregion

            var BillHeader = db.Ar_Billings.Where(b => b.Bill_ID == Bill_ID).FirstOrDefault();

            var BillDetails = (from d in db.Ar_Billing_Details
                               join m in db.Ar_Billings
                               on d.Bill_ID equals m.Bill_ID
                               where m.Bill_ID == Bill_ID
                               select d).ToList();

            foreach (var item in BillDetails)
            {
                if (item.ParentTrans_ID != null && item.ParentTrans_ID != 0 && (item.Item_Type == "Test"))
                {
                    var test = db.Lab_Test_Details.Where(t => t.Lab_Test_Detail_ID == item.ParentTrans_ID).FirstOrDefault();
                    if (test != null)
                        test.IsBilled = false;
                }
                if (item.ParentTrans_ID != null && item.ParentTrans_ID != 0 && (item.Item_Type == "Test" && item.ParentTrans_Type == "Test Group Category"))
                {
                    var GroupedData = (from lbm in db.Laboratory_Tests
                                       join lbd in db.Lab_Test_Details
                                       on lbm.Lab_Test_ID equals lbd.Lab_Test_ID
                                       where lbd.Lab_Test_Detail_ID == item.ParentTrans_ID
                                       select lbm.Parent_Transaction_Type_ID).FirstOrDefault();

                    if (GroupedData != null)
                    {
                        var test = db.Lab_Test_Details.Where(t => t.Lab_Test_Detail_ID == GroupedData).FirstOrDefault();
                        if (test != null)
                            test.IsBilled = false;
                    }
                }
            }
            if (BillDetails != null)
                db.Ar_Billing_Details.DeleteAllOnSubmit(BillDetails);
            db.SubmitChanges();
            if (BillHeader != null)
                db.Ar_Billings.DeleteOnSubmit(BillHeader);

            // Deleting from GL....

            var GL_M = (from m in db.GL_Vouchers where m.Voucher_ID == BillHeader.Voucher_ID select m).FirstOrDefault();
            var GL_D = (from d in db.GL_Voucher_Accounts where d.Voucher_ID == BillHeader.Voucher_ID select d).ToList();
            if (GL_D != null)
                db.GL_Voucher_Accounts.DeleteAllOnSubmit(GL_D);
            db.SubmitChanges();
            if (GL_M != null)
                db.GL_Vouchers.DeleteOnSubmit(GL_M);
            db.SubmitChanges();
            return "";
        }
      

        [WebMethod]
        public static string CancelPatient(int Bill_No)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            int billPK_ID = (from b in db.Ar_Billings where b.Bill_No == Convert.ToString(Bill_No) select b.Bill_ID).FirstOrDefault();
            string status = "Allowdlt";
            string AllowPatientDelete = DBClass.getField("select dbo.GetRights('AllowPatientDelete','" + AppConfig.UserID + "')");

            if (Convert.ToBoolean(AllowPatientDelete) == true)
            {
                status = "Fail";
                var listReceitps = db.Receipts.Where(r => r.Bill_ID == billPK_ID && r.isCancel == false).ToList();

                if (listReceitps.Count == 0)
                {
                    Ar_Billing p = new Ar_Billing();
                    var query = db.Ar_Billings.SingleOrDefault(x => x.Bill_No == Convert.ToString(Bill_No));
                    if (query != null)
                    {
                        query.isCancel = true;
                        query.Cancel_by = AppConfig.UserID;
                        query.Cancel_Date = DateTime.Now;
                        db.SubmitChanges();
                        status = "success";
                    }
                }
                return status;
            }
            return status;
        }


        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue, string fromDate, string toDate, string mainDept)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    // Build the main query (with joins and base filters)
                    var Billing = from b in _dbContext.Ar_Billings
                                  join p in _dbContext.Reg_patients on b.Patient_ID equals p.pat_id
                                  join u in _dbContext.aspnet_Users on b.Created_By equals u.UserId
                                   where (b.Total_Amount != null || b.Discount_Amount != null)
                                        && (b.IsPharmacy == null || b.IsPharmacy == false)
                                        && (b.IsCathLab == null || b.IsCathLab == false)
                                   select new
                                   {
                                       Bill_No = b.Bill_No,
                                       Bill_Date = b.Creation_Date,
                                       Remarks = b.Remarks,
                                       Total_Amount = b.Total_Amount,
                                       Discount_Amount = b.Discount_Amount,

                                       // Calculate Discount_Percentage safely
                                       Discount_Percentage = b.Total_Amount.HasValue && b.Total_Amount.Value > 0
    ? Math.Round((b.Discount_Amount ?? 0) / b.Total_Amount.Value * 100, 2, MidpointRounding.AwayFromZero)
    : 0,

                                       Net_Amount = b.Net_Amount,
                                       Received_Amount = b.Received_Amount,
                                       Balance_Amount = b.Balance_Amount,
                                       MrNo = p.mr_no_sequence,
                                       Full_Name = p.Full_Name,
                                       Bill_ID = b.Bill_ID,
                                       In_Patient_ID = b.In_Patient_ID,
                                       Operator = u.UserName,
                                       isCancel = b.isCancel,
                                       final_bill_ipd = b.final_bill_ipd,
                                       Main_Department = _dbContext.GetDataValueName("Mode Of Registration", b.Main_Department),
                                       Main_Department_Code = b.Main_Department,
                                   };

                    // Total records that match base filters (not affected by search)
                    var Total_Billing = Billing.Count();

                    // Apply search filter if searchValue is provided
                    if (!string.IsNullOrWhiteSpace(searchValue))
                    {
                        searchValue = searchValue.Trim();
                        Billing = Billing.Where(x =>
                            x.Bill_No.ToString().Contains(searchValue) ||
                            (x.Full_Name != null && x.Full_Name.Contains(searchValue)) ||
                            (x.MrNo != null && x.MrNo.Contains(searchValue)) ||
                            (x.Operator != null && x.Operator.Contains(searchValue))
                        );
                    }

                    // Start / End date filter on Bill Date (yyyy-MM-dd). Blank = no filter (all data).
                    DateTime fromDt, toDt;
                    if (DateTime.TryParseExact(fromDate, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out fromDt))
                    {
                        DateTime fromDateValue = fromDt.Date;
                        Billing = Billing.Where(x => x.Bill_Date >= fromDateValue);
                    }
                    if (DateTime.TryParseExact(toDate, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out toDt))
                    {
                        DateTime toDateExclusive = toDt.Date.AddDays(1);
                        Billing = Billing.Where(x => x.Bill_Date < toDateExclusive);
                    }

                    // Main Department filter (raw code value)
                    if (!string.IsNullOrWhiteSpace(mainDept))
                    {
                        Billing = Billing.Where(x => x.Main_Department_Code == mainDept);
                    }

                    // Count after search + date filters
                    var FilteredCount = Billing.Count();

                    // Apply sorting (you can extend this later for dynamic sortColumn)
                    Billing = Billing.OrderByDescending(a => a.Bill_ID);

                    // Apply pagination
                    var patientList = Billing.Skip(start).Take(length).ToList();

                    // Refund totals per bill/admission (computed separately, then merged in memory)
                    var billIds = patientList.Select(x => (long)x.Bill_ID).ToList();
                    var ipdIds = patientList.Where(x => x.In_Patient_ID.HasValue)
                                            .Select(x => x.In_Patient_ID.Value).ToList();

                    // Admissions that already have a final bill (non-cancelled)
                    var finalBillIpdIds = _dbContext.Ar_Billings
                        .Where(b => b.In_Patient_ID != null && ipdIds.Contains(b.In_Patient_ID.Value)
                                 && b.final_bill_ipd == true
                                 && (b.isCancel == null || b.isCancel == false))
                        .Select(b => b.In_Patient_ID.Value)
                        .Distinct()
                        .ToList();

                    var refundRows = _dbContext.Refunds
                        .Where(r => (r.isCancelled == null || r.isCancelled == false)
                                 && (r.Status == null || (r.Status != "Rejected" && r.Status != "UnApproved"))
                                 && ((r.Bill_ID != null && billIds.Contains(r.Bill_ID.Value))
                                  || (r.Bill_ID == null && r.In_Patient_ID != null && ipdIds.Contains(r.In_Patient_ID.Value))))
                        .Select(r => new { r.Bill_ID, r.In_Patient_ID, r.Refund_Amount, r.Status })
                        .ToList();

                    // Refundable negative balance = magnitude of the bill's negative Balance_Amount
                    var data = patientList.Select(x => new
                    {
                        x.Bill_No,
                        x.Bill_Date,
                        x.Remarks,
                        x.Total_Amount,
                        x.Discount_Amount,
                        x.Discount_Percentage,
                        x.Net_Amount,
                        x.Received_Amount,
                        x.Balance_Amount,
                        x.MrNo,
                        x.Full_Name,
                        x.Main_Department,
                        x.Bill_ID,
                        x.Operator,
                        x.isCancel,
                        Is_Final_Bill = x.final_bill_ipd == true,
                        Admission_Has_Final_Bill = x.In_Patient_ID.HasValue && finalBillIpdIds.Contains(x.In_Patient_ID.Value),
                        Refund_Amount = refundRows
                            .Where(r => ((r.Bill_ID != null && r.Bill_ID == (long)x.Bill_ID)
                                      || (r.Bill_ID == null && r.In_Patient_ID == x.In_Patient_ID))
                                     && r.Status == "Approved")
                            .Sum(r => (decimal?)(r.Refund_Amount ?? 0)) ?? 0,
                        Has_Refund = refundRows.Any(r => (r.Bill_ID != null && r.Bill_ID == (long)x.Bill_ID)
                                      || (r.Bill_ID == null && r.In_Patient_ID == x.In_Patient_ID)),
                        Negative_Balance = (x.Balance_Amount.HasValue && x.Balance_Amount.Value < 0)
                            ? (0m - x.Balance_Amount.Value)
                            : 0m
                    }).ToList();

                    var jsonData = new
                    {
                        draw = draw,
                        recordsFiltered = FilteredCount,
                        recordsTotal = Total_Billing,
                        data = data
                    };

                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching patient list", ex);
            }
        }

        [WebMethod]
        public static string GetBillDetails(int billId)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var billDetails = db.Ar_Billing_Details
                        .Where(bd => bd.Bill_ID == billId)
                        .Select(bd => new
                        {
                            Item_Type = bd.Item_Type,
                            Item_Name = bd.Item_Name,
                            Amount = bd.Amount,
                            Discount_Amount = bd.Discount_Amount,
                            Net_Amount = bd.Net_Amount,
                            Test_Main_Department = bd.Test_Main_Department
                        })
                        .ToList();

                    return JsonConvert.SerializeObject(billDetails);
                }
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new { error = ex.Message });
            }
        }

        [WebMethod]
        public static string GetBillAuditLogs(int billId)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var logRows = (from l in db.Ar_Billing_Logs
                                   join u in db.aspnet_Users on l.Loged_By equals u.UserId into userJoin
                                   from u in userJoin.DefaultIfEmpty()
                                   where l.Bill_Id == billId
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

                    var bill = db.Ar_Billings.FirstOrDefault(b => b.Bill_ID == billId);

                    object currentMaster = null;
                    object currentDetails = null;

                    if (bill != null)
                    {
                        currentMaster = new
                        {
                            Bill_No = bill.Bill_No,
                            Patient_ID = bill.Patient_ID,
                            Bill_Date = bill.Bill_Date.HasValue ? bill.Bill_Date.Value.ToString("yyyy-MM-dd HH:mm") : null,
                            Cash_In_Hand = bill.Cash_In_Hand,
                            Bank_Account = bill.Bank_Account,
                            Discount_Amount = bill.Discount_Amount,
                            Total_Amount = bill.Total_Amount,
                            Net_Amount = bill.Net_Amount,
                            Received_Amount = bill.Received_Amount,
                            Balance_Amount = bill.Balance_Amount,
                            Main_Department = bill.Main_Department,
                            BillType = bill.BillType,
                            In_Patient_ID = bill.In_Patient_ID
                        };

                        var detailRows = db.Ar_Billing_Details
                            .Where(d => d.Bill_ID == billId)
                            .Select(d => new
                            {
                                d.Bill_Details_ID,
                                d.Bill_ID,
                                d.Item_ID,
                                d.Item_Name,
                                d.Amount,
                                d.Net_Amount,
                                d.Discount_Amount,
                                d.Qty,
                                d.Item_Type,
                                d.Doctor_id,
                                d.Doctor_Share,
                                d.Hospital_Share
                            }).ToList();

                        currentDetails = new { Billing_Details = detailRows };
                    }

                    return JsonConvert.SerializeObject(new
                    {
                        logs = logs,
                        current = new { master = currentMaster, details = currentDetails }
                    });
                }
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new { error = ex.Message });
            }
        }

        private static object ParseLogJson(string json)
        {
            if (string.IsNullOrWhiteSpace(json))
                return null;

            try
            {
                return JsonConvert.DeserializeObject<JToken>(json);
            }
            catch
            {
                return null;
            }
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "BillingProcessView";

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
                string pageName = "BillingProcessView";

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

        [WebMethod]
        public static void IncrementReprintCount(int Bill_ID)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var bill = db.Ar_Billings.FirstOrDefault(b => b.Bill_ID == Bill_ID);
                    if (bill != null)
                    {
                        // Increment the count (handles nulls just in case)
                        bill.Reprint_Count = bill.Reprint_Count + 1;
                        db.SubmitChanges();
                    }
                }
            }
            catch (Exception ex)
            {
                // Optional: Log the exception to your error log
                System.Diagnostics.Debug.WriteLine("Reprint Count Error: " + ex.Message);
            }
        }

        [WebMethod]
        public static string GetBillAdvanceRefundInfo(int billId)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var bill = db.Ar_Billings.FirstOrDefault(b => b.Bill_ID == billId);
                    if (bill == null)
                        return (new JavaScriptSerializer()).Serialize(new { Error = "Bill not found." });

                    long? ipd = bill.In_Patient_ID;
                    int patientId = bill.Patient_ID ?? 0;

                    decimal advance = 0;
                    decimal billNet = 0;
                    decimal alreadyRefunded = 0;

                    if (ipd.HasValue)
                    {
                        advance = db.AR_Advances
                            .Where(a => a.In_Patient_ID == ipd.Value && (a.isCancelled == null || a.isCancelled == false))
                            .Sum(a => (decimal?)a.Advance_Amount) ?? 0;

                        var billRecords = db.Ar_Billings
                            .Where(b => b.In_Patient_ID == ipd.Value && (b.isCancel == null || b.isCancel == false))
                            .ToList();
                        var finalBills = billRecords.Where(b => b.final_bill_ipd == true).ToList();
                        billNet = (finalBills.Count > 0 ? finalBills : billRecords).Sum(b => b.Net_Amount ?? 0);

                        alreadyRefunded = db.Refunds
                            .Where(r => r.In_Patient_ID == ipd.Value
                                     && (r.isCancelled == null || r.isCancelled == false)
                                     && (r.Status == null || (r.Status != "Rejected" && r.Status != "UnApproved")))
                            .Sum(r => (decimal?)r.Refund_Amount) ?? 0;
                    }

                    var pat = db.Reg_patients.FirstOrDefault(p => p.pat_id == patientId);

                    // Refundable amount = magnitude of the bill's negative Balance_Amount
                    decimal negativeBalance = (bill.Balance_Amount.HasValue && bill.Balance_Amount.Value < 0)
                        ? (0m - bill.Balance_Amount.Value)
                        : 0m;

                    return (new JavaScriptSerializer()).Serialize(new
                    {
                        Patient_ID = patientId,
                        In_Patient_ID = ipd,
                        Bill_No = bill.Bill_No,
                        Full_Name = pat != null ? pat.Full_Name : "",
                        Total_Advance = advance,
                        BillNet = billNet,
                        AlreadyRefunded = alreadyRefunded,
                        NegativeBalance = negativeBalance
                    });
                }
            }
            catch (Exception ex)
            {
                return (new JavaScriptSerializer()).Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod]
        public static string SaveBillAdvanceRefund(int billId, string refundDate, string remarks, int amount)
        {
            try
            {
                if (amount <= 0)
                    return "Error: refund amount must be greater than zero.";

                using (var db = new DataBaseDataContext())
                {
                    var bill = db.Ar_Billings.FirstOrDefault(b => b.Bill_ID == billId);
                    if (bill == null)
                        return "Error: bill not found.";

                    DateTime dt;
                    if (!DateTime.TryParse(refundDate, out dt))
                        dt = DateTime.Now;

                    Refund r = new Refund();
                    r.Patient_ID = bill.Patient_ID;
                    r.In_Patient_ID = bill.In_Patient_ID;
                    r.Bill_ID = billId;
                    r.Refund_Date = dt;
                    r.Refund_Amount = amount;
                    r.Remarks = remarks;
                    r.Created_By = AppConfig.UserID;
                    r.Creation_Date = DateTime.Now;
                    r.Status = "Created";

                    db.Refunds.InsertOnSubmit(r);

                    // Persist the refunded amount against the bill
                    bill.Refund_Amount = (bill.Refund_Amount ?? 0) + amount;

                    db.SubmitChanges();

                    return r.Refund_ID.ToString();
                }
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

    }
}
