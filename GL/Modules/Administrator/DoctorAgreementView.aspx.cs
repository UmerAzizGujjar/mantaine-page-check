using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web.Data.Extensions;

namespace PMS.Inventory
{
    public partial class DoctorAgreementView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_agrments = _dbContext.Doctor_Agreements.Count();
                    var agrement = from a in _dbContext.Doctor_Agreements
                              where (
                                    (a.Doc_agreemnt_id.ToString().Contains(searchValue) || a.Doc_account.Contains(searchValue) || (from v in _dbContext.HR_Employees where Convert.ToInt32(a.Doctor) == v.Emp_ID select new { Doc_name = v.Emp_Name }).FirstOrDefault().Doc_name.ToString().Contains(searchValue)))
                              orderby a.Doc_agreemnt_id descending
                              select new
                              {
                                  doc_id = a.Doc_agreemnt_id,
                                  Doc_name = (from v in _dbContext.HR_Employees where Convert.ToInt32(a.Doctor) == v.Emp_ID select new { Doc_name = v.Emp_Name }).FirstOrDefault().Doc_name.ToString(),
                                  Date = a.Created_Time,
                                  Doc_Account = a.Doc_account,
                              };

                    var FilteredCount = agrement.Count();
                    switch (sortColumn)
                    {
                        case "doc_id":
                            agrement = sortColumnDirection == "asc" ? agrement.OrderBy(a => a.doc_id) : agrement.OrderByDescending(a => a.doc_id);
                            break;
                        case "Doc_name":
                            agrement = sortColumnDirection == "asc" ? agrement.OrderBy(a => a.Doc_name) : agrement.OrderByDescending(a => a.Doc_name);
                            break;
                        case "Doc_Account":
                            agrement = sortColumnDirection == "asc" ? agrement.OrderBy(a => a.Doc_Account) : agrement.OrderByDescending(a => a.Doc_Account);
                            break;
                        default:
                            agrement = agrement.OrderByDescending(a => a.doc_id);
                            break;
                    }
                    var agrementList = agrement.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_agrments, data = agrementList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Doctor Agreements list", ex);
            }
        }        
    }
}