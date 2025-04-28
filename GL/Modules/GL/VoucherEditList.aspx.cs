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
    public partial class VoucherEditList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            
            if (!IsPostBack)
            {
                BindVoucherTypeList();
            }
        }

        private void BindVoucherTypeList()
        {
            DataTable dtVoucherType = new DataTable();
            dtVoucherType = DBClass.getDataTable("Select * from GL_Voucher_Types");
            if (dtVoucherType.Rows.Count > 0)
            {
                lstVoucherType.DataSource = dtVoucherType;
                lstVoucherType.DataTextField = "Voucher_Name";
                lstVoucherType.DataValueField = "Voucher_Type";
                lstVoucherType.DataBind();
            }
            ChekAllVouchers();
        }
        private void ChekAllVouchers()
        {
            foreach (ListItem item in lstVoucherType.Items)
            {
                item.Selected = true;
            }
        }
        private void UnChekAllVouchers()
        {
            foreach (ListItem item in lstVoucherType.Items)
            {
                item.Selected = false;
            }
        }

        protected void btnPreview_Click(object sender, EventArgs e)
        {
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                if (lstVoucherType.SelectedValue == "")
                    return;
                string sql = "delete rptSelectionParameters ;";
                foreach (ListItem item in lstVoucherType.Items)
                {
                    if (item.Selected)
                    {
                        sql += "Insert into rptSelectionParameters (Code) values('" + item.Value + "');";
                    }
                }
                DBClass.exectueQuery(sql, tranObj, con);
                tranObj.Commit();
                string query = "ReportName=VoucherEditList&ReportTitle=Journal Voucher List from " + txtStartDate.Text + " to " + txtEndDate.Text + "&startDate=" + txtStartDate.Text + "&endDate=" + txtEndDate.Text;
                string path = @"../../ReportViewer.aspx?" + query;
                ScriptManager.RegisterStartupScript(this, typeof(string), "OPEN_WINDOW", "window.open('" + path + "');", true);
            }
            catch (Exception ex)
            {
                if (tranObj != null)
                    tranObj.Rollback();
            }

            finally
            {
                con.Close();
            }
        }
    }
}