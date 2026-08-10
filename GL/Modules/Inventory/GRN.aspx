<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GRN.aspx.cs" Inherits="PMS.Inventory.GRN" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/custom-modals.css" rel="stylesheet" />
    <style type="text/css">

        .source-select-input {
            flex: 1;
            min-width: 0;
            border-right: none !important;
            border-radius: 5px 0 0 5px !important;
            height: 34px;
            font-size: 13px;
            max-width: 220px;
        }
        .ErrorAlert {
            border: 1px solid red !important;
        }

        .select2-selection__rendered {
            line-height: 30px !important;
        }

        .main input {
            margin-bottom: 0px !important;
        }

        .select2-container .select2-selection--single {
            height: 30px !important;
        }

        .select2-selection__arrow {
            height: 30px !important;
        }

        .table tr td:nth-child(2) {
            text-align: right !important;
        }

        .table tr td:nth-child(3) {
            text-align: left !important;
        }

        .table tr td:nth-child(4) {
            text-align: right !important;
        }

        .table tr td:nth-child(6) {
            text-align: right !important;
        }

        .table tr td:nth-child(7) {
            text-align: center !important;
        }

        .table tr td:nth-child(8) {
            text-align: right !important;
        }

        .table tr td:nth-child(10) {
            text-align: right !important;
        }

        .table tr td:nth-child(12) {
            text-align: right !important;
        }

        .table tr td:nth-child(9) {
            text-align: right !important;
        }

        input[type="text"] {
            font-size: 13px;
            border-radius: 5px !important;
        }

        #ctl00_MainContent_Label2 {
            position: relative;
            left: 7px;
        }

        li.token-input-token p {
            margin: -3px !important;
        }

        input[type="number"] {
            height: 20px !important;
        }

        textarea {
            font-size: 8px !important;
            border-radius: 5px !important;
        }

        #txtStatus {
            font-size: 10px !important;
        }


        select {
            height: 20px !important;
        }

        ul.token-input-list {
            height: 23px !important;
            width: 692px !important;
        }

        div.token-input-dropdown {
            overflow: auto;
            max-height: 150px;
        }

        ul.token-input-list {
            width: 168px;
        }

        .table {
            margin: 1em 0;
            width: 100%;
            overflow: hidden;
            background: #FFF;
            color: #024457;
        }

            .table tr {
                border: 1px solid #D9E4E6;
            }

                .table tr:nth-child(even) {
                    background-color: #EAF3F3;
                }

            .table th {
                display: none;
                border: 1px solid #FFF;
                background-color: #438eb9;
                color: #FFF;
                padding: 1em;
            }

            .table thead th {
                display: table-cell;
                text-align: center;
            }

        @media (min-width: 480px) {
            .table th:nth-child(2) span {
                display: block;
            }

            .table th:nth-child(2):after {
                display: none;
            }
        }

        .table td {
            display: block;
            word-wrap: break-word;
            max-width: 7em;
        }

            .table td:first-child {
                display: table-cell;
                text-align: center;
                border-right: 1px solid #D9E4E6;
            }

        @media (min-width: 480px) {
            .table td {
                border: 1px solid #D9E4E6;
            }
        }

        .table th, .table td {
            text-align: center;
            margin: .5em 1em;
        }

        @media (min-width: 480px) {
            .table th, .table td {
                display: table-cell;
                padding: 1em;
            }
        }

        select option {
            background: #f5f5f5;
            font-weight: bold;
            color: #000000;
            font-size: 10px !important;
        }

        .responstable td {
            height: 0px !important;
            padding: 0 !important;
        }

        .labelIGP {
            font-size: 11px !important;
        }
    </style>
    <script type="text/javascript">
        var GRN_ID = 0;
$(document).ready(function() {
    var date = '<%= DateTime.Now%>';
    $('#itemInputSection').hide();

    $('#DirectGRN').hide();
    $('#ManualGRN').show();
            $("#txtDate").datepicker({ dateFormat: 'mm/dd/yy' }).attr('readonly', 'readonly');
            $("#txtDate").val(date);
            GetNewGRNNo();
            FillVendors();
            GetDepartments();
            GetProject();
            <% if (Request.QueryString["GRN_ID"] != null)
            { %>
            GRN_ID = '<%= Request.QueryString["GRN_ID"]%>'
            LoadGRNData(GRN_ID);
            //$('#SaveButtonToBeHidden').hide();
            $('#thaction').hide();
            <% } %>
            $('select').select2();

            var GRN_ID = '<%= Request.QueryString["GRN_ID"]%>';
            if (GRN_ID == '') {
                $('#btn_Print').hide();
               
            }


            $('#btnGetAllItems').on('click', function() {
                //if (warehouseCond === '01') {
                    var warehouseVal = $('#ddlInv_org').val();
                if (!warehouseVal || warehouseVal === '0' || warehouseVal === '') {
                    Swal.fire({
                        icon: 'warning',
                        title: 'Warning!',
                        text: 'Please select warehouse first',
                        showConfirmButton: true,
                        timer: 3000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                    $('#ddlInv_org').focus();
                    return false;
                }
                //}
                //$('#ctl00_MainContent_ddlPrNo').prop('disabled', true);
                else {
                    LoadAllitem('');
                }
                
            });

            $('#searchInput').on('keyup', function() {
                var searchText = $(this).val().trim();
                LoadAllitem(searchText);
            });
            $('#dircGRN').on('change', function() {
                if ($(this).is(':checked')) {
                    $('#itemInputSection').show();
                    $('#ManualGRN').hide();
                    $('#DirectGRN').show();
                    $('#btnSave').show();
                   
                } else {
                    $('#itemInputSection').hide();
                    $('#DirectGRN').hide();
                    $('#ManualGRN').show();
                }
            });

            //$('#btnGetAllItems').on('click', function() {
            //   // $('#ctl00_MainContent_ddlPrNo').prop('disabled', true);
            //    LoadAllitem('');
            //});

            $('#searchInput').on('keyup', function() {
                var searchText = $(this).val().trim();
                LoadAllitem(searchText);
            });

    $('#txtItem').tokenInput("../../json.aspx?Table=INV_ItemsForPR", {
        tokenLimit: 1,
        onAdd: function(item) {
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

    $.ajax({
        type: "POST",
        url: "GRN.aspx/AllowDirectGRN",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            debugger;
            var code = JSON.parse(response.d);
            console.log("DirectGRN code:", response.d);
            if (code === "02") {
                debugger
                $('[name="grndirect"]').hide();
              
            }
        },
        error: function (error) {
            console.error("Error calling AllowDirectGRN:", error);
        }
    });
    $(document).on('keyup change', 'input[name="txtGRNQtyDir"], input[name="txtRateDir"]', function() {

        var row = $(this).closest('tr');

        var qty = parseFloat(row.find('input[name="txtGRNQtyDir"]').val()) || 0;
        var rate = parseFloat(row.find('input[name="txtRateDir"]').val()) || 0;

        var amount = qty * rate;

        row.find('input[name="txtamountDir"]').val(amount.toFixed(2));

      //  calcTotal(); // Optional: if you have a function to calculate grand total
    });

});

function LoadAllitem(searchText) {
    var warehouseId = $("#ddlInv_org").val();
    if (!warehouseId || warehouseId === '0' || warehouseId === '') {
        Swal.fire({
            icon: 'warning',
            title: 'Warning!',
            text: 'Please select warehouse first',
            showConfirmButton: true,
            timer: 3000,
            customClass: {
                popup: 'swal-big-popup',
                title: 'swal-big-title',
                htmlContainer: 'swal-big-text'
            }
        });
        $('#ddlInv_org').focus();
        return false;
    }
    else {
        debugger;
        $.ajax({
            type: "POST",
            url: "GRN.aspx/GetAllitem",
            data: JSON.stringify({ searchText: searchText, warehouseId: warehouseId }),
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
                        '<td style="">' + (item.Last_GRN_Rate) + '</td>' +
                        '<td>' + (item.TotalStock || 0) + '</td>' +
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
}

        function appendSearchItem(anchor) {
            debugger;

            // Check for projection type 002 requirements before adding item
            var warehouseId = $('#ddlInv_org').val();

            var row = $(anchor).closest('tr');
            var item_id = $(row).find('td:eq(1)').text().trim();
            var item_code = $(row).find('td:eq(2)').text().trim();
            var item_name = $(row).find('td:eq(3)').text().trim();
            var unit = $(row).find('td:eq(4)').text().trim();
            var rate = $(row).find('td:eq(7)').text().trim() || '0';
            var uom_qty = $(row).find('td:eq(6)').text().trim() || '1';
            var total_stock = $(row).find('td:eq(8)').text().trim() || '0';
            var isChecked = $(anchor).prop('checked');

            if (!isChecked) {
                $('#tblItemDescriptionDir tbody tr').each(function () {
                    if ($(this).find('input[name=txtItemCodeDir]').val() === item_code) {
                        $(this).remove();
                    }
                });
                calcTotal();
                return;
            }

            var exists = false;
            $('#tblItemDescriptionDir tbody tr').each(function () {
                if ($(this).find('input[name=txtItemCodeDir]').val() === item_code) {
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
            var length = $("#tblItemDescriptionDir tr:gt(0)").length + 1;
            var defaultQty = '1';

            var newRow = '<tr>' +
                '<td style=" border: 1px solid #D9E4E6;"><input type="hidden" id="txtItemIdDir' + length + '" name="txtItemIdDir" value="' + item_id + '" style="width:50px !important;text-align:right" />' + length + '</td>' +
                '<td style="padding-right: 3px!important;"><input type="hidden" name="txtItemCodeDir" id="txtItemCodeDir' + length + '"  value="' + item_code + '"  style="width:50px !important;text-align:right;font-size:9px;height:10px !important;"/> ' + item_code + ' </td>' +
                '<td style="padding-left: 3px!important;"><input type="hidden" name="txtItemNameDir" id="txtItemNameDir' + length + '"  value="' + item_name + '" style="width:50px !important;text-align:left;font-size:9px;height:10px !important ;"/> ' + item_name + ' </td>' +
                '<td><input type="text" id="txtGRNQtyDir' + length + '" style="text-align:center;width:125px!important;font-size:11px;height:27px;" name="txtGRNQtyDir" value="0" /></td>' +
                '<td><input type="text" id="txtUOMQtyDir' + length + '" style="text-align:center;width:125px!important;font-size:11px;height:27px;" name="txtUOMQtyDir" value="' + uom_qty + '" /></td>' +
                '<td><input type="text" name="BatchNoDir" id="BatchNoDir' + length + '"  value="" style="width:125px !important;text-align:center;font-size:11px;height:27px !important ;"/></td>' +
                '<td><input type="text" style="text-align:center;font-size:9px;" name="txtMfgdateDir" id="txtMfgdateDir' + length + '"   readonly="readonly"/></td>' +
                '<td><input type="text" style="text-align:center;font-size:9px;" name="ExpdateDir" id="ExpdateDir' + length + '"   readonly="readonly"/></td>' +
                '<td><input type="text" id="txtBONQtyDir' + length + '" style="text-align:center;width:125px!important;font-size:11px;height:27px;" name="txtBONQtyDir" value="0" /></td>' +
                '<td><input type="text" style="text-align:center;font-size:11px;" name="txtRateDir" id="txtRateDir' + length + '"  value="' + rate + '" /></td>' +
                '<td style="padding-right: 3px!important;text-align:center;"><input type="text" style="width:125px !important;text-align:right;font-size:11px;height:27px !important;" value="0" readonly="readonly"  id="txtamountDir' + length + '" name="txtamountDir" ></input></td>' +
                '<td style="padding-right: 3px!important;text-align:center;"><input type="text" style="width:125px !important;text-align:right;font-size:11px;height:27px !important;" value="0"  id="txtSaleRateDir' + length + '" name="txtSaleRateDir" ></input></td>' +
                '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="font-size:11px;margin-left: 16px; color: #f30a0a;position:relative;left:-33px"></i></a> </td>' +
                '</tr>';

            // $('#tblItemDescription tbody').append(newRow);
            $('#tblItemDescriptionDir').append(newRow);
            setTimeout(function() {
                $('#txtMfgdateDir' + length).datepicker({
                    dateFormat: 'dd M yy',
                    changeMonth: true,
                    changeYear: true,
                    showButtonPanel: true
                }).attr('readonly', 'readonly').focus(function() {
                    $(this).datepicker('show');
                });
            }, 100);
            setTimeout(function() {
                $('#ExpdateDir' + length).datepicker({
                    dateFormat: 'dd M yy',
                    changeMonth: true,
                    changeYear: true,
                    showButtonPanel: true
                }).attr('readonly', 'readonly').focus(function() {
                    $(this).datepicker('show');
                });
            }, 100);
}
function LoadGRNDetailDir(GRN_ID) {

    PageMethods.LoadGRNDetailDir(GRN_ID, function(resp) {

        var item = JSON.parse(resp);
        var rows = '';
        var iteration = 0;
        var ExpiryDate = '';
        var MfgDate = '';

        $.each(item, function(key, value) {

            if (value.BatchNum == null)
                value.BatchNum = "";

            if (value.ExpiryDate != null) {
                ExpiryDate = $.datepicker.formatDate('dd M yy',
                    new Date(parseInt(value.ExpiryDate.substring(6, 19))));

                if (ExpiryDate.includes("1963") || ExpiryDate.includes("1964") ||
                    ExpiryDate.includes("1965") || ExpiryDate.includes("1966"))
                    ExpiryDate = "";
            }
            else {
                ExpiryDate = "";
            }

            if (value.MfgDate != null) {
                MfgDate = $.datepicker.formatDate('dd M yy',
                    new Date(parseInt(value.MfgDate.substring(6, 19))));

                if (MfgDate.includes("1963") || MfgDate.includes("1964") ||
                    MfgDate.includes("1965") || MfgDate.includes("1966"))
                    MfgDate = "";
            }
            else {
                MfgDate = "";
            }

            iteration++;

            var rowlength = $("#tblItemDescriptionDir tbody tr").length + iteration;

            rows += '<tr>' +
                '<td style="border:1px solid #D9E4E6;">' +
                '<input type="hidden" id="txtItemIdDir' + rowlength + '" name="txtItemIdDir" value="' + value.Item_Id + '" />' +
                rowlength +
                '</td>' +

                '<td>' +
                '<input type="hidden" id="txtItemCodeDir' + rowlength + '" name="txtItemCodeDir" value="' + value.ItemCode + '" />' +
                value.ItemCode +
                '</td>' +

                '<td>' +
                '<input type="hidden" id="txtItemNameDir' + rowlength + '" name="txtItemNameDir" value="' + value.Description + '" />' +
                value.Description +
                '</td>' +

                '<td><input type="text" id="txtGRNQtyDir' + rowlength + '" name="txtGRNQtyDir" value="' + parseFloat(value.GRNQty).toFixed(2) + '" style="text-align:center;width:125px;font-size:11px;height:27px;" /></td>' +

                '<td><input type="text" id="txtUOMQtyDir' + rowlength + '" name="txtUOMQtyDir" value="' + value.UOM_Qty + '" style="text-align:center;width:125px;font-size:11px;height:27px;" /></td>' +

                '<td><input type="text" id="BatchNoDir' + rowlength + '" name="BatchNoDir" value="' + value.BatchNum + '" style="text-align:center;width:125px;font-size:11px;height:27px;" /></td>' +

                '<td><input type="text" id="txtMfgdateDir' + rowlength + '" name="txtMfgdateDir" value="' + MfgDate + '" readonly /></td>' +

                '<td><input type="text" id="ExpdateDir' + rowlength + '" name="ExpdateDir" value="' + ExpiryDate + '" readonly /></td>' +

                '<td><input type="text" id="txtBONQtyDir' + rowlength + '" name="txtBONQtyDir" value="' + value.BounusQty + '" style="text-align:center;width:125px;font-size:11px;height:27px;" /></td>' +

                '<td><input type="text" id="txtRateDir' + rowlength + '" name="txtRateDir" value="' + parseFloat(value.Rate).toFixed(2) + '" style="text-align:center;font-size:11px;" /></td>' +

                '<td><input type="text" id="txtamountDir' + rowlength + '" name="txtamountDir" value="' + parseFloat(value.Amount).toFixed(2) + '" readonly style="width:125px;text-align:right;font-size:11px;height:27px;" /></td>' +
                '<td><input type="text" id="txtSaleRateDir' + rowlength + '" name="txtSaleRateDir" value="' + parseFloat(value.Sale_Rate).toFixed(2) + '" readonly style="width:125px;text-align:right;font-size:11px;height:27px;" /></td>' +
                '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="font-size:11px;color:#f30a0a;"></i></a></td>' +
                '</tr>';

        });

        $('#tblItemDescriptionDir tbody').append(rows);

        $('input[name="txtMfgdateDir"]').datepicker({
            dateFormat: 'dd M yy',
            changeMonth: true,
            changeYear: true
        });

        $('input[name="ExpdateDir"]').datepicker({
            dateFormat: 'dd M yy',
            changeMonth: true,
            changeYear: true
        });

    },
        function(error) {
            alert(error.get_message());
        });
    $('#btnSave').val('Update');
        }

        function LoadGRNData(GRN_ID) {
            PageMethods.LoadGRNHeaderDetail(GRN_ID, function (resp) {
                var data = JSON.parse(resp);
                debugger;
                var TrnsDate = new Date(parseInt(data.GRN_Date.substr(6)));
                TrnsDate = moment(TrnsDate).format('L');
                setTimeout(function () {
                    $('#GRN_Num').val(data.GRN_Num);
                }, 1000);
                $('#txtDate').val(TrnsDate);
                $('#txtStatus').val(data.Status);
                if (data.Status == "Approved") {
                    UserUnApproveButtonRights();
                }
                if (data.Status == "Created") {
                    UserApproveButtonRights();
                }

                $('#dircGRN').prop('checked', data.is_Direct === true).trigger('change');;
                setTimeout(function () {
                    $('#ddlVendor').val(data.VendorId).trigger('change');

                }, 1000);
                setTimeout(function () {
                    $('#ddlInv_org').val(data.InvOrgId).trigger('change');
                }, 1000);
                setTimeout(function () {
                    $('#ddlProject').val(data.Project).trigger('change');
                }, 1000);
                $('#txtRemarks').val(data.Remarks);
                setTimeout(function () {
                    getIGPNumByVendor(data.VendorId);
                }, 3000);

                if (data.is_Direct == true) {
                    LoadGRNDetailDir(GRN_ID);
                }
                else {
                    LoadGRNDetail(GRN_ID);
                }
                
            },
                function (error) {
                    alert(error.get_message());
                })
        }


        function LoadGRNDetail(GRN_ID) {
            PageMethods.LoadGRNDetail(GRN_ID, function (resp) {
                debugger;
                var item = (JSON.parse(resp));
                var rows = '';
                var Description = '';
                var iteration = 0;
                var ExpiryDate = '';
                var MfgDate = '';
                $.each(item, function (key, value) {
                    debugger;
                    if (value.BatchNum == null)
                        value.BatchNum = "";
                    var datetime = $.datepicker.formatDate('dd M yy', new Date(parseInt(item[key].PO_Date.substring(6, 19))));
                    var IGPdate = $.datepicker.formatDate('dd M yy', new Date(parseInt(item[key].IgpDate.substring(6, 19))));
                    if (value.ExpiryDate != null) {
                        ExpiryDate = $.datepicker.formatDate('dd M yy', new Date(parseInt(item[key].ExpiryDate.substring(6, 19))));
                        var IsExist = (ExpiryDate.includes("1963" || "1964" || "1965" || "1966"))
                        if (IsExist) ExpiryDate = "";
                    }
                    if (value.MfgDate != null) {
                        MfgDate = $.datepicker.formatDate('dd M yy', new Date(parseInt(item[key].MfgDate.substring(6, 19))));
                        var IsExist = (MfgDate.includes("1963" || "1964" || "1965" || "1966"))
                        if (IsExist) MfgDate = "";
                    }
                    var RejQty = value.IGPQty - value.GRNQty;
                    iteration++;
                    var rowlength = (document.getElementById("tblItemDescription").rows.length + iteration) - 1;
                    rows += '<tr>' +
                        '<td style=" border: 1px solid #D9E4E6;"><input type="hidden" id="txtIgpDetailId' + rowlength + '" name="txtIgpDetailId" value="' + value.IGPDetailId + '" style="width:50px !important;text-align:right" />' + rowlength + '</td>' +
                        '<td style="padding-right: 3px!important;"><input type="hidden" name="txtItemCode" id="txtItemCode' + rowlength + '"  value="' + value.Item_Code + '"  style="width:50px !important;text-align:right;font-size:9px;height:10px !important;"/> ' + value.Item_Code + ' </td>' +
                        '<td style="padding-left: 3px!important;"><input type="hidden" name="txtItemName" id="txtItemName' + rowlength + '"  value="' + value.Description + '" style="width:50px !important;text-align:left;font-size:9px;height:10px !important ;"/> ' + value.Description + ' </td>' +
                        '<td style="padding-left: 3px!important;"><input type="hidden" name="txtIgp_num" id="txtIgp_num' + rowlength + '"  value="' + value.IgpNum + '" />' + value.IgpNum + ' </td>' +
                        '<td><input type="text" style="text-align:center;font-size:9px;" name="txtIGPdate" id="txtIGPdate' + rowlength + '"  value="' + IGPdate + '" readonly="readonly"/></td>' +
                        '<td><input type="hidden" style="width:61px !important;text-align:center;font-size:9px;height:10px !important;" name="txtPO_No" id="txtPO_No' + rowlength + '"  value="' + value.PO_No + '" readonly="readonly"/>' + value.PO_No + '</td>' +
                        '<td><input type="text" style="text-align:center;font-size:9px;" name="txtPOdate" id="txtPOdate' + rowlength + '"  value="' + datetime + '" readonly="readonly"/></td>' +
                        '<td><input type="hidden" name="BatchNo" id="BatchNo' + rowlength + '"  value="' + value.BatchNum + '" style="width:50px !important;text-align:left;font-size:9px;height:10px !important ;"/>' + value.BatchNum + '</td>' +
                        '<td><input type="text" style="text-align:center;font-size:9px;" name="txtMfgdate" id="txtMfgdate' + rowlength + '"  value="' + MfgDate + '" readonly="readonly"/></td>' +
                        '<td><input type="text" style="text-align:center;font-size:9px;" name="Expdate" id="Expdate' + rowlength + '"  value="' + ExpiryDate + '" readonly="readonly"/></td>' +
                        '<td style="text-align:right;"><input type="hidden" style="width:61px !important;text-align:center;font-size:9px;height:10px !important;" name="IGPQty" id="IGPQty' + rowlength + '"  value="' + parseFloat(value.IGPQty).toFixed(2) + '" />' + parseFloat(value.IGPQty).toFixed(2) + '</td>' +
                        '<td style="padding-right: 3px!important;display:none;"><input type="hidden"  style="width: 50px !important;text-align:right;font-size:9px;height:10px !important;  id="AccQty' + rowlength + '" name="AccQty" style="width:50px !important;"></input>' + parseFloat(value.GRNQty).toFixed(2) + '</td>' +
                        '<td style="padding-right: 3px!important;display:none;"><input type="hidden" style="width:50px !important;text-align:right;font-size:9px;height:10px !important;" value="' + parseFloat(RejQty).toFixed(2) + '"  id="RejQty' + rowlength + '" name="RejQty" >' + parseFloat(RejQty).toFixed(2) + '</input></td>' +

                        '<td style="padding-right: 3px!important;text-align:right;"><input type="hidden" style="width:50px !important;text-align:right;font-size:9px;height:10px !important;" value="' + value.Amount + '"  id="txtpoamount' + rowlength + '" name="txtpoamount" >' + value.Amount + '</input></td>' +
                        '<td style="width:50px !important;text-align:right;font-size:9px;height:10px !important;"><input type="hidden" style="width:50px !important;text-align:right;font-size:9px;height:10px !important;position: relative;left: -14px;" value="' + parseFloat(value.GRNQty).toFixed(2) + '"  id="GRNQty' + rowlength + '" name="GRNQty">' + parseFloat(value.GRNQty).toFixed(2) + '</input></td>' +
                        '<td style="padding-right: 3px!important;text-align:right;">' +
                        '<input type="hidden" name="SaleRate" id="SaleRate' + rowlength + '" ' +
                        'value="' + (value.Sale_Rate != null ? parseFloat(value.Sale_Rate).toFixed(2) : '') + '" />' +
                        (value.Sale_Rate != null ? parseFloat(value.Sale_Rate).toFixed(2) : '') +
                        '</td>' +
                        '</tr>';
                });
                debugger;
                $('#tblItemDescription').append(rows);
                $('input[name="txtPOdate"]').datepicker({ dateFormat: 'dd M yy' });
                $('input[name="txtMfgdate"]').datepicker({ dateFormat: 'dd M yy' });
                $('input[name="Expdate"]').datepicker({ dateFormat: 'dd M yy' });
                $('#btnSave').val('Update');
            },
                function (error) {
                    alert(error.get_message());
                })
        }

        function GetNewGRNNo() {
            PageMethods.GetNewGRNNo(function (resp) {
                $('#GRN_Num').val(resp);
            },
                function (error) {
                    alert(error.get_message());
                })
        }

        function GetDepartments() {
            debugger;
            PageMethods.GetDepartments(function (Tests) {
                debugger
                optionsInv = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    debugger;
                    if (value.Type == "WareHouse") {
                        optionsInv += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                });
                $('#ddlInv_org').html(optionsInv);
            });
        }

        function GetProject() {
            debugger;
            var optionProj = '';
            PageMethods.GetProjects(function (Tests) {
                debugger
                optionProj = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    debugger;
                    optionProj += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddlProject').html(optionProj);
            });
        }

        function FillVendors() {
            debugger;
            var optionsVen = '';
            PageMethods.getVendorDDLlist(function (Tests) {
                debugger
                optionsVen = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    debugger;
                    if (value.Active == true) {
                        optionsVen += '<option value="' + value.VendorID + '" >' + value.VendorName + '</option>';
                    }
                    else {
                        optionsVen += '<option value="' + value.VendorID + '"  disabled>' + value.VendorName + '</option>';
                    }
                });
                $('#ddlVendor').html(optionsVen);
            });
        }
        function getIGPNumByVendor(item) {
            debugger;
            var optionsIgp = '';
            var VendorId;
            VendorId = item;
            if (VendorId == undefined) {
                VendorId = item;
            }
            PageMethods.GetIGPNoByVendor(VendorId, function (res) {
                debugger;
                var item = JSON.parse(res);
                optionsIgp = '<option value="0">Please Select</option>';
                $.each(item, function (key, value) {
                    optionsIgp += '<option value="' + value.Igp_Id + '" >' + value.Igp_num + '</option>';
                })
                debugger;
                $("#ddlIgpNo option").remove();
                $('#ddlIgpNo').html(optionsIgp);
            });
        }

        function PerformIGPSearch() {
            debugger;
            var IGPId = $('#ddlIgpNo').val();
            var IGPNum = $("#ddlIgpNo option:selected").text();
            var blncQty = 0;
            if (IGPId != "") {
                PageMethods.getIGPByID(IGPId, function (res) {
                    debugger;
                    var item = JSON.parse(res);
                    var rows = '';
                    var iteration = 0;
                    $('#thaction').show();
                    $.each(item, function (key, value) {
                        debugger;
                        if (value.BatchNum == null)
                            value.BatchNum = "";
                        var datetime = $.datepicker.formatDate('dd M yy', new Date(parseInt(item[key].PO_Date.substring(6, 19))));
                        var IGPdate = $.datepicker.formatDate('dd M yy', new Date(parseInt(item[key].Igp_date.substring(6, 19))));
                        iteration++;
                        var rowlength = (document.getElementById("tblItemDescription").rows.length + iteration) - 1;
                        var test_array = $('#tblItemDescription').find('input[name=txtItemCode][value=' + value.Item_Code + ']');

                        if (test_array.length > 0) {

                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'This Item already added',
                                showConfirmButton: false,
                                timer: 2000,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });


                             $('#ctl00_MainContent_txtPRNo').tokenInput("clear");
                            return false;
                        }
                        else {
                            rows += '<tr>' +
                                '<td style=" border: 1px solid #D9E4E6;"><input type="hidden" id="txtIgpDetailId' + rowlength + '" name="txtIgpDetailId" value="' + value.Igp_item_ID + '" style="width:50px !important;text-align:right" />' + rowlength + '</td>' +
                                '<td style="padding-right: 3px!important;"><input type="hidden" name="txtItemCode" id="txtItemCode' + rowlength + '"  value="' + value.Item_Code + '"  style="width:50px !important;text-align:right;font-size:9px;height:10px !important;"/> ' + value.Item_Code + ' </td>' +
                                '<td style="padding-left: 3px!important;"><input type="hidden" name="txtItemName" id="txtItemName' + rowlength + '"  value="' + value.Description + '" style="width:50px !important;text-align:left;font-size:9px;height:10px !important ;"/> ' + value.Description + ' </td>' +
                                '<td style="padding-left: 3px!important;"><input type="hidden" name="txtIgp_num" id="txtIgp_num' + rowlength + '"  value="' + value.Igp_num + '" />' + value.Igp_num + ' </td>' +
                                '<td><input type="text" style="text-align:center;font-size:9px;" name="txtIGPdate" id="txtIGPdate' + rowlength + '"  value="' + IGPdate + '" readonly="readonly"/></td>' +
                                '<td><input type="hidden" style="width:61px !important;text-align:center;font-size:9px;height:10px !important;" name="txtPO_No" id="txtPO_No' + rowlength + '"  value="' + value.PO_No + '" readonly="readonly"/>' + value.PO_No + '</td>' +
                                '<td><input type="text" style="text-align:center;font-size:9px;" name="txtPOdate" id="txtPOdate' + rowlength + '"  value="' + datetime + '" readonly="readonly"/></td>' +
                                '<td><input type="hidden" name="BatchNo" id="BatchNo' + rowlength + '"  value="' + value.BatchNum + '" style="width:50px !important;text-align:left;font-size:9px;height:10px !important ;"/>' + value.BatchNum + '</td>' +
                                '<td><input type="text" style="text-align:center;font-size:9px;" name="txtMfgdate" id="txtMfgdate' + rowlength + '"  value="" readonly="readonly"/></td>' +
                                '<td><input type="text" style="text-align:center;font-size:9px;" name="Expdate" id="Expdate' + rowlength + '"  value="" readonly="readonly"/></td>' +
                                '<td style="padding-right: 3px!important;"><input type="hidden" value="' + parseFloat(value.IGPQty).toFixed(2) + '" style="width: 50px !important;text-align:right;font-size:9px;height:10px !important;  id="IGPQty' + rowlength + '" name="IGPQty" style="width:50px !important;"></input>' + parseFloat(value.IGPQty).toFixed(2) + '</td>' +
                                '<td style="padding-right: 3px!important;"><input type="text" value="0" style="text-align:right;font-size:9px;  id="AccQty' + rowlength + '" name="AccQty" style="width:50px !important;" onkeyup="CulculateRejQty(this)"></input></td>' +
                                '<td style="padding-right: 3px!important;"><input type="hidden" style="width:50px !important;text-align:right;font-size:9px;height:10px !important;" value="0"  id="RejQty' + rowlength + '" name="RejQty" ></input></td>' +
                                '<td style="width:50px !important;text-align:right;font-size:9px;height:10px !important;"><input type="hidden" style="width:50px !important;text-align:right;font-size:9px;height:10px !important;position: relative;left: -14px;" value="0"  id="GRNQty' + rowlength + '" name="GRNQty"></input></td>' +
                                '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="font-size:11px;margin-left: 16px; color: #f30a0a;position:relative;left:-33px"></i></a> </td>' +
                                '</tr>';
                        }
                    });
                    debugger;
                    $('#tblItemDescription').append(rows);
                    $('input[name="txtPOdate"]').datepicker({ dateFormat: 'dd M yy' });
                    $('input[name="txtMfgdate"]').datepicker({ dateFormat: 'dd M yy' });
                    $('input[name="Expdate"]').datepicker({ dateFormat: 'dd M yy' });
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

        function ExcludeFromPayment(anchor) {
            debugger;
            var a = confirm("Are you sure You want to delete");
            if (a == true) {
                console.clear();
                var row = $(anchor).parents('tr')[0];
                row.remove();
            }
        }
        function SaveAllRecord() {
            debugger;
            var status;
            var dateStatus;
            var btnSave = $('#btnSave').val();
            var GRN_Num = $('#GRN_Num').val();
            var date = $('#txtDate').val();
            var VendorId = $('#ddlVendor').val();
            var Remarks = $('#txtRemarks').val();
            var InvOrg = $('#ddlInv_org').val();
            var project = $('#ddlProject').val();
            var table = $('#tblItemDescriptionDetail');
            var tableDir = $('#tblItemDescriptionDetailDir');
            var Is_Direct = $('#dircGRN').is(':checked');
            if (VendorId == '0') {
                $("#ddlVendor").addClass('ErrorAlert');
                $('#select2-ddlVendor-container').parent().css('border-color', 'red');
            }
            else {
                $("#ddlVendor").removeClass('ErrorAlert');
                $('#select2-ddlVendor-container').parent().css('border-color', ' rgb(206, 191, 191)');
            }
            if (InvOrg == '0') {
                $("#ddlInv_org").addClass('ErrorAlert');
                $('#select2-ddlInv_org-container').parent().css('border-color', 'red');
            }
            else {
                $("#ddlInv_org").removeClass('ErrorAlert');
                $('#select2-ddlInv_org-container').parent().css('border-color', ' rgb(206, 191, 191)');
            }
            var tblLength = $("#tblItemDescription tr:gt(0)").length;
            var tblLengthDir = $("#tblItemDescriptionDir tr:gt(0)").length;
            if (tblLength == '0' && tblLengthDir == '0') {
                $('#tblItemDescription').addClass('ErrorAlert');
            } else {
                $('#tblItemDescription').removeClass('ErrorAlert');
            }
            if (!$('#ddlVendor').hasClass('ErrorAlert') && !$('#ddlInv_org').hasClass('ErrorAlert') && !$('#tblItemDescription').hasClass('ErrorAlert')) {
                var Item_list = [];
                debugger;
                table.find('tr').each(function (key, value) {
                    debugger;
                    var AccQTy = $(value).find('td input[name=AccQty]').val();
                    var GRNdate = new Date(date).setHours(0, 0, 0, 0);
                    var ExpDate = new Date($(value).find('td input[name=Expdate]').val()).setHours(0, 0, 0, 0);
                    var IgpQty = $(value).find('td input[name=IGPQty]').val();
                    if (GRNdate > ExpDate) {
                        dateStatus = "DateFalse";
                    }
                    if (AccQTy == "0" || IgpQty < AccQTy) {
                        status = false;
                    }
                    else {
                        Item_list.push({ 'IGPDetailId': $(value).find('td input[name=txtIgpDetailId]').val(), 'ItemCode': $(value).find('td input[name=txtItemCode]').val(), 'Mfgdate': $(value).find('td input[name=txtMfgdate]').val(), 'Expdate': $(value).find('td input[name=Expdate]').val(), 'AccQty': $(value).find('td input[name=AccQty]').val(), 'GRNQty': $(value).find('td input[name=GRNQty]').val(), });
                    }

                });
                var ItemListDir = [];
                var status = true;
                var dateStatus = "";

                $('#tblItemDescriptionDir tbody tr').each(function(key, value) {

                    var grnQty = $(value).find('input[name=txtGRNQtyDir]').val() || "0";
                    var mfgDate = $(value).find('input[name=txtMfgdateDir]').val();
                    var expDate = $(value).find('input[name=ExpdateDir]').val();

                    // Validate expiry date if entered
                    if (expDate != "") {
                        var GRNdate = new Date(date).setHours(0, 0, 0, 0); // date = GRN Date
                        var ExpDate = new Date(expDate).setHours(0, 0, 0, 0);

                        if (GRNdate > ExpDate) {
                            dateStatus = "DateFalse";
                        }
                    }

                    // Quantity validation
                    if (parseFloat(grnQty) <= 0) {
                        status = false;
                    }
                    else {

                        ItemListDir.push({
                            'ItemIdDir': $(value).find('input[name=txtItemIdDir]').val(),
                            'ItemCodeDir': $(value).find('input[name=txtItemCodeDir]').val(),
                           // 'ItemNameDir': $(value).find('input[name=txtItemNameDir]').val(),
                            'GRNQtyDir': $(value).find('input[name=txtGRNQtyDir]').val(),
                            'UOMQtyDir': $(value).find('input[name=txtUOMQtyDir]').val(),
                            'BatchNoDir': $(value).find('input[name=BatchNoDir]').val(),
                            'MfgdateDir': $(value).find('input[name=txtMfgdateDir]').val(),
                            'ExpdateDir': $(value).find('input[name=ExpdateDir]').val(),
                            'BONQtyDir': $(value).find('input[name=txtBONQtyDir]').val(),
                            'RateDir': $(value).find('input[name=txtRateDir]').val(),
                            'AmountDir': $(value).find('input[name=txtamountDir]').val(),
                            'SaleRateDir': $(value).find('input[name=txtSaleRateDir]').val()
                        });

                    }

                });
                if (dateStatus == "DateFalse") {

                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Exp Date must not be less then GRN date',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });


                     return false;
                }
                else if (status == false) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Acc QTY Must Be greater than 0 OR Acc Qty must not greater then IGP qty',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });


                     return false;
                }
                else {
                    $('#btnsave').attr('disabled', true);
                    var AllItemDetail = { 'GRN_Num': GRN_Num, 'Date': date, 'VendorId': VendorId, 'remarks': Remarks, 'project': project, 'InvOrg': InvOrg, 'ItemList': Item_list, 'ItemListDir': ItemListDir, 'Is_Direct': Is_Direct };
                    PageMethods.SaveGRNDetail(btnSave, JSON.stringify(AllItemDetail), function (res) {
                        debugger;
                        sendFile(res, function () {
                            Swal.fire({
                                icon: 'success',
                                title: 'Success!',
                                text: 'Data Save Successfully.',
                                showConfirmButton: false,
                                timer: 2500,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });
                            $('#btnSave').val("Update");
                            window.location = "GRN.aspx?GRN_ID=" + res;
                        });
                    });
                }
            }
            else {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Add Items',
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
      
        function CulculateRejQty(anchor) {
            debugger;
            var row = $(anchor).parents('tr')[0];
            var IgpQty = $($(row).find('td input[name=IGPQty]')[0]).val();
            var AccQty = $($(row).find('td input[name=AccQty]')[0]).val();
            var RejQty = IgpQty - AccQty;
            $($(row).find('td')[12]).text(RejQty);
            $($(row).find('td')[13]).text(AccQty);
        }
        function PrintGRNDetail() {
            var id = '<% =Request.QueryString["GRN_ID"] %>';
            var locationInfo = window.location;


            var user_name = '<% =AppConfig.Company_Name %>';
            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx'; // same folder
            }

            var url = '/ReportViewer.aspx?ReportName=GRNList&ReportTitle=Good Receipt List&GRNid=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/' + reportPath +  '?ReportName=GRNList&ReportTitle=Good Receipt List&GRNid=' + id;
            }
            window.open(url, '_blank');
        }
        function PrintVoucher() {
            var id = '<% =Request.QueryString["GRN_ID"] %>';
            var locationInfo = window.location;


            var user_name = '<% =AppConfig.Company_Name %>';
            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx'; // same folder
            }

            var url = '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=GRN Voucher&TransID=' + id + '&TransType=GRN';
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/' + reportPath +  '?ReportName=Voucher&ReportTitle=GRN Voucher&TransID=' + id + '&TransType=GRN';
            }
            window.open(url, '_blank');
        }
        function sendFile(ID, callback) {
            debugger;
            var fileInput = $('#choseGRNfile')[0];
            if (fileInput.files.length > 0) {
                var data = new FormData();
                data.append('file', $('#choseGRNfile')[0].files[0]);
                data.append('ID', ID);
                $.ajax({
                    type: 'post',
                    url: '../../upload/UploadGRNFiles.ashx',
                    data: data,
                    success: function (status) {
                        if (typeof callback === 'function') callback();
                    },
                    processData: false,
                    contentType: false,
                    error: function () {
                        alert("Whoops something went wrong!");
                    }
                });
            } else {
                if (typeof callback === 'function') callback();
    }
}
        function Approve() {
            var GRNId = '<%= Request.QueryString["GRN_ID"] %>';

    PageMethods.ApproveGRN(GRNId, function (message) {

        if (message && message.trim() !== "") {

            var icon = message.toLowerCase().includes("approved")
                ? "success"
                : "error";

            Swal.fire({
                icon: icon,
                title: icon === "success" ? "Success" : "Error",
                text: message,
                showConfirmButton: true,
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            }).then(() => {
                if (icon === "success") {
                    location.reload();
                }
            });
        }

    }, function (err) {
        Swal.fire({
            icon: "error",
            title: "Error",
            text: err.get_message()
        });
    });
}

        function UserUnApproveButtonRights() {
            debugger;
            $.ajax({
                type: "POST",
                url: "GRN.aspx/UserUnApproveEntryRights",
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

                    alert("Failed to retrieve User UnApprove Button Rights.");
                }
            });
        }
        function UserApproveButtonRights() {
            debugger;
            $.ajax({
                type: "POST",
                url: "GRN.aspx/UserUnApproveEntryRights",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var hasRights = response.d;
                    debugger;
                    if (hasRights) {
                        debugger;
                        $('#btnApprove').show();
                    } else {
                        $('#btnApprove').hide();
                    }
                },
                failure: function (response) {
                    alert("Failed to retrieve User Approve Button Rights.");
                }
            });
        }
        function UnApprove() {
            debugger;
            var GRNId = '<% =Request.QueryString["GRN_ID"] %>';
            PageMethods.UnApproveGRN(GRNId, function (Tests) {
                debugger
                var message = JSON.parse(Tests);
                if (message[0].Column1 != "" || message[0].Column1 != null) {
                    alert(message[0].Column1);
                    location.reload();
                }
            });
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <form id="item">
        <div class="row">
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="LblIGP_Num" class="labelIGP">GRN No</label>
                <input type="text" class="form-control" id="GRN_Num" name="GRN_Num" readonly="readonly" />
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="Lbl_Date" class="labelIGP">Date</label>
                <input type="text" class="form-control" id="txtDate" name="txtDate" />
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="lbltxtVendor" class="labelIGP">Vendor</label>
                <select class="form-control" id="ddlVendor" name="ddlVendor" onchange="getIGPNumByVendor(this)">
                </select>
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="lblPO_No" class="labelIGP">Igp No</label>
                <select class="form-control" id="ddlIgpNo" name="ddlIgpNo" onchange="PerformIGPSearch()">
                </select>
            </div>
            </div>


            <div class="row">
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="lblInvOrg" class="labelIGP">Warehouse</label>
                <select id="ddlInv_org" class="form-control">
                </select>
            </div>

            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="LblProject" class="labelIGP">Project</label>
                <select id="ddlProject" class="form-control" name="ddlProject">
                </select>
            </div>
           <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="lblStatus" class="labelIGP">Status</label>
                <input type="text" class="form-control" id="txtStatus" readonly="readonly" />
            </div>

            <div class="col-lg-3 col-md-6 col-sm-12">
                 <label id="lblrem" class="labelIGP">Remarks</label>
                 <textarea id="txtRemarks" class="form-control" rows="2" cols="20"></textarea>
             </div>
         </div>

        <div class="row">
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="lblAttachment" class="labelIGP">Attachment</label>
                <input type="file" id="choseGRNfile" name="choseGRNfile" />
                <asp:HyperLink ID="HyperLink1" runat="server">Download</asp:HyperLink>
            </div>

            <div class="col-lg-1 col-md-6 col-sm-12" name="grndirect">
                <label class="source-radio-option">
                    Direct GRN
                </label>
            </div>

            <div class="col-lg-1 col-md-6 col-sm-12"  name="grndirect">
     
                <input type="checkbox" name="dircGRN" id="dircGRN" value="item" />
            </div>
            <div id="itemInputSection" class="col-lg-4 col-md-6 col-sm-12">
                
                   <%-- <input type="hidden" id="txtItem" class="source-select-input" placeholder="Search items..." />--%>
                    <button type="button" class="btn btn-primry" id="btnGetAllItems" onclick="LoadAllitem('')"><i class="fa fa-search"></i>Items</button>
              
            </div>


        </div>

     
     </form>

            <div id="ManualGRN" class="table-container" style="width:100%">
                <table class="table " id="tblItemDescription" style="margin-top: 13px; font-size: 10px!important; width: 100% !important; overflow: unset;">
                    <thead>
                        <tr>
                            <th style="text-align: center;">Sr No.</th>
                            <th style="text-align: center; font-size: 10px;">Item Code</th>
                            <th style="text-align: center;">Item Description</th>
                            <th style="text-align: center;">IGP #</th>
                            <th style="text-align: center;">IGP Date</th>
                            <th style="text-align: center;">PO No</th>
                            <th style="text-align: center;">PO Date</th>
                            <th style="text-align: center;">Batch No</th>
                            <th style="text-align: center;">Mfg Date</th>
                            <th style="text-align: center;">Exp Date</th>
                            <th style="text-align: center;">IGP Qty</th>
                            <th style="display: none; text-align: center;">Acc Qty</th>
                            <th style="display: none; text-align: center;">Rej Qty</th>
                            <th style="text-align: center;">Rate</th>
                            <th style="text-align: center;">GRN Qty</th>
                            <th style="text-align: center;">Sale Rate</th>
                            <th style="text-align: center;" id="thaction">Action</th>
                        </tr>
                    </thead>
                    <tbody id="tblItemDescriptionDetail">
                    </tbody>
                </table>
            </div>
    
            <div id="DirectGRN" class="table-container" style="width:100%">
                <table class="table " id="tblItemDescriptionDir" style="margin-top: 13px; font-size: 10px!important; width: 100% !important; overflow: unset;">
                    <thead>
                        <tr>
                            <th style="text-align: center;">Sr No.</th>
                            <th style="text-align: center; font-size: 10px;">Item Code</th>
                            <th style="text-align: center;">Item Description</th>
                            <th style="text-align: center;">GRN Qty</th>
                            <th style="text-align: center;">UOM</th>
                            <th style="text-align: center;">Batch No</th>
                            <th style="text-align: center;">Mfg Date</th>
                            <th style="text-align: center;">Exp Date</th>
                            <th style="text-align: center;">Bounus Qty</th>
                            <th style="text-align: center;">Rate</th>
                            <th style="text-align: center;">Amount</th>
                            <th style="text-align: center;">Sale Rate</th>
                            <th style="text-align: center;" id="thactiond">Action</th>
                        </tr>
                    </thead>
                    <tbody id="tblItemDescriptionDetailDir">
                    </tbody>
                </table>
            </div>

    <div class="purchaseOrderSubmitForm" style=" margin-top: 21px;">       
        <div class="row">
            <div class="col-lg-8">
                <div class="row">
                    <div class="col-lg-2 col-md-4 col-sm-12">
                        <input type="button" class="btn btn-primry" value="Voucher" id="btnVoucher" onclick="PrintVoucher()" />
                        &nbsp;
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-12">
                        <input type="button" class="btn btn-gray" value="List" onclick="window.location = 'GRNView.aspx'" />
                        &nbsp;
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-12">
                        <input type="button" class="btn-primry" value="Print" name="name" id="btn_Print" onclick="PrintGRNDetail();" style="width: 81px;" />
                        &nbsp;
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-12" id="SaveButtonToBeHidden">
                        <input type="button" class="btn-primry" onclick="SaveAllRecord()" value="Save" id="btnSave" style="width: 81px; display: none" />
                        &nbsp;
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-12">
                        <input type="button" class="btn-primry" style="width: 103px; display: none" value="UnApprove" id="btnUnApprove" onclick="UnApprove()" />
                        &nbsp;
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-12">
                        <input type="button" class="btn-primry" style="width: 93px; display: none" value="Approve" id="btnApprove" onclick="Approve()" />
                        &nbsp;
                    </div>

                    <div class="col-lg-2 col-md-4 col-sm-12">
                        <input type="button" value="New" class="btn btn-yellow" onclick="window.location = 'GRN.aspx'" style="display: none" />
                    </div>
                </div>
            </div>

        </div>
    </div>

       <div class="modal fade" id="itemsModal" tabindex="-1" aria-labelledby="itemsModalLabel" aria-hidden="true">
       <div class="modal-dialog modal-lg custom-modal-dialog">
           <div class="modal-content custom-modal-content">
               <div class="modal-header custom-modal-header">
                   <div class="custom-modal-title-wrap">
                       <span class="custom-modal-icon"><i class="fa fa-cubes"></i></span>
                       <h4 class="modal-title custom-modal-title" id="itemsModalLabel">Item Details</h4>
                   </div>
                   <button type="button" class="custom-modal-close" data-dismiss="modal" aria-label="Close"><i class="fa fa-times"></i></button>
               </div>
               <div class="modal-body custom-modal-body">
                   <div class="custom-modal-search-wrap">
                       <span class="custom-modal-search-icon"><i class="fa fa-search"></i></span>
                       <input type="text" id="searchInput" class="custom-modal-search" placeholder="Search items..." />
                   </div>
                   <div class="custom-modal-table-wrap">
                       <table class="table custom-modal-table">
                           <thead>
                               <tr>
                                   <th>Select</th>
                                   <!-- td:eq(0) -->
                                   <th style="display: none;">Item ID</th>
                                   <!-- td:eq(1) -->
                                   <th>Item Code</th>
                                   <!-- td:eq(2) -->
                                   <th>Description</th>
                                   <!-- td:eq(3) -->
                                   <th>Unit</th>
                                   <!-- td:eq(4) -->
                                   <th style="display: none;">Rate</th>
                                   <!-- td:eq(5) -->
                                   <th style="display: none;">UOM Qty</th>

                                   <th>Last Purchase Rate</th>
                                   <!-- td:eq(6) -->
                                   <th>Stock</th>
                               </tr>
                           </thead>
                           <tbody id="itemsTableBody">
                           </tbody>
                       </table>
                   </div>
               </div>
               <div class="modal-footer">
                   <input type="button" value="Close" class="btn-gray" data-dismiss="modal" />
               </div>
           </div>
       </div>
   </div>
</asp:Content>
