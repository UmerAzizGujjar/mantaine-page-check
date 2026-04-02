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
    public partial class TestDefination : System.Web.UI.Page
    {
        private static bool is_admin = false;
        public bool is_admin_Test_Rate = false;
        public bool is_admin_Test_box = false;

        protected void Page_Load(object sender, EventArgs e)
        {
            string UserName = Session["UserName"] != null ? Session["UserName"].ToString() : "";
            string[] roles = System.Web.Security.Roles.GetRolesForUser(UserName);
            if (roles.Contains("administrator"))
            {
                Session["is_admin"] = true;
                is_admin = true;
            }
            else
            {
                Session["is_admin"] = false;
            }

            is_admin_Test_Rate = Convert.ToBoolean(DBClass.getField("Select AllowTestRate from aspnet_Users where UserId='" + AppConfig.UserID + "'"));

            is_admin_Test_box = Convert.ToBoolean(DBClass.getField("Select allowtestbox from aspnet_Users where UserId='" + AppConfig.UserID + "'"));

        }
        [WebMethod]
        public static string FillTestMainDepartment()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var dpt = (from d in db.DataValues
                       join v in db.ValueSets
                       on d.ValueSet_ID equals v.ValueSet_ID
                       where v.ValueSet_Name == "Main Test Departments"

                       where d.DataValue_Description != "Lab Test"

                       select new
                       {
                           d.DataValue_Name,
                           d.DataValue_Description
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
        }
        [WebMethod]
        public static string FillTestMainDepartmentDrpdwn()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var dpt = (from d in db.DataValues
                       join v in db.ValueSets
                       on d.ValueSet_ID equals v.ValueSet_ID
                       where v.ValueSet_Name == "Test Main Department"
                       select new
                       {
                           d.DataValue_Name,
                           d.DataValue_Description
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
        }
        [WebMethod]
        public static string FillGroupHeaderLevel1()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var dpt = (from d in db.DataValues
                       join v in db.ValueSets
                       on d.ValueSet_ID equals v.ValueSet_ID
                       where v.ValueSet_Name == "Test Group Header L1"
                       select new
                       {
                           d.DataValue_Name,
                           d.DataValue_Description
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
        }
        [WebMethod]
        public static string FillAltrasound_level()
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
        [WebMethod]
        public static string TestMainDepartmentDrpdwn()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var dpt = (from d in db.DataValues
                       join v in db.ValueSets
                       on d.ValueSet_ID equals v.ValueSet_ID
                       where v.ValueSet_Name == "Main Test Departments"
                        & d.DataValue_Description == "Lab Test"
                       select new
                       {
                           d.DataValue_Name,
                           d.DataValue_Description
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
        }
        [WebMethod]
        public static string GetOutSourceLabs()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var Labs = from dv in db.DataValues
                       join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                       where vs.ValueSet_Name == "Out Source Labs"
                       select new { dv.DataValue_Name, dv.DataValue_Description };
            return (new JavaScriptSerializer().Serialize(Labs));
        }
        [WebMethod]
        public static string GetTest(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var test = (from t in db.Lab_Tests
                        where t.Test_ID == id
                        select new
                        {
                            t,
                            t.Group_Header_L0,
                            v = (from tv in db.Test_Values
                                 where tv.Test_ID == id
                                 select new
                                 {
                                     tv.TestValue_ID,
                                     tv.Patient_Type,

                                     Patient_Type_Name = (from d in db.DataValues join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID where v.ValueSet_Name == "Test Patient Types" && d.DataValue_Name == tv.Patient_Type select d.DataValue_Description).FirstOrDefault(),
                                     tv.Start_Range,
                                     tv.End_Range

                                 }).ToList(),
                            IPDTestRate = (from rate in db.Test_Defination_Detail_Rates
                                           where rate.Test_ID == id && rate.Patient_Type.Equals("IPD")
                                           select new
                                           {
                                               rate.Patient_Type,
                                               Patient_Category_Name = db.GetDataValueName("Patient Type", rate.Patient_Category),
                                               rate.Patient_Category,
                                               rate.Test_Rate
                                           }).ToList(),
                            OPDTestRate = (from rate in db.Test_Defination_Detail_Rates
                                           where rate.Test_ID == id && rate.Patient_Type.Equals("OPD")
                                           select new
                                           {
                                               rate.Patient_Type,
                                               Patient_Category_Name = db.GetDataValueName("Patient Type", rate.Patient_Category),
                                               rate.Patient_Category,
                                               rate.Test_Rate,
                                               Out_Source_Lab_ID = (from d in db.DataValues
                                                                    join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID
                                                                    where v.ValueSet_Name == "Out Source Labs" && d.DataValue_Name == t.Out_Source_Lab_ID
                                                                    select d.DataValue_Description).FirstOrDefault(),
                                               Group_Header_L1 = (from d in db.DataValues
                                                                  join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID
                                                                  where v.ValueSet_Name == "Test Group Header L1" && d.DataValue_Name == t.Group_Header_L1
                                                                  select d.DataValue_Description).FirstOrDefault(),

                                           }).ToList(),
                        }).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(test);
        }
        [WebMethod]
        public static string GetGroupDepartments()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dep = from dv in db.DataValues
                      join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                      where vs.ValueSet_Name == "Test Departments"
                      select new { dv.DataValue_Name, dv.DataValue_Description };

            return (new JavaScriptSerializer()).Serialize(dep);
        }
        [WebMethod]
        public static string FillTestGenreDrpdwn()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var dpt = (from d in db.DataValues
                       join v in db.ValueSets
                       on d.ValueSet_ID equals v.ValueSet_ID
                       where v.ValueSet_Name == "Sample Genre"
                       select new
                       {
                           d.DataValue_Name,
                           d.DataValue_Description
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
        }
        [WebMethod]
        public static string FillTestDesignationDrpdwn()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var dpt = (from d in db.DataValues
                       join v in db.ValueSets
                       on d.ValueSet_ID equals v.ValueSet_ID
                       where v.ValueSet_Name == "Designation"
                       select new
                       {
                           d.DataValue_Name,
                           d.DataValue_Description
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
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
        public static string GetUnits()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var units = from dv in db.DataValues
                        join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                        where vs.ValueSet_Name == "Test Units"
                        select new { dv.DataValue_Name, dv.DataValue_Description };

            return (new JavaScriptSerializer()).Serialize(units);
        }
        [WebMethod]
        public static string GetGroups()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var units = from dv in db.DataValues
                        join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                        where vs.ValueSet_Name == "Test Groups"
                        select new { dv.DataValue_Name, dv.DataValue_Description };

            return (new JavaScriptSerializer()).Serialize(units);
        }
        [WebMethod]
        public static string GetPatientTypes()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var types = from dv in db.DataValues
                        join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                        where vs.ValueSet_Name == "Test Patient Types"
                        select new { dv.DataValue_Name, dv.DataValue_Description };

            return (new JavaScriptSerializer()).Serialize(types);
        }
        [WebMethod]
        public static string PatientsCategories()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var PatientsCategory = (from dv in db.DataValues
                                        join vs in db.ValueSets
                                        on dv.ValueSet_ID equals vs.ValueSet_ID
                                        where vs.ValueSet_Name == "Patient Type"
                                        select new
                                        {
                                            dv.DataValue_Name,
                                            dv.DataValue_Description
                                        }).ToList();

                return (new JavaScriptSerializer()).Serialize(PatientsCategory);
            }
        }

        [WebMethod]
        public static string FillXRayLevel()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var dpt = (from d in db.DataValues
                       join v in db.ValueSets
                       on d.ValueSet_ID equals v.ValueSet_ID
                       where v.ValueSet_Name == "X-Ray Format" 
                       select new
                       {
                           d.DataValue_Name,
                           d.DataValue_Description
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
        }

        [WebMethod]
        public static string GetXRayss()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var xrayVal = from dv in db.XRayLevels
                          select new
                          {
                              dv.Test_ID,
                              dv.Levels,
                              dv.XRayLevel_ID,
                              dv.FixValues
                          };

            return (new JavaScriptSerializer()).Serialize(xrayVal);
        }

        [WebMethod]
        public static void SaveXRay(List<XRayValue> xray_values)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            foreach (var item in xray_values)
            {
                if (!string.IsNullOrEmpty(item.XRayLevelID))
                {
                    var itemToUpdate = (from i in db.XRayLevels
                                        where i.XRayLevel_ID == Convert.ToInt32(item.XRayLevelID)
                                        select i).FirstOrDefault();
                    if (itemToUpdate != null)
                    {
                        itemToUpdate.Levels = item.Levels;
                        itemToUpdate.FixValues = item.FixValues;
                    }
                }
                else
                {
                    XRayLevel obj = new XRayLevel();
                    obj.Created_By = AppConfig.UserID;
                    obj.Levels = item.Levels;
                    obj.FixValues = item.FixValues;
                    obj.Created_Time = DateTime.Now;
                    db.XRayLevels.InsertOnSubmit(obj);
                }
            }
            db.SubmitChanges();
        }

        public class XRayValue
        {
            public string Levels { get; set; }
            public string FixValues { get; set; }
            public string XRayLevelID { get; set; }
        }
        public class TestValue
        {
            public string ID { get; set; }
            public string Type { get; set; }
            public string Start { get; set; }
            public string End { get; set; }
        }
        public class test_extra_values
        {
            public string Value { get; set; }
        }
        public class IPDTestRate
        {
            public string Patient_Type { get; set; }
            public string Patient_Category { get; set; }
            public string Test_Rate { get; set; }
        }
        public class OPDTestRate
        {
            public string Patient_Type { get; set; }
            public string Patient_Category { get; set; }
            public string Test_Rate { get; set; }
        }
        public class UltraValue
        {
            public string Levels { get; set; }
            public string FixValues { get; set; }
            public string UltrasoundLevelID { get; set; }
        }

        public class LabTest
        {
            public string ID { get; set; }
            public string Name { get; set; }
            public string MainDepartment { get; set; }
            public string GroupDepartment { get; set; }
            public string SelectedDepartment { get; set; }
            public string Group { get; set; }
            public string Unit { get; set; }
            public string Note { get; set; }
            public string ValueType { get; set; }
            public string Rate { get; set; }
            public bool Active { get; set; }
            public bool cultural { get; set; }
            public string reportColums { get; set; }
            public string FixedValue { get; set; }
            public string out_source_lab_id { get; set; }
            public string Genre { get; set; }
            public string Designation { get; set; }
            public decimal Qty { get; set; }
            public int reporthour { get; set; }
            public string reportDays { get; set; }
            public int GroupOrder { get; set; }
            public string Group_Header_L1 { get; set; }
            public string Altrasound_Level { get; set; }
            public bool chk_value { get; set; }
            public bool chk_template { get; set; }
            public bool chk_listchooseresult { get; set; }
            public bool chk_resultTypeImage { get; set; }
            public bool chk_Levels { get; set; }

            public bool chk_Payment { get; set; }

            public bool Special_Test { get; set; }
            public string WaitingTime { get; set; }
            public List<TestValue> TestValues { get; set; }
            public List<IPDTestRate> IPDTestRates { get; set; }
            public List<OPDTestRate> OPDTestRates { get; set; }
            public List<UltraValue> UltraValues { get; set; }

        }
        [WebMethod]
        public static string GetExtratest(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var extra_test = from dv in db.Lab_Test_Multiple_Values
                             where dv.Test_ID == id
                             select new
                             {
                                 dv.Value
                             };

            return (new JavaScriptSerializer()).Serialize(extra_test);
        }
        [WebMethod]
        public static string GetUltraValues(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var ultraVal = from dv in db.UltraSoundLevels
                           where dv.Test_ID == id.ToString()
                           select new
                           {
                               dv.Test_ID,
                               dv.Levels,
                               dv.UltraSoundLevel_ID,
                               dv.FixValues
                           };

            return (new JavaScriptSerializer()).Serialize(ultraVal);
        }
        [WebMethod]
        public static void SaveUltraSound(List<UltraValue> test_values)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var result = (from i in db.UltraSoundLevels select i).ToList();
            foreach (var item in test_values)
            {
                if (item.UltrasoundLevelID != null)
                {
                    var itemToUpdate = (from i in db.UltraSoundLevels
                                        where i.UltraSoundLevel_ID == Convert.ToInt32(item.UltrasoundLevelID)
                                        select i).FirstOrDefault();
                    itemToUpdate.UltraSoundLevel_ID = Convert.ToInt32(item.UltrasoundLevelID);
                    itemToUpdate.Levels = item.Levels;
                    itemToUpdate.FixValues = item.FixValues;
                    db.SubmitChanges();
                }
                else
                {
                    UltraSoundLevel obj = new UltraSoundLevel();
                    obj.Levels = item.Levels;
                    obj.FixValues = item.FixValues;
                    db.UltraSoundLevels.InsertOnSubmit(obj);
                    db.SubmitChanges();
                }
            }
        }
        [WebMethod]
        public static string GetUltraSound()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var result = (from i in db.UltraSoundLevels
                          select new
                          {
                              i.UltraSoundLevel_ID,
                              i.Levels,
                              i.FixValues
                          }).ToList();
            return (new JavaScriptSerializer()).Serialize(result);
        }
        [WebMethod]
        public static string GetXRays()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var result = (from i in db.UltraSoundLevels
                          select new
                          {
                              i.UltraSoundLevel_ID,
                              i.Levels,
                              i.FixValues
                          }).ToList();
            return (new JavaScriptSerializer()).Serialize(result);
        }

        [WebMethod]
        public static void SaveTest(string test_values, List<test_extra_values> test_extra_values)
        {
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<LabTest>(test_values);

            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            if (record.ID == "(New)")
            {
                Lab_Test test = new Lab_Test();
                test.Test_Name = record.Name;
                test.Main_Department = record.MainDepartment;
                test.Group_Department = record.GroupDepartment;
                test.Group_Header_L0 = record.SelectedDepartment;
                test.Group_Header_L1 = record.Group_Header_L1;
                test.Altrasound_Level = record.Altrasound_Level;
                test.Group_Category = record.Group;
                test.Unit = record.Unit;
                test.Note = record.Note;
                test.Result_Type_Value = record.chk_value;
                test.Chk_Levels = record.chk_Levels;
                test.Payment = record.chk_Payment;
                test.Special_Test = record.Special_Test;
                test.Result_Type_Fixed = record.chk_template;
                test.Result_Type_List = record.chk_listchooseresult;
                test.Result_Type_Image = record.chk_resultTypeImage;
                test.Value_Type = record.ValueType;
                test.Active = record.Active;
                test.Is_Cultural = record.cultural;
                test.Report_Colum = record.reportColums;

                test.Created_By = AppConfig.UserID;
                test.Created_Time = DateTime.Now;
                if (is_admin)
                {
                    test.Rate = Convert.ToDecimal(record.Rate == "" ? "0.0" : record.Rate);
                }

                test.Out_Source_Lab_ID = record.out_source_lab_id;
                test.Genre = record.Genre;
                test.Qty = record.Qty;
                test.Test_Designation = record.Designation;
                test.Reporting_Time = record.reporthour;
                test.Reporting_Day = record.reportDays;
                test.Group_Order = record.GroupOrder;
                test.Fixed_Value = record.FixedValue;
                test.WaitingTime = int.TryParse(record.WaitingTime, out var temp) ? temp : (int?)0;
                db.Lab_Tests.InsertOnSubmit(test);
                db.SubmitChanges();
                var id = test.Test_ID;
                foreach (var test_value in record.TestValues)
                {
                    Test_Value value = new Test_Value();
                    value.Test_ID = id;
                    value.Patient_Type = test_value.Type;
                    value.Start_Range = test_value.Start;
                    value.End_Range = test_value.End;
                    db.Test_Values.InsertOnSubmit(value);
                    db.SubmitChanges();
                }

                foreach (var IPDTestRates in record.IPDTestRates)
                {
                    Test_Defination_Detail_Rate Rates = new Test_Defination_Detail_Rate();
                    Rates.Test_ID = id;
                    Rates.Patient_Type = IPDTestRates.Patient_Type;
                    Rates.Patient_Category = IPDTestRates.Patient_Category;
                    Rates.Test_Rate = Convert.ToInt64(IPDTestRates.Test_Rate);
                    Rates.Created_By = AppConfig.UserID.ToString();
                    Rates.Created_Time = DateTime.Now;
                    db.Test_Defination_Detail_Rates.InsertOnSubmit(Rates);

                    db.SubmitChanges();
                }

                foreach (var OPDTestRates in record.OPDTestRates)
                {
                    Test_Defination_Detail_Rate Rates = new Test_Defination_Detail_Rate();
                    Rates.Test_ID = id;
                    Rates.Patient_Type = OPDTestRates.Patient_Type;
                    Rates.Patient_Category = OPDTestRates.Patient_Category;
                    Rates.Test_Rate = Convert.ToInt64(OPDTestRates.Test_Rate);
                    Rates.Created_By = AppConfig.UserID.ToString();
                    Rates.Created_Time = DateTime.Now;
                    db.Test_Defination_Detail_Rates.InsertOnSubmit(Rates);
                    db.SubmitChanges();
                }
                var idd = test.Test_ID;
                foreach (var extra_test in test_extra_values)
                {
                    Lab_Test_Multiple_Value tests = new Lab_Test_Multiple_Value();
                    tests.Value = extra_test.Value;
                    tests.Test_ID = idd;
                    db.Lab_Test_Multiple_Values.InsertOnSubmit(tests);
                    db.SubmitChanges();
                }

            }
            else
            {
                var test = (from t in db.Lab_Tests
                            where t.Test_ID == int.Parse(record.ID)
                            select t).FirstOrDefault();

                test.Test_Name = record.Name;
                test.Main_Department = record.MainDepartment;
                test.Group_Department = record.GroupDepartment;
                test.Group_Header_L0 = record.SelectedDepartment;
                test.Group_Header_L1 = record.Group_Header_L1;
                test.Altrasound_Level = record.Altrasound_Level;
                test.Group_Category = record.Group;
                test.Unit = record.Unit;
                test.Note = record.Note;
                test.Result_Type_Value = record.chk_value;
                test.Chk_Levels = record.chk_Levels;
                test.Payment = record.chk_Payment;
                test.Result_Type_Fixed = record.chk_template;
                test.Result_Type_List = record.chk_listchooseresult;
                test.Result_Type_Image = record.chk_resultTypeImage;
                test.Value_Type = record.ValueType;
                test.Active = record.Active;
                test.Is_Cultural = record.cultural;
                test.Report_Colum = record.reportColums;
                test.Out_Source_Lab_ID = record.out_source_lab_id;
                test.Genre = record.Genre;
                test.Qty = record.Qty;
                test.Test_Designation = record.Designation;
                test.Reporting_Time = record.reporthour;
                test.Reporting_Day = record.reportDays;
                test.Group_Order = record.GroupOrder;
                test.Updated_By = AppConfig.UserID;
                test.Updated_Time = DateTime.Now;
                test.Special_Test = record.Special_Test;
                if (is_admin)
                {
                    test.Rate = Convert.ToDecimal(record.Rate == "" ? "0.0" : record.Rate);
                }

                test.Fixed_Value = record.FixedValue;
                test.WaitingTime = int.TryParse(record.WaitingTime, out var temp) ? temp : (int?)0;
                db.SubmitChanges();

                db.Test_Values.DeleteAllOnSubmit(
                                (from tv in db.Test_Values
                                 where tv.Test_ID == int.Parse(record.ID)
                                 select tv));
                db.SubmitChanges();

                foreach (var test_value in record.TestValues)
                {
                    Test_Value value = new Test_Value();
                    value.Test_ID = int.Parse(record.ID);
                    value.Patient_Type = test_value.Type;
                    value.Start_Range = test_value.Start;
                    value.End_Range = test_value.End;
                    db.Test_Values.InsertOnSubmit(value);
                    db.SubmitChanges();
                }

                db.UltraSoundLevels.DeleteAllOnSubmit((
                  from ultraVal in db.UltraSoundLevels
                  where ultraVal.Test_ID == test.Test_ID.ToString()
                  select ultraVal));
                db.SubmitChanges();


                db.Test_Defination_Detail_Rates.DeleteAllOnSubmit((
                    from rate in db.Test_Defination_Detail_Rates
                    where rate.Test_ID == int.Parse(record.ID) && rate.Patient_Type.Equals("IPD")
                    select rate).ToList());
                db.SubmitChanges();

                foreach (var IPDTestRates in record.IPDTestRates)
                {
                    Test_Defination_Detail_Rate Rates = new Test_Defination_Detail_Rate();
                    Rates.Test_ID = int.Parse(record.ID);
                    Rates.Patient_Type = IPDTestRates.Patient_Type;
                    Rates.Patient_Category = IPDTestRates.Patient_Category;
                    Rates.Test_Rate = Convert.ToInt64(IPDTestRates.Test_Rate);
                    Rates.Updated_By = AppConfig.UserID.ToString();
                    Rates.Updated_Time = DateTime.Now;
                    db.Test_Defination_Detail_Rates.InsertOnSubmit(Rates);
                    db.SubmitChanges();
                }

                db.Test_Defination_Detail_Rates.DeleteAllOnSubmit((
                    from rate in db.Test_Defination_Detail_Rates
                    where rate.Test_ID == int.Parse(record.ID) && rate.Patient_Type.Equals("OPD")
                    select rate).ToList());
                db.SubmitChanges();

                foreach (var OPDTestRates in record.OPDTestRates)
                {
                    Test_Defination_Detail_Rate Rates = new Test_Defination_Detail_Rate();
                    Rates.Test_ID = int.Parse(record.ID);
                    Rates.Patient_Type = OPDTestRates.Patient_Type;
                    Rates.Patient_Category = OPDTestRates.Patient_Category;
                    Rates.Test_Rate = Convert.ToInt64(OPDTestRates.Test_Rate);
                    Rates.Updated_By = AppConfig.UserID.ToString();
                    Rates.Updated_Time = DateTime.Now;
                    db.Test_Defination_Detail_Rates.InsertOnSubmit(Rates);
                    db.SubmitChanges();
                }
                var idd = test.Test_ID;
                if (record.ID != "(New)")
                {
                    db.Lab_Test_Multiple_Values.DeleteAllOnSubmit(
                             (from tv in db.Lab_Test_Multiple_Values
                              where tv.Test_ID == idd
                              select tv));
                }
                foreach (var extra_test in test_extra_values)
                {
                    Lab_Test_Multiple_Value tests = new Lab_Test_Multiple_Value();
                    tests.Value = extra_test.Value;
                    tests.Test_ID = idd;
                    db.Lab_Test_Multiple_Values.InsertOnSubmit(tests);
                    db.SubmitChanges();
                }
            }
        }
    }
}