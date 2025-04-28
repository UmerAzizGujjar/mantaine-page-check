<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RolesView.aspx.cs" Inherits="PMS.Account.RolesView" Theme="Default_Theme" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            debugger;
            $('#ctl00_lblMessage').hide();
            LoadPage();

        });
        debugger;
        function LoadPage() {
            $('#example').DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "RolesView.aspx/ViewList",
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
                    { "data": "RoleId","name":"RoleId" ,"visible": false, "width": "0%" },
                    { "data": "RoleName", width: "20%" },
                    { "data": "Description", width:"20%" },
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a class="editListBtn" href="#" onclick="editOpen(\'' + full.RoleId + '\')" style="border-radius: 4px; margin-right: 4px; color: white; padding: 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>';
                            var Delete = '<a style="border-radius: 4px;background-color:#ad170c;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" data-id="' + full.RoleId + '" onclick="deleteConfirm(this)"><i class="fa fa-trash"style="color:white !important;"></i></a>';

                            var result;
                            result = res + Delete;
                            return result;
                        }, "width": "5%"
                    }
                ],
                "initComplete": function (settings, json) {
                    var lengthDropdown = document.querySelector('#example_length select');
                    var label = document.querySelector('#example_length label');
                    if (lengthDropdown && label) {
                        label.innerHTML = 'Show entries ';
                        label.appendChild(lengthDropdown);
                    } else {
                        console.log("Length dropdown or label not found");
                    }
                }
            });
        }

        function editOpen(Tem_Id) {
            console.log("Tem_Id:", Tem_Id);
            window.open("Roles.aspx?RoleId=" + Tem_Id);
        }

        function deleteConfirm(anchorTag) {
            var table = $('#example').DataTable();
            var row = $(anchorTag).closest('tr');
            var rowData = table.row(row).data();
            var RoleId = rowData.RoleId;
            if (confirm('Are you sure you want to delete this record?')) {
                PageMethods.CancelRecord(RoleId, function (msg) {
                    table.row(row).remove().draw();
                });
            }
        }


    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
 <div class="col-lg-2 col-md-4 col-sm-6" style="margin-bottom:1%;margin-left:3%">
    <input type="button" class="btn btn-primry" value="Add New" id="btnnew" onclick="window.location = 'Roles.aspx'" />
</div>
        </div>
  <div class="table-container container-fluid">
        <div class="row">
            <div class="col-12">
                <table id="example" class="table table-striped table-bordered display">
                    <thead>
                        <tr>
                            <th>Roll ID</th>
                            <th>Role Name</th>
                            <th>Description</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="tblbody">
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</asp:Content>
