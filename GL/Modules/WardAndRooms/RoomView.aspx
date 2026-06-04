<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RoomView.aspx.cs" Inherits="PMS.RoomView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/lib/sweetalert/tablestyle.css" rel="stylesheet" />

    <script type="text/javascript">
        $(document).ready(function () {
            LoadRoomTable();
        });

        function LoadRoomTable() {
            let savedVisibility = null;
            $.ajax({
                type: "POST",
                url: "RoomView.aspx/GetUserColumnPreferences",
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
            $('#tblRoomList').DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            window.location = 'Room.aspx';
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
                        url: "RoomView.aspx/ViewRoomList",
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
                    { "data": "Room_ID", "visible": false },
                    { "data": "Room_No", "name": "Room_No" },
                    { "data": "Name", "name": "Name" },
                    { "data": "Building_Type", "name": "Building_Type" },
                    { "data": "Room_Type", "name": "Room_Type" },
                    { "data": "Floor_No", "name": "Floor_No" },
                    { "data": "Location", "name": "Location" },
                    { "data": "Warden", "name": "Warden" },
                    { "data": "Charges_Per_Day", "name": "Charges_Per_Day" },
                    {
                        "render": function (data, type, full) {
                            var editBtn = '<a class="editListBtn" style="border-radius: 4px; padding: 5px 8px; background-color:#007bff; color:white; text-decoration:none;" ' +
                                'href="Room.aspx?ID=' + full.Room_ID + '" title="Edit"><i class="fa fa-pencil"></i></a>';


                            var delBtn = '<a class="delListBtn" style="border-radius: 4px; margin-left: 4px; padding: 5px 8px; background-color:#dc3545; color:white; text-decoration:none;" ' +
                                'href="#" onclick="deleteRoom(' + full.Room_ID + ')" title="Delete"><i class="fa fa-trash"></i></a>';
                            return editBtn + delBtn;
                        }, "orderable": false
                    }
                ],
                "dom": 'lBfrtip',
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

                    var lengthContainer = document.querySelector('#tblRoomList_length');
                    var lengthDropdown = document.querySelector('#tblRoomList_length select');
                    var label = document.querySelector('#tblRoomList_length label');

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

        function deleteRoom(id) {
            if (confirm('Are you sure you want to delete this room?')) {
                $.ajax({
                    type: "POST",
                    url: "RoomView.aspx/DeleteRoom",
                    data: JSON.stringify({ RoomID: id }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        alert('Room deleted successfully.');
                        $('#tblRoomList').DataTable().ajax.reload();
                    },
                    error: function (xhr, status, error) {
                        alert('Error deleting room.');
                        console.log(xhr.responseText);
                    }
                });
            }
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="table-container">
        <table id="tblRoomList" class="display table table-striped table-bordered" style="width:100%">
            <thead>
                <tr>
                    <th style="display:none;">Room_ID</th>
                    <th>Room No.</th>
                    <th>Name</th>
                    <th>Building Type</th>
                    <th>Room Type</th>
                    <th>Floor No</th>
                    <th>Location</th>
                    <th>Warden</th>
                    <th>Charges/Day</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            </tbody>
        </table>
    </div>

    

</asp:Content>
