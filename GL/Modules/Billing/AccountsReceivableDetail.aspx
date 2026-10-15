<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AccountsReceivableDetail.aspx.cs" Inherits="PMS.Modules.Billing.AccountsReceivableDetail" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/Billing.css" rel="stylesheet" />

    <style type="text/css">
        .table th {
            border: 1px solid #FFF;
            background-color: #438eb9;
            color: #FFF;
            position: sticky;
            top: 0;
            z-index: 2;
        }
        #Emp_name {
            display: inline-flex;
            align-items: center;
            font-size: 20px;
            font-weight: 700;
            color: #fff;
            background: linear-gradient(135deg, #438eb9 0%, #2c6ea3 100%);
            padding: 6px 18px;
            border-radius: 6px;
            margin: 0;
            white-space: nowrap;
            max-width: 100%;
            box-shadow: 1px 1px 4px rgba(0, 0, 0, 0.15);
        }
        .filter-bar {
            background: #f6f8fa;
            border: 1px solid #e3e6ea;
            border-radius: 8px;
        }
        .dp-actionbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 10px 18px;
            padding: 10px 16px;
        }
        .dp-tb {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
            min-width: 0;
        }
        .dp-tb-right {
            margin-left: auto;
        }
        .dp-tb label.ctl-label {
            margin: 0 2px 0 0;
            font-size: 12.5px;
            font-weight: 600;
            white-space: nowrap;
            color: #333;
        }
        .filter-bar input[type="text"],
        .filter-bar select {
            height: 30px;
            padding: 3px 10px;
            font-size: 13px;
            box-sizing: border-box;
        }
        .filter-bar .form-control {
            height: 30px;
            padding: 3px 10px;
            font-size: 13px;
            border-radius: 5px;
            border: 1px solid #ced4da;
        }
        .ctl-date {
            width: 120px !important;
        }
        .ctl-search {
            width: 180px !important;
        }
        .filter-bar input[type="button"].btn-primry {
            padding: 5px 14px !important;
            font-size: 12.5px !important;
            font-weight: 600 !important;
            height: 30px !important;
            line-height: 1 !important;
            width: auto !important;
            min-width: 90px;
            white-space: nowrap;
            box-shadow: 1px 1px 3px rgba(0, 0, 0, 0.18) !important;
        }
        .filter-bar .select2-container {
            width: auto !important;
            min-width: 130px;
            max-width: 240px;
        }
        .filter-bar .select2-container .select2-selection--single {
            height: 30px !important;
            padding: 2px 8px;
        }
        .filter-bar .select2-container--default .select2-selection--single .select2-selection__rendered {
            line-height: 24px !important;
            font-size: 13px !important;
        }
        .filter-bar .select2-container--default .select2-selection--single .select2-selection__arrow {
            height: 28px !important;
        }
        .sum-label {
            font-size: 18px;
            font-weight: 700;
            color: #fff;
            background: #438eb9;
            padding: 4px 14px;
            border-radius: 6px;
            display: inline-block;
            white-space: nowrap;
        }
        .scroll-body {
            max-height: 62vh;
            overflow: auto;
        }
        .loading-overlay {
            display: none;
            text-align: center;
            padding: 20px;
            color: #438eb9;
            font-weight: 700;
        }

        .filter-bar select#ddlRecvAcc ~ .select2-container {
            width: 340px !important;
            max-width: 340px !important;
        }

        #btnTransfer:disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }
    </style>

    <script type="text/javascript">
        var _rowsData = [];
        var _type = '<%= Request.QueryString["Type"] %>';

        $(document).ready(function () {
            initDatepickers();
            LoadPage();
            LoadAccounts();

            $('#btnSearch').click(function () {
                LoadPage();
            });

            $('#ddlRecvAcc').on('change', function () {
                updateTransferState();
            });

            $('#btnTransfer').click(function () {
                TransferAndPost();
            });

            $('#myInput').on('input', function () {
                applyRowFilters();
            });
        });

        function initDatepickers() {
            $('#txt_datefrom, #txt_dateto').datepicker({ dateFormat: 'mm/dd/yy' }).attr('readonly', 'readonly');
        }

        function escText(s) {
            if (s === null || s === undefined) return '';
            return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
        }

        function fmtDate(d) {
            if (d === null || d === undefined || d === '') return '';
            var raw = String(d);
            var m;
            if (/Date\(\d+\)/.test(raw)) {
                m = moment(parseInt(raw.replace(/[^0-9]/g, ''), 10));
            } else {
                m = moment(raw);
            }
            return m.isValid() ? m.format('D-MMM-YYYY') : '';
        }

        function addCommas(nStr) {
            if (nStr === null || nStr === undefined || nStr === '') nStr = 0;
            var n = parseFloat(nStr);
            if (isNaN(n)) return '0';
            return n.toLocaleString('en', { maximumFractionDigits: 2 });
        }

        function showLoader(show) {
            if (show) {
                $('#loadingArea').show();
                $('#tblWrap').css('visibility', 'hidden');
            } else {
                $('#loadingArea').hide();
                $('#tblWrap').css('visibility', 'visible');
            }
        }

        function applyPharmacyLabels() {
            if (_type !== 'PH') return;
            var labels = ['Sr No', 'Bill No', 'Date', 'Customer', '', 'Type', 'Warehouse', 'Cash Received', 'Bill Total'];
            $('#detailHead th').each(function (i) { $(this).text(labels[i] || ''); });
            $('#lbl_TotalCaption').text('Total Cash Received');
        }

        function LoadPage() {
            applyPharmacyLabels();
            var stDate = $('#txt_datefrom').val();
            var endDate = $('#txt_dateto').val();

            showLoader(true);
            $.ajax({
                type: "POST",
                url: "AccountsReceivableDetail.aspx/ViewList",
                data: JSON.stringify({ "rtype": _type, "startDate": stDate, "endDate": endDate }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (newdata) {
                    renderRows(JSON.parse(newdata.d));
                },
                error: function (err) {
                    $('#tbody').empty();
                    _rowsData = [];
                    showLoader(false);
                    Swal.fire({ icon: 'error', title: 'Error', text: (err.responseText || 'Load failed') });
                }
            });
        }

        function renderRows(data) {
            var $tbody = $('#tbody');
            $tbody.empty();
            _rowsData = [];

            $('#Emp_name').html('<%= Request.QueryString["Name"] %> (' + _type + ')');

            if (!data || data.length === 0) {
                $('#lbl_TotalAmount').text('0');
                $('#lbl_RowCount').text('0');
                updateTransferState();
                showLoader(false);
                return;
            }

            var htmlRows = [];
            var totalShare = 0;

            for (var i = 0; i < data.length; i++) {
                var value = data[i];
                var idx = _rowsData.length;
                _rowsData.push(value);

                var share = parseFloat(value.Transfer_Amount !== undefined ? value.Transfer_Amount : value.Hospital_Share) || 0;
                totalShare += share;

                htmlRows.push(
                    '<tr data-i="' + idx + '">' +
                    '<td>' + (idx + 1) + '</td>' +
                    '<td>' + escText(value.Patient_No) + '</td>' +
                    '<td>' + escText(fmtDate(value.Slip_Date)) + '</td>' +
                    '<td>' + escText(value.Full_Name) + '</td>' +
                    '<td>' + escText(value.Doctor_Name) + '</td>' +
                    '<td>' + escText(value.Type_Name) + '</td>' +
                    '<td>' + escText(value.Dept) + '</td>' +
                    '<td style="text-align:right;">' + addCommas(share) + '</td>' +
                    '<td style="text-align:right;">' + addCommas(value.Receipt_Amount) + '</td>' +
                    '</tr>'
                );
            }

            var batchSize = 400;
            for (var b = 0; b < htmlRows.length; b += batchSize) {
                $tbody.append(htmlRows.slice(b, b + batchSize).join(''));
            }

            $('#lbl_TotalAmount').text(totalShare.toLocaleString('en', { maximumFractionDigits: 2 }));
            $('#lbl_RowCount').text(_rowsData.length);
            updateTransferState();
            showLoader(false);
        }

        function applyRowFilters() {
            var txt = ($('#myInput').val() || '').toLowerCase().trim();
            $('#tbody tr').each(function () {
                var $tr = $(this);
                if (txt) {
                    var hay = ($tr.text() || '').toLowerCase();
                    $tr.toggle(hay.indexOf(txt) > -1);
                } else {
                    $tr.show();
                }
            });
        }

        function LoadAccounts() {
            $.ajax({
                type: "POST",
                url: "AccountsReceivableDetail.aspx/LoadAccounts",
                data: JSON.stringify({}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    var options = '<option value="">Please Select</option>';
                    $.each(data, function (i, a) {
                        options += '<option value="' + a.Account_ID + '">' + escText(a.Account_Name) + ' (' + escText(a.Account_Code) + ')</option>';
                    });
                    $('#ddlRecvAcc').html(options).select2({ width: '260px' });
                    updateTransferState();
                },
                error: function (err) {
                    Swal.fire({ icon: 'error', title: 'Error', text: 'Accounts load failed.' });
                }
            });
        }

        function updateTransferState() {
            var hasRows = _rowsData && _rowsData.length > 0;
            var hasAcc = ($('#ddlRecvAcc').val() || '') !== '';
            $('#btnTransfer').prop('disabled', !(hasRows && hasAcc));
        }

        function TransferAndPost() {
            if (!_rowsData || _rowsData.length === 0) {
                Swal.fire({ icon: 'warning', title: 'No Slips', text: 'No receivable slips to transfer.', confirmButtonColor: '#3085d6' });
                return;
            }

            var accId = $('#ddlRecvAcc').val();
            if (!accId) {
                Swal.fire({ icon: 'warning', title: 'Select Account', text: 'Please select Received Through account.', confirmButtonColor: '#3085d6' });
                return;
            }

            var total = parseFloat(($('#lbl_TotalAmount').text() || '0').replace(/,/g, '')) || 0;

            Swal.fire({
                title: 'Confirm Transfer',
                html: 'Transfer <strong>' + addCommas(total) + '</strong> of ' + _rowsData.length + ' slip(s) from receivable temporary account<br/>to <strong>' + escText($('#ddlRecvAcc option:selected').text()) + '</strong>?<br/>ACCRCV voucher will be posted.',
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#28a745',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Yes, Post Voucher!',
                cancelButtonText: 'Cancel'
            }).then((result) => {
                if (!result.isConfirmed) return;

                Swal.fire({
                    title: 'Processing...',
                    text: 'Please wait',
                    allowOutsideClick: false,
                    showConfirmButton: false,
                    didOpen: () => { Swal.showLoading(); }
                });

                var stDate = $('#txt_datefrom').val();
                var endDate = $('#txt_dateto').val();

                $.ajax({
                    type: "POST",
                    url: "AccountsReceivableDetail.aspx/TransferReceivable",
                    data: JSON.stringify({ rtype: _type, startDate: stDate, endDate: endDate, accountID: parseInt(accId, 10) }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        try {
                            var res = JSON.parse(response.d);
                            if (res && res.length > 0 && res[0].Voucher_ID > 0) {
                                var v = res[0];
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Voucher Posted',
                                    html: 'Voucher No: <strong>' + v.Voucher_ID + '</strong>' +
                                        '<br/>Slips: ' + v.Slip_Count +
                                        '<br/>Amount: ' + addCommas(v.Transfer_Amount) +
                                        '<br/>Received Through: ' + escText(v.Received_Through || ''),
                                    confirmButtonColor: '#28a745'
                                }).then(function () {
                                    window.location.reload();
                                });
                            } else {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Transfer Failed',
                                    text: res[0].Message || 'Unknown error',
                                    confirmButtonColor: '#d33'
                                });
                            }
                        } catch (e) {
                            Swal.fire({ icon: 'error', title: 'Error', text: 'Invalid response from server.', confirmButtonColor: '#d33' });
                        }
                    },
                    error: function (err) {
                        Swal.fire({ icon: 'error', title: 'Error', text: (err.responseText || 'Transfer failed') });
                    }
                });
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="row filter-bar dp-actionbar" style="margin-bottom: 10px;">
        <div class="dp-tb">
            <span id="Emp_name"></span>
        </div>
        <div class="dp-tb">
            <label for="txt_datefrom" class="ctl-label">From</label>
            <input type="text" id="txt_datefrom" class="form-control ctl-date" />
            <label for="txt_dateto" class="ctl-label">To</label>
            <input type="text" id="txt_dateto" class="form-control ctl-date" />
            <input type="button" id="btnSearch" class="btn-primry" value="Search" />
        </div>
        <div class="dp-tb">
            <input id="myInput" type="text" class="form-control ctl-search" placeholder="Search table.." />
        </div>
    </div>

    <div class="row filter-bar dp-actionbar" style="margin-bottom: 10px;">
        <div class="dp-tb">
            <label for="ddlRecvAcc" class="ctl-label">Received Through</label>
            <select id="ddlRecvAcc"></select>
        </div>
        <div class="dp-tb dp-tb-right">
            <input type="button" id="btnTransfer" class="btn-primry" value="Transfer &amp; Post ACCRCV Voucher" disabled="disabled" />
        </div>
    </div>

    <div class="row" style="margin-bottom: 10px;">
        <div class="col-lg-12" style="display:flex; align-items:center; justify-content:space-between; gap:10px;">
            <span class="sum-label" style="background:#cecccc; color:#333;">Rows: <span id="lbl_RowCount">0</span></span>
            <span class="sum-label"><span id="lbl_TotalCaption">Total Hospital Share</span>: <span id="lbl_TotalAmount">0</span></span>
        </div>
    </div>

    <div id="loadingArea" class="loading-overlay">Loading entries, please wait...</div>

    <div class="row" id="tblWrap">
        <div class="col-lg-12">
            <div class="scroll-body">
                <table class="table" id="tbl">
                    <thead>
                        <tr id="detailHead">
                            <th>Sr No</th>
                            <th>OPD No</th>
                            <th>Date</th>
                            <th>Patient Name</th>
                            <th>Doctor</th>
                            <th>Type</th>
                            <th>Department</th>
                            <th>Hospital Share</th>
                            <th>Receipt</th>
                        </tr>
                    </thead>
                    <tbody id="tbody" class="font-weight-bold">
                    </tbody>
                </table>
            </div>
        </div>
    </div>

</asp:Content>
