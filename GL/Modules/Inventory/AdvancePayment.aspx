<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdvancePayment.aspx.cs" Inherits="PMS.Inventory.AdvancePayment" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">



    <script type="text/javascript">
        $(document).ready(function () {
            UserRights();

            var $datepicker = $('#txtdate');

            $datepicker.datepicker({
                changeMonth: true,
                changeYear: true,
                yearRange: "-50:+50",
                dateFormat: "dd M yy"
            });

            var currentDate = $.datepicker.formatDate("dd M yy", new Date());
            $datepicker.val(currentDate);

            $('#ddl_withholdtax').prop('disabled', !$('#chkWHTax').is(':checked'));

            $('#chkWHTax').on('change', function () {
                $('#ddl_withholdtax').prop('disabled', !$(this).is(':checked'));
            });
            $('select').select2();
            FillVendors();
            Fillwtaxtype();
            FillPaidThrough();
    <% if (Request.QueryString["Adv_ID"] != null)
    { %>
        var Adv_ID = '<%= Request.QueryString["Adv_ID"]%>'
        loadadvancepayment(Adv_ID);
         <% } %>
        var Adv_ID = '<%= Request.QueryString["Adv_ID"]%>'
        if (Adv_ID == '') {
            GetnewAdvanceNo();
            $('#txt_status').val('Created');
        }
    });

    function PrintVoucher() {
        var InvId = '<% =Request.QueryString["Adv_ID"] %>';
        var locationInfo = window.location;

        var user_name = '<% =AppConfig.Company_Name %>';
        if (user_name == 'As-Siraat Serving Humanity') {
            reportPath = '../../ReportViewer.aspx';
        } else {
            reportPath = 'ReportViewer.aspx'; // same folder
        }

        var url = '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=Advance Payment Voucher&TransID=' + InvId + '&TransType=ADV';;
        if (!locationInfo.origin.includes('localhost')) {
            var urlInfo = window.location.href.split('/');
            var ip = urlInfo[2];
            var foldername = urlInfo[3];

            url = 'http://' + ip + '/' + foldername + '/' + reportPath +  '?ReportName=Voucher&ReportTitle=Advance Payment Voucher&TransID=' + InvId + '&TransType=ADV';
        }
        window.open(url, '_blank');
    }
    function Print() {
        var InvId = '<% =Request.QueryString["Adv_ID"] %>';
        var locationInfo = window.location;

        var user_name = '<% =AppConfig.Company_Name %>';
        if (user_name == 'As-Siraat Serving Humanity') {
            reportPath = '../../ReportViewer.aspx';
        } else {
            reportPath = 'ReportViewer.aspx'; // same folder
        }

        var url = '/ReportViewer.aspx?ReportName=Advance_Base_Print&ReportTitle=Advance Payment &Adv_ID=' + InvId;
        if (!locationInfo.origin.includes('localhost')) {
            var urlInfo = window.location.href.split('/');
            var ip = urlInfo[2];
            var foldername = urlInfo[3];

            url = 'http://' + ip + '/' + foldername + '/' + reportPath +  '?ReportName=Advance_Base_Print&ReportTitle=Advance Payment &Adv_ID=' + InvId;
        }
        window.open(url, '_blank');
    }
    function GetnewAdvanceNo() {
        PageMethods.GetnewAdvanceNumber(function (resp) {
            $('#advanceno').val(resp);
        },
            function (error) {
                alert(error.get_message());
            })
    }
    function Fillwtaxtype() {
      
        var optionsVen = '';
        PageMethods.getwtaxtype(function (Tests) {
            optionsVen = '<option value="0">Please Select</option>';
            $.each(JSON.parse(Tests), function (key, value) {
             
                optionsVen += '<option value="' + value.WithHold_Tax_ID + '" >' + value.WithHold_Tax_Perc + '</option>';
            });
            $('#ddl_withholdtax').html(optionsVen);
        });
    }
    function FillPaidThrough() {
   
        var optionsBnk = '';
        PageMethods.GetPaidThrough(function (Tests) {
    
            optionsBnk = '<option value="0">Please Select</option>';
            $.each(JSON.parse(Tests), function (key, value) {
               
                optionsBnk += '<option value="' + value.Account_ID + '" >' + value.name + '</option>';
            });
            $('#ddl_paidthrough').html(optionsBnk);
        });
    }
    function FillVendors() {
      
        PageMethods.getVendorDDLlist(function (Tests) {
           
            optionsVen = '<option value="0">Please Select</option>';
            $.each(JSON.parse(Tests), function (key, value) {
                optionsVen += '<option value="' + value.Vendor_ID + '" >' + value.Vendor_Name + '</option>';
            });
            $('#ddl_vendor').html(optionsVen);
        });
    }

    function LoadPOs() {
       
        var ddl_vendor = $("#ddl_vendor").val() || 0;
        if (ddl_vendor != '0') {
            FillPONumbers(ddl_vendor);
        }
        else {
            $('#ddl_PoNum').html('<option value="0">Please Select</option>');
        }
    }



    function FillPONumbers(vendorId) {
       
        $('#ddl_PoNum').empty();
        $('#ddl_PoNum').append('<option value="0">Please Select</option>');
        PageMethods.getPONumbersByVendor(vendorId, function (result) {
            var poList = JSON.parse(result);
            $.each(poList, function (key, value) {
                $('#ddl_PoNum').append('<option value="' + value.PO_ID + '">' + value.PO_No + '</option>');
            });
        });
    }

    function LoadPoAmount() {
      
        var PoId = $("#ddl_PoNum").val() || 0;
        if (PoId != '0') {
            PageMethods.getPOAmount(PoId, function (result) {
                var poData = JSON.parse(result);
                $('#txtPoAmount').val(poData.PO_Amount);
            });
        }
        else {
            $('#txtPoAmount').val(0);
        }
    }

    function calculatetax() {
        debugger;
        var taxperc = $('#ddl_withholdtax :selected').text().trim();
        if (taxperc === 'Please Select') {
            taxperc = 0;
        } else {
            taxperc = parseFloat(taxperc) || 0;
        }

        var txtPoAmount = parseFloat($('#txtPoAmount').val().replace(/,/g, '') || 0);
        var advance_amount = parseFloat($('#advance_amount').val().replace(/,/g, '') || 0);          

        if (advance_amount > txtPoAmount) {
            $('#advance_amount').val(0);
            Swal.fire({
                icon: 'error',
                title: 'Error!',
                text: 'Advance amount must be less than or equal to PO Amount.',
                showConfirmButton: false,
                timer: 2000,
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            });
            advance_amount = 0;
        }

        var balance = parseFloat(txtPoAmount - advance_amount).toFixed(2);
        var taxamount = advance_amount * taxperc / 100;
        var paidamount = advance_amount - taxamount;
        var total = taxamount + paidamount;

        $('#withhold_tax_amount').val(taxamount.toFixed(2));
        $('#txt_paidamount').val(paidamount.toFixed(2));
        $('#txtTotalAmount').val(total.toFixed(2));
        $('#txtbalance_amount').val(balance);
    }

    function SaveAllRecord() {
        debugger;
        $("#btn_Save").prop("disabled", true);
        debugger;
        var btnSave = $('#btn_Save').val();
        var advanceno = $('#advanceno').val();
        var txtdate = $('#txtdate').val();
        var advance_amount = $('#advance_amount').val();
        var ddl_vendor = $('#ddl_vendor').val() || 0;
        if (ddl_vendor == 0) {
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
            $("#btn_Save").prop("disabled", false);
            return false;
        }
        var PoID = $('#ddl_PoNum').val() || 0;
        if (PoID == 0) {
            Swal.fire({
                icon: 'error',
                title: 'Error!',
                text: 'Please Select PO',
                showConfirmButton: false,
                timer: 2000,
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            });
            $("#btn_Save").prop("disabled", false);
            return false;
        }
        var PoAmount = $('#txtPoAmount').val() || 0;
        if (PoAmount == 0) {
            Swal.fire({
                icon: 'error',
                title: 'Error!',
                text: 'Please Check PO and Its Amount',
                showConfirmButton: false,
                timer: 2000,
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            });
            $("#btn_Save").prop("disabled", false);
            return false;
        }
        debugger;
        var txtPoAmount = parseFloat(PoAmount);
        var advamt = parseFloat(advance_amount);
        var chkWHTax = $('#chkWHTax').prop('checked');

        if (advamt > txtPoAmount) {
            Swal.fire({
                icon: 'error',
                title: 'Error!',
                text: 'Please Advance Amount Must be Less Then or Equal to PO Amount',
                showConfirmButton: false,
                timer: 2000,
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            });
            $("#btn_Save").prop("disabled", false);
            return false;
        }
        var referno = $('#referno').val();
        var ddl_paidthrough = $('#ddl_paidthrough').val() || 0;
        if (ddl_paidthrough == 0) {
            Swal.fire({
                icon: 'error',
                title: 'Error!',
                text: 'Please Select Paid Through',
                showConfirmButton: false,
                timer: 2000,
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            });
            $("#btn_Save").prop("disabled", false);
            return false;
        }
        var ddl_withholdtax = $('#ddl_withholdtax').val();
        var withhold_tax_amount = $('#withhold_tax_amount').val() || 0;
        var txt_remarks = $('#txt_remarks').val();
        var txt_status = $('#txt_status').val();
        var txt_paidamount = $('#txt_paidamount').val() || 0;
        var balance_amount = $('#txtbalance_amount').val() || 0;
        var txtTotalAmount = $('#txtTotalAmount').val() || 0;
        $("#btn_Save").prop("disabled", true);
        var AllItemDetail = { 'advanceno': advanceno, 'txtdate': txtdate, 'ddl_vendor': ddl_vendor, 'PoID': PoID, 'PoAmount': PoAmount, 'balance_amount': balance_amount, 'referno': referno, 'ddl_paidthrough': ddl_paidthrough, 'advance_amount': advance_amount, 'ddl_withholdtax': ddl_withholdtax, 'withhold_tax_amount': withhold_tax_amount, 'txt_remarks': txt_remarks, 'txt_status': txt_status, 'txt_paidamount': txt_paidamount, 'txtTotalAmount': txtTotalAmount, 'chkWHTax': chkWHTax };
        PageMethods.SaveAdvancePayment(btnSave, JSON.stringify(AllItemDetail), function (res) {
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
            $('#btn_Save').val("Update");
            window.location = "AdvancePayment.aspx?Adv_ID=" + res;
            $('#btn_Save').val("Update");
        });
    }
    function loadadvancepayment(Adv_ID) {
        debugger;
        PageMethods.loadadvanceheader(Adv_ID, function (resp) {
            debugger;
            var data = JSON.parse(resp);
            debugger;
            var txtdate = $.datepicker.formatDate('dd M yy', new Date(parseInt(data.Date.substring(6, 19))));
            $('#txtdate').val(txtdate);
            $('#advanceno').val(data.Advance_No);
            $('#txtTotalAmount').val(data.Total_amount);
            $('#referno').val(data.Refer_No);
            $('#advance_amount').val(data.Actual_Advance_Amount);
            $('#withhold_tax_amount').val(data.WithHoldTax_Amount);
            setTimeout(function () {
                $('#ddl_vendor').val(data.Vendor_ID).trigger('change');
                FillPONumbers(data.Vendor_ID);
                $('#ddl_paidthrough').val(data.Paid_Through).trigger('change');
            }, 2500);
            if (data.WithHoldTax_Check == true) {
                $("#chkWHTax").prop('checked', true);
            }
            setTimeout(function () {
                $('#ddl_PoNum').val(data.Po_Id).trigger('change');
            }, 3000);
            setTimeout(function () {
                $('#ddl_withholdtax').val(data.WithHoldTax_Perc).trigger('change');
            }, 4000);
            $('#txt_remarks').val(data.Remarks);
            $('#txt_status').val(data.Status);
            var checkstatus = $('#txt_status').val();
            if (checkstatus == 'Approved') {
                $("#btn_Save").prop("disabled", true);
                $('#btn_Save').hide();
            }
            if (checkstatus == 'Created' || checkstatus == 'Pending') {
                $("#btnVoucher").prop("disabled", true);
                $('#btnVoucher').hide();
                if (Adv_ID != '') {
                    CheckADVANCEApprovalRightsAndShowButton(Adv_ID);
                }
            }
            $('#btn_Save').val("Update");

        },
            function (error) {
                alert(error.get_message());
            })
    }
    function callPageMethod(methodName, params, successCallback, errorCallback) {
        if (typeof params === 'function') {
            errorCallback = successCallback;
            successCallback = params;
            params = {};
        }
        $.ajax({
            type: "POST",
            url: "AdvancePayment.aspx/" + methodName,
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
        debugger;
        $.ajax({
            type: "POST",
            url: "AdvancePayment.aspx/UserEntryRights",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                debugger;
                var hasRights = response.d;
                debugger;
                if (hasRights) {
                    debugger;
                    $('#btn_Save').show();
                } else {
                    $('#btn_Save').hide();
                }
            },
            failure: function (response) {
                alert("Failed to retrieve user rights.");
            }
        });
    }
    <%--function Approve() {
        debugger;
        var AdvID = '<% =Request.QueryString["Adv_ID"] %>';
        PageMethods.ApprovePayment(AdvID, function (Tests) {
            debugger
            var message = JSON.parse(Tests);
            if (message[0].Message != null || message[0].Message != "") {
                alert(message[0].Message);
                location.reload();
            }
        });
    }
    function UnApprove() {
        debugger;
        var AdvID = '<% =Request.QueryString["Adv_ID"] %>';
        PageMethods.UnApprovePayment(AdvID, function (Tests) {
            debugger
            var message = JSON.parse(Tests);
            if (message[0].Column1 != "" || message[0].Column1 != null) {
                alert(message[0].Column1);
                location.reload();
            }
        });
    }--%>
        function CheckADVANCEApprovalRightsAndShowButton(advId) {
            callPageMethod('CheckADVANCEApprovalRights', function (hasRights) {
                if (hasRights) {
                    callPageMethod('GetADVANCEApprovalInfo', { AdvId: advId }, function (resp) {
                        var info = JSON.parse(resp);
                        if (info.CanApprove) {
                            $('#btnApproveAdv').show();
                            $('#btnApproveAdv').data('adv-amount', info.Amount);
                        }
                    });
                }
            });
        }
        function ApproveADVANCEFromEdit() {
            var advId = '<% =Request.QueryString["Adv_ID"] %>';
            var amount = $('#btnApproveAdv').data('adv-amount');
            var confirmHtml = 'Are you sure you want to approve Advance Payment #' + $('#advanceno').val() + '?';
            if (amount > 0) {
                confirmHtml += '<br><br>Advance Amount: <strong>' + parseFloat(amount).toFixed(2) + '</strong>';
            }
            Swal.fire({
                title: 'Approve Advance Payment?',
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
                    callPageMethod('ApproveSingleADVANCE', { AdvId: advId, approvalRemarks: remarks }, function (resp) {
                        if (resp === "Success") {
                            Swal.fire({ icon: 'success', title: 'Approved!', text: 'Advance Payment has been approved successfully.', showConfirmButton: false, timer: 2000, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } }).then(function () { location.reload(); });
                        } else {
                            Swal.fire({ icon: 'error', title: 'Error', text: resp, showConfirmButton: true, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } }).then(function () { location.reload(); });
                        }
                    });
                }
            });
        }
        function sendFile(ID) {
            debugger;
            var fileInput = $('#choseAdPaymentfile')[0];
            if (fileInput.files.length > 0) {
                debugger;
                var data = new FormData();
                data.append('file', $('#choseAdPaymentfile')[0].files[0]);
                data.append('ID', ID);
                $.ajax({
                    type: 'post',
                    url: '../UploadAdvancePaymentFiles.ashx',
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
        function toggle(source) {
            var checkboxes = document.querySelectorAll('input[type="checkbox"]');
            for (var i = 0; i < checkboxes.length; i++) {
                if (checkboxes[i] != source)
                    checkboxes[i].checked = source.checked;
            }
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <form id="item">
        <div class="row">
            <div class="col-lg-2 col-md-3 col-sm-4">
                <label>Advance No</label>
                <input type="text" id="advanceno" class="form-control" readonly="readonly" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4">
                <label>Date</label>
                <input type="text" name="txt_Date" id="txtdate" class="form-control" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4">
                <label>Vendor</label>
                <select id="ddl_vendor" onchange="LoadPOs()" class="form-control">
                </select>
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4">
                <label>PO #</label>
                <select id="ddl_PoNum" onchange="LoadPoAmount()" class="form-control">
                </select>
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4">
                <label>PO Amount</label>
                <input type="text" id="txtPoAmount" readonly="readonly" class="form-control" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4">
                <label>Ref No</label>
                <input type="text" id="referno" class="form-control" />
            </div>

        </div>
        <br />
        <div class="row">

            <div class="col-lg-2 col-md-3 col-sm-4">
                <label>Paid Through</label>
                <select id="ddl_paidthrough" class="form-control" name="ddl_paidthrough"></select>
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4">
                <label>Advance Amount</label>
                <input type="text" id="advance_amount" class="form-control" onkeyup="calculatetax()" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4">
                <label>Balance Amount</label>
                <input type="text" id="txtbalance_amount" readonly="readonly" class="form-control" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4">
                <label>With Holding Tax</label>
                <input type="checkbox" id="chkWHTax" style="width: 15px ! important;height: 15px !important;" />               
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4">
                <label>With Holding Tax</label>
                <select id="ddl_withholdtax" class="form-control" onchange="calculatetax()">
                </select>
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4">
                <label>With Holding Tax Amount</label>
                <input type="text" id="withhold_tax_amount" readonly="readonly" class="form-control" />
            </div>


        </div>
        <br />
        <div class="row">
            <div class="col-lg-2 col-md-3 col-sm-4">
                <label>Paid Amount</label>
                <input type="text" readonly="readonly" name="txt_paidamount" id="txt_paidamount" class="form-control" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4">
                <label>Total  Amount </label>
                <input type="text" readonly="readonly" name="txtTotalAmount" id="txtTotalAmount" class="form-control" />
            </div>
            <div class="col-lg-4 col-md-3 col-sm-4">
                <label>Remarks</label>
                <textarea id="txt_remarks" style="width: 100% !important;height: 36px !important"></textarea>
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4">
                <label>Status</label>
                <input type="text" readonly="readonly" name="txt_status" id="txt_status" class="form-control" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4">
                <label>Attachments</label>
                <input type="file" id="choseAdPaymentfile" name="choseAdPaymentfile" style="height: 30px !important" />
                <asp:HyperLink ID="HyperLink1" runat="server">Download</asp:HyperLink>
            </div>
        </div>
    </form>
    <br />
    <div class="row">
        <div class="col-lg-8">
            <div class="row">
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" name="btn_Save" id="btn_Save" class="btn btn-primry" value="Save" onclick="SaveAllRecord()" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" name="btnList" id="btnList" class="btn btn-yellow" value="List" onclick="location.href = 'AdvancePaymentView.aspx';" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" name="btnAdd" id="btnAdd" class="btn btn-yellow" value="New" onclick="location.href = 'AdvancePayment.aspx';" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button"  value="Voucher" class="btn btn-yellow" id="btnVoucher" onclick="PrintVoucher()" title="Voucher" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" style="display: none" class="btn btn-primry" value="Approve" id="btnApproveAdv" onclick="ApproveADVANCEFromEdit()" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button"  value="Print" class="btn btn-primry" id="btnPrint" onclick="Print()" title="Print" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>
