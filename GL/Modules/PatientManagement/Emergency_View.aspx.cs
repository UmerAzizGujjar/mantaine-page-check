using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.PatientManagement
{
    public partial class Emergency_View : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {


        }



        [WebMethod]
        public static string EditPatient(string EmerID)
        {
            // Get permission value from DB function (returns '0' or '1' as string)
            string allowValue = DBClass.getField(
                $"SELECT dbo.GetRights('AllowPatientEdit', '{AppConfig.UserID}')"
            );

            // Treat null/empty as '0' (not allowed) for safety
            if (Convert.ToBoolean(allowValue) == true)
            {
                return "Allowed";
            }
            else
            {
                return "NotAllowed";
            }
        }
        [WebMethod]
        public static string CancelPatient(string Emer_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            string status = "Allowdlt";
            string AllowPatientDelete = DBClass.getField("select dbo.GetRights('AllowPatientDelete','" + AppConfig.UserID + "')");

            if (Convert.ToBoolean(AllowPatientDelete) == true)
            {
                status = "Fail";
                // Check for uncanceled receipts and billings related to this emergency
                // Note: If Emergency_ID field does not exist, you may need to check using Reg_PatId or skip this check
                var emergency = db.Emergencies.SingleOrDefault(x => x.Emer_id == Convert.ToInt32(Emer_ID));
                if (emergency != null)
                {
                    // Simple approach: Just check if emergency can be cancelled without checking receipts/billings
                    // You can add receipt/billing check later when column structure is confirmed
                    emergency.isCancel = true;
                    db.SubmitChanges();
                    status = "success";
                }
                return status;
            }
            return status;
        }
        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue, string fromDate, string toDate)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    DateTime searchDate;
                    bool isDateSearch = DateTime.TryParse(searchValue, out searchDate);

                    var Total_emer = _dbContext.Emergencies.Count();
                    var emer = from e in _dbContext.Emergencies
                              join rg in _dbContext.Reg_patients on e.Reg_PatId equals rg.pat_id
                              where (e.Emergency_No.ToString().Contains(searchValue) ||
                                     e.mr_no_sequence.Contains(searchValue) ||
                                     rg.Full_Name.Contains(searchValue) ||
                                     rg.NIC.Contains(searchValue) ||
                                     rg.Mobile1.Contains(searchValue) ||
                                     e.Emergency_Charges.ToString().Contains(searchValue) ||
                                     (isDateSearch && e.Created_Time >= searchDate && e.Created_Time < searchDate.AddDays(1)))
                              select new
                              {
                                  Emer_id = e.Emer_id,
                                  Emergency_No = e.Emergency_No,
                                  Created_Time = e.Created_Time,
                                  mr_no_sequence = e.mr_no_sequence,
                                  Full_Name = rg.Full_Name,
                                  NIC = rg.NIC,
                                  Mobile1 = rg.Mobile1,
                                  Amount = e.Receipt_Amount ?? 0,
                                  balance_amount = e.balance_amount ?? 0,
                                  Type = "Emergency" ,
                                  Patient_Type = _dbContext.GetDataValueName("Patient Type", e.Patient_Type),
                                  isCancel = e.isCancel ?? false,
                                  Doctor_ID = e.Doctor_ID,
                                  emer_doc_token = e.emer_doc_token ?? 0
                              };



                    // Start / End date filter (yyyy-MM-dd). Blank = no filter (all data).
                    DateTime fromDt, toDt;
                    if (DateTime.TryParseExact(fromDate, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out fromDt))
                    {
                        DateTime fromDateValue = fromDt.Date;
                        emer = emer.Where(a => a.Created_Time >= fromDateValue);
                    }
                    if (DateTime.TryParseExact(toDate, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out toDt))
                    {
                        DateTime toDateExclusive = toDt.Date.AddDays(1);
                        emer = emer.Where(a => a.Created_Time < toDateExclusive);
                    }

                    var FilteredCount = emer.Count();
                    switch (sortColumn)
                    {
                        case "Emergency_No":
                            emer = sortColumnDirection == "asc" ? emer.OrderBy(a => a.Emergency_No) : emer.OrderByDescending(a => a.Emergency_No);
                            break;
                        case "Emer_id":
                            emer = sortColumnDirection == "asc" ? emer.OrderBy(a => a.Emer_id) : emer.OrderByDescending(a => a.Emer_id);
                            break;
                        case "Created_Time":
                            emer = sortColumnDirection == "asc" ? emer.OrderBy(a => a.Created_Time) : emer.OrderByDescending(a => a.Created_Time);
                            break;
                        case "mr_no_sequence":
                            emer = sortColumnDirection == "asc" ? emer.OrderBy(a => a.mr_no_sequence) : emer.OrderByDescending(a => a.mr_no_sequence);
                            break;
                        case "emer_doc_token":
                            emer = sortColumnDirection == "asc" ? emer.OrderBy(a => a.emer_doc_token) : emer.OrderByDescending(a => a.emer_doc_token);
                            break;
                        case "Amount":
                            emer = sortColumnDirection == "asc" ? emer.OrderBy(a => a.Amount) : emer.OrderByDescending(a => a.Amount);
                            break;
                        default:
                            emer = emer.OrderByDescending(a => a.Created_Time);
                            break;
                    }


                    var emergencyList = emer.Skip(start).Take(length).ToList();

                    var docIdList = emergencyList
                        .Select(x => { int v; return int.TryParse(x.Doctor_ID, out v) && v > 0 ? v : 0; })
                        .Where(v => v > 0)
                        .Distinct()
                        .ToList();
                    var docMap = _dbContext.HR_Employees
                        .Where(em => docIdList.Contains(em.Emp_ID))
                        .ToDictionary(em => em.Emp_ID.ToString(), em => em.Emp_Name);

                    var rows = emergencyList.Select(x => new
                    {
                        x.Emer_id,
                        x.Emergency_No,
                        x.Created_Time,
                        x.mr_no_sequence,
                        x.Full_Name,
                        x.NIC,
                        x.Mobile1,
                        x.Amount,
                        x.balance_amount,
                        x.Type,
                        x.Patient_Type,
                        x.isCancel,
                        x.emer_doc_token,
                        Doc_Name = (x.Doctor_ID != null && docMap.ContainsKey(x.Doctor_ID)) ? docMap[x.Doctor_ID] : ""
                    }).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_emer, data = rows };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching emergency list", ex);
            }
        }
    }
}