using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Dashboards
{
    public partial class EMR : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

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
                             doctor = (from emp in db.HR_Employees where emp.Emp_ID == Convert.ToInt32(app.Consultant_ID) select new {emp.Emp_Name} ).FirstOrDefault()

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
        public static string CountVisits(int reg_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            int OPD = db.Out_Patients.Where(t => t.Reg_PatId == reg_id).Count();

       
            int IPD = db.In_Patients.Where(t => t.Patient_ID == reg_id).Count();

       
            int Emergency = db.Emergency_Patients.Where(t => t.Patient_ID == reg_id).Count();

            var result = new
            {
                OutPatientCount = OPD,
                InPatientCount = IPD,
                EmergencyCaseCount = Emergency
            };

            return (new JavaScriptSerializer()).Serialize(result);
        }
        [WebMethod]
        public static string GetDepartmentCount(int patid,string category)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_loadPatientsDepartmentWiseOPD(patid,category);
            return (new JavaScriptSerializer()).Serialize(Details);
        }   
        [WebMethod]
        public static string GetDepartmentCountIPD(int patid,string category)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_loadPatientsDepartmentWiseOPD(patid,category);
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string ModePresentation()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Mode Of Registration"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        [WebMethod]
        public static string LoadVitalParametersHistory(int patid)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var outpatientlist = (from op in db.Out_Patients
                                  where op.Reg_PatId == patid

                                  select new
                                  {
                                      op.Out_Patient_ID,
                                      op.pulse_Min,
                                      op.BP_mm_Hg,
                                      op.Weight_Kg,
                                      op.Height_Cm,
                                      op.Respiration_Min,
                                      op.Temp_C,
                                      op.L_M_P,
                                      op.spo2,
                                      op.BSR,
                                      op.EDD,
                                      op.BMI,
                                      op.MUAC,
                                      op.OFC,
                                  
                                      op.Created_Time
                                  }).ToList();
            List<VitalParameterClass> list = new List<VitalParameterClass>();
            foreach (var item in outpatientlist)
            {
                VitalParameterClass obj = new VitalParameterClass();
                obj.Pulse_Min = item.pulse_Min;
                obj.Out_Patient_ID = item.Out_Patient_ID;
                obj.BP_mm_Hg = item.BP_mm_Hg;
                obj.Weight_Kg = item.Weight_Kg;
                obj.Height_Cm = item.Height_Cm;
                obj.Respiration_Min = item.Respiration_Min;
                obj.Temp_C = item.Temp_C;
                obj.L_M_P = item.L_M_P;
                obj.SPO2 = item.spo2;
                obj.BMI = item.BMI;
                obj.MUAC = item.MUAC;
                obj.OFC = item.OFC;
                obj.Receiving_date = DateTime.Now;
                obj.RN_Special_Instruction = "";
                obj.RN_Patient_General_Condition = "";
                obj.Created_Time = Convert.ToDateTime(item.Created_Time);
                obj.BSR = (item.BSR != null) ? item.BSR : "";
                obj.EDD = (item.EDD != null) ? item.EDD : "";
                obj.BMI = (item.BMI != null) ? item.BMI : "";
                obj.Status = "OutPatient";

                list.Add(obj);
            }
            return (new JavaScriptSerializer()).Serialize(list);
        }
        [WebMethod]
        public static string LoadVitalParametersHistoryemergency(int patid)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
          

            var EmergencyPatientList = (from op in db.ReceivingNotes
                                        join p in db.Reg_patients
                                       on op.Patient_ID equals p.pat_id
                                        where p.pat_id == patid
                                           && op.Type_Nursing == "Receiving Note Emergency"
                                        select new
                                        {
                                            op.RateBeats,
                                            op.BloodPressure,
                                            op.Emergency_Rhythm,
                                            op.Emergency_Volume,
                                            op.OthersRecieveNote,
                                            op.RespirationRate,
                                            op.Temperature,
                                            op.Receiving_Date,
                                            op.RN_Special_Instruction,
                                            op.O2_Saturation,
                                            op.O2_Saturation_Oxygen1,
                                            op.O2_Saturation_Oxygen2,
                                            user = db.aspnet_Users.Where(x => x.UserId == op.user_id).Select(x => x.UserName).FirstOrDefault(),
                                        }).ToList();


            List<VitalParameterClassEmer> list = new List<VitalParameterClassEmer>();
            foreach (var item in EmergencyPatientList)
            {
                VitalParameterClassEmer obj = new VitalParameterClassEmer();
                obj.Rhythm = db.GetDataValueName("Emergency Rhythm", item.Emergency_Rhythm);
                obj.Volume = db.GetDataValueName("Emergency Volume", item.Emergency_Volume);
                obj.BP_mm_Hg = item.BloodPressure;
                obj.Rate_Beats = item.RateBeats;
                obj.OthersRcvNote = item.OthersRecieveNote;
                obj.O2_Saturation = item.O2_Saturation;
                obj.O2_Saturation_Oxygen1 = item.O2_Saturation_Oxygen1;
                obj.O2_Saturation_Oxygen2 = item.O2_Saturation_Oxygen2;
                obj.Respiration_Min = item.RespirationRate;
                obj.Temp_C = item.Temperature;
                obj.Receiving_date = Convert.ToDateTime(item.Receiving_Date);
                obj.RN_Special_Instruction = item.RN_Special_Instruction;
                obj.Status = "Emergency Patient";
                obj.user = item.user;
                list.Add(obj);
            }
            return (new JavaScriptSerializer()).Serialize(list);
        }
        public class VitalParameterClass
        {
            public int Out_Patient_ID;
            public string Pulse_Min;
            public string BP_mm_Hg;
            public string Weight_Kg;
            public string Height_Cm;
            public DateTime Created_Time;
            public string Respiration_Min;
            public string Temp_C;
            public string L_M_P;
            public string SPO2;
            public string Test_ID;
            public DateTime Receiving_date;
            public string RN_Special_Instruction;
            public string RN_Patient_General_Condition;
            public string Status;
            public string EDD { get; set; }
            public string BSR { get; set; }
            public string BMI { get; set; }
            public string MUAC { get; set; }
            public string OFC { get; set; }



        }
        [WebMethod]
        public static string GetTotalVisits(int patid)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_Dashboard_GetTotalVisits_OPD(patid);
            return (new JavaScriptSerializer()).Serialize(Details);
        }
       
        [WebMethod]
        public static string GetTotalVisitsIPD(int patid)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_Dashboard_GetTotalVisits_IPD(patid);
            return (new JavaScriptSerializer()).Serialize(Details);
        }    
        [WebMethod]
        public static string GetTotalVisitsEmergency(int patid)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_Dashboard_GetTotalVisits_Emergency(patid);
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string GetTestListForHistory(int patid)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var OutPatienttestilst = (
                from lbtM in db.Laboratory_Tests
                join lbtD in db.Lab_Test_Details on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                join abd in db.Ar_Billing_Details on lbtD.BillDetailID equals abd.Bill_Details_ID
                join rp in db.Reg_patients on lbtD.Actual_Patient_ID equals rp.pat_id
                where rp.pat_id == patid && abd.ParentTrans_Name == "OutPatient" && lbtD.IsBilled == true

                select new
                {
              //outpat.Out_Patient_ID,
              lbtD.Lab_Test_Detail_ID,
                    lbtD.Date,
                    lbtD.Remark,
                    lbtD.Catagory_ID,
                    lbtM.Lab_Test_ID,
                    lbtD.Test_ID,
                    lbtD.Dept_ID,
                    lbtD.L_R_Rotation_ID,
                    Value_Type = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Value_Type).FirstOrDefault(),
                    Value_TypeGroup = (from t in db.Lab_Tests where t.Group_Category == lbtD.Catagory_ID select t.Value_Type).FirstOrDefault(),
                    Test_Name = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Test_Name).FirstOrDefault(),
                    Group_Department = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Group_Department).FirstOrDefault(),
                    Group_Category = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Group_Category).FirstOrDefault(),
                    DepartmentName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test Departments", t.Main_Department)).FirstOrDefault(),
                    Department_ID = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Main_Department).FirstOrDefault(),
                    GroupName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Test Groups", t.Group_Category)).FirstOrDefault(),
                    Group_Name = db.GetDataValueName("Test Groups", lbtD.Catagory_ID),
                    lbtD.Rotation_ID,
                    Rotation = ((from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test Departments", t.Main_Department)).FirstOrDefault()) == "X-Ray"
                        ? db.GetDataValueName("Test XRay Rotations", lbtD.Rotation_ID)
                        : db.GetDataValueName("Test CT Scan Rotations", lbtD.Rotation_ID),
                    DataValue_Description = (from dv in db.DataValues
                                             join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                             where vs.ValueSet_Name == "Test XRay Rotations" && dv.DataValue_Name == lbtD.Rotation_ID
                                             select dv.DataValue_Description).FirstOrDefault(),
                   // DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(outpat.Doctor_ID) select d.Emp_Name).FirstOrDefault(),
                    lbtD.Special_Tests,
                    lbtD.Area_Of_Interest,
                    lbtD.Doctor,
                    lbtD.Recieved_ID,
                    lbtD.Is_Result,
                    Patient_Id = rp.pat_id,
                    lbtD.isApproved,
                    lbtD.BillDetailID,
                    Report_Colum = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Report_Colum).FirstOrDefault(),
                    //outpat.Doctor_ID
                }
            ).ToList();

            List<LabTestClass> list = new List<LabTestClass>();

            foreach (var item in OutPatienttestilst)
            {
                LabTestClass obj = new LabTestClass
                {
                    Lab_Test_Detail_ID = item.Lab_Test_Detail_ID.ToString(),
                    Date = Convert.ToDateTime(item.Date),
                    Remark = item.Remark,
                    Catagory_ID = item.Catagory_ID,
                    Lab_Test_ID = item.Lab_Test_ID.ToString(),
                    Test_ID = item.Test_ID,
                    Dept_ID = item.Dept_ID,
                    L_R_Rotation_ID = item.L_R_Rotation_ID,
                    //In_Patient_ID = item.Out_Patient_ID,
                    Value_Type = item.Value_Type,
                    Value_TypeGroup = item.Value_TypeGroup,
                    Test_Name = item.Test_Name,
                    Group_Department = item.Group_Department,
                    Group_Category = item.Group_Category,
                    DepartmentName = item.DepartmentName,
                    Department_ID = item.Department_ID,
                    GroupName = item.GroupName,
                    Group_Name = item.Group_Name,
                    Rotation_ID = item.Rotation_ID,
                    Rotation = item.Rotation,
                    DataValue_Description = item.DataValue_Description,
                    Special_Tests = item.Special_Tests,
                    Area_Of_Interest = item.Area_Of_Interest,
                    Doctor = item.Doctor,
                    Recieved_ID = item.Recieved_ID,
                    Is_Result = item.Is_Result ?? false,
                    Report_Column = item.Report_Colum,
                    isApproved = item.isApproved ?? false,
                    Patient_ID = Convert.ToString(item.Patient_Id),
                    Bill_Details_ID = item.BillDetailID.ToString(),
                    //DoctorName = item.DoctorName,
                    Status = "OutPatient"
                };
                list.Add(obj);
            }

            return (new JavaScriptSerializer()).Serialize(list);
        }
        [WebMethod]
        public static string GetTestListForHistoryIPD(int patid)
       {
                DataBaseDataContext db = new DataBaseDataContext();

            var InPatienttestilst = (from lbtM in db.Laboratory_Tests
                join lbtD in db.Lab_Test_Details
                on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                     join abd in db.Ar_Billing_Details on lbtD.BillDetailID equals abd.Bill_Details_ID
                                     join p in db.Reg_patients on lbtD.Actual_Patient_ID equals p.pat_id
                                     where p.pat_id == patid && abd.ParentTrans_Name  == "InPatient" && lbtD.IsBilled == true
                orderby lbtD.Date descending
                select new
                {
                    //outpat.In_Patient_ID,
                    lbtD.Lab_Test_Detail_ID,
                    lbtD.Date,
                    lbtD.Remark,
                    lbtD.Catagory_ID,
                    lbtM.Lab_Test_ID,
                    lbtD.Test_ID,
                    lbtD.Dept_ID,
                    lbtD.L_R_Rotation_ID,
                    Value_Type = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Value_Type).FirstOrDefault(),
                    Value_TypeGroup = (from t in db.Lab_Tests where t.Group_Category == lbtD.Catagory_ID select t.Value_Type).FirstOrDefault(),
                    Test_Name = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Test_Name).FirstOrDefault(),
                    Group_Department = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Group_Department).FirstOrDefault(),
                    Group_Category = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Group_Category).FirstOrDefault(),
                    DepartmentName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test Departments", t.Main_Department)).FirstOrDefault(),
                    Department_ID = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Main_Department).FirstOrDefault(),
                    GroupName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Test Groups", t.Group_Category)).FirstOrDefault(),
                    Group_Name = db.GetDataValueName("Test Groups", lbtD.Catagory_ID),
                    lbtD.Rotation_ID,
                    Rotation = ((from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test Departments", t.Main_Department)).FirstOrDefault()) == "X-Ray" ? db.GetDataValueName("Test XRay Rotations", lbtD.Rotation_ID) : db.GetDataValueName("Test CT Scan Rotations", lbtD.Rotation_ID),
                    DataValue_Description = (from dv in db.DataValues
                                             join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                             where vs.ValueSet_Name == ("Test XRay Rotations").ToString() && dv.DataValue_Name == lbtD.Rotation_ID
                                             select dv.DataValue_Description).FirstOrDefault(),
                    lbtD.Special_Tests,
                    lbtD.Area_Of_Interest,
                    lbtD.Doctor,
                    lbtD.Recieved_ID,
                    lbtD.Is_Result,
                    Patient_Id = p.pat_id,
                    lbtD.isApproved,
                    lbtD.BillDetailID,
                    Report_Colum = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Report_Colum).FirstOrDefault(),
                    DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(lbtD.Doctor) select d.Emp_Name).FirstOrDefault(),
                }
                ).ToList();

            List<LabTestClass> list = new List<LabTestClass>();

            foreach (var item in InPatienttestilst)
            {
                LabTestClass obj = new LabTestClass
                {
                    Lab_Test_Detail_ID = item.Lab_Test_Detail_ID.ToString(),
                    Date = Convert.ToDateTime(item.Date),
                    Remark = item.Remark,
                    Catagory_ID = item.Catagory_ID,
                    Lab_Test_ID = item.Lab_Test_ID.ToString(),
                    Test_ID = item.Test_ID,
                    Dept_ID = item.Dept_ID,
                    L_R_Rotation_ID = item.L_R_Rotation_ID,
                  //  In_Patient_ID = item.In_Patient_ID,
                    Value_Type = item.Value_Type,
                    Value_TypeGroup = item.Value_TypeGroup,
                    Test_Name = item.Test_Name,
                    Group_Department = item.Group_Department,
                    Group_Category = item.Group_Category,
                    DepartmentName = item.DepartmentName,
                    Department_ID = item.Department_ID,
                    GroupName = item.GroupName,
                    Group_Name = item.Group_Name,
                    Rotation_ID = item.Rotation_ID,
                    Rotation = item.Rotation,
                    DataValue_Description = item.DataValue_Description,
                    Special_Tests = item.Special_Tests,
                    Area_Of_Interest = item.Area_Of_Interest,
                    Doctor = item.Doctor,
                    Recieved_ID = item.Recieved_ID,
                    Is_Result = item.Is_Result ?? false,
                    DoctorName = item.DoctorName,
                    Report_Column = item.Report_Colum,
                    isApproved = item.isApproved ?? false,
                    Patient_ID = Convert.ToString(item.Patient_Id),
                    Bill_Details_ID = item.BillDetailID.ToString(),
                    Status = "InPatient"
                };
                list.Add(obj);
            }

            return (new JavaScriptSerializer()).Serialize(list);
        }
        [WebMethod]
        public static string GetTestListForHistoryEmergency(int patid)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var InPatienttestilst = (from lbtM in db.Laboratory_Tests
                                     join lbtD in db.Lab_Test_Details
                                     on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                     join abd in db.Ar_Billing_Details on lbtD.BillDetailID equals abd.Bill_Details_ID
                                     join p in db.Reg_patients on lbtD.Actual_Patient_ID equals p.pat_id
                                     where p.pat_id == patid && abd.ParentTrans_Name == "EmergencyPatient"
                                     orderby lbtD.Date descending
                                     select new
                                     {
                                         //outpat.Emergency_ID,
                                         lbtD.Lab_Test_Detail_ID,
                                         lbtD.Date,
                                         lbtD.Remark,
                                         lbtD.Catagory_ID,
                                         lbtM.Lab_Test_ID,
                                         lbtD.Test_ID,
                                         lbtD.Dept_ID,
                                         lbtD.L_R_Rotation_ID,
                                         Value_Type = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Value_Type).FirstOrDefault(),
                                         Value_TypeGroup = (from t in db.Lab_Tests where t.Group_Category == lbtD.Catagory_ID select t.Value_Type).FirstOrDefault(),
                                         Test_Name = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Test_Name).FirstOrDefault(),
                                         Group_Department = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Group_Department).FirstOrDefault(),
                                         Group_Category = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Group_Category).FirstOrDefault(),
                                         DepartmentName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test Departments", t.Main_Department)).FirstOrDefault(),
                                         Department_ID = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Main_Department).FirstOrDefault(),
                                         GroupName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Test Groups", t.Group_Category)).FirstOrDefault(),
                                         Group_Name = db.GetDataValueName("Test Groups", lbtD.Catagory_ID),
                                         lbtD.Rotation_ID,
                                         Rotation = ((from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test Departments", t.Main_Department)).FirstOrDefault()) == "X-Ray" ? db.GetDataValueName("Test XRay Rotations", lbtD.Rotation_ID) : db.GetDataValueName("Test CT Scan Rotations", lbtD.Rotation_ID),
                                         DataValue_Description = (from dv in db.DataValues
                                                                  join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                                                  where vs.ValueSet_Name == ("Test XRay Rotations").ToString() && dv.DataValue_Name == lbtD.Rotation_ID
                                                                  select dv.DataValue_Description).FirstOrDefault(),
                                         lbtD.Special_Tests,
                                         lbtD.Area_Of_Interest,
                                         lbtD.Doctor,
                                         lbtD.Recieved_ID,
                                         lbtD.isApproved,
                                         lbtD.Is_Result,
                                         DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(lbtD.Doctor) select d.Emp_Name).FirstOrDefault(),
                                         Patient_Id = p.pat_id,
                                          lbtD.BillDetailID,
                                         Report_Colum= (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Report_Colum).FirstOrDefault(),
                                     }
                ).ToList();

            List<LabTestClass> list = new List<LabTestClass>();

            foreach (var item in InPatienttestilst)
            {
                LabTestClass obj = new LabTestClass
                {
                    Lab_Test_Detail_ID = item.Lab_Test_Detail_ID.ToString(),
                    Date = Convert.ToDateTime(item.Date),
                    Remark = item.Remark,
                    Catagory_ID = item.Catagory_ID,
                    Lab_Test_ID = item.Lab_Test_ID.ToString(),
                    Test_ID = item.Test_ID,
                    Dept_ID = item.Dept_ID,
                    L_R_Rotation_ID = item.L_R_Rotation_ID,
                   // In_Patient_ID = item.Emergency_ID,
                    Value_Type = item.Value_Type,
                    Value_TypeGroup = item.Value_TypeGroup,
                    Test_Name = item.Test_Name,
                    Group_Department = item.Group_Department,
                    Group_Category = item.Group_Category,
                    DepartmentName = item.DepartmentName,
                    Department_ID = item.Department_ID,
                    GroupName = item.GroupName,
                    Group_Name = item.Group_Name,
                    Rotation_ID = item.Rotation_ID,
                    Rotation = item.Rotation,
                    DataValue_Description = item.DataValue_Description,
                    Special_Tests = item.Special_Tests,
                    Area_Of_Interest = item.Area_Of_Interest,
                    Doctor = item.Doctor,
                    Recieved_ID = item.Recieved_ID,
                    Is_Result = item.Is_Result ?? false,
                    DoctorName = item.DoctorName,
                    Report_Column=item.Report_Colum,
                    Patient_ID = Convert.ToString(item.Patient_Id),
                    Bill_Details_ID = item.BillDetailID.ToString(),
                    isApproved = item.isApproved ?? false,
                    Status = "Emergency Patient",
                   
                };
                list.Add(obj);
            }

            return (new JavaScriptSerializer()).Serialize(list);
        }
        [WebMethod]
        public static string LoadVitalParametersHistoryIPD(int patid)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var IPD_PatientList = (from op in db.ReceivingNotes
                                   join p in db.Reg_patients
                                   on op.Patient_ID equals p.pat_id
                                   join inpat in db.In_Patients
                                   on p.pat_id equals inpat.Patient_ID
                                   where p.pat_id == patid
                                   && op.In_Patient_ID == inpat.In_Patient_ID
                                   && op.Emergency_ID == null
                                   orderby op.Receiving_Date descending
                                   select new
                                   {
                                       op.RateBeats,
                                       op.BloodPressure,
                                       op.Emergency_Rhythm,
                                       op.Emergency_Volume,
                                       op.OthersRecieveNote,
                                       op.RespirationRate,
                                       op.Temperature,
                                       op.Receiving_Date,
                                       op.RN_Special_Instruction,
                                       op.O2_Saturation,
                                       op.O2_Saturation_Oxygen1,
                                       op.O2_Saturation_Oxygen2,
                                       user = db.aspnet_Users.Where(x => x.UserId == op.user_id).Select(x => x.UserName).FirstOrDefault(),


                                   }).ToList();

         
            List<VitalParameter> list = new List<VitalParameter>();
        

            foreach (var item in IPD_PatientList)
            {
                VitalParameter obj = new VitalParameter();
                obj.Emergency_Rhythm = db.GetDataValueName("Emergency Rhythm", item.Emergency_Rhythm);
                obj.Emergency_Volume = db.GetDataValueName("Emergency Volume", item.Emergency_Volume);
                obj.BP_mm_Hg = item.BloodPressure;
                obj.RateBeats = item.RateBeats;
                obj.OthersRecieveNote = item.OthersRecieveNote;
                obj.O2_Saturation = item.O2_Saturation;
                obj.O2_Saturation_Oxygen1 = item.O2_Saturation_Oxygen1;
                obj.O2_Saturation_Oxygen2 = item.O2_Saturation_Oxygen2;
                obj.Respiration_Min = item.RespirationRate;
                obj.Temp_C = item.Temperature;
                obj.Receiving_date = Convert.ToDateTime(item.Receiving_Date);
                obj.RN_Special_Instruction = item.RN_Special_Instruction;
                obj.Status = "IPD Discharge Patient";
                obj.User_Name = item.user;

                list.Add(obj);
            }
            return (new JavaScriptSerializer()).Serialize(list);
        }

        public class VitalParameter
        {
            public string Pulse_Min { get; set; }
            public string BP_mm_Hg { get; set; }
            public string Weight_Kg { get; set; }
            public string Height_Cm { get; set; }
            public DateTime Created_Time { get; set; }
            public string Respiration_Min { get; set; }
            public string Temp_C { get; set; }
            public string L_M_P { get; set; }
            public string Test_ID { get; set; }
            public DateTime Receiving_date { get; set; }
            public string RN_Special_Instruction { get; set; }
            public string RN_Patient_General_Condition { get; set; }
            public string Status { get; set; }
            public string BMI { get; set; }
            public string GCS { get; set; }
            public string RateBeats { get; set; }
            public string Emergency_Rhythm { get; set; }
            public string Emergency_Volume { get; set; }
            public string OthersRecieveNote { get; set; }
            public string RespirationRate { get; set; }
            public string O2_Saturation { get; set; }
            public string O2_Saturation_Oxygen1 { get; set; }
            public string O2_Saturation_Oxygen2 { get; set; }
            public string User_Name { get; set; }
        }



        public class LabTestClass
        {
            public string chkPackages;
            public bool IsBilled;
            public string Lab_Test_Detail_ID;
            public string L_R_Rotation_ID;
            public DateTime Date;
            public string Remark;
            public string Catagory_ID;
            public string Lab_Test_ID;
            public int Test_ID;
            public string Dept_ID;
            public string Bill_Details_ID;
            public string Recieved_ID;
            public string Parent_Transaction_Type;
            public string Parent_Transaction_Type_ID;
            public string Transaction_Type;
            public string Doctor_ID;
            public int Patient_No;
            public string Patient_ID;
            public string Name;
            public string Out_Patient_ID;
            public string Special_Tests;
            public string Area_Of_Interest;
            public int In_Patient_ID;
            public string Value_Type;
            public string Value_TypeGroup;
            public string Test_Name;
            public string Group_Department;
            public string Group_Category;
            public string DepartmentName;
            public string Department_ID;
            public string GroupName;
            public string Group_Name;
            public string Rotation_ID;
            public string DoctorName;
            public string doctornames;
            public string DataValue_Description;
            public bool Is_Result;
            public bool isApproved;
            public string Rotation;
            public string Doctor;
            public string Status;
            public string Report_Column;
            public string ListOfTestIDs;
        }
        public class VitalParameterClassEmer
        {

            public string Pulse_Min;
            public string Rate_Beats;
            public string Weight_Kg;
            public string Height_Cm;
            public string Rhythm;
            public string Volume;
            public string OthersRcvNote;
            public string BP_mm_Hg;
            public string O2_Saturation;
            public string O2_Saturation_Oxygen1;
            public string O2_Saturation_Oxygen2;
            public DateTime Created_Time;
            public string Respiration_Min;
            public string Temp_C;
            public string L_M_P;
            public string Test_ID;
            public DateTime Receiving_date;
            public string RN_Special_Instruction;
            public string RN_Patient_General_Condition;
            public string Status;
            public string BMI;
            public string GCS;
            public string user;
        }

    }

}