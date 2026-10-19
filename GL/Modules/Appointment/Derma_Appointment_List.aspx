<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Derma_Appointment_List.aspx.cs" Inherits="PMS.Modules.Appointment.Derma_Appointment_List" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">

        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();
            loadDoctors();
            $("#doctorFilter").select2();

            $('#doctorFilter').on('change', function () {
                $('#tblResult').DataTable().draw();
            });

            $('#statusFilter').on('change', function () { 
                $('#tblResult').DataTable().draw();
            });
        });


        function LoadPage() {
            let savedVisibility = null;
            $.ajax({
                type: "POST",
                url: "Derma_Appointment_List.aspx/GetUserColumnPreferences",
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
                "buttons": [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            window.location = 'Derma_Appointment.aspx';
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
                    var doctorId = $('#doctorFilter').val();
                    var statusVal = $('#statusFilter').val();
                    $.ajax({
                        type: "POST",
                        url: "Derma_Appointment_List.aspx/ViewList",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length,
                            sortColumn: data.columns[data.order[0].column].name,
                            sortColumnDirection: data.order[0].dir,
                            searchValue: data.search.value,
                            doctorFilter: doctorId,
                            statusFilter: statusVal
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
                    { "data": "Derma_Appointment_Id", "visible": false, "width": "0%", "orderable": false },
                    { "data": "Appointment_No", "name": "Appointment_No", "width": "8%", "orderable": true },
                    { "data": "Full_Name", "name": "Full_Name", "width": "10%", "orderable": false },
                    { "data": "Phone", "width": "10%", "orderable": false },
                    { "data": "Age", "width": "10%", "orderable": false },
                    { "data": "Doctor_Id", "width": "10%", "orderable": false },
                    { "data": "Machine_Name", "width": "10%", "orderable": false },
                    {
                        "data": "Appointment_Date", "name": "Appointment_Date",
                        "render": function (data, type, full) {
                            var date = full.Appointment_Date;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "9%"
                    },                 
                    { "data": "Status", "width": "10%", "orderable": false },
                    { "data": "CreatedBY", "width": "10%", "orderable": false },
                    {
                        "data": "Creation_Date", "name": "Creation_Date",
                        "render": function (data, type, full) {
                            var date = full.Creation_Date;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "9%"
                    },               
                    {
                        render: function (data, type, full) {
                            var res = '<a href="#" onclick="editOpen(' + full.Derma_Appointment_Id + ')" class="editListBtn" style="border-radius: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>'

                            var result;
                            result = res;
                            return result;


                        }, "width": "10%", "orderable": false
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

        function loadDoctors() {
            $.ajax({
                type: "POST",
                url: "Derma_Appointment_List.aspx/GetDoctors",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var doctors = response.d;
                    var select = $('#doctorFilter');
                    select.empty().append('<option value="">All Doctors</option>');
                    $.each(doctors, function (i, doctor) {
                        select.append('<option value="' + doctor.Emp_ID + '">' + doctor.Emp_Name + '</option>');
                    });
                },
                error: function (xhr, status, error) {
                    console.log("Error loading doctors:", xhr.responseText);
                }
            });
        }

        function editOpen(id) {
            window.open("Derma_Appointment.aspx?APPID=" + id + "");
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-2 col-md-6 col-sm-12">
            <label for="doctorFilter">Filter by Doctor:</label>
            <select id="doctorFilter" class="form-control">
                <option value="">All Doctors</option>
            </select>
        </div>
        <div class="col-lg-2 col-md-6 col-sm-12">
            <label for="statusFilter">Filter by Status:</label>
            <select id="statusFilter" class="form-control">
                <option value="">All Statuses</option>
                <option value="Visited">Visited</option>
                <option value="Booked">Booked</option>
            </select>
            </div>
    </div>
     <div class="row">
     <div class="table-container col-lg-12 col-md-12 col-sm-10">
         <table class="table table-hover table-striped table-bordered" id="tblResult" style="overflow: scroll; height: auto;">
             <thead id="ihead">
                 <tr>
                     <th style="display: none;">Derma_Appointment_Id</th>
                     <th>Appointment_No</th>
                     <th>Full Name</th>
                     <th>Phone</th>
                     <th>Age</th>
                     <th>Doctor</th>
                     <th>Machine Name</th>
                     <th>App Date</th>
                     <th>Status</th>
                     <th>User Name</th>
                     <th>Creation Date</th>
                     <th>Actions</th>
                 </tr>
             </thead>
             <tbody id="ibody">
             </tbody>
         </table>
     </div>
 </div>
</asp:Content>
