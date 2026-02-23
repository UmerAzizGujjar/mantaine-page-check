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
    public partial class SalesTaxDefinition : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }
        [WebMethod]
        public static string loadpayablegl(string ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var decription = (from i in db.GL_Accounts where i.Account_ID == Convert.ToInt32(ID) select new { name = i.Account_Name }).ToList();
            return (new JavaScriptSerializer()).Serialize(decription);
        }
        [WebMethod]
        public static string loadrecvablegl(string ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var decription = (from i in db.GL_Accounts where i.Account_ID == Convert.ToInt32(ID) select new { name = i.Account_Name }).ToList();
            return (new JavaScriptSerializer()).Serialize(decription);
        }
        [WebMethod]
        public static string loadAccountList()
        {
            string result = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            var itemsList = (from i in db.GL_Accounts where i.Levels == 4 select new { i.Account_ID, name = i.Account_Code.ToString() + '-' + i.Account_Name }).ToList();
            if (itemsList != null)
            {
                result = (new JavaScriptSerializer()).Serialize(itemsList);
            }
            return result;
        }
        [WebMethod]
        public static string savewithholdtaxinfo(string btnSave, string AllItemDetail)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<Account>(AllItemDetail);
            foreach (var acc in record.AccountList)
            {
                if (acc.Sales_Tax_ID == null)
                {
                    Sales_Tax ltd = new Sales_Tax();
                    ltd.Tax_Type = acc.Tax_Type;
                    ltd.Sales_Tax_Perc = acc.Sales_Tax_Perc;
                    ltd.Account_ID_Payable = Convert.ToInt32(acc.Account_ID_Payable);
                    ltd.Description_Payable = acc.Description_Payable;
                    ltd.Account_Code_Recvable = Convert.ToInt32(acc.Account_Code_Recvable);
                    ltd.Description_Recvable = acc.Description_Recvable;
                    ltd.Active = Convert.ToBoolean(acc.Activechk);
                    ltd.S_W_H_Tax = Convert.ToBoolean(acc.STWH);
                    ltd.IsBilling = Convert.ToBoolean(acc.IsBilling);
                    db.Sales_Taxes.InsertOnSubmit(ltd);
                    db.SubmitChanges();
                }
                else
                {
                    string sql = "Update Sales_Tax set " + "Tax_Type = '" + acc.Tax_Type + "'" +
                                 ",Sales_Tax_Perc = " + acc.Sales_Tax_Perc +
                                 ",Account_ID_Payable = " + Convert.ToInt32(acc.Account_ID_Payable) +
                                 ",Description_Payable = '" + acc.Description_Payable + "'" +
                                 ",Account_Code_Recvable = " + Convert.ToInt32(acc.Account_Code_Recvable) +
                                 ",Description_Recvable = '" + acc.Description_Recvable + "'" +
                                 ",Active = '" + Convert.ToBoolean(acc.Activechk) + "'" +
                                 ",S_W_H_Tax = '" + Convert.ToBoolean(acc.STWH) + "'" +
                                  ",IsBilling = '" + Convert.ToBoolean(acc.IsBilling) + "'" +
                                 " where Sales_Tax_ID = " + acc.Sales_Tax_ID + "";
                    DBClass.executeNonQueryWithoutBegin(sql);
                }
            }
            return "Success";
        }
        [WebMethod]
        public static string LoadAccount()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Header = (from a in db.Sales_Taxes
                          select new
                          {
                              a.Sales_Tax_ID,
                              a.Tax_Type,
                              a.Sales_Tax_Perc,
                              a.Account_Code_Recvable,
                              a.Account_ID_Payable,
                              a.Description_Payable,
                              a.Description_Recvable,                              
                              a.S_W_H_Tax,
                              a.IsBilling,
                              a.Active,
                          }).ToList();
            return (new JavaScriptSerializer()).Serialize(Header);
        }
        public class Account
        {
            public List<AccountList> AccountList { get; set; }
        }
        public class AccountList
        {

            public string Sales_Tax_ID { get; set; }
            public string Tax_Type { get; set; }
            public string Sales_Tax_Perc { get; set; }
            public string Account_ID_Payable { get; set; }
            public string Description_Payable { get; set; }
            public string Account_Code_Recvable { get; set; }
            public string Description_Recvable { get; set; }
            public string Activechk { get; set; }
            public string STWH { get; set; }

            public string IsBilling { get; set; }
        }
    }
}