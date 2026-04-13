using Newtonsoft.Json;
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
    public partial class OutPatientPolicy : System.Web.UI.Page
    {
        private const string OutPatientPrefix = "OutPatient_";

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
            public string OutPatient_name { get; set; }
            public bool is_enabled { get; set; }
        }

        [WebMethod]
        public static string SaveCompanyOutPatientRights(int company_id, string company_code, string description, List<FieldPermission> rights)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                try
                {
                    var company = db.sys_Companies.FirstOrDefault(c => c.Company_ID == company_id);
                    if (company == null)
                    {
                        return "{\"success\":false,\"message\":\"Invalid Company ID.\"}";
                    }

                    if (rights == null)
                        rights = new List<FieldPermission>();

                    var cleanedRights = rights
                        .Select(r => new
                        {
                            incoming_name = !string.IsNullOrWhiteSpace(r.OutPatient_name) ? r.OutPatient_name : r.field_name,
                            original = r
                        })
                        .Where(r => !string.IsNullOrWhiteSpace(r.incoming_name))
                        .Select(r => new
                        {
                            field_name = r.incoming_name.Trim().ToLower(),
                            original = r.original
                        })
                        .GroupBy(r => r.field_name)
                        .Select(g => g.First())
                        .ToList();

                    var now = DateTime.Now;
                    var userId = AppConfig.UserID;

                    var currentPolicies = db.company_opd_policies
                        .Where(p => p.company_id == company_id && p.field_name.StartsWith(OutPatientPrefix))
                        .ToList();

                    var currentDict = currentPolicies
                        .ToDictionary(
                            p => p.field_name.Substring(OutPatientPrefix.Length).ToLower(),
                            StringComparer.OrdinalIgnoreCase);

                    var inputFieldNames = cleanedRights.Select(r => r.field_name).ToHashSet();

                    var policiesToDelete = currentPolicies.Where(p => !inputFieldNames.Contains(p.field_name.ToLower()));
                    db.company_opd_policies.DeleteAllOnSubmit(policiesToDelete);

                    foreach (var item in cleanedRights)
                    {
                        string normalizedFieldName = item.field_name;
                        var perm = item.original;

                        if (currentDict.TryGetValue(normalizedFieldName, out var existingPolicy))
                        {
                            bool changed = false;

                            if (existingPolicy.is_enabled != perm.is_enabled)
                            {
                                existingPolicy.is_enabled = perm.is_enabled;
                                changed = true;
                            }

                            if (changed)
                            {
                                existingPolicy.updated_time = now;
                                existingPolicy.updated_by = userId;
                            }
                        }
                        else
                        {
                            // INSERT new
                            var newPolicy = new company_opd_policy
                            {
                                company_id = company_id,
                                field_name = OutPatientPrefix + normalizedFieldName,
                                is_enabled = perm.is_enabled,
                                created_time = now,
                                created_by = userId,
                                updated_time = null,
                                updated_by = null
                            };
                            db.company_opd_policies.InsertOnSubmit(newPolicy);
                        }
                    }

                    db.SubmitChanges();

                    return "{\"success\":true,\"message\":\"Permissions saved successfully.\",\"company_id\":" + company_id + "}";
                }
                catch (Exception ex)
                {
                    return "{\"success\":false,\"message\":\"" + ex.Message.Replace("\"", "'") + "\"}";
                }
            }
        }

        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Policy = _dbContext.company_opd_policies.Count(a => a.field_name.StartsWith(OutPatientPrefix));

                    var policy = (from a in _dbContext.company_opd_policies
                                  join c in _dbContext.sys_Companies on a.company_id equals c.Company_ID
                                  where (a.field_name.StartsWith(OutPatientPrefix) && c.Company_Name.Contains(searchValue))
                                  select new
                                  {
                                      Company_ID = a.company_id,
                                      Company_Name = c.Company_Name
                                  })
                                  .Distinct();

                    var FilteredCount = policy.Count();

                    switch (sortColumn)
                    {
                        case "Company_ID":
                            policy = sortColumnDirection == "asc"
                                ? policy.OrderBy(a => a.Company_ID)
                                : policy.OrderByDescending(a => a.Company_ID);
                            break;
                        default:
                            policy = policy.OrderByDescending(a => a.Company_ID);
                            break;
                    }

                    var PolicyList = policy.Skip(start).Take(length).ToList();

                    var jsonData = new
                    {
                        draw = draw,
                        recordsFiltered = FilteredCount,
                        recordsTotal = Total_Policy,
                        data = PolicyList
                    };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Policy list", ex);
            }
        }

        [WebMethod]
        public static string GetCompanyDetails(int company_id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                // Get company name from sys_Companys
                var company = db.sys_Companies
                    .Where(c => c.Company_ID == company_id)
                    .Select(c => new
                    {
                        c.Company_ID,
                        c.Company_Name
                    })
                    .FirstOrDefault();

                if (company == null)
                {
                    return JsonConvert.SerializeObject(new
                    {
                        Error = "Company not found"
                    });
                }

                var rightsList = db.company_opd_policies
                    .Where(r => r.company_id == company_id && r.field_name.StartsWith(OutPatientPrefix))
                    .Select(r => new
                    {
                        r.field_name,
                        r.is_enabled
                    })
                    .ToList()
                    .Select(r => new
                    {
                        field_name = r.field_name.Substring(OutPatientPrefix.Length),
                        r.is_enabled
                    })
                    .ToList();

                return JsonConvert.SerializeObject(new
                {
                    company.Company_ID,
                    company.Company_Name,
                    Rights = rightsList
                });
            }
        }


    }
}