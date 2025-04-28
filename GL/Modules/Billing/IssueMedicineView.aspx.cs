using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using System.Text;
using System.Data;


namespace PMS
{
    public partial class IssueMedicineView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        public class Result
        {
            public string Bill_No;
            public string Bill_Date;
            public string Remarks;
            public string Discount_Percentage;
            public string Discount_Amount;
            public string Net_Amount;
            public string Received_Amount;
            public string Total_Amount;
            public string Balance_Amount;
            public string Full_Name;
            public string MR_No;
            public string Bill_ID;
        }
        [WebMethod]
        public static List<Result> Search(string billNo, string Mrno, string Date)
        {


            string SearchSql = "";

            if (billNo == "" && Mrno == "" && Date == "")
                SearchSql = "select top 500 Bill_No,Bill_Date,Remarks,Patient_No,Full_Name,Bill_ID from Ar_Billings b,Patients p where b.Patient_ID=p.Patient_ID and (b.Total_Amount is null or b.discount_Amount is null )  order by b.Bill_Date desc";

            else
            {
                if (Date != "")
                {
                    SearchSql = "select Bill_No,Bill_Date,Remarks,Total_Amount,Patient_No,Full_Name,Bill_ID from Ar_Billings b,Patients p where b.Patient_ID=p.Patient_ID  and (b.Total_Amount is not null or b.discount_Amount is not null )  and b.Bill_Date ='" + Convert.ToDateTime(Date).ToString("yyyy-MM-dd") + "'  order by b.Bill_Date desc";
                }
                if (Mrno != "")
                {
                    SearchSql = "select Bill_No,Bill_Date,Remarks,Total_Amount,Patient_No,Full_Name,Bill_ID from Ar_Billings b,Patients p where b.Patient_ID=p.Patient_ID  and (b.Total_Amount is null or b.discount_Amount is null )  and (p.patient_no like '%" + Mrno + "%' or  p.full_name like '%" + Mrno + "%')  order by 1 desc";
                }

                if (billNo != "")
                {
                    SearchSql = "select Bill_No,Bill_Date,Remarks,Patient_No,Full_Name,Bill_ID from Ar_Billings b,Patients p where b.Patient_ID=p.Patient_ID  and (b.Total_Amount is null or b.discount_Amount is null )  and  b.Bill_No like '%" + billNo + "%'  order by 1 desc";
                }
            }

            DataTable dt = DBClass.getDataTable(SearchSql);

            List<Result> list = new List<Result>();

            foreach (DataRow dr in dt.Rows)
            {
                Result rslt = new Result()
                {
                    Bill_No = dr[0] == DBNull.Value ? "" : (string)dr[0].ToString(),
                    Bill_Date = dr[1] == DBNull.Value ? "" : Convert.ToDateTime(dr[1]).ToString("dd-MMM-yyyy"),
                    Remarks = dr[2] == DBNull.Value ? "" : dr[2].ToString(),
                    //Total_Amount = dr[3] == DBNull.Value ? "" : dr[3].ToString(),
                   /// Discount_Percentage = dr[4] == DBNull.Value ? "" : dr[4].ToString(),
                   // Discount_Amount = dr[5] == DBNull.Value ? "" : (string)dr[5].ToString(),
                   // Net_Amount = dr[6] == DBNull.Value ? "" : dr[6].ToString(),
                  //  Received_Amount = dr[7] == DBNull.Value ? "" : dr[7].ToString(),
                    //Balance_Amount = dr[8] == DBNull.Value ? "" : dr[8].ToString(),
                    MR_No = dr[3] == DBNull.Value ? "" : dr[3].ToString(),
                    Full_Name = dr[4] == DBNull.Value ? "" : dr[4].ToString(),
                    Bill_ID = dr[5] == DBNull.Value ? "" : (string)dr[5].ToString()
                };
                list.Add(rslt);
            }
            return list;
        }

        [WebMethod]
        public static string DeleteRecord(int Bill_ID)
        {
            List<string> ReceiptNos = new List<string>();

            DataBaseDataContext db = new DataBaseDataContext();

            #region"Checking receipts."

            var rcptList = (from r in db.Receipts
                            where r.Bill_ID == Bill_ID
                            select new { r.Receipt_No, r.Bill_ID }).ToList();
            StringBuilder data = new StringBuilder();

            foreach (var item in rcptList)
            {
                data.Append(item.Receipt_No);
                data.Append(",");
            }
            if (data.Length > 0)
            {
                return "Delete Following Receipts." + data;
            }

            #endregion

            var BillHeader = db.Ar_Billings.Where(b => b.Bill_ID == Bill_ID).FirstOrDefault();

            var BillDetails = (from d in db.Ar_Billing_Details
                               join m in db.Ar_Billings
                               on d.Bill_ID equals m.Bill_ID
                               where m.Bill_ID == Bill_ID
                               select d).ToList();

            foreach (var item in BillDetails)
            {
                if (item.ParentTrans_ID != null && item.ParentTrans_ID != 0 && (item.Item_Type == "Test"))
                {
                    var test = db.Lab_Test_Details.Where(t => t.Lab_Test_Detail_ID == item.ParentTrans_ID).FirstOrDefault();
                    if (test != null)
                        test.IsBilled = false;
                }
                if (item.ParentTrans_ID != null && item.ParentTrans_ID != 0 && (item.Item_Type == "Test" && item.ParentTrans_Type == "Test Group Category"))
                {
                    var GroupedData = (from lbm in db.Laboratory_Tests
                                       join lbd in db.Lab_Test_Details
                                       on lbm.Lab_Test_ID equals lbd.Lab_Test_ID
                                       where lbd.Lab_Test_Detail_ID == item.ParentTrans_ID
                                       select lbm.Parent_Transaction_Type_ID
                                     ).FirstOrDefault();

                    if (GroupedData != null)
                    {
                        var test = db.Lab_Test_Details.Where(t => t.Lab_Test_Detail_ID == GroupedData).FirstOrDefault();
                        if (test != null)
                            test.IsBilled = false;
                    }
                }
            }
            if (BillDetails != null)
                db.Ar_Billing_Details.DeleteAllOnSubmit(BillDetails);
            db.SubmitChanges();
            if (BillHeader != null)
                db.Ar_Billings.DeleteOnSubmit(BillHeader);

            // Deleting from GL....

            var GL_M = (from m in db.GL_Vouchers where m.Voucher_ID == BillHeader.Voucher_ID select m).FirstOrDefault();
            var GL_D = (from d in db.GL_Voucher_Accounts where d.Voucher_ID == BillHeader.Voucher_ID select d).ToList();
            if (GL_D != null)
                db.GL_Voucher_Accounts.DeleteAllOnSubmit(GL_D);
            db.SubmitChanges();
            if (GL_M != null)
                db.GL_Vouchers.DeleteOnSubmit(GL_M);
            db.SubmitChanges();
            return "";
        }
    }
}