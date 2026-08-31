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

                    var MedicineHistory = from ipm in db.In_Patient_Medicines
                                          join ipd in db.In_Patients
                                           on ipm.Patient_ID equals ipd.In_Patient_ID
                                          join rp in db.Reg_patients
                                           on ipd.Patient_ID equals rp.pat_id
                                          join wd in db.Ward_Definitions
                                              on ipd.Ward_ID equals wd.Ward_ID into wdGroup
                                          from wd in wdGroup.DefaultIfEmpty()
                                          where (ipm.Req_Qty ?? 0) > 0
                                                && ipm.Transaction_Type == "InPatient"
                                                && (string.IsNullOrEmpty(searchValue)|| (rp.Full_Name != null && rp.Full_Name.Contains(searchValue))
                                                        || (rp.Father_Name != null && rp.Father_Name.Contains(searchValue)) || rp.pat_id.ToString().Contains(searchValue)
                                                        || (rp.mr_no_sequence != null && rp.mr_no_sequence.Contains(searchValue))
                                                   )
                                          select new
                                          {
                                              ipm.In_Patient_Medicine_ID,
                                              ipm.Item_Code,
                                              ipd.In_Patient_ID,
                                              rp.pat_id,
                                              rp.Full_Name,
                                              rp.Father_Name,
                                              rp.mr_no_sequence,
                                              ipm.Medicine_Date,
                                              ipm.Transaction_Type,
                                               ipm.Rcv_Qty,
                                               ipm.Rtn_Qty,
                                               ipm.Status,
                                               ipm.is_rejected,
                                               Ward_Name = wd.Ward_Type,
                                              ipd.Bed_No,
                                              ipm.Medicine_Name,
                                              ipm.Req_Qty,
                                              ipm.Issue_Rcvd_Qty,
                                          };

                    var TotalRecords = MedicineHistory.Count();

                    switch (sortColumn)
                    {
                        case "mr_no_sequence":
                            MedicineHistory = sortColumnDirection == "asc"
                                ? MedicineHistory.OrderBy(x => x.mr_no_sequence)
                                : MedicineHistory.OrderByDescending(x => x.mr_no_sequence);
                            break;

                        case "Medicine_Date":
                            MedicineHistory = sortColumnDirection == "asc"
                                ? MedicineHistory.OrderBy(x => x.Medicine_Date)
                                : MedicineHistory.OrderByDescending(x => x.Medicine_Date);
                            break;

                        case "Full_Name":
                            MedicineHistory = sortColumnDirection == "asc"
                                ? MedicineHistory.OrderBy(x => x.Full_Name)
                                : MedicineHistory.OrderByDescending(x => x.Full_Name);
                            break;

                        default:
                            MedicineHistory = MedicineHistory.OrderByDescending(x => x.In_Patient_Medicine_ID);
                            break;
                    }

                    var MedicineHistoryList = MedicineHistory
                                                .Skip(start)
                                                .Take(length)
                                                .ToList();

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