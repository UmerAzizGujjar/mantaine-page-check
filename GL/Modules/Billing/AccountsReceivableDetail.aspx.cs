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

namespace PMS.Modules.Billing
{
    public partial class AccountsReceivableDetail : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string ViewList(string rtype, string startDate, string endDate)
        {
            var rows = new List<Dictionary<string, object>>();

            using (DataBaseDataContext db = new DataBaseDataContext())
            using (SqlConnection con = new SqlConnection(db.Connection.ConnectionString))
            using (SqlCommand cmd = new SqlCommand("dbo.sp_Load_HospitalShare_Receivable_Detail", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Type", rtype ?? "");
                cmd.Parameters.AddWithValue("@startDate", startDate ?? "");
                cmd.Parameters.AddWithValue("@endDate", endDate ?? "");
                con.Open();

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
            }

            return (new JavaScriptSerializer()).Serialize(rows);
        }
    }
}
