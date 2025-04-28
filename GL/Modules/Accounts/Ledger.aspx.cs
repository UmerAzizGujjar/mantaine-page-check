using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class Ledger : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
         
            if (!IsPostBack)
            {
                switch (Request.QueryString["Type"])
                {
                    case "VWPOS":
                        vendorDiv.Visible = true;
                        accountDiv.Visible = false;
                        stockDiv.Visible = false;
                        DateDiv.Visible = false;
                        string sqlUni = "Select 0 as Vendor_ID, 'All' as Vendor_Name union all ";
                        System.Data.DataTable dtVen = DBClass.getDataTable(sqlUni + " Select Vendor_ID, (convert(Varchar,Vendor_ID) + ' - ' + Vendor_Name) as Vendor_Name from AP_Vendors");
                        ddlVendor.DataSource = dtVen;
                        ddlVendor.DataTextField = "Vendor_Name";
                        ddlVendor.DataValueField = "Vendor_ID";
                        ddlVendor.DataBind();
                        break;
                    case "VWPS":
                        vendorDiv.Visible = false;
                        accountDiv.Visible = false;
                        stockDiv.Visible = false;
                        DateDiv.Visible = true;
                        break;
                    case "VWP":
                        vendorDiv.Visible = false;
                        accountDiv.Visible = false;
                        stockDiv.Visible = false;
                        DateDiv.Visible = true;
                        string sqlLUnin1 = "Select 0 as Vendor_ID, 'All' as Vendor_Name union all ";
                        System.Data.DataTable dtVende1 = DBClass.getDataTable(sqlLUnin1 + " Select Vendor_ID, (convert(Varchar,Vendor_ID) + ' - ' + Vendor_Name) as Vendor_Name from AP_Vendors");
                        ddlVendor.DataSource = dtVende1;
                        ddlVendor.DataTextField = "Vendor_Name";
                        ddlVendor.DataValueField = "Vendor_ID";
                        ddlVendor.DataBind();
                        break;
                    case "GRNS":
                        vendorDiv.Visible = true;
                        accountDiv.Visible = false;
                        stockDiv.Visible = false;
                        string sqlLiUnion = "Select 0 as Vendor_ID, 'All' as Vendor_Name union all ";
                        System.Data.DataTable dtVendorsss = DBClass.getDataTable(sqlLiUnion + " Select Vendor_ID, (convert(Varchar,Vendor_ID) + ' - ' + Vendor_Name) as Vendor_Name from AP_Vendors");
                        ddlVendor.DataSource = dtVendorsss;
                        ddlVendor.DataTextField = "Vendor_Name";
                        ddlVendor.DataValueField = "Vendor_ID";
                        ddlVendor.DataBind();

                        break;
                    case "IGPS":
                        vendorDiv.Visible = true;
                        accountDiv.Visible = false;
                        stockDiv.Visible = false;
                        string sqlLUnin = "Select 0 as Vendor_ID, 'All' as Vendor_Name union all ";
                        System.Data.DataTable dtVende = DBClass.getDataTable(sqlLUnin + " Select Vendor_ID, (convert(Varchar,Vendor_ID) + ' - ' + Vendor_Name) as Vendor_Name from AP_Vendors");
                        ddlVendor.DataSource = dtVende;
                        ddlVendor.DataTextField = "Vendor_Name";
                        ddlVendor.DataValueField = "Vendor_ID";
                        ddlVendor.DataBind();

                        break;
                    case "SIH":
                        vendorDiv.Visible = false;
                        stockDiv.Visible = true;
                        accountDiv.Visible = false;
                        DateDiv.Visible = true;
                        break;

                    default:
                        accountDiv.Visible = true;
                        stockDiv.Visible = false;
                        vendorDiv.Visible = false;
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
                    query = "ReportName=VendorWisePOSummary&ReportTitle=Vendor Wise PO Summary&Vendor_ID=" + ddlVendor.SelectedValue + "";
                    break;
                case "VWPS":
                    query = "ReportName=VendorWisePurchaseSummary&ReportTitle=Vendor Wise Purchase Summary from " + txtStart_Date.Text + " to " + txtEnd_Date.Text + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text + "&VendorId=0";
                    break;
                case "IGPS":
                    query = "ReportName=VendorWiseIGPS&ReportTitle=Vendor Wise Inward Gate Pass Summary from " + txtStart_Date.Text + " to " + txtEnd_Date.Text + "&Vendor_ID=" + ddlVendor.SelectedValue + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text + "";
                    break;
                case "GRNS":
                    query = "ReportName=VendorDetailsGRNS&ReportTitle=Good Receipt Note Summary from " + txtStart_Date.Text + " to " + txtEnd_Date.Text + "&Vendor_ID=" + ddlVendor.SelectedValue + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text + "";
                    break;
                case "VWP":
                    query = "ReportName=VendorWisePurchase&ReportTitle=Vendor Wise Purchase Detail from " + txtStart_Date.Text + " to " + txtEnd_Date.Text + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text + "&VendorId=" + ddlVendor.SelectedValue + "";
                    break;
                case "SIH":
                    query = "ReportName=PharmacyStock&ReportTitle=Stock In Hand &Stock=" + ddlStock.SelectedValue + "";
                    break;
                default:
                    query = "ReportName=Ledger&ReportTitle=Account ledger from " + txtStart_Date.Text + " to " + txtEnd_Date.Text + "&Account_ID=" + txtAccount_ID.Text.Trim() + "&startDate=" + txtStart_Date.Text + "&endDate=" + txtEnd_Date.Text;
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