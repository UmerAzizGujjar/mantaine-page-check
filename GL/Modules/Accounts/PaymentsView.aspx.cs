using Infragistics.Web.UI.GridControls;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class PaymentsView : System.Web.UI.Page
    {
        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            if (Session["UserName"] == null || Session["Company_Name"] == null || Session["Company_ID"] == null || Session["Book_ID"] == null)
            {
                Session.Abandon();
                Response.Redirect("~/Account/Login.aspx", true);
            }
            else
            {
                string qury = "select plot_payments.*,GL_Accounts.Account_Name, AP_Vendors.Vendor_Name from plot_payments inner join GL_Accounts on GL_Accounts.Account_ID = Plot_Payments.Account_ID inner join AP_Vendors on AP_Vendors.Vendor_ID = Plot_Payments.Vendor_ID order by payment_id desc";
                sqlList.SelectCommand = qury;
                this.sqlList.ConnectionString = DBClass.ConnectionString();
            }
        }
        protected void Page_Load(object sender, EventArgs e)
        {
        
            //if (!IsPostBack)
            //    BindList();
        }
        /*
        private void BindList()
        {
            DataTable dtbList = new DataTable();
            dtbList = DBClass.getDataTable("Select * from AP_Purchases");
            grdCustomerList.DataSource = dtbList;
            grdCustomerList.DataBind();
        }
        protected void grdCustomerList_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                Label lblVendor_ID = (Label)e.Row.FindControl("lblVendor_ID");
                if (lblVendor_ID != null && lblVendor_ID.Text != "")
                {
                    lblVendor_ID.Text = DBClass.getField("select Vendor_Name from AP_Vendors where Vendor_ID=" + Convert.ToInt32(lblVendor_ID.Text));
                }
            }
        }

        protected void grdCustomerList_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Remove")
            {
                bool rowDeleted = DBClass.deleteRecord("Delete AP_Purchases Where Purchases_ID=" + Convert.ToInt32(e.CommandArgument) + ";Delete AP_Purchase_Items Where Purchases_ID=" + Convert.ToInt32(e.CommandArgument));
                if (rowDeleted)
                {
                    BindList();
                    upList.Update();
                }
            }
        }

        protected void grdCustomerList_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            grdCustomerList.PageIndex = e.NewPageIndex;
            BindList();
        }
         */
        protected void whdgList_ItemCommand(object sender, Infragistics.Web.UI.GridControls.HandleCommandEventArgs e)
        {
            if (e.CommandName == "Remove")
            {
                SqlTransaction tranObj = null;
                SqlConnection con = new SqlConnection(DBClass.ConnectionString());
                con.Open();
                tranObj = con.BeginTransaction();
                try
                {
                    //DataTable dtPlotsInSales = DBClass.getDataTable("Select * from ar_Sales_items where plot_ID in (select Plot_ID from ap_purchase_Items where purchases_ID=" + Convert.ToInt32(e.CommandArgument) + ")");
                    //if (dtPlotsInSales.Rows.Count > 0)
                    //{
                    //    lblMessage.Text = "Record cannot be deleted as it is being used in sales.";
                    //    lblMessage.CssClass = "errorMessage";
                    //}
                    //else
                    //{
                    //    string query = "Update Plots Set Plot_Status='Created' where Plot_ID in (select Plot_ID from AP_Purchase_Items where Purchases_ID=" + Convert.ToInt32(e.CommandArgument) + ") ; ";
                    //    //Delete Voucher account Details
                    //    query += "Delete GL_Voucher_Accounts where Voucher_ID=(select Voucher_ID From AP_Purchases where Purchases_ID=" + Convert.ToInt32(e.CommandArgument) + ") ; ";
                    //    //Delte Voucher
                    //    query += "Delete GL_Vouchers where Voucher_ID=(select Voucher_ID From AP_Purchases where Purchases_ID=" + Convert.ToInt32(e.CommandArgument) + ") ; ";

                    //    query += "Delete AP_Purchases Where Purchases_ID=" + Convert.ToInt32(e.CommandArgument) + ";Delete AP_Purchase_Items Where Purchases_ID=" + Convert.ToInt32(e.CommandArgument);
                    //    DBClass.exectueQuery(query, tranObj, con);
                    //    tranObj.Commit();
                    //    Response.Redirect(Request.RawUrl, false);
                    //    upList.Update();
                    //}
                    string q = "Delete from plot_payments where payment_id = " + e.CommandArgument.ToString();
                    q += "; Delete from plot_payments_items where payment_id = " + e.CommandArgument.ToString();
                    q += ";";
                    DBClass.exectueQuery(q, tranObj, con);
                    tranObj.Commit();
                    Response.Redirect(Request.RawUrl, false);
                    upList.Update();
                }
                catch (Exception exc)
                {
                    if (tranObj != null)
                        tranObj.Rollback();
                    throw new Exception(exc.Message);
                }
                finally
                {
                    con.Close();
                }
            }
        }
        protected void whdgList_RowIslandsPopulating(object sender, Infragistics.Web.UI.GridControls.ContainerRowCancelEventArgs e)
        {
            this.whdgList.RowIslandDataBinding += new RowIslandEventHandler(whdgList_RowIslandDataBinding);
        }
        void whdgList_RowIslandDataBinding(object sender, RowIslandEventArgs e)
        {
            // Sort a Column in PARENT BAND
            if (e.RowIsland.DataMember == "whdsList")
            {
                Sorting sort = e.RowIsland.Behaviors.Sorting;
                sort.SortedColumns.Add("ItemName", Infragistics.Web.UI.SortDirection.Descending);
            }

            // Sort a Column in CHILD BAND
            if (e.RowIsland.DataMember == "whdsList"
               && e.RowIsland.ParentRow == this.whdgList.GridView.Rows[1])
            {
                Sorting sort = e.RowIsland.Behaviors.Sorting;
                sort.SortedColumns.Add(e.RowIsland.Columns[1], Infragistics.Web.UI.SortDirection.Ascending);
            }
        }
    }
}