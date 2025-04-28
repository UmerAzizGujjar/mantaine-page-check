using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Net;
using System.Data.SqlClient;
using System.IO;
using System.Web.Services;
using System.Drawing.Printing;
using CrystalDecisions.CrystalReports.Engine;
using System.Configuration;
using CrystalDecisions.Shared;
using System.Web.Script.Serialization;
using PMS.Modules.PatientManagement;

namespace PMS
{
    public partial class InPatientView : System.Web.UI.Page
    {
        DataBaseDataContext db = new DataBaseDataContext();
        static string FilePath = "";
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        public static string GetQoute()
        {
            return @"""";
        }

       [WebMethod]
        public static string DeleteRecord(int InPatientID)
        {



            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());


            var patID = (int)(from tbl in db.In_Patients
                              where tbl.In_Patient_ID == (int)InPatientID
                              select tbl.Patient_ID).FirstOrDefault();
            var ipdid = InPatientID;
            var patbill = (from tbl in db.Ar_Billings
                           where tbl.Patient_ID == (int)patID && (tbl.isCancel == null ? false : tbl.isCancel) == false
                           select tbl).FirstOrDefault();
            var wardcheck = (from tbl in db.Ward_Allocations
                             where tbl.InPatient_ID == Convert.ToString((int)ipdid)
                             orderby tbl.Ward_Allocation_ID descending
                             select tbl.IsDischarge).FirstOrDefault();


            var user = AppConfig.UserID.ToString();


            if (patbill == null && wardcheck == false)
            {
                SqlTransaction tranObj = null;
                SqlConnection con = new SqlConnection(DBClass.ConnectionString());
                con.Open();
                tranObj = con.BeginTransaction();
                try
                {
                    bool rowUpdated = DBClass.exectueQuery(
                    "UPDATE In_Patient SET is_cancel = 1, cancel_by = '" + user + "' WHERE In_Patient_ID = " + Convert.ToInt32(InPatientID) + "; " +
                    "DELETE FROM Ward_Allocation WHERE InPatient_ID = " + InPatientID.ToString(),
                    tranObj,
                    con
                );




                    tranObj.Commit();

                }
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
            return patbill.ToString();

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
                              where (
                                    (ipd.In_Patient_ID.ToString().Contains(searchValue) || p.mr_no_sequence.ToString().Contains(searchValue) || p.Full_Name.Contains(searchValue) || p.pat_id.ToString().Contains(searchValue) || p.Father_Name.Contains(searchValue) || _dbContext.GetDataValueName("Patient Main Category", ipd.Department).Contains(searchValue)))
                                     && (ipd.is_cancel ?? false) == false
                              select new
                              {
                                  mr_no_sequence = p.mr_no_sequence,
                                  Admission_Date = ipd.Admission_Date,
                                  IN_Patient_ID = ipd.In_Patient_ID,
                                  Full_Name = p.Full_Name,
                                  Father_Name = p.Father_Name,
                                  Department = _dbContext.GetDataValueName("Patient Main Category", ipd.Department),


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
                            pat = sortColumnDirection == "asc" ? pat.OrderBy(a => a.Admission_Date) : pat.OrderByDescending(a => a.Admission_Date);
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
