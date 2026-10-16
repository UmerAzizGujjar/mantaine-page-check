<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="IPDMedicineHistory.aspx.cs" Inherits="PMS.Modules.Billing.IPDMedicineHistory" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <style>
        #tbl tr.row-rejected td {
            background-color: #f8d7da !important;
            color: #842029 !important;
        }
        #tbl tr.row-rejected td a {
            pointer-events: none;
            opacity: 0.6;
        }
        .badge-closed {
            background-color: #dc3545;
            color: #fff;
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 11px;
            font-weight: 600;
            display: inline-block;
        }
        .badge-pending {
            background-color: #ffc107;
            color: #000;
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 11px;
            font-weight: 600;
            display: inline-block;
        }
        .badge-issued {
            background-color: #198754;
            color: #fff;
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 11px;
            font-weight: 600;
            display: inline-block;
        }
        #tbl td.rcv-over {
            background-color: #fff3cd !important;
            color: #856404 !important;
            font-weight: 700 !important;
        }
        #tbl td.rcv-short {
            background-color: #dc3545 !important;
            color: #fff !important;
            font-weight: 700 !important;
            font-size: 14px !important;
            text-shadow: 0 1px 1px rgba(0,0,0,0.4);
            box-shadow: inset 0 0 0 2px #842029;
        }
        #tbl tr.row-rejected td.rcv-short {
            background-color: #b02a37 !important;
            color: #fff !important;
            box-shadow: inset 0 0 0 2px #000;
        }
    </style>
    <script type="text/javascript">

    $(document).ready(function () {
        $('#ctl00_lblMessage').hide();
        LoadPage();
    });

    function LoadPage() {
        let savedVisibility = null;
        $.ajax({
            type: "POST",
            url: "IPDMedicineHistory.aspx/GetUserColumnPreferences",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            async: false,
            success: function (response) {
                if (response.d && response.d !== "") {
                   try {
                        savedVisibility = JSON.parse(response.d);
                    }
                    catch (e) {
                        console.warn("Invalid column visibility JSON");
                    }
                }
            },
            error: function () {
                console.error("Failed to load column preferences");
            }
        });
        $("#tbl").DataTable({

            "processing": true,
            "serverSide": true,
            "destroy": true,
            "filter": true,
            "lengthChange": true,
            "searchDelay": 500,
            "deferRender": true,

            "dom": 'lBfrtip',

            buttons: [
                'copy',
                'excel',
                {
                    extend: 'pdfHtml5',
                    text: 'PDF',
                    orientation: 'Potrait',
                    pageSize: 'A3',
                    exportOptions: {
                        columns: ':not(:last-child)'
                    },
                    customize: function (doc) {
                        doc.defaultStyle.fontSize = 8;
                    }
                },
                {
                    extend: 'colvis',
                    text: '<i class="fa fa-columns"></i> Columns',
                    className: 'dt-button buttons-colvis',
                    collectionLayout: 'fixed two-column',
                    postfixButtons: ['colvisRestore']
                }
            ],

            "ajax": function (data, callback, settings) {

                $.ajax({
                    type: "POST",
                    url: "IPDMedicineHistory.aspx/ViewList",

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
                {
                    "data": "In_Patient_Medicine_ID", "visible": false,"width": "0%"
                },
                {
                    "data": "Medicine_Date", "name": "Medicine_Date", "render": function (data, type, full) {
                        if (full.Medicine_Date != null) {
                            return moment(full.Medicine_Date).format('DD-MMM-YYYY');
                        }
                        return '';
                    },
                    "width": "8%",
                    "orderable": true
                },
                {
                    "data": "mr_no_sequence", "name": "mr_no_sequence","width": "6%",
                    "orderable": true
                },
                {"data": "Full_Name","name": "Full_Name", "width": "8%", "orderable": true},
                {"data": "Father_Name","width": "8%","orderable": false },
                { "data": "Ward_Name", "width": "8%", "orderable": false },
                { "data": "Medicine_Name", "name": "Medicine_Name", "width": "12%", "orderable": false },
                { "data": "Bed_No", "width": "6%", "orderable": false },
                {
                    "data": "Request_Time", "name": "Request_Time",
                    "render": function (data, type, full) {
                        if (full.Request_Time == null) return '';
                        return moment(full.Request_Time).format('DD-MMM-YYYY hh:mm A');
                    }, "width": "9%", "orderable": true
                },
                { "data": "Req_Qty", "width": "6%", "orderable": false },
                { "data": "Rcv_Qty", "width": "6%", "orderable": false },
                {
                    "data": "Issue_Date", "name": "Issue_Date",
                    "render": function (data, type, full) {
                        if (full.Issue_Date == null) return '';
                        return moment(full.Issue_Date).format('DD-MMM-YYYY hh:mm A');
                    }, "width": "9%", "orderable": true
                },
                { "data": "Rtn_Qty", "width": "6%", "orderable": false },
                { "data": "Issue_Rcvd_Qty", "width": "6%", "orderable": false },
                {
                    "data": "Receive_Time", "name": "Receive_Time",
                    "render": function (data, type, full) {
                        if (full.Receive_Time == null) return '';
                        return moment(full.Receive_Time).format('DD-MMM-YYYY hh:mm A');
                    }, "width": "16%", "orderable": true
                },
                {
                    render: function (data, type, full) {
                        var rejected = (full.is_rejected == true || full.Status === "rejected");
                        var reqQty = parseFloat(full.Req_Qty) || 0;
                        var issueRcvdQty = parseFloat(full.Issue_Rcvd_Qty) || 0;
                        var fullyIssued = (reqQty > 0 && reqQty === issueRcvdQty);

                        if (rejected && fullyIssued) {
                            return '<span class="badge-closed">Issued/Closed</span>';
                        }
                        if (rejected) {
                            return '<span class="badge-closed">Closed</span>';
                        }
                        if (fullyIssued) {
                            return '<span class="badge-issued">Issued</span>';
                        }
                        return '<span class="badge-pending">Pending</span>';
                    },
                    "width": "6%",
                    "orderable": false
                }
            ],

            "createdRow": function (row, data, dataIndex) {
                if (data.is_rejected == true || data.Status === "rejected") {
                    $(row).addClass('row-rejected');
                }
                var rcv = parseFloat(data.Rcv_Qty) || 0;
                var req = parseFloat(data.Req_Qty) || 0;
                if (req > 0 && rcv > req) {
                    $(row).find('td:eq(8)').addClass('rcv-over');
                } else if (req > 0 && rcv < req) {
                    $(row).find('td:eq(8)').addClass('rcv-short');
                }
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

                var lengthContainer = document.querySelector('#tbl_length');
                var lengthDropdown = document.querySelector('#tbl_length select');
                var label = document.querySelector('#tbl_length label');

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
    }

    function ViewDetails(id) {

        alert("Selected Medicine ID : " + id);

        // window.location.href = "IPDMedicineDetail.aspx?ID=" + id;
    }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
    <div class="table-container">
        <table id="tbl" class="table table-bordered table-hover table-striped">
            <thead id="ihead">
                <tr>
                    <th style="display:none;">Medicine_ID</th>
                    <th>Medicine Date</th>
                    <th>MR No</th>
                    <th>Patient Name</th>
                    <th>Father Name</th>
                    <th>Ward</th>
                    <th>Medicine Name</th>
                    <th>Bed No</th>
                    <th>Request Time</th>
                    <th>Issued Qty</th>
                    <th>Rcv Qty</th>
                    <th>Issue Time </th>
                    <th>Rtn Qty</th>
                    <th>Issued Rcv Qty</th>
                    <th>Issued Rcv Time</th>
                    <th>View</th>
                </tr>
            </thead>
            <tbody id="tbody">
            </tbody>
        </table>
    </div>
</div>
</asp:Content>

