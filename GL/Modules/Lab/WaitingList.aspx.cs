using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Lab
{
    public partial class WaitingList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static object GetRadiologyAcknowledgment(int draw, int start, int length, string sortColumn, string sortDirection, string searchValue, string mainDepartmentFilter, string statusFilter, string doctorFilter)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var query = from pat in db.Reg_patients
                        join bill in db.Ar_Billings on pat.pat_id equals bill.Patient_ID
                        join bill_details in db.Ar_Billing_Details on bill.Bill_ID equals bill_details.Bill_ID
                        join labtest_detail in db.Lab_Test_Details on bill_details.Bill_Details_ID equals labtest_detail.Bill_Details_ID
                        join lbt in db.Laboratory_Tests on labtest_detail.Lab_Test_ID equals lbt.Lab_Test_ID
                        where lbt.System_Generated == true
                              && bill_details.Test_Main_Department != "001"
                              && (bill.isCancel == false || bill.isCancel == null)
                              && bill.Bill_Date.HasValue && bill.Bill_Date.Value.Date == DateTime.Now.Date
                        orderby bill.Bill_Date ascending
                        let test = (from t in db.Lab_Tests where t.Test_ID == labtest_detail.Test_ID select t).FirstOrDefault()
                        let doctorId = bill_details.Doctor_id != null && bill_details.Doctor_id != "" ? Convert.ToInt32(bill_details.Doctor_id) : (int?)null
                        let doctorName = doctorId.HasValue ? (from emp in db.HR_Employees where emp.Emp_ID == doctorId.Value select emp.Emp_Name).FirstOrDefault() : null
                        select new
                        {
                            MrNo = pat.mr_no_sequence,
                            Name = pat.Full_Name,
                            BillNo = bill.Bill_No,
                            BillDate = bill.Bill_Date,
                            TestName = bill_details.Item_Name,
                            Main_Department = test.Main_Department,
                            Department = db.GetDataValueName("Test Main Department", test.Main_Department),
                            DoctorID = doctorId,
                            DoctorName = doctorName ?? "No Assigned Doctor",
                            bill_details.Bill_Details_ID,
                            labtest_detail.Lab_Test_Detail_ID,
                            bill_details.ParentTrans_Name,
                            IsAcknowledge = labtest_detail.IsAcknowledge ?? false,
                            IsApproved = labtest_detail.isApproved ?? false,
                            History = labtest_detail.History,
                            Priorities = labtest_detail.Priorities,
                            WaitingTime = test.WaitingTime.HasValue ? test.WaitingTime.Value.ToString() : "0"
                        };

             var queryList = query.ToList();

            if (!string.IsNullOrEmpty(mainDepartmentFilter) && mainDepartmentFilter != "All")
            {
                queryList = queryList.Where(x => x.Main_Department == mainDepartmentFilter).ToList();
            }

            if (!string.IsNullOrEmpty(doctorFilter) && doctorFilter != "All")
            {
                int docId = Convert.ToInt32(doctorFilter);
                queryList = queryList.Where(x => x.DoctorID == docId).ToList();
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

            if (!string.IsNullOrEmpty(searchValue))
            {
                queryList = queryList.Where(x =>
                    x.Name.Contains(searchValue) ||
                    x.MrNo.Contains(searchValue) ||
                    x.BillNo.Contains(searchValue) ||
                    x.TestName.Contains(searchValue)
                ).ToList();
            }

            switch (sortColumn)
            {
                case "MrNo":
                    queryList = sortDirection == "asc" ? queryList.OrderBy(x => x.MrNo).ToList() : queryList.OrderByDescending(x => x.MrNo).ToList();
                    break;
                case "Name":
                    queryList = sortDirection == "asc" ? queryList.OrderBy(x => x.Name).ToList() : queryList.OrderByDescending(x => x.Name).ToList();
                    break;
                case "BillNo":
                    queryList = sortDirection == "asc" ? queryList.OrderBy(x => x.BillNo).ToList() : queryList.OrderByDescending(x => x.BillNo).ToList();
                    break;
                case "BillDate":
                    queryList = sortDirection == "asc" ? queryList.OrderBy(x => x.BillDate).ToList() : queryList.OrderByDescending(x => x.BillDate).ToList();
                    break;
                case "TestName":
                    queryList = sortDirection == "asc" ? queryList.OrderBy(x => x.TestName).ToList() : queryList.OrderByDescending(x => x.TestName).ToList();
                    break;
                case "Department":
                    queryList = sortDirection == "asc" ? queryList.OrderBy(x => x.Department).ToList() : queryList.OrderByDescending(x => x.Department).ToList();
                    break;
                case "DoctorName":
                    queryList = sortDirection == "asc" ? queryList.OrderBy(x => x.DoctorName).ToList() : queryList.OrderByDescending(x => x.DoctorName).ToList();
                    break;
                default:
                    queryList = queryList.OrderBy(x => x.BillDate).ToList();
                    break;
            }

            // Calculate total waiting time
            int totalWaitingMinutes = queryList.Sum(x => {
                int waitMinutes = 0;
                if (!string.IsNullOrEmpty(x.WaitingTime))
                {
                    int.TryParse(x.WaitingTime, out waitMinutes);
                }
                return waitMinutes;
            });

            int totalHours = totalWaitingMinutes / 60;
            int remainingMinutes = totalWaitingMinutes % 60;
            string formattedWaitingTime = $"{totalHours} hours {remainingMinutes} minutes";

            int totalRecords = queryList.Count();
            var finalList = queryList.Skip(start).Take(length).ToList();

            return new
            {
                draw = draw,
                recordsTotal = totalRecords,
                recordsFiltered = totalRecords,
                data = finalList,
                totalWaitingTime = formattedWaitingTime,
                totalWaitingMinutes = totalWaitingMinutes
            };
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
        public static string GetMainDepartments()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var departments = (from dv in db.DataValues
                                  join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                  where vs.ValueSet_Name == "Test Main Department"
                                  select new { dv.DataValue_Name, dv.DataValue_Description }).ToList();
                return (new JavaScriptSerializer()).Serialize(departments);
            }
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
                var user = AppConfig.UserID;
                foreach (var item in Testlist)
                {
                    int labTestDetailId = Convert.ToInt32(item.Lab_Test_Detail_ID);

                    var record = db.Lab_Test_Details.FirstOrDefault(x => x.Lab_Test_Detail_ID == labTestDetailId);
                    if (record != null)
                    {
                        record.Priorities = item.status;
                        record.IsAcknowledge = true;
                        record.Acknowledged_By = AppConfig.UserID;
                        record.Acknowledged_Time = DateTime.Now;
                        record.DoctorID = item.Doctor_ID;
                        record.History = item.History;
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
    }
}