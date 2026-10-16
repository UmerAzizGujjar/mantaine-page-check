using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Text.RegularExpressions;
using System.Web.Services;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace PMS.Modules.PatientManagement
{
    /// <summary>
    /// Anesthesia record in three steps that must be saved in order:
    /// 1 Pre-op assessment, 2 Intra-operative sheet, 3 Operation notes.
    /// The page script sends column-named JSON; only real, non-system columns of the entity are applied.
    /// </summary>
    public partial class AnesthesiaForm : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        private static readonly HashSet<string> SystemColumns = new HashSet<string>
        {
            "PreOp_ID", "IntraOp_ID", "OpNote_ID", "History_ID", "Vital_ID", "Anesthesia_ID", "Patient_ID", "In_Patient_ID",
            "Company_ID", "Book_ID", "Created_By", "Created_Date", "Modified_By", "Modified_Date"
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
            if (type == typeof(decimal)) { decimal d; return decimal.TryParse(s, NumberStyles.Number, CultureInfo.InvariantCulture, out d) ? (object)d : null; }
            if (type == typeof(bool)) return s == "1" || s.Equals("true", StringComparison.OrdinalIgnoreCase);
            if (type == typeof(DateTime))
            {
                DateTime dt;
                if (DateTime.TryParseExact(s, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out dt)) return dt;
                return DateTime.TryParse(s, CultureInfo.InvariantCulture, DateTimeStyles.None, out dt) ? (object)dt : null;
            }
            if (type == typeof(TimeSpan)) { TimeSpan ts; return TimeSpan.TryParse(s, CultureInfo.InvariantCulture, out ts) ? (object)ts : null; }
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
                if (v is DateTime) v = ((DateTime)v).ToString(p.Name.EndsWith("_Date") && p.Name.StartsWith("Created") ? "yyyy-MM-dd HH:mm" : "yyyy-MM-dd");
                else if (v is TimeSpan) v = ((TimeSpan)v).ToString(@"hh\:mm");
                d[p.Name] = v;
            }
            return d;
        }

        private static string Missing(JObject d, params string[] keys)
        {
            var miss = keys.Where(k => string.IsNullOrWhiteSpace((string)d[k])).ToList();
            return miss.Count == 0 ? null : string.Join(", ", miss.Select(k => k.Replace("_ID", "").Replace('_', ' ')));
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
                                    .OrderBy(e => e.Emp_Name).Select(e => new { id = e.Emp_ID, name = e.Emp_Name }).ToList();
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
                    // Only patients who are admitted right now (an In_Patient row that is not discharged).
                    int companyId = AppConfig.Company_ID;
                    var q = from p in db.Reg_patients
                            join ip in db.In_Patients on p.pat_id equals ip.Patient_ID
                            where (ip.Discharge == false || ip.Discharge == null) && ip.Company_ID == companyId
                            select new { p, ip };
                    if (searchText.Length > 0)
                        q = q.Where(x => x.p.Full_Name.Contains(searchText) || x.p.mr_no_sequence.Contains(searchText) || x.p.Father_Name.Contains(searchText)
                                      || x.p.NIC.Contains(searchText) || x.p.Mobile1.Contains(searchText));
                    var rows = q.OrderByDescending(x => x.ip.Admission_Date).Take(50)
                                .Select(x => new { PatientId = x.p.pat_id, MRNo = x.p.mr_no_sequence ?? "", Name = x.p.Full_Name ?? "", Father = x.p.Father_Name ?? "", NIC = x.p.NIC ?? "", Contact = x.p.Mobile1 ?? "", x.ip.Admission_Date })
                                .ToList();
                    var list = rows.Select(r => new { r.PatientId, r.MRNo, r.Name, r.Father, r.NIC, r.Contact, AdmittedOn = r.Admission_Date.HasValue ? r.Admission_Date.Value.ToString("dd-MMM-yyyy") : "" }).ToList();
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

        // ---------- load a saved case ----------
        [WebMethod]
        public static string GetCase(string anesthesiaId)
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var pre = db.Anesthesia_PreOps.FirstOrDefault(x => x.Anesthesia_ID == anesthesiaId);
                    if (pre == null) return Result(false, "Anesthesia record not found");
                    var intra = db.Anesthesia_IntraOps.FirstOrDefault(x => x.Anesthesia_ID == anesthesiaId);
                    var notes = db.Anesthesia_OpNotes.FirstOrDefault(x => x.Anesthesia_ID == anesthesiaId);
                    var history = db.Anesthesia_Histories.Where(x => x.Anesthesia_ID == anesthesiaId).OrderBy(x => x.History_ID)
                                    .Select(x => new { Item = x.Item_Name, Present = x.Is_Present ?? false, Notes = x.Notes }).ToList();
                    var vitals = db.Anesthesia_IntraOp_Vitals.Where(x => x.Anesthesia_ID == anesthesiaId).OrderBy(x => x.Chart_Time).ThenBy(x => x.Vital_ID).ToList()
                                   .Select(ToDict).ToList();
                    return Result(true, "", new
                    {
                        AnesthesiaId = anesthesiaId,
                        Patient = PatientBrief(db, pre.Patient_ID),
                        PreOp = ToDict(pre),
                        History = history,
                        IntraOp = intra == null ? null : ToDict(intra),
                        Vitals = vitals,
                        OpNotes = notes == null ? null : ToDict(notes)
                    });
                }
            }
            catch (Exception ex) { return Result(false, ex.Message); }
        }

        // ---------- step 1 ----------
        /// <summary>The patient's current (not discharged) admission in this company, or null.</summary>
        private static int? CurrentAdmission(DataBaseDataContext db, int patientId)
        {
            int companyId = AppConfig.Company_ID;
            return db.In_Patients
                     .Where(ip => ip.Patient_ID == patientId && (ip.Discharge == false || ip.Discharge == null) && ip.Company_ID == companyId)
                     .OrderByDescending(ip => ip.Admission_Date)
                     .Select(ip => (int?)ip.In_Patient_ID).FirstOrDefault();
        }

        private static string NextId(DataBaseDataContext db)
        {
            string prefix = "ANE-" + DateTime.Now.ToString("yyyyMMdd") + "-";
            int next = db.ExecuteQuery<int>(
                "select isnull(max(cast(right(Anesthesia_ID, 4) as int)), 0) + 1 from Anesthesia_PreOp with (updlock, holdlock) where Anesthesia_ID like {0}",
                prefix + "%").FirstOrDefault();
            return prefix + next.ToString("D4");
        }

        [WebMethod]
        public static string SavePreOp(string data)
        {
            try
            {
                var d = JObject.Parse(data);
                string id = ((string)d["AnesthesiaId"] ?? "").Trim();
                int patientId = (int?)d["PatientId"] ?? 0;
                if (patientId <= 0) return Result(false, "Please select a patient first");
                string miss = Missing(d, "Procedure_Date", "Procedure_Name", "Anaesthetist_ID", "ASA_Status", "Assessed_By_ID", "Assessment_Date");
                if (miss != null) return Result(false, "Please fill: " + miss);

                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    if (!db.Reg_patients.Any(p => p.pat_id == patientId)) return Result(false, "Patient not found");
                    db.Connection.Open();
                    db.Transaction = db.Connection.BeginTransaction();
                    try
                    {
                        Anesthesia_PreOp rec = id == "" ? null : db.Anesthesia_PreOps.FirstOrDefault(x => x.Anesthesia_ID == id);
                        bool isNew = rec == null;
                        if (isNew)
                        {
                            // The record is tied to the patient's current admission (In_Patient_ID).
                            int? inPatientId = CurrentAdmission(db, patientId);
                            if (inPatientId == null) { db.Transaction.Rollback(); return Result(false, "This patient is not currently admitted"); }
                            id = NextId(db);
                            rec = new Anesthesia_PreOp
                            {
                                Anesthesia_ID = id, Patient_ID = patientId, In_Patient_ID = inPatientId,
                                Company_ID = AppConfig.Company_ID, Book_ID = AppConfig.Book_ID,
                                Created_By = AppConfig.UserID, Created_Date = DateTime.Now
                            };
                            db.Anesthesia_PreOps.InsertOnSubmit(rec);
                        }
                        else
                        {
                            if (rec.Patient_ID != patientId) { db.Transaction.Rollback(); return Result(false, "This record belongs to another patient"); }
                            if (rec.In_Patient_ID == null) rec.In_Patient_ID = CurrentAdmission(db, patientId);
                            rec.Modified_By = AppConfig.UserID; rec.Modified_Date = DateTime.Now;
                        }
                        Apply(rec, d);

                        db.Anesthesia_Histories.DeleteAllOnSubmit(db.Anesthesia_Histories.Where(h => h.Anesthesia_ID == id));
                        var hist = d["History"] as JArray;
                        if (hist != null)
                        {
                            foreach (JObject h in hist.OfType<JObject>())
                            {
                                string item = ((string)h["Item"] ?? "").Trim();
                                if (item == "") continue;
                                bool present = (bool?)h["Present"] ?? false;
                                string notes = ((string)h["Notes"] ?? "").Trim();
                                if (!present && notes == "") continue;
                                db.Anesthesia_Histories.InsertOnSubmit(new Anesthesia_History
                                {
                                    Anesthesia_ID = id,
                                    Item_Name = item.Length > 60 ? item.Substring(0, 60) : item,
                                    Is_Present = present,
                                    Notes = notes == "" ? null : (notes.Length > 300 ? notes.Substring(0, 300) : notes)
                                });
                            }
                        }
                        db.SubmitChanges();
                        db.Transaction.Commit();
                        return Result(true, isNew ? "saved" : "updated", new { AnesthesiaId = id });
                    }
                    catch { db.Transaction.Rollback(); throw; }
                }
            }
            catch (Exception ex) { return Result(false, ex.Message); }
        }

        // ---------- step 2 ----------
        [WebMethod]
        public static string SaveIntraOp(string data)
        {
            try
            {
                var d = JObject.Parse(data);
                string id = ((string)d["AnesthesiaId"] ?? "").Trim();
                string miss = Missing(d, "Surgeon_ID", "Type_Of_Anesthesia");
                if (miss != null) return Result(false, "Please fill: " + miss);
                var vitalRows = (d["Vitals"] as JArray ?? new JArray()).OfType<JObject>()
                                  .Where(v => !string.IsNullOrWhiteSpace((string)v["Chart_Time"])).ToList();
                if (vitalRows.Count == 0) return Result(false, "Please add at least one monitoring reading with a time");

                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var pre = db.Anesthesia_PreOps.FirstOrDefault(x => x.Anesthesia_ID == id);
                    if (pre == null) return Result(false, "Please save Step 1 first");
                    db.Connection.Open();
                    db.Transaction = db.Connection.BeginTransaction();
                    try
                    {
                        var rec = db.Anesthesia_IntraOps.FirstOrDefault(x => x.Anesthesia_ID == id);
                        bool isNew = rec == null;
                        if (isNew)
                        {
                            rec = new Anesthesia_IntraOp
                            {
                                Anesthesia_ID = id, Patient_ID = pre.Patient_ID, In_Patient_ID = pre.In_Patient_ID,
                                Company_ID = AppConfig.Company_ID, Book_ID = AppConfig.Book_ID,
                                Created_By = AppConfig.UserID, Created_Date = DateTime.Now
                            };
                            db.Anesthesia_IntraOps.InsertOnSubmit(rec);
                        }
                        else { rec.Modified_By = AppConfig.UserID; rec.Modified_Date = DateTime.Now; }
                        Apply(rec, d);

                        db.Anesthesia_IntraOp_Vitals.DeleteAllOnSubmit(db.Anesthesia_IntraOp_Vitals.Where(v => v.Anesthesia_ID == id));
                        foreach (JObject row in vitalRows)
                        {
                            var v = new Anesthesia_IntraOp_Vital { Anesthesia_ID = id, Created_Date = DateTime.Now };
                            Apply(v, row);
                            db.Anesthesia_IntraOp_Vitals.InsertOnSubmit(v);
                        }
                        db.SubmitChanges();
                        db.Transaction.Commit();
                        return Result(true, isNew ? "saved" : "updated", new { AnesthesiaId = id });
                    }
                    catch { db.Transaction.Rollback(); throw; }
                }
            }
            catch (Exception ex) { return Result(false, ex.Message); }
        }

        // ---------- step 3 ----------
        [WebMethod]
        public static string SaveOpNotes(string data)
        {
            try
            {
                var d = JObject.Parse(data);
                string id = ((string)d["AnesthesiaId"] ?? "").Trim();
                string miss = Missing(d, "Op_Date", "Procedure_Name", "Surgeon_ID", "Anaesthetist_ID");
                if (miss != null) return Result(false, "Please fill: " + miss);

                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var pre = db.Anesthesia_PreOps.FirstOrDefault(x => x.Anesthesia_ID == id);
                    if (pre == null) return Result(false, "Please save Step 1 first");
                    if (!db.Anesthesia_IntraOps.Any(x => x.Anesthesia_ID == id)) return Result(false, "Please save Step 2 first");

                    var rec = db.Anesthesia_OpNotes.FirstOrDefault(x => x.Anesthesia_ID == id);
                    bool isNew = rec == null;
                    if (isNew)
                    {
                        rec = new Anesthesia_OpNote
                        {
                            Anesthesia_ID = id, Patient_ID = pre.Patient_ID, In_Patient_ID = pre.In_Patient_ID,
                            Company_ID = AppConfig.Company_ID, Book_ID = AppConfig.Book_ID,
                            Created_By = AppConfig.UserID, Created_Date = DateTime.Now
                        };
                        db.Anesthesia_OpNotes.InsertOnSubmit(rec);
                    }
                    else { rec.Modified_By = AppConfig.UserID; rec.Modified_Date = DateTime.Now; }
                    Apply(rec, d);
                    db.SubmitChanges();
                    return Result(true, isNew ? "saved" : "updated", new { AnesthesiaId = id });
                }
            }
            catch (Exception ex) { return Result(false, ex.Message); }
        }
    }
}
