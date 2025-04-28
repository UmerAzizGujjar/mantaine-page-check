using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;


namespace PMS
{
    public partial class SubjectDefinition : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string GetStudentClass()

        {
            DataBaseDataContext db = new DataBaseDataContext();
            string data = string.Empty;
            var listItems = (from p in db.DataValues
                             join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                             where v.ValueSet_Description == "Student Class"
                             select new
                             {
                                 DataValueName = p.DataValue_Name,
                                 DataValueDescription = p.DataValue_Description,
                             }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);
        }
        [WebMethod]
        public static string GetPrograms()

        {
            DataBaseDataContext db = new DataBaseDataContext();
            string data = string.Empty;
            var listItems = (from p in db.DataValues
                             join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                             where v.ValueSet_Description == "Admission Category"
                             select new
                             {
                                 DataValueName = p.DataValue_Name,
                                 DataValueDescription = p.DataValue_Description,
                             }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);
        }

        [WebMethod]
        public static string SaveSubject(string AllSubject, string btnSave)
        {

            string SubjecID = "";
            Subject_Definition subjectDef = new Subject_Definition();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer serialize = new JavaScriptSerializer();
            var subject = serialize.Deserialize<MasterList>(AllSubject);

            if (btnSave == "Update")
            {

                var lstItem = (from a in db.Subject_Definitions
                               where a.subject_Id == Convert.ToInt32(subject.Subject_id)
                               select a).FirstOrDefault();
                lstItem.Update_By = AppConfig.UserID;
                lstItem.Update_Time = DateTime.Now;
                lstItem.Class = subject.ddlClass;
                lstItem.Program = subject.ddlProgram;
                db.SubmitChanges();
                SubjecID = lstItem.subject_Id.ToString();
            }
            else
            {
                subjectDef.Class = subject.ddlClass;
                subjectDef.Program = subject.ddlProgram;
                subjectDef.Created_By = AppConfig.UserID;
                subjectDef.Created_Time = DateTime.Now;
                db.Subject_Definitions.InsertOnSubmit(subjectDef);

                db.SubmitChanges();
                SubjecID = subjectDef.subject_Id.ToString();

            }

            if (btnSave == "Update")
            {
                List<Subject_Definition_List> DetailLists = db.Subject_Definition_Lists.Where(t => t.Subject_ID == int.Parse(SubjecID)).ToList();

                foreach (var record in subject.Arr)
                {
                    if (record.Subject != "")
                    {
                        if (record.Subject_Detail_ID == null || record.Subject_Detail_ID.Trim() == "")
                        {
                            
                        }
                        else
                        {
                            var detail = DetailLists.Where(x => x.Subject_Detail_ID == Convert.ToInt32(record.Subject_Detail_ID)).FirstOrDefault();
                            DetailLists.Remove(detail);
                        }
                    }
                }
                db.Subject_Definition_Lists.DeleteAllOnSubmit(DetailLists);
           
                db.SubmitChanges();



                foreach (var record in subject.Arr)
                {
                    if (record.Subject != "")
                    {
                        Subject_Definition_List ltd = new Subject_Definition_List();
                        ltd.Subject_ID = int.Parse(SubjecID);
                        ltd.Subject_Name = record.Subject;
                        ltd.Created_Time = DateTime.Now;
                        ltd.Created_By = AppConfig.UserID;

                        if (record.Subject_Detail_ID == null || record.Subject_Detail_ID.Trim() == "")
                        {
                            db.Subject_Definition_Lists.InsertOnSubmit(ltd);
                        }
                        else
                        {
                            ltd.Subject_Detail_ID = Convert.ToInt32(record.Subject_Detail_ID);
                        }
                       
                        db.SubmitChanges();
                    }

                }
            }
            else
            {
                foreach (var record in subject.Arr)
                {
                    if (record.Subject != "")
                    {
                        Subject_Definition_List ltd = new Subject_Definition_List();
                        ltd.Subject_ID = int.Parse(SubjecID);
                        ltd.Subject_Name = record.Subject;
                        ltd.Created_Time = DateTime.Now;
                        ltd.Created_By = AppConfig.UserID;
                        db.Subject_Definition_Lists.InsertOnSubmit(ltd);
                        db.SubmitChanges();
                    }

                }
            }
            return SubjecID;
        }
        [WebMethod]
        public static string editMaster(int Stu_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var obj = db.Subject_Definitions.FirstOrDefault(r => r.subject_Id == Stu_ID);
            return (new JavaScriptSerializer().Serialize(obj));
        }


        [WebMethod]
        public static string EditDetail(string Stu_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = (from d in db.Subject_Definition_Lists
                           join m in db.Subject_Definitions
                            on d.Subject_ID equals m.subject_Id
                           where m.subject_Id == Convert.ToInt64(Stu_ID)
                           select new
                           {
                               d.Subject_Detail_ID,
                               d.Subject_ID,
                               d.Subject_Name

                           }).ToList();


            return (new JavaScriptSerializer()).Serialize(Details);
        }



        public class MasterList

        {
            public string Subject_id { get; set; }
            public string ddlProgram { get; set; }
            public string ddlClass { get; set; }
            public List<DetailList> Arr { get; set; }
        }

        public class DetailList
        {
            public string Subject { get; set; }
            public string Subject_Detail_ID { get; set; }
        }


    }
}