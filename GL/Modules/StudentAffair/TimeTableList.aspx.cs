using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static PMS.StudentAttendance;

namespace PMS
{
    public partial class TimeTableList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Student = _dbContext.Student_Time_Tables.Count();
                    var Student = from STT in _dbContext.Student_Time_Tables
                                  where ((_dbContext.GetDataValueName("Student Class", STT.Class).Contains(searchValue) || _dbContext.GetDataValueName("Admission Category", STT.Program).Contains(searchValue)
                                  || _dbContext.GetDataValueName("Week", STT.Weeks).Contains(searchValue)))
                                  select new
                                  {                                    
                                      St_id = STT.St_id,
                                      Classname = _dbContext.GetDataValueName("Student Class", STT.Class),
                                      ProgramName = _dbContext.GetDataValueName("Admission Category", STT.Program),
                                      WeekName = _dbContext.GetDataValueName("Week", STT.Weeks),
                                      FirstDate = _dbContext.Student_Time_Table_Details.Where(sd => sd.St_id == STT.St_id).OrderBy(sd => sd.Std_Id).Select(sd => sd.Date).FirstOrDefault(),
                                      LastDate = _dbContext.Student_Time_Table_Details.Where(sd => sd.St_id == STT.St_id).OrderByDescending(sd => sd.Std_Id).Select(sd => sd.Date).FirstOrDefault()
                                  };



                    var FilteredCount = Student.Count();
                    switch (sortColumn)
                    {
                        case "Classname":
                            Student = sortColumnDirection == "asc" ? Student.OrderBy(a => a.Classname) : Student.OrderByDescending(a => a.Classname);
                            break;
                        default:
                            Student = Student.OrderByDescending(a => a.St_id);
                            break;
                    }


                    var StudentList = Student.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Student, data = StudentList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Time Table list", ex);
            }
        }

        [WebMethod]
        public static string DeleteRecord(int Id)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var Delete = DBClass.getField("delete from Student_Time_Table_Detail where St_id= '" + Id + "' ");
            var DeleteMaster = DBClass.getField("delete from Student_Time_Table where St_id= '" + Id + "' ");
            return (Delete);
        }

    }
}