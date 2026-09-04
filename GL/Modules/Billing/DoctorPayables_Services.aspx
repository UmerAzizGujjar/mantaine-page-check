<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DoctorPayables_Services.aspx.cs" Inherits="PMS.Modules.Billing.DoctorPayables_Services" %>
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
            font-size: 22px;
            font-weight: 700;
            color: #fff;
            background: linear-gradient(135deg, #438eb9 0%, #2c6ea3 100%);
            padding: 6px 18px;
            border-radius: 6px;
            margin: 0;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            max-width: 100%;
            box-shadow: 1px 1px 4px rgba(0, 0, 0, 0.15);
        }
        .table-striped > tbody > tr:nth-child(odd) > td {
            background-color: #dfe9f1;
        }
        .filter-bar {
            background: #f6f8fa;
            border: 1px solid #e3e6ea;
            border-radius: 8px;
        }
        /* ===== Compact aligned toolbar rows ===== */
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
        .dp-tb label.ctl-label,
        .dp-bar label.ctl-label {
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
        /* kill theme `input{width:100%!important}` inside our bars */
        .filter-bar input { max-width: 100%; }
        .filter-bar input[type="checkbox"] {
            width: 16px !important;
            height: 16px !important;
            margin: 0;
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
        .ctl-wide {
            width: 220px !important;
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
            font-size: 20px;
            font-weight: 700;
            color: #fff;
            background: #438eb9;
            padding: 4px 14px;
            border-radius: 6px;
            display: inline-block;
            white-space: nowrap;
        }
        .ddlname {
            width: 170px;
            height: 28px;
            padding: 2px 6px;
            font-size: 12px;
            line-height: 1.2;
            border: 1px solid #ced4da;
            border-radius: 4px;
            background: #fff;
            color: #2c3e50;
            box-sizing: border-box;
        }
        .ddlname:focus {
            outline: none;
            border-color: #438eb9;
            box-shadow: 0 0 0 2px rgba(67, 142, 185, 0.18);
        }
        #tbody tr { cursor: pointer; }
        #tbody tr td { vertical-align: middle; }
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
    </style>

    <script type="text/javascript">
        var _DocId = '<%= Request.QueryString["ID"] %>';
        var _accountList = [];
        var _accountOptsHtml = '';
        var _rowsData = [];
        var _isLoading = false;
        var _loading = false;
        var _queryAccountID = '<%= Request.QueryString["AccountID"] %>';

        $(document).ready(function () {
            initDatepickers();
            applyQueryDates();
            loadAccounts(function () {
                initFilters();
                LoadPage(_DocId);
            });

            $('#btnSearch').click(function () {
                LoadPage(_DocId);
            });

            $('#chckHead').on('click', function () {
                var isTrue = $('#chckHead').is(':checked');
                $('.chcktbl').prop('checked', isTrue);
                calculateSum();
            });

            $('#myInput, #DepSearch').on('input', debounce(function () {
                applyRowFilters();
            }, 150));

            $('#ddlDepartment').on('change', function () {
                if ($(this).val() === 'All') {
                    $('#txt_datefrom').val('');
                    $('#txt_dateto').val('');
                    LoadPage(_DocId);
                } else {
                    applyRowFilters();
                }
            });

            $(document).on('change', '.chcktbl', function () {
                var allChecked = $('.chcktbl:checked').length === $('.chcktbl').length;
                $('#chckHead').prop('checked', allChecked);
                calculateSum();
            });
        });

        function initDatepickers() {
            $('#txt_datefrom, #txt_dateto').datepicker({ dateFormat: 'mm/dd/yy' }).attr('readonly', 'readonly');
        }

        function debounce(fn, wait) {
            var t;
            return function () {
                clearTimeout(t);
                var ctx = this, args = arguments;
                t = setTimeout(function () { fn.apply(ctx, args); }, wait);
            };
        }

        function applyQueryDates() {
            var st = '<%= Request.QueryString["stDate"] %>';
            var en = '<%= Request.QueryString["endDate"] %>';
            if (st) { $('#txt_datefrom').val(st); }
            if (en) { $('#txt_dateto').val(en); }
        }

        function initFilters() {
            $('#ddlDepartment').select2({ minimumResultsForSearch: Infinity, width: 'resolve' });
            $('#ddlpayment_method').select2({ minimumResultsForSearch: Infinity, width: 'resolve' }).prop('disabled', true).trigger('change');
            $('#ddlpayment_method').on('change', function () {
                syncRowAccounts();
            });
        }

        function loadAccounts(callback) {
            $.ajax({
                type: "post",
                url: "DoctorPayables_Services.aspx/loadAccount",
                dataType: 'JSON',
                contentType: "application/json; charset=utf-8",
                success: function (msg) {
                    _accountList = JSON.parse(msg.d);
                    _accountOptsHtml = '';
                    $.each(_accountList, function (key, value) {
                        _accountOptsHtml += '<option value="' + value.Account_ID + '">' + escAttr(value.name) + '</option>';
                    });
                    $('#ddlpayment_method').html('<option value="0">Select Account</option>' + _accountOptsHtml);
                    applyQueryAccount();
                    if (callback) callback();
                }
            });
        }

        function applyQueryAccount() {
            if (!_queryAccountID || _queryAccountID == '0' || _queryAccountID === '') return;
            $('#chckAccount').prop('checked', true);
            togglePaymentMethod();
            $('#ddlpayment_method').val(_queryAccountID).trigger('change');
        }

        function syncRowAccounts(value) {
            if (value === undefined || value === null) value = $('#ddlpayment_method').val();
            $('.ddlname').val(value);
        }

        function togglePaymentMethod() {
            var isChecked = document.getElementById("chckAccount").checked;
            $('#ddlpayment_method').prop('disabled', !isChecked).trigger('change');
            if ($('#ddlpayment_method').hasClass('select2-hidden-accessible')) {
                $('#ddlpayment_method').select2(isChecked ? 'enable' : 'disable');
            }
        }

        function escAttr(s) {
            if (s === null || s === undefined) return '';
            return String(s).replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/'/g, '&#39;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
        }

        function escText(s) {
            if (s === null || s === undefined) return '';
            return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
        }

        function fmtDate(d) {
            if (d === null || d === undefined || d === '') return '';
            var m;
            var raw = String(d);
            if (/Date\(\d+\)/.test(raw)) {
                var ms = parseInt(raw.replace(/[^0-9]/g, ''), 10);
                m = moment(ms);
            } else {
                m = moment(d);
            }
            return m.isValid() ? m.format('L') : '';
        }

        function cleanBillType(v) {
            var t = (v == null ? '' : String(v)).trim();
            if (t === '01' || t === '1') return 'Private';
            if (t === '02' || t === '2') return 'Panel';
            return '';
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

        function LoadPage(DocId) {
            if (_loading) return;
            _loading = true;

            var stDate = $('#txt_datefrom').val();
            var endDate = $('#txt_dateto').val();

            showLoader(true);
            $.ajax({
                type: "POST",
                url: "DoctorPayables_Services.aspx/ViewList",
                data: JSON.stringify({
                    "DocId": DocId,
                    "startDate": stDate,
                    "endDate": endDate
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (newdata) {
                    renderRows(JSON.parse(newdata.d));
                },
                error: function (err) {
                    $('#tbody').empty();
                    $('#Emp_name').html('');
                    $('#price').text('0');
                    $('#lbl_TotalAmount').text('0');
                    _loading = false;
                    showLoader(false);
                    Swal.fire({ icon: 'error', title: 'Error', text: (err.d || err.responseText || 'Load failed') });
                }
            });
        }

        function renderRows(data) {
            var $tbody = $('#tbody');
            $tbody.empty();
            _rowsData = [];
            if (!data || data.length === 0) {
                $('#Emp_name').html('');
                $('#price').text('0');
                $('#lbl_TotalAmount').text('0');
                $('#lbl_RowCount').text('0');
                _loading = false;
                showLoader(false);
                return;
            }

            var htmlRows = [];
            var totalshareAmount = 0;
            var DocName = data[0].Emp_Name || '';

            for (var i = 0; i < data.length; i++) {
                var value = data[i];
                var idx = _rowsData.length;
                _rowsData.push(value);

                var share = parseFloat(value.Doctor_Share) || 0;
                totalshareAmount += share;

                var BillType = cleanBillType(value.BillType);
                var BillDate = fmtDate(value.Bill_Date);
                var AdmissionDate = fmtDate(value.Admission_Date);
                var DischargeDate = fmtDate(value.Discharge_Date);
                var isIpd = value.In_Patient_ID != null && value.In_Patient_ID != '' && value.In_Patient_ID != 'null';
                var department = value.Test_Department || '';
                var preChecked = (value.isPayable === true || value.isPayable === 1 || value.isPayable === '1') ? ' checked' : '';

                var displayBillNo = (value.SourceType === 'Patient') ? value.Patient_No : value.Bill_No;
                var serviceName = value.Item_Name || 'Consultation Fee';

                htmlRows.push(
                    '<tr data-i="' + idx + '" data-opd="' + (isIpd ? 'IPD' : 'OPD') + '">' +
                    '<td><input type="checkbox" class="chcktbl" name="chkReport"' + preChecked + ' /></td>' +
                    '<td>' + (idx + 1) + '</td>' +
                    '<td>' + escText(displayBillNo) + '</td>' +
                    '<td>' + escText(BillDate) + '</td>' +
                    '<td>' + escText(value.Patient_No) + '</td>' +
                    '<td>' + escText(value.Full_Name) + '</td>' +
                    '<td>' + (isIpd ? 'IPD' : 'OPD') + '</td>' +
                    '<td>' + escText(department) + '</td>' +
                    '<td>' + escText(AdmissionDate) + '</td>' +
                    '<td>' + escText(DischargeDate) + '</td>' +
                    '<td>' + escText(BillType) + '</td>' +
                    '<td>' + escText(serviceName) + '</td>' +
                    '<td style="text-align:right;">' + addCommas(share) + '</td>' +
                    '<td><select class="ddlname" name="ddlname" data-i="' + idx + '">' + _accountOptsHtml + '</select></td>' +
                    '</tr>'
                );
            }

            var batchSize = 400;
            for (var b = 0; b < htmlRows.length; b += batchSize) {
                $tbody.append(htmlRows.slice(b, b + batchSize).join(''));
            }

            $('#Emp_name').html(escText(DocName));
            $('#lbl_TotalAmount').text(totalshareAmount.toLocaleString('en', { maximumFractionDigits: 2 }));
            $('#lbl_RowCount').text(_rowsData.length);
            $('#price').text('0');

            restoreSelections();
            applyRowFilters();
            _loading = false;
            showLoader(false);
        }

        var _prevCheckedKeys = {};
        function saveSelections() {
            _prevCheckedKeys = {};
            $.each(_rowsData, function (i, v) {
                var key = v.SourceType + '_' + (v.Bill_Details_ID || '') + '_' + (v.Patient_ID || '') + '_' + (v.Bill_ID || '');
                var row = $('tr[data-i="' + i + '"]');
                if (row.find('.chcktbl').is(':checked')) _prevCheckedKeys[key] = true;
            });
        }
        function restoreSelections() {
            if (!_rowsData.length) return;
            $.each(_rowsData, function (i, v) {
                var key = v.SourceType + '_' + (v.Bill_Details_ID || '') + '_' + (v.Patient_ID || '') + '_' + (v.Bill_ID || '');
                if (_prevCheckedKeys[key]) {
                    $('tr[data-i="' + i + '"]').find('.chcktbl').prop('checked', true);
                }
            });
            calculateSum();
        }

        function applyRowFilters() {
            var dept = $('#ddlDepartment').val();
            var subDept = ($('#DepSearch').val() || '').toLowerCase().trim();
            var globalTxt = ($('#myInput').val() || '').toLowerCase().trim();

            $('#tbody tr').each(function () {
                var $tr = $(this);
                var idx = parseInt($tr.attr('data-i'), 10);
                var v = _rowsData[idx];
                if (!v) { $tr.hide(); return; }

                var ok = true;
                if (dept && dept !== 'All') {
                    var isIpd = v.In_Patient_ID != null && v.In_Patient_ID != '' && v.In_Patient_ID != 'null';
                    ok = ok && ((dept === 'IPD' && isIpd) || (dept === 'OPD' && !isIpd));
                }
                if (ok && subDept) {
                    var deptTxt = (v.Test_Department || '').toLowerCase();
                    ok = deptTxt.indexOf(subDept) > -1;
                }
                if (ok && globalTxt) {
                    var hay = ($tr.text() || '').toLowerCase();
                    ok = hay.indexOf(globalTxt) > -1;
                }
                $tr.toggle(ok);
            });
            calculateSum();
        }

        function getCheckedRows() {
            var rows = [];
            $('#tbody tr').each(function () {
                if (!$(this).is(':visible')) return;
                var $cb = $(this).find('.chcktbl');
                if (!$cb.length || !$cb.is(':checked')) return;
                var idx = parseInt($(this).attr('data-i'), 10);
                var v = _rowsData[idx];
                if (v) rows.push(v);
            });
            return rows;
        }

        function calculateSum() {
            var sum = 0;
            $.each(getCheckedRows(), function (i, v) {
                sum += (parseFloat(v.Doctor_Share) || 0);
            });
            $('#price').text(sum.toLocaleString('en', { maximumFractionDigits: 2 }));
        }

        function getCrAccount() {
            var accId = $('#ddlpayment_method').val();
            return (accId && accId != '0') ? parseInt(accId, 10) : 0;
        }

        function TranferShares() {
            var checked = getCheckedRows();
            if (checked.length === 0) {
                Swal.fire({ icon: 'warning', title: 'No Rows Selected', text: 'Please select at least one row before transferring shares.' });
                return;
            }

            var totalCr = 0;
            var CrAccountID = 0;
            var Item_list = [];
            var table = $('#tbody');

            table.find('tr input[type=checkbox]:checked:visible').each(function (key, value) {
                var $tr = $(this).closest('tr');
                var idx = parseInt($tr.attr('data-i'), 10);
                var v = _rowsData[idx];
                if (!v) return;

                var rowCr = parseInt($tr.find('select[name=ddlname] :selected').val(), 10) || 0;
                if (rowCr) CrAccountID = rowCr;

                var sourceType = v.SourceType || 'Billing';
                var accountId = v.Account_Id || '';
                var shareAmount = v.Doctor_Share || 0;
                totalCr += parseFloat(shareAmount) || 0;
                var billDetailId = null;
                var patientId = null;
                var billId = null;

                if (sourceType === 'Billing') {
                    billDetailId = v.Bill_Details_ID || null;
                } else if (sourceType === 'Patient') {
                    patientId = v.Patient_ID || null;
                } else if (sourceType === 'IPD_Share_Distribution') {
                    billId = v.Bill_ID || null;
                }
                Item_list.push({
                    'Source_Type': sourceType,
                    'Bill_Detail_ID': billDetailId,
                    'Patient_ID': patientId,
                    'Bill_ID': billId,
                    'AccountID': accountId,
                    'shareAmount': shareAmount
                });
            });

            if (Item_list.length === 0) {
                Swal.fire({ icon: 'warning', title: 'No Rows', text: 'No transferable rows selected.' });
                return;
            }
            if (!CrAccountID) {
                Swal.fire({ icon: 'warning', title: 'No Account Selected', text: 'Select an account from the Payment Through dropdown before transferring.' });
                return;
            }

            $('#BtnPaid').attr('disabled', true);

            var AllItemDetail = {
                'Distri_No': 1,
                'totalCr': totalCr,
                'CrAccountID': CrAccountID,
                'ItemList': Item_list
            };

            PageMethods.TranferShares('Save', JSON.stringify(AllItemDetail), function (res) {
                saveSelections();
                Swal.fire({
                    title: 'Data Transfer!',
                    icon: 'success',
                    showConfirmButton: false,
                    timer: 2000
                });
                setTimeout(function () {
                    window.location = "DoctorPayables_Services.aspx?ID=" + _DocId;
                }, 600);
            }, function (error) {
                $('#BtnPaid').attr('disabled', false);
                Swal.fire({ icon: 'error', title: 'Error', text: error.get_message() });
            });
        }

        function UpdateData() {
            var checked = getCheckedRows();
            if (checked.length === 0) {
                Swal.fire({ icon: 'warning', title: 'No Rows Selected', text: 'Please select at least one row to save & print.' });
                return;
            }

            $('#BtnSave').prop('disabled', true);
            var Update_list = [];
            var ListTransID = '';
            $.each(checked, function (i, v) {
                var bd = v.Bill_Details_ID;
                if (bd == null || bd == '') return;
                Update_list.push({ 'txt_billdetail_id': String(bd) });
                if (ListTransID) ListTransID += ', ';
                ListTransID += bd;
            });

            var onDone = function (ok) {
                if (ok) {
                    Swal.fire({
                        title: 'Data Successfully Saved!',
                        icon: 'success',
                        showConfirmButton: false,
                        timer: 2000
                    });
                    setTimeout(function () {
                        location.reload();
                    }, 500);
                } else {
                    $('#BtnSave').prop('disabled', false);
                }
            };

            if (Update_list.length) {
                $.ajax({
                    type: "post",
                    url: "DoctorPayables_Services.aspx/Update",
                    data: JSON.stringify({ "Update_list": Update_list }),
                    dataType: 'JSON',
                    contentType: "application/json; charset=utf-8",
                    success: function () { onDone(true); },
                    error: function (err) {
                        Swal.fire({ icon: 'error', title: 'Error', text: err.d || 'Update failed' });
                        onDone(false);
                    }
                });
            } else {
                onDone(true);
            }

            var id = '<%= Request.QueryString["ID"] %>';
            if (id && ListTransID) {
                var url = 'ReportViewer.aspx?ReportName=DoctorBaseReport&ReportTitle=Doctor Share Base  Report&Doctor_ID=' + id + '&Bill_Details_ID=' + ListTransID;
                window.open(url, '_blank');
            }
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="row filter-bar dp-actionbar" style="margin-bottom: 10px;">
        <div class="dp-tb">
            <label for="txt_datefrom" class="ctl-label">From</label>
            <input type="text" id="txt_datefrom" class="form-control ctl-date" />
            <label for="txt_dateto" class="ctl-label">To</label>
            <input type="text" id="txt_dateto" class="form-control ctl-date" />
            <input type="button" id="btnSearch" class="btn-primry" value="Search" />
        </div>
        <div class="dp-tb">
            <input type="checkbox" id="chckAccount" onclick="togglePaymentMethod()" />
            <label for="chckAccount" class="ctl-label" style="cursor:pointer;">Select Account</label>
            <select id="ddlpayment_method" disabled="disabled"></select>
        </div>
        <div class="dp-tb dp-tb-right">
            <input type="button" id="BtnPaid" onclick="TranferShares()" value="Paid" class="btn-primry" />
            <input type="button" id="BtnSave" onclick="UpdateData();" value="Save & Print" class="btn-primry" />
        </div>
    </div>

    <div class="row filter-bar dp-actionbar" style="margin-bottom: 10px;">
        <div class="dp-tb" style="flex: 0 0 auto; min-width: 240px;">
            <label id="Emp_name" style="font-size: 18px; font-weight: 700; margin: 0;"></label>
        </div>
        <div class="dp-tb">
            <select id="ddlDepartment">
                <option value="All">All</option>
                <option value="IPD">IPD</option>
                <option value="OPD">OPD</option>
            </select>
        </div>
        <div class="dp-tb">
            <input id="DepSearch" type="text" class="form-control ctl-search" placeholder="Sub Department.." />
        </div>
        <div class="dp-tb">
            <input id="myInput" type="text" class="form-control ctl-search" placeholder="Search table.." />
        </div>
        <div class="dp-tb dp-tb-right">
            <span class="sum-label" id="price">0</span>
        </div>
    </div>

    <div class="row" style="margin-bottom: 10px;">
        <div class="col-lg-12" style="display:flex; align-items:center; justify-content:space-between; gap:10px;">
            <span class="sum-label" style="background:#cecccc; color:#333;">Rows: <span id="lbl_RowCount">0</span></span>
            <span class="sum-label" style="background:#cecccc; color:#333;">Total: <span id="lbl_TotalAmount">0</span></span>
        </div>
    </div>

    <div id="loadingArea" class="loading-overlay">Loading entries, please wait...</div>

    <div class="row" id="tblWrap">
        <div class="col-lg-12">
            <div class="scroll-body">
                <table class="table" id="tbl">
                    <thead>
                        <tr>
                            <th style="width:30px;">
                                <input type="checkbox" id="chckHead" name="chkReport" />
                            </th>
                            <th>Sr No</th>
                            <th>Bill/OPD No</th>
                            <th>Bill Date</th>
                            <th>MR No</th>
                            <th>Patient Name</th>
                            <th>Dept</th>
                            <th>Sub Department</th>
                            <th>Date Of Admission</th>
                            <th>Date Of Discharge</th>
                            <th>Bill Type</th>
                            <th>Service Name</th>
                            <th>Doctor Share</th>
                            <th style="width: 180px;">Payment Through</th>
                        </tr>
                    </thead>
                    <tbody id="tbody" class="font-weight-bold">
                    </tbody>
                </table>
            </div>
        </div>
    </div>

</asp:Content>
