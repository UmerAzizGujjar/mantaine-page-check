<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AddPaymentInvoice.aspx.cs" Inherits="PMS.Inventory.AddPaymentInvoice" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/payment-invoice.css?v=20261014" rel="stylesheet" />

        <script type="text/javascript">
            var InvType = '';
            var bankAccountsCache = [];
            var savedBranch = null;

            function loadUserBranch() {
                PageMethods.GetUserBranch(function (result) {
                    if (!result || result === "null") {
                        $('#ddlBranch').empty().append('<option value="0">No Branch Assigned</option>');
                        return;
                    }
                    var branches = JSON.parse(result);
                    $('#ddlBranch').empty();
                    branches.forEach(function (branch) {
                        $('#ddlBranch').append('<option value="' + branch.branch_ID + '">' + branch.branch_Name + '</option>');
                    });
                    if (branches.length === 1) {
                        $('#ddlBranch').val(branches[0].branch_ID);
                    } else {
                        $('#ddlBranch').prepend('<option value="0">Please Select</option>').val('0');
                    }
                    if (savedBranch) {
                        $('#ddlBranch').val(savedBranch).trigger('change');
                    }
                });
            }
            $(document).ready(function () {
                UserRights();
                $('#ddl_PaymentMode').select2();
                $('#ddl_venderName').select2();
                $('#ddl_bankCash').select2();
                $('#ddlBranch').select2();
                loadUserBranch();
                $('#btnSave').click(function () {
                    SaveAllRecord();
                });
                $('#btnVoucher').hide();
                $('#btn_Print').hide();
                var checkedit = '<%= Request.QueryString["Inv_ID"]%>'
            if (checkedit == '') {
                GetNewPaymentInvoiceNo();
            }

            setTimeout(function () {
                Fillwtaxtype();
            }, 3000);
            setTimeout(function () {
                FillStaxtype();
            }, 2500);
            var currentDate = new Date();
            var formattedDate = $.datepicker.formatDate('dd M yy', currentDate);

            var $datepicker = $('#txt_paymentDate');

            $datepicker.datepicker({
                changeMonth: true,
                changeYear: true,
                yearRange: "-50:+50",
                dateFormat: "dd M yy"
            });

            var currentDate = $.datepicker.formatDate("dd M yy", new Date());
            $datepicker.val(currentDate);

            var $datepicker = $('#txt_DocumentDate');

            $datepicker.datepicker({
                changeMonth: true,
                changeYear: true,
                yearRange: "-50:+50",
                dateFormat: "dd M yy"
            });

            var currentDate = $.datepicker.formatDate("dd M yy", new Date());
            $datepicker.val(currentDate);

            FillVendors();
            GetPaymentMode();
            FillBank();
            <% if (Request.QueryString["Inv_ID"] != null)
        { %>
            var Inv_ID = '<%= Request.QueryString["Inv_ID"]%>'
            LoadPaymentInvoiceHeader(Inv_ID);
            <% } %>
            $('[id*=checkHeader]').click(function () {
                var isTrue = $('#checkHeader').is(':checked');
                if (isTrue) {
                    $('.chktd').prop('checked', true);
                    setTimeout(function () {
                        $("#tblPOItemstModelTable tr:gt(0) input[type=checkbox]:checked ").each(function (key, value) {
                            var row = $(this);
                            append(row);
                        });
                    }, 1000);
                }
                else {
                    $('.chktd').prop('checked', false);
                }
            });
            $('#btn_ManInv').on('click', function () {
                var vendorId = $("#ddl_venderName").val();
                GetManualInvoiceDetailAndGetPurchaseInvoiceNDetailByVendorId(vendorId);
                $('#ctl00_MainContent_txtRemarks').focus();
            });
            var Inv_ID = '<%= Request.QueryString["Inv_ID"]%>'

            $("input[name='rbtnAccType']").change(function () {
                filterBankAccounts($(this).val());
            });
                $('#ddl_bankCash').on('change', function () {
                var sel = $(this).find('option:selected');
                var accType = sel.data('acc-type');
                if (accType === 'cash') { $('#rbtnAccCash').prop('checked', true).trigger('change'); }
                else if (accType === 'bank') { $('#rbtnAccBank').prop('checked', true).trigger('change'); }
            });

            syncPaymentBadges();
            setInterval(syncPaymentBadges, 1000);
        });
        function Fillwtaxtype() {
            var options = '';
            PageMethods.getwtaxtype(function (Tests) {
                options = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    options += '<option value="' + value.WithHold_Tax_ID + '" >' + value.WithHold_Tax_Perc + '</option>';
                });
                $('.ddlWTaxType').html(options);
            });
        }

        function FillStaxtype() {
            var options = '';
            PageMethods.getStaxtype(function (Tests) {
                options = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    options += '<option value="' + value.Sales_Tax_ID + '" >' + value.Sales_Tax_Perc + '</option>';
                });
                $('.ddlSalTax').html(options);
            });
        }

        function callPageMethod(methodName, params, successCallback, errorCallback) {
            if (typeof params === 'function') {
                errorCallback = successCallback;
                successCallback = params;
                params = {};
            }
            $.ajax({
                type: "POST",
                url: "AddPaymentInvoice.aspx/" + methodName,
                data: JSON.stringify(params || {}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (typeof successCallback === 'function') successCallback(response.d);
                },
                error: function (xhr, status, error) {
                    console.error('Error calling ' + methodName + ':', xhr.status, error);
                    if (typeof errorCallback === 'function') errorCallback(error);
                }
            });
        }
        function UserRights() {
            $.ajax({
                type: "POST",
                url: "AddPaymentInvoice.aspx/UserEntryRights",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var hasRights = response.d;
                    if (hasRights) {
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
        function LoadPurchaseInvoiceNDetail(vendorId) {
            PageMethods.getPurchaseInvoiceNDetailByVendorId(vendorId, function (data) {
                var Test = JSON.parse(data);
                $('#tblPOItemstModelTable tbody tr').remove();
                var rows = "";
                for (var i = 0; i < Test.length; i++) {
                    rows = '<tr>' +
                        '<td><input class="chktd" id="chktd" name="chktd" type="checkbox" style=" margin-top: -2px; margin-left: 0px;height: 36px;" onclick="append(this)"/></td>' +
                        '<td style="display:none">' + Test[i].PurchaseInvoiceId + '</td> ' +
                        '<td>' + Test[i].InvoiceNum + '</td> ' +
                        '<td>' + Test[i].TotalAmount + '</td> ' +
                        '<td>' + Test[i].Advance_Recieved_Amount + '</td> ' +
                        '<td>' + Test[i].Paid_Amount + '</td> ' +                        
                        '<td>' + Test[i].Balance + '</td> ' +                        
                        '<td>' + InvType + '</td>' +
                        '<td>' + Test[i].SalTax + '</td> ' +
                        '<td>' + Test[i].SalTax_Amt + '</td> ' +
                        '<td style="display:none"></td> ' +
                        '<td style="display:none"></td> ' +
                        '<td style="display:none">' + Test[i].TotalAmount + '</td>' +
                        '</tr>';
                    $('#tblPOItemstModelTable tbody').append(rows);
                }
                $('#POItemsModel').modal({
                    backdrop: 'static'
                });
            });
        }
        function ExcludeFromPayment(anchor) {
            var a = confirm("Are you sure You want to delete");
            if (a == true) {
                console.clear();
                var row = $(anchor).parents('tr')[0];
                row.remove();
            }
        }
        function GetManualInvoiceDetailAndGetPurchaseInvoiceNDetailByVendorId(vendorId) {
            PageMethods.GetManualInvoiceDetailAndGetPurchaseInvoiceNDetailByVendorId(vendorId, function (data) {
                var Test = JSON.parse(data);
                $('#tblPOItemstModelTable tbody tr').remove();
                var rows = "";
                for (var i = 0; i < Test.length; i++) {
                    InvType = Test[i].Type;
                    if (InvType == 'Purchase') {
                        InvType = 'PUR';
                    }
                    else {
                        InvType = 'MINV';
                    }
                    rows = '<tr>' +
                        '<td><input class="chktd" id="chktd" name="chktd" type="checkbox" style=" margin-top: -2px; margin-left: 0px;height: 36px;" onclick="append(this)"/></td>' +
                        '<td style="display:none">' + Test[i].ManualInvoiceId + '</td> ' +
                        '<td>' + Test[i].ManualInvoiceNum + '</td> ' +
                        '<td>' + Test[i].TotalAmount + '</td> ' +
                        '<td>' + Test[i].Advance_Recieved_Amount + '</td> ' +
                        '<td>' + Test[i].Paid_Amount + '</td> ' +                       
                        '<td>' + Test[i].Balance + '</td> ' +                        
                        '<td>' + InvType + '</td>' +
                        '<td>' + Test[i].SalTax + '</td> ' +
                        '<td>' + Test[i].SalTax_Amt + '</td> ' +
                        '<td style="display:none">' + Test[i].TotalAdvanceAdjusted + '</td>' +
                        '<td style="display:none">' + Test[i].ActualTotalAmount + '</td>' +
                        '<td style="display:none">' + Test[i].TotalAmount + '</td>' +
                        '</tr>';
                    $('#tblPOItemstModelTable tbody').append(rows);
                }
                $('#POItemsModel').modal({
                    backdrop: 'static'
                });
            });
        }
        function GetNewPaymentInvoiceNo() {
            PageMethods.GetNewPaymentInvoiceNo(function (resp) {
                $('#txt_PaymentNo').val(resp);
            },
                function (error) {
                })
        }
        function FillzerobalanceVendors(invid) {
            var optionsVen = '';
            PageMethods.getzeroVendorDDLlist(invid, function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    optionsVen += '<option value="' + value.Vendor_ID + '" >' + value.Vendor_Name + '</option>';
                });
                setTimeout(function () {
                    $('#ddl_venderName').html(optionsVen);
                }, 2000);
            });
        }
        function FillVendors() {
            var optionsVen = '';
            PageMethods.getVendorDDLlist(function (Tests) {
                optionsVen = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    if (value.IsActive == 0) {
                        optionsVen += '<option value="' + value.VendorID + '" disabled="disabled" >' + value.VendorName + '</option>';
                    }
                    else {
                        optionsVen += '<option value="' + value.VendorID + '" >' + value.VendorName + '</option>';
                    }
                });
                $('#ddl_venderName').html(optionsVen);
            });
        }
        function GetPaymentMode() {
            var optionsDeptfill = '<option value="0">Please Select</option>';
            var optionfed = '';
            PageMethods.GetPaymentMode(function (Tests) {
                optionfed = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    if (value.Type == "Pay") {
                        optionsDeptfill += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                    else {
                        optionfed += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                })
                $('#ddl_PaymentMode').html(optionsDeptfill);
            });
        }
        function FillBank() {
            var optionsBnk = '';
            PageMethods.GetBank(function (Tests) {
                bankAccountsCache = JSON.parse(Tests) || [];
                filterBankAccounts('all');
            });
        }
        function classifyAccount(name) {
            if (!name) return 'bank';
            var n = name.toLowerCase();
            if (n.indexOf('cash') >= 0 || n.indexOf('petty') >= 0) return 'cash';
            return 'bank';
        }
        function filterBankAccounts(type) {
            var prev = $('#ddl_bankCash').val();
            var html = '<option value="0">Please Select</option>';
            var stillExists = false;
            $.each(bankAccountsCache, function (key, value) {
                var accType = classifyAccount(value.name);
                if (type === 'all' || accType === type) {
                    html += '<option value="' + value.Account_ID + '" data-acc-type="' + accType + '">' + value.name + '</option>';
                    if (String(value.Account_ID) === String(prev)) stillExists = true;
                }
            });
            $('#ddl_bankCash').html(html);
            if (stillExists) {
                $('#ddl_bankCash').val(prev);
            } else {
                $('#ddl_bankCash').val('0');
            }
            $('#ddl_bankCash').trigger('change.select2');
        }
        function syncPaymentBadges() {
            $('#badgePaymentNo').text($('#txt_PaymentNo').val() || '---');
            var d = $('#txt_paymentDate').val();
            $('#badgePaymentDate').text(d || '---');
            var modeText = $('#ddl_PaymentMode option:selected').text();
            if (!modeText || modeText === 'Please Select') modeText = '---';
            $('#badgePaymentMode').text(modeText);
            $('#badgeStatus').text($('#txtStatusid').val() || '---');
        }
        function validateSave() {
            var proceed = true;
            var Vendor = $('#ddl_venderName').val();
            var PaymentMode = $('#ddl_PaymentMode').val();
            var Bankcash = $('#ddl_bankCash').val();
            var WTaxAmount = $('#txt_WTaxAmount').val();
            if (Vendor == '0') {
                $("#ddl_venderName").addClass('ErrorAlert');
                $('#select2-ddl_venderName-container').parent().css('border-color', 'red');
                proceed = false;
            }
            else {
                $("#ddl_venderName").removeClass('ErrorAlert');
                $('#select2-ddl_venderName-container').parent().css('border-color', ' rgb(206, 191, 191)');
            }
            if (PaymentMode == '0') {
                $("#ddl_PaymentMode").addClass('ErrorAlert');
                $('#select2-ddl_PaymentMode-container').parent().css('border-color', 'red');
                proceed = false;
            }
            else {
                $("#ddl_PaymentMode").removeClass('ErrorAlert');
                $('#select2-ddl_PaymentMode-container').parent().css('border-color', 'rgb(206, 191, 191)');
            }
            if (Bankcash == '0') {

                $("#ddl_bankCash").addClass('ErrorAlert');
                $('#select2-ddl_bankCash-container').parent().css('border-color', 'red');
                proceed = false;
            }
            else {
                $("#ddl_bankCash").removeClass('ErrorAlert');
                $('#select2-ddl_bankCash-container').parent().css('border-color', ' rgb(206, 191, 191)');
            }
            if (WTaxAmount < 0) {

                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'WTaxAmount always greater than zero',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                proceed = false;
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
            if (document.getElementById('tblItemDescription').rows.length > 1) {
                $.each($('#tblItemDescription tbody tr'), function (key, value) {
                    var blnceamt = parseFloat($($(value).find('td input[name=txtBalance]')[0]).val()) || 0;
                    var adjAmt = parseFloat($(value).find('input[name="txtAdjusted"]').val()) || 0;
                    if (adjAmt > blnceamt) {
                        proceed = false;
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Adjustment Amount must be less then or Equal to Balance Amount',
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
            return proceed;
        }
        function PrintPaymentDetail() {
            var id = '<% =Request.QueryString["Inv_ID"] %>';
            var locationInfo = window.location;
            var user_name = '<% =AppConfig.Company_Name %>';
            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx'; // same folder
            }
            var url = '/ReportViewer.aspx?ReportName=PaymentBasePrint&ReportTitle=Payment Invoice &Inv_Id=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/' + reportPath +  '?ReportName=PaymentBasePrint&ReportTitle=Payment Invoice &Inv_Id=' + id;
            }
            window.open(url, '_blank');
        }
        function SaveAllRecord() {
            if (validateSave()) {
                var btnSave = $('#btnSave').val();
                var PaymentNo = $('#txt_PaymentNo').val();
                var PaymentDate = $('#txt_paymentDate').val();
                var AccountId = $('#ddl_bankCash').val();
                var PaymentMode = $('#ddl_PaymentMode').val();
                var DocumentNo = $('#txt_documentNo').val();
                var DocumentDate = $('#txt_DocumentDate').val();
                var VendorId = $('#ddl_venderName').val();
                var PaidAmount = $('#txt_PaidAmount').val();
                var InvoiceAdjusted = $('#txt_invoiceAdjusted').val();
                var WTaxAmount = $('#txt_WTaxAmount').val();
                var Remarks = $('#txt_remarks').val();
                var Branch = $('#ddlBranch').val();
                var table = $('#tblItemDescriptionDetail');
                var Item_list = [];
                table.find('tr').each(function (key, value) {
                    Item_list.push({
                        'PurchaseInoviceId': $(value).find('td input[name=txtPurchaseInoviceId]').val(), 'InvoiceNum': $(value).find('td input[name=txtInvoiceNum]').val(), 'InvoiceAmount': $(value).find('td input[name=txtTotalAmount]').val(), 'InvoicePayable': $(value).find('td input[name=txtPayable]').val(), 'AdvanceAmount': $(value).find('td input[name=txtadvanceamount]').val(), 'AdjustedAmount': $(value).find('td input[name=txtAdjusted]').val() === "" ? "0" : $(value).find('td input[name=txtAdjusted]').val(), 'Deduction': $(value).find('td input[name=txtDedcution]').val() === "" ? "0"  : $(value).find('td input[name=txtDedcution]').val(), 'TotalPaidAmount': $(value).find('td input[name=txtPaidAmount]').val(), 'InvoiceType': $(value).find('td input[name=txtPurchaseInoviceType]').val(), 'wthtaxper': $(value).find('td select[name=ddlWTaxType] :selected').text(), 'withholdtaxid': $(value).find('td select[name=ddlWTaxType] :selected').val(), 'withholdtaxadj': $(value).find('td input[name=WhOnInvAdj]').val(), 'withholdtaxamou': $(value).find('td input[name=WTaxAmount]').val(), 'txtadvamount': $(value).find('td input[name=txtadvamount]').val(), 'ddlSalTaxid': $(value).find('td select[name=ddlSalTax] :selected').val(), 'SalTaxAmount': $(value).find('td input[name=SalTaxAmount]').val(),
                    });
                });
                $('#btnSave').attr('disabled', true);
                var AllItemDetail = { 'PaymentNum': PaymentNo, 'PaymentDate': PaymentDate, 'AccountId': AccountId, 'PaymentModeId': PaymentMode, 'DocumentNum': DocumentNo, 'DocumentDate': DocumentDate, 'Vendorid': VendorId, 'PaidAmount': PaidAmount, 'InvoiceAdjusted': InvoiceAdjusted, 'WTaxAmount': WTaxAmount, 'Remarks': Remarks, 'Branch': Branch, 'ItemList': Item_list };
                PageMethods.SavePaymentInvoice(btnSave, JSON.stringify(AllItemDetail), function (res) {
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
                    setTimeout(function () {
                        window.location = "AddPaymentInvoice.aspx?Inv_ID=" + res;
                        $('#btnSave').val("Update");
                    }, 2000);
                });
            }
        }
        function LoadPaymentInvoiceHeader(Inv_ID) {
            PageMethods.LoadPaymentInvoiceHeaderDetail(Inv_ID, function (resp) {
                var data = JSON.parse(resp);
                var PaymentDate = $.datepicker.formatDate('dd M yy', new Date(parseInt(data.PaymentDate.substring(6, 19))));
                $('#txt_paymentDate').val(PaymentDate);
                var DocumentDate = $.datepicker.formatDate('dd M yy', new Date(parseInt(data.DocumentDate.substring(6, 19))));
                $('#txt_DocumentDate').val(DocumentDate);
                setTimeout(function () {
                    $('#ddl_bankCash').val(data.AccountId).trigger('change');
                }, 1500);
                setTimeout(function () {
                    $('#ddl_PaymentMode').val(data.PaymentModeId).trigger('change');
                }, 1500);
                setTimeout(function () {
                    $('#ddl_venderName').val(data.Vendor_ID).trigger('change');
                }, 1500);
                $('#txt_PaymentNo').val(data.PaymentNum);
                $('#txt_documentNo').val(data.DocumentNo);
                $('#txt_PaidAmount').val(data.PaidAmount);
                $('#txt_invoiceAdjusted').val(data.InvoiceAdjusted);
                $('#txt_WTaxAmount').val(data.WTaxAmount);
                $('#txt_remarks').val(data.Remarks);
                $('#txtStatusid').val(data.Status);
                savedBranch = data.Branch_id;
                if (savedBranch) {
                    $('#ddlBranch').val(savedBranch).trigger('change');
                }
                var checkstatus = $('#txtStatusid').val();
                if (checkstatus == 'Approved') {
                    $('#btnSave').attr("disabled", 'disabled');
                    $('#btnSave').hide();
                    UserUnApproveButtonRights();
                    $('#btnVoucher').show();
                    $('#btn_Print').show();
                }
                if (checkstatus == 'Created' || checkstatus == 'Pending') {
                    $('#btnSave').attr("disabled", false);
                    $('#btnSave').show();
                    $('#btnVoucher').hide();
                    $('#btn_Print').show();
                    if (Inv_ID != '') {
                        CheckPAYMENTApprovalRightsAndShowButton(Inv_ID);
                    }
                }
                FillzerobalanceVendors(Inv_ID);
                LoadPaymnetInvocieDetail(Inv_ID)
                $('#btnSave').val("Update");

            },
                function (error) {
                    //alert(error.get_message());
                })
        }
        //advance
        function LoadPaymnetInvocieDetail(Inv_ID) {
            PageMethods.LoadPaymentInvoiceDetail(Inv_ID, function (resp) {
                var data = (JSON.parse(resp));
                var rows = '';
                selectedOptions = data;
                var payable = 0;
                var TotalAmount = 0;
                var totaladj = 0
                var totaladvance = 0
                var balnce = 0;
                $.each(data, function (key, value) {
                    TotalAmount = value.TotalAmount;
                    totaladvance = value.Advance_Amount;
                    balnce = TotalAmount - totaladvance;
                    rows += '<tr>' +
                        '<td><input type="hidden" id="txtInvoiceNum' + key + '" name="txtInvoiceNum" value="' + value.Invoice_No + '"/>' + value.Invoice_No + '</td> ' +
                        '<td class="headcol_2"><input type="hidden" id="txtTotalAmount' + key + '" name="txtTotalAmount" value="' + value.TotalAmount + '"/>' + value.TotalAmount + '</td> ' +
                        '<td><input type="hidden" id="txtadvanceamount' + length + '" name="txtadvanceamount" value="' + value.Advance_Amount + '"/>' + value.Advance_Amount + '</td> ' +
                        '<td><input type="hidden" id="txtPreviouslyPaid' + key + '" name="txtPreviouslyPaid" value="' + value.PreviouslyPaid + '"/>' + value.PreviouslyPaid + '</td>' +
                        '<td><input type="hidden" id="txtBalance' + key + '" name="txtBalance" value="' + balnce + '"/>' + balnce + '</td>' +
                        '<td><input type="text" id="txtAdjusted' + key + '" name="txtAdjusted" value="' + value.AdjustedAmount + '" onchange="calcutae()" style="width: 89px!important"/></td>' +
                        '<td><input type="text" id="txtDedcution' + key + '" name="txtDedcution" value="' + value.Deduction + '" onchange="calcutae()" style="width: 89px!important"/></td>' +
                        '<td><select id="ddlWTaxType' + key + '" class="ddlWTaxType" name="ddlWTaxType" onchange="calcutae()" style="width:86px!important"></select></td>' +
                        '<td style="display:none;"><input type="text" id="WhOnInvAdj' + key + '" name="WhOnInvAdj" readonly="true" value="' + value.withholdtaxadj + '"/></td>' +
                        '<td style="display:none;"><input type="hidden" id="TaxableSwht' + key + '" name="TaxableSwht" value="" /></td>' +
                        '</td>' +
                        '<td><input type="text" id="WTaxAmount' + key + '" name="WTaxAmount" value="' + value.withholdtaxamou + '" style="width:117px!important"/></td>' +
                        '<td style="display:none"><select id="ddlSalTax' + key + '" readonly class="ddlSalTax" name="ddlSalTax" style="width: 93px!important"></select></td>' +
                        '<td style="display:none"><input type="text" id="SalTaxAmount' + key + '" name="SalTaxAmount" readonly="true" value="' + value.Stax_Amount + '" style="width: 116px!important"></td>' +
                        '<td><input id="txtPaidAmount' + key + '" name="txtPaidAmount" value="' + value.TotalPaidAmount + '" type="text" style="width: 136px!important;border: none;"/></td>' +
                        '<td style="display:none"><input type="hidden" id="txtPurchaseInoviceId' + key + '" name="txtPurchaseInoviceId" value="' + value.PurchaseInvoiceId + '"/></td>' +
                        '<td style="display:none"><input type="hidden" id="txtPurchaseInoviceType' + key + '" name="txtPurchaseInoviceType" value="' + value.InvoiceType + '"/></td>' +
                        '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="fa fa-trash" style="font-size: 13px;margin-left: 16px; color: #f30a0a;position:relative;" i=""></i></a></td>' +
                        '</tr>'
                    length++;
                });
                $("#tblItemDescription").append(rows);
                setTimeout(function () {
                    $.each(data, function (key, value) {
                        $("#ddlWTaxType" + key).val(value.WithHoldtax_ID).trigger('change');
                        $('#ddlSalTax' + key).val(value.Stax_ID).trigger('change');
                    });
                }, 5500);
                $('#btnSave').val('Update');
            },
                function (error) {
                })
        }
        function append(anchor) {
            var row = $(anchor).parents('tr')[0];
            var PurchaseInvoiceId = $($(row).find('td')[1]).text();
            var Invoicenum = $($(row).find('td')[2]).text();
            var payable = $($(row).find('td')[3]).text();
            var advance = $($(row).find('td')[4]).text();
            var paidamount = $($(row).find('td')[5]).text();
            var balance = $($(row).find('td')[6]).text();
            var InvoiceType = $($(row).find('td')[7]).text();
            var SalTaxid = $($(row).find('td')[8]).text();
            var SalTaxAmt = $($(row).find('td')[9]).text();
            var advamount = $($(row).find('td')[10]).text();
            var Actual_Inv_Amont = $($(row).find('td')[11]).text();
            var length = $("#tblItemDescription tr:gt(0)").length;
            if (length > 0) {
                length = length + 1;
            }
            else {
                length = 1;
            }
            var test_array = $('#tblItemDescription').find('input[name=txtInvoiceNum][value=' + Invoicenum + ']');
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
            var rows = '<tr>' +
                '<td><input type="hidden" id="txtInvoiceNum' + length + '" name="txtInvoiceNum" value="' + Invoicenum + '"/>' + Invoicenum + '</td> ' +
                '<td class="headcol_2"><input type="hidden" id="txtTotalAmount' + length + '" name="txtTotalAmount" value="' + Actual_Inv_Amont + '"/>' + Actual_Inv_Amont + '</td> ' +
                '<td><input type="hidden" id="txtadvanceamount' + length + '" name="txtadvanceamount" value="' + advance + '"/>' + advance + '</td> ' +
                '<td><input type="text" readonly style="width: 70px!important" id="txtPreviouslyPaid' + length + '" name="txtPreviouslyPaid" value="' + paidamount + '"/></td>' +
                '<td><input type="text" readonly style="width: 70px!important" id="txtBalance' + length + '" name="txtBalance" value="' + balance + '"/></td>' +
                '<td><input type="text" id="txtAdjusted' + length + '" name="txtAdjusted" onkeyup="calcutae()" style="width: 88px!important" value="' + balance + '"/></td>' +
                '<td><input type="text" id="txtDedcution' + length + '" name="txtDedcution" onchange="calcutae()" style="width: 88px!important"/></td>' +
                '<td><select id="ddlWTaxType' + length + '" class="ddlWTaxType" name="ddlWTaxType" onchange="calcutae()" style="width: 93px!important"></select></td>' +
                '<td style="display:none;"><input type="text" id="WhOnInvAdj' + length + '" name="WhOnInvAdj"  readonly="true"/></td>' +
                '<td style="display:none;"><input type="hidden" id="TaxableSwht' + length + '" name="TaxableSwht" value="" /></td>' +
                '</td>' +
                '<td><input type="text" id="WTaxAmount' + length + '" name="WTaxAmount" readonly="true" style="width: 116px!important"></td>' +
                '<td style="display:none"><select id="ddlSalTax' + length + '" name="ddlSalTax" class="ddlSalTax" readonly style="width: 93px!important"></select></td>' +
                '<td style="display:none"><input type="text" id="SalTaxAmount' + length + '" name="SalTaxAmount" readonly="true" value="' + SalTaxAmt + '" style="width: 116px!important"></td>' +
                '<td><input  readonly="readonly" style="width:133px!important;border: none" id="txtPaidAmount' + length + '" name="txtPaidAmount" value="' + balance + '" type="text" /></td>' +
                '<td style="display:none"><input type="hidden" id="txtPurchaseInoviceId' + length + '" name="txtPurchaseInoviceId" value="' + PurchaseInvoiceId + '"/></td>' +
                '<td style="display:none"><input type="hidden" id="txtPurchaseInoviceType' + length + '" name="txtPurchaseInoviceType" value="' + InvoiceType + '"/></td>' +
                '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="fa fa-trash" style="font-size: 13px;margin-left: 16px; color: #f30a0a;position:relative;" i=""></i></a></td>' +
                '</tr>'
            $("#tblItemDescription").append(rows);
            populateWithTaxddl(length);
            populateSalTaxddl(length, SalTaxid);
            length++;
        }

        function populateSalTaxddl(rowId, id) {
            PageMethods.getStaxtype(function (response) {
                var options = '<option value="0">Please Select</option>';
                $.each(JSON.parse(response), function (key, value) {
                    options += '<option value="' + value.Sales_Tax_ID + '">' + value.Sales_Tax_Perc + '</option>';
                });
                $('#ddlSalTax' + rowId).html(options);
            });
            setTimeout(function () {
                $('#ddlSalTax' + rowId).val(id).trigger('change');
            }, 1000);
        }

        function populateWithTaxddl(rowId) {
            PageMethods.getwtaxtype(function (response) {
                var options = '<option value="0">Please Select</option>';
                $.each(JSON.parse(response), function (key, value) {
                    options += '<option value="' + value.WithHold_Tax_ID + '">' + value.WithHold_Tax_Perc + '</option>';
                });
                $('#ddlWTaxType' + rowId).html(options);
            });

        }


        function calcutae() {
            var TotalinvoiceAdjusted = 0;
            var TotalPaidAmount = 0;
            var totalcheckpaidamou = 0;
            var totaltaxamount = 0;

            $.each($('#tblItemDescription tbody tr'), function (key, value) {
                var InvoiceAjust = parseFloat($($(value).find('td input[name=txtAdjusted]')[0]).val()) || 0;
                var balance = parseFloat($($(value).find('td input[name=txtBalance]')[0]).val()) || 0;
                var InvoiceDeduction = parseFloat($($(value).find('td input[name=txtDedcution]')[0]).val()) || 0;
                // Check if InvoiceAjust is greater than balance
                if (InvoiceAjust > balance) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Adjusted amount cannot be greater than the balance.',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                    $(value).find('td input[name=txtAdjusted]').val(0);
                    InvoiceAjust = 0;
                }
                TotalinvoiceAdjusted += InvoiceAjust;
                var wtxtype = $(value).find('td select[name=ddlWTaxType] :selected').text() || 0;
                if (wtxtype == "Please Select") wtxtype = 0;
                var adjustedvalue = ((InvoiceAjust * wtxtype) / 100).toFixed(2);
                $(value).find('input[name=WhOnInvAdj]').val(adjustedvalue);
                $(value).find('input[name=WTaxAmount]').val(adjustedvalue);
                var remnvalueadjusted = (InvoiceAjust - adjustedvalue - InvoiceDeduction).toFixed(2);
                $(value).find('input[name=txtPaidAmount]').val(remnvalueadjusted);
                TotalPaidAmount += parseFloat(remnvalueadjusted);
                // Validate NaN cases
                if (isNaN(parseFloat(adjustedvalue))) {
                    $(value).find('input[name=WhOnInvAdj]').val(0);
                    $(value).find('input[name=WTaxAmount]').val(0);
                }
                if (isNaN(parseFloat(remnvalueadjusted))) {
                    $(value).find('input[name=txtPaidAmount]').val(InvoiceAjust);
                }
                totalcheckpaidamou += parseFloat($(value).find('td input[name=txtPaidAmount]').val()) || 0;
                totaltaxamount += parseFloat($(value).find('td input[name=WTaxAmount]').val()) || 0;
            });
            $('#txt_invoiceAdjusted').val(TotalinvoiceAdjusted);
            $('#txt_PaidAmount').val(totalcheckpaidamou);
            $('#txt_WTaxAmount').val(totaltaxamount);
        }
        

       <%--
        function Approve() {
            var InvId = '<% =Request.QueryString["Inv_ID"] %>';
            PageMethods.ApprovePayment(InvId, function (Tests) {
                var message = JSON.parse(Tests);
                if (message[0].Message != null || message[0].Message != "") {
                    alert(message[0].Message);
                    location.reload();
                }
            });
        }--%>
        function UnApprove() {
            var InvId = '<% =Request.QueryString["Inv_ID"] %>';
            PageMethods.UnApprovePayment(InvId, function (Tests) {
                var message = JSON.parse(Tests);
                if (message[0].Column1 != "" || message[0].Column1 != null) {
                    alert(message[0].Column1);
                    location.reload();
                }
            });
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

                var url = '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=Payment Voucher&TransID=' + InvId + '&TransType=Pay';
                if (!locationInfo.origin.includes('localhost')) {
                    var urlInfo = window.location.href.split('/');
                    var ip = urlInfo[2];
                    var foldername = urlInfo[3];
                    url = 'http://' + ip + '/' + foldername + '/' + reportPath +  '?ReportName=Voucher&ReportTitle=Payment Voucher&TransID=' + InvId + '&TransType=Pay';
                }
                window.open(url, '_blank');
            }

            function sendFile(ID) {
                var fileInput = $('#chosePaymentfile')[0];
                if (fileInput.files.length > 0) {
                    var data = new FormData();
                    data.append('file', $('#chosePaymentfile')[0].files[0]);
                    data.append('ID', ID);
                    $.ajax({
                        type: 'post',
                        url: '../../UploadPaymentFiles.ashx',
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
            function UserUnApproveButtonRights() {
                $.ajax({
                    type: "POST",
                    url: "AddPaymentInvoice.aspx/UserUnApproveEntryRights",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        var hasRights = response.d;
                        if (hasRights) {
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
            function CheckPAYMENTApprovalRightsAndShowButton(invId) {
                callPageMethod('CheckPAYMENTApprovalRights', function (hasRights) {
                    if (hasRights) {
                        callPageMethod('GetPAYMENTApprovalInfo', { InvId: invId }, function (resp) {
                            var info = JSON.parse(resp);
                            if (info.CanApprove) {
                                $('#btnApprovePay').show();
                                $('#btnApprovePay').data('pay-amount', info.Amount);
                            }
                        });
                    }
                });
            }
            function ApprovePAYMENTFromEdit() {
                var invId = '<% =Request.QueryString["Inv_ID"] %>';
                var amount = $('#btnApprovePay').data('pay-amount');
                var confirmHtml = 'Are you sure you want to approve Payment Invoice #' + $('#txt_PaymentNo').val() + '?';
                if (amount > 0) {
                    confirmHtml += '<br><br>Invoice Amount: <strong>' + parseFloat(amount).toFixed(2) + '</strong>';
                }
                Swal.fire({
                    title: 'Approve Payment Invoice?',
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
                        callPageMethod('ApproveSinglePAYMENT', { InvId: invId, approvalRemarks: remarks }, function (resp) {
                            if (resp === "Success") {
                                Swal.fire({ icon: 'success', title: 'Approved!', text: 'Payment Invoice has been approved successfully.', showConfirmButton: false, timer: 2000, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } }).then(function () { location.reload(); });
                            } else {
                                Swal.fire({ icon: 'error', title: 'Error', text: resp, showConfirmButton: true, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } }).then(function () { location.reload(); });
                            }
                        });
                    }
                });
            }


        </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="pi-page">

        <!-- Title line: the master page puts "Payment » Add Payment" in the empty left side; the badges sit on the right -->
        <div class="pr-meta-bar">
            <div class="meta-left"></div>
            <div class="meta-right">
                <div class="pi-badge"><span class="pi-badge-label">No</span><span class="pi-badge-value" id="badgePaymentNo">---</span></div>
                <div class="pi-badge"><span class="pi-badge-label">Date</span><span class="pi-badge-value" id="badgePaymentDate">---</span></div>
                <div class="pi-badge"><span class="pi-badge-label">Mode</span><span class="pi-badge-value" id="badgePaymentMode">---</span></div>
                <div class="pi-badge"><span class="pi-badge-label">Status</span><span class="pi-badge-value" id="badgeStatus">---</span></div>
            </div>
        </div>

        <div class="pi-layout">

            <!-- Left: payment details + attachments -->
            <div class="pi-col">
                <section class="pi-card">
                    <h5 class="pi-card-title"><i class="fa fa-file-text-o"></i> Payment Details</h5>
                    <div class="pi-grid">
                        <div class="pi-field">
                            <label for="txt_PaymentNo">Payment No</label>
                            <input id="txt_PaymentNo" class="form-control" type="text" name="txt_PaymentNo" readonly="readonly" />
                        </div>
                        <div class="pi-field">
                            <label for="ddl_PaymentMode">Payment Mode<span class="pi-req">*</span></label>
                            <select id="ddl_PaymentMode" class="form-control">
                                <option value="0">Please Select</option>
                            </select>
                        </div>
                        <div class="pi-field">
                            <label for="txt_paymentDate">Payment Date</label>
                            <input id="txt_paymentDate" class="form-control" type="text" name="txt_paymentDate" autocomplete="off" />
                        </div>
                        <div class="pi-field">
                            <label for="txtStatusid">Status</label>
                            <input type="text" id="txtStatusid" readonly="readonly" class="form-control" />
                        </div>

                        <div class="pi-field">
                            <label for="txt_documentNo">Document No</label>
                            <input id="txt_documentNo" class="form-control" type="text" name="txt_documentNo" autocomplete="off" />
                        </div>
                        <div class="pi-field">
                            <label for="txt_DocumentDate">Document Date</label>
                            <input id="txt_DocumentDate" class="form-control" type="text" name="txt_DocumentDate" autocomplete="off" />
                        </div>
                        <div class="pi-field">
                            <label for="ddl_venderName">Vendor Name<span class="pi-req">*</span></label>
                            <select id="ddl_venderName" class="form-control">
                                <option value="0">Please Select</option>
                            </select>
                        </div>
                        <div class="pi-field">
                            <label>&nbsp;</label>
                            <button id="btn_ManInv" type="button" class="btn btn-primry" style="width:100%;"><i class="fa fa-plus"></i> Add Invoices</button>
                        </div>
                    </div>
                </section>

                <section class="pi-card">
                    <h5 class="pi-card-title"><i class="fa fa-paperclip"></i> Attachments &amp; Remarks</h5>
                    <div class="pi-grid">
                        <div class="pi-field pi-span-2">
                            <label for="chosePaymentfile">Attachments</label>
                            <input id="chosePaymentfile" type="file" name="chosePaymentfile" class="form-control" />
                            <asp:HyperLink ID="HyperLink1" runat="server" CssClass="pi-link">Download</asp:HyperLink>
                        </div>
                        <div class="pi-field">
                            <label for="ddlBranch">Branch</label>
                            <select id="ddlBranch" class="form-control">
                                <option value="0">Please Select</option>
                            </select>
                        </div>
                        <div class="pi-field pi-span-all">
                            <label for="txt_remarks">Remarks</label>
                            <textarea id="txt_remarks" class="form-control" name="txt_remarks" rows="2" cols="20"></textarea>
                        </div>
                    </div>
                </section>
            </div>

            <!-- Right: bank / cash + summary -->
            <div class="pi-col">
                <section class="pi-card">
                    <h5 class="pi-card-title"><i class="fa fa-bank"></i> Bank / Cash</h5>
                    <div class="pi-grid pi-grid-2" style="grid-template-columns: minmax(0, 1fr);">
                        <div class="pi-field">
                            <label>Account Type</label>
                            <div class="pi-seg">
                                <label><input type="radio" name="rbtnAccType" id="rbtnAccAll" value="all" checked /><span>All</span></label>
                                <label><input type="radio" name="rbtnAccType" id="rbtnAccCash" value="cash" /><span>Cash</span></label>
                                <label><input type="radio" name="rbtnAccType" id="rbtnAccBank" value="bank" /><span>Bank</span></label>
                            </div>
                        </div>
                        <div class="pi-field">
                            <label for="ddl_bankCash">Select Account<span class="pi-req">*</span></label>
                            <select id="ddl_bankCash" class="form-control">
                                <option>Please Select</option>
                            </select>
                        </div>
                    </div>
                </section>

                <section class="pi-card">
                    <h5 class="pi-card-title"><i class="fa fa-calculator"></i> Summary</h5>
                    <div class="pi-grid" style="grid-template-columns: minmax(0, 1fr);">
                        <div class="pi-field pi-figure pi-figure-main">
                            <label for="txt_PaidAmount">Paid Amount</label>
                            <input id="txt_PaidAmount" type="text" name="txt_PaidAmount" readonly="readonly" class="form-control" />
                        </div>
                        <div class="pi-field pi-figure">
                            <label for="txt_invoiceAdjusted">Adjusted</label>
                            <input id="txt_invoiceAdjusted" class="form-control" type="text" name="txt_invoiceAdjusted" readonly="readonly" />
                        </div>
                        <div class="pi-field pi-figure">
                            <label for="txt_WTaxAmount">W Tax Amount</label>
                            <input id="txt_WTaxAmount" class="form-control" type="text" readonly="readonly" name="txt_WTaxAmount" />
                        </div>
                    </div>
                </section>
            </div>
        </div>

        <!-- Invoices being paid -->
        <section class="pi-card">
            <h5 class="pi-card-title"><i class="fa fa-list-alt"></i> Invoices <span class="pi-card-note">Use <b>Add Invoices</b> to pick the vendor's open invoices</span></h5>
            <div class="pi-table-wrap">
                <table class="table" id="tblItemDescription">
                    <thead>
                        <tr>
                            <th class="table_heading_color" style="width: 87px;">Invoice#</th>
                            <th class="table_heading_color" style="width: 114px;">Invoice Amt</th>
                            <th class="table_heading_color" style="width: 104px;">Advance Amt</th>
                            <th class="table_heading_color" style="width: 100px;">Previously Paid </th>
                            <th class="table_heading_color" style="width: 100px;">Balance</th>
                            <th class="table_heading_color" style="width: 120px;">Adjusted</th>
                            <th class="table_heading_color" style="width: 120px;">Deduction</th>
                            <th class="table_heading_color" style="display: none;">P Tax</th>
                            <th class="table_heading_color" style="display: none;">P Tax</th>
                            <th class="table_heading_color" style="width: 120px;">WH Tax</th>
                            <th class="table_heading_color" style="display: none;">Wh On Inv Adj</th>
                            <th class="table_heading_color" style="display: none;">Taxtable SWHT</th>
                            <th class="table_heading_color" style="width: 134px;">WH Tax Amt</th>
                            <th class="table_heading_color" style="width: 101px; display: none !important;">SalTax</th>
                            <th class="table_heading_color" style="width: 134px; display: none !important;">SalTax Amt</th>
                            <th class="table_heading_color" style="width: 150px;">Paid Amount</th>
                            <th class="table_heading_color">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="tblItemDescriptionDetail">
                    </tbody>
                </table>
            </div>
        </section>

        <!-- Actions -->
        <div class="row" style="margin-top: 1%">
            <div class="col-lg-6">
                <div class="row">
                    <div class="col-lg-2 col-md-4 col-sm-12">
                        <input type="button" class="btn btn-primry" name="btnSave" id="btnSave" value="Save" onclick="this.disabled = true;" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-12">
                        <input type="button" class="btn-gray" value="List" onclick="window.location='PaymentInvoiceView.aspx'" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-12">
                        <input type="button" class="btn btn-yellow" value="New" onclick="window.location='AddPaymentInvoice.aspx'" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-12">
                        <input type="button" name="" id="btn_Print" value="Print" class="btn btn-primry" onclick="PrintPaymentDetail()" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-12">
                        <input type="button" style="display: none" class="btn btn-primry" value="Approve" id="btnApprovePay" onclick="ApprovePAYMENTFromEdit()" />
                        <input type="button" style="display: none" class="btn btn-primry" value="UnApprove" id="btnUnApprove" onclick="UnApprove()" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-12">
                        <input type="button" value="Voucher" class="btn btn-primry" id="btnVoucher" onclick="PrintVoucher()" />
                    </div>
                </div>
            </div>
        </div>

        <!-- Add invoices picker -->
        <div id="POItemsModel" class="modal fade pi-modal" role="dialog">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">&times;</button>
                        <h4 class="modal-title">Add Purchase Items</h4>
                    </div>
                    <input type="hidden" id="txthiddentr" name="txthidddentr" />
                    <div class="pi-modal-scroll">
                        <table class="table" id="tblPOItemstModelTable">
                            <thead>
                                <tr>
                                    <th style="width: 40px;">
                                        <input type="checkbox" id="checkHeader" value="false" /></th>
                                    <th>Invoice#</th>
                                    <th>Payable</th>
                                    <th>Advance Amount</th>
                                    <th>Paid Amount</th>
                                    <th>Balance</th>
                                    <th>Invoice Type</th>
                                    <th>SalTax</th>
                                    <th>SalTax Amt</th>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>
                    <div class="modal-footer">
                        <div class="row">
                            <div class="col-lg-10"></div>
                            <div class="col-lg-2 col-md-4 col-sm-6">
                                <input type="button" id="PoItem" name="PoItem" value="Done" class="btn btn-primry" data-dismiss="modal" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </div>
</asp:Content>
