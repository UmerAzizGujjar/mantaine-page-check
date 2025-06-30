<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PaymentInvoiceView.aspx.cs" Inherits="PMS.Inventory.PaymentInvoiceView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
      <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">

        function PrintVoucher(InvId) {
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=Payment Voucher&TransID=' + InvId + '&TransType=Pay';
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=Payment Voucher&TransID=' + InvId + '&TransType=Pay';
            }
            window.open(url, '_blank');
        }

        function OnFail(exc) {
            alert(exc.get_message());
        }
        function Edit(ID) {
            window.location.href = "AddPaymentInvoice.aspx?Inv_ID=" + ID;
        }
        function isDeleteAllow() {
            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: "PaymentInvoiceView.aspx/isDeleteAllow",
                data: "",
                success: function (resp) {
                    debugger;
                    if (resp.d == true) {
                        isDele = true;
                    }
                    else {
                        isDele = false;
                    }
                }, error: function () { }
            })
        }
        function deleteConfirm(anchorTag) {
            debugger;
            var row = $(anchorTag).parents('tr')[0];
            var InvID = $($(row).find('td')[0]).text();
            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(InvID, function (msg) {
                    debugger
                    $(row).remove();
                }, OnFail);
            }
        }

        $(document).ready(function () {
            LoadPage();
        });



        function LoadPage() {
            $("#tblResult").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'AddPaymentInvoice.aspx'; } }, 'copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "PaymentInvoiceView.aspx/ViewList",
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
                    { "data": "PaymentInvoiceId", visible: false, },
                    { "data": "PaymentNum", "name": "PaymentNum", width: "9%" },
                    { "data": "PurchaseNo", width: "11%" },
                    { "data": "ManualNo", "name": "ManualNo", width:"11%" },
                    {
                        "data": "PaymentDate",
                        "render": function (data, type, full) {
                            var date = full.PaymentDate;
                            date = moment(date).format('D-MMM-YYYY');
                            return date;
                        }, width:"11%"
                    },
                    { "data": "Amount", width: "10%", className: "text-right" },
                    { "data": "Status", width: "10%" },
                    { "data": "Remarks", width:"20%" },
                    {
                        "render": function (data, type, full) {
                            var res = '<a class="editListBtn" href="#" onclick="Edit(' + full.PaymentInvoiceId + ')" style="border-radius: 4px;margin-right: 4px; color: white; padding: 5px 8px 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>';
                            var print = '<a style="border-radius: 4px;background-color:#387024;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintVoucher(' + full.PaymentInvoiceId + ')" id="btnprint"><i class="fa fa-print" style="color:white !important;"></i></a>';
                            var result = res + print;
                            return result;
                        }, width:"8%"
                    }
                ],
                "rowCallback": function (row, data, index) {
                    if (data.Status === "Approved") {
                        $(row).css('background-color', '#ABEBC6');
                    }
                },
                "initComplete": function (settings, json) {
                    var lengthDropdown = document.querySelector('#tblResult_length select');
                    var label = document.querySelector('#tblResult_length label');
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
        <div class="col-lg-2 col-md-4 col-sm-12" style="margin-bottom:1%">
            <input type="button" class="btn btn-primry" id="aadnew" value="Add New" onclick="location.href = 'AddPaymentInvoice.aspx';" />
        </div>
    </div>

    <div class="table-container">
        <table class="table table-hover table-bordered" id="tblResult" style="width: 100%">
            <thead id="ihead">
                <tr>
                    <th>PaymentInvoiceI</th>
                    <th>Payment #</th>
                    <th>Purchase Inv</th>
                    <th>Manual Inv</th>
                    <th>Payment Date</th>
                    <th>Amount</th>
                    <th>Status</th>
                    <th>Remarks</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody id="ibody">
            </tbody>
        </table>
    </div>
</asp:Content>
