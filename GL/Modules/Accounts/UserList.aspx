<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="UserList.aspx.cs" Inherits="PMS.Modules.Accounts.UserList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <link href="../../wwwroot/THEME_TIBBIT/css/tablestyle.css" rel="stylesheet" />

    <script type="text/javascript">
        $(document).ready(function () {
            LoadTable();
        });
        function editOpen(id) {
            window.open("RegisterUser.aspx?UserID=" + id + "");
        }
        function Resetpass(UserID) {
            var data = JSON.stringify({ UserID: UserID });
            Swal.fire({
                icon: 'warning',
                title: 'Are you sure?',
                text: 'This action will Reset the Password!',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#3085d6',
                confirmButtonText: 'Yes, Reset it!',
                cancelButtonText: 'Cancel',
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            }).then((result) => {
                if (result.isConfirmed) {
                    // Only run this if user clicked "Yes, delete it!"
                    $.ajax({
                        type: "POST",
                        url: "UserList.aspx/Reset_User_Password",
                        data: data,
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (data) {
                            var response = data.d;
                            if (response == "Password Reset Successfully!") {
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Success!',
                                    text: response,
                                    showConfirmButton: false,
                                    timer: 2500,
                                    customClass: {
                                        popup: 'swal-big-popup',
                                        title: 'swal-big-title',
                                        htmlContainer: 'swal-big-text'
                                    }
                                });
                            }
                            else {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Error!',
                                    text: response,
                                    showConfirmButton: false,
                                    timer: 2000,
                                    customClass: {
                                        popup: 'swal-big-popup',
                                        title: 'swal-big-title',
                                        htmlContainer: 'swal-big-text'
                                    }
                                });
                            }
                        },
                        error: function (xhr, status, error) {
                            console.log("XHR:", xhr);
                            console.log("Status:", status);
                            console.log("Error:", error);

                            if (xhr.responseText) {
                                alert("Server Error: " + xhr.responseText);
                            } else {
                                alert("AJAX Error: " + error);
                            }
                        }
                    });
                }
            });

        }
        function deleteUser(id) {
            Swal.fire({
                icon: 'warning',
                title: 'Are you sure?',
                text: 'This action will delete the user permanently!',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#3085d6',
                confirmButtonText: 'Yes, delete it!',
                cancelButtonText: 'Cancel',
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            }).then((result) => {
                if (result.isConfirmed) {
                    blockUser(id);
                }
            });
        }
        function blockUser(UserID) {
            var data = JSON.stringify({ UserID: UserID });
            $.ajax({
                type: "POST",
                url: "UserList.aspx/Delete_User",
                data: data,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var response = data.d;

                    Swal.fire({
                        icon: 'success',
                        title: 'Success!',
                        text: response,
                        showConfirmButton: false,
                        timer: 2500,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                },
                error: function (xhr, status, error) {
                    console.log("XHR:", xhr);
                    console.log("Status:", status);
                    console.log("Error:", error);

                    if (xhr.responseText) {
                        alert("Server Error: " + xhr.responseText);
                    } else {
                        alert("AJAX Error: " + error);
                    }
                }
            });
        }
        function LoadTable() {
            let savedVisibility = null;

            $.ajax({
                type: "POST",
                url: "UserList.aspx/GetUserColumnPreferences",
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
            $("#tblResult").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'RegisterUser.aspx'; } }, 'copy', 'excel', 'pdf',
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
                        url: "UserList.aspx/ViewList",
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
                    { "data": "UserId", "visible": false, "width": "0%", "orderable": false },
                    { "data": "UserName", "name": "mr_no_sequence", "width": "5%", "orderable": true },
                    { "data": "Email", "name": "Opd_No", "width": "4%", "orderable": false },
                    { "data": "mobileno", "width": "7%", "orderable": false },
                    {
                        "data": "LastActivityDate", "name": "LastActivityDate",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.LastActivityDate;
                            date = moment(date).format('DD-MMM-YYYY hh:mm A'); // added time
                            return date;
                        },
                        "width": "7%"
                    },
                    { "data": "BlockUser", "width": "1%", "orderable": true },
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a href="#" onclick="editOpen(\'' + full.UserId + '\')" class="editListBtn" style="border-radius: 4px;padding: 5px 8px;"><i  class="fa fa-pencil"></i></a>';

                            var Del = '<a class="delListBtn" style="border-radius: 4px;margin-left: 4px;padding: 5px 8px 5px 8px;" href="#" data-id="' + full.UserId + '" onclick="deleteUser(\'' + full.UserId + '\')"><i class="fa fa-trash" ></i></a>';

                            var reset = '<a class="resetbtn" style="border-radius: 4px;margin-left: 4px;padding: 5px 8px 5px 8px;" href="#" data-id="' + full.UserId + '" onclick="Resetpass(\'' + full.UserId + '\')"><i class="fa fa-undo"></i></a>';
                            var result;
                            result = res + Del + reset;
                            return result;
                        }, "width": "5%", "orderable": false
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
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="UserDetails" style="margin-top: 15px;">
        <div class="row">
            <div class="table-container col-lg-12 col-md-12 col-sm-10">
                <table class="table table-hover table-striped table-bordered" id="tblResult" style="overflow: scroll; height: auto;">
                    <thead id="ihead">
                        <tr>
                            <th style="display: none;">UserID</th>
                            <th>UserName</th>
                            <th>Email</th>
                            <th>Mobile</th>
                            <th>LastActive</th>
                            <th>IsBlocked</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="ibody">
                        <!-- Data will be populated by LoadTable() -->
                    </tbody>
                </table>
            </div>
        </div>
    </div>

</asp:Content>
