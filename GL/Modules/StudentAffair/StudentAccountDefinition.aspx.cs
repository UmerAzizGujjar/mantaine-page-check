using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.StudentAffair
{
    public partial class StudentAccountDefinition : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

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
        public static string SaveAccount(string btnSave, string AllItemDetail)
        {

#pragma warning disable CS0219 // The variable 'AccountId' is assigned but its value is never used
            string AccountId = "";
#pragma warning restore CS0219 // The variable 'AccountId' is assigned but its value is never used

            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<Account>(AllItemDetail);



            foreach (var acc in record.AccountList)
            {
                if (acc.Account_Category_Id == null)
                {
                    Student_Account_Category ltd = new Student_Account_Category();
                    ltd.Accrued_Income = acc.AccruedIcnome;
                    ltd.Net_Income = acc.NetIncome;
                    ltd.Receivable_Fee = acc.ReceivableFee;
                    ltd.Category_Name = acc.txtCategory;
                    db.Student_Account_Categories.InsertOnSubmit(ltd);
                    db.SubmitChanges();
                }
                else
                {
                    string sql = "Update Student_Account_Category set" +
    " Accrued_Income = '" + acc.AccruedIcnome + "'" +
    " ,Net_Income = " + acc.NetIncome +
    " ,Receivable_Fee = " + acc.ReceivableFee +
    " ,Category_Name = '" + acc.txtCategory + "'" +
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
            var Header = (from m in db.Student_Account_Categories

                          select new
                          {
                              m.Account_Category_Id,
                              m.Accrued_Income,
                              m.Net_Income,
                              m.Receivable_Fee,
                              m.Category_Name,

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
            public string AccruedIcnome { get; set; }
            public string NetIncome { get; set; }
            public string ReceivableFee { get; set; }
            public string txtCategory { get; set; }


        }
    }
}