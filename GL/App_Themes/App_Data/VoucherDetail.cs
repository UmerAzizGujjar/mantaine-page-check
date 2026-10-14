using System;
using System.Collections.Generic;
using System.Data;
using System.Web.Script.Serialization;

namespace PMS
{
    // Shared by the voucher list pages: one voucher's status, GL lines and linked bills, as JSON
    public static class VoucherDetail
    {
        public static string GetJson(string voucherId)
        {
            long id = Convert.ToInt64(voucherId);

            var head = DBClass.getDataTable(
                "SELECT Voucher_Status FROM GL_Vouchers WHERE Voucher_ID = @Voucher_ID",
                DBClass.Param("@Voucher_ID", id));

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

            string status = head.Rows.Count > 0 ? Convert.ToString(head.Rows[0]["Voucher_Status"]) : "";

            return new JavaScriptSerializer().Serialize(new Dictionary<string, object>
            {
                { "status", status },
                { "lines", ToRows(lines) },
                { "bills", ToRows(bills) }
            });
        }

        // Reads Voucher_ID from the record (recordSql must select Voucher_ID and take @Id) and returns its detail.
        // A record without a posted voucher returns an empty status and no lines.
        public static string GetJsonForRecord(string recordSql, int recordId)
        {
            var head = DBClass.getDataTable(recordSql, DBClass.Param("@Id", recordId));

            if (head.Rows.Count == 0 || head.Rows[0]["Voucher_ID"] == DBNull.Value)
            {
                return new JavaScriptSerializer().Serialize(new Dictionary<string, object>
                {
                    { "status", "" },
                    { "lines", new List<Dictionary<string, object>>() },
                    { "bills", new List<Dictionary<string, object>>() }
                });
            }

            return GetJson(Convert.ToString(head.Rows[0]["Voucher_ID"]));
        }

        public static List<Dictionary<string, object>> ToRows(DataTable dt)
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
