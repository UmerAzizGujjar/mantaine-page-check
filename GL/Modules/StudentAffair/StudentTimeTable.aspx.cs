using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class StudentTimeTable : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string GetProgram()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var valuset = DBClass.GetValueSet("Admission Category");
            return (new JavaScriptSerializer()).Serialize(valuset);
        }
        [WebMethod]
        public static string GetClass()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var valuset = DBClass.GetValueSet("Student Class");
            return (new JavaScriptSerializer()).Serialize(valuset);
        }
        [WebMethod]
        public static string GetVenues()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Ven = DBClass.GetValueSet("Venue");
            return (new JavaScriptSerializer()).Serialize(Ven);
        }


        [WebMethod]
        public static string GetTeachers()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Teacher = DBClass.GetValueSet("Teacher");
            return (new JavaScriptSerializer()).Serialize(Teacher);
        }

        [WebMethod]
        public static string GetWeek()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var valuset = DBClass.GetValueSet("Week");
            return (new JavaScriptSerializer()).Serialize(valuset);
        }
        [WebMethod]
        public static string GetSubjects()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var valuset = DBClass.GetValueSet("Subject Type");
            return (new JavaScriptSerializer()).Serialize(valuset);
        }
        [WebMethod]
        public static string GetBatch()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var valuset = DBClass.GetValueSet("Batch");
            return (new JavaScriptSerializer()).Serialize(valuset);
        }
        [WebMethod]
        public static string GetGroups()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var valuset = DBClass.GetValueSet("Group");
            return (new JavaScriptSerializer()).Serialize(valuset);
        }


        [WebMethod]
        public static string GetSubj(string program, string classs)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            string data = string.Empty;
            var listItems = (from s in db.Subject_Definitions
                             join sd in db.Subject_Definition_Lists on s.subject_Id equals sd.Subject_ID
                             where s.Program == program && s.Class == classs
                             select new
                             {
                                 sd.Subject_Detail_ID,
                                 sd.Subject_Name

                             }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);
        }
        [WebMethod]
        public static string SaveTimeTable(string StdTimetable, string btnSave)
        {

            string subject = "";
            Student_Time_Table subjectDef = new Student_Time_Table();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer serialize = new JavaScriptSerializer();
            var subjects = serialize.Deserialize<MasterList>(StdTimetable);

            if (btnSave == "Update")
            {
                var lstItems = (from a in db.Student_Time_Tables
                                where a.St_id == Convert.ToInt32(subjects.Subject_id)
                                select a).FirstOrDefault();

                lstItems.Program = subjects.program;
                lstItems.Class = subjects.ddlClass;
                lstItems.Weeks = subjects.ddlWeek;
                lstItems.UpdatedBy = AppConfig.UserID;
                lstItems.UpdateTime = DateTime.Now;

                db.SubmitChanges();
                subject = lstItems.St_id.ToString();
            }
            else
            {
                subjectDef.Program = subjects.program;
                subjectDef.Class = subjects.ddlClass;
                subjectDef.Weeks = subjects.ddlWeek;
                subjectDef.CreatedBy = AppConfig.UserID;
                subjectDef.CreatedTime = DateTime.Now;

                db.Student_Time_Tables.InsertOnSubmit(subjectDef);
                db.SubmitChanges();
                subject = subjectDef.St_id.ToString();

            }
            if (btnSave == "Update")
            {
                List<Student_Time_Table_Detail> dtl = db.Student_Time_Table_Details.Where(t => t.St_id == int.Parse(subject)).ToList();
                db.Student_Time_Table_Details.DeleteAllOnSubmit(dtl);
                db.SubmitChanges();
            }

            foreach (var record in subjects.Save_list)
            {
                Student_Time_Table_Detail std = new Student_Time_Table_Detail();
                std.St_id = int.Parse(subject);
                std.Class_Year = record.Class;
                std.Class_Name = record.txtClass;
                std.Date = record.dat;
                std.Day_Name = record.day;
                std.FromTime = record.FTimes;
                std.ToTime = record.TTime;
                std.Practical = record.ddlSubject;
                std.Batch = record.ddlBatch;
                std.Groups = record.ddlGroup;
                std.Venue = record.ddlVenu;
                std.Teacher = record.ddlTeacher;
                std.Whole_Class = Convert.ToBoolean(record.whlclass);
                std.Subjects = record.ddlGetStuSub;
                std.Topic = record.topic;
                std.Holiday = Convert.ToBoolean(record.chkhldy);
                std.Brea_k = Convert.ToBoolean(record.chkbrk);
                std.CreatedBy = AppConfig.UserID;
                std.CreatedTime = DateTime.Now;
                db.Student_Time_Table_Details.InsertOnSubmit(std);
                db.SubmitChanges();
            }

            return subject;
        }
        [WebMethod]
        public static string Replicate(string StdTimetable)
        {

            string subject = "";
            Student_Time_Table subjectDef = new Student_Time_Table();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer serialize = new JavaScriptSerializer();
            var subjects = serialize.Deserialize<MasterList>(StdTimetable);
            {
                subjectDef.Program = subjects.program;
                subjectDef.Class = subjects.ddlClass;
                subjectDef.Weeks = subjects.ddlWeek;
                subjectDef.CreatedBy = AppConfig.UserID;
                subjectDef.CreatedTime = DateTime.Now;

                db.Student_Time_Tables.InsertOnSubmit(subjectDef);
                db.SubmitChanges();
                subject = subjectDef.St_id.ToString();

            }
            foreach (var record in subjects.Save_list)
            {
                Student_Time_Table_Detail std = new Student_Time_Table_Detail();
                std.St_id = int.Parse(subject);
                std.Class_Year = record.Class;
                std.Class_Name = record.txtClass;
                std.Date = record.dat;
                std.Day_Name = record.day;
                std.FromTime = record.FTimes;
                std.ToTime = record.TTime;
                std.Practical = record.ddlSubject;
                std.Batch = record.ddlBatch;
                std.Groups = record.ddlGroup;
                std.Venue = record.ddlVenu;
                std.Topic = record.topic;
                std.Teacher = record.ddlTeacher;
                std.Whole_Class = Convert.ToBoolean(record.whlclass);
                std.Subjects = record.ddlGetStuSub;
                std.Holiday = Convert.ToBoolean(record.chkhldy);
                std.Brea_k = Convert.ToBoolean(record.chkbrk);
                std.CreatedBy = AppConfig.UserID;
                std.CreatedTime = DateTime.Now;
                db.Student_Time_Table_Details.InsertOnSubmit(std);
                db.SubmitChanges();
            }

            return subject;
        }




        [WebMethod]
        public static string editMaster(int Stu_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var obj = db.Student_Time_Tables.FirstOrDefault(r => r.St_id == Stu_ID);
            return (new JavaScriptSerializer().Serialize(obj));
        }
        [WebMethod]
        public static string EditDetail(string Stu_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = (from d in db.Student_Time_Table_Details
                           join m in db.Student_Time_Tables
                            on d.St_id equals m.St_id
                           where m.St_id == Convert.ToInt64(Stu_ID)
                           select new
                           {
                               d.Std_Id,
                               d.St_id,
                               d.Class_Name,
                               classname = DBClass.getField("select dbo.GetDataValueName('Student Class', '" + d.Class_Year + "') from Student_Time_Table_Detail "),
                               d.Class_Year,
                               d.Date,
                               d.Day_Name,
                               d.FromTime,
                               d.ToTime,
                               d.Practical,
                               d.Batch,
                               d.Groups,
                               d.Venue,
                               d.Teacher,
                               d.Topic,
                               d.Whole_Class,
                               d.Subjects,
                               d.Holiday,
                               d.Brea_k,
                           }).ToList();


            return (new JavaScriptSerializer()).Serialize(Details);
        }
        public class MasterList
        {
            public string Subject_id { get; set; }
            public string program { get; set; }
            public string ddlClass { get; set; }
            public string ddlWeek { get; set; }
            public List<Detaillist> Save_list { get; set; }

        }
        public class Detaillist
        {
            public string Class { get; set; }
            public string txtClass { get; set; }

            public DateTime dat { get; set; }
            public string day { get; set; }
            public DateTime FTimes { get; set; }
            public string ddlVenu { get; set; }
            public string ddlTeacher { get; set; }
            public DateTime TTime { get; set; }
            public string ddlSubject { get; set; }
            public string ddlBatch { get; set; }
            public string ddlGroup { get; set; }
            public string whlclass { get; set; }
            public string ddlGetStuSub { get; set; }
            public string chkhldy { get; set; }
            public string chkbrk { get; set; }

            public string topic { get; set; }
        }
    }
}