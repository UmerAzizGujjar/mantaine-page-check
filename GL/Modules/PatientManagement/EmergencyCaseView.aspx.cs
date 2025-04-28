using Infragistics.Web.UI.GridControls;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class EmergencyCaseView : System.Web.UI.Page
    {
        DataBaseDataContext db = new DataBaseDataContext();
  

        protected override void OnInit(EventArgs e)
        {
            if (Session["Company_ID"] != null)
            {
                base.OnInit(e);
            }
            else
            {
                Session.Abandon();
                Response.Redirect("~/Account/Login.aspx", true);
            }

        }

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string DeleteRecord(int Emergency_PatientID)
        {

            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var patID = (int)(from tbl in db.Emergency_Patients
                              where tbl.Emergency_ID == (int)Emergency_PatientID
                              select tbl.Patient_ID).FirstOrDefault();

            var patbill = (from tbl in db.Ar_Billings
                           where tbl.Patient_ID == (int)patID && (tbl.isCancel == null ? false : tbl.isCancel) == false
                           select tbl).FirstOrDefault();
            if (patbill == null)
            {
                SqlTransaction tranObj = null;
                SqlConnection con = new SqlConnection(DBClass.ConnectionString());
                con.Open();
                tranObj = con.BeginTransaction();
                try
                {
                    bool rowDeleted = DBClass.exectueQuery("Delete Emergency_Patient Where Emergency_ID=" + Convert.ToInt32(Emergency_PatientID) + "; Delete from Ward_Allocation where EmergencyID = " + Emergency_PatientID.ToString() + "", tranObj, con);


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

                    var Total_EmergencyCase = _dbContext.Emergency_Patients.Count();
                    var EmergencyCase = from EP in _dbContext.Emergency_Patients
                                        join p in _dbContext.Reg_patients on EP.Patient_ID equals p.pat_id
                                        where (
                                         (EP.Emergency_ID.ToString().Contains(searchValue) || p.mr_no_sequence.Contains(searchValue) || p.Full_Name.Contains(searchValue) || _dbContext.GetDataValueName("Patient Main Category", EP.Department).Contains(searchValue)))
                                        select new
                                  {
                                      Emergency_ID = EP.Emergency_ID,
                                      Admission_Date = EP.Admission_Date,
                                      mr_no_sequence = p.mr_no_sequence,
                                      Full_Name = p.Full_Name,
                                      Father_Name = p.Father_Name,
                                      Department =  EP.Department,
                                      Discharge_On = EP.Discharge_On,
                                  };

                    var FilteredCount = EmergencyCase.Count();
                    switch (sortColumn)
                    {
                        case "Emergency_ID":
                            EmergencyCase = sortColumnDirection == "asc" ? EmergencyCase.OrderBy(a => a.Emergency_ID) : EmergencyCase.OrderByDescending(a => a.Emergency_ID);
                            break;
                        case "mr_no_sequence":
                            EmergencyCase = sortColumnDirection == "asc" ? EmergencyCase.OrderBy(b => b.mr_no_sequence) : EmergencyCase.OrderByDescending(a => a.mr_no_sequence);
                            break;
                        case "Discharge_On":
                            EmergencyCase = sortColumnDirection == "asc" ? EmergencyCase.OrderBy(a => a.Discharge_On) : EmergencyCase.OrderByDescending(a => a.Discharge_On);
                            break;
                        default:
                            EmergencyCase = EmergencyCase.OrderBy(a => a.Emergency_ID);
                            break;
                    }

                    var patientList = EmergencyCase.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_EmergencyCase, data = patientList };
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
