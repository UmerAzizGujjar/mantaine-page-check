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
    public partial class DayClosing : System.Web.UI.Page
    {
        public bool OracleConnected = false;
        protected void Page_Load(object sender, EventArgs e)
        {
            OracleConnection();
        }
        private void OracleConnection()
        {
            string output = DBClass.OracleConnectionTest();
            if (output != "")
            {
                lblMessage.CssClass = "error-container";
                lblMessage.Text = output;
            }
            else
            {
                OracleConnected = true;
                lblMessage.CssClass = "successMessage";
                lblMessage.Text = "Oracle Server Status: Connected";
            }
        }

        [WebMethod]
        public static string ProcessDay(string date)
        {
            try
            {


                string voucherNo;
                string voucherDate = "TO_DATE('" + Convert.ToDateTime(date).ToString("dd-MMM-yyyy") + "','dd-mon-rrrr')";
                string createDate = "TO_DATE('" + DateTime.Now.ToString("dd-MMM-yyyy hh:mm:ss tt") + "',  'dd-mon-rrrr hh:mi:ss AM')";
                string description = "Closing voucher of HMIS";
                string voucherType = "JVH";
                string voucherId;
                string sql;
                DataTable dt;


                //*******  validation check  ****************
                sql = "Select * from GL_Days_Process Where Closing_Date='" + Convert.ToDateTime(date).ToString("dd-MMM-yyyy") + "'";
                dt = DBClass.getDataTable(sql);
                if (dt.Rows.Count != 0)
                {
                    throw new Exception("Day is already process");

                }
                else if (Convert.ToDateTime(date) > DateTime.Now.Date)
                {
                    throw new Exception("You can't process future date, please select valid date");

                }

                // ****** validation check Ends ************

                //Get new voucher Number
                sql = "Select NVL(Max(Voucher_No),0)+1 as New_Voucher_No from GL_Vouchers where Voucher_Type='JVH' and EXTRACT(month FROM Voucher_date)=" + Convert.ToDateTime(date).Month + " and EXTRACT(year FROM Voucher_date)=" + Convert.ToDateTime(date).Year + "";
                dt = DBClass.OracleGetDataTable(sql);
                voucherNo = dt.Rows[0][0].ToString();

                //Insert Oracle Voucher header
                sql = "insert into GL_Vouchers(Voucher_ID,Voucher_Type,Voucher_No,Voucher_Date,Description,Created_By,Creation_Date,Status,Last_Updated_By,Last_Updated_Date,Approved_By,Approval_Date,Company_ID,Branch_ID,Module,Module_Doc) " +
                    "Values(GL_VOUCHER_ID_S.NEXTVAL,'" + voucherType + "'," + voucherNo + "," + voucherDate + ",'" + description + "',1," + createDate + ",'APPROVED',1," + createDate + ",1," + createDate + ",1,'01','INV','INVOICE') RETURNING Voucher_ID INTO :LastID";
                voucherId = DBClass.OracleExecuteQuery(sql);

                //Insert voucher detail
                sql = "select sys_parms.code,sum(receipt_amount)+Sum(Card_Receipt_Amount) as amount from Patients,sys_Parms where convert(date,Created_Time)='" + Convert.ToDateTime(date).ToString("dd-MMM-yyyy") + "' and patients.Patient_Type=sys_parms.Segment2 and patients.Patient_Main_Category=sys_parms.Segment1 and sys_Parms.Segment3='Is Income Account' group by sys_Parms.Code " +
                "Union all select sys_parms.code,Sum(Doctor_Amount)as amount from Patients,sys_Parms where convert(date,Created_Time)='" + Convert.ToDateTime(date).ToString("dd-MMM-yyyy") + "' and patients.Patient_Type=sys_parms.Segment2 and patients.Patient_Main_Category=sys_parms.Segment1 and sys_Parms.Segment3='Is Liability Account' and sys_Parms.name=296 group by sys_Parms.Code ;";




                dt = DBClass.getDataTable(sql);
                double total = 0;
                int accountId;
                string voucherAccountId;

                total = Convert.ToDouble(dt.Compute("Sum(Amount)", ""));
                // Convert.ToDouble (dt.Compute("Sum(amount)")).ToString();

                //Debit Entry
                accountId = DBClass.OracleGLAccountID(DBClass.getParameter("GL_Cash_Account"));
                sql = "insert into gl_voucher_accounts(VOUCHER_ACCOUNT_ID,voucher_id,account_id,debit,credit,naration,created_by,creation_date,last_updated_by,last_update_date) " +
                    "values(GL_VOUCHER_ACCOUNT_ID_S.NEXTVAL," + voucherId + "," + accountId + "," + total + ",0,'" + description + "',1," + createDate + ",1," + createDate + ") RETURNING VOUCHER_ACCOUNT_ID INTO :LastID";
                voucherAccountId = DBClass.OracleExecuteQuery(sql);
                foreach (DataRow row in dt.Rows)
                {
                    //Credit Entry
                    accountId = DBClass.OracleGLAccountID(row["code"].ToString());
                    sql = "insert into gl_voucher_accounts(VOUCHER_ACCOUNT_ID,voucher_id,account_id,debit,credit,naration,created_by,creation_date,last_updated_by,last_update_date) " +
                        "values(GL_VOUCHER_ACCOUNT_ID_S.NEXTVAL," + voucherId + "," + accountId + ",0," + (row["amount"]).ToString() + ",'" + description + "',1," + createDate + ",1," + createDate + ") RETURNING VOUCHER_ACCOUNT_ID INTO :LastID";
                    voucherAccountId = DBClass.OracleExecuteQuery(sql);
                    //total += Convert.ToDouble(row["amount"].ToString());

                }
                //Insert into database
                sql = "Insert into GL_Days_Process(Closing_Date,Created_By,Creation_Time,Billing_Voucher_ID) " +
                    "Values('" + Convert.ToDateTime(date).ToString("dd-MMM-yyyy") + "', '" + AppConfig.UserID + "',getdate()," + voucherId + ")";
                DBClass.executeNonQueryWithoutBegin(sql);

                return voucherId;
            }
            catch (Exception exc)
            {
                throw exc;
            }
        }

    }
}