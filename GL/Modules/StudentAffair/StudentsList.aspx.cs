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
        public static string ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue,string Class, bool Isactive, bool Noactive, string ddlProgram, string ddlBatch,
    string ddlGroup, bool txt_WholeClass)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    bool? isActiveFilter = null;
                    if (Isactive) isActiveFilter = true;
                    else if (Noactive) isActiveFilter = false;
                    var allStudents = db.sp_Student_List(Class, isActiveFilter, txt_WholeClass, ddlProgram, ddlBatch, ddlGroup).ToList();

                    if (!string.IsNullOrWhiteSpace(searchValue))
                    {
                        string searchTerm = searchValue.ToLower();
                        allStudents = allStudents.Where(x =>
                            (x.Full_Name != null && x.Full_Name.ToLower().Contains(searchTerm)) ||(x.Father_Name != null && x.Father_Name.ToLower().Contains(searchTerm)) || (x.Student_CNIC != null && x.Student_CNIC.ToLower().Contains(searchTerm)) || (x.Roll_No != null && x.Roll_No.Contains(searchTerm)) ||  (x.Student_Contact_No != null && x.Student_Contact_No.ToLower().Contains(searchTerm)) || (x.Sesion != null && x.Sesion.ToLower().Contains(searchTerm))
                        ).ToList();
                    }
                    int recordsTotal = allStudents.Count;
                    int recordsFiltered = allStudents.Count;
                    switch (sortColumn)
                    {
                        case "Full_Name": allStudents = sortColumnDirection == "asc"  ? allStudents.OrderBy(s => s.Full_Name).ToList() : allStudents.OrderByDescending(s => s.Full_Name).ToList();
                            break;
                        case "Roll_No": allStudents = sortColumnDirection == "asc" ? allStudents.OrderBy(s => s.Roll_No).ToList(): allStudents.OrderByDescending(s => s.Roll_No).ToList();
                            break;
                        case "Class":allStudents = sortColumnDirection == "asc"  ? allStudents.OrderBy(s => s.Class).ToList() : allStudents.OrderByDescending(s => s.Class).ToList();
                            break;
                        case "AdmissionDate": allStudents = sortColumnDirection == "asc"  ? allStudents.OrderBy(s => s.CreatedTime).ToList() : allStudents.OrderByDescending(s => s.CreatedTime).ToList();
                            break;
                        case "Student_Id":
                        default:
                            allStudents = sortColumnDirection == "asc"  ? allStudents.OrderBy(s => s.Student_Id).ToList()  : allStudents.OrderByDescending(s => s.Student_Id).ToList();
                            break;
                    }

                    var pagedData = allStudents.Skip(start).Take(length).ToList();

                    var formattedData = pagedData.Select(s => new
                    {
                        Student_Id = s.Student_Id,
                        AdmissionDate = s.CreatedTime,
                        Class = s.Class ?? "",
                        Full_Name = s.Full_Name ?? "",
                        Father_Name = s.Father_Name ?? "",
                        Student_CNIC = s.Student_CNIC ?? "",
                        Student_Contact_No = s.Student_Contact_No ?? "",
                        Batch = s.Batch ?? " ",
                        Groups = s.Groups ?? " ",
                        Sesion = s.Sesion ?? ""
                    }).ToList();
                    var result = pagedData.Select(s => new
                    {
                        Student_Id = s.Student_Id,
                        AdmissionDate = s.CreatedTime,
                        Roll_No = s.Roll_No ?? "",
                        Class = s.Class ?? "",
                        Full_Name = s.Full_Name ?? "",
                        Father_Name = s.Father_Name ?? "",
                        Student_CNIC = s.Student_CNIC ?? "",
                        Student_Contact_No = s.Student_Contact_No ?? "",
                        Batch = s.Batch ?? " ",
                        Groups = s.Groups ?? " ",
                        Sesion = s.Sesion ?? ""
                    }).ToList();

                    var jsonData = new
                    {
                        draw,
                        recordsTotal,
                        recordsFiltered,
                        data = result
                    };

                    return new JavaScriptSerializer().Serialize(jsonData);
                }
            }
            catch (Exception ex)
            {
                // Log error
                return new JavaScriptSerializer().Serialize(new
                {
                    draw,
                    recordsTotal = 0,
                    recordsFiltered = 0,
                    data = new object[0]
                });
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