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
    public partial class Student : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }


        private class ddlListItems
        {
            public string DataValueName;
            public string DataValueDescription;
            public string Type;
        }


        [WebMethod]
        public static string LoadStudentData(int Stu_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var loaddonordata = (from a in db.Students
                                 where a.Student_ID == Stu_ID
                                 select new
                                 {

                                     a.Student_ID,
                                     a.Student_Code,
                                     a.Student_Name,
                                     a.Phone,
                                     a.Address,
                                     a.Admission_Category,
                                     a.Email,
                                     a.Father_Name,
                                     a.Roll_No,
                                     a.Session,
                                     a.Account_ID,
                                     a.Date,
                                 }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(loaddonordata);

        }

        [WebMethod]
        public static string GetAdmisionCategory()

        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Admission Category"
                         select new ddlListItems
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                         }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);
        }



        [WebMethod]
        public static string GetSession()

        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Session"
                         select new ddlListItems
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                         }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);
        }





        [WebMethod]
        public static string Getnewstudentno()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var GRN_No = DBClass.GetNewNumber("Student_Code", "Student", "");
            return GRN_No.ToString();
        }


        [WebMethod]
        public static string SaveInvoice(string btnSave, string AllItemDetail)
        {
            string studentid = "";
            Student stud = new Student();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<MasterList>(AllItemDetail);
            var lstItem = (from t in db.Students
                           where t.Student_Code == int.Parse(record.txt_StudentCode)
                           select t).FirstOrDefault();
            if (btnSave == "Update")
            {
                lstItem.Student_Code = Convert.ToInt32(record.txt_StudentCode);
                lstItem.Student_Name = record.txt_studentname;
                lstItem.Roll_No = record.txt_rollno;
                lstItem.Father_Name = record.txt_fname;
                lstItem.Phone = record.txt_phone;
                lstItem.Email = record.txt_email;
                lstItem.Session = record.ddl_session;
                lstItem.Admission_Category = record.ddladmsn_category;          
                lstItem.Account_ID = Convert.ToInt32(record.txt_glaccount);
                lstItem.Address = record.txt_address;

                var dates = record.txt_Date;
                if (dates == null || dates == "")
                {
                    lstItem.Date = DateTime.Now;
                }
                else
                {
                    lstItem.Date = Convert.ToDateTime(record.txt_Date);
                }
                db.SubmitChanges();
                studentid = lstItem.Student_ID.ToString();
            }
            else
            {

                stud.Student_Code = Convert.ToInt32(record.txt_StudentCode);
                stud.Student_Name = record.txt_studentname;
                stud.Roll_No = record.txt_rollno;
                stud.Father_Name = record.txt_fname;
                stud.Phone = record.txt_phone;
                stud.Email = record.txt_email;
                stud.Admission_Category = record.ddladmsn_category;
                stud.Session = record.ddl_session;
                stud.Account_ID = Convert.ToInt32(record.txt_glaccount);
                stud.Address = record.txt_address;
                stud.Date = Convert.ToDateTime(record.txt_Date);
                db.Students.InsertOnSubmit(stud);
                db.SubmitChanges();
                studentid = stud.Student_ID.ToString();
            }
            return studentid;
        }


        public class MasterList
        {
            public string txt_StudentCode { get; set; }
            public string txt_studentname { get; set; }
            public string txt_rollno { get; set; }
            public string txt_fname { get; set; }
            public string txt_phone { get; set; }
            public string txt_email { get; set; }
            public string ddladmsn_category { get; set; }
            public string ddl_session { get; set; }
            public string txt_glaccount { get; set; }
            public string txt_address { get; set; }
            public string txt_Date { get; set; }



        }


    }
}