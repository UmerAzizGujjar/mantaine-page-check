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
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Labtest = _dbContext.Lab_Tests.Count();
                    var Labtest = from t in _dbContext.Lab_Tests
                                    where ( t.Test_Name.Contains(searchValue) || _dbContext.GetDataValueName("Test Groups", t.Group_Category).Contains(searchValue) || _dbContext.GetDataValueName("Main Test Departments", t.Main_Department).Contains(searchValue) || _dbContext.GetDataValueName("Test Departments", t.Group_Department).Contains(searchValue) ||
                                     _dbContext.GetDataValueName("Test Units", t.Unit).Contains(searchValue))
                                    select new
                                    {
                                        Test_ID = t.Test_ID,
                                        Test_Name = t.Test_Name,
                                        Group_Category = _dbContext.GetDataValueName("Test Groups", t.Group_Category) ?? string.Empty,
                                        Group_Department = _dbContext.GetDataValueName("Test Departments", t.Group_Department),
                                        Main_Department = _dbContext.GetDataValueName("Main Test Departments", t.Main_Department),
                                        Unit = _dbContext.GetDataValueName("Test Units", t.Unit),
                                        Active =  t.Active,
                                    };

                    var FilteredCount = Labtest.Count();
                    switch (sortColumn)
                    {
                        case "Test_Name":
                            Labtest = sortColumnDirection == "asc" ? Labtest.OrderBy(a => a.Test_Name) : Labtest.OrderByDescending(a => a.Test_Name);
                            break;
                        default:
                            Labtest = Labtest.OrderByDescending(a => a.Test_ID);
                            break;
                    }


                    var LabTestList = Labtest.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Labtest, data = LabTestList };
                    return jsonData;
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