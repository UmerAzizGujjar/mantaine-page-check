using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Globalization;
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

        private static void ResolveDates(string period, string startDateStr, string endDateStr, out DateTime startDate, out DateTime endDate)
        {
            DateTime now = DateTime.Now;
            startDate = DateTime.Today;
            endDate = DateTime.Now;

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
                    DateTime ps, pe;
                    if (!string.IsNullOrEmpty(startDateStr) && DateTime.TryParseExact(startDateStr, "dd/MM/yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out ps))
                        startDate = ps;
                    if (!string.IsNullOrEmpty(endDateStr) && DateTime.TryParseExact(endDateStr, "dd/MM/yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out pe))
                        endDate = pe.Date.AddDays(1).AddTicks(-1);
                    break;
                default:
                    startDate = DateTime.Today;
                    endDate = DateTime.Today.AddDays(1).AddTicks(-1);
                    break;
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetHospitalRevenue(string period, string startDate = null, string endDate = null)
        {
            try
            {
                DateTime sDate, eDate;
                ResolveDates(period, startDate, endDate, out sDate, out eDate);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    decimal RegSum = (from p in db.Reg_patients
                                          where p.charge_time >= sDate && p.charge_time <= eDate
                                          select (decimal?)p.Card_fee).Sum() ?? 0;
                    decimal patientSum = (from p in db.Patients
                                          where p.Created_Time >= sDate && p.Created_Time <= eDate
                                          select (decimal?)p.Receipt_Amount).Sum() ?? 0;
                    decimal EMRSum = (from p in db.Emergencies
                                          where p.Created_Time >= sDate && p.Created_Time <= eDate
                                          select (decimal?)p.Receipt_Amount).Sum() ?? 0;

                    decimal billingSum = (from b in db.Ar_Billings
                                          where b.Creation_Date >= sDate && b.Creation_Date <= eDate && (b.IsPharmacy == null || b.IsPharmacy == false)
                                          select (decimal?)b.Received_Amount).Sum() ?? 0;
                    decimal PharSum = (from b in db.Ar_Billings
                                          where b.Creation_Date >= sDate && b.Creation_Date <= eDate && b.IsPharmacy == true && b.Ware_House == "008"
                                       select (decimal?)b.Received_Amount).Sum() ?? 0;

                    decimal totalRevenue = patientSum + billingSum + RegSum + PharSum + EMRSum;

                    return new JavaScriptSerializer().Serialize(new
                    {
                        TotalHospitalRevenue = totalRevenue
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetOPDSaleRevenue(string period, string startDate = null, string endDate = null)
        {
            try
            {
                DateTime sDate, eDate;
                ResolveDates(period, startDate, endDate, out sDate, out eDate);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    decimal opdRevenue = (from p in db.Patients
                                          where p.Created_Time >= sDate && p.Created_Time <= eDate
                                          select (decimal?)p.Receipt_Amount).Sum() ?? 0;

                    return new JavaScriptSerializer().Serialize(new
                    {
                        OPDRevenue = opdRevenue
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetEMRSaleRevenue(string period, string startDate = null, string endDate = null)
        {
            try
            {
                DateTime sDate, eDate;
                ResolveDates(period, startDate, endDate, out sDate, out eDate);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    decimal opdRevenue = (from p in db.Emergencies
                                          where p.Created_Time >= sDate && p.Created_Time <= eDate
                                          select (decimal?)p.Receipt_Amount).Sum() ?? 0;

                    return new JavaScriptSerializer().Serialize(new
                    {
                        OPDRevenue = opdRevenue
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetCardFeeRevenue(string period, string startDate = null, string endDate = null)
        {
            try
            {
                DateTime sDate, eDate;
                ResolveDates(period, startDate, endDate, out sDate, out eDate);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    decimal opdRevenue = (from p in db.Reg_patients
                                          where p.charge_time >= sDate && p.charge_time <= eDate
                                          select (decimal?)p.Card_fee).Sum() ?? 0;

                    return new JavaScriptSerializer().Serialize(new
                    {
                        OPDRevenue = opdRevenue
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetPharmacyRevenue(string period, string startDate = null, string endDate = null)
        {
            try
            {
                DateTime sDate, eDate;
                ResolveDates(period, startDate, endDate, out sDate, out eDate);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    decimal pharmacySum = (from b in db.Ar_Billings
                                           where b.Creation_Date >= sDate &&
                                                 b.Creation_Date <= eDate &&
                                                 b.IsPharmacy == true  &&
                                                 b.Ware_House == "008"
                                           select (decimal?)b.Received_Amount).Sum() ?? 0;

                    return new JavaScriptSerializer().Serialize(new
                    {
                        PharmacyRevenue = pharmacySum
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetPBRevenue(string period, string startDate = null, string endDate = null)
        {
            try
            {
                DateTime sDate, eDate;
                ResolveDates(period, startDate, endDate, out sDate, out eDate);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    decimal pharmacySum = (from b in db.Ar_Billings
                                           where b.Creation_Date >= sDate &&
                                                 b.Creation_Date <= eDate &&
                                                 b.IsPharmacy == true  &&
                                                 b.Ware_House == "009"
                                           select (decimal?)b.Received_Amount).Sum() ?? 0;

                    return new JavaScriptSerializer().Serialize(new
                    {
                        PharmacyRevenue = pharmacySum
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetLabRadiologyRevenue(string period, string startDate = null, string endDate = null)
        {
            try
            {
                DateTime sDate, eDate;
                ResolveDates(period, startDate, endDate, out sDate, out eDate);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    string[] deptCodes = { "001", "002", "003", "008", "005" };

                    var labSum = (from b in db.Ar_Billings
                                  where b.Creation_Date >= sDate && b.Creation_Date <= eDate
                                  where db.Ar_Billing_Details.Any(d => d.Bill_ID == b.Bill_ID && deptCodes.Contains(d.Test_Main_Department))
                                  select (decimal?)b.Received_Amount).Sum() ?? 0;

                    return new JavaScriptSerializer().Serialize(new
                    {
                        LabRevenue = labSum
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetServicesRevenue(string period, string startDate = null, string endDate = null)
        {
            try
            {
                DateTime sDate, eDate;
                ResolveDates(period, startDate, endDate, out sDate, out eDate);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    //string[] deptCodes = { "001", "002", "003", "008", "005" };

                    var labSum = (from b in db.Ar_Billings
                                  where b.Creation_Date >= sDate && b.Creation_Date <= eDate
                                  where db.Ar_Billing_Details.Any(d => d.Bill_ID == b.Bill_ID && d.Item_Type.Contains("Service"))
                                  select (decimal?)b.Received_Amount).Sum() ?? 0;

                    return new JavaScriptSerializer().Serialize(new
                    {
                        LabRevenue = labSum
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetOPDChartData(string period, string startDate = null, string endDate = null)
        {
            try
            {
                DateTime sDate, eDate;
                ResolveDates(period, startDate, endDate, out sDate, out eDate);

                using (var conn = new System.Data.SqlClient.SqlConnection(System.Web.Configuration.WebConfigurationManager.ConnectionStrings["ASPGLConnectionString"].ConnectionString))
                {
                    // Optimized Query: 
                    // 1. Gets all visits in the period and numbers them per patient (PeriodSeq).
                    // 2. LEFT JOINs to a distinct list of patients who visited BEFORE the start date.
                    // 3. Counts as "New" only if it's their 1st visit in the period AND they have no prior history.
                    string query = @"
                SELECT 
                    ISNULL(COUNT(curr.Reg_PatId), 0) AS TotalPatients,
                    ISNULL(SUM(CASE WHEN curr.PeriodSeq = 1 AND prev.Reg_PatId IS NULL THEN 1 ELSE 0 END), 0) AS NewPatients
                FROM (
                    SELECT 
                        Reg_PatId,
                        ROW_NUMBER() OVER(PARTITION BY Reg_PatId ORDER BY Created_Time ASC) as PeriodSeq
                    FROM Patients 
                    WHERE Created_Time >= @s AND Created_Time <= @e
                      AND Reg_PatId IS NOT NULL
                ) curr
                LEFT JOIN (
                    SELECT Reg_PatId
                    FROM Patients
                    WHERE Created_Time < @s
                    GROUP BY Reg_PatId
                ) prev ON curr.Reg_PatId = prev.Reg_PatId";

                    using (var cmd = new System.Data.SqlClient.SqlCommand(query, conn))
                    {
                        cmd.CommandTimeout = 30; // Reduced timeout since this will run in milliseconds

                        cmd.Parameters.AddWithValue("@s", sDate);
                        cmd.Parameters.AddWithValue("@e", eDate);

                        conn.Open();

                        int totalPatients = 0;
                        int newOPD = 0;

                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                totalPatients = Convert.ToInt32(reader["TotalPatients"]);
                                newOPD = Convert.ToInt32(reader["NewPatients"]);
                            }
                        }

                        int revisitOPD = totalPatients - newOPD;

                        return new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(new
                        {
                            TotalPatients = totalPatients,
                            NewOPD = newOPD,
                            RevisitOPD = revisitOPD
                        });
                    }
                }
            }
            catch (Exception ex)
            {
                return new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }
        [WebMethod(EnableSession = false)]
        public static string GetOPDVolumeData(string period, string startDate = null, string endDate = null)
        {
            try
            {
                DateTime sDate, eDate;
                ResolveDates(period, startDate, endDate, out sDate, out eDate);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var typeCounts = db.Patients
                        .Where(p => p.Created_Time >= sDate && p.Created_Time <= eDate)
                        .GroupBy(p => p.Patient_Type)
                        .Select(g => new { Type = g.Key, Count = g.Count() })
                        .ToList();

                    int generalCount = typeCounts.Where(t => t.Type == "01").Select(t => t.Count).FirstOrDefault();
                    int privateCount = typeCounts.Where(t => t.Type == "02").Select(t => t.Count).FirstOrDefault();
                    int total = generalCount + privateCount;

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

        [WebMethod(EnableSession = false)]
        public static string GetWaitTimeAndSnapshot(string period, string startDate = null, string endDate = null)
        {
            try
            {
                DateTime sDate, eDate;
                ResolveDates(period, startDate, endDate, out sDate, out eDate);

                int avgGeneral = 0, avgPrivate = 0, diagCount = 0, physioCount = 0;

                using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(
                    System.Web.Configuration.WebConfigurationManager.ConnectionStrings["ASPGLConnectionString"].ConnectionString))
                {
                    conn.Open();

                    using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(@"
SELECT
    AVG(CASE WHEN p.Patient_Type = '01' THEN DATEDIFF(MINUTE, p.Entry_Date, op.Created_Time) END) AS AvgGeneral,
    AVG(CASE WHEN p.Patient_Type = '02' THEN DATEDIFF(MINUTE, p.Entry_Date, op.Created_Time) END) AS AvgPrivate
FROM Patients p
INNER JOIN Out_Patient op ON p.Patient_ID = op.Patient_ID
WHERE p.Created_Time >= @s AND p.Created_Time <= @e", conn))
                    {
                        cmd.Parameters.AddWithValue("@s", sDate);
                        cmd.Parameters.AddWithValue("@e", eDate);
                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                avgGeneral = reader["AvgGeneral"] != DBNull.Value ? Convert.ToInt32(reader["AvgGeneral"]) : 0;
                                avgPrivate = reader["AvgPrivate"] != DBNull.Value ? Convert.ToInt32(reader["AvgPrivate"]) : 0;
                            }
                        }
                    }

                    using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(@"
SELECT
    COUNT(CASE WHEN d.Test_Main_Department = '001' THEN 1 END) AS DiagCount,
    COUNT(CASE WHEN d.Test_Main_Department = '005' THEN 1 END) AS PhysioCount
FROM Ar_Billings m
INNER JOIN Ar_Billing_Details d ON m.Bill_ID = d.Bill_ID
WHERE m.Creation_Date >= @s AND m.Creation_Date <= @e", conn))
                    {
                        cmd.Parameters.AddWithValue("@s", sDate);
                        cmd.Parameters.AddWithValue("@e", eDate);
                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                diagCount = Convert.ToInt32(reader["DiagCount"]);
                                physioCount = Convert.ToInt32(reader["PhysioCount"]);
                            }
                        }
                    }
                }

                return new JavaScriptSerializer().Serialize(new
                {
                    AvgGeneral = avgGeneral,
                    AvgPrivate = avgPrivate,
                    DiagCount = diagCount,
                    PhysioCount = physioCount
                });
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = "Server Error: " + ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetBillingSnapshot(string period, string startDate = null, string endDate = null)
        {
            try
            {
                DateTime sDate, eDate;
                ResolveDates(period, startDate, endDate, out sDate, out eDate);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var billingData = from master in db.Ar_Billings
                                      join detail in db.Ar_Billing_Details on master.Bill_ID equals detail.Bill_ID
                                      where master.Creation_Date >= sDate && master.Creation_Date <= eDate
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

        [WebMethod(EnableSession = false)]
        public static string GetPharmacySnapshotPB(string period, string startDate = null, string endDate = null)
        {
            try
            {
                DateTime sDate, eDate;
                ResolveDates(period, startDate, endDate, out sDate, out eDate);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var pharmacyBills = from bill in db.Ar_Billings
                                        where bill.IsPharmacy == true
                                        && bill.Creation_Date >= sDate
                                        && bill.Creation_Date <= eDate
                                        && bill.Ware_House == "009"
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

        [WebMethod(EnableSession = false)]
        public static string GetPharmacySnapshot(string period, string startDate = null, string endDate = null)
        {
            try
            {
                DateTime sDate, eDate;
                ResolveDates(period, startDate, endDate, out sDate, out eDate);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var pharmacyBills = from bill in db.Ar_Billings
                                        where bill.IsPharmacy == true
                                        && bill.Creation_Date >= sDate
                                        && bill.Creation_Date <= eDate
                                        && bill.Ware_House == "008"
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

        [WebMethod(EnableSession = false)]
        public static string GetDialysisSnapshot(string period, string startDate = null, string endDate = null)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    DateTime sDate, eDate;
                    ResolveDates(period, startDate, endDate, out sDate, out eDate);

                    var registrations = db.Patients.Where(p =>
                        p.Patient_Main_Category == "042" &&
                        p.Entry_Date >= sDate &&
                        p.Entry_Date <= eDate
                    ).ToList();

                    var regIds = registrations.Select(p => p.Reg_PatId).ToList();
                    var sessions = db.Out_Patients.Where(op =>
                        regIds.Contains(op.Reg_PatId) &&
                        op.Created_Time >= sDate &&
                        op.Created_Time <= eDate
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

        [WebMethod(EnableSession = false)]
        public static string GetRegionalHeatmap(string period, string startDate = null, string endDate = null)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    DateTime sDate, eDate;
                    ResolveDates(period, startDate, endDate, out sDate, out eDate);

                    var groupedData = (from rg in db.Reg_patients
                                       join p in db.Patients on rg.pat_id equals p.Reg_PatId
                                       where p.Created_Time >= sDate && p.Created_Time <= eDate
                                       group rg by rg.val_area into g
                                       select new
                                       {
                                           AreaID = g.Key,
                                           Counts = g.Count()
                                       }).ToList();

                    var heatmapData = groupedData.Select(x => new
                    {
                        AreaName = string.IsNullOrEmpty(x.AreaID)
                                   ? "Not Specified"
                                   : db.GetDataValueName("Area", x.AreaID),
                        Counts = x.Counts
                    })
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

        [WebMethod(EnableSession = false)]
        public static string GetDepartments()
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var departments = (from dv in db.DataValues
                                       join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                       where vs.ValueSet_Name == "Patient Main Category"
                                       select new
                                       {
                                           dv.DataValue_Name,
                                           dv.DataValue_Description
                                       }).ToList();

                    return new JavaScriptSerializer().Serialize(departments);
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetClinicalOutcomes(string period, string department, string startDate = null, string endDate = null)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    DateTime sDate, eDate;
                    ResolveDates(period, startDate, endDate, out sDate, out eDate);

                    var query = db.Emergency_Patients.Where(ep =>
                        ep.Admission_Date >= sDate && ep.Admission_Date <= eDate);

                    if (!string.IsNullOrEmpty(department) && department != "0")
                        query = query.Where(ep => ep.Department == department);

                    var patients = query.ToList();

                    var er = patients.Where(p => p.Department == "01").ToList();
                    var ipd = patients.Where(p => p.Department != "01").ToList();

                    var result = new
                    {
                        ER = new
                        {
                            Discharges = er.Count(p => p.Discharge == true),
                            Deaths = er.Count(p => p.DateOfDeath != null),
                            Referrals = er.Count(p => p.isReferred == true)
                        },
                        IPD = new
                        {
                            Discharges = ipd.Count(p => p.Discharge == true),
                            Deaths = ipd.Count(p => p.DateOfDeath != null),
                            Referrals = ipd.Count(p => p.isReferred == true)
                        }
                    };

                    return new JavaScriptSerializer().Serialize(result);
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetYearlyPharmacySummary(int year, string warehouse = "0")
        {
            try
            {
                var rows = new List<Dictionary<string, object>>();
                using (var conn = new System.Data.SqlClient.SqlConnection(
                    System.Web.Configuration.WebConfigurationManager.ConnectionStrings["ASPGLConnectionString"].ConnectionString))
                {
                    using (var cmd = new System.Data.SqlClient.SqlCommand("dbo.sp_YearlyPharmacySummary", conn))
                    {
                        cmd.CommandType = System.Data.CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@Year", year);
                        cmd.Parameters.AddWithValue("@Warehouse", warehouse ?? "0");
                        conn.Open();
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                var row = new Dictionary<string, object>();
                                for (int i = 0; i < reader.FieldCount; i++)
                                    row[reader.GetName(i)] = reader[i];
                                rows.Add(row);
                            }
                        }
                    }
                }
                return new JavaScriptSerializer().Serialize(rows);
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message + "|" + ex.GetType().Name + "|" + (ex.InnerException?.Message ?? "") });
            }
        }
        

        [WebMethod(EnableSession = false)]
        public static string GetYearlyPharmacySummaryPB(int year, string warehouse = "0")
        {
            try
            {
                var rows = new List<Dictionary<string, object>>();
                using (var conn = new System.Data.SqlClient.SqlConnection(
                    System.Web.Configuration.WebConfigurationManager.ConnectionStrings["ASPGLConnectionString"].ConnectionString))
                {
                    using (var cmd = new System.Data.SqlClient.SqlCommand("dbo.sp_YearlyPharmacySummaryPB", conn))
                    {
                        cmd.CommandType = System.Data.CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@Year", year);
                        cmd.Parameters.AddWithValue("@Warehouse", warehouse ?? "0");
                        conn.Open();
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                var row = new Dictionary<string, object>();
                                for (int i = 0; i < reader.FieldCount; i++)
                                    row[reader.GetName(i)] = reader[i];
                                rows.Add(row);
                            }
                        }
                    }
                }
                return new JavaScriptSerializer().Serialize(rows);
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message + "|" + ex.GetType().Name + "|" + (ex.InnerException?.Message ?? "") });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetYearlyPharmacyRevenue(int year, string warehouse = "0")
        {
            try
            {
                var rows = new List<Dictionary<string, object>>();
                using (var conn = new System.Data.SqlClient.SqlConnection(
                    System.Web.Configuration.WebConfigurationManager.ConnectionStrings["ASPGLConnectionString"].ConnectionString))
                {
                    using (var cmd = new System.Data.SqlClient.SqlCommand("dbo.sp_YearlyPharmacyRevenue", conn))
                    {
                        cmd.CommandType = System.Data.CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@Year", year);
                        cmd.Parameters.AddWithValue("@Warehouse", warehouse ?? "0");
                        conn.Open();
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                var row = new Dictionary<string, object>();
                                for (int i = 0; i < reader.FieldCount; i++)
                                    row[reader.GetName(i)] = reader[i];
                                rows.Add(row);
                            }
                        }
                    }
                }
                return new JavaScriptSerializer().Serialize(rows);
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message + "|" + ex.GetType().Name + "|" + (ex.InnerException?.Message ?? "") });
            }
        }

        [WebMethod]
        public static string GetYearlyInventorySummary(int year, string warehouse = "0")
        {
            try
            {
                var rows = new List<Dictionary<string, object>>();
                using (var conn = new System.Data.SqlClient.SqlConnection(
                    System.Web.Configuration.WebConfigurationManager.ConnectionStrings["ASPGLConnectionString"].ConnectionString))
                {
                    using (var cmd = new System.Data.SqlClient.SqlCommand("dbo.sp_YearlyInventorySummary", conn))
                    {
                        cmd.CommandType = System.Data.CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@Year", year);
                        cmd.Parameters.AddWithValue("@Warehouse", warehouse ?? "0");
                        conn.Open();
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                var row = new Dictionary<string, object>();
                                for (int i = 0; i < reader.FieldCount; i++)
                                    row[reader.GetName(i)] = reader[i];
                                rows.Add(row);
                            }
                        }
                    }
                }
                return new JavaScriptSerializer().Serialize(rows);
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message + "|" + ex.GetType().Name + "|" + (ex.InnerException?.Message ?? "") + "|" + (ex.InnerException?.GetType().Name ?? "") });
            }
        }

        private class ddlListItems
        {
            public string DataValueName;
            public string DataValueDescription;
            public string Type;
        }

        [WebMethod]
        public static string fillWarehouse()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Ware House"
                         select new ddlListItems
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(listItems);
        }

        [WebMethod(EnableSession = false)]
        public static string GetRevenueTrends(string period, string startDate = null, string endDate = null)
        {
            try
            {
                DateTime endPointDate, endPointEnd;

                switch (period.ToLower())
                {
                    case "yesterday":
                        endPointDate = DateTime.Today.AddDays(-1);
                        endPointEnd = endPointDate.AddDays(1).AddTicks(-1);
                        break;
                    case "custom":
                        DateTime pe;
                        if (!string.IsNullOrEmpty(endDate) && DateTime.TryParseExact(endDate, "dd/MM/yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out pe))
                            endPointDate = pe;
                        else
                            endPointDate = DateTime.Today;
                        endPointEnd = endPointDate.AddDays(1).AddTicks(-1);
                        break;
                    default:
                        endPointDate = DateTime.Today;
                        endPointEnd = DateTime.Now;
                        break;
                }

                DateTime endMonthStart = new DateTime(endPointDate.Year, endPointDate.Month, 1);
                DateTime trendStart = endMonthStart.AddMonths(-4);
                DateTime trendEnd = endMonthStart;

                var monthPatients = new Dictionary<string, decimal>();
                var monthCardfee = new Dictionary<string, decimal>();
                var monthEMRPatients = new Dictionary<string, decimal>();
                var monthBillings = new Dictionary<string, decimal>();
                var monthPharmacy = new Dictionary<string, decimal>();
                var monthPB = new Dictionary<string, decimal>();
                var monthLab = new Dictionary<string, decimal>();
                var monthServices = new Dictionary<string, decimal>();

                using (var conn = new System.Data.SqlClient.SqlConnection(
                    System.Web.Configuration.WebConfigurationManager.ConnectionStrings["ASPGLConnectionString"].ConnectionString))
                {
                    conn.Open();

                    using (var cmd = new System.Data.SqlClient.SqlCommand(
                        @"SELECT YEAR(Created_Time) AS Yr, MONTH(Created_Time) AS Mn, ISNULL(SUM(Receipt_Amount), 0) AS val
                          FROM Patients WHERE Created_Time >= @ts AND Created_Time < @te
                          GROUP BY YEAR(Created_Time), MONTH(Created_Time)", conn))
                    {
                        cmd.Parameters.AddWithValue("@ts", trendStart);
                        cmd.Parameters.AddWithValue("@te", trendEnd);
                        using (var r = cmd.ExecuteReader())
                            while (r.Read())
                            {
                                string key = r["Yr"].ToString() + "-" + r["Mn"].ToString().PadLeft(2, '0');
                                monthPatients[key] = (decimal)r["val"];
                            }
                    }

                    using (var cmd = new System.Data.SqlClient.SqlCommand(
                        @"SELECT YEAR(charge_time) AS Yr, MONTH(charge_time) AS Mn, ISNULL(SUM(Card_fee), 0) AS val
                          FROM Reg_patient WHERE charge_time >= @ts AND charge_time < @te
                          GROUP BY YEAR(charge_time), MONTH(charge_time)", conn))
                    {
                        cmd.Parameters.AddWithValue("@ts", trendStart);
                        cmd.Parameters.AddWithValue("@te", trendEnd);
                        using (var r = cmd.ExecuteReader())
                            while (r.Read())
                            {
                                string key = r["Yr"].ToString() + "-" + r["Mn"].ToString().PadLeft(2, '0');
                                monthCardfee[key] = (decimal)r["val"];
                            }
                    }

                    using (var cmd = new System.Data.SqlClient.SqlCommand(
                        @"SELECT YEAR(Created_Time) AS Yr, MONTH(Created_Time) AS Mn, ISNULL(SUM(Receipt_Amount), 0) AS val
                          FROM Emergency WHERE Created_Time >= @ts AND Created_Time < @te
                          GROUP BY YEAR(Created_Time), MONTH(Created_Time)", conn))
                    {
                        cmd.Parameters.AddWithValue("@ts", trendStart);
                        cmd.Parameters.AddWithValue("@te", trendEnd);
                        using (var r = cmd.ExecuteReader())
                            while (r.Read())
                            {
                                string key = r["Yr"].ToString() + "-" + r["Mn"].ToString().PadLeft(2, '0');
                                monthEMRPatients[key] = (decimal)r["val"];
                            }
                    }

                    using (var cmd = new System.Data.SqlClient.SqlCommand(
                        @"SELECT YEAR(Creation_Date) AS Yr, MONTH(Creation_Date) AS Mn, ISNULL(SUM(Received_Amount), 0) AS val
                          FROM Ar_Billings WHERE Creation_Date >= @ts AND Creation_Date < @te
                          GROUP BY YEAR(Creation_Date), MONTH(Creation_Date)", conn))
                    {
                        cmd.Parameters.AddWithValue("@ts", trendStart);
                        cmd.Parameters.AddWithValue("@te", trendEnd);
                        using (var r = cmd.ExecuteReader())
                            while (r.Read())
                            {
                                string key = r["Yr"].ToString() + "-" + r["Mn"].ToString().PadLeft(2, '0');
                                monthBillings[key] = (decimal)r["val"];
                            }
                    }

                    using (var cmd = new System.Data.SqlClient.SqlCommand(
                        @"SELECT YEAR(Creation_Date) AS Yr, MONTH(Creation_Date) AS Mn, ISNULL(SUM(Received_Amount), 0) AS val
                          FROM Ar_Billings WHERE Creation_Date >= @ts AND Creation_Date < @te AND IsPharmacy = 1 and Ware_House = '008'
                          GROUP BY YEAR(Creation_Date), MONTH(Creation_Date)", conn))
                    {
                        cmd.Parameters.AddWithValue("@ts", trendStart);
                        cmd.Parameters.AddWithValue("@te", trendEnd);
                        using (var r = cmd.ExecuteReader())
                            while (r.Read())
                            {
                                string key = r["Yr"].ToString() + "-" + r["Mn"].ToString().PadLeft(2, '0');
                                monthPharmacy[key] = (decimal)r["val"];
                            }
                    }

                    using (var cmd = new System.Data.SqlClient.SqlCommand(
                        @"SELECT YEAR(Creation_Date) AS Yr, MONTH(Creation_Date) AS Mn, ISNULL(SUM(Received_Amount), 0) AS val
                          FROM Ar_Billings WHERE Creation_Date >= @ts AND Creation_Date < @te AND IsPharmacy = 1 and Ware_House = '009'
                          GROUP BY YEAR(Creation_Date), MONTH(Creation_Date)", conn))
                    {
                        cmd.Parameters.AddWithValue("@ts", trendStart);
                        cmd.Parameters.AddWithValue("@te", trendEnd);
                        using (var r = cmd.ExecuteReader())
                            while (r.Read())
                            {
                                string key = r["Yr"].ToString() + "-" + r["Mn"].ToString().PadLeft(2, '0');
                                monthPB[key] = (decimal)r["val"];
                            }
                    }

                    using (var cmd = new System.Data.SqlClient.SqlCommand(
                        @"SELECT YEAR(b.Creation_Date) AS Yr, MONTH(b.Creation_Date) AS Mn, ISNULL(SUM(b.Received_Amount), 0) AS val
                          FROM Ar_Billings b
                          WHERE b.Creation_Date >= @ts AND b.Creation_Date < @te AND EXISTS (
                              SELECT 1 FROM Ar_Billing_Details d
                              WHERE d.Bill_ID = b.Bill_ID AND d.Test_Main_Department IN ('001','002','003','008','005'))
                          GROUP BY YEAR(b.Creation_Date), MONTH(b.Creation_Date)", conn))
                    {
                        cmd.Parameters.AddWithValue("@ts", trendStart);
                        cmd.Parameters.AddWithValue("@te", trendEnd);
                        using (var r = cmd.ExecuteReader())
                            while (r.Read())
                            {
                                string key = r["Yr"].ToString() + "-" + r["Mn"].ToString().PadLeft(2, '0');
                                monthLab[key] = (decimal)r["val"];
                            }
                    }

                    using (var cmd = new System.Data.SqlClient.SqlCommand(
                        @"SELECT YEAR(b.Creation_Date) AS Yr, MONTH(b.Creation_Date) AS Mn, ISNULL(SUM(b.Received_Amount), 0) AS val
                          FROM Ar_Billings b
                          WHERE b.Creation_Date >= @ts AND b.Creation_Date < @te AND EXISTS (
                              SELECT 1 FROM Ar_Billing_Details d
                              WHERE d.Bill_ID = b.Bill_ID AND  d.Item_Type IN ('Service'))
                          GROUP BY YEAR(b.Creation_Date), MONTH(b.Creation_Date)", conn))
                    {
                        cmd.Parameters.AddWithValue("@ts", trendStart);
                        cmd.Parameters.AddWithValue("@te", trendEnd);
                        using (var r = cmd.ExecuteReader())
                            while (r.Read())
                            {
                                string key = r["Yr"].ToString() + "-" + r["Mn"].ToString().PadLeft(2, '0');
                                monthServices[key] = (decimal)r["val"];
                            }
                    }

                    decimal curP = 0, curB = 0, curPh = 0,curPBh = 0,curEMR = 0, curL = 0, curS = 0, curCard =0;

                    using (var cmd = new System.Data.SqlClient.SqlCommand(
                        "SELECT ISNULL(SUM(Receipt_Amount), 0) FROM Patients WHERE Created_Time >= @cs AND Created_Time <= @ce", conn))
                    {
                        cmd.Parameters.AddWithValue("@cs", endMonthStart);
                        cmd.Parameters.AddWithValue("@ce", endPointEnd);
                        curP = (decimal)cmd.ExecuteScalar();
                    }

                    using (var cmd = new System.Data.SqlClient.SqlCommand(
                        "SELECT ISNULL(SUM(Card_fee), 0) FROM Reg_patient WHERE charge_time >= @cs AND charge_time <= @ce", conn))
                    {
                        cmd.Parameters.AddWithValue("@cs", endMonthStart);
                        cmd.Parameters.AddWithValue("@ce", endPointEnd);
                        curCard = (decimal)cmd.ExecuteScalar();
                    }

                    using (var cmd = new System.Data.SqlClient.SqlCommand(
                        "SELECT ISNULL(SUM(Receipt_Amount), 0) FROM Emergency WHERE Created_Time >= @cs AND Created_Time <= @ce", conn))
                    {
                        cmd.Parameters.AddWithValue("@cs", endMonthStart);
                        cmd.Parameters.AddWithValue("@ce", endPointEnd);
                        curEMR = (decimal)cmd.ExecuteScalar();
                    }

                    using (var cmd = new System.Data.SqlClient.SqlCommand(
                        "SELECT ISNULL(SUM(Received_Amount), 0) FROM Ar_Billings WHERE Creation_Date >= @cs AND Creation_Date <= @ce", conn))
                    {
                        cmd.Parameters.AddWithValue("@cs", endMonthStart);
                        cmd.Parameters.AddWithValue("@ce", endPointEnd);
                        curB = (decimal)cmd.ExecuteScalar();
                    }

                    using (var cmd = new System.Data.SqlClient.SqlCommand(
                        "SELECT ISNULL(SUM(Received_Amount), 0) FROM Ar_Billings WHERE Creation_Date >= @cs AND Creation_Date <= @ce AND IsPharmacy = 1 and Ware_House = '008'", conn))
                    {
                        cmd.Parameters.AddWithValue("@cs", endMonthStart);
                        cmd.Parameters.AddWithValue("@ce", endPointEnd);
                        curPh = (decimal)cmd.ExecuteScalar();
                    }

                    using (var cmd = new System.Data.SqlClient.SqlCommand(
                        "SELECT ISNULL(SUM(Received_Amount), 0) FROM Ar_Billings WHERE Creation_Date >= @cs AND Creation_Date <= @ce AND IsPharmacy = 1 and Ware_House = '009'", conn))
                    {
                        cmd.Parameters.AddWithValue("@cs", endMonthStart);
                        cmd.Parameters.AddWithValue("@ce", endPointEnd);
                        curPh = (decimal)cmd.ExecuteScalar();
                    }

                    using (var cmd = new System.Data.SqlClient.SqlCommand(
                        "SELECT ISNULL(SUM(Received_Amount), 0) FROM Ar_Billings WHERE Creation_Date >= @cs AND Creation_Date <= @ce AND IsPharmacy = 1", conn))
                    {
                        cmd.Parameters.AddWithValue("@cs", endMonthStart);
                        cmd.Parameters.AddWithValue("@ce", endPointEnd);
                        curPBh = (decimal)cmd.ExecuteScalar();
                    }

                    using (var cmd = new System.Data.SqlClient.SqlCommand(
                        @"SELECT ISNULL(SUM(b.Received_Amount), 0)
                          FROM Ar_Billings b
                          WHERE b.Creation_Date >= @cs AND b.Creation_Date <= @ce AND EXISTS (
                              SELECT 1 FROM Ar_Billing_Details d
                              WHERE d.Bill_ID = b.Bill_ID AND d.Test_Main_Department IN ('001','002','003','008','005'))", conn))
                    {
                        cmd.Parameters.AddWithValue("@cs", endMonthStart);
                        cmd.Parameters.AddWithValue("@ce", endPointEnd);
                        curL = (decimal)cmd.ExecuteScalar();
                    }

                    using (var cmd = new System.Data.SqlClient.SqlCommand(
                        @"SELECT ISNULL(SUM(b.Received_Amount), 0)
                          FROM Ar_Billings b
                          WHERE b.Creation_Date >= @cs AND b.Creation_Date <= @ce AND EXISTS (
                              SELECT 1 FROM Ar_Billing_Details d
                              WHERE d.Bill_ID = b.Bill_ID AND  d.Item_Type IN ('Service'))", conn))
                    {
                        cmd.Parameters.AddWithValue("@cs", endMonthStart);
                        cmd.Parameters.AddWithValue("@ce", endPointEnd);
                        curS = (decimal)cmd.ExecuteScalar();
                    }

                    string[] shortMonths = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" };
                    var labels = new List<string>();
                    var hospital = new List<decimal>();
                    var opd = new List<decimal>();
                    var EMR = new List<decimal>();
                    var card = new List<decimal>();
                    var pharmacy = new List<decimal>();
                    var PB = new List<decimal>();
                    var lab = new List<decimal>();
                    var Services = new List<decimal>();

                    for (var d = trendStart; d < trendEnd; d = d.AddMonths(1))
                    {
                        string key = d.Year.ToString() + "-" + d.Month.ToString().PadLeft(2, '0');
                        decimal pv = monthPatients.ContainsKey(key) ? monthPatients[key] : 0;
                        decimal bv = monthBillings.ContainsKey(key) ? monthBillings[key] : 0;
                        labels.Add(shortMonths[d.Month - 1]);
                        hospital.Add(pv + bv);
                        opd.Add(pv);
                        pharmacy.Add(monthPharmacy.ContainsKey(key) ? monthPharmacy[key] : 0);
                        EMR.Add(monthEMRPatients.ContainsKey(key) ? monthEMRPatients[key] : 0);
                        card.Add(monthCardfee.ContainsKey(key) ? monthCardfee[key] : 0);
                        PB.Add(monthPB.ContainsKey(key) ? monthPB[key] : 0);
                        lab.Add(monthLab.ContainsKey(key) ? monthLab[key] : 0);
                        Services.Add(monthServices.ContainsKey(key) ? monthServices[key] : 0);
                    }

                    labels.Add(shortMonths[endPointDate.Month - 1]);
                    hospital.Add(curP + curB);
                    opd.Add(curP);
                    EMR.Add(curEMR);
                    card.Add(curCard);
                    pharmacy.Add(curPh);
                    PB.Add(curPBh);
                    lab.Add(curL);
                    Services.Add(curS);

                    return new JavaScriptSerializer().Serialize(new
                    {
                        labels = labels,
                        hospital = hospital,
                        opd = opd,
                        EMR = EMR,
                        card = card,
                        pharmacy = pharmacy,
                        PB = PB,
                        lab = lab,
                        Services = Services
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetOPDDepartmentWise(string txt_sdate, string txt_edate)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var result = db.sp_OPDDepartmentWise(txt_sdate, txt_edate).ToList();
                    return new JavaScriptSerializer().Serialize(result);
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetDoctorWise(string txt_sdate, string txt_edate)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var result = db.sp_GetDoctorCountForCEODashboard(txt_sdate, txt_edate).ToList();
                    return new JavaScriptSerializer().Serialize(result);
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }
    }
}