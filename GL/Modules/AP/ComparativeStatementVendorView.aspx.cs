using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.AP
{
    public partial class ComparativeStatementVendorView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }


        [WebMethod]
        public static bool DeleteRecord(string CMID)
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
                var CM_ID = (from itm in db.CS_Vendor_Masters
                             where (itm.CS_Ven_Master_ID == int.Parse(CMID))
                             select itm.CS_Ven_Master_ID).FirstOrDefault();
                if (CM_ID != 0)
                {
                    DBClass.exectueQuery("Update CS_Vendor_Master set IsDeleted=1,Deleted_By='" + userid + "',Deleted_Time='" + date + "' where CS_Ven_Master_ID =" + CM_ID, tranObj, con);
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
        public static string AutoPO(string CSID)
        {
            //var userid = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_AutoPO(Convert.ToInt32(CSID), Convert.ToString(AppConfig.UserID));
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

                    var Total_Vendors = _dbContext.CS_Vendor_Masters.Count();
                    var Vendor_Master = from vendor in _dbContext.CS_Vendor_Masters
                                        where vendor.CS_Ven_No.ToString().Contains(searchValue) || vendor.Status.ToString().Contains(searchValue) ||
                                              vendor.Remarks.ToString().Contains(searchValue)
                                        select new
                                        {
                                            CSVENID = vendor.CS_Ven_Master_ID,
                                            CSVENNO = vendor.CS_Ven_No,
                                            CSVENDATE = vendor.CS_Date,
                                            CSVENVALIDITY = vendor.CS_Validity,
                                            CSVENREMARKS = vendor.Remarks,
                                            CSVENSTATUS = vendor.Status,
                                            IsAuto = vendor.IsAutoGenerate,
                                            PoStatus = _dbContext.AP_Purchase_Orders.Where(po => po.CS_Master_ID == vendor.CS_Ven_Master_ID).OrderByDescending(po => po.PO_ID).Select(po => po.Status)
                                                         .FirstOrDefault() ?? string.Empty,
                                            PoID = _dbContext.AP_Purchase_Orders
                                                     .Where(po => po.CS_Master_ID == vendor.CS_Ven_Master_ID)
                                                     .OrderByDescending(po => po.PO_ID)
                                                     .Select(po => (int?)po.PO_ID)
                                                     .FirstOrDefault()
                                        };


                    var filteredVendorMaster = Vendor_Master
                .Where(v => v.CSVENDATE >= new DateTime(1753, 1, 1) && v.CSVENDATE <= new DateTime(9999, 12, 31))
                .ToList();

                    var FilteredCount = Vendor_Master.Count();
                    switch (sortColumn)
                    {
                        case "CSVENNO":
                            Vendor_Master = sortColumnDirection == "asc" ? Vendor_Master.OrderBy(a => a.CSVENNO) : Vendor_Master.OrderByDescending(a => a.CSVENNO);
                            break;
                        case "CSVENDATE":
                            Vendor_Master = sortColumnDirection == "asc" ? Vendor_Master.OrderBy(b => b.CSVENDATE) : Vendor_Master.OrderByDescending(a => a.CSVENDATE);
                            break;
                        default:
                            Vendor_Master = Vendor_Master.OrderByDescending(a => a.CSVENID);
                            break;
                    }

                    var AdvancePaymentList = Vendor_Master.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Vendors, data = AdvancePaymentList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Comparative Statement  list", ex);
            }
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "ComparativeStatementVendorView";

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
                string pageName = "ComparativeStatementVendorView";

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