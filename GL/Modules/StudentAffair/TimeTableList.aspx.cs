using System;
using System.Linq;
using System.Web.Services;
using System.Web.UI;

namespace PMS
{
    public partial class TimeTableList : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    // 🔹 Build base query
                    var query = from stt in db.Student_Time_Tables
                                select new
                                {
                                    St_id = stt.St_id,
                                    Classname = db.GetDataValueName("Student Class", stt.Class),
                                    ProgramName = db.GetDataValueName("Admission Category", stt.Program),
                                    WeekName = db.GetDataValueName("Week", stt.Weeks),
                                    FirstDate = db.Student_Time_Table_Details
                                                 .Where(d => d.St_id == stt.St_id)
                                                 .OrderBy(d => d.Std_Id)
                                                 .Select(d => d.Date)
                                                 .FirstOrDefault(),
                                    LastDate = db.Student_Time_Table_Details
                                                 .Where(d => d.St_id == stt.St_id)
                                                 .OrderByDescending(d => d.Std_Id)
                                                 .Select(d => d.Date)
                                                 .FirstOrDefault()
                                };

                    // 🔹 Apply search (case-insensitive)
                    if (!string.IsNullOrWhiteSpace(searchValue))
                    {
                        string term = searchValue.Trim().ToLower();
                        query = query.Where(x =>
                            (x.Classname ?? "").ToLower().Contains(term) ||
                            (x.ProgramName ?? "").ToLower().Contains(term) ||
                            (x.WeekName ?? "").ToLower().Contains(term)
                        );
                    }

                    var totalRecords = db.Student_Time_Tables.Count();
                    var filteredCount = query.Count();

                    // 🔹 Sorting — now includes WeekName (✅ your request)
                    switch (sortColumn)
                    {
                        case "Classname":
                            query = sortColumnDirection == "asc"
                                ? query.OrderBy(x => x.Classname)
                                : query.OrderByDescending(x => x.Classname);
                            break;
                        case "ProgramName":
                            query = sortColumnDirection == "asc"
                                ? query.OrderBy(x => x.ProgramName)
                                : query.OrderByDescending(x => x.ProgramName);
                            break;
                        case "WeekName":   // ✅ ADDED — sorts Week column
                            query = sortColumnDirection == "asc"
                                ? query.OrderBy(x => x.WeekName)
                                : query.OrderByDescending(x => x.WeekName);
                            break;
                        default:
                            query = query.OrderByDescending(x => x.St_id);
                            break;
                    }

                    // 🔹 Paging
                    var data = query.Skip(start).Take(length).ToList();

                    return new
                    {
                        draw,
                        recordsTotal = totalRecords,
                        recordsFiltered = filteredCount,
                        data
                    };
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error in ViewList", ex);
            }
        }

        [WebMethod]
        public static string DeleteRecord(int Id)
        {
            using (var db = new DataBaseDataContext())
            {
                // Delete details first
                var details = db.Student_Time_Table_Details.Where(d => d.St_id == Id);
                db.Student_Time_Table_Details.DeleteAllOnSubmit(details);

                // Delete master
                var master = db.Student_Time_Tables.FirstOrDefault(m => m.St_id == Id);
                if (master != null)
                {
                    db.Student_Time_Tables.DeleteOnSubmit(master);
                }

                db.SubmitChanges();
                return "OK";
            }
        }
    }
}