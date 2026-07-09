using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.PatientManagement
{
    public partial class DeathDetailsList : System.Web.UI.Page
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

                    var Total_pat = _dbContext.In_Patients.Count();
                    var pat = from ipd in _dbContext.In_Patients
                              join p in _dbContext.Reg_patients on ipd.Patient_ID equals p.pat_id
                              where ipd.DateOfDeath != null
                                    //&& (ipd.is_cancel ?? false) == false
                                    && (ipd.In_Patient_ID.ToString().Contains(searchValue) ||p.mr_no_sequence.ToString().Contains(searchValue) ||p.Full_Name.Contains(searchValue) ||
                                        p.pat_id.ToString().Contains(searchValue) ||  p.Father_Name.Contains(searchValue) ||
                                        _dbContext.GetDataValueName("Patient Main Category", ipd.Department).Contains(searchValue)
                                    )
                              select new
                              {
                                  mr_no_sequence = p.mr_no_sequence,
                                  Admission_Date = ipd.Admission_Date,
                                  IN_Patient_ID = ipd.In_Patient_ID,
                                  Full_Name = p.Full_Name,
                                  Father_Name = p.Father_Name,
                                  Death_Date = ipd.DateOfDeath,
                                  CauseOfDeath = ipd.CauseOfDeath,
                                  Department = _dbContext.GetDataValueName("Patient Main Category", ipd.Department),
                                  PlaceOfDeath = _dbContext.GetDataValueName("Place Of Death", ipd.PlaceOfDeath)
                              };

                    var FilteredCount = pat.Count();
                    switch (sortColumn)
                    {
                        case "MRNO":
                            pat = sortColumnDirection == "asc" ? pat.OrderBy(a => a.mr_no_sequence) : pat.OrderByDescending(a => a.mr_no_sequence);
                            break;
                        case "Patient_ID":
                            pat = sortColumnDirection == "asc" ? pat.OrderBy(a => a.Department) : pat.OrderByDescending(a => a.Department);
                            break;
                        case "DATE":
                            pat = sortColumnDirection == "asc" ? pat.OrderBy(a => a.Death_Date) : pat.OrderByDescending(a => a.Death_Date);
                            break;
                        default:
                            pat = pat.OrderByDescending(a => a.IN_Patient_ID);
                            break;
                    }


                    var patientList = pat.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_pat, data = patientList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching patient list", ex);
            }
        }
    }
}