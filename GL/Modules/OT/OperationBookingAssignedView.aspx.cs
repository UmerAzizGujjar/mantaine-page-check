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
    public partial class OperationBookingAssignedView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string get_ot_fitnes_list()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var get_result = db.sp_Operation_Theater_View_Assigned();
            return (new JavaScriptSerializer().Serialize(get_result));
        }
        [WebMethod]
        public static string StatusUpdate(string fitness_id, string PatientType)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            try
            {
                if (PatientType == "IPD")
                {
                    In_Patient inp = new In_Patient();
                    var record = (from data in db.In_Patients
                                  where data.In_Patient_ID == Convert.ToInt32(fitness_id)
                                  select data).FirstOrDefault();
                    record.Prepared_Status = true;
                }
                else if (PatientType == "OPD")
                {
                    Out_Patient opd = new Out_Patient();
                    var opdRecord = (from data in db.Out_Patients
                                     where data.Out_Patient_ID == Convert.ToInt32(fitness_id)
                                     select data).FirstOrDefault();
                    opdRecord.Prepared_Status = true;
                }
                db.SubmitChanges();
                return "Prepared";

            }
            catch (Exception ex)
            {
                return ex.Message;
            }
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