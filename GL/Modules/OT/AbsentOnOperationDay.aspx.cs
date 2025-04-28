using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class AbsentOnOperationDay : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string get_ot_fitnes_list()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var get_result = db.sp_Operation_Theater_View_Assigned_Absent().ToList();
            return (new JavaScriptSerializer().Serialize(get_result));
        }
        [WebMethod]
        public static string StatusUpdate(string fitness_id)
        {
            return "Prepared";
        }


        [WebMethod]
        public static string GetDoctors()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var docs = (from data in db.HR_Employees
                        where data.IsDoctor == true
                        select data).ToList();

            return (new JavaScriptSerializer()).Serialize(docs);
        }
    }
}