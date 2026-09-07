using AjaxControlToolkit;
using System;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static PMS.Modules.Dashboards.EMR;

namespace PMS
{
    public partial class LaboratoryTest : System.Web.UI.Page
    {
        public static int Test_id, ImageRecordID, outPatID, PatID;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtLab_Test_ID.Text = "(New)";
                if (Request.QueryString["ID"] != null)
                {
                    PopulateLabTestData(Convert.ToInt32(Request.QueryString["ID"]));
                    ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "", "GetTestList('" + Convert.ToInt32(Request.QueryString["ID"]) + "');", true);
                    Test_id = Convert.ToInt32(Request.QueryString["ID"].ToString());
                }
            }
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
        public static string GetLabTestInfo(int labTestId)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var labInfo = (from lt in db.Laboratory_Tests
                           join pat in db.Reg_patients on lt.Patient_ID equals pat.pat_id into a
                           from pat in a.DefaultIfEmpty()
                           where lt.Lab_Test_ID == labTestId
                           select new {
                               LabTestId = lt.Lab_Test_ID,
                               PatientName = pat != null ? pat.Full_Name : "Walk-in",
                               MR_No = pat != null ? pat.pat_id.ToString() : "--"
                           }).FirstOrDefault();

            var details = (from td in db.Lab_Test_Details
                          where td.Lab_Test_ID == labTestId
                          select new {
                              td.Test_ID,
                              td.Catagory_ID
                          }).Distinct().ToList();

            var tests = details.Select(d => {
                string testName;
                string catId = d.Catagory_ID ?? "";
                if (d.Test_ID > 0) {
                    var t = db.Lab_Tests.Where(x => x.Test_ID == d.Test_ID).FirstOrDefault();
                    testName = t != null ? t.Test_Name : "Unknown";
                } else {
                    testName = db.GetDataValueName("Test Groups", catId) ?? "Group Test";
                }
                return new {
                    TestId = d.Test_ID,
                    CategoryId = catId,
                    TestName = testName,
                    CategoryName = db.GetDataValueName("Test Groups", catId) ?? ""
                };
            }).ToList();

            var result = new {
                labInfo.LabTestId,
                labInfo.PatientName,
                labInfo.MR_No,
                Tests = tests
            };

            return new JavaScriptSerializer().Serialize(result);
        }
        [WebMethod]
        public static string LoadVitalParametersHistory(int patid)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var latestItem = (from op in db.Out_Patients
                              where op.Reg_PatId == patid
                              orderby op.Created_Time descending
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
                              }).FirstOrDefault(); // Only the latest record

            List<VitalParameterClass> list = new List<VitalParameterClass>();

            if (latestItem != null)
            {
                VitalParameterClass obj = new VitalParameterClass();
                obj.Pulse_Min = latestItem.pulse_Min;
                obj.Out_Patient_ID = latestItem.Out_Patient_ID;
                obj.BP_mm_Hg = latestItem.BP_mm_Hg;
                obj.Weight_Kg = latestItem.Weight_Kg;
                obj.Height_Cm = latestItem.Height_Cm;
                obj.Respiration_Min = latestItem.Respiration_Min;
                obj.Temp_C = latestItem.Temp_C;
                obj.L_M_P = latestItem.L_M_P;
                obj.SPO2 = latestItem.spo2;
                obj.BMI = latestItem.BMI ?? "";
                obj.MUAC = latestItem.MUAC;
                obj.OFC = latestItem.OFC;
                obj.Receiving_date = DateTime.Now;
                obj.RN_Special_Instruction = "";
                obj.RN_Patient_General_Condition = "";
                obj.Created_Time = Convert.ToDateTime(latestItem.Created_Time);
                obj.BSR = latestItem.BSR ?? "";
                obj.EDD = latestItem.EDD ?? "";
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


        [WebMethod]
        public static string checkRepeat(int RecievedID)
        {
            string returnString = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatROomsList = (from op in db.Lab_Test_Details
                                      where op.Lab_Test_Detail_ID == RecievedID
                                      select new
                                      {
                                          op.Lab_Test_ID,
                                      }).ToList();
                returnString = (new JavaScriptSerializer()).Serialize(inPatROomsList);

                if (inPatROomsList != null)
                {

                }
            }
            return returnString;
        }
        [WebMethod]
        public static string LoadimagesDetail(string TestDetailID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var data = (from td in db.Test_Images
                        where td.Lab_Test_Detail_ID == int.Parse(TestDetailID)
                        select new
                        {
                            td.Image_path
                        }).ToList();
            return (new JavaScriptSerializer().Serialize(data));
        }
        public class TestDetail
        {
            public string TestName;
            public string Department;
            public string Main;
            public bool Is_Result;
            public string Image_path;
            public string Group;
            public bool? Status;
            public string ValueType;
            public string Template;
            public string Diagnosiss;
            public string notes;
            public string Test_Values;
            public int Test_ID;
        }
        [WebMethod]
        public static string GetImage(string src)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var image = (from dv in db.Lab_Test_Details where dv.Image_path == src select dv).FirstOrDefault();
            Random rand = new Random();
            string randomfilename = @"Images\" + rand.Next().ToString();
            return "";
        }
        [WebMethod]
        public static string CountResult(string dpt)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var testDetailst = (from lbtM in db.Laboratory_Tests
                                    join lbtD in db.Lab_Test_Details
                                    on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                    join lbTDdef in db.Lab_Tests
                                    on lbtD.Test_ID equals lbTDdef.Test_ID
                                    where lbTDdef.Main_Department == dpt && Convert.ToDateTime(lbtM.Created_Time).Month == DateTime.Now.Month && Convert.ToDateTime(lbtM.Created_Time).Year == DateTime.Now.Year && Convert.ToDateTime(lbtM.Created_Time).Day == DateTime.Now.Day
                                    select new { }).ToList();
                var countTotal = testDetailst.Count();
                return (new JavaScriptSerializer()).Serialize(countTotal);
            }
            return "";
        }
        [WebMethod]
        public static TestDetail GetTestDetail(string TestDetailID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var data = (from td in db.Lab_Test_Details
                        join t in db.Lab_Tests
                        on td.Test_ID equals t.Test_ID
                        where td.Lab_Test_Detail_ID == int.Parse(TestDetailID)
                        select new TestDetail { TestName = t.Test_Name, Department = db.GetDataValueName("Test Departments", t.Group_Department), Main = db.GetDataValueName("Main Test Departments", t.Main_Department), Group = db.GetDataValueName("Test Groups", t.Group_Category), Status = td.Status, ValueType = t.Value_Type, Template = t.Fixed_Value, Image_path = td.Image_path, Diagnosiss = td.Diagnosis, notes = td.Notes, Is_Result = (bool)td.Is_Result, Test_Values = td.Test_Value, Test_ID = td.Test_ID }).FirstOrDefault();
            return data;
        }
        [WebMethod]
        public static string GetLabTests()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var tests = from t in db.Lab_Tests
                        where t.Main_Department == "001"
                        select new { t.Test_ID, t.Test_Name };
            List<TestIDsAndGroupCategory> listOfTest = new List<TestIDsAndGroupCategory>();
            int counter = 1;
            foreach (var test in tests)
            {
                TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                obj.TestID = test.Test_ID.ToString();
                obj.TestName = test.Test_Name.ToString();
                obj.SerialNo = counter.ToString();
                obj.IsGroupCategory = false;
                listOfTest.Add(obj);
                counter++;
            }
            var GroupCategories = from dv in db.DataValues
                                  join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                  where vs.ValueSet_Name == "Test Groups"
                                  select new { dv.DataValue_Name, dv.DataValue_Description };
            foreach (var category in GroupCategories)
            {
                TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                obj.TestID = category.DataValue_Name.ToString();
                obj.TestName = category.DataValue_Description.ToString();
                obj.SerialNo = counter.ToString();
                obj.IsGroupCategory = true;
                obj.CategoryID = category.DataValue_Name;
                listOfTest.Add(obj);
                counter++;
            }
            return (new JavaScriptSerializer()).Serialize(listOfTest);
        }
        [WebMethod]
        public static string GetTestMainDepartmentDetails(int TestID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var TestMainDepartmentName = (from t in db.Lab_Tests
                                          where t.Test_ID == TestID
                                          select new
                                          {
                                              TestMainDepartmentName123 = db.GetDataValueName("Main Test Departments", t.Main_Department.ToString()).ToString(),
                                              estMainDepartmen = t.Main_Department
                                          }).ToList();
            return (new JavaScriptSerializer().Serialize(TestMainDepartmentName));
        }
        [WebMethod]
        public static string FillTestsByCategory(string CategoryID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var tests = from t in db.Lab_Tests
                        where t.Main_Department == CategoryID
                        select new { t.Test_ID, t.Test_Name };
            return (new JavaScriptSerializer()).Serialize(tests);
        }
        [WebMethod]
        public static string FillTestName(string Cat)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var test = (from i in db.Lab_Tests
                        where i.Group_Category == Cat.ToString()
                        select new
                        {
                            i.Test_Name,
                            Test_ID = (from dv in db.Lab_Tests where dv.Test_Name == i.Test_Name select dv.Test_ID).FirstOrDefault(),
                        }).Distinct().ToList();
            return (new JavaScriptSerializer()).Serialize(test);
        }
        [WebMethod]
        public static string GetTestListForHistory(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var testDetailst = (from lbtM in db.Laboratory_Tests
                                join lbtD in db.Lab_Test_Details
                                on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                join lbTDdef in db.Lab_Tests
                                on lbtD.Test_ID equals lbTDdef.Test_ID
                                join abd in db.Ar_Billing_Details 
                                on lbtD.Bill_Details_ID equals abd.Bill_Details_ID
                                join ab in db.Ar_Billings on abd.Bill_ID equals ab.Bill_ID
                                join r in db.Reg_patients on ab.Patient_ID equals r.pat_id
                                where lbtM.Patient_ID == Convert.ToInt32(id)
                                select new
                                {
                                    lbtD.Lab_Test_Detail_ID,
                                    lbtD.Date,
                                    lbtD.Remark,
                                    lbtM.Lab_Test_ID,
                                    lbTDdef.Test_ID,
                                    lbTDdef.Test_Name,
                                    lbTDdef.Group_Department,
                                    lbtM.Parent_Transaction_Type,
                                    lbtM.Parent_Transaction_Type_ID,
                                    mainDepartmentName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test", t.Main_Department)).FirstOrDefault(),
                                    DepartmentName = db.GetDataValueName("Test Departments", lbTDdef.Group_Department),
                                    lbTDdef.Group_Category,
                                    GroupName = db.GetDataValueName("Test Groups", lbTDdef.Group_Category),
                                    lbtD.Test_Collected_On,
                                    lbtD.Test_Ready_On,
                                    lbtD.Test_Collected_By,
                                    lbtD.Image_path,
                                    lbtD.Is_Result,
                                    lbtD.Rotation_ID,
                                    lbtD.L_R_Rotation_ID,
                                    lbtD.Bill_Details_ID,
                                    r.mr_no_sequence,
                                    ab.Bill_No,
                                    Rotation = ((from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test Departments", t.Main_Department)).FirstOrDefault()) == "X-Ray" ? db.GetDataValueName("Test XRay                                                               Rotations", lbtD.Rotation_ID) : db.GetDataValueName("Test CT Scan Rotations", lbtD.Rotation_ID),
                                }
                ).ToList();
            return (new JavaScriptSerializer()).Serialize(testDetailst);
        }
        [WebMethod]
        public static string GetTestList(int id)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext();
                var testDetailst = (from lbtD in db.Lab_Test_Details
                                    where lbtD.Lab_Test_ID == id
                                    select new
                                    {
                                        lbtD.Lab_Test_Detail_ID,
                                        lbtD.Status,
                                        lbtD.Date,
                                        lbtD.Remark,
                                        lbtD.Lab_Test_ID,
                                        lbtD.Test_ID,
                                        Parent_Transaction_Type_ID = ((from pat in db.Laboratory_Tests where pat.Lab_Test_ID == id select pat.Parent_Transaction_Type_ID).FirstOrDefault()),
                                        Parent_Transaction_Type = ((from pat in db.Laboratory_Tests where pat.Lab_Test_ID == id select pat.Parent_Transaction_Type).FirstOrDefault()),
                                        Test_Name = ((from pat in db.Lab_Tests where pat.Test_ID == lbtD.Test_ID select pat.Test_Name).FirstOrDefault()),
                                        Catagory_ID = ((from pat in db.Lab_Tests where pat.Test_ID == lbtD.Test_ID select pat.Group_Category).FirstOrDefault()),
                                        Catagory_Name = ((from pat in db.Lab_Tests where pat.Test_ID == lbtD.Test_ID select db.GetDataValueName("Test Groups", pat.Group_Category)).FirstOrDefault()),
                                        DepartmentName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test Departments", t.Main_Department)).FirstOrDefault(),
                                        lbtD.Test_Collected_By,
                                        lbtD.Test_Collected_On,
                                        lbtD.Test_Ready_On,
                                        lbtD.Test_Performed_By,
                                        lbtD.Area_Of_Interest,
                                        lbtD.L_R_Rotation_ID,
                                        lbtD.Rotation_ID,
                                        Rotation = ((from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test                                                    Departments", t.Main_Department)).FirstOrDefault()) == "X-Ray" ? db.GetDataValueName("Test XRay Rotations", lbtD.Rotation_ID) : db.GetDataValueName("Test CT Scan Rotations", lbtD.Rotation_ID),
                                        lbtD.Emergancy,

                                    }
                    ).ToList();

                List<PendingLabTestClass> list = new List<PendingLabTestClass>();
                foreach (var item in testDetailst)
                {
                    PendingLabTestClass obj = new PendingLabTestClass();

                    obj.Lab_Test_Detail_ID = item.Lab_Test_Detail_ID.ToString();
                    obj.Date = Convert.ToDateTime(item.Date).ToString();

                    obj.Test_ID = item.Test_ID;
                    obj.Lab_Test_ID = Convert.ToInt32(item.Lab_Test_ID).ToString();

                    obj.Parent_Transaction_Type = item.Parent_Transaction_Type;
                    obj.Parent_Transaction_Type_ID = item.Parent_Transaction_Type_ID.ToString();

                    obj.Doctor_ID = "0";

                    obj.Test_Name = item.Test_Name;

                    obj.Catagory_ID = item.Catagory_ID;
                    obj.DepartmentName = item.DepartmentName;

                    obj.Rotation = item.Rotation;
                    obj.Special_Tests = "";
                    obj.Area_Of_Interest = "";
                    obj.Test_Performed_By = item.Test_Performed_By.ToString();
                    obj.Test_Ready_On = Convert.ToDateTime(item.Test_Ready_On);
                    obj.Test_Collected_On = Convert.ToDateTime(item.Test_Collected_On);
                    obj.Test_Collected_By = item.Test_Collected_By;

                    obj.Status = item.Status.ToString();
                    obj.Remark = item.Remark.ToString();
                    obj.Emergancy = Convert.ToBoolean(item.Emergancy);
                    list.Add(obj);
                }
                List<PendingLabTestClass> AlltestListRefined = new List<PendingLabTestClass>();
                AlltestListRefined = list;
              
                var NoOfTestsCateWise = (from lbtsts in db.Lab_Tests
                                         where lbtsts.Group_Category != "" && lbtsts.Group_Category != null
                                         group lbtsts by lbtsts.Group_Category into g
                                         select new
                                         {
                                             CategoryID = g.Key,
                                             Category = db.GetDataValueName("Test Groups", g.Key),
                                             testsCount = g.Count(),
                                             MainDepartment = (from tbl in db.Lab_Tests
                                                               where tbl.Group_Category == g.Key
                                                               select new { DepartmentName = (db.GetDataValueName("Main Test Departments", tbl.Main_Department) == null ? "" : db.GetDataValueName("Main Test Departments", tbl.Main_Department)) }
                                                                 ).FirstOrDefault().DepartmentName.ToString()
                                         }
                                         ).ToList();
                foreach (var item in NoOfTestsCateWise)
                {
                    int CatewisetestsCount = testDetailst.Where(t => t.Catagory_ID == item.CategoryID).Count();
                    if (CatewisetestsCount > 0)
                    {
                        AlltestListRefined.RemoveAll(t => t.Catagory_ID == item.CategoryID);
                        AlltestListRefined.Add(new PendingLabTestClass()
                        {
                            Test_Name = item.Category,
                          
                            Test_ID = 0,

                            Lab_Test_ID = testDetailst.Where(r => r.Catagory_ID == item.CategoryID).Select(r => r.Lab_Test_ID).FirstOrDefault().ToString(),
                            Status = testDetailst.Where(r => r.Catagory_ID == item.CategoryID).Select(r => r.Status).FirstOrDefault().ToString(),
                            Date = testDetailst.Where(r => r.Catagory_ID == item.CategoryID).Select(r => r.Date).FirstOrDefault().ToString(),

                            Parent_Transaction_Type_ID = testDetailst.Where(r => r.Catagory_ID == item.CategoryID).Select(r => r.Parent_Transaction_Type_ID).FirstOrDefault().ToString(),
                            Parent_Transaction_Type = testDetailst.Where(r => r.Catagory_ID == item.CategoryID).Select(r => r.Parent_Transaction_Type).FirstOrDefault().ToString(),
                            Catagory_ID = testDetailst.Where(r => r.Catagory_ID == item.CategoryID).Select(r => r.Catagory_ID).FirstOrDefault().ToString(),
                            DepartmentName = testDetailst.Where(r => r.Catagory_ID == item.CategoryID).Select(r => r.DepartmentName).FirstOrDefault().ToString(),

                            Test_Collected_By = testDetailst.Where(r => r.Catagory_ID == item.CategoryID).Select(r => r.Test_Collected_By).FirstOrDefault().ToString(),
                            Test_Collected_On = (DateTime)testDetailst.Where(r => r.Catagory_ID == item.CategoryID).Select(r => r.Test_Collected_On).FirstOrDefault(),
                            Test_Ready_On = (DateTime)testDetailst.Where(r => r.Catagory_ID == item.CategoryID).Select(r => r.Test_Ready_On).FirstOrDefault(),

                            Test_Performed_By = testDetailst.Where(r => r.Catagory_ID == item.CategoryID).Select(r => r.Test_Performed_By).FirstOrDefault(),
                            Area_Of_Interest = testDetailst.Where(r => r.Catagory_ID == item.CategoryID).Select(r => r.Area_Of_Interest).FirstOrDefault(),
                            L_R_Rotation_ID = testDetailst.Where(r => r.Catagory_ID == item.CategoryID).Select(r => r.L_R_Rotation_ID).FirstOrDefault(),
                            Rotation_ID = testDetailst.Where(r => r.Catagory_ID == item.CategoryID).Select(r => r.Rotation_ID).FirstOrDefault(),
                            Rotation = testDetailst.Where(r => r.Catagory_ID == item.CategoryID).Select(r => r.Rotation).FirstOrDefault(),
                            Remark = testDetailst.Where(r => r.Catagory_ID == item.CategoryID).Select(r => r.Remark).FirstOrDefault(),
                            Emergancy = (bool)testDetailst.Where(r => r.Catagory_ID == item.CategoryID).Select(r => r.Emergancy).FirstOrDefault()

                        });
                    }
                }
                return ((new JavaScriptSerializer()).Serialize(AlltestListRefined));
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }
        [WebMethod]
        public static string GetTests()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var test = (from t in db.Lab_Tests
                        select new { t.Test_ID, t.Test_Name }).ToList();
            return (new JavaScriptSerializer()).Serialize(test);
        }
        [WebMethod]
        public static string GetMainDepartments()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dep = from dv in db.DataValues
                      join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                      where vs.ValueSet_Name == "Main Test Departments"
                      select new { dv.DataValue_Name, dv.DataValue_Description };
            return (new JavaScriptSerializer()).Serialize(dep);
        }
        [WebMethod]
        public static string checkPackeges(string TransactionType, int Patient_ID, int InPatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var chkPackages = (from inpat in db.In_Patients
                               join p in db.Reg_patients
                               on inpat.Patient_ID equals p.pat_id
                               from bill in db.Ar_Billings
                               join billd in db.Ar_Billing_Details
                               on bill.Bill_ID equals billd.Bill_ID
                               join pkg in db.Packages
                               on billd.ParentTrans_ID equals pkg.Packages_ID
                               where inpat.Patient_ID == Patient_ID && inpat.Discharge == false
                               select pkg.Package_Name).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(chkPackages);
        }
        [WebMethod]
        public static string LoadAllTestCatagory(string LabTestID, string CatID, string LTesDtid, string TransactionType, int Patient_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var inPatmedicineList = (from lbtM in db.Laboratory_Tests
                                     join lbtD in db.Lab_Test_Details
                                     on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                     where lbtM.Parent_Transaction_Type_ID == Convert.ToInt32(LTesDtid) && lbtD.IsBilled == true
                                     select new
                                     {
                                         lbtM.Lab_Test_ID,
                                         lbtD.Lab_Test_Detail_ID,
                                         lbtD.Test_ID,
                                         Test_Name = ((from pat in db.Lab_Tests where pat.Test_ID == lbtD.Test_ID select pat.Test_Name).FirstOrDefault()),
                                         lbtD.IsBilled,
                                         lbtD.Catagory_ID,
                                     }).ToList();
            var COunt = inPatmedicineList.Count;
            if (COunt == 0)
            {
                var inPaTestList = (from lbtM in db.Laboratory_Tests
                                    join lbtD in db.Lab_Test_Details
                                    on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                  
                                    where lbtM.Lab_Test_ID == Convert.ToInt32(LabTestID) && lbtD.IsBilled == true && lbtD.Catagory_ID == CatID
                                    select new
                                    {
                                        lbtM.Lab_Test_ID,
                                        lbtD.Lab_Test_Detail_ID,
                                        lbtD.Test_ID,
                                        Test_Name = ((from pat in db.Lab_Tests where pat.Test_ID == lbtD.Test_ID select pat.Test_Name).FirstOrDefault()),
                                        lbtD.IsBilled,
                                        lbtD.Catagory_ID,
                                    }).ToList();

                var Counttest = inPaTestList.Count;
                if (Counttest == 0)
                {
                    var CountAll = (from t in db.Lab_Tests
                                    where t.Group_Category == CatID
                                    select new
                                    {
                                        Lab_Test_ID = 0,
                                        Lab_Test_Detail_ID = 0,
                                        t.Test_ID,
                                        t.Test_Name,
                                        IsBilled = false,
                                    }).ToList();
                    return (new JavaScriptSerializer()).Serialize(CountAll);
                }
                else
                {
                    foreach (var item in inPaTestList)
                    {
                        var CountAll = (from t in db.Lab_Tests
                                        where t.Group_Category == CatID
                                        select new
                                        {
                                            Lab_Test_ID = item.Lab_Test_ID.ToString(),
                                            Lab_Test_Detail_ID = item.Lab_Test_Detail_ID.ToString(),
                                            t.Test_ID,
                                            t.Test_Name,
                                            IsBilled = true,
                                            Catagory_ID = item.Catagory_ID,
                                        }).ToList();
                       
                        return (new JavaScriptSerializer()).Serialize(CountAll);
                    }
                }
            }
            else
            {
                List<PendingLabTestClass> AlltestList = new List<PendingLabTestClass>();
                foreach (var item in inPatmedicineList)
                {
                    var CountAll = (from t in db.Lab_Tests
                                    where t.Group_Category == CatID
                                    select new
                                    {
                                        Lab_Test_ID = item.Lab_Test_ID.ToString(),
                                        Lab_Test_Detail_ID = item.Lab_Test_Detail_ID.ToString(),
                                        t.Test_ID,
                                        t.Test_Name,
                                        IsBilled = true,
                                        Group_Category = item.Catagory_ID,
                                    }).ToList();
                   
                    return (new JavaScriptSerializer()).Serialize(CountAll);
                }

            }
            return "";
        }

        public class TestDetailsForOPDrpt
        {
            public string Lab_Test_Detail_ID { get; set; }
            public DateTime Date { get; set; }
            public string Remark { get; set; }
            public string Lab_Test_ID { get; set; }
            public string Test_ID { get; set; }
            public string Test_Name { get; set; }
            public string Group_Department { get; set; }
            public string DepartmentName { get; set; }
            public string Group_Category { get; set; }
            public string GroupName { get; set; }
            public string Rotation_ID { get; set; }
            public string Rotation { get; set; }
            public string Recieved_ID { get; set; }
            public string GroupCategory_ID { get; set; }
            public string Parent_Transaction_Type { get; set; }
            public int Parent_Transaction_Type_ID { get; set; }
            public string Transaction_Type { get; set; }
            public int Out_Patient_ID { get; set; }
            public int Patient_No { get; set; }
            public int Patient_ID { get; set; }
            public string Name { get; set; }
            public string Doctor_ID { get; set; }
            public string Area_Of_Interest { get; set; }
            public string Bill_Details_ID { get; set; }

        }
        [WebMethod]
        public static string AllPendingLabTestDetail(string DeptID)
        {
            //int Patient_ID = DBClass.GetMRNOBy_PatientID(Convert.ToInt32(MRno));
            DataBaseDataContext db = new DataBaseDataContext();
            JavaScriptSerializer serl = new JavaScriptSerializer();
            DateTime startDate = System.DateTime.Now.AddMonths(-2);
            var Month = startDate.Month;
            DateTime endData = System.DateTime.Now.Date;
            //DateTime dtTrailDate = new DateTime(2019, 12, 31);
            serl.MaxJsonLength = 2147483647;


            #region 'Comment Test of OPD and IPD Don't Delete This Region Code'
            //************ Load OutPtients Test **************
            /*
            var testDetails_OPD = (from lbtM in db.Laboratory_Tests
                                   join lbtD in db.Lab_Test_Details
                                   on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                   join outpat in db.Out_Patients
                                   on lbtM.Patient_ID equals outpat.Out_Patient_ID
                                   join paat in db.Patients
                                      on outpat.Patient_ID equals paat.Patient_ID
                                   where lbtD.Dept_ID == DeptID && lbtM.Transaction_Type == "OutPatient" 
                                   && lbtD.Recieved_ID == null

                                   select new
                                   {
                                       lbtD.IsBilled,
                                       lbtD.Lab_Test_Detail_ID,
                                       lbtD.Date,
                                       lbtD.Remark,
                                       lbtD.Catagory_ID,
                                       lbtM.Lab_Test_ID,
                                       lbtD.Test_ID,
                                       lbtD.Recieved_ID,
                                       lbtM.Parent_Transaction_Type,
                                       lbtM.Parent_Transaction_Type_ID,
                                       outpat.Out_Patient_ID,
                                       lbtM.Transaction_Type,
                                       outpat.Doctor_ID,
                                       paat.Patient_No,
                                       paat.Entry_Date,
                                       paat.Created_Time,
                                       outpat.Patient_ID,
                                       chkPackages = "0",
                                       paat.Full_Name,
                                       Test_Name = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Test_Name).FirstOrDefault(),
                                       Group_Department = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Group_Department).FirstOrDefault(),
                                       Group_Category = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Group_Category).FirstOrDefault(),
                                       DepartmentName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test                                               Departments", t.Main_Department)).FirstOrDefault(),
                                       Department_ID = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Main_Department).FirstOrDefault(),
                                       Group_Name = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Test                                                        Groups", t.Group_Category)).FirstOrDefault(),
                                       GroupName = db.GetDataValueName("Test Groups", lbtD.Catagory_ID),
                                       Rotation_ID = lbtD.Rotation_ID,
                                       Rotation = ((from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test                                                    Departments", t.Main_Department)).FirstOrDefault()) == "X-Ray" ? db.GetDataValueName("Test XRay Rotations", lbtD.Rotation_ID) : db.GetDataValueName("Test CT Scan Rotations", lbtD.Rotation_ID),
                                       lbtD.Special_Tests,
                                       lbtD.Area_Of_Interest
                                   }
                ).ToList();
            //************ Load InPtients Test **************
            var testDetails_INP = (from lbtM in db.Laboratory_Tests
                                   join lbtD in db.Lab_Test_Details
                                   on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                   join inpat in db.In_Patients
                                   on lbtM.Patient_ID equals inpat.In_Patient_ID
                                   join paat in db.Patients
                                       on inpat.Patient_ID equals paat.Patient_ID
                                   where lbtD.Dept_ID == DeptID && lbtM.Transaction_Type == "InPatient" 
                                  && lbtD.Recieved_ID == null
                                   select new
                                   {
                                       lbtD.IsBilled,
                                       lbtD.Lab_Test_Detail_ID,
                                       lbtD.Date,
                                       lbtD.Remark,
                                       lbtD.Catagory_ID,
                                       lbtM.Lab_Test_ID,
                                       lbtD.Test_ID,
                                       lbtD.Recieved_ID,
                                       lbtM.Parent_Transaction_Type,
                                       lbtM.Parent_Transaction_Type_ID,
                                       inpat.In_Patient_ID,
                                       inpat.Created_Time,
                                       lbtM.Transaction_Type,
                                       chkPackages = (from inpataient in db.In_Patients
                                                      join p in db.Patients on inpataient.Patient_ID equals p.Patient_ID
                                                      from bill in db.Ar_Billings
                                                      join billd in db.Ar_Billing_Details
                                                      on bill.Bill_ID equals billd.Bill_ID
                                                      join pkg in db.Packages on billd.ParentTrans_ID equals pkg.Packages_ID
                                                      where inpataient.Patient_ID == inpat.Patient_ID && inpat.Discharge == false && inpataient.Patient_ID == bill.Patient_ID && inpataient.In_Patient_ID == inpat.In_Patient_ID
                                                      select pkg.Package_Name).FirstOrDefault(),

                                       paat.Patient_No,
                                       inpat.Patient_ID,
                                       paat.Full_Name,
                                       Test_Name = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Test_Name).FirstOrDefault(),
                                       Group_Department = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Group_Department).FirstOrDefault(),
                                       Group_Category = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Group_Category).FirstOrDefault(),
                                       DepartmentName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test                                               Departments", t.Main_Department)).FirstOrDefault(),
                                       Department_ID = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Main_Department).FirstOrDefault(),
                                       Group_Name = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Test                                                        Groups", t.Group_Category)).FirstOrDefault(),
                                       GroupName = db.GetDataValueName("Test Groups", lbtD.Catagory_ID),
                                       Rotation_ID = lbtD.Rotation_ID,
                                       Rotation = ((from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test                                                    Departments", t.Main_Department)).FirstOrDefault()) == "X-Ray" ? db.GetDataValueName("Test XRay Rotations", lbtD.Rotation_ID) : db.GetDataValueName("Test CT Scan Rotations", lbtD.Rotation_ID),
                                       lbtD.Special_Tests,
                                       lbtD.Area_Of_Interest,
                                       lbtD.Doctor,
                                       DoctorName = (from p in db.HR_Employees where p.Emp_ID == Convert.ToInt32(lbtD.Doctor) && p.IsDoctor == true select p.Emp_Name).FirstOrDefault(),
                                   }
              ).ToList();
            */
            #endregion
            //************ Load Front Desk Test with out Sample **************
            //#region 'Comment Test of of with out sample '
            //var testDetails_Billing_Without_Sample = (from lbtM in db.Laboratory_Tests
            //                           join lbtD in db.Lab_Test_Details
            //                           on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
            //                           join blng in db.Ar_Billings
            //                           on lbtM.Patient_ID equals blng.Bill_ID
            //                           join lbTDdef in db.Ar_Billing_Details
            //                           on lbtD.Lab_Test_Detail_ID equals lbTDdef.ParentTrans_ID
            //                           join paat in db.Patients
            //                           on blng.Patient_ID equals paat.Patient_ID

            //                            join labt in db.Lab_Tests
            //                            on lbTDdef.Item_ID equals labt.Test_ID

            //                           //join sd in db.Sample_Details
            //                           //on lbTDdef.Bill_Details_ID equals sd.Bill_Detail_ID

            //                           where 
            //                           lbtM.Transaction_Type == "Front Desk" && lbtD.Recieved_ID == null
            //                           && labt.Qty == 0
            //                           && (blng.Bill_Date.Value.Date >= startDate && blng.Bill_Date <= endData)

            //                           select new
            //                           {
            //                               lbtD.IsBilled,
            //                               lbtD.Lab_Test_Detail_ID,
            //                               lbtD.Date,
            //                               lbtD.Remark,
            //                               lbtD.Catagory_ID,
            //                               lbtM.Lab_Test_ID,
            //                               lbtD.Test_ID,
            //                               lbtD.Recieved_ID,
            //                               lbtM.Parent_Transaction_Type,
            //                               lbtM.Parent_Transaction_Type_ID,
            //                               blng.Bill_ID,
            //                               lbtM.Transaction_Type,
            //                               Doctor_ID = 0,
            //                               lbTDdef.Category_ID,
            //                               lbTDdef.Item_Name,

            //                               chkPackages = "0",
            //                               paat.Patient_No,
            //                               paat.Entry_Date,
            //                               paat.Created_Time,
            //                               blng.Patient_ID,
            //                               paat.Full_Name,
            //                               Test_Name = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Test_Name).FirstOrDefault(),
            //                               Group_Department = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select lbTDdef.Category_ID).FirstOrDefault(),
            //                               DepartmentName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test                                               Departments", t.Main_Department)).FirstOrDefault(),
            //                               Department_ID = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Main_Department).FirstOrDefault(),
            //                               GroupName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Test Groups", lbTDdef.Category_ID)).FirstOrDefault(),
            //                               Group_Name = db.GetDataValueName("Test Groups", lbTDdef.Category_ID),
            //                               Rotation_ID = lbtD.Rotation_ID,
            //                               Rotation = ((from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test                                                    Departments", t.Main_Department)).FirstOrDefault()) == "X-Ray" ? db.GetDataValueName("Test XRay Rotations", lbtD.Rotation_ID) : db.GetDataValueName("Test CT Scan Rotations", lbtD.Rotation_ID),
            //                               lbtD.Special_Tests,
            //                               lbtD.Area_Of_Interest,
            //                               haveSample = (from s in db.Sample_Details where s.Bill_Detail_ID == lbTDdef.Bill_Details_ID select s).Count() == 0 ? false : true,
            //                               lbTDdef.Bill_Details_ID
            //                           }
            // ).ToList();
            //#endregion
            //************ Load Front Desk Test with sample **************
            //var testDetails_Billing_Sample = (from lbtM in db.Laboratory_Tests
            //                                  join lbtD in db.Lab_Test_Details
            //                                  on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
            //                                  join blng in db.Ar_Billings
            //                                  on lbtM.Patient_ID equals blng.Bill_ID
            //                                  join lbTDdef in db.Ar_Billing_Details
            //                                  on lbtD.Lab_Test_Detail_ID equals lbTDdef.ParentTrans_ID
            //                                  join paat in db.Patients
            //                                  on blng.Patient_ID equals paat.Patient_ID

            //                                  join sd in db.Sample_Details
            //                                  on lbTDdef.Bill_Details_ID equals sd.Bill_Detail_ID

            //                                  //join labt in db.Lab_Tests
            //                                  //on lbTDdef.Item_ID equals labt.Test_ID

            //                                  where lbtM.Transaction_Type == "Front Desk" && lbtD.Recieved_ID == null && sd.Sample_Collected == true
            //                          //blng.Bill_Date.Value.Date >= dtTrailDate.Date
            //                          //&& lbTDdef.Test_Main_Department == "001"
            //                          //&& labt.Qty == 1
            //                          && (blng.Bill_Date >= startDate)


            var testDetails_Billing_Sample = (from pat in db.Reg_patients
                                              join bill in db.Ar_Billings on pat.pat_id equals bill.Patient_ID
                                              join bill_details in db.Ar_Billing_Details on bill.Bill_ID equals bill_details.Bill_ID
                                              join lbtD in db.Lab_Test_Details on bill_details.ParentTrans_ID equals lbtD.Lab_Test_Detail_ID
                                              join lbtM in db.Laboratory_Tests on lbtD.Lab_Test_ID equals lbtM.Lab_Test_ID
                                              join sd in db.Sample_Details on bill_details.Bill_Details_ID equals sd.Bill_Detail_ID
                                              where lbtM.Transaction_Type == "Front Desk" && lbtD.Recieved_ID == null && sd.Sample_Collected == true && (bill.isCancel == false || bill.isCancel == null)
                                                && (bill.Bill_Date >= startDate)
                                              orderby bill.Bill_Date descending


                                              select new
                                              {
                                                  bill.Bill_No,
                                                  lbtD.IsBilled,
                                                  lbtD.Lab_Test_Detail_ID,
                                                  lbtD.Date,
                                                  lbtD.Remark,
                                                  lbtD.Catagory_ID,
                                                  lbtM.Lab_Test_ID,
                                                  lbtD.Test_ID,
                                                  lbtD.Recieved_ID,
                                                  lbtM.Parent_Transaction_Type,
                                                  lbtM.Parent_Transaction_Type_ID,
                                                  bill.Bill_ID,
                                                  lbtM.Transaction_Type,
                                                  Doctor_ID = 0,
                                                  bill_details.Category_ID,
                                                  bill_details.Item_Name,

                                                  chkPackages = "0",
                                                  pat.Patient_No,
                                                  pat.Created_time,

                                                  pat.pat_id,
                                                  pat.Full_Name,
                                                  sd.Remarks,
                                                  Test_Name = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Test_Name).FirstOrDefault(),
                                                  Group_Department = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select bill_details.Category_ID).FirstOrDefault(),
                                                  DepartmentName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test                                               Departments", t.Main_Department)).FirstOrDefault(),
                                                  Department_ID = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Main_Department).FirstOrDefault(),
                                                  GroupName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Test Groups", bill_details.Category_ID)).FirstOrDefault(),
                                                  Group_Name = db.GetDataValueName("Test Groups", bill_details.Category_ID),
                                                  Rotation_ID = lbtD.Rotation_ID,
                                                  Rotation = ((from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test                                                    Departments", t.Main_Department)).FirstOrDefault()) == "X-Ray" ? db.GetDataValueName("Test XRay Rotations", lbtD.Rotation_ID) : db.GetDataValueName("Test CT Scan Rotations", lbtD.Rotation_ID),
                                                   lbtD.Special_Tests,
                                                   lbtD.Area_Of_Interest,
                                                    haveSample = (from s in db.Sample_Details where s.Bill_Detail_ID == bill_details.Bill_Details_ID select s).Count() == 0 ? false : true,
                                                    IsUrgent = sd.IsUrgent,
                                                    bill_details.Bill_Details_ID
                                               }
               ).ToList();
            List<PendingLabTestClass> list = new List<PendingLabTestClass>();
            //****** OutPatients************

            #region 'Comment Area of Loading IPD and OPD TEst don't Delete This Region'
            /*
            foreach (var item in testDetails_OPD)
            {
                PendingLabTestClass obj = new PendingLabTestClass();
                if (item.IsBilled != null)
                    obj.IsBilled = (bool)item.IsBilled;
                obj.Out_Patient_ID = item.Out_Patient_ID.ToString();
                obj.Lab_Test_Detail_ID = item.Lab_Test_Detail_ID.ToString();
                obj.Date = Convert.ToDateTime(item.Date).ToString();
                obj.Catagory_ID = item.Catagory_ID;
                obj.Test_ID = item.Test_ID;
                obj.Lab_Test_ID = Convert.ToInt32(item.Lab_Test_ID).ToString();
                obj.Recieved_ID = item.Recieved_ID;
                obj.Parent_Transaction_Type = item.Parent_Transaction_Type;
                obj.Parent_Transaction_Type_ID = item.Parent_Transaction_Type_ID.ToString();
                obj.Transaction_Type = item.Transaction_Type;
                obj.DoctorName = item.Doctor_ID;
                obj.Patient_No = (Int32)item.Patient_No;
                obj.Patient_ID = item.Patient_ID.ToString();
                obj.Name = item.Full_Name;
                obj.chkPackages = "0"; ;
                if (item.Test_Name != null)
                    obj.Test_Name = item.Test_Name;
                else
                    obj.Test_Name = "";
                obj.Group_Department = "";
                if (item.Group_Category != null)
                    obj.Group_Category = item.Group_Category;
                else
                    obj.Group_Category = "0";
                if (item.Entry_Date != null)
                {
                    obj.Entry_Date = item.Entry_Date.ToString();
                }
                else
                {
                    obj.Entry_Date = item.Created_Time.ToString();
                }
                obj.DepartmentName = "";
                obj.Department_ID = "";
                if (item.GroupName != null)
                    obj.GroupName = item.GroupName;
                else
                    obj.GroupName = "";
                if (item.Recieved_ID != null)
                    obj.Recieved_ID = item.Recieved_ID;
                else
                    obj.Recieved_ID = "0";
                obj.Rotation_ID = "";
                obj.Rotation = "";
                obj.Special_Tests = item.Special_Tests;
                obj.Area_Of_Interest = item.Area_Of_Interest;
                list.Add(obj);
            }
            //****** InPatients************

            foreach (var item in testDetails_INP)
            {
                PendingLabTestClass obj = new PendingLabTestClass();
                if (item.IsBilled != null)
                    obj.IsBilled = (bool)item.IsBilled;
                obj.Out_Patient_ID = item.In_Patient_ID.ToString();
                obj.Lab_Test_Detail_ID = item.Lab_Test_Detail_ID.ToString();
                obj.Date = Convert.ToDateTime(item.Date).ToString();
                obj.Catagory_ID = item.Catagory_ID;
                obj.Test_ID = item.Test_ID;
                obj.chkPackages = item.chkPackages;
                obj.Lab_Test_ID = Convert.ToInt32(item.Lab_Test_ID).ToString();
                obj.Recieved_ID = item.Recieved_ID;
                obj.Parent_Transaction_Type = item.Parent_Transaction_Type;
                obj.Parent_Transaction_Type_ID = item.Parent_Transaction_Type_ID.ToString();
                // obj.Bill_ID=item.Bill_ID;
                obj.Transaction_Type = item.Transaction_Type;
                //obj.Doctor_ID = item.Doctor_ID;
                obj.Doctor_ID = item.Doctor;
                obj.DoctorName = item.DoctorName;
                obj.Patient_No = (Int32)item.Patient_No;
                obj.Patient_ID = item.Patient_ID.ToString();
                obj.Name = item.Full_Name;
                if (item.Test_Name != null)
                    obj.Test_Name = item.Test_Name;
                else
                    obj.Test_Name = "";
                obj.Group_Department = "";
                if (item.Group_Category != null)
                    obj.Group_Category = item.Group_Category;
                else
                    obj.Group_Category = "0";
                obj.DepartmentName = "";
                obj.Department_ID = "";
                if (item.GroupName != null)
                    obj.GroupName = item.GroupName;
                else
                    obj.GroupName = "";
                if (item.Recieved_ID != null)
                    obj.Recieved_ID = item.Recieved_ID;
                else
                    obj.Recieved_ID = "0";

               
                    obj.Entry_Date = item.Created_Time.ToString();
            
                
                obj.Rotation_ID = "";
                obj.Rotation = "";
                obj.Special_Tests = item.Special_Tests;
                obj.Area_Of_Interest = item.Area_Of_Interest;
                list.Add(obj);
            }
            */
            #endregion
            //****** Front Desk with out sample************
            //foreach (var item in testDetails_Billing_Without_Sample)
            //{
            //    PendingLabTestClass obj = new PendingLabTestClass();
            //    if (item.IsBilled != null)
            //        obj.IsBilled = (bool)item.IsBilled;
            //    obj.Lab_Test_Detail_ID = item.Lab_Test_Detail_ID.ToString();
            //    obj.Date = Convert.ToDateTime(item.Date).ToString();
            //    obj.Catagory_ID = item.Catagory_ID;
            //    obj.Test_ID = item.Test_ID;
            //    obj.Lab_Test_ID = Convert.ToInt32(item.Lab_Test_ID).ToString();
            //    obj.Recieved_ID = item.Recieved_ID;
            //    obj.Parent_Transaction_Type = item.Parent_Transaction_Type;
            //    obj.Parent_Transaction_Type_ID = item.Parent_Transaction_Type_ID.ToString();
            //    obj.Bill_ID = item.Bill_ID.ToString();
            //    obj.Transaction_Type = item.Transaction_Type;
            //    obj.Doctor_ID = "0";
            //    obj.Patient_No = (Int32)item.Patient_No;
            //    obj.Patient_ID = item.Patient_ID.ToString();
            //    obj.Name = item.Full_Name;
            //    obj.chkPackages = "0";
            //    obj.Test_Name = item.Test_Name;
            //    obj.Group_Department = item.Group_Department;
            //    obj.Group_Category = item.Category_ID;
            //    obj.Bill_Details_ID = item.Bill_Details_ID;
            //    obj.DepartmentName = item.DepartmentName;
            //    obj.Department_ID = item.Department_ID;
            //    obj.GroupName = item.Item_Name;
            //    obj.Entry_Date = item.Created_Time.ToString();
            //    if (item.Recieved_ID != null)
            //        obj.Recieved_ID = item.Recieved_ID;
            //    else
            //        obj.Recieved_ID = "0";
            //    obj.Rotation = "";
            //    obj.Special_Tests = "";
            //    obj.Area_Of_Interest = "";
            //    if (obj.Department_ID == "001" || obj.Department_ID == null)
            //        list.Add(obj);
            //}
            //****** Front Desk with sample************
            foreach (var item in testDetails_Billing_Sample)
            {
                PendingLabTestClass obj = new PendingLabTestClass();
                if (item.IsBilled != null)
                    obj.IsBilled = (bool)item.IsBilled;
                obj.Lab_Test_Detail_ID = item.Lab_Test_Detail_ID.ToString();
                obj.Date = Convert.ToDateTime(item.Date).ToString();
                obj.Catagory_ID = item.Catagory_ID;
                obj.Test_ID = item.Test_ID;
                obj.Lab_Test_ID = Convert.ToInt32(item.Lab_Test_ID).ToString();
                obj.Recieved_ID = item.Recieved_ID;
                obj.Parent_Transaction_Type = item.Parent_Transaction_Type;
                obj.Parent_Transaction_Type_ID = item.Parent_Transaction_Type_ID.ToString();
                obj.Bill_ID = item.Bill_ID.ToString();
                obj.Transaction_Type = item.Transaction_Type;
                obj.Doctor_ID = "0";
                obj.Patient_No = (Int32)item.Patient_No;
                obj.Patient_ID = item.pat_id.ToString();
                obj.Name = item.Full_Name;
                obj.chkPackages = "0";
                obj.Test_Name = item.Test_Name;
                obj.Group_Department = item.Group_Department;
                obj.Group_Category = item.Category_ID;
                obj.Bill_Details_ID = item.Bill_Details_ID;
                obj.DepartmentName = item.DepartmentName;
                obj.Department_ID = item.Department_ID;
                obj.Remarks = item.Remarks;
                obj.GroupName = item.Item_Name;
                obj.IsUrgent = item.IsUrgent ?? false;
                obj.Entry_Date = item.Created_time.ToString();
                if (item.Recieved_ID != null)
                    obj.Recieved_ID = item.Recieved_ID;
                else
                    obj.Recieved_ID = "0";
                obj.Rotation = "";
                obj.Special_Tests = "";
                obj.Area_Of_Interest = "";
                obj.Bill_No = item.Bill_No;
                if (obj.Department_ID == "001" || obj.Department_ID == null || obj.Department_ID == "005")
                    list.Add(obj);
            }
            //List<PendingLabTestClass> AlltestListRefined = new List<PendingLabTestClass>();
            //AlltestListRefined = list;
            ////// Getting All Investigation Tests Group Categories
            //var NoOfTestsCateWise = (from lbtsts in db.Lab_Tests
            //                         where lbtsts.Group_Category != "" && lbtsts.Group_Category != null
            //                         group lbtsts by lbtsts.Group_Category into g
            //                         select new
            //                         {
            //                          CategoryID = g.Key,
            //                          Category = db.GetDataValueName("Test Groups", g.Key),
            //                          testsCount = g.Count(),
            //                           MainDepartment = (from tbl in db.Lab_Tests
            //                                             where tbl.Group_Category == g.Key
            //                                             select new { DepartmentName = (db.GetDataValueName("Main Test Departments", tbl.Main_Department)                                                                 == null ? "" : db.GetDataValueName("Main Test Departments", tbl.Main_Department)) }
            //                                               ).FirstOrDefault().DepartmentName.ToString()
            //                         }
            //                         ).ToList();
            // foreach (var item in NoOfTestsCateWise)
            // {
            //     var Patient_ID = testDetails_Billing.Where(t => t.Group_Category == item.CategoryID).Select(t => t.Patient_ID).Distinct().ToList();
            //      foreach (var itemyy in Patient_ID)
            // {
            //     var Bill_ID = testDetails_Billing.Where(t => t.Group_Category == item.CategoryID && t.Patient_ID == itemyy).Select(t => t.Bill_ID).Distinct                ().ToList();
            //     foreach (var bill in Bill_ID)
            // {
            //int CatewisetestsCount = testDetails_Billing.Where(t => t.Group_Category == item.CategoryID && t.Patient_ID ==itemyy && t.Bill_ID==bill).Count();
            //     if (CatewisetestsCount == item.testsCount)
            //     {
            //         var Receive = (testDetails_Billing.Where(t => t.Group_Category == item.CategoryID && t.Patient_ID == itemyy && t.Bill_ID == bill).Select                                 (t => t.Recieved_ID).FirstOrDefault());
            //         if (Receive == null)
            //             Receive = "0";
            //         AlltestListRefined.RemoveAll(t => t.Group_Category == item.CategoryID && t.Patient_ID == itemyy.ToString());
            //         AlltestListRefined.Add(new PendingLabTestClass()
            //         {
            //             GroupName = item.Category,
            //             Test_ID = 0,
            //             Catagory_ID = item.CategoryID,
            //             Transaction_Type = "Front Desk",
            //             IsBilled = true,
            //             Patient_No = (int)(from i in db.Patients where i.Patient_ID == itemyy select i.Patient_No).FirstOrDefault(),
            //             Patient_ID = itemyy.ToString(),
            //             Name = (from i in db.Patients where i.Patient_ID == itemyy select i.Full_Name).FirstOrDefault(),
            //             Lab_Test_ID = (testDetails_Billing.Where(r => r.Group_Category == item.CategoryID && r.Patient_ID == itemyy && r.Bill_ID==bill ).Select(r                        => r.Lab_Test_ID).FirstOrDefault()).ToString(),
            //             Recieved_ID = Receive,
            //             Doctor_ID = "",
            //             chkPackages="0",
            //         });
            //     }
            // }
            // }
            // }
            return serl.Serialize(list);
        }


        public class PendingLabTestClass
        {
            public string chkPackages;
            public bool IsBilled;
            public bool IsUrgent;
            public string Lab_Test_Detail_ID;
            public string L_R_Rotation_ID;
            public string Date;
            public string Remark;
            public string Catagory_ID;
            public string Lab_Test_ID;
            public int Test_ID;
            public string Recieved_ID;
            public string Parent_Transaction_Type;
            public string Parent_Transaction_Type_ID;
            public string Transaction_Type;
            public string Doctor_ID;
            public int Patient_No;
            public string Patient_ID;
            public string Name;
            public string Test_Name;
            public string Group_Department;
            public string Group_Category;
            public string DepartmentName;
            public string Department_ID;
            public string GroupName;
            public string Rotation;
            public string Rotation_ID;
            public string Out_Patient_ID;
            public string Special_Tests;
            public string Area_Of_Interest;
            public string Bill_ID;
            public string DoctorName;
            public string Created_Time;
            public string Entry_Date;


           
            public DateTime Test_Ready_On;
            public DateTime Test_Collected_On;
            public string Test_Collected_By;
            public string Test_Performed_By;
            public string Status;
            public string cnic { get; set; }
            public string Mobile { get; set; }
            public bool Emergancy;
            public int Bill_Details_ID;
            public string Bill_No { get; set; }

            internal void Add(PendingLabTestClass obj)
            {
                throw new NotImplementedException();
            }

            public string Remarks { get; set; }
        }
       


        [WebMethod]
        public static string PendingTest(string DeptID)
        {
            DateTime startDate = System.DateTime.Now.AddDays(-10);
            DateTime endData = System.DateTime.Now.Date;

            DataBaseDataContext db = new DataBaseDataContext();
           
            var testDetailst_OPD = (from lbtM in db.Laboratory_Tests
                                                      join lbtD in db.Lab_Test_Details
                                                      on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                                      join blng in db.Ar_Billings
                                                      on lbtM.Patient_ID equals blng.Bill_ID
                                                      join lbTDdef in db.Ar_Billing_Details
                                                      on lbtD.Lab_Test_Detail_ID equals lbTDdef.ParentTrans_ID
                                                      join paat in db.Reg_patients
                                                      on blng.Patient_ID equals paat.pat_id

                                                      join labt in db.Lab_Tests
                                                      on lbTDdef.Item_ID equals labt.Test_ID
                                                    

                                                      where
                                                      labt.Main_Department == DeptID && 
                                                      lbtM.Transaction_Type == "Front Desk" && lbtD.Recieved_ID == null
                                                      && labt.Qty == 0
                                                      && (blng.Bill_Date.Value.Date >= startDate && blng.Bill_Date <= endData)

                                                      select new
                                                      {
                                                          lbtD.IsBilled,
                                                          lbtD.Lab_Test_Detail_ID,
                                                          lbtD.Date,
                                                          lbtD.Remark,
                                                          lbtD.Catagory_ID,
                                                          lbtM.Lab_Test_ID,
                                                          lbtD.Test_ID,
                                                          lbtD.Recieved_ID,
                                                          lbtM.Parent_Transaction_Type,
                                                          lbtM.Parent_Transaction_Type_ID,
                                                          blng.Bill_ID,
                                                          lbtM.Transaction_Type,
                                                          Doctor_ID = 0,
                                                          lbTDdef.Category_ID,
                                                          lbTDdef.Item_Name,

                                                          chkPackages = "0",
                                                          paat.Patient_No,
                                                          paat.Created_time,
                                                          //paat.Created_Time,
                                                          blng.Patient_ID,
                                                          paat.Full_Name,
                                                          Test_Name = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Test_Name).FirstOrDefault(),
                                                          Group_Department = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select lbTDdef.Category_ID).FirstOrDefault(),
                                                          DepartmentName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test                                               Departments", t.Main_Department)).FirstOrDefault(),
                                                          Department_ID = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Main_Department).FirstOrDefault(),
                                                          GroupName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Test Groups", lbTDdef.Category_ID)).FirstOrDefault(),
                                                          Group_Name = db.GetDataValueName("Test Groups", lbTDdef.Category_ID),
                                                          Rotation_ID = lbtD.Rotation_ID,
                                                          Rotation = ((from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test                                                    Departments", t.Main_Department)).FirstOrDefault()) == "X-Ray" ? db.GetDataValueName("Test XRay Rotations", lbtD.Rotation_ID) : db.GetDataValueName("Test CT Scan Rotations", lbtD.Rotation_ID),
                                                          lbtD.Special_Tests,
                                                          lbtD.Area_Of_Interest,
                                                          haveSample = (from s in db.Sample_Details where s.Bill_Detail_ID == lbTDdef.Bill_Details_ID select s).Count() == 0 ? false : true,
                                                          lbTDdef.Bill_Details_ID
                                                      }
 ).ToList();
            
            //************ Load In Patients Test **************
            var testDetailst_INP = (from lbtM in db.Laboratory_Tests
                                    join lbtD in db.Lab_Test_Details
                                    on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                    join Inpat in db.In_Patients
                                    on lbtM.Patient_ID equals Inpat.In_Patient_ID
                                    join lbTDdef in db.Lab_Tests
                                    on lbtD.Test_ID equals lbTDdef.Test_ID
                                    where lbTDdef.Main_Department == DeptID && Convert.ToDateTime(lbtM.Created_Time).Month == DateTime.Now.Month && Convert.ToDateTime(lbtM.Created_Time).Year == DateTime.Now.Year && Convert.ToDateTime(lbtM.Created_Time).Day == DateTime.Now.Day && lbtD.Image_path == null
                                    select new
                                    {
                                        lbtD.IsBilled,
                                        lbtD.Recieved_ID,
                                        lbtM.Parent_Transaction_Type,
                                        lbtM.Parent_Transaction_Type_ID,
                                        Inpat.In_Patient_ID,
                                        lbtM.Transaction_Type,
                                        lbtD.L_R_Rotation_ID,
                                        Patient_No = (from p in db.Reg_patients where Inpat.Patient_ID == p.pat_id select p.Patient_No).FirstOrDefault(),
                                        Inpat.Patient_ID,
                                        Name = (from p in db.Reg_patients where Inpat.Patient_ID == p.pat_id select p.Full_Name).FirstOrDefault(),
                                        Inpat.Doctor,
                                        lbtD.Lab_Test_Detail_ID,
                                        lbtD.Rotation_ID,
                                        chkPackages = (from inpataient in db.In_Patients
                                                       join p in db.Reg_patients on inpataient.Patient_ID equals p.pat_id
                                                       from bill in db.Ar_Billings
                                                       join billd in db.Ar_Billing_Details
                                                       on bill.Bill_ID equals billd.Bill_ID
                                                       join pkg in db.Packages on billd.ParentTrans_ID equals pkg.Packages_ID
                                                       where inpataient.Patient_ID == Inpat.Patient_ID && inpataient.Patient_ID == bill.Patient_ID && Inpat.Discharge == false
                                                       select pkg.Package_Name).FirstOrDefault(),
                                        Rotation = ((from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test                                                        Departments", t.Main_Department)).FirstOrDefault()) == "X-Ray" ? db.GetDataValueName("Test XRay Rotations", lbtD.Rotation_ID) : db.GetDataValueName("Test CT Scan Rotations", lbtD.Rotation_ID),
                                        lbtD.Date,
                                        lbtD.Remark,
                                        lbtM.Lab_Test_ID,
                                        lbTDdef.Test_ID,
                                        lbTDdef.Test_Name,
                                        lbtD.Area_Of_Interest,
                                        lbTDdef.Group_Department,
                                        Inpat.Created_Time,
                                        DepartmentName = db.GetDataValueName("Test Departments", lbTDdef.Group_Department),
                                        lbTDdef.Group_Category,
                                        GroupName = db.GetDataValueName("Test Groups", lbTDdef.Group_Category),
                                        //lbtD.Doctor,
                                        DoctorName = (from p in db.HR_Employees where p.Emp_ID == Convert.ToInt32(lbtD.Doctor) && p.IsDoctor == true select p.Emp_Name).FirstOrDefault(),
                                    }

            ).ToList();
            //************ Load Front DeskTest **************
            var testDetails_Billing = (from lbtM in db.Laboratory_Tests
                                       join lbtD in db.Lab_Test_Details
                                       on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                       join blng in db.Ar_Billings

                                       on lbtM.Patient_ID equals blng.Bill_ID
                                       join lbTef in db.Ar_Billing_Details
                                    on lbtD.Lab_Test_Detail_ID equals lbTef.ParentTrans_ID
                                       join lbTDdef in db.Lab_Tests
                                       on lbtD.Test_ID equals lbTDdef.Test_ID
                                       where lbTDdef.Main_Department == DeptID && lbtM.Transaction_Type == "Front Desk" && Convert.ToDateTime(blng.Creation_Date).Month == DateTime.Now.Month && Convert.ToDateTime(blng.Creation_Date).Year == DateTime.Now.Year && Convert.ToDateTime(blng.Creation_Date).Day == DateTime.Now.Day && lbtD.Image_path == null && lbTef.ParentTrans_Name == ""
                                       select new
                                       {
                                           lbtD.IsBilled,
                                           lbtD.Lab_Test_Detail_ID,
                                           lbtD.Date,
                                           lbtD.Remark,
                                           lbtD.Catagory_ID,
                                           lbtM.Lab_Test_ID,
                                           lbtD.Test_ID,
                                           lbtD.Recieved_ID,
                                           lbtD.L_R_Rotation_ID,
                                           lbtM.Parent_Transaction_Type,
                                           lbtM.Parent_Transaction_Type_ID,
                                           blng.Bill_ID,
                                           lbtM.Transaction_Type,
                                           Doctor_ID = 0,
                                           chkPackages = "0",
                                           lbTDdef.Group_Category,
                                           blng.Creation_Date,
                                           Patient_No = (from p in db.Reg_patients where blng.Patient_ID == p.pat_id select p.Patient_No).FirstOrDefault(),
                                           blng.Patient_ID,
                                           Name = (from p in db.Reg_patients where blng.Patient_ID == p.pat_id select p.Full_Name).FirstOrDefault(),
                                           Test_Name = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Test_Name).FirstOrDefault(),
                                           Group_Department = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select lbTDdef.Group_Category).FirstOrDefault(),
                                           DepartmentName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test                                                   Departments", t.Main_Department)).FirstOrDefault(),
                                           Department_ID = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Main_Department).FirstOrDefault(),
                                           GroupName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Test Groups", lbTDdef.Group_Category)).FirstOrDefault(),
                                           Group_Name = db.GetDataValueName("Test Groups", lbTDdef.Group_Category),
                                           Rotation_ID = lbtD.Rotation_ID,
                                           Rotation = ((from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test                                                        Departments", t.Main_Department)).FirstOrDefault()) == "X-Ray" ? db.GetDataValueName("Test XRay Rotations", lbtD.Rotation_ID) : db.GetDataValueName("Test CT Scan Rotations", lbtD.Rotation_ID),
                                           lbtD.Special_Tests,
                                           lbtD.Area_Of_Interest
                                       }
            ).ToList();

            List<PendingLabTestClass> list = new List<PendingLabTestClass>();
            foreach (var item in testDetailst_OPD)
            {
                PendingLabTestClass obj = new PendingLabTestClass();
                if (item.IsBilled != null)
                    obj.IsBilled = (bool)item.IsBilled;
             
                obj.Out_Patient_ID = "0";
                obj.Lab_Test_Detail_ID = item.Lab_Test_Detail_ID.ToString();
                obj.Date = Convert.ToDateTime(item.Date).ToString();
                obj.Test_ID = item.Test_ID;
                obj.Lab_Test_ID = Convert.ToInt32(item.Lab_Test_ID).ToString();
                obj.Recieved_ID = item.Recieved_ID;
              
                obj.L_R_Rotation_ID = string.Empty;
                obj.chkPackages = "0";
                obj.Parent_Transaction_Type = item.Parent_Transaction_Type;
                obj.Parent_Transaction_Type_ID = item.Parent_Transaction_Type_ID.ToString();
              
                obj.Transaction_Type = item.Transaction_Type;
            
                obj.DoctorName = string.Empty;
                obj.Patient_No = (Int32)item.Patient_No;
                obj.Patient_ID = item.Patient_ID.ToString();
                obj.Name = item.Full_Name;
                obj.Entry_Date = item.Created_time.ToString();
                if (item.Test_Name != null)
                    obj.Test_Name = item.Test_Name;
                else
                    obj.Test_Name = "";
                obj.Group_Department = "";
              
                    obj.Group_Category = "";
                obj.DepartmentName = "";
                obj.Department_ID = "";
                if (item.GroupName != null)
                    obj.GroupName = item.GroupName;
                else
                    obj.Group_Category = "";
                obj.Rotation_ID = item.Rotation_ID;
                obj.Rotation = item.Rotation;
                obj.Area_Of_Interest = item.Area_Of_Interest;
                list.Add(obj);
            }
            foreach (var item in testDetailst_INP)
            {
                PendingLabTestClass obj = new PendingLabTestClass();
                if (item.IsBilled != null)
                    obj.IsBilled = (bool)item.IsBilled;
                obj.Out_Patient_ID = item.In_Patient_ID.ToString();
                obj.Lab_Test_Detail_ID = item.Lab_Test_Detail_ID.ToString();
                obj.Date = Convert.ToDateTime(item.Date).ToString();
                obj.Test_ID = item.Test_ID;
                obj.Lab_Test_ID = Convert.ToInt32(item.Lab_Test_ID).ToString();
                obj.Recieved_ID = item.Recieved_ID;
                obj.L_R_Rotation_ID = item.L_R_Rotation_ID;
                obj.Parent_Transaction_Type = item.Parent_Transaction_Type;
                obj.Parent_Transaction_Type_ID = item.Parent_Transaction_Type_ID.ToString();
                obj.Transaction_Type = item.Transaction_Type;
                obj.Doctor_ID = item.Doctor;
                obj.DoctorName = item.DoctorName;
                obj.Patient_No = (Int32)item.Patient_No;
                obj.Patient_ID = item.Patient_ID.ToString();
                obj.Name = item.Name.ToString();
                obj.chkPackages = item.chkPackages;
                obj.Created_Time = item.Date.ToString();
                if (item.Test_Name != null)
                    obj.Test_Name = item.Test_Name;
                else
                    obj.Test_Name = "";
                obj.Group_Department = "";
                if (item.Group_Category != null)

                    obj.Group_Category = item.Group_Category;
                else
                    obj.Group_Category = "";
                obj.DepartmentName = "";
                obj.Department_ID = "";
                if (item.GroupName != null)
                    obj.GroupName = item.GroupName;
                else
                    obj.Group_Category = "";
                obj.Rotation_ID = item.Rotation_ID;
                obj.Rotation = item.Rotation;
                obj.Area_Of_Interest = item.Area_Of_Interest;
                list.Add(obj);
            }
            foreach (var item in testDetails_Billing)
            {
                PendingLabTestClass obj = new PendingLabTestClass();
                if (item.IsBilled != null)
                    obj.IsBilled = (bool)item.IsBilled;
                obj.Lab_Test_Detail_ID = item.Lab_Test_Detail_ID.ToString();
                obj.Date = Convert.ToDateTime(item.Date).ToString();
                obj.Catagory_ID = item.Catagory_ID;
                obj.Test_ID = item.Test_ID;
                obj.Lab_Test_ID = Convert.ToInt32(item.Lab_Test_ID).ToString();
                obj.Recieved_ID = item.Recieved_ID;
                obj.L_R_Rotation_ID = item.L_R_Rotation_ID;
                obj.Parent_Transaction_Type = item.Parent_Transaction_Type;
                obj.Parent_Transaction_Type_ID = item.Parent_Transaction_Type_ID.ToString();
                obj.Bill_ID = item.Bill_ID.ToString();
                obj.Transaction_Type = item.Transaction_Type;
                obj.Doctor_ID = "0";
                obj.chkPackages = "0";
                obj.Patient_No = (Int32)item.Patient_No;
                obj.Patient_ID = item.Patient_ID.ToString();
                obj.Name = item.Name;
                obj.Test_Name = item.Test_Name;
                obj.Group_Department = item.Group_Department;
                obj.Group_Category = item.Group_Category;
                obj.DepartmentName = item.DepartmentName;
                obj.Department_ID = item.Department_ID;
                obj.GroupName = item.GroupName;
                obj.Created_Time = item.Date.ToString();
                obj.Rotation_ID = "";
                obj.Rotation = "";
                obj.Special_Tests = "";
                obj.Area_Of_Interest = "";
                obj.Rotation_ID = item.Rotation_ID;
                obj.Rotation = item.Rotation;
                list.Add(obj);
            }
            return (new JavaScriptSerializer()).Serialize(list);
        }
        public class LabTest
        {
            public string PatientID { get; set; }
            public string ApprovedBy { get; set; }
            public string TestCharges { get; set; }
            public List<TestValue> TestList { get; set; }
            public string Area { get; set; }
        }
        public class TestValue
        {
            public int? Bill_Details_ID;
            public string LabTestID { get; set; }
            public string Date { get; set; }
            public string TestID { get; set; }
            public string Payment { get; set; }
            public string GroupCatID { get; set; }
            public string TestPerformedBy { get; set; }
            public string Area { get; set; }
            public DateTime TestCollectedOn { get; set; }
            public DateTime TestReadyOn { get; set; }
            public string TestCollectedBy { get; set; }
            public string TestDID { get; set; }
            public string RotationID { get; set; }
            public string L_R_Rotation_ID { get; set; }
            public string ParentLabTestID { get; set; }
            public string ParrentLabTestDetali { get; set; }

            public string Remarks { get; set; }
            public string Emergancy { get; set; }
        }
        [WebMethod]
        public static int SaveTest(string LabTestID, string btnSave, string transType, string transID, string tlist)
        {

            string LabtestID = "";
            Laboratory_Test lt = new Laboratory_Test();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<LabTest>(tlist);
            var lstTests = (from t in db.Laboratory_Tests
                            where t.Lab_Test_ID == int.Parse(LabTestID)
                            select t).FirstOrDefault();

            if (btnSave == "Update")
            {
                lstTests.Test_Charges = Convert.ToDecimal(record.TestCharges);
                lstTests.Updated_Time = DateTime.Now;
                lstTests.Updated_By = AppConfig.UserID;
                lstTests.Parent_Transaction_Type = transType;
                lstTests.Transaction_Type = transType;
                lstTests.Parent_Transaction_Type_ID = Convert.ToInt32(transID);
                db.SubmitChanges();
                LabtestID = lstTests.Lab_Test_ID.ToString();
            }
            else
            {
                lt.Patient_ID = Convert.ToInt32(record.PatientID);
                lt.Test_Charges = Convert.ToDecimal(record.TestCharges);
                lt.Created_Time = DateTime.Now;
                lt.Created_By = AppConfig.UserID;
                lt.Parent_Transaction_Type = transType;
                lt.Parent_Transaction_Type_ID = Convert.ToInt32(transID);
                db.Laboratory_Tests.InsertOnSubmit(lt);
                db.SubmitChanges();
                LabtestID = lt.Lab_Test_ID.ToString();
            }
            ///**********Deleting Previous details**************/
            var lstTestDetails = db.Lab_Test_Details.Where(t => t.Lab_Test_ID == int.Parse(LabtestID)).ToList();
            var count = lstTestDetails.Count;
            
            var labID = int.Parse(LabtestID);
            foreach (var test in record.TestList)
            {


                var CountAll = (from t in db.Lab_Tests
                                where t.Group_Category == test.GroupCatID
                                select new
                                {
                                    t.Test_ID,
                                }).ToList();

               
                if (test.TestID == "0")
                {
                    foreach (var testCatID in CountAll)
                    {
                        Lab_Test_Detail ltd = new Lab_Test_Detail();
                        ltd.Test_ID = testCatID.Test_ID;
                        ltd.Lab_Test_ID = labID;
                        ltd.Patient_ID = Convert.ToInt32(record.PatientID);
                        ltd.Date = DateTime.Now;
                        ltd.Status = Convert.ToBoolean(test.Payment);
                        ltd.Test_Collected_By = test.TestCollectedBy;
                        ltd.Test_Ready_On = Convert.ToDateTime(test.TestReadyOn);
                        ltd.Test_Collected_On = Convert.ToDateTime(test.TestCollectedOn);
                        ltd.Test_Performed_By = test.TestPerformedBy;
                        ltd.Area_Of_Interest = test.Area;
                        ltd.Rotation_ID = test.RotationID;
                        ltd.L_R_Rotation_ID = test.L_R_Rotation_ID;
                        ltd.Bill_Details_ID = test.Bill_Details_ID;
                        ltd.Remark = test.Remarks;
                        ltd.Emergancy = Convert.ToBoolean(test.Emergancy);
                        ltd.Is_Result = false;
                        ltd.Test_Status = "Pending";
                        var checkexit = db.Lab_Test_Details.Where(t => t.Test_ID == testCatID.Test_ID && t.Bill_Details_ID == test.Bill_Details_ID).ToList();
                        var Exist = checkexit.Count;
                        if (Exist == 0)
                        {
                            db.Lab_Test_Details.InsertOnSubmit(ltd);
                            db.SubmitChanges();
                        }
                        else
                        {
                            foreach (var item in lstTestDetails)
                            {
                                if (Convert.ToInt32(test.TestID) == item.Test_ID)
                                {
                                    item.Lab_Test_ID = labID;
                                    item.Patient_ID = Convert.ToInt32(record.PatientID);
                                    item.Date = DateTime.Now;
                                    item.Test_ID = Convert.ToInt32(test.TestID);
                                    item.Status = Convert.ToBoolean(test.Payment);
                                    item.Test_Collected_By = test.TestCollectedBy;
                                   
                                    item.Bill_Details_ID = test.Bill_Details_ID;
                                    item.Test_Ready_On = Convert.ToDateTime(test.TestReadyOn);
                                    item.Test_Collected_On = Convert.ToDateTime(test.TestCollectedOn);
                                    item.Test_Performed_By = test.TestPerformedBy;
                                    item.Area_Of_Interest = test.Area;
                                    item.Rotation_ID = test.RotationID;
                                    item.L_R_Rotation_ID = test.L_R_Rotation_ID;
                                    ltd.Remark = test.Remarks;
                                    ltd.Emergancy = Convert.ToBoolean(test.Emergancy);
                                    item.Is_Result = false;
                                    ltd.Test_Status = "Pending";
                                    db.SubmitChanges();
                                }
                            }
                        }
                        if (test.TestDID != "0")
                        {
                            {
                                var P = (from tbl in db.Lab_Test_Details
                                         where tbl.Lab_Test_Detail_ID == Convert.ToInt32(test.TestDID)
                                         select tbl).FirstOrDefault();
                                if (P != null)
                                {
                                    P.Recieved_ID = ltd.Lab_Test_Detail_ID.ToString();
                                    P.Is_Result = false;
                                    db.SubmitChanges();
                                }
                            }
                        }
                        var PR = (from tbl in db.Lab_Test_Details
                                  where tbl.Lab_Test_Detail_ID == Convert.ToInt32(test.ParrentLabTestDetali) && tbl.Lab_Test_ID == Convert.ToInt32(test.ParentLabTestID)
                                  select tbl).FirstOrDefault();
                        if (PR != null)
                        {
                            PR.Recieved_ID = ltd.Lab_Test_Detail_ID.ToString();
                            PR.Is_Result = false;
                            db.SubmitChanges();
                        }
                    }
                }
                //Saveing Individual Test
                else
                {
                    Lab_Test_Detail ltd = new Lab_Test_Detail();
                    ltd.Test_ID = Convert.ToInt32(test.TestID);
                    ltd.Lab_Test_ID = labID;
                    ltd.Patient_ID = Convert.ToInt32(record.PatientID);
                    ltd.Date = DateTime.Now;

                    ltd.Status = Convert.ToBoolean(test.Payment);
                    ltd.Test_Collected_By = test.TestCollectedBy;
                 
                    ltd.Bill_Details_ID = test.Bill_Details_ID;
                    ltd.Test_Ready_On = Convert.ToDateTime(test.TestReadyOn);
                    ltd.Test_Collected_On = Convert.ToDateTime(test.TestCollectedOn);
                    ltd.Test_Performed_By = test.TestPerformedBy;
                    ltd.Area_Of_Interest = test.Area;
                    ltd.Rotation_ID = test.RotationID;
                    ltd.L_R_Rotation_ID = test.L_R_Rotation_ID;
                    ltd.Remark = test.Remarks;
                    ltd.Emergancy = Convert.ToBoolean(test.Emergancy);
                    ltd.Is_Result = false;
                    ltd.Test_Status = "Pending";
                    var checkexit = db.Lab_Test_Details.Where(t => t.Test_ID == Convert.ToInt32(test.TestID) && t.Bill_Details_ID == test.Bill_Details_ID).ToList();
                    var Exist = checkexit.Count;
                    if (Exist == 0)
                    {
                        db.Lab_Test_Details.InsertOnSubmit(ltd);
                        db.SubmitChanges();
                    }
                    else
                    {
                        foreach (var item in lstTestDetails)
                        {
                            if (Convert.ToInt32(test.TestID) == item.Test_ID)
                            {
                                item.Lab_Test_ID = labID;
                                item.Patient_ID = Convert.ToInt32(record.PatientID);
                                item.Date = DateTime.Now;
                                item.Test_ID = Convert.ToInt32(test.TestID);
                                item.Status = Convert.ToBoolean(test.Payment);
                                item.Test_Collected_By = test.TestCollectedBy;
                              
                                item.Bill_Details_ID = test.Bill_Details_ID;
                                item.Test_Ready_On = Convert.ToDateTime(test.TestReadyOn);
                                item.Test_Collected_On = Convert.ToDateTime(test.TestCollectedOn);
                                item.Test_Performed_By = test.TestPerformedBy;
                                item.Area_Of_Interest = test.Area;
                                item.Rotation_ID = test.RotationID;
                                item.L_R_Rotation_ID = test.L_R_Rotation_ID;
                                ltd.Remark = test.Remarks;
                                ltd.Emergancy = Convert.ToBoolean(test.Emergancy);
                                item.Is_Result = false;
                                ltd.Test_Status = "Pending";
                                db.SubmitChanges();
                            }
                        }
                    }
                    if (test.TestDID != "0")
                    {
                        {
                            var P = (from tbl in db.Lab_Test_Details
                                     where tbl.Lab_Test_Detail_ID == Convert.ToInt32(test.TestDID)
                                     select tbl).FirstOrDefault();
                            if (P != null)
                            {
                                P.Recieved_ID = ltd.Lab_Test_Detail_ID.ToString();
                                P.Is_Result = false;
                                db.SubmitChanges();
                            }
                        }
                    }
                    var PR = (from tbl in db.Lab_Test_Details
                              where tbl.Lab_Test_Detail_ID == Convert.ToInt32(test.ParrentLabTestDetali) && tbl.Lab_Test_ID == Convert.ToInt32(test.ParentLabTestID)
                              select tbl).FirstOrDefault();
                    if (PR != null)
                    {
                        PR.Recieved_ID = ltd.Lab_Test_Detail_ID.ToString();
                        PR.Is_Result = false;
                        db.SubmitChanges();
                    }
                }

            }
            return labID;
        }
        private void PopulateLabTestData(int LabTest_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var qry = (from labTst in db.Laboratory_Tests
                       join pat in db.Reg_patients
                       on labTst.Patient_ID equals pat.pat_id
                       into a
                       from pat in a.DefaultIfEmpty()
                       where labTst.Lab_Test_ID == LabTest_ID
                       select new
                       {
                           labTst.Patient_ID,
                           labTst.Lab_Test_ID,
                           pat.Full_Name,
                           pat.Mobile1,
                           pat.Permanent_Address,
                           pat.Gender,
                           pat.Age_years,
                           pat.Created_time,
                           
                           labTst.Medical_Test,
                           labTst.Test_Charges,
                           labTst.Walk_In_Customer,
                           labTst.Test_Collected_On,
                           labTst.Test_Ready_On,
                           labTst.Test_Collected_By,
                           labTst.Test_Performed_By,
                           labTst.Test_Approved_By

                       }).FirstOrDefault();
            if (qry != null)
            {
                txtLab_Test_ID.Text = qry.Lab_Test_ID.ToString();
                vlblPatients_Name.Text = qry.Full_Name;
                vLbl_Contact.Text = qry.Mobile1;
                vLbl_Adress.Text = qry.Permanent_Address;
                if (qry.Gender != null)
                    vLbl_Gender.Text = db.GetDataValueName("Gender", qry.Gender);
                vLbl_Age.Text = qry.Age_years;
                if (qry.Created_time != null)
                {
                    vLbl_RegDate.Text = qry.Created_time.Value.ToString(AppConfig.DateFormat);
                }
                else
                {
                    vLbl_RegDate.Text = qry.Created_time.Value.ToString(AppConfig.DateFormat);
                }

                
                if (qry.Test_Collected_On != null)
                    chkCustomer.Checked = Convert.ToBoolean(qry.Walk_In_Customer);
                if (chkCustomer.Checked == true)
                {
                    txtPatient_ID.Text = "Walk-in Customer";
                    txtPatient_ID.ReadOnly = true;
                }
                else
                {
                    hdfPatient_ID.Value = qry.Patient_ID.ToString();
                    txtPatient_ID.Text = qry.Patient_ID.ToString();
                }
            }
        }
        [WebMethod]
        public static string GetLabTestDDLDetails(int SerialNo)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var tests = from t in db.Lab_Tests
                        where t.Main_Department == "001"
                        select new { t.Test_ID, t.Test_Name, t.Group_Category, TestMainDepartmentName = db.GetDataValueName("Main Test                                                   Departments", t.Main_Department.ToString()).ToString(), GroupCategoryName = db.GetDataValueName("Test Groups", t.Group_Category.ToString()).ToString() };
            List<TestIDsAndGroupCategory> listOfTest = new List<TestIDsAndGroupCategory>();
            int counter = 1;
          
            foreach (var test in tests)
            {
                TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                obj.TestID = test.Test_ID.ToString();
                obj.TestName = test.Test_Name.ToString();
                obj.SerialNo = counter.ToString();
                obj.IsGroupCategory = false;
                obj.CategoryID = test.Group_Category;
                obj.MainDepartmentName = test.TestMainDepartmentName;
                obj.GroupName = test.GroupCategoryName;
                listOfTest.Add(obj);
                counter++;
            }
            var GroupCategories = from dv in db.DataValues
                                  join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                  where vs.ValueSet_Name == "Test Groups"
                                  select new { dv.DataValue_Name, dv.DataValue_Description };
            
            foreach (var category in GroupCategories)
            {
                TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                obj.TestID = category.DataValue_Name.ToString();
                obj.TestName = category.DataValue_Description.ToString();
                obj.SerialNo = counter.ToString();
                obj.IsGroupCategory = true;
                obj.CategoryID = null;
                listOfTest.Add(obj);
                counter++;
            }
          
            counter = 1;
            foreach (TestIDsAndGroupCategory item in listOfTest)
            {
                if (SerialNo == Convert.ToInt32(item.SerialNo))
                {
                    if (item.IsGroupCategory)
                    {
                        tests = from t in db.Lab_Tests
                                where t.Group_Category == item.TestID
                                select new { t.Test_ID, t.Test_Name, t.Group_Category, TestMainDepartmentName = db.GetDataValueName("Main Test Departments", t.Main_Department.ToString()).ToString(), GroupCategoryName = db.GetDataValueName("Test Groups", t.Group_Category.ToString()).ToString() };
                        listOfTest = new List<TestIDsAndGroupCategory>();
                        foreach (var test in tests)
                        {
                            TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                            obj.TestID = test.Test_ID.ToString();
                            obj.TestName = test.Test_Name.ToString();
                            obj.SerialNo = counter.ToString();
                            obj.IsGroupCategory = false;
                            obj.CategoryID = test.Group_Category;
                            obj.MainDepartmentName = test.TestMainDepartmentName;
                            obj.GroupName = test.GroupCategoryName;
                            listOfTest.Add(obj);
                            counter++;
                        }
                    }
                }
            }
            if (counter == 1)
            {
              
                foreach (TestIDsAndGroupCategory item in listOfTest)
                {
                    if (SerialNo == Convert.ToInt32(item.SerialNo))
                    {
                        if (!item.IsGroupCategory)
                        {
                            tests = from t in db.Lab_Tests
                                    where t.Test_ID == Convert.ToInt32(item.TestID)
                                    select new { t.Test_ID, t.Test_Name, t.Group_Category, TestMainDepartmentName = db.GetDataValueName("Main Test                                             Departments", t.Main_Department.ToString()).ToString(), GroupCategoryName = db.GetDataValueName("Test Groups", t.Group_Category.ToString()).ToString() };
                            listOfTest = new List<TestIDsAndGroupCategory>();
                            foreach (var test in tests)
                            {
                                TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                                obj.TestID = test.Test_ID.ToString();
                                obj.TestName = test.Test_Name.ToString();
                                obj.SerialNo = counter.ToString();
                                obj.IsGroupCategory = false;
                                obj.CategoryID = test.Group_Category;
                                obj.MainDepartmentName = test.TestMainDepartmentName;
                                obj.GroupName = test.GroupCategoryName;
                                listOfTest.Add(obj);
                                counter++;
                            }
                        }
                    }
                }
            }
            return (new JavaScriptSerializer()).Serialize(listOfTest);
        }
        public class TestIDsAndGroupCategory
        {
            public string TestID { get; set; }
            public string TestName { get; set; }
            public string SerialNo { get; set; }
            public string CategoryID { get; set; }
            public bool IsGroupCategory { get; set; }
            public string GroupName { get; set; }
            public string MainDepartmentName { get; set; }
        }
        public class TestGroupCategory
        {
            public string TestID { get; set; }
            public string TestName { get; set; }
            public string SerialNo { get; set; }
            public string CategoryID { get; set; }
            public bool IsGroupCategory { get; set; }
            public string GroupName { get; set; }
            public string MainDepartmentName { get; set; }
        }
        public class Detail
        {
            public string Name;
            public string Gender;
            public string Age;
            public string Mobile;
            public string Address;
            public string Entry_Date;
            public string Patient_Category;

        }
        [System.Web.Services.WebMethod]
        public static Detail GetDetail(string PatientID)
        {
            int Patien_No = Convert.ToInt32(PatientID);
            Detail pt = new Detail();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Reg_patient pat = new Reg_patient();
            pat = (from tbl in db.Reg_patients
                   where tbl.pat_id == Convert.ToInt32(Convert.ToString(PatientID))
                   select tbl).FirstOrDefault();
            if (pat != null)
            {
                pt.Name = pat.Full_Name;
                pt.Gender = pat.Gender;
                pt.Age = pat.Age_years.ToString();
                if (pat.Created_time.HasValue)
                {
                    pt.Entry_Date = pat.Created_time.ToString();
                }
                else
                {
                    pt.Entry_Date = pat.Created_time.ToString();
                }
                pt.Address = pat.Permanent_Address;
                pt.Mobile = pat.Mobile1;
               
                pt.Gender = db.GetDataValueName("Gender", pat.Gender);
                return pt;
            }
            else
                return pt;
        }
        protected void chkCustomer_CheckedChanged(object sender, EventArgs e)
        {
            if (chkCustomer.Checked == true)
            {
                ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "bindDate", "bindDate();", true);
                txtPatient_ID.Text = "Walk-in Customer";
                txtPatient_ID.ReadOnly = true;
                lblAdress.Visible = false;
                vLbl_Adress.Visible = false;
                lblAge_Years.Visible = false;
                vLbl_Age.Visible = false;
                lblContactNo.Visible = false;
                vLbl_Contact.Visible = false;
                lblGender.Visible = false;
                vLbl_Gender.Visible = false;
                LblReg_Date.Visible = false;
                vLbl_RegDate.Visible = false;
                lblPatient_Name.Visible = false;
                vlblPatients_Name.Visible = false;
                LblPatient_Category.Visible = false;
                vPatient_Category.Visible = false;
            }
            else
            {
                ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "", "bindControls();", true);
                txtPatient_ID.Text = "";
                txtPatient_ID.ReadOnly = false;
                lblAdress.Visible = true;
                vLbl_Adress.Visible = true;
                lblAge_Years.Visible = true;
                vLbl_Age.Visible = true;
                lblContactNo.Visible = true;
                vLbl_Contact.Visible = true;
                lblGender.Visible = true;
                vLbl_Gender.Visible = true;
                LblReg_Date.Visible = true;
                vLbl_RegDate.Visible = true;
                lblPatient_Name.Visible = true;
                vlblPatients_Name.Visible = true;
                LblPatient_Category.Visible = true;
                vPatient_Category.Visible = true;
            }
        }
        private void download(DataTable dt, string Filename)
        {
            Byte[] bytes = (Byte[])dt.Rows[0]["Image_Path"];
            Response.Buffer = true;
            Response.Charset = "";
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.ContentType = dt.Rows[0]["Extention"].ToString();
            Response.AddHeader("content-disposition", "attachment;filename="
            + Filename.ToString());
            Response.BinaryWrite(bytes);
            Response.Flush();
            Response.End();
        }
        private string[] Split(char[] p)
        {
            throw new NotImplementedException();
        }
        [WebMethod]
        public static string GetRotationsCategoryWise(string testCategory)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dep = from dv in db.DataValues
                      join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                      where vs.ValueSet_Name == testCategory
                      select new { dv.DataValue_Name, dv.DataValue_Description };
            return (new JavaScriptSerializer()).Serialize(dep);
        }
    }
}