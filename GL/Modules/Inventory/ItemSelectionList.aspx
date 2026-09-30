<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ItemSelectionList.aspx.cs" Inherits="PMS.Modules.Inventory.ItemSelectionList" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
 <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <style type="text/css">
    .detail-container {
        padding: 15px;
    }

    .clickable-row {
        cursor: pointer;
    }

        .clickable-row:hover {
            background-color: #f0f8ff;
        }
    
    .details-table {
        width: 100%;
        border-collapse: collapse;
        font-family: sans-serif;
    }
    
    .details-table th {
        background-color: #f4f4f4;
        padding: 10px;
        border-bottom: 2px solid #ddd;
        text-align: left;
    }
    
    .details-table td {
        padding: 10px;
        border-bottom: 1px solid #eee;
    }
    
    .category-header {
        background-color: #e9ecef;
        font-weight: bold;
    }
    
    .category-header td {
        padding: 8px 10px;
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
                url: "ItemSelectionList.aspx/GetUserColumnPreferences",
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

            const table = $("#tblResult").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            window.location = 'DiscountAssigned.aspx';
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
                "columnDefs": savedVisibility ? [] : undefined,
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "ItemSelectionList.aspx/ViewList",
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
                    { "data": null, "width": "3%", "orderable": false, "render": (data, type, full, meta) => meta.settings._iDisplayStart + meta.row + 1 },
                    { "data": "Selection_ID", "visible": false, "width": "0%", "orderable": false },
                    {
                        "data": "Selection_Date", "name": "Selection_Date",
                        "render": (data, type, full) => moment(full.Selection_Date).format('DD-MMM-YYYY'),
                        "width": "8%"
                    },
                    { "data": "GRN_Num", "name": "GRN_Num", "width": "10%", "orderable": true },
                    { "data": "VendorName", "name": "VendorName", "width": "10%", "orderable": false },
                    { "data": "WarehouseName", "name": "WarehouseName", "width": "10%", "orderable": false },
                    
                    { "data": "Remarks", "name": "Remarks", "width": "10%", "orderable": false },
                    { "data": "Created_By", "name": "Created_By", "width": "8%", "orderable": false },
                    {
                        "render": (data, type, full) => {
                            let res = `<a href="#" onclick="editOpen(${full.Selection_ID})" class="editListBtn" style="border-radius: 4px;padding: 5px 8px;"><i class="fa fa-pencil"></i></a>`;
                            
                            let print = `<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px;" href="#" onclick="Print(${full.Selection_ID})"><i class="fa fa-print"></i></a>`;
                            return res  + print;
                        },
                        "width": "10%",
                        "orderable": false
                    }
                ],
                "createdRow": function (row, data, dataIndex) {
                    $(row).addClass('clickable-row');
                    $(row).attr('data-selection-id', data.Selection_ID);
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
                }
            });

            $('#tblResult tbody').on('click', 'tr.clickable-row', function (e) {
                if ($(e.target).closest('a,button,input').length > 0) {
                    return;
                }

                var tr = $(this);
                var row = table.row(tr);
                var selectionId = tr.attr('data-selection-id');

                if (row.child.isShown()) {
                    row.child.hide();
                    tr.removeClass('shown');
                } else {
                    table.rows().every(function () {
                        if (this.child.isShown()) {
                            this.child.hide();
                            $(this.node()).removeClass('shown');
                        }
                    });

                    row.child('<div style="padding:20px;text-align:center;">Loading...</div>').show();
                    tr.addClass('shown');
                    LoadSelectionDetails(selectionId, row);
                }
            });

            
        }

        function LoadSelectionDetails(selectionId, row) {
            $.ajax({
                type: "POST",
                url: "ItemSelectionList.aspx/GetSelectionDetails",
                data: JSON.stringify({ selectionId: selectionId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d) {
                        var details = JSON.parse(response.d);
                        var html = BuildDetailsHTML(details);
                        row.child(html).show();
                    }
                },
                error: function (xhr, status, error) {
                    row.child('<div style="padding:20px;color:red;">Error loading details</div>').show();
                    console.log(xhr.responseText);
                }
            });
        }

        function BuildDetailsHTML(details) {
            var html = '<div class="detail-container">';
            html += '<table class="details-table">';
            html += '<thead>';
            html += '<tr>';
            html += '<th>Item Code</th>';
            html += '<th>Item Name</th>';
            html += '<th>GRN Qty</th>';
            html += '<th>Selected Qty</th>';
            html += '<th>Batch Num</th>';
            html += '<th>Unit</th>';
            html += '<th>Rate</th>';
            html += '</tr>';
            html += '</thead>';
            html += '<tbody>';

            details.forEach(function (item) {
                html += '<tr>';
                html += '<td>' + (item.ItemCode || 'N/A') + '</td>';
                html += '<td>' + (item.ItemName || 'N/A') + '</td>';
                html += '<td>' + parseFloat(item.GRN_Qty || 0).toFixed(4) + '</td>';
                html += '<td>' + parseFloat(item.Selected_Qty || 0).toFixed(4) + '</td>';
                html += '<td>' + (item.BatchNum || 'N/A') + '</td>';
                html += '<td>' + (item.Unit || 'N/A') + '</td>';
                html += '<td>' + parseFloat(item.Rate || 0).toFixed(2) + '</td>';
                html += '</tr>';
            });

            html += '</tbody>';
            html += '</table>';
            html += '</div>';
            return html;
        }

        function editOpen(id) {
            window.location.href = "ItemSelection.aspx?Selection_ID=" + id;
        }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        <div class="row">
    <div class="table-container col-lg-12 col-md-12 col-sm-10">
        <table class="table table-hover table-striped table-bordered" id="tblResult" style="overflow: scroll; height: auto;">
      <thead id="ihead">
        <tr>
            <th>Sr#</th>                
            <th style="display: none;">Selection ID</th>    
            <th>Selection Date</th>
            <th>GRN Num</th>
            <th>Vendor Name</th>
            <th>Ware House</th>
            <th>Remarks</th>
            <th>Created By</th>       
            <th style="width: 20% !important;">Actions</th>
        </tr>
    </thead>
            <tbody id="ibody">
            </tbody>
        </table>
    </div>
</div>
</asp:Content>

