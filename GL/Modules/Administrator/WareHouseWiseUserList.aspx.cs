using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class WareHouseWiseUserList : System.Web.UI.Page
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

                    DateTime searchDate;
                    bool isDateSearch = DateTime.TryParse(searchValue, out searchDate);

                    var Total_WareHouse_Wise_User = _dbContext.WareHouse_Wise_Users.Count();
                    var WareHouse = from WU in _dbContext.WareHouse_Wise_Users
                                     join As in _dbContext.aspnet_Users on WU.User_Id equals As.UserId
                                     where (
                                     As.UserName.Contains(searchValue) || (isDateSearch && WU.Created_Time >= searchDate && WU.Created_Time < searchDate.AddDays(1)))
                                     select new
                                     {
                                         WareHouse_wise_User_Id = WU.WareHouse_wise_User_Id,
                                         UserName = As.UserName,
                                         Created_Time = WU.Created_Time,
                                     };

                    var FilteredCount = WareHouse.Count();
                    switch (sortColumn)
                    {
                        case "UserName":
                            WareHouse = sortColumnDirection == "asc" ? WareHouse.OrderBy(a => a.UserName) : WareHouse.OrderByDescending(a => a.UserName);
                            break;
                        default:
                            WareHouse = WareHouse.OrderBy(a => a.WareHouse_wise_User_Id);
                            break;
                    }


                    var DepartmentWiseList = WareHouse.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_WareHouse_Wise_User, data = DepartmentWiseList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Ward list", ex);
            }
        }
        [WebMethod]
        public static string DeleteRecord(string ID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var Delete = DBClass.getField("delete from WareHouse_Wise_User where WareHouse_wise_User_Id= '" + ID + "' ");
            var DeleteMaster = DBClass.getField("delete from WareHouse_wise_user_detail where WareHouse_wise_User_Id= '" + ID + "' ");
            return (Delete);
        }
    }
}
