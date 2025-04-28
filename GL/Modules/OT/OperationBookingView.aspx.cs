using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Web.Services;
using System.Web.Script.Serialization;

namespace PMS
{
    public partial class OperationBookingView : System.Web.UI.Page
    {


        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string get_ot_fitnes_list()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var get_result = db.sp_Operation_Theater_View();
            return (new JavaScriptSerializer().Serialize(get_result));
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

        public class Fitness_vals
        {
            public string In_Patient_ID { get; set; }
            public string doc_id { get; set; }
            public string op_date { get; set; }
            public string patientType { get; set; }

        }

        [WebMethod]
        public static string update_call(List<Fitness_vals> detailAry)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            string value = "failure";
            foreach (var item in detailAry)
            {
                if (item.patientType == "IPD")
                {
                    In_Patient inp = new In_Patient();
                    var record = (from data in db.In_Patients
                                  where data.In_Patient_ID == Convert.ToInt32(item.In_Patient_ID)
                                  select data).FirstOrDefault();
                    record.Referred_Doctor = item.doc_id;
                    record.Operation_Date = Convert.ToDateTime(item.op_date);
                }
                else
                {
                    Out_Patient opd = new Out_Patient();
                    var opd_Record = (from opdData in db.Out_Patients
                                     where opdData.Out_Patient_ID == Convert.ToInt32(item.In_Patient_ID)
                                     select opdData).FirstOrDefault();
                    opd_Record.Refering_Doctor = item.doc_id;
                    opd_Record.OPD_Entry_Date = Convert.ToDateTime(item.op_date);
                }
                
                try
                {
                    db.SubmitChanges();
                    value = "success";
                }
                catch (Exception ex)
                {
                    value = "failure";
                }

            }
            return value;
        }


    }
}