using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Inventory
{
    public partial class ItemSelectionList : System.Web.UI.Page
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


                    var Total_Items = _dbContext.ItemSelection_Masters.Count();
                    var Item_Selection = from p in _dbContext.ItemSelection_Masters
                                   where (p.GRN_Num.ToString().Contains(searchValue) || p.VendorName.Contains(searchValue) || p.WarehouseName.Contains(searchValue))
                                   select new
                                   {
                                       Selection_ID = p.Selection_ID,
                                       Selection_Date = p.Selection_Date,
                                       GRN_Num = p.GRN_Num,
                                       VendorName = p.VendorName,
                                       WarehouseName = p.WarehouseName,
                                       Remarks = p.Remarks,
                                       Created_By = _dbContext.aspnet_Users.Where(x => x.UserId == p.Created_By).Select(x => x.UserName).FirstOrDefault(),
                                   };



                    var FilteredCount = Item_Selection.Count();
                    switch (sortColumn)
                    {
                        case "GRN_Num":
                            Item_Selection = sortColumnDirection == "asc" ? Item_Selection.OrderBy(a => a.GRN_Num) : Item_Selection.OrderByDescending(a => a.GRN_Num);
                            break;
                        case "Selection_Date":
                            Item_Selection = sortColumnDirection == "asc" ? Item_Selection.OrderBy(a => a.Selection_Date) : Item_Selection.OrderByDescending(a => a.Selection_Date);
                            break;
                        default:
                            Item_Selection = Item_Selection.OrderByDescending(a => a.Selection_ID);
                            break;
                    }


                    var ItemSelectionList = Item_Selection.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Items, data = ItemSelectionList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Items selection list", ex);
            }
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "ItemSelectionList";

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
                string pageName = "ItemSelectionList";

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
        public static string GetSelectionDetails(int selectionId)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var selectionDetails = db.ItemSelection_Details
                        .Where(sd => sd.Selection_ID == selectionId)
                        .Select(sd => new
                        {
                            ItemCode = sd.ItemCode,
                            ItemName = sd.ItemName,
                            GRN_Qty = sd.GRN_Qty,
                            Selected_Qty = sd.Selected_Qty,
                            BatchNum = sd.BatchNum,
                            Unit = sd.Unit,
                            Rate = sd.Rate
                        })
                        .ToList();

                    return Newtonsoft.Json.JsonConvert.SerializeObject(selectionDetails);
                }
            }
            catch (Exception ex)
            {
                return Newtonsoft.Json.JsonConvert.SerializeObject(new { error = ex.Message });
            }
        }

    }
}