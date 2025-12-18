using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Linq.SqlClient;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class InPatientsDischargeList : System.Web.UI.Page
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
                    bool rowDeleted = DBClass.exectueQuery("Delete In_Patient Where In_Patient_ID=" + Convert.ToInt32(InPatientID) + "", tranObj, con);


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

                    var Total_Patients = _dbContext.Reg_patients.Count();
                    var Discharge = from P in _dbContext.Reg_patients
                                    join opd in _dbContext.In_Patients on P.pat_id equals opd.Patient_ID
                                    where opd.Discharge == true && (opd.is_cancel ?? false) == false &&
                                     ((P.mr_no_sequence.Contains(searchValue) || P.Full_Name.Contains(searchValue) || _dbContext.GetDataValueName("Patient Main Category", opd.Department).Contains(searchValue) || _dbContext.GetDataValueName("Patient Type", opd.Patient_Discount_Type).Contains(searchValue)))
                                        select new
                                        {
                                            In_Patient_ID = opd.In_Patient_ID,
                                            Admission_Date = opd.Admission_Date,
                                            mr_no_sequence = P.mr_no_sequence,
                                            Full_Name = P.Full_Name,
                                            Father_Name = P.Father_Name,
                                            Department = _dbContext.GetDataValueName("Patient Main Category", opd.Department),
                                            Patient_Type = _dbContext.GetDataValueName("Patient Type", opd.Patient_Discount_Type),
                                            Discharge_By = Convert.ToString(_dbContext.getUserName(Convert.ToString(opd.Discharge_By))),
                                            Discharge_On = opd.Discharge_On,
                                            AdmitDays = SqlMethods.DateDiffDay(opd.Admission_Date, DateTime.Now)
                                        };

                    var FilteredCount = Discharge.Count();
                    switch (sortColumn)
                    {
                        case "Department":
                            Discharge = sortColumnDirection == "asc" ? Discharge.OrderBy(a => a.Department) : Discharge.OrderByDescending(a => a.Department);
                            break;
                        case "mr_no_sequence":
                            Discharge = sortColumnDirection == "asc" ? Discharge.OrderBy(b => b.mr_no_sequence) : Discharge.OrderByDescending(a => a.mr_no_sequence);
                            break;
                        case "Patient_Type":
                            Discharge = sortColumnDirection == "asc" ? Discharge.OrderBy(b => b.Patient_Type) : Discharge.OrderByDescending(a => a.Patient_Type);
                            break;
                        case "Discharge_On":
                            Discharge = sortColumnDirection == "asc" ? Discharge.OrderBy(a => a.Discharge_On) : Discharge.OrderByDescending(a => a.Discharge_On);
                            break;
                        default:
                            Discharge = Discharge.OrderByDescending(a => a.In_Patient_ID);
                            break;
                    }

                    var patientList = Discharge.Skip(start).Take(length).ToList();

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
