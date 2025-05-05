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
    public partial class SubjectList : System.Web.UI.Page
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
                   
                    var Total_Subject = _dbContext.Subject_Definitions.Count();
                    var Subject = from S in _dbContext.Subject_Definitions
                              where ((S.subject_Id.ToString().Contains(searchValue) || _dbContext.GetDataValueName("Student Class", S.Program).Contains(searchValue) || _dbContext.GetDataValueName("Admission Category", S.Class).Contains(searchValue)))
                              select new
                              {
                                  subject_Id = S.subject_Id,
                                  Program = _dbContext.GetDataValueName("Student Class", S.Program),
                                  Class = _dbContext.GetDataValueName("Admission Category", S.Class),
                              };



                    var FilteredCount = Subject.Count();
                    switch (sortColumn)
                    {
                        case "Program":
                            Subject = sortColumnDirection == "asc" ? Subject.OrderBy(a => a.Program) : Subject.OrderByDescending(a => a.Program);
                            break;                      
                        default:
                            Subject = Subject.OrderBy(a => a.subject_Id); 
                            break;
                    }


                    var SubjectList = Subject.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Subject, data = SubjectList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Student list", ex);
            }
        }

        [WebMethod]
        public static string DeleteSubject(int Id)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var Delete = DBClass.getField("delete from Subject_Definition_List where subject_Id= '" + Id + "' ");
            var DeleteMaster = DBClass.getField("delete from Subject_Definition where subject_Id= '" + Id + "' ");
            return (Delete);
        }
    }
}