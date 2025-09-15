using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class VoucherView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static object VoucherViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue, string vouchertype, string voucheryear)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    // Count total vouchers
                    var totalVouchers = _dbContext.GL_Vouchers.Where(a => a.Voucher_Type == vouchertype).Count();

                    // Query to filter vouchers
                    var vouchersQuery = from a in _dbContext.GL_Vouchers
                                        where (a.Voucher_No.ToString().Contains(searchValue)
                                        || a.Remarks.Contains(searchValue)
                                        || a.Ref_Num.Contains(searchValue)
                                        || a.Pay_To_Name.Contains(searchValue))
                                        && a.Voucher_Type == vouchertype
                                        && Convert.ToDateTime(a.Voucher_Date).Year == Convert.ToInt32(voucheryear)
                                        select new
                                        {
                                            a.Voucher_ID,
                                            a.Voucher_No,
                                            a.Voucher_Type,
                                            a.Voucher_Date,
                                            a.Ref_Num,
                                            a.Remarks,
                                            a.Voucher_Status,
                                            a.Total_Debit,
                                            a.Creation_Time,
                                            a.Pay_To_Name,
                                            Created_By = (from u in _dbContext.aspnet_Users where u.UserId == a.Created_By select u.UserName).FirstOrDefault(),
                                            Approved_By = (from u in _dbContext.aspnet_Users where u.UserId == a.Approved_By select u.UserName).FirstOrDefault(),
                                            TotalDebtAmt = _dbContext.GL_Voucher_Accounts.Where(g => g.Voucher_ID == a.Voucher_ID).Sum(g => g.DR)
                                        };

                    var filteredCount = vouchersQuery.Count();

                    switch (sortColumn)
                    {
                        case "Voucher_No":
                            vouchersQuery = sortColumnDirection == "asc" ? vouchersQuery.OrderBy(v => v.Voucher_No) : vouchersQuery.OrderByDescending(v => v.Voucher_No);
                            break;
                        case "Voucher_Date":
                            vouchersQuery = sortColumnDirection == "asc" ? vouchersQuery.OrderBy(v => v.Voucher_Date) : vouchersQuery.OrderByDescending(v => v.Voucher_Date);
                            break;
                        case "Pay_To_Name":
                            vouchersQuery = sortColumnDirection == "asc" ? vouchersQuery.OrderBy(v => v.Pay_To_Name) : vouchersQuery.OrderByDescending(v => v.Pay_To_Name);
                            break;
                        default:
                            vouchersQuery = vouchersQuery.OrderByDescending(v => v.Voucher_No);
                            break;
                    }
                    var voucherList = vouchersQuery.Skip(start).Take(length).ToList();
                    var jsonData = new
                    {
                        draw = draw,
                        recordsFiltered = filteredCount,
                        recordsTotal = totalVouchers,
                        data = voucherList
                    };

                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Voucher list", ex);
            }
        }
     

        [WebMethod]
        public static bool DeleteRecord(string VOUCHERID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            var userid = AppConfig.UserID;
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                var V_ID = (from itm in db.GL_Vouchers
                            where (itm.Voucher_ID == int.Parse(VOUCHERID))
                            select itm.Voucher_ID).FirstOrDefault();
                if (V_ID != 0)
                {
                    DBClass.exectueQuery("Update GL_Vouchers set Voucher_Status='Cancelled',IsDeleted=1,Deleted_By='" + userid + "',Deleted_Date='" + DateTime.Now + "' where Voucher_ID =" + V_ID, tranObj, con);
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
    }
}