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
                else if(res.Test_ID != null)
                {
                    PanelDetailServ obj = new PanelDetailServ();
                    obj.PanelID = res.Panel_ID.ToString();
                    obj.ItemID = res.Item_ID;
                    obj.Rate = Convert.ToDecimal(res.Rate);
                    obj.GroupCategory = res.GroupCategory;
                    obj.TestID = res.Test_ID;
                    obj.Description = (from lt in db.Lab_Tests
                                       where lt.Test_ID == Convert.ToInt32(res.Test_ID)
                                       select lt.Test_Name).FirstOrDefault();
                    if (obj.Description == null)
                    {
                        obj.Description = db.GetDataValueName("Test Groups", res.GroupCategory);

                    }
                    listObj.Add(obj);
                    counter++;
                }
            }
            data = (new JavaScriptSerializer()).Serialize(listObj);
            return data;
        }

        [WebMethod]
        public static string Save(string cmp_name, string no_of_emp, string email, string contact_no,string Glcode, string address, string discount,decimal panelrate, string btnValue, string id, string[][] rateDetail)
        {
            int lstid = 0;
            Panel panel;
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            if (btnValue == "Save")
            {
                panel = new Panel();
            }
            else
            {
                panel = (from tbl in db.Panels
                         where tbl.Panel_ID == Convert.ToInt32(id)
                         select tbl).FirstOrDefault();
                panel.Updated_By = AppConfig.UserID;
                panel.Updated_Time = DateTime.Now;

            }
            panel.Address = address;
            panel.Company_Name = cmp_name;
            panel.gl_account = Convert.ToInt32(Glcode);
            panel.Contact_No = contact_no;
            panel.Discount = Convert.ToDecimal(discount);
            panel.Email = email;
            panel.Panel_Rate = panelrate;
            panel.No_Of_Employees = Convert.ToInt32(no_of_emp);
            panel.Created_Time = DateTime.Now;
            panel.Created_By = AppConfig.UserID;
            if (btnValue == "Save")
            {
                panel.Created_By = AppConfig.UserID;
                panel.Created_Time = DateTime.Now;
                db.Panels.InsertOnSubmit(panel);
                db.SubmitChanges();
            }
            else
            {
                string sql = "Delete from Panel_Detail_Services where Panel_ID = " + panel.Panel_ID.ToString() + "";
                DBClass.executeNonQueryWithoutBegin(sql);
            }
            for (int i = 1; i < rateDetail.Length; i++)
            {
                if (rateDetail[i][2].ToString().Trim() == "null" || rateDetail[i][2].ToString().Trim() == "undefined")
                {
                    Panel_Detail_Service pds = new Panel_Detail_Service();
                    pds.Panel_ID = panel.Panel_ID;
                    pds.Item_ID = rateDetail[i][0].ToString();
                    pds.Item_Code = Convert.ToInt32(DBClass.getField("Select Item_Code from inv_items i where i.item_ID = " + pds.Item_ID + ""));
                    pds.Rate = Convert.ToInt32(rateDetail[i][1]);
                    db.Panel_Detail_Services.InsertOnSubmit(pds);
                }
                else if (rateDetail[i][2].ToString().Trim() != null)
                {
                    Panel_Detail_Service pds = new Panel_Detail_Service();
                    pds.Panel_ID = panel.Panel_ID;
                
                    pds.Item_Code = 0;
                    pds.Rate = Convert.ToInt32(rateDetail[i][1]);
                    pds.GroupCategory = rateDetail[i][2];
                    pds.Test_ID = rateDetail[i][3];
                    db.Panel_Detail_Services.InsertOnSubmit(pds);
                }
            }
            db.SubmitChanges();
            if (btnValue == "Save")
            {
                lstid = panel.Panel_ID;
            }
            else
            {
                lstid = Convert.ToInt32(id);
            }

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
                             {   i.Item_ID, 
                                 name = i.Item_Code.ToString() 
                                 + '-' + i.Description
                             }).ToList();
            if (itemsList != null)
            {
                result = (new JavaScriptSerializer()).Serialize(itemsList);
            }
            return result;
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