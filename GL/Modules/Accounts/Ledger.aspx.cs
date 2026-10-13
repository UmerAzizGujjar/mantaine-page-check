using Infragistics.Documents.Reports.HTML;
using Infragistics.Documents.Reports.RTF;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class Ledger : System.Web.UI.Page
    {
        private DataTable GetUserWarehouses()
        {
            if (DBClass.IsAdministrator())
            {
                return DBClass.getDataTable(@"
                    SELECT DataValue_Name AS Value, DataValue_Description AS Text
                    FROM DataValues
                    WHERE ValueSet_ID = 8
                    ORDER BY CASE WHEN DataValue_Name = '0' THEN 0 ELSE 1 END, DataValue_Description");
            }
            return DBClass.getDataTable(@"
    SELECT DISTINCT dv.DataValue_Name AS Value, dv.DataValue_Description AS Text
    FROM WareHouse_Wise_User wu
    INNER JOIN WareHouse_Wise_User_Detail wud ON wu.WareHouse_wise_User_Id = wud.WareHouse_wise_User_Id
    INNER JOIN DataValues dv ON wud.WareHouse = dv.DataValue_Name
    WHERE wu.User_Id = '" + AppConfig.UserID.ToString() + @"'
      AND dv.ValueSet_ID = 8
    ORDER BY dv.DataValue_Description");
        }

        protected void Page_Load(object sender, EventArgs e)
        {

            if (!IsPostBack)
            {
                switch (Request.QueryString["Type"])
                {
                    case "VWPOS":
                        vendorDiv.Visible = true;
                        vendorTypeDiv.Visible = false;
                        accountDiv.Visible = false;
                        stockDiv.Visible = false;
                        DateDiv.Visible = true;
                        tr_Export.Visible = true;
                        string sqlUni = "Select 0 as Vendor_ID, 'All' as Vendor_Name union all ";
                        System.Data.DataTable dtVen = DBClass.getDataTable(sqlUni + " Select Vendor_ID, (convert(Varchar,Vendor_ID) + ' - ' + Vendor_Name) as Vendor_Name from AP_Vendors");
                        ddlVendor.DataSource = dtVen;
                        ddlVendor.DataTextField = "Vendor_Name";
                        ddlVendor.DataValueField = "Vendor_ID";
                        ddlVendor.DataBind();

                        warehouseDiv.Visible = true;
                        ddlWarehouse.DataSource = GetUserWarehouses();
                        ddlWarehouse.DataTextField = "Text";
                        ddlWarehouse.DataValueField = "Value";
                        ddlWarehouse.DataBind();
                        ddlWarehouse.Items.Insert(0, new ListItem("All", "0"));

                        txtStart_Date.Text = DateTime.Now.ToString("dd MMM yyyy");
                        txtEnd_Date.Text = DateTime.Now.ToString("dd MMM yyyy");
                        break;
                    case "VWPS":

                        vendorDiv.Visible = true;
                        vendorTypeDiv.Visible = true;
                        accountDiv.Visible = false;
                        stockDiv.Visible = false;
                        DateDiv.Visible = true;
                        tr_Export.Visible = true;
                        vendorTypeDiv.Visible = true;
                        vendorTypeDiv.Visible = true;

                        System.Data.DataTable dtVendorType = DBClass.getDataTable(@"
                            SELECT DataValue_Name, DataValue_Description 
                            FROM dbo.DataValues p 
                            JOIN dbo.ValueSet v ON p.ValueSet_ID = v.ValueSet_ID 
                            WHERE v.ValueSet_Description = 'Vendor Type'
                        ");
                        ddlVendorType.DataSource = dtVendorType;
                        ddlVendorType.DataTextField = "DataValue_Description";
                        ddlVendorType.DataValueField = "DataValue_Name";
                        ddlVendorType.AppendDataBoundItems = true;
                        ddlVendorType.Items.Clear();
                        ddlVendorType.Items.Add(new ListItem("All", "0"));
                        warehouseDiv.Visible = false;
                        ddlVendorType.DataBind();

                        string sqlUn = "Select 0 as Vendor_ID, 'All' as Vendor_Name union all ";
                        System.Data.DataTable dtVent = DBClass.getDataTable(sqlUn + " Select Vendor_ID, (convert(Varchar,Vendor_ID) + ' - ' + Vendor_Name) as Vendor_Name from AP_Vendors");
                        ddlVendor.DataSource = dtVent;
                        ddlVendor.DataTextField = "Vendor_Name";
                        ddlVendor.DataValueField = "Vendor_ID";
                        ddlVendor.DataBind();

                        break;
                    case "VWP":
                        vendorDiv.Visible = true;
                        vendorTypeDiv.Visible = true;
                        accountDiv.Visible = false;
                        stockDiv.Visible = false;
                        DateDiv.Visible = true;
                        tr_Export.Visible = true;
                        string sqlLUnin1 = "Select 0 as Vendor_ID, 'All' as Vendor_Name union all ";
                        System.Data.DataTable dtVende1 = DBClass.getDataTable(sqlLUnin1 + " Select Vendor_ID, (convert(Varchar,Vendor_ID) + ' - ' + Vendor_Name) as Vendor_Name from AP_Vendors");
                        ddlVendor.DataSource = dtVende1;
                        ddlVendor.DataTextField = "Vendor_Name";
                        ddlVendor.DataValueField = "Vendor_ID";
                        ddlVendor.DataBind();

                        vendorTypeDiv.Visible = true;

                        System.Data.DataTable dtVendorType1 = DBClass.getDataTable(@"
                            SELECT DataValue_Name, DataValue_Description 
                            FROM dbo.DataValues p 
                            JOIN dbo.ValueSet v ON p.ValueSet_ID = v.ValueSet_ID 
                            WHERE v.ValueSet_Description = 'Vendor Type'
                        ");
                        ddlVendorType.DataSource = dtVendorType1;
                        ddlVendorType.DataTextField = "DataValue_Description";
                        ddlVendorType.DataValueField = "DataValue_Name";
                        ddlVendorType.AppendDataBoundItems = true;
                        ddlVendorType.Items.Clear();
                        ddlVendorType.Items.Add(new ListItem("All", "0"));
                        ddlVendorType.DataBind();

                        warehouseDiv.Visible = true;
                        ddlWarehouse.DataSource = GetUserWarehouses();
                        ddlWarehouse.DataTextField = "Text";
                        ddlWarehouse.DataValueField = "Value";
                        ddlWarehouse.DataBind();
                        ddlWarehouse.Items.Insert(0, new ListItem("All", "0"));
                        break;
                    case "GRNS":
                        vendorDiv.Visible = true;
                        accountDiv.Visible = false;
                        vendorTypeDiv.Visible = false;
                        stockDiv.Visible = false;
                        tr_Export.Visible = true;
                        string sqlLiUnion = "Select 0 as Vendor_ID, 'All' as Vendor_Name union all ";
                        System.Data.DataTable dtVendorsss = DBClass.getDataTable(sqlLiUnion + " Select Vendor_ID, (convert(Varchar,Vendor_ID) + ' - ' + Vendor_Name) as Vendor_Name from AP_Vendors");
                        ddlVendor.DataSource = dtVendorsss;
                        ddlVendor.DataTextField = "Vendor_Name";
                        ddlVendor.DataValueField = "Vendor_ID";
                        ddlVendor.DataBind();

                        warehouseDiv.Visible = true;
                        ddlWarehouse.DataSource = GetUserWarehouses();
                        ddlWarehouse.DataTextField = "Text";
                        ddlWarehouse.DataValueField = "Value";
                        ddlWarehouse.DataBind();
                        ddlWarehouse.Items.Insert(0, new ListItem("All", "0"));
                        break;
                    case "IGPS":
                        vendorDiv.Visible = true;
                        accountDiv.Visible = false;
                        vendorTypeDiv.Visible = false;
                        tr_Export.Visible = true;
                        stockDiv.Visible = false;
                        string sqlLUnin = "Select 0 as Vendor_ID, 'All' as Vendor_Name union all ";
                        System.Data.DataTable dtVende = DBClass.getDataTable(sqlLUnin + " Select Vendor_ID, (convert(Varchar,Vendor_ID) + ' - ' + Vendor_Name) as Vendor_Name from AP_Vendors");
                        ddlVendor.DataSource = dtVende;
                        ddlVendor.DataTextField = "Vendor_Name";
                        ddlVendor.DataValueField = "Vendor_ID";
                        ddlVendor.DataBind();

                        warehouseDiv.Visible = true;
                        ddlWarehouse.DataSource = GetUserWarehouses();
                        ddlWarehouse.DataTextField = "Text";
                        ddlWarehouse.DataValueField = "Value";
                        ddlWarehouse.DataBind();
                        ddlWarehouse.Items.Insert(0, new ListItem("All", "0"));
                        break;
                    case "SIH":
                        vendorDiv.Visible = false;
                        stockDiv.Visible = true;
                        vendorTypeDiv.Visible = false;
                        accountDiv.Visible = false;
                        DateDiv.Visible = true;
                        break;

                    case "SIHD":
                        vendorDiv.Visible = true;
                        tr_Export.Visible = true;
                        stockDiv.Visible = false;
                        accountDiv.Visible = false;
                        vendorTypeDiv.Visible = false;
                        lblAccount.Visible = false;
                        txtAccount_ID.Visible = false;
                        sttDate.Visible = true;
                        txtStart_Date.Visible = true;
                        txtEnd_Date.Visible = true;
                        endDate.Visible = true;
                        lblVendor.Text = "Ware House";
                        System.Data.DataTable dtDept2 = DBClass.getDataTable("Select DataValue_Name,DataValue_Description FROM dbo.DataValues p JOIN dbo.ValueSet v ON p.ValueSet_ID = v.ValueSet_ID WHERE v.ValueSet_Description = 'Ware House'");
                        ddlVendor.DataSource = dtDept2;
                        ddlVendor.DataTextField = "DataValue_Description";
                        ddlVendor.DataValueField = "DataValue_Name";
                        ddlVendor.Items.Add(new ListItem() { Text = "All", Value = "0" });
                        ddlVendor.AppendDataBoundItems = true;
                        ddlVendor.DataBind();
                        warehouseDiv.Visible = false;
                        // ADDED THESE TWO LINES
                        txtStart_Date.Text = "01 Jan 2020";
                        txtEnd_Date.Text = DateTime.Now.ToString("dd MMM yyyy");
                        break;

                    case "Stock_Consumption_Details":
                        vendorDiv.Visible = false;
                        stockDiv.Visible = true;
                        vendorTypeDiv.Visible = false;
                        accountDiv.Visible = false;
                        DateDiv.Visible = true;
                        tr_Export.Visible = true;

                        warehouseDiv.Visible = true;
                        ddlWarehouse.DataSource = GetUserWarehouses();
                        ddlWarehouse.DataTextField = "Text";
                        ddlWarehouse.DataValueField = "Value";
                        ddlWarehouse.DataBind();
                        ddlWarehouse.Items.Insert(0, new ListItem("All", "0"));

                        accountCategoryDiv.Visible = true;
                        System.Data.DataTable dtAccCat = DBClass.getDataTable("SELECT Account_Category_Id AS [Value], CategoryName AS [Text] FROM Account_Category ORDER BY CategoryName");
                        ddlAccountCategory.DataSource = dtAccCat;
                        ddlAccountCategory.DataTextField = "Text";
                        ddlAccountCategory.DataValueField = "Value";
                        ddlAccountCategory.DataBind();
                        ddlAccountCategory.Items.Insert(0, new ListItem("All", "0"));
                        break;

                    case "Pharmacy_Stock_Consumption_Details":
                        vendorDiv.Visible = false;
                        stockDiv.Visible = true;
                        vendorTypeDiv.Visible = false;
                        accountDiv.Visible = false;
                        DateDiv.Visible = true;
                        break;

                    case "SIHBW":
                        vendorDiv.Visible = false;
                        vendorTypeDiv.Visible = false;
                        stockDiv.Visible = true;
                        accountDiv.Visible = false;
                        DateDiv.Visible = false;
                        warehouseDiv.Visible = true;
                        tr_Export.Visible = true;

                        ddlWarehouse.DataSource = GetUserWarehouses();
                        ddlWarehouse.DataTextField = "Text";
                        ddlWarehouse.DataValueField = "Value";
                        ddlWarehouse.DataBind();
                        ddlWarehouse.Items.Insert(0, new ListItem("All", "0"));

                        break;
                    //case "Ledger":
                    //    vendorDiv.Visible = true;
                    //    vendorTypeDiv.Visible = false;
                    //    lblVendor.Text = "Department";
                    //    System.Data.DataTable dtDept = DBClass.getDataTable("Select DataValue_Name,DataValue_Description FROM dbo.DataValues p JOIN dbo.ValueSet v ON p.ValueSet_ID = v.ValueSet_ID WHERE v.ValueSet_Description = 'Department'");
                    //    ddlVendorType.DataSource = dtDept;
                    //    ddlVendorType.DataTextField = "DataValue_Description";
                    //    ddlVendorType.DataValueField = "DataValue_Name";
                    //    ddlVendorType.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    //    ddlVendorType.AppendDataBoundItems = true;
                    //    ddlVendorType.DataBind();
                    //    stockDiv.Visible = false;
                    //    break;
                    case "GL":
                        accountDiv.Visible = true;
                        vendorTypeDiv.Visible = false;
                        stockDiv.Visible = false;
                        vendorDiv.Visible = false;
                        break;

                    default:
                        vendorDiv.Visible = true;
                        warehouseDiv.Visible = false;
                        vendorTypeDiv.Visible = false;
                        lblVendor.Text = "Department";
                        System.Data.DataTable dtDept = DBClass.getDataTable("Select DataValue_Name,DataValue_Description FROM dbo.DataValues p JOIN dbo.ValueSet v ON p.ValueSet_ID = v.ValueSet_ID WHERE v.ValueSet_Description = 'Department'");
                        ddlVendor.DataSource = dtDept;
                        ddlVendor.DataTextField = "DataValue_Description";
                        ddlVendor.DataValueField = "DataValue_Name";
                        ddlVendor.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                        ddlVendor.AppendDataBoundItems = true;
                        ddlVendor.DataBind();
                        stockDiv.Visible = false;
                        tr_Export.Visible = true;
                        tr_HideZeroBalance.Visible = true;
                        break;
                }
            }
        }

        protected void btnPreview_Click(object sender, EventArgs e)
        {
            string query = "";
            switch (Request.QueryString["Type"])
            {
                //case "LLW":
                //    string StartAccount_Code = DBClass.getField("select Account_Code from Gl_Accounts where Account_ID=" + txtAccount_ID.Text + "");
                //        string EndAccount_Code = DBClass.getField("select Account_Code from Gl_Accounts where Account_ID=" + txtAccount_IDlvl3.Text + "");
                //        query = "ReportName=LedgerLevelwise&ReportTitle=Account ledger Level Wise from " + txtStart_Date.Text + " to " + txtEnd_Date.Text + "&StartAccount_Code=" + StartAccount_Code.Trim() + "000" + "&EndAccount_Code=" + EndAccount_Code.Trim() + "999" + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text;
                //    break;
                //case "IWPOS":
                //    query = "ReportName=ItemWosePOSummary&ReportTitle=Item Wise PO Summary from " + txtStart_Date.Text + " to " + txtEnd_Date.Text + "&Vendor_ID=" + ddlVendor.SelectedValue + "&Item_ID=" + ddlLevels.SelectedValue + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text + "";
                //    break;
                case "VWPOS":
                    query = "ReportName=VendorWisePOSummary&ReportTitle=Vendor Wise PO Summary from " + txtStart_Date.Text + " to " + txtEnd_Date.Text + "&Vendor_ID=" + ddlVendor.SelectedValue + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text + "&Warehouse=" + ddlWarehouse.SelectedValue + "&ExportPDF=" + chkExportPDF.Checked;
                    break;
                case "VWPS":
                    query = "ReportName=VendorWisePurchaseSummary&ReportTitle=Vendor Wise Purchase Summary from " + txtStart_Date.Text + " to " + txtEnd_Date.Text + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text + "&VendorType=" + ddlVendorType.SelectedValue + "&VendorId=" + ddlVendor.SelectedValue + "&ExportPDF=" + chkExportPDF.Checked;
                    break;
                case "IGPS":
                    query = "ReportName=VendorWiseIGPS&ReportTitle=Vendor Wise Inward Gate Pass Summary from " + txtStart_Date.Text + " to " + txtEnd_Date.Text + "&Vendor_ID=" + ddlVendor.SelectedValue + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text + "&Warehouse=" + ddlWarehouse.SelectedValue + "&ExportPDF=" + chkExportPDF.Checked;
                    break;
                case "GRNS":
                    query = "ReportName=VendorDetailsGRNS&ReportTitle=Good Receipt Note Summary from " + txtStart_Date.Text + " to " + txtEnd_Date.Text + "&Vendor_ID=" + ddlVendor.SelectedValue + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text + "&Warehouse=" + ddlWarehouse.SelectedValue + "&ExportPDF=" + chkExportPDF.Checked;
                    break;
                case "VWP":
                    query = "ReportName=VendorWisePurchase&ReportTitle=Vendor Wise Purchase Detail from " + txtStart_Date.Text + " to " + txtEnd_Date.Text + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text + "&VendorType=" + ddlVendorType.SelectedValue + "&VendorId=" + ddlVendor.SelectedValue + "&Warehouse=" + ddlWarehouse.SelectedValue + "&ExportPDF=" + chkExportPDF.Checked;
                    break;
                case "SIH":
                    query = "ReportName=PharmacyStock&ReportTitle=Stock In Hand &Stock=" + ddlStock.SelectedValue + "&ExportPDF=" + chkExportPDF.Checked;
                    break;
                case "SIHD":
                    query = "ReportName=PharmacyStockDetail&ReportTitle=Stock In Hand Detail from " + txtStart_Date.Text + " to " + txtEnd_Date.Text + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text + "&WareHouse=" + ddlVendor.SelectedValue + "&ExportPDF=" + chkExportPDF.Checked;
                    break;

                case "Stock_Consumption_Details":
                    query = "ReportName=Stock_Consumption_Details&ReportTitle=Stock Consumption Detail From" + txtStart_Date.Text + " to " + txtEnd_Date.Text + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text + "&Stock=" + ddlStock.SelectedValue + ""+ "&Warehouse=" + ddlWarehouse.SelectedValue + "&AccountCategory=" + ddlAccountCategory.SelectedValue + "&ExportPDF=" + chkExportPDF.Checked;
                    break;

                case "Pharmacy_Stock_Consumption_Details":
                    query = "ReportName=Pharmacy_Stock_Consumption_Details&ReportTitle=Stock Consumption Detail From" + txtStart_Date.Text + " to " + txtEnd_Date.Text + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text + "&Stock=" + ddlStock.SelectedValue + "";
                    break;
                case "SIHBW":
                    query = "ReportName=PharmacyStockBatchWise&ReportTitle=Stock In Hand  From" + "&Stock=" + ddlStock.SelectedValue + "" + "&WareHouse=" + ddlWarehouse.SelectedValue + "&ExportPDF=" + chkExportPDF.Checked;   //  excluded + txtStart_Date.Text + " to " + txtEnd_Date.Text + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text 
                    break;
                //case "Ledger":
                //    query = "ReportName=Ledger1&ReportTitle=Account ledger from " + txtStart_Date.Text + " to " + txtEnd_Date.Text + "&Account_ID=" + txtAccount_ID.Text.Trim() + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text + "&DeptID=" + ddlVendor.SelectedValue;
                //    break;
                case "GL":
                    query = "ReportName=GeneralLedger&ReportTitle=Account ledger from " + txtStart_Date.Text + " to " + txtEnd_Date.Text + "&Account_ID=" + txtAccount_ID.Text.Trim() + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text;
                    break;
                default:
                    query = "ReportName=Ledger&ReportTitle=Account ledger from " + txtStart_Date.Text + " to " + txtEnd_Date.Text + "&Account_ID=" + txtAccount_ID.Text.Trim() + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text + "&DeptID=" + ddlVendor.SelectedValue + "&ExportPDF=" + chkExportPDF.Checked + "&HideZeroBalance=" + chkHideZeroBalance.Checked;
                    break;
            }
            string path = @"../../ReportViewer.aspx?" + query;
            ScriptManager.RegisterStartupScript(this, typeof(string), "OPEN_WINDOW", "window.open('" + path + "');", true);


        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {

        }

        //protected void ddlLevels_SelectedIndexChanged(object sender, EventArgs e)
        //{
        //    if (ddlLevels.SelectedValue == "3")
        //    {
        //        level3.Visible = true;
        //        level4.Visible = false;
        //    }
        //    else if(ddlLevels.SelectedValue == "4")
        //    {
        //        level3.Visible = false;
        //        level4.Visible = true;
        //    }
        //}
    }
}