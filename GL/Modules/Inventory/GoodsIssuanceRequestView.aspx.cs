using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Web.Script.Services;
using Telerik.Web;

namespace PMS.Inventory
{
    public partial class GoodsIssuanceRequestView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static bool isDeleteAllow()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            bool value = Convert.ToBoolean(DBClass.getField("select  isnull(AllowPatientDelete,0) from aspnet_users where username='" + AppConfig.UserName + "'"));
            return value;

        }

        [WebMethod]
        public static bool DeleteRecord(string MIRID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                var MIR_ID = (from itm in db.MaterialIssueRequests
                              where (itm.MaterialRequest_Id == int.Parse(MIRID))
                              select itm.MaterialRequest_Id).FirstOrDefault();
                if (MIR_ID != 0)
                {
                    DBClass.exectueQuery("delete MaterialIssueRequest_Detail where MaterialRequest_Id =" + MIR_ID, tranObj, con);
                    DBClass.exectueQuery("delete MaterialIssueRequest where MaterialRequest_Id =" + MIR_ID, tranObj, con);
                    tranObj.Commit();
                }
                else
                {
                    tranObj.Rollback();
                    return false;
                }
            }
#pragma warning disable CS0168 // The variable 'ex' is declared but never used
            catch (Exception ex)
#pragma warning restore CS0168 // The variable 'ex' is declared but never used
            {
                if (tranObj != null)
                    tranObj.Rollback();
                return false;
            }
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

                    var userDepartments = _dbContext.Department_Wise_User_Details
                     .Where(dept => dept.User_Id == AppConfig.UserID)
                     .Select(dept => dept.Department)
                     .ToList();

                    var userWarehouses = _dbContext.WareHouse_Wise_User_Details
                                      .Where(ware => ware.User_Id == AppConfig.UserID)
                                      .Select(ware => ware.WareHouse)
                                      .ToList();


                    var Total_GOODISSUANCE = _dbContext.MaterialIssueRequests.Count();
                    var MaterialIssue = from MIR in _dbContext.MaterialIssueRequests
                                        where userDepartments.Contains(MIR.Department) && userWarehouses.Contains(MIR.InventoryOrganization)
                                        && (MIR.Request_No.ToString().Contains(searchValue) || MIR.Remarks.ToString().Contains(searchValue) || _dbContext.GetDataValueName("Department", MIR.Department).Contains(searchValue) || MIR.Status.Contains(searchValue) || _dbContext.aspnet_Users.Where(x => x.UserId == MIR.Created_By).Select(x => x.UserName).FirstOrDefault().Contains(searchValue))
                                        select new
                                        {
                                            MaterialRequest_Id = MIR.MaterialRequest_Id,
                                            Request_No = MIR.Request_No,
                                            Priority = MIR.Priority,
                                            Department = _dbContext.GetDataValueName("Department", MIR.Department),
                                            Remarks = MIR.Remarks,
                                            Status = MIR.Status,
                                            CreatedBY = _dbContext.aspnet_Users.Where(x => x.UserId == MIR.Created_By).Select(x => x.UserName).FirstOrDefault(),
                                        };

                    var FilteredCount = MaterialIssue.Count();
                    switch (sortColumn)
                    {
                        case "Request_No":
                            MaterialIssue = sortColumnDirection == "asc" ? MaterialIssue.OrderBy(a => a.Request_No) : MaterialIssue.OrderByDescending(a => a.Request_No);
                            break;
                        case "Priority":
                            MaterialIssue = sortColumnDirection == "asc" ? MaterialIssue.OrderBy(b => b.Priority) : MaterialIssue.OrderByDescending(a => a.Priority);
                            break;                       
                        default:
                            MaterialIssue = MaterialIssue.OrderByDescending(a => a.MaterialRequest_Id);
                            break;
                    }

                    var GoodIssuanceLIST = MaterialIssue.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_GOODISSUANCE, data = GoodIssuanceLIST };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Good Issuance list", ex);
            }
        }

    }
}