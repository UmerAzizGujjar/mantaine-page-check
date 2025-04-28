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
    public partial class Sales : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
           
            if (!IsPostBack)
            {
                lblMessage.Text = "";
                BindDropdownList();
                ClearForm();
                if (Request.QueryString["ID"] != null)
                {
                    FillSalesForm(Convert.ToInt32(Request.QueryString["ID"]));
                }
                if (ViewState["dtPlots"] == null)
                    CreateDataTable();
            }
        }

        private void BindDropdownList()
        {
            object valueset; //declare a single object for all valueset
            valueset = DBClass.GetValueSet("Cost Center");
            ddlCostCenter.DataSource = valueset;
            ddlCostCenter.DataTextField = "DataValue_Description";
            ddlCostCenter.DataValueField = "DataValue_Name";
            //ddlCostCenter.Items.Add(new ListItem("Please Select", "0"));
            ddlCostCenter.DataBind();

            valueset = DBClass.GetValueSet("Salesman");
            ddlSalesman.DataSource = valueset;
            ddlSalesman.DataTextField = "DataValue_Description";
            ddlSalesman.DataValueField = "DataValue_Name";
            ddlSalesman.Items.Add(new ListItem("Please Select", "0"));
            ddlSalesman.DataBind();
        }
        private void FillSalesForm(int Sales_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Ar_Sale sale = new Ar_Sale();

            sale = (from tbl in db.Ar_Sales
                    where tbl.Sales_ID == Sales_ID
                    select tbl).FirstOrDefault();
            if (sale != null)
            {
                txtSales_ID.Text = sale.Sales_ID.ToString();
                txtRemarks.Text = sale.Remarks;
                txtStatus.Text = sale.Sales_Status;
                cbDelivered.Checked = Convert.ToBoolean(sale.Delivered);
                txtFileNo.Text = sale.File_No; 
                txtInvoiceNo.Text = Convert.ToString(sale.Invoice_No);
                hdfSales_ID.Value = sale.Sales_ID.ToString();
                if (sale.Sales_Date != null)
                    txtSales_Date.Text = Convert.ToDateTime(sale.Sales_Date).ToString("dd MMM yyyy");
                if (sale.Sales_Status == "Approved")
                {
                    btnSave.Enabled = false;
                    lblMessage.Text = "Cannot edit posted entry";
                    btnVoucherPreview.Visible = true;
                }
                bool ApprovelAllowed = Convert.ToBoolean(DBClass.getField("select  isnull(AllowUnapproveVoucher,0) from aspnet_users where username='" + AppConfig.UserName + "'"));
                if (sale.Sales_Status == "Approved" && ApprovelAllowed)
                    btnUnApprove.Visible = true;
                DataTable dtPlots = new DataTable();
                string sql = "select sitem.ID as ID, sitem.Plot_ID,([Plot_Number]+' - '+dbo.GetDataValueName('Sector',Sector)+' - '+" +
                    "dbo.GetDataValueName('Block',Block)+' - '+dbo.GetDataValueName('Area',Area)+' - '+dbo.GetDataValueName('Plot Type',Plot_Type)+' - '+" +
                    "dbo.GetDataValueName('Category',Category)) as Plot_Number,sitem.Rate,Cost_Center, " +
                    "Salesman from dbo.AR_Sales_Items sitem inner join Plots p on sitem.Plot_ID=p.Plot_ID " +
                     " where sitem.Sales_ID=" + Sales_ID;

                dtPlots = DBClass.getDataTable(sql);
                ViewState["dtPlots"] = dtPlots;
                if (dtPlots.Rows.Count > 0 && dtPlots.Rows[0]["Cost_Center"] != null)
                {
                    if (ddlCostCenter.Items.FindByValue(dtPlots.Rows[0]["Cost_Center"].ToString()) != null)
                        ddlCostCenter.SelectedValue = dtPlots.Rows[0]["Cost_Center"].ToString();
                }
                if (dtPlots.Rows.Count > 0 && dtPlots.Rows[0]["Salesman"] != null)
                {
                    if (ddlSalesman.Items.FindByValue(dtPlots.Rows[0]["Salesman"].ToString()) != null)
                        ddlSalesman.SelectedValue = dtPlots.Rows[0]["Salesman"].ToString();
                }
                BindPlotesGrid();
                btnSave.Text = "Update";
            }
        }
        protected void ClearForm()
        {
            txtInvoiceNo.Text = Convert.ToString(DBClass.GetNewInvoiceNo());
            txtSales_ID.Text = "(New)";
            txtCustomer.Text = "";
            txtRemarks.Text = "";
            //ddlDue_Installment_After_months.SelectedValue = "0";
            //txtMonthly_Installment.Text = "";
            //txtTotal_Installment.Text = "";
            //txtCost_OF_Land.Text = "";
            //txtDevelopment_Charges.Text = "";
            //txtOther.Text = "";
            //txtSales_Amount.Text = "";
            //txtDiscount.Text = "";
            //txtNet_Value.Text = "";

            btnSave.Text = "Save";
        }
        protected void btnSave_Click(object sender, EventArgs e)
        {
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            db.Connection.Open();
            db.Transaction = db.Connection.BeginTransaction();
            tranObj = con.BeginTransaction();
            try
            {
                lblMessage.Text = "";
                if (grdPlotsList.Rows.Count < 1)
                {
                    lblMessage.Text = "Plot is required.";
                    lblMessage.CssClass = "errorMessage";
                    return;
                }
                int salesID = 0;
                decimal salesAmount = 0;

                if (!Page.IsValid)
                    return;
                Ar_Sale sale;
                if (btnSave.Text == "Save")
                {
                    sale = new Ar_Sale();
                }
                else
                {
                    sale = (from tbl in db.Ar_Sales
                            where tbl.Sales_ID == Convert.ToInt32(txtSales_ID.Text)
                            select tbl).FirstOrDefault();

                    var si = from p in db.AR_Sales_Items
                             where p.Sales_ID == sale.Sales_ID
                             select p;
                    string query = "Update Plots Set Plot_Status='Purchased' where Plot_ID in (select Plot_ID from AR_Sales_Items where Sales_ID=" + sale.Sales_ID + ")";
                    DBClass.exectueQuery(query,tranObj,con);
                    db.AR_Sales_Items.DeleteAllOnSubmit(si);
                    db.SubmitChanges();
                    lblMessage.Text = "Data has been update sucessfully";
                }
                sale.Sales_Status = txtStatus.Text;
                sale.Delivered = cbDelivered.Checked;
                if(txtFileNo.Enabled)
                    sale.File_No = txtFileNo.Text;
                sale.Customer_ID = Convert.ToInt32(txtCustomer.Text);
                sale.Company_ID = AppConfig.Company_ID;
                //if (txtCost_OF_Land.Text != "")
                //    sale.Cost_Of_Land = Convert.ToDecimal(txtCost_OF_Land.Text);
                //if (txtDevelopment_Charges.Text != "")
                //    sale.Development_Charges = Convert.ToDecimal(txtDevelopment_Charges.Text);
                //if (txtDiscount.Text != "")
                //    sale.Discount = Convert.ToDecimal(txtDiscount.Text);
                //if (txtInstallment_Date.Text != "")
                //    sale.Installment_Date = Convert.ToDateTime(txtInstallment_Date.Text);
                sale.Sales_Date = Convert.ToDateTime(txtSales_Date.Text);
                //if (txtMonthly_Installment.Text != "")
                //    sale.Monthly_Installment = Convert.ToDecimal(txtMonthly_Installment.Text);
                //if (txtNet_Value.Text != "")
                //    sale.Net_Value = Convert.ToDecimal(txtNet_Value.Text);
                //if (txtSales_Amount.Text != "")
                //    sale.Sales_Amount = Convert.ToDecimal(txtSales_Amount.Text);
                //if (txtTotal_Installment.Text != "")
                //    sale.Total_Installments = Convert.ToInt32(txtTotal_Installment.Text);
                //if (ddlDue_Installment_After_months.SelectedValue != "0")
                //    sale.Due_Installments_After_Months = Convert.ToInt32(ddlDue_Installment_After_months.SelectedValue);
                sale.Remarks = txtRemarks.Text;
                sale.Invoice_No = Convert.ToInt32(txtInvoiceNo.Text);
                if (btnSave.Text == "Save")
                {
                    sale.Sales_Status = "Created";
                    sale.Invoice_No = DBClass.GetNewInvoiceNo();
                    sale.Voucher_ID = 0;
                    db.Ar_Sales.InsertOnSubmit(sale);
                    lblMessage.Text = "Data has been save sucessfully";
                }
                else
                {
                    lblMessage.Text = "Data has been update sucessfully";
                }
                db.SubmitChanges();
                salesID = sale.Sales_ID;
                if (grdPlotsList.Rows.Count > 0)
                {
                    string query = "";
                    foreach (GridViewRow row in grdPlotsList.Rows)
                    {
                        AR_Sales_Item salesItem = new AR_Sales_Item();
                        salesItem.Sales_ID = salesID;
                        salesItem.Plot_ID = Convert.ToInt32(((Label)row.FindControl("lblPlotID")).Text);
                        salesItem.Rate = Convert.ToDecimal(((Label)row.FindControl("lblRate")).Text);
                        salesItem.Cost_Center = ddlCostCenter.SelectedValue;
                        salesItem.Salesman = ddlSalesman.SelectedValue;
                        db.AR_Sales_Items.InsertOnSubmit(salesItem);
                        salesAmount += salesItem.Rate.Value;
                        //query += "update plots set Plot_Status='Sold' where Plot_ID=" + Convert.ToInt32(((Label)row.FindControl("lblPlotID")).Text) + " ; ";
                    }
                    //if (query != "")
                    //    DBClass.exectueQuery(query);
                }
                sale.Sales_Amount = salesAmount;
                db.SubmitChanges();
                tranObj.Commit();
                db.Transaction.Commit();
                ClearForm();
                Response.Redirect("~/SalesView.aspx", false);
                //lblMessage.CssClass = "sucessfullMessage";
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
                db.Connection.Close();
            }
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            AddTodataTable();
            BindPlotesGrid();
            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "clearToken", "$('#ctl00_MainContent_txtPlot_Number').tokenInput('clear');", true);
        }
        private void CreateDataTable()
        {
            DataTable dtPlots = new DataTable();
            dtPlots.Columns.Add("ID");
            dtPlots.Columns.Add("Plot_ID");
            dtPlots.Columns.Add("Plot_Number");
            dtPlots.Columns.Add("Rate");
            ViewState["dtPlots"] = dtPlots;
        }
        private void BindPlotesGrid()
        {
            DataTable dtPlots = ViewState["dtPlots"] as DataTable;
            grdPlotsList.DataSource = dtPlots;
            grdPlotsList.DataBind();
        }
        private void AddTodataTable()
        {
            if (!PlotAlreadyExists())
            {
                DataTable dtPlots = ViewState["dtPlots"] as DataTable;
                if (hdfRowIndex.Value != "")
                {
                    int rowindex = Convert.ToInt32(hdfRowIndex.Value);

                    dtPlots.Rows.RemoveAt(rowindex);
                    if (txtRates.Text != "" && dtPlots != null)
                    {
                        DataRow dr = dtPlots.NewRow();
                        dr["Plot_Number"] = hdfPlotNumber.Value;
                        dr["Plot_ID"] = txtPlot_Number.Text;
                        dr["Rate"] = txtRates.Text;
                        dr["ID"] = "0";
                        dtPlots.Rows.InsertAt(dr, rowindex);
                        lblErrorMessage.Text = "";
                    }
                }
                else
                {
                    DataRow dr = dtPlots.NewRow();
                    dr["Plot_Number"] = hdfPlotNumber.Value;
                    dr["Plot_ID"] = txtPlot_Number.Text;
                    dr["Rate"] = txtRates.Text;
                    dr["ID"] = "0";
                    dtPlots.Rows.Add(dr);
                }
                ViewState["dtPlots"] = dtPlots;
            }
            ClearPlotForm();
        }

        private void ClearPlotForm()
        {
            txtRates.Text = "";
            hdfRowIndex.Value = "";
            btnAdd.Text = "Add";
        }
        protected bool PlotAlreadyExists()
        {
            lblErrorMessage.Text = "";
            bool exists = false;
            if (txtPlot_Number.Text != "")
            {
                //string PlotPurchased = DBClass.getField("Select Plot_ID From AR_Sales_Items where Plot_ID=" + Convert.ToInt32(txtPlot_Number.Text));
                //if (PlotPurchased != "" && PlotPurchased != "There is no row at position 0.")
                //{
                //    lblErrorMessage.Text = "Plot already sold.";
                //    exists = true;
                //}
                foreach (GridViewRow row in grdPlotsList.Rows)
                {
                    Label lblPlotID = (Label)row.FindControl("lblPlotID");
                    if (hdfRowIndex.Value != "" && lblPlotID != null)
                    {

                        if (txtPlot_Number.Text == lblPlotID.Text && Convert.ToInt32(hdfRowIndex.Value) != row.RowIndex)// && PlotPurchased != lblPlotID.Text)
                        {
                            lblErrorMessage.Text = "Plot already sold.";
                            exists = true;
                            break;
                        }
                        else
                            exists = false;
                    }
                    else
                    {
                        if (txtPlot_Number.Text == lblPlotID.Text)
                        {
                            lblErrorMessage.Text = "Plot already sold.";
                            exists = true;
                            break;
                        }
                    }

                }
            }
            return exists;
        }
        protected void grdPlotsList_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            DataTable dtPlots = (DataTable)ViewState["dtPlots"];
            DataRow drCurrentRow = null;
            int rowIndex = Convert.ToInt32(e.RowIndex);
            if (dtPlots.Rows.Count > 0)
            {
                dtPlots.Rows.Remove(dtPlots.Rows[rowIndex]);
                drCurrentRow = dtPlots.NewRow();
                ViewState["dtPlots"] = dtPlots;
            }
            BindPlotesGrid();
        }
        protected void grdPlotsList_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "SelectRecord")
            {
                int rowIndex = Convert.ToInt32(e.CommandArgument);
                string Plot_ID = ((Label)grdPlotsList.Rows[rowIndex].FindControl("lblPlotID")).Text;
                string Plot_Number = ((Label)grdPlotsList.Rows[rowIndex].FindControl("lblPlotNumber")).Text; ;
                string inputString = String.Format(@"id:" + Plot_ID + @",name: '{0}'", Plot_Number);
                ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "tmp", "$('#ctl00_MainContent_txtPlot_Number').tokenInput('add', {" + inputString + "});", true);
                txtRates.Text = Convert.ToDouble(((Label)grdPlotsList.Rows[rowIndex].FindControl("lblRate")).Text.Equals("") ? "0" : ((Label)grdPlotsList.Rows[rowIndex].FindControl("lblRate")).Text).ToString("n2");
                hdfRowIndex.Value = rowIndex.ToString();
                btnAdd.Text = "Update";
            }
        }
        protected void btnVoucherPreview_Click(object sender, EventArgs e)
        {
            if (txtSales_ID.Text != "(New)")
            {
                string voucherID = DBClass.getField("select Voucher_ID from AR_Sales where Sales_ID=" + txtSales_ID.Text);
                if (voucherID != "0")
                {
                    string query = "ReportName=Voucher&Voucher_ID=" + voucherID;
                    string path = @"\ReportViewer.aspx?" + query;
                    ScriptManager.RegisterStartupScript(this, typeof(string), "OPEN_WINDOW", "window.open('" + path + "');", true);
                }
                //else
                //    lblMessage.Text = "Sales has not been approved yet.";
            }
        }
        protected void btnUnApprove_Click(object sender, EventArgs e)
        {
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            db.Connection.Open();
            db.Transaction = db.Connection.BeginTransaction();
            tranObj = con.BeginTransaction();
            try
            {
                if (txtSales_ID.Text != "(New)")
                {
                    //if (btnUnApprove.Text == "")
                    //{
                    long Voucher_ID = 0;
                    int Sales_ID = Convert.ToInt32(txtSales_ID.Text);
                    Ar_Sale sales = new Ar_Sale();
                    sales = (from tbl in db.Ar_Sales
                             where tbl.Sales_ID == Sales_ID
                             select tbl).FirstOrDefault();
                    if (sales != null)
                    {
                        Voucher_ID = sales.Voucher_ID;
                        sales.Sales_Status = "Created";

                        sales.Approved_Time = DateTime.Now;
                        db.SubmitChanges();
                        string query = "Delete Gl_Voucher_Accounts where Voucher_ID=" + Voucher_ID + "; ";
                        query += "Update Plots set plot_Status='Purchased' where Plot_ID in (Select Plot_ID from ar_sales_items where Sales_ID=" + sales.Sales_ID + ");";
                        // query += "Delete GL_Vouchers where Voucher_ID=" + Voucher_ID + ";";
                        // query += "Delete AR_Sales set Voucher_ID= null where sales_ID=" + sales.Sales_ID + ";";
                        DBClass.exectueQuery(query, tranObj, con);

                    }

                    tranObj.Commit();
                    db.Transaction.Commit();
                    Response.Redirect(Request.RawUrl);

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
                db.Connection.Close();
            }
        }

        protected void btnCancelPlot_Click(object sender, EventArgs e)
        {
            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "clearToken", "$('#ctl00_MainContent_txtPlot_Number').tokenInput('clear');", true);
            ClearPlotForm();
        }
    }
}