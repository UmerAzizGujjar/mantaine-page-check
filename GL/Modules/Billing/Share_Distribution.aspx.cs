using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
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
        public static string LoadDistributionDetailsByBillNO(string Bill_No)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                try
                {
                    int billNo = Convert.ToInt32(Bill_No);
                    var pat = db.spGetIPD_Distribution(billNo).ToList();
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

        public class Detial
        {
            public int Patient_ID { get; set; }
            public int Bill_ID { get; set; }
            public DateTime Distributuion_Date { get; set; }
            public string remarks { get; set; }
            public List<DepartmentDistribution> DepartmentDistribution { get; set; }
            public List<IPDDistributions> IPDDistribution { get; set; }
        }
        public class DepartmentDistribution
        {
            public int ddlGlAccounts { get; set; }
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

            List<IPD_Distribution_Detail> ListOfshare = new List<IPD_Distribution_Detail>();
            foreach (DepartmentDistribution dtls in dt.DepartmentDistribution)
            {
                IPD_Distribution_Detail Service = new IPD_Distribution_Detail();
                Service.Distribution_Id = Convert.ToInt32(Distribution_Id);
                Service.Account_Id = dtls.ddlGlAccounts;
                Service.Share_Calculation = dtls.txtDescription;
                Service.Total_Amount = dtls.txtTotalAmount;
                Service.Net_Amount = dtls.txtNetAmount;
                Service.Discount_Percentage = dtls.txtDiscountPer;
                Service.Discount_Amount = dtls.txtDiscountAmount;
                ListOfshare.Add(Service);
            }

            List<IPD_Doctor_Distribution_Detail> ListOfRefund = new List<IPD_Doctor_Distribution_Detail>();
            foreach (IPDDistributions dts in dt.IPDDistribution)
            {
                IPD_Doctor_Distribution_Detail Doctor = new IPD_Doctor_Distribution_Detail();
                Doctor.Distribution_Id = Convert.ToInt32(Distribution_Id);
                Doctor.Account_Id = dts.Account_ID;
                Doctor.Share_Account_Name = dts.Account_Name;
                Doctor.Total_Amount = dts.txtRevenuAmount;
                Doctor.Net_Amount = dts.txtRevenuNetAmount;
                Doctor.Discount_Percentage = dts.txtRevenuDiscPer;
                Doctor.Discount_Amount = dts.txtRevenuDiscAmount;
                ListOfRefund.Add(Doctor);


            }
            db.IPD_Distribution_Masters.InsertOnSubmit(Ref);
            db.IPD_Distribution_Details.InsertAllOnSubmit(ListOfshare);
            db.IPD_Doctor_Distribution_Details.InsertAllOnSubmit(ListOfRefund);
            db.SubmitChanges();
            return value;
        }
    }
}