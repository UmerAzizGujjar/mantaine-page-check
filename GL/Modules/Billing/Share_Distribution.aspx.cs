using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web;
using static PMS.Modules.Billing.Share_Distribution;
using static PMS.Refund;

namespace PMS.Modules.Billing
{
    public partial class Share_Distribution : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string LoadPatientDetailsByBillNO(string Bill_No)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                try
                {
                    int billNo = Convert.ToInt32(Bill_No);
                    var pat = db.spGetBillDetailforIPD_Distribution(billNo).ToList();
                    return (new JavaScriptSerializer().Serialize(pat));
                }
                catch (Exception ex)
                {
                    return (new JavaScriptSerializer().Serialize(ex.Message));
                }
            }
        }
        [WebMethod]
        public static string LoadPatientDetailsByBillID(int BillId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                try
                {   var Bill_No = (from data in db.Ar_Billings.Where(x => x.Bill_ID == BillId) select data.Bill_No).FirstOrDefault();
                    int billNo = Convert.ToInt32(Bill_No);
                    var pat = db.spGetBillDetailforIPD_Distribution(billNo).ToList();
                    return (new JavaScriptSerializer().Serialize(pat));
                }
                catch (Exception ex)
                {
                    return (new JavaScriptSerializer().Serialize(ex.Message));
                }
            }
        }
        [WebMethod]
        public static string LoadDistributionDetailsByBillNO(string Bill_No)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                try
                {
                    int billNo = Convert.ToInt32(Bill_No);
                    var pat = db.spGetIPD_Distribution(Bill_No).ToList();
                    return (new JavaScriptSerializer().Serialize(pat));
                }
                catch (Exception ex)
                {
                    return (new JavaScriptSerializer().Serialize(ex.Message));
                }
            }
        }
        [WebMethod]
        public static string GetDoctors()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<HR_Employee> emps = (from emp in db.HR_Employees
                                      where emp.IsDoctor == true
                                      select emp).ToList();

            return (new JavaScriptSerializer()).Serialize(emps);
        }
        [WebMethod]
        public static string filldropdowns()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from account in db.GL_Accounts
                         where account.Levels == 4
                         select new
                         {
                             account.Account_Code,
                             account.Account_ID,
                             account.Account_Name
                         }).ToList();
            string data = string.Empty;
            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static string fillIpddropdowns()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from account in db.GL_Accounts
                         where account.Levels == 4 && account.Account_Name == "IPD SHARE"
                         select new
                         {
                             account.Account_Code,
                             account.Account_ID,
                             account.Account_Name
                         }).ToList();
            string data = string.Empty;
            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static string fillDocdropdowns(int doc_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from account in db.GL_Accounts
                         join hr in  db.HR_Employees 
                         on account.Account_ID equals hr.Account_ID
                         where account.Levels == 4 && hr.Emp_ID == doc_id
                         select new
                         {
                             account.Account_Code,
                             account.Account_ID,
                             account.Account_Name
                         }).ToList();
            string data = string.Empty;
            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static bool CheckBillExist(int Bill_ID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                return db.IPD_Distribution_Masters
                         .Any(x => x.Bill_Id == Bill_ID);
            }
        }
        [WebMethod]
        public static string approve_Bill(string BillId)
        {
            try
            {
                var user_id = AppConfig.UserID;
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    int billId = Convert.ToInt32(BillId);

                    // Execute first procedure
                    var result1 = db.SpApproveIPDDistribution(billId, user_id).FirstOrDefault();

                    // Execute second procedure
                    var result2 = db.SpApproveIPDShareDistribution(billId, user_id).FirstOrDefault();

                    return (new JavaScriptSerializer()).Serialize(new
                    {
                        Status = true,
                        Message = "Share Approved Successfully",
                        Proc1Message = result1,
                        Proc2Message = result2
                    });
                }
            }
            catch (Exception ex)
            {
                return (new JavaScriptSerializer()).Serialize(new
                {
                    Status = false,
                    Message = ex.Message
                });
            }
        }

        public class Detial
        {
            public int Patient_ID { get; set; }
            public decimal IPD_Revenue { get; set; }

            public int Bill_ID { get; set; }
            public int Distribution_Id { get; set; }
            public DateTime Distributuion_Date { get; set; }
            public string remarks { get; set; }
            public List<DepartmentDistribution> DepartmentDistribution { get; set; }
            public List<IPDDistributions> IPDDistribution { get; set; }
        }
        public class DepartmentDistribution
        {
            public int Account_ID { get; set; }
            public string txtDescription { get; set; }
            public decimal txtTotalAmount { get; set; }
            public decimal txtDiscountPer { get; set; }
            public decimal txtDiscountAmount { get; set; }
            public decimal txtNetAmount { get; set; }
        }
        public class IPDDistributions
        {
            public int Account_ID { get; set; }
            public string Account_Name { get; set; }
            public decimal txtRevenuAmount { get; set; }
            public decimal txtRevenuDiscPer { get; set; }
            public decimal txtRevenuDiscAmount { get; set; }
            public decimal txtRevenuNetAmount { get; set; }
        }
        [WebMethod]
        public static string SaveDistribution(string data)
        {


            return (new JavaScriptSerializer()).Serialize(Save(data));
        }
        [WebMethod]
        public static string LoadDistributionHead(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = from data in db.IPD_Distribution_Masters.Where(x => x.Distribution_Id == id)
                        select new
                        {
                            data.Distribution_Date,
                            data.Bill_Id,
                            data.Patient_Id,
                            data.Remarks,
                            data.Voucher_Status,
                            data.Voucher_ID,
                            data.Total_Amount
                        };

            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static string LoadDistributionDetail(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = from data in db.IPD_Distribution_Details.Where(x => x.Distribution_Id == id)
                        select new
                        {
                            data.Distribution_Id,
                            data.Total_Amount,
                            data.Share_Calculation,
                            data.Account_Id,
                            data.Net_Amount,
                            data.Discount_Amount,
                            data.Discount_Percentage,
                            data.Distribution_Detail_Id,
                        };

            return (new JavaScriptSerializer()).Serialize(query);
        }

        [WebMethod]
        public static string GetDoctorAmountsfromBilling(string Bill_No)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var query = (from ab in db.Ar_Billings
                         join abd in db.Ar_Billing_Details
                            on ab.Bill_ID equals abd.Bill_ID
                         join hr in db.HR_Employees
                            on abd.Doctor_id equals Convert.ToString(hr.Emp_ID)
                         join acc in db.GL_Accounts
                            on hr.Account_ID equals acc.Account_ID
                         where abd.Doctor_id != null
                            && abd.Doctor_id != "0"
                            && ab.Bill_No == Bill_No
                         group abd by new
                         {
                             hr.Account_ID,
                             acc.Account_Code,
                             acc.Account_Name,
                             abd.Doctor_id
                         }
                         into g
                         select new
                         {
                             Doctor_ID = g.Key.Doctor_id,
                             Account_ID = g.Key.Account_ID,
                             Account_Code = g.Key.Account_Code,
                             Account_Name = g.Key.Account_Name,
                             TotalAmount = g.Sum(x => x.Doctor_Share ?? 0)
                         }).ToList();

            return new JavaScriptSerializer().Serialize(query);
        }


        [WebMethod]
        public static string LoadIPDDistributionShare(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = from data in db.IPD_Doctor_Distribution_Details.Where(x => x.Distribution_Id == id)
                        select new
                        {
                            data.Distribution_Id,
                            data.Total_Amount,
                            data.Share_Account_Name,
                            data.Account_Id,
                            Account_Code = (from a in db.GL_Accounts where a.Account_ID == data.Account_Id select a.Account_Code).FirstOrDefault(),
                            data.Net_Amount,
                            data.Discount_Amount,
                            data.Discount_Percentage,
                            data.Doctor_Distribution_Id,
                        };

            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static string Save(string data)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            JavaScriptSerializer JSS = new JavaScriptSerializer();
            var dt = JSS.Deserialize<Detial>(data);
            string value = string.Empty;
            IPD_Distribution_Master Ref = new IPD_Distribution_Master();
            var Distribution_Id = DBClass.GetNewNumber("Distribution_Id", "IPD_Distribution_Master", "").ToString();
            Ref.Patient_Id = dt.Patient_ID;
            Ref.Bill_Id = dt.Bill_ID;
            Ref.Distribution_Date = dt.Distributuion_Date; 
            Ref.Remarks = dt.remarks;
            Ref.Total_Amount = dt.IPD_Revenue;
            Ref.Voucher_Status = "Created";
            //Ref.Share_Voucher_Status = "Created";
            Ref.Created_By = AppConfig.UserID;
            Ref.Creation_Time = DateTime.Now;
            db.IPD_Distribution_Masters.InsertOnSubmit(Ref);

            db.SubmitChanges();

            List<IPD_Distribution_Detail> ListOfshare = new List<IPD_Distribution_Detail>();
            foreach (DepartmentDistribution dtls in dt.DepartmentDistribution)
            {
                IPD_Distribution_Detail Service = new IPD_Distribution_Detail();
                Service.Distribution_Id = Ref.Distribution_Id;
                Service.Account_Id = dtls.Account_ID;
                Service.Share_Calculation = dtls.txtDescription;
                Service.Total_Amount = dtls.txtTotalAmount;
                Service.Net_Amount = dtls.txtNetAmount;
                Service.Discount_Percentage = dtls.txtDiscountPer;
                Service.Discount_Amount = dtls.txtDiscountAmount;
                ListOfshare.Add(Service);

                db.IPD_Distribution_Details.InsertAllOnSubmit(ListOfshare);
            }

            List<IPD_Doctor_Distribution_Detail> ListOfRefund = new List<IPD_Doctor_Distribution_Detail>();
            foreach (IPDDistributions dts in dt.IPDDistribution)
            {
                IPD_Doctor_Distribution_Detail Doctor = new IPD_Doctor_Distribution_Detail();
                Doctor.Distribution_Id = Ref.Distribution_Id; 
                Doctor.Account_Id = dts.Account_ID;
                Doctor.Share_Account_Name = dts.Account_Name;
                Doctor.Total_Amount = dts.txtRevenuAmount;
                Doctor.Net_Amount = dts.txtRevenuNetAmount;
                Doctor.Discount_Percentage = dts.txtRevenuDiscPer;
                Doctor.Discount_Amount = dts.txtRevenuDiscAmount;
                ListOfRefund.Add(Doctor);
                db.IPD_Doctor_Distribution_Details.InsertAllOnSubmit(ListOfRefund);
            }
            //db.IPD_Distribution_Masters.InsertOnSubmit(Ref);
            //db.IPD_Distribution_Details.InsertAllOnSubmit(ListOfshare);
            //db.IPD_Doctor_Distribution_Details.InsertAllOnSubmit(ListOfRefund);
            db.SubmitChanges();
            return value;
        }
        [WebMethod]
        public static string Update(string data)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            JavaScriptSerializer JSS = new JavaScriptSerializer();
            var dt = JSS.Deserialize<Detial>(data);

            string value = string.Empty;

            // 🔹 Get existing master
            var Ref = db.IPD_Distribution_Masters
                        .FirstOrDefault(x => x.Distribution_Id == dt.Distribution_Id);

            if (Ref == null)
                return "Distribution not found";

            Ref.Patient_Id = dt.Patient_ID;
            Ref.Bill_Id = dt.Bill_ID;
            Ref.Distribution_Date = dt.Distributuion_Date;
            Ref.Remarks = dt.remarks;
            Ref.Voucher_Status = "Created";
            //Ref.Share_Voucher_Status = "Created";
            Ref.Total_Amount = dt.IPD_Revenue;
            Ref.Updated_Time = DateTime.Now;
            Ref.Updated_By = AppConfig.UserID;
            var oldDetails = db.IPD_Distribution_Details
                               .Where(x => x.Distribution_Id == dt.Distribution_Id);

            var oldDoctors = db.IPD_Doctor_Distribution_Details
                              .Where(x => x.Distribution_Id == dt.Distribution_Id);

            db.IPD_Distribution_Details.DeleteAllOnSubmit(oldDetails);
            db.IPD_Doctor_Distribution_Details.DeleteAllOnSubmit(oldDoctors);

            List<IPD_Distribution_Detail> ListOfshare = new List<IPD_Distribution_Detail>();

            foreach (DepartmentDistribution dtls in dt.DepartmentDistribution)
            {
                IPD_Distribution_Detail Service = new IPD_Distribution_Detail();

                Service.Distribution_Id = dt.Distribution_Id;
                Service.Account_Id = dtls.Account_ID;
                Service.Share_Calculation = dtls.txtDescription;
                Service.Total_Amount = dtls.txtTotalAmount;
                Service.Net_Amount = dtls.txtNetAmount;
                Service.Discount_Percentage = dtls.txtDiscountPer;
                Service.Discount_Amount = dtls.txtDiscountAmount;

                ListOfshare.Add(Service);
            }

            List<IPD_Doctor_Distribution_Detail> ListOfRefund =
                new List<IPD_Doctor_Distribution_Detail>();

            foreach (IPDDistributions dts in dt.IPDDistribution)
            {
                IPD_Doctor_Distribution_Detail Doctor =
                    new IPD_Doctor_Distribution_Detail();

                Doctor.Distribution_Id = dt.Distribution_Id;
                Doctor.Account_Id = dts.Account_ID;
                Doctor.Share_Account_Name = dts.Account_Name;
                Doctor.Total_Amount = dts.txtRevenuAmount;
                Doctor.Net_Amount = dts.txtRevenuNetAmount;
                Doctor.Discount_Percentage = dts.txtRevenuDiscPer;
                Doctor.Discount_Amount = dts.txtRevenuDiscAmount;

                ListOfRefund.Add(Doctor);
            }

            db.IPD_Distribution_Details.InsertAllOnSubmit(ListOfshare);
            db.IPD_Doctor_Distribution_Details.InsertAllOnSubmit(ListOfRefund);

            db.SubmitChanges();

            return "Updated Successfully";
        }

    }
}