using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web.Services;

namespace PMS.Modules.Lab
{
    public partial class MammographyHistoryView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        [WebMethod]
        public static string DeleteRecord(int MammoID)
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    db.Lab_Mammography_Histories.DeleteAllOnSubmit(db.Lab_Mammography_Histories.Where(x => x.Mammo_ID == MammoID));
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
                    int total = db.Lab_Mammography_Histories.Count(x => x.Company_ID == companyId);

                    var records = from m in db.Lab_Mammography_Histories
                                  join p in db.Reg_patients on m.Patient_ID equals p.pat_id
                                  where m.Company_ID == companyId
                                        && (string.IsNullOrEmpty(searchValue)
                                            || p.mr_no_sequence.Contains(searchValue)
                                            || p.Full_Name.Contains(searchValue)
                                            || m.Referring_Doctor.Contains(searchValue))
                                  select new
                                  {
                                      m.Mammo_ID,
                                      MRNo = p.mr_no_sequence ?? "",
                                      Patient_Name = p.Full_Name ?? "",
                                      Referring_Doctor = m.Referring_Doctor ?? "",
                                      m.Exam_Date,
                                      Technologist = db.HR_Employees.Where(e => e.Emp_ID == m.Technologist_ID).Select(e => e.Emp_Name).FirstOrDefault(),
                                      m.Reason_Screening, m.Reason_FollowUp, m.Reason_Lump, m.Reason_Nipple_Discharge,
                                      m.Reason_Skin_Changes, m.Reason_Implant, m.Reason_Pain, m.Reason_Other
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
                        default: records = asc ? records.OrderBy(r => r.Mammo_ID) : records.OrderByDescending(r => r.Mammo_ID); break;
                    }

                    var rows = records.Skip(start).Take(length).ToList().Select(r =>
                    {
                        var reasons = new List<string>();
                        if (r.Reason_Screening == true) reasons.Add("Screening");
                        if (r.Reason_FollowUp == true) reasons.Add("Follow-Up");
                        if (r.Reason_Lump == true) reasons.Add("Lump");
                        if (r.Reason_Nipple_Discharge == true) reasons.Add("Nipple Discharge");
                        if (r.Reason_Skin_Changes == true) reasons.Add("Skin Changes");
                        if (r.Reason_Implant == true) reasons.Add("Implant");
                        if (r.Reason_Pain == true) reasons.Add("Pain");
                        if (!string.IsNullOrEmpty(r.Reason_Other)) reasons.Add(r.Reason_Other);
                        return new
                        {
                            r.Mammo_ID,
                            r.MRNo,
                            r.Patient_Name,
                            r.Referring_Doctor,
                            Reason = string.Join(", ", reasons),
                            Date = r.Exam_Date.HasValue ? r.Exam_Date.Value.ToString("dd-MMM-yyyy") : "",
                            Technologist = r.Technologist ?? ""
                        };
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
