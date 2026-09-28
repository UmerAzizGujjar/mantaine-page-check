<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="StockLedgerReport.aspx.cs" Inherits="PMS.StockLedgerReport" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        #ctl00_MainContent_ddlInventoryOrg,ctl00_MainContent_ddlItemGroup,
        ctl00_MainContent_ddlItemType,ctl00_MainContent_ddlItemCategory,
        ctl00_MainContent_ddlProcedureType{
            width:200px;
        }
        .auto-style1 {
            height: 35px;
        }
        .auto-style2 {
            width: 110px;
        }
        .auto-style3 {
            height: 35px;
            width: 110px;
        }
        .auto-style4 {
            width: 13px;
        }
        .auto-style5 {
            width: 97px;
        }
    </style>
     <link href="js/select2.min.css" rel="stylesheet" />
    <script type="text/javascript" src="js/select2.min.js"></script>  
     <script type="text/javascript">
         $(document).ready(function () {

             $("#txtsDate").datepicker({ dateFormat: 'mm/dd/yy' });
             $("#txteDate").datepicker({ dateFormat: 'mm/dd/yy' });
             $('select').select2();
             GetDepartments();
             loadItemList();
             FillAccountCategory();
             $('#txtsTime').ptTimeSelect({});
             $('#txteTime').ptTimeSelect({});
             $('#txtsTime').val('12:00 AM');
             $('#txteTime').val('11:59 PM');
             loadItemCodeList();
             loadManufacturerList();
             loadSupplierList();
             if ('<%= Request.QueryString["rptTitle"] %>' == 'IWNSRC') {
                 $('#ctl00_MainContent_rowItem').hide();
                 $('#ctl00_MainContent_rowWareHouse').hide();
                 $('#ctl00_MainContent_rowInventory_Org').hide();
             }
             if ('<%= Request.QueryString["rptTitle"] %>' == 'IWNSR') {
                 $('#ctl00_MainContent_rowItem').hide();
                 $('#ctl00_MainContent_rowInventory_Org').hide();
                 $('#rowStockOnly').hide();
             }
             $('#<%= btnPreview.ClientID %>').click(function () {
                 var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                 var urlParams = new URLSearchParams(window.location.search);
                 var reportVersion = urlParams.get('ReportVersion'); // "2" or null

                 var type = '<%= Request.QueryString["Type"] %>';
                 var type = '<% =Request.QueryString["rptTitle"] %>'

                 if (type == null || type == '') {
                     var startDate = $('#txtsDate').val();
                     var endDate = $('#txteDate').val();
                     var startItemCode = $('#ddlStartItemCode').val();
                     var endItemCode = $('#ddlEndItemCode').val();
                     var ddlWare = $('#ddlWareHouse').val();
                     var ddlinvOrg = $('#ctl00_MainContent_ddlInventoryOrg').val();

                     // ✅ Choose report name dynamically
                     var reportName = (reportVersion === '2')
                         ? 'StockLedgerWareHousewise_2'
                         : 'StockLedgerWareHousewise';

                     var url = '../../ReportViewer.aspx?ReportName=' + encodeURIComponent(reportName) +
                         '&ReportTitle=Stock Ledger Ware House Wise' +
                         '&StartDate=' + encodeURIComponent(startDate) +
                         '&EndDate=' + encodeURIComponent(endDate) +
                         '&StartItemCode=' + encodeURIComponent(startItemCode) +
                         '&EndItemCode=' + encodeURIComponent(endItemCode) +
                         '&WareHouse=' + encodeURIComponent(ddlWare) +
                         '&Inventory_Org=' + encodeURIComponent(ddlinvOrg) +
                         '&ExportPDF=' + exporttopdf;

                     window.open(url, '_blank');
                 }
                 else if (type == 'IWNSRC')
                 {
                     $('#ctl00_MainContent_rowItem').hide();
                     $('#ctl00_MainContent_rowWareHouse').hide();
                     $('#ctl00_MainContent_rowInventory_Org').hide();

                     var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                     var stockOnly = document.getElementById('chkStockOnly').checked;
                     var startDateTime = $('#txtsDate').val() + ' ' + $('#txtsTime').val();
                     var endDateTime = $('#txteDate').val() + ' ' + $('#txteTime').val();

                     var url = '../../ReportViewer.aspx?ReportName=ItemWiseNetSaleConcise'
                         + '&ReportTitle=' + encodeURIComponent('Item Wise Net Sales from ' + startDateTime + ' to ' + endDateTime)
                         + '&StartDate=' + encodeURIComponent($('#txtsDate').val())
                         + '&StartTime=' + encodeURIComponent($('#txtsTime').val())
                         + '&EndDate=' + encodeURIComponent($('#txteDate').val())
                         + '&EndTime=' + encodeURIComponent($('#txteTime').val())
                         + '&ItemCode=' + encodeURIComponent($('#ddlItemName').val() || '0')
                         + '&Manufacturer=' + encodeURIComponent($('#ddlManufacturer').val() || '0')
                         + '&StockOnly=' + stockOnly
                         + '&ExportPDF=' + exporttopdf;
                     window.open(url, '_blank');
                 }
                 else if (type == 'IWNSR')
                 {
                     var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                     var startDateTime = $('#txtsDate').val() + ' ' + $('#txtsTime').val();
                     var endDateTime = $('#txteDate').val() + ' ' + $('#txteTime').val();

                     var url = '../../ReportViewer.aspx?ReportName=ItemWiseNetSale'
                         + '&ReportTitle=' + encodeURIComponent('Item Wise Net Sales from ' + startDateTime + ' to ' + endDateTime)
                         + '&StartDate=' + encodeURIComponent($('#txtsDate').val())
                         + '&StartTime=' + encodeURIComponent($('#txtsTime').val())
                         + '&EndDate=' + encodeURIComponent($('#txteDate').val())
                         + '&EndTime=' + encodeURIComponent($('#txteTime').val())
                         + '&ItemCode=' + encodeURIComponent($('#ddlItemName').val() || '0')
                         + '&Manufacturer=' + encodeURIComponent($('#ddlManufacturer').val() || '0')
                         + '&Supplier=' + encodeURIComponent($('#ddlSupplier').val() || '0')
                         + '&Warehouse=' + encodeURIComponent($('#ddlWareHouse').val() || '0')
                         + '&ExportPDF=' + exporttopdf;
                     window.open(url, '_blank');
                 }
                 else
                 {
                     debugger;
                     if (type == 'ITL')
                     {
                         var invOrg = $('#ctl00_MainContent_ddlInventoryOrg').val();
                         var group = $('#ctl00_MainContent_ddlItemGroup').val();
                         var type = $('#ctl00_MainContent_ddlItemType').val();
                         var category = $('#ctl00_MainContent_ddlItemCategory').val();
                         var procedure = $('#ctl00_MainContent_ddlProcedureType').val();

                         var url = '../../ReportViewer.aspx?ReportName=ItemList&ReportTitle=Item List&Inventory_Org=' + invOrg + '&Item_Group=' + group + '&Item_Type=' + type + '&Item_Category=' + category + '&Procedure_Type=' + procedure + '';
                         window.open(url);
                     }
                     else if (type == 'ISLR') {
                         StartDate = $('#txtsDate').val();
                         EndDate = $('#txteDate').val();
                         var startItemCode = $('#ddlStartItemCode').val();
                         var endItemCode = $('#ddlEndItemCode').val();
                         var ddlWare = $('#ddlWareHouse').val();
                         var ddlinvOrg = $('#ctl00_MainContent_ddlInventoryOrg').val();
                         var depid = $('#ddldepartment').val();

                         var url = '../../ReportViewer.aspx?ReportName=Inventory_StockLedger_Report&ReportTitle=ItemWiseStockLedgerList&StartDate=' + StartDate + '&EndDate=' + EndDate + '&StartItemCode=' + startItemCode + '&EndItemCode=' + endItemCode + '&WareHouse=' + ddlWare + '&Inventory_Org=' + ddlinvOrg + '&Departemnt=' + depid + '&ExportPDF=' + exporttopdf;
                         window.open(url);
                     }
                     else if (type == 'SSIW') {
                         StartDate = $('#txtsDate').val();
                         EndDate = $('#txteDate').val();
                         var startItemCode = $('#ddlStartItemCode').val();
                         var endItemCode = $('#ddlEndItemCode').val();
                         var url = '../../ReportViewer.aspx?ReportName=SaleSumaryItemWise&ReportTitle=Sale Sumary Item Wise&StartDate=' + StartDate + '&EndDate=' + EndDate + '&StartItemCode=' + startItemCode + '&EndItemCode=' + endItemCode + '&ExportPDF=' + exporttopdf;
                         window.open(url);
                     }
                     else if (type == 'BL') {
                         StartDate = $('#txtsDate').val();
                         EndDate = $('#txteDate').val();


                         var url = '../../ReportViewer.aspx?ReportName=Bill_Ledger_Report&ReportTitle=Bill Ledger Report From ' + StartDate + ' to ' + EndDate + '&StartDate=' + StartDate + '&EndDate=' + EndDate + '&ExportPDF=' + exporttopdf;
                         window.open(url);
                     }
                 }
             });
         });
            function GetDepartments() {
            debugger;
            var optionsDepth = '';

            PageMethods.GetDepartments(function (Tests) {
                debugger
                optionsDepth = '<option value="0">Please Select</option>';
                optionsInv = '<option value="0">Please Select</option>';

                $.each(JSON.parse(Tests), function (key, value) {
                    debugger;
                    if (value.Type == "Dept") {
                        optionsDepth += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                    else if (value.Type == "InvOrg") {
                        optionsInv += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                });              
                $('#ddlWareHouse').html(optionsInv);

            });
         }
         function FillAccountCategory() {

             var options = '<option value="0">Please Select</option>';
             PageMethods.getAccountCategory(function (data) {
                 var testsData = JSON.parse(data);

                 debugger;

                 $.each(JSON.parse(data), function (key, value) {
                     options += '<option value="' + value.Account_Category_Id + '" >' + value.CategoryName + '</option>';
                 });
                 $('#ctl00_MainContent_ddlInventoryOrg').html(options);

             });
             return options;
         }

function loadItemList(rowlength) {
                debugger;
                var optionsitem = '';
                var length = rowlength;
                PageMethods.loadItemList(function (resp) {
                    debugger;
                    optionsitem = '<option value="0">Please Select</option>';
                    $.each(JSON.parse(resp), function (key, value) {
                        debugger;
                        optionsitem += '<option value="' + value.Item_ID + '" >' + value.name + '</option>';
                    });
                    $('#ddlStartItemCode').html(optionsitem);                    
                    $('#ddlEndItemCode').html(optionsitem);
                              
                },
               function (error) {
                   alert(error.get_message());
               });
            }

            function loadItemCodeList() {
                PageMethods.loadItemCodeList(function (resp) {
                    var optionsitem = '<option value="0">Please Select</option>';
                    $.each(JSON.parse(resp), function (key, value) {
                        optionsitem += '<option value="' + value.Item_Code + '" >' + value.name + '</option>';
                    });
                    $('#ddlItemName').html(optionsitem);
                    $('#ddlItemName').trigger('change');
                },
               function (error) {
                   alert(error.get_message());
               });
            }

            function loadManufacturerList() {
                PageMethods.GetManufacturers(function (resp) {
                    var options = '<option value="0">Please Select</option>';
                    $.each(JSON.parse(resp), function (key, value) {
                        options += '<option value="' + value.DataValue_Description + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlManufacturer').html(options);
                    $('#ddlManufacturer').trigger('change');
                },
               function (error) {
                   alert(error.get_message());
               });
            }

            function loadSupplierList() {
                PageMethods.GetSuppliers(function (resp) {
                    var options = '<option value="0">Please Select</option>';
                    $.each(JSON.parse(resp), function (key, value) {
                        options += '<option value="' + value.Vendor_ID + '" >' + value.Vendor_Name + '</option>';
                    });
                    $('#ddlSupplier').html(options);
                    $('#ddlSupplier').trigger('change');
                },
               function (error) {
                   alert(error.get_message());
               });
            }

     </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">   
    <div style="margin-top: 50px;" id="Elements">
        <table>
          <tr id="rowDates" runat="server">
                <td runat="server" id="lblStartDate" class="auto-style2">Start Date </td>
                <td>
                    <input type="text" id="txtsDate" name="txtsDate"  />                   
                </td>
                <td class="auto-style4"></td>
                <td  id="lblEndDate" class="auto-style5">End Date </td>
                <td>
                    <input type="text" id="txteDate" name="txtsDate"/>        
                </td>
             </tr>  
            <tr id="rowTimes">
                <td class="auto-style2">Start Time </td>
                <td>
                    <input type="text" id="txtsTime" name="txtsTime" />
                </td>
                <td class="auto-style4"></td>
                <td class="auto-style5">End Time </td>
                <td>
                    <input type="text" id="txteTime" name="txteTime" />
                </td>
            </tr>
            <tr id="rowItemName">
                <td class="auto-style2">Item Name </td>
                <td>
                    <select id="ddlItemName"></select>
                </td>
                <td class="auto-style4"></td>
                <td class="auto-style5">Manufacturer </td>
                <td>
                    <select id="ddlManufacturer"></select>
                </td>
            </tr>
            <tr id="rowSupplierName">
                <td class="auto-style2">Supplier Name </td>
                <td>
                    <select id="ddlSupplier"></select>
                </td>
                <td class="auto-style4"></td>
                <td class="auto-style5"></td>
                <td></td>
            </tr>
            <tr id="rowStockOnly">
                <td class="auto-style2">Only Stock &gt; 0</td>
                <td>
                    <div class="form-check" style="display: inline-flex; width: 26px;">
                        <input class="form-check-input" type="checkbox" id="chkStockOnly" />
                    </div>
                </td>
            </tr>
            <tr id="rowItem" runat="server">
                <td class="auto-style2">Start Item Code </td>
                <td>
                    <select id="ddlStartItemCode"></select>  
                </td>
                <td class="auto-style4"></td>
                <td class="auto-style5">End Item Code </td>
                <td>
                    <select id="ddlEndItemCode"></select>  
                </td>
            </tr>
            <tr id="rowWareHouse" runat="server">
                <td class="auto-style1"> WareHouse </td>
                <td> 
                    <select id="ddlWareHouse">
                    </select>
                </td>
            </tr>     
            <tr id="rowInventory_Org" runat="server" visible="false">
                <td class="auto-style3">Account Category</td>
                <td class="auto-style1"><asp:DropDownList ID="ddlInventoryOrg" runat="server"></asp:DropDownList></td>
            </tr>    
            <tr id="rowItemGroup" runat="server" visible="false">
                <td class="auto-style3">Item Group</td>
                <td class="auto-style1"><asp:DropDownList ID="ddlItemGroup" runat="server"></asp:DropDownList></td>
            </tr>
            <tr id="rowItemType" runat="server" visible="false">
                <td class="auto-style3">Item Type</td>
                <td class="auto-style1">
                    <asp:DropDownList ID="ddlItemType" runat="server"></asp:DropDownList></td>
            </tr>
            <tr id="rowItemCategory" runat="server" visible="false">
                <td class="auto-style3">Item Category</td>
                <td class="auto-style1"><asp:DropDownList ID="ddlItemCategory" runat="server"></asp:DropDownList></td>
            </tr>
            <tr id="rowProcedureType" runat="server" visible="false">
                <td class="auto-style3">Procedure Type</td>
                <td class="auto-style1"><asp:DropDownList ID="ddlProcedureType" runat="server"></asp:DropDownList></td>
            </tr>
            <tr id="rowExport">
                <td class="auto-style2">Export to Excel</td>
                <td>
                    <div class="form-check" style="display: inline-flex; width: 26px;">
                        <input runat="server" class="form-check-input" type="checkbox" id="chkExportPDF" />
                    </div>
                </td>
            </tr>
            </table>
        <br />

        <div style="margin-left: 100px;">
             <div class="row">
             <div class="col-lg-2">
                 <asp:Button Text="Preview" CssClass="btn btn-primry" ID="btnPreview" runat="server" OnClientClick="return false;" />
             </div>
             <div class="col-lg-2">
                 <asp:Button Text="Reset" ID="btnReset" CssClass="btn btn-gray" runat="server" />
             </div>
         </div>
           
        </div>

    </div>
</asp:Content>
