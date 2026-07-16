
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Inventory
{
    public partial class AdvancePayment : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            HyperLink1.Visible = false;
            if (!IsPostBack)
            {
                if (Request.QueryString["Adv_ID"] != null)
                {
                    DataBaseDataContext db = new DataBaseDataContext();
                    var getID = Request.QueryString["Adv_ID"];
                    var gettype = (from a in db.Advance_Payments where a.Advance_ID == Convert.ToInt32(getID) select a.File_Path).FirstOrDefault();
                    if (!string.IsNullOrEmpty(gettype))
                    {
                        HyperLink1.NavigateUrl = gettype;
                        HyperLink1.Visible = true;
                    }

                }
            }

        }
        [WebMethod]
        public static string ApprovePayment(string AdvID)
        {
            var userid = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.SpApproveAdvancePayment(Convert.ToInt32(AdvID), Convert.ToString(userid));
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string UnApprovePayment(string AdvID)
        {
            var userid = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.spUnApproveAdvancePayment(Convert.ToInt32(AdvID), Convert.ToString(userid));
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static bool UserEntryRights()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var uid = AppConfig.UserID;
                var hasEntryRights = db.Sys_Inv_OrignatorTempelate_Masters
                                   .Join(db.Sys_Inv_OrignatorTempelate_Detail_Forms,
                                         SATM => SATM.OrignatorTempelate_ID,
                                         SATDF => SATDF.OrignatorTempelate_ID,
                                         (SATM, SATDF) => new { SATM, SATDF })
                                   .Join(db.Sys_Inv_OrignatorTempelate_Details,
                                         temp => temp.SATM.OrignatorTempelate_ID,
                                         SATDO => SATDO.OrignatorTempelate_ID,
                                         (temp, SATDO) => new { temp.SATM, temp.SATDF, SATDO })
                                   .Any(temp => temp.SATM.IsActive == true && temp.SATM.IsDeleted == false && temp.SATDF.FormId == 12 && temp.SATDO.UserId == uid);

                return hasEntryRights;
            }
        }
        [WebMethod]
        public static string loadadvanceheader(int Adv_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_loadAdvancePaymentHeader(Adv_ID).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static int SaveAdvancePayment(string btnSave, string AllItemDetail)
        {
            string AdvancepaymentID = "";
            Advance_Payment obj = new Advance_Payment();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<MasterInoviceList>(AllItemDetail);
            var lstItem = (from t in db.Advance_Payments where t.Advance_No == int.Parse(record.advanceno) select t).FirstOrDefault();
            if (btnSave == "Update")
            {
                if (record.advanceno != "")
                {
                    lstItem.Advance_No = Convert.ToInt32(record.advanceno);
                }
                lstItem.Total_amount = record.txtTotalAmount;
                if (record.txtdate != "")
                {
                    lstItem.Date = Convert.ToDateTime(record.txtdate);
                }
                if (record.ddl_vendor != "" || record.ddl_vendor != "0")
                {
                    lstItem.Vendor_ID = Convert.ToInt32(record.ddl_vendor);
                }
                if (record.PoID != "" || record.PoID != "0")
                {
                    lstItem.Po_Id = Convert.ToInt32(record.PoID);
                }
                if (record.referno != "")
                {
                    lstItem.Refer_No = record.referno;
                }
                if (record.ddl_paidthrough != "" || record.ddl_paidthrough != "0")
                {
                    lstItem.Paid_Through = Convert.ToInt32(record.ddl_paidthrough);
                }
                if (record.advance_amount != "")
                {
                    lstItem.Advance_Amount = Convert.ToDecimal(record.advance_amount);
                    lstItem.Actual_Advance_Amount = Convert.ToDecimal(record.advance_amount);
                }
                if (record.ddl_withholdtax != "")
                {
                    lstItem.WithHoldTax_Perc = Convert.ToInt32(record.ddl_withholdtax);
                }
                if (record.withhold_tax_amount != "")
                {
                    lstItem.WithHoldTax_Amount = Convert.ToDecimal(record.withhold_tax_amount);
                }
                if (record.txt_paidamount != "")
                {
                    lstItem.Paid_Amount = Convert.ToDecimal(record.txt_paidamount);
                }
                if (record.txt_remarks != "")
                {
                    lstItem.Remarks = record.txt_remarks;
                }
                if (record.txt_status != "")
                {
                    lstItem.Status = record.txt_status;
                }
                if (record.balance_amount != "")
                {
                    lstItem.BalanceAmount = Convert.ToDecimal(record.balance_amount);
                }

                lstItem.WithHoldTax_Check = record.chkWHTax;
                lstItem.Updated_By = Convert.ToString(AppConfig.UserID);
                lstItem.Updated_Date = DateTime.Now;
                db.SubmitChanges();
                AdvancepaymentID = lstItem.Advance_ID.ToString();
            }
            else
            {
                if (record.advanceno != "")
                {
                    obj.Advance_No = Convert.ToInt32(record.advanceno);
                }
                obj.Total_amount = record.txtTotalAmount;
                if (record.txtdate != "")
                {
                    obj.Date = Convert.ToDateTime(record.txtdate);
                }
                if (record.ddl_vendor != "" || record.ddl_vendor != "0")
                {
                    obj.Vendor_ID = Convert.ToInt32(record.ddl_vendor);
                }
                if (record.PoID != "" || record.PoID != "0")
                {
                    obj.Po_Id = Convert.ToInt32(record.PoID);
                }

                if (record.referno != "")
                {
                    obj.Refer_No = record.referno;
                }
                if (record.ddl_paidthrough != "" || record.ddl_paidthrough != "0")
                {
                    obj.Paid_Through = Convert.ToInt32(record.ddl_paidthrough);
                }
                if (record.advance_amount != "")
                {
                    obj.Advance_Amount = Convert.ToDecimal(record.advance_amount);
                    obj.Actual_Advance_Amount = Convert.ToDecimal(record.advance_amount);
                }
                if (record.ddl_withholdtax != "")
                {
                    obj.WithHoldTax_Perc = Convert.ToInt32(record.ddl_withholdtax);
                }
                if (record.withhold_tax_amount != "")
                {
                    obj.WithHoldTax_Amount = Convert.ToDecimal(record.withhold_tax_amount);
                }
                if (record.txt_paidamount != "")
                {
                    obj.Paid_Amount = Convert.ToDecimal(record.txt_paidamount);
                }
                if (record.txt_remarks != "")
                {
                    obj.Remarks = record.txt_remarks;
                }
                if (record.txt_status != "")
                {
                    obj.Status = record.txt_status;
                }
                if (record.balance_amount != "")
                {
                    obj.BalanceAmount = Convert.ToDecimal(record.balance_amount);
                }
                obj.WithHoldTax_Check = record.chkWHTax;
                obj.Created_By = Convert.ToString(AppConfig.UserID);
                obj.Created_Date = DateTime.Now;
                obj.IsDeleted = false;
                db.Advance_Payments.InsertOnSubmit(obj);
                db.SubmitChanges();
                AdvancepaymentID = obj.Advance_ID.ToString();
            }
            return int.Parse(AdvancepaymentID);
        }
        [WebMethod]
        public static string getwtaxtype()

        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from a in db.WithHold_Taxes
                         select new
                         {
                             a.WithHold_Tax_ID,
                             a.WithHold_Tax_Perc,
                         }).ToList();
            string data = string.Empty;
            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static string GetnewAdvanceNumber()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var Payment_No = DBClass.GetNewNumber("Advance_No", "Advance_Payment", "");
            return Payment_No.ToString();
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
        [WebMethod]
        public static string getPONumbersByVendor(int vendorId)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var poList = (from po in db.AP_Purchase_Orders
                          where po.Vendor_ID == vendorId && po.Status == "Approved"
                          select new
                          {
                              po.PO_ID,
                              po.PO_No
                          }).ToList();

            return (new JavaScriptSerializer()).Serialize(poList);
        }
        [WebMethod]
        public static string getPOAmount(int PoId)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var poAmount = (from po in db.AP_Purchase_Orders
                            where po.PO_ID == PoId
                            select new
                            {
                                po.PO_Amount
                            }).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(poAmount);
        }
        [WebMethod]
        public static string GetPaidThrough()
        {
            string result = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            var itemsList = (from i in db.GL_Accounts where i.Levels == 4 && (i.Bank == true || i.Cash == true) select new { i.Account_ID, name = i.Account_Code.ToString() + '-' + i.Account_Name }).ToList();
            if (itemsList != null)
            {
                result = (new JavaScriptSerializer()).Serialize(itemsList);
            }
            return result;
        }
        public class MasterInoviceList
        {
            public string advanceno { get; set; }
            public string txtdate { get; set; }
            public string ddl_vendor { get; set; }
            public string PoID { get; set; }
            public string balance_amount { get; set; }
            public string referno { get; set; }
            public string ddl_paidthrough { get; set; }
            public string advance_amount { get; set; }
            public string ddl_withholdtax { get; set; }
            public string withhold_tax_amount { get; set; }
            public string txt_remarks { get; set; }
            public string txt_status { get; set; }
            public string txt_paidamount { get; set; }
            public decimal? txtTotalAmount { get; set; }
            public bool chkWHTax { get; set; }
        }

        [WebMethod]
        public static bool CheckADVANCEApprovalRights()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var form_id = 12;
                var user_id = AppConfig.UserID;

                return (from SASD in db.Sys_Approval_Stage_Details
                        join SASM in db.Sys_Approval_Stage_Masters on SASD.Stage_ID equals SASM.Stage_ID
                        join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                        join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATD.Tempelate_ID equals SATF.Tempelate_ID
                        join SATM in db.Sys_Approval_Tempelate_Masters on SATD.Tempelate_ID equals SATM.Tempelate_ID
                        where SASD.UserId == user_id && SATF.FormId == form_id && SATM.IsActive == true && SASM.IsDeleted == false
                        select SASD).Any();
            }
        }

        [WebMethod]
        public static string GetADVANCEApprovalInfo(string AdvId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var advId = Convert.ToInt32(AdvId);
                var user_id = AppConfig.UserID;
                var form_id = 12;

                var totalAmount = (from a in db.Advance_Payments
                                   where a.Advance_ID == advId
                                   select (decimal?)a.Advance_Amount).FirstOrDefault() ?? 0m;

                var maxApprovalLimit = db.ExecuteQuery<decimal?>(
                    "SELECT MAX(SASD.MaxApprovalLimit) " +
                    "FROM Sys_Approval_Stage_Detail SASD " +
                    "INNER JOIN Sys_Approval_Stage_Master SASM ON SASD.Stage_ID = SASM.Stage_ID " +
                    "INNER JOIN Sys_Approval_Tempelate_Detail_Stages SATD ON SASM.Stage_ID = SATD.StageId " +
                    "INNER JOIN Sys_Approval_Tempelate_Detail_Forms SATF ON SATD.Tempelate_ID = SATF.Tempelate_ID " +
                    "INNER JOIN Sys_Approval_Tempelate_Master SATM ON SATD.Tempelate_ID = SATM.Tempelate_ID " +
                    "WHERE SASD.UserId = {0} AND SATF.FormId = {1} AND SATM.IsActive = 1 AND SASM.IsDeleted = 0",
                    user_id, form_id).FirstOrDefault() ?? 0m;

                var canApprove = maxApprovalLimit == -1m || totalAmount <= maxApprovalLimit;

                var result = new
                {
                    CanApprove = canApprove,
                    MaxApprovalLimit = maxApprovalLimit,
                    Amount = totalAmount
                };

                return (new JavaScriptSerializer()).Serialize(result);
            }
        }

        [WebMethod]
        public static string ApproveSingleADVANCE(string AdvId, string approvalRemarks)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var advId = Convert.ToInt32(AdvId);
                var user_id = AppConfig.UserID;
                var form_id = 12;

                var ADVANCE = db.Advance_Payments
                    .Where(a => a.Advance_ID == advId)
                    .SingleOrDefault();

                if (ADVANCE == null)
                    return "Error: Advance Payment not found";

                var isFinalApprovals = (from SASD in db.Sys_Approval_Stage_Details
                                        join SASM in db.Sys_Approval_Stage_Masters on SASD.Stage_ID equals SASM.Stage_ID
                                        join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                                        join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATD.Tempelate_ID equals SATF.Tempelate_ID
                                        where SASD.UserId == user_id && SATF.FormId == form_id && SASM.IsDeleted == false
                                        select new { SASM.IsFinalApproval, SATF.FormId }).ToList();

                if (isFinalApprovals.Any(a => a.IsFinalApproval == true && a.FormId == form_id))
                {
                    var Details = db.SpApproveAdvancePayment(advId, Convert.ToString(user_id));
                    db.SubmitChanges();

                    var sasd = (from tbl in db.Sys_Approval_Stage_Details
                                join SASM in db.Sys_Approval_Stage_Masters on tbl.Stage_ID equals SASM.Stage_ID
                                join SATDS in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATDS.StageId
                                join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATDS.Tempelate_ID equals SATF.Tempelate_ID
                                where tbl.UserId == user_id && SASM.IsFinalApproval == true && SATF.FormId == form_id && SASM.IsDeleted == false
                                select tbl).FirstOrDefault();

                    if (sasd != null)
                    {
                        var satds = (from tbl in db.Sys_Approval_Tempelate_Detail_Stages
                                     join SATF in db.Sys_Approval_Tempelate_Detail_Forms on tbl.Tempelate_ID equals SATF.Tempelate_ID
                                     where tbl.StageId == sasd.Stage_ID && SATF.FormId == form_id
                                     select tbl).FirstOrDefault();

                        if (satds != null)
                        {
                            var log = new Sys_Approval_Log();
                            log.Approval_Template_ID = satds.Tempelate_ID;
                            log.Approval_Stage_ID = sasd.Stage_ID;
                            log.Entry_ID = ADVANCE.Advance_ID;
                            log.Form_ID = form_id;
                            log.From_Name = "Advance";
                            log.Remarks = ADVANCE.Remarks;
                            log.Company_ID = AppConfig.Company_ID;
                            log.IsFinalAprroval = true;
                            log.Entry_Status = "Approved";
                            log.Approve_By = user_id;
                            log.Approve_Date = DateTime.Now;
                            log.IsRejected = false;
                            log.Approval_Remarks = approvalRemarks;
                            db.Sys_Approval_Logs.InsertOnSubmit(log);
                            db.SubmitChanges();
                        }
                    }
                }
                else
                {
                    ADVANCE.Status = "Pending";
                    ADVANCE.Approved_Date = DateTime.Now;
                    ADVANCE.Approved_By = Convert.ToString(user_id);
                    db.SubmitChanges();

                    var sasd = (from tbl in db.Sys_Approval_Stage_Details
                                join SASM in db.Sys_Approval_Stage_Masters on tbl.Stage_ID equals SASM.Stage_ID
                                join SATDS in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATDS.StageId
                                join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATDS.Tempelate_ID equals SATF.Tempelate_ID
                                where tbl.UserId == user_id && SASM.IsFinalApproval == false && SATF.FormId == form_id && SASM.IsDeleted == false
                                select tbl).FirstOrDefault();

                    if (sasd != null)
                    {
                        var satds = (from tbl in db.Sys_Approval_Tempelate_Detail_Stages
                                     join SATF in db.Sys_Approval_Tempelate_Detail_Forms on tbl.Tempelate_ID equals SATF.Tempelate_ID
                                     where tbl.StageId == sasd.Stage_ID && SATF.FormId == form_id
                                     select tbl).FirstOrDefault();

                        if (satds != null)
                        {
                            var log = new Sys_Approval_Log();
                            log.Approval_Template_ID = satds.Tempelate_ID;
                            log.Approval_Stage_ID = sasd.Stage_ID;
                            log.Entry_ID = ADVANCE.Advance_ID;
                            log.Form_ID = form_id;
                            log.From_Name = "Advance";
                            log.Remarks = ADVANCE.Remarks;
                            log.Company_ID = AppConfig.Company_ID;
                            log.IsFinalAprroval = false;
                            log.Entry_Status = "Pending";
                            log.Approve_By = user_id;
                            log.Approve_Date = DateTime.Now;
                            log.IsRejected = false;
                            log.Approval_Remarks = approvalRemarks;
                            db.Sys_Approval_Logs.InsertOnSubmit(log);
                            db.SubmitChanges();
                        }
                    }
                }
                db.SubmitChanges();
                return "Success";
            }
        }
    }
}