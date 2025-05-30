<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AddPaymentInvoice.aspx.cs" Inherits="PMS.Inventory.AddPaymentInvoice" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
   
    
     <script type="text/javascript">
         var InvType = '';
         $(document).ready(function () {
             UserRights();
             $('#ddl_PaymentMode').select2();
             $('#ddl_venderName').select2();
             $('#ddl_bankCash').select2();
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
                        debugger
                        $("#tblPOItemstModelTable tr:gt(0) input[type=checkbox]:checked ").each(function (key, value) {
                            debugger
                            var row = $(this);
                            debugger
                            append(row);
                        });
                    }, 1000);
                }
                else {
                    $('.chktd').prop('checked', false);
                }
            });
            $('#btn_ManInv').on('click', function () {
                debugger
                var vendorId = $("#ddl_venderName").val();
                GetManualInvoiceDetailAndGetPurchaseInvoiceNDetailByVendorId(vendorId);
                $('#ctl00_MainContent_txtRemarks').focus();
            });
            var Inv_ID = '<%= Request.QueryString["Inv_ID"]%>'
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

        function UserRights() {
            debugger;
            $.ajax({
                type: "POST",
                url: "AddPaymentInvoice.aspx/UserEntryRights",
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
                    alert("Failed to retrieve user rights.");
                }
            });
        }
        debugger;
        function LoadPurchaseInvoiceNDetail(vendorId) {
            debugger
            PageMethods.getPurchaseInvoiceNDetailByVendorId(vendorId, function (data) {
                debugger
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
        debugger;
        function GetManualInvoiceDetailAndGetPurchaseInvoiceNDetailByVendorId(vendorId) {
            debugger
            PageMethods.GetManualInvoiceDetailAndGetPurchaseInvoiceNDetailByVendorId(vendorId, function (data) {
                debugger;
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
                    debugger;
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
                debugger
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
                debugger
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
                debugger
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
                debugger
                optionsBnk = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    optionsBnk += '<option value="' + value.Account_ID + '" >' + value.name + '</option>';
                });
                $('#ddl_bankCash').html(optionsBnk);
            });
        }
        function validateSave() {
            debugger;
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
                alert("WTaxAmount always greater than zero");
                proceed = false;
            }
            var tblLength = $("#tblItemDescription tr:gt(0)").length;
            if (tblLength == '0') {

                $('#tblItemDescription').addClass('ErrorAlert');
                alert("Please Add items");
                proceed = false;
            } else {
                $('#tblItemDescription').removeClass('ErrorAlert');
            }
            if (document.getElementById('tblItemDescription').rows.length > 1) {
                debugger;
                $.each($('#tblItemDescription tbody tr'), function (key, value) {
                    debugger;
                    var blnceamt = parseFloat($($(value).find('td input[name=txtBalance]')[0]).val()) || 0;
                    var adjAmt = parseFloat($(value).find('input[name="txtAdjusted"]').val()) || 0;
                    if (adjAmt > blnceamt) {
                        proceed = false;
                        alert("Adjustment Amount must be less then or Equal to Balance Amount");
                    }
                });
            }
            debugger;
            return proceed;
        }
        debugger;
        function PrintPaymentDetail() {
            var id = '<% =Request.QueryString["Inv_ID"] %>';
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=PaymentBasePrint&ReportTitle=Payment Invoice &Inv_Id=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=PaymentBasePrint&ReportTitle=Payment Invoice &Inv_Id=' + id;
            }
            window.open(url, '_blank');
        }
        function SaveAllRecord() {
            debugger;
            if (validateSave()) {
                debugger;
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
                var table = $('#tblItemDescriptionDetail');
                var Item_list = [];
                table.find('tr').each(function (key, value) {
                    Item_list.push({
                        'PurchaseInoviceId': $(value).find('td input[name=txtPurchaseInoviceId]').val(), 'InvoiceNum': $(value).find('td input[name=txtInvoiceNum]').val(), 'InvoiceAmount': $(value).find('td input[name=txtTotalAmount]').val(), 'InvoicePayable': $(value).find('td input[name=txtPayable]').val(), 'AdvanceAmount': $(value).find('td input[name=txtadvanceamount]').val(), 'AdjustedAmount': $(value).find('td input[name=txtAdjusted]').val() === "" ? "0" : $(value).find('td input[name=txtAdjusted]').val(), 'Deduction': $(value).find('td input[name=txtDedcution]').val() === "" ? "0"  : $(value).find('td input[name=txtDedcution]').val(), 'TotalPaidAmount': $(value).find('td input[name=txtPaidAmount]').val(), 'InvoiceType': $(value).find('td input[name=txtPurchaseInoviceType]').val(), 'wthtaxper': $(value).find('td select[name=ddlWTaxType] :selected').text(), 'withholdtaxid': $(value).find('td select[name=ddlWTaxType] :selected').val(), 'withholdtaxadj': $(value).find('td input[name=WhOnInvAdj]').val(), 'withholdtaxamou': $(value).find('td input[name=WTaxAmount]').val(), 'txtadvamount': $(value).find('td input[name=txtadvamount]').val(), 'ddlSalTaxid': $(value).find('td select[name=ddlSalTax] :selected').val(), 'SalTaxAmount': $(value).find('td input[name=SalTaxAmount]').val(),
                    });
                });
                $('#btnSave').attr('disabled', true);
                var AllItemDetail = { 'PaymentNum': PaymentNo, 'PaymentDate': PaymentDate, 'AccountId': AccountId, 'PaymentModeId': PaymentMode, 'DocumentNum': DocumentNo, 'DocumentDate': DocumentDate, 'Vendorid': VendorId, 'PaidAmount': PaidAmount, 'InvoiceAdjusted': InvoiceAdjusted, 'WTaxAmount': WTaxAmount, 'Remarks': Remarks, 'ItemList': Item_list };
                PageMethods.SavePaymentInvoice(btnSave, JSON.stringify(AllItemDetail), function (res) {
                    alert('Data Save Successfully');
                    sendFile(res);
                    setTimeout(function () {
                        debugger;
                        window.location = "AddPaymentInvoice.aspx?Inv_ID=" + res;
                        $('#btnSave').val("Update");
                    }, 2000);
                });
            }
        }
        function LoadPaymentInvoiceHeader(Inv_ID) {
            debugger;
            PageMethods.LoadPaymentInvoiceHeaderDetail(Inv_ID, function (resp) {
                debugger;
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
                debugger;
                var checkstatus = $('#txtStatusid').val();
                if (checkstatus == 'Approved') {
                    debugger;
                    $('#btnSave').attr("disabled", 'disabled');
                    $('#btnSave').hide();
                    UserUnApproveButtonRights();
                    $('#btnVoucher').show();
                    $('#btn_Print').show();
                }
                debugger;
                if (checkstatus == 'Created') {
                    debugger;
                    $('#btnSave').attr("disabled", false);
                    $('#btnSave').show();
                    $('#btnVoucher').hide();
                    $('#btn_Print').show();
                }
                debugger;
                FillzerobalanceVendors(Inv_ID);
                LoadPaymnetInvocieDetail(Inv_ID)
                $('#btnSave').val("Update");

            },
                function (error) {
                    //alert(error.get_message());
                })
        }
        //advance
        debugger;
        function LoadPaymnetInvocieDetail(Inv_ID) {
            debugger;
            PageMethods.LoadPaymentInvoiceDetail(Inv_ID, function (resp) {
                debugger;
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
                        '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="font-size: 13px;margin-left: 16px; color: #f30a0a;position:relative;" i=""></i></a></td>' +
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
        debugger;
        function append(anchor) {
            debugger;
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
                alert('This Item already added!');
                $('#ctl00_MainContent_txtPRNo').tokenInput("clear");
                return false;
            }
            var rows = '<tr>' +
                '<td><input type="hidden" id="txtInvoiceNum' + length + '" name="txtInvoiceNum" value="' + Invoicenum + '"/>' + Invoicenum + '</td> ' +
                '<td class="headcol_2"><input type="hidden" id="txtTotalAmount' + length + '" name="txtTotalAmount" value="' + Actual_Inv_Amont + '"/>' + Actual_Inv_Amont + '</td> ' +
                '<td><input type="hidden" id="txtadvanceamount' + length + '" name="txtadvanceamount" value="' + advance + '"/>' + advance + '</td> ' +
                '<td><input type="text" readonly style="width: 70px!important" id="txtPreviouslyPaid' + length + '" name="txtPreviouslyPaid" value="' + paidamount + '"/></td>' +
                '<td><input type="text" readonly style="width: 70px!important" id="txtBalance' + length + '" name="txtBalance" value="' + balance + '"/></td>' +
                '<td><input type="text" id="txtAdjusted' + length + '" name="txtAdjusted" onchange="calcutae()" style="width: 88px!important"/></td>' +
                '<td><input type="text" id="txtDedcution' + length + '" name="txtDedcution" onchange="calcutae()" style="width: 88px!important"/></td>' +
                '<td><select id="ddlWTaxType' + length + '" class="ddlWTaxType" name="ddlWTaxType" onchange="calcutae()" style="width: 93px!important"></select></td>' +
                '<td style="display:none;"><input type="text" id="WhOnInvAdj' + length + '" name="WhOnInvAdj"  readonly="true"/></td>' +
                '<td style="display:none;"><input type="hidden" id="TaxableSwht' + length + '" name="TaxableSwht" value="" /></td>' +
                '</td>' +
                '<td><input type="text" id="WTaxAmount' + length + '" name="WTaxAmount" readonly="true" style="width: 116px!important"></td>' +
                '<td style="display:none"><select id="ddlSalTax' + length + '" name="ddlSalTax" class="ddlSalTax" readonly style="width: 93px!important"></select></td>' +
                '<td style="display:none"><input type="text" id="SalTaxAmount' + length + '" name="SalTaxAmount" readonly="true" value="' + SalTaxAmt + '" style="width: 116px!important"></td>' +
                '<td><input  readonly="readonly" style="width:133px!important;border: none" id="txtPaidAmount' + length + '" name="txtPaidAmount" value="" type="text"/></td>' +
                '<td style="display:none"><input type="hidden" id="txtPurchaseInoviceId' + length + '" name="txtPurchaseInoviceId" value="' + PurchaseInvoiceId + '"/></td>' +
                '<td style="display:none"><input type="hidden" id="txtPurchaseInoviceType' + length + '" name="txtPurchaseInoviceType" value="' + InvoiceType + '"/></td>' +
                '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="font-size: 13px;margin-left: 16px; color: #f30a0a;position:relative;" i=""></i></a></td>' +
                '</tr>'
            $("#tblItemDescription").append(rows);
            debugger
            populateWithTaxddl(length);
            populateSalTaxddl(length, SalTaxid);
            length++;
        }

        function populateSalTaxddl(rowId, id) {
            debugger
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
            debugger
            PageMethods.getwtaxtype(function (response) {
                var options = '<option value="0">Please Select</option>';
                $.each(JSON.parse(response), function (key, value) {
                    options += '<option value="' + value.WithHold_Tax_ID + '">' + value.WithHold_Tax_Perc + '</option>';
                });
                $('#ddlWTaxType' + rowId).html(options);
            });

        }


        debugger;
        function calcutae() {
            debugger;
            var TotalinvoiceAdjusted = 0;
            var TotalPaidAmount = 0;
            var totalcheckpaidamou = 0;
            var totaltaxamount = 0;

            $.each($('#tblItemDescription tbody tr'), function (key, value) {
                debugger;
                var InvoiceAjust = parseFloat($($(value).find('td input[name=txtAdjusted]')[0]).val()) || 0;
                var balance = parseFloat($($(value).find('td input[name=txtBalance]')[0]).val()) || 0;
                var InvoiceDeduction = parseFloat($($(value).find('td input[name=txtDedcution]')[0]).val()) || 0;
                // Check if InvoiceAjust is greater than balance
                if (InvoiceAjust > balance) {
                    alert("Adjusted amount cannot be greater than the balance.");
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
        

       <%-- debugger;
        function Approve() {
            debugger;
            var InvId = '<% =Request.QueryString["Inv_ID"] %>';
            PageMethods.ApprovePayment(InvId, function (Tests) {
                debugger
                var message = JSON.parse(Tests);
                if (message[0].Message != null || message[0].Message != "") {
                    alert(message[0].Message);
                    location.reload();
                }
            });
        }--%>
        debugger;
        function UnApprove() {
            var InvId = '<% =Request.QueryString["Inv_ID"] %>';
            PageMethods.UnApprovePayment(InvId, function (Tests) {
                debugger
                var message = JSON.parse(Tests);
                if (message[0].Column1 != "" || message[0].Column1 != null) {
                    alert(message[0].Column1);
                    location.reload();
                }
            });
        }
        debugger;
        function PrintVoucher() {
            debugger;
            var InvId = '<% =Request.QueryString["Inv_ID"] %>';
             var locationInfo = window.location;
             var url = '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=Payment Voucher&TransID=' + InvId + '&TransType=Pay';
             if (!locationInfo.origin.includes('localhost')) {
                 debugger;
                 var urlInfo = window.location.href.split('/');
                 var ip = urlInfo[2];
                 var foldername = urlInfo[3];
                 url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=Payment Voucher&TransID=' + InvId + '&TransType=Pay';
             }
             window.open(url, '_blank');
         }

         function sendFile(ID) {
             debugger;
             var fileInput = $('#chosePaymentfile')[0];
             if (fileInput.files.length > 0) {
                 debugger;
                 var data = new FormData();
                 data.append('file', $('#chosePaymentfile')[0].files[0]);
                 data.append('ID', ID);
                 $.ajax({
                     type: 'post',
                     url: '../UploadPaymentFiles.ashx',
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
             debugger;
             $.ajax({
                 type: "POST",
                 url: "AddPaymentInvoice.aspx/UserUnApproveEntryRights",
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


     </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <form id="item">
        <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label id="lb_PaymentNo" class="w115 fleft">Payment No</label>
                <input id="txt_PaymentNo" class="form-control" type="text" name="txt_PaymentNo" readonly="readonly" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label id="lb_PaymentMode" class="w115 fleft">Payment Mode<span style="color: red;">*</span></label>
                <select id="ddl_PaymentMode" class="form-control">
                    <option value="0">Please Select</option>
                </select>
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label id="lb_paymentDate" class="w115">Payment Date</label>
                <input id="txt_paymentDate" class="form-control" type="text" name="txt_paymentDate" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label id="lb_documentNo" class="w115">Document No</label>
                <input id="txt_documentNo" class="form-control" type="text" name="txt_documentNo" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label id="lb_DocumentDate">Document Date</label>
                <input id="txt_DocumentDate" class="form-control" type="text" name="" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-12">
                <label id="lb_bankCash" class="w115 fleft">Bank Cash<span style="color: red;">*</span></label>
                <select id="ddl_bankCash" class="form-control">
                    <option>Please Select</option>
                </select>
            </div>
        </div>
        <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label id="lb_venderName" class="w115 fleft">Vendor Name<span style="color: red;">*</span></label>
                <select id="ddl_venderName" class="form-control">
                    <option value="0">Please Select</option>
                </select>
            </div>
            <div class="col-lg-1 col-md-4 col-sm-6">
                <input style="margin-top:25px" type="button" id="btn_ManInv" name="" value="Add" class="btn btn-primry"  />
            </div>
            <div class="col-lg-1 col-md-4 col-sm-6">
                <label id="lb_invoiceAdjusted"> Adjusted</label>
                <input id="txt_invoiceAdjusted" class="form-control" type="text" name="txt_invoiceAdjusted" readonly="readonly" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label id="lb_PaidAmount">Paid Amnt</label>
                <input id="txt_PaidAmount" type="text" name="txt_PaidAmount" readonly="readonly" class="form-control" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label id="lb_WTaxAmount" class="w115">W Tax Amnt</label>
                <input id="txt_WTaxAmount" class="form-control" type="text" readonly="readonly" name="txt_WTaxAmount" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label id="Label1">Status</label>
                <input type="text" id="txtStatusid" readonly="readonly" class="form-control" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label id="lb_Attachments" class="w115 fleft">Attachments</label>
                <input id="chosePaymentfile" type="file" name="chosePaymentfile" />
                <asp:HyperLink ID="HyperLink1" runat="server">Download</asp:HyperLink>
            </div>
        </div>
        <div class="row">
            <div class="col-lg-10 col-md-10 col-sm-12">
                <label id="lb_remarks" >Remarks</label>
                <textarea id="txt_remarks" class="form-control"  name="txt_remarks" rows="2" cols="12"> </textarea>
            </div>
          
            
        </div>
    </form>


    <div class="row">
        <div class="" style="width: 100%; overflow: scroll;">
            <table class="table table-bordered" id="tblItemDescription">
                <thead>
                    <tr>
                        <th class="table_heading_color" style="width: 87px;">Invoice#</th>
                        <th class="table_heading_color" style="width: 114px;">Invoice Amt</th>
                        <th class="table_heading_color" style="width: 104px;">Advance Amt</th>
                        <%--<th class="table_heading_color" style="display: none;">SWHT Amt</th>--%>
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
                        <th class="table_heading_color" style="width: 101px;display:none !important;">SalTax</th>
                        <th class="table_heading_color" style="width: 134px;display:none !important;">SalTax Amt</th>
                        <th class="table_heading_color" style="width: 150px;">Paid Amount</th>
                        <th class="table_heading_color">Actions</th>
                    </tr>
                </thead>
                <tbody id="tblItemDescriptionDetail">
                </tbody>
            </table>
        </div>
    </div>
<div class="row" style="margin-top:1%">
         <div class="col-lg-6">
            <div class="row">
                    <div class="col-lg-2 col-md-4 col-sm-12">
            <input type="button" class="btn btn-primry" name="btnSave" id="btnSave" value="Save"  onclick="this.disabled = true;" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-12">
            <input type="button" class="btn-gray" value="List" onclick="window.location='PaymentInvoiceView.aspx'"  />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-12">
            <input type="button" class="btn btn-yellow" value="New" onclick="window.location='AddPaymentInvoice.aspx'"  />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-12">
            <input type="button" name="" id="btn_Print" value="Print" class="btn btn-primry" onclick="PrintPaymentDetail()" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-12">
            <input type="button" style="display: none" class="btn btn-primry" value="UnApprove" id="btnUnApprove" onclick="UnApprove()" />
    
        </div>
        <div class="col-lg-2 col-md-4 col-sm-12">
            <input type="button"  value="Voucher" class="btn btn-primry" id="btnVoucher" onclick="PrintVoucher()" />
        </div>
            </div>
        </div>
    </div>

    <div id="POItemsModel" class="modal fade" role="dialog">
        <div class="modal-dialog">
            <div class="modal-content" style="width: 1000px; margin-left: -270px; height: 505px;">
                <div class="modal-header">
                    <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Add Purchase Items </h4>
                </div>
                <input type="hidden" id="txthiddentr" name="txthidddentr" />
                <div style="width: 970px; overflow: scroll; height: 401px  !important; height: auto;">
                    <table class="table table-bordered" style="width: 953px; height: 0px !important; height: auto; overflow: scroll;" id="tblPOItemstModelTable">
                        <thead>
                            <tr>
                                <th style="width: 40px !important;">
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
</asp:Content>
