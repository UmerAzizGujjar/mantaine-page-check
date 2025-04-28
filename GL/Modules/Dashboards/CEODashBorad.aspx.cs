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
                result = (new JavaScriptSerializer()).Serialize(query);
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
                result = (new JavaScriptSerializer()).Serialize(query);
            }
            return result;
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
    }
}