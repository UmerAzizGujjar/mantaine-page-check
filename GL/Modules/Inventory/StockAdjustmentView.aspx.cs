using System;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI.WebControls;

namespace PMS.Inventory
{
    public partial class StockAdjustmentView : System.Web.UI.Page
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

                    var Total_Stock_Adjustments = _dbContext.INV_Stock_Adjustments.Count();
                    var StoreAdjustment = from ISA in _dbContext.INV_Stock_Adjustments
                                          join item in _dbContext.INV_Items
                                          on Convert.ToInt32(ISA.Item_Id) equals item.Item_ID
                                          where ISA.Item_Code.ToString().Contains(searchValue) || item.Description.Contains(searchValue) || ISA.Adjustment_No.ToString().Contains(searchValue)
                                          select new
                                          {
                                          Adjustment_Id = ISA.Adjustment_ID,
                                          Adjustment_No = ISA.Adjustment_No,
                                          AdjustmentDates = ISA.Adjustment_Date,
                                          ItemCode = ISA.Item_Code,
                                          ItemDescription = item.Description,
                                          Rate = ISA.Rate,
                                          Qty = ISA.Qty,
                                          //Voucher_No = DBClass.getField("select Voucher_No from GL_Vouchers where Voucher_ID =" + ISA.Voucher_ID),
                                          Status = ISA.Status,
                                      };

                    var FilteredCount = StoreAdjustment.Count();
                    switch (sortColumn)
                    {
                        case "Adjustment_No":
                            StoreAdjustment = sortColumnDirection == "asc" ? StoreAdjustment.OrderBy(a => a.Adjustment_No) : StoreAdjustment.OrderByDescending(a => a.Adjustment_No);
                            break;
                        case "ItemCode":
                            StoreAdjustment = sortColumnDirection == "asc" ? StoreAdjustment.OrderBy(b => b.ItemCode) : StoreAdjustment.OrderByDescending(a => a.ItemCode);
                            break;
                        default:
                            StoreAdjustment = StoreAdjustment.OrderByDescending(a => a.Adjustment_Id);
                            break;
                    }

                    var StoreAdjustmentList = StoreAdjustment.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Stock_Adjustments, data = StoreAdjustmentList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Store Adjustment Issue list", ex);
            }
        }
    }
}