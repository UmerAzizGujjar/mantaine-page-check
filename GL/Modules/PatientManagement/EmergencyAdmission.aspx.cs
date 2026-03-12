using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.PatientManagement
{
    public partial class EmergencyAdmission : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Check if Emergency_ID is in query string for edit mode
                if (Request.QueryString["Emergency_ID"] != null)
                {
                    // Edit mode will be handled client-side
                }
            }
        }

        [WebMethod]
        public static string GetEmergencyWaitingList()
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var emergencyList = (from e in db.Emergencies
                                        join p in db.Reg_patients on e.Reg_PatId equals p.pat_id
                                        where (e.isCancel == false || e.isCancel == null)
                                        orderby e.Emer_id descending
                                        select new
                                        {
                                            Emergency_ID = e.Emer_id,
                                            Emergency_No = e.Emergency_No ?? 0,
                                            MR_No = p.mr_no_sequence ?? "",
                                            Patient_Name = p.Full_Name ?? "",
                                            Age = p.Age_years ?? "",
                                            Created_Time = e.Created_Time,
                                            Status = e.Status ?? "Pending",
                                            Patient_ID = e.Reg_PatId
                                        }).ToList();

                    return new JavaScriptSerializer().Serialize(emergencyList);
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { error = ex.Message });
            }
        }

        [WebMethod]
        public static string UpdateEmergencyStatus(int Emergency_ID, string status)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var emergency = db.Emergencies.FirstOrDefault(e => e.Emer_id == Emergency_ID);
                    if (emergency != null)
                    {
                        emergency.Status = status;
                        db.SubmitChanges();
                        return "Success";
                    }
                    return "Error: Emergency record not found";
                }
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        public class AdmissionData
        {
            public int Emergency_Patient_ID { get; set; }
            public int Emergency_ID { get; set; }
            public int Patient_ID { get; set; }
            public string btnAction { get; set; }
            public string ddlPatientCondition { get; set; }
            public string txtTreatmentTime { get; set; }
            public string txtAdmission_Date { get; set; }
            public string txtadmissionfee { get; set; }
            public string ddlDepartment { get; set; }
            public string ddlDoctor { get; set; }
            public string ddlIssuance_Of { get; set; }
            public string ddlWard_No { get; set; }
            public string txtBed_No { get; set; }
        }

        [WebMethod]
        public static string SaveAdmission(AdmissionData data)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    Emergency_Patient admission;
                    
                    if (data.btnAction == "Save")
                    {
                        admission = new Emergency_Patient();
                        admission.Patient_ID = data.Patient_ID;
                        admission.Created_By = AppConfig.UserID;
                        admission.Created_Time = DateTime.Now;
                        admission.Company_ID = AppConfig.Company_ID;
                        admission.Book_ID = AppConfig.Book_ID;
                    }
                    else
                    {
                        admission = db.Emergency_Patients.FirstOrDefault(ep => ep.Emergency_ID == data.Emergency_Patient_ID);
                        if (admission == null)
                            return "Error: Admission record not found";
                        
                        admission.Updated_By = AppConfig.UserID;
                        admission.Updated_Time = DateTime.Now;
                    }

                    // Set admission fields
                    if (!string.IsNullOrEmpty(data.txtAdmission_Date))
                        admission.Admission_Date = Convert.ToDateTime(data.txtAdmission_Date);
                    else
                        admission.Admission_Date = DateTime.Now;

                    admission.Emergency_Pat_Condition = data.ddlPatientCondition ?? "01";
                    admission.Department = data.ddlDepartment ?? "";
                    admission.Doctor = data.ddlDoctor ?? "";
                    admission.Issuance_Of = data.ddlIssuance_Of ?? "";

                    if (!string.IsNullOrEmpty(data.txtadmissionfee))
                        admission.Admission_Fees = int.Parse(data.txtadmissionfee);

                    if (!string.IsNullOrEmpty(data.ddlWard_No) && data.ddlWard_No != "0")
                        admission.Ward_ID = Convert.ToInt32(data.ddlWard_No);

                    if (!string.IsNullOrEmpty(data.txtBed_No) && int.TryParse(data.txtBed_No, out int bedNo))
                        admission.Bed_No = bedNo;

                    if (!string.IsNullOrEmpty(data.txtTreatmentTime))
                        admission.TreatmentTime = Convert.ToDateTime(data.txtTreatmentTime);
                    else
                        admission.TreatmentTime = DateTime.Now;

                    if (data.btnAction == "Save")
                    {
                        db.Emergency_Patients.InsertOnSubmit(admission);
                    }

                    db.SubmitChanges();

                    // Update Emergency table status
                    var emergency = db.Emergencies.FirstOrDefault(e => e.Emer_id == data.Emergency_ID);
                    if (emergency != null)
                    {
                        emergency.Status = "Admitted";
                        db.SubmitChanges();
                    }

                    return admission.Emergency_ID.ToString();
                }
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        [WebMethod]
        public static string GetAdmissionData(int Emergency_Patient_ID)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var admission = (from ep in db.Emergency_Patients
                                    join e in db.Emergencies on ep.Patient_ID equals e.Reg_PatId
                                    join p in db.Reg_patients on ep.Patient_ID equals p.pat_id
                                    where ep.Emergency_ID == Emergency_Patient_ID
                                    select new
                                    {
                                        Emergency_Patient_ID = ep.Emergency_ID,
                                        Emergency_ID = e.Emer_id,
                                        Patient_ID = ep.Patient_ID,
                                        Patient_Name = p.Full_Name,
                                        MR_No = p.mr_no_sequence,
                                        Emergency_No = e.Emergency_No,
                                        Age = p.Age_years,
                                        Contact = p.Mobile1,
                                        ddlPatientCondition = ep.Emergency_Pat_Condition,
                                        txtTreatmentTime = ep.TreatmentTime,
                                        txtAdmission_Date = ep.Admission_Date,
                                        txtadmissionfee = ep.Admission_Fees,
                                        ddlDepartment = ep.Department,
                                        ddlDoctor = ep.Doctor,
                                        ddlIssuance_Of = ep.Issuance_Of,
                                        ddlWard_No = ep.Ward_ID,
                                        txtBed_No = ep.Bed_No
                                    }).FirstOrDefault();

                    return new JavaScriptSerializer().Serialize(admission);
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { error = ex.Message });
            }
        }

        [WebMethod]
        public static string GetPatientInfo(int Emergency_ID)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var patientInfo = (from e in db.Emergencies
                                      join p in db.Reg_patients on e.Reg_PatId equals p.pat_id
                                      where e.Emer_id == Emergency_ID
                                      select new
                                      {
                                          Patient_ID = e.Reg_PatId,
                                          Emergency_ID = e.Emer_id,
                                          Patient_Name = p.Full_Name,
                                          MR_No = p.mr_no_sequence,
                                          Emergency_No = e.Emergency_No,
                                          Age = p.Age_years,
                                          Contact = p.Mobile1
                                      }).FirstOrDefault();

                    return new JavaScriptSerializer().Serialize(patientInfo);
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { error = ex.Message });
            }
        }

        [WebMethod]
        public static string GetTriageAreas()
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var triageAreas = (from dv in db.DataValues
                                      join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                      where vs.ValueSet_Name == "Patient Condition"
                                      select new
                                      {
                                          dv.DataValue_Name,
                                          dv.DataValue_Description
                                      }).ToList();

                    return new JavaScriptSerializer().Serialize(triageAreas);
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { error = ex.Message });
            }
        }

        [WebMethod]
        public static string GetDepartments()
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var departments = (from dv in db.DataValues
                                      join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                      where vs.ValueSet_Name == "Patient Main Category"
                                      select new
                                      {
                                          dv.DataValue_Name,
                                          dv.DataValue_Description
                                      }).ToList();

                    return new JavaScriptSerializer().Serialize(departments);
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { error = ex.Message });
            }
        }

        [WebMethod]
        public static string GetDoctors(string departmentId)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var doctors = (from emp in db.HR_Employees
                                  where emp.IsDoctor == true && 
                                        (string.IsNullOrEmpty(departmentId) || emp.Department == departmentId)
                                  select new
                                  {
                                      Emp_ID = emp.Emp_ID,
                                      Emp_Name = emp.Emp_Name
                                  }).ToList();

                    return new JavaScriptSerializer().Serialize(doctors);
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { error = ex.Message });
            }
        }

        [WebMethod]
        public static string GetAdmitToOptions()
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var options = (from dv in db.DataValues
                                  join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                  where vs.ValueSet_Name == "Laundary From To"
                                  select new
                                  {
                                      dv.DataValue_Name,
                                      dv.DataValue_Description
                                  }).ToList();

                    return new JavaScriptSerializer().Serialize(options);
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { error = ex.Message });
            }
        }

        [WebMethod]
        public static string GetWards()
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var wards = (from w in db.Ward_Definitions
                                select new
                                {
                                    Ward_ID = w.Ward_ID,
                                    Ward_Type = w.Ward_Type
                                }).ToList();

                    return new JavaScriptSerializer().Serialize(wards);
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { error = ex.Message });
            }
        }

        public class Beds
        {
            public int WardID { get; set; }
            public int PatientNo { get; set; }
            public int BedNo { get; set; }
        }

        [WebMethod]
        public static string FillWardBeds(int WardID)
        {
            try
            {
                List<Beds> bdsList = new List<Beds>();
                if (WardID > 0)
                {
                    using (DataBaseDataContext db = new DataBaseDataContext())
                    {
                        int Beds = (int)(from bds in db.Ward_Definitions
                                        where bds.Ward_ID == WardID
                                        select bds.No_Of_Beds).SingleOrDefault();

                        for (int i = 1; i <= Beds; i++)
                        {
                            var patID = (from p in db.Ward_Allocations
                                        where p.Bed_No_Assigned == i && p.Ward_ID == WardID && p.IsDischarge == false
                                        select p.Patient_ID).FirstOrDefault();

                            if (patID == null)
                            {
                                patID = 0;
                            }
                            else
                            {
                                patID = (from p in db.Reg_patients
                                        where p.pat_id == patID
                                        select p.Patient_No).FirstOrDefault();
                            }

                            if (patID == null)
                            {
                                patID = 0;
                            }

                            Beds b = new Beds();
                            b.BedNo = i;
                            b.PatientNo = (int)patID;
                            b.WardID = WardID;
                            bdsList.Add(b);
                        }
                    }
                }
                return new JavaScriptSerializer().Serialize(bdsList);
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { error = ex.Message });
            }
        }
    }
}