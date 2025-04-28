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
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();
                 
                    var Total_Order = _dbContext.AP_Purchase_Orders.Count();
                    var PurchaseOreder = from PO in _dbContext.AP_Purchase_Orders
                                   where
                                       ((PO.PO_ID.ToString().Contains(searchValue) || PO.PO_No.ToString().Contains(searchValue) || PO.Ref_No.ToString().Contains(searchValue) || (from v in _dbContext.AP_Vendors where PO.Vendor_ID == v.Vendor_ID select new { vendor = v.Vendor_Name }).FirstOrDefault().vendor.ToString().Contains(searchValue) || PO.PO_Amount.ToString().Contains(searchValue) || PO.Status.ToString().Contains(searchValue)))
                                   select new
                                   {
                                       POID = PO.PO_ID,
                                       PONo = PO.PO_No,
                                       Date = PO.PO_Date,
                                       RefNo = PO.Ref_No,
                                       VendorName = (from v in _dbContext.AP_Vendors where PO.Vendor_ID == v.Vendor_ID select new { vendor = v.Vendor_Name }).FirstOrDefault().vendor.ToString(),
                                       PO_Amount = PO.PO_Amount,
                                       Status = PO.Status,
                                      
                                   };

                    var FilteredCount = PurchaseOreder.Count();
                    switch (sortColumn)
                    {
                        case "PONo":
                            PurchaseOreder = sortColumnDirection == "asc" ? PurchaseOreder.OrderBy(a => a.PONo) : PurchaseOreder.OrderByDescending(a => a.PONo);
                            break;
                        case "Date":
                            PurchaseOreder = sortColumnDirection == "asc" ? PurchaseOreder.OrderBy(b => b.Date) : PurchaseOreder.OrderByDescending(a => a.Date);
                            break;
                        case "RefNo":
                            PurchaseOreder = sortColumnDirection == "asc" ? PurchaseOreder.OrderBy(b => b.RefNo) : PurchaseOreder.OrderByDescending(a => a.RefNo);
                            break;                       
                        case "PO_Amount":
                            PurchaseOreder = sortColumnDirection == "asc" ? PurchaseOreder.OrderBy(b => b.PO_Amount) : PurchaseOreder.OrderByDescending(a => a.PO_Amount);
                            break;
                        case "Status":
                            PurchaseOreder = sortColumnDirection == "asc" ? PurchaseOreder.OrderBy(b => b.Status) : PurchaseOreder.OrderByDescending(a => a.Status);
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
    }
}