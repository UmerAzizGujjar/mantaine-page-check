using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Lab
{
    public partial class UltraSoundfooterList : System.Web.UI.Page
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

                    var Total_pat = _dbContext.DataValues
                     .Where(a => a.ValueSet_ID == 2126)
                     .Count();
                    var pat = from a in _dbContext.DataValues where a.ValueSet_ID == 2126

                              where (
                                    (a.Segment2.Contains(searchValue) || a.Segment1.Contains(searchValue)|| a.DataValue_Name.Contains(searchValue)))
                              select new
                              {
                                 TemplateName = a.Segment2,
                                 DoctorName = a.Segment1,
                                 DoctorId = a.DataValue_Name,
                                 TemplateId = a.DataValue_ID
                              };

                    var FilteredCount = pat.Count();
                    switch (sortColumn)
                    {
                        case "TemplateName":
                            pat = sortColumnDirection == "asc" ? pat.OrderBy(a => a.TemplateName) : pat.OrderByDescending(a => a.TemplateName);
                            break;
                        case "DoctorName":
                            pat = sortColumnDirection == "asc" ? pat.OrderBy(a => a.DoctorName) : pat.OrderByDescending(a => a.DoctorName);
                            break;
                        default:
                            pat = pat.OrderByDescending(a => a.TemplateId);
                            break;
                    }


                    var patientList = pat.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_pat, data = patientList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Template list", ex);
            }
        }
    }
}