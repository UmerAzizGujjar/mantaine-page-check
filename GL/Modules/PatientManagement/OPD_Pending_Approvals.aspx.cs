using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.PatientManagement
{
    public partial class OPD_Pending_Approvals : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string ApproveOPD(string pat_id, string Pat_Category)
        {
            var user_id = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.SpApprove_OPD_AsSiraat(Convert.ToInt32(pat_id), Pat_Category, user_id);
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string LoadPatientsToApprove(string pat_type, string search)
        {
            if (search.Trim() == "" || search.Trim() == null)
            {


                DataBaseDataContext db = new DataBaseDataContext();
                var Details = db.spLoadopdPatient(pat_type, search);
                return (new JavaScriptSerializer()).Serialize(Details);

            }
            else
            {
                DataBaseDataContext db = new DataBaseDataContext();
                var Details = db.spLoadopdPatient(pat_type, search).ToList().Where(x => x.mr_no_sequence.ToLower().Contains(search.ToLower()) || x.Status.ToLower().Contains(search.ToLower()) || x.Full_Name.ToLower().Contains(search.ToLower()));
                return (new JavaScriptSerializer()).Serialize(Details);
            }



        }
        [WebMethod]
        public static string PatientType()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Patient Type"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }
        public class check
        {

            public bool? chdeck { get; set; }

        }
    }
}
