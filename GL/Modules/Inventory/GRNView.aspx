<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GRNView.aspx.cs" Inherits="PMS.Inventory.GRNView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/custom-modals.css" rel="stylesheet" />
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

        .logListBtn {
            background-color: #455a64 !important;
            color: #fff !important;
        }

            .logListBtn:hover {
                background-color: #2f3d45 !important;
            }

        .grn-log-body {
            background: #f4f6f9;
            font-size: 12px;
            color: #333;
            padding: 0 !important;
        }

        .bl-scroll {
            max-height: calc(100vh - 240px);
            overflow-y: auto;
            padding: 14px 16px;
        }

        .bl-loading {
            text-align: center;
            padding: 40px;
            color: #888;
        }

            .bl-loading i {
                margin-right: 6px;
            }

        .bl-empty {
            text-align: center;
            padding: 46px 10px;
            color: #8a8f98;
        }

        .bl-empty-ico {
            font-size: 46px;
            color: #d5dae0;
            display: block;
            margin-bottom: 12px;
        }

        .bl-empty-title {
            font-weight: 700;
            font-size: 13px;
            color: #5c636a;
            display: block;
        }

        .bl-empty-sub {
            font-size: 11.5px;
            color: #9aa1a8;
            margin-top: 4px;
        }

        .bl-card {
            background: #fff;
            border: 1px solid #e3e6ea;
            border-radius: 8px;
            margin-bottom: 14px;
            overflow: hidden;
            box-shadow: 0 1px 2px rgba(0,0,0,.05);
        }

        .bl-card-head {
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 8px 12px;
            padding: 9px 12px;
            background: #fbfcfe;
            border-bottom: 1px solid #eceef1;
        }

        .bl-seq {
            background: #EFA63E;
            color: #fff;
            font-weight: 700;
            font-size: 11px;
            padding: 3px 11px;
            border-radius: 12px;
            white-space: nowrap;
        }

        .bl-seq-newest {
            background: #cb8d35;
        }

        .bl-meta {
            color: #6b7280;
            font-size: 11px;
            display: flex;
            align-items: center;
            gap: 4px;
        }

            .bl-meta i {
                color: #b0b6be;
            }

        .bl-chips {
            margin-left: auto;
            display: flex;
            gap: 6px;
            flex-wrap: wrap;
        }

        .bl-chip {
            font-size: 10.5px;
            font-weight: 700;
            padding: 2px 9px;
            border-radius: 11px;
            white-space: nowrap;
        }

        .bl-chip-add {
            background: #e7f6ec;
            color: #1c7d43;
        }

        .bl-chip-del {
            background: #fdeaea;
            color: #b02a37;
        }

        .bl-chip-mod {
            background: #fff4e0;
            color: #9a6700;
        }

        .bl-sec-label {
            padding: 8px 12px;
            font-weight: 700;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: .04em;
            color: #69707a;
            background: #f6f8fa;
            border-bottom: 1px solid #eef0f3;
        }

        .bl-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 12px;
            margin: 0;
        }

            .bl-table th {
                background: #f8fafb;
                font-size: 10.5px;
                text-transform: uppercase;
                letter-spacing: .03em;
                color: #7d8790;
                padding: 6px 12px;
                border-bottom: 1px solid #e6e9ed;
                white-space: nowrap;
                text-align: left;
            }

            .bl-table td {
                padding: 6px 12px;
                border-bottom: 1px solid #f0f2f4;
                vertical-align: top;
                font-size: 12px;
            }

        .bl-table-cmp th:first-child,
        .bl-table-cmp td:first-child {
            width: 17%;
        }

        .bl-fld {
            color: #5b636b;
            font-weight: 600;
            white-space: nowrap;
        }

        .bl-val {
            color: #6f767d;
        }

        .bl-val-old {
            color: #b02a37;
            font-weight: 600;
        }

        .bl-val-new {
            color: #1c7d43;
            font-weight: 700;
        }

        .bl-arrow {
            color: #c3c9cf;
            text-align: center;
            white-space: nowrap;
            width: 34px;
        }

        .bl-none {
            color: #9aa1a8;
            font-style: italic;
            padding: 8px 12px;
        }

        .bl-itemname {
            font-weight: 600;
            color: #37424c;
        }

        .bl-itemname-old {
            text-decoration: line-through;
            color: #b02a37;
        }

        .bl-itemname-new {
            font-weight: 700;
            color: #1c7d43;
        }

        .bl-note {
            padding: 8px 12px 10px;
            color: #97a0a8;
            font-style: italic;
            font-size: 11px;
            border-top: 1px dashed #e2e6ea;
        }

        /* ===== Approval Log portion ===== */
        .ap-section {
            margin-top: 18px;
            padding-top: 14px;
            border-top: 2px solid #dfe4ea;
        }

        .ap-section-head {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 0 2px 10px;
        }

        .ap-section-ico {
            color: #3498db;
            font-size: 16px;
        }

        .ap-section-title {
            font-weight: 800;
            font-size: 14px;
            color: #2f3d45;
            letter-spacing: .02em;
        }

        .ap-section-count {
            margin-left: auto;
            font-size: 11px;
            font-weight: 700;
            color: #6b7280;
            background: #eef2f6;
            border-radius: 11px;
            padding: 2px 10px;
        }

        .ap-card {
            border-left: 4px solid #cbd5e1;
        }

        .ap-badge {
            font-size: 10.5px;
            font-weight: 800;
            padding: 3px 11px;
            border-radius: 11px;
            white-space: nowrap;
            text-transform: uppercase;
            letter-spacing: .03em;
        }

        .ap-badge-app {
            background: #e7f6ec;
            color: #1c7d43;
        }

        .ap-badge-pend {
            background: #fff4e0;
            color: #9a6700;
        }

        .ap-badge-rej {
            background: #fdeaea;
            color: #b02a37;
        }

        .ap-stage {
            font-weight: 700;
            font-size: 12px;
            color: #37424c;
        }

        .ap-tag {
            font-size: 10px;
            font-weight: 700;
            padding: 2px 8px;
            border-radius: 9px;
            background: #eef2f6;
            color: #5b636b;
        }

        .ap-tag-final {
            background: #e7f0fb;
            color: #1b48ed;
        }

        .ap-tag-bypass {
            background: #f3e8fd;
            color: #6b21a8;
        }

        .ap-tag-edit {
            background: #e0f7fa;
            color: #0e7490;
        }

        .ap-remarks {
            padding: 8px 12px;
            font-size: 12px;
            color: #4c545d;
        }

            .ap-remarks i {
                color: #b0b6be;
                margin-right: 4px;
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

                            var logBtn = '<a class="logListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="openGRNLogs(' + full.GRN_ID + ',\'' + full.GRN_Num + '\');return false;" title="View Change History"><i class="fa fa-history"></i></a>';

                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="Print(' + full.GRN_ID + ')" id="btnprint"><i class="fa fa-print"></i></a>';
                            var voucherBtn = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: var(--theme-on-accent, #fff);background-color: var(--theme-accent, #EFA63E);padding: 5px 8px 5px 8px;" href="#" onclick="event.stopPropagation(); openGRNVoucher(' + full.GRN_ID + ',\'' + full.GRN_Num + '\');return false;" title="View Voucher"><i class="fa fa-book"></i></a>';

                            var result = res + logBtn + print + voucherBtn;
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
        // GL voucher posted for this GRN, shown in a modal
        function openGRNVoucher(grnId, grnNo) {
            var $body = $('#grnVoucherBody');
            $body.html('<div class="bl-loading"><i class="fa fa-spinner fa-spin"></i>Loading voucher&hellip;</div>');
            $('#grnVoucherTitle').text('GRN Voucher' + (grnNo ? ' - GRN ' + grnNo : ''));
            $('#grnVoucherModal').modal({ backdrop: 'static' });

            $.ajax({
                type: "POST",
                url: "GRNView.aspx/GetGRNVoucherDetail",
                data: JSON.stringify({ grnId: grnId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var d = JSON.parse(response.d);
                    if (!d.lines || d.lines.length === 0) {
                        $body.html('<div class="bl-empty"><i class="fa fa-book bl-empty-ico"></i><span class="bl-empty-title">No voucher posted for this GRN</span></div>');
                        return;
                    }

                    var lineRows = d.lines.map(function (l) {
                        return '<tr><td>' + escHtml(l.Account_Code) + '</td><td>' + escHtml(l.Account_Name) + '</td>' +
                               '<td>' + escHtml(l.Narration) + '</td>' +
                               '<td style="text-align:right;">' + fmtMoney(l.DR) + '</td>' +
                               '<td style="text-align:right;">' + fmtMoney(l.CR) + '</td></tr>';
                    }).join('');

                    $body.html(
                        '<div class="bl-card">' +
                        '<div class="bl-card-head"><span class="ap-badge ' + (d.status === 'Approved' ? 'ap-badge-app' : 'ap-badge-pend') + '">' + escHtml(d.status || 'Unknown') + '</span></div>' +
                        '<table class="bl-table"><thead><tr><th>Account Code</th><th>Account</th><th>Narration</th>' +
                        '<th style="text-align:right;">DR</th><th style="text-align:right;">CR</th></tr></thead>' +
                        '<tbody>' + lineRows + '</tbody></table>' +
                        '</div>');
                },
                error: function () {
                    $body.html('<div class="bl-empty"><i class="fa fa-exclamation-triangle bl-empty-ico" style="color:#d8a25a;"></i><span class="bl-empty-title">Unable to load voucher</span></div>');
                }
            });
        }

        function ViewPage(id, type) {
            var ID = id
            if (type == 'GRN') {
                window.open("GRN.aspx?GRN_ID="+ ID, "_blank");
            }
            else if (type == 'IGP') {
                window.open("InversionGatePass.aspx?IGP_Id=" + ID, "_blank");
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

        // ================= GRN CHANGE HISTORY (GRN_Logs) =================

        var GRNMasterFields = [
            { k: 'Grn_No', l: 'GRN No', kind: 'int' },
            { k: 'Grn_Date', l: 'GRN Date', kind: 'date' },
            { k: 'Vendor_Name', l: 'Vendor', kind: 'text' },
            { k: 'Warehouse', l: 'Warehouse', kind: 'text' },
            { k: 'Project', l: 'Project', kind: 'text' },
            { k: 'Remarks', l: 'Remarks', kind: 'text' },
            { k: 'Status', l: 'Status', kind: 'text' },
            { k: 'Is_Direct', l: 'Direct', kind: 'text' }
        ];

        var GRNItemFields = [
            { k: 'Item_Name', l: 'Item', kind: 'text' },
            { k: 'GRNQty', l: 'GRN Qty', kind: 'qty' },
            { k: 'UOM_Qty', l: 'UOM Qty', kind: 'qty' },
            { k: 'Rate', l: 'Rate', kind: 'money' },
            { k: 'Amount', l: 'Amount', kind: 'money' },
            { k: 'Sale_Rate', l: 'Sale Rate', kind: 'money' },
            { k: 'BatchNum', l: 'Batch', kind: 'text' },
            { k: 'BounusQty', l: 'Bonus Qty', kind: 'qty' },
            { k: 'MfgDate', l: 'Mfg Date', kind: 'date' },
            { k: 'ExpiryDate', l: 'Expiry Date', kind: 'date' }
        ];

        function escHtml(s) {
            return String(s == null ? '' : s)
                .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
        }

        function fmtMoney(v) {
            if (v === null || v === undefined || v === '') return '';
            var n = Number(v);
            if (isNaN(n)) return String(v);
            var neg = n < 0;
            n = Math.abs(n);
            var parts = n.toFixed(2).split('.');
            parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
            return (neg ? '-' : '') + parts[0] + '.' + parts[1];
        }

        function fmtQty(v) {
            if (v === null || v === undefined || v === '') return '';
            var n = Number(v);
            if (isNaN(n)) return String(v);
            return Number.isInteger(n) ? String(n) : n.toFixed(2);
        }

        var GRNMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

        function normDateText(v) {
            if (v === null || v === undefined || v === '') return '';
            var s = String(v);
            var m = s.match(/^\/Date\((-?\d+)\)\/$/);
            var d = null;
            if (m) {
                d = new Date(Number(m[1]));
            } else if (/^\d{4}-\d{2}-\d{2}/.test(s)) {
                d = new Date(s.replace(' ', 'T'));
            } else {
                return s;
            }
            if (isNaN(d.getTime())) return s;
            var p = function (x) { return x < 10 ? '0' + x : '' + x; };
            return p(d.getDate()) + '-' + GRNMonths[d.getMonth()] + '-' + d.getFullYear() + ' ' + p(d.getHours()) + ':' + p(d.getMinutes());
        }

        function normByKind(kind, v) {
            if (kind === 'money') return fmtMoney(v);
            if (kind === 'qty') return fmtQty(v);
            if (kind === 'num') return (v === null || v === undefined || v === '') ? '' : String(Number(v));
            if (kind === 'int') return (v === null || v === undefined || v === '') ? '' : String(Number(v));
            if (kind === 'date') return normDateText(v);
            return (v === null || v === undefined) ? '' : String(v);
        }

        function hasOwn(o, k) {
            return o !== null && typeof o === 'object' && Object.prototype.hasOwnProperty.call(o, k);
        }

        function grnItems(state) {
            if (!state || !state.details || !state.details.Items) return [];
            return state.details.Items;
        }

        function diffMaster(before, after) {
            var rows = [];
            if (!before || !after) return rows;
            GRNMasterFields.forEach(function (f) {
                if (!hasOwn(before.master, f.k) || !hasOwn(after.master, f.k)) return;
                var b = normByKind(f.kind, before.master[f.k]);
                var a = normByKind(f.kind, after.master[f.k]);
                if (b !== a) rows.push({ label: f.l, prev: b, cur: a });
            });
            return rows;
        }

        function diffItems(before, after) {
            var result = { added: [], removed: [], modified: [] };
            if (!before || !after) return result;
            var prevArr = grnItems(before);
            var nextArr = grnItems(after);
            var keyOf = function (it) {
                return String(it.Item_Code == null ? '' : it.Item_Code) + '_' + String(it.IGPDetailId == null ? '' : it.IGPDetailId);
            };
            var map = function (arr) {
                var m = {};
                arr.forEach(function (it) { m[keyOf(it)] = it; });
                return m;
            };
            var prevMap = map(prevArr);
            var nextMap = map(nextArr);

            nextArr.forEach(function (it) {
                var k = keyOf(it);
                if (!hasOwn(prevMap, k)) result.added.push(it);
            });
            prevArr.forEach(function (it) {
                var k = keyOf(it);
                if (!hasOwn(nextMap, k)) {
                    result.removed.push(it);
                } else {
                    var beforeIt = prevMap[k];
                    var nextIt = nextMap[k];
                    var changes = [];
                    GRNItemFields.forEach(function (f) {
                        var b = normByKind(f.kind, beforeIt[f.k]);
                        var a = normByKind(f.kind, nextIt[f.k]);
                        if (b !== a) changes.push({ label: f.l, prev: b, cur: a });
                    });
                    if (changes.length > 0) result.modified.push({ item: nextIt, changes: changes });
                }
            });
            return result;
        }

        function grnItemRow(item, extraClass) {
            return '<tr><td class="bl-itemname ' + (extraClass || '') + '">' + escHtml(item.Item_Name) + '</td>'
                + '<td>' + fmtQty(item.GRNQty) + '</td>'
                + '<td>' + fmtQty(item.UOM_Qty) + '</td>'
                + '<td>' + escHtml(item.BatchNum) + '</td>'
                + '<td>' + fmtMoney(item.Rate) + '</td>'
                + '<td>' + fmtMoney(item.Amount) + '</td></tr>';
        }

        function buildGRNItemsHTML(diff) {
            var any = diff.added.length > 0 || diff.removed.length > 0 || diff.modified.length > 0;
            if (!any) return '';

            var row = function (name, tag, tagCls, oldVal, curVal) {
                return '<tr>'
                    + '<td class="bl-itemname">' + escHtml(name) + '</td>'
                    + '<td class="bl-fld">' + (tag ? '<span class="bl-chip ' + tagCls + '">' + escHtml(tag) + '</span>' : '') + '</td>'
                    + '<td class="bl-val ' + (oldVal === null ? '' : 'bl-val-old') + '">' + (oldVal === null ? '&mdash;' : escHtml(oldVal)) + '</td>'
                    + '<td class="bl-val ' + (curVal === null ? '' : 'bl-val-new') + '">' + (curVal === null ? '&mdash;' : escHtml(curVal)) + '</td>'
                    + '</tr>';
            };

            var html = '';
            html += '<div class="bl-sec-label">GRN Items Updated</div>';

            if (diff.added.length > 0) {
                html += '<div class="bl-sub-sec-head" style="color:#1c7d43;padding:8px 12px 2px;font-weight:700;">Items Added <span class="bl-chip bl-chip-add">+' + diff.added.length + '</span></div>';
                html += '<table class="bl-table"><thead><tr><th>Item</th><th>GRN Qty</th><th>UOM Qty</th><th>Batch</th><th>Rate</th><th>Amount</th></tr></thead><tbody>';
                diff.added.forEach(function (it) { html += grnItemRow(it, 'bl-itemname-new'); });
                html += '</tbody></table>';
            }

            if (diff.removed.length > 0) {
                html += '<div class="bl-sub-sec-head" style="color:#b02a37;padding:8px 12px 2px;font-weight:700;">Items Removed <span class="bl-chip bl-chip-del">-' + diff.removed.length + '</span></div>';
                html += '<table class="bl-table"><thead><tr><th>Item</th><th>GRN Qty</th><th>UOM Qty</th><th>Batch</th><th>Rate</th><th>Amount</th></tr></thead><tbody>';
                diff.removed.forEach(function (it) { html += grnItemRow(it, 'bl-itemname-old'); });
                html += '</tbody></table>';
            }

            if (diff.modified.length > 0) {
                html += '<div class="bl-sub-sec-head" style="color:#9a6700;padding:8px 12px 2px;font-weight:700;">Items Modified <span class="bl-chip bl-chip-mod">' + diff.modified.length + '</span></div>';
                html += '<table class="bl-table bl-table-cmp"><thead><tr><th>Item</th><th>Field</th><th>Previous</th><th>Updated</th></tr></thead><tbody>';
                diff.modified.forEach(function (mod) {
                    mod.changes.forEach(function (c) {
                        html += row(mod.item.Item_Name, c.label, 'bl-chip-mod',
                            c.prev === '' ? null : c.prev,
                            c.cur === '' ? null : c.cur);
                    });
                });
                html += '</tbody></table>';
            }

            return html;
        }

        function buildRevisionHTML(evt, idx, total) {
            var d = diffMaster(evt.before, evt.after);
            var di = diffItems(evt.before, evt.after);
            var noCurrent = (evt.after === null);

            var chips = '';
            if (d.length > 0) chips += '<span class="bl-chip bl-chip-mod">' + d.length + ' field' + (d.length > 1 ? 's' : '') + '</span>';
            if (di.added.length > 0) chips += '<span class="bl-chip bl-chip-add">+' + di.added.length + ' item' + (di.added.length > 1 ? 's' : '') + '</span>';
            if (di.removed.length > 0) chips += '<span class="bl-chip bl-chip-del">-' + di.removed.length + ' item' + (di.removed.length > 1 ? 's' : '') + '</span>';

            var html = '<div class="bl-card">';
            html += '<div class="bl-card-head">';
            html += '<span class="bl-seq ' + (idx === 0 ? 'bl-seq-newest' : '') + '">' + (idx === 0 ? 'Latest Update' : 'Update #' + (total - idx)) + '</span>';
            html += '<span class="bl-meta"><i class="fa fa-user-o"></i> ' + escHtml(evt.user) + '</span>';
            html += '<span class="bl-meta"><i class="fa fa-clock-o"></i> ' + escHtml(evt.time) + '</span>';
            html += '<span class="bl-chips">' + chips + '</span>';
            html += '</div>';

            html += '<div class="bl-card-body">';
            if (noCurrent) {
                html += '<div class="bl-note">Current GRN data is no longer available (record may have been deleted). Only the stored snapshot is shown.</div>';
            }

            if (d.length > 0) {
                html += '<div class="bl-sec-label">GRN Summary &mdash; Changed Fields</div>';
                html += '<div style="overflow-x:auto;"><table class="bl-table bl-table-cmp"><thead><tr><th>Field</th><th>Previous Value</th><th></th><th>Updated Value</th></tr></thead><tbody>';
                d.forEach(function (row) {
                    html += '<tr><td class="bl-fld">' + escHtml(row.label) + '</td>'
                        + '<td class="bl-val bl-val-old">' + (row.prev === '' ? '&mdash;' : escHtml(row.prev)) + '</td>'
                        + '<td class="bl-arrow"><i class="fa fa-long-arrow-right"></i></td>'
                        + '<td class="bl-val bl-val-new">' + (row.cur === '' ? '&mdash;' : escHtml(row.cur)) + '</td></tr>';
                });
                html += '</tbody></table></div>';
            } else {
                html += '<div class="bl-none">No header field changes in this update.</div>';
            }

            html += buildGRNItemsHTML(di);
            if (!di.added.length && !di.removed.length && !di.modified.length) {
                html += '<div class="bl-note">No item level changes in this update.</div>';
            }
            html += '</div>';
            html += '</div>';
            return html;
        }

        function openGRNLogs(grnId, grnNo) {
            var $body = $('#grnModalBody');
            $body.html('<div class="bl-loading"><i class="fa fa-spinner fa-spin"></i>Loading change history&hellip;</div>');
            $('#grnLogTitle').text('GRN Change History' + (grnNo ? ' - ' + grnNo : ''));
            $('#grnLogModal').modal({ backdrop: 'static' });

            $.ajax({
                type: "POST",
                url: "GRNView.aspx/GetGRNLogs",
                data: JSON.stringify({ grnId: grnId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    try {
                        renderGRNLogs(JSON.parse(response.d));
                    } catch (ex) {
                        $body.html('<div class="bl-empty"><i class="fa fa-exclamation-triangle bl-empty-ico" style="color:#d8a25a;"></i><span class="bl-empty-title">Unable to load history</span><span class="bl-empty-sub">' + escHtml(ex.message) + '</span></div>');
                    }
                },
                error: function (err) {
                    $body.html('<div class="bl-empty"><i class="fa fa-exclamation-triangle bl-empty-ico" style="color:#d8a25a;"></i><span class="bl-empty-title">Unable to load history</span><span class="bl-empty-sub">Server error occurred while reading logs.</span></div>');
                }
            });
        }

        function renderGRNLogs(payload) {
            var $body = $('#grnModalBody');
            if (!payload || payload.error) {
                $body.html('<div class="bl-empty"><i class="fa fa-exclamation-triangle bl-empty-ico" style="color:#d8a25a;"></i><span class="bl-empty-title">Unable to load history</span><span class="bl-empty-sub">' + escHtml(payload && payload.error ? payload.error : 'No data returned.') + '</span></div>');
                return;
            }

            var logs = payload.logs || [];
            var current = payload.current;
            var approvals = payload.approvals || [];

            if (logs.length === 0) {
                var emptyHtml = '<div class="bl-empty"><i class="fa fa-history bl-empty-ico"></i><span class="bl-empty-title">No update history found</span><span class="bl-empty-sub">Changes are logged automatically each time this GRN is edited and saved.</span></div>';
                if (approvals.length > 0) {
                    emptyHtml += buildApprovalTrailHTML(approvals);
                }
                $body.html(emptyHtml);
                return;
            }

            var snapshots = logs.map(function (l) { return { master: l.Master, details: l.Details }; });
            var hasCurrent = current && current.master;
            if (hasCurrent) {
                snapshots.push({ master: current.master, details: current.details });
            }

            var events = [];
            for (var i = 0; i < logs.length; i++) {
                events.push({
                    user: logs[i].UserName,
                    time: logs[i].TimeText,
                    before: snapshots[i],
                    after: (i + 1 < snapshots.length) ? snapshots[i + 1] : null
                });
            }
            events.reverse();

            var total = events.length;
            var html = '';
            for (var j = 0; j < events.length; j++) {
                html += buildRevisionHTML(events[j], j, total);
            }

            if (approvals.length > 0) {
                html += buildApprovalTrailHTML(approvals);
            }

            $body.html(html);
        }

        function approvalStatusMeta(a) {
            var s = String(a.Status || '').toLowerCase();
            if (a.IsRejected || s === 'rejected' || s === 'cancelled') {
                return { cls: 'ap-badge-rej', text: a.Status || 'Rejected' };
            }
            if (s === 'approved') return { cls: 'ap-badge-app', text: 'Approved' };
            return { cls: 'ap-badge-pend', text: a.Status || 'Pending' };
        }

        function buildApprovalTrailHTML(approvals) {
            var html = '<div class="ap-section">';
            html += '<div class="ap-section-head">'
                + '<span class="ap-section-ico"><i class="fa fa-check-square-o"></i></span>'
                + '<span class="ap-section-title">Approval Log</span>'
                + '<span class="ap-section-count">' + approvals.length + ' entr' + (approvals.length > 1 ? 'ies' : 'y') + '</span>'
                + '</div>';

            approvals.forEach(function (a) {
                var meta = approvalStatusMeta(a);
                var tags = '';
                if (a.IsFinal) tags += '<span class="ap-tag ap-tag-final">Final</span>';
                if (a.IsByPassed) tags += '<span class="ap-tag ap-tag-bypass">By-passed</span>';
                if (a.IsEditableAfterApproval) tags += '<span class="ap-tag ap-tag-edit">Editable</span>';

                html += '<div class="bl-card ap-card">';
                html += '<div class="bl-card-head">';
                html += '<span class="ap-badge ' + meta.cls + '">' + escHtml(meta.text) + '</span>';
                if (a.StageName) html += '<span class="ap-stage">' + escHtml(a.StageName) + '</span>';
                html += '<span class="bl-meta"><i class="fa fa-user-o"></i> ' + escHtml(a.User || '\u2014') + '</span>';
                if (a.DateText) html += '<span class="bl-meta"><i class="fa fa-clock-o"></i> ' + escHtml(a.DateText) + '</span>';
                html += '<span class="bl-chips">' + tags + '</span>';
                html += '</div>';

                if (a.Remarks) {
                    html += '<div class="bl-card-body"><div class="ap-remarks"><i class="fa fa-comment-o"></i> ' + escHtml(a.Remarks) + '</div></div>';
                }
                html += '</div>';
            });

            html += '</div>';
            return html;
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

    <div class="modal fade" id="grnLogModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog custom-modal-dialog custom-modal-dialog-xl" role="document">
            <div class="modal-content custom-modal-content">

                <div class="modal-header custom-modal-header">
                    <div class="custom-modal-title-wrap">
                        <span class="custom-modal-icon"><i class="fa fa-history"></i></span>
                        <h4 class="modal-title custom-modal-title" id="grnLogTitle">GRN Change History</h4>
                    </div>
                    <button type="button" class="custom-modal-close" data-dismiss="modal" aria-label="Close">
                        <i class="fa fa-times"></i>
                    </button>
                </div>

                <div class="modal-body custom-modal-body grn-log-body">
                    <div class="bl-scroll">
                        <div id="grnModalBody"></div>
                    </div>
                </div>

                <div class="custom-modal-footer">
                    <span class="custom-modal-count">Change history is recorded automatically on every save. Newest update shown first.</span>
                    <button type="button" class="custom-modal-btn-close" data-dismiss="modal">
                        <i class="fa fa-times-circle"></i> Close
                    </button>
                </div>

            </div>
        </div>
    </div>

    <div class="modal fade" id="grnVoucherModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog custom-modal-dialog custom-modal-dialog-xl" role="document">
            <div class="modal-content custom-modal-content">

                <div class="modal-header custom-modal-header">
                    <div class="custom-modal-title-wrap">
                        <span class="custom-modal-icon"><i class="fa fa-book"></i></span>
                        <h4 class="modal-title custom-modal-title" id="grnVoucherTitle">GRN Voucher</h4>
                    </div>
                    <button type="button" class="custom-modal-close" data-dismiss="modal" aria-label="Close">
                        <i class="fa fa-times"></i>
                    </button>
                </div>

                <div class="modal-body custom-modal-body grn-log-body">
                    <div class="bl-scroll">
                        <div id="grnVoucherBody"></div>
                    </div>
                </div>

                <div class="custom-modal-footer">
                    <span class="custom-modal-count">GL entries posted for this GRN.</span>
                    <button type="button" class="custom-modal-btn-close" data-dismiss="modal">
                        <i class="fa fa-times-circle"></i> Close
                    </button>
                </div>

            </div>
        </div>
    </div>
</asp:Content>
