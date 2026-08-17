using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class IssueMedicineList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }



        [WebMethod]
        public static string GetWarehouses()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Ware House"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();

                return new JavaScriptSerializer().Serialize(result);
            }
        }

        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue, string warehouseId)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Billings = _dbContext.Ar_Billings.Count();
                    var IssueMedicine = from AB in _dbContext.Ar_Billings
                                        where AB.IsPharmacy == true &&
                                              (string.IsNullOrEmpty(warehouseId) || warehouseId == "0" || AB.Ware_House == warehouseId) &&
                                              (
                                                  (AB.Customer_Name != null && AB.Customer_Name.Contains(searchValue)) ||
                                                  (AB.Referred_By_value != null && AB.Referred_By_value.Contains(searchValue)) ||
                                                  (AB.Received_Amount != null && AB.Received_Amount.ToString().Contains(searchValue)) ||
                                                  _dbContext.Reg_patients.Any(rg =>rg.pat_id == AB.Patient_ID && rg.mr_no_sequence != null && rg.mr_no_sequence.Contains(searchValue))
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
                                            Pharma_trans_Type = AB.Pharma_trans_Type,
                                            pharmacy_Department = _dbContext.GetDataValueName("Patient Main Category", AB.pharmacy_Department),
                                            WareHouse = _dbContext.GetDataValueName("Ware House", AB.Ware_House) ?? "",
                                            Status = AB.Status ?? "Created",
                                        };

                    var FilteredCount = IssueMedicine.Count();
                    switch (sortColumn)
                    {
                        
                        case "Patient_ID":
                            IssueMedicine = sortColumnDirection == "asc" ? IssueMedicine.OrderBy(b => b.Patient_ID) : IssueMedicine.OrderByDescending(a => a.Patient_ID);
                            break;
                        case "Invoice_Date":
                            IssueMedicine = sortColumnDirection == "asc" ? IssueMedicine.OrderBy(a => a.Invoice_Date) : IssueMedicine.OrderByDescending(a => a.Invoice_Date);
                            break;
                        default:
                            IssueMedicine = IssueMedicine.OrderByDescending(a => a.Bill_ID);
                            break;
                    }

                    var IssueMedicineLlist = IssueMedicine.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Billings, data = IssueMedicineLlist };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching IssueMedicine list", ex);
            }
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "IssueMedicineList";

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
                string pageName = "IssueMedicineList";

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