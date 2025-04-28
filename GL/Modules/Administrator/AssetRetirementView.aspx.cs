using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Administrator
{
    public partial class AssetRetirementView : System.Web.UI.Page
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

                    var Total_Depereciation = _dbContext.Asset_Retirements.Count();
                    var dep = from a in _dbContext.Asset_Retirements
                              join b in _dbContext.Asset_Retirement_details on a.Asset_Ret_ID equals b.asset_ret_id
                              where (
                                    (a.TransNo.ToString().Contains(searchValue)))
                              select new
                              {
                                  Asset_Ret_ID = a.Asset_Ret_ID,
                                  Asset_id = b.Asset_id,
                                  TransNo = a.TransNo,
                                  AssetValue = b.AssetValue,
                                  created_time = a.created_time,
                              };

                    var FilteredCount = dep.Count();
                    switch (sortColumn)
                    {
                        case "Created_time":
                            dep = sortColumnDirection == "asc" ? dep.OrderBy(a => a.created_time) : dep.OrderByDescending(a => a.created_time);
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