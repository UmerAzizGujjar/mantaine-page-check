<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="BillingProcessView.aspx.cs" Inherits="PMS.BillingProcessView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/custom-modals.css" rel="stylesheet" />
    <script src="https://cdn.datatables.net/buttons/2.4.2/js/buttons.colVis.min.js"></script>
    <style>
        .bp-date-filter { display: flex; flex-wrap: wrap; align-items: center; gap: 10px 14px; margin-bottom: 10px; }
        .bp-date-filter label.fl { margin: 0; font-weight: 600; }
        .bp-date-filter input[type=date] { width: 160px; display: inline-block; }
        .bp-switch { position: relative; display: inline-block; width: 44px; height: 24px; margin: 0; }
        .bp-switch input { opacity: 0; width: 0; height: 0; }
        .bp-slider { position: absolute; cursor: pointer; inset: 0; background: #ccc; border-radius: 24px; transition: .2s; }
        .bp-slider:before { content: ""; position: absolute; height: 18px; width: 18px; left: 3px; top: 3px; background: #fff; border-radius: 50%; transition: .2s; }
        .bp-switch input:checked + .bp-slider { background: #2e7d32; }
        .bp-switch input:checked + .bp-slider:before { transform: translateX(20px); }

        .detail-container {
            padding: 15px;
        }

        .clickable-row {
            cursor: pointer;
        }

            .clickable-row:hover {
                background-color: #f0f8ff;
            }

        .logListBtn {
            background-color: #455a64 !important;
            color: #fff !important;
        }

            .logListBtn:hover {
                background-color: #2f3d45 !important;
            }

        .bill-log-body {
            background: #f4f6f9;
            font-size: 12px;
            color: #333;
            padding: 0 !important;
        }

        .bl-scroll {
            max-height: calc(100vh - 240px);
            overflow-y: auto;
            padding: 14px 16px;
        }

        .bl-loading {
            text-align: center;
            padding: 40px;
            color: #888;
        }

            .bl-loading i {
                margin-right: 6px;
            }

        .bl-empty {
            text-align: center;
            padding: 46px 10px;
            color: #8a8f98;
        }

        .bl-empty-ico {
            font-size: 46px;
            color: #d5dae0;
            display: block;
            margin-bottom: 12px;
        }

        .bl-empty-title {
            font-weight: 700;
            font-size: 13px;
            color: #5c636a;
            display: block;
        }

        .bl-empty-sub {
            font-size: 11.5px;
            color: #9aa1a8;
            margin-top: 4px;
        }

        .bl-card {
            background: #fff;
            border: 1px solid #e3e6ea;
            border-radius: 8px;
            margin-bottom: 14px;
            overflow: hidden;
            box-shadow: 0 1px 2px rgba(0,0,0,.05);
        }

        .bl-card-head {
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 8px 12px;
            padding: 9px 12px;
            background: #fbfcfe;
            border-bottom: 1px solid #eceef1;
        }

        .bl-seq {
            background: #EFA63E;
            color: #fff;
            font-weight: 700;
            font-size: 11px;
            padding: 3px 11px;
            border-radius: 12px;
            white-space: nowrap;
        }

        .bl-seq-newest {
            background: #cb8d35;
        }

        .bl-meta {
            color: #6b7280;
            font-size: 11px;
            display: flex;
            align-items: center;
            gap: 4px;
        }

            .bl-meta i {
                color: #b0b6be;
            }

        .bl-chips {
            margin-left: auto;
            display: flex;
            gap: 6px;
            flex-wrap: wrap;
        }

        .bl-chip {
            font-size: 10.5px;
            font-weight: 700;
            padding: 2px 9px;
            border-radius: 11px;
            white-space: nowrap;
        }

        .bl-chip-add {
            background: #e7f6ec;
            color: #1c7d43;
        }

        .bl-chip-del {
            background: #fdeaea;
            color: #b02a37;
        }

        .bl-chip-mod {
            background: #fff4e0;
            color: #9a6700;
        }

        .bl-sec-label {
            padding: 8px 12px;
            font-weight: 700;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: .04em;
            color: #69707a;
            background: #f6f8fa;
            border-bottom: 1px solid #eef0f3;
        }

        .bl-toggle {
            cursor: pointer;
            user-select: none;
            display: flex;
            align-items: center;
            gap: 6px;
        }

            .bl-toggle:hover {
                background: #eef3f8;
            }

            .bl-toggle .fa {
                font-size: 12px;
                color: #b0b6be;
                width: 10px;
            }

        .bl-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 12px;
            margin: 0;
        }

            .bl-table th {
                background: #f8fafb;
                font-size: 10.5px;
                text-transform: uppercase;
                letter-spacing: .03em;
                color: #7d8790;
                padding: 6px 12px;
                border-bottom: 1px solid #e6e9ed;
                white-space: nowrap;
                text-align: left;
            }

            .bl-table td {
                padding: 6px 12px;
                border-bottom: 1px solid #f0f2f4;
                vertical-align: top;
                font-size: 12px;
            }

        .bl-table-cmp th:first-child,
        .bl-table-cmp td:first-child {
            width: 17%;
        }

        .bl-fld {
            color: #5b636b;
            font-weight: 600;
            white-space: nowrap;
        }

        .bl-val {
            color: #6f767d;
        }

        .bl-val-old {
            color: #b02a37;
            font-weight: 600;
        }

        .bl-val-new {
            color: #1c7d43;
            font-weight: 700;
        }

        .bl-arrow {
            color: #c3c9cf;
            text-align: center;
            white-space: nowrap;
            width: 34px;
        }

        .bl-none {
            color: #9aa1a8;
            font-style: italic;
            padding: 8px 12px;
        }

        .bl-itemname {
            font-weight: 600;
            color: #37424c;
        }

        .bl-itemname-old {
            text-decoration: line-through;
            color: #b02a37;
        }

        .bl-itemname-new {
            font-weight: 700;
            color: #1c7d43;
        }

        .bl-diff-inline {
            list-style: none;
            margin: 0;
            padding: 0;
        }

            .bl-diff-inline li {
                font-size: 11.5px;
                padding: 1px 0;
                color: #4c545d;
            }

            .bl-diff-inline .d-old {
                color: #b02a37;
                text-decoration: line-through;
            }

            .bl-diff-inline .d-new {
                color: #1c7d43;
                font-weight: 700;
            }

        .bl-note {
            padding: 8px 12px 10px;
            color: #97a0a8;
            font-style: italic;
            font-size: 11px;
            border-top: 1px dashed #e2e6ea;
        }
    </style>
    <script type="text/javascript">
        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            initDateFilter();   // default: current month, filter ON
            $('#ddlMainDept').select2({ width: '190px' }).on('change', function () { reloadBillList(); });
            LoadPage();


        });

        /* ---------- Start / End date filter (default = current month) ---------- */
        function pad2(n) { return n < 10 ? '0' + n : '' + n; }
        function fmtYMD(d) { return d.getFullYear() + '-' + pad2(d.getMonth() + 1) + '-' + pad2(d.getDate()); }

        function setCurrentMonthDates() {
            var now = new Date();
            $('#txtFromDate').val(fmtYMD(new Date(now.getFullYear(), now.getMonth(), 1)));
            $('#txtToDate').val(fmtYMD(new Date(now.getFullYear(), now.getMonth() + 1, 0)));
        }

        function reloadBillList() {
            if ($.fn.DataTable.isDataTable('#tbloutPatients')) {
                $('#tbloutPatients').DataTable().ajax.reload();
            }
        }

        function initDateFilter() {
            setCurrentMonthDates();
            $('#chkDateFilter').prop('checked', true);
            $('#lblDateFilterState').text('Current month');

            // Toggle: ON = date filter (current month), OFF = clear dates and show all data
            $('#chkDateFilter').on('change', function () {
                if (this.checked) {
                    setCurrentMonthDates();
                    $('#txtFromDate, #txtToDate').prop('disabled', false);
                    $('#lblDateFilterState').text('Current month');
                } else {
                    $('#txtFromDate, #txtToDate').val('').prop('disabled', true);
                    $('#lblDateFilterState').text('All data');
                }
                reloadBillList();
            });

            $('#txtFromDate, #txtToDate').on('change', function () {
                var f = $('#txtFromDate').val(), t = $('#txtToDate').val();
                if (f && t && f > t) {
                    Swal.fire({ icon: 'warning', title: 'Invalid Date Range', text: 'Start date cannot be after end date.' });
                    return;
                }
                $('#lblDateFilterState').text('Custom range');
                reloadBillList();
            });
        }

        function IncrementReprintCount(billId) {
            if (!billId || billId == '0' || billId == '') return;

            $.ajax({
                type: "POST",
                url: "BillingProcess.aspx/IncrementReprintCount",
                data: JSON.stringify({ 'Bill_ID': parseInt(billId) }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    console.log("Reprint count updated for Bill ID: " + billId);
                },
                error: function (err) {
                    console.error("Failed to update reprint count", err);
                }
            });
        }


        function PrintBilling(Bill_ID) {
            var locationInfo = window.location;
            var user_name = '<%= AppConfig.Company_Name %>';
            IncrementReprintCount(Bill_ID);
            var reportPath;  // ✅ declared properly

            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx';
            }

            var url;

            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/' + reportPath +
                    '?ReportName=BillingBaseReport&ReportTitle=Billing Base Report&Bill_ID=' + Bill_ID + "&IsDuplicate=1";  // ✅ was using undefined `id`
            } else {
                url = '/' + reportPath +
                    '?ReportName=BillingBaseReport&ReportTitle=Billing Base Report&Bill_ID=' + Bill_ID + "&IsDuplicate=1";  // ✅ fixed localhost URL + uses reportPath
            }

            window.open(url, '_blank');
        }
        function PrintBilling1(Bill_ID) {
            var locationInfo = window.location;
            IncrementReprintCount(Bill_ID);
            var user_name = '<%= AppConfig.Company_Name %>';
            var reportPath;  // ✅ declared properly

            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx';
            }

            var url;

            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');

                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/' + reportPath +
                    '?ReportName=BillingBaseReport_Thermal&ReportTitle=Billing Base Report&Bill_ID=' + Bill_ID;  // ✅ was using undefined `id`
            } else {
                url = '/' + reportPath +
                    '?ReportName=BillingBaseReport_Thermal&ReportTitle=Billing Base Report&Bill_ID=' + Bill_ID;  // ✅ fixed localhost URL + uses reportPath
            }

            window.open(url, '_blank');
        }

      
      
        function LoadPage() {
            let savedVisibility = null;

            $.ajax({
                type: "POST",
                url: "BillingProcessView.aspx/GetUserColumnPreferences",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    if (response.d && response.d !== "") {
                        try {
                            savedVisibility = JSON.parse(response.d);
                        } catch (e) {
                            console.warn("Invalid column visibility JSON");
                        }
                    }
                },
                error: function () {
                    console.error("Failed to load column preferences");
                }
            });
            var table = $("#tbloutPatients").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                buttons: [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            window.location = 'BillingProcess.aspx';
                        }
                    },
                    'copy',
                    'excel',
                    'pdf',
                    {
                        extend: 'colvis',
                        text: '<i class="fa fa-columns"></i> Columns',
                        className: 'dt-button buttons-colvis',
                        collectionLayout: 'fixed two-column',
                        postfixButtons: ['colvisRestore']
                    }
                ],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "BillingProcessView.aspx/ViewList",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length,
                            sortColumn: data.columns[data.order[0].column].name,
                            sortColumnDirection: data.order[0].dir,
                            searchValue: data.search.value,
                            fromDate: $('#txtFromDate').val() || '',
                            toDate: $('#txtToDate').val() || '',
                            mainDept: $('#ddlMainDept').val() || ''
                        }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            callback({
                                draw: response.d.draw,
                                recordsTotal: response.d.recordsTotal,
                                recordsFiltered: response.d.recordsFiltered,
                                data: response.d.data
                            });
                        },
                        error: function (xhr, status, error) {
                            console.log(xhr.responseText);
                        }
                    });
                },
                "columns": [
                    { "data": "Bill_ID", "visible": false, "width": "0%" },
                    { "data": "isCancel", "visible": false, "orderable": false, "width": "0%" },
                    { "data": "Bill_No", "name": "Bill_No", "width": "5%", "orderable": true },
                    {
                        "data": "Bill_Date", "name": "Bill_Date",
                        "render": function (data, type, full) {
                            var date = full.Bill_Date;
                            // date = moment(date).format('DD-MMM-YYYY');
                            date = moment(date).format('DD-MMM-YYYY hh:mm A');
                            return date;
                        }, "width": "7%", "orderable": true
                    },
                    { "data": "MrNo", "name": "MrNo", "width": "7%", "orderable": true },
                    { "data": "Full_Name", "width": "10%", "orderable": false },
                    { "data": "Main_Department", "width": "8%", "orderable": false },
                    { "data": "Total_Amount", "width": "5%", "orderable": false },
                    { "data": "Discount_Percentage", "width": "3%", "orderable": false },
                    { "data": "Discount_Amount", "width": "5%", "orderable": false },
                    { "data": "Net_Amount", "width": "5%", "orderable": false },
                    { "data": "Received_Amount", "name": "Received_Amount", "width": "5%", "orderable": false },
                    {
                        "data": "Balance_Amount", "name": "Balance_Amount", "width": "5%", "orderable": false,
                        "render": function (data, type, full) {
                            var bal = parseFloat(data) || 0;
                            var ref = parseFloat(full.Refund_Amount) || 0;
                            // Move balance toward zero by the refunded amount
                            if (ref !== 0 && bal !== 0) {
                                bal = (bal < 0) ? (bal + ref) : (bal - ref);
                            }
                            return bal.toFixed(2);
                        }
                    },
                    {
                        "data": "Refund_Amount", "name": "Refund_Amount", "width": "5%", "orderable": false,
                        "render": function (data, type, full) {
                            if (data === null || data === undefined || data === '') return '0.00';
                            var n = Number(data);
                            return isNaN(n) ? data : n.toFixed(2);
                        }
                    },
                    { "data": "Operator", "width": "6%", "orderable": false },

                    {
                        render: function (data, type, full) {
                            if (full.isCancel === true) {
                                return '<span style="color:#721c24; font-weight:bold;">Cancelled</span>';
                            }
                            // Admission finalized: older (non-final) bills are locked
                            var logBtn = '<a class="logListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="openBillLogs(' + full.Bill_ID + ',\'' + full.Bill_No + '\');return false;" title="View Change History"><i class="fa fa-history"></i></a>';

                            if (full.Admission_Has_Final_Bill === true && full.Is_Final_Bill !== true) {
                                return '<span style="background:#eef0f3;color:#6b7280;font-size:10.5px;font-weight:700;padding:3px 9px;border-radius:11px;white-space:nowrap;margin-right:4px;display:inline-block;vertical-align:middle;">Bill Finalized</span>' + logBtn;
                            }

                            var finalBadge = '';
                            if (full.Is_Final_Bill === true) {
                                finalBadge = '<span style="background:#e7f6ec;color:#1c7d43;font-size:10.5px;font-weight:700;padding:3px 9px;border-radius:11px;white-space:nowrap;margin-right:4px;display:inline-block;vertical-align:middle;">Final Bill</span>';
                            }
                            var res = '<a href="#" class="editListBtn" onclick="editOpen(' + full.Bill_ID + ')" style="border-radius: 4px;color: white; padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>'

                            var Del = '<a class="delListBtn" href="#" style="border-radius: 4px;margin-left: 4px; color: white; padding: 5px 8px 5px 8px;" onclick=cancelPatient(this)><i class="fa fa-trash" aria-hidden="true"></i></a>';

                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintBilling(' + full.Bill_ID + ')" id="btnprint"><i class="fa fa-print"></i></a>';

                            var print1 = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintBilling1(' + full.Bill_ID + ')" id="btnprint1"><i class="fa fa-print"></i></a>';

                            // Check if Balance_Amount is greater than 0 before showing receipt button
                            var receipt = '';
                            var balanceAmount = parseFloat(full.Balance_Amount);
                            if (balanceAmount > 0) {
                                receipt = '<a class="editListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="openReceipt(\'' + full.Bill_No + '\', ' + full.Bill_ID + ')" title="Add Receipt"><i class="fa fa-money"></i></a>';
                            } else {
                                // Optional: Show a disabled receipt button or just nothing
                                // receipt = '<a class="disabledBtn" style="border-radius: 4px;margin-left: 4px;color: gray;padding: 5px 8px 5px 8px; cursor: not-allowed; opacity: 0.5;" title="Balance is zero - No receipt needed"><i class="fa fa-money"></i></a>';
                            }

                            // Advance Refund button only when there is a refundable negative balance and no refund yet
                            var advRefund = '';
                            var hasRefund = (full.Has_Refund === true || full.Has_Refund === 'true');
                            var negBal = parseFloat(full.Negative_Balance) || 0;
                            if (!hasRefund && negBal > 0) {
                                advRefund = '<a class="advRefundBtn" style="border-radius: 4px;margin-left: 4px;padding: 5px 8px 5px 8px;" href="#" onclick="openAdvanceRefund(' + full.Bill_ID + ');return false;" title="Advance Refund"><i class="fa fa-reply"></i></a>';
                            }

                            var result;
                            result = finalBadge + res + logBtn + Del + print + print1 + receipt + advRefund;
                            return result;
                        },
                        "width": "10%",
                        "orderable": false
                    }

                ],
                "createdRow": function (row, data, dataIndex) {
                    $(row).addClass('clickable-row');
                    $(row).attr('data-bill-id', data.Bill_ID);
                    if (data.Is_Final_Bill === true) {
                        $(row).attr('data-final-bill', '1');
                        $(row).css('background-color', '#d4edda');
                        $(row).find('td').css('color', '#155724');
                    }
                    if (data.isCancel === true) {
                        $(row).attr('data-cancelled', '1');
                        $(row).css('background-color', '#f8d7da');
                        $(row).find('td').css('color', '#721c24');
                    }
                },
                "initComplete": function (settings, json) {
                    const api = this.api();
                    if (savedVisibility && Array.isArray(savedVisibility)) {
                        if (savedVisibility.length === api.columns().count()) {
                            api.columns().every(function (index) {
                                this.visible(savedVisibility[index]);
                            });
                        }
                    }
                    api.on('column-visibility.dt', function (e, settings, column, state) {
                        let currentVis = [];
                        api.columns().every(function () {
                            currentVis.push(this.visible());
                        });
                        PageMethods.SaveUserColumnPreferences(
                            JSON.stringify(currentVis),
                            function () {
                                console.log("Column preferences saved");
                            },
                            function (error) {
                                console.error("Failed to save preferences:", error);
                            }
                        );
                    });

                    var lengthContainer = document.querySelector('#tbloutPatients_length');
                    var lengthDropdown = document.querySelector('#tbloutPatients_length select');
                    var label = document.querySelector('#tbloutPatients_length label');

                    if (lengthDropdown && label && lengthContainer) {
                        var labelText = document.createElement('span');
                        labelText.textContent = 'Show entries ';
                        labelText.style.marginTop = '10px';
                        labelText.style.display = 'inline-block';

                        lengthDropdown.style.width = '60px';
                        label.innerHTML = '';
                        label.style.display = 'inline-flex';
                        label.style.marginTop = '17px';
                        label.appendChild(labelText);
                        label.appendChild(lengthDropdown);
                    }
                }
            });

            $('#tbloutPatients tbody').on('click', 'tr.clickable-row', function (e) {
                if ($(e.target).closest('a,button,input').length > 0) {
                    return;
                }

                var tr = $(this);
                if (tr.attr('data-cancelled') === '1') {
                    return;
                }
                var row = table.row(tr);
                var billId = tr.attr('data-bill-id');

                if (row.child.isShown()) {
                    row.child.hide();
                    tr.removeClass('shown');
                } else {
                    table.rows().every(function () {
                        if (this.child.isShown()) {
                            this.child.hide();
                            $(this.node()).removeClass('shown');
                        }
                    });

                    row.child('<div style="padding:20px;text-align:center;">Loading...</div>').show();
                    tr.addClass('shown');
                    LoadBillDetails(billId, row);
                }
            });
        }

        function LoadBillDetails(billId, row) {
            $.ajax({
                type: "POST",
                url: "BillingProcessView.aspx/GetBillDetails",
                data: JSON.stringify({ billId: billId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d) {
                        var details = JSON.parse(response.d);
                        var html = BuildDetailsHTML(details);
                        row.child(html).show();
                    }
                },
                error: function (xhr, status, error) {
                    row.child('<div style="padding:20px;color:red;">Error loading details</div>').show();
                    console.log(xhr.responseText);
                }
            });
        }
        function openReceipt(billNo, billId) {
         
            window.location.href = 'Receipts.aspx?Bill_No=' + encodeURIComponent(billNo) + '&Bill_ID=' + billId;
        }

        function openAdvanceRefund(billId) {
            $.ajax({
                type: "POST",
                url: "BillingProcessView.aspx/GetBillAdvanceRefundInfo",
                data: JSON.stringify({ billId: billId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var d = JSON.parse(response.d);
                    if (d.Error) {
                        Swal.fire({ icon: 'error', title: 'Error!', text: d.Error, confirmButtonText: 'OK' });
                        return;
                    }
                    var nb = parseFloat(d.NegativeBalance) || 0;
                    if (nb <= 0) {
                        Swal.fire({ icon: 'info', title: 'No Negative Balance', text: 'There is no refundable negative balance for this bill/admission.', confirmButtonText: 'OK' });
                        return;
                    }
                    Swal.fire({
                        title: 'Advance Refund',
                        html: '<div style="text-align:left;font-size:14px;line-height:1.6;">'
                            + '<div><b>Bill:</b> ' + (d.Bill_No || '') + '</div>'
                            + '<div><b>Patient:</b> ' + (d.Full_Name || '') + '</div>'
                            + '<div><b>Total Advance:</b> ' + d.Total_Advance + '</div>'
                            + '<div><b>Bill Net:</b> ' + d.BillNet + '</div>'
                            + '<div><b>Already Refunded:</b> ' + d.AlreadyRefunded + '</div>'
                            + '<div style="margin-top:6px;"><b>Negative Balance:</b> <span style="color:#b02a37;font-weight:700;">' + nb + '</span></div>'
                            + '<input id="swalRefundAmt" class="swal2-input" type="number" value="' + nb + '" step="1" min="1" style="margin-top:10px;">'
                            + '<textarea id="swalRefundRemarks" class="swal2-textarea" placeholder="Remarks" style="margin-top:6px;"></textarea>'
                            + '</div>',
                        showCancelButton: true,
                        confirmButtonText: 'Refund',
                        focusConfirm: false,
                        preConfirm: function () {
                            var amt = parseFloat(document.getElementById('swalRefundAmt').value) || 0;
                            if (amt <= 0) { Swal.showValidationMessage('Amount must be greater than zero'); return false; }
                            if (amt > nb) { Swal.showValidationMessage('Amount cannot exceed negative balance (' + nb + ')'); return false; }
                            return {
                                amount: Math.round(amt),
                                remarks: document.getElementById('swalRefundRemarks').value
                            };
                        }
                    }).then(function (res) {
                        if (!res.isConfirmed) return;
                        $.ajax({
                            type: "POST",
                            url: "BillingProcessView.aspx/SaveBillAdvanceRefund",
                            data: JSON.stringify({
                                billId: billId,
                                refundDate: new Date().toISOString(),
                                remarks: res.value.remarks,
                                amount: res.value.amount
                            }),
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            success: function (r2) {
                                var out = r2.d;
                                if (out && out.indexOf('Error') === 0) {
                                    Swal.fire({ icon: 'error', title: 'Error!', text: out, confirmButtonText: 'OK' });
                                    return;
                                }
                                Swal.fire({ icon: 'success', title: 'Saved', text: 'Advance refund created (pending approval). Refund No: ' + out, confirmButtonText: 'OK' });
                                $('#tbloutPatients').DataTable().ajax.reload(null, false);
                            },
                            error: function (x, e) {
                                Swal.fire({ icon: 'error', title: 'Error!', text: e, confirmButtonText: 'OK' });
                            }
                        });
                    });
                },
                error: function (x, e) {
                    Swal.fire({ icon: 'error', title: 'Error!', text: 'Could not load refund info', confirmButtonText: 'OK' });
                }
            });
        }
        function BuildDetailsHTML(details) {
            var html = '<div class="detail-container">';
            var categories = {
                'Services': [],
                'Lab Tests': [],
                'Radiology': [],
                'Pharmacy': [],
                'Consultation': [],
                'Other': []
            };

            details.forEach(function (item) {
                var category = 'Other';
                var itemType = (item.Item_Type || '').toLowerCase();

                if (itemType === 'service' || itemType === 'services') {
                    category = 'Services';
                } else if (itemType === 'test') {
                    if (item.Test_Main_Department === '001') {
                        category = 'Lab Tests';
                    } else {
                        category = 'Radiology';
                    }
                } else if (itemType === 'pharmacy') {
                    category = 'Pharmacy';
                } else if (itemType === 'consultation') {
                    category = 'Consultation';
                }

                categories[category].push(item);
            });

            html += '<table class="details-table" style="width: 100%; border-collapse: collapse; text-align: left; font-family: sans-serif;">';
            html += '<thead>';
            html += '<tr style="background-color: #f4f4f4; border-bottom: 2px solid #ddd;">';
            html += '<th style="padding: 10px; width: 70%;">Item Name</th>';
            html += '<th style="padding: 10px; width: 10%;">Amount</th>';
            html += '<th style="padding: 10px; width: 10%;">Discount</th>';
            html += '<th style="padding: 10px; width: 10%;">Net Amount</th>';
            html += '</tr>';
            html += '</thead>';
            html += '<tbody>';

            for (var cat in categories) {
                if (categories[cat].length > 0) {
                    html += '<tr style="background-color: #e9ecef;">';
                    html += '<td colspan="4" style="padding: 8px 10px; font-weight: bold;">' + cat + '</td>';
                    html += '</tr>';

                    categories[cat].forEach(function (item) {
                        var itemName = item.Item_Name || item.Description || 'N/A';
                        var amount = (item.Amount || 0).toFixed(2);
                        var discount = (item.Discount_Amount || 0).toFixed(2);
                        var net = (item.Net_Amount || 0).toFixed(2);

                        html += '<tr style="border-bottom: 1px solid #eee;">';
                        html += '<td style="padding: 10px;">' + itemName + '</td>';
                        html += '<td style="padding: 10px;">' + amount + '</td>';
                        html += '<td style="padding: 10px;">' + discount + '</td>';
                        html += '<td style="padding: 10px;">' + net + '</td>';
                        html += '</tr>';
                    });
                }
            }

            html += '</tbody>';
            html += '</table>';
            html += '</div>';
            return html;
        }


        function editOpen(id) {
            window.open("BillingProcess.aspx?Bill_ID=" + id + "");
        }
        function CancelConfirm(anchorTag) {


            var row = $(anchorTag).parents('tr')[0];
            var Bill_ID = $($(row).find('td')[0]).text();
            var BillNo = $($(row).find('td')[1]).text();

            $("#tbloutPatients tr").find('th:eq(14)').show();
            $("#tbloutPatients tr").find('td:eq(14)').show();
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="show" style="width:100px;"><input type="text" id="txtCancel" onchange="cancelPatient(this)"/></span>';

        }
        function cancelPatient(anchorTag) {

            var row = $(anchorTag).parents('tr')[0];
            var Bill_No = $($(row).find('td')[0]).text();
            if (confirm('Are you sure want to Cancel this Bill:- ' + Bill_No)) {
                PageMethods.CancelPatient(Bill_No, function (msg) {
                    if (msg == "Allowdlt") {
                        alert('You have no right to Cancel. ')

                    }
                    else if (msg == "success") {

                        row.remove();
                    }
                    else {
                        alert('Unable to Cancel this patient, because this patient has uncanceled Reciept ')
                    }

                },

                );
            }

            window.location.href = "BillingProcessView.aspx";
        }

        function deleteConfirm(anchorTag) {

            var row = $(anchorTag).parents('tr')[0];

            var Bill_ID = $($(row).find('td')[0]).text();

            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(Bill_ID, function (msg) {
                    if (msg == '')
                        row.remove();
                    else
                        alert(msg);
                }, OnFail);
            }
        }

        // ================= BILL CHANGE HISTORY (Ar_Billing_Logs) =================

        var BLMasterFields = [
            { k: 'Total_Amount', l: 'Total Amount', kind: 'money' },
            { k: 'Discount_Amount', l: 'Discount Amount', kind: 'money' },
            { k: 'Net_Amount', l: 'Net Amount', kind: 'money' },
            { k: 'Received_Amount', l: 'Received Amount', kind: 'money' },
            { k: 'Balance_Amount', l: 'Balance Amount', kind: 'money' },
            { k: 'Cash_In_Hand', l: 'Cash In Hand', kind: 'money' },
            { k: 'Bank_Account', l: 'Bank Account', kind: 'text' },
            { k: 'Bill_Date', l: 'Bill Date', kind: 'date' },
            { k: 'Main_Department', l: 'Department', kind: 'dept' },
            { k: 'BillType', l: 'Bill Type', kind: 'text' },
            { k: 'In_Patient_ID', l: 'In-Patient ID', kind: 'int' }
        ];

        var BLItemFields = [
            { k: 'Qty', l: 'Qty', kind: 'qty' },
            { k: 'Amount', l: 'Amount', kind: 'money' },
            { k: 'Discount_Amount', l: 'Discount', kind: 'money' },
            { k: 'Net_Amount', l: 'Net Amount', kind: 'money' },
            { k: 'Doctor_Share', l: 'Doctor Share', kind: 'money' },
            { k: 'Hospital_Share', l: 'Hospital Share', kind: 'money' },
            { k: 'Doctor_id', l: 'Doctor ID', kind: 'int' },
            { k: 'Item_Name', l: 'Item Name', kind: 'text' }
        ];

        var BLDeptNames = { '001': 'Lab', '002': 'Ultrasound', '003': 'X-Ray', '004': 'CT Scan', '005': 'Blood Bank', '006': 'Consultant' };

        function escHtml(s) {
            return String(s == null ? '' : s)
                .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
        }

        function fmtMoney(v) {
            if (v === null || v === undefined || v === '') return '';
            var n = Number(v);
            if (isNaN(n)) return String(v);
            var neg = n < 0;
            n = Math.abs(n);
            var parts = n.toFixed(2).split('.');
            parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
            return (neg ? '-' : '') + parts[0] + '.' + parts[1];
        }

        function fmtQty(v) {
            if (v === null || v === undefined || v === '') return '';
            var n = Number(v);
            if (isNaN(n)) return String(v);
            return Number.isInteger(n) ? String(n) : n.toFixed(2);
        }

        var BLMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

        function normDateText(v) {
            if (v === null || v === undefined || v === '') return '';
            var s = String(v);
            var m = s.match(/^\/Date\((-?\d+)\)\/$/);
            var d = null;
            if (m) {
                d = new Date(Number(m[1]));
            } else if (/^\d{4}-\d{2}-\d{2}/.test(s)) {
                d = new Date(s.replace(' ', 'T'));
            } else {
                return s;
            }
            if (isNaN(d.getTime())) return s;
            var p = function (x) { return x < 10 ? '0' + x : '' + x; };
            return p(d.getDate()) + '-' + BLMonths[d.getMonth()] + '-' + d.getFullYear() + ' ' + p(d.getHours()) + ':' + p(d.getMinutes());
        }

        function normByKind(kind, v) {
            if (kind === 'money') return fmtMoney(v);
            if (kind === 'qty') return fmtQty(v);
            if (kind === 'int') return (v === null || v === undefined || v === '') ? '' : String(Number(v));
            if (kind === 'date') return normDateText(v);
            if (kind === 'dept') {
                if (v === null || v === undefined || v === '') return '';
                var key = String(v).trim();
                return BLDeptNames[key] ? BLDeptNames[key] : String(v);
            }
            return (v === null || v === undefined) ? '' : String(v);
        }

        function hasOwn(o, k) {
            return o !== null && typeof o === 'object' && Object.prototype.hasOwnProperty.call(o, k);
        }

        function detailArray(state) {
            if (!state || !state.details || !state.details.Billing_Details) return [];
            return state.details.Billing_Details;
        }

        function diffMaster(before, after) {
            var rows = [];
            if (!before || !after) return rows;
            BLMasterFields.forEach(function (f) {
                if (!hasOwn(before.master, f.k) || !hasOwn(after.master, f.k)) return;
                var b = normByKind(f.kind, before.master[f.k]);
                var a = normByKind(f.kind, after.master[f.k]);
                if (b !== a) rows.push({ label: f.l, prev: b, cur: a });
            });
            return rows;
        }

        function diffDetails(before, after) {
            var result = { added: [], removed: [], modified: [] };
            if (!before || !after) return result;
            var prevArr = detailArray(before);
            var nextArr = detailArray(after);
            var keyOf = function (it) {
                var id = (it.Item_ID === null || it.Item_ID === undefined) ? '' : String(it.Item_ID);
                var type = (it.Item_Type === null || it.Item_Type === undefined) ? '' : String(it.Item_Type);
                return id + '|' + type;
            };
            var map = function (arr) {
                var m = {};
                arr.forEach(function (it) { m[keyOf(it)] = it; });
                return m;
            };
            var prevMap = map(prevArr);
            var nextMap = map(nextArr);

            nextArr.forEach(function (it) {
                var k = keyOf(it);
                if (!hasOwn(prevMap, k)) result.added.push(it);
            });
            prevArr.forEach(function (it) {
                var k = keyOf(it);
                if (!hasOwn(nextMap, k)) {
                    result.removed.push(it);
                } else {
                    var beforeIt = prevMap[k];
                    var changes = [];
                    BLItemFields.forEach(function (f) {
                        var b = normByKind(f.kind, beforeIt[f.k]);
                        var a = normByKind(f.kind, it[f.k]);
                        if (b !== a) changes.push({ label: f.l, prev: b, cur: a });
                    });
                    if (changes.length > 0) result.modified.push({ item: it, changes: changes });
                }
            });
            return result;
        }

        function itemRowCells(item, extraClass) {
            return '<tr><td class="bl-itemname ' + (extraClass || '') + '">' + escHtml(item.Item_Name) + '</td>'
                + '<td>' + fmtQty(item.Qty) + '</td>'
                + '<td>' + fmtMoney(item.Amount) + '</td>'
                + '<td>' + fmtMoney(item.Discount_Amount) + '</td>'
                + '<td>' + fmtMoney(item.Net_Amount) + '</td></tr>';
        }

        function buildItemSectionHTML(diff) {
            var html = '';
            var any = diff.added.length > 0 || diff.removed.length > 0 || diff.modified.length > 0;
            if (!any) return html;

            html += '<div class="bl-sec-label bl-toggle bl-toggle-card" data-target="blcard' + (BLCardSeq++) + '">'
                + '<i class="fa fa-caret-right"></i> Item Changes'
                + '<span class="bl-chip bl-chip-add">+' + diff.added.length + '</span>'
                + '<span class="bl-chip bl-chip-del">-' + diff.removed.length + '</span>'
                + '<span class="bl-chip bl-chip-mod">~' + diff.modified.length + '</span>'
                + '</div>';

            html += '<div id="blcard' + (BLCardSeq - 1) + '" style="display:none;">';

            if (diff.added.length > 0) {
                html += '<div class="bl-sub-sec-head" style="color:#1c7d43;padding:8px 12px 2px;font-weight:700;">Items Added <span class="bl-chip bl-chip-add">' + diff.added.length + '</span></div>';
                html += '<table class="bl-table"><thead><tr><th>Item</th><th>Qty</th><th>Amount</th><th>Discount</th><th>Net</th></tr></thead><tbody>';
                diff.added.forEach(function (it) { html += itemRowCells(it, 'bl-itemname-new'); });
                html += '</tbody></table>';
            }

            if (diff.removed.length > 0) {
                html += '<div class="bl-sub-sec-head" style="color:#b02a37;padding:8px 12px 2px;font-weight:700;">Items Removed <span class="bl-chip bl-chip-del">' + diff.removed.length + '</span></div>';
                html += '<table class="bl-table"><thead><tr><th>Item</th><th>Qty</th><th>Amount</th><th>Discount</th><th>Net</th></tr></thead><tbody>';
                diff.removed.forEach(function (it) { html += itemRowCells(it, 'bl-itemname-old'); });
                html += '</tbody></table>';
            }

            if (diff.modified.length > 0) {
                html += '<div class="bl-sub-sec-head" style="color:#9a6700;padding:8px 12px 2px;font-weight:700;">Items Modified <span class="bl-chip bl-chip-mod">' + diff.modified.length + '</span></div>';
                html += '<table class="bl-table"><thead><tr><th>Item</th><th>Field Changes</th></tr></thead><tbody>';
                diff.modified.forEach(function (mod) {
                    html += '<tr><td class="bl-itemname">' + escHtml(mod.item.Item_Name) + '</td><td><ul class="bl-diff-inline">';
                    mod.changes.forEach(function (c) {
                        html += '<li>' + escHtml(c.label) + ': <span class="d-old">' + escHtml(c.prev) + '</span> &rarr; <span class="d-new">' + escHtml(c.cur) + '</span></li>';
                    });
                    html += '</ul></td></tr>';
                });
                html += '</tbody></table>';
            }

            html += '</div>';
            return html;
        }

        function buildRevisionHTML(evt, idx, total) {
            var d = diffMaster(evt.before, evt.after);
            var dd = diffDetails(evt.before, evt.after);
            var noCurrent = (evt.after === null);

            var chips = '';
            if (d.length > 0) chips += '<span class="bl-chip bl-chip-mod">' + d.length + ' field' + (d.length > 1 ? 's' : '') + '</span>';
            if (dd.added.length > 0) chips += '<span class="bl-chip bl-chip-add">+' + dd.added.length + ' item' + (dd.added.length > 1 ? 's' : '') + '</span>';
            if (dd.removed.length > 0) chips += '<span class="bl-chip bl-chip-del">-' + dd.removed.length + ' item' + (dd.removed.length > 1 ? 's' : '') + '</span>';

            var html = '<div class="bl-card">';
            html += '<div class="bl-card-head">';
            html += '<span class="bl-seq ' + (idx === 0 ? 'bl-seq-newest' : '') + '">' + (idx === 0 ? 'Latest Update' : 'Update #' + (total - idx)) + '</span>';
            html += '<span class="bl-meta"><i class="fa fa-user-o"></i> ' + escHtml(evt.user) + '</span>';
            html += '<span class="bl-meta"><i class="fa fa-clock-o"></i> ' + escHtml(evt.time) + '</span>';
            html += '<span class="bl-chips">' + chips + '</span>';
            html += '</div>';

            html += '<div class="bl-card-body">';
            if (noCurrent) {
                html += '<div class="bl-note">Current bill data is no longer available (bill may have been deleted). Only the stored snapshot is shown.</div>';
            }

            if (d.length > 0) {
                html += '<div class="bl-sec-label">Bill Summary &mdash; Changed Fields</div>';
                html += '<div style="overflow-x:auto;"><table class="bl-table bl-table-cmp"><thead><tr><th>Field</th><th>Previous Value</th><th></th><th>Updated Value</th></tr></thead><tbody>';
                d.forEach(function (row) {
                    html += '<tr><td class="bl-fld">' + escHtml(row.label) + '</td>'
                        + '<td class="bl-val bl-val-old">' + (row.prev === '' ? '&mdash;' : escHtml(row.prev)) + '</td>'
                        + '<td class="bl-arrow"><i class="fa fa-long-arrow-right"></i></td>'
                        + '<td class="bl-val bl-val-new">' + (row.cur === '' ? '&mdash;' : escHtml(row.cur)) + '</td></tr>';
                });
                html += '</tbody></table></div>';
            } else {
                html += '<div class="bl-none">No summary (amount / discount) field changes in this update.</div>';
            }

            html += buildItemSectionHTML(dd);
            if (!dd.added.length && !dd.removed.length && !dd.modified.length) {
                html += '<div class="bl-note">No item level changes in this update.</div>';
            }
            html += '</div>';
            html += '</div>';
            return html;
        }

        function openBillLogs(billId, billNo) {
            var $body = $('#blModalBody');
            $body.html('<div class="bl-loading"><i class="fa fa-spinner fa-spin"></i>Loading change history&hellip;</div>');
            $('#blCount').text('');
            $('#billLogTitle').text('Bill Change History' + (billNo ? ' - ' + billNo : ''));
            $('#billLogModal').modal({ backdrop: 'static' });

            $.ajax({
                type: "POST",
                url: "BillingProcessView.aspx/GetBillAuditLogs",
                data: JSON.stringify({ billId: billId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    try {
                        var payload = JSON.parse(response.d);
                        renderBillLogs(payload);
                    } catch (ex) {
                        $body.html('<div class="bl-empty"><i class="fa fa-exclamation-triangle bl-empty-ico" style="color:#d8a25a;"></i><span class="bl-empty-title">Unable to load history</span><span class="bl-empty-sub">' + escHtml(ex.message) + '</span></div>');
                    }
                },
                error: function (err) {
                    $body.html('<div class="bl-empty"><i class="fa fa-exclamation-triangle bl-empty-ico" style="color:#d8a25a;"></i><span class="bl-empty-title">Unable to load history</span><span class="bl-empty-sub">Server error occurred while reading logs.</span></div>');
                }
            });
        }

        function renderBillLogs(payload) {
            var $body = $('#blModalBody');
            if (!payload || payload.error) {
                $body.html('<div class="bl-empty"><i class="fa fa-exclamation-triangle bl-empty-ico" style="color:#d8a25a;"></i><span class="bl-empty-title">Unable to load history</span><span class="bl-empty-sub">' + escHtml(payload && payload.error ? payload.error : 'No data returned.') + '</span></div>');
                return;
            }

            var logs = payload.logs || [];
            var current = payload.current;

            if (logs.length === 0) {
                $body.html('<div class="bl-empty"><i class="fa fa-history bl-empty-ico"></i><span class="bl-empty-title">No update history found</span><span class="bl-empty-sub">Changes are logged automatically each time this bill is edited and saved.</span></div>');
                $('#blCount').text('');
                return;
            }

            var snapshots = logs.map(function (l) { return { master: l.Master, details: l.Details }; });
            var hasCurrent = current && current.master;
            if (hasCurrent) {
                snapshots.push({ master: current.master, details: current.details });
            }

            var events = [];
            for (var i = 0; i < logs.length; i++) {
                events.push({
                    user: logs[i].UserName,
                    time: logs[i].TimeText,
                    before: snapshots[i],
                    after: (i + 1 < snapshots.length) ? snapshots[i + 1] : null
                });
            }
            events.reverse();

            BLCardSeq = 0;
            var total = events.length;
            var html = '';
            for (var j = 0; j < events.length; j++) {
                html += buildRevisionHTML(events[j], j, total);
            }
            $body.html(html);
            $('#blCount').text(total + ' recorded update' + (total > 1 ? 's' : ''));
        }

        var BLCardSeq = 0;

        $(document).on('click', '.bl-toggle-card', function () {
            var id = $(this).data('target');
            $('#' + id).toggle();
            $(this).find('.fa').toggleClass('fa-caret-right fa-caret-down');
        });

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-5 col-md-12 col-sm-12 bp-date-filter">
            <label class="fl" for="txtFromDate">Start Date</label>
            <input type="date" id="txtFromDate" class="form-control" />
            <label class="fl" for="txtToDate">End Date</label>
            <input type="date" id="txtToDate" class="form-control" />
            <label class="fl" for="chkDateFilter">Date Filter</label>
            <label class="bp-switch" title="Off = clear dates and show all data">
                <input type="checkbox" id="chkDateFilter" checked="checked" />
                <span class="bp-slider"></span>
            </label>
            <span id="lblDateFilterState" class="text-muted">Current month</span>
         
        </div>
        <div class="col-lg-2 col-md-6 col-sm-12">
            <label class="fl" for="ddlMainDept" style="margin-left: 18px;">Main Department</label>
            <select id="ddlMainDept" class="form-control" style="width: 190px;">
                <option value="">All</option>
                <option value="01">OPD</option>
                <option value="02">Emergency</option>
                <option value="03">IPD</option>
            </select>
        </div>
    </div>
    <div class="row">
        <div class="table-container">
            <table class="table table-hover table-striped table-bordered" id="tbloutPatients">
                <thead id="ihead">
                    <tr>
                        <th class="hide">Bill ID</th>
                        <th class="hide">Is Cancel</th>
                        <th>Bill No</th>
                        <th>Bill Date</th>
                        <th>MR No</th>
                        <th>Name</th>
                        <th>Main Dept</th>
                        <th>Total Amount</th>
                        <th>Disc %</th>
                        <th>Disc Amount</th>
                        <th>Net Amount</th>
                        <th>Received Amount</th>
                        <th>Balance Amount</th>
                        <th>Refund Amount</th>
                        <th>Operator</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="ibody">
                </tbody>
            </table>
        </div>
    </div>

    <div class="modal fade" id="billLogModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog custom-modal-dialog custom-modal-dialog-xl" role="document">
            <div class="modal-content custom-modal-content">

                <div class="modal-header custom-modal-header">
                    <div class="custom-modal-title-wrap">
                        <span class="custom-modal-icon"><i class="fa fa-history"></i></span>
                        <h4 class="modal-title custom-modal-title" id="billLogTitle">Bill Change History</h4>
                    </div>
                    <button type="button" class="custom-modal-close" data-dismiss="modal" aria-label="Close">
                        <i class="fa fa-times"></i>
                    </button>
                </div>

                <div class="modal-body custom-modal-body bill-log-body">
                    <div class="bl-scroll">
                        <div id="blModalBody"></div>
                    </div>
                </div>

                <div class="custom-modal-footer">
                    <span class="custom-modal-count" id="blCount"></span>
                    <button type="button" class="custom-modal-btn-close" data-dismiss="modal">
                        <i class="fa fa-times-circle"></i> Close
                    </button>
                </div>

            </div>
        </div>
    </div>
</asp:Content>
