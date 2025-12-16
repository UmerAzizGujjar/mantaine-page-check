using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web;

namespace PMS.Modules.PatientManagement
{
    public partial class OPDDischarge : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]

        public static string ViewList(string search, string fil_clinic, string Doc_id)
        {
            string data = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();

            var d = db.sp_GetOpdDischargeList(search, fil_clinic, Doc_id).ToList();

            if (d != null)
            {
                JavaScriptSerializer serl = new JavaScriptSerializer();
                data = serl.Serialize(d);
            }
            return data;
        }
        [WebMethod]
        public static string LoadFilterClinic()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var EmpList = (from tbl in db.ValueSets
                           join Dv in db.DataValues on
                           tbl.ValueSet_ID equals Dv.ValueSet_ID
                           where
                           tbl.ValueSet_Description == "Filter Clinic"
                           select new
                           {
                               Dv.DataValue_Name,
                               Dv.DataValue_Description
                           }).ToList();
            return (new JavaScriptSerializer().Serialize(EmpList));
        }
        [WebMethod]
        public static string LoadDoctor()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var EmpList = (from hr in db.HR_Employees
                           where hr.IsDoctor == true
                           select new
                           {
                               hr.Emp_ID,
                               hr.Emp_Name
                           }).ToList();
            return (new JavaScriptSerializer().Serialize(EmpList));
        }

        [WebMethod]
        public static string DischargePatients(List<int> patientIds)
        {
            try
            {
                // Assuming you have a connection string defined in your Web.config
                string connectionString = ConfigurationManager.ConnectionStrings["ASPGLConnectionString"].ConnectionString;

                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    con.Open();

                    foreach (var patientId in patientIds)
                    {
                        // Create a SQL command to update the patient's record to mark them as discharged
                        using (SqlCommand cmd = new SqlCommand("UPDATE Out_Patient SET Discharge = 1, discharge_date = @DischargeDate WHERE Out_Patient_ID = @PatientID", con))
                        {
                            cmd.Parameters.AddWithValue("@PatientID", patientId);
                            cmd.Parameters.AddWithValue("@DischargeDate", DateTime.Now);

                            cmd.ExecuteNonQuery();
                        }
                    }

                    con.Close();
                }

                return "Success";
            }
            catch (Exception ex)
            {
                // Log the exception (optional)
                // LogError(ex);

                return "Error: " + ex.Message;
            }
        }

    }
}