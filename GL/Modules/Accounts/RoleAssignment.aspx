<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RoleAssignment.aspx.cs" Inherits="PMS.Modules.Accounts.RoleAssignment" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">

        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();


        });

        function LoadPage() {
            $('#example').DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'ManageRoles.aspx'; } }, 'copy', 'excel', 'pdf',
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
                        url: "RoleAssignment.aspx/ViewList",
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
                    { "data": "UserId", visible: false },
                    { "data": "UserName", "name": "UserName", "orderable": true },
                    { "data": "Email", "orderable": false },
                    {
                        render: function (data, type, full) {
                            var res = '<a href="#" onclick="editOpen(\'' + full.UserId + '\')" class="editListBtn" style="border-radius: 4px;margin-right: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>'
                                ;

                            var result;
                            result = res;
                            return result;
                        }, "width": "10%", "orderable": false
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

        function editOpen(Tem_Id) {
            console.log("Tem_Id:", Tem_Id);
            window.open("ManageRoles.aspx?UserID=" + Tem_Id);
        }
        function redirecttonew() {
            window.location.href = "ManageRoles.aspx";
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
     <input type="button" class="btn-primry" onclick="redirecttonew()" value="Add New"  />  
    <br />
    <br />
    <div class="table-container">        
                <table id="example" class="table table-hover table-bordered">
                    <thead>
                        <tr>
                            <th>User ID</th>
                            <th>User Name</th>
                            <th>Email</th>
                           <%-- <th>Role Name</th>--%>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="tblbody"></tbody>
                </table>    
                 </div>
</asp:Content>
