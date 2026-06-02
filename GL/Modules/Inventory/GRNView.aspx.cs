using Infragistics.Documents.Reports.Report;
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
    public partial class GRNView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static bool isDeleteAllow()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            bool value = Convert.ToBoolean(DBClass.getField("select isnull(AllowPatientDelete,0) from aspnet_users where username='" + AppConfig.UserName + "'"));
            return value;
        }

        [WebMethod]
        public static List<object> GetAuditInfo(int invoiceId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.spGetAuditRecordAginstGRN(invoiceId).ToList<object>();
                return query;
            }
        }

        [WebMethod]
        public static object GetMasterAndDetail(int invoiceId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                // Master record - optimized without DBClass.getField
                var master = (from m in db.GRN_Masters
                              join v in db.AP_Vendors on m.VendorId equals v.Vendor_ID.ToString()
                              where m.GRN_ID == invoiceId
                              select new
                              {
                                  m.GRN_ID,
                                  m.GRN_Num,
                                  m.GRN_Date,
                                  VendorName = v.Vendor_Name,
                                  m.Status,
                                  m.Remarks
                              }).FirstOrDefault();

                // Detail rows
                var detail = (from d in db.GRN_Details
                              join inv in db.INV_Items on d.Item_Id equals inv.Item_ID
                              where d.GRNId == invoiceId
                              select new
                              {
                                  inv.Item_Code,
                                  inv.Description,
                                  d.GRNQty,
                                  d.Rate,
                                  d.Amount,
                              }).ToList();

                return new
                {
                    Master = master,
                    Detail = detail
                };
            }
        }

        [WebMethod]
        public static bool DeleteRecord(string GRNID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                var GRN_Id = (from itm in db.GRN_Masters
                              where (itm.GRN_ID == int.Parse(GRNID))
                              select itm.GRN_ID).FirstOrDefault();
                if (GRN_Id != 0)
                {
                    DBClass.exectueQuery("Update GRN_Master set Status='Cancelled',IsDeleted=1,Deleted_By='" + AppConfig.UserID + "',Deleted_Time=GetDate() where GRN_ID =" + GRN_Id, tranObj, con);
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
                    _dbContext.CommandTimeout = 180;

                    var Total_GRNS = _dbContext.GRN_Masters.Count();

                    // Optimized query following IGP structure
                    var GRNS = from GRN in _dbContext.GRN_Masters
                               join V in _dbContext.AP_Vendors on GRN.VendorId equals V.Vendor_ID.ToString()
                               where (GRN.GRN_Num.ToString().Contains(searchValue) ||
                                      V.Vendor_Name.ToString().Contains(searchValue) ||
                                      GRN.Status.ToString().Contains(searchValue) ||
                                      GRN.Remarks.ToString().Contains(searchValue))
                               select new
                               {
                                   GRN_ID = GRN.GRN_ID,
                                   GRN_Num = GRN.GRN_Num,
                                   Vendor_Name = V.Vendor_Name,
                                   Remarks = GRN.Remarks,
                                   Status = GRN.Status,
                                   Approved_Date = GRN.Approved_Date,
                                   Creation_Date = GRN.Creation_Date,
                                   Update_Date = GRN.Update_Date,
                                   CreatedBy = _dbContext.aspnet_Users.Where(x => x.UserId == GRN.Created_By).Select(x => x.UserName).FirstOrDefault(),
                                   Ware_House = _dbContext.GetDataValueName("Ware House", GRN.InvOrgId),
                                   Updated_By = _dbContext.aspnet_Users.Where(x => x.UserId == GRN.Updated_By).Select(x => x.UserName).FirstOrDefault(),
                                   // These fields are kept for compatibility but not displayed
                                   po_Number = "",
                                   Igp_Number = ""
                               };

                    var FilteredCount = GRNS.Count();

                    switch (sortColumn)
                    {
                        case "GRN_Num":
                            GRNS = sortColumnDirection == "asc" ? GRNS.OrderBy(a => a.GRN_Num) : GRNS.OrderByDescending(a => a.GRN_Num);
                            break;
                        case "Vendor_Name":
                            GRNS = sortColumnDirection == "asc" ? GRNS.OrderBy(a => a.Vendor_Name) : GRNS.OrderByDescending(a => a.Vendor_Name);
                            break;
                        case "Status":
                            GRNS = sortColumnDirection == "asc" ? GRNS.OrderBy(a => a.Status) : GRNS.OrderByDescending(a => a.Status);
                            break;
                        case "CreatedBy":
                            GRNS = sortColumnDirection == "asc" ? GRNS.OrderBy(a => a.CreatedBy) : GRNS.OrderByDescending(a => a.CreatedBy);
                            break;
                        default:
                            GRNS = GRNS.OrderByDescending(a => a.GRN_ID);
                            break;
                    }

                    var GRNLIST = GRNS.Skip(start).Take(length).ToList();
                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_GRNS, data = GRNLIST };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching GRN list", ex);
            }
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "GRNView";

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
                string pageName = "GRNView";

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