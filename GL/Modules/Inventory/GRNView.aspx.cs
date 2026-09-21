using Infragistics.Documents.Reports.Report;
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

namespace PMS.Inventory
{
    public partial class GRNView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static bool isDeleteAllow()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            bool value = Convert.ToBoolean(DBClass.getField("select isnull(AllowPatientDelete,0) from aspnet_users where username='" + AppConfig.UserName + "'"));
            return value;
        }

        [WebMethod]
        public static List<object> GetAuditInfo(int invoiceId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.spGetAuditRecordAginstGRN(invoiceId).ToList<object>();
                return query;
            }
        }

        [WebMethod]
        public static object GetMasterAndDetail(int invoiceId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                // Master record - optimized without DBClass.getField
                var master = (from m in db.GRN_Masters
                              join v in db.AP_Vendors on m.VendorId equals v.Vendor_ID.ToString()
                              where m.GRN_ID == invoiceId
                              select new
                              {
                                  m.GRN_ID,
                                  m.GRN_Num,
                                  m.GRN_Date,
                                  VendorName = v.Vendor_Name,
                                  m.Status,
                                  m.Remarks
                              }).FirstOrDefault();

                // Detail rows
                var detail = (from d in db.GRN_Details
                              join inv in db.INV_Items on d.Item_Id equals inv.Item_ID
                              where d.GRNId == invoiceId
                              select new
                              {
                                  inv.Item_Code,
                                  inv.Description,
                                  d.GRNQty,
                                  d.Rate,
                                  d.Amount,
                              }).ToList();

                return new
                {
                    Master = master,
                    Detail = detail
                };
            }
        }

        [WebMethod]
        public static bool DeleteRecord(string GRNID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                var GRN_Id = (from itm in db.GRN_Masters
                              where (itm.GRN_ID == int.Parse(GRNID))
                              select itm.GRN_ID).FirstOrDefault();
                if (GRN_Id != 0)
                {
                    DBClass.exectueQuery("Update GRN_Master set Status='Cancelled',IsDeleted=1,Deleted_By='" + AppConfig.UserID + "',Deleted_Time=GetDate() where GRN_ID =" + GRN_Id, tranObj, con);
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
                    _dbContext.CommandTimeout = 180;

                    var Total_GRNS = _dbContext.GRN_Masters.Count();

                    // Optimized query following IGP structure
                    var GRNS = from GRN in _dbContext.GRN_Masters
                               join V in _dbContext.AP_Vendors on GRN.VendorId equals V.Vendor_ID.ToString()
                               where (GRN.GRN_Num.ToString().Contains(searchValue) ||
                                      V.Vendor_Name.ToString().Contains(searchValue) ||
                                      GRN.Status.ToString().Contains(searchValue) ||
                                      GRN.Remarks.ToString().Contains(searchValue))
                               select new
                               {
                                   GRN_ID = GRN.GRN_ID,
                                   GRN_Num = GRN.GRN_Num,
                                   Vendor_Name = V.Vendor_Name,
                                   Remarks = GRN.Remarks,
                                   Status = GRN.Status,
                                   Approved_Date = GRN.Approved_Date,
                                   Creation_Date = GRN.Creation_Date,
                                   Update_Date = GRN.Update_Date,
                                   CreatedBy = _dbContext.aspnet_Users.Where(x => x.UserId == GRN.Created_By).Select(x => x.UserName).FirstOrDefault(),
                                   Ware_House = _dbContext.GetDataValueName("Ware House", GRN.InvOrgId),
                                   Updated_By = _dbContext.aspnet_Users.Where(x => x.UserId == GRN.Updated_By).Select(x => x.UserName).FirstOrDefault(),
                                   // These fields are kept for compatibility but not displayed
                                   po_Number = "",
                                   Igp_Number = ""
                               };

                    var FilteredCount = GRNS.Count();

                    switch (sortColumn)
                    {
                        case "GRN_Num":
                            GRNS = sortColumnDirection == "asc" ? GRNS.OrderBy(a => a.GRN_Num) : GRNS.OrderByDescending(a => a.GRN_Num);
                            break;
                        case "Vendor_Name":
                            GRNS = sortColumnDirection == "asc" ? GRNS.OrderBy(a => a.Vendor_Name) : GRNS.OrderByDescending(a => a.Vendor_Name);
                            break;
                        case "Status":
                            GRNS = sortColumnDirection == "asc" ? GRNS.OrderBy(a => a.Status) : GRNS.OrderByDescending(a => a.Status);
                            break;
                        case "CreatedBy":
                            GRNS = sortColumnDirection == "asc" ? GRNS.OrderBy(a => a.CreatedBy) : GRNS.OrderByDescending(a => a.CreatedBy);
                            break;
                        default:
                            GRNS = GRNS.OrderByDescending(a => a.GRN_ID);
                            break;
                    }

                    var GRNLIST = GRNS.Skip(start).Take(length).ToList();
                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_GRNS, data = GRNLIST };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching GRN list", ex);
            }
        }

        // ================= GRN CHANGE HISTORY (GRN_Logs) =================

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

        private static object BuildGRNMasterSnapshot(GRN_Master grn, DataBaseDataContext dbc)
        {
            string vendorName = "";
            int vendorId;
            if (int.TryParse(grn.VendorId, out vendorId))
            {
                var vn = (from v in dbc.AP_Vendors where v.Vendor_ID == vendorId select v.Vendor_Name).FirstOrDefault();
                if (vn != null) vendorName = vn;
            }

            string warehouseName = "";
            if (!string.IsNullOrEmpty(grn.InvOrgId))
            {
                try { warehouseName = dbc.GetDataValueName("Ware House", grn.InvOrgId) ?? ""; }
                catch { warehouseName = ""; }
            }

            var snap = new Dictionary<string, string>();
            snap["Grn_No"] = StrVal(grn.GRN_Num);
            snap["Grn_Date"] = DateVal(grn.GRN_Date);
            snap["Vendor_Name"] = vendorName;
            snap["Warehouse"] = warehouseName;
            snap["Project"] = StrVal(grn.Project);
            snap["Remarks"] = StrVal(grn.Remarks);
            snap["Status"] = StrVal(grn.Status);
            snap["Is_Direct"] = grn.is_Direct.HasValue && grn.is_Direct.Value ? "Yes" : "No";
            return snap;
        }

        private static object BuildGRNDetailSnapshot(DataBaseDataContext dbc, int grnId)
        {
            var rows = dbc.GRN_Details.Where(t => t.GRNId == grnId).ToList();

            var ids = rows.Where(r => r.Item_Id.HasValue).Select(r => r.Item_Id.Value).Distinct().ToList();
            var itemNames = new Dictionary<int, string>();
            foreach (var id in ids)
            {
                var desc = dbc.INV_Items.Where(x => x.Item_ID == id).Select(x => x.Description).FirstOrDefault();
                itemNames[id] = desc ?? "";
            }

            return new
            {
                Items = rows.Select(i =>
                {
                    string name = "";
                    if (i.Item_Id.HasValue && itemNames.ContainsKey(i.Item_Id.Value))
                        name = itemNames[i.Item_Id.Value];

                    return new
                    {
                        Item_Name = name,
                        Item_Code = StrVal(i.ItemCode),
                        IGPDetailId = i.IGPDetailId.HasValue ? i.IGPDetailId.Value.ToString() : "",
                        GRNQty = NumVal(i.GRNQty),
                        UOM_Qty = NumVal(i.UOM_Qty),
                        Rate = NumVal(i.Rate),
                        Amount = NumVal(i.Amount),
                        Sale_Rate = NumVal(i.Sale_Rate),
                        BatchNum = StrVal(i.BatchNum),
                        BounusQty = NumVal(i.BounusQty),
                        MfgDate = DateVal(i.MfgDate),
                        ExpiryDate = DateVal(i.ExpiryDate)
                    };
                }).ToList()
            };
        }

        [WebMethod]
        public static string GetGRNLogs(int grnId)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var logRows = (from l in db.GRN_Logs
                                   join u in db.aspnet_Users on l.Loged_By equals u.UserId into userJoin
                                   from u in userJoin.DefaultIfEmpty()
                                   where l.Grn_Id == grnId
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

                    var grn = db.GRN_Masters.FirstOrDefault(x => x.GRN_ID == grnId);

                    object currentMaster = null;
                    object currentDetails = null;

                    if (grn != null)
                    {
                        currentMaster = BuildGRNMasterSnapshot(grn, db);
                        currentDetails = BuildGRNDetailSnapshot(db, Convert.ToInt32(grn.GRN_ID));
                    }

                    var approvalRows = (from a in db.Sys_Approval_Logs
                                        join st in db.Sys_Approval_Stage_Masters on a.Approval_Stage_ID equals st.Stage_ID into stageJoin
                                        from st in stageJoin.DefaultIfEmpty()
                                        join au in db.aspnet_Users on a.Approve_By equals au.UserId into apprJoin
                                        from au in apprJoin.DefaultIfEmpty()
                                        join ru in db.aspnet_Users on a.Rejected_By equals ru.UserId into rejJoin
                                        from ru in rejJoin.DefaultIfEmpty()
                                        where a.Entry_ID == grnId && a.From_Name == "GRN"
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
                string pageName = "GRNView";

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
                string pageName = "GRNView";

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