using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Billing
{
    public partial class DiscountAssignedList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    DateTime searchDate;
                    bool isDateSearch = DateTime.TryParse(searchValue, out searchDate);

                    var Total_Discount = _dbContext.Discount_Assign_Bills.Count();
                    var Discount = from p in _dbContext.Discount_Assign_Bills
                                   join rp in _dbContext.Reg_patients on p.Reg_ID equals rp.pat_id
                              where (rp.mr_no_sequence.ToString().Contains(searchValue) || rp.Full_Name.Contains(searchValue))
                              select new
                              {
                                  Discount_Assign_ID = p.Discount_Assign_ID,
                                  mr_no_sequence = rp.mr_no_sequence,
                                  Bill_ID = p.Bill_ID,
                                  Full_Name = rp.Full_Name,
                                  Patient_ID = rp.pat_id,
                                  Discount_Date = p.Discount_Date,
                                  NIC = rp.NIC,
                                  Total_Discount = p.Total_Discount,
                                  Created_By = _dbContext.aspnet_Users.Where(x => x.UserId == p.Created_By).Select(x => x.UserName).FirstOrDefault(),
                              };



                    var FilteredCount = Discount.Count();
                    switch (sortColumn)
                    {
                        case "mr_no_sequence":
                            Discount = sortColumnDirection == "asc" ? Discount.OrderBy(a => a.mr_no_sequence) : Discount.OrderByDescending(a => a.mr_no_sequence);
                            break;
                        case "Discount_Date":
                            Discount = sortColumnDirection == "asc" ? Discount.OrderBy(a => a.Discount_Date) : Discount.OrderByDescending(a => a.Discount_Date);
                            break;
                        default:
                            Discount = Discount.OrderByDescending(a => a.Discount_Assign_ID);
                            break;
                    }


                    var DiscountList = Discount.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Discount, data = DiscountList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Discount list", ex);
            }
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "DiscountAssignedList";

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
                string pageName = "DiscountAssignedList";

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
        public static bool GetUserDiscountPermission()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var user = db.aspnet_Users.FirstOrDefault(u => u.UserId == AppConfig.UserID);
                return user?.AllowDiscount_assign == true;
            }
        }

        [WebMethod]
        public static string GetDiscountDetails(int discountAssignId)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var discountDetails = db.Discount_Assign_Detail_bills
                        .Where(dd => dd.Discount_Assign_ID == discountAssignId)
                        .Select(dd => new
                        {
                            Item_ID = dd.Item_ID,
                            Item_Name = dd.Item_Name,
                            Item_Type = dd.Item_Type,
                            Original_Amount = dd.Original_Amount,
                            Discount_Percentage = dd.Discount_Percentage,
                            Discount_Amount = dd.Discount_Amount,
                            Net_Amount = dd.Net_Amount
                        })
                        .ToList();

                    return Newtonsoft.Json.JsonConvert.SerializeObject(discountDetails);
                }
            }
            catch (Exception ex)
            {
                return Newtonsoft.Json.JsonConvert.SerializeObject(new { error = ex.Message });
            }
        }

        [WebMethod]
        public static string ApproveDiscountsBulk(string billIdsJson)
        {
            try
            {
                var billIds = Newtonsoft.Json.JsonConvert.DeserializeObject<List<string>>(billIdsJson);

                if (billIds == null || billIds.Count == 0)
                    return "Error: No bills selected for approval.";

                using (var db = new DataBaseDataContext())
                {
                    foreach (string billIdStr in billIds)
                    {
                        int billId = Convert.ToInt32(billIdStr);

                        var discountMaster = db.Discount_Assign_Bills
                                               .OrderByDescending(d => d.Creation_Date)
                                               .FirstOrDefault(d => d.Bill_ID == billId);

                        if (discountMaster == null) continue; // Skip if not found

                        // Skip if already approved
                        if (discountMaster.Status == "Approved") continue;

                        decimal totalAmount = discountMaster.Total_amount ?? 0;
                        decimal totalDiscount = discountMaster.Total_Discount;

                        // Update Ar_Billings
                        var arBill = db.Ar_Billings.FirstOrDefault(b => b.Bill_ID == billId);
                        if (arBill != null)
                        {
                            arBill.Discount_Amount = totalDiscount;
                            arBill.Received_Amount = totalAmount;
                            arBill.Cash_In_Hand = totalAmount;
                            arBill.Net_Amount = totalAmount;
                        }

                        // Update Receipts
                        var arReceipt = db.Receipts.FirstOrDefault(r => r.Bill_ID == billId);
                        if (arReceipt != null)
                        {
                            arReceipt.Receipt_Amount = totalAmount;
                        }

                        // Update Discount details
                        var approvedDetails = db.Discount_Assign_Detail_bills
                                                .Where(d => d.Discount_Assign_ID == discountMaster.Discount_Assign_ID)
                                                .ToList();

                        foreach (var service in approvedDetails)
                        {
                            var arBillDetail = db.Ar_Billing_Details
                                                 .FirstOrDefault(d => d.Bill_Details_ID == service.Bill_Detail_ID);

                            if (arBillDetail != null)
                            {
                                arBillDetail.Discount_Percentage = service.Discount_Percentage;
                                arBillDetail.Discount_Amount = service.Discount_Amount;
                                arBillDetail.Net_Amount = service.Net_Amount;
                            }
                        }

                        discountMaster.Status = "Approved";
                    }

                    db.SubmitChanges();
                    return "Success";
                }
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }
    }
}