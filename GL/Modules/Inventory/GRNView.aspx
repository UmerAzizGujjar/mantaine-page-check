<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GRNView.aspx.cs" Inherits="PMS.Inventory.GRNView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/IITH_Theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">

        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();

        });

        function Edit(ID) {
            window.location.href = "GRN.aspx?GRN_ID=" + ID;
        }

        function Print(ids) {

            var id = ids
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=GRNList&ReportTitle=Good Receipt List&GRNid=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=GRNList&ReportTitle=Good Receipt List&GRNid=' + id;
            }
            window.open(url, '_blank');
        }
        function PrintVoucher(id) {

            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=GRN Voucher&TransID=' + id + '&TransType=GRN';
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=GRN Voucher&TransID=' + id + '&TransType=GRN';
            }
            window.open(url, '_blank');
        } 


        function LoadPage() {
            $("#tblResult").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "GRNView.aspx/ViewList",
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
                    { "data": "GRN_ID", "visible": false, },
                    { "data": "po_Number", "name": "po_Number", "orderable": true },
                    { "data": "GRN_Num", "name": "GRN_Num", "orderable": true },
                    { "data": "Igp_Number", "name": "Igp_Number", "orderable": true },
                    {
                        "data": "Approved_Date",
                        "render": function (data, type, full) {
                            var date = full.Approved_Date;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "orderable": false
                    },
                    { "data": "Vendor_Name", "orderable": false },
                    { "data": "Remarks", "orderable": false },
                    { "data": "Status", "orderable": false },
                    {
                        "render": function (data, type, full) {
                            var res = '<a href="#" class="editListBtn" onclick="Edit(' + full.GRN_ID + ')" style="border-radius: 4px;margin-right: 4px; color: white; padding: 5px 8px 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>'
                            var print = '<a style="border-radius: 4px;background-color:#387024;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="Print(' + full.GRN_ID + ')" id="btnprint"><i class="fa fa-print" style="color:white !important;"></i></a>';
                            var result = res + print;
                            return result;
                        }, "orderable": false
                    }
                ],
                "initComplete": function (settings, json) {
                    var lengthContainer = document.querySelector('#tblResult_length');
                    var lengthDropdown = document.querySelector('#tblResult_length select');
                    var label = document.querySelector('#tblResult_length label');

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
                },
                "rowCallback": function (row, data, index) {
                    if (data.Status === "Approved") {
                        $(row).css('background-color', '#ABEBC6');
                    }
                }
            });
        }            
        

            

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid table-container">
    <div class="row col-lg-12 col-md-12 col-sm-12 col-xs-12">
        <div id="GRNdetails" style="margin-top: 15px;">  
         <div>
            </div>
        <table class="table table-responsive table-hover table-bordered" id="tblResult">
            <thead id="ihead">
                <tr>              
                    <th>GRN ID</th>
                    <th>PO Num</th>
                    <th>GRN Num</th>
                    <th>IGP Num</th>
                    <th>Approval Date</th>
                    <th>Vendor Name</th>                              
                    <th>Remarks</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody id="ibody">
            </tbody>
        </table>
        </div>      
        </div>
        </div>
</asp:Content>
