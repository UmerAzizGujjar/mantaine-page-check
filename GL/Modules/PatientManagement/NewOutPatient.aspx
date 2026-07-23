<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="NewOutPatient.aspx.cs" Inherits="PMS.Modules.PatientManagement.NewOutPatient" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/NewOutPatient.css" rel="stylesheet" />

    <script id="ScriptmanageSymptomsModal">

        $(document).on('input', '#symptomSearch', function () {
            const searchTerm = $(this).val().trim();
            const selectedValue = $('#departments').val();
            const selectedText = $('#departments').find('option:selected').text();
            console.log(searchTerm);
            fillSymptomsInModal(selectedValue, searchTerm);
        });
        function fillSymptomsInModal(selectedValue, searchTerm) {
            var options = '';

            $.ajax({
                type: "POST",
                url: "NewOutPatient.aspx/GetSymptoms",
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
                        $('#btnSaveNewComplaint').attr('disabled', false);
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
                url: 'NewOutPatient.aspx/GetSymptomsData',
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
        var SharingPolicy;
        function LoadSharingPolicy() {

            $.ajax({
                type: "POST",
                url: "NewOutPatient.aspx/GetSharingPolicy",
                data: JSON.stringify({}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    SharingPolicy = JSON.parse(response.d);
                },
                error: function (error) {
                    console.error("Error fetching items", error);
                }
            });
        }
        function saveSymptomsToDatabase() {
            $('#btnSaveSymptoms').attr('disabled', true);
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
                    url: "NewOutPatient.aspx/SaveSymptoms",
                    data: JSON.stringify({ symptoms: symptomsData }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        $('#btnSaveSymptoms').attr('disabled', false);
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
                        $('#btnSaveSymptoms').attr('disabled', false);
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
                $('#btnSaveSymptoms').attr('disabled', false);
                Swal.fire({
                    icon: 'warning',
                    title: 'No Data',
                    text: 'No symptoms to save',
                    showConfirmButton: false,
                    timer: 2000
                });
            }
        }
    </script>
    <script id="DocumentReady">
        $(document).ready(function () {
            loadPolicyVisibility();
            makeSelectsSelect2();
            loaddoctor_byDep();
            LoadSharingPolicy();
            var id = '<%=Request.QueryString["ID"]%>';
            var formType = '<%=Request.QueryString["Type"]%>';
            var inPatientID = '<%=Request.QueryString["InPatientID"]%>';
            globalFormType = formType;

            if (formType == "InPatientDischarge" && id != "") {
                $('#<%= hdfPatient_ID.ClientID %>').val(inPatientID);
                $('#<%= hdfInPatientID.ClientID %>').val(inPatientID);
                $('#<%= hdfFormType.ClientID %>').val('InPatientDischarge');
                $('#<%= hdfOutPatientID.ClientID %>').val(id);
                $('#<%= txtOut_Patient_ID.ClientID%>').val(inPatientID);
                loadPatientFormData(id);
                loaddoctor(id);
                $('#btnSave').val("Update");
                AppendSymtompsHistory();
                LoadMedicines();
                AppendPrimaryDiagnosisHistory();
                AppendFinalDiagnosisHistory();
                AppendComplaintsHistory();
                updateHistoryTable();
                LoadLabResultrpt();
                LoadServices();

                $('.exam-row input[type="checkbox"]').each(function () {
                    var param = this.id.split('_chk').pop();
                    if (this.checked) {
                        Add_GeneralExamRow(param);
                    }
                });
            }
            else if (formType == "InPatientDischarge" && inPatientID != "") {
                $('#<%= hdfPatient_ID.ClientID %>').val(inPatientID);
                $('#<%= hdfInPatientID.ClientID %>').val(inPatientID);
                $('#<%= hdfFormType.ClientID %>').val('InPatientDischarge');
                $('#ctl00_MainContent_txtOut_Patient_ID').val(inPatientID);
                $('#<%= txtOut_Patient_ID.ClientID%>').val(inPatientID);
                loadInPatientFormData(inPatientID);
            }
            else if (id != "") {
                $('#<%= txtOut_Patient_ID.ClientID%>').val(id);
                loadPatientFormData(id);
                loaddoctor(id);
                $('#btnSave').val("Update");
                AppendSymtompsHistory();
                Appendtestintable();
                LoadMedicines();
                AppendPrimaryDiagnosisHistory();
                AppendFinalDiagnosisHistory();
                AppendComplaintsHistory();
                updateHistoryTable();
                LoadLabResultrpt();
                LoadServices();

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
            $("#ctl00_MainContent_txtLMP").datepicker();
            $('.labtest_checkbox').hide();
            $('#06').click();
            fillDepartment();
            fillFilterClinic();
            filldoc();
            loadAllDoctor();
            FillMainTestDepartment();

            FillLabTests('');
            fillComplaints("");
            fillPrimaryDiagnosis("");
            fillFinalDiagnosis("");
            FillMedicene("");
            updateHistoryTable();
            updateDisposalTable();
            updateSystematicExamTable();
            loadDepartments();
            GetSymptomsByDepartment();
            fillSymptoms("000", "");
            $("#ctl00_MainContent_FollowNoDate").datepicker();
            $('#dvtblSymtomps').slideUp();
            $('#filterExaminations').change(filterExaminations);

            $('#tab01Search').on('input', function () {
                const searchTerm = $(this).val().trim();
                const selectedValue = $('#filterDepartments').val();
                fillSymptoms(selectedValue, searchTerm);
            });
            $('#tab06Search').on('input', function () {
                const searchTerm = $(this).val().trim();
                fillComplaints(searchTerm);
            });
            $('#tabServiceSearch').on('input', function () {
                const searchTerm = $(this).val().trim();
                FillServices(searchTerm);
            });
            FillServices('');
            $('#tab07Search').on('input', function () {
                const searchTerm = $(this).val().trim();
                fillPrimaryDiagnosis(searchTerm);
            });
            $('#tab08Search').on('input', function () {
                const searchTerm = $(this).val().trim();
                fillFinalDiagnosis(searchTerm);
            });
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
            $('#ctl00_MainContent_ddlPatientDepartment').on("change", function () {
                var selectedText = $(this).find('option:selected').text();

                if (selectedText === 'Filter Clinic') {
                    $('#divFilterClinic').slideDown();
                }
                else {
                    $('#divFilterClinic').slideUp();
                }

                fillPendingPatientsList();
            });
            $('#isPrivate').on('change', function () {
                if ($(this).is(':checked')) {
                    $('#divdocname').slideDown();
                    $('#divFilterClinic').slideUp();
                } else {
                    $('#divdocname').slideUp();

                    var selectedText = $('#ctl00_MainContent_ddlPatientDepartment').find('option:selected').text();

                    if (selectedText === 'Filter Clinic') {

                        $('#divFilterClinic').slideDown();
                    } else {

                        $('#divFilterClinic').slideUp();
                    }
                }
            });
            $('#<%= ddlDoctorName.ClientID %>, #<%= ddlIssuance_Of.ClientID %>, #<%= ddlFOllowUpWeeks.ClientID %>, #<%= ddlFOllowUp.ClientID %>').change(function () {
                updateFollowUpTable();
            });
            $('#<%= FollowNoDate.ClientID %>').on('change blur', function () {
                updateFollowUpTable();
            });
            $(document).on('input', '.history-row textarea, .history-row input[type="text"]', function () {
                updateHistoryTable();
            });
            $(document).on('input', '.Disposal-row textarea, .Disposal-row input[type="text"]', function () {
                updateDisposalTable();
            });

            $(document).on('input', '.Systematic-Exam-Row textarea, .Systematic-Exam-Row input[type="text"]', function () {
                updateSystematicExamTable();
            });
            $('#filterDepartments').change(function () {
                const selectedValue = $(this).val();
                const searchTerm = $('#tab01Search').val().trim();
                fillSymptoms(selectedValue, searchTerm);
            });
            $('#ctl00_MainContent_txtInputBox1').on('input', function () {
                const inputVal = $(this).val().trim();
                const examName = 'CustomInput';
                const $existingRow = $(`#tblGeneralExam tbody tr[data-exam="${examName}"]`);

                if (inputVal === '') {
                    // If input is empty, remove the row
                    if ($existingRow.length > 0) {
                        $existingRow.remove();
                    }

                    // Hide table if it's empty
                    if ($('#tblGeneralExam tbody tr').length === 0) {
                        $('#divtblGeneralExam').slideUp();
                    }

                    return;
                }

                if ($existingRow.length > 0) {
                    // Update existing row
                    $existingRow.find('td:first').text(inputVal);
                } else {
                    // Add new row
                    const $row = $(`
          <tr data-exam="${examName}">
              <td>${inputVal}</td>
              <td>
                  <a href="javascript:void(0)" onclick="Remove_CustomInputRow()" class="remove-input">
                      <i class="fa fa-times"></i>
                  </a>
              </td>
          </tr>
      `);
                    $('#tblGeneralExam tbody').append($row);
                }

                // Show table
                $('#divtblGeneralExam').slideDown();
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
            FillTestsByCategory('002', "");
            //refer Tab working
            const $patientCategory = $('#ctl00_MainContent_ddlPatient_Main_Category');
            const $doctorsDropdown = $('#ctl00_MainContent_ddldoctors');
            const $referTextbox = $('.refer-textbox');
            const $referTable = $('#tblRefer tbody');
            const $divRefer = $('#divtblRefer');
            const ROW_DEPARTMENT = 0;
            const ROW_DOCTOR = 1;
            const ROW_NOTE = 2;
            function initializeTable() {

                while ($referTable.find('tr').length < 3) {
                    $referTable.append('<tr style="display:none"><td></td></tr>');
                }
            }
            function updateTableVisibility() {
                const hasContent = $referTable.find('td').text().trim() !== '';

                if (hasContent) {
                    if ($divRefer.is(':hidden')) {
                        $divRefer.slideDown(300);
                    }
                } else {
                    if ($divRefer.is(':visible')) {
                        $divRefer.slideUp(300);
                    }
                }
            }
            $patientCategory.on('change', function () {
                const selectedValue = $(this).val();
                const selectedText = $(this).find('option:selected').text();

                initializeTable();
                const $deptRow = $referTable.find(`tr:eq(${ROW_DEPARTMENT})`);

                if (selectedValue && selectedValue !== "0") {
                    $deptRow.find('td').text("Department: " + selectedText);
                    $deptRow.slideDown();
                } else {
                    $referTextbox.empty();
                    $referTable.empty();
                    $divRefer.slideUp();
                    return;
                }

                updateTableVisibility();
            });
            $doctorsDropdown.on('change', function () {
                if ($patientCategory.val() === "0") return;

                initializeTable();
                var $doctorRow = $referTable.find(`tr:eq(${ROW_DOCTOR})`);
                var selectedValue = $(this).val();
                var selectedText = $(this).find('option:selected').text();

                if (selectedValue && selectedValue !== "0") {
                    // Update doctor row
                    $doctorRow.find('td').text("Doctor: " + selectedText);
                    $doctorRow.slideDown();
                } else {
                    // Remove doctor row

                    $doctorRow.find('td').empty();
                    $doctorRow.slideUp();
                }

                updateTableVisibility();
            });
            $referTextbox.on('input', function () {
                if ($patientCategory.val() === "0") return;

                initializeTable();
                const $noteRow = $referTable.find(`tr:eq(${ROW_NOTE})`);
                const inputValue = $(this).val().trim();

                if (inputValue) {
                    $noteRow.find('td').text("Note: " + inputValue);
                    $noteRow.slideDown();
                } else {
                    $noteRow.find('td').empty();
                    $noteRow.slideUp();
                }

                updateTableVisibility();
            });
            $('.modern-table').each(function () {
                const observer = new MutationObserver(function (mutations) {
                    mutations.forEach(function (mutation) {
                        if (mutation.addedNodes.length > 0 || mutation.removedNodes.length > 0) {
                            const $table = $(mutation.target).closest('table');
                            $table.attr('tabindex', '-1')
                                .get(0)
                                .scrollIntoView({ behavior: 'smooth', block: 'nearest' });
                        }
                    });
                });

                observer.observe(this, {
                    childList: true,
                    subtree: true
                });
            });
            if (formType == "InPatientDischarge") {
                hideInPatientDischargeElements();
                setTimeout(hideInPatientDischargeElements, 500);
            }
        });
    </script>
    <script id="functions" type="text/javascript">
        var globalFormType = '';
        function loadPolicyVisibility() {
            $.ajax({
                type: "POST",
                url: "NewOutPatient.aspx/GetSidebarPolicy",  
                data: '{}',  
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    
                    var policyNames = (typeof response.d === "string") ? JSON.parse(response.d) : response.d;

                    if (policyNames && policyNames.length > 0) {
                        $.each(policyNames, function (index, val) {
                            
                            $('div[name="' + val + '"]').show();
 
                        });
                    }
                },
                error: function (xhr, status, error) {
                    console.error("AJAX Error: " + status + " - " + error);
                }
            });
        }
        function loadPatientFormData(patientId) {
            // Show loading indicator
            showLoading();

            $.ajax({
                type: "POST",
                url: "NewOutPatient.aspx/GetPatientFormData",
                data: JSON.stringify({ PatientID: patientId }),
                contentType: "application/json; charset=utf-8",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    hideLoading();

                    var result = JSON.parse(response.d);

                    if (result.success) {
                        populatePatientForm(result.data);
                        if (result.data.Discharge == "true") {

                            $('#btnSave').hide();
                            $('.mybutton2-wrapper').hide();
                        }
                        if (globalFormType === 'InPatientDischarge') {
                            $('#btnSave').show();
                            $('#btnSave').val("Update");
                            $('.mybutton2-wrapper').show();
                            var inPatID = $('#<%= hdfInPatientID.ClientID %>').val();
                            if (inPatID) {
                                // Restore txtOut_Patient_ID to InPatientID (populatePatientForm overwrites it with OutPatientID)
                                $('#ctl00_MainContent_txtOut_Patient_ID').val(inPatID);
                                $('#<%= txtOut_Patient_ID.ClientID %>').val(inPatID);
                                loadInPatientFormData(inPatID);
                            }
                        }
                    } else {
                        alert("Error: " + result.message);
                    }
                },
                error: function (xhr, status, error) {
                    hideLoading();
                    console.error("AJAX Error: ", error);
                    alert("Failed to load patient data. Please try again.");
                }
            });
        }

        function populatePatientForm(data) {
            try {
                // Helper function to set value safely
                function setValue(controlId, value) {
                    var element = document.getElementById(controlId);
                    if (!element) return;  // Exit if element not found

                    if (element.type === 'checkbox') {
                        element.checked = value === 'true' || value === true;
                    }
                    else if (element.tagName.toLowerCase() === 'span') {  // Check tag name instead of type
                        element.textContent = value || '';  // Fixed assignment and used textContent
                    }
                    else if (element.value !== undefined) {  // For other input elements
                        element.value = value || '';
                    }
                    else {  // Fallback for other elements
                        element.textContent = value || '';
                    }
                }

                // Helper function to set dropdown value
                function setDropdownValue(controlId, value) {
                    var element = document.getElementById(controlId);
                    if (element && value) {
                        element.value = value;
                        // Trigger change event if needed
                        $(element).trigger('change');
                    }
                }

                // Basic Patient Information
                setValue('ctl00_MainContent_vlblPatients_Name', data.PatientName);
                setValue('ctl00_MainContent_vLbl_Age', data.Age);
                setValue('ctl00_MainContent_vLbl_Contact', data.Contact);
                setValue('ctl00_MainContent_vLbl_Adress', data.Address);
                setValue('ctl00_MainContent_txtOut_Patient_ID', data.OutPatientId);
                setValue('ctl00_MainContent_hdfPatient_ID', data.PatientId);
                setValue('ctl00_MainContent_hdfReg_ID', data.RegId);

                // Doctor Selection
                setDropdownValue('ctl00_MainContent_ddlDoctorName', data.DoctorId);

                // Vital Signs
                setValue('ctl00_MainContent_txtPuls', data.Pulse);
                setValue('ctl00_MainContent_txtBP', data.BP);
                setValue('ctl00_MainContent_txtTemp', data.Temperature);
                setValue('ctl00_MainContent_txtRespiration', data.Respiration);
                setValue('ctl00_MainContent_txtHeight', data.Height);
                setValue('ctl00_MainContent_txtWeight', data.Weight);
                setValue('ctl00_MainContent_txtspo2', data.SPO2);
                setValue('ctl00_MainContent_txtBMI', data.BMI);
                setValue('ctl00_MainContent_TxtBSR', data.BSR);
                setValue('ctl00_MainContent_txtMUAC', data.MUAC);
                setValue('ctl00_MainContent_txtOFC', data.OFC);

                // Medical History
                setValue('ctl00_MainContent_txtLMP', data.LMP);
                setValue('ctl00_MainContent_txtedd', data.EDD);
                setValue('ctl00_MainContent_txtDevelopmentHistory', data.DevelopmentHistory);
                setValue('ctl00_MainContent_txtVaccinationHistory', data.VaccinationHistory);
                setValue('ctl00_MainContent_txtNutritionHistory', data.NutritionHistory);
                setValue('ctl00_MainContent_txtHistoryOfPeresentIllness', data.HistoryOfPresentIllness);
                setValue('ctl00_MainContent_txtHistoryOfFamily', data.HistoryOfFamily);
                setValue('ctl00_MainContent_txtHistoryOfPastIllness', data.HistoryOfPastIllness);
                setValue('ctl00_MainContent_txtSocioEconomicHistory', data.SocioEconomicHistory);
                setValue('ctl00_MainContent_txtObstetricHistory', data.ObstetricHistory);
                setValue('ctl00_MainContent_txtAllergiesHistory', data.AllergiesHistory);
                setValue('ctl00_MainContent_txtTreatmentHistory', data.TreatmentHistory);
                setValue('ctl00_MainContent_txtDrugHistory', data.DrugHistory);
                setValue('ctl00_MainContent_txtPersonalHistory', data.PersonalHistory);
                setValue('ctl00_MainContent_txtBirthHistory', data.BirthHistory);

                // Physical Examination
                setValue('ctl00_MainContent_txtCVS', data.CVS);
                setValue('ctl00_MainContent_txtGIT', data.GIT);
                setValue('ctl00_MainContent_txtRESP', data.RESP);
                setValue('ctl00_MainContent_txtCNS', data.CNS);
                setValue('ctl00_MainContent_txtGYNAE', data.GYNAE);
                setValue('ctl00_MainContent_txtUGS', data.UGS);
                setValue('ctl00_MainContent_txtLocal', data.Local);
                setValue('ctl00_MainContent_txtMucculor', data.Muscular);
                setValue('ctl00_MainContent_txtAbdomin', data.Abdominal);

                // General Examination Checkboxes
                setValue('ctl00_MainContent_chkPallor', data.Pallor);
                setValue('ctl00_MainContent_chkJVP', data.JVP);
                setValue('ctl00_MainContent_chkCyanosis', data.Cyanosis);
                setValue('ctl00_MainContent_chkDisoriented', data.Disoriented);
                setValue('ctl00_MainContent_chkJaundice', data.Jaundice);
                setValue('ctl00_MainContent_chkDehydration', data.Dehydration);
                setValue('ctl00_MainContent_chkEdema', data.Edema);
                setValue('ctl00_MainContent_chkLymphadenopathy', data.Lymphadenopathy);
                setValue('ctl00_MainContent_chkClubbing', data.Clubbing);
                setValue('ctl00_MainContent_chkDyspnoea', data.Dyspnoea);
                setValue('ctl00_MainContent_chkNeckSwelling', data.NeckSwelling);
                setValue('ctl00_MainContent_chkSkinLesions', data.SkinLesions);

                // Special Checkboxes
                setValue('ctl00_MainContent_chkDRE', data.DRE);
                setValue('ctl00_MainContent_chkProctoscopy', data.Proctoscopy);

                // Diagnosis and Treatment
                setValue('ctl00_MainContent_txtProvisionalDiagnosis', data.ProvisionalDiagnosis);
                setValue('ctl00_MainContent_txtFinalDiagnosis', data.FinalDiagnosis);
                setValue('ctl00_MainContent_Final_Rec', data.FinalRecommendation);
                setValue('ctl00_MainContent_txtAdvice', data.Advice);
                setValue('ctl00_MainContent_txtRefer_To_Hospital', data.ReferToHospital);
                setValue('ctl00_MainContent_txtDesignation', data.Designation);
                // Gynecology Findings
                setValue('ctl00_MainContent_txtPA_Gynae', data.PA_Gynae);
                setValue('ctl00_MainContent_txtPS_Gynae', data.PS_Gynae);
                setValue('ctl00_MainContent_txtUterus_Gynae', data.Uterus_Gynae);
                setValue('ctl00_MainContent_txtFX_Gynae', data.FX_Gynae);

                // Obstetrics Findings
                setValue('ctl00_MainContent_txtPS_Obs', data.PS_Obs);
                setValue('ctl00_MainContent_txtPV_Obs', data.PV_Obs);
                setValue('ctl00_MainContent_txtSFH_Obs', data.SFH_Obs);
                setValue('ctl00_MainContent_txtLIE_Obs', data.LIE_Obs);
                setValue('ctl00_MainContent_txtPresentation_Obs', data.Presentation_Obs);
                setValue('ctl00_MainContent_txtFHR_Obs', data.FHR_Obs);
                setValue('ctl00_MainContent_txtEngagement_Obs', data.Engagement_Obs);

                // Dropdowns
                setDropdownValue('ctl00_MainContent_ddlIssuance_Of', data.IssuanceOf);
                setDropdownValue('ctl00_MainContent_ddlFOllowUp', data.FollowUp);
                setDropdownValue('ctl00_MainContent_ddlFOllowUpWeeks', data.FollowUpWeek);

                setDropdownValue('ctl00_MainContent_ddlVerbalConsent', data.Verbal_Consent);
                setDropdownValue('ctl00_MainContent_ddlPatient_Main_Category', data.PatientMainCategory);
                setValue('ctl00_MainContent_txtRefferNote', data.ReferNote);



                // Dates
                setValue('ctl00_MainContent_FollowNoDate', data.FollowDate);

                // Additional Fields
                setValue('ctl00_MainContent_txtInputBox1', data.InputBox1);

                setValue('ctl00_MainContent_txtRemarksHistory', data.RemarksHistory);
                //Voucher
                setValue('ctl00_MainContent_hdnVoucher_id', data.hdnVoucher_id);
                setValue('ctl00_MainContent_hdnStatus', data.hdnStatus);

                // Hidden Fields
                setValue('ctl00_MainContent_hdfdhischarge', data.Discharge);
                Load_Proto();
                updateDisposalTable();
                updateHistoryTable();
                // Show success message
                AddVitals();
                setDropdownValue('ctl00_MainContent_ddldoctors', data.referDoc);
                setValue('ctl00_MainContent_chkHypertensive', data.Hypertensive);
                setValue('ctl00_MainContent_chkSmokers', data.Smokers);
                setValue('ctl00_MainContent_chkNon_Smokers', data.Non_Smokers);
                setValue('ctl00_MainContent_chkDiabetics', data.Diabetics);
                setValue('ctl00_MainContent_chkAlcoholConsumption', data.Alcohol_Consumption);
                setValue('ctl00_MainContent_chkSmokeless', data.Smokeless);
                setValue('ctl00_MainContent_chkDM', data.DM);
                setValue('ctl00_MainContent_chkHTN', data.HTN);
                setValue('ctl00_MainContent_chkTB', data.TB);
                setValue('ctl00_MainContent_chkIHD', data.IHD);
                setValue('ctl00_MainContent_chkAsthma', data.Asthma);

            } catch (error) {
                console.error("Error populating form: ", error);
                alert("Error populating form data. Please check console for details.");
            }
        }
        function InsertLabResult() {
            debugger;

            var ResultrptVal = $('#ctl00_MainContent_ddlLabResult').find('option:selected').val();
            var ResultrptName = $('#ctl00_MainContent_ddlLabResult').find('option:selected').text();
            if (ResultrptVal != "0") {

                var currentDate = new Date();
                var formattedDates = $.datepicker.formatDate('dd M yy', currentDate);

                var rows = '';
                rows += '<tr>' +
                    '<td><input type="hidden" name="txtLabResultrpt" value="' + ResultrptVal + '"> ' + ResultrptName + '</td>' +
                    '<td><input type="text" name="txtResultName" style="width: 80px !important;"></td>' +
                    '<td><input type="text" class="datepicker" name="txtResulDate" style="width: 85px !important;" value="' + formattedDates + '"></td>' +
                    '<td><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td>' +
                    '</tr>';
                $('#tblResultrpt tbody').append(rows);
                $('#tblResultrpt .datepicker').datepicker({ dateFormat: 'dd M yy' });

                // Show the table div
                $('#dvtblResultrpt').show();

                $('#ctl00_MainContent_ddlLabResult').val("0");
            }
        }

        function SaveLabResult(callback) {
            console.log('SaveLabResult called');
            try {
                var table = $('#tblResultrpt');
                var tblResultrpt = [];

                table.find('tbody tr').each(function (key, value) {
                    var resultDate = $(value).find('td input[name=txtResulDate]').val();
                    var resultObj = {
                        'Result_ID': $(value).find('td input[name=txtLabResultrpt]').val(),
                        'Result_Name': $(value).find('td input[name=txtResultName]').val()
                    };

                    if (resultDate !== "") {
                        resultObj.Result_Date = resultDate;
                    }

                    tblResultrpt.push(resultObj);
                });

                var btnsave = $('#btnSave').val();
                var PatID = $('#<%= hdfPatient_ID.ClientID%>').val();
                var OutPatID = $('#<%= txtOut_Patient_ID.ClientID%>').val();
                if (OutPatID == '(New)' || OutPatID == '')
                    OutPatID = 0;

                var ResulttrptDetail = { Pat: PatID, OutPatientID: OutPatID, Resulttrpt: tblResultrpt };

                console.log('SaveLabResult saving, OutPatID=', OutPatID);
                PageMethods.SaveLabResultrpt(btnsave, JSON.stringify(ResulttrptDetail), globalFormType, function (response) {
                    console.log('SaveLabResult completed');
                    if (callback) callback();
                });
            } catch (e) {
                console.error('SaveLabResult exception:', e);
                if (callback) callback();
            }
        }

function LoadLabResultrpt() {
            PageMethods.LoadLabResultrptDetail($('#<%= txtOut_Patient_ID.ClientID%>').val(), globalFormType, function (res) {
                var Medicines = JSON.parse(res);
                var rows = '';

                $.each(Medicines, function (key, value) {
                    var dateObj;

                    // ✅ Handle when ReslutDate is empty, null or undefined
                    if (!value.ReslutDate || value.ReslutDate === "") {
                        dateObj = new Date(); // current date
                    } else if (value.ReslutDate.includes("/Date(")) {
                        // Handle /Date(1234567890)/ format
                        var timestamp = parseInt(value.ReslutDate.replace("/Date(", "").replace(")/", ""));
                        dateObj = new Date(timestamp);
                    } else {
                        dateObj = new Date(value.ReslutDate);
                    }
                    var formattedDates = !isNaN(dateObj.getTime())
                        ? $.datepicker.formatDate('dd M yy', dateObj)
                        : $.datepicker.formatDate('dd M yy', new Date());

                    rows += '<tr>' +
                        '<td><input type="hidden" name="txtLabResultrpt" value="' + value.Lab_Resultrpt_ID + '"> ' + value.Lab_Resultrpt + '</td>' +
                        '<td><input type="text" name="txtResultName" style="width: 80px !important;" value="' + value.Lab_Resultrpt_Name + '"></td>' +
                        '<td><input type="text" class="datepicker" name="txtResulDate" style="width: 85px ! important;" value="' + formattedDates + '"></td>' +
                        '<td><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td>' +
                        '</tr>';
                });

                $('#tblResultrpt tbody').append(rows);
                $('#tblResultrpt .datepicker').datepicker({ dateFormat: 'dd M yy' });

                // Show table if there are records
                if (Medicines.length > 0) {
                    $('#dvtblResultrpt').show();
                }
            });
        }

        function deleteTest(anchorTag) {
            var row = $(anchorTag).closest('tr');
            row.remove();

            if ($('#tblResultrpt tbody tr').length === 0) {
                $('#dvtblResultrpt').hide();
            }
        }
        // Helper functions for loading indicators and messages
        function showLoading() {
            // Add your loading indicator here
            $('body').append(`
            <div class="modern-loading-overlay">
                <div class="loading-content">
                    <div class="loading-spinner">
                        <div class="spinner-ring"></div>
                        <div class="spinner-ring"></div>
                        <div class="spinner-ring"></div>
                    </div>
                    <div class="loading-text">Loading</div>
                    <div class="loading-subtext">Please wait while we prepare your content...</div>
                    <div class="progress-bar">
                        <div class="progress-fill"></div>
                    </div>
                </div>
                <div class="particle"></div>
                <div class="particle"></div>
                <div class="particle"></div>
                <div class="particle"></div>
            </div>
        `);
        }

        function PrintVoucher() {
            debugger;
            var id =  '<%=Request.QueryString["ID"]%>';
               var locationInfo = window.location;
               var url = '../../ReportViewer.aspx?ReportName=Voucher&ReportTitle=OPD Voucher&TransID=' + id + '&TransType=OPDShare';
               if (!locationInfo.origin.includes('localhost') || locationInfo.origin.includes('localhost')) {
                   var urlInfo = window.location.href.split('/');
                   var ip = urlInfo[2];
                   var foldername = urlInfo[3];
                   url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=OPD Voucher&TransID=' + id + '&TransType=OPDShare';
               }
               window.open(url, '_blank');
           }

        function hideLoading() {
            const overlay = document.querySelector('.modern-loading-overlay');
            if (overlay) {
                overlay.classList.add('fade-out');
                setTimeout(() => {
                    if (overlay && overlay.parentNode) {
                        overlay.parentNode.removeChild(overlay);
                    }
                }, 500); // Match this duration with your CSS transition time
            }
        }


        // Example usage:
        // Call this function with a patient ID to load the form
        // loadPatientFormData(123);
        function calculateBMI() {
            var height_in_cm = parseFloat($('#ctl00_MainContent_txtHeight').val());
            var weight_kg = parseFloat($('#ctl00_MainContent_txtWeight').val());


            if (isNaN(height_in_cm) || isNaN(weight_kg)) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please enter valid height and weight.',
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

            var height_m = height_in_cm / 100;
            var calcBMI = weight_kg / (height_m * height_m);

            $('#ctl00_MainContent_txtBMI').val(calcBMI.toFixed(2));
        }
        function ResetForm() {
            window.location.href = "NewOutPatient.aspx";
        }
        function loadInPatientFormData(inPatientID) {
            $.ajax({
                type: "POST",
                url: "NewOutPatient.aspx/GetInPatientFormData",
                data: JSON.stringify({ InPatientID: parseInt(inPatientID) }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var result = JSON.parse(response.d);
                    if (result.success) {
                        var data = result.data;
                        $('#<%= vlblPatients_Name.ClientID %>').text(data.PatientName);
                        $('#<%= vLbl_Age.ClientID %>').text(data.Age);
                        $('#<%= vLbl_Contact.ClientID %>').text(data.Contact);
                        $('#<%= vLbl_Adress.ClientID %>').text(data.Address);
                        $('#<%= hdfReg_ID.ClientID %>').val(data.RegId);
                        $('#<%= Label200.ClientID %>').text(data.MR_No);
                    }
                },
                error: function (xhr, status, error) {
                    console.error("Error loading InPatient data:", error);
                }
            });
        }
        function hideInPatientDischargeElements() {
            $('input[value="Queue"]').hide();
            $('input[value="Voucher"]').hide();
            $('input[value="Prescription"]').hide();
            $('#<%= dlblFollowNo.ClientID %>').closest('.row').hide();
            $('#<%= lblPatien_ID.ClientID %>').closest('.row').hide();
            // Hide Medical History section
            $('#<%= chkSmokers.ClientID %>').closest('.row.mb-3').prev('.row.mb-3').hide();
            $('#<%= chkSmokers.ClientID %>').closest('.row.mb-3').hide();
            $('#09, #10, #tab09, #tab10').hide();
            $('#dvtblResultrpt').hide();
        }
        function ShowHistory() {
            var reg_ID = $("#<%= hdfReg_ID.ClientID %>").val();
            if (reg_ID && reg_ID !== "(New)") {
                var locationInfo = window.location;
                var url = "/Dashboards/NewEMR.aspx?RegID=" + encodeURIComponent(reg_ID);
                if (!locationInfo.origin.includes('localhost') || locationInfo.origin.includes('localhost')) {
                    var urlInfo = window.location.href.split('/');
                    var ip = urlInfo[2];
                    var foldername = urlInfo[3];
                    url = 'http://' + ip + '/' + foldername + '/Dashboards/NewEMR.aspx?RegID=' + encodeURIComponent(reg_ID);
                }
                window.open(url, '_blank');
            } else {
                var locationInfo = window.location;
                var url = "/Dashboards/NewEMR.aspx";
                if (!locationInfo.origin.includes('localhost') || locationInfo.origin.includes('localhost')) {
                    var urlInfo = window.location.href.split('/');
                    var ip = urlInfo[2];
                    var foldername = urlInfo[3];
                    url = 'http://' + ip + '/' + foldername + '/Dashboards/NewEMR.aspx';
                }
                window.open(url, '_blank');
            }
        }


        function openQueue() {
            fillPendingPatientsList();
            $('#queueModal').modal('show');
        }
        function loadPatient(PatientID, opdNo, regPatID) {
            debugger;
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
                        var Mr_No = ReplaceNullWith_Space(data.Mr_No);
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
                        $('#<%= Label200.ClientID %>').text(Mr_No);
                        $("#<%= hdfPatient_ID.ClientID %>").val(PatientID);
                        $("#<%= hdfReg_ID.ClientID %>").val(regPatID);
                        FillPreviousLabTests();
                        FillPreviousMedicines();
                        FillPreviousServices();
                        FillPreviousDiagnosticTests();
                        $('#queueModal').modal('hide');
                    }
                },
                failure: function (response) {

                }
            });




        }
        function loaddoctor_byDep() {
            var depart = $('#ctl00_MainContent_ddlPatient_Main_Category').val();
            if (depart == 0) {
                depart = "";
            }

            PageMethods.LoadDoctor_bydep(depart, function (res) {
                var doctor = JSON.parse(res);
                var options = '<option value="0" >Please Select </option>';
                var rowsText = '';

                $.each(doctor, function (key, value) {
                    options += '<option value="' + value.Emp_ID + '" >' + value.Emp_Name + '</option>';
                });

                $('#ctl00_MainContent_ddldoctors').html(options)
                $('#ctl00_MainContent_ddldoctors').attr('disabled', false);
            });
        }
        function loadDepartments() {
            var User_ID = '<%= Session["UserId"] != null ? Session["UserId"].ToString() : "" %>';

            $.ajax({
                url: 'NewOutPatient.aspx/GetDepartment',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                data: JSON.stringify({}),
                success: function (res) {
                    var doctor = JSON.parse(res.d); // Parse the JSON string

                    var options =
                        '<option value="000">Default Symptoms</option>' +
                        '<option value="' + User_ID + '">Your Favourites</option>';

                    // ✅ Loop through 'doctor' not 'data'
                    $.each(doctor, function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                    });

                    $('#departments').html(options);
                    $('#departments').select2();
                    $('#filterDepartments').html(options);

                },
                error: function (xhr, status, error) {
                    console.error('Error loading departments:', error);
                }
            });
        }
        function FillMainTestDepartment() {

            var options = '';

            PageMethods.FillTestMainDepartment(function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#filterMainDepartments').html(options);
                $('#filterMainDepartments').select2();

            });
        }
        function LoadDesignation() {
            debugger;
            var DocID = $('#ctl00_MainContent_ddlDoctorName').val();
            PageMethods.LoadDesignation(DocID, function (res) {
                var doctor = JSON.parse(res);
                var rowsText = '';
                debugger;
                $('#ctl00_MainContent_txtDesignation').val(doctor.Emp_designatin);
                updateFollowUpTable();
            });
            ConfigureAvailableDates(DocID);

        }
        function ConfigureAvailableDates(DocID) {
            $.ajax({
                type: "POST",
                url: "NewOutPatient.aspx/GetAvailableDates",
                data: JSON.stringify({ DocID: DocID }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var availableDates = JSON.parse(response.d);

                    $("#ctl00_MainContent_FollowNoDate").datepicker("destroy"); // Remove any previous config

                    $("#ctl00_MainContent_FollowNoDate").datepicker({
                        dateFormat: "yy-mm-dd", // format to match your returned data
                        beforeShowDay: function (date) {
                            var dmy = $.datepicker.formatDate("yy-mm-dd", date);
                            if (availableDates.indexOf(dmy) !== -1) {
                                return [true, "available-date", "Doctor Available"];
                            } else {
                                return [false, "", "Doctor Not Available"];
                            }
                        }
                    });
                },
                error: function (xhr, status, error) {
                    console.error("Error fetching available dates:", error);
                }
            });
        }
        function loadAllDoctor() {
            PageMethods.loadAllDoc(function (res) {
                var doctor = JSON.parse(res);
                var options = '';
                var rowsText = '';

                $.each(doctor, function (key, value) {

                    options += '<option value="' + value.Emp_ID + '" >' + value.Emp_Name + '</option>';
                });

                $('#ctl00_MainContent_ddlDoctorName').html(options)

            });
        }
        function loaddoctor(id) {
            PageMethods.LoadDoctor(id, function (res) {
                var doctor = JSON.parse(res);
                var options = '';
                var rowsText = '';

                $.each(doctor, function (key, value) {

                    options += '<option value="' + value.Emp_ID + '" >' + value.Emp_Name + '</option>';
                });

                $('#ctl00_MainContent_ddlDoctorName').html(options)

            });
        }
        function makeSelectsSelect2() {
            const selector = '.select2-enable';

            const $elements = $(selector);

            if ($elements.length > 0) {
                $elements.select2();
            }
        }
        function fillPendingPatientsList() {

            var filterDepartment = $('#ctl00_MainContent_ddlPatientDepartment').val();
            var filterClinic = $('#ctl00_MainContent_ddlFilterClinic').val();
            var doc_name = $('#ctl00_MainContent_ddldocname').val();
            if (doc_name == "0") {
                doc_name = "";
            }
            if (filterDepartment == "0") {
                filterDepartment = "";
            }
            if (filterClinic == "0") {
                filterClinic = "";
            }
            
            PageMethods.PendingPatients(filterDepartment, filterClinic, doc_name, function (data) {
                debugger;
                var parsedData = JSON.parse(data);
                var rows = '';
                $.each(parsedData, function (key, value) {
                    debugger;
                    var TrnsDate = new Date(parseInt(value.Created_Time.substr(6)));
                    var retdate = moment(TrnsDate).format('LLLL');
                    var status = '';
                
       
                    if (value.Checked == null) {
                        status = 'Un Checked';
                    }
                    if (value.Checked != null) {
                        var rowColorStyle = (status = 'Checked') ? 'style="background-color: #aeffae;"' : '';
                    }

                    rows += '<tr ' + rowColorStyle + '> <td>' + value.Patient_No + '</td> <td> ' + value.Dep_token + ' </td>' + '<td>' + value.Full_Name + '</td> ' + '</td> ' + '<td>' + value.Age_years + '</td> ' + '<td>' + value.Department + '</td> ' + '<td>' + value.Dep_token + '</td>' +  '<td>' + value.DoctorName + '</td> ' + '<td>' + retdate + '</td> ' + '<td>' + value.UserName + '</td> ' + '<td>' + status + '</td>' + ' <td> <a href="javascript:void(0)" onclick=loadPatient(' + value.Patient_ID + ',' + value.Patient_No + ',' + value.Reg_PatId + ')><i class="fa fa-plus-circle fa-2x" ></i></a> </td> </tr>';
                });
                debugger;
                $('#tblPendingPatients tbody').html(rows);


                $(".se-pre-con").fadeOut("slow");

            }, function (exec) { })
        }

        function fillDepartment() {
            var options;
            PageMethods.GetAllDeparmtent(function (data) {
                debugger;
                var options = '<option value="0" >Filter By Department</option>';
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $("#ctl00_MainContent_ddlPatientDepartment").html(options);
            });
            return options;
        }
        function fillFilterClinic() {
            var options;
            PageMethods.GetAllFilterClinics(function (data) {
                debugger;
                var options = '<option value="0" >Filter Clinic</option>';
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $("#ctl00_MainContent_ddlFilterClinic").html(options);
                $("#ctl00_MainContent_ddlFilterClinic").select2();
            });
            return options;
        }
        function filldoc() {
            var options;
            PageMethods.Getdoctors(function (data) {
                debugger;
                var options = '<option value="0" >Filter By Doctor</option>';
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.Emp_ID + '" >' + value.Emp_Name + '</option>';
                });
                $("#ctl00_MainContent_ddldocname").html(options);
                $("#ctl00_MainContent_ddldocname").select2();
            });
            return options;
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
                url: 'NewOutPatient.aspx/GetCategorizedSymptoms',
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

        function ShowPreviousHistory() {
            const $divPreviousHistory = $('#InvestigationPreviousHistory');

            if ($divPreviousHistory.is(':visible')) {
                $divPreviousHistory.slideUp();
            } else {
                $divPreviousHistory.slideDown();
            }
        }
        function ShowMedicenePreviousHistory() {
            const $divPreviousHistory = $('#MedicenePreviousHistory');

            if ($divPreviousHistory.is(':visible')) {
                $divPreviousHistory.slideUp();
            } else {
                $divPreviousHistory.slideDown();
            }
        }
        function ShowDiagnosticsPreviousHistory() {
            const $divPreviousHistory = $('#DiagnosticsPreviousHistory');

            if ($divPreviousHistory.is(':visible')) {
                $divPreviousHistory.slideUp();
            } else {
                $divPreviousHistory.slideDown();
            }
        }
        function openManageSymptomsModal() {
            $('#manageSymptomsModal').modal('show');
        }
        function saveSymptom() {
            $('#btnSaveNewSymptom').attr('disabled', true);
            const SymptomText = $('#NewSymptom').val().trim();

            if (SymptomText === '') {
                $('#btnSaveNewSymptom').attr('disabled', false);
                alert('Please enter a Symptom before saving.');
                return;
            }
            else {
                $.ajax({
                    type: "POST",
                    url: "NewOutPatient.aspx/SaveNewSymptom",
                    data: JSON.stringify({ name: SymptomText }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        $('#btnSaveNewSymptom').attr('disabled', false);
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
                        $('#btnSaveNewSymptom').attr('disabled', false);
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
                $('#NewSymptom').val('');
            });
        }


        function AddVitals() {
            // Get all the input values using jQuery
            const pulse = $('#ctl00_MainContent_txtPuls').val();
            const bp = $('#ctl00_MainContent_txtBP').val();
            const temp = $('#ctl00_MainContent_txtTemp').val();
            const resp = $('#ctl00_MainContent_txtRespiration').val();
            const height = $('#ctl00_MainContent_txtHeight').val();
            const weight = $('#ctl00_MainContent_txtWeight').val();

            // Get the table body and container div
            const tbody = $('#tblVitals tbody');
            const tableContainer = $('#divtblVitals');

            // Clear existing rows
            tbody.empty();

            // Create new row with the vitals data
            const newRow = $('<tr>').html(`
        <td>${pulse || '-'}</td>
        <td>${bp || '-'}</td>
        <td>${temp || '-'}</td>
        <td>${resp || '-'}</td>
        <td>${height || '-'}</td>
        <td>${weight || '-'}</td>
    `);
            tbody.append(newRow);
            tableContainer.slideDown();
        }

        function updateHistoryTable() {
            const historyTable = $('#tblHistory tbody');
            const historyContainer = $('#divtblHistory');
            let hasData = false;

            // Clear existing rows
            historyTable.empty();

            // Process each history field
            $('.history-row').each(function () {
                const label = $(this).find('span').text().trim();
                const textbox = $(this).find('textarea, input[type="text"]');
                const value = textbox.val().trim();

                if (value) {
                    // Append new row with formatted text
                    historyTable.append(`
                <tr>
                    <td><strong>${label}:</strong> ${value}</td>
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

        function updateSystematicExamTable() {
            const SystematicExamTable = $('#SystematicExam tbody');
            const SystematicExam = $('#divtblSystematicExam');
            let hasData = false;

            // Clear existing rows (no animation here)
            SystematicExamTable.empty();

            // Process each examination field (original logic)
            $('.Systematic-Exam-Row').each(function () {
                const labelSpan = $(this).find('span[id*="_Label"]');
                const label = labelSpan.length ? labelSpan.text().trim() : '';

                const textbox = $(this).find('textarea, input[type="text"]');
                const value = textbox.length ? textbox.val().trim() : '';

                if (value) {
                    SystematicExamTable.append(`
                <tr>
                    <td><strong>${label}:</strong> ${value}</td>
                </tr>
            `);
                    hasData = true;
                }
            });

            // Only use slide effects for showing/hiding the container
            if (hasData) {
                if (SystematicExam.is(':hidden')) {
                    SystematicExam.slideDown(300); // Slide down to show
                }
                // If already visible, just leave it visible (no animation)
            } else {
                if (SystematicExam.is(':visible')) {
                    SystematicExam.slideUp(300); // Slide up to hide
                }
                // If already hidden, just leave it hidden
            }
        }

        function Add_GeneralExamRow(examName) {
            const $tableBody = $('#tblGeneralExam tbody');

            if ($tableBody.find(`tr[data-exam="${examName}"]`).length > 0) return;

            const $row = $(`
            <tr data-exam="${examName}">
                <td>${examName}</td>
                <td>
                    <a onclick="Remove_GeneralExamRow('${examName}')" class="remove-exam" data-exam="${examName}"><i class="fa fa-times"></i></a>
                </td>
            </tr>
        `);

            // Append to table
            $tableBody.append($row);

            // Show table container
            $('#divtblGeneralExam').slideDown();
        }
        function Remove_GeneralExamRow(examName) {
            // Remove the row
            $(`#tblGeneralExam tbody tr[data-exam="${examName}"]`).remove();

            // Uncheck the corresponding checkbox
            $(`input[type="checkbox"][onclick*="'${examName}'"]`).prop('checked', false);

            // Hide the table container if no rows
            if ($('#tblGeneralExam tbody tr').length === 0) {
                $('#divtblGeneralExam').slideUp();
            }
        }

        function AddNewComplaint() {
            const $divComplaint = $('#divAddNewComplaint');

            if ($divComplaint.is(':visible')) {
                // Hide with slide up animation
                $divComplaint.slideUp(300, function () {
                    $('#NewComplaint').val(''); // Clear input after hiding
                });
            } else {
                // Show with slide down animation
                $divComplaint.slideDown(300, function () {
                    $('#NewComplaint').focus(); // Focus input after showing
                });
            }
        }
        function saveComplaint() {
            $('#btnSaveNewComplaint').attr('disabled', true);
            const complaintText = $('#NewComplaint').val().trim();

            if (complaintText === '') {
                $('#btnSaveNewComplaint').attr('disabled', false);
                alert('Please enter a complaint before saving.');
                return;
            }
            else {
                $.ajax({
                    type: "POST",
                    url: "NewOutPatient.aspx/SaveNewComplaint",
                    data: JSON.stringify({ complaintText: complaintText }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        $('#btnSaveNewComplaint').attr('disabled', false);
                        if (response.d == "0") {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'Complaint already exists!',
                                showConfirmButton: false,
                                timer: 2000,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });
                        }
                        else {
                            fillComplaints("");
                        }
                    },
                    error: function (xhr, status, error) {
                        $('#btnSaveNewComplaint').attr('disabled', false);
                        console.error("Error searching symptoms:", error);
                    }
                });
            }
            // Hide the form with slide up animation after saving
            $('#divAddNewComplaint').slideUp(300, function () {
                $('#NewComplaint').val(''); // Clear input after hiding
            });
        }
        function Add_ComplaintRow(id, name) {
            var checkComplaintadded = false;
            $(".complainclass").each(function () {
                var complainid = $(this).val();
                if (complainid == id) {
                    checkComplaintadded = true;
                }
            });

            if (checkComplaintadded === false) {




                var html = '<tr> <td style="display:none;"> <input type="hidden" class="complainclass" value="' + id + '" />' + id + ' </td>' +
                    '<td> ' + name + ' </td>' +
                    '<td  > <a href="#" onclick="Remove_ComplaintRow(\'' + id + '\')"><i class="fa fa-times"></i></a></td></tr>';


                $('#tblComplaints tbody').append(html);
                $('#dvtblComplaints').slideDown();

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
        function Remove_ComplaintRow(id) {
            // Only uncheck the checkbox for the given id
            $('#chk_complaint_' + id).prop('checked', false);

            // Loop through rows to find and remove the matching one
            $('#tblComplaints tbody tr').each(function () {
                var row = $(this);
                var hiddenInput = row.find('input.complainclass');
                if (hiddenInput.val() === id) {
                    row.remove();
                    return false; // exit the loop early after removing
                }
            });

            // Hide the table if there are no more rows
            if ($('#tblComplaints tbody tr').length === 0) {
                $('#dvtblComplaints').slideUp();
            }
        }
        function fillComplaints(searchValue) {
            var options = '';
            $.ajax({
                url: 'NewOutPatient.aspx/GetComplaints',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                data: JSON.stringify({
                    searchValue: searchValue || ""
                }),
                success: function (response) {
                    var data = response.d ? JSON.parse(response.d) : response;
                    $.each(data, function (key, value) {

                        options += '<div class="complaint-row" style="display: flex; align-items: center; justify-content: space-between; cursor: pointer;" ' +
                            'onclick="document.getElementById(\'chk_complaint_' + value.ComplaintId + '\').click()">' +
                            '<div style="display: flex; align-items: center;">' +
                            '<input type="checkbox" id="chk_complaint_' + value.ComplaintId + '" ' +
                            'value="' + value.ComplaintId + '" ' +
                            'class="complaint_checkbox" ' +
                            'onclick="event.stopPropagation(); this.checked ? Add_ComplaintRow(\'' + value.ComplaintId + '\', \'' + value.ComplaintName + '\') : Remove_ComplaintRow(\'' + value.ComplaintId + '\')" />' +
                            '<label for="chk_complaint_' + value.ComplaintId + '" style="margin-left: 8px; cursor: pointer;">' + value.ComplaintName + '</label>' +
                            '</div>' +
                            '</div>';
                    });

                    $('#allComplaints').html(options);



                },
                error: function (xhr, status, error) {
                    console.error('Error fetching area data:', error);
                }
            });

            return options;
        }

        function AddNewPrimaryDiagnosis() {
            const $divComplaint = $('#divAddNewPrimaryDiagnosis');

            if ($divComplaint.is(':visible')) {
                // Hide with slide up animation
                $divComplaint.slideUp(300, function () {
                    $('#NewPrimaryDiagnosis').val(''); // Clear input after hiding
                });
            } else {
                // Show with slide down animation
                $divComplaint.slideDown(300, function () {
                    $('#NewPrimaryDiagnosis').focus(); // Focus input after showing
                });
            }
        }
        function savePrimaryDiagnosis() {
            $('#btnSaveNewPrimaryDiagnosis').attr('disabled', true);
            const Text = $('#NewPrimaryDiagnosis').val().trim();

            if (Text === '') {
                $('#btnSaveNewPrimaryDiagnosis').attr('disabled', false);
                alert('Please enter a Diagnosis before saving.');
                return;
            }
            else {
                $.ajax({
                    type: "POST",
                    url: "NewOutPatient.aspx/SaveNewDiagnosis",
                    data: JSON.stringify({ Text: Text }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        $('#btnSaveNewPrimaryDiagnosis').attr('disabled', false);
                        if (response.d == "0") {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'Diagnosis already exists!',
                                showConfirmButton: false,
                                timer: 2000,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });
                        }
                        else {
                            fillPrimaryDiagnosis("");
                            fillFinalDiagnosis("");
                        }
                    },
                    error: function (xhr, status, error) {
                        $('#btnSaveNewPrimaryDiagnosis').attr('disabled', false);
                        console.error("Error searching symptoms:", error);
                    }
                });
            }
            // Hide the form with slide up animation after saving
            $('#divAddNewPrimaryDiagnosis').slideUp(300, function () {
                $('#NewPrimaryDiagnosis').val(''); // Clear input after hiding
            });
        }
        function fillPrimaryDiagnosis(searchValue) {
            var options = '';
            $.ajax({
                url: 'NewOutPatient.aspx/GetDiagnosis',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                data: JSON.stringify({
                    searchValue: searchValue || ""
                }),
                success: function (response) {
                    var data = response.d ? JSON.parse(response.d) : response;
                    $.each(data, function (key, value) {
                        options += '<div class="Primary-Diagnosis-row" style="display: flex; align-items: center; justify-content: space-between;">' +
                            '<div style="display: flex; align-items: center; width: 100%">' +
                            '<input type="checkbox" id="chk_Primary_Diagnosis_' + value.DiagnosisId + '" ' +
                            'value="' + value.DiagnosisId + '" ' +
                            'class="Primary_Diagnosis_checkbox" ' +
                            'onclick="var textarea = document.getElementById(\'txtPrimaryDiagnosis_' + value.DiagnosisId + '\'); ' +
                            'this.checked ? handlePrimaryDiagnosisRow(\'' + value.DiagnosisId + '\', \'' + (value.DiagnosisName || '').replace(/'/g, "\\'") + '\') ' +
                            ': removePrimaryDiagnosisRow(\'' + value.DiagnosisId + '\')" />' +
                            '<label for="chk_Primary_Diagnosis_' + value.DiagnosisId + '" style="margin-left: 8px; width: 25%;">' + (value.DiagnosisName || '') + '</label>' +
                            '<textarea class="primaryDiagnosisTextbox" id="txtPrimaryDiagnosis_' + value.DiagnosisId + '" style="width: 70%; margin-left: 10px;" rows="3"></textarea>' +
                            '</div>' +
                            '</div>';
                    });

                    $('#allPrimaryDiagnosis').html(options);
                },
                error: function (xhr, status, error) {
                    console.error('Error fetching area data:', error);
                }
            });
        }
        function handlePrimaryDiagnosisRow(diagnosisId, diagnosisName) {
            debugger;
            // Get the textarea value
            const remarks = $('#txtPrimaryDiagnosis_' + diagnosisId).val().trim();

            // Check if row already exists
            const existingRow = $('#PrimarydiagnosisRow_' + diagnosisId);
            debugger;
            if (existingRow.length) {
                // Update existing row
                existingRow.find('td:eq(2)').text(remarks);
            }
            else {
                // Create new row
                const newRow = `
    <tr id="PrimarydiagnosisRow_${diagnosisId}">
        <td style="display:none">${diagnosisId}</td>
        <td>${diagnosisName}</td>
        <td>${remarks}</td>
        <td>
            <a href="#" onclick="removePrimaryDiagnosisRow('${diagnosisId}')">
                <i class="fa fa-times"></i>
            </a>
        </td>
    </tr>
`;
                console.log(newRow);
                $("#tblPrimaryDiagnosis tbody").append(newRow);
            }

            // Show table if hidden
            $('#dvtblPrimaryDiagnosis').slideDown();
        }
        $(document).on('change', '.Primary_Diagnosis_checkbox', function () {
            const diagnosisId = $(this).val();
            const diagnosisName = $(this).next('label').text();

            if ($(this).is(':checked')) {
                handlePrimaryDiagnosisRow(diagnosisId, diagnosisName);
            } else {
                removePrimaryDiagnosisRow(diagnosisId);
            }
        });
        $(document).on('input', '.primaryDiagnosisTextbox', function () {
            const diagnosisId = $(this).attr('id').replace('txtPrimaryDiagnosis_', '');
            const diagnosisName = $(this).prevAll('label').text();
            const checkbox = $('#chk_Primary_Diagnosis_' + diagnosisId);

            // Check the checkbox if not already checked
            if (!checkbox.is(':checked')) {
                checkbox.prop('checked', true);
            }

            handlePrimaryDiagnosisRow(diagnosisId, diagnosisName);
        });

        function saveFinalDiagnosis() {
            $('#btnSaveNewFinalDiagnosis').attr('disabled', true);
            const Text = $('#NewFinalDiagnosis').val().trim();

            if (Text === '') {
                $('#btnSaveNewFinalDiagnosis').attr('disabled', false);
                alert('Please enter a Diagnosis before saving.');
                return;
            }
            else {
                $.ajax({
                    type: "POST",
                    url: "NewOutPatient.aspx/SaveNewDiagnosis",
                    data: JSON.stringify({ Text: Text }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        $('#btnSaveNewFinalDiagnosis').attr('disabled', false);
                        if (response.d == "0") {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'Diagnosis already exists!',
                                showConfirmButton: false,
                                timer: 2000,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });
                        }
                        else {
                            fillFinalDiagnosis("");
                            fillPrimaryDiagnosis("");
                        }
                    },
                    error: function (xhr, status, error) {
                        $('#btnSaveNewFinalDiagnosis').attr('disabled', false);
                        console.error("Error searching symptoms:", error);
                    }
                });
            }
            // Hide the form with slide up animation after saving
            $('#divAddNewFinalDiagnosis').slideUp(300, function () {
                $('#NewFinalDiagnosis').val(''); // Clear input after hiding
            });
        }
        function AddNewFinalDiagnosis() {
            const $divComplaint = $('#divAddNewFinalDiagnosis');

            if ($divComplaint.is(':visible')) {
                // Hide with slide up animation
                $divComplaint.slideUp(300, function () {
                    $('#NewFinalDiagnosis').val(''); // Clear input after hiding
                });
            } else {
                // Show with slide down animation
                $divComplaint.slideDown(300, function () {
                    $('#NewFinalDiagnosis').focus(); // Focus input after showing
                });
            }
        }
        function fillFinalDiagnosis(searchValue) {
            var options = '';
            $.ajax({
                url: 'NewOutPatient.aspx/GetDiagnosis',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                data: JSON.stringify({
                    searchValue: searchValue || ""
                }),
                success: function (response) {
                    var data = response.d ? JSON.parse(response.d) : response;
                    $.each(data, function (key, value) {
                        options += '<div class="Final-Diagnosis-row" style="display: flex; align-items: center; justify-content: space-between;">' +
                            '<div style="display: flex; align-items: center; width: 100%">' +
                            '<input type="checkbox" id="chk_Final_Diagnosis_' + value.DiagnosisId + '" ' +
                            'value="' + value.DiagnosisId + '" ' +
                            'class="Final_Diagnosis_checkbox" ' +
                            'onclick="var textarea = document.getElementById(\'txtFinalDiagnosis_' + value.DiagnosisId + '\'); ' +
                            'this.checked ? handleFinalDiagnosisRow(\'' + value.DiagnosisId + '\', \'' + (value.DiagnosisName || '').replace(/'/g, "\\'") + '\') ' +
                            ': removeFinalDiagnosisRow(\'' + value.DiagnosisId + '\')" />' +
                            '<label for="chk_Final_Diagnosis_' + value.DiagnosisId + '" style="margin-left: 8px; width: 25%;">' + (value.DiagnosisName || '') + '</label>' +
                            '<textarea class="finalDiagnosisTextbox" id="txtFinalDiagnosis_' + value.DiagnosisId + '" style="width: 70%; margin-left: 10px;" rows="3"></textarea>' +
                            '</div>' +
                            '</div>';
                    });

                    $('#allFinalDiagnosis').html(options);
                },
                error: function (xhr, status, error) {
                    console.error('Error fetching area data:', error);
                }
            });
        }
        function removePrimaryDiagnosisRow(diagnosisId) {
            // Remove the row
            $('#PrimarydiagnosisRow_' + diagnosisId).remove();

            // Uncheck checkbox and clear textarea
            $('#chk_Primary_Diagnosis_' + diagnosisId).prop('checked', false);
            $('#txtPrimaryDiagnosis_' + diagnosisId).val('');

            // Hide table if no rows left
            if ($('#tblPrimaryDiagnosis tbody tr').length === 0) {
                $('#dvtblPrimaryDiagnosis').slideUp();
            }
        }
        function handleFinalDiagnosisRow(diagnosisId, diagnosisName) {
            // Get the textarea value
            const remarks = $('#txtFinalDiagnosis_' + diagnosisId).val().trim();

            // Check if row already exists
            const existingRow = $('#FinaldiagnosisRow_' + diagnosisId);

            if (existingRow.length) {
                // Update existing row
                existingRow.find('td:eq(2)').text(remarks);
            } else {
                // Create new row
                const newRow = `
            <tr id="FinaldiagnosisRow_${diagnosisId}">
                <td style="display:none">${diagnosisId}</td>
                <td>${diagnosisName}</td>
                <td>${remarks}</td>
                <td>
                    <a href="#" onclick="removeFinalDiagnosisRow('${diagnosisId}')">
                        <i class="fa fa-times"></i>
                    </a>
                </td>
            </tr>
        `;

                $('#tblFinalDiagnosis tbody').append(newRow);
            }

            // Show table if hidden
            $('#dvtblFinalDiagnosis').slideDown();
        }
        function removeFinalDiagnosisRow(diagnosisId) {
            // Remove the row
            $('#FinaldiagnosisRow_' + diagnosisId).remove();

            // Uncheck checkbox and clear textarea
            $('#chk_Final_Diagnosis_' + diagnosisId).prop('checked', false);
            $('#txtFinalDiagnosis_' + diagnosisId).val('');

            // Hide table if no rows left
            if ($('#tblFinalDiagnosis tbody tr').length === 0) {
                $('#dvtblFinalDiagnosis').slideUp();
            }
        }
        $(document).on('change', '.Final_Diagnosis_checkbox', function () {
            const diagnosisId = $(this).val();
            const diagnosisName = $(this).next('label').text();

            if ($(this).is(':checked')) {
                handleFinalDiagnosisRow(diagnosisId, diagnosisName);
            } else {
                removeFinalDiagnosisRow(diagnosisId);
            }
        });
        $(document).on('input', '.finalDiagnosisTextbox', function () {
            const diagnosisId = $(this).attr('id').replace('txtFinalDiagnosis_', '');
            const diagnosisName = $(this).prevAll('label').text();
            const checkbox = $('#chk_Final_Diagnosis_' + diagnosisId);

            // Check the checkbox if not already checked
            if (!checkbox.is(':checked')) {
                checkbox.prop('checked', true);
            }

            handleFinalDiagnosisRow(diagnosisId, diagnosisName);
        });
        function FillPreviousLabTests() {
            debugger;
            var patientID = $("#<%= hdfReg_ID.ClientID %>").val();

            if (!patientID || patientID === '') {
                $('#InvestigationPreviousHistory').html('<div style="padding: 10px; color: #999;">No patient selected</div>');
                return;
            }

            var html = '';



            html += '<div id="previousTestsList">';

            PageMethods.GetPreviousLabTests(patientID, function (Tests) {
                var testData = JSON.parse(Tests);

                if (testData.length === 0) {
                    $('#InvestigationPreviousHistory').html('<div style="padding: 10px; color: #999;">No previous lab tests found</div>');
                    return;
                }

                $.each(testData, function (key, value) {
                    html += '<div class="labtest-row" style="display: flex; align-items: center; justify-content: space-between; padding: 6px 0; cursor: pointer;" ' +
                        'onclick="ShowLabTestDetails(\'' + value.SerialNo + '\', \'' + value.TestName + '\')">' +
                        '<div style="display: flex; align-items: center;">' +
                        '<input type="checkbox" id="PrevLabTestchk_' + value.SerialNo + '" ' +
                        'data-testid="' + value.TestID + '" ' +
                        'data-testname="' + value.TestName + '" ' +
                        'value="' + value.SerialNo + '" ' +
                        'class="prev-labtest_checkbox" ' +
                        'onclick="event.stopPropagation(); this.checked ?  Add_LabTestRow(\'' + value.SerialNo + '\', \'' + value.TestName + '\') : Remove_LabTestRow(\'' + value.SerialNo + '\')" />' +
                        '<label class="labtest-label" for="PrevLabTestchk_' + value.SerialNo + '" style="margin-left: 8px; font-size: 14px; color: #333; cursor: pointer;">' + value.TestName + '</label>' +
                        '</div>' +
                        '<button type="button" class="labtest-dropdown-btn" ' +
                        'onclick="event.stopPropagation(); ShowLabTestDetails(\'' + value.SerialNo + '\', \'' + value.TestName + '\')" ' +
                        'style="background: none; border: none; cursor: pointer; padding: 2px 8px; margin-left: 8px;">' +
                        '<i class="fa fa-chevron-down" style="font-size: 12px; color: #888;"></i>' +
                        '</button>' +
                        '</div>';
                });

                html += '</div>';
                $('#InvestigationPreviousHistory').html(html);
            }, function (error) {
                console.error('Error loading previous lab tests:', error);
                $('#InvestigationPreviousHistory').html('<div style="padding: 10px; color: #d9534f;">Error loading previous tests</div>');
            });
        }
        function FillPreviousDiagnosticTests() {
            debugger;
            var patientID = $("#<%= hdfReg_ID.ClientID %>").val();

            if (!patientID || patientID === '') {
                $('#DiagnosticsPreviousHistory').html('<div style="padding: 10px; color: #999;">No patient selected</div>');
                return;
            }

            var html = '';



            html += '<div id="previousDiagnosticTestsList">';

            PageMethods.GetPreviousDiagnosticTests(patientID, function (Tests) {
                var testData = JSON.parse(Tests);

                if (testData.length === 0) {
                    $('#DiagnosticsPreviousHistory').html('<div style="padding: 10px; color: #999;">No previous diagnostic tests found</div>');
                    return;
                }

                $.each(testData, function (key, value) {
                    html += '<div class="diagnosticTest-row" style="display: flex; align-items: center; justify-content: space-between; padding: 6px 0; cursor: pointer;" ' +
                        'onclick="ShowDiagnosticTestDetails(\'' + value.Test_ID + '\', \'' + value.Test_Name + '\', \'' + value.Main_Department + '\')">' +
                        '<div style="display: flex; align-items: center;">' +
                        '<input type="checkbox" id="PrevDiagnosticTestchk_' + value.Test_ID + '" ' +
                        'data-testid="' + value.Test_ID + '" ' +
                        'data-testname="' + value.Test_Name + '" ' +
                        'data-maindept="' + value.Main_Department + '" ' +
                        'value="' + value.Test_ID + '" ' +
                        'class="prev-diagnostictest_checkbox" ' +
                        'onclick="event.stopPropagation(); this.checked ?  Add_DiagnosticTestRow(\'' + value.Test_ID + '\', \'' + value.Test_Name + '\') : Remove_DiagnosticTestRow(\'' + value.Test_ID + '\')" />' +
                        '<label class="diagnostictest-label" for="PrevDiagnosticTestchk_' + value.Test_ID + '" style="margin-left: 8px; font-size: 14px; color: #333; cursor: pointer;">' + value.Test_Name + '</label>' +
                        '</div>' +
                        '<button type="button" class="diagnostictest-dropdown-btn" ' +
                        'onclick="event.stopPropagation(); ShowDiagnosticTestDetails(\'' + value.Test_ID + '\', \'' + value.Test_Name + '\', \'' + value.Main_Department + '\')" ' +
                        'style="background: none; border: none; cursor: pointer; padding: 2px 8px; margin-left: 8px;">' +
                        '<i class="fa fa-chevron-down" style="font-size: 12px; color: #888;"></i>' +
                        '</button>' +
                        '</div>';
                });

                html += '</div>';
                $('#DiagnosticsPreviousHistory').html(html);
            }, function (error) {
                console.error('Error loading previous diagnostic tests:', error);
                $('#DiagnosticsPreviousHistory').html('<div style="padding: 10px; color: #d9534f;">Error loading previous tests</div>');
            });
        }


        function FillLabTests(searchValue) {
            debugger;
            var html = '';

            PageMethods.GetLabTests(searchValue, function (Tests) {
                debugger
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
        function FillPreviousMedicines() {
            debugger;
            var patientID = $("#<%= hdfReg_ID.ClientID %>").val();

            if (!patientID || patientID === '') {
                $('#MedicenePreviousHistory').html('<div style="padding: 10px; color: #999;">No patient selected</div>');
                return;
            }

            var html = '';

            

            html += '<div id="previousMedicinesList">';

            PageMethods.GetPreviousMedicines(patientID, function (Medicines) {
                var medicineData = JSON.parse(Medicines);

                if (medicineData.length === 0) {
                    $('#MedicenePreviousHistory').html('<div style="padding: 10px; color: #999;">No previous medicines found</div>');
                    return;
                }

                $.each(medicineData, function (key, value) {
                    html += '<div class="Medicene-row" style="display: flex; align-items: center; justify-content: space-between; padding: 6px 0; cursor: pointer;" ' +
                        'onclick="ShowMediceneDetails(\'' + value.Item_Code + '\', \'' + value.Description.replace(/'/g, "\\'") + '\')">' +
                        '<div style="display: flex; align-items: center;">' +
                        '<input type="checkbox" id="PrevMedicinechk_' + value.Item_Code + '" ' +
                        'data-itemcode="' + value.Item_Code + '" ' +
                        'data-description="' + value.Description.replace(/'/g, "&#39;") + '" ' +
                        'value="' + value.Item_Code + '" ' +
                        'class="prev-medicine_checkbox" ' +
                        'onclick="event.stopPropagation(); this.checked ? ShowMediceneDetails(\'' + value.Item_Code + '\', \'' + value.Description.replace(/'/g, "\\'") + '\') : RemovePreviousMedicineSelection(\'' + value.Item_Code + '\')" />' +
                        '<label class="Medicene-label" for="PrevMedicinechk_' + value.Item_Code + '" ' +
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

                html += '</div>';
                $('#MedicenePreviousHistory').html(html);
            }, function (error) {
                console.error('Error loading previous medicines:', error);
                $('#MedicenePreviousHistory').html('<div style="padding: 10px; color: #d9534f;">Error loading previous medicines</div>');
            });
        }

      
        function FillMedicene(searchValue) {
            var html = '';
            $.ajax({
                url: 'NewOutPatient.aspx/getpharmacyitems',
                method: 'POST',
                contentType: 'application/json',
                data: JSON.stringify({ searchString: searchValue || '' }),
                success: function (response) {
                    try {
                        var pharmacyItems = JSON.parse(response.d);
                        if (pharmacyItems.length === 0) {
                            html = '<div style="padding: 10px; color: #666; font-style: italic;">No items found</div>';
                        } else {
                            $.each(pharmacyItems, function (key, value) {
                                var stockColor = value.TotalStock > 0 ? '#28a745' : '#dc3545';
                                var stockText = value.TotalStock > 0 ? 'Stock: ' + value.StockDisplay : 'Out of Stock';

                                html += '<div class="Medicene-row" style="display: flex; align-items: center; justify-content: space-between; padding: 6px 0; cursor: pointer;" ' +
                                    'onclick="ShowMediceneDetails(\'' + value.Item_Code + '\', \'' + value.Description.replace(/'/g, "\\'") + '\', false, {}, ' + (value.TotalStock || 0) + ')">' +
                                    '<div style="display: flex; align-items: center; flex: 1;">' +
                                    '<input style="display:none" type="checkbox" id="Medicenechk_' + value.Item_Code + '" class="Medicene-checkbox" ' +
                                    'style="margin-right: 8px; cursor: pointer;">' +
                                    '<label class="Medicene-label" for="Medicenechk_' + value.Item_Code + '" ' +
                                    'style="margin-left: 8px; font-size: 14px; color: #333; cursor: pointer; flex: 1;">' +
                                    value.Description +
                                    '</label>' +
                                    '</div>' +
                                    '<div style="display: flex; align-items: center; gap: 10px;">' +
                                    '<span style="font-size: 12px; color: ' + stockColor + '; font-weight: 500; min-width: 80px; text-align: right;">' +
                                    stockText +
                                    '</span>' +
                                    '<button type="button" class="Medicene-dropdown-btn" ' +
                                    'onclick="event.stopPropagation(); ShowMediceneDetails(\'' + value.Item_Code + '\', \'' + value.Description.replace(/'/g, "\\'") + '\', false, {}, ' + (value.TotalStock || 0) + ')" ' +
                                    'style="background: none; border: none; cursor: pointer; padding: 2px 8px; margin-left: 8px;">' +
                                    '<i class="fa fa-chevron-down" style="font-size: 12px; color: #888;"></i>' +
                                    '</button>' +
                                    '</div>' +
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
        function ShowMediceneDetails(serialNo, testName, isEditMode = false, existingValues = {}, totalStock = 0) {
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

            // Determine stock status for display
            var stockColor = totalStock > 0 ? '#28a745' : '#dc3545';
            var stockStatus = totalStock > 0 ? 'In Stock' : 'Out of Stock';
            var stockDisplay = totalStock > 0 ? totalStock.toFixed(2) : '0';

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
    
    <!-- Third Row - Frequency and Stock (2 fields) -->
    <div class="row">
        <div class="col-md-6" style="margin-bottom: 8px;">
            <label style="display: block; margin-bottom: 4px; font-size: 13px;">Frequency</label>
            <select id="medicenefrequency_${serialNo}" class="form-control" style="width: 100%; padding: 5px;">
             </select>
        </div>
        <div class="col-md-6" style="margin-bottom: 8px;">
            <label style="display: block; margin-bottom: 4px; font-size: 13px;">Available Stock</label>
            <input type="text" id="availableStock_${serialNo}" class="form-control" 
                  style="width: 100%; padding: 5px; background-color: #f8f9fa; color: ${stockColor}; font-weight: bold;"
                  value="${stockDisplay}" readonly>
            <small style="color: ${stockColor}; font-size: 11px;">${stockStatus}</small>
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
            debugger;
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

            var selectedOtherInstructionText = $('#otherinstructions_' + serialNo).find('option:selected').text().trim();
            if (!otherInstruction || otherInstruction === "" || selectedOtherInstructionText === "Select Instruction") {
                var otherInstructionText = "";
                var otherInstruction = "";
            } else {
                var otherInstructionText = selectedOtherInstructionText;
            }

            var specialInstructions = $('#specialinstructions_' + serialNo).val();
            var ItemCode = $('#ItemCode' + serialNo).val();
            var datetime = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A")%>';
            var datetimeValue = '<%= DateTime.Now%>';

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

            // Check if this is an edit operation (existing row with matching serialNo)
            var existingRow = $('input[name="uurowid"][value="' + serialNo + '"]').closest('tr');

            if (existingRow.length > 0) {
                // UPDATE existing row instead of creating new one
                existingRow.find('td').eq(0).html('<input type="hidden" name="testDate" value="' + datetimeValue + '">' + datetime);
                existingRow.find('td').eq(1).html('<input type="hidden" name="hdnItemCode" value="0">' + medicineName);
                existingRow.find('td').eq(2).html(frequencyText + '<input type="hidden" class="field-value" value="' + frequency + '">');
                existingRow.find('td').eq(3).html(routeText + '<input type="hidden" class="field-value" value="' + route + '">');
                existingRow.find('td').eq(4).html(duration);
                existingRow.find('td').eq(5).html(specialInstructions);
                existingRow.find('td').eq(6).html(dosageFromText + '<input type="hidden" class="field-value" value="' + dosageFrom + '">');
                existingRow.find('td').eq(7).html(doseText + '<input type="hidden" class="field-value" value="' + dose + '">');
                existingRow.find('td').eq(8).html(otherInstructionText + '<input type="hidden" class="field-value" value="' + otherInstruction + '">');
                existingRow.find('td').eq(9).html(ItemCode + '<input type="hidden" class="field-value" value="' + ItemCode + '">');

                // Keep the same uurowid (don't change it)

                // Clear the details div after update
                $('#MediceneDetails_' + serialNo).slideUp();

            } else {
                // ADD new row (this is a new medicine, not an edit)
                var newUuid = uuid();
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
                    '<td style="display:none;"><input type="hidden" name="ItemCode" value="' + serialNo + '" /></td>' +
                    '<td>' +
                    '<a href="#" onclick="editMedicine(this)">Edit</a> | ' +
                    '<a href="#" onclick="deleteMedicine(this)"><i class="fa fa-times"></i></a>' +
                    '<input type="hidden" name="uurowid" value="' + newUuid + '">' +
                    '</td>' +
                    '</tr>';
                $('#tblMedicines tbody').append(row);

                $('#dvtblMedicines').slideDown();
                $('#MediceneDetails_' + serialNo).slideUp();
            }

            // Clear the form fields after add/update
            $('#mediceneDose_' + serialNo).val('');
            $('#mediceneDosageFrom_' + serialNo).val('');
            $('#duration_' + serialNo).val('');
            $('#mediceneroute_' + serialNo).val('');
            $('#medicenefrequency_' + serialNo).val('');
            $('#otherinstructions_' + serialNo).val('');
            $('#specialinstructions_' + serialNo).val('');

            // Uncheck the checkbox and remove the details div
            $('#Medicenechk_' + serialNo).prop('checked', false);
            $('#MediceneDetails_' + serialNo).remove();
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
                url: 'NewOutPatient.aspx/GetTemplate',
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
        // Fill all services with search
        function FillServices(searchValue) {
            var html = '';
            $.ajax({
                url: 'NewOutPatient.aspx/GetServices',
                method: 'POST',
                contentType: 'application/json',
                data: JSON.stringify({ searchString: searchValue || '' }),
                success: function (response) {
                    try {
                        var serviceItems = JSON.parse(response.d);
                        if (serviceItems.length === 0) {
                            html = '<div style="padding: 10px; color: #666; font-style: italic;">No services found</div>';
                        } else {
                            $.each(serviceItems, function (key, value) {
                                // Check if service is already added
                                var isChecked = $('#tblServices tbody').find('input[name="serviceItemCode"][value="' + value.Item_Code + '"]').length > 0;

                                html += '<div class="service-row" style="display: flex; align-items: center; justify-content: space-between; padding: 6px 0; border-bottom: 1px solid #eee;">' +
                                    '<div style="display: flex; align-items: center;">' +
                                    '<input type="checkbox" id="Servicechk_' + value.Item_Code + '" ' +
                                    'data-itemcode="' + value.Item_Code + '" ' +
                                    'data-description="' + value.Description.replace(/'/g, "&#39;") + '" ' +
                                    'class="service-checkbox" ' +
                                    (isChecked ? 'checked' : '') + ' ' +
                                    'onchange="this.checked ? Add_ServiceRow(\'' + value.Item_Code + '\', \'' + value.Description.replace(/'/g, "\\'") + '\') : Remove_ServiceRow(\'' + value.Item_Code + '\')" ' +
                                    'style="margin-right: 8px; cursor: pointer;">' +
                                    '<label for="Servicechk_' + value.Item_Code + '" ' +
                                    'style="margin: 0; font-size: 14px; color: #333; cursor: pointer;">' +
                                    value.Description +
                                    '</label>' +
                                    '</div>' +
                                    '</div>';
                            });
                        }
                        $('#allServices').html(html);
                    } catch (error) {
                        console.error('Error parsing response:', error);
                        $('#allServices').html('<div style="padding: 10px; color: red;">Error loading services</div>');
                    }
                },
                error: function (xhr, status, error) {
                    console.error('Error fetching data:', error);
                    $('#allServices').html('<div style="padding: 10px; color: red;">Error loading services</div>');
                }
            });
        }

        // Add service to table
        function Add_ServiceRow(itemCode, serviceName) {
            // Get current datetime
            var datetime = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A")%>';
            var datetimeValue = '<%= DateTime.Now%>';

            // Check if service already exists
            var existingRow = $('#tblServices tbody').find('input[name="serviceItemCode"][value="' + itemCode + '"]').closest('tr');

            if (existingRow.length > 0) {
                // Service already exists, just update the date
                existingRow.find('td').eq(0).html('<input type="hidden" name="serviceDate" value="' + datetimeValue + '">' + datetime);
                return;
            }

            // Create new row
            var row = '<tr>' +
                '<td style="display:none"><input type="hidden" name="serviceDate" value="' + datetimeValue + '">' + datetime + '</td>' +
                '<td><input type="hidden" name="serviceItemCode" value="' + itemCode + '">' + serviceName + '</td>' +
                '<td>' +
                '<a href="javascript:void(0)" onclick="deleteService(this, \'' + itemCode + '\')"><i class="fa fa-times"></i></a>' +
                '</td>' +
                '</tr>';

            // Append to table
            $('#tblServices tbody').append(row);
            $('#dvtblServices').slideDown();

            // Check the checkbox in all services list
            $('#Servicechk_' + itemCode).prop('checked', true);
        }
        function LoadServices() {
            var OutPatID = $('#<%= txtOut_Patient_ID.ClientID%>').val();

            if (!OutPatID || OutPatID == '(New)' || OutPatID == '' || OutPatID == "0") {
                return;
            }

            PageMethods.LoadServicesDetail(OutPatID, globalFormType, function (res) {
                if (!res) return;

                var Services = JSON.parse(res);

                if (Services.length === 0) return;

                var rows = '';

                $.each(Services, function (key, value) {
                    var dateObj;
                    var datetime, datetimeValue;

                    // Handle when CreatedDate is empty, null or undefined
                    if (!value.CreatedDate || value.CreatedDate === "") {
                        dateObj = new Date();
                    } else if (value.CreatedDate.includes("/Date(")) {
                        var timestamp = parseInt(value.CreatedDate.replace("/Date(", "").replace(")/", ""));
                        dateObj = new Date(timestamp);
                    } else {
                        dateObj = new Date(value.CreatedDate);
                    }

                    // Format display date
                    var formattedDate = !isNaN(dateObj.getTime())
                        ? $.datepicker.formatDate('dd/mm/yy', dateObj) + ' ' + dateObj.toLocaleTimeString('en-US')
                        : new Date().toLocaleDateString() + ' ' + new Date().toLocaleTimeString('en-US');

                    datetime = formattedDate;
                    datetimeValue = dateObj.toISOString();

                    rows += '<tr>' +
                        '<td style="display:none"><input type="hidden" name="serviceDate" value="' + datetimeValue + '">' + datetime + '</td>' +
                        '<td><input type="hidden" name="serviceItemCode" value="' + value.Service_ItemId + '">' + value.Services_Procedure_ItemName + '</td>' +
                        '<td>' +
                        '<a href="javascript:void(0)" onclick="deleteService(this, \'' + value.Service_ItemId + '\')"><i class="fa fa-times"></i></a>' +
                        '</td>' +
                        '</tr>';
                });

                $('#tblServices tbody').html(rows);

                // Show table div if there are records
                if (Services.length > 0) {
                    $('#dvtblServices').slideDown();
                }
            });
        }
        // Remove service from table
        function Remove_ServiceRow(itemCode) {
            var row = $('#tblServices tbody').find('input[name="serviceItemCode"][value="' + itemCode + '"]').closest('tr');
            row.remove();

            // Uncheck the checkbox
            $('#Servicechk_' + itemCode).prop('checked', false);

            // Hide table if no rows left
            if ($('#tblServices tbody tr').length === 0) {
                $('#dvtblServices').slideUp();
            }
        }

        // Delete service (called from table)
        function deleteService(anchorTag, itemCode) {
            var row = $(anchorTag).closest('tr');
            row.remove();

            // Uncheck the checkbox in all services list
            $('#Servicechk_' + itemCode).prop('checked', false);

            // Uncheck in previous history if exists
            $('#PrevServicechk_' + itemCode).prop('checked', false);

            // Hide table if no rows left
            if ($('#tblServices tbody tr').length === 0) {
                $('#dvtblServices').slideUp();
            }
        }

        // Toggle Previous History
        function ToggleServicePreviousHistory() {
            if ($('#ServicePreviousHistory').is(':visible')) {
                $('#ServicePreviousHistory').slideUp();
            } else {
                $('#ServicePreviousHistory').slideDown();
               
            }
        }

        // Fill previous services
        function FillPreviousServices() {
            debugger;
            var patientID = $("#<%= hdfReg_ID.ClientID %>").val();

            if (!patientID || patientID === '') {
                $('#ServicePreviousHistory').html('<div style="padding: 10px; color: #999;">No patient selected</div>');
                return;
            }

            var html = '';


            html += '<div id="previousServicesList" style="max-height: 300px; overflow-y: auto; border: 1px solid #ddd; padding: 10px; border-radius: 4px;">';

            PageMethods.GetPreviousServices(patientID, function (Services) {
                var serviceData = JSON.parse(Services);

                if (serviceData.length === 0) {
                    $('#ServicePreviousHistory').html('<div style="padding: 10px; color: #999;">No previous services found</div>');
                    return;
                }

                $.each(serviceData, function (key, value) {
                    // Check if service is already added
                    var isChecked = $('#tblServices tbody').find('input[name="serviceItemCode"][value="' + value.Item_Code + '"]').length > 0;

                    html += '<div class="service-row" style="display: flex; align-items: center; justify-content: space-between; padding: 6px 0; border-bottom: 1px solid #eee;">' +
                        '<div style="display: flex; align-items: center;">' +
                        '<input type="checkbox" id="PrevServicechk_' + value.Item_Code + '" ' +
                        'data-itemcode="' + value.Item_Code + '" ' +
                        'data-description="' + value.Description.replace(/'/g, "&#39;") + '" ' +
                        'class="prev-service_checkbox" ' +
                        (isChecked ? 'checked' : '') + ' ' +
                        'onchange="this.checked ? Add_ServiceRow(\'' + value.Item_Code + '\', \'' + value.Description.replace(/'/g, "\\'") + '\') : Remove_ServiceRow(\'' + value.Item_Code + '\')" ' +
                        'style="margin-right: 8px; cursor: pointer;">' +
                        '<label for="PrevServicechk_' + value.Item_Code + '" ' +
                        'style="margin: 0; font-size: 14px; color: #333; cursor: pointer;">' +
                        value.Description +
                        '</label>' +
                        '</div>' +
                        '</div>';
                });

                html += '</div>';
                $('#ServicePreviousHistory').html(html);
            }, function (error) {
                console.error('Error loading previous services:', error);
                $('#ServicePreviousHistory').html('<div style="padding: 10px; color: #d9534f;">Error loading previous services</div>');
            });
        }

    


        function updateFollowUpTable() {
            // Get values from form inputs
            var doctorName = $('#<%= ddlDoctorName.ClientID %> option:selected').text();
            var doctorId = $('#<%= ddlDoctorName.ClientID %>').val();
            var designation = $('#<%= txtDesignation.ClientID %>').val();
            var admission = $('#<%= ddlIssuance_Of.ClientID %> option:selected').text();
            var admissionId = $('#<%= ddlIssuance_Of.ClientID %>').val();
            var followUp = $('#<%= ddlFOllowUp.ClientID %> option:selected').text();
            var followUpTime = $('#<%= ddlFOllowUpWeeks.ClientID %> option:selected').text();
            var followUpId = $('#<%= ddlFOllowUp.ClientID %>').val();
            var followUpTimeId = $('#<%= ddlFOllowUpWeeks.ClientID %>').val();
            var followUpDate = $('#<%= FollowNoDate.ClientID %>').val();

            // Only proceed if at least one field has a value
            if (!doctorId && !followUpId && !followUpDate) {
                return false;
            }

            var table = $('#tblFollowUp tbody');
            var existingRow = table.find('tr').first();

            if (existingRow.length > 0) {
                // Update existing row
                if (doctorId) {
                    existingRow.find('td:eq(0)').text(doctorName).attr('data-id', doctorId);
                    existingRow.find('td:eq(1)').text(designation);
                }
                if (admissionId) {
                    existingRow.find('td:eq(2)').text(admission).attr('data-id', admissionId);
                }
                if (followUpId) {
                    existingRow.find('td:eq(3)').text(followUp).attr('data-id', followUpId);
                }
                if (followUpTimeId) {
                    existingRow.find('td:eq(4)').text(followUpTime).attr('data-id', followUpTimeId);
                }
                if (followUpDate) {
                    existingRow.find('td:eq(5)').text(followUpDate);
                }
            } else {
                // Create new row only if at least one required field is filled
                if (doctorId || followUpId || followUpDate) {
                    var newRow = $('<tr>').append(
                        $('<td>').text(doctorName || '').attr('data-id', doctorId || ''),
                        $('<td>').text(designation || ''),
                        $('<td>').text(admission || '').attr('data-id', admissionId || ''),
                        $('<td>').text(followUp || '').attr('data-id', followUpId || ''),
                        $('<td>').text(followUpTime || '').attr('data-id', followUpTimeId || ''),
                        $('<td>').text(followUpDate || '')
                    );

                    // Append to table
                    table.append(newRow);
                    $('#divtblFollowUp').slideDown();
                }
            }

            return true;
        }

        function updateDisposalTable() {
            const DisposalTable = $('#tblDisposal tbody');
            const DisposalContainer = $('#divtblDisposal');
            let hasData = false;

            // Clear existing rows
            DisposalTable.empty();

            // Process each Disposal field
            $('.Disposal-row').each(function () {
                const label = $(this).find('span').text().trim();
                const textbox = $(this).find('textarea, input[type="text"]');
                const value = textbox.val().trim();

                if (value) {
                    // Append new row with formatted text
                    DisposalTable.append(`
        <tr>
            <td><strong>${label}:</strong> ${value}</td>
        </tr>
    `);
                    hasData = true;
                }
            });

            // Show/hide container based on whether there's data
            if (hasData) {
                DisposalContainer.slideDown();
            } else {
                DisposalContainer.slideUp();
            }
        }

        function AddProto() {
            debugger;
            var protoval = $('#ctl00_MainContent_ddlProto').val();
            var prototext = $('#ctl00_MainContent_ddlProto option:selected').text();

            var rows = '<tr><td ><input type="hidden" name="ProtoId" value="' + protoval + '" />' + prototext + '</td> <td style="text-align: left;"> <a  href="#" onclick="DeleteRow(this)"><i class="fa fa-times"></i></a> </td> </tr>';
            $("#tblProto").append(rows);
            $("#dvtblProto").slideDown();
        }

        function toggleDischarge(checkbox) {
            const label = checkbox.closest('label');
            const textSpan = document.getElementById('DischargeButtonText');

            if (checkbox.checked) {
                label.classList.add('checked');
                textSpan.textContent = 'Discharged';
            } else {
                label.classList.remove('checked');
                textSpan.textContent = 'Discharge';
            }
        }
        function DeleteRow(anchor) {
            var row = $(anchor).parents('tr')[0];
            row.remove();
            // Check if there are no more rows left in the tbody
            if ($("#tblProto tbody tr").length === 0) {
                $("#dvtblProto").slideUp();
            }
        }
        function toggleRetract() {
            const retractDiv = document.getElementById('retract');
            retractDiv.classList.toggle('minimized');
        }
        function ReplaceNullWith_Space(value) {
            return value == null ? '' : value;
        }
        function Remove_CustomInputRow() {
            const examName = 'CustomInput';

            $(`#tblGeneralExam tbody tr[data-exam="${examName}"]`).remove();

            $('#ctl00_MainContent_txtInputBox1').val('');
            if ($('#tblGeneralExam tbody tr').length === 0) {
                $('#divtblGeneralExam').slideUp();
            }
        }
        function filterExaminations() {

            const selectedValue = $('#filterExaminations').val();

            $('.subtabs').slideUp();

            if (selectedValue === '001') {
                $('#subTab001').slideDown();
            }
            else if (selectedValue === '002') {
                $('#subTab002').slideDown();
            }
            else if (selectedValue === '004') {
                $('#subTab004').slideDown();
            }
            else if (selectedValue === '005') {
                $('#subTab005').slideDown();
            }
            else {
                $('#subTab003').slideDown();
            }
        }
        function uuid() {
            var uuid = "", i, random;
            for (i = 0; i < 32; i++) {
                random = Math.random() * 16 | 0;

                if (i == 8 || i == 12 || i == 16 || i == 20) {
                    uuid += "-"
                }
                uuid += (i == 12 ? 4 : (i == 16 ? (random & 3 | 8) : random)).toString(16);
            }
            return uuid;
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
        function SaveComplaintsTab(callback) {
            console.log('SaveComplaintsTab called');
            try {
                var ComplaintsList = [];
                var OutPatientID = $('#<%= txtOut_Patient_ID.ClientID%>').val();
                if (OutPatientID == '(New)' || OutPatientID == '' || OutPatientID == "0")
                    OutPatientID = 0;
                $.each($('#tblComplaints tbody tr'), function (key, value) {
                    ComplaintsList.push({
                        'OutPatientID': OutPatientID,
                        'ComplaintID': $(value).find('.complainclass').val(),
                        'ComplaintText': $($(value).find('td')[1]).text().trim(),
                    });
                });

                PageMethods.SaveComplaintsOfPatient(JSON.stringify(ComplaintsList), globalFormType, function (response) {
                    console.log('SaveComplaintsTab completed');
                    if (callback) callback();
                }, function (error) {
                    console.error('SaveComplaintsTab error:', error ? error.get_message ? error.get_message() : error : 'unknown');
                    if (callback) callback();
                });
            } catch (e) {
                console.error('SaveComplaintsTab exception:', e);
                if (callback) callback();
            }

        }
        function SavePrimaryDiagnosisTab(callback) {
            console.log('SavePrimaryDiagnosisTab called');
            try {
                var PrimaryDiagnosisList = [];
                var OutPatientID = $('#<%= txtOut_Patient_ID.ClientID%>').val();
                if (OutPatientID == '(New)' || OutPatientID == '' || OutPatientID == "0") {
                    OutPatientID = 0;
                }
                $.each($('#tblPrimaryDiagnosis tbody tr'), function (key, value) {
                    PrimaryDiagnosisList.push({
                        'OutPatientID': OutPatientID,
                        'DiagnosisID': $($(value).find('td')[0]).text().trim(),
                        'Remarks': $($(value).find('td')[2]).text().trim(),
                    });
                });

                PageMethods.SavePrimaryDiagnosisOfPatient(JSON.stringify(PrimaryDiagnosisList), globalFormType, function (response) {
                    console.log('SavePrimaryDiagnosisTab completed');
                    if (callback) callback();
                }, function (error) {
                    console.error('SavePrimaryDiagnosisTab error:', error && error.get_message ? error.get_message() : error);
                    if (callback) callback();
                });
            } catch (e) {
                console.error('SavePrimaryDiagnosisTab exception:', e);
                if (callback) callback();
            }

        }
        function SaveFinalDiagnosisTab(callback) {
            console.log('SaveFinalDiagnosisTab called');
            try {
                var FinalDiagnosisList = [];
                var OutPatientID = $('#<%= txtOut_Patient_ID.ClientID%>').val();
                if (OutPatientID == '(New)' || OutPatientID == '' || OutPatientID == "0") {
                    OutPatientID = 0;
                }
                $.each($('#tblFinalDiagnosis tbody tr'), function (key, value) {
                    FinalDiagnosisList.push({
                        'OutPatientID': OutPatientID,
                        'DiagnosisID': $($(value).find('td')[0]).text().trim(),
                        'Remarks': $($(value).find('td')[2]).text().trim(),
                    });
                });

                PageMethods.SaveFinalDiagnosisOfPatient(JSON.stringify(FinalDiagnosisList), globalFormType, function (response) {
                    console.log('SaveFinalDiagnosisTab completed');
                    if (callback) callback();
                }, function (error) {
                    console.error('SaveFinalDiagnosisTab error:', error && error.get_message ? error.get_message() : error);
                    if (callback) callback();
                });
            } catch (e) {
                console.error('SaveFinalDiagnosisTab exception:', e);
                if (callback) callback();
            }

        }
        function SaveServices(callback) {
            debugger;
            var table = $('#tblServices');
            var ServicesList = [];

            table.find('tbody tr').each(function (key, value) {
                var itemCode = $(value).find('input[name="serviceItemCode"]').val();
                var serviceName = $($(value).find('td')[1]).text();

                ServicesList.push({
                    'Service_ItemId': itemCode,
                    'Services_Procedure_ItemName': serviceName,
                    'CreatedDate': $(value).find('input[name="serviceDate"]').val()
                });
            });

            var PatID = $('#<%= hdfReg_ID.ClientID%>').val();
           var OutPatID = $('#<%= txtOut_Patient_ID.ClientID%>').val();

           if (OutPatID == '(New)' || OutPatID == '' || OutPatID == "0")
               OutPatID = 0;

           var ServiceDetails = {
               Pat: PatID,
               PatientID: OutPatID,
               ServiceList: ServicesList
           };

           console.log('Saving services:', ServiceDetails);

           PageMethods.SaveServices(JSON.stringify(ServiceDetails), globalFormType,
               function (response) {
                   // Parse response if using enhanced DTO
                   try {
                       var result = JSON.parse(response);

                       if (result.Success) {
                           console.log(result.Message);
                           alert('Services saved successfully: ' + result.ServicesSaved + ' service(s)');

                           if (result.Errors && result.Errors.length > 0) {
                               console.warn('Errors encountered:', result.Errors);
                           }
                       } else {
                           console.error('Save failed:', result.Message);
                           alert('Error saving services: ' + result.Message);
                       }
                    } catch (e) {
                        console.log('Response:', response);
                    }
                    if (callback) callback();
                },
                function (error) {
                    console.error('Error calling SaveServices:', error);
                    if (callback) callback();
                }
            );
        }
        function saveInPatientDischargeTabs(callback) {
            console.log('saveInPatientDischargeTabs: starting chain...');
            SaveComplaintsTab(function () {
                console.log('Complaints saved');
                SavePrimaryDiagnosisTab(function () {
                    console.log('Primary diagnosis saved');
                    SaveFinalDiagnosisTab(function () {
                        console.log('Final diagnosis saved');
                        SaveServices(function () {
                            console.log('Services saved');
                            SaveLabResult(function () {
                                console.log('Lab results saved, calling final callback');
                                if (callback) callback();
                            });
                        });
                    });
                });
            });
        }
        function SaveMedicines() {
            $('#btnSave').attr('disabled', true);
            console.log('SaveMedicines called, globalFormType=', globalFormType);
            if (globalFormType === 'InPatientDischarge') {
                console.log('Starting InPatientDischarge save chain...');
                saveInPatientDischargeTabs(function () {
                    console.log('Child tabs saved, now saving medicines...');
                    var table = $('#tblMedicines');
                    var MedicinesList = [];
                    table.find('tbody tr').each(function (key, value) {
                        var date = '<%= DateTime.Now%>'
                        MedicinesList.push({
                            'Medicine_Date': $(value).find('td input[name=testDate]').val(), 'Medicine_Name': $($(value).find('td')[1]).text(), 'Frequency': $($(value).find('td')[2]).text(), 'Oral': $($(value).find('td')[3]).text(), 'Injection': $($(value).find('td')[4]).text(), 'AttendingParamedical_Staff': $($(value).find('td')[5]).text(),
                            'Dosage_From': $($(value).find('td')[6]).text(), 'Dosage_Qty': $($(value).find('td')[7]).text(), 'Other_Instruction': $($(value).find('td')[8]).text(), 'ItemCode': $(value).find('td input[name=ItemCode]').val(),
                        });
                    });
                    var PatID = $('#<%= hdfPatient_ID.ClientID%>').val();
                    var OutPatID = $('#<%= txtOut_Patient_ID.ClientID%>').val();
                    console.log('Medicines PatID=', PatID, 'OutPatID=', OutPatID);
                    if (OutPatID == '(New)' || OutPatID == '' || OutPatID == "0")
                        OutPatID = 0;
                    var MedicineDetails = { Pat: PatID, PatientID: OutPatID, MedicineList: MedicinesList }
                    console.log('Saving medicines...', MedicineDetails);
                    PageMethods.SaveMedicines(JSON.stringify(MedicineDetails), globalFormType, function (response) {
                        console.log('Medicines saved, calling SaveHistoryTab');
                        SaveHistoryTab();
                    });
                });
                return;
            }
            SaveComplaintsTab(); SavePrimaryDiagnosisTab(); SaveFinalDiagnosisTab(); SaveServices(); SaveLabResult();
            debugger;
            var table = $('#tblMedicines');
            var MedicinesList = [];
            table.find('tbody tr').each(function (key, value) {
                var date = '<%= DateTime.Now%>'
                MedicinesList.push({
                    'Medicine_Date': $(value).find('td input[name=testDate]').val(), 'Medicine_Name': $($(value).find('td')[1]).text(), 'Frequency': $($(value).find('td')[2]).text(), 'Oral': $($(value).find('td')[3]).text(), 'Injection': $($(value).find('td')[4]).text(), 'AttendingParamedical_Staff': $($(value).find('td')[5]).text(),
                    'Dosage_From': $($(value).find('td')[6]).text(), 'Dosage_Qty': $($(value).find('td')[7]).text(), 'Other_Instruction': $($(value).find('td')[8]).text(), 'ItemCode': $(value).find('td input[name=ItemCode]').val(),
                });

            });

            var PatID = $('#<%= hdfPatient_ID.ClientID%>').val();

            var OutPatID = $('#<%= txtOut_Patient_ID.ClientID%>').val();
            if (OutPatID == '(New)' || OutPatID == '' || OutPatID == "0")
                OutPatID = 0;
            var MedicineDetails = { Pat: PatID, PatientID: OutPatID, MedicineList: MedicinesList }
            console.log(MedicineDetails);
            PageMethods.SaveMedicines(JSON.stringify(MedicineDetails), globalFormType, function (response) {
                if (globalFormType !== 'InPatientDischarge') {
                    saveTests();
                } else {
                    SaveHistoryTab();
                }
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
        function SaveHistoryTab() {
            console.log('SaveHistoryTab called');
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
            console.log('SaveSymptoms OutPatientID=', SymtomsList.OutPatientID);
            PageMethods.SaveSymtoms(JSON.stringify(SymtomsList), globalFormType, function (response) {
                console.log('Symptoms saved, calling SaveProtos');
                SaveProtos();
                saveAllRecord();
            }, function (error) {
                console.error('SaveSymtoms error:', error.get_message());
                saveAllRecord();
            });

        }
        function SaveProtos() {
            debugger;
            var table = $("#tblProto");
            var ProcedureList = [];
            var btnSave = $('#btnSave').val();
            table.find("tbody tr").each(function (key, value) {
                ProcedureList.push({
                    'Proto_Description': $($(value).find("td")[0]).text(),
                    'ProtoId': $($(value).find("td")[0]).find("input[name=ProtoId]").val(),
                });
            });
            var patID = $('#<%= hdfPatient_ID.ClientID%>').val();

            var opdid = $('#<%= txtOut_Patient_ID.ClientID %>').val();
            if (opdid == "(New)" || opdid == "0")
                opdid = 0;
            var ProtoDetails = { PatId: patID, opdid: opdid, ProtoList: ProcedureList };
            console.log(ProtoDetails);
            PageMethods.SaveProto(btnSave, JSON.stringify(ProtoDetails), globalFormType, function (response) {

            });
        }
        function saveAllRecord() {
            console.log('=== saveAllRecord called ===');
            var Patient_ID = $("#<%= hdfPatient_ID.ClientID %>").val();
            var reg_ID = $("#<%= hdfReg_ID.ClientID %>").val();
            var Administration = $('#ctl00_MainContent_ddlIssuance_Of').val();
            var doc_id_hdn = $('#ctl00_MainContent_hdndoctors_id').val();
            var Voucher_id = $('#ctl00_MainContent_hdnVoucher_id').val();
            if (Administration == 0)
                Administration = "";
            var Out_Patient_ID = $('#ctl00_MainContent_txtOut_Patient_ID').val();
            if (Out_Patient_ID == "(New)" || Out_Patient_ID == "0")
                Out_Patient_ID = "";
            if (globalFormType === 'InPatientDischarge') {
                Out_Patient_ID = $('#<%= hdfOutPatientID.ClientID %>').val() || Out_Patient_ID;
            }

            // Helper function to safely get values
            function safeGetValue(selector) {
                var value = $(selector).val();
                return value || "";
            }

            console.log("saveAllRecord values:", {
                Patient_ID: Patient_ID,
                reg_ID: reg_ID,
                Out_Patient_ID: Out_Patient_ID,
                btnSave: safeGetValue('#btnSave'),
                FormType: $('#<%= hdfFormType.ClientID %>').val(),
                InPatientID: parseInt($('#<%= hdfInPatientID.ClientID %>').val()) || 0
            });

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
                PA_Gynae: safeGetValue('#ctl00_MainContent_txtPA_Gynae'),
                PS_Gynae: safeGetValue('#ctl00_MainContent_txtPS_Gynae'),
                Uterus_Gynae: safeGetValue('#ctl00_MainContent_txtUterus_Gynae'),
                FX_Gynae: safeGetValue('#ctl00_MainContent_txtFX_Gynae'),
                PS_Obs: safeGetValue('#ctl00_MainContent_txtPS_Obs'),
                PV_Obs: safeGetValue('#ctl00_MainContent_txtPV_Obs'),
                SFH_Obs: safeGetValue('#ctl00_MainContent_txtSFH_Obs'),
                LIE_Obs: safeGetValue('#ctl00_MainContent_txtLIE_Obs'),
                Presentation_Obs: safeGetValue('#ctl00_MainContent_txtPresentation_Obs'),
                FHR_Obs: safeGetValue('#ctl00_MainContent_txtFHR_Obs'),
                Engagement_Obs: safeGetValue('#ctl00_MainContent_txtEngagement_Obs'),

                // Tab05 - Referral
                Reffer_To: safeGetValue('#ctl00_MainContent_ddlPatient_Main_Category'),
                Reffer_doc: safeGetValue('#ctl00_MainContent_ddldoctors'),
                Reffer_No: safeGetValue('#ctl00_MainContent_txtRefferNote'),

                // Tab12 - Follow Up
                Doctor_ID: $('#ctl00_MainContent_ddlDoctorName option:selected').val() || "",
                Designation: safeGetValue('#ctl00_MainContent_txtDesignation'),
                Issuance_Of: safeGetValue('#ctl00_MainContent_ddlIssuance_Of'),
                Follow_Up: safeGetValue('#ctl00_MainContent_ddlFOllowUp'),
                FollowUp_Time: safeGetValue('#ctl00_MainContent_ddlFOllowUpWeeks'),
                FollowNoDate: safeGetValue('#ctl00_MainContent_FollowNoDate'),

                // Tab13 - Disposal
                FinalDiagnosis: safeGetValue('#ctl00_MainContent_txtFinalDiagnosis'),
                Advice: safeGetValue('#ctl00_MainContent_txtAdvice'),
                Final_Rec: safeGetValue("#ctl00_MainContent_Final_Rec"),
                Proto: safeGetValue('#ctl00_MainContent_ddlProto'),
                Verbal_Consent: safeGetValue('#ctl00_MainContent_ddlVerbalConsent'),

                Smokers: document.getElementById("ctl00_MainContent_chkSmokers")?.checked || false,
                Non_Smokers: document.getElementById("ctl00_MainContent_chkNon_Smokers")?.checked || false,
                Diabetics: document.getElementById("ctl00_MainContent_chkDiabetics")?.checked || false,
                Hypertensive: document.getElementById("ctl00_MainContent_chkHypertensive")?.checked || false,
                Alcohol_Consumption: document.getElementById("ctl00_MainContent_chkAlcoholConsumption")?.checked || false,
                Smokeless: document.getElementById("ctl00_MainContent_chkSmokeless")?.checked || false,

                DM: document.getElementById("ctl00_MainContent_chkDM")?.checked || false,
                HTN: document.getElementById("ctl00_MainContent_chkHTN")?.checked || false,
                TB: document.getElementById("ctl00_MainContent_chkTB")?.checked || false,
                IHD: document.getElementById("ctl00_MainContent_chkIHD")?.checked || false,
                Asthma: document.getElementById("ctl00_MainContent_chkAsthma")?.checked || false,

                // Common Fields - ensure these are proper data types
                Patient_ID: parseInt(Patient_ID) || 0,
                reg_ID: reg_ID || "",
                doc_id_hdn: doc_id_hdn || "",
                btnsave: safeGetValue('#btnSave') || "Save",
                Discharged: document.getElementById("DischargeCheckBox") ? document.getElementById("DischargeCheckBox").checked : false,
                Administration: Administration,
                Out_Patient_ID: Out_Patient_ID,
                FormType: $('#<%= hdfFormType.ClientID %>').val() || "",
                InPatientID: parseInt($('#<%= hdfInPatientID.ClientID %>').val()) || 0
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
                        debugger;
                        var formTypeId = $('#<%= hdfFormType.ClientID %>').val();
                        if (formTypeId === 'InPatientDischarge') {
                            var inPatID = $('#<%= hdfInPatientID.ClientID %>').val();
                            window.location = "NewOutPatient.aspx?Type=InPatientDischarge&InPatientID=" + inPatID + "&ID=" + response.d;
                            return;
                        }
                        if (SharingPolicy == '001') {

                        
                            var pat_id = response.d;
                            CheckComplainsAndDaignosis(pat_id);
                 
                        }
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
        function CheckComplainsAndDaignosis(pat_id) {
            PageMethods.CheckComplains(pat_id, function (result) {

                if (result === true) {
                    ApprovedOPDShare(pat_id);
                } 
            }, function (error) {
                console.error(error);
            });
        }
        function ApprovedOPDShare(pat_id) {


            PageMethods.approvepatient(pat_id, function (Tests) {
                debugger
                var message = JSON.parse(Tests);
                if (message[0].Message != null || message[0].Message != "") {
                    Swal.fire({
                        icon: 'success',
                        title: 'Success!',
                        text: message[0].Message,
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
    </script>

    <script id="updateLogic" type="text/javascript">

        function AppendSymtompsHistory() {
            var OutPatientID = $('#<%= txtOut_Patient_ID.ClientID%>').val();

            PageMethods.LoadSymtompsHistory(OutPatientID, globalFormType, function (res) {
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

            PageMethods.LoadMedicines(patientId, globalFormType, function (res) {
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
                            '<td style="display:none;"><input type="hidden" name="ItemCode" id ="ItemCode" value="' + (value.Item_Code || '') + '"> </td>' +
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
            PageMethods.LoadComplaints(OutPatientID, globalFormType, function (res) {
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

            PageMethods.LoadFinalDiagnosis(OutPatientID, globalFormType, function (res) {
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

            PageMethods.LoadPrimaryDiagnosis(OutPatientID, globalFormType, function (res) {
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
                PageMethods.LoadProtoDetails(patients_id, globalFormType, function (response) {
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

        function PrintoutPatient() {
            debugger;
            var id = '<%=Request.QueryString["ID"]%>';
            var url = '../../ReportViewer.aspx?ReportName=OutPatient&Title=Out Patient Report&outPatientID=' + id;
            window.open(url, '_blanks');
        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="queueModal" class="modal fade scrollable-modal" data-backdrop="static" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable" role="document">
            <div class="modal-content">
                <div class="modal-body">
                    <div id="QueueList">
                        <div class="row" style="margin-bottom: 15px">
                            <div class="col-lg-3">
                                <select class="" id="ddlPatientDepartment" onchange="fillPendingPatientsList();" runat="server"></select>
                            </div>
                            <div id="divFilterClinic" class="col-lg-3" style="display: none">
                                <select class="select2-enable" id="ddlFilterClinic" onchange="fillPendingPatientsList();" runat="server"></select>
                            </div>
                            <div class="col-lg-1">
                                <input type="checkbox" id="isPrivate" />
                            </div>
                            <div class="col-lg-2">
                                <label>Private</label>
                            </div>
                            <div id="divdocname" class="col-lg-3" style="display: none">
                                <select class="select2-enable" id="ddldocname" onchange="fillPendingPatientsList();" runat="server"></select>
                            </div>
                            <div class="col-lg-2 text-end">
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
                                        <th>Dept Token #</th>
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
    <div class="menu-item no-submenu" name="complaints" style="display:none" id="06" onclick="navigateAction(this)">
        <div class="menu-title">
            <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/complaints.png" class="sidebarIcon">
            <span>Complaints</span>
        </div>
    </div>
    <div class="menu-item no-submenu" name="symptoms" style="display:none" id="01" onclick="navigateAction(this)">
        <div class="menu-title">
            <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/symptoms.png" class="sidebarIcon">
            <span>Symptoms</span>
        </div>
    </div>
    <div class="menu-item no-submenu" name="vitals" style="display:none" id="02" onclick="navigateAction(this)">
        <div class="menu-title">
            <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/vitals.png" class="sidebarIcon">
            <span>Vitals</span>
        </div>
    </div>
    <div class="menu-item no-submenu" name="history" style="display:none" id="03" onclick="navigateAction(this)">
        <div class="menu-title">
            <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/history.png" class="sidebarIcon">
            <span>History</span>
        </div>
    </div>
    <div class="menu-item no-submenu" name="examination" style="display:none" id="04" onclick="navigateAction(this)">
        <div class="menu-title">
            <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/examination.png" class="sidebarIcon">
            <span>Examination</span>
        </div>
    </div>
    <div class="menu-item no-submenu" name="primary_diagnosis" style="display:none" id="07" onclick="navigateAction(this)">
        <div class="menu-title">
            <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/primarydiagnosis.png" class="sidebarIcon">
            <span>Primary Diagnosis</span>
        </div>
    </div>
    <div class="menu-item no-submenu" name="final_diagnosis" style="display:none" id="08" onclick="navigateAction(this)">
        <div class="menu-title">
            <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/finaldiagnosis.png" class="sidebarIcon">
            <span>Final Diagnosis</span>
        </div>
    </div>
    <div class="menu-item no-submenu" name="investigation" style="display:none" id="09" onclick="navigateAction(this)">
        <div class="menu-title">
            <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/investigation.png" class="sidebarIcon">
            <span>Investigation</span>
        </div>
    </div>
    <div class="menu-item no-submenu" name="diagnostics" style="display:none" id="10" onclick="navigateAction(this)">
        <div class="menu-title">
            <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/diagnostics.png" class="sidebarIcon">
            <span>Diagnostics</span>
        </div>
    </div>
    <div class="menu-item no-submenu" name="medication" style="display:none" id="11" onclick="navigateAction(this)">
        <div class="menu-title">
            <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/medication.png" class="sidebarIcon">
            <span>Medication</span>
        </div>
    </div>
    <div class="menu-item no-submenu" name="services_procedures" style="display:none" id="14" onclick="navigateAction(this)">
        <div class="menu-title">
            <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/medication.png" class="sidebarIcon">
            <span>Services/Procedures</span>
        </div>
    </div>
    <div class="menu-item no-submenu" name="follow_up" style="display:none" id="12" onclick="navigateAction(this)">
        <div class="menu-title">
            <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/followup.png" class="sidebarIcon">
            <span>Follow Up</span>
        </div>
    </div>
    <div class="menu-item no-submenu" name="disposal" style="display:none" id="13" onclick="navigateAction(this)">
        <div class="menu-title">
            <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/disposal.png" class="sidebarIcon">
            <span>Disposal</span>
        </div>
    </div>
    <div class="menu-item no-submenu" name="refer_to" style="display:none" id="05" onclick="navigateAction(this)">
        <div class="menu-title">
            <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/refer.png" class="sidebarIcon" />
            <span>Refer To</span>
        </div>
    </div>
</div>
        </div>
        <div class="col-lg-10 grow-col" style="margin-top: 10px">
            <div class="row">
                <div class="col-lg-2">
                    <div style="width: fit-content !important;" class="retractIcon">
                        <img onclick="toggleRetract()" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/sidebar.png"
                            alt="Sidebar Toggle" class="sidebarToggleIcon" />
                    </div>
                </div>
                <div class="col-lg-10">
                    <div style="display: flex; justify-content: flex-end;">
                        <input type="button" class="btn btn-primry" value="EMR" onclick="ShowHistory()" />
                        <input type="button" class="btn btn-primry" value="Queue" onclick="openQueue()" />
                        <label class="mybutton2-wrapper">
                            <input type="checkbox" id="DischargeCheckBox" onchange="toggleDischarge(this)" />
                            <span id="DischargeButtonText">Discharge</span>
                        </label>
                        <input type="button" class="btn btn-primry" value="Reset" onclick="ResetForm()" />
                        <input id="btnSave" type="button" class="btn btn-primry" value="Save" onclick="SaveMedicines()" />

                        <input type="button" class="btn btn-primry" value="Prescription" name="name" onclick="PrintoutPatient();" />

                        <input type="button" class="btn btn-primry" value="Voucher" name="Voucher" id="Voucher" onclick="PrintVoucher();" style="display:none;" />
                        <input type="button" class="btn btn-primry" value="List View" name="name" onclick="window.location = 'OutPatientsView.aspx'" />
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
                                                    <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/Patient.png" alt="Patient Image" class="img-fluid patient-image" />
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
                                                    <asp:Label ID="lblPatien_No" CssClass="labels" runat="server" Text="MR No:"></asp:Label>
                                                </div>
                                                <div class="col-md-7 col-sm-6">
                                                    <asp:Label ID="Label200" CssClass="md" runat="server"></asp:Label>
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
                                            <div class="row mb-3">
                                                <div class="col-md-5 col-sm-6">
                                                    <asp:Label CssClass="labels" runat="server" Text="Medical History:"></asp:Label>
                                                </div>                                               
                                            </div>
                                            <div class="row mb-3">
                                                <div class="col-md-7 col-sm-6">
                                                    <div style="display: flex; gap: 15px; flex-wrap: wrap;">

                                                        <div style="display: flex; align-items: center;">
                                                            <asp:CheckBox ID="chkSmokers" runat="server" />
                                                            <label for="ctl00_MainContent_chkSmokers" style="margin-left: 5px; margin-bottom: 0;">Smoker</label>
                                                        </div>

                                                        <div style="display: flex; align-items: center;">
                                                            <asp:CheckBox ID="chkDiabetics" runat="server" />
                                                            <label for="ctl00_MainContent_chkDiabetics" style="margin-left: 5px; margin-bottom: 0;">Diabetic</label>
                                                        </div>

                                                        <div style="display: flex; align-items: center;">
                                                            <asp:CheckBox ID="chkAlcoholConsumption" runat="server" />
                                                            <label for="ctl00_MainContent_chkAlcoholConsumption" style="margin-left: 5px; margin-bottom: 0;">Alcohol Consumption</label>
                                                        </div>

                                                        <div style="display: flex; align-items: center;">
                                                            <asp:CheckBox ID="chkHypertensive" runat="server" />
                                                            <label for="ctl00_MainContent_chkHypertensive" style="margin-left: 5px; margin-bottom: 0;">Hypertensive</label>
                                                        </div>

                                                        <div style="display: flex; align-items: center;">
                                                            <asp:CheckBox ID="chkSmokeless" runat="server" />
                                                            <label for="ctl00_MainContent_chkSmokeless" style="margin-left: 5px; margin-bottom: 0;">Naswar/Smokeless</label>
                                                        </div>

                                                        <div style="display: flex; align-items: center; display: none;">
                                                            <asp:CheckBox ID="chkNon_Smokers" runat="server" />
                                                            <label for="ctl00_MainContent_chkNon_Smokers" style="margin-left: 5px; margin-bottom: 0;">Non-Smoker</label>
                                                        </div>
                                                    </div>
                                              </div>                                        
                                            </div>
                                            <div class="row">
                                                <div class="col-md-12">
                                                    <h2>Co-Morbid Conditions</h2>
                                                    <div style="display: flex; gap: 15px; flex-wrap: wrap; align-items: center;">
                                                      <div style="display: flex; align-items: center;">
                                                            <asp:CheckBox ID="chkDM" runat="server" />
                                                            <label for="ctl00_MainContent_chkDM" style="margin-left: 5px; margin-bottom: 0;">DM</label>
                                                        </div>
                                                        <div style="display: flex; align-items: center;">
                                                            <asp:CheckBox ID="chkHTN" runat="server" />
                                                            <label for="ctl00_MainContent_chkHTN" style="margin-left: 5px; margin-bottom: 0;">HTN</label>
                                                        </div>
                                                    </div>
                                                    <div style="display: flex; gap: 15px; flex-wrap: wrap; align-items: center;">
                                                        <div style="display: flex; align-items: center;">
                                                            <asp:CheckBox ID="chkTB" runat="server" />
                                                            <label for="ctl00_MainContent_chkTB" style="margin-left: 5px; margin-bottom: 0;">TB</label>
                                                        </div>
                                                        <div style="display: flex; align-items: center;">
                                                            <asp:CheckBox ID="chkIHD" runat="server"  Style="margin-left:6px !important"/>
                                                            <label for="ctl00_MainContent_chkIHD" style="margin-left: 10px; margin-bottom: 0;">IHD</label>
                                                        </div>
                                                    </div>
                                                    <div style="display: flex; align-items: center;">
                                                        <asp:CheckBox ID="chkAsthma" runat="server" />
                                                        <label for="ctl00_MainContent_chkAsthma" style="margin-left: 6px; margin-bottom: 0;">Asthma</label>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row mb-3" style="display: none">
                                                <div class="col-md-5 col-sm-6">
                                                    <asp:Label ID="Doctor" CssClass="labels" runat="server" Text="Doctor:"></asp:Label>
                                                    <input type="hidden" id="hdndoctors_id" runat="server" />
                                                    <input type="hidden" id="hdnStatus" runat="server" />
                                                    <input type="hidden" id="hdnVoucher_id" runat="server" />
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
                                                    <select class="select2-enable" id="filterDepartments">
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
                                        <div class="vitals-container">
                                            <!-- Pulse -->
                                            <div class="vital-row" style="display: flex; align-items: center; justify-content: space-between;">
                                                <div style="display: flex; align-items: center;">
                                                    <asp:Label Style="width: 200px;" ID="LblPuls" runat="server" Text="Pulse (Beats/min)"></asp:Label>
                                                    <asp:TextBox ID="txtPuls" runat="server" TabIndex="1"></asp:TextBox>
                                                </div>
                                            </div>

                                            <!-- BP -->
                                            <div class="vital-row" style="display: flex; align-items: center; justify-content: space-between;">
                                                <div style="display: flex; align-items: center;">
                                                    <asp:Label Style="width: 200px;" ID="LblBP" runat="server" Text="B.P (mmHg)"></asp:Label>
                                                    <asp:TextBox ID="txtBP" runat="server" placeholder="120/80" TabIndex="2"></asp:TextBox>
                                                </div>
                                            </div>

                                            <!-- Temp -->
                                            <div class="vital-row" style="display: flex; align-items: center; justify-content: space-between;">
                                                <div style="display: flex; align-items: center;">
                                                    <asp:Label Style="width: 200px;" ID="LblTemp" runat="server" Text="Temp (°F)"></asp:Label>
                                                    <asp:TextBox ID="txtTemp" runat="server" TabIndex="3"></asp:TextBox>
                                                </div>
                                            </div>

                                            <!-- Respiration -->
                                            <div class="vital-row" style="display: flex; align-items: center; justify-content: space-between;">
                                                <div style="display: flex; align-items: center;">
                                                    <asp:Label Style="width: 200px;" ID="Label12" runat="server" Text="Respiration (Breaths/min)"></asp:Label>
                                                    <asp:TextBox ID="txtRespiration" runat="server" TabIndex="4"></asp:TextBox>
                                                </div>
                                            </div>

                                            <!-- Height -->
                                            <div class="vital-row" style="display: flex; align-items: center; justify-content: space-between;">
                                                <div style="display: flex; align-items: center;">
                                                    <asp:Label Style="width: 200px;" ID="LblHeight" runat="server" Text="Height (ft.cm)"></asp:Label>
                                                    <asp:TextBox ID="txtHeight" placeholder="5.2" runat="server" TabIndex="5"></asp:TextBox>
                                                </div>
                                            </div>

                                            <!-- Weight -->
                                            <div class="vital-row" style="display: flex; align-items: center; justify-content: space-between;">
                                                <div style="display: flex; align-items: center;">
                                                    <asp:Label Style="width: 200px;" ID="LblWeight" runat="server" Text="Weight (kgs)"></asp:Label>
                                                    <asp:TextBox ID="txtWeight" onchange="calculateBMI()" runat="server" TabIndex="6"></asp:TextBox>
                                                </div>
                                            </div>

                                            <!-- SPO2 -->
                                            <div class="vital-row" style="display: flex; align-items: center; justify-content: space-between;">
                                                <div style="display: flex; align-items: center;">
                                                    <asp:Label Style="width: 200px;" ID="LBL_SPO2" runat="server" Text="SPO2"></asp:Label>
                                                    <asp:TextBox ID="txtspo2" runat="server" TabIndex="7"></asp:TextBox>
                                                </div>
                                            </div>

                                            <!-- LMP -->
                                            <div class="vital-row" style="display: flex; align-items: center; justify-content: space-between;">
                                                <div style="display: flex; align-items: center;">
                                                    <asp:Label Style="width: 200px;" ID="LBL_LMP" runat="server" Text="L.M.P"></asp:Label>
                                                    <asp:TextBox ID="txtLMP" runat="server" TabIndex="7"></asp:TextBox>
                                                </div>
                                            </div>

                                            <!-- BSR -->
                                            <div class="vital-row" style="display: flex; align-items: center; justify-content: space-between;">
                                                <div style="display: flex; align-items: center;">
                                                    <asp:Label Style="width: 200px;" ID="Label35" runat="server" Text="BSR"></asp:Label>
                                                    <asp:TextBox ID="TxtBSR" runat="server" TabIndex="9" CssClass="align"></asp:TextBox>
                                                </div>
                                            </div>

                                            <!-- BMI -->
                                            <div class="vital-row" style="display: flex; align-items: center; justify-content: space-between;">
                                                <div style="display: flex; align-items: center;">
                                                    <asp:Label Style="width: 200px;" ID="LblBMI" runat="server" Text="BMI"></asp:Label>
                                                    <asp:TextBox ID="txtBMI" runat="server" TabIndex="10"></asp:TextBox>
                                                </div>
                                            </div>

                                            <!-- MUAC -->
                                            <div class="vital-row" style="display: flex; align-items: center; justify-content: space-between; display: none !important">
                                                <div style="display: flex; align-items: center;">
                                                    <asp:Label Style="width: 200px;" ID="lblMUAC" runat="server" Text="MUAC(cm)"></asp:Label>
                                                    <asp:TextBox ID="txtMUAC" runat="server" TabIndex="11"></asp:TextBox>
                                                </div>
                                            </div>

                                            <!-- EDD -->
                                            <div class="vital-row" style="display: flex; align-items: center; justify-content: space-between; display: none !important">
                                                <div style="display: flex; align-items: center;">
                                                    <asp:Label Style="width: 200px;" ID="Label34" runat="server" Text="EDD"></asp:Label>
                                                    <asp:TextBox ID="txtedd" runat="server" TabIndex="8"></asp:TextBox>
                                                </div>
                                            </div>

                                            <!-- OFC -->
                                            <div class="vital-row" style="display: flex; align-items: center; justify-content: space-between; display: none !important">
                                                <div style="display: flex; align-items: center;">
                                                    <asp:Label Style="width: 200px;" ID="lblOFC" runat="server" Text="OFC(cm)"></asp:Label>
                                                    <asp:TextBox ID="txtOFC" runat="server" TabIndex="12"></asp:TextBox>
                                                </div>
                                            </div>

                                            <!-- Refer To Hospital -->
                                            <div class="vital-row" style="display: flex; align-items: center; justify-content: space-between; display: none !important">
                                                <div style="display: flex; align-items: center;">
                                                    <asp:Label Style="width: 200px;" ID="LblRefer_To_Hospital" runat="server" Text="Refer To Hospital"></asp:Label>
                                                    <asp:TextBox ID="txtRefer_To_Hospital" runat="server" TextMode="MultiLine" TabIndex="9"></asp:TextBox>
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
                                                    <asp:Label Style="width: 75%;" ID="Label2" runat="server" Text="History Of Present Illness"></asp:Label>
                                                    <asp:TextBox ID="txtHistoryOfPeresentIllness" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="1"></asp:TextBox>
                                                </div>
                                            </div>

                                            <!-- Past History -->
                                            <div class="history-row">
                                                <div style="display: flex; align-items: center; width: 100%">
                                                    <asp:Label Style="width: 75%;" ID="d" runat="server" Text="Past History"></asp:Label>
                                                    <asp:TextBox ID="txtHistoryOfPastIllness" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="2"></asp:TextBox>
                                                </div>
                                            </div>

                                            <!-- Birth History -->
                                            <div class="history-row">
                                                <div style="display: flex; align-items: center; width: 100%">
                                                    <asp:Label Style="width: 75%;" ID="Label15" runat="server" Text="Birth History"></asp:Label>
                                                    <asp:TextBox ID="txtBirthHistory" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="3"></asp:TextBox>
                                                </div>
                                            </div>

                                            <!-- Gynae History -->
                                            <div class="history-row">
                                                <div style="display: flex; align-items: center; width: 100%">
                                                    <asp:Label Style="width: 75%;" ID="Label16" runat="server" Text="Gynae"></asp:Label>
                                                    <asp:TextBox ID="txtGYNAE" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="4"></asp:TextBox>
                                                </div>
                                            </div>

                                            <!-- Drug History -->
                                            <div class="history-row">
                                                <div style="display: flex; align-items: center; width: 100%">
                                                    <asp:Label Style="width: 75%;" ID="Label8" runat="server" Text="Drug History"></asp:Label>
                                                    <asp:TextBox ID="txtDrugHistory" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="5"></asp:TextBox>
                                                </div>
                                            </div>

                                            <!-- Personal History -->
                                            <div class="history-row">
                                                <div style="display: flex; align-items: center; width: 100%">
                                                    <asp:Label Style="width: 75%;" ID="Label17" runat="server" Text="Personal History"></asp:Label>
                                                    <asp:TextBox ID="txtPersonalHistory" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="6"></asp:TextBox>
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

                                            <!-- Development History -->
                                            <div class="history-row">
                                                <div style="display: flex; align-items: center; width: 100%">
                                                    <asp:Label Style="width: 75%;" ID="lblDevelopmentHistory" runat="server" Text="Development History"></asp:Label>
                                                    <asp:TextBox ID="txtDevelopmentHistory" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="10"></asp:TextBox>
                                                </div>
                                            </div>

                                            <!-- Vaccination History -->
                                            <div class="history-row">
                                                <div style="display: flex; align-items: center; width: 100%">
                                                    <asp:Label Style="width: 75%;" ID="lblVaccinationHistory" runat="server" Text="Vaccination History"></asp:Label>
                                                    <asp:TextBox ID="txtVaccinationHistory" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="11"></asp:TextBox>
                                                </div>
                                            </div>

                                            <!-- Nutrition History -->
                                            <div class="history-row">
                                                <div style="display: flex; align-items: center; width: 100%">
                                                    <asp:Label Style="width: 75%;" ID="lblNutritionHistory" runat="server" Text="Nutrition History"></asp:Label>
                                                    <asp:TextBox ID="txtNutritionHistory" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="12"></asp:TextBox>
                                                </div>
                                            </div>

                                            <!-- Family History -->
                                            <div class="history-row">
                                                <div style="display: flex; align-items: center; width: 100%">
                                                    <asp:Label Style="width: 75%;" ID="Label3" runat="server" Text="Family History"></asp:Label>
                                                    <asp:TextBox ID="txtHistoryOfFamily" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="13"></asp:TextBox>
                                                </div>
                                            </div>

                                            <!-- SocioEconomic History -->
                                            <div class="history-row">
                                                <div style="display: flex; align-items: center; width: 100%">
                                                    <asp:Label Style="width: 75%;" ID="Label5" runat="server" Text="SocioEconomic History"></asp:Label>
                                                    <asp:TextBox ID="txtSocioEconomicHistory" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="14"></asp:TextBox>
                                                </div>
                                            </div>

                                        </div>
                                    </div>
                                    <div class="tabs" id="tab04" style="display: none">
                                        <div class="row">
                                            <div class="col-md-5 col-sm-12">
                                                <select id="filterExaminations">
                                                    <option value="001">General Physical</option>
                                                    <option value="002">Systematic</option>
                                                    <option value="004">Gynae</option>
                                                    <option value="005">OBS</option>
                                                    <option value="003">Special</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div id="subTab001" class="general-exam-container subtabs">
                                            <!-- Row 1 -->
                                            <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
                                                <!-- Pallor -->
                                                <div class="exam-row" style="display: flex; align-items: center; width: 48%; cursor: pointer;"
                                                    onclick="document.getElementById('ctl00_MainContent_chkPallor').click()">
                                                    <asp:CheckBox ID="chkPallor" runat="server"
                                                        onclick="event.stopPropagation(); this.checked ? Add_GeneralExamRow('Pallor') : Remove_GeneralExamRow('Pallor')" />
                                                    <label for="ctl00_MainContent_chkPallor" style="margin-left: 8px; cursor: pointer;">Pallor</label>
                                                </div>

                                                <!-- JVP -->
                                                <div class="exam-row" style="display: flex; align-items: center; width: 48%; cursor: pointer;"
                                                    onclick="document.getElementById('ctl00_MainContent_chkJVP').click()">
                                                    <asp:CheckBox ID="chkJVP" runat="server"
                                                        onclick="event.stopPropagation(); this.checked ? Add_GeneralExamRow('JVP') : Remove_GeneralExamRow('JVP')" />
                                                    <label for="ctl00_MainContent_chkJVP" style="margin-left: 8px; cursor: pointer;">JVP</label>
                                                </div>
                                            </div>

                                            <!-- Row 2 -->
                                            <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
                                                <!-- Cyanosis -->
                                                <div class="exam-row" style="display: flex; align-items: center; width: 48%; cursor: pointer;"
                                                    onclick="document.getElementById('ctl00_MainContent_chkCyanosis').click()">
                                                    <asp:CheckBox ID="chkCyanosis" runat="server"
                                                        onclick="event.stopPropagation(); this.checked ? Add_GeneralExamRow('Cyanosis') : Remove_GeneralExamRow('Cyanosis')" />
                                                    <label for="ctl00_MainContent_chkCyanosis" style="margin-left: 8px; cursor: pointer;">Cyanosis</label>
                                                </div>

                                                <!-- Disoriented -->
                                                <div class="exam-row" style="display: flex; align-items: center; width: 48%; cursor: pointer;"
                                                    onclick="document.getElementById('ctl00_MainContent_chkDisoriented').click()">
                                                    <asp:CheckBox ID="chkDisoriented" runat="server"
                                                        onclick="event.stopPropagation(); this.checked ? Add_GeneralExamRow('Disoriented') : Remove_GeneralExamRow('Disoriented')" />
                                                    <label for="ctl00_MainContent_chkDisoriented" style="margin-left: 8px; cursor: pointer;">Disoriented</label>
                                                </div>
                                            </div>

                                            <!-- Row 3 -->
                                            <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
                                                <!-- Jaundice -->
                                                <div class="exam-row" style="display: flex; align-items: center; width: 48%; cursor: pointer;"
                                                    onclick="document.getElementById('ctl00_MainContent_chkJaundice').click()">
                                                    <asp:CheckBox ID="chkJaundice" runat="server"
                                                        onclick="event.stopPropagation(); this.checked ? Add_GeneralExamRow('Jaundice') : Remove_GeneralExamRow('Jaundice')" />
                                                    <label for="ctl00_MainContent_chkJaundice" style="margin-left: 8px; cursor: pointer;">Jaundice</label>
                                                </div>

                                                <!-- Dehydration -->
                                                <div class="exam-row" style="display: flex; align-items: center; width: 48%; cursor: pointer;"
                                                    onclick="document.getElementById('ctl00_MainContent_chkDehydration').click()">
                                                    <asp:CheckBox ID="chkDehydration" runat="server"
                                                        onclick="event.stopPropagation(); this.checked ? Add_GeneralExamRow('Dehydration') : Remove_GeneralExamRow('Dehydration')" />
                                                    <label for="ctl00_MainContent_chkDehydration" style="margin-left: 8px; cursor: pointer;">Dehydration</label>
                                                </div>
                                            </div>

                                            <!-- Row 4 -->
                                            <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
                                                <!-- Edema -->
                                                <div class="exam-row" style="display: flex; align-items: center; width: 48%; cursor: pointer;"
                                                    onclick="document.getElementById('ctl00_MainContent_chkEdema').click()">
                                                    <asp:CheckBox ID="chkEdema" runat="server"
                                                        onclick="event.stopPropagation(); this.checked ? Add_GeneralExamRow('Edema') : Remove_GeneralExamRow('Edema')" />
                                                    <label for="ctl00_MainContent_chkEdema" style="margin-left: 8px; cursor: pointer;">Edema</label>
                                                </div>

                                                <!-- Lymphadenopathy -->
                                                <div class="exam-row" style="display: flex; align-items: center; width: 48%; cursor: pointer;"
                                                    onclick="document.getElementById('ctl00_MainContent_chkLymphadenopathy').click()">
                                                    <asp:CheckBox ID="chkLymphadenopathy" runat="server"
                                                        onclick="event.stopPropagation(); this.checked ? Add_GeneralExamRow('Lymphadenopathy') : Remove_GeneralExamRow('Lymphadenopathy')" />
                                                    <label for="ctl00_MainContent_chkLymphadenopathy" style="margin-left: 8px; cursor: pointer;">Lymphadenopathy</label>
                                                </div>
                                            </div>

                                            <!-- Row 5 -->
                                            <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
                                                <!-- Clubbing -->
                                                <div class="exam-row" style="display: flex; align-items: center; width: 48%; cursor: pointer;"
                                                    onclick="document.getElementById('ctl00_MainContent_chkClubbing').click()">
                                                    <asp:CheckBox ID="chkClubbing" runat="server"
                                                        onclick="event.stopPropagation(); this.checked ? Add_GeneralExamRow('Clubbing') : Remove_GeneralExamRow('Clubbing')" />
                                                    <label for="ctl00_MainContent_chkClubbing" style="margin-left: 8px; cursor: pointer;">Clubbing</label>
                                                </div>

                                                <!-- Dyspnoea -->
                                                <div class="exam-row" style="display: flex; align-items: center; width: 48%; cursor: pointer;"
                                                    onclick="document.getElementById('ctl00_MainContent_chkDyspnoea').click()">
                                                    <asp:CheckBox ID="chkDyspnoea" runat="server"
                                                        onclick="event.stopPropagation(); this.checked ? Add_GeneralExamRow('Dyspnoea') : Remove_GeneralExamRow('Dyspnoea')" />
                                                    <label for="ctl00_MainContent_chkDyspnoea" style="margin-left: 8px; cursor: pointer;">Dyspnoea</label>
                                                </div>
                                            </div>

                                            <!-- Row 6 -->
                                            <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
                                                <!-- Neck Swelling -->
                                                <div class="exam-row" style="display: flex; align-items: center; width: 48%; cursor: pointer;"
                                                    onclick="document.getElementById('ctl00_MainContent_chkNeckSwelling').click()">
                                                    <asp:CheckBox ID="chkNeckSwelling" runat="server"
                                                        onclick="event.stopPropagation(); this.checked ? Add_GeneralExamRow('NeckSwelling') : Remove_GeneralExamRow('NeckSwelling')" />
                                                    <label for="ctl00_MainContent_chkNeckSwelling" style="margin-left: 8px; cursor: pointer;">Neck Swelling</label>
                                                </div>

                                                <!-- Skin Lesions -->
                                                <div class="exam-row" style="display: flex; align-items: center; width: 48%; cursor: pointer;"
                                                    onclick="document.getElementById('ctl00_MainContent_chkSkinLesions').click()">
                                                    <asp:CheckBox ID="chkSkinLesions" runat="server"
                                                        onclick="event.stopPropagation(); this.checked ? Add_GeneralExamRow('SkinLesions') : Remove_GeneralExamRow('SkinLesions')" />
                                                    <label for="ctl00_MainContent_chkSkinLesions" style="margin-left: 8px; cursor: pointer;">Skin Lesions</label>
                                                </div>
                                            </div>

                                            <!-- Row 7 -->
                                            <div style="margin-bottom: 10px;">
                                                <div class="exam-text-row">
                                                    <div style="display: flex; align-items: center; width: 100%">
                                                        <asp:Label Style="width: 75%;" ID="Label4" runat="server" Text="Other"></asp:Label>
                                                        <asp:TextBox ID="txtInputBox1" runat="server" TextMode="MultiLine" Rows="3" Width="100%" TabIndex="11"></asp:TextBox>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div id="subTab002" class="subtabs" style="display: none">
                                            <div class="exam-container" style="width: 100%;">

                                                <!-- DRE Checkbox Row -->
                                                <div class="Systematic-Exam-Row" style="display: flex; align-items: center; width: 100%; margin-bottom: 15px; display: none !important">
                                                    <asp:Label Style="width: 75%;" ID="LabelDRE" runat="server" Text="DRE"></asp:Label>
                                                    <div style="width: 100%;">
                                                        <asp:CheckBox ID="chkDRE" runat="server" CssClass="systematic-checkbox" />
                                                    </div>
                                                </div>

                                                <!-- Proctoscopy Checkbox Row -->
                                                <div class="Systematic-Exam-Row" style="display: flex; align-items: center; width: 100%; margin-bottom: 15px; display: none !important">
                                                    <asp:Label Style="width: 75%; padding-right: 15px;" ID="LabelProctoscopy" runat="server" Text="Proctoscopy"></asp:Label>
                                                    <div style="width: 100%;">
                                                        <asp:CheckBox ID="chkProctoscopy" runat="server" CssClass="systematic-checkbox" />
                                                    </div>
                                                </div>

                                                <!-- CNS Examination -->
                                                <div class="Systematic-Exam-Row">
                                                    <div style="display: flex; align-items: center; width: 100%">
                                                        <asp:Label Style="width: 75%;" ID="Label6" runat="server" Text="CNS Examination"></asp:Label>
                                                        <asp:TextBox ID="txtCNS" TextMode="MultiLine" Rows="3" Width="100%" runat="server" CssClass="systematic-textbox"></asp:TextBox>
                                                    </div>
                                                </div>

                                                <!-- CVS Examination -->
                                                <div class="Systematic-Exam-Row">
                                                    <div style="display: flex; align-items: center; width: 100%">
                                                        <asp:Label Style="width: 75%;" ID="Label10" runat="server" Text="CVS Examination"></asp:Label>
                                                        <asp:TextBox ID="txtCVS" TextMode="MultiLine" Rows="3" Width="100%" runat="server" CssClass="systematic-textbox"></asp:TextBox>
                                                    </div>
                                                </div>

                                                <!-- Respiration Examination -->
                                                <div class="Systematic-Exam-Row">
                                                    <div style="display: flex; align-items: center; width: 100%">
                                                        <asp:Label Style="width: 75%;" ID="Label13" runat="server" Text="Respiration Examination"></asp:Label>
                                                        <asp:TextBox ID="txtRESP" TextMode="MultiLine" Rows="3" Width="100%" runat="server" CssClass="systematic-textbox"></asp:TextBox>
                                                    </div>
                                                </div>

                                                <!-- GI Examination -->
                                                <div class="Systematic-Exam-Row">
                                                    <div style="display: flex; align-items: center; width: 100%">
                                                        <asp:Label Style="width: 75%;" ID="Label50" runat="server" Text="GI Examination"></asp:Label>
                                                        <asp:TextBox ID="txtGIT" TextMode="MultiLine" Rows="3" Width="100%" runat="server" CssClass="systematic-textbox"></asp:TextBox>
                                                    </div>
                                                </div>

                                                <!-- Abdomin -->
                                                <div class="Systematic-Exam-Row">
                                                    <div style="display: flex; align-items: center; width: 100%">
                                                        <asp:Label Style="width: 75%;" ID="lblAbdomin" runat="server" Text="Abdomin"></asp:Label>
                                                        <asp:TextBox ID="txtAbdomin" TextMode="MultiLine" Rows="3" Width="100%" runat="server" CssClass="systematic-textbox"></asp:TextBox>
                                                    </div>
                                                </div>

                                                <!-- Urogenital System -->
                                                <div class="Systematic-Exam-Row">
                                                    <div style="display: flex; align-items: center; width: 100%">
                                                        <asp:Label Style="width: 75%;" ID="Label51" runat="server" Text="Urogenital System"></asp:Label>
                                                        <asp:TextBox ID="txtUGS" TextMode="MultiLine" Rows="3" Width="100%" runat="server" CssClass="systematic-textbox"></asp:TextBox>
                                                    </div>
                                                </div>

                                                <!-- Musculoskeletal System -->
                                                <div class="Systematic-Exam-Row">
                                                    <div style="display: flex; align-items: center; width: 100%">
                                                        <asp:Label Style="width: 75%;" ID="Label52" runat="server" Text="Musculoskeletal System"></asp:Label>
                                                        <asp:TextBox ID="txtMucculor" TextMode="MultiLine" Rows="3" Width="100%" runat="server" CssClass="systematic-textbox"></asp:TextBox>
                                                    </div>
                                                </div>

                                                <!-- Local/Special Examination -->
                                                <div class="Systematic-Exam-Row">
                                                    <div style="display: flex; align-items: center; width: 100%">
                                                        <asp:Label Style="width: 75%;" ID="Label53" runat="server" Text="Local/Special Examination"></asp:Label>
                                                        <asp:TextBox ID="txtLocal" TextMode="MultiLine" Rows="3" Width="100%" runat="server" CssClass="systematic-textbox"></asp:TextBox>
                                                    </div>
                                                </div>

                                                <!-- Provisional Diagnosis -->
                                                <div class="Systematic-Exam-Row">
                                                    <div style="display: flex; align-items: center; width: 100%">
                                                        <asp:Label Style="width: 75%;" ID="Label54" runat="server" Text="Provisional Diagnosis"></asp:Label>
                                                        <asp:TextBox ID="txtProvisionalDiagnosis" TextMode="MultiLine" Rows="3" Width="100%" runat="server" CssClass="systematic-textbox"></asp:TextBox>
                                                    </div>
                                                </div>

                                                <!-- Remarks -->
                                                <div class="Systematic-Exam-Row">
                                                    <div style="display: flex; align-items: center; width: 100%">
                                                        <asp:Label Style="width: 75%;" ID="Label55" runat="server" Text="Remarks"></asp:Label>
                                                        <asp:TextBox ID="txtRemarksHistory" TextMode="MultiLine" Rows="3" Width="100%" runat="server" CssClass="systddlPatient_Main_Categoryematic-textbox"></asp:TextBox>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div id="subTab004" class="subtabs" style="display: none">
                                            <div class="exam-container" style="width: 100%;">
                                                <div class="Systematic-Exam-Row">
                                                    <div style="display: flex; align-items: center; width: 100%">
                                                        <asp:Label Style="width: 75%;" ID="Label25" runat="server" Text="P/A"></asp:Label>
                                                        <asp:TextBox ID="txtPA_Gynae" TextMode="MultiLine" Rows="3" Width="100%" runat="server" CssClass="systematic-textbox"></asp:TextBox>
                                                    </div>
                                                </div>
                                                <div class="Systematic-Exam-Row">
                                                    <div style="display: flex; align-items: center; width: 100%">
                                                        <asp:Label Style="width: 75%;" ID="Label26" runat="server" Text="P/S"></asp:Label>
                                                        <asp:TextBox ID="txtPS_Gynae" TextMode="MultiLine" Rows="3" Width="100%" runat="server" CssClass="systematic-textbox"></asp:TextBox>
                                                    </div>
                                                </div>
                                                <div class="Systematic-Exam-Row">
                                                    <div style="display: flex; align-items: center; width: 100%">
                                                        <asp:Label Style="width: 75%;" ID="Label27" runat="server" Text="Uterus"></asp:Label>
                                                        <asp:TextBox ID="txtUterus_Gynae" TextMode="MultiLine" Rows="3" Width="100%" runat="server" CssClass="systematic-textbox"></asp:TextBox>
                                                    </div>
                                                </div>
                                                <div class="Systematic-Exam-Row">
                                                    <div style="display: flex; align-items: center; width: 100%">
                                                        <asp:Label Style="width: 75%;" ID="Label28" runat="server" Text="FX"></asp:Label>
                                                        <asp:TextBox ID="txtFX_Gynae" TextMode="MultiLine" Rows="3" Width="100%" runat="server" CssClass="systematic-textbox"></asp:TextBox>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div id="subTab005" class="subtabs" style="display: none">
                                            <div class="exam-container" style="width: 100%;">
                                                <div class="Systematic-Exam-Row">
                                                    <div style="display: flex; align-items: center; width: 100%">
                                                        <asp:Label Style="width: 75%;" ID="Label23" runat="server" Text="P/S"></asp:Label>
                                                        <asp:TextBox ID="txtPS_Obs" TextMode="MultiLine" Rows="3" Width="100%" runat="server" CssClass="systematic-textbox"></asp:TextBox>
                                                    </div>
                                                </div>
                                                <div class="Systematic-Exam-Row">
                                                    <div style="display: flex; align-items: center; width: 100%">
                                                        <asp:Label Style="width: 75%;" ID="Label24" runat="server" Text="P/V"></asp:Label>
                                                        <asp:TextBox ID="txtPV_Obs" TextMode="MultiLine" Rows="3" Width="100%" runat="server" CssClass="systematic-textbox"></asp:TextBox>
                                                    </div>
                                                </div>
                                                <div class="Systematic-Exam-Row">
                                                    <div style="display: flex; align-items: center; width: 100%">
                                                        <asp:Label Style="width: 75%;" ID="Label29" runat="server" Text="SFH"></asp:Label>
                                                        <asp:TextBox ID="txtSFH_Obs" TextMode="MultiLine" Rows="3" Width="100%" runat="server" CssClass="systematic-textbox"></asp:TextBox>
                                                    </div>
                                                </div>
                                                <div class="Systematic-Exam-Row">
                                                    <div style="display: flex; align-items: center; width: 100%">
                                                        <asp:Label Style="width: 75%;" ID="Label30" runat="server" Text="LIE"></asp:Label>
                                                        <asp:TextBox ID="txtLIE_Obs" TextMode="MultiLine" Rows="3" Width="100%" runat="server" CssClass="systematic-textbox"></asp:TextBox>
                                                    </div>
                                                </div>
                                                <div class="Systematic-Exam-Row">
                                                    <div style="display: flex; align-items: center; width: 100%">
                                                        <asp:Label Style="width: 75%;" ID="Label31" runat="server" Text="Presentation"></asp:Label>
                                                        <asp:TextBox ID="txtPresentation_Obs" TextMode="MultiLine" Rows="3" Width="100%" runat="server" CssClass="systematic-textbox"></asp:TextBox>
                                                    </div>
                                                </div>
                                                <div class="Systematic-Exam-Row">
                                                    <div style="display: flex; align-items: center; width: 100%">
                                                        <asp:Label Style="width: 75%;" ID="Label32" runat="server" Text="FHR"></asp:Label>
                                                        <asp:TextBox ID="txtFHR_Obs" TextMode="MultiLine" Rows="3" Width="100%" runat="server" CssClass="systematic-textbox"></asp:TextBox>
                                                    </div>
                                                </div>
                                                <div class="Systematic-Exam-Row">
                                                    <div style="display: flex; align-items: center; width: 100%">
                                                        <asp:Label Style="width: 75%;" ID="Label33" runat="server" Text="Engagement"></asp:Label>
                                                        <asp:TextBox ID="txtEngagement_Obs" TextMode="MultiLine" Rows="3" Width="100%" runat="server" CssClass="systematic-textbox"></asp:TextBox>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div id="subTab003" class="subtabs">
                                        </div>
                                    </div>
                                    <div class="tabs" id="tab05" style="display: none">
                                        <div class="refer-row" style="display: flex; align-items: center; justify-content: space-between;">
                                            <div style="display: flex; align-items: center; width: 100%">
                                                <asp:Label Style="width: 200px;" ID="Label14" runat="server" Text="Refered To"></asp:Label>
                                                <asp:DropDownList ID="ddlPatient_Main_Category" onchange="loaddoctor_byDep()" Width="80%" runat="server" AppendDataBoundItems="true" TabIndex="21"></asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="refer-row" style="display: flex; align-items: center; justify-content: space-between;">
                                            <div style="display: flex; align-items: center; width: 100%">
                                                <asp:Label Style="width: 200px;" ID="Label18" runat="server" Text="Doctor"></asp:Label>
                                                <asp:DropDownList Style="width: 80%" ID="ddldoctors" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="refer-row" style="display: flex; align-items: center; justify-content: space-between;">
                                            <div style="display: flex; align-items: center; width: 100%">
                                                <asp:Label Style="width: 200px;" ID="Label19" runat="server" Text="Referral Note"></asp:Label>
                                                <asp:TextBox ID="txtRefferNote" TextMode="SingleLine" Width="80%" CssClass="refer-textbox" runat="server" TabIndex="22"></asp:TextBox>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="tabs" id="tab06">
                                        <div style="display: flex; justify-content: flex-end;">
                                            <input type="button" class="btn btn-primry" value="Add New" onclick="AddNewComplaint()" />
                                        </div>
                                        <div style="display: none" id="divAddNewComplaint">
                                            <div style="display: flex; justify-content: center;">
                                                <input type="text" id="NewComplaint" />
                                                <input style="width: 50% !important; margin-left: 10px;" type="button" id="btnSaveNewComplaint" onclick="saveComplaint()" class="btn btn-primry" value="Save" />
                                            </div>
                                        </div>

                                        <div class="row">
                                            <div class="col-md-7 col-sm-12">
                                                <input type="text" class="form-control mb-2" id="tab06Search" placeholder="Search..." />
                                            </div>
                                            <div class="col-md-5 col-sm-12">
                                            </div>

                                        </div>
                                        <div id="allComplaints"></div>
                                    </div>
                                    <div class="tabs" id="tab07" style="display: none">
                                        <div style="display: flex; justify-content: flex-end;">
                                            <input type="button" class="btn btn-primry" value="Add New" onclick="AddNewPrimaryDiagnosis()" />
                                        </div>
                                        <div style="display: none" id="divAddNewPrimaryDiagnosis">
                                            <div style="display: flex; justify-content: center;">
                                                <input type="text" id="NewPrimaryDiagnosis" />
                                                <input style="width: 50% !important; margin-left: 10px;" type="button" id="btnSaveNewPrimaryDiagnosis" onclick="savePrimaryDiagnosis()" class="btn btn-primry" value="Save" />
                                            </div>
                                        </div>

                                        <div class="row">
                                            <div class="col-md-7 col-sm-12">
                                                <input type="text" class="form-control mb-2" id="tab07Search" placeholder="Search..." />
                                            </div>
                                            <div class="col-md-5 col-sm-12">
                                            </div>

                                        </div>
                                        <div id="allPrimaryDiagnosis"></div>
                                    </div>
                                    <div class="tabs" id="tab08" style="display: none">
                                        <div style="display: flex; justify-content: flex-end;">
                                            <input type="button" class="btn btn-primry" value="Add New" onclick="AddNewFinalDiagnosis()" />
                                        </div>
                                        <div style="display: none" id="divAddNewFinalDiagnosis">
                                            <div style="display: flex; justify-content: center;">
                                                <input type="text" id="NewFinalDiagnosis" />
                                                <input style="width: 50% !important; margin-left: 10px;" type="button" id="btnSaveNewFinalDiagnosis" onclick="saveFinalDiagnosis()" class="btn btn-primry" value="Save" />
                                            </div>
                                        </div>

                                        <div class="row">
                                            <div class="col-md-7 col-sm-12">
                                                <input type="text" class="form-control mb-2" id="tab08Search" placeholder="Search..." />
                                            </div>
                                            <div class="col-md-5 col-sm-12">
                                            </div>

                                        </div>
                                        <div id="allFinalDiagnosis"></div>
                                    </div>
                                    <div class="tabs" id="tab09" style="display: none">
                                        <div style="display: flex; justify-content: flex-end;">
                                            <input type="button" class="btn btn-primry" value="Previous History" onclick="ShowPreviousHistory()" />
                                        </div>
                                        <div style="display:none" id="InvestigationPreviousHistory">
                                        </div>
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
                                        <div style="display: flex; justify-content: flex-end;">
                                            <input type="button" class="btn btn-primry" value="Previous History" onclick="ShowDiagnosticsPreviousHistory()" />
                                        </div>
                                        <div style="display: none" id="DiagnosticsPreviousHistory">
                                        </div>
                                        <div class="row">
                                            <div class="col-md-5 col-sm-12">
                                                <div class="big-select2">
                                                    <select class="select2-enable" id="filterMainDepartments">
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
                                            <div style="display: flex; justify-content: flex-end;">
                                                <input type="button" class="btn btn-primry" value="Previous History" onclick="ShowMedicenePreviousHistory()" />
                                            </div>
                                            <div style="display: none" id="MedicenePreviousHistory">
                                            </div>
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
                                    <div class="tabs" id="tab12" style="display: none">

                                        <div class="row" style="width: 100%;">
                                            <!-- Doctor Name -->
                                            <div class="FollowUp-Row" style="display: flex; align-items: center; margin-bottom: 12px;">
                                                <asp:Label Style="width: 200px; text-align: left; margin-right: 15px;" ID="LblDoctorName" runat="server" Text="Doctor Name <span class='RedStar'>*</span>"></asp:Label>
                                                <asp:DropDownList ID="ddlDoctorName" runat="server"
                                                    Style="height: 32px;"
                                                    CssClass="form-control"
                                                    AppendDataBoundItems="true"
                                                    onchange="LoadDesignation();">
                                                </asp:DropDownList>
                                            </div>

                                            <!-- Designation -->
                                            <div class="FollowUp-Row" style="display: flex; align-items: center; margin-bottom: 12px;">
                                                <asp:Label Style="width: 200px; text-align: left; margin-right: 15px;" ID="LblDesignation" runat="server" Text="Designation"></asp:Label>
                                                <asp:TextBox ID="txtDesignation" runat="server"
                                                    Style="width: 250px; height: 32px;"
                                                    CssClass="form-control"
                                                    ReadOnly="true">
                                                </asp:TextBox>
                                            </div>

                                            <!-- Admission -->
                                            <div class="FollowUp-Row" style="display: flex; align-items: center; margin-bottom: 12px;">
                                                <asp:Label Style="width: 200px; text-align: left; margin-right: 15px;" ID="LblAdmission" runat="server" Text="Admission"></asp:Label>
                                                <asp:DropDownList ID="ddlIssuance_Of" runat="server"
                                                    Style="height: 32px;"
                                                    CssClass="form-control"
                                                    AppendDataBoundItems="true">
                                                </asp:DropDownList>
                                            </div>

                                            <!-- Follow Up -->
                                            <div class="FollowUp-Row" style="display: flex; align-items: center; margin-bottom: 12px;">
                                                <asp:Label Style="width: 200px; text-align: left; margin-right: 15px;" ID="LblFollowUp" runat="server" Text="Follow Up <span class='RedStar'>*</span>"></asp:Label>
                                                <asp:DropDownList ID="ddlFOllowUp" runat="server"
                                                    Style="height: 32px;"
                                                    CssClass="form-control"
                                                    AppendDataBoundItems="true">
                                                </asp:DropDownList>
                                            </div>

                                            <!-- Follow Up -->
                                            <div class="FollowUp-Row" style="display: flex; align-items: center; margin-bottom: 12px;">
                                                <asp:Label Style="width: 200px; text-align: left; margin-right: 15px;" ID="LblFollowUpWeek" runat="server" Text="Follow Up Time <span class='RedStar'>*</span>"></asp:Label>
                                                <asp:DropDownList ID="ddlFOllowUpWeeks" runat="server"
                                                    Style="height: 32px;"
                                                    CssClass="form-control"
                                                    AppendDataBoundItems="true">
                                                </asp:DropDownList>
                                            </div>

                                            <!-- FollowUp Date -->
                                            <div class="FollowUp-Row" style="display: flex; align-items: center; margin-bottom: 12px;">
                                                <asp:Label Style="width: 200px; text-align: left; margin-right: 15px;" ID="LblFollowUpDate" runat="server" Text="FollowUp Date <span class='RedStar'>*</span>"></asp:Label>
                                                <asp:TextBox ID="FollowNoDate" runat="server"
                                                    Style="height: 32px;"
                                                    CssClass="form-control">
                                                </asp:TextBox>
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
                                             <div style="display: flex; align-items: center; width: 100%">
     <asp:Label Style="width: 200px;" ID="Label36" runat="server" Text="Verbal Consent"></asp:Label>
     <asp:DropDownList ID="ddlVerbalConsent"  Width="80%" runat="server" AppendDataBoundItems="true" TabIndex="21"></asp:DropDownList>
 </div>
                                             <div style="display: flex; align-items: center; width: 100%">
     <asp:Label Style="width: 200px;" ID="Label37" runat="server" Text="Lab Result"></asp:Label>
     <asp:DropDownList ID="ddlLabResult" Width="80%" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
     <input id="btnlabrpt" class="btn-primry" type="button" value="Add" onclick="InsertLabResult()"  />
 </div>


                                        </div>
                                        <h4 style="margin-top: 20px" class="btn btn-primry">Protos:</h4>
                                        <asp:DropDownList ID="ddlProto" CssClass="dropdownBackgroud" Width="50%" runat="server" onchange="AddProto();" AppendDataBoundItems="true"></asp:DropDownList>
                                    </div>
                                    <div class="tabs" id="tab14" style="display: none">
                                        <div style="display: flex; justify-content: flex-end;">
                                            <input type="button" class="btn btn-primry" value="Previous History" onclick="ToggleServicePreviousHistory()" />
                                        </div>
                                        <div style="display: none" id="ServicePreviousHistory">
                                        </div>
                                        <div class="row">
                                            <div class="col-md-7 col-sm-12">
                                                <input type="text" class="form-control mb-2" id="tabServiceSearch" placeholder="Search..." />
                                            </div>
                                            <div class="col-md-5 col-sm-12">
                                            </div>

                                        </div>
                                        <div id="allServices"></div>

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
                                                        <th style="width: 30%">Test Name</th>
                                                        <th style="display: none">Sample Received</th>
                                                        <th style="display: none">Result</th>
                                                        <th style="width: 30%">Special Tests</th>
                                                        <th style="width: 20%">Area Of Interest</th>
                                                        <th style="width: 10%">Rotation</th>
                                                        <th style="width: 10%" class="actions-col">Action</th>
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
                                <div class="col-lg-4" id="dvtblServices" style="display: none">
                                    <div class="dashboard-card">
                                        <div class="card-header">
                                            <h4><i class="fa fa-procedures"></i>Services / Procedures</h4>
                                        </div>
                                        <div class="table-responsive">
                                            <table class="table modern-table" id="tblServices">
                                                <thead>
                                                    <tr style="position: sticky; top: 0px; z-index: 10;">
                                                        <th style="display: none">Date</th>
                                                        <th>Service Name</th>
                                                        <th>Action</th>
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
                                <div class="col-lg-9" id="divtblVitals" style="display: none">
                                    <div class="dashboard-card">
                                        <div class="card-header">
                                            <h4><i class="fa fa-heartbeat"></i>Vitals</h4>
                                        </div>
                                        <div class="table-responsive">
                                            <table class="table modern-table" id="tblVitals">
                                                <thead>
                                                    <tr>
                                                        <th>Pulse</th>
                                                        <th>B.P.</th>
                                                        <th>Temp</th>
                                                        <th>Resp.</th>
                                                        <th>Height</th>
                                                        <th>Weight</th>
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
                                                        <th>Follow Up Time</th>
                                                        <th>Date</th>
                                                    </tr>
                                                </thead>
                                                <tbody></tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                                <!-- History Panel -->
                                <div class="col-lg-6" id="divtblHistory" style="display: none">
                                    <div class="dashboard-card">
                                        <div class="card-header">
                                            <h4><i class="fa fa-history"></i>History</h4>
                                        </div>
                                        <div class="table-responsive">
                                            <table class="table modern-table" id="tblHistory">
                                                <thead class="hidden">
                                                    <tr>
                                                        <th>History</th>
                                                    </tr>
                                                </thead>
                                                <tbody></tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                                <!-- Lab Result Table (Initially Hidden) -->
<div class="col-lg-6" id="dvtblResultrpt" style="display: none">
    <div class="dashboard-card">
        <div class="card-header">
            <h4><i class="fa fa-flask"></i>Lab Results</h4>
        </div>
        <div class="table-responsive">
            <table class="table modern-table" id="tblResultrpt">
                <thead>
                    <tr style="position: sticky; top: 0px; z-index: 10;">
                        <th>Lab Result</th>
                        <th>Result Name</th>
                        <th>Date</th>
                        <th>Action</th>
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
    <asp:HiddenField ID="hdfInPatientID" Value="" runat="server" />
    <asp:HiddenField ID="hdfFormType" Value="" runat="server" />
    <asp:HiddenField ID="hdfOutPatientID" Value="" runat="server" />
    <asp:HiddenField ID="hdfPatient_No" runat="server" />
    <asp:HiddenField ID="hdfdhischarge" Value="false" runat="server" />
    <asp:HiddenField ID="hdfFetch_ID" runat="server" />

</asp:Content>
