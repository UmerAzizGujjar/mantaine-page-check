<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdvancePayment.aspx.cs" Inherits="PMS.Inventory.AdvancePayment" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">



    <script type="text/javascript">
        $(document).ready(function () {
            UserRights();
            var currentDate = new Date();
            var formattedDate = $.datepicker.formatDate('dd M yy', currentDate);
            $("#txtdate").val(formattedDate).datepicker({ dateFormat: 'dd M yy', readOnly: true });
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


            }
        });

        function PrintVoucher() {
            var InvId = '<% =Request.QueryString["Adv_ID"] %>';
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=Advance Payment Voucher&TransID=' + InvId + '&TransType=ADV';;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];

                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=Advance Payment Voucher&TransID=' + InvId + '&TransType=ADV';
            }
            window.open(url, '_blank');
        }
        function Print() {
            var InvId = '<% =Request.QueryString["Adv_ID"] %>';
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=Advance_Base_Print&ReportTitle=Advance Payment &Adv_ID=' + InvId;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];

                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=Advance_Base_Print&ReportTitle=Advance Payment &Adv_ID=' + InvId;
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
            debugger;
            var optionsVen = '';
            PageMethods.getwtaxtype(function (Tests) {
                optionsVen = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    debugger;
                    optionsVen += '<option value="' + value.WithHold_Tax_ID + '" >' + value.WithHold_Tax_Perc + '</option>';
                });
                $('#ddl_withholdtax').html(optionsVen);
            });
        }
        function FillPaidThrough() {
            debugger;
            var optionsBnk = '';
            PageMethods.GetPaidThrough(function (Tests) {
                debugger
                optionsBnk = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    debugger;
                    optionsBnk += '<option value="' + value.Account_ID + '" >' + value.name + '</option>';
                });
                $('#ddl_paidthrough').html(optionsBnk);
            });
        }
        function FillVendors() {
            debugger;
            PageMethods.getVendorDDLlist(function (Tests) {
                debugger
                optionsVen = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    optionsVen += '<option value="' + value.Vendor_ID + '" >' + value.Vendor_Name + '</option>';
                });
                $('#ddl_vendor').html(optionsVen);
            });
        }
        function calculatetax() {
            debugger;
            var taxperc = $('#ddl_withholdtax :selected').text();
            if (taxperc == 'Please Select') {
                taxperc = 0;
            }
            var amount = $('#advance_amount').val();
            var taxamount = amount * taxperc / 100;
            var paidamount = amount - taxamount;
            var total = taxamount + paidamount;
            $('#withhold_tax_amount').val(taxamount);
            $('#txt_paidamount').val(paidamount);
            $('#txtTotalAmount').val(total);


        }
        function SaveAllRecord() {
            debugger;
            var btnSave = $('#btn_Save').val();
            var advanceno = $('#advanceno').val();
            var txtdate = $('#txtdate').val();
            var ddl_vendor = $('#ddl_vendor').val();
            var referno = $('#referno').val();
            var ddl_paidthrough = $('#ddl_paidthrough').val();
            var advance_amount = $('#advance_amount').val();
            var ddl_withholdtax = $('#ddl_withholdtax').val();
            var withhold_tax_amount = $('#withhold_tax_amount').val();
            var txt_remarks = $('#txt_remarks').val();
            var txt_status = $('#txt_status').val();
            var txt_paidamount = $('#txt_paidamount').val();
            var txtTotalAmount = $('#txtTotalAmount').val();
            $('#btn_Save').attr('disabled', true);
            var AllItemDetail = { 'advanceno': advanceno, 'txtdate': txtdate, 'ddl_vendor': ddl_vendor, 'referno': referno, 'ddl_paidthrough': ddl_paidthrough, 'advance_amount': advance_amount, 'ddl_withholdtax': ddl_withholdtax, 'withhold_tax_amount': withhold_tax_amount, 'txt_remarks': txt_remarks, 'txt_status': txt_status, 'txt_paidamount': txt_paidamount, 'txtTotalAmount': txtTotalAmount };
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
            PageMethods.loadadvanceheader(Adv_ID, function (resp) {
                var data = JSON.parse(resp);
                debugger;
                var txtdate = $.datepicker.formatDate('dd M yy', new Date(parseInt(data.Date.substring(6, 19))));
                $('#txtdate').val(txtdate);
                setTimeout(function () {
                    $('#ddl_vendor').val(data.Vendor_ID).trigger('change');
                    $('#ddl_paidthrough').val(data.Paid_Through).trigger('change');
                    $('#ddl_withholdtax').val(data.WithHoldTax_Perc).trigger('change');
                }, 2000);
                $('#advanceno').val(data.Advance_No);
                $('#txtTotalAmount').val(data.Total_amount);
                $('#referno').val(data.Refer_No);
                $('#advance_amount').val(data.Actual_Advance_Amount);
                $('#withhold_tax_amount').val(data.WithHoldTax_Amount);
                $('#txt_remarks').val(data.Remarks);
                $('#txt_status').val(data.Status);
                var checkstatus = $('#txt_status').val();
                if (checkstatus == 'Approved') {
                    $('#btn_Save').attr('disabled', true);
                    $('#btn_Save').hide();
                }
                if (checkstatus == 'Created') {
                    $('#btnVoucher').attr('disabled', true);
                    $('#btnVoucher').hide();
                }
                $('#btn_Save').val("Update");
            },
                function (error) {
                    alert(error.get_message());
                })
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
            <div class="col-lg-2 col-md-6 col-sm-6">
                <label>Advance No</label>
                <input type="text" id="advanceno" class="form-control" readonly="readonly" />
            </div>
            <div class="col-lg-2 col-md-6 col-sm-6">
                <label>Date</label>
                <input type="text" name="txt_Date" id="txtdate" class="form-control" />
            </div>
            <div class="col-lg-2 col-md-6 col-sm-6">
                <label>Vendor</label>
                <select id="ddl_vendor" class="form-control">
                </select>
            </div>
            <div class="col-lg-2 col-md-6 col-sm-6">
                <label>Ref No</label>
                <input type="text" id="referno" class="form-control" />
            </div>
            <div class="col-lg-2 col-md-6 col-sm-6">
                <label>Status</label>
                <input type="text" readonly="readonly" value="Created" name="txt_status" id="txt_status" class="form-control" />
            </div>
            <div class="col-lg-2 col-md-6 col-sm-6">
                <label>Paid Through</label>
                <select id="ddl_paidthrough" class="form-control" name="ddl_paidthrough"></select>
            </div>
        </div>

        <div class="row">
            <div class="col-lg-2 col-md-6 col-sm-6">
                <label>Paid Amnt</label>
                <input type="text" readonly="readonly" name="txt_paidamount" id="txt_paidamount" class="form-control" />
            </div>
            <div class="col-lg-2 col-md-6 col-sm-6">
                <label>Total  Amnt </label>
                <input type="text" readonly="readonly" name="txtTotalAmount" id="txtTotalAmount" class="form-control" />
            </div>
            <div class="col-lg-2 col-md-6 col-sm-6">
                <label>Advance Amnt</label>
                <input type="text" id="advance_amount" class="form-control" onchange="calculatetax()" />
            </div>
            <div class="col-lg-2 col-md-6 col-sm-6">
                <label>With Holding Tax</label>
                <select id="ddl_withholdtax" class="form-control" onchange="calculatetax()">
                </select>
            </div>
            <div class="col-lg-2 col-md-6 col-sm-6">
                <label>With Holding Tax Amnt</label>
                <input type="text" id="withhold_tax_amount" readonly="readonly" class="form-control" />
            </div>
            <div class="col-lg-2 col-md-6 col-sm-6">
                <label>Attachments</label>
                <input type="file" id="choseAdPaymentfile" name="choseAdPaymentfile" />
                <asp:HyperLink ID="HyperLink1" runat="server">Download</asp:HyperLink>
            </div>
        </div>
        <div class="row">
            <div class="col-lg-6 col-md-6 col-sm-6">
                <label>Remarks</label>
                <textarea id="txt_remarks" style="width: 100% !important;"></textarea>
            </div>
        </div>
    </form>

    <div class="row">
        <div class="col-lg-6">
            <div class="row">
        <div class="col-lg-2 col-md-4 col-sm-12">
            <input type="button" class="btn btn-primry" name="btn_Save" id="btn_Save" value="Save" onclick="SaveAllRecord()" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-12">
            <input type="button" name="btnList" class="btn-gray" id="btnList" value="List" onclick="location.href = 'AdvancePaymentView.aspx';" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-12">
            <input type="button" class="btn btn-yellow" name="btnAdd" id="btnAdd" value="New" onclick="location.href = 'AdvancePayment.aspx';" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-12">
            <input type="button" class="btn btn-primry"  value="Voucher" id="btnVoucher" onclick="PrintVoucher()" title="Voucher" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-12">
            <input type="button" class="btn btn-primry" value="Print" id="btnPrint" onclick="Print()" title="Print" />
        </div>
    </div>
        </div>
    </div>
</asp:Content>
