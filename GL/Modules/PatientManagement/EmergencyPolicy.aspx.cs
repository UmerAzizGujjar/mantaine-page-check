using Newtonsoft.Json;
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
    // Per-company field permissions for EmergencyForm.aspx (table company_emergency_policy, see EmergencyPolicy.sql)
    public partial class EmergencyPolicy : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string GetCompany()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.sys_Companies
                              select new
                              {
                                  dv.Company_ID,
                                  dv.Company_Name
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }
        public class FieldPermission
        {
            public string field_name { get; set; }
            public bool is_enabled { get; set; }
        }

        [WebMethod]
        public static string SaveCompanyEmergencyRights(int company_id, List<FieldPermission> rights)
        {
            try
            {
                if (DBClass.getDataTable("SELECT 1 FROM sys_Companys WHERE Company_ID = @company_id",
                        DBClass.Param("@company_id", company_id)).Rows.Count == 0)
                {
                    return "{\"success\":false,\"message\":\"Invalid Company ID.\"}";
                }

                var cleanedRights = (rights ?? new List<FieldPermission>())
                    .Where(r => !string.IsNullOrWhiteSpace(r.field_name))
                    .GroupBy(r => r.field_name.Trim(), StringComparer.OrdinalIgnoreCase)
                    .Select(g => new FieldPermission { field_name = g.Key, is_enabled = g.Last().is_enabled })
                    .ToList();

                using (SqlConnection con = new SqlConnection(DBClass.ConnectionString()))
                {
                    con.Open();
                    using (SqlTransaction tran = con.BeginTransaction())
                    {
                        // Remove fields no longer on the form
                        using (SqlCommand cmd = new SqlCommand("DELETE FROM company_emergency_policy WHERE company_id = @company_id" +
                            (cleanedRights.Count > 0
                                ? " AND field_name NOT IN (" + string.Join(",", cleanedRights.Select((r, i) => "@f" + i)) + ")"
                                : ""), con, tran))
                        {
                            cmd.Parameters.Add(DBClass.Param("@company_id", company_id));
                            for (int i = 0; i < cleanedRights.Count; i++)
                                cmd.Parameters.Add(DBClass.Param("@f" + i, cleanedRights[i].field_name));
                            cmd.ExecuteNonQuery();
                        }

                        const string upsert = @"
                            UPDATE company_emergency_policy
                            SET is_enabled = @is_enabled, updated_time = GETDATE(), updated_by = @user_id
                            WHERE company_id = @company_id AND field_name = @field_name AND is_enabled <> @is_enabled;
                            IF NOT EXISTS (SELECT 1 FROM company_emergency_policy WHERE company_id = @company_id AND field_name = @field_name)
                                INSERT INTO company_emergency_policy (company_id, field_name, is_enabled, created_time, created_by)
                                VALUES (@company_id, @field_name, @is_enabled, GETDATE(), @user_id);";

                        foreach (var perm in cleanedRights)
                        {
                            using (SqlCommand cmd = new SqlCommand(upsert, con, tran))
                            {
                                cmd.Parameters.Add(DBClass.Param("@company_id", company_id));
                                cmd.Parameters.Add(DBClass.Param("@field_name", perm.field_name));
                                cmd.Parameters.Add(DBClass.Param("@is_enabled", perm.is_enabled));
                                cmd.Parameters.Add(DBClass.Param("@user_id", AppConfig.UserID));
                                cmd.ExecuteNonQuery();
                            }
                        }

                        tran.Commit();
                    }
                }

                return "{\"success\":true,\"message\":\"Permissions saved successfully.\",\"company_id\":" + company_id + "}";
            }
            catch (Exception ex)
            {
                return "{\"success\":false,\"message\":\"" + ex.Message.Replace("\"", "'") + "\"}";
            }
        }

        [WebMethod]
        public static string DeleteCompanyEmergencyRights(int company_id)
        {
            try
            {
                DBClass.exectueQueryWithParms(new[] { DBClass.Param("@company_id", company_id) },
                    "DELETE FROM company_emergency_policy WHERE company_id = @company_id");
                return "{\"success\":true}";
            }
            catch (Exception ex)
            {
                return "{\"success\":false,\"message\":\"" + ex.Message.Replace("\"", "'") + "\"}";
            }
        }

        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                var total = Convert.ToInt32(DBClass.getDataTable(
                    "SELECT COUNT(DISTINCT company_id) FROM company_emergency_policy").Rows[0][0]);

                var dt = DBClass.getDataTable(@"
                    SELECT DISTINCT c.Company_ID, c.Company_Name
                    FROM company_emergency_policy p
                    JOIN sys_Companys c ON c.Company_ID = p.company_id
                    WHERE c.Company_Name LIKE '%' + @search + '%'",
                    DBClass.Param("@search", searchValue ?? ""));

                var rows = dt.AsEnumerable()
                    .Select(r => new { Company_ID = r.Field<int>("Company_ID"), Company_Name = r.Field<string>("Company_Name") });

                rows = sortColumn == "Company_Name" && sortColumnDirection == "asc"
                    ? rows.OrderBy(a => a.Company_Name)
                    : sortColumn == "Company_Name"
                        ? rows.OrderByDescending(a => a.Company_Name)
                        : rows.OrderByDescending(a => a.Company_ID);

                var list = rows.ToList();

                return new
                {
                    draw = draw,
                    recordsFiltered = list.Count,
                    recordsTotal = total,
                    data = list.Skip(start).Take(length < 0 ? list.Count : length).ToList()
                };
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Policy list", ex);
            }
        }

        [WebMethod]
        public static string GetCompanyDetails(int company_id)
        {
            var company = DBClass.getDataTable("SELECT Company_ID, Company_Name FROM sys_Companys WHERE Company_ID = @company_id",
                DBClass.Param("@company_id", company_id));

            if (company.Rows.Count == 0)
            {
                return JsonConvert.SerializeObject(new
                {
                    Error = "Company not found"
                });
            }

            var rightsList = DBClass.getDataTable("SELECT field_name, is_enabled FROM company_emergency_policy WHERE company_id = @company_id",
                    DBClass.Param("@company_id", company_id))
                .AsEnumerable()
                .Select(r => new
                {
                    field_name = r.Field<string>("field_name"),
                    is_enabled = r.Field<bool>("is_enabled")
                })
                .ToList();

            return JsonConvert.SerializeObject(new
            {
                Company_ID = company.Rows[0]["Company_ID"],
                Company_Name = company.Rows[0]["Company_Name"],
                Rights = rightsList
            });
        }
    }
}
