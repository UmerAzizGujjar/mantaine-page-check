<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PurchaseOrderView.aspx.cs" Inherits="PMS.PurchaseOrderView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />

    <script type="text/javascript">

        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();
        });

        function Edit(ID) {
            window.location.href = "PurchaseOrder.aspx?PO_ID=" + ID;
        }
        function Print(id) {
            debugger;
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=PurchaseOrderList&ReportTitle=Purchase Order List&POid=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=PurchaseOrderList&ReportTitle=Purchase Order List&POid=' + id;
            }
            window.open(url,'_blank');
        }
        function redirecttonew() {
            window.location.href = "PurchaseOrder.aspx";
        }


        function LoadPage() {
            $("#example").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'PurchaseOrder.aspx'; } }, 'copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "PurchaseOrderView.aspx/ViewList",
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
                    { "data": "POID", "visible": false, "width": "0%" },
                    { "data": null, "orderable": false, "width": "10%" },
                    { "data": "PONo", "name": "PONo", "width": "10%", "orderable": true },
                    {
                        "data": "Date",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.Date;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "10%", "orderable": false
                    },
                    { "data": "RefNo", "width": "15%", "orderable": true },
                    { "data": "VendorName", "width": "20%", "orderable": false },
                    { "data": "PO_Amount", "width": "15%", className: "text-right", "orderable": false },
                    { "data": "Status", "width": "10%", "orderable": false },
                    {
                        "render": function (data, type, full) {
                            debugger;
                            var res = '<a href="#" class="editListBtn" onclick="Edit(' + full.POID + ')" style="border-radius: 4px;margin-right: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>'

                            var print = '<a class="printListBtn" style = "border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href = "#" onclick = "Print(' + full.POID + ')" id = "btnprint" ><i class="fa fa-print"></i></a >';
                            var result;
                            result = res + print;
                            return result;
                        }, "width": "10%", "orderable": false
                    }
                ],
                "rowCallback": function (row, data, index) {
                    if (data.Status === "Cancelled") {
                        $(row).css('background-color', 'rgb(251, 148, 148)');
                        $(row).find('td').css('background-color', 'rgb(251, 148, 148)');
                    }
                    else if (data.Status === "Approved") {
                        $(row).css('background-color', '#ABEBC6');
                        $(row).find('td').css('background-color', '#ABEBC6');
                    }
                },
                "createdRow": function (row, data, dataIndex) {
                    $(row).find('td:eq(0)').html(dataIndex + 1);
                },
                "initComplete": function (settings, json) {
                    var lengthContainer = document.querySelector('#example_length');
                    var lengthDropdown = document.querySelector('#example_length select');
                    var label = document.querySelector('#example_length label');

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
                    } else {
                        console.log("Length dropdown, label, or container not found");
                    }
                }
            });
        }
        

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
   
    <div class="table-container">
        <table class="table  table-hover table-bordered" id="example">
    <thead>
        <tr>
            <th style="display: none;">PO ID</th>
            <th>SR #</th>
            <th>PO Num</th>
            <th>PO Date</th>
            <th>Ref No</th>
            <th>Vendor Name</th>
            <th>Net Amount</th>
            <th>Status</th>
            <th>Action</th>
        </tr>
    </thead>
    <tbody id="tblbody">
    </tbody>
</table>

    </div>
    
</asp:Content>
