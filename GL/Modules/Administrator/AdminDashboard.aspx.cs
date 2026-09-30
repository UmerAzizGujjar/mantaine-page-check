using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;

namespace PMS.Modules.Administrator
{
    public partial class AdminDashboard : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        private static DateTime ParseDate(string dateStr, DateTime fallback)
        {
            DateTime d;
            if (!string.IsNullOrEmpty(dateStr) && DateTime.TryParseExact(dateStr, "dd/MM/yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out d))
                return d;
            return fallback;
        }

        private static string ToJson(object o)
        {
            return new JavaScriptSerializer().Serialize(o);
        }

        private static int ToInt(object v) { return v == null || v == DBNull.Value ? 0 : Convert.ToInt32(v); }
        private static decimal ToDecimal(object v) { return v == null || v == DBNull.Value ? 0m : Convert.ToDecimal(v); }
        private static double ToDouble(object v) { return v == null || v == DBNull.Value ? 0d : Convert.ToDouble(v); }

        // Creates a raw SqlCommand with a generous timeout (avoids default 30s timeouts under load).
        private static SqlCommand NoLockCmd(string sql, string connStr)
        {
            var cmd = new SqlCommand(sql, new SqlConnection(connStr));
            cmd.CommandTimeout = 120;
            return cmd;
        }

        // Opens the connection in READ UNCOMMITTED so dashboard reads never block on the live system's writes.
        private static void OpenNoLock(SqlCommand cmd)
        {
            cmd.Connection.Open();
            using (var iso = new SqlCommand("SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED", cmd.Connection))
                iso.ExecuteNonQuery();
        }

        // Prepares a LINQ DataContext: higher timeout + READ UNCOMMITTED connection.
        private static void PrepDb(DataBaseDataContext db)
        {
            db.CommandTimeout = 120;
            var conn = db.Connection;
            if (conn.State != System.Data.ConnectionState.Open)
                conn.Open();
            using (var iso = new SqlCommand("SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED", (SqlConnection)conn))
                iso.ExecuteNonQuery();
        }

        // Closes the DataContext's manually-opened connection (DataContext.Dispose does NOT close one it didn't open).
        private static void CloseDb(DataBaseDataContext db)
        {
            try
            {
                if (db.Connection != null && db.Connection.State == System.Data.ConnectionState.Open)
                    db.Connection.Close();
            }
            catch { }
        }

        // Runs a raw aggregate SQL that takes @s/@e and returns grouped rows:
        //  row[0] = group key (string), row[1..n] = the selected value columns.
        private static List<KeyValuePair<string, object[]>> SqlGroup(string sql, string connStr, DateTime s, DateTime e)
        {
            var result = new List<KeyValuePair<string, object[]>>();
            using (var cmd = NoLockCmd(sql, connStr))
            {
                cmd.Parameters.AddWithValue("@s", s);
                cmd.Parameters.AddWithValue("@e", e);
                OpenNoLock(cmd);
                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        var vals = new object[r.FieldCount];
                        r.GetValues(vals);
                        result.Add(new KeyValuePair<string, object[]>(Convert.ToString(vals[0]), vals.Skip(1).ToArray()));
                    }
                }
            }
            return result;
        }

        // Runs a raw SQL that takes @s/@e and returns the first row's values.
        private static object[] SqlRow(string sql, string connStr, DateTime s, DateTime e)
        {
            using (var cmd = NoLockCmd(sql, connStr))
            {
                cmd.Parameters.AddWithValue("@s", s);
                cmd.Parameters.AddWithValue("@e", e);
                OpenNoLock(cmd);
                using (var r = cmd.ExecuteReader())
                {
                    var vals = new object[r.FieldCount];
                    if (r.Read()) r.GetValues(vals);
                    return vals;
                }
            }
        }

        // Loads the code->description map for a ValueSet in ONE query (replaces N calls to GetDataValueName).
        private static Dictionary<string, string> LoadValueNames(DataBaseDataContext db, string valueSetName)
        {
            var map = new Dictionary<string, string>();
            int? vsId = db.ValueSets
                .Where(vs => vs.ValueSet_Name == valueSetName)
                .Select(vs => (int?)vs.ValueSet_ID)
                .FirstOrDefault();
            if (vsId == null) return map;

            foreach (var dv in db.DataValues
                .Where(dv => dv.ValueSet_ID == vsId
                          && (dv.System_Value == null || dv.System_Value == false)
                          && dv.DataValue_Name != null && dv.DataValue_Description != null))
            {
                if (!map.ContainsKey(dv.DataValue_Name))
                    map[dv.DataValue_Name] = dv.DataValue_Description;
            }
            return map;
        }

        [WebMethod(EnableSession = false)]
        public static string GetDashboardData(string startDate, string endDate, string department, string doctor)
        {
            try
            {
                DateTime s = ParseDate(startDate, DateTime.Today).Date;
                DateTime e = ParseDate(endDate, DateTime.Today).Date.AddDays(1).AddTicks(-1);
                DateTime eNext = e.Date.AddDays(1);
                double daySpan = Math.Max(1, (e.Date - s.Date).TotalDays + 1);
                DateTime lastMonthStart = s.AddMonths(-1);
                DateTime lastMonthEnd = s;
                //DateTime ys = DateTime.Today.AddDays(-1);
                //DateTime ye = DateTime.Today.AddTicks(-1);
                DateTime ys = s.AddDays(-1);
                DateTime ye = s.AddTicks(-1);

                string conn;
                using (var db0 = new DataBaseDataContext()) { conn = db0.Connection.ConnectionString; }

                /* ─────────── KPI (1 query for all metrics, both periods) ─────────── */
                var tKpi = Task.Run(() =>
                {
                    object[] row;
                    using (var cmd = NoLockCmd(@"
SELECT
  (SELECT COUNT(*) FROM Patients pt  WHERE pt.Created_Time>=@s1 AND pt.Created_time<=@e1)
   +(SELECT COUNT(*) FROM Emergency_Patient ep  WHERE ep.Created_time>=@s1 AND ep.Created_time<=@e1)
   +(SELECT COUNT(*) FROM In_Patient ipd  WHERE ipd.Created_time>=@s1 AND ipd.Created_time<=@e1) AS TotalVisited,
     (SELECT COUNT(*) FROM Patients pt WHERE pt.Created_time>=@s2 AND pt.Created_time<=@e2)
   +(SELECT COUNT(*) FROM Emergency_Patient ep WHERE ep.Created_time>=@s2 AND ep.Created_time<=@e2)
   +(SELECT COUNT(*) FROM In_Patient ipd WHERE ipd.Created_time>=@s2 AND ipd.Created_time<=@e2) AS TotalVisitedY,
    (SELECT COUNT(*) FROM Patients pt JOIN Reg_patient rp ON pt.Reg_PatId=rp.pat_id WHERE rp.Created_time>=@s1 AND rp.Created_time<=@e1)
   +(SELECT COUNT(*) FROM Emergency_Patient ep JOIN Reg_patient rp ON ep.Patient_ID=rp.pat_id WHERE rp.Created_time>=@s1 AND rp.Created_time<=@e1)
   +(SELECT COUNT(*) FROM In_Patient ip JOIN Reg_patient rp ON ip.Patient_ID=rp.pat_id WHERE rp.Created_time>=@s1 AND rp.Created_time<=@e1) AS WalkIn,
      (SELECT COUNT(*) FROM Patients pt JOIN Reg_patient rp ON pt.Reg_PatId=rp.pat_id WHERE rp.Created_time>=@s2 AND rp.Created_time<=@e2)
   +(SELECT COUNT(*) FROM Emergency_Patient ep JOIN Reg_patient rp ON ep.Patient_ID=rp.pat_id WHERE rp.Created_time>=@s2 AND rp.Created_time<=@e2)
   +(SELECT COUNT(*) FROM In_Patient ip JOIN Reg_patient rp ON ip.Patient_ID=rp.pat_id WHERE rp.Created_time>=@s2 AND rp.Created_time<=@e2) AS WalkInY,
  (SELECT COUNT(*) FROM Appointment_Form WHERE App_Date>=@s1 AND App_Date<@a1) AS Appts,
  (SELECT COUNT(*) FROM Appointment_Form WHERE App_Date>=@s2 AND App_Date<@a2) AS ApptsY,
  (SELECT COUNT(*) FROM Appointment_Form WHERE App_Date>=@s1 AND App_Date<@a1 AND cancelAppointment=1) AS Cancelled,
  (SELECT COUNT(*) FROM Appointment_Form WHERE App_Date>=@s2 AND App_Date<@a2 AND cancelAppointment=1) AS CancelledY,
  (SELECT COUNT(*) FROM Patients p  WHERE p.Created_time>=@s1 AND p.Created_time<=@e1 AND p.Patient_Type='02' And appointment_id is not Null) AS Checkups,
  (SELECT COUNT(*) FROM Patients p  WHERE p.Created_time>=@s2 AND p.Created_time<=@e2 AND p.Patient_Type='02' And appointment_id is not Null) AS CheckupsY,
  (SELECT ISNULL(SUM(p.Receipt_Amount),0) FROM Patients p  WHERE p.Created_time>=@s1 AND p.Created_time<=@e1)
+(Select ISNULL(Sum(ep.Receipt_Amount),0) From Emergency ep where ep.Created_Time >= @s1 AND ep.Created_Time <= @e1)
+(Select ISNULL(Sum(ep.Admission_Fees),0) From In_Patient ep where ep.Created_Time >= @s1 AND ep.Created_Time <= @e1) AS Receipts,
  (SELECT ISNULL(SUM(p.Receipt_Amount),0) FROM Patients p  WHERE p.Created_time>=@s2 AND p.Created_time<=@e2)
+(Select ISNULL(Sum(ep.Receipt_Amount),0) From Emergency ep where ep.Created_Time >= @s2 AND ep.Created_Time <= @e2)
+(Select ISNULL(Sum(ep.Admission_Fees),0) From In_Patient ep where ep.Created_Time >= @s2 AND ep.Created_Time <= @e2) AS ReceiptsY,
  (SELECT ISNULL(SUM(b.Received_Amount),0) FROM Ar_Billings b WHERE b.Creation_Date>=@s1 AND b.Creation_Date<=@e1) AS Billing,
  (SELECT ISNULL(SUM(b.Received_Amount),0) FROM Ar_Billings b WHERE b.Creation_Date>=@s2 AND b.Creation_Date<=@e2) AS BillingY,
  (SELECT ISNULL(SUM(rp.Card_fee),0) FROM Reg_patient rp WHERE rp.charge_time>=@s1 AND rp.charge_time<=@e1) AS CardFees,
  (SELECT ISNULL(SUM(rp.Card_fee),0) FROM Reg_patient rp WHERE rp.charge_time>=@s2 AND rp.charge_time<=@e2) AS CardFeesY", conn))
                    {
                        cmd.Parameters.AddWithValue("@s1", s);
                        cmd.Parameters.AddWithValue("@e1", e);
                        cmd.Parameters.AddWithValue("@s2", ys);
                        cmd.Parameters.AddWithValue("@e2", ye);
                        cmd.Parameters.AddWithValue("@a1", s.AddDays(1));
                        cmd.Parameters.AddWithValue("@a2", ys.AddDays(1));
                        OpenNoLock(cmd);
                        using (var r = cmd.ExecuteReader())
                        {
                            var vals = new object[r.FieldCount];
                            if (r.Read()) r.GetValues(vals);
                            row = vals;
                        }
                    }
                    int totalVisited = row.Length > 0 ? ToInt(row[0]) : 0;
                    int totalVisitedY = row.Length > 1 ? ToInt(row[1]) : 0;
                    int walkInVolume = row.Length > 2 ? ToInt(row[2]) : 0;
                    int walkInVolumeY = row.Length > 3 ? ToInt(row[3]) : 0;
                    int totalAppointments = row.Length > 4 ? ToInt(row[4]) : 0;
                    int totalAppointmentsY = row.Length > 5 ? ToInt(row[5]) : 0;
                    int cancelledToday = row.Length > 6 ? ToInt(row[6]) : 0;
                    int cancelledY = row.Length > 7 ? ToInt(row[7]) : 0;
                    int consultantCheckups = row.Length > 8 ? ToInt(row[8]) : 0;
                    int consultantCheckupsY = row.Length > 9 ? ToInt(row[9]) : 0;
                    decimal patientReceipts = row.Length > 10 ? ToDecimal(row[10]) : 0;
                    decimal patientReceiptsY = row.Length > 11 ? ToDecimal(row[11]) : 0;
                    decimal billingReceived = row.Length > 12 ? ToDecimal(row[12]) : 0;
                    decimal billingReceivedY = row.Length > 13 ? ToDecimal(row[13]) : 0;
                    decimal cardFees = row.Length > 14 ? ToDecimal(row[14]) : 0;
                    decimal cardFeesY = row.Length > 15 ? ToDecimal(row[15]) : 0;

                    decimal revenueYield = patientReceipts  + cardFees;
                    decimal revenueYieldY = patientReceiptsY  + cardFeesY;
                    double cancellationRate = totalAppointments > 0 ? Math.Round((double)cancelledToday / totalAppointments * 100, 1) : 0;
                    double cancellationRateY = totalAppointmentsY > 0 ? Math.Round((double)cancelledY / totalAppointmentsY * 100, 1) : 0;

                    return new
                    {
                        totalVisited = totalVisited.ToString("N0"),
                        walkInVolume = walkInVolume.ToString("N0"),
                        totalAppointments = totalAppointments.ToString("N0"),
                        consultantCheckups = consultantCheckups.ToString("N0"),
                        cancellationRate = cancellationRate.ToString("F1") + "%",
                        revenueYield = "Rs. " + Math.Round(revenueYield / 1000).ToString("N0") + "K",
                        totalVisitedTooltip = "Aggregated throughput for selected filters",
                        walkInTooltip = "Filter Clinic & FRU",
                        appointmentsTooltip = "Consultant bookings",
                        checkupsTooltip = "Specialist throughput",
                        cancellationTooltip = "Missed specialist slots",
                        revenueTooltip = "Estimated collection",
                        todayDiff = totalVisited - totalVisitedY,
                        totalVisitedDiff = totalVisited - totalVisitedY,
                        walkInDiff = walkInVolume - walkInVolumeY,
                        appointmentsDiff = totalAppointments - totalAppointmentsY,
                        checkupsDiff = consultantCheckups - consultantCheckupsY,
                        cancellationDiff = cancellationRateY - cancellationRate,
                        revenueDiff = revenueYield - revenueYieldY
                    };
                });

                /* ─────────── APPOINTMENT FUNNEL (1 query) ─────────── */
                var tFunnel = Task.Run(() =>
                {
                    var row = SqlRow(@"
SELECT
    SUM(CASE WHEN Status = 'Visited' THEN 1 ELSE 0 END) AS Visited,
    SUM(CASE WHEN Status = 'Booked' AND ISNULL(cancelAppointment,0) = 0 THEN 1 ELSE 0 END) AS NoShow,
    SUM(CASE WHEN cancelAppointment = 1 THEN 1 ELSE 0 END) AS Cancelled
FROM Appointment_Form
WHERE App_Date >= @s AND App_Date < @e", conn, s, eNext);
                    return new
                    {
                        visited = row.Length > 0 ? ToInt(row[0]) : 0,
                        noShow = row.Length > 1 ? ToInt(row[1]) : 0,
                        cancelled = row.Length > 2 ? ToInt(row[2]) : 0
                    };
                });

                /* ─────────── SPECIALIST CONSULTANTS (2 GROUP BY queries + doctors) ─────────── */
                var tSpecialist = Task.Run(() =>
                {
                    using (DataBaseDataContext db = new DataBaseDataContext())
                    {
                        PrepDb(db);
                        const string specialistSql = @"
SELECT a.Consultant_ID AS [Key],
       COUNT(*) AS Appts,
       SUM(CASE WHEN a.Status = 'Visited' THEN 1 ELSE 0 END) AS Visited
FROM Appointment_Form a
WHERE a.App_Date >= @s AND a.App_Date < @e AND a.Consultant_ID IS NOT NULL
GROUP BY a.Consultant_ID";

                        DateTime monthStart = new DateTime(s.Year, s.Month, 1);
                        DateTime monthEnd = monthStart.AddMonths(1);

                        var specialistCur = SqlGroup(specialistSql, db.Connection.ConnectionString, s, eNext).ToDictionary(x => x.Key, x => new { appts = ToInt(x.Value[0]), visited = ToInt(x.Value[1]) });
                        var specialistLm = SqlGroup(specialistSql, db.Connection.ConnectionString, lastMonthStart, lastMonthEnd).ToDictionary(x => x.Key, x => ToInt(x.Value[0]));
                        var specialistLC = SqlGroup(specialistSql, db.Connection.ConnectionString, monthStart, monthEnd).ToDictionary(x => x.Key, x => ToInt(x.Value[0]));

                        var doctors_ = db.HR_Employees.Where(emp => emp.IsDoctor == true).ToList();
                        CloseDb(db);
                        return doctors_.Select(emp =>
                        {
                            string empId = emp.Emp_ID.ToString();
                            var cur = specialistCur.ContainsKey(empId) ? specialistCur[empId] : null;
                            int appointments = cur != null ? cur.appts : 0;
                            int patientsSeen = cur != null ? cur.visited : 0;
                            int lastMonth = specialistLm.ContainsKey(empId) ? specialistLm[empId] : 0;
                            int CurrentMonth = specialistLC.ContainsKey(empId) ? specialistLC[empId] : 0;
                            double avgPerDay = Math.Round((double)appointments / daySpan, 1);
                            int growth = lastMonth > 0 ? (int)Math.Round(((double)CurrentMonth - lastMonth) / lastMonth * 100) : 0;
                            return new
                            {
                                name = emp.Emp_Name ?? "Unknown",
                                specialty = emp.Department ?? "General",
                                appointments,
                                patientsSeen,
                                avgPerDay,
                                growth
                            };
                        }).OrderByDescending(x => x.patientsSeen).Take(20).ToList();
                    }
                });

                /* ─────────── WALK-IN CONSULTANTS (4 GROUP BY queries in parallel) ─────────── */
                var tWalkIn = Task.Run(() =>
                {
                    const string walkInOpSql = @"
SELECT op.Doctor_ID AS [Key], COUNT(*) AS Cnt
FROM Patients p
INNER JOIN Out_Patient op ON p.Patient_ID = op.Patient_ID
WHERE p.Created_Time >= @s AND p.Created_Time < @e
  AND (p.filter_clinic = '001' OR p.filter_clinic = '002' OR p.filter_clinic = '003')
  AND op.Doctor_ID IS NOT NULL AND op.Doctor_ID != ''
GROUP BY op.Doctor_ID";
                    const string walkInEmSql = @"
SELECT ep.Doctor AS [Key], COUNT(*) AS Cnt
FROM Patients p
INNER JOIN Emergency_Patient ep ON p.Patient_ID = ep.Patient_ID
WHERE p.Created_Time >= @s AND p.Created_Time < @e
  AND (p.filter_clinic = '001' OR p.filter_clinic = '002' OR p.filter_clinic = '003')
  AND ep.Doctor IS NOT NULL AND ep.Doctor != ''
GROUP BY ep.Doctor";

                    var t1 = Task.Run(() => SqlGroup(walkInOpSql, conn, s, eNext).ToDictionary(x => x.Key, x => ToInt(x.Value[0])));
                    var t2 = Task.Run(() => SqlGroup(walkInEmSql, conn, s, eNext).ToDictionary(x => x.Key, x => ToInt(x.Value[0])));
                    var t3 = Task.Run(() => SqlGroup(walkInOpSql, conn, lastMonthStart, lastMonthEnd).ToDictionary(x => x.Key, x => ToInt(x.Value[0])));
                    var t4 = Task.Run(() => SqlGroup(walkInEmSql, conn, lastMonthStart, lastMonthEnd).ToDictionary(x => x.Key, x => ToInt(x.Value[0])));
                    Task.WaitAll(t1, t2, t3, t4);
                    var opCur = t1.Result; var emCur = t2.Result; var opLm = t3.Result; var emLm = t4.Result;

                    using (DataBaseDataContext db = new DataBaseDataContext())
                    {
                        PrepDb(db);
                        var doctors_ = db.HR_Employees.Where(emp => emp.IsDoctor == true).ToList();
                        CloseDb(db);
                        return doctors_.Select(emp =>
                        {
                            string empId = emp.Emp_ID.ToString();
                            int patientsSeen = (opCur.ContainsKey(empId) ? opCur[empId] : 0) + (emCur.ContainsKey(empId) ? emCur[empId] : 0);
                            double avgPerDay = Math.Round((double)patientsSeen / daySpan, 1);
                            int lastMonth = (opLm.ContainsKey(empId) ? opLm[empId] : 0) + (emLm.ContainsKey(empId) ? emLm[empId] : 0);
                            int growth = lastMonth > 0 ? (int)Math.Round(((double)patientsSeen - lastMonth) / lastMonth * 100) : 0;
                            return new
                            {
                                name = emp.Emp_Name ?? "Unknown",
                                patientsSeen,
                                avgPerDay,
                                growth
                            };
                        }).OrderByDescending(x => x.patientsSeen).ToList();
                    }
                });

                /* ─────────── REVENUE BREAKDOWN ─────────── */
                var tRevenue = Task.Run(() =>
                {
                    using (DataBaseDataContext db = new DataBaseDataContext())
                    {
                        PrepDb(db);
                        var conn2 = db.Connection.ConnectionString;
                        var specialistPatients = db.Patients.Where(p => p.Patient_Type == "02" && p.Created_Time >= s && p.Created_Time <= e).ToList();
                        decimal specialistGross = specialistPatients.Sum(p => p.Actual_amount ?? 0);
                        decimal specialistDiscount = specialistPatients.Sum(p => p.discount_amt ?? 0);
                        var specialistPatList = specialistPatients.Select(p => p.Patient_ID).ToList();

                        decimal specialistRefund = 0;
                        if (specialistPatList.Count > 0)
                        {
                            specialistRefund = db.OPD_Refunds
                                .Where(od => od.Refund_Date >= s && od.Refund_Date <= e
                                          && (od.isCancelled == null || od.isCancelled == false))
                                .ToList()
                                .Where(od => specialistPatList.Contains(od.pat_id))
                                .Sum(od => (od.Hospital_Refund ?? 0) + (od.Doctor_Refund ?? 0));
                        }
                        decimal specialistNet = specialistGross - specialistDiscount - specialistRefund;

                        var grossRow = SqlGroup(@"
SELECT d.Item_Type AS [Key],
       SUM(ISNULL(d.Amount,0)) AS Amt,
       SUM(ISNULL(d.Discount_Amount,0)) AS Disc
FROM Ar_Billings b
INNER JOIN Ar_Billing_Details d ON b.Bill_ID = d.Bill_ID
WHERE b.Creation_Date >= @s AND b.Creation_Date <= @e
  AND (d.Item_Type = 'Test' OR d.Item_Type = 'Medicine')
GROUP BY d.Item_Type", conn2, s, e).ToDictionary(x => x.Key, x => new { amt = ToDecimal(x.Value[0]), disc = ToDecimal(x.Value[1]) });

                        var refundRow = SqlGroup(@"
SELECT d.Item_Type AS [Key],
       SUM(ISNULL(rds.Doctor_Refund,0) + ISNULL(rds.Hospital_Refund,0)) AS Amt
FROM Refund_Detail_Services rds
INNER JOIN Refund r ON r.Refund_ID = rds.Refund_ID
INNER JOIN Ar_Billing_Details d ON d.Bill_Details_ID = rds.Bill_Detail_ID
INNER JOIN Ar_Billings b ON b.Bill_ID = d.Bill_ID
WHERE r.Creation_Date >= @s AND r.Creation_Date <= @e
  AND (r.isCancelled IS NULL OR r.isCancelled = 0)
  AND (rds.isCancelled IS NULL OR rds.isCancelled = 0)
  AND rds.Bill_Detail_ID IS NOT NULL AND rds.Refund_ID IS NOT NULL
  AND (d.Item_Type = 'Test' OR d.Item_Type = 'Medicine')
  AND b.Creation_Date >= @s AND b.Creation_Date <= @e
GROUP BY d.Item_Type", conn2, s, e).ToDictionary(x => x.Key, x => ToDecimal(x.Value[0]));

                        decimal diagnosticsGross = grossRow.ContainsKey("Test") ? grossRow["Test"].amt : 0;
                        decimal diagnosticsDiscount = grossRow.ContainsKey("Test") ? grossRow["Test"].disc : 0;
                        decimal pharmacyGross = grossRow.ContainsKey("Medicine") ? grossRow["Medicine"].amt : 0;
                        decimal pharmacyDiscount = grossRow.ContainsKey("Medicine") ? grossRow["Medicine"].disc : 0;
                        decimal diagnosticsRefund = refundRow.ContainsKey("Test") ? refundRow["Test"] : 0;
                        decimal pharmacyRefund = refundRow.ContainsKey("Medicine") ? refundRow["Medicine"] : 0;
                        decimal diagnosticsNet = diagnosticsGross - diagnosticsDiscount - diagnosticsRefund;
                        decimal pharmacyNet = pharmacyGross - pharmacyDiscount - pharmacyRefund;

                        CloseDb(db);
                        return new[]
                        {
                            new { category = "Specialist Consultation", grossAmount = (int)specialistGross, discount = (int)specialistDiscount, refund = (int)specialistRefund, netCollection = (int)specialistNet },
                            new { category = "Diagnostics & Labs", grossAmount = (int)diagnosticsGross, discount = (int)diagnosticsDiscount, refund = (int)diagnosticsRefund, netCollection = (int)diagnosticsNet },
                            new { category = "Pharmacy Dispensing", grossAmount = (int)pharmacyGross, discount = (int)pharmacyDiscount, refund = (int)pharmacyRefund, netCollection = (int)pharmacyNet }
                        };
                    }
                });

                /* ─────────── PATIENT BILLING ─────────── */
                var tBilling = Task.Run(() =>
                {
                    using (DataBaseDataContext db = new DataBaseDataContext())
                    {
                        PrepDb(db);
                        var regs = db.Reg_patients.Where(rp => rp.Created_time >= s && rp.Created_time <= e).ToList();
                        var regByPat = regs.ToLookup(r => r.pat_id);

                        var pats = (from p in db.Patients
                                    join rp in db.Reg_patients on p.Reg_PatId equals rp.pat_id
                                    where rp.Created_time >= s && rp.Created_time <= e
                                    select p).Distinct().ToList();
                        var opds = db.Out_Patients.Where(op => op.Created_Time >= s && op.Created_Time <= e).ToList();
                        var opdByPat = opds.ToLookup(o => o.Reg_PatId ?? 0);

                        int genNew = 0, genReg = 0, conNew = 0, conReg = 0;
                        int genCardFee = 0, genAmount = 0, conCardFee = 0, conAmount = 0;

                        foreach (var pat in pats)
                        {
                            if (pat.Reg_PatId == null) continue;
                            int rpid = pat.Reg_PatId.Value;
                            string pt = pat.Patient_Type;
                            int opdCount = opdByPat[rpid].Count();
                            int regCount = regByPat[rpid].Count();
                            decimal cardFee = regByPat[rpid].Any() ? (regByPat[rpid].First().Card_fee ?? 0) : 0;
                            decimal amount = pat.Receipt_Amount ?? 0;

                            int isNew = 0;
                            if (regCount == 1 && opdCount == 1) isNew = 1;
                            else if (regCount == 1 && opdCount == 2) { isNew = 1; }

                            if (pt == "01")
                            {
                                if (isNew == 1) genNew++; else genReg++;
                                genCardFee += (int)cardFee;
                                genAmount += (int)amount;
                            }
                            else if (pt == "02")
                            {
                                if (isNew == 1) conNew++; else conReg++;
                                conCardFee += (int)cardFee;
                                conAmount += (int)amount;
                            }
                        }

                        CloseDb(db);
                        return new[]
                        {
                            new { department = "General Walk-In", registeredPatient = genReg, newPatient = genNew, cardFee = genCardFee, totalAmount = genAmount },
                            new { department = "Consultant/Private", registeredPatient = conReg, newPatient = conNew, cardFee = conCardFee, totalAmount = conAmount }
                        };
                    }
                });

                /* ─────────── INVESTIGATION SUMMARY ─────────── */
                var tInvestigation = Task.Run(() =>
                {
                    using (DataBaseDataContext db = new DataBaseDataContext())
                    {
                        PrepDb(db);
                        var conn2 = db.Connection.ConnectionString;
                        var rawInvestigation = new List<object[]>();
                        var performedByDept = new Dictionary<string, int>();
                        using (var cmd = NoLockCmd(@"
SELECT d.Test_Main_Department AS DeptCode,
       COUNT(*) AS OrderedCnt,
       SUM(ISNULL(d.Net_Amount,0)) AS Amt
FROM Ar_Billings b
INNER JOIN Ar_Billing_Details d ON b.Bill_ID = d.Bill_ID
WHERE b.Creation_Date >= @s AND b.Creation_Date <= @e
  AND d.Item_Type = 'Test'
  AND d.Test_Main_Department IS NOT NULL
GROUP BY d.Test_Main_Department", conn2))
                        {
                            cmd.Parameters.AddWithValue("@s", s);
                            cmd.Parameters.AddWithValue("@e", e);
                            OpenNoLock(cmd);
                            using (var r = cmd.ExecuteReader())
                            {
                                while (r.Read())
                                    rawInvestigation.Add(new object[] { r["DeptCode"].ToString(), ToInt(r["OrderedCnt"]), ToInt(r["Amt"]) });
                            }
                        }
                        using (var cmd2 = NoLockCmd(@"
SELECT d.Test_Main_Department AS DeptCode, COUNT(DISTINCT d.Bill_Details_ID) AS PerformedCnt
FROM Ar_Billings b
INNER JOIN Ar_Billing_Details d ON b.Bill_ID = d.Bill_ID
WHERE b.Creation_Date >= @s AND b.Creation_Date <= @e
  AND d.Item_Type = 'Test'
  AND d.Test_Main_Department IS NOT NULL
  AND EXISTS (SELECT 1 FROM Lab_Test_Detail lt WHERE lt.BillDetailID = d.Bill_Details_ID AND lt.Is_Result = 1)
GROUP BY d.Test_Main_Department", conn2))
                        {
                            cmd2.Parameters.AddWithValue("@s", s);
                            cmd2.Parameters.AddWithValue("@e", e);
                            OpenNoLock(cmd2);
                            using (var r = cmd2.ExecuteReader())
                            {
                                while (r.Read())
                                    performedByDept[r["DeptCode"].ToString()] = ToInt(r["PerformedCnt"]);
                            }
                        }
                        var deptNames = LoadValueNames(db, "Main Test Departments");
                        var investigation = rawInvestigation
                            .Select(row => new
                            {
                                departmentName = deptNames.ContainsKey((string)row[0]) ? deptNames[(string)row[0]] : (string)row[0],
                                ordered = (int)row[1],
                                performed = performedByDept.ContainsKey((string)row[0]) ? performedByDept[(string)row[0]] : 0,
                                amount = (int)row[2]
                            })
                            .OrderByDescending(x => x.ordered)
                            .ToList();
                        if (investigation.Count == 0)
                            investigation = new[] { new { departmentName = "Lab", ordered = 0, performed = 0, amount = 0 } }.ToList();
                        CloseDb(db);
                        return investigation;
                    }
                });

                /* ─────────── NEW VS FOLLOW-UP (RETENTION) ─────────── */
                var tRetention = Task.Run(() =>
                {
                    using (DataBaseDataContext db = new DataBaseDataContext())
                    {
                        PrepDb(db);
                        var allPats = db.Patients
                            .Where(p => p.Created_Time >= s.AddDays(-7) && p.Created_Time < e && p.Reg_PatId != null)
                            .OrderBy(p => p.Created_Time)
                            .ToList();

                        var visitsByPat = allPats
                            .Where(p => p.Reg_PatId != null)
                            .GroupBy(p => p.Reg_PatId.Value)
                            .ToDictionary(g => g.Key, g => g.OrderBy(p => p.Created_Time).Select(p => p.Created_Time.Value).ToList());

                        DateTime latestMonth = allPats.Where(p => p.Created_Time >= s)
                            .Select(p => p.Created_Time.Value)
                            .DefaultIfEmpty(e.AddDays(-1))
                            .Max();
                        latestMonth = new DateTime(latestMonth.Year, latestMonth.Month, 1);

                        var retention = new System.Collections.Generic.List<object>();
                        for (int w = 1; w <= 4; w++)
                        {
                            int newC = 0, retC = 0;
                            int wStartDay = (w - 1) * 7 + 1;
                            int wEndDay = Math.Min(w * 7, DateTime.DaysInMonth(latestMonth.Year, latestMonth.Month));
                            DateTime ws = new DateTime(latestMonth.Year, latestMonth.Month, wStartDay);
                            DateTime we = new DateTime(latestMonth.Year, latestMonth.Month, wEndDay).AddDays(1).AddTicks(-1);

                            var weekPats = allPats.Where(p => p.Created_Time >= ws && p.Created_Time <= we).ToList();
                            foreach (var pat in weekPats)
                            {
                                int rpid = pat.Reg_PatId.Value;
                                var patTime = pat.Created_Time.Value;
                                if (visitsByPat.ContainsKey(rpid) && visitsByPat[rpid].Any(d => d >= patTime.AddDays(-7) && d < patTime))
                                    retC++;
                                else
                                    newC++;
                            }
                            retention.Add(new { week = "W" + w, newPatients = newC, returning = retC });
                        }
                        CloseDb(db);
                        return retention;
                    }
                });

                /* ─────────── CONSULTATION DISTRIBUTION ─────────── */
                var tDistribution = Task.Run(() =>
                {
                    var minutes = new List<double>();
                    using (var cmd = NoLockCmd(@"
SELECT DATEDIFF(MINUTE, op.Created_Time, op.discharge_date) AS Mins
FROM Out_Patient op
WHERE op.Created_Time IS NOT NULL AND op.discharge_date IS NOT NULL
  AND op.Created_Time >= @s AND op.Created_Time <= @e
  AND DATEDIFF(MINUTE, op.Created_Time, op.discharge_date) >= 0", conn))
                    {
                        cmd.Parameters.AddWithValue("@s", s);
                        cmd.Parameters.AddWithValue("@e", e);
                        OpenNoLock(cmd);
                        using (var r = cmd.ExecuteReader())
                        {
                            while (r.Read()) minutes.Add(ToDouble(r["Mins"]));
                        }
                    }

                    int lt5 = minutes.Count(m => m < 5);
                    int r5_10 = minutes.Count(m => m >= 5 && m <= 10);
                    int r16_30 = minutes.Count(m => m > 10 && m <= 30);
                    int r31_60 = minutes.Count(m => m > 30 && m <= 60);
                    int r61_120 = minutes.Count(m => m > 60 && m <= 120);
                    int gt120 = minutes.Count(m => m > 120);

                    return new[]
                    {
                        new { range = "<5", count = lt5 },
                        new { range = "5-10", count = r5_10 },
                        new { range = "16-30", count = r16_30 },
                        new { range = "31-60", count = r31_60 },
                        new { range = "61-120", count = r61_120 },
                        new { range = ">120", count = gt120 }
                    };
                });

                /* ─────────── GENDER ─────────── */
                var tGender = Task.Run(() =>
                {
                    using (DataBaseDataContext db = new DataBaseDataContext())
                    {
                        PrepDb(db);
                        var conn2 = db.Connection.ConnectionString;
                        var regPats = (from p in db.Patients
                                       join rp in db.Reg_patients on p.Reg_PatId equals rp.pat_id
                                       where p.Created_Time >= s && p.Created_Time <= e
                                       select rp).Distinct().ToList();

                        int male = regPats.Count(r => r.Gender == "M" || r.Gender == "Male");
                        int female = regPats.Count(r => r.Gender == "F" || r.Gender == "Female");

                        double maleAvg = 0, femaleAvg = 0, maleCnt = 0, femaleCnt = 0;
                        using (var cmd = NoLockCmd(@"
SELECT p.Patient_ID, DATEDIFF(MINUTE, op.Created_Time, op.discharge_date) AS Mins
FROM Patients p
INNER JOIN Out_Patient op ON p.Patient_ID = op.Patient_ID
WHERE p.Created_Time >= @s AND p.Created_Time <= @e
  AND op.Created_Time IS NOT NULL AND op.discharge_date IS NOT NULL
  AND DATEDIFF(MINUTE, op.Created_Time, op.discharge_date) >= 0", conn2))
                        {
                            cmd.Parameters.AddWithValue("@s", s);
                            cmd.Parameters.AddWithValue("@e", e);
                            OpenNoLock(cmd);
                            using (var r = cmd.ExecuteReader())
                            {
                                while (r.Read())
                                {
                                    int pid = ToInt(r["Patient_ID"]);
                                    double mins = ToDouble(r["Mins"]);
                                    var rp = regPats.FirstOrDefault(x => x.pat_id == pid);
                                    if (rp == null) continue;
                                    if (rp.Gender == "M" || rp.Gender == "Male") { maleAvg += mins; maleCnt++; }
                                    else if (rp.Gender == "F" || rp.Gender == "Female") { femaleAvg += mins; femaleCnt++; }
                                }
                            }
                        }
                        maleAvg = maleCnt > 0 ? Math.Round(maleAvg / maleCnt, 1) : 0;
                        femaleAvg = femaleCnt > 0 ? Math.Round(femaleAvg / femaleCnt, 1) : 0;

                        CloseDb(db);
                        return new
                        {
                            male = new { patients = male, avgTime = maleAvg },
                            female = new { patients = female, avgTime = femaleAvg }
                        };
                    }
                });

                /* ─────────── OPD TRENDS (GROUP BY hour in SQL) ─────────── */
                var tOpd = Task.Run(() =>
                {
                    var hourCounts = SqlGroup(@"
SELECT DATEPART(HOUR, p.Created_Time) AS [Key], COUNT(*) AS Cnt
FROM Patients p
WHERE p.Created_Time >= @s AND p.Created_Time <= @e
GROUP BY DATEPART(HOUR, p.Created_Time)", conn, s, e)
                        .ToDictionary(x => x.Key, x => ToInt(x.Value[0]));

                    return Enumerable.Range(8, 11).Select(h =>
                    {
                        string hk = h.ToString();
                        return new { hour = h.ToString("D2") + ":00", value = hourCounts.ContainsKey(hk) ? hourCounts[hk] : 0 };
                    }).ToList();
                });

                /* ─────────── AGE GROUP ─────────── */
                var tAgeGroup = Task.Run(() =>
                {
                    using (DataBaseDataContext db = new DataBaseDataContext())
                    {
                        PrepDb(db);
                        var ageRegs = (from p in db.Patients
                                       join rp in db.Reg_patients on p.Reg_PatId equals rp.pat_id
                                       where p.Created_Time >= s && p.Created_Time <= e
                                       select rp).Distinct().ToList();

                        int c0_1 = 0, c1_5 = 0, c5_12 = 0, c13_18 = 0, c19_30 = 0, c31_45 = 0, c46_60 = 0;
                        foreach (var r in ageRegs)
                        {
                            DateTime dob = r.DOB ?? r.Created_time ?? e.AddYears(-30);
                            int age = e.Year - dob.Year;
                            if (dob > e.AddYears(-age)) age--;
                            if (age <= 1) c0_1++;
                            else if (age <= 5) c1_5++;
                            else if (age <= 12) c5_12++;
                            else if (age <= 18) c13_18++;
                            else if (age <= 30) c19_30++;
                            else if (age <= 45) c31_45++;
                            else if (age <= 60) c46_60++;
                        }

                        CloseDb(db);
                        return new[]
                        {
                            new { range = "0-1", value = c0_1 },
                            new { range = "1-5", value = c1_5 },
                            new { range = "5-12", value = c5_12 },
                            new { range = "13-18", value = c13_18 },
                            new { range = "19-30", value = c19_30 },
                            new { range = "31-45", value = c31_45 },
                            new { range = "46-60", value = c46_60 }
                        };
                    }
                });

                /* ─────────── DEPARTMENT TILES (GROUP BY in SQL) ─────────── */
                var tDeptTiles = Task.Run(() =>
                {
                    using (DataBaseDataContext db = new DataBaseDataContext())
                    {
                        PrepDb(db);
                        var conn2 = db.Connection.ConnectionString;
                        var prevS = s.AddDays(-(e.Date - s.Date).TotalDays - 1);
                        var prevE = s.AddTicks(-1);

                        var curGroup = SqlGroup(@"
SELECT p.Patient_Main_Category AS [Key], COUNT(*) AS Cnt
FROM Patients p
WHERE p.Created_Time >= @s AND p.Created_Time <= @e AND p.Patient_Main_Category IS NOT NULL
GROUP BY p.Patient_Main_Category", conn2, s, e)
                            .ToDictionary(x => x.Key, x => Convert.ToInt32(x.Value[0]));
                        var prevGroup = SqlGroup(@"
SELECT p.Patient_Main_Category AS [Key], COUNT(*) AS Cnt
FROM Patients p
WHERE p.Created_Time >= @s AND p.Created_Time <= @e AND p.Patient_Main_Category IS NOT NULL
GROUP BY p.Patient_Main_Category", conn2, prevS, prevE)
                            .ToDictionary(x => x.Key, x => ToInt(x.Value[0]));

                        var allCodes = curGroup.Keys.Union(prevGroup.Keys).Distinct().ToList();
                        var catNames = LoadValueNames(db, "Patient Main Category");

                        var deptTiles = allCodes.Select(code =>
                        {
                            int cur = curGroup.ContainsKey(code) ? curGroup[code] : 0;
                            int prv = prevGroup.ContainsKey(code) ? prevGroup[code] : 0;
                            int change = prv > 0 ? (int)Math.Round(((double)cur - prv) / prv * 100) : (cur > 0 ? 100 : 0);
                            return new
                            {
                                name = catNames.ContainsKey(code) ? catNames[code] : code,
                                count = cur,
                                change = Math.Abs(change),
                                isUp = cur >= prv
                            };
                        }).OrderByDescending(x => x.count).ToList();

                        if (deptTiles.Count == 0)
                            deptTiles = new[] { new { name = "No Data", count = 0, change = 0, isUp = true } }.ToList();
                        CloseDb(db);
                        return deptTiles;
                    }
                });

                Task.WaitAll(tKpi, tFunnel, tSpecialist, tWalkIn, tRevenue, tBilling, tInvestigation, tRetention, tDistribution, tGender, tOpd, tAgeGroup, tDeptTiles);

                var data = new
                {
                    kpi = tKpi.Result,
                    funnel = tFunnel.Result,
                    specialist = tSpecialist.Result,
                    walkIn = tWalkIn.Result,
                    revenue = tRevenue.Result,
                    billing = tBilling.Result,
                    investigation = tInvestigation.Result,
                    retention = tRetention.Result,
                    distribution = tDistribution.Result,
                    gender = tGender.Result,
                    opdTrends = tOpd.Result,
                    ageGroup = tAgeGroup.Result,
                    deptTiles = tDeptTiles.Result
                };

                return ToJson(new { success = true, data });
            }
            catch (Exception ex)
            {
                return ToJson(new { success = false, error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetDepartments()
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var depts = db.HR_Employees
                                  .Where(e => e.IsDoctor == true && e.Department != null && e.Department != "")
                                  .Select(e => e.Department)
                                  .Distinct()
                                  .OrderBy(d => d)
                                  .ToList();

                    var data = new List<object>();
                    data.Add(new { value = "0", text = "All Departments" });
                    foreach (var d in depts)
                        data.Add(new { value = d, text = d });

                    return ToJson(new { success = true, data });
                }
            }
            catch (Exception ex)
            {
                return ToJson(new { success = false, error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetDoctors(string department)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var query = db.HR_Employees.Where(e => e.IsDoctor == true && e.Emp_Name != null && e.Emp_Name != "");
                    if (!string.IsNullOrEmpty(department) && department != "0")
                        query = query.Where(e => e.Department == department);

                    var doctors = query.OrderBy(e => e.Emp_Name).ToList();

                    var data = new List<object>();
                    data.Add(new { value = "0", text = "All Doctors" });
                    foreach (var d in doctors)
                        data.Add(new { value = d.Emp_Name, text = d.Emp_Name });

                    return ToJson(new { success = true, data });
                }
            }
            catch (Exception ex)
            {
                return ToJson(new { success = false, error = ex.Message });
            }
        }
    }
}
