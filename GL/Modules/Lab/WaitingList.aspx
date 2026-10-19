<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="WaitingList.aspx.cs" Inherits="PMS.Modules.Lab.WaitingList" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">     
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        var departmentsList = [];
        var doctorsList = []; 

        $(document).ready(function () {
            loadDepartments();
            loadDoctors();
            loadWaitingList();

            $('#departmentFilter, #doctorFilter').on('change', function () {
                $('#tblWaitingList').DataTable().ajax.reload();
            });
        });

        function loadDepartments() {
            $.ajax({
                type: "POST",
                url: "WaitingList.aspx/GetMainDepartments",
                contentType: "application/json; charset=utf-8",
                success: function (response) {
                    departmentsList = JSON.parse(response.d);
                    var options = '<option value="All">All</option>';
                    departmentsList.forEach(function (dept) {
                        options += `<option value="${dept.DataValue_Name}">${dept.DataValue_Description}</option>`;
                    });
                    $('#departmentFilter').html(options);
                },
                error: function (xhr) {
                    console.log(xhr.responseText);
                }
            });
        }

        function loadDoctors() {
            $.ajax({
                type: "POST",
                url: "WaitingList.aspx/GetDoctors",
                contentType: "application/json; charset=utf-8",
                success: function (response) {
                    doctorsList = JSON.parse(response.d);
                    var options = '<option value="All">All</option>';
                    doctorsList.forEach(function (doctor) {
                        options += `<option value="${doctor.Emp_ID}">${doctor.Emp_Name}</option>`;
                    });
                    $('#doctorFilter').html(options);
                },
                error: function (xhr) {
                    console.log(xhr.responseText);
                }
            });
        }

        function loadWaitingList() {
            var table = $("#tblWaitingList").DataTable({
                "processing": true,
                "serverSide": true,
                "destroy": true,
                "scrollX": true,
                "autoWidth": false,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "WaitingList.aspx/GetRadiologyAcknowledgment",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length,
                            sortColumn: data.columns[data.order[0].column].name || 'BillDate',
                            sortDirection: data.order[0].dir,
                            searchValue: data.search.value,
                            mainDepartmentFilter: $('#departmentFilter').val() || 'All',
                            statusFilter: 'All',
                            doctorFilter: $('#doctorFilter').val() || 'All'
                        }),
                        contentType: "application/json; charset=utf-8",
                        success: function (response) {
                            callback({
                                draw: response.d.draw,
                                recordsTotal: response.d.recordsTotal,
                                recordsFiltered: response.d.recordsFiltered,
                                data: response.d.data
                            });
                            
                            // Update waiting time display
                            $('#totalWaitingTime').text(response.d.totalWaitingTime || '0 hours 0 minutes');
                        },
                        error: function (xhr) {
                            console.log(xhr.responseText);
                        }
                    });
                },
                "columns": [
                    { 
                        "data": "MrNo", 
                        "name": "MrNo",
                        "width": "10%"
                    },
                    { 
                        "data": "Name", 
                        "name": "Name",
                        "width": "15%"
                    },
                    { 
                        "data": "BillNo", 
                        "name": "BillNo",
                        "width": "10%"
                    },
                    {
                        "data": "BillDate", 
                        "name": "BillDate",
                        "width": "15%",
                        "render": function (data) {
                            if (data) {
                                return moment(data).format("DD-MMM-YYYY");
                            }
                            return '';
                        }
                    },
                    { 
                        "data": "TestName", 
                        "name": "TestName",
                        "width": "20%"
                    },
                    { 
                        "data": "Department", 
                        "name": "Department",
                        "width": "15%"
                    },
                    { 
                        "data": "testtime", 
                        "name": "testtime",
                        "width": "15%"
                    },
                    { 
                        "data": "DoctorName", 
                        "name": "DoctorName",
                        "width": "15%"
                    }
                ],
                "order": [[3, "asc"]]
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12">
            <div style="margin-bottom: 15px;">
                <div class="row">
                    <div class="col-md-3">
                        <label>Department:</label>
                        <select id="departmentFilter" class="form-control">
                            <option value="All">All</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label>Doctor:</label>
                        <select id="doctorFilter" class="form-control">
                            <option value="All">All</option>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label>Total Waiting Time:</label>
                        <div class="form-control" style="background-color: #f5f5f5; font-weight: bold;">
                            <span id="totalWaitingTime">0 hours 0 minutes</span>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="table-responsive">
                <table class="table table-hover table-striped table-bordered" id="tblWaitingList">
                    <thead>
                        <tr>
                            <th>MR No</th>
                            <th>Name</th>
                            <th>Bill No</th>
                            <th>Bill Date</th>
                            <th>Test Name</th>
                            <th>Department</th>
                            <th>Waiting Time</th>
                            <th>Doctor</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</asp:Content>
