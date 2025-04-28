using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class Doctor_Template_List : System.Web.UI.Page
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
                

                    var templates = _dbContext.Doctor_Template_Masters.Count();
                    var tmp = from a in _dbContext.Doctor_Template_Masters
                              orderby a.Template_Id descending
                              select new TempList
                              {
                                  TemplateID = a.Template_Id,
                                  TemplateName = a.Template_Name,
                                  Doctor_Id = (from hr in _dbContext.HR_Employees where hr.Emp_ID == a.Doctor_Id select hr.Emp_Name).FirstOrDefault(),

                              };
                    var FilteredCount = tmp.Count();
                    switch (sortColumn)
                    {
                        case "TemplateName":
                            tmp = sortColumnDirection == "asc" ? tmp.OrderBy(a => a.TemplateName) : tmp.OrderByDescending(a => a.TemplateName);
                            break;
                       
                    }


                    var templatelist = tmp.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = templates, data = templatelist };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching patient list", ex);
            }
        }
        [WebMethod]
        public static string DeleteRecord(string labID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var remove = (from aremove in db.Doctor_Template_Masters
                              where aremove.Template_Id == Convert.ToInt32(labID)
                              select aremove).FirstOrDefault();
                if (remove != null)
                {
                    db.Doctor_Template_Masters.DeleteOnSubmit(remove);
                    db.SubmitChanges();
                }
            }
            return "";
        }
    }

    public class TempList
    {
        public int TemplateID { get; set; }
        public string TemplateName { get; set; }
        public string Doctor_Id { get; set; }

    }

    public class TemplateDataTable
    {
        public int draw { get; set; }
        public int recordsTotal { get; set; }
        public int recordsFiltered { get; set; }
        public List<TempList> data { get; set; }
    }
}
