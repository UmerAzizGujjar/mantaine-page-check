using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using Newtonsoft.Json;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
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
                string conStr = ConfigurationManager.ConnectionStrings["ASPGLConnectionString"].ConnectionString;
                string dialysisId = "";
                string today = DateTime.Now.ToString("yyyyMMdd");
                
                using (SqlConnection con = new SqlConnection(conStr))
                {
                    con.Open();
                    string query = "SELECT COUNT(*) FROM Dialysis_PreDialysis WHERE Dialysis_ID LIKE 'DLY-' + @today + '-%'";
                    
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@today", today);
                        int count = (int)cmd.ExecuteScalar();
                        int nextNumber = count + 1;
                        dialysisId = $"DLY-{today}-{nextNumber.ToString("D4")}";
                    }
                }

                return dialysisId;
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
                string conStr = ConfigurationManager.ConnectionStrings["ASPGLConnectionString"].ConnectionString;

                using (SqlConnection con = new SqlConnection(conStr))
                {
                    string preQuery = @"SELECT * FROM Dialysis_PreDialysis WHERE Dialysis_ID = @DialysisId";
                    using (SqlCommand cmd = new SqlCommand(preQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@DialysisId", dialysisId);
                        using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                        {
                            DataTable preDt = new DataTable();
                            sda.Fill(preDt);
                            
                            string duringQuery = @"SELECT * FROM Dialysis_DuringDialysis WHERE Dialysis_ID = @DialysisId ORDER BY Vital_Time";
                            cmd.CommandText = duringQuery;
                            DataTable duringDt = new DataTable();
                            using (SqlDataAdapter sda2 = new SqlDataAdapter(cmd))
                            {
                                sda2.Fill(duringDt);
                            }

                            string postQuery = @"SELECT * FROM Dialysis_PostDialysis WHERE Dialysis_ID = @DialysisId";
                            cmd.CommandText = postQuery;
                            DataTable postDt = new DataTable();
                            using (SqlDataAdapter sda3 = new SqlDataAdapter(cmd))
                            {
                                sda3.Fill(postDt);
                            }

                            return JsonConvert.SerializeObject(new
                            {
                                PreDialysis = preDt,
                                DuringDialysis = duringDt,
                                PostDialysis = postDt
                            });
                        }
                    }
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
                string conStr = ConfigurationManager.ConnectionStrings["ASPGLConnectionString"].ConnectionString;
                DataTable dt = new DataTable();

                using (SqlConnection con = new SqlConnection(conStr))
                {
                    using (SqlCommand cmd = new SqlCommand("SELECT TOP 50 pat_id AS PatientId, mr_no_sequence AS MRNo, Full_Name AS PatientName, Father_Name AS FatherName, NIC, Mobile1 AS ContactNo, ISNULL(Age_Years, '') AS Age, ISNULL(Gender, '') AS Gender FROM Reg_patient ORDER BY pat_id DESC", con))
                    {
                        using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                        {
                            sda.Fill(dt);
                        }
                    }
                }

                return JsonConvert.SerializeObject(dt);
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
                string conStr = ConfigurationManager.ConnectionStrings["ASPGLConnectionString"].ConnectionString;
                DataTable dt = new DataTable();

                using (SqlConnection con = new SqlConnection(conStr))
                {
                    string query = @"SELECT TOP 50 
                    pat_id AS PatientId, 
                    mr_no_sequence AS MRNo, 
                    Full_Name AS PatientName, 
                    Father_Name AS FatherName, 
                    NIC, 
                    Mobile1 AS ContactNo, 
                    ISNULL(Age_Years, '') AS Age, 
                    ISNULL(Gender, '') AS Gender 
                 FROM Reg_patient 
                 WHERE Full_Name LIKE @searchText 
                    OR mr_no_sequence LIKE @searchText 
                    OR Father_Name LIKE @searchText 
                    OR NIC LIKE @searchText 
                    OR Mobile1 LIKE @searchText 
                 ORDER BY pat_id DESC";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@searchText", "%" + searchText + "%");
                        using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                        {
                            sda.Fill(dt);
                        }
                    }
                }

                return JsonConvert.SerializeObject(dt);
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
        public static string SavePreDialysis(string data)
        {
            try
            {
                var preDialysisData = JsonConvert.DeserializeObject<PreDialysisData>(data);
                string conStr = ConfigurationManager.ConnectionStrings["ASPGLConnectionString"].ConnectionString;
                
                using (SqlConnection con = new SqlConnection(conStr))
                {
                    con.Open();
                    
                    if (!string.IsNullOrEmpty(preDialysisData.DialysisId))
                    {
                        string checkQuery = "SELECT COUNT(*) FROM Dialysis_PreDialysis WHERE Dialysis_ID = @DialysisId";
                        using (SqlCommand checkCmd = new SqlCommand(checkQuery, con))
                        {
                            checkCmd.Parameters.AddWithValue("@DialysisId", preDialysisData.DialysisId);
                            int exists = (int)checkCmd.ExecuteScalar();
                            
                            if (exists > 0)
                            {
                                string updateQuery = @"UPDATE Dialysis_PreDialysis SET 
                                    Patient_ID = @PatientId, 
                                    Vascular_Access = @VascularAccess, 
                                    Dialysis_No = @DialysisNo, 
                                    Machine_No = @MachineNo, 
                                    Dialyzer = @Dialyzer, 
                                    Advised_By_ID = @AdvisedBy, 
                                    Priming_By_ID = @PrimingBy, 
                                    Priming_Solution = @PrimingSol, 
                                    Heparin = @Heparin, 
                                    Heparin_Infusion_Per_Hour = @HeparinInfusion,
                                    Current_Weight = @CurrentWeight, 
                                    Last_Weight = @LastWeight, 
                                    Start_Time = @StartTime, 
                                    Finish_Time = @FinishTime, 
                                    Weight_Difference = @WeightDiff, 
                                    UF_ML = @UF, 
                                    UF_Rate = @UFRate, 
                                    Total_Duration = @TotalDuration, 
                                    Dialysis_Type = @DialysisType, 
                                    Special_Instruction = @SpecialInstruction,
                                    Complaints = @Complaints, 
                                    Conscious_Level = @ConsciousLevel, 
                                    Edema = @Edema, 
                                    Card_Rhythm = @CardRhythm, 
                                    Lungs = @Lungs, 
                                    Other = @Other, 
                                    Remarks = @Remarks,
                                    Modified_Date = GETDATE(), 
                                    Modified_By = @UserId
                                    WHERE Dialysis_ID = @DialysisId";

                                using (SqlCommand cmd = new SqlCommand(updateQuery, con))
                                {
                                    AddPreDialysisParameters(cmd, preDialysisData);
                                    cmd.ExecuteNonQuery();
                                }
                                
                                return preDialysisData.DialysisId;
                            }
                        }
                    }
                    
                    string query = @"INSERT INTO Dialysis_PreDialysis 
                                    (Dialysis_ID, Patient_ID, Vascular_Access, Dialysis_No, Machine_No, Dialyzer, 
                                     Advised_By_ID, Priming_By_ID, Priming_Solution, Heparin, Heparin_Infusion_Per_Hour,
                                     Current_Weight, Last_Weight, Start_Time, Finish_Time, Weight_Difference, 
                                     UF_ML, UF_Rate, Total_Duration, Dialysis_Type, Special_Instruction,
                                     Complaints, Conscious_Level, Edema, Card_Rhythm, Lungs, Other, Remarks, 
                                     Created_Date, Created_By)
                                    VALUES 
                                    (@DialysisId, @PatientId, @VascularAccess, @DialysisNo, @MachineNo, @Dialyzer, 
                                     @AdvisedBy, @PrimingBy, @PrimingSol, @Heparin, @HeparinInfusion,
                                     @CurrentWeight, @LastWeight, @StartTime, @FinishTime, @WeightDiff, 
                                     @UF, @UFRate, @TotalDuration, @DialysisType, @SpecialInstruction,
                                     @Complaints, @ConsciousLevel, @Edema, @CardRhythm, @Lungs, @Other, @Remarks,
                                     GETDATE(), @UserId)";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        AddPreDialysisParameters(cmd, preDialysisData);
                        cmd.ExecuteNonQuery();
                    }
                }

                return preDialysisData.DialysisId;
            }
            catch (Exception ex)
            {
                return "error: " + ex.Message;
            }
        }

        private static void AddPreDialysisParameters(SqlCommand cmd, PreDialysisData data)
        {
            cmd.Parameters.AddWithValue("@DialysisId", data.DialysisId);
            cmd.Parameters.AddWithValue("@PatientId", string.IsNullOrEmpty(data.PatientId) ? (object)DBNull.Value : data.PatientId);
            cmd.Parameters.AddWithValue("@VascularAccess", string.IsNullOrEmpty(data.VascularAccess) ? (object)DBNull.Value : data.VascularAccess);
            cmd.Parameters.AddWithValue("@DialysisNo", string.IsNullOrEmpty(data.DialysisNo) ? (object)DBNull.Value : data.DialysisNo);
            cmd.Parameters.AddWithValue("@MachineNo", string.IsNullOrEmpty(data.MachineNo) ? (object)DBNull.Value : data.MachineNo);
            cmd.Parameters.AddWithValue("@Dialyzer", string.IsNullOrEmpty(data.Dialyzer) ? (object)DBNull.Value : data.Dialyzer);
            cmd.Parameters.AddWithValue("@AdvisedBy", string.IsNullOrEmpty(data.AdvisedBy) ? (object)DBNull.Value : data.AdvisedBy);
            cmd.Parameters.AddWithValue("@PrimingBy", string.IsNullOrEmpty(data.PrimingBy) ? (object)DBNull.Value : data.PrimingBy);
            cmd.Parameters.AddWithValue("@PrimingSol", string.IsNullOrEmpty(data.PrimingSol) ? (object)DBNull.Value : data.PrimingSol);
            cmd.Parameters.AddWithValue("@Heparin", string.IsNullOrEmpty(data.Heparin) ? (object)DBNull.Value : data.Heparin);
            cmd.Parameters.AddWithValue("@HeparinInfusion", string.IsNullOrEmpty(data.HeparinInfusion) ? (object)DBNull.Value : data.HeparinInfusion);
            cmd.Parameters.AddWithValue("@CurrentWeight", string.IsNullOrEmpty(data.CurrentWeight) ? (object)DBNull.Value : data.CurrentWeight);
            cmd.Parameters.AddWithValue("@LastWeight", string.IsNullOrEmpty(data.LastWeight) ? (object)DBNull.Value : data.LastWeight);
            cmd.Parameters.AddWithValue("@StartTime", string.IsNullOrEmpty(data.StartTime) ? (object)DBNull.Value : data.StartTime);
            cmd.Parameters.AddWithValue("@FinishTime", string.IsNullOrEmpty(data.FinishTime) ? (object)DBNull.Value : data.FinishTime);
            cmd.Parameters.AddWithValue("@WeightDiff", string.IsNullOrEmpty(data.WeightDiff) ? (object)DBNull.Value : data.WeightDiff);
            cmd.Parameters.AddWithValue("@UF", string.IsNullOrEmpty(data.UF) ? (object)DBNull.Value : data.UF);
            cmd.Parameters.AddWithValue("@UFRate", string.IsNullOrEmpty(data.UFRate) ? (object)DBNull.Value : data.UFRate);
            cmd.Parameters.AddWithValue("@TotalDuration", string.IsNullOrEmpty(data.TotalDuration) ? (object)DBNull.Value : data.TotalDuration);
            cmd.Parameters.AddWithValue("@DialysisType", string.IsNullOrEmpty(data.DialysisType) ? (object)DBNull.Value : data.DialysisType);
            cmd.Parameters.AddWithValue("@SpecialInstruction", string.IsNullOrEmpty(data.SpecialInstruction) ? (object)DBNull.Value : data.SpecialInstruction);
            cmd.Parameters.AddWithValue("@Complaints", string.IsNullOrEmpty(data.Complaints) ? (object)DBNull.Value : data.Complaints);
            cmd.Parameters.AddWithValue("@ConsciousLevel", string.IsNullOrEmpty(data.ConsciousLevel) ? (object)DBNull.Value : data.ConsciousLevel);
            cmd.Parameters.AddWithValue("@Edema", string.IsNullOrEmpty(data.Edema) ? (object)DBNull.Value : data.Edema);
            cmd.Parameters.AddWithValue("@CardRhythm", string.IsNullOrEmpty(data.CardRhythm) ? (object)DBNull.Value : data.CardRhythm);
            cmd.Parameters.AddWithValue("@Lungs", string.IsNullOrEmpty(data.Lungs) ? (object)DBNull.Value : data.Lungs);
            cmd.Parameters.AddWithValue("@Other", string.IsNullOrEmpty(data.Other) ? (object)DBNull.Value : data.Other);
            cmd.Parameters.AddWithValue("@Remarks", string.IsNullOrEmpty(data.Remarks) ? (object)DBNull.Value : data.Remarks);
            cmd.Parameters.AddWithValue("@UserId", HttpContext.Current.Session["UserID"] ?? DBNull.Value);
        }

        [WebMethod]
        public static string SaveDuringDialysis(string DialysisId, string PatientId, string VitalSigns)
        {
            try
            {
                string conStr = ConfigurationManager.ConnectionStrings["ASPGLConnectionString"].ConnectionString;
                var vitals = JsonConvert.DeserializeObject<List<VitalSign>>(VitalSigns);

                using (SqlConnection con = new SqlConnection(conStr))
                {
                    con.Open();
                    
                    string deleteQuery = "DELETE FROM Dialysis_DuringDialysis WHERE Dialysis_ID = @DialysisId";
                    using (SqlCommand deleteCmd = new SqlCommand(deleteQuery, con))
                    {
                        deleteCmd.Parameters.AddWithValue("@DialysisId", DialysisId);
                        deleteCmd.ExecuteNonQuery();
                    }
                    
                    foreach (var vital in vitals)
                    {
                        string query = @"INSERT INTO Dialysis_DuringDialysis 
                                        (Dialysis_ID, Patient_ID, Vital_Time, Temperature, BP_Systolic, BP_Diastolic, Pulse, 
                                         Dialysis_Flow_Rate, Venous_Pressure, Blood_Flow, Created_Date, Created_By)
                                        VALUES 
                                        (@DialysisId, @PatientId, @Time, @Temperature, @BPSys, @BPDias, @Pulse, 
                                         @DialysisFlowRate, @VenousPressure, @BloodFlow, GETDATE(), @UserId)";

                        using (SqlCommand cmd = new SqlCommand(query, con))
                        {
                            cmd.Parameters.AddWithValue("@DialysisId", DialysisId);
                            cmd.Parameters.AddWithValue("@PatientId", PatientId);
                            cmd.Parameters.AddWithValue("@Time", string.IsNullOrEmpty(vital.Time) ? (object)DBNull.Value : vital.Time);
                            cmd.Parameters.AddWithValue("@Temperature", string.IsNullOrEmpty(vital.Temperature) ? (object)DBNull.Value : vital.Temperature);
                            cmd.Parameters.AddWithValue("@BPSys", string.IsNullOrEmpty(vital.BPSys) ? (object)DBNull.Value : vital.BPSys);
                            cmd.Parameters.AddWithValue("@BPDias", string.IsNullOrEmpty(vital.BPDias) ? (object)DBNull.Value : vital.BPDias);
                            cmd.Parameters.AddWithValue("@Pulse", string.IsNullOrEmpty(vital.Pulse) ? (object)DBNull.Value : vital.Pulse);
                            cmd.Parameters.AddWithValue("@DialysisFlowRate", string.IsNullOrEmpty(vital.DialysisFlowRate) ? (object)DBNull.Value : vital.DialysisFlowRate);
                            cmd.Parameters.AddWithValue("@VenousPressure", string.IsNullOrEmpty(vital.VenousPressure) ? (object)DBNull.Value : vital.VenousPressure);
                            cmd.Parameters.AddWithValue("@BloodFlow", string.IsNullOrEmpty(vital.BloodFlow) ? (object)DBNull.Value : vital.BloodFlow);
                            cmd.Parameters.AddWithValue("@UserId", HttpContext.Current.Session["UserID"] ?? DBNull.Value);

                            cmd.ExecuteNonQuery();
                        }
                    }
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
                string conStr = ConfigurationManager.ConnectionStrings["ASPGLConnectionString"].ConnectionString;

                using (SqlConnection con = new SqlConnection(conStr))
                {
                    con.Open();
                    
                    if (!string.IsNullOrEmpty(postDialysisData.DialysisId))
                    {
                        string checkQuery = "SELECT COUNT(*) FROM Dialysis_PostDialysis WHERE Dialysis_ID = @DialysisId";
                        using (SqlCommand checkCmd = new SqlCommand(checkQuery, con))
                        {
                            checkCmd.Parameters.AddWithValue("@DialysisId", postDialysisData.DialysisId);
                            int exists = (int)checkCmd.ExecuteScalar();
                            
                            if (exists > 0)
                            {
                                string updateQuery = @"UPDATE Dialysis_PostDialysis SET 
                                    Patient_ID = @PatientId,
                                    Start_Time = @StartTime, 
                                    End_Time = @EndTime, 
                                    Duration = @Duration, 
                                    Staff_ID = @StaffId, 
                                    Weight = @Weight, 
                                    Temperature = @Temperature, 
                                    BP_Systolic = @BPSys, 
                                    BP_Diastolic = @BPDias, 
                                    Pulse = @Pulse, 
                                    Comments = @Comments,
                                    Modified_Date = GETDATE(), 
                                    Modified_By = @UserId
                                    WHERE Dialysis_ID = @DialysisId";

                                using (SqlCommand cmd = new SqlCommand(updateQuery, con))
                                {
                                    AddPostDialysisParameters(cmd, postDialysisData);
                                    cmd.ExecuteNonQuery();
                                }
                                
                                return "success";
                            }
                        }
                    }
                    
                    string query = @"INSERT INTO Dialysis_PostDialysis 
                                    (Dialysis_ID, Patient_ID, Start_Time, End_Time, Duration, Staff_ID, Weight, 
                                     Temperature, BP_Systolic, BP_Diastolic, Pulse, Comments, 
                                     Created_Date, Created_By)
                                    VALUES 
                                    (@DialysisId, @PatientId, @StartTime, @EndTime, @Duration, @StaffId, @Weight, 
                                     @Temperature, @BPSys, @BPDias, @Pulse, @Comments, 
                                     GETDATE(), @UserId)";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        AddPostDialysisParameters(cmd, postDialysisData);
                        cmd.ExecuteNonQuery();
                    }
                }

                return "success";
            }
            catch (Exception ex)
            {
                return "error: " + ex.Message;
            }
        }

        private static void AddPostDialysisParameters(SqlCommand cmd, PostDialysisData data)
        {
            cmd.Parameters.AddWithValue("@DialysisId", data.DialysisId);
            cmd.Parameters.AddWithValue("@PatientId", string.IsNullOrEmpty(data.PatientId) ? (object)DBNull.Value : data.PatientId);
            cmd.Parameters.AddWithValue("@StartTime", string.IsNullOrEmpty(data.StartTime) ? (object)DBNull.Value : data.StartTime);
            cmd.Parameters.AddWithValue("@EndTime", string.IsNullOrEmpty(data.EndTime) ? (object)DBNull.Value : data.EndTime);
            cmd.Parameters.AddWithValue("@Duration", string.IsNullOrEmpty(data.Duration) ? (object)DBNull.Value : data.Duration);
            cmd.Parameters.AddWithValue("@StaffId", string.IsNullOrEmpty(data.StaffId) ? (object)DBNull.Value : data.StaffId);
            cmd.Parameters.AddWithValue("@Weight", string.IsNullOrEmpty(data.Weight) ? (object)DBNull.Value : data.Weight);
            cmd.Parameters.AddWithValue("@Temperature", string.IsNullOrEmpty(data.Temperature) ? (object)DBNull.Value : data.Temperature);
            cmd.Parameters.AddWithValue("@BPSys", string.IsNullOrEmpty(data.BPSys) ? (object)DBNull.Value : data.BPSys);
            cmd.Parameters.AddWithValue("@BPDias", string.IsNullOrEmpty(data.BPDias) ? (object)DBNull.Value : data.BPDias);
            cmd.Parameters.AddWithValue("@Pulse", string.IsNullOrEmpty(data.Pulse) ? (object)DBNull.Value : data.Pulse);
            cmd.Parameters.AddWithValue("@Comments", string.IsNullOrEmpty(data.Comments) ? (object)DBNull.Value : data.Comments);
            cmd.Parameters.AddWithValue("@UserId", HttpContext.Current.Session["UserID"] ?? DBNull.Value);
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