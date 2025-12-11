using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Dashboards
{
    public partial class Sales_Dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static SalesSummary GetSalesSummary()
        {
            SalesSummary summary = new SalesSummary();

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = db.sp_GetSalesSummary().FirstOrDefault();
                if (result != null)
                {
                    summary.This_Week_Sale = result.This_Week_Sale ?? 0;
                    summary.Previous_Week_Sale = result.Previous_Week_Sale ?? 0;

                    summary.This_Month_Sale = result.This_Month_Sale ?? 0;
                    summary.Previous_Month_Sale = result.Previous_Month_Sale ?? 0;

                    summary.This_Year_Sale = result.This_Year_Sale ?? 0;
                    summary.Previous_Year_Sale = result.Previous_Year_Sale ?? 0;

                    summary.This_Week_Discount = result.This_Week_Discount ?? 0;
                    summary.This_Month_Discount = result.This_Month_Discount ?? 0;
                    summary.This_Year_Discount = result.This_Year_Discount ?? 0;

                    summary.This_Week_Profit = result.This_Week_Profit ?? 0;
                    summary.This_Month_Profit = result.This_Month_Profit ?? 0;
                    summary.This_Year_Profit = result.This_Year_Profit ?? 0;

                }
            }

            return summary;
        }

        public class SalesSummary
        {
            public decimal This_Week_Sale { get; set; }
            public decimal Previous_Week_Sale { get; set; }
            public decimal This_Month_Sale { get; set; }
            public decimal Previous_Month_Sale { get; set; }
            public decimal This_Year_Sale { get; set; }
            public decimal Previous_Year_Sale { get; set; }

            public decimal This_Week_Discount { get; set; }
            public decimal This_Month_Discount { get; set; }
            public decimal This_Year_Discount { get; set; }

            public decimal This_Week_Profit { get; set; }
            public decimal This_Month_Profit { get; set; }
            public decimal This_Year_Profit { get; set; }

        }

        public class TopSalesMedicine
        {
            public string Item_Name { get; set; }
            public decimal TotalNetAmount { get; set; }
            public int TotalQty { get; set; }
        }

        [WebMethod]
        public static List<TopSalesMedicine> GetTopSalesMedicines()
        {
            List<TopSalesMedicine> list = new List<TopSalesMedicine>();

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = db.ExecuteQuery<TopSalesMedicine>(
                    "EXEC SP_GetTopSalesMedicines"
                ).ToList();

                list = result;
            }

            return list;
        }

        public class MedicineCategorySummary
        {
            public string MedicineCategory { get; set; }
            public int TotalQty { get; set; }
            public decimal TotalNetAmount { get; set; }
        }

        [WebMethod]
        public static List<MedicineCategorySummary> GetSalesMedicinesDepartmentWise()
        {
            List<MedicineCategorySummary> list = new List<MedicineCategorySummary>();

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = db.ExecuteQuery<MedicineCategorySummary>(
                    "EXEC SP_GetPharmacyMedicineSummary"
                ).ToList();

                list = result;
            }

            return list;
        }

        public class DailySales
        {
            public string SaleDate { get; set; }
            public int TotalQty { get; set; }
            public decimal TotalNetAmount { get; set; }
        }

        [WebMethod]
        public static List<DailySales> GetLastMonthDailySales()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = db.ExecuteQuery<DailySales>("EXEC GetLastMonthDailySales").ToList();
                return result;
            }
        }

        public class YearlySalesComparison
        {
            public string MonthName { get; set; }
            public decimal PrevYearAmount { get; set; }
            public decimal CurrentYearAmount { get; set; }
        }

        [WebMethod]
        public static List<YearlySalesComparison> GetSalesComparisonYearly()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = db.ExecuteQuery<YearlySalesComparison>("EXEC SP_GetSalesComparisonYearly").ToList();
                return result;
            }
        }

        public class PharmacyStockSummary
        {
            public decimal GrandTotalQty { get; set; }
            public decimal GrandTotalAmount { get; set; }
            public decimal DeadStockQty { get; set; }
            public decimal DeadStockAmount { get; set; }
        }

        [WebMethod]
        public static List<PharmacyStockSummary> GetPharmacyStockSummary()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                return db.ExecuteQuery<PharmacyStockSummary>(
                    "EXEC sp_PharmacyStockcurrent"
                ).ToList();
            }
        }

        public class PendingPOSummary
        {
            public decimal TotalPendingQty { get; set; }
            public decimal TotalPendingAmount { get; set; }
        }

        [WebMethod]
        public static List<PendingPOSummary> GetPendingPO()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                return db.ExecuteQuery<PendingPOSummary>(
                    "EXEC sp_PendingPO"
                ).ToList();
            }
        }

    }
}