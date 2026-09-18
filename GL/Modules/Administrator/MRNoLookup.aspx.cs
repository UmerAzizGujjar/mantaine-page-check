using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web.Services;

namespace PMS.Modules.Administrator
{
    public partial class MRNoLookup : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        [WebMethod]
        public static List<PatientHeader> SearchByMRNo(string mrNo)
        {
            List<PatientHeader> list = new List<PatientHeader>();

            if (string.IsNullOrWhiteSpace(mrNo))
            {
                return list;
            }

            string connectionString = ConfigurationManager.ConnectionStrings["NationalHospitalConnectionString"].ConnectionString;
            string term = mrNo.Trim();

            using (DataBaseDataContext db = new DataBaseDataContext(connectionString))
            {
                list = db.Reg_patients
                    .Where(p => p.mr_no_sequence != null
                                && p.mr_no_sequence.Contains(term)
                                && (p.iscancel == null || p.iscancel == false))
                    .OrderByDescending(p => p.pat_id)
                    .Take(200)
                    .Select(p => new PatientHeader
                    {
                        MRNo = p.mr_no_sequence,
                        Full_Name = p.Full_Name,
                        Father_Name = p.Father_Name,
                        Gender = p.Gender,
                        Age = p.Age_years,
                        Mobile = p.Mobile1,
                        NIC = p.NIC,
                        Blood_Group = p.Blood_Group,
                        Address = p.Permanent_Address
                    })
                    .ToList();
            }

            return list;
        }

        public class PatientHeader
        {
            public string MRNo { get; set; }
            public string Full_Name { get; set; }
            public string Father_Name { get; set; }
            public string Gender { get; set; }
            public string Age { get; set; }
            public string Mobile { get; set; }
            public string NIC { get; set; }
            public string Blood_Group { get; set; }
            public string Address { get; set; }
        }
    }
}
