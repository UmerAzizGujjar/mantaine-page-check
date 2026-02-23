<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="UserControlList.aspx.cs" Inherits="PMS.Account.UserControlList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            debugger;
            $('#ctl00_lblMessage').hide();
            LoadPage();

        });
        debugger;
        function LoadPage() {
            let savedVisibility = null;

            $.ajax({
                type: "POST",
                url: "UserControlList.aspx/GetUserColumnPreferences",
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
            $('#example').DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'UserControl.aspx'; } }, 'copy', 'excel', 'pdf',
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
                        url: "UserControlList.aspx/ViewList",
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
                    { "data": "User_Branch_Master_Id", "visible": false, "width": "0%" },
                    /*  { "data": null, "orderable": false, "width": "10%" },*/
                    { "data": "user_name", width: "20%" },
                    {
                        "data": "Created_Time",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.Created_Time;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "10%"
                    },
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a class="editListBtn" href="#" onclick="editOpen(\'' + full.User_Branch_Master_Id + '\')" style="border-radius: 4px; margin-right: 4px;padding: 5px 8px;"><i class="fa fa-pencil"></i></a>';


                            var result;
                            result = res;
                            return result;
                        }, "width": "10%"
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
                    }
                }
                //"createdRow": function (row, data, dataIndex) {
                //    $(row).find('td:eq(0)').html(dataIndex + 1);
                //}
            });
        }

        function OnFail(exc) {
            alert(exc.get_message());
        }
        function editOpen(ID) {
            window.location.href = "UserControl.aspx?ID=" + ID;

        }
        function deleteConfirm(User_Branch_Master_Id) {
            debugger;
            var ID = User_Branch_Master_Id;
            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(ID, function (msg) {
                    debugger
                    window.location.href = 'UserControlList.aspx';
                }, OnFail);
            }
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">


    <div class="table-container">
        <table id="example" class="table table-hover table-bordered">
            <thead>
                <tr>
                    <th>Sr #</th>
                    <th>Username</th>
                    <th>Date</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody id="tblbody"></tbody>
        </table>
    </div>
</asp:Content>
