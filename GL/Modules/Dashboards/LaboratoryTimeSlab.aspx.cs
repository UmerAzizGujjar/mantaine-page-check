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

        public class RadTimeSlabRow
        {
            public string MR_No { get; set; }
            public string Patient_Name { get; set; }
            public string Study { get; set; }
            public DateTime? Slip_Time { get; set; }
            public DateTime? Report_Time { get; set; }
        }

        // Radiology & Imaging (depts 002/003/004): slip generation -> consultant report entry.
        private static List<RadTimeSlabRow> GetRadiologyRows(DataBaseDataContext db, string txt_sdate, string txt_edate)
        {
            DateTime fromDt = ParseDate(txt_sdate);
            DateTime toDt = ParseDate(txt_edate).AddDays(1);
            db.CommandTimeout = 180;

            return (from ltd in db.Lab_Test_Details
                    join tdef in db.Lab_Tests on ltd.Test_ID equals tdef.Test_ID
                    join pa in db.Reg_patients on ltd.Patient_ID equals pa.pat_id
                    join bd in db.Ar_Billing_Details on ltd.Bill_Details_ID equals bd.Bill_Details_ID
                    join ar in db.Ar_Billings on bd.Bill_ID equals ar.Bill_ID
                    where (bd.Test_Main_Department == "002" || bd.Test_Main_Department == "003" || bd.Test_Main_Department == "004")
                       && ar.Creation_Date >= fromDt && ar.Creation_Date < toDt
                       && (ar.isCancel == null || ar.isCancel == false)
                    select new RadTimeSlabRow
                    {
                        MR_No = pa.mr_no_sequence,
                        Patient_Name = pa.Full_Name,
                        Study = tdef.Test_Name,
                        Slip_Time = ar.Creation_Date,
                        Report_Time = ltd.Is_Result == true ? ltd.Created_Time : null
                    }).ToList();
        }

        private static string FormatDt(DateTime? d)
        {
            return d.HasValue ? d.Value.ToString("dd-MMM-yyyy hh:mm tt") : "";
        }

        [WebMethod]
        public static object RadiologyViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue, string txt_sdate, string txt_edate)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var all = GetRadiologyRows(db, txt_sdate, txt_edate).Select(x => new
                {
                    mrNo = x.MR_No ?? "",
                    patientName = x.Patient_Name ?? "",
                    study = x.Study ?? "",
                    slipDate = x.Slip_Time,
                    reportDate = x.Report_Time,
                    mins = (x.Slip_Time.HasValue && x.Report_Time.HasValue)
                        ? (int?)Math.Max(0, (int)(x.Report_Time.Value - x.Slip_Time.Value).TotalMinutes) : null
                }).ToList();

                if (!string.IsNullOrEmpty(searchValue))
                {
                    string sv = searchValue.ToLower();
                    all = all.Where(x => x.mrNo.ToLower().Contains(sv) || x.patientName.ToLower().Contains(sv) || x.study.ToLower().Contains(sv)).ToList();
                }

                bool desc = sortColumnDirection == "desc";
                switch (sortColumn)
                {
                    case "mrNo": all = desc ? all.OrderByDescending(x => x.mrNo).ToList() : all.OrderBy(x => x.mrNo).ToList(); break;
                    case "patientName": all = desc ? all.OrderByDescending(x => x.patientName).ToList() : all.OrderBy(x => x.patientName).ToList(); break;
                    case "study": all = desc ? all.OrderByDescending(x => x.study).ToList() : all.OrderBy(x => x.study).ToList(); break;
                    case "slipDate": all = desc ? all.OrderByDescending(x => x.slipDate).ToList() : all.OrderBy(x => x.slipDate).ToList(); break;
                    case "reportDate": all = desc ? all.OrderByDescending(x => x.reportDate).ToList() : all.OrderBy(x => x.reportDate).ToList(); break;
                    case "totalTimeMinutes": all = desc ? all.OrderByDescending(x => x.mins).ToList() : all.OrderBy(x => x.mins).ToList(); break;
                }

                int total = all.Count;
                var data = all.Skip(start).Take(length).Select((x, i) => new
                {
                    srNo = start + i + 1,
                    x.mrNo,
                    x.patientName,
                    x.study,
                    slipDate = FormatDt(x.slipDate),
                    reportDate = x.reportDate.HasValue ? FormatDt(x.reportDate) : "Pending",
                    totalTime = x.mins.HasValue ? FormatMinutes(x.mins.Value) : "-",
                    totalTimeMinutes = x.mins ?? -1
                }).ToList();

                return new { draw, recordsTotal = total, recordsFiltered = total, data };
            }
        }

        [WebMethod]
        public static string GetRadiologyDashboard(string txt_sdate, string txt_edate)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var all = GetRadiologyRows(db, txt_sdate, txt_edate);
                var done = all.Where(x => x.Slip_Time.HasValue && x.Report_Time.HasValue)
                              .Select(x => Math.Max(0, (x.Report_Time.Value - x.Slip_Time.Value).TotalMinutes)).ToList();

                int avg = done.Any() ? (int)Math.Round(done.Average(), 0) : 0;
                int max = done.Any() ? (int)Math.Round(done.Max(), 0) : 0;

                return new JavaScriptSerializer().Serialize(new
                {
                    totalStudies = all.Count,
                    reported = done.Count,
                    pending = all.Count - done.Count,
                    avgTat = FormatMinutes(avg),
                    maxTat = FormatMinutes(max)
                });
            }
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

        [WebMethod]
        public static string GetPreviousTests(string mrNo)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var pat = db.Reg_patients.FirstOrDefault(p => p.mr_no_sequence == mrNo);
                if (pat == null) return "[]";

                int? patientNo = pat.Patient_No;

                var individual = (from ltm in db.Laboratory_Tests
                                  join ltd in db.Lab_Test_Details on ltm.Lab_Test_ID equals ltd.Lab_Test_ID
                                  join tdef in db.Lab_Tests on ltd.Test_ID equals tdef.Test_ID
                                  join bd in db.Ar_Billing_Details on ltd.Bill_Details_ID equals bd.Bill_Details_ID
                                  where ltm.Patient_ID == pat.pat_id
                                     && (bd.Is_Group_Category == null ? false : bd.Is_Group_Category) == false
                                  select new
                                  {
                                      TestName = tdef.Test_Name,
                                      TestDate = bd.Service_Date,
                                      IsApproved = ltd.isApproved
                                  }).ToList();

                var groups = (from ld in db.Lab_Test_Details
                              join p in db.Reg_patients on ld.Patient_ID equals p.pat_id
                              join bt in db.Lab_Tests on ld.Test_ID equals bt.Test_ID
                              join ltm in db.Laboratory_Tests on ld.Lab_Test_ID equals ltm.Lab_Test_ID
                              join bd in db.Ar_Billing_Details on ld.Bill_Details_ID equals bd.Bill_Details_ID
                              where p.Patient_No == patientNo
                                 && (bd.Is_Group_Category == null ? false : bd.Is_Group_Category) == true
                              group new { ld, bt, bd } by new { ld.Lab_Test_ID, bt.Group_Category } into g
                              select new
                              {
                                  TestName = db.GetDataValueName("Test Groups", g.Key.Group_Category) ?? g.Key.Group_Category,
                                  TestDate = g.Max(x => x.bd.Service_Date),
                                  IsApproved = g.Max(x => x.ld.isApproved == true ? 1 : (int?)0)
                              }).ToList();

                var rows = individual
                    .Select(x => new { x.TestName, x.TestDate, Ok = x.IsApproved == true })
                    .Concat(groups.Select(x => new { x.TestName, x.TestDate, Ok = x.IsApproved == 1 }))
                    .OrderByDescending(x => x.TestDate)
                    .ThenBy(x => x.TestName)
                    .ToList();

                return new JavaScriptSerializer().Serialize(rows.Select(x => new
                {
                    testName = x.TestName,
                    testDate = x.TestDate.HasValue ? x.TestDate.Value.ToString("dd-MMM-yyyy") : "",
                    status = x.Ok ? "Approved" : "Pending"
                }));
            }
        }
    }
}
