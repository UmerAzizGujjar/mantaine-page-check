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
    public partial class CEODashboardNew : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string GetYears()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var Dis = (from d in db.DataValues
                       join v in db.ValueSets
                       on d.ValueSet_ID equals v.ValueSet_ID
                       where v.ValueSet_Name == "Years"
                       select new
                       {
                           d.DataValue_Name,
                           d.DataValue_Description
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(Dis));
        }
        [WebMethod]
        public static string GetPatientsCount(string txt_sdate, string txt_edate)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var results = db.ExecuteQuery<PatientCountResult>(
                    "EXEC sp_GetPatientCountsByDate {0}, {1}",
                    txt_sdate, txt_edate
                ).ToList();

                var resultObj = results.FirstOrDefault() ?? new PatientCountResult();
                return new JavaScriptSerializer().Serialize(resultObj);
            }
        }
        [WebMethod]
        public static string GetYearlyInventorySummary(int year)
        {
            string result = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_YearlyInventorySummary(year).ToList();
                result = (new JavaScriptSerializer()).Serialize(query);
            }
            return result;
        }

        [WebMethod]
        public static string GetYearlyPharmacySummary(int year)
        {
            string result = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_YearlyPharmacySummary(year).ToList();
                result = (new JavaScriptSerializer()).Serialize(query);
            }
            return result;
        }

        [WebMethod]
        public static string GetYearlyPharmacyRevenu(int year)
        {
            string result = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_YearlyPharmacyRevenue(year).ToList();
                result = (new JavaScriptSerializer()).Serialize(query);
            }
            return result;
        }
        public class PatientCountResult
        {
            public int TotalPatients { get; set; }
            public int NewOPD { get; set; }
            public int RevisitOPD { get; set; }
        }

        [WebMethod]
        public static string GetEmergencyCounts(string txt_sdate, string txt_edate)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_GetEmergencyCountsByDate(txt_sdate, txt_edate).FirstOrDefault();
                return new JavaScriptSerializer().Serialize(query);
            }
        }

        [WebMethod]
        public static string GetIPDAdmitDischarge(string txt_sdate, string txt_edate)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_GetIPDAdmitDischargeByDate(txt_sdate, txt_edate).FirstOrDefault();
                return new JavaScriptSerializer().Serialize(query);
            }
        }

        [WebMethod]
        public static string GetTotalIPDAdmitted()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = db.sp_GetTotalIPDAdmitted().FirstOrDefault();
                return new JavaScriptSerializer().Serialize(result);
            }
        }

        [WebMethod]
        public static string GetAppointmentsOPDCount(string txt_sdate, string txt_edate)
        {
            try
            {
                DateTime startDate = DateTime.Parse(txt_sdate);
                DateTime endDate = DateTime.Parse(txt_edate);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var appointmentsInRange = db.Appointment_Forms
                        .Where(a => a.App_Date >= startDate && a.App_Date <= endDate && a.Reg_id.HasValue)
                        .ToList();

                    if (!appointmentsInRange.Any())
                    {
                        return new JavaScriptSerializer().Serialize(new
                        {
                            NewAppointments = 0,
                            Revisits = 0
                        });
                    }

                    var regIds = appointmentsInRange.Select(a => a.Reg_id.Value).ToList();

                    var firstAppointmentPerPatient = db.Appointment_Forms
                        .Where(a => regIds.Contains(a.Reg_id.Value))
                        .GroupBy(a => a.Reg_id.Value)
                        .Select(g => new
                        {
                            Reg_id = g.Key,
                            FirstAppointmentID = g.Min(x => x.Appointment_ID)
                        })
                        .ToDictionary(x => x.Reg_id, x => x.FirstAppointmentID);

                    int newCount = 0;
                    int revisitCount = 0;

                    foreach (var appt in appointmentsInRange)
                    {
                        if (appt.Reg_id.HasValue &&
                            firstAppointmentPerPatient.TryGetValue(appt.Reg_id.Value, out int firstID))
                        {
                            if (appt.Appointment_ID == firstID)
                            {
                                newCount++;
                            }
                            else
                            {
                                revisitCount++;
                            }
                        }
                        else
                        {
                            newCount++;
                        }
                    }

                    return new JavaScriptSerializer().Serialize(new
                    {
                        NewAppointments = newCount,
                        Revisits = revisitCount
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message });
            }
        }

        [WebMethod]
        public static string GetFootfallCount(string txt_sdate, string txt_edate)
        {
            string result = string.Empty;

            try
            {
                DateTime startDate = DateTime.Parse(txt_sdate).Date; // 2025-08-28 00:00:00
                DateTime endDate = DateTime.Parse(txt_edate).Date.AddDays(1).AddTicks(-1);
                // 2025-08-28 23:59:59.9999999


                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    // Single query: join Patients with Reg_patients and filter by date
                    int count = (from p in db.Patients
                                 join rp in db.Reg_patients
                                    on p.Reg_PatId equals rp.pat_id
                                 where rp.Created_time >= startDate &&
                                       rp.Created_time <= endDate
                                 select p).Count();

                    result = (new JavaScriptSerializer())
                                .Serialize(new { FootfallCount = count });
                }
            }
            catch (Exception ex)
            {
                result = (new JavaScriptSerializer())
                            .Serialize(new { Error = ex.Message });
            }

            return result;
        }


        [WebMethod]
        public static string GetAreaWisePatientsCount(string txt_sdate, string txt_edate)
        {
            string result = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_AreaWisePatientCount(txt_sdate, txt_edate).ToList();
                result = (new JavaScriptSerializer()).Serialize(query);
            }
            return result;
        }
        [WebMethod]
        public static string GetTodayPatientsCount()
        {
            string result = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_GetTodayPatientCounts().FirstOrDefault();
                result = (new JavaScriptSerializer()).Serialize(query);
            }
            return result;
        }
        [WebMethod]
        public static string GetDialysisPatientsCount(string txt_sdate, string txt_edate)
        {
            string result = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_GetDialysisPatientCounts(txt_sdate, txt_edate).FirstOrDefault();
                result = (new JavaScriptSerializer()).Serialize(query);
            }
            return result;
        }
        [WebMethod]
        public static string GetProcdureCount(string txt_sdate, string txt_edate)
        {
            string result = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_GetProcedureCounts(txt_sdate, txt_edate).ToList();
                result = (new JavaScriptSerializer()).Serialize(query);
            }
            return result;
        }
        

        [WebMethod]
        public static string GetPharmacyCount(string txt_sdate, string txt_edate)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_GetPharmacyCounts(txt_sdate, txt_edate).ToList();

                var normalizedData = query.Select(r => new {
                    CustomerType = r.CustomerType,  
                    TotalCount = r.TotalCount,
                    TotalReceivedAmount = r.TotalReceivedAmount
                }).ToList();

                var totalCount = normalizedData.Sum(x => x.TotalCount);
                var totalAmount = normalizedData.Sum(x => x.TotalReceivedAmount);

                normalizedData.Add(new
                {
                    CustomerType = "Total",
                    TotalCount = totalCount,
                    TotalReceivedAmount = totalAmount
                });

                return new JavaScriptSerializer().Serialize(normalizedData);
            }
        }


        [WebMethod]
        public static string GetInvestigationCount(string txt_sdate, string txt_edate)
        {
            string result = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_GetInvestigationCounts(txt_sdate, txt_edate).ToList();

                decimal? totalNetAmount = query.Sum(x => x.TotalBillAmount);
                decimal? totalDiscount = query.Sum(x => x.TotalDiscount);
                decimal? totalAmount = totalNetAmount + totalDiscount;

                var totalRow = new
                {
                    Department = "Total",
                    TotalBillCount = query.Sum(x => x.TotalBillCount ?? 0),
                    TotalPerformCount = query.Sum(x => x.TotalPerformCount ?? 0),
                    TotalDiscount = query.Sum(x => x.TotalDiscount),
                    TotalBillAmount = totalNetAmount,
                    TotalAmount = totalAmount
                };

                var resultList = query.Cast<object>().ToList();
                resultList.Add(totalRow);

                result = (new JavaScriptSerializer()).Serialize(resultList);
            }
            return result;
        }
        [WebMethod]
        public static string GetReferCount(string txt_sdate, string txt_edate)
        {
            string result = string.Empty;
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var query = db.sp_GetReferCount(DateTime.Parse(txt_sdate), DateTime.Parse(txt_edate)).FirstOrDefault();

                    if (query != null)
                    {
                        int totalCount = query.TotalCount.GetValueOrDefault();
                        int referCount = query.ReferCount.GetValueOrDefault();

                        double percentage = 0;
                        if (totalCount > 0)
                            percentage = (referCount * 100.0) / totalCount;

                        var data = new
                        {
                            ReferCount = referCount,
                            TotalCount = totalCount,
                            Percentage = Math.Round(percentage, 2)
                        };

                        result = new JavaScriptSerializer().Serialize(data);
                    }
                    else
                    {
                        result = "{\"error\":\"No data found.\"}";
                    }
                }
            }
            catch (Exception ex)
            {
                result = "{\"error\":\"" + ex.Message + "\"}";
            }

            return result;
        }











        [WebMethod]
        public static string GetTop5TestsByDepartment(string txt_sdate, string txt_edate)
        {
            string result = string.Empty;
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var query = db.sp_GetTop5TestsByDepartment(txt_sdate, txt_edate).ToList();

                    if (query == null || query.Count == 0)
                    {
                        return "[]";
                    }

                    // Group by department
                    var departmentData = query.GroupBy(x => x.Department)
                                            .Select(g => new
                                            {
                                                Department = g.Key,
                                                TotalDepartmentAmount = g.Sum(t => t.TotalAmount ?? 0),
                                                TotalDepartmentCount = g.Sum(t => t.TestCount ?? 0),
                                                Tests = g.OrderBy(t => t.DeptRank)
                                                        .Select(t => new
                                                        {
                                                            TestName = t.Test_Name ?? "Unknown Test",
                                                            TotalAmount = t.TotalAmount ?? 0,
                                                            TestCount = t.TestCount ?? 0,
                                                            Rank = t.DeptRank ?? 0,
                                                            Percentage = t.TotalAmount > 0 ?
                                                                Math.Round((t.TotalAmount.Value / g.Sum(x => x.TotalAmount ?? 1)) * 100, 2) : 0
                                                        }).ToList()
                                            }).ToList();

                    result = (new JavaScriptSerializer()).Serialize(departmentData);
                }
            }
            catch (Exception ex)
            {
                result = "[]";
                System.Diagnostics.Debug.WriteLine("Error in GetTop5TestsByDepartment: " + ex.Message);
            }
            return result;
        }
        [WebMethod]
        public static string GetPatientCountsAndNetAmount(string txt_sdate, string txt_edate)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_GetPatientCountsAndNetAmountByDate(txt_sdate, txt_edate).ToList();
                return new JavaScriptSerializer().Serialize(query);
            }
        }

        [WebMethod]
        public static string GetEmergencyPatientCountsAndNetAmount(string txt_sdate, string txt_edate)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_GetEmergencyPatientCountsAndNetAmountByDate(txt_sdate, txt_edate).ToList();
                return new JavaScriptSerializer().Serialize(query);
            }
        }

        [WebMethod]
        public static string GetVitalCount(string txt_sdate, string txt_edate)
        {
            string result = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_GetOPDVitalCounts(txt_sdate, txt_edate).FirstOrDefault();
                result = (new JavaScriptSerializer()).Serialize(query);
            }
            return result;
        }
        [WebMethod]
        public static string GetGetOverallSatisfaction(string txt_sdate, string txt_edate)
        {
            string result = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_GetOverallSatisfactionAverage(txt_sdate, txt_edate).FirstOrDefault();
                result = (new JavaScriptSerializer()).Serialize(query);
            }
            return result;
        }

        [WebMethod]
        public static string GetDocPatientCount(string txt_sdate, string txt_edate)
        {
            string result = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_GetDoctorCountForCEODashboard(txt_sdate, txt_edate).ToList();
                result = (new JavaScriptSerializer()).Serialize(query);
            }
            return result;
        }

        [WebMethod]
        public static string GetDepartmentPatientCount(string txt_sdate, string txt_edate)
        {
            string result = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_GetDepartmentPatientCountForCEODashboard((txt_sdate),( txt_edate)).ToList();
                result = new JavaScriptSerializer().Serialize(query);
            }
            return result;
        }

        [WebMethod]
        public static string GetIPDPatientCountsAndNetAmount(string txt_sdate, string txt_edate)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_GetIPDPatientCountsAndNetAmountByDate(txt_sdate, txt_edate).ToList();
                return new JavaScriptSerializer().Serialize(query);
            }
        }

        [WebMethod]
        public static string GetWardBedOccupancy(string txt_sdate, string txt_edate)
        {
            using (var db = new DataBaseDataContext())
            {
                var result = db.sp_GetWardBedOccupancy(txt_sdate, txt_edate).ToList();
                return new JavaScriptSerializer().Serialize(result);
            }
        }

        [WebMethod]
        public static string GetOPDDepartmentWise(string txt_sdate, string txt_edate)
        {
            using (var db = new DataBaseDataContext())
            {
                var result = db.sp_OPDDepartmentWise(txt_sdate, txt_edate).ToList();
                return new JavaScriptSerializer().Serialize(result);
            }
        }

        [WebMethod]
        public static string GetEmergencyWardBedOccupancy(string txt_sdate, string txt_edate)
        {
            using (var db = new DataBaseDataContext())
            {
                var result = db.sp_GetEmergencyWardBedOccupancy(txt_sdate, txt_edate).ToList();
                return new JavaScriptSerializer().Serialize(result);
            }
        }


        [WebMethod]
        public static string GetAppointmentCountByDoctor(string txt_sdate, string txt_edate)
        {
            string result = string.Empty;

            try
            {
                DateTime startDate = DateTime.Parse(txt_sdate);
                DateTime endDate = DateTime.Parse(txt_edate).AddDays(1).AddSeconds(-1); // Include full end date

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var query = (from app in db.Appointment_Forms
                                 where app.App_Date >= startDate &&
                                       app.App_Date <= endDate &&
                                       app.IS_CANCEL != true // Exclude cancelled appointments
                                 join emp in db.HR_Employees on app.Consultant_ID equals emp.Emp_ID.ToString() into empJoin
                                 from emp in empJoin.DefaultIfEmpty() // Left join to get doctor details
                                 where emp != null && emp.IsDoctor == true // Filter only doctors
                                 group new { app, emp } by new { emp.Emp_ID, emp.Emp_Name } into g
                                 select new
                                 {
                                     Doctor_ID = g.Key.Emp_ID,
                                     Doctor_Name = g.Key.Emp_Name ?? "Unknown Doctor",
                                     Appointment_Count = g.Count(),
                                     Completed_Count = g.Count(x => x.app.Status == "Completed"),
                                     Pending_Count = g.Count(x => x.app.Status == "Pending" || x.app.Status == "Scheduled"),
                                     Cancelled_Count = g.Count(x => x.app.IS_CANCEL == true),
                                     // Additional doctor info if needed
                                     Department = g.First().emp.Department,
                                     Designation = g.First().emp.Designation
                                 })
                                .OrderByDescending(x => x.Appointment_Count)
                                .Take(10) // Top 10 doctors by appointment count
                                .ToList();

                    result = (new JavaScriptSerializer()).Serialize(query);
                }
            }
            catch (Exception ex)
            {
                result = (new JavaScriptSerializer()).Serialize(new { Error = ex.Message });
            }

            return result;
        }
    }
}