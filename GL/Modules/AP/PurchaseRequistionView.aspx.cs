using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
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
                                       Created_Date = PR.Creation_Date,
                                       Approve_Time = PR.Approved_Time,
                                       TotalQty = (from x in _dbContext.Purchase_Requisition_Details where x.PR_ID == (long?)(long)PR.PR_Id select (decimal?)x.Qty).Sum() ?? 0,
                                       CreatedBY = _dbContext.aspnet_Users.Where(x => x.UserId == PR.Created_By).Select(x => x.UserName).FirstOrDefault(),
                                       UpdatedBY = _dbContext.aspnet_Users.Where(x => x.UserId == PR.Updated_By).Select(x => x.UserName).FirstOrDefault(),
                                       Approved_By = _dbContext.aspnet_Users.Where(x => x.UserId == PR.Approved_By).Select(x => x.UserName).FirstOrDefault(),
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

        // ================= PR CHANGE HISTORY (AP_Purchase_Requisition_Logs) =================

        private static string StrVal(object v)
        {
            if (v == null) return "";
            return Convert.ToString(v, CultureInfo.InvariantCulture);
        }

        private static string NumVal(object v)
        {
            if (v == null) return "";
            try { return Convert.ToDecimal(v).ToString("0.##", CultureInfo.InvariantCulture); }
            catch { return ""; }
        }

        private static string DateVal(object v)
        {
            if (v == null) return "";
            try { return Convert.ToDateTime(v).ToString("yyyy-MM-dd", CultureInfo.InvariantCulture); }
            catch { return ""; }
        }

        private static JToken ParseLogJson(string json)
        {
            if (string.IsNullOrWhiteSpace(json))
                return null;

            try { return JsonConvert.DeserializeObject<JToken>(json); }
            catch { return null; }
        }

        private static object BuildPRMasterSnapshot(Purchase_Requisition pr, DataBaseDataContext db)
        {
            string priorityName = "";
            if (!string.IsNullOrEmpty(pr.Priority))
            {
                try { priorityName = db.GetDataValueName("Priority Type", pr.Priority) ?? ""; }
                catch { priorityName = ""; }
            }

            string departmentName = "";
            if (!string.IsNullOrEmpty(pr.Department))
            {
                try { departmentName = db.GetDataValueName("Department", pr.Department) ?? ""; }
                catch { departmentName = ""; }
            }

            string warehouseName = "";
            if (!string.IsNullOrEmpty(pr.Warehouse))
            {
                try { warehouseName = db.GetDataValueName("Ware House", pr.Warehouse) ?? ""; }
                catch { warehouseName = ""; }
            }

            string branchName = "";
            if (pr.Branch_Id.HasValue)
            {
                branchName = (from b in db.Branches where b.branch_ID == pr.Branch_Id select b.branch_Name).FirstOrDefault() ?? "";
            }

            var snap = new Dictionary<string, string>();
            snap["PR_Num"] = pr.PR_Num.HasValue ? pr.PR_Num.Value.ToString() : "";
            snap["PR_Date"] = DateVal(pr.PR_Date);
            snap["Ref_No"] = StrVal(pr.Ref_Num);
            snap["Priority"] = priorityName;
            snap["Department"] = departmentName;
            snap["Warehouse"] = warehouseName;
            snap["Branch"] = branchName;
            snap["Status"] = StrVal(pr.Status);
            snap["Remarks"] = StrVal(pr.Remarks);
            return snap;
        }

        private static object BuildPRItemsSnapshot(DataBaseDataContext db, int prId)
        {
            var rows = (from d in db.Purchase_Requisition_Details
                        join i in db.INV_Items on d.Item_ID equals i.Item_ID
                        where d.PR_ID == prId
                        orderby d.PR_Detail_ID
                        select new
                        {
                            Item_Code = i.Item_Code,
                            Item_Name = i.Description,
                            d.Qty,
                            d.UnitPrice,
                            d.EstimateCost,
                            d.Required_Date,
                            d.Remarks
                        }).ToList();

            return new
            {
                Items = rows.Select(i => new
                {
                    Item_Code = StrVal(i.Item_Code),
                    Item_Name = StrVal(i.Item_Name),
                    Qty = NumVal(i.Qty),
                    UnitPrice = NumVal(i.UnitPrice),
                    EstimateCost = NumVal(i.EstimateCost),
                    Required_Date = DateVal(i.Required_Date),
                    Remarks = StrVal(i.Remarks)
                }).ToList()
            };
        }

        [WebMethod]
        public static string GetPRLogs(int prId)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var logRows = (from l in db.AP_Purchase_Requisition_Logs
                                   join u in db.aspnet_Users on l.Loged_By equals u.UserId into userJoin
                                   from u in userJoin.DefaultIfEmpty()
                                   where l.PR_Id == prId
                                   orderby l.Log_Time, l.Log_Id
                                   select new
                                   {
                                       l.Log_Id,
                                       l.Log_Time,
                                       l.Master_Log,
                                       l.Details_Log,
                                       UserName = u != null ? u.UserName : null
                                   }).ToList();

                    var logs = logRows.Select(r => new
                    {
                        Log_Id = r.Log_Id,
                        TimeText = r.Log_Time.HasValue ? r.Log_Time.Value.ToString("dd MMM yyyy hh:mm tt") : "",
                        UserName = string.IsNullOrEmpty(r.UserName) ? "" : r.UserName,
                        Master = ParseLogJson(r.Master_Log),
                        Details = ParseLogJson(r.Details_Log)
                    }).ToList();

                    var pr = db.Purchase_Requisitions.FirstOrDefault(p => p.PR_Id == prId);

                    object currentMaster = null;
                    object currentDetails = null;

                    if (pr != null)
                    {
                        currentMaster = BuildPRMasterSnapshot(pr, db);
                        currentDetails = BuildPRItemsSnapshot(db, pr.PR_Id);
                    }

                    var approvalRows = (from a in db.Sys_Approval_Logs
                                        join st in db.Sys_Approval_Stage_Masters on a.Approval_Stage_ID equals st.Stage_ID into stageJoin
                                        from st in stageJoin.DefaultIfEmpty()
                                        join au in db.aspnet_Users on a.Approve_By equals au.UserId into apprJoin
                                        from au in apprJoin.DefaultIfEmpty()
                                        join ru in db.aspnet_Users on a.Rejected_By equals ru.UserId into rejJoin
                                        from ru in rejJoin.DefaultIfEmpty()
                                        where a.Entry_ID == prId && a.Form_ID == 1
                                        orderby a.Approve_Date, a.ID
                                        select new
                                        {
                                            a.ID,
                                            StageName = st != null ? st.Stage_Name : null,
                                            a.Entry_Status,
                                            a.IsFinalAprroval,
                                            a.IsRejected,
                                            a.Is_ByPassed,
                                            a.IsEditableAfterApproval,
                                            Approver = au != null ? au.UserName : null,
                                            Rejector = ru != null ? ru.UserName : null,
                                            a.Approve_Date,
                                            a.Rejected_Date,
                                            a.Approval_Remarks,
                                            a.Rejection_Remarks,
                                            a.Remarks,
                                            a.From_Name
                                        }).ToList();

                    var approvals = approvalRows.Select(r => new
                    {
                        ID = r.ID,
                        StageName = StrVal(r.StageName),
                        Status = StrVal(r.Entry_Status),
                        IsFinal = r.IsFinalAprroval ?? false,
                        IsRejected = r.IsRejected ?? false,
                        IsByPassed = r.Is_ByPassed ?? false,
                        IsEditableAfterApproval = r.IsEditableAfterApproval ?? false,
                        User = !string.IsNullOrEmpty(r.Rejector) ? r.Rejector : StrVal(r.Approver),
                        DateText = (r.Rejected_Date ?? r.Approve_Date).HasValue
                            ? (r.Rejected_Date ?? r.Approve_Date).Value.ToString("dd MMM yyyy hh:mm tt")
                            : "",
                        Remarks = !string.IsNullOrEmpty(r.Rejection_Remarks)
                            ? r.Rejection_Remarks
                            : (!string.IsNullOrEmpty(r.Approval_Remarks) ? r.Approval_Remarks : StrVal(r.Remarks)),
                        FromName = StrVal(r.From_Name)
                    }).ToList();

                    return JsonConvert.SerializeObject(new
                    {
                        logs = logs,
                        current = new { master = currentMaster, details = currentDetails },
                        approvals = approvals
                    });
                }
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new { error = ex.Message });
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