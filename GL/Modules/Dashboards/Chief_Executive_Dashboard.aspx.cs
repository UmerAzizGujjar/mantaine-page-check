using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Dashboards
{
    public partial class Chief_Executive_Dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string GetHospitalRevenue(string period)
        {
            try
            {
                DateTime startDate = DateTime.Today;
                DateTime endDate = DateTime.Today.AddDays(1).AddTicks(-1);
                DateTime now = DateTime.Now;
                switch (period.ToLower())
                {
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
                    default:
                        startDate = DateTime.Today;
                        endDate = DateTime.Today.AddDays(1).AddTicks(-1);
                        break;
                }

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    decimal patientSum = (from p in db.Patients
                                          where p.Created_Time >= startDate && p.Created_Time <= endDate
                                          select (decimal?)p.Receipt_Amount).Sum() ?? 0;

                    decimal billingSum = (from b in db.Ar_Billings
                                          where b.Creation_Date >= startDate && b.Creation_Date <= endDate
                                          select (decimal?)b.Received_Amount).Sum() ?? 0;

                    decimal totalRevenue = patientSum + billingSum;

                    return new JavaScriptSerializer().Serialize(new
                    {
                        TotalHospitalRevenue = totalRevenue,
                        DateRange = startDate.ToString("MMM dd, yyyy") + " - " + DateTime.Now.ToString("MMM dd, yyyy")
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod]
        public static string GetOPDSaleRevenue(string period)
        {
            try
            {
                DateTime startDate = DateTime.Today;
                DateTime endDate = DateTime.Now;
                DateTime now = DateTime.Now;

                switch (period.ToLower())
                {
                    case "week":
                        int diff = (7 + (now.DayOfWeek - DayOfWeek.Monday)) % 7;
                        startDate = now.AddDays(-1 * diff).Date;
                        break;
                    case "month":
                        startDate = new DateTime(now.Year, now.Month, 1);
                        break;
                    case "year":
                        startDate = new DateTime(now.Year, 1, 1);
                        break;
                    default:
                        startDate = DateTime.Today;
                        endDate = DateTime.Today.AddDays(1).AddTicks(-1);
                        break;
                }

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    decimal opdRevenue = (from p in db.Patients
                                          where p.Created_Time >= startDate && p.Created_Time <= endDate
                                          select (decimal?)p.Receipt_Amount).Sum() ?? 0;

                    return new JavaScriptSerializer().Serialize(new
                    {
                        OPDRevenue = opdRevenue,
                        DateRange = startDate.ToString("MMM dd, yyyy") + " - " + DateTime.Now.ToString("MMM dd, yyyy")
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod]
        public static string GetPharmacyRevenue(string period)
        {
            try
            {
                DateTime startDate = DateTime.Today;
                DateTime endDate = DateTime.Now;
                DateTime now = DateTime.Now;

                switch (period.ToLower())
                {
                    case "week":
                        int diff = (7 + (now.DayOfWeek - DayOfWeek.Monday)) % 7;
                        startDate = now.AddDays(-1 * diff).Date;
                        break;
                    case "month":
                        startDate = new DateTime(now.Year, now.Month, 1);
                        break;
                    case "year":
                        startDate = new DateTime(now.Year, 1, 1);
                        break;
                    default:
                        startDate = DateTime.Today;
                        endDate = DateTime.Today.AddDays(1).AddTicks(-1);
                        break;
                }

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    decimal pharmacySum = (from b in db.Ar_Billings
                                           where b.Creation_Date >= startDate &&
                                                 b.Creation_Date <= endDate &&
                                                 b.IsPharmacy == true 
                                           select (decimal?)b.Received_Amount).Sum() ?? 0;

                    return new JavaScriptSerializer().Serialize(new
                    {
                        PharmacyRevenue = pharmacySum,
                        DateRange = startDate.ToString("MMM dd, yyyy") + " - " + DateTime.Now.ToString("MMM dd, yyyy")
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod]
        public static string GetLabRadiologyRevenue(string period)
        {
            try
            {
                DateTime startDate = DateTime.Today;
                DateTime endDate = DateTime.Now;
                DateTime now = DateTime.Now;

                switch (period.ToLower())
                {
                    case "week":
                        int diff = (7 + (now.DayOfWeek - DayOfWeek.Monday)) % 7;
                        startDate = now.AddDays(-1 * diff).Date;
                        break;
                    case "month":
                        startDate = new DateTime(now.Year, now.Month, 1);
                        break;
                    case "year":
                        startDate = new DateTime(now.Year, 1, 1);
                        break;
                    default:
                        startDate = DateTime.Today;
                        endDate = DateTime.Today.AddDays(1).AddTicks(-1);
                        break;
                }

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    string[] deptCodes = { "001", "002", "003", "008", "005" };

                    var labSum = (from b in db.Ar_Billings
                                  where b.Creation_Date >= startDate && b.Creation_Date <= endDate
                                  where db.Ar_Billing_Details.Any(d => d.Bill_ID == b.Bill_ID && deptCodes.Contains(d.Test_Main_Department))
                                  select (decimal?)b.Received_Amount).Sum() ?? 0;

                    return new JavaScriptSerializer().Serialize(new
                    {
                        LabRevenue = labSum,
                        DateRange = startDate.ToString("MMM dd, yyyy") + " - " + DateTime.Now.ToString("MMM dd, yyyy")
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod]
        public static string GetOPDChartData(string period)
        {
            try
            {
                DateTime startDate = DateTime.Today;
                DateTime endDate = DateTime.Now;
                DateTime now = DateTime.Now;

                switch (period.ToLower())
                {
                    case "week":
                        int diff = (7 + (now.DayOfWeek - DayOfWeek.Monday)) % 7;
                        startDate = now.AddDays(-1 * diff).Date;
                        break;
                    case "month":
                        startDate = new DateTime(now.Year, now.Month, 1);
                        break;
                    case "year":
                        startDate = new DateTime(now.Year, 1, 1);
                        break;
                    default:
                        startDate = DateTime.Today;
                        endDate = DateTime.Today.AddDays(1).AddTicks(-1);
                        break;
                }

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var visitsInPeriod = db.Patients
                        .Where(p => p.Created_Time >= startDate && p.Created_Time <= endDate && p.Reg_PatId != null)
                        .Select(p => new { p.Reg_PatId, p.Created_Time })
                        .ToList();

                    int newOPD = visitsInPeriod
                        .GroupBy(p => p.Reg_PatId)
                        .Count(g => !db.Patients.Any(prev => prev.Reg_PatId == g.Key && prev.Created_Time < startDate));
                    int totalPatients = visitsInPeriod.Count;
                    int revisitOPD = totalPatients - newOPD;

                    return new JavaScriptSerializer().Serialize(new
                    {
                        TotalPatients = totalPatients,
                        NewOPD = newOPD,
                        RevisitOPD = revisitOPD
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod]
        public static string GetOPDVolumeData(string period)
        {
            try
            {
                DateTime startDate = DateTime.Today;
                DateTime endDate = DateTime.Now;
                DateTime now = DateTime.Now;

                switch (period.ToLower())
                {
                    case "week":
                        int diff = (7 + (now.DayOfWeek - DayOfWeek.Monday)) % 7;
                        startDate = now.AddDays(-1 * diff).Date;
                        break;
                    case "month":
                        startDate = new DateTime(now.Year, now.Month, 1);
                        break;
                    case "year":
                        startDate = new DateTime(now.Year, 1, 1);
                        break;
                    default:
                        startDate = DateTime.Today;
                        endDate = DateTime.Today.AddDays(1).AddTicks(-1);
                        break;
                }

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var patients = db.Patients
                        .Where(p => p.Created_Time >= startDate && p.Created_Time <= endDate)
                        .Select(p => p.Patient_Type)
                        .ToList();

                    int total = patients.Count;
                    int generalCount = patients.Count(t => t == "01");
                    int privateCount = patients.Count(t => t == "02");

                    double generalPerc = total > 0 ? ((double)generalCount / total) * 100 : 0;
                    double privatePerc = total > 0 ? ((double)privateCount / total) * 100 : 0;

                    return new JavaScriptSerializer().Serialize(new
                    {
                        Total = total,
                        GeneralCount = generalCount,
                        GeneralPerc = generalPerc,
                        PrivateCount = privateCount,
                        PrivatePerc = privatePerc
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod]
        public static string GetWaitTimeAndSnapshot(string period)
        {
            try
            {
                DateTime startDate = DateTime.Today;
                DateTime endDate = DateTime.Now;
                DateTime now = DateTime.Now;


                switch (period.ToLower())
                {
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
                    default: 
                        startDate = DateTime.Today;
                        endDate = DateTime.Today.AddDays(1).AddTicks(-1);
                        break;
                }

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var patientsInPeriod = (from p in db.Patients
                                            join opd in db.Out_Patients on p.Patient_ID equals opd.Patient_ID into opdJoin
                                            from opd in opdJoin.DefaultIfEmpty()
                                            where p.Created_Time >= startDate && p.Created_Time <= endDate
                                            select new
                                            {
                                                p.Patient_ID,
                                                p.Patient_Type,
                                                p.Created_Time, 
                                                OutPatientID = opd != null ? (int?)opd.Out_Patient_ID : null,
                                                DischargeDate = opd != null ? opd.discharge_date : null,
                                                OpdCreatedTime = opd != null ? (DateTime?)opd.Created_Time : null
                                            }).ToList();

                    List<double> generalMinutes = new List<double>();
                    List<double> privateMinutes = new List<double>();

                    foreach (var item in patientsInPeriod)
                    {
                        DateTime? effectiveEndTime;

                        if (item.DischargeDate.HasValue)
                        {
                            effectiveEndTime = item.DischargeDate.Value;
                        }
                        else if (item.OutPatientID.HasValue)
                        {
                            string outPatientIdStr = item.OutPatientID.Value.ToString();

                            var labTime = db.Laboratory_Tests.Where(lt => lt.Patient_ID == item.OutPatientID).Max(lt => (DateTime?)lt.Created_Time);
                            var medTime = db.In_Patient_Medicines.Where(m => m.Patient_ID == item.OutPatientID).Max(m => (DateTime?)m.Medicine_Date);
                            var svcTime = db.InPatientServices.Where(s => s.Ou_Patient_Id == outPatientIdStr).Max(s => (DateTime?)s.CreatedDate);

                            DateTime?[] times = { labTime, medTime, svcTime, item.OpdCreatedTime };

                            effectiveEndTime = times.Max() ?? item.Created_Time;
                        }
                        else
                        {
                            effectiveEndTime = item.Created_Time;
                        }

                        double totalMinutes = ((TimeSpan)(effectiveEndTime.Value - item.Created_Time)).TotalMinutes;

                        if (totalMinutes < 0) totalMinutes = 0;

                        if (item.Patient_Type == "01") generalMinutes.Add(totalMinutes);
                        else if (item.Patient_Type == "02") privateMinutes.Add(totalMinutes);
                    }

                    var billingDetailsInPeriod = from master in db.Ar_Billings
                                                 join detail in db.Ar_Billing_Details on master.Bill_ID equals detail.Bill_ID
                                                 where master.Creation_Date >= startDate && master.Creation_Date <= endDate
                                                 select detail;

                    int diagCount = billingDetailsInPeriod.Count(d => d.Test_Main_Department == "001");
                    int physioCount = billingDetailsInPeriod.Count(d => d.Test_Main_Department == "005");

                    return new JavaScriptSerializer().Serialize(new
                    {
                        AvgGeneral = generalMinutes.Any() ? Math.Round(generalMinutes.Average()) : 0,
                        AvgPrivate = privateMinutes.Any() ? Math.Round(privateMinutes.Average()) : 0,
                        DiagCount = diagCount,
                        PhysioCount = physioCount
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = "Server Error: " + ex.Message });
            }
        }

        [WebMethod]
        public static string GetBillingSnapshot(string period)
        {
            try
            {
                DateTime startDate = DateTime.Today;
                DateTime endDate = DateTime.Now;
                DateTime now = DateTime.Now;

                switch (period.ToLower())
                {
                    case "week":
                        int diff = (7 + (now.DayOfWeek - DayOfWeek.Monday)) % 7;
                        startDate = now.AddDays(-1 * diff).Date;
                        break;
                    case "month":
                        startDate = new DateTime(now.Year, now.Month, 1);
                        break;
                    case "year":
                        startDate = new DateTime(now.Year, 1, 1);
                        break;
                    default:
                        startDate = DateTime.Today;
                        endDate = DateTime.Today.AddDays(1).AddTicks(-1);
                        break;
                }

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var billingData = from master in db.Ar_Billings
                                      join detail in db.Ar_Billing_Details on master.Bill_ID equals detail.Bill_ID
                                      where master.Creation_Date >= startDate && master.Creation_Date <= endDate
                                      select detail;

                    return new JavaScriptSerializer().Serialize(new
                    {
                        LabCount = billingData.Count(d => d.Test_Main_Department == "001"),
                        UltrasoundCount = billingData.Count(d => d.Test_Main_Department == "002"),
                        XRayCount = billingData.Count(d => d.Test_Main_Department == "003"),
                        CardioCount = billingData.Count(d => d.Test_Main_Department == "008"),
                        PhysioCount = billingData.Count(d => d.Test_Main_Department == "005")
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod]
        public static string GetPharmacySnapshot(string period)
        {
            try
            {
                DateTime startDate = DateTime.Today;
                DateTime endDate = DateTime.Now;
                DateTime now = DateTime.Now;

                switch (period.ToLower())
                {
                    case "week":
                        int diff = (7 + (now.DayOfWeek - DayOfWeek.Monday)) % 7;
                        startDate = now.AddDays(-1 * diff).Date;
                        break;
                    case "month":
                        startDate = new DateTime(now.Year, now.Month, 1);
                        break;
                    case "year":
                        startDate = new DateTime(now.Year, 1, 1);
                        break;
                    default:
                        startDate = DateTime.Today;
                        endDate = DateTime.Today.AddDays(1).AddTicks(-1);
                        break;
                }

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var pharmacyBills = from bill in db.Ar_Billings
                                        where bill.IsPharmacy == true
                                        && bill.Creation_Date >= startDate
                                        && bill.Creation_Date <= endDate
                                        select bill;

                    return new JavaScriptSerializer().Serialize(new
                    {
                        HospitalCount = pharmacyBills.Count(b => b.Patient_ID > 0),
                        WalkinCount = pharmacyBills.Count(b => b.Patient_ID == 0 || b.Patient_ID == null),
                        Total = pharmacyBills.Count()
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod]
        public static string GetDialysisSnapshot(string period)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    DateTime startDate = DateTime.Today;
                    DateTime endDate = DateTime.Now;
                    DateTime now = DateTime.Now;


                    switch (period.ToLower())
                    {
                        case "week":
                            int diff = (7 + (now.DayOfWeek - DayOfWeek.Monday)) % 7;
                            startDate = now.AddDays(-1 * diff).Date;
                            break;
                        case "month":
                            startDate = new DateTime(now.Year, now.Month, 1);
                            break;
                        case "year":
                            startDate = new DateTime(now.Year, 1, 1);
                            break;
                        default:
                            startDate = DateTime.Today;
                            endDate = DateTime.Today.AddDays(1).AddTicks(-1);
                            break;
                    }

                    var registrations = db.Patients.Where(p =>
                        p.Patient_Main_Category == "042" &&
                        p.Entry_Date >= startDate &&
                        p.Entry_Date <= endDate
                    ).ToList();

                    var regIds = registrations.Select(p => p.Reg_PatId).ToList();
                    var sessions = db.Out_Patients.Where(op =>
                        regIds.Contains(op.Reg_PatId) &&
                        op.Created_Time >= startDate &&
                        op.Created_Time <= endDate
                    ).ToList();

                    int performedCount = registrations.Count;

                    int activeCount = registrations.Count(r => {
                        var session = sessions.OrderByDescending(s => s.Created_Time)
                                              .FirstOrDefault(s => s.Reg_PatId == r.Reg_PatId);

                        return session == null || (session.Discharge != true);
                    });

                    return new JavaScriptSerializer().Serialize(new
                    {
                        ActiveSessions = activeCount,
                        PerformedToday = performedCount,
                        ActiveNow = activeCount 
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod]
        public static string GetRegionalHeatmap(string period)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    DateTime startDate = DateTime.Today;
                    DateTime endDate = DateTime.Now;
                    DateTime now = DateTime.Now;

                    switch (period.ToLower())
                    {
                        case "week":
                            int diff = (7 + (now.DayOfWeek - DayOfWeek.Monday)) % 7;
                            startDate = now.AddDays(-1 * diff).Date;
                            break;
                        case "month":
                            startDate = new DateTime(now.Year, now.Month, 1);
                            break;
                        case "year":
                            startDate = new DateTime(now.Year, 1, 1);
                            break;
                        case "today":
                        default:
                            startDate = DateTime.Today;
                            endDate = DateTime.Today.AddDays(1).AddTicks(-1);
                            break;
                    }


                    var heatmapData = (from rg in db.Reg_patients
                                       join p in db.Patients on rg.pat_id equals p.Reg_PatId
                                       where p.Created_Time >= startDate && p.Created_Time <= endDate
                                       group rg by rg.val_area into g
                                       select new
                                       {
                                           AreaName = g.Key,
                                           Counts = g.Count()
                                       })
                                       .Where(x => x.Counts > 0)
                                       .OrderByDescending(x => x.Counts)
                                       .Take(10)
                                       .ToList();

                    return new JavaScriptSerializer().Serialize(heatmapData);
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }


    }
}