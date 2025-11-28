using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Inventory
{
    public partial class BOM_View : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string CancelBOM(int bomId)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var bom = db.inv_boms.FirstOrDefault(b => b.BOMID == bomId);
                    if (bom == null)
                        return "Error: BOM not found.";

                    bom.isCancel = true;
                    bom.Cancel_By = AppConfig.UserID;
                    bom.CancelDate = DateTime.Now;
                    db.SubmitChanges();

                    return "BOM canceled successfully.";
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

                    var Total_Items = _dbContext.inv_boms.Count();
                    var inv_Items = from I in _dbContext.inv_boms
                                    where (I.isCancel == false || I.isCancel == null) &&
                                       ((I.Category.ToString().Contains(searchValue))) 
                                    select new
                                    {
                                        BOMID = I.BOMID,
                                        ProcedureName = (from p in _dbContext.INV_Items  where p.Item_ID == I.ProcedureID
                                                         select p.Description).FirstOrDefault() ?? "(No Procedure)",
                                        Category = I.Category,
                                        TotalCost = I.TotalCost,

                                    };

                    var FilteredCount = inv_Items.Count();
                    switch (sortColumn)
                    {
                        case "BOMID":
                            inv_Items = sortColumnDirection == "asc" ? inv_Items.OrderBy(a => a.BOMID) : inv_Items.OrderByDescending(a => a.BOMID);
                            break;
                        case "Category":
                            inv_Items = sortColumnDirection == "asc" ? inv_Items.OrderBy(a => a.Category) : inv_Items.OrderByDescending(a => a.Category);
                            break;
                        default:
                            inv_Items = inv_Items.OrderByDescending(a => a.BOMID);
                            break;
                    }

                    var BOMList = inv_Items.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Items, data = BOMList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching BOM list", ex);
            }
        }
    }
}