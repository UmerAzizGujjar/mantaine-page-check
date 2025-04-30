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

namespace PMS
{
    public partial class RefundList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static bool DeleteRecord(string advId)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());         
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                var advid = (from itm in db.Refunds
                             where (itm.Refund_ID == int.Parse(advId))
                             select itm.Refund_ID).FirstOrDefault();
                if (advid != 0)
                {
                    DBClass.exectueQuery("delete Refund where Refund_ID =" + advid, tranObj, con);
                    DBClass.exectueQuery("delete Refund_Detail_Services where Refund_ID =" + advid, tranObj, con);
                    DBClass.exectueQuery("delete Refund_Detail_Doctor_Share where Refund_ID =" + advid, tranObj, con);
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

                    var Total_Refunds = _dbContext.Refunds.Count();
                    var Refunds = from R in _dbContext.Refunds
                                where 
                                     ((R.Refund_ID.ToString().Contains(searchValue)  || R.Bill_ID.ToString().Contains(searchValue)|| R.Bill_ID.ToString().Contains(searchValue) || R.Refund_Amount.ToString().Contains(searchValue) || (from bl in _dbContext.Ar_Billings where bl.Bill_ID == R.Bill_ID select bl.Bill_No).FirstOrDefault().Contains(searchValue) || (from bl in _dbContext.Patients where bl.Patient_ID == R.Patient_ID select bl.Patient_No).FirstOrDefault().ToString().Contains(searchValue)))
                                select new
                                {
                                    Refund_ID = R.Refund_ID,
                                    Bill_ID = R.Bill_ID,
                                    Bill_No = (from bl in _dbContext.Ar_Billings where bl.Bill_ID == R.Bill_ID select bl.Bill_No).FirstOrDefault(),
                                    Refund_Date = R.Refund_Date,
                                    Refund_Amount = R.Refund_Amount,
                                    MrNo = (from bl in _dbContext.Patients where bl.Patient_ID == R.Patient_ID select bl.Patient_No).FirstOrDefault(),
                                    Remarks = R.Remarks,
                                };

                    var FilteredCount = Refunds.Count();
                    switch (sortColumn)
                    {
                        case "Bill_ID":
                            Refunds = sortColumnDirection == "asc" ? Refunds.OrderBy(a => a.Bill_ID) : Refunds.OrderByDescending(a => a.Bill_ID);
                            break;
                        case "Refund_Date":
                            Refunds = sortColumnDirection == "asc" ? Refunds.OrderBy(a => a.Refund_Date) : Refunds.OrderByDescending(a => a.Refund_Date);
                            break;
                        default:
                            Refunds = Refunds.OrderByDescending(a => a.Refund_ID);
                            break;
                    }

                    var RefundList = Refunds.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Refunds, data = RefundList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Item list", ex);
            }
        }
    }
}