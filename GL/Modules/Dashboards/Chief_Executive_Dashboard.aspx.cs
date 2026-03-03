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
                DateTime startDate = DateTime.Parse(txt_sdate).Date;
                DateTime endDate = DateTime.Parse(txt_edate).Date.AddDays(1).AddTicks(-1);

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
                        TotalHospitalRevenue = totalRevenue
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { Error = ex.Message, Stack = ex.StackTrace });
            }
        }

    }
}