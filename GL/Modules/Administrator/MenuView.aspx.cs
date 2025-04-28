using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Security.Policy;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Infragistics.Web.UI.GridControls;

namespace PMS
{
    public partial class MenuView : System.Web.UI.Page
    {
        protected override void OnInit(EventArgs e)
        {
            
        }
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static bool DeleteRecord(string AppID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var remove = (from aremove in db.Menus
                          where aremove.Menu_ID == Convert.ToInt32(AppID)
                          select aremove).FirstOrDefault();
            if (remove != null)
            {
                remove.IsActive = false;
            }

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

                    var Total_Menus = _dbContext.Menus.Count();
                    var Menu = from ab in _dbContext.Menus
                               where ab.IsActive == true
                               && (ab.Menu_Description.Contains(searchValue) || ab.Menu_Name.Contains(searchValue) || ab.URL.Contains(searchValue) || ab.Parent_ID.ToString().Contains(searchValue)
                               || (from p in _dbContext.Menus where p.Menu_ID == ab.Parent_ID select p.Menu_Description).FirstOrDefault().ToString().Contains(searchValue))
                               select new
                               {
                                   Menu_ID =  ab.Menu_ID,
                                   Menu_Name = ab.Menu_Name,
                                   Menu_Description =  ab.Menu_Description,
                                   URL = ab.URL,
                                   Parent_Menu = (from p in _dbContext.Menus where p.Menu_ID == ab.Parent_ID select p.Menu_Description).FirstOrDefault(),
                                   Order_By=  ab.Order_By,
                                   IsActive  = ab.IsActive
                               };

                    var FilteredCount = Menu.Count();
                    switch (sortColumn)
                    {
                        case "Order_By":
                            Menu = sortColumnDirection == "asc" ? Menu.OrderBy(a => a.Order_By) : Menu.OrderByDescending(a => a.Order_By);
                            break;
                        default:
                            Menu = Menu.OrderByDescending(a => a.Order_By);
                            break;
                    }


                    var MenuList = Menu.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Menus, data = MenuList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Menu list", ex);
            }
        }


    }
}