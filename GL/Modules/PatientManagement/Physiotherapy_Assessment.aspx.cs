using System;
using System.Linq;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.Script.Services;

namespace PMS.Modules.PatientManagement
{
    public partial class Physiotherapy_Assessment : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                if (Request.QueryString["ID"] != null)
                {
                    int outPatientId = Convert.ToInt32(Request.QueryString["ID"]);
                    LoadPatientData(outPatientId);
                }
            }
        }

        private void LoadPatientData(int outPatientId)
        {
            using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var qry = (from op in db.Out_Patients
                           join p in db.Patients on op.Patient_ID equals p.Patient_ID
                           join rp in db.Reg_patients on p.Reg_PatId equals rp.pat_id
                           where op.Out_Patient_ID == outPatientId
                           select new
                           {
                               op.Patient_ID,
                               op.OPD_Entry_Date,
                               op.pulse_Min,
                               op.BP_mm_Hg,
                               op.Temp_C,
                               op.Respiration_Min,
                               op.Height_Cm,
                               op.Weight_Kg,
                               op.Recommended_Department,
                               op.Refering_Doctor,
                               p.Full_Name,
                               p.Age_years,
                               p.Gender,
                               p.Mobile1,
                               p.Patient_No,
                               p.Patient_Main_Category
                           }).FirstOrDefault();

                if (qry != null)
                {
                    string mrNo = "MR-" + (qry.Patient_No?.ToString() ?? "");
                    string fullName = qry.Full_Name ?? "";
                    string age = qry.Age_years ?? "";
                    string genderCode = qry.Gender ?? "";
                    string genderDisplay = GetDisplayName(db, "Gender", genderCode);
                    string contact = qry.Mobile1 ?? "";
                    string deptCode = qry.Patient_Main_Category ?? "";
                    string deptDisplay = GetDisplayName(db, "Patient Main Category", deptCode);

                    var data = new
                    {
                        display = mrNo + " - " + fullName,
                        age = age,
                        gender = genderDisplay,
                        contact = contact,
                        referredBy = deptDisplay,
                        pulse = qry.pulse_Min ?? "--",
                        bp = qry.BP_mm_Hg ?? "--",
                        temp = qry.Temp_C ?? "--",
                        resp = qry.Respiration_Min ?? "--",
                        height = qry.Height_Cm ?? "--",
                        weight = qry.Weight_Kg ?? "--"
                    };

                    string script = "populatePatient(" + new JavaScriptSerializer().Serialize(data) + ");";
                    ClientScript.RegisterStartupScript(GetType(), "loadPatient", script, true);
                }
            }
        }

        private string GetDisplayName(DataBaseDataContext db, string valueSet, string valueName)
        {
            if (string.IsNullOrEmpty(valueName)) return "";
            return db.GetDataValueName(valueSet, valueName) ?? valueName;
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static string LoadDoctors()
        {
            using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var doctors = db.HR_Employees
                    .Where(e => e.IsDoctor == true)
                    .Select(e => new { e.Emp_ID, e.Emp_Name })
                    .ToList();
                return new JavaScriptSerializer().Serialize(doctors);
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static string LoadDataValues(string valueSetName)
        {
            using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var values = (from dv in db.DataValues
                              join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                              where vs.ValueSet_Name == valueSetName
                              select new { dv.DataValue_Name, dv.DataValue_Description })
                             .ToList();
                return new JavaScriptSerializer().Serialize(values);
            }
        }
    }
}
