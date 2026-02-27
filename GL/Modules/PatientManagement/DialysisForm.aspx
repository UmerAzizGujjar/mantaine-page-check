<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DialysisForm.aspx.cs" Inherits="PMS.Modules.PatientManagement.DialysisForm" %>

 
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script>
        var currentDialysisId = '';
        var isEditMode = false;

        $(document).ready(function () {
            initializeForm();
            loadDropdowns();
            checkEditMode();
        });

        function initializeSelect2() {
            // Initialize Select2 on all select elements
            $('select').select2();
        }

        function checkEditMode() {
            var urlParams = new URLSearchParams(window.location.search);
            var id = urlParams.get('ID');
            
            if (id) {
                isEditMode = true;
                currentDialysisId = id;
                $('#hdfDialysisId').val(id);
                $('#txtDialysisNo').val(id).prop('disabled', true);
                updateButtonTexts();
                // Load dialysis data after dropdowns are loaded
                setTimeout(function() {
                    loadDialysisData(id);
                }, 1000);
            } else {
                generateNewDialysisId();
            }
        }

        function generateNewDialysisId() {
            $.ajax({
                type: "POST",
                url: "DialysisForm.aspx/GenerateDialysisId",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    currentDialysisId = response.d;
                    $('#hdfDialysisId').val(currentDialysisId);
                    $('#txtDialysisNo').val(currentDialysisId).prop('disabled', true);
                }
            });
        }

        function loadDialysisData(dialysisId) {
            $.ajax({
                type: "POST",
                url: "DialysisForm.aspx/GetDialysisData",
                data: JSON.stringify({ dialysisId: dialysisId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    
                    if (data.PreDialysis && data.PreDialysis.length > 0) {
                        populatePreDialysisData(data.PreDialysis[0]);
                    }
                    
                    if (data.DuringDialysis && data.DuringDialysis.length > 0) {
                        populateDuringDialysisData(data.DuringDialysis);
                    }
                    
                    if (data.PostDialysis && data.PostDialysis.length > 0) {
                        populatePostDialysisData(data.PostDialysis[0]);
                    }
                },
                error: function (error) {
                    console.error("Error loading dialysis data", error);
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Error loading dialysis data',
                        timer: 2000,
                        showConfirmButton: false
                    });
                }
            });
        }

        function populatePreDialysisData(data) {
            $('#hdfPatientId').val(data.Patient_ID);
            
            // Load patient info
            loadPatientInfo(data.Patient_ID);
            
            // Populate dropdowns - set value directly since options already loaded
            if (data.Vascular_Access) {
                $('#ddlVascularAccess').val(data.Vascular_Access).trigger('change');
            }
            
            if (data.Machine_No) {
                $('#ddlMachineNo').val(data.Machine_No).trigger('change');
            }
            
            if (data.Dialyzer) {
                $('#ddlDialyzer').val(data.Dialyzer).trigger('change');
            }
            
            if (data.Advised_By_ID) {
                $('#ddlAdvisedBy').val(data.Advised_By_ID).trigger('change');
            }
            
            if (data.Priming_By_ID) {
                $('#ddlPrimingBy').val(data.Priming_By_ID).trigger('change');
            }
            
            if (data.Heparin) {
                $('#ddlHeparin').val(data.Heparin).trigger('change');
            }
            
            if (data.Dialysis_Type) {
                $('#ddlDialysisType').val(data.Dialysis_Type).trigger('change');
            }
            
            // Populate text fields
            $('#txtDialysisNo').val(data.Dialysis_No);
            $('#txtPrimingSol').val(data.Priming_Solution);
            $('#txtHeparinInfusion').val(data.Heparin_Infusion_Per_Hour);
            $('#txtCurrentWeight').val(data.Current_Weight);
            $('#txtLastWeight').val(data.Last_Weight);
            $('#txtStartTime').val(data.Start_Time);
            $('#txtFinishTime').val(data.Finish_Time);
            $('#txtWeightDiff').val(data.Weight_Difference);
            $('#txtUF').val(data.UF_ML);
            $('#txtUFRate').val(data.UF_Rate);
            $('#txtTotalDuration').val(data.Total_Duration);
            $('#txtSpecialInstruction').val(data.Special_Instruction);
            $('#txtComplaints').val(data.Complaints);
            $('#txtConsciousLevel').val(data.Conscious_Level);
            $('#txtEdema').val(data.Edema);
            $('#txtCardRhythm').val(data.Card_Rhythm);
            $('#txtLungs').val(data.Lungs);
            $('#txtOther').val(data.Other);
            $('#txtRemarks').val(data.Remarks);
            
            $('#hdfStep1Saved').val('true');
            $('#step1Nav').addClass('completed');
            $('#step2Nav').removeClass('disabled');
            updateStepSummary();
        }

        function populateDuringDialysisData(dataArray) {
            $('#vitalSignsBody').empty();
            
            $.each(dataArray, function (i, vital) {
                var row = '<tr>' +
                    '<td><input type="time" class="form-control vital-time" value="' + (vital.Vital_Time || '') + '" /></td>' +
                    '<td><input type="number" step="0.1" class="form-control vital-temp" placeholder="°F" value="' + (vital.Temperature || '') + '" /></td>' +
                    '<td><input type="number" step="1" class="form-control vital-bp-sys" placeholder="mmHg" value="' + (vital.BP_Systolic || '') + '" /></td>' +
                    '<td><input type="number" step="1" class="form-control vital-bp-dias" placeholder="mmHg" value="' + (vital.BP_Diastolic || '') + '" /></td>' +
                    '<td><input type="number" step="1" class="form-control vital-pulse" placeholder="bpm" value="' + (vital.Pulse || '') + '" /></td>' +
                    '<td><input type="number" step="1" class="form-control vital-dialysis-flow" placeholder="ml/min" value="' + (vital.Dialysis_Flow_Rate || '') + '" /></td>' +
                    '<td><input type="number" step="1" class="form-control vital-venous-pressure" placeholder="mmHg" value="' + (vital.Venous_Pressure || '') + '" /></td>' +
                    '<td><input type="number" step="1" class="form-control vital-blood-flow" placeholder="ml/min" value="' + (vital.Blood_Flow || '') + '" /></td>' +
                    '<td><button type="button" class="btn btn-sm btn-danger" onclick="deleteVitalRow(this)"><i class="fa fa-trash"></i></button></td>' +
                    '</tr>';
                
                $('#vitalSignsBody').append(row);
            });
            
            $('#hdfStep2Saved').val('true');
            $('#step2Nav').addClass('completed');
            $('#step3Nav').removeClass('disabled');
            updateStepSummary();
        }

        function populatePostDialysisData(data) {
            if (data.Staff_ID) {
                $('#ddlPostStaff').val(data.Staff_ID).trigger('change');
            }
            
            $('#txtPostStartTime').val(data.Start_Time);
            $('#txtPostEndTime').val(data.End_Time);
            $('#txtPostDuration').val(data.Duration);
            $('#txtPostWeight').val(data.Weight);
            $('#txtPostTemp').val(data.Temperature);
            $('#txtPostBPSys').val(data.BP_Systolic);
            $('#txtPostBPDias').val(data.BP_Diastolic);
            $('#txtPostPulse').val(data.Pulse);
            $('#txtPostComments').val(data.Comments);
            
            $('#step3Nav').addClass('completed');
            updateStepSummary();
        }

        function updateStepSummary() {
            var step1Saved = $('#hdfStep1Saved').val() === 'true';
            var step2Saved = $('#hdfStep2Saved').val() === 'true';
            var step3Saved = $('#step3Nav').hasClass('completed');
            
            $('#summaryPreStatus').html(step1Saved ? 
                '<i class="fa fa-check-circle text-success"></i> Completed' : 
                '<i class="fa fa-clock text-warning"></i> Pending');
                
            $('#summaryDuringStatus').html(step2Saved ? 
                '<i class="fa fa-check-circle text-success"></i> Completed' : 
                '<i class="fa fa-clock text-warning"></i> Pending');
                
            $('#summaryPostStatus').html(step3Saved ? 
                '<i class="fa fa-check-circle text-success"></i> Completed' : 
                '<i class="fa fa-clock text-warning"></i> Pending');
        }

        function loadPatientInfo(patientId) {
            $.ajax({
                type: "POST",
                url: "DialysisForm.aspx/SearchPatients",
                data: JSON.stringify({ searchText: patientId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    if (data.length > 0) {
                        var patient = data[0];
                        $('#infoMrNo').text(patient.MRNo);
                        $('#infoPatientName').text(patient.PatientName);
                        $('#infoAge').text(patient.Age);
                        $('#infoGender').text(patient.Gender);
                        $('#infoContact').text(patient.ContactNo);
                        $('#patientInfoBar').show();
                        updateStepSummary();
                    }
                }
            });
        }

        function updateButtonTexts() {
            if (isEditMode) {
                $('#btnSaveStep1').html('<i class="fa fa-save"></i> Update & Next');
                $('#btnSaveStep2').html('<i class="fa fa-save"></i> Update & Next');
                $('#btnSaveStep3').html('<i class="fa fa-check"></i> Update');
            }
        }

        function initializeForm() {
            $('#btnAddPatient').click(function () {
                $('#PatientsSearchModel').modal('show');
                loadPatients();
            });

            $('#txtPatientSearch').on('keyup', function () {
                var searchText = $(this).val();
                if (searchText.length >= 2) {
                    searchPatients(searchText);
                } else if (searchText.length === 0) {
                    loadPatients();
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

            $('#btnAddVitalRow').click(function () {
                addVitalRow();
            });

            // Calculate duration when start/end time changes
            $('#txtPostStartTime, #txtPostEndTime').on('change', function () {
                calculateDuration();
            });
        }

        function loadDropdowns() {
            var dropdownsLoaded = 0;
            var totalDropdowns = 8;
            
            function checkAllLoaded() {
                dropdownsLoaded++;
                if (dropdownsLoaded === totalDropdowns) {
                    initializeSelect2();
                }
            }
            
            loadVascularAccess(checkAllLoaded);
            loadMachines(checkAllLoaded);
            loadDialyzers(checkAllLoaded);
            loadDoctors(checkAllLoaded);
            loadNurses(checkAllLoaded);
            loadHeparin(checkAllLoaded);
            loadDialysisTypes(checkAllLoaded);
            loadStaff(checkAllLoaded);
        }

        function loadVascularAccess(callback) {
            $.ajax({
                type: "POST",
                url: "DialysisForm.aspx/GetVascularAccess",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    var options = '<option value="">Select</option>';
                    $.each(data, function (key, value) {
                        options += '<option value="' + value.Value + '">' + value.Text + '</option>';
                    });
                    $('#ddlVascularAccess').html(options);
                    if (callback) callback();
                }
            });
        }

        function loadMachines(callback) {
            $.ajax({
                type: "POST",
                url: "DialysisForm.aspx/GetMachines",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    var options = '<option value="">Select</option>';
                    $.each(data, function (key, value) {
                        options += '<option value="' + value.Value + '">' + value.Text + '</option>';
                    });
                    $('#ddlMachineNo').html(options);
                    if (callback) callback();
                }
            });
        }

        function loadDialyzers(callback) {
            $.ajax({
                type: "POST",
                url: "DialysisForm.aspx/GetDialyzers",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    var options = '<option value="">Select</option>';
                    $.each(data, function (key, value) {
                        options += '<option value="' + value.Value + '">' + value.Text + '</option>';
                    });
                    $('#ddlDialyzer').html(options);
                    if (callback) callback();
                }
            });
        }

        function loadDoctors(callback) {
            $.ajax({
                type: "POST",
                url: "DialysisForm.aspx/GetDoctors",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    var options = '<option value="">Nothing selected</option>';
                    $.each(data, function (key, value) {
                        options += '<option value="' + value.Emp_ID + '">' + value.Emp_Name + '</option>';
                    });
                    $('#ddlAdvisedBy').html(options);
                    $('#ddlPrimingBy').html(options);
                    if (callback) callback();
                }
            });
        }

        function loadNurses(callback) {
            $.ajax({
                type: "POST",
                url: "DialysisForm.aspx/GetNurses",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    if (callback) callback();
                }
            });
        }

        function loadHeparin(callback) {
            $.ajax({
                type: "POST",
                url: "DialysisForm.aspx/GetHeparin",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    var options = '<option value="">Nothing selected</option>';
                    $.each(data, function (key, value) {
                        options += '<option value="' + value.Value + '">' + value.Text + '</option>';
                    });
                    $('#ddlHeparin').html(options);
                    if (callback) callback();
                }
            });
        }

        function loadDialysisTypes(callback) {
            $.ajax({
                type: "POST",
                url: "DialysisForm.aspx/GetDialysisTypes",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    var options = '<option value="">Select</option>';
                    $.each(data, function (key, value) {
                        options += '<option value="' + value.Value + '">' + value.Text + '</option>';
                    });
                    $('#ddlDialysisType').html(options);
                    if (callback) callback();
                }
            });
        }

        function loadStaff(callback) {
            $.ajax({
                type: "POST",
                url: "DialysisForm.aspx/GetStaff",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    var options = '<option value="">Select Staff</option>';
                    $.each(data, function (key, value) {
                        options += '<option value="' + value.Emp_ID + '">' + value.Emp_Name + '</option>';
                    });
                    $('#ddlPostStaff').html(options);
                    if (callback) callback();
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
                },
                error: function (error) {
                    console.error("Error loading patients", error);
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
                },
                error: function (error) {
                    console.error("Error searching patients", error);
                }
            });
        }

        function bindPatientTable(data) {
            var tbody = $('#iPatientsBody');
            tbody.empty();
            
            if (data.length === 0) {
                tbody.append('<tr><td colspan="7" style="text-align:center;">No patients found</td></tr>');
                return;
            }
            
            $.each(data, function (i, item) {
                var row = '<tr>' +
                    '<td style="display:none;">' + item.PatientId + '</td>' +
                    '<td>' + item.MRNo + '</td>' +
                    '<td>' + item.PatientName + '</td>' +
                    '<td>' + item.FatherName + '</td>' +
                    '<td>' + item.CNIC + '</td>' +
                    '<td>' + item.ContactNo + '</td>' +
                    '<td><button type="button" class="btn btn-sm btn-primry" onclick="selectPatient(' + item.PatientId + ',\'' +
                    item.MRNo + '\',\'' + item.PatientName + '\',\'' + item.Age + '\',\'' +
                    item.Gender + '\',\'' + item.ContactNo + '\')"><i class="fa fa-plus"></i></button></td>' +
                    '</tr>';
                tbody.append(row);
            });
        }

        function selectPatient(id, mrNo, name, age, gender, contact) {
            clearFormData();
            
            $('#hdfPatientId').val(id);
            $('#infoMrNo').text(mrNo);
            $('#infoPatientName').text(name);
            $('#infoAge').text(age);
            $('#infoGender').text(gender);
            $('#infoContact').text(contact);
            
            $('#patientInfoBar').show();
            $('#PatientsSearchModel').modal('hide');
            
            $('#hdfStep1Saved').val('false');
            $('#hdfStep2Saved').val('false');
            
            navigateToStep(1);
        }

        function newForm() {
            window.location.href = 'DialysisForm.aspx';
        }
         function viewList() {
     window.location.href = 'DialysisView.aspx';
 }

        function clearFormData() {
            // Clear Step 1
            $('#ddlVascularAccess, #ddlMachineNo, #ddlDialyzer, #ddlAdvisedBy, #ddlPrimingBy, #ddlHeparin, #ddlDialysisType').val('');
            $('#txtPrimingSol, #txtHeparinInfusion, #txtCurrentWeight, #txtLastWeight, #txtStartTime, #txtFinishTime, #txtWeightDiff, #txtUF, #txtUFRate, #txtTotalDuration, #txtSpecialInstruction, #txtComplaints, #txtConsciousLevel, #txtEdema, #txtCardRhythm, #txtLungs, #txtOther, #txtRemarks').val('');
            
            // Clear Step 2
            $('#vitalSignsBody').empty();
            
            // Clear Step 3
            $('#ddlPostStaff').val('');
            $('#txtPostStartTime, #txtPostEndTime, #txtPostDuration, #txtPostWeight, #txtPostTemp, #txtPostBPSys, #txtPostBPDias, #txtPostPulse, #txtPostComments').val('');
            
            // Generate new Dialysis ID for new patient
            generateNewDialysisId();
            
            // Reset navigation
            $('.step-item').removeClass('active completed').addClass('disabled');
            $('#step1Nav').removeClass('disabled').addClass('active');
        }

        function navigateToStep(stepNumber) {
            var step1Saved = $('#hdfStep1Saved').val() === 'true';
            var step2Saved = $('#hdfStep2Saved').val() === 'true';

            if (stepNumber === 2 && !step1Saved) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Warning!',
                    text: 'Please save Step 1 first',
                    timer: 2000,
                    showConfirmButton: false
                });
                return;
            }

            if (stepNumber === 3 && !step2Saved) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Warning!',
                    text: 'Please save Step 2 first',
                    timer: 2000,
                    showConfirmButton: false
                });
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
                Swal.fire({
                    icon: 'warning',
                    title: 'Warning!',
                    text: 'Please select a patient first',
                    timer: 2000,
                    showConfirmButton: false
                });
                return;
            }

            var data = {
                DialysisId: currentDialysisId,
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
                data: JSON.stringify({ data: JSON.stringify(data) }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d && response.d.indexOf('error') === -1) {
                        currentDialysisId = response.d;
                        $('#hdfDialysisId').val(currentDialysisId);
                        $('#hdfStep1Saved').val('true');
                        $('#step1Nav').addClass('completed');
                        $('#step2Nav').removeClass('disabled');
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: isEditMode ? 'Step 1 updated successfully' : 'Step 1 saved successfully',
                            timer: 2000,
                            showConfirmButton: false
                        });
                        navigateToStep(2);
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Error saving data: ' + response.d,
                            timer: 2000,
                            showConfirmButton: false
                        });
                    }
                }
            });
        }

        function addVitalRow() {
            var row = '<tr>' +
                '<td><input type="time" class="form-control vital-time" /></td>' +
                '<td><input type="number" step="0.1" class="form-control vital-temp" placeholder="°F" /></td>' +
                '<td><input type="number" step="1" class="form-control vital-bp-sys" placeholder="mmHg" /></td>' +
                '<td><input type="number" step="1" class="form-control vital-bp-dias" placeholder="mmHg" /></td>' +
                '<td><input type="number" step="1" class="form-control vital-pulse" placeholder="bpm" /></td>' +
                '<td><input type="number" step="1" class="form-control vital-dialysis-flow" placeholder="ml/min" /></td>' +
                '<td><input type="number" step="1" class="form-control vital-venous-pressure" placeholder="mmHg" /></td>' +
                '<td><input type="number" step="1" class="form-control vital-blood-flow" placeholder="ml/min" /></td>' +
                '<td><button type="button" class="btn btn-sm btn-danger" onclick="deleteVitalRow(this)"><i class="fa fa-trash"></i></button></td>' +
                '</tr>';
            
            $('#vitalSignsBody').append(row);
        }

        function deleteVitalRow(btn) {
            $(btn).closest('tr').remove();
        }

        function getVitalSignsData() {
            var vitals = [];
            $('#vitalSignsBody tr').each(function () {
                var vital = {
                    Time: $(this).find('.vital-time').val(),
                    Temperature: $(this).find('.vital-temp').val(),
                    BPSys: $(this).find('.vital-bp-sys').val(),
                    BPDias: $(this).find('.vital-bp-dias').val(),
                    Pulse: $(this).find('.vital-pulse').val(),
                    DialysisFlowRate: $(this).find('.vital-dialysis-flow').val(),
                    VenousPressure: $(this).find('.vital-venous-pressure').val(),
                    BloodFlow: $(this).find('.vital-blood-flow').val()
                };
                vitals.push(vital);
            });
            return vitals;
        }

        function saveStep2() {
            var vitalsData = getVitalSignsData();
            
            if (vitalsData.length === 0) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Warning!',
                    text: 'Please add at least one vital sign record',
                    timer: 2000,
                    showConfirmButton: false
                });
                return;
            }

            $.ajax({
                type: "POST",
                url: "DialysisForm.aspx/SaveDuringDialysis",
                data: JSON.stringify({ 
                    DialysisId: currentDialysisId,
                    PatientId: $('#hdfPatientId').val(),
                    VitalSigns: JSON.stringify(vitalsData)
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d === 'success') {
                        $('#hdfStep2Saved').val('true');
                        $('#step2Nav').addClass('completed');
                        $('#step3Nav').removeClass('disabled');
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: isEditMode ? 'Step 2 updated successfully' : 'Step 2 saved successfully',
                            timer: 2000,
                            showConfirmButton: false
                        });
                        navigateToStep(3);
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Error saving data: ' + response.d,
                            timer: 2000,
                            showConfirmButton: false
                        });
                    }
                }
            });
        }

        function calculateDuration() {
            var startTime = $('#txtPostStartTime').val();
            var endTime = $('#txtPostEndTime').val();
            
            if (startTime && endTime) {
                var start = new Date('1970-01-01T' + startTime);
                var end = new Date('1970-01-01T' + endTime);
                
                var diffMs = end - start;
                if (diffMs < 0) {
                    diffMs += 24 * 60 * 60 * 1000; // Add 24 hours if end is next day
                }
                
                var hours = Math.floor(diffMs / (1000 * 60 * 60));
                var minutes = Math.floor((diffMs % (1000 * 60 * 60)) / (1000 * 60));
                
                $('#txtPostDuration').val(hours + ' hour(s) ' + minutes + ' minute(s)');
            }
        }

        function saveStep3() {
            var data = {
                DialysisId: currentDialysisId,
                PatientId: $('#hdfPatientId').val(),
                StartTime: $('#txtPostStartTime').val(),
                EndTime: $('#txtPostEndTime').val(),
                Duration: $('#txtPostDuration').val(),
                StaffId: $('#ddlPostStaff').val(),
                Weight: $('#txtPostWeight').val(),
                Temperature: $('#txtPostTemp').val(),
                BPSys: $('#txtPostBPSys').val(),
                BPDias: $('#txtPostBPDias').val(),
                Pulse: $('#txtPostPulse').val(),
                Comments: $('#txtPostComments').val()
            };

            $.ajax({
                type: "POST",
                url: "DialysisForm.aspx/SavePostDialysis",
                data: JSON.stringify({ data: JSON.stringify(data) }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d === 'success') {
                        $('#step3Nav').addClass('completed');
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: isEditMode ? 'Dialysis form updated successfully' : 'Dialysis form completed successfully',
                            timer: 2000,
                            showConfirmButton: false
                        });
                        
                        // Optionally redirect or reset form
                        // window.location.href = 'DialysisList.aspx';
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Error saving data: ' + response.d,
                            timer: 2000,
                            showConfirmButton: false
                        });
                    }
                }
            });
        }
    </script>
    <style>
    /* Step Navigation */
  
    
    .dialysis-top-buttons {
        display: flex;
        gap: 10px;
        justify-content: flex-start;
        margin-bottom: 20px;
    }
    
    .step-navigation {
        display: flex;
        justify-content: center;
        align-items: center;
        margin-bottom: 15px;
        padding: 15px 0;
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
        width: 50px;
        height: 50px;
        border-radius: 50%;
        background-color: #e0e0e0;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 22px;
        margin-bottom: 8px;
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
        font-size: 11px;
        font-weight: 500;
        color: #666;
        text-align: center;
    }

    .step-item.active .step-label {
        color: #4A90E2;
        font-weight: 600;
    }

    .step-arrow {
        font-size: 20px;
        color: #ccc;
        margin: 0 15px;
        margin-bottom: 25px;
    }

    /* Patient Card - Compact Version */
    .cardd {
        background-color: #fff;
        border: 1px solid #e0e0e0;
        border-radius: 8px;
        margin-bottom: 20px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    }

    .card-bodyy {
        padding: 15px;
    }

    .image-container {
        display: flex;
        justify-content: center;
        align-items: flex-start;
        margin-bottom: 5px;
    }

    .patient-image {
        max-width: 80px;
        height: auto;
        border-radius: 6px;
    }

    .labels {
        font-weight: 600;
        color: #333;
        font-size: 12px;
        margin-bottom: 2px;
    }

    .md {
        color: #666;
        font-size: 12px;
    }

    .info-row {
        margin-bottom: 8px;
        display: flex;
        gap: 5px;
    }

    /* Step Summary Card */
    .step-summary-card {
        background-color: #f8f9fa;
        border: 1px solid #e0e0e0;
        border-radius: 8px;
        padding: 15px;
    }

    .step-summary-card h6 {
        font-size: 13px;
        font-weight: 600;
        margin-bottom: 15px;
        color: #333;
    }

    .step-summary-item {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 8px 0;
        border-bottom: 1px solid #dee2e6;
    }

    .step-summary-item:last-child {
        border-bottom: none;
    }

    .step-summary-label {
        font-size: 12px;
        color: #666;
        font-weight: 500;
    }

    .step-summary-status {
        font-size: 11px;
    }

    .text-success {
        color: #28a745;
    }

    .text-warning {
        color: #ffc107;
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

    .dialysis-form-row {
        display: flex;
        flex-wrap: wrap;
        margin: 0 -10px 20px -10px;
    }

    .dialysis-field {
        padding: 0 10px;
        margin-bottom: 15px;
    }

    .dialysis-field-20 { width: 20%; }
    .dialysis-field-25 { width: 25%; }
    .dialysis-field-33 { width: 33.33%; }
    .dialysis-field-50 { width: 50%; }
    .dialysis-field-75 { width: 75%; }
    .dialysis-field-100 { width: 100%; }

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

    #ddlVascularAccess, #txtDialysisNo, #ddlMachineNo, #ddlDialyzer, #ddlAdvisedBy,
    #ddlPrimingBy, #txtPrimingSol, #ddlHeparin, #txtHeparinInfusion, #txtCurrentWeight,
    #txtLastWeight, #txtStartTime, #txtFinishTime, #txtWeightDiff, #txtUF,
    #txtUFRate, #txtTotalDuration, #ddlDialysisType, #txtComplaints, #txtConsciousLevel,
    #txtEdema, #txtCardRhythm, #txtLungs, #txtOther, #txtRemarks, #txtSpecialInstruction,
    #txtPostStartTime, #txtPostEndTime, #txtPostDuration, #ddlPostStaff, #txtPostWeight,
    #txtPostTemp, #txtPostBPSys, #txtPostBPDias, #txtPostPulse, #txtPostComments {
        width: 100%;
        padding: 8px 12px;
        border: 1px solid #ddd;
        border-radius: 4px;
        font-size: 14px;
        transition: border-color 0.3s ease;
    }

    #ddlVascularAccess:focus, #txtDialysisNo:focus, #ddlMachineNo:focus, #ddlDialyzer:focus,
    #ddlAdvisedBy:focus, #ddlPrimingBy:focus, #txtPrimingSol:focus, #ddlHeparin:focus,
    #txtHeparinInfusion:focus, #txtCurrentWeight:focus, #txtLastWeight:focus, #txtStartTime:focus,
    #txtFinishTime:focus, #txtWeightDiff:focus, #txtUF:focus, #txtUFRate:focus,
    #txtTotalDuration:focus, #ddlDialysisType:focus, #txtComplaints:focus, #txtConsciousLevel:focus,
    #txtEdema:focus, #txtCardRhythm:focus, #txtLungs:focus, #txtOther:focus,
    #txtRemarks:focus, #txtSpecialInstruction:focus, #txtPostStartTime:focus,
    #txtPostEndTime:focus, #txtPostDuration:focus, #ddlPostStaff:focus,
    #txtPostWeight:focus, #txtPostTemp:focus, #txtPostBPSys:focus,
    #txtPostBPDias:focus, #txtPostPulse:focus, #txtPostComments:focus {
        outline: none;
        border-color: #4A90E2;
    }

    #txtDialysisNo, #txtPostDuration {
        background-color: #f5f5f5;
        cursor: not-allowed;
    }

    #txtSpecialInstruction, #txtPostComments {
        resize: vertical;
        min-height: 80px;
    }

    .dialysis-action-buttons {
        display: flex;
        gap: 15px;
        justify-content: flex-start;
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

    .btn-primry {
        background-color: #4A90E2;
        color: white;
    }

    .btn-primry:hover {
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

    .btn-danger {
        background-color: #dc3545;
        color: white;
    }

    .btn-danger:hover {
        background-color: #c82333;
    }

    .btn-primry i {
        margin-right: 5px;
    }

    /* Patient Search Modal - Vertical Scroll & Round Plus Button */
    #PatientsSearchModel .modal-body {
        max-height: 500px;
        overflow-y: auto;
    }

    #tblPatientsResult {
        width: 100%;
        border-collapse: collapse;
    }

    #tblPatientsResult thead {
        background-color: #f8f9fa;
        position: sticky;
        top: 0;
        z-index: 10;
    }

    #tblPatientsResult th {
        padding: 12px;
        text-align: left;
        font-size: 13px;
        font-weight: 600;
        color: #333;
        border-bottom: 2px solid #dee2e6;
    }

    #tblPatientsResult td {
        padding: 8px 12px;
        font-size: 13px;
        color: #666;
        border-bottom: 1px solid #dee2e6;
        vertical-align: middle;
    }

    #tblPatientsResult tbody tr:hover {
        background-color: #f8f9fa;
    }

    /* Round Small Plus Button */
    #tblPatientsResult .btn-primry {
        width: 30px;
        height: 30px;
        padding: 0;
        border-radius: 50%;
        display: inline-flex;
        align-items: center;
        justify-content: center;
    }

    #tblPatientsResult .btn-primry i {
        margin: 0;
        font-size: 14px;
    }

    /* Vital Signs Table - White Headers */
    .table-responsive {
        overflow-x: auto;
    }

    #tblVitalSigns {
        width: 100%;
        border-collapse: collapse;
        margin-top: 15px;
    }

    #tblVitalSigns thead {
        background-color: white;
    }

    #tblVitalSigns th {
        padding: 12px;
        text-align: left;
        font-size: 13px;
        font-weight: 600;
        color: #333;
        border-bottom: 2px solid #dee2e6;
    }

    #tblVitalSigns td {
        padding: 12px;
        font-size: 13px;
        color: #666;
        border-bottom: 1px solid #dee2e6;
    }

    #tblVitalSigns tbody tr:hover {
        background-color: #f8f9fa;
    }

    #vitalSignsBody input {
        padding: 5px 8px;
        font-size: 12px;
    }

    @media (max-width: 992px) {
        .dialysis-field-20, .dialysis-field-25, .dialysis-field-33, .dialysis-field-50 {
            width: 50%;
        }
    }

    @media (max-width: 576px) {
        .dialysis-field-20, .dialysis-field-25, .dialysis-field-33, .dialysis-field-50 {
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
         <asp:HiddenField ID="hdfDialysisId" runat="server" ClientIDMode="Static" />
         <asp:HiddenField ID="hdfPatientId" runat="server" ClientIDMode="Static" />
         <asp:HiddenField ID="hdfCurrentStep" runat="server" ClientIDMode="Static" Value="1" />
         <asp:HiddenField ID="hdfStep1Saved" runat="server" ClientIDMode="Static" Value="false" />
         <asp:HiddenField ID="hdfStep2Saved" runat="server" ClientIDMode="Static" Value="false" />

         <div class="dialysis-top-buttons">
             
             <button type="button" class="btn-primry" id="btnAddPatient">
                  Add Patient
             </button>
         </div>

         <!-- Patient Card - Compact 2 Column Layout -->
         <div class="dialysis-form-row" id="patientInfoBar" style="display:none;">
             <div class="dialysis-field dialysis-field-50">
                 <div class="cardd">
                     <div class="card-bodyy">
                         <div class="dialysis-form-row">
                             <div class="dialysis-field dialysis-field-25 text-center">
                                 <div class="image-container">
                                     <img src="../../wwwroot/Tibbit_theme/images/dashboard_Icons/Patient.png" alt="Patient" class="patient-image" />
                                 </div>
                             </div>
                             <div class="dialysis-field dialysis-field-75">
                                 <div class="info-row">
                                     <span class="labels">MR No:</span>
                                     <span class="md" id="infoMrNo">-</span>
                                 </div>
                                 <div class="info-row">
                                     <span class="labels">Name:</span>
                                     <span class="md" id="infoPatientName">-</span>
                                 </div>
                                 <div class="info-row">
                                     <span class="labels">Age:</span>
                                     <span class="md" id="infoAge">-</span>
                                 </div>
                                 <div class="info-row">
                                     <span class="labels">Gender:</span>
                                     <span class="md" id="infoGender">-</span>
                                 </div>
                                 <div class="info-row">
                                     <span class="labels">Contact:</span>
                                     <span class="md" id="infoContact">-</span>
                                 </div>
                             </div>
                         </div>
                     </div>
                 </div>
             </div>

             <!-- Dialysis Progress with Step Navigation -->
             <div class="dialysis-field dialysis-field-50">
                 <div class="step-summary-card">
                     <h6><i class="fa fa-list-check"></i> Dialysis Progress</h6>
                     
                     <!-- Step Navigation -->
                     <div class="step-navigation">
                         <div class="step-item active" id="step1Nav" onclick="navigateToStep(1)">
                             <div class="step-icon"><i class="fa fa-hourglass"></i></div>
                             <div class="step-label">Pre</div>
                         </div>
                         <div class="step-arrow">→</div>
                         <div class="step-item disabled" id="step2Nav" onclick="navigateToStep(2)">
                             <div class="step-icon"><i class="fa fa-heartbeat"></i></div>
                             <div class="step-label">During</div>
                         </div>
                         <div class="step-arrow">→</div>
                         <div class="step-item disabled" id="step3Nav" onclick="navigateToStep(3)">
                             <div class="step-icon"><i class="fa fa-clipboard"></i></div>
                             <div class="step-label">Post</div>
                         </div>
                     </div>
                 
                 </div>
             </div>
         </div>

         <!-- Step 1: Pre Dialysis -->
         <div class="form-section active" id="section1">
             <div class="dialysis-form-row">
                 <div class="dialysis-field dialysis-field-20">
                     <label>Vascular Access<span class="required">*</span></label>
                     <select id="ddlVascularAccess" class="form-control">
                         <option value="">Select</option>
                     </select>
                 </div>
                 <div class="dialysis-field dialysis-field-20">
                     <label>Dialysis No.</label>
                     <input type="text" id="txtDialysisNo" class="form-control" placeholder="Dialysis Number" />
                 </div>
                 <div class="dialysis-field dialysis-field-20">
                     <label>Machine No.<span class="required">*</span></label>
                     <select id="ddlMachineNo" class="form-control">
                         <option value="">Select</option>
                     </select>
                 </div>
                 <div class="dialysis-field dialysis-field-20">
                     <label>Dialyzer</label>
                     <select id="ddlDialyzer" class="form-control">
                         <option value="">Select</option>
                     </select>
                 </div>
                 <div class="dialysis-field dialysis-field-20">
                     <label>Advised by<span class="required">*</span></label>
                     <select id="ddlAdvisedBy" class="form-control">
                         <option value="">Nothing selected</option>
                     </select>
                 </div>
             </div>

             <div class="dialysis-form-row">
                 <div class="dialysis-field dialysis-field-20">
                     <label>Priming By<span class="required">*</span></label>
                     <select id="ddlPrimingBy" class="form-control">
                         <option value="">Nothing selected</option>
                     </select>
                 </div>
                 <div class="dialysis-field dialysis-field-20">
                     <label>Priming Sol.</label>
                     <input type="text" id="txtPrimingSol" class="form-control" value="Dental Mould for pouring" />
                 </div>
                 <div class="dialysis-field dialysis-field-20">
                     <label>Heparin</label>
                     <select id="ddlHeparin" class="form-control">
                         <option value="">Nothing selected</option>
                     </select>
                 </div>
                 <div class="dialysis-field dialysis-field-20">
                     <label>Heparin Infusion / Hour</label>
                     <input type="text" id="txtHeparinInfusion" class="form-control" placeholder="Heparin Infusion / Hour" />
                 </div>
                 <div class="dialysis-field dialysis-field-20">
                     <label>Current Weight (kg)</label>
                     <input type="text" id="txtCurrentWeight" class="form-control" placeholder="Weight" />
                 </div>
             </div>

             <div class="dialysis-form-row">
                 <div class="dialysis-field dialysis-field-20">
                     <label>Last Weight (kg)</label>
                     <input type="text" id="txtLastWeight" class="form-control" placeholder="last weight" />
                 </div>
                 <div class="dialysis-field dialysis-field-20">
                     <label>Start Time<span class="required">*</span></label>
                     <input type="time" id="txtStartTime" class="form-control" value="04:00" />
                 </div>
                 <div class="dialysis-field dialysis-field-20">
                     <label>Finish Time</label>
                     <input type="time" id="txtFinishTime" class="form-control" value="04:00" />
                 </div>
                 <div class="dialysis-field dialysis-field-20">
                     <label>Diff. in Weight (kg)</label>
                     <input type="text" id="txtWeightDiff" class="form-control" placeholder="Weight" />
                 </div>
                 <div class="dialysis-field dialysis-field-20">
                     <label>UF: ml</label>
                     <input type="text" id="txtUF" class="form-control" placeholder="UF" />
                 </div>
             </div>

             <div class="dialysis-form-row">
                 <div class="dialysis-field dialysis-field-20">
                     <label>UF Rate: ml/hr</label>
                     <input type="text" id="txtUFRate" class="form-control" placeholder="UF rate" />
                 </div>
                 <div class="dialysis-field dialysis-field-20">
                     <label>Total Duration</label>
                     <input type="text" id="txtTotalDuration" class="form-control" placeholder="Please enter duration" />
                 </div>
                 <div class="dialysis-field dialysis-field-20">
                     <label>Dialysis Type</label>
                     <select id="ddlDialysisType" class="form-control">
                         <option value="">Select</option>
                     </select>
                 </div>
                 <div class="dialysis-field dialysis-field-20">
                     <label>Complaints</label>
                     <input type="text" id="txtComplaints" class="form-control" placeholder="Please enter complaints">
                 </div>
                 <div class="dialysis-field dialysis-field-20">
                     <label>Conscious Level</label>
                     <input type="text" id="txtConsciousLevel" class="form-control" placeholder="Please enter conscious level">
                 </div>
             </div>

            <div class="dialysis-form-row">
                <div class="dialysis-field dialysis-field-20">
                    <label>Edema</label>
                    <input type="text" id="txtEdema" class="form-control" placeholder="Please enter edema">
                </div>
                <div class="dialysis-field dialysis-field-20">
                    <label>Card Rhythm</label>
                    <input type="text" id="txtCardRhythm" class="form-control" placeholder="Please enter card rhythm">
                </div>
                <div class="dialysis-field dialysis-field-20">
                    <label>Lungs</label>
                    <input type="text" id="txtLungs" class="form-control" placeholder="Please enter lungs">
                </div>
                <div class="dialysis-field dialysis-field-20">
                    <label>Other</label>
                    <input type="text" id="txtOther" class="form-control" placeholder="Please enter other">
                </div>
                <div class="dialysis-field dialysis-field-20">
                    <label>Remarks</label>
                    <input type="text" id="txtRemarks" class="form-control" placeholder="Please enter remarks">
                </div>
            </div>

             <div class="dialysis-form-row">
                 <div class="dialysis-field dialysis-field-100">
                     <label>Special Instruction</label>
                     <textarea id="txtSpecialInstruction" class="form-control" placeholder="Please enter instruction"></textarea>
                 </div>
             </div>

             <div class="dialysis-action-buttons">

                 <button type="button" class="btn btn-primry" id="btnSaveStep1">
                     Save & Next
                 </button>
                 <button type="button" class="btn-primry" onclick="newForm()">
      New
</button>
                 <button type="button" class="btn-primry" onclick="viewList()">
      List
</button>
             </div>
         </div>

         <!-- Step 2: During Dialysis -->
         <div class="form-section" id="section2">
             <div class="dialysis-form-row">
                 <div class="dialysis-field dialysis-field-100">
                     <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
                         <label style="margin: 0;">Vital Signs During Dialysis</label>
                         <button type="button" class="btn btn-primry btn-sm" id="btnAddVitalRow">
                             <i class="fa fa-plus"></i> Add Row
                         </button>
                     </div>
                     <div class="table-responsive">
                         <table id="tblVitalSigns" class="table table-bordered">
                             <thead>
                                 <tr>
                                     <th>Time</th>
                                     <th>Temperature (°F)</th>
                                     <th>BP-Sys (mmHg)</th>
                                     <th>BP-Dias (mmHg)</th>
                                     <th>Pulse (bpm)</th>
                                     <th>Dialysis Flow Rate (ml/min)</th>
                                     <th>Venous Pressure (mmHg)</th>
                                     <th>Blood Flow (ml/min)</th>
                                     <th>Action</th>
                                 </tr>
                             </thead>
                             <tbody id="vitalSignsBody">
                             </tbody>
                         </table>
                     </div>
                 </div>
             </div>

             <div class="dialysis-action-buttons">
                 <button type="button" class="btn btn-secondary" id="btnBackToStep1">
                     <i class="fa fa-arrow-left"></i> Back
                 </button>
                 <button type="button" class="btn btn-primry" id="btnSaveStep2">
                     <i class="fa fa-save"></i> Save & Next
                 </button>
             </div>
         </div>

         <!-- Step 3: Post Dialysis -->
         <div class="form-section" id="section3">
             <div class="dialysis-form-row">
                 <div class="dialysis-field dialysis-field-20">
                     <label>Start Time<span class="required">*</span></label>
                     <input type="time" id="txtPostStartTime" class="form-control" />
                 </div>
                 <div class="dialysis-field dialysis-field-20">
                     <label>End Time<span class="required">*</span></label>
                     <input type="time" id="txtPostEndTime" class="form-control" />
                 </div>
                 <div class="dialysis-field dialysis-field-20">
                     <label>Total Duration</label>
                     <input type="text" id="txtPostDuration" class="form-control" readonly />
                 </div>
                 <div class="dialysis-field dialysis-field-20">
                     <label>Staff<span class="required">*</span></label>
                     <select id="ddlPostStaff" class="form-control">
                         <option value="">Select Staff</option>
                     </select>
                 </div>
                 <div class="dialysis-field dialysis-field-20">
                     <label>Weight (kg)</label>
                     <input type="number" step="0.1" id="txtPostWeight" class="form-control" placeholder="Weight" />
                 </div>
             </div>

             <div class="dialysis-form-row">
                 <div class="dialysis-field dialysis-field-20">
                     <label>Temperature (°F)</label>
                     <input type="number" step="0.1" id="txtPostTemp" class="form-control" placeholder="Temperature" />
                 </div>
                 <div class="dialysis-field dialysis-field-20">
                     <label>BP-Sys (mmHg)</label>
                     <input type="number" id="txtPostBPSys" class="form-control" placeholder="Systolic" />
                 </div>
                 <div class="dialysis-field dialysis-field-20">
                     <label>BP-Dias (mmHg)</label>
                     <input type="number" id="txtPostBPDias" class="form-control" placeholder="Diastolic" />
                 </div>
                 <div class="dialysis-field dialysis-field-20">
                     <label>Pulse (bpm)</label>
                     <input type="number" id="txtPostPulse" class="form-control" placeholder="Pulse" />
                 </div>
             </div>

             <div class="dialysis-form-row">
                 <div class="dialysis-field dialysis-field-100">
                     <label>Comments</label>
                     <textarea id="txtPostComments" class="form-control" placeholder="Enter any additional comments or observations" rows="4"></textarea>
                 </div>
             </div>

             <div class="dialysis-action-buttons">
                 <button type="button" class="btn btn-secondary" id="btnBackToStep2">
                     <i class="fa fa-arrow-left"></i> Back
                 </button>
                 <button type="button" class="btn btn-success" id="btnSaveStep3">
                     <i class="fa fa-check"></i> Save
                 </button>
             </div>
         </div>
     </div>

     <!-- Patient Search Modal (Bootstrap) -->
     <div id="PatientsSearchModel" class="modal fade" data-backdrop="static" tabindex="-1" role="dialog">
         <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable" role="document">
             <div class="modal-content">
                 <div class="modal-body">
                     <fieldset class="form-group">
                         <div class="form-row">
                             <div class="col-md-3">
                                 <h5>Search Your Patients:</h5>
                                 <input type="text" id="txtPatientSearch" class="form-control" autocomplete="off" placeholder="Enter patient name or MR No." />
                             </div>
                         </div>
                     </fieldset>
                     <div class="table-responsive">
                         <table class="table table-hover table-striped table-bordered" id="tblPatientsResult">
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
                             <tbody id="iPatientsBody">
                             </tbody>
                         </table>
                     </div>
                 </div>
                 <div class="modal-footer">
                     <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                 </div>
             </div>
         </div>
     </div>

</asp:Content>
