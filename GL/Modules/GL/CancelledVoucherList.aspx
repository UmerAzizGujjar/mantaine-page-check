<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CancelledVoucherList.aspx.cs" Inherits="PMS.Modules.GL.CancelledVoucherList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />

    <script type="text/javascript">
        $(document).ready(function () {
            LoadPage();
        });

        function LoadPage() {
            var table = $("#example").DataTable({
                "processing": true,
                "serverSide": true,
                "destroy": true,
                "dom": 'lBfrtip',
                buttons: ['copy', 'excel', 'csv', 'pdf', 'colvis'],
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "CancelledVoucherList.aspx/CancelledVoucherListData",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length,
                            sortColumn: data.columns[data.order[0].column].name,
                            sortColumnDirection: data.order[0].dir,
                            searchValue: data.search.value
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
                    { "data": "Ref_Num", "name": "Ref_Num" },
                    {
                        "data": "Voucher_Date", "name": "Voucher_Date",
                        "render": function (d) { return d ? moment(d).format('D-MMM-YYYY') : 'N/A'; }
                    },
                    { "data": "Cancelled_By", "name": "Cancelled_By" },
                    {
                        "data": "Cancelled_Time", "name": "Cancelled_Time",
                        "render": function (d) { return d ? moment(d).format('D-MMM-YYYY h:mm A') : 'N/A'; }
                    },
                    { "data": "Voucher_Status", "name": "Voucher_Status" }
                ],
                "order": [[0, "desc"]]
            });
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="table-container">
        <table id="example" class="table table-hover table-bordered">
            <thead>
                <tr>
                    <th>Voucher ID</th>
                    <th>Voucher No</th>
                    <th>Type</th>
                    <th>Ref No</th>
                    <th>Date</th>
                    <th>Cancelled By</th>
                    <th>Cancelled Time</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody></tbody>
        </table>
    </div>
</asp:Content>
