
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class TestApproval : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
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
            public string Patient_No;
        }
        public class Test
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
            public string GroupCategory_ID { get; set; }
            public string Unit { get; set; }
            public string Unit_Name { get; set; }
            public string ValueType { get; set; }
            public bool Status { get; set; }
            public string ImagePath { get; set; }
            public string Result_ID { get; set; }
            public string Parent_Transaction_Type { get; set; }
            public int Parent_Transaction_Type_ID { get; set; }
            public bool Is_Result { get; set; }
            public bool Emergancy { get; set; }
            public string ListOfTestIDs { get; set; }
            public string Bill_Details_ID { get; set; }
            public string Test_Temp { get; set; }
            public string Test_Value { get; set; }
            public string Start_Range { get; set; }
            public string End_Range { get; set; }
            public string Growth_type { get; set; }

            public string Organism_Name { get; set; }
            public string Organism_Value { get; set; }
            public string organismList { get; set; }

            public string Report_Colum { get; set; }
            public string Ranges { get; set; }
            public string AllRange { get; set; }
            public string Rejected_Reason { get; set; }
         
        }
        public class GroupTestDetails
        {
            public string lab_test_Detail_id { get; set; }
            public string fixed_values { get; set; }
            public string value_type { get; set; }
            public string result_type { get; set; }
            public string Growthtype { get; set; }
            public string OrganismType { get; set; }
            public string Master_Remarks { get; set; }
        }
        [WebMethod]
        public static string ApprovedResultList()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var TableData = db.sp_GetPenidngApprovel_List().ToList();
            return (new JavaScriptSerializer().Serialize(TableData));


        }
        [WebMethod]
        public static Detail GetDetail(string PatientID)
        {
            int Patien_No = Convert.ToInt32(PatientID);
            Detail pt = new Detail();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Patient pat = new Patient();
            pat = (from tbl in db.Patients
                   where tbl.Patient_ID == Patien_No
                   select tbl).FirstOrDefault();
            if (pat != null)
            {
                pt.Name = pat.Full_Name;
                pt.Gender = pat.Gender;
                pt.Age = pat.Age_years.ToString();
                if (pat.Entry_Date.HasValue)
                    pt.Entry_Date = pat.Entry_Date.ToString();
                // pt.Address = pat.Permanent_Address;
                pt.Mobile = pat.Mobile1;
                pt.Patient_Category = db.GetDataValueName("Patient Main Category", pat.Patient_Main_Category);
                pt.Gender = db.GetDataValueName("Gender", pat.Gender);
                return pt;
            }
            else
                return pt;
        }
        [WebMethod]
        public static string ApproveTests(List<Test> approve_list)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            foreach (var list in approve_list)
            {
                if (list.Group_Category == null || list.Group_Category == "")
                {
                    var result = (from p in db.Lab_Test_Details
                                  where p.Lab_Test_Detail_ID == Convert.ToInt32(list.Lab_Test_Detail_ID)
                                  select p).FirstOrDefault();
                    result.Approved_By = AppConfig.UserID;
                    result.Approved_Time = DateTime.Now;
                    result.isApproved = true;
                    result.Is_Result = true;
                    result.Test_Status = "Approved";
                    db.SubmitChanges();
                }
                else
                {
                    var testlist = (from td in db.Lab_Test_Details
                                    join b in db.Ar_Billing_Details
                                    on td.Bill_Details_ID equals b.Bill_Details_ID
                                    where b.Category_ID == list.Group_Category && b.Bill_Details_ID == int.Parse(list.Bill_Details_ID)
                                    select new
                                    { td.Lab_Test_Detail_ID }).ToList();
                    foreach (var lists in testlist)
                    {
                        Lab_Test_Detail test = (from t in db.Lab_Test_Details
                                                where t.Lab_Test_Detail_ID == (lists.Lab_Test_Detail_ID)
                                                select t).FirstOrDefault();
                        test.Approved_By = AppConfig.UserID;
                        test.Approved_Time = DateTime.Now;
                        test.isApproved = true;
                        test.Is_Result = true;
                        test.Test_Status = "Approved";
                        db.SubmitChanges();
                    }
                }
            }
            return "Approved Successfully";
        }
        [WebMethod]
        public static string RejectTests(string rejectedId, string groupCat, string billDetailID, string Remarks)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            if (groupCat == "0")
            {
                Lab_Test_Detail result = (from p in db.Lab_Test_Details
                              where p.Lab_Test_Detail_ID == Convert.ToInt32(rejectedId)
                              select p).FirstOrDefault();
                result.Rejected_By = AppConfig.UserID;
                result.Rejected_Time = DateTime.Now;
                result.IsRejected = true;
                result.Is_Result = true;
                result.Test_Status = "Rejected";
                result.Rejected_Reason = Remarks;
                db.SubmitChanges();
                return "Rejected Successfully";
            }
            else
            {
                var testlist = (from td in db.Lab_Test_Details
                             join b in db.Ar_Billing_Details
                             on td.Bill_Details_ID equals b.Bill_Details_ID
                                where b.Category_ID == groupCat && b.Bill_Details_ID == int.Parse(billDetailID)
                             select new
                             {
                                 td.Lab_Test_Detail_ID
                             }).ToList();
                if (testlist.Count > 0)
                {
                    foreach (var list in testlist)
                    {
                        Lab_Test_Detail test = (from t in db.Lab_Test_Details
                                                where t.Lab_Test_Detail_ID == (list.Lab_Test_Detail_ID)
                                                select t).FirstOrDefault();
                        test.Rejected_By = AppConfig.UserID;
                        test.Rejected_Time = DateTime.Now;
                        test.IsRejected = true;
                        test.Is_Result = true;
                        test.Test_Status = "Rejected";
                        test.Rejected_Reason = Remarks;
                        db.SubmitChanges();
                    }
                    return "Rejected Successfully";
                }
                else {
                    var result = (from td in db.Lab_Test_Details
                                  join b in db.Ar_Billing_Details
                                  on td.Bill_Details_ID equals b.Bill_Details_ID
                                  join labT in db.Lab_Tests
                                  on td.Test_ID equals labT.Test_ID
                                  where labT.Group_Category == groupCat && b.Bill_Details_ID == int.Parse(billDetailID)
                                  select new
                                  {
                                      td.Lab_Test_Detail_ID
                                  }).ToList();
                    foreach (var list in result)
                    {
                        Lab_Test_Detail test = (from t in db.Lab_Test_Details
                                                where t.Lab_Test_Detail_ID == (list.Lab_Test_Detail_ID)
                                                select t).FirstOrDefault();
                        test.Rejected_By = AppConfig.UserID;
                        test.Rejected_Time = DateTime.Now;
                        test.IsRejected = true;
                        test.Is_Result = true;
                        test.Test_Status = "Rejected";
                        test.Rejected_Reason = Remarks;
                        db.SubmitChanges();
                    }
                    return "Rejected Successfully";
                }
               
        }
           
        }
        [WebMethod]
        public static string GetLabDetail(string Patient_ID, int LabTestID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var patientNo = (from p in db.Patients
                             where p.Patient_ID == Convert.ToInt32(Patient_ID)
                             select p.Patient_No).FirstOrDefault();
            var patientIDs = (from p in db.Patients
                              where p.Patient_No == patientNo
                              select p.Patient_ID).ToList();
            //for range
            var patientGender = (from p in db.Patients where p.Patient_ID == Convert.ToInt32(Patient_ID) select p.Gender).FirstOrDefault();
            if (patientGender == "F")
            { patientGender = "2"; }
            else if (patientGender == "M")
            { patientGender = "1"; }
            else if (patientGender == "C")
            { patientGender = "3"; }
            //
           // int counter = 1;
            var data = (from lt in db.Laboratory_Tests
                        join ltd in db.Lab_Test_Details
                        on lt.Lab_Test_ID equals ltd.Lab_Test_ID
                        join tdef in db.Lab_Tests
                        on ltd.Test_ID equals tdef.Test_ID
                        join pa in db.Patients
                        on lt.Patient_ID equals pa.Patient_ID
                        join bd in db.Ar_Billing_Details
                        on ltd.Bill_Details_ID equals bd.Bill_Details_ID
                        //join tv in db.Test_Values
                        //on ltd.Test_ID equals tv.Test_ID

                        where

                        lt.Lab_Test_ID == (LabTestID == 0 ? lt.Lab_Test_ID : LabTestID)
                        && pa.Patient_No == patientNo
                        && (bd.Is_Group_Category == null ? false : bd.Is_Group_Category) == false
                        && bd.Is_Group_Category == false
                        select new
                        {
                            lt.Parent_Transaction_Type,
                            lt.Parent_Transaction_Type_ID,
                            lt.Lab_Test_ID,
                            tdef.Test_ID,
                            ltd.Lab_Test_Detail_ID,
                            tdef.Test_Name,
                            ltd.Rotation_ID,
                            ltd.Emergancy,
                            ltd.L_R_Rotation_ID,
                            tdef.Group_Category,
                            DepartmentName = (db.GetDataValueName
                            ("Main Test Departments", tdef.Main_Department) == null ? "" :
                            db.GetDataValueName("Main Test Departments", tdef.Main_Department)),
                            GroupName = (db.GetDataValueName
                            ("Test Groups", tdef.Group_Category) == null ? "" :
                            db.GetDataValueName("Test Groups", tdef.Group_Category)),
                            Rotation = db.GetDataValueName("Test XRay Rotations", ltd.Rotation_ID),
                            Unit_Name = (db.GetDataValueName("Test Units", tdef.Unit) == null ? "" : 
                            db.GetDataValueName("Test Units", tdef.Unit)),
                            tdef.Value_Type,
                            Status = ltd.Status == null ? false : true,
                            ltd.Image_path,
                            ltd.Is_Result,
                            ltd.Bill_Details_ID,
                            ltd.Test_Template,
                            ltd.Rejected_Reason,
                            Ranges = (from v in db.Test_Values where v.Test_ID == tdef.Test_ID && v.Patient_Type == patientGender select v.Start_Range + " - " + v.End_Range).FirstOrDefault(),

                            AllRange = (from v in db.Test_Values where v.Test_ID == tdef.Test_ID && v.Patient_Type == "6" select v.Start_Range + " - " + v.End_Range).FirstOrDefault(),
                            ltd.Test_Value,
                            ltd.Growth_Type,
                            tdef.Report_Colum,
                        }).ToList();

            List<Test> AlltestList = new List<Test>();
            List<Test> AlltestListRefined = new List<Test>();
            List<Test> AlltestOrganism = new List<Test>();
            //Populate Test in list (Single Test)
            foreach (var item in data)
            {
                Test test = new Test();
                test.Lab_Test_Detail_ID = item.Lab_Test_Detail_ID.ToString();
                test.Lab_Test_ID = item.Lab_Test_ID.ToString();
                test.Test_ID = item.Test_ID.ToString();
                test.Test_Name = item.Test_Name;
               // test.DepartmentName = item.DepartmentName;
                test.Group_Category = item.Group_Category;
                //test.GroupName = item.GroupName;
                test.Test_Temp = item.Test_Template;
                if (item.Is_Result != null)
                {
                    test.Is_Result = (bool)item.Is_Result;
                }
                else
                {
                    test.Is_Result = false;
                }
                if (item.Emergancy != null)
                {

                    test.Emergancy = (bool)item.Emergancy;
                }
                else
                {
                    test.Emergancy = false;
                }
                test.Rotation_ID = item.Rotation_ID;
                test.Rotation = item.Rotation;
                test.Unit_Name = item.Unit_Name;
                test.ValueType = item.Value_Type;
                test.Status = (bool)item.Status;
                test.Parent_Transaction_Type = item.Parent_Transaction_Type;
                test.Parent_Transaction_Type_ID = Convert.ToInt32(item.Parent_Transaction_Type_ID);
                test.Bill_Details_ID = item.Bill_Details_ID.ToString();
                //test.Start_Range = item.Start_Range;
                //test.End_Range = item.End_Range;
                test.Ranges = item.Ranges;
                test.AllRange = item.AllRange;
                test.Test_Value = item.Test_Value;
                test.Growth_type = item.Growth_Type;
                test.Report_Colum = item.Report_Colum;
                test.Rejected_Reason = item.Rejected_Reason;
                var orgNameVal = (from org in db.Result_Organisms 
                               where org.Test_ID == int.Parse(test.Test_ID)
                               select new { org.Organism_Name, org.Organism_Value});
                Test orgs = new Test();
                foreach(var i in orgNameVal)
                {

                    orgs.Organism_Name = i.Organism_Name;
                    orgs.Organism_Value = i.Organism_Value;
                    AlltestOrganism.Add(orgs);
                   // AlltestList.Add(orgs);
                    //counter++;
                }
               // item.list
                AlltestList.Add(test);
               // counter++;
            }

            AlltestListRefined = AlltestList;
            //For Group Tests
            DataTable GroupTest = DBClass.getDataTable
            ("Select Distinct ld.Lab_Test_ID, (select Segment2 from Datavalues where Datavalue_Name = (Select Group_Category from Lab_TEsts where TEst_ID = ld.Test_ID) and ValueSet_ID = 70) as [Segment2], (select Datavalue_ID from Datavalues where Datavalue_Name = (Select Group_Category from Lab_TEsts where TEst_ID = ld.Test_ID) and ValueSet_ID = 70) as [Test_ID], (Select Group_Category from Lab_TEsts where TEst_ID = ld.Test_ID) as [Group_Category], dbo.GetDataValueName('Test Groups', (Select Group_Category from Lab_TEsts where TEst_ID = ld.Test_ID)) as [Group_Test_Name], bd.Bill_Details_ID,ld.Is_Result , ld.Rejected_Reason from Lab_Test_Detail ld, Lab_Tests lt, Laboratory_Test ltm, AR_Billing_Details bd where bd.Bill_Details_ID = ld.Bill_Details_ID and isnull(bd.Is_Group_Category,0) = 1 and ld.Patient_ID = (case when " + Patient_ID + " = 0 then ld.Patient_ID else " + Patient_ID + " end) and lt.Test_ID = ld.Test_ID /*and lt.Group_Category <> ''*/ and ltm.Lab_Test_ID = ld.Lab_Test_ID and ltm.Lab_Test_ID = (case when " + LabTestID + " = 0 then ltm.Lab_Test_ID else " + LabTestID + " end)");

            foreach (DataRow item in GroupTest.Rows)
            {
                Test TestObj = new Test()
                {

                    Lab_Test_ID = item[0] == DBNull.Value ? "" : item[0].ToString(),
                    Report_Colum = item[1] == DBNull.Value ? "" : item[1].ToString(),
                    Test_ID = item[2] == DBNull.Value ? "" : item[2].ToString(),
                    Group_Category = item[3] == DBNull.Value ? "" : item[3].ToString(),
                    Test_Name = item[4] == DBNull.Value ? "" : item[4].ToString(),
                    Bill_Details_ID = item[5] == DBNull.Value ? "" : item[5].ToString(),
                    Is_Result = Convert.ToBoolean(item[6] == DBNull.Value ? "" : item[6]),
                    Rejected_Reason = item[7] == DBNull.Value ? "" : item[7].ToString(), 
                };
                TestObj.ListOfTestIDs = DBClass.getField("select dbo.[GetGroupSubTests]('" + TestObj.Group_Category + "')");
                var resID = (from ltd in db.Lab_Test_Details
                             where ltd.Bill_Details_ID == int.Parse(TestObj.Bill_Details_ID)
                             select ltd.Lab_Test_Detail_ID).FirstOrDefault();
                TestObj.Lab_Test_Detail_ID = Convert.ToString(resID);
                AlltestListRefined.Add(TestObj);
            }
            return (new JavaScriptSerializer()).Serialize(AlltestListRefined);
        }
        [WebMethod]
        public static string GetTestDetails(int LabID, string CatID, int billDetailID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            string returnData = string.Empty;
            bool isSingleGroupTest = false;
            string data = string.Empty;
            var patientGender = (from p in db.Patients
                                 where p.Patient_ID == (from l in db.Laboratory_Tests
                                                        where l.Lab_Test_ID == LabID
                                                        select l.Patient_ID).FirstOrDefault()
                                 select p.Gender).FirstOrDefault();
            var categoryFromBill = DBClass.getField("select Category_ID from Ar_Billing_Details where Bill_Details_ID = " + billDetailID + "").ToString();
            if (categoryFromBill == string.Empty)
            {
                CatID = "0";
            }
            var DataValue_Name = db.DataValues
                .Where(m => m.DataValue_ID.Equals(CatID))
                .Select(m => m.DataValue_Name)
                .FirstOrDefault();
            if (DataValue_Name == null)
            {
                DataValue_Name = db.Lab_Tests
                    .Where(x => x.Test_ID.Equals(CatID))
                    .Select(x => x.Group_Category)
                    .FirstOrDefault();
                if (DataValue_Name != null)
                    isSingleGroupTest = true;
            }
            if (!CatID.Equals("0"))
            {
                var inPatmedicineList = (from pm in db.Lab_Test_Details
                                         join t in db.Lab_Tests
                                         on pm.Test_ID equals t.Test_ID
                                         where t.Group_Category == DataValue_Name && pm.Lab_Test_ID == LabID
                                         select new
                                         {
                                             pm.Lab_Test_ID,
                                             pm.Test_ID,
                                             t.Test_Name,
                                             Lab_Test_Detail_ID = (from lbd in db.Lab_Test_Details
                                                                   where lbd.Lab_Test_ID == Convert.ToInt32(LabID) && lbd.Test_ID == pm.Test_ID
                                                                   select lbd.Lab_Test_Detail_ID).FirstOrDefault(),
                                             pm.Test_Value,
                                             pm.Is_Result,
                                             pm.Approved_By,
                                             pm.Test_Template,
                                             Group_CategoryName = db.GetDataValueName("Test Groups", t.Group_Category),
                                             Group_Department = db.GetDataValueName("Test Departments", t.Group_Department),
                                             Main_Department = db.GetDataValueName("Main Test Departments", t.Main_Department),
                                             pm.Status,
                                             pm.isApproved,
                                             pm.Diagnosis,
                                             pm.Notes,
                                             isSingleGroupTest = isSingleGroupTest,
                                             Fixed_Value = pm.Is_Result == true ? pm.Test_Template : t.Fixed_Value,
                                             t.Value_Type,
                                             t.Result_Type_Fixed,
                                             t.Result_Type_List,
                                             t.Result_Type_Value,
                                             pm.Result_Value,
                                             pm.Growth_Type,
                                             pm.Organism_Type,
                                             pm.Master_Remarks,
                                             resultValueList = (from p in db.Lab_Test_Multiple_Values
                                                                where p.Test_ID == t.Test_ID
                                                                select p.Value).ToList()
                                         }).ToList();
                returnData = (new JavaScriptSerializer()).Serialize(inPatmedicineList);
            }
            else
            {
                var groupTestSingleTestID = DBClass.getField
                    ("select Item_ID from Ar_Billing_Details where Bill_Details_ID = "
                    + billDetailID + "").ToString();
                var inPatmedicineList = (from pm in db.Lab_Test_Details
                                         join t in db.Lab_Tests
                                         on pm.Test_ID equals t.Test_ID
                                         where pm.Lab_Test_ID == LabID && pm.Test_ID.Equals(groupTestSingleTestID)
                                         select new
                                         {
                                             pm.Lab_Test_ID,
                                             pm.Test_ID,
                                             t.Test_Name,
                                             Lab_Test_Detail_ID = (from lbd in db.Lab_Test_Details
                                                                   where lbd.Lab_Test_ID == Convert.ToInt32(LabID) && lbd.Test_ID == pm.Test_ID
                                                                   select lbd.Lab_Test_Detail_ID).FirstOrDefault(),
                                             pm.Test_Value,
                                             pm.Is_Result,
                                             pm.Approved_By,
                                             pm.Test_Template,
                                             Group_CategoryName = db.GetDataValueName("Test Groups", t.Group_Category),
                                             Group_Department = db.GetDataValueName("Test Departments", t.Group_Department),
                                             Main_Department = db.GetDataValueName("Main Test Departments", t.Main_Department),
                                             pm.Status,
                                             pm.isApproved,
                                             pm.Diagnosis,
                                             pm.Notes,
                                             isSingleGroupTest = isSingleGroupTest,
                                             Fixed_Value = pm.Is_Result == true ? pm.Test_Template : t.Fixed_Value,
                                             t.Value_Type,
                                             t.Result_Type_Fixed,
                                             t.Result_Type_List,
                                             t.Result_Type_Value,
                                             pm.Result_Value,
                                             pm.Growth_Type,
                                             pm.Organism_Type,
                                             pm.Master_Remarks,
                                             resultValueList = (from p in db.Lab_Test_Multiple_Values
                                                                where p.Test_ID == t.Test_ID
                                                                select p.Value).ToList()
                                         }).ToList();
                returnData = (new JavaScriptSerializer()).Serialize(inPatmedicineList);
            }
            return returnData;
        }
        [WebMethod]
        public static string LoadOrganismList(int LabID, int globalTestId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var List = (from org in db.Result_Organisms
                            where org.Test_ID == globalTestId
                            select new
                            {
                                org.Organism_Name,
                                org.Organism_Value
                            }).ToList();

                return (new JavaScriptSerializer()).Serialize(List);
            }
            return "";
        }
    }
}