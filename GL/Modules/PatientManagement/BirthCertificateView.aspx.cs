using System;
using System.Collections.Generic;
using System.Data.Linq.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.PatientManagement
{
    public partial class BirthCertificateView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "Birth_Certificate";

                using (var db = new DataBaseDataContext())
                {
                    var pref = db.UserDataTablePreferences
                                  .FirstOrDefault(p => p.UserID == userId && p.PageName == pageName);

                    if (pref != null)
                        return pref.ColumnVisibility;
                    else
                        return "";
                }
            }
            catch (Exception ex)
            {
                return "";
            }
        }

        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Patients = _dbContext.Birth_Certificates.Count();
                    var BirthCertificate = from P in _dbContext.Reg_patients
                                        join IP in _dbContext.Birth_Certificates on P.pat_id equals IP.Patient_ID
                                        where  (
                                            IP.Birth_Certificate_ID.ToString().Contains(searchValue) ||
                                            P.mr_no_sequence.Contains(searchValue) ||
                                            P.Full_Name.Contains(searchValue) ||
                                          
                                            SqlMethods.DateDiffDay(IP.Registration_Date, DateTime.Now).ToString().Contains(searchValue)
                                        )
                                        select new
                                        {
                                            In_Patient_ID = IP.Birth_Certificate_ID,
                                            Admission_Date = IP.Registration_Date,
                                            mr_no_sequence = P.mr_no_sequence,
                                            Full_Name = P.Full_Name,
                                            Father_Name = P.Father_Name,
                                            Birth_Date = IP.Date_of_Birth,

                                            Created_by = Convert.ToString(_dbContext.getUserName(Convert.ToString(IP.Created_By))),
                      
                                        };

                    var FilteredCount = BirthCertificate.Count();
                    switch (sortColumn)
                    {
                        case "In_Patient_ID":
                            BirthCertificate = sortColumnDirection == "asc" ? BirthCertificate.OrderBy(a => a.In_Patient_ID) : BirthCertificate.OrderByDescending(a => a.In_Patient_ID);
                            break;
                        case "mr_no_sequence":
                            BirthCertificate = sortColumnDirection == "asc" ? BirthCertificate.OrderBy(b => b.mr_no_sequence) : BirthCertificate.OrderByDescending(a => a.mr_no_sequence);
                            break;

                        case "Admission_Date":
                            BirthCertificate = sortColumnDirection == "asc" ? BirthCertificate.OrderBy(b => b.Admission_Date) : BirthCertificate.OrderByDescending(a => a.Admission_Date);
                            break;
                        default:
                            BirthCertificate = BirthCertificate.OrderByDescending(a => a.In_Patient_ID);
                            break;
                    }

                    var patientList = BirthCertificate.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Patients, data = patientList };
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