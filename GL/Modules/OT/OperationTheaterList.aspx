<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OperationTheaterList.aspx.cs" Inherits="PMS.OperationTheaterList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/css/tablestyle.css" rel="stylesheet" />

    <script type="text/javascript">
        $(document).ready(function () {
            debugger;
            $('#ctl00_lblMessage').hide();
            LoadPage();


        });

        function editOpen(id) {
            debugger;
            window.open("OperationBooking.aspx?ID=" + id + "");
        }

        function Operationprint(Operation_Booking_ID) {
            var url = '../../ReportViewer.aspx?ReportName=OperationTheater&ReportTitle=Operation Booking&Operation_Booking_ID=' + Operation_Booking_ID;
            window.open(url, '_blank');
        }
        function delete_id(id) {
            Swal.fire({
                icon: 'warning',
                title: 'Are you sure?',
                text: 'This action will delete the Package!',
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
                $.ajax({
                    type: "POST",
                    url: "Department_Packages_List.aspx/DeleteID",
                    data: JSON.stringify({ OT_ID: id }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        if (response.d == "Package cancelled successfully.") {
                            Swal.fire({
                                icon: 'success',
                                title: 'Success!',
                                text: 'Your Package has been Deleted successfully.',
                                showConfirmButton: false,
                                timer: 2500,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            }); LoadPage();
                        } else {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'Error Deleting Package',
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
                        console.log(xhr.responseText);
                    }
                });

            });
        }




        function LoadPage() {
            let savedVisibility = null;

            $.ajax({
                type: "POST",
                url: "OperationTheaterList.aspx/GetUserColumnPreferences",
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
            $("#patientOT").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'OperationBooking.aspx'; } }, 'copy', 'excel', 'pdf',
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
                        url: "OperationTheaterList.aspx/ViewList",
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
                    { "data": "Operation_Booking_ID", "visible": false, "width": "0%" },
                    { "data": "mr_no_sequence", "name": "mr_no_sequence", "width": "5%", "orderable": true },
                    { "data": "Full_Name", "width": "10%", "orderable": false },
                    { "data": "DoctorName", "width": "10%", "orderable": false },
                    { "data": "ProcedureName", "width": "15%", "orderable": false },
                    { "data": "Mobile", "width": "10%", "orderable": false },
                    { "data": "Department", "width": "10%", "orderable": false },
                    {
                        "data": "Created_Time", "name": "Created_Time",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.Created_Time;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "10%", "orderable": true
                    },
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a href="#" class="editListBtn" onclick="editOpen(' + full.Operation_Booking_ID + ')" style="border-radius: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>'
                            var del = '<a href="#" onclick="delete_id(' + full.Operation_Booking_ID + ')" class="editListBtn" style="border-radius: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-trash"></i></a>'

                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="Operationprint(' + full.Operation_Booking_ID + ')" id="btnprint"><i class="fa fa-print" ></i></a>';
                            var result;
                            result = res + print;
                            return result;

                        }, "width": "5%"
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

                    var lengthContainer = document.querySelector('#patientOT_length');
                    var lengthDropdown = document.querySelector('#patientOT_length select');
                    var label = document.querySelector('#patientOT_length label');

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
   

    <div id="divOT" class="table-container">
        <table class="table table-hover table-striped table-bordered" id="patientOT">
            <thead>
                <tr>
                    <th style="display: none;">Mr ID</th>
                    <th>Mr No</th>
                    <th>Patient Name</th>
                    <th>Doctor</th>
                    <th>Procedure Name</th>
                    <th>Mobile</th>
                   <th>Patient Type</th>
                    <th>Operation Date</th>
                    <th>Action</th>
                </tr>
            </thead>
        </table>
    </div>


</asp:Content>
