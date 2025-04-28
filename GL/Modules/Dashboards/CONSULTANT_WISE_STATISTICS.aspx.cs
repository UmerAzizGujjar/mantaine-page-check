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
    public partial class CONSULTANT_WISE_STATISTICS : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string GetTotalDoctor(string txt_sdate, string txt_edate, string Doctor)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_loadPatientsDoctorWise(Doctor, txt_sdate, txt_edate).ToList();


                result = (new JavaScriptSerializer()).Serialize(query);
            }

            return result;
        }
        [WebMethod]
        public static string LoadDoctor()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            List<HR_Employee> EmpList = new List<HR_Employee>();
            EmpList = (from tbl in db.HR_Employees
                       where (tbl.IsDoctor == true)
                       select tbl).ToList();
            return (new JavaScriptSerializer().Serialize(EmpList));
        }
    }
}