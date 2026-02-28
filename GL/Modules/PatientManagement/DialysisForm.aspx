<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DialysisForm.aspx.cs" Inherits="PMS.Modules.PatientManagement.DialysisForm" %>

 
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <link href="../../wwwroot/Tibbit_theme/css/CustomCss/swalalert.css" rel="stylesheet" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.29.4/moment.min.js"></script>
    <script>
        var currentDialysisId = '';
        var isEditMode = false;

        $(document).ready(function () {
            initializeForm();
            loadDropdowns();
            checkEditMode();
            //loadPatientModalDropdowns();
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
            $('#btnAddExistingPatient').click(function () {
                $('#PatientsSearchModel').modal('show');
                loadPatients();
            });

            $('#btnAddNewPatient').click(function () {
                AddNewPatient();
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
                    '<td>' + item.NIC + '</td>' +
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

        function AddNewPatient() {
            clearPatient();
            $('#hdfNewPatientId').val('(New)');

            $('#PatientModel').modal({
                backdrop: 'static'
            });
            $("#ddl_name").focus();
            fillmrno();
        }

        function clearPatient() {
            $('#txt_name').val("");
            $('#txt_relation').val("");
            $('#txt_dob').val("");
            $('#txt_cnic').val("");
            $('#txt_house').val('');
            $('#txtAge_yearss').val('');
            $('#txt_mobile').val('');
            $('#ddl_Gender').val('0');
            $('#ddl_status').val('0');
            $('#ddlCountry').val('0');
            $('#ddl_Province').val('0');
            $('#txtcity').val('0');
            $('#txtarea').val('0');
            $('#ddlRelation').val('S/O');
            $('#ddl_name').val('Mr.');
            $('#PrefixAge').val('Year');
            
            $('#updatePatient_Data').hide();
        }

        function clearPatientModal() {
            clearPatient();
        }
        
        function savePatient() {
            if (!validatePatientModal()) {
                return;
            }

            var Prefix_PatientName = $('#ddl_name').val();
            var PatientName = $('#txt_name').val();
            var PatientID = $('#hdfNewPatientId').val();
            var Full_Name = Prefix_PatientName + PatientName;
            var RelationType = $('#ddlRelation').val();
            var Relation = $('#txt_relation').val();
            var Gender = $('#ddl_Gender').val();
            var Mobile = $('#txt_mobile').val();
            var Age = $('#txt_dob').val();
            var Date_Of_Birth = $('#txtAge_yearss').val();
            var CNIC = $('#txt_cnic').val();
            var Address = $('#txt_house').val();
            var stno = '';
            var city = $('#txtcity :selected').text();
            var area = $('#txtarea :selected').text();
            var city_val = $('#txtcity').val();
            var area_val = $('#txtarea').val();
            var martail_status = $('#ddl_status').val();
            var Country = $('#ddlCountry :selected').val();
            var Province = $('#ddl_Province :selected').val();
            var cardfee = $('#txtCardFee').val() || '0';

            if ((PatientName == "" || Mobile == "")) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Enter compulsory Fields',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                return;
            }

            var data = {
                Full_Name: Full_Name,
                RelationType: RelationType,
                Relation: Relation,
                Gender: Gender,
                Mobile: Mobile,
                Date_Of_Birth: Date_Of_Birth,
                CNIC: CNIC,
                Address: Address,
                stno: stno,
                city: city,
                city_val: city_val,
                area_val: area_val,
                area: area,
                PatientID: PatientID,
                martail_status: martail_status,
                Age: Age,
                "Country": Country,
                "Province": Province,
                "cardfee": cardfee
            };

            $.ajax({
                type: "POST",
                url: "DialysisForm.aspx/SavePatientDetail",
                data: JSON.stringify(data),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var result = response.d;
                    
                    if (result && result.indexOf('error') === -1) {
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: 'Patient saved successfully.',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                        
                        // Get patient info after save
                        get_pat_initial_info(result);
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Error while saving data: ' + result,
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                    }
                },
                error: function (xhr, status, error) {
                    console.error("Error: ", error);
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Error while saving data. Please try again',
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

        function validatePatientModal() {
            var isValid = true;
            var errorMessage = '';

            // Clear previous validation
            $('.modal-body input, .modal-body select').removeClass('is-invalid');

            // Name validation
            var PatientName = $('#txt_name').val();
            if (!PatientName || PatientName.trim() === '') {
                $('#txt_name').addClass('is-invalid');
                errorMessage += 'Patient name is required.\n';
                isValid = false;
            }

            // Mobile validation
            var Mobile = $('#txt_mobile').val();
            if (!Mobile || Mobile.trim() === '') {
                $('#txt_mobile').addClass('is-invalid');
                errorMessage += 'Mobile number is required.\n';
                isValid = false;
            }

            if (!isValid) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: errorMessage,
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
            }

            return isValid;
        }

        function SavePatient() {
            if (!validatePatientModal()) {
                return;
            }

            var Prefix_PatientName = $('#ddl_name').val();
            var PatientName = $('#txt_name').val();
            var PatientID = $('#hdfNewPatientId').val();
            var Full_Name = Prefix_PatientName + PatientName;
            var RelationType = $('#ddlRelation').val();
            var Relation = $('#txt_relation').val();
            var Gender = $('#ddl_Gender').val();
            var Mobile = $('#txt_mobile').val();
            var Age = $('#txt_dob').val();
            var Date_Of_Birth = $('#txtAge_yearss').val();
            var CNIC = $('#txt_cnic').val();
            var Address = $('#txt_house').val();
            var stno = '';
            var city = $('#txtcity :selected').text();
            var area = $('#txtarea :selected').text();
            var city_val = $('#txtcity').val();
            var area_val = $('#txtarea').val();
            var martail_status = $('#ddl_status').val();
            var Country = $('#ddlCountry :selected').val();
            var Province = $('#ddl_Province :selected').val();
            var cardfee = $('#txtCardFee').val() || '0';

            if ((PatientName == "" || Mobile == "")) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Enter compulsory Fields',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                return;
            }

            var data = {
                Full_Name: Full_Name,
                RelationType: RelationType,
                Relation: Relation,
                Gender: Gender,
                Mobile: Mobile,
                Date_Of_Birth: Date_Of_Birth,
                CNIC: CNIC,
                Address: Address,
                stno: stno,
                city: city,
                city_val: city_val,
                area_val: area_val,
                area: area,
                PatientID: PatientID,
                martail_status: martail_status,
                Age: Age,
                "Country": Country,
                "Province": Province,
                "cardfee": cardfee
            };

            $.ajax({
                type: "POST",
                url: "DialysisForm.aspx/SavePatientDetail",
                data: JSON.stringify(data),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var result = response.d;
                    
                    if (result && result.indexOf('error') === -1) {
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: 'Patient saved successfully.',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                        
                        // Get patient info after save
                        get_pat_initial_info(result);
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Error while saving data: ' + result,
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                    }
                },
                error: function (xhr, status, error) {
                    console.error("Error: ", error);
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Error while saving data. Please try again',
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

        function get_pat_initial_info(ini_patientID) {
            $('#PatientModel').modal('hide');
            
            // Load patient info and select them
            $.ajax({
                type: "POST",
                url: "DialysisForm.aspx/SearchPatients",
                data: JSON.stringify({ searchText: ini_patientID }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    if (data.length > 0) {
                        var patient = data[0];
                        selectPatient(patient.PatientId, patient.MRNo, patient.PatientName, patient.Age, patient.Gender, patient.ContactNo);
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

    .form-card {
        background-color: #fff;
        border: 1px solid #e0e0e0;
        border-radius: 8px;
        padding: 20px;
        margin-bottom: 20px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.05);
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

    .btn-primry i, .btn-secondary i, .btn-success i {
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

    .is-invalid {
        border-color: #dc3545 !important;
        background-color: #fff5f5 !important;
    }

    .is-invalid:focus {
        border-color: #dc3545 !important;
        box-shadow: 0 0 0 0.2rem rgba(220, 53, 69, 0.25) !important;
    }
    
    /* Fix modal input alignment */
    .modal-body .row {
        margin-left: 0;
        margin-right: 0;
    }
    
    .modal-body .col-lg-1,
    .modal-body .col-lg-2,
    .modal-body .col-lg-3 {
        padding-left: 10px;
        padding-right: 10px;
    }
    
    .modal-body label {
        margin-top: 10px;
    }
    
    .modal-body .form-control,
    .modal-body select {
        width: 100% !important;
        margin-top: 0;
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
         <asp:HiddenField ID="hdfNewPatientId" runat="server" ClientIDMode="Static" />

         <div class="dialysis-top-buttons">
             <button type="button" class="btn-primry" id="btnAddNewPatient">
                 Add New Patient
             </button>
             <button type="button" class="btn-primry" id="btnAddExistingPatient">
                   Add Existing Patient
             </button>
         </div>

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

             <div class="dialysis-field dialysis-field-50">
                 <div class="step-summary-card">
                     <h6><i class="fa fa-list-check"></i> Dialysis Progress</h6>
                     
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
             <div class="form-card">
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
             <div class="form-card">
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
             </div>

             <div class="dialysis-action-buttons">
                 <button type="button" class="btn btn-secondary" id="btnBackToStep1">
                     <i class="fa fa-arrow-left"></i> Back
                 </button>
                 <button type="button" class="btn btn-primry" id="btnSaveStep2">
                     <i class="fa fa-save"></i> Save & Next
                 </button>
                 <button type="button" class="btn-primry" onclick="newForm()">
                     <i class="fa fa-file"></i> New
                 </button>
                 <button type="button" class="btn-primry" onclick="viewList()">
                     <i class="fa fa-list"></i> List
                 </button>
             </div>
         </div>

         <!-- Step 3: Post Dialysis -->
         <div class="form-section" id="section3">
             <div class="form-card">
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
             </div>

             <div class="dialysis-action-buttons">
                 <button type="button" class="btn btn-secondary" id="btnBackToStep2">
                     <i class="fa fa-arrow-left"></i> Back
                 </button>
                 <button type="button" class="btn btn-success" id="btnSaveStep3">
                     <i class="fa fa-check"></i> Save
                 </button>
                 <button type="button" class="btn-primry" onclick="newForm()">
                     <i class="fa fa-file"></i> New
                 </button>
                 <button type="button" class="btn-primry" onclick="viewList()">
                     <i class="fa fa-list"></i> List
                 </button>
             </div>
         </div>
     </div>

     <!-- Existing Patient Search Modal -->
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

     <!-- New Patient Registration Modal -->
     <div id="PatientModel" class="modal fade" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Patient Details</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>

                <div class="modal-body">
                    <div class="row">
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <label for="txt_Mrno">MR No</label>
                            <input type="text" id="txt_Mrno" class="form-control" disabled />
                        </div>
                        <div class="col-lg-1 col-md-4 col-sm-6">
                            <label for="ddl_name">Name<span style="color: red;">*</span></label>
                            <select id="ddl_name" class="form-control" style="width: 137%">
                                <option value="Mr.">Mr.</option>
                                <option value="Mrs.">Mrs.</option>
                                <option value="Ms.">Ms.</option>
                                <option value="B/O.">B/O.</option>
                            </select>
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6" style="margin-top: 7px">
                            <label></label>
                            <input name="dob" type="text" id="txt_name" class="form-control" />
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <label for="ddlRelation">Relation<span style="color: red;">*</span></label>
                            <select id="ddlRelation" class="form-control">
                                <option value="S/O">S/O</option>
                                <option value="W/O">W/O</option>
                                <option value="D/O">D/O</option>
                            </select>
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label></label>
                            <input type="text" id="txt_relation" class="form-control" style="margin-top: 5px" />
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <label for="PrefixAge">Age/DOB<span style="color: red;">*</span></label>
                            <select id="PrefixAge" class="form-control">
                                <option value="Year">Year</option>
                                <option value="Month">Month</option>
                                <option value="Day">Day</option>
                            </select>
                        </div>
                        <div class="col-lg-1 col-md-4 col-sm-6" style="margin-top: 8px;">
                            <label></label>
                            <input type="text" id="txt_dob" class="form-control" placeholder="DOB" onchange="CalculateDateOfBirth();" style="width: 137% !important" />
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6" style="margin-top: 7px;">
                            <label></label>
                            <input type="text" id="txtAge_yearss" class="form-control" placeholder="dd mmyy" />
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <label for="ddl_Gender">Gender<span style="color: red;">*</span></label>
                            <select id="ddl_Gender" class="form-control">
                                <option value="0">Select Gender</option>
                            </select>
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="txt_cnic">CNIC<span style="color: red;">*</span></label>
                            <input type="text" id="txt_cnic" class="form-control" />
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="txt_mobile">Mobile<span style="color: red;">*</span></label>
                            <input type="text" id="txt_mobile" class="form-control" />
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="ddl_status">Marital Status<span style="color: red;">*</span></label>
                            <select id="ddl_status" class="form-control">
                                <option value="0">Select Marial</option>
                            </select>
                        </div>
                        <div class="col-lg-2 colmd-4 col-sm-6">
                            <label>Country</label>
                            <select id="ddlCountry" class="form-control" onchange="loadProvinces(this.value)">
                                <option value="0">Select Country</option>
                            </select>
                        </div>
                        <div class="col-lg-3 colmd-4 col-sm-6">
                            <label>Province</label>
                            <select id="ddl_Province" class="form-control" onchange="loadCities(this.value)">
                                <option value="0">Select Province</option>
                            </select>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-lg-3 colmd-4 col-sm-6">
                            <label for="txtcity">City</label>
                            <select id="txtcity" class="form-control" onchange="loadAreas(this.value)">
                                <option value="0">Select City</option>
                            </select>
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="txtarea">Area</label>
                            <select id="txtarea" class="form-control">
                                <option value="0">Select Area</option>
                            </select>
                        </div>
                        <div class="col-lg-5 col-md-4 col-sm-6">
                            <label for="txt_house">Address</label>
                            <input type="text" id="txt_house" class="form-control" />
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6" style="display:none">
                            <label for="lblfee">Fee<span style="color: red;">*</span></label>
                            <input type="text" tabindex="17" id="txtCardFee" class="form-control" />
                        </div>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-primry" id="SavePatient_Data" onclick="SavePatient();">Save</button>
                    <button type="button" class="btn btn-secondary" id="updatePatient_Data" onclick="SavePatient();">Update</button>
                    <button type="button" class="btn btn-gray" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
