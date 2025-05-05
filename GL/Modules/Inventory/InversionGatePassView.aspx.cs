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
                              where
                            ((Igp.Igp_num.ToString().Contains(searchValue) || _dbContext.GetPONum(Igp.Igp_Id).ToString().Contains(searchValue) || Igp.Igp_num.ToString().Contains(searchValue) || V.Vendor_Name.ToString().Contains(searchValue) || Igp.Inspec_Status.ToString().Contains(searchValue) || Igp.Status.ToString().Contains(searchValue) || Igp.Inspec_Status.ToString().Contains(searchValue) || Igp.Inspec_Status.ToString().Contains(searchValue)))
                              select new
                              {
                                  Igp_Id = Igp.Igp_Id,
                                  Igp_num = Igp.Igp_num,
                                  VendorName = V.Vendor_Name,
                                  PONum = _dbContext.GetPONum(Igp.Igp_Id),
                                  BilityNum = Igp.BilityNum,
                                  Remarks = Igp.Remarks,
                                  VehicleNum = Igp.VehicleNum,
                                  Status = Igp.Status,
                                  Inspec_Status = Igp.Inspec_Status,
                                  InvType = Igp.InvType,
                                  Igp_date = Igp.Igp_date,
                                  IsAuto = DBClass.getField("Select isnull(IsAutoGenerate,0) from GRN_Master where IGP_Id =" + Igp.Igp_Id),
                                  Grn_ID = DBClass.getField("select GRN_ID from GRN_Master where IGP_Id=" + Igp.Igp_Id)

                              };

                    

                    var FilteredCount = IGP.Count();
                    switch (sortColumn)
                    {
                        case "Igp_num":
                            IGP = sortColumnDirection == "asc" ? IGP.OrderBy(a => a.Igp_num) : IGP.OrderByDescending(a => a.Igp_num);
                            break;
                        case "PONum":
                            IGP = sortColumnDirection == "asc" ? IGP.OrderBy(b => b.PONum) : IGP.OrderByDescending(a => a.PONum);
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
                throw new Exception("Error fetching Purchase Order list", ex);
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

    }
}