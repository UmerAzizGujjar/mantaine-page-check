using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Inventory
{
    public partial class AdvanceTaxDefinition : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string loadpayablegl(string ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var decription = (from i in db.GL_Accounts
                              where i.Account_ID == Convert.ToInt32(ID)
                              select new { name = i.Account_Name }).ToList();
            return (new JavaScriptSerializer()).Serialize(decription);
        }

        [WebMethod]
        public static string loadrecvablegl(string ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var decription = (from i in db.GL_Accounts
                              where i.Account_ID == Convert.ToInt32(ID)
                              select new { name = i.Account_Name }).ToList();
            return (new JavaScriptSerializer()).Serialize(decription);
        }

        [WebMethod]
        public static string loadAccountList()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var itemsList = (from i in db.GL_Accounts
                             where i.Levels == 4
                             select new
                             {
                                 i.Account_ID,
                                 name = i.Account_Code.ToString() + "-" + i.Account_Name
                             }).ToList();
            return (new JavaScriptSerializer()).Serialize(itemsList);
        }

        [WebMethod]
        public static string savewithholdAdvancetax(string btnSave, string AllItemDetail)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<Advance>(AllItemDetail);

            foreach (var acc in record.Advancelist)
            {
                if (acc.Advance_Tax_ID == null)
                {
                    // Insert
                    Advance_Tax ltd = new Advance_Tax();
                    ltd.Tax_Type = acc.Tax_Type;
                    ltd.Advance_Tax_Perc = acc.Advance_Tax_Perc;
                    ltd.Account_ID_Payable = acc.Account_ID_Payable;
                    ltd.Description_Payable = acc.Description_Payable;
                    ltd.Account_Code_Recvable = acc.Account_Code_Recvable;
                    ltd.Description_Recvable = acc.Description_Recvable;
                    ltd.Active = acc.Activechk;
                    ltd.S_W_H_Tax = acc.STWH;

                    db.Advance_Taxes.InsertOnSubmit(ltd);
                    db.SubmitChanges();
                }
                else
                {
                    // Update
                    string sql = "UPDATE Advance_Tax SET " +
                                 "Tax_Type = '" + acc.Tax_Type + "', " +
                                 "Advance_Tax_Perc = '" + acc.Advance_Tax_Perc + "', " +
                                 "Account_ID_Payable = " + acc.Account_ID_Payable + ", " +
                                 "Description_Payable = '" + acc.Description_Payable + "', " +
                                 "Account_Code_Recvable = " + acc.Account_Code_Recvable + ", " +
                                 "Description_Recvable = '" + acc.Description_Recvable + "', " +
                                 "Active = '" + acc.Activechk + "', " +
                                 "S_W_H_Tax = '" + acc.STWH + "' " +
                                 "WHERE Advance_Tax_ID = " + acc.Advance_Tax_ID;
                    DBClass.executeNonQueryWithoutBegin(sql);
                }
            }
            return "Success";
        }

        [WebMethod]
        public static string LoadAccount()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Header = (from a in db.Advance_Taxes
                          select new
                          {
                              a.Advance_Tax_ID,
                              a.Tax_Type,
                              a.Advance_Tax_Perc,
                              a.Account_Code_Recvable,
                              a.Account_ID_Payable,
                              a.Description_Payable,
                              a.Description_Recvable,
                              a.S_W_H_Tax,
                              a.Active
                          }).ToList();

            return (new JavaScriptSerializer()).Serialize(Header);
        }
        public class Advance
        {
            public List<Advancelist> Advancelist { get; set; }
        }
        public class Advancelist
        {
            public int? Advance_Tax_ID { get; set; }
            public string Tax_Type { get; set; }
            public string Advance_Tax_Perc { get; set; }
            public int Account_ID_Payable { get; set; }
            public string Description_Payable { get; set; }
            public int Account_Code_Recvable { get; set; }
            public string Description_Recvable { get; set; }
            public bool Activechk { get; set; }
            public bool STWH { get; set; }
        }
    }
}