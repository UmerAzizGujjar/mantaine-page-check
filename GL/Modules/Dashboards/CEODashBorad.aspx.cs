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
    public partial class CEODashBorad : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string GetPatientsCount(string txt_sdate, string txt_edate)
        {
            string result = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_GetPatientCountsByDate(txt_sdate, txt_edate).FirstOrDefault();
                result = (new JavaScriptSerializer()).Serialize(query);
            }
            return result;
        }
        [WebMethod]
        public static string GetAppointmentsOPDCount(string txt_sdate, string txt_edate)
        {
            string result = string.Empty;

            try
            {
                DateTime startDate = DateTime.Parse(txt_sdate);
                DateTime endDate = DateTime.Parse(txt_edate);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    int count = db.Patients
                                  .Where(dt => dt.Created_Time >= startDate &&
                                               dt.Created_Time <= endDate &&
                                               dt.appointment_id.HasValue &&
                                               dt.appointment_id != 0)
                                  .Count();

                    result = (new JavaScriptSerializer()).Serialize(new { AppointmentsOPDCount = count });
                }
            }
            catch (Exception ex)
            {
                result = (new JavaScriptSerializer()).Serialize(new { Error = ex.Message });
            }

            return result;
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
            string result = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_GetPharmacyCounts(txt_sdate, txt_edate).ToList();

                decimal totalNetAmount = query.Sum(x => x.TotalReceivedAmount);
                var totalRow = new
                {
                    CustomerType = "Total",
                    TotalCount = query.Sum(x => x.TotalCount),
                    TotalReceivedAmount = totalNetAmount
                };
                var resultList = query.Cast<object>().ToList();
                resultList.Add(totalRow);

                result = (new JavaScriptSerializer()).Serialize(resultList);
            }
            return result;
        }


        [WebMethod]
        public static string GetInvestigationCount(string txt_sdate, string txt_edate)
        {
            string result = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_GetInvestigationCounts(txt_sdate, txt_edate).ToList();

                decimal? totalNetAmount = query.Sum(x => x.TotalBillAmount);


                var totalRow = new
                {
                    Department = "Total",
                    TotalBillCount = query.Sum(x => x.TotalBillCount ?? 0),
                    TotalPerformCount = query.Sum(x => x.TotalPerformCount ?? 0),
                    TotalBillAmount = totalNetAmount
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