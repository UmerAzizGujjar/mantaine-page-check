using System;
using System.Collections.Generic;
using System.Data.Linq.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.PatientManagement
{
    public partial class BirthCertificateView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "Birth_Certificate";

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
        public static string GetGeneralItemsFiltered(string searchTerm, int page)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            int pageSize = 20;

            var query = from i in db.INV_Items
                        where i.Pharmacy_Item == false
                        && i.IsPharmacyItem == false
                        && i.Hospital_Services == false
                        && i.Services != true
                        && i.Book_ID == 1
                        select i;

            // Apply search filter if search term is provided (minimum 3 characters)
            if (!string.IsNullOrEmpty(searchTerm) && searchTerm.Length >= 3)
            {
                query = query.Where(i => i.Item_Code.Contains(searchTerm) ||
                                         i.Description.Contains(searchTerm));
            }
            else
            {
                // Return empty results if search term is less than 3 characters
                var emptyResult = new { results = new List<object>(), pagination = new { more = false } };
                return (new JavaScriptSerializer()).Serialize(emptyResult);
            }

            int totalCount = query.Count();
            bool hasMore = (page * pageSize) < totalCount;

            var items = query
                .OrderBy(i => i.Item_Code)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(i => new {
                    id = i.Item_ID,
                    text = i.Item_Code + " - " + i.Description  // IMPORTANT: Use 'text' property
                })
                .ToList();

            var result = new { results = items, pagination = new { more = hasMore } };
            return (new JavaScriptSerializer()).Serialize(result);
        }

        [WebMethod]
        public static string GetPharmacyItemsFiltered(string searchTerm, int page)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            int pageSize = 20;

            var query = from i in db.INV_Items
                        where (i.Pharmacy_Item == true || i.IsPharmacyItem == true)
                        && i.Services != true
                        && i.Hospital_Services == false
                        && i.Book_ID == 1
                        select i;

            // Apply search filter if search term is provided (minimum 3 characters)
            if (!string.IsNullOrEmpty(searchTerm) && searchTerm.Length >= 3)
            {
                query = query.Where(i => i.Item_Code.Contains(searchTerm) ||
                                         i.Description.Contains(searchTerm));
            }
            else
            {
                // Return empty results if search term is less than 3 characters
                var emptyResult = new { results = new List<object>(), pagination = new { more = false } };
                return (new JavaScriptSerializer()).Serialize(emptyResult);
            }

            int totalCount = query.Count();
            bool hasMore = (page * pageSize) < totalCount;

            var items = query
                .OrderBy(i => i.Item_Code)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(i => new {
                    id = i.Item_ID,
                    text = i.Item_Code + " - " + i.Description  // IMPORTANT: Use 'text' property
                })
                .ToList();

            var result = new { results = items, pagination = new { more = hasMore } };
            return (new JavaScriptSerializer()).Serialize(result);
        }
        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue, string fromDate, string toDate)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var baseQuery = from P in _dbContext.Reg_patients
                                    join IP in _dbContext.Birth_Certificates on P.pat_id equals IP.Patient_ID
                                    select new
                                    {
                                        In_Patient_ID = IP.Birth_Certificate_ID,
                                        Admission_Date = IP.Created_Time,
                                        mr_no_sequence = P.mr_no_sequence,
                                        Full_Name = IP.Child_Name,
                                        Father_Name = IP.Father_Name,
                                        Birth_Date = IP.Date_of_Birth,
                                        Created_By = IP.Created_By
                                    };

                    var Total_Patients = baseQuery.Count();

                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        baseQuery = baseQuery.Where(x =>
                            x.mr_no_sequence.Contains(searchValue) ||
                            x.Full_Name.Contains(searchValue) ||
                            x.Father_Name.Contains(searchValue));
                    }

                    // Start / End date filter (yyyy-MM-dd). Blank = no filter (all data).
                    DateTime fromDt, toDt;
                    if (DateTime.TryParseExact(fromDate, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out fromDt))
                    {
                        DateTime fromDateValue = fromDt.Date;
                        baseQuery = baseQuery.Where(a => a.Admission_Date >= fromDateValue);
                    }
                    if (DateTime.TryParseExact(toDate, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out toDt))
                    {
                        DateTime toDateExclusive = toDt.Date.AddDays(1);
                        baseQuery = baseQuery.Where(a => a.Admission_Date < toDateExclusive);
                    }

                    switch (sortColumn)
                    {
                        case "In_Patient_ID":
                            baseQuery = sortColumnDirection == "asc" ? baseQuery.OrderBy(a => a.In_Patient_ID) : baseQuery.OrderByDescending(a => a.In_Patient_ID);
                            break;
                        case "mr_no_sequence":
                            baseQuery = sortColumnDirection == "asc" ? baseQuery.OrderBy(b => b.mr_no_sequence) : baseQuery.OrderByDescending(b => b.mr_no_sequence);
                            break;
                        case "Admission_Date":
                            baseQuery = sortColumnDirection == "asc" ? baseQuery.OrderBy(b => b.Admission_Date) : baseQuery.OrderByDescending(b => b.Admission_Date);
                            break;
                        default:
                            baseQuery = baseQuery.OrderByDescending(a => a.In_Patient_ID);
                            break;
                    }

                    var FilteredCount = baseQuery.Count();
                    var patientList = baseQuery.Skip(start).Take(length).ToList();

                    var result = patientList.Select(p => new
                    {
                        In_Patient_ID = p.In_Patient_ID,
                        Admission_Date = p.Admission_Date,
                        mr_no_sequence = p.mr_no_sequence,
                        Full_Name = p.Full_Name,
                        Father_Name = p.Father_Name,
                        Birth_Date = p.Birth_Date,
                        Created_by = p.Created_By.HasValue ? Convert.ToString(_dbContext.getUserName(p.Created_By.Value.ToString())) : ""
                    }).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Patients, data = result };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("ViewList Error: " + ex.Message + " | " + ex.StackTrace);
                return new { draw = draw, recordsFiltered = 0, recordsTotal = 0, data = new List<object>() };
            }
        }


    }
}