using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.PatientManagement
{
    public partial class Emergency_Pending_Approvals : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string ApproveBulkEmergency(string emer_ids)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            using (SqlConnection con = new SqlConnection(db.Connection.ConnectionString))
            using (SqlCommand cmd = new SqlCommand("dbo.SpApprove_Pending_Emergency_Bulk", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Emer_IDs", (object)emer_ids ?? "");
                cmd.Parameters.AddWithValue("@user_id", AppConfig.UserID);
                return ExecuteToJson(con, cmd);
            }
        }
        [WebMethod]
        public static string ApproveSingleEmergency(string emer_id, string Pat_Category)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            using (SqlConnection con = new SqlConnection(db.Connection.ConnectionString))
            using (SqlCommand cmd = new SqlCommand("dbo.SpApprove_Pending_Emergency", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Emer_ID", Convert.ToInt64(emer_id));
                cmd.Parameters.AddWithValue("@Pat_Category", (object)Pat_Category ?? "");
                cmd.Parameters.AddWithValue("@user_id", AppConfig.UserID);
                return ExecuteToJson(con, cmd);
            }
        }
        [WebMethod]
        public static string LoadPatientsToApprove_Emergency(string pat_type, string search, string cost_center, string start_date, string end_date)
        {
            DateTime startDt;
            DateTime endDt;
            object startParam = DateTime.TryParse(start_date, out startDt) ? (object)startDt : DBNull.Value;
            object endParam = DateTime.TryParse(end_date, out endDt) ? (object)endDt : DBNull.Value;

            using (DataBaseDataContext db = new DataBaseDataContext())
            using (SqlConnection con = new SqlConnection(db.Connection.ConnectionString))
            using (SqlCommand cmd = new SqlCommand("dbo.sp_Load_EmergencyPendingApprovals", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@pat_type", (object)pat_type ?? "0");
                cmd.Parameters.AddWithValue("@search", (object)search ?? "");
                cmd.Parameters.AddWithValue("@cost_center", (object)cost_center ?? "0");
                cmd.Parameters.AddWithValue("@start_date", startParam);
                cmd.Parameters.AddWithValue("@end_date", endParam);
                return ExecuteToJson(con, cmd);
            }
        }
        // Posted emergency vouchers (ERJV bulk, ER single) for the company, in the voucher date range.
        [WebMethod]
        public static string LoadApprovedVouchers(string start_date, string end_date)
        {
            DateTime startDt;
            DateTime endDt;
            DateTime dateFrom = DateTime.TryParseExact(start_date, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out startDt)
                ? startDt.Date : DateTime.Today;
            DateTime dateTo = DateTime.TryParseExact(end_date, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out endDt)
                ? endDt.Date.AddDays(1) : DateTime.Today.AddDays(1);

            var dt = DBClass.getDataTable(
                @"SELECT v.Voucher_ID, v.Voucher_No, v.Voucher_Type, v.Voucher_Date, v.Remarks, v.Voucher_Status,
                         (SELECT COUNT(*) FROM Emergency e WHERE e.Voucher_ID = v.Voucher_ID) AS PatientCount,
                         (SELECT ISNULL(SUM(va.DR), 0) FROM GL_Voucher_Accounts va WHERE va.Voucher_ID = v.Voucher_ID) AS TotalDR,
                         (SELECT ISNULL(SUM(va.CR), 0) FROM GL_Voucher_Accounts va WHERE va.Voucher_ID = v.Voucher_ID) AS TotalCR
                  FROM GL_Vouchers v
                  WHERE v.Voucher_Type IN ('ERJV', 'ER')
                    AND ISNULL(v.IsDeleted, 0) = 0
                    AND v.Company_ID = @Company_ID
                    AND v.Voucher_Date >= @DateFrom
                    AND v.Voucher_Date < @DateTo
                  ORDER BY v.Voucher_ID DESC",
                DBClass.Param("@Company_ID", AppConfig.Company_ID),
                DBClass.Param("@DateFrom", dateFrom),
                DBClass.Param("@DateTo", dateTo));

            return new JavaScriptSerializer().Serialize(ToRows(dt));
        }

        // GL lines and emergency patients of one posted voucher, for the View popup.
        [WebMethod]
        public static string GetApprovedVoucherDetail(string voucherId)
        {
            long id = Convert.ToInt64(voucherId);

            var lines = DBClass.getDataTable(
                @"SELECT va.Narration, ga.Account_Code, ga.Account_Name, va.DR, va.CR,
                         ISNULL(dbo.GetDataValueName('Cost Center', va.Cost_Center), va.Cost_Center) AS CostCenter
                  FROM GL_Voucher_Accounts va
                  LEFT JOIN GL_Accounts ga ON ga.Account_ID = va.Account_ID
                  WHERE va.Voucher_ID = @Voucher_ID
                  ORDER BY va.Voucher_account_ID",
                DBClass.Param("@Voucher_ID", id));

            var patients = DBClass.getDataTable(
                @"SELECT e.Emergency_No, ISNULL(e.mr_no_sequence, rg.mr_no_sequence) AS mr_no_sequence, rg.Full_Name,
                         dbo.GetDataValueName('Patient Type', e.Patient_Type) AS Pat_type,
                         ISNULL(dbo.GetDataValueName('Cost Center', NULLIF(NULLIF(LTRIM(RTRIM(e.Cost_Center)), ''), '0')),
                                NULLIF(NULLIF(LTRIM(RTRIM(e.Cost_Center)), ''), '0')) AS CostCenter,
                         ISNULL(e.Actual_amount, 0) AS Actual_Amount, ISNULL(e.Receipt_Amount, 0) AS Receipt_Amount,
                         ISNULL(e.Actual_amount, 0) - ISNULL(e.Receipt_Amount, 0) AS Discount_Amount
                  FROM Emergency e
                  LEFT JOIN Reg_patient rg ON rg.pat_id = e.Reg_PatId
                  WHERE e.Voucher_ID = @Voucher_ID
                  ORDER BY e.Emer_id",
                DBClass.Param("@Voucher_ID", id));

            return new JavaScriptSerializer().Serialize(new Dictionary<string, object>
            {
                { "lines", ToRows(lines) },
                { "patients", ToRows(patients) }
            });
        }

        private static List<Dictionary<string, object>> ToRows(DataTable dt)
        {
            var rows = new List<Dictionary<string, object>>();
            foreach (DataRow r in dt.Rows)
            {
                var row = new Dictionary<string, object>();
                foreach (DataColumn c in dt.Columns)
                {
                    row[c.ColumnName] = r[c] == DBNull.Value ? null : r[c];
                }
                rows.Add(row);
            }
            return rows;
        }
        private static string ExecuteToJson(SqlConnection con, SqlCommand cmd)
        {
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

            return (new JavaScriptSerializer()).Serialize(rows);
        }
        [WebMethod]
        public static string PatientType()
        {
            return DataValuesJson("Patient Type");
        }
        [WebMethod]
        public static string CostCenter()
        {
            return DataValuesJson("Cost Center");
        }
        private static string DataValuesJson(string valueSetName)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == valueSetName
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                return new JavaScriptSerializer().Serialize(result);
            }
        }
    }
}
