using Newtonsoft.Json;
using PMS.Modules.PatientManagement;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web.Data.Extensions;

namespace PMS.Modules.Dashboards
{
    public partial class NewEMR : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string getAppoitnmentInfo(int Patient_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var query = (from app in db.Appointment_Forms
                         where app.Reg_id == Patient_ID
                         && app.Status == "Booked"
                         orderby app.App_Date ascending
                         select new
                         {

                             AppointmentDate = app.App_Date,
                             doctor = (from emp in db.HR_Employees where emp.Emp_ID == Convert.ToInt32(app.Consultant_ID) select new { emp.Emp_Name }).FirstOrDefault()

                         }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(query);
        }



        [WebMethod]
        public static string GetLastAppointmentVisit(int Patient_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var query = (from app in db.Appointment_Forms
                         where app.Reg_id == Patient_ID
                         && app.Status == "Visited"
                         orderby app.App_Date descending
                         select new
                         {
                             AppointmentDate = app.App_Date,
                             doctor = (from emp in db.HR_Employees
                                       where emp.Emp_ID == Convert.ToInt32(app.Consultant_ID)
                                       select new { emp.Emp_Name }).FirstOrDefault(),
                             Department = db.GetDataValueName("Patient Main Category", app.Sub_Department)
                         }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static string GetBasicInfo(int Patient_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var query = (from rg in db.Reg_patients
                         where rg.pat_id == Patient_ID
                         select new
                         {

                             Name = rg.Full_Name,
                             FatherName = rg.Father_Name,
                             Relation = rg.Relation_prefix,
                             Gender = rg.Gender,
                             DOB = rg.DOB,
                             Age = rg.Age_years,
                             MaritalStatus = rg.Martial_Status,
                             Mr_No = rg.mr_no_sequence,
                             pat_no = rg.Patient_No,
                             Address = rg.Permanent_Address /*"H# " + rg.House_No + " " + rg.stno_mno + " " + rg.area + " " + rg.city*/,
                             Mobile = rg.Mobile1,
                             CNIC = rg.NIC,
                             HouseNo = rg.House_No,
                             Area = rg.area,
                             StreetNo = rg.stno_mno,
                             City = rg.city,
                             ValArea = rg.val_area,
                             ValCity = rg.val_city,
                             Reg_PatientID = rg.pat_id,
                             opdCount = db.Patients.Count(count => count.Reg_PatId == Patient_ID)

                         }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static string GetPatients(string searchValue)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var patients = (from p in db.Reg_patients
                                    where (p.Patient_No != null && p.Patient_No.ToString().Contains(searchValue))
                                          || (p.Full_Name != null && p.Full_Name.Contains(searchValue))
                                    select new
                                    {
                                        PatientNo = p.Patient_No,
                                        FullName = p.Full_Name,
                                        RegID = p.pat_id,
                                    }).Take(5).ToList();

                    return new JavaScriptSerializer().Serialize(patients);
                }
            }
            catch (Exception ex)
            {
                // Log error if needed
                return new JavaScriptSerializer().Serialize(new { error = ex.Message });
            }
        }
        [WebMethod]
        public static string CountVisits(int reg_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var patientIds = db.Out_Patients
    .Where(op => op.Reg_PatId == reg_id)
    .Select(op => op.Out_Patient_ID)
    .Concat(db.In_Patients
        .Where(ip => ip.Patient_ID == reg_id)
        .Select(ip => ip.In_Patient_ID))
    .Concat(db.Emergency_Patients
        .Where(ep => ep.Patient_ID == reg_id)
        .Select(ep => ep.Emergency_ID))
    .ToList();
            // Step 2: Get all medicine records matching any of these IDs
            var Medicenes = (from med in db.In_Patient_Medicines
                             where patientIds.Contains((int)med.Patient_ID)
                             select med).Count();
            // Get total count of patients with this regID
            var InvestigationCount = (from lbtM in db.Laboratory_Tests
                                      join lbtD in db.Lab_Test_Details
                                      on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                      join lab in db.Lab_Tests on lbtD.Test_ID equals lab.Test_ID

                                      where (patientIds.Contains((int)lbtD.Patient_ID) ||
                                                    lbtD.Patient_ID == reg_id)
                                      && lbtD.Dept_ID == "001"
                                      select lbtD).Count();
            var DiagnosticCount = (from lbtM in db.Laboratory_Tests
                                   join lbtD in db.Lab_Test_Details
                                   on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                   join lab in db.Lab_Tests on lbtD.Test_ID equals lab.Test_ID

                                   where (patientIds.Contains((int)lbtD.Patient_ID) ||
                                                    lbtD.Patient_ID == reg_id)
                                   && lbtD.Dept_ID != "001"
                                   select lbtD).Count();
            int OPD = db.Out_Patients.Where(t => t.Reg_PatId == reg_id).Count();


            int IPD = db.In_Patients.Where(t => t.Patient_ID == reg_id).Count();


            int Emergency = db.Emergency_Patients.Where(t => t.Patient_ID == reg_id).Count();
            var Procedures = (from ips in db.InPatientServices
                              where ips.PatientId == reg_id
                              select IPD).Count();
            var result = new
            {
                OutPatientCount = OPD,
                InPatientCount = IPD,
                EmergencyCaseCount = Emergency,
                MediceneCount = Medicenes,
                InvestigationCount = InvestigationCount,
                DiagnosticCount = DiagnosticCount,
                ProceduresCount = Procedures,
            };

            return (new JavaScriptSerializer()).Serialize(result);
        }
        [WebMethod]
        public static object OPDViewList(int regID, int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    // Total count
                    var Total_pat = _dbContext.Out_Patients.Count(op => op.Reg_PatId == regID);

                    var query = from op in _dbContext.Out_Patients
                                join p in _dbContext.Patients on op.Patient_ID equals p.Patient_ID
                                join emp in _dbContext.HR_Employees on op.Doctor_ID equals emp.Emp_ID.ToString() into empJoin
                                from emp in empJoin.DefaultIfEmpty()
                                where op.Reg_PatId == regID && p.isCancel == false
                                select new
                                {
                                    VisitNo = op.Out_Patient_ID,
                                    VisitDate = op.Created_Time.HasValue ? op.Created_Time.Value : (DateTime?)null,
                                    Department = _dbContext.GetDataValueName("Patient Main Category", p.Patient_Main_Category) ?? "N/A",
                                    PatientType = _dbContext.GetDataValueName("Patient Type", p.Patient_Type) ?? "N/A",
                                    CheckedBy = emp != null ? emp.Emp_Name : "N/A",
                                    Remarks = op.Final_Rec ?? "",
                                    DischargeDate = op.discharge_date.HasValue ? op.discharge_date.Value : (DateTime?)null,
                                    Status = op.Discharge.HasValue ? (op.Discharge.Value ? "Consulted" : "Active") : "Active"
                                };

                    // Apply search
                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        DateTime searchDate;
                        bool isDateSearch = DateTime.TryParse(searchValue, out searchDate);

                        query = query.Where(x =>
                            x.VisitNo.ToString().Contains(searchValue) ||
                            (x.Department != null && x.Department.Contains(searchValue)) ||
                            (x.PatientType != null && x.PatientType.Contains(searchValue)) ||
                            (x.CheckedBy != null && x.CheckedBy.Contains(searchValue)) ||
                            x.Status.Contains(searchValue) ||
                            (x.Remarks != null && x.Remarks.Contains(searchValue)) ||
                            (isDateSearch && (
                                (!x.VisitDate.HasValue || x.VisitDate.Value.Date == searchDate.Date) ||
                                (!x.DischargeDate.HasValue || x.DischargeDate.Value.Date == searchDate.Date)
                            ))
                        );
                    }

                    var FilteredCount = query.Count();

                    // Sorting
                    if (!string.IsNullOrEmpty(sortColumn))
                    {
                        switch (sortColumn)
                        {
                            case "VisitNo":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.VisitNo) : query.OrderByDescending(x => x.VisitNo);
                                break;
                            case "VisitDate":
                                query = sortColumnDirection == "asc"
                                    ? query.OrderBy(x => x.VisitDate ?? DateTime.MaxValue)
                                    : query.OrderByDescending(x => x.VisitDate ?? DateTime.MinValue);
                                break;
                            case "Department":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.Department) : query.OrderByDescending(x => x.Department);
                                break;
                            case "PatientType":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.PatientType) : query.OrderByDescending(x => x.PatientType);
                                break;
                            case "CheckedBy":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.CheckedBy) : query.OrderByDescending(x => x.CheckedBy);
                                break;
                            case "Status":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.Status) : query.OrderByDescending(x => x.Status);
                                break;
                            case "DischargeDate":
                                query = sortColumnDirection == "asc"
                                    ? query.OrderBy(x => x.DischargeDate ?? DateTime.MaxValue)
                                    : query.OrderByDescending(x => x.DischargeDate ?? DateTime.MinValue);
                                break;
                            default:
                                query = query.OrderByDescending(x => x.VisitDate ?? DateTime.MinValue);
                                break;
                        }
                    }
                    else
                    {
                        query = query.OrderByDescending(x => x.VisitDate ?? DateTime.MinValue);
                    }

                    // Pagination
                    var data = query.Skip(start).Take(length).AsEnumerable()
                        .Select(x => new
                        {
                            VisitNo = x.VisitNo,
                            VisitDate = x.VisitDate?.ToString("yyyy-MM-ddTHH:mm:ss"),
                            Department = x.Department,
                            PatientType = x.PatientType,
                            CheckedBy = x.CheckedBy,
                            Remarks = x.Remarks,
                            DischargeDate = x.DischargeDate?.ToString("yyyy-MM-ddTHH:mm:ss"),
                            Status = x.Status
                        }).ToList();

                    // Final result
                    var result = new
                    {
                        draw = draw,
                        recordsTotal = Total_pat,
                        recordsFiltered = FilteredCount,
                        data = data
                    };

                    // Serialize manually to avoid double-escaping
                    var json = Newtonsoft.Json.JsonConvert.SerializeObject(result);
                    return json;
                }
            }
            catch (Exception ex)
            {
                return Newtonsoft.Json.JsonConvert.SerializeObject(new
                {
                    draw = draw,
                    recordsTotal = 0,
                    recordsFiltered = 0,
                    data = new List<object>(),
                    error = ex.Message
                });
            }
        }
        [WebMethod]
        public static object IPDViewList(int regID, int draw, int start, int length,
                                  string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    // ✅ STEP 1: Base In_Patients
                    var ipList = _dbContext.In_Patients
                        .Where(ip => ip.Patient_ID == regID)
                        .ToList();

                    var Total_pat = ipList.Count;
                    if (Total_pat == 0)
                    {
                        return Newtonsoft.Json.JsonConvert.SerializeObject(new
                        {
                            draw = draw,
                            recordsTotal = 0,
                            recordsFiltered = 0,
                            data = new List<object>()
                        });
                    }

                    // In_Patient_ID is int
                    var ipIds = ipList.Select(x => x.In_Patient_ID).ToList();
                    // String version for Ward_Allocations.InPatient_ID which is string
                    var ipIdStrings = ipIds.Select(id => id.ToString()).ToList();

                    // ✅ STEP 2: Ward allocations
                    // InPatient_ID is STRING → use string comparison
                    var wardAllocs = _dbContext.Ward_Allocations
                        .Where(wa => wa.InPatient_ID != null
                                  && ipIdStrings.Contains(wa.InPatient_ID)
                                  && wa.IsDischarge != true
                                  && (wa.isCancelled == null || wa.isCancelled != true))
                        .ToList();

                    // ✅ STEP 3: Ward definitions
                    var wardIds = wardAllocs.Select(wa => wa.Ward_ID).Distinct().ToList();
                    var wardDefs = _dbContext.Ward_Definitions
                        .Where(wd => wardIds.Contains(wd.Ward_ID))
                        .ToList();

                    // ✅ STEP 4: Room allocations
                    // In_Patient_ID is int? → use .HasValue + .Value
                    var roomAllocs = _dbContext.Room_Allocations
                        .Where(raRow => raRow.In_Patient_ID.HasValue
                                     && ipIds.Contains(raRow.In_Patient_ID.Value))
                        .ToList();

                    var roomIds = roomAllocs.Select(raRow => raRow.Room_ID).Distinct().ToList();
                    var rooms = _dbContext.Rooms
                        .Where(roomRow => roomIds.Contains(roomRow.Room_ID))
                        .ToList();

                    // ✅ STEP 5: Doctors
                    // Emp_ID is int, Doctor_Assigned is int?
                    var doctorEmpIds = wardAllocs
                        .Where(wa => wa.Doctor_Assigned.HasValue && wa.Doctor_Assigned.Value > 0)
                        .Select(wa => wa.Doctor_Assigned.Value)
                        .ToList();

                    foreach (var ip in ipList)
                    {
                        if (!string.IsNullOrEmpty(ip.Doctor))
                        {
                            int docId;
                            if (int.TryParse(ip.Doctor, out docId) && docId > 0)
                                doctorEmpIds.Add(docId);
                        }
                    }
                    doctorEmpIds = doctorEmpIds.Distinct().ToList();

                    var doctors = _dbContext.HR_Employees
                        .Where(e => doctorEmpIds.Contains(e.Emp_ID))   // Emp_ID is int
                        .ToList();

                    // ✅ STEP 6: Build in memory
                    var allData = ipList.Select(ip =>
                    {
                        // wa.InPatient_ID is string, ip.In_Patient_ID is int
                        var wa = wardAllocs.FirstOrDefault(w =>
                            w.InPatient_ID == ip.In_Patient_ID.ToString());

                        var wd = wa != null
                            ? wardDefs.FirstOrDefault(w => w.Ward_ID == wa.Ward_ID)
                            : null;

                        // Room_Allocations.In_Patient_ID is int?
                        var raRow = roomAllocs.FirstOrDefault(rm =>
                            rm.In_Patient_ID.HasValue && rm.In_Patient_ID.Value == ip.In_Patient_ID);

                        var room = raRow != null
                            ? rooms.FirstOrDefault(rr => rr.Room_ID == raRow.Room_ID)
                            : null;

                        // Attending doctor
                        string attendingDoctor = "N/A";
                        if (wa != null && wa.Doctor_Assigned.HasValue)
                        {
                            var doc = doctors.FirstOrDefault(d => d.Emp_ID == wa.Doctor_Assigned.Value);
                            if (doc != null) attendingDoctor = doc.Emp_Name ?? "N/A";
                        }
                        else if (!string.IsNullOrEmpty(ip.Doctor))
                        {
                            int docId;
                            if (int.TryParse(ip.Doctor, out docId))
                            {
                                var doc = doctors.FirstOrDefault(d => d.Emp_ID == docId);
                                if (doc != null) attendingDoctor = doc.Emp_Name ?? "N/A";
                            }
                        }

                        // Department — GetDataValueName returns string, no .Value
                        string deptName = ip.Department ?? "N/A";
                        try
                        {
                            var resolved = _dbContext.GetDataValueName("Patient Main Category", ip.Department);
                            if (!string.IsNullOrEmpty(resolved))
                                deptName = resolved;
                        }
                        catch { /* keep code fallback */ }

                        string status =
                            ip.Discharge == true ? "Discharged" :
                            (ip.Death_Certificate == true ? "Deceased" : "Admitted");

                        return new
                        {
                            IPD_ID = ip.In_Patient_ID,
                            AdmissionDate = ip.Admission_Date?.ToString("yyyy-MM-ddTHH:mm:ss"),
                            Department = deptName,
                            WardName = wd != null ? wd.Ward_Type : "N/A",
                            RoomNo = room != null ? room.Room_No : "N/A",
                            BedNo = wa != null && wa.Bed_No_Assigned.HasValue
                                    ? wa.Bed_No_Assigned.Value.ToString() : "N/A",
                            AttendingDoctor = attendingDoctor,
                            ProvisionalDiagnosis = ip.Provisional_Diagnosis ?? "",
                            ExpectedDischargeDate = ip.Expected_Discharge_Date?.ToString("yyyy-MM-ddTHH:mm:ss"),
                            DischargeDate = ip.Discharge_On?.ToString("yyyy-MM-ddTHH:mm:ss"),
                            Status = status,
                            ReferringDoctor = ip.Referring_Doctor ?? "",
                            AdmissionType = ip.AdmissionType ?? "Regular"
                        };
                    }).ToList();

                    // ✅ STEP 7: Search
                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        DateTime searchDate;
                        bool isDateSearch = DateTime.TryParse(searchValue, out searchDate)
                                            && searchDate.Year >= 1753;
                        string datePrefix = isDateSearch ? searchDate.ToString("yyyy-MM-dd") : null;

                        allData = allData.Where(x =>
                            x.IPD_ID.ToString().Contains(searchValue) ||
                            (!string.IsNullOrEmpty(x.Department) && x.Department.IndexOf(searchValue, StringComparison.OrdinalIgnoreCase) >= 0) ||
                            (!string.IsNullOrEmpty(x.WardName) && x.WardName.IndexOf(searchValue, StringComparison.OrdinalIgnoreCase) >= 0) ||
                            (!string.IsNullOrEmpty(x.AttendingDoctor) && x.AttendingDoctor.IndexOf(searchValue, StringComparison.OrdinalIgnoreCase) >= 0) ||
                            (!string.IsNullOrEmpty(x.AdmissionType) && x.AdmissionType.IndexOf(searchValue, StringComparison.OrdinalIgnoreCase) >= 0) ||
                            (!string.IsNullOrEmpty(x.Status) && x.Status.IndexOf(searchValue, StringComparison.OrdinalIgnoreCase) >= 0) ||
                            (!string.IsNullOrEmpty(x.BedNo) && x.BedNo.Contains(searchValue)) ||
                            (!string.IsNullOrEmpty(x.RoomNo) && x.RoomNo.Contains(searchValue)) ||
                            (!string.IsNullOrEmpty(x.ProvisionalDiagnosis) && x.ProvisionalDiagnosis.IndexOf(searchValue, StringComparison.OrdinalIgnoreCase) >= 0) ||
                            (!string.IsNullOrEmpty(x.ReferringDoctor) && x.ReferringDoctor.IndexOf(searchValue, StringComparison.OrdinalIgnoreCase) >= 0) ||
                            (isDateSearch && (
                                (!string.IsNullOrEmpty(x.AdmissionDate) && x.AdmissionDate.StartsWith(datePrefix)) ||
                                (!string.IsNullOrEmpty(x.ExpectedDischargeDate) && x.ExpectedDischargeDate.StartsWith(datePrefix)) ||
                                (!string.IsNullOrEmpty(x.DischargeDate) && x.DischargeDate.StartsWith(datePrefix))
                            ))
                        ).ToList();
                    }

                    var FilteredCount = allData.Count;

                    // ✅ STEP 8: Sorting
                    switch (sortColumn)
                    {
                        case "IPD_ID":
                            allData = sortColumnDirection == "asc"
                                ? allData.OrderBy(x => x.IPD_ID).ToList()
                                : allData.OrderByDescending(x => x.IPD_ID).ToList();
                            break;
                        case "AdmissionDate":
                            allData = sortColumnDirection == "asc"
                                ? allData.OrderBy(x => x.AdmissionDate ?? "").ToList()
                                : allData.OrderByDescending(x => x.AdmissionDate ?? "").ToList();
                            break;
                        case "Department":
                            allData = sortColumnDirection == "asc"
                                ? allData.OrderBy(x => x.Department).ToList()
                                : allData.OrderByDescending(x => x.Department).ToList();
                            break;
                        case "WardName":
                            allData = sortColumnDirection == "asc"
                                ? allData.OrderBy(x => x.WardName).ToList()
                                : allData.OrderByDescending(x => x.WardName).ToList();
                            break;
                        case "AttendingDoctor":
                            allData = sortColumnDirection == "asc"
                                ? allData.OrderBy(x => x.AttendingDoctor).ToList()
                                : allData.OrderByDescending(x => x.AttendingDoctor).ToList();
                            break;
                        case "Status":
                            allData = sortColumnDirection == "asc"
                                ? allData.OrderBy(x => x.Status).ToList()
                                : allData.OrderByDescending(x => x.Status).ToList();
                            break;
                        case "ExpectedDischargeDate":
                            allData = sortColumnDirection == "asc"
                                ? allData.OrderBy(x => x.ExpectedDischargeDate ?? "").ToList()
                                : allData.OrderByDescending(x => x.ExpectedDischargeDate ?? "").ToList();
                            break;
                        case "DischargeDate":
                            allData = sortColumnDirection == "asc"
                                ? allData.OrderBy(x => x.DischargeDate ?? "").ToList()
                                : allData.OrderByDescending(x => x.DischargeDate ?? "").ToList();
                            break;
                        default:
                            allData = allData.OrderByDescending(x => x.AdmissionDate ?? "").ToList();
                            break;
                    }

                    // ✅ STEP 9: Paging
                    var pagedData = allData.Skip(start).Take(length).ToList();

                    var result = new
                    {
                        draw = draw,
                        recordsTotal = Total_pat,
                        recordsFiltered = FilteredCount,
                        data = pagedData
                    };

                    return Newtonsoft.Json.JsonConvert.SerializeObject(result);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("IPDViewList ERROR: " + ex.Message);
                System.Diagnostics.Debug.WriteLine("STACK: " + ex.StackTrace);

                return Newtonsoft.Json.JsonConvert.SerializeObject(new
                {
                    draw = draw,
                    recordsTotal = 0,
                    recordsFiltered = 0,
                    data = new List<object>(),
                    error = ex.Message,
                    stackTrace = ex.StackTrace
                });
            }
        }

        [WebMethod]
        public static object EMERGENCYViewList(int regID, int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    // Total count
                    var Total_pat = _dbContext.Emergency_Patients.Count(ep => ep.Patient_ID == regID);

                    var query = from ep in _dbContext.Emergency_Patients
                                join emp in _dbContext.HR_Employees on ep.Doctor equals emp.Emp_ID.ToString() into empJoin
                                from emp in empJoin.DefaultIfEmpty()

                                    // Join with Ward_Allocation
                                join wa in _dbContext.Ward_Allocations on ep.Emergency_ID equals wa.EmergencyID into wardAllocJoin
                                from wa in wardAllocJoin.Take(1).DefaultIfEmpty()

                                    // Join with Ward_Definition
                                join wd in _dbContext.Ward_Definitions on wa.Ward_ID equals wd.Ward_ID into wardDefJoin
                                from wd in wardDefJoin.DefaultIfEmpty()

                                    // Join with assigned doctor
                                join wardDoc in _dbContext.HR_Employees on wa.Doctor_Assigned equals wardDoc.Emp_ID into wardDocJoin
                                from wardDoc in wardDocJoin.DefaultIfEmpty()

                                where ep.Patient_ID == regID
                                select new
                                {
                                    EMERGENCY_ID = ep.Emergency_ID,
                                    AdmissionDate = ep.Admission_Date,
                                    WardType = wd != null ? wd.Ward_Type : "N/A",
                                    BedNo = wa != null ? (wa.Bed_No_Assigned.HasValue ? wa.Bed_No_Assigned.Value.ToString() : "N/A") : "N/A",
                                    AttendingDoctor = wardDoc != null ? wardDoc.Emp_Name : (emp != null ? emp.Emp_Name : "N/A"),
                                    DischargeDate = ep.Discharge_On,
                                    Status = ep.Discharge.HasValue ?
                                        (ep.Discharge.Value ? "Discharged" : "Admitted") :
                                        (ep.Death_Certificate.HasValue && ep.Death_Certificate.Value ? "Deceased" : "Admitted")
                                };

                    // Apply search
                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        DateTime searchDate;
                        bool isDateSearch = DateTime.TryParse(searchValue, out searchDate);

                        query = query.Where(x =>
                            x.EMERGENCY_ID.ToString().Contains(searchValue) ||
                            (x.WardType != null && x.WardType.Contains(searchValue)) ||
                            (x.AttendingDoctor != null && x.AttendingDoctor.Contains(searchValue)) ||
                            x.Status.Contains(searchValue) ||
                            x.BedNo.Contains(searchValue) ||
                            (isDateSearch && (
                                (!x.AdmissionDate.HasValue || x.AdmissionDate.Value.Date == searchDate.Date) ||
                                (!x.DischargeDate.HasValue || x.DischargeDate.Value.Date == searchDate.Date)
                            ))
                        );
                    }

                    var FilteredCount = query.Count();

                    // Sorting
                    if (!string.IsNullOrEmpty(sortColumn))
                    {
                        switch (sortColumn)
                        {
                            case "EMERGENCY_ID":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.EMERGENCY_ID) : query.OrderByDescending(x => x.EMERGENCY_ID);
                                break;
                            case "AdmissionDate":
                                query = sortColumnDirection == "asc"
                                    ? query.OrderBy(x => x.AdmissionDate ?? DateTime.MaxValue)
                                    : query.OrderByDescending(x => x.AdmissionDate ?? DateTime.MinValue);
                                break;
                            case "WardName":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.WardType) : query.OrderByDescending(x => x.WardType);
                                break;
                            case "AttendingDoctor":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.AttendingDoctor) : query.OrderByDescending(x => x.AttendingDoctor);
                                break;
                            case "Status":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.Status) : query.OrderByDescending(x => x.Status);
                                break;
                            case "DischargeDate":
                                query = sortColumnDirection == "asc"
                                    ? query.OrderBy(x => x.DischargeDate ?? DateTime.MaxValue)
                                    : query.OrderByDescending(x => x.DischargeDate ?? DateTime.MinValue);
                                break;
                            default:
                                query = query.OrderByDescending(x => x.AdmissionDate ?? DateTime.MinValue);
                                break;
                        }
                    }
                    else
                    {
                        query = query.OrderByDescending(x => x.AdmissionDate ?? DateTime.MinValue);
                    }

                    // Apply paging and format dates
                    var data = query.Skip(start).Take(length).AsEnumerable()
                        .Select(x => new
                        {
                            EMERGENCY_ID = x.EMERGENCY_ID,
                            AdmissionDate = x.AdmissionDate?.ToString("yyyy-MM-ddTHH:mm:ss"),
                            WardName = x.WardType,
                            BedNo = x.BedNo,
                            AttendingDoctor = x.AttendingDoctor,
                            DischargeDate = x.DischargeDate?.ToString("yyyy-MM-ddTHH:mm:ss"),
                            Status = x.Status
                        }).ToList();

                    // Final result
                    var result = new
                    {
                        draw = draw,
                        recordsTotal = Total_pat,
                        recordsFiltered = FilteredCount,
                        data = data
                    };

                    // 🔑 Serialize to string
                    return Newtonsoft.Json.JsonConvert.SerializeObject(result);
                }
            }
            catch (Exception ex)
            {
                var errorResult = new
                {
                    draw = draw,
                    recordsTotal = 0,
                    recordsFiltered = 0,
                    data = new List<object>(),
                    error = ex.Message
                };
                return Newtonsoft.Json.JsonConvert.SerializeObject(errorResult);
            }
        }
        [WebMethod]
        public static object MedicineViewList(int regID, int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    var patientIds = _dbContext.Out_Patients
                        .Where(op => op.Reg_PatId == regID)
                        .Select(op => op.Out_Patient_ID)
                        .Concat(_dbContext.In_Patients
                            .Where(ip => ip.Patient_ID == regID)
                            .Select(ip => ip.In_Patient_ID))
                        .Concat(_dbContext.Emergency_Patients
                            .Where(ep => ep.Patient_ID == regID)
                            .Select(ep => ep.Emergency_ID))
                        .ToList();

                    var query = (from med in _dbContext.In_Patient_Medicines
                                 where med.Patient_ID != null
                                    && patientIds.Contains(med.Patient_ID.Value)
                                 select new
                                 {
                                     MedicineName = med.Medicine_Name,
                                     Dosage = med.Dosage_Qty,
                                     Form = med.Dosage_From,
                                     Route = med.Oral,
                                     Duration = med.Injections,
                                     Frequency = med.Frequency,
                                     PrescriptionDate = med.Medicine_Date,
                                     Instructions = med.Other_Instruction
                                 });

                    var Total_pat = query.Count();

                    // Search
                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        DateTime searchDate;
                        bool isDateSearch = DateTime.TryParse(searchValue, out searchDate)
                                            && searchDate.Year >= 1753;

                        query = query.Where(x =>
                            (x.MedicineName != null && x.MedicineName.Contains(searchValue)) ||
                            (x.Dosage != null && x.Dosage.Contains(searchValue)) ||
                            (x.Form != null && x.Form.Contains(searchValue)) ||
                            (isDateSearch && x.PrescriptionDate.HasValue
                                && x.PrescriptionDate.Value.Year == searchDate.Year
                                && x.PrescriptionDate.Value.Month == searchDate.Month
                                && x.PrescriptionDate.Value.Day == searchDate.Day)
                        );
                    }

                    var FilteredCount = query.Count();

                    // Sorting — ✅ no DateTime.MinValue literals sent to SQL
                    if (!string.IsNullOrEmpty(sortColumn))
                    {
                        switch (sortColumn)
                        {
                            case "MedicineName":
                                query = sortColumnDirection == "asc"
                                    ? query.OrderBy(x => x.MedicineName)
                                    : query.OrderByDescending(x => x.MedicineName);
                                break;

                            case "PrescriptionDate":
                                query = sortColumnDirection == "asc"
                                    ? query.OrderBy(x => x.PrescriptionDate.HasValue)
                                           .ThenBy(x => x.PrescriptionDate)
                                    : query.OrderByDescending(x => x.PrescriptionDate.HasValue)
                                           .ThenByDescending(x => x.PrescriptionDate);
                                break;

                            case "Dosage":
                                query = sortColumnDirection == "asc"
                                    ? query.OrderBy(x => x.Dosage)
                                    : query.OrderByDescending(x => x.Dosage);
                                break;

                            case "Form":
                                query = sortColumnDirection == "asc"
                                    ? query.OrderBy(x => x.Form)
                                    : query.OrderByDescending(x => x.Form);
                                break;

                            default:
                                query = query.OrderByDescending(x => x.PrescriptionDate.HasValue)
                                             .ThenByDescending(x => x.PrescriptionDate);
                                break;
                        }
                    }
                    else
                    {
                        query = query.OrderByDescending(x => x.PrescriptionDate.HasValue)
                                     .ThenByDescending(x => x.PrescriptionDate);
                    }

                    var data = query.Skip(start).Take(length).AsEnumerable()
                        .Select(x => new
                        {
                            MedicineName = x.MedicineName ?? "N/A",
                            Dosage = x.Dosage ?? "N/A",
                            Form = x.Form ?? "N/A",
                            Route = x.Route ?? "N/A",
                            Duration = x.Duration ?? "N/A",
                            Frequency = x.Frequency ?? "N/A",
                            PrescriptionDate = x.PrescriptionDate?.ToString("yyyy-MM-ddTHH:mm:ss"),
                            Instructions = x.Instructions ?? "N/A"
                        }).ToList();

                    var result = new
                    {
                        draw = draw,
                        recordsTotal = Total_pat,
                        recordsFiltered = FilteredCount,
                        data = data
                    };

                    return JsonConvert.SerializeObject(result);
                }
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new
                {
                    draw = draw,
                    recordsTotal = 0,
                    recordsFiltered = 0,
                    data = new List<object>(),
                    error = ex.Message
                });
            }
        }

        [WebMethod]
        public static object InvestigationViewList(int regID, int draw, int start, int length,
                                             string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    // ✅ STEP 1: Collect patient visit IDs (int? unified to avoid Concat errors)
                    var outIds = db.Out_Patients
                        .Where(op => op.Reg_PatId == regID)
                        .Select(op => (int?)op.Out_Patient_ID)
                        .ToList();

                    var inIds = db.In_Patients
                        .Where(ip => ip.Patient_ID == regID)
                        .Select(ip => (int?)ip.In_Patient_ID)
                        .ToList();

                    var emrIds = db.Emergency_Patients
                        .Where(ep => ep.Patient_ID == regID)
                        .Select(ep => (int?)ep.Emergency_ID)
                        .ToList();

                    var patientIds = outIds.Concat(inIds).Concat(emrIds)
                        .Where(id => id.HasValue)
                        .Select(id => id.Value)
                        .Distinct()
                        .ToList();

                    // ✅ STEP 2: Fetch Lab_Test_Details — Lab only
                    // NOTE: Patient_ID is int (NOT nullable) → no HasValue/.Value
                    var labDetails = db.Lab_Test_Details
                        .Where(d => d.Dept_ID == "001"
                                 && (patientIds.Contains(d.Patient_ID)
                                     || d.Patient_ID == regID))
                        .ToList();

                    if (labDetails.Count == 0)
                    {
                        return Newtonsoft.Json.JsonConvert.SerializeObject(new
                        {
                            draw = draw,
                            recordsTotal = 0,
                            recordsFiltered = 0,
                            data = new List<object>()
                        });
                    }

                    // ✅ STEP 3: Load test names into a dictionary
                    // Test_ID — try without .HasValue/.Value first
                    var testIds = labDetails
                        .Select(d => d.Test_ID)
                        .Distinct()
                        .ToList();

                    var testMap = db.Lab_Tests
                        .Where(t => testIds.Contains(t.Test_ID))
                        .ToList()
                        .ToDictionary(t => t.Test_ID, t => t.Test_Name);

                    // ✅ STEP 4: Build in-memory list
                    var allData = labDetails.Select(d => new
                    {
                        Lab_Test_Detail_ID = d.Lab_Test_Detail_ID,
                        Date = d.Date,
                        DateStr = d.Date?.ToString("yyyy-MM-ddTHH:mm:ss"),
                        Remark = d.Remark ?? "N/A",
                        Test_Name = testMap.ContainsKey(d.Test_ID)
                                    ? testMap[d.Test_ID] : "N/A",
                        Special_Tests = d.Special_Tests ?? "N/A",
                        Area_Of_Interest = d.Area_Of_Interest ?? "N/A"
                    }).ToList();

                    var Total_pat = allData.Count;

                    // ✅ STEP 5: Search (in memory)
                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        DateTime searchDate;
                        bool isDateSearch = DateTime.TryParse(searchValue, out searchDate)
                                            && searchDate.Year >= 1753;
                        string datePrefix = isDateSearch ? searchDate.ToString("yyyy-MM-dd") : null;

                        allData = allData.Where(x =>
                            (!string.IsNullOrEmpty(x.Test_Name) && x.Test_Name.IndexOf(searchValue, StringComparison.OrdinalIgnoreCase) >= 0) ||
                            (!string.IsNullOrEmpty(x.Remark) && x.Remark.IndexOf(searchValue, StringComparison.OrdinalIgnoreCase) >= 0) ||
                            (!string.IsNullOrEmpty(x.Special_Tests) && x.Special_Tests.IndexOf(searchValue, StringComparison.OrdinalIgnoreCase) >= 0) ||
                            (!string.IsNullOrEmpty(x.Area_Of_Interest) && x.Area_Of_Interest.IndexOf(searchValue, StringComparison.OrdinalIgnoreCase) >= 0) ||
                            (isDateSearch && !string.IsNullOrEmpty(x.DateStr) && x.DateStr.StartsWith(datePrefix))
                        ).ToList();
                    }

                    var FilteredCount = allData.Count;

                    // ✅ STEP 6: Sorting (string-based — no SqlDateTime overflow)
                    switch (sortColumn)
                    {
                        case "Test_Name":
                            allData = sortColumnDirection == "asc"
                                ? allData.OrderBy(x => x.Test_Name).ToList()
                                : allData.OrderByDescending(x => x.Test_Name).ToList();
                            break;
                        case "Date":
                            allData = sortColumnDirection == "asc"
                                ? allData.OrderBy(x => x.DateStr ?? "").ToList()
                                : allData.OrderByDescending(x => x.DateStr ?? "").ToList();
                            break;
                        case "Special_Tests":
                            allData = sortColumnDirection == "asc"
                                ? allData.OrderBy(x => x.Special_Tests).ToList()
                                : allData.OrderByDescending(x => x.Special_Tests).ToList();
                            break;
                        case "Area_Of_Interest":
                            allData = sortColumnDirection == "asc"
                                ? allData.OrderBy(x => x.Area_Of_Interest).ToList()
                                : allData.OrderByDescending(x => x.Area_Of_Interest).ToList();
                            break;
                        default:
                            allData = allData.OrderByDescending(x => x.DateStr ?? "").ToList();
                            break;
                    }

                    // ✅ STEP 7: Paging
                    var pagedData = allData.Skip(start).Take(length)
                        .Select(x => new
                        {
                            Lab_Test_Detail_ID = x.Lab_Test_Detail_ID,
                            Date = x.DateStr,
                            Remark = x.Remark,
                            Test_Name = x.Test_Name,
                            Special_Tests = x.Special_Tests,
                            Area_Of_Interest = x.Area_Of_Interest
                        }).ToList();

                    var result = new
                    {
                        draw = draw,
                        recordsTotal = Total_pat,
                        recordsFiltered = FilteredCount,
                        data = pagedData
                    };

                    return Newtonsoft.Json.JsonConvert.SerializeObject(result);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("InvestigationViewList ERROR: " + ex.Message);
                System.Diagnostics.Debug.WriteLine("STACK: " + ex.StackTrace);

                return Newtonsoft.Json.JsonConvert.SerializeObject(new
                {
                    draw = draw,
                    recordsTotal = 0,
                    recordsFiltered = 0,
                    data = new List<object>(),
                    error = ex.Message,
                    stackTrace = ex.StackTrace
                });
            }
        }

        [WebMethod]
        public static object DiagnosticsViewList(int regID, int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    // STEP 1: Collect patient visit IDs (Out_Patient_ID / In_Patient_ID / Emergency_ID)
                    var outIds = db.Out_Patients
                        .Where(op => op.Reg_PatId == regID)
                        .Select(op => (int?)op.Out_Patient_ID)
                        .ToList();

                    var inIds = db.In_Patients
                        .Where(ip => ip.Patient_ID == regID)
                        .Select(ip => (int?)ip.In_Patient_ID)
                        .ToList();

                    var emrIds = db.Emergency_Patients
                        .Where(ep => ep.Patient_ID == regID)
                        .Select(ep => (int?)ep.Emergency_ID)
                        .ToList();

                    var patientIds = outIds.Concat(inIds).Concat(emrIds)
                        .Where(id => id.HasValue)
                        .Select(id => id.Value)
                        .Distinct()
                        .ToList();

                    // STEP 2: Fetch Lab_Test_Details — exclude Lab dept (001)
                    // Lab_Test_Details.Patient_ID is visit ID (Out_Patient_ID / In_Patient_ID / Emergency_ID)
                    var labDetails = db.Lab_Test_Details
                        .Where(d => d.Dept_ID != "001"
                                 && (patientIds.Contains(d.Patient_ID)
                                     || d.Patient_ID == regID))
                        .ToList();

                    if (labDetails.Count == 0)
                    {
                        return Newtonsoft.Json.JsonConvert.SerializeObject(new
                        {
                            draw = draw,
                            recordsTotal = 0,
                            recordsFiltered = 0,
                            data = new List<object>()
                        });
                    }

                    // STEP 3: Load test names + dept names into dictionaries
                    var testIds = labDetails.Select(d => d.Test_ID).Distinct().ToList();

                    var testMap = db.Lab_Tests
                        .Where(t => testIds.Contains(t.Test_ID))
                        .ToList()
                        .ToDictionary(t => t.Test_ID, t => t);

                    // STEP 4: Build in-memory list
                    var allData = labDetails.Select(d =>
                    {
                        var lab = testMap.ContainsKey(d.Test_ID) ? testMap[d.Test_ID] : null;
                        var mainDept = lab?.Main_Department ?? "";
                        var deptName = db.GetDataValueName("Main Test Departments", mainDept);
                        var isXRay = deptName == "X-Ray";

                        return new
                        {
                            Lab_Test_Detail_ID = d.Lab_Test_Detail_ID,
                            Date = d.Date,
                            DateStr = d.Date?.ToString("yyyy-MM-ddTHH:mm:ss"),
                            Remark = d.Remark ?? "N/A",
                            Test_Name = lab?.Test_Name ?? "N/A",
                            Department = deptName,
                            Special_Tests = d.Special_Tests ?? "N/A",
                            Area_Of_Interest = d.Area_Of_Interest ?? "N/A",
                            Rotation = isXRay
                                ? db.GetDataValueName("Test XRay Rotations", d.Rotation_ID)
                                : db.GetDataValueName("Test CT Scan Rotations", d.Rotation_ID)
                        };
                    }).ToList();

                    var Total_pat = allData.Count;

                    // STEP 5: Search (in memory)
                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        DateTime searchDate;
                        bool isDateSearch = DateTime.TryParse(searchValue, out searchDate)
                                            && searchDate.Year >= 1753;
                        string datePrefix = isDateSearch ? searchDate.ToString("yyyy-MM-dd") : null;

                        allData = allData.Where(x =>
                            (!string.IsNullOrEmpty(x.Test_Name) && x.Test_Name.IndexOf(searchValue, StringComparison.OrdinalIgnoreCase) >= 0) ||
                            (!string.IsNullOrEmpty(x.Department) && x.Department.IndexOf(searchValue, StringComparison.OrdinalIgnoreCase) >= 0) ||
                            (!string.IsNullOrEmpty(x.Rotation) && x.Rotation.IndexOf(searchValue, StringComparison.OrdinalIgnoreCase) >= 0) ||
                            (!string.IsNullOrEmpty(x.Remark) && x.Remark.IndexOf(searchValue, StringComparison.OrdinalIgnoreCase) >= 0) ||
                            (!string.IsNullOrEmpty(x.Special_Tests) && x.Special_Tests.IndexOf(searchValue, StringComparison.OrdinalIgnoreCase) >= 0) ||
                            (!string.IsNullOrEmpty(x.Area_Of_Interest) && x.Area_Of_Interest.IndexOf(searchValue, StringComparison.OrdinalIgnoreCase) >= 0) ||
                            (isDateSearch && !string.IsNullOrEmpty(x.DateStr) && x.DateStr.StartsWith(datePrefix))
                        ).ToList();
                    }

                    var FilteredCount = allData.Count;

                    // STEP 6: Sorting
                    switch (sortColumn)
                    {
                        case "Test_Name":
                            allData = sortColumnDirection == "asc"
                                ? allData.OrderBy(x => x.Test_Name).ToList()
                                : allData.OrderByDescending(x => x.Test_Name).ToList();
                            break;
                        case "Date":
                            allData = sortColumnDirection == "asc"
                                ? allData.OrderBy(x => x.DateStr ?? "").ToList()
                                : allData.OrderByDescending(x => x.DateStr ?? "").ToList();
                            break;
                        case "Department":
                            allData = sortColumnDirection == "asc"
                                ? allData.OrderBy(x => x.Department).ToList()
                                : allData.OrderByDescending(x => x.Department).ToList();
                            break;
                        default:
                            allData = allData.OrderByDescending(x => x.DateStr ?? "").ToList();
                            break;
                    }

                    // STEP 7: Paging
                    var pagedData = allData.Skip(start).Take(length)
                        .Select(x => new
                        {
                            Lab_Test_Detail_ID = x.Lab_Test_Detail_ID,
                            Date = x.DateStr,
                            Remark = x.Remark,
                            Test_Name = x.Test_Name,
                            Department = x.Department,
                            Special_Tests = x.Special_Tests,
                            Area_Of_Interest = x.Area_Of_Interest,
                            Rotation = x.Rotation ?? "N/A"
                        }).ToList();

                    var result = new
                    {
                        draw = draw,
                        recordsTotal = Total_pat,
                        recordsFiltered = FilteredCount,
                        data = pagedData
                    };

                    return Newtonsoft.Json.JsonConvert.SerializeObject(result);
                }
            }
            catch (Exception ex)
            {
                return Newtonsoft.Json.JsonConvert.SerializeObject(new
                {
                    draw = draw,
                    recordsTotal = 0,
                    recordsFiltered = 0,
                    data = new List<object>(),
                    error = ex.Message
                });
            }
        }
            [WebMethod]
        public static object PatientServicesViewList(int regID, int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    // Get total count from InPatientServices where PatientId matches regID
                    var Total_services = _dbContext.InPatientServices.Count(ips => ips.PatientId == regID);

                    var query = from ips in _dbContext.InPatientServices
                                where ips.PatientId == regID
                                select new
                                {
                                    ServicesId = ips.ServicesId,
                                    ServiceName = ips.Services_Procedure_ItemName ?? "N/A",
                                    ServiceType = ips.ServiceType ?? "N/A",
                                    Amount = ips.ServiceAmount ?? 0,
                                    PatientType = ips.PatientType ?? "N/A",
                                    CreatedDate = ips.CreatedDate.HasValue ? ips.CreatedDate.Value.Date : (DateTime?)null,
                                    UserName = ips.UserName ?? "N/A",
                                    IsBilled = ips.isbilled.HasValue ? (ips.isbilled.Value ? "Billed" : "Not Billed") : "Not Billed"
                                };

                    // Apply search filter if searchValue is provided
                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        DateTime searchDate;
                        decimal searchAmount;
                        bool isDateSearch = DateTime.TryParse(searchValue, out searchDate);
                        bool isAmountSearch = decimal.TryParse(searchValue, out searchAmount);

                        query = query.Where(x =>
                            x.ServicesId.ToString().Contains(searchValue) ||
                            (x.ServiceName != null && x.ServiceName.Contains(searchValue)) ||
                            (x.ServiceType != null && x.ServiceType.Contains(searchValue)) ||
                            (x.PatientType != null && x.PatientType.Contains(searchValue)) ||
                            (x.UserName != null && x.UserName.Contains(searchValue)) ||
                            x.IsBilled.Contains(searchValue) ||
                            (isAmountSearch && x.Amount == searchAmount) ||
                            (isDateSearch && x.CreatedDate.HasValue && x.CreatedDate.Value.Date == searchDate.Date)
                        );
                    }

                    var FilteredCount = query.Count();

                    // Apply sorting
                    if (!string.IsNullOrEmpty(sortColumn))
                    {
                        switch (sortColumn)
                        {
                            case "ServicesId":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.ServicesId) : query.OrderByDescending(x => x.ServicesId);
                                break;
                            case "ServiceName":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.ServiceName) : query.OrderByDescending(x => x.ServiceName);
                                break;
                            case "ServiceType":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.ServiceType) : query.OrderByDescending(x => x.ServiceType);
                                break;
                            case "Amount":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.Amount) : query.OrderByDescending(x => x.Amount);
                                break;
                            case "PatientType":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.PatientType) : query.OrderByDescending(x => x.PatientType);
                                break;
                            case "CreatedDate":
                                query = sortColumnDirection == "asc" ?
                                    query.OrderBy(x => x.CreatedDate.HasValue ? x.CreatedDate : DateTime.MaxValue) :
                                    query.OrderByDescending(x => x.CreatedDate.HasValue ? x.CreatedDate : DateTime.MinValue);
                                break;
                            case "UserName":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.UserName) : query.OrderByDescending(x => x.UserName);
                                break;
                            case "IsBilled":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.IsBilled) : query.OrderByDescending(x => x.IsBilled);
                                break;
                            default:
                                query = query.OrderByDescending(x => x.CreatedDate.HasValue ? x.CreatedDate : DateTime.MinValue);
                                break;
                        }
                    }
                    else
                    {
                        query = query.OrderByDescending(x => x.CreatedDate.HasValue ? x.CreatedDate : DateTime.MinValue);
                    }

                    // Apply paging and format dates/amounts
                    var data = query.Skip(start).Take(length).AsEnumerable()
                        .Select(x => new
                        {
                            ServicesId = x.ServicesId,
                            ServiceName = x.ServiceName ?? "N/A",
                            ServiceType = x.ServiceType ?? "N/A",
                            Amount = x.Amount.ToString("N2"), // Format as currency with 2 decimals
                            PatientType = x.PatientType ?? "N/A",
                            CreatedDate = x.CreatedDate.HasValue ? x.CreatedDate.Value.ToString("MM/dd/yyyy") : "",
                            UserName = x.UserName ?? "N/A",
                            IsBilled = x.IsBilled ?? "Not Billed"
                        }).ToList();

                    // Return the proper DataTables structure
                    var jsonData = new
                    {
                        draw = draw,
                        recordsFiltered = FilteredCount,
                        recordsTotal = Total_services,
                        data = data
                    };

                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                // Log the exception and return empty result
                // Consider logging: ex.Message, ex.StackTrace
                return new
                {
                    draw = draw,
                    recordsFiltered = 0,
                    recordsTotal = 0,
                    data = new List<object>(),
                    error = ex.Message
                };
            }
        }
        [WebMethod]
        public static object PatientComplaintsViewList(int regID, int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    // Get patient IDs from all three sources
                    var patientIds = _dbContext.Out_Patients
                        .Where(op => op.Reg_PatId == regID)
                        .Select(op => op.Out_Patient_ID)
                        .Concat(_dbContext.In_Patients
                            .Where(ip => ip.Patient_ID == regID)
                            .Select(ip => ip.In_Patient_ID))
                        .Concat(_dbContext.Emergency_Patients
                            .Where(ep => ep.Patient_ID == regID)
                            .Select(ep => ep.Emergency_ID))
                        .ToList();

                    // Get total count from OutPatientComplaints
                    var Total_complaints = _dbContext.OutPatientComplaints.Count(opc =>
                        patientIds.Contains(opc.OutPatientID) || opc.PatientID == regID);
                    var query =
                        from opc in _dbContext.OutPatientComplaints
                        join cd in _dbContext.ComplaintsDefinitions
                            on opc.ComplaintID equals cd.ID into gj
                        from cd in gj.DefaultIfEmpty()
                        where patientIds.Contains(opc.OutPatientID) || opc.PatientID == regID
                        select new
                        {
                            ID = opc.ID,
                            OutPatientID = opc.OutPatientID,
                            PatientID = opc.PatientID,
                            ComplaintID = opc.ComplaintID,
                            ComplaintName = cd.ComplaintName ?? "N/A"
                        };


                    // Apply search filter if searchValue is provided
                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        int searchID;
                        bool isIDSearch = int.TryParse(searchValue, out searchID);

                        query = query.Where(x =>
                            x.ID.ToString().Contains(searchValue) ||
                            x.OutPatientID.ToString().Contains(searchValue) ||
                            x.PatientID.ToString().Contains(searchValue) ||
                            (x.ComplaintName != null && x.ComplaintName.Contains(searchValue)) ||
                            (isIDSearch && x.ComplaintID == searchID)
                        );
                    }

                    var FilteredCount = query.Count();

                    // Apply sorting
                    if (!string.IsNullOrEmpty(sortColumn))
                    {
                        switch (sortColumn)
                        {
                            case "ID":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.ID) : query.OrderByDescending(x => x.ID);
                                break;
                            case "OutPatientID":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.OutPatientID) : query.OrderByDescending(x => x.OutPatientID);
                                break;
                            case "PatientID":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.PatientID) : query.OrderByDescending(x => x.PatientID);
                                break;
                            case "ComplaintName":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.ComplaintName) : query.OrderByDescending(x => x.ComplaintName);
                                break;
                            default:
                                query = query.OrderByDescending(x => x.ID);
                                break;
                        }
                    }
                    else
                    {
                        query = query.OrderByDescending(x => x.ID);
                    }

                    // Apply paging
                    var data = query.Skip(start).Take(length).AsEnumerable()
                        .Select(x => new
                        {
                            ID = x.ID,
                            OutPatientID = x.OutPatientID,
                            PatientID = x.PatientID,
                            ComplaintID = x.ComplaintID,
                            ComplaintName = x.ComplaintName ?? "N/A"
                        }).ToList();

                    var jsonData = new
                    {
                        draw = draw,
                        recordsFiltered = FilteredCount,
                        recordsTotal = Total_complaints,
                        data = data
                    };

                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                return new
                {
                    draw = draw,
                    recordsFiltered = 0,
                    recordsTotal = 0,
                    data = new List<object>(),
                    error = ex.Message
                };
            }
        }
        [WebMethod]
        public static object PrimaryDiagnosisViewList(int regID, int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    // Get patient IDs from all three sources
                    var patientIds = _dbContext.Out_Patients
                        .Where(op => op.Reg_PatId == regID)
                        .Select(op => op.Out_Patient_ID)
                        .Concat(_dbContext.In_Patients
                            .Where(ip => ip.Patient_ID == regID)
                            .Select(ip => ip.In_Patient_ID))
                        .Concat(_dbContext.Emergency_Patients
                            .Where(ep => ep.Patient_ID == regID)
                            .Select(ep => ep.Emergency_ID))
                        .ToList();

                    // Get total count from OutPatientPrimaryDiagnosis
                    var Total_diagnosis = _dbContext.OutPatientPrimaryDiagnosis.Count(opd =>
                        patientIds.Contains(opd.OutPatientID) || opd.PatientID == regID);

                    var query = from opd in _dbContext.OutPatientPrimaryDiagnosis
                                where patientIds.Contains(opd.OutPatientID) || opd.PatientID == regID
                                select new
                                {
                                    ID = opd.ID,
                                    OutPatientID = opd.OutPatientID,
                                    PatientID = opd.PatientID,
                                    DiagnosisID = opd.DiagnosisID,
                                    DiagnosisName = _dbContext.DiagnosisDefinitions.Where(c => c.ID == opd.DiagnosisID).Select(c => c.DiagnosisName).FirstOrDefault() ?? "N/A",
                                    Remarks = opd.Remarks ?? ""
                                };

                    // Apply search filter if searchValue is provided
                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        int searchID;
                        bool isIDSearch = int.TryParse(searchValue, out searchID);

                        query = query.Where(x =>
                            x.ID.ToString().Contains(searchValue) ||
                            x.OutPatientID.ToString().Contains(searchValue) ||
                            x.PatientID.ToString().Contains(searchValue) ||
                            (x.DiagnosisName != null && x.DiagnosisName.Contains(searchValue)) ||
                            (x.Remarks != null && x.Remarks.Contains(searchValue)) ||
                            (isIDSearch && x.DiagnosisID == searchID)
                        );
                    }

                    var FilteredCount = query.Count();

                    // Apply sorting
                    if (!string.IsNullOrEmpty(sortColumn))
                    {
                        switch (sortColumn)
                        {
                            case "ID":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.ID) : query.OrderByDescending(x => x.ID);
                                break;
                            case "OutPatientID":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.OutPatientID) : query.OrderByDescending(x => x.OutPatientID);
                                break;
                            case "PatientID":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.PatientID) : query.OrderByDescending(x => x.PatientID);
                                break;
                            case "DiagnosisName":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.DiagnosisName) : query.OrderByDescending(x => x.DiagnosisName);
                                break;
                            case "Remarks":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.Remarks) : query.OrderByDescending(x => x.Remarks);
                                break;
                            default:
                                query = query.OrderByDescending(x => x.ID);
                                break;
                        }
                    }
                    else
                    {
                        query = query.OrderByDescending(x => x.ID);
                    }

                    // Apply paging
                    var data = query.Skip(start).Take(length).AsEnumerable()
                        .Select(x => new
                        {
                            ID = x.ID,
                            OutPatientID = x.OutPatientID,
                            PatientID = x.PatientID,
                            DiagnosisID = x.DiagnosisID,
                            DiagnosisName = x.DiagnosisName ?? "N/A",
                            Remarks = x.Remarks ?? ""
                        }).ToList();

                    var jsonData = new
                    {
                        draw = draw,
                        recordsFiltered = FilteredCount,
                        recordsTotal = Total_diagnosis,
                        data = data
                    };

                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                return new
                {
                    draw = draw,
                    recordsFiltered = 0,
                    recordsTotal = 0,
                    data = new List<object>(),
                    error = ex.Message
                };
            }
        }
        [WebMethod]
        public static object FinalDiagnosisViewList(int regID, int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    // Get patient IDs from all three sources
                    var patientIds = _dbContext.Out_Patients
                        .Where(op => op.Reg_PatId == regID)
                        .Select(op => op.Out_Patient_ID)
                        .Concat(_dbContext.In_Patients
                            .Where(ip => ip.Patient_ID == regID)
                            .Select(ip => ip.In_Patient_ID))
                        .Concat(_dbContext.Emergency_Patients
                            .Where(ep => ep.Patient_ID == regID)
                            .Select(ep => ep.Emergency_ID))
                        .ToList();

                    // Get total count from OutPatientFinalDiagnosis
                    var Total_diagnosis = _dbContext.OutPatientFinalDiagnosis.Count(ofd =>
                        patientIds.Contains(ofd.OutPatientID) || ofd.PatientID == regID);

                    var query = from ofd in _dbContext.OutPatientFinalDiagnosis
                                where patientIds.Contains(ofd.OutPatientID) || ofd.PatientID == regID
                                select new
                                {
                                    ID = ofd.ID,
                                    OutPatientID = ofd.OutPatientID,
                                    PatientID = ofd.PatientID,
                                    DiagnosisID = ofd.DiagnosisID,
                                    DiagnosisName = _dbContext.DiagnosisDefinitions.Where(c => c.ID == ofd.DiagnosisID).Select(c => c.DiagnosisName).FirstOrDefault() ?? "N/A",
                                    Remarks = ofd.Remarks ?? ""
                                };

                    // Apply search filter if searchValue is provided
                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        int searchID;
                        bool isIDSearch = int.TryParse(searchValue, out searchID);

                        query = query.Where(x =>
                            x.ID.ToString().Contains(searchValue) ||
                            x.OutPatientID.ToString().Contains(searchValue) ||
                            x.PatientID.ToString().Contains(searchValue) ||
                            (x.DiagnosisName != null && x.DiagnosisName.Contains(searchValue)) ||
                            (x.Remarks != null && x.Remarks.Contains(searchValue)) ||
                            (isIDSearch && x.DiagnosisID == searchID)
                        );
                    }

                    var FilteredCount = query.Count();

                    // Apply sorting
                    if (!string.IsNullOrEmpty(sortColumn))
                    {
                        switch (sortColumn)
                        {
                            case "ID":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.ID) : query.OrderByDescending(x => x.ID);
                                break;
                            case "OutPatientID":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.OutPatientID) : query.OrderByDescending(x => x.OutPatientID);
                                break;
                            case "PatientID":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.PatientID) : query.OrderByDescending(x => x.PatientID);
                                break;
                            case "DiagnosisName":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.DiagnosisName) : query.OrderByDescending(x => x.DiagnosisName);
                                break;
                            case "Remarks":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.Remarks) : query.OrderByDescending(x => x.Remarks);
                                break;
                            default:
                                query = query.OrderByDescending(x => x.ID);
                                break;
                        }
                    }
                    else
                    {
                        query = query.OrderByDescending(x => x.ID);
                    }

                    // Apply paging
                    var data = query.Skip(start).Take(length).AsEnumerable()
                        .Select(x => new
                        {
                            ID = x.ID,
                            OutPatientID = x.OutPatientID,
                            PatientID = x.PatientID,
                            DiagnosisID = x.DiagnosisID,
                            DiagnosisName = x.DiagnosisName ?? "N/A",
                            Remarks = x.Remarks ?? ""
                        }).ToList();

                    var jsonData = new
                    {
                        draw = draw,
                        recordsFiltered = FilteredCount,
                        recordsTotal = Total_diagnosis,
                        data = data
                    };

                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                return new
                {
                    draw = draw,
                    recordsFiltered = 0,
                    recordsTotal = 0,
                    data = new List<object>(),
                    error = ex.Message
                };
            }
        }
        [WebMethod]
        public static object PatientSymptomsViewList(int regID, int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    // Get patient IDs from all three sources
                    var outPatientIds = _dbContext.Out_Patients
                        .Where(op => op.Reg_PatId == regID)
                        .Select(op => op.Out_Patient_ID)
                        .ToList();

                    var inPatientIds = _dbContext.In_Patients
                        .Where(ip => ip.Patient_ID == regID)
                        .Select(ip => ip.In_Patient_ID)
                        .ToList();

                    var emergencyIds = _dbContext.Emergency_Patients
                        .Where(ep => ep.Patient_ID == regID)
                        .Select(ep => ep.Emergency_ID)
                        .ToList();

                    // Get total count from Sysmtopms for all patient types
                    var Total_symptoms = _dbContext.Sysmtopms.Count(s =>
                        (s.Out_Patient_ID.HasValue && outPatientIds.Contains(s.Out_Patient_ID.Value)) ||
                        (s.In_Patient_ID.HasValue && inPatientIds.Contains(s.In_Patient_ID.Value)) ||
                        (s.EmergencyID.HasValue && emergencyIds.Contains(s.EmergencyID.Value)));

                    var query = from s in _dbContext.Sysmtopms
                                where (s.Out_Patient_ID.HasValue && outPatientIds.Contains(s.Out_Patient_ID.Value)) ||
                                      (s.In_Patient_ID.HasValue && inPatientIds.Contains(s.In_Patient_ID.Value)) ||
                                      (s.EmergencyID.HasValue && emergencyIds.Contains(s.EmergencyID.Value))
                                select new
                                {
                                    ID = s.ID,
                                    Out_Patient_ID = s.Out_Patient_ID,
                                    In_Patient_ID = s.In_Patient_ID,
                                    EmergencyID = s.EmergencyID,
                                    Symtom_ID = s.Symtom_ID,
                                    SymptomName = _dbContext.GetDataValueName("Symtoms", s.Symtom_ID.ToString()) ?? "N/A",
                                    Duration = s.Duration ?? "N/A",
                                    Days_Years_Months = s.Days_Years_Months ?? "N/A",
                                    Remarks = s.Remarks ?? "",
                                    PatientType = s.Out_Patient_ID.HasValue ? "Out Patient" :
                                                 s.In_Patient_ID.HasValue ? "In Patient" :
                                                 s.EmergencyID.HasValue ? "Emergency" : "Unknown"
                                };

                    // Apply search filter if searchValue is provided
                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        int searchID, searchDuration;
                        bool isIDSearch = int.TryParse(searchValue, out searchID);
                        bool isDurationSearch = int.TryParse(searchValue, out searchDuration);

                        query = query.Where(x =>
                            x.ID.ToString().Contains(searchValue) ||
                            (x.Out_Patient_ID.HasValue && x.Out_Patient_ID.Value.ToString().Contains(searchValue)) ||
                            (x.In_Patient_ID.HasValue && x.In_Patient_ID.Value.ToString().Contains(searchValue)) ||
                            (x.EmergencyID.HasValue && x.EmergencyID.Value.ToString().Contains(searchValue)) ||
                            (x.SymptomName != null && x.SymptomName.Contains(searchValue)) ||
                            (x.Days_Years_Months != null && x.Days_Years_Months.Contains(searchValue)) ||
                            (x.Remarks != null && x.Remarks.Contains(searchValue)) ||
                            x.PatientType.Contains(searchValue) ||
                            (isIDSearch && x.Symtom_ID == searchID.ToString()) ||
                            (isDurationSearch && x.Duration == searchDuration.ToString())
                        );
                    }

                    var FilteredCount = query.Count();

                    // Apply sorting
                    if (!string.IsNullOrEmpty(sortColumn))
                    {
                        switch (sortColumn)
                        {
                            case "ID":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.ID) : query.OrderByDescending(x => x.ID);
                                break;
                            case "SymptomName":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.SymptomName) : query.OrderByDescending(x => x.SymptomName);
                                break;
                            case "Duration":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.Duration) : query.OrderByDescending(x => x.Duration);
                                break;
                            case "Days_Years_Months":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.Days_Years_Months) : query.OrderByDescending(x => x.Days_Years_Months);
                                break;
                            case "PatientType":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.PatientType) : query.OrderByDescending(x => x.PatientType);
                                break;
                            case "Remarks":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.Remarks) : query.OrderByDescending(x => x.Remarks);
                                break;
                            default:
                                query = query.OrderByDescending(x => x.ID);
                                break;
                        }
                    }
                    else
                    {
                        query = query.OrderByDescending(x => x.ID);
                    }

                    // Apply paging
                    var data = query.Skip(start).Take(length).AsEnumerable()
                        .Select(x => new
                        {
                            ID = x.ID,
                            PatientID = x.Out_Patient_ID ?? x.In_Patient_ID ?? x.EmergencyID ?? 0,
                            SymptomName = x.SymptomName ?? "N/A",
                            Duration = x.Duration,
                            DurationUnit = x.Days_Years_Months ?? "N/A",
                            PatientType = x.PatientType,
                            Remarks = x.Remarks ?? ""
                        }).ToList();

                    var jsonData = new
                    {
                        draw = draw,
                        recordsFiltered = FilteredCount,
                        recordsTotal = Total_symptoms,
                        data = data
                    };

                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                return new
                {
                    draw = draw,
                    recordsFiltered = 0,
                    recordsTotal = 0,
                    data = new List<object>(),
                    error = ex.Message
                };
            }
        }
    }
}