using CrystalDecisions.CrystalReports.Engine;
using CrystalDecisions.Shared;
using Infragistics.Documents.Reports.RTF;
using Microsoft.Reporting.WebForms;
using PMS.Modules.PatientManagement;
using QRCoder;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Printing;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web.UI;
using static Telerik.Web.UI.OrgChartStyles;

namespace PMS
{
    public partial class ReportViewer : System.Web.UI.Page
    {
        ParameterFields paramFields;
        ReportDocument rd;
        protected void Page_Unload(object sender, EventArgs e)
        {

            rd.Close();
            rd.Dispose();

        }

        protected void Page_Init(object sender, EventArgs e)
        {

            //if (!IsPostBack)
            //{

            // LoadReport();
            //// CrystalReportViewer1.ReportSource = rd;
            //// CrystalReportViewer1.DataBind();
            // CrystalReportViewer1.Zoom(120);
            // Session["rpt"] = rd;

            //    }
            //    else
            //    {
            //       LoadReport();

            //        ReportDocument doc = (ReportDocument)Session["rpt"];
            //        CrystalReportViewer1.ReportSource = doc;

            //        CrystalReportViewer1.DataBind();
            //        CrystalReportViewer1.Zoom(120);
            //    }
            //     if (Session["rpt"] != null)
            //{

            //}

        }
        private void getDateTimeDBFormate(string Date, string Time, out string parameterDate)
        {
            string startTime = Time;
            string DateFormate = "yyyy-MM-dd";
            string DateTimeFormate = "yyyy-MM-dd hh:mm tt";
            string dateTime = Convert.ToDateTime(Date).ToString(DateFormate);
            dateTime += " " + Regex.Replace(Time, @"\s+", "");
            dateTime = Convert.ToDateTime(dateTime).ToString(DateTimeFormate);

            parameterDate = dateTime;
        }


        public void LoadReport()
        {
            GC.Collect();
            SqlConnectionStringBuilder SSB = new SqlConnectionStringBuilder(ConfigurationManager.ConnectionStrings["ASPGLConnectionString"].ConnectionString);
            string reportName = Request.QueryString["ReportName"];
            string reportTitle = Request.QueryString["ReportTitle"];
            string CompanyNamefolder = DBClass.getField("select Company_ReportFolder from Sys_Companys where Company_ID = " + AppConfig.Company_ID + "");
            string reportPath = Server.MapPath("~/Reports/");
            rd = new ReportDocument();
            paramFields = new ParameterFields();
            bool Export = Convert.ToBoolean(Request.QueryString["ExportPDF"]);

            #region "reports code here..."

            #region Inventory
            if (reportName == "Voucher")
            {
                if (Request.QueryString["TransID"] != null && Request.QueryString["TransType"] != null)
                {
                    string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                    string transType = Request.QueryString["TransType"].ToString();

                    int transID = Convert.ToInt32(Request.QueryString["TransID"]);
                    string VoucherId = string.Empty;
                    if (transType == "GRN")
                    {
                        VoucherId = DBClass.getField("select Voucher_ID from GRN_Master where GRN_ID = " + transID).ToString();
                    }
                    else if (transType == "Adj")
                    {
                        VoucherId = DBClass.getField("select Voucher_ID from INV_Stock_Adjustment where Adjustment_ID = " + transID).ToString();
                    }
                    else if (transType == "SIN")
                    {
                        VoucherId = DBClass.getField("select Voucher_ID from Store_Issue where Store_Issue_Id = " + transID).ToString();
                    }
                    else if (transType == "SRN")
                    {
                        VoucherId = DBClass.getField("select Voucher_ID from Goods_Return_Notes where Store_Return_Id = " + transID).ToString();
                    }
                    else if (transType == "LabShare")
                    {
                        VoucherId = DBClass.getField("select Voucher_ID from lab_test_Detail where lab_test_Detail_Id = " + transID).ToString();
                    }
                    else if (transType == "BIJV")
                    {
                        VoucherId = DBClass.getField("select Voucher_ID from Ar_Billings where Bill_Id = " + transID).ToString();
                    }
                    else if (transType == "DSJV")
                    {
                        VoucherId = DBClass.getField("select Doctor_Share_Voucher_ID from Ar_Billings where Bill_Id = " + transID).ToString();
                    }
                    else if (transType == "IPD_Dist")
                    {
                        VoucherId = DBClass.getField("Select Voucher_ID from IPD_Distribution_Master where Distribution_Id =  " + transID).ToString();
                    }
                    else if (transType == "IPD_Share")
                    {
                        VoucherId = DBClass.getField("Select Share_Voucher_ID from IPD_Distribution_Master where Distribution_Id =  " + transID).ToString();
                    }
                    else if (transType == "MIN")
                    {
                        VoucherId = DBClass.getField("select Voucher_ID from Manual_Invoice where ManualInvoiceId = " + transID).ToString();
                    }
                    else if (transType == "CardFee")
                    {
                        VoucherId = DBClass.getField("select Voucher_ID from Reg_patient where Pat_id = " + transID).ToString();
                    }
                    else if (transType == "Pur")
                    {
                        VoucherId = DBClass.getField("select Voucher_ID from Purchase_Invoice_Master where PurchaseInvoiceId = " + transID).ToString();
                    }
                    else if (transType == "Pay")
                    {
                        VoucherId = DBClass.getField("select Voucher_ID from Payment_Invoice where PaymentInvoiceId = " + transID).ToString();
                    }
                    else if (transType == "PURR")
                    {
                        VoucherId = DBClass.getField("select Voucher_ID from Purchase_Return_Master where Purchase_Return_ID = " + transID).ToString();
                    }
                    else if (transType == "ADV")
                    {
                        VoucherId = DBClass.getField("select Voucher_ID from Advance_Payment where Advance_ID = " + transID).ToString();
                    }
                    else if (transType == "OPD")
                    {
                        VoucherId = DBClass.getField("select Voucher_ID from Patients where Patient_ID = " + transID).ToString();
                    }
                    else if (transType == "SFV")
                    {
                        VoucherId = DBClass.getField("select Voucher_ID from Student_Fee where Fee_id = " + transID).ToString();
                    }
                    else if (transType == "SRV")
                    {
                        VoucherId = DBClass.getField("select Voucher_ID from Student_Receipt where student_receipt_id = " + transID).ToString();
                    }
                    else if (transType == "ACV")
                    {
                        VoucherId = DBClass.getField("select Voucher_ID_Accrued from Student_Receipt where student_receipt_id = " + transID).ToString();
                    }
                    else if (transType == "OPDShare")
                    {
                        VoucherId = DBClass.getField("select Voucher_ID from Out_Patient where Out_Patient_ID = " + transID).ToString();
                    }
                    else if (transType == "DPV")
                    {
                        VoucherId = DBClass.getField("select Voucher_ID from GL_Vouchers  where Voucher_ID = " + transID).ToString();
                    }
                    else if (transType == "PSV")
                    {
                        VoucherId = DBClass.getField("select Voucher_ID from Ar_Billings  where ispharmacy = 1 and Bill_id = " + transID).ToString();
                    }
                    else if (transType == "CPV")
                    {
                        VoucherId = DBClass.getField("select Voucher_ID from GL_Vouchers  where Voucher_ID = " + transID).ToString();
                    }
                    else if (transType == "ADV")
                    {
                        var rawVoucherId = DBClass.getField("select Voucher_ID from Advance_Payment where Advance_ID = " + transID);
                        VoucherId = rawVoucherId != null ? rawVoucherId.ToString() : "0"; // Default to "0" if null
                    }

                    else if (transType == "AJV")
                    {
                        VoucherId = DBClass.getField("select Voucher_id_adjustment from Purchase_Invoice_Master where PurchaseInvoiceId = " + transID).ToString();
                    }

                    reportPath += "Inventory/rptGLViewVoucher.rpt";
                    rd.Load(reportPath);
                    //rd.SetParameterValue("@Voucher_ID", Convert.ToInt32(VoucherId));    // this is the original parameter that is wihotu a fail safe 
                    //int voucherIdInt;
                    //if (!int.TryParse(VoucherId, out voucherIdInt))
                    //{
                    //    // If parsing fails, use a default value (like 0) or handle the error gracefully.
                    //    voucherIdInt = 0;
                    //}

                    rd.SetParameterValue("@Voucher_ID", Convert.ToInt32(VoucherId));
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Title", Title);
                    rd.SetParameterValue("UserName", AppConfig.UserName);
                    try
                    {
                        rd.SetParameterValue("@TransType", transType);
                    }
                    catch { }
                }
            }
            else if (reportName == "Voucher_GIN")
            {
                if (Request.QueryString["TransID"] != null && Request.QueryString["TransType"] != null)
                {
                    string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                    string transType = Request.QueryString["TransType"].ToString();

                    int transID = Convert.ToInt32(Request.QueryString["TransID"]);
                    string VoucherId = string.Empty;

                    if (transType == "SIN")
                    {
                        VoucherId = DBClass.getField("select Voucher_ID from Store_Issue where Store_Issue_Id = " + transID).ToString();
                    }
                    reportPath += "Inventory/rptGINPrint.rpt";
                    rd.Load(reportPath);
                    //rd.SetParameterValue("@Voucher_ID", Convert.ToInt32(VoucherId));    // this is the original parameter that is wihotu a fail safe 
                    int voucherIdInt;
                    if (!int.TryParse(VoucherId, out voucherIdInt))
                    {
                        // If parsing fails, use a default value (like 0) or handle the error gracefully.
                        voucherIdInt = 0;
                    }

                    rd.SetParameterValue("@Voucher_ID", voucherIdInt);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Title", Title);
                    rd.SetParameterValue("UserName", AppConfig.UserName);
                }
            }
   
            else if (reportName == "MinimumStock")
            {
                reportPath += "Inventory/rptMinimumStock.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                string itemId = Request.QueryString["Item"].ToString();
                string ItemCategory = Request.QueryString["ItemCategory"].ToString();
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@Item_Id", itemId);
                rd.SetParameterValue("@Item_Category", ItemCategory);
            }

            else if (reportName == "SIN_summary")
            {
                if (Request.QueryString["sDate"] != null && Request.QueryString["eDate"] != null)
                {
                    reportPath += "Inventory/rptSINSummary.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    string deptID = Request.QueryString["Department"].ToString();
                    string itemId = Request.QueryString["Item"].ToString();
                    string ItemCategory = Request.QueryString["ItemCategory"].ToString();
                    string Warehouse = Request.QueryString["WareHouse"].ToString();

                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("@stDate", Convert.ToDateTime(Request.QueryString["sDate"]));
                    rd.SetParameterValue("@endDate", Convert.ToDateTime(Request.QueryString["eDate"]));
                    rd.SetParameterValue("@Item_Id", itemId);
                    rd.SetParameterValue("@DepetID", deptID);
                    rd.SetParameterValue("@WareHouse", Warehouse);
                    rd.SetParameterValue("@Item_Category", ItemCategory);
                }
            }
            else if (reportName == "BER")
            {
                string rptFileName = "Inventory/rptBatchExpiry.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("@stDate", Convert.ToDateTime(Request.QueryString["sDate"]));
                rd.SetParameterValue("@endDate", Convert.ToDateTime(Request.QueryString["eDate"]));
                rd.SetParameterValue("@WareHouse", (Request.QueryString["Warehouse"]).ToString());
                rd.SetParameterValue("@Item", (Request.QueryString["Item"]).ToString());
            }
            else if (reportName == "StockLedgerWareHousewise")
            {
                string stitemcode = Request.QueryString["StartItemCode"].ToString();
                string enditemcode = Request.QueryString["EndItemCode"].ToString();
                string warehouse = Request.QueryString["WareHouse"].ToString();
                string itemCategory = Request.QueryString["Inventory_Org"].ToString();

                long sitemCode = Convert.ToInt64(stitemcode);
                long eitemCode = Convert.ToInt64(enditemcode);

                string stDate = Request.QueryString["StartDate"].ToString();
                string endDate = Request.QueryString["EndDate"].ToString();
                reportPath += "Inventory/rptStockLedgerWareHouseWise.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("@stDate", stDate);
                rd.SetParameterValue("@endDate", endDate);
                rd.SetParameterValue("@stItemCode", sitemCode);
                rd.SetParameterValue("@endItemCode", eitemCode);
                rd.SetParameterValue("@Ware_House", warehouse);
                rd.SetParameterValue("@ItemCategory", itemCategory);
            }
            else if (reportName == "StockLedgerWareHousewise_2")
            {
                string stitemcode = Request.QueryString["StartItemCode"].ToString();
                string enditemcode = Request.QueryString["EndItemCode"].ToString();
                string warehouse = Request.QueryString["WareHouse"].ToString();
                string itemCategory = Request.QueryString["Inventory_Org"].ToString();

                long sitemCode = Convert.ToInt64(stitemcode);
                long eitemCode = Convert.ToInt64(enditemcode);

                string stDate = Request.QueryString["StartDate"].ToString();
                string endDate = Request.QueryString["EndDate"].ToString();
                reportPath += "Inventory/rptStockLedgerWareHouseWise_2.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("@stDate", stDate);
                rd.SetParameterValue("@endDate", endDate);
                rd.SetParameterValue("@stItemCode", sitemCode);
                rd.SetParameterValue("@endItemCode", eitemCode);
                rd.SetParameterValue("@Ware_House", warehouse);
                rd.SetParameterValue("@ItemCategory", itemCategory);
            }
            else if (reportName == "PharmacyStockDetail")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string warehouse = Request.QueryString["WareHouse"].ToString();
                string StartDateTime = Request.QueryString["startDate"].ToString();
                string EndDateTime = Request.QueryString["endDate"].ToString();
                reportPath += "Pharmacy/rptPharmacyStockDetail.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("@StartDate", StartDateTime);
                rd.SetParameterValue("@EndDate", EndDateTime);
                rd.SetParameterValue("@warehouse", warehouse);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "CathLabStockDetail")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string warehouse = Request.QueryString["WareHouse"].ToString();
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                reportPath += "Inventory/rptCathLabStockDetail.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("@StartDate", StartDateTime);
                rd.SetParameterValue("@EndDate", EndDateTime);
                rd.SetParameterValue("@warehouse", warehouse);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "StockBalance")
            {
                string CurrentUserName = DBClass.getField("select username from aspnet_users where userid='" + AppConfig.UserID + "'").ToString();
                reportPath += "Inventory/StockMovement.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("@sDateTime", Convert.ToDateTime(Request.QueryString["sDate"]));
                rd.SetParameterValue("@warehouse", Request.QueryString["WareHouse"]);
                rd.SetParameterValue("@itemcode", Request.QueryString["itemCode"].ToString());
                rd.SetParameterValue("@ItemCategory", Request.QueryString["ItemCategory"].ToString());
                rd.SetParameterValue("OperatorName", CurrentUserName);

            }
            else if (reportName == "InwardGatePassList")
            {
                if (Request.QueryString["Igpid"] != null)
                {
                    string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                    reportPath += "Inventory/rptIGP_Print.rpt";
                    rd.Load(reportPath);
                    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                    rd.SetParameterValue("@IGP_ID", Convert.ToInt32(Request.QueryString["Igpid"]));
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", companyAddress);
                    rd.SetParameterValue("CompanyLogo", logoPath);
                }
            }
            else if (reportName == "GRNList")
            {
                if (Request.QueryString["GRNid"] != null)
                {
                    string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                    reportPath += "Inventory/rptGRN_Print.rpt";
                    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                    rd.Load(reportPath);
                    rd.SetParameterValue("@GRN_ID", Convert.ToInt32(Request.QueryString["GRNid"]));
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", companyAddress);
                    rd.SetParameterValue("CompanyLogo", logoPath);
                }
            }
            else if (reportName == "StoreTransferPrint")
            {
                reportPath += "Inventory/rptStore_Transfer_Print.rpt";
                rd.Load(reportPath);
                string StoreTransferID = Request.QueryString["Store_TransferID"].ToString();
                rd.SetParameterValue("@Store_Transfer_ID", Convert.ToInt32(StoreTransferID));
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
            }
            else if (reportName == "Inspection")
            {
                if (Request.QueryString["Igpid"] != null)
                {
                    string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                    reportPath += "Inventory/rptInspection.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@Igbp_ID", Convert.ToInt32(Request.QueryString["Igpid"]));
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", companyAddress);
                }
            }
            else if (reportName == "MaterialIssueRequestList")
            {
                if (Request.QueryString["MIRId"] != null)
                {
                    string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                    reportPath += "Inventory/rptMIRBasePrint.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@MIR_ID", Convert.ToInt32(Request.QueryString["MIRId"]));
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", companyAddress);
                }
            }
            else if (reportName == "StoreIssueBasePrint")
            {
                reportPath += "Inventory/rptInv_Store_Issue.rpt";
                rd.Load(reportPath);
                string StoreIssueID = Request.QueryString["SI_ID"].ToString();
                rd.SetParameterValue("@Store_Issue_ID", Convert.ToInt32(StoreIssueID));
                rd.SetParameterValue("@Store_Issue_ID", Convert.ToInt32(StoreIssueID), rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", Request.QueryString["ReportTitle"].ToString().Trim());
            }
            else if (reportName == "PurchaseReturnBasePrint")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                reportPath += "Purchase/rptPurchase_return.rpt";
                rd.Load(reportPath);
                string PurchaseReturnID = Request.QueryString["PurchaseReturnID"].ToString();
                rd.SetParameterValue("@purchaseReturnId", PurchaseReturnID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Address", companyAddress);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Title", Request.QueryString["ReportTitle"].ToString().Trim());
            }
            else if (reportName == "StockAdjustmentPrint")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                reportPath += "Inventory/rptStockAdjustment.rpt";
                rd.Load(reportPath);
                string stockadjustment = Request.QueryString["StockAdjustmentID"].ToString();
                rd.SetParameterValue("@Stock_Adjustment_Id", stockadjustment);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Address", companyAddress);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Title", Request.QueryString["ReportTitle"].ToString().Trim());
            }
            //else if (reportName == "StockTransferPrint")
            //{
            //    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
            //    string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
            //    reportPath += "Purchase/rptPurchase_return.rpt";
            //    rd.Load(reportPath);
            //    string PurchaseReturnID = Request.QueryString["PurchaseReturnID"].ToString();
            //    rd.SetParameterValue("@purchaseReturnId", PurchaseReturnID);
            //    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
            //    rd.SetParameterValue("Address", companyAddress);
            //    rd.SetParameterValue("CompanyLogo", logoPath);
            //    rd.SetParameterValue("Title", Request.QueryString["ReportTitle"].ToString().Trim());
            //}
            else if (reportName == "StoreIssueBasePrint_Thermal")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                reportPath += "Inventory/rptInv_Store_Issue_Thermal.rpt";
                rd.Load(reportPath);
                string StoreIssueID = Request.QueryString["SI_ID"].ToString();
                rd.SetParameterValue("@Store_Issue_ID", Convert.ToInt32(StoreIssueID));
                rd.SetParameterValue("@Store_Issue_ID", Convert.ToInt32(StoreIssueID), rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", Request.QueryString["ReportTitle"].ToString().Trim());
                rd.SetParameterValue("Address", companyAddress);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "PurchaseReturnList")
            {
                if (Request.QueryString["PRid"] != null)
                {
                    string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                    reportPath += "Inventory/rptPR_Print.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@PR_ID", Convert.ToInt32(Request.QueryString["PRid"]));
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", companyAddress);
                }
            }
            else if (reportName == "MIR_summary")
            {
                if (Request.QueryString["sDate"] != null && Request.QueryString["eDate"] != null)
                {
                    reportPath += "Inventory/rptMIR_Summary_Department_Wise.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    string deptID = Request.QueryString["Department"].ToString();
                    string Status = Request.QueryString["Item"].ToString();
                    rd.SetParameterValue("@sDateTime", Convert.ToDateTime(Request.QueryString["sDate"]));
                    rd.SetParameterValue("@endDateTime", Convert.ToDateTime(Request.QueryString["eDate"]));
                    rd.SetParameterValue("@Item_Id", Status);
                    rd.SetParameterValue("@DepetID", deptID);
                }
            }
            #endregion
            #region Patients
            else if (reportName == "Departmentwisestats")
            {
                reportPath += "Patients/rptDepartmentWiseStatics.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);

                string stDate = Request.QueryString["StartDate"].ToString();
                string stTime = Request.QueryString["StartTime"].ToString();

                string endDate = Request.QueryString["EndDate"].ToString();
                string endTime = Request.QueryString["EndTime"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);

                rd.SetParameterValue("@startDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
            }
            else if (reportName == "Birth_Certificate")
            {
                //var user_id = 
                var in_patient_id = Request.QueryString["Inpatient_ID"].ToString();
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                var user_id = AppConfig.UserID;
                var userName = DBClass.getField($"SELECT dbo.getUserName('{user_id}')");


                reportPath += "InPatient/rptBirthCertificate.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("User_ID", userName);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@patientId", in_patient_id);
            }
            else if (reportName == "AdminissionSlip")
            {
                //var user_id = 
                var in_patient_id = Request.QueryString["Inpatient_ID"].ToString();
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                var user_id = AppConfig.UserID;
                var userName = DBClass.getField($"SELECT dbo.getUserName('{user_id}')");


                reportPath += "InPatient/rptAdmissionPrint.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("User_ID", userName);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@patientId", in_patient_id);

                // ===== DYNAMIC QR CODE GENERATION (NO DATABASE STORAGE) =====
                try
                {
                    string sql = $@"
        SELECT ISNULL(rp.mr_no_sequence, '') AS mr_no_sequence,
               ISNULL(rp.Full_Name, '') AS Full_Name,
               ISNULL(CONVERT(VARCHAR, rp.Age_years), '') AS Age_years,
               ISNULL(rp.Gender, '') AS Gender
        FROM Reg_patient rp
        JOIN In_Patient ip ON ip.patient_id = rp.pat_id
        WHERE ip.In_Patient_ID = {in_patient_id}";

                    DataTable patientData = DBClass.getDataTable(sql);

                    if (patientData.Rows.Count > 0)
                    {
                        string qrContent = $"MR:{patientData.Rows[0]["mr_no_sequence"]}|Name:{patientData.Rows[0]["Full_Name"]}|Age:{patientData.Rows[0]["Age_years"]}|Gender:{patientData.Rows[0]["Gender"]}";

                        // Save to temp file instead of passing bytes
                        string tempQrPath = Path.Combine(Path.GetTempPath(), $"QR_{in_patient_id}_{Guid.NewGuid()}.png");

                        using (QRCodeGenerator qrGenerator = new QRCodeGenerator())
                        {
                            QRCodeData qrCodeData = qrGenerator.CreateQrCode(qrContent, QRCodeGenerator.ECCLevel.Q);
                            using (PngByteQRCode qrCodeImage = new PngByteQRCode(qrCodeData))
                            {
                                byte[] qrBytes = qrCodeImage.GetGraphic(10);
                                File.WriteAllBytes(tempQrPath, qrBytes);
                            }
                        }

                        // Pass FILE PATH as string parameter
                        rd.SetParameterValue("QRImagePath", tempQrPath);
                    }
                    else
                    {
                        rd.SetParameterValue("QRImagePath", "");
                    }
                }
                catch (Exception ex)
                {
                    rd.SetParameterValue("QRImagePath", "");
                }


            }
            else if (reportName == "InPatient_Advance_Bill")
            {
                //var user_id = 
                var in_patient_id = Request.QueryString["Inpatient_ID"].ToString();
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                var user_id = AppConfig.UserID;
                var userName = DBClass.getField($"SELECT dbo.getUserName('{user_id}')");


                reportPath += "InPatient/rptIn_Patient_Advance_Billing.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("User_ID", userName);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("Address", companyAddress);
                rd.SetParameterValue("@In_Patient_ID", in_patient_id);

                // ===== DYNAMIC QR CODE GENERATION (NO DATABASE STORAGE) =====
                try
                {
                    string sql = $@"
        SELECT ISNULL(rp.mr_no_sequence, '') AS mr_no_sequence,
               ISNULL(rp.Full_Name, '') AS Full_Name,
               ISNULL(CONVERT(VARCHAR, rp.Age_years), '') AS Age_years,
               ISNULL(rp.Gender, '') AS Gender
        FROM Reg_patient rp
        JOIN In_Patient ip ON ip.patient_id = rp.pat_id
        WHERE ip.In_Patient_ID = {in_patient_id}";

                    DataTable patientData = DBClass.getDataTable(sql);

                    if (patientData.Rows.Count > 0)
                    {
                        string qrContent = $"MR:{patientData.Rows[0]["mr_no_sequence"]}|Name:{patientData.Rows[0]["Full_Name"]}|Age:{patientData.Rows[0]["Age_years"]}|Gender:{patientData.Rows[0]["Gender"]}";

                        // Save to temp file instead of passing bytes
                        string tempQrPath = Path.Combine(Path.GetTempPath(), $"QR_{in_patient_id}_{Guid.NewGuid()}.png");

                        using (QRCodeGenerator qrGenerator = new QRCodeGenerator())
                        {
                            QRCodeData qrCodeData = qrGenerator.CreateQrCode(qrContent, QRCodeGenerator.ECCLevel.Q);
                            using (PngByteQRCode qrCodeImage = new PngByteQRCode(qrCodeData))
                            {
                                byte[] qrBytes = qrCodeImage.GetGraphic(10);
                                File.WriteAllBytes(tempQrPath, qrBytes);
                            }
                        }

                        // Pass FILE PATH as string parameter
                        rd.SetParameterValue("QRImagePath", tempQrPath);
                    }
                    else
                    {
                        rd.SetParameterValue("QRImagePath", "");
                    }
                }
                catch (Exception ex)
                {
                    rd.SetParameterValue("QRImagePath", "");
                }


            }
            else if (reportName == "DischargePrint")
            {

                var in_patient_id = Request.QueryString["InPatientId"].ToString();

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                reportPath += "InPatient/rptDischargeSlip.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("@PatientId", in_patient_id);


                // ===== DYNAMIC QR CODE GENERATION (NO DATABASE STORAGE) =====
                try
                {
                    string sql = $@"
        SELECT ISNULL(rp.mr_no_sequence, '') AS mr_no_sequence,
               ISNULL(rp.Full_Name, '') AS Full_Name,
               ISNULL(CONVERT(VARCHAR, rp.Age_years), '') AS Age_years,
               ISNULL(rp.Gender, '') AS Gender
        FROM Reg_patient rp
        JOIN In_Patient ip ON ip.patient_id = rp.pat_id
        WHERE ip.In_Patient_ID = {in_patient_id}";

                    DataTable patientData = DBClass.getDataTable(sql);

                    if (patientData.Rows.Count > 0)
                    {
                        string qrContent = $"MR:{patientData.Rows[0]["mr_no_sequence"]}|Name:{patientData.Rows[0]["Full_Name"]}|Age:{patientData.Rows[0]["Age_years"]}|Gender:{patientData.Rows[0]["Gender"]}";

                        // Save to temp file instead of passing bytes
                        string tempQrPath = Path.Combine(Path.GetTempPath(), $"QR_{in_patient_id}_{Guid.NewGuid()}.png");

                        using (QRCodeGenerator qrGenerator = new QRCodeGenerator())
                        {
                            QRCodeData qrCodeData = qrGenerator.CreateQrCode(qrContent, QRCodeGenerator.ECCLevel.Q);
                            using (PngByteQRCode qrCodeImage = new PngByteQRCode(qrCodeData))
                            {
                                byte[] qrBytes = qrCodeImage.GetGraphic(10);
                                File.WriteAllBytes(tempQrPath, qrBytes);
                            }
                        }

                        // Pass FILE PATH as string parameter
                        rd.SetParameterValue("QRImagePath", tempQrPath);
                    }
                    else
                    {
                        rd.SetParameterValue("QRImagePath", "");
                    }
                }
                catch (Exception ex)
                {
                    rd.SetParameterValue("QRImagePath", "");
                }



            }
            else if (reportName == "DischargeDetailedPrint")
            {

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string InPatientId = Request.QueryString["InPatientId"].ToString();
                reportPath += "InPatient/rptDischargeBasePrint.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("@InPatientId", InPatientId);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("@InPatientId", Convert.ToInt32(InPatientId), rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@InPatientId", Convert.ToInt32(InPatientId), rd.Subreports[1].Name.ToString());
                rd.SetParameterValue("@InPatientId", Convert.ToInt32(InPatientId), rd.Subreports[2].Name.ToString());
                rd.SetParameterValue("@InPatientId", Convert.ToInt32(InPatientId), rd.Subreports[3].Name.ToString());
                rd.SetParameterValue("@InPatientId", Convert.ToInt32(InPatientId), rd.Subreports[4].Name.ToString());
                rd.SetParameterValue("@InPatientId", Convert.ToInt32(InPatientId), rd.Subreports[5].Name.ToString());
            }



            else if (reportName == "Emergencypatient")
            {
                string Emergency_ID = Request.QueryString["Emergency_ID"].ToString();
                var user_id = AppConfig.UserID;
                var userName = DBClass.getField($"SELECT dbo.getUserName('{user_id}')");


                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                reportPath += "Emergency/rptEmergencypatientDetails.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("@emergencyid", Convert.ToInt32(Emergency_ID));
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("UserName", userName);
                rd.SetParameterValue("@emergencyid", Convert.ToInt32(Emergency_ID), rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@emergencyid", Convert.ToInt32(Emergency_ID), rd.Subreports[1].Name.ToString());
                rd.SetParameterValue("@emergencyid", Convert.ToInt32(Emergency_ID), rd.Subreports[2].Name.ToString());
                rd.SetParameterValue("@emergencyid", Convert.ToInt32(Emergency_ID), rd.Subreports[3].Name.ToString());
                rd.SetParameterValue("@emergencyid", Convert.ToInt32(Emergency_ID), rd.Subreports[4].Name.ToString());
                rd.SetParameterValue("@emergencyid", Convert.ToInt32(Emergency_ID), rd.Subreports[5].Name.ToString());
            }
            //else if (reportName == "CONSULTANT_Wise_Statistics")
            //{

            //    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

            //    reportPath += "Patients/rptCounsltant_Wise_stat_report.rpt";
            //    rd.Load(reportPath);
            //    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
            //    rd.SetParameterValue("CompanyLogo", logoPath);
            //    rd.SetParameterValue("Title", reportTitle);
            //    string Doctor = Request.QueryString["Doctor"].ToString();
            //    string stDate = Request.QueryString["StartDate"].ToString();
            //    string stTime = Request.QueryString["StartTime"].ToString();

            //    string endDate = Request.QueryString["EndDate"].ToString();
            //    string endTime = Request.QueryString["EndTime"].ToString();

            //    string parameterStDate = string.Empty;
            //    string parameterEndDate = string.Empty;

            //    this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
            //    this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);
            //    rd.SetParameterValue("@docid", Doctor);
            //    rd.SetParameterValue("@startDate", parameterStDate);
            //    rd.SetParameterValue("@endDate", parameterEndDate);
            //}
            //else if (reportName == "Counsltant_Day_Wise_report")
            //{


            //    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
            //    reportPath += "Patients/rptCounsltant_Day_Wise_report.rpt";
            //    rd.Load(reportPath);
            //    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
            //    rd.SetParameterValue("Title", reportTitle);
            //    rd.SetParameterValue("CompanyLogo", logoPath);

            //    string stDate = Request.QueryString["StartDate"].ToString();
            //    string stTime = Request.QueryString["StartTime"].ToString();

            //    string endDate = Request.QueryString["EndDate"].ToString();
            //    string endTime = Request.QueryString["EndTime"].ToString();
            //    string Doctor = Request.QueryString["Doctor"].ToString();

            //    string parameterStDate = string.Empty;
            //    string parameterEndDate = string.Empty;

            //    this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
            //    this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);
            //    rd.SetParameterValue("@docid", Doctor);
            //    rd.SetParameterValue("@startDate", parameterStDate);
            //    rd.SetParameterValue("@endDate", parameterEndDate);
            //}
            else if (reportName == "HospitalCashReport")
            {

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                reportPath += "Patients/rptPatients_Info.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("CompanyLogo", logoPath);

                string stDate = Request.QueryString["StartDate"].ToString();
                string stTime = Request.QueryString["StartTime"].ToString();

                string endDate = Request.QueryString["EndDate"].ToString();
                string endTime = Request.QueryString["EndTime"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);

                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("@Operator", Request.QueryString["Operator"]);
                rd.SetParameterValue("@PatientType", Request.QueryString["Patient_Type"]);
            }

            else if (reportName == "OPDDetailReport")
            {

                string rptFileName = "Patients/OPDDetailReport.rpt";
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string doctorID = Request.QueryString["DoctorID"].ToString();


                string CheckSummary = Request.QueryString["Summary"].ToString();
                if (CheckSummary == "true")
                {
                    rptFileName = "Patients/OPDDetailReport_Summary.rpt";
                    reportTitle = "OPD Detail Summary From " + Request.QueryString["StartDateTime"].ToString() + "to" + Request.QueryString["EndDateTime"].ToString();
                }

                string FilterClinic = Request.QueryString["FilterClinic"].ToString();

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string sqlStartDateTime = Convert.ToDateTime(StartDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string sqlEndDateTime = Convert.ToDateTime(EndDateTime).ToString("yyyy-MM-dd HH:mm:ss");

                string departmentID = Request.QueryString["Department"].ToString();
                if (departmentID == "0")
                {
                    departmentID = "All";
                }
                string Operator = Request.QueryString["Operator"].ToString();
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@FromDate", sqlStartDateTime);
                rd.SetParameterValue("@ToDate", sqlEndDateTime);
                rd.SetParameterValue("@Operator", Operator);
                rd.SetParameterValue("@Department", departmentID);
                rd.SetParameterValue("@filterClinic", FilterClinic);
                rd.SetParameterValue("@DoctorID", doctorID);

                try
                {
                    string subreportName = rd.Subreports[0].Name;

                    rd.SetParameterValue("@Company_ID", AppConfig.Company_ID, subreportName);
                    rd.SetParameterValue("@FromDate", sqlStartDateTime, subreportName);
                    rd.SetParameterValue("@ToDate", sqlEndDateTime, subreportName);
                    rd.SetParameterValue("@Operator", Operator, subreportName);
                    rd.SetParameterValue("@Department", departmentID, subreportName);
                    rd.SetParameterValue("@filterClinic", FilterClinic, subreportName);
                    rd.SetParameterValue("@DoctorID", doctorID, subreportName);
                    
                }
                catch (Exception ex)
                {
                    
                }

            }
            else if (reportName == "EmergencyDetailReport")
            {
                string rptFileName = "Emergency/EmergencyDetailReport.rpt";
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string doctorID = Request.QueryString["DoctorID"].ToString();

                string CheckSummary = Request.QueryString["Summary"].ToString();
                if (CheckSummary == "true")
                {
                    rptFileName = "Patients/EmergencyDetailReport_Summary.rpt";
                    reportTitle = "Emergency Detail Summary From "
                        + Request.QueryString["StartDateTime"].ToString()
                        + " to "
                        + Request.QueryString["EndDateTime"].ToString();
                }

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string sqlStartDateTime = Convert.ToDateTime(StartDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string sqlEndDateTime = Convert.ToDateTime(EndDateTime).ToString("yyyy-MM-dd HH:mm:ss");

                string departmentID = Request.QueryString["Department"].ToString();
                if (departmentID == "0")
                {
                    departmentID = "All";
                }

                string Operator = Request.QueryString["Operator"].ToString();
                reportPath += rptFileName;
                rd.Load(reportPath);

                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Title", reportTitle);

                rd.SetParameterValue("@FromDate", sqlStartDateTime);
                rd.SetParameterValue("@ToDate", sqlEndDateTime);
                rd.SetParameterValue("@Operator", Operator);
                rd.SetParameterValue("@Department", departmentID);
                rd.SetParameterValue("@DoctorID", doctorID);
            }

            else if (reportName == "OPD_Department_Wise_Report")
            {
                string rptFileName = "Patients/OPDDepartmentWiseReport.rpt";
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                //string Shift = Request.QueryString["Shift"].ToString();

                string doctorID = Request.QueryString["DoctorID"].ToString();
                string PatientType = Request.QueryString["PatientType"].ToString();

                string sqlStartDateTime = Convert.ToDateTime(StartDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string sqlEndDateTime = Convert.ToDateTime(EndDateTime).ToString("yyyy-MM-dd HH:mm:ss");

                string departmentID = Request.QueryString["Department"].ToString();
                if (departmentID == "0")
                {
                    departmentID = "All";
                }

                string shiftText = Request.QueryString["Shift"]?.ToString() ?? "All";

                // Convert the text to the correct integer ID
                string shiftId = "0"; // Default for "All"
                if (shiftText == "Morning")
                    shiftId = "2";
                else if (shiftText == "Evening")
                    shiftId = "3";
                else if (shiftText == "Night")
                    shiftId = "4";

                string Operator = Request.QueryString["Operator"].ToString();
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@FromDate", sqlStartDateTime);
                rd.SetParameterValue("@ToDate", sqlEndDateTime);
                rd.SetParameterValue("@Operator", Operator);         // operator
                //rd.SetParameterValue("Shift", Shift);
                rd.SetParameterValue("@Shift_id", shiftId);
                rd.SetParameterValue("@DoctorID", doctorID);
                rd.SetParameterValue("@Department", departmentID);
                rd.SetParameterValue("@PatientType", PatientType);
            }


            else if (reportName == "PCRS")
            {

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string sqlStartDateTime = Convert.ToDateTime(StartDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string sqlEndDateTime = Convert.ToDateTime(EndDateTime).ToString("yyyy-MM-dd HH:mm:ss");


                string rptFileName = "Pharmacy/rptPharmacyCashSummary.rpt";
                //string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                //string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                string itemName = Request.QueryString["Item"].ToString();
                string companyName = Request.QueryString["Company"].ToString();
                string operatorName = Request.QueryString["Operator"].ToString();
                string warehouse = Request.QueryString["WareHouse"].ToString();
                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@startDate", sqlStartDateTime);
                rd.SetParameterValue("@endDate", sqlEndDateTime);
                rd.SetParameterValue("@itemId", itemName);
                rd.SetParameterValue("@operator", operatorName);
                rd.SetParameterValue("@companyId", companyName);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("@Warehouse", warehouse);


                rd.SetParameterValue("@startDate", sqlStartDateTime, rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@endDate", sqlEndDateTime, rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@itemId", itemName, rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@operator", operatorName, rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@companyId", companyName, rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@Warehouse", warehouse, rd.Subreports[0].Name.ToString());
            }


            else if (reportName == "Consultant_Wise_Statistics")
            {
                string rptFileName = "TransactionalDetails/rptCounsltant_Wise_stat_report.rpt";
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string doctorID = Request.QueryString["DoctorID"].ToString();
                string sqlStartDateTime = Convert.ToDateTime(StartDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string sqlEndDateTime = Convert.ToDateTime(EndDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@startdate", sqlStartDateTime);
                rd.SetParameterValue("@endDate", sqlEndDateTime);
                rd.SetParameterValue("@DoctorID", doctorID);
            }
            else if (reportName == "Counsltant_Day_Wise_report")
            {
                string rptFileName = "TransactionalDetails/rptConsltant_Day_Wise_report.rpt";
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string doctorID = Request.QueryString["DoctorID"].ToString();
                string sqlStartDateTime = Convert.ToDateTime(StartDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string sqlEndDateTime = Convert.ToDateTime(EndDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@startdate", sqlStartDateTime);
                rd.SetParameterValue("@endDate", sqlEndDateTime);
                rd.SetParameterValue("@DoctorID", doctorID);
            }
            else if (reportName == "Department_Wise_Statistics")
            {
                string rptFileName = "TransactionalDetails/rptDepartmentWiseStatics.rpt";
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string sqlStartDateTime = Convert.ToDateTime(StartDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string sqlEndDateTime = Convert.ToDateTime(EndDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@startdate", sqlStartDateTime);
                rd.SetParameterValue("@endDate", sqlEndDateTime);
            }
            else if (reportName == "Over_Summary_Shift_Wise")
            {
                string rptFileName = "TransactionalDetails/OverSummaryShiftWise.rpt";
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string sqlStartDateTime = Convert.ToDateTime(StartDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string sqlEndDateTime = Convert.ToDateTime(EndDateTime).ToString("yyyy-MM-dd HH:mm:ss");

                string departmentID = Request.QueryString["Department"].ToString();
                //string Shift = Request.QueryString["Shift"].ToString();
                //if (Shift == "All")
                //{
                //    Shift = "0";
                //}
                string shiftText = Request.QueryString["Shift"]?.ToString() ?? "All";

                // Convert the text to the correct integer ID
                string shiftId = "0"; // Default for "All"
                if (shiftText == "Morning")
                    shiftId = "2";
                else if (shiftText == "Evening")
                    shiftId = "3";
                else if (shiftText == "Night")
                    shiftId = "4";
                // If it's "All" or anything else, keep it as "0"
                string Operator = Request.QueryString["Operator"].ToString();
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@FromDate", sqlStartDateTime);
                rd.SetParameterValue("@ToDate", sqlEndDateTime);
                rd.SetParameterValue("@Operator", Operator);
                rd.SetParameterValue("@Shift_id", shiftId);
                rd.SetParameterValue("@Department", departmentID);
            }
            else if (reportName == "Day_Activity")
            {
                string rptFileName = "Inventory/OverSummaryShiftWise.rpt";
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string sqlStartDateTime = Convert.ToDateTime(StartDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string sqlEndDateTime = Convert.ToDateTime(EndDateTime).ToString("yyyy-MM-dd HH:mm:ss");


                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@FromDate", sqlStartDateTime);
                rd.SetParameterValue("@ToDate", sqlEndDateTime);
            }
            else if (reportName == "DepartmentWiseReport")
            {
                string rptFileName = "DepartmentWiseReport.rpt";
                bool CheckSummary = Convert.ToBoolean(Request.QueryString["Summary"]);
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                string Shift = Request.QueryString["Shift"].ToString();
                string DoctorName = Request.QueryString["DoctorName"].ToString();

                if (CheckSummary == true)
                {
                    rptFileName = "DepartmentWiseReport_Summary.rpt";
                    reportTitle = "OPD Summary Report From " + StartDateTime + " to " + EndDateTime;
                }
                reportPath += rptFileName;

                rd.Load(reportPath);

                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("Shift", Shift);
                rd.SetParameterValue("@FromDate", StartDateTime);
                rd.SetParameterValue("@ToDate", EndDateTime);
                rd.SetParameterValue("@ToDate", EndDateTime);

                rd.SetParameterValue("@Operator", Request.QueryString["Operator"]);
                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                string departmentID = Request.QueryString["Department"].ToString();
                rd.SetParameterValue("@Department", departmentID);
                rd.SetParameterValue("@DoctorName", DoctorName);

                string Discharge = Request.QueryString["Discount"].ToString();


                if (Discharge == "1")
                {
                    rd.RecordSelectionFormula = "{OPD_Detail_Report;1.Discount}> 0";
                }
                else if (Discharge == "2")
                {
                    rd.RecordSelectionFormula = "{OPD_Detail_Report;1.Discount} = 0";
                }
            }
            else if (reportName == "DoctorWiseUltrasoundReport")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string rptFileName = "LabRadiology/rptDoctorWiseUltrasoundReport.rpt";
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                string doctorID = Request.QueryString["DoctorID"].ToString();
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@StartDate", StartDateTime);
                rd.SetParameterValue("@EndDate", EndDateTime);
                rd.SetParameterValue("@Doctor_Id", doctorID);
                rd.SetParameterValue("CompanyLogo", logoPath);

            }


            else if (reportName == "IPDDetailReport")
            {

                string rptFileName = "InPatient/IPD_Detail_Report.rpt";
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string CheckSummary = Request.QueryString["Summary"].ToString();
                if (CheckSummary == "true")
                {
                    rptFileName = "InPatient/IPD_Detail_Report_Summary.rpt";
                    reportTitle = "IPD Detail Summary From " + Request.QueryString["StartDateTime"].ToString() + "to" + Request.QueryString["EndDateTime"].ToString();
                }
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                string sqlStartDateTime = Convert.ToDateTime(StartDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string sqlEndDateTime = Convert.ToDateTime(EndDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string departmentID = Request.QueryString["Department"].ToString();
                if (departmentID == "0")
                {
                    departmentID = "All";
                }
                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();

                string Operator = Request.QueryString["Operator"].ToString();
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("CompanyAddress", companyAddress);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@FromDate", sqlStartDateTime);
                rd.SetParameterValue("@ToDate", sqlEndDateTime);
                rd.SetParameterValue("@Operator", Operator);
                rd.SetParameterValue("@Department", departmentID);
            }
            else if (reportName == "EmerDetailReport")
            {

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string sqlStartDateTime = Convert.ToDateTime(StartDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string sqlEndDateTime = Convert.ToDateTime(EndDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                string Operator = Request.QueryString["Operator"].ToString();

                string rptFileName = "Emergency/Emergency_Detail_Report.rpt";
                string CheckSummary = Request.QueryString["Summary"].ToString();

                if (CheckSummary == "true")
                {
                    rptFileName = "Emergency/Emergency_Detail_Report_Summary.rpt";
                    reportTitle = "Emergency Detail Summary From " + sqlStartDateTime + "to" + sqlEndDateTime;
                }

                reportPath += rptFileName;
                rd.Load(reportPath);

                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("CompanyAddress", companyAddress);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@FromDate", sqlStartDateTime);
                rd.SetParameterValue("@ToDate", sqlEndDateTime);
                rd.SetParameterValue("@Operator", Operator);
            }
            else if (reportName == "Emergency_Reg_Report")
            {

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string rptFileName = "Emergency/Reg_Emergency_Detail_Report.rpt";
                string CheckSummary = Request.QueryString["Summary"].ToString();
                if (CheckSummary == "true")
                {
                    rptFileName = "Emergency/Reg_Emergency_Detail_Report_Summary.rpt";
                    reportTitle = "Registered Emergency Summary From " + Request.QueryString["StartDateTime"].ToString() + "to" + Request.QueryString["EndDateTime"].ToString();
                }
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string sqlStartDateTime = Convert.ToDateTime(StartDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string sqlEndDateTime = Convert.ToDateTime(EndDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();

                string Operator = Request.QueryString["Operator"].ToString();
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("CompanyAddress", companyAddress);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@FromDate", sqlStartDateTime);
                rd.SetParameterValue("@ToDate", sqlEndDateTime);
                rd.SetParameterValue("@Operator", Operator);
            }
            else if (reportName == "OPD_Time_Line")
            {
                string reportType = Request.QueryString["Report_Type"].ToString();
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string sqlStartDateTime = Convert.ToDateTime(StartDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string sqlEndDateTime = Convert.ToDateTime(EndDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string fileName = string.Empty;
                if (reportType == "Weekly")
                {
                    fileName = "GeneralPatientsReport/rptWeeklyPatientRegistrations_WRT_Department.rpt";
                }
                else if (reportType == "Monthly")
                {
                    fileName = "GeneralPatientsReport/rptDailyRegistrationsOfDepartmentMonthly.rpt";
                }
                else if (reportType == "Annually")
                {
                    fileName = "GeneralPatientsReport/rptMonthlyRegistrationsOfDepartmentAnually.rpt";
                }
                reportPath += fileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);

                rd.SetParameterValue("@stDate", sqlStartDateTime);
                rd.SetParameterValue("@endDate", sqlEndDateTime);
                rd.SetParameterValue("@Operator", "0");
                if (reportType == "Monthly" || reportType == "Annually")
                {
                    rd.SetParameterValue("@Trans_Type", "OPD");
                }
            }
            else if (reportName == "Emergency_Time_Line")
            {
                string reportType = Request.QueryString["Report_Type"].ToString();
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string sqlStartDateTime = Convert.ToDateTime(StartDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string sqlEndDateTime = Convert.ToDateTime(EndDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string fileName = string.Empty;
                if (reportType == "Weekly")
                {
                    fileName = "Emergency/rptWeeklyPatientRegistrations_WRT_Department.rpt";
                }
                else if (reportType == "Monthly")
                {
                    fileName = "Emergency/rptDailyRegistrationsOfDepartmentMonthly.rpt";
                }
                else if (reportType == "Annually")
                {
                    fileName = "Emergency/rptMonthlyRegistrationsOfDepartmentAnually.rpt";
                }
                reportPath += fileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);

                rd.SetParameterValue("@stDate", sqlStartDateTime);
                rd.SetParameterValue("@endDate", sqlEndDateTime);

            }
            else if (reportName == "IPDTimeLine")
            {
                string reportType = Request.QueryString["Report_Type"].ToString();
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string sqlStartDateTime = Convert.ToDateTime(StartDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string sqlEndDateTime = Convert.ToDateTime(EndDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string fileName = string.Empty;
                if (reportType == "Monthly")
                {
                    fileName = "InPatient/rptDailyRegistrationsOfDepartmentMonthly.rpt";
                }
                else if (reportType == "Annually")
                {
                    fileName = "InPatient/rptMonthlyRegistrationsOfDepartmentAnually.rpt";
                }
                reportPath += fileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);

                rd.SetParameterValue("@stDate", sqlStartDateTime);
                rd.SetParameterValue("@endDate", sqlEndDateTime);
                rd.SetParameterValue("@Operator", "0");
                rd.SetParameterValue("@Trans_Type", "IPD");
            }
            else if (reportName == "DischargeTimeLine")
            {
                string reportType = Request.QueryString["Report_Type"].ToString();
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string sqlStartDateTime = Convert.ToDateTime(StartDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string sqlEndDateTime = Convert.ToDateTime(EndDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string fileName = string.Empty;
                if (reportType == "Monthly")
                {
                    fileName = "InPatient/rptDailyRegistrationsOfDepartmentMonthly.rpt";
                }
                else if (reportType == "Annually")
                {
                    fileName = "InPatient/rptMonthlyRegistrationsOfDepartmentAnually.rpt";
                }
                reportPath += fileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);

                rd.SetParameterValue("@stDate", sqlStartDateTime);
                rd.SetParameterValue("@endDate", sqlEndDateTime);
                rd.SetParameterValue("@Operator", "0");
                rd.SetParameterValue("@Trans_Type", "DISCHARGE");
            }
            else if (reportName == "Discharge")
            {
                string reportType = Request.QueryString["Report_Type"].ToString();
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string sqlStartDateTime = Convert.ToDateTime(StartDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string sqlEndDateTime = Convert.ToDateTime(EndDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string fileName = string.Empty;
                if (reportType == "Monthly")
                {
                    //fileName = "rptWard_Room_Allocation_Monthly_Daywise_Summary.rpt";
                    fileName = "rptBed_Occupancy_Of_Month.rpt";
                }
                else if (reportType == "Annually")
                {
                    //fileName = "rptMonthlyAnnualWardAllocation.rpt";
                    fileName = "rptBedOccupancyAnnually.rpt";
                }
                else if (reportType == "Annually With Stay Days")
                {
                    fileName = "rptBed_Occupancy_With_Stay_Days_Anually.rpt";
                }
                else if (reportType == "Annually With Stay Days Summary")
                {
                    fileName = "rptBed_Occupancy_With_Stay_Days_Anually_Summary.rpt";
                }
                else if (reportType == "Annually With Stay Days Summary Department Wise")
                {
                    fileName = "rptBed_Occupancy_With_Stay_Days_Anually_SummaryDepartmentWise.rpt";
                }
                reportPath += fileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);

                rd.SetParameterValue("@stDate", sqlStartDateTime);
                rd.SetParameterValue("@endDate", sqlEndDateTime);
                rd.SetParameterValue("@Operator", "0");
                rd.SetParameterValue("@Trans_Type", "DISCHARGE");
            }
            else if (reportName == "AverageLengthOfStay")
            {
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string reportType = Request.QueryString["Report_Type"].ToString();
                string fileName = string.Empty;
                if (reportType == "Annually")
                {
                    fileName = "Hospital/rptMonthlyRegistrationsOfDepartmentAnually_Decimals.rpt";
                }
                else if (reportType == "Annually with Stay Days")
                {
                    fileName = "Hospital/rptALOS_AnuallyWithDays.rpt";
                }
                else if (reportType == "Annually with Stay Days Summary")
                {
                    fileName = "Hospital/rptALOS_AnuallyWithDays_Summary.rpt";
                }
                reportPath += fileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", "" + reportType + " ALOS Report From " + Convert.ToDateTime(Request.QueryString["sDate"]).ToString("dd-MMM-yyyy") + " To " + Convert.ToDateTime(Request.QueryString["eDate"]).ToString("dd-MMM-yyyy"));
                rd.SetParameterValue("@stDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("@Operator", "0");
                rd.SetParameterValue("@Trans_Type", "ALOS");
            }
            else if (reportName == "BedOccupancy")
            {
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string reportType = Request.QueryString["Report_Type"].ToString();
                string fileName = string.Empty;
                if (reportType == "Monthly")
                {
                    //fileName = "rptWard_Room_Allocation_Monthly_Daywise_Summary.rpt";
                    fileName = "Hospital/rptBed_Occupancy_Of_Month.rpt";
                }
                else if (reportType == "Annually")
                {
                    //fileName = "rptMonthlyAnnualWardAllocation.rpt";
                    fileName = "Hospital/rptBedOccupancyAnnually.rpt";
                }
                else if (reportType == "Annually With Stay Days")
                {
                    fileName = "Hospital/rptBed_Occupancy_With_Stay_Days_Anually.rpt";
                }
                else if (reportType == "Annually With Stay Days Summary")
                {
                    fileName = "Hospital/rptBed_Occupancy_With_Stay_Days_Anually_Summary.rpt";
                }
                else if (reportType == "Annually With Stay Days Summary Department Wise")
                {
                    fileName = "Hospital/rptBed_Occupancy_With_Stay_Days_Anually_SummaryDepartmentWise.rpt";
                }

                reportPath += fileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", "" + reportType + " Bed Occupancy Time Line Report From " + Convert.ToDateTime(Request.QueryString["sDate"]).ToString("dd-MMM-yyyy") + " To " + Convert.ToDateTime(Request.QueryString["eDate"]).ToString("dd-MMM-yyyy"));
                rd.SetParameterValue("@stDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("@Operator", "0");
                rd.SetParameterValue("@Trans_Type", "BedOccupancy");
                if (reportType == "Annually With Stay Days" || reportType == "Annually With Stay Days Summary")
                {
                    string companyAddress = DBClass.getField("select Company_Address from Sys_Companys where COmpany_ID = " + AppConfig.Company_ID + "").ToString();
                    rd.SetParameterValue("Address", companyAddress);
                }
            }
            else if (reportName == "PrintPatientCard")
            {
                if (Request.QueryString["MrNo"] != null)
                {

                    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                    reportPath += "Patients/rptPatient_Card.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@MR_No", Request.QueryString["MrNo"]);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("CompanyLogo", logoPath);
                    rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
                }
            }
            else if (reportName == "PrintPatientBackCard")
            {
                if (Request.QueryString["MrNo"] != null)
                {

                    reportPath += "Patients/rptPatientCard_Back.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@MR_No", Request.QueryString["MrNo"]);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));

                }
            }
            else if (reportName == "OPD_Patient_Print")
            {
                if (Request.QueryString["OPD_ID"] != null)
                {
                    var OPDID = Request.QueryString["OPD_ID"].ToString();
                    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                    var address = DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + "");

                    reportPath += "Patients/rpt_OPD_Patient_Print.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@OPD_ID", OPDID);
                    try
                    {
                        rd.SetParameterValue("@OPD_ID", OPDID, rd.Subreports[0].Name.ToString());
                        rd.SetParameterValue("CompanyName", AppConfig.Company_Name, rd.Subreports[0].Name.ToString());
                        rd.SetParameterValue("CompanyLogo", logoPath, rd.Subreports[0].Name.ToString());
                        rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""), rd.Subreports[0].Name.ToString());
                    }
                    catch
                    {
                        // Subreport parameter doesn't exist on this report variant - ignore silently
                    }
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("CompanyLogo", logoPath);
                    rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
                }
            }
            else if (reportName == "Emergency_Patient_Print")
            {
                var emer_id = Request.QueryString["Emergency_Id"].ToString();
                var user_id = AppConfig.UserID;
                var userName = DBClass.getField($"SELECT dbo.getUserName('{user_id}')");
                var address = DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + "");
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                reportPath += "Emergency/rpt_Emergency_Patient_Reg_Print.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("@Emergency_Id", emer_id);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("UserName", userName);
                rd.SetParameterValue("Address", address);

            }
            else if (reportName == "Emergency_Patient_Print_LTR")
            {
                var emer_id = Request.QueryString["Emergency_Id"].ToString();
                var user_id = AppConfig.UserID;
                var userName = DBClass.getField($"SELECT dbo.getUserName('{user_id}')");
                var address = DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + "");
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                reportPath += "Emergency/rptEmergencyBasePrintHalf.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("@Emergency_Id", emer_id);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("UserName", userName);
                rd.SetParameterValue("Address", address);

                try
                {
                    string sql = $@"
        SELECT ISNULL(rp.mr_no_sequence, '') AS mr_no_sequence,
               ISNULL(rp.Full_Name, '') AS Full_Name,
               ISNULL(CONVERT(VARCHAR, rp.Age_years), '') AS Age_years,
               ISNULL(rp.Gender, '') AS Gender
        FROM emergency em 
        JOIN Reg_patient rp ON em.Reg_PatId = rp.pat_id
        WHERE em.Emer_id = {emer_id}";

                    DataTable patientData = DBClass.getDataTable(sql);

                    if (patientData.Rows.Count > 0)
                    {
                        string qrContent = $"MR:{patientData.Rows[0]["mr_no_sequence"]}|Name:{patientData.Rows[0]["Full_Name"]}|Age:{patientData.Rows[0]["Age_years"]}|Gender:{patientData.Rows[0]["Gender"]}";

                        // Save to temp file instead of passing bytes
                        string tempQrPath = Path.Combine(Path.GetTempPath(), $"QR_{emer_id}_{Guid.NewGuid()}.png");

                        using (QRCodeGenerator qrGenerator = new QRCodeGenerator())
                        {
                            QRCodeData qrCodeData = qrGenerator.CreateQrCode(qrContent, QRCodeGenerator.ECCLevel.Q);
                            using (PngByteQRCode qrCodeImage = new PngByteQRCode(qrCodeData))
                            {
                                byte[] qrBytes = qrCodeImage.GetGraphic(10);
                                File.WriteAllBytes(tempQrPath, qrBytes);
                            }
                        }

                        // Pass FILE PATH as string parameter
                        rd.SetParameterValue("QRImagePath", tempQrPath);
                    }
                    else
                    {
                        rd.SetParameterValue("QRImagePath", "");
                    }
                }
                catch (Exception ex)
                {
                    rd.SetParameterValue("QRImagePath", "");
                }
            }
            else if (reportName == "OPD_Patient_Print_Slip")
            {
                if (Request.QueryString["OPD_ID"] != null)
                {
                    var OPD_ID = Request.QueryString["OPD_ID"].ToString();
                    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                    reportPath += "Patients/rpt_OPD_Patient_Print_Slip.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@OPD_ID", OPD_ID);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("CompanyLogo", logoPath);
                    rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));

                    try
                    {
                        string sql = $@"
            SELECT ISNULL(rp.mr_no_sequence, '') AS mr_no_sequence,
                   ISNULL(rp.Full_Name, '') AS Full_Name,
                   ISNULL(CONVERT(VARCHAR, rp.Age_years), '') AS Age_years,
                   ISNULL(rp.Gender, '') AS Gender
            FROM Reg_patient rp
            JOIN patients ip ON ip.reg_patid = rp.pat_id
            WHERE ip.patient_id = {OPD_ID}";

                        DataTable patientData = DBClass.getDataTable(sql);

                        if (patientData.Rows.Count > 0)
                        {
                            string qrContent = $"MR:{patientData.Rows[0]["mr_no_sequence"]}|Name:{patientData.Rows[0]["Full_Name"]}|Age:{patientData.Rows[0]["Age_years"]}|Gender:{patientData.Rows[0]["Gender"]}";

                            // Save to temp file instead of passing bytes
                            string tempQrPath = Path.Combine(Path.GetTempPath(), $"QR_{OPD_ID}_{Guid.NewGuid()}.png");

                            using (QRCodeGenerator qrGenerator = new QRCodeGenerator())
                            {
                                QRCodeData qrCodeData = qrGenerator.CreateQrCode(qrContent, QRCodeGenerator.ECCLevel.Q);
                                using (PngByteQRCode qrCodeImage = new PngByteQRCode(qrCodeData))
                                {
                                    byte[] qrBytes = qrCodeImage.GetGraphic(10);
                                    File.WriteAllBytes(tempQrPath, qrBytes);
                                }
                            }

                            // Pass FILE PATH as string parameter
                            rd.SetParameterValue("QRImagePath", tempQrPath);
                        }
                        else
                        {
                            rd.SetParameterValue("QRImagePath", "");
                        }
                    }
                    catch (Exception ex)
                    {
                        rd.SetParameterValue("QRImagePath", "");
                    }

                }
            }
            else if (reportName == "PrinRegtPatientCard")
            {

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                reportPath += "Patients/rptRegistration_Patient_Card.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("@pat_id", Request.QueryString["Reg_id"]);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));

            }
            else if (reportName == "PrintRegPatientBackCard")
            {


                reportPath += "Patients/rptRegistrationPatientCard_Back.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("@pat_id", Request.QueryString["Reg_id"]);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));


            }
            else if (reportName == "OPDForm")
            {
                if (Request.QueryString["OPD_ID"] != null)
                {

                    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                    reportPath += "Patients/rptOutPatient.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@patient_ID", Request.QueryString["OPD_ID"]);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("CompanyLogo", logoPath);
                    rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
                }
            }

            else if (reportName == "consent_slip")
            {
                string inPatientID = Request.QueryString["In_Patient_ID"].ToString();

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                reportPath += "Patients/rptconsent.rpt";
                rd.Load(reportPath);

                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("@Inp_patientID", inPatientID);

            }
            else if (reportName == "OutPatient")
            {

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string out_Patient_ID = Request.QueryString["outPatientID"].ToString();
                reportPath += "Patients/rptOutpatientDetails.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("@outPatient", Convert.ToInt32(out_Patient_ID));
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("@outPatient", Convert.ToInt32(out_Patient_ID), rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@outPatient", Convert.ToInt32(out_Patient_ID), rd.Subreports[1].Name.ToString());
                rd.SetParameterValue("@outPatient", Convert.ToInt32(out_Patient_ID), rd.Subreports[2].Name.ToString());
                rd.SetParameterValue("@outPatient", Convert.ToInt32(out_Patient_ID), rd.Subreports[3].Name.ToString());
                rd.SetParameterValue("@outPatient", Convert.ToInt32(out_Patient_ID), rd.Subreports[4].Name.ToString());
                rd.SetParameterValue("@outPatient", Convert.ToInt32(out_Patient_ID), rd.Subreports[5].Name.ToString());
            }
            else if (reportName == "Reg_Patient_Print")
            {
                if (Request.QueryString["Patient_ID"] != null)
                {


                    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                    reportPath += "Patients/rptReg_Patient_Print.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@pat_Id", Request.QueryString["Patient_ID"]);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("CompanyLogo", logoPath);
                }
            }
            else if (reportName == "TotalIncome")
            {
                reportPath += "TransactionalDetails/rptTotal_Income.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;

                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string sqlStartDateTime = Convert.ToDateTime(StartDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string sqlEndDateTime = Convert.ToDateTime(EndDateTime).ToString("yyyy-MM-dd HH:mm:ss");


                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Address", companyAddress);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@StDate", sqlStartDateTime);
                rd.SetParameterValue("@endDate", sqlEndDateTime);

            }

            else if (reportName == "Lab_Log_Report")
            {
                reportPath += "LabRadiology/rptlab_log_report.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;

                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string sqlStartDateTime = Convert.ToDateTime(StartDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string sqlEndDateTime = Convert.ToDateTime(EndDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string Category = Convert.ToString(Request.QueryString["Category"]);
                string Test_Departement = Convert.ToString(Request.QueryString["Test_Departement"]);
                string Operator = Convert.ToString(Request.QueryString["Operator"]);
                string BillingDoctor = Convert.ToString(Request.QueryString["BillingDoctor"]);
                string Acknowledge_By = Convert.ToString(Request.QueryString["Acknowledged_By"]);
                string Prelim_By = Convert.ToString(Request.QueryString["Prelim_BY"]);
                string Final_Sign_By = Convert.ToString(Request.QueryString["Final_Sign_By"]);
                string Referring_Consultant = Convert.ToString(Request.QueryString["Referring_Consultant"]);
                string PerformingDoctor = Convert.ToString(Request.QueryString["PerformingDoctor"]);

                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Address", companyAddress);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@stDate", sqlStartDateTime);
                rd.SetParameterValue("@endDate", sqlEndDateTime);
                rd.SetParameterValue("@Category", Category);
                rd.SetParameterValue("@Test_Departement", Test_Departement);
                rd.SetParameterValue("@Operator", Operator);
                rd.SetParameterValue("@BillingDoctor", BillingDoctor);
                rd.SetParameterValue("@Acknowledge_By", Acknowledge_By);
                rd.SetParameterValue("@Prelim_By", Prelim_By);
                rd.SetParameterValue("@Final_Sign_By", Final_Sign_By);
                rd.SetParameterValue("@Referring_Consultant", Referring_Consultant);
                rd.SetParameterValue("@PerformingDoctor", PerformingDoctor);
                rd.SetParameterValue("CompanyLogo", logoPath);

            }

            else if (reportName == "Student_Fee_Details_Report")
            {
                reportPath += "Student/rpt_Student_Fee_Details.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;

                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string sqlStartDateTime = Convert.ToDateTime(StartDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string sqlEndDateTime = Convert.ToDateTime(EndDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string Roll_No = Convert.ToString(Request.QueryString["Roll_No"]);

                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Address", companyAddress);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@Stdate", sqlStartDateTime);
                rd.SetParameterValue("@enDate", sqlEndDateTime);
                rd.SetParameterValue("@Roll_No", Roll_No);
                rd.SetParameterValue("CompanyLogo", logoPath);

            }
            else if (reportName == "Student_Fee_Details_Class_Report")
            {
                reportPath += "Student/rpt_Student_Class_Wise_Fee_Details.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;

                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string sqlStartDateTime = Convert.ToDateTime(StartDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string sqlEndDateTime = Convert.ToDateTime(EndDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string Class_No = Convert.ToString(Request.QueryString["Class_No"]);

                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Address", companyAddress);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@Stdate", sqlStartDateTime);
                rd.SetParameterValue("@enDate", sqlEndDateTime);
                rd.SetParameterValue("@Class_No", Class_No);
                rd.SetParameterValue("CompanyLogo", logoPath);

            }
            else if (reportName == "Student_Fee_Details_Session_Report")
            {
                reportPath += "Student/rpt_Student_Session_Wise_Fee_Details.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;

                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string sqlStartDateTime = Convert.ToDateTime(StartDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string sqlEndDateTime = Convert.ToDateTime(EndDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string Session = Convert.ToString(Request.QueryString["Session"]);

                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Address", companyAddress);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@Stdate", sqlStartDateTime);
                rd.SetParameterValue("@enDate", sqlEndDateTime);
                rd.SetParameterValue("@Session", Session);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "Student_Receipt_Details_Report_Received")
            {
                reportPath += "Student/rpt_Student_Wise_Receipt_Details_RECI.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;

                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string sqlStartDateTime = Convert.ToDateTime(StartDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string sqlEndDateTime = Convert.ToDateTime(EndDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string Roll_No = Convert.ToString(Request.QueryString["Roll_No"]);

                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Address", companyAddress);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@Stdate", sqlStartDateTime);
                rd.SetParameterValue("@enDate", sqlEndDateTime);
                rd.SetParameterValue("@Roll_No", Roll_No);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "Student_Receipt_Details_Report_Balance")
            {
                reportPath += "Student/rpt_Student_Wise_Receipt_Details_Bal.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;

                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string sqlStartDateTime = Convert.ToDateTime(StartDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string sqlEndDateTime = Convert.ToDateTime(EndDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string Roll_No = Convert.ToString(Request.QueryString["Roll_No"]);

                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Address", companyAddress);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@Stdate", sqlStartDateTime);
                rd.SetParameterValue("@enDate", sqlEndDateTime);
                rd.SetParameterValue("@Roll_No", Roll_No);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "Student_Receipt_Class_Details_Report_Received")
            {
                reportPath += "Student/rpt_Student_Wise__Class_Receipt_Details_Received.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;

                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string sqlStartDateTime = Convert.ToDateTime(StartDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string sqlEndDateTime = Convert.ToDateTime(EndDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string Class_No = Convert.ToString(Request.QueryString["Class_No"]);

                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Address", companyAddress);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@Stdate", sqlStartDateTime);
                rd.SetParameterValue("@enDate", sqlEndDateTime);
                rd.SetParameterValue("@Class_No", Class_No);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "Student_Receipt_Class_Details_Report_Balance")
            {
                reportPath += "Student/rpt_Student_Wise__Class_Receipt_Details_Bal.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;

                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string sqlStartDateTime = Convert.ToDateTime(StartDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string sqlEndDateTime = Convert.ToDateTime(EndDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string Class_No = Convert.ToString(Request.QueryString["Class_No"]);

                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Address", companyAddress);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@Stdate", sqlStartDateTime);
                rd.SetParameterValue("@enDate", sqlEndDateTime);
                rd.SetParameterValue("@Class_No", Class_No);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "Student_Receipt_Session_Details_Report_Received")
            {
                reportPath += "Student/rpt_Student_Wise__Session_Receipt_Details_Received.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;

                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string sqlStartDateTime = Convert.ToDateTime(StartDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string sqlEndDateTime = Convert.ToDateTime(EndDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string Session = Convert.ToString(Request.QueryString["Session"]);

                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Address", companyAddress);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@Stdate", sqlStartDateTime);
                rd.SetParameterValue("@enDate", sqlEndDateTime);
                rd.SetParameterValue("@Session", Session);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "Student_Receipt_Session_Details_Report_Balance")
            {
                reportPath += "Student/rpt_Student_Wise__Session_Receipt_Details_Bal.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;

                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string sqlStartDateTime = Convert.ToDateTime(StartDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string sqlEndDateTime = Convert.ToDateTime(EndDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string Session = Convert.ToString(Request.QueryString["Session"]);

                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Address", companyAddress);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@Stdate", sqlStartDateTime);
                rd.SetParameterValue("@enDate", sqlEndDateTime);
                rd.SetParameterValue("@Session", Session);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "Pharmacy_Profit_and_Loss_Report")
            {
                if (Request.QueryString["StartDateTime"] != null && Request.QueryString["EndDateTime"] != null)
                {
                    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                    reportPath += "Pharmacy/rptPharmacyProfitandLoss.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;

                    string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                    string stDate = Request.QueryString["StartDateTime"].ToString();
                    string endDate = Request.QueryString["EndDateTime"].ToString();
                    var edate = Convert.ToDateTime(endDate);
                    var newEnddate = new DateTime(edate.Year, edate.Month, edate.Day, edate.Hour, edate.Minute, 59);

                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    //rd.SetParameterValue("Address", companyAddress);
                    rd.SetParameterValue("ReportTitle", reportTitle);
                    rd.SetParameterValue("@StartDate", stDate);
                    rd.SetParameterValue("@endDate", newEnddate);
                    rd.SetParameterValue("CompanyLogo", logoPath);
                    rd.SetParameterValue("@Warehouse", Request.QueryString["WareHouse"]);
                }
            }

            else if (reportName == "Appointment_Patient_Print")
            {
                if (Request.QueryString["appointmentId"] != null)
                {
                    var appoitnment = Request.QueryString["appointmentId"];
                    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                    reportPath += "Patients/rptAppointment_Patient_Print.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@appointment_Id", appoitnment);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("CompanyLogo", logoPath);
                    //rd.SetParameterValue("Title", reportTitle);
                }
            }
            else if (reportName == "AllCashReport")
            {
                try
                {
                    string DateFormate = "yyyy-MM-dd";
                    string DateTimeFormate = "yyyy-MM-dd hh:mm tt";
                    bool dateOnly = false;
                    string sdateTime = Convert.ToDateTime(Request.QueryString["sDate"].ToString()).ToString(DateFormate);
                    string CurrentUserID = AppConfig.UserID.ToString();
                    sdateTime += " " + Regex.Replace(Request.QueryString["STime"].ToString(), @"\s+", "");
                    if (Request.QueryString["STime"].ToString() == "")
                    {
                        dateOnly = true;
                    }
                    if (!dateOnly)
                    {
                        sdateTime = Convert.ToDateTime(sdateTime).ToString(DateTimeFormate);
                    }
                    string edateTime = Convert.ToDateTime(Request.QueryString["eDate"].ToString()).ToString(DateFormate);
                    edateTime += " " + Regex.Replace(Request.QueryString["ETime"].ToString(), @"\s+", "");
                    if (!dateOnly)
                    {
                        edateTime = Convert.ToDateTime(edateTime).ToString(DateTimeFormate);
                    }

                    var ComapnyPhone = DBClass.getField("select Company_Phone1 from Sys_Companys where Company_ID = " + AppConfig.Company_ID + "");
                    var ComapnyEmail = DBClass.getField("select Company_Email from Sys_Companys where Company_ID = " + AppConfig.Company_ID + "");
                    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                    reportPath += "Patients/rptAllCashReport.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("CompanyLogo", logoPath);
                    rd.SetParameterValue("ComapnyPhone", ComapnyPhone);
                    rd.SetParameterValue("ComapnyEmail", ComapnyEmail);
                    rd.SetParameterValue("@sDateTime", sdateTime);
                    rd.SetParameterValue("@endDateTime", edateTime);
                }
                catch (Exception ex)
                {
                    throw;
                }
            }
            else if (reportName == "DoctorWisePatients")
            {
                try
                {
                    string DateFormate = "yyyy-MM-dd";
                    //string DateTimeFormate = "yyyy-MM-dd hh:mm tt";
                    //string AllPatientsRecords = Request.QueryString["AllPatientsRecords"].ToString();
                    string DateTimeFormate = "yyyy-MM-dd HH:mm:ss";
                    int AllPatientsRecords;
                    string Shift_Id = Request.QueryString["Shift"];

                    if (Request.QueryString["AllPatientsRecords"] == "false")
                    {
                        AllPatientsRecords = 0;
                    }
                    else
                    {
                        AllPatientsRecords = 1;
                    }
                    string CurrentUserID = AppConfig.UserID.ToString();
                    string CurrentUserName = DBClass.getField("select username from aspnet_users where userid='" + AppConfig.UserID + "'").ToString();
                    int dateOnly = 0;
                    string sdateTime = Convert.ToDateTime(Request.QueryString["sDate"].ToString()).ToString(DateFormate);
                    sdateTime += " " + Regex.Replace(Request.QueryString["STime"].ToString(), @"\s+", "");
                    if (Request.QueryString["STime"].ToString() == "")
                    {
                        dateOnly = 1;
                    }
                    if (dateOnly == 0)
                    {
                        sdateTime = Convert.ToDateTime(sdateTime).ToString(DateTimeFormate);
                    }
                    string edateTime = Convert.ToDateTime(Request.QueryString["eDate"].ToString()).ToString(DateFormate);
                    edateTime += " " + Regex.Replace(Request.QueryString["ETime"].ToString(), @"\s+", "");
                    if (dateOnly == 0)
                    {
                        edateTime = Convert.ToDateTime(edateTime).ToString(DateTimeFormate);
                    }
                    int deptID = Convert.ToInt32(Request.QueryString["DepartmentID"]);
                    string PatType = Request.QueryString["PatientType"].ToString();
                    string Operator = Convert.ToString(Request.QueryString["Operator"]);
                    string STIME = Request.QueryString["STime"].ToString();
                    string ETIME = Request.QueryString["ETime"].ToString();
                    bool summary = Convert.ToBoolean(Request.QueryString["Summary"]);
                    string doctorID = Request.QueryString["DoctorID"].ToString();
                    //bool date_Only_Boolean_converted = Convert.ToBoolean(dateOnly);
                    bool AllPatientsRecords_Boolean_Converted = Convert.ToBoolean(AllPatientsRecords);
                    bool summary_Boolean_Converted = Convert.ToBoolean(summary);


                    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                    reportPath += "Patients/rptDoctorDetails.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("@sDate", sdateTime);
                    rd.SetParameterValue("@eDate", edateTime);
                    rd.SetParameterValue("@DepartmentID", deptID);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("@PatientType", PatType);
                    rd.SetParameterValue("@DateOnly", dateOnly);
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("Summary", summary);
                    rd.SetParameterValue("@DoctorID", doctorID);
                    rd.SetParameterValue("@UserID", CurrentUserID);
                    rd.SetParameterValue("@AllPatientsRecords", AllPatientsRecords_Boolean_Converted);
                    rd.SetParameterValue("@Operator", Operator);
                    rd.SetParameterValue("STime", STIME);
                    rd.SetParameterValue("ETime", ETIME);
                    rd.SetParameterValue("CompanyLogo", logoPath);
                    rd.SetParameterValue("@Shift_Id", Shift_Id);

                    //rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);


                }
                catch (Exception ex)
                {

                    throw;
                }
            }
            else if (reportName == "DeptWisePatients")
            {
                try
                {
                    string DateFormate = "yyyy-MM-dd";
                    //string DateTimeFormate = "yyyy-MM-dd hh:mm tt";
                    //string AllPatientsRecords = Request.QueryString["AllPatientsRecords"].ToString();
                    string DateTimeFormate = "yyyy-MM-dd HH:mm:ss";
                    int AllPatientsRecords;
                    string Shift_Id = Request.QueryString["Shift"];

                    if (Request.QueryString["AllPatientsRecords"] == "false")
                    {
                        AllPatientsRecords = 0;
                    }
                    else
                    {
                        AllPatientsRecords = 1;
                    }
                    string CurrentUserID = AppConfig.UserID.ToString();
                    string CurrentUserName = DBClass.getField("select username from aspnet_users where userid='" + AppConfig.UserID + "'").ToString();
                    int dateOnly = 0;
                    string sdateTime = Convert.ToDateTime(Request.QueryString["sDate"].ToString()).ToString(DateFormate);
                    sdateTime += " " + Regex.Replace(Request.QueryString["STime"].ToString(), @"\s+", "");
                    if (Request.QueryString["STime"].ToString() == "")
                    {
                        dateOnly = 1;
                    }
                    if (dateOnly == 0)
                    {
                        sdateTime = Convert.ToDateTime(sdateTime).ToString(DateTimeFormate);
                    }
                    string edateTime = Convert.ToDateTime(Request.QueryString["eDate"].ToString()).ToString(DateFormate);
                    edateTime += " " + Regex.Replace(Request.QueryString["ETime"].ToString(), @"\s+", "");
                    if (dateOnly == 0)
                    {
                        edateTime = Convert.ToDateTime(edateTime).ToString(DateTimeFormate);
                    }
                    int deptID = Convert.ToInt32(Request.QueryString["DepartmentID"]);
                    string PatType = Request.QueryString["PatientType"].ToString();
                    string Operator = Convert.ToString(Request.QueryString["Operator"]);
                    string STIME = Request.QueryString["STime"].ToString();
                    string ETIME = Request.QueryString["ETime"].ToString();
                    bool summary = Convert.ToBoolean(Request.QueryString["Summary"]);
                    string doctorID = Request.QueryString["DoctorID"].ToString();
                    //bool date_Only_Boolean_converted = Convert.ToBoolean(dateOnly);
                    bool AllPatientsRecords_Boolean_Converted = Convert.ToBoolean(AllPatientsRecords);
                    bool summary_Boolean_Converted = Convert.ToBoolean(summary);


                    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                    reportPath += "Patients/rptPatientsDetails.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("@sDate", sdateTime);
                    rd.SetParameterValue("@eDate", edateTime);
                    rd.SetParameterValue("@DepartmentID", deptID);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("@PatientType", PatType);
                    rd.SetParameterValue("@DateOnly", dateOnly);
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("Summary", summary);
                    rd.SetParameterValue("@DoctorID", doctorID);
                    rd.SetParameterValue("@UserID", CurrentUserID);
                    rd.SetParameterValue("@AllPatientsRecords", AllPatientsRecords_Boolean_Converted);
                    rd.SetParameterValue("@Operator", Operator);
                    rd.SetParameterValue("STime", STIME);
                    rd.SetParameterValue("ETime", ETIME);
                    rd.SetParameterValue("CompanyLogo", logoPath);
                    rd.SetParameterValue("@Shift_Id", Shift_Id);

                    //rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);


                }
                catch (Exception ex)
                {

                    throw;
                }
            }
            #endregion
            #region Billing Print
            else if (reportName == "PrintAdvanceReport")
            {

                reportPath += "Billings/rptPrintAdvanceReport.rpt";
                rd.Load(reportPath);
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");      // Added by 
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);         // Added by
                rd.SetParameterValue("CompanyLogo", logoPath);                       // Added by
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("@Adv_IDs", Request.QueryString["Adv_IDs"]);
            }
            else if (reportName == "PrintRefundReport")
            {
                var refundid = Request.QueryString["Refund_ID"].ToString();
                reportPath += "Billings/rptPrintRefundPrint.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("@Refund_IDs", refundid);
                try
                {
                    rd.SetParameterValue("@Refund_IDs", refundid, rd.Subreports[0].Name.ToString());
                }
                catch
                {
                    // Subreport parameter doesn't exist on this report variant - ignore silently
                }
            }
            else if (reportName == "PrinAllReceiptDetail")
            {
                try
                {
                    string CurrentUserID = AppConfig.UserName;
                    string PatientID = Request.QueryString["PatientID"].ToString();
                    reportPath += "Billings/TotalBillWiseReport.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("Summary", Convert.ToBoolean(Request.QueryString["Summary"]));
                    rd.SetParameterValue("@PatientID", PatientID);
                    rd.SetParameterValue("UserID", CurrentUserID);
                }
                catch (Exception ex)
                {

                    throw;
                }
            }
            #endregion
            #region Purchase
            else if (reportName == "VPDR")
            {

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string vendorName = Request.QueryString["Vendor"].ToString();
                string StatusType = Request.QueryString["Status"].ToString();
                string rptFileName = "Purchase/rptVendorDetails.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("@VendorId", vendorName);
                rd.SetParameterValue("@Active", StatusType);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "InvoiceAging")
            {
                string rptFileName = "Purchase/rptInvoice_Aging.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("@endDate", Convert.ToDateTime(Request.QueryString["sDate"]));
                rd.SetParameterValue("@VendorId", (Request.QueryString["VendorId"]).ToString());
            }
            else if (reportName == "ApAgingDetail")
            {

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string rptFileName = "Purchase/rptVendorAging.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("@EndDate", Convert.ToDateTime(Request.QueryString["sDate"]));
                rd.SetParameterValue("@VendorId", (Request.QueryString["VendorId"]).ToString());
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "ApAgingSummary")
            {

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string rptFileName = "Purchase/rptVendorAgingSummary.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("@EndDate", Convert.ToDateTime(Request.QueryString["sDate"]));
                rd.SetParameterValue("@VendorId", (Request.QueryString["VendorId"]).ToString());
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "Vendor_Balance")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                var Start_Date = Request.QueryString["startDate"];
                string RptTitle = Request.QueryString["ReportTitle"];

                if (Start_Date != null)
                {
                    reportPath += "Accounts/rptVendorBalance.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("ReportTitle", RptTitle);
                    rd.SetParameterValue("@sDateTime", Start_Date);
                    //rd.SetParameterValue("CompanyLogo", logoPath);
                }
            }
            else if (reportName == "VendorLedger")
            {

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string rptFileName = "Purchase/rptVendorLedger.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("@startDate", Convert.ToDateTime(Request.QueryString["sDate"]));
                rd.SetParameterValue("@endDate", Convert.ToDateTime(Request.QueryString["eDate"]));
                rd.SetParameterValue("@VendorId", (Request.QueryString["Vendor"]).ToString());
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "Vendor_Wise_Transaction_Detail")
            {
                string rptFileName = "Inventory/rptVendorWiseTransactionDetail.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("ReportTitle", reportTitle);
                rd.SetParameterValue("@StartDate", Convert.ToDateTime(Request.QueryString["sDate"]));
                rd.SetParameterValue("@EndDate", Convert.ToDateTime(Request.QueryString["eDate"]));
                rd.SetParameterValue("@VendorId", (Request.QueryString["Vendor"]).ToString());
            }
            else if (reportName == "Vendor_Ledger")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string rptFileName = "Inventory/rptVendorLedger2.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("ReportTitle", reportTitle);
                rd.SetParameterValue("@StartDate", Convert.ToDateTime(Request.QueryString["sDate"]));
                rd.SetParameterValue("@EndDate", Convert.ToDateTime(Request.QueryString["eDate"]));
                // rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("@vendor_Id", (Request.QueryString["Vendor_Id"]).ToString());
            }
            else if (reportName == "Vendor_Wise_Payment_Summary")
            {
                string rptFileName = "Inventory/rptVendorWisePaymentSummary.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("ReportTitle", reportTitle);
                rd.SetParameterValue("@StartDate", Convert.ToDateTime(Request.QueryString["sDate"]));
                rd.SetParameterValue("@EndDate", Convert.ToDateTime(Request.QueryString["eDate"]));
                rd.SetParameterValue("@VendorId", (Request.QueryString["Vendor"]).ToString());
            }
            else if (reportName == "Bonus_Medicine_Detail_Report")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string rptFileName = "Pharmacy/rptBonusMedicineDetailReport.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@StartDate", Convert.ToDateTime(Request.QueryString["sDate"]));
                rd.SetParameterValue("@EndDate", Convert.ToDateTime(Request.QueryString["eDate"]));
                rd.SetParameterValue("@VendorId", (Request.QueryString["Vendor"]).ToString());
                rd.SetParameterValue("@Warehouse", Request.QueryString["WareHouse"]);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "GRN_Report")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                var warehouse = Request.QueryString["WareHouse"].ToString();
                string rptFileName = "Pharmacy/rptGRN_Report.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@StartDate", Convert.ToDateTime(Request.QueryString["sDate"]));
                rd.SetParameterValue("@EndDate", Convert.ToDateTime(Request.QueryString["eDate"]));
                rd.SetParameterValue("@VendorId", (Request.QueryString["Vendor"]).ToString());
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("@warehouse", warehouse);
            }

            else if (reportName == "GRN_PO_Reconciliation_Report")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                var warehouse = Request.QueryString["WareHouse"].ToString();
                string rptFileName = "Pharmacy/rptGRNvsPO_Report.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@StartDate", Convert.ToDateTime(Request.QueryString["sDate"]));
                rd.SetParameterValue("@EndDate", Convert.ToDateTime(Request.QueryString["eDate"]));
                rd.SetParameterValue("@VendorId", (Request.QueryString["Vendor"]).ToString());
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("@warehouse", warehouse);
            }
            else if (reportName == "Inventory_Reconciliation_Report")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                var warehouse = Request.QueryString["WareHouse"].ToString();
                string rptFileName = "Inventory/rptInventory_Reconciliation_Report.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@StartDate", Convert.ToDateTime(Request.QueryString["sDate"]));
                rd.SetParameterValue("@EndDate", Convert.ToDateTime(Request.QueryString["eDate"]));
                rd.SetParameterValue("@VendorId", (Request.QueryString["Vendor"]).ToString());
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("@warehouse", warehouse);
            }
            else if (reportName == "Purchase_Order_Report")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                var warehouse = Request.QueryString["WareHouse"].ToString();
                var status = Request.QueryString["Status"].ToString();
                string rptFileName = "Inventory/rptPurchase_Order_Report.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@StartDate", Convert.ToDateTime(Request.QueryString["sDate"]));
                rd.SetParameterValue("@EndDate", Convert.ToDateTime(Request.QueryString["eDate"]));
                rd.SetParameterValue("@VendorId", (Request.QueryString["Vendor"]).ToString());
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("@warehouse", warehouse);
                rd.SetParameterValue("Status", status);
            }
            else if (reportName == "Payment_to_Supplier_Report")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string rptFileName = "Inventory/rptPayment_to_Supplier_Report.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@StartDate", Convert.ToDateTime(Request.QueryString["sDate"]));
                rd.SetParameterValue("@EndDate", Convert.ToDateTime(Request.QueryString["eDate"]));
                rd.SetParameterValue("@VendorId", (Request.QueryString["Vendor"]).ToString());
                rd.SetParameterValue("CompanyLogo", logoPath);

            }
            else if (reportName == "Purchase_Register_Report")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string rptFileName = "Inventory/rptPurchaseRegisterReport.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@StartDate", Convert.ToDateTime(Request.QueryString["sDate"]));
                rd.SetParameterValue("@EndDate", Convert.ToDateTime(Request.QueryString["eDate"]));
                rd.SetParameterValue("@VendorId", (Request.QueryString["Vendor"]).ToString());
                rd.SetParameterValue("CompanyLogo", logoPath);

            }
            else if (reportName == "Pending_Payment_Request_Report")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string rptFileName = "Inventory/rptPendingPurchaseRequest.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@StartDate", Convert.ToDateTime(Request.QueryString["sDate"]));
                rd.SetParameterValue("@EndDate", Convert.ToDateTime(Request.QueryString["eDate"]));
                rd.SetParameterValue("CompanyLogo", logoPath);

            }
            else if (reportName == "VendorPerson")
            {
                if (Request.QueryString["ID"] != null)
                {
                    reportPath += "Purchase/rptVendor_Person.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@VId", Convert.ToInt32(Request.QueryString["ID"]));
                }
            }
            else if (reportName == "PurchaseRequsitionList")
            {
                if (Request.QueryString["PRid"] != null)
                {
                    string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                    reportPath += "Purchase/rptPR_Print.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@PR_ID", Convert.ToInt32(Request.QueryString["PRid"]));
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", companyAddress);
                }
            }
            else if (reportName == "RequestForQuotationList")
            {
                if (Request.QueryString["RFQid"] != null)
                {
                    string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                    reportPath += "Purchase/rptRFQ_Print.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@RFQ_ID", Convert.ToInt32(Request.QueryString["RFQid"]));
                    rd.SetParameterValue("@vendorid", Convert.ToInt32(Request.QueryString["Venderid"]));
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", companyAddress);
                }
            }
            else if (reportName == "ComparativeStatementVendor")
            {
                if (Request.QueryString["CM_ID"] != null)
                {
                    string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                    reportPath += "Purchase/rptCSV_Print.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@CM_ID", Convert.ToInt32(Request.QueryString["CM_ID"]));
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", companyAddress);
                    rd.SetParameterValue("Title", Request.QueryString["ReportTitle"].ToString().Trim());
                }
            }
            else if (reportName == "PurchaseOrderList")
            {
                if (Request.QueryString["POid"] != null)
                {
                    string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                    reportPath += "Purchase/rptPO_Print.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@PO_ID", Convert.ToInt32(Request.QueryString["POid"]));
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", companyAddress);
                }
            }
            else if (reportName == "PurchaseOrderList2")
            {
                if (Request.QueryString["POid"] != null)
                {
                    string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                    reportPath += "Purchase/rptPO_Print_2.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@PO_ID", Convert.ToInt32(Request.QueryString["POid"]));
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", companyAddress);
                }
            }
            #endregion
            #region Pharmacy
            else if (reportName == "VendorWisePurchase")
            {

                if (Request.QueryString["VendorId"] != null)
                {

                    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                    string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                    reportPath += "Pharmacy/rptSupplierWisePurchase.rpt";

                    rd.Load(reportPath);
                    string VendorId = Request.QueryString["VendorId"].ToString();
                    string vendorType = Request.QueryString["VendorType"].ToString();
                    string Warehouse = Request.QueryString["Warehouse"].ToString();


                    string stDate = Request.QueryString["startDate"].ToString();

                    string endDate = Request.QueryString["endDate"].ToString();
                    rd.SetParameterValue("@VendorType", vendorType);

                    rd.SetParameterValue("@StartDate", stDate);
                    rd.SetParameterValue("@EndDate", endDate);
                    rd.SetParameterValue("CompanyLogo", logoPath);
                    rd.SetParameterValue("@VendorId", VendorId);
                    rd.SetParameterValue("@Warehouse", Warehouse);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    // rd.SetParameterValue("Address", companyAddress);
                }
            }
            else if (reportName == "VendorWisePurchaseSummary")
            {
                if (Request.QueryString["VendorId"] != null)
                {

                    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                    reportPath += "Pharmacy/rptSupplierWisePurchaseSummary.rpt";
                    rd.Load(reportPath);
                    string stDate = Request.QueryString["startDate"].ToString();
                    string endDate = Request.QueryString["endDate"].ToString();
                    string vendorType = Request.QueryString["VendorType"];
                    string VendorID = Request.QueryString["VendorId"];

                    rd.SetParameterValue("@VendorType", vendorType);

                    rd.SetParameterValue("@StartDate", stDate);
                    rd.SetParameterValue("@EndDate", endDate);
                    rd.SetParameterValue("@VendorId", VendorID);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("CompanyLogo", logoPath);
                    // rd.SetParameterValue("Address", companyAddress);
                }
            }
            else if (reportName == "PharmacyStock")
            {
                if (Request.QueryString["Stock"] != null)
                {
                    var stock = Request.QueryString["Stock"];
                    string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                    reportPath += "Pharmacy/rptPharmacyStock.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@Stock", stock);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", companyAddress);
                }
            }
            else if (reportName == "Stock_Consumption_Details")
            {
                if (Request.QueryString["Stock"] != null)
                {
                    var stock = Request.QueryString["Stock"];
                    string stDate = Request.QueryString["startDate"].ToString();
                    string endDate = Request.QueryString["endDate"].ToString();
                    string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                    reportPath += "Pharmacy/rptStockConsumptionDetail.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@Stock", stock);
                    rd.SetParameterValue("@FromDate", stDate);
                    rd.SetParameterValue("@ToDate", endDate);
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", companyAddress);
                }
            }
            else if (reportName == "Overall_Stock_Consumption_Details")
            {
                if (Request.QueryString["Stock"] != null)
                {
                    var stock = Request.QueryString["Stock"];
                    string stDate = Request.QueryString["startDate"].ToString();
                    string endDate = Request.QueryString["endDate"].ToString();
                    string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                    reportPath += "Inventory/rptOverallStockConsumptionDetail.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@Stock", stock);
                    rd.SetParameterValue("@Warehouse", Request.QueryString["WareHouse"]);
                    rd.SetParameterValue("@FromDate", stDate);
                    rd.SetParameterValue("@ToDate", endDate);
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", companyAddress);
                }
            }
            else if (reportName == "Pharmacy_Stock_Consumption_Details")
            {
                if (Request.QueryString["Stock"] != null)
                {
                    var stock = Request.QueryString["Stock"];
                    string stDate = Request.QueryString["startDate"].ToString();
                    string endDate = Request.QueryString["endDate"].ToString();
                    string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                    reportPath += "Pharmacy/rptPharmacyStockConsumptionDetail.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@Stock", stock);
                    rd.SetParameterValue("@FromDate", stDate);
                    rd.SetParameterValue("@ToDate", endDate);
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", companyAddress);
                }
            }
            else if (reportName == "PharmacyStockBatchWise")
            {
                if (Request.QueryString["Stock"] != null)
                {
                    string warehouse = Request.QueryString["WareHouse"].ToString();
                    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                    var stock = Request.QueryString["Stock"];
                    //  string stDate = Request.QueryString["startDate"].ToString();
                    //  string endDate = Request.QueryString["endDate"].ToString();
                    string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                    reportPath += "Pharmacy/rptPharmacyStockBatchWise.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@Stock", stock);
                    //  rd.SetParameterValue("@FromDate", stDate);
                    //  rd.SetParameterValue("@ToDate", endDate);
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", companyAddress);
                    rd.SetParameterValue("@warehouse", warehouse);
                    rd.SetParameterValue("CompanyLogo", logoPath);
                }
            }
            else if (reportName == "PharmacySaleReport")
            {

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string rptFileName = "Pharmacy/rptSaleReport.rpt";
                //bool CheckSummary = Convert.ToBoolean(Request.QueryString["Summary"]);
                string CheckSummary = Request.QueryString["Summary"].ToString();
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                string ItemID = Request.QueryString["ItemID"].ToString();
                if (CheckSummary == "true")
                {
                    rptFileName = "Pharmacy/rptSaleReportSummary.rpt";
                    reportTitle = "Sale Summary Report from " + StartDateTime + " to " + EndDateTime;
                    reportPath += rptFileName;
                    rd.Load(reportPath);
                    rd.SetParameterValue("@FromDate", StartDateTime);
                    rd.SetParameterValue("@ToDate", EndDateTime);
                    rd.SetParameterValue("@Item_ID", ItemID);
                    rd.SetParameterValue("@Warehouse", Request.QueryString["WareHouse"]);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("@UserId", Request.QueryString["Operator"]);
                    rd.SetParameterValue("@FromDate", StartDateTime, rd.Subreports[0].Name.ToString());
                    rd.SetParameterValue("@ToDate", EndDateTime, rd.Subreports[0].Name.ToString());
                    rd.SetParameterValue("@UserId", Request.QueryString["Operator"], rd.Subreports[0].Name.ToString());
                    rd.SetParameterValue("@Warehouse", Request.QueryString["WareHouse"], rd.Subreports[0].Name.ToString());
                    rd.SetParameterValue("@Item_ID", ItemID, rd.Subreports[0].Name.ToString());
                    rd.SetParameterValue("CompanyLogo", logoPath);
                }
                else
                {
                    reportPath += rptFileName;
                    rd.Load(reportPath);
                    rd.SetParameterValue("@FromDate", StartDateTime);
                    rd.SetParameterValue("@ToDate", EndDateTime);
                    rd.SetParameterValue("@Item_ID", ItemID);
                    rd.SetParameterValue("@Warehouse", Request.QueryString["WareHouse"]);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("@UserId", Request.QueryString["Operator"]);
                    rd.SetParameterValue("@FromDate", StartDateTime, rd.Subreports[0].Name.ToString());
                    rd.SetParameterValue("@ToDate", EndDateTime, rd.Subreports[0].Name.ToString());
                    rd.SetParameterValue("@UserId", Request.QueryString["Operator"], rd.Subreports[0].Name.ToString());
                    rd.SetParameterValue("@Warehouse", Request.QueryString["WareHouse"], rd.Subreports[0].Name.ToString());
                    rd.SetParameterValue("@Item_ID", ItemID, rd.Subreports[0].Name.ToString());
                    rd.SetParameterValue("CompanyLogo", logoPath);
                    rd.Subreports[0].RecordSelectionFormula = "{spSaleReport;1.TotalAmount} < 0";
                }
            }
            else if (reportName == "PharmacySaleReport_PaymentWise")
            {

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string rptFileName = "Pharmacy/rptSaleReport_PaymentTypeWise.rpt";
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                string ItemID = Request.QueryString["ItemID"].ToString();
                string Payment_Type = Request.QueryString["Payment_Type"].ToString();
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("@FromDate", StartDateTime);
                rd.SetParameterValue("@ToDate", EndDateTime);
                rd.SetParameterValue("Payment_Type", Payment_Type);
                rd.SetParameterValue("@Item_ID", ItemID);
                rd.SetParameterValue("@Warehouse", Request.QueryString["WareHouse"]);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@UserId", Request.QueryString["Operator"]);
                rd.SetParameterValue("@FromDate", StartDateTime, rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@ToDate", EndDateTime, rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@UserId", Request.QueryString["Operator"], rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@Warehouse", Request.QueryString["WareHouse"], rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@Item_ID", ItemID, rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.Subreports[0].RecordSelectionFormula = "{spSaleReport;1.TotalAmount} < 0";
            }
            else if (reportName == "MER")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string ItemID = Request.QueryString["ItemID"].ToString();
                string vendorID = Request.QueryString["VendorId"].ToString();

                string rptFileName = "Pharmacy/rptMedicineExpiry.rpt";

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@startDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("@itemId", ItemID);
                rd.SetParameterValue("@Vendor", vendorID);
                rd.SetParameterValue("@Warehouse", Request.QueryString["WareHouse"]);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "CathLab_MER")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string ItemID = Request.QueryString["ItemID"].ToString();
                string vendorID = Request.QueryString["VendorId"].ToString();

                string rptFileName = "Pharmacy/rptCathLab_MedicineExpiry.rpt";

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@startDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("@itemId", ItemID);
                rd.SetParameterValue("@Vendor", vendorID);
                rd.SetParameterValue("@Warehouse", Request.QueryString["WareHouse"]);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "StockCategoryValuationReport")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string ItemID = Request.QueryString["ItemID"].ToString();
                string vendorID = Request.QueryString["VendorId"].ToString();
                string itemgroup = Request.QueryString["itemgroup"].ToString();

                string rptFileName = "Pharmacy/StockCategoryValuationReport.rpt";

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@startDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("@itemId", ItemID);
                rd.SetParameterValue("@Vendor", vendorID);
                rd.SetParameterValue("@ItemGroup", itemgroup);
                rd.SetParameterValue("@Warehouse", Request.QueryString["WareHouse"]);
                rd.SetParameterValue("CompanyLogo", logoPath);

            }
            else if (reportName == "Inward_Gate_Pass_Report")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string ItemID = Request.QueryString["ItemID"].ToString();
                string vendorID = Request.QueryString["VendorId"].ToString();

                string rptFileName = "Inventory/rptInward_Gate_Pass_Report.rpt";

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@startDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("@itemId", ItemID);
                rd.SetParameterValue("@Vendor", vendorID);
                rd.SetParameterValue("@Warehouse", Request.QueryString["WareHouse"]);
                rd.SetParameterValue("CompanyLogo", logoPath);

            }
            else if (reportName == "Asset_Register_Report")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string Asset_Name = Request.QueryString["AssetName"].ToString();
                string Category = Request.QueryString["Category"].ToString();
                string Department = Request.QueryString["Department"].ToString();

                string rptFileName = "Fixed-Assets/rptAssetRegisterReport.rpt";

                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@startDate", Convert.ToDateTime(Request.QueryString["sDate"]));
                rd.SetParameterValue("@endDate", Convert.ToDateTime(Request.QueryString["eDate"]));

                rd.SetParameterValue("@AssetName", Asset_Name);
                rd.SetParameterValue("@Category", Category);
                rd.SetParameterValue("@Department", Department);
                rd.SetParameterValue("CompanyLogo", logoPath);

            }
            else if (reportName == "Asset_Ageing_Report")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string Asset_Name = Request.QueryString["AssetName"].ToString();
                string Category = Request.QueryString["Category"].ToString();
                string status = Request.QueryString["Status"].ToString();

                string rptFileName = "Fixed-Assets/rptAssetAgeingReport.rpt";

                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@startDate", Convert.ToDateTime(Request.QueryString["sDate"]));
                rd.SetParameterValue("@endDate", Convert.ToDateTime(Request.QueryString["eDate"]));

                rd.SetParameterValue("@AssetName", Asset_Name);
                rd.SetParameterValue("@Category", Category);
                rd.SetParameterValue("Status", status);
                rd.SetParameterValue("CompanyLogo", logoPath);

            }
            else if (reportName == "Asset_Depreciation_Report")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string Asset_Name = Request.QueryString["AssetName"].ToString();
                string Category = Request.QueryString["Category"].ToString();
                string rptFileName = "Fixed-Assets/rptAssetDepreciationReport.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@startDate", Convert.ToDateTime(Request.QueryString["sDate"]));
                rd.SetParameterValue("@endDate", Convert.ToDateTime(Request.QueryString["eDate"]));
                rd.SetParameterValue("@AssetName", Asset_Name);
                rd.SetParameterValue("@Category", Category);
                rd.SetParameterValue("CompanyLogo", logoPath);

            }
            else if (reportName == "Asset_Acquisition_Report")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string Asset_Name = Request.QueryString["AssetName"].ToString();
                string Category = Request.QueryString["Category"].ToString();
                string rptFileName = "Fixed-Assets/rptAssetAcquisitionReport.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@startDate", Convert.ToDateTime(Request.QueryString["sDate"]));
                rd.SetParameterValue("@endDate", Convert.ToDateTime(Request.QueryString["eDate"]));
                rd.SetParameterValue("@AssetName", Asset_Name);
                rd.SetParameterValue("@Category", Category);
                rd.SetParameterValue("CompanyLogo", logoPath);

            }
            else if (reportName == "Stock_Transfer_Report")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string ItemID = Request.QueryString["ItemID"].ToString();
                string Operator = Request.QueryString["Operator"].ToString();
                string FromWarehouse = Request.QueryString["FromWarehouse"].ToString();
                string ToWarehouse = Request.QueryString["ToWarehouse"].ToString();


                string rptFileName = "Inventory/rptStockTransferReport.rpt";

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@startDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("@itemId", ItemID);
                rd.SetParameterValue("@Operator", Operator);
                rd.SetParameterValue("@FromWarehouse", FromWarehouse);
                rd.SetParameterValue("@ToWarehouse", ToWarehouse);
                rd.SetParameterValue("CompanyLogo", logoPath);

            }
            else if (reportName == "PurchaseReturnReport")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string ItemID = Request.QueryString["ItemID"].ToString();
                string vendorID = Request.QueryString["VendorId"].ToString();

                string rptFileName = "Inventory/rptPurchaseReturnReport.rpt";

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@startDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("@itemId", ItemID);
                rd.SetParameterValue("@Vendor", vendorID);
                rd.SetParameterValue("@Warehouse", Request.QueryString["WareHouse"]);
                rd.SetParameterValue("CompanyLogo", logoPath);

            }

            #endregion
            #region Transaction Details
            else if (reportName == "Lab_Test_Investigation")
            {
                try
                {
                    string startTime = Request.QueryString["STime"].ToString();
                    string ENdtTime = Request.QueryString["ETime"].ToString();
                    string CurrentUserName = DBClass.getField("select username from aspnet_users where userid='" + AppConfig.UserID + "'").ToString();
                    string DateFormate = "yyyy-MM-dd";
                    string DateTimeFormate = "yyyy-MM-dd hh:mm tt";
                    bool dateOnly = false;
                    string sdateTime = Convert.ToDateTime(Request.QueryString["sDate"].ToString()).ToString(DateFormate);
                    string CurrentUserID = AppConfig.UserID.ToString();
                    sdateTime += " " + Regex.Replace(Request.QueryString["STime"].ToString(), @"\s+", "");
                    if (Request.QueryString["STime"].ToString() == "")
                    {
                        dateOnly = true;
                    }
                    if (!dateOnly)
                    {
                        sdateTime = Convert.ToDateTime(sdateTime).ToString(DateTimeFormate);
                    }
                    string edateTime = Convert.ToDateTime(Request.QueryString["eDate"].ToString()).ToString(DateFormate);
                    edateTime += " " + Regex.Replace(Request.QueryString["ETime"].ToString(), @"\s+", "");
                    if (!dateOnly)
                    {
                        edateTime = Convert.ToDateTime(edateTime).ToString(DateTimeFormate);
                    }
                    string DeptID = Request.QueryString["DepartmentID"].ToString();
                    // string TestCatagory = Request.QueryString["TestCatagory"].ToString();
                    string TransType = Request.QueryString["Result"].ToString();
                    reportPath += "TransactionalDetails/rpt_lab_Result_Investigation.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@DepetID", DeptID);
                    //rd.SetParameterValue("@catagory", TestCatagory);
                    rd.SetParameterValue("@sDateTime", sdateTime);
                    rd.SetParameterValue("@endDateTime", edateTime);
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                }
                catch (Exception ex)
                {
                    throw;
                }
            }
            //inserting la
            else if (reportName == "LabCashCollection")
            {
                string rptFileName = "TransactionalDetails/rptLabCashCollection.rpt";
                //if (Convert.ToBoolean(Request.QueryString["Summary"].ToString()))
                //    rptFileName = "TransactionalDetails/rptLabCashCollection _Summary.rpt";

                reportPath += rptFileName;
                rd.Load(reportPath);

                string stDate = Request.QueryString["sDate"].ToString();
                string stTime = Request.QueryString["STime"].ToString();
                string endDate = Request.QueryString["eDate"].ToString();
                string endTime = Request.QueryString["ETime"].ToString();
                string Operator = Request.QueryString["Operator"].ToString();
                string PatType = Request.QueryString["Patient_Type"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);
                rd.SetParameterValue("@Department", Request.QueryString["Department"]);
                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", "Lab Cash Collection");
                rd.SetParameterValue("@Operator", Operator);
                rd.SetParameterValue("@Patient_Type", PatType);
            }
            else if (reportName == "Service_Wise_Summary_Report")
            {
                string rptFileName = "Patients/rptServiceWiseSummary.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);
                string stDate = Request.QueryString["sDate"].ToString();
                string stTime = Request.QueryString["STime"].ToString();
                string endDate = Request.QueryString["eDate"].ToString();
                string endTime = Request.QueryString["ETime"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                string departmentID = Request.QueryString["Department"].ToString();
                if (departmentID == "All")
                {
                    departmentID = "0";
                }
                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);
                rd.SetParameterValue("@Department", departmentID);
                rd.SetParameterValue("@FromDate", parameterStDate);
                rd.SetParameterValue("@ToDate", parameterEndDate);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("ReportTitle", "Service Wise Summary");
            }
            else if (reportName == "Lab_Test_Investigation_Delay")
            {
                string rptFileName = "TransactionalDetails/rpt_lab_Result_Investigation_Delay.rpt";
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                reportPath += rptFileName;
                rd.Load(reportPath);

                string stDate = Request.QueryString["sDate"].ToString();
                string stTime = Request.QueryString["STime"].ToString();
                string endDate = Request.QueryString["eDate"].ToString();
                string endTime = Request.QueryString["ETime"].ToString();
                string Department = Request.QueryString["Department"].ToString();
                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                string companyPhone = DBClass.getField("select Company_Phone1 from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);
                rd.SetParameterValue("@Department", Request.QueryString["Department"]);
                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);

                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Address", companyAddress);
                rd.SetParameterValue("companyPhone", companyPhone);
            }



            else if (reportName == "Radiology_Investigation_Delay")
            {
                string rptFileName = "TransactionalDetails/rpt_Radiology_Investigation_Delay.rpt";
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                reportPath += rptFileName;
                rd.Load(reportPath);

                string stDate = Request.QueryString["sDate"].ToString();
                string stTime = Request.QueryString["STime"].ToString();
                string endDate = Request.QueryString["eDate"].ToString();
                string endTime = Request.QueryString["ETime"].ToString();
                string Department = Request.QueryString["Department"].ToString();
                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                string companyPhone = DBClass.getField("select Company_Phone1 from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);
                rd.SetParameterValue("@Department", Request.QueryString["Department"]);
                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);

                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Address", companyAddress);
                rd.SetParameterValue("companyPhone", companyPhone);
            }

            //replica of Lab cash Collection
            else if (reportName == "Receipt_Operator_Wise_Report")
            {


                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string rptFileName = "Billings/rptOperatorWise_Receipt_Report.rpt";
                string CheckSummary = Request.QueryString["Summary"].ToString();
                string CheckDetailSummary = Request.QueryString["AllPatientsRecords"].ToString();

                if (CheckSummary == "true")
                {
                    rptFileName = "Billings/rptOperatorWise_Receipt_Report_Summary.rpt";
                    reportTitle = "Operator Wise Billing Summary From " + Request.QueryString["sDate"].ToString() + "to" + Request.QueryString["eDate"].ToString();
                }
                if (CheckDetailSummary == "true")
                {
                    rptFileName = "Billings/rptOperatorWise_Receipt_Report_Summary_Detailed.rpt";
                    reportTitle = "Operator Wise Billing Summary From " + Request.QueryString["sDate"].ToString() + "to" + Request.QueryString["eDate"].ToString();
                }
                reportPath += rptFileName;
                rd.Load(reportPath);

                string stDate = Request.QueryString["sDate"].ToString();
                string stTime = Request.QueryString["STime"].ToString();
                string endDate = Request.QueryString["eDate"].ToString();
                string endTime = Request.QueryString["ETime"].ToString();
                string Operator = Request.QueryString["Operator"].ToString();
                string PatType = Request.QueryString["Patient_Type"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);
                rd.SetParameterValue("@Department", Request.QueryString["Department"]);
                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", "Operator Wise Billing");
                rd.SetParameterValue("@Operator", Operator);
                rd.SetParameterValue("@Patient_Type", PatType);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "Operator_Wise_Billing_Report")
            {


                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string rptFileName = "TransactionalDetails/rptOperatorWise_Bill_Report.rpt";
                string CheckSummary = Request.QueryString["Summary"].ToString();
                string CheckDetailSummary = Request.QueryString["AllPatientsRecords"].ToString();

                if (CheckSummary == "true")
                {
                    rptFileName = "TransactionalDetails/rptOperatorWise_Bill_Report_Summary.rpt";
                    reportTitle = "Operator Wise Billing Summary From " + Request.QueryString["sDate"].ToString() + "to" + Request.QueryString["eDate"].ToString();
                }
                if (CheckDetailSummary == "true")
                {
                    rptFileName = "TransactionalDetails/rptOperatorWise_Bill_Report_Summary_Detailed.rpt";
                    reportTitle = "Operator Wise Billing Summary From " + Request.QueryString["sDate"].ToString() + "to" + Request.QueryString["eDate"].ToString();
                }
                reportPath += rptFileName;
                rd.Load(reportPath);

                string stDate = Request.QueryString["sDate"].ToString();
                string stTime = Request.QueryString["STime"].ToString();
                string endDate = Request.QueryString["eDate"].ToString();
                string endTime = Request.QueryString["ETime"].ToString();
                string Operator = Request.QueryString["Operator"].ToString();
                string PatType = Request.QueryString["Patient_Type"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);
                rd.SetParameterValue("@Department", Request.QueryString["Department"]);
                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", "Operator Wise Billing");
                rd.SetParameterValue("@Operator", Operator);
                rd.SetParameterValue("@Patient_Type", PatType);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "StudentAttendanceList")
            {
                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                var Class = Request.QueryString["Class"];
                var Program = Request.QueryString["Program"];
                var Batch = Request.QueryString["Batch"];
                var Group = Request.QueryString["Group"];
                var Subject = Request.QueryString["Subject"];
                var SubSubject = Request.QueryString["SubSubject"];
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();


                reportPath += "Student/rptAttendanceDetails.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("@classs", Class);

                rd.SetParameterValue("@program", Program);
                rd.SetParameterValue("@batch", Batch);
                rd.SetParameterValue("@Group", Group);
                rd.SetParameterValue("@Subject", Subject);
                rd.SetParameterValue("@SubSubject", SubSubject);
                rd.SetParameterValue("@StartDate", StartDateTime);
                rd.SetParameterValue("@EndDate", EndDateTime);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Address", companyAddress);
            }
            else if (reportName == "SubjectWiseAttendance")
            {
                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                var Class = Request.QueryString["Class"];
                var Program = Request.QueryString["Program"];
                var Batch = Request.QueryString["Batch"];
                var Group = Request.QueryString["Group"];
                var Subject = Request.QueryString["Subject"];
                var SubSubject = Request.QueryString["SubSubject"];
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();


                reportPath += "Student/rptAttendanceSubjectWise.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("@classs", Class);

                rd.SetParameterValue("@program", Program);
                rd.SetParameterValue("@batch", Batch);
                rd.SetParameterValue("@Group", Group);
                rd.SetParameterValue("@Subject", Subject);
                rd.SetParameterValue("@SubSubject", SubSubject);
                rd.SetParameterValue("@StartDate", StartDateTime);
                rd.SetParameterValue("@EndDate", EndDateTime);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Address", companyAddress);
            }
            else if (reportName == "AttendancePercentage")
            {
                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                var Class = Request.QueryString["Class"];
                var Program = Request.QueryString["Program"];
                var Batch = Request.QueryString["Batch"];
                var Group = Request.QueryString["Group"];
                var Subject = Request.QueryString["Subject"];
                var SubSubject = Request.QueryString["SubSubject"];
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();


                reportPath += "Student/rptAttendancePercentage.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("@classs", Class);

                rd.SetParameterValue("@program", Program);
                rd.SetParameterValue("@batch", Batch);
                rd.SetParameterValue("@Group", Group);
                rd.SetParameterValue("@Subject", Subject);
                rd.SetParameterValue("@SubSubject", SubSubject);
                rd.SetParameterValue("@StartDate", StartDateTime);
                rd.SetParameterValue("@EndDate", EndDateTime);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Address", companyAddress);
            }
            else if (reportName == "StudentList")
            {


                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                var Class = Request.QueryString["Class"];
                var Isactive = Convert.ToBoolean(Request.QueryString["Isactive"]);
                var Noactive = Convert.ToBoolean(Request.QueryString["Noactive"]);
                var Program = Request.QueryString["Program"];
                var Batch = Request.QueryString["Batch"];
                var Group = Request.QueryString["Group"];
                var WholeClass = Convert.ToBoolean(Request.QueryString["WholeClass"]);

                bool? Active = null;

                if (Noactive == true)
                {
                    Active = false;
                }

                else if (Isactive == true)
                {
                    Active = true;
                }
                else
                {
                    Active = null;
                }


                reportPath += "Student/rptStudentList.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("@Class", Class);

                rd.SetParameterValue("@Program", Program);
                rd.SetParameterValue("@Group", Group);
                rd.SetParameterValue("@Batch", Batch);
                rd.SetParameterValue("@WholeClass", WholeClass);

                rd.SetParameterValue("@Is_Active", Active);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Address", companyAddress);
            }
            else if (reportName == "ChallanPrint")
            {
                if (Request.QueryString["TransID"] != null)
                {
                    string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                    reportPath += "Student/StudentChallan.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@FeeID", Request.QueryString["TransID"]);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Title", Request.QueryString["ReportTitle"].ToString().Trim());
                    rd.SetParameterValue("CompanyLogo", logoPath);
                    rd.SetParameterValue("Address", companyAddress);
                }
            }
            else if (reportName == "StudentTimeTable")
            {

                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                var Class = Request.QueryString["Class"];
                var Program = Request.QueryString["Program"];
                var ddlWeek = Request.QueryString["ddlWeek"];


                reportPath += "Student/rptStudentTimeTable.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("@Class", Class);

                rd.SetParameterValue("@Program", Program);
                rd.SetParameterValue("@Weeks", ddlWeek);

                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Address", companyAddress);
            }

            else if (reportName == "AttendanceReport")
            {
                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                var Class = Request.QueryString["classs"];
                var FTime = Request.QueryString["FTime"];
                var TTime = Request.QueryString["TTime"];
                var Program = Request.QueryString["program"];
                var Batch = Request.QueryString["bathc"];
                var Group = Request.QueryString["Group"];
                var txt_WholeClass = Convert.ToBoolean(Request.QueryString["txt_WholeClass"]);
                var Date = Request.QueryString["date"];


                DateTime dt = DateTime.Parse(FTime);
                var ftime = dt.ToString("hh:mm tt");

                DateTime Totime = DateTime.Parse(TTime);
                var Ttime = Totime.ToString("hh:mm tt");

                DateTime datee = DateTime.Parse(Date);
                var newdate = datee.ToString("dd-MM-yyyy");


                reportPath += "Student/rptAttendanceReport.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("@classs", Class);
                rd.SetParameterValue("@FTime", ftime);
                rd.SetParameterValue("@TTime", Ttime);

                rd.SetParameterValue("@program", Program);
                rd.SetParameterValue("@bathc", Batch);
                rd.SetParameterValue("@Group", Group);
                rd.SetParameterValue("@txt_WholeClass", txt_WholeClass);
                rd.SetParameterValue("@datee", datee.Date);

                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Address", companyAddress);

            }


            else if (reportName == "HospitalServices")
            {

                string rptFileName = "TransactionalDetails/rptHospital_Services_Detail.rpt";
                string patientTpe = Request.QueryString["Patient_Type"].ToString();
                string serviceID = Request.QueryString["ServiceID"].ToString();
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);

                string stDate = Request.QueryString["StartDate"].ToString();
                string stTime = Request.QueryString["StartTime"].ToString();

                string endDate = Request.QueryString["EndDate"].ToString();
                string endTime = Request.QueryString["EndTime"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                string op = Request.QueryString["Operator"];
                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);
                rd.SetParameterValue("@Patient_Type", patientTpe);
                rd.SetParameterValue("@StDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                rd.SetParameterValue("@serviceID", serviceID);
                rd.SetParameterValue("@Operator", op);
                rd.SetParameterValue("CompanyLogo", logoPath);

            }
            #endregion
            #region General Patient Report
            else if (reportName == "TotalPatientRegsreport")
            {

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                reportPath += "GeneralPatientsReport/rptPatientRegistration.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", "" + " Total Patients Report From " + Convert.ToDateTime(Request.QueryString["sDate"]).ToString("dd-MMM-yyyy") + " To " + Convert.ToDateTime(Request.QueryString["eDate"]).ToString("dd-MMM-yyyy"));
                rd.SetParameterValue("@stDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "Birth_Certificate_Detail_Report")
            {

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                reportPath += "InPatient/rptBirthCertificateDetailReport.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", "" + " Birth Detail Report from " + Convert.ToDateTime(Request.QueryString["sDate"]).ToString("dd-MMM-yyyy") + " To " + Convert.ToDateTime(Request.QueryString["eDate"]).ToString("dd-MMM-yyyy"));
                rd.SetParameterValue("@stDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "Death_Certificate_Detail_Report")
            {
                string StartDateTime = Request.QueryString["sDate"].ToString();
                string EndDateTime = Request.QueryString["eDate"].ToString();

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                reportPath += "InPatient/rptDeathCertificate_Detail_Report.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@stDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "Patient_Quality_Check_Report")
            {

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                reportPath += "Patients/sp_Medical_Record_Quality_Check.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@stDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Address", companyAddress);
            }
            else if (reportName == "LCP")
            {

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                reportPath += "Patients/rptServicesLCP.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("ReportTitle", reportTitle);
                rd.SetParameterValue("@StartDate", StartDateTime);
                rd.SetParameterValue("@EndDate", EndDateTime);
                rd.SetParameterValue("CompanyLogo", logoPath);
                
            }
            else if (reportName == "Gir_To_Po_Heirarchy")
            {

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                reportPath += "Inventory/rptGirToPoHeirarchy.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@stDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Address", companyAddress);
            }
            else if (reportName == "High_Risk_Medicine_Report")
            {

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                reportPath += "Pharmacy/rptHighRiskMedicine.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@startDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Address", companyAddress);
            }
            else if (reportName == "Narcotic_Medicine_Report")
            {

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                reportPath += "Pharmacy/rptNarcoticMedicine.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@startDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Address", companyAddress);
            }
            else if (reportName == "Lab_Test_Result_Culture")
            {

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                string Department = Request.QueryString["Department"].ToString();
                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                reportPath += "LabRadiology/rptLabTestResultCulture.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@stDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("@Group_Department", Department);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Address", companyAddress);
            }
            else if (reportName == "Cath_Lab_Billing_Detail_Report")
            {

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                string MrNo = Request.QueryString["MRNo"].ToString();
                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string doctorID = Request.QueryString["DoctorID"].ToString();
                string Operator = Request.QueryString["Operator"].ToString();
                string ItemID = Request.QueryString["ItemID"].ToString();


                reportPath += "TransactionalDetails/rptCathLabBillingDetailReport.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@Operator", Operator);
                rd.SetParameterValue("@Doctor", doctorID);
                rd.SetParameterValue("@MrNo", MrNo);
                rd.SetParameterValue("@itemId", ItemID);
                rd.SetParameterValue("@stDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Address", companyAddress);
                rd.SetParameterValue("@FromDate", StartDateTime, rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@ToDate", EndDateTime, rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@UserId", Operator, rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@Item_ID", ItemID, rd.Subreports[0].Name.ToString());
            }
            else if (reportName == "Cath_Lab_Billing_Detail_Vendor_Wise_Report")
            {

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                string MrNo = Request.QueryString["MRNo"].ToString();
                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string doctorID = Request.QueryString["DoctorID"].ToString();
                string Operator = Request.QueryString["Operator"].ToString();
                string ItemID = Request.QueryString["ItemID"].ToString();
                string vendorID = Request.QueryString["VendorId"].ToString();


                reportPath += "TransactionalDetails/rptCathLabBillingDetailVendorWiseReport.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@Operator", Operator);
                rd.SetParameterValue("@Doctor", doctorID);
                rd.SetParameterValue("@MrNo", MrNo);
                rd.SetParameterValue("@itemId", ItemID);
                rd.SetParameterValue("@stDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("@Vendor_ID", vendorID);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Address", companyAddress);
            }
            //Total Patient Report
            else if (reportName == "TotalOpdDischargeReport")
            {
                reportPath += "GeneralPatientsReport/rptOpdPatientDischargeReport.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                //rd.SetParameterValue("Title", "" + " OPD Discharge Report From " + Convert.ToDateTime(Request.QueryString["sDate"]).ToString("dd-MMM-yyyy") + " To " + Convert.ToDateTime(Request.QueryString["eDate"]).ToString("dd-MMM-yyyy"));
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@stDate", Convert.ToDateTime(Request.QueryString["sDate"]));
                rd.SetParameterValue("@endDate", Convert.ToDateTime(Request.QueryString["eDate"]));
            }
            else if (reportName == "TotalpatientsandRevisitpatientsreport")
            {
                string rptFileName = "GeneralPatientsReport/rptTotalPat_RevisitPat.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("Title", " Total Patients Status Report From " + Convert.ToDateTime(Request.QueryString["sDate"]).ToString("dd-MMM-yyyy") + " To " + Convert.ToDateTime(Request.QueryString["eDate"]).ToString("dd-MMM-yyyy"));
                rd.SetParameterValue("@stDate", Convert.ToDateTime(Request.QueryString["sDate"]));
                rd.SetParameterValue("@endDate", Convert.ToDateTime(Request.QueryString["eDate"]));
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
            }
            else if (reportName == "LabTestDetailCollection")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string rptFileName = "GeneralPatientsReport/rptLabTestDetailCollection.rpt";
                string CheckSummary = Request.QueryString["Summary"].ToString();
                if (CheckSummary == "true")
                {
                    rptFileName = "GeneralPatientsReport/rptLabTestDetailCollection_Summary.rpt";
                }
                reportPath += rptFileName;
                rd.Load(reportPath);

                string stDate = Request.QueryString["sDate"].ToString();
                string stTime = Request.QueryString["STime"].ToString();

                string endDate = Request.QueryString["eDate"].ToString();
                string endTime = Request.QueryString["ETime"].ToString();
                string TestName = Request.QueryString["testName"].ToString();       
                string Department = Request.QueryString["Department"].ToString();       
                string Operator = Request.QueryString["Operator"].ToString();       
                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;
                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);
                string PatType = Request.QueryString["Patient_Type"].ToString();


                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", "Lab Cash Collection");
                rd.SetParameterValue("@Department", Department);
                rd.SetParameterValue("@TestName", TestName);
                rd.SetParameterValue("@Patient_Type", PatType);
                rd.SetParameterValue("@Operator", Operator);
                rd.SetParameterValue("CompanyLogo", logoPath);

            }
            else if (reportName == "RadiologyReport")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string rptFileName = "LabRadiology/rptRadiologyReport.rpt";


                reportPath += rptFileName;
                rd.Load(reportPath);

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string Operator = Request.QueryString["Operator"].ToString();
                string TestName = Request.QueryString["testName"].ToString();
                string MainDepartment = Request.QueryString["MainDepartment"].ToString();
                string PatType = Request.QueryString["Patient_Type"].ToString();
                //if (TestName == "All")
                //{
                //    TestName = "0";
                //}
                rd.SetParameterValue("@LabTest", TestName);

                rd.SetParameterValue("@RadiologyDept", MainDepartment);
                rd.SetParameterValue("@Operator", Operator);

                rd.SetParameterValue("@stDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@Patient_Type", PatType);
                rd.SetParameterValue("CompanyLogo", logoPath);


            }
            else if (reportName == "RadiologyReport_Panel")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string rptFileName = "LabRadiology/rptRadiologyPanelReport.rpt";


                reportPath += rptFileName;
                rd.Load(reportPath);

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string Operator = Request.QueryString["Operator"].ToString();
                string TestName = Request.QueryString["testName"].ToString();
                string MainDepartment = Request.QueryString["MainDepartment"].ToString();
                string PatType = Request.QueryString["Patient_Type"].ToString();
                string Panel = Request.QueryString["Panel"].ToString();
                //if (TestName == "All")
                //{
                //    TestName = "0";
                //}
                rd.SetParameterValue("@LabTest", TestName);

                rd.SetParameterValue("@RadiologyDept", MainDepartment);
                rd.SetParameterValue("@Operator", Operator);

                rd.SetParameterValue("@stDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@Patient_Type", PatType);
                rd.SetParameterValue("@Panel", Panel);
                rd.SetParameterValue("CompanyLogo", logoPath);


            }
            else if (reportName == "Panel_wise_Billing_Report")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string rptFileName = "LabRadiology/rptPanelWiseBillingReport.rpt";


                reportPath += rptFileName;
                rd.Load(reportPath);

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string Operator = Request.QueryString["Operator"].ToString();
                string TestName = Request.QueryString["testName"].ToString();
                string MainDepartment = Request.QueryString["MainDepartment"].ToString();
                string Panel = Request.QueryString["Panel"].ToString();
                //if (TestName == "All")
                //{
                //    TestName = "0";
                //}
                rd.SetParameterValue("@LabTest", TestName);

                rd.SetParameterValue("@RadiologyDept", MainDepartment);
                rd.SetParameterValue("@Operator", Operator);

                rd.SetParameterValue("@stDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@Panel", Panel);
                rd.SetParameterValue("CompanyLogo", logoPath);


            }
            else if (reportName == "AnalysisReport")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string rptFileName = "TransactionalDetails/rptAnalysisReport.rpt";


                reportPath += rptFileName;
                rd.Load(reportPath);

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string Operator = Request.QueryString["Operator"].ToString();
                string TestName = Request.QueryString["testName"].ToString();
                rd.SetParameterValue("@LabTest", TestName);

                rd.SetParameterValue("@Operator", Operator);

                rd.SetParameterValue("@stDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("CompanyLogo", logoPath);


            }
            //else if (reportName == "AnalysisReport")
            //{
            //    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

            //    string rptFileName = "TransactionalDetails/rptAnalysisReport.rpt";
            //    reportPath += rptFileName;
            //    rd.Load(reportPath);
            //    string stDate = Request.QueryString["sDate"].ToString();
            //    string stTime = Request.QueryString["STime"].ToString();
            //    string endDate = Request.QueryString["eDate"].ToString();
            //    string endTime = Request.QueryString["ETime"].ToString();
            //    string TestName = Request.QueryString["Tests"].ToString();

            //    string Operator = Request.QueryString["Operator"].ToString();
            //    string parameterStDate = string.Empty;
            //    string parameterEndDate = string.Empty;

            //    this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
            //    this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);

            //    rd.SetParameterValue("@LabTest", Request.QueryString["Department"]);
            //    rd.SetParameterValue("@stDate", parameterStDate);
            //    rd.SetParameterValue("@endDate", parameterEndDate);
            //    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
            //    rd.SetParameterValue("Title", "Analysis Report");
            //    rd.SetParameterValue("@Operator", Operator);
            //    rd.SetParameterValue("CompanyLogo", logoPath);

            //}
            else if (reportName == "Sale_Return_Report")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string rptFileName = "Pharmacy/rptSaleReturnReport.rpt";


                reportPath += rptFileName;
                rd.Load(reportPath);

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string Operator = Request.QueryString["Operator"].ToString();
                rd.SetParameterValue("@UserId", Operator);
                rd.SetParameterValue("@FromDate", StartDateTime);
                rd.SetParameterValue("@ToDate", EndDateTime);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("@Warehouse", Request.QueryString["WareHouse"]);


            }
            else if (reportName == "Sale_Report_Summary")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string rptFileName = "Pharmacy/rptSaleSummaryReport.rpt";


                reportPath += rptFileName;
                rd.Load(reportPath);

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                var WAREHOUSE = Request.QueryString["WareHouse"];
                string Operator = Request.QueryString["Operator"].ToString();
                rd.SetParameterValue("@UserId", Operator);
                rd.SetParameterValue("@FromDate", StartDateTime);
                rd.SetParameterValue("@ToDate", EndDateTime);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("CompanyLogo", logoPath);

                rd.SetParameterValue("@Warehouse", WAREHOUSE);


                rd.SetParameterValue("@FromDate", StartDateTime, rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@ToDate", EndDateTime, rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@UserId", Request.QueryString["Operator"], rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@Warehouse", WAREHOUSE, rd.Subreports[0].Name.ToString());

            }
            else if (reportName == "Pharmacy_Customer_Report")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string rptFileName = "Pharmacy/rptPharmacyCustomerReaport.rpt";


                reportPath += rptFileName;
                rd.Load(reportPath);

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                rd.SetParameterValue("@Start_date", StartDateTime);
                rd.SetParameterValue("@End_date", EndDateTime);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("@Warehouse", Request.QueryString["WareHouse"]);

            }
            else if (reportName == "Physiotherapy_Cash_Collection")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string rptFileName = "LabRadiology/rptPhysiotherapyCashCollection.rpt";

                reportPath += rptFileName;
                rd.Load(reportPath);

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                rd.SetParameterValue("@stDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "Cardiology_Cash_Collection")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string rptFileName = "LabRadiology/rptCardiologyCashCollection.rpt";

                reportPath += rptFileName;
                rd.Load(reportPath);
                string testName = Request.QueryString["TestName"] ?? "All";

                // string testID = Request.QueryString["TestID"] ?? "All"; // Default to "All" if not provided

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                //string department = Request.QueryString["Department"].ToString();
                //if (department == "" || department == "null")
                //{
                //    department = "All";
                //}

                rd.SetParameterValue("@LabTest", testName);

                rd.SetParameterValue("@stDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "Item_Wise_Margin_Report")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string rptFileName = "Pharmacy/rptItemWiseMarginReport.rpt";
                string ItemID = Request.QueryString["ItemID"].ToString();

                reportPath += rptFileName;
                rd.Load(reportPath);

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                rd.SetParameterValue("@itemId", ItemID);
                rd.SetParameterValue("@warehouseId", Request.QueryString["WareHouse"]);
                rd.SetParameterValue("@startDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "Item_Wise_Purchase_Report")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string rptFileName = "Pharmacy/rptItemWiseDetailReport.rpt";
                string ItemID = Request.QueryString["ItemID"].ToString();

                reportPath += rptFileName;
                rd.Load(reportPath);

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                rd.SetParameterValue("@itemId", ItemID);
                rd.SetParameterValue("@warehouseId", Request.QueryString["WareHouse"]);
                rd.SetParameterValue("@startDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }

            else if (reportName == "Lab_Test_Wise_Summary")
            {
                string rptFileName = "TransactionalDetails/rptLabTestWiseDetailCollection _Summary.rpt";
                string CheckSummary = Request.QueryString["Summary"].ToString();
                if (CheckSummary == "true")
                {
                    rptFileName = "TransactionalDetails/rptLabTestWiseDetailCollection _Summary.rpt";
                }
                reportPath += rptFileName;
                rd.Load(reportPath);

                string stDate = Request.QueryString["sDate"].ToString();
                string stTime = Request.QueryString["STime"].ToString();

                string endDate = Request.QueryString["eDate"].ToString();
                string endTime = Request.QueryString["ETime"].ToString();
                string TestName = Request.QueryString["testName"].ToString();
                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;
                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);
                string PatType = Request.QueryString["Patient_Type"].ToString();
                rd.SetParameterValue("@TestName", TestName);
                rd.SetParameterValue("@Department", Request.QueryString["Department"]);

                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", "Lab Cash Collection");
                //rd.SetParameterValue("Patient_Type", PatType);

            }
            else if (reportName == "Radiology_Test_Wise_Summary")
            {
                string rptFileName = "TransactionalDetails/rptRadiologyTestWiseDetailCollection_Summary.rpt";
                
                reportPath += rptFileName;
                rd.Load(reportPath);

                string stDate = Request.QueryString["sDate"].ToString();
                string stTime = Request.QueryString["STime"].ToString();

                string endDate = Request.QueryString["eDate"].ToString();
                string endTime = Request.QueryString["ETime"].ToString();
                string TestName = Request.QueryString["testName"].ToString();
                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;
                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);
                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", "Radiology Test Wise Summary");
                rd.SetParameterValue("@TestName", TestName);
                rd.SetParameterValue("@Department", Request.QueryString["Department"]);


            }
            else if (reportName == "Lab_Test_Patient_Wise")
            {
                string rptFileName = "LabRadiology/rptLabTestPatientsWise.rpt";
                string CheckSummary = Request.QueryString["Summary"].ToString();
                if (CheckSummary == "true")
                {
                    rptFileName = "LabRadiology/rptLabTestPatientsWise.rpt";
                }
                reportPath += rptFileName;
                rd.Load(reportPath);

                string stDate = Request.QueryString["sDate"].ToString();
                string stTime = Request.QueryString["STime"].ToString();

                string endDate = Request.QueryString["eDate"].ToString();
                string endTime = Request.QueryString["ETime"].ToString();
                string TestName = Request.QueryString["testName"].ToString();
                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;
                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);
                rd.SetParameterValue("@TestName", TestName);
                rd.SetParameterValue("@Department", Request.QueryString["Department"]);

                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", "Lab Cash Collection");

            }
            else if (reportName == "IPDStatus")
            {
                try
                {
                    //string CurrentUserID = AppConfig.UserID.ToString();

                    DateTime sdateTime = Convert.ToDateTime(Request.QueryString["sDate"].ToString());

                    DateTime edateTime = Convert.ToDateTime(Request.QueryString["eDate"].ToString());

                    string deptID = Request.QueryString["DepartmentID"].ToString();
                    string Status = Request.QueryString["Status"].ToString();

                    reportPath += "GeneralPatientsReport/rptIPDStatus.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("@sDate", sdateTime);
                    rd.SetParameterValue("@eDate", edateTime);
                    rd.SetParameterValue("@DepartmentID", deptID);
                    //  rd.SetParameterValue("@UserID", CurrentUserID);
                    rd.SetParameterValue("@checkStatus", Status);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Title", reportTitle);

                }
                catch (Exception ex)
                {

                    throw;
                }
            }
            else if (reportName == "DischargeReceived")
            {

                string StartDateTime = Request.QueryString["StartDateTime"];
                string EndDateTime = Request.QueryString["EndDateTime"];

                string Shift_Id = Request.QueryString["Shift"];
                string Doctor = Request.QueryString["Doctor"];
                string Procedure = Request.QueryString["Procedure"];

                reportPath += "GeneralPatientsReport/rptDischarge_Received.rpt";
                rd.Load(reportPath);
                //rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@FromDate", StartDateTime);
                rd.SetParameterValue("@ToDate", EndDateTime);
                rd.SetParameterValue("Shift_Id", Shift_Id);
                rd.SetParameterValue("@Doctor", Doctor);
                rd.SetParameterValue("@Procedure", Procedure);

                rd.SetParameterValue("CompanyName", AppConfig.Company_Name, rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID, rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("Title", reportTitle, rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@FromDate", StartDateTime, rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@ToDate", EndDateTime, rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("Shift_Id", Shift_Id, rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@Doctor", Doctor, rd.Subreports[0].Name.ToString());

                rd.SetParameterValue("CompanyName", AppConfig.Company_Name, rd.Subreports[1].Name.ToString());
                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID, rd.Subreports[1].Name.ToString());
                rd.SetParameterValue("Title", reportTitle, rd.Subreports[1].Name.ToString());
                rd.SetParameterValue("@FromDate", StartDateTime, rd.Subreports[1].Name.ToString());
                rd.SetParameterValue("@ToDate", EndDateTime, rd.Subreports[1].Name.ToString());
                rd.SetParameterValue("Shift_Id", Shift_Id, rd.Subreports[1].Name.ToString());
                rd.SetParameterValue("@Doctor", Doctor, rd.Subreports[1].Name.ToString());

            }
            else if (reportName == "Discharge_Detail")
            {                                       // pat type 

                string operatorID = "0";
                string rptFileName = "GeneralPatientsReport/rptDischarge_Detail.rpt";
                string CheckSummary = Request.QueryString["Summary"].ToString();
                if (CheckSummary == "true")
                {
                    rptFileName = "GeneralPatientsReport/rptDischarge_Detail_Summary.rpt";
                    reportTitle = "Discharge Detail Summary Report From " + Request.QueryString["StartDate"].ToString() + " " + Request.QueryString["StartTime"].ToString() + " to " + Request.QueryString["EndDate"].ToString() + " " + Request.QueryString["EndTime"].ToString();
                }
                reportPath += rptFileName;
                rd.Load(reportPath);

                string departmentID = Request.QueryString["Department"].ToString();
                string PatType = Request.QueryString["PatientType"].ToString();
                string stDate = Request.QueryString["StartDate"].ToString();
                string stTime = Request.QueryString["StartTime"].ToString();

                string endDate = Request.QueryString["EndDate"].ToString();
                string endTime = Request.QueryString["EndTime"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);

                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("@DepartmentID", departmentID);
                rd.SetParameterValue("@Patient_Type", PatType);
                string MedicalSubsidy = Request.QueryString["MedicalSubsidy"].ToString();

                if (MedicalSubsidy == "1")
                {
                    reportTitle = "Medical Subsidy Detail From " + Request.QueryString["StartDate"].ToString() + " " + Request.QueryString["StartTime"].ToString() + " to " + Request.QueryString["EndDate"].ToString() + " " + Request.QueryString["EndTime"].ToString();
                    rd.RecordSelectionFormula = "{spDischarge_Detail;1.Medical_Subsidy} > 0";
                }
                else if (MedicalSubsidy == "2")
                {
                    rd.RecordSelectionFormula = "{spDischarge_Detail;1.Medical_Subsidy} = 0";
                }

                if (Request.QueryString["Operator"].ToString().Trim() != "0")
                {
                    operatorID = Request.QueryString["Operator"].ToString();
                }

                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@Operator", operatorID);
            }
            else if (reportName == "IPDDoctorShareReport")
            {
                //  var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string rptFileName = "TransactionalDetails/IPDDoctorShareDetail.rpt";
                string Operator = Request.QueryString["Operator"].ToString();

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
             

                reportPath += rptFileName;
                rd.Load(reportPath);

                string departmentID = Request.QueryString["Department"].ToString();
                string PatientType = Request.QueryString["PatientType"].ToString();

                string stDate = Request.QueryString["StartDate"].ToString();
                string stTime = Request.QueryString["StartTime"].ToString();

                string endDate = Request.QueryString["EndDate"].ToString();
                string endTime = Request.QueryString["EndTime"].ToString();
                //string doctorID = Request.QueryString["DoctorID"].ToString();
                string doctorID = Request.QueryString["DoctorID"] ?? "0";
                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);

                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("@DepartmentID", departmentID);

                rd.SetParameterValue("@Patient_Category", PatientType);
                rd.SetParameterValue("@DoctorID", doctorID);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@Operator", Operator);
            }
            else if (reportName == "DoctorShare_Report")
            {
                //  var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string rptFileName = "TransactionalDetails/AllDoctorShareDetail.rpt";
                string Operator = Request.QueryString["Operator"].ToString();

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string CheckSummary = Request.QueryString["Summary"].ToString();
                if (CheckSummary == "true")
                {
                    rptFileName = "TransactionalDetails/AllDoctorShareDetail_Summary.rpt";

                    reportTitle =
                        "Doctor Share Report from " +
                        Request.QueryString["StartDate"] + " " +
                        Request.QueryString["StartTime"] + " to " +
                        Request.QueryString["EndDate"] + " " +
                        Request.QueryString["EndTime"] +
                        "&StartDate=" + Request.QueryString["StartDate"] +
                        "&EndDate=" + Request.QueryString["EndDate"] +
                        "&StartTime=" + Request.QueryString["StartTime"] +
                        "&EndTime=" + Request.QueryString["EndTime"] +
                        "&DoctorID=" + Request.QueryString["DoctorID"] +
                        "&Operator=" + Operator +
                        "&Department=" + (Request.QueryString["Department"] ?? "0") +
                        "&PatientType=" + Request.QueryString["PatientType"];
                }

                reportPath += rptFileName;
                rd.Load(reportPath);

                string departmentID = Request.QueryString["Department"].ToString();
                string PatType = Request.QueryString["PatientType"].ToString();
                string stDate = Request.QueryString["StartDate"].ToString();
                string stTime = Request.QueryString["StartTime"].ToString();

                string endDate = Request.QueryString["EndDate"].ToString();
                string endTime = Request.QueryString["EndTime"].ToString();
                //string doctorID = Request.QueryString["DoctorID"].ToString();
                string doctorID = Request.QueryString["DoctorID"] ?? "0";
                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);

                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("@DepartmentID", departmentID);
                rd.SetParameterValue("@Patient_Type", PatType);
                rd.SetParameterValue("@DoctorID", doctorID);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@Operator", Operator);
            }

            else if (reportName == "AdvanceDetail")
            {
                string rptFileName = "GeneralPatientsReport/rptPrintAdvanceRecord.rpt";
                string StartDateTime = Request.QueryString["sDate"].ToString();
                string EndDateTime = Request.QueryString["eDate"].ToString();

                string stTime = Request.QueryString["StartTime"].ToString();
                string endTime = Request.QueryString["EndTime"].ToString();

                string patType = Request.QueryString["Patient_Type"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(StartDateTime, stTime, out parameterStDate);
                this.getDateTimeDBFormate(EndDateTime, endTime, out parameterEndDate);


                if (patType == string.Empty || patType == "undefined")
                {
                    patType = "All";
                }

                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("@sDate", parameterStDate);
                rd.SetParameterValue("@eDate", parameterEndDate);
                string departmentID = Request.QueryString["Department"].ToString();
                rd.SetParameterValue("@DepartmentID", departmentID);
                rd.SetParameterValue("Company_Name", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@PatientType", patType);
            }
            else if (reportName == "ReportVoucher")
            {
                string rptFileName = "TransactionalDetails/rptLabTestReportVoucher.rpt";
                string StartDateTime = Request.QueryString["sDate"].ToString();
                string EndDateTime = Request.QueryString["eDate"].ToString();

                string stTime = Request.QueryString["StartTime"].ToString();
                string endTime = Request.QueryString["EndTime"].ToString();

                //string patType = Request.QueryString["Patient_Type"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(StartDateTime, stTime, out parameterStDate);
                this.getDateTimeDBFormate(EndDateTime, endTime, out parameterEndDate);


                //if (patType == string.Empty || patType == "undefined")
                //{
                //    patType = "All";
                //}

                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("@sDate", parameterStDate);
                rd.SetParameterValue("@eDate", parameterEndDate);
                string departmentID = Request.QueryString["Department"].ToString();
                rd.SetParameterValue("@DepartmentID", departmentID);
                rd.SetParameterValue("Company_Name", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                //rd.SetParameterValue("@PatientType", patType);
            }
            else if (reportName == "Patient_Count_Department_Wise")
            {
                string rptFileName = "TransactionalDetails/rptLabTestPatientsCategoryWise.rpt";
                string StartDateTime = Request.QueryString["sDate"].ToString();
                string EndDateTime = Request.QueryString["eDate"].ToString();

                string stTime = Request.QueryString["StartTime"].ToString();
                string endTime = Request.QueryString["EndTime"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(StartDateTime, stTime, out parameterStDate);
                this.getDateTimeDBFormate(EndDateTime, endTime, out parameterEndDate);

                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("@StartDate", parameterStDate);
                rd.SetParameterValue("@EndDate", parameterEndDate);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
            }
            else if (reportName == "TestWiseMonthlyLabTestDepartment")
            {
                string rptFileName = "GeneralPatientsReport/rptDailyTestMonthly_TestDepartments.rpt";
                string StartDateTime = Request.QueryString["sDate"].ToString();
                string EndDateTime = Request.QueryString["eDate"].ToString();

                string stTime = Request.QueryString["StartTime"].ToString();
                string endTime = Request.QueryString["EndTime"].ToString();

                //string patType = Request.QueryString["Patient_Type"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(StartDateTime, stTime, out parameterStDate);
                this.getDateTimeDBFormate(EndDateTime, endTime, out parameterEndDate);


                //if (patType == string.Empty || patType == "undefined")
                //{
                //    patType = "All";
                //}

                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("@sDate", parameterStDate);
                rd.SetParameterValue("@eDate", parameterEndDate);
                string departmentID = Request.QueryString["Department"].ToString();
                rd.SetParameterValue("@DepartmentID", departmentID);
                rd.SetParameterValue("Company_Name", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                //rd.SetParameterValue("@PatientType", patType);
            }
            else if (reportName == "Stock_In_Hand_Detail")
            {
                string rptFileName = "Inventory/rptStockinHandDetail.rpt";
                string StartDateTime = Request.QueryString["sDate"].ToString();
                string EndDateTime = Request.QueryString["eDate"].ToString();
                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();

                string stTime = Request.QueryString["StartTime"].ToString();
                string endTime = Request.QueryString["EndTime"].ToString();

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(StartDateTime, stTime, out parameterStDate);
                this.getDateTimeDBFormate(EndDateTime, endTime, out parameterEndDate);

                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("@FromDate", parameterStDate);
                rd.SetParameterValue("@ToDate", parameterEndDate);
                string departmentID = Request.QueryString["Department"].ToString();
                rd.SetParameterValue("@Department", departmentID);
                rd.SetParameterValue("Address", companyAddress);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "ActiveItems")
            {
                string rptFileName = "Inventory/rptActiveItemsList.rpt";
                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();

                string statusParam = Request.QueryString["Status"] ?? "0";
                string itemFilterParam = Request.QueryString["ItemFilter"] ?? "0";


                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("Address", companyAddress);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("@StatusFilter", statusParam);
                rd.SetParameterValue("@ItemTypeFilter", itemFilterParam);

            }
            else if (reportName == "AdmissionDetail")
            {
                string operatorID = "0";
                string rptFileName = "GeneralPatientsReport/rptIPD_Detail.rpt";
                string CheckSummary = Request.QueryString["Summary"].ToString();
                if (CheckSummary == "true")
                {
                    rptFileName = "GeneralPatientsReport/rptIPD_Detail_Summary.rpt";
                    reportTitle = "Admission Detail Summary From " + Request.QueryString["StartDate"].ToString() + "to" + Request.QueryString["EndDate"].ToString();
                }

                reportPath += rptFileName;
                rd.Load(reportPath);


                string stDate = Request.QueryString["StartDate"].ToString();
                string stTime = Request.QueryString["StartTime"].ToString();

                string endDate = Request.QueryString["EndDate"].ToString();
                string endTime = Request.QueryString["EndTime"].ToString();
                string Patient_Type = Request.QueryString["Patient_Type"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);

                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);

                if (Request.QueryString["Operator"].ToString().Trim() != "0")
                {
                    operatorID = Request.QueryString["Operator"].ToString();
                }
                rd.SetParameterValue("@Operator", operatorID);
                rd.SetParameterValue("@Patient_Type", Patient_Type);
            }
            #endregion
            #region Operations
            else if (reportName == "ActivePatientList")
            {

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string rptFileName = "Operations/rptActivePatientReport.rpt";
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                string departmentID = Request.QueryString["Department"].ToString();
                string FilterClinic = Request.QueryString["FilterClinic"].ToString();
                string patType = Request.QueryString["PatientType"].ToString();
                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@startDate", StartDateTime);
                rd.SetParameterValue("@EndDate", EndDateTime);
                rd.SetParameterValue("@DepartmentID", departmentID);
                rd.SetParameterValue("@patientType", patType);
                rd.SetParameterValue("@filterClinic", FilterClinic);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "ActivePatientListSummary")
            {

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string rptFileName = "Operations/rptActivePatientReportSummary.rpt";
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                string departmentID = Request.QueryString["Department"].ToString();
                string FilterClinic = Request.QueryString["FilterClinic"].ToString();
                string patType = Request.QueryString["PatientType"].ToString();
                string Doctor = Request.QueryString["Doctor"].ToString();
                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@startDate", StartDateTime);
                rd.SetParameterValue("@EndDate", EndDateTime);
                rd.SetParameterValue("@DepartmentID", departmentID);
                rd.SetParameterValue("@filterClinic", FilterClinic);
                rd.SetParameterValue("@patientType", patType);
                rd.SetParameterValue("@DoctorID", Doctor);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "AppointmentList")
            {
                string rptFileName = "Operations/rptAppointmentList.rpt";
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                string Doctor = Request.QueryString["Doctor"].ToString();
                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@startDate", StartDateTime);
                rd.SetParameterValue("@EndDate", EndDateTime);
                rd.SetParameterValue("@DoctorID", Doctor);
            }
            #endregion
            #region Clinical OPD
            else if (reportName == "PatientLedger")
            {
                string rptFileName = "Clinical-OPD/rptPatientLedger.rpt";
                //string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                //string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                string departmentID = Request.QueryString["Department"].ToString();
                string FilterClinic = Request.QueryString["FilterClinic"].ToString();
                string patType = Request.QueryString["PatientType"].ToString();
                string Doctor = Request.QueryString["Doctor"].ToString();
                string endDate = Request.QueryString["EndDate"].ToString();
                string endTime = Request.QueryString["EndTime"].ToString();
                //string doctorID = Request.QueryString["DoctorID"].ToString();
                string doctorID = Request.QueryString["DoctorID"] ?? "0";

                string stDate = Request.QueryString["StartDate"].ToString();
                string stTime = Request.QueryString["StartTime"].ToString();


                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);


                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("@startDate", parameterStDate);
                rd.SetParameterValue("@EndDate", parameterEndDate);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                //rd.SetParameterValue("@startDate", StartDateTime);
                //rd.SetParameterValue("@EndDate", EndDateTime);
                rd.SetParameterValue("@DepartmentID", departmentID);
                rd.SetParameterValue("@filterClinic", FilterClinic);
                rd.SetParameterValue("@patientType", patType);
                rd.SetParameterValue("@DoctorID", Doctor);
            }
            else if (reportName == "SinglePatientLedger")
            {
                string rptFileName = "Clinical-OPD/rptSinglePatientLedger.rpt";
                string mrNo = Request.QueryString["MrNo"].ToString();
                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@MrNo", mrNo);
            }

            #endregion
            #region Account & Finance
            else if (reportName == "RevenueDepartmentWise")
            {
                reportPath += "AccountAndFinance/rptRevenueDepartmentWise.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);

                string stDate = Request.QueryString["StartDate"].ToString();
                string stTime = Request.QueryString["StartTime"].ToString();

                string endDate = Request.QueryString["EndDate"].ToString();
                string endTime = Request.QueryString["EndTime"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);

                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("@Operator", Request.QueryString["Operator"]);
                rd.SetParameterValue("@Cashier", Request.QueryString["Cashier"]);
                rd.SetParameterValue("@PatientType", Request.QueryString["Patient_Type"]);
            }
            else if (reportName == "RevenuseSummary")
            {
                string rptFileName = "AccountAndFinance/rptRevenueDepartmentWiseSummary.rpt";
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@stDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
            }
            else if (reportName == "Head_Wise_Discount_Report")
            {
                string rptFileName = "TransactionalDetails/rptHeadWiseDiscountReport.rpt";
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("ReportTitle", reportTitle);
                rd.SetParameterValue("@StartDate", StartDateTime);
                rd.SetParameterValue("@EndDate", EndDateTime);
            }
            else if (reportName == "TimeAndMotion")
            {
                string rptFileName = "Patients/rptServicesTime&Motion.rpt";
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("ReportTitle", reportTitle);
                rd.SetParameterValue("@StartDate", StartDateTime);
                rd.SetParameterValue("@EndDate", EndDateTime);
            }
            else if (reportName == "Daily_Sale_Summary")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string rptFileName = "Pharmacy/rptDailySaleSummary.rpt";
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@StartDate", StartDateTime);
                rd.SetParameterValue("@EndDate", EndDateTime);
                rd.SetParameterValue("@Warehouse", Request.QueryString["WareHouse"]);
                rd.SetParameterValue("@StartDate", StartDateTime, rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@EndDate", EndDateTime, rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@Warehouse", Request.QueryString["WareHouse"], rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "Item_Wise_Gross_Profit")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string ItemID = Request.QueryString["ItemID"].ToString();
                string warehouse = Request.QueryString["WareHouse"].ToString();

                string rptFileName = "Pharmacy/rptItemWiseGrossProfitReport.rpt";

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@Warehouse", warehouse);
                rd.SetParameterValue("@StartDate", StartDateTime);
                rd.SetParameterValue("@EndDate", EndDateTime);
                rd.SetParameterValue("@itemId", ItemID);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "Category_Wise_Profitability_Report")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string Category = Request.QueryString["Category"].ToString();

                string rptFileName = "Pharmacy/rptCategoryWiseProfitabilityReport.rpt";

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@StartDate", StartDateTime);
                rd.SetParameterValue("@EndDate", EndDateTime);
                rd.SetParameterValue("@Category", Category);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "YearlyPharmacyOverallSummaryReport2")
            {
                string year = Request.QueryString["Year"].ToString();

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string rptFileName = "Pharmacy/YearlyPharmacyOverallSummaryReport2.rpt";
                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("@Year", year);
                rd.SetParameterValue("@Year", year, rd.Subreports[0].Name.ToString());
            }
            else if (reportName == "YearlyPharmacyOverallSummaryReport")
            {
                string year = Request.QueryString["Year"].ToString();

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string rptFileName = "Pharmacy/YearlyPharmacyOverallSummaryReport.rpt";
                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("@Year", year);
                rd.SetParameterValue("@Warehouse", Request.QueryString["WareHouse"]);
                rd.SetParameterValue("@Year", year, rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@Warehouse", Request.QueryString["WareHouse"], rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@Year", year, rd.Subreports[1].Name.ToString());
                rd.SetParameterValue("@Warehouse", Request.QueryString["WareHouse"], rd.Subreports[1].Name.ToString());

            }
            else if (reportName == "DailyPharmacyOverallSummaryReport")
            {
                string year = Request.QueryString["Year"].ToString();
                string Month = Request.QueryString["Month"].ToString();

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string rptFileName = "Pharmacy/rptDailyPharmacyOverallSummaryReport.rpt";
                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("@Year", year);
                rd.SetParameterValue("@Month", Month);
                rd.SetParameterValue("@Warehouse", Request.QueryString["WareHouse"]);
                rd.SetParameterValue("@Year", year, rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@Month", Month, rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@Warehouse", Request.QueryString["WareHouse"], rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@Year", year, rd.Subreports[1].Name.ToString());
                rd.SetParameterValue("@Month", Month, rd.Subreports[1].Name.ToString());
                rd.SetParameterValue("@Warehouse", Request.QueryString["WareHouse"], rd.Subreports[1].Name.ToString());

            }
            else if (reportName == "FastSlow_Non_Moving_Stock")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string rptFileName = "Pharmacy/rptFastSlowNonMovingStock.rpt";
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string ItemID = Request.QueryString["ItemID"].ToString();
                string Movement_Type = Request.QueryString["MovementType"].ToString();

                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@StartDate", StartDateTime);
                rd.SetParameterValue("@EndDate", EndDateTime);
                rd.SetParameterValue("@Item_ID", ItemID);
                rd.SetParameterValue("@Movement_Type", Movement_Type);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("@Warehouse", Request.QueryString["WareHouse"]);
            }
            else if (reportName == "PCR")
            {
                string rptFileName = "AccountAndFinance/rptPharmacyCashReport.rpt";
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                string MrNo = Request.QueryString["MRNo"].ToString();
                string warehouse = Request.QueryString["WareHouse"].ToString();
                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@startDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("@MrNo", MrNo);
                rd.SetParameterValue("@WareHouse", warehouse);
            }
            else if (reportName == "PCRS")
            {
                string rptFileName = "AccountAndFinance/rptPharmacyCashSummary.rpt";
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@startDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
            }
            else if (reportName == "Advance_Base_Print")
            {
                if (Request.QueryString["Adv_ID"] != null)
                {
                    reportPath += "AccountAndFinance/rptAdvanceBasePrint.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@Advance_ID", Convert.ToInt32(Request.QueryString["Adv_ID"]));
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Title", Request.QueryString["ReportTitle"].ToString().Trim()); ;
                }
            }
            else if (reportName == "PurchaseInvoiceList")
            {
                if (Request.QueryString["Inv_ID"] != null)
                {
                    string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                    reportPath += "AccountAndFinance/rptPurchase_Invoice_Print.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@Purchase_ID", Convert.ToInt32(Request.QueryString["Inv_ID"]));
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", companyAddress);
                }
            }
            else if (reportName == "PaymentBasePrint")
            {
                reportPath += "AccountAndFinance/rptPaymentBasePrint.rpt";
                rd.Load(reportPath);
                DateTime stDate = Convert.ToDateTime(Request.QueryString["startDate"]);
                DateTime endDate = Convert.ToDateTime(Request.QueryString["endDate"]);
                string InvoiceID = Request.QueryString["Inv_Id"].ToString();
                //rd.SetParameterValue("@stDate", stDate);
                //rd.SetParameterValue("@endDate", endDate);
                rd.SetParameterValue("@PaymentInvoiceID", Convert.ToInt32(InvoiceID));
                rd.SetParameterValue("@InvId", Convert.ToInt32(InvoiceID));
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", Request.QueryString["ReportTitle"].ToString().Trim());
            }
            #endregion
            #region Account & Finance/Management
            else if (reportName == "ITR")
            {
                string rptFileName = "AccountandFinanceManagement/rptInvtrackReport.rpt";
                string form = Request.QueryString["invForm"].ToString();
                string No = Request.QueryString["invNo"].ToString();
                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@Form_Type", form);
                rd.SetParameterValue("@Form_No", No);
            }
            else if (reportName == "DoctorMS")
            {
                string rptFileName = "AccountandFinanceManagement/rptDoctorWiseMedicineSales.rpt";
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                string Doctor = Request.QueryString["Doctor"].ToString();
                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@startDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("@DoctorID", Doctor);
            }
            else if (reportName == "DoctorMSS")
            {
                string rptFileName = "AccountandFinanceManagement/rptDoctorWiseMedicineSalesSummary.rpt";
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                string Dept = Request.QueryString["Dept"].ToString();
                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@startDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("@DoctorID", Dept);
            }
            else if (reportName == "DMS")
            {
                string rptFileName = "AccountandFinanceManagement/rptDepartmentWiseMedicineSales.rpt";
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                string Dept = Request.QueryString["Dept"].ToString();
                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@startDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("@DepartmentID", Dept);
            }
            else if (reportName == "DMSS")
            {
                string rptFileName = "AccountandFinanceManagement/rptDepartmentWiseMedicineSalesSummary.rpt";
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                string Dept = Request.QueryString["Dept"].ToString();
                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@startDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("@DepartmentID", Dept);
            }
            #endregion
            #region General Ledger
            else if (reportName == "BalanceSheet")
            {
                reportPath += "GeneralLedger/rptBalanceSheet.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
            }
            else if (reportName == "BalanceSheetDetail")
            {
                if (Request.QueryString["startDate"] != null && Request.QueryString["Level1"] != null
                   && Request.QueryString["Level2"] != null && Request.QueryString["Level3"] != null
                   && Request.QueryString["Level4"] != null && Request.QueryString["stCode"] != null
                   && Request.QueryString["enCode"] != null)
                {
                    reportPath += "GeneralLedger/rptBalanceSheetDetail.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("@start_date", Convert.ToDateTime(Request.QueryString["startDate"]));
                    rd.SetParameterValue("@stCode", Request.QueryString["stCode"]);
                    rd.SetParameterValue("@enCode", Request.QueryString["enCode"]);
                    rd.SetParameterValue("Level3", Request.QueryString["Level3"]);
                    rd.SetParameterValue("Level1", Request.QueryString["Level1"]);
                    rd.SetParameterValue("Level2", Request.QueryString["Level2"]);
                    rd.SetParameterValue("Level4", Request.QueryString["Level4"]);
                    rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                    rd.SetParameterValue("@Book_ID", AppConfig.Book_ID);
                    if (Request.QueryString["HideZeroBalance"] != null && Convert.ToBoolean(Request.QueryString["HideZeroBalance"]))
                        rd.RecordSelectionFormula = "{@Closing}<>0.00";
                }
            }
            else if (reportName == "BalanceSheetComparison")
            {
                if (Request.QueryString["startDate"] != null && Request.QueryString["Level1"] != null
                  && Request.QueryString["Level2"] != null && Request.QueryString["Level3"] != null
                  && Request.QueryString["Level4"] != null && Request.QueryString["stCode"] != null
                  && Request.QueryString["enCode"] != null)
                {
                    reportPath += "GeneralLedger/rptBalanceSheetComparison.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("@start_date", Convert.ToDateTime(Request.QueryString["startDate"]));
                    rd.SetParameterValue("@ComparisonFrom", Convert.ToDateTime(Request.QueryString["ComarisonStartDate"]));
                    rd.SetParameterValue("@stCode", Request.QueryString["stCode"]);
                    rd.SetParameterValue("@enCode", Request.QueryString["enCode"]);
                    rd.SetParameterValue("Level3", Request.QueryString["Level3"]);
                    rd.SetParameterValue("Level1", Request.QueryString["Level1"]);
                    rd.SetParameterValue("Level2", Request.QueryString["Level2"]);
                    rd.SetParameterValue("Level4", Request.QueryString["Level4"]);
                    rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                    rd.SetParameterValue("@Book_ID", AppConfig.Book_ID);
                    string hideZeroBalanceQueryString = Request.QueryString["HideZeroBalance"];

                    if (!string.IsNullOrEmpty(hideZeroBalanceQueryString) && Convert.ToBoolean(hideZeroBalanceQueryString))
                    {
                        rd.RecordSelectionFormula = "{@CurrentClosing}<>0.00" + " OR {@Closing}<>0.00";
                    }

                }
            }
            else if (reportName == "ProfitLoss")
            {
                if (Request.QueryString["StartDate"] != null && Request.QueryString["EndDate"] != null)
                {
                    reportPath += "GeneralLedger/rptPL.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                    rd.SetParameterValue("@Book_ID", AppConfig.Book_ID);
                    rd.SetParameterValue("@StartDate", Convert.ToDateTime(Request.QueryString["StartDate"]));
                    rd.SetParameterValue("@EndDate", Convert.ToDateTime(Request.QueryString["EndDate"]));

                }
            }
            else if (reportName == "ProfitLossDetail")
            {
                if (Request.QueryString["startDate"] != null && Request.QueryString["Level1"] != null
                  && Request.QueryString["Level2"] != null && Request.QueryString["Level3"] != null
                  && Request.QueryString["Level4"] != null && Request.QueryString["stCode"] != null
                     && Request.QueryString["enCode"] != null && Request.QueryString["endDate"] != null)
                {
                    reportPath += "GeneralLedger/rptProfitLoss.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("@fromdate", Convert.ToDateTime(Request.QueryString["startDate"]));
                    rd.SetParameterValue("@todate", Convert.ToDateTime(Request.QueryString["endDate"]));
                    rd.SetParameterValue("Level3", Request.QueryString["Level3"]);
                    rd.SetParameterValue("Level1", Request.QueryString["Level1"]);
                    rd.SetParameterValue("Level2", Request.QueryString["Level2"]);
                    rd.SetParameterValue("Level4", Request.QueryString["Level4"]);
                    rd.SetParameterValue("@stCode", Request.QueryString["stCode"]);
                    rd.SetParameterValue("@enCode", Request.QueryString["enCode"]);
                    rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                    rd.SetParameterValue("@Book_ID", AppConfig.Book_ID);
                    if (Request.QueryString["HideZeroBalance"] != null && Convert.ToBoolean(Request.QueryString["HideZeroBalance"]))
                        rd.RecordSelectionFormula = "{@Closing}<>0.00";
                }
            }
            else if (reportName == "ProfitLossComparison")
            {
                if (Request.QueryString["Level1"] != null && Request.QueryString["Level2"] != null && Request.QueryString["Level3"] != null
                 && Request.QueryString["Level4"] != null && Request.QueryString["stCode"] != null && Request.QueryString["enCode"] != null
                 && Request.QueryString["startDate"] != null && Request.QueryString["endDate"] != null)
                {
                    reportPath += "GeneralLedger/rptProfitLossComparison.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("@fromdate", Convert.ToDateTime(Request.QueryString["startDate"]));
                    rd.SetParameterValue("@todate", Convert.ToDateTime(Request.QueryString["endDate"]));
                    rd.SetParameterValue("@ComparisonDateFrom", Convert.ToDateTime(Request.QueryString["ComarisonStartDate"]));
                    rd.SetParameterValue("@ComparisonDateTo", Convert.ToDateTime(Request.QueryString["ComparisonEndDate"]));
                    rd.SetParameterValue("Level3", Request.QueryString["Level3"]);
                    rd.SetParameterValue("Level1", Request.QueryString["Level1"]);
                    rd.SetParameterValue("Level2", Request.QueryString["Level2"]);
                    rd.SetParameterValue("Level4", Request.QueryString["Level4"]);
                    rd.SetParameterValue("@stCode", Request.QueryString["stCode"]);
                    rd.SetParameterValue("@enCode", Request.QueryString["enCode"]);
                    rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                    rd.SetParameterValue("@Book_ID", AppConfig.Book_ID);
                    if (Request.QueryString["HideZeroBalance"] != null && Convert.ToBoolean(Request.QueryString["HideZeroBalance"]))
                        rd.RecordSelectionFormula = "{@CurrentClosing}<>0.00";
                }
            }
            else if (reportName == "TrailComparison")
            {
                if (Request.QueryString["startDate"] != null && Request.QueryString["endDate"] != null)
                {
                    reportPath += "GeneralLedger/rptTrialComparison.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                    rd.SetParameterValue("@Book_ID", AppConfig.Book_ID);
                    rd.SetParameterValue("@fromdate", Convert.ToDateTime(Request.QueryString["startDate"]));
                    rd.SetParameterValue("@toDate", Convert.ToDateTime(Request.QueryString["endDate"]));

                }
            }
            else if (reportName == "MultiLedger")
            {
                if (Request.QueryString["startDate"] != null && Request.QueryString["endDate"] != null)
                {
                    reportPath += "GeneralLedger/rptMulti_Ledger.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                    rd.SetParameterValue("@Book_ID", AppConfig.Book_ID);
                    rd.SetParameterValue("@start_date", Convert.ToDateTime(Request.QueryString["startDate"]));
                    rd.SetParameterValue("@end_date", Convert.ToDateTime(Request.QueryString["endDate"]));
                    if (Request.QueryString["HideZeroBalance"] != null && Convert.ToBoolean(Request.QueryString["HideZeroBalance"]))
                        rd.RecordSelectionFormula = "{@Balance}<>0.00";

                }
            }
            else if (reportName == "VoucherEditList")
            {
                if (Request.QueryString["startDate"] != null && Request.QueryString["endDate"] != null)
                {
                    reportPath += "GeneralLedger/rptVoucherEditList.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                    rd.SetParameterValue("@Book_ID", AppConfig.Book_ID);
                    rd.SetParameterValue("@start_date", Convert.ToDateTime(Request.QueryString["startDate"]));
                    rd.SetParameterValue("@end_date", Convert.ToDateTime(Request.QueryString["endDate"]));
                }
            }
            else if (reportName == "TrailBalanceByDateCodeSelection")
            {
                if (Request.QueryString["startDate"] != null && Request.QueryString["Level1"] != null
                  && Request.QueryString["Level2"] != null && Request.QueryString["Level3"] != null
                  && Request.QueryString["Level4"] != null && Request.QueryString["stCode"] != null
                     && Request.QueryString["enCode"] != null && Request.QueryString["endDate"] != null)
                {
                    reportPath += "GeneralLedger/rptTrial_by_date_CodeLevelSelection.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("@fromdate", Convert.ToDateTime(Request.QueryString["startDate"]));
                    rd.SetParameterValue("@todate", Convert.ToDateTime(Request.QueryString["endDate"]));
                    rd.SetParameterValue("Level3", Request.QueryString["Level3"]);
                    rd.SetParameterValue("Level1", Request.QueryString["Level1"]);
                    rd.SetParameterValue("Level2", Request.QueryString["Level2"]);
                    rd.SetParameterValue("Level4", Request.QueryString["Level4"]);
                    rd.SetParameterValue("@stCode", Request.QueryString["stCode"]);
                    rd.SetParameterValue("@enCode", Request.QueryString["enCode"]);
                    rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                    rd.SetParameterValue("@Book_ID", AppConfig.Book_ID);
                    if (Request.QueryString["HideZeroBalance"] != null && Convert.ToBoolean(Request.QueryString["HideZeroBalance"]))
                        rd.RecordSelectionFormula = "{@TotalBalance}<>0.00";
                }
            }
            else if (reportName == "TrailForCostCenter")
            {
                if (Request.QueryString["startDate"] != null && Request.QueryString["endDate"] != null
                    && Request.QueryString["CostCenter"] != null && Request.QueryString["AllAccounts"] != null)
                {
                    reportPath += "GeneralLedger/rptTrialBalanceCostCenterWise.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("@fromdate", Convert.ToDateTime(Request.QueryString["startDate"]));
                    rd.SetParameterValue("@todate", Convert.ToDateTime(Request.QueryString["endDate"]));
                    rd.SetParameterValue("@CostCenter", Request.QueryString["CostCenter"]);
                    rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                    rd.SetParameterValue("@Book_ID", AppConfig.Book_ID);
                    rd.SetParameterValue("CostCenterName", Request.QueryString["CostCenterName"]);

                    if (Request.QueryString["AllAccounts"] != null && Request.QueryString["Account_Code"] != null)
                    {
                        rd.RecordSelectionFormula = "{Trial_Balance.Account_Code} =\"" + Request.QueryString["Account_Code"] + "\"";
                    }

                }
            }
            else if (reportName == "LedgerForCostCenter")
            {
                if (Request.QueryString["startDate"] != null && Request.QueryString["endDate"] != null
                    && Request.QueryString["CostCenter"] != null && Request.QueryString["AllAccounts"] != null)
                {
                    string DeptID = Request.QueryString["Department"].ToString();
                    string CostCenter = Request.QueryString["CostCenter"].ToString();
                    string CostCenterName = Request.QueryString["CostCenterName"].ToString();
                    reportPath += "GeneralLedger/rptLadgerCostCenter.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;

                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("@start_date", Convert.ToDateTime(Request.QueryString["startDate"]));
                    rd.SetParameterValue("@end_date", Convert.ToDateTime(Request.QueryString["endDate"]));
                    rd.SetParameterValue("@Cost_Center", CostCenter);
                    rd.SetParameterValue("@Dept_id", Convert.ToInt32(DeptID));
                    rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                    rd.SetParameterValue("@Book_ID", AppConfig.Book_ID);
                    rd.SetParameterValue("CostCenterName", CostCenterName);
                    if (!Convert.ToBoolean(Request.QueryString["AllAccounts"]) && Request.QueryString["Account_Code"] != null)
                    {
                        rd.RecordSelectionFormula = "{Ladger.Account_Code} =\"" + Request.QueryString["Account_Code"] + "\"";
                    }
                    if (Request.QueryString["HideZeroBalance"] != null && Convert.ToBoolean(Request.QueryString["HideZeroBalance"]))
                        rd.RecordSelectionFormula = "{@Total_Balance}<>0.00";
                }
            }
            else if (reportName == "VendorWiseLedger")
            {
                string rptFileName = "Purchase/rptNewVendorLedger.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("@startDate", Convert.ToDateTime(Request.QueryString["sDate"]));
                rd.SetParameterValue("@endDate", Convert.ToDateTime(Request.QueryString["eDate"]));
                rd.SetParameterValue("@VendorId", (Request.QueryString["Vendor"]).ToString());
            }
            else if (reportName == "Bill_Ledger_Report")
            {
                string stDate = Request.QueryString["StartDate"].ToString();
                string endDate = Request.QueryString["EndDate"].ToString();
                string rptTitle = Request.QueryString["ReportTitle"].ToString();
                reportPath += "Inventory/rptBillLedger.rpt";
                rd.Load(reportPath);
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("ReportTitle", rptTitle);
                rd.SetParameterValue("@StartDate", stDate);
                rd.SetParameterValue("@EndDate", endDate);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "PARLR")
            {
                reportPath += "Inventory/rptReorderLevel.rpt";
                rd.Load(reportPath);
                int Item_ID = Convert.ToInt16(Request.QueryString["Items"]);
                int accountCategory = Convert.ToInt16(Request.QueryString["AccountCategory"]);
                var warehouse = Request.QueryString["wareh"];

                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", Request.QueryString["ReportTitle"].ToString().Trim());
                rd.SetParameterValue("@itemID", Item_ID);
                rd.SetParameterValue("@AccountCategory_ID", accountCategory);
                rd.SetParameterValue("@warehouse", warehouse);
                if (Request.QueryString["HideZeroBalance"] != null && Convert.ToBoolean(Request.QueryString["HideZeroBalance"]))
                    rd.RecordSelectionFormula = "{@TotalBalance}<>0.00";
            }
            else if (reportName == "SaleSumaryItemWise")
            {
                string stitemcode = Request.QueryString["StartItemCode"].ToString();
                string enditemcode = Request.QueryString["EndItemCode"].ToString();
                long sitemCode = Convert.ToInt64(stitemcode);
                long eitemCode = Convert.ToInt64(enditemcode);
                string stDate = Request.QueryString["StartDate"].ToString();
                string endDate = Request.QueryString["EndDate"].ToString();
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                reportPath += "Inventory/rptSaleSumaryItemWise.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("@startDate", stDate);
                rd.SetParameterValue("@endDate", endDate);
                rd.SetParameterValue("@stItemCode", sitemCode);
                rd.SetParameterValue("@endItemCode", eitemCode);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }

            else if (reportName == "Inventory_StockLedger_Report")
            {
                string stitemcode = Request.QueryString["StartItemCode"].ToString();
                string enditemcode = Request.QueryString["EndItemCode"].ToString();
                string warehouse = Request.QueryString["WareHouse"].ToString();
                string itemCategory = Request.QueryString["Inventory_Org"].ToString();
                string department = Request.QueryString["Departemnt"].ToString();

                long sitemCode = Convert.ToInt64(stitemcode);
                long eitemCode = Convert.ToInt64(enditemcode);
                string stDate = Request.QueryString["StartDate"].ToString();

                string endDate = Request.QueryString["EndDate"].ToString();

                reportPath += "Inventory/rptStockLedgerWareHouseWiseNew.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("StartDate", stDate);
                rd.SetParameterValue("Enddate", endDate);
                rd.SetParameterValue("@stDate", stDate);
                rd.SetParameterValue("@endDate", endDate);
                rd.SetParameterValue("@stItemCode", sitemCode);
                rd.SetParameterValue("@endItemCode", eitemCode);
                rd.SetParameterValue("@Ware_House", warehouse);
                rd.SetParameterValue("@ItemCategory", itemCategory);


            }
            else if (reportName == "StockAdjustment")
            {
                DateTime StartDate = Convert.ToDateTime(Request.QueryString["startDate"]);
                DateTime EndDate = Convert.ToDateTime(Request.QueryString["endDate"]);
                string StartTimeStr = Convert.ToString(StartDate);
                string EndTimeStr = Convert.ToString(EndDate);
                string Reason = Request.QueryString["Department"].ToString();

                if (StartTimeStr == EndTimeStr)
                {
                    string datePart = EndTimeStr.Substring(0, EndTimeStr.IndexOf(" "));
                    EndTimeStr = datePart + " 11:59:59 PM";
                }
                else
                {
                    string datePart = EndTimeStr.Substring(0, EndTimeStr.IndexOf(" "));
                    EndTimeStr = datePart + " 11:59:59 PM";
                }
                reportPath += "Inventory/rptGetStockAdjusments.rpt";
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                rd.Load(reportPath);

                rd.SetParameterValue("@StartDate", StartDate);
                rd.SetParameterValue("@EndDate", EndTimeStr);

                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("ReportTitle", "Stock Adjustments Report");
                rd.SetParameterValue("sdate", StartDate);
                rd.SetParameterValue("edate", EndDate);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("@Reason", Reason);
                rd.SetParameterValue("@Warehouse", Request.QueryString["WareHouse"]);

            }
            else if (reportName == "SIH")
            {
                if (Request.QueryString["stock"] != null)
                {
                    string warehouse = Request.QueryString["WareHouse"].ToString();
                    var stock = Request.QueryString["stock"];
                    string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                    reportPath += "Inventory/rptStockInHand.rpt";
                    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                    rd.Load(reportPath);
                    rd.SetParameterValue("@Stock", stock);
                    rd.SetParameterValue("@WareHouse", warehouse);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", companyAddress);
                    rd.SetParameterValue("CompanyLogo", logoPath);
                }
            }
            else if (reportName == "Ledger")
            {
                if (Request.QueryString["startDate"] != null && Request.QueryString["endDate"] != null
                   && Request.QueryString["Account_ID"] != null)
                {
                    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                    var DeptID = Convert.ToInt32(Request.QueryString["DeptID"]);
                    reportPath += "GeneralLedger/rptLedger.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                    rd.SetParameterValue("@Book_ID", AppConfig.Book_ID);
                    rd.SetParameterValue("@account_id", Request.QueryString["Account_ID"]);
                    rd.SetParameterValue("@start_date", Convert.ToDateTime(Request.QueryString["startDate"]));
                    rd.SetParameterValue("@end_date", Convert.ToDateTime(Request.QueryString["endDate"]));
                    rd.SetParameterValue("@Dept_id", DeptID);
                    rd.SetParameterValue("CompanyLogo", logoPath);
                    if (Request.QueryString["HideZeroBalance"] != null && Convert.ToBoolean(Request.QueryString["HideZeroBalance"]))
                        rd.RecordSelectionFormula = "{@Total_Balance}<>0.00";

                }
            }
            else if (reportName == "GeneralLedger")
            {
                if (Request.QueryString["startDate"] != null && Request.QueryString["endDate"] != null
                   && Request.QueryString["Account_ID"] != null)

                {
                    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                    reportPath += "GeneralLedger/rptGeneralLedger.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                    rd.SetParameterValue("@Book_ID", AppConfig.Book_ID);
                    rd.SetParameterValue("@account_id", Request.QueryString["Account_ID"]);
                    rd.SetParameterValue("@start_date", Convert.ToDateTime(Request.QueryString["startDate"]));
                    rd.SetParameterValue("@end_date", Convert.ToDateTime(Request.QueryString["endDate"]));
                    rd.SetParameterValue("CompanyLogo", logoPath);

                }
            }

            else if (reportName == "ChartOfAccount")
            {
                if (Request.QueryString["Level1"] != null && Request.QueryString["Level2"] != null
                     && Request.QueryString["Level3"] != null && Request.QueryString["Level4"] != null)
                {
                    reportPath += "GeneralLedger/rptChartOfAccount.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;

                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Level3", Request.QueryString["Level3"]);
                    rd.SetParameterValue("Level1", Request.QueryString["Level1"]);
                    rd.SetParameterValue("Level2", Request.QueryString["Level2"]);
                    rd.SetParameterValue("Level4", Request.QueryString["Level4"]);
                    rd.SetParameterValue("@Book_ID", AppConfig.Book_ID);
                }
            }
            else if (reportName == "TrailByDate")
            {
                if (Request.QueryString["startDate"] != null && Request.QueryString["endDate"] != null)
                {
                    reportPath += "GeneralLedger/rptTrial_by_date.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);

                    rd.SetParameterValue("@start_date", Convert.ToDateTime(Request.QueryString["startDate"]));
                    rd.SetParameterValue("@end_date", Convert.ToDateTime(Request.QueryString["endDate"]));

                    rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                    rd.SetParameterValue("@Book_ID", AppConfig.Book_ID);
                }
            }
            else if (reportName == "TrailBalanceAt")
            {
                if (Request.QueryString["startDate"] != null && Request.QueryString["Level1"] != null
                  && Request.QueryString["Level2"] != null && Request.QueryString["Level3"] != null
                  && Request.QueryString["Level4"] != null)
                {
                    reportPath += "GeneralLedger/rptTrialBalance.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);

                    rd.SetParameterValue("@start_date", Convert.ToDateTime(Request.QueryString["startDate"]));
                    rd.SetParameterValue("@end_date", Convert.ToDateTime(Request.QueryString["startDate"]));

                    rd.SetParameterValue("Level3", Request.QueryString["Level3"]);
                    rd.SetParameterValue("Level1", Request.QueryString["Level1"]);
                    rd.SetParameterValue("Level2", Request.QueryString["Level2"]);
                    rd.SetParameterValue("Level4", Request.QueryString["Level4"]);
                    rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                    rd.SetParameterValue("@Book_ID", AppConfig.Book_ID);
                }
            }
            #endregion
            #region Patient Management
            else if (reportName == "PatientSlip")
            {
                reportPath += "PatientManagement/rptPatientSlip1.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", "OPD Slip");
                rd.SetParameterValue("@Patient_ID", Convert.ToInt32(Request.QueryString["Patient_ID"]));
            }
            else if (reportName == "PharmacySlip")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                reportPath += "PatientManagement/rptPharmacySlip.rpt";
                rd.Load(reportPath);
                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Address", companyAddress);
                rd.SetParameterValue("@BillId", Convert.ToInt32(Request.QueryString["Bill_ID"]));
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "PharmacyReturnSlip")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                reportPath += "PatientManagement/rptPharmacyReturnSlip.rpt";
                rd.Load(reportPath);
                string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Address", companyAddress);
                rd.SetParameterValue("@ReturnId", Convert.ToInt32(Request.QueryString["Return_ID"]));
                rd.SetParameterValue("CompanyLogo", logoPath);

            }
            //    else if (reportName == "BillingBaseReport")
            //    {

            //        // string qrPath = DBClass.getField($"SELECT QR_Code_Path FROM reg_patient WHERE pat_id = {Request.QueryString["Patient_ID"]}");
            //        var billId = Convert.ToInt32(Request.QueryString["Bill_ID"]);

            //        var user_id = AppConfig.UserID;
            //        var userName = DBClass.getField($"SELECT dbo.getUserName('{user_id}')");

            //        reportPath += "PatientManagement/rptBillBasePrintHalf.rpt";
            //        var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

            //        rd.Load(reportPath);
            //        rd.SetParameterValue("@Bill_Id", billId);
            //        rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);
            //        rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
            //        rd.SetParameterValue("CompanyLogo", logoPath);
            //        rd.SetParameterValue("UserName", userName);
            ////        rd.SetParameterValue("QrCode", qrPath);
            //    }

            else if (reportName == "BillingBaseReport")
            {
                var billId = Convert.ToInt32(Request.QueryString["Bill_ID"]);
                var user_id = AppConfig.UserID;
                var userName = DBClass.getField($"SELECT dbo.getUserName('{user_id}')");
                reportPath += "PatientManagement/rptBillBasePrintHalf.rpt";
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                rd.Load(reportPath);
                
                try
                {
                    int isDuplicate = 0;
                    if (Request.QueryString["IsDuplicate"] != null)
                    {
                        int.TryParse(Request.QueryString["IsDuplicate"], out isDuplicate);
                    }
                    rd.SetParameterValue("IsDuplicate", isDuplicate);
                }
                catch { }
                try
                {
                    rd.SetParameterValue("@Bill_ID", billId, rd.Subreports[0].Name.ToString());
                }
                catch
                {
                    // Subreport parameter doesn't exist on this report variant - ignore silently
                }
                rd.SetParameterValue("@Bill_Id", billId);
                rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("UserName", userName);

                try
                {
                    string sql = $@"
        SELECT ISNULL(rp.mr_no_sequence, '') AS mr_no_sequence,
               ISNULL(rp.Full_Name, '') AS Full_Name,
               ISNULL(CONVERT(VARCHAR, rp.Age_years), '') AS Age_years,
               ISNULL(rp.Gender, '') AS Gender
        FROM ar_billings ab 
        JOIN Reg_patient rp ON ab.patient_id = rp.pat_id
        WHERE ab.bill_id = {billId}";

                    DataTable patientData = DBClass.getDataTable(sql);

                    if (patientData.Rows.Count > 0)
                    {
                        string qrContent = $"MR:{patientData.Rows[0]["mr_no_sequence"]}|Name:{patientData.Rows[0]["Full_Name"]}|Age:{patientData.Rows[0]["Age_years"]}|Gender:{patientData.Rows[0]["Gender"]}";

                        // Save to temp file instead of passing bytes
                        string tempQrPath = Path.Combine(Path.GetTempPath(), $"QR_{billId}_{Guid.NewGuid()}.png");

                        using (QRCodeGenerator qrGenerator = new QRCodeGenerator())
                        {
                            QRCodeData qrCodeData = qrGenerator.CreateQrCode(qrContent, QRCodeGenerator.ECCLevel.Q);
                            using (PngByteQRCode qrCodeImage = new PngByteQRCode(qrCodeData))
                            {
                                byte[] qrBytes = qrCodeImage.GetGraphic(10);
                                File.WriteAllBytes(tempQrPath, qrBytes);
                            }
                        }

                        // Pass FILE PATH as string parameter
                        rd.SetParameterValue("QRImagePath", tempQrPath);
                    }
                    else
                    {
                        rd.SetParameterValue("QRImagePath", "");
                    }
                }
                catch (Exception ex)
                {
                    rd.SetParameterValue("QRImagePath", "");
                }
            }
            else if (reportName == "CathLabBillingBasePrint")
            {
                var billId = Convert.ToInt32(Request.QueryString["Bill_ID"]);
                var user_id = AppConfig.UserID;
                var userName = DBClass.getField($"SELECT dbo.getUserName('{user_id}')");
                reportPath += "PatientManagement/rptCathLabBasePrint.rpt";
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                rd.Load(reportPath);
                rd.SetParameterValue("@Bill_Id", billId);
                rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("UserName", userName);

                try
                {
                    string sql = $@"
        SELECT ISNULL(rp.mr_no_sequence, '') AS mr_no_sequence,
               ISNULL(rp.Full_Name, '') AS Full_Name,
               ISNULL(CONVERT(VARCHAR, rp.Age_years), '') AS Age_years,
               ISNULL(rp.Gender, '') AS Gender
        FROM ar_billings ab 
        JOIN Reg_patient rp ON ab.patient_id = rp.pat_id
        WHERE ab.bill_id = {billId}";

                    DataTable patientData = DBClass.getDataTable(sql);

                    if (patientData.Rows.Count > 0)
                    {
                        string qrContent = $"MR:{patientData.Rows[0]["mr_no_sequence"]}|Name:{patientData.Rows[0]["Full_Name"]}|Age:{patientData.Rows[0]["Age_years"]}|Gender:{patientData.Rows[0]["Gender"]}";

                        // Save to temp file instead of passing bytes
                        string tempQrPath = Path.Combine(Path.GetTempPath(), $"QR_{billId}_{Guid.NewGuid()}.png");

                        using (QRCodeGenerator qrGenerator = new QRCodeGenerator())
                        {
                            QRCodeData qrCodeData = qrGenerator.CreateQrCode(qrContent, QRCodeGenerator.ECCLevel.Q);
                            using (PngByteQRCode qrCodeImage = new PngByteQRCode(qrCodeData))
                            {
                                byte[] qrBytes = qrCodeImage.GetGraphic(10);
                                File.WriteAllBytes(tempQrPath, qrBytes);
                            }
                        }

                        // Pass FILE PATH as string parameter
                        rd.SetParameterValue("QRImagePath", tempQrPath);
                    }
                    else
                    {
                        rd.SetParameterValue("QRImagePath", "");
                    }
                }
                catch (Exception ex)
                {
                    rd.SetParameterValue("QRImagePath", "");
                }
            }
            else if (reportName == "CathLabSaleReturnPrint")
            {
                var Return_ID = Request.QueryString["Return_ID"].ToString();
                var user_id = AppConfig.UserID;
                var userName = DBClass.getField($"SELECT dbo.getUserName('{user_id}')");
                reportPath += "PatientManagement/rptCathLabReturnSlipPrint.rpt";
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                rd.Load(reportPath);
                rd.SetParameterValue("@ReturnId", Return_ID);
                rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("UserName", userName);

                try
                {
                    string sql = $@"
        SELECT ISNULL(rp.mr_no_sequence, '') AS mr_no_sequence,
               ISNULL(rp.Full_Name, '') AS Full_Name,
               ISNULL(CONVERT(VARCHAR, rp.Age_years), '') AS Age_years,
               ISNULL(rp.Gender, '') AS Gender
        FROM Pharmacy_SaleReturns ps 
        JOIN Reg_patient rp ON ps.patient_id = rp.pat_id
        WHERE ps.Return_ID = {Return_ID}";

                    DataTable patientData = DBClass.getDataTable(sql);

                    if (patientData.Rows.Count > 0)
                    {
                        string qrContent = $"MR:{patientData.Rows[0]["mr_no_sequence"]}|Name:{patientData.Rows[0]["Full_Name"]}|Age:{patientData.Rows[0]["Age_years"]}|Gender:{patientData.Rows[0]["Gender"]}";

                        // Save to temp file instead of passing bytes
                        string tempQrPath = Path.Combine(Path.GetTempPath(), $"QR_{Return_ID}_{Guid.NewGuid()}.png");

                        using (QRCodeGenerator qrGenerator = new QRCodeGenerator())
                        {
                            QRCodeData qrCodeData = qrGenerator.CreateQrCode(qrContent, QRCodeGenerator.ECCLevel.Q);
                            using (PngByteQRCode qrCodeImage = new PngByteQRCode(qrCodeData))
                            {
                                byte[] qrBytes = qrCodeImage.GetGraphic(10);
                                File.WriteAllBytes(tempQrPath, qrBytes);
                            }
                        }

                        // Pass FILE PATH as string parameter
                        rd.SetParameterValue("QRImagePath", tempQrPath);
                    }
                    else
                    {
                        rd.SetParameterValue("QRImagePath", "");
                    }
                }
                catch (Exception ex)
                {
                    rd.SetParameterValue("QRImagePath", "");
                }
            }
            else if (reportName == "IPD_Distribution_Bill_Print")
            {
                var Bill_ID = Convert.ToInt32(Request.QueryString["Bill_ID"]);
                var user_id = AppConfig.UserID;
                var userName = DBClass.getField($"SELECT dbo.getUserName('{user_id}')");
                reportPath += "Inpatient/rptIPD_Distribution_Bill_Print.rpt";
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                rd.Load(reportPath);
                rd.SetParameterValue("@Bill_ID", Bill_ID);
                rd.SetParameterValue("@Bill_ID", Convert.ToInt32(Bill_ID), rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@Bill_ID", Convert.ToInt32(Bill_ID), rd.Subreports[1].Name.ToString());
                rd.SetParameterValue("@Bill_ID", Convert.ToInt32(Bill_ID), rd.Subreports[2].Name.ToString());
                rd.SetParameterValue("@Bill_ID", Convert.ToInt32(Bill_ID), rd.Subreports[3].Name.ToString());
                rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("UserName", userName);

                try
                {
                    string sql = $@"
        SELECT ISNULL(rp.mr_no_sequence, '') AS mr_no_sequence,
               ISNULL(rp.Full_Name, '') AS Full_Name,
               ISNULL(CONVERT(VARCHAR, rp.Age_years), '') AS Age_years,
               ISNULL(rp.Gender, '') AS Gender
        FROM ar_billings ab 
        JOIN Reg_patient rp ON ab.patient_id = rp.pat_id
        WHERE ab.bill_id = {Bill_ID}";

                    DataTable patientData = DBClass.getDataTable(sql);

                    if (patientData.Rows.Count > 0)
                    {
                        string qrContent = $"MR:{patientData.Rows[0]["mr_no_sequence"]}|Name:{patientData.Rows[0]["Full_Name"]}|Age:{patientData.Rows[0]["Age_years"]}|Gender:{patientData.Rows[0]["Gender"]}";

                        // Save to temp file instead of passing bytes
                        string tempQrPath = Path.Combine(Path.GetTempPath(), $"QR_{Bill_ID}_{Guid.NewGuid()}.png");

                        using (QRCodeGenerator qrGenerator = new QRCodeGenerator())
                        {
                            QRCodeData qrCodeData = qrGenerator.CreateQrCode(qrContent, QRCodeGenerator.ECCLevel.Q);
                            using (PngByteQRCode qrCodeImage = new PngByteQRCode(qrCodeData))
                            {
                                byte[] qrBytes = qrCodeImage.GetGraphic(10);
                                File.WriteAllBytes(tempQrPath, qrBytes);
                            }
                        }

                        // Pass FILE PATH as string parameter
                        rd.SetParameterValue("QRImagePath", tempQrPath);
                    }
                    else
                    {
                        rd.SetParameterValue("QRImagePath", "");
                    }
                }
                catch (Exception ex)
                {
                    rd.SetParameterValue("QRImagePath", "");
                }
            }
            else if (reportName == "BillingBaseReport_Thermal")
            {
                var billId = Convert.ToInt32(Request.QueryString["Bill_ID"]);
                var user_id = AppConfig.UserID;
                var userName = DBClass.getField($"SELECT dbo.getUserName('{user_id}')");
                reportPath += "PatientManagement/rptBillBasePrintHalf(thermal).rpt";
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                rd.Load(reportPath);
                rd.SetParameterValue("@Bill_Id", billId);
                rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("UserName", userName);

                try
                {
                    string sql = $@"
        SELECT ISNULL(rp.mr_no_sequence, '') AS mr_no_sequence,
               ISNULL(rp.Full_Name, '') AS Full_Name,
               ISNULL(CONVERT(VARCHAR, rp.Age_years), '') AS Age_years,
               ISNULL(rp.Gender, '') AS Gender
        FROM ar_billings ab 
        JOIN Reg_patient rp ON ab.patient_id = rp.pat_id
        WHERE ab.bill_id = {billId}";

                    DataTable patientData = DBClass.getDataTable(sql);

                    if (patientData.Rows.Count > 0)
                    {
                        string qrContent = $"MR:{patientData.Rows[0]["mr_no_sequence"]}|Name:{patientData.Rows[0]["Full_Name"]}|Age:{patientData.Rows[0]["Age_years"]}|Gender:{patientData.Rows[0]["Gender"]}";

                        // Save to temp file instead of passing bytes
                        string tempQrPath = Path.Combine(Path.GetTempPath(), $"QR_{billId}_{Guid.NewGuid()}.png");

                        using (QRCodeGenerator qrGenerator = new QRCodeGenerator())
                        {
                            QRCodeData qrCodeData = qrGenerator.CreateQrCode(qrContent, QRCodeGenerator.ECCLevel.Q);
                            using (PngByteQRCode qrCodeImage = new PngByteQRCode(qrCodeData))
                            {
                                byte[] qrBytes = qrCodeImage.GetGraphic(10);
                                File.WriteAllBytes(tempQrPath, qrBytes);
                            }
                        }

                        // Pass FILE PATH as string parameter
                        rd.SetParameterValue("QRImagePath", tempQrPath);
                    }
                    else
                    {
                        rd.SetParameterValue("QRImagePath", "");
                    }
                }
                catch (Exception ex)
                {
                    rd.SetParameterValue("QRImagePath", "");
                }
            }

            else if (reportName == "ReceiptbasePrint")
            {
                try
                {
                    reportPath += "PatientManagement/rptReceiptBase.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    string companyAddress = DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + "");
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("Address", companyAddress);
                    rd.SetParameterValue("@Receipt_ID", Request.QueryString["Receipt_ID"]);
                }
                catch (Exception ex)
                {
                    throw;
                }
            }
            //else if (reportName == "BillingBaseReport_Consultant")
            //{
            //    var billId = Convert.ToInt32(Request.QueryString["Bill_ID"]);
            //    string doctorId = Request.QueryString["Doctor_ID"];
            //    var user_id = AppConfig.UserID;
            //    var userName = DBClass.getField($"SELECT dbo.getUserName('{user_id}')");
            //    reportPath += "Billings/rptBillBasePrintHalf_Consultant.rpt";
            //    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
            //    rd.Load(reportPath);
            //    rd.SetParameterValue("@Bill_Id", billId);
            //    if (string.IsNullOrEmpty(doctorId))
            //        cmd.Parameters.AddWithValue("@Doctor_ID", DBNull.Value);
            //    else
            //        cmd.Parameters.AddWithValue("@Doctor_ID", int.Parse(doctorId));
            //    rd.SetParameterValue("@Doctor_ID", doctorId);
            //    rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);
            //    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
            //    rd.SetParameterValue("CompanyLogo", logoPath);
            //    rd.SetParameterValue("UserName", userName);
            //}

            // correct one is below


            //else if (reportName == "BillingBaseReport_Consultant" ||reportName == "BillingBaseReport_Hospital_Services")
            //{

            //    //string reportName = Request.QueryString["ReportName"];
            //    string billId = Request.QueryString["Bill_ID"];
            //    string doctorId = Request.QueryString["Doctor_ID"]; // null if not passed

            //    var user_id = AppConfig.UserID;
            //    var userName = DBClass.getField($"SELECT dbo.getUserName('{user_id}')");
            //    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

            //    ReportDocument report = new ReportDocument();

            //    if (reportName == "BillingBaseReport_Consultant")
            //    {
            //        // Has Doctor_ID → Consultant report
            //        report.Load(Server.MapPath("~/Reports/Billings/rptBillBasePrintHalf_Consultant.rpt"));
            //    }
            //    else if (reportName == "BillingBaseReport_Hospital_Services")
            //    {
            //        // No Doctor_ID → Hospital Services report
            //        report.Load(Server.MapPath("~/Reports/Billings/rptBillBasePrintHalf_Hospital.rpt"));
            //    }
            //    reportPath += "Billings/rptBillBasePrintHalf_Hospital.rpt";


            //    rd.Load(reportPath);



            //    rd.SetParameterValue("@Bill_Id", billId);
            //    rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);

            //    // Fix: Handle Doctor_ID correctly for Crystal Reports
            //    if (string.IsNullOrEmpty(doctorId))
            //        rd.SetParameterValue("@Doctor_ID", DBNull.Value);
            //    else
            //        rd.SetParameterValue("@Doctor_ID", Convert.ToInt32(doctorId));

            //    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
            //    rd.SetParameterValue("CompanyLogo", logoPath);
            //    rd.SetParameterValue("UserName", userName);
            //}

            else if (reportName == "BillingBaseReport_Consultant" || reportName == "BillingBaseReport_Hospital_Services")
            {
                string billId = Request.QueryString["Bill_ID"];
                string doctorId = Request.QueryString["Doctor_ID"]; // may be null

                var user_id = AppConfig.UserID;
                var userName = DBClass.getField($"SELECT dbo.getUserName('{user_id}')");
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                if (!string.IsNullOrEmpty(doctorId))
                {
                    rd.Load(Server.MapPath("~/Reports/Billings/rptBillBasePrintHalf_Consultant.rpt"));
                }
                else
                {
                    rd.Load(Server.MapPath("~/Reports/Billings/rptBillBasePrintHalf_Hospital.rpt"));
                }
                rd.SetParameterValue("@Bill_Id", billId);
                rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);

                if (string.IsNullOrEmpty(doctorId))
                    rd.SetParameterValue("@Doctor_ID", DBNull.Value);
                else
                    rd.SetParameterValue("@Doctor_ID", Convert.ToInt32(doctorId));

                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("UserName", userName);
            }

            #endregion
            #region Lab/Radiology
            else if (reportName == "TestResultQ")
            {
                int reportColumns = Convert.ToInt32(Request.QueryString["ReportColumn"]);
                int reportcolumntest = reportColumns;
                if (reportColumns == 2)
                {
                    reportPath += "LabRadiology/rptLabTestResultQ_2.rpt";
                }
                else if (reportColumns == 3)
                {

                    reportPath += "LabRadiology/rptLabTestResultQ_3.rpt";
                }
                else if (reportColumns == 4)
                {

                    reportPath += "LabRadiology/rptLabTestResultQ.rpt";
                }
                else if (reportColumns == 5)
                {

                    reportPath += "LabRadiology/rptLabTestResultQ_6.rpt";

                }

                else if (reportColumns == 6)
                {
                    reportPath += "LabRadiology/rptLabTestResultQ_5.rpt";

                }
                else if (reportColumns == 7)
                {
                    reportPath += "LabRadiology/rptLabResult_Organism.rpt";

                }
                else if (reportColumns == 8)
                {
                    reportPath += "LabRadiology/rptLabTestUiltraSound_1.rpt";

                }

                else if (reportColumns == 9)
                {
                    reportPath += "LabRadiology/rptLabTestResultQ_8.rpt";

                }
                else if (reportColumns == 10)
                {
                    reportPath += "LabRadiology/rptLabTestBloodBankResultQ.rpt";
                }
                else if (reportColumns == 11)
                {
                    reportPath += "LabRadiology/rptLabTestResultQ_Fixed_Patient_Value.rpt";
                }
                else if (reportColumns == 12)
                {
                    reportPath += "LabRadiology/rptLabTestHistopathology.rpt";

                }
                else if (reportColumns == 13)
                {
                    reportPath += "LabRadiology/rptLabTestRadiology_Xray.rpt";

                }
                else if (reportColumns == 14)
                {
                    reportPath += "LabRadiology/rptLabTestRadiology_CTScan.rpt";

                }
                else if (reportColumns == 15)
                {
                    reportPath += "LabRadiology/rptLabTestRadiology_MRI.rpt";

                }
                else if (reportColumns == 16)
                {
                    reportPath += "LabRadiology/rptLabTestResultQ_Cardio.rpt";

                }
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                string list = string.Empty;
                list = Request.QueryString["Test_IDs"].ToString();
                string transID = string.Empty;
                transID = Request.QueryString["TransID"].ToString();
                string BillDetailsID = string.Empty;
                BillDetailsID = Request.QueryString["BillDetailID"].ToString();

                rd.SetParameterValue("@Test_IDs", list);
                rd.SetParameterValue("@Patient_ID", Request.QueryString["test_wise_ids"]);
                rd.SetParameterValue("@Trans_IDs", transID);
                rd.SetParameterValue("@Bill_Details_IDs", BillDetailsID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
                rd.SetParameterValue("Phone", DBClass.getField("select Company_Phone1 from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
                if (reportColumns == 7)
                {
                    string labTestDetailId = string.Empty;
                    labTestDetailId = Request.QueryString["labTDetailsID"];
                    if (labTestDetailId == "null")
                    {
                        //incase report is 7th but in Group
                        labTestDetailId = "1";
                    }
                    rd.SetParameterValue("@labTDetailsID", labTestDetailId);
                }
            }
            #endregion
            #region Accounts
            else if (reportName == "Voucher_GL")
            {
                if (Request.QueryString["Voucher_ID"] != null)
                {
                    reportPath += "Accounts/rptVoucher.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    var coucherID = Convert.ToInt32(Request.QueryString["Voucher_ID"]);
                    rd.SetParameterValue("@Voucher_ID", coucherID);
                }
            }
            #endregion
            #region Inventory Module Reports
            else if (reportName == "ItemList")
            {
                reportPath += "Inventory/rptItemsListing.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("@Inventory_Org", Request.QueryString["Inventory_Org"].ToString());
                rd.SetParameterValue("@Item_Group", Request.QueryString["Item_Group"].ToString());
                rd.SetParameterValue("@Item_Type", Request.QueryString["Item_Type"].ToString());
                rd.SetParameterValue("@Item_Category", Request.QueryString["Item_Category"].ToString());
                rd.SetParameterValue("@Procedure_Type", Request.QueryString["Procedure_Type"].ToString());
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", Request.QueryString["ReportTitle"].ToString().Trim());
            }
            else if (reportName == "ItemWosePOSummary")
            {
                reportPath += "Inventory/rpPOSummaryItemWise.rpt";
                rd.Load(reportPath);
                DateTime stDate = Convert.ToDateTime(Request.QueryString["sDate"]);
                DateTime endDate = Convert.ToDateTime(Request.QueryString["eDate"]);
                string vendorID = Request.QueryString["Vendor_ID"].ToString();
                int Item_ID = Convert.ToInt16(Request.QueryString["Items"]);
                string ItemGruop = Request.QueryString["ItemGroup"].ToString();

                rd.SetParameterValue("@stDate", stDate);
                rd.SetParameterValue("@endDate", endDate);
                rd.SetParameterValue("@Vendor_ID", Convert.ToInt32(vendorID));

                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", Request.QueryString["ReportTitle"].ToString().Trim());
                rd.SetParameterValue("@Item_ID", Item_ID);
                rd.SetParameterValue("@Item_Group", ItemGruop);
            }
            else if (reportName == "VendorWisePOSummary")
            {
                reportPath += "Inventory/rptPOSummaryVendorWise.rpt";
                rd.Load(reportPath);
                string vendorID = Request.QueryString["Vendor_ID"].ToString();
                rd.SetParameterValue("@Vendor_ID", Convert.ToInt32(vendorID));
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", Request.QueryString["ReportTitle"].ToString().Trim());
            }
            else if (reportName == "VendorWiseIGPS")
            {
                reportPath += "Inventory/rptIGP_Summary.rpt";
                rd.Load(reportPath);
                DateTime stDate = Convert.ToDateTime(Request.QueryString["startDate"]);
                DateTime endDate = Convert.ToDateTime(Request.QueryString["endDate"]);
                string vendorID = Request.QueryString["Vendor_ID"].ToString();
                rd.SetParameterValue("@stDate", stDate);
                rd.SetParameterValue("@endDate", endDate);
                rd.SetParameterValue("@Vendor_ID", vendorID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", Request.QueryString["ReportTitle"].ToString().Trim());
            }
            else if (reportName == "VendorDetailsGRNS")
            {
                reportPath += "Inventory/rptGOOD_Recipt_Summary_GRN.rpt";
                rd.Load(reportPath);
                DateTime stDate = Convert.ToDateTime(Request.QueryString["startDate"]);
                DateTime endDate = Convert.ToDateTime(Request.QueryString["endDate"]);
                string vendorID = Request.QueryString["Vendor_ID"].ToString();
                rd.SetParameterValue("@stDate", stDate);
                rd.SetParameterValue("@endDate", endDate);
                rd.SetParameterValue("@Vendor_ID", Convert.ToInt32(vendorID));
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", Request.QueryString["ReportTitle"].ToString().Trim());
            }
            else if (reportName == "GRN_and_Item_Wise_Report")
            {
                string rptFileName = "Inventory/rptGRN_Wise_Report.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("@GRN_Num", (Request.QueryString["DepetID"]).ToString());
                //Mohsin
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                //Mohsin
            }
            #endregion
            #region In Patient Report
            else if (reportName == "In_Patient_History")
            {
                var in_patient_id = Request.QueryString["In_Patient_ID"].ToString();
                reportPath += "InPatient/rpt_In_Patient_ID_History.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
                rd.SetParameterValue("@In_Patient_ID", in_patient_id);
                try
                {
                    string sql = $@"
                        SELECT ISNULL(rp.mr_no_sequence, '') AS mr_no_sequence,
                                      ISNULL(rp.Full_Name, '') AS Full_Name,
                                      ISNULL(CONVERT(VARCHAR, rp.Age_years), '') AS Age_years,
                                      ISNULL(rp.Gender, '') AS Gender
                               FROM Reg_patient rp
                               JOIN in_patient ip ON ip.patient_id = rp.pat_id
                               WHERE ip.In_Patient_ID = {in_patient_id}";

                    DataTable patientData = DBClass.getDataTable(sql);

                    if (patientData.Rows.Count > 0)
                    {
                        string qrContent = $"MR:{patientData.Rows[0]["mr_no_sequence"]}|Name:{patientData.Rows[0]["Full_Name"]}|Age:{patientData.Rows[0]["Age_years"]}|Gender:{patientData.Rows[0]["Gender"]}";

                        // Save to temp file instead of passing bytes
                        string tempQrPath = Path.Combine(Path.GetTempPath(), $"QR_{in_patient_id}_{Guid.NewGuid()}.png");

                        using (QRCodeGenerator qrGenerator = new QRCodeGenerator())
                        {
                            QRCodeData qrCodeData = qrGenerator.CreateQrCode(qrContent, QRCodeGenerator.ECCLevel.Q);
                            using (PngByteQRCode qrCodeImage = new PngByteQRCode(qrCodeData))
                            {
                                byte[] qrBytes = qrCodeImage.GetGraphic(10);
                                File.WriteAllBytes(tempQrPath, qrBytes);
                            }
                        }

                        // Pass FILE PATH as string parameter
                        rd.SetParameterValue("QRImagePath", tempQrPath);
                    }
                    else
                    {
                        rd.SetParameterValue("QRImagePath", "");
                    }
                }
                catch (Exception ex)
                {
                    rd.SetParameterValue("QRImagePath", "");
                }


            }
            else if (reportName == "Medication")
            {
                var in_patient_id = Request.QueryString["In_Patient_ID"].ToString();
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                reportPath += "InPatient/rpt_GetIn_Patient_ID_Medication.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
                rd.SetParameterValue("@In_Patient_ID", in_patient_id);
                rd.SetParameterValue("CompanyLogo", logoPath);
                try
                {
                    string sql = $@"
                        SELECT ISNULL(rp.mr_no_sequence, '') AS mr_no_sequence,
                                      ISNULL(rp.Full_Name, '') AS Full_Name,
                                      ISNULL(CONVERT(VARCHAR, rp.Age_years), '') AS Age_years,
                                      ISNULL(rp.Gender, '') AS Gender
                               FROM Reg_patient rp
                               JOIN in_patient ip ON ip.patient_id = rp.pat_id
                               WHERE ip.In_Patient_ID = {in_patient_id}";

                    DataTable patientData = DBClass.getDataTable(sql);

                    if (patientData.Rows.Count > 0)
                    {
                        string qrContent = $"MR:{patientData.Rows[0]["mr_no_sequence"]}|Name:{patientData.Rows[0]["Full_Name"]}|Age:{patientData.Rows[0]["Age_years"]}|Gender:{patientData.Rows[0]["Gender"]}";

                        // Save to temp file instead of passing bytes
                        string tempQrPath = Path.Combine(Path.GetTempPath(), $"QR_{in_patient_id}_{Guid.NewGuid()}.png");

                        using (QRCodeGenerator qrGenerator = new QRCodeGenerator())
                        {
                            QRCodeData qrCodeData = qrGenerator.CreateQrCode(qrContent, QRCodeGenerator.ECCLevel.Q);
                            using (PngByteQRCode qrCodeImage = new PngByteQRCode(qrCodeData))
                            {
                                byte[] qrBytes = qrCodeImage.GetGraphic(10);
                                File.WriteAllBytes(tempQrPath, qrBytes);
                            }
                        }

                        // Pass FILE PATH as string parameter
                        rd.SetParameterValue("QRImagePath", tempQrPath);
                    }
                    else
                    {
                        rd.SetParameterValue("QRImagePath", "");
                    }
                }
                catch (Exception ex)
                {
                    rd.SetParameterValue("QRImagePath", "");
                }


            }
            else if (reportName == "InPatientMonitoring")
            {

                var in_patient_id = Request.QueryString["In_Patient_ID"].ToString();
                reportPath += "InPatient/rpt_In_Patient_ID_Nursing_Plan.rpt";
                rd.Load(reportPath);
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
                rd.SetParameterValue("@In_Patient_ID", in_patient_id);
                try
                {
                    string sql = $@"
                        SELECT ISNULL(rp.mr_no_sequence, '') AS mr_no_sequence,
                                      ISNULL(rp.Full_Name, '') AS Full_Name,
                                      ISNULL(CONVERT(VARCHAR, rp.Age_years), '') AS Age_years,
                                      ISNULL(rp.Gender, '') AS Gender
                               FROM Reg_patient rp
                               JOIN in_patient ip ON ip.patient_id = rp.pat_id
                               WHERE ip.In_Patient_ID = {in_patient_id}";

                    DataTable patientData = DBClass.getDataTable(sql);

                    if (patientData.Rows.Count > 0)
                    {
                        string qrContent = $"MR:{patientData.Rows[0]["mr_no_sequence"]}|Name:{patientData.Rows[0]["Full_Name"]}|Age:{patientData.Rows[0]["Age_years"]}|Gender:{patientData.Rows[0]["Gender"]}";

                        // Save to temp file instead of passing bytes
                        string tempQrPath = Path.Combine(Path.GetTempPath(), $"QR_{in_patient_id}_{Guid.NewGuid()}.png");

                        using (QRCodeGenerator qrGenerator = new QRCodeGenerator())
                        {
                            QRCodeData qrCodeData = qrGenerator.CreateQrCode(qrContent, QRCodeGenerator.ECCLevel.Q);
                            using (PngByteQRCode qrCodeImage = new PngByteQRCode(qrCodeData))
                            {
                                byte[] qrBytes = qrCodeImage.GetGraphic(10);
                                File.WriteAllBytes(tempQrPath, qrBytes);
                            }
                        }

                        // Pass FILE PATH as string parameter
                        rd.SetParameterValue("QRImagePath", tempQrPath);
                    }
                    else
                    {
                        rd.SetParameterValue("QRImagePath", "");
                    }
                }
                catch (Exception ex)
                {
                    rd.SetParameterValue("QRImagePath", "");
                }


            }
            else if (reportName == "MedicationPRN")
            {
                try
                {
                    reportPath += "InPatient/rpt_GetIn_Patient_ID_MedicationPRN.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
                    rd.SetParameterValue("@In_Patient_ID", Request.QueryString["In_Patient_ID"]);
                }
                catch (Exception ex)
                {
                    throw;
                }
            }
            else if (reportName == "MedicationSTAT")
            {
                try
                {
                    reportPath += "InPatient/rpt_GetIn_Patient_ID_MedicationSTAT.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
                    rd.SetParameterValue("@In_Patient_ID", Request.QueryString["In_Patient_ID"]);
                }
                catch (Exception ex)
                {
                    throw;
                }
            }
            else if (reportName == "Infusion")
            {
                try
                {
                    reportPath += "InPatient/rpt_In_Patient_ID_Infusion_Order.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
                    rd.SetParameterValue("@In_Patient_ID", Request.QueryString["In_Patient_ID"]);

                }
                catch (Exception ex)
                {
                    throw;
                }
            }
            //else if (reportName == "InPatients_Detail")
            //{
            //    string InPatient_ID = Request.QueryString["InPatient_ID"].ToString();

            //    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

            //    reportPath += "InPatient/rptInpatientDetails.rpt";
            //    rd.Load(reportPath);
            //    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
            //    rd.SetParameterValue("CompanyLogo", logoPath);
            //    rd.SetParameterValue("@outPatient", Convert.ToInt32(InPatient_ID));
            //    rd.SetParameterValue("@outPatient", Convert.ToInt32(InPatient_ID), rd.Subreports[0].Name.ToString());
            //    rd.SetParameterValue("@outPatient", Convert.ToInt32(InPatient_ID), rd.Subreports[1].Name.ToString());
            //    rd.SetParameterValue("@outPatient", Convert.ToInt32(InPatient_ID), rd.Subreports[2].Name.ToString());
            //    // rd.SetParameterValue("@InPatient_id", Convert.ToInt32(InPatient_ID), rd.Subreports[3].Name.ToString());
            //}
            else if (reportName == "InpatientDetail")
            {
                string InPatient_ID = Request.QueryString["InPatient_ID"].ToString();

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                reportPath += "InPatient/rptInpatientDetails.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("@outPatient", Convert.ToInt32(InPatient_ID));
                rd.SetParameterValue("@outPatient", Convert.ToInt32(InPatient_ID), rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@outPatient", Convert.ToInt32(InPatient_ID), rd.Subreports[1].Name.ToString());
                rd.SetParameterValue("@outPatient", Convert.ToInt32(InPatient_ID), rd.Subreports[2].Name.ToString());
                rd.SetParameterValue("@outPatient", Convert.ToInt32(InPatient_ID), rd.Subreports[3].Name.ToString());
                rd.SetParameterValue("@outPatient", Convert.ToInt32(InPatient_ID), rd.Subreports[4].Name.ToString());
                rd.SetParameterValue("@outPatient", Convert.ToInt32(InPatient_ID), rd.Subreports[5].Name.ToString());
                try
                {
                    rd.SetParameterValue("@outPatient", Convert.ToInt32(InPatient_ID), rd.Subreports[6].Name.ToString());
                    rd.SetParameterValue("@outPatient", Convert.ToInt32(InPatient_ID), rd.Subreports[7].Name.ToString());
                    rd.SetParameterValue("@outPatient", Convert.ToInt32(InPatient_ID), rd.Subreports[8].Name.ToString());
                    rd.SetParameterValue("@outPatient", Convert.ToInt32(InPatient_ID), rd.Subreports[9].Name.ToString());
                }
                catch { }
            }
            else if (reportName == "Clinical_Summary")
            {
                try
                {
                    reportPath += "InPatient/rpt_In_Patient_ID_Clinical_Summary.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
                    rd.SetParameterValue("@In_Patient_ID", Request.QueryString["In_Patient_ID"]);
                }
                catch (Exception ex)
                {
                    throw;
                }
            }
            else if (reportName == "In_Patient_VitalSigns")
            {

                var in_patient_id = Request.QueryString["In_Patient_ID"].ToString();

                reportPath += "InPatient/rpt_In_Patient_VitalSigns.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("@In_Patient_ID", in_patient_id);
                // ===== DYNAMIC QR CODE GENERATION (NO DATABASE STORAGE) =====
                try
                {
                    string sql = $@"
                        SELECT ISNULL(rp.mr_no_sequence, '') AS mr_no_sequence,
                                      ISNULL(rp.Full_Name, '') AS Full_Name,
                                      ISNULL(CONVERT(VARCHAR, rp.Age_years), '') AS Age_years,
                                      ISNULL(rp.Gender, '') AS Gender
                               FROM Reg_patient rp
                               JOIN in_patient ip ON ip.patient_id = rp.pat_id
                               WHERE ip.In_Patient_ID = {in_patient_id}";

                    DataTable patientData = DBClass.getDataTable(sql);

                    if (patientData.Rows.Count > 0)
                    {
                        string qrContent = $"MR:{patientData.Rows[0]["mr_no_sequence"]}|Name:{patientData.Rows[0]["Full_Name"]}|Age:{patientData.Rows[0]["Age_years"]}|Gender:{patientData.Rows[0]["Gender"]}";

                        // Save to temp file instead of passing bytes
                        string tempQrPath = Path.Combine(Path.GetTempPath(), $"QR_{in_patient_id}_{Guid.NewGuid()}.png");

                        using (QRCodeGenerator qrGenerator = new QRCodeGenerator())
                        {
                            QRCodeData qrCodeData = qrGenerator.CreateQrCode(qrContent, QRCodeGenerator.ECCLevel.Q);
                            using (PngByteQRCode qrCodeImage = new PngByteQRCode(qrCodeData))
                            {
                                byte[] qrBytes = qrCodeImage.GetGraphic(10);
                                File.WriteAllBytes(tempQrPath, qrBytes);
                            }
                        }

                        // Pass FILE PATH as string parameter
                        rd.SetParameterValue("QRImagePath", tempQrPath);
                    }
                    else
                    {
                        rd.SetParameterValue("QRImagePath", "");
                    }
                }
                catch (Exception ex)
                {
                    rd.SetParameterValue("QRImagePath", "");
                }


            }
            else if (reportName == "ProgressNote")
            {
                try
                {
                    var in_patient_id = Request.QueryString["In_Patient_ID"].ToString();

                    reportPath += "InPatient/rpt_In_Patient_ID_DoctorNote.rpt";
                    rd.Load(reportPath);
                    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("CompanyLogo", logoPath);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
                    rd.SetParameterValue("@In_Patient_ID", in_patient_id);

                    // ===== DYNAMIC QR CODE GENERATION (NO DATABASE STORAGE) =====
                    try
                    {
                        string sql = $@"
        SELECT ISNULL(rp.mr_no_sequence, '') AS mr_no_sequence,
               ISNULL(rp.Full_Name, '') AS Full_Name,
               ISNULL(CONVERT(VARCHAR, rp.Age_years), '') AS Age_years,
               ISNULL(rp.Gender, '') AS Gender
        FROM Reg_patient rp
        JOIN In_Patient ip ON ip.patient_id = rp.pat_id
        WHERE ip.In_Patient_ID = {in_patient_id}";

                        DataTable patientData = DBClass.getDataTable(sql);

                        if (patientData.Rows.Count > 0)
                        {
                            string qrContent = $"MR:{patientData.Rows[0]["mr_no_sequence"]}|Name:{patientData.Rows[0]["Full_Name"]}|Age:{patientData.Rows[0]["Age_years"]}|Gender:{patientData.Rows[0]["Gender"]}";

                            // Save to temp file instead of passing bytes
                            string tempQrPath = Path.Combine(Path.GetTempPath(), $"QR_{in_patient_id}_{Guid.NewGuid()}.png");

                            using (QRCodeGenerator qrGenerator = new QRCodeGenerator())
                            {
                                QRCodeData qrCodeData = qrGenerator.CreateQrCode(qrContent, QRCodeGenerator.ECCLevel.Q);
                                using (PngByteQRCode qrCodeImage = new PngByteQRCode(qrCodeData))
                                {
                                    byte[] qrBytes = qrCodeImage.GetGraphic(10);
                                    File.WriteAllBytes(tempQrPath, qrBytes);
                                }
                            }

                            // Pass FILE PATH as string parameter
                            rd.SetParameterValue("QRImagePath", tempQrPath);
                        }
                        else
                        {
                            rd.SetParameterValue("QRImagePath", "");
                        }
                    }
                    catch (Exception ex)
                    {
                        rd.SetParameterValue("QRImagePath", "");
                    }
                }
                catch (Exception ex)
                {
                    throw;
                }
            }
            else if (reportName == "PrintIPDVitals")
            {
                try
                {
                    var in_patient_id = Request.QueryString["In_Patient_ID"].ToString();

                    reportPath += "InPatient/rpt_In_Patient_Vitals_Report.rpt";
                    rd.Load(reportPath);
                    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("CompanyLogo", logoPath);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
                    rd.SetParameterValue("@In_Patient_ID", in_patient_id);

                    // ===== DYNAMIC QR CODE GENERATION (NO DATABASE STORAGE) =====
                    try
                    {
                        string sql = $@"
        SELECT ISNULL(rp.mr_no_sequence, '') AS mr_no_sequence,
               ISNULL(rp.Full_Name, '') AS Full_Name,
               ISNULL(CONVERT(VARCHAR, rp.Age_years), '') AS Age_years,
               ISNULL(rp.Gender, '') AS Gender
        FROM Reg_patient rp
        JOIN In_Patient ip ON ip.patient_id = rp.pat_id
        WHERE ip.In_Patient_ID = {in_patient_id}";

                        DataTable patientData = DBClass.getDataTable(sql);

                        if (patientData.Rows.Count > 0)
                        {
                            string qrContent = $"MR:{patientData.Rows[0]["mr_no_sequence"]}|Name:{patientData.Rows[0]["Full_Name"]}|Age:{patientData.Rows[0]["Age_years"]}|Gender:{patientData.Rows[0]["Gender"]}";

                            // Save to temp file instead of passing bytes
                            string tempQrPath = Path.Combine(Path.GetTempPath(), $"QR_{in_patient_id}_{Guid.NewGuid()}.png");

                            using (QRCodeGenerator qrGenerator = new QRCodeGenerator())
                            {
                                QRCodeData qrCodeData = qrGenerator.CreateQrCode(qrContent, QRCodeGenerator.ECCLevel.Q);
                                using (PngByteQRCode qrCodeImage = new PngByteQRCode(qrCodeData))
                                {
                                    byte[] qrBytes = qrCodeImage.GetGraphic(10);
                                    File.WriteAllBytes(tempQrPath, qrBytes);
                                }
                            }

                            // Pass FILE PATH as string parameter
                            rd.SetParameterValue("QRImagePath", tempQrPath);
                        }
                        else
                        {
                            rd.SetParameterValue("QRImagePath", "");
                        }
                    }
                    catch (Exception ex)
                    {
                        rd.SetParameterValue("QRImagePath", "");
                    }
                }
                catch (Exception ex)
                {
                    throw;
                }
            }
            else if (reportName == "NursingProgressNote")
            {
                try
                {
                    reportPath += "InPatient/rpt_In_Patient_ID_NursingNote.rpt";
                    rd.Load(reportPath);
                    string in_pat = Request.QueryString["In_Patient_ID"];
                    int ipd = Convert.ToInt32(in_pat);
                    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("CompanyLogo", logoPath);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
                    rd.SetParameterValue("@In_Patient_ID", ipd);
                    rd.SetParameterValue("@In_Patient_ID", ipd, rd.Subreports[0].Name.ToString());


                    // ===== DYNAMIC QR CODE GENERATION (NO DATABASE STORAGE) =====
                    try
                    {
                        string sql = $@"
        SELECT ISNULL(rp.mr_no_sequence, '') AS mr_no_sequence,
               ISNULL(rp.Full_Name, '') AS Full_Name,
               ISNULL(CONVERT(VARCHAR, rp.Age_years), '') AS Age_years,
               ISNULL(rp.Gender, '') AS Gender
        FROM Reg_patient rp
        JOIN In_Patient ip ON ip.patient_id = rp.pat_id
        WHERE ip.In_Patient_ID = {ipd}";

                        DataTable patientData = DBClass.getDataTable(sql);

                        if (patientData.Rows.Count > 0)
                        {
                            string qrContent = $"MR:{patientData.Rows[0]["mr_no_sequence"]}|Name:{patientData.Rows[0]["Full_Name"]}|Age:{patientData.Rows[0]["Age_years"]}|Gender:{patientData.Rows[0]["Gender"]}";

                            // Save to temp file instead of passing bytes
                            string tempQrPath = Path.Combine(Path.GetTempPath(), $"QR_{ipd}_{Guid.NewGuid()}.png");

                            using (QRCodeGenerator qrGenerator = new QRCodeGenerator())
                            {
                                QRCodeData qrCodeData = qrGenerator.CreateQrCode(qrContent, QRCodeGenerator.ECCLevel.Q);
                                using (PngByteQRCode qrCodeImage = new PngByteQRCode(qrCodeData))
                                {
                                    byte[] qrBytes = qrCodeImage.GetGraphic(10);
                                    File.WriteAllBytes(tempQrPath, qrBytes);
                                }
                            }

                            // Pass FILE PATH as string parameter
                            rd.SetParameterValue("QRImagePath", tempQrPath);
                        }
                        else
                        {
                            rd.SetParameterValue("QRImagePath", "");
                        }
                    }
                    catch (Exception ex)
                    {
                        rd.SetParameterValue("QRImagePath", "");
                    }


                }
                catch (Exception ex)
                {
                    throw;
                }
            }
            else if (reportName == "InpatientAdmissionSlip")
            {

                reportPath += "InPatient/rpt_In_Patient_ID_AdmissionSlip.rpt";
                rd.Load(reportPath);
                string in_pat = Request.QueryString["In_Patient_ID"];
                int ipd = Convert.ToInt32(in_pat);
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
                rd.SetParameterValue("@In_Patient_ID", ipd);


                // ===== DYNAMIC QR CODE GENERATION (NO DATABASE STORAGE) =====
                try
                {
                    string sql = $@"
                         SELECT ISNULL(rp.mr_no_sequence, '') AS mr_no_sequence,
                                ISNULL(rp.Full_Name, '') AS Full_Name,
                                ISNULL(CONVERT(VARCHAR, rp.Age_years), '') AS Age_years,
                                ISNULL(rp.Gender, '') AS Gender
                         FROM Reg_patient rp
                         JOIN In_Patient ip ON ip.patient_id = rp.pat_id
                         WHERE ip.In_Patient_ID = {ipd}";

                    DataTable patientData = DBClass.getDataTable(sql);

                    if (patientData.Rows.Count > 0)
                    {
                        string qrContent = $"MR:{patientData.Rows[0]["mr_no_sequence"]}|Name:{patientData.Rows[0]["Full_Name"]}|Age:{patientData.Rows[0]["Age_years"]}|Gender:{patientData.Rows[0]["Gender"]}";

                        // Save to temp file instead of passing bytes
                        string tempQrPath = Path.Combine(Path.GetTempPath(), $"QR_{ipd}_{Guid.NewGuid()}.png");

                        using (QRCodeGenerator qrGenerator = new QRCodeGenerator())
                        {
                            QRCodeData qrCodeData = qrGenerator.CreateQrCode(qrContent, QRCodeGenerator.ECCLevel.Q);
                            using (PngByteQRCode qrCodeImage = new PngByteQRCode(qrCodeData))
                            {
                                byte[] qrBytes = qrCodeImage.GetGraphic(10);
                                File.WriteAllBytes(tempQrPath, qrBytes);
                            }
                        }

                        // Pass FILE PATH as string parameter
                        rd.SetParameterValue("QRImagePath", tempQrPath);
                    }
                    else
                    {
                        rd.SetParameterValue("QRImagePath", "");
                    }
                }
                catch (Exception ex)
                {
                    rd.SetParameterValue("QRImagePath", "");
                }

            }
            else if (reportName == "Certificate_In_Patient")
            {
                string rptFileName = "InPatient/rptDeath_CertifcateIn_Patient.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", "Death Certifcate");
                rd.SetParameterValue("@In_Patient_ID", Convert.ToInt32(Request.QueryString["In_Patient_ID"]));

            }
            #endregion
            else if (reportName == "LabBarcode")
            {
                reportPath += "LabRadiology/rptLabBarcode.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("@Sample_ID", int.Parse(Request.QueryString["Sample_ID"]));
            }
            else if (reportName == "LabQrCode")
            {
                var sampleId = Request.QueryString["Sample_ID"].ToString();
                reportPath += "LabRadiology/rptLabQrCode.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("@Sample_ID", sampleId);

                try
                {
                    bool patientDataFound = false;

                    string sql = $@"
                    SELECT distinct 
                           ISNULL(rp.mr_no_sequence, '') AS mr_no_sequence,
                           ISNULL(rp.Full_Name, '') AS Full_Name,
                           ISNULL(CONVERT(VARCHAR, rp.Age_years), '') AS Age_years,
                           ISNULL(rp.Gender, '') AS Gender,
                           ISNULL(ar.Bill_No, '') AS Bill_No

                    FROM Sample_Master m,
                         Ar_Billings ar,
                         Reg_patient rp,
                         Ar_Billing_Details abd,
                         Sample_Detail sd
                    WHERE m.Patient_ID = rp.pat_id 
                      AND abd.Bill_Details_ID = sd.Bill_Detail_ID
                      AND ar.Bill_ID = abd.Bill_ID
                      AND sd.Sample_ID = {sampleId}";

                    DataTable patientData = DBClass.getDataTable(sql);

                    if (patientData.Rows.Count > 0)
                    {
                        patientDataFound = true;

                        string qrContent = $"MR:{patientData.Rows[0]["mr_no_sequence"]}|Name:{patientData.Rows[0]["Full_Name"]}|Age:{patientData.Rows[0]["Age_years"]}|Gender:{patientData.Rows[0]["Gender"]}|Bill No:{patientData.Rows[0]["Bill_No"]}";
                        // Save to temp file instead of passing bytes
                        string tempQrPath = Path.Combine(Path.GetTempPath(), $"QR_{sampleId}_{Guid.NewGuid()}.png");
                        using (QRCodeGenerator qrGenerator = new QRCodeGenerator())
                        {
                            QRCodeData qrCodeData = qrGenerator.CreateQrCode(qrContent, QRCodeGenerator.ECCLevel.Q);
                            using (PngByteQRCode qrCodeImage = new PngByteQRCode(qrCodeData))
                            {
                                byte[] qrBytes = qrCodeImage.GetGraphic(10);
                                File.WriteAllBytes(tempQrPath, qrBytes);
                            }
                        }
                        // Pass FILE PATH as string parameter
                        rd.SetParameterValue("QRImagePath", tempQrPath);
                    }
                    else
                    {
                        rd.SetParameterValue("QRImagePath", "");
                    }

                    // Debug check — remove or comment out once confirmed working
                    System.Diagnostics.Debug.WriteLine(patientDataFound
                        ? $"Patient data found for sample_id={sampleId}. Row count: {patientData.Rows.Count}"
                        : $"No patient data found for sample_id={sampleId}.");
                }
                catch (Exception ex)
                {
                    rd.SetParameterValue("QRImagePath", "");
                    System.Diagnostics.Debug.WriteLine($"QR generation failed for sample_id={sampleId}: {ex.Message}");
                }
            }
            else if (reportName == "PrintINVBarcodes")
            {
                reportPath += "Inventory/rptCathLabBarcode.rpt";
                rd.Load(reportPath);

                rd.SummaryInfo.ReportTitle = reportTitle;

                string barcodeIdsParam = Request.QueryString["Barcode_IDs"];
                string singleBarcodeId = Request.QueryString["Barcode_ID"];

                if (!string.IsNullOrEmpty(barcodeIdsParam))
                {
                    rd.SetParameterValue("@Barcode_IDs", barcodeIdsParam);
                }
                else if (!string.IsNullOrEmpty(singleBarcodeId))
                {
                    rd.SetParameterValue("@Barcode_IDs", singleBarcodeId);
                }
                else
                {
                    Response.Write("<script>alert('No barcode selected for printing');</script>");
                    return;
                }
            }
            else if (reportName == "LabBarcodeSlip")
            {
                reportPath += "LabRadiology/rptLabSlipBarcode.rpt";
                var sampleid = Request.QueryString["Sample_ID"].ToString();
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("@Sample_ID", sampleid);
                //rd.SetParameterValue("@Sample_ID", int.Parse(Request.QueryString["Sample_ID"]));
            }
            else if (reportName == "Budget_Voucher")
            {
                if (Request.QueryString["Budget_ID"] != null)
                {
                    reportPath += "Accounts/rptBudgetVoucher.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    var BudgetID = Convert.ToInt32(Request.QueryString["Budget_ID"]);
                    rd.SetParameterValue("@Budget_ID", BudgetID);
                }
            }
            else if (reportName == "TestResultQImg")
            {
                string PatientID = Request.QueryString["PatientID"].ToString();
                string Image_Id = Request.QueryString["Image_Id"].ToString();
                reportPath += "LabRadiology/rptTestResultQImg.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("@Image_Id", Image_Id);
                rd.SetParameterValue("@PatientID", PatientID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
                rd.SetParameterValue("Phone", DBClass.getField("select Company_Phone1 from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));

            }

            else if (reportName == "Patient_Transaction_Detail_SehatSahulatCard")
            {
                reportPath += "rptPatient_Trans_Detail_Type_Sehat_Sahulat.rpt";
                rd.Load(reportPath);
                string title = Request.QueryString["ReportTitle"].ToString();
                string MrNo = Request.QueryString["MRNo"].ToString();

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string sqlStartDateTime = Convert.ToDateTime(StartDateTime).ToString("yyyy-MM-dd HH:mm:ss");
                string sqlEndDateTime = Convert.ToDateTime(EndDateTime).ToString("yyyy-MM-dd HH:mm:ss");


                rd.SetParameterValue("@StDate", sqlStartDateTime);
                rd.SetParameterValue("@endDate", sqlEndDateTime);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", title);
                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                rd.SetParameterValue("@Patient_No", MrNo);
            }
            else if (reportName == "PatientsTypesDetails")
            {
                try
                {
                    string joined;
                    string DateFormate = "yyyy-MM-dd";
                    string DateTimeFormate = "yyyy-MM-dd hh:mm tt";


                    string sdateTime = Convert.ToDateTime(Request.QueryString["sDate"].ToString()).ToString(DateFormate);

                    sdateTime += " " + Regex.Replace(Request.QueryString["STime"].ToString(), @"\s+", "");

                    string edateTime = Convert.ToDateTime(Request.QueryString["eDate"].ToString()).ToString(DateFormate);
                    edateTime += " " + Regex.Replace(Request.QueryString["ETime"].ToString(), @"\s+", "");

                    //Mohsin: Starting from here on Monday 30th June,2025 from end and back end is developed.
                    //Below code is irrelevant Therefore it is commented.
                    //string deptID = Request.QueryString["DepartmentID"].ToString();
                    //string PatType = Request.QueryString["PatientType"].ToString();
                    //string ALLValues = Request.QueryString["ALLValues"].ToString();


                    //string[] ALlarry;
                    //string[] arry;
                    //arry = PatType.Split(',');


                    //SqlConnection con = new SqlConnection(DBClass.ConnectionString());
                    //con.Open();
                    //var delete = ("Delete  rptSetParameter");
                    //SqlCommand cmdd = new SqlCommand(delete, con);
                    //cmdd.ExecuteNonQuery();

                    //if (PatType == "null")
                    //{
                    //    //ALlarry = ALLValues.Split(',');
                    //    DataTable dt = DBClass.getDataTable("select distinct Patient_Type from Patients");


                    //    for (int i = 0; i < dt.Rows.Count; i++)
                    //    {
                    //        var sql = ("insert into rptSetParameter (Code) Values('" + dt.Rows[i]["Patient_Type"].ToString() + "')");
                    //        SqlCommand cmd = new SqlCommand(sql, con);
                    //        cmd.ExecuteNonQuery();
                    //    }

                    //    PatType = "0";
                    //    joined = "All";

                    //}
                    //else
                    //{
                    //    List<string> termsList = new List<string>();
                    //    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    //    for (int i = 0; i < arry.Length; i++)
                    //    {
                    //        var sql = ("insert into rptSetParameter (Code) Values('" + arry[i] + "')");
                    //        SqlCommand cmd = new SqlCommand(sql, con);
                    //        cmd.ExecuteNonQuery();

                    //        var data = db.GetDataValueName("Patient Type", arry[i]);
                    //        termsList.Add(data);
                    //    }
                    //    string[] terms = termsList.ToArray();
                    //    joined = string.Join(",", terms);
                    //}
                    //con.Close();

                    //reportPath += "rptGetPatientsTypesDetails.rpt";
                    //rd.Load(reportPath);
                    //rd.SummaryInfo.ReportTitle = reportTitle;
                    //rd.SetParameterValue("@sDate", sdateTime);
                    //rd.SetParameterValue("@eDate", edateTime);
                    //rd.SetParameterValue("@DepartmentID", deptID);
                    //rd.SetParameterValue("@PatientType", PatType);

                    //rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    //rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
                    //rd.SetParameterValue("Title", reportTitle);
                    //rd.SetParameterValue("PatientType", joined);
                    //Mohsin


                }
                catch (Exception ex)
                {

                    throw;
                }
            }

            //else if (reportName == "PharmacySaleReport")
            //{
            //    string InvoiceNo = Request.QueryString["Invoice_No"].ToString();
            //    if (InvoiceNo == null || InvoiceNo == "")
            //    {
            //        string rptFileName = "rptSaleReport.rpt";

            //        string StartDateTime = Request.QueryString["StartDateTime"].ToString();
            //        string EndDateTime = Request.QueryString["EndDateTime"].ToString();
            //        string CheckSummary = Request.QueryString["Summary"].ToString();
            //        if (CheckSummary == "true")
            //        {
            //            rptFileName = "rptSaleReportSummary.rpt";
            //            reportTitle = "Sale Summary Report from " + StartDateTime + " to " + EndDateTime;
            //        }

            //        reportPath += rptFileName;
            //        rd.Load(reportPath);
            //        rd.SetParameterValue("@FromDate", StartDateTime);
            //        rd.SetParameterValue("@ToDate", EndDateTime);
            //        rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
            //        rd.SetParameterValue("Title", reportTitle);
            //        rd.SetParameterValue("@UserId", Request.QueryString["Operator"]);
            //        if (InvoiceNo == null || InvoiceNo == "")
            //            InvoiceNo = "0";
            //        rd.SetParameterValue("@Invoice_No", InvoiceNo);
            //        rd.SetParameterValue("@FromDate", StartDateTime, rd.Subreports[0].Name.ToString());
            //        rd.SetParameterValue("@ToDate", EndDateTime, rd.Subreports[0].Name.ToString());
            //        rd.SetParameterValue("@UserId", Request.QueryString["Operator"], rd.Subreports[0].Name.ToString());
            //        rd.SetParameterValue("@Invoice_No", InvoiceNo, rd.Subreports[0].Name.ToString());
            //        rd.Subreports[0].RecordSelectionFormula = "{spSaleReport;1.TotalAmount} < 0";

            //    }
            //    else
            //    {
            //        string rptFileName = "rptPharmacySlip_New.rpt";
            //        reportPath += rptFileName;
            //        rd.Load(reportPath);
            //        string companyAddress = DBClass.getField("select Company_Address from sys_Companys where Company_ID = " + AppConfig.Company_ID + "").ToString();
            //        rd.SetParameterValue("Address", companyAddress);
            //        rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
            //        rd.SetParameterValue("Title", reportTitle);
            //        rd.SetParameterValue("@Invoice_No", InvoiceNo);

            //    }
            //}

            else if (reportName == "BloodIssuance")
            {
                string rptFileName = "rptBloodIssuance.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);

                string stDate = Request.QueryString["sDate"].ToString();
                string stTime = Request.QueryString["STime"].ToString();
                string endDate = Request.QueryString["eDate"].ToString();
                string endTime = Request.QueryString["ETime"].ToString();
                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;
                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);
                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", "Lab Cash Collection");

            }
            else if (reportName == "ComponentBloodBankStockLedger")
            {
                string rptFileName = "rptBloodLadgerBalanceComponent.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);
                string stDate = Request.QueryString["sDate"].ToString();
                string Component = Request.QueryString["Component"].ToString();
                rd.SetParameterValue("@FromDate", stDate);
                rd.SetParameterValue("@Component", Component);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);

            }
            else if (reportName == "BloodBankStockLedger")
            {
                string rptFileName = "rptBloodBankSummary.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);
                string stDate = Request.QueryString["sDate"].ToString();
                rd.SetParameterValue("@FromDate", stDate);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);

            }
            else if (reportName == "SehatSahulatWiseExpensive")
            {
                reportPath += "rptPatient_Sehat.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                string stDate = Request.QueryString["StartDate"].ToString();
                string stTime = Request.QueryString["StartTime"].ToString();
                string endDate = Request.QueryString["EndDate"].ToString();
                string endTime = Request.QueryString["EndTime"].ToString();
                string Department_ID = Request.QueryString["Departments_ID"].ToString();
                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;
                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);
                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("@Department_ID", Department_ID);
            }

            else if (reportName == "InsuranceCompanies")
            {
                reportPath += "rptPatient_Wise_Panel_Companies.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                string stDate = Request.QueryString["StartDate"].ToString();
                string stTime = Request.QueryString["StartTime"].ToString();
                string endDate = Request.QueryString["EndDate"].ToString();
                string endTime = Request.QueryString["EndTime"].ToString();
                string Department_ID = Request.QueryString["Departments_ID"].ToString();
                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;
                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);
                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("@Panel_Companies", Request.QueryString["PanelCompanies"].ToString());
                rd.SetParameterValue("@Department_ID", Department_ID);


            }
            else if (reportName == "Patient_Transaction_Detail_Type")
            {
                reportPath += "rptPatient_Trans_DetailTypeWise.rpt";
                rd.Load(reportPath);
                string title = Request.QueryString["ReportTitle"].ToString();
                string MrNo = Request.QueryString["MRNo"].ToString();

                string stDate = Request.QueryString["StartDate"].ToString();
                string stTime = Request.QueryString["StartTime"].ToString();

                string endDate = Request.QueryString["EndDate"].ToString();
                string endTime = Request.QueryString["EndTime"].ToString();


                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);


                rd.SetParameterValue("@StDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", title);
                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                rd.SetParameterValue("@Patient_No", MrNo);
            }
            else if (reportName == "SehatSahulatWise")
            {
                reportPath += "rptPatient_Sehat_Sahulat_Wise.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                string stDate = Request.QueryString["StartDate"].ToString();
                string stTime = Request.QueryString["StartTime"].ToString();
                string endDate = Request.QueryString["EndDate"].ToString();
                string endTime = Request.QueryString["EndTime"].ToString();
                string Department_ID = Request.QueryString["Departments_ID"].ToString();
                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;
                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);
                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("@Department_ID", Department_ID);


            }
            else if (reportName == "CBloodBankStockLedger")
            {
                string rptFileName = "rptBloodBankCSummary.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);
                string stDate = Request.QueryString["sDate"].ToString();
                string Component = Request.QueryString["Component"].ToString();
                rd.SetParameterValue("@FromDate", stDate);
                rd.SetParameterValue("@Blood_Platelets_Id", Component);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);

            }
            else if (reportName == "BloodResultPending")
            {
                try
                {
                    string startTime = Request.QueryString["STime"].ToString();
                    string ENdtTime = Request.QueryString["ETime"].ToString();
                    string CurrentUserName = DBClass.getField("select username from aspnet_users where userid='" + AppConfig.UserID + "'").ToString();
                    string DateFormate = "yyyy-MM-dd";
                    string DateTimeFormate = "yyyy-MM-dd hh:mm tt";
                    bool dateOnly = false;
                    string sdateTime = Convert.ToDateTime(Request.QueryString["sDate"].ToString()).ToString(DateFormate);
                    string CurrentUserID = AppConfig.UserID.ToString();
                    sdateTime += " " + Regex.Replace(Request.QueryString["STime"].ToString(), @"\s+", "");
                    if (Request.QueryString["STime"].ToString() == "")
                    {
                        dateOnly = true;
                    }
                    if (!dateOnly)
                    {
                        sdateTime = Convert.ToDateTime(sdateTime).ToString(DateTimeFormate);
                    }
                    string edateTime = Convert.ToDateTime(Request.QueryString["eDate"].ToString()).ToString(DateFormate);
                    edateTime += " " + Regex.Replace(Request.QueryString["ETime"].ToString(), @"\s+", "");
                    if (!dateOnly)
                    {
                        edateTime = Convert.ToDateTime(edateTime).ToString(DateTimeFormate);
                    }

                    string TransType = Request.QueryString["Result"].ToString();
                    if (TransType == "0")
                    {
                        reportPath += "rptBlood_Bank_Result_Approved.rpt";
                    }
                    else
                    {
                        reportPath += "rptBlood_Bank_Result_Pending_NEW.rpt";
                    }
                    rd.Load(reportPath);
                    //rd.SetParameterValue("@DepetID", DeptID);
                    rd.SetParameterValue("@sDateTime", sdateTime);
                    rd.SetParameterValue("@endDateTime", edateTime);
                    //rd.SetParameterValue("@Is_Result", TransType);


                    // rd.SetParameterValue("@TestID", TestID);
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    //rd.SetParameterValue("stime", startTime);
                    //rd.SetParameterValue("etime", ENdtTime);

                    //rd.SetParameterValue("@DoctorID", DoctorID.ToString());


                }
                catch (Exception ex)
                {
                    throw;
                }
            }
            else if (reportName == "Services_List")
            {
                reportPath += "rptServies_Items_List.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", "Servies's Detail");
                rd.SetParameterValue("Show_Rate", Request.QueryString["Show_Rate"]);

            }
            else if (reportName == "LabResultPending")
            {
                try
                {
                    string startTime = Request.QueryString["STime"].ToString();
                    string ENdtTime = Request.QueryString["ETime"].ToString();
                    string CurrentUserName = DBClass.getField("select username from aspnet_users where userid='" + AppConfig.UserID + "'").ToString();
                    string DateFormate = "yyyy-MM-dd";
                    string DateTimeFormate = "yyyy-MM-dd hh:mm tt";
                    bool dateOnly = false;
                    string sdateTime = Convert.ToDateTime(Request.QueryString["sDate"].ToString()).ToString(DateFormate);
                    string CurrentUserID = AppConfig.UserID.ToString();
                    sdateTime += " " + Regex.Replace(Request.QueryString["STime"].ToString(), @"\s+", "");
                    if (Request.QueryString["STime"].ToString() == "")
                    {
                        dateOnly = true;
                    }
                    if (!dateOnly)
                    {
                        sdateTime = Convert.ToDateTime(sdateTime).ToString(DateTimeFormate);
                    }
                    string edateTime = Convert.ToDateTime(Request.QueryString["eDate"].ToString()).ToString(DateFormate);
                    edateTime += " " + Regex.Replace(Request.QueryString["ETime"].ToString(), @"\s+", "");
                    if (!dateOnly)
                    {
                        edateTime = Convert.ToDateTime(edateTime).ToString(DateTimeFormate);
                    }
                    string DeptID = Request.QueryString["DepartmentID"].ToString();
                    string TransType = Request.QueryString["Result"].ToString();
                    //string MainDeptID = Request.QueryString["MainDeptID"].ToString();
                    // string TestID = Request.QueryString["TestID"].ToString();
                    // int DoctorID = Convert.ToInt32(Request.QueryString["Doctor_ID"]);
                    if (TransType == "0")
                    {
                        reportPath += "rptLab_Result_Pending_Approved.rpt";
                    }
                    else
                    {
                        reportPath += "rptLab_Result_Pending_NEW.rpt";
                    }
                    rd.Load(reportPath);
                    rd.SetParameterValue("@DepetID", DeptID);
                    rd.SetParameterValue("@sDateTime", sdateTime);
                    rd.SetParameterValue("@endDateTime", edateTime);
                    //rd.SetParameterValue("@Is_Result", TransType);


                    // rd.SetParameterValue("@TestID", TestID);
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    //rd.SetParameterValue("stime", startTime);
                    //rd.SetParameterValue("etime", ENdtTime);

                    //rd.SetParameterValue("@DoctorID", DoctorID.ToString());


                }
                catch (Exception ex)
                {
                    throw;
                }
            }
            else if (reportName == "OPDBaseReport")
            {
                reportPath += "rptOutPatientBaseReport.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("@Out_Patient_ID", Convert.ToInt32(Request.QueryString["Out_Patient_ID"]));
            }
            else if (reportName == "EmergencyReferdPrint")
            {
                reportPath += "rptReferral_Slip_Base_Print.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                string companyAddress = DBClass.getField("select Company_Address from Sys_Companys where COmpany_ID = " + AppConfig.Company_ID + "").ToString();

                rd.SetParameterValue("@Emergency_ID", int.Parse(Request.QueryString["Emergency_ID"]));
                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("Address", companyAddress);
            }
            else if (reportName == "Procedure_Service_List")
            {
                reportPath += "rptOPD_IPD_Items_List_General2.rpt";
                rd.Load(reportPath);

                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", "Procedure Service List");
                rd.SetParameterValue("@Procedure_types", Request.QueryString["Report_Type"].ToString());
                rd.SetParameterValue("@Trans_Type", Request.QueryString["Company"].ToString());
                //rd.SetParameterValue("@Show_Rate", "Test");

            }
            else if (reportName == "BloodBankLabTest_Details")
            {
                string rptFileName = "";
                rptFileName = "rptLabTestWiseDetailBloodBankTestWise_Summary.rpt";

                reportPath += rptFileName;
                rd.Load(reportPath);

                string stDate = Request.QueryString["sDate"].ToString();
                string stTime = Request.QueryString["STime"].ToString();

                string endDate = Request.QueryString["eDate"].ToString();
                string endTime = Request.QueryString["ETime"].ToString();
                string TestName = Request.QueryString["testName"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);
                string PatType = Request.QueryString["Patient_Type"].ToString();
                if (PatType.Trim() == string.Empty)
                {
                    PatType = "All";
                }
                rd.SetParameterValue("@Patient_Type", PatType);
                rd.SetParameterValue("@TestName", TestName);
                rd.SetParameterValue("@Department", Request.QueryString["Department"]);

                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", "Lab Test Wise Summary");
            }
            else if (reportName == "Blood_Bank_Cash_Collection_Details")
            {
                string rptFileName = "rptLab_test_Blood_Bank_Details.rpt";
                //if (Convert.ToBoolean(Request.QueryString["Summary"].ToString()))
                //string CheckSummary = Request.QueryString["Summary"].ToString();
                //if (CheckSummary == "true")
                //{
                //    rptFileName = "Pharmacy/rptLab_TestBloodBankSummary.rpt";
                //    reportTitle = "Sale Summary Report from " + StartDateTime + " to " + EndDateTime;
                //}
                rptFileName = "rptLab_TestBloodBankSummary.rpt";

                reportPath += rptFileName;
                rd.Load(reportPath);

                string stDate = Request.QueryString["sDate"].ToString();
                string stTime = Request.QueryString["STime"].ToString();

                string endDate = Request.QueryString["eDate"].ToString();
                string endTime = Request.QueryString["ETime"].ToString();
                string TestName = Request.QueryString["testName"].ToString();
                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;


                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);

                bool AllPatientRecords = Convert.ToBoolean(Request.QueryString["AllPatientsRecords"].ToString());
                string userID = "0";

                if (!AllPatientRecords)
                    userID = AppConfig.UserID.ToString();
                string PatType = Request.QueryString["Patient_Type"].ToString();
                if (PatType.Trim() == string.Empty)
                {
                    PatType = "All";
                }
                rd.SetParameterValue("@Patient_Type", PatType);
                rd.SetParameterValue("@TestName", TestName);
                rd.SetParameterValue("@Department", Request.QueryString["Department"]);

                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", "Lab Cash Collection");

            }
            else if (reportName == "Discount_Assigned")
            {
                try
                {
                    reportPath += "rptDiscountAssignedReport.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("@Discount_Assigned_Patient_Id", Request.QueryString["Discount_Assigned_Patient_Id"]);
                }
                catch (Exception ex)
                {
                    throw;
                }
            }
            else if (reportName == "BloodBankCashCollection")
            {
                string rptFileName = "rptBloodBankCashCollection.rpt";
                //if (Convert.ToBoolean(Request.QueryString["Summary"].ToString()))
                //    rptFileName = "rptLabCashCollection_Summary.rpt";
                //string CheckSummary = Request.QueryString["Summary"].ToString();
                //if (CheckSummary == "true")
                //{
                //    rptFileName = "Pharmacy/rptLab_TestBloodBankSummary.rpt";
                //    reportTitle = "Sale Summary Report from " + StartDateTime + " to " + EndDateTime;
                //}
                reportPath += rptFileName;
                rd.Load(reportPath);

                string stDate = Request.QueryString["sDate"].ToString();
                string stTime = Request.QueryString["STime"].ToString();
                string discountType = Request.QueryString["Discount"].ToString();

                string endDate = Request.QueryString["eDate"].ToString();
                string endTime = Request.QueryString["ETime"].ToString();
                string Operator = Request.QueryString["Operator"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);

                bool AllPatientRecords = Convert.ToBoolean(Request.QueryString["AllPatientsRecords"].ToString());
                string userID = "0";

                if (!AllPatientRecords)
                    userID = AppConfig.UserID.ToString();
                string PatType = Request.QueryString["Patient_Type"].ToString();
                if (PatType.Trim() == string.Empty)
                {
                    PatType = "All";
                }
                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", "Lab Cash Collection");
                rd.SetParameterValue("@Patient_Type", PatType);
                rd.SetParameterValue("@Department", Request.QueryString["Department"]);
                if (discountType == "1")
                {
                    rd.RecordSelectionFormula = "{spLabCashCollection;1.Discount} > 0";
                }
                //for Discount = 0
                else if (discountType == "2")
                {
                    rd.RecordSelectionFormula = "{spLabCashCollection;1.Discount} = 0";
                }
                rd.SetParameterValue("@Operator", Operator);
            }
            else if (reportName == "NonCashBloodBankRevenue")
            {
                string joined;
                string rptFileName = "rptBlood_Bank_Receiving.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);

                string stDate = Request.QueryString["sDate"].ToString();
                string stTime = Request.QueryString["STime"].ToString();

                string endDate = Request.QueryString["eDate"].ToString();
                string endTime = Request.QueryString["ETime"].ToString();
                string Operator = Request.QueryString["Operator"].ToString();
                string discountType = Request.QueryString["Discount"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);

                string PatType = Request.QueryString["Patient_Type"].ToString();
                string[] ALlarry;
                string[] arry;
                arry = PatType.Split(',');

                SqlConnection con = new SqlConnection(DBClass.ConnectionString());
                con.Open();
                var delete = ("Delete  rptSetParameter");
                SqlCommand cmdd = new SqlCommand(delete, con);
                cmdd.ExecuteNonQuery();

                if (PatType == "null")
                {
                    //ALlarry = ALLValues.Split(',');
                    DataTable dt = DBClass.getDataTable("select distinct Patient_Type from Patients");


                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        var sql = ("insert into rptSetParameter (Code) Values('" + dt.Rows[i]["Patient_Type"].ToString() + "')");
                        SqlCommand cmd = new SqlCommand(sql, con);
                        cmd.ExecuteNonQuery();
                    }

                    PatType = "0";
                    joined = "All";

                }
                else
                {
                    List<string> termsList = new List<string>();
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    for (int i = 0; i < arry.Length; i++)
                    {
                        var sql = ("insert into rptSetParameter (Code) Values('" + arry[i] + "')");
                        SqlCommand cmd = new SqlCommand(sql, con);
                        cmd.ExecuteNonQuery();

                        var data = db.GetDataValueName("Patient Type", arry[i]);
                        termsList.Add(data);
                    }
                    string[] terms = termsList.ToArray();
                    joined = string.Join(",", terms);
                }
                con.Close();

                //rd.SetParameterValue("@Patient_Type", PatType);

                rd.SetParameterValue("@Department", Request.QueryString["Department"]);

                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", "Lab Cash Collection");
                if (discountType == "1")
                {
                    rd.RecordSelectionFormula = "{spLab_Receiving_BloodBank;1.Discount} > 0";
                }
                //for Discount = 0
                else if (discountType == "2")
                {
                    rd.RecordSelectionFormula = "{spLab_Receiving_BloodBank;1.Discount} = 0";
                }
                rd.SetParameterValue("@Operator", Operator);
                rd.SetParameterValue("PatientType", joined);
            }

            //else if (reportName == "TestWiseMonthlyLabTestDepartment")
            //{

            //    string rptFileName = "GeneralPatientsReport/rptDailyTestMonthly_TestDepartments.rpt";
            //    reportPath += rptFileName;
            //    rd.Load(reportPath);
            //    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
            //    rd.SetParameterValue("Title", " Lab Test Department Wise Monthly Report From " + Convert.ToDateTime(Request.QueryString["sDate"]).ToString("dd-MMM-yyyy") + " To " + Convert.ToDateTime(Request.QueryString["eDate"]).ToString("dd-MMM-yyyy"));
            //    rd.SetParameterValue("@stDate", Convert.ToDateTime(Request.QueryString["sDate"]));
            //    rd.SetParameterValue("@endDate", Convert.ToDateTime(Request.QueryString["eDate"]));
            //    rd.SetParameterValue("@DepetID", (Request.QueryString["DepetID"]).ToString());
            //}          
            else if (reportName == "BloodTransfusion")
            {
                try
                {
                    reportPath += "rptBlood_Transfusion_NEW_Report.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("@BTR_Id", int.Parse(Request.QueryString["BTR_Id"]));
                }
                catch (Exception ex)
                {
                    throw;
                }
            }
            //inserting the new report 

            //inserting the new report 

            else if (reportName == "Lab_Test_Wise_Summary")     // changed the name of the report
            {
                string joined;
                string rptFileName = "";
                rptFileName = "rptLabTestWiseDetailCollection _Summary.rpt";

                reportPath += rptFileName;
                rd.Load(reportPath);

                string stDate = Request.QueryString["sDate"].ToString();
                string stTime = Request.QueryString["STime"].ToString();

                string endDate = Request.QueryString["eDate"].ToString();
                string endTime = Request.QueryString["ETime"].ToString();
                string TestName = Request.QueryString["testName"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);
                string PatType = Request.QueryString["Patient_Type"].ToString();
                //if (PatType.Trim() == string.Empty)
                //{
                //    PatType = "All";
                //}
                //rd.SetParameterValue("@Patient_Type", PatType);
                string[] ALlarry;
                string[] arry;
                arry = PatType.Split(',');

                SqlConnection con = new SqlConnection(DBClass.ConnectionString());
                con.Open();
                var delete = ("Delete  rptSetParameter");
                SqlCommand cmdd = new SqlCommand(delete, con);
                cmdd.ExecuteNonQuery();

                if (PatType == "null")
                {
                    //ALlarry = ALLValues.Split(',');
                    DataTable dt = DBClass.getDataTable("select distinct Patient_Type from Patients");


                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        var sql = ("insert into rptSetParameter (Code) Values('" + dt.Rows[i]["Patient_Type"].ToString() + "')");
                        SqlCommand cmd = new SqlCommand(sql, con);
                        cmd.ExecuteNonQuery();
                    }

                    PatType = "0";
                    joined = "All";

                }
                else
                {
                    List<string> termsList = new List<string>();
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    for (int i = 0; i < arry.Length; i++)
                    {
                        var sql = ("insert into rptSetParameter (Code) Values('" + arry[i] + "')");
                        SqlCommand cmd = new SqlCommand(sql, con);
                        cmd.ExecuteNonQuery();

                        var data = db.GetDataValueName("Patient Type", arry[i]);
                        termsList.Add(data);
                    }
                    string[] terms = termsList.ToArray();
                    joined = string.Join(",", terms);
                }
                con.Close();

                rd.SetParameterValue("@TestName", TestName);
                rd.SetParameterValue("@Department", Request.QueryString["Department"]);

                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", "Lab Test Wise Summary");
                rd.SetParameterValue("PatientType", joined);
            }
            else if (reportName == "LabDepartmentWiseSummary")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string rptFileName = "";
                rptFileName = "LabRadiology/rptLabDepartmentWiseCash_Summary.rpt";

                reportPath += rptFileName;
                rd.Load(reportPath);

                string Department = Request.QueryString["DepartmentID"].ToString();
                string PatType = Request.QueryString["Patient_Type"].ToString();

                string stDate = Request.QueryString["sDate"].ToString();
                string stTime = Request.QueryString["STime"].ToString();

                string endDate = Request.QueryString["eDate"].ToString();
                string endTime = Request.QueryString["ETime"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);


                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Title", "Lab Department Wise Summary");
                rd.SetParameterValue("@Patient_Type", PatType);
                rd.SetParameterValue("@Department", Department);
            }
            else if (reportName == "Procedure_Detail")
            {
                reportPath += "rptOPD_IPD_Items_List.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", "Procedure Detail");
                rd.SetParameterValue("Show_Rate", Request.QueryString["Show_Rate"]);
                rd.SetParameterValue("@Trans_Type", Request.QueryString["Trans_Type"]);
                rd.SetParameterValue("@Procedure_types", Request.QueryString["Procedure_Type"]);

            }
            else if (reportName == "AdmitPatientList")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

                string PatType = Request.QueryString["PatientType"].ToString();

                string rptFileName = "InPatient/rptAdmitPatientList.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@StartDate", Convert.ToDateTime(Request.QueryString["sDate"]));
                rd.SetParameterValue("@EndDate", Convert.ToDateTime(Request.QueryString["eDate"]));
                rd.SetParameterValue("@PatientType", PatType);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "TestResultStatus")
            {
                reportPath += "rptTest_Result_Status.rpt";
                rd.Load(reportPath);

                string stDate = Request.QueryString["sDate"].ToString();
                string stTime = Request.QueryString["STime"].ToString();

                string endDate = Request.QueryString["eDate"].ToString();
                string endTime = Request.QueryString["ETime"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);

                //bool AllPatientRecords = Convert.ToBoolean(Request.QueryString["AllPatientsRecords"].ToString());
                //string userID = "0";

                //if (!AllPatientRecords)
                //    userID = AppConfig.UserID.ToString();

                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", "Test Result Status From " + Convert.ToDateTime(parameterStDate).ToString("dd-MMM-yyyy hh:mm tt") + " and " + Convert.ToDateTime(parameterEndDate).ToString("dd-MMM-yyyy hh:mm tt") + "");
                rd.SetParameterValue("@MainDpt", Request.QueryString["serviceID"]);
            }
            else if (reportName == "GroupTestDefinition")
            {
                reportPath += "rptGroupTestResult.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", Title);
                rd.SetParameterValue("@Group_Category_Name", Request.QueryString["GroupCategoryName"].ToString());
            }
            else if (reportName == "Patient_Transaction_Detail")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                reportPath += "Patients/rptPatient_Trans_Detail.rpt";
                rd.Load(reportPath);
                string title = Request.QueryString["ReportTitle"].ToString();
                string MrNo = Request.QueryString["MRNo"].ToString();

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                rd.SetParameterValue("@StDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("Title", title);
                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                rd.SetParameterValue("@Patient_No", MrNo);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));

            }
            else if (reportName == "TestRateList")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                reportPath += "Billings/rptTestsRateList.rpt";
                rd.Load(reportPath);
                string title = Request.QueryString["ReportTitle"].ToString();
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", title);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "ServiceRatelist")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                reportPath += "Billings/rptServiceRatelist.rpt";
                rd.Load(reportPath);
                string title = Request.QueryString["ReportTitle"].ToString();
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", title);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "DepartmentFeeslist")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                reportPath += "Billings/rptDepartmentFeeslist.rpt";
                rd.Load(reportPath);
                string title = Request.QueryString["ReportTitle"].ToString();
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", title);
                rd.SetParameterValue("CompanyLogo", logoPath);
            }
            else if (reportName == "ConsolidateMedicalSubsidy")
            {
                string discountType = Request.QueryString["Discount"].ToString();
                string rptFileName = "rptConsolidate_Medical_Subsidy.rpt";

                //if (Convert.ToBoolean(Request.QueryString["Summary"].ToString()))
                //    rptFileName = "rptConsolidate_Medical_Subsidy_Summary.rpt";
                //string CheckSummary = Request.QueryString["Summary"].ToString();
                //if (CheckSummary == "true")
                //{
                //    rptFileName = "Pharmacy/rptLab_TestBloodBankSummary.rpt";
                //    reportTitle = "Sale Summary Report from " + StartDateTime + " to " + EndDateTime;
                //}
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);

                string stDate = Request.QueryString["StartDate"].ToString();
                string stTime = Request.QueryString["StartTime"].ToString();

                string endDate = Request.QueryString["EndDate"].ToString();
                string endTime = Request.QueryString["EndTime"].ToString();
                string PatType = Request.QueryString["PatientType"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);

                string[] ALlarry;
                string[] arry;
                arry = PatType.Split(',');
                //arry=arry.replace(/,+$/g, '');

                SqlConnection con = new SqlConnection(DBClass.ConnectionString());
                con.Open();
                var delete = ("Delete  rptSetParameter");
                SqlCommand cmdd = new SqlCommand(delete, con);
                cmdd.ExecuteNonQuery();

                if (PatType == "null" || PatType == "undefined")
                {
                    //ALlarry = ALLValues.Split(',');
                    DataTable dt = DBClass.getDataTable("select distinct Patient_Type from Patients");


                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        var sql = ("insert into rptSetParameter (Code) Values('" + dt.Rows[i]["Patient_Type"].ToString() + "')");
                        SqlCommand cmd = new SqlCommand(sql, con);
                        cmd.ExecuteNonQuery();
                    }

                    PatType = "0";

                }
                else
                {
                    for (int i = 0; i < arry.Length; i++)
                    {
                        var sql = ("insert into rptSetParameter (Code) Values('" + arry[i] + "')");
                        SqlCommand cmd = new SqlCommand(sql, con);
                        cmd.ExecuteNonQuery();
                    }
                }
                con.Close();


                bool AllPatientRecords = Convert.ToBoolean(Request.QueryString["AllPatientRecords"].ToString());
                string userID = "0";

                if (!AllPatientRecords)
                    userID = AppConfig.UserID.ToString();



                rd.SetParameterValue("@StDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("@UserID", userID);
                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                string departmentID = Request.QueryString["Department"].ToString();
                rd.SetParameterValue("@DepartmentID", departmentID);

                rd.SetParameterValue("@serviceID", Request.QueryString["ServiceID"]);
                rd.SetParameterValue("@Patient_Type", PatType);
                //for Discount > 0
                if (discountType == "1")
                {
                    rd.RecordSelectionFormula = "{sp_Consolidate_Medical_Subsidy;1.Discount} > 0";
                }
                //for Discount = 0
                else if (discountType == "2")
                {
                    rd.RecordSelectionFormula = "{sp_Consolidate_Medical_Subsidy;1.Discount} = 0";
                }
            }
            else if (reportName == "OPDPrivateDetail")
            {
                string rptFileName = "rptOPD_Private_OPD_Detail.rpt";

                //if (Convert.ToBoolean(Request.QueryString["Summary"].ToString()))
                //    rptFileName = "rptOPD_Private_OPD_Detail_Summary.rpt";
                //string CheckSummary = Request.QueryString["Summary"].ToString();
                //if (CheckSummary == "true")
                //{
                //    rptFileName = "Pharmacy/rptLab_TestBloodBankSummary.rpt";
                //    reportTitle = "Sale Summary Report from " + StartDateTime + " to " + EndDateTime;
                //}
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);

                string stDate = Request.QueryString["StartDate"].ToString();
                string stTime = Request.QueryString["StartTime"].ToString();

                string endDate = Request.QueryString["EndDate"].ToString();
                string endTime = Request.QueryString["EndTime"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);

                bool AllPatientRecords = Convert.ToBoolean(Request.QueryString["AllPatientRecords"].ToString());
                string userID = "0";

                if (!AllPatientRecords)
                    userID = AppConfig.UserID.ToString();

                rd.SetParameterValue("@StDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("@UserID", userID);
                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                string departmentID = Request.QueryString["Department"].ToString();
                rd.SetParameterValue("@DepartmentID", departmentID);

                //rd.SetParameterValue("@Operator", Request.QueryString["Operator"]);
            }
            else if (reportName == "PrivateProcedureDetail")
            {
                string rptFileName = "rptPrivateProcedureDetail.rpt";
                //bool CheckSummary = Convert.ToBoolean(Request.QueryString["Summary"]);
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                //if (CheckSummary == true)
                //{
                //    rptFileName = "rptPrivateProcedureDetail_Summary.rpt";
                //    reportTitle = "PrivateProcedure Summary Report from " + StartDateTime + " to " + EndDateTime;
                //}
                //string CheckSummary = Request.QueryString["Summary"].ToString();
                //if (CheckSummary == "true")
                //{
                //    rptFileName = "Pharmacy/rptLab_TestBloodBankSummary.rpt";
                //    reportTitle = "Sale Summary Report from " + StartDateTime + " to " + EndDateTime;
                //}
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                rd.SetParameterValue("@FromDate", StartDateTime);
                rd.SetParameterValue("@ToDate", EndDateTime);
                rd.SetParameterValue("Company_Name", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
                rd.SetParameterValue("@Operator", Request.QueryString["Operator"]);
                string departmentID = Request.QueryString["Department"].ToString();
                rd.SetParameterValue("@DepartmentID", departmentID);
            }
            else if (reportName == "ProcedureTimeLine")
            {

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string reportType = Request.QueryString["Report_Type"].ToString();
                string fileName = string.Empty;
                if (reportType == "Monthly")
                {
                    fileName = "Hospital/rptDailyProcedureAssignemt_Monthly.rpt";
                }
                else if (reportType == "Annually")
                {
                    //fileName = "rptMonthlyProcedureAssignment_Anually.rpt";
                    fileName = "Hospital/rptProcedureTimeLineAnnually.rpt";
                }
                reportPath += fileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", "" + reportType + " Procedure Time Line Report From " + Convert.ToDateTime(Request.QueryString["sDate"]).ToString("dd-MMM-yyyy") + " To " + Convert.ToDateTime(Request.QueryString["eDate"]).ToString("dd-MMM-yyyy"));
                rd.SetParameterValue("@stDate", StartDateTime);
                rd.SetParameterValue("@endDate", EndDateTime);
                rd.SetParameterValue("@Operator", "0");
                rd.SetParameterValue("@Trans_Type", "Procedure");
            }
            else if (reportName == "ProcedureTimeLineDetail")
            {

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();

                string ProcedureName = Request.QueryString["ProcedureName"].ToString();
                string PatientType = Request.QueryString["PatientType"].ToString();
                string departmentID = Request.QueryString["Department"].ToString();
                //string OpdIpdDepartment = Request.QueryString["MainDepartment"].ToString();
                string ProcedureType = Request.QueryString["ProcedureType"].ToString();

                string rptFileName = "Hospital/rptProcedureTimeLineDetail.rpt";

                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("@FromDate", StartDateTime);
                rd.SetParameterValue("@ToDate", EndDateTime);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@ProcedureName", ProcedureName);
                rd.SetParameterValue("@PatientType", PatientType);
                rd.SetParameterValue("@DepartmentID", departmentID);
                //rd.SetParameterValue("@MainDepartment", OpdIpdDepartment);
                rd.SetParameterValue("@ProcedureType", ProcedureType);
            }

            else if (reportName == "ServiceChargesDetail")
            {
                string rptFileName = "TransactionalDetails/rptAdmissionCharges.rpt";
                string discountType = Request.QueryString["Discount"].ToString();

                reportPath += rptFileName;
                rd.Load(reportPath);

                string PatType = Request.QueryString["Patient_Type"].ToString();
                if (PatType.Trim() == string.Empty)
                {
                    PatType = "All";
                }

                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle + " For Patient Type :" + PatType);
                rd.SetParameterValue("Address", DBClass.getField("select Company_Name from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));

                string stDate = Request.QueryString["StartDate"].ToString();
                string stTime = Request.QueryString["StartTime"].ToString();

                string endDate = Request.QueryString["EndDate"].ToString();
                string endTime = Request.QueryString["EndTime"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);

                rd.SetParameterValue("@Patient_Type", PatType);
                rd.SetParameterValue("@FromDate", parameterStDate);
                rd.SetParameterValue("@ToDate", parameterEndDate);
                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                rd.SetParameterValue("@Operator", Request.QueryString["Operator"]);
                rd.SetParameterValue("@Department", Request.QueryString["Department"]);
                //rd.SetParameterValue("@serviceID", Request.QueryString["ServiceID"]);
                //for Discount > 0
                if (discountType == "1")
                {
                    rd.RecordSelectionFormula = "{spAdmissionCharges;1.Discount} > 0";
                }
                //for Discount = 0
                else if (discountType == "2")
                {
                    rd.RecordSelectionFormula = "{spAdmissionCharges;1.Discount} = 0";
                }
            }

            else if (reportName == "CancelBill")
            {
                reportPath += "TransactionalDetails/rptBillCancelReport.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);

                string stDate = Request.QueryString["StartDate"].ToString();
                string stTime = Request.QueryString["StartTime"].ToString();

                string endDate = Request.QueryString["EndDate"].ToString();
                string endTime = Request.QueryString["EndTime"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);

                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
            }
            else if (reportName == "AdvanceReport")
            {
                reportPath += "TransactionalDetails/rptAdvancePaymentReport.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);

                string stDate = Request.QueryString["StartDate"].ToString();
                string stTime = Request.QueryString["StartTime"].ToString();

                string endDate = Request.QueryString["EndDate"].ToString();
                string endTime = Request.QueryString["EndTime"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);

                rd.SetParameterValue("@FromDate", parameterStDate);
                rd.SetParameterValue("@ToDate", parameterEndDate);
            }
            else if (reportName == "RefundReport")
            {
                reportPath += "TransactionalDetails/rptRefundReport.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);

                string stDate = Request.QueryString["StartDate"].ToString();
                string stTime = Request.QueryString["StartTime"].ToString();

                string endDate = Request.QueryString["EndDate"].ToString();
                string endTime = Request.QueryString["EndTime"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);

                string doctorID = Request.QueryString["DoctorID"].ToString();


                rd.SetParameterValue("@Department", Request.QueryString["Department"]);
                rd.SetParameterValue("@Operator", Request.QueryString["Operator"]);
                rd.SetParameterValue("@Doctor", doctorID);
                rd.SetParameterValue("@FromDate", parameterStDate);
                rd.SetParameterValue("@ToDate", parameterEndDate);
            }
            else if (reportName == "ReceiptCollectionReport")
            {
                reportPath += "TransactionalDetails/rptReceiptCollectionReport.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);

                string stDate = Request.QueryString["StartDate"].ToString();
                string stTime = Request.QueryString["StartTime"].ToString();

                string endDate = Request.QueryString["EndDate"].ToString();
                string endTime = Request.QueryString["EndTime"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);

                rd.SetParameterValue("@FromDate", parameterStDate);
                rd.SetParameterValue("@ToDate", parameterEndDate);
            }
            else if (reportName == "DailyRevenue")
            {
                reportPath += "rptDailyRevenue.rpt";
                rd.Load(reportPath);
                string patType = Request.QueryString["Patient_Type"].ToString();
                if (patType == string.Empty)
                {
                    patType = "All";
                }

                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle + " For Patient Type : " + patType);
                rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));

                string stDate = Request.QueryString["StartDate"].ToString();
                string stTime = Request.QueryString["StartTime"].ToString();

                string endDate = Request.QueryString["EndDate"].ToString();
                string endTime = Request.QueryString["EndTime"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);

                rd.SetParameterValue("@FromDate", parameterStDate);
                rd.SetParameterValue("@ToDate", parameterEndDate);
                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                rd.SetParameterValue("@Operator", Request.QueryString["Operator"]);
                rd.SetParameterValue("@Department", Request.QueryString["Department"]);
                rd.SetParameterValue("@PatientType", patType);
            }
            else if (reportName == "DepartmentWiseCashSummary")
            {
                reportPath += "rptDailyRevenueSummary.rpt";
                rd.Load(reportPath);
                string patType = Request.QueryString["Patient_Type"].ToString();
                string title = Request.QueryString["ReportTitle"].ToString();
                if (patType == string.Empty)
                {
                    patType = "All";
                }

                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle + " For Patient Type : " + patType);
                rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));

                string stDate = Request.QueryString["StartDate"].ToString();
                string stTime = Request.QueryString["StartTime"].ToString();

                string endDate = Request.QueryString["EndDate"].ToString();
                string endTime = Request.QueryString["EndTime"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);

                rd.SetParameterValue("@FromDate", parameterStDate);
                rd.SetParameterValue("@ToDate", parameterEndDate);
                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                rd.SetParameterValue("@Operator", Request.QueryString["Operator"]);
                rd.SetParameterValue("@Department", Request.QueryString["Department"]);
                rd.SetParameterValue("@PatientType", patType);
            }
            else if (reportName == "DepartmentwiseCashSummary")
            {
                reportPath += "rptPatients_Info_Summary.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);

                string stDate = Request.QueryString["StartDate"].ToString();
                string stTime = Request.QueryString["StartTime"].ToString();

                string endDate = Request.QueryString["EndDate"].ToString();
                string endTime = Request.QueryString["EndTime"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);

                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
            }
            else if (reportName == "BedAllocationReport")
            {
                reportPath += "Hospital/rptBedAllocationReport.rpt";
                string endDate = Request.QueryString["EndDate"].ToString();
                rd.Load(reportPath);

                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@AsOnDate", endDate);
            }
            else if (reportName == "PackageDetailReport")
            {
                string rptFileName = "rptPackageDetail.rpt";
                //bool CheckSummary = Convert.ToBoolean(Request.QueryString["Summary"]);
                string discountType = Request.QueryString["MedicalSubsidy"].ToString();
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                //string CheckSummary = Request.QueryString["Summary"].ToString();
                //if (CheckSummary == "true")
                //{
                //    rptFileName = "Pharmacy/rptLab_TestBloodBankSummary.rpt";
                //    reportTitle = "Sale Summary Report from " + StartDateTime + " to " + EndDateTime;
                //}
                //if (CheckSummary == true)
                //{
                //    rptFileName = "rptPackageDetail_Summary.rpt";
                //    reportTitle = "Package Summary Report from " + StartDateTime + " to " + EndDateTime;
                //}

                reportPath += rptFileName;
                rd.Load(reportPath);

                rd.SetParameterValue("@FromDate", StartDateTime);
                rd.SetParameterValue("@ToDate", EndDateTime);
                rd.SetParameterValue("@UserID", AppConfig.UserID.ToString());
                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);

                rd.SetParameterValue("Company_Name", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));

                if (discountType == "1")
                {
                    rd.RecordSelectionFormula = "{sp_Package_detail;1.Medical_Subsidy} > 0";
                }
                //for Discount = 0
                else if (discountType == "2")
                {
                    rd.RecordSelectionFormula = "{sp_Package_detail;1.Medical_Subsidy} = 0";
                }
            }
            else if (reportName == "ProcedureDetail")
            {
                string rptFileName = "rptProcedureDetail.rpt";
                //bool CheckSummary = Convert.ToBoolean(Request.QueryString["Summary"]);
                string discountType = Request.QueryString["MedicalSubsidy"].ToString();

                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                //if (CheckSummary == true)
                //{
                //    rptFileName = "rptProcedureDetail_Summary.rpt";
                //    reportTitle = "Procedure Summary Report from " + StartDateTime + " to " + EndDateTime;
                //}

                //string CheckSummary = Request.QueryString["Summary"].ToString();
                //if (CheckSummary == "true")
                //{
                //    rptFileName = "Pharmacy/rptLab_TestBloodBankSummary.rpt";
                //    reportTitle = "Sale Summary Report from " + StartDateTime + " to " + EndDateTime;
                //}
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                rd.SetParameterValue("@FromDate", StartDateTime);
                rd.SetParameterValue("@ToDate", EndDateTime);
                rd.SetParameterValue("Company_Name", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
                rd.SetParameterValue("@Operator", Request.QueryString["Operator"]);
                string departmentID = Request.QueryString["Department"].ToString();
                rd.SetParameterValue("@DepartmentID", departmentID);

                if (discountType == "1")
                {
                    rd.RecordSelectionFormula = "{sp_Package_detail;1.Discount} > 0";
                }
                //for Discount = 0
                else if (discountType == "2")
                {
                    rd.RecordSelectionFormula = "{sp_Package_detail;1.Discount} = 0";
                }
            }
            else if (reportName == "PrivateAdmitionDetail")
            {
                string rptFileName = "rptPrivateAdmition_Detail.rpt";
                // bool CheckSummary = Convert.ToBoolean(Request.QueryString["Summary"]);
                string StartDateTime = Request.QueryString["StartDateTime"].ToString();
                string EndDateTime = Request.QueryString["EndDateTime"].ToString();
                //if (CheckSummary == true)
                //{
                //    rptFileName = "rptPrivateAdmission_Detail_Summary.rpt";
                //    reportTitle = "Private Admission  Summary Report from " + StartDateTime + " to " + EndDateTime;
                //}
                //string CheckSummary = Request.QueryString["Summary"].ToString();
                //if (CheckSummary == "true")
                //{
                //    rptFileName = "Pharmacy/rptLab_TestBloodBankSummary.rpt";
                //    reportTitle = "Sale Summary Report from " + StartDateTime + " to " + EndDateTime;
                //}
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                rd.SetParameterValue("@FromDate", StartDateTime);
                rd.SetParameterValue("@ToDate", EndDateTime);
                //rd.SetParameterValue("Company_Name", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("CompanyName", DBClass.getField("select Company_Name from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
                string departmentID = Request.QueryString["Department"].ToString();
                rd.SetParameterValue("@DepartmentID", departmentID);

                //rd.SetParameterValue("@Operator", Request.QueryString["Operator"]);
            }


            else if (reportName == "ChargePolicyWiseSummary")
            {
                string rptFileName = "rptCharge_Policy_Wise_Summary.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);

                string stDate = Request.QueryString["sDate"].ToString();
                string stTime = Request.QueryString["STime"].ToString();
                string endDate = Request.QueryString["eDate"].ToString();
                string endTime = Request.QueryString["ETime"].ToString();
                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;
                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);
                rd.SetParameterValue("@FromDate", parameterStDate);
                rd.SetParameterValue("@ToDate", parameterEndDate);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", Request.QueryString["ReportTitle"].ToString());
                rd.SetParameterValue("@Charge_Policy", Request.QueryString["Charge_Policy"]);

            }

            else if (reportName == "Discharge Time Line Detail")
            {
                string rptFileName = "rptDischarge_Detail_Time_Line.rpt";

                reportPath += rptFileName;
                rd.Load(reportPath);

                string departmentID = Request.QueryString["Department"].ToString();
                string stDate = Request.QueryString["StartDate"].ToString();
                string stTime = Request.QueryString["StartTime"].ToString();

                string endDate = Request.QueryString["EndDate"].ToString();
                string endTime = Request.QueryString["EndTime"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);

                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                rd.SetParameterValue("@DepartmentID", departmentID);

                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@Operator", "0");
            }
            else if (reportName == "BillingProcess")
            {
                if (Request.QueryString["BillNo"] != null)
                {
                    reportPath += "rptBillingProcess.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@Bill_No", Convert.ToInt32(Request.QueryString["BillNo"]));
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
                }
            }
            else if (reportName == "PatientBill")
            {
                if (Request.QueryString["Patient_ID"] != null)
                {
                    reportPath += "rptPatientBilling.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@Patient_ID", Convert.ToInt32(Request.QueryString["Patient_ID"]));
                }
            }
            else if (reportName == "PatientReceipt")
            {
                if (Request.QueryString["Patient_ID"] != null)
                {
                    reportPath += "rptPatientBillingReceipt.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@Patient_ID", Convert.ToInt32(Request.QueryString["Patient_ID"]));
                }
            }
            else if (reportName == "LedgerLevelwise")
            {
                if (Request.QueryString["startDate"] != null && Request.QueryString["endDate"] != null
                   && Request.QueryString["StartAccount_Code"] != null && Request.QueryString["EndAccount_Code"] != null)
                {
                    reportPath += "rptLedgerLevelwise.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                    rd.SetParameterValue("@Book_ID", AppConfig.Book_ID);
                    rd.SetParameterValue("@StartAccountcode", Request.QueryString["StartAccount_Code"]);
                    rd.SetParameterValue("@EndAccountcode", Request.QueryString["EndAccount_Code"]);
                    rd.SetParameterValue("@start_date", Convert.ToDateTime(Request.QueryString["startDate"]));
                    rd.SetParameterValue("@end_date", Convert.ToDateTime(Request.QueryString["endDate"]));
                }
            }
            else if (reportName == "ReceviableAging")
            {
                reportPath += "rptReceviableAging.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
            }
            else if (reportName == "PayableAging")
            {
                reportPath += "rptReceviableAging.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
            }
            else if (reportName == "CashBook")
            {
                if (Request.QueryString["startDate"] != null && Request.QueryString["endDate"] != null
                   && Request.QueryString["Account_Code"] != null)
                {
                    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                    reportPath += "Accounts/rptCashBook.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                    rd.SetParameterValue("@Book_ID", AppConfig.Book_ID);
                    rd.SetParameterValue("@Account_Code", Request.QueryString["Account_Code"]);
                    rd.SetParameterValue("@fromDate", Convert.ToDateTime(Request.QueryString["startDate"]));
                    rd.SetParameterValue("@toDate", Convert.ToDateTime(Request.QueryString["endDate"]));
                    rd.SetParameterValue("CompanyLogo", logoPath);
                }
            }
            else if (reportName == "DepartmentConversion")
            {
                string rptFileName = "rptDepartmentConversion.rpt";

                if (Convert.ToBoolean(Request.QueryString["Summary"].ToString()))
                    rptFileName = "rptDepartmentConversion_Summary.rpt";
                reportPath += rptFileName;

                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", reportTitle);

                string departmentID = Request.QueryString["Department"].ToString();

                string stDate = Request.QueryString["StartDate"].ToString();
                string stTime = Request.QueryString["StartTime"].ToString();

                string endDate = Request.QueryString["EndDate"].ToString();
                string endTime = Request.QueryString["EndTime"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);

                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                rd.SetParameterValue("@Department", departmentID);
            }
            else if (reportName == "CashBookSummary")
            {
                if (Request.QueryString["startDate"] != null && Request.QueryString["endDate"] != null
                   && Request.QueryString["Account_Code"] != null)
                {
                    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                    reportPath += "Accounts/rptCashBookSummary.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                    rd.SetParameterValue("@Book_ID", AppConfig.Book_ID);
                    rd.SetParameterValue("@Account_Code", Request.QueryString["Account_Code"]);
                    rd.SetParameterValue("@startDate", Convert.ToDateTime(Request.QueryString["startDate"]));
                    rd.SetParameterValue("@endDate", Convert.ToDateTime(Request.QueryString["endDate"]));
                    rd.SetParameterValue("CompanyLogo", logoPath);

                }
            }
            else if (reportName == "StockReport")
            {
                if (Request.QueryString["EndDate"] != null
                   && Request.QueryString["Sector"] != null && Request.QueryString["Block"] != null)
                {
                    reportPath += "rptStock.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                    rd.SetParameterValue("@Sector", Request.QueryString["Sector"]);
                    rd.SetParameterValue("@Block", Request.QueryString["Block"]);
                    rd.SetParameterValue("@Plot", Request.QueryString["Plot"]);
                    rd.SetParameterValue("@EndDate", Convert.ToDateTime(Request.QueryString["EndDate"]));
                }
            }
            else if (reportName == "SalesReport")
            {
                if (Request.QueryString["StartDate"] != null && Request.QueryString["EndDate"] != null)
                {
                    reportPath += "rptSales.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                    rd.SetParameterValue("@StartDate", Convert.ToDateTime(Request.QueryString["StartDate"]));
                    rd.SetParameterValue("@EndDate", Convert.ToDateTime(Request.QueryString["EndDate"]));
                    if (Request.QueryString["AllPlots"] != null && Convert.ToBoolean(Request.QueryString["AllPlots"])
                        && Request.QueryString["Plot_ID"] != null)
                    {
                        if (Request.QueryString["Plot_ID"] != "")
                            rd.RecordSelectionFormula = "{spPlots_Ledger;1.Plot_ID} =" + Convert.ToInt32(Request.QueryString["Plot_ID"]);
                    }
                }
            }
            else if (reportName == "DeliveredSalesReport")
            {
                reportPath += "rptDeliveredSale.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                rd.SetParameterValue("@Deliverable", Convert.ToBoolean(Request.QueryString["Delivered"]));
            }
            else if (reportName == "PurchaseReport")
            {
                if (Request.QueryString["StartDate"] != null && Request.QueryString["EndDate"] != null)
                {
                    reportPath += "rptPurchase.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                    rd.SetParameterValue("@StartDate", Convert.ToDateTime(Request.QueryString["StartDate"]));
                    rd.SetParameterValue("@EndDate", Convert.ToDateTime(Request.QueryString["EndDate"]));
                }
            }
            else if (reportName == "DeliveredPurchasesReoprt")
            {
                reportPath += "rptDeliveredPurchase.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                rd.SetParameterValue("@Deliverable", Convert.ToBoolean(Request.QueryString["Delivered"]));
            }
            else if (reportName == "SalesMargin")
            {
                if (Request.QueryString["fromDate"] != null && Request.QueryString["toDate"] != null)
                {
                    reportPath += "rptSalesMarginNew.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                    rd.SetParameterValue("@fromDate", Convert.ToDateTime(Request.QueryString["fromDate"]));
                    rd.SetParameterValue("@toDate", Convert.ToDateTime(Request.QueryString["toDate"]));
                }
            }
            else if (reportName == "SalesMarginSalesmanWise")
            {
                if (Request.QueryString["fromDate"] != null && Request.QueryString["toDate"] != null
                    && Request.QueryString["Salesman"] != null)
                {
                    reportPath += "rptSalesMarginSalesmanWise.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                    rd.SetParameterValue("@Salesman", Request.QueryString["Salesman"]);
                    rd.SetParameterValue("@StartDate", Convert.ToDateTime(Request.QueryString["fromDate"]));
                    rd.SetParameterValue("@EndDate", Convert.ToDateTime(Request.QueryString["toDate"]));
                }
            }
            else if (reportName == "TestWiseMonthly")
            {

                string rptFileName = "rptDailyTestMonthly.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", " Test Wise Monthly Report From " + Convert.ToDateTime(Request.QueryString["sDate"]).ToString("dd-MMM-yyyy") + " To " + Convert.ToDateTime(Request.QueryString["eDate"]).ToString("dd-MMM-yyyy"));
                rd.SetParameterValue("@stDate", Convert.ToDateTime(Request.QueryString["sDate"]));
                rd.SetParameterValue("@endDate", Convert.ToDateTime(Request.QueryString["eDate"]));
            }
            else if (reportName == "SalesmanWiseReceiveables")
            {
                if (Request.QueryString["fromDate"] != null && Request.QueryString["toDate"] != null
                    && Request.QueryString["Salesman"] != null)
                {
                    string path = System.IO.Path.Combine(reportPath, "rptSalesmanWiseReceiveables.rpt");
                    rd.Load(path);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                    rd.SetParameterValue("@Salesman", Request.QueryString["Salesman"]);
                    rd.SetParameterValue("@StartDate", Convert.ToDateTime(Request.QueryString["fromDate"]));
                    rd.SetParameterValue("@EndDate", Convert.ToDateTime(Request.QueryString["toDate"]));
                }
            }
            else if (reportName == "PlotLedger")
            {
                if (Request.QueryString["EndDate"] != null
                   && Request.QueryString["Sector"] != null && Request.QueryString["Block"] != null)
                {
                    reportPath += "rptPartyLedger.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                    rd.SetParameterValue("@Sector", Request.QueryString["Sector"]);
                    rd.SetParameterValue("@Block", Request.QueryString["Block"]);
                    rd.SetParameterValue("@Plot", Request.QueryString["Plot"]);
                    rd.SetParameterValue("@StartDate", Convert.ToDateTime(Request.QueryString["StartDate"]));
                    rd.SetParameterValue("@EndDate", Convert.ToDateTime(Request.QueryString["EndDate"]));
                }
            }
            //else if (reportName == "DailyActivity")
            //{
            //    if (Request.QueryString["ActivityDate"] != null)
            //    {
            //        reportPath += "Accounts/rptDayActivity.rpt";
            //        rd.Load(reportPath);
            //        rd.SummaryInfo.ReportTitle = reportTitle;
            //        rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
            //        rd.SetParameterValue("@ActivityDate", Convert.ToDateTime(Request.QueryString["ActivityDate"]));

            //        rd.SetParameterValue("@companyid", AppConfig.Company_ID);
            //        rd.SetParameterValue("@Book_ID", AppConfig.Book_ID);
            //    }
            //}
            else if (reportName == "DailyActivity")
            {
                if (Request.QueryString["ActivityDate"] != null)
                {
                    reportPath += "Accounts/rptDayActivity.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("@ActivityDate", Convert.ToDateTime(Request.QueryString["fromDate"]));
                    rd.SetParameterValue("@companyid", AppConfig.Company_ID);
                    //  rd.SetParameterValue("@Book_ID", AppConfig.Book_ID);
                }
            }
            else if (reportName == "AccountBalance")
            {
                if (Request.QueryString["fromDate"] != null && Request.QueryString["stCode"] != null
                     && Request.QueryString["enCode"] != null && Request.QueryString["toDate"] != null)
                {
                    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                    reportPath += "Accounts/rptAccountBalance.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("@fromdate", Convert.ToDateTime(Request.QueryString["fromDate"]));
                    rd.SetParameterValue("@todate", Convert.ToDateTime(Request.QueryString["toDate"]));
                    rd.SetParameterValue("@stCode", Request.QueryString["stCode"]);
                    rd.SetParameterValue("@enCode", Request.QueryString["enCode"]);
                    rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                    rd.SetParameterValue("@Book_ID", AppConfig.Book_ID);
                    rd.SetParameterValue("CompanyLogo", logoPath);
                    if (Request.QueryString["HideZeroBalance"] != null && Convert.ToBoolean(Request.QueryString["HideZeroBalance"]))
                        rd.RecordSelectionFormula = "{@Closeing}<>0.00";
                }
            }
            else if (reportName == "VendorCompany")
            {
                if (Request.QueryString["ID"] != null)
                {
                    reportPath += "rptVendor_Companies.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@VId", Convert.ToInt32(Request.QueryString["ID"]));
                }
            }
            else if (reportName == "VendorGeneralItem")
            {
                if (Request.QueryString["ID"] != null)
                {
                    reportPath += "rptVendor_GeneralItem.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@VId", Convert.ToInt32(Request.QueryString["ID"]));
                }
            }
            else if (reportName == "PharmacyItem")
            {
                if (Request.QueryString["ID"] != null)
                {
                    reportPath += "rptVendor_PharmacyItem.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@VId", Convert.ToInt32(Request.QueryString["ID"]));
                }
            }

            else if (reportName == "BankReconsilation")
            {
                if (Request.QueryString["stDate"] != null && Request.QueryString["Account_ID"] != null)
                {
                    reportPath += "rptBankReconsilation.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);
                    rd.SetParameterValue("@account_id", Request.QueryString["Account_ID"]);
                    rd.SetParameterValue("@stDate", Convert.ToDateTime(Request.QueryString["stDate"]));
                }
            }
            else if (reportName == "DocumentPrinting")
            {
                if (Request.QueryString["fromDate"] != null && Request.QueryString["toDate"] != null
                     && Request.QueryString["fromVoucher_No"] != null && Request.QueryString["toVoucher_No"] != null
                     && Request.QueryString["Voucher_Type"] != null)
                {
                    reportPath += "rptVoucherList.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("@Book_ID", AppConfig.Book_ID);
                    rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                    rd.SetParameterValue("@fromVoucher_No", Convert.ToInt32(Request.QueryString["fromVoucher_No"]));
                    rd.SetParameterValue("@toVoucher_No", Convert.ToInt32(Request.QueryString["toVoucher_No"]));
                    rd.SetParameterValue("@Voucher_Type", Request.QueryString["Voucher_Type"]);
                    rd.SetParameterValue("@fromDate", Convert.ToDateTime(Request.QueryString["fromDate"]));
                    rd.SetParameterValue("@toDate", Convert.ToDateTime(Request.QueryString["toDate"]));
                }
            }
            //else if (reportName == "DoctorWisePatients")
            //{
            //    try
            //    {
            //        string DateFormate = "yyyy-MM-dd";
            //        string DateTimeFormate = "yyyy-MM-dd hh:mm tt";
            //        string CurrentUserID = AppConfig.UserID.ToString();
            //        bool dateOnly = false;
            //        string sdateTime = Convert.ToDateTime(Request.QueryString["sDate"].ToString()).ToString(DateFormate);

            //        sdateTime += " " + Regex.Replace(Request.QueryString["STime"].ToString(), @"\s+", "");
            //        if (Request.QueryString["STime"].ToString() == "")
            //        {
            //            dateOnly = true;
            //        }
            //        if (!dateOnly)
            //        {
            //            //sdateTime = sdateTime.Remove(16, 1);
            //            sdateTime = Convert.ToDateTime(sdateTime).ToString(DateTimeFormate);
            //            // Convert.ToDateTime(sdateTime).ToString(DateTimeFormate);
            //        }
            //        string edateTime = Convert.ToDateTime(Request.QueryString["eDate"].ToString()).ToString(DateFormate);
            //        edateTime += " " + Regex.Replace(Request.QueryString["ETime"].ToString(), @"\s+", "");
            //        if (!dateOnly)
            //        {
            //            //edateTime = edateTime.Remove(16, 1);
            //            edateTime = Convert.ToDateTime(edateTime).ToString(DateTimeFormate);
            //        }
            //        string doctorID = Request.QueryString["DoctorID"].ToString();
            //        string deptID = Request.QueryString["DepartmentID"].ToString();
            //        string PatType = Request.QueryString["PatientType"].ToString();
            //        bool summry = Convert.ToBoolean(Request.QueryString["Summary"]);
            //        reportPath += "Hospital/rptDoctorDetails.rpt";
            //        rd.Load(reportPath);
            //        rd.SummaryInfo.ReportTitle = reportTitle;
            //        rd.SetParameterValue("@sDate", sdateTime);
            //        rd.SetParameterValue("@eDate", edateTime);
            //        rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);
            //        rd.SetParameterValue("@DepartmentID", deptID);
            //        rd.SetParameterValue("@DoctorID", doctorID);
            //        rd.SetParameterValue("@PatientType", PatType);
            //        rd.SetParameterValue("@DateOnly", !dateOnly ? 0 : 1);
            //        rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
            //        rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
            //        rd.SetParameterValue("Title", reportTitle);
            //        rd.SetParameterValue("Summary", Convert.ToBoolean(Request.QueryString["Summary"]));
            //        rd.SetParameterValue("@UserID", CurrentUserID);

            //    }
            //    catch (Exception ex)
            //    {

            //        throw;
            //    }
            //}
            //else if (reportName == "DoctorWisePatients")
            //{
            //    try
            //    {
            //        string DateFormate = "yyyy-MM-dd";
            //        //string DateTimeFormate = "yyyy-MM-dd hh:mm tt";
            //        //string AllPatientsRecords = Request.QueryString["AllPatientsRecords"].ToString();
            //        string DateTimeFormate = "yyyy-MM-dd HH:mm:ss";
            //        int AllPatientsRecords;
            //        string Shift_Id = Request.QueryString["Shift"];

            //        if (Request.QueryString["AllPatientsRecords"] == "false")
            //        {
            //            AllPatientsRecords = 0;
            //        }
            //        else
            //        {
            //            AllPatientsRecords = 1;
            //        }
            //        string CurrentUserID = AppConfig.UserID.ToString();
            //        string CurrentUserName = DBClass.getField("select username from aspnet_users where userid='" + AppConfig.UserID + "'").ToString();
            //        int dateOnly = 0;
            //        string sdateTime = Convert.ToDateTime(Request.QueryString["sDate"].ToString()).ToString(DateFormate);
            //        sdateTime += " " + Regex.Replace(Request.QueryString["STime"].ToString(), @"\s+", "");
            //        if (Request.QueryString["STime"].ToString() == "")
            //        {
            //            dateOnly = 1;
            //        }
            //        if (dateOnly == 0)
            //        {
            //            sdateTime = Convert.ToDateTime(sdateTime).ToString(DateTimeFormate);
            //        }
            //        string edateTime = Convert.ToDateTime(Request.QueryString["eDate"].ToString()).ToString(DateFormate);
            //        edateTime += " " + Regex.Replace(Request.QueryString["ETime"].ToString(), @"\s+", "");
            //        if (dateOnly == 0)
            //        {
            //            edateTime = Convert.ToDateTime(edateTime).ToString(DateTimeFormate);
            //        }
            //        int deptID = Convert.ToInt32(Request.QueryString["DepartmentID"]);
            //        string PatType = Request.QueryString["PatientType"].ToString();
            //        string Operator = Convert.ToString(Request.QueryString["Operator"]);
            //        string STIME = Request.QueryString["STime"].ToString();
            //        string ETIME = Request.QueryString["ETime"].ToString();
            //        bool summary = Convert.ToBoolean(Request.QueryString["Summary"]);
            //        string doctorID = Request.QueryString["DoctorID"].ToString();
            //        //bool date_Only_Boolean_converted = Convert.ToBoolean(dateOnly);
            //        bool AllPatientsRecords_Boolean_Converted = Convert.ToBoolean(AllPatientsRecords);
            //        bool summary_Boolean_Converted = Convert.ToBoolean(summary);


            //        var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");

            //        reportPath += "Hospital/rptDoctorDetails.rpt";
            //        rd.Load(reportPath);
            //        rd.SummaryInfo.ReportTitle = reportTitle;
            //        rd.SetParameterValue("@sDate", sdateTime);
            //        rd.SetParameterValue("@eDate", edateTime);
            //        rd.SetParameterValue("@DepartmentID", deptID);
            //        rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
            //        rd.SetParameterValue("@PatientType", PatType);
            //        rd.SetParameterValue("@DateOnly", dateOnly);
            //        rd.SetParameterValue("Title", reportTitle);
            //        rd.SetParameterValue("Summary", summary);
            //        rd.SetParameterValue("@DoctorID", doctorID);
            //        rd.SetParameterValue("@UserID", CurrentUserID);
            //        rd.SetParameterValue("@AllPatientsRecords", AllPatientsRecords_Boolean_Converted);
            //        rd.SetParameterValue("@Operator", Operator);
            //        rd.SetParameterValue("STime", STIME);
            //        rd.SetParameterValue("ETime", ETIME);
            //        rd.SetParameterValue("CompanyLogo", logoPath);

            //        //rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);


            //    }
            //    catch (Exception ex)
            //    {

            //        throw;
            //    }
            //}
            else if (reportName == "InPatientSummarry")
            {
                try
                {
                    string DateFormate = "yyyy-MM-dd";
                    string DateTimeFormate = "yyyy-MM-dd hh:mm tt";
                    string CurrentUserID = AppConfig.UserName;
                    bool dateOnly = false;
                    string PatientID = Request.QueryString["PatientID"].ToString();
                    reportPath += "InPatientDetailSummary.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("Summary", Convert.ToBoolean(Request.QueryString["Summary"]));
                    rd.SetParameterValue("@PatientID", PatientID);
                    rd.SetParameterValue("UserID", CurrentUserID);
                }
                catch (Exception ex)
                {

                    throw;
                }
            }
            else if (reportName == "MaxInventoryItem")
            {
                try
                {
                    string DateFormate = "yyyy-MM-dd";
                    string DateTimeFormate = "yyyy-MM-dd hh:mm tt";
                    string CurrentUserID = AppConfig.UserName;
                    bool dateOnly = false;
                    reportPath += "Max_Inventory_Items.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Title", "Maximum Inventory Items Report");
                    rd.SetParameterValue("Summary", Convert.ToBoolean(Request.QueryString["Summary"]));
                    rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);
                    rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
                    rd.SetParameterValue("UserID", CurrentUserID);
                }
                catch (Exception ex)
                {

                    throw;
                }
            }
            else if (reportName == "MiniInventoryItem")
            {
                try
                {
                    string DateFormate = "yyyy-MM-dd";
                    string DateTimeFormate = "yyyy-MM-dd hh:mm tt";
                    string CurrentUserID = AppConfig.UserName;
                    bool dateOnly = false;
                    reportPath += "Mini_Inventory_Items.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Title", "Minimum Inventory Items Report");
                    rd.SetParameterValue("Summary", Convert.ToBoolean(Request.QueryString["Summary"]));
                    rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
                    rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);
                    rd.SetParameterValue("UserID", CurrentUserID);


                }
                catch (Exception ex)
                {

                    throw;
                }
            }
            else if (reportName == "GLVoucherEntry")
            {
                try
                {
                    string DateFormate = "yyyy-MM-dd";
                    string DateTimeFormate = "yyyy-MM-dd hh:mm tt";
                    string CurrentUserID = AppConfig.UserName;
                    bool dateOnly = false;

                    string Voucher_ID = Request.QueryString["Voucher_ID"].ToString();

                    reportPath += "rptGL_Voucher.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("@Voucher_ID", Voucher_ID);

                }
                catch (Exception ex)
                {

                    throw;
                }
            }
            else if (reportName == "PrintHospital")
            {
                try
                {
                    string Bill_ID = Request.QueryString["Bill_ID"].ToString();

                    reportPath += "rptHospitalServiceBill.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("@Bill_ID", Bill_ID);
                    rd.SetParameterValue("@Consultant_Bill", 0);

                    rd.RecordSelectionFormula = "{spHospitalServiceBill;1.Net_Amount} <> {spHospitalServiceBill;1.Doctor_Amount}";
                }
                catch (Exception ex)
                {

                    throw;
                }
            }
            else if (reportName == "PrintConsultant")
            {
                try
                {
                    string Bill_ID = Request.QueryString["Bill_ID"].ToString();

                    reportPath += "rptHospitalServiceBill.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("@Bill_ID", Bill_ID);
                    rd.SetParameterValue("@Consultant_Bill", 1);

                    //rd.RecordSelectionFormula = "{spHospitalServiceBill;1.Net_Amount} = {spHospitalServiceBill;1.Doctor_Amount}";
                    rd.RecordSelectionFormula = "{spHospitalServiceBill;1.Doctor_Amount} > 0";
                }
                catch (Exception ex)
                {

                    throw;
                }
            }
            else if (reportName == "OutSourceTestDetail")
            {
                reportPath += "rptOutSourceTestList.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
                rd.SetParameterValue("@tetsDate", Convert.ToDateTime(Request.QueryString["tetsDate"]).ToString("dd-MMM-yyyy"));
            }
            else if (reportName == "rptBatchNoWiseReport")
            {
                try
                {
                    string CurrentUserName = DBClass.getField("select username from aspnet_users where userid='" + AppConfig.UserID + "'").ToString();
                    string DateFormate = "yyyy-MM-dd";
                    string DateTimeFormate = "yyyy-MM-dd hh:mm tt";
                    string CurrentUserID = AppConfig.UserID.ToString();
                    bool dateOnly = false;

                    string sddateTime = Convert.ToDateTime(Request.QueryString["sDate"].ToString()).ToString(DateFormate);
                    string edateTime = Convert.ToDateTime(Request.QueryString["eDate"].ToString()).ToString(DateFormate);
                    bool summry = Convert.ToBoolean(Request.QueryString["Summary"]);
                    reportPath += "rptBatchNoWiseReport.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("Summary", Convert.ToBoolean(Request.QueryString["Summary"]));
                    rd.SetParameterValue("OperatorName", CurrentUserName);

                    rd.SetParameterValue("@sDateTime", sddateTime);
                    rd.SetParameterValue("@endDateTime", edateTime);
                    rd.SetParameterValue("@UserID", CurrentUserID);

                }
                catch (Exception ex)
                {

                    throw;
                }
            }
            else if (reportName == "PO_Summarry")
            {
                try
                {
                    string CurrentUserName = DBClass.getField("select username from aspnet_users where userid='" + AppConfig.UserID + "'").ToString();
                    string DateFormate = "yyyy-MM-dd";
                    string DateTimeFormate = "yyyy-MM-dd hh:mm tt";
                    string CurrentUserID = AppConfig.UserID.ToString();
                    bool dateOnly = false;

                    string sddateTime = Convert.ToDateTime(Request.QueryString["sDate"].ToString()).ToString(DateFormate);
                    string edateTime = Convert.ToDateTime(Request.QueryString["eDate"].ToString()).ToString(DateFormate);

                    bool summry = Convert.ToBoolean(Request.QueryString["Summary"]);
                    reportPath += "PO_Summarry.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("Summary", Convert.ToBoolean(Request.QueryString["Summary"]));
                    rd.SetParameterValue("OperatorName", CurrentUserName);
                    rd.SetParameterValue("@sDateTime", sddateTime);
                    rd.SetParameterValue("@endDateTime", edateTime);
                    rd.SetParameterValue("@UserID", CurrentUserID);


                }
                catch (Exception ex)
                {

                    throw;
                }
            }
            else if (reportName == "OppeningReport")
            {
                try
                {
                    string CurrentUserName = DBClass.getField("select username from aspnet_users where userid='" + AppConfig.UserID + "'").ToString();
                    string DateFormate = "yyyy-MM-dd";
                    string DateTimeFormate = "yyyy-MM-dd hh:mm tt";
                    string CurrentUserID = AppConfig.UserID.ToString();
                    bool dateOnly = false;

                    string sddateTime = Convert.ToDateTime(Request.QueryString["sDate"].ToString()).ToString(DateFormate);
                    string edateTime = Convert.ToDateTime(Request.QueryString["eDate"].ToString()).ToString(DateFormate);
                    bool summry = Convert.ToBoolean(Request.QueryString["Summary"]);
                    reportPath += "OppeningReport.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("Summary", Convert.ToBoolean(Request.QueryString["Summary"]));
                    rd.SetParameterValue("OperatorName", CurrentUserName);

                    rd.SetParameterValue("@sDateTime", sddateTime);
                    rd.SetParameterValue("@endDateTime", edateTime);
                    rd.SetParameterValue("@UserID", CurrentUserID);

                }
                catch (Exception ex)
                {

                    throw;
                }
            }
            else if (reportName == "OPDStatus")
            {
                try
                {
                    string CurrentUserID = AppConfig.UserID.ToString();

                    DateTime sdateTime = Convert.ToDateTime(Request.QueryString["sDate"].ToString());

                    DateTime edateTime = Convert.ToDateTime(Request.QueryString["eDate"].ToString());

                    string deptID = Request.QueryString["DepartmentID"].ToString();
                    string Status = Request.QueryString["Status"].ToString();

                    reportPath += "rptOPDStatus.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("@sDate", sdateTime);
                    rd.SetParameterValue("@eDate", edateTime);
                    rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);
                    rd.SetParameterValue("@DepartmentID", deptID);
                    rd.SetParameterValue("@UserID", CurrentUserID);
                    rd.SetParameterValue("@checkStatus", Status);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
                    rd.SetParameterValue("Title", reportTitle);

                }
                catch (Exception ex)
                {

                    throw;
                }
            }
            else if (reportName == "OPDStatusSummary")
            {
                try
                {

                    string CurrentUserID = AppConfig.UserID.ToString();

                    DateTime sdateTime = Convert.ToDateTime(Request.QueryString["sDate"].ToString());

                    DateTime edateTime = Convert.ToDateTime(Request.QueryString["eDate"].ToString());

                    string deptID = Request.QueryString["DepartmentID"].ToString();


                    reportPath += "rptOPDStatusSummary.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("@sDate", sdateTime);
                    rd.SetParameterValue("@eDate", edateTime);
                    rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);
                    rd.SetParameterValue("@DepartmentID", deptID);
                    rd.SetParameterValue("@UserID", CurrentUserID);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
                    rd.SetParameterValue("Title", reportTitle);

                }
                catch (Exception ex)
                {

                    throw;
                }
            }

            else if (reportName == "IPDStatusSummary")
            {
                try
                {

                    string CurrentUserID = AppConfig.UserID.ToString();

                    DateTime sdateTime = Convert.ToDateTime(Request.QueryString["sDate"].ToString());

                    DateTime edateTime = Convert.ToDateTime(Request.QueryString["eDate"].ToString());

                    string deptID = Request.QueryString["DepartmentID"].ToString();


                    reportPath += "rptIPDStatusSummary.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("@sDate", sdateTime);
                    rd.SetParameterValue("@eDate", edateTime);
                    rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);
                    rd.SetParameterValue("@DepartmentID", deptID);
                    rd.SetParameterValue("@UserID", CurrentUserID);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Title", reportTitle);

                }
                catch (Exception ex)
                {

                    throw;
                }
            }
            else if (reportName == "DeptWisePatientsCardDetails")
            {
                try
                {
                    string DateFormate = "yyyy-MM-dd";
                    string DateTimeFormate = "yyyy-MM-dd hh:mm tt";
                    string CurrentUserID = AppConfig.UserID.ToString();
                    bool dateOnly = false;
                    string CurrentUserName = DBClass.getField("select username from aspnet_users where userid='" + AppConfig.UserID + "'").ToString();
                    string sdateTime = Convert.ToDateTime(Request.QueryString["sDate"].ToString()).ToString(DateFormate);
                    sdateTime += " " + Regex.Replace(Request.QueryString["STime"].ToString(), @"\s+", "");
                    if (Request.QueryString["STime"].ToString() == "")
                    {
                        dateOnly = true;
                    }
                    if (!dateOnly)
                        sdateTime = Convert.ToDateTime(sdateTime).ToString(DateTimeFormate);

                    string edateTime = Convert.ToDateTime(Request.QueryString["eDate"].ToString()).ToString(DateFormate);
                    edateTime += " " + Regex.Replace(Request.QueryString["ETime"].ToString(), @"\s+", "");
                    if (!dateOnly)
                        edateTime = Convert.ToDateTime(edateTime).ToString(DateTimeFormate);

                    string deptID = Request.QueryString["DepartmentID"].ToString();
                    string PatType = Request.QueryString["PatientType"].ToString();

                    reportPath += "rptPatientsCardDetails.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("@sDate", sdateTime);
                    rd.SetParameterValue("@eDate", edateTime);
                    rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);
                    rd.SetParameterValue("@DepartmentID", deptID);
                    rd.SetParameterValue("@PatientType", PatType);
                    rd.SetParameterValue("@DateOnly", !dateOnly ? 0 : 1);
                    rd.SetParameterValue("Summary", Convert.ToBoolean(Request.QueryString["Summary"]));
                    rd.SetParameterValue("@UserID", CurrentUserID);
                    rd.SetParameterValue("@AllPatientsRecords", Convert.ToBoolean(Request.QueryString["AllPatientsRecords"]));
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("STime", Request.QueryString["STime"].ToString());
                    rd.SetParameterValue("ETime", Request.QueryString["ETime"].ToString());
                    rd.SetParameterValue("OperatorName", CurrentUserName);
                    rd.SetParameterValue("@Operator", Request.QueryString["Operator"]);
                }
                catch (Exception ex)
                {
                    throw;
                }
            }

            else if (reportName == "rptPatientInvestigationBilling")
            {
                try
                {
                    string startTime = Request.QueryString["STime"].ToString();
                    string ENdtTime = Request.QueryString["ETime"].ToString();
                    string CurrentUserName = DBClass.getField("select username from aspnet_users where userid='" + AppConfig.UserID + "'").ToString();
                    string DateFormate = "yyyy-MM-dd";
                    string DateTimeFormate = "yyyy-MM-dd hh:mm tt";
                    bool dateOnly = false;
                    string sdateTime = Convert.ToDateTime(Request.QueryString["sDate"].ToString()).ToString(DateFormate);
                    //string CurrentUserID = AppConfig.UserID.ToString();
                    string CurrentUserID = Request.QueryString["Operator"].ToString();

                    sdateTime += " " + Regex.Replace(Request.QueryString["STime"].ToString(), @"\s+", "");
                    if (Request.QueryString["STime"].ToString() == "")
                    {
                        dateOnly = true;
                    }
                    if (!dateOnly)
                    {
                        sdateTime = Convert.ToDateTime(sdateTime).ToString(DateTimeFormate);
                    }
                    string edateTime = Convert.ToDateTime(Request.QueryString["eDate"].ToString()).ToString(DateFormate);
                    edateTime += " " + Regex.Replace(Request.QueryString["ETime"].ToString(), @"\s+", "");
                    if (!dateOnly)
                    {
                        edateTime = Convert.ToDateTime(edateTime).ToString(DateTimeFormate);
                    }
                    string DeptID = Request.QueryString["DepartmentID"].ToString();
                    string TransType = Request.QueryString["TransType"].ToString();
                    string MainDeptID = Request.QueryString["MainDeptID"].ToString();
                    string TestID = Request.QueryString["TestID"].ToString();
                    int DoctorID = Convert.ToInt32(Request.QueryString["Doctor_ID"]);

                    reportPath += reportName + ".rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("@DepetID", DeptID);
                    rd.SetParameterValue("@TransType", TransType);
                    rd.SetParameterValue("@TestID", TestID);
                    rd.SetParameterValue("@MainDept", MainDeptID);
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("stime", startTime);
                    rd.SetParameterValue("etime", ENdtTime);
                    rd.SetParameterValue("@sDateTime", sdateTime);
                    rd.SetParameterValue("@endDateTime", edateTime);
                    rd.SetParameterValue("Summary", Convert.ToBoolean(Request.QueryString["Summary"]));
                    rd.SetParameterValue("OperatorName", CurrentUserName);
                    rd.SetParameterValue("@DoctorID", DoctorID.ToString());
                    rd.SetParameterValue("@UserID", CurrentUserID);
                    rd.SetParameterValue("@AllPatientsRecords", Convert.ToBoolean(Request.QueryString["AllPatientsRecords"]));
                    //rd.SetParameterValue("@Operator", Request.QueryString["Operator"]);
                }
                catch (Exception ex)
                {
                    throw;
                }
            }
            else if (reportName == "rptInPatientDetail")
            {
                try
                {
                    string startTime = Request.QueryString["STime"].ToString();
                    string ENdtTime = Request.QueryString["ETime"].ToString();
                    string CurrentUserName = DBClass.getField("select username from aspnet_users where userid='" + AppConfig.UserID + "'").ToString();
                    string DateFormate = "yyyy-MM-dd";
                    string DateTimeFormate = "yyyy-MM-dd hh:mm tt";
                    bool dateOnly = false;
                    string sdateTime = Convert.ToDateTime(Request.QueryString["sDate"].ToString()).ToString(DateFormate);
                    string CurrentUserID = AppConfig.UserID.ToString();
                    sdateTime += " " + Regex.Replace(Request.QueryString["STime"].ToString(), @"\s+", "");
                    if (Request.QueryString["STime"].ToString() == "")
                    {
                        dateOnly = true;
                    }
                    if (!dateOnly)
                    {
                        //sdateTime = Convert.ToDateTime(sdateTime).ToString(DateTimeFormate);
                    }
                    string edateTime = Convert.ToDateTime(Request.QueryString["eDate"].ToString()).ToString(DateFormate);
                    edateTime += " " + Regex.Replace(Request.QueryString["ETime"].ToString(), @"\s+", "");
                    if (!dateOnly)
                    {
                        //edateTime = Convert.ToDateTime(edateTime).ToString(DateTimeFormate);
                    }
                    string DeptID = Request.QueryString["DepartmentID"].ToString();
                    string TransType = Request.QueryString["TransType"].ToString();

                    reportPath += reportName + ".rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("Summary", true);
                    rd.SetParameterValue("OperatorName", CurrentUserName);

                    rd.SetParameterValue("@DepetID", DeptID);
                    rd.SetParameterValue("@TransType", TransType);
                    //rd.SetParameterValue("@TestID", TestID);
                    //rd.SetParameterValue("@MainDept", MainDeptID);


                    rd.SetParameterValue("@sDateTime", sdateTime);
                    rd.SetParameterValue("@endDateTime", edateTime);
                    rd.SetParameterValue("@Operator", Request.QueryString["Operator"]);

                    //rd.SetParameterValue("@DoctorID", DoctorID.ToString());
                    rd.SetParameterValue("@UserID", CurrentUserID);
                    rd.SetParameterValue("@AllPatientsRecords", Convert.ToBoolean(Request.QueryString["AllPatientsRecords"]));
                    rd.SetParameterValue("stime", startTime);
                    rd.SetParameterValue("etime", ENdtTime);
                }
                catch (Exception ex)
                {
                    throw;
                }
            }

            else if (reportName == "LabCashReceivingCollection")
            {
                string joined;
                string rptFileName = "rptLab_Receiving_CashCollection.rpt";
                //if (Convert.ToBoolean(Request.QueryString["Summary"].ToString()))
                //rptFileName = "rptLabCashCollection _Summary.rpt";

                reportPath += rptFileName;
                rd.Load(reportPath);

                string stDate = Request.QueryString["sDate"].ToString();
                string stTime = Request.QueryString["STime"].ToString();

                string endDate = Request.QueryString["eDate"].ToString();
                string endTime = Request.QueryString["ETime"].ToString();
                string Operator = Request.QueryString["Operator"].ToString();
                string discountType = Request.QueryString["Discount"].ToString();

                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;

                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);

                bool AllPatientRecords = Convert.ToBoolean(Request.QueryString["AllPatientsRecords"].ToString());
                string userID = "0";

                if (!AllPatientRecords)
                    userID = AppConfig.UserID.ToString();
                string PatType = Request.QueryString["Patient_Type"].ToString();

                string[] ALlarry;
                string[] arry;
                arry = PatType.Split(',');

                SqlConnection con = new SqlConnection(DBClass.ConnectionString());
                con.Open();
                var delete = ("Delete  rptSetParameter");
                SqlCommand cmdd = new SqlCommand(delete, con);
                cmdd.ExecuteNonQuery();

                if (PatType == "null")
                {
                    //ALlarry = ALLValues.Split(',');
                    DataTable dt = DBClass.getDataTable("select distinct Patient_Type from Patients");


                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        var sql = ("insert into rptSetParameter (Code) Values('" + dt.Rows[i]["Patient_Type"].ToString() + "')");
                        SqlCommand cmd = new SqlCommand(sql, con);
                        cmd.ExecuteNonQuery();
                    }

                    PatType = "0";
                    joined = "All";

                }
                else
                {
                    List<string> termsList = new List<string>();
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    for (int i = 0; i < arry.Length; i++)
                    {
                        var sql = ("insert into rptSetParameter (Code) Values('" + arry[i] + "')");
                        SqlCommand cmd = new SqlCommand(sql, con);
                        cmd.ExecuteNonQuery();

                        var data = db.GetDataValueName("Patient Type", arry[i]);
                        termsList.Add(data);
                    }
                    string[] terms = termsList.ToArray();
                    joined = string.Join(",", terms);
                }
                con.Close();

                //if (PatType.Trim() == string.Empty)
                //{
                //    PatType = "All";
                //}
                //rd.SetParameterValue("@Patient_Type", PatType);

                rd.SetParameterValue("@Department", Request.QueryString["Department"]);


                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", "Lab Cash Collection");
                if (discountType == "1")
                {
                    rd.RecordSelectionFormula = "{spLabCashCollection;1.Discount} > 0";
                }
                //for Discount = 0
                else if (discountType == "2")
                {
                    rd.RecordSelectionFormula = "{spLabCashCollection;1.Discount} = 0";
                }
                rd.SetParameterValue("@Operator", Operator);
                //rd.SetParameterValue("@Patient_Type", joined);
            }

            else if (reportName == "BloodDonorInfo")
            {

                reportPath += "rptBloodDonorInfo.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("@BloodDonor_ID", Convert.ToInt32(Request.QueryString["BloodDonor_ID"]));
                rd.SetParameterValue("Title", (Request.QueryString["ReportTitle"]));

            }
            else if (reportName == "WholeBloodStockLedger")
            {
                string rptFileName = "rptWhole_Blood_Ledger.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);

                string stDate = Request.QueryString["sDate"].ToString();
                string stTime = Request.QueryString["STime"].ToString();
                string endDate = Request.QueryString["eDate"].ToString();
                string endTime = Request.QueryString["ETime"].ToString();
                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;
                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);
                rd.SetParameterValue("@FromDate", parameterStDate);
                rd.SetParameterValue("@ToDate", parameterEndDate);
                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", Request.QueryString["ReportTitle"].ToString());

            }
            else if (reportName == "GroupMainTestDepartments")
            {
                try
                {
                    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                    string DeptID = Request.QueryString["Main_Department"].ToString();
                    string DeptNew = Request.QueryString["Patient_Type"].ToString();
                    reportPath += "LabRadiology/rptGroupTestMain_Department.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@Main_Department", DeptID);
                    rd.SetParameterValue("@Patient_Type", DeptNew);
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("CompanyLogo", logoPath);
                }
                catch (Exception ex)
                {
                    throw;
                }
            }
            else if (reportName == "OutPatientRefferal")
            {
                string out_Patient_ID = Request.QueryString["outPatientID"].ToString();
                reportPath += "rptOutpatReffral.rpt";
                rd.Load(reportPath);
                rd.SetParameterValue("@outPatient", Convert.ToInt32(out_Patient_ID));
                rd.SetParameterValue("@outPatient", Convert.ToInt32(out_Patient_ID), rd.Subreports[0].Name.ToString());
                rd.SetParameterValue("@outPatient", Convert.ToInt32(out_Patient_ID), rd.Subreports[1].Name.ToString());
                rd.SetParameterValue("@outPatient", Convert.ToInt32(out_Patient_ID), rd.Subreports[2].Name.ToString());
                // rd.SetParameterValue("@outPatient", Convert.ToInt32(out_Patient_ID), rd.Subreports[3].Name.ToString());
            }

            else if (reportName == "OutPatientsINP")
            {
                string rptFileName = "rptOutPatients_Inp.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);

                string stDate = Request.QueryString["sDate"].ToString();
                string stTime = Request.QueryString["STime"].ToString();
                string endDate = Request.QueryString["eDate"].ToString();
                string endTime = Request.QueryString["ETime"].ToString();
                string parameterStDate = string.Empty;
                string parameterEndDate = string.Empty;
                this.getDateTimeDBFormate(stDate, stTime, out parameterStDate);
                this.getDateTimeDBFormate(endDate, endTime, out parameterEndDate);
                rd.SetParameterValue("@stDate", parameterStDate);
                rd.SetParameterValue("@endDate", parameterEndDate);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", "Patients Conversion Report From " + parameterStDate + " To " + parameterEndDate);


            }
            else if (reportName == "ComponentBloodStockLedger")
            {
                string rptFileName = "rptNewComponentBloodLedger.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);

                string stDate = Request.QueryString["sDate"].ToString();
                string Components = Request.QueryString["Component"].ToString();
                rd.SetParameterValue("@FromDate", stDate);
                rd.SetParameterValue("@Company_ID", AppConfig.Company_ID);
                rd.SetParameterValue("@Component", Components);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Title", Request.QueryString["ReportTitle"].ToString());

            }
            else if (reportName == "BloodDonorCompatibilityReport")
            {

                reportPath += "rptBloodDonorCompatibility.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("@BloodDonor_ID", Convert.ToInt32(Request.QueryString["BloodDonor_ID"]));
            }
            else if (reportName == "MainTestDepartments")
            {
                try
                {
                    var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                    string DeptID = Request.QueryString["Main_Department"].ToString();
                    string DeptNew = Request.QueryString["Patient_Type"].ToString();
                    reportPath += "LabRadiology/rptTestMain_Department.rpt";
                    rd.Load(reportPath);
                    rd.SetParameterValue("@Main_Department", DeptID);
                    rd.SetParameterValue("@Patient_Type", DeptNew);
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                    rd.SetParameterValue("CompanyLogo", logoPath);
                }
                catch (Exception ex)
                {
                    throw;
                }
            }
            else if (reportName == "BasePrintDonor")
            {
                reportPath += "rptDonorBase_Print.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("@Donor_ID", int.Parse(Request.QueryString["Donor_ID"]));
            }
            else if (reportName == "BasePrintBloodTransfusion")
            {
                reportPath += "rptBlood_Transfusion_Report.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("@BTR_Id", int.Parse(Request.QueryString["BTR_Id"]));
            }
            else if (reportName == "TestResult")
            {
                reportPath += "rptLabTestResultQ.rpt";
                //reportPath += "rptLabTestResult.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("@Test_IDs", Request.QueryString["Test_IDs"]);
            }

            else if (reportName == "TestDefination")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                var Address = DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + "");
                reportPath += "Billings/rptTestDefination.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("@Test_IDs", Request.QueryString["Test_IDs"]);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Address", Address);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);

            }
            else if (reportName == "Gastro")
            {
                reportPath += "rptGastro.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("@Endoscopy_ID", int.Parse(Request.QueryString["Endoscopy_ID"]));
            }
            else if (reportName == "EmergencyBasePrint")
            {
                reportPath += "EmergencyRoomTreatment.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("Title", reportTitle);
                rd.SetParameterValue("@Emergency_ID", int.Parse(Request.QueryString["Emergency_ID"]));
            }
            else if (reportName == "DischargeSmmary")
            {
                reportPath += "rptEmergencyDischargeSummary.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("@Emergency_ID", int.Parse(Request.QueryString["Emergency_ID"]));
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("Address", DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + ""));
            }
            else if (reportName == "Colono")
            {
                reportPath += "rptColono.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("@Endoscopy_ID", int.Parse(Request.QueryString["Endoscopy_ID"]));
            }
            else if (reportName == "LabSlip")
            {
                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                var Address = DBClass.getField("select Company_Address from Sys_Companys where Company_ID = " + AppConfig.Company_ID + "");
                var Phone = DBClass.getField("select Company_Phone1 from Sys_Companys where Company_ID = " + AppConfig.Company_ID + "");
                reportPath += "LabRadiology/rptLabSlip.rpt";
                rd.Load(reportPath);
                var labtest = int.Parse(Request.QueryString["Lab_ID"]);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("@Lab_ID", labtest);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Address", Address);
                rd.SetParameterValue("Phone", Phone);
            }


            else if (reportName == "EmergencyPrint")
            {

                var logoPath = DBClass.getField("SELECT dbo.GetCompanyLogo()");
                string rptFileName = "Emergency/rptDeath_Certifcate.rpt";
                reportPath += rptFileName;
                rd.Load(reportPath);
                rd.SetParameterValue("CompanyName", AppConfig.Company_Name);
                rd.SetParameterValue("CompanyLogo", logoPath);
                rd.SetParameterValue("Title", "Death Certificate");
                rd.SetParameterValue("@Emergency_ID", Convert.ToInt32(Request.QueryString["Emergency_ID"]));

            }
            else if (reportName == "GOP_Details")
            {
                try
                {
                    string CurrentUserID = AppConfig.UserID.ToString();
                    DateTime sdateTime = Convert.ToDateTime(Request.QueryString["sDate"].ToString());
                    DateTime edateTime = Convert.ToDateTime(Request.QueryString["eDate"].ToString());
                    reportPath += "rptGOPPatientsDetails.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("@sDate", sdateTime);
                    rd.SetParameterValue("@eDate", edateTime);
                    rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);
                    // rd.SetParameterValue("@DepartmentID", deptID);
                    rd.SetParameterValue("@UserID", CurrentUserID);
                    rd.SetParameterValue("@AllPatientsRecords", false);
                    rd.SetParameterValue("OperatorName", AppConfig.UserName);
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("@Operator", Request.QueryString["Operator"]);
                }
                catch (Exception ex)
                {
                    throw;
                }
            }
            //Total Patient Report

            else if (reportName == "DotcorCallUnit")
            {
                reportPath += "rptEmergencyDoctor.rpt";
                rd.Load(reportPath);
                rd.SummaryInfo.ReportTitle = reportTitle;
                rd.SetParameterValue("@Emergency_ID", int.Parse(Request.QueryString["Emergency_ID"]));
            }
            else if (reportName == "GOP_Summary")
            {
                try
                {
                    string CurrentUserID = AppConfig.UserID.ToString();
                    DateTime sdateTime = Convert.ToDateTime(Request.QueryString["sDate"].ToString());
                    DateTime edateTime = Convert.ToDateTime(Request.QueryString["eDate"].ToString());
                    reportPath += "rptGOPPatientsDetails_Summary.rpt";
                    rd.Load(reportPath);
                    rd.SummaryInfo.ReportTitle = reportTitle;
                    rd.SetParameterValue("@sDate", sdateTime);
                    rd.SetParameterValue("@eDate", edateTime);
                    rd.SetParameterValue("@CompanyID", AppConfig.Company_ID);
                    rd.SetParameterValue("@UserID", CurrentUserID);
                    rd.SetParameterValue("@AllPatientsRecords", false);
                    rd.SetParameterValue("OperatorName", AppConfig.UserName);
                    rd.SetParameterValue("Title", reportTitle);
                    rd.SetParameterValue("@Operator", Request.QueryString["Operator"]);
                }
                catch (Exception ex)
                {
                    throw;
                }
            }

            else
                return;


            #endregion

            #region "set report connection#
            string UserID = SSB.UserID;
            string Password = SSB.Password;
            string DBName = SSB.InitialCatalog;
            string ServerName = SSB.DataSource;

            rd.SetDatabaseLogon(UserID, Password, ServerName, DBName);
            TableLogOnInfo logOnInfo = new TableLogOnInfo();
            logOnInfo = rd.Database.Tables[0].LogOnInfo;

            ConnectionInfo connectionInfo = new ConnectionInfo();
            connectionInfo = rd.Database.Tables[0].LogOnInfo.ConnectionInfo;

            // Set the Connection parameters.
            connectionInfo.DatabaseName = DBName;
            connectionInfo.ServerName = ServerName;
            connectionInfo.Password = Password;
            connectionInfo.UserID = UserID;
            rd.Database.Tables[0].ApplyLogOnInfo(logOnInfo);
            if (reportName == "PurchaseReturnReport" || reportName == "IPDDetailReport" || reportName == "LedgerForCostCenter" || reportName == "TrailForCostCenter" || reportName == "TrailBalanceByDateCodeSelection" || reportName == "TrailByDate" || reportName == "TrailBalanceAt" || reportName == "LedgerForCostCenter" || reportName == "Ledger" || reportName == "MultiLedger" || reportName == "Lab_Log_Report" || reportName == "Asset_Depreciation_Report" || reportName == "OPD_Department_Wise_Report" || reportName == "Operator_Wise_Billing_Report" ||reportName == "Receipt_Operator_Wise_Report" || reportName == "HospitalServices" || reportName == "StockCategoryValuationReport" || reportName == "OPDDetailReport" || reportName == "DoctorShare_Report" || reportName == "Discharge_Detail" || reportName == "BloodBankCashCollection" || reportName == "Lab_Test_Investigation" || reportName == "TotalPatientRegsreport" || reportName == "DeptWisePatientsCardDetails" || reportName == "MER" || reportName == "AllCashReport" || reportName == "DoctorWisePatients" || reportName == "DeptWisePatients" || reportName == "PatientsTypesDetails" || reportName == "rptPatientInvestigationBilling" || reportName == "rptInPatientDetail" || reportName == "AllDoctorShareDetail" || reportName == "GOP_Details" || reportName == "GOP_Summary" || reportName == "BedAllocationReport" || reportName == "DepartmentwiseCashSummary" || reportName == "AdmissionDetail" || reportName == "Discharge Detail" || reportName == "DepartmentConversion" || reportName == "Procedure_Detail" || reportName == "Services_List" || reportName == "InsuranceCompanies" || reportName == "MainTestDepartments" || reportName == "GroupMainTestDepartments" || reportName == "SehatSahulatWise" || reportName == "SehatSahulatWiseExpensive" || reportName == "Patient_Transaction_Detail_Type" || reportName == "Patient_Transaction_Detail_SehatSahulatCard" || reportName == "OutPatientsINP" || reportName == "DeptWisePatients" || reportName == "PackageDetailReport" || reportName == "ProcedureDetail" || reportName == "PrivateAdmitionDetail" || reportName == "OPDPrivateDetail" || reportName == "AdvanceDetail" || reportName == "DailyRevenue" || reportName == "OutSourceTestDetail" || reportName == "ConsolidateMedicalSubsidy" || reportName == "PrivateProcedureDetail" || reportName == "TestResultStatus" || reportName == "LabTestDetailCollection" || reportName == "LabTestWiseSummary" || reportName == "Procedure_Service_List" || reportName == "ChargePolicyWiseSummary" || reportName == "LabCashReceivingCollection" || reportName == "BloodIssuance" || reportName == "WholeBloodStockLedger" || reportName == "ComponentBloodStockLedger" || reportName == "CBloodBankStockLedger" || reportName == "LabResultPending" || reportName == "BloodBankLabTest_Details" || reportName == "Blood_Bank_Cash_Collection_Details" || reportName == "NonCashBloodBankRevenue" || reportName == "ComponentBloodBankStockLedger" || reportName == "BloodBankStockLedger" || reportName == "BloodResultPending" || reportName == "OPDTimeLine" || reportName == "WardAllocationTimeLine" || reportName == "ProcedureTimeLine" || reportName == "ProcedureTimeLineDetail" || reportName == "BedOccupancy" || reportName == "AverageLengthOfStay" || reportName == "DepartmentWiseProcedureTimeLine" || reportName == "TestWiseMonthly" || reportName == "TestWiseMonthlyLabTestDepartment" || reportName == "Discharge Time Line Detail"
                || reportName == "Daily_Sale_Summary" || reportName == "StockAdjustment" || reportName == "PharmacyStockBatchWise"|| reportName == "Item_Wise_Gross_Profit" || reportName == "YearlyPharmacyOverallSummaryReport" )
            {
                string Export_To_Excel = Request.QueryString["ExportPDF"].ToString();
                //rd.ExportToHttpResponse(ExportFormatType.Excel, Response, true, "ExportedReport");
                //rd.PrintOptions.PrinterName = GetDefaultPrinter();
                //rd.PrintToPrinter(1, false, 1, 1);
                if (Export_To_Excel == "true" || Export_To_Excel == "True")
                {
                    rd.ExportToHttpResponse(ExportFormatType.Excel, Response, false, "ExportedReport");
                }
                else
                {
                    rd.ExportToHttpResponse(ExportFormatType.PortableDocFormat, Response, false, "ExportedReport");
                }
            }
            //    if (reportName == "PatientSlip" || reportName == "OPDBaseReport" || reportName == "TestResultQ" || Export == false)
            //    {
            //        rd.ExportToHttpResponse(ExportFormatType.PortableDocFormat, Response, false, "ExportedReport");
            //        rd.PrintOptions.PrinterName = GetDefaultPrinter();
            //        rd.PrintToPrinter(1, false, 1, 1);
            //    }
            //}
            else
            {
                
                rd.ExportToHttpResponse(ExportFormatType.PortableDocFormat, Response, false, "ExportedReport");
            }
            #endregion
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadReport();
                // CrystalReportViewer1.ReportSource = rd;
                // CrystalReportViewer1.DataBind();
                CrystalReportViewer1.Zoom(120);
                Session["rpt"] = rd;
            }
        }
        string GetDefaultPrinter()
        {
            PrinterSettings settings = new PrinterSettings();
            foreach (string printer in PrinterSettings.InstalledPrinters)
            {
                settings.PrinterName = printer;
                if (settings.IsDefaultPrinter)
                    return printer;
            }
            return string.Empty;
        }

        private void setReportParameter(string ParameterName, object ParameterValue)
        {

        }
        protected void CrystalReportViewer1_Unload(object sender, EventArgs e)
        {

        }
        protected void CrystalReportViewer1_Disposed(object sender, EventArgs e)
        {

        }
    }
}

