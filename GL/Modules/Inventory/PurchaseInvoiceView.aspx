<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PurchaseInvoiceView.aspx.cs" Inherits="PMS.Inventory.PurchaseInvoiceView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />


    <script type="text/javascript">

        function PrintPurchaseDetail(PurchaseInvoiceId) {
             var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=PurchaseInvoiceList&ReportTitle=Purchase Invoice List&Inv_Id=' + PurchaseInvoiceId;
             if (!locationInfo.origin.includes('localhost')) {
                 var urlInfo = window.location.href.split('/');
                 var ip = urlInfo[2];
                 var foldername = urlInfo[3];
                 url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=PurchaseInvoiceList&ReportTitle=Purchase Invoice List&Inv_Id=' + PurchaseInvoiceId;
             }
             window.open(url, '_blank');
        }

        function PrintVoucher(InvId) {
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=Purchase Voucher&TransID=' + InvId + '&TransType=Pur';
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=Purchase Voucher&TransID=' + InvId + '&TransType=Pur';
            }
            window.open(url, '_blank');
        }

        function Edit(ID) {
            window.location.href = "AddPurchaseInvoice.aspx?Inv_ID=" + ID;
        }

        $(document).ready(function () {
            LoadPage();
        });


        function LoadPage() {
            $("#example").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'AddPurchaseInvoice.aspx'; } }, 'copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "PurchaseInvoiceView.aspx/ViewList",
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
                    { "data": "PurchaseInvoiceId", visible: false, width: "0%" },
                    { "data": "InvoiceNum", "name": "InvoiceNum", width:"6%" },
                    {
                        "data": "InvoiceDate",
                        "render": function (data, type, full) {
                            var date = full.InvoiceDate;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, width:"8%"
                    },
                    { "data": "IGPNumber", width: "7%" },
                    { "data": "GrnNumber", width: "7%" },
                    { "data": "VendorName", width: "18%" },
                    { "data": "Remarks", width:"20%" },
                    {
                        "data": "Amount",
                        "render": function (data, type, full) {
                            var Amount = full.Amount;
                            if (Amount == null || Amount == '' || Amount == "") {
                                Amount = 0;
                            } else {
                                Amount = full.Amount;
                            }
                            return Amount;
                        }, width:"9%",className:"text-right"
                    },
                    {
                        "render": function (data, type, full) {
                            var res = '<a class="editListBtn" href="#" onclick="Edit(' + full.PurchaseInvoiceId + ')" style="border-radius: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>';

                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintPurchaseDetail(' + full.PurchaseInvoiceId + ')" id="btnprint"><i class="fa fa-print" ></i></a>';
                            var result = res + print;
                            return result;
                        }, width:"9%"
                    }
                ],
                "rowCallback": function (row, data, index) {
                    if (data.Status === "Approved") {
                        $(row).css('background-color', '#ABEBC6');
                    }
                },
                "initComplete": function (settings, json) {
                    var lengthDropdown = document.querySelector('#example_length select');
                    var label = document.querySelector('#example_length label');
                    if (lengthDropdown && label) {
                        label.innerHTML = 'Show entries ';
                        label.appendChild(lengthDropdown);
                    } else {
                        console.log("Length dropdown or label not found");
                    }
                }
            });
        }        
        
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
    <div class="table-container">
        <table class="table table-hover table-bordered" id="example" style="width: 100%">
            <thead id="ihead">
                <tr>
                    <th>PurchaseInvoiceId</th>
                    <th>Inv_No</th>
                    <th>Date</th>
                    <th>IGP</th>
                    <th>GRN </th>
                    <th>Vendor</th>
                    <th>Remarks</th>
                    <th>Amount</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody id="ibody">
            </tbody>
        </table>
    </div>
        </div>
</asp:Content>
