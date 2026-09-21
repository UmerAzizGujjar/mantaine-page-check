<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ServiceView.aspx.cs" Inherits="PMS.Modules.Inventory.ServiceView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
     <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/custom-modals.css" rel="stylesheet" />
     <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/item-logs.css" rel="stylesheet" />
    <script src="../../wwwroot/THEME_TIBBIT/CustomJs/item-logs.js"></script>
    <script type="text/javascript">

        $(document).ready(function () {
            LoadPage();
        });

        function PrintTest(id) {
            window.open('ReportViewer.aspx?ReportName=TestDefination&ReportTitle= Test Defination&Test_IDs=' + id);
        }

        function Edit(ID) {
            debugger;
            window.location.href = "Service.aspx?ID=" + ID;
        }
        function deleteConfirm(ID) {
            debugger;
            var itemID = ID;
            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(itemID, function (msg) {
                    debugger;
                    location.reload();
                });
            }
        }
        function redirecttonew() {
            window.location.href = "Service.aspx";
        }


        function LoadPage() {
            let savedVisibility = null;
            let savedPageIndex = 0;
            let filterValue = 'all';

            // Load saved filter
            $.ajax({
                type: "POST",
                url: "ServiceView.aspx/GetFilterState",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    if (response.d !== null && response.d !== undefined) {
                        filterValue = response.d;
                        $('#filterStatus').val(filterValue);
                    }
                },
                error: function () {
                    console.error("Failed to load filter state");
                }
            });

            $.ajax({
                type: "POST",
                url: "ServiceView.aspx/GetUserColumnPreferences",
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
            $.ajax({
                type: "POST",
                url: "ServiceView.aspx/GetPageState",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    if (response.d !== null && response.d !== undefined) {
                        savedPageIndex = response.d;
                    }
                },
                error: function () {
                    console.error("Failed to load page state");
                }
            });

            $("#example").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "pageLength": 50,
                "displayStart": savedPageIndex * 50,
                "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
                "buttons": [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () { window.location = 'Service.aspx'; }
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
                    // Get the current filter value
                    var filter = $('#filterStatus').val() || 'all';

                    $.ajax({
                        type: "POST",
                        url: "ServiceView.aspx/ViewList",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length,
                            sortColumn: data.columns[data.order[0].column].name,
                            sortColumnDirection: data.order[0].dir,
                            searchValue: data.search.value,
                            filterStatus: filter  // Pass filter to backend
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
                    { "data": "Item_ID", "visible": false, "width": "0%" },
                    { "data": "ItemCode", "name": "ItemCode", "width": "5%", "orderable": true },
                    { "data": "ItemName", "name": "ItemName", "width": "10%", "orderable": true },
                    { "data": "UOM", "name": "UOM", "width": "5%", "orderable": false },
                    { "data": "WareHouse", "name": "WareHouse", "width": "5%", "orderable": false },
                    { "data": "ItemCategory", "name": "ItemCategory", "width": "5%", "orderable": false },
                    { "data": "AccountCategory", "name": "AccountCategory", "width": "7%", "orderable": false },
                    { "data": "ItemType", "name": "ItemType", "width": "5%", "orderable": false },
                    { "data": "Service_Sub_Category", "name": "Service_Sub_Category", "width": "7%", "orderable": false },
                    { "data": "AccountID", "name": "AccountID", "width": "9%", "orderable": false },
                    { "data": "SaleRate", "name": "SaleRate", "width": "5%" },
                    { "data": "StockTotal", "name": "StockTotal", "width": "5%" },
                    {
                        "data": "Active",
                        "name": "Active",
                        "render": function (data, type, full) {
                            return data ? 'Active' : 'InActive';
                        }, "width": "5%",
                    },
                    { "data": "CreatedBy", "width": "8%", "orderable": false },
                    {
                        "render": function (data, type, full) {
                            var res = '<a class="editListBtn"  href="#" onclick="Edit(' + full.Item_ID + ')" style="border-radius: 4px;margin-right: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>';
                            var logBtn = '<a class="logListBtn" style="border-radius:4px;margin-left:4px;color:white;padding:5px 8px;" href="#" onclick="openItemLogsModal(\'ServiceView.aspx/GetItemLogs\',' + full.Item_ID + ',\'' + full.ItemCode + '\');return false;" title="View Change History"><i class="fa fa-history"></i></a>';
                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;padding: 5px 8px 5px 8px;" href="#" onclick="PrintTest(' + full.Test_ID + ')" id="btnprint"><i class="fa fa-print" ></i></a>';
                            var result;
                            result = res + logBtn + print;
                            return result;
                        }, "width": "9%",
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

                    api.on('page.dt', function () {
                        var page = api.page.info();
                        var pageIndex = page.page;
                        $.ajax({
                            type: "POST",
                            url: "ServiceView.aspx/SavePageState",
                            data: JSON.stringify({ pageIndex: pageIndex }),
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            success: function () {
                                console.log("Page state saved: " + pageIndex);
                            },
                            error: function () {
                                console.error("Failed to save page state");
                            }
                        });
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

            if (savedPageIndex > 0) {
                setTimeout(function () {
                    table.page(savedPageIndex).draw('page');
                }, 100);
            }

            // Filter change event
            $('#filterStatus').on('change', function () {
                var filterValue = $(this).val();

                $.ajax({
                    type: "POST",
                    url: "ServiceView.aspx/SaveFilterState",
                    data: JSON.stringify({ filterValue: filterValue }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function () {
                        console.log("Filter state saved: " + filterValue);
                    },
                    error: function () {
                        console.error("Failed to save filter state");
                    }
                });

                $('#example').DataTable().ajax.reload();
            });
        }
        
        
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-2 col-md-6 col-sm-12">
            <label for="filterStatus">Filter by Account Status:</label>
            <select id="filterStatus">
                <option value="all">All Services</option>
                <option value="mapped">Mapped (Has Account)</option>
                <option value="unmapped">Unmapped (No Account)</option>
            </select>
        </div>
    </div>
    <div class="table-container">
        <table id="example" class="table table-hover table-bordered">
            <thead>
                <tr style="position: sticky; top: 0px; z-index: 10;">
                    <th>Item_ID</th>                                       
                    <th>Item Code</th>
                    <th>Description</th>
                    <th>UOM</th>
                    <th>WareHouse</th>
                    <th>Item Category</th>
                    <th>Account Category</th>
                    <th>Item Type</th>
                    <th>Item Sub Category</th>
                    <th>Account</th>
                    <th>Sale Rate</th>
                    <th>Stock</th>
                    <th>Active</th>
                     <th>Created by</th>   
                    <th>Action</th>
                </tr>
            </thead>
            <tbody id="tblbody"></tbody>
        </table>
    </div>

    <div class="modal fade" id="itemLogModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog custom-modal-dialog custom-modal-dialog-xl" role="document">
            <div class="modal-content custom-modal-content">
                <div class="modal-header custom-modal-header">
                    <div class="custom-modal-title-wrap">
                        <span class="custom-modal-icon"><i class="fa fa-history"></i></span>
                        <h4 class="modal-title custom-modal-title" id="itemLogTitle">Item Change History</h4>
                    </div>
                    <button type="button" class="custom-modal-close" data-dismiss="modal" aria-label="Close"><i class="fa fa-times"></i></button>
                </div>
                <div class="modal-body custom-modal-body item-log-body">
                    <div class="bl-scroll"><div id="itemLogBody"></div></div>
                </div>
                <div class="custom-modal-footer">
                    <span class="custom-modal-count" id="itemLogCount"></span>
                    <button type="button" class="custom-modal-btn-close" data-dismiss="modal"><i class="fa fa-times-circle"></i> Close</button>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
