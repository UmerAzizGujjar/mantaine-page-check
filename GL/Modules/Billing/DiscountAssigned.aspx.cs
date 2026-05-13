using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Windows;
using Telerik.Web;
using Telerik.Web.UI.ImageEditor;
using static PMS.Refund;

namespace PMS.Modules.Billing
{
    public partial class DiscountAssigned : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [System.Web.Services.WebMethod]
        public static string GetPatientAndAdvanceDetail(string AdvanceId)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            int patientid = Convert.ToInt32(db.Refunds.Where(x => x.Refund_ID.Equals(AdvanceId)).Select(x => x.Patient_ID).FirstOrDefault());
            int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(patientid));
            var InPatientId = db.In_Patients.Where(m => m.Patient_ID.Equals(patientid) && m.Discharge == false).OrderByDescending(m => m.Admission_Date).Select(m => m.In_Patient_ID).FirstOrDefault();

            var Type = (from tbl in db.In_Patients
                        where tbl.Patient_ID == Convert.ToInt32(patientid)
                        && tbl.Discharge != true
                        orderby tbl.Created_Time descending
                        select tbl.Patient_Discount_Type).FirstOrDefault();

            var query = (from data in db.Refunds
                         join pat in db.Reg_patients on data.Patient_ID equals pat.pat_id
                         where data.Refund_ID == Convert.ToInt32(AdvanceId)
                         select new
                         {
                             pat.Patient_No,
                             pat.Full_Name,
                             pat.Mobile1,
                             pat.Created_time,
                             pat.Gender,
                             pat.Age_years,
                             pat.Permanent_Address,
                             pat.pat_id,
                             Patient_Discount_Type = db.GetDataValueName("Patient Type", Type),
                             data.Remarks,
                             data.Refund_Date,
                             data.Bill_ID,
                             data.Refund_Amount,
                             Balance = Convert.ToInt32(db.getAdvance_Balance(Convert.ToInt32(InPatientId), "In_Patient"))
                         }).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(query);
        }

        [WebMethod]
        public static string LoadShareDetails(string advID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var shareDetail = (from ds in db.Refunds
                               join rds in db.Refund_Detail_Services on ds.Refund_ID equals rds.Refund_ID
                               join dt in db.Ar_Billing_Details on rds.Bill_Detail_ID equals dt.Bill_Details_ID
                               where ds.Refund_ID == Convert.ToInt32(advID)
                               select new
                               {
                                   dt.Item_Name,
                                   dt.Doctor_Share,
                                   Net_Amount = dt.Net_Amount - (dt.Doctor_Share == null ? 0 : dt.Doctor_Share),
                                   rds.Doctor_Refund,
                                   rds.Hospital_Refund,
                               }).ToList();
            return (new JavaScriptSerializer()).Serialize(shareDetail);
        }

        [WebMethod]
        public static string RefundDetials(string advID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var RefundDetail = (from rd in db.Refund_Detail_Doctor_Shares
                                join d in db.AR_Billing_Detail_Doctor_Shares on rd.Emp_ID equals d.Emp_ID
                                select new
                                {
                                    rd.Emp_ID,
                                    d.Share_type,
                                    d.Amount,
                                    rd.Refund_Amount,
                                    Emp_Name = (from e in db.HR_Employees where e.Emp_ID == rd.Emp_ID select e.Emp_Name).FirstOrDefault()
                                }).ToList();
            return (new JavaScriptSerializer()).Serialize(RefundDetail);
        }

        [WebMethod]
        public static PatientDetail LoadPatientDetails(string PatientID)
        {
            int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatientID));
            PatientDetail pt = new PatientDetail();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var pat = (from tbl in db.Reg_patients
                       where tbl.Patient_No == Patien_No
                       orderby tbl.Created_time descending
                       select new
                       {
                           tbl.Full_Name,
                           tbl.Gender,
                           tbl.Age_years,
                           tbl.Created_time,
                           tbl.Permanent_Address,
                           tbl.Mobile1,
                           tbl.Patient_No,
                           tbl.pat_id,
                           //tbl.Patient_Main_Category,
                           //tbl.Patient_Type,
                       }).FirstOrDefault();

            var Type = (from tbl in db.In_Patients
                        where tbl.Patient_ID == int.Parse(PatientID)
                        && tbl.Discharge != true
                        orderby tbl.Created_Time descending
                        select tbl.Patient_Discount_Type).FirstOrDefault();

            if (pat != null)
            {
                pt.Name = pat.Full_Name;
                pt.Gender = pat.Gender;
                pt.Age = pat.Age_years.ToString();
                pt.pat_id = pat.pat_id;

                if (pat.Created_time.HasValue)
                    pt.Entry_Date = pat.Created_time.ToString();
                pt.Address = pat.Permanent_Address;
                pt.Mobile = pat.Mobile1;
                //pt.department = db.GetDataValueName("Patient Main Category", pat.Patient_Main_Category);
                //pt.Patient_Type = db.GetDataValueName("Patient Type", pat.Patient_Type);
                pt.Gender = db.GetDataValueName("Gender", pat.Gender);
                var Patientno = pat.Patient_No.ToString();
                var count = (db.Reg_patients.Where(v => v.Patient_No == Convert.ToInt32(Patientno)).ToList());
                pt.Follow = count.Count.ToString();
                pt.Patient_Discount_Type = db.GetDataValueName("Patient Type", Type);
                var InPatientId = db.In_Patients.Where(m => m.Patient_ID.Equals(PatientID) && m.Discharge == false).OrderByDescending(m => m.Admission_Date).Select(m => m.In_Patient_ID).FirstOrDefault();
                pt.Balance = Convert.ToInt32(db.getAdvance_Balance(Convert.ToInt32(InPatientId), "In_Patient"));
                return pt;
            }
            else
                return pt;
        }

        public class PatientDetail
        {
            public string Name;
            public string Gender;
            public string Age;
            public string Patient_Type;
            public string Patient_Discount_Type;
            public string Mobile;
            public string Address;
            public string Entry_Date;
            public string department;
            public string Follow;
            public int Balance;
            public int pat_id;
        }

        [WebMethod]
        public static string LoadPatientDetailsByBillNO(string Bill_No)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                try
                {
                    int billNo = Convert.ToInt32(Bill_No);
                    var pat = db.spGetBillDetails(billNo).ToList();
                    return (new JavaScriptSerializer().Serialize(pat));
                }
                catch (Exception ex)
                {
                    return (new JavaScriptSerializer().Serialize(ex.Message));
                }
            }
        }

        [WebMethod]
        public static bool CheckBillTestApproved(int Bill_ID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                try
                {
                    var pat = db.sp_GetLabApprovalStatus(Bill_ID).ToList();
                    if (pat == null || pat.Count == 0)
                        return false;
                    bool isApproved = pat.Any(x => x.isApproved != null && x.isApproved == true);
                    return isApproved;
                }
                catch (Exception)
                {
                    return false;
                }
            }
        }

        [WebMethod]
        public static string LoadDoctorShare(string Bill_No)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                try
                {
                    int billNo = Convert.ToInt32(Bill_No);
                    var pat = db.spGetDoctorDistribution(billNo).ToList();
                    return (new JavaScriptSerializer().Serialize(pat));
                }
                catch (Exception ex)
                {
                    return (new JavaScriptSerializer().Serialize(ex.Message));
                }
            }
        }

        [WebMethod]
        public static string CheckExistInPatient(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var Check = (from inPat in db.In_Patients
                             where inPat.Patient_ID == PatientID
                             && inPat.Discharge == false
                             orderby inPat.Admission_Date descending
                             select new
                             {
                                 inPat.In_Patient_ID
                             }).FirstOrDefault();
                return (new JavaScriptSerializer().Serialize(Check));
            }
        }

        // Discount Classes
        public class DiscountDetail
        {
            public int Patient_ID { get; set; }
            public int Reg_ID { get; set; }
            public DateTime DiscountDate { get; set; }
            public string remarks { get; set; }
            public int Bill_Id { get; set; }
            public decimal Total_Discount { get; set; }
            public List<ServiceDiscount> ServiceDiscount { get; set; }
      
        }

        public class ServiceDiscount
        {
            public int Bill_Detail_ID { get; set; }
            public int Item_ID { get; set; }
            public string Item_Name { get; set; }
            public string Item_Type { get; set; }
            public decimal Original_Amount { get; set; }
            public decimal Discount_Percentage { get; set; }
            public decimal Discount_Amount { get; set; }
            public decimal Net_Amount { get; set; }
        }

        [WebMethod]
        public static string SaveDiscount(string data)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            JavaScriptSerializer JSS = new JavaScriptSerializer();
            var dt = JSS.Deserialize<DiscountDetail>(data);

            string value = string.Empty;
            var BillID = string.Empty;

            // Create master record
            Discount_Assign_Bill discount = new Discount_Assign_Bill();
            var Discount_Assign_ID = DBClass.GetNewNumber("Discount_Assign_ID", "Discount_Assign_Bill", "").ToString();

            discount.Discount_Assign_ID = Convert.ToInt32(Discount_Assign_ID);
            discount.Bill_ID = dt.Bill_Id;
            discount.Patient_ID = dt.Patient_ID;
            discount.Reg_ID = dt.Reg_ID;
            discount.Discount_Date = dt.DiscountDate;
            discount.Total_Discount = dt.Total_Discount;
            discount.Remarks = dt.remarks;
            discount.Status = "Created";
            discount.Created_By = AppConfig.UserID;
            discount.Creation_Date = DateTime.Now;

            // Create detail records list
            List<Discount_Assign_Detail_bill> ListOfDiscountDetails = new List<Discount_Assign_Detail_bill>();

            foreach (ServiceDiscount service in dt.ServiceDiscount)
            {
                Discount_Assign_Detail_bill detail = new Discount_Assign_Detail_bill();

                detail.Discount_Assign_ID = Convert.ToInt32(Discount_Assign_ID);
                detail.Bill_Detail_ID = service.Bill_Detail_ID;
                detail.Item_ID = service.Item_ID;
                detail.Item_Name = service.Item_Name;
                detail.Item_Type = service.Item_Type;
                detail.Original_Amount = service.Original_Amount;
                detail.Discount_Percentage = service.Discount_Percentage;
                detail.Discount_Amount = service.Discount_Amount;
                detail.Net_Amount = service.Net_Amount;
                //detail.Created_By = AppConfig.UserID;
                //detail.Creation_Date = DateTime.Now;

                ListOfDiscountDetails.Add(detail);
            }

            // Insert into database using LINQ
            db.Discount_Assign_Bills.InsertOnSubmit(discount);
            db.Discount_Assign_Detail_bills.InsertAllOnSubmit(ListOfDiscountDetails);
            db.SubmitChanges();

            value = Discount_Assign_ID;

            return value;
        }
    }
}