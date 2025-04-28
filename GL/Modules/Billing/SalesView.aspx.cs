using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using Infragistics.Web.UI.GridControls;
using System.Data.SqlClient;

namespace PMS
{
    public partial class SalesView : System.Web.UI.Page
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
                string qury = "Select Distinct ar_sales.Sales_ID,Invoice_No,Customer_Name,Sales_Date,Sales_Amount,Sales_Status"
                            + ", ar_sales.Voucher_ID,(Voucher_Type+' '+convert(varchar, Voucher_No)) as Voucher_Info"
                            + ", (SELECT DataValue_Description FROM DataValues WHERE DataValue_Name = dbo.AR_Sales_Items.Salesman AND ValueSet_ID = 9) AS Salesman"
                            + " from ar_sales LEFT JOIN AR_Customers ON ar_sales.Customer_ID=AR_Customers.Customer_ID"
                            + " left join gl_vouchers on ar_sales.voucher_id=gl_vouchers.voucher_id"
                            + " INNER JOIN AR_Sales_Items ON Ar_Sales.Sales_ID = AR_Sales_Items.Sales_ID"
                            + " where ar_sales.company_id= " + AppConfig.Company_ID + " order by Sales_id desc";
                                            sqlList.SelectCommand = qury;
                this.sqlList.ConnectionString = DBClass.ConnectionString();
            }
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            
            if (Request.QueryString["Win"] != null)
            {
                Menu MenuBar = (Menu)this.Page.Master.FindControl("MenuBar");
                MenuBar.Visible = false;
            }
            //if (!IsPostBack)
            //    BindSalesList();
        }
        /*
        protected void grdSalesList_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Remove")
            {
                string query = "Update Plots Set Plot_Status='Purchased' where Plot_ID=(select Plot_ID from AR_Sales_Items where Sales_ID=" + Convert.ToInt32(e.CommandArgument) + ");";
                query += "Delete Ar_Sales_Items Where Sales_ID=" + Convert.ToInt32(e.CommandArgument) + ";Delete Ar_Sales Where Sales_ID=" + Convert.ToInt32(e.CommandArgument);

                DBClass.exectueQuery(query);
                BindSalesList();
                upList.Update();
            }
        }
      
        private void BindSalesList()
        {
            DataTable dtbSalesList = new DataTable();
            dtbSalesList = DBClass.getDataTable("Select * from Ar_Sales");
            grdSalesList.DataSource = dtbSalesList;
            grdSalesList.DataBind();
        }

        protected void grdSalesList_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                Label lblCustomer_ID = (Label)e.Row.FindControl("lblCustomer_ID");

                if (lblCustomer_ID != null && lblCustomer_ID.Text != "")
                {
                    lblCustomer_ID.Text = DBClass.getField("select Customer_Name From Ar_Customers Where Customer_ID=" + Convert.ToInt32(lblCustomer_ID.Text));
                }

            }
        }

        protected void grdSalesList_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            grdSalesList.PageIndex = e.NewPageIndex;
            BindSalesList();
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
                    string query = "Update Plots Set Plot_Status='Purchased' where Plot_ID in (select Plot_ID from AR_Sales_Items where Sales_ID=" + Convert.ToInt32(e.CommandArgument) + ") ; ";
                    //Delete Voucher account Details
                    query += "Delete GL_Voucher_Accounts where Voucher_ID=(select Voucher_ID From AR_Sales where sales_ID=" + Convert.ToInt32(e.CommandArgument) + ") ; ";
                    //Delte Voucher
                    query += "Delete GL_Vouchers where Voucher_ID=(select Voucher_ID From AR_Sales where sales_ID=" + Convert.ToInt32(e.CommandArgument) + ") ; ";
                    //Delete Sales
                    query += "Delete Ar_Sales_Items Where Sales_ID=" + Convert.ToInt32(e.CommandArgument) + ";Delete Ar_Sales Where Sales_ID=" + Convert.ToInt32(e.CommandArgument);

                    DBClass.exectueQuery(query, tranObj, con);
                    tranObj.Commit();
                    Response.Redirect(Request.RawUrl, false);
                    upList.Update();

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