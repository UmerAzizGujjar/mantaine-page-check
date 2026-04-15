using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Administrator
{
    public partial class TokenListIITH : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string LoadDoctorTokenPatients()
        {
            try
            {
                Guid currentUserIdGuid = AppConfig.UserID;
                string currentUserIdString = currentUserIdGuid.ToString();

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var doctorRecord = (from emp in db.HR_Employees
                                        where emp.userid == currentUserIdString
                                              && emp.IsDoctor == true
                                        select new { emp.Emp_ID, emp.Emp_Name }).FirstOrDefault();

                    if (doctorRecord == null)
                    {
                        return new JavaScriptSerializer().Serialize(new List<object>());
                    }

                    int doctorEmpId = doctorRecord.Emp_ID;
                    string doctorName = doctorRecord.Emp_Name;

                    DateTime todayStart = DateTime.Today;
                    DateTime tomorrowStart = DateTime.Today.AddDays(1);

                    var patients = (from p in db.Patients
                                    join op in db.Out_Patients on p.Patient_ID equals op.Patient_ID into opGroup
                                    from op in opGroup.DefaultIfEmpty()
                                    where
                                        p.Doctor_ID == Convert.ToString(doctorEmpId)
                                        && p.Patient_Type == "02"
                                        && p.Created_Time.HasValue
                                        && p.Created_Time.Value >= todayStart
                                        && p.Created_Time.Value < tomorrowStart
                                        && (op == null || op.BP_mm_Hg == null || op.BP_mm_Hg == "")
                                    select new
                                    {
                                        Patient_ID = p.Patient_ID,
                                        Full_Name = p.Full_Name,
                                        Opd_No = p.Opd_No,
                                        mr_no_sequence = p.mr_no_sequence ?? "",
                                        tokenNo = p.Doc_Token,

                                        filter_clinic = p.filter_clinic ?? "",
                                        Created_Time = p.Created_Time,
                                        Doctor_ID = p.Doctor_ID,

                                        doc_name = doctorName
                                    }).OrderBy(x => x.tokenNo)
                                      .ToList();

                    return new JavaScriptSerializer().Serialize(patients);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"=== ERROR LoadDoctorTokenPatients ===");
                System.Diagnostics.Debug.WriteLine($"Message: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"StackTrace: {ex.StackTrace}");

                return new JavaScriptSerializer().Serialize(new
                {
                    error = ex.Message,
                    stack = ex.StackTrace
                });
            }
        }

        [WebMethod]
        public static string GetCurrentDoctorName()
        {
            try
            {
                Guid currentUserIdGuid = AppConfig.UserID;
                string currentUserIdString = currentUserIdGuid.ToString();

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var doctor = (from emp in db.HR_Employees
                                  where emp.userid == currentUserIdString
                                  select emp.Emp_Name).FirstOrDefault();

                    return new JavaScriptSerializer().Serialize(new { doctorName = doctor ?? "Doctor" });
                }
            }
            catch
            {
                return new JavaScriptSerializer().Serialize(new { doctorName = "Doctor" });
            }
        }
    }
}