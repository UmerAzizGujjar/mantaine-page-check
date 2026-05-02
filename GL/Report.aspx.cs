using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Runtime.InteropServices.ComTypes;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using static PMS.Vendor;

namespace PMS
{
    public partial class Report : System.Web.UI.Page
    {

        protected void Page_Load(object sender, EventArgs e)

        {
            DataBaseDataContext db = new DataBaseDataContext();
            if (!IsPostBack)
            {
                lblSpecificAccount.Visible = false;
                txtSpecificAccount.Visible = false;
                switch (Request.QueryString["Type"])
                {
                    case "BS":
                        DateDiv.Visible = true;
                        AccountInfoDiv.Visible = false;
                        AccountDiv.Visible = false;
                        plhAllAcounts.Visible = false;
                        break;
                    case "BSD":
                        DateDiv.Visible = true;
                        txtEnd_Date.Visible = false;
                        enDate.Visible = false;
                        levelChekBox.Visible = true;
                        HideZerroBalance.Visible = true;
                        ExportDiv.Visible = true;
                        break;
                    case "BSC":
                        DateDiv.Visible = true;
                        txtEnd_Date.Visible = false;
                        enDate.Visible = false;
                        comparisonDateDiv.Visible = true;
                        Comparison_DateTo.Visible = false;
                        txtComarison_DateTo.Visible = false;
                        AccountInfoDiv.Visible = true;
                        AccountDiv.Visible = false;
                        levelChekBox.Visible = true;
                        HideZerroBalance.Visible = true;
                        ExportDiv.Visible = true;
                        break;
                    case "VL":
                        phMultiLedger.Visible = false;
                        txtStart_Date.Visible = true;
                        DateDiv.Visible = true;
                        stDate.Visible = true;
                        txtEnd_Date.Visible = true;
                        enDate.Visible = true;
                        AccountInfoDiv.Visible = false;
                        levelChekBox.Visible = false;
                        CostCenterDiv.Visible = false;
                        chbAllAccounts.Visible = false;
                        lblSpecificAccount.Visible = false;
                        txtSpecificAccount.Visible = false;
                        lblCostCenter.Visible = false;
                        ddlCostCenter.Visible = false;
                        chbAllAccounts.Checked = false;
                        Vendordiv.Visible = true;
                        string connStr = ConfigurationManager.ConnectionStrings["ASPGLConnectionString"].ConnectionString;
                        using (SqlConnection conn = new SqlConnection(connStr))
                        {
                            string query = "SELECT Vendor_ID, Vendor_Name FROM AP_Vendors";
                            SqlCommand cmd = new SqlCommand(query, conn);
                            conn.Open();
                            SqlDataReader reader = cmd.ExecuteReader();
                            VendorList.DataSource = reader;
                            VendorList.DataTextField = "Vendor_Name";
                            VendorList.DataValueField = "Vendor_ID";
                            VendorList.DataBind();
                            conn.Close();
                        }

                        VendorList.Items.Insert(0, new ListItem("All", "0"));
                        break;

                    case "VB":
                        phMultiLedger.Visible = false;
                        txtStart_Date.Visible = true;
                        DateDiv.Visible = true;
                        stDate.Visible = true;
                        txtEnd_Date.Visible = false;
                        enDate.Visible = false;
                        AccountInfoDiv.Visible = false;
                        levelChekBox.Visible = false;
                        CostCenterDiv.Visible = false;
                        chbAllAccounts.Visible = false;
                        lblSpecificAccount.Visible = false;
                        txtSpecificAccount.Visible = false;
                        lblCostCenter.Visible = false;
                        ddlCostCenter.Visible = false;
                        chbAllAccounts.Checked = false;
                        Vendordiv.Visible = false;

                        break;
                    case "COA":
                        DateDiv.Visible = true;
                        stDate.Visible = false;
                        txtStart_Date.Visible = false;
                        AccountInfoDiv.Visible = false;
                        AccountDiv.Visible = false;
                        levelChekBox.Visible = true;
                        plhAllAcounts.Visible = false;
                        break;
                    case "PL":
                        AccountInfoDiv.Visible = false;
                        AccountDiv.Visible = false;
                        plhAllAcounts.Visible = false;
                        HideZerroBalance.Visible = false;
                        ExportDiv.Visible = true;
                        DateDiv.Visible = true;
                        break;
                    case "PLD":
                        DateDiv.Visible = true;
                        levelChekBox.Visible = true;
                        HideZerroBalance.Visible = true;
                        AccountInfoDiv.Visible = true;
                        AccountDiv.Visible = false;
                        ExportDiv.Visible = true;
                        break;
                    case "AB":
                        DateDiv.Visible = true;
                        levelChekBox.Visible = false;
                        HideZerroBalance.Visible = true;
                        AccountInfoDiv.Visible = true;
                        AccountDiv.Visible = true;
                        CostCenterDiv.Visible = false;
                        BindCostCenterDDL();
                        break;
                    case "PLC":
                        DateDiv.Visible = true;
                        comparisonDateDiv.Visible = true;
                        levelChekBox.Visible = true;
                        HideZerroBalance.Visible = true;
                        AccountInfoDiv.Visible = true;
                        AccountDiv.Visible = false;
                        ExportDiv.Visible = true;
                        break;
                    case "DA":
                        DateDiv.Visible = true;
                        AccountInfoDiv.Visible = false;
                        AccountDiv.Visible = false;
                        plhAllAcounts.Visible = false;
                        txtStart_Date.Visible = true;
                        stDate.Visible = true;
                        break;
                    case "ML":
                        phMultiLedger.Visible = true;
                        DateDiv.Visible = true;
                        AccountInfoDiv.Visible = true;
                        AccountDiv.Visible = false;
                        ExportDiv.Visible = true;
                        levelChekBox.Visible = false;
                        plhAllAcounts.Visible = false;
                        chbAllAccounts.Visible = true;
                        plhAllAcounts.Visible = true;
                        lblSpecificAccount.Visible = false;
                        txtSpecificAccount.Visible = false;
                        lblCostCenter.Visible = false;
                        ddlCostCenter.Visible = false;
                        chbAllAccounts.Checked = false;
                        if (ViewState["dtAccounts"] == null)
                            CreateDataTable();
                        break;
                    //case "VB":
                    //    phMultiLedger.Visible = false;
                    //    DateDiv.Visible = true;
                    //    AccountInfoDiv.Visible = false;
                    //    AccountDiv.Visible = false;
                    //    levelChekBox.Visible = false;
                    //    plhAllAcounts.Visible = false;
                    //    chbAllAccounts.Visible = false;
                    //    plhAllAcounts.Visible = false;
                    //    lblSpecificAccount.Visible = false;
                    //    txtSpecificAccount.Visible = false;
                    //    lblCostCenter.Visible = false;
                    //    ddlCostCenter.Visible = false;
                    //    chbAllAccounts.Checked = false;
                    //    break;
                    case "BSA":
                        AccountInfoDiv.Visible = true;
                        AccountDiv.Visible = false;
                        plhAllAcounts.Visible = false;
                        break;

                    case "BSN":
                        enDate.Visible = true;
                        txtEnd_Date.Visible = true;
                        AccountInfoDiv.Visible = false;
                        AccountDiv.Visible = false;
                        plhAllAcounts.Visible = false;
                        break;

                    case "TBD":
                        DateDiv.Visible = true;
                        levelChekBox.Visible = false; 
                        ExportDiv.Visible = true;
                        AccountInfoDiv.Visible = false;
                        AccountDiv.Visible = false;
                        plhAllAcounts.Visible = false;
                        break;
                    case "TB":
                        DateDiv.Visible = true;
                        ExportDiv.Visible = true;
                        levelChekBox.Visible = true;
                        AccountInfoDiv.Visible = false;
                        AccountDiv.Visible = false;
                        plhAllAcounts.Visible = false;
                        break;
                    case "TC":
                        DateDiv.Visible = true;
                        AccountInfoDiv.Visible = false;
                        ExportDiv.Visible = true;
                        AccountDiv.Visible = false;
                        plhAllAcounts.Visible = false;
                        break;
                    case "TBDC":
                        levelChekBox.Visible = true;
                        plhAllAcounts.Visible = false;
                        ExportDiv.Visible = true;
                        DateDiv.Visible = true;
                        levelChekBox.Visible = true;
                        HideZerroBalance.Visible = true;
                        AccountInfoDiv.Visible = true;
                        AccountDiv.Visible = false;
                        break;
                    case "TBC":
                        chbAllAccounts.Visible = false;
                        AccountInfoDiv.Visible = true;
                        AccountDiv.Visible = false;
                        ExportDiv.Visible = true;
                        levelChekBox.Visible = false;
                        DateDiv.Visible = true;
                        CostCenterDiv.Visible = true;
                        BindCostCenterDDL();
                        break;
                    case "CBS":
                        DateDiv.Visible = true;
                        chkExportPDF.Visible = true;
                        txtEnd_Date.Visible = true;
                        AccountInfoDiv.Visible = true;
                        CostCenterDiv.Visible = false;
                        BindCostCenterDDL();
                        break;
                    case "CB":
                        DateDiv.Visible = true;
                        chkExportPDF.Visible = true;
                        txtEnd_Date.Visible = true;
                        AccountInfoDiv.Visible = true;
                        CostCenterDiv.Visible = false;
                        BindCostCenterDDL();
                        break;
                    case "TBB":
                        chbAllAccounts.Visible = false;
                        lblCostCenter.Text = "Branch Name";
                        AccountInfoDiv.Visible = false;
                        AccountDiv.Visible = false;
                        levelChekBox.Visible = false;
                        txtStart_Date.Visible = true;
                        stDate.Visible = true;
                        enDate.Visible = true;
                        txtEnd_Date.Visible = true;
                        plhAllAcounts.Visible = true;
                        BindCostCenterDDL();
                        break;
                    case "LBC":
                        DepartmentDiv.Visible = true;
                        CostCenterDiv.Visible = true;
                        plhAllAcounts.Visible = true;
                        ExportDiv.Visible = true;
                        DateDiv.Visible = true;
                        BindCostCenterDDL();
                        BindDepartmentDDL();
                        break;
                    default:
                        break;
                }
            }
        }

        private void BindVoucherTypeDropdownList()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var list = (from lst in db.GL_Voucher_Types
                        select lst).ToList();
            ddlVoucher_Type.DataSource = list;
            ddlVoucher_Type.DataTextField = "Voucher_Name";
            ddlVoucher_Type.DataValueField = "Voucher_Type";
            ddlVoucher_Type.Items.Add(new ListItem("Please Select", "0"));
            ddlVoucher_Type.DataBind();
        }

        private void BindSalesmanDropDownlists()
        {
            object valueset; //declare a single object for all valueset
            valueset = DBClass.GetValueSet("Sale Person");
            ddlSalesman.DataSource = valueset;
            ddlSalesman.DataTextField = "DataValue_Description";
            ddlSalesman.DataValueField = "DataValue_Name";
            ddlSalesman.Items.Add(new ListItem("All", "0"));
            ddlSalesman.DataBind();
        }
        private void BindCostCenterDDL()
        {
            if (Request.QueryString["Type"] == "TBB")
            {

            }
            else
            {
                object valueset;
                valueset = DBClass.GetValueSet("Cost Center");
                ddlCostCenter.DataSource = valueset;
                ddlCostCenter.DataTextField = "DataValue_Description";
                ddlCostCenter.DataValueField = "DataValue_Name";
                ddlCostCenter.Items.Add(new ListItem("All", "0"));
                ddlCostCenter.DataBind();
            }

        }

        private void BindDepartmentDDL()
        {
            if (Request.QueryString["Type"] == "LBC")
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                object valueset; //declare a single object for all valueset          
                valueset = DBClass.GetValueSet("Department");
                ddlDepartment.DataSource = valueset;
                ddlDepartment.DataTextField = "DataValue_Description";
                ddlDepartment.DataValueField = "DataValue_Name";
                ddlDepartment.Items.Add(new ListItem("All", "0"));
                ddlDepartment.DataBind();
            }
        }
        protected void btnAdd_Click(object sender, EventArgs e)
        {
            AddTodataTable();
            BindPlotesGrid();

            upAccountList.Update();
        }
        private void CreateDataTable()
        {
            DataTable dtAccounts = new DataTable();

            dtAccounts.Columns.Add("Account_ID");
            dtAccounts.Columns.Add("Account_Code");
            dtAccounts.Columns.Add("Account_Name");

            ViewState["dtAccounts"] = dtAccounts;
        }
        private void BindPlotesGrid()
        {
            DataTable dtAccounts = ViewState["dtAccounts"] as DataTable;
            grdAccountsList.DataSource = dtAccounts;
            grdAccountsList.DataBind();
            upAccountList.Update();
        }
        private void AddTodataTable()
        {
            if (!AccountAlreadyExists())
            {
                DataTable dtAccounts = ViewState["dtAccounts"] as DataTable;
                //string[] Account_Code_Name = ddlAccountCode.SelectedItem.Text.Split('-');
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                GL_Account account = (from acc in db.GL_Accounts
                                      where acc.Account_ID == Convert.ToInt32(txtAccountCode.Text)
                                      select acc).FirstOrDefault();
                if (hdfRowIndex.Value != "")
                {
                    int rowindex = Convert.ToInt32(hdfRowIndex.Value);

                    dtAccounts.Rows.RemoveAt(rowindex);
                    if (txtAccountCode.Text != "")
                    {
                        DataRow dr = dtAccounts.NewRow();
                        dr["Account_ID"] = Convert.ToInt32(txtAccountCode.Text);
                        dr["Account_Code"] = account.Account_Code;
                        dr["Account_Name"] = account.Account_Name;

                        dtAccounts.Rows.InsertAt(dr, rowindex);
                    }
                }
                else
                {
                    DataRow dr = dtAccounts.NewRow();
                    dr["Account_ID"] = Convert.ToInt32(txtAccountCode.Text);
                    dr["Account_Code"] = account.Account_Code;
                    dr["Account_Name"] = account.Account_Name;
                    dtAccounts.Rows.Add(dr);
                }
                ViewState["dtAccounts"] = dtAccounts;
            }
            ClearAccount();
        }
        protected void grdAccountsList_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            ClearAccount();
            DataTable dtAccounts = (DataTable)ViewState["dtAccounts"];
            DataRow drCurrentRow = null;
            int rowIndex = Convert.ToInt32(e.RowIndex);
            if (dtAccounts.Rows.Count > 0)
            {
                dtAccounts.Rows.Remove(dtAccounts.Rows[rowIndex]);
                drCurrentRow = dtAccounts.NewRow();
                ViewState["dtAccounts"] = dtAccounts;
            }
            BindPlotesGrid();
            upAccountList.Update();
        }

        private void ClearAccount()
        {
            //txtAccountCode.Text = "";
            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "clearToken", "$('#ctl00_MainContent_txtAccountCode').tokenInput('clear');", true);
            hdfRowIndex.Value = "";
            btnAdd.Text = "Add";
        }
        protected void grdAccountsList_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "SelectRecord")
            {
                int rowIndex = Convert.ToInt32(e.CommandArgument);
                string Accountid = ((Label)grdAccountsList.Rows[rowIndex].FindControl("lblAccount_ID")).Text;
                string code = ((Label)grdAccountsList.Rows[rowIndex].FindControl("lblAccount_Code")).Text;
                string name = ((Label)grdAccountsList.Rows[rowIndex].FindControl("lblAccount_Name")).Text;

                string Account_CodeAndName = code.Trim() + " - " + name.Trim();
                string inputString = String.Format(@"id:" + Accountid + @",name: '{0}'", Account_CodeAndName);
                ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "tmp", "$('#ctl00_MainContent_txtAccountCode').tokenInput('add', { " + inputString + " });", true);
                hdfRowIndex.Value = rowIndex.ToString();
                btnAdd.Text = "Update";
            }
        }
        protected bool AccountAlreadyExists()
        {
            lblErrorMessage.Text = "";
            bool exists = false;
            if (txtAccountCode.Text != "")
            {

                foreach (GridViewRow row in grdAccountsList.Rows)
                {
                    Label lblAccount_ID = (Label)row.FindControl("lblAccount_ID");
                    if (hdfRowIndex.Value != "" && lblAccount_ID != null)
                    {
                        if (txtAccountCode.Text == lblAccount_ID.Text && Convert.ToInt32(hdfRowIndex.Value) != row.RowIndex)
                        {
                            lblErrorMessage.Text = "Account already exists.";
                            exists = true;
                            break;
                        }
                    }
                    else
                    {
                        if (txtAccountCode.Text == lblAccount_ID.Text)
                        {
                            lblErrorMessage.Text = "Account already exists.";
                            exists = true;
                            break;
                        }
                    }
                }
            }
            return exists;
        }

        protected void btnPreview_Click(object sender, EventArgs e)
        {
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                if (Request.QueryString["Type"] == null)
                    return;
                //Page.Validate();
                //if (!Page.IsValid)
                //    return;
                string reportType = Request.QueryString["Type"];
                string query = "";
                string Account_Code = "";
                string StartAccountCode = "";
                //string Account_Code_for_CashBook = "";
                string EndAccountCode = "";
                string Account_Code_Name = "";

                if (!chbAllAccounts.Checked)
                {
                    Account_Code = DBClass.getField("Select Account_Code from Gl_Accounts Where Account_ID=" + txtSpecificAccount.Text);
                }
                switch (reportType)
                {
                    case "BS":
                        InsertEntriesInBalanseSheet();
                        query = "ReportName=BalanceSheet&ReportTitle=Balance Sheet As on " + txtStart_Date.Text;
                        break;
                    case "IL":
                        query = "ReportName=InstallmentLedger&ReportTitle=Installment Ledger&Customer_ID=" + txtCustomer.Text + "&StartDate=" + Convert.ToDateTime(txtStart_Date.Text).ToString("dd-MMM-yy") + "&EndDate=" + Convert.ToDateTime(txtEnd_Date.Text).ToString("dd-MMM-yy") + "&ProjectID=" + ddlCostCenter.SelectedValue.ToString() + "";
                        break;
                    case "PL":
                        query = "ReportName=ProfitLoss&ReportTitle=Profit And Loss " + txtStart_Date.Text + " To " + txtEnd_Date.Text + "&StartDate=" + Convert.ToDateTime(txtStart_Date.Text).ToString("dd-MMM-yy") + "&EndDate=" + Convert.ToDateTime(txtEnd_Date.Text).ToString("dd-MMM-yy") + "&ExportPDF=" + chkExportPDF.Checked;
                        break;
                    case "TB":
                        query = "ReportName=TrailBalanceAt&ReportTitle=Trial Balance from  " + txtStart_Date.Text + " To " + txtEnd_Date.Text + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text + "&Level1=" + cbLevel1.Checked + "&Level2=" + cbLevel2.Checked + "&Level3=" + cbLevel3.Checked + "&Level4=" + cbLevel4.Checked + "&ExportPDF=" + chkExportPDF.Checked;
                        break;
                    case "TBD":
                        query = "ReportName=TrailByDate&ReportTitle=Trail Balance from " + txtStart_Date.Text + " to " + txtEnd_Date.Text + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text + "&ExportPDF=" + chkExportPDF.Checked;
                        break;
                    case "TBDC":
                        if (txtStart_Code.Text != "" && txtEnd_Code.Text != "" && rbtAccountSelection.Checked == true)
                        {
                            StartAccountCode = DBClass.getField("Select Account_Code from Gl_Accounts Where Account_ID=" + txtStart_Code.Text);
                            EndAccountCode = DBClass.getField("Select Account_Code from Gl_Accounts Where Account_ID=" + txtEnd_Code.Text);
                        }
                        else if (rbtAll.Checked == true)
                        {
                            StartAccountCode = DBClass.getField("select ISNULL(min(account_code),0) as Min_AccountCode from GL_Accounts where Levels=4");
                            EndAccountCode = DBClass.getField("select ISNULL(max(account_code),0) as Min_AccountCode from GL_Accounts where Levels=4");
                        }
                        query = "ReportName=TrailBalanceByDateCodeSelection&ReportTitle=Trail By Date With Code Level Selection " + txtStart_Date.Text + " to " + txtEnd_Date.Text + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text + "&Level1=" + cbLevel1.Checked + "&Level2=" + cbLevel2.Checked + "&Level3=" + cbLevel3.Checked + "&Level4=" + cbLevel4.Checked + "&stCode=" + StartAccountCode + "&enCode=" + EndAccountCode + "&HideZeroBalance=" + cbHideZeroBalance.Checked + "&ExportPDF=" + chkExportPDF.Checked;
                        break;
                    case "TBC":
                       
                        if (txtStart_Code.Text != "" && txtEnd_Code.Text != "" && rbtAccountSelection.Checked == true)
                        {
                            StartAccountCode = DBClass.getField("Select Account_Code from Gl_Accounts Where Account_ID=" + txtStart_Code.Text);
                            EndAccountCode = DBClass.getField("Select Account_Code from Gl_Accounts Where Account_ID=" + txtEnd_Code.Text);
                        }
                        else if (rbtAll.Checked == true)
                        {
                            StartAccountCode = DBClass.getField("select ISNULL(min(account_code),0) as Min_AccountCode from GL_Accounts where Levels=4");
                            EndAccountCode = DBClass.getField("select ISNULL(max(account_code),0) as Min_AccountCode from GL_Accounts where Levels=4");
                        }
                        query = "ReportName=TrailForCostCenter&ReportTitle=Trail For Cost Center From " + txtStart_Date.Text + " to " + txtEnd_Date.Text + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text + "&CostCenter=" + ddlCostCenter.Text + "&CostCenterName=" + ddlCostCenter.SelectedItem.Text + "&stCode=" + StartAccountCode + "&enCode=" + EndAccountCode + "&AllAccounts=" + rbtAll.Checked.ToString().ToLower() + "&ExportPDF=" + chkExportPDF.Checked;
                        break;
                    case "LBC":
                        query = "ReportName=LedgerForCostCenter&ReportTitle=Ledger For Cost Center  From " + txtStart_Date.Text + " to " + txtEnd_Date.Text + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text + "&CostCenter=" + ddlCostCenter.SelectedValue + "&Department=" + ddlDepartment.SelectedValue + "&AllAccounts=" + chbAllAccounts.Checked + "&Account_Code=" + Account_Code + "&CostCenterName=" + ddlCostCenter.SelectedItem.Text + "&ExportPDF=" + chkExportPDF.Checked;
                        break;
                    case "COA":
                        query = "ReportName=ChartOfAccount&ReportTitle=Chart Of Account &Level1=" + cbLevel1.Checked + "&Level2=" + cbLevel2.Checked + "&Level3=" + cbLevel3.Checked + "&Level4=" + cbLevel4.Checked;
                        break;
                    //case "DailyActivity":
                    //    query = "ReportName=DailyActivity&ReportTitle=Day Activity " + Convert.ToDateTime(txtStart_Date.Text).ToString("MM-dd-yyyy") + "&ActivityDate=" + txtStart_Date.Text + "&ExportPDF=" + Excel
                    //    break;
                    case "DA":
                        // Use the SAME raw date string that works in other reports (e.g., AccountBalance)
                        string rawActivityDate = txtStart_Date.Text.Trim();

                        // Optional: Validate it's not empty
                        if (string.IsNullOrEmpty(rawActivityDate))
                        {
                            ScriptManager.RegisterStartupScript(this, GetType(), "NoDate",
                                "alert('Please enter a Start Date.');", true);
                            return;
                        }

                        // Use the same date format as used in AccountBalance (no conversion!)
                        query = "ReportName=DailyActivity&ReportTitle=Day Activity " + rawActivityDate +
                                "&ActivityDate=" + Server.UrlEncode(rawActivityDate) + "&company_id=" + AppConfig.Company_ID;
                        break;
                    case "AB":
                        if (txtStart_Code.Text != "" && txtEnd_Code.Text != "")
                        {
                            StartAccountCode = DBClass.getField("Select Account_Code from Gl_Accounts Where Account_ID=" + txtStart_Code.Text);
                            EndAccountCode = DBClass.getField("Select Account_Code from Gl_Accounts Where Account_ID=" + txtEnd_Code.Text);
                        }
                        query = "ReportName=AccountBalance&ReportTitle=Account Balance  as on " + txtStart_Date.Text + "&fromDate=" + txtStart_Date.Text + "&toDate=" + txtStart_Date.Text + "&stCode=" + StartAccountCode + "&enCode=" + EndAccountCode + "&HideZeroBalance=" + cbHideZeroBalance.Checked + "&Project_Name=" + ddlCostCenter.SelectedItem.Text.Trim() + "";
                        break;
                    case "ML":
                        if (chbAllAccounts.Checked)
                        {
                            DBClass.exectueQuery("Delete From rptSelectionParameters;", tranObj, con);
                            tranObj.Commit();
                            DataTable ddt = DBClass.getDataTable("Select Account_ID from GL_Accounts Where Levels=4 and Active=1");
                            for (int i = 0; i <= ddt.Rows.Count - 1; i++)
                            {
                                DBClass.executeNonQueryWithoutBegin("Insert into rptSelectionParameters (Code) values  ('" + ddt.Rows[i]["Account_ID"] + "')");

                            }
                            query = "ReportName=MultiLedger&ReportTitle=Account Ledger From " + txtStart_Date.Text + " To " + txtEnd_Date.Text + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text + "&ExportPDF=" + chkExportPDF.Checked;
                            break;
                        }
                        else
                        {
                            FillSelectionParameters();
                            query = "ReportName=MultiLedger&ReportTitle=Account Ledger From " + txtStart_Date.Text + " To " + txtEnd_Date.Text + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text + "&ExportPDF=" + chkExportPDF.Checked;
                            break;
                        }
                    case "VL":
                        string selectedVendorId = VendorList.SelectedValue;
                      //  var ExcelOT = chkExportPDF.Checked;
                        query = "ReportName=Vendor_Ledger&ReportTitle=Vendor Ledger Report From " + txtStart_Date.Text + " To " + txtEnd_Date.Text + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text + "&Vendor_Id=" + selectedVendorId ;
                        break;

                    case "VB":
                      //  var ExcelOT = chkExportPDF.Checked;
                        query = "ReportName=Vendor_Balance&ReportTitle=Vendor Balance Report From " + txtStart_Date.Text + " To " + txtEnd_Date.Text + "&startDate=" + txtStart_Date.Text ;
                        break;
                    case "TC":
                        query = "ReportName=TrailComparison&ReportTitle=Trail Comparison From " + txtStart_Date.Text + " To " + txtEnd_Date.Text + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text + "&ExportPDF=" + chkExportPDF.Checked;
                        break;
                    //case "VB":
                    //    query = "ReportName=Vendor_Balance&ReportTitle=Vendor Balance Report From " + txtStart_Date.Text + " To " + txtEnd_Date.Text + "&startDate=" + txtStart_Date.Text;
                    //    break;
                    case "BSD":
                        StartAccountCode = DBClass.getField("select ISNULL(min(account_code),0) as Min_AccountCode from GL_Accounts where Levels=4 and (Account_Code LIKE '1%' OR Account_Code LIKE '2%' OR Account_Code LIKE '3%')");
                        EndAccountCode = DBClass.getField("select ISNULL(max(account_code),0) as Min_AccountCode from GL_Accounts where Levels=4 and (Account_Code LIKE '1%' OR Account_Code LIKE '2%' OR Account_Code LIKE '3%')");
                        query = "ReportName=BalanceSheetDetail&ReportTitle=Balance Sheet Detail as on " + txtStart_Date.Text + "&startDate=" + txtStart_Date.Text + "&Level1=" + cbLevel1.Checked + "&Level2=" + cbLevel2.Checked + "&Level3=" + cbLevel3.Checked + "&Level4=" + cbLevel4.Checked + "&stCode=" + StartAccountCode + "&enCode=" + EndAccountCode + "&HideZeroBalance=" + cbHideZeroBalance.Checked + "" + "&ExportPDF=" + chkExportPDF.Checked;
                        break;
                    case "BSC":
                        StartAccountCode = DBClass.getField("select ISNULL(min(account_code),0) as Min_AccountCode from GL_Accounts where Levels=4 and (Account_Code LIKE '1%' OR Account_Code LIKE '2%' OR Account_Code LIKE '3%')");
                        EndAccountCode = DBClass.getField("select ISNULL(max(account_code),0) as Min_AccountCode from GL_Accounts where Levels=4 and (Account_Code LIKE '1%' OR Account_Code LIKE '2%' OR Account_Code LIKE '3%')");
                        query = "ReportName=BalanceSheetComparison&ReportTitle=Balance Sheet Comparison as on " + txtStart_Date.Text + " to " + txtComarison_DateFrom.Text + "&startDate=" + txtStart_Date.Text + "&ComarisonStartDate=" + txtComarison_DateFrom.Text + "&Level1=" + cbLevel1.Checked + "&Level2=" + cbLevel2.Checked + "&Level3=" + cbLevel3.Checked + "&Level4=" + cbLevel4.Checked + "&stCode=" + StartAccountCode + "&enCode=" + EndAccountCode + "&HideZeroBalance=" + cbHideZeroBalance.Checked + "" + "&ExportPDF=" + chkExportPDF.Checked;
                        break;
                    case "PLD":
                        if (txtStart_Code.Text != "" && txtEnd_Code.Text != "" && rbtAccountSelection.Checked == true)
                        {
                            StartAccountCode = DBClass.getField("Select Account_Code from Gl_Accounts Where Account_ID=" + txtStart_Code.Text);
                            EndAccountCode = DBClass.getField("Select Account_Code from Gl_Accounts Where Account_ID=" + txtEnd_Code.Text);
                        }
                        else if (rbtAll.Checked == true)
                        {
                            StartAccountCode = DBClass.getField("select ISNULL(min(account_code),0) as Min_AccountCode from GL_Accounts where Levels=4 and (Account_Code LIKE '4%' OR Account_Code LIKE '5%' OR Account_Code LIKE '6%' OR Account_Code LIKE '7%' OR Account_Code LIKE '8%')");
                            EndAccountCode = DBClass.getField("select ISNULL(max(account_code),0) as Min_AccountCode from GL_Accounts where Levels=4 and (Account_Code LIKE '4%' OR Account_Code LIKE '5%' OR Account_Code LIKE '6%' OR Account_Code LIKE '7%' OR Account_Code LIKE '8%')");
                        }
                        query = "ReportName=ProfitLossDetail&ReportTitle=Profit And Loss Detail From" + txtStart_Date.Text + " To " + txtEnd_Date.Text + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text + "&Level1=" + cbLevel1.Checked + "&Level2=" + cbLevel2.Checked + "&Level3=" + cbLevel3.Checked + "&Level4=" + cbLevel4.Checked + "&stCode=" + StartAccountCode + "&enCode=" + EndAccountCode + "&HideZeroBalance=" + cbHideZeroBalance.Checked + "" + "&ExportPDF=" + chkExportPDF.Checked;
                        break;
                    case "PLC":
                        if (txtStart_Code.Text != "" && txtEnd_Code.Text != "" && rbtAccountSelection.Checked == true)
                        {
                            StartAccountCode = DBClass.getField("Select Account_Code from Gl_Accounts Where Account_ID=" + txtStart_Code.Text);
                            EndAccountCode = DBClass.getField("Select Account_Code from Gl_Accounts Where Account_ID=" + txtEnd_Code.Text);
                        }
                        else if (rbtAll.Checked == true)
                        {
                            StartAccountCode = DBClass.getField("select ISNULL(min(account_code),0) as Min_AccountCode from GL_Accounts where Levels=4 and (Account_Code LIKE '4%' OR Account_Code LIKE '5%' OR Account_Code LIKE '6%' OR Account_Code LIKE '7%' OR Account_Code LIKE '8%')");
                            EndAccountCode = DBClass.getField("select ISNULL(max(account_code),0) as Min_AccountCode from GL_Accounts where Levels=4 and (Account_Code LIKE '4%' OR Account_Code LIKE '5%' OR Account_Code LIKE '6%' OR Account_Code LIKE '7%' OR Account_Code LIKE '8%')");
                        }
                        query = "ReportName=ProfitLossComparison&ReportTitle=Profit And Loss Comparison " + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text + "&ComarisonStartDate=" + txtComarison_DateFrom.Text + "&ComparisonEndDate=" + txtComarison_DateTo.Text + "&Level1=" + cbLevel1.Checked + "&Level2=" + cbLevel2.Checked + "&Level3=" + cbLevel3.Checked + "&Level4=" + cbLevel4.Checked + "&stCode=" + StartAccountCode + "&enCode=" + EndAccountCode + "&HideZeroBalance=" + cbHideZeroBalance.Checked + "" + "&ExportPDF=" + chkExportPDF.Checked;
                        break;
                    case "TBB":
                        if (txtStart_Code.Text != "" && txtEnd_Code.Text != "" && rbtAccountSelection.Checked == true)
                        {
                            StartAccountCode = DBClass.getField("Select Account_Code from Gl_Accounts Where Account_ID=" + txtStart_Code.Text);
                            EndAccountCode = DBClass.getField("Select Account_Code from Gl_Accounts Where Account_ID=" + txtEnd_Code.Text);
                        }
                        else if (rbtAll.Checked == true)
                        {
                            StartAccountCode = DBClass.getField("select ISNULL(min(account_code),0) as Min_AccountCode from GL_Accounts where Levels=4");
                            EndAccountCode = DBClass.getField("select ISNULL(max(account_code),0) as Min_AccountCode from GL_Accounts where Levels=4");
                        }
                        var branch = ddlCostCenter.SelectedValue;
                        query = "ReportName=TrailBalanceBranchWise&ReportTitle=Trail For Branch From " + txtStart_Date.Text + " to " + txtEnd_Date.Text + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text + "&Branch=" + ddlCostCenter.SelectedValue + "&BranchName=" + ddlCostCenter.SelectedItem.Text + "&stCode=" + StartAccountCode + "&enCode=" + EndAccountCode + "&AllAccounts=" + rbtAccountSelection;
                        break;
                    case "OTLWP":
                        var ExcelOT = chkExportPDF.Checked;
                        query = "ReportName=OTListWithoutPic&ReportTitle=Customer Summary&StartDate=" + Convert.ToDateTime(txtStart_Date.Text).ToString("dd-MMM-yy") + "&EndDate=" + Convert.ToDateTime(txtEnd_Date.Text).ToString("dd-MMM-yy") + "&ExportPDF=" + ExcelOT;
                        break;


                    default:
                        break;
                }

                string path = @"ReportViewer.aspx?" + query;
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
        private void InsertEntriesInBalanseSheet()
        {
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                if (txtStart_Date.Text != "")
                {
                    string Earning;
                    string EarningID;
                    string query = "";
                    query += "delete from rpt_BalanceSheet;";
                    Earning = DBClass.getField("Select Code from sys_Parms where Name='Earning' AND company_id=" + AppConfig.Company_ID + "").ToString();
                    EarningID = DBClass.getField("Select account_id from gl_accounts where account_code='" + Earning + "' and book_id=" + AppConfig.Book_ID + "").ToString();
                    DateTime currentDate = Convert.ToDateTime(txtStart_Date.Text);
                    DateTime previousYear = currentDate.AddYears(-1);
                    //Test_Qasim
                    query += "insert into rpt_BalanceSheet(Account_ID,Account_Code,This_Year,Previous_Year,Book_ID) Select gl_accounts.account_id,gl_accounts.Account_code,dbo.GetAccountBalance(GL_Accounts.Account_ID,'" + currentDate.ToString("dd-MMM-yyyy") + "'),dbo.GetAccountBalance(GL_Accounts.Account_ID,'" + previousYear.ToString("dd-MMM-yyyy") + "'),book_id from gl_accounts where book_id=" + AppConfig.Book_ID + " and levels=4 and left(account_code,1) in (1,2,3,4,5) ;"; 
                    query += "Insert into rpt_BalanceSheet(Account_ID,Account_Code,This_Year,Previous_Year,Book_ID) select " + EarningID + ",'" + Earning + "',isnull(sum(dr-cr),0),0," + AppConfig.Book_ID + " from vwgl_ledger where left(vwgl_ledger.account_code,1) between '1' and '9' and company_id=" + AppConfig.Company_ID + " and voucher_date <='" + previousYear.ToString("dd-MMM-yyyy") + "' ;";
                    DBClass.exectueQuery(query, tranObj, con);
                    tranObj.Commit();
                }
            }
            catch (Exception ex)
            {
                if (tranObj != null)
                    tranObj.Rollback();
                throw ex;
            }
            finally
            {
                con.Close();
            }
        }
        private void FillSelectionParameters()
        {
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                string query = "Delete rptSelectionParameters";
                foreach (GridViewRow row in grdAccountsList.Rows)
                {
                    Label lblAccount_ID = (Label)row.FindControl("lblAccount_ID");
                    if (lblAccount_ID != null && lblAccount_ID.Text != "")
                    {
                        if (query != "")
                            query += ";";
                        query += "Insert into rptSelectionParameters(Code)values(" + lblAccount_ID.Text + ")";
                    }
                }
                if (query != "")
                {
                    DBClass.exectueQuery(query, tranObj, con);
                    tranObj.Commit();
                }
            }
            catch (Exception ex)
            {
                if (tranObj != null)
                    tranObj.Rollback();
                throw ex;
            }
            finally
            {
                con.Close();
            }
        }

        protected void grdAccountsList_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                Label lblAccount_ID = (Label)e.Row.FindControl("lblAccount_ID");

                Label lblAccount_Name = (Label)e.Row.FindControl("lblAccount_Name");
                if (lblAccount_ID != null && lblAccount_ID.Text != "" && lblAccount_Name != null)
                {
                    lblAccount_Name.Text = DBClass.getField("Select IsNull(Account_Name,'') from GL_Accounts where Account_ID=" + Convert.ToInt32(lblAccount_ID.Text));
                }
            }
        }
        //private void InserRecordInDailyBook()
        //{
        //    SqlTransaction tranObj = null;
        //    SqlConnection con = new SqlConnection(DBClass.ConnectionString());
        //    con.Open();
        //    tranObj = con.BeginTransaction();
        //    try
        //    {
        //        string Account_Name = DBClass.getField("select Account_Name from gl_accounts where Account_ID=");
        //        string query = "Delete from rpt_DailyBook;";
        //        query += "Insert into rpt_DailyBook(Account_Code,Account_Name,Date,Balance) values(Null,'" + Account_Name + " Opening Balance....','" + txtStart_Date.Text + "',dbo.GetAccountBalance(" + txtAccountCodeForCashBook.Text + ",'" + txtStart_Date.Text + "'))";
        //        DBClass.exectueQuery(query, tranObj, con);
        //        tranObj.Commit();
        //    }
        //    catch (Exception ex)
        //    {
        //        if (tranObj != null)
        //            tranObj.Rollback();
        //        throw ex;
        //    }
        //    finally
        //    {
        //        con.Close();
        //    }
        //}
        protected void chbAllAccounts_CheckedChanged(object sender, EventArgs e)
        {
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();

            if (Request.QueryString["Type"] == "ML")
            {
                if (chbAllAccounts.Checked == false)
                {
                    phMultiLedger.Visible = true;
                }
                else
                {

                    phMultiLedger.Visible = false;

                }

            }
            else
            {
                if (chbAllAccounts.Checked == false)
                {
                    lblSpecificAccount.Visible = true;
                    txtSpecificAccount.Visible = true;
                }
                else
                {
                    lblSpecificAccount.Visible = false;
                    txtSpecificAccount.Visible = false;
                }
            }
        }

        protected void rbtAll_CheckedChanged(object sender, EventArgs e)
        {
            if (rbtAll.Checked)
            {
                AccountDiv.Visible=false;
            }
        }

        protected void rbtAccountSelection_CheckedChanged(object sender, EventArgs e)
        {
            if (rbtAccountSelection.Checked)
            {
                AccountDiv.Visible = true;

            }
        }
    }
}