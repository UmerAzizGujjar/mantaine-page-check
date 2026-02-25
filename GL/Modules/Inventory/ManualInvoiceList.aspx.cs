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

namespace PMS.Inventory
{
    public partial class ManualInvoiceList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static bool DeleteRecord(string ManID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                var Inv_Id = (from itm in db.Manual_Invoices
                              where (itm.ManualInvoiceId == int.Parse(ManID))
                              select itm.ManualInvoiceId).FirstOrDefault();
                if (Inv_Id != 0)
                {
                    var userid = Convert.ToString(AppConfig.UserID);
                    DBClass.exectueQuery("Update Manual_Invoice set Status='Deleted',IsDeleted=1,Deleted_By='" + userid + "',Deleted_Time=GetDate() where ManualInvoiceId =" + Inv_Id, tranObj, con);
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
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Invoices = _dbContext.Manual_Invoices.Count();
                    var Invoices = from MI in _dbContext.Manual_Invoices
                                   join MID in _dbContext.Manual_Invoice_Details on MI.ManualInvoiceId equals MID.ManualInvoiceId
                                   join V in _dbContext.AP_Vendors on MI.VendorId equals V.Vendor_ID
                                   where
                                        ((MI.ManualInvoiceNum.ToString().Contains(searchValue) || (MI.RefInvoiceNum.ToString().Contains(searchValue) || V.Vendor_Name.Contains(searchValue))))
                                          select new
                                          {
                                              ManualInvoiceId = MI.ManualInvoiceId,
                                              ManualInvoiceNum = MI.ManualInvoiceNum,
                                              VendorName = V.Vendor_Name,
                                              RefInvoiceNum = MI.RefInvoiceNum,
                                              Remarks = MI.Remarks,
                                              ManualInvoiceDate = MI.ManualInvoiceDate,
                                              Status = MI.Status,
                                              TotalAmount = MID.TotalAmount,
                                          };

                    var FilteredCount = Invoices.Count();
                    switch (sortColumn)
                    {
                        case "ManualInvoiceNum":
                            Invoices = sortColumnDirection == "asc" ? Invoices.OrderBy(a => a.ManualInvoiceNum) : Invoices.OrderByDescending(a => a.ManualInvoiceNum);
                            break;
                        case "RefInvoiceNum":
                            Invoices = sortColumnDirection == "asc" ? Invoices.OrderBy(b => b.RefInvoiceNum) : Invoices.OrderByDescending(a => a.RefInvoiceNum);
                            break;
                        default:
                            Invoices = Invoices.OrderByDescending(a => a.ManualInvoiceNum);
                            break;
                    }

                    var InvoiceList = Invoices.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Invoices, data = InvoiceList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Invoice list", ex);
            }
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "ManualInvoicelist";

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
                string pageName = "ManualInvoicelist";

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