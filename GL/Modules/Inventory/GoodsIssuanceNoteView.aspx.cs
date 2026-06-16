using PMS.Inventory;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class GoodsIssuanceNoteView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        [WebMethod]
        public static object GetMasterAndDetail(int invoiceId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var master = (from m in db.Store_Issues
                              where m.Store_Issue_Id == invoiceId
                              select new
                              {
                                  ID = m.Store_Issue_Id,
                                  Number = m.Store_Issue_No,
                                  Date = m.Created_Time,
                                  Status = m.Status,
                              }).FirstOrDefault();

                var detail = (from d in db.Store_Issue_Details
                              join mid in db.MaterialIssueRequest_Details on d.MIR_Detail_Id equals Convert.ToInt32(mid.MaterialRequestDetail_Id)
                              join mir in db.MaterialIssueRequests on mid.MaterialRequest_Id equals mir.MaterialRequest_Id
                              join inv in db.INV_Items on d.Item_Id equals inv.Item_ID
                              where d.Store_Issue_Id == invoiceId
                              select new
                              {
                                  inv.Item_Code,
                                  inv.Description,
                                  d.Issue_Qty,
                                  mid.MIRQty,
                                  blnc_Qty = mid.MIRQty - (from ab in db.Store_Issue_Details
                                                           where ab.MIR_Detail_Id == d.MIR_Detail_Id
                                                           select ab.Issue_Qty).Sum(),
                                  d.MIR_Detail_Id
                              }).ToList();

                return new
                {
                    Master = master,
                    Detail = detail
                };
            }
        }

        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection,
                                      string searchValue, string girStatus)  // <-- new parameter
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

                    var Total_StoreIssues = _dbContext.Store_Issues.Count();

                    // Base query with all needed fields, including computed Blnc_Qty
                    var StoreIssues = from SI in _dbContext.Store_Issues
                                      where userDepartments.Contains(SI.Department_Id)
                                         && userWarehouses.Contains(SI.Organization_Id)
                                         && (
                                             SI.Store_Issue_No.ToString().Contains(searchValue) ||
                                             _dbContext.GetDataValueName("Department", SI.Department_Id).Contains(searchValue) ||
                                             _dbContext.GetDataValueName("Ware House", SI.Organization_Id).Contains(searchValue) ||
                                             SI.Status.Contains(searchValue) ||
                                             _dbContext.aspnet_Users.Where(x => x.UserId == (from gmm in _dbContext.MaterialIssueRequests
                                                                                             where gmm.MaterialRequest_Id == (from gm in _dbContext.Store_Issue_Details
                                                                                                                              where gm.Store_Issue_Id == SI.Store_Issue_Id
                                                                                                                              select gm.MIR_Id).FirstOrDefault()
                                                                                             select gmm.Created_By).FirstOrDefault())
                                                                   .Select(x => x.UserName).FirstOrDefault().Contains(searchValue) ||
                                             _dbContext.aspnet_Users.Where(x => x.UserId == SI.Created_by)
                                                                   .Select(x => x.UserName).FirstOrDefault().Contains(searchValue)
                                         )
                                      select new
                                      {
                                          Store_Issue_Id = SI.Store_Issue_Id,
                                          Store_Issue_No = SI.Store_Issue_No,
                                          Created_Time = SI.Created_Time,
                                          Update_Time = SI.Update_Time,
                                          Updated_By = _dbContext.aspnet_Users.Where(x => x.UserId == SI.Updated_By).Select(x => x.UserName).FirstOrDefault(),
                                          Department = _dbContext.GetDataValueName("Department", SI.Department_Id),
                                          WareHouse = _dbContext.GetDataValueName("Ware House", SI.Organization_Id),
                                          RequestNo = (from gmm in _dbContext.MaterialIssueRequests
                                                       where gmm.MaterialRequest_Id == (from gm in _dbContext.Store_Issue_Details
                                                                                        where gm.Store_Issue_Id == SI.Store_Issue_Id
                                                                                        select gm.MIR_Id).FirstOrDefault()
                                                       select gmm.Request_No).FirstOrDefault(),
                                          Requester = _dbContext.aspnet_Users.Where(x => x.UserId == (from gmm in _dbContext.MaterialIssueRequests
                                                                                                      where gmm.MaterialRequest_Id == (from gm in _dbContext.Store_Issue_Details
                                                                                                                                       where gm.Store_Issue_Id == SI.Store_Issue_Id
                                                                                                                                       select gm.MIR_Id).FirstOrDefault()
                                                                                                      select gmm.Created_By).FirstOrDefault())
                                                                           .Select(x => x.UserName).FirstOrDefault(),
                                          Issuer = _dbContext.aspnet_Users.Where(x => x.UserId == SI.Created_by).Select(x => x.UserName).FirstOrDefault(),
                                          Status = SI.Status,
                                          Blnc_Qty = (
                                              from gm in _dbContext.Store_Issue_Details
                                              where gm.Store_Issue_Id == SI.Store_Issue_Id
                                              group gm by gm.MIR_Detail_Id into g
                                              let mirQty = g.FirstOrDefault().MIR_Qty
                                              let totalIssued = _dbContext.Store_Issue_Details
                                                                  .Where(x => x.MIR_Detail_Id == g.Key)
                                                                  .Sum(x => (decimal?)x.Issue_Qty) ?? 0
                                              select mirQty - totalIssued
                                          ).Sum(),
                                          Approved_Time = SI.Approved_Time,
                                      };

                    // Apply GIR Status filter
                    if (!string.IsNullOrEmpty(girStatus))
                    {
                        if (girStatus == "Complete")
                            StoreIssues = StoreIssues.Where(s => s.Blnc_Qty == 0);
                        else if (girStatus == "Partial")
                            StoreIssues = StoreIssues.Where(s => s.Blnc_Qty > 0);
                    }

                    var FilteredCount = StoreIssues.Count();

                    // Sorting
                    switch (sortColumn)
                    {
                        case "Store_Issue_No":
                            StoreIssues = sortColumnDirection == "asc" ? StoreIssues.OrderBy(a => a.Store_Issue_No) : StoreIssues.OrderByDescending(a => a.Store_Issue_No);
                            break;
                        case "Created_Time":
                            StoreIssues = sortColumnDirection == "asc" ? StoreIssues.OrderBy(b => b.Created_Time) : StoreIssues.OrderByDescending(a => a.Created_Time);
                            break;
                        default:
                            StoreIssues = StoreIssues.OrderByDescending(a => a.Store_Issue_Id);
                            break;
                    }

                    var StoreIssueList = StoreIssues.Skip(start).Take(length).ToList();

                    var jsonData = new
                    {
                        draw = draw,
                        recordsFiltered = FilteredCount,
                        recordsTotal = Total_StoreIssues,
                        data = StoreIssueList
                    };
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