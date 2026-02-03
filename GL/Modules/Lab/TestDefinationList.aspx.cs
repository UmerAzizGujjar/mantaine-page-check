using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static Telerik.Web.UI.ComboBox.ComboBoxStyles;

namespace PMS
{
    public partial class TestDefinationList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

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
        public static string GetTestGroups()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dep = from dv in db.DataValues
                      join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                      where vs.ValueSet_Name == "Test Groups"
                      select new { dv.DataValue_Name, dv.DataValue_Description };

            return (new JavaScriptSerializer()).Serialize(dep);
        }
        [WebMethod]
        public static string GroupDepartment()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dep = from dv in db.DataValues
                      join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                      where vs.ValueSet_Name == "Test Departments"
                      select new { dv.DataValue_Name, dv.DataValue_Description };

            return (new JavaScriptSerializer()).Serialize(dep);
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
        public static object ViewList(
    int draw,
    int start,
    int length,
    string sortColumn,
    string sortColumnDirection,
    string searchValue,
    string mainDepartmentId,   // NEW
    string groupCategoryId,    // NEW
    string groupDepartmentId   // NEW
)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"]?.ToString();

                    var baseQuery = _dbContext.Lab_Tests.AsQueryable();

                    // Apply search filter (existing)
                    if (!string.IsNullOrWhiteSpace(searchValue))
                    {
                        searchValue = searchValue.Trim();
                        baseQuery = baseQuery.Where(t =>
                            t.Test_Name.Contains(searchValue) ||
                            _dbContext.GetDataValueName("Test Groups", t.Group_Category).Contains(searchValue) ||
                            _dbContext.GetDataValueName("Main Test Departments", t.Main_Department).Contains(searchValue) ||
                            _dbContext.GetDataValueName("Test Departments", t.Group_Department).Contains(searchValue) ||
                            _dbContext.GetDataValueName("Test Units", t.Unit).Contains(searchValue)
                        );
                    }

                    // ✅ NEW: Apply department/category filters
                    if (!string.IsNullOrWhiteSpace(mainDepartmentId))
                        baseQuery = baseQuery.Where(t => t.Main_Department == mainDepartmentId);

                    if (!string.IsNullOrWhiteSpace(groupCategoryId))
                        baseQuery = baseQuery.Where(t => t.Group_Category == groupCategoryId);

                    if (!string.IsNullOrWhiteSpace(groupDepartmentId))
                        baseQuery = baseQuery.Where(t => t.Group_Department == groupDepartmentId);

                    // Total counts BEFORE pagination (for recordsTotal & recordsFiltered)
                    var Total_Labtest = _dbContext.Lab_Tests.Count(); // total in DB (unfiltered)
                    var FilteredCount = baseQuery.Count(); // after filters

                    // Projection — keep this clean and match property names
                    var Labtest = baseQuery.Select(t => new
                    {
                        Test_ID = t.Test_ID,
                        Test_Name = t.Test_Name,
                        Group_Category = _dbContext.GetDataValueName("Test Groups", t.Group_Category) ?? string.Empty,
                        Group_Department = _dbContext.GetDataValueName("Test Departments", t.Group_Department) ?? string.Empty,
                        Main_Department = _dbContext.GetDataValueName("Main Test Departments", t.Main_Department) ?? string.Empty,
                        Unit = _dbContext.GetDataValueName("Test Units", t.Unit) ?? string.Empty,
                        Active = t.Active,
                        Rate = t.Rate
                    });

                    // Sorting
                    switch (sortColumn)
                    {
                        case "Test_Name":
                            Labtest = sortColumnDirection == "asc"
                                ? Labtest.OrderBy(a => a.Test_Name)
                                : Labtest.OrderByDescending(a => a.Test_Name);
                            break;
                        case "Main_Department":
                            Labtest = sortColumnDirection == "asc"
                                ? Labtest.OrderBy(a => a.Main_Department)
                                : Labtest.OrderByDescending(a => a.Main_Department);
                            break;
                        case "Group_Category":
                            Labtest = sortColumnDirection == "asc"
                                ? Labtest.OrderBy(a => a.Group_Category)
                                : Labtest.OrderByDescending(a => a.Group_Category);
                            break;
                        case "Group_Department":
                            Labtest = sortColumnDirection == "asc"
                                ? Labtest.OrderBy(a => a.Group_Department)
                                : Labtest.OrderByDescending(a => a.Group_Department);
                            break;
                        default:
                            Labtest = Labtest.OrderByDescending(a => a.Test_ID);
                            break;
                    }

                    var LabTestList = Labtest.Skip(start).Take(length).ToList();

                    return new
                    {
                        draw,
                        recordsTotal = Total_Labtest,
                        recordsFiltered = FilteredCount,
                        data = LabTestList
                    };
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Lab list", ex);
            }
        }


        [WebMethod]
        public static bool changeActiveStatus(int testID, bool activeStatus)
        {
            bool status = false;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                Lab_Test labTest = new Lab_Test();
                if (labTest != null)
                {
                    labTest = (from t in db.Lab_Tests where t.Test_ID == testID select t).FirstOrDefault();
                    labTest.Active = activeStatus;
                    db.SubmitChanges();
                    status = true;
                }
            }
            return status;
        }

        [WebMethod]
        [ScriptMethod(UseHttpGet = false, ResponseFormat = ResponseFormat.Json)]
        public static string DeleteTest(int id)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    string AllowPatientDelete = DBClass.getField("select dbo.GetRights('AllowPatientDelete','" + AppConfig.UserID + "')");

                    if (Convert.ToBoolean(AllowPatientDelete))
                    {
                        var testValues = db.Test_Values.Where(tv => tv.Test_ID == id).ToList();
                        db.Test_Values.DeleteAllOnSubmit(testValues);

                        db.SubmitChanges();

                        var labTest = db.Lab_Tests.FirstOrDefault(t => t.Test_ID == id);
                        if (labTest != null)
                        {
                            db.Lab_Tests.DeleteOnSubmit(labTest);
                            db.SubmitChanges();
                            return "success";
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                
            }
            return "error";
        }
    }
}