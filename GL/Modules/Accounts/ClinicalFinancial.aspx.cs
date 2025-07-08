using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Accounts
{
    public partial class ClinicalFinancial : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string filldropdowns()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from account in db.GL_Accounts
                         where account.Levels == 4
                         select new
                         {
                             account.Account_Code,
                             account.Account_ID,
                             account.Account_Name
                         }).ToList();
            string data = string.Empty;
            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static void InsertData(List<RowData> rows)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            foreach (RowData row in rows)
            {
                string category = row.categoryname;

                int cash = 0, discount = 0, revenue = 0;
                int.TryParse(row.cashinhand, out cash);
                int.TryParse(row.discount, out discount);
                int.TryParse(row.revenue, out revenue);

                ClinicalAccountCategory table = new ClinicalAccountCategory
                {
                    CategoryName = category,
                    CashInHand = cash,
                    Discount = discount,
                    Revenue = revenue,
                    CreatedBy = AppConfig.UserID, 
                    CreatedDate = DateTime.Now,
                    IsCancel = false,
                };

                db.ClinicalAccountCategories.InsertOnSubmit(table);
            }

            db.SubmitChanges();
        }


        // Create a class to receive row data
        public class RowData
        {
            public string categoryname { get; set; }
            public string cashinhand { get; set; }
            public string discount { get; set; }
            public string revenue { get; set; }
        }

    }
}