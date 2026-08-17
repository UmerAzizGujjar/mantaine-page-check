using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Runtime.Remoting.Contexts;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
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

                    // Build the main query (with joins and base filters)
                    var Billing = from b in _dbContext.Ar_Billings
                                  join p in _dbContext.Reg_patients on b.Patient_ID equals p.pat_id
                                  join u in _dbContext.aspnet_Users on b.Created_By equals u.UserId
                                   where (b.Total_Amount != null || b.Discount_Amount != null)
                                        && (b.IsPharmacy == null || b.IsPharmacy == false)
                                  select new
                                  {
                                      Bill_No = b.Bill_No,
                                      Bill_Date = b.Creation_Date,
                                      Remarks = b.Remarks,
                                      Total_Amount = b.Total_Amount,
                                      Discount_Amount = b.Discount_Amount,

                                      // Calculate Discount_Percentage safely
                                      Discount_Percentage = b.Total_Amount.HasValue && b.Total_Amount.Value > 0
    ? Math.Round((b.Discount_Amount ?? 0) / b.Total_Amount.Value * 100, 2, MidpointRounding.AwayFromZero)
    : 0,

                                      Net_Amount = b.Net_Amount,
                                      Received_Amount = b.Received_Amount,
                                      Balance_Amount = b.Balance_Amount,
                                      MrNo = p.mr_no_sequence,
                                      Full_Name = p.Full_Name,
                                       Bill_ID = b.Bill_ID,
                                       Operator = u.UserName,
                                       isCancel = b.isCancel
                                   };

                    // Total records that match base filters (not affected by search)
                    var Total_Billing = Billing.Count();

                    // Apply search filter if searchValue is provided
                    if (!string.IsNullOrWhiteSpace(searchValue))
                    {
                        searchValue = searchValue.Trim();
                        Billing = Billing.Where(x =>
                            x.Bill_No.ToString().Contains(searchValue) ||
                            (x.Full_Name != null && x.Full_Name.Contains(searchValue)) ||
                            (x.MrNo != null && x.MrNo.Contains(searchValue)) ||
                            (x.Operator != null && x.Operator.Contains(searchValue))
                        );
                    }

                    // Count after search filter
                    var FilteredCount = Billing.Count();

                    // Apply sorting (you can extend this later for dynamic sortColumn)
                    Billing = Billing.OrderByDescending(a => a.Bill_ID);

                    // Apply pagination
                    var patientList = Billing.Skip(start).Take(length).ToList();

                    var jsonData = new
                    {
                        draw = draw,
                        recordsFiltered = FilteredCount,
                        recordsTotal = Total_Billing,
                        data = patientList
                    };

                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching patient list", ex);
            }
        }

        [WebMethod]
        public static string GetBillDetails(int billId)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var billDetails = db.Ar_Billing_Details
                        .Where(bd => bd.Bill_ID == billId)
                        .Select(bd => new
                        {
                            Item_Type = bd.Item_Type,
                            Item_Name = bd.Item_Name,
                            Amount = bd.Amount,
                            Discount_Amount = bd.Discount_Amount,
                            Net_Amount = bd.Net_Amount,
                            Test_Main_Department = bd.Test_Main_Department
                        })
                        .ToList();

                    return JsonConvert.SerializeObject(billDetails);
                }
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new { error = ex.Message });
            }
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "BillingProcessView";

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
                string pageName = "BillingProcessView";

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
        public static void IncrementReprintCount(int Bill_ID)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var bill = db.Ar_Billings.FirstOrDefault(b => b.Bill_ID == Bill_ID);
                    if (bill != null)
                    {
                        // Increment the count (handles nulls just in case)
                        bill.Reprint_Count = bill.Reprint_Count + 1;
                        db.SubmitChanges();
                    }
                }
            }
            catch (Exception ex)
            {
                // Optional: Log the exception to your error log
                System.Diagnostics.Debug.WriteLine("Reprint Count Error: " + ex.Message);
            }
        }

    }
}
