<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="StoreStockTransferView.aspx.cs" Inherits="PMS.Inventory.StoreStockTransferView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
      <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            debugger;
            $('#ctl00_lblMessage').hide();
            LoadPage();


        });

        function PrintTest(id) {
            window.open('ReportViewer.aspx?ReportName=TestDefination&ReportTitle= Test Defination&Test_IDs=' + id);
        }
        function LoadPage() {
            $("#example").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'StoreStockTransfer.aspx'; } }, 'copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "StoreStockTransferView.aspx/ViewList",
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
                    { "data": "Stock_Transfer_ID", "visible": false, "width": "0%" },
                    { "data": null, "orderable": false, "width": "8%" },
                    { "data": "Stock_Transfer_No", "name": "Stock_Transfer_No", "width": "12%", "orderable": true },
                    {
                        "data": "Stock_Transfer_Date", "name": "Stock_Transfer_Date",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.Stock_Transfer_Date;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "15%", "orderable": false
                    },
                    { "data": "WareHouseFrom", "width": "15%", "orderable": false },
                    { "data": "WareHouseTo", "width": "10%", "orderable": false },
                    { "data": "Remarks", "width": "20%", "orderable": false },
                    { "data": "Status", "width": "10%", "orderable": false },
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a href="#" class="editListBtn" onclick="Edit(' + full.Stock_Transfer_ID + ')" style="border-radius: 4px;  color: white; padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>'

                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintTest(' + full.Test_ID + ')" id="btnprint"><i class="fa fa-print"></i></a>';
                            var result;
                            result = res  + print;
                            return result;
                        }, "width": "10%", "orderable": false
                    }
                ],
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

        function Edit(ID) {
           window.location.href = "StoreStockTransfer.aspx?stID=" + ID;
        }

        
        function redirecttonew() {
            window.location.href = "StoreStockTransfer.aspx";
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
     
    <div class="table-container">
        <table id="example" class="table table-hover table-bordered">
            <thead>
                <tr>
                    <th>Stock_Transfer_ID</th>
                    <th>SR#</th>
                    <th>Store TransNo</th>
                    <th>Date</th>
                    <th>WareHouseFrom</th>
                    <th>WareHouseTo</th>
                    <th>Remarks</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody id="tblbody">
            </tbody>
        </table>
    </div>
</asp:Content>
