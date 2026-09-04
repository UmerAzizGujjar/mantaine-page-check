using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
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
        public static string ApproveBulkOPD(string pat_ids)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            using (SqlConnection con = new SqlConnection(db.Connection.ConnectionString))
            using (SqlCommand cmd = new SqlCommand("dbo.SpApprove_Pending_OPD_Bulk", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Pat_IDs", (object)pat_ids ?? "");
                cmd.Parameters.AddWithValue("@user_id", AppConfig.UserID);
                con.Open();

                var rows = new List<Dictionary<string, object>>();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var row = new Dictionary<string, object>();
                        for (int i = 0; i < reader.FieldCount; i++)
                        {
                            row[reader.GetName(i)] = reader.IsDBNull(i) ? null : reader.GetValue(i);
                        }
                        rows.Add(row);
                    }
                }

                result = (new JavaScriptSerializer()).Serialize(rows);
            }
            return result;
        }
        [WebMethod]
        public static string LoadPatientsToApprove_OPD(string pat_type, string search)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            using (SqlConnection con = new SqlConnection(db.Connection.ConnectionString))
            using (SqlCommand cmd = new SqlCommand("dbo.sp_Load_OPDPendingApprovals", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@pat_type", (object)pat_type ?? "0");
                cmd.Parameters.AddWithValue("@search", (object)search ?? "");
                con.Open();

                var rows = new List<Dictionary<string, object>>();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var row = new Dictionary<string, object>();
                        for (int i = 0; i < reader.FieldCount; i++)
                        {
                            row[reader.GetName(i)] = reader.IsDBNull(i) ? null : reader.GetValue(i);
                        }
                        rows.Add(row);
                    }
                }

                result = (new JavaScriptSerializer()).Serialize(rows);
            }
            return result;
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
