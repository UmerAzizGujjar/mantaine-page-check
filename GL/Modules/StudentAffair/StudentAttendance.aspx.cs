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
    public partial class StudentAttendance : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        //[WebMethod]
        //public static String UserRoles()
        //{
        //    DataBaseDataContext db = new DataBaseDataContext();
        //    var ups = (from St in db.aspnet_Users
        //               where St.UserName == AppConfig.UserName
        //               select St.Student_Update).FirstOrDefault();

        //    return (new JavaScriptSerializer()).Serialize(ups);
        //}
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
        public static string GetSubj(string program, string classs, string week, string date)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            string data = string.Empty;
            var listItems = (from s in db.Subject_Definitions
                             join sd in db.Subject_Definition_Lists
                             on s.subject_Id equals sd.Subject_ID
                             where s.Program == program && s.Class == classs
                        
                             select new
                             {
                                 sd.Subject_Detail_ID,
                                 sd.Subject_Name

                             }).ToList().Distinct();
            return (new JavaScriptSerializer()).Serialize(listItems);
        }
        [WebMethod]
        public static string GetSubjectType(string Subject, string classs)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var subjtype = (from stt in db.Student_Time_Tables
                            join std in db.Student_Time_Table_Details
                            on stt.St_id equals std.St_id
                            where std.Subjects == Subject && std.Class_Year == classs
                            select new
                            {
                                std.Std_Id,
                                std.Practical,

                                prac = DBClass.getField("select dbo.GetDataValueName('Subject Type', '" + std.Practical + "') from Student_Time_Table_Detail "),

                            }).GroupBy(x => x.Practical).Select(x => x.FirstOrDefault()).ToList().Distinct();
            return (new JavaScriptSerializer()).Serialize(subjtype);
        }
        [WebMethod]
        public static string GetWeek()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var valuset = DBClass.GetValueSet("Week");
            return (new JavaScriptSerializer()).Serialize(valuset);
        }

        [WebMethod]
        public static string StudentBatch()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            //List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            var listItems = (from p in db.DataValues
                             join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                             where v.ValueSet_Description == "Batch"
                             select new
                             {
                                 DataValue_Name = p.DataValue_Name,
                                 DataValue_Description = p.DataValue_Description,
                             }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);
        }

        [WebMethod]
        public static string GetAcademicBlockByWeek(string week)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var result = (from link in db.Student_Time_Tables
                                  join dv in db.DataValues on link.Block equals dv.DataValue_Name
                                  join ds in db.ValueSets on dv.ValueSet_ID equals ds.ValueSet_ID
                                  where ds.ValueSet_Name == "Academic Block"
                                        && link.Weeks == week 
                                  select new
                                  {
                                      dv.DataValue_Name,
                                      dv.DataValue_Description
                                  }).Distinct().ToList(); 

                    return new JavaScriptSerializer().Serialize(result);
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new List<object>());
            }
        }

        [WebMethod]
        public static string GetAcademicModuleByWeek(string week)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var result = (from link in db.Student_Time_Tables
                                  join dv in db.DataValues on link.Module equals dv.DataValue_Name
                                  join ds in db.ValueSets on dv.ValueSet_ID equals ds.ValueSet_ID
                                  where ds.ValueSet_Name == "Academic Module"
                                        && link.Weeks == week 
                                  select new
                                  {
                                      dv.DataValue_Name,
                                      dv.DataValue_Description
                                  }).Distinct().ToList();

                    return new JavaScriptSerializer().Serialize(result);
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new List<object>());
            }
        }

        [WebMethod]
        public static string StudentGroup()

        {
            DataBaseDataContext db = new DataBaseDataContext();
            var valuset = DBClass.GetValueSet("Group");


            return (new JavaScriptSerializer()).Serialize(valuset);
        }

        [WebMethod]
        public static string GetTime(string sub, string practical, string classs, string week, string date)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Time = (from stt in db.Student_Time_Tables
                        join std in db.Student_Time_Table_Details
                        on stt.St_id equals std.St_id
                        where std.Subjects == sub
                       //&& std.Practical == practical
                       && stt.Class == classs && stt.Weeks == week
                      && std.Date == DateTime.Parse(date)
                        select new
                        {
                            std.Std_Id,
                            std.FromTime,
                            std.ToTime
                        }).ToList().Distinct();
            return (new JavaScriptSerializer()).Serialize(Time);
        }


        [WebMethod]
        public static string GetAttendanceDetaile(string FTime, string TTime, string program, string classs, string date, string Group, string bathc, string txt_WholeClass)
        {
            DateTime dt = DateTime.Parse(FTime);
            var ftime = dt.ToString("hh:mm tt");

            DateTime Totime = DateTime.Parse(TTime);
            var Ttime = Totime.ToString("hh:mm tt");

            DateTime datee = DateTime.Parse(date);
            var newdate = datee.ToString("dd-MM-yyyy");

            var wholeClass = Convert.ToBoolean(txt_WholeClass);


            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.GetAttendanceDetails(dt, Totime, program, classs, datee.Date, Group, bathc, wholeClass).ToList();


            if (Details.Count == 0)
            {
                var AttendanceDetail = db.sp_AttendanceDetails(dt, Totime, program, classs, datee.Date, Group, bathc, wholeClass).ToList();
                return (new JavaScriptSerializer()).Serialize(AttendanceDetail);
            }
            else
            {
                return (new JavaScriptSerializer()).Serialize(Details);
            }
        }
        [WebMethod]
        public static string GetDateOfAttendance(string prgrm, string clas, string week)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Time = (from sta in db.Student_Time_Tables
                        join std in db.Student_Time_Table_Details
                        on sta.St_id equals std.St_id
                        where sta.Program == prgrm && sta.Class == clas && sta.Weeks == week
                        select new
                        {
                             std.Date,
                             std.Day_Name
                        }).ToList().Distinct();
            return (new JavaScriptSerializer()).Serialize(Time);

        }


        [WebMethod]
        public static string SaveAttendance(string Parameter)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            JavaScriptSerializer serialize = new JavaScriptSerializer();
            var Saveattendance = serialize.Deserialize<Att>(Parameter);




            var SaAtt = new Student_Attendance();
            foreach (var record in Saveattendance.Save_list)
            {
                SaAtt = new Student_Attendance();

                SaAtt.Stud_Id = record.Student_Id;
                SaAtt.Student_Name = record.Student_Name;
                SaAtt.Roll_No = Convert.ToInt32(record.Roll_No);

                TimeSpan attime;
                if (TimeSpan.TryParse(record.ATime, out attime))
                {

                    record.ATime = Convert.ToString(attime);
                    // Conversion succeeded, use the attime variable here
                }
                else
                {
                    // Conversion failed, handle the error here
                }

                SaAtt.Attendance_date = new DateTime(record.dat.Date.Year, record.dat.Date.Month, record.dat.Date.Day, attime.Hours, attime.Minutes, attime.Seconds);
                SaAtt.Day_Name = record.day;

                SaAtt.Fromtime = DateTime.Parse(record.FTimes);
                SaAtt.Totime = DateTime.Parse(record.TTimes);
                SaAtt.Class = record.Classval;
                record.Classname = DBClass.getField("select dbo.GetDataValueName('Student Class', '" + SaAtt.Class + "') ");
                SaAtt.Subject = record.Subval;
                record.Subjectname = DBClass.getField("select Subject_Name from Subject_Definition_List where Subject_Detail_ID=" + SaAtt.Subject);
                SaAtt.Practical = record.pracval;
                record.pracval = DBClass.getField("select dbo.GetDataValueName('Subject Type', '" + SaAtt.Practical + "') ");
                SaAtt.Present = Convert.ToBoolean(record.chkPresent);
                SaAtt.Absent = Convert.ToBoolean(record.chkAbsent);
                SaAtt.Leave = Convert.ToBoolean(record.chkLeave);
                SaAtt.Batch = record.batchs;
                SaAtt.Groups = record.groups;
                SaAtt.Created_Time = DateTime.Now;
                SaAtt.Created_By = AppConfig.UserID;
                SaAtt.Block = record.Block; 
                SaAtt.Module = record.Module;
                db.Student_Attendances.InsertOnSubmit(SaAtt);
                db.SubmitChanges();
            }
            return (new JavaScriptSerializer()).Serialize(Saveattendance.Save_list);
        }

        [WebMethod]
        public static string UpdateAttendance(string Parameters)

        {
            DataBaseDataContext db = new DataBaseDataContext();
            JavaScriptSerializer serialize = new JavaScriptSerializer();
            var Upattendance = serialize.Deserialize<Att>(Parameters);
            foreach (var record in Upattendance.Update_list)
            {
                var UpAtt = (from St in db.Student_Attendances where St.Stud_Id == record.Student_Id && St.Class == record.Classval && St.Subject == record.Subval && St.Practical == record.pracval && St.Attendance_date.Value.Date == record.dat.Date select St).FirstOrDefault();
                if (UpAtt != null)
                {
                    UpAtt.Present = Convert.ToBoolean(record.chkPresent);
                    UpAtt.Absent = Convert.ToBoolean(record.chkAbsent);
                    UpAtt.Leave = Convert.ToBoolean(record.chkLeave);
                    UpAtt.ReferBy = "This record has been Updated";
                    UpAtt.Updated_Time = DateTime.Now;
                    UpAtt.Updated_By = AppConfig.UserID;
                    UpAtt.Totime = Convert.ToDateTime(record.totim);
                    UpAtt.Fromtime = Convert.ToDateTime(record.frmtim);
                    UpAtt.Attendance_date = Convert.ToDateTime(record.dat);

                    db.SubmitChanges();
                }
                else
                {
                    return "Not Found";
                }
            }
            return "Success";
        }
        [WebMethod]
        public static string AttendanceProcess(string Parameters)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            JavaScriptSerializer serialize = new JavaScriptSerializer();
            var Upattendance = serialize.Deserialize<AttProc>(Parameters);

            var fromTime = new DateTime(Upattendance.date.Date.Year, Upattendance.date.Date.Month, Upattendance.date.Date.Day, Upattendance.frmtim.TimeOfDay.Hours, Upattendance.frmtim.TimeOfDay.Minutes, Upattendance.frmtim.TimeOfDay.Seconds);


            var toTime = new DateTime(Upattendance.date.Date.Year, Upattendance.date.Date.Month, Upattendance.date.Date.Day, Upattendance.totim.TimeOfDay.Hours, Upattendance.totim.TimeOfDay.Minutes, Upattendance.totim.TimeOfDay.Seconds);

            var isAttendance = db.sp_isAttendance(Upattendance.RollNo, fromTime, toTime);


            return (new JavaScriptSerializer()).Serialize(isAttendance);



       
        }


        public class AttProc
        {
            public DateTime frmtim { get; set; }
            public DateTime totim { get; set; }
            public string RollNo { get; set; }
            public DateTime date { get; set; }
        }

        public class Att
        {
            public List<Attendance> Save_list { get; set; }
            public List<Attendance> Update_list { get; set; }
        }

        public class Attendance
        {
            public int Student_Id { get; set; }
            public string Student_Name { get; set; }
            public DateTime frmtim { get; set; }
            public DateTime totim { get; set; }
            public string Roll_No { get; set; }
            public string Classname { get; set; }
            public string Subjectname { get; set; }
            public string Pracname { get; set; }
            public string chkPresent { get; set; }
            public string chkAbsent { get; set; }
            public string chkLeave { get; set; }
            public string Classval { get; set; }
            public string Subval { get; set; }
            public string pracval { get; set; }

            public DateTime dat { get; set; }
            public string day { get; set; }


            public string batchs { get; set; }

            public string groups { get; set; }

            public string FTimes { get; set; }
            public string TTimes { get; set; }
            public string ATime { get; set; }

            public string Block { get; set; } 
            public string Module { get; set; }



        }


    }
}