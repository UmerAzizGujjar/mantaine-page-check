using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;
using Telerik.Web;

namespace PMS.Modules.PatientManagement
{
    public partial class NewOutPatient : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                BindDropDownList();
            }

        }
        [WebMethod]
        public static string Getdoctors()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from hr in db.HR_Employees
                              where hr.IsDoctor == true && hr.userid == Convert.ToString(AppConfig.UserID)

                              select new
                              {
                                  hr.Emp_ID,
                                  hr.Emp_Name
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }
        [WebMethod]
        public static string PendingPatients(string filterDepartment, string doc_name)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var data = (from p in db.Patients
                        join u in db.aspnet_Users
                        on p.Created_By equals u.UserId
                        where Convert.ToDateTime(p.Created_Time).Month == DateTime.Now.Month &&
                              Convert.ToDateTime(p.Created_Time).Year == DateTime.Now.Year &&
                              Convert.ToDateTime(p.Created_Time).Day == DateTime.Now.Day &&
                              p.Patient_Type == "01"

                        select new
                        {
                            p.Patient_ID,
                            p.Reg_PatId,
                            Patient_No = p.Opd_No,
                            p.Full_Name,
                            p.NIC,
                            DoctorName = (from d in db.HR_Employees
                                          where d.Emp_ID == Convert.ToInt32(p.Doctor_ID)
                                          select d.Emp_Name).FirstOrDefault(),
                            Department = db.GetDataValueName("Patient Main Category", p.Patient_Main_Category),
                            Gender = db.GetDataValueName("Gender", p.Gender),
                            p.Created_Time,
                            u.UserName,
                            p.Age_years,
                            p.Patient_Type,
                            p.Doctor_ID,
                            Checked = ((from op in db.Out_Patients
                                        where op.Patient_ID == p.Patient_ID
                                        && op.Doctor_ID != null && op.Doctor_ID != ""
                                        select op.Doctor_ID).FirstOrDefault()),
                            Token_No = (from t in db.Patients
                                        where t.Patient_ID < p.Patient_ID
                                           && t.Created_Time.Value.Date == p.Created_Time.Value.Date
                                           && t.Created_Time.Value.Month == p.Created_Time.Value.Month
                                           && t.Created_Time.Value.Year == p.Created_Time.Value.Year
                                           && t.Patient_Main_Category == p.Patient_Main_Category
                                        select t).Count() + 1
                        });

            if (!string.IsNullOrEmpty(filterDepartment) && filterDepartment != "0" && doc_name == "0")
            {
                data = data.Where(p => p.Department == db.GetDataValueName("Patient Main Category", filterDepartment));
            }

            else if (!string.IsNullOrEmpty(filterDepartment) && filterDepartment != "0" && !string.IsNullOrEmpty(doc_name))
            {
                data = data.Where(p => p.Department == db.GetDataValueName("Patient Main Category", filterDepartment) && p.Doctor_ID == doc_name);
            }

            else if (!string.IsNullOrEmpty(doc_name) && (string.IsNullOrEmpty(filterDepartment) || filterDepartment == "0"))
            {
                data = data.Where(p => p.Doctor_ID == doc_name);
            }

            var result = data.ToList();
            return (new JavaScriptSerializer()).Serialize(result);
        }
        [WebMethod]
        public static string GetAllDeparmtent()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Patient Main Category"
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
        public static string GetTemplateMedicine(int Templateid)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var dpt = (from dt in db.Doctor_Template_Masters
                       join dtm in db.Doctor_Template_Medicines
                       on dt.Template_Id equals dtm.Template_Id
                       join mt in db.Medicines_Templates
                       on dtm.Medicine_id equals mt.Item_Code
                       where dt.Template_Id == Templateid
                       select new
                       {
                           mt.Medicine_Date,
                           mt.Medicine_Name,
                           mt.Dosage_From,
                           mt.Dosage_Qty,
                           mt.AttendingParamedical_Staff,
                           mt.Item_Code,
                           mt.Other_Instruction,
                           mt.Frequency,
                           mt.Injections,
                           mt.Oral,
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
        }

        [WebMethod]
        public static string GetTemplate(string searchString)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var dpt = (from d in db.Doctor_Template_Masters
                       join hr in db.HR_Employees
on d.Doctor_Id equals hr.Emp_ID
                       where hr.userid == Convert.ToString(AppConfig.UserID) && d.isActive == true
                       select new
                       {
                           d.Template_Id,
                           d.Template_Name
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
        }

        [WebMethod]
        public static string FillRoutesDropDown()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Routes = from d in db.DataValues
                         join v in db.ValueSets
                         on d.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Name == "Routes"
                         select new
                         {
                             d.DataValue_Name,
                             d.DataValue_Description
                         };
            return (new JavaScriptSerializer().Serialize(Routes));
        }
        [WebMethod]
        public static string FillFrequencyDropDown()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Routes = from d in db.DataValues
                         join v in db.ValueSets
                         on d.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Name == "Frequency"
                         select new
                         {
                             d.DataValue_Name,
                             d.DataValue_Description,
                             d.Segment1
                         };
            return (new JavaScriptSerializer().Serialize(Routes));
        }
        [WebMethod]
        public static string FillDosageDropDown()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Routes = from d in db.DataValues
                         join v in db.ValueSets
                         on d.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Name == "Dosage Form"
                         select new
                         {
                             d.DataValue_Name,
                             d.DataValue_Description,

                         };
            return (new JavaScriptSerializer().Serialize(Routes));
        }
        [WebMethod]
        public static string FillDosageQty()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Routes = from d in db.DataValues
                         join v in db.ValueSets
                         on d.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Name == "Dosage Quantity"
                         select new
                         {
                             d.DataValue_Name,
                             d.DataValue_Description,

                         };
            return (new JavaScriptSerializer().Serialize(Routes));
        }
        [WebMethod]
        public static string FillOtherInstruction()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Routes = from d in db.DataValues
                         join v in db.ValueSets
                         on d.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Name == "Other Instruction"
                         select new
                         {
                             d.DataValue_Name,
                             DataValue_Description = d.Segment1,

                         };
            return (new JavaScriptSerializer().Serialize(Routes));
        }
        [WebMethod]
        public static string getpharmacyitems(string searchString)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                IQueryable<INV_Item> query = db.INV_Items.Where(d => d.IsPharmacyItem == false);

                // Only apply the search filter if searchString is not empty
                if (!string.IsNullOrEmpty(searchString))
                {
                    query = query.Where(d => d.Description.Contains(searchString));
                }

                var pharmacyItems = query.OrderByDescending(d => d.Item_ID)
                                       .Select(d => new
                                       {
                                           d.Item_Code,
                                           Description = d.Description
                                       }).Take(10)
                                       .ToList();

                return (new JavaScriptSerializer().Serialize(pharmacyItems));
            }
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
        public static string FillTestsByCategory(string CategoryID, string searchTerm)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var tests = from t in db.Lab_Tests
                        where t.Main_Department == CategoryID && t.Active == true
                        select new { t.Test_ID, t.Test_Name };

            // Apply search filter if searchTerm is not empty
            if (!string.IsNullOrEmpty(searchTerm))
            {
                tests = tests.Where(t => t.Test_Name.ToLower().Contains(searchTerm.ToLower()));
            }

            return (new JavaScriptSerializer()).Serialize(tests);
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
        public static string GetLabTestDDLDetails(string SerialNo, string maindpt)
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
                        where t.Main_Department == maindpt && t.Test_Name == testName && t.Group_Category == groupCategory
                        select new
                        {
                            t.Test_ID,
                            t.Rate, /*= DBClass.getField(""),t.Test_Name*/
                            Test_Name = SerialNo,
                            t.Group_Category,
                            TestMainDepartmentName = db.GetDataValueName("Main Test Departments", t.Main_Department.ToString()).ToString(),
                            GroupCategoryName = db.GetDataValueName("Test Groups", t.Group_Category.ToString()).ToString(),


                        }).ToList();
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
                                       select new
                                       {
                                           Test_ID = 0,
                                           Group_Category = dv.DataValue_Name,
                                           Test_Name = dv.DataValue_Description,
                                           TestMainDepartmentName = "Lab Test",
                                           Main_Department = "001",
                                           Rate = dv.Segment1,


                                       }).ToList();
                return (new JavaScriptSerializer()).Serialize(GroupCategories);

            }
        }
        [WebMethod]
        public static string GetLabTests(string searchValue)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            // Get tests with optional search filter
            var testsQuery = from t in db.Lab_Tests
                             where t.Main_Department == "001"
                             && t.Active == true
                             select t;

            if (!string.IsNullOrEmpty(searchValue))
            {
                testsQuery = testsQuery.Where(t => t.Test_Name.Contains(searchValue));
            }

            var tests = testsQuery.Select(t => new {
                t.Test_ID,
                Test_Name = t.Test_Name,
                t.Group_Category
            });

            List<TestIDsAndGroupCategory> listOfTest = new List<TestIDsAndGroupCategory>();
            int counter = 1;

            // Process tests (same as original)
            foreach (var test in tests)
            {
                TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                obj.TestID = test.Test_ID.ToString();
                obj.TestName = test.Test_Name.ToString() +
                              (test.Group_Category != string.Empty ?
                               " | " + DBClass.getField("select Datavalue_Description from Datavalues where Datavalue_Name = '" + test.Group_Category + "' and Valueset_ID = 70") :
                               string.Empty);
                obj.SerialNo = counter.ToString();
                obj.IsGroupCategory = false;
                listOfTest.Add(obj);
                counter++;
            }

            // Only add categories if no search value (maintain original behavior)
            if (string.IsNullOrEmpty(searchValue))
            {
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
        [WebMethod]
        public static string SaveNewDiagnosis(string Text)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                try
                {

                    // Trim input and check for existing complaint (case-insensitive match)
                    string trimmedText = Text.Trim();

                    bool exists = db.ComplaintsDefinitions
                                    .Any(c => c.ComplaintName.ToLower() == trimmedText.ToLower());

                    if (exists)
                    {
                        return "0";
                    }

                    // Create and insert the new complaint
                    DiagnosisDefinition newDiagnosis = new DiagnosisDefinition
                    {
                        DiagnosisName = trimmedText
                    };

                    db.DiagnosisDefinitions.InsertOnSubmit(newDiagnosis);
                    db.SubmitChanges();

                    return "1";
                }
                catch (Exception ex)
                {
                    // Log the error if needed
                    return "Error saving symptom: " + ex.Message;
                }
            }

        }
        [WebMethod]
        public static string GetDiagnosis(string searchValue)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    IQueryable<DiagnosisDefinition> query = db.DiagnosisDefinitions;

                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        // Filter based on search
                        query = query.Where(c => c.DiagnosisName.ToLower().Contains(searchValue.ToLower()));
                    }
                    else
                    {
                        // If no search, take top 6
                        query = query.Take(6);
                    }

                    // Select only necessary fields
                    var result = query
                        .Select(c => new
                        {
                            DiagnosisId = c.ID,
                            DiagnosisName = c.DiagnosisName
                        })
                        .ToList();

                    return new JavaScriptSerializer().Serialize(result);
                }
            }
            catch (Exception ex)
            {
                // Log error
                System.Diagnostics.Debug.WriteLine($"Error in GetComplaints: {ex}");
                return "[]"; // Return empty array on error
            }
        }

        [WebMethod]
        public static string GetComplaints(string searchValue)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    IQueryable<ComplaintsDefinition> query = db.ComplaintsDefinitions;

                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        // Filter based on search
                        query = query.Where(c => c.ComplaintName.ToLower().Contains(searchValue.ToLower()));
                    }
                    else
                    {
                        // If no search, take top 6
                        query = query.Take(6);
                    }

                    // Select only necessary fields
                    var result = query
                        .Select(c => new
                        {
                            ComplaintId = c.ID,
                            ComplaintName = c.ComplaintName
                        })
                        .ToList();

                    return new JavaScriptSerializer().Serialize(result);
                }
            }
            catch (Exception ex)
            {
                // Log error
                System.Diagnostics.Debug.WriteLine($"Error in GetComplaints: {ex}");
                return "[]"; // Return empty array on error
            }
        }

        [WebMethod]
        public static string SaveNewComplaint(string complaintText)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                try
                {

                    // Trim input and check for existing complaint (case-insensitive match)
                    string trimmedComplaint = complaintText.Trim();

                    bool exists = db.ComplaintsDefinitions
                                    .Any(c => c.ComplaintName.ToLower() == trimmedComplaint.ToLower());

                    if (exists)
                    {
                        return "0";
                    }

                    // Create and insert the new complaint
                    ComplaintsDefinition newComplaint = new ComplaintsDefinition
                    {
                        ComplaintName = trimmedComplaint
                    };

                    db.ComplaintsDefinitions.InsertOnSubmit(newComplaint);
                    db.SubmitChanges();

                    return "1";
                }
                catch (Exception ex)
                {
                    // Log the error if needed
                    return "Error saving symptom: " + ex.Message;
                }
            }

        }
        [WebMethod]
        public static string LoadDoctor()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var doctor = (from emp in db.HR_Employees

                              where emp.Resign_Date == null && emp.IsDoctor == true
                              select new { emp.Emp_ID, emp.Emp_Name }).ToList();
                return (new JavaScriptSerializer()).Serialize(doctor);
            }
            return "";
        }
        [WebMethod]
        public static string LoadDoctor_bydep(string depart)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var doctor = (from emp in db.HR_Employees

                              where emp.Department == depart && emp.IsDoctor == true
                              select new { emp.Emp_ID, emp.Emp_Name }).ToList();
                return (new JavaScriptSerializer()).Serialize(doctor);
            }
            return "";
        }
        [WebMethod]
        public static string LoadDesignation(int DocID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var Designation = (from emp in db.HR_Employees

                                   where emp.Emp_ID == DocID && emp.Resign_Date == null && emp.IsDoctor == true
                                   select new { Emp_designatin = db.GetDataValueName("Designation", emp.Designation), }).FirstOrDefault();
                return (new JavaScriptSerializer()).Serialize(Designation);
            }
            return "";
        }
        private void BindDropDownList()
        {
            object valueset;   //declare a single object for all valueset            
            valueset = DBClass.GetValueSet("Patient Status");
            DataBaseDataContext db = new DataBaseDataContext();
            List<HR_Employee> EmpList = new List<HR_Employee>();
            EmpList = (from tbl in db.HR_Employees
                       where tbl.IsDoctor == true
                       select tbl).ToList();

            valueset = DBClass.GetValueSet("FollowUp");
            ddlFOllowUp.DataSource = valueset;
            ddlFOllowUp.DataTextField = "DataValue_Description";
            ddlFOllowUp.DataValueField = "DataValue_Name";
            ddlFOllowUp.Items.Add(new ListItem("Please Select", "0"));
            ddlFOllowUp.DataBind();

            valueset = DBClass.GetValueSet("Proto");
            ddlProto.DataSource = valueset;
            ddlProto.DataTextField = "DataValue_Description";
            ddlProto.DataValueField = "DataValue_Name";
            ddlProto.Items.Add(new ListItem("Please Select", "0"));
            ddlProto.DataBind();

            valueset = DBClass.GetValueSet("Laundary From To");
            ddlIssuance_Of.DataSource = valueset;
            ddlIssuance_Of.DataTextField = "DataValue_Description";
            ddlIssuance_Of.DataValueField = "DataValue_Name";
            ddlIssuance_Of.Items.Add(new ListItem("Please Select", "0"));
            ddlIssuance_Of.DataBind();

            valueset = DBClass.GetValueSet("Patient Main Category");
            ddlPatient_Main_Category.DataSource = valueset;
            ddlPatient_Main_Category.DataTextField = "DataValue_Description";
            ddlPatient_Main_Category.DataValueField = "DataValue_Name";
            ddlPatient_Main_Category.Items.Add(new ListItem("Please Select", "0"));
            ddlPatient_Main_Category.DataBind();
        }

            [WebMethod]
        public static string SaveNewSymptom(string name)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                try
                {
                    // Get the maximum DataValueName where ValueSet_ID = 1083
                    int? maxValue = db.DataValues
                        .Where(dv => dv.ValueSet_ID == 1083)
                        .Max(dv => (int?)Convert.ToInt32((dv.DataValue_Name)));

                    // If no records found, start with 1, otherwise increment the max value
                    int newValue = (maxValue.HasValue) ? maxValue.Value + 1 : 1;

                    // Create new DataValue record
                    DataValue newSymptom = new DataValue
                    {
                        ValueSet_ID = 1083,
                        DataValue_Name = newValue.ToString(),
                        DataValue_Description = name,
                        // Add other required fields with default values if needed
                        // For example:
                        // IsActive = true,
                        // CreatedDate = DateTime.Now
                    };

                    db.DataValues.InsertOnSubmit(newSymptom);
                    db.SubmitChanges();

                    return "Symptom saved successfully";
                }
                catch (Exception ex)
                {
                    // Log the error if needed
                    return "Error saving symptom: " + ex.Message;
                }
            }
        }
        [WebMethod]
        public static string GetCategorizedSymptoms(string categoryId, string searchValue)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    // Base query
                    var query = from dv in db.DataValues
                                join ds in db.ValueSets on dv.ValueSet_ID equals ds.ValueSet_ID
                                join sc in db.SymptomsCategorizations on dv.DataValue_Name equals sc.SymptomId
                                where ds.ValueSet_Name == "Symtoms" 
                                      && sc.CategoryId == categoryId
                                select new
                                {
                                    SymptomId = sc.SymptomId,
                                    Description = dv.DataValue_Description,
                                    
                                };

                    // Apply search filter if provided
                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        query = query.Where(x => x.Description.ToLower().Contains(searchValue.ToLower()));
                    }

                    // Execute query based on categoryId
                    var resultList = query.ToList();
                    

                    return new JavaScriptSerializer().Serialize(resultList);
                }
            }
            catch (Exception ex)
            {
                // Log error
                System.Diagnostics.Debug.WriteLine($"Error in GetCategorizedSymptoms: {ex}");
                return "[]"; // Return empty array on error
            }
        }

        [WebMethod]
        public static string GetSymptoms(string searchValue)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var query = from dv in db.DataValues
                        join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                        where vs.ValueSet_Name == "Symtoms"
                        select dv;

            // If searchValue is not null or empty, apply the filter
            if (!string.IsNullOrEmpty(searchValue))
            {
                query = query.Where(dv => dv.DataValue_Description.ToLower().Contains(searchValue.ToLower())).Take(5);
            }
            else
            {
                // Return only 5 records when no search value is provided
                query = query.Take(5);
            }

            // Project to anonymous type to avoid serialization issues
            var result = query.Select(dv => new {
                DataValue_Name = dv.DataValue_Name,
                DataValue_Description = dv.DataValue_Description
                // Add other fields you need
            }).ToList();

            return (new JavaScriptSerializer()).Serialize(result);
        }
        
        [WebMethod]
        public static string GetDepartment()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Patient Main Category"
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
        public static bool SaveSymptoms(List<SymptomData> symptoms)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    // 1. Delete ALL existing symptom categorizations
                    db.SymptomsCategorizations.DeleteAllOnSubmit(db.SymptomsCategorizations);
                    db.SubmitChanges();
                    foreach (var symptom in symptoms)
                    {

                        SymptomsCategorization newSymptom = new SymptomsCategorization
                        {
                            CategoryId = symptom.DepartmentId,
                            SymptomId = symptom.SymptomId,
                            CreatedBy = AppConfig.UserID.ToString(),
                            CreatedTime = DateTime.Now
                        };
                        db.SymptomsCategorizations.InsertOnSubmit(newSymptom);

                        db.SubmitChanges();
                    }
                }
                return true;
            }
            catch (Exception ex)
            {
                
                return false;
            }
        }
        [WebMethod]
        public static string GetSymptomsData()
        {
            try
            {
                
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var result = (from dv in db.DataValues
                                  join ds in db.ValueSets on dv.ValueSet_ID equals ds.ValueSet_ID
                                  join sc in db.SymptomsCategorizations on dv.DataValue_Name equals sc.SymptomId
                                  where ds.ValueSet_Name == "Symtoms" 
                                  select new
                                  {
                                      SymptomId = sc.SymptomId,
                                      Description = dv.DataValue_Description,
                                      CategoryId = sc.CategoryId
                                  }).ToList();

                    return new JavaScriptSerializer().Serialize(result);
                }
               

            }
            catch (Exception ex)
            {
                return "[]";
            }
        }
        public class SymptomData
        {
            public string DepartmentId { get; set; }
            public string SymptomId { get; set; }
        }
    }
}