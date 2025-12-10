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
    public partial class DashPatientsCount : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string ViewList(string txt_sdate, string txt_edate)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_Patients_Count(txt_sdate, txt_edate).FirstOrDefault();
                result = (new JavaScriptSerializer()).Serialize(query);
            }
            return result;
        }

        [WebMethod]
        public static string LoadDepartmenr()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var EmpList = (from tbl in db.ValueSets
                           join Dv in db.DataValues on
                           tbl.ValueSet_ID equals Dv.ValueSet_ID
                           where
                           tbl.ValueSet_Description == "Patient Main Category"
                           select new
                           {
                               Dv.DataValue_Name,
                               Dv.DataValue_Description
                           }).ToList();
            return (new JavaScriptSerializer().Serialize(EmpList));
        }
        [WebMethod]
        public static string GetTotalDepartment(string txt_sdate, string txt_edate, string Dep)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.PatientsCount_DepartmentWise(Dep, txt_sdate, txt_edate).ToList();


                result = (new JavaScriptSerializer()).Serialize(query);
            }

            return result;
        }
    }
}