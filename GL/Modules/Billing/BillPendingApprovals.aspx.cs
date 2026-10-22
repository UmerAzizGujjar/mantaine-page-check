using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Web.Script.Serialization;
using System.Web.Services;

namespace PMS.Modules.Billing
{
    public partial class BillPendingApprovals : System.Web.UI.Page
    {
        // sys_Parms 'Bill Bulk Approval' Code '02' turns the bulk screen on
        protected bool BulkEnabled;

        protected void Page_Load(object sender, EventArgs e)
        {
            BulkEnabled = IsBulkEnabled();
        }

        private static bool IsBulkEnabled()
        {
            string code = Convert.ToString(DBClass.getField(
                "SELECT TOP 1 Code FROM sys_Parms WHERE Name = 'Bill Bulk Approval'"));
            return (code ?? "").Trim() == "02";
        }

        // Pending (Created) bills, IPD left out (sp_Load_Bill_Pending_Approvals).
        [WebMethod]
        public static string LoadPendingBills(string start_date, string end_date, string search)
        {
            if (!IsBulkEnabled())
            {
                return new JavaScriptSerializer().Serialize(new List<Dictionary<string, object>>());
            }

            var dt = DBClass.getDataTable("EXEC dbo.sp_Load_Bill_Pending_Approvals @Company_ID, @startDate, @endDate, @search",
                DBClass.Param("@Company_ID", AppConfig.Company_ID),
                DBClass.Param("@startDate", ParseDate(start_date)),
                DBClass.Param("@endDate", ParseDate(end_date)),
                DBClass.Param("@search", search ?? ""));

            return new JavaScriptSerializer().Serialize(ToRows(dt));
        }

        // Approves the ticked bills into one BLJV voucher (SpApprove_Pending_Bills_Bulk).
        // billIds is a comma separated list of Bill_ID values.
        [WebMethod]
        public static string ApproveBulkBills(string billIds)
        {
            var result = new Dictionary<string, object>();
            try
            {
                if (!IsBulkEnabled())
                {
                    result["ok"] = false;
                    result["message"] = "Bulk bill approval is turned off (sys_Parms 'Bill Bulk Approval').";
                    return new JavaScriptSerializer().Serialize(result);
                }

                var dt = DBClass.getDataTable("EXEC dbo.SpApprove_Pending_Bills_Bulk @Bill_IDs, @Company_ID, @user_id",
                    DBClass.Param("@Bill_IDs", billIds ?? ""),
                    DBClass.Param("@Company_ID", AppConfig.Company_ID),
                    DBClass.Param("@user_id", AppConfig.UserID));

                DataRow r = dt.Rows.Count > 0 ? dt.Rows[0] : null;
                long voucherId = r != null && r["Voucher_ID"] != DBNull.Value ? Convert.ToInt64(r["Voucher_ID"]) : 0;

                result["ok"] = voucherId > 0;
                result["message"] = r != null ? Convert.ToString(r["Message"]) : "No response from server.";
                if (voucherId > 0)
                {
                    result["voucherNo"] = Convert.ToString(r["Voucher_No"]);
                    result["count"] = Convert.ToInt32(r["Bill_Count"]);
                    result["total"] = Convert.ToDecimal(r["Total_Amount"]);
                }
            }
            catch (Exception ex)
            {
                result["ok"] = false;
                result["message"] = ex.Message;
            }
            return new JavaScriptSerializer().Serialize(result);
        }

        // Posted bulk vouchers (BLJV) for the company, in the date range.
        [WebMethod]
        public static string LoadBulkVouchers(string start_date, string end_date)
        {
            DateTime dateFrom = ParseDate(start_date) ?? DateTime.Today;
            DateTime dateTo = (ParseDate(end_date) ?? DateTime.Today).AddDays(1);

            var dt = DBClass.getDataTable(
                @"SELECT v.Voucher_ID, v.Voucher_No, v.Voucher_Date, v.Remarks, v.Voucher_Status,
                         (SELECT COUNT(*) FROM Ar_Billings ab WHERE ab.Voucher_ID = v.Voucher_ID) AS BillCount,
                         (SELECT ISNULL(SUM(va.DR), 0) FROM GL_Voucher_Accounts va WHERE va.Voucher_ID = v.Voucher_ID) AS TotalDR,
                         (SELECT ISNULL(SUM(va.CR), 0) FROM GL_Voucher_Accounts va WHERE va.Voucher_ID = v.Voucher_ID) AS TotalCR
                  FROM GL_Vouchers v
                  WHERE v.Voucher_Type = 'BLJV'
                    AND ISNULL(v.IsDeleted, 0) = 0
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
                @"SELECT va.Narration, ga.Account_Code, ga.Account_Name, va.DR, va.CR,
                         dbo.GetDataValueName('Cost Center', va.Cost_Center) AS CostCenter
                  FROM GL_Voucher_Accounts va
                  JOIN GL_Accounts ga ON ga.Account_ID = va.Account_ID
                  WHERE va.Voucher_ID = @Voucher_ID
                  ORDER BY va.Voucher_account_ID",
                DBClass.Param("@Voucher_ID", id));

            var bills = DBClass.getDataTable(
                @"SELECT ab.Bill_No, rg.mr_no_sequence, rg.Full_Name, ab.Total_Amount, ab.Discount_Amount, ab.Received_Amount, ab.Balance_Amount
                  FROM Ar_Billings ab
                  LEFT JOIN Reg_patient rg ON rg.pat_id = ab.Patient_ID
                  WHERE ab.Voucher_ID = @Voucher_ID
                  ORDER BY ab.Bill_ID",
                DBClass.Param("@Voucher_ID", id));

            return new JavaScriptSerializer().Serialize(new Dictionary<string, object>
            {
                { "lines", ToRows(lines) },
                { "bills", ToRows(bills) }
            });
        }

        private static DateTime? ParseDate(string s)
        {
            DateTime d;
            return DateTime.TryParseExact(s, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out d)
                ? d.Date : (DateTime?)null;
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
