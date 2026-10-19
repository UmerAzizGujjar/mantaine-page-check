<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AddManualInvoice.aspx.cs" Inherits="PMS.Inventory.AddManualInvoice" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

        <script type="text/javascript">
            //For Check all
            function toggle(source) {
                var checkboxes = document.querySelectorAll('input[type="checkbox"]');
                for (var i = 0; i < checkboxes.length; i++) {
                    if (checkboxes[i] != source)
                        checkboxes[i].checked = source.checked;
                }
            }
            $(document).ready(function () {
                Fillwtaxtype();
                UserRights();
                var currentDate = new Date();
                var formattedDate = $.datepicker.formatDate('dd M yy', currentDate);
                $("#txt_Date").datepicker({ dateFormat: 'dd M yy', changeMonth: true, changeYear: true, yearRange: "-50:+50" }).attr('readonly', false);
                $("#txt_Date").val(formattedDate);
                $('#ddl_Supplier').select2();
                $('#tblddl_AccountCode').select2();
                $('#').select2();
                FillVendors();
        <% if (Request.QueryString["Inv_ID"] != null)
        { %>
            var Inv_ID = '<%= Request.QueryString["Inv_ID"]%>'
            $('#btn_Save').val('Update');
            LoadInvoiceData(Inv_ID);
            <%}
        else
        { %>
         <%}%>
            var Inv_ID = '<%= Request.QueryString["Inv_ID"]%>'
            if (Inv_ID == '') {
                $('#btn_Print').hide();
                $('#btnVoucher').hide();
            }
            setTimeout(function () {
                var status = $('#txt_Status').val();
                if (status == "Deleted") {
                    $('#btn_Save').hide();
                    $('#btnVoucher').hide();
                }
                if (status == "Approved") {
                    UserUnApproveButtonRights();
                    $('#btn_Save').attr("disabled", true);
                    $('#btnVoucher').show();
                }
                if (status == "Created" || status == "Pending") {
                    $('#btnVoucher').hide();
                    if (Inv_ID != '') {
                        CheckMIApprovalRightsAndShowButton(Inv_ID);
                    }
                }
            }, 1000);
        });
        function callPageMethod(methodName, params, successCallback, errorCallback) {
            if (typeof params === 'function') {
                errorCallback = successCallback;
                successCallback = params;
                params = {};
            }
            $.ajax({
                type: "POST",
                url: "AddManualInvoice.aspx/" + methodName,
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
                url: "AddManualInvoice.aspx/UserEntryRights",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var hasRights = response.d;
                    if (hasRights) {
                        $('#btn_Save').show();
                    } else {
                        $('#btn_Save').hide();
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
      
        function UnApprove() {
            var InvId = '<% =Request.QueryString["Inv_ID"] %>';
           PageMethods.UnApproveManualInvoice(InvId, function (Tests) {
               var message = JSON.parse(Tests);
               if (message[0].Column1 != "" || message[0].Column1 != null) {
                   alert(message[0].Column1);
                   location.reload();
               }
           });
        }
        function CheckMIApprovalRightsAndShowButton(invId) {
            callPageMethod('CheckMIApprovalRights', function (hasRights) {
                if (hasRights) {
                    callPageMethod('GetMIApprovalInfo', { InvId: invId }, function (resp) {
                        var info = JSON.parse(resp);
                        if (info.CanApprove) {
                            $('#btn_Approve').show();
                            $('#btn_Approve').data('mi-amount', info.Amount);
                        }
                    });
                }
            });
        }
        function ApproveMIFromEdit() {
            var invId = '<% =Request.QueryString["Inv_ID"] %>';
            var amount = $('#btn_Approve').data('mi-amount');
            var confirmHtml = 'Are you sure you want to approve Manual Invoice #' + $('#txt_Invoice').val() + '?';
            if (amount > 0) {
                confirmHtml += '<br><br>Invoice Amount: <strong>' + parseFloat(amount).toFixed(2) + '</strong>';
            }
            Swal.fire({
                title: 'Approve Manual Invoice?',
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
                    callPageMethod('ApproveSingleMI', { InvId: invId, approvalRemarks: remarks }, function (resp) {
                        if (resp === "Success") {
                            Swal.fire({ icon: 'success', title: 'Approved!', text: 'Manual Invoice has been approved successfully.', showConfirmButton: false, timer: 2000, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } }).then(function () { location.reload(); });
                        } else {
                            Swal.fire({ icon: 'error', title: 'Error', text: resp, showConfirmButton: true, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } }).then(function () { location.reload(); });
                        }
                    });
                }
            });
        }
        function PrintVoucher() {
            var id = '<% =Request.QueryString["Inv_ID"] %>';
                var locationInfo = window.location;
            var user_name = '<% =AppConfig.Company_Name %>';
            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx'; // same folder
            }
                var url = '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=MIN Voucher&TransID=' + id + '&TransType=MIN';
                if (!locationInfo.origin.includes('localhost')) {
                    var urlInfo = window.location.href.split('/');
                    var ip = urlInfo[2];
                    var foldername = urlInfo[3];

                    url = 'http://' + ip + '/' + foldername + '/' + reportPath +  '?ReportName=Voucher&ReportTitle=MIN Voucher&TransID=' + id + '&TransType=MIN';
                }
                window.open(url, '_blank');
            }
            function GetNewInvNo() {
                PageMethods.GetNewInvNo(function (resp) {
                    $('#txt_Invoice').val(resp);
                },
                    function (error) {
                        alert(error.get_message());
                    })
            }
            function FillVendors() {
                var optionsVen = '';
                PageMethods.getVendorDDLlist(function (Tests) {
                    optionsVen = '<option value="0">Please Select</option>';
                    $.each(JSON.parse(Tests), function (key, value) {
                        if (value.Active == true) {
                            optionsVen += '<option value="' + value.VendorID + '" >' + value.VendorName + '</option>';
                        }
                        else {
                            optionsVen += '<option value="' + value.VendorID + '"  disabled>' + value.VendorName + '</option>';
                        }
                    });
                    $('#ddl_Supplier').html(optionsVen);
                });
            }
            function Addrow() {
                var rows = '';
                var rowlength = tblItemDescription.rows.length;
                rows += '<tr>' +
                    '<td class="th_Sp_Color">' + '<select name="tblddl_AccountCode" id="tblddl_AccountCode' + rowlength + '"></select>' +
                    '</td>' +
                    '<td class="th_Sp_Color">' +
                    '<input type="text" name="tbltxt_Description" id="tbltxt_Description' + rowlength + '"/>' +
                    '</td>' +
                    '<td class="th_Sp_Color">' +
                    '<select name="tblddl_Department" id="tblddl_Department' + rowlength + '" style="width: 112px!important;">' +
                    '<option>Please Select </option>' +
                    '</select>' +
                    '</td>' +
                    '<td class="th_Sp_Color">' +
                    '<input type="text" name="tbltxt_Qty" id="tbltxt_Qty' + rowlength + '" style="width: 50px!important;"/>' +
                    '</td>' +
                    '<td class="th_Sp_Color">' +
                    '<input type="text" name="tbltxt_Rate" style="width: 150px!important;text-align: right;" id="tbltxt_Rate' + rowlength + '" onchange="calcutaeAmount(this)"/>' +
                    '</td>' +
                    '<td class="th_Sp_Color">' +
                    '<select name="ddlstax" style="width: 112px!important;" id="ddlstax' + rowlength + '" onchange="calcutaeAmount(this)">' + _gloabal + ' </select></td>' +
                    '<td class="th_Sp_Color">' +
                    '<input type="text" readonly="readonly" style="width: 73px!important;text-align: right" name="stamount" id="stamount' + rowlength + '"/>' +
                    '</td>' +
                    '<td class="th_Sp_Color">' +
                    '<input type="text" name="tbltxt_TotalAmount" style="width: 129px!important;text-align: right" id="tbltxt_TotalAmount' + rowlength + '" readonly="readonly"/>' +
                    '</td>' +
                    '<td class="th_Sp_Color">' +
                    '<a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="width:15px !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a></td>' +
                    '</tr>'
                $('#tblItemDescriptionDetail').append(rows);
                $('input').attr('autocomplete', 'off');
                loadItemList(rowlength);
            }
            function validateSave() {
                var proceed = true;
                var table = $('#tblItemDescriptionDetail');
                var Vendor = $('#ddl_Supplier').val();
                if (Vendor == '0') {
                    $("#ddl_Supplier").addClass('ErrorAlert');
                    $('#select2-ddl_Supplier-container').parent().css('border-color', 'red');
                    proceed = false;
                }
                else {
                    $("#ddl_Supplier").removeClass('ErrorAlert');
                    $('#select2-ddl_Supplier-container').parent().css('border-color', ' rgb(206, 191, 191)');
                }
                var tblLength = $("#tblItemDescription tr:gt(0)").length;
                if (tblLength == '0') {
                    $('#tblItemDescription').addClass('ErrorAlert');
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Add Vendor',
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
                    table.find('tr').each(function (key, value) {
                        var AccountId = $(value).find('td select[name=tblddl_AccountCode]').val();
                        var QTy = $(value).find('td input[name=tbltxt_Qty]').val();
                        var Rate = $(value).find('td input[name=tbltxt_Rate]').val();

                        if (AccountId == "0" || AccountId == "") {
                            proceed = false;
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'Please Select Account',
                                showConfirmButton: false,
                                timer: 2000,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });
                        }
                        else if (QTy == "0" || QTy < 0 || QTy == "") {
                            proceed = false;
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'QTY must be greater than 0',
                                showConfirmButton: false,
                                timer: 2000,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });

                        }
                        else if (Rate == "0" || Rate < 0 || Rate == "") {
                            proceed = false;
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'Rate must be greater than 0',
                                showConfirmButton: false,
                                timer: 2000,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });
                        }
                        else {
                            proceed = true;
                        }
                    });
                }
                return proceed;
            }
            function calcutaeAmount() {
                var TotalAmount = 0;
                $.each($('#tblItemDescription tbody tr'), function (key, value) {
                    var Qty = $($(value).find('td input[name=tbltxt_Qty]')[0]).val();
                    var Rate = $($(value).find('td input[name=tbltxt_Rate]')[0]).val();
                    var stvalue = $(value).find('td select[name=ddlstax] :selected').text();
                    if (stvalue.includes('Please Select')) {
                        stvalue = 0;
                    }
                    var totalAmount = Qty * Rate;
                    var calsaltax = (stvalue / 100) * totalAmount;
                    $('#stamount' + (key + 1)).val(calsaltax);
                    var checkstperc = $(value).find('td select[name=ddlstax] :selected').val();
                    if (checkstperc == 0) {
                        $('#tbltxt_TotalAmount' + (key + 1)).val(totalAmount);
                    }
                    var totalfinalamount = totalAmount + calsaltax;
                    var checkstamou = $($(value).find('td input[name=stamount]')[0]).val();
                    if (checkstamou == "NaN") {
                        var val2 = 0;
                        $(this).find('input[name=stamount]').val(val2);
                    }
                    $('#tbltxt_TotalAmount' + (key + 1)).val(totalfinalamount);
                    TotalAmount += parseFloat(totalfinalamount);
                });
                $('input[name=txt_GrandTotal]').val(TotalAmount);
            }
            function SaveAllRecord() {
                if (validateSave()) {
                    var btnSave = $('#btn_Save').val();
                    var InvoiceNum = $('#txt_Invoice').val();
                    var Date = $('#txt_Date').val();
                    var VendorId = $('#ddl_Supplier').val();
                    var RefInvoiceNumber = $('#txt_RefInvoice_Number').val();
                    var Remarks = $('#txtRemarks').val();
                    var table = $('#tblItemDescriptionDetail');
                    var Item_list = [];
                    table.find('tr').each(function (key, value) {
                        Item_list.push({
                            'AccountId': $(value).find('td select[name=tblddl_AccountCode]').val(),
                            'Description': $(value).find('td input[name=tbltxt_Description]').val(),
                            'DepartmentId': $(value).find('td select[name=tblddl_Department]').val(),
                            'Qty': $(value).find('td input[name=tbltxt_Qty]').val(),
                            'Rate': $(value).find('td input[name=tbltxt_Rate]').val(),
                            'ddlstax': $(value).find('td select[name=ddlstax]').val(),
                            'stamount': $(value).find('td input[name=stamount]').val(),
                            'TotalAmount': $(value).find('td input[name=tbltxt_TotalAmount]').val()
                        });
                    });
                    var AllItemDetail = { 'Invoice_num': InvoiceNum, 'Date': Date, 'VendorId': VendorId, 'RefInvoicenum': RefInvoiceNumber, 'Remarks': Remarks, 'ItemList': Item_list };
                    PageMethods.SaveInvoice(btnSave, JSON.stringify(AllItemDetail), function (res) {
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

                        $('#btn_Save').val("Update");
                        window.location = 'AddManualInvoice.aspx?Inv_ID=' + res;
                    });
                }
            }
            function LoadInvoiceData(Inv_ID) {
                PageMethods.LoadManualInvoiceHeaderDetail(Inv_ID, function (resp) {
                    var data = JSON.parse(resp);

                    var datetime = $.datepicker.formatDate('dd M yy', new Date(parseInt(data.ManualInvoiceDate.substring(6, 19))))
                    $('#txt_Date').val(datetime);
                    setTimeout(function () {
                        $('#ddl_Supplier').val(data.VendorId).trigger('change');
                    }, 1000);
                    $('#txt_Invoice').val(data.ManualInvoiceNum);
                    $('#txt_RefInvoice_Number').val(data.RefInvoiceNum);
                    $('#txtRemarks').val(data.Remarks);
                    $('#txt_Status').val(data.Status);
                    var checkstatusss = $('#txt_Status').val();
                    if (checkstatusss == 'Approved') {
                        $('#btn_Save').hide();
                    }
                    LoadInvocieDetail(Inv_ID);
                },
                    function (error) {
                        alert(error.get_message());
                    })
            }

            var rowsoneditmode = '';
            function LoadInvocieDetail(Inv_ID) {
                var rows = '';
                var TotalAmount = 0;
                PageMethods.LoadInvocieDetail(Inv_ID, function (resp) {
                    var data = (JSON.parse(resp));
                    selectedOptions = data;
                    var rowIndex = parseInt((parseInt($('#tblItemDescriptionDetail tbody tr').length)));
                    $.each(data, function (key, value) {
                        rows += '<tr>' +
                            '<td class="th_Sp_Color">' +
                            '<select name="tblddl_AccountCode" id="tblddl_AccountCode' + +(key + 1) + '"></select>' +
                            '</td>' +
                            '<td class="th_Sp_Color">' +
                            '<input type="text" name="tbltxt_Description" id="tbltxt_Description' + (key + 1) + '"  value="' + value.Description + '"/>' +
                            '</td>' +
                            '<td class="th_Sp_Color">' +
                            '<select name="tblddl_Department" style="width: 100px!important;" id="tblddl_Department' + (key + 1) + '">' +
                            '<option>Please Select </option>' +
                            '</select>' +
                            '</td>' +
                            '<td class="th_Sp_Color">' +
                            '<input type="text" name="tbltxt_Qty" style="width: 50px!important;" id="tbltxt_Qty' + (key + 1) + '"  value="' + value.Qty + '"/>' +
                            '</td>' +
                            '<td class="th_Sp_Color">' +
                            '<input type="text" name="tbltxt_Rate"  style="width: 150px!important;text-align: right" id="tbltxt_Rate' + (key + 1) + '" onchange="calcutaeAmount(this) "  value="' + value.Rate + '"/>' +
                            '</td>' +
                            '<td class="th_Sp_Color">' +
                            '<select name="ddlstax"  style="width: 95px!important;" id="ddlstax' + +(key + 1) + '">' + _gloabal + ' </select></td>' +
                            '<td class="th_Sp_Color">' +
                            '<input type="text" name="stamount" style="width: 73px!important;text-align: right" id="stamount' + (key + 1) + '" readonly="readonly"  value="' + value.SalTax_Percentage + '"/>' +
                            '</td>' +
                            '<td class="th_Sp_Color">' +
                            '<input type="text" name="tbltxt_TotalAmount" style="width: 129px!important;text-align: right" id="tbltxt_TotalAmount' + (key + 1) + '" readonly="readonly"  value="' + value.TotalAmount + '"/>' +
                            '</td>' +
                            '<td class="th_Sp_Color">' +
                            '<a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="width:15px !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a></td>' +
                            '</tr>'
                        TotalAmount += value.TotalAmount;
                    });
                    $('#tblItemDescriptionDetail').append(rows);
                    $('input').attr('autocomplete', 'off');
                    rowsoneditmode = tblItemDescriptionDetail.rows.length;
                    $('input[name=txt_GrandTotal]').val(TotalAmount);
                    $.each(selectedOptions, function (key, value) {
                        loadItemList(key + 1);
                        setTimeout(function () {
                            $('#tblddl_AccountCode' + (key + 1)).val(value.AccountId).trigger('change');
                        }, 1000);
                        setTimeout(function () {
                            $('#tblddl_Department' + (key + 1)).val(value.DepartmentId);
                        }, 1000);
                        setTimeout(function () {
                            $('#ddlstax' + (key + 1)).val(value.SalTax_Id);
                        }, 1000);
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
            function loadItemList(rowlength) {
                var length = rowlength;
                $('#tblddl_AccountCode' + length + '').select2();
                PageMethods.loadAccountList(function (resp) {
                    optionsitem = '<option value="0">Please Select</option>';
                    $.each(JSON.parse(resp), function (key, value) {
                        optionsitem += '<option value="' + value.Account_ID + '" >' + value.name + '</option>';
                    });
                    $('#tblddl_AccountCode' + length + '').html(optionsitem);
                },
                    function (error) {
                        alert(error.get_message());
                    });
                var optionsDPT = '';
                var optionInv = '';
                PageMethods.getDDLlist(function (Tests) {
                    optionsDPT = '<option value="0">Please Select</option>';
                    optionInv = '<option value="0">Please Select</option>';
                    $.each(JSON.parse(Tests), function (key, value) {
                        if (value.Type == "DPT") {
                            optionsDPT += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                        }
                        else {
                            optionInv += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                        }
                    });
                    $('#tblddl_Department' + length + '').html(optionsDPT);
                });
            }
            var _gloabal = '';
            function Fillwtaxtype() {
                var optionsVen = '';
                PageMethods.getwtaxtype(function (Tests) {
                    optionsVen = '<option value="0">Please Select</option>';
                    $.each(JSON.parse(Tests), function (key, value) {
                        optionsVen += '<option value="' + value.Sales_Tax_ID + '" >' + value.Sales_Tax_Perc + '</option>';
                    });
                    _gloabal = optionsVen;
                });
            }

            function UserUnApproveButtonRights() {
                $.ajax({
                    type: "POST",
                    url: "AddManualInvoice.aspx/UserUnApproveEntryRights",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        var hasRights = response.d;
                        if (hasRights) {
                            $('#btn_UnApprove').show();
                        } else {
                            $('#btn_UnApprove').hide();
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
                var fileInput = $('#choseMIfile')[0];
                if (fileInput.files.length > 0) {
                    var data = new FormData();
                    data.append('file', $('#choseMIfile')[0].files[0]);
                    data.append('ID', ID);
                    $.ajax({
                        type: 'post',
                        url: '../../UploadMIFiles.ashx',
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

        </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label id="lb_Invoice">Invoice# </label>            
            <input type="text" name="txt_Invoice" id="txt_Invoice" value="New" readonly="readonly" />        
        </div>

        <div class="col-lg-2 col-md-4 col-sm-6">          
            <label id="lb_Date">Date</label>  
            <input type="text" name="txt_Date" id="txt_Date" />           
        </div>

        <div class="col-lg-2 col-md-4 col-sm-6">      
            <label id="lb_InvoiceRefNo">Ref Invoice# </label>
            <input type="text" id="txt_RefInvoice_Number" name="txt_RefInvoice_Number" />       
        </div>

        <div class="col-lg-2 col-md-4 col-sm-6">
            <label id="lb_Supplier" style="display: block">Vendor<span style="color: red;">*</span></label>
            <select name="ddl_Supplier" id="ddl_Supplier" class="form-control"></select>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label id="lb_Status">Status</label>
            <input type="text" readonly="readonly" id="txt_Status" name="txt_Status" />
        </div>
                <div class=" col-lg-2 col-md-4 col-sm-6 mb-3">
                    <label class="col-form-label">Attachment</label>
                    <input type="file" id="choseMIfile" name="choseMIfile" />
                    <asp:HyperLink ID="HyperLink1" runat="server">Download</asp:HyperLink>
                </div>
    </div>


    <div class="row" style="margin-top: 5px;">
        <div class="col-lg-4 col-md-6 col-sm-8">
            <label id="lb_Remarks">Remarks</label>
            <textarea cols="2" rows="1" style="width: 100%" id="txtRemarks" name="txtRemarks"></textarea>
        </div>
        <div class="col-lg-1 col-md-6 col-sm-6">
            <input type="button" class="btn btn-primry" onclick="Addrow()" value="+" id="AddAccount" style="margin-top: 26px !important" />
        </div>
    </div>

    <div >
        <table class="table table-bordered" id="tblItemDescription" style="text-align: center;">
            <thead>
                <tr>
                    <th>Account Code</th>
                    <th >Description</th>
                    <th >Department</th>
                    <th >Qty</th>
                    <th >Rate</th>
                    <th >S.Tax%</th>
                    <th >ST Amnt</th>
                    <th >Total Amnt</th>
                    <th >Remove</th>
                </tr>
            </thead>
            <tbody id="tblItemDescriptionDetail">
            </tbody>
        </table>
    </div>
    
    <div class="row">
        <div class="col-lg-6">
            <div class="row">
           <div class="col-lg-2 col-md-3">
            <input type="button" class="btn btn-primry" name="btn_Save" id="btn_Save" value="Save" onclick="SaveAllRecord()" />
            <input type="button" name="btn_Print" id="btn_Print" value="Print" style="display: none" />
           </div>
            <div class="col-lg-2 col-md-3">
                <input type="button" class="btn-gray" name="btn_listView" id="btn_listView" value="List view" onclick="window.location = 'ManualInvoiceList.aspx'" />
            </div>
            <div class="col-lg-2 col-md-3">
                <input type="button" name="btn_New" class="btn btn-yellow" id="btn_New" value="New" onclick="window.location = 'AddManualInvoice.aspx'" />
            </div>
            <div class="col-lg-2 col-md-3">
                <input type="button" class="btn btn-primry" value="Voucher" id="btnVoucher" onclick="PrintVoucher()" />
            </div>
             <div class="col-lg-2 col-md-3">
            <input type="button" name="btn_Approve" class="btn btn-primry" id="btn_Approve" style="display: none" value="Approve" onclick="ApproveMIFromEdit()" />
             <input type="button" name="btn_UnApprove" class="btn btn-primry" id="btn_UnApprove" style="display: none" value="UnApprove" onclick="UnApprove()" />
        </div>
            </div>
            </div>
    </div>
    <div class="row">
         <div class="col-md-2 col-lg-10"></div>
        <div class="col-md-2 col-lg-2" style="margin-top: 5px;">
            <label id="lb_GrandTotal">Grand Total</label>
            <input type="text" readonly="readonly" id="txt_GrandTotal" name="txt_GrandTotal" style="text-align: right;" />
        </div>
    </div>
</asp:Content>
