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
        public static bool DeleteRecord(string itemID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                var itmId = (from itm in db.INV_Items
                             where (itm.Item_ID == int.Parse(itemID))
                             select itm.Item_ID).FirstOrDefault();
                if (itmId != 0)
                {
                    DBClass.exectueQuery("delete from INV_Items where Item_ID =" + itmId, tranObj, con);
                    tranObj.Commit();
                }
                else
                {
                    tranObj.Rollback();
                    return false;
                }
            }
            catch (Exception ex)
            {
                if (tranObj != null)
                    tranObj.Rollback();
                return false;
            }
            return true;
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
                                    join BD in _dbContext.inv_bom_details on I.BOMID equals BD.BOMID
                                    where
                                       ((I.Category.ToString().Contains(searchValue)))
                                    select new
                                    {
                                        BOMID = I.BOMID,
                                        Category = I.Category,
                                        TotalCost = I.TotalCost,
                                        itemName = (from item in _dbContext.INV_Items  where item.Item_ID == BD.ItemID select item.Description).FirstOrDefault(),
                                        Qty = BD.Qty,
                                        Unit = BD.Unit,
                                        Total = BD.Total,

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