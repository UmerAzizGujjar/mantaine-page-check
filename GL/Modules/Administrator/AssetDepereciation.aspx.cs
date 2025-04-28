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
    public partial class AssetDepereciation : System.Web.UI.Page
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
        public class Dep_Fill
        {
            public int assetId { get; set; }
            public string desc { get; set; }
            public int nodays { get; set; }
            public decimal Depr_Cost { get; set; }
            public decimal DepAmount { get; set; }
            public int Depreciation { get; set; }
            public int Accumulated_acc { get; set; }
            public int Depreciation_Acc { get; set; }
        }
        [System.Web.Services.WebMethod]
        public static string getRecords(string id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Result = (from records in db.Asset_Depereciations
                          where records.Asset_Dep_ID == Convert.ToInt32(id)
                          select records).ToList();

            return (new JavaScriptSerializer()).Serialize(Result);
        }
        [WebMethod]
        public static string GetDepreciation_Result(string id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var LoadDepereciation = (from p in db.Asset_Depereciation_Details.Where(x => x.Asset_Dep_ID.Equals(id))
                                     select new
                                     {
                                         p.Asset_Def_ID,
                                         p.Asset_Dep_Detai_Id,
                                         p.Asset_description,
                                         p.no_of_days,
                                         p.Depereciation_Amount_charge,
                                         p.Dep_Cost,
                                         p.debit_account_id,
                                         p.Credit_Account_id,
                                         p.Depreciation_perc

                                     }).ToList();
            return (new JavaScriptSerializer()).Serialize(LoadDepereciation);
        }
        [WebMethod]
        public static string SaveRecord(string Trans_Type, int ddlMonth, string ddlMonth_text, string Reg_No, string Date, string btnSave, string ddlYears, string id, List<Dep_Fill> list)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            try
            {
                Asset_Depereciation master;

                if (btnSave == "Save")
                {
                    master = new Asset_Depereciation
                    {
                        created_by = AppConfig.UserID,
                        created_time = DateTime.Now
                    };
                    db.Asset_Depereciations.InsertOnSubmit(master);
                }
                else
                {
                    master = db.Asset_Depereciations.FirstOrDefault(x => x.Asset_Dep_ID == Convert.ToInt32(id));
                    if (master == null)
                        return "-1";

                    master.Updated_By = AppConfig.UserID;
                    master.Updated_Time = DateTime.Now;

                    var existingDetails = db.Asset_Depereciation_Details.Where(x => x.Asset_Dep_ID == master.Asset_Dep_ID).ToList();
                    db.Asset_Depereciation_Details.DeleteAllOnSubmit(existingDetails);
                }

                master.Trans_type = Trans_Type;
                master.Month_period_id = ddlMonth;
                master.Month = ddlMonth_text;
                master.yearly = ddlYears;
                master.Register_No = Reg_No;
                master.Date = Convert.ToDateTime(Date);

                db.SubmitChanges();

                List<string> duplicateAssets = new List<string>();

                if(ddlMonth_text != "Please Select")
                {
                    foreach (var item in list)
                    {
                        bool alreadyExists = db.Asset_Depereciation_Details.Any(x =>
                            x.Asset_Def_ID == item.assetId &&
                            x.created_dep_Date.Value.Month == DateTime.Now.Month &&
                            x.created_dep_Date.Value.Year == DateTime.Now.Year);

                        if (!alreadyExists)
                        {
                            Asset_Depereciation_Detail detail = new Asset_Depereciation_Detail
                            {
                                Asset_Dep_ID = master.Asset_Dep_ID,
                                Asset_Def_ID = item.assetId,
                                Asset_description = item.desc,
                                no_of_days = item.nodays,
                                Dep_Cost = item.Depr_Cost,
                                Depereciation_Amount_charge = item.DepAmount,
                                Depreciation_perc = item.Depreciation,
                                debit_account_id = item.Accumulated_acc,
                                Credit_Account_id = item.Depreciation_Acc,
                                created_dep_Date = DateTime.Now
                            };

                            db.Asset_Depereciation_Details.InsertOnSubmit(detail);
                        }
                        else
                        {
                            duplicateAssets.Add($"Asset ID {item.desc} already exists for this month.");
                        }
                    }

                    db.SubmitChanges();

                    if (duplicateAssets.Count > 0)
                    {
                        return "DUPLICATE:" + string.Join(",", duplicateAssets);
                    }
                }
                if (ddlYears != "Please Select")
                {
                    foreach (var item in list)
                    {
                        bool alreadyExists = db.Asset_Depereciation_Details.Any(x =>
                            x.Asset_Def_ID == item.assetId &&
                            x.created_dep_Date.Value.Year == DateTime.Now.Year);

                        if (!alreadyExists)
                        {
                            Asset_Depereciation_Detail detail = new Asset_Depereciation_Detail
                            {
                                Asset_Dep_ID = master.Asset_Dep_ID,
                                Asset_Def_ID = item.assetId,
                                Asset_description = item.desc,
                                no_of_days = item.nodays,
                                Dep_Cost = item.Depr_Cost,
                                Depereciation_Amount_charge = item.DepAmount,
                                Depreciation_perc = item.Depreciation,
                                debit_account_id = item.Accumulated_acc,
                                Credit_Account_id = item.Depreciation_Acc,
                                created_dep_Date = DateTime.Now
                            };

                            db.Asset_Depereciation_Details.InsertOnSubmit(detail);
                        }
                        else
                        {
                            duplicateAssets.Add($"Asset ID {item.desc} already exists for this year.");
                        }
                    }

                    db.SubmitChanges();

                    if (duplicateAssets.Count > 0)
                    {
                        return "DUPLICATE:" + string.Join(",", duplicateAssets);
                    }
                }
                return master.Asset_Dep_ID.ToString();
            }
            catch (Exception ex)
            {
                return ex.InnerException != null ? ex.InnerException.Message : ex.Message;
            }
        }


        [WebMethod]
        public static Dictionary<string, bool> Check_DepPolicy()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var userPermissions = (from data in db.Depereciation_Policies
                                       select new
                                       {
                                           data.Monthly,
                                           data.Yearly,
                                       }).FirstOrDefault();

                return new Dictionary<string, bool>
        {
            { "Monthly", userPermissions?.Monthly ?? false },
            { "Yearly", userPermissions?.Yearly ?? false }
        };
            }
        }

        [WebMethod]
        public static string getDepereciationDataYearly(string Years)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            int year = int.Parse(Years);

            var policy = db.Depereciation_Policies
                .Where(d => d.Fiscal_Year_Start.HasValue && d.Fiscal_Year_Start.Value.Year == year)
                .Select(d => new
                {
                    StartDate = d.Fiscal_Year_Start,
                    EndDate = d.Fiscal_Year_End
                })
                .FirstOrDefault();

            if (policy == null)
            {
                return new JavaScriptSerializer().Serialize(new { error = "Policy not found for the given year." });
            }

            DateTime sDate = Convert.ToDateTime(policy.StartDate);
            DateTime eDate = Convert.ToDateTime(policy.EndDate);
            var rawDetails = db.Asset_Definitions
                .Where(d => d.Capitilization_Date.HasValue &&
                            d.Capitilization_Date.Value <= eDate)
                .ToList();

            var Details = rawDetails.Select(d =>
            {
                var totalDepreciationCharged = db.Asset_Depereciation_Details
                .Where(dep => dep.Asset_Def_ID == d.Asset_Definition_Id)
                .Sum(dep => (decimal?)dep.Depereciation_Amount_charge) ?? 0;

                var totalCapitilizationCost = d.Capitilization_Cost;

                var totalExpenseAmount = db.Asset_Expense_details
                            .Where(e => e.Asset_ID == d.Asset_Definition_Id)
                            .Sum(e => (decimal?)e.Expense_Amount) ?? 0;
                DateTime capDate = d.Capitilization_Date.Value;
                DateTime start = capDate > sDate ? sDate : capDate;
                //DateTime end = eDate;

                int days = (eDate.Date - d.Capitilization_Date.Value.Date).Days + 1;

                return new
                {
                     d.Asset_Definition_Id,
                        d.Asset_Cat_id,
                        Capitilization_Cost = totalCapitilizationCost,
                        Expense_Amount = totalExpenseAmount,
                        d.Item_Description,
                        d.Depreciation,
                        d.Acc_Depreciation_Acc,
                        d.Depreciation_Acc,
                        d.Asset_lifeDays,
                        Capitilization_Date = capDate.ToString("dd MMM yyyy"),
                        DaysCount = days,
                        TotalDepreciationCharged = totalDepreciationCharged
                };
            }).Where(d => d.TotalDepreciationCharged < d.Capitilization_Cost) // still comparing against only capitalized cost
                .ToList();

            return new JavaScriptSerializer().Serialize(Details);
        }


        //my code before validation
        //[WebMethod]
        //public static string getDepereciationData(string Month)
        //{
        //    DataBaseDataContext db = new DataBaseDataContext();

        //    // Parse the ddlMonth to get the first and last date of the month
        //    DateTime monthDate;
        //    if (!DateTime.TryParseExact(Month, "MMM-yyyy", null, System.Globalization.DateTimeStyles.None, out monthDate))
        //    {
        //        return "Invalid month format";
        //    }

        //    // Get the first day of the given month
        //    DateTime sDate = new DateTime(monthDate.Year, monthDate.Month, 1);

        //    // Get the last day of the given month
        //    DateTime eDate = sDate.AddMonths(1).AddDays(-1);

        //    // Query Asset_Definitions and filter by the month and capitalization date
        //    var rawDetails = db.Asset_Definitions
        //        .Where(d => d.Capitilization_Date.HasValue &&
        //                    d.Capitilization_Date.Value >= sDate &&
        //                    d.Capitilization_Date.Value <= eDate)
        //        .ToList();

        //    // Get details and calculate the days difference from capitalization date to the end of the current month
        //    var Details = rawDetails.Select(d => new
        //    {
        //        d.Asset_Definition_Id,
        //        d.Asset_Cat_id,
        //        Capitilization_Cost = d.Capitilization_Cost +
        //                  (db.Asset_Expense_details
        //                     .Where(e => e.Asset_ID == d.Asset_Definition_Id)
        //                     .Sum(e => (decimal?)e.Expense_Amount) ?? 0),
        //        d.Item_Description,
        //        d.Depreciation,
        //        d.Acc_Depreciation_Acc,
        //        d.Depreciation_Acc,
        //        Capitilization_Date = d.Capitilization_Date.Value.ToString("dd MMM yyyy"),
        //        DaysCount = (eDate.Date - d.Capitilization_Date.Value.Date).Days + 1
        //    }).ToList();

        //    return new JavaScriptSerializer().Serialize(Details);
        //}

        //[WebMethod]
        //public static string getDepereciationData(string startdate, string enddate)
        //{
        //    DataBaseDataContext db = new DataBaseDataContext();

        //    DateTime sDate = DateTime.ParseExact(startdate, "dd MMM yyyy", System.Globalization.CultureInfo.InvariantCulture);
        //    DateTime eDate = DateTime.ParseExact(enddate, "dd MMM yyyy", System.Globalization.CultureInfo.InvariantCulture);

        //    // First fetch raw data
        //    var rawDetails = db.Asset_Definitions
        //    .Where(d => d.Capitilization_Date.HasValue &&
        //          d.Capitilization_Date.Value >= sDate &&
        //          d.Capitilization_Date.Value <= eDate)
        //    .ToList();

        //    // Now calculate the difference in days and shape the final result
        //    var Details = rawDetails.Select(d => new
        //    {
        //        d.Asset_Definition_Id,
        //        d.Asset_Cat_id,
        //        d.Capitilization_Cost,
        //        d.Item_Description,
        //        Capitilization_Date = d.Capitilization_Date.Value.ToString("dd MMM yyyy"),
        //        DaysCount = (eDate.Date - d.Capitilization_Date.Value.Date).Days
        //    }).ToList();

        //    // Return the serialized JSON result
        //    return new JavaScriptSerializer().Serialize(Details);



        //}



        [WebMethod]
        public static string getDepereciationData(string Month)
        {
            DataBaseDataContext db = new DataBaseDataContext();

          
            DateTime monthDate;
            if (!DateTime.TryParseExact(Month, "MMM-yyyy", null, System.Globalization.DateTimeStyles.None, out monthDate))
            {
                return "Invalid month format";
            }

            DateTime sDate = new DateTime(monthDate.Year, monthDate.Month, 1);
            DateTime eDate = sDate.AddMonths(1).AddDays(-1);

            var rawDetails = db.Asset_Definitions
                .Where(d => d.Capitilization_Date.HasValue &&
                            d.Capitilization_Date.Value >= sDate &&
                            d.Capitilization_Date.Value <= eDate)
                .ToList();

            var Details = rawDetails
                .Select(d =>
                {
           
            var totalDepreciationCharged = db.Asset_Depereciation_Details
                        .Where(dep => dep.Asset_Def_ID == d.Asset_Definition_Id)
                        .Sum(dep => (decimal?)dep.Depereciation_Amount_charge) ?? 0;

            var totalCapitilizationCost = d.Capitilization_Cost;

            var totalExpenseAmount = db.Asset_Expense_details
                        .Where(e => e.Asset_ID == d.Asset_Definition_Id)
                        .Sum(e => (decimal?)e.Expense_Amount) ?? 0;

                    return new
                    {
                        d.Asset_Definition_Id,
                        d.Asset_Cat_id,
                        Capitilization_Cost = totalCapitilizationCost + totalExpenseAmount,
                        //Expense_Amount = totalExpenseAmount,
                        d.Item_Description,
                        d.Depreciation,
                        d.Acc_Depreciation_Acc,
                        d.Depreciation_Acc,
                        d.Asset_lifeDays,
                        Capitilization_Date = d.Capitilization_Date.Value.ToString("dd MMM yyyy"),
                        DaysCount = (eDate.Date - d.Capitilization_Date.Value.Date).Days + 1,
                        TotalDepreciationCharged = totalDepreciationCharged
                    };
                })
                .Where(d => d.TotalDepreciationCharged < d.Capitilization_Cost) // still comparing against only capitalized cost
                .ToList();

            return new JavaScriptSerializer().Serialize(Details);
        }

        [WebMethod]
        public static string approveAssetDep(int assetDetailId)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var UserId = AppConfig.UserID;
            var Details = db.SpApprove_Depreciation(assetDetailId, UserId);
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string UnapproveAssetDep(int assetDetailId)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            //var UserId = AppConfig.UserID;
            var Details = db.spUnapproveDepereciation(assetDetailId);
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string getyears()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var Header = (from m in db.GL_Periods
                          where m.Period_Closed == false
                          orderby m.Period_ID
                          select new
                          {
                              m.Period_ID,
                              m.Period_start_date,
                              m.Period_end_date,
                              m.Period_Description
                          }).ToList();

            // Extract the year and get distinct values
            var result = Header.Select(m => new
            {
                m.Period_ID,
                m.Period_start_date,
                m.Period_end_date,
                m.Period_Description,
                Year = m.Period_Description.Split('-').Last()
            })
            .GroupBy(m => m.Year)
            .Select(g => g.First()) 
            .ToList();

            return (new JavaScriptSerializer()).Serialize(result);
        }
        [WebMethod]
        public static string getMonth()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Header = (from m in db.GL_Periods
                          where m.Period_Closed == false
                          orderby m.Period_ID descending
                          select new
                          {
                              m.Period_ID,
                              m.Period_start_date,
                              m.Period_end_date,
                              m.Period_Description
                          }).ToList();
            return (new JavaScriptSerializer()).Serialize(Header);
        }
        [WebMethod]
        public static string getDepereciationResults(int assetId)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Header = (from m in db.Asset_Depereciation_Details
                          where m.Asset_Def_ID == assetId

                          select new
                          {
                              m.Asset_description,
                              m.no_of_days,
                              m.Dep_Cost,
                              m.Depreciation_perc,
                              m.Depereciation_Amount_charge,
                              m.created_dep_Date
                          }).ToList();
            return (new JavaScriptSerializer()).Serialize(Header);
        }

    }
}