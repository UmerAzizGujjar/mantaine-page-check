<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PharmacyItemsView.aspx.cs" Inherits="PMS.PharmacyItemsView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/IITH_Theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();


        });


        function LoadPage() {
            $("#tbloutPatients").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "PharmacyItemsView.aspx/ViewList",
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
                    { "data": "Item_Code", "name": "Item_Code", "width": "12%", "orderable": true },
                    { "data": "Description", "width": "20%", "orderable": false },
                    { "data": "Unit", "width": "15%", "orderable": false },
                    { "data": "Sale_Rate", "width": "15%", "orderable": false },
                    { "data": "Service", "width": "15%", "orderable": false },

                   
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a href="#" class="editListBtn" onclick="editOpen(' + full.Item_ID + ')" style="border-radius: 4px; color: white; padding: 5px 8px 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>'
                            var Del = '<a href="#" style="border-radius: 4px; background-color: #ad170c;margin-left: 4px; color: white; padding: 5px 8px 5px 8px;" onclick=deleteConfirm(this)><i class="fa fa-trash" aria-hidden="true"></i></a>';

                            var result;
                            result = res + Del;
                            return result;
                        }, "width": "10%", "orderable": false
                    }

                ],
                "initComplete": function (settings, json) {
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
                    } else {
                        console.log("Length dropdown, label, or container not found");
                    }
                }
            });
        }

        function editOpen(id) {
            debugger;
            window.location.href = "../../Modules/Inventory/Items.aspx?ID=" + id + "";

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
                <asp:Button Text="Add New" CssClass="btn btn-primry" ID="Button1" runat="server" PostBackUrl="../../Modules/Inventory/Items.aspx" CausesValidation="false" Style="margin-bottom:15% !important" />
            </td>
            <td>
                <div id="loadingimage" style="margin-left: -1081px; display: none">
                    <asp:Image ID="image2" ImageUrl="~/images/loading.gif" runat="server" Width="32px" />
                </div>
            </td>
        </tr>
    </table>

    <div class="table-container">
        <table class="table table-hover table-striped table-bordered" id="tbloutPatients">
            <thead id="ihead">
                <tr>                  
                    <th style="display:none;">Item ID</th>  
                    <th>Item Code</th>
                    <th>Description</th>
                    <th>UOM</th>
                    <th>Sales Rate</th>   
                    <th>Item Type</th>                                          
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody id="ibody">
            </tbody>
        </table>
         </div>

</asp:Content>