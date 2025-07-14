<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="StockAdjustmentView.aspx.cs" Inherits="PMS.Inventory.StockAdjustmentView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">    
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
        <script type="text/javascript">
            $(document).ready(function () {
                $('#ctl00_lblMessage').hide();
                LoadPage();

            });

            function Edit(ID) {
                window.location.href = "StockAdjustment.aspx?ID=" + ID;
            }
            function redirecttonew() {
                window.location.href = "StockAdjustment.aspx";
            }  


            function PrintVoucher(Adjustment_Id) {
                debugger;
                var locationInfo = window.location;
                var url = '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=Adj Voucher&TransID=' + Adjustment_Id + '&TransType=Adj';
                if (!locationInfo.origin.includes('localhost')) {
                    var urlInfo = window.location.href.split('/');
                    var ip = urlInfo[2];
                    var foldername = urlInfo[3];
                    url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=Adj Voucher&TransID=' + Adjustment_Id + '&TransType=Adj';
                }
                window.open(url, '_blank');
            }

            var isDele = '';
            function LoadPage() {
                $("#tblexample").DataTable({
                    "processing": true,
                    "serverSide": true,
                    "dom": 'lBfrtip',
                    "lengthChange": true,
                    "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'StockAdjustment.aspx'; } }, 'copy', 'excel', 'pdf'],
                    "filter": true,
                    "ajax": function (data, callback, settings) {
                        $.ajax({
                            type: "POST",
                            url: "StockAdjustmentView.aspx/ViewList",
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
                        { "data": "Adjustment_Id", visible: false },
                        { "data": "Adjustment_No", "name": "Adjustment_No", "orderable": true },
                        {
                            "data": "AdjustmentDates",
                            "render": function (data, type, full) {
                                var date = moment(full.AdjustmentDates).format('D-MMM-YYYY');
                                return date;
                            }, "orderable": false
                        },
                        { "data": "ItemCode", "name": "ItemCode", "orderable": true },
                        { "data": "ItemDescription", "orderable": false },
                        { "data": "Qty", "orderable": false },
                        { "data": "Rate", "orderable": false },
                        { "data": "Status", "orderable": false },
                        {
                            "data": null,
                            "render": function (data, type, full) {
                                var res = '<a href="#" class="editListBtn" onclick="Edit(' + full.Adjustment_Id + ')" style="border-radius: 4px;margin-right: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>';

                                var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintVoucher(' + full.Adjustment_Id + ')" id="btnprint"><i class="fa fa-print"></i></a>';
                                var result;
                                result = res  + print;
                                return result;
                            }, "orderable": false
                        }
                    ],
                    "rowCallback": function (row, data, index) {
                        if (data.Status === "Approved") {
                            $(row).css('background-color', '#ABEBC6');
                        }
                    },
                    "initComplete": function (settings, json) {
                        var lengthContainer = document.querySelector('#tblexample_length');
                        var lengthDropdown = document.querySelector('#tblexample_length select');
                        var label = document.querySelector('#tblexample_length label');

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
        <table id="tblexample" class="table table-hover table-bordered">
            <thead>
                <tr>
                    <th>Adjustement #</th>
                    <th>Adjustement #</th>
                    <th>AdjustedDate</th>
                    <th>ItemCode</th>
                    <th>ItemDescription</th>
                    <th>QTY</th>
                    <th>Rate</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody id="tblbody">
            </tbody>
        </table>
    </div>
  
</asp:Content>