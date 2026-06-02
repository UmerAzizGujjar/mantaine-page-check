<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GRNView.aspx.cs" Inherits="PMS.Inventory.GRNView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/css/tablestyle.css" rel="stylesheet" />
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
            window.location.href = "GRN.aspx?GRN_ID=" + ID;
        }

        function Print(ids) {

            var id = ids
            var locationInfo = window.location;


            var user_name = '<% =AppConfig.Company_Name %>';
            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx'; // same folder
            }

            var url = '/ReportViewer.aspx?ReportName=GRNList&ReportTitle=Good Receipt List&GRNid=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/' + reportPath +  '?ReportName=GRNList&ReportTitle=Good Receipt List&GRNid=' + id;
            }
            window.open(url, '_blank');
        }
        function PrintVoucher(id) {

            var locationInfo = window.location;

            var user_name = '<% =AppConfig.Company_Name %>';
            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx'; // same folder
            }
            var url = '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=GRN Voucher&TransID=' + id + '&TransType=GRN';
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/' + reportPath +  '?ReportName=Voucher&ReportTitle=GRN Voucher&TransID=' + id + '&TransType=GRN';
            }
            window.open(url, '_blank');
        } 


        function LoadPage() {
            let savedVisibility = null;

            $.ajax({
                type: "POST",
                url: "GRNView.aspx/GetUserColumnPreferences",
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

            var table =  $("#tblResult").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'GRN.aspx'; } }, 'copy', 'excel', 'pdf',
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
                
                    { "data": "GRN_Num", "name": "GRN_Num", "orderable": true },
                    {
                        "data": "Approved_Date",
                        "render": function (data, type, full) {
                            var date = full.Approved_Date;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "orderable": false
                    },
                    { "data": "Vendor_Name", "orderable": false },
                    { "data": "Ware_House", "orderable": false },
                    { "data": "CreatedBy", "orderable": false },   // ← NEW
                    {
                        "data": "Creation_Date",
                        "render": function (data, type, full) {
                            return full.Creation_Date ? moment(full.Creation_Date).format('D-MMM-YYYY') : '';
                        },
                        "orderable": false
                    },  // ← NEW
                    { "data": "Updated_By", "orderable": false },  // ← NEW
                    {
                        "data": "Update_Date",
                        "render": function (data, type, full) {
                            return full.Update_Date ? moment(full.Update_Date).format('D-MMM-YYYY') : '';
                        },
                        "orderable": false
                    },
                    { "data": "Remarks", "orderable": false },
                    { "data": "Status", "orderable": false },
                    {
                        "render": function (data, type, full) {
                            var res = '<a href="#" class="editListBtn" onclick="Edit(' + full.GRN_ID + ')" style="border-radius: 4px;margin-right: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>'

                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="Print(' + full.GRN_ID + ')" id="btnprint"><i class="fa fa-print"></i></a>';
                            var result = res + print;
                            return result;
                        }, "orderable": false
                    }
                ],
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
                    }
                },
                "rowCallback": function (row, data, index) {
                    if (data.Status === "Approved") {
                        $(row).css('background-color', '#ABEBC6');
                    }
                }
            });
            $('#tblResult tbody').on('click', 'tr', function () { 
                debugger;
                var row = table.row(this);
                var data = row.data();
                if (!data) return;
                var id = data.GRN_ID;
                if (row.child.isShown()) {
                    row.child.hide();
                    $(this).removeClass('shown');
                    return;
                }
                row.child('<div class="child-loading">Loading...</div>').show();
                $(this).addClass('shown');

                $.ajax({
                    type: "POST",
                    url: "GRNView.aspx/GetMasterAndDetail",
                    data: JSON.stringify({ invoiceId: id }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (resp) {
                        var d = resp.d;
                        var html = `
                         <div class="child-container">                            
                             <div class="col-sm-4 col-md-4 col-lg-3 child-col-left">
                                 <h5>Master Information</h5>
                                 <p><b>Invoice #:</b> ${d.Master.GRN_Num}</p>
                                 <p><b>Date:</b> ${moment(d.Master.GRN_Date).format("DD-MMM-YYYY")}</p>
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
                               <td>${item.GRNQty}</td>
                               <td>${item.Rate}</td>
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
                url: "GRNView.aspx/GetAuditInfo",
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
                window.open("GRN.aspx?GRN_ID="+ ID, "_blank");
            }
            else if (type == 'IGP') {
                window.open("InversionGatePass.aspx?IGP_Id =" + ID, "_blank");
            }
            else if (type == 'PO') {
                window.open("../AP/PurchaseOrder.aspx?PO_ID="+ ID, "_blank");
            }
            else if (type == 'PR') {
                window.open("../AP/PurchaseRequistion.aspx?ID="+ ID, "_blank");
            }
            else if (type == 'PUR Inv') {
                window.open("AddPurchaseInvoice.aspx?Inv_ID="+ ID, "_blank");
            }
            else if (type == 'Pay Inv') {
                window.open("AddPaymentInvoice.aspx?Inv_ID="+ ID, "_blank");
            }
        }  

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="table-container">
    <div class="row col-lg-12 col-md-12 col-sm-12 col-xs-12">
        <div id="GRNdetails" style="margin-top: 15px;">  
         <div>
            </div>
        <table class="table table-responsive table-hover table-bordered" id="tblResult">
            <thead id="ihead">
                <tr>              
                    <th>GRN ID</th>
                    
                    <th>Grn Num</th>
                    <th>Approval Date</th>
                    <th>Vendor Name</th>
                    <th>Ware House</th>
                     <th>Created By</th>
                     <th>Created Date</th>
                     <th>Updated By</th>
                     <th>Updated Date</th>
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
