using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Administrator
{
    public partial class Define_Policy_View : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string CancelPolicy(int policyId)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var policy = db.Policies.FirstOrDefault(p => p.Policy_ID == policyId);
                    if (policy != null)
                    {
                        policy.Is_Cancel = true;
                        policy.Cancel_By = AppConfig.UserID;
                        db.SubmitChanges();
                        return "Policy canceled successfully.";
                    }
                    return "Policy not found.";
                }
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }



        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Policy = _dbContext.Policies.Count();
                    var policy = from a in _dbContext.Policies
                              where a.Is_Cancel == false &&
                              ((a.Policy_Name.ToString().Contains(searchValue) || a.Policy_Description.Contains(searchValue)))
                              select new
                              {
                                  Policy_ID = a.Policy_ID,
                                  Policy_Name = a.Policy_Name,
                                  Policy_Description = a.Policy_Description,
                              };

                    var FilteredCount = policy.Count();
                    switch (sortColumn)
                    {
                        case "Policy_ID":
                            policy = sortColumnDirection == "asc" ? policy.OrderBy(a => a.Policy_ID) : policy.OrderByDescending(a => a.Policy_ID);
                            break;
                        default:
                            policy = policy.OrderByDescending(a => a.Policy_ID);
                            break;
                    }


                    var PolicyList = policy.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Policy, data = PolicyList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Policy list", ex);
            }
        }
    }
}