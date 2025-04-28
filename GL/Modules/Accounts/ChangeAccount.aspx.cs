using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class ChangeAccount : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            
            if (!IsPostBack)
            {
                BindAccounts();
            }
        }

        private void BindAccounts()
        {
           
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                string query = "";
                if (txtNewAccount_ID.Text != "" && txtOldAccount_ID.Text != ""
                && txtNewAccount_ID.Text != txtOldAccount_ID.Text)
                {

                    query += "Update Plots set account_ID=" + Convert.ToInt32(txtNewAccount_ID.Text) + " where account_ID=" + Convert.ToInt32(txtOldAccount_ID.Text);

                    query += "Update AR_CUstomers set account_ID=" + Convert.ToInt32(txtNewAccount_ID.Text) + " where account_ID=" + Convert.ToInt32(txtOldAccount_ID.Text);

                    query += "Update AP_Vendors set account_ID=" + Convert.ToInt32(txtNewAccount_ID.Text) + " where account_ID=" + Convert.ToInt32(txtOldAccount_ID.Text);

                    query += "Update GL_Voucher_Accounts set account_ID=" + Convert.ToInt32(txtNewAccount_ID.Text) + " where account_ID=" + Convert.ToInt32(txtOldAccount_ID.Text) + ";Delete GL_Accounts where Account_ID=" + Convert.ToInt32(txtOldAccount_ID.Text) + ";";

                    DBClass.exectueQuery(query, tranObj, con);
                    tranObj.Commit();
                    ClearForm();
                    lblMessage.Text = "Account has been updated successfully";
                    lblMessage.CssClass = "sucessfullMessage";
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

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        private void ClearForm()
        {
            lblMessage.Text = "";
            BindAccounts();
          
        }
    }
}