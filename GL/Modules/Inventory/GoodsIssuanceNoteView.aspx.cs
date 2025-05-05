using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web;

namespace PMS
{
    public partial class GoodsIssuanceNoteView : System.Web.UI.Page
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

                    var Total_StoreIssues = _dbContext.Store_Issues.Count();
                    var StoreIssues = from SI in _dbContext.Store_Issues
                               where
                                    ((SI.Store_Issue_No.ToString().Contains(searchValue) || _dbContext.GetDataValueName("Department", SI.Department_Id).Contains(searchValue) || _dbContext.GetDataValueName("Ware House", SI.Organization_Id).Contains(searchValue) || SI.Status.Contains(searchValue) || _dbContext.aspnet_Users.Where(x => x.UserId == (from gmm in _dbContext.MaterialIssueRequests where gmm.MaterialRequest_Id == (from gm in _dbContext.Store_Issue_Details where gm.Store_Issue_Id ==  SI.Store_Issue_Id select gm.MIR_Id).FirstOrDefault() select gmm.Created_By).FirstOrDefault()).Select(x => x.UserName).FirstOrDefault().Contains(searchValue) || _dbContext.aspnet_Users.Where(x => x.UserId == SI.Created_by).Select(x => x.UserName).FirstOrDefault().Contains(searchValue)))
                               select new
                               {
                                   Store_Issue_Id = SI.Store_Issue_Id,
                                   Store_Issue_No = SI.Store_Issue_No,
                                   Created_Time = SI.Created_Time,
                                   Department = _dbContext.GetDataValueName("Department", SI.Department_Id),
                                   WareHouse = _dbContext.GetDataValueName("Ware House", SI.Organization_Id),
                                   RequestNo = (from gmm in _dbContext.MaterialIssueRequests where gmm.MaterialRequest_Id == (from gm in _dbContext.Store_Issue_Details where gm.Store_Issue_Id == SI.Store_Issue_Id select gm.MIR_Id).FirstOrDefault() select gmm.Request_No).FirstOrDefault(),
                                   Requester = _dbContext.aspnet_Users.Where(x => x.UserId == (from gmm in _dbContext.MaterialIssueRequests
                                                                                       where gmm.MaterialRequest_Id == (from gm in _dbContext.Store_Issue_Details
                                                                                                                        where gm.Store_Issue_Id == SI.Store_Issue_Id
                                                                                                                        select gm.MIR_Id).FirstOrDefault()
                                                                                       select gmm.Created_By).FirstOrDefault()).Select(x => x.UserName).FirstOrDefault(),
                                   Issuer = _dbContext.aspnet_Users.Where(x => x.UserId == SI.Created_by).Select(x => x.UserName).FirstOrDefault(),
                                   Status = SI.Status,
                               };

                    var FilteredCount = StoreIssues.Count();
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

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_StoreIssues, data = StoreIssueList };
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

