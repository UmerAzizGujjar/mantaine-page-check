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
using System.Web.Script.Services;
using System.Web.UI.MobileControls;

namespace PMS
{
    public partial class WebForm12 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        protected override void OnInit(EventArgs e)
        {
            if (Session["Company_ID"] != null)
            {
               
            }
        }
        [WebMethod]
        public static string DeleteRecord(int OutPatientID)
        {

            // Response.Write("<script>alert('Hello');</script>");
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            // Patient pat = new Patient();

            var patID = (int)(from tbl in db.Out_Patients
                              where tbl.Out_Patient_ID == (int)OutPatientID
                              select tbl.Patient_ID).FirstOrDefault();

            var patbill = (from tbl in db.Ar_Billings
                           where tbl.Patient_ID == (int)patID
                           select tbl).FirstOrDefault();
            if (patbill == null)
            {
                SqlTransaction tranObj = null;
                SqlConnection con = new SqlConnection(DBClass.ConnectionString());
                con.Open();
                tranObj = con.BeginTransaction();
                try
                {
                    bool rowDeleted = DBClass.exectueQuery("Delete Out_Patient Where Out_Patient_ID=" + Convert.ToInt32(OutPatientID) + "", tranObj, con);


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

                    var Total_pat = _dbContext.Out_Patients.Count();
                    var pat = from p in _dbContext.Out_Patients
                              join rg in _dbContext.Patients on p.Patient_ID equals rg.Patient_ID
                              where (
                                    (p.Out_Patient_ID.ToString().Contains(searchValue) || rg.Father_Name.Contains(searchValue) || rg.mr_no_sequence.Contains(searchValue) || rg.Mobile1.Contains(searchValue) || rg.Full_Name.Contains(searchValue) || rg.NIC.Contains(searchValue) || _dbContext.GetDataValueName("Patient Main Category", rg.Patient_Main_Category).Contains(searchValue)))
                              select new
                              {
                                  Out_Patient_ID = p.Out_Patient_ID,
                                  Created_Time = p.Created_Time,
                                  mr_no_sequence = rg.mr_no_sequence,
                                  Full_Name = rg.Full_Name,
                                  Father_Name = rg.Father_Name,
                                  Category = _dbContext.GetDataValueName("Patient Main Category", rg.Patient_Main_Category),
                                  Mobile1 = rg.Mobile1,
                                  Status = p.Status
                              };

                    var FilteredCount = pat.Count();
                    switch (sortColumn)
                    {
                        case "Out_Patient_ID":
                            pat = sortColumnDirection == "asc" ? pat.OrderBy(a => a.Out_Patient_ID) : pat.OrderByDescending(a => a.Out_Patient_ID);
                            break;
                        case "mr_no_sequence":
                            pat = sortColumnDirection == "asc" ? pat.OrderBy(a => a.mr_no_sequence) : pat.OrderByDescending(a => a.mr_no_sequence);
                            break;
                        case "Created_Time":
                            pat = sortColumnDirection == "asc" ? pat.OrderBy(a => a.Created_Time) : pat.OrderByDescending(a => a.Created_Time);
                            break;
                        case "Mobile1":
                            pat = sortColumnDirection == "asc" ? pat.OrderBy(a => a.Mobile1) : pat.OrderByDescending(a => a.Mobile1);
                            break;
                        default:
                            pat = pat.OrderByDescending(a => a.Out_Patient_ID);
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

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "OutPatientsView";

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
        public static void SaveUserColumnPreferences(string visibilityJson)
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "OutPatientsView";

                using (var db = new DataBaseDataContext())
                {
                    var existing = db.UserDataTablePreferences
                                     .FirstOrDefault(p => p.UserID == userId && p.PageName == pageName);

                    if (existing != null)
                    {
                        existing.ColumnVisibility = visibilityJson;
                    }
                    else
                    {
                        db.UserDataTablePreferences.InsertOnSubmit(new UserDataTablePreference
                        {
                            UserID = userId,
                            PageName = pageName,
                            ColumnVisibility = visibilityJson
                        });
                    }

                    db.SubmitChanges();
                }
            }
            catch (Exception ex)
            {
                throw;
            }
        }
        [WebMethod]
        public static string GetOutPatientNewFormRedirectPermission()
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var sysParm = db.sys_Parms
                        .Where(p => p.Name == "OutPatient New Form Redirect"
                                 && p.Company_ID == AppConfig.Company_ID)
                        .Select(p => p.Code)
                        .FirstOrDefault();

                    return new JavaScriptSerializer().Serialize(new { useNewForm = sysParm == "1" });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { useNewForm = false, error = ex.Message });
            }
        }
    }
}