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

namespace PMS.Inventory
{
    public partial class PurchaseInvoiceView : System.Web.UI.Page
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
                var query = db.spGetAuditRecordAginstPurIvo(invoiceId).ToList<object>();
                
                return query;
            }
           
        }
        [WebMethod]
        public static object GetMasterAndDetail(int invoiceId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                // Master record
                var master = (from m in db.Purchase_Invoice_Masters
                              where m.PurchaseInvoiceId == invoiceId
                              select new
                              {
                                  m.PurchaseInvoiceId,
                                  m.InvoiceNum,
                                  m.CreatedDate,
                                  VendorName  = DBClass.getField("select Vendor_Name from AP_Vendors where Vendor_ID=" + m.VendorId),
                                  m.Status,
                                  m.Remarks
                              }).FirstOrDefault();

                // Detail rows
                var detail = (from d in db.Purchase_Invoice_Details
                              join inv in db.INV_Items on d.ItemId equals inv.Item_ID
                              where d.PurchaseInvoiceId == invoiceId
                              select new
                              {
                                  inv.Description,
                                  d.Qty,
                                  d.Rate,
                                  d.Amount,
                                  d.TotalAmount,
                                  d.DiscAmt,
                                  d.Stax_Amount,

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

                    var Total_Invoices = _dbContext.Purchase_Invoice_Masters.Count();
                    var Puchase_Invoices = from PIM in _dbContext.Purchase_Invoice_Masters
                                            join PID in _dbContext.Purchase_Invoice_Details on PIM.PurchaseInvoiceId equals PID.PurchaseInvoiceId
                                            where
                                            ((PIM.InvoiceNum.ToString().Contains(searchValue) || ((from gm in _dbContext.GRN_Masters where gm.GRN_ID == PID.GRN_ID select gm.GRN_Num).FirstOrDefault().ToString().Contains(searchValue) || (from gmm in _dbContext.Igp_masters where gmm.Igp_Id == (from gm in _dbContext.GRN_Masters where gm.GRN_ID == PID.GRN_ID select gm.IGP_Id).FirstOrDefault() select gmm.Igp_num).FirstOrDefault().ToString().Contains(searchValue))))
                                            group PIM by PIM.PurchaseInvoiceId into MasterGroup
                                            select new
                                            {
                                                VendorId = MasterGroup.FirstOrDefault().VendorId,
                                                PurchaseInvoiceId = MasterGroup.Key,
                                                InvoiceNum = MasterGroup.FirstOrDefault().InvoiceNum,
                                                VendorName = DBClass.getField("select Vendor_Name from AP_Vendors where Vendor_ID=" + MasterGroup.FirstOrDefault().VendorId),
                                                InvoiceDate = MasterGroup.FirstOrDefault().InvoiceDate,
                                                GrnNumber = (from gm in _dbContext.GRN_Masters where gm.GRN_ID == (from pid in _dbContext.Purchase_Invoice_Details  where pid.PurchaseInvoiceId == MasterGroup.Key
                                                                                 select pid.GRN_ID).FirstOrDefault() select gm.GRN_Num).FirstOrDefault(),
                                                IGPNumber = (from gmm in _dbContext.Igp_masters where gmm.Igp_Id == (from gm in _dbContext.GRN_Masters where gm.GRN_ID == (from pid in _dbContext.Purchase_Invoice_Details where pid.PurchaseInvoiceId == MasterGroup.Key select pid.GRN_ID).FirstOrDefault()
                                                                     select gm.IGP_Id).FirstOrDefault() select gmm.Igp_num).FirstOrDefault(),
                                                Remarks = MasterGroup.FirstOrDefault().Remarks,
                                                Status = MasterGroup.FirstOrDefault().Status,
                                                Amount = MasterGroup.FirstOrDefault().Total_Invoice_Amount,
                                                VoucherNo = (from gm in _dbContext.GL_Vouchers where gm.Voucher_ID == MasterGroup.FirstOrDefault().Voucher_ID
                                                             select gm.Voucher_No.ToString()).FirstOrDefault(),
                                            };

                    var FilteredCount = Puchase_Invoices.Count();
                    switch (sortColumn)
                    {
                        case "InvoiceNum":
                            Puchase_Invoices = sortColumnDirection == "asc" ? Puchase_Invoices.OrderBy(a => a.InvoiceNum) : Puchase_Invoices.OrderByDescending(a => a.InvoiceNum);
                            break;
                        case "GrnNumber":
                            Puchase_Invoices = sortColumnDirection == "asc" ? Puchase_Invoices.OrderBy(b => b.GrnNumber) : Puchase_Invoices.OrderByDescending(a => a.GrnNumber);
                            break;
                        default:
                            Puchase_Invoices = Puchase_Invoices.OrderByDescending(a => a.PurchaseInvoiceId);
                            break;
                    }

                    var PurchaseInvoiceList = Puchase_Invoices.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Invoices, data = PurchaseInvoiceList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Purchase Invoice list", ex);
            }
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "PurchaseInvoiceView";

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
                string pageName = "PurchaseInvoiceView";

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