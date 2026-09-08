using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;

namespace PMS.Modules.Dashboards
{
    public partial class PatientsTurnOver : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e) { }

        public class DailyPoint
        {
            public string Date { get; set; }
            public int Billings { get; set; }
            public int OPD { get; set; }
        }

        public class KpiSummary
        {
            public int NewRegistrations { get; set; }
            public int OpdNew { get; set; }
            public int OpdRepeat { get; set; }
            public int TotalBills { get; set; }
            public List<DailyPoint> DailyTrend { get; set; }
        }

        [WebMethod]
        public static string GetPatients(string fromDate, string toDate)
        {
            DateTime from, to;
            string[] fmts = { "MM/dd/yyyy", "M/d/yyyy", "yyyy-MM-dd", "dd-MMM-yyyy" };
            if (!DateTime.TryParseExact(fromDate, fmts, CultureInfo.InvariantCulture, DateTimeStyles.None, out from))
                from = DateTime.Today;
            if (!DateTime.TryParseExact(toDate, fmts, CultureInfo.InvariantCulture, DateTimeStyles.None, out to))
                to = DateTime.Today;

            if (to < from) { var t = from; from = to; to = t; }
            DateTime toExclusive = to.Date.AddDays(1);

            var kpi = new KpiSummary { DailyTrend = new List<DailyPoint>() };

            using (var db = new DataBaseDataContext())
            {
                var bills = db.Ar_Billings
                    .Where(b => b.Bill_Date >= from
                             && b.Bill_Date < toExclusive
                             && (b.isCancel == false || b.isCancel == null)
                             && (b.IsPharmacy == false || b.IsPharmacy == null))
                    .Select(b => new { b.Patient_ID, b.Opd_Id, b.Bill_Date })
                    .ToList();

                var regCreated = db.Reg_patients
                    .Select(r => new { r.pat_id, r.Created_time })
                    .ToDictionary(x => x.pat_id, x => x.Created_time);

                var opdIds = bills
                    .Where(b => b.Opd_Id != null && b.Patient_ID != null)
                    .Select(b => (int)b.Patient_ID)
                    .Distinct()
                    .ToList();

                int opdNew = 0, opdRepeat = 0;
                foreach (var id in opdIds)
                {
                    if (regCreated.TryGetValue(id, out var created))
                    {
                        if (created >= from) opdNew++;
                        else opdRepeat++;
                    }
                }

                kpi.OpdNew = opdNew;
                kpi.OpdRepeat = opdRepeat;

                kpi.NewRegistrations = db.Reg_patients.Count(r =>
                    r.Created_time >= from && r.Created_time < toExclusive);

                kpi.TotalBills = bills.Count;

                var daily = bills
                    .GroupBy(b => b.Bill_Date.Value.Date)
                    .Select(g => new { Day = g.Key, B = g.Count(), O = g.Count(b => b.Opd_Id != null) })
                    .ToDictionary(x => x.Day, x => new { x.B, x.O });

                int dayCount = (int)(toExclusive - from.Date).TotalDays;
                for (int i = 0; i < dayCount; i++)
                {
                    var d = from.Date.AddDays(i);
                    kpi.DailyTrend.Add(new DailyPoint
                    {
                        Date = d.ToString("MMM dd"),
                        Billings = daily.ContainsKey(d) ? daily[d].B : 0,
                        OPD = daily.ContainsKey(d) ? daily[d].O : 0
                    });
                }
            }

            return new JavaScriptSerializer().Serialize(kpi);
        }
    }
}
