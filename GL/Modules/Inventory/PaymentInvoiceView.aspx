<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PaymentInvoiceView.aspx.cs" Inherits="PMS.Inventory.PaymentInvoiceView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
      <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
   <style>
    table.dataTable tbody tr.child td > .child-container {
        display: flex;
        gap: 20px;
        padding: 15px;
        background: #f4f7fb;
        border-left: 4px solid #3498db;
        animation: fadeIn .25s ease-in;
    }

    .table-wrapper {
        max-height: 200px; /* adjust height as needed */
        overflow-y: auto; /* vertical scroll */
        overflow-x: auto; /* horizontal scroll if table is wider */
        border: 1px solid #ddd;
        margin-bottom: 10px;
    }

        /* Optional: fixed header style */
        .table-wrapper table {
            width: 100%;
            border-collapse: collapse;
        }

        .table-wrapper th, .table-wrapper td {
            padding: 6px;
            border: 1px solid #ddd;
            font-size: 12px;
            text-align: left;
            white-space: nowrap; /* prevents wrapping */
        }

    .child-col-left {
        background: #ffffff;
        border-radius: 6px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }

        .child-col-left p {
            color: #1b48ed;
            font-size: 15px;
        }

            .child-col-left p b {
                color: black;
            }

    .child-col-right {
        width: 65%;
    }

    h5 {
        font-size: 20px;
        font-weight: 1000;
    }

    .child-table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 5px;
        background: #fff;
        border-radius: 6px;
        overflow: hidden;
    }

        .child-table th {
            background: #3498db;
            color: #fff;
            padding: 6px;
            font-size: 13px;
            text-align: left;
        }

        .child-table td {
            padding: 6px;
            border: 1px solid #ddd;
            font-size: 12px;
        }

    .child-loading {
        padding: 15px;
        font-size: 14px;
        font-weight: bold;
    }

    @keyframes fadeIn {
        from {
            opacity: 0;
            transform: translateY(-8px);
        }

        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
</style>
    
    <script type="text/javascript">

        function PrintVoucher(InvId) {
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=Payment Voucher&TransID=' + InvId + '&TransType=Pay';
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '../../ReportViewer.aspx?ReportName=Voucher&ReportTitle=Payment Voucher&TransID=' + InvId + '&TransType=Pay';
            }
            window.open(url, '_blank');
        }

        function PrintPaymentDetail(PaymentInvoiceId) {
             var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=PaymentBasePrint&ReportTitle=Payment Invoice &Inv_Id=' + PaymentInvoiceId;
             if (!locationInfo.origin.includes('localhost')) {
                 var urlInfo = window.location.href.split('/');
                 var ip = urlInfo[2];
                 var foldername = urlInfo[3];
                 url = 'http://' + ip + '/' + foldername + '../../ReportViewer.aspx?ReportName=PaymentBasePrint&ReportTitle=Payment Invoice &Inv_Id=' + PaymentInvoiceId;
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
            var table =   $("#tblResult").DataTable({
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
                            var res = '<a class="editListBtn" href="#" onclick="Edit(' + full.PaymentInvoiceId + ')" style="border-radius: 4px;margin-right: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>';

                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintPaymentDetail(' + full.PaymentInvoiceId + ')" id="btnprint"><i class="fa fa-print" ></i></a>';
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
            $('#tblResult tbody').on('click', 'tr', function () {
                var row = table.row(this);
                var data = row.data();
                if (!data) return;
                var id = data.PaymentInvoiceId;
                if (row.child.isShown()) {
                    row.child.hide();
                    $(this).removeClass('shown');
                    return;
                }
                row.child('<div class="child-loading">Loading...</div>').show();
                $(this).addClass('shown');

                $.ajax({
                    type: "POST",
                    url: "PaymentInvoiceView.aspx/GetMasterAndDetail",
                    data: JSON.stringify({ invoiceId: id }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (resp) {
                        var d = resp.d;
                        var html = `
              <div class="child-container">                            
                  <div class="col-sm-4 col-md-4 col-lg-3 child-col-left">
                      <h5>Master Information</h5>
                      <p><b>Invoice #:</b> ${d.Master.Number}</p>
                      <p><b>Date:</b> ${moment(d.Master.Date).format("DD-MMM-YYYY")}</p>
                      <p><b>Vendor:</b> ${d.Master.VendorName}</p>
                      <p><b>Status:</b> ${d.Master.Status}</p>
                      <p><b>Remarks:</b> ${d.Master.Remarks}</p>
                  </div>                           
                  <div class="col-sm-9 col-md-4 col-lg-9">
                      <h5>Invoice Details</h5>
                       <div class="table-wrapper">
                      <table class="child-table" id="detailTable_${id}">
                          <thead>
                              <tr>
                                  <th>Adjusted Amount</th>
                                  <th>Total Amount</th>
                                  <th>WHT Amount</th>
                                  <th>Payable Amount</th>
                              </tr>
                          </thead>
                          <tbody></tbody>
                      </table>   
                      </div>
                      <h5 class="mt-3">Audit Information</h5>
                      <table class="child-table" id="otherTable_${id}">
                          <thead>
                              <tr>
                                  <th>Type</th>
                                  <th>Number</th>
                                  <th>Date</th>
                                  <th>Status</th>
                                  <th>View</th>
                              </tr>
                          </thead>
                          <tbody></tbody>
                      </table>                           
                  </div>                            
              </div>`;

                        row.child(html).show();
                        $.each(d.Detail, function (i, item) {
                            $("#detailTable_" + id + " tbody").append(`
                <tr>
                    <td>${item.AdjustedAmount}</td>
                    <td>${item.TotalPaidAmount}</td>
                    <td>${item.Withholdtaxamount}</td>
                    <td>${item.Payable}</td>
                </tr>
               `);
                        });
                        LoadAuditInfo(id);
                    }
                });

            });
        }
        
        function LoadAuditInfo(id) {

            $.ajax({
                type: "POST",
                url: "PaymentInvoiceView.aspx/GetAuditInfo",
                data: JSON.stringify({ invoiceId: id }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (resp) {

                    $.each(resp.d, function (i, x) {

                        $("#otherTable_" + id + " tbody").append(`
                  <tr>
                      <td>${x.T_Type}</td>
                      <td>${x.NUmber}</td>
                      <td>${moment(x.Dates).format("DD-MMM-YYYY")}</td>
                      <td>${x.Status}</td>
                      <td>
                         <a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="ViewPage(${x.ID},'${x.T_Type}')" id="btnview"><i class="fa fa-eye" ></i></a>
                      </td>
                  </tr>
              `);
                    });
                }
            });
        }
        function ViewPage(id, type) {
            debugger;
            var ID = id
            if (type == 'GRN') {
                window.open("GRN.aspx?GRN_ID=" + ID, "_blank");
            }
            else if (type == 'IGP') {
                window.open("InversionGatePass.aspx?IGP_Id = " + ID, "_blank");
            }
            else if (type == 'PO') {
                window.open("../AP/PurchaseOrder.aspx?PO_ID=" + ID, "_blank");
            }
            else if (type == 'PR') {
                window.open("../AP/PurchaseRequistion.aspx?ID=" + ID, "_blank");
            }
            else if (type == 'PUR Inv') {
                window.open("AddPurchaseInvoice.aspx?Inv_ID=" + ID, "_blank");
            }
            else if (type == 'Pay Inv') {
                window.open("AddPaymentInvoice.aspx?Inv_ID=" + ID, "_blank");
            }
        }  


    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
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
