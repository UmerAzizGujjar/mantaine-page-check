using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.Services;

namespace PMS.Modules.GL
{
    public partial class CancelledVoucherList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e) { }

        // DataTables column name -> SQL sort expression. Whitelisted so client input never reaches ORDER BY as raw text.
        private static readonly Dictionary<string, string> SortMap = new Dictionary<string, string>
        {
            { "Voucher_ID", "v.Voucher_ID" },
            { "Voucher_No", "v.Voucher_No" },
            { "Voucher_Type", "v.Voucher_Type" },
            { "Ref_Num", "v.Ref_Num" },
            { "Voucher_Date", "v.Voucher_Date" },
            { "Cancelled_By", "u.UserName" },
            { "Cancelled_Time", "v.Deleted_Date" },
            { "Voucher_Status", "v.Voucher_Status" }
        };

        // Master-level query: one row per voucher. GL_Voucher_Accounts is deliberately not joined, so no duplicates.
        // Cancelled By / Cancelled Time come from Deleted_By / Deleted_Date (written by VoucherView.DeleteRecord), not Approved_By.
        private const string FromSql = @"
            FROM GL_Vouchers v
            LEFT JOIN aspnet_Users u ON u.UserId = v.Deleted_By
            WHERE v.Voucher_Status = 'Cancelled' AND v.Company_ID = @CompanyID";

        private const string SearchSql = @"
            (@Search = '' OR CAST(v.Voucher_No AS VARCHAR(20)) LIKE @Like OR v.Voucher_Type LIKE @Like
             OR v.Ref_Num LIKE @Like OR u.UserName LIKE @Like OR v.Voucher_Status LIKE @Like)";

        [WebMethod]
        public static object CancelledVoucherListData(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                string search = (searchValue ?? "").Trim();
                string sortExpr = SortMap.ContainsKey(sortColumn ?? "") ? SortMap[sortColumn] : "v.Voucher_ID";
                string sortDir = string.Equals(sortColumnDirection, "asc", StringComparison.OrdinalIgnoreCase) ? "ASC" : "DESC";

                // Each query needs its own SqlParameter objects; a parameter cannot be attached to two commands.
                // Totals in one row. The filtered count uses the same search condition as the page query.
                DataTable counts = DBClass.getDataTable(
                    "SELECT COUNT(*) AS RecordsTotal, ISNULL(SUM(CASE WHEN " + SearchSql + " THEN 1 ELSE 0 END), 0) AS RecordsFiltered " + FromSql,
                    BuildArgs(search, start, length));
                int total = Convert.ToInt32(counts.Rows[0]["RecordsTotal"]);
                int filtered = Convert.ToInt32(counts.Rows[0]["RecordsFiltered"]);

                DataTable dt = DBClass.getDataTable(
                    "SELECT v.Voucher_ID, v.Voucher_No, v.Voucher_Type, v.Voucher_Date, v.Ref_Num, v.Voucher_Status, " +
                    "v.Deleted_Date AS Cancelled_Time, u.UserName AS Cancelled_By " +
                    FromSql + " AND " + SearchSql +
                    " ORDER BY " + sortExpr + " " + sortDir + (sortExpr == "v.Voucher_ID" ? "" : ", v.Voucher_ID DESC") +
                    " OFFSET @Start ROWS FETCH NEXT @Length ROWS ONLY",
                    BuildArgs(search, start, length));

                var data = new List<object>();
                foreach (DataRow r in dt.Rows)
                {
                    string cancelledBy = r["Cancelled_By"] as string;
                    data.Add(new
                    {
                        Voucher_ID = Convert.ToInt64(r["Voucher_ID"]),
                        Voucher_No = Convert.ToInt32(r["Voucher_No"]),
                        Voucher_Type = r["Voucher_Type"] as string,
                        Ref_Num = r["Ref_Num"] as string,
                        Voucher_Date = ToIso(r["Voucher_Date"]),
                        Cancelled_By = string.IsNullOrWhiteSpace(cancelledBy) ? "N/A" : cancelledBy,
                        Cancelled_Time = ToIso(r["Cancelled_Time"]),
                        Voucher_Status = r["Voucher_Status"] as string
                    });
                }
                return new { draw, recordsTotal = total, recordsFiltered = filtered, data };
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching cancelled voucher list: " + ex.Message, ex);
            }
        }

        private static SqlParameter[] BuildArgs(string search, int start, int length)
        {
            return new[]
            {
                DBClass.Param("@CompanyID", AppConfig.Company_ID),
                DBClass.Param("@Search", search),
                DBClass.Param("@Like", "%" + search + "%"),
                DBClass.Param("@Start", start < 0 ? 0 : start),
                DBClass.Param("@Length", length <= 0 ? int.MaxValue : length)
            };
        }

        private static string ToIso(object value)
        {
            return value == null || value is DBNull ? null : Convert.ToDateTime(value).ToString("s");
        }
    }
}
