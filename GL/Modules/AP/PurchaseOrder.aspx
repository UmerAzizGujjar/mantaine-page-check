<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PurchaseOrder.aspx.cs" Inherits="PMS.AP.PurchaseOrder" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        .form-check-input {
            margin-left: -20px !important;
        }

        .tooltip-inner {
            background-color: #ffc107 !important;
            color: #000 !important;
            font-size: 12px;
            font-weight: bold;
        }

        .tooltip-arrow::before {
            border-top-color: #ffc107 !important;
            border-bottom-color: #ffc107 !important;
        }

        #ui-datepicker-div{
        z-index: 1000 !important;
        }
        /* ========== PAGE LOADER STYLES ========== */
#page-loader {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(255, 255, 255, 0.9);
    z-index: 9999;
    display: flex;
    justify-content: center;
    align-items: center;
    flex-direction: column;
}

#page-loader .loader-spinner {
    border: 5px solid #f3f3f3;
    border-top: 5px solid #3498db;
    border-radius: 50%;
    width: 60px;
    height: 60px;
    animation: spin 1s linear infinite;
    margin-bottom: 20px;
}

#page-loader .loader-text {
    font-size: 16px;
    color: #333;
    font-weight: bold;
}

@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}

#page-loader.hidden {
    display: none;
}
    </style>

    <script type="text/javascript">

        function FillStaxtype() {
            debugger;
            var options = '<option value="0">0</option>';
            PageMethods.getwtaxtype(function (Tests) {
                debugger
                $.each(JSON.parse(Tests), function (key, value) {
                    debugger;
                    options += '<option value="' + value.Sales_Tax_ID + '" >' + value.Sales_Tax_Perc + '</option>';
                });
                $('.ddlSTAX').html(options);

            });
        }
        function FillAdvancetaxtype() {
            debugger;
            var options = '<option value="0">0</option>';
            PageMethods.getAdvanceTaxType(function (Tests) {
                debugger
                $.each(JSON.parse(Tests), function (key, value) {
                    debugger;
                    options += '<option value="' + value.Advance_Tax_ID + '" >' + value.Advance_Tax_Perc + '</option>';
                });
                $('.ddlAdvanceTax').html(options);
            });
        }
        function FillFurtherTaxType() {
            var options = '<option value="0">0</option>';
            PageMethods.getFurtherTaxType(function (res) {
                $.each(JSON.parse(res), function (key, value) {
                    options += '<option value="' + value.Further_Tax_ID + '">' + value.Further_Tax_Perc + '</option>';
                });
                $('.ddlFurtherTax').html(options);
            });
        }

        var selectedOptions = '';
        var fedcounter = 1;
        var taxcounter = 1;
        var Counter = 1;
        function PrintPurchseOrderReport() {
            var contents = $("#PrintPurchseOrderReport").html();
            var frame1 = $('<iframe />');
            frame1[0].name = "frame1";
            frame1.css({ "position": "absolute", "top": "-1000000px" });
            $("body").append(frame1);
            var frameDoc = frame1[0].contentWindow;
            frameDoc.document.open();
            frameDoc.document.write('<html>');
            frameDoc.document.write('<body>');
            frameDoc.document.write(contents);
            frameDoc.document.write('</body></html>');
            frameDoc.document.close();
            setTimeout(function () {
                window.frames["frame1"].focus();
                window.frames["frame1"].print();
                frame1.remove();
                window.close();
            }, 500);
        }
        function CurrencyFormatted(num) {
            num = num.toString().replace(/\$|\,/g, '');
            if (isNaN(num))
                num = "0";
            sign = (num == (num = Math.abs(num)));
            num = Math.floor(num * 100 + 0.50000000001);
            cents = num % 100;
            num = Math.floor(num / 100).toString();
            if (cents < 10)
                cents = "0" + cents;
            for (var i = 0; i < Math.floor((num.length - (1 + i)) / 3); i++)
                num = num.substring(0, num.length - (4 * i + 3)) + ',' +
                    num.substring(num.length - (4 * i + 3));
            return (((sign) ? '' : '-') + num);
        }
        function GetDetail(PO_No) {
            debugger;
            PageMethods.GetPODetail(PO_No, function (res) {
                var Test = JSON.parse(res);

                var rows = '';
                var SrNo = 0;
                $('#Billtbody tr').remove();
                $.each(Test, function (key, value) {
                    SrNo += 1;
                    rows += '<tr ><td valign="top" style="border: 1px solid black;  border-collapse: collapse;height:30px;border-color:lightgrey;text-align:center;margin-left: 45px;">' + SrNo + '</td><td style="border: 1px solid black; border-collapse: collapse;height:10px;border-color:lightgrey;margin-left: 45px;" valign="top">' + value.Item_Name + '</td><td style="border: 1px solid black; border-collapse: collapse;height:10px;border-color:lightgrey;margin-left: 45px;" valign="top">' + value.Unit + '</td><td style=" border: 1px solid black; border-collapse: collapse;height:10px;text-align: center;border-color:lightgrey;text-align:Right;margin-left: 45px;" valign="top"> ' + value.Qty + '</td><td style=" border: 1px solid black; border-collapse: collapse;height:10px;text-align: center;border-color:lightgrey;text-align:Right;margin-left: 45px;" valign="top"> ' + value.Rate + '</td><td valign="top" style=" border: 1px solid black; border-collapse: collapse;height:10px;text-align: center;border-color:lightgrey;text-align:Right;margin-left: 45px;">' + value.Discount_Amount + '</td><td valign="top" style="border: 1px solid black; border-collapse: collapse;height:10px;text-align: center;border-color:lightgrey;text-align:Right;margin-left: 45px;">' + value.Amount + '</td></tr>';
                });
                $('#Billtbody').html(rows);
                PrintPurchseOrderReport();
            });
        }
        function removeCommas(str) {
            debugger;
            while (str.search(",") >= 1) {
                str = (str + "").replace(',', '');
            }
            return str;
        };

        function PrintPurchaseOrderDetail() {
            debugger;
            var id = '<% =Request.QueryString["PO_ID"] %>';
            var locationInfo = window.location;

            var user_name = '<% =AppConfig.Company_Name %>';
            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx'; // same folder
            }

            var url = '/ReportViewer.aspx?ReportName=PurchaseOrderList&ReportTitle=Purchase Order List&POid=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/' + reportPath +  '?ReportName=PurchaseOrderList&ReportTitle=Purchase Order List&POid=' + id;
            }
            window.open(url, '_blank');
        }

        function append(anchor, isBulk = false) {
            debugger;
            // debugger; // Removed for performance, uncomment if needed for testing
            var row = $(anchor).parents('tr')[0];
            var PR_Num = $($(row).find('td')[1]).text();
            var item_name = $($(row).find('td')[3]).text();
            var unit = $($(row).find('td')[6]).text();
            var Rate = $($(row).find('td')[8]).text();
            var pr_detail_id = $($(row).find('td')[9]).text();
            var Qty = $($(row).find('td')[4]).text();
            var itemcode = $($(row).find('td')[5]).text();
            var UOM_Qty = $($(row).find('td')[10]).text();

            if (unit == "null") unit = "";
            if (Rate == "null" || Rate == "NaN") Rate = "0";
            if (UOM_Qty == "null" || UOM_Qty == "") UOM_Qty = "0";

            var length = $("#tblItemDescription tr:gt(0)").length + 1;

            // Check for duplicates
            var test_array = $('#tblItemDescription').find('input[name=txtItemCode][value="' + itemcode + '"]');
            if (test_array.length > 0) {
                // ONLY show SweetAlert if it's NOT a bulk operation
                if (!isBulk) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'This Item already added!',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                }
                return false;
            } else {
                $("#tblItemDescription").append('<tr>' +
                    '<td style="padding-top:7px!important;"><input type="hidden" id="txtPRDId' + length + '" name="txtPRDId" value="' + pr_detail_id + '" style="width: 75px !important;text-align:right" />' + length + '</td>' +
                    '<td style="padding-top: 7px!important;"><input type="hidden" name="txtPRNo" id="txtPRNO' + length + '" value="' + PR_Num + '" style="text-align:right ;width:50px !important;font-size:9px;height:20px;padding-top: 7px!important;padding-right: 3px!important;"/>' + PR_Num + '</td>' +
                    '<td style="padding-top: 7px!important;text-align:right!important;"><input type="hidden" name="txtcsno" id="txtcsno' + length + '" value="" style="text-align:right ;width:50px !important;font-size:9px;height:20px;"/></td>' +
                    '<td style="padding-top: 7px!important;padding-right: 3px!important;text-align:right!important;"><input type="hidden" name="txtItemCode" id="txtItemCode' + length + '" value="' + itemcode + '" style="width:50px !important;text-align:right;font-size:9px;height:20px;"/> ' + itemcode + ' </td>' +
                    '<td style="padding-left: 8px!important;padding-top: 7px!important;text-align:left!important;"><input type="hidden" name="txtItemName" id="txtItemName' + length + '" value="' + item_name + '"/> ' + item_name + ' </td>' +
                    '<td style="text-align:left!important;"> <input type="hidden" name="txtUnit" id="txtUnit' + length + '" value="' + unit + '" />' + unit + ' </td>' +
                    '<td><input type="text" id="txtQty' + length + '" style="text-align:right ;width:50px !important;font-size:9px;height:20px;" name="txtQty" onkeyup="CulculateAmonutWithQty(this)" value="' + Qty + '"/></input></td>' +
                    '<td><input type="text" id="txtUOMQty' + length + '" style="text-align:right;width:50px!important;font-size:9px;height:20px;" name="txtUOMQty" value="' + UOM_Qty + '" /></td>' + 
                    '<td>' + '<input type="text" id="txtBonusQty' + length + '"' + ' style="text-align:right;width:50px!important;font-size:9px;height:20px;"' + ' name="txtBonusQty" value="0"' + ' data-toggle="tooltip"' + ' data-placement="bottom"' + ' title="Enter Bonus quantity in Loose"' + '/>' + '</td>' +
                    '<td><input type="text" autocomplete="off" style="text-align:right ;width:50px !important;font-size:9px;height:20px;" onkeyup="CulculateAmonutWithQty(this)" name="txtRate" id="txtRate' + length + '" value="' + Rate + '" /></td>' +
                    '<td><input type="text" autocomplete="off" style="text-align:right ;width:50px !important;font-size:9px;height:20px;" name="txtDisPer" readonly="readonly" id="txtDisPer' + length + '" value="0" /></td>' +
                    '<td style="text-align:right;padding-top: 7px!important"><input type="text" onkeyup="calcTotal()" style="width: 50px !important;text-align:right;font-size:9px;height:20px;text-align:right!important;" id="txtDisAmount' + length + '" name="txtDisAmount"></input></td>' +
                    '<td><select id="ddlSTAX' + length + '" name="ddlSTAX" onchange="calcTotal()" style="text-align:right ;width:50px !important;font-size:9px;height:20px;" class="duplicate ddlSTAX" ><option value="0">0</option></select></td>' +
                    '<td style="padding-top: 7px!important;text-align:right!important"><input type="text" style="text-align:right!important; width:50px !important;font-size:9px;height:20px;" value="0" readonly="readonly" id="txtSalAmount' + length + '" name="txtSalAmount" /></td>' +
                /*'<td><select id="ddlFurtherTax' + length + '" name="ddlFurtherTax" onchange="calcTotal()" style="text-align:right ;width:50px !important;font-size:9px;height:20px;" class="ddlFurtherTax"><option value="0">0</option></select></td>' +*/
                    '<td><input type="text" id="ddlFurtherTax' + length + '" name="ddlFurtherTax" onkeyup="calcTotal()" style="text-align:right ;width:50px !important;font-size:9px;height:20px;" value="0" /></td>'+
                /*'<td><input type="text" readonly="readonly" style="width:50px !important;text-align:right;font-size:9px;height:20px;" value="0" id="txtFurtherTaxAmount' + length + '" name="txtFurtherTaxAmount"></td>' +*/
                    '<td><input type="text" style="width:50px !important;text-align:right;font-size:9px;height:20px;" value="0" id="txtFurtherTaxAmount' + length + '" name="txtFurtherTaxAmount" onkeyup="calcFurtherTaxFromAmount(this)" data-manual="false"></td>' +
                    '<td><select id="ddlAdvanceTax' + length + '" name="ddlAdvanceTax" onchange="calcTotal()" style="text-align:right ;width:50px !important;font-size:9px;height:20px;" class="ddlAdvanceTax"></select></td>' +
                    '<td><input type="text" readonly="readonly" style="width:50px !important;text-align:right;font-size:9px;height:20px;" value="0" id="txtAdvanceTaxAmount' + length + '" name="txtAdvanceTaxAmount"></td>' +
                    '<td style="display:none;"><select id="ddlFed' + length + '" onchange="calcTotal()" style="text-align:right ;width:50px !important;font-size:9px;height:20px;margin-left: 6px;" class="duplicate"><option value="0">0</option>' + (typeof optionsList !== 'undefined' ? optionsList : "") + '</select></td>' +
                    '<td style="padding-top: 7px!important;display:none;"><input type="text" value="0" style="width: 50px !important;text-align:right;font-size:9px;height:20px;" id="txtFedAmount' + length + '" name="txtFedAmount"></input></td>' +
                    '<td><input type="text" readonly style="width:50px!important;text-align:right;font-size:9px;height:20px;" value="0" id="txtBonusAmount' + length + '" name="txtBonusAmount" /></td>' +
                    '<td style="text-align:right ;width:50px !important;font-size:9px;height:20px;padding-top: 7px!important;"><input type="text" style="width:50px !important;text-align:right;font-size:9px;height:20px;" value="0" readonly="readonly" id="txtTotalAmount' + length + '" name="txtTotalAmount"></input></td>' +
                    '<td><input type="text" name="txtddate" id="txtddate' + length + '" class="row-date-picker" style="width:64px !important;text-align:center;font-size:9px;height:20px;" /></td>' +
                    '<td style="padding-top: 7px!important;"><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="font-size: 13px;margin-left: 16px; color: #f30a0a;position:relative;left: -10px;"></i></a> </td></tr>');

                populateTaxddl(length);
                populateAdvanceTaxddl(length);
                populateFurtherTaxddl(length);

                // Heavy UI initializations only run if NOT bulk
                if (!isBulk) {
                    CulculateAmonutWithQty(length);
                    $('[data-toggle="tooltip"]').tooltip();
                    $('#txtddate' + length).datepicker({ dateFormat: 'dd M yy' }).attr('readonly', 'readonly');
                    calcTotal();
                }
            }
        }
       function populateTaxddl(rowId) {
                PageMethods.getwtaxtype(function (response) {
                    var options = '<option value="0">0</option>';
                    $.each(JSON.parse(response), function (key, value) {
                        options += '<option value="' + value.Sales_Tax_ID + '">' + value.Sales_Tax_Perc + '</option>';
                    });
                    $('#ddlSTAX' + rowId).html(options);
                });
            }

            function populateAdvanceTaxddl(rowId, callback) {
                PageMethods.getAdvanceTaxType(function (response) {
                    var options = '<option value="0">0</option>';
                    $.each(JSON.parse(response), function (key, value) {
                        options += '<option value="' + value.Advance_Tax_ID + '">' + value.Advance_Tax_Perc + '</option>';
                    });
                    $('#ddlAdvanceTax' + rowId).html(options);
                    if (typeof callback === 'function') {
                        callback();
                    }
                });
            }

            function populateFurtherTaxddl(rowId) {
                PageMethods.getFurtherTaxType(function (response) {
                    var options = '<option value="0">0</option>';
                    $.each(JSON.parse(response), function (key, value) {
                        options += '<option value="' + value.Further_Tax_ID + '">' + value.Further_Tax_Perc + '</option>';
                    });
                    $('#ddlFurtherTax' + rowId).html(options);
                });
            }
        function httpGet(theUrl) {
            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }
        function LoadPrNoDetail(pr_id) {
            debugger;
            PageMethods.getPurchaseByID(pr_id, function (data) {
                debugger;
                var Test = JSON.parse(data);
                $('#tblPOItemstModelTable tbody tr').remove();
                var rows = "";
                for (var i = 0; i < Test.length; i++) {
                    debugger;
                    rows = '<tr><td><input class="chktd" id="chktd" name="chktd" type="checkbox" style=" margin-top: -2px;" onclick="append(this)"/></td><td style="display:none;">' + Test[i].PR_Num + '</td><td style="display:none;">' + Test[i].Item_ID + '</td><td>' + Test[i].Description + '</td><td>' + parseFloat(Test[i].Qty).toFixed(2)
                        + '</td><td style="display:none;">' + Test[i].Item_Code + '</td><td style="display:none;">' + Test[i].Unit + '</td><td style="display:none;">' + parseFloat(Test[i].Pack_Quantity).toFixed(2) + '</td><td style="display:none;">' + parseFloat(Test[i].UnitPrice).toFixed(2) + '</td><td style="display:none;">' + Test[i].PR_Detail_ID + '</td><td style="display:none;">' + (Test[i].UOM_Qty != null ? Test[i].UOM_Qty : '0') + '</td></tr>'; 
                    $('#tblPOItemstModelTable tbody').append(rows);
                }
                $('#POItemsModel').modal({
                    backdrop: 'static'
                });
            });
        }
        var optionsList = '';
        function loaddata() {
            PageMethods.getDDLlist(function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    debugger;
                    if (value.Type == "Sal") {
                        optionsList += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                    else {
                        optionsList += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                });
            });
        }
      $(document).ready(function () {
    // ✅ Show page loader immediately
    $('#page-loader').removeClass('hidden').show();
    
    // Initialize page
    UserRights();
    GetWareHouseCondition();
    
    $('#ddlWarehouse').change(function () {
        $("#ddlWarehouse").attr('disabled', true);
    });
    
    $('[id*=checkHeader]').click(function () {
        var isTrue = $(this).is(':checked');
        $('.chktd').prop('checked', isTrue);
        if (isTrue) {
            var $rows = $("#tblPOItemstModelTable tr:gt(0) input[type=checkbox]:checked");
            var index = 0;
            function processBatch() {
                var batchSize = 50;
                var end = Math.min(index + batchSize, $rows.length);
                for (; index < end; index++) {
                    append($rows[index], true);
                }
                if (index < $rows.length) {
                    requestAnimationFrame(processBatch);
                } else {
                    $('.row-date-picker').datepicker({ dateFormat: 'dd M yy' }).attr('readonly', 'readonly');
                    $('[data-toggle="tooltip"]').tooltip();
                    calcTotal();
                    Swal.fire({
                        icon: 'success',
                        title: 'Success',
                        text: 'Items processed successfully.',
                        timer: 1500,
                        showConfirmButton: false
                    });
                }
            }
            processBatch();
        }
    });
    
    $('#ddlWarehouse').select2();
    
    // ✅ Load dropdowns IMMEDIATELY (NO setTimeout delay!)
    loaddata();
    FillWarehouse();
    FillStaxtype();
    FillAdvancetaxtype();
    FillFurtherTaxType();
    
    // Set default dates
    var currentDate = new Date();
    var formattedDate = $.datepicker.formatDate('dd M yy', currentDate);
    $("#ctl00_MainContent_txtPurchase_Date").val(formattedDate).datepicker({ dateFormat: 'dd M yy', readOnly: true });
    $("#ctl00_MainContent_txtdueDate").val(formattedDate).datepicker({ dateFormat: 'dd M yy', readOnly: true });
    
    // ✅ Load PO data ONLY if PO_ID exists in query string
    <% if (Request.QueryString["PO_ID"] != null) { %>
    var PO_ID = '<%= Request.QueryString["PO_ID"]%>';
    // Wait for dropdowns to populate (500ms is enough, NOT 3000ms)
    setTimeout(function() {
        LoadPurchaseOrderData(PO_ID);
        $('#btnSave').val('Update');
        // Hide loader after PO data loaded
        setTimeout(function() {
            $('#page-loader').addClass('hidden').fadeOut(300);
        }, 500);
    }, 500);
    <% } else { %>
    // No PO_ID - hide loader immediately after initialization
    setTimeout(function() {
        $('#page-loader').addClass('hidden').fadeOut(300);
    }, 500);
    <% } %>
    
    $('.token-input-list').css('width', '666px !important', 'margin-left: 1px;');
    var PO_Id = '<%= Request.QueryString["PO_ID"] %>';
    if (PO_Id == "") {
        $('#btnPrint').hide();
        GetNewPurchaseNo();
    }
    
    $('select').select2();
    
    $('#btnPRSave').on('click', function () {
        var pr_id = $("#ctl00_MainContent_ddlPrNo").val();
        LoadPrNoDetail(pr_id);
        $('#ctl00_MainContent_txtRemarks').focus();
    });
    
    // Check status after load
    setTimeout(function () {
        var status = $('#ctl00_MainContent_txtStatus').val();
        if (status == "Approved") {
            UserUnApproveButtonRights();
            $('#btnSave').attr("disabled", 'disabled');
            $('#btnSave').hide();
            $('#btncancel').hide();
        }
        if (status == "Cancelled") {
            $('#btnSave').attr("disabled", 'disabled');
            $('#btnSave').hide();
            $('#btncancel').hide();
        }
        if (status == "Created") {
            $('#btnSave').show();
            $('#btnUnApprove').hide();
        }
    }, 1000);
    
    $('#txtItem').tokenInput("../../json.aspx?Table=INV_ItemsForPR", {
        tokenLimit: 1,
        onAdd: function (item) {
            try {
                $("#hditemID").val(item.id);
                append();
                $('#btnGIR').attr('disabled', true);
                $('#btnGIR').css('pointer-events', 'none');
                $('#ctl00_MainContent_ddlGIR').css('pointer-events', 'none');
                $('#ctl00_MainContent_ddlGIR').attr('disabled', true);
            } catch (err) {
                alert(err.message);
            }
        }
    });
    
    $('#txtItem').focus();
    
    $('#btnGetAllItems').on('click', function () {
        $('#ctl00_MainContent_ddlPrNo').prop('disabled', true);
        LoadAllitem('');
    });
    
    $('#searchInput').on('keyup', function () {
        var searchText = $(this).val().trim();
        LoadAllitem(searchText);
    });
});



        function UserRights() {
            debugger;
            $.ajax({
                type: "POST",
                url: "PurchaseOrder.aspx/UserEntryRights",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var hasRights = response.d;
                    debugger;
                    if (hasRights) {
                        debugger;
                        $('#btnSave').show();
                    } else {
                        $('#btnSave').hide();
                    }
                },
                failure: function (response) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Failed to retrieve user rights.',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                }
            });
        }



        function GetNewPurchaseNo() {
            PageMethods.GetNewPurchaseNo(function (resp) {
                $('#ctl00_MainContent_txtPurchase_No').val(resp);
            },
                function (error) {
                    alert(error.get_message());
                });
        }
        function LoadPurchaseOrderData(PO_ID) {
            PageMethods.LoadPOHeaderDetail(PO_ID, function (resp) {
                var data = JSON.parse(resp);
                debugger;
                var datetime = $.datepicker.formatDate('dd M yy', new Date(parseInt(data.PO_Date.substring(6, 19))));
                $('#ctl00_MainContent_txtPurchase_Date').val(datetime);
                if (data.Due_Date != null || data.Due_Date != undefined) {
                    var datetime = $.datepicker.formatDate('dd M yy', new Date(parseInt(data.Due_Date.substring(6, 19))));
                    $('#ctl00_MainContent_txtdueDate').val(datetime);
                }
                $('#hdnPurchase_ID').val(data.PO_ID);
                $('#txttranstype').val(data.Transaction_Type);
                $('#txtcsmasterid').val(data.CS_Master_ID);
                $('#ctl00_MainContent_txtPurchase_No').val(data.PO_No);
                $("#ctl00_MainContent_txtPurchase_Reference").val(data.Ref_No);
                setTimeout(function () {
                    $('#ctl00_MainContent_ddlTerm').val(data.Term_ID).trigger('change');
                }, 1000);
                setTimeout(function () {
                    $('#ctl00_MainContent_ddlVendor').val(data.Vendor_ID).trigger('change');
                }, 1000);
                $('#ctl00_MainContent_txtRemarks').val(data.Remarks);
                $('#ctl00_MainContent_txtWarranty').val(data.Warranty);
                $('#ctl00_MainContent_txtDisclaimer').val(data.Disclaimer);
                $('#ctl00_MainContent_Freight').val(data.Frieght_Charges);
                $('#txtfreight_charges').val(data.Frieght_Charges);
                setTimeout(function () {
                    $('#ctl00_MainContent_ddlPOType').val(data.PO_Type).trigger('change');
                }, 1000)
                setTimeout(function () {
                    $('#ddlWarehouse').val(data.Ware_House).trigger('change');
                }, 1000);
                setTimeout(function () {
                    $('#ctl00_MainContent_ddlpayment').val(data.Payment_Terms).trigger('change');
                }, 1000)
                setTimeout(function () {
                    $('#ctl00_MainContent_ddlDelivery').val(data.Delivery_Terms).trigger('change');
                }, 1000)
                $('#txtSub_Total').val(data.Sub_Total);
                $('#txtTotalDiscAmt').val(data.Discount);
                $('#ctl00_MainContent_txtTotalDiscAmt').val(data.Discount);
                $('#ctl00_MainContent_Net_Amount').val(data.PO_Amount);
                $('#txtst_amou').val(data.Total_ST_Amount);
                $('#ctl00_MainContent_txtStatus').val(data.Status);
                $('#chkManual').prop('checked', data.IsManual === true);
                $('#chkByDefault').prop('checked', data.IsByDefault === true);
                LoadPOItemDetail(PO_ID);
                $('#txtAdv_amou').val(data.Total_Adv_Amt);
                $('#txtFurther_amou').val(data.Total_Further_Amt);
            },
                function (error) {
                    alert(error.get_message());
                })
        }
      // ============================================================================
// HELPER FUNCTIONS (define once at top of your JS file)
// ============================================================================

        // ============================================================================
        // OPTIONAL: Chunked rendering for 500+ items (uncomment if needed)
        // ============================================================================
        /*
        function LoadPOItemDetail_Chunked(PO_ID, chunkSize = 50) {
            console.time('LoadPOItemDetail_Chunked');
            
            PageMethods.getDDLlist(function (Tests) {
                var testsData = (typeof Tests === "string") ? JSON.parse(Tests) : Tests;
                var optionsSal = '', optionFed = '';
                if (testsData && testsData.forEach) {
                    testsData.forEach(function (item) {
                        var opt = '<option value="' + item.DataValueName + '">' + item.DataValueDescription + '</option>';
                        if (item.Type === "Sal") optionsSal += opt;
                        else optionFed += opt;
                    });
                }
        
                PageMethods.LoadPOItemDetail(PO_ID, function (resp) {
                    var data = (typeof resp === "string") ? JSON.parse(resp) : resp;
                    if (!data || !data.forEach || data.length === 0) {
                        console.timeEnd('LoadPOItemDetail_Chunked');
                        return;
                    }
        
                    var tbody = $('#tblItemDescription tbody');
                    tbody.empty();
                    var index = 0;
        
                    function renderChunk() {
                        var end = Math.min(index + chunkSize, data.length);
                        var rowsHTML = [];
                        
                        for (; index < end; index++) {
                            var value = data[index];
                            var key = index;
                            var idx = key + 1;
                            
                            var TrnsDate = "";
                            if (value.Delivery_Date) {
                                try {
                                    var ms = parseInt(value.Delivery_Date.substring(6, 19));
                                    TrnsDate = $.datepicker.formatDate('dd M yy', new Date(ms));
                                } catch (e) { TrnsDate = ""; }
                            }
                            var pr_id = sanitizePrId(safeVal(value.pr_id, ""));
                            
                            // Build row (same structure as main function)
                            var row = '<tr data-index="' + idx + '">...</tr>'; // Reuse full row HTML from above
                            rowsHTML.push(row);
                        }
                        
                        tbody.append(rowsHTML.join(''));
                        
                        if (index < data.length) {
                            requestAnimationFrame(renderChunk); // Non-blocking
                        } else {
                            // Finalize after all chunks
                            data.forEach(function (value, key) {
                                var idx = key + 1;
                                $('#ddlSTAX' + idx).val(safeVal(value.SalTax_Id, 0));
                                $('#ddlFurtherTax' + idx).val(safeVal(value.FurtherTax_Percentage, 0));
                                $('#ddlAdvanceTax' + idx).val(safeVal(value.AdvanceTax_ID, 0));
                                $('#ddlFed' + idx).val(safeVal(value.FedPercent_Id, 0));
                            });
                            $('input.txtddate').datepicker({ dateFormat: 'dd M yy' }).attr('readonly', 'readonly');
                            if (typeof calcTotal === 'function') calcTotal();
                            $('#btnSave').val('Update');
                            console.timeEnd('LoadPOItemDetail_Chunked');
                        }
                    }
                    renderChunk();
                }, function(error) {
                    console.timeEnd('LoadPOItemDetail_Chunked');
                    alert(error.get_message ? error.get_message() : error);
                });
            });
        }
        */
        //oldPOcode 16 march 


        //function LoadPOItemDetail(PO_ID) {
        //    var optionsSal = '';
        //    var optionFed = '';
        //    PageMethods.getDDLlist(function (Tests) {
        //        debugger
        //        $.each(JSON.parse(Tests), function (key, value) {
        //            debugger;
        //            if (value.Type == "Sal") {
        //                optionsSal += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
        //            }
        //            else {
        //                optionFed += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
        //            }
        //        });
        //    });
        //    PageMethods.LoadPOItemDetail(PO_ID, function (resp) {
        //        debugger;
        //        var data = (JSON.parse(resp));
        //        selectedOptions = data;
        //        var TrnsDate = '';
        //        $.each(data, function (key, value) {
        //            debugger;

        //            if (value.Delivery_Date != null) {
        //                TrnsDate = $.datepicker.formatDate('dd M yy', new Date(parseInt(data[key].Delivery_Date.substring(6, 19))));
        //            }
        //            else {
        //                TrnsDate = ""
        //            }
        //            if (value.Unit == null) value.Unit = "";
        //            if (value.UnitName == null) value.UnitName = "";
        //            if (value.SalTax_Id == null) value.SalTax_Id = 0;
        //            if (value.SalTax_Amount == null) value.SalTax_Amount = 0;
        //            if (value.Fed_Percentage == null) value.Fed_Percentage = 0;
        //            if (value.Discount_Amount == null) value.Discount_Amount = 0;
        //            if (value.Discount_Percentage == null) value.Discount_Percentage = 0;
        //            if (value.pr_id.includes("ERROR") || value.pr_id.includes("Execute") || value.pr_id.includes("There")) value.pr_id = "";
        //            if (value.CS_Ven_No == null) value.CS_Ven_No = "";
        //            if (value.PRDetailId == null) value.PRDetailId = 0;
        //            if (value.UOM_Qty == null) value.UOM_Qty = 0;

        //            var rowlength = $('#tblItemDescription tr').length;
        //            var row = '<tr>' +
        //                '<td style="padding-top: 7px!important;text-align:right!important;"><input type="hidden" id="txtPRDId' + (key + 1) + '" name="txtPRDId" value="' + value.PRDetailId + '" />' + (key + 1) + '</td>' +
        //                '<td style="padding-top: 7px!important;text-align:right!important;"><input type="hidden" name="txtPRNo" id="txtPRNO' + (key + 1) + '"  value="' + value.pr_id + '"  style="text-align:right ;width:50px !important;font-size:9px;height:20px;"/>' + value.pr_id + '</td>' +
        //                '<td style="padding-top: 7px!important;text-align:right!important;"><input type="hidden" name="txtcsno" id="txtcsno' + (key + 1) + '"  value="' + value.CS_Ven_No + '"  style="text-align:right ;width:50px !important;font-size:9px;height:20px;"/>' + value.CS_Ven_No + '</td>' +
        //                '<td style="padding-top: 7px!important;text-align:right!important;"><input type="hidden" name="txtItemCode" id="txtItemCode' + (key + 1) + '"  value="' + value.Item_Code + '" /> ' + value.Item_Code + ' </td>' +
        //                '<td style="padding-left: 8px!important;padding-top: 7px!important;text-align:left!important;"><input type="hidden" name="txtItemName" id="txtItemName' + (key + 1) + '"  value="' + value.Item_Name + '" /> ' + value.Item_Name + ' </td>' +
        //                '<td style="text-align:left!important;"><input type="hidden" name="txtUnit" id="txtUnit' + (key + 1) + '"  value="' + value.Unit + '" />' + value.Unit + ' </td>' +
        //                '<td><input type="text"  id="txtQty' + (key + 1) + '" name="txtQty" style="text-align:right ;width:50px !important;font-size:9px;height:20px;" onkeyup="CulculateAmonutWithQty(this)" value=' + parseFloat(value.Qty).toFixed(2) + '></input></td>' +
        //                '<td><input type="text" id="txtUOMQty' + (key + 1) + '" name="txtUOMQty" style="text-align:right;width:50px!important;font-size:9px;height:20px;" value="' + (value.UOM_Qty != null ? parseFloat(value.UOM_Qty).toFixed(2) : '0') + '" /></td>' +
        //                '<td><input type="text" style="text-align:right;width:50px!important;font-size:9px;height:20px;" value="' + (value.Bonus_Qty != null ? parseFloat(value.Bonus_Qty).toFixed(2) : '0') + '" id="txtBonusQty' + (key + 1) + '" name="txtBonusQty" /></td>' +
        //                '<td><input type="text" name="txtRate" style="text-align:right ;width:50px !important;font-size:9px;height:20px" onkeyup="CulculateAmonutWithQty(this)" id="txtRate' + (key + 1) + '"  value="' + parseFloat(value.Rate).toFixed(2) + '" /></td>' +
        //                '<td><input type="text" autocomplete="off" style="text-align:right ;width:50px !important;font-size:9px;height:20px;" readonly="readonly"  name="txtDisPer" id="txtDisPer' + (key + 1) + '"  value="' + value.Discount_Percentage + '" /></td>' +
        //                '<td style="text-align:right;padding-top: 7px!important;"><input type="text"  onkeyup="calcTotal()" value="' + value.Discount_Amount + '" style="width: 50px !important;text-align:right;font-size:9px;height:20px;text-align:right!important;"  id="txtDisAmount' + (key + 1) + '" name="txtDisAmount" ></input></td>' +
        //                '<td><select id="ddlSTAX' + (key + 1) + '" name="ddlSTAX" class="ddlSTAX" onchange="calcTotal()" style="text-align:right ;width:50px !important;font-size:9px;height:20px;"></select></td>' +
        //                '<td style="padding-top: 7px!important;"><input type="text" style="text-align:right!important;width:50px !important;font-size:9px;height:20px;" readonly="readonly" value="' + value.SalTax_Amount + '"  id="txtSalAmount' + (key + 1) + '" name="txtSalAmount" ></input></td>' +
        //            /*'<td><select id="ddlFurtherTax' + (key + 1) + '" name="ddlFurtherTax" class="ddlFurtherTax" onchange="calcTotal()" style="text-align:right ;width:50px !important;font-size:9px;height:20px;"><option value="0">0</option></select></td>' +*/
        //                '<td><input type="text" id="ddlFurtherTax' + (key + 1) + '" name="ddlFurtherTax" onkeyup="calcTotal()" style="text-align:right ;width:50px !important;font-size:9px;height:20px;" value="' + (value.FurtherTax_Percentage != null ? value.FurtherTax_Percentage : '0') + '" /></td>' +
        //                '<td><input type="text" readonly="readonly" style="width:50px !important;text-align:right;font-size:9px;height:20px;" value="' + (value.FurtherTax_Amount !== null && value.FurtherTax_Amount !== undefined ? value.FurtherTax_Amount : '0') + '" id="txtFurtherTaxAmount' + (key + 1) + '" name="txtFurtherTaxAmount"></td>' +
        //                '<td style="display:none;"><select id="ddlFed' + (key + 1) + '" onchange="calcTotal()" style="text-align:right ;width:50px !important;font-size:9px;height:20px;margin-left: 9px;" ><option value="0">0</option>' + optionFed + '</select></td>' +
        //                '<td><select id="ddlAdvanceTax' + (key + 1) + '" name="ddlAdvanceTax" class="ddlAdvanceTax" onchange="calcTotal()" style="text-align:right ;width:50px !important;font-size:9px;height:20px;">' +
        //                '<option value="0">0</option>' +
        //                '</select></td>' +
        //                '<td><input type="text" readonly="readonly" style="width:50px !important;text-align:right;font-size:9px;height:20px;" ' +
        //                'value="' + value.AdvanceTax_Amount + '" id="txtAdvanceTaxAmount' + (key + 1) + '" name="txtAdvanceTaxAmount"></td>' +

        //                '<td style="padding-top: 7px!important;display:none;"><input type="hidden" value="' + value.Fed_Percentage + '" style="text-align:right ;width:50px !important;font-size:9px;height:20px;"  id="txtFedAmount' + (key + 1) + '" name="txtFedAmount" style="text-align:right ;width:59px !important;font-size:9px;height:20px;"></input>' + value.Fed_Percentage + '</td>' +
        //                '<td><input type="text" readonly style="width:50px!important;text-align:right;font-size:9px;height:20px;" value="' + (value.Bonus_Tax != null ? parseFloat(value.Bonus_Tax).toFixed(2) : '0') + '" id="txtBonusAmount' + (key + 1) + '" name="txtBonusAmount" /></td>' +
        //                '<td style="text-align:right ;width:50px !important;font-size:9px;height:20px;padding-top: 7px!important;"><input type="text" style="width:50px !important;text-align:right;font-size:9px;height:20px;" value="' + value.Amount + '" readonly="readonly"  id="txtTotalAmount' + (key + 1) + '" name="txtTotalAmount"></input></td>' +
        //                '<td><input type="text" name="txtddate" id="txtddate' + (key + 1) + '" value="' + TrnsDate + '" style="text-align:right ;width:64px !important;font-size:9px;height:20px;" /></td>' +
        //                '<td style="padding-top: 7px!important;"><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="font-size: 13px;margin-left: 16px; color: #f30a0a;position:relative;left: -10px;" i=""></i></a> </td></tr>';
        //            $('#tblItemDescription tbody').append(row);

        //        });

        //        setTimeout(function () {
        //            $.each(selectedOptions, function (key, value) {
        //                debugger;
        //                $('#ddlSTAX' + (key + 1)).val(value.SalTax_Id).trigger('change');
        //                // $('#ddlFurtherTax' + (key + 1)).val(value.FurtherTax_Id).trigger('change');
        //                $('#ddlFurtherTax' + (key + 1)).val(value.FurtherTax_Percentage != null ? value.FurtherTax_Percentage : '0');
        //                $('#ddlAdvanceTax' + (key + 1)).val(value.AdvanceTax_ID).trigger('change');
        //                $("#ddlFed" + (key + 1)).val(value.FedPercent_Id);
        //                calcTotal();
        //            });
        //        }, 4500);
        //        setTimeout(function () {
        //            $.each(selectedOptions, function (key, value) {
        //                $('#txtAdvanceTaxAmount' + (key + 1)).val(value.AdvanceTax_Amount);
        //            });
        //        }, 4500);
        //        var count = $('#tblItemDescription tr').length - 1;
        //        for (i = 1; i <= count; i++) {
        //            $('#txtExpirDate' + i).datepicker();
        //        }
        //        $('input[name="txtddate"]').datepicker({ dateFormat: 'dd M yy' }).attr('readonly', 'readonly');
        //        $('#btnSave').val('Update');
        //    },
        //        function (error) {
        //            alert(error.get_message());
        //        })
        //}
// ============================================================================
// HELPER FUNCTIONS (define once at top of your JS file)
// ============================================================================
// ============================================================================
// HELPER FUNCTIONS (Define once at top of your JS file)
// ============================================================================

// Safe value getter - handles null/undefined
// ============================================================================
// HELPER FUNCTIONS
// ============================================================================
function safeVal(v, def) {
    return (v == null || v === undefined) ? def : v;
}

function sanitizePrId(val) {
    if (!val) return "";
    if (val.includes("ERROR") || val.includes("Execute") || val.includes("There")) {
        return "";
    }
    return val;
}

var calcTotalTimer = null;
var calcTotalRaf = null;

function scheduleCalcTotal(delay) {
    var wait = (typeof delay === 'number') ? delay : 80;

    if (calcTotalTimer) {
        clearTimeout(calcTotalTimer);
    }

    calcTotalTimer = setTimeout(function () {
        calcTotalTimer = null;

        if (window.requestAnimationFrame) {
            if (calcTotalRaf) {
                cancelAnimationFrame(calcTotalRaf);
            }
            calcTotalRaf = requestAnimationFrame(function () {
                calcTotalRaf = null;
                runCalcTotalCore();
            });
        } else {
            runCalcTotalCore();
        }
    }, wait);
}

function calcTotal(forceNow) {
    if (forceNow === true) {
        runCalcTotalCore();
        return;
    }

    scheduleCalcTotal();
}

// ============================================================================
// MAIN: LoadPOItemDetail - FIXED for dropdown timing + calculations
// ============================================================================
// ============================================================================
// MAIN: LoadPOItemDetail - FIXED for Advance Tax loading in Edit Mode
// ============================================================================
function LoadPOItemDetail(PO_ID) {
    console.time('LoadPOItemDetail');
    $('#tblItemDescription tbody').empty();
    
    PageMethods.LoadPOItemDetail(PO_ID,
        function (resp) {
            var data = (typeof resp === "string") ? JSON.parse(resp) : resp;
            if (!data || !Array.isArray(data) || data.length === 0) {
                console.timeEnd('LoadPOItemDetail');
                $('#btnSave').val('Update');
                return;
            }
            
            console.log('Loading ' + data.length + ' PO items...');
            
            // Build ALL rows in memory FIRST
            var rowsHTML = [];
            data.forEach(function (value, key) {
                var idx = key + 1;
                
                // Format date
                var TrnsDate = "";
                if (value.Delivery_Date) {
                    try {
                        var ms = parseInt(value.Delivery_Date.substring(6, 19));
                        TrnsDate = $.datepicker.formatDate('dd M yy', new Date(ms));
                    } catch (e) { TrnsDate = ""; }
                }
                
                var pr_id = sanitizePrId(safeVal(value.pr_id, ""));
                
                // Build row with ORIGINAL IDs
                var row = '<tr data-index="' + idx + '">' +
                    '<td style="padding-top:7px!important;"><input type="hidden" id="txtPRDId' + idx + '" name="txtPRDId" value="' + safeVal(value.PRDetailId, 0) + '" />' + idx + '</td>' +
                    '<td style="padding-top: 7px!important;"><input type="hidden" name="txtPRNo" id="txtPRNO' + idx + '" value="' + pr_id + '" style="text-align:right ;width:50px !important;font-size:9px;height:20px;"/>' + pr_id + '</td>' +
                    '<td style="padding-top: 7px!important;text-align:right!important;"><input type="hidden" name="txtcsno" id="txtcsno' + idx + '" value="' + safeVal(value.CS_Ven_No, "") + '" style="text-align:right ;width:50px !important;font-size:9px;height:20px;"/>' + safeVal(value.CS_Ven_No, "") + '</td>' +
                    '<td style="padding-top: 7px!important;padding-right: 3px!important;text-align:right!important;"><input type="hidden" name="txtItemCode" id="txtItemCode' + idx + '" value="' + safeVal(value.Item_Code, "") + '" style="width:50px !important;text-align:right;font-size:9px;height:20px;"/> ' + safeVal(value.Item_Code, "") + ' </td>' +
                    '<td style="padding-left: 8px!important;padding-top: 7px!important;text-align:left!important;"><input type="hidden" name="txtItemName" id="txtItemName' + idx + '" value="' + safeVal(value.Item_Name, "") + '"/> ' + safeVal(value.Item_Name, "") + ' </td>' +
                    '<td style="text-align:left!important;"><input type="hidden" name="txtUnit" id="txtUnit' + idx + '" value="' + safeVal(value.Unit, "") + '" />' + safeVal(value.Unit, "") + ' </td>' +
                    '<td><input type="text" id="txtQty' + idx + '" name="txtQty" style="text-align:right ;width:50px !important;font-size:9px;height:20px;" onkeyup="CulculateAmonutWithQty(this)" value="' + parseFloat(safeVal(value.Qty, 0)).toFixed(2) + '"/></td>' +
                    '<td><input type="text" id="txtUOMQty' + idx + '" name="txtUOMQty" style="text-align:right;width:50px!important;font-size:9px;height:20px;" value="' + parseFloat(safeVal(value.UOM_Qty, 0)).toFixed(2) + '"/></td>' +
                    '<td><input type="text" id="txtBonusQty' + idx + '" name="txtBonusQty" style="text-align:right;width:50px!important;font-size:9px;height:20px;" value="' + parseFloat(safeVal(value.Bonus_Qty, 0)).toFixed(2) + '"/></td>' +
                    '<td><input type="text" name="txtRate" style="text-align:right ;width:50px !important;font-size:9px;height:20px" onkeyup="CulculateAmonutWithQty(this)" id="txtRate' + idx + '" value="' + parseFloat(safeVal(value.Rate, 0)).toFixed(2) + '" /></td>' +
                    '<td><input type="text" autocomplete="off" style="text-align:right ;width:50px !important;font-size:9px;height:20px;" readonly="readonly" name="txtDisPer" id="txtDisPer' + idx + '" value="' + safeVal(value.Discount_Percentage, 0) + '" /></td>' +
                    '<td style="text-align:right;padding-top: 7px!important;"><input type="text" onkeyup="calcTotal()" value="' + safeVal(value.Discount_Amount, 0) + '" style="width: 50px !important;text-align:right;font-size:9px;height:20px;text-align:right!important;" id="txtDisAmount' + idx + '" name="txtDisAmount"></input></td>' +
                    '<td><select id="ddlSTAX' + idx + '" name="ddlSTAX" style="text-align:right ;width:50px !important;font-size:9px;height:20px;" class="ddlSTAX"><option value="0">0</option></select></td>' +
                    '<td style="padding-top: 7px!important;"><input type="text" style="text-align:right!important;width:50px !important;font-size:9px;height:20px;" readonly="readonly" value="" id="txtSalAmount' + idx + '" name="txtSalAmount"></input></td>' +
                    '<td><input type="text" id="ddlFurtherTax' + idx + '" name="ddlFurtherTax" style="text-align:right ;width:50px !important;font-size:9px;height:20px;" value="' + safeVal(value.FurtherTax_Percentage, 0) + '" /></td>' +
                    '<td><input type="text" readonly="readonly" style="width:50px !important;text-align:right;font-size:9px;height:20px;" value="' + safeVal(value.FurtherTax_Amount, 0) + '" id="txtFurtherTaxAmount' + idx + '" name="txtFurtherTaxAmount"></td>' +
                    '<td style="display:none;"><select id="ddlFed' + idx + '" style="text-align:right ;width:50px !important;font-size:9px;height:20px;margin-left: 9px;" ><option value="0">0</option>' + (typeof optionsList !== 'undefined' ? optionsList : "") + '</select></td>' +
                    '<td><select id="ddlAdvanceTax' + idx + '" name="ddlAdvanceTax" style="text-align:right ;width:50px !important;font-size:9px;height:20px;" class="ddlAdvanceTax"><option value="0">0</option></select></td>' +
                    '<td><input type="text" readonly="readonly" style="width:50px !important;text-align:right;font-size:9px;height:20px;" value="" id="txtAdvanceTaxAmount' + idx + '" name="txtAdvanceTaxAmount"></td>' +
                    '<td style="padding-top: 7px!important;display:none;"><input type="hidden" value="' + safeVal(value.Fed_Percentage, 0) + '" style="text-align:right ;width:50px !important;font-size:9px;height:20px;" id="txtFedAmount' + idx + '" name="txtFedAmount"></input></td>' +
                    '<td><input type="text" readonly style="width:50px!important;text-align:right;font-size:9px;height:20px;" value="' + parseFloat(safeVal(value.Bonus_Tax, 0)).toFixed(2) + '" id="txtBonusAmount' + idx + '" name="txtBonusAmount" /></td>' +
                    '<td style="text-align:right ;width:50px !important;font-size:9px;height:20px;padding-top: 7px!important;"><input type="text" style="width:50px !important;text-align:right;font-size:9px;height:20px;" value="' + safeVal(value.Amount, 0) + '" readonly="readonly" id="txtTotalAmount' + idx + '" name="txtTotalAmount"></input></td>' +
                    '<td><input type="text" name="txtddate" id="txtddate' + idx + '" value="' + TrnsDate + '" style="text-align:right ;width:64px !important;font-size:9px;height:20px;" /></td>' +
                    '<td style="padding-top: 7px!important;"><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="font-size: 13px;margin-left: 16px; color: #f30a0a;position:relative;left: -10px;"></i></a> </td>' +
                    '</tr>';
                rowsHTML.push(row);
            });
            
            // SINGLE DOM insertion
            $('#tblItemDescription tbody').html(rowsHTML.join(''));
            console.log('DOM rendered, populating dropdowns...');
            
            // Set up counters to track when all async operations complete
            let pendingOperations = data.length * 2; // For both populateTaxddl and populateAdvanceTaxddl
            let allOperationsComplete = false;
            
            function checkAllComplete() {
                pendingOperations--;
                if (pendingOperations <= 0 && !allOperationsComplete) {
                    allOperationsComplete = true;
                    
                    // Now set all dropdown values and calculated fields
                    console.log('All dropdowns populated, setting values...');
                    
                    data.forEach(function (value, key) {
                        var idx = key + 1;
                        
                        // Set SalTax dropdown value
                        var salTaxId = safeVal(value.SalTax_Id, "0") + "";
                        var $ddlSTAX = $('#ddlSTAX' + idx);
                        if ($ddlSTAX.find('option[value="' + salTaxId + '"]').length > 0) {
                            $ddlSTAX.val(salTaxId);
                        }
                        $('#txtSalAmount' + idx).val(safeVal(value.SalTax_Amount, 0));
                        
                        // Set AdvanceTax dropdown value
                        var advTaxId = safeVal(value.AdvanceTax_ID, "0") + "";
                        var $ddlAdv = $('#ddlAdvanceTax' + idx);
                        if ($ddlAdv.find('option[value="' + advTaxId + '"]').length > 0) {
                            $ddlAdv.val(advTaxId);
                        }
                        $('#txtAdvanceTaxAmount' + idx).val(safeVal(value.AdvanceTax_Amount, 0));
                        
                        // Set other values
                        $('#ddlFurtherTax' + idx).val(safeVal(value.FurtherTax_Percentage, 0));
                        $('#txtFurtherTaxAmount' + idx).val(safeVal(value.FurtherTax_Amount, 0));
                        $('#ddlFed' + idx).val(safeVal(value.FedPercent_Id, 0));
                        $('#txtBonusAmount' + idx).val(parseFloat(safeVal(value.Bonus_Tax, 0)).toFixed(2));
                        $('#txtTotalAmount' + idx).val(safeVal(value.Amount, 0));
                    });
                    
                    // Initialize datepickers
                    $('input[name="txtddate"]').datepicker({
                        dateFormat: 'dd M yy'
                    }).attr('readonly', 'readonly');
                    
                    // SINGLE calculation call after everything is set
                    console.log('Running final calcTotal()...');
                    if (typeof calcTotal === 'function') {
                        calcTotal();
                    }
                    
                    $('#btnSave').val('Update');
                    console.timeEnd('LoadPOItemDetail');
                }
            }
            
            // Populate dropdowns for all rows
            data.forEach(function (value, key) {
                var idx = key + 1;
                
                // Populate tax dropdown
                populateTaxddl(idx);
                
                // Populate advance tax dropdown with callback
                populateAdvanceTaxddl(idx, function() {
                    checkAllComplete();
                });
                
                // For populateTaxddl, we need to know when it's done
                // If it's synchronous, call checkAllComplete immediately
                // If it's async, modify populateTaxddl to accept a callback
                setTimeout(checkAllComplete, 100); // Fallback timeout
            });
            
        },
        function (error) {
            console.timeEnd('LoadPOItemDetail');
            alert(error.get_message ? error.get_message() : error);
        }
    );
}

// Helper function to modify populateTaxddl to accept a callback
// Modify your existing populateTaxddl function or create a new one
function populateTaxddlWithCallback(index, callback) {
    // Your existing populateTaxddl logic
    populateTaxddl(index);
    
    // If populateTaxddl is synchronous, call callback immediately
    if (callback) setTimeout(callback, 50);
}
        function httpGet(theUrl) {
     
            
            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }
        function GetAccountCodeAndName() {
            var name = '';
            $.each($("#ctl00_MainContent_txtItem_Description").tokenInput('get'), function () {
                if (name != '') {
                    name += ",";
                }
                name += this.name;
            });
            $("#hdfitem_name").val(name);
        }
        function getprNoBy_WareHouse(item) {
            debugger;
            var optionsPR = '';
            var Warehouse;
            Warehouse = item.value;
            if (typeof Warehouse == "undefined" || Warehouse == "") {
                VendorId = item;
            }
            PageMethods.GetPRNoByWarehouse(Warehouse, function (res) {
                var item = JSON.parse(res);
                optionsPR = '<option value="0">Please Select</option>';
                $.each(item, function (key, value) {
                    optionsPR += '<option value="' + value.PR_Id + '" >' + value.PR_Num + '</option>';
                });
                $("#ctl00_MainContent_ddlPrNo option").remove();
                $('#ctl00_MainContent_ddlPrNo').html(optionsPR);
            });
        }
        function getprNoBy() {
            debugger;
            var optionsPR = '';
            var Warehouse;

            PageMethods.GetPRNoBy( function (res) {
                var item = JSON.parse(res);
                optionsPR = '<option value="0">Please Select</option>';
                $.each(item, function (key, value) {
                    optionsPR += '<option value="' + value.PR_Id + '" >' + value.PR_Num + '</option>';
                });
                $("#ctl00_MainContent_ddlPrNo option").remove();
                $('#ctl00_MainContent_ddlPrNo').html(optionsPR);
            });
        }
        var warehouseCond;
        function GetWareHouseCondition() {

            $.ajax({
                type: "POST",
                url: "PurchaseOrder.aspx/GetWareHouseCondition",
                data: JSON.stringify({}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    warehouseCond = JSON.parse(response.d);
                    if (warehouseCond == '01') {
                        $('#warehouse').show();
                    }
                    else {
                        $('#warehouse').hide();
                        getprNoBy();
                    }
                },
                error: function (error) {
                    console.error("Error fetching items", error);
                }
            });
        }




    </script>
    <script type="text/javascript">
        function HideItemPopup() {
            document.getElementById('oItemPopup').style.display = "none";
            document.getElementById('oDarkScreen').style.display = "none";
        }
        function PerformPRSearch() {
            debugger;
            var PRId = $('#ctl00_MainContent_ddlPrNo').val();
            var optionFed = '';
            PageMethods.getDDLlist(function (Tests) {
                debugger
                $.each(JSON.parse(Tests), function (key, value) {
                    debugger;
                    if (value.Type == "Sal") {
                        optionsSal += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                    else {
                        optionFed += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                });
            });
            if (PRId != "") {
                PageMethods.getPurchaseByID(PRId, function (res) {
                    debugger;
                    var item = JSON.parse(res);
                    var rows = '';
                    var iteration = 0;
                    $.each(item, function (key, value) {
                        debugger;
                        if (value.Unit == null)
                            value.Unit = "";
                        if (value.UnitName == null)
                            value.UnitName = "";
                        if (value.Pack_Quantity == null)
                            value.Pack_Quantity = "";
                        if (value.Purchase_Rate == null) {
                            value.Purchase_Rate = 0;
                        }
                        iteration++;
                        var rowlength = (document.getElementById("tblItemDescription").rows.length + iteration) - 1;
                        rows += '<tr>' +
                            '<td style="padding-top:7px!important;""><input type="hidden" id="txtPRDId' + rowlength + '" name="txtPRDId" value="' + value.PR_Detail_ID + '" style="width: 75px !important;text-align:right" />' + rowlength + '</td>' +
                            '<td style="padding-top: 7px!important;"><input type="hidden" name="txtPRNo" id="txtPRNO' + rowlength + '"  value="' + value.PR_ID + '"style="text-align:right ;width:50px !important;font-size:9px;height:20px;padding-top: 7px!important;padding-right: 3px!important;"/>' + value.PR_ID + '</td>' +
                            '<td style="padding-top: 7px!important;padding-right: 3px!important;"><input type="hidden" name="txtItemCode" id="txtItemCode' + rowlength + '"  value="' + value.Item_Code + '"  style="width:50px !important;text-align:right;font-size:9px;height:20px;"/> ' + value.Item_Code + ' </td>' +
                            '<td style="padding-left: 8px!important;padding-top: 7px!important;"><input type="hidden" name="txtItemName" id="txtItemName' + rowlength + '"  value="' + value.Description + '"/> ' + value.Description + ' </td>' +
                            '<td> <input type="hidden" name="txtUnit" id="txtUnit' + rowlength + '"  value="' + value.Unit + '" />' + value.UnitName + ' </td>' +
                            '<td><input type="text"  id="txtQty' + rowlength + '" style="text-align:right ;width:50px !important;font-size:9px;height:20px;margin-top: 4px;" name="txtQty" onkeyup="CulculateAmonutWithQty(this)" value="' + value.Qty + '"/></input></td>' +
                            '<td><input type="text" id="txtUOMQty' + rowlength + '" name="txtUOMQty" style="text-align:right;width:50px!important;font-size:9px;height:20px;" value="' + (value.UOM_Qty != null ? parseFloat(value.UOM_Qty).toFixed(2) : '0') + '" /></td>' +
                            '<td>' + value.Pack_Quantity + '</td>' +
                            '<td><input type="text" style="text-align:right ;width:50px !important;font-size:9px;height:20px;margin-top: 4px;" onkeyup="CulculateAmonutWithQty(this)" name="txtRate" id="txtRate' + rowlength + '"  value="' + value.Purchase_Rate + '" /></td>' +

                            '<td><input type="text" autocomplete="off" style="text-align:right ;width:50px !important;font-size:9px;height:20px;margin-top: 4px;" onkeyup="calcTotal()" name="txtDisPer" id="txtDisPer' + rowlength + '"  value="0" /></td>' +
                            '<td style="text-align:right;padding-top: 7px!important;"><input type="text" readonly="readonly" value="0" style="width: 50px !important;text-align:right;font-size:9px;height:20px;text-align:right!important;"  id="txtDisAmount' + rowlength + '" name="txtDisAmount" ></input></td>' +

                            '<td><select id="ddlSTAX' + rowlength + '" name="ddlSTAX" class="ddlSTAX" onchange="calcTotal()" style="margin-top: 4px;;text-align:right ;width:50px !important;font-size:9px;height:20px;margin-left: 9px;" ></select></td>' +
                            '<td style="padding-top: 7px!important;"><input type="text" readonly="readonly" style="text-align:right ;width:50px !important;font-size:9px;height:20px;margin-top: 4px;" value="0"  id="txtSalAmount' + rowlength + '" name="txtSalAmount" ></input></td>' +
                            '<td style="display:none;"><select id="ddlFed' + rowlength + '" onchange="calcTotal()" style="text-align:right ;width:50px !important;font-size:9px;height:20px;margin-top: 4px;    margin-left: 6px;"><option value="0">0</option>' + optionFed + '</select></td>' +
                            '<td style="padding-top: 7px!important;display:none;"><input type="text" value="0" style="width: 50px !important;text-align:right;font-size:9px;height:20px;  id="txtFedAmount' + rowlength + '" name="txtFedAmount" style="width:50px !important;"></input></td>' +

                            '<td style="text-align:right ;width:50px !important;font-size:9px;height:20px;padding-top: 7px!important;"><input type="text" style="width:50px !important;text-align:right;font-size:9px;height:20px;" value="0" readonly="readonly"  id="txtTotalAmount' + rowlength + '" name="txtTotalAmount"></input></td>' +
                            '<td><input type="text" name="txtddate" id="txtddate' + rowlength + '" style="width:50px !important;text-align:center;font-size:9px;height:20px;" /></td>' +
                            '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a> </td></tr>';
                    });
                    debugger;
                    $('#tblItemDescription').append(rows);
                    $('input[name="txtddate"]').datepicker({ dateFormat: 'dd M yy' }).attr('readonly', 'readonly');

                    calcTotal();
                });
            }
            else {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select PR Number',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

            }
        }
        
        function CulculateAmonut() {
            debugger;
            var amtwithdis = 0;
            var TotalAmount = 0;
            var TotalDiscountAmount = 0;
            var TotalNetAmount = 0;

            $.each($('#tblItemDescription tbody tr'), function (key, value) {
                debugger;
                var DisPer = 0;
                var Rate = parseFloat($($(value).find('td input[name=txtRate]')[0]).val()) || 0;
                var Qty = parseFloat($($(value).find('td input[name=txtQty]')[0]).val()) || 0;
                var DisAmt = parseFloat($($(value).find('td input[name=txtDisAmount]')[0]).val()) || 0;

                var Amount = Rate * Qty;
                if (DisAmt > 0 && Amount > 0) {
                    DisPer = parseFloat((DisAmt / Amount) * 100).toFixed(2);
                } else {
                    DisPer = 0;
                }
                $($(value).find('td input[name=txtDisPer]')[0]).val(DisPer);

                var finalNetAmount = Amount - DisAmt;

                TotalAmount += Amount;
                TotalNetAmount += finalNetAmount;
                TotalDiscountAmount += DisAmt;
            });

            amtwithdis = parseFloat(TotalAmount);
            $('#txtSub_Total').val(amtwithdis.toFixed(2));
            $('#ctl00_MainContent_Net_Amount').val(TotalNetAmount.toFixed(2));
            $('#ctl00_MainContent_txtTotalDiscAmt').val(TotalDiscountAmount.toFixed(2));
            $('#txtTotalDiscAmt').val(TotalDiscountAmount.toFixed(2));
        }

        function ExcludeFromPayment(anchor) {
            debugger;
            var a = confirm("Are you sure You want to delete");
            if (a == true) {
                var row = $(anchor).parents('tr')[0];
                row.remove();
                CulculateAmonut();
            }
        }
        function FillDepartments() {
            debugger;
            var optionsDPT = '';
            var optionInv = '';
            PageMethods.getDDLlist(function (Tests) {
                debugger
                $.each(JSON.parse(Tests), function (key, value) {
                    debugger;
                    if (value.Type == "DPT") {
                        optionsDPT += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                    else {
                        optionInv += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                });
                $('#ddldept').html(optionsDPT);
                $('#ddlInv_org').html(optionInv);
            });
        }


        function FillWarehouse() {

            var optionInv = '';
            PageMethods.fillWarehouse(function (Tests) {

                optionInv = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {

                    optionInv += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddlWarehouse').html(optionInv);
            });
        }

        function runCalcTotalCore() {
            var netAmount = 0;
            var STpercent = 0;
            var totalstamount = 0;
            var STAmount = 0;
            var DiscAmount = 0;
            var TotalDiscAmount = 0;
            var totamount = 0;
            var subtotal = 0;
            var totalfinalamount = 0;
            var totalAdvAmount = 0;
            var FurtherPercent = 0;
            var FurtherAmount = 0;
            var totalFurtherAmount = 0;
            var totalBonusTax = 0; 

            $.each($('#tblItemDescription tbody tr'), function (key, value) {
                var $row = $(value);
                var DiscAmount = parseFloat($row.find('input[name=txtDisAmount]').val()) || 0;
                if (DiscAmount < 0) {
                    DiscAmount = 0;
                    $row.find('input[name=txtDisAmount]').val(DiscAmount);
                }
                var discpercent = 0;
                var Rate = parseFloat($row.find('input[name=txtRate]').val()) || 0;
                var Qty = parseFloat($row.find('input[name=txtQty]').val()) || 0;
                var amountExclusiveTaxes = Qty * Rate;

                if (amountExclusiveTaxes > 0) {
                    discpercent = parseFloat((DiscAmount / amountExclusiveTaxes) * 100).toFixed(2);
                }
                $row.find('input[name=txtDisPer]').val(discpercent);
                subtotal += amountExclusiveTaxes;

                var selectedSTAX = $row.find('select[name=ddlSTAX] :selected').text();
                STpercent = selectedSTAX ? parseFloat(selectedSTAX) || 0 : 0;

                var selectedAdvTax = $row.find('select[name=ddlAdvanceTax] :selected').text();
                var AdvPercent = selectedAdvTax ? parseFloat(selectedAdvTax) || 0 : 0;

                //var selectedFurtherTax = $($(value).find('td select[name=ddlFurtherTax] :selected')[0]).text();
                //FurtherPercent = selectedFurtherTax ? parseFloat(selectedFurtherTax) || 0 : 0;

                //var selectedFurtherTax = $($(value).find('td input[name=ddlFurtherTax]')[0]).val() || 0;
                //FurtherPercent = parseFloat(selectedFurtherTax) || 0;

                //FurtherAmount = parseFloat((FurtherPercent / 100) * (amountExclusiveTaxes - DiscAmount));
                //$($(value).find('td input[name=txtFurtherTaxAmount]')[0]).val(FurtherAmount.toFixed(2));
                //totalFurtherAmount += FurtherAmount;
                var selectedFurtherTax = $row.find('input[name=ddlFurtherTax]').val() || 0;
                FurtherPercent = parseFloat(selectedFurtherTax) || 0;

                var furtherAmountField = $row.find('input[name=txtFurtherTaxAmount]');
                var currentFieldValue = furtherAmountField.val();
                var calculatedAmount = parseFloat((FurtherPercent / 100) * (amountExclusiveTaxes - DiscAmount));

                if (FurtherPercent > 0 && (currentFieldValue === '' || currentFieldValue === '0' || currentFieldValue === '0.00')) {
                    furtherAmountField.val(calculatedAmount.toFixed(2));
                    FurtherAmount = calculatedAmount;
                } else if (FurtherPercent === 0) {
                    FurtherAmount = 0;
                } else {
                    FurtherAmount = parseFloat(currentFieldValue) || calculatedAmount;
                }

                totalFurtherAmount += FurtherAmount;



                AdvAmount = parseFloat((AdvPercent / 100) * (amountExclusiveTaxes - DiscAmount));
                $row.find('input[name=txtAdvanceTaxAmount]').val(AdvAmount.toFixed(2));

                STAmount = parseFloat((STpercent / 100) * (amountExclusiveTaxes - DiscAmount));
                $row.find('input[name=txtSalAmount]').val(STAmount.toFixed(2));

                var BonusQty = parseFloat($row.find('input[name=txtBonusQty]').val()) || 0;
                var bonusTaxTotal = 0;
                var isByDefault = $('#chkByDefault').is(':checked');
                if (BonusQty > 0 && !isByDefault) {
                    var bonusBase = BonusQty * Rate;
                    var bonusST = (STpercent / 100) * bonusBase;
                    var bonusAdv = (AdvPercent / 100) * bonusBase;
                  //  var bonusFurther = (FurtherPercent / 100) * bonusBase;
                    bonusTaxTotal = bonusST + bonusAdv/* + bonusFurther*/;
                }
                $row.find('input[name=txtBonusAmount]').val(bonusTaxTotal.toFixed(2));
                totalBonusTax += bonusTaxTotal;

                netAmount = parseFloat(amountExclusiveTaxes + STAmount + AdvAmount + FurtherAmount - DiscAmount);
                $row.find('input[name=txtTotalAmount]').val(netAmount.toFixed(2));

                totamount += netAmount;
                totalstamount += STAmount;
                totalAdvAmount += AdvAmount;
                TotalDiscAmount += DiscAmount;
                totalfinalamount = totamount;
            });

            $('#txtSub_Total').val(subtotal.toFixed(2));
            $('#txtst_amou').val((totalstamount + totalAdvAmount + totalFurtherAmount).toFixed(2));
            $('#txtAdv_amou').val(totalAdvAmount.toFixed(2));
            $('#txtFurther_amou').val(totalFurtherAmount.toFixed(2));

            $('#txtBonusTaxTotal').val(totalBonusTax.toFixed(2));

            var freightTotal = parseFloat($('#ctl00_MainContent_Freight').val()) || 0;
            var totalFinalAmt = totalfinalamount + totalBonusTax + freightTotal;

            $('#ctl00_MainContent_Net_Amount').val(totalFinalAmt.toFixed(2));
            $('#ctl00_MainContent_txtTotalDiscAmt').val(TotalDiscAmount.toFixed(2));
            $('#txtTotalDiscAmt').val(TotalDiscAmount.toFixed(2));
            $('#txtfreight_charges').val(freightTotal);
        }

        function calcFurtherTaxFromAmount(anchor) {
            debugger;
            var row = $(anchor).parents('tr')[0];
            $(anchor).attr('data-manual', 'true');

            var Rate = parseFloat($(row).find('input[name=txtRate]').val()) || 0;
            var Qty = parseFloat($(row).find('input[name=txtQty]').val()) || 0;
            var DiscAmount = parseFloat($(row).find('input[name=txtDisAmount]').val()) || 0;
            var enteredAmount = parseFloat($(anchor).val()) || 0;

            var base = (Qty * Rate) - DiscAmount;
            var calculatedPercent = 0;

            if (base > 0 && enteredAmount >= 0) {
                calculatedPercent = parseFloat((enteredAmount / base) * 100).toFixed(2);
            }

            $(row).find('input[name=ddlFurtherTax]').val(calculatedPercent);
            $(row).find('input[name=txtFurtherTaxAmount]').attr('data-manual', 'false');

            scheduleCalcTotal();
        }

        function CulculateAmonutWithQty(anchor) {
            var $row = null;

            if (anchor && anchor.nodeType === 1) {
                $row = $(anchor).closest('tr');
            } else if (anchor !== undefined && anchor !== null) {
                var idx = (anchor + '').replace(/[^0-9]/g, '');
                if (idx) {
                    $row = $('#txtQty' + idx).closest('tr');
                }
            }

            if ($row && $row.length > 0) {
                var disAmount = parseFloat($row.find('input[name=txtDisAmount]').val()) || 0;
                var rate = parseFloat($row.find('input[name=txtRate]').val()) || 0;
                var qty = parseFloat($row.find('input[name=txtQty]').val()) || 0;
                var amount = rate * qty;
                var disPer = 0;

                if (amount > 0) {
                    disPer = parseFloat((disAmount / amount) * 100).toFixed(2);
                }

                $row.find('input[name=txtDisPer]').val(disPer);
            }

            scheduleCalcTotal();
        }


        function validateSave() {
            debugger
            $("#btnSave").prop("disabled", true);
            var proceed = true;
            var table = $('#tblItemDescriptionDetail');
            var Vendor = $('#ctl00_MainContent_ddlVendor').val();
            var Warehouse = $('#ddlWarehouse').val();
            var PaymentTerms = $('#ctl00_MainContent_ddlpayment').val();
            var PDate = $('#ctl00_MainContent_txtPurchase_Date').val();
            var dueDate = $('#ctl00_MainContent_txtdueDate').val();
            var PurchaseDate = new Date(PDate).setHours(0, 0, 0, 0);
            var DueDate = new Date(dueDate).setHours(0, 0, 0, 0);
            if (PurchaseDate > DueDate) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Due Date must be greater than Purchase Date',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                $("#btnSave").prop("disabled", false).removeAttr("disabled");
                return false;
            }

            //if (Warehouse == '0') {
            //    Swal.fire({
            //        icon: 'error',
            //        title: 'Error!',
            //        text: 'Please Select Warehouse',
            //        showConfirmButton: false,
            //        timer: 2000,
            //        customClass: {
            //            popup: 'swal-big-popup',
            //            title: 'swal-big-title',
            //            htmlContainer: 'swal-big-text'
            //        }
            //    });
            //    return false;
            //}

            if (Vendor == '0') {
                $("#ctl00_MainContent_ddlVendor").addClass('ErrorAlert');
                $('#select2-ctl00_MainContent_ddlVendor-container').parent().css('border-color', 'red');
                proceed = false;
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Vendor',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                $('#ctl00_MainContent_ddlVendor').select2().focus();
                $('#ctl00_MainContent_ddlVendor').select2('open');

                $("#btnSave").prop("disabled", false).removeAttr("disabled");
                return false;
            }
            else {
                $("#ctl00_MainContent_ddlVendor").removeClass('ErrorAlert');
                $('#select2-ctl00_MainContent_ddlVendor-container').parent().css('border-color', ' rgb(206, 191, 191)');
            }
            if (PaymentTerms == '0') {
                $("#ctl00_MainContent_ddlpayment").addClass('ErrorAlert');
                $('#select2-ctl00_MainContent_ddlpayment-container').parent().css('border-color', 'red');
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Mode of Payment',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                $('#ctl00_MainContent_ddlpayment').select2().focus();
                $('#ctl00_MainContent_ddlpayment').select2('open');

                $("#btnSave").prop("disabled", false).removeAttr("disabled");
                proceed = false;
                return false;
            }
            else {
                $("#ctl00_MainContent_ddlpayment").removeClass('ErrorAlert');
                $('#select2-ctl00_MainContent_ddlpayment-container').parent().css('border-color', 'rgb(206, 191, 191)');
            }
            if (document.getElementById('tblItemDescription').rows.length == 1) {
                proceed = false;
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Items List Should have Items.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                $("#btnSave").prop("disabled", false).removeAttr("disabled");
                return false;
            }
            else if (document.getElementById('tblItemDescription').rows.length > 1) {
                table.find('tr').each(function (key, value) {
                    var Qty = $(value).find('td input[name=txtQty]').val();
                    var Rate = $(value).find('td input[name=txtRate]').val();
                    var UOM_Qty = $(value).find('td input[name=txtUOMQty]').val();

                    if (Qty == 0 || Qty == "" || Qty < 0) {
                        proceed = false;
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Please Enter Qty or Qty Greater than zero',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });

                        $("#btnSave").prop("disabled", false).removeAttr("disabled");
                    }
                    else if (Rate == 0 || Rate == "" || Rate < 0) {
                        proceed = false;
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Please Enter Rate or Rate Greater than zero',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                        
                        $("#btnSave").prop("disabled", false).removeAttr("disabled");
                    }
                    if (UOM_Qty == "0" || UOM_Qty == "" || parseFloat(UOM_Qty) <= 0) {
                        proceed = false;
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Please add UOM_Qty',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                        $("#btnSave").prop("disabled", false).removeAttr("disabled");
                        return false;
                    }
                });
            }


            return proceed;
        }
        function SaveAllRecord() {
            debugger
            $("#btnSave").prop("disabled", true);
            calcTotal(true);
            if (validateSave()) {
                debugger;
                var status;
                var btnSave = $('#btnSave').val();
                var RefNo = $('#ctl00_MainContent_txtPurchase_Reference').val();
                var VendorName = $('#ctl00_MainContent_ddlVendor').val();
                var Remarks = $('#ctl00_MainContent_txtRemarks').val();
                var Warranty = $('#ctl00_MainContent_txtWarranty').val();
                var Disclaimer = $('#ctl00_MainContent_txtDisclaimer').val();
                var Purchase_No = $('#ctl00_MainContent_txtPurchase_No').val();
                var Purchase_Date = $('#ctl00_MainContent_txtPurchase_Date').val();
                var Due_Date = $('#ctl00_MainContent_txtdueDate').val();
                var table = $('#tblItemDescriptionDetail');
                var SubTotal = $('#txtSub_Total').val();
                var DiscountAmount = $('#ctl00_MainContent_txtTotalDiscAmt').val();
                var NetAmount = $('#ctl00_MainContent_Net_Amount').val();
                var PaymentTerms = $('#ctl00_MainContent_ddlpayment').val();
                var Warehouse = $('#ddlWarehouse').val();
                var Term_ID = $('#ctl00_MainContent_ddlTerm').val();
                var DeliveryTerms = $('#ctl00_MainContent_ddlDelivery').val();
                var Freight = $('#ctl00_MainContent_Freight').val();
                var POType = $('#ctl00_MainContent_ddlPOType').val();
                var PO_ID = $('#hdnPurchase_ID').val();
                var transtype = $('#txttranstype').val();
                var txtcsmasterid = $('#txtcsmasterid').val();
                var txtst_amou = $('#txtst_amou').val();
                var Adv_amount = $('#txtAdv_amou').val();
                var Further_amount = $('#txtFurther_amou').val();
                var IsManual = $('#chkManual').is(':checked');
                var IsByDefault = $('#chkByDefault').is(':checked');
                var Item_list = [];
                debugger;
                if (Purchase_No == "(New)" || Purchase_No == "")
                    Purchase_No = "0";
                table.find('tr').each(function (key, value) {
                    debugger;
                    var PurchaseDate = new Date(Purchase_Date).setHours(0, 0, 0, 0);
                    var DeliveryDate = new Date($(value).find('td input[name=txtddate]').val()).setHours(0, 0, 0, 0);
                    if (PurchaseDate > DeliveryDate) {
                        status = false;
                    }
                    else {
                        Item_list.push({
                            'PRDetailId': $(value).find('td input[name=txtPRDId]').val(), 'ItemCode': $(value).find('td input[name=txtItemCode]').val(), 'ItemName': $(value).find('td input[name=txtItemName]').val(), 'Unit': $(value).find('td input[name=txtUnit]').val(), 'BonusQty': $(value).find('td input[name=txtBonusQty]').val(), 'Qty': $(value).find('td input[name=txtQty]').val(), 'UOM_Qty': $(value).find('td input[name=txtUOMQty]').val(), 'Rate': $(value).find('td input[name=txtRate]').val(), 'DisPer': $(value).find('td input[name=txtDisPer]').val(), 'DisAmount': $(value).find('td input[name=txtDisAmount]').val(), 'Amount': $(value).find('td input[name=txtTotalAmount]').val(), 'FedPercentId': $("#ddlFed" + (key + 1) + " option:selected").val(), 'Fed_Percentage': $($(value).find('td')[11]).text(), 'SalTax_Id': $("#ddlSTAX" + (key + 1) + " option:selected").val(), 'AdvanceTax_ID': $("#ddlAdvanceTax" + (key + 1) + " option:selected").val(), 'SalTax_Amount': $(value).find('td input[name=txtSalAmount]').val(), 'DateTime': $(value).find('td input[name=txtddate]').val(), 'AdvanceTax_Amount': $(value).find('td input[name=txtAdvanceTaxAmount]').val(), 'FurtherTax_Id': 0, 'FurtherTax_Percentage': $($(value).find('td input[name=ddlFurtherTax]')[0]).val() || 0, 'BonusTax': $(value).find('td input[name=txtBonusAmount]').val(),
                            'FurtherTax_Amount': $(value).find('td input[name=txtFurtherTaxAmount]').val(),

                        });
                    }
                });

                if (status == false) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Delivery Date must be greater than Purchase Date',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                    $("#btnSave").prop("disabled", false).removeAttr("disabled");
                    return false;
                }
                else {
                    var AllItemDetail = {
                        'txtst_amou': txtst_amou, 'Adv_amount': Adv_amount, 'transtype': transtype, 'txtcsmasterid': txtcsmasterid, 'PO_ID': PO_ID, 'SubTotal': SubTotal, 'DiscountAmount': DiscountAmount, 'NetAmount': NetAmount, 'Purchase_Date': Purchase_Date, 'Purchase_No': Purchase_No, 'RefNo': RefNo, 'VendorName': VendorName, 'Remarks': Remarks, 'Warranty': Warranty, 'Disclaimer': Disclaimer, 'PaymentTerms': PaymentTerms, 'Term_ID': Term_ID, 'DeliveryTerms': DeliveryTerms, 'FreightCharges': Freight, 'POType': POType, 'Due_Date': Due_Date, 'ItemList': Item_list, 'Warehouse': Warehouse, 'Further_amount': Further_amount, 'IsManual': IsManual,
                        'IsByDefault': IsByDefault };
                    PageMethods.SavePurchaseItemDetail(btnSave, JSON.stringify(AllItemDetail), function (res) {
                        debugger;
                        sendFile(res);
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: 'Data Save Successfully',
                            showConfirmButton: false,
                            timer: 2500,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });

                        window.location = "PurchaseOrder.aspx?PO_ID=" + res;
                    });
                }
            }
        }

        function UnApprove() {
            debugger;
            var POid = '<% =Request.QueryString["PO_ID"] %>';
            PageMethods.UnApprovePO(POid, function (Tests) {
                debugger
                var message = JSON.parse(Tests);
                if (message[0].Column1 != "" || message[0].Column1 != null) {
                    alert(message[0].Column1);
                    location.reload();
                }
            });
        }



        function Cancel() {
            var POid = '<%= Request.QueryString["PO_ID"] %>';
            PageMethods.CancelEntry(POid, function (response) {
                try {
                    var message = JSON.parse(response);
                    if (message.error) {
                        alert("Error Occurred While Cancelling: " + message.error);
                    } else if (message[0].Column1 == "1") {
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: 'PO Cancelled Successfully',
                            showConfirmButton: false,
                            timer: 2500,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });

                        location.reload();
                    } else {
                        alert("Unexpected response format");
                    }
                } catch (error) {
                    alert("Error parsing server response: " + error.message);
                }
            });
        }


        function UserUnApproveButtonRights() {
            debugger;
            $.ajax({
                type: "POST",
                url: "PurchaseOrder.aspx/UserUnApproveEntryRights",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var hasRights = response.d;
                    debugger;
                    if (hasRights) {
                        debugger;
                        $('#btnUnApprove').show();
                    } else {
                        $('#btnUnApprove').hide();
                    }
                },
                failure: function (response) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Failed to retrieve User UnApprove Button Rights.',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                }
            });
        }
        function sendFile(ID) {
            debugger;
            var fileInput = $('#chosePofile')[0];
            if (fileInput.files.length > 0) {
                debugger;
                var data = new FormData();
                data.append('file', $('#chosePofile')[0].files[0]);
                data.append('ID', ID);
                $.ajax({
                    type: 'post',
                    url: '../../upload/UploadPOFiles.ashx',
                    data: data,
                    success: function (status) {

                    },
                    processData: false,
                    contentType: false,
                    error: function () {
                        alert(" something went wrong!");
                    }
                });
            }
        }

        // Load items from INV_Items table into search modal
        function LoadAllitem(searchText) {
            debugger;        
            $.ajax({
                type: "POST",
                url: "PurchaseOrder.aspx/GetAllitem",
                data: JSON.stringify({ searchText: searchText }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var items = JSON.parse(response.d);
                    var tableBody = $('#itemsTableBody');
                    tableBody.empty();
                    $.each(items, function (index, item) {
                        var row = '<tr>' +
                            '<td><input type="checkbox" class="itemCheckbox" onclick="appendSearchItem(this)"></td>' +
                            '<td style="display:none;">' + item.Item_ID + '</td>' +
                            '<td>' + item.Item_Code + '</td>' +
                            '<td>' + item.Description + '</td>' +
                            '<td>' + item.Unit + '</td>' +
                            '<td style="display:none;">' + (item.Purchase_Rate || 0) + '</td>' +
                            '<td style="display:none;">' + (item.UOM_Qty || 1) + '</td>' +
                            '</tr>';
                        tableBody.append(row);
                    });
                    $('#itemsModal').modal('show');
                },
                error: function (error) {
                    console.error("Error fetching items", error);
                    Swal.fire({ icon: 'error', title: 'Error', text: 'Failed to load items.' });
                }
            });
        }

        function appendSearchItem(anchor) {
            debugger;
            var row = $(anchor).closest('tr');
            var item_id = $(row).find('td:eq(1)').text().trim();
            var item_code = $(row).find('td:eq(2)').text().trim();
            var item_name = $(row).find('td:eq(3)').text().trim();
            var unit = $(row).find('td:eq(4)').text().trim();
            var rate = $(row).find('td:eq(5)').text().trim() || '0';
            var uom_qty = $(row).find('td:eq(6)').text().trim() || '1';
            var isChecked = $(anchor).prop('checked');
            if (!isChecked) {
                $('#tblItemDescription tbody tr').each(function () {
                    if ($(this).find('input[name=txtItemCode]').val() === item_code) {
                        $(this).remove();
                    }
                });
                return;
            }

            var exists = false;
            $('#tblItemDescription tbody tr').each(function () {
                if ($(this).find('input[name=txtItemCode]').val() === item_code) {
                    exists = true;
                    return false;
                }
            });

            if (exists) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Item already added!',
                    timer: 2000,
                    showConfirmButton: false
                });

                $(anchor).prop('checked', false);
                return;
            }

            var length = $("#tblItemDescription tr:gt(0)").length + 1;
            var newRow = '<tr>' +
                '<td style="padding-top:7px!important;"><input type="hidden" id="txtPRDId' + length + '" name="txtPRDId" value="0" />' + length + '</td>' +
                '<td style="padding-top: 7px!important;"><input type="hidden" name="txtPRNo" id="txtPRNO' + length + '" value="" /> </td>' +
                '<td style="padding-top: 7px!important;text-align:right!important;"><input type="hidden" name="txtcsno" id="txtcsno' + length + '" value="" /></td>' +
                '<td style="padding-top: 7px!important;padding-right: 3px!important;text-align:right!important;"><input type="hidden" name="txtItemCode" id="txtItemCode' + length + '" value="' + item_code + '" style="width:50px !important;text-align:right;font-size:9px;height:20px;"/> ' + item_code + ' </td>' +
                '<td style="padding-left: 8px!important;padding-top: 7px!important;text-align:left!important;"><input type="hidden" name="txtItemName" id="txtItemName' + length + '" value="' + item_name + '"/> ' + item_name + ' </td>' +
                '<td style="text-align:left!important;"> <input type="hidden" name="txtUnit" id="txtUnit' + length + '" value="' + unit + '" />' + unit + ' </td>' +
                '<td><input type="text" id="txtQty' + length + '" style="text-align:right ;width:50px !important;font-size:9px;height:20px;" name="txtQty" onkeyup="CulculateAmonutWithQty(this)" value="1"/></td>' +
                '<td><input type="text" id="txtUOMQty' + length + '" style="text-align:right;width:50px!important;font-size:9px;height:20px;" name="txtUOMQty" value="' + uom_qty + '" /></td>' +
                '<td><input type="text" id="txtBonusQty' + length + '" style="text-align:right;width:50px!important;font-size:9px;height:20px;" name="txtBonusQty" value="0" data-toggle="tooltip" data-placement="bottom" title="Enter Bonus quantity in Loose"/></td>' +
                '<td><input type="text" autocomplete="off" style="text-align:right ;width:50px !important;font-size:9px;height:20px;" onkeyup="CulculateAmonutWithQty(this)" name="txtRate" id="txtRate' + length + '" value="' + rate + '" /></td>' +
                '<td><input type="text" autocomplete="off" style="text-align:right ;width:50px !important;font-size:9px;height:20px;" name="txtDisPer" readonly="readonly" id="txtDisPer' + length + '" value="0" /></td>' +
                '<td style="text-align:right;padding-top: 7px!important"><input type="text" onkeyup="calcTotal()" style="width: 50px !important;text-align:right;font-size:9px;height:20px;text-align:right!important;" id="txtDisAmount' + length + '" name="txtDisAmount" value="0"></input></td>' +
                '<td><select id="ddlSTAX' + length + '" name="ddlSTAX" onchange="calcTotal()" style="text-align:right ;width:50px !important;font-size:9px;height:20px;" class="duplicate ddlSTAX" ><option value="0">0</option></select></td>' +
                '<td style="padding-top: 7px!important;text-align:right!important"><input type="text" style="text-align:right!important; width:50px !important;font-size:9px;height:20px;" value="0" readonly="readonly" id="txtSalAmount' + length + '" name="txtSalAmount" /></td>' +
            /*'<td><select id="ddlFurtherTax' + length + '" name="ddlFurtherTax" onchange="calcTotal()" style="text-align:right ;width:50px !important;font-size:9px;height:20px;" class="ddlFurtherTax"><option value="0">0</option></select></td>' +*/
                '<td><input type="text" id="ddlFurtherTax' + length + '" name="ddlFurtherTax" onkeyup="calcTotal()" style="text-align:right ;width:50px !important;font-size:9px;height:20px;" value="0" /></td>' +
                '<td><input type="text" readonly="readonly" style="width:50px !important;text-align:right;font-size:9px;height:20px;" value="0" id="txtFurtherTaxAmount' + length + '" name="txtFurtherTaxAmount"></td>' +
                '<td><select id="ddlAdvanceTax' + length + '" name="ddlAdvanceTax" onchange="calcTotal()" style="text-align:right ;width:50px !important;font-size:9px;height:20px;" class="ddlAdvanceTax"></select></td>' +
                '<td><input type="text" readonly="readonly" style="width:50px !important;text-align:right;font-size:9px;height:20px;" value="0" id="txtAdvanceTaxAmount' + length + '" name="txtAdvanceTaxAmount"></td>' +
                '<td style="display:none;"><select id="ddlFed' + length + '" onchange="calcTotal()" style="text-align:right ;width:50px !important;font-size:9px;height:20px;margin-left: 6px;" class="duplicate"><option value="0">0</option></select></td>' +
                '<td style="padding-top: 7px!important;display:none;"><input type="text" value="0" style="width: 50px !important;text-align:right;font-size:9px;height:20px;" id="txtFedAmount' + length + '" name="txtFedAmount"></input></td>' +
                '<td><input type="text" readonly style="width:50px!important;text-align:right;font-size:9px;height:20px;" value="0" id="txtBonusAmount' + length + '" name="txtBonusAmount" /></td>' +
                '<td style="text-align:right ;width:50px !important;font-size:9px;height:20px;padding-top: 7px!important;"><input type="text" style="width:50px !important;text-align:right;font-size:9px;height:20px;" value="0" readonly="readonly" id="txtTotalAmount' + length + '" name="txtTotalAmount"></input></td>' +
                '<td><input type="text" name="txtddate" id="txtddate' + length + '" class="row-date-picker" style="width:64px !important;text-align:center;font-size:9px;height:20px;" /></td>' +
                '<td style="padding-top: 7px!important;"><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="font-size: 13px;margin-left: 16px; color: #f30a0a;position:relative;left: -10px;"></i></a> </td></tr>';

            $('#tblItemDescription tbody').append(newRow);
            populateTaxddl(length);
            populateAdvanceTaxddl(length);
            populateFurtherTaxddl(length);
            $('[data-toggle="tooltip"]').tooltip();
            $('#txtddate' + length).datepicker({ dateFormat: 'dd M yy' }).attr('readonly', 'readonly');
            CulculateAmonutWithQty(length);
            calcTotal();
        }

    </script>
    <style>
        #txtfreight_charges{
            text-align:right;
        }
    </style>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <input type="hidden" id="txtcsmasterid" name="txtcsmasterid" />
    <input type="hidden" id="txtcsno" name="txtcsno" />
    <input type="hidden" id="txttranstype" name="txttranstype" />
    <form id="item">
        <!-- PAGE LOADER -->
        <div id="page-loader">
            <div class="loader-spinner"></div>
            <div class="loader-text">Loading Purchase Order...</div>
        </div>
        <div class="row">
            <div class="col-lg-3 col-md-6 col-sm-12">
                <asp:Label ID="LabelPurchase_No" runat="server" Text="PO No."></asp:Label>
                <asp:TextBox runat="server" ID="txtPurchase_No" class="form-control" ReadOnly="true" />
                <asp:HiddenField ID="hdnPurchase_ID" runat="server" ClientIDMode="Static" />
                <asp:TextBox runat="server" ID="txtPurchase_ID" Visible="false" ReadOnly="true" Width="0" />
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <asp:Label ID="LabelPurchase_Date" runat="server" Text="Date"></asp:Label>
                <asp:RequiredFieldValidator ID="rfvPurchaseDate" runat="server" InitialValue="0" ControlToValidate="txtPurchase_Date" ErrorMessage="*" Display="Dynamic"></asp:RequiredFieldValidator>
                <asp:TextBox runat="server" ID="txtPurchase_Date" class="form-control" />
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <asp:Label ID="lblPOType" runat="server" Text="P.O Type"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlPOType" class="form-control" AppendDataBoundItems="true"></asp:DropDownList>
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <asp:Label ID="lblpayment" runat="server" Text="Payment Mode" Style="">Mode of Payment<span style="color: red">*</span></asp:Label>
                <asp:DropDownList runat="server" ID="ddlpayment" class="form-control" AppendDataBoundItems="true"></asp:DropDownList>
            </div>

        </div>

        <div class="row">
            <div class="col-lg-3 col-md-6 col-sm-12">
                <asp:Label ID="lblDueDate" runat="server" Text="Due Date"></asp:Label>
                <asp:TextBox runat="server" ID="txtdueDate" class="form-control" />
            </div>

            <div class="col-lg-3 col-md-6 col-sm-12">
                <asp:Label ID="lblSupplier_ID" runat="server" Text="Vendor">Vendor <span style="color: red;">*</span></asp:Label>
                <asp:DropDownList runat="server" ID="ddlVendor" class="form-control" AppendDataBoundItems="true"></asp:DropDownList>
            </div>


            <div class="col-lg-2 col-md-6 col-sm-4">
                <asp:Label ID="lblPrNo" runat="server" Text="Pr.No"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlPrNo" class="form-control"></asp:DropDownList>
            </div>
            <div class="col-lg-1 col-md-2 col-sm-4">
                <input type="button" value="Add" id="btnPRSave" class="btn btn-primry" style="margin-top: 16px;" />
            </div>
            <div class="col-lg-1 col-md-2 col-sm-4">
                <input type="button" value="Items" id="btnGetAllItems" class="btn btn-gray" style="margin-top: 16px;" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6" id ="warehouse">
                <label id="LblWarehouse">WareHouse<span style="color: red">*</span></label>
                <select id="ddlWarehouse" onchange="getprNoBy_WareHouse(this)" class="form-select">
                    <option value="0">Please Select</option>
                </select>
            </div>
        </div>

        <div class="row">
           
            <div class="col-lg-3 col-md-6 col-sm-12">
                <asp:Label ID="lblDelivery" runat="server" Text="Delivery Terms"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlDelivery" class="form-control" AppendDataBoundItems="true"></asp:DropDownList>
            </div>
             <div class="col-lg-3 col-md-6 col-sm-12">
     <asp:Label ID="lblReference" runat="server" Text="Ref. No"></asp:Label>
     <asp:TextBox runat="server" ID="txtPurchase_Reference" class="form-control" />
 </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <asp:Label ID="lblFreight" runat="server" Text="Freight Amount"></asp:Label>
                <asp:TextBox runat="server" ID="Freight" onkeyup="calcTotal()" class="form-control" />
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <asp:Label ID="lblStatus" runat="server" Text="Status"></asp:Label>
                <asp:TextBox runat="server" ReadOnly="true" ID="txtStatus" class="form-control" />
            </div>
        </div>

        <div class="row">

            <div class="col-lg-3 col-md-6 col-sm-12">
                <asp:Label ID="lblTerm_ID" runat="server" Text="Payment Terms"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlTerm" class="form-control" AppendDataBoundItems="true"></asp:DropDownList>
            </div>

            <div class="col-lg-3 col-md-6 col-sm-12">
                <asp:Label ID="lblWarranty" runat="server" Text="Warranty"></asp:Label>
                <asp:TextBox runat="server" ID="txtWarranty" class="form-control" />
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <asp:Label ID="LblDisclaimer" runat="server" Text="Disclaimer"></asp:Label>
                <asp:TextBox runat="server" ID="txtDisclaimer" class="form-control" />
            </div>
            <div class="col-lg-1 col-md-6 col-sm-12">
                <label class="col-form-label">Attachment</label>
                <input type="file" id="chosePofile" name="chosePofile" />
                <asp:HyperLink ID="HyperLink1" runat="server">Download</asp:HyperLink>
            </div>
            <div class="col-lg-1 col-md-6 col-sm-12">
                 <label class="form-check-label" for="chkByDefault">By Default</label>
                 <input class="form-check-input" type="checkbox" id="chkByDefault" />
            </div>
            <div class="col-lg-1 col-md-6 col-sm-12">
                <label class="form-check-label" for="chkManual">Manual</label>
                <input class="form-check-input" type="checkbox" id="chkManual" />
            </div>
        </div>
        <div class="row">
            <div class="col-lg-9 col-md-12 col-sm-12">
                <asp:Label ID="lblRemarks" runat="server" Text="Remarks"></asp:Label>
                <asp:TextBox runat="server" ID="txtRemarks" class="form-control" />
            </div>
        </div>
    </form>
    <asp:HiddenField ID="hdfItem_ID" runat="server" ClientIDMode="Static" />   
        <div class="row" style=" height: 276px !important; height: auto;overflow:scroll">
        <table class="table responstable table-bordered" id="tblItemDescription" style="font-size: 9px !important; overflow: scroll; height: auto;">
            <thead>
                <tr style="position: sticky; top: 0px; z-index: 10;">
                    <th style="width: 29px;">No</th>
                    <th style="width: 50px; text-align: center; font-size: 10px;">P.R No</th>
                    <th style="width: 66px; text-align: center; font-size: 10px;">CS NO</th>
                    <th style="width: 66px; text-align: center; font-size: 10px;">Item Code</th>
                    <th style="width: 218px; text-align: center;">Item Description</th>
                    <th style="width: 60px;">Unit</th>
                    <th style="width: 60px;">Qty</th>
                    <th style="width: 60px;">UOM Qty</th>
                    <th style="width: 60px;">Bonus Qty</th>
                    <th style="width: 60px;">Rate</th>
                    <th style="width: 63px;">Dis %</th>
                    <th style="width: 69px;">Dis Amount</th>
                    <th style="width: 63px;">S.Tax %</th>
                    <th style="width: 66px;">ST Amount</th>
                    <th style="width: 66px;">F.Tax %</th>
                    <th style="width: 66px;">F.Tax Amount</th>
                    <th style="width: 63px;">A.Tax %</th>
                    <th style="width: 66px;">Adv Amount</th>
                    <th style="width: 58px; display: none;">Fed%</th>
                    <th style="width: 70px; display: none;">Fed Amount</th>
                    <th style="width: 75px;">Bonus Tax</th>
                    <th style="width: 75px;">Total</th>
                    <th style="width: 75px;">Delivery Date</th>
                    <th style="width: 45px;">Action</th>
                </tr>
            </thead>
            <tbody id="tblItemDescriptionDetail">
            </tbody>
        </table>
    </div>


    <div class="purchaseOrderSubmitForm" style="margin-top: 21px;">

        <div class="row">

            <div class="col-lg-8">
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" class="btn btn-primry" onclick="this.disabled=true;SaveAllRecord()" value="Save" id="btnSave" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6 ">
                    <input type="button" class="btn-gray" value="List" onclick="window.location = 'PurchaseOrderView.aspx'" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" class="btn btn-yellow" value="New" onclick="window.location = 'PurchaseOrder.aspx'" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input style="text-align: center" type="button" value="Cancel" id="btncancel" class="btn btn-primry" onclick="Cancel()" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" id="btnPrint" value="Print" class="btn btn-primry" name="name" onclick="PrintPurchaseOrderDetail();" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" style="display: none" class="btn btn-primry" value="UnApprove" id="btnUnApprove" onclick="UnApprove()" />
                </div>
            </div>
            <div class="col-lg-3"></div>
            <div class="col-lg-3">
                <div class="col-lg-12 col-md-8 col-sm-12">
                    <asp:Label ID="lblSubTotal" runat="server" Text="Sub Total"></asp:Label>
                </div>
                <div class="col-lg-12 col-md-8 col-sm-12">
                    <asp:TextBox runat="server" ReadOnly="true" ID="txtSub_Total" ClientIDMode="Static" Style="text-align: right;" />
                </div>
                <div class="col-lg-12 col-md-8 col-sm-12">
                    <asp:Label ID="lblTotalDiscAmt" runat="server" Text="Discount Amount"></asp:Label>
                </div>
                <div class="col-lg-12 col-md-8 col-sm-12">
                    <asp:TextBox runat="server" ReadOnly="true" ID="txtTotalDiscAmt" SkinID="userdefinewidth" Style="text-align: right;" />
                </div>
                <div class="col-lg-12 col-md-8 col-sm-12">
                    <asp:Label ID="Label5" runat="server" Text="Total Tax"></asp:Label>
                </div>
                <div class="col-lg-12 col-md-8 col-sm-12">
                    <asp:TextBox runat="server" ReadOnly="true" ID="txtst_amou" ClientIDMode="Static" Style="text-align: right;" />
                </div>
                <div class="col-lg-12 col-md-8 col-sm-12">
                    <asp:Label ID="lblBonusTax" runat="server" Text="Bonus Tax"></asp:Label>
                </div>
                <div class="col-lg-12 col-md-8 col-sm-12">
                    <asp:TextBox runat="server" ReadOnly="true" ID="txtBonusTaxTotal" ClientIDMode="Static" Style="text-align: right;" />
                </div>
                <div class="col-lg-12 col-md-8 col-sm-12">
                    <asp:Label ID="lblfreight_charges" runat="server" Text="Freight Charges"></asp:Label>
                </div>
                <div class="col-lg-12 col-md-8 col-sm-12">
                    <asp:TextBox runat="server" ID="txtfreight_charges" ReadOnly="true" ClientIDMode="Static" SkinID="userdefinewidth" onchange="return caltotal();" />
                </div>
                <div class="col-lg-12 col-md-8 col-sm-12">
                    <asp:Label ID="lblNet_Amount" runat="server" Text="Net Amount"></asp:Label>
                </div>
                <div class="col-lg-12 col-md-8 col-sm-12">
                    <asp:TextBox runat="server" ID="Net_Amount" ReadOnly="true" SkinID="UserDefineWidth" Style="text-align: right;" />
                </div>
                <div>
                    <asp:TextBox ID="txtAdv_amou"  runat="server"  ClientIDMode="Static"  Style="display: none;" ReadOnly="true" />
                </div>
                <div>
                    <asp:TextBox ID="txtFurther_amou" runat="server" ClientIDMode="Static" Style="display: none;" ReadOnly="true" />
                </div>
            </div>

        </div>

    </div>

    <div id="PrintPurchseOrderReport" style="display: none;">
        <div style="height: 110px; -webkit-print-color-adjust: exact; width: 750px; margin-left: 100px">
            <div style="padding: 5px; margin-left: -30px">
                <%--<img height="105" width="120" src="../images/HMIS_Icons/CPHLogoLatest.png" style="margin-top: -1px;">--%>
            </div>
            <div style="width: 350px; height: 110px; margin-top: -113px; margin-left: 177px;">
                <div style="padding-top: 75px; font-size: 20px; font-weight: bold; text-align: center; margin-top: -150px;">
                    As Siraat Serving Humanity
                 
                    <b style="font-size: 14px">(Project of Health & Education Foundaion)</b>
                </div>
            </div>
        </div>
        <div style="margin-left: 360px;">
            <b style="text-align: center; font-size: 26px">PURCHASE ORDER</b>
        </div>
        <table cellpadding="0" cellspacing="0" border="1" bordercolor="white" style="margin-top: 30px; margin-left: 50px; height: 200px; width: 769px">
            <tr>
                <td>
                    <h6 style="width: 100px; text-align: left; font-size: 14px; margin-top: -10px; font-family: Calibri">PO No:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 88px; text-align: center; margin-left: -60px; margin-top: -17px; font-size: 14px">
                        <span id="lvlPOno"></span>
                    </h6>
                </td>
                <td>
                    <h6 style="width: 100px; text-align: left; font-size: 14px; margin-top: -10px; font-family: Calibri">Vendor Name:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 160px !important; text-align: center; margin-top: -17px; font-size: 14px;">
                        <span id="lblVendorName"></span>
                    </h6>
                </td>
                <td>
                    <h6 style="width: 70px; text-align: left; font-size: 14px; margin-top: -8px; font-family: Calibri">Po Date:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 100px; text-align: center; margin-top: -16px; font-size: 14px;">
                        <span id="lvlPoDate"></span>
                    </h6>
                </td>
            </tr>
            <tr>
                <td>
                    <h6 style="width: 78px; text-align: left; margin-top: -40px; font-size: 14px; font-family: Calibri">Ref No</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 100px; text-align: center; margin-left: -60px; margin-top: -43px; font-size: 14px;">
                        <span id="lvlRefNo"></span>
                    </h6>
                </td>

                <td>
                    <h6 style="width: 78px; text-align: left; margin-top: -40px; font-size: 14px; font-family: Calibri">Terms</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 160px; text-align: center; margin-top: -43px; font-size: 14px;">
                        <span id="lblTerms"></span>
                    </h6>
                </td>
                <td>
                    <h6 style="width: 108px; text-align: left; margin-top: -40px; font-size: 14px; font-family: Calibri;">Ware House</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 100px; text-align: center; margin-top: -43px; font-size: 14px;">
                        <span id="lblWareHouse"></span>
                    </h6>
                </td>
            </tr>
            <tr>
                <td>
                    <h6 style="width: 78px; text-align: left; margin-top: -40px; font-size: 14px; font-family: Calibri">Remarks:</h6>
                </td>
                <td colspan="5">
                    <h6 style="border-bottom: 1px dotted #000; width: 580px; text-align: center; margin-left: -61px; margin-top: -45px; font-size: 14px;">
                        <span id="txtRemarksrpt"></span>
                    </h6>
                </td>
            </tr>
        </table>
        <div style="border: 2px solid black; border-collapse: collapse; border-color: gray; margin-top: -20px; margin-left: 52px; width: 733px; min-height: 556px" cellpadding="5" cellspacing="5">
            <table class="table" style="overflow: scroll; width: 734px; margin-top: -5px; font-family: Calibri;" id="tblBilling">
                <thead>
                    <tr>
                        <th style="width: 40px; text-align: left; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray; font-family: Calibri; font-size: 18px">Sr.</th>
                        <th style="width: 300px; text-align: left; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray; font-family: Calibri; font-size: 18px">Description</th>
                        <th style="width: 30px; text-align: left; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray; font-family: Calibri; font-size: 18px">Unit</th>
                        <th style="width: 33px; text-align: right; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray; font-family: Calibri; font-size: 18px">Qty</th>
                        <th style="width: 76px; text-align: right; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray; font-family: Calibri; font-size: 18px">Rate</th>
                        <th style="width: 100px; text-align: right; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray; font-family: Calibri; font-size: 18px">Dis Amount</th>
                        <th style="width: 100px; text-align: right; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray; font-family: Calibri; font-size: 18px">Amount</th>
                    </tr>
                </thead>
                <tbody id="Billtbody">
                </tbody>
            </table>
        </div>
        <table class="table" style="width: 305px; margin-left: 490px;" id="tblBillingDetail" cellpadding="5" cellspacing="5">
            <tr>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray; font-family: Calibri"><b>Total Amount:</b></td>
                <td></td>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray; text-align: Right;">
                    <span id="lblTotalAmount" class="lede" style="font-weight: bold; text-align: Right;"></span>
                </td>
            </tr>
            <tr>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray; font-family: Calibri"><b>Discount:</b></td>
                <td></td>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray; text-align: Right;">
                    <span id="lblDisAmount" class="lede" style="font-weight: bold; text-align: Right;"></span>
                </td>
            </tr>
            <tr>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray; font-family: Calibri"><b>Net Payable:</b></td>
                <td></td>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray; text-align: Right;">
                    <span id="lblNetPayable" class="lede" style="font-weight: bold; text-align: Right;"></span>
                </td>
            </tr>
            <tbody>
            </tbody>
        </table>
        <table class="table" style="margin-left: 50px; margin-top: 20px">
            <tr>
                <td style="font-family: Calibri"><b>Prepared By:</b></td>
                <td style="width: 30px"></td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 230px; text-align: left; font-family: Calibri; margin-left: -19px; margin-top: 15px; font-size: 14px;">
                        <span id="lblOperatorNameb"></span>
                    </h6>
                </td>
                <td style="font-family: Calibri"><b>Checked By:</b></td>
                <td style="width: 30px"></td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 230px; text-align: left; font-family: Calibri; margin-left: -19px; margin-top: 17px; font-size: 14px;">
                        <span id="Span1"></span>
                    </h6>
                </td>
            </tr>
            <tbody>
            </tbody>
        </table>
    </div>
    <div id="POItemsModel" class="modal fade" role="dialog">
        <div class="modal-dialog">
            <div class="modal-content" style="width: 1000px; margin-left: -270px; height: 505px;">
                <div class="modal-header">
                    <h4 class="modal-title">Add PR Items</h4>
                    <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>

                </div>
                <input type="hidden" id="txthiddentr" name="txthidddentr" />
                <div class="table-container" style="width: 970px; overflow: scroll; height: 401px  !important; height: auto;">
                    <table class="table table-bordered" style="width: 953px; height: 80px !important; height: auto; overflow: scroll;" id="tblPOItemstModelTable">
                        <thead>
                            <tr>
                                <th style="width: 32px;">
                                    <input type="checkbox" id="checkHeader" value="false" /></th>
                                <th style="display: none;">Pr ID </th>
                                <th style="display: none;">Item ID </th>
                                <th>Item Name</th>
                                <th>Qty</th>
                                <th style="display: none;"></th>
                                <th style="display: none;"></th>
                                <th style="display: none;"></th>
                                <th style="display: none;"></th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
                <div class="modal-footer">
                    <div class="col-lg-10 col-md-10 col-sm-10">
                        <div class="col-lg-2 col-md-2 col-sm-2">
                            <input type="button" id="PoItem" name="PoItem" value="Close" class="btn btn-gray" data-dismiss="modal" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
        </div>

        <!-- Add this NEW modal for Item Search -->
<div class="modal fade" id="itemsModal" tabindex="-1" aria-labelledby="itemsModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-md">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title" id="itemsModalLabel">Item Details</h3>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close" style="margin-top: -11px !important">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <input type="text" id="searchInput" class="form-control search-input" placeholder="Search items..." />
                <div style="max-height: 400px; overflow-y: auto;">
                    <table class="table table-bordered table-striped table-responsive-md table-responsive-lg">
                        <thead>
                            <tr>
                                <th>Select</th>          <!-- td:eq(0) -->
                                <th style="display:none;">Item ID</th>  <!-- td:eq(1) -->
                                <th>Item Code</th>       <!-- td:eq(2) -->
                                <th>Description</th>     <!-- td:eq(3) -->
                                <th>Unit</th>            <!-- td:eq(4) -->
                                <th style="display:none;">Rate</th>      <!-- td:eq(5) -->
                                <th style="display:none;">UOM Qty</th>   <!-- td:eq(6) -->
                            </tr>
                        </thead>
                        <tbody id="itemsTableBody">
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="modal-footer">
                <div class="col-lg-10 col-md-10 col-sm-10"> </div>
                <div class="col-lg-2 col-md-2 col-sm-2 float-end">
                    <input type="button" value="Close" class="btn-gray" data-dismiss="modal" />
                </div>
            </div>
        </div>
    </div>
</div>
</asp:Content>
