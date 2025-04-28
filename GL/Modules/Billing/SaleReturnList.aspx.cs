using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
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

    }
}