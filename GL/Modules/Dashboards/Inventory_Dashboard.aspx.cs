using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Dashboards
{
    public partial class Inventory_Dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static List<PurchaseOrderChart> GetPurchaseOrderChart()
        {
            List<PurchaseOrderChart> list = new List<PurchaseOrderChart>();

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = db.GetPurchaseOrderChart();

                foreach (var item in result)
                {
                    list.Add(new PurchaseOrderChart
                    {
                        MonthName = item.MonthName,
                        TotalPOs = item.TotalPOs ?? 0,
                        TotalAmount = item.TotalAmount ?? 0
                    });
                }
            }

            return list;
        }
        public class PurchaseOrderChart
        {
            public string MonthName { get; set; }
            public int TotalPOs { get; set; }
            public decimal TotalAmount { get; set; }
        }

        public class TopGRNItem
        {
            public string Description { get; set; }
            public decimal TotalAmount { get; set; }
            public int ReceivedCount { get; set; }
        }

        [WebMethod]
        public static List<TopGRNItem> GetTopGRNItems()
        {
            List<TopGRNItem> list = new List<TopGRNItem>();

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = db.ExecuteQuery<TopGRNItem>(
                    "EXEC SP_GetTopGRNItems"
                ).ToList();

                list = result;
            }

            return list;
        }




        [WebMethod]
        public static List<GRNChart> GetGRNChart()
        {
            List<GRNChart> list = new List<GRNChart>();

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = db.SP_GetGRNChart();

                foreach (var item in result)
                {
                    list.Add(new GRNChart
                    {
                        MonthName = item.MonthName,
                        TotalGRNs = item.TotalGRNs ?? 0,
                        TotalAmount = item.TotalAmount ?? 0
                    });
                }
            }

            return list;
        }

        public class GRNChart
        {
            public string MonthName { get; set; }
            public int TotalGRNs { get; set; }
            public decimal TotalAmount { get; set; }
        }

        public class TopGRNVendor
        {
            public string Vendor_Name { get; set; }
            public decimal TotalAmount { get; set; }
        }

        [WebMethod]
        public static List<TopGRNVendor> GetTopGRNVendors()
        {
            List<TopGRNVendor> list = new List<TopGRNVendor>();

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = db.ExecuteQuery<TopGRNVendor>(
                    "EXEC SP_GetTopGRNVendors"
                ).ToList();

                list = result;
            }

            return list;
        }

        public class TopPaidVendor
        {
            public string Vendor_Name { get; set; }
            public decimal TotalPaid { get; set; }
        }

        [WebMethod]
        public static List<TopPaidVendor> GetTopPaidVendors()
        {
            List<TopPaidVendor> list = new List<TopPaidVendor>();

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = db.ExecuteQuery<TopPaidVendor>(
                    "EXEC SP_GetTopPaidVendors"
                ).ToList();

                list = result;
            }

            return list;
        }

        public class POSummary
        {
            public int TotalPO_Last7Days { get; set; }
            public decimal TotalAmount_Last7Days { get; set; }
            public int TotalPO_LastMonth { get; set; }
            public decimal TotalAmount_LastMonth { get; set; }
            public int TotalPO_LastYear { get; set; }
            public decimal TotalAmount_LastYear { get; set; }
        }

        [WebMethod]
        public static POSummary GetPOSummary()
        {
            POSummary summary = new POSummary();

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = db.ExecuteQuery<POSummary>("EXEC SP_GetPOSummary").FirstOrDefault();
                if (result != null)
                {
                    summary = result;
                }
            }

            return summary;
        }

        public class GRNSummary
        {
            public int TotalGRN_Last7Days { get; set; }
            public decimal TotalAmount_Last7Days { get; set; }
            public int TotalGRN_LastMonth { get; set; }
            public decimal TotalAmount_LastMonth { get; set; }
            public int TotalGRN_LastYear { get; set; }
            public decimal TotalAmount_LastYear { get; set; }
        }

        [WebMethod]
        public static GRNSummary GetGRNSummary()
        {
            GRNSummary summary = new GRNSummary();

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = db.ExecuteQuery<GRNSummary>("EXEC SP_GetGRNSummary").FirstOrDefault();
                if (result != null)
                {
                    summary = result;
                }
            }

            return summary;
        }

        public class PaymentSummary
        {
            public int TotalPayments_Last7Days { get; set; }
            public decimal TotalAmount_Last7Days { get; set; }
            public int TotalPayments_LastMonth { get; set; }
            public decimal TotalAmount_LastMonth { get; set; }
            public int TotalPayments_LastYear { get; set; }
            public decimal TotalAmount_LastYear { get; set; }
        }

        [WebMethod]
        public static PaymentSummary GetPaymentSummary()
        {
            PaymentSummary summary = new PaymentSummary();

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = db.ExecuteQuery<PaymentSummary>("EXEC SP_GetPaymentSummary").FirstOrDefault();
                if (result != null)
                {
                    summary = result;
                }
            }

            return summary;
        }

    }
}