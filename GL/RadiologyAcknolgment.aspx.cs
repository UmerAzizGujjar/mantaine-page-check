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
    public partial class RadiologyAcknolgment : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static object GetRadiologyAcknowledgment(int draw, int start, int length, string sortColumn, string sortDirection, string searchValue)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            //var query = (
            //    from pat in db.Reg_patients
            //    join bill in db.Ar_Billings on pat.pat_id equals bill.Patient_ID
            //    join bill_details in db.Ar_Billing_Details on bill.Bill_ID equals bill_details.Bill_ID
            //    join labtest_detail in db.Lab_Test_Details on bill_details.Bill_Details_ID equals labtest_detail.Bill_Details_ID
            //    join lbt in db.Laboratory_Tests on labtest_detail.Lab_Test_ID equals lbt.Lab_Test_ID
            //    where lbt.System_Generated == true
            //          && (labtest_detail.isApproved == false || labtest_detail.isApproved == null)
            //          && bill_details.Test_Main_Department != "001"
            //          && (bill.isCancel == false || bill.isCancel == null)
            //          && (labtest_detail.IsAcknowledge == false || labtest_detail.IsAcknowledge == null)
            //    select new
            //    {
            //        bill.Bill_Date,
            //        bill.Bill_No,
            //        bill.Bill_ID,
            //        bill_details.Item_Name,
            //        pat.Full_Name,
            //        bill_details.Bill_Details_ID,
            //        labtest_detail.Lab_Test_Detail_ID,
            //        Department =
            //            (from ipd in db.In_Patients
            //             where ipd.Patient_ID == pat.pat_id
            //             orderby ipd.In_Patient_ID descending
            //             select db.GetDataValueName("Patient Main Category", ipd.Department)).FirstOrDefault()
            //            ??
            //            (from emg in db.Emergency_Patients
            //             where emg.Patient_ID == pat.pat_id
            //             orderby emg.Emergency_ID descending
            //             select db.GetDataValueName("Patient Main Category", emg.Department)).FirstOrDefault()
            //            ??
            //            (from p2 in db.Patients
            //             where p2.Patient_ID == pat.pat_id
            //             select db.GetDataValueName("Patient Main Category", p2.Patient_Main_Category)).FirstOrDefault()
            //    }
            //);
            var query = from pat in db.Reg_patients
                        join bill in db.Ar_Billings on pat.pat_id equals bill.Patient_ID
                        join bill_details in db.Ar_Billing_Details on bill.Bill_ID equals bill_details.Bill_ID
                        join labtest_detail in db.Lab_Test_Details on bill_details.Bill_Details_ID equals labtest_detail.Bill_Details_ID
                        join lbt in db.Laboratory_Tests on labtest_detail.Lab_Test_ID equals lbt.Lab_Test_ID
                        where lbt.System_Generated == true
                              && (labtest_detail.isApproved == false || labtest_detail.isApproved == null)
                              && bill_details.Test_Main_Department != "001"
                              && (bill.isCancel == false || bill.isCancel == null)
                              && (labtest_detail.IsAcknowledge == false || labtest_detail.IsAcknowledge == null)
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
                        select new
                        {
                            bill.Bill_Date,
                            bill.Bill_No,
                            bill.Bill_ID,
                            bill_details.Item_Name,
                            pat.Full_Name,
                            bill_details.Bill_Details_ID,
                            labtest_detail.Lab_Test_Detail_ID,
                            Department = db.GetDataValueName("Patient Main Category", dept)
                        };

            if (!string.IsNullOrEmpty(searchValue))
            {
                query = query.Where(x =>
                    x.Full_Name.Contains(searchValue) ||
                    x.Bill_No.Contains(searchValue) ||
                    x.Item_Name.Contains(searchValue)
                );
            }

            switch (sortColumn)
            {
                case "Bill_No":
                    query = sortDirection == "asc" ? query.OrderBy(x => x.Bill_No) : query.OrderByDescending(x => x.Bill_No);
                    break;
                case "Full_Name":
                    query = sortDirection == "asc" ? query.OrderBy(x => x.Full_Name) : query.OrderByDescending(x => x.Full_Name);
                    break;
                case "Bill_Date":
                    query = sortDirection == "asc" ? query.OrderBy(x => x.Bill_Date) : query.OrderByDescending(x => x.Bill_Date);
                    break;
                case "Department":
                    query = sortDirection == "asc" ? query.OrderBy(x => x.Department) : query.OrderByDescending(x => x.Department);
                    break;
                default:
                    query = query.OrderByDescending(x => x.Bill_Date);
                    break;
            }

            int totalRecords = query.Count();

            var finalList = query.Skip(start).Take(length).ToList();

            return new
            {
                draw = draw,
                recordsTotal = totalRecords,
                recordsFiltered = totalRecords,
                data = finalList
            };
        }



        public class Testlist
        {
            public string status { get; set; }
            public string Lab_Test_Detail_ID { get; set; }
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