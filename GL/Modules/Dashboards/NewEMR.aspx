<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="NewEMR.aspx.cs" Inherits="PMS.Modules.Dashboards.NewEMR" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/css/tablestyle.css" rel="stylesheet" />
    <link href="../../wwwroot/THEME_TIBBIT/css/CustomCss/NewEMR.css" rel="stylesheet" />
   
    <script type="text/javascript" id="ScriptSidebar">
        function toggleRetract() {
            const retractDiv = document.getElementById('retract');
            retractDiv.classList.toggle('minimized');
        }



        function navigateAction(element) {

            $('.menu-item').removeClass('selected');

            $(element).addClass('selected');

            const allTabs = document.querySelectorAll('.tabs');
            $(allTabs).not('#tab' + element.id).slideUp(300);

            const tabId = 'tab' + element.id;
            const selectedTab = document.getElementById(tabId);
            if (selectedTab) {
                $(selectedTab).slideDown(300);
            }

            const spanText = $(element).find('span').text().trim();
            if (spanText) {
                $('.header').text(spanText);
            }
        }
    </script>

    <script type="text/javascript" id="ready">
        $(document).ready(function () {

            $('#ctl00_notification').hide();
        });
        document.addEventListener("DOMContentLoaded", function () {
            const urlParams = new URLSearchParams(window.location.search);
            const regId = urlParams.get("RegID");

            if (regId) {
                selectPatient(regId);
            }
        });

        function selectPatient(RegID) {
            hideResults();
            $("#hdfReg_ID").val(RegID);
            fetchPatientInfo();
            checkVisits();
            LoadOPDTable();
            LoadIPDTable();
            LoadEMERGENCYTable();
            LoadMedicineTable();
            LoadDiagnosticsTable();
            LoadInvestigationTable();
            LoadPatientServicesTable();
            LoadPatientComplaintsTable();
            LoadPatientSymptomsTable();
            LoadPrimaryDiagnosisTable();
            LoadFinalDiagnosisTable();
        }
        function fetchPatientInfo() {
            debugger;
            var Patient_ID = $("#hdfReg_ID").val();

            $.ajax({
                type: "POST",
                url: "NewEMR.aspx/GetBasicInfo",
                data: JSON.stringify({ Patient_ID: Patient_ID }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (resp) {
                    debugger;
                    var data = JSON.parse(resp.d);

                    $('#patname').text(data.Name);
                    $('#mrno').text(data.Mr_No);
                    $('#txtage').text(data.Age);
                    $('#gender').text(data.Gender);
                    $('#phonenumber').text(data.Mobile);
                    $('#address').text(data.Address);
                    $('#CNIC').text(data.CNIC);


                    fetchAppointment();

                },
                error: function (response) {
                    alert("Error: " + response.responseText);
                    console.error("AJAX Error: ", response);
                }
            });

        }
        
        function fetchAppointment() {
            var Patient_ID = $("#hdfReg_ID").val();
            $.ajax({
                type: "POST",
                url: "NewEMR.aspx/getAppoitnmentInfo",
                data: JSON.stringify({ Patient_ID: Patient_ID }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (resp) {
                    debugger;
                    var data = JSON.parse(resp.d);
                    console.log(data);
                    if (data && data.doctor) {

                        $('#doctorname').text(data.doctor.Emp_Name);
                    } else {
                        $('#doctorname').text("");
                    }

                    if (data && data.AppointmentDate) {
                        var date = data.AppointmentDate;
                        date = moment(date).format('MMMM DD,YYYY');
                        $("#appdate").text(date);
                    } else {
                        $("#appdate").text("No appointments.");
                    }

                    getlastAppointment();
                },
                error: function (response) {
                    alert("Error: " + response.responseText);
                    console.error("AJAX Error: ", response);
                }
            });
        }
        function getlastAppointment() {
            var Patient_ID = $("#hdfReg_ID").val();
            $.ajax({
                type: "POST",
                url: "NewEMR.aspx/GetLastAppointmentVisit",
                data: JSON.stringify({ Patient_ID: Patient_ID }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (resp) {
                    debugger;
                    var data = JSON.parse(resp.d);
                    if (data && data.doctor) {
                        $('#prvDoctor').text(data.doctor.Emp_Name);
                    } else {
                        $('#prvDoctor').text("");
                    }

                    if (data && data.AppointmentDate) {
                        var date = data.AppointmentDate;
                        date = moment(date).format('MMMM-DD-YY');
                        $("#prv_visit").text(date);
                    } else {
                        $("#prv_visit").text("No appointments.");
                    }
                    if (data && data.Department) {
                        $('#Department').text(data.Department);
                    } else {
                        $('#Department').text("");
                    }
                },
                error: function (response) {
                    alert("Error: " + response.responseText);
                    console.error("AJAX Error: ", response);
                }
            });

        }
        function checkVisits() {
            var reg_id = $('#hdfReg_ID').val();
            $.ajax({
                type: "POST",
                url: "NewEMR.aspx/CountVisits",
                data: JSON.stringify({ reg_id: reg_id }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (resp) {
                    debugger;
                    var data = JSON.parse(resp.d);
                    $("#opdVisits").text(data.OutPatientCount);
                    $("#ipdVisits").text(data.InPatientCount);
                    $("#emergencyVisits").text(data.EmergencyCaseCount);
                    $("#medicationCount").text(data.MediceneCount);
                    $("#investigationCount").text(data.InvestigationCount);
                    $("#diagnosticsCount").text(data.DiagnosticCount);
                    $("#proceduresCount").text(data.ProceduresCount);


                },
                error: function (response) {
                    alert("Error: " + response.responseText);
                    console.error("AJAX Error: ", response);
                }
            });

        }
        function toggleInfo() {
            const $hiddenElements = $('.ToBeHidden');
            const $icon = $('.arrow-button i');

            if ($hiddenElements.is(':visible')) {
                // Slide up if currently visible
                $hiddenElements.slideUp(300, function () {
                    $icon.removeClass('fa-chevron-up').addClass('fa-chevron-down');
                });
            } else {
                // Slide down if currently hidden
                $hiddenElements.slideDown(300, function () {
                    $icon.removeClass('fa-chevron-down').addClass('fa-chevron-up');
                });
            }
        }

        function hideResults() {
            searchResults.classList.remove('active');
        }
        document.addEventListener('DOMContentLoaded', function () {
            const searchInput = document.getElementById('searchInput');
            const searchResults = document.getElementById('searchResults');

            let searchTimeout;
            let currentXHR = null;
            let highlightedIndex = -1; // Track which result is highlighted

            searchInput.addEventListener('input', function (e) {
                const query = e.target.value.trim();
                clearTimeout(searchTimeout);

                if (currentXHR && currentXHR.readyState !== 4) {
                    currentXHR.abort();
                }

                searchTimeout = setTimeout(() => {
                    showLoading();
                    searchPatients(query);
                }, 300);
            });

            // Handle keyboard navigation
            searchInput.addEventListener('keydown', function (e) {
                const items = searchResults.querySelectorAll('.result-item');
                if (items.length === 0) return;

                if (e.key === 'ArrowDown') {
                    e.preventDefault();
                    highlightedIndex = (highlightedIndex + 1) % items.length;
                    updateHighlight(items);
                } else if (e.key === 'ArrowUp') {
                    e.preventDefault();
                    highlightedIndex = (highlightedIndex - 1 + items.length) % items.length;
                    updateHighlight(items);
                } else if (e.key === 'Enter') {
                    e.preventDefault();
                    if (highlightedIndex >= 0) {
                        const selectedItem = items[highlightedIndex];
                        selectedItem.click(); // trigger selection
                    } else if (items.length > 0) {
                        items[0].click(); // default: first item
                    }
                    hideResults();
                }
            });

            function updateHighlight(items) {
                items.forEach(item => item.classList.remove('highlighted'));
                if (highlightedIndex >= 0) {
                    items[highlightedIndex].classList.add('highlighted');
                    items[highlightedIndex].scrollIntoView({ block: "nearest" });
                }
            }

            function searchPatients(searchValue) {
                currentXHR = $.ajax({
                    type: "POST",
                    url: "NewEMR.aspx/GetPatients",
                    data: JSON.stringify({ searchValue: searchValue }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        try {
                            const patients = JSON.parse(response.d);
                            if (patients.error) {
                                showError(patients.error);
                            } else {
                                highlightedIndex = -1; // reset highlight
                                showResults(patients, searchValue);
                            }
                        } catch (e) {
                            showError('Error parsing response: ' + e.message);
                        }
                    },
                    error: function (xhr, status, error) {
                        showError('Server error: ' + error);
                    }
                });
            }

            function showResults(patients, query) {
                if (!patients || patients.length === 0) {
                    searchResults.innerHTML = `
                <div class="no-results">
                    No patients found for "${query}"
                </div>`;
                } else {
                    searchResults.innerHTML = patients.map(patient => {
                        const displayText = `${patient.PatientNo}-${patient.FullName}`;
                        return `
                    <div class="result-item" onclick="selectPatient('${patient.RegID}')">
                        <div>${highlightText(displayText, query)}</div>
                    </div>`;
                    }).join('');
                }
                searchResults.classList.add('active');
            }

            function showLoading() {
                searchResults.innerHTML = `
            <div class="no-results">
                <div style="display: flex; align-items: center; justify-content: center; gap: 10px;">
                    <div class="loading-spinner"></div>
                    Searching patients...
                </div>
            </div>`;
                searchResults.classList.add('active');
            }

            function showError(errorMessage) {
                searchResults.innerHTML = `
            <div class="no-results" style="color: #ff6b6b;">
                ⚠️ Error: ${errorMessage}
            </div>`;
                searchResults.classList.add('active');
            }

            function highlightText(text, query) {
                if (!query) return text;
                const regex = new RegExp(`(${escapeRegExp(query)})`, 'gi');
                return text.replace(regex, '<strong style="background: rgba(102, 126, 234, 0.2); border-radius: 3px; padding: 0 2px;">$1</strong>');
            }

            function escapeRegExp(string) {
                return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
            }

            searchInput.addEventListener('focus', function () {
                if (this.value.trim().length >= 2) {
                    const query = this.value.trim();
                    showLoading();
                    searchPatients(query);
                }
            });
        });

        function LoadOPDTable() {
            var ID = $("#hdfReg_ID").val();
            if ($.fn.DataTable.isDataTable('#tblOPD')) {
                $('#tblOPD').DataTable().destroy();
            }

            let tableOptions = {
                "processing": true,
                "serverSide": true,
                "filter": true,
                "ajax": {
                    "url": "NewEMR.aspx/OPDViewList",
                    "type": "POST",
                    "contentType": "application/json; charset=utf-8",
                    "dataType": "json",
                    "data": function (d) {
                        return JSON.stringify({
                            regID: parseInt(ID) || 0,
                            draw: d.draw,
                            start: d.start,
                            length: d.length,
                            sortColumn: d.columns && d.order && d.order[0] ? d.columns[d.order[0].column].data : "",
                            sortColumnDirection: d.order && d.order[0] ? d.order[0].dir : "desc",
                            searchValue: d.search ? d.search.value : ""
                        });
                    },
                    "dataSrc": function (json) {
                        console.log("Server Full Response:", json);

                        if (json && json.d) {
                            try {
                                const data = JSON.parse(json.d);
                                console.log("Parsed Data:", data);
                                data.data = data.data.map(item => ({
                                    VisitNo: item.VisitNo || '',
                                    VisitDate: item.VisitDate || null,
                                    Department: item.Department || 'N/A',
                                    PatientType: item.PatientType || 'N/A',
                                    CheckedBy: item.CheckedBy || 'N/A',
                                    Remarks: item.Remarks || '',
                                    DischargeDate: item.DischargeDate || null,
                                    Status: item.Status || 'Active'
                                }));

                                return data.data;
                            } catch (e) {
                                console.error("JSON Parse Error:", e);
                                return [];
                            }
                        } else {
                            console.error("Invalid response format", json);
                            return [];
                        }
                    },
                    "error": function (xhr, status, error) {
                        console.error("AJAX Error:", status, error);
                        console.error("Response:", xhr.responseText);
                        Swal.fire('Error', 'Failed to load data.', 'error');
                    }
                },
                "columns": [
                    { "data": "VisitNo", "width": "8%", "orderable": true },
                    {
                        "data": "VisitDate",
                        "render": function (data, type) {
                            if (!data || type !== 'display') return data; 
                            const m = moment(data);
                            return m.isValid() ? m.format('DD-MMM-YYYY') : 'N/A';
                        },
                        "width": "10%", "orderable": true
                    },
                    { "data": "Department", "width": "15%", "orderable": true },
                    { "data": "PatientType", "width": "12%", "orderable": true },
                    { "data": "CheckedBy", "width": "12%", "orderable": true },
                    {
                        "data": "Status",
                        "render": function (data) {
                            return data || 'Active';
                        },
                        "width": "10%", "orderable": true
                    },
                    {
                        "data": "DischargeDate",
                        "render": function (data, type) {
                            if (!data || type !== 'display') return data;
                            const m = moment(data);
                            return m.isValid() ? m.format('DD-MMM-YYYY') : 'N/A';
                        },
                        "width": "10%", "orderable": true
                    },
                    {
                        "data": "Remarks",
                        "render": function (data) {
                            return data || '';
                        },
                        "width": "15%", "orderable": false
                    },
                    {
                        "data": null,
                        "render": function (data, type, row) {
                            return `
                        <a class="printListBtn" 
                           style="border-radius: 4px; margin-left: 4px; color: white; padding: 5px 8px; background-color: #007bff;" 
                           href="#" 
                           onclick="Print(${row.VisitNo}); return false;">
                           <i class="fa fa-print"></i>
                        </a>`;
                        },
                        "width": "15%", "orderable": false
                    }
                ],
                "dom": 'Bfrtip',
                "buttons": ['copy', 'excel', 'pdf'],
                "lengthChange": true,
                "initComplete": function (settings, json) {
                    const xhr = settings.jqXHR;

                    if (xhr && xhr.responseJSON && xhr.responseJSON.d) {
                        let parsedData;
                        try {
                            parsedData = typeof xhr.responseJSON.d === "string"
                                ? JSON.parse(xhr.responseJSON.d)
                                : xhr.responseJSON.d;

                            const total = parsedData.recordsFiltered || 0;
                            const shouldHideControls = total <= 9;

                            console.log("Records Filtered:", total, "Hide Controls:", shouldHideControls);

                            const $container = $('#tblOPD').closest('.dataTables_wrapper');

                            if (shouldHideControls) {
                                $container.find('.dataTables_paginate, .dataTables_length, .dataTables_info, .dataTables_filter, .dt-buttons').hide();
                            } else {
                                $container.find('.dataTables_paginate, .dataTables_length, .dataTables_info, .dataTables_filter, .dt-buttons').show();
                            }
                            if (!shouldHideControls) {
                                const $lengthLabel = $('#tblOPD_length label');
                                const $lengthSelect = $('#tblOPD_length select');

                                if ($lengthSelect.length && $lengthLabel.length && !$lengthLabel.data('customized')) {
                                    $lengthLabel.empty()
                                        .append('<span>Show entries </span>')
                                        .append($lengthSelect)
                                        .data('customized', true);

                                    $lengthSelect.css('width', '60px');
                                    $lengthLabel.css({
                                        'display': 'inline-flex',
                                        'alignItems': 'center',
                                        'marginTop': '17px'
                                    });
                                }
                            }
                        } catch (e) {
                            console.error("Error in initComplete:", e);
                        }
                    }
                }
            };

            $("#tblOPD").DataTable(tableOptions);
        }
        function LoadIPDTable() {
            var ID = $("#hdfReg_ID").val();

            // Destroy existing table if it exists
            if ($.fn.DataTable.isDataTable('#tblIPD')) {
                $('#tblIPD').DataTable().destroy();
            }

            let tableOptions = {
                "processing": true,
                "serverSide": true,
                "filter": true,
                "dom": 'Bfrtip',
                "buttons": ['copy', 'excel', 'pdf'],
                "lengthChange": true,
                "ajax": {
                    "url": "NewEMR.aspx/IPDViewList",
                    "type": "POST",
                    "contentType": "application/json; charset=utf-8",
                    "dataType": "json",
                    "data": function (d) {
                        return JSON.stringify({
                            regID: parseInt(ID) || 0,
                            draw: d.draw,
                            start: d.start,
                            length: d.length,
                            sortColumn: d.columns && d.order && d.order[0] ? d.columns[d.order[0].column].data : "",
                            sortColumnDirection: d.order && d.order[0] ? d.order[0].dir : "desc",
                            searchValue: d.search ? d.search.value : ""
                        });
                    },
                    "dataSrc": function (json) {
                        console.log("IPD Server response:", json);

                        if (json && json.d) {
                            try {
                                const data = JSON.parse(json.d);
                                console.log("Parsed IPD Data:", data);

                                data.data = data.data.map(item => ({
                                    IPD_ID: item.IPD_ID || '',
                                    AdmissionDate: item.AdmissionDate || null,
                                    Department: item.Department || 'N/A',
                                    WardName: item.WardName || 'N/A',
                                    RoomNo: item.RoomNo || 'N/A',
                                    BedNo: item.BedNo || 'N/A',
                                    AttendingDoctor: item.AttendingDoctor || 'N/A',
                                    ProvisionalDiagnosis: item.ProvisionalDiagnosis || '',
                                    ExpectedDischargeDate: item.ExpectedDischargeDate || null,
                                    DischargeDate: item.DischargeDate || null,
                                    AdmissionType: item.AdmissionType || 'Regular',
                                    Status: item.Status || 'Admitted',
                                    TotalAmount: item.TotalAmount || '0',
                                    ReferringDoctor: item.ReferringDoctor || ''
                                }));

                                return data.data;
                            } catch (e) {
                                console.error("IPD JSON Parse Error:", e);
                                return [];
                            }
                        } else {
                            console.error("Invalid IPD response", json);
                            return [];
                        }
                    },
                    "error": function (xhr, status, error) {
                        console.error("IPD AJAX Error:", status, error);
                        console.error("Response:", xhr.responseText);
                    }
                },
                "columns": [
                    { "data": "IPD_ID", "width": "6%", "orderable": true },
                    {
                        "data": "AdmissionDate",
                        "render": function (data, type) {
                            if (!data || type !== 'display') return data;
                            const m = moment(data);
                            return m.isValid() ? m.format('DD-MMM-YYYY') : 'N/A';
                        },
                        "width": "10%", "orderable": true
                    },
                    { "data": "Department", "width": "12%", "orderable": true, "defaultContent": "N/A" },
                    { "data": "WardName", "width": "10%", "orderable": true, "defaultContent": "N/A" },
                    { "data": "BedNo", "width": "5%", "orderable": false, "defaultContent": "N/A" },
                    { "data": "RoomNo", "width": "6%", "orderable": false, "defaultContent": "N/A" },
                    { "data": "AttendingDoctor", "width": "12%", "orderable": true, "defaultContent": "N/A" },
                    {
                        "data": "Status",
                        "render": function (data, type, row) {
                            var statusClass = '';
                            switch (data) {
                                case 'Admitted': statusClass = 'label-success'; break;
                                case 'Discharged': statusClass = 'label-primary'; break;
                                case 'Deceased': statusClass = 'label-danger'; break;
                                default: statusClass = 'label-default';
                            }
                            return '<span class="label ' + statusClass + '">' + (data || 'Admitted') + '</span>';
                        },
                        "width": "8%", "orderable": true
                    },
                    {
                        "data": "ExpectedDischargeDate",
                        "render": function (data, type) {
                            if (!data || type !== 'display') return data;
                            const m = moment(data);
                            return m.isValid() ? m.format('DD-MMM-YYYY') : 'N/A';
                        },
                        "width": "10%", "orderable": false
                    },
                    {
                        "data": "DischargeDate",
                        "render": function (data, type) {
                            if (!data || type !== 'display') return data;
                            const m = moment(data);
                            return m.isValid() ? m.format('DD-MMM-YYYY') : 'N/A';
                        },
                        "width": "10%", "orderable": false
                    },
                    {
                        "data": null,
                        "render": function (data, type, row) {
                            return `
                        <a class="btn btn-xs btn-primary" style="margin-right:2px" href="#" onclick="PrintIPD(${row.IPD_ID});return false;" title="Print">
                            <i class="fa fa-print"></i>
                        </a>
                        <a class="btn btn-xs btn-success" href="#" onclick="ViewBill(${row.IPD_ID});return false;" title="View Bill">
                            <i class="fa fa-money"></i>
                        </a>`;
                        },
                        "width": "13%", "orderable": false
                    }
                ],
                "order": [[0, "desc"]],
                "pageLength": 25,
                "lengthMenu": [[10, 25, 50, 100], [10, 25, 50, 100]],
                "initComplete": function (settings, json) {
                    const xhr = settings.jqXHR;
                    if (xhr && xhr.responseJSON && xhr.responseJSON.d) {
                        let parsedData;
                        try {
                            parsedData = typeof xhr.responseJSON.d === "string"
                                ? JSON.parse(xhr.responseJSON.d)
                                : xhr.responseJSON.d;

                            const total = parsedData.recordsFiltered || 0;
                            const shouldHideControls = total <= 9;

                            console.log("IPD Records Filtered:", total, "Hide Controls:", shouldHideControls);

                            const $container = $('#tblIPD').closest('.dataTables_wrapper');

                            if (shouldHideControls) {
                                $container.find('.dataTables_paginate, .dataTables_length, .dataTables_info, .dataTables_filter, .dt-buttons').hide();
                            } else {
                                $container.find('.dataTables_paginate, .dataTables_length, .dataTables_info, .dataTables_filter, .dt-buttons').show();
                            }

                            // Customize length dropdown only if controls are shown
                            if (!shouldHideControls) {
                                const $label = $('#tblIPD_length label');
                                const $select = $('#tblIPD_length select');

                                if ($select.length && $label.length && !$label.data('customized')) {
                                    $label.empty()
                                        .append('<span>Show entries </span>')
                                        .append($select)
                                        .data('customized', true);

                                    $select.css('width', '60px');
                                    $label.css({
                                        'display': 'inline-flex',
                                        'alignItems': 'center',
                                        'marginTop': '17px'
                                    });
                                }
                            }
                        } catch (e) {
                            console.error("Error in IPD initComplete:", e);
                        }
                    }
                }
            };

            $("#tblIPD").DataTable(tableOptions);
        }
        function LoadEMERGENCYTable() {
            var ID = $("#hdfReg_ID").val();

            // Destroy existing table if it exists
            if ($.fn.DataTable.isDataTable('#tblEMERGENCY')) {
                $('#tblEMERGENCY').DataTable().destroy();
            }

            let tableOptions = {
                "processing": true,
                "serverSide": true,
                "filter": true,
                "dom": 'Bfrtip',
                "buttons": ['copy', 'excel', 'pdf'],
                "lengthChange": true,
                "ajax": {
                    "url": "NewEMR.aspx/EMERGENCYViewList",
                    "type": "POST",
                    "contentType": "application/json; charset=utf-8",
                    "dataType": "json",
                    "data": function (d) {
                        return JSON.stringify({
                            regID: parseInt(ID) || 0,
                            draw: d.draw,
                            start: d.start,
                            length: d.length,
                            sortColumn: d.columns && d.order && d.order[0] ? d.columns[d.order[0].column].data : "",
                            sortColumnDirection: d.order && d.order[0] ? d.order[0].dir : "desc",
                            searchValue: d.search ? d.search.value : ""
                        });
                    },
                    "dataSrc": function (json) {
                        console.log("EMERGENCY Server response:", json);

                        if (json && json.d) {
                            try {
                                const data = JSON.parse(json.d);
                                console.log("Parsed EMERGENCY Data:", data);

                                data.data = data.data.map(item => ({
                                    EMERGENCY_ID: item.EMERGENCY_ID || '',
                                    AdmissionDate: item.AdmissionDate || null,
                                    WardName: item.WardName || 'N/A',
                                    BedNo: item.BedNo || 'N/A',
                                    AttendingDoctor: item.AttendingDoctor || 'N/A',
                                    DischargeDate: item.DischargeDate || null,
                                    Status: item.Status || 'Admitted'
                                }));

                                return data.data;
                            } catch (e) {
                                console.error("EMERGENCY JSON Parse Error:", e);
                                return [];
                            }
                        } else {
                            console.error("Invalid EMERGENCY response", json);
                            return [];
                        }
                    },
                    "error": function (xhr, status, error) {
                        console.error("EMERGENCY AJAX Error:", status, error);
                        console.error("Response:", xhr.responseText);
                    }
                },
                "columns": [
                    { "data": "EMERGENCY_ID", "width": "6%", "orderable": true },
                    {
                        "data": "AdmissionDate",
                        "render": function (data, type) {
                            if (!data || type !== 'display') return data;
                            const m = moment(data);
                            return m.isValid() ? m.format('DD-MMM-YYYY') : 'N/A';
                        },
                        "width": "10%", "orderable": true
                    },
                    { "data": "WardName", "width": "10%", "orderable": true, "defaultContent": "N/A" },
                    { "data": "BedNo", "width": "5%", "orderable": false, "defaultContent": "N/A" },
                    { "data": "AttendingDoctor", "width": "12%", "orderable": true, "defaultContent": "N/A" },
                    {
                        "data": "Status",
                        "render": function (data, type, row) {
                            var statusClass = '';
                            switch (data) {
                                case 'Admitted': statusClass = 'label-success'; break;
                                case 'Discharged': statusClass = 'label-primary'; break;
                                case 'Deceased': statusClass = 'label-danger'; break;
                                default: statusClass = 'label-default';
                            }
                            return '<span class="label ' + statusClass + '">' + (data || 'Admitted') + '</span>';
                        },
                        "width": "8%", "orderable": true
                    },
                    {
                        "data": "DischargeDate",
                        "render": function (data, type) {
                            if (!data || type !== 'display') return data;
                            const m = moment(data);
                            return m.isValid() ? m.format('DD-MMM-YYYY') : 'N/A';
                        },
                        "width": "10%", "orderable": false
                    },
                    {
                        "data": null,
                        "render": function (data, type, row) {
                            return `
                        <a class="btn btn-xs btn-primary" style="margin-right:2px" href="#" onclick="PrintEMERGENCY(${row.EMERGENCY_ID});return false;" title="Print">
                            <i class="fa fa-print"></i>
                        </a>`;
                        },
                        "width": "13%", "orderable": false
                    }
                ],
                "order": [[0, "desc"]],
                "pageLength": 25,
                "lengthMenu": [[10, 25, 50, 100], [10, 25, 50, 100]],
                "initComplete": function (settings, json) {
                    const xhr = settings.jqXHR;
                    if (xhr && xhr.responseJSON && xhr.responseJSON.d) {
                        let parsedData;
                        try {
                            parsedData = typeof xhr.responseJSON.d === "string"
                                ? JSON.parse(xhr.responseJSON.d)
                                : xhr.responseJSON.d;

                            const total = parsedData.recordsFiltered || 0;
                            const shouldHideControls = total <= 9;

                            console.log("EMERGENCY Records Filtered:", total, "Hide Controls:", shouldHideControls);

                            const $container = $('#tblEMERGENCY').closest('.dataTables_wrapper');

                            if (shouldHideControls) {
                                $container.find('.dataTables_paginate, .dataTables_length, .dataTables_info, .dataTables_filter, .dt-buttons').hide();
                            } else {
                                $container.find('.dataTables_paginate, .dataTables_length, .dataTables_info, .dataTables_filter, .dt-buttons').show();
                            }

                            // Customize length dropdown only if shown
                            if (!shouldHideControls) {
                                const $label = $('#tblEMERGENCY_length label');
                                const $select = $('#tblEMERGENCY_length select');

                                if ($select.length && $label.length && !$label.data('customized')) {
                                    $label.empty()
                                        .append('<span>Show entries </span>')
                                        .append($select)
                                        .data('customized', true);

                                    $select.css('width', '60px');
                                    $label.css({
                                        'display': 'inline-flex',
                                        'alignItems': 'center',
                                        'marginTop': '17px'
                                    });
                                }
                            }
                        } catch (e) {
                            console.error("Error in EMERGENCY initComplete:", e);
                        }
                    }
                }
            };

            $("#tblEMERGENCY").DataTable(tableOptions);
        }
        function LoadMedicineTable() {
            var ID = $("#hdfReg_ID").val();

            if ($.fn.DataTable.isDataTable('#tblMedicene')) {
                $('#tblMedicene').DataTable().destroy();
            }

            let tableOptions = {
                "processing": true,
                "serverSide": true,
                "filter": true,
                "dom": 'Bfrtip',
                "buttons": ['copy', 'excel', 'pdf'],
                "lengthChange": true,
                "ajax": {
                    "url": "NewEMR.aspx/MedicineViewList",
                    "type": "POST",
                    "contentType": "application/json; charset=utf-8",
                    "dataType": "json",
                    "data": function (d) {
                        return JSON.stringify({
                            regID: ID,
                            draw: d.draw,
                            start: d.start,
                            length: d.length,
                            sortColumn: d.columns && d.order && d.order[0] ? d.columns[d.order[0].column].data : "",
                            sortColumnDirection: d.order && d.order[0] ? d.order[0].dir : "desc",
                            searchValue: d.search ? d.search.value : ""
                        });
                    },
                    "dataSrc": function (json) {
                        console.log("Medicine Response:", json);
                        if (json && json.d) {
                            try {
                                const data = JSON.parse(json.d);
                                console.log("Parsed Medicine Data:", data);

                                data.data = data.data.map(item => ({
                                    MedicineID: item.MedicineID || '',
                                    MedicineName: item.MedicineName || 'N/A',
                                    Dosage: item.Dosage || 'N/A',
                                    Form: item.Form || 'N/A',
                                    Route: item.Route || 'N/A',
                                    Duration: item.Duration || 'N/A',
                                    Frequency: item.Frequency || 'N/A',
                                    PrescriptionDate: item.PrescriptionDate || null,
                                    Instructions: item.Instructions || 'N/A'
                                }));

                                return data.data;
                            } catch (e) {
                                console.error("Medicine JSON Parse Error:", e);
                                return [];
                            }
                        }
                        return [];
                    },
                    "error": function (xhr, status, error) {
                        console.error("Medicine AJAX Error:", status, error);
                    }
                },
                "columns": [
                    {
                        "data": "MedicineName",
                        "width": "15%",
                        "orderable": false
                    },
                    {
                        "data": "PrescriptionDate",
                        "render": function (data, type) {
                            if (!data || type !== 'display') return data;
                            const m = moment(data);
                            return m.isValid() ? m.format('DD-MMM-YYYY') : 'N/A';
                        },
                        "width": "12%",
                        "orderable": true
                    },
                    {
                        "data": null,
                        "render": function (data, type, row) {
                            return `${row.Dosage || 'N/A'} - ${row.Form || 'N/A'}`;
                        },
                        "width": "12%",
                        "orderable": false
                    },
                    { "data": "Route", "width": "8%", "orderable": false },
                    { "data": "Duration", "width": "8%", "orderable": false },
                    { "data": "Frequency", "width": "10%", "orderable": false },
                    { "data": "Instructions", "width": "20%", "orderable": false }
                ],
                "order": [[1, "desc"]],
                "pageLength": 25,
                "lengthMenu": [[10, 25, 50, 100], [10, 25, 50, 100]],
                "initComplete": function (settings, json) {
                    const xhr = settings.jqXHR;
                    if (xhr && xhr.responseJSON && xhr.responseJSON.d) {
                        let parsedData;
                        try {
                            parsedData = typeof xhr.responseJSON.d === "string"
                                ? JSON.parse(xhr.responseJSON.d)
                                : xhr.responseJSON.d;

                            const total = parsedData.recordsFiltered || 0;
                            const shouldHideControls = total <= 9;

                            console.log("Medicine Records:", total, "Hide Controls:", shouldHideControls);

                            const $container = $('#tblMedicene').closest('.dataTables_wrapper');

                            if (shouldHideControls) {
                                $container.find('.dataTables_paginate, .dataTables_length, .dataTables_info, .dataTables_filter, .dt-buttons').hide();
                            } else {
                                $container.find('.dataTables_paginate, .dataTables_length, .dataTables_info, .dataTables_filter, .dt-buttons').show();
                            }

                            if (!shouldHideControls) {
                                const $label = $('#tblMedicene_length label');
                                const $select = $('#tblMedicene_length select');

                                if ($select.length && $label.length && !$label.data('customized')) {
                                    $label.empty()
                                        .append('<span>Show entries </span>')
                                        .append($select)
                                        .data('customized', true);

                                    $select.css('width', '60px');
                                    $label.css({
                                        'display': 'inline-flex',
                                        'alignItems': 'center',
                                        'marginTop': '17px'
                                    });
                                }
                            }
                        } catch (e) {
                            console.error("Error in Medicine initComplete:", e);
                        }
                    }
                }
            };

            $("#tblMedicene").DataTable(tableOptions);
        }
        function LoadInvestigationTable() {
            var ID = $("#hdfReg_ID").val();

            if ($.fn.DataTable.isDataTable('#tblInvestigation')) {
                $('#tblInvestigation').DataTable().destroy();
            }

            let tableOptions = {
                "processing": true,
                "serverSide": true,
                "filter": true,
                "dom": 'Bfrtip',
                "buttons": ['copy', 'excel', 'pdf'],
                "lengthChange": true,
                "ajax": {
                    "url": "NewEMR.aspx/InvestigationViewList",
                    "type": "POST",
                    "contentType": "application/json; charset=utf-8",
                    "dataType": "json",
                    "data": function (d) {
                        return JSON.stringify({
                            regID: parseInt(ID) || 0,
                            draw: d.draw,
                            start: d.start,
                            length: d.length,
                            sortColumn: d.columns && d.order && d.order[0] ? d.columns[d.order[0].column].data : "",
                            sortColumnDirection: d.order && d.order[0] ? d.order[0].dir : "desc",
                            searchValue: d.search ? d.search.value : ""
                        });
                    },
                    "dataSrc": function (json) {
                        console.log("Investigation Response:", json);
                        if (json && json.d) {
                            try {
                                const data = JSON.parse(json.d);
                                console.log("Parsed Investigation Data:", data);

                                data.data = data.data.map(item => ({
                                    Lab_Test_Detail_ID: item.Lab_Test_Detail_ID || '',
                                    Date: item.Date || null,
                                    Test_Name: item.Test_Name || 'N/A',
                                    DoctorName: item.DoctorName || 'N/A',
                                    Special_Tests: item.Special_Tests || 'N/A',
                                    Area_Of_Interest: item.Area_Of_Interest || 'N/A',
                                    Remark: item.Remark || 'N/A'
                                }));

                                return data.data;
                            } catch (e) {
                                console.error("Investigation JSON Parse Error:", e);
                                return [];
                            }
                        }
                        return [];
                    },
                    "error": function (xhr, status, error) {
                        console.error("Investigation AJAX Error:", status, error);
                    }
                },
                "columns": [
                    { "data": "Lab_Test_Detail_ID", "width": "6%", "orderable": true },
                    { "data": "Test_Name", "width": "20%", "orderable": true },
                    {
                        "data": "Date",
                        "render": function (data, type) {
                            if (!data || type !== 'display') return data;
                            const m = moment(data);
                            return m.isValid() ? m.format('DD-MMM-YYYY') : 'N/A';
                        },
                        "width": "10%",
                        "orderable": true
                    },
                    { "data": "Special_Tests", "width": "15%", "orderable": true },
                    { "data": "Area_Of_Interest", "width": "15%", "orderable": true },
                    { "data": "Remark", "width": "15%", "orderable": false }
                ],
                "order": [[2, "desc"]],
                "pageLength": 25,
                "lengthMenu": [[10, 25, 50, 100], [10, 25, 50, 100]],
                "initComplete": function (settings, json) {
                    const xhr = settings.jqXHR;
                    if (xhr && xhr.responseJSON && xhr.responseJSON.d) {
                        let parsedData;
                        try {
                            parsedData = typeof xhr.responseJSON.d === "string"
                                ? JSON.parse(xhr.responseJSON.d)
                                : xhr.responseJSON.d;

                            const total = parsedData.recordsFiltered || 0;
                            const shouldHideControls = total <= 9;

                            console.log("Investigation Records:", total, "Hide Controls:", shouldHideControls);

                            const $container = $('#tblInvestigation').closest('.dataTables_wrapper');

                            if (shouldHideControls) {
                                $container.find('.dataTables_paginate, .dataTables_length, .dataTables_info, .dataTables_filter, .dt-buttons').hide();
                            } else {
                                $container.find('.dataTables_paginate, .dataTables_length, .dataTables_info, .dataTables_filter, .dt-buttons').show();
                            }

                            if (!shouldHideControls) {
                                const $label = $('#tblInvestigation_length label');
                                const $select = $('#tblInvestigation_length select');

                                if ($select.length && $label.length && !$label.data('customized')) {
                                    $label.empty()
                                        .append('<span>Show entries </span>')
                                        .append($select)
                                        .data('customized', true);

                                    $select.css('width', '60px');
                                    $label.css({
                                        'display': 'inline-flex',
                                        'alignItems': 'center',
                                        'marginTop': '17px'
                                    });
                                }
                            }
                        } catch (e) {
                            console.error("Error in Investigation initComplete:", e);
                        }
                    }
                }
            };

            $("#tblInvestigation").DataTable(tableOptions);
        }
        function LoadDiagnosticsTable() {
            var ID = $("#hdfReg_ID").val();

            if ($.fn.DataTable.isDataTable('#tblDiagnostics')) {
                $('#tblDiagnostics').DataTable().destroy();
            }

            let tableOptions = {
                "processing": true,
                "serverSide": true,
                "filter": true,
                "dom": 'Bfrtip',
                "buttons": ['copy', 'excel', 'pdf', 'print'],
                "lengthChange": true,
                "ajax": {
                    "url": "NewEMR.aspx/DiagnosticsViewList",
                    "type": "POST",
                    "contentType": "application/json; charset=utf-8",
                    "dataType": "json",
                    "data": function (d) {
                        return JSON.stringify({
                            regID: parseInt(ID) || 0,
                            draw: d.draw,
                            start: d.start,
                            length: d.length,
                            sortColumn: d.columns && d.order && d.order[0] ? d.columns[d.order[0].column].data : "",
                            sortColumnDirection: d.order && d.order[0] ? d.order[0].dir : "desc",
                            searchValue: d.search ? d.search.value : ""
                        });
                    },
                    "dataSrc": function (json) {
                        console.log("Diagnostics Response:", json);
                        if (json && json.d) {
                            try {
                                const data = JSON.parse(json.d);
                                console.log("Parsed Diagnostics Data:", data);

                                data.data = data.data.map(item => ({
                                    Lab_Test_Detail_ID: item.Lab_Test_Detail_ID || '',
                                    Date: item.Date || null,
                                    Test_Name: item.Test_Name || 'N/A',
                                    DoctorName: item.DoctorName || 'N/A',
                                    Special_Tests: item.Special_Tests || 'N/A',
                                    Area_Of_Interest: item.Area_Of_Interest || 'N/A',
                                    Department: item.Department || 'N/A',
                                    Rotation: item.Rotation || 'N/A',
                                    Remark: item.Remark || 'N/A'
                                }));

                                return data.data;
                            } catch (e) {
                                console.error("Diagnostics JSON Parse Error:", e);
                                return [];
                            }
                        }
                        return [];
                    },
                    "error": function (xhr, status, error) {
                        console.error("Diagnostics AJAX Error:", status, error);
                    }
                },
                "columns": [
                    { "data": "Lab_Test_Detail_ID", "width": "5%", "orderable": true },
                    { "data": "Test_Name", "width": "15%", "orderable": true },
                    { "data": "Department", "width": "12%", "orderable": true },
                    {
                        "data": "Date",
                        "render": function (data, type) {
                            if (!data || type !== 'display') return data;
                            const m = moment(data);
                            return m.isValid() ? m.format('DD-MMM-YYYY') : 'N/A';
                        },
                        "width": "8%",
                        "orderable": true
                    },
                    { "data": "Special_Tests", "width": "10%", "orderable": false },
                    { "data": "Area_Of_Interest", "width": "10%", "orderable": false },
                    { "data": "Rotation", "width": "12%", "orderable": true },
                    { "data": "Remark", "width": "10%", "orderable": false }
                ],
                "order": [[3, "desc"]],
                "pageLength": 25,
                "lengthMenu": [[10, 25, 50, 100], [10, 25, 50, 100]],
                "language": {
                    "emptyTable": "No diagnostic tests found for this patient",
                    "zeroRecords": "No matching diagnostic tests found"
                },
                "initComplete": function (settings, json) {
                    const xhr = settings.jqXHR;
                    if (xhr && xhr.responseJSON && xhr.responseJSON.d) {
                        let parsedData;
                        try {
                            parsedData = typeof xhr.responseJSON.d === "string"
                                ? JSON.parse(xhr.responseJSON.d)
                                : xhr.responseJSON.d;

                            const total = parsedData.recordsFiltered || 0;
                            const shouldHideControls = total <= 9;

                            console.log("Diagnostics Records:", total, "Hide Controls:", shouldHideControls);

                            const $container = $('#tblDiagnostics').closest('.dataTables_wrapper');

                            if (shouldHideControls) {
                                $container.find('.dataTables_paginate, .dataTables_length, .dataTables_info, .dataTables_filter, .dt-buttons').hide();
                            } else {
                                $container.find('.dataTables_paginate, .dataTables_length, .dataTables_info, .dataTables_filter, .dt-buttons').show();
                            }

                            if (!shouldHideControls) {
                                const $label = $('#tblDiagnostics_length label');
                                const $select = $('#tblDiagnostics_length select');

                                if ($select.length && $label.length && !$label.data('customized')) {
                                    $label.empty()
                                        .append('<span>Show entries </span>')
                                        .append($select)
                                        .data('customized', true);

                                    $select.css('width', '60px');
                                    $label.css({
                                        'display': 'inline-flex',
                                        'alignItems': 'center',
                                        'marginTop': '17px'
                                    });
                                }
                            }
                        } catch (e) {
                            console.error("Error in Diagnostics initComplete:", e);
                        }
                    }
                }
            };

            $("#tblDiagnostics").DataTable(tableOptions);
        }
        function LoadPatientServicesTable() {
            var ID = $("#hdfReg_ID").val();

            // Destroy existing table if it exists
            if ($.fn.DataTable.isDataTable('#tblPatientServices')) {
                $('#tblPatientServices').DataTable().destroy();
            }

            $("#tblPatientServices").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": {
                    "url": "NewEMR.aspx/PatientServicesViewList",
                    "type": "POST",
                    "contentType": "application/json; charset=utf-8",
                    "dataType": "json",
                    "data": function (d) {
                        return JSON.stringify({
                            regID: parseInt(ID) || 0,
                            draw: d.draw,
                            start: d.start,
                            length: d.length,
                            sortColumn: d.columns && d.order && d.order[0] ? d.columns[d.order[0].column].data : "",
                            sortColumnDirection: d.order && d.order[0] ? d.order[0].dir : "desc",
                            searchValue: d.search ? d.search.value : ""
                        });
                    },
                    "dataSrc": function (json) {
                        console.log("Server response:", json); // Debug log

                        if (json.d) {
                            // Ensure all required properties exist
                            var result = {
                                draw: json.d.draw || 0,
                                recordsTotal: json.d.recordsTotal || 0,
                                recordsFiltered: json.d.recordsFiltered || 0,
                                data: json.d.data || []
                            };

                            // Handle null values in the response
                            result.data = result.data.map(function (item) {
                                return {
                                    ServicesId: item.ServicesId || '',
                                    ServiceName: item.ServiceName || 'N/A',
                                    ServiceType: item.ServiceType || 'N/A',
                                    Amount: item.Amount || '0.00',
                                    PatientType: item.PatientType || 'N/A',
                                    CreatedDate: item.CreatedDate || '',
                                    UserName: item.UserName || 'N/A',
                                    IsBilled: item.IsBilled || 'Not Billed'
                                };
                            });

                            // Set the values for DataTables
                            this.recordsTotal = result.recordsTotal;
                            this.recordsFiltered = result.recordsFiltered;

                            return result.data;
                        } else if (json.error) {
                            console.error("Server error:", json.error);
                            return [];
                        }
                        return [];
                    },
                    "error": function (xhr, status, error) {
                        console.error("AJAX Error:", status, error);
                        console.error("Response:", xhr.responseText);
                    }
                },
                "columns": [
                    {
                        "data": "ServicesId",
                        "name": "ServicesId",
                        "width": "8%",
                        "orderable": true
                    },
                    {
                        "data": "ServiceName",
                        "name": "ServiceName",
                        "width": "20%",
                        "orderable": true,
                        "defaultContent": "N/A"
                    },
                    {
                        "data": "ServiceType",
                        "name": "ServiceType",
                        "width": "12%",
                        "orderable": true,
                        "defaultContent": "N/A"
                    },
                    {
                        "data": "Amount",
                        "name": "Amount",
                        "render": function (data) {
                            if (!data || data === '0.00') return '0.00';
                            // Ensure proper currency formatting
                            var amount = parseFloat(data.replace(/,/g, ''));
                            return isNaN(amount) ? '0.00' : amount.toFixed(2);
                        },
                        "width": "10%",
                        "orderable": true,
                        "className": "text-right" // Right align for currency
                    },
                    {
                        "data": "PatientType",
                        "name": "PatientType",
                        "width": "12%",
                        "orderable": true,
                        "defaultContent": "N/A"
                    },
                    {
                        "data": "CreatedDate",
                        "name": "CreatedDate",
                        "render": function (data) {
                            if (!data) return '';
                            // Handle different date formats
                            var date = moment(data);
                            return date.isValid() ? date.format('DD-MMM-YYYY') : data;
                        },
                        "width": "12%",
                        "orderable": true
                    },
                    {
                        "data": "UserName",
                        "name": "UserName",
                        "width": "12%",
                        "orderable": true,
                        "defaultContent": "N/A"
                    },
                    {
                        "data": "IsBilled",
                        "name": "IsBilled",
                        "render": function (data) {
                            // Add styling based on billing status
                            if (data === 'Billed') {
                                return '<span class="badge badge-success">' + data + '</span>';
                            } else {
                                return '<span class="badge badge-warning">' + data + '</span>';
                            }
                        },
                        "width": "10%",
                        "orderable": true,
                        "defaultContent": "Not Billed"
                    },

                ],
                "initComplete": function (settings, json) {
                    var lengthContainer = document.querySelector('#tblPatientServices_length');
                    var lengthDropdown = document.querySelector('#tblPatientServices_length select');
                    var label = document.querySelector('#tblPatientServices_length label');

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
                    } else {
                        console.log("Length dropdown, label, or container not found");
                    }
                }
            });
        }
        function LoadPatientComplaintsTable() {
            var ID = $("#hdfReg_ID").val();

            if ($.fn.DataTable.isDataTable('#tblPatientComplaints')) {
                $('#tblPatientComplaints').DataTable().destroy();
            }

            $("#tblPatientComplaints").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": {
                    "url": "NewEMR.aspx/PatientComplaintsViewList",
                    "type": "POST",
                    "contentType": "application/json; charset=utf-8",
                    "dataType": "json",
                    "data": function (d) {
                        return JSON.stringify({
                            regID: parseInt(ID) || 0,
                            draw: d.draw,
                            start: d.start,
                            length: d.length,
                            sortColumn: d.columns && d.order && d.order[0] ? d.columns[d.order[0].column].data : "",
                            sortColumnDirection: d.order && d.order[0] ? d.order[0].dir : "desc",
                            searchValue: d.search ? d.search.value : ""
                        });
                    },
                    "dataSrc": function (json) {
                        console.log("Final Diagnosis response:", json);
                        if (json.d) {
                            var result = {
                                draw: json.d.draw || 0,
                                recordsTotal: json.d.recordsTotal || 0,
                                recordsFiltered: json.d.recordsFiltered || 0,
                                data: json.d.data || []
                            };
                            this.recordsTotal = result.recordsTotal;
                            this.recordsFiltered = result.recordsFiltered;
                            return result.data;
                        }
                        return [];
                    },
                    "error": function (xhr, status, error) {
                        console.error("Final Diagnosis AJAX Error:", status, error);
                    }
                },
                "columns": [
                    { "data": "ComplaintName", "width": "35%", "orderable": true, "defaultContent": "N/A" },
                    { "data": "Remarks", "width": "25%", "orderable": true, "defaultContent": "" },

                ]
            });
        }
        function LoadPatientSymptomsTable() {
            var ID = $("#hdfReg_ID").val();

            if ($.fn.DataTable.isDataTable('#tblPatientSymptoms')) {
                $('#tblPatientSymptoms').DataTable().destroy();
            }

            $("#tblPatientSymptoms").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": {
                    "url": "NewEMR.aspx/PatientSymptomsViewList",
                    "type": "POST",
                    "contentType": "application/json; charset=utf-8",
                    "dataType": "json",
                    "data": function (d) {
                        return JSON.stringify({
                            regID: parseInt(ID) || 0,
                            draw: d.draw,
                            start: d.start,
                            length: d.length,
                            sortColumn: d.columns && d.order && d.order[0] ? d.columns[d.order[0].column].data : "",
                            sortColumnDirection: d.order && d.order[0] ? d.order[0].dir : "desc",
                            searchValue: d.search ? d.search.value : ""
                        });
                    },
                    "dataSrc": function (json) {
                        console.log("Symptoms response:", json);
                        if (json.d) {
                            var result = {
                                draw: json.d.draw || 0,
                                recordsTotal: json.d.recordsTotal || 0,
                                recordsFiltered: json.d.recordsFiltered || 0,
                                data: json.d.data || []
                            };
                            this.recordsTotal = result.recordsTotal;
                            this.recordsFiltered = result.recordsFiltered;
                            return result.data;
                        }
                        return [];
                    },
                    "error": function (xhr, status, error) {
                        console.error("Symptoms AJAX Error:", status, error);
                    }
                },
                "columns": [
                    { "data": "SymptomName", "width": "25%", "orderable": true, "defaultContent": "N/A" },
                    { "data": "Duration", "width": "10%", "orderable": true },
                    { "data": "DurationUnit", "width": "12%", "orderable": true, "defaultContent": "N/A" },
                    { "data": "PatientType", "width": "12%", "orderable": true },
                    { "data": "Remarks", "width": "15%", "orderable": true, "defaultContent": "" },

                ]
            });
        }
        function LoadPrimaryDiagnosisTable() {
            var ID = $("#hdfReg_ID").val();

            if ($.fn.DataTable.isDataTable('#tblPrimaryDiagnosis')) {
                $('#tblPrimaryDiagnosis').DataTable().destroy();
            }

            $("#tblPrimaryDiagnosis").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": {
                    "url": "NewEMR.aspx/PrimaryDiagnosisViewList",
                    "type": "POST",
                    "contentType": "application/json; charset=utf-8",
                    "dataType": "json",
                    "data": function (d) {
                        return JSON.stringify({
                            regID: parseInt(ID) || 0,
                            draw: d.draw,
                            start: d.start,
                            length: d.length,
                            sortColumn: d.columns && d.order && d.order[0] ? d.columns[d.order[0].column].data : "",
                            sortColumnDirection: d.order && d.order[0] ? d.order[0].dir : "desc",
                            searchValue: d.search ? d.search.value : ""
                        });
                    },
                    "dataSrc": function (json) {
                        console.log("Primary Diagnosis response:", json);
                        if (json.d) {
                            var result = {
                                draw: json.d.draw || 0,
                                recordsTotal: json.d.recordsTotal || 0,
                                recordsFiltered: json.d.recordsFiltered || 0,
                                data: json.d.data || []
                            };
                            this.recordsTotal = result.recordsTotal;
                            this.recordsFiltered = result.recordsFiltered;
                            return result.data;
                        }
                        return [];
                    },
                    "error": function (xhr, status, error) {
                        console.error("Primary Diagnosis AJAX Error:", status, error);
                    }
                },
                "columns": [
                    { "data": "DiagnosisName", "width": "35%", "orderable": true, "defaultContent": "N/A" },
                    { "data": "Remarks", "width": "25%", "orderable": true, "defaultContent": "" },

                ]
            });
        }
        function LoadFinalDiagnosisTable() {
            var ID = $("#hdfReg_ID").val();

            if ($.fn.DataTable.isDataTable('#tblFinalDiagnosis')) {
                $('#tblFinalDiagnosis').DataTable().destroy();
            }

            $("#tblFinalDiagnosis").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": {
                    "url": "NewEMR.aspx/FinalDiagnosisViewList",
                    "type": "POST",
                    "contentType": "application/json; charset=utf-8",
                    "dataType": "json",
                    "data": function (d) {
                        return JSON.stringify({
                            regID: parseInt(ID) || 0,
                            draw: d.draw,
                            start: d.start,
                            length: d.length,
                            sortColumn: d.columns && d.order && d.order[0] ? d.columns[d.order[0].column].data : "",
                            sortColumnDirection: d.order && d.order[0] ? d.order[0].dir : "desc",
                            searchValue: d.search ? d.search.value : ""
                        });
                    },
                    "dataSrc": function (json) {
                        console.log("Primary Diagnosis response:", json);
                        if (json.d) {
                            var result = {
                                draw: json.d.draw || 0,
                                recordsTotal: json.d.recordsTotal || 0,
                                recordsFiltered: json.d.recordsFiltered || 0,
                                data: json.d.data || []
                            };
                            this.recordsTotal = result.recordsTotal;
                            this.recordsFiltered = result.recordsFiltered;
                            return result.data;
                        }
                        return [];
                    },
                    "error": function (xhr, status, error) {
                        console.error("Primary Diagnosis AJAX Error:", status, error);
                    }
                },
                "columns": [
                    { "data": "DiagnosisName", "width": "35%", "orderable": true, "defaultContent": "N/A" },
                    { "data": "Remarks", "width": "25%", "orderable": true, "defaultContent": "" },

                ]
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <input type="hidden" id="hdfPatient_ID" />
    <input type="hidden" id="hdfReg_ID" />
    <input type="hidden" id="hdfoutPatID" />
    <div class="row">
        <div id="retract" class="col-lg-2">
            <div class="sidebarr">
                <div class="menu-item no-submenu" id="01" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/complaints.png" alt="Profile Picture" class="sidebarIcon">
                        <span>OPD</span>
                    </div>
                </div>
                <div class="menu-item no-submenu" id="02" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/symptoms.png" alt="Profile Picture" class="sidebarIcon">
                        <span>IPD</span>
                    </div>
                </div>
                <div class="menu-item no-submenu" id="03" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/vitals.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Emergency</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="04" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/history.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Medication</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="05" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/examination.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Investigation</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="06" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/refer.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Diagnostics</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="07" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/primarydiagnosis.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Procedures</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="08" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/finaldiagnosis.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Symptoms</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="09" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/investigation.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Complaints</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="10" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/diagnostics.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Primary Diagnosis</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="11" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/medication.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Final Diagnosis</span>
                    </div>
                </div>

                 
            </div>
        </div>
        <div class="col-lg-10">

            <div class="row">
                <div class="col-lg-3">
                    <div onclick="toggleRetract()" style="width: fit-content !important;" class="retractIcon">
                        <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/sidebar.png"
                            alt="Sidebar Toggle" class="sidebarToggleIcon" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="search-container">
                        <div class="search-input-wrapper">
                            <input
                                type="text"
                                class="search-input"
                                placeholder="Search for anything..."
                                id="searchInput"
                                autocomplete="off"
                                style="height: 45px; width: 100% !important; padding: 16px 50px 16px 20px !important; border: 1.5px solid #ccc !important; border-radius: 25px !important; background: rgba(255, 255, 255, 0.1) !important; backdrop-filter: blur(10px) !important; color: black !important; font-size: 16px !important; box-shadow: none !important" />
                            <div class="search-icon">🔍</div>
                        </div>
                        <div class="search-results" id="searchResults"></div>
                    </div>
                </div>
                <div class="col-lg-3"></div>
            </div>
            <div id="Information">
                <div class="row">
                    <!-- Left Column: Profile Information -->
                    <div class="col-lg-5 col-md-5 col-sm-5 profile">
                        <div class="card3">
                            <div class="profile-info">
                                <img class="ToBeHidden" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/cake.png" alt="Profile Picture" class="profile-img">
                                <div class="profile-details">
                                    <span class="profile-name" id="patname"></span>
                                    <p><strong class="">MR No:</strong> &nbsp; &nbsp; <span style="font-weight: 500 !important" id="mrno"></span>&nbsp; &nbsp; &nbsp; <strong class="">Age:</strong> &nbsp; &nbsp; <span style="font-weight: 500 !important" id="txtage"></span>&nbsp;&nbsp;&nbsp; <strong class="">Gender:</strong> &nbsp; &nbsp; <span style="font-weight: 500 !important" id="gender"></span></p>
                                    <p class="ToBeHidden"><strong class="">Phone Number:</strong> &nbsp; &nbsp;&nbsp; <span style="font-weight: 500 !important" id="phonenumber"></span></p>
                                    <p class="ToBeHidden"><strong class="">CNIC:</strong>&nbsp;&nbsp;&nbsp; <span style="font-weight: 500 !important" id="CNIC"></span></p>
                                    <p class="ToBeHidden"><strong class="">Address:</strong> &nbsp;&nbsp;&nbsp;<span style="font-weight: 500 !important" id="address"></span></p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Right Column: Appointment Information -->
                    <div class="col-lg-6 col-md-6 col-sm-6 ToBeHidden">
                        <div class="appointmentcard">
                            <div class="appointment-info">
                                <h5 style="margin-right: 45px; font-size: 1.3em">
                                    <strong class="">Upcoming Appointment</strong>

                                </h5>
                                <span class="badge" style="cursor: pointer;"><span id="appdate">Appointment Date</span></span>
                                <h5 style="margin-left: 45px"><strong class="">Consultation with &nbsp;<span id="doctorname"></span></strong></h5>
                            </div>

                            <div class="appointment-details">
                                <div class="row-details">
                                    <p><strong class="labelcolor">Last Visit:&nbsp;</strong><span id="prv_visit"></span></p>
                                    <p><strong class="labelcolor">Doctor Name:&nbsp;</strong><span id="prvDoctor"></span></p>
                                    <p><strong class="labelcolor">Department:&nbsp;</strong><span id="Department"></span></p>
                                </div>
                            </div>

                        </div>
                    </div>
                </div>
                <div class="digital-stats-container ToBeHidden">
                    <div class="digital-stats-row">
                        <div class="digital-stat">
                            <span class="stat-label">OPD Visits:</span>
                            <span class="digital-number" id="opdVisits">--</span>
                        </div>
                        <div class="digital-stat">
                            <span class="stat-label">IPD Visits:</span>
                            <span class="digital-number" id="ipdVisits">--</span>
                        </div>
                        <div class="digital-stat">
                            <span class="stat-label">Emergency:</span>
                            <span class="digital-number" id="emergencyVisits">--</span>
                        </div>
                        <div class="digital-stat">
                            <span class="stat-label">Medication:</span>
                            <span class="digital-number" id="medicationCount">--</span>
                        </div>
                        <div class="digital-stat">
                            <span class="stat-label">Investigation:</span>
                            <span class="digital-number" id="investigationCount">--</span>
                        </div>
                        <div class="digital-stat">
                            <span class="stat-label">Diagnostics:</span>
                            <span class="digital-number" id="diagnosticsCount">--</span>
                        </div>
                        <div class="digital-stat">
                            <span class="stat-label">Procedures:</span>
                            <span class="digital-number" id="proceduresCount">--</span>
                        </div>
                    </div>
                </div>
                <div class="hr-with-arrow">
                    <hr />
                    <a onclick="toggleInfo()" class="arrow-button">
                        <i class="fa fa-chevron-down"></i>
                    </a>
                </div>
            </div>
            <h2 class="header mybutton"></h2>
            <div id="tab01" style="display:none" class="tabs">
                <div class="table-container col-lg-12 col-md-12 col-sm-10">
                    <table class="table modern-table" id="tblOPD">
                        <thead id="OPDhead">
                            <tr>
                                <th>Visit No.</th>
                                <th>Date</th>
                                <th>Department</th>
                                <th>Patient Type</th>
                                <th>Checked By</th>
                                <th>Status</th>
                                <th>Discharged Date</th>
                                <th>Remarks</th>
                                <th>Preview</th>
                            </tr>
                        </thead>
                        <tbody id="OPDbody">
                        </tbody>
                    </table>
                </div>
            </div>
            <div id="tab02" style="display: none" class="tabs">

                <div class="table-responsive">
                    <table id="tblIPD" class="  table modern-table" style="width: 100%">
                        <thead>
                            <tr>
                                <th>IPD ID</th>
                                <th>Admission Date</th>
                                <th>Department</th>
                                <th>Ward</th>

                                <th>Bed</th>
                                <th>Room</th>
                                <th>Doctor</th>
                                <th>Status</th>
                                <th>Expected Discharge</th>
                                <th>Discharge Date</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <!-- Data will be populated by DataTables -->
                        </tbody>
                    </table>
                </div>
            </div>
            <div id="tab03" style="display: none" class="tabs">

                <div class="table-responsive">
                    <table id="tblEMERGENCY" class="table modern-table" style="width: 100%">
                        <thead>
                            <tr>
                                <th>Emergency ID</th>
                                <th>Admission Date</th>
                                <th>Ward</th>
                                <th>Bed</th>
                                <th>Doctor</th>
                                <th>Status</th>
                                <th>Discharge Date</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <!-- Data will be populated by DataTables -->
                        </tbody>
                    </table>
                </div>
            </div>
            <div id="tab04" style="display: none" class="tabs">

                <div class="table-responsive">
                    <table id="tblMedicene" class="table modern-table" style="width: 100%">
                        <thead>
                            <tr>
                                <th>Medicene Name</th>
                                <th>Prescription Date</th>
                                <th>Dosage</th>
                                <th>Route</th>
                                <th>Duration</th>
                                <th>Frequency</th>
                                <th>Instructions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <!-- Data will be populated by DataTables -->
                        </tbody>
                    </table>
                </div>
            </div>
            <div id="tab05" style="display: none" class="tabs">

                <div class="table-responsive">
                    <table id="tblInvestigation" class="table modern-table" style="width: 100%">
                        <thead>
                            <tr>
                                <th>Lab Test ID</th>
                                <th>Test Name</th>
                                <th>Date</th>
                                <th>Special Test</th>
                                <th>Area of Interest</th>
                                <th>Remarks</th>
                            </tr>
                        </thead>
                        <tbody>
                            <!-- Data will be populated by DataTables -->
                        </tbody>
                    </table>
                </div>
            </div>
            <div id="tab06" style="display: none" class="tabs">

                <div class="table-responsive">
                    <table id="tblDiagnostics" class="table modern-table" style="width: 100%">
                        <thead>
                            <tr>
                                <th>Test ID</th>
                                <th>Test Name</th>
                                <th>Department</th>
                                <th>Date</th>
                                <th>Special Test</th>
                                <th>Area of Interest</th>
                                <th>Rotation</th>
                                <th>Remarks</th>
                            </tr>
                        </thead>
                        <tbody>
                            <!-- Data will be populated by DataTables -->
                        </tbody>
                    </table>
                </div>
            </div>
            <div id="tab07" style="display: none" class="tabs">
                <div class="table-container col-lg-12 col-md-12 col-sm-10">
                    <table class="table modern-table" id="tblPatientServices">
                        <thead id="ServicesHead">
                            <tr>
                                <th>Service ID</th>
                                <th>Service Name</th>
                                <th>Service Type</th>
                                <th>Amount</th>
                                <th>Patient Type</th>
                                <th>Created Date</th>
                                <th>Created By</th>
                                <th>Billing Status</th>
                            </tr>
                        </thead>
                        <tbody id="ServicesBody">
                        </tbody>
                    </table>
                </div>
            </div>
            <div id="tab08" style="display: none" class="tabs">
                <div class="table-container col-lg-12 col-md-12 col-sm-10">
                    <table class="table modern-table" id="tblPatientSymptoms">
                        <thead id="SymptomsHead">
                            <tr>
                                <th>Symptom</th>
                                <th>Duration</th>
                                <th>Duration Unit</th>
                                <th>Patient Type</th>
                                <th>Remarks</th>
                            </tr>
                        </thead>
                        <tbody id="SymptomsBody">
                        </tbody>
                    </table>
                </div>
            </div>
            <div id="tab09" style="display: none" class="tabs">
                <div class="table-container col-lg-12 col-md-12 col-sm-10">
                    <table class="table modern-table" id="tblPatientComplaints">
                        <thead id="ComplaintsHead">
                            <tr>

                                <th>Complaint</th>
                                <th>Remarks</th>
                            </tr>
                        </thead>
                        <tbody id="ComplaintsBody">
                        </tbody>
                    </table>
                </div>
            </div>

            <div id="tab10" style="display: none" class="tabs">
                <div class="table-container col-lg-12 col-md-12 col-sm-10">
                    <table class="table modern-table" id="tblPrimaryDiagnosis">
                        <thead id="PrimaryDiagnosisHead">
                            <tr>
                                <th>Primary Diagnosis</th>
                                <th>Remarks</th>
                            </tr>
                        </thead>
                        <tbody id="PrimaryDiagnosisBody">
                        </tbody>
                    </table>
                </div>
            </div>

            <div id="tab11" style="display: none" class="tabs">
                <div class="table-container col-lg-12 col-md-12 col-sm-10">
                    <table class="table modern-table" id="tblFinalDiagnosis">
                        <thead id="FinalDiagnosisHead">
                            <tr>
                                <th>Final Diagnosis</th>
                                <th>Remarks</th>
                            </tr>
                        </thead>
                        <tbody id="FinalDiagnosisBody">
                        </tbody>
                    </table>
                </div>
            </div>


        </div>
    </div>


</asp:Content>
