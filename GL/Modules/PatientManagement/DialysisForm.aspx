<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DialysisForm.aspx.cs" Inherits="PMS.Modules.PatientManagement.DialysisForm" %>

 
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script>
        $(document).ready(function () {
            initializeForm();
            loadDropdowns();
        });

        function initializeForm() {
            $('#btnAddPatient').click(function () {
                $('#patientModal').addClass('show');
                loadPatients();
            });

            $('#closePatientModal, #btnCloseModal').click(function () {
                $('#patientModal').removeClass('show');
            });

            $('#btnSearchPatient').click(function () {
                var searchText = $('#txtPatientSearch').val();
                searchPatients(searchText);
            });

            $('#txtPatientSearch').on('keyup', function (e) {
                if (e.keyCode === 13) {
                    var searchText = $(this).val();
                    searchPatients(searchText);
                }
            });

            $('#btnSaveStep1').click(function () {
                saveStep1();
            });

            $('#btnSaveStep2').click(function () {
                saveStep2();
            });

            $('#btnSaveStep3').click(function () {
                saveStep3();
            });

            $('#btnBackToStep1').click(function () {
                navigateToStep(1);
            });

            $('#btnBackToStep2').click(function () {
                navigateToStep(2);
            });

            $('#btnAddVital').click(function () {
                addVitalSign();
            });
        }

        function loadDropdowns() {
            loadVascularAccess();
            loadMachines();
            loadDialyzers();
            loadDoctors();
            loadNurses();
            loadHeparin();
            loadDialysisTypes();
        }

        function loadVascularAccess() {
            $.ajax({
                type: "POST",
                url: "DialysisForm.aspx/GetVascularAccess",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    var ddl = $('#ddlVascularAccess');
                    ddl.empty();
                    ddl.append('<option value="">Select</option>');
                    $.each(data, function (i, item) {
                        ddl.append($('<option></option>').val(item.Id).html(item.Name));
                    });
                }
            });
        }

        function loadMachines() {
            $.ajax({
                type: "POST",
                url: "DialysisForm.aspx/GetMachines",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    var ddl = $('#ddlMachineNo');
                    ddl.empty();
                    ddl.append('<option value="">Select</option>');
                    $.each(data, function (i, item) {
                        ddl.append($('<option></option>').val(item.Id).html(item.Name));
                    });
                }
            });
        }

        function loadDialyzers() {
            $.ajax({
                type: "POST",
                url: "DialysisForm.aspx/GetDialyzers",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    var ddl = $('#ddlDialyzer');
                    ddl.empty();
                    ddl.append('<option value="">Select</option>');
                    $.each(data, function (i, item) {
                        ddl.append($('<option></option>').val(item.Id).html(item.Name));
                    });
                }
            });
        }

        function loadDoctors() {
            $.ajax({
                type: "POST",
                url: "DialysisForm.aspx/GetDoctors",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    var ddl = $('#ddlAdvisedBy');
                    ddl.empty();
                    ddl.append('<option value="">Nothing selected</option>');
                    $.each(data, function (i, item) {
                        ddl.append($('<option></option>').val(item.Id).html(item.Name));
                    });
                }
            });
        }

        function loadNurses() {
            $.ajax({
                type: "POST",
                url: "DialysisForm.aspx/GetNurses",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    var ddl = $('#ddlPrimingBy');
                    ddl.empty();
                    ddl.append('<option value="">Nothing selected</option>');
                    $.each(data, function (i, item) {
                        ddl.append($('<option></option>').val(item.Id).html(item.Name));
                    });
                }
            });
        }

        function loadHeparin() {
            $.ajax({
                type: "POST",
                url: "DialysisForm.aspx/GetHeparin",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    var ddl = $('#ddlHeparin');
                    ddl.empty();
                    ddl.append('<option value="">Nothing selected</option>');
                    $.each(data, function (i, item) {
                        ddl.append($('<option></option>').val(item.Id).html(item.Name));
                    });
                }
            });
        }

        function loadDialysisTypes() {
            $.ajax({
                type: "POST",
                url: "DialysisForm.aspx/GetDialysisTypes",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    var ddl = $('#ddlDialysisType');
                    ddl.empty();
                    ddl.append('<option value="">Select</option>');
                    $.each(data, function (i, item) {
                        ddl.append($('<option></option>').val(item.Id).html(item.Name));
                    });
                }
            });
        }

        function loadPatients() {
            $.ajax({
                type: "POST",
                url: "DialysisForm.aspx/GetPatients",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    bindPatientTable(data);
                }
            });
        }

        function searchPatients(searchText) {
            $.ajax({
                type: "POST",
                url: "DialysisForm.aspx/SearchPatients",
                data: JSON.stringify({ searchText: searchText }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    bindPatientTable(data);
                }
            });
        }

        function bindPatientTable(data) {
            var tbody = $('#patientTableBody');
            tbody.empty();
            $.each(data, function (i, item) {
                var row = '<tr>' +
                    '<td style="display:none;">' + item.PatientId + '</td>' +
                    '<td>' + item.MRNo + '</td>' +
                    '<td>' + item.PatientName + '</td>' +
                    '<td>' + item.FatherName + '</td>' +
                    '<td>' + item.CNIC + '</td>' +
                    '<td>' + item.ContactNo + '</td>' +
                    '<td><span class="action-icon" onclick="selectPatient(' + item.PatientId + ',\'' +
                    item.MRNo + '\',\'' + item.PatientName + '\',\'' + item.Age + '\',\'' +
                    item.Gender + '\',\'' + item.ContactNo + '\')">➕</span></td>' +
                    '</tr>';
                tbody.append(row);
            });
        }

        function selectPatient(id, mrNo, name, age, gender, contact) {
            $('#hdfPatientId').val(id);
            $('#infoMrNo').text(mrNo);
            $('#infoPatientName').text(name);
            $('#infoAge').text(age);
            $('#infoGender').text(gender);
            $('#infoContact').text(contact);
            $('#patientInfoBar').addClass('show');
            $('#patientModal').removeClass('show');
        }

        function navigateToStep(stepNumber) {
            var step1Saved = $('#hdfStep1Saved').val() === 'true';
            var step2Saved = $('#hdfStep2Saved').val() === 'true';

            if (stepNumber === 2 && !step1Saved) {
                alert('Please save Step 1 first');
                return;
            }

            if (stepNumber === 3 && !step2Saved) {
                alert('Please save Step 2 first');
                return;
            }

            $('.form-section').removeClass('active');
            $('.step-item').removeClass('active');

            $('#section' + stepNumber).addClass('active');
            $('#step' + stepNumber + 'Nav').addClass('active');
            $('#hdfCurrentStep').val(stepNumber);
        }

        function saveStep1() {
            var patientId = $('#hdfPatientId').val();
            if (!patientId) {
                alert('Please select a patient first');
                return;
            }

            var data = {
                PatientId: patientId,
                VascularAccess: $('#ddlVascularAccess').val(),
                DialysisNo: $('#txtDialysisNo').val(),
                MachineNo: $('#ddlMachineNo').val(),
                Dialyzer: $('#ddlDialyzer').val(),
                AdvisedBy: $('#ddlAdvisedBy').val(),
                PrimingBy: $('#ddlPrimingBy').val(),
                PrimingSol: $('#txtPrimingSol').val(),
                Heparin: $('#ddlHeparin').val(),
                HeparinInfusion: $('#txtHeparinInfusion').val(),
                CurrentWeight: $('#txtCurrentWeight').val(),
                LastWeight: $('#txtLastWeight').val(),
                StartTime: $('#txtStartTime').val(),
                FinishTime: $('#txtFinishTime').val(),
                WeightDiff: $('#txtWeightDiff').val(),
                UF: $('#txtUF').val(),
                UFRate: $('#txtUFRate').val(),
                TotalDuration: $('#txtTotalDuration').val(),
                DialysisType: $('#ddlDialysisType').val(),
                SpecialInstruction: $('#txtSpecialInstruction').val(),
                Complaints: $('#txtComplaints').val(),
                ConsciousLevel: $('#txtConsciousLevel').val(),
                Edema: $('#txtEdema').val(),
                CardRhythm: $('#txtCardRhythm').val(),
                Lungs: $('#txtLungs').val(),
                Other: $('#txtOther').val(),
                Remarks: $('#txtRemarks').val()
            };

            $.ajax({
                type: "POST",
                url: "DialysisForm.aspx/SavePreDialysis",
                data: JSON.stringify(data),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d === 'success') {
                        $('#hdfStep1Saved').val('true');
                        $('#step1Nav').addClass('completed');
                        $('#step2Nav').removeClass('disabled');
                        alert('Step 1 saved successfully');
                        navigateToStep(2);
                    } else {
                        alert('Error saving data');
                    }
                }
            });
        }

        function saveStep2() {
            var data = {
                PatientId: $('#hdfPatientId').val(),
                VitalSigns: getVitalSignsData()
            };

            $.ajax({
                type: "POST",
                url: "DialysisForm.aspx/SaveDuringDialysis",
                data: JSON.stringify(data),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d === 'success') {
                        $('#hdfStep2Saved').val('true');
                        $('#step2Nav').addClass('completed');
                        $('#step3Nav').removeClass('disabled');
                        alert('Step 2 saved successfully');
                        navigateToStep(3);
                    } else {
                        alert('Error saving data');
                    }
                }
            });
        }

        function saveStep3() {
            var data = {
                PatientId: $('#hdfPatientId').val(),
                PostWeight: $('#txtPostWeight').val(),
                TotalUF: $('#txtTotalUF').val(),
                BloodFlowRate: $('#txtPostBloodFlow').val(),
                DialysateFlowRate: $('#txtDialysateFlow').val(),
                PostBPSys: $('#txtPostBPSys').val(),
                PostBPDias: $('#txtPostBPDias').val(),
                PostPulse: $('#txtPostPulse').val(),
                Complications: $('#txtComplications').val(),
                Interventions: $('#txtInterventions').val(),
                PostRemarks: $('#txtPostRemarks').val()
            };

            $.ajax({
                type: "POST",
                url: "DialysisForm.aspx/SavePostDialysis",
                data: JSON.stringify(data),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d === 'success') {
                        $('#step3Nav').addClass('completed');
                        alert('Dialysis form completed successfully');
                    } else {
                        alert('Error saving data');
                    }
                }
            });
        }

        function addVitalSign() {
            var time = $('#txtVitalTime').val();
            var temp = $('#txtTemperature').val();
            var bpSys = $('#txtBPSys').val();
            var bpDias = $('#txtBPDias').val();
            var pulse = $('#txtPulse').val();
            var bloodFlow = $('#txtBloodFlow').val();

            var row = '<tr>' +
                '<td>' + time + '</td>' +
                '<td>' + temp + '</td>' +
                '<td>' + bpSys + '</td>' +
                '<td>' + bpDias + '</td>' +
                '<td>' + pulse + '</td>' +
                '<td>' + bloodFlow + '</td>' +
                '<td><span class="action-icon" onclick="deleteVitalRow(this)">🗑️</span></td>' +
                '</tr>';

            $('#vitalSignsBody').append(row);

            $('#txtVitalTime').val('');
            $('#txtTemperature').val('');
            $('#txtBPSys').val('');
            $('#txtBPDias').val('');
            $('#txtPulse').val('');
            $('#txtBloodFlow').val('');
        }

        function deleteVitalRow(btn) {
            $(btn).closest('tr').remove();
        }

        function getVitalSignsData() {
            var vitals = [];
            $('#vitalSignsBody tr').each(function () {
                var vital = {
                    Time: $(this).find('td:eq(0)').text(),
                    Temperature: $(this).find('td:eq(1)').text(),
                    BPSys: $(this).find('td:eq(2)').text(),
                    BPDias: $(this).find('td:eq(3)').text(),
                    Pulse: $(this).find('td:eq(4)').text(),
                    BloodFlow: $(this).find('td:eq(5)').text()
                };
                vitals.push(vital);
            });
            return JSON.stringify(vitals);
        }
    </script>
    <style>
   

 
    /* Step Navigation */
    .step-navigation {
        display: flex;
        justify-content: center;
        align-items: center;
        margin-bottom: 40px;
        padding: 20px 0;
        border-bottom: 2px solid #e0e0e0;
    }

    .step-item {
        display: flex;
        flex-direction: column;
        align-items: center;
        position: relative;
        cursor: pointer;
    }

    .step-item.disabled {
        cursor: not-allowed;
        opacity: 0.5;
    }

    .step-icon {
        width: 60px;
        height: 60px;
        border-radius: 50%;
        background-color: #e0e0e0;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 28px;
        margin-bottom: 10px;
        transition: all 0.3s ease;
    }

    .step-item.active .step-icon {
        background-color: #4A90E2;
        color: white;
    }

    .step-item.completed .step-icon {
        background-color: #28a745;
        color: white;
    }

    .step-label {
        font-size: 14px;
        font-weight: 500;
        color: #666;
        text-align: center;
    }

    .step-item.active .step-label {
        color: #4A90E2;
        font-weight: 600;
    }

    .step-arrow {
        font-size: 24px;
        color: #ccc;
        margin: 0 30px;
        margin-bottom: 30px;
    }

    /* Patient Info Bar */
    .patient-info-bar {
        background-color: #f8f9fa;
        padding: 15px 20px;
        border-radius: 5px;
        margin-bottom: 20px;
        border-left: 4px solid #4A90E2;
        display: none;
    }

    .patient-info-bar.show {
        display: block;
    }

    .patient-info-content {
        display: flex;
        align-items: center;
        flex-wrap: wrap;
        gap: 20px;
        font-size: 14px;
    }

    .patient-info-item {
        display: flex;
        gap: 5px;
    }

    .patient-info-label {
        font-weight: 600;
        color: #333;
    }

    .patient-info-value {
        color: #666;
    }

 

    /* Form Sections */
    .form-section {
        display: none;
        animation: fadeIn 0.3s ease;
    }

    .form-section.active {
        display: block;
    }

    @keyframes fadeIn {
        from {
            opacity: 0;
            transform: translateY(10px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    .row {
        display: flex;
        flex-wrap: wrap;
        margin: 0 -10px 20px -10px;
    }

    .col-lg-2, .col-lg-3, .col-lg-4, .col-lg-6, .col-lg-12 {
        padding: 0 10px;
        margin-bottom: 15px;
    }

    .col-lg-2 { width: 16.66%; }
    .col-lg-3 { width: 25%; }
    .col-lg-4 { width: 33.33%; }
    .col-lg-6 { width: 50%; }
    .col-lg-12 { width: 100%; }

    label {
        display: block;
        margin-bottom: 5px;
        font-size: 13px;
        font-weight: 500;
        color: #333;
    }

    label .required {
        color: red;
        margin-left: 3px;
    }

    input[type="text"],
    input[type="number"],
    input[type="time"],
    select,
    textarea {
        width: 100%;
        padding: 8px 12px;
        border: 1px solid #ddd;
        border-radius: 4px;
        font-size: 14px;
        transition: border-color 0.3s ease;
    }

    input[type="text"]:focus,
    input[type="number"]:focus,
    input[type="time"]:focus,
    select:focus,
    textarea:focus {
        outline: none;
        border-color: #4A90E2;
    }

    input[readonly] {
        background-color: #f5f5f5;
        cursor: not-allowed;
    }

    textarea {
        resize: vertical;
        min-height: 80px;
    }

    /* Vital Signs Grid */
    .vital-signs-row {
        display: flex;
        gap: 10px;
        margin-bottom: 15px;
    }

    .vital-signs-row .col-lg-2 {
        flex: 1;
    }

    /* Action Buttons */
    .action-buttons {
        display: flex;
        gap: 15px;
        justify-content: flex-end;
        margin-top: 30px;
        padding-top: 20px;
        border-top: 2px solid #e0e0e0;
    }

    .btn {
        padding: 10px 25px;
        border: none;
        border-radius: 5px;
        font-size: 14px;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.3s ease;
    }

    .btn-primary {
        background-color: #4A90E2;
        color: white;
    }

    .btn-primary:hover {
        background-color: #357ABD;
    }

    .btn-secondary {
        background-color: #6c757d;
        color: white;
    }

    .btn-secondary:hover {
        background-color: #545b62;
    }

    .btn-success {
        background-color: #28a745;
        color: white;
    }

    .btn-success:hover {
        background-color: #218838;
    }

    /* Modal Styles */
    .modal {
        display: none;
        position: fixed;
        z-index: 1000;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
        overflow: auto;
        background-color: rgba(0,0,0,0.4);
        animation: fadeIn 0.3s ease;
    }

    .modal.show {
        display: block;
    }

    .modal-dialog {
        position: relative;
        width: auto;
        max-width: 900px;
        margin: 30px auto;
    }

    .modal-content {
        position: relative;
        background-color: #fff;
        border-radius: 8px;
        box-shadow: 0 5px 15px rgba(0,0,0,0.3);
        animation: slideDown 0.3s ease;
    }

    @keyframes slideDown {
        from {
            transform: translateY(-50px);
            opacity: 0;
        }
        to {
            transform: translateY(0);
            opacity: 1;
        }
    }

    .modal-header {
        padding: 20px;
        border-bottom: 1px solid #dee2e6;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .modal-title {
        font-size: 18px;
        font-weight: 600;
        color: #333;
    }

    .modal-body {
        padding: 20px;
        max-height: 70vh;
        overflow-y: auto;
    }

    .modal-footer {
        padding: 15px 20px;
        border-top: 1px solid #dee2e6;
        display: flex;
        justify-content: flex-end;
        gap: 10px;
    }

    .close {
        background: none;
        border: none;
        font-size: 28px;
        font-weight: 300;
        color: #999;
        cursor: pointer;
        line-height: 1;
    }

    .close:hover {
        color: #333;
    }

    /* Search Bar */
    .search-container {
        margin-bottom: 20px;
    }

    .search-input-group {
        display: flex;
        gap: 10px;
    }

    .search-input-group input {
        flex: 1;
    }

    /* Table Styles */
    .table-responsive {
        overflow-x: auto;
    }

    table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 15px;
    }

    table thead {
        background-color: #f8f9fa;
    }

    table th {
        padding: 12px;
        text-align: left;
        font-size: 13px;
        font-weight: 600;
        color: #333;
        border-bottom: 2px solid #dee2e6;
    }
    #btnAddPatient {
    display: block;
    margin-left: auto;
    margin-right: 0;
}
    table td {
        padding: 12px;
        font-size: 13px;
        color: #666;
        border-bottom: 1px solid #dee2e6;
    }

    table tbody tr:hover {
        background-color: #f8f9fa;
        cursor: pointer;
    }

    .action-icon {
        cursor: pointer;
        color: #4A90E2;
        font-size: 16px;
        margin: 0 5px;
    }

    .action-icon:hover {
        color: #357ABD;
    }

    @media (max-width: 992px) {
        .col-lg-2, .col-lg-3, .col-lg-4, .col-lg-6 {
            width: 50%;
        }
    }

    @media (max-width: 576px) {
        .col-lg-2, .col-lg-3, .col-lg-4, .col-lg-6 {
            width: 100%;
        }

        .step-arrow {
            margin: 0 10px;
        }

       
    }
</style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    
     <div class="container-fluid">
         <asp:HiddenField ID="hdfPatientId" runat="server" ClientIDMode="Static" />
         <asp:HiddenField ID="hdfCurrentStep" runat="server" ClientIDMode="Static" Value="1" />
         <asp:HiddenField ID="hdfStep1Saved" runat="server" ClientIDMode="Static" Value="false" />
         <asp:HiddenField ID="hdfStep2Saved" runat="server" ClientIDMode="Static" Value="false" />

    <button type="button" class="btn-primry" id="btnAddPatient">
        <i class="fa fa-plus"></i> Add Patient
    </button>


         <!-- Patient Info Bar -->
         <div class="patient-info-bar" id="patientInfoBar">
             <div class="patient-info-content">
                 <div class="patient-info-item">
                     <span class="patient-info-label">MR No:</span>
                     <span class="patient-info-value" id="infoMrNo">-</span>
                 </div>
                 <div class="patient-info-item">
                     <span class="patient-info-label">Name:</span>
                     <span class="patient-info-value" id="infoPatientName">-</span>
                 </div>
                 <div class="patient-info-item">
                     <span class="patient-info-label">Age:</span>
                     <span class="patient-info-value" id="infoAge">-</span>
                 </div>
                 <div class="patient-info-item">
                     <span class="patient-info-label">Gender:</span>
                     <span class="patient-info-value" id="infoGender">-</span>
                 </div>
                 <div class="patient-info-item">
                     <span class="patient-info-label">Contact:</span>
                     <span class="patient-info-value" id="infoContact">-</span>
                 </div>
             </div>
         </div>

         <!-- Step Navigation -->
         <div class="step-navigation">
             <div class="step-item active" id="step1Nav" onclick="navigateToStep(1)">
                 <div class="step-icon">⏳</div>
                 <div class="step-label">1. Pre Dialysis</div>
             </div>
             <div class="step-arrow">→</div>
             <div class="step-item disabled" id="step2Nav" onclick="navigateToStep(2)">
                 <div class="step-icon">✓</div>
                 <div class="step-label">2. During Dialysis</div>
             </div>
             <div class="step-arrow">→</div>
             <div class="step-item disabled" id="step3Nav" onclick="navigateToStep(3)">
                 <div class="step-icon">📋</div>
                 <div class="step-label">3. Post Dialysis</div>
             </div>
         </div>

         <!-- Step 1: Pre Dialysis -->
         <div class="form-section active" id="section1">
             <div class="row">
                 <div class="col-lg-3">
                     <label>Vascular Access<span class="required">*</span></label>
                     <select id="ddlVascularAccess" class="form-control">
                         <option value="">Select</option>
                     </select>
                 </div>
                 <div class="col-lg-3">
                     <label>Dialysis No.</label>
                     <input type="text" id="txtDialysisNo" class="form-control" placeholder="Dialysis Number" />
                 </div>
                 <div class="col-lg-3">
                     <label>Dialysis Machine No.<span class="required">*</span></label>
                     <select id="ddlMachineNo" class="form-control">
                         <option value="">Select</option>
                     </select>
                 </div>
                 <div class="col-lg-3">
                     <label>Dialyzer</label>
                     <select id="ddlDialyzer" class="form-control">
                         <option value="">Select</option>
                     </select>
                 </div>
             </div>

             <div class="row">
                 <div class="col-lg-3">
                     <label>Advised by<span class="required">*</span></label>
                     <select id="ddlAdvisedBy" class="form-control">
                         <option value="">Nothing selected</option>
                     </select>
                 </div>
                 <div class="col-lg-3">
                     <label>Priming By<span class="required">*</span></label>
                     <select id="ddlPrimingBy" class="form-control">
                         <option value="">Nothing selected</option>
                     </select>
                 </div>
                 <div class="col-lg-3">
                     <label>Priming Sol.</label>
                     <input type="text" id="txtPrimingSol" class="form-control" value="Dental Mould for pouring" />
                 </div>
                 <div class="col-lg-3">
                     <label>Heparin</label>
                     <select id="ddlHeparin" class="form-control">
                         <option value="">Nothing selected</option>
                     </select>
                 </div>
             </div>

             <div class="row">
                 <div class="col-lg-3">
                     <label>Heparin Infusion / Hour</label>
                     <input type="text" id="txtHeparinInfusion" class="form-control" placeholder="Heparin Infusion / Hour" />
                 </div>
                 <div class="col-lg-3">
                     <label>Current Weight (kg)</label>
                     <input type="text" id="txtCurrentWeight" class="form-control" placeholder="Weight" />
                 </div>
                 <div class="col-lg-3">
                     <label>Last Weight (kg)</label>
                     <input type="text" id="txtLastWeight" class="form-control" placeholder="last weight" />
                 </div>
                 <div class="col-lg-3">
                     <label>Dialysis Starting Time<span class="required">*</span></label>
                     <input type="time" id="txtStartTime" class="form-control" value="04:00" />
                 </div>
             </div>

             <div class="row">
                 <div class="col-lg-3">
                     <label>Finish Time</label>
                     <input type="time" id="txtFinishTime" class="form-control" value="04:00" />
                 </div>
                 <div class="col-lg-3">
                     <label>Diff. in Weight (kg)</label>
                     <input type="text" id="txtWeightDiff" class="form-control" placeholder="Weight" />
                 </div>
                 <div class="col-lg-3">
                     <label>UF: ml</label>
                     <input type="text" id="txtUF" class="form-control" placeholder="UF" />
                 </div>
                 <div class="col-lg-3">
                     <label>UF Rate: ml/hr</label>
                     <input type="text" id="txtUFRate" class="form-control" placeholder="UF rate" />
                 </div>
             </div>

             <div class="row">
                 <div class="col-lg-3">
                     <label>Total Duration</label>
                     <input type="text" id="txtTotalDuration" class="form-control" placeholder="Please enter duration" />
                 </div>
                 <div class="col-lg-3">
                     <label>Dialysis Type</label>
                     <select id="ddlDialysisType" class="form-control">
                         <option value="">Select</option>
                     </select>
                 </div>
             </div>

             <div class="row">
                 <div class="col-lg-12">
                     <label>Special Instruction</label>
                     <textarea id="txtSpecialInstruction" class="form-control" placeholder="Please enter instruction"></textarea>
                 </div>
             </div>

            <div class="row mb-3">
    <div class="col-lg-3">
        <label>Complaints</label>
        <input type="text" id="txtComplaints" class="form-control" placeholder="Please enter complaints">
    </div>
    <div class="col-lg-3">
        <label>Conscious Level</label>
        <input type="text" id="txtConsciousLevel" class="form-control" placeholder="Please enter conscious level">
    </div>
    <div class="col-lg-3">
        <label>Edema</label>
        <input type="text" id="txtEdema" class="form-control" placeholder="Please enter edema">
    </div>
    <div class="col-lg-3">
        <label>Card Rhythm</label>
        <input type="text" id="txtCardRhythm" class="form-control" placeholder="Please enter card rhythm">
    </div>
</div>

<div class="row">
    <div class="col-lg-3">
        <label>Lungs</label>
        <input type="text" id="txtLungs" class="form-control" placeholder="Please enter lungs">
    </div>
    <div class="col-lg-3">
        <label>Other</label>
        <input type="text" id="txtOther" class="form-control" placeholder="Please enter other">
    </div>
    <div class="col-lg-3">
        <label>Remarks</label>
        <input type="text" id="txtRemarks" class="form-control" placeholder="Please enter remarks">
    </div>
</div>

             

             <div class="action-buttons">
                 <button type="button" class="btn btn-primary" id="btnSaveStep1">Save & Next</button>
             </div>
         </div>

         <!-- Step 2: During Dialysis -->
         <div class="form-section" id="section2">
             <div class="row">
                 <div class="col-lg-2">
                     <label>Vital Time</label>
                     <input type="time" id="txtVitalTime" class="form-control" value="04:00" />
                 </div>
                 <div class="col-lg-2">
                     <label>Temperature (F)</label>
                     <input type="text" id="txtTemperature" class="form-control" placeholder="95.107" />
                 </div>
                 <div class="col-lg-2">
                     <label>BP-Sys (mm/hg)</label>
                     <input type="text" id="txtBPSys" class="form-control" placeholder="50.300" />
                 </div>
                 <div class="col-lg-2">
                     <label>BP-Dias (mm/hg)</label>
                     <input type="text" id="txtBPDias" class="form-control" placeholder="0.150" />
                 </div>
                 <div class="col-lg-2">
                     <label>Pulse</label>
                     <input type="text" id="txtPulse" class="form-control" placeholder="40.140" />
                 </div>
                 <div class="col-lg-2">
                     <label>Blood Flow</label>
                     <input type="text" id="txtBloodFlow" class="form-control" placeholder="Blood Flow" />
                 </div>
             </div>

             <div class="row">
                 <div class="col-lg-12">
                     <label>Vital Signs Records</label>
                     <div class="table-responsive">
                         <table id="tblVitalSigns">
                             <thead>
                                 <tr>
                                     <th>Time</th>
                                     <th>Temperature (F)</th>
                                     <th>BP-Sys</th>
                                     <th>BP-Dias</th>
                                     <th>Pulse</th>
                                     <th>Blood Flow</th>
                                     <th>Actions</th>
                                 </tr>
                             </thead>
                             <tbody id="vitalSignsBody">
                             </tbody>
                         </table>
                     </div>
                     <button type="button" class="btn btn-secondary" id="btnAddVital" style="margin-top: 10px;">Add Vital Sign</button>
                 </div>
             </div>

             <div class="action-buttons">
                 <button type="button" class="btn btn-secondary" id="btnBackToStep1">Back</button>
                 <button type="button" class="btn btn-primary" id="btnSaveStep2">Save & Next</button>
             </div>
         </div>

         <!-- Step 3: Post Dialysis -->
         <div class="form-section" id="section3">
             <div class="row">
                 <div class="col-lg-3">
                     <label>Post Dialysis Weight (kg)</label>
                     <input type="text" id="txtPostWeight" class="form-control" placeholder="Weight" />
                 </div>
                 <div class="col-lg-3">
                     <label>Total UF Removed (ml)</label>
                     <input type="text" id="txtTotalUF" class="form-control" placeholder="UF" />
                 </div>
                 <div class="col-lg-3">
                     <label>Blood Flow Rate</label>
                     <input type="text" id="txtPostBloodFlow" class="form-control" placeholder="Blood Flow Rate" />
                 </div>
                 <div class="col-lg-3">
                     <label>Dialysate Flow Rate</label>
                     <input type="text" id="txtDialysateFlow" class="form-control" placeholder="Dialysate Flow" />
                 </div>
             </div>

             <div class="row">
                 <div class="col-lg-4">
                     <label>Post BP-Sys (mm/hg)</label>
                     <input type="text" id="txtPostBPSys" class="form-control" placeholder="BP Systolic" />
                 </div>
                 <div class="col-lg-4">
                     <label>Post BP-Dias (mm/hg)</label>
                     <input type="text" id="txtPostBPDias" class="form-control" placeholder="BP Diastolic" />
                 </div>
                 <div class="col-lg-4">
                     <label>Post Pulse</label>
                     <input type="text" id="txtPostPulse" class="form-control" placeholder="Pulse" />
                 </div>
             </div>

             <div class="row">
                 <div class="col-lg-6">
                     <label>Complications During Dialysis</label>
                     <textarea id="txtComplications" class="form-control" placeholder="Please enter complications"></textarea>
                 </div>
                 <div class="col-lg-6">
                     <label>Interventions/Actions Taken</label>
                     <textarea id="txtInterventions" class="form-control" placeholder="Please enter interventions"></textarea>
                 </div>
             </div>

             <div class="row">
                 <div class="col-lg-12">
                     <label>Post Dialysis Remarks</label>
                     <textarea id="txtPostRemarks" class="form-control" placeholder="Please enter remarks"></textarea>
                 </div>
             </div>

             <div class="action-buttons">
                 <button type="button" class="btn btn-secondary" id="btnBackToStep2">Back</button>
                 <button type="button" class="btn btn-success" id="btnSaveStep3">Save</button>
             </div>
         </div>
     </div>

     <!-- Patient Search Modal -->
     <div class="modal" id="patientModal">
         <div class="modal-dialog">
             <div class="modal-content">
                 <div class="modal-header">
                     <h5 class="modal-title">Search Patients</h5>
                     <button type="button" class="close" id="closePatientModal">&times;</button>
                 </div>
                 <div class="modal-body">
                     <div class="search-container">
                         <div class="search-input-group">
                             <input type="text" id="txtPatientSearch" class="form-control" placeholder="Enter patient name or MR No." />
                             <button type="button" class="btn btn-primary" id="btnSearchPatient">Search</button>
                         </div>
                     </div>
                     <div class="table-responsive">
                         <table id="tblPatients">
                             <thead>
                                 <tr>
                                     <th style="display:none;">Patient ID</th>
                                     <th>MR No</th>
                                     <th>Patient Name</th>
                                     <th>Father Name</th>
                                     <th>CNIC</th>
                                     <th>Contact No</th>
                                     <th>Action</th>
                                 </tr>
                             </thead>
                             <tbody id="patientTableBody">
                             </tbody>
                         </table>
                     </div>
                 </div>
                 <div class="modal-footer">
                     <button type="button" class="btn btn-secondary" id="btnCloseModal">Close</button>
                 </div>
             </div>
         </div>
     </div>





</asp:Content>
