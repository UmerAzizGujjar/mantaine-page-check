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
    public partial class Doctor_Template : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string LoadDoctor()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var doctor = (from emp in db.HR_Employees

                              where emp.Resign_Date == null && emp.IsDoctor == true
                              && emp.userid == Convert.ToString(AppConfig.UserID)
                              select new { emp.Emp_ID, emp.Emp_Name }).ToList();
                return (new JavaScriptSerializer()).Serialize(doctor);
            }
            return "";
        }

        [WebMethod]
        public static string getpharmacyitems(string searchString)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var pharmacyItems = (from d in db.INV_Items
                                     where d.IsPharmacyItem == true && d.Description.Contains(searchString)
                                     orderby d.Item_ID descending
                                     select new
                                     {
                                         d.Item_Code,
                                         Description = d.Description
                                     }).Take(20).ToList();

                return (new JavaScriptSerializer().Serialize(pharmacyItems));
            }
        }
        [WebMethod]
        public static string FillTestMainDepartment()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var dpt = (from d in db.DataValues
                       join v in db.ValueSets
                       on d.ValueSet_ID equals v.ValueSet_ID
                       where v.ValueSet_Name == "Main Test Departments"
                       select new
                       {
                           d.DataValue_Name,
                           d.DataValue_Description
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
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
                                  where vs.ValueSet_Name == "Test Groups" && dv.Division == "001"
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
        [WebMethod]
        public static string FillTestsByCategory(string CategoryID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var tests = from t in db.Lab_Tests
                        where t.Main_Department == CategoryID && t.Active == true
                        select new { t.Test_ID, t.Test_Name };

            return (new JavaScriptSerializer()).Serialize(tests);
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
        public static string GetProcedure(string dpt)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var INV_Items = from itm in db.Lab_Tests

                            where itm.Main_Department == dpt
                            select new
                            {
                                itm.Main_Department,
                                itm.Test_ID,
                                itm.Test_Name,
                                Main_Department_Name = (db.GetDataValueName("Main Test Departments", itm.Main_Department))
                            };
            return (new JavaScriptSerializer().Serialize(INV_Items));
        }

        [WebMethod]
        public static string LoadMasterData(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var query = (from m in db.Doctor_Template_Masters
                         where m.Template_Id == id
                         select m).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static string LoadTestData(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var details = (from m in db.Doctor_Template_Tests
                           where m.Template_Id == id
                           select new
                           {
                               m.Test_Id,
                               m.Department_id,
                               m.Department_Name,
                               m.Test_Name,
                               m.Rotation_Id,
                               m.Rotation_Name
                           }).ToList();

            return (new JavaScriptSerializer()).Serialize(details);
        }

        [WebMethod]
        public static string LoadMedicineData(int id)
        {
           
            DataBaseDataContext db = new DataBaseDataContext();

            var details = (from m in db.Doctor_Template_Medicines
                           where m.Template_Id == id
                           select new
                           {
                               m.IsPharmacy,
                               m.Medicine_id,
                               m.Medicine_Name
                           }).ToList();

            return (new JavaScriptSerializer()).Serialize(details);
        }

        [WebMethod]
        public static string SaveRecord(string btnSave, string Temp_Id, string Doctor_Id, bool isActive, string Tem_Name, List<Medicine> medList, List<Test> testList)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Doctor_Template_Master apptemp;

            if (btnSave == "Save")
            {
                apptemp = new Doctor_Template_Master
                {
                    Template_Name = Tem_Name,
                    isActive = isActive,
                    Doctor_Id = Convert.ToInt32(Doctor_Id),
                    Created_Time = DateTime.Now,
                    Created_By = AppConfig.UserID
                };
                db.Doctor_Template_Masters.InsertOnSubmit(apptemp);
                db.SubmitChanges();
            }
            else
            {
                apptemp = db.Doctor_Template_Masters.FirstOrDefault(tbl => tbl.Template_Id == Convert.ToInt32(Temp_Id));
                if (apptemp != null)
                {
                    apptemp.Doctor_Id = Convert.ToInt32(Doctor_Id);
                    apptemp.Template_Name = Tem_Name;
                    apptemp.isActive = isActive;
                    apptemp.Updated_by = AppConfig.UserID;
                    apptemp.Updated_Time = DateTime.Now;
                    db.SubmitChanges();
                }
            }

            if (apptemp != null)
            {
              
                if (btnSave != "Save")
                {
                    var existingMeds = db.Doctor_Template_Medicines.Where(m => m.Template_Id == apptemp.Template_Id).ToList();
                    db.Doctor_Template_Medicines.DeleteAllOnSubmit(existingMeds);

                    var existingTests = db.Doctor_Template_Tests.Where(t => t.Template_Id == apptemp.Template_Id).ToList();
                    db.Doctor_Template_Tests.DeleteAllOnSubmit(existingTests);
                }

                // Insert new child records
                foreach (var med in medList)
                {
                    Doctor_Template_Medicine apforms = new Doctor_Template_Medicine
                    {
                        Template_Id = apptemp.Template_Id,
                        Medicine_id = med.MedicineId,
                        Medicine_Name = med.MedicineName,
                        IsPharmacy = true
                    };
                    db.Doctor_Template_Medicines.InsertOnSubmit(apforms);
                }

                foreach (var test in testList)
                {
                    Doctor_Template_Test testforms = new Doctor_Template_Test
                    {
                        Template_Id = apptemp.Template_Id,
                        Department_id = test.DepartmentId,
                        Department_Name = test.DepartmentName,
                        Test_Name = test.TestName,
                        Test_Id = test.TestId,
                        Rotation_Id = test.RotationId,
                        Rotation_Name = test.RotationName
                    };
                    db.Doctor_Template_Tests.InsertOnSubmit(testforms);
                }

                db.SubmitChanges();
            }

            return apptemp.Template_Id.ToString();
        }



        public class Medicine
        {
            public string MedicineId { get; set; }
            public string MedicineName { get; set; }
            public Boolean IsPharmacy { get; set; }
        }

        public class Test
        {
            public string DepartmentId { get; set; }
            public string DepartmentName { get; set; }
            public string TestId { get; set; }
            public string TestName { get; set; }
            public string RotationId { get; set; }
            public string RotationName { get; set; }
        }


    }
}