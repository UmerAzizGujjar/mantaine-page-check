using Infragistics.Documents.Reports.Report;
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
    public partial class InversionGatePassView : System.Web.UI.Page
    {
        public static object VendorName { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static List<object> GetAuditInfo(int invoiceId)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.spGetAuditRecordAginstIGP(invoiceId).ToList<object>();

                return query;
            }

        }
        [WebMethod]
        public static object GetMasterAndDetail(int invoiceId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                // Master record
                var master = (from m in db.Igp_masters
                              where m.Igp_Id == invoiceId
                              select new
                              {
                                 ID= m.Igp_Id,
                                 Number = m.Igp_num,
                                 Date = m.Igp_date,
                                 VendorName = DBClass.getField("select Vendor_Name from AP_Vendors where Vendor_ID=" + m.Vendor),
                                 Status = m.Status,
                                 Remarks = m.Remarks
                              }).FirstOrDefault();

                // Detail rows
                var detail = (from d in db.Igp_Details
                              join inv in db.INV_Items on d.Item_Id equals inv.Item_ID
                              where d.Igp_Id == invoiceId
                              select new
                              {
                                  inv.Item_Code,
                                  inv.Description,
                                  d.POQty,
                                  d.InspecQty,
                                  d.IGPQty,
                                  d.BlncQty,
                                  // d.BounusQty

                              }).ToList();

                return new
                {
                    Master = master,
                    Detail = detail
                };
            }
        }
        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_IGP = _dbContext.Igp_masters.Count();
                    var IGP = from Igp in _dbContext.Igp_masters
                              join V in _dbContext.AP_Vendors on Convert.ToInt32(Igp.Vendor) equals V.Vendor_ID
                              select new
                              {
                                  Igp_Id = Igp.Igp_Id,
                                  Igp_num = Igp.Igp_num,
                                  VendorName = V.Vendor_Name,
                                  PONum = "", // Empty string since not needed
                                  BilityNum = Igp.BilityNum,
                                  Remarks = Igp.Remarks,
                                  VehicleNum = Igp.VehicleNum,
                                  Creation_Date = Igp.Creation_Date,
                                  Ware_House = _dbContext.GetDataValueName("Ware House", Igp.InvOrgId),
                                  Update_Date = Igp.Update_Date,
                                  CreatedBy = _dbContext.aspnet_Users.Where(x => x.UserId == Igp.Created_By).Select(x => x.UserName).FirstOrDefault() ?? "",
                                  Updated_By = _dbContext.aspnet_Users.Where(x => x.UserId == Igp.Updated_By).Select(x => x.UserName).FirstOrDefault() ?? "",
                                  Status = Igp.Status,
                                  Inspec_Status = Igp.Inspec_Status,
                                  InvType = Igp.InvType,
                                  Igp_date = Igp.Igp_date,
                                  IsAuto = DBClass.getField("Select isnull(IsAutoGenerate,0) from GRN_Master where IGP_Id =" + Igp.Igp_Id),
                                  Grn_ID = DBClass.getField("select GRN_ID from GRN_Master where IGP_Id=" + Igp.Igp_Id)
                              };

                    // Apply search filter if searchValue is not empty
                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        IGP = IGP.Where(x =>
                            x.Igp_num.ToString().Contains(searchValue) ||
                            (x.VendorName != null && x.VendorName.Contains(searchValue)) ||
                            (x.BilityNum != null && x.BilityNum.ToString().Contains(searchValue)) ||
                            (x.Remarks != null && x.Remarks.Contains(searchValue)) ||
                            (x.VehicleNum != null && x.VehicleNum.ToString().Contains(searchValue)) ||
                            x.Status.Contains(searchValue) ||
                            (x.Inspec_Status != null && x.Inspec_Status.Contains(searchValue)) ||
                            (x.InvType != null && x.InvType.Contains(searchValue)) ||
                            (x.CreatedBy != null && x.CreatedBy.Contains(searchValue))
                        );
                    }

                    var FilteredCount = IGP.Count();

                    // Apply sorting
                    switch (sortColumn)
                    {
                        case "Igp_num":
                            IGP = sortColumnDirection == "asc" ? IGP.OrderBy(a => a.Igp_num) : IGP.OrderByDescending(a => a.Igp_num);
                            break;
                        case "VendorName":
                            IGP = sortColumnDirection == "asc" ? IGP.OrderBy(a => a.VendorName) : IGP.OrderByDescending(a => a.VendorName);
                            break;
                        case "CreatedBy":
                            IGP = sortColumnDirection == "asc" ? IGP.OrderBy(a => a.CreatedBy) : IGP.OrderByDescending(a => a.CreatedBy);
                            break;
                        case "Igp_date":
                            IGP = sortColumnDirection == "asc" ? IGP.OrderBy(a => a.Igp_date) : IGP.OrderByDescending(a => a.Igp_date);
                            break;
                       
                        default:
                            IGP = IGP.OrderByDescending(a => a.Igp_Id);
                            break;
                    }

                    var IGPList = IGP.Skip(start).Take(length).ToList();
                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_IGP, data = IGPList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Inversion Gate Pass list", ex);
            }
        }



        [WebMethod]
        public static bool DeleteRecord(string IGPID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                var user_id = AppConfig.UserID;
                var Igp_Id = (from itm in db.Igp_masters
                              where (itm.Igp_Id == int.Parse(IGPID))
                              select itm.Igp_Id).FirstOrDefault();
                if (Igp_Id != 0)
                {
                    DBClass.exectueQuery("Update Igp_master set IsDeleted=0,DeletedBy='" + user_id + "',Deleted_Time=GetDate() where Igp_Id =" + Igp_Id, tranObj, con);
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
        public static string AutoGRN(string IgpId)
        {
            var user_id = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_AutoGRN(Convert.ToInt32(IgpId), user_id);
            return (new JavaScriptSerializer()).Serialize(Details);
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "InversionGatepassView";

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
                string pageName = "InversionGatepassView";

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