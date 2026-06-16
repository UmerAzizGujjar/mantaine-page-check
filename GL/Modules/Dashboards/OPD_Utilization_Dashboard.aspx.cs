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
    public partial class OPD_Utilization_Dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string LoadDepartment()
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
        public static string GetTotalDepartmentRevenu(string txt_sdate, string txt_edate)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_OPD_Utilization(txt_sdate, txt_edate).FirstOrDefault();


                result = (new JavaScriptSerializer()).Serialize(query);
            }

            return result;
        }
        [WebMethod]
        public static string GetDepartmentWiseRevenu(string txt_sdate, string txt_edate, string Dep)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_OPD_Utilization_Departmentwise(Dep, txt_sdate, txt_edate).ToList();


                result = (new JavaScriptSerializer()).Serialize(query);
            }

            return result;
        }
        [WebMethod]
        public static string GetMonthlyTrends()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var months = new List<string>();
                var patients = new List<int>();
                var revenue = new List<decimal>();
                var now = DateTime.Now;
                for (int i = 11; i >= 0; i--)
                {
                    var monthStart = new DateTime(now.Year, now.Month, 1).AddMonths(-i);
                    var monthEnd = monthStart.AddMonths(1).AddDays(-1);
                    var data = db.sp_OPD_Utilization(monthStart.ToString("yyyy-MM-dd"), monthEnd.ToString("yyyy-MM-dd")).FirstOrDefault();
                    months.Add(monthStart.ToString("MMM"));
                    patients.Add(data?.Total_patients_Count ?? 0);
                    revenue.Add(data?.Total_Revenu ?? 0);
                }
                return new JavaScriptSerializer().Serialize(new { labels = months, patients, revenue });
            }
        }
    }
}