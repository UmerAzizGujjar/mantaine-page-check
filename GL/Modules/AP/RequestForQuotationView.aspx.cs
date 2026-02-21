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

namespace PMS.AP
{
    public partial class RequestForQuotationView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        [WebMethod]
        public static bool DeleteRecord(string RFQID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            var userid = AppConfig.UserID;
            var date = DateTime.Now;
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                var RFQ_ID = (from itm in db.AP_RequestForQuotations
                              where (itm.RFQ_ID == int.Parse(RFQID))
                              select itm.RFQ_ID).FirstOrDefault();
                if (RFQ_ID != 0)
                {
                    DBClass.exectueQuery("Update AP_RequestForQuotations set IsDeleted=1,Deleted_By='" + userid + "',Deleted_Time='" + date + "' where RFQ_ID =" + RFQID, tranObj, con);
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
        public static bool isDeleteAllow()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            bool value = Convert.ToBoolean(DBClass.getField("select isnull(AllowPatientDelete,0) from aspnet_users where username='" + AppConfig.UserName + "'"));
            return value;
        }

        [WebMethod]
        public static string GetVendorsforReports(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = (from d in db.AP_RequestForQuotation_Vendors
                           where d.RFQ_ID == id
                           select new
                           {
                               d.VendorId,

                           }).ToList();

            return (new JavaScriptSerializer()).Serialize(Details);
        }


        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Quotations = _dbContext.AP_RequestForQuotations.Count();
                    var QuotationsRequest = from RQ in _dbContext.AP_RequestForQuotations
                                         where
                                             ((RQ.RFQ_ID.ToString().Contains(searchValue) || RQ.RFQ_No.ToString().Contains(searchValue) || RQ.Remarks.ToString().Contains(searchValue) || RQ.Ref_No.ToString().Contains(searchValue) || (from v in _dbContext.AP_Vendors where RQ.Vendor_ID == v.Vendor_ID select new { vendor = v.Vendor_Name }).FirstOrDefault().vendor.ToString().Contains(searchValue) || RQ.Status.ToString().Contains(searchValue)))
                                         select new
                                         {
                                             RFQID = RQ.RFQ_ID,
                                             RFQNo = RQ.RFQ_No,
                                             Date = RQ.RFQ_Date,
                                             RefNo = RQ.Ref_No,
                                             VendorName = (from v in _dbContext.AP_Vendors where RQ.Vendor_ID == v.Vendor_ID select new { vendor = v.Vendor_Name }).FirstOrDefault().vendor.ToString(),
                                             Status = RQ.Status,
                                             Remarks = RQ.Remarks,

                                         };

                    var FilteredCount = QuotationsRequest.Count();
                    switch (sortColumn)
                    {
                        case "RFQNo":
                            QuotationsRequest = sortColumnDirection == "asc" ? QuotationsRequest.OrderBy(a => a.RFQNo) : QuotationsRequest.OrderByDescending(a => a.RFQNo);
                            break;
                        case "Date":
                            QuotationsRequest = sortColumnDirection == "asc" ? QuotationsRequest.OrderBy(b => b.Date) : QuotationsRequest.OrderByDescending(a => a.Date);
                            break;
                            default:
                            QuotationsRequest = QuotationsRequest.OrderByDescending(a => a.RFQID);
                            break;
                    }

                    var RequestQuotation = QuotationsRequest.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Quotations, data = RequestQuotation };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Request Quotation list", ex);
            }
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "RequestForQuotationView";

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
                string pageName = "RequestForQuotationView";

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
