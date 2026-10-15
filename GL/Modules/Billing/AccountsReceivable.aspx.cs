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
    public partial class AccountsReceivable : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string ViewList()
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            using (SqlConnection con = new SqlConnection(db.Connection.ConnectionString))
            using (SqlCommand cmd = new SqlCommand("dbo.sp_Load_HospitalShare_Receivable", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Company_ID", AppConfig.Company_ID);
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
    }
}
