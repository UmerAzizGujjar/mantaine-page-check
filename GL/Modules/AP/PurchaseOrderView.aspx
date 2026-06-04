<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PurchaseOrderView.aspx.cs" Inherits="PMS.PurchaseOrderView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <link href="../../wwwroot/lib/sweetalert/tablestyle.css" rel="stylesheet" />
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
            var user_name = '<% =AppConfig.Company_Name %>';
            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx'; // same folder
            }
            var url = '/ReportViewer.aspx?ReportName=PurchaseOrderList&ReportTitle=Purchase Order List&POid=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/' + reportPath +  '?ReportName=PurchaseOrderList&ReportTitle=Purchase Order List&POid=' + id;
            }
            window.open(url,'_blank');
        }
        function redirecttonew() {
            window.location.href = "PurchaseOrder.aspx";
        }


        function LoadPage() {
            let savedVisibility = null;

            $.ajax({
                type: "POST",
                url: "PurchaseOrderView.aspx/GetUserColumnPreferences",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    if (response.d && response.d !== "") {
                        try {
                            savedVisibility = JSON.parse(response.d);
                        } catch (e) {
                            console.warn("Invalid column visibility JSON");
                        }
                    }
                },
                error: function () {
                    console.error("Failed to load column preferences");
                }
            });
            var table =  $("#example").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'PurchaseOrder.aspx'; } }, 'copy', 'excel', 'pdf',
                    {
                        extend: 'colvis',
                        text: '<i class="fa fa-columns"></i> Columns',
                        className: 'dt-button buttons-colvis',
                        collectionLayout: 'fixed two-column',
                        postfixButtons: ['colvisRestore']
                    }
                ],
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
                    { "data": "RefNo", "width": "10%", "orderable": true },
                    { "data": "VendorName", "width": "10%", "orderable": false },
                    { "data": "Ware_House", "width": "7%", "orderable": false },
                    { "data": "PO_Amount", "width": "10%", className: "text-right", "orderable": false },
                    { "data": "Status", "width": "10%", "orderable": false },
                    { "data": "CreatedBy", "width": "10%", "orderable": false },
                    { "data": "Approvedby", "width": "10%", "orderable": false },
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
                    const api = this.api();
                    if (savedVisibility && Array.isArray(savedVisibility)) {
                        if (savedVisibility.length === api.columns().count()) {
                            api.columns().every(function (index) {
                                this.visible(savedVisibility[index]);
                            });
                        }
                    }
                    api.on('column-visibility.dt', function (e, settings, column, state) {
                        let currentVis = [];
                        api.columns().every(function () {
                            currentVis.push(this.visible());
                        });
                        PageMethods.SaveUserColumnPreferences(
                            JSON.stringify(currentVis),
                            function () {
                                console.log("Column preferences saved");
                            },
                            function (error) {
                                console.error("Failed to save preferences:", error);
                            }
                        );
                    });

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
                    }
                }
            });
            $('#example tbody').on('click', 'tr', function () {
                var row = table.row(this);
                var data = row.data();
                if (!data) return;
                var id = data.POID;
                if (row.child.isShown()) {
                    row.child.hide();
                    $(this).removeClass('shown');
                    return;
                }
                row.child('<div class="child-loading">Loading...</div>').show();
                $(this).addClass('shown');

                $.ajax({
                    type: "POST",
                    url: "PurchaseOrderView.aspx/GetMasterAndDetail",
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
                                  <th>Item Code</th>
                                  <th>Item</th>
                                  <th>Qty</th>
                                  <th>Rate</th>
                                  <th>Discount Amount</th>
                                  <th>Net Amount</th>
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
                    <td>${item.Item_Code}</td>
                    <td>${item.Description}</td>
                    <td>${item.Qty}</td>
                    <td>${item.Rate}</td>
                    <td>${item.Discount_Amount}</td>
                    <td>${item.Amount}</td>
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
                url: "PurchaseOrderView.aspx/GetAuditInfo",
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
                window.open("../Inventory/GRN.aspx?GRN_ID=" + ID, "_blank");
            }
            else if (type == 'IGP') {
                window.open("../Inventory/InversionGatePass.aspx?IGP_Id = " + ID, "_blank");
            }
            else if (type == 'PO') {
                window.open("PurchaseOrder.aspx?PO_ID=" + ID, "_blank");
            }
            else if (type == 'PR') {
                window.open("PurchaseRequistion.aspx?ID=" + ID, "_blank");
            }
            else if (type == 'PUR Inv') {
                window.open("../Inventory/AddPurchaseInvoice.aspx?Inv_ID=" + ID, "_blank");
            }
            else if (type == 'Pay Inv') {
                window.open("../Inventory/AddPaymentInvoice.aspx?Inv_ID=" + ID, "_blank");
            }
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
            <th>WareHouse</th>
            <th>Net Amount</th>
            <th>Status</th>
            <th>Created By</th>
            <th>Approved By</th>
            <th>Action</th>
        </tr>
    </thead>
    <tbody id="tblbody">
    </tbody>
</table>

    </div>
    
</asp:Content>
