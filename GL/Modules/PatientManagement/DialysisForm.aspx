<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DialysisForm.aspx.cs" Inherits="PMS.Modules.PatientManagement.DialysisForm" %>

 
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <link href="../../wwwroot/lib/sweetalert/swalalert.css" rel="stylesheet" />
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/vendor.css" rel="stylesheet" />
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/Datavalue.css" rel="stylesheet" />
    <link href="../../wwwroot/lib/theme/pharmacy-form.css?v=6" rel="stylesheet" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.29.4/moment.min.js"></script>
    <script type="text/javascript">
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
            fillArea();
            fillCountry();
            fillProvince();
            fillCity();
            fillGender();
            fillmartial();
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

        function CalculateDateOfBirth() {
            var Numbers = $('#PrefixAge').val();
            var CalDob = $('#txt_dob').val();

            if (!CalDob || isNaN(CalDob) || CalDob <= 0) {
                $('#txtAge_yearss').val('');
                return;
            }

            var now = moment();
            var dob;

            if (Numbers === "Year") {
                dob = now.subtract(CalDob, 'years');
            } else if (Numbers === "Month") {
                dob = now.subtract(CalDob, 'months');
            } else if (Numbers === "Day") {
                dob = now.subtract(CalDob, 'days');
            } else {
                $('#txtAge_yearss').val('');
                return;
            }

            var finalDate = dob.format("DD/MM/YYYY");

            var $datepicker = $('#txtAge_yearss');
            if (!$datepicker.hasClass('hasDatepicker')) {
                $datepicker.datepicker({
                    changeMonth: true,
                    changeYear: true,
                    yearRange: "-100:+0",
                    dateFormat: "dd/mm/yy"
                });
            }

            $datepicker.datepicker('setDate', dob.toDate());

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

        // the real MR number is generated on save (GenerateMRNo); until then the form shows "New"
        function fillmrno() {
            $('#txt_Mrno').val('New');
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
            $('#SavePatient_Data').attr('disabled', true);
            if (!validatePatientModal()) {
                $('#SavePatient_Data').attr('disabled', false);
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

        function viewList() {
            window.location.href = "DialysisView.aspx";
        }

        function newForm() {
            window.location.href = "DialysisForm.aspx";
        }

        function fillGender() {
            $.ajax({
                type: "POST",
                url: "DialysisForm.aspx/GetGenders",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    var options = '<option value="0">Select Gender</option>';
                    $.each(data, function (key, value) {
                        options += '<option value="' + value.Value + '">' + value.Text + '</option>';
                    });
                    $('#ddl_Gender').html(options);
                }
            });
        }

        function fillmartial() {
            var options = '<option value="0">Please Select</option>';
            PageMethods.GetMartailStatus(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddl_status').html(options);
            });
            return options;
        }

        function fillCountry() {
            var options = '<option value="0">Please Select</option>';
            PageMethods.GetCountry(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlCountry').html(options);
            });
            return options;
        }

        function fillProvince() {
            var options = '<option value="0">Please Select</option>';
            PageMethods.GetProvince(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddl_Province').html(options);
            });
            return options;
        }

        function fillCity() {
            var options = '<option value="0">Please Select</option>';
            PageMethods.GetCity(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#txtcity').html(options);
            });
            return options;
        }
        function fillArea() {
            var options = '<option value="0">Please Select</option>';
            PageMethods.GetArea(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#txtarea').html(options);
            });
            return options;
        }

        function clearFormData() {
            $('#ddlVascularAccess, #ddlMachineNo, #ddlDialyzer, #ddlAdvisedBy, #ddlPrimingBy, #ddlHeparin, #ddlDialysisType').val('');
            $('#txtPrimingSol, #txtHeparinInfusion, #txtCurrentWeight, #txtLastWeight, #txtStartTime, #txtFinishTime, #txtWeightDiff, #txtUF, #txtUFRate, #txtTotalDuration, #txtSpecialInstruction, #txtComplaints, #txtConsciousLevel, #txtEdema, #txtCardRhythm, #txtLungs, #txtOther, #txtRemarks').val('');

            $('#vitalSignsBody').empty();

            $('#ddlPostStaff').val('');
            $('#txtPostStartTime, #txtPostEndTime, #txtPostDuration, #txtPostWeight, #txtPostTemp, #txtPostBPSys, #txtPostBPDias, #txtPostPulse, #txtPostComments').val('');

            generateNewDialysisId();

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
            $('#btnSaveStep1').attr('disabled', true);
            var patientId = $('#hdfPatientId').val();
            if (!patientId) {
                $('#btnSaveStep1').attr('disabled', false);
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
                        updateStepSummary();
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: isEditMode ? 'Step 1 updated successfully' : 'Step 1 saved successfully',
                            timer: 2000,
                            showConfirmButton: false
                        });
                        $('#btnSaveStep1').attr('disabled', false);
                        navigateToStep(2);
                    } else {
                        $('#btnSaveStep1').attr('disabled', false);
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Error saving data: ' + response.d,
                            timer: 2000,
                            showConfirmButton: false
                        });
                    }
                },
                error: function () {
                    $('#btnSaveStep1').attr('disabled', false);
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
            $('#btnSaveStep2').attr('disabled', true);
            var vitalsData = getVitalSignsData();

            if (vitalsData.length === 0) {
                $('#btnSaveStep2').attr('disabled', false);
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
                        updateStepSummary();
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: isEditMode ? 'Step 2 updated successfully' : 'Step 2 saved successfully',
                            timer: 2000,
                            showConfirmButton: false
                        });
                        navigateToStep(3);
                    } else {
                        $('#btnSaveStep2').attr('disabled', false);
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Error saving data: ' + response.d,
                            timer: 2000,
                            showConfirmButton: false
                        });
                    }
                },
                error: function () {
                    $('#btnSaveStep2').attr('disabled', false);
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
                    diffMs += 24 * 60 * 60 * 1000;
                }

                var hours = Math.floor(diffMs / (1000 * 60 * 60));
                var minutes = Math.floor((diffMs % (1000 * 60 * 60)) / (1000 * 60));

                $('#txtPostDuration').val(hours + ' hour(s) ' + minutes + ' minute(s)');
            }
        }

        function saveStep3() {
            $('#btnSaveStep3').attr('disabled', true);
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
                        updateStepSummary();
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: isEditMode ? 'Dialysis form updated successfully' : 'Dialysis form completed successfully',
                            timer: 2000,
                            showConfirmButton: false
                        });
                    } else {
                        $('#btnSaveStep3').attr('disabled', false);
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Error saving data: ' + response.d,
                            timer: 2000,
                            showConfirmButton: false
                        });
                    }
                },
                error: function () {
                    $('#btnSaveStep3').attr('disabled', false);
                }
            });
        }
        
    </script>
<style>
    /* ==========================================================================
       Dialysis form - built on the shared .ph-card / .ph-grid styles (wwwroot/lib/theme/pharmacy-form.css).
       Page header, patient bar + 3-step tracker, one card per step, vitals table, patient modals.
       Colours come from the active theme (--theme-accent ...). Keep the .step-item / .form-section state
       classes (active, completed, disabled): the page script toggles them.
       ========================================================================== */
    .dl-page { display: flex; flex-direction: column; gap: 16px; width: 100%; margin: 0 0 24px; }

    /* ---------- header ---------- */
    .dl-head { display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: 12px 20px; padding: 0 6px; }
    .dl-head h2 { margin: 0; font-size: 22px; font-weight: 800; color: var(--theme-ink, #1b2a41) !important; }
    .dl-head h2 > i { margin-right: 6px; color: var(--theme-accent, #438eb9); }
    .dl-head p { margin: 2px 0 0; font-size: 13px; color: #6b7686; }
    .dl-badge {
        display: inline-flex; align-items: center; gap: 6px; margin-left: 10px; padding: 3px 10px;
        font-size: 12px; font-weight: 700; vertical-align: middle; border-radius: 999px;
        color: var(--theme-accent-ink, #2b6a90); background: var(--theme-accent-soft, #e8f1f8);
    }
    .dl-actions { display: flex; flex-wrap: wrap; gap: 8px; }

    /* ---------- buttons ---------- */
    .dl-page .dl-btn {
        display: inline-flex; align-items: center; justify-content: center; gap: 7px;
        width: auto; min-width: 0; height: 36px; margin: 0; padding: 0 18px;
        font-size: 13px; font-weight: 700; line-height: 1; white-space: nowrap; cursor: pointer;
        border-radius: 6px; border: 1px solid transparent; transition: filter .15s ease, box-shadow .15s ease;
    }
    .dl-page .dl-btn:hover { filter: brightness(.95); }
    .dl-page .dl-btn:disabled { opacity: .6; cursor: not-allowed; }
    .dl-btn-primary { color: var(--theme-on-accent, #fff); background: var(--theme-accent, #438eb9); }
    .dl-btn-success { color: #fff; background: #2e9e5b; }
    .dl-btn-outline { color: var(--theme-accent-ink, #2b6a90); background: #fff; border-color: var(--theme-accent, #438eb9) !important; }
    .dl-btn-quiet { color: #4a5568; background: #eef1f5; border-color: #dde3ea !important; }

    /* ---------- patient bar + step tracker ---------- */
    .dl-page .dl-patientbar { display: grid; grid-template-columns: minmax(0, 1fr) minmax(0, 1.1fr); gap: 20px 28px; align-items: center; padding: 16px; }
    @media (max-width: 991px) { .dl-page .dl-patientbar { grid-template-columns: minmax(0, 1fr); } }
    .dl-patient { display: flex; align-items: center; gap: 14px; min-width: 0; }
    .dl-avatar {
        flex: 0 0 auto; display: flex; align-items: center; justify-content: center; width: 64px; height: 64px;
        overflow: hidden; border-radius: 50%; background: var(--theme-accent-soft, #e8f1f8);
    }
    .dl-avatar img { width: 42px; height: auto; }
    .dl-patient-name { font-size: 17px; font-weight: 800; color: var(--theme-ink, #1b2a41); overflow-wrap: anywhere; }
    .dl-chips { display: flex; flex-wrap: wrap; gap: 6px 8px; margin-top: 6px; }
    .dl-chip { display: inline-flex; align-items: center; gap: 6px; padding: 3px 11px; font-size: 12px; font-weight: 600; color: #2d3748; background: #eef1f5; border-radius: 999px; }
    .dl-chip b { font-weight: 700; color: #6b7686; }

    .dl-steps { display: flex; align-items: flex-start; justify-content: center; padding: 4px 0; }
    .step-item { position: relative; flex: 0 0 auto; display: flex; flex-direction: column; align-items: center; gap: 6px; width: 84px; cursor: pointer; }
    .step-item.disabled { cursor: not-allowed; opacity: .55; }
    .step-icon {
        display: flex; align-items: center; justify-content: center; width: 44px; height: 44px; font-size: 18px;
        color: #6b7686; background: #e6eaf0; border-radius: 50%; transition: background .2s ease, box-shadow .2s ease;
    }
    .step-item.active .step-icon { color: var(--theme-on-accent, #fff); background: var(--theme-accent, #438eb9); box-shadow: 0 0 0 4px var(--theme-accent-ring, rgba(67, 142, 185, .25)); }
    .step-item.completed .step-icon { color: #fff; background: #2e9e5b; }
    .step-item.completed .step-icon i { display: none; }
    .step-item.completed .step-icon::after { content: "\f00c"; font-family: FontAwesome; font-size: 18px; }
    .step-label { font-size: 12px; font-weight: 700; color: #6b7686; text-align: center; }
    .step-item.active .step-label { color: var(--theme-accent-ink, #2b6a90); }
    .step-arrow { flex: 1 1 36px; max-width: 90px; height: 2px; margin-top: 21px; font-size: 0; color: transparent; overflow: hidden; background: #d5dbe3; border-radius: 2px; }
    .step-item.completed + .step-arrow { background: #2e9e5b; }

    /* ---------- step sections ---------- */
    .form-section { display: none; }
    .form-section.active { display: flex; flex-direction: column; gap: 16px; animation: dlFade .25s ease; }
    @keyframes dlFade { from { opacity: 0; transform: translateY(6px); } to { opacity: 1; transform: none; } }

    .dl-group {
        display: flex; align-items: center; gap: 8px; margin: 20px 0 12px; padding-bottom: 6px;
        font-size: 12px; font-weight: 800; letter-spacing: .06em; text-transform: uppercase;
        color: var(--theme-accent-ink, #2b6a90); border-bottom: 1px solid #e3e8ee;
    }
    .dl-group:first-of-type { margin-top: 4px; }
    .dl-group i { font-size: 13px; opacity: .85; }
    .dl-grid { grid-template-columns: repeat(auto-fill, minmax(190px, 1fr)); }
    .dl-grid-5 { grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); }
    .dl-span-all { grid-column: 1 / -1; }
    .dl-page .required { margin-left: 2px; color: #c0392b; }
    .dl-page .ph-card textarea.form-control {
        display: block; width: 100%; min-height: 84px; padding: 8px 10px; font-size: 13px; font-weight: 600; resize: vertical;
        color: var(--theme-ink, #1b2a41); background: #fff; border: 1px solid #cfd6e0; border-radius: 6px; box-shadow: none; box-sizing: border-box;
    }
    .dl-page .ph-card textarea.form-control:focus { border-color: var(--theme-accent, #438eb9); box-shadow: 0 0 0 3px var(--theme-accent-ring, rgba(67, 142, 185, .25)); outline: none; }
    .dl-page .ph-card input[type="time"].form-control, .dl-page .ph-card input[type="number"].form-control { padding-right: 8px !important; }
    .dl-page .is-invalid { border-color: #c0392b !important; box-shadow: 0 0 0 3px rgba(192, 57, 43, .15) !important; }

    .dl-actionbar { display: flex; flex-wrap: wrap; align-items: center; justify-content: flex-end; gap: 8px; }
    .dl-actionbar .dl-btn-back { margin-right: auto; }

    /* ---------- vitals during dialysis ---------- */
    .dl-toolbar { display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: 10px; margin-bottom: 12px; }
    .dl-toolbar h6 { margin: 0; font-size: 13px; font-weight: 700; color: #4a5568; }
    .dl-table-wrap { margin: 0 -16px; overflow-x: auto; border-top: 1px solid #e3e8ee; }
    #tblVitalSigns { width: 100%; margin: 0; border-collapse: separate; border-spacing: 0; }
    #tblVitalSigns thead th {
        position: sticky; top: 0; z-index: 1; padding: 9px 10px; font-size: 11.5px; letter-spacing: .03em; text-transform: uppercase; white-space: nowrap; vertical-align: middle;
        color: var(--theme-on-accent, #fff); background: var(--theme-accent, #438eb9); border: 0; border-bottom: 2px solid var(--theme-accent-ink, #2b6a90);
    }
    #tblVitalSigns td { padding: 6px 8px; vertical-align: middle; border: 0; border-bottom: 1px solid #eef1f5; }
    #tblVitalSigns tbody tr:hover td { background: var(--theme-accent-soft, #f4f8fb); }
    #tblVitalSigns td:last-child, #tblVitalSigns th:last-child { width: 64px; text-align: center; }
    #vitalSignsBody input.form-control { min-width: 78px; }
    #vitalSignsBody input.vital-time { min-width: 108px; }
    #vitalSignsBody .btn-danger {
        display: inline-flex; align-items: center; justify-content: center; width: 32px; height: 32px; padding: 0; margin: 0;
        color: #c0392b; background: #fdecea; border: 0; border-radius: 6px;
    }
    #vitalSignsBody .btn-danger:hover { background: #f9d6d2; }
    .dl-state { display: none; padding: 26px 16px; text-align: center; font-size: 13px; color: #8a94a6; }
    .dl-state i { display: block; margin-bottom: 6px; font-size: 26px; opacity: .6; }

    /* ---------- modals (existing patient search + new patient) ---------- */
    .dl-page .modal-content { overflow: hidden; border: 0; border-radius: 10px; box-shadow: 0 20px 50px rgba(16, 24, 40, .3); }
    .dl-page .modal-header {
        display: flex; align-items: center; justify-content: space-between; padding: 12px 18px;
        color: var(--theme-on-accent, #fff); border-bottom: 1px solid var(--theme-accent-ink, #2b6a90);
        background: linear-gradient(180deg, var(--theme-accent-light, #438eb9) 0%, var(--theme-accent, #438eb9) 100%) !important;
    }
    .dl-page .modal-header::before, .dl-page .modal-header::after { display: none; }
    .dl-page .modal-title { margin: 0; font-size: 15px; font-weight: 800; letter-spacing: .03em; text-transform: uppercase; }
    .dl-page .modal-header .close { float: none; margin: 0 !important; padding: 0; line-height: 1; font-size: 26px; color: inherit; opacity: .9; text-shadow: none; }
    .dl-page .modal-body { max-height: 68vh; padding: 16px 18px; overflow-y: auto; }
    .dl-page .modal-footer { display: flex; justify-content: flex-end; gap: 8px; padding: 12px 18px; background: #f8fafc; border-top: 1px solid #e3e8ee; }

    .dl-modal label { display: block; margin: 0 0 4px; font-size: 11.5px; font-weight: 700; letter-spacing: .02em; color: #4a5568; }
    .dl-modal input.form-control, .dl-modal select.form-control {
        width: 100%; height: 34px; padding: 4px 10px; margin: 0; font-size: 13px; font-weight: 600;
        color: var(--theme-ink, #1b2a41); background: #fff; border: 1px solid #cfd6e0; border-radius: 6px; box-shadow: none; box-sizing: border-box;
    }
    .dl-modal input.form-control:focus, .dl-modal select.form-control:focus { border-color: var(--theme-accent, #438eb9); box-shadow: 0 0 0 3px var(--theme-accent-ring, rgba(67, 142, 185, .25)); outline: none; }
    .dl-modal input[disabled], .dl-modal input[readonly] { background: #f3f5f8; cursor: not-allowed; }
    .dl-modal .select2-container { width: 100% !important; display: block; }
    .dl-modal .select2-container .select2-selection--single { height: 34px; border: 1px solid #cfd6e0; border-radius: 6px; }
    .dl-modal .select2-container .select2-selection--single .select2-selection__rendered { line-height: 32px; padding-left: 10px; font-size: 13px; font-weight: 600; }
    .dl-modal .select2-container .select2-selection--single .select2-selection__arrow { height: 32px; }
    .dl-modal select.select2-hidden-accessible { width: 1px !important; height: 1px !important; padding: 0 !important; border: 0 !important; }
    .dl-modal .ph-grid { grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 12px 14px; align-items: end; }
    @media (max-width: 767px) { .dl-modal .ph-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); } }
    @media (max-width: 480px) { .dl-modal .ph-grid { grid-template-columns: minmax(0, 1fr); } .dl-modal .ph-span-2 { grid-column: auto; } }
    .ui-datepicker { z-index: 2000 !important; }

    .dl-search-bar { margin-bottom: 12px; }
    .dl-table-scroll { max-height: 52vh; overflow: auto; border: 1px solid #e3e8ee; border-radius: 8px; }
    #tblPatientsResult { width: 100%; margin: 0; border-collapse: separate; border-spacing: 0; }
    #tblPatientsResult thead th {
        position: sticky; top: 0; z-index: 1; padding: 9px 12px; font-size: 11.5px; letter-spacing: .03em; text-transform: uppercase; white-space: nowrap;
        color: var(--theme-on-accent, #fff); background: var(--theme-accent, #438eb9); border: 0;
    }
    #tblPatientsResult td { padding: 8px 12px; vertical-align: middle; border: 0; border-bottom: 1px solid #eef1f5; }
    #tblPatientsResult tbody tr:hover td { background: var(--theme-accent-soft, #f4f8fb); }
    #tblPatientsResult td[colspan] { padding: 22px; text-align: center; color: #8a94a6; }
    #tblPatientsResult .btn-primry, #tblPatientsResult .btn-primary {
        display: inline-flex; align-items: center; justify-content: center; width: 32px; height: 32px; padding: 0;
        color: var(--theme-on-accent, #fff); background: var(--theme-accent, #438eb9); border: 0; border-radius: 6px;
    }

    /* ---------- dark mode ---------- */
    html[data-theme="dark"] .dl-head h2 { color: var(--dk-text, #e6e9ef) !important; }
    html[data-theme="dark"] .dl-head p { color: var(--dk-muted, #9aa6b8); }
    html[data-theme="dark"] .dl-badge { background: var(--dk-surface-3, #232d3d); color: var(--dk-text, #e6e9ef); }
    html[data-theme="dark"] .dl-btn-outline, html[data-theme="dark"] .dl-btn-quiet { background: var(--dk-surface-3, #232d3d); color: var(--dk-text, #e6e9ef); border-color: var(--dk-border, #2d3748) !important; }
    html[data-theme="dark"] .dl-patient-name { color: var(--dk-text, #e6e9ef); }
    html[data-theme="dark"] .dl-chip { background: var(--dk-surface-3, #232d3d); color: var(--dk-text, #e6e9ef); }
    html[data-theme="dark"] .step-icon { background: var(--dk-surface-3, #232d3d); color: var(--dk-muted, #9aa6b8); }
    html[data-theme="dark"] .step-label { color: var(--dk-muted, #9aa6b8); }
    html[data-theme="dark"] .step-arrow { background: var(--dk-border, #2d3748); }
    html[data-theme="dark"] .dl-group { border-color: var(--dk-border, #2d3748); }
    html[data-theme="dark"] .dl-toolbar h6 { color: var(--dk-text, #e6e9ef); }
    html[data-theme="dark"] .dl-table-wrap, html[data-theme="dark"] #tblVitalSigns td, html[data-theme="dark"] #tblPatientsResult td { border-color: var(--dk-border, #2d3748); }
    html[data-theme="dark"] #tblVitalSigns thead th, html[data-theme="dark"] #tblPatientsResult thead th { background: var(--dk-surface-3, #232d3d); color: var(--dk-text, #e6e9ef); }
    html[data-theme="dark"] #tblVitalSigns tbody tr:hover td, html[data-theme="dark"] #tblPatientsResult tbody tr:hover td { background: var(--dk-surface-3, #232d3d); }
    html[data-theme="dark"] .dl-page .ph-card textarea.form-control { background: var(--dk-surface-3, #232d3d); color: var(--dk-text, #e6e9ef); border-color: var(--dk-border, #2d3748); }
    html[data-theme="dark"] .dl-page .modal-content { background: var(--dk-surface-2, #1c2431); color: var(--dk-text, #e6e9ef); }
    html[data-theme="dark"] .dl-page .modal-footer { background: var(--dk-surface-3, #232d3d); border-color: var(--dk-border, #2d3748); }
    html[data-theme="dark"] .dl-modal label { color: var(--dk-muted, #9aa6b8); }
    html[data-theme="dark"] .dl-modal input.form-control, html[data-theme="dark"] .dl-modal select.form-control { background: var(--dk-surface-3, #232d3d); color: var(--dk-text, #e6e9ef); border-color: var(--dk-border, #2d3748); }
    html[data-theme="dark"] .dl-table-scroll { border-color: var(--dk-border, #2d3748); }
</style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dl-page">

        <asp:HiddenField ID="hdfDialysisId" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hdfPatientId" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hdfCurrentStep" runat="server" ClientIDMode="Static" Value="1" />
        <asp:HiddenField ID="hdfStep1Saved" runat="server" ClientIDMode="Static" Value="false" />
        <asp:HiddenField ID="hdfStep2Saved" runat="server" ClientIDMode="Static" Value="false" />
        <asp:HiddenField ID="hdfNewPatientId" runat="server" ClientIDMode="Static" />

        <!-- Page header + patient actions -->
        <div class="dl-head">
            <div>
                <h2><i class="fa fa-tint"></i>Dialysis Form <span class="dl-badge" id="dlMode"><i class="fa fa-plus-circle"></i> New session</span></h2>
                <p>Pre-dialysis assessment, vital signs during the session and the post-dialysis summary.</p>
            </div>
            <div class="dl-actions">
                <button type="button" class="dl-btn dl-btn-primary" id="btnAddNewPatient"><i class="fa fa-user-plus"></i> Add New Patient</button>
                <button type="button" class="dl-btn dl-btn-outline" id="btnAddExistingPatient"><i class="fa fa-search"></i> Add Existing Patient</button>
            </div>
        </div>

        <!-- Patient + progress -->
        <section class="ph-card dl-patientbar" id="patientInfoBar" style="display: none;">
            <div class="dl-patient">
                <div class="dl-avatar">
                    <img src="../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/Patient.png" alt="Patient" class="patient-image" />
                </div>
                <div>
                    <div class="dl-patient-name" id="infoPatientName">-</div>
                    <div class="dl-chips">
                        <span class="dl-chip"><b>MR No</b> <span id="infoMrNo">-</span></span>
                        <span class="dl-chip"><b>Age</b> <span id="infoAge">-</span></span>
                        <span class="dl-chip"><b>Gender</b> <span id="infoGender">-</span></span>
                        <span class="dl-chip"><b>Contact</b> <span id="infoContact">-</span></span>
                    </div>
                </div>
            </div>

            <div class="dl-steps">
                <div class="step-item active" id="step1Nav" onclick="navigateToStep(1)">
                    <div class="step-icon"><i class="fa fa-hourglass"></i></div>
                    <div class="step-label">Pre</div>
                </div>
                <div class="step-arrow"></div>
                <div class="step-item disabled" id="step2Nav" onclick="navigateToStep(2)">
                    <div class="step-icon"><i class="fa fa-heartbeat"></i></div>
                    <div class="step-label">During</div>
                </div>
                <div class="step-arrow"></div>
                <div class="step-item disabled" id="step3Nav" onclick="navigateToStep(3)">
                    <div class="step-icon"><i class="fa fa-clipboard"></i></div>
                    <div class="step-label">Post</div>
                </div>
            </div>
        </section>

        <!-- Step 1: Pre Dialysis -->
        <div class="form-section active" id="section1">
            <section class="ph-card">
                <h5 class="ph-card-title"><i class="fa fa-hourglass-start"></i> Pre-Dialysis Assessment</h5>

                <h6 class="dl-group"><i class="fa fa-cogs"></i> Access &amp; Machine</h6>
                <div class="ph-grid dl-grid">
                    <div class="ph-field dialysis-field">
                        <label for="ddlVascularAccess">Vascular Access<span class="required">*</span></label>
                        <select id="ddlVascularAccess" class="form-control">
                            <option value="">Select</option>
                        </select>
                    </div>
                    <div class="ph-field dialysis-field">
                        <label for="txtDialysisNo">Dialysis No.</label>
                        <input type="text" id="txtDialysisNo" class="form-control" placeholder="Dialysis Number" />
                    </div>
                    <div class="ph-field dialysis-field">
                        <label for="ddlMachineNo">Machine No.<span class="required">*</span></label>
                        <select id="ddlMachineNo" class="form-control">
                            <option value="">Select</option>
                        </select>
                    </div>
                    <div class="ph-field dialysis-field">
                        <label for="ddlDialyzer">Dialyzer</label>
                        <select id="ddlDialyzer" class="form-control">
                            <option value="">Select</option>
                        </select>
                    </div>
                    <div class="ph-field dialysis-field">
                        <label for="ddlAdvisedBy">Advised by<span class="required">*</span></label>
                        <select id="ddlAdvisedBy" class="form-control">
                            <option value="">Nothing selected</option>
                        </select>
                    </div>
                    <div class="ph-field dialysis-field">
                        <label for="ddlDialysisType">Dialysis Type</label>
                        <select id="ddlDialysisType" class="form-control">
                            <option value="">Select</option>
                        </select>
                    </div>
                </div>

                <h6 class="dl-group"><i class="fa fa-flask"></i> Priming &amp; Heparin</h6>
                <div class="ph-grid dl-grid">
                    <div class="ph-field dialysis-field">
                        <label for="ddlPrimingBy">Priming By<span class="required">*</span></label>
                        <select id="ddlPrimingBy" class="form-control">
                            <option value="">Nothing selected</option>
                        </select>
                    </div>
                    <div class="ph-field dialysis-field">
                        <label for="txtPrimingSol">Priming Sol.</label>
                        <input type="text" id="txtPrimingSol" class="form-control" value="Dental Mould for pouring" />
                    </div>
                    <div class="ph-field dialysis-field">
                        <label for="ddlHeparin">Heparin</label>
                        <select id="ddlHeparin" class="form-control">
                            <option value="">Nothing selected</option>
                        </select>
                    </div>
                    <div class="ph-field dialysis-field">
                        <label for="txtHeparinInfusion">Heparin Infusion / Hour</label>
                        <input type="text" id="txtHeparinInfusion" class="form-control" placeholder="Heparin Infusion / Hour" />
                    </div>
                </div>

                <h6 class="dl-group"><i class="fa fa-balance-scale"></i> Weight, Fluid &amp; Timing</h6>
                <div class="ph-grid dl-grid">
                    <div class="ph-field dialysis-field">
                        <label for="txtCurrentWeight">Current Weight (kg)</label>
                        <input type="text" id="txtCurrentWeight" class="form-control" placeholder="Weight" />
                    </div>
                    <div class="ph-field dialysis-field">
                        <label for="txtLastWeight">Last Weight (kg)</label>
                        <input type="text" id="txtLastWeight" class="form-control" placeholder="Last weight" />
                    </div>
                    <div class="ph-field dialysis-field">
                        <label for="txtWeightDiff">Diff. in Weight (kg)</label>
                        <input type="text" id="txtWeightDiff" class="form-control" placeholder="Weight" />
                    </div>
                    <div class="ph-field dialysis-field">
                        <label for="txtUF">UF: ml</label>
                        <input type="text" id="txtUF" class="form-control" placeholder="UF" />
                    </div>
                    <div class="ph-field dialysis-field">
                        <label for="txtUFRate">UF Rate: ml/hr</label>
                        <input type="text" id="txtUFRate" class="form-control" placeholder="UF rate" />
                    </div>
                    <div class="ph-field dialysis-field">
                        <label for="txtStartTime">Start Time<span class="required">*</span></label>
                        <input type="time" id="txtStartTime" class="form-control" value="04:00" />
                    </div>
                    <div class="ph-field dialysis-field">
                        <label for="txtFinishTime">Finish Time</label>
                        <input type="time" id="txtFinishTime" class="form-control" value="04:00" />
                    </div>
                    <div class="ph-field dialysis-field">
                        <label for="txtTotalDuration">Total Duration</label>
                        <input type="text" id="txtTotalDuration" class="form-control" placeholder="Please enter duration" />
                    </div>
                </div>

                <h6 class="dl-group"><i class="fa fa-stethoscope"></i> Clinical Assessment</h6>
                <div class="ph-grid dl-grid">
                    <div class="ph-field dialysis-field">
                        <label for="txtComplaints">Complaints</label>
                        <input type="text" id="txtComplaints" class="form-control" placeholder="Please enter complaints" />
                    </div>
                    <div class="ph-field dialysis-field">
                        <label for="txtConsciousLevel">Conscious Level</label>
                        <input type="text" id="txtConsciousLevel" class="form-control" placeholder="Please enter conscious level" />
                    </div>
                    <div class="ph-field dialysis-field">
                        <label for="txtEdema">Edema</label>
                        <input type="text" id="txtEdema" class="form-control" placeholder="Please enter edema" />
                    </div>
                    <div class="ph-field dialysis-field">
                        <label for="txtCardRhythm">Card Rhythm</label>
                        <input type="text" id="txtCardRhythm" class="form-control" placeholder="Please enter card rhythm" />
                    </div>
                    <div class="ph-field dialysis-field">
                        <label for="txtLungs">Lungs</label>
                        <input type="text" id="txtLungs" class="form-control" placeholder="Please enter lungs" />
                    </div>
                    <div class="ph-field dialysis-field">
                        <label for="txtOther">Other</label>
                        <input type="text" id="txtOther" class="form-control" placeholder="Please enter other" />
                    </div>
                    <div class="ph-field dialysis-field dl-span-all">
                        <label for="txtRemarks">Remarks</label>
                        <input type="text" id="txtRemarks" class="form-control" placeholder="Please enter remarks" />
                    </div>
                    <div class="ph-field dialysis-field dl-span-all">
                        <label for="txtSpecialInstruction">Special Instruction</label>
                        <textarea id="txtSpecialInstruction" class="form-control" placeholder="Please enter instruction"></textarea>
                    </div>
                </div>
            </section>

            <div class="dl-actionbar">
                <button type="button" class="dl-btn dl-btn-quiet" onclick="newForm()"><i class="fa fa-file-o"></i> New</button>
                <button type="button" class="dl-btn dl-btn-quiet" onclick="viewList()"><i class="fa fa-list"></i> List</button>
                <button type="button" class="dl-btn dl-btn-primary" id="btnSaveStep1">Save &amp; Next</button>
            </div>
        </div>

        <!-- Step 2: During Dialysis -->
        <div class="form-section" id="section2">
            <section class="ph-card">
                <h5 class="ph-card-title"><i class="fa fa-heartbeat"></i> During Dialysis &mdash; Vital Signs</h5>
                <div class="dl-toolbar">
                    <h6>Record the readings taken during the session</h6>
                    <button type="button" class="dl-btn dl-btn-primary" id="btnAddVitalRow"><i class="fa fa-plus"></i> Add Row</button>
                </div>
                <div class="dl-table-wrap">
                    <table id="tblVitalSigns">
                        <thead>
                            <tr>
                                <th>Time</th>
                                <th>Temperature (&deg;F)</th>
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
                    <div class="dl-state" id="vitalEmpty" style="display: block;"><i class="fa fa-heartbeat"></i> No readings yet. Use <b>Add Row</b> to record the first one.</div>
                </div>
            </section>

            <div class="dl-actionbar">
                <button type="button" class="dl-btn dl-btn-quiet dl-btn-back" id="btnBackToStep1"><i class="fa fa-arrow-left"></i> Back</button>
                <button type="button" class="dl-btn dl-btn-quiet" onclick="newForm()"><i class="fa fa-file-o"></i> New</button>
                <button type="button" class="dl-btn dl-btn-quiet" onclick="viewList()"><i class="fa fa-list"></i> List</button>
                <button type="button" class="dl-btn dl-btn-primary" id="btnSaveStep2"><i class="fa fa-save"></i> Save &amp; Next</button>
            </div>
        </div>

        <!-- Step 3: Post Dialysis -->
        <div class="form-section" id="section3">
            <section class="ph-card">
                <h5 class="ph-card-title"><i class="fa fa-clipboard"></i> Post-Dialysis Summary</h5>

                <h6 class="dl-group"><i class="fa fa-clock-o"></i> Session</h6>
                <div class="ph-grid dl-grid">
                    <div class="ph-field dialysis-field">
                        <label for="txtPostStartTime">Start Time<span class="required">*</span></label>
                        <input type="time" id="txtPostStartTime" class="form-control" />
                    </div>
                    <div class="ph-field dialysis-field">
                        <label for="txtPostEndTime">End Time<span class="required">*</span></label>
                        <input type="time" id="txtPostEndTime" class="form-control" />
                    </div>
                    <div class="ph-field dialysis-field">
                        <label for="txtPostDuration">Total Duration</label>
                        <input type="text" id="txtPostDuration" class="form-control" readonly />
                    </div>
                    <div class="ph-field dialysis-field">
                        <label for="ddlPostStaff">Staff<span class="required">*</span></label>
                        <select id="ddlPostStaff" class="form-control">
                            <option value="">Select Staff</option>
                        </select>
                    </div>
                </div>

                <h6 class="dl-group"><i class="fa fa-heartbeat"></i> Final Readings</h6>
                <div class="ph-grid dl-grid dl-grid-5">
                    <div class="ph-field dialysis-field">
                        <label for="txtPostWeight">Weight (kg)</label>
                        <input type="number" step="0.1" id="txtPostWeight" class="form-control" placeholder="Weight" />
                    </div>
                    <div class="ph-field dialysis-field">
                        <label for="txtPostTemp">Temperature (&deg;F)</label>
                        <input type="number" step="0.1" id="txtPostTemp" class="form-control" placeholder="Temperature" />
                    </div>
                    <div class="ph-field dialysis-field">
                        <label for="txtPostBPSys">BP-Sys (mmHg)</label>
                        <input type="number" id="txtPostBPSys" class="form-control" placeholder="Systolic" />
                    </div>
                    <div class="ph-field dialysis-field">
                        <label for="txtPostBPDias">BP-Dias (mmHg)</label>
                        <input type="number" id="txtPostBPDias" class="form-control" placeholder="Diastolic" />
                    </div>
                    <div class="ph-field dialysis-field">
                        <label for="txtPostPulse">Pulse (bpm)</label>
                        <input type="number" id="txtPostPulse" class="form-control" placeholder="Pulse" />
                    </div>
                    <div class="ph-field dialysis-field dl-span-all">
                        <label for="txtPostComments">Comments</label>
                        <textarea id="txtPostComments" class="form-control" placeholder="Enter any additional comments or observations" rows="4"></textarea>
                    </div>
                </div>
            </section>

            <div class="dl-actionbar">
                <button type="button" class="dl-btn dl-btn-quiet dl-btn-back" id="btnBackToStep2"><i class="fa fa-arrow-left"></i> Back</button>
                <button type="button" class="dl-btn dl-btn-quiet" onclick="newForm()"><i class="fa fa-file-o"></i> New</button>
                <button type="button" class="dl-btn dl-btn-quiet" onclick="viewList()"><i class="fa fa-list"></i> List</button>
                <button type="button" class="dl-btn dl-btn-success" id="btnSaveStep3"><i class="fa fa-check"></i> Save</button>
            </div>
        </div>

        <!-- Existing Patient Search Modal -->
        <div id="PatientsSearchModel" class="modal fade dl-modal" data-backdrop="static" tabindex="-1" role="dialog">
            <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Select Patient</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <div class="dl-search-bar">
                            <div class="dl-search-field">
                                <label for="txtPatientSearch">Search Patient</label>
                                <input type="text" id="txtPatientSearch" class="form-control" autocomplete="off" placeholder="Enter patient name or MR No." />
                            </div>
                        </div>
                        <div class="dl-table-scroll">
                            <table class="table" id="tblPatientsResult">
                                <thead>
                                    <tr>
                                        <th style="display: none;">Patient ID</th>
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
                        <button type="button" class="dl-btn dl-btn-quiet" data-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- New Patient Registration Modal -->
        <div id="PatientModel" class="modal fade dl-modal" tabindex="-1" role="dialog">
            <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Patient Details</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>

                    <div class="modal-body">
                        <div class="ph-grid">
                            <div class="ph-field">
                                <label for="txt_Mrno">MR No</label>
                                <input type="text" id="txt_Mrno" class="form-control" disabled />
                            </div>
                            <div class="ph-field">
                                <label for="ddl_name">Title<span class="required">*</span></label>
                                <select id="ddl_name" class="form-control">
                                    <option value="Mr.">Mr.</option>
                                    <option value="Mrs.">Mrs.</option>
                                    <option value="Ms.">Ms.</option>
                                    <option value="B/O.">B/O.</option>
                                </select>
                            </div>
                            <div class="ph-field ph-span-2">
                                <label for="txt_name">Patient Name<span class="required">*</span></label>
                                <input name="dob" type="text" id="txt_name" class="form-control" placeholder="First Name" />
                            </div>

                            <div class="ph-field">
                                <label for="ddlRelation">Relation<span class="required">*</span></label>
                                <select id="ddlRelation" class="form-control">
                                    <option value="S/O">S/O</option>
                                    <option value="W/O">W/O</option>
                                    <option value="D/O">D/O</option>
                                </select>
                            </div>
                            <div class="ph-field ph-span-2">
                                <label for="txt_relation">Relation Name</label>
                                <input type="text" id="txt_relation" class="form-control" placeholder="Relation Name" />
                            </div>
                            <div class="ph-field">
                                <label for="ddl_Gender">Gender<span class="required">*</span></label>
                                <select id="ddl_Gender" class="form-control">
                                    <option value="0">Select Gender</option>
                                </select>
                            </div>

                            <div class="ph-field">
                                <label for="PrefixAge">Age / DOB<span class="required">*</span></label>
                                <select id="PrefixAge" class="form-control">
                                    <option value="Year">Year</option>
                                    <option value="Month">Month</option>
                                    <option value="Day">Day</option>
                                </select>
                            </div>
                            <div class="ph-field">
                                <label for="txt_dob">Date of Birth</label>
                                <input type="text" id="txt_dob" class="form-control" placeholder="DOB" onchange="CalculateDateOfBirth();" />
                            </div>
                            <div class="ph-field">
                                <label for="txtAge_yearss">Age</label>
                                <input type="text" id="txtAge_yearss" class="form-control" placeholder="dd mmyy" />
                            </div>
                            <div class="ph-field">
                                <label for="ddl_status">Marital Status<span class="required">*</span></label>
                                <select id="ddl_status" class="form-control">
                                    <option value="0">Select Marial</option>
                                </select>
                            </div>

                            <div class="ph-field">
                                <label for="txt_cnic">CNIC<span class="required">*</span></label>
                                <input type="text" id="txt_cnic" class="form-control" />
                            </div>
                            <div class="ph-field">
                                <label for="txt_mobile">Mobile<span class="required">*</span></label>
                                <input type="text" id="txt_mobile" class="form-control" />
                            </div>
                            <div class="ph-field">
                                <label for="ddlCountry">Country</label>
                                <select id="ddlCountry" class="form-control">
                                    <option value="0">Select Country</option>
                                </select>
                            </div>
                            <div class="ph-field">
                                <label for="ddl_Province">Province</label>
                                <select id="ddl_Province" class="form-control">
                                    <option value="0">Select Province</option>
                                </select>
                            </div>

                            <div class="ph-field">
                                <label for="txtcity">City</label>
                                <select id="txtcity" class="form-control">
                                    <option value="0">Select City</option>
                                </select>
                            </div>
                            <div class="ph-field">
                                <label for="txtarea">Area</label>
                                <select id="txtarea" class="form-control">
                                    <option value="0">Select Area</option>
                                </select>
                            </div>
                            <div class="ph-field ph-span-2">
                                <label for="txt_house">Address</label>
                                <input type="text" id="txt_house" class="form-control" />
                            </div>
                            <div class="ph-field" style="display: none">
                                <label for="txtCardFee">Fee<span class="required">*</span></label>
                                <input type="text" tabindex="17" id="txtCardFee" class="form-control" />
                            </div>
                        </div>
                    </div>

                    <div class="modal-footer">
                        <button type="button" class="dl-btn dl-btn-quiet" data-dismiss="modal">Close</button>
                        <button type="button" class="dl-btn dl-btn-outline" id="updatePatient_Data" onclick="SavePatient();">Update</button>
                        <button type="button" class="dl-btn dl-btn-primary" id="SavePatient_Data" onclick="SavePatient();">Save</button>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <script type="text/javascript">
        $(function () {
            // header badge: "Editing" when the page is opened for an existing session (?ID=...)
            if (new URLSearchParams(window.location.search).get('ID')) {
                $('#dlMode').html('<i class="fa fa-pencil"></i> Editing session');
            }
            // vitals table: show the empty message whenever there are no rows
            var vitalBody = document.getElementById('vitalSignsBody');
            function syncVitalEmpty() { $('#vitalEmpty').toggle(vitalBody.children.length === 0); }
            if (vitalBody && window.MutationObserver) {
                new MutationObserver(syncVitalEmpty).observe(vitalBody, { childList: true });
            }
            syncVitalEmpty();
        });
    </script>
</asp:Content>
