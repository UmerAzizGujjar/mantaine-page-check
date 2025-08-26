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
    public partial class AddPanel_Packages : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindingDropDown();
            }
        }



        public class MasterListForPanelOrDoc
        {
            public string PackageID { get; set; }
            public List<DetailPanelList> ItemListPanel { get; set; }
        }

        public class DetailPanelList
        {
            public string PanelID { get; set; }

        }

        [WebMethod]
        public static string LoadPanel(string Id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var panel = (from tbl in db.Panel_Packages_Details
                             where tbl.Pan_Pakages_Id == Convert.ToInt32(Id) 
                             select tbl).ToList();

                return (new JavaScriptSerializer()).Serialize(panel);
            }

        }
        [WebMethod]
        public static string GetPopulatePackage(int PackagesID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());


            var qry = (from p in db.PanelPackages
                       where p.Pan_Packages_ID == PackagesID
                       select new
                       {
                           p.Pan_Packages_ID,
                           p.Remarks,
                           p.Package_Name,                          
                           p.Package_Type,
                           p.Duration,
                           p.PerDay_Charges,                         
                           p.Panel_id,
                           p.Total_Amount,
                           p.Total_Expense,
                           p.Doctor_Share,
                           p.Hospital_Share,
                           p.Net_Amount,
                           p.Share_type,

                       }).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(qry);
        }

        [WebMethod]
        public static string GetPackageDetail(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var pkgdetail = (from pkgd in db.Panel_Packages_Detail_Rates
                             where pkgd.Pan_Packages_ID == Convert.ToInt32(id)
                             select new
                             {
                                 pkgd.Item_Code,
                                 itemanme = (
                                 (pkgd.Item_Type.ToString() == "Item" || pkgd.Item_Type.ToString() == "Service") ?
                                 (from item in db.INV_Items where item.Item_ID == pkgd.Item_Code select item.Description).FirstOrDefault()
                                 :
                                 (from test in db.Lab_Tests where test.Test_ID == pkgd.Item_Code select test.Test_Name).FirstOrDefault()
                                 ),
                                 pkgd.Pan_Packages_ID,
                                 pkgd.QTY,
                                 pkgd.Price,
                                 pkgd.Amount,
                                 pkgd.Item_Type,
                                 pkgd.IsFixed,
                                 pkgd.is_expense,
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
            object valuesets;
            DataBaseDataContext dbs = new DataBaseDataContext();

            valuesets = DBClass.GetValueSet("Package Share Type");
            ddlShareType.DataSource = valuesets;
            ddlShareType.DataTextField = "DataValue_Description";
            ddlShareType.DataValueField = "DataValue_Name";
            ddlShareType.Items.Add(new ListItem("Please Select", "0"));
            ddlShareType.DataBind();
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
            public bool isExpense { get; set; }

            public string IsFix { get; set; }
        }
        public class Package_detail_Rate
        {
            public string Pan_Pakages_Id { get; set; }
            public string Panel_Id { get; set; }
        }

        public class PackageHeader
        {
            public List<DetailPackage> PKDetail { get; set; }
            public List<Package_detail_Rate> PKRateDetail { get; set; }

        }
        [WebMethod]
        public static int SavePackage(string btnSave, string PAckID, string Package, string Remarks, string PackageType, string TotalAmount, string TotalExpense, string NetAmount, string Doctor_Share, string Hospital_Share, string ShareType, string duration, string PAKg, string PAKrate, decimal PerDay_Charges)
        {

            string Package_ID = "";

            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<PackageHeader>(PAKg);        
            var records = oJS.Deserialize<PackageHeader>(PAKrate);        
            if (btnSave == "Update")
            {

                var lstTests = (from t in db.PanelPackages
                                where t.Pan_Packages_ID == int.Parse(PAckID)
                                select t).FirstOrDefault();
                lstTests.Package_Name = Package;
                lstTests.Remarks = Remarks;
                lstTests.PerDay_Charges = PerDay_Charges;
                lstTests.Duration = duration;
                lstTests.Package_Type = PackageType;
                lstTests.Share_type = ShareType;
                lstTests.Total_Amount = Convert.ToDecimal(TotalAmount);
                lstTests.Total_Expense = Convert.ToDecimal(TotalExpense);
                lstTests.Net_Amount = Convert.ToDecimal(NetAmount);
                lstTests.Doctor_Share = Convert.ToDecimal(Doctor_Share);
                lstTests.Hospital_Share = Convert.ToDecimal(Hospital_Share);
                lstTests.Updated_By = AppConfig.UserID;
                lstTests.Updation_Date = DateTime.Now;

                db.SubmitChanges();
                Package_ID = lstTests.Pan_Packages_ID.ToString();

            }
            else
            {
                PanelPackage pkg = new PanelPackage();
                pkg.Package_Name = Package;
                pkg.Remarks = Remarks;
                pkg.Duration = duration;
                pkg.Package_Type = PackageType;
                pkg.PerDay_Charges = PerDay_Charges;
                pkg.Share_type = ShareType;
                pkg.Total_Amount = Convert.ToDecimal(TotalAmount);
                pkg.Total_Expense = Convert.ToDecimal(TotalExpense);
                pkg.Net_Amount = Convert.ToDecimal(NetAmount);
                pkg.Doctor_Share = Convert.ToDecimal(Doctor_Share);
                pkg.Hospital_Share = Convert.ToDecimal(Hospital_Share);
                pkg.Created_By = AppConfig.UserID;
                pkg.Creation_Date = DateTime.Now;
                db.PanelPackages.InsertOnSubmit(pkg);
                db.SubmitChanges();
                Package_ID = pkg.Pan_Packages_ID.ToString();
            }

            if (btnSave == "Update")
            {
                var PacktDetails = db.Panel_Packages_Detail_Rates.Where(t => t.Pan_Packages_ID == int.Parse(Package_ID)).ToList();
                db.Panel_Packages_Detail_Rates.DeleteAllOnSubmit(PacktDetails);
                db.SubmitChanges();
            }


            var PackageID = int.Parse(Package_ID);
            foreach (var test in record.PKDetail)
            {
                Panel_Packages_Detail_Rate pkgdetail = new Panel_Packages_Detail_Rate();
                pkgdetail.Item_Code = Convert.ToInt32(test.Item);
                pkgdetail.Pan_Packages_ID = Convert.ToInt32(Package_ID);
                pkgdetail.QTY = Convert.ToInt32(test.QTy);
                pkgdetail.Price = Convert.ToDecimal(test.Price);
                pkgdetail.Amount = Convert.ToDecimal(test.Amount);
                pkgdetail.Item_Type = test.ItemType;
                pkgdetail.ItemsOrderBy = test.ItemsOrder;
                pkgdetail.is_expense = test.isExpense;
                if (test.IsFix == "true" || test.IsFix == "True")
                {
                    pkgdetail.IsFixed = true;
                }
                else
                {
                    pkgdetail.IsFixed = false;
                }
                db.Panel_Packages_Detail_Rates.InsertOnSubmit(pkgdetail);
                db.SubmitChanges();
            }

            if (btnSave == "Update")
            {
                var PacktDetails = db.Panel_Packages_Details.Where(t => t.Pan_Pakages_Id == int.Parse(Package_ID)).ToList();
                db.Panel_Packages_Details.DeleteAllOnSubmit(PacktDetails);
                db.SubmitChanges();
            }

            foreach (var test in records.PKRateDetail)
            {
                Panel_Packages_Detail PKRateDetail = new Panel_Packages_Detail();
                PKRateDetail.Pan_Pakages_Id = Convert.ToInt32(Package_ID);
                PKRateDetail.Panel_Id = test.Panel_Id;
                db.Panel_Packages_Details.InsertOnSubmit(PKRateDetail);
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
        public static string GetDoctors()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<HR_Employee> emps = (from emp in db.HR_Employees
                                      where emp.IsDoctor == true
                                      select emp).ToList();

            return (new JavaScriptSerializer()).Serialize(emps);
        }


        [WebMethod]
        public static string GetPanel()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var panel = (from tbl in db.Panels

                             select tbl).ToList();

                return (new JavaScriptSerializer()).Serialize(panel);
            }
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

            // adding lab tests in list.
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

            // adding test categorys in list.
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

            // filtering list to get the category id
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
                // filtering list to get the Test id

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