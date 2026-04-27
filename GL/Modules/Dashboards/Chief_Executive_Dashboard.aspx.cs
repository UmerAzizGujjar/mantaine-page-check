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

    }
}