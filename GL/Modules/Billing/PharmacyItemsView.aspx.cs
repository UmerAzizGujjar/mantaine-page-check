using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static Telerik.Web.UI.OrgChartStyles;

namespace PMS
{
    public partial class PharmacyItemsView : System.Web.UI.Page
    {

        public static string ItemType = "";

        protected void Page_Load(object sender, EventArgs e)
        {

        }


        [WebMethod]
        public static bool DeleteRecord(int ItemID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            INV_Item item = db.INV_Items.Where(i => i.Item_ID == ItemID).FirstOrDefault();
            db.INV_Items.DeleteOnSubmit(item);
            db.SubmitChanges();
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
                    var Items = from I in _dbContext.INV_Items
                                where I.Pharmacy_Item == true &&
                                     ((I.Item_ID.ToString().Contains(searchValue) || I.Item_Code.Contains(searchValue) || I.Description.Contains(searchValue) || _dbContext.GetDataValueName("UOM", I.Unit).Contains(searchValue)))
                                    select new
                                    {
                                        Item_ID = I.Item_ID,
                                        Item_Code = I.Item_Code,
                                        Description = I.Description,
                                        Sale_Rate = I.Sale_Rate,
                                        Service = I.Services.HasValue && !I.Services.Value ? "Item" : I.Services.HasValue && I.Services.Value ? "Service" : "",
                                        Unit = _dbContext.GetDataValueName("UOM", I.Unit),
                                    };

                    var FilteredCount = Items.Count();
                    switch (sortColumn)
                    {
                        
                        case "Item_Code":
                            Items = sortColumnDirection == "asc" ? Items.OrderBy(b => b.Item_Code) : Items.OrderByDescending(a => a.Item_Code);
                            break;
                        default:
                            Items = Items.OrderByDescending(a => a.Item_ID);
                            break;
                    }

                    var patientList = Items.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Items, data = patientList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Item list", ex);
            }
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "PharmacyItemsView";

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
                string pageName = "PharmacyItemsView";

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
    }
}