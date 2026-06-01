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
        public static List<object> GetAuditInfo(int invoiceId)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.spGetAuditRecordAginstPR(invoiceId).ToList<object>();

                return query;
            }

        }
        [WebMethod]
        public static object GetMasterAndDetail(int invoiceId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                // Master record
                var master = (from m in db.Purchase_Requisitions
                              where m.PR_Id == invoiceId
                              select new
                              {
                                  ID = m.PR_Id,
                                  Number = m.PR_Num,
                                  Date = m.PR_Date,
                                  //VendorName = DBClass.getField("select Vendor_Name from AP_Vendors where Vendor_ID=" + m.ven),
                                  Status = m.Status,
                                  Remarks = m.Remarks
                              }).FirstOrDefault();

                // Detail rows
                var detail = (from d in db.Purchase_Requisition_Details
                              join inv in db.INV_Items on d.Item_ID equals inv.Item_ID
                              where d.PR_ID == invoiceId
                              select new
                              {
                                  inv.Item_Code,
                                  inv.Description,
                                  d.Qty,
                                  d.EstimateCost,
                                  d.Required_Date

                              }).ToList();

                return new
                {
                    Master = master,
                    Detail = detail
                };
            }
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
                                   select new
                                   {
                                       PR_Id = PR.PR_Id,
                                       PR_Num = PR.PR_Num,
                                       PR_Date = PR.PR_Date,
                                       Priority = _dbContext.GetDataValueName("Priority Type", PR.Priority),
                                       Department = _dbContext.GetDataValueName("Department", PR.Department),
                                       Remarks = PR.Remarks,
                                       Status = PR.Status,
                                       Update_Date = PR.Update_Date,
                                       TotalQty = (from x in _dbContext.Purchase_Requisition_Details where x.PR_ID == (long?)(long)PR.PR_Id select (decimal?)x.Qty).Sum() ?? 0,
                                       CreatedBY = _dbContext.aspnet_Users.Where(x => x.UserId == PR.Created_By).Select(x => x.UserName).FirstOrDefault(),
                                       UpdatedBY = _dbContext.aspnet_Users.Where(x => x.UserId == PR.Updated_By).Select(x => x.UserName).FirstOrDefault(),
                                   };

                    // Apply search filter if searchValue is not empty
                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        Purchase = Purchase.Where(x =>
                            x.PR_Id.ToString().Contains(searchValue) ||
                            x.PR_Num.ToString().Contains(searchValue) ||
                            x.Priority.Contains(searchValue) ||
                            x.Department.Contains(searchValue) ||
                            (x.Remarks != null && x.Remarks.ToString().Contains(searchValue)) ||
                            x.Status.Contains(searchValue) ||
                            (x.CreatedBY != null && x.CreatedBY.Contains(searchValue) ||
                            x.UpdatedBY != null && x.UpdatedBY.Contains(searchValue))
                        );
                    }

                    var FilteredCount = Purchase.Count();

                    // Apply sorting
                    switch (sortColumn)
                    {
                        case "PR_Num":
                            Purchase = sortColumnDirection == "asc" ? Purchase.OrderBy(a => a.PR_Num) : Purchase.OrderByDescending(a => a.PR_Num);
                            break;
                        case "PR_Date":
                            Purchase = sortColumnDirection == "asc" ? Purchase.OrderBy(b => b.PR_Date) : Purchase.OrderByDescending(a => a.PR_Date);
                            break;
                        case "Department":
                            Purchase = sortColumnDirection == "asc" ? Purchase.OrderBy(a => a.Department) : Purchase.OrderByDescending(a => a.Department);
                            break;
                        case "CreatedBY":
                            Purchase = sortColumnDirection == "asc" ? Purchase.OrderBy(a => a.CreatedBY) : Purchase.OrderByDescending(a => a.CreatedBY);
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

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "PurchaseRequisitionView";

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
                string pageName = "PurchaseRequisitionView";

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