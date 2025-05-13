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

namespace PMS.AP
{
    public partial class PurchaseRequistionView : System.Web.UI.Page
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
        public static bool DeleteRecord(string PR_Id)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            var userid = AppConfig.UserID;
            var date = DateTime.Now;
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                var pr_ID = (from itm in db.Purchase_Requisitions
                             where (itm.PR_Id == int.Parse(PR_Id))
                             select itm.PR_Id).FirstOrDefault();
                if (pr_ID != 0)
                {
                    DBClass.exectueQuery("update Purchase_Requisition set Status='Cancelled',IsDeleted=1,Deleted_By='" + userid + "',Deleted_Date='" + date + "' where pr_ID =" + pr_ID, tranObj, con);
                    tranObj.Commit();
                }
                else
                {
                    tranObj.Rollback();
                    return false;
                }
            }
            catch (Exception ex)
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


                    var Total_Purchase = _dbContext.Purchase_Requisitions.Count();
                    var Purchase = from PR in _dbContext.Purchase_Requisitions
                                   where userDepartments.Contains(PR.Department)
                                   &&
                                     ((PR.PR_Id.ToString().Contains(searchValue) || PR.PR_Num.ToString().Contains(searchValue) || _dbContext.GetDataValueName("Priority Type", PR.Priority).Contains(searchValue) 
                                      || _dbContext.GetDataValueName("Department", PR.Department).Contains(searchValue) || PR.Remarks.ToString().Contains(searchValue) || PR.Status.ToString().Contains(searchValue)
                                      || _dbContext.aspnet_Users.Where(x => x.UserId == PR.Created_By).Select(x => x.UserName).FirstOrDefault().Contains(searchValue)))
                                  select new
                                  {
                                      PR_Id = PR.PR_Id,
                                      PR_Num = PR.PR_Num,
                                      PR_Date = PR.PR_Date,
                                      Priority = _dbContext.GetDataValueName("Priority Type", PR.Priority),
                                      Department = _dbContext.GetDataValueName("Department", PR.Department),
                                      Remarks = PR.Remarks,
                                      Status = PR.Status,
                                      TotalQty = (from x in _dbContext.Purchase_Requisition_Details where x.PR_ID == (long?)(long)PR.PR_Id select (decimal?)x.Qty).Sum() ?? 0,
                                      CreatedBY = _dbContext.aspnet_Users.Where(x => x.UserId == PR.Created_By).Select(x => x.UserName).FirstOrDefault(),
                                  };

                    var FilteredCount = Purchase.Count();
                    switch (sortColumn)
                    {
                        case "PR_Num":
                            Purchase = sortColumnDirection == "asc" ? Purchase.OrderBy(a => a.PR_Num) : Purchase.OrderByDescending(a => a.PR_Num);
                            break;
                        case "PR_Date":
                            Purchase = sortColumnDirection == "asc" ? Purchase.OrderBy(b => b.PR_Date) : Purchase.OrderByDescending(a => a.PR_Date);
                            break;
                        default:
                            Purchase = Purchase.OrderByDescending(a => a.PR_Id);
                            break;
                    }

                    var PurchaseList = Purchase.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Purchase, data = PurchaseList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Purchase list", ex);
            }
        }

    }
}