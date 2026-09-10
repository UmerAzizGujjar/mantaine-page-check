using Infragistics.Documents.Reports.Report;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Globalization;

namespace PMS.Inventory
{
    public partial class InversionGatePassView : System.Web.UI.Page
    {
        public static object VendorName { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static List<object> GetAuditInfo(int invoiceId)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.spGetAuditRecordAginstIGP(invoiceId).ToList<object>();

                return query;
            }

        }
        [WebMethod]
        public static object GetMasterAndDetail(int invoiceId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                // Master record
                var master = (from m in db.Igp_masters
                              where m.Igp_Id == invoiceId
                              select new
                              {
                                 ID= m.Igp_Id,
                                 Number = m.Igp_num,
                                 Date = m.Igp_date,
                                 VendorName = DBClass.getField("select Vendor_Name from AP_Vendors where Vendor_ID=" + m.Vendor),
                                 Status = m.Status,
                                 Remarks = m.Remarks
                              }).FirstOrDefault();

                // Detail rows
                var detail = (from d in db.Igp_Details
                              join inv in db.INV_Items on d.Item_Id equals inv.Item_ID
                              where d.Igp_Id == invoiceId
                              select new
                              {
                                  inv.Item_Code,
                                  inv.Description,
                                  d.POQty,
                                  d.InspecQty,
                                  d.IGPQty,
                                  d.BlncQty,
                                  // d.BounusQty

                              }).ToList();

                return new
                {
                    Master = master,
                    Detail = detail
                };
            }
        }
        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_IGP = _dbContext.Igp_masters.Count();
                    var IGP = from Igp in _dbContext.Igp_masters
                              join V in _dbContext.AP_Vendors on Convert.ToInt32(Igp.Vendor) equals V.Vendor_ID
                              select new
                              {
                                  Igp_Id = Igp.Igp_Id,
                                  Igp_num = Igp.Igp_num,
                                  VendorName = V.Vendor_Name,
                                  PONum = "", // Empty string since not needed
                                  BilityNum = Igp.BilityNum,
                                  Remarks = Igp.Remarks,
                                  VehicleNum = Igp.VehicleNum,
                                  Creation_Date = Igp.Creation_Date,
                                  Ware_House = _dbContext.GetDataValueName("Ware House", Igp.InvOrgId),
                                  Update_Date = Igp.Update_Date,
                                  CreatedBy = _dbContext.aspnet_Users.Where(x => x.UserId == Igp.Created_By).Select(x => x.UserName).FirstOrDefault() ?? "",
                                  Updated_By = _dbContext.aspnet_Users.Where(x => x.UserId == Igp.Updated_By).Select(x => x.UserName).FirstOrDefault() ?? "",
                                  Status = Igp.Status,
                                  Inspec_Status = Igp.Inspec_Status,
                                  InvType = Igp.InvType,
                                  Igp_date = Igp.Igp_date,
                                  IsAuto = DBClass.getField("Select isnull(IsAutoGenerate,0) from GRN_Master where IGP_Id =" + Igp.Igp_Id),
                                  Grn_ID = DBClass.getField("select GRN_ID from GRN_Master where IGP_Id=" + Igp.Igp_Id)
                              };

                    // Apply search filter if searchValue is not empty
                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        IGP = IGP.Where(x =>
                            x.Igp_num.ToString().Contains(searchValue) ||
                            (x.VendorName != null && x.VendorName.Contains(searchValue)) ||
                            (x.BilityNum != null && x.BilityNum.ToString().Contains(searchValue)) ||
                            (x.Remarks != null && x.Remarks.Contains(searchValue)) ||
                            (x.VehicleNum != null && x.VehicleNum.ToString().Contains(searchValue)) ||
                            x.Status.Contains(searchValue) ||
                            (x.Inspec_Status != null && x.Inspec_Status.Contains(searchValue)) ||
                            (x.InvType != null && x.InvType.Contains(searchValue)) ||
                            (x.CreatedBy != null && x.CreatedBy.Contains(searchValue))
                        );
                    }

                    var FilteredCount = IGP.Count();

                    // Apply sorting
                    switch (sortColumn)
                    {
                        case "Igp_num":
                            IGP = sortColumnDirection == "asc" ? IGP.OrderBy(a => a.Igp_num) : IGP.OrderByDescending(a => a.Igp_num);
                            break;
                        case "VendorName":
                            IGP = sortColumnDirection == "asc" ? IGP.OrderBy(a => a.VendorName) : IGP.OrderByDescending(a => a.VendorName);
                            break;
                        case "CreatedBy":
                            IGP = sortColumnDirection == "asc" ? IGP.OrderBy(a => a.CreatedBy) : IGP.OrderByDescending(a => a.CreatedBy);
                            break;
                        case "Igp_date":
                            IGP = sortColumnDirection == "asc" ? IGP.OrderBy(a => a.Igp_date) : IGP.OrderByDescending(a => a.Igp_date);
                            break;
                       
                        default:
                            IGP = IGP.OrderByDescending(a => a.Igp_Id);
                            break;
                    }

                    var IGPList = IGP.Skip(start).Take(length).ToList();
                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_IGP, data = IGPList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Inversion Gate Pass list", ex);
            }
        }



        [WebMethod]
        public static bool DeleteRecord(string IGPID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                var user_id = AppConfig.UserID;
                var Igp_Id = (from itm in db.Igp_masters
                              where (itm.Igp_Id == int.Parse(IGPID))
                              select itm.Igp_Id).FirstOrDefault();
                if (Igp_Id != 0)
                {
                    DBClass.exectueQuery("Update Igp_master set IsDeleted=0,DeletedBy='" + user_id + "',Deleted_Time=GetDate() where Igp_Id =" + Igp_Id, tranObj, con);
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
        public static string AutoGRN(string IgpId)
        {
            var user_id = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_AutoGRN(Convert.ToInt32(IgpId), user_id);
            return (new JavaScriptSerializer()).Serialize(Details);
        }

        // ================= IGP CHANGE HISTORY (IGP_Logs) =================

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

        private static object BuildIGPMasterSnapshot(Igp_master igp, DataBaseDataContext dbc)
        {
            string vendorName = "";
            int vendorId;
            if (int.TryParse(igp.Vendor, out vendorId))
            {
                var vn = (from v in dbc.AP_Vendors where v.Vendor_ID == vendorId select v.Vendor_Name).FirstOrDefault();
                if (vn != null) vendorName = vn;
            }

            string warehouseName = "";
            if (!string.IsNullOrEmpty(igp.InvOrgId))
            {
                try { warehouseName = dbc.GetDataValueName("Ware House", igp.InvOrgId) ?? ""; }
                catch { warehouseName = ""; }
            }

            var snap = new Dictionary<string, string>();
            snap["Igp_No"] = StrVal(igp.Igp_num);
            snap["Igp_Date"] = DateVal(igp.Igp_date);
            snap["Vendor_Name"] = vendorName;
            snap["Warehouse"] = warehouseName;
            snap["DriverName"] = StrVal(igp.DriverName);
            snap["VehicleNum"] = StrVal(igp.VehicleNum);
            snap["BilityNum"] = StrVal(igp.BilityNum);
            snap["Remarks"] = StrVal(igp.Remarks);
            snap["Status"] = StrVal(igp.Status);
            snap["Inspec_Status"] = StrVal(igp.Inspec_Status);
            return snap;
        }

        private static object BuildIGPItemsSnapshot(DataBaseDataContext dbc, int igpId)
        {
            var rows = dbc.Igp_Details.Where(t => t.Igp_Id == igpId).ToList();

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
                        Item_Code = i.Item_Code.HasValue ? i.Item_Code.Value.ToString() : "",
                        PO_Item_ID = i.PO_Item_ID.HasValue ? i.PO_Item_ID.Value.ToString() : "",
                        IGPQty = NumVal(i.IGPQty),
                        POQty = NumVal(i.POQty),
                        RcvQty = NumVal(i.RcvQty),
                        BlncQty = NumVal(i.BlncQty),
                        BounusQty = NumVal(i.BounusQty),
                        InspecQty = NumVal(i.InspecQty),
                        BatchNum = StrVal(i.BatchNum),
                        MfgDate = DateVal(i.MfgDate),
                        ExpiryDate = DateVal(i.ExpiryDate),
                        Sale_Rate = NumVal(i.Sale_Rate),
                        UOM_Qty = NumVal(i.UOM_Qty)
                    };
                }).ToList()
            };
        }

        [WebMethod]
        public static string GetIGPLogs(int igpId)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var logRows = (from l in db.IGP_Logs
                                   join u in db.aspnet_Users on l.Loged_By equals u.UserId into userJoin
                                   from u in userJoin.DefaultIfEmpty()
                                   where l.Igp_Id == igpId
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

                    var igp = db.Igp_masters.FirstOrDefault(x => x.Igp_Id == igpId);

                    object currentMaster = null;
                    object currentDetails = null;

                    if (igp != null)
                    {
                        currentMaster = BuildIGPMasterSnapshot(igp, db);
                        currentDetails = BuildIGPItemsSnapshot(db, Convert.ToInt32(igp.Igp_Id));
                    }

                    return JsonConvert.SerializeObject(new
                    {
                        logs = logs,
                        current = new { master = currentMaster, details = currentDetails }
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
                string pageName = "InversionGatepassView";

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
                string pageName = "InversionGatepassView";

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