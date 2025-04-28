using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class PaymentFormList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        public class Result
        {
            public string PaymentForm_No;
            public string PaymentForm_Date;
            public string Remarks;
            public string Discount_Percentage;
            public string Discount_Amount;
            public string Net_Amount;
            public string Received_Amount;
            public string Total_Amount;
            public string Balance_Amount;
            public string Full_Name;
            public string MR_No;
            public string PaymentForm_ID;
            public string Operator;
        }
        [WebMethod]
        public static List<Result> Search(string billNo, string Mrno, string Date)
        {


            string SearchSql = "";
            //PaymentForm_ID,PaymentForm_No,PaymentForm_Date
            if (billNo == "" && Mrno == "" && Date == "")
                SearchSql = "select top 500 PaymentForm_No,b.Creation_Date as PaymentForm_Date,Remarks,Total_Amount,0 as Discount_Percentage,0 as Discount_Amount,Net_Amount,Received_Amount,Balance_Amount,Patient_No,Full_Name,PaymentForm_ID,u.UserName as Operator  from Ar_PaymentForm b,Patients p,aspnet_Users u where b.Patient_ID=p.Patient_ID and (b.Total_Amount is not null ) and b.Created_By=u.UserId  order by b.PaymentForm_Date desc";

            else
            {
                if (Date != "")
                {

                    SearchSql = " select PaymentForm_No,b.Creation_Date as PaymentForm_Date,Remarks,Total_Amount,0 as Discount_Percentage,0 as Discount_Amount,Net_Amount,Received_Amount,Balance_Amount,Patient_No,Full_Name,PaymentForm_ID,u.UserName as Operator  from Ar_PaymentForm b,Patients p ,aspnet_Users u  where b.Patient_ID=p.Patient_ID  and (b.Total_Amount is not null)  and cast(b.Creation_Date as date) ='" + Convert.ToDateTime(Date).ToString("yyyy-MM-dd") + "'  and b.Created_By=u.UserId   order by b.PaymentForm_Date desc";
                }
                if (Mrno != "")
                {
                    SearchSql = "select PaymentForm_No,b.Creation_Date as PaymentForm_Date,Remarks,Total_Amount,0 as Discount_Percentage,0 as Discount_Amount,Net_Amount,Received_Amount,Balance_Amount,Patient_No,Full_Name,PaymentForm_ID,u.UserName as Operator from Ar_PaymentForm b,Patients p ,aspnet_Users u where b.Patient_ID=p.Patient_ID  and (b.Total_Amount is not null )  and (p.patient_no like '%" + Mrno + "%' or  p.full_name like '%" + Mrno + "%') and b.Created_By=u.UserId   order by 1 desc";
                }

                if (billNo != "")
                {
                    SearchSql = "select PaymentForm_No,b.Creation_Date as PaymentForm_Date,Remarks,Total_Amount,0 as Discount_Percentage,0 as Discount_Amount,Net_Amount,Received_Amount,Balance_Amount,Patient_No,Full_Name,PaymentForm_ID,u.UserName as Operator  from Ar_PaymentForm b,Patients p ,aspnet_Users u where b.Patient_ID=p.Patient_ID  and (b.Total_Amount is not null)  and  b.PaymentForm_No like '%" + billNo + "%' and b.Created_By=u.UserId   order by 1 desc";
                }
            }

            DataTable dt = DBClass.getDataTable(SearchSql);

            List<Result> list = new List<Result>();

            foreach (DataRow dr in dt.Rows)
            {
                Result rslt = new Result()
                {
                    PaymentForm_No = dr[0] == DBNull.Value ? "" : (string)dr[0].ToString(),
                    PaymentForm_Date = dr[1] == DBNull.Value ? "" : Convert.ToDateTime(dr[1]).ToString("dd-MMM-yyyy hh:mm:ss tt"),
                    Remarks = dr[2] == DBNull.Value ? "" : dr[2].ToString(),
                    Total_Amount = dr[3] == DBNull.Value ? "" : dr[3].ToString(),
                    Discount_Percentage = dr[4] == DBNull.Value ? "" : dr[4].ToString(),
                    Discount_Amount = dr[5] == DBNull.Value ? "" : (string)dr[5].ToString(),
                    Net_Amount = dr[6] == DBNull.Value ? "" : dr[6].ToString(),
                    Received_Amount = dr[7] == DBNull.Value ? "" : dr[7].ToString(),
                    Balance_Amount = dr[8] == DBNull.Value ? "" : dr[8].ToString(),
                    MR_No = dr[9] == DBNull.Value ? "" : dr[9].ToString(),
                    Full_Name = dr[10] == DBNull.Value ? "" : dr[10].ToString(),
                    PaymentForm_ID = dr[11] == DBNull.Value ? "" : (string)dr[11].ToString(),
                    Operator = dr[12] == DBNull.Value ? "" : (string)dr[12].ToString()
                };
                list.Add(rslt);
            }
            return list;
        }

    }
}