using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Administrator
{
    public partial class AssetDepreciationView : System.Web.UI.Page
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

                    var Total_Depereciation = _dbContext.Asset_Depereciations.Count();
                    var dep = from a in _dbContext.Asset_Depereciations  join  b in _dbContext.Asset_Depereciation_Details on a.Asset_Dep_ID equals b.Asset_Dep_ID
                              where (
                                    (b.Asset_description.ToString().Contains(searchValue)))
                              select new
                              {
                                  Asset_Dep_ID = a.Asset_Dep_ID,
                                  Asset_description = b.Asset_description,
                                  Trans_type = a.Trans_type,
                                  Dep_Cost = b.Dep_Cost,
                                  Depereciation_Amount_charge = b.Depereciation_Amount_charge,
                                  created_time = a.created_time,
                              };

                    var FilteredCount = dep.Count();
                    switch (sortColumn)
                    {
                        case "created_time":
                            dep = sortColumnDirection == "asc" ? dep.OrderBy(a => a.created_time) : dep.OrderByDescending(a => a.created_time);
                            break;
                        default:
                            dep = dep.OrderByDescending(a => a.Asset_Dep_ID);
                            break;
                    }


                    var DepreciationList = dep.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Depereciation, data = DepreciationList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching patient list", ex);
            }
        }
    }
}