using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web.UI;

namespace PMS
{
    public partial class WardDefinitionView : System.Web.UI.Page
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


                    var wards = _dbContext.Ward_Definitions.Count();
                    var ward = from a in _dbContext.Ward_Definitions
                              where (a.Ward_No.ToString().Contains(searchValue) || a.Ward_Type.Contains(searchValue) || _dbContext.GetDataValueName("Patient Main Category", a.Department).Contains(searchValue)
                              || a.No_Of_Beds.ToString().Contains(searchValue))
                              select new
                              {
                                  Ward_No = a.Ward_No,
                                  Ward_Type = a.Ward_Type,
                                  No_Of_Beds = a.No_Of_Beds,
                                  Ward_ID = a.Ward_ID,
                                  Department = _dbContext.GetDataValueName("Patient Main Category", a.Department),


                              };
                    var FilteredCount = ward.Count();
                    switch (sortColumn)
                    {
                        case "Ward_No":
                            ward = sortColumnDirection == "asc" ? ward.OrderBy(a => a.Ward_No) : ward.OrderByDescending(a => a.Ward_No);
                            break;
                        default:
                            ward = ward.OrderByDescending(a => a.Ward_ID);
                            break;
                    }


                    var templatelist = ward.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = wards, data = templatelist };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Medicine Template list", ex);
            }
        }

        [WebMethod]
        public static bool DeleteRecord(string itemID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                try
                {
                    int id = int.Parse(itemID);
                    var item = db.INV_Items.SingleOrDefault(i => i.Item_ID == id);

                    if (item != null)
                    {
                        db.INV_Items.DeleteOnSubmit(item);
                        db.SubmitChanges();
                        return true;
                    }
                    return false;
                }
                catch (Exception)
                {
                    return false;
                }
            }
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "WardDefinitionView";

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
                string pageName = "WardDefinitionView";

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
