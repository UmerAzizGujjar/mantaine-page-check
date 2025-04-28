using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Script.Serialization;
using System.Web.Services;

namespace PMS
{
    public partial class ItemAccountCategory : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            
            if (!IsPostBack)
            {
               
                ClearForm();
                if (Request.QueryString["ID"] != null)
                {
                    FillCustomerForm(Convert.ToInt32(Request.QueryString["ID"]));
                }

            }
            lblMessage.Text = "";
        }

        private void FillCustomerForm(int Item_Account_CategoryID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            INV_Item_Account_Category item_account_Category = new INV_Item_Account_Category();

            item_account_Category = (from tbl in db.INV_Item_Account_Categories
                                     where tbl.Category_ID == Item_Account_CategoryID
                                     select tbl).FirstOrDefault();
            if (item_account_Category != null)
            {
                txtItem_ID.Text = Convert.ToString(Item_Account_CategoryID);
                txtItem_Name.Text = item_account_Category.Category_Name;
                btnSave.Text = "Update";
            }
        }

        private void ClearForm()
        {
            txtItem_ID.Text = "(New)";
            txtItem_Name.Text = "";
          
            btnSave.Text = "Save";
        }


        protected void btnNew_Click(object sender, EventArgs e)
        {
            if (Request.QueryString["ID"] != null)
            {
                Response.Redirect("~/ItemAccountCategory.aspx", false);
            }

            ClearForm();
        }



        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                lblMessage.Text = "";
                if (!Page.IsValid)
                    return;
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                INV_Item_Account_Category INV_Item_Account_Category;

                if (btnSave.Text == "Save")
                {
                    INV_Item_Account_Category = new INV_Item_Account_Category();
                }
                else
                {

                    #region "Edit"

                    INV_Item_Account_Category = (from tbl in db.INV_Item_Account_Categories
                                                 where tbl.Category_ID == Convert.ToInt32(txtItem_ID.Text)
                                                 select tbl).SingleOrDefault();

                    INV_Item_Account_Category.Updated_By = AppConfig.UserID;
                    INV_Item_Account_Category.Updated_Time  = DateTime.Now;
                    
                    #endregion
                    

                }

                INV_Item_Account_Category.Created_By = AppConfig.UserID;
                INV_Item_Account_Category.Created_Time = DateTime.Now;
                INV_Item_Account_Category.Book_ID = AppConfig.Book_ID;
                INV_Item_Account_Category.Company_ID = AppConfig.Company_ID;
                
                   
                if (btnSave.Text == "Save")
                {
                    db.INV_Item_Account_Categories.InsertOnSubmit(INV_Item_Account_Category);
                    lblMessage.Text = "Data has been save successfully";
                }
                else
                {
                    lblMessage.Text = "Data has been update successfully";
                }
                db.SubmitChanges();

                ClearForm();
                Response.Redirect("~/inventory/ItemAccountCategoryView.aspx", true);
                lblMessage.CssClass = "sucessfullMessage";
            }
            catch (Exception ex)
            {

                throw ex;
            }
        }
        [WebMethod]
        public static string GetDepartments()
        {
            var Accounts = DBClass.getDataTable("select Account_ID,Account_Code,Account_Name,Levels from gl_accounts where left(account_code,1)=6 and levels=2");
            List<GL_Account> ListAccounts = new List<GL_Account>();
            foreach (DataRow item in Accounts.Rows)
            {
                GL_Account ac = new GL_Account();
                ac.Account_ID = Convert.ToInt32(item["Account_ID"]);
                ac.Account_Code = item["Account_Code"].ToString();
                ac.Account_Name = item["Account_Name"].ToString();
                ListAccounts.Add(ac);
            }
            return (new JavaScriptSerializer()).Serialize(ListAccounts);
        }
        [WebMethod]
        public static string GetAccountsByDepartments(int DeptID)
        {
            var Accounts = DBClass.getDataTable("select Account_ID,Account_Code,Account_Name,Levels from gl_accounts where left(account_code,1)=6 and parent_code="+DeptID+" and levels=4");
            List<GL_Account> ListAccounts = new List<GL_Account>();
            foreach (DataRow item in Accounts.Rows)
            {
                GL_Account ac = new GL_Account();
                ac.Account_ID = Convert.ToInt32(item["Account_ID"]);
                ac.Account_Code = item["Account_Code"].ToString();
                ac.Account_Name = item["Account_Name"].ToString();
                ListAccounts.Add(ac);
            }
            return (new JavaScriptSerializer()).Serialize(ListAccounts);
        }

        [WebMethod]
        public static void SaveData(string data)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            JavaScriptSerializer js = new JavaScriptSerializer();
            var dta = js.Deserialize<ItemAccountCategoryTemp>(data);

            INV_Item_Account_Category itemAccCat;

            if (dta.CatID == 0)
            {
                itemAccCat = new PMS.INV_Item_Account_Category();
                itemAccCat.Category_Name = dta.CatName;
                db.INV_Item_Account_Categories.InsertOnSubmit(itemAccCat);
                db.SubmitChanges();

                if (dta.CatID != 0)
                {
                    itemAccCat = db.INV_Item_Account_Categories.Where(i => i.Category_ID == dta.CatID).FirstOrDefault();
                    itemAccCat.Category_Name = dta.CatName;

                    var details = db.INV_Item_Account_Category_Details.Where(id => dta.CatID == id.Category_ID).ToList();
                    db.INV_Item_Account_Category_Details.DeleteAllOnSubmit(details);
                    db.SubmitChanges();
                }

                foreach (AccountsList item in dta.AccountsList)
                {
                    INV_Item_Account_Category_Detail oINV_Item_Account_Category_Detail = new INV_Item_Account_Category_Detail();
                    oINV_Item_Account_Category_Detail.Department = item.Dept;
                    oINV_Item_Account_Category_Detail.Type = item.Type;
                    oINV_Item_Account_Category_Detail.Account_Code = item.Code;
                    db.INV_Item_Account_Category_Details.InsertOnSubmit(oINV_Item_Account_Category_Detail);
                }
                db.SubmitChanges();
            }
            
        }

        public class AccountsList
        {
            public string Dept { get; set; }
            public string Type { get; set; }
            public string Code { get; set; }
        }
        public class ItemAccountCategoryTemp
        {
            public List<AccountsList> AccountsList {get;set;}
            public int CatID { get; set; }
            public string CatName { get; set; }
        }
    }
}