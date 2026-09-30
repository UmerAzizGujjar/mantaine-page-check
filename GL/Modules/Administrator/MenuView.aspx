<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MenuView.aspx.cs" Inherits="PMS.MenuView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            LoadPage();

        });
        function PrintTest(id) {
            window.open('ReportViewer.aspx?ReportName=TestDefination&ReportTitle= Test Defination&Test_IDs=' + id);
        }
        function LoadPage() {
            $('#tbl').DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'Menu.aspx'; } }, 'copy', 'excel', 'pdf',
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
                            var res = '<a href="#" class="editListBtn" onclick="Edit(\'' + full.Menu_ID + '\')" style="border-radius: 4px; margin-right: 4px;padding: 5px 8px;"><i class="fa fa-pencil"></i></a>';

                            var Delete = '<a class="delListBtn" style="border-radius: 4px;margin-left: 4px;padding: 5px 8px 5px 8px;" href="#"  onclick="deleteConfirm(' + full.Menu_ID + ')"><i class="fa fa-trash"></i></a>';

                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;padding: 5px 8px 5px 8px;" href="#" onclick="PrintTest(' + full.Test_ID + ')" id="btnprint"><i class="fa fa-print"></i></a>';
                            var result;
                            result = res + Delete + print;
                            return result;;
                        }, "width": "6%", "orderable": false
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
            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(ID, function (msg) {
                    location.reload();
                });
            }
        }

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
