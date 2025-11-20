
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
    }
}