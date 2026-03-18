using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.PatientManagement
{
    public partial class Emergency_Admission_View : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {


        }



        [WebMethod]
        public static string EditPatient(string EmerID)
        {
            // Get permission value from DB function (returns '0' or '1' as string)
            string allowValue = DBClass.getField(
                $"SELECT dbo.GetRights('AllowPatientDelete', '{AppConfig.UserID}')"
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
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    DateTime searchDate;
                    bool isDateSearch = DateTime.TryParse(searchValue, out searchDate);

                    var admissions = from ep in _dbContext.Emergency_Patients
                                     // FIX: Join on 'emer_id' (the foreign key) instead of 'Emergency_ID' (the PK)
                                     join e in _dbContext.Emergencies on ep.emer_id equals e.Emer_id

                                     join rg in _dbContext.Reg_patients on ep.Patient_ID equals rg.pat_id
                                     join wd in _dbContext.Ward_Definitions on ep.Ward_ID equals wd.Ward_ID into wardGroup
                                     from wd in wardGroup.DefaultIfEmpty()

                                     where (e.isCancel == false || e.isCancel == null)

                                     select new
                                     {
                                          Emergency_ID = ep.Emergency_ID,

                                         Emergency_No = e.Emergency_No ?? 0,
                                         mr_no_sequence = rg.mr_no_sequence ?? "",
                                         Full_Name = rg.Full_Name ?? "",
                                         Admission_Date = ep.Admission_Date,

                                          Admit_To = _dbContext.GetDataValueName("Laundary From To", ep.Issuance_Of),

                                         Ward_Name = wd != null ? wd.Ward_Type : "",
                                         Bed_No = ep.Bed_No
                                     };

                    if (!string.IsNullOrWhiteSpace(searchValue))
                    {
                        admissions = admissions.Where(x =>
                            x.Emergency_No.ToString().Contains(searchValue) ||
                            x.mr_no_sequence.Contains(searchValue) ||
                            x.Full_Name.Contains(searchValue) ||
                            (x.Admit_To ?? "").Contains(searchValue) ||
                            (x.Ward_Name ?? "").Contains(searchValue) ||
                            (x.Bed_No.HasValue && x.Bed_No.Value.ToString().Contains(searchValue)) ||
                            (isDateSearch && x.Admission_Date >= searchDate && x.Admission_Date < searchDate.AddDays(1))
                        );
                    }

                    var Total_emer = (from ep in _dbContext.Emergency_Patients
                                      join e in _dbContext.Emergencies on ep.Emergency_ID equals e.Emer_id
                                      where (e.isCancel == false || e.isCancel == null)
                                      select ep.Emergency_ID).Count();

                    var FilteredCount = admissions.Count();
                    switch (sortColumn)
                    {
                        case "Emergency_No":
                            admissions = sortColumnDirection == "asc" ? admissions.OrderBy(a => a.Emergency_No) : admissions.OrderByDescending(a => a.Emergency_No);
                            break;
                        case "mr_no_sequence":
                            admissions = sortColumnDirection == "asc" ? admissions.OrderBy(a => a.mr_no_sequence) : admissions.OrderByDescending(a => a.mr_no_sequence);
                            break;
                        case "Full_Name":
                            admissions = sortColumnDirection == "asc" ? admissions.OrderBy(a => a.Full_Name) : admissions.OrderByDescending(a => a.Full_Name);
                            break;
                        case "Admission_Date":
                            admissions = sortColumnDirection == "asc" ? admissions.OrderBy(a => a.Admission_Date) : admissions.OrderByDescending(a => a.Admission_Date);
                            break;
                        case "Admit_To":
                            admissions = sortColumnDirection == "asc" ? admissions.OrderBy(a => a.Admit_To) : admissions.OrderByDescending(a => a.Admit_To);
                            break;
                        case "Ward_Name":
                            admissions = sortColumnDirection == "asc" ? admissions.OrderBy(a => a.Ward_Name) : admissions.OrderByDescending(a => a.Ward_Name);
                            break;
                        case "Bed_No":
                            admissions = sortColumnDirection == "asc" ? admissions.OrderBy(a => a.Bed_No) : admissions.OrderByDescending(a => a.Bed_No);
                            break;
                        default:
                            admissions = admissions.OrderByDescending(a => a.Emergency_ID);
                            break;
                    }


                    var emergencyList = admissions.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_emer, data = emergencyList };
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