using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Billing
{
    public partial class Medicine_History : System.Web.UI.Page
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

                    var Total_Billings = _dbContext.Ar_Billings.Count();
                    var MedicineHistory = from AB in _dbContext.Ar_Billings
                                          join ABD in _dbContext.Ar_Billing_Details on AB.Bill_ID equals ABD.Bill_ID into detailsGroup
                                          where AB.IsPharmacy == true &&
                                                (
                                                    (AB.Customer_Name != null && AB.Customer_Name.Contains(searchValue)) ||
                                                    (AB.Referred_By_value != null && AB.Referred_By_value.Contains(searchValue)) ||
                                                    (AB.Received_Amount != null && AB.Received_Amount.ToString().Contains(searchValue)) ||
                                                    _dbContext.Reg_patients.Any(rg => rg.pat_id == AB.Patient_ID && rg.mr_no_sequence != null && rg.mr_no_sequence.Contains(searchValue)
                                                    || detailsGroup.Any(d => d.Item_Name != null && d.Item_Name.Contains(searchValue)))
                                                )
                                          select new
                                          {
                                              BillNo = AB.Seq_InvoiceNo,
                                              Invoice_Date = AB.Invoice_Date,
                                              Customer_Name = AB.Customer_Name,
                                              Referred_By_value = AB.Referred_By_value,
                                              Patient_ID = _dbContext.Reg_patients.Where(rg => rg.pat_id == AB.Patient_ID).Select(rg => rg.mr_no_sequence).FirstOrDefault(),
                                              Received_Amount = AB.Received_Amount,
                                              Bill_ID = AB.Bill_ID,
                                              Total_Amount = AB.Total_Amount,
                                              Discount_Amount = AB.Discount_Amount,
                                              Balance_Amount = AB.Balance_Amount,
                                              FBR_Number = AB.FBR_No ?? "",
                                              Item_Name = string.Join(", ", detailsGroup.Select(d => d.Item_Name).Distinct())
                                          };

                    var FilteredCount = MedicineHistory.Count();
                    switch (sortColumn)
                    {

                        case "Patient_ID":
                            MedicineHistory = sortColumnDirection == "asc" ? MedicineHistory.OrderBy(b => b.Patient_ID) : MedicineHistory.OrderByDescending(a => a.Patient_ID);
                            break;
                        case "Invoice_Date":
                            MedicineHistory = sortColumnDirection == "asc" ? MedicineHistory.OrderBy(a => a.Invoice_Date) : MedicineHistory.OrderByDescending(a => a.Invoice_Date);
                            break;
                        default:
                            MedicineHistory = MedicineHistory.OrderByDescending(a => a.Bill_ID);
                            break;
                    }

                    var MedicineHistryList = MedicineHistory.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Billings, data = MedicineHistryList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching MedicineHistory list", ex);
            }
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "Medicine_History";

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
                string pageName = "Medicine_History";

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
    }
}