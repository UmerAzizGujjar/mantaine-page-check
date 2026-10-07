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
    public partial class FurtherTaxDefinition : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string loadpayablegl(string ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var desc = (from i in db.GL_Accounts
                        where i.Account_ID == Convert.ToInt32(ID)
                        select new { name = i.Account_Name }).ToList();
            return new JavaScriptSerializer().Serialize(desc);
        }

        [WebMethod]
        public static string loadrecvablegl(string ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var desc = (from i in db.GL_Accounts
                        where i.Account_ID == Convert.ToInt32(ID)
                        select new { name = i.Account_Name }).ToList();
            return new JavaScriptSerializer().Serialize(desc);
        }

        [WebMethod]
        public static string loadAccountList()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            db.ObjectTrackingEnabled = false;      // read-only query: no change tracking needed
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
        public static string LoadAccount()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            db.ObjectTrackingEnabled = false;      // read-only query: no change tracking needed
            var list = (from a in db.Further_Taxes
                        select new
                        {
                            a.Further_Tax_ID,
                            a.Tax_Type,
                            a.Further_Tax_Perc,
                            a.Account_ID_Payable,
                            a.Description_Payable,
                            a.Account_Code_Recvable,
                            a.Description_Recvable,
                            a.S_W_H_Tax,
                            a.Active
                        }).ToList();
            return new JavaScriptSerializer().Serialize(list);
        }

        [WebMethod]
        public static string saveFurtherTax(string btnSave, string AllItemDetail)
        {
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<FurtherTaxModel>(AllItemDetail);

            using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                foreach (var item in record.Furtherlist)
                {
                    if (!item.Further_Tax_ID.HasValue)
                    {
                        var ft = new Further_Tax
                        {
                            Tax_Type = item.Tax_Type,
                            Further_Tax_Perc = item.Further_Tax_Perc,
                            Account_ID_Payable = item.Account_ID_Payable,
                            Description_Payable = item.Description_Payable,
                            Account_Code_Recvable = item.Account_Code_Recvable,
                            Description_Recvable = item.Description_Recvable,
                            Active = item.Activechk,
                            S_W_H_Tax = item.STWH
                        };
                        db.Further_Taxes.InsertOnSubmit(ft);
                    }
                    else
                    {
                        var existing = db.Further_Taxes.FirstOrDefault(x => x.Further_Tax_ID == item.Further_Tax_ID.Value);
                        if (existing != null)
                        {
                            existing.Tax_Type = item.Tax_Type;
                            existing.Further_Tax_Perc = item.Further_Tax_Perc;
                            existing.Account_ID_Payable = item.Account_ID_Payable;
                            existing.Description_Payable = item.Description_Payable;
                            existing.Account_Code_Recvable = item.Account_Code_Recvable;
                            existing.Description_Recvable = item.Description_Recvable;
                            existing.Active = item.Activechk;
                            existing.S_W_H_Tax = item.STWH;
                        }
                    }
                }
                db.SubmitChanges();
            }
            return "Success";
        }

        public class FurtherTaxModel
        {
            public List<FurtherTaxItem> Furtherlist { get; set; }
        }

        public class FurtherTaxItem
        {
            public int? Further_Tax_ID { get; set; }
            public string Tax_Type { get; set; }
            public string Further_Tax_Perc { get; set; }
            public int Account_ID_Payable { get; set; }
            public string Description_Payable { get; set; }
            public int Account_Code_Recvable { get; set; }
            public string Description_Recvable { get; set; }
            public bool Activechk { get; set; }
            public bool STWH { get; set; }
        }
    }
}