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
    public partial class DashPatientsCountertoClinic : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string ViewList(string txt_sdate, string txt_edate)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_GetPatientCounter_to_Clinic_details(txt_sdate, txt_edate).ToList();

                var serializer = new JavaScriptSerializer();
                serializer.MaxJsonLength = int.MaxValue;

                return serializer.Serialize(query);
            }
        }
    }
}