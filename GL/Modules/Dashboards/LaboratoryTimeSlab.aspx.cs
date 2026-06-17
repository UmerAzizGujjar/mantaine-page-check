using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;

namespace PMS.Modules.Dashboards
{
    public partial class LaboratoryTimeSlab : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e) { }

        public class LabTimeSlabDTO
        {
            public string MR_No { get; set; }
            public string Patient_Name { get; set; }
            public string Bill_Date { get; set; }
            public string Sample_Date { get; set; }
            public string Lab_Date { get; set; }
            public string Report_Date { get; set; }
            public string Approve_Date { get; set; }
            public int Total_Time_Spent_Minutes { get; set; }
            public string Total_Time_Spent { get; set; }
        }

        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue, string txt_sdate, string txt_edate)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                string query = "EXEC [dbo].[sp_GetLaboratoryTimeSlab_Details] @StartDate = {0}, @EndDate = {1}";
                var all = db.ExecuteQuery<LabTimeSlabDTO>(query, txt_sdate, txt_edate).ToList();

                if (!string.IsNullOrEmpty(searchValue))
                {
                    string sv = searchValue.ToLower();
                    all = all.Where(x =>
                        (x.MR_No ?? "").ToLower().Contains(sv) ||
                        (x.Patient_Name ?? "").ToLower().Contains(sv)).ToList();
                }

                Func<LabTimeSlabDTO, object> orderFn;
                switch (sortColumn)
                {
                    case "mrNo": orderFn = x => x.MR_No; break;
                    case "patientName": orderFn = x => x.Patient_Name; break;
                    case "billDate": orderFn = x => x.Bill_Date; break;
                    case "sampleDate": orderFn = x => x.Sample_Date; break;
                    case "labDate": orderFn = x => x.Lab_Date; break;
                    case "reportDate": orderFn = x => x.Report_Date; break;
                    case "approveDate": orderFn = x => x.Approve_Date; break;
                    case "totalTimeMinutes": orderFn = x => x.Total_Time_Spent_Minutes; break;
                    default: orderFn = x => 0; break;
                }

                if (sortColumnDirection == "desc")
                    all = all.OrderByDescending(orderFn).ToList();
                else
                    all = all.OrderBy(orderFn).ToList();

                int totalRecords = all.Count;
                var page = all.Skip(start).Take(length).ToList();

                var data = page.Select((x, i) => new
                {
                    srNo = start + i + 1,
                    mrNo = x.MR_No ?? "",
                    patientName = x.Patient_Name ?? "",
                    billDate = x.Bill_Date ?? "",
                    sampleDate = x.Sample_Date ?? "",
                    labDate = x.Lab_Date ?? "",
                    reportDate = x.Report_Date ?? "",
                    approveDate = x.Approve_Date ?? "",
                    totalTime = x.Total_Time_Spent ?? "-",
                    totalTimeMinutes = x.Total_Time_Spent_Minutes
                }).ToList();

                return new
                {
                    draw,
                    recordsTotal = totalRecords,
                    recordsFiltered = totalRecords,
                    data
                };
            }
        }

        [WebMethod]
        public static string GetDashboardData(string txt_sdate, string txt_edate)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                string query = "EXEC [dbo].[sp_GetLaboratoryTimeSlab_Details] @StartDate = {0}, @EndDate = {1}";
                var all = db.ExecuteQuery<LabTimeSlabDTO>(query, txt_sdate, txt_edate).ToList();

                int totalTests = all.Count;

                DateTime currFrom = ParseDate(txt_sdate);
                DateTime currTo = ParseDate(txt_edate);
                int spanDays = (currTo - currFrom).Days + 1;
                DateTime prevFrom = currFrom.AddDays(-spanDays);
                DateTime prevTo = currFrom.AddDays(-1);

                int prevCount = 0;
                double prevAvgTatMins = 0;
                if (prevFrom < currFrom)
                {
                    var prev = db.ExecuteQuery<LabTimeSlabDTO>(query, prevFrom.ToString("yyyy-MM-dd"), prevTo.ToString("yyyy-MM-dd")).ToList();
                    prevCount = prev.Count;
                    prevAvgTatMins = prev.Any() ? Math.Round(prev.Average(x => x.Total_Time_Spent_Minutes), 0) : 0;
                }

                double trendPct = prevCount > 0 ? Math.Round((double)(totalTests - prevCount) / prevCount * 100, 1) : 0;

                double avgTatMins = all.Any() ? Math.Round(all.Average(x => x.Total_Time_Spent_Minutes), 0) : 0;
                double tatTrendPct = prevAvgTatMins > 0 ? Math.Round((avgTatMins - prevAvgTatMins) / prevAvgTatMins * 100, 1) : 0;

                double b2s = 0, s2l = 0, l2r = 0, r2a = 0;
                int b2sN = 0, s2lN = 0, l2rN = 0, r2aN = 0;

                foreach (var row in all)
                {
                    DateTime billD = ParseDate(row.Bill_Date);
                    DateTime sampleD = ParseDate(row.Sample_Date);
                    DateTime labD = ParseDate(row.Lab_Date);
                    DateTime reportD = ParseDate(row.Report_Date);
                    DateTime approveD = ParseDate(row.Approve_Date);

                    if (billD != DateTime.MinValue && sampleD != DateTime.MinValue)
                    {
                        b2s += (sampleD - billD).TotalMinutes; b2sN++;
                    }
                    if (sampleD != DateTime.MinValue && labD != DateTime.MinValue)
                    {
                        s2l += (labD - sampleD).TotalMinutes; s2lN++;
                    }
                    if (labD != DateTime.MinValue && reportD != DateTime.MinValue)
                    {
                        l2r += (reportD - labD).TotalMinutes; l2rN++;
                    }
                    if (reportD != DateTime.MinValue && approveD != DateTime.MinValue)
                    {
                        r2a += (approveD - reportD).TotalMinutes; r2aN++;
                    }
                }

                b2s = b2sN > 0 ? b2s / b2sN : 0;
                s2l = s2lN > 0 ? s2l / s2lN : 0;
                l2r = l2rN > 0 ? l2r / l2rN : 0;
                r2a = r2aN > 0 ? r2a / r2aN : 0;

                string AvgTimeStr(double mins, int count)
                {
                    if (count <= 0) return "";
                    int avg = (int)Math.Round(mins, 0);
                    return avg == 0 && mins > 0 ? "<1m" : FormatMinutes(avg);
                }

                double maxMins = 0;
                string bnStageName = null;

                if (b2sN > 0 && b2s > maxMins) { maxMins = b2s; bnStageName = "Sample"; }
                if (s2lN > 0 && s2l > maxMins) { maxMins = s2l; bnStageName = "Lab"; }
                if (l2rN > 0 && l2r > maxMins) { maxMins = l2r; bnStageName = "Report"; }
                if (r2aN > 0 && r2a > maxMins) { maxMins = r2a; bnStageName = "Approve"; }

                string bnName = "No Bottleneck";
                int bnMins = (int)Math.Round(maxMins, 0);
                if (bnMins > 0)
                {
                    switch (bnStageName)
                    {
                        case "Sample":  bnName = "Sample Collection"; break;
                        case "Lab":     bnName = "Lab Processing"; break;
                        case "Report":  bnName = "Report"; break;
                        default:        bnName = "Approval"; break;
                    }
                }

                var wfList = new List<object>();
                wfList.Add(new { name = "Billing", minutes = 0, avgTime = "", isBottleneck = false });

                if (b2sN > 0) wfList.Add(new { name = "Sample", minutes = (int)Math.Round(b2s, 0), avgTime = AvgTimeStr(b2s, b2sN), isBottleneck = bnStageName == "Sample" });
                if (s2lN > 0) wfList.Add(new { name = "Lab", minutes = (int)Math.Round(s2l, 0), avgTime = AvgTimeStr(s2l, s2lN), isBottleneck = bnStageName == "Lab" });
                if (l2rN > 0) wfList.Add(new { name = "Report", minutes = (int)Math.Round(l2r, 0), avgTime = AvgTimeStr(l2r, l2rN), isBottleneck = bnStageName == "Report" });
                if (r2aN > 0) wfList.Add(new { name = "Approve", minutes = (int)Math.Round(r2a, 0), avgTime = AvgTimeStr(r2a, r2aN), isBottleneck = bnStageName == "Approve" });

                var workflowStages = wfList.ToArray();

                var result = new
                {
                    totalTests,
                    avgTat = FormatMinutes((int)avgTatMins),
                    avgTatMinutes = (int)avgTatMins,
                    bottleneckName = bnName,
                    bottleneckTime = bnMins > 0 ? FormatMinutes(bnMins) : "",
                    bottleneckMinutes = bnMins,
                    testTrend = totalTests >= prevCount ? "up" : "down",
                    testTrendPercent = Math.Abs(trendPct),
                    tatTrend = avgTatMins >= prevAvgTatMins ? "up" : "down",
                    tatTrendPercent = Math.Abs(tatTrendPct),
                    workflowStages
                };

                var serializer = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };
                return serializer.Serialize(result);
            }
        }

        private static DateTime ParseDate(string s)
        {
            if (string.IsNullOrWhiteSpace(s)) return DateTime.MinValue;
            DateTime d;
            if (DateTime.TryParseExact(s, "dd/MM/yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out d)) return d;
            if (DateTime.TryParseExact(s, "dd-MMM-yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out d)) return d;
            if (DateTime.TryParseExact(s, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out d)) return d;
            if (DateTime.TryParseExact(s, "dd-MM-yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out d)) return d;
            if (DateTime.TryParse(s, out d)) return d;
            return DateTime.MinValue;
        }

        private static string FormatMinutes(int minutes)
        {
            if (minutes < 60) return $"{minutes}m";
            int hours = minutes / 60;
            int mins = minutes % 60;
            return $"{hours}h {mins}m";
        }

        [WebMethod]
        public static string GetMonthlyTrends()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                string query = "EXEC [dbo].[sp_GetLaboratoryTimeSlab_Details] @StartDate = {0}, @EndDate = {1}";
                var months = new List<string>();
                var tests = new List<int>();
                var avgTat = new List<int>();
                var now = DateTime.Now;
                for (int i = 11; i >= 0; i--)
                {
                    var monthStart = new DateTime(now.Year, now.Month, 1).AddMonths(-i);
                    var monthEnd = monthStart.AddMonths(1).AddDays(-1);
                    var all = db.ExecuteQuery<LabTimeSlabDTO>(query, monthStart.ToString("yyyy-MM-dd"), monthEnd.ToString("yyyy-MM-dd")).ToList();
                    months.Add(monthStart.ToString("MMM"));
                    tests.Add(all.Count);
                    avgTat.Add(all.Any() ? (int)Math.Round(all.Average(x => x.Total_Time_Spent_Minutes), 0) : 0);
                }
                return new JavaScriptSerializer().Serialize(new { labels = months, tests, avgTat });
            }
        }
    }
}
