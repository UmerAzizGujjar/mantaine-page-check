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
        public static object IPDViewList(int regID, int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    // Total count
                    var Total_pat = _dbContext.In_Patients.Count(ip => ip.Patient_ID == regID);

                    var query = from ip in _dbContext.In_Patients
                                join emp in _dbContext.HR_Employees on ip.Doctor equals emp.Emp_ID.ToString() into empJoin
                                from emp in empJoin.DefaultIfEmpty()

                                    // Join with Ward_Allocation to get current ward assignment
                                join wa in _dbContext.Ward_Allocations on ip.In_Patient_ID.ToString() equals wa.InPatient_ID into wardAllocJoin
                                from wa in wardAllocJoin
                                    .Where(x => !(x.IsDischarge ?? true) && !(x.isCancelled ?? true))
                                    .Take(1)
                                    .DefaultIfEmpty()

                                    // Join with Ward_Definition to get ward details
                                join wd in _dbContext.Ward_Definitions on wa.Ward_ID equals wd.Ward_ID into wardDefJoin
                                from wd in wardDefJoin.DefaultIfEmpty()

                                    // Join with Room_Allocation to get current room
                                join ra in _dbContext.Room_Allocations on ip.In_Patient_ID equals ra.In_Patient_ID into roomAllocJoin
                                from ra in roomAllocJoin.Take(1).DefaultIfEmpty()

                                    // Join with Rooms
                                join r in _dbContext.Rooms on ra.Room_ID equals r.Room_ID into roomJoin
                                from r in roomJoin.DefaultIfEmpty()

                                    // Join for doctor assigned in ward
                                join wardDoc in _dbContext.HR_Employees on wa.Doctor_Assigned equals wardDoc.Emp_ID into wardDocJoin
                                from wardDoc in wardDocJoin.DefaultIfEmpty()

                                where ip.Patient_ID == regID
                                select new
                                {
                                    IPD_ID = ip.In_Patient_ID,
                                    AdmissionDate = ip.Admission_Date,
                                    Department = _dbContext.GetDataValueName("Patient Main Category", ip.Department) ?? "N/A",
                                    WardType = wd != null ? wd.Ward_Type : "N/A",
                                    WardNo = wd != null && !string.IsNullOrWhiteSpace(wd.Ward_No) ? wd.Ward_No: "N/A",
                                    RoomNo = r != null ? r.Room_No : "N/A",
                                    BedNo = wa != null ? (wa.Bed_No_Assigned.HasValue ? wa.Bed_No_Assigned.Value.ToString() : "N/A") : "N/A",
                                    AttendingDoctor = wardDoc != null ? wardDoc.Emp_Name : (emp != null ? emp.Emp_Name : "N/A"),
                                    ProvisionalDiagnosis = ip.Provisional_Diagnosis ?? "",
                                    ExpectedDischargeDate = ip.Expected_Discharge_Date,
                                    DischargeDate = ip.Discharge_On,
                                    AdmissionType = ip.AdmissionType ?? "Regular",
                                    Status = ip.Discharge.HasValue ?
                                        (ip.Discharge.Value ? "Discharged" : "Admitted") :
                                        (ip.Death_Certificate.HasValue && ip.Death_Certificate.Value ? "Deceased" : "Admitted"),
                                    ReferringDoctor = ip.Referring_Doctor ?? ""
                                };

                    // Apply search
                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        DateTime searchDate;
                        bool isDateSearch = DateTime.TryParse(searchValue, out searchDate);

                        query = query.Where(x =>
                            x.IPD_ID.ToString().Contains(searchValue) ||
                            (x.Department != null && x.Department.Contains(searchValue)) ||
                            (x.WardType != null && x.WardType.Contains(searchValue)) ||
                            (x.AttendingDoctor != null && x.AttendingDoctor.Contains(searchValue)) ||
                            (x.AdmissionType != null && x.AdmissionType.Contains(searchValue)) ||
                            x.Status.Contains(searchValue) ||
                            x.BedNo.Contains(searchValue) ||
                            x.RoomNo.Contains(searchValue) ||
                            (x.ProvisionalDiagnosis != null && x.ProvisionalDiagnosis.Contains(searchValue)) ||
                            (x.ReferringDoctor != null && x.ReferringDoctor.Contains(searchValue)) ||
                            (isDateSearch && (
                                (!x.AdmissionDate.HasValue || x.AdmissionDate.Value.Date == searchDate.Date) ||
                                (!x.ExpectedDischargeDate.HasValue || x.ExpectedDischargeDate.Value.Date == searchDate.Date) ||
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
                            case "IPD_ID":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.IPD_ID) : query.OrderByDescending(x => x.IPD_ID);
                                break;
                            case "AdmissionDate":
                                query = sortColumnDirection == "asc"
                                    ? query.OrderBy(x => x.AdmissionDate ?? DateTime.MaxValue)
                                    : query.OrderByDescending(x => x.AdmissionDate ?? DateTime.MinValue);
                                break;
                            case "Department":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.Department) : query.OrderByDescending(x => x.Department);
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
                            case "ExpectedDischargeDate":
                                query = sortColumnDirection == "asc"
                                    ? query.OrderBy(x => x.ExpectedDischargeDate ?? DateTime.MaxValue)
                                    : query.OrderByDescending(x => x.ExpectedDischargeDate ?? DateTime.MinValue);
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

                    // Apply paging and format dates as ISO strings
                    var data = query.Skip(start).Take(length).AsEnumerable()
                        .Select(x => new
                        {
                            IPD_ID = x.IPD_ID,
                            AdmissionDate = x.AdmissionDate?.ToString("yyyy-MM-ddTHH:mm:ss"),
                            Department = x.Department,
                            WardName = x.WardType,
                            RoomNo = x.RoomNo,
                            BedNo = x.BedNo,
                            AttendingDoctor = x.AttendingDoctor,
                            ExpectedDischargeDate = x.ExpectedDischargeDate?.ToString("yyyy-MM-ddTHH:mm:ss"),
                            DischargeDate = x.DischargeDate?.ToString("yyyy-MM-ddTHH:mm:ss"),
                            Status = x.Status,
                            ReferringDoctor = x.ReferringDoctor
                        }).ToList();

                    // Final result
                    var result = new
                    {
                        draw = draw,
                        recordsTotal = Total_pat,
                        recordsFiltered = FilteredCount,
                        data = data
                    };

                    // 🔑 Serialize to string so frontend can JSON.parse(json.d)
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
                    // Get all patient IDs associated with this registration
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

                    // Query medicines
                    var query = (from med in _dbContext.In_Patient_Medicines
                                 where patientIds.Contains((int)med.Patient_ID)
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

                    // Total count
                    var Total_pat = query.Count();

                    // Apply search
                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        DateTime searchDate;
                        bool isDateSearch = DateTime.TryParse(searchValue, out searchDate);

                        query = query.Where(x =>
                            (x.MedicineName != null && x.MedicineName.Contains(searchValue)) ||
                            (x.Dosage != null && x.Dosage.Contains(searchValue)) ||
                            (x.Form != null && x.Form.Contains(searchValue)) ||
                            (isDateSearch && x.PrescriptionDate == searchDate.Date)
                        );
                    }

                    var FilteredCount = query.Count();

                    // Sorting
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
                                    ? query.OrderBy(x => x.PrescriptionDate ?? DateTime.MinValue)
                                    : query.OrderByDescending(x => x.PrescriptionDate ?? DateTime.MinValue);
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
                                query = query.OrderByDescending(x => x.PrescriptionDate ?? DateTime.MinValue);
                                break;
                        }
                    }
                    else
                    {
                        query = query.OrderByDescending(x => x.PrescriptionDate ?? DateTime.MinValue);
                    }

                    // Apply paging and format dates as ISO strings
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

                    // Final result
                    var result = new
                    {
                        draw = draw,
                        recordsTotal = Total_pat,
                        recordsFiltered = FilteredCount,
                        data = data
                    };

                    // 🔑 Serialize to string so frontend can parse it
                    return JsonConvert.SerializeObject(result);
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
                return JsonConvert.SerializeObject(errorResult);
            }
        }

        [WebMethod]
        public static object InvestigationViewList(int regID, int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    // Get all patient IDs
                    var patientIds = db.Out_Patients
                        .Where(op => op.Reg_PatId == regID)
                        .Select(op => op.Out_Patient_ID)
                        .Concat(db.In_Patients
                            .Where(ip => ip.Patient_ID == regID)
                            .Select(ip => ip.In_Patient_ID))
                        .Concat(db.Emergency_Patients
                            .Where(ep => ep.Patient_ID == regID)
                            .Select(ep => ep.Emergency_ID))
                        .ToList();

                    // Query investigation tests (Lab Dept: "001")
                    var query = (from lbtM in db.Laboratory_Tests
                                 join lbtD in db.Lab_Test_Details on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                 join lab in db.Lab_Tests on lbtD.Test_ID equals lab.Test_ID
                                 where (patientIds.Contains(lbtD.Patient_ID) || lbtD.Patient_ID == regID)
                                       && lbtD.Dept_ID == "001"
                                 select new
                                 {
                                     Lab_Test_Detail_ID = lbtD.Lab_Test_Detail_ID,
                                     Date = lbtD.Date,
                                     Remark = lbtD.Remark,
                                     Test_Name = db.Lab_Tests
                                         .Where(t => t.Test_ID == lbtD.Test_ID)
                                         .Select(t => t.Test_Name)
                                         .FirstOrDefault(),
                                     Special_Tests = lbtD.Special_Tests,
                                     Area_Of_Interest = lbtD.Area_Of_Interest
                                 });

                    var Total_pat = query.Count();

                    // Search
                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        DateTime searchDate;
                        bool isDateSearch = DateTime.TryParse(searchValue, out searchDate);

                        query = query.Where(x =>
                            (x.Test_Name != null && x.Test_Name.Contains(searchValue)) ||
                            (x.Remark != null && x.Remark.Contains(searchValue)) ||
                            (x.Special_Tests != null && x.Special_Tests.Contains(searchValue)) ||
                            (x.Area_Of_Interest != null && x.Area_Of_Interest.Contains(searchValue)) ||
                            (isDateSearch && x.Date == searchDate.Date)
                        );
                    }

                    var FilteredCount = query.Count();

                    // Sorting
                    if (!string.IsNullOrEmpty(sortColumn))
                    {
                        switch (sortColumn)
                        {
                            case "Test_Name":
                                query = sortColumnDirection == "asc"
                                    ? query.OrderBy(x => x.Test_Name)
                                    : query.OrderByDescending(x => x.Test_Name);
                                break;
                            case "Date":
                                query = sortColumnDirection == "asc"
                                    ? query.OrderBy(x => x.Date ?? DateTime.MinValue)
                                    : query.OrderByDescending(x => x.Date ?? DateTime.MinValue);
                                break;
                            case "Special_Tests":
                                query = sortColumnDirection == "asc"
                                    ? query.OrderBy(x => x.Special_Tests)
                                    : query.OrderByDescending(x => x.Special_Tests);
                                break;
                            case "Area_Of_Interest":
                                query = sortColumnDirection == "asc"
                                    ? query.OrderBy(x => x.Area_Of_Interest)
                                    : query.OrderByDescending(x => x.Area_Of_Interest);
                                break;
                            default:
                                query = query.OrderByDescending(x => x.Date ?? DateTime.MinValue);
                                break;
                        }
                    }
                    else
                    {
                        query = query.OrderByDescending(x => x.Date ?? DateTime.MinValue);
                    }

                    // Format data
                    var data = query.Skip(start).Take(length).AsEnumerable()
                        .Select(x => new
                        {
                            Lab_Test_Detail_ID = x.Lab_Test_Detail_ID,
                            Date = x.Date?.ToString("yyyy-MM-ddTHH:mm:ss"),
                            Remark = x.Remark ?? "N/A",
                            Test_Name = x.Test_Name ?? "N/A",
                            Special_Tests = x.Special_Tests ?? "N/A",
                            Area_Of_Interest = x.Area_Of_Interest ?? "N/A"
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
        public static object DiagnosticsViewList(int regID, int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    // Get all patient IDs
                    var patientIds = db.Out_Patients
                        .Where(op => op.Reg_PatId == regID)
                        .Select(op => op.Out_Patient_ID)
                        .Concat(db.In_Patients
                            .Where(ip => ip.Patient_ID == regID)
                            .Select(ip => ip.In_Patient_ID))
                        .Concat(db.Emergency_Patients
                            .Where(ep => ep.Patient_ID == regID)
                            .Select(ep => ep.Emergency_ID))
                        .ToList();

                    // Query diagnostic tests (Non-Lab Dept)
                    var query = (from lbtM in db.Laboratory_Tests
                                 join lbtD in db.Lab_Test_Details on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                 join lab in db.Lab_Tests on lbtD.Test_ID equals lab.Test_ID
                                 where (patientIds.Contains(lbtD.Patient_ID) || lbtD.Patient_ID == regID)
                                       && lbtD.Dept_ID != "001"
                                 select new
                                 {
                                     Lab_Test_Detail_ID = lbtD.Lab_Test_Detail_ID,
                                     Date = lbtD.Date,
                                     Remark = lbtD.Remark,
                                     Department = db.GetDataValueName("Main Test Departments", lbtD.Dept_ID),
                                     Test_Name = db.Lab_Tests
                                         .Where(t => t.Test_ID == lbtD.Test_ID)
                                         .Select(t => t.Test_Name)
                                         .FirstOrDefault(),
                                     Special_Tests = lbtD.Special_Tests,
                                     Area_Of_Interest = lbtD.Area_Of_Interest,
                                     Rotation = (db.GetDataValueName("Main Test Departments", lbtD.Dept_ID) == "X-Ray")
                                         ? db.GetDataValueName("Test XRay Rotations", lbtD.Rotation_ID)
                                         : db.GetDataValueName("Test CT Scan Rotations", lbtD.Rotation_ID)
                                 });

                    var Total_pat = query.Count();

                    // Search
                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        DateTime searchDate;
                        bool isDateSearch = DateTime.TryParse(searchValue, out searchDate);

                        query = query.Where(x =>
                            (x.Test_Name != null && x.Test_Name.Contains(searchValue)) ||
                            (x.Department != null && x.Department.Contains(searchValue)) ||
                            (x.Rotation != null && x.Rotation.Contains(searchValue)) ||
                            (x.Remark != null && x.Remark.Contains(searchValue)) ||
                            (x.Special_Tests != null && x.Special_Tests.Contains(searchValue)) ||
                            (x.Area_Of_Interest != null && x.Area_Of_Interest.Contains(searchValue)) ||
                            (isDateSearch && x.Date == searchDate.Date)
                        );
                    }

                    var FilteredCount = query.Count();

                    // Sorting
                    if (!string.IsNullOrEmpty(sortColumn))
                    {
                        switch (sortColumn)
                        {
                            case "Date":
                                query = sortColumnDirection == "asc"
                                    ? query.OrderBy(x => x.Date ?? DateTime.MinValue)
                                    : query.OrderByDescending(x => x.Date ?? DateTime.MinValue);
                                break;
                            case "Department":
                                query = sortColumnDirection == "asc"
                                    ? query.OrderBy(x => x.Department)
                                    : query.OrderByDescending(x => x.Department);
                                break;
                            default:
                                query = query.OrderByDescending(x => x.Date ?? DateTime.MinValue);
                                break;
                        }
                    }
                    else
                    {
                        query = query.OrderByDescending(x => x.Date ?? DateTime.MinValue);
                    }

                    // Format data
                    var data = query.Skip(start).Take(length).AsEnumerable()
                        .Select(x => new
                        {
                            Lab_Test_Detail_ID = x.Lab_Test_Detail_ID,
                            Date = x.Date?.ToString("yyyy-MM-ddTHH:mm:ss"),
                            Remark = x.Remark ?? "N/A",
                            Test_Name = x.Test_Name ?? "N/A",
                            Special_Tests = x.Special_Tests ?? "N/A",
                            Area_Of_Interest = x.Area_Of_Interest ?? "N/A",
                            Department = x.Department ?? "N/A",
                            Rotation = x.Rotation ?? "N/A"
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