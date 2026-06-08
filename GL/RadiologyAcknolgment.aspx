<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RadiologyAcknolgment.aspx.cs" Inherits="PMS.RadiologyAcknolgment" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <style type="text/css">
        .select2-search--dropdown .select2-search__field {
            padding: 4px;
            width: 100% !important;
            box-sizing: border-box;
        }
        .filter-row {
            margin-bottom: 15px;
        }
        .filter-row [class*="col-"] {
            margin-bottom: 10px;
        }
        @media (min-width: 992px) {
            .filter-row [class*="col-"] {
                margin-bottom: 0;
            }
        }
        .date-picker-wrapper {
            position: relative;
        }
        .date-picker-wrapper input {
            cursor: pointer;
            background-color: #fff;
        }
    </style>
    <script type="text/javascript">
        var doctorsList = [];

        $(document).ready(function () {
            loadDoctors();
            loadDoctorsforFilter();
            FillMainTestDepartment();
            
            // Initialize date pickers first
            initializeDatePickers();
            
            // Then load the table after dates are set
            loadRadiologyAcknowledgment();

            // Apply filter on any filter change
            $('.filter-control').on('change', function () {
                var table = $('#tblradilogy').DataTable();
                if (table) {
                    table.ajax.reload();
                }
            });
        });
        
        function initializeDatePickers() {
            var today = new Date();
            var yesterday = new Date();
            yesterday.setDate(today.getDate() - 1);
            
            $("#startDate, #endDate").datepicker({
                dateFormat: 'dd-mm-yy',
                changeMonth: true,
                changeYear: true,
                autoclose: true,
                todayHighlight: true,
                maxDate: today
            });
            
            // Set default dates: yesterday to today (last 24 hours)
            $('#startDate').datepicker('setDate', yesterday);
            $('#endDate').datepicker('setDate', today);
        }

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
            let savedVisibility = null;

            $.ajax({
                type: "POST",
                url: "RadiologyAcknolgment.aspx/GetUserColumnPreferences",
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

            var table = $("#tblradilogy").DataTable({
                "processing": true,
                "serverSide": true,
                "destroy": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "pageLength": 50,
                "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],  
                "buttons": [
                    {
                        text: 'Save',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            SaveData();
                        }
                    },
                    'copy',
                    {
                        extend: 'excel',
                        exportOptions: {
                            format: {
                                body: function (data, row, column, node) {

                                    // Doctor dropdown
                                    if ($(node).find('select.doctor-select').length) {
                                        return $(node).find('select.doctor-select option:selected').text();
                                    }

                                    // Priority dropdown
                                    if ($(node).find('select.priority-select').length) {
                                        return $(node).find('select.priority-select option:selected').text();
                                    }

                                    // Remove HTML from other columns
                                    return $('<div>').html(data).text();
                                }
                            }
                        }
                    },                    
                    {
                        extend: 'pdf',
                        exportOptions: {
                            format: {
                                body: function (data, row, column, node) {

                                    if ($(node).find('select.doctor-select').length) {
                                        return $(node).find('select.doctor-select option:selected').text();
                                    }

                                    if ($(node).find('select.priority-select').length) {
                                        return $(node).find('select.priority-select option:selected').text();
                                    }

                                    return $('<div>').html(data).text();
                                }
                            }
                        }
                    },
                    {
                        extend: 'colvis',
                        text: '<i class="fa fa-columns"></i> Columns',
                        className: 'dt-button buttons-colvis',
                        collectionLayout: 'fixed two-column',
                        postfixButtons: ['colvisRestore']
                    }
                ],
                "ajax": function (data, callback, settings) {
                    var startDateVal = $('#startDate').val() || '';
                    var endDateVal = $('#endDate').val() || '';
                    var length = data.length;
                    if (length === -1) {
                        length = 1000000; 
                    }

                    $.ajax({
                        type: "POST",
                        url: "RadiologyAcknolgment.aspx/GetRadiologyAcknowledgment",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: length, 
                            sortColumn: data.columns[data.order[0].column].name,
                            sortDirection: data.order[0].dir,
                            searchValue: data.search.value,
                            mainDepartmentFilter: $('#mainDepartmentFilter').val() || 'All',
                            statusFilter: $('#statusFilter').val() || 'All',
                            ddlDoctorFilter: $('#ddlDoctorFilter').val() || '0',
                            mainTestDepartmentFilter: $('#ddlMainTestDepartment').val() || 'All',
                            startDate: startDateVal,
                            endDate: endDateVal
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
                        "data": "Bill_Date",
                        "name": "Bill_Date",
                        "render": function (data) {
                            if (!data) return '';
                            return moment(data).format("DD-MMM-YYYY");
                        }
                    },
                    { "data": "Bill_No", "name": "Bill_No" },
                    { "data": "mr_no_sequence", "name": "mr_no_sequence" },
                    { "data": "Full_Name" },
                    { "data": "Item_Name" },
                    { "data": "Lab_Test_Detail_ID" },
                    { "data": "Main_Test_Departments" },
                    { "data": "WardName" },
                    { "data": "BedNo" },
                    { "data": "Net_Amount" },
                    { "data": "Main_Department" },
                    {
                        "data": "Panel",
                        "name": "Panel",
                        "render": function (data) {
                            if (data && data > 0) {
                                return 'Panel';
                            } else {
                                return 'Private';
                            }
                        }
                    },
                    { "data": "Panel_Name" },
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

                            var selectedDoctorId =
                                (labTestDoctorId === null ||
                                    labTestDoctorId === "" ||
                                    labTestDoctorId === 0 ||
                                    labTestDoctorId === "0")
                                    ? billingDoctorId
                                    : labTestDoctorId;
                           /* var selectedDoctorId = billingDoctorId;*/

                            var isDisabled = (row.IsApproved === true);
                            var disabledAttr = isDisabled ? 'disabled' : '';

                            var options = '<option value="0">Select Doctor</option>';
                            doctorsList.forEach(function (doctor) {
                                var selected = (selectedDoctorId == doctor.Emp_ID) ? 'selected' : '';
                                options += `<option value="${doctor.Emp_ID}" ${selected}>${doctor.Emp_Name}</option>`;
                            });

                            return `<select class="form-control doctor-select" name="doctor" ${disabledAttr}>${options}</select>`;
                        }
                    },
                    {
                        "data": "IsAcknowledge",
                        "name": "IsAcknowledge",
                        "render": function (data, type, row) {
                            if (row.IsApproved === true) {
                                return '<span class="">Approved</span>';
                            }
                            else if (row.IsAcknowledge === true && row.IsApproved === false) {
                                return '<span class="">Acknowledged</span>';
                            }
                            else {
                                return '<span class="">Not Approved</span>';
                            }
                        }
                    },
                    { "data": "Department" },
                    {
                        "data": "Priorities",
                        "render": function (data) {
                            var selectedPriority = data || 'Medium';
                            return `
                        <select class="form-control priority-select" name="status">
                            <option value="Low" ${selectedPriority === 'Low' ? 'selected' : ''}>Low</option>
                            <option value="Medium" ${selectedPriority === 'Medium' ? 'selected' : ''}>Medium</option>
                            <option value="High" ${selectedPriority === 'High' ? 'selected' : ''}>High</option>
                        </select>
                    `;
                        }
                    },
                    {
                        "data": null,
                        "orderable": false,
                        "render": function (data, type, row) {
                            return `<button type="button" class="btn btn-sm btn-info history-btn" data-history="${(row.History || '').replace(/"/g, '&quot;')}">History</button>
                            <input type="hidden" class="history-value" value="${(row.History || '').replace(/"/g, '&quot;')}">`;
                        }
                    },
                    { "data": "Lab_Test_Detail_ID", "name": "Lab_Test_Detail_ID", "visible": false }
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

                        $.ajax({
                            type: "POST",
                            url: "RadiologyAcknolgment.aspx/SaveUserColumnPreferences",
                            data: JSON.stringify({ visibilityJson: JSON.stringify(currentVis) }), 
                            contentType: "application/json; charset=utf-8",
                            success: function (response) {
                                console.log("Column preferences saved");
                            },
                            error: function (error) {
                                console.error("Failed to save preferences:", error);
                            }
                        });
                    });

                    var lengthContainer = document.querySelector('#tblradilogy_length');
                    var lengthDropdown = document.querySelector('#tblradilogy_length select');
                    var label = document.querySelector('#tblradilogy_length label');

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
                },
                "drawCallback": function () {
                    $('.doctor-select').each(function () {
                        if (!$(this).hasClass("select2-hidden-accessible")) {
                            $(this).select2({
                                width: '100%',
                                placeholder: "Select Doctor",
                                allowClear: true,
                                disabled: $(this).is(':disabled')
                            });
                        }
                    });

                    $('.priority-select').each(function () {
                        if (!$(this).hasClass("select2-hidden-accessible")) {
                            $(this).select2({
                                width: '100%',
                                minimumResultsForSearch: -1
                            });
                        }
                    });
                },
            });
        }

        function loadDoctorsforFilter() {
            $.ajax({
                type: "POST",
                url: "RadiologyAcknolgment.aspx/loadDoctorsforFilter",
                contentType: "application/json; charset=utf-8",
                success: function (response) {
                    var options = '<option value="0">All Doctors</option>';
                    var doctors = JSON.parse(response.d);
                    $.each(doctors, function (key, value) {
                        options += '<option value="' + value.Emp_ID + '">' + value.name + '</option>';
                    });
                    $('#ddlDoctorFilter').html(options);
                    $('#ddlDoctorFilter').select2({
                        width: '100%',
                        placeholder: "Select Doctor",
                        allowClear: true
                    });
                },
                error: function (error) {
                    console.log(error);
                }
            });
        }

        function SaveData() {
            var tableDT = $("#tblradilogy").DataTable();
            var Testlist = [];
            var isChkZero = true;

            $('#tblradilogy tbody input.rowSelect:checked').each(function () {
                isChkZero = false;
                var row = $(this).closest('tr');
                var rowData = tableDT.row(row).data();
                var status = row.find('.priority-select').val();
                var Lab_Test_Detail_ID = rowData.Lab_Test_Detail_ID;
                var Doctor_ID = row.find('.doctor-select').val() || 0;
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
                success: function (response) {
                    if (response.d === "Update Data") {
                        alert("Records saved successfully!");
                        location.reload();
                    } else {
                        alert("Error: " + response.d);
                    }
                },
                error: function (xhr, status, error) {
                    alert("Error saving data: " + error);
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
            alert("History saved successfully!");
        }

        function FillMainTestDepartment() {
            var options = '<option value="All">All Main Test Departments</option>';
            $.ajax({
                type: "POST",
                url: "RadiologyAcknolgment.aspx/FillTestMainDepartment",
                contentType: "application/json; charset=utf-8",
                success: function (response) {
                    var tests = JSON.parse(response.d);
                    $.each(tests, function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlMainTestDepartment').html(options);
                    $('#ddlMainTestDepartment').select2({
                        width: '100%',
                        placeholder: "Select Main Test Department",
                        allowClear: true
                    });
                },
                error: function (error) {
                    console.log(error);
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12">
          
                
                <div class="panel-body">
                    <!-- Filter Row 1 -->
                    <div class="row filter-row">
                        <div class="col-lg-2 col-md-2 col-sm-6">
                            <label>Main Department:</label>
                            <select id="mainDepartmentFilter" class="form-control filter-control">
                                <option value="All">All Departments</option>
                                <option value="WalkIn">Walk In</option>
                                <option value="OutPatient">Out Patient</option>
                                <option value="InPatient">In Patient</option>
                                <option value="Emergency">Emergency</option>
                            </select>
                        </div>
                        <div class="col-lg-2 col-md-2 col-sm-6">
                            <label>Status:</label>
                            <select id="statusFilter" class="form-control filter-control">
                                <option value="All">All Status</option>
                                <option value="Approved">Approved</option>
                                <option value="Acknowledged">Acknowledged</option>
                                <option value="NotApproved">Not Approved</option>
                            </select>
                        </div>
                        <div class="col-lg-2 col-md-2 col-sm-6">
                            <label>Doctor:</label>
                            <select id="ddlDoctorFilter" class="form-control filter-control">
                                <option value="0">All Doctors</option>
                            </select>
                        </div>
                        <div class="col-lg-2 col-md-2 col-sm-6">
                            <label>Main Test Department:</label>
                            <select id="ddlMainTestDepartment" class="form-control filter-control">
                                <option value="All">All Test Departments</option>
                            </select>
                        </div>
                        <div class="col-lg-2 col-md-2 col-sm-6">
                            <label>Start Date:</label>
                            <input type="text" id="startDate" class="form-control filter-control" placeholder="DD-MM-YYYY" autocomplete="off">
                        </div>
                        <div class="col-lg-2 col-md-2 col-sm-6">
                            <label>End Date:</label>
                            <input type="text" id="endDate" class="form-control filter-control" placeholder="DD-MM-YYYY" autocomplete="off">
                        </div>
                    </div>

                    <!-- Table -->
                    <div style="margin-top: 15px; overflow-x: auto;">
                        <table class="table table-hover table-striped table-bordered" id="tblradilogy" style="width: 100%;">
                            <thead>
                                <tr>
                                    <th>Check</th>
                                    <th>Bill Date</th>
                                    <th>Bill No</th>
                                    <th>MR No</th>
                                    <th>Name</th>
                                    <th>Test Name</th>
                                    <th>Accession #</th>
                                    <th>Main Test Department</th>
                                    <th>Ward No</th>
                                    <th>Bed No</th>
                                    <th>Net Amount</th>
                                    <th>Main Category</th>
                                    <th>Patient Category</th>
                                    <th>Panel Name</th>
                                    <th>Main Department</th>
                                    <th>Doctor</th>
                                    <th>Status</th>
                                    <th>Department</th>
                                    <th>Priority</th>
                                    <th>History</th>
                                    <th style='display: none;'>Lab Test Detail Id</th>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>
                </div>
         
        </div>
    </div>

    <!-- History Modal -->
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
                        <textarea class="form-control" id="historyText" rows="5" placeholder="Enter history notes..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary" onclick="saveHistory()">Save History</button>
                </div>
            </div>
        </div>
    </div>
</asp:Content>