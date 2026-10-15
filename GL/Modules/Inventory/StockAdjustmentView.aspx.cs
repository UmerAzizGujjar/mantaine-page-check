using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI.WebControls;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace PMS.Inventory
{
    public partial class StockAdjustmentView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }
        // GL voucher posted for this stock adjustment (INV_Stock_Adjustment.Voucher_ID): status and GL lines, for the voucher modal
        [WebMethod]
        public static string GetADJVoucherDetail(int recordId)
        {
            return VoucherDetail.GetJsonForRecord("SELECT Voucher_ID FROM INV_Stock_Adjustment WHERE Adjustment_ID = @Id", recordId);
        }

        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Stock_Adjustments = _dbContext.INV_Stock_Adjustments.Count();
                    var StoreAdjustment = from ISA in _dbContext.INV_Stock_Adjustments
                                          join item in _dbContext.INV_Items
                                          on Convert.ToInt32(ISA.Item_Id) equals item.Item_ID
                                          where (ISA.Item_Code.ToString().Contains(searchValue) || item.Description.Contains(searchValue) || ISA.Adjustment_No.ToString().Contains(searchValue)) 
                                          && (ISA.IsDeleted == false || ISA.IsDeleted == null)
                                          select new
                                          {
                                          Adjustment_Id = ISA.Adjustment_ID,
                                          Adjustment_No = ISA.Adjustment_No,
                                          AdjustmentDates = ISA.Adjustment_Date,
                                          ItemCode = ISA.Item_Code,
                                          ItemDescription = item.Description,
Rate = ISA.Rate,
                                           Qty = ISA.Qty,
                                           Total_Amount = ISA.Amount,
                                          warehouse = _dbContext.GetDataValueName("Ware House", ISA.Ware_House),
                                          //Voucher_No = DBClass.getField("select Voucher_No from GL_Vouchers where Voucher_ID =" + ISA.Voucher_ID),
                                          Status = ISA.Status,
                                          Created_By = _dbContext.aspnet_Users.Where(u => u.UserId == ISA.Created_By).Select(u => u.UserName).FirstOrDefault() ?? "",
                                          Creation_Time = ISA.Creation_Time,
                                          Updated_By = _dbContext.aspnet_Users.Where(u => u.UserId == ISA.Updated_By).Select(u => u.UserName).FirstOrDefault() ?? "",
                                          Update_Time = ISA.Update_Time

                                          };

                    var FilteredCount = StoreAdjustment.Count();
                    switch (sortColumn)
                    {
                        case "Adjustment_No":
                            StoreAdjustment = sortColumnDirection == "asc" ? StoreAdjustment.OrderBy(a => a.Adjustment_No) : StoreAdjustment.OrderByDescending(a => a.Adjustment_No);
                            break;
                        case "ItemCode":
                            StoreAdjustment = sortColumnDirection == "asc" ? StoreAdjustment.OrderBy(b => b.ItemCode) : StoreAdjustment.OrderByDescending(a => a.ItemCode);
                            break;
                        default:
                            StoreAdjustment = StoreAdjustment.OrderByDescending(a => a.Adjustment_Id);
                            break;
                    }

                    var StoreAdjustmentList = StoreAdjustment.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Stock_Adjustments, data = StoreAdjustmentList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Store Adjustment Issue list", ex);
            }
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "StockAdjustmentview";

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
                string pageName = "StockAdjustmentview";

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

        // ================= STOCK ADJUSTMENT CHANGE HISTORY (INV_Stock_Adjustment_Logs) =================

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

        private static object BuildStockAdjMasterSnapshot(INV_Stock_Adjustment adj, DataBaseDataContext db)
        {
            string warehouseName = "";
            if (!string.IsNullOrEmpty(adj.Ware_House))
            {
                try { warehouseName = db.GetDataValueName("Ware House", adj.Ware_House) ?? ""; }
                catch { warehouseName = ""; }
            }

            string reasonName = "";
            if (!string.IsNullOrEmpty(adj.Reason_Why))
            {
                try { reasonName = db.GetDataValueName("Reason Needed", adj.Reason_Why) ?? ""; }
                catch { reasonName = ""; }
            }

            var snap = new Dictionary<string, string>();
            snap["Adjustment_No"] = adj.Adjustment_No.HasValue ? adj.Adjustment_No.Value.ToString() : "";
            snap["Adjustment_Date"] = DateVal(adj.Adjustment_Date);
            snap["Ware_House"] = warehouseName;
            snap["Status"] = StrVal(adj.Status);
            snap["Reason_Why"] = reasonName;
            snap["Batch_No"] = StrVal(adj.Batch_No);
            snap["Expire_Date"] = DateVal(adj.Expire_Date);
            snap["Remarks"] = StrVal(adj.Remarks);
            snap["Update_Time"] = DateVal(adj.Update_Time);
            return snap;
        }

        private static object BuildStockAdjDetailSnapshot(DataBaseDataContext db, INV_Stock_Adjustment adj)
        {
            string itemName = "";
            if (!string.IsNullOrEmpty(adj.Item_Id))
            {
                int itemId;
                if (int.TryParse(adj.Item_Id, out itemId))
                {
                    var itm = db.INV_Items.Where(x => x.Item_ID == itemId)
                                           .Select(x => new { x.Description })
                                           .FirstOrDefault();
                    if (itm != null) itemName = itm.Description ?? "";
                }
            }

            var items = new List<object>();
            items.Add(new
            {
                Item_Code = StrVal(adj.Item_Code),
                Item_Name = itemName,
                Qty = NumVal(adj.Qty),
                Rate = NumVal(adj.Rate),
                Amount = NumVal(adj.Amount)
            });

            return new { Items = items };
        }

        [WebMethod]
        public static string GetSTOCKADJLogs(int adjId)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var logRows = (from l in db.INV_Stock_Adjustment_Logs
                                   join u in db.aspnet_Users on l.Loged_By equals u.UserId into userJoin
                                   from u in userJoin.DefaultIfEmpty()
                                   where l.Adjustment_Id == adjId
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

                    var adj = db.INV_Stock_Adjustments.FirstOrDefault(x => x.Adjustment_ID == adjId);

                    object currentMaster = null;
                    object currentDetails = null;

                    if (adj != null)
                    {
                        currentMaster = BuildStockAdjMasterSnapshot(adj, db);
                        currentDetails = BuildStockAdjDetailSnapshot(db, adj);
                    }

                    var approvalRows = (from a in db.Sys_Approval_Logs
                                        join st in db.Sys_Approval_Stage_Masters on a.Approval_Stage_ID equals st.Stage_ID into stageJoin
                                        from st in stageJoin.DefaultIfEmpty()
                                        join au in db.aspnet_Users on a.Approve_By equals au.UserId into apprJoin
                                        from au in apprJoin.DefaultIfEmpty()
                                        join ru in db.aspnet_Users on a.Rejected_By equals ru.UserId into rejJoin
                                        from ru in rejJoin.DefaultIfEmpty()
                                        where a.Entry_ID == adjId && a.Form_ID == 3
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