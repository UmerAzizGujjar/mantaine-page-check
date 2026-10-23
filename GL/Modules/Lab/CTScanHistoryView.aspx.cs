using System;
using System.Globalization;
using System.Linq;
using System.Web.Services;

namespace PMS.Modules.Lab
{
    public partial class CTScanHistoryView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        [WebMethod]
        public static string DeleteRecord(int CTID)
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    db.Lab_CT_Histories.DeleteAllOnSubmit(db.Lab_CT_Histories.Where(x => x.CT_ID == CTID));
                    db.SubmitChanges();
                    return "Record deleted";
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
                    int companyId = AppConfig.Company_ID;
                    int total = db.Lab_CT_Histories.Count(x => x.Company_ID == companyId);

                    var records = from c in db.Lab_CT_Histories
                                  join p in db.Reg_patients on c.Patient_ID equals p.pat_id
                                  where c.Company_ID == companyId
                                        && (string.IsNullOrEmpty(searchValue)
                                            || p.mr_no_sequence.Contains(searchValue)
                                            || p.Full_Name.Contains(searchValue)
                                            || c.Referring_Doctor.Contains(searchValue)
                                            || c.Chief_Complaint.Contains(searchValue))
                                  select new
                                  {
                                      c.CT_ID,
                                      MRNo = p.mr_no_sequence ?? "",
                                      Patient_Name = p.Full_Name ?? "",
                                      Referring_Doctor = c.Referring_Doctor ?? "",
                                      Chief_Complaint = c.Chief_Complaint ?? "",
                                      c.Exam_Date,
                                      Radiologist = db.HR_Employees.Where(e => e.Emp_ID == c.Radiologist_ID).Select(e => e.Emp_Name).FirstOrDefault()
                                  };

                    DateTime f, t;
                    if (DateTime.TryParseExact(fromDate, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out f))
                    {
                        DateTime fd = f.Date;
                        records = records.Where(r => r.Exam_Date >= fd);
                    }
                    if (DateTime.TryParseExact(toDate, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out t))
                    {
                        DateTime td = t.Date.AddDays(1);
                        records = records.Where(r => r.Exam_Date < td);
                    }

                    int filtered = records.Count();
                    bool asc = sortColumnDirection == "asc";
                    switch (sortColumn)
                    {
                        case "MRNo": records = asc ? records.OrderBy(r => r.MRNo) : records.OrderByDescending(r => r.MRNo); break;
                        case "Patient_Name": records = asc ? records.OrderBy(r => r.Patient_Name) : records.OrderByDescending(r => r.Patient_Name); break;
                        case "Referring_Doctor": records = asc ? records.OrderBy(r => r.Referring_Doctor) : records.OrderByDescending(r => r.Referring_Doctor); break;
                        case "Exam_Date": records = asc ? records.OrderBy(r => r.Exam_Date) : records.OrderByDescending(r => r.Exam_Date); break;
                        default: records = asc ? records.OrderBy(r => r.CT_ID) : records.OrderByDescending(r => r.CT_ID); break;
                    }

                    var rows = records.Skip(start).Take(length).ToList().Select(r => new
                    {
                        r.CT_ID,
                        r.MRNo,
                        r.Patient_Name,
                        r.Referring_Doctor,
                        Chief_Complaint = r.Chief_Complaint.Length > 80 ? r.Chief_Complaint.Substring(0, 80) + "..." : r.Chief_Complaint,
                        Date = r.Exam_Date.HasValue ? r.Exam_Date.Value.ToString("dd-MMM-yyyy") : "",
                        Radiologist = r.Radiologist ?? ""
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
