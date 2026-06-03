<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="FinancialLogs.aspx.cs" Inherits="PMS.FinancialLogs" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <script src='<%= ResolveUrl("~/Scripts/jquery-ui.min.js") %>'></script>
    <script src="https://cdn.datatables.net/buttons/2.4.2/js/buttons.colVis.min.js"></script>
 <style type="text/css">
     .info_btn {
         min-width: 90px;
     }

     .btn-addnew {
         top: -5px !important;
     }

     .view-log-btn {
         border-radius: 4px;
         background-color: #d4b7e7;
         color: black !important;
         padding: 4px 11px;
         display: inline-block;
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
     }
    </style>

    <script type="text/javascript">
        $(document).ready(function () {
            var currentDate = moment('<%= DateTime.Now %>').format('L');
            $("#txt_sdate").datepicker({ dateFormat: 'mm/dd/yy' }).attr('readonly', 'readonly').val(currentDate);
            $("#txt_edate").datepicker({ dateFormat: 'mm/dd/yy' }).attr('readonly', 'readonly').val(currentDate);

            var table = $('#example').DataTable({
                dom: 'lBfrtip',
                lengthChange: true,
                buttons: ['copy', 'excel', 'pdf']
            });

            table.buttons().container().insertBefore('#example_filter');
            LoadPage();
        });

        function LoadPage() {
            var getquerytype = '<%= Request.QueryString["VoucherType"]%>';
            var startdate = $("#txt_sdate").val();
            var enddate = $("#txt_edate").val();

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
                success: function (response) {
                    var table = $('#example').DataTable();
                    table.clear().draw();

                    var rows = [];
                    if (response && response.d) {
                        rows = JSON.parse(response.d) || [];
                    }

                    $.each(rows, function (i, item) {
                        var vdate = '';
                        if (item.Voucher_Date) {
                            var ticks = parseInt(item.Voucher_Date.substr(6), 10);
                            if (!isNaN(ticks)) {
                                vdate = moment(new Date(ticks)).format('L');
                            }
                        }

                        table.row.add([
                            (i + 1),
                            item.Voucher_No,
                            vdate,
                            item.Voucher_Type,
                            item.Remarks,
                            item.Total_Debit,
                            item.Voucher_Status,
                            '<a href="#" class="view-log-btn" onclick="openLogModal(' + item.Voucher_ID + '); return false;">View</a>'
                        ]);
                    });

                    table.draw();
                },
                error: function () {
                    $('#example').DataTable().clear().draw();
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
    <div class="col-md-2">
        <label>From Date  </label>
        <input type="text" id="txt_sdate" />
    </div>
    <div class="col-md-2" style="margin-left: -25px!important;">
        <label>To Date</label>
        <input type="text" id="txt_edate" />
    </div>
    <div class="col-md-2" style="margin-left: -25px!important;">
        <input type="button" onclick="searchdate()" value="Search" class="btn btn-info info_btn btn-addnew" />
    </div>
</div>
<br />

<div class="row">
    <div class="table-container">
        <table id="example" class="table table-hover table-striped table-bordered display">
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
    </div>
</div>

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
