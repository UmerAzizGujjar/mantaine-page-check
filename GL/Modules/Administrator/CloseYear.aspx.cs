using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;

namespace PMS
{
    public partial class CloseYear : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string year = DBClass.getField("select left(min(period_id),4) from GL_Periods where Period_Closed='False' and Company_ID=" + AppConfig.Company_ID + "");
                if(year != "There is no row at position 0." && year != "")
                    txtYear.Text = year;
            }
        }

        protected void btnCloseYear_Click(object sender, EventArgs e)
        {
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                DataTable dtyear = DBClass.getDataTable("select period_id,period_end_date from gl_periods where left(period_id,4)='" + txtYear.Text + "' and company_id=" + AppConfig.Company_ID + " order by period_id");

                DateTime voucherDate = Convert.ToDateTime(dtyear.Rows[dtyear.Rows.Count - 1]["period_end_date"]);
                string Period_ID = dtyear.Rows[dtyear.Rows.Count - 1]["period_id"].ToString(), Voucher_Type = "JV", Narration = "Year Closing";
                string voucherQuery = "Select max(isnull(voucher_no,0))from Gl_Vouchers where company_id=" + AppConfig.Company_ID + " and period_id='" + Period_ID + "' and voucher_type='JV' And Cancel=0";
                string voucherNo = DBClass.getField(voucherQuery);
                voucherNo = Convert.ToInt32(voucherNo.Equals("") ? "0" : voucherNo) + 1.ToString();
                int voucherID;
                string sSQL = null;
                string earningAccount = DBClass.getField("Select Earning from sys_companys where company_id=" + AppConfig.Company_ID + "").ToString();
                earningAccount = DBClass.getField("Select account_id from gl_accounts where account_code='" + earningAccount + "' and book_id=" + AppConfig.Book_ID + "").ToString();
                if (earningAccount != "There is no row at position 0.")
                {
                    sSQL += "INSERT INTO Gl_Vouchers(Voucher_No,Voucher_Date,Period_ID," +
                        "Voucher_Type,Remarks,Voucher_Status,Closing,Cancel," +
                        "Company_ID,Created_By,Creation_Time,Updated_By," +
                        "Update_Time,Approved_By,Approved_Time) " +
                        "VALUES ('" + voucherNo + "','" + voucherDate.ToString("dd-MMM-yy") + "','" + Period_ID +
                        "','" + Voucher_Type +
                        "','" + Narration +
                          "','Approved'" +
                        ",'True','False'," +
                        AppConfig.Company_ID + ",'" +
                        AppConfig.UserID + "',getDate(),'" +
                        AppConfig.UserID + "',getDate(),NULL,NULL)";
                    voucherID = DBClass.ExecuteNonQuerySCOPE_IDENTITY(sSQL, tranObj, con);
                    sSQL = "Insert into Gl_Voucher_accounts(voucher_id,account_id,narration,dr,cr) select " + voucherID + ",account_id,'" + Narration + "',(case when sum(dr-cr)<0 then -sum(dr-cr) else 0 end),(case when sum(dr-cr)>0 then sum(dr-cr) else 0 end) from vwgl_ledger where voucher_date<='" + voucherDate.ToString("dd-MMM-yy") + "' and company_id=" + AppConfig.Company_ID + " and left(account_code,1)>3 group by account_id;";
                    sSQL += "Insert into Gl_Voucher_accounts(voucher_id,account_id,narration,dr,cr) select " + voucherID + "," + earningAccount + ",'" + Narration + "',(case when sum(dr-cr)>0 then sum(dr-cr) else 0 end),(case when sum(dr-cr)<0 then -sum(dr-cr) else 0 end) from vwgl_ledger where left(account_code,1)>3 and voucher_date<='" + voucherDate.ToString("dd-MMM-yy") + "' and company_id=" + AppConfig.Company_ID + ";";
                    sSQL += "Update gl_periods set Period_Closed='True' where company_id=" + AppConfig.Company_ID + " and left(period_id,4)=" + txtYear.Text + ";";
                    sSQL += "Update Gl_Vouchers set Voucher_Status='Approved',Approved_By='" + AppConfig.UserID + "',Approved_Time=getdate() where voucher_id=" + voucherID + "";

                    DBClass.exectueQuery(sSQL, tranObj, con);
                    tranObj.Commit();
                    lblMessage.CssClass = "sucessfullMessage";
                    lblMessage.Text = "Year has been closed successfully.";
                    btnCloseYear.Enabled = false;
                }
                else
                {
                    lblMessage.Text = "There is no record for this year.";
                    lblMessage.CssClass = "errorMessage";
                }
            }
            catch (Exception ex)
            {
                if (tranObj != null)
                    tranObj.Rollback();
                throw;
            }
            finally
            {
                con.Close();
            }
        }
    }
}