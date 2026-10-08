using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class panelagreement : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string loadData(int panelID)
        {
            string data = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            List<PanelDetailServ> listObj = new List<PanelDetailServ>();

            var result = (from pds in db.Panel_Detail_Services
                          where pds.Panel_ID == panelID
                          select pds).ToList();
            int counter = 1;
            foreach (var res in result)
            {
                if (res.Test_ID == null)
                {
                    PanelDetailServ obj = new PanelDetailServ();
                    obj.PanelID = res.Panel_ID.ToString();
                    obj.ItemID = res.Item_ID;
                    obj.Rate = Convert.ToDecimal(res.Rate);
                    obj.GroupCategory = res.GroupCategory;
                    obj.TestID = res.Test_ID;
                    obj.Description = (from i in db.INV_Items
                                       where i.Item_ID == Convert.ToInt32(res.Item_ID)
                                       select i.Description).FirstOrDefault();
                    listObj.Add(obj);
                    counter++;
                }
                else if (res.Test_ID != null)
                {
                    if (res.Test_ID == res.GroupCategory)
                    {
                        PanelDetailServ obj = new PanelDetailServ();
                        obj.PanelID = res.Panel_ID.ToString();
                        obj.ItemID = res.Item_ID;
                        obj.Rate = Convert.ToDecimal(res.Rate);
                        obj.GroupCategory = res.GroupCategory;
                        obj.TestID = res.Test_ID;

                       
                            obj.Description = db.GetDataValueName("Test Groups", res.GroupCategory);

                        
                        listObj.Add(obj);
                        counter++;
                    }
                    else {
                        PanelDetailServ obj = new PanelDetailServ();
                        obj.PanelID = res.Panel_ID.ToString();
                        obj.ItemID = res.Item_ID;
                        obj.Rate = Convert.ToDecimal(res.Rate);
                        obj.GroupCategory = res.GroupCategory;
                        obj.TestID = res.Test_ID;
                        obj.Description = (from lt in db.Lab_Tests
                                           where lt.Test_ID == Convert.ToInt32(res.Test_ID)
                                           select lt.Test_Name).FirstOrDefault();
             
                        listObj.Add(obj);
                        counter++;
                    }
                    
                }
            }
            data = (new JavaScriptSerializer()).Serialize(listObj);
            return data;
        }

        [WebMethod]
        public static string Save(string cmp_name, string no_of_emp, string email, string contact_no, string Glcode, string address, string discount, decimal panelrate, decimal panelrateEmergency, string btnValue, string id, string[][] rateDetail)
        {
            int lstid = 0;
            Panel panel;
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            if (btnValue == "Save" || btnValue == "Replicate")
            {
                panel = new Panel();
                panel.Created_By = AppConfig.UserID;
                panel.Created_Time = DateTime.Now;
                db.Panels.InsertOnSubmit(panel);
            }
            else
            {
                panel = (from tbl in db.Panels
                         where tbl.Panel_ID == Convert.ToInt32(id)
                         select tbl).FirstOrDefault();

                if (panel == null) return "Error: Panel not found";

                panel.Updated_By = AppConfig.UserID;
                panel.Updated_Time = DateTime.Now;
            }

            panel.Address = address;
            panel.Company_Name = cmp_name;
            panel.gl_account = string.IsNullOrEmpty(Glcode) ? 0 : Convert.ToInt32(Glcode);
            panel.Contact_No = contact_no;
            panel.Discount = string.IsNullOrEmpty(discount) ? 0 : Convert.ToDecimal(discount);
            panel.Email = email;
            panel.Panel_Rate = panelrate;
            panel.Panel_Rate_Emergency = panelrateEmergency;
            panel.No_Of_Employees = string.IsNullOrEmpty(no_of_emp) ? 0 : Convert.ToInt32(no_of_emp);

            if (btnValue == "Save" || btnValue == "Replicate")
            {
                db.SubmitChanges(); 
            }

            // Build every detail row first, so a bad value fails before the old rows are deleted
            var newDetails = new List<Panel_Detail_Service>();
            for (int i = 1; i < rateDetail.Length; i++)
            {
                if (rateDetail[i] == null || rateDetail[i].Length < 2) continue;

                string itemIDVal = rateDetail[i][0].ToString().Trim();
                string rateVal = rateDetail[i][1].ToString().Trim();
                string groupCatVal = rateDetail[i].Length > 2 ? rateDetail[i][2].ToString().Trim() : "";
                string testIDVal = rateDetail[i].Length > 3 ? rateDetail[i][3].ToString().Trim() : "";
                decimal rate = 0;
                if (!string.IsNullOrEmpty(rateVal) && !decimal.TryParse(rateVal, NumberStyles.Number, CultureInfo.InvariantCulture, out rate))
                    throw new Exception("Invalid rate '" + rateVal + "'. Please enter a number.");

                if (!string.IsNullOrEmpty(itemIDVal) && itemIDVal != "0")
                {
                    Panel_Detail_Service pds = new Panel_Detail_Service();
                    pds.Panel_ID = panel.Panel_ID;
                    pds.Item_ID = itemIDVal;
                    int itemKey;
                    int itemCode = 0;
                    if (int.TryParse(itemIDVal, out itemKey))
                    {
                        string codeVal = Convert.ToString(DBClass.getField("Select Item_Code from inv_items i where i.item_ID = " + itemKey));
                        int.TryParse(codeVal, out itemCode);
                    }
                    pds.Item_Code = itemCode;

                    pds.Rate = rate;
                    pds.GroupCategory = null;
                    pds.Test_ID = null;

                    newDetails.Add(pds);
                }
                else if (!string.IsNullOrEmpty(groupCatVal) || !string.IsNullOrEmpty(testIDVal))
                {
                    Panel_Detail_Service pds = new Panel_Detail_Service();
                    pds.Panel_ID = panel.Panel_ID;
                    pds.Item_ID = null;
                    pds.Item_Code = 0;
                    pds.Rate = rate;
                    pds.GroupCategory = groupCatVal;
                    pds.Test_ID = testIDVal;

                    newDetails.Add(pds);
                }
            }

            if (btnValue != "Save" && btnValue != "Replicate")
            {
                string sql = "Delete from Panel_Detail_Services where Panel_ID = " + panel.Panel_ID.ToString();
                DBClass.executeNonQueryWithoutBegin(sql);
            }
            db.Panel_Detail_Services.InsertAllOnSubmit(newDetails);

            db.SubmitChanges();

            lstid = panel.Panel_ID;
            return lstid.ToString();
        }
        [WebMethod]
        public static string GetGLAccounts()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from account in db.GL_Accounts
                              where account.Levels == 4
                              select new
                              {
                                  account.Account_ID,
                                  account.Account_Name,
                                  account.Parent_Code,
                              }).ToList();

                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        [WebMethod]
        public static string LoadPanelData(string id)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var query = (from data in db.Panels.Where(x => x.Panel_ID == Convert.ToInt32(id)) select data).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(query);
        }

        [WebMethod]
        public static string loadItemtList()
        {
            string result = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            var itemsList = (from i in db.INV_Items
                             where (i.Services == true || i.Hospital_Services == true || i.IsBill_Item == true || i.Procedure_types != "0")
                             select new
                             {
                                 i.Item_ID,
                                 name = i.Item_Code.ToString()
                                 + '-' + i.Description
                             }).ToList();
            if (itemsList != null)
            {
                result = (new JavaScriptSerializer()).Serialize(itemsList);
            }
            return result;
        }
        // Medicines are INV_Items flagged IsPharmacyItem (~27k rows), so the dropdown searches on demand
        [WebMethod]
        public static string SearchMedicines(string term)
        {
            term = (term ?? "").Trim();
            DataBaseDataContext db = new DataBaseDataContext();
            var medicines = (from i in db.INV_Items
                             where i.IsPharmacyItem == true
                                   && (i.isCancel == null || i.isCancel == false)
                                   && (i.Is_Active == true)
                                   && (i.Description.Contains(term) || i.Item_Code.ToString().Contains(term))
                             orderby i.Description
                             select new
                             {
                                 id = i.Item_ID,
                                 text = i.Item_Code.ToString() + " - " + i.Description,
                                 description = i.Description
                             }).Take(50).ToList();
            return (new JavaScriptSerializer()).Serialize(medicines);
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
        public static string FillTestsByCategory(string CategoryID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var tests = from t in db.Lab_Tests
                        where t.Main_Department == CategoryID && t.Active == true
                        select new { t.Test_ID, t.Test_Name, t.Group_Category };

            return (new JavaScriptSerializer()).Serialize(tests);
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
                obj.TestName = test.Test_Name.ToString();

                obj.SerialNo = counter.ToString();
                obj.IsGroupCategory = false;
                obj.GroupCategory = test.Group_Category;
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
                obj.GroupCategory = category.DataValue_Name;
                listOfTest.Add(obj);
                counter++;
            }

            return (new JavaScriptSerializer()).Serialize(listOfTest);
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
            public string GroupCategory { get; set; }
        }
        public class PanelDetailServ
        {
            public string PanelDetailServiceID { get; set; }
            public string PanelID { get; set; }
            public string ItemID { get; set; }
            public string ItemCode { get; set; }
            public decimal Rate { get; set; }
            public string GroupCategory { get; set; }
            public string TestID { get; set; }
            public string Description { get; set; }
        }
    }
}