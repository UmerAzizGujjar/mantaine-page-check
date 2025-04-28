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
    public partial class PaymentInvoiceView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static bool isDeleteAllow()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            bool value = Convert.ToBoolean(DBClass.getField("select  isnull(AllowPatientDelete,0) from aspnet_users where username='" + AppConfig.UserName + "'"));
            return value;

        }

        [WebMethod]
        public static bool DeleteRecord(string InvID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                var Inv_Id = (from itm in db.Payment_Invoices
                              where (itm.PaymentInvoiceId == int.Parse(InvID))
                              select itm.PaymentInvoiceId).FirstOrDefault();
                if (Inv_Id != 0)
                {
                    DBClass.exectueQuery("delete Payment_Invoice_Detail where PaymentInvoiceId =" + Inv_Id, tranObj, con);
                    DBClass.exectueQuery("delete Payment_Invoice where PaymentInvoiceId =" + Inv_Id, tranObj, con);
                    tranObj.Commit();
                }
                else
                {
                    tranObj.Rollback();
                    return false;
                }
            }
#pragma warning disable CS0168 
            catch (Exception ex)
#pragma warning restore CS0168
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
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Invoices = _dbContext.Payment_Invoices.Count();
                    var Payment_Invoices = from PI in _dbContext.Payment_Invoices                                          
                                           where
                                        ((PI.PaymentNum.ToString().Contains(searchValue) || PI.Remarks.ToString().Contains(searchValue) || PI.InvoiceAdjusted.ToString().Contains(searchValue) || PI.Remarks.ToString().Contains(searchValue) || PI.Status.ToString().Contains(searchValue)))
                                           select new
                                           {
                                               PaymentInvoiceId = PI.PaymentInvoiceId,
                                               PaymentNum = Convert.ToInt32(PI.PaymentNum),
                                               PaymentDate = PI.PaymentDate,
                                               Status = PI.Status,
                                               PaidAmount = PI.PaidAmount,
                                               Amount = PI.InvoiceAdjusted,
                                               Remarks = PI.Remarks,
                                            PurchaseNo = (from gmm in _dbContext.Purchase_Invoice_Masters where gmm.PurchaseInvoiceId == (from gm in _dbContext.Payment_Invoice_Details where gm.Invoice_Type == "PUR" && gm.PaymentInvoiceId == PI.PaymentInvoiceId select gm.PurchaseInvoiceId).FirstOrDefault() select gmm.InvoiceNum).FirstOrDefault(),
                                            ManualNo = (from gmm in _dbContext.Manual_Invoices where gmm.ManualInvoiceId == (from gm in _dbContext.Payment_Invoice_Details where gm.Invoice_Type == "MINV" && gm.PaymentInvoiceId == PI.PaymentInvoiceId select gm.PurchaseInvoiceId).FirstOrDefault() select gmm.ManualInvoiceNum).FirstOrDefault(),
                                               VoucherNo = (from gm in _dbContext.GL_Vouchers where gm.Voucher_ID == PI.Voucher_ID select gm.Voucher_No.ToString()).FirstOrDefault(),
                                               
                                           };

                    var FilteredCount = Payment_Invoices.Count();
                    switch (sortColumn)
                    {
                        case "PaymentNum":
                            Payment_Invoices = sortColumnDirection == "asc" ? Payment_Invoices.OrderBy(a => a.PaymentNum) : Payment_Invoices.OrderByDescending(a => a.PaymentNum);
                            break;
                        case "ManualNo":
                            Payment_Invoices = sortColumnDirection == "asc" ? Payment_Invoices.OrderBy(b => b.ManualNo) : Payment_Invoices.OrderByDescending(a => a.ManualNo);
                            break;
                        default:
                            Payment_Invoices = Payment_Invoices.OrderByDescending(a => a.PaymentNum);
                            break;
                    }

                    var PaymentList = Payment_Invoices.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Invoices, data = PaymentList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Payment Invoice list", ex);
            }
        }
    }
}


