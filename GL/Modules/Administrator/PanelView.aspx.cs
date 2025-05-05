using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class PanelView : System.Web.UI.Page
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

                    var Total_Panels = _dbContext.Panels.Count();
                    var Panels = from P in _dbContext.Panels
                                    where (
                                          (P.Company_Name.ToString().Contains(searchValue) || P.No_Of_Employees.ToString().Contains(searchValue) || P.Address.ToString().Contains(searchValue)))
                                    select new
                                    {
                                        Panel_ID = P.Panel_ID,
                                        Company_Name = P.Company_Name,
                                        No_Of_Employees = P.No_Of_Employees,
                                        Contact_No = P.Contact_No,
                                        Address = P.Address,
                                        Discount = P.Discount,
                                        Email = P.Email,
                                    };

                    var FilteredCount = Panels.Count();
                    switch (sortColumn)
                    {
                        case "No_Of_Employees":
                            Panels = sortColumnDirection == "asc" ? Panels.OrderBy(a => a.No_Of_Employees) : Panels.OrderByDescending(a => a.No_Of_Employees);
                            break;
                        default:
                            Panels = Panels.OrderByDescending(a => a.Panel_ID);
                            break;
                    }


                    var PanelList = Panels.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Panels, data = PanelList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Employee list", ex);
            }
        }

        [WebMethod]
        public static string Delete(string panel_id)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            try 
            {
               DBClass.executeNonQueryWithoutBegin("delete from panel where panel_id=" + panel_id);

                return "success";
            }
            catch(Exception ex)
            {
                return "Error";
            }
          
        
        }
    }
}