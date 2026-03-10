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
    public partial class Refund : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [System.Web.Services.WebMethod]

        public static string GetPatientAndAdvanceDetail(string AdvanceId)
        {
              DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
              int patientid =Convert.ToInt32(db.Refunds.Where(x => x.Refund_ID.Equals(AdvanceId)).Select(x => x.Patient_ID).FirstOrDefault());
              int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(patientid));
              var InPatientId = db.In_Patients.Where(m => m.Patient_ID.Equals(patientid) && m.Discharge == false).OrderByDescending(m => m.Admission_Date).Select(m => m.In_Patient_ID).FirstOrDefault();
             
              var Type = (from tbl in db.In_Patients
                          where tbl.Patient_ID == Convert.ToInt32(patientid)
                          && tbl.Discharge != true
                          orderby tbl.Created_Time descending
                          select tbl.Patient_Discount_Type).FirstOrDefault();

             
             
              var query = (from data in db.Refunds
                           join pat in db.Reg_patients on data.Patient_ID equals pat.pat_id
                           select new 
                           {
                           pat.Patient_No,
                           pat.Full_Name,
                           pat.Mobile1,
                           pat.Created_time,
                           pat.Gender,
                           pat.Age_years,
                           pat.Permanent_Address,
                           //pat.Patient_Main_Category,
                           pat.pat_id,
                         
                         //department = db.GetDataValueName("Patient Main Category", pat.Patient_Main_Category), 

                           Patient_Discount_Type = db.GetDataValueName("Patient Type", Type),
                           data.Remarks,
                           data.Refund_Date,
                          data.Refund_Amount,
                           Balance = Convert.ToInt32(db.getAdvance_Balance(Convert.ToInt32(InPatientId), "In_Patient"))
                           }).FirstOrDefault();

              return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static string LoadShareDetails(string advID)
        {
             DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
             var shareDetail = (from rds in db.Refund_Detail_Services join dt in db.Ar_Billing_Details on rds.Bill_Detail_ID equals dt.Bill_Details_ID select new { 
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
          
            var pat = (
                from tbl in db.Reg_patients
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
                    //tbl.Patient_Main_Category,
                    //tbl.Patient_Type,
                    tbl.Patient_No,
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

                if (pat.Created_time.HasValue)
                    pt.Entry_Date = pat.Created_time.ToString();
                pt.Address = pat.Permanent_Address;
                pt.Mobile = pat.Mobile1;
                //pt.department = pat.Patient_Main_Category;
                //pt.department = db.GetDataValueName("Patient Main Category", pat.Patient_Main_Category); 

                var ptID = int.Parse(PatientID);
                var InPatientdat = (from inv in db.In_Patients
                                    join p in db.Reg_patients
                                    on inv.Patient_ID equals p.pat_id
                                    where p.Patient_No == Patien_No && inv.Patient_ID == ptID
                                    orderby inv.Created_Time descending
                                    select inv.Department).FirstOrDefault();
                if (InPatientdat != null)
                    pt.department = db.GetDataValueName("Patient Main Category", InPatientdat);


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
        }
        [WebMethod]
        public static string LoadPatientDetailsByBillNO(string Bill_No)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                try
                {
                    int billNo = Convert.ToInt32(Bill_No);
                    var pat = db.spGetBillServices(billNo).ToList();
                    return (new JavaScriptSerializer().Serialize(pat));
                }
                catch (Exception ex)
                {
                    return (new JavaScriptSerializer().Serialize(ex.Message));
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
        public class Detial {
            public int Patient_ID { get; set; }
            public DateTime advanceDate { get; set; }
            public string remarks { get; set; }
            public List<DoctorRefund> ServiceRefund { get; set; }
            public List<RefundDistribution> ShareRefund { get; set; }
        }
        public class DoctorRefund {
            public int Bill_Detial_ID { get; set; }
            public int Doctor_Refund { get; set; }
            public int Hos_Refund { get; set; }
            public int Item_ID { get; set; }
        }
        public class RefundDistribution {
            public int Emp_ID { get; set; }
            public int Record_Id { get; set; }
            public int Refund_Amount { get; set; }
        }
        [WebMethod]
        public static string SaveRefund(string data)
        {


            return (new JavaScriptSerializer()).Serialize(Save(data));
        }
        [WebMethod]
        public static string Save(string data)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            JavaScriptSerializer JSS = new JavaScriptSerializer();
            var dt = JSS.Deserialize<Detial>(data);

            string value = string.Empty;
            var BillID = string.Empty;

            Refund Ref = new Refund();
            var Refund_ID = DBClass.GetNewNumber("Refund_ID", "Refund", "").ToString();

            Ref.Patient_ID = dt.Patient_ID;
            Ref._Refund_Date = dt.advanceDate;
            Ref.Remarks = dt.remarks;

            decimal totalRefund = 0;

            List<Refund_Detail_Service> ListOfshare = new List<Refund_Detail_Service>();

            foreach (DoctorRefund dtls in dt.ServiceRefund)
            {
                Refund_Detail_Service Service = new Refund_Detail_Service();

                Service.Refund_ID = Convert.ToInt32(Refund_ID);
                Service.Bill_Detail_ID = dtls.Bill_Detial_ID;
                Service.Item_ID = dtls.Item_ID;
                Service.Doctor_Refund = dtls.Doctor_Refund;
                Service.Hospital_Refund = dtls.Hos_Refund;
                totalRefund += Convert.ToDecimal(dtls.Doctor_Refund);
                totalRefund += Convert.ToDecimal(dtls.Hos_Refund);

                BillID = DBClass.getField("select Bill_ID from Ar_Billing_Details where bill_Details_ID=" + dtls.Bill_Detial_ID);

                ListOfshare.Add(Service);
            }


            List<Refund_Detail_Doctor_Share> ListOfRefund = new List<Refund_Detail_Doctor_Share>();
            foreach (RefundDistribution dts in dt.ShareRefund)
            {
                Refund_Detail_Doctor_Share Doctor = new Refund_Detail_Doctor_Share();

                Doctor.Refund_ID = Convert.ToInt32(Refund_ID);
                Doctor.Emp_ID = dts.Emp_ID;
                Doctor.Refund_Amount = dts.Refund_Amount;
                totalRefund += Convert.ToDecimal(dts.Refund_Amount);

                ListOfRefund.Add(Doctor);
            }

            Ref.Bill_ID = Convert.ToInt32(BillID);
            Ref.Refund_Amount = Convert.ToInt32(totalRefund);

            db.Refunds.InsertOnSubmit(Ref);
            db.Refund_Detail_Services.InsertAllOnSubmit(ListOfshare);
            db.Refund_Detail_Doctor_Shares.InsertAllOnSubmit(ListOfRefund);

            db.SubmitChanges();

            if (!string.IsNullOrEmpty(BillID))
            {
                DBClass.executeNonQueryWithoutBegin("UPDATE Ar_Billings SET Is_Refund = 1 WHERE Bill_ID = " + BillID);
            }

            return value;
        }
    }
}
