using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.ComTypes;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Lab
{
    public partial class RadiologyTestResult : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {


        }
        public class TesttList
        {
            public int Patient_ID { get; set; }
            public List<TesttListDetails> test_list { get; set; }
        }
        public class TesttListDetails
        {
            public string TestDID { get; set; }
            public string Value { get; set; }
            public string Diagnosis { get; set; }
            public string Notes { get; set; }
        }
        public void btnRefresh_Click(Object sender, EventArgs e)
        {

        }
        //public void buttonimageuploadNotes_Click(Object sender, EventArgs e)
        //{
        //    DataBaseDataContext db = new DataBaseDataContext();
        //    var count = Request.Files.Count;
        //    var detail_ID = session_obejct.Value;
        //    if (fileUploadMultiple.HasFile)
        //    {
        //        for (int i = 0; i < Request.Files.Count; i++)
        //        {
        //            HttpPostedFile fileUpload = Request.Files[i];

        //            Test_Image image = new Test_Image();
        //            int imageNo = Convert.ToInt32(DBClass.getField("Select isnull(Max(Image_No),0) + 1 from Test_Image where Lab_Test_Detail_ID = " + detail_ID + ""));

        //            string fname = HttpContext.Current.Server.MapPath("LabTestImg/" + imageNo + "-" + detail_ID + ".png");

        //            string image_Path = "LabTestImg/" + imageNo + "-" + detail_ID + ".png";

        //            if (System.IO.File.Exists(HttpContext.Current.Server.MapPath(image_Path)))
        //            {
        //                // file exist
        //                string savePath = HttpContext.Current.Server.MapPath(image_Path);
        //                System.IO.File.Delete(savePath);
        //                string sql = "delete from Test_Image where Image_path ='" + image_Path + "'";
        //                DBClass.executeNonQueryWithoutBegin(sql);
        //            }


        //            fileUpload.SaveAs(fname);
        //            image.Image_No = imageNo;
        //            image.Image_path = image_Path;
        //            image.Lab_Test_Detail_ID = Convert.ToInt32(detail_ID);
        //            db.Test_Images.InsertOnSubmit(image);
        //            db.SubmitChanges();
        //        }

        //    }
        //}


        [WebMethod]
        public static string CheckRadiologylistRights()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var ups = (from St in db.aspnet_Users
                       where St.UserId == AppConfig.UserID
                       select St.Radiology_result).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(ups);
        }
        [WebMethod]
        public static string CheckRadiologylistApprovalRights()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var ups = (from St in db.aspnet_Users
                       where St.UserId == AppConfig.UserID
                       select St.Radiology_result_Approval).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(ups);
        }
        [WebMethod]
        public static string CheckRadiologyAllListRights()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var ups = (from St in db.aspnet_Users
                       where St.UserId == AppConfig.UserID
                       select St.Allow_RadiologyAllList).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(ups);
        }
        public void buttonimageuploadNotes_Click(object sender, EventArgs e)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var detail_ID = session_obejct.Value;

            if (!fileUploadMultiple.HasFile)
                return;

            // New root folder
            string dirFullPath = Server.MapPath("~/wwwroot/images/RadiologyTestImg/");

            // Create directory if not exists
            if (!Directory.Exists(dirFullPath))
            {
                Directory.CreateDirectory(dirFullPath);
            }

            for (int i = 0; i < Request.Files.Count; i++)
            {
                HttpPostedFile fileUpload = Request.Files[i];

                Test_Image image = new Test_Image();
                Lab_Test_Detail ltd = new Lab_Test_Detail();

                // SAME OLD IMAGE NO LOGIC
                int imageNo = Convert.ToInt32(
                    DBClass.getField(
                        "SELECT ISNULL(MAX(Image_No),0) + 1 FROM Test_Image WHERE Lab_Test_Detail_ID = " + detail_ID
                    )
                );

                // SAME OLD FILE NAME
                string fileName = imageNo + "-" + detail_ID + ".png";

                // Physical path (NEW FOLDER)
                string physicalPath = Path.Combine(dirFullPath, fileName);

                // DB path (SAME STRUCTURE IDEA)
                string image_Path = "~../../../../wwwroot/images/RadiologyTestImg/" + fileName;

                // SAME OLD DELETE LOGIC
                if (File.Exists(physicalPath))
                {
                    File.Delete(physicalPath);

                    //string sql = "DELETE FROM Test_Image WHERE Image_path = '" + image_Path + "'";
                    //DBClass.executeNonQueryWithoutBegin(sql);
                }

                // Save file
                fileUpload.SaveAs(physicalPath);

                // Save DB record
                image.Image_No = imageNo;
                image.Image_path = image_Path;
                ltd.Image_path = image_Path;
                image.Lab_Test_Detail_ID = Convert.ToInt32(detail_ID);

                db.Test_Images.InsertOnSubmit(image);
                db.SubmitChanges();
            }
        }



        [WebMethod]
        public static string SaveGroupTest(int Lab_ID, List<GroupTestDetails> TesttDetails)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                foreach (var item in TesttDetails)
                {
                    var testPerformby = (from asp in db.aspnet_Users where asp.UserId == AppConfig.UserID select asp.UserName).FirstOrDefault();
                    Lab_Test_Detail labtest = (from t in db.Lab_Test_Details
                                               where t.Lab_Test_Detail_ID == int.Parse(item.lab_test_Detail_id)
                                               && t.Bill_Details_ID == Convert.ToInt32(item.BillDetailID)
                                               select t).FirstOrDefault();
                    labtest.Test_Template = item.fixed_values;
                    labtest.Result_Value = item.result_type;
                    labtest.Test_Value = item.value_type;
                    labtest.Growth_Type = item.Growthtype;
                    labtest.Organism_Type = item.OrganismType;
                    labtest.Master_Remarks = item.Master_Remarks;
                    labtest.Is_Result = true;
                    labtest.Created_Time = DateTime.Now;
                    labtest.Test_Performed_By = testPerformby;
                    labtest.Test_Status = "Created";
                    if (!string.IsNullOrEmpty(item.Refer_Doc_id))
                    {
                        labtest.Refer_Doctor = item.Refer_Doc_id; 
                    }

                    db.SubmitChanges();
                }
                return "Successfull";
            }
            catch (Exception ex)
            {

            }

            return "";
        }
        public class GroupTest
        {

            public List<GroupTestDetails> group_list { get; set; }
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
            public int BillDetailID { get; set; }

            public string Refer_Doc_id { get; set; }
        }
        [WebMethod]
        public static string SaveTestDetail(string valuetype, string valueofTemplate, string Lab_ID, string testDetailID, string CatID, string resultVal, string GrowthType, string GrowthTypeInfo, string OrganismType, string Master_Remarks, string Levels, string referDocId)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            Lab_Test_Detail test = (from t in db.Lab_Test_Details
                                    where t.Lab_Test_Detail_ID == int.Parse(testDetailID)
                                    select t).FirstOrDefault();
            test.Test_Template = valueofTemplate;
            test.Result_Value = resultVal;
            test.Test_Value = valuetype;
            test.Growth_Type = GrowthType;
            test.Organism_Type = OrganismType;
            test.Growth_Type_Info = GrowthTypeInfo;
            test.Master_Remarks = Master_Remarks;
            test.Is_Result = true;
            test.Test_Status = "Created";
            test.Levels = Levels;
            test.Created_Time = DateTime.Now;
            test.Test_Performed_By = AppConfig.UserName;
            if (!string.IsNullOrEmpty(referDocId))
            {
                test.Refer_Doctor = referDocId; 
            }

            db.SubmitChanges();

            return "Successfull";
        }

        private class Organism_List
        {
            public string OrgName;
            public string OrgValue;
            public int LabID;
        }

        [WebMethod]
        public static string SaveTestImages(string TestDetailID, string filename, int TestID, string ParentTransactionType, int Parent_Transaction_Type_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            Test_Image image = new Test_Image();
            image.Lab_Test_Detail_ID = Convert.ToInt32(TestDetailID);

            image.Test_ID = TestID;
            image.Image_path = filename.ToString();
            image.Parent_Transaction_Type_ID = Convert.ToInt32(Parent_Transaction_Type_ID);
            image.Parent_Transaction_Type = ParentTransactionType;

            db.Test_Images.InsertOnSubmit(image);
            db.SubmitChanges();
            return "Successfull";
        }
        [WebMethod]
        public static string SaveOrganismList(string[][] Organism_List, int Lab_test_ID, int bill_detailid)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext();
                string Query = "delete from Result_Organism where Lab_test_id='" + Lab_test_ID + "' and bill_detail_id='" + bill_detailid + "'";
                DBClass.executeNonQueryWithoutBegin(Query);
                if (Organism_List.Length > 0)
                {
                    for (int i = 0; i < Organism_List.Length; i++)
                    {
                        Result_Organism org = new Result_Organism();
                        var Organism_Name = Organism_List[i][0];
                        org.Organism_Value = Organism_List[i][1];
                        org.Organism_Name_Case2 = Organism_List[i][2];
                        org.Organism_Name_Case3 = Organism_List[i][3];
                        org.Organism_Name_Header = Organism_List[i][4];
                        org.Organism_Name_Case2_Header = Organism_List[i][5];
                        org.Organism_Name_Case3_Header = Organism_List[i][6];
                        org.Lab_Test_ID = Convert.ToInt32(Organism_List[i][7]);
                        org.Test_ID = Convert.ToInt32(Organism_List[i][8]);

                        var datavalueId = Convert.ToInt32(DBClass
                           .getField("select Datavalue_ID from DataValues where DataValue_Description LIKE '%"
                           + Organism_Name + "%' and ValueSet_ID = 2115"));
                        org.Organism_Name = Organism_Name;
                        org.Organism_Datavalue_ID = datavalueId;
                        org.bill_detail_id = bill_detailid;

                        db.Result_Organisms.InsertOnSubmit(org);
                        db.SubmitChanges();
                    }
                }
                else
                {
                    Result_Organism org = new Result_Organism();
                    org.Lab_Test_ID = Lab_test_ID;
                    org.bill_detail_id = bill_detailid;

                    db.Result_Organisms.InsertOnSubmit(org);
                    db.SubmitChanges();
                }
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
            return "";
        }

        [WebMethod]
        public static string LoadOrganismList(int LabID, int globalTestId, int billDetailID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                List<Result_Organism> lis = new List<Result_Organism>();
                var List = (from org in db.Result_Organisms
                            where org.Lab_Test_ID == LabID
                            && org.bill_detail_id == billDetailID
                            select new
                            {
                                org.Organism_Name,
                                org.Organism_Value,
                                org.Organism_Name_Case2,
                                org.Organism_Name_Case3,
                                org.Organism_Name_Header,
                                org.Organism_Name_Case2_Header,
                                org.Organism_Name_Case3_Header,
                                org.Test_ID

                            }).ToList();
                if (List.Count == 0 || List[0].Test_ID == null)
                {
                    List.Clear();
                }
                return (new JavaScriptSerializer()).Serialize(List);
            }
            return "";
        }
        [WebMethod]
        public static string RejectTestDetail(int Lab_ID, string TesttDetails, string RejectionRemarks)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var TesttDetailsID = js.Deserialize<TesttList>(TesttDetails);
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                string chkEditRights = DBClass.getField("select dbo.GetApprovalRights('AllowPatientApprove','" + AppConfig.UserID + "')");
                if (Convert.ToBoolean(chkEditRights) == true)
                {
                    foreach (var test in TesttDetailsID.test_list)
                    {
                        Lab_Test_Detail labtest = (from t in db.Lab_Test_Details
                                                   where t.Lab_Test_Detail_ID == int.Parse(test.TestDID)
                                                   select t).FirstOrDefault();

                        labtest.Result_ID = "0";
                        labtest.UnApproved_By = AppConfig.UserID;
                        labtest.UnApproved_Time = DateTime.Now;
                        labtest.isApproved = null;
                        labtest.Approved_By = null;
                        labtest.Rejected_Reason = RejectionRemarks;

                        db.SubmitChanges();
                    }
                    return "Reject Successfull";
                }
                else
                {
                    return "You have no Rights to Reject Test";
                }
            }
            catch (Exception ex)
            {
            }
            return "Not Successfull";
        }
        [WebMethod]
        public static string ApproveTestDetailCat(int Lab_ID, string TesttDetails, int ReferDoctorId = 0)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var TesttDetailsID = js.Deserialize<TesttList>(TesttDetails);
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

                foreach (var test in TesttDetailsID.test_list)
                {
                    Lab_Test_Detail labtest = (from t in db.Lab_Test_Details
                                               where t.Lab_Test_Detail_ID == int.Parse(test.TestDID)
                                               select t).FirstOrDefault();

                    if (labtest != null)
                    {
                        labtest.Result_ID = "0";
                        labtest.Approved_By = AppConfig.UserID;
                        labtest.Approved_Time = DateTime.Now;
                        labtest.isApproved = true;
                        labtest.Is_Result = true;

                        // Update Refer Doctor ID
                        if (ReferDoctorId > 0)
                        {
                            labtest.DoctorID = ReferDoctorId;
                        }

                        var PR = (from tbl in db.Lab_Test_Details
                                  where tbl.Recieved_ID == test.TestDID && tbl.Is_Result == false
                                  select tbl).FirstOrDefault();
                        if (PR != null)
                        {
                            PR.Is_Result = true;
                        }
                    }
                    db.SubmitChanges();
                }
                return "Successfull";
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }
        [WebMethod]
        public static string DeleteImage(string imagSrc)
        {
            string imageFilePath = HttpContext.Current.Server.MapPath(imagSrc);


            System.IO.File.Delete(imageFilePath);
            string splitedImageFilePAth = imagSrc.Split('/')[1];
            string sql = "delete from Test_Image where Image_path like '%" + splitedImageFilePAth + "%'";
            DBClass.executeNonQueryWithoutBegin(sql);
            return "Success";
        }
        [WebMethod]
        public static string getResultValues(int testidd)
        {
            string valuesList = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var resultValueList = (from p in db.Lab_Test_Multiple_Values where p.Test_ID == testidd select p.Value).ToList();
                if (resultValueList != null)
                {
                    valuesList = (new JavaScriptSerializer().Serialize(resultValueList));
                }
            }

            return valuesList;
        }

        [WebMethod]
        public static string ApproveTestDetail(string TestDetailID, string TestValue, string Template, string Diagnosis, string Notes)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            Lab_Test_Detail test = (from t in db.Lab_Test_Details
                                    where t.Lab_Test_Detail_ID == int.Parse(TestDetailID)
                                    select t).FirstOrDefault();
            if (test == null)
            {
                test = (from t in db.Lab_Test_Details
                        where t.Lab_Test_ID == int.Parse(TestDetailID)
                        select t).FirstOrDefault();

            }
            var ee = HttpContext.Current.Server.HtmlEncode(Template);


            test.Diagnosis = Diagnosis;
            test.Notes = Notes;
            test.Result_ID = "0";
            test.Is_Result = true;
            test.Approved_By = AppConfig.UserID;
            test.Approved_Time = DateTime.Now;
            test.isApproved = true;
            db.SubmitChanges();
            var dd = test.Lab_Test_Detail_ID;
            var P = (from tbl in db.Lab_Test_Details
                     where tbl.Recieved_ID == TestDetailID
                     select tbl).FirstOrDefault();
            if (P != null)
            {
                P.Is_Result = true;
                db.SubmitChanges();
            }
            return "Successfull";
        }

        [WebMethod]
        public static string LoadimagesDetail(string TestDetailID, string single)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            string folderPath = DBClass.getField("Select Segment3 from Sys_Parms where Name like '%Images Folder Path%'");
            var data = (from td in db.Test_Images

                        where td.Lab_Test_Detail_ID == int.Parse(TestDetailID)
                        select new
                        {
                            Image_path = td.Image_path.Replace("~/", string.Empty).Contains("RadiologyTestImg") == true ? td.Image_path.Replace("~/", string.Empty) : "RadiologyTestImg/" + td.Image_path.Replace("~/", string.Empty),
                            td.Lab_Test_Detail_ID,
                            Single = single
                        }).ToList();
            if (data.Count != 0)
            {


            }
            return (new JavaScriptSerializer().Serialize(data));
        }

        public class TestDetail
        {

            public string Approved_By;
            public int Parent_Transaction_Type_ID;
            public string Parent_Transaction_Type;
            public string TestName;
            public string Department;
            public string Test_Template;
            public string Main;
            public string Result_ID;
            public bool Is_Result;
            public string Result_Value;
            public string Image_path;
            public string Group;
            public bool? Status;
            public string ValueType;
            public string Template;
            public string Diagnosiss;
            public string notes;
            public string Test_Values;
            public int Test_ID;
            public string isApproved;
            public string GrowthType;
            public string OrganismType;


        }
        [WebMethod]
        //Pop up show Single Test
        public static string GetTestDetail(string TestDetailID, string LabID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var patientGender = (from p in db.Reg_patients where p.pat_id == (from l in db.Laboratory_Tests where l.Lab_Test_ID == Convert.ToInt32(LabID) select l.Patient_ID).FirstOrDefault() select p.Gender).FirstOrDefault();
            if (patientGender == "F")
            { patientGender = "2"; }
            else if (patientGender == "M")
            { patientGender = "1"; }
            else if (patientGender == "C")
            { patientGender = "3"; }
            List<string> listObj = new List<string>();

            var data = (from td in db.Lab_Test_Details
                        join t in db.Lab_Tests
                        on td.Test_ID equals t.Test_ID

                        where td.Lab_Test_Detail_ID == int.Parse(TestDetailID)
                        select new
                        {
                            TestName = t.Test_Name,
                            Department = db.GetDataValueName("Test Departments", t.Group_Department),
                            Main = db.GetDataValueName("Main Test Departments", t.Main_Department),
                            Group = db.GetDataValueName("Test Groups", t.Group_Category),
                            Status = td.Status,
                            Is_Result = td.Is_Result,
                            Is_Cultural = t.Is_Cultural,
                            Diagnosis = td.Diagnosis,
                            Notes = td.Notes,
                            td.Result_Value,
                            Ranges = (from v in db.Test_Values where v.Test_ID == t.Test_ID && v.Patient_Type == patientGender select v.Start_Range + " - " + v.End_Range).FirstOrDefault(),

                            AllRange = (from v in db.Test_Values where v.Test_ID == t.Test_ID && v.Patient_Type == "6" select v.Start_Range + " - " + v.End_Range).FirstOrDefault(),

                            Test_Template = td.Is_Result == true ? td.Test_Template : t.Fixed_Value,
                            t.Result_Type_Value,
                            t.Result_Type_Fixed,
                            t.Result_Type_List,
                            td.Test_Value,
                            td.Master_Remarks,
                            Fixed_Value = td.Is_Result == true ? td.Test_Template : t.Fixed_Value,
                            td.Growth_Type,
                            td.Organism_Type,
                            td.Levels,
                            t.Result_Type_Image,
                            Is_Approve = td.isApproved == null ? false : true,
                            td.Refer_Doctor,



                        }).ToList();

            listObj.Add(data[0].TestName); //0
            listObj.Add(data[0].Department);  //1
            listObj.Add(data[0].Main); //2
            listObj.Add(data[0].Group); //3
            listObj.Add(data[0].Status.ToString()); //4
            listObj.Add(data[0].Is_Result.ToString()); //5
            listObj.Add(data[0].Diagnosis); //6
            listObj.Add(data[0].Notes); //7
            listObj.Add(data[0].Result_Value); //8
            listObj.Add(data[0].Test_Template); //9
            listObj.Add(data[0].Result_Type_Value.ToString()); //10
            listObj.Add(data[0].Result_Type_Fixed.ToString()); //11
            listObj.Add(data[0].Result_Type_List.ToString()); //12
            listObj.Add(data[0].Test_Value); //13
            listObj.Add(data[0].Fixed_Value); //14
            listObj.Add(data[0].Growth_Type); //15
            listObj.Add(data[0].Organism_Type); //16
            listObj.Add(data[0].Master_Remarks);  // 17
            listObj.Add(data[0].Is_Cultural.ToString()); //18
            listObj.Add(data[0].Ranges);//19
            listObj.Add(data[0].AllRange);//20
          

            var Test_ID = db.Lab_Test_Details.Where(m => m.Lab_Test_Detail_ID == Convert.ToInt32(TestDetailID)).Select(m => m.Test_ID).FirstOrDefault();

            listObj.Add(Test_ID.ToString()); //13

            var Value_Type = db.Lab_Tests.Where(m => m.Test_ID == Test_ID).Select(m => m.Value_Type).FirstOrDefault();
            var Check_Level = db.Lab_Tests.Where(x => x.Test_ID == Test_ID).Select(m => m.Chk_Levels).FirstOrDefault();

            listObj.Add(Value_Type); //14
            listObj.Add(Check_Level.ToString());//21

            listObj.Add(data[0].Is_Approve.ToString()); //22


            listObj.Add(data[0].Levels);
            listObj.Add(data[0].Result_Type_Image.ToString());
            listObj.Add(data[0].Is_Result.ToString()); //28
            listObj.Add(data[0].Refer_Doctor ?? "");
            return (new JavaScriptSerializer().Serialize(listObj));
        }


        public class TestValues
        {
            public string Value_Type { get; set; }
            public string Fixed_Value { get; set; }
            public string Start_Range { get; set; }
            public string End_Range { get; set; }
            public string Patient_Type { get; set; }
            public string Test_Name { get; set; }
            public string Department { get; set; }
            public string Main { get; set; }
            public string Group { get; set; }
            public string Status { get; set; }
            public string Test_ID { get; set; }


        }
        [WebMethod]

        public static string LoadTestCatogry(int LabID, string CatID, int billDetailID)
        {
            string returnData = string.Empty;
            bool isSingleGroupTest = false;
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var patientGender = (from p in db.Reg_patients where p.pat_id == (from l in db.Laboratory_Tests where l.Lab_Test_ID == LabID select l.Patient_ID).FirstOrDefault() select p.Gender).FirstOrDefault();
                if (patientGender == "F")
                { patientGender = "2"; }
                else if (patientGender == "M")
                { patientGender = "1"; }
                else if (patientGender == "C")
                { patientGender = "3"; }

                var categoryFromBill = DBClass.getField("select Category_ID from Ar_Billing_Details where Bill_Details_ID = " + billDetailID + "").ToString();
                var isGroup = DBClass.getField("select Is_Group_Category from Ar_Billing_Details where Bill_Details_ID = " + billDetailID + "").ToString();
                if (categoryFromBill == string.Empty)
                {
                    CatID = "0";
                }

                var DataValue_Name = db.DataValues.Where(m => m.DataValue_ID.Equals(CatID)).Select(m => m.DataValue_Name).FirstOrDefault();
                if (DataValue_Name == null)
                {
                    DataValue_Name = db.Lab_Tests.Where(x => x.Test_ID.Equals(CatID)).Select(x => x.Group_Category).FirstOrDefault();
                    if (DataValue_Name != null)
                        isSingleGroupTest = true;
                }
                if (isGroup == Convert.ToString(true))
                {
                    if (!CatID.Equals("0"))
                    {
                        var inPatmedicineList = (from pm in db.Lab_Test_Details
                                                 join t in db.Lab_Tests
                                                 on pm.Test_ID equals t.Test_ID
                                                 join b in db.Ar_Billing_Details
                                                 on pm.Bill_Details_ID equals b.Bill_Details_ID
                                                 where b.Is_Group_Category == true && t.Group_Category == DataValue_Name && pm.Lab_Test_ID == LabID && pm.Bill_Details_ID == billDetailID
                                                 orderby t.Group_Order
                                                 select new
                                                 {
                                                     pm.Lab_Test_ID,
                                                     pm.Test_ID,
                                                     t.Test_Name,
                                                     Lab_Test_Detail_ID = (from lbd in db.Lab_Test_Details where lbd.Lab_Test_ID == Convert.ToInt32(LabID) && lbd.Test_ID == pm.Test_ID && lbd.Bill_Details_ID == billDetailID select lbd.Lab_Test_Detail_ID).FirstOrDefault(),
                                                     Ranges = (from v in db.Test_Values where v.Test_ID == t.Test_ID && v.Patient_Type == patientGender select v.Start_Range + " - " + v.End_Range).FirstOrDefault(),

                                                     AllRange = (from v in db.Test_Values
                                                                 where v.Test_ID == t.Test_ID
                                                                 && v.Patient_Type == "6"
                                                                 select v.Start_Range + " - " + v.End_Range)
                                                                 .FirstOrDefault(),


                                                     pm.Test_Value,
                                                     pm.Is_Result,
                                                     pm.Levels,
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
                                                     b.Bill_Details_ID,

                                                     resultValueList = (from p in db.Lab_Test_Multiple_Values where p.Test_ID == t.Test_ID select p.Value).ToList(),
                                                     FixedValue = (from dt in db.DataValues where dt.ValueSet_ID == 70 && dt.DataValue_Name == t.Group_Category select dt.Fixed_Value).FirstOrDefault(),
                                                     Resultvalue = (from dt in db.DataValues where dt.ValueSet_ID == 70 && dt.DataValue_Name == t.Group_Category select dt.Result_Value).FirstOrDefault(),
                                                     ListValue = (from dt in db.DataValues where dt.ValueSet_ID == 70 && dt.DataValue_Name == t.Group_Category select dt.List_Value).FirstOrDefault(),
                                                     ReqImage = (from dt in db.DataValues where dt.ValueSet_ID == 70 && dt.DataValue_Name == t.Group_Category select dt.Required_Value).FirstOrDefault(),
                                                     Is_Approve = pm.isApproved == null ? false : true
                                                 }).ToList();

                        returnData = (new JavaScriptSerializer()).Serialize(inPatmedicineList);
                    }
                }
                else
                {

                    var groupTestSingleTestID = (from b in db.Ar_Billing_Details where b.Bill_Details_ID == billDetailID select b.Item_ID).FirstOrDefault();
                    var inPatmedicineList = (from pm in db.Lab_Test_Details
                                             join t in db.Lab_Tests
                                             on pm.Test_ID equals t.Test_ID
                                             join b in db.Ar_Billing_Details
                                            on pm.Bill_Details_ID equals b.Bill_Details_ID

                                             where pm.Bill_Details_ID == billDetailID
                                             && b.Is_Group_Category == false
                                             && pm.Lab_Test_ID == LabID
                                             && pm.Test_ID.Equals(groupTestSingleTestID)
                                             select new
                                             {
                                                 pm.Lab_Test_ID,
                                                 pm.Test_ID,
                                                 t.Test_Name,

                                                 Lab_Test_Detail_ID = (from lbd in db.Lab_Test_Details
                                                                       where lbd.Lab_Test_ID == Convert.ToInt32(LabID) && lbd.Bill_Details_ID == billDetailID
                                                                       && lbd.Test_ID == pm.Test_ID
                                                                       select lbd.Lab_Test_Detail_ID).FirstOrDefault(),
                                                 Ranges = (from v in db.Test_Values
                                                           where v.Test_ID == t.Test_ID
                                                           && v.Patient_Type == patientGender
                                                           select v.Start_Range + " - " + v.End_Range).FirstOrDefault(),
                                                 AllRange = (from v in db.Test_Values
                                                             where v.Test_ID == t.Test_ID
                                                             && v.Patient_Type == "6"
                                                             select v.Start_Range + " - " + v.End_Range).FirstOrDefault(),

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
                                                 b.Bill_Details_ID,

                                                 resultValueList = (from p in db.Lab_Test_Multiple_Values
                                                                    where p.Test_ID == t.Test_ID
                                                                    select p.Value).ToList(),
                                                 FixedValue = (from dt in db.DataValues where dt.ValueSet_ID == 70 && dt.DataValue_Name == t.Group_Category select dt.Fixed_Value).FirstOrDefault(),
                                                 Resultvalue = (from dt in db.DataValues where dt.ValueSet_ID == 70 && dt.DataValue_Name == t.Group_Category select dt.Result_Value).FirstOrDefault(),
                                                 ListValue = (from dt in db.DataValues where dt.ValueSet_ID == 70 && dt.DataValue_Name == t.Group_Category select dt.List_Value).FirstOrDefault(),
                                                 ReqImage = (from dt in db.DataValues where dt.ValueSet_ID == 70 && dt.DataValue_Name == t.Group_Category select dt.Required_Value).FirstOrDefault(),
                                                 Is_Approve = pm.isApproved == null ? false : true
                                             }).ToList();

                    returnData = (new JavaScriptSerializer()).Serialize(inPatmedicineList);
                }
            }
            return returnData;
        }

        [WebMethod]
        public static string GetSubTestIDs(string Group_Category)
        {
            string ListOfSubTestIDs = DBClass.getField("select dbo.[GetGroupSubTests]('" + Group_Category + "')");

            return ListOfSubTestIDs;
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static string checkLab_rights()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var user = (from St in db.aspnet_Users
                        where St.UserName == AppConfig.UserName
                        select new
                        {
                            St.allow_lab,
                            St.allow_ultra,
                            St.allow_ctscan,
                            St.allow_xray,
                            St.allow_b_bank,
                        }).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(user);
        }

        [WebMethod]
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
                pt.Age = pat.Age_years?.ToString() ?? "";
                if (pat.Created_time.HasValue)
                    pt.Entry_Date = pat.Created_time.ToString();

                pt.Mobile = pat.Mobile1;


                var isIPD = (from ipd in db.In_Patients
                             where ipd.Patient_ID == pat.pat_id && (ipd.Discharge == null || ipd.Discharge == false)
                             orderby ipd.In_Patient_ID descending
                             select ipd.In_Patient_ID).FirstOrDefault();
                var isEmergency = (from ipd in db.Emergency_Patients
                                   where ipd.Patient_ID == pat.pat_id && (ipd.Discharge == null || ipd.Discharge == false)
                                   orderby ipd.Emergency_ID descending
                                   select ipd.Emergency_ID).FirstOrDefault();
                if (isIPD != 0)
                {
                    var Locations = DBClass.getField("Select Concat (wd.Ward_Type,' / ',ipd.Bed_No) from In_Patient ipd join Ward_Definition wd on ipd.Ward_ID = wd.Ward_ID where ipd.In_Patient_ID =" + isIPD + "order by ipd.In_Patient_ID desc");
                    var Department = DBClass.getField("Select dbo.GetDataValueName('Patient Main Category', ipd.Department) AS Department from In_Patient ipd  where ipd.In_Patient_ID =" + isIPD + "order by ipd.In_Patient_ID desc");
                    pt.Location = Locations;
                    pt.Patient_Category = "IPD";
                    pt.Department = Department;
                }
                else if (isEmergency != 0)
                {
                    pt.Location = DBClass.getField("Select Concat (wd.Ward_Type,' / ',ipd.Bed_No) from Emergency_Patient ipd join Ward_Definition wd on ipd.Ward_ID = wd.Ward_ID where ipd.Emergency_ID =" + isEmergency + "order by ipd.Emergency_ID desc");
                    pt.Patient_Category = "Emergency";
                    pt.Department = "";
                }
                else
                {
                    var Department = DBClass.getField("Select dbo.GetDataValueName('Patient Main Category', p.Patient_Main_Category) AS Department from Patients p  where p.Reg_PatId =" + pat.pat_id + "order by p.Patient_ID desc");
                    pt.Location = "";
                    pt.Department = Department;
                    pt.Patient_Category = "OPD";
                }

                pt.Gender = db.GetDataValueName("Gender", pat.Gender);
                return pt;
            }
            else
                return pt;
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
            public string patient_ID { get; set; }
            public string Rejected_Reason { get; set; }

            public string Report_Colum { get; set; }
            public string Service_Date { get; set; }
            public bool Is_Approve { get; set; }
            public string Test_Main_Department { get; set; }

            public string Test_Performed_By { get; set; }
            public string Result_Time { get; set; }
            public string Approved_By { get; set; }
            public string Approved_Time { get; set; }
            public string TestDepartment { get; set; }

            public string History { get; set; }
        }
        [WebMethod]
        public static string FillTestDepartment()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Test Departments"
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
        public static string GetLabDetailByBill_id(string Patient_ID, int Bill_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            db.CommandTimeout = 180;
            var patientNo = (from p in db.Reg_patients where p.pat_id == Convert.ToInt32(Patient_ID) select p.Patient_No).FirstOrDefault();
            var patientIDs = (from p in db.Reg_patients where p.Patient_No == patientNo select p.pat_id).ToList();
            //Individual Tests
            var data = (from lt in db.Laboratory_Tests
                        join ltd in db.Lab_Test_Details
                        on lt.Lab_Test_ID equals ltd.Lab_Test_ID
                        join tdef in db.Lab_Tests
                        on ltd.Test_ID equals tdef.Test_ID
                        join pa in db.Reg_patients
                        on lt.Patient_ID equals pa.pat_id

                        join bd in db.Ar_Billing_Details

                        on ltd.Bill_Details_ID equals bd.Bill_Details_ID
                        join ar in db.Ar_Billings on bd.Bill_ID equals ar.Bill_ID
                        where ar.Bill_ID == (Bill_ID == 0 ? ar.Bill_ID : Bill_ID)


                        && (bd.Is_Group_Category == null ? false : bd.Is_Group_Category) == false
                        && (bd.Test_Main_Department == null || bd.Test_Main_Department != "001")

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
                            ltd.History,
                            ltd.Emergancy,
                            ltd.L_R_Rotation_ID,
                            tdef.Group_Category,
                            DepartmentName = (db.GetDataValueName("Main Test Departments", tdef.Main_Department) == null ? "" : db.GetDataValueName("Main Test Departments", tdef.Main_Department)),
                            GroupName = (db.GetDataValueName("Test Groups", tdef.Group_Category) == null ? "" : db.GetDataValueName("Test Groups", tdef.Group_Category)),
                            Rotation = db.GetDataValueName("Test XRay Rotations", ltd.Rotation_ID),
                            Unit_Name = (db.GetDataValueName("Test Units", tdef.Unit) == null ? "" : db.GetDataValueName("Test Units", tdef.Unit)),
                            TestDepartment = (db.GetDataValueName("Test Departments", tdef.Group_Department) == null ? "" : db.GetDataValueName("Test Departments", tdef.Group_Department)),
                            tdef.Value_Type,
                            Status = ltd.Status == null ? false : true,
                            ltd.Image_path,
                            ltd.Is_Result,
                            ltd.Bill_Details_ID,
                            ltd.Rejected_Reason,
                            tdef.Report_Colum,
                            bd.Service_Date,

                            ltd.isApproved,
                            lt.Patient_ID,
                            bd.Test_Main_Department,
                            ltd.Test_Performed_By,
                            ltd.Created_Time,
                            ltd.Approved_Time,
                            Approved_By = (from asp in db.aspnet_Users
                                           where asp.UserId == ltd.Approved_By
                                           select asp.UserName).FirstOrDefault()

                        }).ToList();

            List<Test> AlltestList = new List<Test>();
            List<Test> AlltestListRefined = new List<Test>();

            foreach (var item in data)
            {
                Test test = new Test();
                test.Lab_Test_Detail_ID = item.Lab_Test_Detail_ID.ToString();

                test.Lab_Test_ID = item.Lab_Test_ID.ToString();
                test.Test_ID = item.Test_ID.ToString();
                test.Test_Name = item.Test_Name;
                test.DepartmentName = item.DepartmentName;
                test.Group_Category = item.Group_Category;
                test.TestDepartment = item.TestDepartment;
                test.History = item.History?.ToString() ?? "";
                test.GroupName = item.GroupName;
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
                if (item.isApproved != null)
                {
                    test.Is_Approve = (bool)item.isApproved;
                }
                else
                {
                    test.Is_Approve = false;
                }
                test.Rotation_ID = item.Rotation_ID;
                test.Rotation = item.Rotation;
                test.Unit_Name = item.Unit_Name;
                test.ValueType = item.Value_Type;
                test.Status = (bool)item.Status;
                test.Parent_Transaction_Type = item.Parent_Transaction_Type;
                test.Parent_Transaction_Type_ID = Convert.ToInt32(item.Parent_Transaction_Type_ID);
                test.Bill_Details_ID = item.Bill_Details_ID.ToString();
                test.Rejected_Reason = item.Rejected_Reason;
                test.Report_Colum = item.Report_Colum;
                test.Service_Date = item.Service_Date.ToString();

                test.patient_ID = Convert.ToString(item.Patient_ID);
                test.Test_Performed_By = item.Test_Performed_By ?? "";
                test.Result_Time = item.Created_Time?.ToString() ?? "";
                test.Approved_By = item.Approved_By ?? "";
                test.Approved_Time = item.Approved_Time?.ToString() ?? "";
                if (item.Test_Main_Department == null)
                {
                    test.Test_Main_Department = "";
                }
                else
                {
                    test.Test_Main_Department = item.Test_Main_Department.ToString();
                }

                AlltestList.Add(test);
            }

            AlltestListRefined = AlltestList;

            DataTable GroupTest = DBClass.getDataTable(@"
    SELECT 
        MIN(ld.Lab_Test_ID) AS Lab_Test_ID,
        dv.Segment2,
        dv.Datavalue_ID AS Test_ID,
        lt.Group_Category,
        dbo.GetDataValueName('Test Groups', lt.Group_Category) AS Group_Test_Name,
        MIN(ld.Test_Performed_By) AS Test_Performed_By,
        CONVERT(varchar(16), ld.Created_Time, 120) AS Test_Ready_On,
        MIN(ld.Approved_Time) AS Approved_Time,
        (SELECT TOP 1 UserName 
         FROM aspnet_Users u 
         WHERE u.UserId = ld.Approved_By) AS Approved_By,
        MIN(bd.Bill_Details_ID) AS Bill_Details_ID,
        MIN(ld.Rejected_Reason) AS Rejected_Reason,
        MIN(bd.Service_Date) AS Service_Date,
        CAST(MAX(CAST(ISNULL(ld.isApproved, 0) AS INT)) AS BIT) AS IsApproved,
        CAST(MAX(CAST(ISNULL(ld.Is_Result, 0) AS INT)) AS BIT) AS Is_Result,
        MIN(ltm.Patient_ID) AS Patient_ID,
        MIN(bd.Test_Main_Department) AS Test_Main_Department,
        dbo.GetDataValueName('Test Departments', lt.Group_Department) AS Test_Department,
        MIN(ld.History) AS History
        FROM Lab_Test_Detail ld
        JOIN Lab_Tests lt ON lt.Test_ID = ld.Test_ID
        JOIN Laboratory_Test ltm ON ltm.Lab_Test_ID = ld.Lab_Test_ID
        JOIN AR_Billing_Details bd ON bd.Bill_Details_ID = ld.Bill_Details_ID
        JOIN Ar_Billings ar ON ar.Bill_ID = bd.Bill_ID
        LEFT JOIN Datavalues dv 
          ON dv.Datavalue_Name = lt.Group_Category 
          AND dv.ValueSet_ID = 70
    WHERE ISNULL(bd.Is_Group_Category, 0) = 1 
     
      AND ar.Bill_ID = " + Bill_ID + @"
    GROUP BY lt.Group_Category, dv.Segment2, dv.Datavalue_ID, ld.Approved_By,lt.Group_Department,CONVERT(varchar(16), ld.Created_Time, 120)
");

            foreach (DataRow item in GroupTest.Rows)
            {
                Test TestObj = new Test()
                {

                    Lab_Test_ID = item[0] == DBNull.Value ? "" : item[0].ToString(),
                    Report_Colum = item[1] == DBNull.Value ? "" : item[1].ToString(),
                    Test_ID = item[2] == DBNull.Value ? "" : item[2].ToString(),
                    Group_Category = item[3] == DBNull.Value ? "" : item[3].ToString(),
                    Test_Name = item[4] == DBNull.Value ? "" : item[4].ToString(),
                    Bill_Details_ID = item[9] == DBNull.Value ? "" : item[9].ToString(),
                    Is_Result = Convert.ToBoolean(item[13] == DBNull.Value ? "" : item[13]),
                    Rejected_Reason = item[10] == DBNull.Value ? "" : item[10].ToString(),
                    Service_Date = item[11] == DBNull.Value ? "" : item[11].ToString(),
                    Is_Approve = Convert.ToBoolean(item[12] == DBNull.Value ? "" : item[12]),
                    patient_ID = item[14] == DBNull.Value ? "" : item[14].ToString(),
                    Test_Main_Department = item[15] == DBNull.Value ? "" : item[15].ToString(),
                    Test_Performed_By = item[5] == DBNull.Value ? "" : item[5].ToString(),
                    Result_Time = item[6] == DBNull.Value ? "" : Convert.ToDateTime(item[6]).ToString(),
                    Approved_Time = item[7] == DBNull.Value ? "" : Convert.ToDateTime(item[7]).ToString(),
                    Approved_By = item[8] == DBNull.Value ? "" : item[8].ToString(),
                    TestDepartment = item[16] == DBNull.Value ? "" : item[16].ToString(),

                };

                TestObj.ListOfTestIDs = DBClass.getField("select dbo.[GetGroupSubTests]('" + TestObj.Group_Category + "')");

                AlltestListRefined.Add(TestObj);
            }
            return (new JavaScriptSerializer()).Serialize(AlltestListRefined);
        }

        [WebMethod]
        public static string GetLabDetailByBillDetailId(int Bill_Details_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            db.CommandTimeout = 180;

            var data = (from lt in db.Laboratory_Tests
                        join ltd in db.Lab_Test_Details on lt.Lab_Test_ID equals ltd.Lab_Test_ID
                        join tdef in db.Lab_Tests on ltd.Test_ID equals tdef.Test_ID
                        join pa in db.Reg_patients on lt.Patient_ID equals pa.pat_id
                        join bd in db.Ar_Billing_Details on ltd.Bill_Details_ID equals bd.Bill_Details_ID
                        join ar in db.Ar_Billings on bd.Bill_ID equals ar.Bill_ID
                        where bd.Bill_Details_ID == Bill_Details_ID
                          && (bd.Test_Main_Department == "002" || bd.Test_Main_Department == "003" || bd.Test_Main_Department == "004") // Radiology only
                        select new
                        {
                            lt.Parent_Transaction_Type,
                            lt.Parent_Transaction_Type_ID,
                            lt.Lab_Test_ID,
                            tdef.Test_ID,
                            ltd.Lab_Test_Detail_ID,
                            tdef.Test_Name,
                            ltd.Emergancy,
                            tdef.Group_Category,
                            TestDepartment = db.GetDataValueName("Test Departments", tdef.Group_Department) ?? "",
                            tdef.Value_Type,
                            Status = ltd.Status ?? false,
                            ltd.Is_Result,
                            ltd.Bill_Details_ID,
                            ltd.Rejected_Reason,
                            tdef.Report_Colum,
                            bd.Service_Date,
                            ltd.isApproved,
                            lt.Patient_ID,
                            bd.Test_Main_Department,
                            ltd.Test_Performed_By,
                            ltd.Created_Time,
                            ltd.Approved_Time,
                            Approved_By = (from asp in db.aspnet_Users
                                           where asp.UserId == ltd.Approved_By
                                           select asp.UserName).FirstOrDefault(),
                         //   LabNo = ar.Lab_No ?? ""
                        }).ToList();

            var refined = data.Select(item => new Test
            {
                Lab_Test_Detail_ID = item.Lab_Test_Detail_ID.ToString(),
                Lab_Test_ID = item.Lab_Test_ID.ToString(),
                Test_ID = item.Test_ID.ToString(),
                Test_Name = item.Test_Name,
                Group_Category = item.Group_Category ?? "",
                TestDepartment = item.TestDepartment,
                Is_Result = item.Is_Result ?? false,
                Emergancy = item.Emergancy ?? false,
                ValueType = item.Value_Type,
                Status = item.Status,
                Parent_Transaction_Type = item.Parent_Transaction_Type,
                Parent_Transaction_Type_ID = Convert.ToInt32(item.Parent_Transaction_Type_ID),
                Bill_Details_ID = item.Bill_Details_ID.ToString(),
                Rejected_Reason = item.Rejected_Reason ?? "",
                Report_Colum = item.Report_Colum ?? "",
                Service_Date = item.Service_Date.ToString(),
                Is_Approve = item.isApproved ?? false,
                patient_ID = item.Patient_ID.ToString(),
                Test_Main_Department = item.Test_Main_Department ?? "",
                Test_Performed_By = item.Test_Performed_By ?? "",
                Result_Time = item.Created_Time?.ToString() ?? "",
                Approved_By = item.Approved_By ?? "",
                Approved_Time = item.Approved_Time?.ToString() ?? "",
               // LabNo = item.LabNo
            }).ToList();

            return new JavaScriptSerializer().Serialize(refined);
        }

        [WebMethod]
        public static string GetLabDetail(string Patient_ID, int LabTestID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var patientNo = (from p in db.Reg_patients where p.pat_id == Convert.ToInt32(Patient_ID) select p.Patient_No).FirstOrDefault();
            var patientIDs = (from p in db.Reg_patients where p.Patient_No == patientNo select p.pat_id).ToList();

            var data = (from lt in db.Laboratory_Tests
                        join ltd in db.Lab_Test_Details
                        on lt.Lab_Test_ID equals ltd.Lab_Test_ID
                        join tdef in db.Lab_Tests
                        on ltd.Test_ID equals tdef.Test_ID
                        join pa in db.Reg_patients
                        on lt.Patient_ID equals pa.pat_id
                        join bd in db.Ar_Billing_Details
                        on ltd.Bill_Details_ID equals bd.Bill_Details_ID


                        where

                        pa.pat_id == Convert.ToInt32(Convert.ToString(Patient_ID))
                        && (bd.Is_Group_Category == null ? false : bd.Is_Group_Category) == false
                         && (bd.Test_Main_Department == null || bd.Test_Main_Department != "001")

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
                            DepartmentName = (db.GetDataValueName("Main Test Departments", tdef.Main_Department) == null ? "" : db.GetDataValueName("Main Test Departments", tdef.Main_Department)),
                            GroupName = (db.GetDataValueName("Test Groups", tdef.Group_Category) == null ? "" : db.GetDataValueName("Test Groups", tdef.Group_Category)),
                            Rotation = db.GetDataValueName("Test XRay Rotations", ltd.Rotation_ID),
                            Unit_Name = (db.GetDataValueName("Test Units", tdef.Unit) == null ? "" : db.GetDataValueName("Test Units", tdef.Unit)),
                            TestDepartment = (db.GetDataValueName("Test Departments", tdef.Group_Department) == null ? "" : db.GetDataValueName("Test Departments", tdef.Group_Department)),
                            tdef.Value_Type,
                            Status = ltd.Status == null ? false : true,
                            ltd.Image_path,
                            ltd.Is_Result,
                            ltd.Bill_Details_ID,
                            ltd.Rejected_Reason,
                            tdef.Report_Colum,
                            bd.Service_Date,
                            ltd.isApproved,
                            lt.Patient_ID,
                            bd.Test_Main_Department,
                            ltd.Test_Performed_By,
                            ltd.Created_Time,
                            ltd.Approved_Time,
                            ltd.History,
                            Approved_By = (from asp in db.aspnet_Users
                                           where asp.UserId == ltd.Approved_By
                                           select asp.UserName).FirstOrDefault()
                        }).ToList();

            List<Test> AlltestList = new List<Test>();
            List<Test> AlltestListRefined = new List<Test>();

            foreach (var item in data)
            {
                Test test = new Test();
                test.Lab_Test_Detail_ID = item.Lab_Test_Detail_ID.ToString();

                test.Lab_Test_ID = item.Lab_Test_ID.ToString();
                test.Test_ID = item.Test_ID.ToString();
                test.Test_Name = item.Test_Name;
                test.DepartmentName = item.DepartmentName;
                test.Group_Category = item.Group_Category;
                test.TestDepartment = item.TestDepartment;
                test.History = item.History?.ToString() ?? "";
                test.GroupName = item.GroupName;
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
                test.Rejected_Reason = item.Rejected_Reason;
                test.Report_Colum = item.Report_Colum;
                test.Service_Date = item.Service_Date.ToString();
                if (item.isApproved != null)
                {
                    test.Is_Approve = (bool)item.isApproved;
                }
                else
                {
                    test.Is_Approve = false;
                }
                if (item.Test_Main_Department == null)
                {
                    test.Test_Main_Department = "0";
                }
                else
                {
                    test.Test_Main_Department = item.Test_Main_Department.ToString();
                }
                test.patient_ID = Convert.ToString(item.Patient_ID);
                test.Test_Performed_By = item.Test_Performed_By ?? "";
                test.Result_Time = item.Created_Time?.ToString() ?? "";
                test.Approved_By = item.Approved_By ?? "";
                test.Approved_Time = item.Approved_Time?.ToString() ?? "";
                AlltestList.Add(test);
            }

            AlltestListRefined = AlltestList;
            DataTable GroupTest = DBClass.getDataTable(@"
   SELECT 
    Distinct (ld.Lab_Test_ID) AS Lab_Test_ID,
    dv.Segment2,
    dv.Datavalue_ID AS Test_ID,
    lt.Group_Category,
    dbo.GetDataValueName('Test Groups', lt.Group_Category) AS Group_Test_Name,
    (ld.Test_Performed_By) AS Test_Performed_By,
    CONVERT(varchar(16), ld.Created_Time, 120) AS Test_Ready_On,
    CONVERT(varchar(5), ld.Approved_Time, 108) AS Approved_Time,

    (SELECT TOP 1 UserName 
     FROM aspnet_Users u 
     WHERE u.UserId = ld.Approved_By) AS Approved_By,
    (bd.Bill_Details_ID) AS Bill_Details_ID,
    CAST((CAST(ISNULL(ld.Is_Result, 0) AS INT)) AS BIT) AS Is_Result,
    (ld.Rejected_Reason) AS Rejected_Reason,
    (bd.Service_Date) AS Service_Date,
    CAST((CAST(ISNULL(ld.isApproved, 0) AS INT)) AS BIT) AS IsApproved,
    (ltm.Patient_ID) AS patient_id,
    (ISNULL(bd.Test_Main_Department, '')) AS Test_Main_Department,
    ld.History AS History,
    dbo.GetDataValueName('Test Departments', lt.Group_Department) AS Test_Department
    FROM Lab_Test_Detail ld
    JOIN Lab_Tests lt ON lt.Test_ID = ld.Test_ID
    JOIN Laboratory_Test ltm ON ltm.Lab_Test_ID = ld.Lab_Test_ID
    JOIN AR_Billing_Details bd ON bd.Bill_Details_ID = ld.Bill_Details_ID
    JOIN Reg_patient pat ON ld.Patient_ID = pat.pat_id
    LEFT JOIN Datavalues dv 
          ON dv.Datavalue_Name = lt.Group_Category 
          AND dv.ValueSet_ID = 70
    WHERE ISNULL(bd.Is_Group_Category, 0) = 1
          AND pat.Patient_No = (CASE WHEN " + patientNo + @" = 0 THEN pat.Patient_No ELSE " + patientNo + @" END)
       
");

            foreach (DataRow item in GroupTest.Rows)
            {
                Test TestObj = new Test()
                {

                    Lab_Test_ID = item[0] == DBNull.Value ? "" : item[0].ToString(),
                    Report_Colum = item[1] == DBNull.Value ? "" : item[1].ToString(),
                    Test_ID = item[2] == DBNull.Value ? "" : item[2].ToString(),
                    Group_Category = item[3] == DBNull.Value ? "" : item[3].ToString(),
                    Test_Name = item[4] == DBNull.Value ? "" : item[4].ToString(),
                    Bill_Details_ID = item[9] == DBNull.Value ? "" : item[9].ToString(),
                    Is_Result = Convert.ToBoolean(item[10] == DBNull.Value ? "" : item[10]),
                    Rejected_Reason = item[11] == DBNull.Value ? "" : item[11].ToString(),
                    Service_Date = item[12] == DBNull.Value ? "" : item[12].ToString(),
                    Is_Approve = Convert.ToBoolean(item[13] == DBNull.Value ? "" : item[13]),
                    patient_ID = item[14] == DBNull.Value ? "" : item[14].ToString(),
                    Test_Main_Department = item[15] == DBNull.Value ? "" : item[15].ToString(),
                    Test_Performed_By = item[5] == DBNull.Value ? "" : item[5].ToString(),
                    Result_Time = item[6] == DBNull.Value ? "" : Convert.ToDateTime(item[6]).ToString(),
                    Approved_Time = item[7] == DBNull.Value ? "" : Convert.ToDateTime(item[7]).ToString(),
                    Approved_By = item[8] == DBNull.Value ? "" : item[8].ToString(),
                    TestDepartment = item[16] == DBNull.Value ? "" : item[16].ToString(),
                    History = item[17] == DBNull.Value ? "" : item[17].ToString()




                };

                TestObj.ListOfTestIDs = DBClass.getField("select dbo.[GetGroupSubTests]('" + TestObj.Group_Category + "')");

                AlltestListRefined.Add(TestObj);
            }
            return (new JavaScriptSerializer()).Serialize(AlltestListRefined);
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

        }
        [WebMethod]
        public static string fillGrowthTypes()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var d = (from st in db.DataValues where st.ValueSet_ID == 2114 select new { st.DataValue_Name, st.DataValue_Description }).ToList();
                data = new JavaScriptSerializer().Serialize(d);
            }
            return data;
        }
        [WebMethod]
        public static string fillGrowthInfos()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Growth Information"
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
        public static string FillOrganismType()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var d = (from st in db.DataValues where st.ValueSet_ID == 2115 select new { st.DataValue_Name, st.DataValue_Description }).ToList();
                data = new JavaScriptSerializer().Serialize(d);
            }
            return data;
        }
        [WebMethod]
        public static Detail GetDetailUsingBillID(string Bill_ID)
        {
            int BillID = Convert.ToInt32(Bill_ID);
            Detail pt = new Detail();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Reg_patient pat = new Reg_patient();
            pat = (from l in db.Ar_Billings
                   join p in db.Reg_patients
                   on l.Patient_ID equals p.pat_id
                   where l.Bill_ID == BillID
                   select p).FirstOrDefault();
            if (pat != null)
            {
                pt.Patient_No = Convert.ToInt32(pat.pat_id).ToString();
                pt.Name = pat.Full_Name;
                pt.Gender = pat.Gender;
                pt.Age = pat.Age_years?.ToString() ?? "";
                if (pat.Created_time.HasValue)
                    pt.Entry_Date = pat.Created_time.ToString();

                pt.Mobile = pat.Mobile1;
                var isIPD = (from ipd in db.In_Patients
                             where ipd.Patient_ID == pat.pat_id && (ipd.Discharge == null || ipd.Discharge == false)
                             orderby ipd.In_Patient_ID descending
                             select ipd.In_Patient_ID).FirstOrDefault();
                var isEmergency = (from ipd in db.Emergency_Patients
                                   where ipd.Patient_ID == pat.pat_id && (ipd.Discharge == null || ipd.Discharge == false)
                                   orderby ipd.Emergency_ID descending
                                   select ipd.Emergency_ID).FirstOrDefault();
                if (isIPD != 0)
                {
                    var Locations = DBClass.getField("Select Concat (wd.Ward_Type,' / ',ipd.Bed_No) from In_Patient ipd join Ward_Definition wd on ipd.Ward_ID = wd.Ward_ID where ipd.In_Patient_ID =" + isIPD + "order by ipd.In_Patient_ID desc");
                    var Department = DBClass.getField("Select dbo.GetDataValueName('Patient Main Category', ipd.Department) AS Department from In_Patient ipd  where ipd.In_Patient_ID =" + isIPD + "order by ipd.In_Patient_ID desc");
                    pt.Location = Locations;
                    pt.Patient_Category = "IPD";
                    pt.Department = Department;
                }
                else if (isEmergency != 0)
                {
                    pt.Location = DBClass.getField("Select Concat (wd.Ward_Type,' / ',ipd.Bed_No) from Emergency_Patient ipd join Ward_Definition wd on ipd.Ward_ID = wd.Ward_ID where ipd.Emergency_ID =" + isEmergency + "order by ipd.Emergency_ID desc");
                    pt.Patient_Category = "Emergency";
                    pt.Department = "";
                }
                else
                {
                    var Department = DBClass.getField("Select dbo.GetDataValueName('Patient Main Category', p.Patient_Main_Category) AS Department from Patients p  where p.Reg_PatId =" + pat.pat_id + "order by p.Patient_ID desc");
                    pt.Location = "";
                    pt.Department = Department;
                    pt.Patient_Category = "OPD";
                }
                pt.Gender = db.GetDataValueName("Gender", pat.Gender);
                return pt;
            }
            else
                return pt;
        }
        [WebMethod]
        public static Detail GetDetailUsingLabID(string Lab_ID)
        {

            int LabID = Convert.ToInt32(Lab_ID);
            Detail pt = new Detail();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Reg_patient pat = new Reg_patient();

            pat = (from l in db.Laboratory_Tests
                   join p in db.Reg_patients
                   on l.Patient_ID equals p.pat_id
                   where l.Lab_Test_ID == LabID
                   select p).FirstOrDefault();

            if (pat != null)
            {
                pt.Patient_No = Convert.ToInt32(pat.pat_id).ToString();
                pt.Name = pat.Full_Name;
                pt.Gender = pat.Gender;
                pt.Age = pat.Age_years?.ToString() ?? ""; 
                if (pat.Created_time.HasValue)
                    pt.Entry_Date = pat.Created_time.ToString();

                pt.Mobile = pat.Mobile1;
                var isIPD = (from ipd in db.In_Patients
                             where ipd.Patient_ID == pat.pat_id && (ipd.Discharge == null || ipd.Discharge == false)
                             orderby ipd.In_Patient_ID descending
                             select ipd.In_Patient_ID).FirstOrDefault();
                var isEmergency = (from ipd in db.Emergency_Patients
                                   where ipd.Patient_ID == pat.pat_id && (ipd.Discharge == null || ipd.Discharge == false)
                                   orderby ipd.Emergency_ID descending
                                   select ipd.Emergency_ID).FirstOrDefault();
                if (isIPD != 0)
                {
                    var Locations = DBClass.getField("Select Concat (wd.Ward_Type,' / ',ipd.Bed_No) from In_Patient ipd join Ward_Definition wd on ipd.Ward_ID = wd.Ward_ID where ipd.In_Patient_ID =" + isIPD + "order by ipd.In_Patient_ID desc");
                    var Department = DBClass.getField("Select dbo.GetDataValueName('Patient Main Category', ipd.Department) AS Department from In_Patient ipd  where ipd.In_Patient_ID =" + isIPD + "order by ipd.In_Patient_ID desc");
                    pt.Location = Locations;
                    pt.Patient_Category = "IPD";
                    pt.Department = Department;
                }
                else if (isEmergency != 0)
                {
                    pt.Location = DBClass.getField("Select Concat (wd.Ward_Type,' / ',ipd.Bed_No) from Emergency_Patient ipd join Ward_Definition wd on ipd.Ward_ID = wd.Ward_ID where ipd.Emergency_ID =" + isEmergency + "order by ipd.Emergency_ID desc");
                    pt.Patient_Category = "Emergency";
                    pt.Department = "";
                }
                else
                {
                    var Department = DBClass.getField("Select dbo.GetDataValueName('Patient Main Category', p.Patient_Main_Category) AS Department from Patients p  where p.Reg_PatId =" + pat.pat_id + "order by p.Patient_ID desc");
                    pt.Location = "";
                    pt.Department = Department;
                    pt.Patient_Category = "OPD";
                }
                pt.Gender = db.GetDataValueName("Gender", pat.Gender);
                return pt;
            }
            else
                return pt;
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
            public string Location;
            public string Department;
        }


        //[WebMethod]
        //public static string FillUltrasound_level(string valID)
        //{
        //    DataBaseDataContext db = new DataBaseDataContext();
        //    var result = (from i in db.UltraSoundLevels
        //                  where i.Levels == valID
        //                  select i.FixValues).FirstOrDefault();

        //    return (new JavaScriptSerializer().Serialize(result));
        //}



        [WebMethod]
        public static string GetAll_UltraSoundLevel()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var dpt = (from d in db.DataValues
                       join v in db.ValueSets
                       on d.ValueSet_ID equals v.ValueSet_ID
                       where v.ValueSet_Name == "Ultrasound level"
                       select new
                       {
                           d.DataValue_Name,
                           d.DataValue_Description
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
        }

        protected void Button1_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Modules/Lab/RadiologyTestResult.aspx");
        }




        [WebMethod]
        public static string AllUltraSoundTest(string departmentCode, string doctorId, string startdate, string endtdate)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            db.CommandTimeout = 180;
            JavaScriptSerializer serl = new JavaScriptSerializer();
            serl.MaxJsonLength = 2147483647;

            DateTime startDate = Convert.ToDateTime(startdate).Date;
            DateTime endDate = Convert.ToDateTime(endtdate).Date.AddDays(1).AddTicks(-1);

            var query = (
                from pat in db.Reg_patients
                join bill in db.Ar_Billings on pat.pat_id equals bill.Patient_ID
                join bill_details in db.Ar_Billing_Details on bill.Bill_ID equals bill_details.Bill_ID
                join labtest_detail in db.Lab_Test_Details on bill_details.Bill_Details_ID equals labtest_detail.Bill_Details_ID
                join lbt in db.Laboratory_Tests on labtest_detail.Lab_Test_ID equals lbt.Lab_Test_ID
                where (labtest_detail.isApproved == false || labtest_detail.isApproved == null) &&
                      (
                         labtest_detail.Is_Result == false
                         || labtest_detail.Is_Result == null
                         || (
                             labtest_detail.Is_Result == true &&
                             (labtest_detail.Refer_Doctor == null || labtest_detail.Refer_Doctor == "" || labtest_detail.Refer_Doctor == "0")
                            )
                        ) &&
                      bill_details.Test_Main_Department != "001" &&
                      (bill.isCancel == false || bill.isCancel == null) &&
                       bill.Bill_Date >= startDate &&
                        bill.Bill_Date <= endDate
                         && !db.Refunds.Any(r => r.Bill_ID == bill.Bill_ID)
                orderby bill.Bill_Date descending
                select new
                {
                    bill.Bill_Date,
                    bill.Bill_No,
                    bill.Bill_ID,
                    bill_details.Category_ID,
                    bill_details.Item_Name,
                    Test_Main_Department = db.GetDataValueName("Main Test Departments", bill_details.Test_Main_Department),
                    pat.Patient_No,
                    pat.Created_time,
                    pat.pat_id,
                    pat.Full_Name,
                    bill_details.Bill_Details_ID,
                    bill.Remarks,
                    labtest_detail.IsAcknowledge,
                    DoctorId = bill_details.Doctor_id,
                    DoctorName = (from hr in db.HR_Employees where hr.Emp_ID == Convert.ToInt32(bill_details.Doctor_id ?? "0") select hr.Emp_Name).FirstOrDefault(),
                    labtest_detail.Refer_Doctor,
                    labtest_detail.Is_Result,
                    RawDeptCode = bill_details.Test_Main_Department
                }
            );

            if (!string.IsNullOrEmpty(departmentCode) && departmentCode != "0")
            {
                query = query.Where(x => x.RawDeptCode == departmentCode);
            }

            if (!string.IsNullOrEmpty(doctorId))
            {
                int docId = Convert.ToInt32(doctorId);
                query = query.Where(x => x.DoctorId == docId.ToString() || x.Refer_Doctor == docId.ToString());
            }

            var testDetails_Billing_Sample = query.ToList();
            return serl.Serialize(testDetails_Billing_Sample);
        }

        [WebMethod]
        public static string GetRadiologyResultsReady(string departmentCode, string startdate, string endtdate)  
        {
            DataBaseDataContext db = new DataBaseDataContext();
            db.CommandTimeout = 180;
            JavaScriptSerializer serl = new JavaScriptSerializer();
            serl.MaxJsonLength = 2147483647;

            DateTime startDate = Convert.ToDateTime(startdate).Date;
            DateTime endDate = Convert.ToDateTime(endtdate).Date.AddDays(1).AddTicks(-1);
            var userid = AppConfig.UserID;
            var ups = (from St in db.aspnet_Users
                       where St.UserId == AppConfig.UserID
                       select St.Allow_RadiologyAllList).FirstOrDefault();
            if (ups == true) {
                var resultsReadyList = (
                   from pat in db.Reg_patients
                   join bill in db.Ar_Billings on pat.pat_id equals bill.Patient_ID
                   join bill_details in db.Ar_Billing_Details on bill.Bill_ID equals bill_details.Bill_ID
                   join labtest_detail in db.Lab_Test_Details on bill_details.Bill_Details_ID equals labtest_detail.Bill_Details_ID
                   join lbt in db.Laboratory_Tests on labtest_detail.Lab_Test_ID equals lbt.Lab_Test_ID
                   where labtest_detail.Is_Result == true &&
                         (labtest_detail.isApproved == false || labtest_detail.isApproved == null) &&
                         (labtest_detail.Refer_Doctor != null || labtest_detail.Refer_Doctor != "" || labtest_detail.Refer_Doctor != "0") &&
                         bill_details.Test_Main_Department != "001" &&
                         (bill.isCancel == false || bill.isCancel == null) &&
                                                bill.Bill_Date >= startDate &&
                        bill.Bill_Date <= endDate
                         && !db.Refunds.Any(r => r.Bill_ID == bill.Bill_ID)
                   orderby bill.Bill_Date descending
                   select new
                   {
                       bill.Bill_Date,
                       bill.Bill_No,
                       bill.Bill_ID,
                       bill_details.Category_ID,
                       bill_details.Item_Name,
                       pat.Patient_No,
                       pat.pat_id,
                       pat.Full_Name,
                       bill_details.Bill_Details_ID,
                       bill.Remarks,
                       Test_Main_Department = db.GetDataValueName("Main Test Departments", bill_details.Test_Main_Department),
                       Doctor = (from hr in db.HR_Employees where hr.Emp_ID == Convert.ToInt32(labtest_detail.Refer_Doctor ?? "0") select hr.Emp_Name).FirstOrDefault(),
                       RawDeptCode = bill_details.Test_Main_Department
                   }
               );        
               if (!string.IsNullOrEmpty(departmentCode) && departmentCode != "0")
                {
                    resultsReadyList = resultsReadyList.Where(x => x.RawDeptCode == departmentCode);
                }

                var testDetails_Billing_Sample = resultsReadyList.ToList();
                return serl.Serialize(resultsReadyList);
            }

            else
            {
                var resultsReadyList = (
                   from pat in db.Reg_patients
                   join bill in db.Ar_Billings on pat.pat_id equals bill.Patient_ID
                   join bill_details in db.Ar_Billing_Details on bill.Bill_ID equals bill_details.Bill_ID
                   join labtest_detail in db.Lab_Test_Details on bill_details.Bill_Details_ID equals labtest_detail.Bill_Details_ID
                   join lbt in db.Laboratory_Tests on labtest_detail.Lab_Test_ID equals lbt.Lab_Test_ID
                   join hr in db.HR_Employees on labtest_detail.Refer_Doctor equals Convert.ToString( hr.Emp_ID) 
                   where labtest_detail.Is_Result == true &&
                         (labtest_detail.isApproved == false || labtest_detail.isApproved == null) &&
                         bill_details.Test_Main_Department != "001" &&
                         (bill.isCancel == false || bill.isCancel == null) &&
                        bill.Bill_Date >= startDate &&
                        bill.Bill_Date <= endDate
                         && !db.Refunds.Any(r => r.Bill_ID == bill.Bill_ID)
                         && hr.userid == Convert.ToString(userid)
                   orderby bill.Bill_Date descending
                   select new
                   {
                       bill.Bill_Date,
                       bill.Bill_No,
                       bill.Bill_ID,
                       bill_details.Category_ID,
                       bill_details.Item_Name,
                       pat.Patient_No,
                       pat.pat_id,
                       pat.Full_Name,
                       bill_details.Bill_Details_ID,
                       bill.Remarks,
                       Test_Main_Department = db.GetDataValueName("Main Test Departments", bill_details.Test_Main_Department),
                       Doctor = (from hr in db.HR_Employees where hr.Emp_ID == Convert.ToInt32(labtest_detail.Refer_Doctor ?? "0") select hr.Emp_Name).FirstOrDefault(),
                       RawDeptCode = bill_details.Test_Main_Department
                   }
                );
                if (!string.IsNullOrEmpty(departmentCode) && departmentCode != "0")
                {
                    resultsReadyList = resultsReadyList.Where(x => x.RawDeptCode == departmentCode);
                }

                var testDetails_Billing_Sample = resultsReadyList.ToList();
                return serl.Serialize(resultsReadyList);

            }
           
        }

        [WebMethod]
        public static string GetDoctors()
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext();
                var doctors = (from emp in db.HR_Employees
                               where emp.IsDoctor == true
                               select new
                               {
                                   id = emp.Emp_ID, 
                                   text = emp.Emp_Name
                               }).ToList();
                return (new JavaScriptSerializer()).Serialize(doctors);
            }
            catch (Exception ex)
            {
                return "[]";
            }
        }

      
        private const string DEPT_ULTRASOUND = "002";
        private const string DEPT_XRAY = "003";
        private const string DEPT_CTSCAN = "004";
        private const string DEPT_MRI = "006";

        [WebMethod]
        public static string GetAll_XRayLevel()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                if (AppConfig.UserID == Guid.Empty)
                {
                    return (new JavaScriptSerializer()).Serialize(new List<object>());
                }

                Guid currentUserIdGuid = AppConfig.UserID;

                var levels = (from uwt in db.User_Wise_Templates
                              join uwtDetail in db.User_Wise_Template_Details
                                  on uwt.User_Wise_Template_Id equals uwtDetail.User_Wise_Template_Id
                              join xr in db.XRayLevels
                                  on uwtDetail.DataValue_ID equals xr.Levels
                              join dv in db.DataValues on xr.Levels equals dv.DataValue_Name
                              join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                              where uwt.User_Id == currentUserIdGuid
                                    && uwtDetail.User_Id == currentUserIdGuid
                                    && uwt.is_cancel == false
                                    && uwtDetail.DataValue_ID != null
                                    && uwtDetail.DataValue_ID != ""
                                    && vs.ValueSet_Name == "X-Ray Format"
                                    && uwtDetail.Department == DEPT_XRAY
                              select new
                              {
                                  xr.XRayLevel_ID,
                                  xr.Levels,
                                  xr.FixValues,
                                  DataValue_Description = dv.DataValue_Description
                              }).Distinct().ToList();

                return (new JavaScriptSerializer()).Serialize(levels);
            }
        }

        [WebMethod]
        public static string GetAll_MRILevel()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                if (AppConfig.UserID == Guid.Empty)
                {
                    return (new JavaScriptSerializer()).Serialize(new List<object>());
                }

                Guid currentUserIdGuid = AppConfig.UserID;

                var levels = (from uwt in db.User_Wise_Templates
                              join uwtDetail in db.User_Wise_Template_Details
                                  on uwt.User_Wise_Template_Id equals uwtDetail.User_Wise_Template_Id
                              join mri in db.MRILevels
                                  on uwtDetail.DataValue_ID equals mri.Levels
                              join dv in db.DataValues on mri.Levels equals dv.DataValue_Name
                              join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                              where uwt.User_Id == currentUserIdGuid
                                    && uwtDetail.User_Id == currentUserIdGuid
                                    && uwt.is_cancel == false
                                    && uwtDetail.DataValue_ID != null
                                    && uwtDetail.DataValue_ID != ""
                                    && vs.ValueSet_Name == "MRI Format"
                                    && uwtDetail.Department == DEPT_MRI
                              select new
                              {
                                  mri.MRILevel_ID,
                                  mri.Levels,
                                  mri.FixValues,
                                  DataValue_Description = dv.DataValue_Description
                              }).Distinct().ToList();

                return (new JavaScriptSerializer()).Serialize(levels);
            }
        }

        [WebMethod]
        public static string GetAll_CTScanLevel()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                if (AppConfig.UserID == Guid.Empty)
                {
                    return (new JavaScriptSerializer()).Serialize(new List<object>());
                }

                Guid currentUserIdGuid = AppConfig.UserID;

                var levels = (from uwt in db.User_Wise_Templates
                              join uwtDetail in db.User_Wise_Template_Details
                                  on uwt.User_Wise_Template_Id equals uwtDetail.User_Wise_Template_Id
                              join ct in db.CTScanLevels
                                  on uwtDetail.DataValue_ID equals ct.Levels
                              join dv in db.DataValues on ct.Levels equals dv.DataValue_Name
                              join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                              where uwt.User_Id == currentUserIdGuid
                                    && uwtDetail.User_Id == currentUserIdGuid
                                    && uwt.is_cancel == false
                                    && uwtDetail.DataValue_ID != null
                                    && uwtDetail.DataValue_ID != ""
                                    && vs.ValueSet_Name == "CTScan Format"
                                    && uwtDetail.Department == DEPT_CTSCAN
                              select new
                              {
                                  ct.CTScanLevel_ID,
                                  ct.Levels,
                                  ct.FixValues,
                                  DataValue_Description = dv.DataValue_Description
                              }).Distinct().ToList();

                return (new JavaScriptSerializer()).Serialize(levels);
            }
        }

        [WebMethod]
        public static string GetAll_UltrasoundLevelUserWise()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                if (AppConfig.UserID == Guid.Empty)
                {
                    return (new JavaScriptSerializer()).Serialize(new List<object>());
                }

                Guid currentUserIdGuid = AppConfig.UserID;

                var levels = (from uwt in db.User_Wise_Templates
                              join uwtDetail in db.User_Wise_Template_Details
                                  on uwt.User_Wise_Template_Id equals uwtDetail.User_Wise_Template_Id
                              join us in db.UltraSoundLevels
                                  on uwtDetail.DataValue_ID equals us.Levels
                              join dv in db.DataValues on us.Levels equals dv.DataValue_Name
                              join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                              where uwt.User_Id == currentUserIdGuid
                                    && uwtDetail.User_Id == currentUserIdGuid
                                    && uwt.is_cancel == false
                                    && uwtDetail.DataValue_ID != null
                                    && uwtDetail.DataValue_ID != ""
                                    && vs.ValueSet_Name == "Ultrasound level"
                                    && uwtDetail.Department == DEPT_ULTRASOUND
                              select new
                              {
                                  us.UltraSoundLevel_ID,
                                  us.Levels,
                                  us.FixValues,
                                  DataValue_Description = dv.DataValue_Description
                              }).Distinct().ToList();

                return (new JavaScriptSerializer()).Serialize(levels);
            }
        }

        [WebMethod]
        public static string FillUltrasound_level(string valID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var result = (from i in db.UltraSoundLevels
                          where i.Levels == valID
                          select i.FixValues).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(result);
        }

        // Add methods for MRI and CTScan fixed values
        [WebMethod]
        public static string FillMRILevel(string valID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var result = (from i in db.MRILevels
                          where i.Levels == valID
                          select i.FixValues).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(result);
        }

        [WebMethod]
        public static string FillCTScanLevel(string valID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var result = (from i in db.CTScanLevels
                          where i.Levels == valID
                          select i.FixValues).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(result);
        }

        [WebMethod]
        public static string CheckApprovalrights()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var ups = (from St in db.aspnet_Users
                       where St.UserId == AppConfig.UserID
                       select St.Approve_radiology).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(ups);
        }

        [WebMethod]
        public static string Checkrejectrights()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var ups = (from St in db.aspnet_Users
                       where St.UserId == AppConfig.UserID
                       select St.Reject_radiology).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(ups);
        }


        [WebMethod]
        public static string GetDynamicReportHTML(string Test_IDs, string Trans_IDs, int Patient_ID, string Bill_Details_IDs)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext();

                var reportData = db.spLabReportQ(Test_IDs, Trans_IDs, Patient_ID, Bill_Details_IDs).ToList();

                if (reportData == null || reportData.Count == 0)
                    return "{\"error\":\"No data found\"}";

                var data = reportData.First();

                // Get the raw path from GetCompanyLogo (e.g. "C:\Projects\Images\11414.png")
                // Get physical path from Segment1 + CompanyID + .png
                string physicalFolder = DBClass.getField(
                    "SELECT Segment1 FROM Sys_Parms WHERE Name = 'Project Image File Path'"
                )?.ToString() ?? "";

                string logoWebPath = "";
                if (!string.IsNullOrEmpty(physicalFolder))
                {
                    try
                    {
                        string companyID = "11414";
                        string fullImagePath = System.IO.Path.Combine(
                            physicalFolder.TrimEnd('\\'),
                            companyID + ".png"
                        );

                        // Read file and convert to Base64
                        if (System.IO.File.Exists(fullImagePath))
                        {
                            byte[] imageBytes = System.IO.File.ReadAllBytes(fullImagePath);
                            string base64String = Convert.ToBase64String(imageBytes);

                            // Detect image type from extension
                            string ext = System.IO.Path.GetExtension(fullImagePath)
                                             .ToLower()
                                             .TrimStart('.');
                            string mimeType = ext == "png" ? "image/png"
                                            : ext == "jpg" || ext == "jpeg" ? "image/jpeg"
                                            : ext == "gif" ? "image/gif"
                                            : "image/png";

                            // Embed as data URI — works everywhere, no IIS config needed
                            logoWebPath = "data:" + mimeType + ";base64," + base64String;
                        }
                    }
                    catch
                    {
                        logoWebPath = "";
                    }
                }

                var result = new
                {
                    Company_Name = DBClass.getField("SELECT TOP 1 Company_Name FROM sys_Companys WHERE Company_ID = 1")?.ToString() ?? "National Hospital & Medical Centre",
                    Company_Address = DBClass.getField("SELECT TOP 1 Company_Address FROM sys_Companys WHERE Company_ID = 1")?.ToString() ?? "",
                    Company_Logo_Path = logoWebPath,

                    // Test
                    Test_Name = data.Test_Name ?? data.Group_Department ?? "Radiology Report",
                    Fixed_Value = data.Fixed_Value ?? "",

                    // Patient
                    Full_Name = data.Full_Name ?? "",
                    Age_years = data.Age_years?.ToString() ?? "",
                    Gender = data.Gender ?? "",
                    Patient_No = data.Patient_No?.ToString() ?? "",
                    REg_Date = data.REg_Date,
                    Mobile1 = data.Mobile1 ?? "",
                    NIC = data.NIC ?? "",
                    Patient_Type = data.Patient_Type ?? "",
                    ReferredByDoctor = data.ReferredByDoctor ?? "",
                    Bill_No = data.Bill_No ?? "",
                    Department = data.DepartMent ?? "",
                    Billing_Date = data.Billing_Date?.ToString() ?? "",
                    Approved_Time = data.Approved_Time?.ToString() ?? "",

                    // Footer
                    Report_Footer = data.Report_Footer ?? "",
                    Report_Footer_tow = data.Report_Footer_tow ?? "",
                    Report_Footer1 = data.Report_Footer1 ?? "",
                    Report_Footer_tow1 = data.Report_Footer_tow1 ?? "",

                    // Doctors
                    Test_Approved_By_Doctor_name = data.Test_Approved_By_Doctor_name ?? "",
                    Test_Approved_By_Doctor_qualification = data.Test_Approved_By_Doctor_qualification ?? "",
                    Test_Performed_By_Doctor_name = data.Test_Performed_By_Doctor_name ?? "",
                    Test_Performed_By_Doctor_qualification = data.Test_Performed_By_Doctor_qualification ?? "",
                    Test_Ready_On = data.Test_Ready_On?.ToString() ?? "",
                };

                return new JavaScriptSerializer().Serialize(result);
            }
            catch (Exception ex)
            {
                // Return clean error — no path mapping calls here
                return "{\"error\":\"" + ex.Message.Replace("\"", "'").Replace("\r", " ").Replace("\n", " ") + "\"}";
            }
        }

        // code ends here

    }
}
