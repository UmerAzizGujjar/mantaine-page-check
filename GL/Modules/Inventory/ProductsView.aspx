<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ProductsView.aspx.cs" Inherits="PMS.Inventory.ProductsView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">

        $(document).ready(function () {
            LoadPage();
        });
        function PrintTest(id) {
            window.open('ReportViewer.aspx?ReportName=TestDefination&ReportTitle= Test Defination&Test_IDs=' + id);
        }
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
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'Product.aspx'; } }, 'copy', 'excel', 'pdf',
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
                    { "data": "ItemCode", "name": "ItemCode", "orderable": true,"width": "5%" },
                    { "data": "ItemName", "name": "ItemName", "orderable": false, "width": "18%" },
                    { "data": "UOM", "name": "UOM", "orderable": true, "width": "5%" },
                    { "data": "WareHouse", "name": "WareHouse", "orderable": false, "width": "5%" },
                    { "data": "ItemCategory", "name": "ItemCategory", "orderable": false, "width": "7%" },
                    { "data": "AccountCategory", "name": "AccountCategory", "orderable": false, "width": "12%" },
                    { "data": "ItemType", "name": "ItemType", "orderable": false, "width": "5%" },                  
                    { "data": "SaleRate", "name": "SaleRate", "orderable": false, "width": "5%" },
                    { "data": "StockTotal", "name": "StockTotal", "orderable": false, "width": "5%" }, 
                    {
                        "data": "Active",
                        "name": "Active",
                        "render": function (data, type, full) {
                            return data ? 'Active' : 'InActive'; 
                        }, "orderable": false, "width": "6%"
                    },
                                    
                    {
                        "render": function (data, type, full) {
                            var res = '<a class="editListBtn" href="#" onclick="Edit(' + full.Item_ID + ')" style="border-radius: 4px;margin-right: 4px; padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>';

                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;padding: 5px 8px 5px 8px;" href="#" onclick="PrintTest(' + full.Test_ID + ')" id="btnprint"><i class="fa fa-print" ></i></a>';
                            var result;
                            result = res  + print;
                            return result;
                        }, "orderable": false, "width": "7%"
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
