using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web.Script.Serialization;
using System.Web.Services;

namespace PMS
{
    public partial class RadiologyAcknolgment : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static object GetRadiologyAcknowledgment(int draw, int start, int length, string sortColumn, string sortDirection, string searchValue, string mainDepartmentFilter, string statusFilter, string ddlDoctorFilter, string mainTestDepartmentFilter, string startDate, string endDate)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext();
                db.CommandTimeout = 120;

                DateTime startDateTime;
                DateTime endDateTime;

                if (string.IsNullOrEmpty(startDate) || string.IsNullOrEmpty(endDate))
                {
                    endDateTime = DateTime.Now.Date.AddDays(1);
                    startDateTime = DateTime.Now.Date.AddDays(-1);
                }
                else
                {
                    startDateTime = DateTime.ParseExact(startDate, "dd-MM-yyyy", CultureInfo.InvariantCulture);
                    endDateTime = DateTime.ParseExact(endDate, "dd-MM-yyyy", CultureInfo.InvariantCulture).AddDays(1);
                }

                // STEP 1 - lean query: only the joins + filters + sort + paging run in SQL, returning just the ids of the page.
                // (Before, every row in the date range was loaded with several per-row sub-queries, then filtered/sorted in memory.)
                var lean = from pat in db.Reg_patients
                           join bill in db.Ar_Billings on pat.pat_id equals bill.Patient_ID
                           join bill_details in db.Ar_Billing_Details on bill.Bill_ID equals bill_details.Bill_ID
                           join labtest_detail in db.Lab_Test_Details on bill_details.Bill_Details_ID equals labtest_detail.Bill_Details_ID
                           join lbt in db.Laboratory_Tests on labtest_detail.Lab_Test_ID equals lbt.Lab_Test_ID
                           where lbt.System_Generated == true
                                 && bill_details.Test_Main_Department != "001"
                                 && (bill.isCancel == false || bill.isCancel == null)
                                 && (bill_details.Is_Refunded == false || bill_details.Is_Refunded == null)
                                 && bill.Creation_Date >= startDateTime
                                 && bill.Creation_Date < endDateTime
                           select new
                           {
                               PatId = pat.pat_id,
                               Lab_Test_Detail_ID = labtest_detail.Lab_Test_Detail_ID,
                               Bill_Date = bill.Creation_Date,
                               bill.Bill_No,
                               pat.Full_Name,
                               pat.mr_no_sequence,
                               bill_details.Item_Name,
                               bill_details.ParentTrans_Name,
                               bill_details.Test_Main_Department,
                               Billing_Doctor = bill_details.Doctor_id,
                               LabDoctor = labtest_detail.DoctorID,
                               Ack = labtest_detail.IsAcknowledge,
                               Appr = labtest_detail.isApproved
                           };

                if (!string.IsNullOrEmpty(ddlDoctorFilter) && ddlDoctorFilter != "0")
                {
                    int doctorId = Convert.ToInt32(ddlDoctorFilter);
                    string doctorIdText = doctorId.ToString();
                    // shown doctor = lab-test doctor when set (> 0), otherwise the billing doctor
                    lean = lean.Where(x => (x.LabDoctor ?? 0) == doctorId
                                           || ((x.LabDoctor ?? 0) <= 0 && x.Billing_Doctor == doctorIdText));
                }

                if (!string.IsNullOrEmpty(mainDepartmentFilter) && mainDepartmentFilter != "All")
                {
                    if (mainDepartmentFilter == "WalkIn")
                    {
                        lean = lean.Where(x => x.ParentTrans_Name == null || x.ParentTrans_Name == "");
                    }
                    else
                    {
                        lean = lean.Where(x => x.ParentTrans_Name == mainDepartmentFilter);
                    }
                }

                if (!string.IsNullOrEmpty(statusFilter) && statusFilter != "All")
                {
                    if (statusFilter == "Approved")
                    {
                        lean = lean.Where(x => x.Appr == true);
                    }
                    else if (statusFilter == "NotApproved")
                    {
                        lean = lean.Where(x => x.Appr == false || x.Appr == null);
                    }
                    else if (statusFilter == "Acknowledged")
                    {
                        lean = lean.Where(x => x.Ack == true && (x.Appr == false || x.Appr == null));
                    }
                }

                if (!string.IsNullOrEmpty(mainTestDepartmentFilter) && mainTestDepartmentFilter != "All")
                {
                    lean = lean.Where(x => x.Test_Main_Department == mainTestDepartmentFilter);
                }

                if (!string.IsNullOrEmpty(searchValue))
                {
                    string term = searchValue.Trim();
                    lean = lean.Where(x =>
                        x.Full_Name.Contains(term) ||
                        x.Bill_No.Contains(term) ||
                        x.mr_no_sequence.Contains(term) ||
                        x.Item_Name.Contains(term));
                }

                int totalRecords = lean.Count();

                if (length > 100000)
                {
                    start = 0;
                    length = totalRecords;
                }

                bool asc = sortDirection == "asc";
                var ordered = lean.OrderByDescending(x => x.Bill_Date);
                switch (sortColumn)
                {
                    case "Bill_No":
                        ordered = asc ? lean.OrderBy(x => x.Bill_No) : lean.OrderByDescending(x => x.Bill_No);
                        break;
                    case "Full_Name":
                        ordered = asc ? lean.OrderBy(x => x.Full_Name) : lean.OrderByDescending(x => x.Full_Name);
                        break;
                    case "mr_no_sequence":
                        ordered = asc ? lean.OrderBy(x => x.mr_no_sequence) : lean.OrderByDescending(x => x.mr_no_sequence);
                        break;
                    case "Bill_Date":
                        ordered = asc ? lean.OrderBy(x => x.Bill_Date) : lean.OrderByDescending(x => x.Bill_Date);
                        break;
                    case "Department":
                        // the department only exists as a per-patient sub-query, so it is evaluated just for this sort
                        ordered = asc
                            ? lean.OrderBy(x => (from ipd in db.In_Patients where ipd.Patient_ID == x.PatId orderby ipd.In_Patient_ID descending select ipd.Department).FirstOrDefault()
                                                ?? (from emg in db.Emergency_Patients where emg.Patient_ID == x.PatId orderby emg.Emergency_ID descending select emg.Department).FirstOrDefault()
                                                ?? (from p2 in db.Patients where p2.Patient_ID == x.PatId select p2.Patient_Main_Category).FirstOrDefault())
                            : lean.OrderByDescending(x => (from ipd in db.In_Patients where ipd.Patient_ID == x.PatId orderby ipd.In_Patient_ID descending select ipd.Department).FirstOrDefault()
                                                ?? (from emg in db.Emergency_Patients where emg.Patient_ID == x.PatId orderby emg.Emergency_ID descending select emg.Department).FirstOrDefault()
                                                ?? (from p2 in db.Patients where p2.Patient_ID == x.PatId select p2.Patient_Main_Category).FirstOrDefault());
                        break;
                }
                // unique tie-breaker so paging is stable
                ordered = ordered.ThenBy(x => x.Lab_Test_Detail_ID);

                var pageIds = ordered.Skip(start).Take(length).Select(x => x.Lab_Test_Detail_ID).ToList();

                // STEP 2 - the full projection (ward / bed / department / panel / names) only for the rows of this page.
                // Chunked so a big "All" page never exceeds SQL Server's 2100-parameter limit.
                var byId = new Dictionary<string, object>();
                for (int i = 0; i < pageIds.Count; i += 1000)
                {
                    var chunk = pageIds.Skip(i).Take(1000).ToList();

                    var detail = from pat in db.Reg_patients
                                 join bill in db.Ar_Billings on pat.pat_id equals bill.Patient_ID
                                 join bill_details in db.Ar_Billing_Details on bill.Bill_ID equals bill_details.Bill_ID
                                 join labtest_detail in db.Lab_Test_Details on bill_details.Bill_Details_ID equals labtest_detail.Bill_Details_ID
                                 where chunk.Contains(labtest_detail.Lab_Test_Detail_ID)
                                 let dept = (from ipd in db.In_Patients
                                             where ipd.Patient_ID == pat.pat_id
                                             orderby ipd.In_Patient_ID descending
                                             select ipd.Department).FirstOrDefault()
                                           ?? (from emg in db.Emergency_Patients
                                               where emg.Patient_ID == pat.pat_id
                                               orderby emg.Emergency_ID descending
                                               select emg.Department).FirstOrDefault()
                                           ?? (from p2 in db.Patients
                                               where p2.Patient_ID == pat.pat_id
                                               select p2.Patient_Main_Category).FirstOrDefault()
                                 let emergencyRec = (from emg in db.Emergency_Patients
                                                     where emg.Patient_ID == pat.pat_id
                                                     orderby emg.Emergency_ID descending
                                                     select emg).FirstOrDefault()
                                 let inPatientRec = (from ipd in db.In_Patients
                                                     where ipd.Patient_ID == pat.pat_id
                                                     orderby ipd.In_Patient_ID descending
                                                     select ipd).FirstOrDefault()
                                 let activeWardId = (emergencyRec != null ? (int?)emergencyRec.Ward_ID : (inPatientRec != null ? (int?)inPatientRec.Ward_ID : null))
                                 let activeBedNo = (emergencyRec != null ? (int?)emergencyRec.Bed_No : (inPatientRec != null ? (int?)inPatientRec.Bed_No : null))
                                 let wardName = (activeWardId != null ? (from w in db.Ward_Definitions where w.Ward_ID == activeWardId select w.Ward_Type).FirstOrDefault() : null)
                                 select new
                                 {
                                     Bill_Date = bill.Creation_Date,
                                     bill.Bill_No,
                                     bill.Bill_ID,
                                     bill_details.Item_Name,
                                     pat.Full_Name,
                                     pat.mr_no_sequence,
                                     bill_details.Bill_Details_ID,
                                     Main_Test_Departments = db.GetDataValueName("Main Test Departments", bill_details.Test_Main_Department),
                                     labtest_detail.Lab_Test_Detail_ID,
                                     Department = db.GetDataValueName("Patient Main Category", dept),
                                     Main_Department = db.GetDataValueName("Mode Of Registration", bill.Main_Department),
                                     bill_details.ParentTrans_Name,
                                     bill_details.Net_Amount,
                                     DoctorID = labtest_detail.DoctorID ?? (bill_details.Doctor_id != null && bill_details.Doctor_id != "" ? Convert.ToInt32(bill_details.Doctor_id) : 0),
                                     LabTest_DoctorID = labtest_detail.DoctorID ?? 0,
                                     Billing_DoctorID = (bill_details.Doctor_id != null && bill_details.Doctor_id != "" ? Convert.ToInt32(bill_details.Doctor_id) : 0),
                                     IsAcknowledge = labtest_detail.IsAcknowledge ?? false,
                                     IsApproved = labtest_detail.isApproved ?? false,
                                     History = labtest_detail.History,
                                     Priorities = labtest_detail.Priorities,
                                     WardName = wardName ?? "",
                                     BedNo = (activeBedNo != null ? activeBedNo.Value.ToString() : ""),
                                     RawTestDeptCode = bill_details.Test_Main_Department,
                                     Panel = bill.Panel_Id,
                                     Panel_Name = db.Panels.Where(p => p.Panel_ID == bill.Panel_Id).Select(p => p.Company_Name).FirstOrDefault(),
                                 };

                    foreach (var row in detail)
                    {
                        byId[row.Lab_Test_Detail_ID.ToString()] = row;
                    }
                }

                // keep the order chosen in step 1
                var finalList = new List<object>();
                foreach (int id in pageIds)
                {
                    object row;
                    if (byId.TryGetValue(id.ToString(), out row))
                    {
                        finalList.Add(row);
                    }
                }

                return new
                {
                    draw = draw,
                    recordsTotal = totalRecords,
                    recordsFiltered = totalRecords,
                    data = finalList
                };
            }
            catch (Exception ex)
            {
                return new
                {
                    draw = draw,
                    recordsTotal = 0,
                    recordsFiltered = 0,
                    data = new List<object>(),
                    error = ex.Message
                };
            }
        }

        [WebMethod]
        public static string GetDoctors()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var doctorList = (from emp in db.HR_Employees
                                  where emp.Resign_Date == null && emp.IsDoctor == true
                                  select new { emp.Emp_ID, emp.Emp_Name }).ToList();
                return (new JavaScriptSerializer()).Serialize(doctorList);
            }
        }

        [WebMethod]
        public static bool CheckTestAmount(int Bill_ID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                decimal balance = db.Ar_Billings
                                    .Where(x => x.Bill_ID == Bill_ID)
                                    .Select(x => x.Balance_Amount ?? 0)
                                    .FirstOrDefault();

                return balance <= 0;   // true = allowed, false = balance pending
            }
        }

        [WebMethod]
        public static string loadDoctorsforFilter()
        {
            string result = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            var itemsList = (from i in db.HR_Employees
                             where i.Resign_Date == null
                             select new { i.Emp_ID, name = i.Emp_Name.ToString() }).ToList();
            if (itemsList != null)
            {
                result = (new JavaScriptSerializer()).Serialize(itemsList);
            }
            return result;
        }

        public class Testlist
        {
            public string status { get; set; }
            public string Lab_Test_Detail_ID { get; set; }
            public int Doctor_ID { get; set; }
            public string History { get; set; }
        }

        [WebMethod]
        public static string SaveRecord(List<Testlist> Testlist)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext();

                foreach (var item in Testlist)
                {
                    int labTestDetailId = Convert.ToInt32(item.Lab_Test_Detail_ID);

                    // Update Lab_Test_Details
                    var record = db.Lab_Test_Details.FirstOrDefault(x => x.Lab_Test_Detail_ID == labTestDetailId);
                    if (record != null)
                    {
                        record.Priorities = item.status;
                        record.IsAcknowledge = true;
                        record.Acknowledged_By = AppConfig.UserID;
                        record.Acknowledged_Time = DateTime.Now;
                        record.DoctorID = item.Doctor_ID;

                        // Append to history instead of replacing
                        if (!string.IsNullOrEmpty(item.History))
                        {
                            string timestamp = DateTime.Now.ToString("dd-MM-yyyy HH:mm:ss");
                            string newHistoryEntry = $"[{timestamp}] {item.History}";

                            if (string.IsNullOrEmpty(record.History))
                            {
                                record.History = newHistoryEntry;
                            }
                            else
                            {
                                record.History = record.History + Environment.NewLine + newHistoryEntry;
                            }
                        }

                        // Update Ar_Billing_Details with the same Doctor_ID
                        var billDetailsId = record.Bill_Details_ID;
                        if (billDetailsId.HasValue)
                        {
                            var billingDetail = db.Ar_Billing_Details.FirstOrDefault(x => x.Bill_Details_ID == billDetailsId.Value);
                            if (billingDetail != null && item.Doctor_ID > 0)
                            {
                                billingDetail.Doctor_id = item.Doctor_ID.ToString();
                            }
                        }
                    }
                }
                db.SubmitChanges();
                return "Update Data";
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        [WebMethod]
        public static string FillTestMainDepartment()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var dpt = (from d in db.DataValues
                       join v in db.ValueSets
                       on d.ValueSet_ID equals v.ValueSet_ID
                       where v.ValueSet_Name == "Main Test Departments"
                       select new
                       {
                           d.DataValue_Name,
                           d.DataValue_Description
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "RadiologyAcknowledgementlist";

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
                string pageName = "RadiologyAcknowledgementlist";

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
