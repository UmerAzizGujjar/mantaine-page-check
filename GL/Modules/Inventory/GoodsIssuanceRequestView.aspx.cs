using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Web.Script.Services;
using Telerik.Web;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

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
                                            Closing_Remarks = MIR.Closing_Remarks,
                                            Status = MIR.Status,
                                            CreatedBY = _dbContext.aspnet_Users.Where(x => x.UserId == MIR.Created_By).Select(x => x.UserName).FirstOrDefault(),
                                            Creation_Date = MIR.Creation_Date,
                                            Approved_Time = MIR.Approved_Time,
                                            isClosed = MIR.Is_Closed_GIR,
                                            bln_Qty = (
    from mid in _dbContext.MaterialIssueRequest_Details
    where mid.MaterialRequest_Id == MIR.MaterialRequest_Id
    select (decimal?)(
        (mid.MIRQty ?? 0) -
        (
            (from sid in _dbContext.Store_Issue_Details
             where sid.MIR_Detail_Id == mid.MaterialRequestDetail_Id
             select (decimal?)sid.Issue_Qty).Sum() ?? 0
        )
    )
).Sum() ?? 0,
                                            TotalIssuedQty = (
    from mid in _dbContext.MaterialIssueRequest_Details
    where mid.MaterialRequest_Id == MIR.MaterialRequest_Id
    select (decimal?)(
        (from sid in _dbContext.Store_Issue_Details
         where sid.MIR_Detail_Id == mid.MaterialRequestDetail_Id
         select (decimal?)sid.Issue_Qty).Sum() ?? 0
    )
).Sum() ?? 0,
                                            ReViewRecommended = string.Join(",",
                                                                     (from sa in _dbContext.Sys_Approval_Logs
                                                                      join sasm in _dbContext.Sys_Approval_Stage_Masters
                                                                          on sa.Approval_Stage_ID equals sasm.Stage_ID
                                                                      where sa.Form_ID == 5
                                                                         && sa.Entry_ID == MIR.MaterialRequest_Id
                                                                       //  && sasm.Stage_Name == "Accounts Department(PO)"
                                                                      select _dbContext.aspnet_Users.Where(x => x.UserId == sa.Approve_By).Select(x => x.UserName).FirstOrDefault())
                                                                     .ToArray()),


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

        // ================= GIR CHANGE HISTORY (GIR_Logs) =================

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

        private static object BuildGIRMasterSnapshot(MaterialIssueRequest gir, DataBaseDataContext dbc)
        {
            string deptName = "";
            if (!string.IsNullOrEmpty(gir.Department))
            {
                try { deptName = dbc.GetDataValueName("Department", gir.Department) ?? ""; }
                catch { deptName = ""; }
            }

            string warehouseName = "";
            if (!string.IsNullOrEmpty(gir.InventoryOrganization))
            {
                try { warehouseName = dbc.GetDataValueName("Ware House", gir.InventoryOrganization) ?? ""; }
                catch { warehouseName = ""; }
            }

            var snap = new Dictionary<string, string>();
            snap["Gir_No"] = StrVal(gir.Request_No);
            snap["Gir_Date"] = DateVal(gir.MIRDate);
            snap["Priority"] = gir.Priority == "1" ? "High" : "Low";
            snap["Department"] = deptName;
            snap["Warehouse"] = warehouseName;
            snap["Remarks"] = StrVal(gir.Remarks);
            snap["Status"] = StrVal(gir.Status);
            snap["Closing_Remarks"] = StrVal(gir.Closing_Remarks);
            snap["Is_Closed"] = gir.Is_Closed_GIR.HasValue && gir.Is_Closed_GIR.Value ? "Yes" : "No";
            return snap;
        }

        private static object BuildGIRDetailSnapshot(DataBaseDataContext dbc, long girId)
        {
            var rows = dbc.MaterialIssueRequest_Details.Where(t => t.MaterialRequest_Id == girId).ToList();

            var ids = rows.Where(r => r.Item_Id.HasValue).Select(r => (int)r.Item_Id.Value).Distinct().ToList();
            var itemNames = new Dictionary<int, string>();
            var itemCodes = new Dictionary<int, string>();
            foreach (var id in ids)
            {
                var itm = dbc.INV_Items.Where(x => x.Item_ID == id)
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
                        MIRQty = NumVal(i.MIRQty),
                        Last_MIR_Qty = NumVal(i.Last_MIR_Qty),
                        Last_SIN_Qty = NumVal(i.Last_SIN_Qty),
                        Remarks = StrVal(i.Remarks),
                        Last_GIR_Date = DateVal(i.Last_GIR_Date)
                    };
                }).ToList()
            };
        }

        [WebMethod]
        public static string GetGIRLogs(long girId)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var logRows = (from l in db.GIR_Logs
                                   join u in db.aspnet_Users on l.Loged_By equals u.UserId into userJoin
                                   from u in userJoin.DefaultIfEmpty()
                                   where l.Gir_Id == girId
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

                    var gir = db.MaterialIssueRequests.FirstOrDefault(x => x.MaterialRequest_Id == girId);

                    object currentMaster = null;
                    object currentDetails = null;

                    if (gir != null)
                    {
                        currentMaster = BuildGIRMasterSnapshot(gir, db);
                        currentDetails = BuildGIRDetailSnapshot(db, gir.MaterialRequest_Id);
                    }

                    var approvalRows = (from a in db.Sys_Approval_Logs
                                        join st in db.Sys_Approval_Stage_Masters on a.Approval_Stage_ID equals st.Stage_ID into stageJoin
                                        from st in stageJoin.DefaultIfEmpty()
                                        join au in db.aspnet_Users on a.Approve_By equals au.UserId into apprJoin
                                        from au in apprJoin.DefaultIfEmpty()
                                        join ru in db.aspnet_Users on a.Rejected_By equals ru.UserId into rejJoin
                                        from ru in rejJoin.DefaultIfEmpty()
                                        where a.Entry_ID == girId && a.Form_ID == 5
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
                string pageName = "GoodsIssuanceRequestview";

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
                string pageName = "GoodsIssuanceRequestview";

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

        [WebMethod]
        public static object GetMasterAndDetail(int invoiceId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var master = (from m in db.MaterialIssueRequests
                              where m.MaterialRequest_Id == invoiceId
                              select new
                              {
                                  m.Request_No,
                                  m.MIRDate,
                                  m.Priority,
                                  Department = db.GetDataValueName("Department", m.Department),
                                  m.Status,
                                  m.Remarks,
                                  m.Closing_Remarks,
                                  CreatedBy = db.aspnet_Users.Where(x => x.UserId == m.Created_By).Select(x => x.UserName).FirstOrDefault(),
                                  m.Approved_Time
                              }).FirstOrDefault();

                var detail = (from d in db.MaterialIssueRequest_Details
                              join inv in db.INV_Items on d.Item_Id equals inv.Item_ID
                              where d.MaterialRequest_Id == invoiceId
                              select new
                              {
                                  inv.Item_Code,
                                  inv.Description,
                                  d.MIRQty,
                                  IssuedQty = db.Store_Issue_Details.Where(s => s.MIR_Detail_Id == d.MaterialRequestDetail_Id).Sum(s => (decimal?)s.Issue_Qty) ?? 0,
                                  Balance = d.MIRQty - (db.Store_Issue_Details.Where(s => s.MIR_Detail_Id == d.MaterialRequestDetail_Id).Sum(s => (decimal?)s.Issue_Qty) ?? 0)
                              }).ToList();

                return new
                {
                    Master = master,
                    Detail = detail
                };
            }
        }

        [WebMethod]
        public static List<object> GetAuditInfo(int invoiceId)
        {
            var result = new List<object>();

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                // GIN
                var ginList = (from sid in db.Store_Issue_Details
                               join si in db.Store_Issues on sid.Store_Issue_Id equals si.Store_Issue_Id
                               where sid.MIR_Id == (int)invoiceId
                               select new
                               {
                                   T_Type = "GIN",
                                   ID = si.Store_Issue_Id,
                                   NUmber = si.Store_Issue_No,
                                   Dates = si.Created_Time,
                                   Status = si.Status
                               }).Distinct().ToList<object>();
                result.AddRange(ginList);

                // PR
                var prList = (from pr in db.Purchase_Requisitions
                               where pr.MaterialRequest_Id == invoiceId
                               select new
                               {
                                   T_Type = "PR",
                                   ID = pr.PR_Id,
                                   NUmber = pr.PR_Num,
                                   Dates = pr.PR_Date,
                                   Status = pr.Status
                               }).Distinct().ToList<object>();
                result.AddRange(prList);

                // PO
                var poList = (from prd in db.Purchase_Requisition_Details
                               join poi in db.AP_Purchase_Order_Items on prd.PR_Detail_ID equals (long)poi.PRDetailId
                               join po in db.AP_Purchase_Orders on poi.PO_ID equals po.PO_ID
                               where prd.MaterialRequest_Id == invoiceId
                               select new
                               {
                                   T_Type = "PO",
                                   ID = po.PO_ID,
                                   NUmber = po.PO_No,
                                   Dates = po.PO_Date,
                                   Status = po.Status
                               }).Distinct().ToList<object>();
                result.AddRange(poList);

                // IGP
                var igpList = (from poi in db.AP_Purchase_Order_Items
                               join prd in db.Purchase_Requisition_Details on (long)poi.PRDetailId equals prd.PR_Detail_ID
                               join igd in db.Igp_Details on poi.PO_Item_ID equals igd.PO_Item_ID
                               join igm in db.Igp_masters on igd.Igp_Id equals igm.Igp_Id
                               where prd.MaterialRequest_Id == invoiceId
                               select new
                               {
                                   T_Type = "IGP",
                                   ID = igm.Igp_Id,
                                   NUmber = igm.Igp_num,
                                   Dates = igm.Igp_date,
                                   Status = igm.Status
                               }).Distinct().ToList<object>();
                result.AddRange(igpList);

                // GRN
                var grnList = (from igm in db.Igp_masters
                               join grn in db.GRN_Masters on (int)igm.Igp_Id equals grn.IGP_Id
                               join grnd in db.GRN_Details on grn.GRN_ID equals (int)grnd.GRNId
                               join poi in db.AP_Purchase_Order_Items on grnd.PO_Item_Id equals poi.PO_Item_ID
                               join prd in db.Purchase_Requisition_Details on (long)poi.PRDetailId equals prd.PR_Detail_ID
                               where prd.MaterialRequest_Id == invoiceId
                               select new
                               {
                                   T_Type = "GRN",
                                   ID = grn.GRN_ID,
                                   NUmber = grn.GRN_Num,
                                   Dates = grn.GRN_Date,
                                   Status = grn.Status
                               }).Distinct().ToList<object>();
                result.AddRange(grnList);

                // Purchase Invoice
                var piList = (from grnd in db.GRN_Details
                               join pid in db.Purchase_Invoice_Details on grnd.GRN_detail_Id equals pid.GRN_detail_Id
                               join pim in db.Purchase_Invoice_Masters on pid.PurchaseInvoiceId equals pim.PurchaseInvoiceId
                               join poi in db.AP_Purchase_Order_Items on grnd.PO_Item_Id equals poi.PO_Item_ID
                               join prd in db.Purchase_Requisition_Details on (long)poi.PRDetailId equals prd.PR_Detail_ID
                               where prd.MaterialRequest_Id == invoiceId
                               select new
                               {
                                   T_Type = "PUR Inv",
                                   ID = pim.PurchaseInvoiceId,
                                   NUmber = pim.InvoiceNum,
                                   Dates = pim.CreatedDate,
                                   Status = pim.Status
                               }).Distinct().ToList<object>();
                result.AddRange(piList);
            }

            return result;
        }

    }
}