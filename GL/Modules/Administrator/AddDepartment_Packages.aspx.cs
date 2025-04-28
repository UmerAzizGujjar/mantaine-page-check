using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Inventory
{
    public partial class AddDepartment_Packages : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindingDropDown();            
            }
        }

           [WebMethod]
        public static string GetPopulatePackage(int PackagesID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());


            var qry = (from p in db.DepartmentPackages
                       where p.Dep_Packages_ID == PackagesID
                       select new
                       {
                           p.Dep_Packages_ID,
                           p.Remarks,
                           p.Package_Name,                          
                           p.Package_Type,
                           p.Duration,
                           p.PerDay_Charges,                         
                           p.Panel_id,
                           p.Department,
                           p.Sub_Department,
                        
                       }).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(qry);
        }

        [WebMethod]
        public static string GetPackageDetail(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var pkgdetail = (from pkgd in db.Dep_Packages_Details
                             where pkgd.Dep_Packages_ID == Convert.ToInt32(id)
                             select new
                             {
                                 pkgd.Item_Code,
                                 itemanme = (
                                 (pkgd.Item_Type.ToString() == "Item" || pkgd.Item_Type.ToString() == "Service") ?
                                 (from item in db.INV_Items where item.Item_ID == pkgd.Item_Code select item.Description).FirstOrDefault()
                                 :
                                 (from test in db.Lab_Tests where test.Test_ID == pkgd.Item_Code select test.Test_Name).FirstOrDefault()
                                 ),
                                 pkgd.Dep_Packages_ID,
                                 pkgd.QTY,
                                 pkgd.Price,
                                 pkgd.Amount,
                                 pkgd.Item_Type,
                                 pkgd.IsFixed,
                                 ItemsOrderBy = pkgd.ItemsOrderBy == null ? 0 : pkgd.ItemsOrderBy

                             }

                ).ToList();

            return (new JavaScriptSerializer()).Serialize(pkgdetail);
        }

        [WebMethod]
        public static string GetPanelItems(string Panel_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();

             if (Panel_id == "0")
            {
                var pkgdetail = (from item in db.INV_Items
                                 where item.Book_ID == 1 && item.Hospital_Services == true
                                 select new
                                 {
                                     item.Item_ID,
                                     Description = item.Description,
                                     Sale_Rate = item.Sale_Rate,

                                 }
              ).ToList();
                return (new JavaScriptSerializer()).Serialize(pkgdetail);
            }
            else
            {
                var pkgdetail = (from panel in db.Panel_Detail_Services
                                 where panel.Panel_ID == Convert.ToInt32(Panel_id) && panel.Item_ID != null
                                 select new
                                 {
                                     panel.Item_ID,
                                     Description = (from data in db.INV_Items.Where(x => x.Item_ID.Equals(panel.Item_ID)) select data.Description).FirstOrDefault(),
                                     Sale_Rate = panel.Rate,
                                 }
               ).ToList();
                return (new JavaScriptSerializer()).Serialize(pkgdetail);
            }
        }

        private void BindingDropDown()
        {
            object valueset;
            DataBaseDataContext db = new DataBaseDataContext();

            valueset = DBClass.GetValueSet("Package Type");
            ddlPackageType.DataSource = valueset;
            ddlPackageType.DataTextField = "DataValue_Description";
            ddlPackageType.DataValueField = "DataValue_Name";
            ddlPackageType.Items.Add(new ListItem("Please Select", "0"));
            ddlPackageType.DataBind();
        }
        [WebMethod]
        public static string LoadDepartment(string Id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var panel = (from tbl in db.Department_Packages_Detail_Rates
                             where tbl.Dep_Pakages_Id == Convert.ToInt32(Id)
                             select tbl).ToList();
                return (new JavaScriptSerializer()).Serialize(panel);
            }
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
            public int ItemsOrder { get; set; }

            public string IsFix { get; set; }
        }

        public class Package_detail_Rate
        {
            public string Dep_Pakages_Id { get; set; }
            public string Department_Id { get; set; }
        }

        public class PackageHeader
        {
            public List<DetailPackage> PKDetail { get; set; }
            public List<Package_detail_Rate> PKRateDetail { get; set; }

        }

        [WebMethod]
        public static string GetDepartment()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var data = (from p in db.ValueSets
                        join d in db.DataValues
                        on p.ValueSet_ID equals d.ValueSet_ID                    
                        where p.ValueSet_Description == "Patient Main Category" 
                        select new
                        {
                            d.DataValue_Name,
                            d.DataValue_Description
                        }).ToList();
            return (new JavaScriptSerializer().Serialize(data));
        }

        [WebMethod]
        public static int SavePackage(string btnSave, string PAckID, string Package, string Remarks, string PackageType, string duration, string PAKg, string PAKrate, decimal PerDay_Charges)
        {

            string Package_ID = "";

            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<PackageHeader>(PAKg);
            var records = oJS.Deserialize<PackageHeader>(PAKrate);
            if (btnSave == "Update")
            {

                var lstTests = (from t in db.DepartmentPackages
                                where t.Dep_Packages_ID == int.Parse(PAckID)
                                select t).FirstOrDefault();
                lstTests.Package_Name = Package;
                lstTests.Remarks = Remarks;
                lstTests.PerDay_Charges = PerDay_Charges;
                lstTests.Duration = duration;
                lstTests.Package_Type = PackageType;
                lstTests.Updated_By = AppConfig.UserID;
                lstTests.Updation_Date = DateTime.Now;

                db.SubmitChanges();
                Package_ID = lstTests.Dep_Packages_ID.ToString();

            }
            else
            {
                DepartmentPackage pkg = new DepartmentPackage();
                pkg.Package_Name = Package;
                pkg.Remarks = Remarks;
                pkg.Duration = duration;
                pkg.Package_Type = PackageType;
                pkg.PerDay_Charges = PerDay_Charges;
                pkg.Created_By = AppConfig.UserID;
                pkg.Creation_Date = DateTime.Now;
                db.DepartmentPackages.InsertOnSubmit(pkg);
                db.SubmitChanges();
                Package_ID = pkg.Dep_Packages_ID.ToString();
            }

            if (btnSave == "Update")
            {
                var PacktDetails = db.Dep_Packages_Details.Where(t => t.Dep_Packages_ID == int.Parse(Package_ID)).ToList();
                db.Dep_Packages_Details.DeleteAllOnSubmit(PacktDetails);
                db.SubmitChanges();
            }


            var PackageID = int.Parse(Package_ID);
            foreach (var test in record.PKDetail)
            {
                Dep_Packages_Detail pkgdetail = new Dep_Packages_Detail();
                pkgdetail.Item_Code = Convert.ToInt32(test.Item);
                pkgdetail.Dep_Packages_ID = Convert.ToInt32(Package_ID);
                pkgdetail.QTY = Convert.ToInt32(test.QTy);
                pkgdetail.Price = Convert.ToDecimal(test.Price);
                pkgdetail.Amount = Convert.ToDecimal(test.Amount);
                pkgdetail.Item_Type = test.ItemType;
                pkgdetail.ItemsOrderBy = test.ItemsOrder;
                if (test.IsFix == "true" || test.IsFix == "True")
                {
                    pkgdetail.IsFixed = true;
                }
                else
                {
                    pkgdetail.IsFixed = false;
                }
                db.Dep_Packages_Details.InsertOnSubmit(pkgdetail);
                db.SubmitChanges();
            }
            if (btnSave == "Update")
            {
                var PacktDetails = db.Department_Packages_Detail_Rates.Where(t => t.Dep_Pakages_Id == int.Parse(Package_ID)).ToList();
                db.Department_Packages_Detail_Rates.DeleteAllOnSubmit(PacktDetails);
                db.SubmitChanges();
            }

            foreach (var test in records.PKRateDetail)
            {
                Department_Packages_Detail_Rate PKRateDetail = new Department_Packages_Detail_Rate();
                PKRateDetail.Dep_Pakages_Id = Convert.ToInt32(Package_ID);
                PKRateDetail.Department_Id = test.Department_Id;
                db.Department_Packages_Detail_Rates.InsertOnSubmit(PKRateDetail);
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
        public static string GetLabTestDDLDetails(int SerialNo)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var tests = from t in db.Lab_Tests
                        where t.Main_Department == "001"
                        select new
                        {
                            t.Rate,
                            t.Test_ID,
                            t.Test_Name,
                            t.Group_Category,
                            TestMainDepartmentName = db.GetDataValueName("Main Test Departments", t.Main_Department.ToString()).ToString(),
                            GroupCategoryName = db.GetDataValueName("Test Groups", t.Group_Category.ToString()).ToString(),

                        };
            List<TestIDsAndGroupCategory> listOfTest = new List<TestIDsAndGroupCategory>();
            int counter = 1;
            foreach (var test in tests)
            {
                TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                obj.Rate = test.Rate.ToString();
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
                                select new { t.Rate, t.Test_ID, t.Test_Name, t.Group_Category, TestMainDepartmentName = db.GetDataValueName("Main Test Departments", t.Main_Department.ToString()).ToString(), GroupCategoryName = db.GetDataValueName("Test Groups", t.Group_Category.ToString()).ToString() };
                        listOfTest = new List<TestIDsAndGroupCategory>();
                        foreach (var test in tests)
                        {
                            TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                            obj.Rate = test.Rate.ToString();
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
                                    select new { t.Rate, t.Test_ID, t.Test_Name, t.Group_Category, TestMainDepartmentName = db.GetDataValueName("Main Test Departments", t.Main_Department.ToString()).ToString(), GroupCategoryName = db.GetDataValueName("Test Groups", t.Group_Category.ToString()).ToString() };
                            listOfTest = new List<TestIDsAndGroupCategory>();
                            foreach (var test in tests)
                            {
                                TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                                obj.Rate = test.Rate.ToString();
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


    }
}