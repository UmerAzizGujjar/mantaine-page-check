using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static Telerik.Web.UI.ComboBox.ComboBoxStyles;


namespace PMS.Inventory
{
    public partial class ProductsView : System.Web.UI.Page
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

                    var Total_Items = _dbContext.INV_Items.Count();
                    var inv_Items = from I in _dbContext.INV_Items
                                    where I.Item_Type != null
                                    &&
                                       ((I.Item_Code.ToString().Contains(searchValue) || I.Description.ToString().Contains(searchValue)))
                                           select new
                                           {
                                               Item_ID =    I.Item_ID,
                                               ItemCode = I.Item_Code,
                                               ItemName = I.Description,
                                               UOM = _dbContext.GetDataValueName("UOM", I.Unit) ?? "",
                                               ItemCategory = I.Pharmacy_Item == true ? "Pharmacy Item" : I.Services == true ? "Service" : "Item",
                                               ItemType = _dbContext.GetDataValueName("Item Type", I.Item_Type) ?? "",
                                               AccountCategory = (from a in _dbContext.Account_Categories
                                                                  where a.Account_Category_Id == I.Item_Account_category
                                                                  select new { category = a.CategoryName }).FirstOrDefault().category.ToString(),
                                               PurchaseRate = I.Purchase_Rate ?? 0,
                                               SaleRate = I.Sale_Rate ?? 0,
                                               Active = I.Active ?? false,
                                               WareHouse = _dbContext.GetDataValueName("Ware House", I.InventoryOrg) ?? "",
                                              StockTotal = (_dbContext.GetInvenrtoryItemUomTotalStock(I.Item_ID, I.InventoryOrg))
                                           };

                    var FilteredCount = inv_Items.Count();
                    switch (sortColumn)
                    {
                        case "ItemCode":
                            inv_Items = sortColumnDirection == "asc" ? inv_Items.OrderBy(a => a.ItemCode) : inv_Items.OrderByDescending(a => a.ItemCode);
                            break;
                        case "ItemName":
                            inv_Items = sortColumnDirection == "asc" ? inv_Items.OrderBy(a => a.ItemName) : inv_Items.OrderByDescending(a => a.ItemName);
                            break;
                        default:
                            inv_Items = inv_Items.OrderBy(a => a.ItemCode);
                            break;
                    }

                    var AdvancePaymentList = inv_Items.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Items, data = AdvancePaymentList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching inv Items  list", ex);
            }
        }

    }
}

