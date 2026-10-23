using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Text.RegularExpressions;
using System.Web.Services;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace PMS.Modules.Lab
{
    /// <summary>
    /// Mammography Patient History form (one row per visit in Lab_Mammography_History).
    /// The page script sends column-named JSON; only real, non-system columns of the entity are applied.
    /// </summary>
    public partial class MammographyHistory : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        private static readonly HashSet<string> SystemColumns = new HashSet<string>
        {
            "Mammo_ID", "Patient_ID", "Company_ID", "Book_ID", "Created_By", "Created_Date", "Modified_By", "Modified_Date"
        };

        private static string Result(bool ok, string msg, object extra = null)
        {
            return JsonConvert.SerializeObject(new { ok = ok, msg = msg, data = extra });
        }

        // ---------- value conversion ----------
        private static object ConvertValue(JToken tok, PropertyInfo prop)
        {
            Type type = Nullable.GetUnderlyingType(prop.PropertyType) ?? prop.PropertyType;
            string s = (tok == null || tok.Type == JTokenType.Null) ? null : tok.ToString().Trim();
            if (string.IsNullOrEmpty(s)) return null;

            if (type == typeof(string))
            {
                var col = (System.Data.Linq.Mapping.ColumnAttribute)prop.GetCustomAttributes(typeof(System.Data.Linq.Mapping.ColumnAttribute), false).First();
                Match m = Regex.Match(col.DbType ?? "", @"NVarChar\((\d+)\)", RegexOptions.IgnoreCase);
                if (m.Success) { int max = int.Parse(m.Groups[1].Value); if (s.Length > max) s = s.Substring(0, max); }
                return s;
            }
            if (type == typeof(int)) { int i; return int.TryParse(s, NumberStyles.Integer, CultureInfo.InvariantCulture, out i) ? (object)i : null; }
            if (type == typeof(bool)) return s == "1" || s.Equals("true", StringComparison.OrdinalIgnoreCase);
            if (type == typeof(DateTime))
            {
                DateTime dt;
                if (DateTime.TryParseExact(s, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out dt)) return dt;
                return DateTime.TryParse(s, CultureInfo.InvariantCulture, DateTimeStyles.None, out dt) ? (object)dt : null;
            }
            return null;
        }

        private static bool IsColumn(PropertyInfo p)
        {
            return p.CanWrite && p.GetCustomAttributes(typeof(System.Data.Linq.Mapping.ColumnAttribute), false).Length > 0;
        }

        /// <summary>Copies every posted column that exists on the entity (except system columns).</summary>
        private static void Apply(object entity, JObject data)
        {
            foreach (PropertyInfo p in entity.GetType().GetProperties())
            {
                if (!IsColumn(p) || SystemColumns.Contains(p.Name)) continue;
                JToken tok;
                if (!data.TryGetValue(p.Name, out tok)) continue;
                p.SetValue(entity, ConvertValue(tok, p), null);
            }
        }

        private static Dictionary<string, object> ToDict(object entity)
        {
            var d = new Dictionary<string, object>();
            foreach (PropertyInfo p in entity.GetType().GetProperties())
            {
                if (!IsColumn(p) || p.Name == "Created_By" || p.Name == "Modified_By") continue;
                object v = p.GetValue(entity, null);
                if (v is DateTime) v = ((DateTime)v).ToString("yyyy-MM-dd");
                d[p.Name] = v;
            }
            return d;
        }

        // ---------- lookups ----------
        [WebMethod]
        public static string GetLookups()
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var doctors = db.HR_Employees.Where(e => e.Resign_Date == null && e.IsDoctor == true)
                                    .OrderBy(e => e.Emp_Name).Select(e => e.Emp_Name).ToList();
                    var staff = db.HR_Employees.Where(e => e.Resign_Date == null)
                                  .OrderBy(e => e.Emp_Name).Select(e => new { id = e.Emp_ID, name = e.Emp_Name }).ToList();
                    return Result(true, "", new { doctors = doctors, staff = staff });
                }
            }
            catch (Exception ex) { return Result(false, ex.Message); }
        }

        [WebMethod]
        public static string SearchPatients(string searchText)
        {
            try
            {
                searchText = (searchText ?? "").Trim();
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var q = db.Reg_patients.Where(p => p.iscancel != true);
                    if (searchText.Length > 0)
                        q = q.Where(p => p.Full_Name.Contains(searchText) || p.mr_no_sequence.Contains(searchText) || p.Father_Name.Contains(searchText)
                                      || p.NIC.Contains(searchText) || p.Mobile1.Contains(searchText));
                    var list = q.OrderByDescending(p => p.pat_id).Take(50)
                                .Select(p => new { PatientId = p.pat_id, MRNo = p.mr_no_sequence ?? "", Name = p.Full_Name ?? "", Father = p.Father_Name ?? "", NIC = p.NIC ?? "", Contact = p.Mobile1 ?? "" })
                                .ToList();
                    return Result(true, "", list);
                }
            }
            catch (Exception ex) { return Result(false, ex.Message); }
        }

        private static object PatientBrief(DataBaseDataContext db, int patId)
        {
            var p = db.Reg_patients.Where(x => x.pat_id == patId)
                      .Select(x => new { x.pat_id, MR = x.mr_no_sequence, x.Full_Name, x.Age_years, x.Gender, x.Mobile1 }).FirstOrDefault();
            if (p == null) return null;
            string gender = db.ExecuteQuery<string>("select dbo.GetDataValueName('Gender', {0})", p.Gender ?? "").FirstOrDefault();
            return new { PatientId = p.pat_id, MRNo = p.MR ?? "", Name = p.Full_Name ?? "", Age = p.Age_years ?? "", Gender = string.IsNullOrEmpty(gender) ? (p.Gender ?? "") : gender, Contact = p.Mobile1 ?? "" };
        }

        [WebMethod]
        public static string GetPatient(int patientId)
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var p = PatientBrief(db, patientId);
                    return p == null ? Result(false, "Patient not found") : Result(true, "", p);
                }
            }
            catch (Exception ex) { return Result(false, ex.Message); }
        }

        // ---------- load / save ----------
        [WebMethod]
        public static string GetRecord(int mammoId)
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var rec = db.Lab_Mammography_Histories.FirstOrDefault(x => x.Mammo_ID == mammoId);
                    if (rec == null) return Result(false, "Mammography record not found");
                    return Result(true, "", new { MammoId = rec.Mammo_ID, Patient = PatientBrief(db, rec.Patient_ID), Record = ToDict(rec) });
                }
            }
            catch (Exception ex) { return Result(false, ex.Message); }
        }

        [WebMethod]
        public static string SaveRecord(string data)
        {
            try
            {
                var d = JObject.Parse(data);
                int mammoId = (int?)d["MammoId"] ?? 0;
                int patientId = (int?)d["PatientId"] ?? 0;
                if (patientId <= 0) return Result(false, "Please select a patient first");
                var miss = new[] { "Exam_Date", "Technologist_ID" }.Where(k => string.IsNullOrWhiteSpace((string)d[k])).ToList();
                if (miss.Count > 0) return Result(false, "Please fill: " + string.Join(", ", miss.Select(k => k.Replace("_ID", "").Replace('_', ' '))));

                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    if (!db.Reg_patients.Any(p => p.pat_id == patientId)) return Result(false, "Patient not found");

                    Lab_Mammography_History rec = mammoId > 0 ? db.Lab_Mammography_Histories.FirstOrDefault(x => x.Mammo_ID == mammoId) : null;
                    bool isNew = rec == null;
                    if (isNew)
                    {
                        rec = new Lab_Mammography_History
                        {
                            Patient_ID = patientId,
                            Company_ID = AppConfig.Company_ID, Book_ID = AppConfig.Book_ID,
                            Created_By = AppConfig.UserID, Created_Date = DateTime.Now
                        };
                        db.Lab_Mammography_Histories.InsertOnSubmit(rec);
                    }
                    else
                    {
                        if (rec.Patient_ID != patientId) return Result(false, "This record belongs to another patient");
                        rec.Modified_By = AppConfig.UserID; rec.Modified_Date = DateTime.Now;
                    }
                    Apply(rec, d);
                    db.SubmitChanges();
                    return Result(true, isNew ? "saved" : "updated", new { MammoId = rec.Mammo_ID });
                }
            }
            catch (Exception ex) { return Result(false, ex.Message); }
        }
    }
}
