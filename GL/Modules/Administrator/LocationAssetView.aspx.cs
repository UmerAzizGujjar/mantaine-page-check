using Infragistics.Web.UI.GridControls;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class LocationAssetView : System.Web.UI.Page
    {     
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
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

                    var Total_Order = _dbContext.Locations.Count();
                    var location = from loc in _dbContext.Locations where loc.IsDeleted==false
                                         where
                                             (loc.Location_ID.ToString().Contains(searchValue) || loc.Location_Code.ToString().Contains(searchValue) || loc.Location_Description.ToString().Contains(searchValue))
                                         select new
                                         {
                                             Location_ID = loc.Location_ID,
                                             Location_Code = loc.Location_Code,
                                             Location_Description = loc.Location_Description, 
                                         };

                    var FilteredCount = location.Count();
                    switch (sortColumn)
                    {                      
                        case "Location_Code":
                            location = sortColumnDirection == "asc" ? location.OrderBy(b => b.Location_Code) : location.OrderByDescending(a => a.Location_Code);
                            break;
                        case "Location_Description":
                            location = sortColumnDirection == "asc" ? location.OrderBy(b => b.Location_Description) : location.OrderByDescending(a => a.Location_Description);
                            break;                       
                        default:
                            location = location.OrderByDescending(a => a.Location_Code);
                            break;
                    }
                    var PurchaseList = location.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Order, data = PurchaseList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Location list", ex);
            }
        }

        [WebMethod]
        public static string Savelocation(string Location_ID, string Location_Code, string Location_Description, string btnValue)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            Location obj = null;

            try
            {
                if (btnValue == "Save")
                {
                    if (string.IsNullOrEmpty(Location_ID) || Location_ID == "0")
                    {
                        obj = new Location
                        {
                            Location_Code = Location_Code,
                            Location_Description = Location_Description,
                            Created_Time = DateTime.Now,
                            Created_By = AppConfig.UserID,
                            IsDeleted = false
                        };
                        db.Locations.InsertOnSubmit(obj);
                    }
                    else
                    {
                        return "Error: Invalid operation for saving a new record.";
                    }
                }
                else if (btnValue == "Update")
                {
                    obj = db.Locations.FirstOrDefault(x => x.Location_ID == Convert.ToInt32(Location_ID));
                    if (obj == null)
                    {
                        return "Error: Location not found.";
                    }
                    obj.Location_Code = Location_Code;
                    obj.Location_Description = Location_Description;
                    obj.Updated_Time = DateTime.Now;
                    obj.Updated_By = AppConfig.UserID;
                }

                db.SubmitChanges();
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }

            return "Success-" + (obj?.Location_ID.ToString() ?? "0");
        }
    }
}