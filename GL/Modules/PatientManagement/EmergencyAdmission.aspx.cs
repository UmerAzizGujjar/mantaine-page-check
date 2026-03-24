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
                                            Status = e.Admitted_Status ?? "Pending",
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
                        emergency.Admitted_Status = status;
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
                        admission.emer_id = data.Emergency_ID;
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
                        emergency.Admitted_Status = "Admitted";
                        db.SubmitChanges();
                    }

                    // ✅ SAVE WARD ALLOCATION
                    if (!string.IsNullOrEmpty(data.ddlWard_No) && data.ddlWard_No != "0"
                        && !string.IsNullOrEmpty(data.txtBed_No))
                    {
                        SaveWardAllocation(db, data.Patient_ID.ToString(),
                            admission.Emergency_ID.ToString(),
                            data.ddlWard_No,
                            data.txtBed_No,
                            data.ddlDoctor,
                            false);
                    }

                    return admission.Emergency_ID.ToString();
                }
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        // Helper method for ward allocation
        private static void SaveWardAllocation(DataBaseDataContext db, string patID, string emergencyID,
            string wardID, string bedNo, string doctorID, bool discharge)
        {
            try
            {
                var wardAlloc = new Ward_Allocation();
                wardAlloc.Created_By = AppConfig.UserID;
                wardAlloc.Created_Time = DateTime.Now;
                wardAlloc.Book_ID = AppConfig.Book_ID;
                wardAlloc.Company_ID = AppConfig.Company_ID;
                wardAlloc.From_TimeDate = DateTime.Now;
                wardAlloc.Patient_ID = Convert.ToInt32(patID);
                wardAlloc.EmergencyID = Convert.ToInt32(emergencyID);
                wardAlloc.Ward_ID = Convert.ToInt32(wardID);
                wardAlloc.Bed_No_Assigned = Convert.ToInt32(bedNo);
                wardAlloc.Doctor_Assigned = string.IsNullOrEmpty(doctorID) ? 0 : Convert.ToInt32(doctorID);
                wardAlloc.IsDischarge = discharge;

                db.Ward_Allocations.InsertOnSubmit(wardAlloc);
                db.SubmitChanges();
            }
            catch { }
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
            public string PatientNo { get; set; }
            public int BedNo { get; set; }
            public string Full_Name { get; set; }
            public DateTime? AdmissionDate { get; set; }
        }
        [WebMethod]
        public static string FillWardBeds(int WardID)
        {
            List<Beds> bdsList = new List<Beds>();
            if (WardID > 0)
            {
                DataBaseDataContext db = new DataBaseDataContext();
                int Beds = (int)(from bds in db.Ward_Definitions
                                 where bds.Ward_ID == WardID
                                 select bds.No_Of_Beds).SingleOrDefault();

                for (int i = 1; i <= Beds; i++)
                {
                    var patID = (from p in db.Ward_Allocations
                                 where p.Bed_No_Assigned == (int)(i)
                                     && p.Ward_ID == WardID
                                     && p.IsDischarge == false
                                 select p.Patient_ID).FirstOrDefault();

                    DateTime? admDate = null;
                    string patientName = "";
                    string mrNo = "0";

                    if (patID != null)
                    {
                        var patient = (from p in db.Reg_patients
                                       where p.pat_id == patID
                                       select new { p.mr_no_sequence, p.Full_Name }).FirstOrDefault();

                        if (patient != null)
                        {
                            mrNo = patient.mr_no_sequence ?? "0";
                            patientName = patient.Full_Name ?? "";
                        }

                        admDate = db.Emergency_Patients
                            .Where(e => e.Patient_ID == patID)
                            .Select(e => e.Admission_Date)
                            .FirstOrDefault();
                    }

                    Beds b = new Beds();
                    b.BedNo = i;
                    b.WardID = WardID;
                    b.PatientNo = mrNo;
                    b.Full_Name = patientName;
                    b.AdmissionDate = admDate;
                    bdsList.Add(b);
                }
            }
            return (new JavaScriptSerializer().Serialize(bdsList));
        }

        [WebMethod]
        public static string SaveWardInformation(string btnsave, string PatID, string EmergencyID,
    string ddlWard_No, string txtBed_No, string ddlDoctor, bool DichargChk)
        {
            try
            {
                Ward_Allocation ward_aloct = null;  // ✅ Initialize to null
                DataBaseDataContext db = new DataBaseDataContext();

                if (btnsave == "Update")
                {
                    ward_aloct = db.Ward_Allocations.FirstOrDefault(w =>
                        w.EmergencyID == Convert.ToInt32(EmergencyID)
                        && w.Patient_ID == Convert.ToInt32(PatID)
                        && w.Ward_ID == Convert.ToInt32(ddlWard_No)
                        && w.Bed_No_Assigned == Convert.ToInt32(txtBed_No));

                    if (ward_aloct != null && !DichargChk)
                    {
                        ward_aloct.Updated_By = AppConfig.UserID;
                        ward_aloct.Updated_Time = DateTime.Now;
                    }
                    else if (ward_aloct != null && DichargChk)
                    {
                        ward_aloct.Updated_By = AppConfig.UserID;
                        ward_aloct.Updated_Time = DateTime.Now;
                        ward_aloct.IsDischarge = true;
                    }
                }
                else if (btnsave == "Save")
                {
                    ward_aloct = db.Ward_Allocations.FirstOrDefault(w =>
                        w.Ward_ID == Convert.ToInt32(ddlWard_No)
                        && w.EmergencyID == Convert.ToInt32(EmergencyID)
                        && w.Patient_ID == Convert.ToInt32(PatID)
                        && w.Bed_No_Assigned == Convert.ToInt32(txtBed_No)
                        && w.IsDischarge == false);

                    if (ward_aloct == null)
                    {
                        ward_aloct = new Ward_Allocation
                        {
                            Created_By = AppConfig.UserID,
                            Created_Time = DateTime.Now,
                            Book_ID = AppConfig.Book_ID,
                            Company_ID = AppConfig.Company_ID,
                            From_TimeDate = DateTime.Now,
                            Patient_ID = Convert.ToInt32(PatID),
                            Ward_ID = Convert.ToInt32(ddlWard_No),
                            Bed_No_Assigned = Convert.ToInt32(txtBed_No),
                            Doctor_Assigned = string.IsNullOrEmpty(ddlDoctor) ? 0 : Convert.ToInt32(ddlDoctor),
                            EmergencyID = Convert.ToInt32(EmergencyID),
                            IsDischarge = DichargChk
                        };
                        db.Ward_Allocations.InsertOnSubmit(ward_aloct);

                        // Mark previous allocations as discharged
                        var previousHistory = db.Ward_Allocations
                            .Where(w => w.EmergencyID == Convert.ToInt32(EmergencyID)
                                && w.Patient_ID == Convert.ToInt32(PatID)
                                && w.IsDischarge == false).ToList();

                        foreach (var ward in previousHistory)
                        {
                            ward.IsDischarge = true;
                            ward.To_TimeDate = DateTime.Now;
                        }

                        // Check for duplicate bed allocation
                        var duplicateBed = db.Ward_Allocations
                            .FirstOrDefault(w => w.Ward_ID == Convert.ToInt32(ddlWard_No)
                                && w.EmergencyID != Convert.ToInt32(EmergencyID)
                                && w.Patient_ID != Convert.ToInt32(PatID)
                                && w.Bed_No_Assigned == Convert.ToInt32(txtBed_No)
                                && w.IsDischarge == false);

                        if (duplicateBed != null)
                        {
                            duplicateBed.IsDischarge = true;
                            duplicateBed.To_TimeDate = DateTime.Now;
                        }
                    }
                    else
                    {
                        // Update existing record
                        ward_aloct.Updated_By = AppConfig.UserID;
                        ward_aloct.Updated_Time = DateTime.Now;
                        ward_aloct.IsDischarge = DichargChk;
                    }
                }
                else
                {
                    return "Error: Invalid btnsave value";
                }

                // ✅ Only proceed if ward_aloct was assigned
                if (ward_aloct != null)
                {
                    // Set common properties (only if not already set in Save block)
                    if (btnsave == "Update")
                    {
                        ward_aloct.Patient_ID = Convert.ToInt32(PatID);
                        ward_aloct.Ward_ID = Convert.ToInt32(ddlWard_No);
                        ward_aloct.Bed_No_Assigned = Convert.ToInt32(txtBed_No);
                        ward_aloct.Doctor_Assigned = string.IsNullOrEmpty(ddlDoctor) ? 0 : Convert.ToInt32(ddlDoctor);
                        ward_aloct.EmergencyID = Convert.ToInt32(EmergencyID);
                    }

                    db.SubmitChanges();
                    return "Success";
                }

                return "Error: Ward allocation record could not be created or found";
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        [WebMethod]
        public static string FillRooms(string RoomType)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var Rmdetail = (from rm in db.Rooms
                                    where rm.Room_Type == RoomType
                                    select new
                                    {
                                        rm.Room_No,
                                        rm.Room_ID,
                                        rm.Name,
                                        rm.Room_Type,
                                        PatientNmae = ((from room in db.Room_Allocations
                                                        join p in db.Reg_patients on room.Patient_ID equals p.pat_id
                                                        where room.Room_ID == rm.Room_ID && room.IsDischarge == false
                                                        select p.Patient_No).FirstOrDefault()),
                                    }).ToList();
                    return new JavaScriptSerializer().Serialize(Rmdetail);
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { error = ex.Message });
            }
        }

        [WebMethod]
        public static string SaveRoomInformation(string btnsave, int PatID, int InPatID, string ddlRoom_No, string txtRoom_Type, string txtExpected_Discharge_Date, string ddlDoctor, bool DichargChk)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext();
                Room_Allocation room_aloct;
                room_aloct = (from tbl in db.Room_Allocations
                              where tbl.Room_Type == txtRoom_Type
                              && tbl.In_Patient_ID == InPatID && tbl.Patient_ID == Convert.ToInt32(PatID)
                              && tbl.Room_ID == Convert.ToInt32(ddlRoom_No) && tbl.IsDischarge == false
                              select tbl).FirstOrDefault();

                if (room_aloct == null)
                {
                    room_aloct = new Room_Allocation();
                    room_aloct.Created_By = AppConfig.UserID;
                    room_aloct.Created_Time = DateTime.Now;
                    room_aloct.Book_ID = AppConfig.Book_ID;
                    room_aloct.Company_ID = AppConfig.Company_ID;
                    room_aloct.From_Date = Convert.ToDateTime(DateTime.Now);
                    db.Room_Allocations.InsertOnSubmit(room_aloct);

                    var PreviousRoomHistory = (from tbl in db.Room_Allocations
                                               join inpat in db.In_Patients
                                               on tbl.In_Patient_ID equals inpat.In_Patient_ID
                                               where tbl.In_Patient_ID == Convert.ToInt32(InPatID) && tbl.Patient_ID == Convert.ToInt32(PatID)
                                               && tbl.IsDischarge == false
                                               select tbl).ToList();
                    if (PreviousRoomHistory.Count != 0)
                    {
                        foreach (var rm in PreviousRoomHistory)
                        {
                            rm.IsDischarge = true;
                            rm.To_Date = Convert.ToDateTime(DateTime.Now);
                        }
                    }
                }
                else
                {
                    room_aloct.Updated_By = AppConfig.UserID;
                    room_aloct.Updated_Time = DateTime.Now;
                }

                room_aloct.In_Patient_ID = InPatID;
                room_aloct.Patient_ID = Convert.ToInt32(PatID);
                room_aloct.Room_ID = Convert.ToInt32(ddlRoom_No);
                room_aloct.Room_Type = txtRoom_Type;

                if (DichargChk == true)
                {
                    room_aloct.IsDischarge = true;
                }
                else
                {
                    room_aloct.IsDischarge = false;
                }

                db.SubmitChanges();
                return "Success";
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        [WebMethod]
        public static string GetRoomTypes()
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var roomTypes = (from dv in db.DataValues
                                     join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                     where vs.ValueSet_Name == "Room Type"
                                     select new
                                     {
                                         dv.DataValue_Name,
                                         dv.DataValue_Description
                                     }).ToList();
                    return new JavaScriptSerializer().Serialize(roomTypes);
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { error = ex.Message });
            }
        }

        //[WebMethod]
        //public static string FillWardBeds(int WardID)
        //{
        //    try
        //    {
        //        List<Beds> bdsList = new List<Beds>();
        //        if (WardID > 0)
        //        {
        //            using (DataBaseDataContext db = new DataBaseDataContext())
        //            {
        //                int Beds = (int)(from bds in db.Ward_Definitions
        //                                where bds.Ward_ID == WardID
        //                                select bds.No_Of_Beds).SingleOrDefault();

        //                for (int i = 1; i <= Beds; i++)
        //                {
        //                    var patID = (from p in db.Ward_Allocations
        //                                where p.Bed_No_Assigned == i && p.Ward_ID == WardID && p.IsDischarge == false
        //                                select p.Patient_ID).FirstOrDefault();

        //                    if (patID == null)
        //                    {
        //                        patID = 0;
        //                    }
        //                    else
        //                    {
        //                        patID = (from p in db.Reg_patients
        //                                where p.pat_id == patID
        //                                select p.Patient_No).FirstOrDefault();
        //                    }

        //                    if (patID == null)
        //                    {
        //                        patID = 0;
        //                    }

        //                    Beds b = new Beds();
        //                    b.BedNo = i;
        //                    b.PatientNo = (int)patID;
        //                    b.WardID = WardID;
        //                    bdsList.Add(b);
        //                }
        //            }
        //        }
        //        return new JavaScriptSerializer().Serialize(bdsList);
        //    }
        //    catch (Exception ex)
        //    {
        //        return new JavaScriptSerializer().Serialize(new { error = ex.Message });
        //    }
        //}
    }
}