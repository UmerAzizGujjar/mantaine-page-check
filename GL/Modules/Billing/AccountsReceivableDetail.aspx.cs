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

        [WebMethod]
        public static string LoadAccounts()
        {
            var list = new List<Dictionary<string, object>>();

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = (from account in db.GL_Accounts
                             where account.Active == true && account.Levels == 4
                             orderby account.Account_Code
                             select new
                             {
                                 account.Account_ID,
                                 account.Account_Code,
                                 account.Account_Name
                             }).ToList();

                foreach (var item in query)
                {
                    var row = new Dictionary<string, object>();
                    row["Account_ID"] = item.Account_ID;
                    row["Account_Code"] = item.Account_Code;
                    row["Account_Name"] = item.Account_Name;
                    list.Add(row);
                }
            }

            return (new JavaScriptSerializer()).Serialize(list);
        }

        [WebMethod]
        public static string TransferReceivable(string rtype, string startDate, string endDate, int accountID)
        {
            try
            {
                var rows = new List<Dictionary<string, object>>();

                using (DataBaseDataContext db = new DataBaseDataContext())
                using (SqlConnection con = new SqlConnection(db.Connection.ConnectionString))
                using (SqlCommand cmd = new SqlCommand("dbo.SpTransfer_HospitalShare_Receivable", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Type", rtype ?? "");
                    cmd.Parameters.AddWithValue("@startDate", startDate ?? "");
                    cmd.Parameters.AddWithValue("@endDate", endDate ?? "");
                    cmd.Parameters.AddWithValue("@RecvAccount", accountID);
                    cmd.Parameters.AddWithValue("@user_id", AppConfig.UserID);
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
            catch (Exception ex)
            {
                var rows = new List<Dictionary<string, object>>();
                var row = new Dictionary<string, object>();
                row["Message"] = ex.Message;
                row["Voucher_ID"] = 0;
                rows.Add(row);
                return (new JavaScriptSerializer()).Serialize(rows);
            }
        }
    }
}
