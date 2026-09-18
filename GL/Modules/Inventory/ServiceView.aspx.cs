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
    public partial class ServiceView : System.Web.UI.Page
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
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue, string filterStatus = "all")
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Items = _dbContext.INV_Items.Count();
                    var inv_Items = from I in _dbContext.INV_Items
                                    where I.Item_Type != null
                                    && I.Services == true
                                    select new
                                    {
                                        Item_ID = I.Item_ID,
                                        ItemCode = I.Item_Code,
                                        ItemName = I.Description,
                                        UOM = _dbContext.GetDataValueName("UOM", I.Unit) ?? "",
                                        ItemCategory = I.Services == true ? "Service" : I.Services == true ? "Service" : "Service",
                                        ItemType = _dbContext.GetDataValueName("Item Type", I.Item_Type) ?? "",
                                        AccountCategory = (from a in _dbContext.Account_Categories
                                                           where a.Account_Category_Id == I.Item_Account_category
                                                           select new { category = a.CategoryName }).FirstOrDefault().category.ToString(),
                                        AccountID = (from a in _dbContext.GL_Accounts
                                                     where a.Account_ID == I.Account_ID
                                                     select new { Account = a.Account_Name }).FirstOrDefault().Account.ToString(),
                                        Account_ID = I.Account_ID, 
                                        PurchaseRate = I.Purchase_Rate ?? 0,
                                        SaleRate = I.Sale_Rate ?? 0,
                                        Active = I.Active ?? false,
                                        WareHouse = _dbContext.GetDataValueName("Ware House", I.InventoryOrg) ?? "",
                                        Service_Sub_Category = _dbContext.GetDataValueName("Service Sub Category", I.Service_Sub_Category) ?? "",
                                        StockTotal = (_dbContext.GetInvenrtoryItemUomTotalStock(I.Item_ID, I.InventoryOrg)),
                                        CreatedBy = _dbContext.aspnet_Users.Where(x => x.UserId == I.Created_By).Select(x => x.UserName).FirstOrDefault()
                                    };
                    if (filterStatus == "mapped")
                    {
                        inv_Items = inv_Items.Where(i => i.Account_ID != null && i.Account_ID > 0);
                    }
                    else if (filterStatus == "unmapped")
                    {
                        inv_Items = inv_Items.Where(i => i.Account_ID == null || i.Account_ID == 0);
                    }
                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        inv_Items = inv_Items.Where(i =>
                            i.ItemCode.ToString().Contains(searchValue) ||
                            i.ItemName.ToString().Contains(searchValue) ||
                            i.AccountID.ToString().Contains(searchValue) ||
                            i.ItemType.ToString().Contains(searchValue) ||
                            i.AccountCategory.ToString().Contains(searchValue) ||
                            i.Service_Sub_Category.ToString().Contains(searchValue));
                    }

                    var FilteredCount = inv_Items.Count();
                    if (length == -1 || length > 100000)
                    {
                        start = 0;
                        length = FilteredCount;
                    }

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
                throw new Exception("Error fetching Service list", ex);
            }
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "ServiceView";

                using (var db = new DataBaseDataContext())
                {
                    var pref = db.UserDataTablePreferences
                                  .FirstOrDefault(p => p.UserID == userId && p.PageName == pageName);

                    if (pref != null)
                        return pref.ColumnVisibility;
                    else
                        return "";
                }
            }
            catch (Exception ex)
            {
                return "";
            }
        }

        [WebMethod]
        public static void SaveUserColumnPreferences(string visibilityJson)
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "ServiceView";

                using (var db = new DataBaseDataContext())
                {
                    var existing = db.UserDataTablePreferences
                                     .FirstOrDefault(p => p.UserID == userId && p.PageName == pageName);

                    if (existing != null)
                    {
                        existing.ColumnVisibility = visibilityJson;
                    }
                    else
                    {
                        db.UserDataTablePreferences.InsertOnSubmit(new UserDataTablePreference
                        {
                            UserID = userId,
                            PageName = pageName,
                            ColumnVisibility = visibilityJson
                        });
                    }

                    db.SubmitChanges();
                }
            }
            catch (Exception ex)
            {
                throw;
            }
        }

        [WebMethod]
        public static void SavePageState(int pageIndex)
        {
            if (HttpContext.Current.Session != null)
            {
                HttpContext.Current.Session["ServiceView_PageIndex"] = pageIndex;
            }
        }

        [WebMethod]
        public static int GetPageState()
        {
            if (HttpContext.Current.Session != null && HttpContext.Current.Session["ServiceView_PageIndex"] != null)
            {
                return Convert.ToInt32(HttpContext.Current.Session["ServiceView_PageIndex"]);
            }
            return 0; 
        }

        [WebMethod]
        public static string GetItemLogs(long itemId)
        {
            return INVItemLogHelper.GetItemLogsPayload(itemId);
        }
    }
}