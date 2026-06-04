<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="User_BranchWiseList.aspx.cs" Inherits="PMS.Modules.Administrator.User_BranchWiseList" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <link href="../../wwwroot/lib/sweetalert/tablestyle.css" rel="stylesheet" />

    <script type="text/javascript">
        $(document).ready(function () {
            LoadPage();
        });

        function LoadPage() {
            $('#tblResult').DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            window.location = 'User_BranchWise.aspx';
                        }
                    },
                    'copy', 'excel', 'pdf',
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
                        url: "User_BranchWiseList.aspx/ViewList",
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
                    { "data": "Branch_wise_User_Id", "name": "Branch_wise_User_Id", visible: false, "width": "0%" },
                    { "data": "UserName", "name": "UserName" },
                    {
                        "data": "Created_Time", "name": "Created_Time",
                        "render": function (data, type, full) {
                            var date = full.Created_Time;
                            return moment(date).isValid() ? moment(date).format('DD-MMM-YYYY') : '';
                        }, "width": "15%"
                    },
                    {
                        "render": function (data, type, full) {
                            var editBtn = '<a href="#" onclick="Edit(\'' + full.Branch_wise_User_Id + '\')" class="editListBtn" style="border-radius: 4px; margin-right: 4px; padding: 5px 8px;"><i class="fa fa-pencil"></i></a>';
                            var deleteBtn = '<a class="delListBtn" style="border-radius: 4px; margin-left: 4px; padding: 5px 8px;" href="#" data-id="' + full.Branch_wise_User_Id + '" onclick="deleteConfirm(this)"><i class="fa fa-trash"></i></a>';
                            return editBtn + deleteBtn;
                        }, "width": "10%"
                    }
                ],
                "initComplete": function (settings, json) {
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
        }

        function OnFail(exc) {
            alert(exc.get_message());
        }

        function Edit(ID) {
            window.location.href = "User_BranchWise.aspx?ID=" + ID;
        }

        function deleteConfirm(anchorTag) {
            var branchWiseUserId = $(anchorTag).data('id');
            if (confirm('Are you sure you want to delete this record?')) {
                PageMethods.DeleteRecord(branchWiseUserId, function (msg) {
                    $(anchorTag).closest('tr').remove();
                }, OnFail);
            }
        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="BranchWiseUserDetails" style="margin-top: 15px;">
        <div class="table-container">
            <div class="table-responsive">
                <table class="table table-hover table-striped table-bordered" id="tblResult">
                    <thead id="ihead">
                        <tr>
                            <th>Branch_wise_User_Id</th>
                            <th>Username</th>
                            <th>Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="ibody">
                    </tbody>
                </table>
            </div>
        </div>
    </div>

</asp:Content>
