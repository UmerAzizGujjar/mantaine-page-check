using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Net.NetworkInformation;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Inventory
{
    public partial class StoreStockTransferView : System.Web.UI.Page
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
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Stock_Transfers = _dbContext.Stock_Transfers.Count();
                    var Stock = from ST in _dbContext.Stock_Transfers
                                where (ST.Stock_Transfer_No.ToString().Contains(searchValue) || _dbContext.GetDataValueName("Ware House", ST.Ware_House_From).Contains(searchValue) || _dbContext.GetDataValueName("Ware House", ST.Ware_House_To).Contains(searchValue)) 
                                select new
                              {

                                  Stock_Transfer_ID = ST.Stock_Transfer_ID,
                                  Stock_Transfer_No = ST.Stock_Transfer_No,
                                  Stock_Transfer_Date = ST.Stock_Transfer_Date,
                                  WareHouseFrom = _dbContext.GetDataValueName("Ware House", ST.Ware_House_From),
                                  WareHouseTo = _dbContext.GetDataValueName("Ware House", ST.Ware_House_To),
                                  Remarks = ST.Remarks,
                                  STN_Status = ST.STN_Status,
                                  Status = ST.Status,
                                  Transfer_Status = ST.Transfer_Status,
                              };



                    var FilteredCount = Stock.Count();
                    switch (sortColumn)
                    {
                        case "Stock_Transfer_No":
                            Stock = sortColumnDirection == "asc" ? Stock.OrderBy(a => a.Stock_Transfer_No) : Stock.OrderByDescending(a => a.Stock_Transfer_No);
                            break;
                        default:
                            Stock = Stock.OrderByDescending(a => a.Stock_Transfer_ID);
                            break;
                    }


                    var Stocklist = Stock.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Stock_Transfers, data = Stocklist };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching patient list", ex);
            }
        }


        [WebMethod]
        public static bool DeleteRecord(string STN_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                var ST_ID = (from itm in db.Stock_Transfers
                             where (itm.Stock_Transfer_ID == int.Parse(STN_ID))
                             select itm.Stock_Transfer_ID).FirstOrDefault();
                if (ST_ID != 0)
                {
                    DBClass.exectueQuery("delete Stock_Transfer_Items where Stock_Transfer_ID =" + ST_ID, tranObj, con);
                    DBClass.exectueQuery("delete Stock_Transfer where Stock_Transfer_ID =" + ST_ID, tranObj, con);
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