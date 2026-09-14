using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;

namespace PMS.Modules.Dashboards
{
    public partial class StudentAffairDashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        private static void ResolveDates(string period, string startDateStr, string endDateStr, out DateTime startDate, out DateTime endDate)
        {
            DateTime now = DateTime.Now;
            startDate = DateTime.Today;
            endDate = DateTime.Now;

            DateTime ps = DateTime.MinValue, pe = DateTime.MinValue;
            bool hasStart = !string.IsNullOrEmpty(startDateStr) && DateTime.TryParseExact(startDateStr, "dd/MM/yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out ps);
            bool hasEnd = !string.IsNullOrEmpty(endDateStr) && DateTime.TryParseExact(endDateStr, "dd/MM/yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out pe);
            if (hasStart && hasEnd)
            {
                startDate = ps;
                endDate = pe.Date.AddDays(1).AddTicks(-1);
                return;
            }

            switch (period.ToLower())
            {
                case "yesterday":
                    startDate = DateTime.Today.AddDays(-1);
                    endDate = DateTime.Today.AddDays(-1).AddDays(1).AddTicks(-1);
                    break;
                case "week":
                    int diff = (7 + (now.DayOfWeek - DayOfWeek.Monday)) % 7;
                    startDate = now.AddDays(-1 * diff).Date;
                    endDate = now;
                    break;
                case "month":
                    startDate = new DateTime(now.Year, now.Month, 1);
                    endDate = now;
                    break;
                case "year":
                    startDate = new DateTime(now.Year, 1, 1);
                    endDate = now;
                    break;
                case "custom":
                    if (hasStart) startDate = ps;
                    if (hasEnd) endDate = pe.Date.AddDays(1).AddTicks(-1);
                    break;
                default:
                    startDate = DateTime.Today;
                    endDate = DateTime.Today.AddDays(1).AddTicks(-1);
                    break;
            }
        }

        private static Dictionary<string, string> LoadValueSetLabels(DataBaseDataContext db, string setName)
        {
            Dictionary<string, string> map = new Dictionary<string, string>();
            try
            {
                int? setId = (from v in db.ValueSets
                              where v.ValueSet_Description == setName
                              select (int?)v.ValueSet_ID).FirstOrDefault();
                if (setId != null)
                {
                    var rows = (from dv in db.DataValues
                                where (int?)dv.ValueSet_ID == setId
                                select new { dv.DataValue_Name, dv.DataValue_Description }).ToList();
                    foreach (var r in rows)
                    {
                        string label = string.IsNullOrEmpty(r.DataValue_Description) ? r.DataValue_Name : r.DataValue_Description;
                        if (!string.IsNullOrEmpty(r.DataValue_Name) && !map.ContainsKey(r.DataValue_Name))
                            map[r.DataValue_Name] = label;
                        if (!string.IsNullOrEmpty(r.DataValue_Description) && !map.ContainsKey(r.DataValue_Description))
                            map[r.DataValue_Description] = label;
                    }
                }
            }
            catch { }
            return map;
        }

        private static Dictionary<string, string> LoadClassLabels(DataBaseDataContext db)
        {
            return LoadValueSetLabels(db, "Student Class");
        }

        private static string ClassLabel(string key, Dictionary<string, string> map)
        {
            if (string.IsNullOrEmpty(key)) return "Unassigned";
            string label;
            if (map.TryGetValue(key.Trim(), out label)) return label;
            return key.Trim();
        }

        private static string fmtAmt(decimal v)
        {
            return v.ToString("#,##0");
        }

        [WebMethod(EnableSession = false)]
        public static string GetOverallStats()
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var rows = (from st in db.Reg_Students
                                where (st.Is_Cancel == null || st.Is_Cancel == false)
                                select new { st.Is_Active }).ToList();

                    int active = rows.Count(x => x.Is_Active == null || x.Is_Active == true);
                    int inactive = rows.Count(x => x.Is_Active == false);

                    return new JavaScriptSerializer().Serialize(new
                    {
                        ActiveStudents = active,
                        InactiveStudents = inactive,
                        TotalStudents = rows.Count
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetStats(string period, string startDate = null, string endDate = null)
        {
            try
            {
                DateTime sDate, eDate;
                ResolveDates(period, startDate, endDate, out sDate, out eDate);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    int newAdmissions = (from st in db.Reg_Students
                                         where (st.Is_Cancel == null || st.Is_Cancel == false) &&
                                               st.CreatedTime != null &&
                                               st.CreatedTime >= sDate && st.CreatedTime <= eDate
                                         select st).Count();

                    decimal feesGenerated = (from f in db.Student_Fees
                                             where (f.IsCancel == null || f.IsCancel == false) &&
                                                   ((f.Date != null && f.Date >= sDate && f.Date <= eDate) ||
                                                    (f.Date == null && f.Creation_Time != null && f.Creation_Time >= sDate && f.Creation_Time <= eDate))
                                             select (decimal?)f.Total_Amount).Sum() ?? 0;

                    decimal collections = (from r in db.Student_Receipts
                                           where (r.IsCancel == null || r.IsCancel == false) &&
                                                 r.Student_Receipt_Date != null &&
                                                 r.Student_Receipt_Date >= sDate && r.Student_Receipt_Date <= eDate
                                           select (decimal?)(r.Amount_Received ?? 0)).Sum() ?? 0;

                    int pendingApproval = (from f in db.Student_Fees
                                           where (f.IsCancel == null || f.IsCancel == false) && f.Status != "Approved"
                                           select f).Count();

                    var approvedDetails = (from fd in db.Student_Fee_Details
                                           join f in db.Student_Fees on fd.Student_Fee_ID equals f.Fee_ID
                                           where (f.IsCancel == null || f.IsCancel == false) && f.Status == "Approved"
                                           select new { Student_Fee_Detail_ID = (int?)fd.Student_Fee_Detail_ID, fd.Payable_Fee, ClassKey = f.Student_Class }).ToList();

                    var paid = (from rd in db.Student_Receipt_Details
                                join r in db.Student_Receipts on rd.Student_Receipt_ID equals r.Student_Receipt_ID
                                where (r.IsCancel == null || r.IsCancel == false)
                                group rd by rd.Student_Fee_Detail_ID into g
                                select new { g.Key, Amt = g.Sum(x => (decimal?)(x.Rec_Amount ?? 0)) ?? 0 }).ToList();

                    Dictionary<int?, decimal> paidMap = new Dictionary<int?, decimal>();
                    foreach (var p in paid)
                        paidMap[p.Key] = p.Amt;

                    decimal outstanding = 0;
                    Dictionary<string, decimal> classOut = new Dictionary<string, decimal>();
                    foreach (var d in approvedDetails)
                    {
                        decimal paidAmt = (d.Student_Fee_Detail_ID.HasValue && paidMap.ContainsKey(d.Student_Fee_Detail_ID))
                                              ? paidMap[d.Student_Fee_Detail_ID] : 0;
                        decimal bal = Math.Max(0, (d.Payable_Fee ?? 0) - paidAmt);
                        outstanding += bal;
                        string ck = d.ClassKey ?? "";
                        if (classOut.ContainsKey(ck)) classOut[ck] += bal; else classOut[ck] = bal;
                    }

                    var classMap = LoadClassLabels(db);
                    var classOutTop = classOut.Where(x => x.Value > 0)
                                              .OrderByDescending(x => x.Value)
                                              .Take(6)
                                              .Select(x => new { Label = ClassLabel(x.Key, classMap), Value = x.Value })
                                              .ToList();

                    return new JavaScriptSerializer().Serialize(new
                    {
                        NewAdmissions = newAdmissions,
                        FeesGenerated = feesGenerated,
                        Collections = collections,
                        Outstanding = outstanding,
                        PendingApproval = pendingApproval,
                        ClassOutstanding = classOutTop
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetFeeTrend(string period, string startDate = null, string endDate = null)
        {
            try
            {
                DateTime sDate, eDate;
                ResolveDates(period, startDate, endDate, out sDate, out eDate);
                if ((eDate - sDate).TotalDays < 60)
                {
                    sDate = new DateTime(sDate.Year, 1, 1);
                }

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var feeMonth = (from f in db.Student_Fees
                                    where (f.IsCancel == null || f.IsCancel == false) &&
                                          f.Date != null && f.Date >= sDate && f.Date <= eDate
                                    group f by new { f.Date.Value.Year, f.Date.Value.Month } into g
                                    select new { g.Key.Year, g.Key.Month, Sum = g.Sum(x => (decimal?)(x.Total_Amount ?? 0)) ?? 0 }).ToList();

                    var colMonth = (from r in db.Student_Receipts
                                    where (r.IsCancel == null || r.IsCancel == false) &&
                                          r.Student_Receipt_Date != null &&
                                          r.Student_Receipt_Date >= sDate && r.Student_Receipt_Date <= eDate
                                    group r by new { r.Student_Receipt_Date.Value.Year, r.Student_Receipt_Date.Value.Month } into g
                                    select new { g.Key.Year, g.Key.Month, Sum = g.Sum(x => (decimal?)(x.Amount_Received ?? 0)) ?? 0 }).ToList();

                    Dictionary<int, decimal> fees = feeMonth.ToDictionary(x => x.Year * 100 + x.Month, x => x.Sum);
                    Dictionary<int, decimal> cols = colMonth.ToDictionary(x => x.Year * 100 + x.Month, x => x.Sum);

                    var months = new List<string>();
                    var feeSeries = new List<decimal>();
                    var colSeries = new List<decimal>();
                    DateTime cur = new DateTime(sDate.Year, sDate.Month, 1);
                    DateTime stop = new DateTime(eDate.Year, eDate.Month, 1);
                    while (cur <= stop)
                    {
                        int key = cur.Year * 100 + cur.Month;
                        months.Add(cur.ToString("MMM") + "-" + cur.Year.ToString().Substring(2));
                        feeSeries.Add(fees.ContainsKey(key) ? fees[key] : 0);
                        colSeries.Add(cols.ContainsKey(key) ? cols[key] : 0);
                        cur = cur.AddMonths(1);
                    }

                    return new JavaScriptSerializer().Serialize(new
                    {
                        Months = months,
                        Fees = feeSeries,
                        Collections = colSeries
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetFeeStatus(string period, string startDate = null, string endDate = null)
        {
            try
            {
                DateTime sDate, eDate;
                ResolveDates(period, startDate, endDate, out sDate, out eDate);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var rows = (from f in db.Student_Fees
                                where (f.Date != null && f.Date >= sDate && f.Date <= eDate) ||
                                      (f.Date == null && f.Creation_Time != null && f.Creation_Time >= sDate && f.Creation_Time <= eDate)
                                select new { Amount = f.Total_Amount ?? 0, f.IsCancel, f.Status }).ToList();

                    decimal approvedAmt = 0, unapprovedAmt = 0, cancelledAmt = 0;
                    int approvedCnt = 0, unapprovedCnt = 0, cancelledCnt = 0;
                    foreach (var r in rows)
                    {
                        if (r.IsCancel == true) { cancelledAmt += r.Amount; cancelledCnt++; }
                        else if (r.Status == "Approved") { approvedAmt += r.Amount; approvedCnt++; }
                        else { unapprovedAmt += r.Amount; unapprovedCnt++; }
                    }

                    return new JavaScriptSerializer().Serialize(new
                    {
                        ApprovedAmt = approvedAmt, ApprovedCnt = approvedCnt,
                        UnapprovedAmt = unapprovedAmt, UnapprovedCnt = unapprovedCnt,
                        CancelledAmt = cancelledAmt, CancelledCnt = cancelledCnt
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetStudentDistribution()
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var classMap = LoadClassLabels(db);
                    var dist = (from st in db.Reg_Students
                                where (st.Is_Cancel == null || st.Is_Cancel == false) &&
                                      (st.Is_Active == null || st.Is_Active == true) &&
                                      st.Class != null && st.Class != ""
                                group st by st.Class into g
                                select new { g.Key, Count = g.Count() }).ToList();

                    var top = dist.OrderByDescending(x => x.Count).Take(10)
                                  .Select(x => new { Label = ClassLabel(x.Key, classMap), Count = x.Count })
                                  .ToList();

                    return new JavaScriptSerializer().Serialize(new
                    {
                        Distribution = top,
                        Total = dist.Sum(x => x.Count)
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetAttendanceStats(string period, string startDate = null, string endDate = null)
        {
            try
            {
                DateTime sDate, eDate;
                ResolveDates(period, startDate, endDate, out sDate, out eDate);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var rows = (from a in db.Student_Attendances
                                where a.Attendance_date != null && a.Attendance_date >= sDate && a.Attendance_date <= eDate
                                select new { a.Class, a.Present, a.Absent, a.Leave }).ToList();

                    int present = rows.Count(x => x.Present == true);
                    int absent = rows.Count(x => x.Absent == true);
                    int leave = rows.Count(x => x.Leave == true);
                    int total = present + absent + leave;

                    var classMap = LoadClassLabels(db);
                    var byClass = rows.GroupBy(x => x.Class)
                                      .Select(g => new
                                      {
                                          Class = g.Key,
                                          Present = g.Count(x => x.Present == true),
                                          Absent = g.Count(x => x.Absent == true),
                                          Leave = g.Count(x => x.Leave == true)
                                      })
                                      .OrderByDescending(x => x.Present + x.Absent + x.Leave)
                                      .Take(6)
                                      .Select(x => new
                                      {
                                          Label = ClassLabel(x.Class, classMap),
                                          Present = x.Present,
                                          Absent = x.Absent,
                                          Leave = x.Leave,
                                          Total = x.Present + x.Absent + x.Leave
                                      })
                                      .ToList();

                    return new JavaScriptSerializer().Serialize(new
                    {
                        Present = present,
                        Absent = absent,
                        Leave = leave,
                        Total = total,
                        AttendanceRate = total > 0 ? Math.Round((double)present / total * 100, 1) : 0,
                        ByClass = byClass
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetEnrolmentFilters()
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var classes = (from dv in db.DataValues
                                   join v in db.ValueSets on dv.ValueSet_ID equals v.ValueSet_ID
                                   where v.ValueSet_Description == "Student Class"
                                   orderby dv.DataValue_Description
                                   select new { Value = dv.DataValue_Name, Label = dv.DataValue_Description }).ToList();

                    var programs = (from dv in db.DataValues
                                    join v in db.ValueSets on dv.ValueSet_ID equals v.ValueSet_ID
                                    where v.ValueSet_Description == "Admission Category"
                                    orderby dv.DataValue_Description
                                    select new { Value = dv.DataValue_Name, Label = dv.DataValue_Description }).ToList();

                    return new JavaScriptSerializer().Serialize(new { Classes = classes, Programs = programs });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetEnrolmentList(string cls = null, string prog = null, string status = null)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    string c = string.IsNullOrEmpty(cls) || cls == "0" ? "" : cls;
                    string p = string.IsNullOrEmpty(prog) || prog == "0" ? "" : prog;

                    var baseList = (from st in db.Reg_Students
                                    where (st.Is_Cancel == null || st.Is_Cancel == false) &&
                                          (c == "" || st.Class == c) &&
                                          (p == "" || st.Program == p)
                                    select new { st.Full_Name, st.Roll_No, st.Class, st.Program, st.Is_Active }).ToList();

                    int active = baseList.Count(x => x.Is_Active == null || x.Is_Active == true);
                    int inactive = baseList.Count(x => x.Is_Active == false);

                    var classMap = LoadClassLabels(db);
                    var progMap = LoadValueSetLabels(db, "Admission Category");

                    var filtered = baseList.AsEnumerable();
                    if (status == "active") filtered = filtered.Where(x => x.Is_Active == null || x.Is_Active == true);
                    else if (status == "inactive") filtered = filtered.Where(x => x.Is_Active == false);

                    var ordered = filtered.OrderBy(x => x.Full_Name).ToList();
                    int shown = Math.Min(ordered.Count, 300);

                    var students = ordered.Take(300).Select(x => new
                    {
                        Name = string.IsNullOrEmpty(x.Full_Name) ? "Unnamed" : x.Full_Name,
                        Roll = x.Roll_No,
                        Class = ClassLabel(x.Class, classMap),
                        Program = ClassLabel(x.Program, progMap),
                        Active = x.Is_Active == null || x.Is_Active == true
                    }).ToList();

                    return new JavaScriptSerializer().Serialize(new
                    {
                        Active = active,
                        Inactive = inactive,
                        Total = baseList.Count,
                        Shown = shown,
                        Students = students
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetRecentReceipts()
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var recent = (from r in db.Student_Receipts
                                  where (r.IsCancel == null || r.IsCancel == false) && r.Status == "Approved"
                                  orderby r.Student_Receipt_ID descending
                                  select new { r.Student_Receipt_No, r.Student_Receipt_Date, r.Student_ID, r.Net_Payable, r.Amount_Received, r.Balance }).Take(8).ToList();

                    List<int?> ids = recent.Where(x => x.Student_ID != null).Select(x => x.Student_ID).Distinct().ToList();
                    Dictionary<int?, string> names = new Dictionary<int?, string>();
                    if (ids.Count > 0)
                    {
                        names = (from st in db.Reg_Students
                                 where ids.Contains((int?)st.Student_Id)
                                 select new { st.Student_Id, st.Full_Name }).ToDictionary(x => (int?)x.Student_Id, x => x.Full_Name);
                    }

                    var items = recent.Select(x => new
                    {
                        No = x.Student_Receipt_No,
                        Date = x.Student_Receipt_Date != null ? ((DateTime)x.Student_Receipt_Date).ToString("dd-MMM-yy") : "",
                        Student = x.Student_ID.HasValue && names.ContainsKey(x.Student_ID) ? names[x.Student_ID] : "N/A",
                        Net = x.Net_Payable ?? 0,
                        Received = x.Amount_Received ?? 0,
                        Balance = x.Balance ?? 0
                    }).ToList();

                    return new JavaScriptSerializer().Serialize(items);
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new[] { new { Error = ex.Message } });
            }
        }
    }
}
