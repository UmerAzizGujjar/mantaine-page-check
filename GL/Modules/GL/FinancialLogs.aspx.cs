using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web.Data.Extensions;

namespace PMS
{
    public partial class FinancialLogs : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        private class VoucherAccountLogContainer
        {
            public List<VoucherAccountLogItem> GL_Voucher_Account { get; set; }
        }

        private class VoucherAccountLogItem
        {
            public long Voucher_account_ID { get; set; }
            public int Account_ID { get; set; }
            public decimal? DR { get; set; }
            public decimal? CR { get; set; }
            public long Voucher_ID { get; set; }
            public string Cost_Center { get; set; }
            public string Cheque_No { get; set; }
            public string Cheque_Date { get; set; }
        }

        private class VoucherAccountModalRow
        {
            public int Account_ID { get; set; }
            public string Account_Display { get; set; }
            public decimal? DR { get; set; }
            public decimal? CR { get; set; }
            public string Cost_Center { get; set; }
            public string Cheque_Date { get; set; }
        }

        private class OldVoucherSnapshot
        {
            public int Log_Id { get; set; }
            public string Logged_Time { get; set; }
            public string Logged_By { get; set; }
            public decimal? Total_Debit { get; set; }
            public decimal? Total_Credit { get; set; }
            public List<VoucherAccountModalRow> Rows { get; set; }
        }

        private class OldVoucherSnapshotRaw
        {
            public int Log_Id { get; set; }
            public DateTime? Logged_Time { get; set; }
            public Guid? Logged_By { get; set; }
            public decimal? OldTotalDebit { get; set; }
            public decimal? OldTotalCredit { get; set; }
            public List<VoucherAccountLogItem> OldRows { get; set; }
        }

         

        [WebMethod]
        public static string VoucherViewList(string type, string startdate, string enddate)
        {
            string result = string.Empty;
            DateTime dTimestDate;
            DateTime dTimeenDate;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {

                if (startdate == "" && enddate == "")
                {
                    var query = (from l in db.Gl_Vouchers_Logs
                                 where l.Voucher_Id.HasValue
                                 join a in db.GL_Vouchers on l.Voucher_Id.Value equals a.Voucher_ID
                                 where a.iscancel == false
                                 select new
                                 {

                                     a.Voucher_ID,
                                     a.Voucher_No,
                                     a.Voucher_Date,
                                     a.Ref_Num,
                                     a.Remarks,
                                     a.Branch_DDL,
                                     a.Voucher_Status,
                                     a.Total_Debit,
                                     a.Voucher_Type
                                     // branch = (from b in db.Branches where b.Branh_id == Convert.ToInt32(a.Branch_DDL) select b.Branch_name),

                                 }).Distinct().ToList();
                    result = (new JavaScriptSerializer()).Serialize(query).ToString();
                }
                else
                {
                    dTimestDate = Convert.ToDateTime(startdate);
                    dTimeenDate = Convert.ToDateTime(enddate);
                    var query = (from l in db.Gl_Vouchers_Logs
                                 where l.Voucher_Id.HasValue
                                 join a in db.GL_Vouchers on l.Voucher_Id.Value equals a.Voucher_ID
                                 where a.iscancel == false && a.Voucher_Date >= dTimestDate && a.Voucher_Date <= dTimeenDate
                                 select new
                                 {

                                     a.Voucher_ID,
                                     a.Voucher_No,
                                     a.Voucher_Date,
                                     a.Ref_Num,
                                     a.Remarks,
                                     a.Branch_DDL,
                                     a.Voucher_Status,
                                     a.Total_Debit,
                                     a.Voucher_Type
                                     // branch = (from b in db.Branches where b.Branh_id == Convert.ToInt32(a.Branch_DDL) select b.Branch_name),

                                 }).Distinct().ToList();
                    result = (new JavaScriptSerializer()).Serialize(query).ToString();
                }
            }
            return result;
        }

        [WebMethod]
        public static string GetVoucherAccountChanges(int voucherId)
        {
            var serializer = new JavaScriptSerializer();

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var voucherLogs = (from l in db.Gl_Vouchers_Logs
                                   where l.Voucher_Id == voucherId
                                   orderby l.Log_Id descending
                                   select new
                                   {
                                       l.Log_Id,
                                       l.Details_Logs,
                                       l.Master_Logs,
                                       l.Logged_Time,
                                       l.Logged_By
                                   }).ToList();

                var loggedByIds = voucherLogs
                    .Where(x => x.Logged_By.HasValue)
                    .Select(x => x.Logged_By.Value)
                    .Distinct()
                    .ToList();

                var loggedByMap = (from u in db.aspnet_Users
                                   where loggedByIds.Contains(u.UserId)
                                   select new
                                   {
                                       u.UserId,
                                       u.UserName
                                   }).ToList()
                                   .ToDictionary(x => x.UserId, x => x.UserName);

                var currentRows = (from a in db.GL_Voucher_Accounts
                                   where a.Voucher_ID == voucherId
                                   select a) // Fetch the database entities first
                   .AsEnumerable() // Switch from SQL to in-memory processing
                   .Select(a => new VoucherAccountLogItem
                   {
                       Voucher_account_ID = a.Voucher_account_ID,
                       Account_ID = a.Account_ID,
                       DR = a.DR,
                       CR = a.CR,
                       Voucher_ID = a.Voucher_ID,
                       Cost_Center = a.Cost_Center,
                       Cheque_No = a.Cheque_No,
                       Cheque_Date = a.Cheque_Date.HasValue ? a.Cheque_Date.Value.ToString("yyyy-MM-dd") : null
                   }).ToList();

                var allOldRows = new List<VoucherAccountLogItem>();
                var parsedOldSnapshots = new List<OldVoucherSnapshotRaw>();

                foreach (var voucherLog in voucherLogs)
                {
                    var oldRows = new List<VoucherAccountLogItem>();
                    if (!string.IsNullOrEmpty(voucherLog.Details_Logs))
                    {
                        try
                        {
                            var parsedLogs = serializer.Deserialize<VoucherAccountLogContainer>(voucherLog.Details_Logs);
                            if (parsedLogs != null && parsedLogs.GL_Voucher_Account != null)
                            {
                                oldRows = parsedLogs.GL_Voucher_Account;
                            }
                        }
                        catch
                        {
                            oldRows = new List<VoucherAccountLogItem>();
                        }
                    }

                    allOldRows.AddRange(oldRows);

                    decimal? oldTotalDebit;
                    decimal? oldTotalCredit;
                    ExtractTotalsFromMasterLogs(voucherLog.Master_Logs, out oldTotalDebit, out oldTotalCredit);

                    parsedOldSnapshots.Add(new OldVoucherSnapshotRaw
                    {
                        Log_Id = voucherLog.Log_Id,
                        Logged_Time = voucherLog.Logged_Time,
                        Logged_By = voucherLog.Logged_By,
                        OldRows = oldRows,
                        OldTotalDebit = oldTotalDebit,
                        OldTotalCredit = oldTotalCredit
                    });
                }

                var accountIds = allOldRows.Select(x => x.Account_ID)
                    .Union(currentRows.Select(x => x.Account_ID))
                    .Distinct()
                    .ToList();

                var accountMap = (from acc in db.GL_Accounts
                                  where accountIds.Contains(acc.Account_ID)
                                  select new
                                  {
                                      acc.Account_ID,
                                      acc.Account_Name
                                  }).ToList()
                                  .ToDictionary(x => x.Account_ID, x => x.Account_Name);

                var oldSnapshots = parsedOldSnapshots
                    .Select(s => new OldVoucherSnapshot
                    {
                        Log_Id = s.Log_Id,
                        Logged_Time = s.Logged_Time.HasValue ? s.Logged_Time.Value.ToString("yyyy-MM-dd HH:mm") : string.Empty,
                        Logged_By = s.Logged_By.HasValue && loggedByMap.ContainsKey(s.Logged_By.Value) ? loggedByMap[s.Logged_By.Value] : string.Empty,
                        Total_Debit = s.OldTotalDebit,
                        Total_Credit = s.OldTotalCredit,
                        Rows = s.OldRows
                            .OrderBy(x => x.Account_ID)
                            .Select(x => new VoucherAccountModalRow
                            {
                                Account_ID = x.Account_ID,
                                Account_Display = x.Account_ID + " - " + (accountMap.ContainsKey(x.Account_ID) ? accountMap[x.Account_ID] : ""),
                                DR = x.DR,
                                CR = x.CR,
                                Cost_Center = x.Cost_Center,
                                Cheque_Date = NormalizeDateString(x.Cheque_Date)
                            }).ToList()
                    }).ToList();

                var newModalRows = currentRows
                    .OrderBy(x => x.Account_ID)
                    .Select(x => new VoucherAccountModalRow
                    {
                        Account_ID = x.Account_ID,
                        Account_Display = x.Account_ID + " - " + (accountMap.ContainsKey(x.Account_ID) ? accountMap[x.Account_ID] : ""),
                        DR = x.DR,
                        CR = x.CR,
                        Cost_Center = x.Cost_Center,
                        Cheque_Date = NormalizeDateString(x.Cheque_Date)
                    }).ToList();

                var currentVoucher = (from v in db.GL_Vouchers
                                      where v.Voucher_ID == voucherId
                                      select new
                                      {
                                          v.Total_Debit,
                                          v.Total_Credit
                                      }).FirstOrDefault();

                var response = new
                {
                    OldSnapshots = oldSnapshots,
                    NewRows = newModalRows,
                    NewTotalDebit = currentVoucher != null ? currentVoucher.Total_Debit : null,
                    NewTotalCredit = currentVoucher != null ? currentVoucher.Total_Credit : null
                };

                return serializer.Serialize(response);
            }
        }

        private static void ExtractTotalsFromMasterLogs(string masterLogs, out decimal? totalDebit, out decimal? totalCredit)
        {
            totalDebit = null;
            totalCredit = null;

            if (string.IsNullOrEmpty(masterLogs))
            {
                return;
            }

            try
            {
                var serializer = new JavaScriptSerializer();
                var parsed = serializer.DeserializeObject(masterLogs);
                FindTotalsRecursive(parsed, ref totalDebit, ref totalCredit);
            }
            catch
            {
            }
        }

        private static void FindTotalsRecursive(object node, ref decimal? totalDebit, ref decimal? totalCredit)
        {
            if (node == null)
            {
                return;
            }

            var dict = node as Dictionary<string, object>;
            if (dict != null)
            {
                foreach (var kv in dict)
                {
                    var key = kv.Key == null ? string.Empty : kv.Key.Replace("_", "").ToLowerInvariant();

                    if (!totalDebit.HasValue && key == "totaldebit")
                    {
                        totalDebit = ToNullableDecimal(kv.Value);
                    }
                    else if (!totalCredit.HasValue && key == "totalcredit")
                    {
                        totalCredit = ToNullableDecimal(kv.Value);
                    }

                    FindTotalsRecursive(kv.Value, ref totalDebit, ref totalCredit);
                }
                return;
            }

            var list = node as object[];
            if (list != null)
            {
                foreach (var item in list)
                {
                    FindTotalsRecursive(item, ref totalDebit, ref totalCredit);
                }
            }
        }

        private static decimal? ToNullableDecimal(object value)
        {
            if (value == null)
            {
                return null;
            }

            decimal parsed;
            if (decimal.TryParse(Convert.ToString(value), out parsed))
            {
                return parsed;
            }

            return null;
        }

        private static string NormalizeDateString(string input)
        {
            if (string.IsNullOrWhiteSpace(input))
            {
                return string.Empty;
            }

            var match = Regex.Match(input, @"/Date\((\d+)\)/");
            if (match.Success)
            {
                long milliseconds;
                if (long.TryParse(match.Groups[1].Value, out milliseconds))
                {
                    return DateTimeOffset.FromUnixTimeMilliseconds(milliseconds).UtcDateTime.ToString("yyyy-MM-dd");
                }
            }

            DateTime dt;
            if (DateTime.TryParseExact(input, new[] { "MM/dd/yyyy", "yyyy-MM-dd", "M/d/yyyy", "MM/dd/yy", "yyyy-MM-dd HH:mm:ss" }, CultureInfo.InvariantCulture, DateTimeStyles.None, out dt))
            {
                return dt.ToString("yyyy-MM-dd");
            }

            if (DateTime.TryParse(input, out dt))
            {
                return dt.ToString("yyyy-MM-dd");
            }

            return input;
        }


        [WebMethod]
        public static bool DeleteRecord(string VOUCHERID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                var V_ID = (from itm in db.GL_Vouchers
                            where (itm.Voucher_ID == int.Parse(VOUCHERID))
                            select itm.Voucher_ID).FirstOrDefault();
                if (V_ID != 0)
                {
                    DBClass.exectueQuery("update GL_Voucher_Accounts set iscancel = 1 where Voucher_ID =" + V_ID, tranObj, con);
                    DBClass.exectueQuery("update gl_vouchers set iscancel = 1 where Voucher_ID =" + V_ID, tranObj, con);
                    DBClass.exectueQuery("update gl_vouchers set cancelby = '" + AppConfig.UserID + "' where Voucher_ID =" + V_ID, tranObj, con);
                    tranObj.Commit();
                }
                else
                {
                    tranObj.Rollback();
                    return false;
                }
            }
#pragma warning disable CS0168 // The variable 'ex' is declared but never used
            catch (Exception ex)
#pragma warning restore CS0168 // The variable 'ex' is declared but never used
            {
                if (tranObj != null)
                    tranObj.Rollback();
                return false;
            }
            return true;
        }
    }
}