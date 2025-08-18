using System;
using System.Collections.Generic;
using System.Linq;
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

            var result = new
            {
                OutPatientCount = OPD,
                InPatientCount = IPD,
                EmergencyCaseCount = Emergency,
                MediceneCount = Medicenes,
                InvestigationCount = InvestigationCount,
                DiagnosticCount = DiagnosticCount,
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
                    // Get total count from Out_Patients where regid matches
                    var Total_pat = _dbContext.Out_Patients.Count(op => op.Reg_PatId == regID);

                    var query = from op in _dbContext.Out_Patients
                                join p in _dbContext.Patients on op.Patient_ID equals p.Patient_ID
                                join emp in _dbContext.HR_Employees on op.Doctor_ID equals emp.Emp_ID.ToString() into empJoin
                                from emp in empJoin.DefaultIfEmpty()
                                where op.Reg_PatId == regID && p.isCancel == false
                                select new
                                {
                                    VisitNo = op.Out_Patient_ID,
                                    VisitDate = op.Created_Time.HasValue ? op.Created_Time.Value.Date : (DateTime?)null,
                                    Department = _dbContext.GetDataValueName("Patient Main Category", p.Patient_Main_Category) ?? "N/A",
                                    PatientType = _dbContext.GetDataValueName("Patient Type", p.Patient_Type) ?? "N/A",
                                    CheckedBy = emp != null ? emp.Emp_Name : "N/A",
                                    Remarks = op.Final_Rec ?? "",
                                    DischargeDate = op.discharge_date.HasValue ? op.discharge_date.Value.Date : (DateTime?)null,
                                    Status = op.Discharge.HasValue ? (op.Discharge.Value ? "Consulted" : "Active") : "Active"
                                };

                    // Apply search filter if searchValue is provided
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
                                (x.VisitDate.HasValue && x.VisitDate.Value.Date == searchDate.Date) ||
                                (x.DischargeDate.HasValue && x.DischargeDate.Value.Date == searchDate.Date)
                            ))
                        );
                    }

                    var FilteredCount = query.Count();

                    // Apply sorting
                    if (!string.IsNullOrEmpty(sortColumn))
                    {
                        switch (sortColumn)
                        {
                            case "VisitNo":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.VisitNo) : query.OrderByDescending(x => x.VisitNo);
                                break;
                            case "VisitDate":
                                query = sortColumnDirection == "asc" ?
                                    query.OrderBy(x => x.VisitDate.HasValue ? x.VisitDate : DateTime.MaxValue) :
                                    query.OrderByDescending(x => x.VisitDate.HasValue ? x.VisitDate : DateTime.MinValue);
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
                                query = sortColumnDirection == "asc" ?
                                    query.OrderBy(x => x.DischargeDate.HasValue ? x.DischargeDate : DateTime.MaxValue) :
                                    query.OrderByDescending(x => x.DischargeDate.HasValue ? x.DischargeDate : DateTime.MinValue);
                                break;
                            default:
                                query = query.OrderByDescending(x => x.VisitDate.HasValue ? x.VisitDate : DateTime.MinValue);
                                break;
                        }
                    }
                    else
                    {
                        query = query.OrderByDescending(x => x.VisitDate.HasValue ? x.VisitDate : DateTime.MinValue);
                    }

                    // Apply paging and format dates
                    var data = query.Skip(start).Take(length).AsEnumerable()
                        .Select(x => new
                        {
                            VisitNo = x.VisitNo,
                            VisitDate = x.VisitDate.HasValue ? x.VisitDate.Value.ToString("MM/dd/yyyy") : "",
                            Department = x.Department ?? "N/A",
                            PatientType = x.PatientType ?? "N/A",
                            CheckedBy = x.CheckedBy ?? "N/A",
                            Remarks = x.Remarks ?? "",
                            DischargeDate = x.DischargeDate.HasValue ? x.DischargeDate.Value.ToString("MM/dd/yyyy") : "",
                            Status = x.Status ?? "Active"
                        }).ToList();

                    // Return the proper DataTables structure
                    var jsonData = new
                    {
                        draw = draw,
                        recordsFiltered = FilteredCount,
                        recordsTotal = Total_pat,
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
        public static object IPDViewList(int regID, int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {

            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    // Get total count from In_Patient where regid matches
                    var Total_pat = _dbContext.In_Patients.Count(ip => ip.Patient_ID == regID);

                    var query = from ip in _dbContext.In_Patients
                                 join emp in _dbContext.HR_Employees on ip.Doctor equals emp.Emp_ID.ToString() into empJoin
                                from emp in empJoin.DefaultIfEmpty()

                                    // Join with Ward_Allocation to get current ward assignment
                                join wa in _dbContext.Ward_Allocations on ip.In_Patient_ID.ToString() equals wa.InPatient_ID into wardAllocJoin
                                from wa in wardAllocJoin.Where(x => (x.IsDischarge == false || x.IsDischarge == null) &&
                                                                   (x.isCancelled == false || x.isCancelled == null))
                                                            .Take(1)
                                                            .DefaultIfEmpty()

                                    // Join with Ward_Definition to get ward details
                                join wd in _dbContext.Ward_Definitions on wa.Ward_ID equals wd.Ward_ID into wardDefJoin
                                from wd in wardDefJoin.DefaultIfEmpty()

                                    // Join with Room_Allocation to get current room assignment
                                join ra in _dbContext.Room_Allocations on ip.In_Patient_ID equals ra.In_Patient_ID into roomAllocJoin
                                from ra in roomAllocJoin.Take(1).DefaultIfEmpty()

                                    // Join with Rooms to get room details
                                join r in _dbContext.Rooms on ra.Room_ID equals r.Room_ID into roomJoin
                                from r in roomJoin.DefaultIfEmpty()

                                    // Join with doctor for ward allocation
                                join wardDoc in _dbContext.HR_Employees on wa.Doctor_Assigned equals wardDoc.Emp_ID into wardDocJoin
                                from wardDoc in wardDocJoin.DefaultIfEmpty()

                                where ip.Patient_ID == regID
                                select new
                                {
                                    IPD_ID = ip.In_Patient_ID,
                                    AdmissionDate = ip.Admission_Date,
                                    Department = _dbContext.GetDataValueName("Patient Main Category", ip.Department) ?? "N/A",
                                     WardType = wd != null ? wd.Ward_Type : "N/A",
                                    WardNo = wd != null ? (wd.Ward_No.HasValue ? wd.Ward_No.Value.ToString() : "N/A") : "N/A",
                                    RoomNo = r != null ? r.Room_No : "N/A",
                                    RoomName = r != null ? r.Name : "N/A",
                                    BedNo = wa != null ? (wa.Bed_No_Assigned.HasValue ? wa.Bed_No_Assigned.Value.ToString() : "N/A") : "N/A",
                                    AttendingDoctor = wardDoc != null ? wardDoc.Emp_Name : (emp != null ? emp.Emp_Name : "N/A"),
                                    ProvisionalDiagnosis = ip.Provisional_Diagnosis ?? "",
                                    ExpectedDischargeDate = ip.Expected_Discharge_Date,
                                    DischargeDate = ip.Discharge_On,
                                    AdmissionType = ip.AdmissionType ?? "Regular",
                                    Status = ip.Discharge.HasValue ?
                                            (ip.Discharge.Value ? "Discharged" : "Admitted") :
                                            (ip.Death_Certificate.HasValue && ip.Death_Certificate.Value ? "Deceased" : "Admitted"),
                                  
                                    ReferringDoctor = ip.Referring_Doctor ?? "",
                                    
                                    WardAllocationFrom = wa != null ? wa.From_TimeDate : null,
                                    RoomType = ra != null ? ra.Room_Type : (r != null ? r.Room_Type : "N/A"),
                                    Building = r != null ? r.Building_Type : "N/A",
                                    Floor = r != null ? (r.Floor_No.HasValue ? r.Floor_No.Value.ToString() : "N/A") : "N/A",
                                    Location = r != null ? r.Location : "N/A"
                                };

                    // Apply search filter if searchValue is provided
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
                                (x.AdmissionDate.HasValue && x.AdmissionDate.Value.Date == searchDate.Date) ||
                                (x.ExpectedDischargeDate.HasValue && x.ExpectedDischargeDate.Value.Date == searchDate.Date) ||
                                (x.DischargeDate.HasValue && x.DischargeDate.Value.Date == searchDate.Date)
                            ))
                        );
                    }

                    var FilteredCount = query.Count();

                    // Apply sorting
                    if (!string.IsNullOrEmpty(sortColumn))
                    {
                        switch (sortColumn)
                        {
                            case "IPD_ID":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.IPD_ID) : query.OrderByDescending(x => x.IPD_ID);
                                break;
                            case "AdmissionDate":
                                query = sortColumnDirection == "asc" ?
                                    query.OrderBy(x => x.AdmissionDate.HasValue ? x.AdmissionDate : DateTime.MaxValue) :
                                    query.OrderByDescending(x => x.AdmissionDate.HasValue ? x.AdmissionDate : DateTime.MinValue);
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
                            case "DischargeDate":
                                query = sortColumnDirection == "asc" ?
                                    query.OrderBy(x => x.DischargeDate.HasValue ? x.DischargeDate : DateTime.MaxValue) :
                                    query.OrderByDescending(x => x.DischargeDate.HasValue ? x.DischargeDate : DateTime.MinValue);
                                break;
                            case "ExpectedDischargeDate":
                                query = sortColumnDirection == "asc" ?
                                    query.OrderBy(x => x.ExpectedDischargeDate.HasValue ? x.ExpectedDischargeDate : DateTime.MaxValue) :
                                    query.OrderByDescending(x => x.ExpectedDischargeDate.HasValue ? x.ExpectedDischargeDate : DateTime.MinValue);
                                break;
                            default:
                                query = query.OrderByDescending(x => x.AdmissionDate.HasValue ? x.AdmissionDate : DateTime.MinValue);
                                break;
                        }
                    }
                    else
                    {
                        query = query.OrderByDescending(x => x.AdmissionDate.HasValue ? x.AdmissionDate : DateTime.MinValue);
                    }

                    // Apply paging and format dates
                    var data = query.Skip(start).Take(length).AsEnumerable()
                        .Select(x => new
                        {
                            IPD_ID = x.IPD_ID,
                            AdmissionDate = x.AdmissionDate.HasValue ? x.AdmissionDate.Value.ToString("MM/dd/yyyy") : "",
                            Department = x.Department ?? "N/A",
                            WardName = x.WardType ?? "N/A",
                            RoomNo = x.RoomNo ?? "N/A",
                            BedNo = x.BedNo ?? "N/A",
                            AttendingDoctor = x.AttendingDoctor ?? "N/A", 
                            ExpectedDischargeDate = x.ExpectedDischargeDate.HasValue ? x.ExpectedDischargeDate.Value.ToString("MM/dd/yyyy") : "",
                            DischargeDate = x.DischargeDate.HasValue ? x.DischargeDate.Value.ToString("MM/dd/yyyy") : "",
                             Status = x.Status ?? "Admitted",
                             ReferringDoctor = x.ReferringDoctor ?? ""
                        }).ToList();

                    // Return the proper DataTables structure
                    var jsonData = new
                    {
                        draw = draw,
                        recordsFiltered = FilteredCount,
                        recordsTotal = Total_pat,
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
        public static object EMERGENCYViewList(int regID, int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    // Get total count from In_Patient where regid matches
                    var Total_pat = _dbContext.Emergency_Patients.Count(ip => ip.Patient_ID == regID);

                    var query = from ip in _dbContext.Emergency_Patients
                                join emp in _dbContext.HR_Employees on ip.Doctor equals emp.Emp_ID.ToString() into empJoin
                                from emp in empJoin.DefaultIfEmpty()

                                    // Join with Ward_Allocation to get current ward assignment
                                join wa in _dbContext.Ward_Allocations on ip.Emergency_ID equals wa.EmergencyID into wardAllocJoin
                                from wa in wardAllocJoin.Take(1)
                                                          .DefaultIfEmpty()
                                     
                                    // Join with Ward_Definition to get ward details
                                join wd in _dbContext.Ward_Definitions on wa.Ward_ID equals wd.Ward_ID into wardDefJoin
                                from wd in wardDefJoin.DefaultIfEmpty()

                                    // Join with doctor for ward allocation
                                join wardDoc in _dbContext.HR_Employees on wa.Doctor_Assigned equals wardDoc.Emp_ID into wardDocJoin
                                from wardDoc in wardDocJoin.DefaultIfEmpty()

                                where ip.Patient_ID == regID
                                select new
                                {
                                    EMERGENCY_ID = ip.Emergency_ID,
                                    AdmissionDate = ip.Admission_Date,
                                     WardType = wd != null ? wd.Ward_Type : "N/A",
                                    WardNo = wd != null ? (wd.Ward_No.HasValue ? wd.Ward_No.Value.ToString() : "N/A") : "N/A",
                                    BedNo = wa != null ? (wa.Bed_No_Assigned.HasValue ? wa.Bed_No_Assigned.Value.ToString() : "N/A") : "N/A",
                                    AttendingDoctor = wardDoc != null ? wardDoc.Emp_Name : (emp != null ? emp.Emp_Name : "N/A"),
                                     DischargeDate = ip.Discharge_On,
                                     Status = ip.Discharge.HasValue ?
                                            (ip.Discharge.Value ? "Discharged" : "Admitted") :
                                            (ip.Death_Certificate.HasValue && ip.Death_Certificate.Value ? "Deceased" : "Admitted"),
                                 };

                    // Apply search filter if searchValue is provided
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
                                (x.AdmissionDate.HasValue && x.AdmissionDate.Value.Date == searchDate.Date) ||
                                 (x.DischargeDate.HasValue && x.DischargeDate.Value.Date == searchDate.Date)
                            ))
                        );
                    }

                    var FilteredCount = query.Count();

                    // Apply sorting
                    if (!string.IsNullOrEmpty(sortColumn))
                    {
                        switch (sortColumn)
                        {
                            case "EMERGENCY_ID":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.EMERGENCY_ID) : query.OrderByDescending(x => x.EMERGENCY_ID);
                                break;
                            case "AdmissionDate":
                                query = sortColumnDirection == "asc" ?
                                    query.OrderBy(x => x.AdmissionDate.HasValue ? x.AdmissionDate : DateTime.MaxValue) :
                                    query.OrderByDescending(x => x.AdmissionDate.HasValue ? x.AdmissionDate : DateTime.MinValue);
                                break;
                             
                            case "WardName":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.WardType) : query.OrderByDescending(x => x.WardType);
                                break;
                             
                            case "Status":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.Status) : query.OrderByDescending(x => x.Status);
                                break;
                            case "DischargeDate":
                                query = sortColumnDirection == "asc" ?
                                    query.OrderBy(x => x.DischargeDate.HasValue ? x.DischargeDate : DateTime.MaxValue) :
                                    query.OrderByDescending(x => x.DischargeDate.HasValue ? x.DischargeDate : DateTime.MinValue);
                                break;
                            
                            default:
                                query = query.OrderByDescending(x => x.AdmissionDate.HasValue ? x.AdmissionDate : DateTime.MinValue);
                                break;
                        }
                    }
                    else
                    {
                        query = query.OrderByDescending(x => x.AdmissionDate.HasValue ? x.AdmissionDate : DateTime.MinValue);
                    }

                    // Apply paging and format dates
                    var data = query.Skip(start).Take(length).AsEnumerable()
                        .Select(x => new
                        {
                            EMERGENCY_ID = x.EMERGENCY_ID,
                            AdmissionDate = x.AdmissionDate.HasValue ? x.AdmissionDate.Value.ToString("MM/dd/yyyy") : "",
                              WardName = x.WardType ?? "N/A",
                            BedNo = x.BedNo ?? "N/A",
                            AttendingDoctor = x.AttendingDoctor ?? "N/A",
                             DischargeDate = x.DischargeDate.HasValue ? x.DischargeDate.Value.ToString("MM/dd/yyyy") : "",
                            Status = x.Status ?? "Admitted",
                         }).ToList();

                    // Return the proper DataTables structure
                    var jsonData = new
                    {
                        draw = draw,
                        recordsFiltered = FilteredCount,
                        recordsTotal = Total_pat,
                        data = data
                    };

                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                // Log the exception and return empty result
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

                    // Step 2: Get all medicine records matching any of these IDs
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
                    // Get total count of patients with this regID
                    var Total_pat = query.Count();
                    // Apply search filter if searchValue is provided
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

                    // Apply sorting
                    if (!string.IsNullOrEmpty(sortColumn))
                    {
                        switch (sortColumn)
                        {
                            case "MedicineName":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.MedicineName) : query.OrderByDescending(x => x.MedicineName);
                                break;
                            case "PrescriptionDate":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.PrescriptionDate) : query.OrderByDescending(x => x.PrescriptionDate);
                                break;
                            case "Dosage":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.Dosage) : query.OrderByDescending(x => x.Dosage);
                                break;
                            case "Form":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.Form) : query.OrderByDescending(x => x.Form);
                                break;
                            default:
                                query = query.OrderByDescending(x => x.PrescriptionDate);
                                break;
                        }
                    }
                    else
                    {
                        query = query.OrderByDescending(x => x.PrescriptionDate);
                    }

                    // Apply paging and format dates
                    var data = query.Skip(start).Take(length).AsEnumerable()
                        .Select(x => new
                        {
                             MedicineName = x.MedicineName ?? "N/A",
                            Dosage = x.Dosage ?? "N/A",
                            Form = x.Form ?? "N/A",
                            Route = x.Route ?? "N/A",
                            Duration = x.Duration ?? "N/A",
                            Frequency = x.Frequency ?? "N/A",
                            PrescriptionDate = x.PrescriptionDate ,
                            Instructions = x.Instructions ?? "N/A"
                        }).ToList();

                    // Return the proper DataTables structure
                    var jsonData = new
                    {
                        draw = draw,
                        recordsFiltered = FilteredCount,
                        recordsTotal = Total_pat,
                        data = data
                    };

                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                // Log the exception and return empty result
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
        public static object InvestigationViewList(int regID, int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
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
                    var query = (from lbtM in db.Laboratory_Tests
                                 join lbtD in db.Lab_Test_Details
                                 on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                 join lab in db.Lab_Tests on lbtD.Test_ID equals lab.Test_ID 
                                 where (patientIds.Contains(lbtD.Patient_ID) ||
                                                    lbtD.Patient_ID == regID)
                                 && lbtD.Dept_ID == "001"
                                 select new
                                 {
                                     Lab_Test_Detail_ID =  lbtD.Lab_Test_Detail_ID,
                                     lbtD.Date,
                                     lbtD.Remark,
                                     Test_Name = (from t in db.Lab_Tests
                                                  where t.Test_ID == lbtD.Test_ID
                                                  select t.Test_Name).FirstOrDefault(),
                                      
                                     lbtD.Special_Tests,
                                     lbtD.Area_Of_Interest,
                                 });

                    // Get total count of records
                    var Total_pat = query.Count();

                    // Apply search filter if searchValue is provided
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

                    // Apply sorting
                    if (!string.IsNullOrEmpty(sortColumn))
                    {
                        switch (sortColumn)
                        {
                            case "Test_Name":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.Test_Name) : query.OrderByDescending(x => x.Test_Name);
                                break;
                            case "Date":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.Date) : query.OrderByDescending(x => x.Date);
                                break;
                             
                            case "Special_Tests":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.Special_Tests) : query.OrderByDescending(x => x.Special_Tests);
                                break;
                            case "Area_Of_Interest":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.Area_Of_Interest) : query.OrderByDescending(x => x.Area_Of_Interest);
                                break;
                            default:
                                query = query.OrderByDescending(x => x.Date);
                                break;
                        }
                    }
                    else
                    {
                        query = query.OrderByDescending(x => x.Date);
                    }

                    // Apply paging and format data
                    var data = query.Skip(start).Take(length).AsEnumerable()
                        .Select(x => new
                        {
                            Lab_Test_Detail_ID = x.Lab_Test_Detail_ID,
                            Date = x.Date,
                            Remark = x.Remark ?? "N/A",
                            Test_Name = x.Test_Name ?? "N/A",
                             Special_Tests = x.Special_Tests ?? "N/A",
                            Area_Of_Interest = x.Area_Of_Interest ?? "N/A"
                        }).ToList();

                    // Return the proper DataTables structure
                    var jsonData = new
                    {
                        draw = draw,
                        recordsFiltered = FilteredCount,
                        recordsTotal = Total_pat,
                        data = data
                    };

                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                // Log the exception and return empty result
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
        public static object DiagnosticsViewList(int regID, int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
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
                    var query = (from lbtM in db.Laboratory_Tests
                                 join lbtD in db.Lab_Test_Details
                                 on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                 join lab in db.Lab_Tests on lbtD.Test_ID equals lab.Test_ID 
                                 where (patientIds.Contains(lbtD.Patient_ID) ||
                                                     lbtD.Patient_ID == regID)
                                  && lbtD.Dept_ID != "001"
                                 select new
                                 {
                                     Lab_Test_Detail_ID = lbtD.Lab_Test_Detail_ID,
                                     Rotation = ((from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test Departments", t.Main_Department)).FirstOrDefault()) == "X-Ray"
                                              ? db.GetDataValueName("Test XRay Rotations", lbtD.Rotation_ID)
                                              : db.GetDataValueName("Test CT Scan Rotations", lbtD.Rotation_ID),

                                              
                                     lbtD.Date,
                                     lbtD.Remark,
                                     Department = db.GetDataValueName("Main Test Departments", lbtD.Dept_ID),
                                     Test_Name = (from t in db.Lab_Tests
                                                  where t.Test_ID == lbtD.Test_ID
                                                  select t.Test_Name).FirstOrDefault(),
                                     lbtD.Special_Tests,
                                     lbtD.Area_Of_Interest,
                                 });

                    // Get total count of records
                    var Total_pat = query.Count();

                    // Apply search filter if searchValue is provided
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

                    // Apply sorting
                    if (!string.IsNullOrEmpty(sortColumn))
                    {
                        switch (sortColumn)
                        {
                             
                            case "Date":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.Date) : query.OrderByDescending(x => x.Date);
                                break;
                             
                            case "Department":
                                query = sortColumnDirection == "asc" ? query.OrderBy(x => x.Department) : query.OrderByDescending(x => x.Department);
                                break;
                             
                            default:
                                query = query.OrderByDescending(x => x.Date);
                                break;
                        }
                    }
                    else
                    {
                        query = query.OrderByDescending(x => x.Date);
                    }

                    // Apply paging and format data
                    var data = query.Skip(start).Take(length).AsEnumerable()
                        .Select(x => new
                        {
                            Lab_Test_Detail_ID = x.Lab_Test_Detail_ID,
                            Date = x.Date,
                            Remark = x.Remark ?? "N/A",
                            Test_Name = x.Test_Name ?? "N/A",
                             Special_Tests = x.Special_Tests ?? "N/A",
                            Area_Of_Interest = x.Area_Of_Interest ?? "N/A",
                            Department = x.Department ?? "N/A",
                            Rotation = x.Rotation ?? "N/A",
                        }).ToList();

                    // Return the proper DataTables structure
                    var jsonData = new
                    {
                        draw = draw,
                        recordsFiltered = FilteredCount,
                        recordsTotal = Total_pat,
                        data = data
                    };

                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                // Log the exception and return empty result
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