<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PharmacyItemsView.aspx.cs" Inherits="PMS.PharmacyItemsView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/custom-modals.css" rel="stylesheet" />
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/item-logs.css" rel="stylesheet" />
    <script src="../../wwwroot/THEME_TIBBIT/CustomJs/item-logs.js"></script>
    <style>
        #tbloutPatients td:last-child {
            white-space: nowrap;
        }
        #tbloutPatients td:last-child a {
            display: inline-block;
            margin: 0 1px !important;
            padding: 5px 7px !important;
        }
    </style>
    <script type="text/javascript">
        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadWarehouseDropdown();
            LoadPage();


        });

        function LoadWarehouseDropdown() {
            $.ajax({
                type: "POST",
                url: "PharmacyItemsView.aspx/GetWarehouses",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    try {
                        var data = JSON.parse(response.d);
                        var options = '<option value="0">All Warehouses</option>';
                        $.each(data, function (key, value) {
                            options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                        });
                        $('#ddlWarehouse').html(options);
                        $('#ddlWarehouse').select2();
                    } catch (e) {
                        console.error("Error parsing warehouses: ", e);
                    }
                },
                error: function (xhr, status, error) {
                    console.error("Failed to load warehouses: ", error);
                }
            });
        }

        function PrintTest(id) {
            window.open('ReportViewer.aspx?ReportName=TestDefination&ReportTitle= Test Defination&Test_IDs=' + id);
        }
        function LoadPage() {
            let savedVisibility = null;

            $.ajax({
                type: "POST",
                url: "PharmacyItemsView.aspx/GetUserColumnPreferences",
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
            $("#tbloutPatients").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "pageLength": 50,
                "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
                buttons: [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            window.location = '/Modules/Inventory/Product.aspx';
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
                        url: "PharmacyItemsView.aspx/ViewList",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length === -1 ? 1000000 : data.length,
                            sortColumn: data.columns[data.order[0].column].name,
                            sortColumnDirection: data.order[0].dir,
                            searchValue: data.search.value,
                            warehouseId: ($('#ddlWarehouse').val() || '0')
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
                    { "data": "Item_Code", "name": "Item_Code", "width": "5%", "orderable": true },
                    { "data": "Description", "width": "10%", "orderable": false },
                    { "data": "Unit", "width": "5%", "orderable": false },
                    { "data": "Sale_Rate", "width": "7%", "orderable": false },
                    { "data": "Service", "width": "6%", "orderable": false },
                    { "data": "AccountCategory", "width": "8%", "orderable": false },
                    { "data": "PurchaseRate", "width": "7%", "orderable": false },
                    { "data": "SaleRate", "width": "7%", "orderable": false },
                    { "data": "WareHouse", "width": "8%", "orderable": false },
                    { "data": "StockTotal", "width": "6%", "orderable": false },
                    { "data": "CreatedBy", "width": "7%", "orderable": false },
                    { "data": "LocatorAddress", "width": "8%", "orderable": false },

                   
                    {
                        render: function (data, type, full) {
                            var res = '<a href="#" class="editListBtn" onclick="editOpen(' + full.Item_ID + ')" style="border-radius: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>'

                            var Del = '<a class="delListBtn" href="#" style="border-radius: 4px;margin-left: 4px; color: white; padding: 5px 8px 5px 8px;" onclick=deleteConfirm(this)><i class="fa fa-trash" aria-hidden="true"></i></a>';

                            var logBtn = '<a class="logListBtn" style="border-radius:4px;margin-left:4px;color:white;padding:5px 8px;" href="#" onclick="openItemLogsModal(\'PharmacyItemsView.aspx/GetItemLogs\',' + full.Item_ID + ',\'' + full.Item_Code + '\');return false;" title="View Change History"><i class="fa fa-history"></i></a>';
                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintTest(' + full.Item_ID + ')" id="btnprint"><i class="fa fa-print" ></i></a>';
                            var result;
                            result = res + Del + logBtn + print;
                            return result;;
                        }, "width": "18%", "orderable": false
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

                    var lengthContainer = document.querySelector('#tbloutPatients_length');
                    var lengthDropdown = document.querySelector('#tbloutPatients_length select');
                    var label = document.querySelector('#tbloutPatients_length label');

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

            $('#ddlWarehouse').on('change', function () {
                $('#tbloutPatients').DataTable().ajax.reload();
            });
        }

        function editOpen(id) {
            window.location.href = "../../Modules/Inventory/Product.aspx?ID=" + id + "";

        }

        function deleteConfirm(anchorTag) {
            var table = $('#tbloutPatients').DataTable();
            var row = $(anchorTag).closest('tr');
            var rowData = table.row(row).data();
            var ItemID = rowData.Item_ID;

            if (confirm('Are you sure you want to delete this record?')) {
                PageMethods.DeleteRecord(ItemID, function (result) {
                    if (result) {
                        location.reload();
                    } else {
                        alert("This record is in use and cannot be deleted");
                    }
                });
            }
        }



       
    </script>  

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <table>
        <tr>
            
            <td>
                <div id="loadingimage" style="margin-left: -1081px; display: none">
                    <asp:Image ID="image2" ImageUrl="~/images/loading.gif" runat="server" Width="32px" />
                </div>
            </td>
        </tr>
    </table>

    <div class="table-container">

        <div class="row">
            <div class="col-lg-2">
                <label for="ddlWarehouse" style="font-weight: bold;">Ware House</label>
            <select id="ddlWarehouse" ></select>
            </div>
            
        </div>
        <table class="table table-hover table-striped table-bordered" id="tbloutPatients">
            <thead id="ihead">
                <tr>                  
                    <th style="display:none;">Item ID</th>  
                    <th>Item Code</th>
                    <th>Description</th>
                    <th>UOM</th>
                    <th>Sales Rate</th>   
                    <th>Item Type</th>                                          
                    <th>Account Category</th>                                          
                    <th>Purchase Rate</th>                                          
                    <th>Sale Rate</th>                                          
                    <th>Ware House</th>                                          
                    <th>Stock</th>
                    <th>Created by</th>
                    <th>Locator Address</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody id="ibody">
            </tbody>
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