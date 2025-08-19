<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="NewEMR.aspx.cs" Inherits="PMS.Modules.Dashboards.NewEMR" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <style id="sidebar">
        .retractIcon {
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 8px;
            border-radius: 50%;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .sidebarToggleIcon {
            width: 24px;
            height: 24px;
            transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
        }

        .retractIcon:hover {
            background-color: rgba(0, 0, 0, 0.1);
            transform: scale(1.1);
        }

            .retractIcon:hover img {
                filter: brightness(0.8) contrast(1.2);
                transform: rotate(10deg);
            }

        .retractIcon:active {
            transform: scale(0.95);
        }

        #retract {
            transition: all 0.5s ease;
            overflow: hidden;
        }

            #retract.minimized {
                width: 100px !important;
            }

                #retract.minimized span {
                    display: none;
                }

        .sidebarr {
            border-right: 1px solid #dee2e6;
            padding: 0;
        }

        .menu-item {
            cursor: pointer;
            padding: 15px 20px;
            border-bottom: 1px solid #dee2e6;
            transition: background-color 0.3s;
            font-size: 15px
        }



            .menu-item.selected {
                background-color: #EFA63E;
                color: black !important;
            }

                .menu-item.selected img {
                    filter: brightness(0);
                }



        .sidebarIcon {
            width: 30px;
            margin-right: 25px;
        }


        .menu-item:hover {
            background-color: #EFA63E;
            color: black !important;
        }

        .menu-item img {
            filter: sepia(100%) saturate(450%) hue-rotate(330deg) brightness(1);
            transition: all 0.3s ease;
        }

        .menu-item:hover img {
            filter: brightness(0) !important; /* Force black, no blur */
            backface-visibility: hidden;
            transform-style: preserve-3d;
            transition: filter 0.3s ease, transform 0.3s ease; /* Control transitions */
        }

        .menu-title {
            display: flex;
            justify-content: start;
            align-items: center;
        }
    </style>
    <style id="MiscCSS">
        .modern-table {
            width: 100% !important;
            margin-bottom: 0;
            padding-top: 15px;
        }

            .modern-table thead th {
                background-color: #ffffff !important;
                color: #222222 !important;
                font-weight: 600;
                padding: 12px 15px;
                border-bottom: 2px solid #eee;
                position: sticky;
                top: 0;
            }

            .modern-table tbody td {
                padding: 12px 15px;
                vertical-align: middle;
                border-bottom: 1px solid #f1f3f5;
            }

            .modern-table tbody tr:last-child td {
                border-bottom: none;
            }


        .digital-stats-container {
            width: 100%;
            padding: 12px 0;
        }

        .digital-stats-row {
            display: flex;
            justify-content: space-between;
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 15px;
            flex-wrap: wrap;
            gap: 10px;
        }

        .digital-stat {
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .stat-label {
            font-size: 16px;
            color: #495057;
        }

        .digital-number {
            font-weight: bolder !important;
            font-size: 21px;
            color: #000;
            min-width: 24px;
            text-align: center;
        }


        .hr-with-arrow {
            display: flex;
            align-items: center;
        }

            .hr-with-arrow hr {
                flex-grow: 1;
                border: none;
                border-top: 1px solid #ddd;
                margin: 0;
            }

        .arrow-button {
            background: none;
            border: none;
            cursor: pointer;
            padding: 0 8px;
            margin-right: 20px;
            color: #999;
            transition: all 0.2s;
            font-size: 14px;
        }

            .arrow-button:hover {
                color: #333; /* Darker on hover */
                transform: translateY(1px); /* Optional: slight movement */
            }

        hr {
            margin-top: 0px !important
        }

        .row-details {
            display: flex;
        }

            .row-details p {
                margin: 0;
                flex: 1; /* Adjust widths equally if necessary */
                /* Optional: centers text within each item */
            }

        .card3 {
            padding: 20px 0px;
        }

        .profile-info {
            display: flex;
            gap: 40px; /* Adds spacing between image and text */
            align-items: flex-start;
        }

        .profile-img {
            width: 150px;
            height: 150px;
            object-fit: cover;
            border-radius: 15%;
        }

        .profile-details {
            line-height: 1.8; /* Adjusts line spacing for text */
        }

            .profile-details p {
                margin-bottom: 2px; /* Adds space between rows */
            }

        .profile-name {
            display: block;
            font-size: 1.6em;
            font-weight: bold !important;
            margin-top: 5px;
        }

        .icons {
            height: 30px;
            width: 30px;
            margin-right: 15px;
        }

        .badge {
            font-size: 1.2em;
            color: white;
            background-color: #EFA63E !important;
            padding: 5px 10px;
            border-radius: 5px;
            height: 26px;
        }

        .appointmentcard {
            margin-top: 40px;
            background-color: #fff;
            border: 1px solid rgba(0, 0, 0, 0.1); /* slightly darker border */
            border-radius: 8px; /* rounded corners */
            box-shadow: 0 6px 18px rgba(0, 0, 0, 0.15); /* more shadow and spread */
            padding: 20px;
            margin-bottom: 20px;
        }

        .statusCards {
            background-color: #fff;
            border: 1px solid rgba(0, 0, 0, 0.1);
            border-radius: 8px;
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.25); /* darker + more spread */
            padding: 20px;
            margin-bottom: 15px;
        }

        .appointment-info {
            display: flex;
            align-items: center;
            margin-bottom: 10px;
        }

        .labelcolor {
            color: #EFA63E !important;
        }

        .card {
            padding: 20px;
            border: 2px solid #ddd;
            border-radius: 8px;
            background-color: #fff;
            height: 400px !important;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }

        .page-header, #ctl00_sidebar {
            display: none !important;
        }

        .container-fluid {
            padding-left: 0px !important;
            padding-right: 0px !important;
            overflow-x: hidden;
            overflow-y: auto;
        }

        #tibbitFooter {
            display: none !important
        }

        label, span, .table > tbody > tr > td, select {
            font-weight: normal !important
        }

        .main-content {
            padding-bottom: 0px !important
        }

        .mybutton {
            font-size: 19px !important;
            width: fit-content !important;
            background-color: #f0f1f3;
            padding: 3px 12px;
            border-radius: 8px;
            margin: 0;
            color: #EFA63E !important;
            font-weight: bold !important;
            font-size: 16px;
            transition: all 0.3s ease;
            margin-bottom: 5px;
            border: 0px !important;
            margin-left: 5px;
            margin-right: 5px;
        }
    </style>
    <style id="searchBar">
        .search-container {
            position: relative;
            width: 100%;
        }

        .search-input-wrapper {
            position: relative;
            display: flex;
            align-items: center;
        }

        .search-input {
            width: 100% !important;
            padding: 16px 50px 16px 20px !important;
            border: 2px solid rgba(255, 255, 255, 0.3) !important;
            border-radius: 25px !important;
            background: rgba(255, 255, 255, 0.1) !important;
            backdrop-filter: blur(10px) !important;
            color: white !important;
            font-size: 16px !important;
            outline: none !important;
            transition: all 0.3s ease !important;
            placeholder-color: rgba(255, 255, 255, 0.7) !important;
        }

            .search-input::placeholder {
                color: rgba(255, 255, 255, 0.7);
            }

            .search-input:focus {
                border-color: rgba(255, 255, 255, 0.6);
                background: rgba(255, 255, 255, 0.15);
                box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
            }

        .search-icon {
            position: absolute;
            right: 17px;
            margin-bottom: 5px;
            color: rgba(255, 255, 255, 0.7);
            font-size: 18px;
            pointer-events: none;
            transition: color 0.3s ease;
        }

        .search-input:focus + .search-icon {
            color: rgba(255, 255, 255, 0.9);
        }

        .search-results {
            position: absolute;
            top: 100%;
            left: 0;
            right: 0;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(15px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 15px;
            margin-top: 8px;
            opacity: 0;
            visibility: hidden;
            transform: translateY(-10px);
            transition: all 0.3s ease;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
            z-index: 1000;
        }

            .search-results.active {
                opacity: 1;
                visibility: visible;
                transform: translateY(0);
            }

        .result-item {
            padding: 12px 20px;
            color: #333;
            cursor: pointer;
            transition: all 0.2s ease;
            border-bottom: 1px solid rgba(0, 0, 0, 0.05);
            font-size: 15px;
            display: block;
            line-height: 1.4;
            font-weight: normal
        }





            .result-item:last-child {
                border-bottom: none;
                border-radius: 0 0 15px 15px;
            }

            .result-item:first-child {
                border-radius: 15px 15px 0 0;
            }

            .result-item:hover {
                background: rgba(255, 255, 255, 0.1);
            }

        .result-title {
            font-weight: 600;
            margin-bottom: 5px;
            font-size: 14px;
        }

        .result-description {
            font-size: 12px;
            opacity: 0.8;
            line-height: 1.4;
        }

        .no-results {
            padding: 20px;
            text-align: center;
            color: black;
            font-style: italic;
        }

        /* Responsive design */
        @media (max-width: 768px) {
            .col-lg-4 {
                max-width: 100%;
            }
        }
    </style>
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

        });
        function selectPatient(patientNo, RegID) {
            $("#hdfReg_ID").val(RegID);
            checkVisits();
            fetchPatientInfo();
            hideResults();
            $('#Information').slideDown();
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
        function hideResults() {
            searchResults.classList.remove('active');
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
        document.addEventListener('DOMContentLoaded', function () {
            const searchInput = document.getElementById('searchInput');
            const searchResults = document.getElementById('searchResults');

            let searchTimeout;
            let currentXHR = null;

            searchInput.addEventListener('input', function (e) {
                const query = e.target.value.trim();

                clearTimeout(searchTimeout);

                // Cancel previous AJAX request if still pending
                if (currentXHR && currentXHR.readyState !== 4) {
                    currentXHR.abort();
                }

                // Add small delay for better UX
                searchTimeout = setTimeout(() => {


                    showLoading();

                    searchPatients(query);
                }, 300);
            });

            // Hide results when clicking outside
            document.addEventListener('click', function (e) {
                if (!e.target.closest('.search-container')) {
                    hideResults();
                }
            });
            function searchPatients(searchValue) {
                currentXHR = $.ajax({
                    type: "POST",
                    url: "NewEMR.aspx/GetPatients", // Replace 'YourPage.aspx' with your actual page name
                    data: JSON.stringify({ searchValue: searchValue }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        try {
                            const patients = JSON.parse(response.d);

                            // Check if response contains error
                            if (patients.error) {
                                showError(patients.error);
                            } else {
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
            </div>
        `;
                } else {
                    searchResults.innerHTML = patients.map(patient => {
                        const displayText = `${patient.PatientNo}-${patient.FullName}`;
                        return `
                <div class="result-item" onclick="selectPatient('${patient.PatientNo}','${patient.RegID}')">
                    <div>${highlightText(displayText, query)}</div>
                </div>
            `;
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
        </div>
    `;
                searchResults.classList.add('active');
            }

            function showError(errorMessage) {
                searchResults.innerHTML = `
        <div class="no-results" style="color: #ff6b6b;">
            ⚠️ Error: ${errorMessage}
        </div>
    `;
                searchResults.classList.add('active');
            }



            // Listen for patient selection (example usage)
            document.addEventListener('patientSelected', function (e) {
                console.log('Patient Selected Event:', e.detail);
                // You can handle the selected patient here
                // Example: Load patient details, update forms, etc.
            });

            function highlightText(text, query) {
                if (!query) return text;
                const regex = new RegExp(`(${escapeRegExp(query)})`, 'gi');
                return text.replace(regex, '<strong style="background: rgba(102, 126, 234, 0.2); border-radius: 3px; padding: 0 2px;">$1</strong>');
            }

            function escapeRegExp(string) {
                return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
            }

            // Show focus effect
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

            // Destroy existing table if it exists
            if ($.fn.DataTable.isDataTable('#tblOPD')) {
                $('#tblOPD').DataTable().destroy();
            }

            $("#tblOPD").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
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
                                    VisitNo: item.VisitNo || '',
                                    VisitDate: item.VisitDate || '',
                                    Department: item.Department || 'N/A',
                                    PatientType: item.PatientType || 'N/A',
                                    CheckedBy: item.CheckedBy || 'N/A',
                                    Remarks: item.Remarks || '',
                                    DischargeDate: item.DischargeDate || '',
                                    Status: item.Status || 'Active'
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
                        "data": "VisitNo",
                        "name": "VisitNo",
                        "width": "8%",
                        "orderable": true
                    },
                    {
                        "data": "VisitDate",
                        "name": "VisitDate",
                        "render": function (data) {
                            if (!data) return '';
                            // Handle different date formats
                            var date = moment(data);
                            return date.isValid() ? date.format('DD-MMM-YYYY') : data;
                        },
                        "width": "10%",
                        "orderable": true
                    },
                    {
                        "data": "Department",
                        "width": "15%",
                        "orderable": true,
                        "defaultContent": "N/A"
                    },
                    {
                        "data": "PatientType",
                        "width": "12%",
                        "orderable": true,
                        "defaultContent": "N/A"
                    },
                    {
                        "data": "CheckedBy",
                        "width": "12%",
                        "orderable": true,
                        "defaultContent": "N/A"
                    },
                    {
                        "data": "Status",
                        "width": "10%",
                        "orderable": true,
                        "defaultContent": "Active"
                    },
                    {
                        "data": "DischargeDate",
                        "name": "DischargeDate",
                        "render": function (data) {
                            if (!data) return '';
                            var date = moment(data);
                            return date.isValid() ? date.format('DD-MMM-YYYY') : data;
                        },
                        "width": "10%",
                        "orderable": true
                    },
                    {
                        "data": "Remarks",
                        "width": "15%",
                        "orderable": false,
                        "defaultContent": ""
                    },
                    {
                        "data": null,
                        "render": function (data, type, row) {
                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="Print(' + row.VisitNo + ')" id="btnprint"><i class="fa fa-print"></i></a>';
                            return print;
                        },
                        "width": "15%",
                        "orderable": false
                    }
                ],
                "initComplete": function (settings, json) {
                    var lengthContainer = document.querySelector('#tblOPD_length');
                    var lengthDropdown = document.querySelector('#tblOPD_length select');
                    var label = document.querySelector('#tblOPD_length label');

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
        function LoadIPDTable() {
            var ID = $("#hdfReg_ID").val();

            // Destroy existing table if it exists
            if ($.fn.DataTable.isDataTable('#tblIPD')) {
                $('#tblIPD').DataTable().destroy();
            }

            $("#tblIPD").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "filter": true,
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
                        console.log("IPD Server response:", json); // Debug log

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
                                    IPD_ID: item.IPD_ID || '',
                                    AdmissionDate: item.AdmissionDate || '',
                                    Department: item.Department || 'N/A',
                                    WardName: item.WardName || 'N/A',
                                    RoomNo: item.RoomNo || 'N/A',
                                    BedNo: item.BedNo || 'N/A',
                                    AttendingDoctor: item.AttendingDoctor || 'N/A',
                                    ProvisionalDiagnosis: item.ProvisionalDiagnosis || '',
                                    ExpectedDischargeDate: item.ExpectedDischargeDate || '',
                                    DischargeDate: item.DischargeDate || '',
                                    AdmissionType: item.AdmissionType || 'Regular',
                                    Status: item.Status || 'Admitted',
                                    TotalAmount: item.TotalAmount || '0',
                                    ReferringDoctor: item.ReferringDoctor || ''
                                };
                            });

                            // Set the values for DataTables
                            this.recordsTotal = result.recordsTotal;
                            this.recordsFiltered = result.recordsFiltered;

                            return result.data;
                        } else if (json.error) {
                            console.error("IPD Server error:", json.error);
                            return [];
                        }
                        return [];
                    },
                    "error": function (xhr, status, error) {
                        console.error("IPD AJAX Error:", status, error);
                        console.error("Response:", xhr.responseText);
                    }
                },
                "columns": [
                    {
                        "data": "IPD_ID",
                        "name": "IPD_ID",
                        "title": "IPD ID",
                        "width": "6%",
                        "orderable": true
                    },
                    {
                        "data": "AdmissionDate",
                        "name": "AdmissionDate",
                        "title": "Admission Date",
                        "render": function (data) {
                            if (!data) return '';
                            var date = moment(data);
                            return date.isValid() ? date.format('DD-MMM-YYYY') : data;
                        },
                        "width": "10%",
                        "orderable": true
                    },
                    {
                        "data": "Department",
                        "name": "Department",
                        "title": "Department",
                        "width": "12%",
                        "orderable": true,
                        "defaultContent": "N/A"
                    },
                    {
                        "data": "WardName",
                        "name": "WardName",
                        "title": "Ward",
                        "width": "10%",
                        "orderable": true,
                        "defaultContent": "N/A"
                    },
                    {
                        "data": "BedNo",
                        "name": "BedNo",
                        "title": "Bed",
                        "width": "5%",
                        "orderable": false,
                        "defaultContent": "N/A"
                    },

                    {
                        "data": "RoomNo",
                        "name": "RoomNo",
                        "title": "Room",
                        "width": "6%",
                        "orderable": false,
                        "defaultContent": "N/A"
                    },
                    {
                        "data": "AttendingDoctor",
                        "name": "AttendingDoctor",
                        "title": "Doctor",
                        "width": "12%",
                        "orderable": true,
                        "defaultContent": "N/A"
                    },

                    {
                        "data": "Status",
                        "name": "Status",
                        "title": "Status",
                        "width": "8%",
                        "orderable": true,
                        "defaultContent": "Admitted",
                        "render": function (data, type, row) {
                            var statusClass = '';
                            switch (data) {
                                case 'Admitted':
                                    statusClass = 'label-success';
                                    break;
                                case 'Discharged':
                                    statusClass = 'label-primary';
                                    break;
                                case 'Deceased':
                                    statusClass = 'label-danger';
                                    break;
                                default:
                                    statusClass = 'label-default';
                            }
                            return '<span class="label ' + statusClass + '">' + data + '</span>';
                        }
                    },
                    {
                        "data": "ExpectedDischargeDate",
                        "name": "ExpectedDischargeDate",
                        "title": "Expected Discharge",
                        "render": function (data) {
                            if (!data) return '';
                            var date = moment(data);
                            return date.isValid() ? date.format('DD-MMM-YYYY') : data;
                        },
                        "width": "10%",
                        "orderable": false
                    },
                    {
                        "data": "DischargeDate",
                        "name": "DischargeDate",
                        "title": "Discharge Date",
                        "render": function (data) {
                            if (!data) return '';
                            var date = moment(data);
                            return date.isValid() ? date.format('DD-MMM-YYYY') : data;
                        },
                        "width": "10%",
                        "orderable": false
                    },
                    {
                        "data": null,
                        "title": "Actions",
                        "render": function (data, type, row) {
                            var actions = '';

                            // Print button
                            actions += '<a class="btn btn-xs btn-primary" style="margin-right: 2px;" href="#" onclick="PrintIPD(' + row.IPD_ID + ')" title="Print">' +
                                '<i class="fa fa-print"></i></a>';


                            // Bill button
                            actions += '<a class="btn btn-xs btn-success" href="#" onclick="ViewBill(' + row.IPD_ID + ')" title="View Bill">' +
                                '<i class="fa fa-money"></i></a>';

                            return actions;
                        },
                        "width": "13%",
                        "orderable": false
                    }
                ],
                "order": [[0, "desc"]], // Default sort by admission date descending
                "pageLength": 25,
                "lengthMenu": [[10, 25, 50, 100], [10, 25, 50, 100]],

                "initComplete": function (settings, json) {
                    var lengthContainer = document.querySelector('#tblIPD_length');
                    var lengthDropdown = document.querySelector('#tblIPD_length select');
                    var label = document.querySelector('#tblIPD_length label');

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

                    console.log("IPD DataTable initialized successfully");
                }
            });
        }
        function LoadEMERGENCYTable() {
            var ID = $("#hdfReg_ID").val();

            // Destroy existing table if it exists
            if ($.fn.DataTable.isDataTable('#tblEMERGENCY')) {
                $('#tblEMERGENCY').DataTable().destroy();
            }

            $("#tblEMERGENCY").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "filter": true,
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
                        console.log("EMERGENCY Server response:", json); // Debug log

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
                                    EMERGENCY_ID: item.EMERGENCY_ID || '',
                                    AdmissionDate: item.AdmissionDate || '',
                                    WardName: item.WardName || 'N/A',
                                    BedNo: item.BedNo || 'N/A',
                                    AttendingDoctor: item.AttendingDoctor || 'N/A',
                                    DischargeDate: item.DischargeDate || '',
                                    Status: item.Status || 'Admitted',
                                };
                            });

                            // Set the values for DataTables
                            this.recordsTotal = result.recordsTotal;
                            this.recordsFiltered = result.recordsFiltered;

                            return result.data;
                        } else if (json.error) {
                            console.error("EMERGENCY Server error:", json.error);
                            return [];
                        }
                        return [];
                    },
                    "error": function (xhr, status, error) {
                        console.error("EMERGENCY AJAX Error:", status, error);
                        console.error("Response:", xhr.responseText);
                    }
                },
                "columns": [
                    {
                        "data": "EMERGENCY_ID",
                        "name": "EMERGENCY_ID",
                        "title": "EMERGENCY ID",
                        "width": "6%",
                        "orderable": true
                    },
                    {
                        "data": "AdmissionDate",
                        "name": "AdmissionDate",
                        "title": "Admission Date",
                        "render": function (data) {
                            if (!data) return '';
                            var date = moment(data);
                            return date.isValid() ? date.format('DD-MMM-YYYY') : data;
                        },
                        "width": "10%",
                        "orderable": true
                    },
                    {
                        "data": "WardName",
                        "name": "WardName",
                        "title": "Ward",
                        "width": "10%",
                        "orderable": true,
                        "defaultContent": "N/A"
                    },
                    {
                        "data": "BedNo",
                        "name": "BedNo",
                        "title": "Bed",
                        "width": "5%",
                        "orderable": false,
                        "defaultContent": "N/A"
                    },

                    {
                        "data": "AttendingDoctor",
                        "name": "AttendingDoctor",
                        "title": "Doctor",
                        "width": "12%",
                        "orderable": true,
                        "defaultContent": "N/A"
                    },

                    {
                        "data": "Status",
                        "name": "Status",
                        "title": "Status",
                        "width": "8%",
                        "orderable": true,
                        "defaultContent": "Admitted",
                        "render": function (data, type, row) {
                            var statusClass = '';
                            switch (data) {
                                case 'Admitted':
                                    statusClass = 'label-success';
                                    break;
                                case 'Discharged':
                                    statusClass = 'label-primary';
                                    break;
                                case 'Deceased':
                                    statusClass = 'label-danger';
                                    break;
                                default:
                                    statusClass = 'label-default';
                            }
                            return '<span class="label ' + statusClass + '">' + data + '</span>';
                        }
                    },
                    {
                        "data": "DischargeDate",
                        "name": "DischargeDate",
                        "title": "Discharge Date",
                        "render": function (data) {
                            if (!data) return '';
                            var date = moment(data);
                            return date.isValid() ? date.format('DD-MMM-YYYY') : data;
                        },
                        "width": "10%",
                        "orderable": false
                    },
                    {
                        "data": null,
                        "title": "Actions",
                        "render": function (data, type, row) {
                            var actions = '';

                            // Print button
                            actions += '<a class="btn btn-xs btn-primary" style="margin-right: 2px;" href="#" onclick="PrintEMERGENCY(' + row.EMERGENCY_ID + ')" title="Print">' +
                                '<i class="fa fa-print"></i></a>';



                            return actions;
                        },
                        "width": "13%",
                        "orderable": false
                    }
                ],
                "order": [[0, "desc"]], // Default sort by admission date descending
                "pageLength": 25,
                "lengthMenu": [[10, 25, 50, 100], [10, 25, 50, 100]],

                "initComplete": function (settings, json) {
                    var lengthContainer = document.querySelector('#tblEMERGENCY_length');
                    var lengthDropdown = document.querySelector('#tblEMERGENCY_length select');
                    var label = document.querySelector('#tblEMERGENCY_length label');

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

                    console.log("EMERGENCY DataTable initialized successfully");
                }
            });
        }
        function LoadMedicineTable() {
            var ID = $("#hdfReg_ID").val();

            // Destroy existing table if it exists
            if ($.fn.DataTable.isDataTable('#tblMedicene')) {
                $('#tblMedicene').DataTable().destroy();
            }

            $("#tblMedicene").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "filter": true,
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
                        console.log("Medicine Server response:", json); // Debug log

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
                                    MedicineID: item.MedicineID || '',
                                    MedicineName: item.MedicineName || 'N/A',
                                    Dosage: item.Dosage || 'N/A',
                                    Form: item.Form || 'N/A',
                                    Route: item.Route || 'N/A',
                                    Duration: item.Duration || 'N/A',
                                    Frequency: item.Frequency || 'N/A',
                                    PrescriptionDate: item.PrescriptionDate || '',
                                    Instructions: item.Instructions || 'N/A'
                                };
                            });

                            // Set the values for DataTables
                            this.recordsTotal = result.recordsTotal;
                            this.recordsFiltered = result.recordsFiltered;

                            return result.data;
                        } else if (json.error) {
                            console.error("Medicine Server error:", json.error);
                            return [];
                        }
                        return [];
                    },
                    "error": function (xhr, status, error) {
                        console.error("Medicine AJAX Error:", status, error);
                        console.error("Response:", xhr.responseText);
                    }
                },
                "columns": [
                    {
                        "data": "MedicineName",
                        "name": "MedicineName",
                        "title": "Medicine Name",
                        "width": "15%",
                        "orderable": false
                    },

                    {
                        "data": "PrescriptionDate",
                        "name": "PrescriptionDate",
                        "title": "Prescription Date",
                        "render": function (data) {
                            if (!data) return '';
                            var date = moment(data);
                            return date.isValid() ? date.format('DD-MMM-YYYY') : data;
                        },
                        "width": "12%",
                        "orderable": true
                    }, {
                        "data": null,
                        "name": "DosageForm",
                        "title": "Dosage",
                        "width": "12%",
                        "orderable": false,
                        "render": function (data, type, row) {
                            return `${row.Dosage || 'N/A'} - ${row.Form || 'N/A'}`;
                        }
                    },
                    {
                        "data": "Route",
                        "name": "Route",
                        "title": "Route",
                        "width": "8%",
                        "orderable": false
                    },
                    {
                        "data": "Duration",
                        "name": "Duration",
                        "title": "Duration",
                        "width": "8%",
                        "orderable": false
                    },
                    {
                        "data": "Frequency",
                        "name": "Frequency",
                        "title": "Frequency",
                        "width": "10%",
                        "orderable": false
                    },
                    {
                        "data": "Instructions",
                        "name": "Instructions",
                        "title": "Instructions",
                        "width": "20%",
                        "orderable": false
                    }
                ],
                "order": [[0, "desc"]], // Default sort by prescription date descending
                "pageLength": 25,
                "lengthMenu": [[10, 25, 50, 100], [10, 25, 50, 100]],
                "initComplete": function (settings, json) {
                    var lengthContainer = document.querySelector('#tblMedicene_length');
                    var lengthDropdown = document.querySelector('#tblMedicene_length select');
                    var label = document.querySelector('#tblMedicene_length label');

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

                    console.log("Medicene DataTable initialized successfully");
                }
            });

        }
        function LoadInvestigationTable() {
            var ID = $("#hdfReg_ID").val();

            // Destroy existing table if it exists
            if ($.fn.DataTable.isDataTable('#tblInvestigation')) {
                $('#tblInvestigation').DataTable().destroy();
            }

            $("#tblInvestigation").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "filter": true,
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
                        console.log("Investigation Server response:", json); // Debug log

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
                                    Lab_Test_Detail_ID: item.Lab_Test_Detail_ID || '',
                                    Date: item.Date || '',
                                    Test_Name: item.Test_Name || 'N/A',
                                    DoctorName: item.DoctorName || 'N/A',
                                    Special_Tests: item.Special_Tests || 'N/A',
                                    Area_Of_Interest: item.Area_Of_Interest || 'N/A',
                                    Remark: item.Remark || 'N/A'
                                };
                            });

                            // Set the values for DataTables
                            this.recordsTotal = result.recordsTotal;
                            this.recordsFiltered = result.recordsFiltered;

                            return result.data;
                        } else if (json.error) {
                            console.error("Investigation Server error:", json.error);
                            return [];
                        }
                        return [];
                    },
                    "error": function (xhr, status, error) {
                        console.error("Investigation AJAX Error:", status, error);
                        console.error("Response:", xhr.responseText);
                    }
                },
                "columns": [
                    {
                        "data": "Lab_Test_Detail_ID",
                        "name": "Lab_Test_Detail_ID",
                        "title": "Test ID",
                        "width": "6%",
                        "orderable": true
                    },
                    {
                        "data": "Test_Name",
                        "name": "Test_Name",
                        "title": "Test Name",
                        "width": "20%",
                        "orderable": true,
                        "defaultContent": "N/A"
                    },

                    {
                        "data": "Date",
                        "name": "Date",
                        "title": "Test Date",
                        "render": function (data) {
                            if (!data) return '';
                            var date = moment(data);
                            return date.isValid() ? date.format('DD-MMM-YYYY') : data;
                        },
                        "width": "10%",
                        "orderable": true
                    },
                    {
                        "data": "Special_Tests",
                        "name": "Special_Tests",
                        "title": "Special Tests",
                        "width": "15%",
                        "orderable": true,
                        "defaultContent": "N/A"
                    },
                    {
                        "data": "Area_Of_Interest",
                        "name": "Area_Of_Interest",
                        "title": "Area of Interest",
                        "width": "15%",
                        "orderable": true,
                        "defaultContent": "N/A"
                    },
                    {
                        "data": "Remark",
                        "name": "Remark",
                        "title": "Remarks",
                        "width": "15%",
                        "orderable": false,
                        "defaultContent": "N/A"
                    }
                ],
                "order": [[0, "desc"]], // Default sort by test date descending
                "pageLength": 25,
                "lengthMenu": [[10, 25, 50, 100], [10, 25, 50, 100]],

                "initComplete": function (settings, json) {
                    var lengthContainer = document.querySelector('#tblInvestigation_length');
                    var lengthDropdown = document.querySelector('#tblInvestigation_length select');
                    var label = document.querySelector('#tblInvestigation_length label');

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

                    console.log("Investigation DataTable initialized successfully");
                }
            });
        }
        function LoadDiagnosticsTable() {
            var ID = $("#hdfReg_ID").val();

            // Destroy existing table if it exists
            if ($.fn.DataTable.isDataTable('#tblDiagnostics')) {
                $('#tblDiagnostics').DataTable().destroy();
            }

            $("#tblDiagnostics").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf', 'print'],
                "filter": true,
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
                        console.log("Diagnostics Server response:", json);

                        if (json.d) {
                            var result = {
                                draw: json.d.draw || 0,
                                recordsTotal: json.d.recordsTotal || 0,
                                recordsFiltered: json.d.recordsFiltered || 0,
                                data: json.d.data || []
                            };

                            // Format data and handle null values
                            result.data = result.data.map(function (item) {
                                return {
                                    Lab_Test_Detail_ID: item.Lab_Test_Detail_ID || '',
                                    Date: item.Date || '',
                                    Test_Name: item.Test_Name || 'N/A',
                                    DoctorName: item.DoctorName || 'N/A',
                                    Special_Tests: item.Special_Tests || 'N/A',
                                    Area_Of_Interest: item.Area_Of_Interest || 'N/A',
                                    Department: item.Department || 'N/A',
                                    Rotation: item.Rotation || 'N/A',
                                    Remark: item.Remark || 'N/A'
                                };
                            });

                            this.recordsTotal = result.recordsTotal;
                            this.recordsFiltered = result.recordsFiltered;

                            return result.data;
                        } else if (json.error) {
                            console.error("Diagnostics Server error:", json.error);
                            return [];
                        }
                        return [];
                    },
                    "error": function (xhr, status, error) {
                        console.error("Diagnostics AJAX Error:", status, error);
                        console.error("Response:", xhr.responseText);
                    }
                },
                "columns": [
                    {
                        "data": "Lab_Test_Detail_ID",
                        "name": "Lab_Test_Detail_ID",
                        "title": "Test ID",
                        "width": "5%",
                        "orderable": true
                    },
                    {
                        "data": "Test_Name",
                        "name": "Test_Name",
                        "title": "Test Name",
                        "width": "15%",
                        "orderable": true,
                        "defaultContent": "N/A"
                    },
                    {
                        "data": "Department",
                        "name": "Department",
                        "title": "Department",
                        "width": "12%",
                        "orderable": true,
                        "defaultContent": "N/A"
                    },
                    {
                        "data": "Date",
                        "name": "Date",
                        "title": "Test Date",
                        "render": function (data) {
                            if (!data) return '';
                            var date = moment(data);
                            return date.isValid() ? date.format('DD-MMM-YYYY') : data;
                        },
                        "width": "8%",
                        "orderable": true
                    },

                    {
                        "data": "Special_Tests",
                        "name": "Special_Tests",
                        "title": "Special Tests",
                        "width": "10%",
                        "orderable": false,
                        "defaultContent": "N/A"
                    },
                    {
                        "data": "Area_Of_Interest",
                        "name": "Area_Of_Interest",
                        "title": "Area of Interest",
                        "width": "10%",
                        "orderable": false,
                        "defaultContent": "N/A"
                    },
                    {
                        "data": "Rotation",
                        "name": "Rotation",
                        "title": "Rotation/View",
                        "width": "12%",
                        "orderable": true,
                        "defaultContent": "N/A"
                    },
                    {
                        "data": "Remark",
                        "name": "Remark",
                        "title": "Remarks",
                        "width": "10%",
                        "orderable": false,
                        "defaultContent": "N/A"
                    }
                ],
                "order": [[0, "desc"]], // Default sort by test date descending
                "pageLength": 25,
                "lengthMenu": [[10, 25, 50, 100], [10, 25, 50, 100]],
                "language": {
                    "emptyTable": "No diagnostic tests found for this patient",
                    "zeroRecords": "No matching diagnostic tests found"
                },
                "initComplete": function (settings, json) {
                    // Customize length menu display
                    var lengthContainer = document.querySelector('#tblDiagnostics_length');
                    var lengthDropdown = document.querySelector('#tblDiagnostics_length select');
                    var label = document.querySelector('#tblDiagnostics_length label');

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

                    console.log("Diagnostics DataTable initialized successfully");
                }
            });
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
                    { "data": "ID", "width": "8%", "orderable": true },
                    { "data": "OutPatientID", "width": "12%", "orderable": true },
                    { "data": "PatientID", "width": "12%", "orderable": true },
                    { "data": "DiagnosisName", "width": "35%", "orderable": true, "defaultContent": "N/A" },
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
                    { "data": "ID", "width": "8%", "orderable": true },
                    { "data": "PatientID", "width": "10%", "orderable": true },
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
                    { "data": "ID", "width": "8%", "orderable": true },
                    { "data": "OutPatientID", "width": "12%", "orderable": true },
                    { "data": "PatientID", "width": "12%", "orderable": true },
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
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/complaints.png" alt="Profile Picture" class="sidebarIcon">
                        <span>OPD</span>
                    </div>
                </div>
                <div class="menu-item no-submenu" id="02" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/symptoms.png" alt="Profile Picture" class="sidebarIcon">
                        <span>IPD</span>
                    </div>
                </div>
                <div class="menu-item no-submenu" id="03" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/vitals.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Emergency</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="04" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/history.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Medication</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="05" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/examination.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Investigation</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="06" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/refer.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Diagnostics</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="07" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/primarydiagnosis.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Procedures</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="08" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/finaldiagnosis.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Symptoms</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="09" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/investigation.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Complaints</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="10" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/diagnostics.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Primary Diagnosis</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="11" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/medication.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Final Diagnosis</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="12" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/followup.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Advices</span>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-lg-10">

            <div class="row">
                <div class="col-lg-3">
                    <div onclick="toggleRetract()" style="width: fit-content !important;" class="retractIcon">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/sidebar.png"
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
                                <img class="ToBeHidden" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/cake.png" alt="Profile Picture" class="profile-img">
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
            <div id="tab01" style="display: none" class="tabs">
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
