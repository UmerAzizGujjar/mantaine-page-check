using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Inventory
{
    public partial class AccountCategory : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string loadAccountList()
        {
            string result = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            db.ObjectTrackingEnabled = false;      // read-only query: no change tracking needed
            var itemsList = (from i in db.GL_Accounts where i.Levels == 4 select new { i.Account_ID, name = i.Account_Code.ToString() + '-' + i.Account_Name }).ToList();
            if (itemsList != null)
            {
                result = (new JavaScriptSerializer()).Serialize(itemsList);
            }
            return result;
        }


        [WebMethod]
        public static string SaveAccount(string btnSave, string AllItemDetail)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<Account>(AllItemDetail);    
           
            foreach (var acc in record.AccountList)
            {
                if (acc.Account_Category_Id == null)
                {
                    Account_Category ltd = new Account_Category();
                    ltd.CategoryName = acc.CategoryName;
                    ltd.Asset_Account = acc.AssetAccount;
                    ltd.Consumption_Account = acc.ConsumptionAccount;
                    ltd.Sal_Account = acc.SalAccount;
                    ltd.CgsAccount = acc.CgsAccount;
                    ltd.Work_Progress_Account = acc.WorkProgressAccount;
                    ltd.Capital_Consumption_Account = acc.CapitalConsumptionAccount;
                    db.Account_Categories.InsertOnSubmit(ltd);
                    db.SubmitChanges();
                }
                else
                {
                    string sql = "Update Account_Category set" +
                                 " CategoryName = '" + acc.CategoryName + "'" +
                                 " ,Asset_Account = " + acc.AssetAccount +
                                 " ,Consumption_Account = " + acc.ConsumptionAccount +
                                 " ,Sal_Account = " + acc.SalAccount +
                                 " ,CgsAccount = " + acc.CgsAccount +
                                 " ,Work_Progress_Account = " + acc.WorkProgressAccount +
                                 " ,Capital_Consumption_Account = " + acc.CapitalConsumptionAccount +
                                 " where Account_Category_Id = " + acc.Account_Category_Id + "";
                   DBClass.executeNonQueryWithoutBegin(sql);
                }
            }

            return "Success";
        }


        [WebMethod]
        public static string LoadAccount()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            db.ObjectTrackingEnabled = false;      // read-only query: no change tracking needed
            var Header = (from m in db.Account_Categories                      
                        
                          select new
                          {
                            m.Account_Category_Id,
                            m.CategoryName,
                            m.Asset_Account,
                            m.Capital_Consumption_Account,
                            m.Consumption_Account,
                            m.Sal_Account,
                            m.CgsAccount,
                            m.Work_Progress_Account       
                          }).ToList();
            return (new JavaScriptSerializer()).Serialize(Header);
        }


        public class Account
        {      
            public List<AccountList> AccountList { get; set; }
        }


       public class AccountList
        {
            public string Account_Category_Id { get; set; }
            public string  CategoryName { get; set; }
            public string AssetAccount { get; set; }

            public string ConsumptionAccount { get; set; }

            public string SalAccount { get; set; }
            public string CgsAccount { get; set; }

            public string WorkProgressAccount { get; set; }

            public string CapitalConsumptionAccount { get; set; }

        }
    }
}