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
        public static string GetTotalDoctor(string txt_sdate, string txt_edate, string doctorArrayJson)
        {
            List<int> doctorIds = new JavaScriptSerializer().Deserialize<List<int>>(doctorArrayJson);
            DateTime startDate = DateTime.Parse(txt_sdate);
            DateTime endDate = DateTime.Parse(txt_edate);

            using (var db = new DataBaseDataContext())
            {
                int numDays = (endDate - startDate).Days + 1;

                var query = (from p in db.Patients
                             join opd in db.Out_Patients on p.Patient_ID equals opd.Patient_ID
                             join drm in db.Doctor_Rouster_Masters on p.Doctor_ID equals Convert.ToString(drm.Doctor_Id)
                             join drd in db.Doctor_Rouster_Details on drm.Rouster_id equals drd.Rouster_id
                             where opd.Discharge == true
                                   && p.filter_clinic == null
                                   && p.Created_Time >= startDate
                                   && p.Created_Time <= endDate
                                   && drd.Rouster_Date >= startDate
                                   && drd.Rouster_Date <= endDate
                                   && (doctorIds.Contains(Convert.ToInt32(p.Doctor_ID)) || !doctorIds.Any())
                             group drd by p.Doctor_ID into g
                             select new DoctorStatistics
                             {
                                 DoctorName = db.HR_Employees.Where(hr => hr.Emp_ID == Convert.ToInt32(g.Key))
                                                             .Select(hr => hr.Emp_Name).FirstOrDefault(),
                                 PatientCount = g.Count(),
                                 NumberOfDays = g.Select(d => d.Rouster_Date).Distinct().Count()
                             })
                             .Take(5)
                             .ToList();

                return new JavaScriptSerializer().Serialize(query);
            }
        }

        public class DoctorStatistics
        {
            public string DoctorName { get; set; }
            public int PatientCount { get; set; }
            public int NumberOfDays { get; set; }
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