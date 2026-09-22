using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Administrator
{
    public partial class Department_Assign_View : System.Web.UI.Page
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
                    var policy = db.Policy_Department_Assignments.FirstOrDefault(p => p.Policy_Assign_Dep_id == policyId);
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

                    var Total_Department = _dbContext.Policy_Department_Assignments.Count();
                    var Department_Assign = from a in _dbContext.Policy_Department_Assignments
                                            join p in _dbContext.Policies on a.Policy_ID equals p.Policy_ID
                                            where a.Is_Cancel == false && 
                                            p.Policy_Name.Contains(searchValue) 
                                            select new
                                            {
                                                Dep_ID = a.Policy_Assign_Dep_id,
                                                Department = _dbContext.GetDataValueName("Patient Main Category", a.Department_ID),
                                                Policy_Name = p.Policy_Name,
                                                Fees = a.Fees,
                                                Hospital_Share = a.Hospital_Share,
                                                Doctor_Share = a.Doctor_Share,
                                                a.IsTime,
                                                a.Start_Time,
                                                a.End_Time,
                                                a.Expiry_Date,
                                            };

                    var FilteredCount = Department_Assign.Count();

                    switch (sortColumn)
                    {
                        case "Dep_ID":
                            Department_Assign = sortColumnDirection == "asc" ? Department_Assign.OrderBy(a => a.Dep_ID) : Department_Assign.OrderByDescending(a => a.Dep_ID);
                            break;
                        default:
                            Department_Assign = Department_Assign.OrderByDescending(a => a.Dep_ID);
                            break;
                    }

                    var rawList = Department_Assign.Skip(start).Take(length).ToList();

                    var PolicyList = rawList.Select(a => new
                    {
                        a.Dep_ID,
                        a.Department,
                        a.Policy_Name,
                        a.Fees,
                        a.Hospital_Share,
                        a.Doctor_Share,
                        Time_In = a.Start_Time.HasValue ? DateTime.Today.Add(a.Start_Time.Value).ToString("hh:mm tt") : "",
                        Time_Out = a.End_Time.HasValue ? DateTime.Today.Add(a.End_Time.Value).ToString("hh:mm tt") : "",
                        Expiry_Date = a.Expiry_Date.HasValue ? a.Expiry_Date.Value.ToString("dd-MM-yyyy") : ""
                    }).ToList();

                    var jsonData = new
                    {
                        draw = draw,
                        recordsFiltered = FilteredCount,
                        recordsTotal = Total_Department,
                        data = PolicyList
                    };

                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Department Assign list", ex);
            }
        }
    }
}