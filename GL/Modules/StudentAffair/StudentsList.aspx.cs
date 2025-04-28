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
    public partial class StudentsList : System.Web.UI.Page
    {
        DataBaseDataContext db = new DataBaseDataContext();
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        public static string GetQoute()
        {
            return @"""";
        }

        [WebMethod]
        public static string ViewList(string Class, string Search, bool Isactive, bool Noactive, bool txt_WholeClass, string ddlGroup, string ddlBatch, string ddlProgram)
        {
            if (Noactive == true)
            {

                if (Search.Trim() == "")
                {
                    DataBaseDataContext db = new DataBaseDataContext();
                    var Details = db.sp_Student_List(Class, false, txt_WholeClass, ddlProgram, ddlGroup, ddlBatch).ToList();
                    return (new JavaScriptSerializer()).Serialize(Details);
                }
                else
                {
                    DataBaseDataContext db = new DataBaseDataContext();
                    var Details = db.sp_Student_List(Class, false, txt_WholeClass, ddlProgram, ddlGroup, ddlBatch).ToList().Where(x => x.Full_Name.ToLower().Contains(Search.ToLower()) || x.Father_Name.ToLower().Contains(Search.ToLower()) || x.Student_CNIC.ToLower().Contains(Search.ToLower()) || x.Roll_No.Contains(Search) || x.Student_Contact_No.ToLower().Contains(Search.ToLower()) || x.Sesion.ToLower().Contains(Search.ToLower()));
                    return (new JavaScriptSerializer()).Serialize(Details);
                }
            }

            else if (Isactive == true)
            {


                if (Search.Trim() == "")
                {
                    DataBaseDataContext db = new DataBaseDataContext();
                    var Details = db.sp_Student_List(Class, true, txt_WholeClass, ddlProgram, ddlGroup, ddlBatch).ToList();
                    return (new JavaScriptSerializer()).Serialize(Details);
                }
                else
                {
                    DataBaseDataContext db = new DataBaseDataContext();
                    var Details = db.sp_Student_List(Class, true, txt_WholeClass, ddlProgram, ddlGroup, ddlBatch).ToList().Where(x => x.Full_Name.ToLower().Contains(Search.ToLower()) || x.Father_Name.ToLower().Contains(Search.ToLower()) || x.Student_CNIC.ToLower().Contains(Search.ToLower()) || x.Roll_No.Contains(Search) || x.Student_Contact_No.ToLower().Contains(Search.ToLower()) || x.Sesion.ToLower().Contains(Search.ToLower()));
                    return (new JavaScriptSerializer()).Serialize(Details);
                }



            }
            else
            {
                if (Search.Trim() == "")
                {
                    DataBaseDataContext db = new DataBaseDataContext();
                    var Details = db.sp_Student_List(Class, null, txt_WholeClass, ddlProgram, ddlGroup, ddlBatch).ToList();
                    return (new JavaScriptSerializer()).Serialize(Details);
                }
                else
                {
                    DataBaseDataContext db = new DataBaseDataContext();
                    var Details = db.sp_Student_List(Class, null, txt_WholeClass, ddlProgram, ddlGroup, ddlBatch).ToList().Where(x => x.Full_Name.ToLower().Contains(Search.ToLower()) || x.Father_Name.ToLower().Contains(Search.ToLower()) || x.Student_CNIC.ToLower().Contains(Search.ToLower()) || x.Roll_No.Contains(Search) || x.Student_Contact_No.ToLower().Contains(Search.ToLower()) || x.Sesion.ToLower().Contains(Search.ToLower()));
                    return (new JavaScriptSerializer()).Serialize(Details);
                }
            }



        }


        [WebMethod]
        public static string DeleteRecord(int StudentId)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());


            var stdnt = (from tbl in db.Reg_Students
                         where tbl.Student_Id == (int)StudentId
                         select tbl).FirstOrDefault();

            if (stdnt != null)
            {
                SqlTransaction tranObj = null;
                SqlConnection con = new SqlConnection(DBClass.ConnectionString());
                con.Open();
                tranObj = con.BeginTransaction();
                try
                {
                    bool rowDeleted = DBClass.exectueQuery("update Reg_Student set Is_Cancel=1 where Student_Id=" + Convert.ToInt32(StudentId) + "; ", tranObj, con);

                    tranObj.Commit();

                }

                //update Reg_Student set Is_Cancel=1 where Student_Id=3;


                catch (Exception exc)
                {
                    if (tranObj != null)
                        tranObj.Rollback();
                    throw new Exception(exc.Message);
                }
                finally
                {
                    con.Close();
                }
                return "Delete";
            }
            return StudentId.ToString();

        }
        [WebMethod]
        public static string updatebills()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            string billupdate = DBClass.getField("select dbo.GetRights('Student_Update','" + AppConfig.UserID + "')");

            return (billupdate);
        }
        [WebMethod]
        public static string GetFromClass()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dep = from dv in db.DataValues
                      join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                      where vs.ValueSet_Name == "Student Class"
                      select new { dv.DataValue_Name, dv.DataValue_Description };

            return (new JavaScriptSerializer()).Serialize(dep);
        }
        [WebMethod]
        public static string GetToClass()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dep = from dv in db.DataValues
                      join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                      where vs.ValueSet_Name == "Student Class"
                      select new { dv.DataValue_Name, dv.DataValue_Description };

            return (new JavaScriptSerializer()).Serialize(dep);
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
        public static string StudentGroup()

        {
            DataBaseDataContext db = new DataBaseDataContext();
            var valuset = DBClass.GetValueSet("Group");


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
                                 DataValueName = p.DataValue_Name,
                                 DataValueDescription = p.DataValue_Description,
                             }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);
        }

        [WebMethod]
        public static string Update(List<Updatelist> Update_list)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            JavaScriptSerializer oJS = new JavaScriptSerializer();

            foreach (var item in Update_list)
            {
                var data = (from arb in db.Reg_Students.Where(x => x.Student_Id.Equals(item.txtStudent_Id)
                            )
                            select arb).FirstOrDefault();

                if (data != null)
                {
                    data.Class = item.Class_Value;
                    data.UpdateTime = DateTime.Now;
                    data.UpdatedBy = AppConfig.UserID;

                    db.SubmitChanges();
                }

            }

            return "Update Data";
        }

        public class Updatelist
        {
            public string txtStudent_Id { get; set; }
            public string Class_Value { get; set; }

        }

    }
}