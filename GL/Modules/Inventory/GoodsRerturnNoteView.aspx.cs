using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Inventory
{
    public partial class GoodsRerturnNoteView : System.Web.UI.Page
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
                    var userDepartments = _dbContext.Department_Wise_User_Details
                     .Where(dept => dept.User_Id == AppConfig.UserID)
                     .Select(dept => dept.Department)
                     .ToList();

                    var userWarehouses = _dbContext.WareHouse_Wise_User_Details
                                           .Where(ware => ware.User_Id == AppConfig.UserID)
                                           .Select(ware => ware.WareHouse)
                                           .ToList();

                    var Total_StoreReturn = _dbContext.Goods_Return_Notes.Count();
                    var StoreReturn = from SI in _dbContext.Goods_Return_Notes
                                      where userDepartments.Contains(SI.Department_Id)
                                     && userWarehouses.Contains(SI.WareHouse) &&

                                      ((SI.Store_Issue_No.ToString().Contains(searchValue) ||SI.Store_Return_NO.ToString().Contains(searchValue) || _dbContext.GetDataValueName("Department", SI.Department_Id).Contains(searchValue) || _dbContext.GetDataValueName("Ware House", SI.WareHouse).Contains(searchValue) || SI.Status.Contains(searchValue) || _dbContext.aspnet_Users.Where(x => x.UserId == (from gmm in _dbContext.Store_Issues where gmm.Store_Issue_Id == SI.Store_Issue_No select gmm.Created_by).FirstOrDefault()).Select(x => x.UserName).FirstOrDefault().Contains(searchValue) || _dbContext.aspnet_Users.Where(x => x.UserId == SI.Created_BY).Select(x => x.UserName).FirstOrDefault().Contains(searchValue)))
                                      select new
                                      {
                                          Store_Return_Id = SI.Store_Return_Id,
                                          Store_Issue_No = (from str in _dbContext.Store_Issues where str.Store_Issue_Id == SI.Store_Issue_No select str.Store_Issue_No).FirstOrDefault(),
                                          Store_Return_No = SI.Store_Return_NO,
                                          Created_Time = SI.Create_Date,
                                          Update_Time = SI.Updated_Date,
                                          Updated_By = _dbContext.aspnet_Users.Where(x => x.UserId == SI.Updated_By).Select(x => x.UserName).FirstOrDefault(),
                                          Created_By = _dbContext.aspnet_Users.Where(x => x.UserId == SI.Created_BY).Select(x => x.UserName).FirstOrDefault(),
                                          Department = _dbContext.GetDataValueName("Department", SI.Department_Id),
                                          WareHouse = _dbContext.GetDataValueName("Ware House", SI.WareHouse),                                         
                                          Issuer = _dbContext.aspnet_Users.Where(x => x.UserId == (from gmm in _dbContext.Store_Issues
                                                                                                      where gmm.Store_Issue_Id == SI.Store_Issue_No
                                                                                                      select gmm.Created_by).FirstOrDefault()).Select(x => x.UserName).FirstOrDefault(),
        
                                          Status = SI.Status,
                                      };

                    var FilteredCount = StoreReturn.Count();
                    switch (sortColumn)
                    {
                        case "Store_Issue_No":
                            StoreReturn = sortColumnDirection == "asc" ? StoreReturn.OrderBy(a => a.Store_Issue_No) : StoreReturn.OrderByDescending(a => a.Store_Issue_No);
                            break;
                        case "Store_Return_No":
                            StoreReturn = sortColumnDirection == "asc" ? StoreReturn.OrderBy(a => a.Store_Return_No) : StoreReturn.OrderByDescending(a => a.Store_Return_No);
                            break;
                        case "Created_Time":
                            StoreReturn = sortColumnDirection == "asc" ? StoreReturn.OrderBy(b => b.Created_Time) : StoreReturn.OrderByDescending(a => a.Created_Time);
                            break;
                        default:
                            StoreReturn = StoreReturn.OrderByDescending(a => a.Store_Return_Id);
                            break;
                    }

                    var StoreIssueList = StoreReturn.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_StoreReturn, data = StoreIssueList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Store Issue list", ex);
            }
        }
    }
}