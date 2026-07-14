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

                var query = from pat in db.Reg_patients
                            join bill in db.Ar_Billings on pat.pat_id equals bill.Patient_ID
                            join bill_details in db.Ar_Billing_Details on bill.Bill_ID equals bill_details.Bill_ID
                            join labtest_detail in db.Lab_Test_Details on bill_details.Bill_Details_ID equals labtest_detail.Bill_Details_ID
                            join lbt in db.Laboratory_Tests on labtest_detail.Lab_Test_ID equals lbt.Lab_Test_ID
                            where lbt.System_Generated == true
                                  && bill_details.Test_Main_Department != "001"
                                  && (bill.isCancel == false || bill.isCancel == null)
                                  && !db.Refunds.Any(r => r.Bill_ID == bill.Bill_ID)
                                  && bill.Bill_Date >= startDateTime
                                  && bill.Bill_Date < endDateTime
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
                                bill.Bill_Date,
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

                var queryList = query.ToList();

                

                if (!string.IsNullOrEmpty(ddlDoctorFilter) && ddlDoctorFilter != "0")
                {
                    int doctorId = Convert.ToInt32(ddlDoctorFilter);
                    queryList = queryList.Where(x =>
                    {
                        int displayDoctorId = (x.LabTest_DoctorID > 0) ? x.LabTest_DoctorID : x.Billing_DoctorID;
                        return displayDoctorId == doctorId;
                    }).ToList();
                }

                if (!string.IsNullOrEmpty(mainDepartmentFilter) && mainDepartmentFilter != "All")
                {
                    if (mainDepartmentFilter == "WalkIn")
                    {
                        queryList = queryList.Where(x => string.IsNullOrEmpty(x.ParentTrans_Name)).ToList();
                    }
                    else
                    {
                        queryList = queryList.Where(x => x.ParentTrans_Name == mainDepartmentFilter).ToList();
                    }
                }

                if (!string.IsNullOrEmpty(statusFilter) && statusFilter != "All")
                {
                    if (statusFilter == "Approved")
                    {
                        queryList = queryList.Where(x => x.IsApproved == true).ToList();
                    }
                    else if (statusFilter == "NotApproved")
                    {
                        queryList = queryList.Where(x => x.IsApproved == false || x.IsApproved == null).ToList();
                    }
                    else if (statusFilter == "Acknowledged")
                    {
                        queryList = queryList.Where(x => x.IsAcknowledge == true && (x.IsApproved == false || x.IsApproved == null)).ToList();
                    }
                }

                if (!string.IsNullOrEmpty(mainTestDepartmentFilter) && mainTestDepartmentFilter != "All")
                {
                    queryList = queryList.Where(x => x.RawTestDeptCode == mainTestDepartmentFilter).ToList();
                }

                if (!string.IsNullOrEmpty(searchValue))
                {
                    queryList = queryList.Where(x =>
                        (x.Full_Name != null && x.Full_Name.ToLower().Contains(searchValue.ToLower())) ||
                        (x.Bill_No != null && x.Bill_No.ToLower().Contains(searchValue.ToLower())) ||
                        (x.mr_no_sequence != null && x.mr_no_sequence.ToLower().Contains(searchValue.ToLower())) ||
                        (x.Item_Name != null && x.Item_Name.ToLower().Contains(searchValue.ToLower()))
                    ).ToList();
                }

                int totalRecords = queryList.Count();

                if (length > 100000) 
                {
                    start = 0;
                    length = totalRecords;
                }

                switch (sortColumn)
                {
                    case "Bill_No":
                        queryList = sortDirection == "asc" ? queryList.OrderBy(x => x.Bill_No).ToList() : queryList.OrderByDescending(x => x.Bill_No).ToList();
                        break;
                    case "Full_Name":
                        queryList = sortDirection == "asc" ? queryList.OrderBy(x => x.Full_Name).ToList() : queryList.OrderByDescending(x => x.Full_Name).ToList();
                        break;
                    case "mr_no_sequence":
                        queryList = sortDirection == "asc" ? queryList.OrderBy(x => x.mr_no_sequence).ToList() : queryList.OrderByDescending(x => x.mr_no_sequence).ToList();
                        break;
                    case "Bill_Date":
                        queryList = sortDirection == "asc" ? queryList.OrderBy(x => x.Bill_Date).ToList() : queryList.OrderByDescending(x => x.Bill_Date).ToList();
                        break;
                    case "Department":
                        queryList = sortDirection == "asc" ? queryList.OrderBy(x => x.Department).ToList() : queryList.OrderByDescending(x => x.Department).ToList();
                        break;
                    default:
                        queryList = queryList.OrderByDescending(x => x.Bill_Date).ToList();
                        break;
                }

                var finalList = queryList.Skip(start).Take(length).ToList();

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