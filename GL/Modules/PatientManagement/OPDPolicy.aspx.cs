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
    public partial class OPDPolicy : System.Web.UI.Page
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
        public static string SaveCompanyOpdRights(int company_id, string company_code, string description, List<FieldPermission> rights)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                try
                {
                    // 1. Validate company
                    var company = db.sys_Companies.FirstOrDefault(c => c.Company_ID == company_id);
                    if (company == null)
                    {
                        return "{\"success\":false,\"message\":\"Invalid Company ID.\"}";
                    }

                    // 2. Delete old policies and commit before insert
                    var oldPolicies = db.company_opd_policies.Where(p => p.company_id == company_id);
                    db.company_opd_policies.DeleteAllOnSubmit(oldPolicies);
                    db.SubmitChanges(); // Commit deletes first to avoid unique constraint violation

                    // 3. Insert new rights (remove duplicates & empty names)
                    if (rights != null && rights.Count > 0)
                    {
                        DateTime now = DateTime.Now;

                        // Remove duplicates by field_name
                        var uniqueRights = rights
                            .Where(r => !string.IsNullOrEmpty(r.field_name))
                            .GroupBy(r => r.field_name.ToLower().Trim()) // case-insensitive compare
                            .Select(g => g.First())
                            .ToList();

                        foreach (var perm in uniqueRights)
                        {
                            var policy = new company_opd_policy
                            {
                                company_id = company_id,
                                field_name = perm.field_name.Trim(),
                                is_enabled = perm.is_enabled,
                                created_time = now,
                                created_by = AppConfig.UserID,
                                updated_time = null,
                                updated_by = null
                            };
                            db.company_opd_policies.InsertOnSubmit(policy);
                        }

                        db.SubmitChanges(); // Commit inserts
                    }

                    return "{\"success\":true,\"message\":\"Permissions saved successfully.\",\"company_id\":" + company_id + "}";
                }
                catch (Exception ex)
                {
                    return "{\"success\":false,\"message\":\"" + ex.Message.Replace("\"", "'") + "\"}";
                }
            }
        }

    }
}