<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AddPurchaseInvoice.aspx.cs" Inherits="PMS.Inventory.AddPurchaseInvoice" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/AddpurchaseInvoice.css" rel="stylesheet" />
    <script type="text/javascript">

        var vendor_Id_Global = 0;
        var _gloabal = '';
        function Fillwtaxtype() {
            debugger;
            var optionsVen = '';
            PageMethods.getwtaxtype(function (Tests) {
                debugger;
                $.each(JSON.parse(Tests), function (key, value) {
                    debugger;
                    optionsVen += '<option value="' + value.Sales_Tax_ID + '" >' + value.Sales_Tax_Perc + '</option>';
                });
                _gloabal = optionsVen;
            });
        }
        var optionsDeptfill = '<option>Please Select</option>';
        var optionfed = '';
        var global = '';
        $(document).ready(function () {
            UserRights();
            $('#btnSave').click(function () {
                debugger;
                SaveAllRecord();
            });
            $(function () {
                $("#tabs").tabs();
            });
            setTimeout(function () {
                Fillwtaxtype();
            }, 500);
            $('[id*=checkHeader]').click(function () {
                var isTrue = $('#checkHeader').is(':checked');
                if (isTrue) {
                    debugger;
                    $('.chktd').prop('checked', true);
                    setTimeout(function () {
                        $("#tblPOItemstModelTable tr:gt(0) input[type=checkbox]:checked ").each(function (key, value) {
                            debugger;
                            var row = $(this);
                            console.log(row);
                            append(row);
                        });
                    }, 1000);
                }
                else {
                    $('.chktd').prop('checked', false);
                }
            });
            $.ajax({
                type: "POST",
                url: "AddPurchaseInvoice.aspx/AllowDirectGRN",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var code = JSON.parse(response.d);
                  
                    if (code === "02") {
                        debugger
                        $('[name="directgrn"]').hide();

                    }
                },
                error: function (error) {
                    console.error("Error calling AllowDirectGRN:", error);
                }
            });
            var currentDate = new Date();
            var formattedDate = $.datepicker.formatDate('dd M yy', currentDate);

            var $datepicker = $('#txt_invoicedate');

            $datepicker.datepicker({
                changeMonth: true,
                changeYear: true,
                yearRange: "-50:+50",
                dateFormat: "dd M yy"
            });

            var currentDate = $.datepicker.formatDate("dd M yy", new Date());
            $datepicker.val(currentDate);

            var $datepicker = $('#txt_accountingDate');

            $datepicker.datepicker({
                changeMonth: true,
                changeYear: true,
                yearRange: "-50:+50",
                dateFormat: "dd M yy"
            });

            var currentDate = $.datepicker.formatDate("dd M yy", new Date());
            $datepicker.val(currentDate);

            var $datepicker = $('#txt_dueDate');

            $datepicker.datepicker({
                changeMonth: true,
                changeYear: true,
                yearRange: "-50:+50",
                dateFormat: "dd M yy"
            });

            var currentDate = $.datepicker.formatDate("dd M yy", new Date());
            $datepicker.val(currentDate);

            var $datepicker = $('#txt_exDate');

            $datepicker.datepicker({
                changeMonth: true,
                changeYear: true,
                yearRange: "-50:+50",
                dateFormat: "dd M yy"
            });

            var currentDate = $.datepicker.formatDate("dd M yy", new Date());
            $datepicker.val(currentDate);
            $('select').select2();
            GetNewInvoiceNo();
            GetDepartments();
            FillVendors();
            filldropdown();
            <% if (Request.QueryString["Inv_ID"] != null)
            { %>
            var Inv_ID = '<%= Request.QueryString["Inv_ID"]%>'
            LoadInvoiceData(Inv_ID);
            <% } %>
            var Inv_ID = '<%= Request.QueryString["Inv_ID"]%>'
            if (Inv_ID == '') {
                $('#btn_Print').hide();
                $('#btnVoucher').hide();
            }
            $('#btn_GRN').on('click', function () {
                debugger;
                var vendorId = $("#ddl_Vendor").val();
                LoadGRNDetail(vendorId);
                $('#ctl00_MainContent_txt_Remarks').focus();
                $('#txt_Remarks').focus();
            });
            $("#PoNum").on("change", function () {
                debugger;
                var value = $(this).val();
                if (value == "") {
                    $('#tblPOItemstModelTable tbody tr').remove();
                    var vendorId = $("#ddl_Vendor").val();
                    LoadGRNDetail(vendorId);
                }
                var temp = '';
                var table = document.getElementById("tblPOItemstModelTable");
                var tr = table.getElementsByTagName("tr");
                for (i = 0; i < tr.length; i++) {
                    td = tr[i].getElementsByTagName("td")[7];
                    if (td) {
                        txtValue = td.textContent || td.innerText;
                        debugger;
                        temp = tr[i];
                        if (txtValue.toUpperCase().indexOf(value) > -1) {
                            tr[i].style.display = "";
                        } else {
                            tr[i].style.display = 'none';
                        }
                    }
                }
            });

            $('#btn_GetFromPO').on('click', function () {
                debugger;
                var vendorId = $("#ddl_Vendor").val();
                if (!vendorId || vendorId === "0" || vendorId === "Please Select") {
                    Swal.fire({
                        icon: 'warning',
                        title: 'Warning!',
                        text: 'Please select a vendor first!',
                        timer: 2000,
                        showConfirmButton: false
                    });
                    return;
                }
                LoadPODetailByVendor(vendorId);
            });

            

            $('#checkPOHeader').on('change', function () {
                var isChecked = $(this).is(':checked');

                $('#PO_Modal tbody tr').each(function () {
                    var rowCheckbox = $(this).find('.chkPOItem');

                    if (isChecked && !rowCheckbox.is(':checked')) {
                        rowCheckbox.prop('checked', true);
                        appendPOItem(rowCheckbox);  
                    } else if (!isChecked && rowCheckbox.is(':checked')) {
                        rowCheckbox.prop('checked', false);
                    }
                });
            });

            $(document).on('change', '.chkPOItem', function () {
                debugger;
                appendPOItem($(this));
            });
            AllowButtonsVisibility();

            $(document).on('keyup', '#searchPONo', function () {
                var value = $(this).val().toLowerCase();

                $("#PO_Modal tbody tr").each(function () {
                    var poNo = $(this).attr('data-po-no');
                    if (poNo && poNo.toLowerCase().indexOf(value) > -1) {
                        $(this).show();
                    } else {
                        $(this).hide();
                    }
                });
            });

            $('#PO_Modal').on('shown.bs.modal', function () {
                $('#searchPONo').focus();
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
        });


        function UserRights() {
            debugger;
            $.ajax({
                type: "POST",
                url: "AddPurchaseInvoice.aspx/UserEntryRights",
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
        function toggle(source) {
            debugger;
            var checkboxes = document.querySelectorAll('input[type="checkbox"]');
            for (var i = 0; i < checkboxes.length; i++) {
                debugger;
                if (checkboxes[i] != source) {
                    checkboxes[i].checked = source.checked;
                    append(checkboxes[i]);
                }
            }
        }
        function validateSave() {
            debugger;
            var proceed = true;
            var Vendor = $('#ddl_Vendor').val();
            var Invoicetype = $('#ddl_invoicetype').val();
            if (Vendor == '0') {
                $("#ddl_Vendor").addClass('ErrorAlert');
                $('#select2-ddl_Vendor-container').parent().css('border-color', 'red');
                proceed = false;
            }
            else {
                $("#ddl_Vendor").removeClass('ErrorAlert');
                $('#select2-ddl_Vendor-container').parent().css('border-color', ' rgb(206, 191, 191)');
            }
            if (Invoicetype == '0') {
                $("#ddl_invoicetype").addClass('ErrorAlert');
                $('#select2-ddl_invoicetype-container').parent().css('border-color', 'red');
                proceed = false;
            }
            else {
                $("#ddl_invoicetype").removeClass('ErrorAlert');
                $('#select2-ddl_invoicetype-container').parent().css('border-color', 'rgb(206, 191, 191)');
            }
            var tblLength = $("#tblItemDescription tr:gt(0)").length;
            if (tblLength == '0') {
                $('#tblItemDescription').addClass('ErrorAlert');
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Add items',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                proceed = false;
            } else {
                $('#tblItemDescription').removeClass('ErrorAlert');
            }
            return proceed;
        }
        function filldropdown() {
            PageMethods.GetDepartments(function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    if (value.Type == "Dept") {
                        optionsDeptfill += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                    else {
                        optionfed += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                })
            });
}
        function LoadGRNDetail(vendorId) {
            var Is_Direct = $('#dircGRN').is(':checked');
            PageMethods.getGRNDetailByVendorId(vendorId, Is_Direct, function (data) {
                debugger;
                var Test = JSON.parse(data);
                var TotalAmount = '';
                var PODate = ''
                var IgpDate = '';
                $('#tblPOItemstModelTable tbody tr').remove();
                var rows = "";
                for (var i = 0; i < Test.length; i++) {
                    debugger;
                    TotalAmount = parseInt(Test[i].GRNQty * Test[i].Rate);
                    PODate = Test[i].PO_Date ? $.datepicker.formatDate('dd M yy', new Date(parseInt(Test[i].PO_Date.substring(6, 19)))) : '';
                    IgpDate = $.datepicker.formatDate('dd M yy', new Date(parseInt(Test[i].Igp_date.substring(6, 19))));
                    rows = '<tr>' +
                        '<td><input name="chkselect" type="checkbox" class="chktd" id="chktd" name="chktd" onclick="append(this)" value="false" style=" margin-top: -2px; margin-left: 0px;height: 36px;"/></td>' +
                        '<td style="display:none">' + Test[i].GRN_ID + '</td> ' +
                        '<td style="display:none">' + Test[i].GRN_detail_Id + '</td> ' +
                        '<td style="display:none">' + Test[i].Item_ID + '</td> ' +
                        '<td>' + Test[i].Item_Code + '</td> ' +
                        '<td>' + Test[i].Description + '</td> ' +
                        '<td style="display:none">' + parseFloat(TotalAmount).toFixed() + '</td> ' +
                        '<td>' + Test[i].PO_No + '</td> ' +
                        '<td style="display:none">' + PODate + '</td> ' +
                        '<td>' + Test[i].Igp_num + '</td> ' +
                        '<td style="display:none">' + IgpDate + '</td> ' +
                        '<td>' + Test[i].GRN_Num + '</td> ' +
                        '<td style="display:none">' + parseFloat(Test[i].GRNQty).toFixed(2) + '</td> ' +
                        '<td style="display:none">' + parseFloat(Test[i].IRNQty).toFixed(2) + '</td> ' +
                        '<td>' + parseFloat(Test[i].GRNQty).toFixed(2) + '</td>' +
                        '<td>' + parseFloat(Test[i].Rate).toFixed(2) + '</td>' +
                        '<td style="display:none">' + parseFloat(TotalAmount).toFixed() + '</td>' +
                        '<td>' + parseFloat(TotalAmount).toFixed() + '</td>' +
                        '<td>' + Test[i].VendorName + '</td>' +
                        '<td>' + Test[i].InvType + '</td>' +
                        '<td style="display:none">' + Test[i].DiscPer + '</td>' +
                        '<td style="display:none">' + parseFloat(Test[i].DiscAmt).toFixed() + '</td>' +
                        '<td style="display:none">' + Test[i].Stax + '</td>' +
                        '<td style="display:none">' + parseFloat(Test[i].sTaxAmount).toFixed() + '</td>' +
                        '<td style="display:none">' + Test[i].AdvigpagainstPo + '</td>' +
                        '<td style="display:none">' + parseFloat(Test[i].AdvTaxAmount || 0).toFixed(2) + '</td>' +
                        '<td style="display:none">' + (Test[i].AdvTaxId || 0) + '</td>' +
                        '<td style="display:none">' + parseFloat(Test[i].FurtherTax_Amount || 0).toFixed(2) + '</td>' +
                        '<td style="display:none">' + (Test[i].FurtherTax_Id || 0) + '</td>' +
                        '<td style="display:none">' + parseFloat(Test[i].Bonus_Qty || 0).toFixed(2) + '</td>' + 
                        '<td style="display:none">' + parseFloat(Test[i].Bonus_Tax || 0).toFixed(2) + '</td>' + 
                        '<td style="display:none">' + (Test[i].IsBatch || false) + '</td>' +
                        '</tr>';
                    $('#tblPOItemstModelTable tbody').append(rows);
                    global = rows;
                }
                $('#POItemsModel').modal({
                    backdrop: 'static'
                });
            });
        }
        function GetNewInvoiceNo() {
            PageMethods.GetNewInvoiceNo(function (resp) {
                $('#txt_invoicenum').val(resp);
            },
                function (error) {
                    alert(error.get_message());
                })
        }
        function GetDepartments() {
            PageMethods.GetDepartments(function (Tests) {
                optionsInv = '<option value="0">Please Select</option>';
                optionsCur = '';
                $.each(JSON.parse(Tests), function (key, value) {
                    if (value.Type == "InvTyp") {
                        optionsInv += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                    else if (value.Type == "Cur") {
                        optionsCur += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                });
                $('#ddl_invoicetype').html(optionsInv);
                $('#ddl_currency').html(optionsCur);
            });
        }

        var vendorList = [];
        function FillVendors() {
            PageMethods.getVendorDDLlist(function (Tests) {
                optionsVen = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    if (value.isActive == 0) {
                        optionsVen += '<option value="' + value.VendorID + '" disabled="disabled"  >' + value.VendorName + '</option>';
                    }
                    else {
                        optionsVen += '<option value="' + value.VendorID + '" >' + value.VendorName + '</option>';
                    }
                });
                $('#ddl_Vendor').html(optionsVen);
            });
        }

        function append(anchor) {
            debugger;
            var rows = '';
            var row = $(anchor).parents('tr')[0];
            var GRNId = $($(row).find('td')[1]).text();
            var GRNDetailId = $($(row).find('td')[2]).text();
            var ItemId = $($(row).find('td')[3]).text();
            var ItemCode = $($(row).find('td')[4]).text();
            var Description = $($(row).find('td')[5]).text();
            var InvoiceAmount = $($(row).find('td')[6]).text()
            var PONum = $($(row).find('td')[7]).text();
            var PODate = $($(row).find('td')[8]).text();
            var IgpNum = $($(row).find('td')[9]).text();
            var IgpDate = $($(row).find('td')[10]).text();
            var GRNNum = $($(row).find('td')[11]).text();
            var AccQty = $($(row).find('td')[12]).text();
            var RecQty = $($(row).find('td')[13]).text();
            var Qty = $($(row).find('td')[14]).text();
            var Rate = $($(row).find('td')[15]).text();
            var AdvTotalAmount = parseFloat(Rate) * parseFloat(Qty);
            var Value = $($(row).find('td')[16]).text();
            var TotalAmount = $($(row).find('td')[17]).text();
            var DiscPer = $($(row).find('td')[20]).text();
            var DiscAmt = $($(row).find('td')[21]).text();
            var stax = $($(row).find('td')[22]).text();
            var staxAmt = $($(row).find('td')[23]).text();
            var AdvigpagainstPo = $($(row).find('td')[24]).text();
            var TotalAdvAmt = $($(row).find('td')[25]).text();
            var AdvTaxId = $($(row).find('td')[26]).text();
            var FurtherTaxAmount = $($(row).find('td')[27]).text();
            var FurtherTaxId = $($(row).find('td')[28]).text();
            var BonusQty = $($(row).find('td')[29]).text(); 
            var BonusTax = $($(row).find('td')[30]).text();
            var IsBatch = $($(row).find('td')[31]).text().trim(); 

            var batchDisabled = (IsBatch == "true" || IsBatch == "1") ? "" : "disabled";
            var batchPlaceholder = (IsBatch == "true" || IsBatch == "1") ? "Enter Batch" : "N/A";
            var batchValue = (IsBatch == "true" || IsBatch == "1") ? "" : "N/A";

            var length = $("#tblItemDescription tr:gt(0)").length;
            if (length > 0) {
                length = length + 1;
            }
            else {
                length = 1;
            }
            var test_array = $('#tblItemDescription').find('input[name=txtItemCode][value=' + ItemCode + ']');
            var test_GRN = $('#tblItemDescription').find('input[name=txtGRNNum][value=' + GRNNum + ']');
            if (test_GRN.length > 0) {
                if (test_array.length > 0) {
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

                    $('#ctl00_MainContent_txtPRNo').tokenInput("clear");
                    return false;
                }
            }
            rows += '<tr>' +
                '<td class="headcol"><input type="hidden" id="txtItemCode' + length + '" name="txtItemCode" value="' + ItemCode + '"/>' + ItemCode + '</td>' +
                '<td class="headcol_1" style="white-space:normal;">' + Description + '</td> ' +
                '<td class="headcol_2">' + parseFloat(InvoiceAmount).toFixed() + '</td> ' +
                '<td class="long">' + PONum + '</td>' +
                '<td class="long">' + PODate + '</td>' +
                '<td class="long">' + IgpNum + '</td>' +
                '<td class="long">' + IgpDate + '</td>' +
                '<td class="long"><input type="hidden" id="txtGRNNum' + length + '" name="txtGRNNum" value="' + GRNNum + '"/>' + GRNNum + '</td>' +
                '<td class="long">' + parseFloat(AccQty).toFixed(2) + '</td>' +
                '<td class="long">' + parseFloat(RecQty).toFixed(2) + '</td>' +
                '<td class="headcol2_1"><input type="hidden" id="txtQty' + length + '" name="txtQty" value="' + parseFloat(Qty).toFixed(2) + '"/>' + parseFloat(Qty).toFixed(2) + '</td>' +
                '<td class="headcol2_bonus_qty">' + parseFloat(BonusQty || 0).toFixed(2) + '<input type="hidden" name="BonusQty" value="' + parseFloat(BonusQty || 0).toFixed(2) + '" />' +
                '</td>' +
                '<td class="headcol2_2"><input type="hidden" id="txtRate' + length + '" name="txtRate" value="' + parseFloat(Rate).toFixed(2) + '"/>' + parseFloat(Rate).toFixed(2) + '</td>' +
                '<td class="headcol2_3"><input type="hidden" id="txtdiscper' + length + '" name="txtdiscper" value="' + parseFloat(DiscPer).toFixed(2) + '"/>' + parseFloat(DiscPer).toFixed(2) + '</td>' +
                '<td class="headcol2_4"><input type="hidden" id="txtdiscamt' + length + '" name="txtdiscamt" value="' + parseFloat(DiscAmt).toFixed(2) + '"/>' + parseFloat(DiscAmt).toFixed(2) + '</td>' +
                '<td class="headcol2_5" style="display:none;"><select style="width: 90px !important;margin-top:-6px;" disabled onchange="CulculateAmonut()" id="Staxddl' + length + '" name="Staxddl"><option value="0">Please Select</option>' + _gloabal + '</select>' + '</td>' +
                '<td class="headcol2_6"><input type="text" readonly="readonly" id="staxamou' + length + '" name="staxamou" value="' + parseFloat(staxAmt).toFixed(2) + '" /></td>' +
                '<td class="headcol2_9">' + parseFloat(TotalAdvAmt || 0).toFixed(2) + '</td>' +
                '<td class="headcol2_further_tax">' + parseFloat(FurtherTaxAmount || 0).toFixed(2) + '</td>' +
                '<td class="headcol2_bonus_tax">' + parseFloat(BonusTax || 0).toFixed(2) + '<input type="hidden" name="BonusTax" value="' + parseFloat(BonusTax || 0).toFixed(2) + '" />' +
                '</td>' +
                '<td class="headcol2_7">' + Value + '</td>' +
                '<td class="headcol2_8"><input type="hidden" id="txtTotalAmount' + parseFloat(TotalAmount).toFixed(2) + '" name="txtTotalAmount" value="' + parseFloat(TotalAmount).toFixed(2) + '"/>' + parseFloat(TotalAmount).toFixed(2) + '</td>' +
                '<td style="display:none"><input type="hidden" id="txtGRNId' + length + '" name="txtGRNId" value="' + GRNId + '"/></td>' +
                '<td style="display:none"><input type="hidden" id="txtGRNDetailId' + length + '" name="txtGRNDetailId" value="' + GRNDetailId + '"/></td>' +
                '<td style="display:none"><input type="hidden" id="txtItemId' + length + '" name="txtItemId" value="' + ItemId + '"/></td>' +
                '<td style="display:none"><input type="hidden" id="AdvigpagainstPo' + length + '" name="AdvigpagainstPo" value="' + AdvigpagainstPo + '"/></td>' +
                '<td style="display:none"><input type="hidden" id="AdvTaxAmount' + length + '" name="AdvTaxAmount" value="' + (TotalAdvAmt || 0) + '"/></td>' +
                '<td style="display:none"><input type="hidden" id="AdvTaxId' + length + '" name="AdvTaxId" value="' + (AdvTaxId || 0) + '"/></td>' +
                '<td style="display:none"><input type="hidden" id="AdvTotalAmount' + length + '" name="AdvTotalAmount" value="' + AdvTotalAmount.toFixed(2) + '"/></td>' +
                '<td style="display:none"><input type="hidden" id="FurtherTaxId' + length + '" name="FurtherTaxId" value="' + (FurtherTaxId || 0) + '"/></td>' +
                '<td style="display:none"><input type="hidden" id="FurtherTaxAmount' + length + '" name="FurtherTaxAmount" value="' + (FurtherTaxAmount || 0) + '"/></td>' +
                '<td class="headcol_batch">' +
                '<input type="text" id="txtBatchNum' + length + '" ' + 'name="txtBatchNum" ' + 'value="' + batchValue + '" ' + 'placeholder="' + batchPlaceholder + '" ' + batchDisabled + ' ' + 'style="width:100px;" />' +'</td>' +
                '<td class="headcol2_10 long"><a href="#" onclick="Delete(this)"><i class="glyphicon glyphicon-trash" style="font-size: 13px; margin-left: 16px; color: #f30a0a;"></i></a></td>' +
                '</tr>'
            debugger;
            $("#tblItemDescription").append(rows);
            $('#Staxddl' + length).val(stax);
            CulculateAmonut();
            length++;
        }
        function Delete(row) {
            debugger;
            $(row).closest('tr').remove();
            calculateRowData();
        }

        function calculateRowData() {
            debugger;
            var netamount = 0;
            var totalinvamount = 0;
            var total_accounting_amt = 0;
            var totaladvanceadjusted = 0;
            $.each($('#advancepaymenttable tbody tr'), function (key, value) {
                var advanceadjusted = $($(value).find('td input[name=adjusted_Amount]')[0]).val();
                if (advanceadjusted == "") {
                    advanceadjusted = 0;
                }
                debugger;
                totaladvanceadjusted += parseFloat(advanceadjusted);
            });
            $('#tot_adjusted_advance').val(totaladvanceadjusted.toFixed());
            var totalfinalinvamountcheck = $('#tot_inv_amount').val();
            var discamount = $('#disc_amount').val();
            if (discamount == '') {
                discamount = 0;
            }
            var totaladvfinaladjustedcheck = $('#tot_adjusted_advance').val();
            if (parseFloat(totalfinalinvamountcheck) < parseFloat(totaladvfinaladjustedcheck)) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Adjusted Amount Can not be greater than Invoice Amount',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                $(row).closest('tr').find('td input[name=adjusted_Amount]').val('');
                $('#tot_adjusted_advance').val(0);
                $('#net_amount').val(totalfinalinvamountcheck);
                return false;
            }
            $.each($('#tblItemDescription tbody tr'), function (key, value) {
                debugger;
                var totamount = $($(value).find('td')[21]).text();
                totalinvamount += parseFloat(totamount);
            });
            $('#tot_inv_amount').val(totalinvamount.toFixed());
            var totalfinalinvamount = $('#tot_inv_amount').val();
            var totaladvfinaladjusted = $('#tot_adjusted_advance').val();
            netamount = parseFloat(totalfinalinvamount) - parseFloat(totaladvfinaladjusted) - parseFloat(discamount) + parseFloat(total_accounting_amt);
            $('#net_amount').val(netamount.toFixed());
        }

        function LoadInvoiceData(Inv_ID) {
            debugger;
            PageMethods.LoadInvoiceHeaderDetail(Inv_ID, function (resp) {
                var data = JSON.parse(resp);

                debugger;
                var InvocieDate = $.datepicker.formatDate('dd M yy', new Date(parseInt(data.InvoiceDate.substring(6, 19))));
                var AccountingDate = $.datepicker.formatDate('dd M yy', new Date(parseInt(data.AccountingDate.substring(6, 19))));
                var DueDate = $.datepicker.formatDate('dd M yy', new Date(parseInt(data.AccountingDate.substring(6, 19))));
                var ExDate = $.datepicker.formatDate('dd M yy', new Date(parseInt(data.ExDate.substring(6, 19))));
                var option = '<option value=' + data.VendorId + '>' + data.Vendor_Name + '</option>';
                vendor_Id_Global = data.VendorId;
                setTimeout(function () {
                    $('#txt_invoicenum').val(data.InvoiceNum).trigger('change');
                    $('#ddl_invoicetype').val(data.InvoiceTypeId).trigger('change');
                    $('#ddl_Vendor').html(option);
                    $('#ddl_currency').val(data.CurrencyId).trigger('change');
                }, 1000);
                $('#txt_invoicenum').val(data.InvoiceNum);
                $('#txt_refinvoiceno').val(data.RefInvoiceNum);
                $('#txt_Stax_invoice').val(data.SalTaxInvocieNum);
                $('#txt_invoicedate').val(InvocieDate);
                $('#txt_accountingDate').val(AccountingDate);
                $('#txt_dueDate').val(DueDate);
                $('#txt_exRate').val(data.ExRate);
                $('#txt_Remarks').val(data.Remarks);
                $('#txt_exDate').val(ExDate);
                $('#tot_inv_amount').val(data.Total_Invoice_Amount);
                $('#tot_adjusted_advance').val(data.Total_Advance_Adjusted);
                $('#net_amount').val(data.Net_Amount);
                $('#disc_amount').val(data.Discount_Amount);
                debugger;
                $('#dircGRN').prop('checked', data.is_DirtGRN === true).trigger('change');
                var isDirct = data.is_DirtGRN == true
                setTimeout(function () {
                    var status = data.Status;
                    if (status == "Approved") {
                        $('#btnVoucher').show();
                    }
                    if (status == "Created") {
                        $('#btnVoucher').hide();
                    }
                    if (status == "Created" || status == "Pending") {
                        if (Inv_ID != "") {
                            CheckPIApprovalRightsAndShowButton(Inv_ID);
                        }
                    }
                }, 1000);
                debugger;
                LoadInvocieDetail(Inv_ID, isDirct)
            },
                function (error) {
                    alert(error.get_message());
                })
        }
        debugger;
          function LoadInvocieDetail(Inv_ID, isDirct) {
            debugger;
            $("#tblItemDescription tbody").empty();

              PageMethods.LoadInvocieDetail(Inv_ID, isDirct, function (resp) {
                debugger;
                var data = JSON.parse(resp);

                if (!data || data.length === 0) {
                    console.warn("No details found for this invoice.");
                    return;
                }

                var rows = '';
                var startIndex = $("#tblItemDescription tr").length;

                $.each(data, function (key, value) {
                    debugger;
                    var currentIndex = startIndex + key;

                    var PO_Date = '';
                    var Igp_date = '';

                    if (value.PO_Date && value.PO_Date.indexOf('/Date(') > -1) {
                        try {
                            PO_Date = $.datepicker.formatDate('dd M yy', new Date(parseInt(value.PO_Date.substring(6, 19))));
                        } catch (e) { PO_Date = ''; }
                    }

                    var grnNum = value.GRN_Num || '';
                    var grnQty = parseFloat(value.GRNQty || 0).toFixed(2);
                    var irnQty = parseFloat(value.IRNQty || 0).toFixed(2);
                    var igpNum = value.Igp_num || '';
                    var desc = value.Description || 'No Description';
                    var itemCode = value.Item_Code || 'N/A';
                    var poNo = value.PO_No || '-';
                    var batchNum = value.BatchNum || '';

                    var isBatch = value.IsBatch === true || value.IsBatch === "true" || value.IsBatch === 1;
                    var batchDisabled = isBatch ? "" : "disabled";
                    var batchPlaceholder = isBatch ? "Enter Batch" : "N/A";
                    var batchValue = isBatch ? (batchNum || '') : 'N/A';

                    debugger;
                    rows += '<tr>' +
                        '<td class="headcol"><input type="hidden" id="txtItemCode' + currentIndex + '" name="txtItemCode" value="' + itemCode + '"/>' + itemCode + '</td>' +
                        '<td class="headcol_1" style="white-space:normal;overflow:auto;">' + desc + '</td>' +
                        '<td class="headcol_2">' + parseFloat(value.Amount || 0).toFixed() + '</td>' +
                        '<td class="long">' + poNo + '</td>' +
                        '<td class="long">' + PO_Date + '</td>' +
                        '<td class="long">' + igpNum + '</td>' +
                        '<td class="long">' + Igp_date + '</td>' +
                        '<td class="long"><input type="hidden" id="txtGRNNum' + currentIndex + '" name="txtGRNNum" value="' + grnNum + '"/>' + grnNum + '</td>' +
                        '<td class="long">' + grnQty + '</td>' +
                        '<td class="long">' + irnQty + '</td>' +
                        '<td class="headcol2_1"><input type="hidden" id="txtQty' + currentIndex + '" name="txtQty" value="' + parseFloat(value.Qty || 0).toFixed(2) + '"/>' + parseFloat(value.Qty || 0).toFixed(2) + '</td>' +
                        '<td class="headcol2_bonus_qty">' + parseFloat(value.Bonus_Qty || 0).toFixed(2) +
                        '<input type="hidden" name="BonusQty" value="' + parseFloat(value.Bonus_Qty || 0).toFixed(2) + '" />' +
                        '</td>' +
                        '<td class="headcol2_2"><input type="hidden" id="txtRate' + currentIndex + '" name="txtRate" value="' + parseFloat(value.Rate || 0).toFixed(2) + '"/>' + parseFloat(value.Rate || 0).toFixed(2) + '</td>' +
                        '<td class="headcol2_3"><input type="hidden" id="txtdiscper' + currentIndex + '" name="txtdiscper" value="' + parseFloat(value.DiscPer || 0).toFixed(2) + '"/>' + parseFloat(value.DiscPer || 0).toFixed(2) + '</td>' +
                        '<td class="headcol2_4"><input type="hidden" id="txtdiscamt' + currentIndex + '" name="txtdiscamt" value="' + parseFloat(value.DiscAmt || 0).toFixed(2) + '"/>' + parseFloat(value.DiscAmt || 0).toFixed(2) + '</td>' +
                        '<td class="headcol2_5" style="display:none;"><select style="position: relative;top:-6px;width: 90px !important;" disabled onchange="CulculateAmonut()" id="Staxddl' + currentIndex + '" name="Staxddl"><option value="0">Please Select</option>' + _gloabal + '</select></td>' +
                        '<td class="headcol2_6"><input type="hidden" id="staxamou' + currentIndex + '" name="staxamou" value="' + (value.Stax_Amount || 0) + '"/>' + (value.Stax_Amount || 0) + '</td>' +
                        '<td class="headcol2_adv_tax">' + parseFloat(value.AdvTax_Amount || 0).toFixed(2) + '</td>' +
                        '<td class="headcol2_further_tax">' + parseFloat(value.FurtherTax_Amount || 0).toFixed(2) + '</td>' +
                        '<td class="headcol2_bonus_tax">' + parseFloat(value.Bonus_Tax || 0).toFixed(2) +
                        '<input type="hidden" name="BonusTax" value="' + parseFloat(value.Bonus_Tax || 0).toFixed(2) + '" />' +
                        '</td>' +
                        '<td class="headcol2_7">' + parseFloat((value.Qty || 0) * (value.Rate || 0)).toFixed(2) + '</td>' +
                        '<td class="headcol2_8"><input type="hidden" id="txtTotalAmount' + currentIndex + '" name="txtTotalAmount" value="' + parseFloat(value.TotalAmount || 0).toFixed() + '"/>' + parseFloat(value.TotalAmount || 0).toFixed() + '</td>' +
                        '<td style="display:none"><input type="hidden" id="txtGRNId' + currentIndex + '" name="txtGRNId" value="' + (value.GRN_ID || 0) + '"/></td>' +
                        '<td style="display:none"><input type="hidden" id="txtGRNDetailId' + currentIndex + '" name="txtGRNDetailId" value="' + (value.GRN_detail_Id || 0) + '"/></td>' +
                        '<td style="display:none"><input type="hidden" id="txtItemId' + currentIndex + '" name="txtItemId" value="' + (value.ItemId || 0) + '"/></td>' +
                        '<td style="display:none"><input type="hidden" id="AdvigpagainstPo' + currentIndex + '" name="AdvigpagainstPo" value="' + (value.Adv_Po_ID || 0) + '"/></td>' +
                        '<td style="display:none"><input type="hidden" name="AdvTaxId" value="' + (value.AdvTax_ID || 0) + '"/></td>' +
                        '<td style="display:none"><input type="hidden" name="AdvTaxAmount" value="' + (value.AdvTax_Amount || 0) + '"/></td>' +
                        '<td style="display:none"><input type="hidden" name="AdvTotalAmount" value="' + (value.AdvanceTotalAmount || 0) + '"/></td>' +
                        '<td style="display:none"><input type="hidden" name="FurtherTaxId" value="' + (value.FurtherTax_Id || 0) + '"/></td>' +
                        '<td style="display:none"><input type="hidden" name="FurtherTaxAmount" value="' + (value.FurtherTax_Amount || 0) + '"/></td>' +
                        '<td class="headcol_batch">' + '<input type="text" id="txtBatchNum' + currentIndex + '" ' + 'name="txtBatchNum" ' + 'value="' + batchValue + '" ' + 'placeholder="' + batchPlaceholder + '" ' + batchDisabled + ' ' + 'style="width:100px;" />' + '</td>' +
                        '<td class="headcol2_10 long"><a href="#" onclick="Delete(this)"><i class="glyphicon glyphicon-trash" style="font-size: 13px;  margin-left: 16px; color: #f30a0a;"></i></a></td>' +
                        '</tr>';
                });
                $("#tblItemDescription tbody").append(rows);

                $.each(data, function (key, value) {
                    var currentIndex = startIndex + key;
                    var staxId = value.Stax_ID || 0;
                    var $dropdown = $("#Staxddl" + currentIndex);

                    if ($dropdown.length > 0) {
                        $dropdown.val(staxId);
                    }
                });

                CulculateAmonut();
                $('#btnSave').val('Update');
                loadadvacedetail();
                Loadadvancepaymentdetail(Inv_ID);

            }, function (error) {
                console.error("Error loading details:", error);
                alert("Error loading invoice details: " + error.get_message());
            });
        }
        debugger;
        function CulculateAmonut() {
            debugger;
            var tbl = document.getElementById('tblItemDescription');
            for (var i = 1; i < tbl.rows.length; i++) {
                debugger;
                var qty = parseFloat($('#txtQty' + i).val() || 0);
                var rate = parseFloat($('#txtRate' + i).val() || 0);
                var discpercentage = parseFloat($('#txtdiscper' + i).val() || 0);

                var Amount = qty * rate;
                var DisAmt = (discpercentage / 100) * Amount;
                var amountwithdiscount = Amount - DisAmt;

                //var STpercent = 0;
                //if ($("#Staxddl" + i + " option:selected").text() !== "Please Select") {
                //    STpercent = parseFloat($("#Staxddl" + i + " option:selected").text() || 0);
                //}
                //var STAmount = (STpercent / 100) * amountwithdiscount;

                var cleanNumber = function (str) {
                    if (!str) return 0;
                    var cleaned = str.toString().trim().replace(/[^0-9.\-]/g, '');
                    return cleaned === '' ? 0 : parseFloat(cleaned);
                };

                var FurtherTax = cleanNumber($(tbl.rows[i]).find('td.headcol2_further_tax').text());
                var BonusTax = cleanNumber($(tbl.rows[i]).find('td.headcol2_bonus_tax').text());
                var AdvanceTax = cleanNumber($(tbl.rows[i]).find('td.headcol2_9').text()); 
                var STAmount = cleanNumber($(tbl.rows[i]).find('td.headcol2_6').text()); 

                var NetAmount = amountwithdiscount + STAmount + FurtherTax + BonusTax + AdvanceTax;

                // Update UI cells
                tbl.rows[i].cells[14].innerText = DisAmt.toFixed(2); 
                tbl.rows[i].cells[16].innerText = STAmount.toFixed(2); 
                tbl.rows[i].cells[20].innerText = amountwithdiscount.toFixed(2); 
                tbl.rows[i].cells[21].innerText = NetAmount.toFixed(2); 

                calculateadvance(tbl.rows[i]);
            }
            calculateRowData();
        }
        function SaveAllRecord() {
            if (validateSave()) {
                debugger;
                var btnSave = $('#btnSave').val();
                var InvoiceNum = $('#txt_invoicenum').val();
                var InvoiceTyp = $('#ddl_invoicetype').val();
                var VendorId = $('#ddl_Vendor').val();
                var RefInvoiceno = $('#txt_refinvoiceno').val();
                var StaxInvoice = $('#txt_Stax_invoice').val();
                var InvoiceDate = $('#txt_invoicedate').val();
                var AccountingDate = $('#txt_accountingDate').val();
                var DueDate = $('#txt_dueDate').val();
                var CurrencyId = $('#ddl_currency').val();
                var ExRate = $('#txt_exRate').val();
                var Remarks = $('#txt_Remarks').val();
                var ExDate = $('#txt_exDate').val();
                var totalinvoiceamount = $('#tot_inv_amount').val();
                var totaladvanceadjusted = $('#tot_adjusted_advance').val();
                var totalnetamount = $('#net_amount').val();
                var disc_amount = $('#disc_amount').val();
                var table = $('#tblItemDescriptionDetail');
                var table2 = $('#advancepaymenttablebody');

                var Item_list = [];
                var Item_list2 = [];
                var Is_Direct = $('#dircGRN').is(':checked');
                debugger;
                table.find('tr').each(function (key, value) {
                    debugger;
                    var AdvigpagainstPo = $(value).find('td input[name=AdvigpagainstPo]').val();
                    if (AdvigpagainstPo == "null" || AdvigpagainstPo == "" || AdvigpagainstPo == null || AdvigpagainstPo == undefined) {
                        AdvigpagainstPo = 0;
                    }
                    var totalamt = $(value).find('.headcol2_8').text();
                    var amount = $(value).find('.headcol2_7').text();
                    var staxperc = $(value).find('.headcol2_6').text();
                    var disamt = $(value).find('.headcol2_4').text();
                    var AdvTaxAmount = $(value).find('.headcol2_9').text();
                    var AdvTotalAmount = $(value).find('td input[name=AdvTotalAmount]').val() || '0';
                    debugger;
                    Item_list.push({
                        'ItemId': $(value).find('td input[name=txtItemId]').val(), 'GRNId': $(value).find('td input[name=txtGRNId]').val(), 'GRNDetailId': $(value).find('td input[name=txtGRNDetailId]').val(), 'Rate': $(value).find('td input[name=txtRate]').val(), 'Qty': $(value).find('td input[name=txtQty]').val(), 'TotalAmount': totalamt, 'staxid': $(value).find('td select[name=Staxddl]').val(), 'staxperc': staxperc, 'DiscPer': $(value).find('td input[name=txtdiscper]').val(), 'DiscAmt': disamt, 'Amount': amount, 'AdvigpagainstPo': AdvigpagainstPo, 'AdvTaxId': $(value).find('td input[name=AdvTaxId]').val() || '0',
                        'AdvTaxAmount': $(value).find('td input[name=AdvTaxAmount]').val() || '0', 'AdvTotalAmount': $(value).find('td input[name=AdvTotalAmount]').val() || '0',
                        'FurtherTax_Id': $(value).find('td input[name=FurtherTaxId]').val() || '0', 'FurtherTax_Amount': $(value).find('td input[name=FurtherTaxAmount]').val() || '0',
                        'Bonus_Qty': $(value).find('td input[name=BonusQty]').val() || '0',
                        'Bonus_Tax': $(value).find('td input[name=BonusTax]').val() || '0',
                        'PODetailId': $(value).find('td input[name = txtPODetailId]').val() || '0',
                        'POID': $(value).find('td input[name = txtPOId]').val() || '0',
                        'BatchNum': $(value).find('td input[name=txtBatchNum]').val() || '',

                    });
                });
                table2.find('tr').each(function (key, value) {
                    debugger;
                    Item_list2.push({
                        'advpaymentno': $(value).find('td select[name=ddl_advanceno] :selected').text(),
                        'advpaymentid': $(value).find('td select[name=ddl_advanceno] :selected').val(),
                        'advadjusted': $(value).find('td input[name=adjusted_Amount]').val()
                    });
                });
                var AllItemDetail = { 'disc_amount': disc_amount, 'totalnetamount': totalnetamount, 'totaladvanceadjusted': totaladvanceadjusted, 'totalinvoiceamount': totalinvoiceamount, 'InvoiceNum': InvoiceNum, 'InvoiceType': InvoiceTyp, 'VendorId': VendorId, 'RefInvoiceNum': RefInvoiceno, 'SalTaxInvoiceNum': StaxInvoice, 'InvoiceDate': InvoiceDate, 'AccountingDate': AccountingDate, 'DueDate': DueDate, 'Currency': CurrencyId, 'ExRate': ExRate, 'Remarks': Remarks, 'ExDate': ExDate, 'ItemList': Item_list, 'Itemlist2': Item_list2, 'Is_Direct': Is_Direct };
                PageMethods.SaveInvoice(btnSave, JSON.stringify(AllItemDetail), function (res) {
                    debugger;
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

                    sendFile(res);
                    $('#btnSave').val("Update");
                    window.location = "AddPurchaseInvoice.aspx?Inv_ID=" + res;
                    $('#btnSave').val("Update");
                });
            }
        }

        function UnApprove() {
            debugger;
            var InvId = '<% =Request.QueryString["Inv_ID"] %>';
            PageMethods.UnApprovePurchaseInvoice(InvId, function (Tests) {
                debugger
                var message = JSON.parse(Tests);
                if (message[0].Column1 != "" || message[0].Column1 != null) {
                    alert(message[0].Column1);
                    location.reload();
                }
            });
        }
        function UserUnApproveButtonRights() {
            debugger;
            $.ajax({
                type: "POST",
                url: "AddPurchaseInvoice.aspx/UserUnApproveEntryRights",
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
        function CheckPIApprovalRightsAndShowButton(invId) {
            callPageMethod('CheckPIApprovalRights', function (hasRights) {
                if (hasRights) {
                    callPageMethod('GetPIApprovalInfo', { InvId: invId }, function (resp) {
                        var info = JSON.parse(resp);
                        if (info.CanApprove) {
                            $('#btnApprove').show();
                            $('#btnApprove').data('pi-amount', info.Amount);
                        }
                    });
                }
            });
        }
        function ApprovePIFromEdit() {
            var invId = Inv_ID;
            var amount = $('#btnApprove').data('pi-amount');
            var confirmHtml = 'Are you sure you want to approve Purchase Invoice?';
            if (amount > 0) {
                confirmHtml += '<br><br>Invoice Amount: <strong>' + parseFloat(amount).toFixed(2) + '</strong>';
            }
            Swal.fire({
                title: 'Approve Purchase Invoice?',
                html: confirmHtml,
                icon: 'question',
                showCancelButton: true,
                confirmButtonText: 'Yes, Approve',
                cancelButtonText: 'Cancel',
                input: 'textarea',
                inputPlaceholder: 'Approval remarks (optional)...',
                customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' }
            }).then((result) => {
                if (result.isConfirmed) {
                    var remarks = result.value || '';
                    callPageMethod('ApproveSinglePI', { InvId: invId, approvalRemarks: remarks }, function (resp) {
                        if (resp === "Success") {
                            Swal.fire({ icon: 'success', title: 'Approved!', text: 'Purchase Invoice has been approved successfully.', showConfirmButton: false, timer: 2000, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } }).then(function () { location.reload(); });
                        } else {
                            Swal.fire({ icon: 'error', title: 'Error', text: resp, showConfirmButton: true, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } }).then(function () { location.reload(); });
                        }
                    });
                }
            });
        }
        function PrintPurchaseDetail() {
            var id = '<% =Request.QueryString["Inv_ID"] %>';
            var locationInfo = window.location;
            var user_name = '<% =AppConfig.Company_Name %>';
            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx'; // same folder
            }
            var url = '/ReportViewer.aspx?ReportName=PurchaseInvoiceList&ReportTitle=Purchase Invoice List&Inv_Id=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/' + reportPath +  '?ReportName=PurchaseInvoiceList&ReportTitle=Purchase Invoice List&Inv_Id=' + id;
            }
            window.open(url, '_blank');
        }
        function PrintVoucher() {
            var InvId = '<% =Request.QueryString["Inv_ID"] %>';
            var locationInfo = window.location;
            var user_name = '<% =AppConfig.Company_Name %>';
            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx'; // same folder
            }
            var url = '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=Purchase Voucher&TransID=' + InvId + '&TransType=Pur';
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/' + reportPath +  '?ReportName=Voucher&ReportTitle=Purchase Voucher&TransID=' + InvId + '&TransType=Pur';
            }
            window.open(url, '_blank');
        }
      
        function Addrow() {
            debugger;
            var rows = '';
            var rowlength = advancepaymenttablebody.rows.length;
            debugger;
            rows = '<tr>' +
                '<td><select id="ddl_advanceno' + (rowlength + 1) + '" name="ddl_advanceno" onchange="loadadvanceamountbyno(this);">' + _global_advanceno + '</select></td>' +
                '<td><input type=text id="advance_amount" name="advance_amount" readonly="readonly" /></td>' +
                '<td><input type=text id="adv_paid_amount" name="adv_paid_amount" readonly="readonly" /></td>' +
                '<td><input type=text id="adv_tax_amount" name="adv_tax_amount" readonly="readonly" /></td>' +
                '<td><input type=text id="adjusted_Amount" name="adjusted_Amount" onkeyup="calculateadvance(this)"/></td>' +
                '</td>' +
                '</tr>';
            $('#advancepaymenttablebody').append(rows);
            loadadvacedetail();
            $('select').select2();
        }
        var _global_advanceno = '';
        function loadadvacedetail() {
            debugger;
            var rowlength = advancepaymenttablebody.rows.length;
            var venid = $('#ddl_Vendor').val();
            if (venid == "0" || venid == "Please Select") {
                venid = vendor_Id_Global;
            }
            debugger;
            var optionsitem = '';
            PageMethods.loadadvancedetail(venid, function (resp) {
                optionsitem = '<option value="0">Please Select</option>';
                $.each(JSON.parse(resp), function (key, value) {
                    optionsitem += '<option value="' + value.Advance_ID + '" >' + value.Advance_No + '</option>';
                });
                $('#ddl_advanceno' + rowlength + '').html(optionsitem);
                _global_advanceno = optionsitem;
            },
                function (error) {
                    alert(error.get_message());
                });
        }

        function loadadvanceamountbyno(row, abc, rowindex) {
            debugger;
            var ID = 0;
            if (typeof abc === 'undefined') {
                ID = $(row).closest('tr').find('td select[name=ddl_advanceno] :selected').val();
            }
            else {
                ID = abc;
            }
            debugger;
            PageMethods.loadadvanceamount(ID, function (Tests) {
                debugger;
                var data = JSON.parse(Tests);
                debugger;
                $.each(data, function (key, value) {
                    if (typeof abc === 'undefined') {
                        debugger;
                        $(row).closest('tr').find('td input[name=advance_amount]').val(value.Advance_Amount);
                        $(row).closest('tr').find('td input[name=adv_tax_amount]').val(value.WithHoldTax_Amount);
                        $(row).closest('tr').find('td input[name=adv_paid_amount]').val(value.Paid_Amount);
                    }
                    else {
                        debugger;
                        $('#advance_amount' + rowindex + '').val(value.Advance_Amount);
                        $('#adv_tax_amount' + rowindex + '').val(value.WithHoldTax_Amount);
                        $('#adv_paid_amount' + rowindex + '').val(value.Paid_Amount);
                    }
                    debugger;
                });
            });
        }
        function calculateadvance(row) {
            debugger;
            var netamount = 0;
            var totalinvamount = 0;
            var total_accounting_amt = 0;
            var totaladvanceadjusted = 0;
            var actualamount = $(row).closest('tr').find('td input[name=advance_amount]').val();
            var adjustedadv = $(row).closest('tr').find('td input[name=adjusted_Amount]').val();
            if (adjustedadv == "") {
                adjustedadv = 0;
            }
            if (parseFloat(actualamount) < parseFloat(adjustedadv)) {
                alert('Adjusted Amount Can not be greater than Advance Amount');
                $(row).closest('tr').find('td input[name=adjusted_Amount]').val('');
                $('#tot_adjusted_advance').val(0);
                var totalfinalinvamountcheck1 = $('#tot_inv_amount').val();
                $('#net_amount').val(totalfinalinvamountcheck1);
                return false;
            }
            $.each($('#advancepaymenttable tbody tr'), function (key, value) {
                var advanceadjusted = $($(value).find('td input[name=adjusted_Amount]')[0]).val();
                if (advanceadjusted == "") {
                    advanceadjusted = 0;
                }
                debugger;
                totaladvanceadjusted += parseFloat(advanceadjusted);
            });
            $('#tot_adjusted_advance').val(totaladvanceadjusted.toFixed());
            var totalfinalinvamountcheck = $('#tot_inv_amount').val();
            var discamount = $('#disc_amount').val();
            if (discamount == '') {
                discamount = 0;
            }
            var totaladvfinaladjustedcheck = $('#tot_adjusted_advance').val();
            if (parseFloat(totalfinalinvamountcheck) < parseFloat(totaladvfinaladjustedcheck)) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Adjusted Amount Can not be greater than Invoice Amount',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                $(row).closest('tr').find('td input[name=adjusted_Amount]').val('');
                $('#tot_adjusted_advance').val(0);
                $('#net_amount').val(totalfinalinvamountcheck);
                return false;
            }
            $.each($('#tblItemDescription tbody tr'), function (key, value) {
                debugger;
                var totamount = $($(value).find('td')[21]).text();
                totalinvamount += parseFloat(totamount);
            });
            $('#tot_inv_amount').val(totalinvamount.toFixed());
            var totalfinalinvamount = $('#tot_inv_amount').val();
            var totaladvfinaladjusted = $('#tot_adjusted_advance').val();
            netamount = parseFloat(totalfinalinvamount) - parseFloat(totaladvfinaladjusted) - parseFloat(discamount) + parseFloat(total_accounting_amt);
            $('#net_amount').val(netamount.toFixed());
        }
        function Loadadvancepaymentdetail(Inv_ID) {
            PageMethods.Loadadvancepaymentdetail(Inv_ID, function (resp) {
                debugger;
                var data = (JSON.parse(resp));
                var rows = '';
                selectedOptions = data;
                $.each(data, function (key, value) {
                    debugger;
                    rows += '<tr>' +
                        '<td><select id="ddl_advanceno' + (key + 1) + '" name="ddl_advanceno" onchange="loadadvanceamountbyno(this)">' + _global_advanceno + '</select></td>' +
                        '<td><input type=text id="advance_amount' + (key + 1) + '" name="advance_amount" readonly="readonly" /></td>' +
                        '<td><input type=text id="adv_paid_amount' + (key + 1) + '" name="adv_paid_amount" readonly="readonly" /></td>' +
                        '<td><input type=text id="adv_tax_amount' + (key + 1) + '" name="adv_tax_amount" readonly="readonly" /></td>' +
                        '<td><input type=text id="adjusted_Amount' + (key + 1) + '" name="adjusted_Amount" value="' + value.Advance_Adjusted + '" onkeyup="calculateadvance(this)"/></td>' +
                        '</td>' +
                        '</tr>'
                });
                debugger;
                $("#advancepaymenttablebody").append(rows);
                setTimeout(function () {
                    $.each(selectedOptions, function (key, value) {
                        debugger;
                        $("#ddl_advanceno" + (key + 1)).val(value.AdvancePayment_ID);
                        loadadvanceamountbyno(this, value.AdvancePayment_ID, (key + 1));
                    });
                }, 2000)
            },
                function (error) {
                    alert(error.get_message());
                })
        }

        function sendFile(ID) {
            debugger;
            var fileInput = $('#txt_attachments')[0];
            if (fileInput.files.length > 0) {
                debugger;
                var data = new FormData();
                data.append('file', $('#txt_attachments')[0].files[0]);
                data.append('ID', ID);
                $.ajax({
                    type: 'post',
                    url: '../../UploadPIFiles.ashx',
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

   

        function formatDateFromJSON(jsonDate) {
            if (!jsonDate) return '';
            try {
                var date = new Date(parseInt(jsonDate.substring(6, 19)));
                return $.datepicker.formatDate('dd M yy', date);
            } catch (e) { return ''; }
        }
        function LoadPODetailByVendor(vendorId) {
            debugger;
            $.ajax({
                type: "POST",
                url: "AddPurchaseInvoice.aspx/getPODetailByVendorId",
                data: JSON.stringify({ vendorId: vendorId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var poData = JSON.parse(response.d);
                    var html = '';

                    poData.forEach(function (item, index) {
                        var poNo = item.PO_No || '';
                        html += `<tr data-po-no="${poNo}">
                <td><input type="checkbox" class="chkPOItem" /></td>
                <td>${poNo}</td>
                <td>${item.Description}</td>
                <td>${item.Qty}</td>
                <td>${item.Bonus_qty}</td>
                <td>${item.bonus_tax}</td>
                <td>${item.sale_tax_amt}</td>
                <td>${item.further_tax}</td>
                <td>${item.discount_per}</td>
                <td>${item.Rate}</td>
                <td>${item.TotalAmountc}</td>
                <td style="display:none">${item.PO_ID}</td>
                <td style="display:none">${item.PO_Detail_ID}</td>
                <td style="display:none">${item.Item_Code}</td>
                <td style="display:none">${item.Vendor_Name}</td>
                <td style="display:none">${item.PO_Date}</td>
                <td style="display:none">${item.Sales_Tax}</td>
                <td style="display:none">${item.discount_amount}</td>
                <td style="display:none">${item.advancetax}</td>
                <td style="display:none">${item.advancetaxid}</td>
                <td style="display:none">${item.further_taxid}</td>
                <td style="display:none">${item.IsBatch || 0}</td>
                </tr>`;
                    });

                    $('#PO_Modal tbody').html(html);
                    $('#searchPONo').val('');
                    $('#PO_Modal tbody tr').show();

                    $('#PO_Modal').modal('show');
                },
                error: function (err) {
                    console.error("Error fetching PO details:", err);
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Failed to load PO details.',
                        timer: 2000,
                        showConfirmButton: false
                    });
                }
            });
        }
        function appendPOItem(anchor) {
            debugger;

            var row = $(anchor).closest('tr');

            var POId = $(row).find('td:eq(11)').text().trim();
            var PODetailId = $(row).find('td:eq(12)').text().trim();
            var ItemCode = $(row).find('td:eq(13)').text().trim();
            var PONum = $(row).find('td:eq(1)').text().trim();
            var Description = $(row).find('td:eq(2)').text().trim();
            var Qty = $(row).find('td:eq(3)').text().trim();
            var Bonus_qty = $(row).find('td:eq(4)').text().trim();
            var bonus_tax = $(row).find('td:eq(5)').text().trim();
            var sale_tax_amt = $(row).find('td:eq(6)').text().trim();
            var further_tax = $(row).find('td:eq(7)').text().trim();
            var discount_percentage = $(row).find('td:eq(8)').text().trim();

            var Rate = $(row).find('td:eq(9)').text().trim();
            var TotalAmount = $(row).find('td:eq(10)').text().trim();
            var VendorName = $(row).find('td:eq(14)').text().trim();
            var PODateRaw = $(row).find('td:eq(15)').text().trim();
            var Saletaxid = $(row).find('td:eq(16)').text().trim();
            var Discount_amount = $(row).find('td:eq(17)').text().trim();
            var Advance_tax = $(row).find('td:eq(18)').text().trim();
            var Advance_taxid = $(row).find('td:eq(19)').text().trim();
            var furthertaxid = $(row).find('td:eq(20)').text().trim();
            var IsBatch = $(row).find('td:eq(21)').text().trim();

            var isChecked = $(anchor).is(':checked');

            if (!isChecked) {
                $('#tblItemDescription tbody tr').each(function () {
                    if ($(this).find('input[name=txtItemCode]').val() === ItemCode) {
                        $(this).remove();
                    }
                });
                return false;
            }

            var PODate = '';
            if (PODateRaw && PODateRaw.indexOf('/Date(') > -1) {
                PODate = $.datepicker.formatDate('dd M yy', new Date(parseInt(PODateRaw.substring(6, 19))));
            } else if (PODateRaw) {
                PODate = PODateRaw;
            }

            var exists = $('#tblItemDescription').find('input[name=txtItemCode][value="' + ItemCode + '"]').length > 0;
            if (exists) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Item already added!',
                    timer: 2000,
                    showConfirmButton: false
                });
                $(anchor).prop('checked', false);
                return false;
            }

            if (!$(anchor).is(':checked')) {
                return false;
            }

            var length = $("#tblItemDescription tr:gt(0)").length + 1;
            var batchDisabled = (IsBatch == "true") ? "" : "disabled";
            var batchPlaceholder = (IsBatch == "true") ? "Enter Batch" : "N/A";
            var batchValue = (IsBatch == "true") ? "" : "N/A";

            var newRow = '<tr>' +
                '<td class="headcol"><input type="hidden" id="txtItemCode' + length + '" name="txtItemCode" value="' + ItemCode + '"/>' + ItemCode + '</td>' +
                '<td class="headcol_1" style="white-space:normal;">' + Description + '</td>' +
                '<td class="headcol_2">' + parseFloat(TotalAmount).toFixed(2) + '</td>' +
                '<td class="long">' + PONum + '</td>' +
                '<td class="long">' + PODate + '</td>' +
                '<td class="long"></td>' +
                '<td class="long"></td>' +
                '<td class="long"><input type="hidden" id="txtGRNNum' + length + '" name="txtGRNNum" value=""/></td>' +
                '<td class="long">0.00</td>' +
                '<td class="long">0.00</td>' +
                '<td class="headcol2_1">' +
                '<input type="hidden" id="txtQty' + length + '" name="txtQty" value="' + parseFloat(Qty).toFixed(2) + '"/>' +
                '<input type="text" style="width:80px;" value="' + parseFloat(Qty).toFixed(2) + '" onchange="updateHiddenQty(this, ' + length + '); CulculateAmonut();" />' +
                '</td>' +
                '<td class="headcol2_bonus_qty"> ' + parseFloat(Bonus_qty).toFixed(2) + '<input type="hidden" name="BonusQty" value="' + parseFloat(Bonus_qty).toFixed(2) + '"/></td>' +
                '<td class="headcol2_2"><input type="hidden" id="txtRate' + length + '" name="txtRate" value="' + parseFloat(Rate).toFixed(2) + '"/>' + parseFloat(Rate).toFixed(2) + '</td>' +
                '<td class="headcol2_3"> ' + parseFloat(discount_percentage).toFixed(2) +
                '<input type="hidden" id="txtdiscper' + length + '" name="txtdiscper" value="' + parseFloat(discount_percentage).toFixed(2) + '"/></td>' +
                '<td class="headcol2_4">' + Discount_amount + '<input type="hidden" id="txtdiscamt' + length + '" name="txtdiscamt"   value="' + parseFloat(Discount_amount).toFixed(2) + '" /></td>' +
                '<td class="headcol2_5" style ="display:none;"><select style="width:90px!important;margin-top:-6px;" disabled onchange="CulculateAmonut()" id="Staxddl' + length + '" name="Staxddl"><option value="0">Please Select</option>' + _gloabal + '</select></td>' +
                '<td class="headcol2_6"><input type="hidden" id="staxamou' + length + '" name="staxamou" value="' + parseFloat(sale_tax_amt).toFixed(2) + '"/>' + parseFloat(sale_tax_amt).toFixed(2) + '</td>' +

                '<td class="headcol2_9">' + Advance_tax + '</td>' +
                '<td class="headcol2_further_tax">' + further_tax + '</td>' +
                '<td class="headcol2_bonus_tax">' + bonus_tax + '<input type="hidden" name="BonusTax" value="' + parseFloat(bonus_tax).toFixed(2) + '"/></td>' +
                '<td class="headcol2_7">' + parseFloat(Qty * Rate).toFixed(2) + '</td>' +
                '<td class="headcol2_8"><input type="hidden" id="txtTotalAmount' + length + '" name="txtTotalAmount" value="' + parseFloat(TotalAmount).toFixed(2) + '"/>' + parseFloat(TotalAmount).toFixed(2) + '</td>' +
                '<td style="display:none"><input type="hidden" id="txtPOId' + length + '" name="txtPOId" value="' + POId + '"/></td>' +
                '<td style="display:none"><input type="hidden" id="txtPODetailId' + length + '" name="txtPODetailId" value="' + PODetailId + '"/></td>' +
                '<td style="display:none"><input type="hidden" id="txtItemId' + length + '" name="txtItemId" value="' + ItemCode + '"/></td>' +
                '<td style="display:none"><input type="hidden" id="AdvigpagainstPo' + length + '" name="AdvigpagainstPo" value="0"/></td>' +
                '<td style="display:none"><input type="hidden" id="AdvTaxAmount' + length + '" name="AdvTaxAmount" value="' + parseFloat(Advance_tax).toFixed(2) + '"/></td>' +
                '<td style="display:none"><input type="hidden" id="AdvTaxId' + length + '" name="AdvTaxId"  value="' + Advance_taxid + '"/></td>' +

                '<td style="display:none"><input type="hidden" id="AdvTotalAmount' + length + '" name="AdvTotalAmount" value="0"/></td>' +
                '<td style="display:none"><input type="hidden" id="FurtherTaxId' + length + '" name="FurtherTaxId" value="' + furthertaxid + '"/></td>' +
                '<td style="display:none"><input type="hidden" id="FurtherTaxAmount' + length + '" name="FurtherTaxAmount" value="' + parseFloat(further_tax).toFixed(2) + '"/></td>' +
                '<td class="headcol_batch"><input type="text" id="txtBatchNum' + length + '" name="txtBatchNum" value="' + batchValue + '" placeholder="' + batchPlaceholder + '" ' + batchDisabled + ' style="width:100px;" /></td>' +
                '<td class="headcol2_10 long"><a href="#" onclick="Delete(this)"><i class="glyphicon glyphicon-trash" style="font-size:13px;margin-left:16px;color:#f30a0a;"></i></a></td>' +
                '</tr>';

            $('#tblItemDescription tbody').append(newRow);
            $('#Staxddl' + length).select2();
            CulculateAmonut();
        }

        function updateHiddenQty(visibleInput, index) {
            $('#txtQty' + index).val($(visibleInput).val());
        }

        function AllowButtonsVisibility() {
            $.ajax({
                type: "POST",
                url: "AddPurchaseInvoice.aspx/GetPOType",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {

                    var code = res.d;

                    if (code === "01") {
                        $("#btn_GetFromPO").show();
                        $("#btn_GRN").hide();
                    }
                    else {
                        $("#btn_GRN").show();
                        $("#btn_GetFromPO").hide();
                    }
                }
            });
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <form id="item">
        <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label id="lb_invoiceId">Invoice #</label>
                <input class="form-control" type="text" name="txt_invoicenum" id="txt_invoicenum" readonly="readonly" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label id="lb_invoicetype">Invoice Type <span style="color: red;">*</span></label>
                <select id="ddl_invoicetype" class="form-control">
                    <option>Please Select</option>
                </select>
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label id="lb_invoicedate" style="">Invoice Date</label>
                <input class="form-control" type="text" name="txt_invoicedate" id="txt_invoicedate" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label id="lbl_accountingDate">Accounting Date</label>
                <input class="form-control" type="text" name="txt_accountingDate" id="txt_accountingDate" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label id="lb_duedate">Due Date</label>
                <input class="form-control" type="text" id="txt_dueDate" name="txt_dueDate" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label id="lb_invoiceno">Ref Invoice #</label>
                <input class="form-control" type="text" name="txt_refinvoiceno" id="txt_refinvoiceno" />
            </div>

        </div>
        <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label id="lb_Stax_invoice">S Tax inv #</label>
                <input class="form-control" type="text" name="txt_Stax_invoice" id="txt_Stax_invoice" />
            </div>
            <div class="col-lg-2 col-md-6 col-sm-10">
                <label id="lb_Vendor">Vendor <span style="color: red;">*</span></label>
                <select id="ddl_Vendor">
                    <option>Please Select</option>
                </select>
            </div>
            <div class="col-lg-1 col-md-4 col-sm-6">
                <input class="btn btn-primry" type="button" value="GRN" id="btn_GRN" style="margin-top: 26px;display:none" />
            </div>
            <div class="col-lg-1 col-md-4 col-sm-6">
                <input class="btn btn-primry" type="button" value="Get from PO" id="btn_GetFromPO" style="margin-top: 26px;display:none;" />
            </div>

            <div class="col-lg-2 col-md-4 col-sm-6">
                <label id="lb_currency">Currency</label>
                <select id="ddl_currency" class="form-control">
                    <option></option>
                    <option>Currency</option>
                </select>
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label id="lb_exRate">Ex Rate</label>
                <input type="text" name="txt_exRate" id="txt_exRate" class="form-control" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label id="lb_exDate">Ex Date</label>
                <input type="text" name="txt_exDate" id="txt_exDate" class="form-control" />
            </div>
        </div>
        <div class="row">
            <div class="col-lg-4 col-md-3 col-sm-4">
                <label id="lb_remarks">Remarks</label>
                <input type="text" name="txt_Remarks" id="txt_Remarks"  />
            </div>
            
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label id="lb_attachments">Attachments</label>
                <input type="file" name="txt_attachments" id="txt_attachments" />
                <asp:HyperLink ID="HyperLink1" runat="server">Download</asp:HyperLink>
            </div>
                         <div class="col-lg-1 col-md-6 col-sm-12" name="directgrn">
                     <label class="source-radio-option">
                    Direct GRN
                </label>
                <input type="checkbox" name="dircGRN" id="dircGRN" value="item" />
            </div>
        </div>

        <div class="modal fade" id="PO_Modal" tabindex="-1" role="dialog" aria-labelledby="PO_ModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <div class="input-group" style="width: 40%;">
                            <input type="text" id="searchPONo" class="form-control" placeholder="Search by PO No..." />
                        </div>
                        <h5 class="modal-title" id="PO_ModalLabel">PO Details</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <table class="table table-bordered">
                            <thead>
                                <tr>
                                    <th>
                                        <input type="checkbox" id="checkPOHeader" /></th>
                                    <th>PO No</th>
                                    <th>Description</th>
                                    <th>Qty</th>
                                    <th>Bonus_qty</th>
                                    <th>bonus_tax</th>
                                    <th>sale_tax_amt</th>
                                    <th>further_tax</th>
                                    <th>discount_per</th>
                                  
                                    <th>Rate</th>
                                    <th>Total Amount</th>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>
                    <div class="modal-footer">
                        <div class="col-lg-10 col-md-10 col-sm-10"></div>
                         <div class="col-lg-2 col-md-2 col-sm-2 float-end">
                        <input type="button" value="Close" class="btn-gray" data-dismiss="modal" />
                             </div>
                    </div>
                </div>
            </div>
        </div>

    </form>
    <br />
    <div class="row">
        <div class="col-md-6">
        </div>
    </div>
    <br />

    <div id="tabs">
        <ul>
            <li><a href="#Tab-1">Payable Invoice</a></li>
            <li><a href="#Tab-2">Advance</a></li>
        </ul>

        <div id="Tab-1">
            <div id="divdiv">
                <div>
                    <div class="row">
                        <div class="table-responsive">
                            <table style="width: 100%" class="table table-responsive table-hover table-bordered" id="tblItemDescription">
                                <thead>
                                    <tr>
                                        <th>Item Code</th>
                                        <th>Description</th>
                                        <th>Invoice Amnt</th>
                                        <th>PO No</th>
                                        <th>PO Date</th>
                                        <th>IGP #</th>
                                        <th>IGP Date</th>
                                        <th>GRN #</th>
                                        <th>GRN Qty</th>
                                        <th>IRN Qty</th>
                                        <th>Qty</th>
                                        <th>Bonus Qty</th>
                                        <th>Rate</th>
                                        <th>Disc%</th>
                                        <th>Disc Amnt</th>
                                        <%--<th>S.Tax%</th>--%>
                                        <th>S.Tax Amnt</th>
                                        <th>Total Advance</th>
                                        <th>Further Tax</th>
                                        <th>Bonus Tax</th>
                                        <th>Value</th>
                                        <th>Total Amnt</th>
                                        <th>Batch Num</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody id="tblItemDescriptionDetail">
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

            </div>
        </div>

        <div id="Tab-2">
            <div class="row">
                <div class="col-lg-1 col-md-4 col-sm-12">
                    <input type="button" class="btn btn-primry" onclick="Addrow()" value="+" id="AddAccount" />
                </div>
            </div>
            <div>
                <div class="row">
                    <div class="table-responsive">
                        <table class="table table-bordered" id="advancepaymenttable">
                            <thead>
                                <tr>
                                    <th>Advance Num</th>
                                    <th>Advance Amount</th>
                                    <th>Paid Amount</th>
                                    <th>WithHold Amount</th>
                                    <th>Adjusted Amount</th>
                                </tr>
                            </thead>
                            <tbody id="advancepaymenttablebody">
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-lg-6 col-md-9 col-sm-10" style="margin-top:1%">
            <div class="row">
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" id="btnSave" class="btn btn-primry" value="Save" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" class="btn btn-yellow" value="New" onclick="window.location = 'AddPurchaseInvoice.aspx'" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" class="btn-gray" value="List" onclick="window.location = 'PurchaseInvoiceView.aspx'" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" value="Print" class="btn btn-primry" id="btn_Print" onclick="PrintPurchaseDetail();" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" class="btn btn-primry" value="Voucher" id="btnVoucher" onclick="PrintVoucher()" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" style="height: 32px !important; width: 102px; display: none" value="Approve" id="btnApprove" onclick="ApprovePIFromEdit()" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    
                    <input type="button" style="height: 32px !important; width: 102px; display: none" value="UnApprove" id="btnUnApprove" onclick="UnApprove()" />
                </div>
            </div>
        </div>
        <div class="col-lg-4 col-md-3 col-sm-3"></div>

        <div class="col-lg-2 col-md-3 col-sm-3">
            <div style="float: right;">
                <label id="lbl_tot_inv_amount">Total Invoice Amount</label>
                <input type="text" id="tot_inv_amount" name="tot_inv_amount" readonly="readonly" />
                <label id="lbl_disc_amount">Additional Discount</label>
                <input type="text" id="disc_amount" name="disc_amount" onkeyup="CulculateAmonut()" />
                <label id="lbl_tot_adjusted_advance">Advance Adjusted</label>
                <input type="text" id="tot_adjusted_advance" name="tot_adjusted_advance" readonly="readonly" />
                <label id="lbl_net_amount">Net Amount</label>
                <input type="text" id="net_amount" name="net_amount" readonly="readonly" />
            </div>
        </div>
    </div>
    <div id="POItemsModel" class="modal fade" role="dialog">
        <div class="modal-dialog">
            <div class="modal-content" style="width: 1000px; margin-left: -270px; height: 505px;">
                <div class="modal-header">
                    <button type="button" style="width: auto; margin-top: -15px" class="close" data-dismiss="modal">&times;</button>
                    <h4 style="margin-right: 620px; margin-left: 17px" class="modal-title">Add GRN Items </h4>
                    <input type="text" id="PoNum" name="PoNum" style="width:30% !important" placeholder="PO #" />
                </div>
                <input type="hidden" id="txthiddentr" name="txthidddentr" />
                <div style="width: 970px; overflow: scroll; height: 401px  !important; height: auto;">
                    <table class="table" style="width: 953px; height: 0px !important; height: auto; overflow: scroll;" id="tblPOItemstModelTable">
                        <thead>
                            <tr>
                                <th class="table_heading_color" style="width: 40px !important;">
                                    <input type="checkbox" id="checkHeader" value="false" /></th>
                                <th class="table_heading_color" style="display: none">GRN Id</th>
                                <th class="table_heading_color" style="display: none">GRN Detail Id</th>
                                <th class="table_heading_color" style="display: none">Item Id</th>
                                <th class="table_heading_color" style="width: 100px !important;">Account Item Code</th>
                                <th class="table_heading_color">Description</th>
                                <th class="table_heading_color" style="display: none">Invoice Amount</th>
                                <th class="table_heading_color">PO No</th>
                                <th class="table_heading_color" style="display: none">PO Date</th>
                                <th class="table_heading_color" style="display: none">IGP #</th>
                                <th class="table_heading_color" style="display: none">PO Date</th>
                                <th class="table_heading_color">IGP #</th>
                                <th class="table_heading_color" style="display: none">IGP Date</th>
                                <th class="table_heading_color">GRN #</th>
                                <th class="table_heading_color" style="display: none">Accepted Qty</th>
                                <th class="table_heading_color" style="display: none">Received Qty</th>
                                <th class="table_heading_color">Qty</th>
                                <th class="table_heading_color">Rate</th>
                                <th class="table_heading_color" style="display: none">Value</th>
                                <th class="table_heading_color">Total Amount</th>
                                <th class="table_heading_color">Vendor Name</th>
                                <th class="table_heading_color">InvType</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
                <div class="modal-footer">
                    <input type="button" id="PoItem" name="PoItem" value="Done" class="btn-gray" data-dismiss="modal" style="width:20%!important" />
                </div>
            </div>
        </div>
    </div>



</asp:Content>
