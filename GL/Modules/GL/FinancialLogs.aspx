<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="FinancialLogs.aspx.cs" Inherits="PMS.VoucherView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <!-- CSS only -->
 <link rel="stylesheet" href="table-style/bootstrap.css">
 <link rel="stylesheet" href="table-style/jquery-ui.css">
 <link rel="stylesheet" href="table-style/dataTables.jqueryui.min.css">
 <link rel="stylesheet" href="table-style/buttons.jqueryui.min.css">
 <!-- JS, Popper.js, and jQuery -->
 <script src="Scripts/jquery-ui.js"></script>
 <script src="Scripts/jquery-ui.min.js"></script>
 <link href="Styles/jquery.datetimepicker.css" rel="stylesheet" />
 <script src="table-style/jquery.dataTables.min.js"></script>
 <script src="table-style/dataTables.jqueryui.min.js"></script>
 <script src="table-style/dataTables.buttons.min.js"></script>
 <script src="table-style/buttons.jqueryui.min.js"></script>
 <script src="table-style/jszip.min.js"></script>
 <script src="table-style/pdfmake.min.js"></script>
 <script src="table-style/vfs_fonts.js"></script>
 <script src="table-style/buttons.html5.min.js"></script>
 <script src="table-style/buttons.print.min.js"></script>
 <script src="table-style/buttons.colVis.min.js"></script>
 <style type="text/css">
     .sidebar.h-sidebar .nav-list > li > a {
         text-align: center !important;
         line-height: 22px !important;
         height: auto !important;
         font-family: Arial, sans-serif !important;
         padding: 10px 14px !important;
         font-weight: bold !important;
     }

     #th-brnch {
         width: 200px !important;
     }

     .nav-list > li .submenu > li.hover > a {
         font-size: 13px !important;
         font-family: Arial, sans-serif !important;
         font-weight: bold !important;
     }

     .table {
         width: 100%;
         font-size: small;
         line-height: 1.5px;
         font-weight: 400 !important;
     }

         .table > tbody > tr > td {
             line-height: 1.75;
         }

         .table > thead > tr > th {
             line-height: 0.75;
         }

     .dataTables_wrapper .dataTables_paginate {
         font-size: small;
         width: 300px;
     }

     .main input {
         margin-bottom: -5px !important;
     }

     .buttons-copy {
         width: 20%;
         border-radius: 12px;
         background-color: #8b8f8c !important;
         color: white !important;
     }

     .buttons-excel {
         width: 20%;
         border-radius: 12px;
         background-color: #5e8a6a !important;
         color: white !important;
     }

     .buttons-pdf {
         width: 20%;
         border-radius: 12px;
         background-color: #e04343 !important;
         color: white !important;
     }

     .buttons-colvis {
         width: 38%;
         border-radius: 12px;
         background-color: #4052a1 !important;
         color: white !important;
     }

     div.dt-buttons {
         position: relative;
         float: left;
         width: 34%;
     }

     .ui-button-text-only .ui-button-text {
         font-weight: 900;
     }

     .dataTables_info {
         font-size: 14px;
         font-weight: 700 !important;
     }

     .dataTables_wrapper .ui-toolbar {
         padding: 3px;
     }

     table.dataTable thead th div.DataTables_sort_wrapper span {
         display: none;
     }

     #txt_date {
         height: 32px;
     }

     #check {
         width: 5% !important;
     }

     .info_btn {
         border-radius: 12px;
         width: 7%;
         margin-bottom: 7px;
         font-size: 14px;
         font-weight: 700;
     }

     .dataTables_filter input {
         border-radius: 15px !important;
     }

     body {
         font-weight: 700;
     }

     #ui-datepicker-div {
         width: 20% !important;
     }

     .btn-addnew {
         top: -5px !important;
     }

     .fa-pencil {
         color: green !important;
     }

     .fa-print {
         color: darkblue !important;
     }

     .voucher-log-modal {
         display: none;
         position: fixed;
         z-index: 9999;
         left: 0;
         top: 0;
         width: 100%;
         height: 100%;
         overflow: auto;
         background-color: rgba(0, 0, 0, 0.45);
     }

     .voucher-log-modal-content {
         background-color: #fff;
         margin: 4% auto;
         padding: 15px;
         border: 1px solid #888;
         width: 92%;
         max-height: 85vh;
         overflow-y: auto;
         border-radius: 8px;
     }

     .voucher-log-close {
         float: right;
         font-size: 22px;
         font-weight: bold;
         cursor: pointer;
     }

     .voucher-log-split {
         display: flex;
         gap: 12px;
         align-items: flex-start;
     }

     .voucher-log-panel {
         width: 50%;
     }

     .voucher-log-total {
         margin: 6px 0;
         font-size: 13px;
     }

     .old-snapshot-block {
         border: 1px solid #dcdcdc;
         border-radius: 6px;
         padding: 8px;
         margin-bottom: 10px;
     }    </style>

    <script type="text/javascript">
        $(document).ready(function () {
            var table = $('#example').DataTable({
                lengthChange: false,
                buttons: ['copy', 'excel', 'pdf']
            });
            table.buttons().container()
                .insertBefore('#example_filter');
            LoadPage();
            var date = '<%= DateTime.Now%>';
            $("#txt_sdate").datepicker({ dateFormat: 'mm/dd/yy' }).attr('readonly', 'readonly');
            date = moment(date).format('L');
            $('#txt_sdate').val(date)

            $("#txt_edate").datepicker({ dateFormat: 'mm/dd/yy' }).attr('readonly', 'readonly');
            date = moment(date).format('L');
            $('#txt_edate').val(date)
        });
        debugger;
        function LoadPage() {
            debugger
            var getquerytype = '<%= Request.QueryString["VoucherType"]%>'
            var startdate;
            if (startdate == null) {
                var getStartDate = $("#txt_sdate").val();
                startdate = getStartDate
            }
            var enddate;
            if (enddate == null) {
                var getEndDate = $("#txt_edate").val();
                enddate = getEndDate
            }
            debugger;
            $.ajax({
                type: "POST",
                url: "FinancialLogs.aspx/VoucherViewList",
                data: JSON.stringify({
                    "type": getquerytype,
                    "startdate": startdate,
                    "enddate": enddate
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    debugger;
                    var table;
                    table = $('#example').DataTable();
                    table.clear().draw();
                    var length = $("#example tr:gt(0)").length;
                    if (data != '') {
                        var data = JSON.parse(data.d);
                        $.each(data, function (i, item) {
                            var vdate = new Date(parseInt(data[i].Voucher_Date.substr(6)));
                            vdate = moment(vdate).format('L');
                            debugger;
                            table.row.add([(i + 1), data[i].Voucher_No, vdate, data[i].Voucher_Type, data[i].Remarks, data[i].Total_Debit, data[i].Voucher_Status, '<td><a href="#" onclick="openLogModal(' + data[i].Voucher_ID + '); return false;" style="border-radius: 4px; background-color: #d4b7e7; color: black; padding: 4px 11px 4px 11px;">View</a></td>'
                            ]);
                        });
                    }
                    else {
                        $('#example').html('<h3>No users are available</h3>');
                    }
                    table.draw();
                    debugger;
                    $.each(data, function (key, value) {
                        debugger;
                        if (data[key].Voucher_Status == "Approved") {
                            debugger;
                            $('#btnDel' + (key + 1) + '').hide();
                        }

                    });

                }

            });

        }


        function openLogModal(voucherId) {
            $('#logModalVoucherId').text(voucherId);
            $('#oldSnapshotsContainer').html('<div style="text-align:center;">Loading...</div>');
            $('#logModalBodyNew').html('<tr><td colspan="6" style="text-align:center;">Loading...</td></tr>');
            $('#newTotalDebit').text('');
            $('#newTotalCredit').text('');
            $('#voucherLogModal').show();

            $.ajax({
                type: "POST",
                url: "FinancialLogs.aspx/GetVoucherAccountChanges",
                data: JSON.stringify({ voucherId: voucherId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = null;
                    if (response && response.d) {
                        data = JSON.parse(response.d);
                    }

                    var oldSnapshots = (data && data.OldSnapshots) ? data.OldSnapshots : [];
                    var newRows = (data && data.NewRows) ? data.NewRows : [];

                    $('#newTotalDebit').text(data && data.NewTotalDebit != null ? data.NewTotalDebit : '');
                    $('#newTotalCredit').text(data && data.NewTotalCredit != null ? data.NewTotalCredit : '');

                    var oldHtml = '';
                    if (oldSnapshots.length === 0) {
                        oldHtml = '<div style="text-align:center;">No old logs found.</div>';
                    } else {
                        $.each(oldSnapshots, function (snapshotIndex, snapshot) {
                            oldHtml += '<div class="old-snapshot-block">';
                            oldHtml += '<div class="voucher-log-total"><b>Old Log #' + (snapshot.Log_Id == null ? '' : snapshot.Log_Id) + '</b>' + (snapshot.Logged_Time ? ' (' + snapshot.Logged_Time + ')' : '') + (snapshot.Logged_By ? ' - Logged By: ' + snapshot.Logged_By : '') + '</div>';
                            oldHtml += '<div class="voucher-log-total">Total Debit: ' + (snapshot.Total_Debit == null ? '' : snapshot.Total_Debit) + ' | Total Credit: ' + (snapshot.Total_Credit == null ? '' : snapshot.Total_Credit) + '</div>';
                            oldHtml += '<table class="table table-striped table-bordered display"><thead><tr><th>SR#</th><th>Account</th><th>DR</th><th>CR</th><th>Cost Center</th><th>Cheque Date</th></tr></thead><tbody>';

                            var rows = snapshot.Rows || [];
                            if (rows.length === 0) {
                                oldHtml += '<tr><td colspan="6" style="text-align:center;">No old rows in this log.</td></tr>';
                            } else {
                                $.each(rows, function (i, row) {
                                    oldHtml += '<tr>' +
                                        '<td>' + (i + 1) + '</td>' +
                                        '<td>' + (row.Account_Display == null ? '' : row.Account_Display) + '</td>' +
                                        '<td>' + (row.DR == null ? '' : row.DR) + '</td>' +
                                        '<td>' + (row.CR == null ? '' : row.CR) + '</td>' +
                                        '<td>' + (row.Cost_Center == null ? '' : row.Cost_Center) + '</td>' +
                                        '<td>' + (row.Cheque_Date == null ? '' : row.Cheque_Date) + '</td>' +
                                        '</tr>';
                                });
                            }

                            oldHtml += '</tbody></table></div>';
                        });
                    }

                    var newHtml = '';
                    if (newRows.length === 0) {
                        newHtml = '<tr><td colspan="6" style="text-align:center;">No new rows found.</td></tr>';
                    } else {
                        $.each(newRows, function (i, row) {
                            newHtml += '<tr>' +
                            '<td>' + (i + 1) + '</td>' +
                                '<td>' + (row.Account_Display == null ? '' : row.Account_Display) + '</td>' +
                                '<td>' + (row.DR == null ? '' : row.DR) + '</td>' +
                                '<td>' + (row.CR == null ? '' : row.CR) + '</td>' +
                                '<td>' + (row.Cost_Center == null ? '' : row.Cost_Center) + '</td>' +
                                '<td>' + (row.Cheque_Date == null ? '' : row.Cheque_Date) + '</td>' +
                                '</tr>';
                        });
                    }

                    $('#oldSnapshotsContainer').html(oldHtml);
                    $('#logModalBodyNew').html(newHtml);
                },
                error: function () {
                    $('#oldSnapshotsContainer').html('<div style="text-align:center;">Unable to load old data.</div>');
                    $('#logModalBodyNew').html('<tr><td colspan="6" style="text-align:center;">Unable to load new data.</td></tr>');
                }
            });
        }

        function closeLogModal() {
            $('#voucherLogModal').hide();
        }

        


        function redirecttonew() {
            var getype = '<%= Request.QueryString["VoucherType"]%>'
            window.location.href = "NewVoucher.aspx?VoucherType=" + getype;
        }
        function searchdate() {
            LoadPage();
        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
  <div class="row">
    <div class="col-md-3">
        <label>From Date  </label>
        <input type="text" id="txt_sdate" />
    </div>
    <div class="col-md-3" style="margin-left: -25px!important;">
        <label>To Date</label>
        <input type="text" id="txt_edate" />
    </div>
    <div class="col-md-2" style="margin-left: -25px!important;">
        <input type="button" onclick="searchdate()" value="Search" class="btn btn-info info_btn btn-addnew" />
    </div>
</div>
<br />


<table id="example" class="table table-striped table-bordered display">
    <thead>
        <tr>
            <th>SR#</th>
            <th>Voucher No</th>
            <th>Voucher Date</th>
            <th>Voucher Type</th>
            <th style="width: 30%;">Description</th>
            <th>Amount</th>
            <th>Status</th>
            <th>Action</th>
        </tr>
    </thead>
    <tbody id="tblbody">
    </tbody>
</table>

<div id="voucherLogModal" class="voucher-log-modal">
    <div class="voucher-log-modal-content">
        <span class="voucher-log-close" onclick="closeLogModal()">&times;</span>
        <h4>Voucher Account Old/New Logs - Voucher ID: <span id="logModalVoucherId"></span></h4>

        <div class="voucher-log-split">
            <div class="voucher-log-panel">
                <h4>Old Data</h4>
                <div id="oldSnapshotsContainer"></div>
            </div>

            <div class="voucher-log-panel">
                <h4>New Data</h4>
                <div class="voucher-log-total">Total Debit: <span id="newTotalDebit"></span> | Total Credit: <span id="newTotalCredit"></span></div>
                <table class="table table-striped table-bordered display">
                    <thead>
                        <tr>
                            <th>SR#</th>
                            <th>Account</th>
                            <th>DR</th>
                            <th>CR</th>
                            <th>Cost Center</th>
                            <th>Cheque Date</th>
                        </tr>
                    </thead>
                    <tbody id="logModalBodyNew"></tbody>
                </table>
            </div>
        </div>
    </div>
</div>
</asp:Content>
