using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Administrator
{
    public partial class Shift__Policy_View : System.Web.UI.Page
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
                    var policy = db.Policy_Details.FirstOrDefault(p => p.Policy_Detail_ID == policyId);
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

                    var Total_Policy = _dbContext.Policy_Details.Count();
                    var Shift_policy = from a in _dbContext.Policy_Details
                                       where a.Is_Cancel == false &&
                                      a.Policy_Name.Contains(searchValue)
                                       select new
                                       {
                                           Policy_Detail_ID = a.Policy_Detail_ID,
                                           Policy_ID = a.Policy_ID,
                                           Policy_Name = a.Policy_Name,
                                           Fees = a.Fees,
                                           Hospital_Share = a.Hospital_Share,
                                           Doctor_Share = a.Doctor_Share,
                                           Start_Time = a.Start_Time,
                                           End_Time = a.End_Time,
                                       };

                    var FilteredCount = Shift_policy.Count();
                    switch (sortColumn)
                    {
                        case "Policy_Detail_ID":
                            Shift_policy = sortColumnDirection == "asc" ? Shift_policy.OrderBy(a => a.Policy_Detail_ID) : Shift_policy.OrderByDescending(a => a.Policy_Detail_ID);
                            break;
                        default:
                            Shift_policy = Shift_policy.OrderByDescending(a => a.Policy_Detail_ID);
                            break;
                    }


                    var PolicyList = Shift_policy.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Policy, data = PolicyList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Shift Policy list", ex);
            }
        }
    }
}