using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Administrator
{
    public partial class AssetSubsequentExpense : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        public class Exp_Fill
        {
            public string ExpenseDate { get; set; }
            public string ExpenseRefrence { get; set; }
            public string ExpenseDetail { get; set; }
            public decimal ExpenseAmount { get; set; }
            public int IncreaseinLife { get; set; }
            public int Asset_id { get; set; }
        }
        [WebMethod]
        public static string GetAssetValues(int AssetId)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var query = (from ass in db.Asset_Definitions
                         where ass.Asset_Definition_Id == AssetId
                         select new
                         {
                             Capitilization_Cost = ass.Capitilization_Cost,
                         }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static string SaveRecord(string Trans, int Asset_id,  DateTime Date, string Asset_val,  int Cr_Account,int Dr_Account,string btnSave, string Remarks,decimal TotalExpense, string asset_name, string id,List<Exp_Fill> list) // this maps to your table data
        {
            DataBaseDataContext db = new DataBaseDataContext();
            try
            {
                Asset_Expense master;

                if (btnSave == "Save")
                {
                    master = new Asset_Expense
                    {
                        created_by = AppConfig.UserID,
                        created_time = DateTime.Now
                    };
                    db.Asset_Expenses.InsertOnSubmit(master);
                }
                else
                {
                    master = db.Asset_Expenses.FirstOrDefault(x => x.Asset_Expense_ID == Convert.ToInt32(id));
                    if (master == null)
                        return "-1";

                    master.Updated_By = AppConfig.UserID;
                    master.Updated_Time = DateTime.Now;

                    var existingDetails = db.Asset_Expense_details
                        .Where(x => x.Asset_Expense_ID == master.Asset_Expense_ID)
                        .ToList();
                    db.Asset_Expense_details.DeleteAllOnSubmit(existingDetails);
                }

               
                master.Trans_no = Trans;
                master.Asset_ID = Asset_id;
                master.Date = Date;
                master.Asset_Value = Asset_val;
                master.Cr_Account = Cr_Account; 
                master.Dr_Account = Dr_Account; 
                master.Remarks = Remarks;
                master.TotalExpenseAmount = TotalExpense;
                master.asset_name = asset_name;
          

                db.SubmitChanges(); 

                foreach (var item in list)
                {
                    Asset_Expense_detail detail = new Asset_Expense_detail
                    {
                        Asset_Expense_ID = master.Asset_Expense_ID,
                        Expense_Date = string.IsNullOrEmpty(item.ExpenseDate) ? (DateTime?)null : Convert.ToDateTime(item.ExpenseDate),
                        Expense_Reference = item.ExpenseRefrence,
                        Expense_Details = item.ExpenseDetail,
                        Expense_Amount = Convert.ToDecimal(item.ExpenseAmount),
                        IncreaseInLife = item.IncreaseinLife,
                        Asset_ID = item.Asset_id,
                    };

                    db.Asset_Expense_details.InsertOnSubmit(detail);
                }

                db.SubmitChanges();
                return master.Asset_Expense_ID.ToString();
            }
            catch (Exception ex)
            {
                return ex.InnerException != null ? ex.InnerException.Message : ex.Message;
            }
        }

        [WebMethod]
        public static string approveExpense(int expense_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var userid = AppConfig.UserID;
            var Details = db.SpApproveExpense(Convert.ToInt32(expense_ID), userid);
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string UnapproveExpense(int expense_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var userid = AppConfig.UserID;
            var Details = db.SpUnApproveExpense(Convert.ToInt32(expense_ID));
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string Load_Debit()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var dpt = (from d in db.GL_Accounts
                       where d.Active == true && d.Levels == 4
                       select new
                       {
                           d.Account_ID,
                           d.Account_Name
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
        } 
        [WebMethod]
        public static string Load_Credit()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var dpt = (from d in db.GL_Accounts
                       where d.Active == true && d.Levels == 4
                       select new
                       {
                           d.Account_ID,
                           d.Account_Name
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
        }
        [WebMethod]
        public static string Load_Asset()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var dpt = (from d in db.Asset_Definitions
                       select new
                       {
                           d.Asset_Definition_Id,
                           d.Item_Description
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
        }

        [WebMethod]
        public static string getRecords(string id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            int ExpenseID = Convert.ToInt32(id);

            var master = (from m in db.Asset_Expenses
                          where m.Asset_Expense_ID == ExpenseID
                          select new
                          {
                              m.Asset_Expense_ID,
                              m.is_approved,
                              m.Trans_no,
                              m.Asset_ID,
                              m.Asset_Value,
                              m.Dr_Account,
                              m.Cr_Account,
                              m.Remarks,
                              m.Date,
                              m.TotalExpenseAmount
                          }).FirstOrDefault();

            var details = (from d in db.Asset_Expense_details
                           where d.Asset_Expense_ID == ExpenseID
                           select new
                           {
                               d.Expense_Date,
                               d.Expense_Reference,
                               d.Expense_Details,
                               d.Expense_Amount,
                               d.IncreaseInLife,
                               d.Asset_ID
                           }).ToList();

            var response = new
            {
                Master = master,
                Detail = details
            };

            return new JavaScriptSerializer().Serialize(response);
        }

    }
}