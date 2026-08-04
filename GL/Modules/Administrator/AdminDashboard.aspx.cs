using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
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

        [WebMethod(EnableSession = false)]
        public static string GetKpiData(string startDate, string endDate, string department, string doctor)
        {
            try
            {
                DateTime s = ParseDate(startDate, DateTime.Today);
                DateTime e = ParseDate(endDate, DateTime.Today).Date.AddDays(1).AddTicks(-1);
                DateTime ys = DateTime.Today.AddDays(-1);
                DateTime ye = DateTime.Today.AddTicks(-1);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    Func<DateTime, DateTime, int> getTotalVisited = (ds, de) =>
                    {
                        int p = (from pt in db.Patients join rp in db.Reg_patients on pt.Reg_PatId equals rp.pat_id where rp.Created_time >= ds && rp.Created_time <= de select pt).Count();
                        int em = (from ep in db.Emergency_Patients join rp in db.Reg_patients on ep.Patient_ID equals rp.pat_id where rp.Created_time >= ds && rp.Created_time <= de select ep).Count();
                        int ip = (from i in db.In_Patients join rp in db.Reg_patients on i.Patient_ID equals rp.pat_id where rp.Created_time >= ds && rp.Created_time <= de select i).Count();
                        return p + em + ip;
                    };

                    int totalVisited = getTotalVisited(s, e);
                    int totalVisitedY = getTotalVisited(ys, ye);

                    int walkInVolume = (from b in db.Ar_Billings
                                        where b.Creation_Date >= s && b.Creation_Date <= e
                                           && (b.IsPharmacy == null || b.IsPharmacy == false)
                                           && b.Main_Department == "01" && b.Opd_Id == 0
                                        select b.Patient_ID).Count();
                    int walkInVolumeY = (from b in db.Ar_Billings
                                          where b.Creation_Date >= ys && b.Creation_Date <= ye
                                             && (b.IsPharmacy == null || b.IsPharmacy == false)
                                             && b.Main_Department == "01" && b.Opd_Id == 0
                                          select b.Patient_ID).Count();

                    var todayEnd = s.Date.AddDays(1);
                    var yesterdayEnd = ys.Date.AddDays(1);

                    int totalAppointments = db.Appointment_Forms.Count(a => a.App_Date >= s.Date && a.App_Date < todayEnd);
                    int totalAppointmentsY = db.Appointment_Forms.Count(a => a.App_Date >= ys.Date && a.App_Date < yesterdayEnd);

                    int consultantCheckups = (from p in db.Patients
                                               join rp in db.Reg_patients on p.Reg_PatId equals rp.pat_id
                                               where rp.Created_time >= s && rp.Created_time <= e && p.Patient_Type == "02"
                                               select p).Count();
                    int consultantCheckupsY = (from p in db.Patients
                                                join rp in db.Reg_patients on p.Reg_PatId equals rp.pat_id
                                                where rp.Created_time >= ys && rp.Created_time <= ye && p.Patient_Type == "02"
                                                select p).Count();

                    int cancelledToday = db.Appointment_Forms.Count(a => a.App_Date >= s.Date && a.App_Date < todayEnd && a.IS_CANCEL == true);
                    int cancelledY = db.Appointment_Forms.Count(a => a.App_Date >= ys.Date && a.App_Date < yesterdayEnd && a.IS_CANCEL == true);
                    double cancellationRate = totalAppointments > 0 ? Math.Round((double)cancelledToday / totalAppointments * 100, 1) : 0;
                    double cancellationRateY = totalAppointmentsY > 0 ? Math.Round((double)cancelledY / totalAppointmentsY * 100, 1) : 0;

                    decimal patientReceipts = (from p in db.Patients
                                                join rp in db.Reg_patients on p.Reg_PatId equals rp.pat_id
                                                where rp.Created_time >= s && rp.Created_time <= e
                                                select (decimal?)p.Receipt_Amount).Sum() ?? 0;
                    decimal billingReceived = (from b in db.Ar_Billings where b.Creation_Date >= s && b.Creation_Date <= e select (decimal?)b.Received_Amount).Sum() ?? 0;
                    decimal cardFees = (from rp in db.Reg_patients where rp.Created_time >= s && rp.Created_time <= e select (decimal?)rp.Card_fee).Sum() ?? 0;
                    decimal revenueYield = patientReceipts + billingReceived + cardFees;

                    decimal patientReceiptsY = (from p in db.Patients
                                                 join rp in db.Reg_patients on p.Reg_PatId equals rp.pat_id
                                                 where rp.Created_time >= ys && rp.Created_time <= ye
                                                 select (decimal?)p.Receipt_Amount).Sum() ?? 0;
                    decimal billingReceivedY = (from b in db.Ar_Billings where b.Creation_Date >= ys && b.Creation_Date <= ye select (decimal?)b.Received_Amount).Sum() ?? 0;
                    decimal cardFeesY = (from rp in db.Reg_patients where rp.Created_time >= ys && rp.Created_time <= ye select (decimal?)rp.Card_fee).Sum() ?? 0;
                    decimal revenueYieldY = patientReceiptsY + billingReceivedY + cardFeesY;

                    var data = new
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
                    return new JavaScriptSerializer().Serialize(new { success = true, data });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { success = false, error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetAppointmentFunnel(string startDate, string endDate, string department, string doctor)
        {
            try
            {
                DateTime s = ParseDate(startDate, DateTime.Today).Date;
                DateTime e = s.AddDays(1);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    int visited = db.Appointment_Forms.Count(a => a.App_Date >= s && a.App_Date < e && a.Status == "Visited");
                    int noShow = db.Appointment_Forms.Count(a => a.App_Date >= s && a.App_Date < e && a.Status == "Booked" && a.IS_CANCEL == false);
                    int cancelled = db.Appointment_Forms.Count(a => a.App_Date >= s && a.App_Date < e && a.IS_CANCEL == true);

                    var data = new { visited, noShow, cancelled };
                    return new JavaScriptSerializer().Serialize(new { success = true, data });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { success = false, error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetSpecialistConsultants(string startDate, string endDate, string department, string doctor)
        {
            try
            {
                DateTime s = ParseDate(startDate, DateTime.Today).Date;
                DateTime e = ParseDate(endDate, DateTime.Today).Date.AddDays(1);
                double daySpan = Math.Max(1, (e - s).TotalDays);
                DateTime lastMonthStart = s.AddMonths(-1);
                DateTime lastMonthEnd = s;

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var doctors_ = db.HR_Employees.Where(emp => emp.IsDoctor == true).ToList();

                    var data = doctors_.Select(emp =>
                    {
                        string empId = emp.Emp_ID.ToString();
                        int appointments = db.Appointment_Forms.Count(a => a.App_Date >= s && a.App_Date < e
                            && a.Consultant_ID == empId);
                        int patientsSeen = db.Appointment_Forms.Count(a => a.App_Date >= s && a.App_Date < e
                            && a.Consultant_ID == empId && a.Status == "Visited");
                        double avgPerDay = Math.Round((double)appointments / daySpan, 1);

                        int lastMonth = db.Appointment_Forms.Count(a => a.App_Date >= lastMonthStart && a.App_Date < lastMonthEnd
                            && a.Consultant_ID == empId);
                        int growth = lastMonth > 0 ? (int)Math.Round(((double)appointments - lastMonth) / lastMonth * 100) : 0;

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

                    return new JavaScriptSerializer().Serialize(new { success = true, data });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { success = false, error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetWalkInConsultants(string startDate, string endDate, string department, string doctor)
        {
            try
            {
                DateTime s = ParseDate(startDate, DateTime.Today).Date;
                DateTime e = ParseDate(endDate, DateTime.Today).Date.AddDays(1);
                double daySpan = Math.Max(1, (e - s).TotalDays);
                DateTime lastMonthStart = s.AddMonths(-1);
                DateTime lastMonthEnd = s;

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var doctors_ = db.HR_Employees.Where(emp => emp.IsDoctor == true).ToList();

                    var outPatients = db.Out_Patients.Where(op => op.Doctor_ID != null && op.Doctor_ID != "").ToList();
                    var emergencies = db.Emergency_Patients.Where(ep => ep.Doctor != null && ep.Doctor != "").ToList();
                    var patients = db.Patients.Where(p => p.Created_Time >= s && p.Created_Time < e
                        && (p.filter_clinic == "001" || p.filter_clinic == "002" || p.filter_clinic == "003")).ToList();
                    var patientsLM = db.Patients.Where(p => p.Created_Time >= lastMonthStart && p.Created_Time < lastMonthEnd
                        && (p.filter_clinic == "001" || p.filter_clinic == "002" || p.filter_clinic == "003")).ToList();

                    var outPatientLookup = outPatients.ToLookup(op => op.Doctor_ID);
                    var emergencyLookup = emergencies.ToLookup(ep => ep.Doctor);
                    var patientIds = new HashSet<int>(patients.Select(p => p.Patient_ID));
                    var patientIdsLM = new HashSet<int>(patientsLM.Select(p => p.Patient_ID));

                    var data = doctors_.Select(emp =>
                    {
                        string empId = emp.Emp_ID.ToString();

                        int fromOutPatient = outPatientLookup[empId]
                            .Count(op => op.Patient_ID.HasValue && patientIds.Contains(op.Patient_ID.Value));
                        int fromEmergency = emergencyLookup[empId]
                            .Count(ep => ep.Patient_ID.HasValue && patientIds.Contains(ep.Patient_ID.Value));
                        int patientsSeen = fromOutPatient + fromEmergency;
                        double avgPerDay = Math.Round((double)patientsSeen / daySpan, 1);

                        int lmOP = outPatientLookup[empId]
                            .Count(op => op.Patient_ID.HasValue && patientIdsLM.Contains(op.Patient_ID.Value));
                        int lmEM = emergencyLookup[empId]
                            .Count(ep => ep.Patient_ID.HasValue && patientIdsLM.Contains(ep.Patient_ID.Value));
                        int lastMonth = lmOP + lmEM;
                        int growth = lastMonth > 0 ? (int)Math.Round(((double)patientsSeen - lastMonth) / lastMonth * 100) : 0;

                        return new
                        {
                            name = emp.Emp_Name ?? "Unknown",
                            patientsSeen,
                            avgPerDay,
                            growth
                        };
                    }).OrderByDescending(x => x.patientsSeen).ToList();

                    return new JavaScriptSerializer().Serialize(new { success = true, data });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { success = false, error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetRevenueBreakdown(string startDate, string endDate, string department, string doctor)
        {
            try
            {
                DateTime s = ParseDate(startDate, DateTime.Today);
                DateTime e = ParseDate(endDate, DateTime.Today).Date.AddDays(1).AddTicks(-1);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    // ── Specialist Consultation ──
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

                    // ── Diagnostics & Labs / Pharmacy ──
                    var billIds = db.Ar_Billings
                        .Where(b => b.Creation_Date >= s && b.Creation_Date <= e)
                        .Select(b => b.Bill_ID)
                        .ToList();

                    var details = db.Ar_Billing_Details
                        .Where(d => d.Item_Type == "Test" || d.Item_Type == "Medicine")
                        .ToList()
                        .Where(d => d.Bill_ID != null && billIds.Contains(d.Bill_ID.Value))
                        .ToList();

                    var testDetails = details.Where(d => d.Item_Type == "Test").ToList();
                    var medicineDetails = details.Where(d => d.Item_Type == "Medicine").ToList();

                    decimal diagnosticsGross = testDetails.Sum(d => d.Amount ?? 0);
                    decimal diagnosticsDiscount = testDetails.Sum(d => d.Discount_Amount ?? 0);

                    decimal pharmacyGross = medicineDetails.Sum(d => d.Amount ?? 0);
                    decimal pharmacyDiscount = medicineDetails.Sum(d => d.Discount_Amount ?? 0);

                    // Refunds for diagnostics & pharmacy
                    var testDetailIds = testDetails.Select(d => d.Bill_Details_ID).ToHashSet();
                    var medicineDetailIds = medicineDetails.Select(d => d.Bill_Details_ID).ToHashSet();

                    decimal diagnosticsRefund = 0, pharmacyRefund = 0;
                    if (testDetailIds.Count > 0 || medicineDetailIds.Count > 0)
                    {
                        var activeRefunds = db.Refunds
                            .Where(r => r.Creation_Date >= s && r.Creation_Date <= e
                                     && (r.isCancelled == null || r.isCancelled == false))
                            .Select(r => r.Refund_ID)
                            .ToHashSet();

                        var refundDetails = db.Refund_Detail_Services
                            .Where(rds => rds.Bill_Detail_ID != null
                                       && (rds.isCancelled == null || rds.isCancelled == false))
                            .ToList()
                            .Where(rds => rds.Refund_ID != null && activeRefunds.Contains(rds.Refund_ID.Value))
                            .ToList();

                        foreach (var rds in refundDetails)
                        {
                            decimal amt = (rds.Doctor_Refund ?? 0) + (rds.Hospital_Refund ?? 0);
                            int bdid = rds.Bill_Detail_ID.Value;
                            if (testDetailIds.Contains(bdid)) diagnosticsRefund += amt;
                            else if (medicineDetailIds.Contains(bdid)) pharmacyRefund += amt;
                        }
                    }

                    decimal diagnosticsNet = diagnosticsGross - diagnosticsDiscount - diagnosticsRefund;
                    decimal pharmacyNet = pharmacyGross - pharmacyDiscount - pharmacyRefund;

                    var data = new[]
                    {
                        new { category = "Specialist Consultation", grossAmount = (int)specialistGross, discount = (int)specialistDiscount, refund = (int)specialistRefund, netCollection = (int)specialistNet },
                        new { category = "Diagnostics & Labs", grossAmount = (int)diagnosticsGross, discount = (int)diagnosticsDiscount, refund = (int)diagnosticsRefund, netCollection = (int)diagnosticsNet },
                        new { category = "Pharmacy Dispensing", grossAmount = (int)pharmacyGross, discount = (int)pharmacyDiscount, refund = (int)pharmacyRefund, netCollection = (int)pharmacyNet }
                    };
                    return new JavaScriptSerializer().Serialize(new { success = true, data });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { success = false, error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetPatientBilling(string startDate, string endDate, string department, string doctor)
        {
            try
            {
                DateTime s = ParseDate(startDate, DateTime.Today);
                DateTime e = ParseDate(endDate, DateTime.Today).Date.AddDays(1).AddTicks(-1);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var regs = db.Reg_patients.Where(rp => rp.Created_time >= s && rp.Created_time <= e).ToList();
                    var regPatIds = regs.Select(r => r.pat_id).ToList();

                    var pats = db.Patients.Where(p => p.Reg_PatId != null).ToList().Where(p => regPatIds.Contains(p.Reg_PatId.Value)).ToList();
                    var opds = db.Out_Patients.Where(op => op.Created_Time >= s && op.Created_Time <= e).ToList();

                    var regByPat = regs.ToLookup(r => r.pat_id);
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

                    var data = new[]
                    {
                        new { department = "General Walk-In", registeredPatient = genReg, newPatient = genNew, cardFee = genCardFee, totalAmount = genAmount },
                        new { department = "Consultant/Private", registeredPatient = conReg, newPatient = conNew, cardFee = conCardFee, totalAmount = conAmount }
                    };
                    return new JavaScriptSerializer().Serialize(new { success = true, data });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { success = false, error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetInvestigationSummary(string startDate, string endDate, string department, string doctor)
        {
            try
            {
                DateTime s = ParseDate(startDate, DateTime.Today);
                DateTime e = ParseDate(endDate, DateTime.Today).Date.AddDays(1).AddTicks(-1);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var details = (from b in db.Ar_Billings
                                   join d in db.Ar_Billing_Details on b.Bill_ID equals d.Bill_ID
                                   where b.Creation_Date >= s && b.Creation_Date <= e
                                      && d.Item_Type == "Test"
                                   select d).ToList();

                    var billDetailIds = details.Select(d => (long)d.Bill_Details_ID).ToList();

                    var performedIds = new HashSet<long>(
                        db.Lab_Test_Details
                            .Where(lt => lt.Is_Result == true && lt.BillDetailID != null && billDetailIds.Contains(lt.BillDetailID.Value))
                            .Select(lt => lt.BillDetailID.Value)
                            .Distinct()
                    );

                    var deptCodes = details.Where(d => d.Test_Main_Department != null).Select(d => d.Test_Main_Department).Distinct().ToList();
                    var deptNames = deptCodes.ToDictionary(c => c, c => db.GetDataValueName("Main Test Departments", c) ?? c);

                    var grouped = details
                        .Where(d => d.Test_Main_Department != null)
                        .GroupBy(d => d.Test_Main_Department)
                        .Select(g => new
                        {
                            departmentName = deptNames.ContainsKey(g.Key) ? deptNames[g.Key] : g.Key,
                            ordered = g.Count(),
                            performed = g.Count(d => performedIds.Contains((long)d.Bill_Details_ID)),
                            amount = (int)g.Sum(d => (decimal?)d.Net_Amount ?? 0)
                        })
                        .OrderByDescending(x => x.ordered)
                        .ToList();

                    if (grouped.Count == 0)
                    {
                        var empty = new[] { new { departmentName = "Lab", ordered = 0, performed = 0, amount = 0 } };
                        return new JavaScriptSerializer().Serialize(new { success = true, data = empty });
                    }

                    return new JavaScriptSerializer().Serialize(new { success = true, data = grouped });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { success = false, error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetNewVsFollowUp(string startDate, string endDate, string department, string doctor)
        {
            try
            {
                DateTime s = ParseDate(startDate, DateTime.Today);
                DateTime e = ParseDate(endDate, DateTime.Today).Date.AddDays(1).AddTicks(-1);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
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

                    var data = new System.Collections.Generic.List<object>();
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
                        data.Add(new { week = "W" + w, newPatients = newC, returning = retC });
                    }

                    return new JavaScriptSerializer().Serialize(new { success = true, data });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { success = false, error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetConsultationDistribution(string startDate, string endDate, string department, string doctor)
        {
            try
            {
                DateTime s = ParseDate(startDate, DateTime.Today);
                DateTime e = ParseDate(endDate, DateTime.Today).Date.AddDays(1).AddTicks(-1);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var minutes = new List<double>();
                    using (var cmd = new System.Data.SqlClient.SqlCommand(@"
SELECT DATEDIFF(MINUTE, op.Created_Time, op.discharge_date) AS Mins
FROM Out_Patient op
WHERE op.Created_Time IS NOT NULL AND op.discharge_date IS NOT NULL
  AND op.Created_Time >= @s AND op.Created_Time <= @e
  AND DATEDIFF(MINUTE, op.Created_Time, op.discharge_date) >= 0", new System.Data.SqlClient.SqlConnection(db.Connection.ConnectionString)))
                    {
                        cmd.Parameters.AddWithValue("@s", s);
                        cmd.Parameters.AddWithValue("@e", e);
                        cmd.Connection.Open();
                        using (var r = cmd.ExecuteReader())
                        {
                            while (r.Read()) minutes.Add(Convert.ToDouble(r["Mins"]));
                        }
                    }

                    int lt5 = minutes.Count(m => m < 5);
                    int r5_10 = minutes.Count(m => m >= 5 && m <= 10);
                    int r16_30 = minutes.Count(m => m > 10 && m <= 30);
                    int r31_60 = minutes.Count(m => m > 30 && m <= 60);
                    int r61_120 = minutes.Count(m => m > 60 && m <= 120);
                    int gt120 = minutes.Count(m => m > 120);

                    var data = new[]
                    {
                        new { range = "<5", count = lt5 },
                        new { range = "5-10", count = r5_10 },
                        new { range = "16-30", count = r16_30 },
                        new { range = "31-60", count = r31_60 },
                        new { range = "61-120", count = r61_120 },
                        new { range = ">120", count = gt120 }
                    };
                    return new JavaScriptSerializer().Serialize(new { success = true, data });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { success = false, error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetGenderData(string startDate, string endDate, string department, string doctor)
        {
            try
            {
                DateTime s = ParseDate(startDate, DateTime.Today);
                DateTime e = ParseDate(endDate, DateTime.Today).Date.AddDays(1).AddTicks(-1);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var regPats = (from p in db.Patients
                                   join rp in db.Reg_patients on p.Reg_PatId equals rp.pat_id
                                   where p.Created_Time >= s && p.Created_Time <= e
                                   select rp).Distinct().ToList();

                    int male = regPats.Count(r => r.Gender == "M" || r.Gender == "Male");
                    int female = regPats.Count(r => r.Gender == "F" || r.Gender == "Female");

                    double maleAvg = 0, femaleAvg = 0, maleCnt = 0, femaleCnt = 0;
                    using (var cmd = new System.Data.SqlClient.SqlCommand(@"
SELECT p.Patient_ID, DATEDIFF(MINUTE, op.Created_Time, op.discharge_date) AS Mins
FROM Patients p
INNER JOIN Out_Patient op ON p.Patient_ID = op.Patient_ID
WHERE p.Created_Time >= @s AND p.Created_Time <= @e
  AND op.Created_Time IS NOT NULL AND op.discharge_date IS NOT NULL
  AND DATEDIFF(MINUTE, op.Created_Time, op.discharge_date) >= 0", new System.Data.SqlClient.SqlConnection(db.Connection.ConnectionString)))
                    {
                        cmd.Parameters.AddWithValue("@s", s);
                        cmd.Parameters.AddWithValue("@e", e);
                        cmd.Connection.Open();
                        using (var r = cmd.ExecuteReader())
                        {
                            while (r.Read())
                            {
                                int pid = Convert.ToInt32(r["Patient_ID"]);
                                double mins = Convert.ToDouble(r["Mins"]);
                                var rp = regPats.FirstOrDefault(x => x.pat_id == pid);
                                if (rp == null) continue;
                                if (rp.Gender == "M" || rp.Gender == "Male") { maleAvg += mins; maleCnt++; }
                                else if (rp.Gender == "F" || rp.Gender == "Female") { femaleAvg += mins; femaleCnt++; }
                            }
                        }
                    }
                    maleAvg = maleCnt > 0 ? Math.Round(maleAvg / maleCnt, 1) : 0;
                    femaleAvg = femaleCnt > 0 ? Math.Round(femaleAvg / femaleCnt, 1) : 0;

                    var data = new
                    {
                        male = new { patients = male, avgTime = maleAvg },
                        female = new { patients = female, avgTime = femaleAvg }
                    };
                    return new JavaScriptSerializer().Serialize(new { success = true, data });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { success = false, error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetOPDTrends(string startDate, string endDate, string department, string doctor)
        {
            try
            {
                DateTime s = ParseDate(startDate, DateTime.Today);
                DateTime e = ParseDate(endDate, DateTime.Today).Date.AddDays(1).AddTicks(-1);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var pats = db.Patients.Where(p => p.Created_Time >= s && p.Created_Time <= e).ToList()
                        .Where(p => p.Created_Time != null).Select(p => p.Created_Time.Value.Hour).Where(h => h >= 8 && h <= 18).ToList();

                    var hours = Enumerable.Range(8, 11).Select(h => new { hour = h.ToString("D2") + ":00", value = pats.Count(v => v == h) }).ToList();
                    return new JavaScriptSerializer().Serialize(new { success = true, data = hours });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { success = false, error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetAgeGroupData(string startDate, string endDate, string department, string doctor)
        {
            try
            {
                DateTime s = ParseDate(startDate, DateTime.Today);
                DateTime e = ParseDate(endDate, DateTime.Today).Date.AddDays(1).AddTicks(-1);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var regs = (from p in db.Patients
                                join rp in db.Reg_patients on p.Reg_PatId equals rp.pat_id
                                where p.Created_Time >= s && p.Created_Time <= e
                                select rp).Distinct().ToList();

                    int c0_1 = 0, c1_5 = 0, c5_12 = 0, c13_18 = 0, c19_30 = 0, c31_45 = 0, c46_60 = 0;
                    foreach (var r in regs)
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

                    var data = new[]
                    {
                        new { range = "0-1", value = c0_1 },
                        new { range = "1-5", value = c1_5 },
                        new { range = "5-12", value = c5_12 },
                        new { range = "13-18", value = c13_18 },
                        new { range = "19-30", value = c19_30 },
                        new { range = "31-45", value = c31_45 },
                        new { range = "46-60", value = c46_60 }
                    };
                    return new JavaScriptSerializer().Serialize(new { success = true, data });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { success = false, error = ex.Message });
            }
        }

        [WebMethod(EnableSession = false)]
        public static string GetDepartmentTiles(string startDate, string endDate, string department, string doctor)
        {
            try
            {
                DateTime s = ParseDate(startDate, DateTime.Today);
                DateTime e = ParseDate(endDate, DateTime.Today).Date.AddDays(1).AddTicks(-1);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var prevS = s.AddDays(-(e.Date - s.Date).TotalDays - 1);
                    var prevE = s.AddTicks(-1);

                    var current = db.Patients.Where(p => p.Created_Time >= s && p.Created_Time <= e && p.Patient_Main_Category != null).ToList();
                    var previous = db.Patients.Where(p => p.Created_Time >= prevS && p.Created_Time <= prevE && p.Patient_Main_Category != null).ToList();

                    var curGroup = current.GroupBy(p => p.Patient_Main_Category).ToDictionary(g => g.Key, g => g.Count());
                    var prevGroup = previous.GroupBy(p => p.Patient_Main_Category).ToDictionary(g => g.Key, g => g.Count());

                    var allCodes = curGroup.Keys.Union(prevGroup.Keys).Distinct().ToList();
                    var deptNames = allCodes.ToDictionary(c => c, c => db.GetDataValueName("Patient Main Category", c) ?? c);

                    var data = allCodes.Select(code =>
                    {
                        int cur = curGroup.ContainsKey(code) ? curGroup[code] : 0;
                        int prv = prevGroup.ContainsKey(code) ? prevGroup[code] : 0;
                        int change = prv > 0 ? (int)Math.Round(((double)cur - prv) / prv * 100) : (cur > 0 ? 100 : 0);
                        return new
                        {
                            name = deptNames.ContainsKey(code) ? deptNames[code] : code,
                            count = cur,
                            change = Math.Abs(change),
                            isUp = cur >= prv
                        };
                    }).OrderByDescending(x => x.count).ToList();

                    if (data.Count == 0)
                        data = new[] { new { name = "No Data", count = 0, change = 0, isUp = true } }.ToList();

                    return new JavaScriptSerializer().Serialize(new { success = true, data });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { success = false, error = ex.Message });
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

                    return new JavaScriptSerializer().Serialize(new { success = true, data });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { success = false, error = ex.Message });
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

                    return new JavaScriptSerializer().Serialize(new { success = true, data });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { success = false, error = ex.Message });
            }
        }
    }
}
