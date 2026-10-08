<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="UnbalancedVoucherList.aspx.cs" Inherits="PMS.Modules.GL.UnbalancedVoucherList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <link href="../CssJs/select2.min.css" rel="stylesheet" />
    <script src="../CssJs/select2.min.js"></script>

    <script type="text/javascript">
        $(document).ready(function () {
            LoadFilters();
            LoadPage();
        });

        function LoadFilters() {
            $.ajax({
                type: "POST",
                url: "UnbalancedVoucherList.aspx/GetVoucherTypes",
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
                "dom": 'lBfrtip',
                buttons: ['copy', 'excel', 'pdf', 'colvis'],
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "UnbalancedVoucherList.aspx/UnbalancedVoucherListData",
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
                            return '<a href="#" onclick="PrintReport(\'' + full.Voucher_ID + '\',\'' + full.Voucher_Type + '\')" style="border-radius:4px;background:#007bff;color:white;padding:5px 8px;"><i class="fa fa-print"></i></a>';
                        },
                        "orderable": false
                    }
                ],
                "order": [[0, "desc"]]
            });

            $('#ddlVoucherType, #ddlVoucherName').off('change.avf').on('change.avf', function () {
                table.ajax.reload();
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

