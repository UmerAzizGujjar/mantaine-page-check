using CrystalDecisions.CrystalReports.Engine;
using CrystalDecisions.Shared;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Drawing.Printing;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using System.Web.Script.Serialization;

namespace PMS
{
    public partial class Packages : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {

                BindingDropDown();
                if (Request.QueryString["ID"] != null)
                {
                    PopulatePackage(Convert.ToInt32(Request.QueryString["ID"]));
   ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "", "PopulatePackageDetail('" + Convert.ToInt32(Request.QueryString["ID"]) +"');", true);

                }
                
            }
        }
        private void PopulatePackage(int PackagesID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
         

            var qry = (from p in db.Packages
                       where p.Packages_ID == PackagesID
                       select new
                       {
                           p.Packages_ID,
                           p.Remarks,
                           p.Package_Name,
                           p.Department,
                           p.Package_Type,
                           p.Duration,
                           p.PerDay_Charges

                       }).FirstOrDefault();


            if (qry != null)
            {
                hdnPackage_ID.Value =qry.Packages_ID.ToString();
                txtPackage_Name.Text = qry.Package_Name;
                txtRemarks.Text = qry.Remarks;
               txtDuration.Text = qry.Duration;
                ddlPatient_Main_Category.SelectedValue = qry.Department;
                txtPerDayCharges.Text= qry.PerDay_Charges.ToString();
                ddlPackageType.SelectedValue = qry.Package_Type;
               
            }
        }

        [WebMethod]
        public static string GetPackageDetail(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext();

         

            var pkgdetail = (from pkgd in db.Packages_Details 
                                where pkgd.Packages_ID==Convert.ToInt32(id)
                                select new
                                {
                                    pkgd.Item_Code,                                      
                                    itemanme = (
                                    (pkgd.Item_Type.ToString()=="Item" || pkgd.Item_Type.ToString()=="Service")?
                                    (from item in db.INV_Items where item.Item_ID == pkgd.Item_Code select item.Description).FirstOrDefault()
                                    :
                                    (from test in db.Lab_Tests where test.Test_ID == pkgd.Item_Code select test.Test_Name).FirstOrDefault()


                                        //(from dt in db.DataValues where dt.DataValue_Name == pkgd.Category_ID select dt.DataValue_Description).FirstOrDefault()
                                    //(DBClass.getField("select Datavalue_Description from Datavalues where Datavalue_Name = '" +  pkgd.Category_ID + "' and Valueset_ID = 70").FirstOrDefault()
                                    ),
                                    GroupName = (from dt in db.DataValues where dt.DataValue_Name == pkgd.Category_ID && dt.ValueSet_ID == 70 select dt.DataValue_Description).FirstOrDefault(),
                                  
                pkgd.Packages_ID ,
                pkgd.QTY ,
                pkgd.Price ,
                pkgd.Amount,
              pkgd.Item_Type, 
              pkgd.Category_ID
                                }

                ).ToList();

            return (new JavaScriptSerializer()).Serialize(pkgdetail);
        }
        private void BindingDropDown()
        {
            object valueset;

            valueset = DBClass.GetValueSet("Patient Main Category");
            ddlPatient_Main_Category.DataSource = valueset;
            ddlPatient_Main_Category.DataTextField = "DataValue_Description";
            ddlPatient_Main_Category.DataValueField = "DataValue_Name";
            ddlPatient_Main_Category.Items.Add(new ListItem("Please Select", "0"));
            ddlPatient_Main_Category.DataBind();
            
            valueset = DBClass.GetValueSet("Package Type");
            ddlPackageType.DataSource = valueset;
            ddlPackageType.DataTextField = "DataValue_Description";
            ddlPackageType.DataValueField = "DataValue_Name";
            ddlPackageType.Items.Add(new ListItem("Please Select", "0"));
            ddlPackageType.DataBind();
        }

        [WebMethod]
        public static string AddItem(string item)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var data = (from td in db.INV_Items

                        where td.Item_ID == int.Parse(item)
                        select new
                        {
                            td.Item_ID,
                            td.Item_Code,
                            td.Description,
                            td.Sale_Rate,
                            td.Services
                        }).ToList();
            return (new JavaScriptSerializer().Serialize(data));
        }
        public class DetailPackage
        {
            public string Item { get; set; }
            public string QTy { get; set; }
            public string Price { get; set; }
            public string Amount { get; set; }
            public string ItemType { get; set; }
            public string Category_ID { get; set; }
        }

        public class PackageHeader
        {
            public List<DetailPackage> PKDetail { get; set; }

        }
        [WebMethod]
        public static int SavePackage(string btnSave, string PAckID, string Package, string Dpt, string Remarks, string PackageType, string duration, string PAKg, decimal PerDay_Charges)
        {

            string Package_ID = "";
           
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<PackageHeader>(PAKg);
           // List<DetailPackage> PKDetail = new List<DetailPackage>(tlist);
           
            //var lstTests = (from t in db.Laboratory_Tests
            //                where t.Patient_ID == int.Parse(record.PatientID)
            //                select t).FirstOrDefault();
            if (btnSave == "Update")
            {

                var lstTests = (from t in db.Packages
                                where t.Packages_ID == int.Parse(PAckID)
                                select t).FirstOrDefault();
                lstTests.Package_Name = Package;
                lstTests.Remarks = Remarks;
                lstTests.Department = Dpt;
                lstTests.PerDay_Charges = PerDay_Charges;
                lstTests.Duration = duration;               
                lstTests.Package_Type = PackageType;              
                db.SubmitChanges();
                Package_ID = lstTests.Packages_ID.ToString();

            }
            else
            {
                Package pkg = new Package();
                pkg.Package_Name = Package;
                pkg.Remarks = Remarks;
                pkg.Department = Dpt;
                pkg.Duration = duration;
                pkg.PerDay_Charges = PerDay_Charges;
                pkg.Package_Type = PackageType;
                db.Packages.InsertOnSubmit(pkg);
                db.SubmitChanges();
                Package_ID = pkg.Packages_ID.ToString();
            }

            if (btnSave == "Update")
            {
                var PacktDetails = db.Packages_Details.Where(t => t.Packages_ID == int.Parse(Package_ID)).ToList();
                db.Packages_Details.DeleteAllOnSubmit(PacktDetails);
                db.SubmitChanges();
            }


            var PackageID = int.Parse(Package_ID);
            foreach (var test in record.PKDetail)
            {
                Packages_Detail pkgdetail = new Packages_Detail();
                pkgdetail.Item_Code = Convert.ToInt32(test.Item);
                pkgdetail.Packages_ID = Convert.ToInt32(Package_ID);
                pkgdetail.QTY = Convert.ToInt32(test.QTy);
                pkgdetail.Price = Convert.ToDecimal(test.Price);
                pkgdetail.Amount = Convert.ToDecimal(test.Amount);
                pkgdetail.Item_Type = test.ItemType;
                pkgdetail.Category_ID = test.Category_ID;
                db.Packages_Details.InsertOnSubmit(pkgdetail);
                db.SubmitChanges();
            }

            return PackageID;
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
        public static string GetTestMainDepartmentDetails(int TestID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var TestMainDepartmentName = (from t in db.Lab_Tests
                                          where t.Test_ID == TestID
                                          select new
                                          {
                                              TestMainDepartmentName123 = db.GetDataValueName("Main Test Departments", t.Main_Department.ToString()).ToString(),
                                              rate = ((from td in db.Lab_Tests where td.Test_ID == TestID select td.Rate).FirstOrDefault()),
                                          }).ToList();
            return (new JavaScriptSerializer().Serialize(TestMainDepartmentName));
        }
        [WebMethod]
        public static string GetLabTestDDLDetails(string SerialNo)
        {
            string groupCategory = string.Empty;
            string testName = SerialNo;

            string[] testFullName = SerialNo.Split('|');
            if (testFullName.Length > 1)
            {
                testName = testFullName[0];
                groupCategory = DBClass.getField("select Datavalue_Name from Datavalues where valueset_ID = 70 and Datavalue_Description = '" + testFullName[1].Trim() + "'").ToString();
            }

            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var test = (from t in db.Lab_Tests
                        where t.Main_Department == "001" && t.Test_Name == testName && t.Group_Category == groupCategory
                        select new { t.Test_ID, t.Rate, /*= DBClass.getField(""),t.Test_Name*/ Test_Name = SerialNo, t.Group_Category, TestMainDepartmentName = db.GetDataValueName("Main Test Departments", t.Main_Department.ToString()).ToString(), GroupCategoryName = db.GetDataValueName("Test Groups", t.Group_Category.ToString()).ToString() }).ToList();
            var count = test.Count;

            if (count != 0)
            {
                return (new JavaScriptSerializer()).Serialize(test);
            }
            else
            {
                var GroupCategories = (from dv in db.DataValues
                                       join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                       where vs.ValueSet_Name == "Test Groups" && dv.DataValue_Description == SerialNo
                                       select new { Test_ID = 0, Group_Category = dv.DataValue_Name, Test_Name = dv.DataValue_Description, TestMainDepartmentName = "Lab Test", Main_Department = "001", Rate = dv.Segment1 }).ToList();
                return (new JavaScriptSerializer()).Serialize(GroupCategories);
            }
        }
        //[WebMethod]
        //public static string GetLabTestDDLDetails(int SerialNo)
        //{
        //    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
        //    var tests = from t in db.Lab_Tests
        //                where t.Main_Department == "001"
        //                select new { t.Rate,t.Test_ID, t.Test_Name, t.Group_Category, TestMainDepartmentName = db.GetDataValueName("Main Test Departments", t.Main_Department.ToString()).ToString(), GroupCategoryName = db.GetDataValueName("Test Groups", t.Group_Category.ToString()).ToString(),
                                    
        //                };
        //    List<TestIDsAndGroupCategory> listOfTest = new List<TestIDsAndGroupCategory>();
        //    int counter = 1;

        //    // adding lab tests in list.
        //    foreach (var test in tests)
        //    {
        //        TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
        //             obj.Rate = test.Rate.ToString();
        //        obj.TestID = test.Test_ID.ToString();
        //        obj.TestName = test.Test_Name.ToString();
        //        obj.SerialNo = counter.ToString();
        //        obj.IsGroupCategory = false;
        //        obj.CategoryID = test.Group_Category;
        //        obj.MainDepartmentName = test.TestMainDepartmentName;
        //        obj.GroupName = test.GroupCategoryName;
        //        listOfTest.Add(obj);
        //        counter++;
        //    }

        //    var GroupCategories = from dv in db.DataValues
        //                          join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
        //                          where vs.ValueSet_Name == "Test Groups"
        //                          select new { dv.DataValue_Name, dv.DataValue_Description };

        //    // adding test categorys in list.
        //    foreach (var category in GroupCategories)
        //    {
        //        TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
        //        obj.TestID = category.DataValue_Name.ToString();
        //        obj.TestName = category.DataValue_Description.ToString();
        //        obj.SerialNo = counter.ToString();
        //        obj.IsGroupCategory = true;
        //        obj.CategoryID = null;
        //        listOfTest.Add(obj);
        //        counter++;
        //    }

        //    // filtering list to get the category id
        //    counter = 1;
        //    foreach (TestIDsAndGroupCategory item in listOfTest)
        //    {
        //        if (SerialNo == Convert.ToInt32(item.SerialNo))
        //        {
        //            if (item.IsGroupCategory)
        //            {
        //                tests = from t in db.Lab_Tests
        //                        where t.Group_Category == item.TestID
        //                        select new { t.Rate,t.Test_ID, t.Test_Name, t.Group_Category, TestMainDepartmentName = db.GetDataValueName("Main Test Departments", t.Main_Department.ToString()).ToString(), GroupCategoryName = db.GetDataValueName("Test Groups", t.Group_Category.ToString()).ToString() };
        //                listOfTest = new List<TestIDsAndGroupCategory>();
        //                foreach (var test in tests)
        //                {
        //                    TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
        //                    obj.Rate = test.Rate.ToString();
        //                    obj.TestID = test.Test_ID.ToString();
        //                    obj.TestName = test.Test_Name.ToString();
        //                    obj.SerialNo = counter.ToString();
        //                    obj.IsGroupCategory = false;
        //                    obj.CategoryID = test.Group_Category;
        //                    obj.MainDepartmentName = test.TestMainDepartmentName;
        //                    obj.GroupName = test.GroupCategoryName;
        //                    listOfTest.Add(obj);
        //                    counter++;
        //                }
        //            }
        //        }
        //    }
        //    if (counter == 1)
        //    {
        //        // filtering list to get the Test id

        //        foreach (TestIDsAndGroupCategory item in listOfTest)
        //        {
        //            if (SerialNo == Convert.ToInt32(item.SerialNo))
        //            {
        //                if (!item.IsGroupCategory)
        //                {
        //                    tests = from t in db.Lab_Tests
        //                            where t.Test_ID == Convert.ToInt32(item.TestID)
        //                            select new { t.Rate,t.Test_ID, t.Test_Name, t.Group_Category, TestMainDepartmentName = db.GetDataValueName("Main Test Departments", t.Main_Department.ToString()).ToString(), GroupCategoryName = db.GetDataValueName("Test Groups", t.Group_Category.ToString()).ToString()};
        //                    listOfTest = new List<TestIDsAndGroupCategory>();
        //                    foreach (var test in tests)
        //                    {
        //                        TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
        //                        obj.Rate = test.Rate.ToString();
        //                        obj.TestID = test.Test_ID.ToString();
        //                        obj.TestName = test.Test_Name.ToString();
        //                        obj.SerialNo = counter.ToString();
        //                        obj.IsGroupCategory = false;
        //                        obj.CategoryID = test.Group_Category;
        //                        obj.MainDepartmentName = test.TestMainDepartmentName;
        //                        obj.GroupName = test.GroupCategoryName;
        //                        listOfTest.Add(obj);
        //                        counter++;
        //                    }
        //                }
        //            }
        //        }
        //    }
        //    return (new JavaScriptSerializer()).Serialize(listOfTest);
        //}
        public class TestIDsAndGroupCategory
        {
            public string Rate { get; set; }
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
        [WebMethod]
        public static string GetLabTests()
        {

            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var tests = from t in db.Lab_Tests
                        where t.Main_Department == "001" && t.Active == true
                        select new { t.Test_ID, Test_Name = t.Test_Name, t.Group_Category };
            List<TestIDsAndGroupCategory> listOfTest = new List<TestIDsAndGroupCategory>();
            int counter = 1;
            foreach (var test in tests)
            {
                TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                obj.TestID = test.Test_ID.ToString();
                obj.TestName = test.Test_Name.ToString() + (test.Group_Category != string.Empty ? " | " + DBClass.getField("select Datavalue_Description from Datavalues where Datavalue_Name = '" + test.Group_Category + "' and Valueset_ID = 70") : string.Empty);
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
        //[WebMethod]
        //public static string GetLabTests()
        //{
        //    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
        //    var tests = from t in db.Lab_Tests
        //                where t.Main_Department == "001"
        //                select new { t.Test_ID, t.Test_Name };
        //    List<TestIDsAndGroupCategory> listOfTest = new List<TestIDsAndGroupCategory>();
        //    int counter = 1;
        //    foreach (var test in tests)
        //    {
        //        TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
        //        obj.TestID = test.Test_ID.ToString();
        //        obj.TestName = test.Test_Name.ToString();
        //        obj.SerialNo = counter.ToString();
        //        obj.IsGroupCategory = false;
        //        listOfTest.Add(obj);
        //        counter++;
        //    }

        //    var GroupCategories = from dv in db.DataValues
        //                          join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
        //                          where vs.ValueSet_Name == "Test Groups"
        //                          select new { dv.DataValue_Name, dv.DataValue_Description };

        //    foreach (var category in GroupCategories)
        //    {
        //        TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
        //        obj.TestID = category.DataValue_Name.ToString();
        //        obj.TestName = category.DataValue_Description.ToString();
        //        obj.SerialNo = counter.ToString();
        //        obj.IsGroupCategory = true;
        //        obj.CategoryID = category.DataValue_Name;
        //        listOfTest.Add(obj);
        //        counter++;
        //    }

        //    return (new JavaScriptSerializer()).Serialize(listOfTest);
        //}

    }
}