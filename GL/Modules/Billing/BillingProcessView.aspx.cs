using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Runtime.Remoting.Contexts;
using System.Text;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static PMS.BillingProcess;

namespace PMS
{
    public partial class BillingProcessView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string DeleteRecord(int Bill_ID)
        {
            List<string> ReceiptNos = new List<string>();

            DataBaseDataContext db = new DataBaseDataContext();

            #region "Checking receipts."

            var rcptList = (from r in db.Receipts
                            where r.Bill_ID == Bill_ID
                            select new { r.Receipt_No, r.Bill_ID }).ToList();
            StringBuilder data = new StringBuilder();

            foreach (var item in rcptList)
            {
                data.Append(item.Receipt_No);
                data.Append(",");
            }
            if (data.Length > 0)
            {
                return "Delete Following Receipts." + data;
            }

            #endregion

            var BillHeader = db.Ar_Billings.Where(b => b.Bill_ID == Bill_ID).FirstOrDefault();

            var BillDetails = (from d in db.Ar_Billing_Details
                               join m in db.Ar_Billings
                               on d.Bill_ID equals m.Bill_ID
                               where m.Bill_ID == Bill_ID
                               select d).ToList();

            foreach (var item in BillDetails)
            {
                if (item.ParentTrans_ID != null && item.ParentTrans_ID != 0 && (item.Item_Type == "Test"))
                {
                    var test = db.Lab_Test_Details.Where(t => t.Lab_Test_Detail_ID == item.ParentTrans_ID).FirstOrDefault();
                    if (test != null)
                        test.IsBilled = false;
                }
                if (item.ParentTrans_ID != null && item.ParentTrans_ID != 0 && (item.Item_Type == "Test" && item.ParentTrans_Type == "Test Group Category"))
                {
                    var GroupedData = (from lbm in db.Laboratory_Tests
                                       join lbd in db.Lab_Test_Details
                                       on lbm.Lab_Test_ID equals lbd.Lab_Test_ID
                                       where lbd.Lab_Test_Detail_ID == item.ParentTrans_ID
                                       select lbm.Parent_Transaction_Type_ID).FirstOrDefault();

                    if (GroupedData != null)
                    {
                        var test = db.Lab_Test_Details.Where(t => t.Lab_Test_Detail_ID == GroupedData).FirstOrDefault();
                        if (test != null)
                            test.IsBilled = false;
                    }
                }
            }
            if (BillDetails != null)
                db.Ar_Billing_Details.DeleteAllOnSubmit(BillDetails);
            db.SubmitChanges();
            if (BillHeader != null)
                db.Ar_Billings.DeleteOnSubmit(BillHeader);

            // Deleting from GL....

            var GL_M = (from m in db.GL_Vouchers where m.Voucher_ID == BillHeader.Voucher_ID select m).FirstOrDefault();
            var GL_D = (from d in db.GL_Voucher_Accounts where d.Voucher_ID == BillHeader.Voucher_ID select d).ToList();
            if (GL_D != null)
                db.GL_Voucher_Accounts.DeleteAllOnSubmit(GL_D);
            db.SubmitChanges();
            if (GL_M != null)
                db.GL_Vouchers.DeleteOnSubmit(GL_M);
            db.SubmitChanges();
            return "";
        }

        [WebMethod]
        public static string CancelPatient(int Bill_No)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            int billPK_ID = (from b in db.Ar_Billings where b.Bill_No == Convert.ToString(Bill_No) select b.Bill_ID).FirstOrDefault();
            string status = "Allowdlt";
            string AllowPatientDelete = DBClass.getField("select dbo.GetRights('AllowPatientDelete','" + AppConfig.UserID + "')");

            if (Convert.ToBoolean(AllowPatientDelete) == true)
            {
                status = "Fail";
                var listReceitps = db.Receipts.Where(r => r.Bill_ID == billPK_ID && r.isCancel == false).ToList();

                if (listReceitps.Count == 0)
                {
                    Ar_Billing p = new Ar_Billing();
                    var query = db.Ar_Billings.SingleOrDefault(x => x.Bill_No == Convert.ToString(Bill_No));
                    if (query != null)
                    {
                        query.isCancel = true;
                        query.Cancel_by = AppConfig.UserID;
                        query.Cancel_Date = DateTime.Now;
                        db.SubmitChanges();
                        status = "success";
                    }
                }
                return status;
            }
            return status;
        }


        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Billing = _dbContext.Ar_Billings.Count();
                    var Billing = from b in _dbContext.Ar_Billings
                              join p in _dbContext.Reg_patients on b.Patient_ID equals p.pat_id
                              join u in _dbContext.aspnet_Users on b.Created_By equals u.UserId
                              where (b.Total_Amount != null || b.Discount_Amount != null)
                                      && (b.isCancel == null || b.isCancel == false)
                                      && (b.IsPharmacy == null || b.IsPharmacy == false)
                              && (
                                    (b.Bill_No.ToString().Contains(searchValue) || p.Full_Name.Contains(searchValue) || p.mr_no_sequence.Contains(searchValue) || u.UserName.Contains(searchValue))) orderby b.Bill_ID descending
                              select new
                              {
                                  Bill_No = b.Bill_No,
                                  Bill_Date = b.Creation_Date,
                                  Remarks = b.Remarks,
                                  Total_Amount = b.Total_Amount,
                                  Discount_Percentage = b.Discount_Percentage,
                                  Discount_Amount = b.Discount_Amount,
                                  Net_Amount = b.Net_Amount,
                                  Received_Amount = b.Received_Amount,
                                  Balance_Amount = b.Balance_Amount,
                                  MrNo = p.mr_no_sequence,
                                  Full_Name = p.Full_Name,
                                  Bill_ID = b.Bill_ID,
                                  Operator = u.UserName
                              };

                    var FilteredCount = Billing.Count();
                    switch (sortColumn)
                    {
                        case "Bill_No":
                            Billing = sortColumnDirection == "asc" ? Billing.OrderBy(a => a.Bill_No) : Billing.OrderByDescending(a => a.Bill_No);
                            break;
                        case "Bill_Date":
                            Billing = sortColumnDirection == "asc" ? Billing.OrderBy(b => b.Bill_Date) : Billing.OrderByDescending(a => a.Bill_Date);
                            break;
                        case "MrNo":
                            Billing = sortColumnDirection == "asc" ? Billing.OrderBy(a => a.MrNo) : Billing.OrderByDescending(a => a.MrNo);
                            break;
                        default:
                            Billing = Billing.OrderByDescending(a => a.Bill_No); 
                            break;
                    }

                    var patientList = Billing.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Billing, data = patientList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching patient list", ex);
            }
        }       
    }
}
