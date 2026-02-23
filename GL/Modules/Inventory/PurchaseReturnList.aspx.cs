using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Inventory
{
	public partial class PurchaseReturnList : System.Web.UI.Page
	{
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static bool DeleteRecord(string ReturnID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            var userid = AppConfig.UserID;
            tranObj = con.BeginTransaction();
            try
            {
                var Id = (from itm in db.Purchase_Return_Masters
                          where (itm.Purchase_Return_ID == int.Parse(ReturnID))
                          select itm.Purchase_Return_ID).FirstOrDefault();
                if (Id != 0)
                {
                    DBClass.exectueQuery("Update Purchase_Return_Master set Status='Deleted',IsDeleted=1,DeletedBy='" + userid + "',DeletedDate=GetDate() where Purchase_Return_ID =" + Id, tranObj, con);

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

                    var Total_Purchase = _dbContext.Purchase_Return_Masters.Count();
                    var Puchase_Return = from PR in _dbContext.Purchase_Return_Masters
                                           where
                                        ((PR.Purchase_Return_No.ToString().Contains(searchValue) || PR.Remarks.ToString().Contains(searchValue)))
                                           select new
                                           {
                                               Purchase_Return_ID = PR.Purchase_Return_ID,
                                               Purchase_Return_No = PR.Purchase_Return_No,
                                               Purchase_Return_Date = PR.Purchase_Return_Date,
                                               Remarks = PR.Remarks,
                                               Status = PR.Status,                                             
                                              
                                           };

                    var FilteredCount = Puchase_Return.Count();
                    switch (sortColumn)
                    {
                        case "Purchase_Return_No":
                            Puchase_Return = sortColumnDirection == "asc" ? Puchase_Return.OrderBy(a => a.Purchase_Return_No) : Puchase_Return.OrderByDescending(a => a.Purchase_Return_No);
                            break;
                        case "Purchase_Return_Date":
                            Puchase_Return = sortColumnDirection == "asc" ? Puchase_Return.OrderBy(b => b.Purchase_Return_Date) : Puchase_Return.OrderByDescending(a => a.Purchase_Return_Date);
                            break;
                        default:
                            Puchase_Return = Puchase_Return.OrderByDescending(a => a.Purchase_Return_No);
                            break;
                    }

                    var PurchaseReturnList = Puchase_Return.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Purchase, data = PurchaseReturnList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Purchase Return list", ex);
            }
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "PurchaseReturnlist";

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
                string pageName = "PurchaseReturnlist";

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