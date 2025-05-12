using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class BudgetView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }


        [WebMethod]
        public static object VoucherViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue, string month, string year, bool checkyear)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var totalRecords = db.Budgets.Count();

                    var query = from a in db.Budgets
                                where (checkyear
                                        ? Convert.ToDateTime(a.Budget_Date).Year == Convert.ToInt32(year)
                                        : Convert.ToDateTime(a.Budget_Date).Month == Convert.ToInt32(month)
                                          && Convert.ToDateTime(a.Budget_Date).Year == Convert.ToInt32(year))
                                select new
                                {
                                    a.Budget_ID,
                                    a.Budget_No,
                                    a.Budget_Date,
                                    a.Remarks,
                                    a.Budget_Status,
                                    a.Total_Debit,
                                    a.Creation_Time,
                                    TotalDebtAmt = db.Budget_Accounts.Where(g => g.Budget_ID == a.Budget_ID).Sum(g => (decimal?)g.DR) ?? 0
                                };

                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        query = query.Where(q =>
                            q.Budget_No.ToString().Contains(searchValue) ||
                            q.Remarks.Contains(searchValue)
                        );
                    }

                    var recordsFiltered = query.Count();

                    switch (sortColumn)
                    {
                        case "Budget_No":
                            query = sortColumnDirection == "asc" ? query.OrderBy(v => v.Budget_No) : query.OrderByDescending(v => v.Budget_No);
                            break;
                        case "Budget_Date":
                            query = sortColumnDirection == "asc" ? query.OrderBy(v => v.Budget_Date) : query.OrderByDescending(v => v.Budget_Date);
                            break;
                        case "Total_Debit":
                            query = sortColumnDirection == "asc" ? query.OrderBy(v => v.Total_Debit) : query.OrderByDescending(v => v.Total_Debit);
                            break;
                        default:
                            query = query.OrderByDescending(v => v.Budget_ID);
                            break;
                    }

                    var budgetList = query.Skip(start).Take(length).ToList();

                    var jsonData = new
                    {
                        draw = draw,
                        recordsTotal = totalRecords,
                        recordsFiltered = recordsFiltered,
                        data = budgetList
                    };

                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Budget list", ex);
            }
        }



        //[WebMethod]
        //public static string VoucherViewList(string month, string year, bool checkyear)
        //{
        //    string result = string.Empty;
        //    JavaScriptSerializer serl = new JavaScriptSerializer();
        //    serl.MaxJsonLength = 2147483647;
        //    using (DataBaseDataContext db = new DataBaseDataContext())
        //    {
        //        if (checkyear == true)
        //        {
        //            var query = (from a in db.Budgets
        //                         where Convert.ToDateTime(a.Budget_Date).Year == Convert.ToInt32(year)
        //                         select new
        //                         {
        //                             a.Budget_ID,
        //                             a.Budget_No,
        //                             a.Budget_Date,
        //                             a.Remarks,
        //                             a.Budget_Status,
        //                             a.Total_Debit,
        //                             a.Creation_Time,
        //                             TotalDebtAmt = DBClass.getField("select sum(DR) from Budget_Accounts where Budget_ID =" + a.Budget_ID),
        //                         }).ToList().Distinct();
        //            return serl.Serialize(query);
        //        }
        //        else
        //        {
        //            var query = (from a in db.Budgets
        //                         where Convert.ToDateTime(a.Budget_Date).Month == Convert.ToInt32(month)
        //                         && Convert.ToDateTime(a.Budget_Date).Year == Convert.ToInt32(year)
        //                         select new
        //                         {
        //                             a.Budget_ID,
        //                             a.Budget_No,
        //                             a.Budget_Date,
        //                             a.Remarks,
        //                             a.Budget_Status,
        //                             a.Total_Debit,
        //                             a.Creation_Time,
        //                             TotalDebtAmt = DBClass.getField("select sum(DR) from Budget_Accounts where Budget_ID =" + a.Budget_ID),
        //                         }).ToList().Distinct();
        //            return serl.Serialize(query);
        //        }
        //    }
        //}
        [WebMethod]
        public static bool DeleteRecord(string BudgetID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            var userid = AppConfig.UserID;
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                var V_ID = (from itm in db.Budgets
                            where (itm.Budget_ID == int.Parse(BudgetID))
                            select itm.Budget_ID).FirstOrDefault();
                if (V_ID != 0)
                {
                    DBClass.exectueQuery("Update Budgets set Budget_Status='Cancelled',IsDeleted=1,Deleted_By='" + userid + "',Deleted_Date='" + DateTime.Now + "' where Budget_ID =" + V_ID, tranObj, con);
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
        public static bool ApproveRecord(string BudgetID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            var userid = AppConfig.UserID;
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                var V_ID = (from itm in db.Budgets
                            where (itm.Budget_ID == int.Parse(BudgetID))
                            select itm.Budget_ID).FirstOrDefault();
                if (V_ID != 0)
                {
                    DBClass.exectueQuery("Update Budgets set Budget_Status='Approved',Approved_By='" + userid + "',Approved_Time='" + DateTime.Now + "' where Budget_ID =" + V_ID, tranObj, con);
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