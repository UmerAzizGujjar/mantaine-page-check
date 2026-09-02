using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;

namespace PMS.Modules.Dashboards
{
    public partial class DashPatientsCountertoClinic : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e) { }

        public class StageInfo
        {
            public string name { get; set; }
            public int minutes { get; set; }
            public string avgTime { get; set; }
            public bool isHighest { get; set; }
        }

        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue, string txt_sdate, string txt_edate)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var all = db.sp_GetPatientCounter_to_Clinic_details(txt_sdate, txt_edate).ToList();

                if (!string.IsNullOrEmpty(searchValue))
                {
                    string sv = searchValue.ToLower();
                    all = all.Where(x =>
                        (x.mr_no_sequence ?? "").ToLower().Contains(sv) ||
                        (x.Full_Name ?? "").ToLower().Contains(sv)).ToList();
                }

                Func<sp_GetPatientCounter_to_Clinic_detailsResult, object> orderFn;
                switch (sortColumn)
                {
                    case "mrNo": orderFn = x => x.mr_no_sequence; break;
                    case "patientName": orderFn = x => x.Full_Name; break;
                    default: orderFn = x => x.Patient_No; break;
                }

                if (sortColumnDirection == "desc")
                    all = all.OrderByDescending(orderFn).ToList();
                else
                    all = all.OrderBy(orderFn).ToList();

                int totalRecords = all.Count;
                var page = all.Skip(start).Take(length).ToList();

                string Fmt(DateTime? dt)
                {
                    return dt.HasValue ? dt.Value.ToString("dd-MMM-yyyy hh:mm tt") : "";
                }

                var data = page.Select((x, i) => new
                {
                    srNo = start + i + 1,
                    mrNo = x.mr_no_sequence ?? "",
                    patientName = x.Full_Name ?? "",
                    regTime = Fmt(x.Reg_Time),
                    opdTime = Fmt(x.Opd_Time),
                    vitalsTime = !string.IsNullOrEmpty(x.Vitals_Date)? DateTime.Parse(x.Vitals_Date).ToString("dd-MMM-yyyy"): "",
                    outPatientTime = Fmt(x.Out_patient_Time),
                    labTime = Fmt(x.Lab_Time),
                    medicineTime = Fmt(x.Medicine_Time),
                    serviceTime = Fmt(x.Service_Time),
                    dischargeDate = Fmt(x.Discharge_Date),
                    totalTime = x.Total_Time_Spent ?? ""
                }).ToList();

                return new { draw, recordsTotal = totalRecords, recordsFiltered = totalRecords, data };
            }
        }

        [WebMethod]
        public static string GetDashboardData(string txt_sdate, string txt_edate)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var all = db.sp_GetPatientCounter_to_Clinic_details(txt_sdate, txt_edate).ToList();

                int totalPatients = all.Count;
                int totalMinSum = all.Sum(x => x.Total_Time_Spent_Minutes ?? 0);
                double avgTotalHours = totalPatients > 0 ? Math.Round((double)totalMinSum / totalPatients / 60, 1) : 0;

                double o2o = 0; int o2oN = 0;
                double o2l = 0; int o2lN = 0;
                double o2m = 0; int o2mN = 0;
                double m2s = 0; int m2sN = 0;
                double s2d = 0; int s2dN = 0;

                foreach (var row in all)
                {
                    if (row.Opd_Time.HasValue && row.Out_patient_Time.HasValue)
                    {
                        double d = (row.Out_patient_Time.Value - row.Opd_Time.Value).TotalMinutes;
                        if (d >= 0) { o2o += d; o2oN++; }
                    }
                    if (row.Out_patient_Time.HasValue && row.Lab_Time.HasValue)
                    {
                        double d = (row.Lab_Time.Value - row.Out_patient_Time.Value).TotalMinutes;
                        if (d >= 0) { o2l += d; o2lN++; }
                    }
                    if (row.Out_patient_Time.HasValue && row.Medicine_Time.HasValue)
                    {
                        double d = (row.Medicine_Time.Value - row.Out_patient_Time.Value).TotalMinutes;
                        if (d >= 0) { o2m += d; o2mN++; }
                    }
                    if (row.Medicine_Time.HasValue && row.Service_Time.HasValue)
                    {
                        double d = (row.Service_Time.Value - row.Medicine_Time.Value).TotalMinutes;
                        if (d >= 0) { m2s += d; m2sN++; }
                    }
                    if (row.Service_Time.HasValue && row.Discharge_Date.HasValue)
                    {
                        double d = (row.Discharge_Date.Value - row.Service_Time.Value).TotalMinutes;
                        if (d >= 0) { s2d += d; s2dN++; }
                    }
                }

                string avgStr(double sum, int count)
                {
                    if (count <= 0) return "";
                    int avg = (int)Math.Round(sum / count, 0);
                    if (avg < 60) return $"{avg}m";
                    return $"{avg / 60}h {avg % 60}m";
                }

                DateTime currFrom = DateTime.ParseExact(txt_sdate, "yyyy-MM-dd", CultureInfo.InvariantCulture);
                DateTime currTo = DateTime.ParseExact(txt_edate, "yyyy-MM-dd", CultureInfo.InvariantCulture);
                int spanDays = (currTo - currFrom).Days + 1;
                DateTime prevFrom = currFrom.AddDays(-spanDays);
                DateTime prevTo = currFrom.AddDays(-1);

                int prevPatients = 0;
                double prevAvgHours = 0;
                if (prevFrom < currFrom)
                {
                    var prev = db.sp_GetPatientCounter_to_Clinic_details(prevFrom.ToString("yyyy-MM-dd"), prevTo.ToString("yyyy-MM-dd")).ToList();
                    prevPatients = prev.Count;
                    int prevMinSum = prev.Sum(x => x.Total_Time_Spent_Minutes ?? 0);
                    prevAvgHours = prevPatients > 0 ? Math.Round((double)prevMinSum / prevPatients / 60, 1) : 0;
                }

                double ptTrendPct = prevPatients > 0 ? Math.Round((double)(totalPatients - prevPatients) / prevPatients * 100, 1) : 0;
                double avgTrendPct = prevAvgHours > 0 ? Math.Round((avgTotalHours - prevAvgHours) / prevAvgHours * 100, 1) : 0;

                var stages = new List<StageInfo>();
                stages.Add(new StageInfo { name = "Registration", minutes = 0, avgTime = "" });
                stages.Add(new StageInfo { name = "Consultation", minutes = o2oN > 0 ? (int)Math.Round(o2o / o2oN) : 0, avgTime = avgStr(o2o, o2oN) });
                stages.Add(new StageInfo { name = "Lab", minutes = o2lN > 0 ? (int)Math.Round(o2l / o2lN) : 0, avgTime = avgStr(o2l, o2lN) });
                stages.Add(new StageInfo { name = "Pharmacy", minutes = o2mN > 0 ? (int)Math.Round(o2m / o2mN) : 0, avgTime = avgStr(o2m, o2mN) });
                stages.Add(new StageInfo { name = "Service", minutes = m2sN > 0 ? (int)Math.Round(m2s / m2sN) : 0, avgTime = avgStr(m2s, m2sN) });
                stages.Add(new StageInfo { name = "Discharge", minutes = s2dN > 0 ? (int)Math.Round(s2d / s2dN) : 0, avgTime = avgStr(s2d, s2dN) });

                int maxMins = stages.Max(s => s.minutes);
                string highestName = maxMins > 0 ? stages.First(s => s.minutes == maxMins).name : "No Data";
                string highestTime = maxMins > 0 ? avgStr(maxMins, 1) : "";

                foreach (var s in stages)
                    s.isHighest = s.minutes == maxMins && maxMins > 0;

                var result = new
                {
                    totalPatients,
                    avgTotalTime = avgTotalHours > 0 ? avgTotalHours + "h" : "0h",
                    avgTotalTimeHours = avgTotalHours,
                    highestStage = highestName,
                    highestStageTime = highestTime,
                    stages,
                    ptTrend = totalPatients >= prevPatients ? "up" : "down",
                    ptTrendPercent = Math.Abs(ptTrendPct),
                    avgTrend = avgTotalHours >= prevAvgHours ? "up" : "down",
                    avgTrendPercent = Math.Abs(avgTrendPct)
                };

                var serializer = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };
                return serializer.Serialize(result);
            }
        }
    }
}
