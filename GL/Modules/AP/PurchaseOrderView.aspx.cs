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