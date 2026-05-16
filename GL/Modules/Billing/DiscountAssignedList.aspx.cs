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
    }
}