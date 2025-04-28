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
    public partial class AssetDepereciationPolicy : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string SavePolicy(bool isMonthly, bool isYearly, string fiscalStart, string fiscalEnd, string btnsave)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                if (btnsave == "Save")
                {
                    Depereciation_Policy policy = new Depereciation_Policy
                    {
                        Monthly = isMonthly,
                        Yearly = isYearly,
                        Fiscal_Year_Start = string.IsNullOrWhiteSpace(fiscalStart) ? (DateTime?)null : DateTime.Parse(fiscalStart),
                        Fiscal_Year_End = string.IsNullOrWhiteSpace(fiscalEnd) ? (DateTime?)null : DateTime.Parse(fiscalEnd),
                        Created_By = AppConfig.UserID,
                        Created_Time = DateTime.Now
                    };
                    db.Depereciation_Policies.InsertOnSubmit(policy);
                    db.SubmitChanges();
                }
                else
                {
                    // Delete all existing records
                    var existingPolicies = db.Depereciation_Policies.ToList();
                    db.Depereciation_Policies.DeleteAllOnSubmit(existingPolicies);

                    // Insert new policy
                    Depereciation_Policy newPolicy = new Depereciation_Policy
                    {
                        Monthly = isMonthly,
                        Yearly = isYearly,
                        Fiscal_Year_Start = string.IsNullOrWhiteSpace(fiscalStart) ? (DateTime?)null : DateTime.Parse(fiscalStart),
                        Fiscal_Year_End = string.IsNullOrWhiteSpace(fiscalEnd) ? (DateTime?)null : DateTime.Parse(fiscalEnd),
                        Created_By = AppConfig.UserID,
                        Created_Time = DateTime.Now
                    };
                    db.Depereciation_Policies.InsertOnSubmit(newPolicy);
                    db.SubmitChanges();
                }
            }

            return "Policy saved successfully!";
        }
        [WebMethod]
        public static string getRecords()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Result = (from records in db.Depereciation_Policies
                          select records).ToList();

            return (new JavaScriptSerializer()).Serialize(Result);
        }
    }
}