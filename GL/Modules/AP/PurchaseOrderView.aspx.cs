using Infragistics.Documents.Reports.Report;
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
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Globalization;


namespace PMS
{
    public partial class PurchaseOrderView : System.Web.UI.Page
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
                var query = db.spGetAuditRecordAginstPO(invoiceId).ToList<object>();

                return query;
            }

        }
        [WebMethod]
        public static object GetMasterAndDetail(int invoiceId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                // Master record
                var master = (from m in db.AP_Purchase_Orders
                              where m.PO_ID == invoiceId
                              select new
                              {
                                  ID = m.PO_ID,
                                  Number = m.PO_No,
                                  Date = m.PO_Date,
                                  VendorName = DBClass.getField("select Vendor_Name from AP_Vendors where Vendor_ID=" + m.Vendor_ID),
                                  Status = m.Status,
                                  Remarks = m.Remarks
                              }).FirstOrDefault();

                // Detail rows
                var detail = (from d in db.AP_Purchase_Order_Items
                              join inv in db.INV_Items on d.Item_Id equals inv.Item_ID
                              where d.PO_ID == invoiceId
                              select new
                              {
                                  inv.Item_Code,
                                  inv.Description,
                                  d.Qty,
                                  d.Discount_Amount,
                                  d.Rate,
                                  d.Amount,
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

                    var Total_Order = _dbContext.AP_Purchase_Orders.Count();
                    var PurchaseOreder = from PO in _dbContext.AP_Purchase_Orders
                                         select new
                                         {
                                             POID = PO.PO_ID,
                                             PONo = PO.PO_No,
                                             Date = PO.PO_Date,
                                             RefNo = PO.Ref_No,
                                             Ware_House = _dbContext.GetDataValueName("Ware House", PO.Ware_House),
                                             VendorName = (from v in _dbContext.AP_Vendors where PO.Vendor_ID == v.Vendor_ID select v.Vendor_Name).FirstOrDefault() ?? "",
                                             PO_Amount = PO.PO_Amount,
                                             Status = PO.Status,
                                             CreatedBy = _dbContext.aspnet_Users.Where(x => x.UserId == PO.Created_By).Select(x => x.UserName).FirstOrDefault() ?? "",
                                             Approvedby = _dbContext.aspnet_Users.Where(x => x.UserId == PO.Approved_By).Select(x => x.UserName).FirstOrDefault() ?? "",
                                         };

                    // Apply search filter if searchValue is not empty
                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        PurchaseOreder = PurchaseOreder.Where(x =>
                            x.POID.ToString().Contains(searchValue) ||
                            x.PONo.ToString().Contains(searchValue) ||
                            (x.RefNo != null && x.RefNo.ToString().Contains(searchValue)) ||
                            (x.VendorName != null && x.VendorName.Contains(searchValue)) ||
                            x.Date.ToString().Contains(searchValue) ||
                            x.PO_Amount.ToString().Contains(searchValue) ||
                            (x.Ware_House != null && x.Ware_House.Contains(searchValue)) ||
                            x.Status.Contains(searchValue) ||
                            (x.CreatedBy != null && x.CreatedBy.Contains(searchValue)) ||
                            (x.Approvedby != null && x.Approvedby.Contains(searchValue))
                        );
                    }

                    var FilteredCount = PurchaseOreder.Count();

                    // Apply sorting
                    switch (sortColumn)
                    {
                        case "PONo":
                            PurchaseOreder = sortColumnDirection == "asc" ? PurchaseOreder.OrderBy(a => a.PONo) : PurchaseOreder.OrderByDescending(a => a.PONo);
                            break;
                        case "RefNo":
                            PurchaseOreder = sortColumnDirection == "asc" ? PurchaseOreder.OrderBy(b => b.RefNo) : PurchaseOreder.OrderByDescending(a => a.RefNo);
                            break;
              
                        case "Date":
                            PurchaseOreder = sortColumnDirection == "asc" ? PurchaseOreder.OrderBy(b => b.Date) : PurchaseOreder.OrderByDescending(a => a.Date);
                            break;
                        case "VendorName":
                            PurchaseOreder = sortColumnDirection == "asc" ? PurchaseOreder.OrderBy(a => a.VendorName) : PurchaseOreder.OrderByDescending(a => a.VendorName);
                            break;
                        case "Ware_House":
                            PurchaseOreder = sortColumnDirection == "asc" ? PurchaseOreder.OrderBy(a => a.Ware_House) : PurchaseOreder.OrderByDescending(a => a.Ware_House);
                            break;
                        case "CreatedBy":
                            PurchaseOreder = sortColumnDirection == "asc" ? PurchaseOreder.OrderBy(a => a.CreatedBy) : PurchaseOreder.OrderByDescending(a => a.CreatedBy);
                            break;
                        default:
                            PurchaseOreder = PurchaseOreder.OrderByDescending(a => a.PONo);
                            break;
                    }

                    var PurchaseList = PurchaseOreder.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Order, data = PurchaseList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Purchase Order list", ex);
            }
        }

        // ================= PO CHANGE HISTORY (AP_Purchase_Order_Logs) =================

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

        private static object BuildPOMasterSnapshot(AP_Purchase_Order po, DataBaseDataContext db)
        {
            string vendorName = "";
            if (po.Vendor_ID != null)
            {
                var vn = (from v in db.AP_Vendors where v.Vendor_ID == po.Vendor_ID select v.Vendor_Name).FirstOrDefault();
                if (vn != null) vendorName = vn;
            }

            string warehouseName = "";
            if (!string.IsNullOrEmpty(po.Ware_House))
            {
                try { warehouseName = db.GetDataValueName("Ware House", po.Ware_House) ?? ""; }
                catch { warehouseName = ""; }
            }

            var snap = new Dictionary<string, string>();
            snap["PO_No"] = po.PO_No.HasValue ? po.PO_No.Value.ToString() : "";
            snap["Ref_No"] = StrVal(po.Ref_No);
            snap["Vendor_Name"] = vendorName;
            snap["Ware_House"] = warehouseName;
            snap["PO_Date"] = DateVal(po.PO_Date);
            snap["Due_Date"] = DateVal(po.Due_Date);
            snap["Sub_Total"] = NumVal(po.Sub_Total);
            snap["Discount"] = NumVal(po.Discount);
            snap["Frieght_Charges"] = NumVal(po.Frieght_Charges);
            snap["Total_ST_Amount"] = NumVal(po.Total_ST_Amount);
            snap["Total_Adv_Amt"] = NumVal(po.Total_Adv_Amt);
            snap["Total_Further_Amt"] = NumVal(po.Total_Further_Amt);
            snap["PO_Amount"] = NumVal(po.PO_Amount);
            snap["PO_Type"] = StrVal(po.PO_Type);
            snap["Payment_Terms"] = StrVal(po.Payment_Terms);
            snap["Delivery_Terms"] = StrVal(po.Delivery_Terms);
            snap["Status"] = StrVal(po.Status);
            return snap;
        }

        private static object BuildPOItemsSnapshot(System.Collections.Generic.IEnumerable<AP_Purchase_Order_Item> rows)
        {
            return new
            {
                Items = rows.Select(i => new
                {
                    Item_Name = StrVal(i.Item_Name),
                    Item_Code = i.Item_Code.HasValue ? i.Item_Code.Value.ToString() : "",
                    PRDetailId = i.PRDetailId.HasValue ? i.PRDetailId.Value.ToString() : "",
                    Qty = NumVal(i.Qty),
                    UOM_Qty = NumVal(i.UOM_Qty),
                    Rate = NumVal(i.Rate),
                    Amount = NumVal(i.Amount),
                    Discount_Percentage = NumVal(i.Discount_Percentage),
                    Discount_Amount = NumVal(i.Discount_Amount),
                    SalTax_Amount = NumVal(i.SalTax_Amount),
                    AdvanceTax_Amount = NumVal(i.AdvanceTax_Amount),
                    FurtherTax_Amount = NumVal(i.FurtherTax_Amount),
                    Bonus_Tax = NumVal(i.Bonus_Tax),
                    Delivery_Date = DateVal(i.Delivery_Date),
                    Last_PO_Rate = NumVal(i.Last_PO_Rate)
                }).ToList()
            };
        }

        [WebMethod]
        public static string GetPOLogs(int poId)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var logRows = (from l in db.AP_Purchase_Order_Logs
                                   join u in db.aspnet_Users on l.Loged_By equals u.UserId into userJoin
                                   from u in userJoin.DefaultIfEmpty()
                                   where l.PO_Id == poId
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

                    var po = db.AP_Purchase_Orders.FirstOrDefault(p => p.PO_ID == poId);

                    object currentMaster = null;
                    object currentDetails = null;

                    if (po != null)
                    {
                        currentMaster = BuildPOMasterSnapshot(po, db);

                        var items = db.AP_Purchase_Order_Items
                                      .Where(i => i.PO_ID == po.PO_ID)
                                      .ToList();

                        currentDetails = BuildPOItemsSnapshot(items);
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
                string pageName = "PurchaseOrderView";

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
                string pageName = "PurchaseOrderView";

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