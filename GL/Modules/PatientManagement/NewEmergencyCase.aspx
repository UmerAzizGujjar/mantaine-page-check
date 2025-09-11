<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="NewEmergencyCase.aspx.cs" Inherits="PMS.Modules.PatientManagement.NewEmergencyCase" %>
 
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

       <style>
          .modern-loading-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(245, 245, 245, 0.95); /* Whitish semi-transparent */
    z-index: 9999;
    display: flex;
    align-items: center;
    justify-content: center;
    opacity: 0;
    animation: fadeIn 0.4s ease forwards;
}
.modern-table tbody td {
    white-space: normal !important; /* allow text wrapping */
    word-wrap: break-word; /* wrap long words */
    word-break: break-word; /* force breaking if needed */
    vertical-align: top; /* keep text aligned to top */
}
.loading-content {
    background: rgba(255, 255, 255, 0.85); /* Solid whitish */
    backdrop-filter: blur(20px);
    border: 1px solid rgba(239, 166, 62, 0.4); /* Subtle orange border */
    padding: 40px;
    border-radius: 20px;
    text-align: center;
    color: #333; /* Dark text for contrast */
    box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
    transform: scale(0.8);
    animation: scaleIn 0.4s ease 0.2s forwards;
    min-width: 200px;
}

.loading-spinner {
    width: 60px;
    height: 60px;
    margin: 0 auto 20px;
    position: relative;
}

.spinner-ring {
    position: absolute;
    width: 100%;
    height: 100%;
    border: 3px solid rgba(239, 166, 62, 0.1); /* Very subtle orange */
    border-top: 3px solid #EFA63E; /* Bright orange */
    border-radius: 50%;
    animation: spin 1s linear infinite;
}

    .spinner-ring:nth-child(2) {
        border-top-color: rgba(239, 166, 62, 0.7);
        animation-duration: 1.5s;
        animation-direction: reverse;
        width: 80%;
        height: 80%;
        top: 10%;
        left: 10%;
    }

    .spinner-ring:nth-child(3) {
        border-top-color: rgba(239, 166, 62, 0.4);
        animation-duration: 2s;
        width: 60%;
        height: 60%;
        top: 20%;
        left: 20%;
    }

.loading-text {
    font-size: 18px;
    font-weight: 600;
    margin-bottom: 10px;
    background: linear-gradient(45deg, #EFA63E, #d18d2f, #EFA63E);
    background-size: 200% 200%;
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    animation: gradientShift 3s ease infinite;
}

.loading-subtext {
    font-size: 14px;
    color: rgba(0, 0, 0, 0.7); /* Darker subtext */
    margin-bottom: 20px;
}

.progress-bar {
    width: 100%;
    height: 4px;
    background: rgba(0, 0, 0, 0.1);
    border-radius: 2px;
    overflow: hidden;
    position: relative;
}

.progress-fill {
    height: 100%;
    background: linear-gradient(90deg, transparent, #EFA63E, transparent);
    border-radius: 2px;
    animation: progressMove 2s ease-in-out infinite;
}

/* Floating particles - adjusted for light background */
.particle {
    position: absolute;
    width: 4px;
    height: 4px;
    background: rgba(239, 166, 62, 0.5);
    border-radius: 50%;
    animation: float 3s ease-in-out infinite;
}

    /* Keep original particle positions */
    .particle:nth-child(1) {
        top: 20%;
        left: 20%;
        animation-delay: 0s;
    }

    .particle:nth-child(2) {
        top: 80%;
        left: 80%;
        animation-delay: 1s;
    }

    .particle:nth-child(3) {
        top: 60%;
        left: 10%;
        animation-delay: 2s;
    }

    .particle:nth-child(4) {
        top: 30%;
        left: 90%;
        animation-delay: 1.5s;
    }

/* Animations remain unchanged */
@keyframes fadeIn {
    to {
        opacity: 1;
    }
}

@keyframes scaleIn {
    to {
        transform: scale(1);
    }
}

@keyframes spin {
    to {
        transform: rotate(360deg);
    }
}

@keyframes gradientShift {
    0%, 100% {
        background-position: 0% 50%;
    }

    50% {
        background-position: 100% 50%;
    }
}

@keyframes progressMove {
    0% {
        transform: translateX(-100%);
    }

    100% {
        transform: translateX(200%);
    }
}

@keyframes float {
    0%, 100% {
        transform: translateY(0px) rotate(0deg);
        opacity: 0.6;
    }

    50% {
        transform: translateY(-20px) rotate(180deg);
        opacity: 1;
    }
}

.fade-out {
    animation: fadeOut 0.4s ease forwards;
}

@keyframes fadeOut {
    to {
        opacity: 0;
        transform: scale(0.95);
    }
}

#hamburger {
    display: none !important
}

.grow-col {
    flex: 1 0 0; /* Grow to fill remaining space */
    max-width: 100%; /* Prevent overflow */
}
/* Override Bootstrap's default column behavior */
.main-layout-row {
    display: flex;
    flex-wrap: wrap;
    width: 100%;
}
/* All other .row elements keep default Bootstrap behavior */
.row:not(.main-layout-row) {
    display: block;
    margin-right: -15px;
    margin-left: -15px;
}

@media screen and (max-width: 995px) {
    .main {
        width: 100% !important;
        margin-left: 0px !important;
    }
}

.labels {
    font-weight: bold !important
}

.mybutton2-wrapper {
    display: inline-block;
    padding: 10px 20px;
    background-color: #EFA63E;
    color: black;
    border-radius: 4px;
    cursor: pointer;
    user-select: none;
    position: relative;
    transition: background-color 0.3s;
}

    .mybutton2-wrapper input[type="checkbox"] {
        display: none;
    }

    .mybutton2-wrapper.checked {
        background-color: red;
    }

.hidden {
    display: none !important
}

.medical-dashboard {
    font-family: 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif !important;
    background-color: #f8f9fa;
    padding: 20px;
    border-radius: 12px;
}

.dashboard-container {
    max-width: 100%;
    margin: 0 auto;
}

.dashboard-card {
    background: #ffffff;
    border-radius: 10px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.05);
    margin-bottom: 20px;
    height: 100%;
    display: flex;
    flex-direction: column;
}

.card-header {
    padding: 15px 20px;
    border-bottom: 1px solid #eee;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

    .card-header h4 {
        margin: 0;
        font-size: 16px;
        font-weight: 600;
        color: #2c3e50;
        display: flex;
        align-items: center;
    }

        .card-header h4 i {
            margin-right: 10px;
            color: #EFA63E;
        }

.fa {
    color: black
}

.btn-icon {
    background: transparent;
    border: none;
    color: #7f8c8d;
    font-size: 14px;
    cursor: pointer;
    padding: 5px;
    border-radius: 50%;
    width: 28px;
    height: 28px;
    display: flex;
    align-items: center;
    justify-content: center;
}

    .btn-icon:hover {
        background: #f5f5f5;
        color: #3498db;
    }

.modern-table {
    width: 100%;
    margin-bottom: 0;
}

    .modern-table thead th {
        background-color: #ffffff !important;
        color: #6a6969 !important;
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


.actions-col {
    width: 80px;
    text-align: center;
}

/* Responsive adjustments */
@media (max-width: 992px) {
    .dashboard-card {
        margin-bottom: 15px;
    }
}

@media (max-width: 768px) {
    .card-header h4 {
        font-size: 15px;
    }

    .modern-table thead th,
    .modern-table tbody td {
        padding: 10px 12px;
    }
}

#tibbitFooter, #ctl00_Footer_StandardFooter {
    display: none !important
}

.main-content {
    padding-bottom: 0px !important
}

label, span, .table > tbody > tr > td, select {
    font-weight: normal !important
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

.preview {
    transition: all 0.5s ease;
}



.retractIcon {
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 8px;
    border-radius: 50%;
    cursor: pointer;
    transition: all 0.3s ease;
}

    .retractIcon:hover {
        background-color: rgba(0, 0, 0, 0.1);
        transform: scale(1.1);
    }

        .retractIcon:hover img {
            filter: brightness(0.8) contrast(1.2);
            transform: rotate(10deg);
        }

.sidebarToggleIcon {
    width: 24px;
    height: 24px;
    transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
}

.retractIcon:active {
    transform: scale(0.95);
}

.sidebarIcon {
    width: 30px;
    margin-right: 25px;
}



.table > tbody > tr > td {
    border-top: 0px !important;
}

.main textarea {
    margin-bottom: 0px !important;
    height: 50px !important;
}

.no-submenu {
    color: #495057;
    font-weight: 500;
    font-size: 15px
}

    .no-submenu:hover {
        background-color: #d1ecf1;
        color: #0c5460;
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


.menu-title {
    display: flex;
    justify-content: start;
    align-items: center;
}

.submenu {
    max-height: 0;
    overflow: hidden;
    transition: max-height 0.3s ease-out;
    background-color: #fff;
}

.submenu-item {
    padding: 12px 20px 12px 40px;
    border-bottom: 1px solid #f1f1f1;
    cursor: pointer;
}

    .submenu-item:hover {
        background-color: #f1f1f1;
    }

.menu-item.active .submenu {
    max-height: 500px;
}

.menu-item.active .toggle-icon::after {
    content: "−";
}

.toggle-icon::after {
    content: "+";
    font-weight: bold;
}







.sidebarToggleIcon {
    width: 24px;
    height: 24px;
    transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
}


.sidebarIcon {
    width: 30px;
    margin-right: 25px;
}



.table > tbody > tr > td {
    border-top: 0px !important;
}

.main textarea {
    margin-bottom: 0px !important;
    height: 50px !important;
}

.no-submenu {
    color: #495057;
    font-weight: 500;
    font-size: 15px
}

    .no-submenu:hover {
        background-color: #d1ecf1;
        color: #0c5460;
    }



.menu-item {
    cursor: pointer;
    padding: 15px 20px;
    border-bottom: 1px solid #dee2e6;
    transition: background-color 0.3s;
    font-size: 15px
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

.submenu {
    max-height: 0;
    overflow: hidden;
    transition: max-height 0.3s ease-out;
    background-color: #fff;
}

.submenu-item {
    padding: 12px 20px 12px 40px;
    border-bottom: 1px solid #f1f1f1;
    cursor: pointer;
}

    .submenu-item:hover {
        background-color: #f1f1f1;
    }

.menu-item.active .submenu {
    max-height: 500px;
}

.menu-item.active .toggle-icon::after {
    content: "−";
}

.toggle-icon::after {
    content: "+";
    font-weight: bold;
}

.previewTable {
    border: 3px solid #cccccc;
    border-radius: 6px;
    padding: 12px 16px;
    background-color: #fff;
    margin-bottom: 15px
}

    .previewTable th {
        background-color: #ffffff !important;
        color: #6a6969 !important;
    }

#clear {
    display: none
}

th {
    color: white !important
}

.container-fluid {
    padding-left: 0px !important;
    padding-right: 0px !important;
}

input[type="checkbox"] {
    width: 30px !important;
    margin-right: 15px
}

.labels {
    font-size: 15px
}

.card {
    border: 1px solid #ccc;
    transition: all 0.3s ease;
    border-radius: 10px;
    padding: 20px;
}

.page-header, #ctl00_sidebar {
    display: none !important;
}

#ctl00_MainContent_txtRefferNote {
    width: 80% !important
}


.symptom-row, .vital-row, .history-row, .exam-row, .exam-text-row, .Systematic-Exam-Row, .refer-row,
.complaint-row, .Primary-Diagnosis-row, .Final-Diagnosis-row, .labtest-row, .diagnosticTest-row, .Medicene-row, .FollowUp-Row, .Disposal-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 2px;
    height: 55px;
    background-color: white;
    border-radius: 13px;
    color: black;
    transition: background-color 0.3s ease, color 0.3s ease;
    padding: 0 16px;
    cursor: pointer;
    border-bottom: 0.0001px dashed gray;
}

.history-row, .exam-text-row, .Systematic-Exam-Row, .Primary-Diagnosis-row, .Final-Diagnosis-row, .Disposal-row {
    height: 65px !important;
}

    .symptom-row:hover, .vital-row:hover, .history-row:hover, .exam-row:hover,
    .exam-text-row:hover, .Systematic-Exam-Row:hover, .refer-row:hover,
    .complaint-row:hover, .Primary-Diagnosis-row:hover, .Final-Diagnosis-row:hover, .labtest-row:hover, .diagnosticTest-row:hover, .Medicene-row:hover, .FollowUp-Row:hover, .Disposal-row:hover {
        background-color: #EFA63E;
        color: black !important;
        transform: scale(1.02);
        transition: background-color 0.3s ease, color 0.3s ease, transform 0.2s ease;
    }

        .labtest-row:hover .labtest-label {
            color: white !important;
        }


        .Medicene-row:hover .Medicene-label {
            color: white !important;
        }

        .diagnosticTest-row:hover .diagnostictest-label {
            color: white !important;
        }

        .symptom-row:hover .fa-plus-circle {
            color: white !important;
        }

.symptom-row label {
    margin-left: 10px;
    margin-bottom: 0;
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


.btn-primry {
    padding: 3px 12px;
    font-weight: normal !important;
    width: fit-content !important;
    border-radius: 8px;
    margin: 0;
    transition: all 0.3s ease;
    margin-bottom: 5px;
    border: 0px !important;
    margin-left: 5px;
    margin-right: 5px;
}



.Medicene-row {
    position: relative;
    margin-bottom: 5px;
    transition: all 0.3s ease;
}

.Medicene-details {
    clear: both;
    padding: 10px;
    background: #f5f5f5;
    margin-bottom: 10px;
    border-radius: 4px;
}

.expanding-row {
    margin-bottom: 15px;
}

.Medicene-row + .Medicene-details {
    margin-top: -5px;
}

      </style>
    <script id="ScriptmanageSymptomsModal">
        $(document).ready(function () {
            bindDate();
            MaskedInput({
                elm: document.getElementById('ctl00_MainContent_txtCNIC'),
                format: '_____-_______-_',
                separator: '-'
            });
            MaskedInput({
                elm: document.getElementById('ctl00_MainContent_txtMobileNo'),
                format: '____-_______',
                separator: '-'
            });
            MaskedInput({
                elm: document.getElementById('ctl00_MainContent_txtBP'),
                format: '___/___',
                separator: '-'
            });
            MaskedInput({
                elm: document.getElementById('ctl00_MainContent_txtBPDischarge'),
                format: '___/___',
                separator: '-'
            });
            MaskedInput({
                elm: document.getElementById('ctl00_MainContent_ctl00_MainContent_txtEOR'),
                format: '_/4',
                separator: '/'
            });
            MaskedInput({
                elm: document.getElementById('ctl00_MainContent_txtMR'),
                format: '_/5',
                separator: '/'
            });
            MaskedInput({
                elm: document.getElementById('ctl00_MainContent_txtVR'),
                format: '_/6',
                separator: '/'
            });
            MaskedInput({
                elm: document.getElementById('ctl00_MainContent_txtAcc'),
                format: '_/15',
                separator: '/'
            });

            loadDepartments();
            GetSymptomsByDepartment();
            $('#departments').change(function () {
                const selectedValue = $(this).val();
                const selectedText = $(this).find('option:selected').text();
                fillSymptomsInModal(selectedValue, "");
                // Then filter the preview table
                if (selectedValue) {
                    // First hide all rows
                    $('#tblsymptomspreview tbody tr').css('display', 'none');

                    // Then show only matching rows using proper table row display
                    $('#tblsymptomspreview tbody tr').each(function () {
                        const row = $(this);
                        const rowDeptId = row.find('input.deptid').val();

                        if (rowDeptId === selectedValue) {
                            row.css('display', 'table-row'); // Explicitly set table-row
                        }
                    });

                    // Check visibility by checking if any rows exist for this department
                    const hasVisibleRows = $('#tblsymptomspreview tbody tr').filter(function () {
                        return $(this).css('display') !== 'none' &&
                            $(this).find('input.deptid').val() === selectedValue;
                    }).length > 0;

                    $('#symptomspreview').toggle(hasVisibleRows);
                } else {
                    // Show all rows with proper table display
                    $('#tblsymptomspreview tbody tr').css('display', 'table-row');
                    $('#symptomspreview').toggle($('#tblsymptomspreview tbody tr').length > 0);
                }
                $(document).on('input', '#symptomSearch', function () {
                    const searchTerm = $(this).val().trim();
                    const selectedValue = $('#departments').val();
                    const selectedText = $('#departments').find('option:selected').text();
                    console.log(searchTerm);
                    fillSymptomsInModal(selectedValue, searchTerm);
                });
            });
            $('#filterDepartments').change(function () {
                const selectedValue = $(this).val();
                const searchTerm = $('#tab01Search').val().trim();
                fillSymptoms(selectedValue, searchTerm);
            });
            $('#departments').change(function () {
                const selectedValue = $(this).val();
                const selectedText = $(this).find('option:selected').text();
                fillSymptomsInModal(selectedValue, "");
                // Then filter the preview table
                if (selectedValue) {
                    // First hide all rows
                    $('#tblsymptomspreview tbody tr').css('display', 'none');

                    // Then show only matching rows using proper table row display
                    $('#tblsymptomspreview tbody tr').each(function () {
                        const row = $(this);
                        const rowDeptId = row.find('input.deptid').val();

                        if (rowDeptId === selectedValue) {
                            row.css('display', 'table-row'); // Explicitly set table-row
                        }
                    });

                    // Check visibility by checking if any rows exist for this department
                    const hasVisibleRows = $('#tblsymptomspreview tbody tr').filter(function () {
                        return $(this).css('display') !== 'none' &&
                            $(this).find('input.deptid').val() === selectedValue;
                    }).length > 0;

                    $('#symptomspreview').toggle(hasVisibleRows);
                } else {
                    // Show all rows with proper table display
                    $('#tblsymptomspreview tbody tr').css('display', 'table-row');
                    $('#symptomspreview').toggle($('#tblsymptomspreview tbody tr').length > 0);
                }
            });
            $('#tab01Search').on('input', function () {
                const searchTerm = $(this).val().trim();
                const selectedValue = $('#filterDepartments').val();
                fillSymptoms(selectedValue, searchTerm);
            });
            $(document).on('input', '.history-row textarea, .history-row input[type="text"]', function () {
                updateHistoryTable();
            });
            document.getElementById('filterMedicalExaminations').addEventListener('change', function () {
                var selectedValue = this.value;

                // Hide all subtabs
                var subtabs = document.querySelectorAll('.subtabs');
                subtabs.forEach(function (tab) {
                    tab.style.display = 'none';
                });

                // Show selected subtab
                var selectedTab = document.getElementById('subTab' + selectedValue);
                if (selectedTab) {
                    selectedTab.style.display = 'block';
                }
            });
            $("[id$='ddlPatientCondition']").on('change', AddAdmission);
            $("[id$='ddlDoctor']").on('change', AddAdmission);
            $("[id$='ddlWard_No']").on('change', AddAdmission);
            $("[id$='txtBed_No']").on('blur', AddAdmission);
            $("[id$='txtRateBeats']").on('blur', AddVitals);
            $("[id$='txtBP']").on('blur', AddVitals);
            $("[id$='txtTemp']").on('blur', AddVitals);
            $("[id$='txtRespiration']").on('blur', AddVitals);
            $("[id$='ddlRhythm']").on('change', AddVitals);
            $("[id$='ddlVolume']").on('change', AddVitals);
            $("[id$='txtSaturation_Oxygen2']").on('blur', AddVitals);
            $("[id$='txtSaturation']").on('blur', AddVitals);
            $("[id$='txtSaturation_Oxygen1']").on('blur', AddVitals);
            $("[id$='chk_OnRoomAir']").on('change', AddVitals);
            $("[id$='chk_WithOxygen']").on('change', AddVitals);
            $("[id$='txtOthersRcvNote']").on('blur', AddVitals);
            $("[id$='txtReceiving_Date']").on('blur', AddVitals);
            $("[id$='txtRN_Special_Instruction']").on('change', AddVitals);
            $("[id$='txtPulseRate']").on('blur', AddDischargeVitals);
            $("[id$='txtBPDischarge']").on('blur', AddDischargeVitals);
            $("[id$='txtTempdisch']").on('blur', AddDischargeVitals);
            $("[id$='txtRespRateDesc']").on('blur', AddDischargeVitals);
            $("[id$='ddlRhythmdischarge']").on('change', AddDischargeVitals);
            $("[id$='ddlvolumedisc']").on('change', AddDischargeVitals);
            $("[id$='txtSaturation_Oxygen2_desc']").on('blur', AddDischargeVitals);
            $("[id$='txtsaturationDis']").on('blur', AddDischargeVitals);
            $("[id$='txtOxygen1']").on('blur', AddDischargeVitals);
            $("[id$='chk_OnRoomAirDesc']").on('change', AddDischargeVitals);
            $("[id$='chk_WithOxygenDesc']").on('change', AddDischargeVitals);
            $("[id$='txtotherecdesc']").on('blur', AddDischargeVitals);
            $("[id$='txttxtReceiving_DateDesc']").on('blur', AddDischargeVitals);
            $("[id$='txtRN_Special_Instruction_Desc']").on('change', AddDischargeVitals);
            $("[id$='ddlDischarge_By']").on('change', AddDischargeDetails);
            $("[id$='txtDischarge_On']").on('blur change', AddDischargeDetails);
            $("[id$='txtDiagnosis']").on('blur change input', AddDischargeDetails);
            $("[id$='txtPrevention_Precaution']").on('blur change input', AddDischargeDetails);
            $("[id$='txtNext_Visit']").on('blur change input', AddDischargeDetails);
            $("[id$='txtTreatmentAtDischarge']").on('blur change input', AddDischargeDetails);
            $("[id$='txtFollowUpPlanInstructions']").on('blur change input', AddDischargeDetails);
            $("[id$='txtProcedureRecommended']").on('blur change input', AddDischargeDetails);
            $("[id$='ddlDischargeStatus']").on('change', AddDischargeDetails);
            $("[id$='txtCauseOfReferral']").on('blur change input', AddDischargeDetails);
            $("[id$='ddlReferredTo']").on('change', AddDischargeDetails);
            $("[id$='cbDicharg_Slip']").on('change', AddDischargeDetails);
            $("[id$='cb_death']").on('change', AddDischargeDetails);
            $("[id$='ReferToOPD']").on('change', AddDischargeDetails);

            var selectors = [
                'txtHistoryOfPeresentIllness',
                'txtHistoryOfPastIllness',
                'txtHistoryOfFamily',
                'txtSocioEconomicHistory',
                'txtBirthHistory',
                'txtDrugHistory',
                'txtObstetricHistory',
                'txtAllergiesHistory',
                'txtTreatmentHistory',
                'txtPersonalHistory',
                'txtVaccinationHistory',
                'txtAnyOtherHistory'
            ].map(function (s) { return "[id$='" + s + "']"; }).join(',');

          
            // update on change/blur - works for both user typing and selects (change)
            $(selectors).on('change blur', AddHistory);
            // checkbox change inside entire tab
            $("[id$='ddl_Department']").on('change', AddDoctorCall);
            $("[id$='ddlCallToDoctor']").on('change', AddDoctorCall);
            $("[id$='txtMobileNo']").on('blur', AddDoctorCall);
            $("[id$='txtCallToDoctor']").on('blur', AddDoctorCall);





            
            $('#06').click();
          
            FillMainTestDepartment();
            FillLabTests('');
     
            fillPrimaryDiagnosis("");
            fillFinalDiagnosis("");
            FillMedicene("");
          
            loadDepartments();
            GetSymptomsByDepartment();
            fillSymptoms("000", "");
             
            $('#dvtblSymtomps').slideUp();
            $('#filterExaminations').change(filterExaminations);

           
          
        
            $('#tab09Search').on('input', function () {
                const searchTerm = $(this).val().trim();
                FillLabTests(searchTerm);
            });
            $('#tab10Search').on('input', function () {
                const searchTerm = $(this).val().trim();
                LoadTestByDepartment(searchTerm);
            });
            $('#tab11_01Search').on('input', function () {
                const searchTerm = $(this).val().trim();
                FillMedicene(searchTerm);
            });
            $('#filterMainDepartments').on('change', function () {
                const searchTerm = $('#tab10Search').val().trim();
                LoadTestByDepartment(searchTerm);
            });
            
            

            FillTestsByCategory('002', "");
           
        });
        function AddDischargeDetails() {
            // helpers
            function textOrDash(val) { return (val || '').toString().trim() ? val.toString().trim() : '-'; }
            function shouldShowText(val) { return (val || '').toString().trim().length > 0; }
            function selTextIfValid(sel) {
                var $s = $(sel);
                if (!$s.length) return null;
                var val = $s.val();
                if (val === null || typeof val === 'undefined') return null;
                // treat '0' as the "no selection" sentinel and exclude
                if (val.toString() === '0') return null;
                var txt = $s.find('option:selected').text() || '';
                return txt.toString().trim() ? txt.toString().trim() : null;
            }
            function checkboxYesNo(sel) {
                var $c = $(sel);
                if (!$c.length) return null;
                return $c.is(':checked') ? 'Yes' : 'No';
            }
            // read values (use ends-with selectors for ASP.NET ids)
            var dischargeByText = selTextIfValid("[id$='ddlDischarge_By']");
            var dischargeOnVal = $("[id$='txtDischarge_On']").val(); // do not exclude discharge date even if blank
            var diagnosis = $("[id$='txtDiagnosis']").val();
            var advice = $("[id$='txtPrevention_Precaution']").val();
            var followUp = $("[id$='txtNext_Visit']").val();
            var treatment = $("[id$='txtTreatmentAtDischarge']").val();
            var followUpPlan = $("[id$='txtFollowUpPlanInstructions']").val();
            var procedureRec = $("[id$='txtProcedureRecommended']").val();
            var dischargeStatusText = selTextIfValid("[id$='ddlDischargeStatus']");
            var causeOfReferral = $("[id$='txtCauseOfReferral']").val();
            var referredToText = selTextIfValid("[id$='ddlReferredTo']");
            var dischargeSlip = checkboxYesNo("[id$='cbDicharg_Slip']");
            var death = checkboxYesNo("[id$='cb_death']");
            // ReferToOPD has ClientIDMode=Static so it's safe to query by id; try label fallback too
            var referToOPD = checkboxYesNo("[id$='ReferToOPD']");

            // Build a list of rows to render. Each item: { field: 'Label', value: '...' }
            var rows = [];

            // Discharge By (select) - show only if selected value != '0'
            if (dischargeByText) rows.push({ field: $("[id$='lblDischarge_By']").text() || 'Advise By', value: dischargeByText });

            // Discharged Date - show always (even if empty)
            rows.push({ field: $("[id$='lblDischarge_On']").text() || 'Discharged Date', value: textOrDash(dischargeOnVal) });

            if (shouldShowText(diagnosis)) rows.push({ field: $("[id$='lblDiagnosis']").text() || 'Diagnosis', value: diagnosis.trim() });
            if (shouldShowText(advice)) rows.push({ field: $("[id$='lblPrevention_Precaution']").text() || 'Advice', value: advice.trim() });
            if (shouldShowText(followUp)) rows.push({ field: $("[id$='Label13']").text() || 'Follow Up', value: followUp.trim() });

            if (shouldShowText(treatment)) rows.push({ field: $("[id$='lblTreatmentAtDischarge']").text() || 'Treatment At Discharge', value: treatment.trim() });
            if (shouldShowText(followUpPlan)) rows.push({ field: $("[id$='lblFollowUpPlanInstructions']").text() || 'Follow Up Plan & Instructions', value: followUpPlan.trim() });
            if (shouldShowText(procedureRec)) rows.push({ field: $("[id$='lblProcRecommended']").text() || 'Procedure Recommended', value: procedureRec.trim() });

            if (dischargeStatusText) rows.push({ field: $("[id$='lblDischargeStatus']").text() || 'Discharge Status', value: dischargeStatusText });
            if (shouldShowText(causeOfReferral)) rows.push({ field: $("[id$='lblCauseOfReferral']").text() || 'Cause Of Referral', value: causeOfReferral.trim() });
            if (referredToText) rows.push({ field: $("[id$='lblReferredTo']").text() || 'Referred To', value: referredToText });

            // Checkboxes: show label and Yes/No. If the checkbox control exists, show row.
            if ($("[id$='cbDicharg_Slip']").length) {
                var labelText = $("[id$='Label14']").text() || 'Discharge Slip';
                rows.push({ field: labelText, value: dischargeSlip || 'No' });
            }
            if ($("[id$='cb_death']").length) {
                var labelDeath = $("[id$='lbldeath']").text() || 'Death';
                rows.push({ field: labelDeath, value: death || 'No' });
            }
            if ($("[id$='ReferToOPD']").length) {
                // try to find an associated label; fallback to text
                var lbl = $("label[for='ReferToOPD']").text() || $("label[for='ReferOPD']").text() || 'Refer To OPD';
                rows.push({ field: lbl, value: referToOPD || 'No' });
            }

            // Render into table (single row per field). If none (except discharge date), table will still show discharge date.
            var $tbody = $('#tblDischargeDetails tbody');
            var $container = $('#divtblDischargeDetails');
            $tbody.empty();

            rows.forEach(function (r) {
                var $tr = $('<tr>');
                $tr.append($('<td>').text(r.field));
                $tr.append($('<td>').text(r.value));
                $tbody.append($tr);
            });

            // show/hide container based on presence of any rows (we always have Discharge Date row at least)
            if (rows.length) $container.slideDown(); else $container.slideUp();
        }

        function bindDate() {
            $("#ctl00_MainContent_txtExpected_Discharge_Date").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#ctl00_MainContent_txtNext_Visit").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#ctl00_MainContent_txtDischarge_On").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#ctl00_MainContent_txtMo_Time").datetimepicker({ datepicker: false, format: 'H:i:s' });
            $("#ctl00_MainContent_txtMo_Operation_Date").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#ctl00_MainContent_txtMo_Next_Visit").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#ctl00_MainContent_txtLMP").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#ctl00_MainContent_txtDateofDeath").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#ctl00_MainContent_txtTimeOfDeath").datetimepicker({ datepicker: false, format: 'H:i:s' });

        }
        function AddDoctorCall() {
            var dept = $("[id$='ddl_Department'] option:selected").text() || '-';
            var doctor = $("[id$='ddlCallToDoctor'] option:selected").text() || '-';
            var mobile = $("[id$='txtMobileNo']").val() || '-';
            var notes = $("[id$='txtCallToDoctor']").val() || '-';

            var tbody = $('#tblDoctorCalls tbody');
            var container = $('#divtblDoctorCalls');

            // single-row behaviour: clear and show current values
            tbody.empty();

            var row = $('<tr>');
            row.append($('<td>').attr('data-label', 'Department').text(dept));
            row.append($('<td>').attr('data-label', 'Doctor').text(doctor));
            row.append($('<td>').attr('data-label', 'Mobile No').text(mobile));
            row.append($('<td>').attr('data-label', 'Doctor Notes').text(notes));

            tbody.append(row);
            container.slideDown();
        }

        function AddDischargeVitals() {
            var pulse = $("[id$='txtPulseRate']").val() || '-';
            var bp = $("[id$='txtBPDischarge']").val() || '-';
            var rhythm = $("[id$='ddlRhythmdischarge'] option:selected").text() || '-';
            var temp = $("[id$='txtTempdisch']").val() || '-';
            var volume = $("[id$='ddlvolumedisc'] option:selected").text() || '-';
            var resp = $("[id$='txtRespRateDesc']").val() || '-';
            var o2sat = $("[id$='txtSaturation_Oxygen2_desc']").val() || '-';
            var percentage = $("[id$='txtsaturationDis']").val() || '-';
            var liters = $("[id$='txtOxygen1']").val() || '-';

            var roomAir = $("[id$='chk_OnRoomAirDesc']").length ? ($("[id$='chk_OnRoomAirDesc']").is(':checked') ? 'Yes' : 'No') : '-';
            var withO2 = $("[id$='chk_WithOxygenDesc']").length ? ($("[id$='chk_WithOxygenDesc']").is(':checked') ? 'Yes' : 'No') : '-';

            var others = $("[id$='txtotherecdesc']").val() || '-';
            var received = $("[id$='txttxtReceiving_DateDesc']").val() || '-';
            var instruction = $("[id$='txtRN_Special_Instruction_Desc']").val() || '-';

            var tbody = $('#tblDischargeVitals tbody');
            var tableContainer = $('#divtblDischargeVitals');

            // single-row behaviour (clear existing and add current)
            tbody.empty();

            var newRow = $('<tr>');
            newRow.append($('<td>').text(pulse));
            newRow.append($('<td>').text(bp));
            newRow.append($('<td>').text(rhythm));
            newRow.append($('<td>').text(temp));
            newRow.append($('<td>').text(volume));
            newRow.append($('<td>').text(resp));
            newRow.append($('<td>').text(o2sat));
            newRow.append($('<td>').text(percentage));
            newRow.append($('<td>').text(liters));
            newRow.append($('<td>').text(roomAir));
            newRow.append($('<td>').text(withO2));
            newRow.append($('<td>').text(others));
            newRow.append($('<td>').text(received));
            newRow.append($('<td>').text(instruction));

            tbody.append(newRow);
            tableContainer.slideDown();
        }
        document.addEventListener('DOMContentLoaded', function () {
            // delegates and initial wiring kept minimal and simple

            // checkbox changes inside #tab04
            var tab = document.getElementById('tab04');
            if (tab) {
                tab.addEventListener('change', function (e) {
                    var t = e.target;
                    if (t && t.tagName === 'INPUT' && t.type === 'checkbox') handleCheckboxChange(t);
                });
            }

            // simple remove button delegation
            document.addEventListener('click', function (e) {
                var btn = e.target;
                if (btn && btn.classList && btn.classList.contains('remove-find-simple')) {
                    var key = btn.getAttribute('data-key');
                    removeRowSimple(key);
                }
            });

            // description textareas (ends-with selectors)
            var descSelectors = [
                "[id$='TextBoxCvs']",
                "[id$='TextBoxGpe']",
                "[id$='TextBoxResp']",
                "[id$='TextBoxGit']",
                "[id$='TextBoxCns']",
                "[id$='txtFurtherExplanation']"
            ].join(',');
            var descs = document.querySelectorAll(descSelectors);
            descs.forEach(function (d) {
                d.addEventListener('input', function () { handleDescriptionChange(d); });
                // initial populate if has value
                if ((d.value || '').trim()) handleDescriptionChange(d);
            });

            // initial sync for pre-checked boxes
            var chks = tab ? tab.querySelectorAll("input[type='checkbox']") : [];
            chks.forEach(function (c) {
                if (c.checked) handleCheckboxChange(c);
            });

            // try common id suffixes for GCS bits
            var eor = byEndsWith('txtEOR') || byEndsWith('ctl00_MainContent_txtEOR');
            var mr = byEndsWith('txtMR') || byEndsWith('ctl00_MainContent_txtMR');
            var vr = byEndsWith('txtVR') || byEndsWith('ctl00_MainContent_txtVR');
            var acc = byEndsWith('txtAcc') || byEndsWith('ctl00_MainContent_txtAcc') || byEndsWith('txtAcc');

            if (eor) {
                wireField(eor, 'Eye Opening Response', 'tblGCS');
            }
            if (mr) {
                wireField(mr, 'Motor Response', 'tblGCS');
            }
            if (vr) {
                wireField(vr, 'Verbal Response', 'tblGCS');
            }
            if (acc) {
                // accumulated may be updated programmatically; monitor it
                monitorField(acc, 'Accumulated', 'tblGCS');
            }
        });
        function Get_Doctor_Info() {

            var Doctor_Val = document.getElementById('<%= ddl_Department.ClientID%>').value;
              if (Doctor_Val == 0) {
                  $('#ctl00_MainContent_ddlCallToDoctor').val('');
              }
              else {
                  var department_Id = $('#ctl00_MainContent_ddl_Department').val();
                  $.ajax({
                      type: "POST",
                      url: "NewEmergencyCase.aspx/Get_Doctor",
                      data: JSON.stringify({
                          "department_Id": department_Id
                      }),
                      contentType: "application/json; charset=utf-8",
                      dataType: "json",
                      success: function (response) {

                          var options = '<option value="0">Please Select </option>';
                          var Parsed_Data = JSON.parse(response.d);
                          $.each(Parsed_Data, function (key, value) {

                              options += '<option value="' + value.Emp_ID + '" >' + value.Emp_Name + '</option>';
                          });
                          $('#ctl00_MainContent_ddlCallToDoctor').html(options);
                          $("#ctl00_MainContent_ddlCallToDoctor").select2();

                      },
                      failure: function (response) {
                          alert(response.d);
                      }
                  });
              }
        }

        function Get_Doctor_MobileInfo() {

            var doctor = document.getElementById('<%= ddlCallToDoctor.ClientID%>').value;
            var EmployeeId = $('#ctl00_MainContent_ddlCallToDoctor').val();
            $.ajax({
                type: "POST",
                url: "NewEmergencyCase.aspx/Get_Doctor_Mobile",
                data: JSON.stringify({
                    "DoctorId": EmployeeId
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    if (response.d == "") {
                        alert("Mobile no. of Selected Doctor is not Available !");
                        $("#ctl00_MainContent_txtMobileNo").val("____-_______");
                    }
                    else {
                        $("#ctl00_MainContent_txtMobileNo").val(response.d);
                    }

                },
                failure: function (response) {
                    alert(response.d);
                    console.log(response.responseJSON.Message);
                }
            });
        }
        /* ====== small helpers (single responsibility) ====== */

        function byEndsWith(suffix) {
            return document.querySelector("[id$='" + suffix + "']");
        }

        function labelForCheckbox(el) {
            var id = el.id || '';
            var shortId = id.split('_').pop();
            var lab = document.querySelector("label[for='" + id + "']") || document.querySelector("label[for='" + shortId + "']");
            if (lab) return (lab.textContent || id).trim();
            return id;
        }

        function tableIdFromElement(el) {
            var node = el;
            while (node && !node.classList.contains('subtabs')) node = node.parentElement;
            if (!node) return null;
            var sid = node.id || '';
            if (sid.indexOf('subTab') === 0) return 'tbl' + sid.replace('subTab', '');
            return null;
        }

        /* ====== row operations (create / update / remove) ====== */

        // add a row or update existing row text if it already exists
        function addRowSimple(tableId, key, text) {
            if (!tableId) return;
            var tbody = document.querySelector('#' + tableId + ' tbody');
            if (!tbody) return;

            var existing = tbody.querySelector("tr[data-key='" + key + "']");
            if (existing) {
                // update text cell
                updateRowSimple(key, text);
                return;
            }

            var tr = document.createElement('tr');
            tr.setAttribute('data-key', key);

            var tdText = document.createElement('td');
            tdText.textContent = text || '-';

            var tdAction = document.createElement('td');
            tdAction.style.width = '48px';

            var btn = document.createElement('button');
            btn.type = 'button';
            btn.className = 'remove-find-simple';
            btn.setAttribute('data-key', key);
            btn.setAttribute('aria-label', 'Remove');
            btn.textContent = '×';

            tdAction.appendChild(btn);
            tr.appendChild(tdText);
            tr.appendChild(tdAction);
            tbody.appendChild(tr);

            // show parent container if hidden (simple walk)
            var el = document.getElementById(tableId);
            var container = null;
            if (el && el.closest) container = el.closest('[id^="divtbl"]');
            if (!container) {
                while (el && el.id && el.id.indexOf('divtbl') === -1) el = el.parentElement;
                container = el;
            }
            if (container) container.style.display = '';
        }

        // only updates the first td of the matching row
        function updateRowSimple(key, text) {
            if (!key) return;
            var row = document.querySelector("tr[data-key='" + key + "']");
            if (!row) return;
            var td = row.querySelector('td');
            if (td) td.textContent = text || '-';
        }

        // remove row and try to clear/uncheck original control
        function removeRowSimple(key) {
            if (!key) return;
            var rows = document.querySelectorAll("tr[data-key='" + key + "']");
            rows.forEach(function (r) { r.parentElement && r.parentElement.removeChild(r); });

            // try to uncheck checkbox by id or ends-with
            var chk = document.getElementById(key);
            if (!chk) {
                var inputs = document.querySelectorAll("input[id$='" + key + "']");
                if (inputs.length) chk = inputs[0];
            }
            if (chk && chk.type === 'checkbox') chk.checked = false;

            // try clear input/textarea
            var txt = document.getElementById(key);
            if (txt && (txt.tagName === 'TEXTAREA' || (txt.tagName === 'INPUT' && txt.type === 'text'))) txt.value = '';

            // hide empty containers simple
            ['divtblCVS', 'divtblGCS', 'divtblGPE', 'divtblRESP', 'divtblGIT', 'divtblCNS'].forEach(function (did) {
                var d = document.getElementById(did);
                if (!d) return;
                var has = d.querySelector('tbody tr');
                if (!has) d.style.display = 'none';
            });
        }

        /* ====== validation and field handlers ====== */

        // validation: allow single-digit numeric GCS parts (e.g., "4"), allow "3/15" etc.
        // keep very permissive for free text but require at least one alphanumeric character
        function isValidGCSValue(val) {
            if (!val) return false;
            val = (val + '').trim();
            if (!val) return false;
            // If contains slash, require digits / digits
            if (val.indexOf('/') !== -1) {
                return /^\s*\d+\s*\/\s*\d+\s*$/.test(val);
            }
            // allow single digits or any value containing an alphanumeric char
            return /[A-Za-z0-9]/.test(val);
        }

        // wire a simple text field to update its row on input/change/blur
        function wireField(el, label, tableId) {
            if (!el) return;
            var handler = function () { handleGCSField(el, label, tableId); };
            el.addEventListener('input', handler);
            el.addEventListener('change', handler);
            el.addEventListener('blur', handler);
            if ((el.value || '').toString().trim()) handler();
        }

        // monitor programmatic updates on a field via polling (idempotent)
        function monitorField(el, label, tableId) {
            if (!el) return;
            if (el._gcsMonitor) return; // already monitoring
            el._gcsMonitor = true;
            var last = (el.value || '').toString();
            if (last.trim()) handleGCSField(el, label, tableId);
            setInterval(function () {
                var cur = (el.value || '').toString();
                if (cur !== last) {
                    last = cur;
                    handleGCSField(el, label, tableId);
                }
            }, 300);
        }

        // main handler for GCS-style fields (keeps logic simple)
        function handleGCSField(el, label, tableId) {
            if (!el) return;
            var raw = (el.value || '').toString();
            var key = el.id || '';
            var text = label + ': ' + raw;

            if (isValidGCSValue(raw)) {
                // if row exists update it, otherwise add it
                var exists = !!document.querySelector("tr[data-key='" + key + "']");
                if (exists) updateRowSimple(key, text);
                else addRowSimple(tableId, key, text);
            } else {
                removeRowSimple(key);
            }
        }

        /* ====== checkbox / description handlers (simple) ====== */

        function handleCheckboxChange(el) {
            var checked = el.checked;
            var key = el.id || '';
            var tbl = tableIdFromElement(el);
            var label = labelForCheckbox(el);
            if (checked) addRowSimple(tbl, key, label);
            else removeRowSimple(key);
        }

        function handleDescriptionChange(el) {
            var val = (el.value || '').trim();
            var key = el.id || '';
            var tbl = tableIdFromElement(el);
            var prefix = '';
            var node = el;
            while (node && !node.classList.contains('subtabs')) node = node.parentElement;
            if (node && node.id) prefix = node.id.replace('subTab', '') + ' Details';
            var text = prefix + ': ' + val;
            if (val.length) addRowSimple(tbl, key, text);
            else removeRowSimple(key);
        }
        function ROPFunction() {
            if ($("#ctl00_MainContent_ctl00_MainContent_txtEOR").val().split('/')[0] > 0 && $("#ctl00_MainContent_ctl00_MainContent_txtEOR").val().split('/')[0] <= 4) {
                var first_integer = $("#ctl00_MainContent_ctl00_MainContent_txtEOR").val().split('/')[0];
                var Second_integer = $("#ctl00_MainContent_txtMR").val().split('/')[0];
                var Third_integer = $("#ctl00_MainContent_txtVR").val().split('/')[0];
                if (first_integer == "_") first_integer = 0;
                if (Second_integer == "_") Second_integer = 0;
                if (Third_integer == "_") Third_integer = 0;
                var sum = parseInt(first_integer) + parseInt(Second_integer) + parseInt(Third_integer);
                $("#ctl00_MainContent_txtAcc").val('' + sum + '/15');

                return true;
            }
            else {
                alert('Please input a number between 1 and 4:');
                return $("#ctl00_MainContent_ctl00_MainContent_txtEOR").val('_/4');

            }
        }
        function MRFunction() {
            if ($("#ctl00_MainContent_txtMR").val().split('/')[0] > 0 && $("#ctl00_MainContent_txtMR").val().split('/')[0] <= 5) {
                var first_integer = $("#ctl00_MainContent_ctl00_MainContent_txtEOR").val().split('/')[0];
                var Second_integer = $("#ctl00_MainContent_txtMR").val().split('/')[0];
                var Third_integer = $("#ctl00_MainContent_txtVR").val().split('/')[0];
                if (first_integer == "_") first_integer = 0;
                if (Second_integer == "_") Second_integer = 0;
                if (Third_integer == "_") Third_integer = 0;
                var sum = parseInt(first_integer) + parseInt(Second_integer) + parseInt(Third_integer);
                $("#ctl00_MainContent_txtAcc").val('' + sum + '/15');
                return true;
            }
            else {
                alert('Please input a number between 1 and 5:');
                return $("#ctl00_MainContent_txtMR").val('_/5');
            }
        }
        function VRFunction() {

            if ($("#ctl00_MainContent_txtVR").val().split('/')[0] > 0 && $("#ctl00_MainContent_txtVR").val().split('/')[0] <= 6) {
                var first_integer = $("#ctl00_MainContent_ctl00_MainContent_txtEOR").val().split('/')[0];
                var Second_integer = $("#ctl00_MainContent_txtMR").val().split('/')[0];
                var Third_integer = $("#ctl00_MainContent_txtVR").val().split('/')[0];
                if (first_integer == "_") first_integer = 0;
                if (Second_integer == "_") Second_integer = 0;
                if (Third_integer == "_") Third_integer = 0;
                var sum = parseInt(first_integer) + parseInt(Second_integer) + parseInt(Third_integer);
                $("#ctl00_MainContent_txtAcc").val('' + sum + '/15');
                return true;
            }
            else {

                alert('Please input a number between 1 and 6:');
                return $("#ctl00_MainContent_txtVR").val('_/6');
            }
        }
        function AddHistory() {
            // mapping of input suffix => display label
            var fields = [
                { id: 'txtHistoryOfPeresentIllness', label: 'History Of Present Illness' },
                { id: 'txtHistoryOfPastIllness', label: 'Past Medical/Surgical History' },
                { id: 'txtHistoryOfFamily', label: 'Family History' },
                { id: 'txtSocioEconomicHistory', label: 'SocioEconomic History' },
                { id: 'txtBirthHistory', label: 'Birth History' },
                { id: 'txtDrugHistory', label: 'Drug History' },
                { id: 'txtObstetricHistory', label: 'Obstetric History' },
                { id: 'txtAllergiesHistory', label: 'Allergies History' },
                { id: 'txtTreatmentHistory', label: 'Treatment History' },
                { id: 'txtPersonalHistory', label: 'Personal History' },
                { id: 'txtVaccinationHistory', label: 'Vaccination History' },
                { id: 'txtAnyOtherHistory', label: 'Any Other History' }
            ];

            var tbody = $('#tblHistory tbody');
            tbody.empty();

            // collect non-empty entries
            var any = false;
            fields.forEach(function (f) {
                var $el = $("[id$='" + f.id + "']");
                if ($el.length) {
                    var val = ($el.val() || '').toString().trim();
                    if (val.length) {
                        any = true;
                        // create single-cell row like: "History Of Present Illness: text here"
                        var row = $('<tr>').html('<td>' + f.label + ': ' + escapeHtml(val) + '</td>');
                        tbody.append(row);
                    }
                }
            });

            var container = $('#divtblHistory');
            if (any) {
                if (container.is(':hidden')) container.slideDown();
            } else {
                // no data -> hide and remove any rows (already cleared)
                if (container.is(':visible')) container.slideUp();
            }
        }

        // simple HTML-escape to avoid accidental markup injection from textarea values
        function escapeHtml(str) {
            return String(str)
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#39;');
        }
        // Initialize - show first tab
        document.addEventListener('DOMContentLoaded', function () {
            document.getElementById('subTabCVS').style.display = 'block';
        });
        function AddAdmission() {
            // Read values (use ends-with selectors so this works with ASP.NET generated ids)
            var triage = $("[id$='ddlPatientCondition'] option:selected").text() || '-';
            var doctor = $("[id$='ddlDoctor'] option:selected").text() || '-';
            var ward = $("[id$='ddlWard_No'] option:selected").text() || '-';
            var bedNo = $("[id$='txtBed_No']").val() || '-';
            var fee = $("[id$='txtadmissionfee']").val() || '-';
            var admissionDate = $("[id$='txtAdmission_Date']").val() || '-';

            // Table body and container
            var tbody = $('#tblAdmissions tbody');
            var tableContainer = $('#divtblAdmissions');

            // Clear existing rows and add a single updated row
            tbody.empty();

            var newRow = $('<tr>').html(
                '<td>' + triage + '</td>' +
                '<td>' + doctor + '</td>' +
                '<td>' + ward + '</td>' +
                '<td>' + bedNo + '</td>' +
                '<td>' + fee + '</td>' +
                '<td>' + admissionDate + '</td>'
            );

            tbody.append(newRow);

            // Reveal the container (keeps same behavior as your demo)
            tableContainer.slideDown();
        }


        function fillSymptomsInModal(selectedValue, searchTerm) {
            var options = '';

            $.ajax({
                type: "POST",
                url: "NewEmergencyCase.aspx/GetSymptoms",
                data: JSON.stringify({ searchValue: searchTerm }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = response.d ? JSON.parse(response.d) : response;
                    $.each(data, function (key, value) {



                        options += '<div class="symptom-row" style="display: flex; align-items: center; justify-content: space-between;">' +
                            '<div style="display: flex; align-items: center;">' +
                            '<input type="checkbox" id="chk_' + value.DataValue_Name + '" ' +
                            'value="' + value.DataValue_Name + '" ' +
                            'class="symptom_checkbox" ' +
                            'onclick="this.checked ? AddSymtomRowInModal(\'' + selectedValue + '\', \'' + value.DataValue_Name + '\', \'' + value.DataValue_Description + '\') : RemoveSymtomRowInModal(\'' + value.DataValue_Name + '\')" />' +
                            '<label for="chk_' + value.DataValue_Name + '" style="margin-left: 8px;">' + value.DataValue_Description + '</label>' +
                            '</div>' +
                            '</div>';
                    });
                    $('#symptoms').html(options);

                },
                error: function (xhr, status, error) {
                    console.error("Error searching symptoms:", error);
                }
            });
        }
        function RemoveSymtomRowInModal(id) {
            // Trim and ensure consistent comparison
            id = id.toString().trim();

            // Find and remove matching rows
            $('#tblsymptomspreview tbody tr').each(function () {
                var row = $(this);
                var symptomId = row.find('input.symptomid').val().toString().trim();

                if (symptomId === id) {
                    row.remove();
                    return false; // Exit the loop early since we found our match
                }
            });

            // Check if table is empty after removal
            if ($('#tblsymptomspreview tbody tr').length === 0) {
                $('#symptomspreview').slideUp();
            }

            // Also uncheck the corresponding checkbox
            $('#chk_' + id.replace(/\s+/g, '_')).prop('checked', false);
        }
        function AddSymtomRowInModal(deptId, id, name) {
            var checksymtomadded = false;
            // Check through all table rows
            $('#tblsymptomspreview tbody tr').each(function () {
                var row = $(this);
                var rowDeptId = row.find('input.deptid').val();
                var rowSymptomId = row.find('input.symptomid').val();

                // Check if both department ID and symptom ID match
                if (rowDeptId == deptId && rowSymptomId == id) {
                    checksymtomadded = true;
                    return false; // Break out of the each loop early
                }
            });

            if (checksymtomadded === false) {


                var html = '<tr> <td style="display:none;"><input type="text" class="deptid" value="' + deptId + '"/></td>' +
                    '<td style="display:none;"><input type="text" class="symptomid" value="' + id + '"/></td>' +
                    '<td> ' + name + ' </td>' +
                    '<td><a href="#" onclick="RemoveSymtomRowInModal(\'' + id + '\')"><i class="fa fa-times"></i></a></td></tr>';


                $('#tblsymptomspreview tbody').append(html);
                $('#symptomspreview').slideDown();


            } else {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Symptom already added',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
            }
        }
        function GetSymptomsByDepartment() {
            $.ajax({
                url: 'NewEmergencyCase.aspx/GetSymptomsData',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                data: JSON.stringify({}),
                success: function (response) {
                    var symptoms = JSON.parse(response.d);
                    $('#tblsymptomspreview tbody').empty();

                    if (symptoms.length > 0) {
                        $.each(symptoms, function (index, symptom) {
                            var html = '<tr>' +
                                '<td style="display:none;">' +
                                '<input type="text" class="deptid" value="' + symptom.CategoryId + '"/>' +
                                '</td>' +
                                '<td style="display:none;">' +
                                '<input type="text" class="symptomid" value="' + symptom.SymptomId + '"/>' +
                                '</td>' +
                                '<td>' + symptom.Description + '</td>' +
                                '<td><a href="#" onclick="RemoveSymtomRowInModal(\'' + symptom.SymptomId + '\')"><i class="fa fa-times"></i></a></td>' +
                                '</tr>';

                            $('#tblsymptomspreview tbody').append(html);
                        });
                        $('#symptomspreview').slideUp();
                    }
                },
                error: function (xhr, status, error) {
                    console.error('Error loading symptoms:', error);
                    alert('Failed to load symptoms data');
                }
            });
        }
        function saveSymptomsToDatabase() {
            // Array to store all symptom data
            var symptomsData = [];

            // Loop through each row in the table
            $('#tblsymptomspreview tbody tr').each(function () {
                var row = $(this);
                var deptId = row.find('.deptid').val();
                var symptomId = row.find('.symptomid').val();

                // Add to our data array
                symptomsData.push({
                    DepartmentId: deptId,
                    SymptomId: symptomId
                });
            });

            // Only proceed if we have data
            if (symptomsData.length > 0) {
                $.ajax({
                    type: "POST",
                    url: "NewEmergencyCase.aspx/SaveSymptoms", // Update with your actual endpoint
                    data: JSON.stringify({ symptoms: symptomsData }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        if (response.d) {
                            // Success handling
                            Swal.fire({
                                icon: 'success',
                                title: 'Success!',
                                text: 'Symptoms saved successfully',
                                showConfirmButton: false,
                                timer: 2000
                            });
                        }
                        $('#filterDepartments').val("000");
                        fillSymptoms("000", "");
                        $('#manageSymptomsModal').modal('hide')
                    },
                    error: function (xhr, status, error) {
                        // Error handling
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Failed to save symptoms: ' + error,
                            showConfirmButton: true
                        });
                        console.error("Error saving symptoms:", error);
                    }
                });
            } else {
                Swal.fire({
                    icon: 'warning',
                    title: 'No Data',
                    text: 'No symptoms to save',
                    showConfirmButton: false,
                    timer: 2000
                });
            }
        }
        function AddSymptomByModal(id, name) {
            $('#AddSymptomsByModal').modal('show');
            $('#symptomName').val(name);



            // Remove any existing click handlers to prevent duplicates
            $('#saveSymptomByModal').off('click').on('click', function () {
                var checksymtomadded = false;
                var Duration = $('#duration').val();
                var DurationSuffix = $('#durationSuffix').val();
                var Remarks = $('#Remarks').val();
                $(".symtopclass").each(function () {
                    var symtomid = $(this).val();
                    if (symtomid == id) {
                        checksymtomadded = true;
                        return false; // Exit the loop early if found
                    }
                });

                if (checksymtomadded === false) {
                    var rowID = uuid();
                    var symp = $('#txtSymtom').val();

                    var html = '<tr> <td style="display:none;"> <input type="hidden" class="symtopclass" value="' + id + '" />' + rowID + ' </td>' +
                        '<td style="display:none;"> ' + id + ' </td>' +
                        '<td> ' + name + ' </td>' +
                        '<td style="display:none;"> ' + Duration + ' </td>' +
                        '<td style="display:none;"> ' + DurationSuffix + ' </td>' +
                        '<td style="display:none;"> ' + Remarks + ' </td>' +
                        '<td> <a href="#" onclick="Delete_Symtom(this)"><i class="fa fa-times"></i></a></td></tr>';

                    if (symp === "") {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Please Fill Symptom First',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                    } else {
                        $('#tblSymtoms tbody').append(html);
                        $('#dvtblSymtomps').slideDown(); // 👈 Show the table container
                        $('#AddSymptomsByModal').modal('hide'); // Close the modal after adding
                    }

                    $('#duration').val("");
                    $('#durationSuffix').val("001");
                    $('#Remarks').val("");
                } else {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Symptom already added',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                }
            });
        }
        function Add_SymtomRow(id, name) {
            var checksymtomadded = false;
            $(".symtopclass").each(function () {
                var symtomid = $(this).val();
                if (symtomid == id) {
                    checksymtomadded = true;
                }
            });

            if (checksymtomadded === false) {
                var rowID = uuid();

                var symp = $('#txtSymtom').val();

                var html = '<tr> <td style="display:none;"> <input type="hidden" class="symtopclass" value="' + id + '" />' + rowID + ' </td>' +
                    '<td style="display:none;"> ' + id + ' </td>' +
                    '<td> ' + name + ' </td>' +
                    '<td  style="display:none;"> ' + $('#txtDuration').val() + ' </td>' +
                    '<td  style="display:none;"> ' + $('#ddlDaysMonthsYears').find('option:selected').text() + ' </td>' +
                    '<td  style="display:none;"> ' + $('#txtRemarks').val() + ' </td>' +
                    '<td> <a href="#" onclick="Delete_Symtom(this)"><i class="fa fa-times"></i></a></td></tr>';

                if (symp === "") {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Fill Symptom First',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                } else {
                    $('#tblSymtoms tbody').append(html);
                    $('#dvtblSymtomps').slideDown(); // 👈 Show the table container
                }

                $('#txtDuration').val("");
                $('#ddlDaysMonthsYears').val("001");
                $('#txtRemarks').val("");
            } else {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Symptom already added',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
            }
        }
        function Delete_Symtom(link) {
            var row = $(link).closest('tr');
            var symptomId = row.find('.symtopclass').val();

            // Uncheck checkbox
            $('#chk_' + symptomId).prop('checked', false);

            // Remove row
            row.remove();

            // 👇 Hide table if no rows left
            if ($('#tblSymtoms tbody tr').length === 0) {
                $('#dvtblSymtomps').slideUp();
            }
        }
        function Remove_SymtomRow(id) {
            $('#tblSymtoms tbody tr').each(function () {
                var row = $(this);
                var hiddenInput = row.find('input.symtopclass');
                if (hiddenInput.val() === id) {
                    row.remove();
                }
                if ($('#tblSymtoms tbody tr').length === 0) {
                    $('#dvtblSymtomps').slideUp();
                }
            });
        }
        function fillSymptoms(categoryId, searchValue) {
            var options = '';
            $.ajax({
                url: 'NewEmergencyCase.aspx/GetCategorizedSymptoms',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                data: JSON.stringify({
                    categoryId: categoryId || "",
                    searchValue: searchValue || ""
                }),
                success: function (response) {
                    var data = response.d ? JSON.parse(response.d) : response;
                    $.each(data, function (key, value) {

                        options += '<div class="symptom-row" style="display: flex; align-items: center; justify-content: space-between; cursor: pointer;" ' +
                            'onclick="document.getElementById(\'chk_' + value.SymptomId + '\').click()">' +
                            '<div style="display: flex; align-items: center;">' +
                            '<input type="checkbox" id="chk_' + value.SymptomId + '" ' +
                            'value="' + value.SymptomId + '" ' +
                            'class="symptom_checkbox" ' +
                            'onclick="event.stopPropagation(); this.checked ? Add_SymtomRow(\'' + value.SymptomId + '\', \'' + value.Description + '\') : Remove_SymtomRow(\'' + value.SymptomId + '\')" />' +
                            '<label for="chk_' + value.SymptomId + '" style="margin-left: 8px; cursor: pointer;">' + value.Description + '</label>' +
                            '</div>' +
                            '<button type="button" class="symptom-add-btn" ' +
                            'onclick="event.stopPropagation(); AddSymptomByModal(\'' + value.SymptomId + '\', \'' + value.Description + '\')" ' +
                            'style="background: none; border: none; cursor: pointer; padding: 8px;">' +
                            '<i class="fa fa-plus-circle" style="font-size: 18px; color: black;"></i>' +
                            '</button>' +
                            '</div>';
                    });
                    $('#allSymptoms').html(options);


                },
                error: function (xhr, status, error) {
                    console.error('Error fetching area data:', error);
                }
            });

            return options;
        }
        function AddNewSymptom() {
            const $divSymptom = $('#divAddNewSymptom');

            if ($divSymptom.is(':visible')) {
                $divSymptom.slideUp(300, function () {
                    $('#NewSymptom').val('');
                });
            } else {
                $divSymptom.slideDown(300, function () {
                    $('#NewSymptom').focus();
                });
            }
        }
        function openManageSymptomsModal() {
            $('#manageSymptomsModal').modal('show');
        }
        function saveSymptom() {
            const SymptomText = $('#NewSymptom').val().trim();

            if (SymptomText === '') {
                alert('Please enter a Symptom before saving.');
                return;
            }
            else {
                $.ajax({
                    type: "POST",
                    url: "NewEmergencyCase.aspx/SaveNewSymptom",
                    data: JSON.stringify({ name: SymptomText }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        if (response.d) {
                            // Success handling
                            Swal.fire({
                                icon: 'success',
                                title: 'Success!',
                                text: 'Symptoms saved successfully',
                                showConfirmButton: false,
                                timer: 2000
                            });
                        }
                        $('#filterDepartments').val("000");
                        fillSymptoms("000", "");
                    },
                    error: function (xhr, status, error) {
                        // Error handling
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Failed to save symptoms: ' + error,
                            showConfirmButton: true
                        });
                        console.error("Error saving symptoms:", error);
                    }
                });
            }
            // Hide the form with slide up animation after saving
            $('#divAddNewSymptom').slideUp(300, function () {
                $('#NewSymptom').val(''); // Clear input after hiding
            });
        }

        function updateHistoryTable() {
            const historyTable = $('#tblHistory tbody');
            const historyContainer = $('#divtblHistory');
            let hasData = false;

            // Clear existing rows
            historyTable.empty();

            // Process each history field
            $('.history-row').each(function () {
                // Find the label element - try multiple selectors to handle different rendered outputs
                const labelElement = $(this).find('span, label, [id*="lbl"], [id*="Label"]').first();
                let labelText = labelElement.text().trim();

                // If no label text found, use a fallback
                if (!labelText) {
                    labelText = "Unknown Field";
                }

                const textbox = $(this).find('textarea, input[type="text"]');
                const value = textbox.val() ? textbox.val().trim() : ''; // Handle undefined values

                if (value) {
                    // Append new row with formatted text
                    historyTable.append(`
                <tr>
                    <td><strong>${labelText}:</strong> ${value}</td>
                </tr>
            `);
                    hasData = true;
                }
            });

            // Show/hide container based on whether there's data
            if (hasData) {
                historyContainer.slideDown();
            } else {
                historyContainer.slideUp();
            }
        }


        function SelectBed(WardID, BedNo) {
            $('#ctl00_MainContent_txtBed_No').val("");
            $('#ctl00_MainContent_txtBed_No').val(BedNo);
            AddAdmission();
        }

        function SelectBedRefer(WardID, BedNo) {
            $('#ctl00_MainContent_txtBedno').val("");
            $('#ctl00_MainContent_txtBedno').val(BedNo);
        }
        function FillWardBeds() {

            PageMethods.FillWardBeds($('#ctl00_MainContent_ddlWard_No').find('option:selected')[0].value, function (res) {
                var WardBeds = JSON.parse(res);
                var rows = '';
                $.each(WardBeds, function (key, value) {
                    if (value.PatientNo == 0) {
                        rows += '<tr> <td> ' + value.PatientNo + ' </td><td> <a href="#" onclick="SelectBed(' + value.WardID + ',' + value.BedNo + ')" style="color:Green"> ' + value.BedNo + ' </a> </td></tr>';
                    }
                    else {
                        rows += '<tr> <td> ' + value.PatientNo + ' </td><td ><font color="red"> ' + value.BedNo + '</font></td></tr>';
                    }
                });
                $('#tblWards tbody tr').remove();
                $('#tblWards tbody').html(rows);
            });
        }

        function FillLabTests(searchValue) {
            debugger;
            var html = '';

            PageMethods.GetLabTests(searchValue, function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    html += '<div class="labtest-row" style="display: flex; align-items: center; justify-content: space-between; padding: 6px 0; cursor: pointer;" ' +
                        'onclick="ShowLabTestDetails(\'' + value.SerialNo + '\', \'' + value.TestName + '\')">' +
                        '<div style="display: flex; align-items: center;">' +
                        '<input type="hidden" id="LabTestchk_' + value.SerialNo + '" ' +
                        'value="' + value.SerialNo + '" ' +
                        'class="labtest_checkbox" ' +
                        'onclick="this.checked ? Add_LabTestRow(\'' + value.SerialNo + '\', \'' + value.TestName + '\') : Remove_LabTestRow(\'' + value.SerialNo + '\')" />' +
                        '<label class="labtest-label" for="LabTestchk_' + value.SerialNo + '" style="margin-left: 8px; font-size: 14px; color: #333; cursor: pointer;">' + value.TestName + '</label>' +
                        '</div>' +
                        '<button type="button" class="labtest-dropdown-btn" ' +
                        'onclick="event.stopPropagation(); ShowLabTestDetails(\'' + value.SerialNo + '\', \'' + value.TestName + '\')" ' +
                        'style="background: none; border: none; cursor: pointer; padding: 2px 8px; margin-left: 8px;">' +
                        '<i class="fa fa-chevron-down" style="font-size: 12px; color: #888;"></i>' +
                        '</button>' +
                        '</div>';
                });
                $('#allLabTests').html(html);
            });
        }
        function Remove_LabTestRow(serial) {
            $('#LabTestchk_' + serial).prop('checked', false);

            $('#tblLabtest tr').has('a[onclick*="Remove_LabTestRow(' + serial + ')"]').remove();


            if ($('#tblLabtest tbody tr').length === 0) {
                $('#dvtblLabtest').slideUp();
            }
        }
        function ShowLabTestDetails(serialNo, testName) {
            const $row = $(`#LabTestchk_${serialNo}`).closest('.labtest-row');
            const $detailsDiv = $(`#labTestDetails_${serialNo}`);
            const $checkbox = $(`#LabTestchk_${serialNo}`);
            const $icon = $(this).find('i');

            // Close all other open details divs first
            $('.labtest-details').not($detailsDiv).each(function () {
                const $otherDiv = $(this);
                const otherSerialNo = $otherDiv.attr('id').replace('labTestDetails_', '');
                const $otherCheckbox = $(`#LabTestchk_${otherSerialNo}`);
                const $otherIcon = $(`#LabTestchk_${otherSerialNo}`).closest('.labtest-row').find('i');

                $otherDiv.slideUp(300, function () {
                    $otherCheckbox.slideDown();
                    $otherIcon.removeClass('fa-chevron-up').addClass('fa-chevron-down');
                });
            });

            if ($detailsDiv.length) {
                // Toggle existing details
                $detailsDiv.slideToggle(300, function () {
                    $checkbox.toggle(!$detailsDiv.is(':visible'));
                });
            } else {
                // Create new details section
                const detailsHtml = `
<div id="labTestDetails_${serialNo}" class="labtest-details" style="display: none; padding: 10px; background: #f5f5f5; margin-top: 5px;">
    <div style="margin-bottom: 8px;">
        <label style="display: block; margin-bottom: 4px; font-size: 13px;">Special Test</label>
        <textarea id="specialTest_${serialNo}" class="form-control" 
                  style="width: 100%; padding: 5px; min-height: 60px;"></textarea>
    </div>
    <div style="margin-bottom: 8px;">
        <label style="display: block; margin-bottom: 4px; font-size: 13px;">Area of Interest</label>
        <textarea id="areaOfInterest_${serialNo}" class="form-control" 
                  style="width: 100%; padding: 5px; min-height: 60px;"></textarea>
    </div>
    <div style="text-align: right;">
        <button type="button" class="btn-add-test" 
                id="addTest_${serialNo}"
                onclick="Add_LabTestRow('${serialNo}','${testName}')"
                style="background: none; border: none; cursor: pointer; color: black;">
            <i class="fa fa-plus-circle" style="color:black"></i> Add Test
        </button>
    </div>
</div>`;

                // Hide checkbox immediately
                $checkbox.slideUp();

                // Insert and show details
                $row.after(detailsHtml)
                    .next('.labtest-details')
                    .slideDown(300, function () {
                        $(`#specialTest_${serialNo}`).focus();
                    });
            }

            // Toggle chevron icon
            $icon.toggleClass('fa-chevron-down fa-chevron-up');
        }
        function Add_LabTestRow(serial, testName) {
            var test = testName;
            var maindpt = "001";

            PageMethods.GetLabTestDDLDetails(test, maindpt, function (res) {
                $.each(JSON.parse(res), function (key, value) {
                    debugger;
                    var Result = 'Result';
                    var test = serial;
                    var date = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A") %>';
                    var dateValue = '<%= DateTime.Now%>';
                    var TestMainDepartmentName;
                    var row;
                    var test_array;
                    var txtSpecialTests = $('#specialTest_' + test).val() || "";
                    var txtAreaOfInterest = $('#areaOfInterest_' + test).val() || "";

                    // Check if this test already exists
                    var existingRow = $('#tblLabtest').find('input[name="testID"][value="' + value.Test_ID + '"]').closest('tr');

                    if (existingRow.length > 0) {
                        // Update existing row instead of creating new one
                        existingRow.find('input[name="testDate"]').val(dateValue);
                        existingRow.find('td:first').text(date);
                        existingRow.find('input[name="txtSpecial_Test"]').val(txtSpecialTests);
                        existingRow.find('td:eq(4)').html('<input type="hidden" name="txtSpecial_Test" value="' + txtSpecialTests + '"/> ' + txtSpecialTests);
                        existingRow.find('input[name="txtArea_Of_Interest"]').val(txtAreaOfInterest);
                        existingRow.find('td:eq(5)').html('<input type="hidden" name="txtArea_Of_Interest" value="' + txtAreaOfInterest + '"/> ' + txtAreaOfInterest);
                        return true; // Continue to next item
                    }

                    if (value.Test_ID != 0) {
                        var row = '<tr>' +
                            '<td style="display:none"><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td>' +
                            '<td><input type="hidden" name="testID" value="' + value.Test_ID + '" />' +
                            '<input type="hidden" name="txtRotation" value="0">' +
                            '<input type="hidden" name="txtGroupCategory" value="0">' +
                            '<input type="hidden" name="txtDeptID" value="001"/> ' +
                            (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') +
                            value.Test_Name +
                            '</td>' +
                            '<td style="display:none">No</td>' +
                            '<td style="display:none">' + Result + '</td>' +
                            '<td><input type="hidden" name="txtSpecial_Test" value="' + txtSpecialTests + '"/> ' +
                            txtSpecialTests + '</td>' +
                            '<td><input type="hidden" name="txtArea_Of_Interest" value="' + txtAreaOfInterest + '"/> ' +
                            txtAreaOfInterest + '</td>' +
                            '<td style="display:none"><input type="hidden" name="rotation" value=""/></td>' +
                            '<td><input type="hidden" name="rowid" value="' + uuid() + '" />' +
                            '<a href="javascript:void(0)" onclick="Remove_LabTestRow(' + test + ')">' +
                            '<i class="fa fa-times"></i></a>' +
                            '</td></tr>';

                        test_array = $('#tblLabtest').find('input[name=testID][value="' + value.Test_ID + '"]');
                    }
                    else {
                        row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="' + value.Group_Category + '"/><input type="hidden" name="txtDeptID" value="001"/> ' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Test_Name + ' </td>   <td>No</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + ctl00_MainContent_txtSpecialTests.value + '"/> ' + ctl00_MainContent_txtSpecialTests.value + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value +
                            ' </td><td><input type="hidden" name="rowid" value="' + uuid() + '" />' +
                            '<a href="javascript:void(0)" onclick="deleteTest(this)">' +
                            '<i class="fa fa-times"></i></a>' +
                            '</td></tr>';
                        test_array = $('#tblLabtest').find('input[name=txtGroupCategory][value="' + value.Group_Category + '"]');
                    }
                    $('#LabTestchk_' + serial).prop('checked', true);
                    $('#tblLabtest').append(row);
                });
                $('#dvtblLabtest').slideDown();
                // Hide the details div after adding/updating
                var $detailsDiv = $('#labTestDetails_' + serial);
                if ($detailsDiv.length) {
                    $detailsDiv.slideUp(300, function () {
                        $('#LabTestchk_' + serial).slideDown();
                        $detailsDiv.remove();
                        $('.labtest-row').find('i.fa-chevron-up').removeClass('fa-chevron-up').addClass('fa-chevron-down');
                    });
                }


            }, function (err) { });
        }

        function LoadTestByDepartment(searchTerm) {
            debugger;
            var maindpt = $('#filterMainDepartments').val();



            if (maindpt == "0") {
                $('#ddlTestList').val("");
                $('#ddlTestList').text("");
                $('#divRotation').slideUp();
                $('#ddlXRayLF').slideUp();
            }
            else if (maindpt == "002") {
                $('#ddlXRayLF').slideUp();
                $('#ddl_xray_rotation').slideUp();
                FillTestsByCategory('002', searchTerm);

            }
            else if (maindpt == "003") {
                $('#ddl_xray_rotation').slideDown();
                FillTestsByCategory('003', searchTerm);
                $('#ddlXRayLF').slideUp();
            }
            else if (maindpt == "004") {
                $('#ddl_xray_rotation').slideUp();
                FillTestsByCategory('004', searchTerm);
                $('#ddlXRayLF').slideUp();

            }
            else if (maindpt == "005") {
                $('#ddl_xray_rotation').slideUp();
                FillTestsByCategory("005", searchTerm);
                $('#divRotation').slideUp();
                $('#ddlXRayLF').slideUp();
            }
            else if (maindpt == "006") {
                $('#ddl_xray_rotation').slideUp();
                FillTestsByCategory("006", searchTerm);
                $('#divRotation').slideUp();
                $('#ddlXRayLF').slideUp();
            }
            else if (maindpt == "007") {
                $('#ddl_xray_rotation').slideUp();
                FillTestsByCategory("007", searchTerm);
                $('#divRotation').slideUp();
                $('#ddlXRayLF').slideUp();
            }
        }
        function FillTestsByCategory(CategoryID, searchTerm) {

            PageMethods.FillTestsByCategory(CategoryID, searchTerm, function (Tests) {
                debugger;
                var html = '';
                $.each(JSON.parse(Tests), function (key, value) {
                    html += '<div class="diagnosticTest-row" style="display: flex; align-items: center; justify-content: space-between; padding: 6px 0; cursor: pointer;" ' +
                        'onclick="ShowDiagnosticTestDetails(\'' + value.Test_ID + '\', \'' + value.Test_Name + '\', \'' + CategoryID + '\')">' +
                        '<div style="display: flex; align-items: center;">' +
                        '<input type="hidden" id="DiagnosticTestchk_' + value.Test_ID + '" ' +
                        'value="' + value.Test_ID + '" ' +
                        'class="diagnostictest_checkbox" ' +
                        'onclick="this.checked ? Add_DiagnosticTestRow(\'' + value.Test_ID + '\', \'' + value.Test_Name + '\') : Remove_DiagnosticTestRow(\'' + value.Test_ID + '\')" />' +
                        '<label class="diagnostictest-label" for="DiagnosticTestchk_' + value.Test_ID + '" style="margin-left: 8px; font-size: 14px; color: #333; cursor: pointer;">' + value.Test_Name + '</label>' +
                        '</div>' +
                        '<button type="button" class="diagnostictest-dropdown-btn" ' +
                        'onclick="event.stopPropagation(); ShowDiagnosticTestDetails(\'' + value.Test_ID + '\', \'' + value.Test_Name + '\', \'' + CategoryID + '\')" ' +
                        'style="background: none; border: none; cursor: pointer; padding: 2px 8px; margin-left: 8px;">' +
                        '<i class="fa fa-chevron-down" style="font-size: 12px; color: #888;"></i>' +
                        '</button>' +
                        '</div>';
                });
                $('#allDiagnosticTest').html(html);
            });
        }
        function FillProcedure(CategoryID, searchTerm) {

            PageMethods.GetProcedure(CategoryID, searchTerm, function (Tests) {
                debugger;
                var html = '';
                $.each(JSON.parse(Tests), function (key, value) {
                    html += '<div class="diagnosticTest-row" style="display: flex; align-items: center; justify-content: space-between; padding: 6px 0; cursor: pointer;" ' +
                        'onclick="ShowDiagnosticTestDetails(\'' + value.Test_ID + '\', \'' + value.Test_Name + '\', \'' + CategoryID + '\')">' +
                        '<div style="display: flex; align-items: center;">' +
                        '<input type="hidden" id="DiagnosticTestchk_' + value.Test_ID + '" ' +
                        'value="' + value.Test_ID + '" ' +
                        'class="diagnostictest_checkbox" ' +
                        'onclick="this.checked ? Add_DiagnosticTestRow(\'' + value.Test_ID + '\', \'' + value.Test_Name + '\') : Remove_DiagnosticTestRow(\'' + value.Test_ID + '\')" />' +
                        '<label class="diagnostictest-label" for="DiagnosticTestchk_' + value.Test_ID + '" style="margin-left: 8px; font-size: 14px; color: #333; cursor: pointer;">' + value.Test_Name + '</label>' +
                        '</div>' +
                        '<button type="button" class="diagnostictest-dropdown-btn" ' +
                        'onclick="event.stopPropagation(); ShowDiagnosticTestDetails(\'' + value.Test_ID + '\', \'' + value.Test_Name + '\', \'' + CategoryID + '\')" ' +
                        'style="background: none; border: none; cursor: pointer; padding: 2px 8px; margin-left: 8px;">' +
                        '<i class="fa fa-chevron-down" style="font-size: 12px; color: #888;"></i>' +
                        '</button>' +
                        '</div>';
                });
                $('#allDiagnosticTest').html(html);
            });
        }
        function ShowDiagnosticTestDetails(serialNo, testName, maindepartment) {
            // Fix: Use consistent class name (changed to match HTML)
            const $row = $(`#DiagnosticTestchk_${serialNo}`).closest('.diagnosticTest-row');
            const $detailsDiv = $(`#DiagnosticTestDetails_${serialNo}`);
            const $checkbox = $(`#DiagnosticTestchk_${serialNo}`);
            const $icon = $row.find('i');

            // Close all other open details divs first
            $('.diagnostictest-details').not($detailsDiv).each(function () {
                const $otherDiv = $(this);
                const otherSerialNo = $otherDiv.attr('id').replace('DiagnosticTestDetails_', '');
                const $otherCheckbox = $(`#DiagnosticTestchk_${otherSerialNo}`);
                const $otherRow = $otherCheckbox.closest('.diagnosticTest-row'); // Fixed class name
                const $otherIcon = $otherRow.find('i');

                $otherDiv.slideUp(300, function () {
                    $otherCheckbox.slideDown();
                    $otherIcon.removeClass('fa-chevron-up').addClass('fa-chevron-down');
                });
            });

            if ($detailsDiv.length) {
                // Toggle existing details
                $detailsDiv.slideToggle(300, function () {
                    $checkbox.toggle(!$detailsDiv.is(':visible'));
                });
            } else {
                // Create new details section
                let detailsHtml = `
<div id="DiagnosticTestDetails_${serialNo}" class="diagnostictest-details" style="display: none; padding: 10px; background: #f5f5f5; margin-top: 5px;">
    <div style="margin-bottom: 8px;">
        <label style="display: block; margin-bottom: 4px; font-size: 13px;">Special Test</label>
        <textarea id="DiagnosticspecialTest_${serialNo}" class="form-control" 
                  style="width: 100%; padding: 5px; min-height: 60px;"></textarea>
    </div>`;

                // Add select dropdown for departments '003' or '004'
                if (maindepartment === '003' || maindepartment === '004') {
                    detailsHtml += `
    <div style="margin-bottom: 8px;">
        <label style="display: block; margin-bottom: 4px; font-size: 13px;">Rotation</label>
        <select class="rotations_${maindepartment}" id="DiagnosticSelect_${serialNo}" class="form-control" style="width: 100%; padding: 5px;">
           
        </select>
    </div>`;
                }

                detailsHtml += `
    <div style="margin-bottom: 8px;">
        <label style="display: block; margin-bottom: 4px; font-size: 13px;">Area of Interest</label>
        <textarea id="DiagnosticareaOfInterest_${serialNo}" class="form-control" 
                  style="width: 100%; padding: 5px; min-height: 60px;"></textarea>
    </div>
    <div style="text-align: right;">
        <button type="button" class="btn-add-test" 
                id="DiagnosticaddTest_${serialNo}"
                onclick="Add_DiagnosticTestRow('${serialNo}','${testName}')"
                style="background: none; border: none; cursor: pointer; color: black;">
            <i class="fa fa-plus-circle" style="color:black"></i> Add Test
        </button>
    </div>
</div>`;

                // Hide checkbox immediately
                $checkbox.slideUp();

                //filldropdowns
                if (maindepartment === '003') {
                    PageMethods.GetRotationsCategoryWise('Test XRay Rotations', function (GetRotations) {
                        debugger;
                        var options = '<option value="0" >Select</option>';
                        $.each(JSON.parse(GetRotations), function (key, value) {
                            debugger;
                            options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                        });
                        $('.rotations_003').html(options);
                        $('.rotations_003').select2();
                    });
                }
                if (maindepartment === '004') {
                    PageMethods.GetRotationsCategoryWise('Test CT Scan Rotations', function (GetRotations) {
                        debugger;
                        var options = '<option value="0" >Select</option>';
                        $.each(JSON.parse(GetRotations), function (key, value) {
                            options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                        });
                        $('.rotations_004').html(options);
                        $('.rotations_004').select2();
                    });
                }
                // Insert and show details - fixed insertion method
                $row.after(detailsHtml);
                const $newDetails = $(`#DiagnosticTestDetails_${serialNo}`);
                $newDetails.slideDown(300, function () {
                    $(`#DiagnosticspecialTest_${serialNo}`).focus();
                });
            }

            // Toggle chevron icon
            $icon.toggleClass('fa-chevron-down fa-chevron-up');
        }
        function Add_DiagnosticTestRow(serial, testName) {
            var test = testName;
            var maindpt = $('#filterMainDepartments').val();

            PageMethods.GetLabTestDDLDetails(test, maindpt, function (res) {
                $.each(JSON.parse(res), function (key, value) {
                    var Result = 'Result';
                    var test = serial;
                    var date = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A") %>';
                    var dateValue = '<%= DateTime.Now%>';
                    var TestMainDepartmentName;
                    var row;
                    var test_array;
                    var txtSpecialTests = $('#DiagnosticspecialTest_' + test).val() || "";  // Fixed ID
                    var txtAreaOfInterest = $('#DiagnosticareaOfInterest_' + test).val() || "";  // Fixed ID
                    var selectedOption = $('#DiagnosticSelect_' + test).find('option:selected');
                    var rotationVal = selectedOption.val() || "0";
                    var rotationText = selectedOption.text() || "";

                    // Check if this test already exists - fixed table selector
                    var existingRow = $('#tblDiagnostictest').find('input[name="testID"][value="' + value.Test_ID + '"]').closest('tr');

                    if (existingRow.length > 0) {
                        // Update existing row instead of creating new one
                        existingRow.find('input[name="testDate"]').val(dateValue);
                        existingRow.find('td:first').text(date);
                        existingRow.find('input[name="txtSpecial_Test"]').val(txtSpecialTests);
                        existingRow.find('td:eq(4)').html('<input type="hidden" name="txtSpecial_Test" value="' + txtSpecialTests + '"/> ' + txtSpecialTests);
                        existingRow.find('input[name="txtArea_Of_Interest"]').val(txtAreaOfInterest);
                        existingRow.find('td:eq(5)').html('<input type="hidden" name="txtArea_Of_Interest" value="' + txtAreaOfInterest + '"/> ' + txtAreaOfInterest);
                        return true; // Continue to next item
                    }

                    if (value.Test_ID != 0) {
                        row = '<tr>' +
                            '<td style="display:none"><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td>' +
                            '<td><input type="hidden" name="testID" value="' + value.Test_ID + '" />' +
                            '<input type="hidden" name="txtRotation" value="0">' +
                            '<input type="hidden" name="txtGroupCategory" value="0">' +
                            '<input type="hidden" name="txtDeptID" value="' + maindpt + '"/> ' +
                            (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') +
                            value.Test_Name +
                            '</td>' +
                            '<td style="display:none">No</td>' +
                            '<td style="display:none">' + Result + '</td>' +
                            '<td><input type="hidden" name="txtSpecial_Test" value="' + txtSpecialTests + '"/> ' +
                            txtSpecialTests + '</td>' +
                            '<td><input type="hidden" name="txtArea_Of_Interest" value="' + txtAreaOfInterest + '"/> ' +
                            txtAreaOfInterest + '</td>' +
                            '<td><input type="hidden" name="rotation" value="' + rotationVal + '"/> ' +
                            rotationText + '</td>' +
                            '<td><input type="hidden" name="rowid" value="' + uuid() + '" />' +

                            '<a href="javascript:void(0)" onclick="Remove_DiagnosticTestRow(\'' + test + '\')">' +  // Fixed function name
                            '<i class="fa fa-times"></i></a>' +
                            '</td></tr>';

                        test_array = $('#tblDiagnostictest').find('input[name=testID][value="' + value.Test_ID + '"]');
                    }
                    else {
                        row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td>' +
                            '<td><input type="hidden" name="testID" value="' + value.Test_ID + '" />' +
                            '<input type="hidden" name="txtRotation" value="0">' +
                            '<input type="hidden" name="txtGroupCategory" value="' + value.Group_Category + '"/>' +
                            '<input type="hidden" name="txtDeptID" value="' + maindpt + '"/> ' +
                            (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Test_Name + '</td>' +
                            '<td>No</td>' +
                            '<td>' + Result + '</td>' +
                            '<td><input type="hidden" name="txtSpecial_Test" value="' + txtSpecialTests + '"/> ' + txtSpecialTests + '</td>' +
                            '<td><input type="hidden" name="txtArea_Of_Interest" value="' + txtAreaOfInterest + '"/> ' + txtAreaOfInterest + '</td>' +
                            '<td><input type="hidden" name="rotation" value="' + rotationVal + '"/> ' + rotationText + '</td>' +
                            '<td><input type="hidden" name="rowid" value="' + uuid() + '" />' +
                            '<a href="javascript:void(0)" onclick="Remove_DiagnosticTestRow(\'' + test + '\')">' +
                            '<i class="fa fa-times" ></i></a>' +
                            '</td></tr>';
                        test_array = $('#tblDiagnostictest').find('input[name=txtGroupCategory][value="' + value.Group_Category + '"]');
                    }

                    // Fixed checkbox ID
                    $('#DiagnosticTestchk_' + serial).prop('checked', true);
                    $('#tblDiagnostictest tbody').append(row);
                });

                $('#dvtblDiagnostictest').slideDown();

                // Hide the details div after adding/updating
                var $detailsDiv = $('#DiagnosticTestDetails_' + serial);
                if ($detailsDiv.length) {
                    $detailsDiv.slideUp(300, function () {
                        $('#DiagnosticTestchk_' + serial).slideDown();
                        $('.diagnosticTest-row').find('i.fa-chevron-up').removeClass('fa-chevron-up').addClass('fa-chevron-down');
                    });
                }
            }, function (err) {
                console.error('Error:', err);
            });
        }
        function Remove_DiagnosticTestRow(serial) {
            // Uncheck the checkbox
            $('#DiagnosticTestchk_' + serial).prop('checked', false);

            // Remove the row by finding the testID input with this serial value
            $('#tblDiagnostictest tr').has('input[name="testID"][value="' + serial + '"]').remove();

            // Hide table if no rows left (checking only data rows, not header)
            if ($('#tblDiagnostictest tbody tr').length === 0) {
                $('#dvtblDiagnostictest').slideUp();
            }
        }

        function FillMedicene(searchValue) {
            var html = '';
            $.ajax({
                url: 'NewEmergencyCase.aspx/getpharmacyitems',
                method: 'POST',
                contentType: 'application/json',
                data: JSON.stringify({ searchString: searchValue || '' }), // Send empty string if searchValue is falsy
                success: function (response) {
                    try {
                        var pharmacyItems = JSON.parse(response.d);
                        if (pharmacyItems.length === 0) {
                            html = '<div style="padding: 10px; color: #666; font-style: italic;">No items found</div>';
                        } else {
                            $.each(pharmacyItems, function (key, value) {
                                html += '<div class="Medicene-row" style="display: flex; align-items: center; justify-content: space-between; padding: 6px 0; cursor: pointer;" ' +
                                    'onclick="ShowMediceneDetails(\'' + value.Item_Code + '\', \'' + value.Description.replace(/'/g, "\\'") + '\')">' +
                                    '<div style="display: flex; align-items: center;">' +
                                    '<input style="display:none" type="checkbox" id="Medicenechk_' + value.Item_Code + '" class="Medicene-checkbox" ' +
                                    'style="margin-right: 8px; cursor: pointer;">' +
                                    '<label class="Medicene-label" for="Medicenechk_' + value.Item_Code + '" ' +
                                    'style="margin-left: 8px; font-size: 14px; color: #333; cursor: pointer;">' +
                                    value.Description +
                                    '</label>' +
                                    '</div>' +
                                    '<button type="button" class="Medicene-dropdown-btn" ' +
                                    'onclick="event.stopPropagation(); ShowMediceneDetails(\'' + value.Item_Code + '\', \'' + value.Description.replace(/'/g, "\\'") + '\')" ' +
                                    'style="background: none; border: none; cursor: pointer; padding: 2px 8px; margin-left: 8px;">' +
                                    '<i class="fa fa-chevron-down" style="font-size: 12px; color: #888;"></i>' +
                                    '</button>' +
                                    '</div>';
                            });
                        }
                        $('#allMedicenes').html(html);
                    } catch (error) {
                        console.error('Error parsing response:', error);
                        $('#allMedicenes').html('<div style="padding: 10px; color: red;">Error loading items</div>');
                    }
                },
                error: function (xhr, status, error) {
                    console.error('Error fetching data:', error);
                    $('#allMedicenes').html('<div style="padding: 10px; color: red;">Error loading items</div>');
                }
            });
        }
        function ShowMediceneDetails(serialNo, testName, isEditMode = false, existingValues = {}) {
            $('#11').click();
            const $row = $(`#Medicenechk_${serialNo}`).closest('.Medicene-row');
            const $detailsDiv = $(`#MediceneDetails_${serialNo}`);
            const $checkbox = $(`#Medicenechk_${serialNo}`);
            const $icon = $(this).find('i');

            // If details div already exists, remove it and return
            if ($detailsDiv.length) {
                $detailsDiv.slideUp(300, function () {
                    $(this).remove();
                });
                return;
            }

            // Remove all other details divs first
            $('.Medicene-details').each(function () {
                const $otherDiv = $(this);
                $otherDiv.slideUp(300, function () {
                    $(this).remove();
                });
            });

            const detailsHtml = `
<div id="MediceneDetails_${serialNo}" class="Medicene-details" style="display: none; padding: 10px; background: #f5f5f5; margin-top: 5px;">
    <!-- First Row - 2 fields -->
    <div class="row">
        <div class="col-md-6" style="margin-bottom: 8px;">
            <label style="display: block; margin-bottom: 4px; font-size: 13px;">Dose</label>
            <select id="mediceneDose_${serialNo}" class="form-control" style="width: 100%; padding: 5px;">
             </select>
        </div>
        <div class="col-md-6" style="margin-bottom: 8px;">
            <label style="display: block; margin-bottom: 4px; font-size: 13px;">Dosage Form</label>
            <select id="mediceneDosageFrom_${serialNo}" class="form-control" style="width: 100%; padding: 5px;">
             </select>
        </div>
    </div>
    
    <!-- Second Row - 2 fields -->
    <div class="row">
        <div class="col-md-6" style="margin-bottom: 8px;">
            <label style="display: block; margin-bottom: 4px; font-size: 13px;">Duration</label>
            <input type="text" id="duration_${serialNo}" class="form-control" 
                  style="width: 100%; padding: 5px;" placeholder="e.g., 7 days">
        </div>
        <div class="col-md-6" style="margin-bottom: 8px;">
            <label style="display: block; margin-bottom: 4px; font-size: 13px;">Route</label>
            <select id="mediceneroute_${serialNo}" class="form-control" style="width: 100%; padding: 5px;">
             </select>
        </div>
    </div>
    
    <!-- Third Row - 1 field -->
    <div class="row">
        <div class="col-md-12" style="margin-bottom: 8px;">
            <label style="display: block; margin-bottom: 4px; font-size: 13px;">Frequency</label>
            <select id="medicenefrequency_${serialNo}" class="form-control" style="width: 100%; padding: 5px;">
             </select>
        </div>
    </div>
    
    <!-- Fourth Row - 1 field -->
    <div class="row">
        <div class="col-md-12" style="margin-bottom: 8px;">
            <label style="display: block; margin-bottom: 4px; font-size: 13px;">Other Instructions</label>
            <select id="otherinstructions_${serialNo}" class="form-control" style="width: 100%; padding: 5px;">
             </select>
        </div>
    </div>
    
    <!-- Special Instructions (full width) -->
    <div style="margin-bottom: 8px;">
        <label style="display: block; margin-bottom: 4px; font-size: 13px;">Special Instructions</label>
        <input type="text" id="specialinstructions_${serialNo}" class="form-control" 
              style="width: 100%; padding: 5px;" placeholder="Any special instructions">
    </div>
    
    <!-- Add Test Button -->
    <div style="text-align: right;">
        <button type="button" class="btn-add-test" 
                id="addTest_${serialNo}"
                onclick="Add_MediceneRow('${serialNo}','${testName}')"
                style="background: none; border: none; cursor: pointer; color: black;">
            <i class="fa fa-plus-circle" style="color:black"></i> ${isEditMode ? 'Update' : 'Add'} Medicene
        </button>
    </div>
</div>`;

            // Insert and show details
            if (isEditMode) {
                $('.editMed').after(detailsHtml);
            } else {
                $row.after(detailsHtml);
            }
            const $newDetailsDiv = $(`#MediceneDetails_${serialNo}`);
            // Populate Dose dropdown and set existing value
            PageMethods.FillDosageQty(function (Dosage) {
                var options = '<option value="">Select Dose</option>';
                $.each(JSON.parse(Dosage), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                });
                $(`#mediceneDose_${serialNo}`).html(options);

                // Set existing value after dropdown is populated
                if (isEditMode && existingValues.dose) {
                    $(`#mediceneDose_${serialNo}`).val(existingValues.dose);
                }
            });
            // Populate all dropdowns and set values
            PageMethods.FillDosageDropDown(function (Dosage) {
                var options = '<option value="">Select Dosage Form</option>';
                $.each(JSON.parse(Dosage), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                });
                $(`#mediceneDosageFrom_${serialNo}`).html(options);

                // Set existing value after dropdown is populated
                if (isEditMode && existingValues.dosageFrom) {
                    $(`#mediceneDosageFrom_${serialNo}`).val(existingValues.dosageFrom);
                }
            });

            PageMethods.FillRoutesDropDown(function (Routes) {
                var options = '<option value="">Select Route</option>';
                $.each(JSON.parse(Routes), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                });
                $(`#mediceneroute_${serialNo}`).html(options);

                // Set existing value after dropdown is populated
                if (isEditMode && existingValues.route) {
                    $(`#mediceneroute_${serialNo}`).val(existingValues.route);
                }
            });

            PageMethods.FillFrequencyDropDown(function (Frequency) {
                var options = '<option value="">Select Frequency</option>';
                $.each(JSON.parse(Frequency), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description +
                        (value.Segment1 ? " - " + value.Segment1 : "") + '</option>';
                });
                $(`#medicenefrequency_${serialNo}`).html(options);

                // Set existing value after dropdown is populated
                if (isEditMode && existingValues.frequency) {
                    $(`#medicenefrequency_${serialNo}`).val(existingValues.frequency);
                }
            });

            PageMethods.FillOtherInstruction(function (Instructions) {
                var options = '<option value="">Select Instruction</option>';
                $.each(JSON.parse(Instructions), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                });
                $(`#otherinstructions_${serialNo}`).html(options);

                // Set existing value after dropdown is populated
                if (isEditMode && existingValues.otherInstruction) {
                    $(`#otherinstructions_${serialNo}`).val(existingValues.otherInstruction);
                }
            });

            // Set other values
            if (isEditMode && existingValues) {
                $(`#duration_${serialNo}`).val(existingValues.duration || '');
                $(`#specialinstructions_${serialNo}`).val(existingValues.specialInstructions || '');
                $(`#mediceneDose_${serialNo}`).val(existingValues.dose || '');

                // Update button text
                $('#addTest_' + serialNo).html('<i class="fa fa-plus-circle" style="color:black"></i> Update');
            }

            // Show the details
            $newDetailsDiv.slideDown(300, function () {
                $(`#mediceneDose_${serialNo}`).focus();
            });
            // Toggle chevron icon
            $icon.toggleClass('fa-chevron-down fa-chevron-up');
        }



        function deleteMedicine(AnchorTag) {

            var row = $(AnchorTag).parents('tr')[0];
            row.remove();

            if ($('#tblMedicines tbody tr').length === 0) {
                $('#dvtblMedicines').slideUp();
            }

        }
        function Add_MediceneRow(serialNo, testName) {
            // Get all values from the dynamic form
            var medicineName = testName;
            var dose = $('#mediceneDose_' + serialNo).val();
            var doseText = $('#mediceneDose_' + serialNo).find('option:selected').text().trim();
            var dosageFrom = $('#mediceneDosageFrom_' + serialNo).val();
            var dosageFromText = $('#mediceneDosageFrom_' + serialNo).find('option:selected').text().trim();
            var duration = $('#duration_' + serialNo).val();
            var route = $('#mediceneroute_' + serialNo).val();
            var routeText = $('#mediceneroute_' + serialNo).find('option:selected').text().trim();
            var frequency = $('#medicenefrequency_' + serialNo).val();
            var frequencyText = $('#medicenefrequency_' + serialNo).find('option:selected').text().trim();
            var otherInstruction = $('#otherinstructions_' + serialNo).val();
            var otherInstructionText = $('#otherinstructions_' + serialNo).find('option:selected').text().trim();
            var specialInstructions = $('#specialinstructions_' + serialNo).val();

            // Get current datetime
            var datetime = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A")%>';
            var datetimeValue = '<%= DateTime.Now%>';

            // Validation
            if (!dose) {
                alert('Please select Dose');
                return false;
            }
            if (!frequency) {
                alert('Please select Frequency');
                return false;
            }
            if (!duration) {
                alert('Please enter Duration');
                return false;
            }

            // Check if we're editing an existing row
            var existingRow = $('input[name="uurowid"][value="' + serialNo + '"]').closest('tr');

            if (existingRow.length > 0) {
                // Update existing row - keeping your exact structure
                existingRow.find('td').eq(0).html('<input type="hidden" name="testDate" value="' + datetimeValue + '">' + datetime);
                existingRow.find('td').eq(1).html('<input type="hidden" name="hdnItemCode" value="0">' + medicineName);
                existingRow.find('td').eq(2).html(frequencyText + '<input type="hidden" class="field-value" value="' + frequency + '">');
                existingRow.find('td').eq(3).html(routeText + '<input type="hidden" class="field-value" value="' + route + '">');
                existingRow.find('td').eq(4).html(duration);
                existingRow.find('td').eq(5).html(specialInstructions);
                existingRow.find('td').eq(6).html(dosageFromText + '<input type="hidden" class="field-value" value="' + dosageFrom + '">');
                existingRow.find('td').eq(7).html(doseText + '<input type="hidden" class="field-value" value="' + dose + '">');
                existingRow.find('td').eq(8).html(otherInstructionText + '<input type="hidden" class="field-value" value="' + otherInstruction + '">');
            } else {
                // Create new row - using your exact string concatenation style
                var row = '<tr>' +
                    '<td style="display:none"><input type="hidden" name="testDate" value="' + datetimeValue + '">' + datetime + '</td>' +
                    '<td><input type="hidden" name="hdnItemCode" value="0">' + medicineName + '</td>' +
                    '<td>' + frequencyText + '<input type="hidden" class="field-value" value="' + frequency + '"></td>' +
                    '<td>' + routeText + '<input type="hidden" class="field-value" value="' + route + '"></td>' +
                    '<td>' + duration + '</td>' +
                    '<td>' + specialInstructions + '</td>' +
                    '<td>' + dosageFromText + '<input type="hidden" class="field-value" value="' + dosageFrom + '"></td>' +
                    '<td>' + doseText + '<input type="hidden" class="field-value" value="' + dose + '"></td>' +
                    '<td>' + otherInstructionText + '<input type="hidden" class="field-value" value="' + otherInstruction + '"></td>' +
                    '<td>' +
                    '<a href="#" onclick="editMedicine(this)">Edit</a> | ' +
                    '<a href="#" onclick="deleteMedicine(this)"><i class="fa fa-times"></i></a>' +
                    '<input type="hidden" name="uurowid" value="' + serialNo + '" />' +
                    '</td>' +
                    '<td style="display:none;"></td>' +
                    '</tr>';

                // Append to table
                $('#tblMedicines tbody').append(row);
            }

            // Rest of your existing code remains exactly the same...
            $('#dvtblMedicines').slideDown();
            $('#MediceneDetails_' + serialNo).slideUp();

            if (existingRow.length === 0) {
                $('#mediceneDose_' + serialNo).val('');
                $('#mediceneDosageFrom_' + serialNo).val('');
                $('#duration_' + serialNo).val('');
                $('#mediceneroute_' + serialNo).val('');
                $('#medicenefrequency_' + serialNo).val('');
                $('#otherinstructions_' + serialNo).val('');
                $('#specialinstructions_' + serialNo).val('');
            }
        }
        function editMedicine(element) {
            const $row = $(element).closest('tr');
            const serialNo = $row.find('input[name="uurowid"]').val();
            const testName = $row.find('td').eq(1).text().trim();

            // Extract existing values from the row - now using the hidden input values
            const existingValues = {
                dose: $row.find('td').eq(7).find('.field-value').val(),
                dosageFrom: $row.find('td').eq(6).find('.field-value').val(),
                duration: $row.find('td').eq(4).text().trim(),
                route: $row.find('td').eq(3).find('.field-value').val(),
                frequency: $row.find('td').eq(2).find('.field-value').val(),
                otherInstruction: $row.find('td').eq(8).find('.field-value').val(),
                specialInstructions: $row.find('td').eq(5).text().trim()
            };
            console.log(existingValues);

            // Call ShowMediceneDetails in edit mode with existing values
            ShowMediceneDetails(serialNo, testName, true, existingValues);
        }
        function ShowMediceneTemplateDiv() {
            $('.tab11subtab').slideUp();
            $('#tab11_02').slideDown();
            FillMediceneTemplates("");
        }
        function ShowAllMedicenesDiv() {
            $('.tab11subtab').slideUp();
            $('#tab11_01').slideDown();

        }
        function FillMediceneTemplates(searchValue) {
            var html = '';
            $.ajax({
                url: 'NewEmergencyCase.aspx/GetTemplate',
                method: 'POST',
                contentType: 'application/json',
                data: JSON.stringify({ searchString: searchValue || '' }), // Send empty string if searchValue is falsy
                success: function (response) {
                    try {
                        var templates = JSON.parse(response.d);
                        if (templates.length === 0) {
                            html = '<div style="padding: 10px; color: #666; font-style: italic;">No items found</div>';
                        } else {
                            $.each(templates, function (key, value) {
                                html += `
    <div class="Medicene-row" style="display: flex; align-items: center; justify-content: space-between; padding: 6px 0;">
        <div style="display: flex; align-items: center;">
            <input type="checkbox" 
                   id="Medicenechk_${value.Template_Id}" 
                   class="Medicene-checkbox"
                   onclick="this.checked ? Add_MediceneByTemplateRow('${value.Template_Id}') : Remove_MediceneByTemplateRow('${value.Template_Id}')"
                   style="margin-right: 8px; cursor: pointer;">
            <label class="Medicene-label" 
                   for="Medicenechk_${value.Template_Id}"
                   style="margin-left: 8px; font-size: 14px; color: #333;">
                ${value.Template_Name}
            </label>
        </div>
    </div>`;
                            });
                        }
                        $('#allMediceneTemplates').html(html);
                    } catch (error) {
                        console.error('Error parsing response:', error);
                        $('#allMediceneTemplates').html('<div style="padding: 10px; color: red;">Error loading items</div>');
                    }
                },
                error: function (xhr, status, error) {
                    console.error('Error fetching data:', error);
                    $('#allMediceneTemplates').html('<div style="padding: 10px; color: red;">Error loading items</div>');
                }
            });
        }
        function Remove_MediceneByTemplateRow(serialNo) {
            var rows = $('#tblMedicines tbody tr[value="' + serialNo + '"]');

            rows.each(function () {
                $(this).find('a[onclick*="deleteMedicine"]').trigger('click');
            });

        }
        function Add_MediceneByTemplateRow(serialNo) {
            var Templateid = serialNo;
            PageMethods.GetTemplateMedicine(Templateid, function (res) {
                debugger;
                var Medicines = JSON.parse(res);
                var rows = '';
                $.each(Medicines, function (key, value) {
                    debugger;
                    var timeStamp = parseInt(value.Medicine_Date.substr(6, 10));
                    var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                    var datearray = date.split("/");
                    var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];
                    debugger;

                    rows += '<tr value=' + Templateid + '> <td style="display:none"><input type="hidden" name="testDate" value="' + date + '"> ' + newdate + ' </td><td> ' + value.Medicine_Name + ' </td><td> ' + value.Frequency + ' </td> <td> ' + value.Oral + ' </td><td> ' + value.Injections + ' </td> <td> ' + value.AttendingParamedical_Staff + ' </td><td> ' + value.Dosage_From + ' </td><td> ' + value.Dosage_Qty + ' </td><td> ' + value.Other_Instruction + ' </td><td> <a href="#" onclick="deleteMedicine(this)"><i class="fa fa-times"></i></a></td> <td style="display:none;">' + value.Item_Code + '</td></tr>';
                });
                $('#tblMedicines tbody').append(rows);
                $('#dvtblMedicines').slideDown();
            })
        }
    </script>
    <script id="DocumentReady">
        $(document).ready(function () {

            
            loaddoctor_byDep();
            var id = '<%=Request.QueryString["ID"]%>';
            if (id != "") {
                $('#<%= txtOut_Patient_ID.ClientID%>').val(id);
                loadPatientFormData(id);
                $('#btnSave').val("Update");
                AppendSymtompsHistory();
                Appendtestintable();
                LoadMedicines();
                AppendPrimaryDiagnosisHistory();
                AppendFinalDiagnosisHistory();
                AppendComplaintsHistory();
                updateHistoryTable();

                $('.exam-row input[type="checkbox"]').each(function () {
                    var param = this.id.split('_chk').pop();
                    if (this.checked) {
                        Add_GeneralExamRow(param);
                    }
                });
 
            }
            else {
                openQueue();
                $('#ctl00_MainContent_txtOut_Patient_ID').val("(New)");
                $('#<%= txtOut_Patient_ID.ClientID%>').val("(New)");

            }
           
        });
    </script>
    <script id="functions" type="text/javascript">
      
        function ResetForm() {
            window.location.href = "NewOutPatient.aspx";
        }
     
        function loadPatient(PatientID, opdNo, regPatID) {
            $.ajax({
                type: "POST",
                url: "NewOutPatient.aspx/GetDetail",
                data: "{'PatientID':" + PatientID + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = response.d;
                    if (data != '') {
                        var mydate = new Date(Date.parse(data.Entry_Date));
                        var dateR = mydate.toLocaleDateString();
                        var name = ReplaceNullWith_Space(data.Name);
                        var gender = ReplaceNullWith_Space(data.Gender);
                        var age = ReplaceNullWith_Space(data.Age);
                        var mobile = ReplaceNullWith_Space(data.Mobile);
                        var address = ReplaceNullWith_Space(data.Address);
                        var follow = ReplaceNullWith_Space(data.Follow);
                        var outID = data.OutPatientID || "0"; // Use logical OR to provide default

                        console.log("OutPatientID:", outID);

                        if (outID && outID !== "0") {
                            window.location = "NewOutPatient.aspx?ID=" + outID;
                            return; // Exit if redirecting
                        }

                        $('#<%= vlblPatients_Name.ClientID %>').text(name);
                        $('#<%= vLbl_Age.ClientID %>').text(gender + "-" + age + "yrs"); // Combine Gender and Age
                        $('#<%= vLbl_Adress.ClientID %>').text(address);
                        $('#<%= vLbl_Contact.ClientID %>').text(mobile);
                        $('#<%= lblFollow.ClientID %>').text(follow);
                        $('#<%= Label1.ClientID %>').text(opdNo);
                        $("#<%= hdfPatient_ID.ClientID %>").val(PatientID);
                        $("#<%= hdfReg_ID.ClientID %>").val(regPatID);

                        $('#queueModal').modal('hide');
                    }
                },
                failure: function (response) {

                }
            });




        }
      
        // Simple AddVitals function matching your style. Load after jQuery and after ASP.NET controls render.

        function AddVitals() {
            // read values (ends-with selectors for ASP.NET rendered ids)
            var pulse = $("[id$='txtRateBeats']").val() || '-';
            var bp = $("[id$='txtBP']").val() || '-';
            var temp = $("[id$='txtTemp']").val() || '-';
            var resp = $("[id$='txtRespiration']").val() || '-';
            var rhythm = $("[id$='ddlRhythm'] option:selected").text() || '-';
            var volume = $("[id$='ddlVolume'] option:selected").text() || '-';
            var o2sat = $("[id$='txtSaturation_Oxygen2']").val() || '-';
            var percentage = $("[id$='txtSaturation']").val() || '-';
            var liters = $("[id$='txtSaturation_Oxygen1']").val() || '-';

            var roomAir = $("[id$='chk_OnRoomAir']").length ? ($("[id$='chk_OnRoomAir']").is(':checked') ? 'Yes' : 'No') : '-';
            var withO2 = $("[id$='chk_WithOxygen']").length ? ($("[id$='chk_WithOxygen']").is(':checked') ? 'Yes' : 'No') : '-';

            var others = $("[id$='txtOthersRcvNote']").val() || '-';
            var received = $("[id$='txtReceiving_Date']").val() || '-';
            var instruction = $("[id$='txtRN_Special_Instruction']").val() || '-';

            var tbody = $('#tblVitals tbody');
            var tableContainer = $('#divtblVitals');

            // clear existing rows and insert one row (same behaviour as your demo)
            tbody.empty();

            var newRow = $('<tr>').html(
                '<td>' + pulse + '</td>' +
                '<td>' + bp + '</td>' +
                '<td>' + temp + '</td>' +
                '<td>' + resp + '</td>' +
                '<td>' + rhythm + '</td>' +
                '<td>' + volume + '</td>' +
                '<td>' + o2sat + '</td>' +
                '<td>' + percentage + '</td>' +
                '<td>' + liters + '</td>' +
                '<td>' + roomAir + '</td>' +
                '<td>' + withO2 + '</td>' +
                '<td>' + others + '</td>' +
                '<td>' + received + '</td>' +
                '<td>' + instruction + '</td>'
            );

            tbody.append(newRow);
            tableContainer.slideDown();
        }

       

      
        function toggleRetract() {
            const retractDiv = document.getElementById('retract');
            retractDiv.classList.toggle('minimized');
        }
      
     
        function toggleMenu(element) {
            element.classList.toggle('active');
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

        document.addEventListener('click', function (e) {
            const sidebarr = document.querySelector('.sidebarr');
            if (!sidebarr.contains(e.target)) {
                // Only close expandable menus (skip no-submenu items)
                document.querySelectorAll('.menu-item').forEach(item => {
                    if (!item.classList.contains('no-submenu')) {
                        item.classList.remove('active');
                    }
                });
            }
        });

    </script>
    <script id="saveLogic">
        function SaveHistoryTab() {

            var SymtomsList = [];

            $.each($('#tblSymtoms tbody tr'), function (key, value) {
                debugger;
                var dayYearMonthText = $($(value).find('td')[4]).text();
                dayYearMonthText = dayYearMonthText.replace(/\s/g, "");

                var dayYearMonthID = $('#ddlDaysMonthsYears').find('option:contains(' + dayYearMonthText + ')').val() || '';

                SymtomsList.push({
                    'SymtomID': $($(value).find('td')[1]).text(),
                    'Duration': $($(value).find('td')[3]).text(),
                    'DayYearMonth': dayYearMonthID,
                    'Remarks': $($(value).find('td')[5]).text()
                });
            });

            var SymtomsList = {
                OutPatientID: ($('#ctl00_MainContent_txtOut_Patient_ID').val() != "(New)" || $('#ctl00_MainContent_txtOut_Patient_ID').val() != "0") ? $('#ctl00_MainContent_txtOut_Patient_ID').val() : "0",
                SymtomsList: SymtomsList
            }
            console.log(SymtomsList);
            PageMethods.SaveSymtoms(JSON.stringify(SymtomsList), function (response) {
                 saveAllRecord();
            });

        }
        function SaveMedicines() { 
            debugger;
            var table = $('#tblMedicines');
            var MedicinesList = [];
            table.find('tbody tr').each(function (key, value) {
                var date = '<%= DateTime.Now%>'
                MedicinesList.push({
                    'Medicine_Date': $(value).find('td input[name=testDate]').val(), 'Medicine_Name': $($(value).find('td')[1]).text(), 'Frequency': $($(value).find('td')[2]).text(), 'Oral': $($(value).find('td')[3]).text(), 'Injection': $($(value).find('td')[4]).text(), 'AttendingParamedical_Staff': $($(value).find('td')[5]).text(),
                    'Dosage_From': $($(value).find('td')[6]).text(), 'Dosage_Qty': $($(value).find('td')[7]).text(), 'Other_Instruction': $($(value).find('td')[8]).text(), 'ItemCode': $($(value).find('td')[10]).text(),
                });

            });

            var PatID = $('#<%= hdfPatient_ID.ClientID%>').val();

            var OutPatID = $('#<%= txtOut_Patient_ID.ClientID%>').val();
            if (OutPatID == '(New)' || OutPatID == '' || OutPatID == "0")
                OutPatID = 0;
            var MedicineDetails = { Pat: PatID, PatientID: OutPatID, MedicineList: MedicinesList }
            console.log(MedicineDetails);
            PageMethods.SaveMedicines(JSON.stringify(MedicineDetails), function (response) {
                saveTests();
            });

        }
        function saveTests() {
            var test_list = [];
            function extractTestData(table) {
                table.find('tr').each(function (key, value) {
                    var rotationVal = $(value).find('td input[name="rotation"]').val();
                    var rotationText = $(value).find('td').eq(6).text().trim();

                    var showTestDescription = false;
                    if (rotationText.includes('X-Ray') || rotationText.includes('CT-Scan')) {
                        showTestDescription = true;
                    }

                    test_list.push({
                        'Date': $(value).find('td input[name="testDate"]').val(),
                        'TestID': $(value).find('td input[name="testID"]').val(),
                        'Catagory_ID': $(value).find('td input[name="txtGroupCategory"]').val(),
                        'Dept_ID': $(value).find('td input[name="txtDeptID"]').val(),
                        'RotationID': rotationVal,
                        'L_R_Rotation_ID': $(value).find('td input[name="txtddlXRayLF_Name"]').val(),
                        'Special_Tests': $(value).find('td input[name="txtSpecial_Test"]').val(),
                        'Area_Of_Interest': $(value).find('td input[name="txtArea_Of_Interest"]').val(),
                        'rotation': rotationText,
                        'showTestDescription': showTestDescription
                    });
                });
            }
            extractTestData($('#tblLabtest tbody'));
            extractTestData($('#tblDiagnostictest tbody'));

            // Now `test_list` contains data from both tables
            console.log(test_list);

            var PatID = $('#<%= hdfPatient_ID.ClientID%>').val();
            var patientID = $('#<%= txtOut_Patient_ID.ClientID %>').val();
            if (patientID == '(New)' || patientID == '' || patientID == "0")
                patientID = 0;
            var labTest = { 'PatientID': patientID, 'TestList': test_list, 'PatID': PatID };
            PageMethods.SaveTest(JSON.stringify(labTest), function (res) {
                SaveHistoryTab();
            });
        }
       
     
        function saveAllRecord() {
            var Patient_ID = $("#<%= hdfPatient_ID.ClientID %>").val();
            var reg_ID = $("#<%= hdfReg_ID.ClientID %>").val();
            var Administration = $('#ctl00_MainContent_ddlIssuance_Of').val();
            var doc_id_hdn = $('#ctl00_MainContent_hdndoctors_id').val();
            if (Administration == 0)
                Administration = "";
            var Out_Patient_ID = $('#ctl00_MainContent_txtOut_Patient_ID').val();
            if (Out_Patient_ID == "(New)" || Out_Patient_ID == "0")
                Out_Patient_ID = "";

            // Helper function to safely get values
            function safeGetValue(selector) {
                var value = $(selector).val();
                return value || "";
            }

            var data = {
                // Tab02 - Vitals
                pulse_Min: safeGetValue('#ctl00_MainContent_txtPuls'),
                BP_mm_Hg: safeGetValue('#ctl00_MainContent_txtBP'),
                Temp_C: safeGetValue('#ctl00_MainContent_txtTemp'),
                Respiration_Min: safeGetValue('#ctl00_MainContent_txtRespiration'),
                Height_Cm: safeGetValue('#ctl00_MainContent_txtHeight'),
                Weight_Kg: safeGetValue('#ctl00_MainContent_txtWeight'),
                SPO2: safeGetValue('#ctl00_MainContent_txtspo2'),
                L_M_P: safeGetValue('#ctl00_MainContent_txtLMP'),
                Bsr: safeGetValue('#ctl00_MainContent_TxtBSR'),
                Bmi: safeGetValue('#ctl00_MainContent_txtBMI'),

                // Tab03 - History
                HistoryOfPeresentIllness: safeGetValue('#ctl00_MainContent_txtHistoryOfPeresentIllness'),
                HistoryOfPastIllness: safeGetValue('#ctl00_MainContent_txtHistoryOfPastIllness'),
                Birth_History: safeGetValue('#ctl00_MainContent_txtBirthHistory'),
                GYNAE: safeGetValue('#ctl00_MainContent_txtGYNAE'),
                Drug_History: safeGetValue('#ctl00_MainContent_txtDrugHistory'),
                Personal_History: safeGetValue('#ctl00_MainContent_txtPersonalHistory'),
                ObstetricHistory: safeGetValue('#ctl00_MainContent_txtObstetricHistory'),
                AllergiesHistory: safeGetValue('#ctl00_MainContent_txtAllergiesHistory'),
                TreatmentHistory: safeGetValue('#ctl00_MainContent_txtTreatmentHistory'),
                DevelopmentHistory: safeGetValue('#ctl00_MainContent_txtDevelopmentHistory'),
                VaccinationHistory: safeGetValue('#ctl00_MainContent_txtVaccinationHistory'),
                NutritionHistory: safeGetValue('#ctl00_MainContent_txtNutritionHistory'),
                HistoryOfFamily: safeGetValue('#ctl00_MainContent_txtHistoryOfFamily'),
                SocioEconomicHistory: safeGetValue('#ctl00_MainContent_txtSocioEconomicHistory'),

                // Tab04 - Examination
                chkPallor: document.getElementById("ctl00_MainContent_chkPallor")?.checked || false,
                chkJVP: document.getElementById("ctl00_MainContent_chkJVP")?.checked || false,
                chkaganoris: document.getElementById("ctl00_MainContent_chkCyanosis")?.checked || false,  // Changed to match HTML
                chkunconceed: document.getElementById("ctl00_MainContent_chkDisoriented")?.checked || false,  // Changed to match HTML
                chkjaundice: document.getElementById("ctl00_MainContent_chkJaundice")?.checked || false,  // Changed to match HTML
                hydration: document.getElementById("ctl00_MainContent_chkDehydration")?.checked || false,  // Changed to match HTML
                edema: document.getElementById("ctl00_MainContent_chkEdema")?.checked || false,  // Changed to match HTML
                chk4: document.getElementById("ctl00_MainContent_chkClubbing")?.checked || false,  // Changed to match HTML
                chk3: document.getElementById("ctl00_MainContent_chkDyspnoea")?.checked || false,  // Changed to match HTML
                chk2: document.getElementById("ctl00_MainContent_chkNeckSwelling")?.checked || false,  // Changed to match HTML
                chk1: document.getElementById("ctl00_MainContent_chkLymphadenopathy")?.checked || false,  // Changed to match HTML
                chk5: document.getElementById("ctl00_MainContent_chkSkinLesions")?.checked || false,  // Changed to match HTML
                Other: safeGetValue('#ctl00_MainContent_txtInputBox1'),
                CNS: safeGetValue('#ctl00_MainContent_txtCNS'),
                CVS: safeGetValue('#ctl00_MainContent_txtCVS'),
                RESP: safeGetValue('#ctl00_MainContent_txtRESP'),
                GIT: safeGetValue('#ctl00_MainContent_txtGIT'),
                Abdominal: safeGetValue("#ctl00_MainContent_txtAbdomin"),
                URG: safeGetValue("#ctl00_MainContent_txtUGS"),
                Mucculor: safeGetValue('#ctl00_MainContent_txtMucculor'),
                Local: safeGetValue('#ctl00_MainContent_txtLocal'),
                Provisional_Diagnosis: safeGetValue('#ctl00_MainContent_txtProvisionalDiagnosis'),
                txtRemarksHistory: safeGetValue('#ctl00_MainContent_txtRemarksHistory'),

                // Tab05 - Referral
                Reffer_To: safeGetValue('#ctl00_MainContent_ddlPatient_Main_Category'),
                Reffer_doc: safeGetValue('#ctl00_MainContent_ddldoctors'),
                Reffer_No: safeGetValue('#ctl00_MainContent_txtRefferNote'),

                // Tab12 - Follow Up
                Doctor_ID: $('#ctl00_MainContent_ddlDoctorName option:selected').val() || "",
                Designation: safeGetValue('#ctl00_MainContent_txtDesignation'),
                Issuance_Of: safeGetValue('#ctl00_MainContent_ddlIssuance_Of'),
                Follow_Up: safeGetValue('#ctl00_MainContent_ddlFOllowUp'),
                FollowNoDate: safeGetValue('#ctl00_MainContent_FollowNoDate'),

                // Tab13 - Disposal
                FinalDiagnosis: safeGetValue('#ctl00_MainContent_txtFinalDiagnosis'),
                Advice: safeGetValue('#ctl00_MainContent_txtAdvice'),
                Final_Rec: safeGetValue("#ctl00_MainContent_Final_Rec"),
                Proto: safeGetValue('#ctl00_MainContent_ddlProto'),

                // Common Fields - ensure these are proper data types
                Patient_ID: parseInt(Patient_ID) || 0,
                reg_ID: reg_ID || "",
                doc_id_hdn: doc_id_hdn || "",
                btnsave: safeGetValue('#btnSave') || "Save",
                Discharged: document.getElementById("DischargeCheckBox") ? document.getElementById("DischargeCheckBox").checked : false,
                Administration: Administration,
                Out_Patient_ID: Out_Patient_ID
            };

            console.log("Data being sent:", data);

            $.ajax({
                type: "POST",
                url: "NewOutPatient.aspx/SaveRecord",
                data: JSON.stringify({ data: data }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    console.log("Response:", response);

                    // Check if the response indicates an error
                    if (response.d && response.d.startsWith("Error:")) {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: response.d,
                            showConfirmButton: true
                        });
                    } else {
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: 'Record has been saved successfully.',
                            showConfirmButton: false,
                            timer: 2500,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                        window.location = "NewOutPatient.aspx?ID=" + response.d;
                        $('#btnSave').val("Update");
                    }
                },
                error: function (xhr, status, error) {
                    console.error("AJAX Error:", {
                        status: xhr.status,
                        statusText: xhr.statusText,
                        responseText: xhr.responseText,
                        error: error
                    });

                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'An error occurred while saving the record. Please check the console for details.',
                        showConfirmButton: true
                    });
                }
            });
        }
    </script>

    <script id="updateLogic" type="text/javascript">

        function AppendSymtompsHistory() {
            var OutPatientID = $('#<%= txtOut_Patient_ID.ClientID%>').val();

            PageMethods.LoadSymtompsHistory(OutPatientID, function (res) {
                var Symptoms = JSON.parse(res);
                var rows = '';

                $.each(Symptoms, function (key, value) {
                    rows += '<tr>' +
                        '<td style="display:none;"><input type="hidden" class="symtopclass" value="' + value.Symtom_ID + '" /></td>' +
                        '<td style="display:none;">' + value.Symtom_ID + '</td>' +
                        '<td>' + value.Symtom_Name + '</td>' +
                        '<td style="display:none;">' + value.Duration + '</td>' +
                        '<td style="display:none;">' + value.Days_Years_Months + '</td>' +
                        '<td style="display:none;">' + value.Remarks + '</td>' +
                        '<td><a href="#" onclick="Delete_Symtom(this)"><i class="fa fa-times"></i></a></td>' +
                        '</tr>';
                });

                $('#tblSymtoms tbody').html(rows);

                // Show/hide container based on whether we have symptoms
                if (Symptoms.length > 0) {
                    $('#dvtblSymtomps').slideDown();
                } else {
                    $('#dvtblSymtomps').slideUp();
                }
            });
        }
        function Appendtestintable() {
            var patientID = $('#<%= txtOut_Patient_ID.ClientID %>').val();
            if (patientID != '(New)') {
                PageMethods.GetTestList(patientID, function (res) {
                    var test = JSON.parse(res);
                    var labRows = '';
                    var diagRows = '';

                    $.each(test, function (key, value) {
                        var Result = value.Is_Result ? 'Result' : 'Waiting';
                        var Sample = value.Is_Result ? "Yes" : "No";

                        // Format the date from the database or use current date
                        var testDate = value.Date ? moment(value.Date).format('M/D/YYYY h:mm:ss A') : moment().format('M/D/YYYY h:mm:ss A');
                        var datearray = testDate.split("/");
                        var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];

                        // Handle null values
                        if (value.L_R_Rotation_ID == null) value.L_R_Rotation_ID = "";
                        if (value.Special_Tests == null) value.Special_Tests = "";
                        if (value.Area_Of_Interest == null) value.Area_Of_Interest = "";
                        if (value.Rotation_ID == null) value.Rotation_ID = "";
                        if (value.Remark == null) value.Remark = "";

                        // X-Ray department (001) goes to Lab table
                        if (value.Department_ID == "001") {
                            labRows += '<tr>' +
                                '<td style="display:none"><input type="hidden" name="testDate" value="' + newdate + '">' + newdate + '</td>' +
                                '<td><input type="hidden" name="testID" value="' + value.Test_ID + '" />' +
                                '<input type="hidden" name="labTestDetailID" value="' + value.Lab_Test_Detail_ID + '"/>' +
                                '<input type="hidden" name="labTestID" value="' + value.Lab_Test_ID + '"/>' +
                                '<input type="hidden" name="txtValueType" value="' + (value.Value_Type || '') + '"/>' +
                                '<input type="hidden" name="txtRecievedID" value="' + (value.Recieved_ID || '') + '"/>' +
                                '<input type="hidden" name="txtRotation" value="' + (value.Rotation || '') + '">' +
                                '<input type="hidden" name="txtddlXRayLF_Name" value="' + value.L_R_Rotation_ID + '">' +
                                '<input type="hidden" name="txtGroupCategory" value="' + (value.Group_Category || '0') + '">' +
                                '<input type="hidden" name="txtDeptID" value="' + (value.Department_ID || '') + '"/>' +
                                '<input type="hidden" name="txtCategoryID" value="' + (value.Catagory_ID || '') + '"/>' +
                                '<input type="hidden" name="txtGroupName" value="' + (value.GroupName || '') + '"/>' +
                                '<input type="hidden" name="txtRemark" value="' + value.Remark + '"/>' +
                                (value.DepartmentName == null ? '' : value.DepartmentName + ', ') +
                                (value.Test_Name || '') +
                                (value.DataValue_Description == null ? '' : ', ' + value.DataValue_Description) +
                                (value.L_R_Rotation_ID ? ', ' + value.L_R_Rotation_ID : '') +
                                '</td>' +
                                '<td style="display:none">' + Sample + '</td>' +
                                '<td style="display:none">' + Result + '</td>' +
                                '<td><input type="hidden" name="txtSpecial_Test" value="' + value.Special_Tests + '"/> ' +
                                value.Special_Tests + '</td>' +
                                '<td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' +
                                value.Area_Of_Interest + '</td>' +
                                '<td style="display:none"><input type="hidden" name="rotation" value="' + (value.Rotation_ID || '') + '"/>' +
                                (value.Rotation || '') + '</td>' +
                                '<td><input type="hidden" name="rowid" value="' + uuid() + '" />' +
                                '<a href="javascript:void(0)" onclick="Remove_LabTestRow(' + value.Test_ID + ')">' +
                                '<i class="fa fa-times"></i></a>' +
                                '</td></tr>';
                        }
                        else {
                            // Other departments go to Diagnostic table
                            diagRows += '<tr>' +
                                '<td style="display:none"><input type="hidden" name="testDate" value="' + newdate + '">' + newdate + '</td>' +
                                '<td><input type="hidden" name="testID" value="' + value.Test_ID + '" />' +
                                '<input type="hidden" name="labTestDetailID" value="' + value.Lab_Test_Detail_ID + '"/>' +
                                '<input type="hidden" name="labTestID" value="' + value.Lab_Test_ID + '"/>' +
                                '<input type="hidden" name="txtValueType" value="' + (value.Value_Type || '') + '"/>' +
                                '<input type="hidden" name="txtRecievedID" value="' + (value.Recieved_ID || '') + '"/>' +
                                '<input type="hidden" name="txtRotation" value="' + (value.Rotation || '') + '">' +
                                '<input type="hidden" name="txtddlXRayLF_Name" value="' + value.L_R_Rotation_ID + '">' +
                                '<input type="hidden" name="txtGroupCategory" value="' + (value.Group_Category || '0') + '">' +
                                '<input type="hidden" name="txtDeptID" value="' + (value.Department_ID || '') + '"/>' +
                                '<input type="hidden" name="txtCategoryID" value="' + (value.Catagory_ID || '') + '"/>' +
                                '<input type="hidden" name="txtGroupName" value="' + (value.GroupName || '') + '"/>' +
                                '<input type="hidden" name="txtRemark" value="' + value.Remark + '"/>' +
                                (value.DepartmentName == null ? '' : value.DepartmentName + ', ') +
                                (value.Test_Name || '') +
                                (value.DataValue_Description == null ? '' : ', ' + value.DataValue_Description) +
                                (value.L_R_Rotation_ID ? ', ' + value.L_R_Rotation_ID : '') +
                                '</td>' +
                                '<td style="display:none">' + Sample + '</td>' +
                                '<td style="display:none">' + Result + '</td>' +
                                '<td><input type="hidden" name="txtSpecial_Test" value="' + value.Special_Tests + '"/> ' +
                                value.Special_Tests + '</td>' +
                                '<td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' +
                                value.Area_Of_Interest + '</td>' +
                                '<td><input type="hidden" name="rotation" value="' + (value.Rotation_ID || '') + '"/>' +
                                (value.Rotation || '') + '</td>' +
                                '<td><input type="hidden" name="rowid" value="' + uuid() + '" />' +
                                '<a href="javascript:void(0)" onclick="Remove_DiagnosticTestRow(' + value.Test_ID + ')">' +
                                '<i class="fa fa-times"></i></a>' +
                                '</td></tr>';
                        }
                    });

                    // Append rows to respective tables and show/hide divs
                    if (labRows) {
                        $('#tblLabtest tbody').append(labRows);
                        $('#dvtblLabtest').show();
                    } else {
                        $('#dvtblLabtest').hide();
                    }

                    if (diagRows) {
                        $('#tblDiagnostictest tbody').append(diagRows);
                        $('#dvtblDiagnostictest').show();
                    } else {
                        $('#dvtblDiagnostictest').hide();
                    }
                }, function (error) {
                    // Error callback
                    console.error('Error fetching test list:', error);
                    alert('Error loading test data. Please try again.');
                });
            }
        }
        function LoadMedicines() {
            debugger;
            var patientId = $('#<%= txtOut_Patient_ID.ClientID%>').val();

            if (patientId === '(New)' || patientId === '0') {
                return; // Exit if new patient
            }

            PageMethods.LoadMedicines(patientId, function (res) {
                try {
                    var Medicines = JSON.parse(res);
                    var rows = '';

                    $.each(Medicines, function (key, value) {
                        // Format date using moment.js
                        var formattedDate = '';
                        if (value.Medicine_Date) {
                            var timeStamp = parseInt(value.Medicine_Date.substr(6, 10));
                            formattedDate = moment.unix(timeStamp).format('MM/DD/YYYY hh:mm A');
                        }

                        // Clean up select values
                        var oral = (value.Oral && value.Oral.trim() === "Select Routes") ? '' : value.Oral;
                        var dosageQty = (value.Dosage_Qty && value.Dosage_Qty.trim() === "Select") ? '' : value.Dosage_Qty;
                        var dosageFrom = (value.Dosage_From && value.Dosage_From.trim() === "Select") ? '' : value.Dosage_From;
                        var otherInstruction = (value.Other_Instruction && value.Other_Instruction.trim() === "Select") ? '' : value.Other_Instruction;

                        // Build row using template literals for better readability
                        rows += '<tr>' +
                            '<td style="display:none"><input type="hidden" name="testDate" value="' + formattedDate + '">' + formattedDate + '</td>' +
                            '<td><input type="hidden" name="hdnItemCode" value="' + (value.Item_Code || '') + '">' + (value.Medicine_Name || '') + '</td>' +
                            '<td>' + (value.Frequency || '') + '<input type="hidden" class="field-value" value="' + (value.Frequency || '') + '"></td>' +
                            '<td>' + (oral || '') + '<input type="hidden" class="field-value" value="' + (oral || '') + '"></td>' +
                            '<td>' + (value.Injections || '') + '</td>' +
                            '<td>' + (value.AttendingParamedical_Staff || '') + '</td>' +
                            '<td>' + (dosageFrom || '') + '<input type="hidden" class="field-value" value="' + (dosageFrom || '') + '"></td>' +
                            '<td>' + (dosageQty || '') + '<input type="hidden" class="field-value" value="' + (dosageQty || '') + '"></td>' +
                            '<td>' + (otherInstruction || '') + '<input type="hidden" class="field-value" value="' + (otherInstruction || '') + '"></td>' +
                            '<td><a href="#" onclick="editMedicine(this); return false;">Edit</a> | <a href="#" onclick="deleteMedicine(this); return false;"><i class="fa fa-times"></i></a><input type="hidden" name="uurowid" value="' + uuid() + '"></td>' +
                            '<td style="display:none;"></td>' +
                            '</tr>';
                    });

                    $('#tblMedicines tbody').html(rows);
                    $('#dvtblMedicines').toggle(Medicines.length > 0);

                } catch (error) {
                    console.error('Error loading medicines:', error);
                    // Optionally show user-friendly error message
                    alert('Failed to load medicines. Please try again.');
                }
            }, function (error) {
                console.error('PageMethod failed:', error);
                alert('Failed to load medicines. Please check your connection and try again.');
            });
        }
        function AppendComplaintsHistory() {
            var OutPatientID = $('#<%= txtOut_Patient_ID.ClientID%>').val();
            PageMethods.LoadComplaints(OutPatientID, function (res) {
                var Complaints = JSON.parse(res);
                var rows = '';

                // First uncheck all complaint checkboxes
                $('[id^="chk_complaint_"]').prop('checked', false);

                $.each(Complaints, function (key, value) {
                    rows += '<tr> <td style="display:none;"> <input type="hidden" class="complainclass" value="' + value.ComplaintID + '" />' + value.ComplaintID + ' </td>' +
                        '<td> ' + value.ComplaintName + ' </td>' +
                        '<td> <a href="#" onclick="Remove_ComplaintRow(\'' + value.ComplaintID + '\')"><i class="fa fa-times"></i></a></td></tr>';

                    // Check the corresponding checkbox
                    $('#chk_complaint_' + value.ComplaintID).prop('checked', true);

                    if (value.ComplaintID && value.ComplaintID.toString().length > 0)
                        $('#dvtblComplaints').slideDown();
                    else
                        $('#dvtblComplaints').slideUp();
                });
                $('#tblComplaints tbody').html(rows);
            });
        }

        function AppendFinalDiagnosisHistory() {
            var OutPatientID = $('#<%= txtOut_Patient_ID.ClientID%>').val();

            PageMethods.LoadFinalDiagnosis(OutPatientID, function (res) {
                var FinalDiagnosis = JSON.parse(res);
                var rows = '';

                // Clear previous selections
                $('[id^="chk_Final_Diagnosis_"]').prop('checked', false);
                $('[id^="txtFinalDiagnosis_"]').val('');

                $.each(FinalDiagnosis, function (key, value) {
                    rows += '<tr id="FinaldiagnosisRow_' + value.FinalDiagnosisID + '">' +
                        '<td style="display:none;"><input type="hidden" class="finaldiagnosisclass" value="' + value.FinalDiagnosisID + '" />' +
                        value.FinalDiagnosisID + '</td>' +
                        '<td>' + value.DiagnosisName + '</td>' +
                        '<td>' + (value.Remarks || '') + '</td>' +
                        '<td><a href="#" onclick="removeFinalDiagnosisRow(\'' + value.FinalDiagnosisID + '\'); return false;"><i class="fa fa-times"></i></a></td>' +
                        '</tr>';

                    // Check the corresponding checkbox and fill remarks
                    $('#chk_Final_Diagnosis_' + value.FinalDiagnosisID).prop('checked', true);
                    $('#txtFinalDiagnosis_' + value.FinalDiagnosisID).val(value.Remarks || '');
                });

                $('#tblFinalDiagnosis tbody').html(rows);
                $('#dvtblFinalDiagnosis').toggle(FinalDiagnosis.length > 0);
            });
        }

        function AppendPrimaryDiagnosisHistory() {
            var OutPatientID = $('#<%= txtOut_Patient_ID.ClientID%>').val();

            PageMethods.LoadPrimaryDiagnosis(OutPatientID, function (res) {
                var PrimaryDiagnosis = JSON.parse(res);
                var rows = '';

                // Clear previous selections
                $('[id^="chk_Primary_Diagnosis_"]').prop('checked', false);
                $('[id^="txtPrimaryDiagnosis_"]').val('');

                $.each(PrimaryDiagnosis, function (key, value) {
                    rows += '<tr id="PrimarydiagnosisRow_' + value.PrimaryDiagnosisID + '">' +
                        '<td style="display:none;"><input type="hidden" class="primarydiagnosisclass" value="' + value.PrimaryDiagnosisID + '" />' +
                        value.PrimaryDiagnosisID + '</td>' +
                        '<td>' + value.DiagnosisName + '</td>' +
                        '<td>' + (value.Remarks || '') + '</td>' +
                        '<td><a href="#" onclick="removePrimaryDiagnosisRow(\'' + value.PrimaryDiagnosisID + '\'); return false;"><i class="fa fa-times"></i></a></td>' +
                        '</tr>';

                    // Check the corresponding checkbox and fill remarks
                    $('#chk_Primary_Diagnosis_' + value.PrimaryDiagnosisID).prop('checked', true);
                    $('#txtPrimaryDiagnosis_' + value.PrimaryDiagnosisID).val(value.Remarks || '');
                });

                $('#tblPrimaryDiagnosis tbody').html(rows);
                $('#dvtblPrimaryDiagnosis').toggle(PrimaryDiagnosis.length > 0);
            });
        }
        function Load_Proto() {
            debugger;
            if ($("#<%= hdfPatient_ID.ClientID%>").val() !== "(New)") {
                var patients_id = $('#<%= txtOut_Patient_ID.ClientID %>').val();
                PageMethods.LoadProtoDetails(patients_id, function (response) {
                    var Proto = JSON.parse(response);
                    var rows = "";

                    $.each(Proto, function (key, value) {
                        rows += '<tr><td><input type="hidden" name="ProtoId" value="' + value.ProtoId + '" />' + value.Proto_Description + '</td><td style="text-align: left;"><a href="#" onclick="DeleteRow(this)"><i class="fa fa-times"></i></a></td></tr>';
                    });
                    $('#tblProto tbody').append(rows);
                    $('#dvtblProto').toggle(Proto.length > 0);
                });
            }

        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="queueModal" class="modal fade" data-backdrop="static" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable" role="document">
            <div class="modal-content">
                <div class="modal-body">
                    <div id="QueueList">
                        <div class="row" style="margin-bottom: 15px">
                            <div class="col-lg-4">
                                <select id="ddlPatientDepartment" runat="server"></select>
                            </div>
                            <div class="col-lg-4">
                                <select id="ddldocname" onchange="fillPendingPatientsList();" runat="server"></select>
                            </div>
                            <div class="col-lg-4 text-end">
                                <a onclick="fillPendingPatientsList()">
                                    <i class="fa fa-refresh fa-2x"></i>
                                </a>
                            </div>

                        </div>


                        <div class="table-responsive previewTable">
                            <table class="table table-bordered table-custom" id="tblPendingPatients">
                                <thead id="ihead">
                                    <tr>
                                        <th>OPD No</th>
                                        <th>Token No</th>
                                        <th>Patient Name</th>
                                        <th>Age</th>
                                        <th>Department</th>
                                        <th>Doctor</th>
                                        <th style="width: 173px;">Created Time</th>
                                        <th>Operator Name</th>
                                        <th>Status</th>
                                        <th>Select</th>
                                    </tr>
                                </thead>
                                <tbody id="ibody">
                                </tbody>
                            </table>

                        </div>
                    </div>


                </div>
                <div class="modal-footer">

                    <button type="button" class="btn btn-gray" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>
    <div id="AddNewSymptom" class="modal fade" data-backdrop="static" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable" role="document">
            <div class="modal-content">
                <div class="modal-body">
                    <div class="row">
                        <div class="col-lg-4">
                        </div>
                        <div class="col-lg-4">
                            <input type="text" id="SymptomName" placeholder="Symptom Name" />
                        </div>

                        <div class="col-lg-4">
                        </div>


                    </div>

                </div>
                <div class="modal-footer">

                    <button type="button" class="btn btn-gray" data-dismiss="modal">Close</button>
                    <button id="saveNewSymptom" type="button" class="btn btn-primry">Save</button>
                </div>
            </div>
        </div>
    </div>
    <div id="AddSymptomsByModal" class="modal fade" data-backdrop="static" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable" role="document">
            <div class="modal-content">
                <div class="modal-body">
                    <div class="row">
                        <div class="col-lg-3">
                            <input type="text" id="symptomName" disabled />
                        </div>
                        <div class="col-lg-3">
                            <input type="text" id="duration" placeholder="Duration" />
                        </div>

                        <div class="col-lg-3">
                            <select id="durationSuffix">
                                <option selected>H</option>
                                <option>D</option>
                                <option>W</option>
                                <option>M</option>
                                <option>Y</option>
                            </select>
                        </div>
                        <div class="col-lg-3">
                            <input type="text" id="Remarks" placeholder="Remarks" />
                        </div>

                    </div>

                </div>
                <div class="modal-footer">

                    <button type="button" class="btn btn-gray" data-dismiss="modal">Close</button>
                    <button id="saveSymptomByModal" type="button" class="btn btn-primry">Save</button>
                </div>
            </div>
        </div>
    </div>
    <div id="manageSymptomsModal" class="modal fade" data-backdrop="static" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable" role="document">
            <div class="modal-content">
                <div class="modal-body">
                    <div class="row">
                        <div class="col-lg-3">
                            <select id="departments"></select>
                        </div>
                        <div class="col-lg-4">
                            <div>
                                <input type="text" class="form-control mb-2" id="symptomSearch" placeholder="Search..." />
                            </div>

                            <div id="symptoms">
                            </div>
                        </div>

                        <div class="col-lg-5">
                            <div class="cardd">
                                <div class="cardd-body">
                                    <div id="symptomspreview">
                                        <div class="table-responsive">
                                            <table class="table" id="tblsymptomspreview">
                                                <thead>
                                                    <tr>
                                                        <th style="display: none;">Department ID</th>
                                                        <th style="display: none;">Symtom ID</th>
                                                        <th>Symptom</th>
                                                        <th>Edit</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                </div>
                <div class="modal-footer">

                    <button type="button" class="btn btn-gray" data-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primry" onclick="saveSymptomsToDatabase()">Save</button>
                </div>
            </div>
        </div>
    </div>
    <div class="row main-layout-row">

        <div id="retract" class="col-lg-2 shrink-col">
            <div class="sidebarr">
                <div class="menu-item no-submenu" id="06" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/complaints.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Complaints</span>
                    </div>
                </div>
                <div class="menu-item no-submenu" id="01" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/symptoms.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Symptoms</span>
                    </div>
                </div>
                <div class="menu-item no-submenu" id="02" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/vitals.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Vitals</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="03" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/history.png" alt="Profile Picture" class="sidebarIcon">
                        <span>History</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="04" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/examination.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Examination</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="05" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/refer.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Refer To</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="07" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/primarydiagnosis.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Primary Diagnosis</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="08" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/finaldiagnosis.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Final Diagnosis</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="09" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/investigation.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Investigation</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="10" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/diagnostics.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Diagnostics</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="11" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/medication.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Medication</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="12" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/followup.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Follow Up</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="13" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/disposal.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Disposal</span>
                    </div>
                </div>


            </div>
        </div>
        <div class="col-lg-10 grow-col" style="margin-top:10px">
            <div class="row">
                <div class="col-lg-2">
                    <div style="width: fit-content !important;" class="retractIcon">
                        <img onclick="toggleRetract()" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/sidebar.png"
                            alt="Sidebar Toggle" class="sidebarToggleIcon" />
                    </div>
                </div>
                <div class="col-lg-10">
                    <div style="display: flex; justify-content: flex-end;">
                        <input type="button" class="btn btn-primry" value="History" onclick="ShowHistory()" />
                        <input type="button" class="btn btn-primry" value="Queue" onclick="openQueue()" />
                        <label class="mybutton2-wrapper">
                            <input type="checkbox" id="DischargeCheckBox" onchange="toggleDischarge(this)" />
                            <span id="DischargeButtonText">Discharge</span>
                        </label>
                        <input type="button" class="btn btn-primry" value="Reset" onclick="ResetForm()" />
                        <input id="btnSave" type="button" class="btn btn-primry" value="Save" onclick="SaveMedicines()" />

                    </div>
                </div>

            </div>
            <div class="row ">


                <!-- Left Column (6 units) -->
                <div class="col-lg-5">
                    <!-- Patient Card -->
                    <div class="row">
                        <div class="col-12">
                            <div class="cardd">
                                <div class="card-bodyy">
                                    <div class="row">
                                        <div class="col-lg-3 col-md-3 col-sm-4 text-center">
                                            <div class="row">
                                                <div class="image-container">
                                                    <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/Patient.png" alt="Patient Image" class="img-fluid patient-image" />
                                                </div>
                                            </div>
                                            <div class="row">
                                            </div>

                                        </div>
                                        <div class="col-lg-9 col-md-9 col-sm-8">

                                            <div class="row mb-3">
                                                <div class="col-md-5 col-sm-6">
                                                    <asp:Label ID="lblPatient_Name" CssClass="labels" runat="server" Text="Patient Name:"></asp:Label>
                                                </div>
                                                <div class="col-md-7 col-sm-6">
                                                    <asp:Label ID="vlblPatients_Name" CssClass="md" runat="server"></asp:Label>
                                                </div>
                                            </div>

                                            <div class="row mb-3">
                                                <div class="col-md-5 col-sm-6">
                                                    <asp:Label ID="lblPatien_ID" CssClass="labels" runat="server" Text="OPD No:"></asp:Label>
                                                </div>
                                                <div class="col-md-7 col-sm-6">
                                                    <asp:Label ID="Label1" CssClass="md" runat="server"></asp:Label>
                                                </div>
                                            </div>

                                            <div class="row mb-3">
                                                <div class="col-md-5 col-sm-6">
                                                    <asp:Label ID="lblAge_Years" CssClass="labels" runat="server" Text="Age (Years):"></asp:Label>
                                                </div>
                                                <div class="col-md-7 col-sm-6">
                                                    <asp:Label ID="vLbl_Age" CssClass="md" runat="server"></asp:Label>
                                                </div>
                                            </div>

                                            <div class="row mb-3">
                                                <div class="col-md-5 col-sm-6">
                                                    <asp:Label ID="lblContactNo" CssClass="labels" runat="server" Text="Contact No:"></asp:Label>
                                                </div>
                                                <div class="col-md-7 col-sm-6">
                                                    <asp:Label ID="vLbl_Contact" CssClass="md" runat="server"></asp:Label>
                                                </div>
                                            </div>

                                            <div class="row mb-3">
                                                <div class="col-md-5 col-sm-6">
                                                    <asp:Label ID="lblAdress" CssClass="labels" runat="server" Text="Address:"></asp:Label>
                                                </div>
                                                <div class="col-md-7 col-sm-6">
                                                    <asp:Label ID="vLbl_Adress" CssClass="md" runat="server"></asp:Label>
                                                </div>
                                            </div>

                                            <div class="row mb-3">
                                                <div class="col-md-5 col-sm-6">
                                                    <asp:Label ID="dlblFollowNo" CssClass="labels" runat="server" Text="Follow Up No:"></asp:Label>
                                                </div>
                                                <div class="col-md-7 col-sm-6">
                                                    <asp:Label ID="lblFollow" runat="server"></asp:Label>
                                                </div>
                                            </div>
                                            <div class="row mb-3" style="display:none">
                                                <div class="col-md-5 col-sm-6">
                                                    <asp:Label ID="Doctor" CssClass="labels" runat="server" Text="Doctor:"></asp:Label>
                                                    <input type="hidden" id="hdndoctors_id" runat="server" />
                                                </div>
                                                <div class="col-md-7 col-sm-6">
                                                    <asp:Label ID="lblDoctor" runat="server"></asp:Label>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <hr />
                    </div>

                    <!--Content Area -->
                    <div class="row">
                        <div class="col-md-12 col-sm-12" style="height: 600px; overflow-y: auto; overflow-x: hidden;">
                            <div class="cardd">
                                <div class="cardd-body">
                                    <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 10px">
                                        <h2 class="header mybutton"></h2>
                                    </div>

                                    <div class="tabs" id="tab01" style="display: none">
                                        <div style="display: flex; justify-content: flex-end;">
                                            <input type="button" class="btn btn-primry" value="Add New" onclick="AddNewSymptom()" />
                                            <input style="margin-left: 5px" type="button" class="btn btn-primry" value="Manage Symptoms" onclick="openManageSymptomsModal()" />
                                        </div>
                                        <div style="display: none" id="divAddNewSymptom">
                                            <div style="display: flex; justify-content: center;">
                                                <input type="text" id="NewSymptom" />
                                                <input style="width: 50% !important; margin-left: 10px;" type="button" id="btnSaveNewSymptom" onclick="saveSymptom()" class="btn btn-primry" value="Save" />
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-md-5 col-sm-12">
                                                <div class="big-select2">
                                                    <select class="enhanced-select2" id="filterDepartments">
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="col-md-7 col-sm-12">
                                                <input type="text" class="form-control mb-2" id="tab01Search" placeholder="Search..." />
                                            </div>
                                        </div>

                                        <div id="allSymptoms"></div>
                                    </div>
                                    <div class="tabs" id="tab02" style="display: none">
    <div style="display: flex; justify-content: flex-end;">
        <input type="button" class="btn btn-primry" value="Add Vitals" onclick="AddVitals()" />
    </div>
    <div class="vitals-container" style="display: flex; flex-wrap: wrap; justify-content: space-between;">
        <!-- Row 1 -->
        <div style="display: flex; width: 100%;">
            <!-- Plus Rate (Beats per Min) -->
            <div class="vital-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 15px;">
                <div style="display: flex; align-items: center; width: 100%;">
                    <asp:Label Style="width: 200px;" ID="lblRateBeats" runat="server" Text="Plus Rate (Beats per Min)"></asp:Label>
                    <asp:TextBox ID="txtRateBeats" runat="server" TabIndex="1" CssClass="form-control"></asp:TextBox>
                </div>
            </div>
            
            <!-- Blood Pressure (120/80) -->
            <div class="vital-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 15px;">
                <div style="display: flex; align-items: center; width: 100%;">
                    <asp:Label Style="width: 200px;" ID="LblBP" runat="server" Text="Blood Pressure (120/80)"></asp:Label>
                    <asp:TextBox ID="txtBP" runat="server" TabIndex="2" CssClass="form-control"></asp:TextBox>
                </div>
            </div>
        </div>
        
        <!-- Row 2 -->
        <div style="display: flex; width: 100%;">
            <!-- Rhythm -->
            <div class="vital-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 15px;">
                <div style="display: flex; align-items: center; width: 100%;">
                    <asp:Label Style="width: 200px;" ID="lblRhythm" runat="server" Text="Rhythm"></asp:Label>
                    <asp:DropDownList runat="server" AppendDataBoundItems="true" ID="ddlRhythm" CssClass="form-control"></asp:DropDownList>
                </div>
            </div>
            
            <!-- Temperature (°F) -->
            <div class="vital-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 15px;">
                <div style="display: flex; align-items: center; width: 100%;">
                    <asp:Label Style="width: 200px;" ID="LblTemp" runat="server" Text="Temperature (°F)"></asp:Label>
                    <asp:TextBox ID="txtTemp" runat="server" TabIndex="3" CssClass="form-control"></asp:TextBox>
                </div>
            </div>
        </div>
        
        <!-- Row 3 -->
        <div style="display: flex; width: 100%;">
            <!-- Volume -->
            <div class="vital-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 15px;">
                <div style="display: flex; align-items: center; width: 100%;">
                    <asp:Label Style="width: 200px;" ID="lblVolume" runat="server" Text="Volume"></asp:Label>
                    <asp:DropDownList runat="server" ID="ddlVolume" AppendDataBoundItems="true" CssClass="form-control"></asp:DropDownList>
                </div>
            </div>
            
            <!-- Respiration Rate (/min) -->
            <div class="vital-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 15px;">
                <div style="display: flex; align-items: center; width: 100%;">
                    <asp:Label Style="width: 200px;" ID="LblRespiration" runat="server" Text="Respiration Rate (/min)"></asp:Label>
                    <asp:TextBox ID="txtRespiration" runat="server" TabIndex="4" CssClass="form-control"></asp:TextBox>
                </div>
            </div>
        </div>
        
        <!-- Row 4 -->
        <div style="display: flex; width: 100%;">
            <!-- O2 Saturation -->
            <div class="vital-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 15px;">
                <div style="display: flex; align-items: center; width: 100%;">
                    <asp:Label Style="width: 200px;" ID="lblSaturation" runat="server" Text="O2 Saturation"></asp:Label>
                    <asp:TextBox ID="txtSaturation_Oxygen2" runat="server" TabIndex="5" CssClass="form-control"></asp:TextBox>
                </div>
            </div>
            
            <!-- Others -->
            <div class="vital-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 15px;">
                <div style="display: flex; align-items: center; width: 100%;">
                    <asp:Label Style="width: 200px;" ID="lblOthersReceiveNote" runat="server" Text="Others"></asp:Label>
                    <asp:TextBox ID="txtOthersRcvNote" runat="server" TabIndex="6" CssClass="form-control"></asp:TextBox>
                </div>
            </div>
        </div>
        
        <!-- Row 5 -->
        <div style="display: flex; width: 100%;">
            <!-- Percentage -->
            <div class="vital-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 15px;">
                <div style="display: flex; align-items: center; width: 100%;">
                    <asp:Label Style="width: 200px;" ID="Label12" runat="server" Text="Percentage"></asp:Label>
                    <asp:TextBox ID="txtSaturation" runat="server" TabIndex="7" CssClass="form-control"></asp:TextBox>
                </div>
            </div>
            
            <!-- Liters Per Minutes -->
            <div class="vital-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 15px;">
                <div style="display: flex; align-items: center; width: 100%;">
                    <asp:Label Style="width: 200px;" ID="Label23" runat="server" Text="Liters Per Minutes"></asp:Label>
                    <asp:TextBox ID="txtSaturation_Oxygen1" runat="server" TabIndex="8" CssClass="form-control"></asp:TextBox>
                </div>
            </div>
        </div>
        
        <!-- Row 6 -->
        <div style="display: flex; width: 100%;">
            <!-- Room Air -->
            <div class="vital-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 15px;">
                <div style="display: flex; align-items: center; width: 100%;">
                    <asp:Label Style="width: 200px;" ID="Label24" runat="server" Text="Room Air"></asp:Label>
                    <asp:CheckBox runat="server" Class="CHKK" ID="chk_OnRoomAir" />
                </div>
            </div>
            
            <!-- With O2 -->
            <div class="vital-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 15px;">
                <div style="display: flex; align-items: center; width: 100%;">
                    <asp:Label Style="width: 200px;" ID="Label25" runat="server" Text="With O2"></asp:Label>
                    <asp:CheckBox runat="server" Class="CHKK" ID="chk_WithOxygen" />
                </div>
            </div>
        </div>
        
        <!-- Row 7 -->
        <div style="display: flex; width: 100%;">
            <!-- Receiving Date & Time -->
            <div class="vital-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 15px;">
                <div style="display: flex; align-items: center; width: 100%;">
                    <asp:Label Style="width: 200px;" ID="lblRecieving_Time" runat="server" Text="Receiving Date & Time"></asp:Label>
                    <asp:TextBox ID="txtReceiving_Date" runat="server" ReadOnly="true" CssClass="form-control"></asp:TextBox>
                </div>
            </div>
            
            <!-- Special Instruction -->
            <div class="vital-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 15px;">
                <div style="display: flex; align-items: center; width: 100%;">
                    <asp:Label Style="width: 200px;" ID="lblRN_Special_Instruction" runat="server" Text="Special Instruction"></asp:Label>
                    <asp:TextBox ID="txtRN_Special_Instruction" runat="server" TabIndex="9" TextMode="MultiLine" CssClass="form-control" onchange="FillInstruction()"></asp:TextBox>
                </div>
            </div>
        </div>
    </div>
</div>
                                    <div class="tabs" id="tab03" style="display: none">

                                        <!-- History Section -->
                                        <div class="history-container">

    <!-- History of Present Illness -->
    <div class="history-row">
        <div style="display: flex; align-items: center; width: 100%">
            <asp:Label Style="width: 75%;" ID="lbl" runat="server" Text="History Of Present Illness"></asp:Label>
            <asp:TextBox ID="txtHistoryOfPeresentIllness" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="1"></asp:TextBox>
        </div>
    </div>

    <!-- Past Medical/Surgical History -->
    <div class="history-row">
        <div style="display: flex; align-items: center; width: 100%">
            <asp:Label Style="width: 75%;" ID="d" runat="server" Text="Past Medical/Surgical History"></asp:Label>
            <asp:TextBox ID="txtHistoryOfPastIllness" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="2"></asp:TextBox>
        </div>
    </div>

    <!-- Family History -->
    <div class="history-row">
        <div style="display: flex; align-items: center; width: 100%">
            <asp:Label Style="width: 75%;" ID="Label3" runat="server" Text="Family History"></asp:Label>
            <asp:TextBox ID="txtHistoryOfFamily" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="3"></asp:TextBox>
        </div>
    </div>

    <!-- SocioEconomic History -->
    <div class="history-row">
        <div style="display: flex; align-items: center; width: 100%">
            <asp:Label Style="width: 75%;" ID="Label5" runat="server" Text="SocioEconomic History"></asp:Label>
            <asp:TextBox ID="txtSocioEconomicHistory" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="4"></asp:TextBox>
        </div>
    </div>

    <!-- Birth History -->
    <div class="history-row">
        <div style="display: flex; align-items: center; width: 100%">
            <asp:Label Style="width: 75%;" ID="Label15" runat="server" Text="Birth History"></asp:Label>
            <asp:TextBox ID="txtBirthHistory" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="5"></asp:TextBox>
        </div>
    </div>

    <!-- Drug History -->
    <div class="history-row">
        <div style="display: flex; align-items: center; width: 100%">
            <asp:Label Style="width: 75%;" ID="Label8" runat="server" Text="Drug History"></asp:Label>
            <asp:TextBox ID="txtDrugHistory" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="6"></asp:TextBox>
        </div>
    </div>

    <!-- Obstetric History -->
    <div class="history-row">
        <div style="display: flex; align-items: center; width: 100%">
            <asp:Label Style="width: 75%;" ID="Label7" runat="server" Text="Obstetric History"></asp:Label>
            <asp:TextBox ID="txtObstetricHistory" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="7"></asp:TextBox>
        </div>
    </div>

    <!-- Allergies History -->
    <div class="history-row">
        <div style="display: flex; align-items: center; width: 100%">
            <asp:Label Style="width: 75%;" ID="Label9" runat="server" Text="Allergies History"></asp:Label>
            <asp:TextBox ID="txtAllergiesHistory" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="8"></asp:TextBox>
        </div>
    </div>

    <!-- Treatment History -->
    <div class="history-row">
        <div style="display: flex; align-items: center; width: 100%">
            <asp:Label Style="width: 75%;" ID="Label11" runat="server" Text="Treatment History"></asp:Label>
            <asp:TextBox ID="txtTreatmentHistory" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="9"></asp:TextBox>
        </div>
    </div>

    <!-- Personal History -->
    <div class="history-row">
        <div style="display: flex; align-items: center; width: 100%">
            <asp:Label Style="width: 75%;" ID="Label17" runat="server" Text="Personal History"></asp:Label>
            <asp:TextBox ID="txtPersonalHistory" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="10"></asp:TextBox>
        </div>
    </div>

    <!-- Vaccination History -->
    <div class="history-row">
        <div style="display: flex; align-items: center; width: 100%">
            <asp:Label Style="width: 75%;" ID="Label40" runat="server" Text="Vaccination History"></asp:Label>
            <asp:TextBox ID="txtVaccinationHistory" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="11"></asp:TextBox>
        </div>
    </div>

    <!-- Any Other History -->
    <div class="history-row">
        <div style="display: flex; align-items: center; width: 100%">
            <asp:Label Style="width: 75%;" ID="Label41" runat="server" Text="Any Other History"></asp:Label>
            <asp:TextBox ID="txtAnyOtherHistory" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="12"></asp:TextBox>
        </div>
    </div>

    <!-- Referred To (Hidden) -->
    <div class="history-row" style="display: none;">
        <div style="display: flex; align-items: center; width: 100%">
            <asp:Label Style="width: 75%;" ID="Label2" runat="server" Text="Referred To"></asp:Label>
            <asp:DropDownList ID="DropDownList1" runat="server" Width="100%" AppendDataBoundItems="true" TabIndex="13"></asp:DropDownList>
        </div>
    </div>

    <!-- Referral Note (Hidden) -->
    <div class="history-row" style="display: none;">
        <div style="display: flex; align-items: center; width: 100%">
            <asp:Label Style="width: 75%;" ID="Label16" runat="server" Text="Referral Note"></asp:Label>
            <asp:TextBox ID="TextBox1" TextMode="SingleLine" Width="100%" runat="server" TabIndex="14"></asp:TextBox>
        </div>
    </div>

</div>
                                    </div>
                                    <div class="tabs" id="tab04" style="display: none">
    <div class="row">
        <div class="col-md-5 col-sm-12">
            <select id="filterMedicalExaminations">
                <option value="CVS">CVS</option>
                <option value="GCS">GCS</option>
                <option value="GPE">General Physical Examination</option>
                <option value="RESP">RESP</option>
                <option value="GIT">GIT</option>
                <option value="CNS">CNS</option>
            </select>
        </div>
    </div>

    <!-- CVS Tab -->
    <div id="subTabCVS" class="cvs-exam-container subtabs">
        <h4 style="margin-bottom: 20px; color: #333;">CVS Examination</h4>
        
        <!-- Row 1 -->
        <div style="display: flex; justify-content: space-between; margin-bottom: 15px; flex-wrap: wrap;">
            <!-- Heart Sound -->
            <div class="exam-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 10px; cursor: pointer;"
               onclick="event.stopPropagation(); this.checked ? Add_GeneralExamRow('Pallor') : Remove_GeneralExamRow('Pallor')">
                <input type="checkbox" id="HeartSound1" runat="server" name="HeartSound" 
                    onclick="event.stopPropagation();" />
                <label for="HeartSound1" style="margin-left: 8px; cursor: pointer;">Heart Sound</label> 
            </div>

            <!-- Arrhythmias -->
            <div class="exam-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 10px; cursor: pointer;"
                onclick="document.getElementById('Arrhythmias1').click()">
                <input type="checkbox" id="Arrhythmias1" runat="server" name="Arrhythmias" 
                    onclick="event.stopPropagation();" />
                <label for="Arrhythmias1" style="margin-left: 8px; cursor: pointer;">Arrhythmias</label>
            </div>
        </div>

        <!-- Row 2 -->
        <div style="display: flex; justify-content: space-between; margin-bottom: 15px; flex-wrap: wrap;">
            <!-- Murmur -->
            <div class="exam-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 10px; cursor: pointer;"
                onclick="document.getElementById('Murmur1').click()">
                <input type="checkbox" id="Murmur1" runat="server" name="Murmur" 
                    onclick="event.stopPropagation();" />
                <label for="Murmur1" style="margin-left: 8px; cursor: pointer;">Murmur</label>
            </div>

            <!-- Any Other Added Sound -->
            <div class="exam-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 10px; cursor: pointer;"
                onclick="document.getElementById('AnyOtherAddedSound1').click()">
                <input type="checkbox" id="AnyOtherAddedSound1" runat="server" name="AnyOtherAddedSound" 
                    onclick="event.stopPropagation();" />
                <label for="AnyOtherAddedSound1" style="margin-left: 8px; cursor: pointer;">Any Other Added Sound</label>
            </div>
        </div>

        <!-- Row 3 -->
        <div style="display: flex; justify-content: space-between; margin-bottom: 15px; flex-wrap: wrap;">
            <!-- Any Other Findings -->
            <div class="exam-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 10px; cursor: pointer;"
                onclick="document.getElementById('AnyOtherFindings1').click()">
                <input type="checkbox" id="AnyOtherFindings1" runat="server" name="AnyOtherFindings" 
                    onclick="event.stopPropagation();" />
                <label for="AnyOtherFindings1" style="margin-left: 8px; cursor: pointer;">Any Other Findings</label>
            </div>
        </div>

        <!-- CVS Text Area -->
        <div style="margin-bottom: 20px;">
            <asp:TextBox ID="TextBoxCvs" Style="height:146px; width: 100%;" runat="server" 
                TextMode="MultiLine" class="form-control" placeholder="Enter CVS details..."></asp:TextBox>
        </div>
    </div>

    <!-- GCS Tab -->
    <div id="subTabGCS" class="gcs-exam-container subtabs" style="display: none;">
        <h4 style="margin-bottom: 20px; color: #333;">GCS Examination</h4>
        
        <!-- GCS Input Fields -->
        <div style="margin-bottom: 20px;">
            <div style="display: flex; align-items: center; width: 100%; margin-bottom: 15px;">
                <asp:Label Style="width: 30%; font-weight: bold;" ID="Label4" runat="server" 
                    Text="Eye Opening Response"></asp:Label>
                <asp:TextBox ID="ctl00_MainContent_txtEOR" runat="server" TabIndex="1" 
                    onchange="ROPFunction()" Style="width: 70%; margin-left: 10px;" class="form-control"></asp:TextBox>
            </div>

            <div style="display: flex; align-items: center; width: 100%; margin-bottom: 15px;">
                <asp:Label Style="width: 30%; font-weight: bold;" ID="Label6" runat="server" 
                    Text="Motor Response"></asp:Label>
                <asp:TextBox ID="txtMR" runat="server" TabIndex="2" onchange="MRFunction()" 
                    Style="width: 70%; margin-left: 10px;" class="form-control"></asp:TextBox>
            </div>

            <div style="display: flex; align-items: center; width: 100%; margin-bottom: 15px;">
                <asp:Label Style="width: 30%; font-weight: bold;" ID="Label10" runat="server" 
                    Text="Verbal Response"></asp:Label>
                <asp:TextBox ID="txtVR" runat="server" TabIndex="3" onchange="VRFunction()" 
                    Style="width: 70%; margin-left: 10px;" class="form-control"></asp:TextBox>
            </div>

            <div style="display: flex; align-items: center; width: 100%; margin-bottom: 15px;">
                <asp:Label Style="width: 30%; font-weight: bold;" ID="Label89" runat="server" 
                    Text="Accumulated"></asp:Label>
                <asp:TextBox ID="txtAcc" runat="server" TabIndex="4" disabled="disabled" 
                    Style="width: 70%; margin-left: 10px;" class="form-control"></asp:TextBox>
            </div>
        </div>

        <!-- Checkboxes Row -->
        <div style="display: flex; justify-content: space-between; margin-bottom: 15px; flex-wrap: wrap;">
            <!-- Cranial Nerves -->
            <div class="exam-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 10px; cursor: pointer;"
                onclick="document.getElementById('CranialNerves1').click()">
                <input type="checkbox" id="CranialNerves1" runat="server" name="CranialNerves" 
                    onclick="event.stopPropagation();" />
                <label for="CranialNerves1" style="margin-left: 8px; cursor: pointer;">Cranial Nerves</label>
            </div>

            <!-- Signs Of Meningism -->
            <div class="exam-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 10px; cursor: pointer;"
                onclick="document.getElementById('SignsOfMeningism1').click()">
                <input type="checkbox" id="SignsOfMeningism1" runat="server" name="SignsOfMeningism" 
                    onclick="event.stopPropagation();" />
                <label for="SignsOfMeningism1" style="margin-left: 8px; cursor: pointer;">Signs Of Meningism</label>
            </div>
        </div>

        <!-- GCS Text Area -->
        <div style="margin-bottom: 20px;">
            <asp:TextBox runat="server" ID="txtFurtherExplanation" TextMode="MultiLine" 
                Style="width: 100%; height: 60px;" class="form-control" placeholder="Enter further explanation..."></asp:TextBox>
        </div>
    </div>

    <!-- General Physical Examination Tab -->
    <div id="subTabGPE" class="gpe-exam-container subtabs" style="display: none;">
        <h4 style="margin-bottom: 20px; color: #333;">General Physical Examination</h4>
        
        <!-- Row 1 -->
        <div style="display: flex; justify-content: space-between; margin-bottom: 15px; flex-wrap: wrap;">
            <!-- Jaundice -->
            <div class="exam-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 10px; cursor: pointer;"
                onclick="document.getElementById('Jondus1').click()">
                <input type="checkbox" id="Jondus1" runat="server" name="Jondus" 
                    onclick="event.stopPropagation();" />
                <label for="Jondus1" style="margin-left: 8px; cursor: pointer;">Jaundice</label>
            </div>

            <!-- Pallor -->
            <div class="exam-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 10px; cursor: pointer;"
                onclick="document.getElementById('Pallor1').click()">
                <input type="checkbox" id="Pallor1" runat="server" name="Pallor" 
                    onclick="event.stopPropagation();" />
                <label for="Pallor1" style="margin-left: 8px; cursor: pointer;">Pallor</label>
            </div>
        </div>

        <!-- Row 2 -->
        <div style="display: flex; justify-content: space-between; margin-bottom: 15px; flex-wrap: wrap;">
            <!-- Dehydration -->
            <div class="exam-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 10px; cursor: pointer;"
                onclick="document.getElementById('Dehydration1').click()">
                <input type="checkbox" id="Dehydration1" runat="server" name="Dehydration" 
                    onclick="event.stopPropagation();" />
                <label for="Dehydration1" style="margin-left: 8px; cursor: pointer;">Dehydration</label>
            </div>

            <!-- GCS Oriented -->
            <div class="exam-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 10px; cursor: pointer;"
                onclick="document.getElementById('GCSOrientation1').click()">
                <input type="checkbox" id="GCSOrientation1" runat="server" name="GCSOrientation" 
                    onclick="event.stopPropagation();" />
                <label for="GCSOrientation1" style="margin-left: 8px; cursor: pointer;">GCS Oriented</label>
            </div>
        </div>

        <!-- Row 3 -->
        <div style="display: flex; justify-content: space-between; margin-bottom: 15px; flex-wrap: wrap;">
            <!-- Conscious / Oriented -->
            <div class="exam-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 10px; cursor: pointer;"
                onclick="document.getElementById('ConsciousOrientely1').click()">
                <input type="checkbox" id="ConsciousOrientely1" runat="server" name="ConsciousOrientely" 
                    onclick="event.stopPropagation();" />
                <label for="ConsciousOrientely1" style="margin-left: 8px; cursor: pointer;">Conscious / Oriented</label>
            </div>
        </div>

        <!-- GPE Text Area -->
        <div style="margin-bottom: 20px;">
            <asp:TextBox ID="TextBoxGpe" runat="server" TextMode="MultiLine" Style="height:144px; width: 100%;" 
                class="form-control" placeholder="Enter GPE Details"></asp:TextBox>
        </div>
    </div>

    <!-- RESP Tab -->
    <div id="subTabRESP" class="resp-exam-container subtabs" style="display: none;">
        <h4 style="margin-bottom: 20px; color: #333;">RESP Examination</h4>
        
        <!-- Row 1 - NVB -->
        <div style="display: flex; justify-content: space-between; margin-bottom: 15px; flex-wrap: wrap;">
            <!-- NVB Right -->
            <div class="exam-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 10px; cursor: pointer;"
                onclick="document.getElementById('NVB_Right1').click()">
                <input type="checkbox" id="NVB_Right1" runat="server" name="NVB_Right" 
                    onclick="event.stopPropagation();" />
                <label for="NVB_Right1" style="margin-left: 8px; cursor: pointer;">NVB Right</label>
            </div>

            <!-- NVB Left -->
            <div class="exam-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 10px; cursor: pointer;"
                onclick="document.getElementById('NVB_Left1').click()">
                <input type="checkbox" id="NVB_Left1" runat="server" name="NVB_Left" 
                    onclick="event.stopPropagation();" />
                <label for="NVB_Left1" style="margin-left: 8px; cursor: pointer;">NVB Left</label>
            </div>
        </div>

        <!-- Row 2 - Crepitation -->
        <div style="display: flex; justify-content: space-between; margin-bottom: 15px; flex-wrap: wrap;">
            <!-- Crepitation Right -->
            <div class="exam-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 10px; cursor: pointer;"
                onclick="document.getElementById('Crepitation_Right1').click()">
                <input type="checkbox" id="Crepitation_Right1" runat="server" name="Crepitation_Right" 
                    onclick="event.stopPropagation();" />
                <label for="Crepitation_Right1" style="margin-left: 8px; cursor: pointer;">Crepitation Right</label>
            </div>

            <!-- Crepitation Left -->
            <div class="exam-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 10px; cursor: pointer;"
                onclick="document.getElementById('Crepitation_Left1').click()">
                <input type="checkbox" id="Crepitation_Left1" runat="server" name="Crepitation_Left" 
                    onclick="event.stopPropagation();" />
                <label for="Crepitation_Left1" style="margin-left: 8px; cursor: pointer;">Crepitation Left</label>
            </div>
        </div>

        <!-- Row 3 -->
        <div style="display: flex; justify-content: space-between; margin-bottom: 15px; flex-wrap: wrap;">
            <!-- Wheeze -->
            <div class="exam-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 10px; cursor: pointer;"
                onclick="document.getElementById('Wheeze1').click()">
                <input type="checkbox" id="Wheeze1" runat="server" name="Wheeze" 
                    onclick="event.stopPropagation();" />
                <label for="Wheeze1" style="margin-left: 8px; cursor: pointer;">Wheeze</label>
            </div>

            <!-- Ranchi -->
            <div class="exam-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 10px; cursor: pointer;"
                onclick="document.getElementById('Ranchi1').click()">
                <input type="checkbox" id="Ranchi1" runat="server" name="Ranchi" 
                    onclick="event.stopPropagation();" />
                <label for="Ranchi1" style="margin-left: 8px; cursor: pointer;">Ranchi</label>
            </div>
        </div>

        <!-- Row 4 -->
        <div style="display: flex; justify-content: space-between; margin-bottom: 15px; flex-wrap: wrap;">
            <!-- Any Other Sound -->
            <div class="exam-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 10px; cursor: pointer;"
                onclick="document.getElementById('AnyOtherSound1').click()">
                <input type="checkbox" id="AnyOtherSound1" runat="server" name="AnyOtherSound" 
                    onclick="event.stopPropagation();" />
                <label for="AnyOtherSound1" style="margin-left: 8px; cursor: pointer;">Any Other Sound</label>
            </div>
        </div>

        <!-- RESP Text Area -->
        <div style="margin-bottom: 20px;">
            <asp:TextBox ID="TextBoxResp" Style="height:140px; width: 100%;" runat="server" 
                TextMode="MultiLine" class="form-control" placeholder="Enter RESP details..."></asp:TextBox>
        </div>
    </div>

    <!-- GIT Tab -->
    <div id="subTabGIT" class="git-exam-container subtabs" style="display: none;">
        <h4 style="margin-bottom: 20px; color: #333;">GIT Examination</h4>
        
        <!-- Row 1 -->
        <div style="display: flex; justify-content: space-between; margin-bottom: 15px; flex-wrap: wrap;">
            <!-- Abdomen Soft -->
            <div class="exam-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 10px; cursor: pointer;"
                onclick="document.getElementById('AbdomenSoft1').click()">
                <input type="checkbox" id="AbdomenSoft1" runat="server" name="AbdomenSoft" 
                    onclick="event.stopPropagation();" />
                <label for="AbdomenSoft1" style="margin-left: 8px; cursor: pointer;">Abdomen Soft</label>
            </div>

            <!-- Tenderness -->
            <div class="exam-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 10px; cursor: pointer;"
                onclick="document.getElementById('Tenderness1').click()">
                <input type="checkbox" id="Tenderness1" runat="server" name="Tenderness" 
                    onclick="event.stopPropagation();" />
                <label for="Tenderness1" style="margin-left: 8px; cursor: pointer;">Tenderness</label>
            </div>
        </div>

        <!-- Row 2 -->
        <div style="display: flex; justify-content: space-between; margin-bottom: 15px; flex-wrap: wrap;">
            <!-- Guarding -->
            <div class="exam-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 10px; cursor: pointer;"
                onclick="document.getElementById('Guarding1').click()">
                <input type="checkbox" id="Guarding1" runat="server" name="Guarding" 
                    onclick="event.stopPropagation();" />
                <label for="Guarding1" style="margin-left: 8px; cursor: pointer;">Guarding</label>
            </div>

            <!-- Bowel Sound -->
            <div class="exam-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 10px; cursor: pointer;"
                onclick="document.getElementById('BowelSound1').click()">
                <input type="checkbox" id="BowelSound1" runat="server" name="BowelSound" 
                    onclick="event.stopPropagation();" />
                <label for="BowelSound1" style="margin-left: 8px; cursor: pointer;">Bowel Sound</label>
            </div>
        </div>

        <!-- Row 3 -->
        <div style="display: flex; justify-content: space-between; margin-bottom: 15px; flex-wrap: wrap;">
            <!-- Distention -->
            <div class="exam-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 10px; cursor: pointer;"
                onclick="document.getElementById('Distention1').click()">
                <input type="checkbox" id="Distention1" runat="server" name="Distention" 
                    onclick="event.stopPropagation();" />
                <label for="Distention1" style="margin-left: 8px; cursor: pointer;">Distention</label>
            </div>

            <!-- Fluid Thrill -->
            <div class="exam-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 10px; cursor: pointer;"
                onclick="document.getElementById('FluidThrill1').click()">
                <input type="checkbox" id="FluidThrill1" runat="server" name="FluidThrill" 
                    onclick="event.stopPropagation();" />
                <label for="FluidThrill1" style="margin-left: 8px; cursor: pointer;">Fluid Thrill</label>
            </div>
        </div>

        <!-- Row 4 -->
        <div style="display: flex; justify-content: space-between; margin-bottom: 15px; flex-wrap: wrap;">
            <!-- Shifting Dullness -->
            <div class="exam-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 10px; cursor: pointer;"
                onclick="document.getElementById('ShiftingDullness1').click()">
                <input type="checkbox" id="ShiftingDullness1" runat="server" name="ShiftingDullness" 
                    onclick="event.stopPropagation();" />
                <label for="ShiftingDullness1" style="margin-left: 8px; cursor: pointer;">Shifting Dullness</label>
            </div>

            <!-- Epigastria Discomfort -->
            <div class="exam-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 10px; cursor: pointer;"
                onclick="document.getElementById('EpigastriaDiscomfort1').click()">
                <input type="checkbox" id="EpigastriaDiscomfort1" runat="server" name="EpigastriaDiscomfort" 
                    onclick="event.stopPropagation();" />
                <label for="EpigastriaDiscomfort1" style="margin-left: 8px; cursor: pointer;">Epigastria Discomfort</label>
            </div>
        </div>

        <!-- Row 5 -->
        <div style="display: flex; justify-content: space-between; margin-bottom: 15px; flex-wrap: wrap;">
            <!-- Retrosternal Burning -->
            <div class="exam-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 10px; cursor: pointer;"
                onclick="document.getElementById('RetrosternalBurning1').click()">
                <input type="checkbox" id="RetrosternalBurning1" runat="server" name="RetrosternalBurning" 
                    onclick="event.stopPropagation();" />
                <label for="RetrosternalBurning1" style="margin-left: 8px; cursor: pointer;">Retrosternal Burning</label>
            </div>
        </div>

        <!-- GIT Text Area -->
        <div style="margin-bottom: 20px;">
            <asp:TextBox ID="TextBoxGit" runat="server" TextMode="MultiLine" Style="height:140px; width: 100%;" 
                class="form-control" placeholder="Enter GIT details..."></asp:TextBox>
        </div>
    </div>

    <!-- CNS Tab -->
    <div id="subTabCNS" class="cns-exam-container subtabs" style="display: none;">
        <h4 style="margin-bottom: 20px; color: #333;">CNS Examination</h4>
        
        <!-- HMF Intact -->
        <div style="display: flex; justify-content: flex-start; margin-bottom: 15px;">
            <div class="exam-row" style="display: flex; align-items: center; width: 48%; cursor: pointer;"
                onclick="document.getElementById('HMFIntact1').click()">
                <input type="checkbox" id="HMFIntact1" runat="server" name="HMFIntact" 
                    onclick="event.stopPropagation();" />
                <label for="HMFIntact1" style="margin-left: 8px; cursor: pointer;">HMF Intact</label>
            </div>
        </div>

        <!-- CNS Text Area -->
        <div style="margin-bottom: 20px;">
            <asp:TextBox ID="TextBoxCns" runat="server" TextMode="MultiLine" Style="height:140px; width: 100%;" 
                class="form-control" placeholder="Enter CNS details..."></asp:TextBox>
        </div>
    </div>
</div>
                                    <div class="tabs" id="tab05" style="display: none;">
  <div style="display:flex; flex-direction:column; gap:12px; padding:8px; box-sizing:border-box; max-width:100%;">
    <!-- Department Row -->
    <div style="display:flex; flex-wrap:wrap; align-items:center; gap:12px;">
      <div style="flex: 0 0 200px;">
        <asp:Label ID="lbl_Department" runat="server" Text="Department"></asp:Label>
      </div>
      <div style="flex:1 1 300px; min-width:180px;">
        <asp:UpdatePanel runat="server" TabIndex="2" ID="UpdatePanel10" style="outline: none;">
          <ContentTemplate>
            <asp:DropDownList ID="ddl_Department" runat="server"  onchange="Get_Doctor_Info();" AppendDataBoundItems="true"></asp:DropDownList>
          </ContentTemplate>
        </asp:UpdatePanel>
      </div>
    </div>

    <!-- Select Doctor Row -->
    <div style="display:flex; flex-wrap:wrap; align-items:center; gap:12px;">
      <div style="flex:0 0 200px;">
        <asp:Label runat="server" ID="lblCallToDoctor" Text="Select Doctor To Call"></asp:Label>
      </div>
      <div style="flex:1 1 300px; min-width:180px;">
        <asp:UpdatePanel runat="server" TabIndex="2" ID="UpdatePanel4" style="outline: none;">
          <Triggers>
          </Triggers>
          <ContentTemplate>
            <asp:DropDownList ID="ddlCallToDoctor" runat="server" onchange="Get_Doctor_MobileInfo();" AppendDataBoundItems="true"></asp:DropDownList>
          </ContentTemplate>
        </asp:UpdatePanel>
      </div>
    </div>

    <!-- Mobile No Row -->
    <div style="display:flex; flex-wrap:wrap; align-items:center; gap:12px;">
      <div style="flex:0 0 200px;">
        <asp:Label runat="server" ID="lblMobileNo" Text="Mobile No"></asp:Label>
      </div>
      <div style="flex:1 1 300px; min-width:180px;">
        <asp:TextBox runat="server" ID="txtMobileNo"></asp:TextBox>
      </div>
    </div>

    <!-- SMS / Buttons Row (kept original buttons, no new buttons added) -->
    <div style="display:flex; flex-wrap:wrap; align-items:center; gap:12px;">
      <div style="flex:0 0 200px;">
        <asp:Label ID="lblSmsToDoctor" runat="server" Text="SMS To Doctor"></asp:Label>
      </div>
      <div style="display:flex; gap:8px; flex-wrap:wrap; align-items:center;">
        <div>
          <input type="button" value="Send" class="btn btn-primry" id="btnPrintAdmisionDetail" onclick="" />
        </div>
        <div>
          <input type="button" class="btn-gray" onclick="DotcorCallUnit()" value="Print" />
        </div>
      </div>
    </div>

    <!-- Doctor Notes -->
    <div style="display:flex; flex-direction:column; gap:8px; width:100%; box-sizing:border-box;">
      <h2 style="margin:0; text-align:left;">Doctor Notes</h2>
      <asp:TextBox TextMode="MultiLine" runat="server" id="txtCallToDoctor" style="width:100%; min-height:139px; font-size:18px; font-weight:Bold;"></asp:TextBox>
    </div>
  </div>
</div>
                                    <div class="tabs" id="tab06">
    <!-- Row 1: Triage Area & Treatment Time -->
    <div class="form-row row">
        <div class="col-md-6 mb-3">
            <asp:Label CssClass="form-label" ID="lblPatientCondition" runat="server" Text="Triage Area"></asp:Label>
            <asp:UpdatePanel ID="UpdatePanel1" TabIndex="6" runat="server">
                <ContentTemplate>
                    <asp:DropDownList ID="ddlPatientCondition" CssClass="form-control-custom" runat="server" AppendDataBoundItems="true" onchange="checkPatientCondition(this)"></asp:DropDownList>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
        <div class="col-md-6 mb-3">
            <asp:Label CssClass="form-label" runat="server" ID="lblTreatmentTime" Text="Treatment Time"></asp:Label>
            <asp:TextBox runat="server" CssClass="form-control-custom readonly" ID="txtTreatmentTime" ReadOnly="true"></asp:TextBox>
        </div>
    </div>

    <!-- Row 2: Admission Date & Current Room/Ward -->
    <div class="form-row row">
        <div class="col-md-6 mb-3">
            <asp:Label CssClass="form-label" ID="LblAdmission_Date" runat="server" Text="Admission Date"></asp:Label>
            <asp:TextBox ID="txtAdmission_Date" CssClass="form-control-custom readonly" runat="server" ReadOnly="true"></asp:TextBox>
        </div>
        <div class="col-md-6 mb-3">
                    <asp:Label CssClass="form-label" ID="lblfee" runat="server" Text="Admission Fee"></asp:Label>
<asp:TextBox ID="txtadmissionfee" CssClass="form-control-custom readonly" ReadOnly="true" TabIndex="8" runat="server" Enabled="true"></asp:TextBox>
            </div>
        <div class="col-md-6 mb-3" style="display:none">
            <asp:Label CssClass="form-label" runat="server" Text="Current Room/Ward"></asp:Label>
            <div class="d-flex align-items-center">
                <asp:UpdatePanel ID="UpdatePanel8" runat="server" UpdateMode="Always">
                    <ContentTemplate>
                        <asp:Label ID="vlblCurrent_Allocated_Room_Ward" runat="server" />
                        <span class="status-indicator status-available"></span>
                    </ContentTemplate>
                </asp:UpdatePanel>
                <asp:UpdatePanel ID="UpdatePanel7" runat="server">
                    <ContentTemplate>
                        <asp:Button ID="btnAllocatedRoomWardChkTriggerBtn" CssClass="btn btn-sm btn-outline-secondary ms-2" Text="Check Availability" runat="server" OnClick="btnAllocatedRoomWardChkTriggerBtn_Click" CausesValidation="false" />
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
        </div>
        
    </div>

    <!-- Row 3: Department & Doctor -->
    <div class="form-row row">
        <div class="col-md-6 mb-3">
            <asp:Label CssClass="form-label" ID="LblDepartment" runat="server" Text="Department"></asp:Label>
            <div>
                <asp:DropDownList ID="ddlDepartment" CssClass="form-control-custom" TabIndex="1" runat="server" AppendDataBoundItems="true" onchange="" Enabled="false"></asp:DropDownList>
                <asp:UpdatePanel ID="UpdatePanel12" runat="server" UpdateMode="Always" Style="display:none">
                    <ContentTemplate>
                        <asp:Button ID="btnGet_Doctor" CssClass="btn btn-sm btn-outline-primary mt-2" Text="Get Doctors" runat="server" OnClick="btnGet_Doctor_Click" CausesValidation="false" />
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
        </div>
        <div class="col-md-6 mb-3">
            <asp:Label CssClass="form-label" ID="Label26" runat="server" Text="Doctor"></asp:Label>
            <asp:UpdatePanel runat="server" TabIndex="2" ID="UpdatePanel13">
                <Triggers>
                    <asp:AsyncPostBackTrigger ControlID="ddlDepartment" />
                </Triggers>
                <ContentTemplate>
                    <asp:DropDownList ID="ddlDoctor" CssClass="form-control-custom" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </div>

    <!-- Row 4: Admit To & Bed No -->
    <div class="form-row row">
        <div class="col-md-6 mb-3">
             <asp:Label ID="lblIssuance_Of" runat="server" Text="Admit To"></asp:Label>&nbsp;&nbsp;<span class="text-danger">*</span>
 <asp:UpdatePanel ID="UpdatePanel9" TabIndex="6" runat="server">
     <ContentTemplate>
         <asp:DropDownList ID="ddlIssuance_Of" runat="server" AppendDataBoundItems="true" onChange="chkIssuance_Of_Select()" Enabled="false"></asp:DropDownList>
     </ContentTemplate>
 </asp:UpdatePanel>
 <asp:RequiredFieldValidator ID="rfvIssuance_Of" ControlToValidate="ddlIssuance_Of" InitialValue="0" runat="server" ErrorMessage="Select Admit To" Text="*"></asp:RequiredFieldValidator>
        </div>
        <div class="col-md-6 mb-3">
            <asp:Label CssClass="form-label" ID="LblBed_No" runat="server" Text="Bed No"></asp:Label>
            <asp:TextBox ID="txtBed_No" CssClass="form-control-custom" TabIndex="8" runat="server" Enabled="true"></asp:TextBox>
        </div>
    </div>

    <!-- Row 5: Ward & Admission Fee -->
    <div class="form-row row">
        <div class="col-md-6 mb-3">
            <asp:Label CssClass="form-label required" ID="lblWard_No" runat="server" Text="Ward"></asp:Label>
            <asp:UpdatePanel ID="UpdatePanel11" TabIndex="7" runat="server" UpdateMode="Always">
                <ContentTemplate>
                    <asp:DropDownList ID="ddlWard_No" CssClass="form-control-custom" runat="server" AppendDataBoundItems="true" OnChange="FillWardBeds()"></asp:DropDownList>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
        <div class="col-md-6 mb-3">
           
        </div>
    </div>
                                           <div style="overflow-y: scroll; max-height: 150px;">
    <table id="tblWards" class="table table-responsive" style="float: right;">
             <thead>
                 <tr>
                     <th>MR No</th>
                     <th>Bed No</th>
                 </tr>
             </thead>
             <tbody>
             </tbody>
         </table>
     </div> 
</div>
                                    <div class="tabs" id="tab07" style="display: none">
  <div style="display: flex; justify-content: flex-end;">
    <input type="button" class="btn btn-primry" value="Add Vitals" onclick="AddDischargeVitals]()" />
  </div>
  <div class="vitals-container" style="display: flex; flex-wrap: wrap; justify-content: space-between;">
    <!-- Row 1 -->
    <div style="display: flex; width: 100%;">
      <div class="vital-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 15px;">
        <div style="display: flex; align-items: center; width: 100%;">
          <asp:Label ID="Label90" runat="server" Text="Plus Rate (Beats per Min)"></asp:Label>
          <asp:TextBox ID="txtPulseRate" runat="server" TabIndex="1" Style="width: 100%; box-sizing: border-box;"></asp:TextBox>
        </div>
      </div>

      <div class="vital-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 15px;">
        <div style="display: flex; align-items: center; width: 100%;">
          <asp:Label ID="Label91" runat="server" Text="Blood Pressure (120/80)"></asp:Label>
          <asp:TextBox ID="txtBPDischarge" runat="server" TabIndex="2" Style="width: 100%; box-sizing: border-box;"></asp:TextBox>
        </div>
      </div>
    </div>

    <!-- Row 2 -->
    <div style="display: flex; width: 100%;">
      <div class="vital-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 15px;">
        <div style="display: flex; align-items: center; width: 100%;">
          <asp:Label ID="Label92" runat="server" Text="Rhythm"></asp:Label>
          <asp:DropDownList runat="server" AppendDataBoundItems="true" ID="ddlRhythmdischarge" Style="width: 100%; box-sizing: border-box;"></asp:DropDownList>
        </div>
      </div>

      <div class="vital-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 15px;">
        <div style="display: flex; align-items: center; width: 100%;">
          <asp:Label ID="Label93" runat="server" Text="Temperature (°F)"></asp:Label>
          <asp:TextBox ID="txtTempdisch" runat="server" TabIndex="3" Style="width: 100%; box-sizing: border-box;"></asp:TextBox>
        </div>
      </div>
    </div>

    <!-- Row 3 -->
    <div style="display: flex; width: 100%;">
      <div class="vital-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 15px;">
        <div style="display: flex; align-items: center; width: 100%;">
          <asp:label ID="Label94" runat="server" Text="Volume"></asp:label>
          <asp:DropDownList runat="server" ID="ddlvolumedisc" AppendDataBoundItems="true" Style="width: 100%;"></asp:DropDownList>
        </div>
      </div>

      <div class="vital-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 15px;">
        <div style="display: flex; align-items: center; width: 100%;">
          <asp:Label ID="Label95" runat="server" Text="Respiration Rate (/min)"></asp:Label>
          <asp:TextBox ID="txtRespRateDesc" runat="server" TabIndex="4" Style="width: 100%;"></asp:TextBox>
        </div>
      </div>
    </div>

    <!-- Row 4 -->
    <div style="display: flex; width: 100%;">
      <div class="vital-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 15px;">
        <div style="display: flex; align-items: center; width: 100%;">
          <asp:Label ID="Label96" runat="server" Text="O2 Saturation"></asp:Label>
          <asp:TextBox ID="txtSaturation_Oxygen2_desc" runat="server" TabIndex="2" Style="width: 100%;"></asp:TextBox>
        </div>
      </div>

      <div class="vital-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 15px;">
        <div style="display: flex; align-items: center; width: 100%;">
          <asp:Label ID="Label97" runat="server" Text="Others"></asp:Label>
          <asp:TextBox ID="txtotherecdesc" runat="server" TabIndex="2" Style="width: 100%;"></asp:TextBox>
        </div>
      </div>
    </div>

    <!-- Row 5 -->
    <div style="display: flex; width: 100%;">
      <div class="vital-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 15px;">
        <div style="display: flex; align-items: center; width: 100%;">
          <asp:Label ID="Label98" runat="server" Text="Receiving Date & Time"></asp:Label>
          <asp:TextBox ID="txttxtReceiving_DateDesc" runat="server" ReadOnly="true" Style="width: 100%;"></asp:TextBox>
        </div>
      </div>

      <div class="vital-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 15px;">
        <div style="display: flex; align-items: center; width: 100%;">
          <asp:Label ID="Label99" runat="server" Text="Special Instruction"></asp:Label>
          <asp:TextBox ID="txtRN_Special_Instruction_Desc" runat="server" TabIndex="9" TextMode="MultiLine" Style="width: 100%; height: 35px;"></asp:TextBox>
        </div>
      </div>
    </div>

    <!-- Row 6 -->
    <div style="display: flex; width: 100%;">
      <div class="vital-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 15px;">
        <div style="display: flex; align-items: center; width: 100%;">
          <asp:TextBox ID="txtsaturationDis" runat="server" TabIndex="2" Style="width: 137px !important;  margin-left:12px;"></asp:TextBox>
          <asp:CheckBox runat="server" style="margin-top: 9px;width: 58px !important;" ID="chk_OnRoomAirDesc" Text="" />
          <label for="chk_OnRoomAirDesc">On Room Air</label>
        </div>
      </div>

      <div class="vital-row" style="display: flex; align-items: center; width: 48%; margin-bottom: 15px;">
        <div style="display: flex; align-items: center; width: 100%;">
          <asp:TextBox ID="txtOxygen1" runat="server" TabIndex="2" Style="width: 137px !important; margin-left:12px;"></asp:TextBox>
          <asp:CheckBox runat="server" style="margin-top: 9px;width: 58px !important;" ID="chk_WithOxygenDesc" Text="" />
          <label for="chk_WithOxygenDesc">With Oxygen</label>
        </div>
      </div>
    </div>
  </div>
</div>
                                    <div class="tabs" id="tab08" style="display: none;">
  <div class="vitals-container" style="display:flex; flex-direction:column; gap:12px; width:100%; box-sizing:border-box; padding:8px;">
    <!-- Header -->
    <div style="padding:10px 0;">
      <h2 style="margin:0;">Discharge Details :</h2>
    </div>

    <!-- Row 1 -->
    <div style="display:flex; flex-wrap:wrap; gap:12px; width:100%;">
      <div class="history-row" style="display:flex; align-items:flex-start; width:48%; padding:5px; box-sizing:border-box;">
        <asp:Label ID="lblDischarge_By" runat="server" Text="Advise By"></asp:Label>
        <asp:UpdatePanel runat="server" ID="UpdatePanel2">
          <Triggers>
            <asp:AsyncPostBackTrigger ControlID="ddlDepartment" />
          </Triggers>
          <ContentTemplate>
            <asp:DropDownList ID="ddlDischarge_By" runat="server" Width="167px" AppendDataBoundItems="true" TabIndex="1"></asp:DropDownList>
          </ContentTemplate>
        </asp:UpdatePanel>
      </div>

      <div class="history-row" style="display:flex; align-items:center; width:48%; padding:5px; box-sizing:border-box;">
        <asp:Label ID="lblDischarge_On" runat="server" Text="Discharged Date "></asp:Label>
        <asp:TextBox ID="txtDischarge_On" runat="server" disabled="disabled"></asp:TextBox>
      </div>

      <div class="history-row" style="display:flex; flex-direction:column; width:48%; padding:5px; box-sizing:border-box;">
        <asp:Label runat="server" ID="lblDiagnosis" Text="Diagnosis"></asp:Label>
        <asp:TextBox runat="server" style="width: 100% !important;height: 35px !important;" ID="txtDiagnosis" TextMode="MultiLine"></asp:TextBox>
      </div>

      <div class="history-row" style="display:flex; flex-direction:column; width:48%; padding:5px; box-sizing:border-box;">
        <asp:Label ID="lblPrevention_Precaution" runat="server" Text="Advice "></asp:Label>
        <asp:TextBox ID="txtPrevention_Precaution"  style="width: 100% !important;height: 35px !important;" runat="server" TextMode="MultiLine"  TabIndex="2"></asp:TextBox>
      </div>

      <div class="history-row" style="display:flex; align-items:center; width:48%; padding:5px; box-sizing:border-box;">
        <asp:Label ID="Label13" runat="server" Text="Follow Up"></asp:Label>
        <asp:TextBox ID="txtNext_Visit" runat="server" TabIndex="5"></asp:TextBox>
      </div>
    </div>

    <!-- Row 2 -->
    <div style="display:flex; flex-wrap:wrap; gap:12px; width:100%;">
      <div class="history-row" style="display:flex; flex-direction:column; width:48%; padding:5px; box-sizing:border-box;">
        <asp:Label ID="lblTreatmentAtDischarge" runat="server" Text="Treatment At Discharge"></asp:Label>
        <asp:TextBox ID="txtTreatmentAtDischarge" runat="server" style="width: 100% !important;height: 35px !important;"  TextMode="MultiLine"  TabIndex="4"></asp:TextBox>
      </div>

      <div class="history-row" style="display:flex; flex-direction:column; width:48%; padding:5px; box-sizing:border-box;">
        <asp:Label ID="lblFollowUpPlanInstructions" runat="server" Text="Follow Up Plan & Instructions"></asp:Label>
        <asp:TextBox  ID="txtFollowUpPlanInstructions" style="width: 100% !important;height: 35px !important;"  runat="server" TextMode="MultiLine"></asp:TextBox>
      </div>

      <div class="history-row" style="display:flex; flex-direction:column; width:48%; padding:5px; box-sizing:border-box;">
        <asp:Label ID="lblProcRecommended" runat="server" Text="Procedure Recommended"></asp:Label>
        <asp:TextBox ID="txtProcedureRecommended" style="width: 100% !important;height: 35px !important;"  runat="server" TextMode="MultiLine"  TabIndex="4"></asp:TextBox>
      </div>

      <div class="history-row" style="display:flex; align-items:center; width:48%; padding:5px; box-sizing:border-box;">
        <asp:Label ID="lblDischargeStatus" runat="server" Text="Discharge Status"></asp:Label>
        <asp:DropDownList runat="server" ID="ddlDischargeStatus" AppendDataBoundItems="true"></asp:DropDownList>
      </div>

      <div class="history-row" style="display:flex; flex-direction:column; width:48%; padding:5px; box-sizing:border-box;">
        <asp:Label runat="server" ID="lblCauseOfReferral" Text="Cause Of Referral"></asp:Label>
        <asp:TextBox  runat="server" style="width: 100% !important;height: 35px !important;" ID="txtCauseOfReferral" TextMode="MultiLine"></asp:TextBox>
      </div>
    </div>

    <!-- Row 3 -->
    <div style="display:flex; flex-wrap:wrap; gap:12px; width:100%;">
      <div class="history-row" style="display:flex; align-items:center; width:48%; padding:5px; box-sizing:border-box;">
        <asp:Label ID="lblReferredTo" runat="server" Text="Referred To"></asp:Label>
        <asp:DropDownList runat="server" ID="ddlReferredTo" AppendDataBoundItems="true"></asp:DropDownList>
      </div>

      <div class="history-row" style="display:flex; align-items:center; width:48%; padding:5px; box-sizing:border-box;">
        <asp:Label ID="Label14" runat="server" Text="Discharge Slip" ></asp:Label>
        <asp:CheckBox ID="cbDicharg_Slip" style="margin-top: 9px;width: 58px !important;" runat="server"  ></asp:CheckBox>
      </div>

      <div class="history-row" style="display:flex; align-items:center; width:48%; padding:5px; box-sizing:border-box;">
        <asp:Label ID="lbldeath" runat="server" Text="Death" ></asp:Label>
        <input type="checkbox" style="margin-top: 9px;width: 58px !important;" ID="cb_death"  runat="server" onchange="showdeathtab();" />
      </div>

      <div class="history-row" style="display:flex; align-items:center; width:48%; padding:5px; box-sizing:border-box;">
        <label class="form-check-label" for="ReferOPD" style="margin-bottom: -21px;">Refer To OPD</label>
        <asp:CheckBox runat="server" style="margin-top: 9px;width: 58px !important;" ID="ReferToOPD" ClientIDMode="Static" />
      </div>
    </div>

    <!-- Row 4 (Death certificate controls hidden by style as original) -->
    <div style="display:none; flex-wrap:wrap; gap:12px; width:100%;">
      <div class="history-row" style="width:48%; padding:5px; box-sizing:border-box;">
        <asp:Label ID="lblDeath_Certificate" runat="server" Text="Death Certificate" style="display:none"></asp:Label>
      </div>
      <div class="history-row" style="width:48%; padding:5px; box-sizing:border-box;">
        <asp:CheckBox ID="cbDeath_Certificate" runat="server" style="display:none"></asp:CheckBox>
      </div>
    </div>

    <!-- Row 5: Action Buttons -->
    <div style="display:flex; flex-wrap:wrap; gap:12px; width:100%; margin-top:5px;">
     
      <div style="width:48%; padding:5px; box-sizing:border-box;">
        <input type="button" id="btnDischargeSummary" class="btn-gray" value="Print" name="name" onclick="DischargeSummary();" style="width:55% !important"  disabled="disabled" />
      </div>
      <div style="width:48%; padding:5px; box-sizing:border-box;">
        <input type="button" id="btnDischargePrint"  value="Discharge Print" name="name" onclick="PrintInpatientReceipt();" style="width: 120px;display:none;" />
      </div>
    </div>

  </div>
</div>
                                    <div class="tabs" id="tab09" style="display: none">

                                        <div class="row">
                                            <div class="col-md-7 col-sm-12">
                                                <input type="text" class="form-control mb-2" id="tab09Search" placeholder="Search..." />
                                            </div>
                                            <div class="col-md-5 col-sm-12">
                                            </div>

                                        </div>
                                        <div id="allLabTests"></div>
                                    </div>
                                    <div class="tabs" id="tab10" style="display: none">

                                        <div class="row">
                                            <div class="col-md-5 col-sm-12">
                                                <div class="big-select2">
                                                    <select class="enhanced-select2" id="filterMainDepartments">
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="col-md-7 col-sm-12">
                                                <input type="text" class="form-control mb-2" id="tab10Search" placeholder="Search..." />
                                            </div>
                                        </div>
                                        <div id="allDiagnosticTest"></div>
                                    </div>
                                    <div class="tabs" id="tab11" style="display: none">
                                        <div style="display: flex; justify-content: flex-end;">
                                            <input type="button" class="btn btn-primry" value="By Template" onclick="ShowMediceneTemplateDiv()" />
                                            <input style="margin-left: 5px" type="button" class="btn btn-primry" value="All Meds" onclick="ShowAllMedicenesDiv()" />
                                        </div>
                                        <div id="tab11_01" class="tab11subtab">
                                            <div class="row editMed">
                                                <div class="col-md-7 col-sm-12">
                                                    <input type="text" class="form-control mb-2" id="tab11_01Search" placeholder="Search..." />
                                                </div>
                                                <div class="col-md-5 col-sm-12">
                                                </div>

                                            </div>
                                            <div id="allMedicenes"></div>
                                        </div>
                                        <div id="tab11_02" class="tab11subtab" style="display: none">
                                            <div class="row">
                                                <div class="col-md-7 col-sm-12">
                                                    <input type="text" class="form-control mb-2" id="tab11_02Search" placeholder="Search..." />
                                                </div>
                                                <div class="col-md-5 col-sm-12">
                                                </div>

                                            </div>
                                            <div id="allMediceneTemplates"></div>
                                        </div>

                                    </div>
                                    <div class="tabs" id="tab12" style="display: none;">
  <div class="vitals-container" style="display:flex; flex-direction:column; gap:12px; width:100%; box-sizing:border-box; padding:8px;">

    <!-- Row 1 -->
    <div style="display:flex; width:100%; flex-wrap:wrap;">
      <div class="vital-row" style="display:flex; align-items:flex-start; width:48%; margin-bottom:15px; padding:5px; box-sizing:border-box;">
        <div style="display:flex; align-items:flex-start; width:100%;">
          <asp:label runat="server" ID="lblIdentificationMarks" Text="Identification Marks"></asp:label>
          <asp:TextBox runat="server" ID="txtIdentificationMarks" TextMode="MultiLine"></asp:TextBox>
        </div>
      </div>

      <div class="vital-row" style="display:flex; align-items:flex-start; width:48%; margin-bottom:15px; padding:5px; box-sizing:border-box;">
        <div style="display:flex; align-items:center; width:100%;">
          <asp:Label runat="server" ID="lblDeathCertifiedBy1" Text="">Death Certified By &nbsp;&nbsp;&nbsp;&nbsp;  1 -</asp:Label>
          <asp:DropDownList runat="server" AppendDataBoundItems="true" ID="ddlDeathCertifiedbyDr1"></asp:DropDownList>
        </div>
      </div>
    </div>

    <!-- Row 2 -->
    <div style="display:flex; width:100%; flex-wrap:wrap;">
      <div style="width:48%; margin-bottom:15px; padding:5px; box-sizing:border-box;"></div>
      <div style="width:48%; margin-bottom:15px; padding:5px; box-sizing:border-box;">
        <div style="display:flex; align-items:center; width:100%;">
          <asp:Label runat="server" ID="lblDeathCertifiedBy2" Text=""> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2 -
          </asp:Label>
          <asp:DropDownList runat="server" ID="ddlDeathCertifiedbyDr2" AppendDataBoundItems="true"></asp:DropDownList>
        </div>
      </div>
    </div>

    <!-- Row 3 -->
    <div style="display:flex; width:100%; flex-wrap:wrap;">
      <div class="vital-row" style="display:flex; align-items:center; width:48%; margin-bottom:15px; padding:5px; box-sizing:border-box;">
        <div style="display:flex; align-items:center; width:100%;">
          <asp:label runat="server" ID="lblDateofDeath" Text="Date Of Death"></asp:label>
          <asp:TextBox runat="server" ID="txtDateofDeath"></asp:TextBox>
        </div>
      </div>

      <div class="vital-row" style="display:flex; align-items:center; width:48%; margin-bottom:15px; padding:5px; box-sizing:border-box;">
        <div style="display:flex; align-items:center; width:100%;">
          <asp:Label runat="server" ID="lblBodyHandedOverTo" Text="Body Handed Over To"></asp:Label>
          <asp:TextBox runat="server" ID="txtBodyHandedOverTo"></asp:TextBox>
        </div>
      </div>
    </div>

    <!-- Row 4 -->
    <div style="display:flex; width:100%; flex-wrap:wrap;">
      <div class="vital-row" style="display:flex; align-items:center; width:48%; margin-bottom:15px; padding:5px; box-sizing:border-box;">
        <div style="display:flex; align-items:center; width:100%;">
          <asp:label runat="server" ID="lblTimeOfDeath" Text="Time Of Death"></asp:label>
          <asp:TextBox runat="server" ID="txtTimeOfDeath"></asp:TextBox>
        </div>
      </div>

      <div class="vital-row" style="display:flex; align-items:center; width:48%; margin-bottom:15px; padding:5px; box-sizing:border-box;">
        <div style="display:flex; align-items:center; width:100%;">
          <asp:Label runat="server" ID="lblFamilyPersonName" Text="Family Person (Name)"></asp:Label>
          <asp:TextBox runat="server" ID="txtFamilyPersonName"></asp:TextBox>
        </div>
      </div>
    </div>

    <!-- Row 5 -->
    <div style="display:flex; width:100%; flex-wrap:wrap;">
      <div class="vital-row" style="display:flex; align-items:center; width:48%; margin-bottom:15px; padding:5px; box-sizing:border-box;">
        <div style="display:flex; align-items:center; width:100%;">
          <asp:label runat="server" ID="lblPlaceOfDeath" Text="Place Of Death"></asp:label>
          <asp:DropDownList ID="ddlPlaceOfDeath" AppendDataBoundItems="true" runat="server"></asp:DropDownList>
        </div>
      </div>

      <div class="vital-row" style="display:flex; align-items:center; width:48%; margin-bottom:15px; padding:5px; box-sizing:border-box;">
        <div style="display:flex; align-items:center; width:100%;">
          <asp:Label runat="server" ID="lbl_CNIC" Text="CNIC"></asp:Label>
          <asp:TextBox runat="server" ID="txtCNIC"></asp:TextBox>
        </div>
      </div>
    </div>

    <!-- Row 6 -->
    <div style="display:flex; width:100%; flex-wrap:wrap;">
      <div class="vital-row" style="display:flex; align-items:flex-start; width:48%; margin-bottom:15px; padding:5px; box-sizing:border-box;">
        <div style="display:flex; align-items:center; width:100%;">
          <asp:label runat="server" ID="lblCauseOfDeath" Text="Cause Of Death"></asp:label>
          <asp:TextBox ID="txtCause_Of_Death" runat="server" Style=""></asp:TextBox>
        </div>
      </div>

      <div class="vital-row" style="display:flex; align-items:center; width:48%; margin-bottom:15px; padding:5px; box-sizing:border-box;">
        <div style="display:flex; align-items:center; width:100%;">
          <asp:Label runat="server" ID="lblRelationWithDeceased" Text="Relation with Deceased"></asp:Label>
          <asp:TextBox runat="server" ID="txtRelationWithDeceased"></asp:TextBox>
        </div>
      </div>
    </div>

    <!-- Row 7 -->
    <div style="display:flex; width:100%; flex-wrap:wrap;">
      <div class="vital-row" style="display:flex; align-items:center; width:48%; margin-bottom:15px; padding:5px; box-sizing:border-box;">
        <div style="display:flex; align-items:center; width:100%;">
          <asp:Label runat="server" ID="lblIssuingOfficerName" Text="Issuing Officer Name"></asp:Label>
          <asp:TextBox runat="server" ID="txtIssuingOfficerName"></asp:TextBox>
        </div>
      </div>

      <div class="vital-row" style="display:flex; align-items:center; width:48%; margin-bottom:15px; padding:5px; box-sizing:border-box;">
        <div style="display:flex; align-items:center; width:100%;">
          <asp:Label runat="server" ID="lblCMO_Police" Text="C.M.O / Police"></asp:Label>
          <asp:TextBox runat="server" ID="txtCMO_Police"></asp:TextBox>
        </div>
      </div>
    </div>

    <!-- Action Row -->
    <div style="display:flex; width:100%; flex-wrap:wrap; gap:12px; margin-top:5px;">
      <div style="width:48%; padding:5px; box-sizing:border-box;">
        <input type="button" style="width:50% !important" id="btnPrint" class="btn-gray" value="Print" onclick="prints();" />
      </div>
    </div>

  </div>
</div>
                                    <div class="tabs" id="tab13" style="display: none">
                                        <!-- Disposal Section -->
                                        <div class="Disposal-container">

                                            <!-- Final Diagnosis -->
                                            <div class="Disposal-row">
                                                <div style="display: flex; align-items: center; width: 100%">
                                                    <asp:Label Style="width: 75%;" ID="Label20" runat="server" Text="Final Diagnosis"></asp:Label>
                                                    <asp:TextBox ID="txtFinalDiagnosis" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="1"></asp:TextBox>
                                                </div>
                                            </div>

                                            <!-- Advice -->
                                            <div class="Disposal-row">
                                                <div style="display: flex; align-items: center; width: 100%">
                                                    <asp:Label Style="width: 75%;" ID="Label21" runat="server" Text="Advice"></asp:Label>
                                                    <asp:TextBox ID="txtAdvice" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="2"></asp:TextBox>
                                                </div>
                                            </div>

                                            <!-- Referral -->
                                            <div class="Disposal-row">
                                                <div style="display: flex; align-items: center; width: 100%">
                                                    <asp:Label Style="width: 75%;" ID="Label22" runat="server" Text="Referral"></asp:Label>
                                                    <asp:TextBox ID="Final_Rec" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="5"></asp:TextBox>
                                                </div>
                                            </div>


                                        </div>
                                        <h4 style="margin-top: 20px" class="btn btn-primry">Protos:</h4>
                                        <asp:DropDownList ID="ddlProto" CssClass="dropdownBackgroud" Width="50%" runat="server" onchange="AddProto();" AppendDataBoundItems="true"></asp:DropDownList>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                </div>

                <!-- Right Column (6 units) -->
                <div class="col-lg-7 preview ">


                    <div id="PreviewPane" class="medical-dashboard" style="height: 85vh; overflow-y: auto;">
                        <div class="dashboard-container">
                            <div class="row g-3">
                                <div class="col-lg-12" id="divtblDischargeDetails" style="display: none; margin-top:12px;">
  <div class="dashboard-card">
    <div class="card-header">
      <h4><i class="fa fa-file-medical-alt"></i> Discharge Details</h4>
    </div>
    <div class="table-responsive" style="overflow:hidden;">
      <table id="tblDischargeDetails" class="table modern-table" style="width:100%; border-collapse:collapse;">
        <thead>
          <tr>
            <th style="width:35%;">Field</th>
            <th style="width:65%;">Value</th>
          </tr>
        </thead>
        <tbody></tbody>
      </table>
    </div>
  </div>
</div>




                                <div class="col-lg-12" id="divtblDoctorCalls" style="display: none;">
  <div class="dashboard-card">
    <div class="card-header">
      <h4><i class="fa fa-user-md"></i> Doctor Calls</h4>
    </div>
    <div class="table-responsive" style="overflow:hidden;">
      <table class="table modern-table" id="tblDoctorCalls" style="width:100%;border-collapse:collapse;">
        <thead>
          <tr>
            <th>Department</th>
            <th>Doctor</th>
            <th>Mobile No</th>
            <th>Doctor Notes</th>
          </tr>
        </thead>
        <tbody></tbody>
      </table>
    </div>
  </div>
</div>




                                <div class="col-lg-12" id="divtblDischargeVitals" style="display: none;">
  <div class="dashboard-card">
    <div class="card-header">
      <h4><i class="fa fa-heartbeat"></i> Discharge Vitals</h4>
    </div>
    <div class="table-responsive">
      <table class="table modern-table" id="tblDischargeVitals" style="width:100%;border-collapse:collapse;">
        <thead>
          <tr>
            <th>Pulse</th>
            <th>B.P.</th>
            <th>Rhythm</th>
            <th>Temp</th>
            <th>Volume</th>
            <th>Resp.</th>
            <th>O2 Sat</th>
            <th>Percentage</th>
            <th>Liters/Min</th>
            <th>Room Air</th>
            <th>With O2</th>
            <th>Others</th>
            <th>Receiving Date & Time</th>
            <th>Special Instruction</th>
          </tr>
        </thead>
        <tbody></tbody>
      </table>
    </div>
  </div>
</div>
                                <!-- Six separate tables - one per section. Keep structure/classes same as your Vitals/History panels. -->
<div class="col-lg-9" id="divtblCVS" style="display: none">
    <div class="dashboard-card">
        <div class="card-header"><h4><i class="fa fa-stethoscope"></i> CVS Findings</h4></div>
        <div class="table-responsive">
            <table class="table modern-table" id="tblCVS">
                <thead><tr><th>Finding</th><th style="width:48px">Action</th></tr></thead>
                <tbody></tbody>
            </table>
        </div>
    </div>
</div>

<div class="col-lg-9" id="divtblGCS" style="display: none">
    <div class="dashboard-card">
        <div class="card-header"><h4><i class="fa fa-brain"></i> GCS Findings</h4></div>
        <div class="table-responsive">
            <table class="table modern-table" id="tblGCS">
                <thead><tr><th>Finding</th><th style="width:48px">Action</th></tr></thead>
                <tbody></tbody>
            </table>
        </div>
    </div>
</div>

<div class="col-lg-9" id="divtblGPE" style="display: none">
    <div class="dashboard-card">
        <div class="card-header"><h4><i class="fa fa-user-md"></i> GPE Findings</h4></div>
        <div class="table-responsive">
            <table class="table modern-table" id="tblGPE">
                <thead><tr><th>Finding</th><th style="width:48px">Action</th></tr></thead>
                <tbody></tbody>
            </table>
        </div>
    </div>
</div>

<div class="col-lg-9" id="divtblRESP" style="display: none">
    <div class="dashboard-card">
        <div class="card-header"><h4><i class="fa fa-lungs"></i> RESP Findings</h4></div>
        <div class="table-responsive">
            <table class="table modern-table" id="tblRESP">
                <thead><tr><th>Finding</th><th style="width:48px">Action</th></tr></thead>
                <tbody></tbody>
            </table>
        </div>
    </div>
</div>

<div class="col-lg-9" id="divtblGIT" style="display: none">
    <div class="dashboard-card">
        <div class="card-header"><h4><i class="fa fa-stomach"></i> GIT Findings</h4></div>
        <div class="table-responsive">
            <table class="table modern-table" id="tblGIT">
                <thead><tr><th>Finding</th><th style="width:48px">Action</th></tr></thead>
                <tbody></tbody>
            </table>
        </div>
    </div>
</div>

<div class="col-lg-9" id="divtblCNS" style="display: none">
    <div class="dashboard-card">
        <div class="card-header"><h4><i class="fa fa-brain"></i> CNS Findings</h4></div>
        <div class="table-responsive">
            <table class="table modern-table" id="tblCNS">
                <thead><tr><th>Finding</th><th style="width:48px">Action</th></tr></thead>
                <tbody></tbody>
            </table>
        </div>
    </div>
</div>


                                <div class="col-lg-9" id="divtblAdmissions">
    <div class="dashboard-card">
        <div class="card-header">
            <h4><i class="fa fa-procedures"></i> Admission Info</h4>
        </div>
        <div class="table-responsive">
            <table class="table modern-table" id="tblAdmissions">
                <thead>
                    <tr>
                        <th>Triage</th>
                        <th>Doctor</th>
                        <th>Ward</th>
                        <th>Bed No</th>
                        <th>Admission Fee</th>
                        <th>Admission Date</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
    </div>
</div>
                                <!-- Lab Tests Panel -->
                                <div class="col-lg-12" id="dvtblLabtest" style="display: none">
                                    <div class="dashboard-card">
                                        <div class="card-header">
                                            <h4><i class="fa fa-flask"></i>Lab Tests</h4>

                                        </div>
                                        <div class="table-responsive">
                                            <table class="table modern-table" id="tblLabtest">
                                                <thead>
                                                    <tr style="position: sticky; top: 0; z-index: 10;">
                                                        <th style="display: none">Date</th>
                                                        <th>Test Name</th>
                                                        <th style="display: none">Sample Received</th>
                                                        <th style="display: none">Result</th>
                                                        <th>Special Tests</th>
                                                        <th>Area Of Interest</th>
                                                        <th style="display: none">Rotation</th>
                                                        <th>Action</th>
                                                    </tr>
                                                </thead>
                                                <tbody id="loadtest"></tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>

                                <!-- Diagnostic Tests Panel -->
                                <div class="col-lg-12" id="dvtblDiagnostictest" style="display: none">
                                    <div class="dashboard-card">
                                        <div class="card-header">
                                            <h4><i class="fa fa-x-ray"></i>Diagnostic Tests</h4>

                                        </div>
                                        <div class="table-responsive">
                                            <table class="table modern-table" id="tblDiagnostictest">
                                                <thead>

                                                    <tr style="position: sticky; top: 0; z-index: 10;">
                                                        <th style="display: none">Date</th>
                                                        <th style="width:30%">Test Name</th>
                                                        <th style="display: none">Sample Received</th>
                                                        <th style="display: none">Result</th>
                                                        <th style="width:30%">Special Tests</th>
                                                        <th style="width:20%">Area Of Interest</th>
                                                        <th style="width:10%">Rotation</th>
                                                        <th style="width:10%" class="actions-col">Action</th>
                                                    </tr>

                                                </thead>
                                                <tbody id="loadDiagnostictest"></tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>

                                <!-- Medicines Panel -->
                                <div class="col-lg-12" id="dvtblMedicines" style="display: none">
                                    <div class="dashboard-card">
                                        <div class="card-header">
                                            <h4><i class="fa fa-pills"></i>Medicines</h4>

                                        </div>
                                        <div class="table-responsive">
                                            <table class="table modern-table" id="tblMedicines">
                                                <thead>
                                                    <tr style="position: sticky; top: 0px; z-index: 10;">
                                                        <th style="display: none">Date</th>
                                                        <th>Medicine Name</th>
                                                        <th>Frequency</th>
                                                        <th>Routes</th>
                                                        <th>Duration</th>
                                                        <th>Special Instructions</th>
                                                        <th>Dosage Form</th>
                                                        <th>Dosage Qty</th>
                                                        <th>Other Instructions</th>
                                                        <th>Edit</th>
                                                    </tr>
                                                </thead>
                                                <tbody></tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>

                                <!-- Refer Panel -->
                                <div class="col-lg-3" id="divtblRefer" style="display: none">
                                    <div class="dashboard-card">
                                        <div class="card-header">
                                            <h4><i class="fa fa-user-md"></i>Refer</h4>
                                        </div>
                                        <div class="table-responsive">
                                            <table class="table modern-table" id="tblRefer">
                                                <thead class="hidden">
                                                    <tr>
                                                        <th>Refer</th>
                                                    </tr>
                                                </thead>
                                                <tbody></tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                                <!-- Vitals Panel -->
                                <div class="col-lg-12" id="divtblVitals" style="display: none">
    <div class="dashboard-card">
        <div class="card-header">
            <h4><i class="fa fa-heartbeat"></i> Vitals</h4>
        </div>
        <div class="table-responsive">
            <table class="table modern-table" id="tblVitals">
                <thead>
                    <tr>
                        <th>Pulse</th>
                        <th>B.P.</th>
                        <th>Temp</th>
                        <th>Resp.</th>
                        <th>Rhythm</th>
                        <th>Volume</th>
                        <th>O2 Sat</th>
                        <th>Percentage</th>
                        <th>Liters/Min</th>
                        <th>Room Air</th>
                        <th>With O2</th>
                        <th>Others</th>
                        <th>Receiving Date & Time</th>
                        <th>Special Instruction</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
    </div>
</div>
                                <!-- Symptoms Panel -->
                                <div class="col-lg-3" id="dvtblSymtomps">
                                    <div class="dashboard-card">
                                        <div class="card-header">
                                            <h4><i class="fa fa-thermometer-half"></i>Symptoms</h4>

                                        </div>
                                        <div class="table-responsive">
                                            <table class="table modern-table" id="tblSymtoms">
                                                <thead class="hidden">
                                                    <tr>
                                                        <th>Symptoms</th>
                                                        <th class="actions-col"></th>
                                                    </tr>
                                                </thead>
                                                <tbody></tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>

                                <!-- Complaints Panel -->
                                <div class="col-lg-4" id="dvtblComplaints" style="display: none">
                                    <div class="dashboard-card">
                                        <div class="card-header">
                                            <h4><i class="fa fa-comment-medical"></i>Complaints</h4>

                                        </div>
                                        <div class="table-responsive">
                                            <table class="table modern-table" id="tblComplaints">
                                                <thead class="hidden">
                                                    <tr>
                                                        <th>Complaints</th>
                                                        <th class="actions-col"></th>
                                                    </tr>
                                                </thead>
                                                <tbody></tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>

                                



                                <!-- General Examination Panel -->
                                <div class="col-lg-3" id="divtblGeneralExam" style="display: none">
                                    <div class="dashboard-card">
                                        <div class="card-header">
                                            <h4><i class="fa fa-stethoscope"></i>General Exam</h4>
                                        </div>
                                        <div class="table-responsive">
                                            <table class="table modern-table" id="tblGeneralExam">
                                                <thead class="hidden">
                                                    <tr>
                                                        <th>General Examination</th>
                                                        <th class="actions-col"></th>
                                                    </tr>
                                                </thead>
                                                <tbody></tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>

                                <!-- Systematic Examination Panel -->
                                <div class="col-lg-6" id="divtblSystematicExam" style="display: none">
                                    <div class="dashboard-card">
                                        <div class="card-header">
                                            <h4><i class="fa fa-procedures"></i>Systematic Exam</h4>
                                        </div>
                                        <div class="table-responsive">
                                            <table class="table modern-table" id="SystematicExam">
                                                <thead class="hidden">
                                                    <tr>
                                                        <th>Systematic Examination</th>
                                                    </tr>
                                                </thead>
                                                <tbody></tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>



                                <!-- Diagnosis Panels -->
                                <div class="col-lg-4" id="dvtblPrimaryDiagnosis" style="display: none">
                                    <div class="dashboard-card">
                                        <div class="card-header">
                                            <h4><i class="fa fa-diagnoses"></i>Primary Diagnosis</h4>

                                        </div>
                                        <div class="table-responsive">
                                            <table class="table modern-table" id="tblPrimaryDiagnosis">
                                                <thead class="hidden">
                                                    <tr>
                                                        <th>Primary Diagnosis</th>
                                                        <th class="actions-col"></th>
                                                    </tr>
                                                </thead>
                                                <tbody></tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-lg-4" id="dvtblFinalDiagnosis" style="display: none">
                                    <div class="dashboard-card">
                                        <div class="card-header">
                                            <h4><i class="fa fa-file-medical-alt"></i>Final Diagnosis</h4>

                                        </div>
                                        <div class="table-responsive">
                                            <table class="table modern-table" id="tblFinalDiagnosis">
                                                <thead class="hidden">
                                                    <tr>
                                                        <th>Final Diagnosis</th>
                                                        <th class="actions-col"></th>
                                                    </tr>
                                                </thead>
                                                <tbody></tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>

                                <!-- Disposal Panel -->
                                <div class="col-lg-4" id="divtblDisposal" style="display: none">
                                    <div class="dashboard-card">
                                        <div class="card-header">
                                            <h4><i class="fa fa-sign-out-alt"></i>Disposal</h4>
                                        </div>
                                        <div class="table-responsive">
                                            <table class="table modern-table" id="tblDisposal">
                                                <thead class="hidden">
                                                    <tr>
                                                        <th>Disposal</th>
                                                    </tr>
                                                </thead>
                                                <tbody></tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>


                                <!-- Follow Up Panel -->
                                <div class="col-lg-8" id="divtblFollowUp" style="display: none">
                                    <div class="dashboard-card">
                                        <div class="card-header">
                                            <h4><i class="fa fa-calendar-check"></i>Follow Up</h4>
                                        </div>
                                        <div class="table-responsive">
                                            <table class="table modern-table" id="tblFollowUp">
                                                <thead>
                                                    <tr>
                                                        <th>Doctor Name</th>
                                                        <th>Designation</th>
                                                        <th>Admission</th>
                                                        <th>Follow Up</th>
                                                        <th>Date</th>
                                                    </tr>
                                                </thead>
                                                <tbody></tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>

                                                                <!-- History Panel -->

<div class="col-lg-9" id="divtblHistory" style="display: none">
    <div class="dashboard-card">
        <div class="card-header">
            <h4><i class="fa fa-file-alt"></i> History</h4>
        </div>
        <div class="table-responsive">
            <table class="table modern-table" id="tblHistory">
                <thead>
                    <tr>
                        <th>History</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
    </div>
</div>
                                <!-- Protos Panel -->
                                <div class="col-lg-4" id="dvtblProto" style="display: none">
                                    <div class="dashboard-card">
                                        <div class="card-header">
                                            <h4><i class="fa fa-file-prescription"></i>Protos</h4>
                                        </div>
                                        <div class="table-responsive">
                                            <table class="table modern-table" id="tblProto">
                                                <thead class="hidden">
                                                    <tr>
                                                        <th>Protos</th>
                                                        <th class="actions-col">Action</th>
                                                    </tr>
                                                </thead>
                                                <tbody></tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                                
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </div>

    </div>


    <asp:TextBox ID="txtOut_Patient_ID" runat="server" ReadOnly="True" Style="display: none;"></asp:TextBox>
    <asp:HiddenField ID="hdfPatient_ID" Value="(New)" runat="server" />
    <asp:HiddenField ID="hdfReg_ID" Value="(New)" runat="server" />
    <asp:HiddenField ID="hdfPatient_No" runat="server" />
    <asp:HiddenField ID="hdfdhischarge" Value="false" runat="server" />
    <asp:HiddenField ID="hdfFetch_ID" runat="server" />



    <asp:TextBox ID="txtPatient_ID" runat="server"></asp:TextBox>
<asp:HiddenField ID="HiddenField1" runat="server" Value="(New)" ClientIDMode="Static" />

    
</asp:Content>
