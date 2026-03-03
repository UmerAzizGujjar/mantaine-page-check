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
        public static string GetHospitalRevenue(string txt_sdate, string txt_edate)
        {
            try
            {
                // 1. Parse Dates correctly
                DateTime startDate = DateTime.Parse(txt_sdate).Date;
                DateTime endDate = DateTime.Parse(txt_edate).Date.AddDays(1).AddTicks(-1);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var query = from p in db.Patients
                                join a in db.Ar_Billings
                                    on p.Reg_PatId equals a.Patient_ID into billingGroup
                                from a in billingGroup.DefaultIfEmpty()
                                where a == null || (a.Creation_Date >= startDate && a.Creation_Date <= endDate)
                                select new
                                {
                                    PatientReceipt = p.Receipt_Amount ?? 0,
                                    BillingReceived = a != null ? (a.Received_Amount ?? 0) : 0
                                };
                    decimal totalRevenue = query.AsEnumerable()
                        .Sum(x => x.PatientReceipt + x.BillingReceived);
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

    }
}