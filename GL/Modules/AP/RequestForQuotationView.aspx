<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RequestForQuotationView.aspx.cs" Inherits="PMS.AP.RequestForQuotationView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
   <link href="../../wwwroot/StandardTheme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();
        });

        function Edit(ID) {
            window.location.href = "RequestForQuotation.aspx?RFQ_ID=" + ID;
        }


        function Print(id) {
            debugger;
            if (id != '' && id != null && id != undefined) {
                PageMethods.GetVendorsforReports(id, function (Tests) {
                    debugger
                    var message = JSON.parse(Tests);
                    for (var i = 0; i < message.length; i++) {
                        debugger;
                        var locationInfo = window.location;
                        var url = '/ReportViewer.aspx?ReportName=RequestForQuotationList&ReportTitle=Request For Quotation&RFQid=' + id + '&Venderid=' + message[i].VendorId;
                        if (!locationInfo.origin.includes('localhost')) {
                            var urlInfo = window.location.href.split('/');
                            var ip = urlInfo[2];
                            var foldername = urlInfo[3];
                            url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=RequestForQuotationList&ReportTitle=Request For Quotation&RFQid=' + id + '&Venderid=' + message[i].VendorId;
                        }
                        window.open(url, '_blank');
                    }
                })
            }
        }

        function deleteConfirm(RFQID) {
            debugger;
            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(RFQID, function (msg) {
                    location.reload();
                }, OnFail);
            }
        }

        function redirecttonew() {
            window.location.href = "RequestForQuotation.aspx";
        }



        function LoadPage() {
            $("#example").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "RequestForQuotationView.aspx/ViewList",
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
                    { "data": "RFQID", "visible": false },
                    { "data": "RFQNo", "name": "RFQNo", "orderable": true },
                    {
                        "data": "Date", "name":"Date",
                        "render": function (data, type, full) {
                            var date = full.Date;
                            date = moment(date).format(' D-MMM-YYYY');
                            return date;
                        }, "orderable": true
                    },
                    { "data": "VendorName", "orderable": false },
                    { "data": "RefNo", "orderable": false },
                    { "data": "Remarks", "orderable": false },
                    { "data": "Status", "orderable": false },
                    {
                        "render": function (data, type, full) {
                            var res = '<a href="#" class="editListBtn" onclick="Edit(' + full.RFQID + ')" style="border-radius: 4px;margin-right: 4px; color: white; padding: 5px 8px 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>'
                            var print = '<a style = "border-radius: 4px;background-color:#387024;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href = "#" onclick = "Print(' + full.RFQID + ')" id = "btnprint" ><i class="fa fa-print"style="color:white !important;"></i></a >';
                            var result = res + print;
                            return result;
                        }, "orderable": false
                    }
                ],
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
 <div class="row col-lg-12 col-md-12 col-sm-12 col-xs-12">
    <div id="OutPatdetails" style="margin-bottom: 1%;">
            <input type="button" id="aadnew" class="btn btn-primry" value="Add New" onclick="location.href = 'RequestForQuotation.aspx';" />
    </div>
            
                <table id="example"  class="table table-bordered table-hover">
                    <thead>
                        <tr>
                            <th style="display: none">RFQ ID</th>
                            <th>RFQ Num</th>
                            <th>RFQ Date</th>
                            <th>Vendor Name</th>
                            <th>Ref No</th>
                            <th>Remarks</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="tblbody">
                    </tbody>
                </table>
            </div>
        </div>
    


</asp:Content>
