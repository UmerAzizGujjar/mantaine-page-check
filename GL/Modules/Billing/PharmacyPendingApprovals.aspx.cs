using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using System.Web.Script.Serialization;
using System.Web.Services;

namespace PMS.Modules.Billing
{
    public partial class PharmacyPendingApprovals : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        // Pharmacy bills that are created but not approved yet.
        // Same test the app uses for "Created": IsPharmacy, no status, no voucher.
        [WebMethod]
        public static string LoadPendingPharmacyBills(string start_date, string end_date, string search)
        {
            DateTime startDt;
            DateTime endDt;
            DateTime dateFrom = DateTime.TryParseExact(start_date, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out startDt)
                ? startDt.Date : DateTime.Today;
            DateTime dateTo = DateTime.TryParseExact(end_date, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out endDt)
                ? endDt.Date.AddDays(1) : DateTime.Today.AddDays(1);
            string key = (search ?? "").Trim();

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var rows = (from AB in db.Ar_Billings
                            where AB.IsPharmacy == true
                               && AB.Status == null
                               && AB.Voucher_ID == null
                               && AB.Seq_InvoiceNo != null
                               && AB.Received_Amount >= 0
                               && (AB.isCancel == null || AB.isCancel == false)
                               && (AB.In_Patient_ID == null || AB.In_Patient_ID == 0)
                               && AB.Creation_Date >= dateFrom
                               && AB.Creation_Date < dateTo
                               && (key == ""
                                   || AB.Seq_InvoiceNo.Contains(key)
                                   || AB.Customer_Name.Contains(key)
                                   || db.Reg_patients.Any(rg => rg.pat_id == AB.Patient_ID && rg.mr_no_sequence.Contains(key)))
                            orderby AB.Bill_ID descending
                            select new
                            {
                                AB.Bill_ID,
                                BillNo = AB.Seq_InvoiceNo,
                                AB.Creation_Date,
                                Customer_Name = AB.Customer_Name,
                                MR_No = db.Reg_patients.Where(rg => rg.pat_id == AB.Patient_ID).Select(rg => rg.mr_no_sequence).FirstOrDefault(),
                                WareHouse = db.GetDataValueName("Ware House", AB.Ware_House),
                                AB.Total_Amount,
                                AB.Discount_Amount,
                                AB.Total_CGS,
                                AB.Net_Amount,
                                AB.Received_Amount,
                                AB.Balance_Amount,
                                Status = "Created"
                            }).Take(1000).ToList();

                return new JavaScriptSerializer().Serialize(rows);
            }
        }

        // Approves the ticked bills in one transaction (BulkApprovePharmacy procedure).
        // billIds is a comma separated list of Bill_ID values.
        [WebMethod]
        public static string BulkApprovePharmacy(string billIds)
        {
            var result = new Dictionary<string, object>();
            try
            {
                var dt = DBClass.getDataTable("EXEC dbo.BulkApprovePharmacy @BillIds, @user_id",
                    DBClass.Param("@BillIds", billIds ?? ""),
                    DBClass.Param("@user_id", AppConfig.UserID));

                result["ok"] = true;
                result["count"] = dt.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0]["ApprovedCount"]) : 0;
                result["message"] = dt.Rows.Count > 0 ? Convert.ToString(dt.Rows[0]["Message"]) : "";
                result["voucherNo"] = dt.Rows.Count > 0 ? Convert.ToString(dt.Rows[0]["VoucherNo"]) : "";
            }
            catch (Exception ex)
            {
                // the procedure rolls back the whole batch and raises the reason (e.g. a bill already approved)
                result["ok"] = false;
                result["message"] = ex.Message;
            }
            return new JavaScriptSerializer().Serialize(result);
        }

        // Posted bulk vouchers (Pharma, written by BulkApprovePharmacy) for the company, in the date range.
        [WebMethod]
        public static string LoadBulkVouchers(string start_date, string end_date)
        {
            DateTime startDt;
            DateTime endDt;
            DateTime dateFrom = DateTime.TryParseExact(start_date, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out startDt)
                ? startDt.Date : DateTime.Today;
            DateTime dateTo = DateTime.TryParseExact(end_date, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out endDt)
                ? endDt.Date.AddDays(1) : DateTime.Today.AddDays(1);

            var dt = DBClass.getDataTable(
                @"SELECT v.Voucher_ID, v.Voucher_No, v.Voucher_Date, v.Remarks, v.Voucher_Status,
                         (SELECT COUNT(*) FROM Ar_Billings ab WHERE ab.Voucher_ID = v.Voucher_ID) AS BillCount,
                         (SELECT ISNULL(SUM(va.DR), 0) FROM GL_Voucher_Accounts va WHERE va.Voucher_ID = v.Voucher_ID) AS TotalDR,
                         (SELECT ISNULL(SUM(va.CR), 0) FROM GL_Voucher_Accounts va WHERE va.Voucher_ID = v.Voucher_ID) AS TotalCR
                  FROM GL_Vouchers v
                  WHERE v.Voucher_Type = 'Pharma'
                    AND v.Remarks LIKE 'Bulk pharmacy approval%'
                    AND v.Company_ID = @Company_ID
                    AND v.Voucher_Date >= @DateFrom
                    AND v.Voucher_Date < @DateTo
                  ORDER BY v.Voucher_ID DESC",
                DBClass.Param("@Company_ID", AppConfig.Company_ID),
                DBClass.Param("@DateFrom", dateFrom),
                DBClass.Param("@DateTo", dateTo));

            return new JavaScriptSerializer().Serialize(ToRows(dt));
        }

        // GL lines and bills of one posted bulk voucher, for the View popup.
        [WebMethod]
        public static string GetBulkVoucherDetail(string voucherId)
        {
            long id = Convert.ToInt64(voucherId);

            var lines = DBClass.getDataTable(
                @"SELECT va.Narration, ga.Account_Code, ga.Account_Name, va.DR, va.CR
                  FROM GL_Voucher_Accounts va
                  JOIN GL_Accounts ga ON ga.Account_ID = va.Account_ID
                  WHERE va.Voucher_ID = @Voucher_ID
                  ORDER BY va.Voucher_account_ID",
                DBClass.Param("@Voucher_ID", id));

            var bills = DBClass.getDataTable(
                @"SELECT ab.Seq_InvoiceNo, ab.Customer_Name, ab.Total_Amount, ab.Discount_Amount, ab.Received_Amount, ab.Balance_Amount
                  FROM Ar_Billings ab
                  WHERE ab.Voucher_ID = @Voucher_ID
                  ORDER BY ab.Bill_ID",
                DBClass.Param("@Voucher_ID", id));

            return new JavaScriptSerializer().Serialize(new Dictionary<string, object>
            {
                { "lines", ToRows(lines) },
                { "bills", ToRows(bills) }
            });
        }

        private static List<Dictionary<string, object>> ToRows(DataTable dt)
        {
            var rows = new List<Dictionary<string, object>>();
            foreach (DataRow r in dt.Rows)
            {
                var row = new Dictionary<string, object>();
                foreach (DataColumn c in dt.Columns)
                {
                    row[c.ColumnName] = r[c] == DBNull.Value ? null : r[c];
                }
                rows.Add(row);
            }
            return rows;
        }
    }
}
