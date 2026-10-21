using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class Voucher : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            HyperLink1.Visible = false;
            if (!IsPostBack)
            {
                if (Request.QueryString["VID"] != null)
                {
                    DataBaseDataContext db = new DataBaseDataContext();
                    var getID = Request.QueryString["VID"];
                    var gettype = (from a in db.GL_Vouchers where a.Voucher_ID == Convert.ToInt32(getID) select a.File_Path).FirstOrDefault();
                    if (!string.IsNullOrEmpty(gettype))
                    {
                        HyperLink1.NavigateUrl = gettype;
                        HyperLink1.Visible = true;
                    }
                }
            }
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
            GL_Voucher voucher = new GL_Voucher();
            voucher = (from tbl in db.GL_Vouchers
                       where tbl.Voucher_ID == VID
                       select tbl).FirstOrDefault();
            if (voucher != null)
            {
                voucher.Voucher_Status = "Created";
                voucher.Approved_Time = DateTime.Now;
                db.SubmitChanges();
            }
            return (new JavaScriptSerializer()).Serialize(voucher);
        }
        [WebMethod]
        public static string LoadVoucherMaster(int VID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Header = (from a in db.GL_Vouchers
                          where a.Voucher_ID == VID
                          select new
                          {
                              a.Voucher_ID,
                              a.Voucher_No,
                              a.Voucher_Status,
                              a.Voucher_Type,
                              a.Voucher_Date,
                              a.Pay_To_Name,
                              a.Remarks,
                              a.Vendor_ID,
                              a.Branch_Id,
                              a.Ref_Num,
                              a.Total_Debit,
                              a.Total_Credit,
                          }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(Header);
        }
        [WebMethod]
        public static string LoadVoucherChild(int VID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_loadvoucherdetail(VID).ToList();
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
        public static int GetNewVoucherNo(string voucherType, DateTime voucherDate)
        {
            using (SqlConnection con = new SqlConnection(DBClass.ConnectionString()))
            {
                con.Open();
                string strSQL = "SELECT dbo.GetNewVoucherNo(@voucherType, @voucherDate)";
                using (SqlCommand cmd = new SqlCommand(strSQL, con))
                {
                    cmd.Parameters.AddWithValue("@voucherType", voucherType);
                    cmd.Parameters.AddWithValue("@voucherDate", voucherDate.Date);

                    object result = cmd.ExecuteScalar();

                    if (result == null || result == DBNull.Value)
                        return 1;

                    return Convert.ToInt32(result);
                }
            }
        }
        [WebMethod]
        public static string Savealldata(string btnSave, string AllItemDetail)
        {
            string InvoiceId = "";
            string vouNo = "";
            long voucherId = 0;
            GL_Voucher gv = new GL_Voucher();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<MasterList>(AllItemDetail);
            DateTime checkvoucherDate;
            if (DateTime.TryParseExact(record.txtdate, "MM/dd/yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out checkvoucherDate))
            {
            }
            else
            {
                string voucherdatemsg = string.Empty;
                voucherdatemsg = "Voucher Date is not Correct.";
                return voucherdatemsg;
            }

            if (checkPeriodClosed(Convert.ToDateTime(checkvoucherDate)) == "Period closed for this month. You cannot add or edit Voucher.")
            {
                string periodmsg = string.Empty;
                periodmsg = "Period closed for this month. You cannot add or edit Voucher.";
                return periodmsg;
            }
            else
            {
                if (btnSave == "Update")
                {
                    var lstItem = (from t in db.GL_Vouchers where t.Voucher_ID == int.Parse(record.editmode_voucherID) && t.Voucher_Type == record.type select t).FirstOrDefault();
                    DateTime voucherDate = Convert.ToDateTime(checkvoucherDate.Date);
                    int month = voucherDate.Month;
                    int voucherCreatedmonth = Convert.ToDateTime(lstItem.Voucher_Date).Month;
                    if (month == voucherCreatedmonth)
                        lstItem.Voucher_Date = Convert.ToDateTime(record.txtdate);
                    lstItem.Voucher_Type = record.type;
                    lstItem.Remarks = record.descriptionmaster;
                    lstItem.Voucher_Status = record.status;
                    lstItem.Ref_Num = record.refnum;
                    lstItem.Pay_To_Name = record.txtptn;
                    lstItem.Vendor_ID = record.vendorID;
                    lstItem.Branch_Id = record.branchID > 0 ? (int?)record.branchID : null;
                    lstItem.Total_Credit = Convert.ToDecimal(record.totalcredit);
                    lstItem.Total_Debit = Convert.ToDecimal(record.totaldebit);
                    lstItem.Updated_By = AppConfig.UserID;
                    lstItem.Update_Time = DateTime.Now;
                    lstItem.Company_ID = AppConfig.Company_ID;
                    lstItem.Closing = false;
                    lstItem.Cancel = false;
                    lstItem.Period_ID = DBClass.GetPeriod_ID(Convert.ToDateTime(checkvoucherDate.Date));



                    if (lstItem == null)
                        throw new Exception("Voucher not found for update.");


                    var existingDetails = db.GL_Voucher_Accounts
                        .Where(d => d.Voucher_ID == int.Parse(record.editmode_voucherID))
                        .ToList();

                    var previousVoucherData = new
                    {
                        Voucher = new
                        {
                            lstItem.Voucher_No,
                            VoucherDate = lstItem.Voucher_Date,
                            lstItem.Voucher_Type,
                            lstItem.Remarks,
                            lstItem.Voucher_Status,
                            lstItem.Approved_By,
                            lstItem.Updated_By,
                            lstItem.Approved_Time,
                            lstItem.Update_Time,
                            lstItem.Total_Debit,
                            lstItem.Total_Credit,
                        },
                        Details = new
                        {
                            GL_Voucher_Account = existingDetails.Select(d => new
                            {
                                d.Voucher_account_ID,
                                d.Account_ID,
                                d.DR,
                                d.CR,
                                d.Voucher_ID,
                                d.Cost_Center,
                                d.Cheque_No,
                                d.Cheque_Date
                            }).ToList()
                        }
                    };

                    string masterLogJson = oJS.Serialize(previousVoucherData.Voucher);
                    string detailsLogJson = oJS.Serialize(previousVoucherData.Details);

                    Gl_Accounts_Log VoucherLog = new Gl_Accounts_Log
                    {
                        Voucher_Id = int.Parse(record.editmode_voucherID),
                        Master_Logs = masterLogJson,
                        Details_Logs = detailsLogJson,
                        Logged_Time = DateTime.Now,
                        Logged_By = AppConfig.UserID
                    };

                    db.Gl_Accounts_Logs.InsertOnSubmit(VoucherLog);


                    db.SubmitChanges();
                    voucherId = lstItem.Voucher_ID;
                }
                else
                {
                    vouNo = DBClass.GetNewVoucherNo(record.type, Convert.ToDateTime(checkvoucherDate.Date)).ToString();
                    gv.Voucher_No = Convert.ToInt32(vouNo);
                    gv.Voucher_Type = record.type;
                    gv.Voucher_Date = Convert.ToDateTime(checkvoucherDate.Date);
                    gv.Remarks = record.descriptionmaster;
                    gv.Voucher_Status = record.status;
                    gv.Ref_Num = record.refnum;
                    gv.Pay_To_Name = record.txtptn;
                    gv.Vendor_ID = record.vendorID;
                    gv.Branch_Id = record.branchID > 0 ? (int?)record.branchID : null;
                    gv.Total_Credit = Convert.ToDecimal(record.totalcredit);
                    gv.Total_Debit = Convert.ToDecimal(record.totaldebit);
                    gv.Created_By = AppConfig.UserID;
                    gv.Creation_Time = DateTime.Now;
                    gv.Company_ID = AppConfig.Company_ID;
                    gv.Closing = false;
                    gv.Cancel = false;
                    gv.Period_ID = DBClass.GetPeriod_ID(Convert.ToDateTime(checkvoucherDate.Date));
                    db.GL_Vouchers.InsertOnSubmit(gv);
                    db.SubmitChanges();
                    voucherId = gv.Voucher_ID;
                }
                if (btnSave == "Update")
                {
                    List<GL_Voucher_Account> lstvoucherdetails = db.GL_Voucher_Accounts.Where(t => t.Voucher_ID == voucherId).ToList();
                    db.GL_Voucher_Accounts.DeleteAllOnSubmit(lstvoucherdetails);
                    db.SubmitChanges();
                }
                foreach (var a in record.Item_List)
                {
                    DateTime cheqDate;
                      string[] acceptedFormats = {
                            "MM/dd/yyyy",      // for new saves
                            "dd MMM yyyy",     // for edits (e.g., "24 Dec 2025")
                            "dd/MM/yyyy",      // just in case
                            "yyyy-MM-dd"       // ideal
                        };

                    if (DateTime.TryParseExact(a.txtcheqdate?.Trim(), acceptedFormats,
                        CultureInfo.InvariantCulture, DateTimeStyles.None, out cheqDate))
                    {
                        // Proceed — cheqDate is correctly parsed
                    }
                    else
                    {
                        return "cheq Date is not in a recognized format (e.g., MM/dd/yyyy or dd MMM yyyy).";
                    }
                    GL_Voucher_Account voc = new GL_Voucher_Account();
                    voc.Voucher_ID = voucherId;
                    if (a.accountcode != "")
                    {
                        voc.Account_ID = Convert.ToInt32(a.accountcode);
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
                        voc.Cost_Center = a.ddlcostcenterid;
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
                        voc.DepartmentId = a.ddldepartmentid;
                    }
                    if (a.txtnarration != "")
                    {
                        voc.Narration = a.txtnarration;
                    }
                    if (a.txtcheqno != "")
                    {
                        voc.Cheque_No = a.txtcheqno;
                    }
                    if (a.txtcheqdate != "")
                    {
                        voc.Cheque_Date = Convert.ToDateTime(cheqDate.Date);
                    }
                    if (a.txtdebamount != "")
                    {
                        voc.DR = Convert.ToDecimal(a.txtdebamount);
                    }
                    if (a.txtcredamount != "")
                    {
                        voc.CR = Convert.ToDecimal(a.txtcredamount);
                    }
                    db.GL_Voucher_Accounts.InsertOnSubmit(voc);
                    db.SubmitChanges();
                }
            }
            return voucherId.ToString();
        }
        [WebMethod]
        public static string GetUserBranch()
        {
            using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var branchIds = (from bwd in db.Branch_Wise_User_Details
                                 where bwd.User_Id == AppConfig.UserID
                                 select bwd.Brancg).ToList();

                if (!branchIds.Any())
                    return "null";

                var validBranches = new List<object>();

                foreach (var brancg in branchIds)
                {
                    if (int.TryParse(brancg, out int branchId))
                    {
                        var branch = db.Branches.FirstOrDefault(b => b.branch_ID == branchId);
                        if (branch != null)
                        {
                            validBranches.Add(new { branch_ID = branchId, branch_Name = branch.branch_Name });
                        }
                    }
                }

                if (!validBranches.Any())
                    return "null";

                return new JavaScriptSerializer().Serialize(validBranches);
            }
        }
        [WebMethod]
        public static string getVendorDDLlist()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            AP_Vendor obj = new AP_Vendor();
            var listItems = (from a in db.AP_Vendors
                             where a.IsActive == true
                             select new
                             {
                                 a.Vendor_ID,
                                 a.Vendor_Name,
                             }).ToList();
            return (new JavaScriptSerializer()).Serialize(listItems);
        }
        public class MasterList
        {
            public string editmode_voucherID { get; set; }
            public string voucherno { get; set; }
            public string type { get; set; }
            public string txtdate { get; set; }
            public string txtptn { get; set; }
            public string descriptionmaster { get; set; }
            public string status { get; set; }
            public string refnum { get; set; }
            public string totaldebit { get; set; }
            public string totalcredit { get; set; }
            public int vendorID { get; set; }
            public int branchID { get; set; }
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
            public string txtcheqno { get; set; }
            public string txtcheqdate { get; set; }
            public string txtaccountname { get; set; }

        }
    }

}


