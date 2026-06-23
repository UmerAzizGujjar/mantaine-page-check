using System;
using System.Linq;
using System.Web.Services;
using System.Web.Script.Services;

namespace PMS.Modules.PatientManagement
{
    public partial class Physiotherapy_Assessment_List : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e) { }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object GetAssessmentList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var pat = from pa in db.Physiotherapy_Assessments
                              join op in db.Out_Patients on pa.Out_Patient_ID equals op.Out_Patient_ID
                              join p in db.Patients on op.Patient_ID equals p.Patient_ID
                              select new
                              {
                                  OutPatientId = op.Out_Patient_ID,
                                  MR = "MR-" + p.Patient_No,
                                  PatientName = p.Full_Name,
                                  AssessmentDate = pa.Assessment_Date,
                                  Department = db.GetDataValueName("Patient Main Category", p.Patient_Main_Category)
                              };

                    int total = pat.Count();

                    if (!string.IsNullOrWhiteSpace(searchValue))
                    {
                        pat = pat.Where(x => x.MR.Contains(searchValue) || x.PatientName.Contains(searchValue) || x.Department.Contains(searchValue));
                    }

                    int filtered = pat.Count();

                    switch (sortColumn)
                    {
                        case "MR":
                            pat = sortColumnDirection == "asc" ? pat.OrderBy(x => x.MR) : pat.OrderByDescending(x => x.MR);
                            break;
                        case "PatientName":
                            pat = sortColumnDirection == "asc" ? pat.OrderBy(x => x.PatientName) : pat.OrderByDescending(x => x.PatientName);
                            break;
                        case "AssessmentDate":
                            pat = sortColumnDirection == "asc" ? pat.OrderBy(x => x.AssessmentDate) : pat.OrderByDescending(x => x.AssessmentDate);
                            break;
                        case "Department":
                            pat = sortColumnDirection == "asc" ? pat.OrderBy(x => x.Department) : pat.OrderByDescending(x => x.Department);
                            break;
                        default:
                            pat = pat.OrderByDescending(x => x.AssessmentDate);
                            break;
                    }

                    var page = pat.Skip(start).Take(length).ToList().Select(x => new
                    {
                        x.OutPatientId,
                        x.MR,
                        x.PatientName,
                        AssessmentDate = x.AssessmentDate.HasValue ? x.AssessmentDate.Value.ToString("dd/MM/yyyy") : "",
                        x.Department
                    }).ToList();

                    return new { draw, recordsTotal = total, recordsFiltered = filtered, data = page };
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching physiotherapy assessments", ex);
            }
        }
    }
}
