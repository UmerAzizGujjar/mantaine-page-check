using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class SampleCollectionFrom : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static String GetPatient(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var PatientDetail = db.sp_GetPatientByID(PatientID).ToList();
                return (new JavaScriptSerializer()).Serialize(PatientDetail);
            }
        }

        [WebMethod]
        public static string GetPatientInfo(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var PatientDetail = (from p in db.Reg_patients where p.pat_id == PatientID select p).FirstOrDefault();
                return (new JavaScriptSerializer()).Serialize(PatientDetail);
            }
        }
        [WebMethod]
        public static string LoadPatRange()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var dpt = (from d in db.DataValues
                       join v in db.ValueSets
                       on d.ValueSet_ID equals v.ValueSet_ID
                       where v.ValueSet_Name == "Test Patient Types"
                       select new
                       {
                           d.DataValue_Name,
                           d.DataValue_Description
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
        }



        [WebMethod]
        public static string PendingSampleList()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var TableData = db.sp_GetPenidngSample_List().ToList();
            return (new JavaScriptSerializer().Serialize(TableData));


        }

        [WebMethod]
        public static string GetUserBranch()
        {
            using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var branchIds = (from bwd in db.Branch_Wise_User_Details
                                 where bwd.User_Id == AppConfig.UserID
                                 select bwd.Brancg).ToList();

                if (!branchIds.Any())
                    return "null";

                var validBranches = new List<object>();

                foreach (var brancg in branchIds)
                {
                    if (int.TryParse(brancg, out int branchId))
                    {
                        var branch = db.Branches.FirstOrDefault(b => b.branch_ID == branchId);
                        if (branch != null)
                        {
                            validBranches.Add(new { branch_ID = branchId, branch_Name = branch.branch_Name });
                        }
                    }
                }

                if (!validBranches.Any())
                    return "null";

                return new JavaScriptSerializer().Serialize(validBranches);
            }
        }
        [WebMethod]
        public static String GetTestDetail(int MRNo, int[] Ids)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                //To convert list of int in string to pass store procedure
                string TempArray = String.Empty;
                for (int i = 0; i < Ids.Length; i++)
                {
                    if (i == 0)
                        TempArray = Ids[i] + "";
                    else
                        TempArray = TempArray + "," + Ids[i];
                }

               

                var TestDetail = db.sp_GetTestDetail(MRNo, TempArray).ToList();

                return (new JavaScriptSerializer()).Serialize(TestDetail);
            }

        }

        [WebMethod]
        public static String GetPatientDep(int PateintNo)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
               
                string PatientDep = DBClass.getField("select dbo.getPatientMain_Category(" + PateintNo + ")");
               

                return (new JavaScriptSerializer().Serialize(PatientDep));
            }
        }

        [WebMethod]
        public static String GetSampleSequenceId()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var Y = DateTime.Now.Year;
                var SampleNo = DBClass.getField("select isnull(max(Sample_ID),0) + 1 from Sample_Master where year(Sample_Collected_Date) = " + Y + "");

                return (new JavaScriptSerializer()).Serialize(Convert.ToInt32(SampleNo));
            }
        }

        [WebMethod]
        public static String GetSampleNo()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var SampleNo = db.Sample_Masters.DefaultIfEmpty().Max(p => p == null ? 0 : p.Sample_No + 1);
               

                if (SampleNo == 0)
                {
                    SampleNo = 1;
                }
               

                return (new JavaScriptSerializer()).Serialize(SampleNo);
            }
        }

        [WebMethod]
        public static String GetEmployeeNames()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var EmployeeNames = (from e in db.HR_Employees
                                     where e.IsDoctor == true
                                     select new
                                     {
                                         e.Emp_ID,
                                         e.Emp_Name

                                     }).ToList();

                return (new JavaScriptSerializer()).Serialize(EmployeeNames);
            }
           

        }
        [WebMethod]
        public static string GetAcknowlagmentCondition()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dept = (from data in db.sys_Parms
                        where data.Name == "Acknowlagment For Lab"
                        select
                          data.Code
                        ).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(dept);
        }
        [WebMethod]
        public static String SaveTest(DateTime CollectedDate, string sampleStatus, string ddlPat_type, int PatientID, string[][] SaveCheckedTest, int EmployeeID, string[][] rem)
        {
            var sampleid = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var SampleNo = db.Sample_Masters.DefaultIfEmpty().Max(p => p == null ? 0 : p.Sample_No + 1);

                if (SampleNo == 0)
                {
                    SampleNo = 1;
                }

                Sample_Master SMObj = new Sample_Master()
                {
                    Sample_No = SampleNo,
                    patient_type_range = ddlPat_type,
                    Sample_Collected_Date = CollectedDate,
                    Patient_ID = PatientID,
                    Sample_Status = sampleStatus,
                    Collected_Emp_ID = EmployeeID,
                    Created_By = AppConfig.UserID,
                    Created_Time = DateTime.Now
                };

                // Dictionary to track the next accession number for each OutSource lab
                Dictionary<string, int> nextAccessionNumbers = new Dictionary<string, int>();

                for (int i = 0; i < SaveCheckedTest.Length; i++)
                {
                    var Gener = (from lb in db.Lab_Tests
                                 where lb.Test_ID == Convert.ToInt32(SaveCheckedTest[i][1])
                                 select lb.Genre).FirstOrDefault();

                    if (Gener == null)
                    {
                        Gener = "0";
                    }

                    Sample_Detail SDObj = new Sample_Detail()
                    {
                        Test_ID = Convert.ToInt32(SaveCheckedTest[i][1]),
                        Bill_Detail_ID = Convert.ToInt32(SaveCheckedTest[i][2]),
                        Dept = SaveCheckedTest[i][3],
                        Genre = Gener,
                        Qty = SaveCheckedTest[i][5],
                        Remarks = rem[i][0].ToString(),
                        OutSource = rem[i][2].ToString(),
                        Sample_Collected = System.Convert.ToBoolean(rem[i][1]),
                    };

                    // Generate accession number if OutSource is selected (not "0")
                    if (rem[i][2].ToString() != "0" && !string.IsNullOrEmpty(rem[i][2].ToString()))
                    {
                        string outSourceLab = rem[i][2].ToString();

                        // Check if we already have a next number for this lab in current batch
                        if (!nextAccessionNumbers.ContainsKey(outSourceLab))
                        {
                            // Get the current MAX from database for this lab
                            int? maxAccessionNo = db.Sample_Details
                                .Where(sd => sd.OutSource == outSourceLab && sd.accession_no != null)
                                .Max(sd => (int?)sd.accession_no);

                            nextAccessionNumbers[outSourceLab] = (maxAccessionNo ?? 0) + 1;
                        }

                        // Assign the current number and increment for next test
                        SDObj.accession_no = nextAccessionNumbers[outSourceLab];
                        SDObj.dispatch_status = "Pending";
                      //  SDObj.a = DateTime.Now;

                        // Increment for the next test with same OutSource lab
                        nextAccessionNumbers[outSourceLab]++;
                    }

                    SMObj.Sample_Details.Add(SDObj);
                }

                db.Sample_Masters.InsertOnSubmit(SMObj);
                try
                {
                    db.SubmitChanges();
                    sampleid = Convert.ToString(SMObj.Sample_ID);
                }
                catch (Exception ex)
                {
                    return "Problem in save tests: " + ex.Message;
                }

                return "Save-" + sampleid;
            }
        }
        [WebMethod]
        public static String GetTestDetailBill(int BillId, int[] Ids)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                
                string TempArray = String.Empty;
                for (int i = 0; i < Ids.Length; i++)
                {
                    if (i == 0)
                        TempArray = Ids[i] + "";
                    else
                        TempArray = TempArray + "," + Ids[i];
                }



                var TestDetail = db.sp_GetTestDetailBill(BillId, TempArray).ToList();

                return (new JavaScriptSerializer()).Serialize(TestDetail);
            }

        }
        [WebMethod]
        public static String UpdateTest(DateTime CollectedDate, string sampleStatus, string ddlPat_type, string[][] SaveCheckedTest, int EmployeeID, int SampleID, string[][] rem)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var SampleMaster = (from SM in db.Sample_Masters
                                    where SM.Sample_ID == SampleID
                                    select SM).FirstOrDefault();

                if (SampleMaster == null)
                {
                    return "Sample not found";
                }

                SampleMaster.Sample_Collected_Date = CollectedDate;
                SampleMaster.Collected_Emp_ID = EmployeeID;
                SampleMaster.patient_type_range = ddlPat_type;
                SampleMaster.Sample_Status = sampleStatus;
                SampleMaster.Updated_By = AppConfig.UserID;
                SampleMaster.Updated_Time = DateTime.Now;

                var SampleDetail = (from SD in db.Sample_Details
                                    where SD.Sample_ID == SampleID
                                    select SD).ToList();

                db.Sample_Details.DeleteAllOnSubmit(SampleDetail);

                // Dictionary to track the next accession number for each OutSource lab
                Dictionary<string, int> nextAccessionNumbers = new Dictionary<string, int>();

                for (int i = 0; i < SaveCheckedTest.Length; i++)
                {
                    Sample_Detail SDObj = new Sample_Detail()
                    {
                        Test_ID = Convert.ToInt32(SaveCheckedTest[i][1]),
                        Bill_Detail_ID = Convert.ToInt32(SaveCheckedTest[i][2]),
                        Dept = SaveCheckedTest[i][3],
                        Genre = string.Empty,
                        Qty = SaveCheckedTest[i][5],
                        Remarks = rem[i][0].ToString(),
                        OutSource = rem[i][2].ToString(),
                        Sample_Collected = System.Convert.ToBoolean(rem[i][1]),
                    };

                    // Generate accession number if OutSource is selected (not "0")
                    if (rem[i][2].ToString() != "0" && !string.IsNullOrEmpty(rem[i][2].ToString()))
                    {
                        string outSourceLab = rem[i][2].ToString();

                        // Check if we already have a next number for this lab in current batch
                        if (!nextAccessionNumbers.ContainsKey(outSourceLab))
                        {
                            // Get the current MAX from database for this lab
                            int? maxAccessionNo = db.Sample_Details
                                .Where(sd => sd.OutSource == outSourceLab && sd.accession_no != null)
                                .Max(sd => (int?)sd.accession_no);

                            nextAccessionNumbers[outSourceLab] = (maxAccessionNo ?? 0) + 1;
                        }

                        // Assign the current number and increment for next test
                        SDObj.accession_no = nextAccessionNumbers[outSourceLab];
                        //SDObj.Accession_Generated_Date = DateTime.Now;

                        // Increment for the next test with same OutSource lab
                        nextAccessionNumbers[outSourceLab]++;
                    }

                    SampleMaster.Sample_Details.Add(SDObj);
                }

                try
                {
                    db.SubmitChanges();
                    return "Update";
                }
                catch (Exception ex)
                {
                    return (new JavaScriptSerializer().Serialize(ex.Message));
                }
            }
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
        public static string AllPendingLabTestDetail(string DeptID, int id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            JavaScriptSerializer serl = new JavaScriptSerializer();
            DateTime startDate = System.DateTime.Now.AddDays(-50);
            DateTime endData = System.DateTime.Now;
            serl.MaxJsonLength = 2147483647;

    

            //************ Load Front Desk Test with sample **************
            var testDetails_Billing_Sample = (from lbtM in db.Laboratory_Tests
                                              join lbtD in db.Lab_Test_Details
                                              on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                              join blng in db.Ar_Billings
                                              on lbtM.Patient_ID equals blng.Bill_ID
                                              join lbTDdef in db.Ar_Billing_Details
                                              on lbtD.Lab_Test_Detail_ID equals lbTDdef.ParentTrans_ID
                                              join paat in db.Reg_patients
                                              on blng.Patient_ID equals paat.pat_id

                                              join sd in db.Sample_Details
                                              on lbTDdef.Bill_Details_ID equals sd.Bill_Detail_ID
                                              join sm in db.Sample_Masters on sd.Sample_ID equals sm.Sample_ID

                                              where lbtM.Transaction_Type == "Front Desk" && lbtD.Recieved_ID == null && sd.Sample_Collected == true && sd.Sample_ID == id
                                              //&& (blng.Bill_Date.Value.Date >= startDate && blng.Bill_Date <= endData)
                                                    && (sm.Sample_Collected_Date.Value.Date >= startDate && sm.Sample_Collected_Date <= endData)
                                              orderby blng.Bill_Date descending
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
                                                  blng.Bill_No,
                                                  lbtM.Transaction_Type,
                                                  Doctor_ID = 0,
                                                  lbTDdef.Category_ID,
                                                  lbTDdef.Item_Name,
                                                  Sample_No = (from s in db.Sample_Masters where s.Sample_ID == sd.Sample_ID select s.Sample_No).FirstOrDefault(),
                                                  chkPackages = "0",
                                                  paat.Patient_No,
                                                  //paat.Entry_Date,
                                                  //paat.Created_Time,
                                                  blng.Patient_ID,
                                                  paat.Full_Name,
                                                  sd.Remarks,
                                                  Test_Name = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Test_Name).FirstOrDefault(),
                                                  Group_Department = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select lbTDdef.Category_ID).FirstOrDefault(),
                                                  DepartmentName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test Departments", t.Main_Department)).FirstOrDefault(),
                                                  Department_ID = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Main_Department).FirstOrDefault(),
                                                  GroupName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Test Groups", lbTDdef.Category_ID)).FirstOrDefault(),
                                                  Group_Name = db.GetDataValueName("Test Groups", lbTDdef.Category_ID),
                                                  Rotation_ID = lbtD.Rotation_ID,
                                                  Rotation = ((from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test Departments", t.Main_Department)).FirstOrDefault()) == "X-Ray" ? db.GetDataValueName("Test XRay Rotations", lbtD.Rotation_ID) : db.GetDataValueName("Test CT Scan Rotations", lbtD.Rotation_ID),
                                                  lbtD.Special_Tests,
                                                  lbtD.Area_Of_Interest,
                                                  haveSample = (from s in db.Sample_Details where s.Bill_Detail_ID == lbTDdef.Bill_Details_ID select s).Count() == 0 ? false : true,
                                                  sm.Sample_Status,
                                                  sd.OutSource,
                                                  lbTDdef.Bill_Details_ID,
                                                  sampleDate = (from sp in db.Sample_Masters where sp.Sample_ID == sd.Sample_ID select sp.Sample_Collected_Date).FirstOrDefault(),
                                                  sampleuser = (from sp in db.Sample_Masters where sp.Sample_ID == sd.Sample_ID select sp.Created_By).FirstOrDefault()
                                              }
               ).ToList();
            List<PendingLabTestClass> list = new List<PendingLabTestClass>();
           
    
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
                obj.Bill_No = item.Bill_No.ToString();
                obj.Sample_No = item.Sample_No.ToString();
                obj.Transaction_Type = item.Transaction_Type;
                obj.Doctor_ID = "0";
                obj.Patient_No = (Int32)item.Patient_No;
                obj.Patient_ID = item.Patient_ID.ToString();
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
                obj.Sample_Status = item.Sample_Status;
                obj.Outsource = item.OutSource;
                //obj.Entry_Date = item.Created_Time.ToString();
                obj.Sample_Date = item.sampleDate.ToString();
                obj.Sample_User = item.sampleuser.ToString();
                if (item.Recieved_ID != null)
                    obj.Recieved_ID = item.Recieved_ID;
                else
                    obj.Recieved_ID = "0";
                obj.Rotation = "";
                obj.Special_Tests = "";
                obj.Area_Of_Interest = "";
                if (obj.Department_ID == "001" || obj.Department_ID == null)
                    list.Add(obj);
            }
           
            return serl.Serialize(list);
        }
        public class PendingLabTestClass
        {
            public string chkPackages;
            public bool IsBilled;
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
            public string Sample_Date;
            public string Sample_User;
            public string Sample_Status;
            public string Outsource;
            public string Bill_No
            {
                get;
                set;
            }
            public string Sample_No
            {
                get;
                set;
            }
            internal void Add(PendingLabTestClass obj)
            {
                throw new NotImplementedException();
            }

            public string Remarks { get; set; }
        }
        //end 
        [WebMethod]
        public static string FillOutSource()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var dpt = (from d in db.DataValues
                       join v in db.ValueSets
                       on d.ValueSet_ID equals v.ValueSet_ID
                       where v.ValueSet_Name == "Out Source Labs"
                       select new
                       {
                           d.DataValue_Name,
                           d.DataValue_Description
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
        }
        [WebMethod]
        public static string GetSampleStatus()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var dpt = (from d in db.DataValues
                       join v in db.ValueSets
                       on d.ValueSet_ID equals v.ValueSet_ID
                       where v.ValueSet_Name == "Sample Status"
                       select new
                       {
                           d.DataValue_Name,
                           d.DataValue_Description
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
        }
        [WebMethod]
        public static int SaveLabTestList(string LabTestID, string btnSave, string transType, string transID, string tlist)
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

                //Saveing Group Test
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
                       // ltd.Test_Performed_By = test.TestPerformedBy;
                        ltd.Area_Of_Interest = test.Area;
                        ltd.Rotation_ID = test.RotationID;
                        ltd.L_R_Rotation_ID = test.L_R_Rotation_ID;
                        ltd.Bill_Details_ID = test.Bill_Details_ID;
                        ltd.Remark = test.Remarks;
                        ltd.Emergancy = Convert.ToBoolean(test.Emergancy);
                        ltd.Is_Result = false;
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
                                    //ltd.Test_Charges = Convert.ToDecimal(record.TestCharges);
                                    item.Bill_Details_ID = test.Bill_Details_ID;
                                    item.Test_Ready_On = Convert.ToDateTime(test.TestReadyOn);
                                    item.Test_Collected_On = Convert.ToDateTime(test.TestCollectedOn);
                                  //  item.Test_Performed_By = test.TestPerformedBy;
                                    item.Area_Of_Interest = test.Area;
                                    item.Rotation_ID = test.RotationID;
                                    item.L_R_Rotation_ID = test.L_R_Rotation_ID;
                                    ltd.Remark = test.Remarks;
                                    ltd.Emergancy = Convert.ToBoolean(test.Emergancy);
                                    item.Is_Result = false;
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
                    //ltd.Test_Charges = Convert.ToDecimal(record.TestCharges);
                    //   var ddd =
                    ltd.Bill_Details_ID = test.Bill_Details_ID;
                    ltd.Test_Ready_On = Convert.ToDateTime(test.TestReadyOn);
                    ltd.Test_Collected_On = Convert.ToDateTime(test.TestCollectedOn);
                   // ltd.Test_Performed_By = test.TestPerformedBy;
                    ltd.Area_Of_Interest = test.Area;
                    ltd.Rotation_ID = test.RotationID;
                    ltd.L_R_Rotation_ID = test.L_R_Rotation_ID;
                    ltd.Remark = test.Remarks;
                    ltd.Emergancy = Convert.ToBoolean(test.Emergancy);
                    ltd.Is_Result = false;
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
                                //ltd.Test_Charges = Convert.ToDecimal(record.TestCharges);
                                item.Bill_Details_ID = test.Bill_Details_ID;
                                item.Test_Ready_On = Convert.ToDateTime(test.TestReadyOn);
                                item.Test_Collected_On = Convert.ToDateTime(test.TestCollectedOn);
                               // item.Test_Performed_By = test.TestPerformedBy;
                                item.Area_Of_Interest = test.Area;
                                item.Rotation_ID = test.RotationID;
                                item.L_R_Rotation_ID = test.L_R_Rotation_ID;
                                ltd.Remark = test.Remarks;
                                ltd.Emergancy = Convert.ToBoolean(test.Emergancy);
                                item.Is_Result = false;
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


        [WebMethod]
        public static string GetSampleCode(int SampleID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            string billid = DBClass.getField(" select Bill_Detail_ID from Sample_Detail where Sample_ID='" + SampleID + "'");
            var sampleCode = db.getSampleIdentity(Convert.ToInt32(billid));
            return sampleCode;



        }
        [WebMethod]
        public static String LoadSampleHeader(int SampleID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                try
                {
                    var SampleHeader = db.sp_Sample_Header_Load(SampleID).ToList();
                    return (new JavaScriptSerializer().Serialize(SampleHeader));
                }
                catch (Exception ex)
                {
                    return (new JavaScriptSerializer().Serialize(ex.Message));
                }
            }
        }

        [WebMethod]
        public static String LoadSampleDetail(int SampleID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                try
                {
                    var SampleDetail = db.sp_Sample_Detail_Load(SampleID).ToList();
                    return (new JavaScriptSerializer().Serialize(SampleDetail));
                }
                catch (Exception ex)
                {
                    return (new JavaScriptSerializer().Serialize(ex.Message));
                }
            }
        }
    }
}