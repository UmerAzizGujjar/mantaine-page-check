<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RadiologyAcknolgment.aspx.cs" Inherits="PMS.RadiologyAcknolgment" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">     
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        var doctorsList = [];

        $(document).ready(function () {
            loadDoctors();
            loadDoctorsforFilter();
            loadRadiologyAcknowledgment();
            FillMainTestDepartment();

            $('#mainDepartmentFilter, #statusFilter, #ddlDoctorFilter, #ddlMainTestDepartment').on('change', function () {
                $('#tblradilogy').DataTable().ajax.reload();
            });
        });

        function loadDoctors() {
            $.ajax({
                type: "POST",
                url: "RadiologyAcknolgment.aspx/GetDoctors",
                contentType: "application/json; charset=utf-8",
                success: function (response) {
                    doctorsList = JSON.parse(response.d);
                },
                error: function (xhr) {
                    console.log(xhr.responseText);
                }
            });
        }

        function loadRadiologyAcknowledgment() {

            var table = $("#tblradilogy").DataTable({
                "processing": true,
                "serverSide": true,
                "destroy": true, 
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{
                    text: 'Save',
                    className: 'dt-button buttons-copy buttons-html5',
                    action: function () {
                        SaveData();
                    }
                }, 'copy', 'excel', 'pdf'],
                "ajax": function (data, callback, settings) {

                    $.ajax({
                        type: "POST",
                        url: "RadiologyAcknolgment.aspx/GetRadiologyAcknowledgment",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length,
                            sortColumn: data.columns[data.order[0].column].name,
                            sortDirection: data.order[0].dir,
                            searchValue: data.search.value,
                            mainDepartmentFilter: $('#mainDepartmentFilter').val() || 'All',
                            statusFilter: $('#statusFilter').val() || 'All',
                            ddlDoctorFilter: $('#ddlDoctorFilter').val() || '0',
                            mainTestDepartmentFilter: $('#ddlMainTestDepartment').val() || 'All'
                        }),
                        contentType: "application/json; charset=utf-8",
                        success: function (response) {

                            callback({
                                draw: response.d.draw,
                                recordsTotal: response.d.recordsTotal,
                                recordsFiltered: response.d.recordsFiltered,
                                data: response.d.data
                            });
                        },
                        error: function (xhr) {
                            console.log(xhr.responseText);
                        }
                    });
                },

                "columns": [
                    {
                        "data": "Bill_ID",
                        "orderable": false,
                        "render": function (data) {
                            return `<input type="checkbox" class="rowSelect" value="${data}">`;
                        }
                    },
                    {
                        "data": "Bill_Date", "name": "Bill_Date",
                        "render": function (data) {
                            return moment(data).format("DD-MMM-YYYY hh:mm A");
                        }
                    },
                    { "data": "Bill_No", "name": "Bill_No" },
                    { "data": "mr_no_sequence", "name": "mr_no_sequence" },
                    { "data": "Full_Name" },
                    { "data": "Item_Name" },
                    { "data": "Main_Test_Departments" },
                    { "data": "WardName" },
                    { "data": "BedNo" },
                    {
                        "data": "ParentTrans_Name",
                        "name": "ParentTrans_Name",
                        "render": function (data) {
                            if (!data || data === "") {
                                return "Walk In";
                            } else if (data === "OutPatient") {
                                return "Out Patient";
                            } else if (data === "InPatient") {
                                return "In Patient";
                            } else if (data === "Emergency") {
                                return "Emergency";
                            } else {
                                return "Walk In";
                            }
                        }
                    },
                    {
                        "data": "DoctorID",
                        "name": "DoctorID",
                        "orderable": false,
                        "render": function (data, type, row) {
                            var labTestDoctorId = row.LabTest_DoctorID || 0;
                            var billingDoctorId = row.Billing_DoctorID || 0;
                            
                            var selectedDoctorId = labTestDoctorId !== 0 ? labTestDoctorId : billingDoctorId;
                            var disabled = (labTestDoctorId !== 0 || billingDoctorId !== 0) ? 'disabled' : '';
                            
                            var options = '<option value="0">Select Doctor</option>';
                            doctorsList.forEach(function (doctor) {
                                var selected = (selectedDoctorId == doctor.Emp_ID) ? 'selected' : '';
                                options += `<option value="${doctor.Emp_ID}" ${selected}>${doctor.Emp_Name}</option>`;
                            });
                            return `<select class="form-control doctor-select" name="doctor" ${disabled}>${options}</select>`;
                        }
                    },
                    {
                        "data": "IsAcknowledge",
                        "name": "IsAcknowledge",
                        "render": function (data, type, row) {
                            if (row.IsApproved === true) {
                                return 'Approved';
                            }
                            else if (row.IsAcknowledge === true) {
                                return 'Acknowledged';
                            }
                            else {
                                return 'Not Approved';
                            }
                        }
                    },
                    { "data": "Department" },              
                    {
                        "data": null,
                        "render": function () {
                            return `
                        <select class="form-control" name="status">
                            <option value="Low">Low</option>
                            <option value="Medium">Medium</option>
                            <option value="High">High</option>
                        </select>
                    `;
                        }
                    },  
                    {
                        "data": null,
                        "orderable": false,
                        "render": function (data, type, row) {
                            return `<button type="button" class="btn btn-sm btn-info history-btn" data-history="${row.History || ''}">History</button>
                                    <input type="hidden" class="history-value" value="${row.History || ''}">`;
                        }
                    },
                    { "data": "Lab_Test_Detail_ID", "name": "Lab_Test_Detail_ID","visible": false }
                ]
            });

        }
        function loadDoctorsforFilter() {

            PageMethods.loadDoctorsforFilter(function (data) {
                var options = '<option value="0" >Please Select</option>';
                $.each(JSON.parse(data), function (key, value) {

                    options += '<option value="' + value.Emp_ID + '" >' + value.name + '</option>';
                });
                $('#ddlDoctorFilter').html(options);
                $('#ddlDoctorFilter').select2();
            },
                function (error) {
                    alert(error.get_message());
                });
        }
        function SaveData() {
            debugger;
            var tableDT = $("#tblradilogy").DataTable();
            var Testlist = [];
            var isChkZero = true;

            $('#tblradilogy tbody input.rowSelect:checked').each(function () {

                isChkZero = false;

                var row = $(this).closest('tr');
                var rowData = tableDT.row(row).data();

                var status = row.find('select[name=status]').val();
                var Lab_Test_Detail_ID = rowData.Lab_Test_Detail_ID;
                var Doctor_ID = row.find('select[name=doctor]').val() || 0;
                var History = row.find('.history-value').val() || '';

                Testlist.push({
                    'status': status,
                    'Lab_Test_Detail_ID': Lab_Test_Detail_ID,
                    'Doctor_ID': parseInt(Doctor_ID),
                    'History': History
                });
            });

            if (isChkZero) {
                alert("Select Checkbox Which Test Do You Want To Acknowledge");
                return;
            }

            $.ajax({
                type: "POST",
                url: "RadiologyAcknolgment.aspx/SaveRecord",
                data: JSON.stringify({ "Testlist": Testlist }),
                contentType: "application/json; charset=utf-8",
                success: function () {
                    location.reload();
                }
            });
        }

        $(document).on('click', '.history-btn', function () {
            var currentHistory = $(this).data('history') || '';
            var row = $(this).closest('tr');
            
            $('#historyText').val(currentHistory);
            $('#historyModal').data('currentRow', row);
            $('#historyModal').modal('show');
        });

        function saveHistory() {
            var row = $('#historyModal').data('currentRow');
            var historyValue = $('#historyText').val();
            
            row.find('.history-value').val(historyValue);
            row.find('.history-btn').data('history', historyValue);
            
            $('#historyModal').modal('hide');
        }

        function FillMainTestDepartment() {
            var options = '<option value="All" >All</option>';
            PageMethods.FillTestMainDepartment(function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlMainTestDepartment').html(options);
            },
                function (error) {
                    console.log(error);
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
                        <label>Main Department:</label>
                        <select id="mainDepartmentFilter" class="form-control">
                            <option value="All">All</option>
                            <option value="WalkIn">Walk In</option>
                            <option value="OutPatient">Out Patient</option>
                            <option value="InPatient">In Patient</option>
                            <option value="Emergency">Emergency</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label>Status:</label>
                        <select id="statusFilter" class="form-control">
                            <option value="All">All</option>
                            <option value="Approved">Approved</option>
                             <option value="Acknowledged">Acknowledged</option>
                            <option value="NotApproved">Not Approved</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label>Doctor:</label>
                        <select id="ddlDoctorFilter" class="form-control">                          
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label>Main Test Department:</label>
                        <select id="ddlMainTestDepartment" class="form-control">
                            <option value="All">All</option>
                        </select>
                    </div>
                </div>
            </div>
    <table style="width: 100%;">
        <tr>
            <td>
                <div id="POdetails" style="margin-top: 15px;">
                    <div>
                        <table class="table table-hover table-striped table-bordered" id="tblradilogy" style="overflow: scroll; height: auto;">
                            <thead id="ihead">
                                <tr>
                                    <th>Check</th>
                                    <th>Bill Date</th>
                                    <th>Bill No</th>
                                    <th>MR No</th>
                                    <th>Name</th>
                                    <th>Test Name</th>                                   
                                    <th>Main Test Department</th>
                                    <th>Ward No</th>
                                    <th>Bed No</th>
                                    <th>Main Department</th>
                                    <th>Doctor</th>
                                    <th>Status</th>
                                    <th>Department</th>
                                    <th>Priority</th>
                                    <th>History</th>
                                    <th style='display: none;'>Lab Test Detail Id</th>

                                </tr>
                            </thead>
                            <tbody id="tbl_tbody_radiology">
                            </tbody>
                        </table>
                    </div>
                </div>
            </td>
        </tr>
    </table>
        </div>
        </div>

    <div class="modal fade" id="historyModal" tabindex="-1" role="dialog" aria-labelledby="historyModalLabel" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="historyModalLabel">History</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="form-group">
                        <label for="historyText">History:</label>
                        <textarea class="form-control" id="historyText" rows="5"></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary" onclick="saveHistory()">Save</button>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
