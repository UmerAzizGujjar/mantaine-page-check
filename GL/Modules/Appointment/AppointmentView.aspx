<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AppointmentView.aspx.cs" Inherits="PMS.AppointmentView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            LoadPage();
            $("#doctorFilter").select2();
            $("#deptFilter").select2();

            $("#dateFilter").datepicker({
                dateFormat: 'yy-mm-dd',
                onSelect: function () {
                    $("#example").DataTable().ajax.reload();
                }
            });
            var today = new Date();
            $("#dateFilter").datepicker({
                dateFormat: 'yy-mm-dd',
                onSelect: function () {
                    $("#example").DataTable().ajax.reload();
                }
            });

        });

        function appointmentPatient_Print(Appointment_ID) {
            debugger;

             var locationInfo = window.location;
            var url = "/ReportViewer.aspx?ReportName=Appointment_Patient_Print&Title=Appointment Patient Print &appointmentId=" + Appointment_ID;
             if (!locationInfo.origin.includes('localhost')) {
                 var urlInfo = window.location.href.split('/');
                 var ip = urlInfo[2];
                 var foldername = urlInfo[3];
                 url = 'http://' + ip + '/' + foldername + "/ReportViewer.aspx?ReportName=Appointment_Patient_Print&Title=Appointment Patient Print &appointmentId=" + Appointment_ID;
             }
             window.open(url, '_blank');
         }

        function LoadPage() {
            let savedVisibility = null;
            $.ajax({
                type: "POST",
                url: "AppointmentView.aspx/GetUserColumnPreferences",
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
                }
            });
            $.ajax({
                type: "POST",
                url: "AppointmentView.aspx/GetDoctors",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var doctorDropdown = $("#doctorFilter");
                    doctorDropdown.empty().append($('<option>').val('').text('All Doctors'));
                    $.each(response.d, function (i, d) {
                        doctorDropdown.append($('<option>').val(d.Emp_ID).text(d.Emp_Name));
                    });
                }
            });
            $.ajax({
                type: "POST",
                url: "AppointmentView.aspx/GetDepartments",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var deptDropdown = $("#deptFilter");
                    deptDropdown.empty().append($('<option>').val('').text('All Departments'));
                    $.each(response.d, function (i, d) {
                        deptDropdown.append($('<option>').val(d.DeptId).text(d.DeptName));
                    });
                }
            });
            if ($.fn.DataTable.isDataTable('#example')) {
                $("#example").DataTable().destroy();
            }
            var table = $("#example").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            window.location = 'Appointment.aspx';
                        }
                    },
                    'copy',
                    'excel',
                    'pdf',
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
                    var selectedDoctor = $("#doctorFilter").val() || "";
                    var selectedDept = $("#deptFilter").val() || "";
                    var selectedStatus = $("#statusFilter").val() || "";
                    var selectedDate = $("#dateFilter").val() || "";

                    $.ajax({
                        type: "POST",
                        url: "AppointmentView.aspx/ViewList",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length,
                            sortColumn: data.columns[data.order[0].column].name,
                            sortColumnDirection: data.order[0].dir,
                            searchValue: data.search.value,
                            doctorId: selectedDoctor,
                            deptId: selectedDept,
                            status: selectedStatus,
                            appDate: selectedDate
                        }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            console.log("Response:", response);
                            callback({
                                draw: response.d.draw,
                                recordsTotal: response.d.recordsTotal,
                                recordsFiltered: response.d.recordsFiltered,
                                data: response.d.data
                            });
                        },
                        error: function (xhr, status, error) {
                            console.error("AJAX Error:", error);
                            console.error("Response:", xhr.responseText);
                        }
                    });
                },
                "columns": [
                    { "data": "Appointment_ID", "visible": false, "width": "0%" },
                    { "data": "Appointment_No", "name": "Appointment_No", "width": "6%" },
                    { "data": "Patient_Name", "name": "Patient_Name", "width": "12%" },
                    { "data": "Age", "name": "Age", "width": "6%" },
                    { "data": "Phone", "name": "Phone", "width": "10%" },
                    { "data": "Appointed_Doctor", "name": "Appointed_Doctor", "width": "10%" },
                    { "data": "Department", "name": "Department", "width": "10%" },
                    {
                        "data": "App_Date",
                        "name": "App_Date",
                        "width": "10%",
                        "render": function (data, type, full) {
                            return moment(full.App_Date).format('D-MMM-YYYY');
                        }
                    },
                    {
                        "data": "Start_Time",
                        "name": "Start_Time",
                        "width": "8%",
                        "render": function (data, type, full) {
                            return moment(full.Start_Time).format('h:mm a');
                        }
                    },
                    {
                        "data": "Created_Time",
                        "name": "Created_Time",
                        "width": "8%",
                        "render": function (data, type, full) {
                            return moment(full.Created_Time).format('D-MMM-YYYY');
                        }
                    },
                    { "data": "Username", "name": "Username", "width": "8%" },
                    { "data": "Status", "name": "Status", "width": "7%" },
                    {
                        "data": null,
                        "width": "10%",
                        "orderable": false,
                        "render": function (data, type, full) {
                            var res = '<a href="#" class="editListBtn" onclick="editOpen(' + full.Appointment_ID + ')" style="border-radius: 4px;margin-right: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>';
                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="appointmentPatient_Print(' + full.Appointment_ID + ')"><i class="fa fa-print"></i></a>';
                            return res + print;
                        }
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
                            function () { },
                            function (error) { }
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
            });
            $("#doctorFilter,#deptFilter,#statusFilter,#dateFilter").on("change", function () {
                table.ajax.reload();
            });
        }
            
       



        function editOpen(id) {

            window.open("Appointment.aspx?APPID=" + id + "");

        }
        debugger;
        function deleteConfirm(anchorTag) {
            debugger;


            var row = $(anchorTag).parents('tr')[0];

            var AppID = $($(row).find('td')[0]).text();


            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(AppID, function (msg) {
                    row.remove();
                }, OnFail);
            }
        }

    </script>


</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-2 col-md-4 col-sm-6">
                <label for="doctorFilter">Doctor</label>
                <select id="doctorFilter" style="padding: 4px; margin-left: 8px;">
                    <option value="">All Doctors</option>
                </select>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label>Department</label>
            <select id="deptFilter" class="form-control">
                <option value="">All Departments</option>
            </select>
        </div>
    <div class="col-lg-2 col-md-4 col-sm-6">
        <label>Status</label>
        <select id="statusFilter" class="form-control">
            <option value="">All</option>
            <option value="Booked">Booked</option>
            <option value="Visited">Visited</option>
            <option value="Not Visited">Not Visited</option>
        </select>
    </div>
    <div class="col-lg-2 col-md-4 col-sm-6">
        <label>App. Date</label>
        <input type="text" id="dateFilter" class="form-control" readonly="readonly" />
    </div>
    </div>
    <div class="table-container" style="margin-top: 15px;">

            <table id="example" class="table-responsive table table-striped table-bordered display">
                <thead>
                    <tr>
                        <th>App No</th>
                        <th>App No.</th>
                        <th>Name</th>
                        <th>Age</th>
                        <th>Phone</th>
                        <th>Doctor</th>
                        <th>Department</th>
                        <th>App Date</th>
                        <th>App Time</th>
                        <th>Created Date</th>
                        <th>User Name</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody id="tblbody">
                </tbody>
            </table>
     
    </div>


</asp:Content>
