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
    public partial class Inventory_ProcurementDashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string LaodDashBoard(string txt_sdate, string txt_edate)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.GetInventoryCounts(txt_sdate, txt_edate).ToList();


                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
        }
    }
}