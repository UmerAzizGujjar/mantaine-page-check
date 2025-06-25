using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using System.Web.Script.Serialization;
using System.Text;
using System.Data;
using System.Data.SqlClient;

namespace PMS
{
    public partial class MainDashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }


        [WebMethod]
        public static string ViewList()
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_Dashboard_Daily().ToList();


                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
        }
        [WebMethod]
        public static string PendingPatients()
        {
            string result;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_getpendingdashboard_Patients().ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();

            }
            return result;
        }
        [WebMethod]
        public static string PendingPrivatePatients()
        {
            string result;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_getpendingPrivatedashboard_Patients().ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();

            }
            return result;
        }
        [WebMethod]
        public static string PendingLabPatients()
        {
            string result;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_getpendinglab_patients().ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();

            }
            return result;
        }
        [WebMethod]
        public static string PendingUltraPatients()
        {
            string result;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_getpendingUltra_patients().ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();

            }
            return result;
        }
        [WebMethod]
        public static string PendingXrayPatients()
        {
            string result;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_getpendingxray_patients().ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();

            }
            return result;
        }
        [WebMethod]
        public static string CheckedFilterPatient()
        {
            string result;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_getchecked_filterPatient().ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();

            }
            return result;
        }
        [WebMethod]
        public static string checkedPvtPatient()
        {
            string result;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_getchecked_pvt().ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();

            }
            return result;
        }

    }
}