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
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Billings = _dbContext.Ar_Billings.Count();
                    var IssueMedicine = from AB in _dbContext.Ar_Billings
                                        where (AB.IsPharmacy == true &&
                                            ((AB.Customer_Name.ToString().Contains(searchValue) || AB.Referred_By_value.ToString().Contains(searchValue) || AB.Received_Amount.ToString().Contains(searchValue))))


                                        select new
                                        {
                                            BillNo = AB.Invoice_No + "-" + AB.Invoice_Date + "-" + AB.Invoice_Date,
                                            Invoice_Date = AB.Invoice_Date,
                                            Customer_Name = AB.Customer_Name,
                                            Referred_By_value = AB.Referred_By_value,
                                            Patient_ID = AB.Patient_ID,
                                            Received_Amount = AB.Received_Amount,
                                            Bill_ID = AB.Bill_ID,
                                        };

                    var FilteredCount = IssueMedicine.Count();
                    switch (sortColumn)
                    {
                        case "Bill_ID":
                            IssueMedicine = sortColumnDirection == "asc" ? IssueMedicine.OrderBy(a => a.Bill_ID) : IssueMedicine.OrderByDescending(a => a.Bill_ID);
                            break;
                        case "Patient_ID":
                            IssueMedicine = sortColumnDirection == "asc" ? IssueMedicine.OrderBy(b => b.Patient_ID) : IssueMedicine.OrderByDescending(a => a.Patient_ID);
                            break;
                        case "Invoice_Date":
                            IssueMedicine = sortColumnDirection == "asc" ? IssueMedicine.OrderBy(a => a.Invoice_Date) : IssueMedicine.OrderByDescending(a => a.Invoice_Date);
                            break;
                        default:
                            IssueMedicine = IssueMedicine.OrderBy(a => a.Bill_ID);
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
    }

}