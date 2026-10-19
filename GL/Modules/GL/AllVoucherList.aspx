<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AllVoucherList.aspx.cs" Inherits="PMS.Modules.GL.AllVoucherList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <link href="../CssJs/select2.min.css" rel="stylesheet" />
    <script src="../CssJs/select2.min.js"></script>
    <style>
        /* buttons follow the active theme (theme-colors.css), not fixed colours */
        .vch-print-btn {
            display: inline-block;
            padding: 5px 8px;
            border-radius: 4px;
            border: 1px solid var(--theme-accent, #EFA63E);
            background: var(--theme-accent, #EFA63E);
            color: var(--theme-on-accent, #1b2a41);
            text-decoration: none;
        }
        .vch-print-btn:hover {
            background: var(--theme-accent-light, #F4B653);
            color: var(--theme-on-accent, #1b2a41);
            text-decoration: none;
        }
    </style>

    <script type="text/javascript">
        $(document).ready(function () {
            LoadFilters();
            LoadPage();

            // View button in the action column opens the approved voucher
            $(document).on('click', '.vView', function (e) {
                e.preventDefault();
                ViewVoucher($(this).data('id'), $(this).data('no'));
            });
        });

        function LoadFilters() {
            $.ajax({
                type: "POST",
                url: "AllVoucherList.aspx/GetVoucherTypes",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (r) {
                    var $t = $('#ddlVoucherType').empty().append('<option value="">All Voucher Types</option>');
                    var $n = $('#ddlVoucherName').empty().append('<option value="">All Voucher Names</option>');
                    $.each(r.d, function (i, x) {
                        $t.append($('<option></option>').val(x.Voucher_Type).text(x.Voucher_Type));
                        $n.append($('<option></option>').val(x.Voucher_Name).text(x.Voucher_Name));
                    });
                    $t.select2({ width: '180px' });
                    $n.select2({ width: '220px' });
                }
            });
        }

        function LoadPage() {
            var table = $("#example").DataTable({
                "processing": true,
                "serverSide": true,
                "destroy": true,
                "searchDelay": 500,
                "deferRender": true,
                "dom": 'lBfrtip',
                buttons: ['copy', 'excel', 'pdf', 'colvis'],
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "AllVoucherList.aspx/AllVoucherListData",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length,
                            sortColumn: data.columns[data.order[0].column].name,
                            sortColumnDirection: data.order[0].dir,
                            searchValue: data.search.value,
                            voucherTypeFilter: $('#ddlVoucherType').val() || "",
                            voucherNameFilter: $('#ddlVoucherName').val() || ""
                        }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            var j = response.d;
                            callback({ draw: j.draw, recordsTotal: j.recordsTotal, recordsFiltered: j.recordsFiltered, data: j.data });
                        },
                        error: function (xhr) { console.log("Error: " + xhr.responseText); }
                    });
                },
                "columns": [
                    { "data": "Voucher_ID", "name": "Voucher_ID", "visible": false },
                    { "data": "Voucher_No", "name": "Voucher_No" },
                    { "data": "Voucher_Type", "name": "Voucher_Type" },
                    { "data": "Narration", "name": "Narration" },
                    { "data": "Voucher_Name", "name": "Voucher_Name" },
                    {
                        "data": "TotalDR", "name": "TotalDR",
                        "render": function (d) { return parseFloat(d || 0).toFixed(2); }
                    },
                    {
                        "data": "TotalCR", "name": "TotalCR",
                        "render": function (d) { return parseFloat(d || 0).toFixed(2); }
                    },
                    {
                        "render": function(d, type, full) {
                            return '<a href="#" class="vch-print-btn vView" data-id="' + full.Voucher_ID + '" data-no="' + full.Voucher_No + '" title="View voucher"><i class="fa fa-eye"></i></a> ' +
                                   '<a href="#" onclick="PrintReport(\'' + full.Voucher_ID + '\',\'' + full.Voucher_Type + '\')" class="vch-print-btn"><i class="fa fa-print"></i></a>';
                        },
                        "orderable": false
                    }
                ],
                "createdRow": function (row, data) {
                    // click anywhere on the row (not on a button) to open the voucher
                    $(row).css('cursor', 'pointer');
                    $(row).off('click.vview').on('click.vview', function (e) {
                        if ($(e.target).closest('a, button, input').length) { return; }
                        ViewVoucher(data.Voucher_ID, data.Voucher_No);
                    });
                },
                "order": [[0, "desc"]]
            });

            $('#ddlVoucherType, #ddlVoucherName').off('change.avf').on('change.avf', function () {
                table.ajax.reload();
            });
}
// GL lines and bills of one approved voucher, shown in a popup (same view as Pharmacy Pending Bills)
function vEsc(v) {
    if (v === null || v === undefined) { return ''; }
    return String(v)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
}

function vMoney(v) {
    return Number(v || 0).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

function ViewVoucher(id, no) {
    $.ajax({
        type: 'POST',
        url: 'AllVoucherList.aspx/GetVoucherDetail',
        data: JSON.stringify({ voucherId: String(id) }),
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (response) {
            var d = JSON.parse(response.d);
            if (d.status !== 'Approved') {
                Swal.fire({ icon: 'info', title: 'Voucher No ' + no, text: 'Only approved vouchers can be viewed. Status: ' + (d.status || 'unknown') });
                return;
            }

            var billRows = (d.bills || []).map(function (b) {
                return '<tr><td>' + vEsc(b.Seq_InvoiceNo) + '</td><td>' + vEsc(b.Customer_Name) + '</td>' +
                       '<td style="text-align:right;">' + vMoney(b.Total_Amount) + '</td>' +
                       '<td style="text-align:right;">' + vMoney(b.Discount_Amount) + '</td>' +
                       '<td style="text-align:right;">' + vMoney(b.Received_Amount) + '</td>' +
                       '<td style="text-align:right;">' + vMoney(b.Balance_Amount) + '</td></tr>';
            }).join('');

            var lineRows = (d.lines || []).map(function (l) {
                return '<tr><td>' + vEsc(l.Account_Code) + '</td><td>' + vEsc(l.Account_Name) + '</td>' +
                       '<td>' + vEsc(l.Narration) + '</td>' +
                       '<td style="text-align:right;">' + vMoney(l.DR) + '</td>' +
                       '<td style="text-align:right;">' + vMoney(l.CR) + '</td></tr>';
            }).join('');

            var billPart = billRows
                ? '<table class="table table-bordered table-condensed"><thead><tr><th>Bill No</th><th>Customer</th>' +
                  '<th style="text-align:right;">Total</th><th style="text-align:right;">Discount</th>' +
                  '<th style="text-align:right;">Received</th><th style="text-align:right;">Balance</th></tr></thead>' +
                  '<tbody>' + billRows + '</tbody></table>'
                : '<p class="text-muted">No bills are linked to this voucher.</p>';

            var html =
                '<h4 style="text-align:left;">Bills in this voucher</h4>' + billPart +
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

function PrintReport(ID, Voucher_Type ) {
    var getype = Voucher_Type
    var locationInfo = window.location;
    var user_name = '<% =AppConfig.Company_Name %>';
    if (user_name == 'As-Siraat Serving Humanity') {
        reportPath = '../../ReportViewer.aspx';
    } else {
        reportPath = 'ReportViewer.aspx'; // same folder
    }

    var url = '/ReportViewer.aspx?ReportName=All_Voucher&TransID=' + ID;
    if (!locationInfo.origin.includes('localhost')) {
        var urlInfo = window.location.href.split('/');
        var ip = urlInfo[2];
        var foldername = urlInfo[3];

        url = 'http://' + ip + '/' + foldername + '/' + reportPath + '?ReportName=All_Voucher&TransID=' + ID ;
    }
//window.location.href = url;
             window.open(url, '_blank');
         }
        function OpenVoucher(id, type) {
            window.location.href = "Voucher.aspx?VoucherType=" + encodeURIComponent(type) + "&VID=" + id;
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div style="margin-bottom:10px;" class="row">
        <div class="col-lg-2">
        <label style="margin-right:6px;font-weight:600;">Voucher Type:</label>
        <select id="ddlVoucherType" style="margin-right:14px;"></select>
            </div>
        <div class="col-lg-2">
        <label style="margin-right:6px;font-weight:600;">Voucher Name:</label>
        <select id="ddlVoucherName"></select>
            </div>
    </div>
    <div class="table-container">
        <table id="example" class="table table-hover table-bordered">
            <thead>
                <tr>
                    <th>Voucher ID</th>
                    <th>Voucher No</th>
                    <th>Voucher Type</th>
                    <th>Narration</th>
                    <th>Voucher Name</th>
                    <th>Sum DR</th>
                    <th>Sum CR</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody></tbody>
        </table>
    </div>
</asp:Content>
