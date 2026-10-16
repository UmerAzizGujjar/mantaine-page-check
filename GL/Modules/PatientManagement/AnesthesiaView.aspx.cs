using System;
using System.Globalization;
using System.Linq;
using System.Web.Services;

namespace PMS.Modules.PatientManagement
{
    public partial class AnesthesiaView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        [WebMethod]
        public static string DeleteRecord(string AnesthesiaID)
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    db.Connection.Open();
                    db.Transaction = db.Connection.BeginTransaction();
                    try
                    {
                        db.Anesthesia_IntraOp_Vitals.DeleteAllOnSubmit(db.Anesthesia_IntraOp_Vitals.Where(x => x.Anesthesia_ID == AnesthesiaID));
                        db.Anesthesia_IntraOps.DeleteAllOnSubmit(db.Anesthesia_IntraOps.Where(x => x.Anesthesia_ID == AnesthesiaID));
                        db.Anesthesia_OpNotes.DeleteAllOnSubmit(db.Anesthesia_OpNotes.Where(x => x.Anesthesia_ID == AnesthesiaID));
                        db.Anesthesia_Histories.DeleteAllOnSubmit(db.Anesthesia_Histories.Where(x => x.Anesthesia_ID == AnesthesiaID));
                        db.Anesthesia_PreOps.DeleteAllOnSubmit(db.Anesthesia_PreOps.Where(x => x.Anesthesia_ID == AnesthesiaID));
                        db.SubmitChanges();
                        db.Transaction.Commit();
                        return "Record deleted";
                    }
                    catch { db.Transaction.Rollback(); throw; }
                }
            }
            catch (Exception ex) { return "error: " + ex.Message; }
        }

        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue, string fromDate, string toDate)
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    int total = db.Anesthesia_PreOps.Count();

                    var records = from a in db.Anesthesia_PreOps
                                  join p in db.Reg_patients on a.Patient_ID equals p.pat_id
                                  where string.IsNullOrEmpty(searchValue)
                                        || a.Anesthesia_ID.Contains(searchValue)
                                        || a.Procedure_Name.Contains(searchValue)
                                        || p.mr_no_sequence.Contains(searchValue)
                                        || p.Full_Name.Contains(searchValue)
                                  select new
                                  {
                                      a.Anesthesia_ID,
                                      MRNo = p.mr_no_sequence ?? "",
                                      Patient_Name = p.Full_Name ?? "",
                                      Procedure_Name = a.Procedure_Name ?? "",
                                      a.Procedure_Date,
                                      HasIntra = db.Anesthesia_IntraOps.Any(i => i.Anesthesia_ID == a.Anesthesia_ID),
                                      HasNotes = db.Anesthesia_OpNotes.Any(n => n.Anesthesia_ID == a.Anesthesia_ID)
                                  };

                    DateTime f, t;
                    if (DateTime.TryParseExact(fromDate, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out f))
                    {
                        DateTime fd = f.Date;
                        records = records.Where(r => r.Procedure_Date >= fd);
                    }
                    if (DateTime.TryParseExact(toDate, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out t))
                    {
                        DateTime td = t.Date.AddDays(1);
                        records = records.Where(r => r.Procedure_Date < td);
                    }

                    int filtered = records.Count();
                    bool asc = sortColumnDirection == "asc";
                    switch (sortColumn)
                    {
                        case "MRNo": records = asc ? records.OrderBy(r => r.MRNo) : records.OrderByDescending(r => r.MRNo); break;
                        case "Patient_Name": records = asc ? records.OrderBy(r => r.Patient_Name) : records.OrderByDescending(r => r.Patient_Name); break;
                        case "Procedure_Name": records = asc ? records.OrderBy(r => r.Procedure_Name) : records.OrderByDescending(r => r.Procedure_Name); break;
                        default: records = asc ? records.OrderBy(r => r.Anesthesia_ID) : records.OrderByDescending(r => r.Anesthesia_ID); break;
                    }

                    var rows = records.Skip(start).Take(length).ToList().Select(r => new
                    {
                        r.Anesthesia_ID,
                        r.MRNo,
                        r.Patient_Name,
                        r.Procedure_Name,
                        Date = r.Procedure_Date.HasValue ? r.Procedure_Date.Value.ToString("dd-MMM-yyyy") : "",
                        Status = r.HasNotes ? "Complete" : (r.HasIntra ? "Intra-op saved" : "Pre-op saved")
                    }).ToList();

                    return new { draw = draw, recordsTotal = total, recordsFiltered = filtered, data = rows };
                }
            }
            catch (Exception ex)
            {
                return new { draw = draw, recordsTotal = 0, recordsFiltered = 0, data = new object[0], error = ex.Message };
            }
        }
    }
}
