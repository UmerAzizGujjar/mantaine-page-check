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
        public static string VoucherViewList(string month, string year, bool checkyear)
        {
            string result = string.Empty;
            JavaScriptSerializer serl = new JavaScriptSerializer();
            serl.MaxJsonLength = 2147483647;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                if (checkyear == true)
                {
                    var query = (from a in db.Budgets
                                 where Convert.ToDateTime(a.Budget_Date).Year == Convert.ToInt32(year)
                                 select new
                                 {
                                     a.Budget_ID,
                                     a.Budget_No,
                                     a.Budget_Date,
                                     a.Remarks,
                                     a.Budget_Status,
                                     a.Total_Debit,
                                     a.Creation_Time,
                                     TotalDebtAmt = DBClass.getField("select sum(DR) from Budget_Accounts where Budget_ID =" + a.Budget_ID),
                                 }).ToList().Distinct();
                    return serl.Serialize(query);
                }
                else
                {
                    var query = (from a in db.Budgets
                                 where Convert.ToDateTime(a.Budget_Date).Month == Convert.ToInt32(month)
                                 && Convert.ToDateTime(a.Budget_Date).Year == Convert.ToInt32(year)
                                 select new
                                 {
                                     a.Budget_ID,
                                     a.Budget_No,
                                     a.Budget_Date,
                                     a.Remarks,
                                     a.Budget_Status,
                                     a.Total_Debit,
                                     a.Creation_Time,
                                     TotalDebtAmt = DBClass.getField("select sum(DR) from Budget_Accounts where Budget_ID =" + a.Budget_ID),
                                 }).ToList().Distinct();
                    return serl.Serialize(query);
                }
            }
        }
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