using PMS.Inventory;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

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

        // ================= GIN CHANGE HISTORY (Store_Issue_Logs) =================

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

        private static object BuildGINMasterSnapshot(Store_Issue si, DataBaseDataContext db)
        {
            string deptName = "";
            if (!string.IsNullOrEmpty(si.Department_Id))
            {
                try { deptName = db.GetDataValueName("Department", si.Department_Id) ?? ""; }
                catch { deptName = ""; }
            }

            string warehouseName = "";
            if (!string.IsNullOrEmpty(si.Organization_Id))
            {
                try { warehouseName = db.GetDataValueName("Ware House", si.Organization_Id) ?? ""; }
                catch { warehouseName = ""; }
            }

            var snap = new Dictionary<string, string>();
            snap["Store_Issue_No"] = si.Store_Issue_No.HasValue ? si.Store_Issue_No.Value.ToString() : "";
            snap["Date"] = DateVal(si.Created_Time);
            snap["Department"] = deptName;
            snap["Ware_House"] = warehouseName;
            snap["MR_No"] = StrVal(si.MR_No);
            snap["Status"] = StrVal(si.Status);
            snap["Approved_Time"] = DateVal(si.Approved_Time);
            snap["Update_Time"] = DateVal(si.Update_Time);
            return snap;
        }

        private static object BuildGINDetailSnapshot(DataBaseDataContext db, int storeIssueId)
        {
            var rows = db.Store_Issue_Details.Where(t => t.Store_Issue_Id == storeIssueId).ToList();

            var ids = rows.Where(r => r.Item_Id.HasValue).Select(r => (int)r.Item_Id.Value).Distinct().ToList();
            var itemNames = new Dictionary<int, string>();
            var itemCodes = new Dictionary<int, string>();
            foreach (var id in ids)
            {
                var itm = db.INV_Items.Where(x => x.Item_ID == id)
                                       .Select(x => new { x.Description, x.Item_Code })
                                       .FirstOrDefault();
                itemNames[id] = itm != null ? (itm.Description ?? "") : "";
                itemCodes[id] = itm != null ? (itm.Item_Code ?? "") : "";
            }

            return new
            {
                Items = rows.Select(i =>
                {
                    string name = "";
                    string code = "";
                    if (i.Item_Id.HasValue)
                    {
                        int key = (int)i.Item_Id.Value;
                        if (itemNames.ContainsKey(key)) name = itemNames[key];
                        if (itemCodes.ContainsKey(key)) code = itemCodes[key];
                    }

                    return new
                    {
                        Item_Name = name,
                        Item_Code = code,
                        MIRDetailId = i.MIR_Detail_Id.HasValue ? i.MIR_Detail_Id.Value.ToString() : "",
                        Qty = NumVal(i.MIR_Qty),
                        Issue_Qty = NumVal(i.Issue_Qty),
                        Balance_Qty = NumVal(i.Balance_Qty),
                        Store_Stock = StrVal(i.Store_Stock),
                        Department = StrVal(i.Department),
                        BatchNum = StrVal(i.BatchNum),
                        Remarks = StrVal(i.Remarks),
                        CGS = NumVal(i.CGS),
                        Last_Issue_Date = DateVal(i.Last_issue_date)
                    };
                }).ToList()
            };
        }

        [WebMethod]
        public static string GetGINLogs(int siId)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var logRows = (from l in db.Store_Issue_Logs
                                   join u in db.aspnet_Users on l.Loged_By equals u.UserId into userJoin
                                   from u in userJoin.DefaultIfEmpty()
                                   where l.Store_Issue_Id == siId
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

                    var si = db.Store_Issues.FirstOrDefault(x => x.Store_Issue_Id == siId);

                    object currentMaster = null;
                    object currentDetails = null;

                    if (si != null)
                    {
                        currentMaster = BuildGINMasterSnapshot(si, db);
                        currentDetails = BuildGINDetailSnapshot(db, si.Store_Issue_Id);
                    }

                    var approvalRows = (from a in db.Sys_Approval_Logs
                                        join st in db.Sys_Approval_Stage_Masters on a.Approval_Stage_ID equals st.Stage_ID into stageJoin
                                        from st in stageJoin.DefaultIfEmpty()
                                        join au in db.aspnet_Users on a.Approve_By equals au.UserId into apprJoin
                                        from au in apprJoin.DefaultIfEmpty()
                                        join ru in db.aspnet_Users on a.Rejected_By equals ru.UserId into rejJoin
                                        from ru in rejJoin.DefaultIfEmpty()
                                        where a.Entry_ID == siId && a.Form_ID == 6
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
    }
}