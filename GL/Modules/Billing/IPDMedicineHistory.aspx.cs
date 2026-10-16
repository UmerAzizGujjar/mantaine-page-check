using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Billing
{
    public partial class IPDMedicineHistory : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    searchValue = (searchValue ?? "").Trim();
                    int searchPatId;
                    bool searchIsId = int.TryParse(searchValue, out searchPatId);

                    // Filter on the core joins only; ward is a left join resolved for the page rows below.
                    var baseQuery = from ipm in db.In_Patient_Medicines
                                    join ipd in db.In_Patients
                                     on ipm.Patient_ID equals ipd.In_Patient_ID
                                    join rp in db.Reg_patients
                                     on ipd.Patient_ID equals rp.pat_id
                                    where (ipm.Req_Qty ?? 0) > 0
                                          && ipm.Transaction_Type == "InPatient"
                                          && (searchValue == ""
                                                || (rp.Full_Name != null && rp.Full_Name.Contains(searchValue))
                                                || (rp.Father_Name != null && rp.Father_Name.Contains(searchValue))
                                                || (rp.mr_no_sequence != null && rp.mr_no_sequence.Contains(searchValue))
                                                || (ipm.Medicine_Name != null && ipm.Medicine_Name.Contains(searchValue))
                                                || (searchIsId && rp.pat_id == searchPatId))
                                    select new { ipm, ipd, rp };

                    var TotalRecords = baseQuery.Count();

                    bool asc = sortColumnDirection == "asc";
                    switch (sortColumn)
                    {
                        case "mr_no_sequence":
                            baseQuery = asc ? baseQuery.OrderBy(x => x.rp.mr_no_sequence) : baseQuery.OrderByDescending(x => x.rp.mr_no_sequence);
                            break;
                        case "Medicine_Date":
                            baseQuery = asc ? baseQuery.OrderBy(x => x.ipm.Medicine_Date) : baseQuery.OrderByDescending(x => x.ipm.Medicine_Date);
                            break;
                        case "Full_Name":
                            baseQuery = asc ? baseQuery.OrderBy(x => x.rp.Full_Name) : baseQuery.OrderByDescending(x => x.rp.Full_Name);
                            break;
                        case "Request_Time":
                            baseQuery = asc ? baseQuery.OrderBy(x => x.ipm.Request_Time) : baseQuery.OrderByDescending(x => x.ipm.Request_Time);
                            break;
                        case "Issue_Date":
                            baseQuery = asc ? baseQuery.OrderBy(x => x.ipm.Issue_Date) : baseQuery.OrderByDescending(x => x.ipm.Issue_Date);
                            break;
                        case "Receive_Time":
                            baseQuery = asc ? baseQuery.OrderBy(x => x.ipm.Receive_Time) : baseQuery.OrderByDescending(x => x.ipm.Receive_Time);
                            break;
                        default:
                            baseQuery = baseQuery.OrderByDescending(x => x.ipm.In_Patient_Medicine_ID);
                            break;
                    }

                    var MedicineHistoryList = (from x in baseQuery.Skip(start).Take(length)
                                               join wd in db.Ward_Definitions
                                                   on x.ipd.Ward_ID equals wd.Ward_ID into wdGroup
                                               from wd in wdGroup.DefaultIfEmpty()
                                               select new
                                               {
                                                   x.ipm.In_Patient_Medicine_ID,
                                                   x.ipm.Item_Code,
                                                   x.ipd.In_Patient_ID,
                                                   x.rp.pat_id,
                                                   x.rp.Full_Name,
                                                   x.rp.Father_Name,
                                                   x.rp.mr_no_sequence,
                                                   x.ipm.Medicine_Date,
                                                   x.ipm.Transaction_Type,
                                                   x.ipm.Rcv_Qty,
                                                   x.ipm.Rtn_Qty,
                                                   x.ipm.Status,
                                                   x.ipm.is_rejected,
                                                   Ward_Name = wd.Ward_Type,
                                                   x.ipd.Bed_No,
                                                   x.ipm.Medicine_Name,
                                                   x.ipm.Req_Qty,
                                                   x.ipm.Issue_Rcvd_Qty,
                                                   x.ipm.Request_Time,
                                                   x.ipm.Issue_Date,
                                                   x.ipm.Receive_Time,
                                               }).ToList();

                    var jsonData = new
                    {
                        draw = draw,
                        recordsFiltered = TotalRecords,
                        recordsTotal = TotalRecords,
                        data = MedicineHistoryList
                    };

                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Medicine History list", ex);
            }
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "IPDMedicineHistory";

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
                string pageName = "IPDMedicineHistory";

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