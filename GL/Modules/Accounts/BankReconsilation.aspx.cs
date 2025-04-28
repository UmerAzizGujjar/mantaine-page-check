using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class BankReconsilation : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                BindGrid();
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            BindGrid();
        }

        protected void Assign_Date_Click(object sender, EventArgs e)
        {
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                if (txtRealization_Date.Text != "")
                {
                    string query = "";
                    foreach (GridViewRow row in gvReconsilationList.Rows)
                    {

                        CheckBox chk = row.FindControl("chkSelect") as CheckBox;
                        Label lblVoucher_Account_ID = row.FindControl("lblVoucher_Account_ID") as Label;
                        int Voucher_Account_ID = Convert.ToInt32(lblVoucher_Account_ID.Text);
                        if (chk.Checked)
                        {
                            if (query != "")
                                query += " ; ";

                            query += "Update GL_Voucher_Accounts set Realization_Date='" + Convert.ToDateTime(txtRealization_Date.Text).ToString("MM-dd-yyyy") + "'" +
                                " Where Voucher_Account_ID=" + Convert.ToInt32(lblVoucher_Account_ID.Text.Equals("") ? "0" : lblVoucher_Account_ID.Text);
                        }
                    }
                    if (query != "")
                    {
                        DBClass.exectueQuery(query, tranObj, con);
                        tranObj.Commit();
                        lblMessage.Text = "Realization date has been uopdated successfully. ";
                        lblMessage.CssClass = "sucessfullMessage";
                        BindGrid();
                        upList.Update();
                    }
                }
            }
            catch (Exception ex)
            {
                if (tranObj != null)
                    tranObj.Rollback();
                lblMessage.Text = ex.Message;
                lblMessage.CssClass = "errorMessage";
            }
            finally
            {
                con.Close();
            }
        }


        protected void BindGrid()
        {
            if (txtAccount_Code_Name.Text != "" && txtFrom_Date.Text != "" && txtTo_Date.Text != "")
            {
                int Accout_ID = Convert.ToInt32(txtAccount_Code_Name.Text.Equals("") ? "0" : txtAccount_Code_Name.Text);
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                var qry = from vouch in db.GL_Vouchers
                          join tbl in db.GL_Voucher_Accounts on vouch.Voucher_ID equals tbl.Voucher_ID
                          where vouch.Voucher_Status == "Approved" && tbl.Realization_Date == null
                           && tbl.Account_ID == Accout_ID && vouch.Voucher_Date >= Convert.ToDateTime(txtFrom_Date.Text) && vouch.Voucher_Date <= Convert.ToDateTime(txtTo_Date.Text)

                          select new
                          {
                              Voucher_Account_ID = tbl.Voucher_account_ID,
                              Voucher_Date = vouch.Voucher_Date,
                              Voucher_No = vouch.Voucher_No,
                              Narration = tbl.Narration,
                              Serial_No = tbl.Serial_No,
                              DR = tbl.DR,
                              CR = tbl.CR
                          };
                gvReconsilationList.DataSource = qry;
                gvReconsilationList.DataBind();
            }
        }

    }
}