using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using Newtonsoft.Json;
using System.Web.Script.Serialization;

namespace PMS.Modules.PatientManagement
{
    public partial class DialysisForm : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string GenerateDialysisId()
        {
            try
            {
                string today = DateTime.Now.ToString("yyyyMMdd");
                string prefix = $"DLY-{today}-";

                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    int count = db.Dialysis_PreDialysis
                                  .Count(d => d.Dialysis_ID.StartsWith(prefix));
                    
                    int nextNumber = count + 1;
                    string dialysisId = $"{prefix}{nextNumber.ToString("D4")}";
                    return dialysisId;
                }
            }
            catch (Exception ex)
            {
                return "DLY-" + DateTime.Now.ToString("yyyyMMdd") + "-0001";
            }
        }

        [WebMethod]
        public static string GetDialysisData(string dialysisId)
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var preDialysis = (from pd in db.Dialysis_PreDialysis
                                       where pd.Dialysis_ID == dialysisId
                                       select pd).ToList();

                    var duringDialysis = (from dd in db.Dialysis_DuringDialysis
                                          where dd.Dialysis_ID == dialysisId
                                          orderby dd.Vital_Time
                                          select dd).ToList();

                    var postDialysis = (from pod in db.Dialysis_PostDialysis
                                        where pod.Dialysis_ID == dialysisId
                                        select pod).ToList();

                    return JsonConvert.SerializeObject(new
                    {
                        PreDialysis = preDialysis,
                        DuringDialysis = duringDialysis,
                        PostDialysis = postDialysis
                    });
                }
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new { error = ex.Message });
            }
        }

        [WebMethod]
        public static string GetPatients()
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var patients = (from p in db.Reg_patients
                                    orderby p.pat_id descending
                                    select new
                                    {
                                        PatientId = p.pat_id,
                                        MRNo = p.mr_no_sequence ?? "",
                                        PatientName = p.Full_Name ?? "",
                                        FatherName = p.Father_Name ?? "",
                                        NIC = p.NIC ?? "",
                                        ContactNo = p.Mobile1 ?? "",
                                        Age = p.Age_years ?? "",
                                        Gender = p.Gender ?? ""
                                    })
                                   .Take(50)
                                   .ToList();

                    return JsonConvert.SerializeObject(patients);
                }
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new { error = ex.Message });
            }
        }

        [WebMethod]
        public static string SearchPatients(string searchText)
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var patients = (from p in db.Reg_patients
                                    where p.Full_Name.Contains(searchText)
                                       || p.mr_no_sequence.Contains(searchText)
                                       || p.Father_Name.Contains(searchText)
                                       || p.NIC.Contains(searchText)
                                       || p.Mobile1.Contains(searchText)
                                    orderby p.pat_id descending
                                    select new
                                    {
                                        PatientId = p.pat_id,
                                        MRNo = p.mr_no_sequence ?? "",
                                        PatientName = p.Full_Name ?? "",
                                        FatherName = p.Father_Name ?? "",
                                        NIC = p.NIC ?? "",
                                        ContactNo = p.Mobile1 ?? "",
                                        Age = p.Age_years ?? "",
                                        Gender = p.Gender ?? ""
                                    })
                                   .Take(50)
                                   .ToList();

                    return JsonConvert.SerializeObject(patients);
                }
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new { error = ex.Message });
            }
        }

        [WebMethod]
        public static string GetVascularAccess()
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Vascular Access"
                              select new
                              {
                                  Value = dv.DataValue_Name,
                                  Text = dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        [WebMethod]
        public static string GetMachines()
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Dialysis Machines"
                              select new
                              {
                                  Value = dv.DataValue_Name,
                                  Text = dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        [WebMethod]
        public static string GetDialyzers()
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Dialyzers"
                              select new
                              {
                                  Value = dv.DataValue_Name,
                                  Text = dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        [WebMethod]
        public static string GetDoctors()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var doctorList = (from emp in db.HR_Employees
                                  where emp.Resign_Date == null && emp.IsDoctor == true
                                  select new { emp.Emp_ID, emp.Emp_Name }).ToList();
                return (new JavaScriptSerializer()).Serialize(doctorList);
            }
        }

        [WebMethod]
        public static string GetNurses()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var nurseList = (from emp in db.HR_Employees
                                 where emp.Resign_Date == null && emp.IsDoctor == false
                                 && (emp.Designation == "Nurse" || emp.Department == "Nursing")
                                 select new { emp.Emp_ID, emp.Emp_Name }).ToList();
                return (new JavaScriptSerializer()).Serialize(nurseList);
            }
        }

        [WebMethod]
        public static string GetHeparin()
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Heparin Types"
                              select new
                              {
                                  Value = dv.DataValue_Name,
                                  Text = dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        [WebMethod]
        public static string GetDialysisTypes()
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Dialysis Types"
                              select new
                              {
                                  Value = dv.DataValue_Name,
                                  Text = dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        [WebMethod]
        public static string GetStaff()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var staffList = (from emp in db.HR_Employees
                                 where emp.Resign_Date == null
                                 select new { emp.Emp_ID, emp.Emp_Name }).ToList();
                return (new JavaScriptSerializer()).Serialize(staffList);
            }
        }

        [WebMethod]
        public static string GetGenders()
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Gender"
                              select new
                              {
                                  Value = dv.DataValue_Name,
                                  Text = dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        [WebMethod]
        public static string GetMaritalStatus()
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Marital Status"
                              select new
                              {
                                  Value = dv.DataValue_Name,
                                  Text = dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        [WebMethod]
        public static string GetCountries()
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Country"
                              select new
                              {
                                  Value = dv.DataValue_Name,
                                  Text = dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        [WebMethod]
        public static string GetProvinces(string countryId)
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Province"
                              select new
                              {
                                  Value = dv.DataValue_Name,
                                  Text = dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        [WebMethod]
        public static string GetCities(string provinceId)
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "City"
                              select new
                              {
                                  Value = dv.DataValue_Name,
                                  Text = dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        [WebMethod]
        public static string GetAreas(string cityId)
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Area"
                              select new
                              {
                                  Value = dv.DataValue_Name,
                                  Text = dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        [WebMethod]
        public static string SavePreDialysis(string data)
        {
            try
            {
                var preDialysisData = JsonConvert.DeserializeObject<PreDialysisData>(data);
                
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var existingRecord = db.Dialysis_PreDialysis
                                           .FirstOrDefault(d => d.Dialysis_ID == preDialysisData.DialysisId);
                    
                    if (existingRecord != null)
                    {
                        UpdatePreDialysisRecord(existingRecord, preDialysisData);
                        existingRecord.Modified_Date = DateTime.Now;
                        existingRecord.Modified_By = HttpContext.Current.Session["UserID"]?.ToString();
                        db.SubmitChanges();
                    }
                    else
                    {
                        var newRecord = new Dialysis_PreDialysi();
                        UpdatePreDialysisRecord(newRecord, preDialysisData);
                        newRecord.Dialysis_ID = preDialysisData.DialysisId;
                        newRecord.Created_Date = DateTime.Now;
                        newRecord.Created_By = HttpContext.Current.Session["UserID"]?.ToString();
                        
                        db.Dialysis_PreDialysis.InsertOnSubmit(newRecord);
                        db.SubmitChanges();
                    }
                }

                return preDialysisData.DialysisId;
            }
            catch (Exception ex)
            {
                return "error: " + ex.Message;
            }
        }

        private static void UpdatePreDialysisRecord(Dialysis_PreDialysi record, PreDialysisData data)
        {
            if (!string.IsNullOrEmpty(data.PatientId))
                record.Patient_ID = int.Parse(data.PatientId);
            
            record.Vascular_Access = data.VascularAccess;
            record.Dialysis_No = data.DialysisNo;
            record.Machine_No = data.MachineNo;
            record.Dialyzer = data.Dialyzer;
            
            // Convert string to int?
            if (!string.IsNullOrEmpty(data.AdvisedBy))
            {
                if (int.TryParse(data.AdvisedBy, out int advisedById))
                    record.Advised_By_ID = advisedById;
            }
            
            if (!string.IsNullOrEmpty(data.PrimingBy))
            {
                if (int.TryParse(data.PrimingBy, out int primingById))
                    record.Priming_By_ID = primingById;
            }
            
            record.Priming_Solution = data.PrimingSol;
            record.Heparin = data.Heparin;
            record.Heparin_Infusion_Per_Hour = data.HeparinInfusion;
            
            // Convert string to decimal?
            if (!string.IsNullOrEmpty(data.CurrentWeight))
            {
                if (decimal.TryParse(data.CurrentWeight, out decimal currentWeight))
                    record.Current_Weight = currentWeight;
            }
            
            if (!string.IsNullOrEmpty(data.LastWeight))
            {
                if (decimal.TryParse(data.LastWeight, out decimal lastWeight))
                    record.Last_Weight = lastWeight;
            }
            
            // Convert string to TimeSpan?
            if (!string.IsNullOrEmpty(data.StartTime))
            {
                if (TimeSpan.TryParse(data.StartTime, out TimeSpan startTime))
                    record.Start_Time = startTime;
            }
            
            if (!string.IsNullOrEmpty(data.FinishTime))
            {
                if (TimeSpan.TryParse(data.FinishTime, out TimeSpan finishTime))
                    record.Finish_Time = finishTime;
            }
            
            if (!string.IsNullOrEmpty(data.WeightDiff))
            {
                if (decimal.TryParse(data.WeightDiff, out decimal weightDiff))
                    record.Weight_Difference = weightDiff;
            }
            
            if (!string.IsNullOrEmpty(data.UF))
            {
                if (decimal.TryParse(data.UF, out decimal uf))
                    record.UF_ML = uf;
            }
            
            if (!string.IsNullOrEmpty(data.UFRate))
            {
                if (decimal.TryParse(data.UFRate, out decimal ufRate))
                    record.UF_Rate = ufRate;
            }
            
            record.Total_Duration = data.TotalDuration;
            record.Dialysis_Type = data.DialysisType;
            record.Special_Instruction = data.SpecialInstruction;
            record.Complaints = data.Complaints;
            record.Conscious_Level = data.ConsciousLevel;
            record.Edema = data.Edema;
            record.Card_Rhythm = data.CardRhythm;
            record.Lungs = data.Lungs;
            record.Other = data.Other;
            record.Remarks = data.Remarks;
        }

        [WebMethod]
        public static string SaveDuringDialysis(string DialysisId, string PatientId, string VitalSigns)
        {
            try
            {
                var vitals = JsonConvert.DeserializeObject<List<VitalSign>>(VitalSigns);

                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var existingVitals = db.Dialysis_DuringDialysis
                                           .Where(d => d.Dialysis_ID == DialysisId)
                                           .ToList();
                    
                    if (existingVitals.Any())
                    {
                        db.Dialysis_DuringDialysis.DeleteAllOnSubmit(existingVitals);
                    }
                    
                    var newVitals = vitals.Select(v => {
                        var vital = new Dialysis_DuringDialysi
                        {
                            Dialysis_ID = DialysisId,
                            Patient_ID = int.Parse(PatientId),
                            Vital_Time = string.IsNullOrEmpty(v.Time) ? (TimeSpan?)null : TimeSpan.Parse(v.Time),
                            Created_Date = DateTime.Now,
                            Created_By = HttpContext.Current.Session["UserID"]?.ToString()
                        };
                        
                        // Convert string to decimal?
                        if (!string.IsNullOrEmpty(v.Temperature))
                        {
                            if (decimal.TryParse(v.Temperature, out decimal temp))
                                vital.Temperature = temp;
                        }
                        
                        if (!string.IsNullOrEmpty(v.BPSys))
                        {
                            if (int.TryParse(v.BPSys, out int bpSys))
                                vital.BP_Systolic = bpSys;
                        }
                        
                        if (!string.IsNullOrEmpty(v.BPDias))
                        {
                            if (int.TryParse(v.BPDias, out int bpDias))
                                vital.BP_Diastolic = bpDias;
                        }
                        
                        if (!string.IsNullOrEmpty(v.Pulse))
                        {
                            if (int.TryParse(v.Pulse, out int pulse))
                                vital.Pulse = pulse;
                        }
                        
                        if (!string.IsNullOrEmpty(v.DialysisFlowRate))
                        {
                            if (decimal.TryParse(v.DialysisFlowRate, out decimal flowRate))
                                vital.Dialysis_Flow_Rate = flowRate;
                        }
                        
                        if (!string.IsNullOrEmpty(v.VenousPressure))
                        {
                            if (decimal.TryParse(v.VenousPressure, out decimal venousPressure))
                                vital.Venous_Pressure = (int)venousPressure;
                        }
                        
                        if (!string.IsNullOrEmpty(v.BloodFlow))
                        {
                            if (decimal.TryParse(v.BloodFlow, out decimal bloodFlow))
                                vital.Blood_Flow = bloodFlow;
                        }
                        
                        return vital;
                    }).ToList();
                    
                    db.Dialysis_DuringDialysis.InsertAllOnSubmit(newVitals);
                    db.SubmitChanges();
                }

                return "success";
            }
            catch (Exception ex)
            {
                return "error: " + ex.Message;
            }
        }

        [WebMethod]
        public static string SavePostDialysis(string data)
        {
            try
            {
                var postDialysisData = JsonConvert.DeserializeObject<PostDialysisData>(data);

                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var existingRecord = db.Dialysis_PostDialysis
                                           .FirstOrDefault(d => d.Dialysis_ID == postDialysisData.DialysisId);
                    
                    if (existingRecord != null)
                    {
                        UpdatePostDialysisRecord(existingRecord, postDialysisData);
                        existingRecord.Modified_Date = DateTime.Now;
                        existingRecord.Modified_By = HttpContext.Current.Session["UserID"]?.ToString();
                        db.SubmitChanges();
                    }
                    else
                    {
                        var newRecord = new Dialysis_PostDialysi();
                        UpdatePostDialysisRecord(newRecord, postDialysisData);
                        newRecord.Dialysis_ID = postDialysisData.DialysisId;
                        newRecord.Created_Date = DateTime.Now;
                        newRecord.Created_By = HttpContext.Current.Session["UserID"]?.ToString();
                        
                        db.Dialysis_PostDialysis.InsertOnSubmit(newRecord);
                        db.SubmitChanges();
                    }
                }

                return "success";
            }
            catch (Exception ex)
            {
                return "error: " + ex.Message;
            }
        }

        private static void UpdatePostDialysisRecord(Dialysis_PostDialysi record, PostDialysisData data)
        {
            if (!string.IsNullOrEmpty(data.PatientId))
                record.Patient_ID = int.Parse(data.PatientId);
            
            // Convert string to TimeSpan?
            if (!string.IsNullOrEmpty(data.StartTime))
            {
                if (TimeSpan.TryParse(data.StartTime, out TimeSpan startTime))
                    record.Start_Time = startTime;
            }
            
            if (!string.IsNullOrEmpty(data.EndTime))
            {
                if (TimeSpan.TryParse(data.EndTime, out TimeSpan endTime))
                    record.End_Time = endTime;
            }
            
            record.Duration = data.Duration;
            
            // Convert string to int?
            if (!string.IsNullOrEmpty(data.StaffId))
            {
                if (int.TryParse(data.StaffId, out int staffId))
                    record.Staff_ID = staffId;
            }
            
            // Convert string to decimal?
            if (!string.IsNullOrEmpty(data.Weight))
            {
                if (decimal.TryParse(data.Weight, out decimal weight))
                    record.Weight = weight;
            }
            
            if (!string.IsNullOrEmpty(data.Temperature))
            {
                if (decimal.TryParse(data.Temperature, out decimal temp))
                    record.Temperature = temp;
            }
            
            if (!string.IsNullOrEmpty(data.BPSys))
            {
                if (int.TryParse(data.BPSys, out int bpSys))
                    record.BP_Systolic = bpSys;
            }
            
            if (!string.IsNullOrEmpty(data.BPDias))
            {
                if (int.TryParse(data.BPDias, out int bpDias))
                    record.BP_Diastolic = bpDias;
            }
            
            if (!string.IsNullOrEmpty(data.Pulse))
            {
                if (int.TryParse(data.Pulse, out int pulse))
                    record.Pulse = pulse;
            }
            
            record.Comments = data.Comments;
        }
        [WebMethod]
        public static string SaveNewPatient(string patientData)
        {
            try
            {
                var data = JsonConvert.DeserializeObject<PatientRegistrationData>(patientData);

                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    // Generate MR No
                    var mrNo = GenerateMRNo(db);

                    // Create new patient record
                    var newPatient = new Reg_patient
                    {
                        mr_no_sequence = mrNo,
                        Full_Name = data.Title + " " + data.Name,
                        Father_Name = data.RelationName,
                        Age_years = data.Age,
                        Gender = data.Gender,
                        NIC = data.CNIC,
                        Mobile1 = data.Mobile,
                        Martial_Status = data.MaritalStatus,
                        Country = data.Country ?? "",
                        Province = data.Province ?? "",
                        city = data.City ?? "",
                        area = data.Area ?? "",
                        Permanent_Address = data.Address ?? "",
                        Created_time = DateTime.Now,
                        Created_by = (Guid?)HttpContext.Current.Session["UserID"]
                    };

                    db.Reg_patients.InsertOnSubmit(newPatient);
                    db.SubmitChanges();

                    return JsonConvert.SerializeObject(new
                    {
                        success = true,
                        patientId = newPatient.pat_id,
                        mrNo = mrNo,
                        patientName = newPatient.Full_Name,
                        age = data.Age,
                        gender = data.Gender,
                        mobile = data.Mobile
                    });
                }
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message
                });
            }
        }

        [WebMethod]
        public static string Getmr()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            Reg_patient pat = null;
            int? maxPatNo = db.Reg_patients.Max(p => (int?)p.Patient_No);
            int newPatNo = (maxPatNo.HasValue ? maxPatNo.Value : 0) + 1;
            return newPatNo.ToString();
        }

        [WebMethod]
        public static string SavePatientDetail(
            string Full_Name, string RelationType, string Relation, string Gender,
            string Mobile, string Date_Of_Birth, string CNIC, string Address,
            string PatientID, string martail_status, string Age,
            string stno, string city, string area,
            string city_val, string area_val, string Province, string Country, string cardfee)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            Reg_patient pat = null;
            if (!string.IsNullOrEmpty(PatientID) && PatientID != "0" && PatientID != "(New)") {
                pat = db.Reg_patients.FirstOrDefault(w => w.pat_id == Convert.ToInt32(PatientID));
                if (pat != null)
                {
                    pat.Relation_prefix = RelationType;
                    pat.Full_Name = Full_Name;
                    pat.Father_Name = Relation;
                    pat.Gender = Gender;
                    pat.Mobile1 = Mobile;
                    pat.Age_years = Age;
                    if (Date_Of_Birth == "")
                    {
                        pat.DOB = null;
                    }
                    else
                    {
                        pat.DOB = Convert.ToDateTime(Date_Of_Birth);
                    }
                   
                    pat.NIC = CNIC;
                    pat.Permanent_Address = Address;
                    pat.Martial_Status = martail_status;
                   
                    pat.stno_mno = stno;
                    pat.city = city;
                    pat.area = area;
                    pat.val_city = city_val;
                    pat.val_area = area_val;
                    pat.Country = Country;
                    pat.Province = Province;
                    db.SubmitChanges();
                }
            }
            else
            {
                pat = new Reg_patient();
                string PatientNumber = DBClass.getMaxEntry_No("Reg_patient", "Patient_No").ToString();
                pat.Patient_No = Convert.ToInt32(PatientNumber);
                pat.Full_Name = Full_Name;
                pat.walkin = false;
                pat.Father_Name = Relation;
                pat.Relation_prefix = RelationType;
                pat.Gender = Gender;
                pat.Mobile1 = Mobile;
                pat.Age_years = Age;
                if (Date_Of_Birth == "")
                {
                    pat.DOB = null;
                }
                else
                {
                    pat.DOB = DateTime.ParseExact(Date_Of_Birth, "dd/MM/yyyy", System.Globalization.CultureInfo.InvariantCulture);
                }
                   
                pat.NIC = CNIC;
                pat.Permanent_Address = Address;
              
                pat.stno_mno = stno;
                pat.city = city;
                pat.area = area;
                pat.val_city = city_val;
                pat.val_area = area_val;
                pat.Created_time = DateTime.Now;
                pat.Created_by = (Guid?)HttpContext.Current.Session["UserID"];
                pat.iscancel = false;
                pat.Martial_Status = martail_status;
                pat.Country = Country;
                pat.Province = Province;

                var company = db.sys_Companies.FirstOrDefault(c => c.Company_ID == AppConfig.Company_ID);
                string companyCode = company?.CompanyCode ?? "HOSP";
                pat.mr_no_sequence = string.IsNullOrWhiteSpace(companyCode) ? PatientNumber : $"{companyCode}-{PatientNumber}";
                pat.Card_fee = Convert.ToDecimal(cardfee);

                db.Reg_patients.InsertOnSubmit(pat);
                db.SubmitChanges();
            }
            return pat?.pat_id.ToString() ?? "0";

        }

        private static string GenerateMRNo(DataBaseDataContext db)
        {
            var lastMRNo = db.Reg_patients
                .OrderByDescending(p => p.pat_id)
                .Select(p => p.mr_no_sequence)
                .FirstOrDefault();

            if (string.IsNullOrEmpty(lastMRNo))
                return "MR-0001";

            var numPart = int.Parse(lastMRNo.Replace("MR-", ""));
            return $"MR-{(numPart + 1).ToString("D4")}";
        }

        public class PatientRegistrationData
        {
            public string Title { get; set; }
            public string Name { get; set; }
            public string Relation { get; set; }
            public string RelationName { get; set; }
            public string AgePrefix { get; set; }
            public string DOB { get; set; }
            public string Age { get; set; }
            public string Gender { get; set; }
            public string CNIC { get; set; }
            public string Mobile { get; set; }
            public string MaritalStatus { get; set; }
            public string Country { get; set; }
            public string Province { get; set; }
            public string City { get; set; }
            public string Area { get; set; }
            public string Address { get; set; }
        }
        public class PreDialysisData
        {
            public string DialysisId { get; set; }
            public string PatientId { get; set; }
            public string VascularAccess { get; set; }
            public string DialysisNo { get; set; }
            public string MachineNo { get; set; }
            public string Dialyzer { get; set; }
            public string AdvisedBy { get; set; }
            public string PrimingBy { get; set; }
            public string PrimingSol { get; set; }
            public string Heparin { get; set; }
            public string HeparinInfusion { get; set; }
            public string CurrentWeight { get; set; }
            public string LastWeight { get; set; }
            public string StartTime { get; set; }
            public string FinishTime { get; set; }
            public string WeightDiff { get; set; }
            public string UF { get; set; }
            public string UFRate { get; set; }
            public string TotalDuration { get; set; }
            public string DialysisType { get; set; }
            public string SpecialInstruction { get; set; }
            public string Complaints { get; set; }
            public string ConsciousLevel { get; set; }
            public string Edema { get; set; }
            public string CardRhythm { get; set; }
            public string Lungs { get; set; }
            public string Other { get; set; }
            public string Remarks { get; set; }
        }

        public class PostDialysisData
        {
            public string DialysisId { get; set; }
            public string PatientId { get; set; }
            public string StartTime { get; set; }
            public string EndTime { get; set; }
            public string Duration { get; set; }
            public string StaffId { get; set; }
            public string Weight { get; set; }
            public string Temperature { get; set; }
            public string BPSys { get; set; }
            public string BPDias { get; set; }
            public string Pulse { get; set; }
            public string Comments { get; set; }
        }

        public class VitalSign
        {
            public string Time { get; set; }
            public string Temperature { get; set; }
            public string BPSys { get; set; }
            public string BPDias { get; set; }
            public string Pulse { get; set; }
            public string DialysisFlowRate { get; set; }
            public string VenousPressure { get; set; }
            public string BloodFlow { get; set; }
        }
    }
}