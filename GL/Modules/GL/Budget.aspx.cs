using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class Budget : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        private class ddlListItems
        {
            public string DataValueName;
            public string DataValueDescription;
            public string Type;
        }
        [WebMethod]
        public static string filldepartments()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Department"
                         select new ddlListItems
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(listItems);
        }
        [WebMethod]
        public static string fillcostcenterss()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Cost Center"
                         select new ddlListItems
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(listItems);
        }
        [WebMethod]
        public static string UnApproveVoucher(int VID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            Budget bdg = new Budget();
            bdg = (from tbl in db.Budgets
                       where tbl.Budget_ID == VID
                       select tbl).FirstOrDefault();
            if (bdg != null)
            {
                bdg.Budget_Status = "Created";
                bdg.Approved_Time = DateTime.Now;
                db.SubmitChanges();
            }
            return (new JavaScriptSerializer()).Serialize(bdg);
        }
        [WebMethod]
        public static string LoadVoucherMaster(int VID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Header = (from a in db.Budgets
                          where a.Budget_ID == VID
                          select new
                          {
                              a.Budget_ID,
                              a.Budget_No,
                              a.Budget_Status,
                              a.Budget_Type,
                              a.Budget_Date,
                              a.Remarks,
                              a.Total_Debit,
                              a.Total_Credit,
                          }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(Header);
        }
        [WebMethod]
        public static string LoadVoucherChild(int VID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_loadBudgetdetail(VID).ToList();
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        public static string checkPeriodClosed(DateTime date)
        {
            string lblmsg = string.Empty;
            string str = "select Period_Closed from GL_Periods where '" + date + "' between Period_start_date and Period_end_date and Company_ID=" + AppConfig.Company_ID + "";
            string closed_id = DBClass.getField(str);
            if (!closed_id.Contains("position"))
            {
                if (Convert.ToBoolean(closed_id) == true)
                {
                    lblmsg = "Period closed for this month. You cannot add or edit Voucher.";
                }
                else
                    lblmsg = "";
            }
            else
            {
                lblmsg = "Period closed for this month. You cannot add or edit Voucher.";
            }
            return lblmsg;
        }
        [WebMethod]
        public static string Savealldata(string btnSave, string AllItemDetail)
        {
            string InvoiceId = "";
            string vouNo = "";
            long budgetId = 0;
            Budget bdg = new Budget();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<MasterList>(AllItemDetail);
            DateTime checkbugetDate;
            if (DateTime.TryParseExact(record.txtdate, "MM/dd/yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out checkbugetDate))
            {
            }
            else
            {
                string voucherdatemsg = string.Empty;
                voucherdatemsg = "Voucher Date is not Correct.";
                return voucherdatemsg;
            }

            if (checkPeriodClosed(Convert.ToDateTime(checkbugetDate)) == "Period closed for this month. You cannot add or edit Voucher.")
            {
                string periodmsg = string.Empty;
                periodmsg = "Period closed for this month. You cannot add or edit Voucher.";
                return periodmsg;
            }
            else
            {
                if (btnSave == "Update")
                {
                    var lstItem = (from t in db.Budgets where t.Budget_ID == int.Parse(record.editmode_budgetID) && t.Budget_Type == record.type select t).FirstOrDefault();
                    DateTime voucherDate = Convert.ToDateTime(checkbugetDate.Date);
                    int month = voucherDate.Month;
                    int voucherCreatedmonth = Convert.ToDateTime(lstItem.Budget_Date).Month;
                    if (month == voucherCreatedmonth)
                        lstItem.Budget_Date = Convert.ToDateTime(record.txtdate);
                    lstItem.Budget_Type = record.type;
                    lstItem.Remarks = record.descriptionmaster;
                    lstItem.Budget_Status = record.status;
                    lstItem.Total_Credit = Convert.ToDecimal(record.totalcredit);
                    lstItem.Total_Debit = Convert.ToDecimal(record.totaldebit);
                    lstItem.Updated_By = AppConfig.UserID;
                    lstItem.Update_Time = DateTime.Now;
                    lstItem.Period_ID = DBClass.GetPeriod_ID(Convert.ToDateTime(checkbugetDate.Date));
                    db.SubmitChanges();
                    budgetId = lstItem.Budget_ID;
                }
                else
                {
                    vouNo = DBClass.GetNewVoucherNo(record.type, Convert.ToDateTime(checkbugetDate.Date)).ToString();
                    bdg.Budget_No = Convert.ToInt32(vouNo);
                    bdg.Budget_Type = record.type;
                    bdg.Budget_Date = Convert.ToDateTime(checkbugetDate.Date);
                    bdg.Remarks = record.descriptionmaster;
                    bdg.Budget_Status = record.status;
                    bdg.Total_Credit = Convert.ToDecimal(record.totalcredit);
                    bdg.Total_Debit = Convert.ToDecimal(record.totaldebit);
                    bdg.Created_By = AppConfig.UserID;
                    bdg.Creation_Time = DateTime.Now;
                    bdg.Company_ID = AppConfig.Company_ID;
                    bdg.Closing = false;
                    bdg.IsDeleted = false;
                    bdg.Period_ID = DBClass.GetPeriod_ID(Convert.ToDateTime(checkbugetDate.Date));
                    db.Budgets.InsertOnSubmit(bdg);
                    db.SubmitChanges();
                    budgetId = bdg.Budget_ID;
                }
                if (btnSave == "Update")
                {
                    List<Budget_Account> lstbudgetdetails = db.Budget_Accounts.Where(t => t.Budget_ID == budgetId).ToList();
                    db.Budget_Accounts.DeleteAllOnSubmit(lstbudgetdetails);
                    db.SubmitChanges();
                }
                foreach (var a in record.Item_List)
                {                    
                    Budget_Account bdg_acc = new Budget_Account();
                    bdg_acc.Budget_ID = budgetId;
                    if (a.accountcode != "")
                    {
                        bdg_acc.Account_ID = Convert.ToInt32(a.accountcode);
                    }
                    if (a.ddlcostcenterid == "undefined")
                    {
                        a.ddlcostcenterid = "";
                    }
                    if (a.ddlcostcenterid == null)
                    {
                        a.ddlcostcenterid = "";
                    }
                    if (a.ddlcostcenterid != "")
                    {
                        bdg_acc.Cost_Center = a.ddlcostcenterid;
                    }

                    if (a.ddldepartmentid == "undefined")
                    {
                        a.ddldepartmentid = "";
                    }
                    if (a.ddldepartmentid == null)
                    {
                        a.ddldepartmentid = "";
                    }
                    if (a.ddldepartmentid != "")
                    {
                        bdg_acc.DepartmentId = a.ddldepartmentid;
                    }
                    if (a.txtnarration != "")
                    {
                        bdg_acc.Narration = a.txtnarration;
                    }                   
                    if (a.txtdebamount != "")
                    {
                        bdg_acc.DR = Convert.ToDecimal(a.txtdebamount);
                    }
                    if (a.txtcredamount != "")
                    {
                        bdg_acc.CR = Convert.ToDecimal(a.txtcredamount);
                    }
                    db.Budget_Accounts.InsertOnSubmit(bdg_acc);
                    db.SubmitChanges();
                }
            }
            return budgetId.ToString();
        }
        public class MasterList
        {
            public string editmode_budgetID { get; set; }
            public string budgetno { get; set; }
            public string type { get; set; }
            public string txtdate { get; set; }
            public string descriptionmaster { get; set; }
            public string status { get; set; }
            public string totaldebit { get; set; }
            public string totalcredit { get; set; }
            public List<DetailList> Item_List { get; set; }
        }
        public class DetailList
        {
            public string accountcode { get; set; }
            public string txtdebamount { get; set; }
            public string txtcredamount { get; set; }
            public string ddlcostcentername { get; set; }
            public string ddlcostcenterid { get; set; }
            public string ddldepartmentname { get; set; }
            public string ddldepartmentid { get; set; }
            public string txtnarration { get; set; }
            public string txtaccountname { get; set; }

        }
    }

}


