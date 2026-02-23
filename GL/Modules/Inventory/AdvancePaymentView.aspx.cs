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
    public partial class AdvancePaymentView : System.Web.UI.Page
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
        public static bool DeleteRecord(string AdvID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                var ADV_ID = (from itm in db.Payment_Invoices
                              where (itm.PaymentInvoiceId == int.Parse(AdvID))
                              select itm.PaymentInvoiceId).FirstOrDefault();
                if (ADV_ID != 0)
                {
                    DBClass.exectueQuery("delete Advance_Payment where Advance_ID =" + ADV_ID, tranObj, con);
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

                    var Total_Payments = _dbContext.Advance_Payments.Count();
                    var Advance_Payments = from AP in _dbContext.Advance_Payments
                                           where
                                      ((AP.Advance_No.ToString().Contains(searchValue) || AP.Remarks.ToString().Contains(searchValue) || AP.Advance_Amount.ToString().Contains(searchValue) ||
                                      (from v in _dbContext.AP_Vendors where AP.Vendor_ID == v.Vendor_ID select new { vendor = v.Vendor_Name }).FirstOrDefault().vendor.ToString().ToString().Contains(searchValue)))
                                         select new
                                         {
                                             Advance_ID = AP.Advance_ID,
                                             advance_no = AP.Advance_No,
                                             date = AP.Date,
                                             VendorName = (from v in _dbContext.AP_Vendors where AP.Vendor_ID == v.Vendor_ID select new { vendor = v.Vendor_Name }).FirstOrDefault().vendor.ToString(),
                                             refer_no = AP.Refer_No,
                                             advance_amount = AP.Advance_Amount,
                                             status = AP.Status,
                                             remarks = AP.Remarks,
                                         };

                    var FilteredCount = Advance_Payments.Count();
                    switch (sortColumn)
                    {
                        case "refer_no":
                            Advance_Payments = sortColumnDirection == "asc" ? Advance_Payments.OrderBy(a => a.refer_no) : Advance_Payments.OrderByDescending(a => a.refer_no);
                            break;
                        case "date":
                            Advance_Payments = sortColumnDirection == "asc" ? Advance_Payments.OrderBy(b => b.date) : Advance_Payments.OrderByDescending(a => a.date);
                            break;
                        default:
                            Advance_Payments = Advance_Payments.OrderByDescending(a => a.advance_no);
                            break;
                    }

                    var AdvancePaymentList = Advance_Payments.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Payments, data = AdvancePaymentList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Advance Payment  list", ex);
            }
        }


        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "AdvancePaymentView";

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
                string pageName = "AdvancePaymentView";

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