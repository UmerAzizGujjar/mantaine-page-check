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
                    string id = Convert.ToInt32(advid).ToString();
                    var username = AppConfig.UserID.ToString();

                    string query = $@"
                        UPDATE Refund 
                        SET isCancelled = 1, 
                            CancelledBy = '{username}', 
                            CancelledTime = GETDATE() 
                        WHERE Refund_ID = {id};

                        UPDATE Refund_Detail_Services 
                        SET isCancelled = 1, 
                            CancelledBy = '{username}', 
                            CancelledTime = GETDATE() 
                        WHERE Refund_ID = {id};

                        UPDATE Refund_Detail_Doctor_Share 
                        SET isCancelled = 1, 
                            CancelledBy = '{username}', 
                            CancelledTime = GETDATE() 
                        WHERE Refund_ID = {id};
                    ";

                    bool rowUpdated = DBClass.exectueQuery(query, tranObj, con);

                   
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
                                     ((R.Refund_ID.ToString().Contains(searchValue)  || R.Bill_ID.ToString().Contains(searchValue)|| R.Bill_ID.ToString().Contains(searchValue) || R.Refund_Amount.ToString().Contains(searchValue) || (from bl in _dbContext.Ar_Billings where bl.Bill_ID == R.Bill_ID select bl.Bill_No).FirstOrDefault().Contains(searchValue) || (from bl in _dbContext.Patients where bl.Patient_ID == R.Patient_ID select bl.mr_no_sequence).FirstOrDefault().ToString().Contains(searchValue)))
                                select new
                                {
                                    Refund_ID = R.Refund_ID,
                                    Bill_ID = R.Bill_ID,
                                    Bill_No = (from bl in _dbContext.Ar_Billings where bl.Bill_ID == R.Bill_ID select bl.Bill_No).FirstOrDefault(),
                                    Refund_Date = R.Refund_Date,
                                    Refund_Amount = R.Refund_Amount,
                                    Status = R.Status ?? "Created",
                                    MrNo = (from bl in _dbContext.Patients where bl.Patient_ID == R.Patient_ID select bl.mr_no_sequence).FirstOrDefault(),
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

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "RefundList";

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
                string pageName = "RefundList";

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

        [WebMethod]
        public static bool ApproveRefunds(List<string> refundIds)
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var userId = AppConfig.UserID; 

                    foreach (var idStr in refundIds)
                    {
                        if (int.TryParse(idStr, out int refundId))
                        {
                            var refund = db.Refunds.FirstOrDefault(r => r.Refund_ID == refundId);
                            if (refund != null)
                            {
                                refund.approve_by = userId;
                                refund.approve_date = DateTime.Now;
                                refund.Status = "Approved";
                            }
                        }
                    }
                    db.SubmitChanges();
                }
                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }

        public Guid? approve_by { get; set; }
        public DateTime? approve_date { get; set; }
        public string Status { get; set; }
    }
}