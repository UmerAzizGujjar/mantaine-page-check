using System;
using System.Collections.Generic;
using System.Data.Linq.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Administrator
{
    public partial class AssetRetirement : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string LoadTransType()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var dpt = (from d in db.DataValues
                       join v in db.ValueSets
                       on d.ValueSet_ID equals v.ValueSet_ID
                       where v.ValueSet_Name == "Transaction Type"
                       select new
                       {
                           d.DataValue_Name,
                           d.DataValue_Description
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
        }
        [WebMethod]
        public static string LoadAssets()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            DateTime today = DateTime.Today;

            var result = (from def in db.Asset_Definitions
                          where def.isactive == true
                               && def.Capitilization_Date != null
                               && def.Asset_lifeDays != null
                               && SqlMethods.DateDiffDay(def.Capitilization_Date, today) > Convert.ToInt32(def.Asset_lifeDays)
                          select new
                          {
                              def.Asset_Definition_Id,
                              def.Item_Description,
                              CapitalizationDate = def.Capitilization_Date,
                              DaysDifference = SqlMethods.DateDiffDay(def.Capitilization_Date, today),
                              def.Asset_lifeDays
                          }).ToList();

            return (new JavaScriptSerializer().Serialize(result));
        }


        [WebMethod]
        public static string LoadCreditAccounts()
        {
            string result = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            var Load_Asset = (from i in db.GL_Accounts
                              where i.Levels == 4
                              select new
                              {

                                  i.Account_ID,
                                  i.Account_Name

                              }).ToList();


            return (new JavaScriptSerializer()).Serialize(Load_Asset);
        }
        [System.Web.Services.WebMethod]
        public static string getRecords(string id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Result = (from records in db.Asset_Retirements
                          where records.Asset_Ret_ID == Convert.ToInt32(id)
                          select records).ToList();

            return (new JavaScriptSerializer()).Serialize(Result);
        }
        [WebMethod]
        public static string GetRetirement_Result(string id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var LoadDepereciation = (from p in db.Asset_Retirement_details.Where(x => x.asset_ret_id.Equals(id))
                                     select new
                                     {
                                         p.asset_ret_id,
                                         p.Asset_Ret_Detail_ID,
                                         p.Asset_id,
                                         p.AssetValue,
                                         p.Depreciation_Amount,
                                         p.Remaing_Amount,
                                         p.Retirement_Value,
                                         p.Cr_Account,
                                         p.Dr_Account

                                     }).ToList();
            return (new JavaScriptSerializer()).Serialize(LoadDepereciation);
        }
        [WebMethod]
        public static string GetAssetValues(int AssetId)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var query = (from ass in db.Asset_Definitions
                         where ass.Asset_Definition_Id == AssetId
                         select new
                         {
                             // Base Capitalization Cost
                             Capitilization_Cost = ass.Capitilization_Cost +

                                                 // Sum of all Expense Amounts from Asset_Expense_details table
                                                 (db.Asset_Expense_details
                                                  .Where(e => e.Asset_ID == ass.Asset_Definition_Id)
                                                  .Sum(e => (decimal?)e.Expense_Amount) ?? 0),

                             Item_Description = ass.Item_Description,

                             // Depreciation calculation
                             Depereciation_Amount_charge = (from ass_Dep in db.Asset_Depereciation_Details
                                                            where ass_Dep.Asset_Def_ID == AssetId
                                                            select ass_Dep.Depereciation_Amount_charge).Sum(),
                         }).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(query);
        }

        [WebMethod]
        public static string LoadDebitAccounts()
        {
            string result = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            var Load_Asset = (from i in db.GL_Accounts
                              where i.Levels == 4
                              select new
                              {

                                  i.Account_ID,
                                  i.Account_Name

                              }).ToList();


            return (new JavaScriptSerializer()).Serialize(Load_Asset);
        }
        public class Retirement_Fill
        {
            public int assetId { get; set; }
            public string assetText { get; set; }
            public decimal Asset_Value { get; set; }
            public decimal Asset_Depreciation { get; set; }
            public decimal Remaining_value { get; set; }
            public decimal Retirement_Value { get; set; }
            public int Cr_Account { get; set; }
            public int Dr_account { get; set; }
        }
        [WebMethod]
        public static string approveAssetRetirement(int assetRetId)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var userid = AppConfig.UserID;
            var Details = db.SpApprove_Retirement(assetRetId, userid);
            return (new JavaScriptSerializer()).Serialize(Details);
        }   
        [WebMethod]
        public static string UnapproveAssetRetirement(int assetRetId)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.SpUnApprove_Retirement(assetRetId);
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string SaveRetirementRecord(string Trans_Type, string Trans_no, string Remarks, string Date, string btnSave, string id, List<Retirement_Fill> list)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            try
            {
                Asset_Retirement master;

                if (btnSave == "Save")
                {
                    master = new Asset_Retirement
                    {
                        created_by = AppConfig.UserID,
                        created_time = DateTime.Now
                    };
                    db.Asset_Retirements.InsertOnSubmit(master);
                }
                else
                {
                    master = db.Asset_Retirements.FirstOrDefault(x => x.Asset_Ret_ID == Convert.ToInt32(id));
                    if (master == null)
                        return "-1";

                    master.Updated_By = AppConfig.UserID;
                    master.Updated_Time = DateTime.Now;

                    var existingDetails = db.Asset_Retirement_details.Where(x => x.asset_ret_id == master.Asset_Ret_ID).ToList();
                    db.Asset_Retirement_details.DeleteAllOnSubmit(existingDetails);
                }

                master.TransType = Trans_Type;
                master.TransNo = Trans_no;
                master.Remarks = Remarks;
                master.Date = Convert.ToDateTime(Date);

                db.SubmitChanges(); // Save master to get ID (if inserted)

                foreach (var item in list)
                {
                    Asset_Retirement_detail detail = new Asset_Retirement_detail
                    {
                        asset_ret_id = master.Asset_Ret_ID,
                        Asset_id = item.assetId,
                        Asset_Name = item.assetText,
                        AssetValue = item.Asset_Value,
                        Depreciation_Amount = item.Asset_Depreciation,
                        Remaing_Amount = item.Remaining_value,
                        Retirement_Value = item.Retirement_Value,
                        Cr_Account = item.Cr_Account,
                        Dr_Account = item.Dr_account,
                        created_date = DateTime.Now
                    };

                    db.Asset_Retirement_details.InsertOnSubmit(detail);
                }

                db.SubmitChanges();
                return master.Asset_Ret_ID.ToString();
            }
            catch (Exception ex)
            {
                // Log the error
                return "-1";
            }
        }

    }
}