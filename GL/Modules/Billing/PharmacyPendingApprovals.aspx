<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PharmacyPendingApprovals.aspx.cs" Inherits="PMS.Modules.Billing.PharmacyPendingApprovals" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">
        var pendingRows = [];      // every bill listed for the current search
        var selectedRows = {};     // Bill_ID -> bill, ticked by the user
        var oTable = null;

        $(function () {
            var today = $.datepicker.formatDate('yy-mm-dd', new Date());
            $('#txtFrom, #txtTo').datepicker({ dateFormat: 'yy-mm-dd' }).attr('readonly', 'readonly');
            $('#txtFrom, #txtTo').val(today);

            $('#btnLoad').on('click', loadPending);
            $('#txtSearch').on('keypress', function (e) {
                if (e.which === 13) { e.preventDefault(); loadPending(); }
            });

            // row checkbox: add/remove that bill from the selection
            $(document).on('change', '#tblPending .chckrow', function () {
                var id = String($(this).val());
                if ($(this).is(':checked')) {
                    selectedRows[id] = findBill(id);
                } else {
                    delete selectedRows[id];
                }
                syncHeader();
                updateSummary();
            });

            // header checkbox: select / clear every bill in the list, not just this page
            $(document).on('change', '#header-check', function () {
                var on = $(this).is(':checked');
                pendingRows.forEach(function (r) {
                    if (on) { selectedRows[String(r.Bill_ID)] = r; }
                    else { delete selectedRows[String(r.Bill_ID)]; }
                });
                syncChecks();
                updateSummary();
            });

            $('#btnApprove').on('click', approveSelected);

            var todayStr = $.datepicker.formatDate('yy-mm-dd', new Date());
            $('#txtVFrom, #txtVTo').datepicker({ dateFormat: 'yy-mm-dd' }).attr('readonly', 'readonly');
            $('#txtVFrom, #txtVTo').val(todayStr);
            $('#btnVLoad').on('click', loadVouchers);
            $(document).on('click', '.vView', function () {
                viewVoucher($(this).data('id'), $(this).data('no'));
            });

            loadPending();
            loadVouchers();
        });

        // posts every ticked bill to the GL in one transaction (BulkApprovePharmacy)
        function approveSelected() {
            var ids = Object.keys(selectedRows).filter(function (id) { return !!selectedRows[id]; });
            if (ids.length === 0) {
                Swal.fire('No bills selected', 'Tick the bills you want to approve.', 'info');
                return;
            }

            Swal.fire({
                title: 'Approve ' + ids.length + ' bill(s)?',
                text: 'Each bill will be posted to a GL voucher. All selected bills are approved together, or none are.',
                icon: 'question',
                showCancelButton: true,
                confirmButtonText: 'Yes, approve',
                cancelButtonText: 'Cancel'
            }).then(function (res) {
                if (!res.isConfirmed) { return; }

                $('#btnApprove').prop('disabled', true);
                $.ajax({
                    type: 'POST',
                    url: 'PharmacyPendingApprovals.aspx/BulkApprovePharmacy',
                    data: JSON.stringify({ billIds: ids.join(',') }),
                    contentType: 'application/json; charset=utf-8',
                    dataType: 'json',
                    success: function (response) {
                        var r = JSON.parse(response.d);
                        if (r.ok) {
                            Swal.fire('Approved', r.count + ' bill(s) posted in one voucher, No ' + r.voucherNo + '. See Posted bulk vouchers below.', 'success');
                            loadPending();
                            loadVouchers();
                        } else {
                            Swal.fire('Not approved', r.message, 'error');
                        }
                    },
                    error: function () {
                        Swal.fire('Error', 'Approval request failed.', 'error');
                    },
                    complete: function () {
                        $('#btnApprove').prop('disabled', false);
                    }
                });
            });
        }

        // Posted bulk vouchers in the From/To date range (voucher date)
        function loadVouchers() {
            $('#btnVLoad').prop('disabled', true);
            $.ajax({
                type: 'POST',
                url: 'PharmacyPendingApprovals.aspx/LoadBulkVouchers',
                data: JSON.stringify({
                    start_date: $('#txtVFrom').val(),
                    end_date: $('#txtVTo').val()
                }),
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    renderVouchers(JSON.parse(response.d));
                },
                error: function () {
                    Swal.fire('Error', 'Failed to load posted bulk vouchers.', 'error');
                },
                complete: function () {
                    $('#btnVLoad').prop('disabled', false);
                }
            });
        }

        var vTable = null;

        function renderVouchers(rows) {
            if (vTable) {
                vTable.destroy();
                vTable = null;
            }

            vTable = $('#tblVouchers').DataTable({
                data: rows,
                pageLength: 10,
                order: [],
                columns: [
                    { data: 'Voucher_No', defaultContent: '', render: function (d) { return pEsc(d); } },
                    {
                        data: 'Voucher_Date', defaultContent: '',
                        render: function (d, t) { return t === 'display' ? pEsc(pDate(d)) : (d || ''); }
                    },
                    { data: 'BillCount', className: 'text-right', defaultContent: '0' },
                    { data: 'TotalDR', className: 'text-right', render: function (d) { return pMoney(d); } },
                    { data: 'TotalCR', className: 'text-right', render: function (d) { return pMoney(d); } },
                    { data: 'Remarks', defaultContent: '', render: function (d) { return pEsc(d); } },
                    { data: 'Voucher_Status', defaultContent: '', render: function (d) { return pEsc(d); } },
                    {
                        data: null, orderable: false, searchable: false, className: 'text-center',
                        render: function (d, t, full) {
                            return '<button type="button" class="btn btn-primry vView" data-id="' + full.Voucher_ID +
                                   '" data-no="' + pEsc(full.Voucher_No) + '">View</button>';
                        }
                    }
                ]
            });

            $('#lblVoucherCount').text('(' + rows.length + ' vouchers)');
        }

        // one posted voucher: the bills it covers and its GL lines
        function viewVoucher(id, no) {
            $.ajax({
                type: 'POST',
                url: 'PharmacyPendingApprovals.aspx/GetBulkVoucherDetail',
                data: JSON.stringify({ voucherId: String(id) }),
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    var d = JSON.parse(response.d);

                    var billRows = (d.bills || []).map(function (b) {
                        return '<tr><td>' + pEsc(b.Seq_InvoiceNo) + '</td><td>' + pEsc(b.Customer_Name) + '</td>' +
                               '<td style="text-align:right;">' + pMoney(b.Total_Amount) + '</td>' +
                               '<td style="text-align:right;">' + pMoney(b.Discount_Amount) + '</td>' +
                               '<td style="text-align:right;">' + pMoney(b.Received_Amount) + '</td>' +
                               '<td style="text-align:right;">' + pMoney(b.Balance_Amount) + '</td></tr>';
                    }).join('');

                    var lineRows = (d.lines || []).map(function (l) {
                        return '<tr><td>' + pEsc(l.Account_Code) + '</td><td>' + pEsc(l.Account_Name) + '</td>' +
                               '<td>' + pEsc(l.Narration) + '</td>' +
                               '<td style="text-align:right;">' + pMoney(l.DR) + '</td>' +
                               '<td style="text-align:right;">' + pMoney(l.CR) + '</td></tr>';
                    }).join('');

                    var html =
                        '<h4 style="text-align:left;">Bills in this voucher</h4>' +
                        '<table class="table table-bordered table-condensed"><thead><tr><th>Bill No</th><th>Customer</th>' +
                        '<th style="text-align:right;">Total</th><th style="text-align:right;">Discount</th>' +
                        '<th style="text-align:right;">Received</th><th style="text-align:right;">Balance</th></tr></thead>' +
                        '<tbody>' + billRows + '</tbody></table>' +
                        '<h4 style="text-align:left;">GL lines</h4>' +
                        '<table class="table table-bordered table-condensed"><thead><tr><th>Account Code</th><th>Account</th>' +
                        '<th>Narration</th><th style="text-align:right;">DR</th><th style="text-align:right;">CR</th></tr></thead>' +
                        '<tbody>' + lineRows + '</tbody></table>';

                    Swal.fire({ title: 'Voucher No ' + no, html: html, width: 960, confirmButtonText: 'Close' });
                },
                error: function () {
                    Swal.fire('Error', 'Failed to load the voucher.', 'error');
                }
            });
        }

        function pEsc(v) {
            if (v === null || v === undefined) { return ''; }
            return String(v)
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#39;');
        }

        // .NET JSON dates look like /Date(1728800000000)/
        function pDate(v) {
            var m = /\/Date\((-?\d+)\)\//.exec(v || '');
            if (!m) { return ''; }
            return new Date(parseInt(m[1], 10)).toLocaleString('en-GB', {
                day: '2-digit', month: 'short', year: '2-digit', hour: '2-digit', minute: '2-digit'
            });
        }

        function pMoney(v) {
            var n = Number(v || 0);
            return n.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
        }

        function findBill(id) {
            for (var i = 0; i < pendingRows.length; i++) {
                if (String(pendingRows[i].Bill_ID) === id) { return pendingRows[i]; }
            }
            return null;
        }

        function loadPending() {
            $('#btnLoad').prop('disabled', true);
            $.ajax({
                type: 'POST',
                url: 'PharmacyPendingApprovals.aspx/LoadPendingPharmacyBills',
                data: JSON.stringify({
                    start_date: $('#txtFrom').val(),
                    end_date: $('#txtTo').val(),
                    search: $('#txtSearch').val()
                }),
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    renderPending(JSON.parse(response.d));
                },
                error: function () {
                    Swal.fire('Error', 'Failed to load pending pharmacy bills.', 'error');
                },
                complete: function () {
                    $('#btnLoad').prop('disabled', false);
                }
            });
        }

        function renderPending(rows) {
            pendingRows = rows;
            selectedRows = {};          // a new search starts with nothing ticked
            $('#header-check').prop('checked', false);

            if (oTable) {
                oTable.destroy();
                oTable = null;
            }

            oTable = $('#tblPending').DataTable({
                data: rows,
                pageLength: 25,
                lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
                order: [],
                columns: [
                    {
                        data: null, orderable: false, searchable: false, className: 'text-center',
                        render: function (d, t, full) {
                            return '<input type="checkbox" class="chckrow" value="' + full.Bill_ID + '" />';
                        }
                    },
                    { data: 'BillNo', defaultContent: '' },
                    {
                        data: 'Creation_Date', defaultContent: '',
                        render: function (d, t) { return t === 'display' ? pEsc(pDate(d)) : (d || ''); }
                    },
                    { data: 'Customer_Name', defaultContent: '', render: function (d) { return pEsc(d); } },
                    { data: 'MR_No', defaultContent: '', render: function (d) { return pEsc(d); } },
                    { data: 'WareHouse', defaultContent: '', render: function (d) { return pEsc(d); } },
                    {
                        data: 'Payment', defaultContent: '-',
                        render: function (d) {
                            var cls = d === 'Bank' ? 'label-info' : (d === 'Cash' ? 'label-success' : 'label-default');
                            return '<span class="label ' + cls + '">' + pEsc(d || '-') + '</span>';
                        }
                    },
                    { data: 'Total_Amount', className: 'text-right', render: function (d) { return pMoney(d); } },
                    { data: 'Discount_Amount', className: 'text-right', render: function (d) { return pMoney(d); } },
                    { data: 'Total_CGS', className: 'text-right', render: function (d) { return pMoney(d); } },
                    { data: 'Received_Amount', className: 'text-right', render: function (d) { return pMoney(d); } },
                    { data: 'Balance_Amount', className: 'text-right', render: function (d) { return pMoney(d); } },
                    { data: 'Status', defaultContent: 'Created', render: function (d) { return pEsc(d); } }
                ],
                drawCallback: function () { syncChecks(); }
            });

            $('#lblSummary').text('(' + rows.length + ' bills)');
            syncHeader();
            updateSummary();
        }

        // tick the boxes on the current page from the selection
        function syncChecks() {
            $('#tblPending .chckrow').each(function () {
                $(this).prop('checked', !!selectedRows[String($(this).val())]);
            });
        }

        function syncHeader() {
            var selected = Object.keys(selectedRows).length;
            $('#header-check').prop('checked', pendingRows.length > 0 && selected === pendingRows.length);
        }

        // totals of the ticked bills, shown in the boxes above the table
        function updateSummary() {
            var count = 0, total = 0, discount = 0, cgs = 0, received = 0, balance = 0;
            Object.keys(selectedRows).forEach(function (id) {
                var r = selectedRows[id];
                if (!r) { return; }
                count++;
                total += Number(r.Total_Amount || 0);
                discount += Number(r.Discount_Amount || 0);
                cgs += Number(r.Total_CGS || 0);
                received += Number(r.Received_Amount || 0);
                balance += Number(r.Balance_Amount || 0);
            });
            $('#txtSelCount').val(count);
            $('#txtSelTotal').val(total.toFixed(2));
            $('#txtSelDiscount').val(discount.toFixed(2));
            $('#txtSelCgs').val(cgs.toFixed(2));
            $('#txtSelReceived').val(received.toFixed(2));
            $('#txtSelBalance').val(balance.toFixed(2));
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="pf-page">
        <section class="pf-card">
            <div class="pf-filters">
                <div class="pf-field">
                    <label class="pf-field-label" for="txtFrom">From date</label>
                    <input type="text" id="txtFrom" class="form-control" />
                </div>
                <div class="pf-field">
                    <label class="pf-field-label" for="txtTo">To date</label>
                    <input type="text" id="txtTo" class="form-control" />
                </div>
                <div class="pf-field pf-field--wide">
                    <label class="pf-field-label" for="txtSearch">Search (bill no, customer, MR no)</label>
                    <input type="text" id="txtSearch" class="form-control" autocomplete="off" placeholder="Type to search..." />
                </div>
                <div class="pf-field pf-field--action">
                    <input type="button" id="btnLoad" class="btn btn-primry" value="Load" />
                </div>
            </div>
        </section>

        <section class="pf-card">
            <div class="pf-card-head">
                <span class="pf-card-icon"><i class="fas fa-calculator"></i></span>
                <h2 class="pf-card-title">Selected bills <span id="lblSummary" class="pf-count"></span></h2>
            </div>
            <div class="pf-filters">
                <div class="pf-field">
                    <label class="pf-field-label">Selected bills</label>
                    <input type="text" id="txtSelCount" class="form-control" readonly="readonly" style="text-align: right;" />
                </div>
                <div class="pf-field">
                    <label class="pf-field-label">Total Amount</label>
                    <input type="text" id="txtSelTotal" class="form-control" readonly="readonly" style="text-align: right;" />
                </div>
                <div class="pf-field">
                    <label class="pf-field-label">Discount Amount</label>
                    <input type="text" id="txtSelDiscount" class="form-control" readonly="readonly" style="text-align: right;" />
                </div>
                <div class="pf-field">
                    <label class="pf-field-label">CGS</label>
                    <input type="text" id="txtSelCgs" class="form-control" readonly="readonly" style="text-align: right;" />
                </div>
                <div class="pf-field">
                    <label class="pf-field-label">Received Amount</label>
                    <input type="text" id="txtSelReceived" class="form-control" readonly="readonly" style="text-align: right;" />
                </div>
                <div class="pf-field">
                    <label class="pf-field-label">Balance Amount</label>
                    <input type="text" id="txtSelBalance" class="form-control" readonly="readonly" style="text-align: right;" />
                </div>
                <div class="pf-field pf-field--action">
                    <input type="button" id="btnApprove" class="btn btn-primry" value="Approve Selected" />
                </div>
            </div>

            <table id="tblPending" class="table table-bordered table-striped table-condensed" style="width: 100%; margin-top: 10px;">
                <thead>
                    <tr>
                        <th style="text-align: center; width: 4%;"><input type="checkbox" id="header-check" /></th>
                        <th>Bill No</th>
                        <th>Created</th>
                        <th>Customer</th>
                        <th>MR No</th>
                        <th>Ware House</th>
                        <th>Payment</th>
                        <th style="text-align: right;">Total</th>
                        <th style="text-align: right;">Discount</th>
                        <th style="text-align: right;">CGS</th>
                        <th style="text-align: right;">Received</th>
                        <th style="text-align: right;">Balance</th>
                        <th>Status</th>
                    </tr>
                </thead>
            </table>
        </section>

        <section class="pf-card">
            <div class="pf-card-head">
                <span class="pf-card-icon"><i class="fas fa-file-invoice"></i></span>
                <h2 class="pf-card-title">Posted bulk vouchers <span id="lblVoucherCount" class="pf-count"></span></h2>
            </div>
            <div class="pf-filters">
                <div class="pf-field">
                    <label class="pf-field-label" for="txtVFrom">Voucher from</label>
                    <input type="text" id="txtVFrom" class="form-control" />
                </div>
                <div class="pf-field">
                    <label class="pf-field-label" for="txtVTo">Voucher to</label>
                    <input type="text" id="txtVTo" class="form-control" />
                </div>
                <div class="pf-field pf-field--action">
                    <input type="button" id="btnVLoad" class="btn btn-primry" value="Load" />
                </div>
            </div>

            <table id="tblVouchers" class="table table-bordered table-striped table-condensed" style="width: 100%; margin-top: 10px;">
                <thead>
                    <tr>
                        <th>Voucher No</th>
                        <th>Voucher Date</th>
                        <th style="text-align: right;">Bills</th>
                        <th style="text-align: right;">Total DR</th>
                        <th style="text-align: right;">Total CR</th>
                        <th>Remarks</th>
                        <th>Status</th>
                        <th style="text-align: center;">View</th>
                    </tr>
                </thead>
            </table>
        </section>
    </div>
</asp:Content>
