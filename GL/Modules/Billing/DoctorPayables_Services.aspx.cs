using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Billing
{
    public partial class DoctorPayables_Services : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string ViewList(int DocId, string startDate, string endDate)
        {
            DateTime dTimestDate;
            DateTime dTimeenDate;



            if (startDate == "" || endDate == "")
            {
                DataBaseDataContext db = new DataBaseDataContext();
                var Details = db.sp_Load_Payables_Details(DocId).ToList();
                return (new JavaScriptSerializer()).Serialize(Details);
            }
            else

            {
                dTimestDate = Convert.ToDateTime(startDate);
                //dTimeenDate = Convert.ToDateTime(endDate);
                dTimeenDate = Convert.ToDateTime(endDate).AddDays(1);

                DataBaseDataContext db = new DataBaseDataContext();
                var Details = db.sp_Load_Payables_Details(DocId).ToList().Where(x => x.Bill_Date >= dTimestDate && x.Bill_Date <= dTimeenDate).ToList().OrderByDescending(x => x.Bill_Date);
                return (new JavaScriptSerializer()).Serialize(Details);
            }

        }





        [WebMethod]
        public static string loadAccount()
        {
            string result = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            var itemsList = (from i in db.GL_Accounts
                             where i.Cash == true || i.Bank == true
                             select new
                             {
                                 i.Account_ID,
                                 name = i.Account_Code.ToString() + '-' + i.Account_Name
                             }).ToList();
            if (itemsList != null)
            {
                result = (new JavaScriptSerializer()).Serialize(itemsList);
            }
            return result;
        }


        [WebMethod]
        public static int TranferShares(string btnSave, string AllItemDetail)
        {
            string TransferNo = "1";
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<MasterTransfer>(AllItemDetail);

            var user = AppConfig.UserID;
            var getMaxVoucherID = db.spApprove_Distribution_Transfer_Master(user).FirstOrDefault();

            var getMaxVoucherIDforInsert = DBClass.getField("select MAX(Voucher_ID) from GL_Vouchers where Voucher_Type = 'DPV'");

            foreach (var a in record.ItemList)
            {
                int? billDetId = null;
                int? patientId = null;
                string recordType = a.Source_Type ?? "Billing";

                if (a.Source_Type == "Billing")
                {
                    billDetId = a.Bill_Detail_ID;
                }
                else if (a.Source_Type == "Patient")
                {
                    patientId = a.Patient_ID;
                }
                else if (a.Source_Type == "IPD_Share_Distribution")
                {
                    billDetId = a.Bill_ID;   // use Bill_ID as the identifier
                                             // patientId remains null
                }
                // For any other Source_Type, both remain null

                db.spApprove_Distribution_Transfer_DR(
                    Convert.ToInt32(getMaxVoucherIDforInsert),
                    billDetId,
                    patientId,
                    a.shareAmount,
                    Convert.ToInt32(a.AccountID),
                    recordType
                );
                db.SubmitChanges();
            }

            // Insert CR side
            db.spApprove_Distribution_Transfer_CR_Side(Convert.ToInt32(getMaxVoucherIDforInsert), Convert.ToDecimal(record.totalCr), record.CrAccountID);
            db.SubmitChanges();

            return int.Parse(TransferNo);
        }


        [WebMethod]
        public static string Update(List<Updatelist> Update_list)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            JavaScriptSerializer oJS = new JavaScriptSerializer();
            Ar_Billing_Detail obj = new Ar_Billing_Detail();
            foreach (var item in Update_list)
            {
                var data = (from arb in db.Ar_Billing_Details.Where(x => x.Bill_Details_ID.Equals(item.txt_billdetail_id)
                            )
                            select arb).FirstOrDefault();

                data.IsPayable = true;
                data.Payable_Date = DateTime.Now;
                db.SubmitChanges();

            }

            return "Update Data";
        }

        public class MasterInoviceList
        {
            public List<Updatelist> Update_list { get; set; }
        }

        public class Updatelist
        {
            //public string ddlname { get; set; }
            //public string txt_changeShare { get; set; }
            public string txt_billdetail_id { get; set; }

        }



        public class MasterTransfer
        {
            public List<DetailTransferList> ItemList { get; set; }
            public string Distri_No { get; set; }
            public string totalCr { get; set; }
            public int CrAccountID { get; set; }

        }

        public class DetailTransferList
        {
            public int? Bill_Detail_ID { get; set; }
            public int? Patient_ID { get; set; }
            public int? Bill_ID { get; set; }           // ← new property
            public string Source_Type { get; set; }
            public string AccountID { get; set; }
            public decimal shareAmount { get; set; }
        }
    }
}