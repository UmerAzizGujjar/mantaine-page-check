<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GoodsIssuanceNoteView.aspx.cs" Inherits="PMS.GoodsIssuanceNoteView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />

    <script type="text/javascript">
        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();

        });


        function PrintReport(ID) {
            var locationInfo = window.location;

            var user_name = '<% =AppConfig.Company_Name %>';
            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx'; // same folder
            }
            var url = '/ReportViewer.aspx?ReportName=StoreIssueBasePrint&ReportTitle=Store Issue Note&SI_ID=' + ID;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/' + reportPath +  '?ReportName=StoreIssueBasePrint&ReportTitle=Store Issue Note&SI_ID=' + ID;
            }
            window.open(url, '_blank');
        }

        function Edit(ID) {
            window.location.href = "GoodsIssuanceNote.aspx?SI_ID=" + ID;
        }

        function redirecttonew() {
            window.location.href = "GoodsIssuanceNote.aspx";
        }
        function LoadPage() {

            var table = $("#example").DataTable({
                "processing": true,
                "serverSide": true,
                "destroy": true,
                "dom": 'lBfrtip',
                "lengthChange": true,

                "buttons": [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            window.location = 'GoodsIssuanceNote.aspx';
                        }
                    },
                    'copy',
                    'excel',
                    'pdf',
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
                        url: "GoodsIssuanceNoteView.aspx/ViewList",
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

                    { "data": "Store_Issue_Id", visible: false },

                    {
                        "data": "Store_Issue_No",
                        "name": "Store_Issue_No",
                        "orderable": true
                    },

                    {
                        "data": "Created_Time",
                        "render": function (data, type, full) {

                            if (!full.Created_Time)
                                return '';

                            return moment(full.Created_Time).format('D-MMM-YYYY');

                        },
                        "name": "Created_Time",
                        "orderable": true
                    },

                    {
                        "data": "Department",
                        "orderable": false
                    },

                    {
                        "data": "WareHouse",
                        "orderable": false
                    },

                    {
                        "data": "RequestNo",
                        "orderable": false
                    },

                    {
                        "data": "Requester",
                        "orderable": false
                    },

                    {
                        "data": "Issuer",
                        "orderable": false
                    },

                    {
                        "data": "Updated_By",
                        "orderable": false
                    },

                    {
                        "data": "Update_Time",
                        "render": function (data, type, full) {

                            return full.Update_Time
                                ? moment(full.Update_Time).format('D-MMM-YYYY hh:mm A')
                                : '';

                        },
                        "orderable": false
                    },

                    {
                        "data": "Status",
                        "orderable": false
                    },

                    {
                        "data": "Approved_Time",
                        "render": function (data, type, full) {

                            return full.Approved_Time
                                ? moment(full.Approved_Time).format('D-MMM-YYYY hh:mm A')
                                : '';

                        },
                        "orderable": false
                    },

                    {
                        "render": function (data, type, full) {

                            var editBtn =
                                '<a href="#" class="editListBtn" ' +
                                'onclick="Edit(' + full.Store_Issue_Id + ')" ' +
                                'style="border-radius:4px;margin-right:4px;padding:5px 8px;">' +
                                '<i class="fa fa-pencil"></i></a>';

                            var printBtn =
                                '<a href="#" class="printListBtn" ' +
                                'onclick="PrintReport(' + full.Store_Issue_Id + ')" ' +
                                'style="border-radius:4px;margin-left:4px;color:white;padding:5px 8px;">' +
                                '<i class="fa fa-print"></i></a>';

                            return editBtn + printBtn;

                        },
                        "orderable": false,
                        "width": "12%"
                    }

                ],

                "rowCallback": function (row, data, index) {

                    if (data.Status === "Approved") {
                        $(row).css('background-color', '#ABEBC6');
                    }

                },

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

            // Prevent buttons from triggering row click
            $('#example tbody').off('click', 'a');

            $('#example tbody').on('click', 'a', function (e) {
                e.stopPropagation();
            });

            // Row click event
            $('#example tbody').off('click', 'tr');

            $('#example tbody').on('click', 'tr', function () {

                var row = table.row(this);
                var data = row.data();

                if (!data)
                    return;

                var id = data.Store_Issue_Id;

                // Close child row
                if (row.child.isShown()) {

                    row.child.hide();
                    $(this).removeClass('shown');

                    return;
                }

                // Show loading
                row.child('<div class="child-loading">Loading...</div>').show();

                $(this).addClass('shown');

                $.ajax({

                    type: "POST",
                    url: "GoodsIssuanceNoteView.aspx/GetMasterAndDetail",

                    data: JSON.stringify({
                        invoiceId: id
                    }),

                    contentType: "application/json; charset=utf-8",
                    dataType: "json",

                    success: function (resp) {

                        var d = resp.d;

                        // Sum Balance Qty
                        var totalBalanceQty = 0;

                        $.each(d.Detail, function (i, item) {

                            totalBalanceQty += parseFloat(item.blnc_Qty || 0);

                        });

                        // Status
                        var girStatus = totalBalanceQty > 0
                            ? '<span class="badge badge-warning">Partial GIR</span>'
                            : '<span class="badge badge-success">Complete</span>';

                        var html = `

    <div class="child-container">

        <div class="col-sm-4 col-md-4 col-lg-3 child-col-left">

            <h5>Master Information</h5>

            <p><b>Invoice #:</b> ${d.Master.Number}</p>

            <p><b>Date:</b> ${moment(d.Master.Date).format("DD-MMM-YYYY")}</p>

            <p><b>Status:</b> ${d.Master.Status}</p>

            <p><b>GIR Status:</b> ${girStatus}</p>

            <p>
                <b>Total Balance Qty:</b> 
                ${totalBalanceQty}
            </p>

        </div>

        <div class="col-sm-9 col-md-8 col-lg-9">

            <h5>Invoice Details</h5>

            <div class="table-wrapper">

                <table class="table table-bordered child-table" id="detailTable_${id}">

                    <thead>
                        <tr>
                            <th>GIR Detail NO</th>
                            <th>GIR Qty</th>
                            <th>GIN Qty</th>
                            <th>Balance Qty</th>
                        </tr>
                    </thead>

                    <tbody></tbody>

                </table>

            </div>

        </div>

    </div>`;

                        row.child(html).show();

                        $.each(d.Detail, function (i, item) {

                            $("#detailTable_" + id + " tbody").append(`

            <tr>
                <td>${item.MIR_Detail_Id}</td>
                <td>${item.MIRQty}</td>
                <td>${item.Issue_Qty}</td>
                <td>${item.blnc_Qty}</td>
            </tr>

        `);

                        });

                    },

                    error: function (xhr, status, error) {

                        console.log(xhr.responseText);

                        row.child('<div class="text-danger">Failed to load detail.</div>').show();

                    }

                });

            });

        }


     
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
     
    <div class="table-container">
        <table id="example" class="table table-hover table-bordered" style="width: 100%">
            <thead>
                <tr>
                    <th>Store Issue#</th>
                    <th>Store Issue#</th>
                    <th>Date</th>
                    <th>Department</th>
                    <th>WareHouse</th>
                    <th>MIR No</th>
                    <th>Request BY</th>
                    <th>Issue BY</th>
                    <th>Updated By</th>
                    <th>Updated Time</th>
                    <th>Status</th>
                    <th>Approved Date</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody id="tblbody">
            </tbody>
        </table>
    </div>
</asp:Content>
