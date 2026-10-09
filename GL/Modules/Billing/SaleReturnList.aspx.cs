using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Billing
{
    public partial class SaleReturnList : System.Web.UI.Page
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
                    var Total_returns = _dbContext.Pharmacy_SaleReturns.Count();
                    var SaleReturn = from PS in _dbContext.Pharmacy_SaleReturns
                                     join PSD in _dbContext.Pharmacy_SaleReturn_Details on PS.Return_ID equals PSD.Return_ID
                                     join u in _dbContext.aspnet_Users on PS.Created_By equals u.UserId
                                     where (PS.IsDeleted == false &&
                                            ((PS.Seq_InvoiceNo.ToString().Contains(searchValue) || u.UserName.ToString().Contains(searchValue) || PS.Total_Amount.ToString().Contains(searchValue))))
                                     select new
                                     {
                                         Return_ID = PS.Return_ID,
                                         Seq_InvoiceNo = PS.Seq_InvoiceNo,
                                         Created_Date = PS.Created_Date,
                                         UserName = u.UserName,
                                         TotalDisc_Amount = (PS.TotalLine_Wise_Discount+PS.Master_Discount_Amt),
                                         Net_Amount = PS.Net_Amount,
                                         Total_Amount = PS.Total_Amount,
                                         Status = PS.Voucher_ID != null ?"Approved" : "Created",
                                     };

                    var FilteredCount = SaleReturn.Count();
                    switch (sortColumn)
                    {
                        case "Seq_InvoiceNo":
                            SaleReturn = sortColumnDirection == "asc" ? SaleReturn.OrderBy(a => a.Seq_InvoiceNo) : SaleReturn.OrderByDescending(a => a.Seq_InvoiceNo);
                            break;
                        case "Created_Date":
                            SaleReturn = sortColumnDirection == "asc" ? SaleReturn.OrderBy(a => a.Created_Date) : SaleReturn.OrderByDescending(a => a.Created_Date);
                            break;
                        default:
                            SaleReturn = SaleReturn.OrderByDescending(a => a.Return_ID);
                            break;
                    }

                    var SaleReturnlist = SaleReturn.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_returns, data = SaleReturnlist };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Sale Return list", ex);
            }
        }

        [WebMethod]
        public static string ApproveReturn(string returnId)
        {
            try
            {
                var user_id = AppConfig.UserID;
                int id = Convert.ToInt32(returnId);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    // The proc deletes and recreates the voucher, so never run it on an already-approved return.
                    if (db.Pharmacy_SaleReturns.Any(r => r.Return_ID == id && r.Voucher_ID != null))
                    {
                        return new JavaScriptSerializer().Serialize(new
                        {
                            Success = false,
                            Message = "Already approved."
                        });
                    }

                    db.ExecuteCommand(
                        "EXEC dbo.SpApproveSaleReturn {0}, {1}",
                        id,
                        user_id
                    );
                }

                return new JavaScriptSerializer().Serialize(new
                {
                    Success = true,
                    Message = "Sale return approved successfully"
                });
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new
                {
                    Success = false,
                    Message = ex.Message
                });
            }
        }

    }
}