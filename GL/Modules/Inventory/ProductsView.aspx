<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ProductsView.aspx.cs" Inherits="PMS.Inventory.ProductsView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/StandardTheme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">

        $(document).ready(function () {
            LoadPage();
        });

        function Edit(ID) {
            debugger;
            window.location.href = "Product.aspx?ID=" + ID;
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
            window.location.href = "Product.aspx";
        }


        function LoadPage() {
            $("#example").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "ProductsView.aspx/ViewList",
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
                    { "data": "Item_ID", "visible": false, "width": "0%" },
                    { "data": "ItemCode", "name": "ItemCode", "orderable": true },
                    { "data": "ItemName", "name": "ItemName", "orderable": false },
                    { "data": "UOM", "name": "UOM", "orderable": true },
                    { "data": "WareHouse", "name": "WareHouse", "orderable": false },
                    { "data": "ItemCategory", "name": "ItemCategory", "orderable": false },
                { "data": "AccountCategory", "name": "AccountCategory", "orderable": false },
                { "data": "ItemType", "name": "ItemType", "orderable": false },                  
                    { "data": "SaleRate", "name": "SaleRate", "orderable": false },
                    { "data": "StockTotal", "name": "StockTotal", "orderable": false }, 
                    {
                        "data": "Active",
                        "name": "Active",
                        "render": function (data, type, full) {
                            return data ? 'Active' : 'InActive'; 
                        }, "orderable": false
                    },
                                    
                    {
                        "render": function (data, type, full) {
                            return '<a class="editListBtn" href="#" onclick="Edit(' + full.Item_ID + ')" style="border-radius: 4px;margin-right: 4px; color: white; padding: 5px 8px 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>';
                        }, "orderable": false
                    }
                ],
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
        } 
        
        
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-2" style="margin-bottom:1%">
            <input type="button" class="btn btn-primry" onclick="redirecttonew()" value="Add New" />
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
                    <th>Sale Rate</th>
                    <th>Stock</th>
                    <th>Active</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody id="tblbody"></tbody>
        </table>
    </div>


</asp:Content>
