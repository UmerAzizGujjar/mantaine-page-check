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
    public partial class Define_Policy : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string GetPolicyById(string policy_id)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var policy = db.Policies
                                   .Where(p => p.Policy_ID.ToString() == policy_id)
                                   .Select(p => new
                                   {
                                       p.Policy_ID,
                                       p.Policy_Name,
                                       p.Policy_Description,
                                       p.Active
                                   })
                                   .FirstOrDefault();

                    return new JavaScriptSerializer().Serialize(policy);
                }
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }


        [WebMethod]
        public static string SavePolicy(string policy_id, string policyName, string policyDescription, bool active)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext();

                if (!string.IsNullOrEmpty(policy_id))
                {
                    var policy = (from dt in db.Policies
                                  where dt.Policy_ID.ToString() == policy_id
                                  select dt).FirstOrDefault();

                    if (policy != null)
                    {
                        policy.Policy_Name = policyName;
                        policy.Policy_Description = policyDescription;
                        policy.Active = active;
                        policy.Updated_By = AppConfig.UserID;
                        policy.Updated_At = DateTime.Now;
                        db.SubmitChanges();
                    }
                }
                else
                {
                    Policy newPolicy = new Policy
                    {
                        Policy_Name = policyName,
                        Policy_Description = policyDescription,
                        Active = active,
                        Created_By = AppConfig.UserID,
                        Is_Cancel = false,
                        Created_At = DateTime.Now
                    };

                    db.Policies.InsertOnSubmit(newPolicy);
                    db.SubmitChanges();
                }

                return "Policy saved successfully!";
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }

        }
    }
}
