<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MenuView.aspx.cs" Inherits="PMS.MenuView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            LoadPage();

        });

        function LoadPage() {
            $('#tbl').DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'Menu.aspx'; } }, 'copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "MenuView.aspx/ViewList",
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
                    { "data": "Menu_ID", "name": "Menu_ID", "visible": false, "width": "0%" },
                    { "data": "Menu_Name", "name": "Menu_Name", "width": "6%", "orderable": true },
                    { "data": "Menu_Description", "orderable": false, "width": "10%" },
                    { "data": "URL", width: "10%", "orderable": false, "width": "15%" },
                    { "data": "Parent_Menu", "orderable": false, "width": "5%" },
                    { "data": "Order_By", "orderable": false, "width": "3%" },
                    { "data": "IsActive", "orderable": false, "width": "3%" },
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a href="#" class="editListBtn" onclick="Edit(\'' + full.Menu_ID + '\')" style="border-radius: 4px; margin-right: 4px; color: white; padding: 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>';
                            var Delete = '<a style="border-radius: 4px;background-color:#ad170c;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#"  onclick="deleteConfirm(' + full.Menu_ID + ')"><i class="fa fa-trash"style="color:white !important;"></i></a>';

                            var result;
                            result = res + Delete;
                            return result;
                        }, "width": "3%", "orderable": false
                    }
                ],
                "initComplete": function (settings, json) {
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
                    } else {
                        console.log("Length dropdown, label, or container not found");
                    }
                }
            });
        }

        function deleteConfirm(ID) {
            debugger;
            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(ID, function (msg) {
                    location.reload();
                });
            }
        }

        debugger;
        function Edit(id) {
            window.open("Menu.aspx?ID=" + id + "");
        }

    </script>


</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
      

    <div class="row">
            <div class="table-container">
            <table id="tbl"  class="table table-bordered table-hover table-striped">
                <thead id="ihead">
                    <tr>
                        <th>MenuID</th>
                        <th>Menu Name</th>
                        <th>Description</th>
                        <th>URl</th>
                        <th>Parent Menu</th>
                        <th>Order By</th>
                        <th>Active</th>
                        <th>View</th>
                    </tr>
                </thead>
                <tbody id="tbody">
                </tbody>
            </table>
        </div>
    </div>
    

   

</asp:Content>
