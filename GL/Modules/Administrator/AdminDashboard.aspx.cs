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
                    decimal specialistGross = (from p in db.Patients
                                               join rp in db.Reg_patients on p.Reg_PatId equals rp.pat_id
                                               where rp.Created_time >= s && rp.Created_time <= e
                                                  && p.Patient_Type == "02"
                                               select (decimal?)p.Receipt_Amount).Sum() ?? 0;

                    decimal diagnosticsGross = (from b in db.Ar_Billings
                                                 where b.Creation_Date >= s && b.Creation_Date <= e
                                                    && (b.IsPharmacy == null || b.IsPharmacy == false)
                                                    && b.Main_Department != "01"
                                                 select (decimal?)b.Received_Amount).Sum() ?? 0;

                    decimal pharmacyGross = (from b in db.Ar_Billings
                                              where b.Creation_Date >= s && b.Creation_Date <= e
                                                 && b.IsPharmacy == true
                                              select (decimal?)b.Received_Amount).Sum() ?? 0;

                    var data = new[]
                    {
                        new { category = "Specialist Consultation", grossAmount = (int)specialistGross, discount = (int)(specialistGross * 0.04m), refund = (int)(specialistGross * 0.02m), netCollection = (int)(specialistGross * 0.94m) },
                        new { category = "Diagnostics & Labs", grossAmount = (int)diagnosticsGross, discount = (int)(diagnosticsGross * 0.03m), refund = (int)(diagnosticsGross * 0.015m), netCollection = (int)(diagnosticsGross * 0.955m) },
                        new { category = "Pharmacy Dispensing", grossAmount = (int)pharmacyGross, discount = (int)(pharmacyGross * 0.04m), refund = 0, netCollection = (int)(pharmacyGross * 0.96m) }
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
        public static string GetPharmacyAnalytics(string startDate, string endDate, string department, string doctor)
        {
            try
            {
                DateTime s = ParseDate(startDate, DateTime.Today);
                DateTime e = ParseDate(endDate, DateTime.Today).Date.AddDays(1).AddTicks(-1);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var walkIn = db.Ar_Billings.Where(b => b.Creation_Date >= s && b.Creation_Date <= e && b.IsPharmacy == true && (b.Opd_Id == null || b.Opd_Id == 0)).ToList();
                    var hospital = db.Ar_Billings.Where(b => b.Creation_Date >= s && b.Creation_Date <= e && b.IsPharmacy == true && b.Opd_Id != null && b.Opd_Id != 0).ToList();

                    int wCount = walkIn.Count();
                    int hCount = hospital.Count();
                    int totalPh = wCount + hCount;

                    var data = new[]
                    {
                        new { customerType = "Walk-in", ordered = wCount, netAmount = (int)walkIn.Sum(b => (decimal?)b.Received_Amount ?? 0), percent = totalPh > 0 ? Math.Round((double)wCount / totalPh * 100, 2) : 0 },
                        new { customerType = "Hospital-Patient", ordered = hCount, netAmount = (int)hospital.Sum(b => (decimal?)b.Received_Amount ?? 0), percent = totalPh > 0 ? Math.Round((double)hCount / totalPh * 100, 2) : 0 }
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
                    var billIds = db.Ar_Billings
                        .Where(b => b.Creation_Date >= s && b.Creation_Date <= e)
                        .Select(b => b.Bill_ID).ToList();

                    var details = db.Ar_Billing_Details
                        .Where(d => d.Item_Type == "Test" || d.Item_Type == "test")
                        .ToList()
                        .Where(d => d.Bill_ID != null && billIds.Contains(d.Bill_ID.Value))
                        .ToList();

                    var billDetailIds = new HashSet<long>(details.Select(d => (long)d.Bill_Details_ID));

                    var billDetailList = billDetailIds.ToList();
                    var performedIds = new HashSet<long>(
                        db.Lab_Test_Details
                            .Where(lt => lt.Is_Result == true && lt.BillDetailID != null && billDetailList.Contains(lt.BillDetailID.Value))
                            .Select(lt => lt.BillDetailID.Value)
                            .Distinct()
                    );

                    var deptCodes = details.Select(d => d.Test_Main_Department).Distinct().ToList();
                    var deptNames = deptCodes.ToDictionary(c => c, c => db.GetDataValueName("Main Test Departments", c) ?? c);

                    var grouped = details
                        .GroupBy(d => d.Test_Main_Department ?? "Other")
                        .Select(g => new
                        {
                            departmentName = deptNames.ContainsKey(g.Key) ? deptNames[g.Key] : g.Key,
                            ordered = g.Count(),
                            performed = g.Count(d => d.Bill_Details_ID != null && performedIds.Contains((long)d.Bill_Details_ID)),
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
                DateTime lookback = s.AddDays(-7);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var allPats = db.Patients
                        .Where(p => p.Created_Time >= lookback && p.Created_Time < e && p.Reg_PatId != null)
                        .OrderBy(p => p.Created_Time)
                        .ToList();

                    var visitsByPat = allPats
                        .Where(p => p.Reg_PatId != null)
                        .GroupBy(p => p.Reg_PatId.Value)
                        .ToDictionary(g => g.Key, g => g.OrderBy(p => p.Created_Time).Select(p => p.Created_Time).ToList());

                    var periodPats = allPats.Where(p => p.Created_Time >= s).ToList();

                    var weeklyData = periodPats
                        .Where(p => p.Created_Time != null)
                        .GroupBy(p => new { year = p.Created_Time.Value.Year, month = p.Created_Time.Value.Month, week = (p.Created_Time.Value.Day - 1) / 7 + 1 })
                        .OrderBy(g => g.Key.year).ThenBy(g => g.Key.month).ThenBy(g => g.Key.week)
                        .Select(g =>
                        {
                            int newC = 0, retC = 0;
                            foreach (var pat in g)
                                {
                                    int rpid = pat.Reg_PatId.Value;
                                    var patTime = pat.Created_Time.Value;
                                    var dates = visitsByPat[rpid];
                                    bool hasPrior7d = dates.Any(d => d >= patTime.AddDays(-7) && d < patTime);
                                    if (hasPrior7d) retC++;
                                    else newC++;
                                }
                            return new { weekLabel = "W" + g.Key.week, newPatients = newC, returning = retC };
                        })
                        .Take(8).ToList();

                    if (weeklyData.Count == 0)
                        return new JavaScriptSerializer().Serialize(new { success = true, data = new[] { new { week = "W1", newPatients = 0, returning = 0 } } });

                    var data = weeklyData.Select(x => new { week = x.weekLabel, newPatients = x.newPatients, returning = x.returning }).ToList();
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
            var data = new[]
            {
                new { range = "<5", count = 1819 },
                new { range = "5-10", count = 3336 },
                new { range = "16-30", count = 2245 },
                new { range = "31-60", count = 1481 },
                new { range = "61-120", count = 816 },
                new { range = ">120", count = 452 }
            };
            return new JavaScriptSerializer().Serialize(new { success = true, data });
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
                    int male = (from p in db.Patients
                                join rp in db.Reg_patients on p.Reg_PatId equals rp.pat_id
                                where rp.Created_time >= s && rp.Created_time <= e && rp.Gender == "Male"
                                select p).Count();

                    int female = (from p in db.Patients
                                  join rp in db.Reg_patients on p.Reg_PatId equals rp.pat_id
                                  where rp.Created_time >= s && rp.Created_time <= e && rp.Gender == "Female"
                                  select p).Count();

                    var data = new
                    {
                        male = new { patients = male, avgTime = 32.5 },
                        female = new { patients = female, avgTime = 28.7 }
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
            var data = new[]
            {
                new { hour = "08:00", value = 445 },
                new { hour = "10:00", value = 820 },
                new { hour = "12:00", value = 1140 },
                new { hour = "14:00", value = 780 },
                new { hour = "16:00", value = 590 },
                new { hour = "18:00", value = 360 }
            };
            return new JavaScriptSerializer().Serialize(new { success = true, data });
        }

        [WebMethod(EnableSession = false)]
        public static string GetTATData(string startDate, string endDate, string department, string doctor)
        {
            var data = new[]
            {
                new { time = "00:00", lab = 45 },
                new { time = "04:00", lab = 30 },
                new { time = "08:00", lab = 90 },
                new { time = "12:00", lab = 120 },
                new { time = "16:00", lab = 80 },
                new { time = "20:00", lab = 50 }
            };
            return new JavaScriptSerializer().Serialize(new { success = true, data });
        }

        [WebMethod(EnableSession = false)]
        public static string GetPatientWaitTime(string startDate, string endDate, string department, string doctor)
        {
            var data = new[]
            {
                new { range = "0-1", value = 840 },
                new { range = "1-5", value = 2520 },
                new { range = "5-12", value = 1210 },
                new { range = "13-18", value = 2700 },
                new { range = "19-30", value = 1820 },
                new { range = "31-45", value = 1950 },
                new { range = "46-60", value = 2100 }
            };
            return new JavaScriptSerializer().Serialize(new { success = true, data });
        }

        [WebMethod(EnableSession = false)]
        public static string GetAgeGroupData(string startDate, string endDate, string department, string doctor)
        {
            var data = new[]
            {
                new { range = "0-1", value = 840 },
                new { range = "1-5", value = 2520 },
                new { range = "5-12", value = 1210 },
                new { range = "13-18", value = 2700 },
                new { range = "19-30", value = 1820 },
                new { range = "31-45", value = 1950 },
                new { range = "46-60", value = 2100 }
            };
            return new JavaScriptSerializer().Serialize(new { success = true, data });
        }

        [WebMethod(EnableSession = false)]
        public static string GetOTUtilization(string startDate, string endDate, string department, string doctor)
        {
            var data = new { utilized = 78, available = 22 };
            return new JavaScriptSerializer().Serialize(new { success = true, data });
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
                    var deptData = (from p in db.Patients
                                    join rp in db.Reg_patients on p.Reg_PatId equals rp.pat_id
                                    join emp in db.HR_Employees on p.Doctor_ID equals emp.Emp_ID.ToString()
                                    where rp.Created_time >= s && rp.Created_time <= e && emp.Department != null
                                    group p by emp.Department into g
                                    select new
                                    {
                                        name = g.Key,
                                        count = g.Count(),
                                        change = 0,
                                        isUp = true
                                    }).OrderByDescending(x => x.count).ToList();

                    if (deptData.Count == 0)
                    {
                        var empty = new[] { new { name = "No Data", count = 0, change = 0, isUp = true } };
                        return new JavaScriptSerializer().Serialize(new { success = true, data = empty });
                    }

                    return new JavaScriptSerializer().Serialize(new { success = true, data = deptData });
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
