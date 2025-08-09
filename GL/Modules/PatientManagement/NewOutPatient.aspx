<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="NewOutPatient.aspx.cs" Inherits="PMS.Modules.PatientManagement.NewOutPatient" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">


    <style title="sidebar">
        label, span, .table > tbody > tr > td, select {
            font-weight: normal !important
        }

        #retract {
            transition: all 0.5s ease;
            overflow: hidden;
            width: 16.66%;
        }

            #retract.minimized {
                width: 100px;
            }

                #retract.minimized span {
                    display: none;
                }

        .preview {
            transition: all 0.5s ease;
            width: 50%;
        }

        #retract.minimized ~ .preview {
            width: 61%;
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
            background-color: #f8f9fa;
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

            .menu-item:hover {
                background-color: #438eb9;
                color: white !important;
            }

            .menu-item img {
                transition: all 0.3s ease;
            }

            .menu-item:hover img {
                filter: brightness(0) invert(1);
                transform: scale(1.1);
                backface-visibility: hidden;
                transform-style: preserve-3d;
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

        label, span, .table > tbody > tr > td, select {
            font-weight: normal !important
        }

        #retract {
            transition: all 0.5s ease;
            overflow: hidden;
            width: 16.66%;
        }

            #retract.minimized {
                width: 100px;
            }

                #retract.minimized span {
                    display: none;
                }

        .preview {
            transition: all 0.5s ease;
            width: 50%;
        }

        #retract.minimized ~ .preview {
            width: 61%;
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
            background-color: #f8f9fa;
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

            .menu-item:hover {
                background-color: #438eb9;
                color: white !important;
            }

            .menu-item img {
                transition: all 0.3s ease;
            }

            .menu-item:hover img {
                filter: brightness(0) invert(1);
                transform: scale(1.1);
                backface-visibility: hidden;
                transform-style: preserve-3d;
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
    </style>

    <style>
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

        th {
            color: white !important
        }

        .container-fluid {
            padding-left: 0px !important
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


        .symptom-row, .vital-row, .history-row, .exam-row, .exam-text-row, .Systematic-Exam-Row, .refer-row,
        .complaint-row, .Primary-Diagnosis-row, .Final-Diagnosis-row, .labtest-row, .diagnosticTest-row, .Medicene-row, .FollowUp-Row, .Disposal-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 2px;
            height: 45px;
            background-color: white;
            border-radius: 13px;
            color: black;
            transition: background-color 0.3s ease, color 0.3s ease;
            padding: 0 16px;
            cursor: pointer;
        }

        .history-row, .exam-text-row, .Systematic-Exam-Row, .Primary-Diagnosis-row, .Final-Diagnosis-row, .Disposal-row {
            height: 60px !important;
        }

            .symptom-row:hover, .vital-row:hover, .history-row:hover, .exam-row:hover,
            .exam-text-row:hover, .Systematic-Exam-Row:hover, .refer-row:hover,
            .complaint-row:hover, .Primary-Diagnosis-row:hover, .Final-Diagnosis-row:hover, .labtest-row:hover, .diagnosticTest-row:hover, .Medicene-row:hover, .FollowUp-Row:hover, .Disposal-row:hover {
                background-color: #438eb9;
                color: white !important;
                transform: scale(1.02);
                transition: background-color 0.3s ease, color 0.3s ease, transform 0.2s ease;
            }

                .labtest-row:hover .labtest-label {
                    color: white !important;
                }

        diagnostictest-label
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
            color: #438eb9 !important;
            font-weight: bold !important;
            font-size: 16px;
            transition: all 0.3s ease;
            margin-bottom: 5px;
            border: 0px !important;
            margin-left: 5px;
            margin-right: 5px;
        }

        .mybutton2 {
            font-size: 16px !important;
            width: fit-content !important;
            background-color: #438eb9;
            padding: 3px 12px;
            border-radius: 8px;
            margin: 0;
            color: white !important;
            font-weight: bold !important;
            font-size: 16px;
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
                    '<td><a href="#" onclick="RemoveSymtomRowInModal(\'' + id + '\')"><i class="fa fa-trash"></i></a></td></tr>';


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
                                '<td><a href="#" onclick="RemoveSymtomRowInModal(\'' + symptom.SymptomId + '\')"><i class="fa fa-trash"></i></a></td>' +
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
                    url: "NewOutPatient.aspx/SaveSymptoms", // Update with your actual endpoint
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
    </script>
    <script id="DocumentReady">
        $(document).ready(function () {
            $('#ctl00_MainContent_txtOut_Patient_ID').val("(New)");
            $('#<%= txtOut_Patient_ID.ClientID%>').val("(New)");
            $('#06').click();
            fillDepartment();
            filldoc();
            fillPendingPatientsList();
            loaddoctor();
            FillMainTestDepartment();
            FillLabTests('');
            fillComplaints("");
            fillPrimaryDiagnosis("");
            fillFinalDiagnosis("");
            FillMedicene("");
            updateHistoryTable();
            updateDisposalTable();
            loadDepartments();
            GetSymptomsByDepartment();
            fillSymptoms("000", "");
            $("#ctl00_MainContent_FollowNoDate").datepicker();
            $('#dvtblSymtomps').slideUp();
            $('#filterExaminations').change(filterExaminations);
            $('#filterDepartments option[value="000"]').prop('selected', true);
            $('#tab01Search').on('input', function () {
                const searchTerm = $(this).val().trim();
                const selectedValue = $('#filterDepartments').val();
                fillSymptoms(selectedValue, searchTerm);
            });
            $('#tab06Search').on('input', function () {
                const searchTerm = $(this).val().trim();
                fillComplaints(searchTerm);
            });
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
            $('#tab11_02Search').on('input', function () {
                const searchTerm = $(this).val().trim();
                FillMedicene(searchTerm);
            });
            $('#filterMainDepartments').on('change', function () {
                const searchTerm = $('#tab10Search').val().trim();
                LoadTestByDepartment(searchTerm);
            });
            $('#ctl00_MainContent_ddlPatientDepartment').on("change", function () {
                $('#ctl00_MainContent_ddlPatientDepartment').find('option:selected')[0].value;
                fillPendingPatientsList();
            })
            $('#<%= ddlDoctorName.ClientID %>, #<%= ddlIssuance_Of.ClientID %>, #<%= ddlFOllowUp.ClientID %>').change(function () {
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
                      <i class="fa fa-trash"></i>
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
            //refer Tab working
            const $patientCategory = $('#ctl00_MainContent_ddlPatient_Main_Category');
            const $doctorsDropdown = $('#ddldoctors');
            const $referTextbox = $('.refer-textbox');
            const $referTable = $('#tblRefer tbody');
            const $divRefer = $('#divtblRefer');
            const ROW_DEPARTMENT = 0;
            const ROW_DOCTOR = 1;
            const ROW_NOTE = 2;
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
        });
    </script>
    <script id="functions">
        function loadPatient(PatientID, opdNo) {
            $.ajax({
                type: "POST",
                url: "OutPatients.aspx/GetDetail",
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

                        // Display the data in the respective labels
                        $('#<%= vlblPatients_Name.ClientID %>').text(name);
                        $('#<%= vLbl_Age.ClientID %>').text(gender + "-" + age + "yrs"); // Combine Gender and Age
                        $('#<%= vLbl_Adress.ClientID %>').text(address);
                        $('#<%= vLbl_Contact.ClientID %>').text(mobile);
                        $('#<%= lblFollow.ClientID %>').text(follow);
                        $('#<%= Label1.ClientID %>').text(opdNo);
                        $('#<%= txtPatient_ID.ClientID%>').val(PatientID);

                    }
                },
                failure: function (response) {

                }
            });




        }
        function loaddoctor_byDep() {
            var depart = $('#ctl00_MainContent_ddlPatient_Main_Category').val();

            PageMethods.LoadDoctor_bydep(depart, function (res) {
                var doctor = JSON.parse(res);
                var options = '<option value="0" >Please Select </option>';
                var rowsText = '';

                $.each(doctor, function (key, value) {
                    options += '<option value="' + value.Emp_ID + '" >' + value.Emp_Name + '</option>';
                });

                $('#ddldoctors').html(options)
                $('#ddldoctors').attr('disabled', false);
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

                    var options = '<option value="0">Please Select</option>' +
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

            var options = '<option value="0" >Select Main Department</option>';

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
                url: "OutPatients.aspx/GetAvailableDates",
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
        function loaddoctor() {
            PageMethods.LoadDoctor(function (res) {
                var doctor = JSON.parse(res);
                var options = '<option value="0" >Please Select </option>';
                var rowsText = '';

                $.each(doctor, function (key, value) {

                    options += '<option value="' + value.Emp_ID + '" >' + value.Emp_Name + '</option>';
                });

                $('#ctl00_MainContent_ddlDoctorName').html(options)
                $('#ctl00_MainContent_ddlDoctorName').select2();
            });
        }
        function fillPendingPatientsList() {

            var filterDepartment = $('#ctl00_MainContent_ddlPatientDepartment').val();
            var doc_name = $('#ctl00_MainContent_ddldocname').val();
            if (doc_name == null) {
                doc_name == "0"
            }

            PageMethods.PendingPatients(filterDepartment, doc_name, function (data) {
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

                    rows += '<tr ' + rowColorStyle + '> <td>' + value.Patient_No + '</td> <td> ' + value.Token_No + ' </td>' + '<td>' + value.Full_Name + '</td> ' + '</td> ' + '<td>' + value.Age_years + '</td> ' + '<td>' + value.Department + '</td> ' + '<td>' + value.DoctorName + '</td> ' + '<td>' + retdate + '</td> ' + '<td>' + value.UserName + '</td> ' + '<td>' + status + '</td>' + ' <td> <a href="javascript:void(0)" onclick=loadPatient(' + value.Patient_ID + ',' + value.Patient_No + ')><i class="fa fa-upload" ></i></a> </td> </tr>';
                });
                debugger;
                $('#tblPendingPatients tbody').html(rows);

                $(".se-pre-con").fadeOut("slow");

            }, function (exec) { })
        }
        function openQueue() {
            if ($('#QueueList').is(':visible')) {
                $('#QueueList').slideUp('fast', function () {
                    $('#PreviewPane').slideDown('fast');
                });
            } else {
                $('#PreviewPane').slideUp('fast', function () {
                    $('#QueueList').slideDown('fast');
                });
            }
        }
        function fillDepartment() {
            var options;
            PageMethods.GetAllDeparmtent(function (data) {
                debugger;
                var options = '<option value="0" >Please Select</option>';
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $("#ctl00_MainContent_ddlPatientDepartment").html(options);
                $("#ctl00_MainContent_ddlPatientDepartment").select2();
            });
            return options;
        }
        function filldoc() {
            var options;
            PageMethods.Getdoctors(function (data) {
                debugger;
                var options = '<option value="0" >Please Select</option>';
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
                        '<td> <a href="#" onclick="Delete_Symtom(this)"><i class="fa fa-trash"></i></a></td></tr>';

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
                    '<td  > <a href="#" onclick="Delete_Symtom(this)"><i class="fa fa-trash"></i></a></td></tr>';

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

                $('#txtSymtom').tokenInput('clear');
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

                        options += '<div class="symptom-row" style="display: flex; align-items: center; justify-content: space-between;">' +
                            '<div style="display: flex; align-items: center;">' +
                            '<input type="checkbox" id="chk_' + value.SymptomId + '" ' +
                            'value="' + value.SymptomId + '" ' +
                            'class="symptom_checkbox" ' +
                            'onclick="this.checked ? Add_SymtomRow(\'' + value.SymptomId + '\', \'' + value.Description + '\') : Remove_SymtomRow(\'' + value.SymptomId + '\')" />' +
                            '<label for="chk_' + value.SymptomId + '" style="margin-left: 8px;">' + value.Description + '</label>' +
                            '</div>' +
                            '<button type="button" class="symptom-add-btn" ' +
                            'onclick="AddSymptomByModal(\'' + value.SymptomId + '\', \'' + value.Description + '\')" ' +
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
                    url: "NewOutPatient.aspx/SaveNewSymptom",
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
                    <a onclick="Remove_GeneralExamRow('${examName}')" class="remove-exam" data-exam="${examName}"><i class="fa fa-trash"></i></a>
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
            const complaintText = $('#NewComplaint').val().trim();

            if (complaintText === '') {
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
                    '<td  > <a href="#" onclick="Remove_ComplaintRow(\'' + id + '\')"><i class="fa fa-trash"></i></a></td></tr>';


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
                        options += '<div class="complaint-row" style="display: flex; align-items: center; justify-content: space-between;">' +
                            '<div style="display: flex; align-items: center;">' +
                            '<input type="checkbox" id="chk_complaint_' + value.ComplaintId + '" ' +
                            'value="' + value.ComplaintId + '" ' +
                            'class="complaint_checkbox" ' +
                            'onclick="this.checked ? Add_ComplaintRow(\'' + value.ComplaintId + '\', \'' + value.ComplaintName + '\') : Remove_ComplaintRow(\'' + value.ComplaintId + '\')" />' +
                            '<label for="chk_complaint_' + value.ComplaintId + '" style="margin-left: 8px;">' + value.ComplaintName + '</label>' +
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
            const Text = $('#NewPrimaryDiagnosis').val().trim();

            if (Text === '') {
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
                <i class="fa fa-trash"></i>
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
            const Text = $('#NewFinalDiagnosis').val().trim();

            if (Text === '') {
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
                        <i class="fa fa-trash"></i>
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

        function FillLabTests(searchValue) {
            debugger;
            var html = '';

            PageMethods.GetLabTests(searchValue, function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    html += '<div class="labtest-row" style="display: flex; align-items: center; justify-content: space-between; padding: 6px 0;">' +
                        '<div style="display: flex; align-items: center;">' +
                        '<input type="checkbox" id="LabTestchk_' + value.SerialNo + '" ' +
                        'value="' + value.SerialNo + '" ' +
                        'class="labtest_checkbox" ' +
                        'onclick="this.checked ? Add_LabTestRow(\'' + value.SerialNo + '\', \'' + value.TestName + '\') : Remove_LabTestRow(\'' + value.SerialNo + '\')" />' +
                        '<label class="labtest-label" for="LabTestchk_' + value.SerialNo + '" style="margin-left: 8px; font-size: 14px; color: #333;">' + value.TestName + '</label>' +
                        '</div>' +
                        '<button type="button" class="labtest-dropdown-btn" ' +
                        'onclick="ShowLabTestDetails(\'' + value.SerialNo + '\', \'' + value.TestName + '\')" ' +
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

            $('.tests-table tr').has('a[onclick*="Remove_LabTestRow(' + serial + ')"]').remove();

 
             if ($('.tests-table tr').length === 0) {
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
                    var existingRow = $('.tests-table').find('input[name="testID"][value="' + value.Test_ID + '"]').closest('tr');

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
                            '<td ><input type="hidden" name="testID" value="' + value.Test_ID + '" />' +
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
                            '<td><input type="hidden" name="rowid" value="' + uuid() + '" />' +
                            '<a href="javascript:void(0)" onclick="Remove_LabTestRow(' + test + ')">' +
                            '<i class="fa fa-trash"></i></a>' +
                            '</td></tr>';

                        test_array = $('.tests-table').find('input[name=testID][value="' + value.Test_ID + '"]');
                    }
                    else {
                        row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="' + value.Group_Category + '"/><input type="hidden" name="txtDeptID" value="001"/> ' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Test_Name + ' </td>   <td>No</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + ctl00_MainContent_txtSpecialTests.value + '"/> ' + ctl00_MainContent_txtSpecialTests.value + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td><td><input type="hidden" name="rowid" value="' + uuid() + '" />' +
                            '<a href="javascript:void(0)" onclick="deleteTest(this)">' +
                            '<i class="fa fa-trash"></i></a>' +
                            '</td></tr>';
                        test_array = $('.tests-table').find('input[name=txtGroupCategory][value="' + value.Group_Category + '"]');
                    }
                    $('#LabTestchk_' + serial).prop('checked', true);
                    $('.tests-table').append(row);
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
                FillProcedure("005", searchTerm);
                $('#divRotation').slideUp();
                $('#ddlXRayLF').slideUp();
            }
            else if (maindpt == "006") {
                $('#ddl_xray_rotation').slideUp();
                FillProcedure("006", searchTerm);
                $('#divRotation').slideUp();
                $('#ddlXRayLF').slideUp();
            }
            else if (maindpt == "007") {
                $('#ddl_xray_rotation').slideUp();
                FillProcedure("007", searchTerm);
                $('#divRotation').slideUp();
                $('#ddlXRayLF').slideUp();
            }
        }
        function FillTestsByCategory(CategoryID, searchTerm) {

            PageMethods.FillTestsByCategory(CategoryID, searchTerm, function (Tests) {
                debugger;
                var html = '';
                $.each(JSON.parse(Tests), function (key, value) {
                    html += '<div class="diagnosticTest-row" style="display: flex; align-items: center; justify-content: space-between; padding: 6px 0;">' +
                        '<div style="display: flex; align-items: center;">' +
                        '<input type="checkbox" id="DiagnosticTestchk_' + value.Test_ID + '" ' +
                        'value="' + value.Test_ID + '" ' +
                        'class="diagnostictest_checkbox" ' +
                        'onclick="this.checked ? Add_DiagnosticTestRow(\'' + value.Test_ID + '\', \'' + value.Test_Name + '\') : Remove_DiagnosticTestRow(\'' + value.Test_ID + '\')" />' +
                        '<label class="diagnostictest-label" for="DiagnosticTestchk_' + value.Test_ID + '" style="margin-left: 8px; font-size: 14px; color: #333;">' + value.Test_Name + '</label>' +
                        '</div>' +
                        '<button type="button" class="diagnostictest-dropdown-btn" ' +
                        'onclick="ShowDiagnosticTestDetails(\'' + value.Test_ID + '\', \'' + value.Test_Name + '\', \'' + CategoryID + '\')" ' +
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
                            '<td><input type="hidden" name="txtArea_Of_Interest" value="' + rotationVal + '"/> ' +
                            rotationText + '</td>' +
                            '<td><input type="hidden" name="rowid" value="' + uuid() + '" />' +

                            '<a href="javascript:void(0)" onclick="Remove_DiagnosticTestRow(\'' + test + '\')">' +  // Fixed function name
                            '<i class="fa fa-trash"></i></a>' +
                            '</td></tr>';

                        test_array = $('#tblDiagnostictest').find('input[name=testID][value="' + value.Test_ID + '"]');
                    }
                    else {
                        row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td>' +
                            '<td><input type="hidden" name="testID" value="' + value.Test_ID + '" />' +
                            '<input type="hidden" name="txtRotation" value="0">' +
                            '<input type="hidden" name="txtGroupCategory" value="' + value.Group_Category + '"/>' +
                            '<input type="hidden" name="txtDeptID" value="001"/> ' +
                            (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Test_Name + '</td>' +
                            '<td>No</td>' +
                            '<td>' + Result + '</td>' +
                            '<td><input type="hidden" name="txtSpecial_Test" value="' + txtSpecialTests + '"/> ' + txtSpecialTests + '</td>' +
                            '<td><input type="hidden" name="txtArea_Of_Interest" value="' + txtAreaOfInterest + '"/> ' + txtAreaOfInterest + '</td>' +
                            '<td><input type="hidden" name="txtArea_Of_Interest" value="' + rotationVal + '"/> ' + rotationText + '</td>' +
                            '<td><input type="hidden" name="rowid" value="' + uuid() + '" />' +
                            '<a href="javascript:void(0)" onclick="Remove_DiagnosticTestRow(\'' + test + '\')">' +
                            '<i class="fa fa-trash" ></i></a>' +
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
                url: 'NewOutPatient.aspx/getpharmacyitems',
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
                                html += '<div class="Medicene-row" style="display: flex; align-items: center; justify-content: space-between; padding: 6px 0;">' +
                                    '<div style="display: flex; align-items: center;">' +
                                    '<input style="display:none" type="checkbox" id="Medicenechk_' + value.Item_Code + '" class="Medicene-checkbox" ' +
                                    'style="margin-right: 8px; cursor: pointer;">' +
                                    '<label class="Medicene-label" for="Medicenechk_' + value.Item_Code + '" ' +
                                    'style="margin-left: 8px; font-size: 14px; color: #333;">' +
                                    value.Description +
                                    '</label>' +
                                    '</div>' +
                                    '<button type="button" class="Medicene-dropdown-btn" ' +
                                    'onclick="ShowMediceneDetails(\'' + value.Item_Code + '\', \'' + value.Description.replace(/'/g, "\\'") + '\')" ' +
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
            const $row = $(`#Medicenechk_${serialNo}`).closest('.Medicene-row');
            const $detailsDiv = $(`#MediceneDetails_${serialNo}`);
            const $checkbox = $(`#Medicenechk_${serialNo}`);
            const $icon = $(this).find('i');

            // Close all other open details divs first
            $('.Medicene-details').not($detailsDiv).each(function () {
                const $otherDiv = $(this);
                const otherSerialNo = $otherDiv.attr('id').replace('MediceneDetails_', '');
                const $otherCheckbox = $(`#Medicenechk_${otherSerialNo}`);
                const $otherIcon = $(`#Medicenechk_${otherSerialNo}`).closest('.Medicene-row').find('i');

                $otherDiv.slideUp(300, function () {
                    $otherIcon.removeClass('fa-chevron-up').addClass('fa-chevron-down');
                });
            });

            if ($detailsDiv.length) {
                // Toggle existing details
                $detailsDiv.slideToggle(300, function () {
                });

                // If in edit mode, populate the form with existing values
                if (isEditMode && existingValues) {
                    // Set values after dropdowns are populated
                    setTimeout(() => {
                        $(`#mediceneDose_${serialNo}`).val(existingValues.dose || '');
                        $(`#mediceneDosageFrom_${serialNo}`).val(existingValues.dosageFrom || '');
                        $(`#duration_${serialNo}`).val(existingValues.duration || '');
                        $(`#mediceneroute_${serialNo}`).val(existingValues.route || '');
                        $(`#medicenefrequency_${serialNo}`).val(existingValues.frequency || '');
                        $(`#otherinstructions_${serialNo}`).val(existingValues.otherInstruction || '');
                        $(`#specialinstructions_${serialNo}`).val(existingValues.specialInstructions || '');
                    }, 100);
                }
            } else {
                const detailsHtml = `
<div id="MediceneDetails_${serialNo}" class="Medicene-details" style="display: none; padding: 10px; background: #f5f5f5; margin-top: 5px;">
    <!-- First Row - 2 fields -->
    <div class="row">
        <div class="col-md-6" style="margin-bottom: 8px;">
            <label style="display: block; margin-bottom: 4px; font-size: 13px;">Dose</label>
            <select id="mediceneDose_${serialNo}" class="form-control" style="width: 100%; padding: 5px;">
                <option value="">Select Dose</option>
            </select>
        </div>
        <div class="col-md-6" style="margin-bottom: 8px;">
            <label style="display: block; margin-bottom: 4px; font-size: 13px;">Dosage Form</label>
            <select id="mediceneDosageFrom_${serialNo}" class="form-control" style="width: 100%; padding: 5px;">
                <option value="">Select Form</option>
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
                <option value="">Select Route</option>
            </select>
        </div>
    </div>
    
    <!-- Third Row - 1 field -->
    <div class="row">
        <div class="col-md-12" style="margin-bottom: 8px;">
            <label style="display: block; margin-bottom: 4px; font-size: 13px;">Frequency</label>
            <select id="medicenefrequency_${serialNo}" class="form-control" style="width: 100%; padding: 5px;">
                <option value="">Select Frequency</option>
            </select>
        </div>
    </div>
    
    <!-- Fourth Row - 1 field -->
    <div class="row">
        <div class="col-md-12" style="margin-bottom: 8px;">
            <label style="display: block; margin-bottom: 4px; font-size: 13px;">Other Instructions</label>
            <select id="otherinstructions_${serialNo}" class="form-control" style="width: 100%; padding: 5px;">
                <option value="">Select Instruction</option>
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
            <i class="fa fa-plus-circle" style="color:black"></i> ${isEditMode ? 'Update' : 'Add'} Test
        </button>
    </div>
</div>`;


                // Insert and show details
                $row.after(detailsHtml);
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
            }

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
                    '<a href="#" onclick="deleteMedicine(this)"><i class="fa fa-trash"></i></a>' +
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

                    rows += '<tr value=' + Templateid + '> <td style="display:none"><input type="hidden" name="testDate" value="' + date + '"> ' + newdate + ' </td><td> ' + value.Medicine_Name + ' </td><td> ' + value.Frequency + ' </td> <td> ' + value.Oral + ' </td><td> ' + value.Injections + ' </td> <td> ' + value.AttendingParamedical_Staff + ' </td><td> ' + value.Dosage_From + ' </td><td> ' + value.Dosage_Qty + ' </td><td> ' + value.Other_Instruction + ' </td><td> <a href="#" onclick="deleteMedicine(this)"><i class="fa fa-trash"></i></a></td> <td style="display:none;">' + value.Item_Code + '</td></tr>';
                });
                $('#tblMedicines tbody').append(rows);
                $('#dvtblMedicines').slideDown();
            })
        }
         
         function updateFollowUpTable() {
            // Get values from form inputs
            var doctorName = $('#<%= ddlDoctorName.ClientID %> option:selected').text();
            var doctorId = $('#<%= ddlDoctorName.ClientID %>').val();
            var designation = $('#<%= txtDesignation.ClientID %>').val();
            var admission = $('#<%= ddlIssuance_Of.ClientID %> option:selected').text();
            var admissionId = $('#<%= ddlIssuance_Of.ClientID %>').val();
            var followUp = $('#<%= ddlFOllowUp.ClientID %> option:selected').text();
            var followUpId = $('#<%= ddlFOllowUp.ClientID %>').val();
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
                if (followUpDate) {
                    existingRow.find('td:eq(4)').text(followUpDate);
                }
            } else {
                // Create new row only if at least one required field is filled
                if (doctorId || followUpId || followUpDate) {
                    var newRow = $('<tr>').append(
                        $('<td>').text(doctorName || '').attr('data-id', doctorId || ''),
                        $('<td>').text(designation || ''),
                        $('<td>').text(admission || '').attr('data-id', admissionId || ''),
                        $('<td>').text(followUp || '').attr('data-id', followUpId || ''),
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

            var rows = '<tr><td ><input type="hidden" name="ProtoId" value="' + protoval + '" />' + prototext + '</td> <td style="text-align: left;"> <a  href="#" onclick="DeleteRow(this)">Delete</a> </td> </tr>';
            $("#tblProto").append(rows);
            $("#dvtblProto").slideDown();
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


            // Update preview width
            const preview = document.querySelector('.preview');
            preview.style.width = retractDiv.classList.contains('minimized') ? "61%" : "50%";
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
            // Hide all tabs first (with slide up animation)
            const allTabs = document.querySelectorAll('.tabs');
            $(allTabs).not('#tab' + element.id).slideUp(300); // Only slide up non-target tabs

            // Get the ID of the tab to show
            const tabId = 'tab' + element.id;

            // Show the selected tab (with slide down animation)
            const selectedTab = document.getElementById(tabId);
            if (selectedTab) {
                $(selectedTab).slideDown(300);
            }

            // Update header with the clicked span's text
            const spanText = $(element).find('span').text().trim();
            if (spanText) {
                $('.header').text(spanText); // Update header text
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

                    var PatID = $('#<%= txtPatient_ID.ClientID%>').val();

                    var OutPatID = $('#<%= txtOut_Patient_ID.ClientID%>').val();
            if (OutPatID == '(New)' || OutPatID == '')
                OutPatID = 0;
            var MedicineDetails = { Pat: PatID, PatientID: OutPatID, MedicineList: MedicinesList }

            PageMethods.SaveMedicines(JSON.stringify(MedicineDetails), function (response) { saveTests(); });

        }
        function saveTests() {
            var table = $('.tests-table tbody');
            var test_list = [];
            var tbl = document.getElementById('loadtest');
            table.find('tr').each(function (key, value) {
                var rotation = $(value).find('td').eq(1).text();
                var showTestDescription = false;
                if (rotation.includes('X-Ray') || rotation.includes('CT-Scan')) {
                    showTestDescription = true;
                }

                var date = '<%= DateTime.Now%>';
        test_list.push({ 'Date': $(value).find('td input[name=testDate]').val(), 'TestID': $(value).find('td input[name=testID]').val(), 'Catagory_ID': $(value).find('td input[name=txtGroupCategory]').val(), 'Dept_ID': $(value).find('td input[name=txtDeptID]').val(), 'RotationID': $(value).find('td input[name=txtRotation]').val(), 'L_R_Rotation_ID': $(value).find('td input[name=txtddlXRayLF_Name]').val(), 'Special_Tests': $(value).find('td input[name=txtSpecial_Test]').val(), 'Area_Of_Interest': $(value).find('td input[name=txtArea_Of_Interest]').val(), 'rotation': rotation, 'showTestDescription': showTestDescription });

    });

            var PatID = $('#<%= txtPatient_ID.ClientID%>').val();
            var patientID = $('#<%= txtOut_Patient_ID.ClientID %>').val();
            if (patientID == '(New)' || patientID == '')
                patientID = 0;
            var labTest = { 'PatientID': patientID, 'TestList': test_list, 'PatID': PatID };
            PageMethods.SaveTest(JSON.stringify(labTest), function (res) {
                SaveHistoryTab();

            });
        }

    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

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

    <div class="row">
        <!-- sidebar -->
        <div class="col-md-2 col-sm-12 p-0" id="retract">
            <div class="sidebarr">
                <div class="menu-item no-submenu" id="06" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/HMIS_Icons/complaints.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Complaints</span>
                    </div>
                </div>
                <div class="menu-item no-submenu" id="01" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/HMIS_Icons/symptoms.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Symptoms</span>
                    </div>
                </div>
                <div class="menu-item no-submenu" id="02" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/HMIS_Icons/vitals.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Vitals</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="03" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/HMIS_Icons/history.png" alt="Profile Picture" class="sidebarIcon">
                        <span>History</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="04" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/HMIS_Icons/examination.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Examination</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="05" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/HMIS_Icons/refer.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Refer To</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="07" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/HMIS_Icons/primarydiagnosis.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Primary Diagnosis</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="08" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/HMIS_Icons/finaldiagnosis.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Final Diagnosis</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="09" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/HMIS_Icons/investigation.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Investigation</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="10" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/HMIS_Icons/diagnostics.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Diagnostics</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="11" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/HMIS_Icons/medication.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Medication</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="12" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/HMIS_Icons/followup.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Follow Up</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="13" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/HMIS_Icons/disposal.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Disposal</span>
                    </div>
                </div>


            </div>
        </div>
        <!-- Left Column (6 units) -->
        <div class="col-md-4">
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
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <hr />
            </div>

            <!--Content Area -->
            <div class="row">
                <div class="col-md-12 col-sm-12">
                    <div class="cardd">
                        <div class="cardd-body">
                            <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 10px">
                                <div style="width: fit-content !important;" class="retractIcon">
                                    <img onclick="toggleRetract()" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/sidebar.png"
                                        alt="Sidebar Toggle" class="sidebarToggleIcon" />
                                </div>
                                <h2 class="header mybutton"></h2>
                            </div>

                            <div class="tabs" id="tab01" style="display: none">
                                <div style="display: flex; justify-content: flex-end;">
                                    <input type="button" class="mybutton2" value="Add New" onclick="AddNewSymptom()" />
                                    <input style="margin-left: 5px" type="button" class="mybutton2" value="Manage Symptoms" onclick="openManageSymptomsModal()" />
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
                                    <input type="button" class="mybutton2" value="Add Vitals" onclick="AddVitals()" />
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
                                            <asp:TextBox ID="txtBirthHistory" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="5"></asp:TextBox>
                                        </div>
                                    </div>

                                    <!-- Gynae History -->
                                    <div class="history-row">
                                        <div style="display: flex; align-items: center; width: 100%">
                                            <asp:Label Style="width: 75%;" ID="Label16" runat="server" Text="Gynae"></asp:Label>
                                            <asp:TextBox ID="txtGYNAE" TextMode="MultiLine" Rows="3" Width="100%" runat="server"></asp:TextBox>
                                        </div>
                                    </div>

                                    <!-- Drug History -->
                                    <div class="history-row">
                                        <div style="display: flex; align-items: center; width: 100%">
                                            <asp:Label Style="width: 75%;" ID="Label8" runat="server" Text="Drug History"></asp:Label>
                                            <asp:TextBox ID="txtDrugHistory" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="6"></asp:TextBox>
                                        </div>
                                    </div>

                                    <!-- Personal History -->
                                    <div class="history-row">
                                        <div style="display: flex; align-items: center; width: 100%">
                                            <asp:Label Style="width: 75%;" ID="Label17" runat="server" Text="Personal History"></asp:Label>
                                            <asp:TextBox ID="txtPersonalHistory" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="7"></asp:TextBox>
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
                                            <asp:TextBox ID="txtAllergiesHistory" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="9"></asp:TextBox>
                                        </div>
                                    </div>

                                    <!-- Treatment History -->
                                    <div class="history-row">
                                        <div style="display: flex; align-items: center; width: 100%">
                                            <asp:Label Style="width: 75%;" ID="Label11" runat="server" Text="Treatment History"></asp:Label>
                                            <asp:TextBox ID="txtTreatmentHistory" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="10"></asp:TextBox>
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
                                            <asp:TextBox ID="txtVaccinationHistory" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="10"></asp:TextBox>
                                        </div>
                                    </div>

                                    <!-- Nutrition History -->
                                    <div class="history-row">
                                        <div style="display: flex; align-items: center; width: 100%">
                                            <asp:Label Style="width: 75%;" ID="lblNutritionHistory" runat="server" Text="Nutrition History"></asp:Label>
                                            <asp:TextBox ID="txtNutritionHistory" TextMode="MultiLine" Rows="3" Width="100%" runat="server" TabIndex="10"></asp:TextBox>
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

                                </div>
                            </div>
                            <div class="tabs" id="tab04" style="display: none">
                                <div class="row">
                                    <div class="col-md-5 col-sm-12">
                                        <select id="filterExaminations">
                                            <option value="001">General Physical</option>
                                            <option value="002">Systematic</option>
                                            <option value="003">Special</option>
                                        </select>
                                    </div>
                                </div>
                                <div id="subTab001" class="general-exam-container subtabs">
                                    <!-- Row 1 -->
                                    <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
                                        <!-- Pallor -->
                                        <div class="exam-row" style="display: flex; align-items: center; width: 48%;">
                                            <input type="checkbox" id="ctl00_MainContent_chkPallor"
                                                onclick="this.checked ? Add_GeneralExamRow('Pallor') : Remove_GeneralExamRow('Pallor')" />
                                            <label for="ctl00_MainContent_chkPallor" style="margin-left: 8px;">Pallor</label>
                                        </div>

                                        <!-- JVP -->
                                        <div class="exam-row" style="display: flex; align-items: center; width: 48%;">
                                            <input type="checkbox" id="ctl00_MainContent_chkJVP"
                                                onclick="this.checked ? Add_GeneralExamRow('JVP') : Remove_GeneralExamRow('JVP')" />
                                            <label for="ctl00_MainContent_chkJVP" style="margin-left: 8px;">JVP</label>
                                        </div>
                                    </div>

                                    <!-- Row 2 -->
                                    <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
                                        <!-- Cyanosis -->
                                        <div class="exam-row" style="display: flex; align-items: center; width: 48%;">
                                            <input type="checkbox" id="ctl00_MainContent_chkaganoris"
                                                onclick="this.checked ? Add_GeneralExamRow('Cyanosis') : Remove_GeneralExamRow('Cyanosis')" />
                                            <label for="ctl00_MainContent_chkaganoris" style="margin-left: 8px;">Cyanosis</label>
                                        </div>

                                        <!-- Disoriented -->
                                        <div class="exam-row" style="display: flex; align-items: center; width: 48%;">
                                            <input type="checkbox" id="ctl00_MainContent_chkunconceed"
                                                onclick="this.checked ? Add_GeneralExamRow('Disoriented') : Remove_GeneralExamRow('Disoriented')" />
                                            <label for="ctl00_MainContent_chkunconceed" style="margin-left: 8px;">Disoriented</label>
                                        </div>
                                    </div>

                                    <!-- Row 3 -->
                                    <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
                                        <!-- Jaundice -->
                                        <div class="exam-row" style="display: flex; align-items: center; width: 48%;">
                                            <input type="checkbox" id="ctl00_MainContent_chkjaundice"
                                                onclick="this.checked ? Add_GeneralExamRow('Jaundice') : Remove_GeneralExamRow('Jaundice')" />
                                            <label for="ctl00_MainContent_chkjaundice" style="margin-left: 8px;">Jaundice</label>
                                        </div>

                                        <!-- Dehydration -->
                                        <div class="exam-row" style="display: flex; align-items: center; width: 48%;">
                                            <input type="checkbox" id="ctl00_MainContent_hydration"
                                                onclick="this.checked ? Add_GeneralExamRow('Dehydration') : Remove_GeneralExamRow('Dehydration')" />
                                            <label for="ctl00_MainContent_hydration" style="margin-left: 8px;">Dehydration</label>
                                        </div>
                                    </div>

                                    <!-- Row 4 -->
                                    <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
                                        <!-- Edema -->
                                        <div class="exam-row" style="display: flex; align-items: center; width: 48%;">
                                            <input type="checkbox" id="ctl00_MainContent_edema"
                                                onclick="this.checked ? Add_GeneralExamRow('Edema') : Remove_GeneralExamRow('Edema')" />
                                            <label for="ctl00_MainContent_edema" style="margin-left: 8px;">Edema</label>
                                        </div>

                                        <!-- Lymphadenopathy -->
                                        <div class="exam-row" style="display: flex; align-items: center; width: 48%;">
                                            <input type="checkbox" id="ctl00_MainContent_chk1"
                                                onclick="this.checked ? Add_GeneralExamRow('Lymphadenopathy') : Remove_GeneralExamRow('Lymphadenopathy')" />
                                            <label for="ctl00_MainContent_chk1" style="margin-left: 8px;">Lymphadenopathy</label>
                                        </div>
                                    </div>

                                    <!-- Row 5 -->
                                    <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
                                        <!-- Clubbing -->
                                        <div class="exam-row" style="display: flex; align-items: center; width: 48%;">
                                            <input type="checkbox" id="ctl00_MainContent_chk2"
                                                onclick="this.checked ? Add_GeneralExamRow('Clubbing') : Remove_GeneralExamRow('Clubbing')" />
                                            <label for="ctl00_MainContent_chk2" style="margin-left: 8px;">Clubbing</label>
                                        </div>

                                        <!-- Dyspnoea -->
                                        <div class="exam-row" style="display: flex; align-items: center; width: 48%;">
                                            <input type="checkbox" id="ctl00_MainContent_chk3"
                                                onclick="this.checked ? Add_GeneralExamRow('Dyspnoea') : Remove_GeneralExamRow('Dyspnoea')" />
                                            <label for="ctl00_MainContent_chk3" style="margin-left: 8px;">Dyspnoea</label>
                                        </div>
                                    </div>

                                    <!-- Row 6 -->
                                    <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
                                        <!-- Neck Swelling -->
                                        <div class="exam-row" style="display: flex; align-items: center; width: 48%;">
                                            <input type="checkbox" id="ctl00_MainContent_ns"
                                                onclick="this.checked ? Add_GeneralExamRow('NeckSwelling') : Remove_GeneralExamRow('NeckSwelling')" />
                                            <label for="ctl00_MainContent_ns" style="margin-left: 8px;">Neck Swelling</label>
                                        </div>

                                        <!-- Skin Lesions -->
                                        <div class="exam-row" style="display: flex; align-items: center; width: 48%;">
                                            <input type="checkbox" id="ctl00_MainContent_sl"
                                                onclick="this.checked ? Add_GeneralExamRow('SkinLesions') : Remove_GeneralExamRow('SkinLesions')" />
                                            <label for="ctl00_MainContent_sl" style="margin-left: 8px;">Skin Lesions</label>
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
                                                <asp:TextBox ID="txtRemarksHistory" TextMode="MultiLine" Rows="3" Width="100%" runat="server" CssClass="systematic-textbox"></asp:TextBox>
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
                                        <select style="width: 80%" id="ddldoctors"></select>
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
                                    <input type="button" class="mybutton2" value="Add New" onclick="AddNewComplaint()" />
                                </div>
                                <div style="display: none" id="divAddNewComplaint">
                                    <div style="display: flex; justify-content: center;">
                                        <input type="text" id="NewComplaint" />
                                        <input style="width: 50% !important; margin-left: 10px;" type="button" id="btnSaveNewComplaint" onclick="saveComplaint()" class="btn btn-primry" value="Save" />
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-5 col-sm-12">
                                    </div>
                                    <div class="col-md-7 col-sm-12">
                                        <input type="text" class="form-control mb-2" id="tab06Search" placeholder="Search..." />
                                    </div>
                                </div>
                                <div id="allComplaints"></div>
                            </div>
                            <div class="tabs" id="tab07" style="display: none">
                                <div style="display: flex; justify-content: flex-end;">
                                    <input type="button" class="mybutton2" value="Add New" onclick="AddNewPrimaryDiagnosis()" />
                                </div>
                                <div style="display: none" id="divAddNewPrimaryDiagnosis">
                                    <div style="display: flex; justify-content: center;">
                                        <input type="text" id="NewPrimaryDiagnosis" />
                                        <input style="width: 50% !important; margin-left: 10px;" type="button" id="btnSaveNewPrimaryDiagnosis" onclick="savePrimaryDiagnosis()" class="btn btn-primry" value="Save" />
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-5 col-sm-12">
                                    </div>
                                    <div class="col-md-7 col-sm-12">
                                        <input type="text" class="form-control mb-2" id="tab07Search" placeholder="Search..." />
                                    </div>
                                </div>
                                <div id="allPrimaryDiagnosis"></div>
                            </div>
                            <div class="tabs" id="tab08" style="display: none">
                                <div style="display: flex; justify-content: flex-end;">
                                    <input type="button" class="mybutton2" value="Add New" onclick="AddNewFinalDiagnosis()" />
                                </div>
                                <div style="display: none" id="divAddNewFinalDiagnosis">
                                    <div style="display: flex; justify-content: center;">
                                        <input type="text" id="NewFinalDiagnosis" />
                                        <input style="width: 50% !important; margin-left: 10px;" type="button" id="btnSaveNewFinalDiagnosis" onclick="saveFinalDiagnosis()" class="btn btn-primry" value="Save" />
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-5 col-sm-12">
                                    </div>
                                    <div class="col-md-7 col-sm-12">
                                        <input type="text" class="form-control mb-2" id="tab08Search" placeholder="Search..." />
                                    </div>
                                </div>
                                <div id="allFinalDiagnosis"></div>
                            </div>
                            <div class="tabs" id="tab09" style="display: none">
                                <div style="display: flex; justify-content: flex-end;">
                                    <input type="button" class="mybutton2" value="Add New" onclick="AddNewSymptom()" />
                                    <input style="margin-left: 5px" type="button" class="mybutton2" value="Manage Symptoms" onclick="openManageSymptomsModal()" />
                                </div>
                                <div class="row">
                                    <div class="col-md-5 col-sm-12">
                                    </div>
                                    <div class="col-md-7 col-sm-12">
                                        <input type="text" class="form-control mb-2" id="tab09Search" placeholder="Search..." />
                                    </div>
                                </div>
                                <div id="allLabTests"></div>
                            </div>
                            <div class="tabs" id="tab10" style="display: none">
                                <div style="display: flex; justify-content: flex-end;">
                                    <input type="button" class="mybutton2" value="Add New" onclick="AddNewSymptom()" />
                                </div>
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
                                    <input type="button" class="mybutton2" value="By Template" onclick="ShowMediceneTemplateDiv()" />
                                    <input style="margin-left: 5px" type="button" class="mybutton2" value="All Meds" onclick="ShowAllMedicenesDiv()" />
                                </div>
                                <div id="tab11_01" class="tab11subtab">
                                    <div class="row">
                                        <div class="col-md-5 col-sm-12">
                                        </div>
                                        <div class="col-md-7 col-sm-12">
                                            <input type="text" class="form-control mb-2" id="tab11_01Search" placeholder="Search..." />
                                        </div>
                                    </div>
                                    <div id="allMedicenes"></div>
                                </div>
                                <div id="tab11_02" class="tab11subtab" style="display: none">
                                    <div class="row">
                                        <div class="col-md-5 col-sm-12">
                                        </div>
                                        <div class="col-md-7 col-sm-12">
                                            <input type="text" class="form-control mb-2" id="tab11_02Search" placeholder="Search..." />
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
                                            Style="width: 250px; height: 32px;"
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


                                </div>
                                <h4 class="mybutton2">Protos:</h4>
                                <asp:DropDownList ID="ddlProto" CssClass="dropdownBackgroud" Width="50%" runat="server" onchange="AddProto();" AppendDataBoundItems="true"></asp:DropDownList>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

        </div>

        <!-- Right Column (6 units) -->
        <div class="col-md-6 col-sm-12 preview">

            <div style="display: flex; justify-content: flex-end;">
                <input type="button" class="mybutton2" value="History" onclick="AddNewSymptom()" />
                <input type="button" class="mybutton2" value="Queue" onclick="openQueue()" />
                <input type="button" class="mybutton2" value="Discharge" onclick="AddNewSymptom()" />
                <input type="button" class="mybutton2" value="Reset" onclick="openManageSymptomsModal()" />
                <input type="button" class="mybutton2" value="Save" onclick="AddNewSymptom()" />

            </div>
            <div id="PreviewPane" style="display: none">
                <div>
                    <div class="row">
                        <div class="col-lg-3 " id="dvtblSymtomps">
                            <div>
                                <div class="table-responsive previewTable">
                                    <table class="table" id="tblSymtoms">
                                        <thead>
                                            <tr>
                                                <th style="display: none;">Row ID</th>
                                                <th style="display: none;">Symtom ID</th>
                                                <th>Symptoms</th>
                                                <th style="display: none;">Dur</th>
                                                <th style="display: none;">D/M/Y</th>
                                                <th style="display: none;">Remarks</th>
                                                <th></th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-3 " id="dvtblComplaints" style="display: none">
                            <div>
                                <div class="table-responsive previewTable">
                                    <table class="table" id="tblComplaints">
                                        <thead>
                                            <tr>
                                                <th style="display: none;">ComplaintID</th>
                                                <th>Complaints</th>
                                                <th></th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                        <div id="divtblHistory" style="display: none" class="col-lg-6  ">
                            <div>
                                <div class="table-responsive previewTable">
                                    <table class="table" id="tblHistory">
                                        <thead>
                                            <tr>
                                                <th>History</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                        </div>
                        <div id="divtblVitals" style="display: none" class="col-lg-9 ">
                            <div>
                                <div class="table-responsive previewTable">
                                    <table class="table" id="tblVitals">
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
                                        <tbody>
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                        </div>
                        <div id="divtblGeneralExam" style="display: none" class="col-lg-3  ">
                            <div>
                                <div class="table-responsive previewTable">
                                    <table class="table" id="tblGeneralExam">
                                        <thead>
                                            <tr>
                                                <th>General Examination</th>
                                                <th></th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                        </div>
                        <div id="divtblSystematicExam" style="display: none" class="col-lg-6  ">
                            <div>
                                <div class="table-responsive previewTable">
                                    <table class="table" id="SystematicExam">
                                        <thead>
                                            <tr>
                                                <th>Systematic Examination</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                        </div>
                        <div id="divtblRefer" style="display: none" class="col-lg-6 previewTable">
                            <div>
                                <div class="table-responsive">
                                    <table class="table" id="tblRefer">
                                        <thead>
                                            <tr>
                                                <th>Refer</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                        </div>
                        <div class="col-lg-4  " id="dvtblPrimaryDiagnosis" style="display: none">
                            <div>
                                <div class="table-responsive previewTable">
                                    <table class="table" id="tblPrimaryDiagnosis">
                                        <thead>
                                            <tr>
                                                <th style="display: none;">PrimaryDiagnosisID</th>
                                                <th>Primary Diagnosis</th>
                                                <th></th>
                                                <th></th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-4  " id="dvtblFinalDiagnosis" style="display: none">
                            <div>
                                <div class="table-responsive previewTable">
                                    <table class="table" id="tblFinalDiagnosis">
                                        <thead>
                                            <tr>
                                                <th style="display: none;">FinalDiagnosisID</th>
                                                <th>Final Diagnosis</th>
                                                <th></th>
                                                <th></th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                        <div id="divtblDisposal" style="display: none" class="col-lg-4  ">
                            <div>
                                <div class="table-responsive previewTable">
                                    <table class="table" id="tblDisposal">
                                        <thead>
                                            <tr>
                                                <th>Disposal</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                        </div>
                        <div class="col-lg-12  " id="dvtblLabtest" style="display: none">
                            <div>
                                <div class="table-responsive previewTable">
                                    <table id="tblLabtest" class="table table-bordered table-custom tests-table">
                                        <thead>
                                            <tr style="position: sticky; top: 0; z-index: 10;">
                                                <th style="display: none">Date</th>
                                                <th>Test Name</th>
                                                <th style="display: none">Sample Received</th>
                                                <th style="display: none">Result</th>
                                                <th>Special Tests</th>
                                                <th>Area Of Interest</th>
                                                <th>Action</th>
                                            </tr>
                                        </thead>
                                        <tbody id="loadtest">
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-12  " id="dvtblDiagnostictest" style="display: none">
                            <div>
                                <div class="table-responsive previewTable">
                                    <table id="tblDiagnostictest" class="table table-bordered table-custom">
                                        <thead>
                                            <tr style="position: sticky; top: 0; z-index: 10;">
                                                <th style="display: none">Date</th>
                                                <th>Diagnostic Test Name</th>
                                                <th style="display: none">Sample Received</th>
                                                <th style="display: none">Result</th>
                                                <th>Special Tests</th>
                                                <th>Area Of Interest</th>
                                                <th>Rotation</th>
                                                <th>Action</th>
                                            </tr>
                                        </thead>
                                        <tbody id="loadDiagnostictest">
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-12  " id="dvtblMedicines" style="display: none">
                            <div>
                                <div class="table-responsive previewTable">
                                    <table id="tblMedicines" class="table table-bordered table-custom">
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
                                        <tbody>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                        <div id="divtblFollowUp" style="display: none" class="col-lg-8">
                            <div>
                                <div class="table-responsive previewTable">
                                    <table class="table" id="tblFollowUp">
                                        <thead>
                                            <tr>
                                                <th>Doctor Name</th>
                                                <th>Designation</th>
                                                <th>Admission</th>
                                                <th>Follow Up</th>
                                                <th>Date</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                        </div>
                        <div id="dvtblProto" style="display: none" class="col-lg-4  ">
                            <div>
                                <div class="table-responsive previewTable">
                                    <table class="table" style="height: auto; overflow: scroll;" id="tblProto">
                                        <thead>
                                            <tr>
                                                <th style="text-align: left;">Protos</th>
                                                <th>Action</th>
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
            <div id="QueueList">
                <div class="row" style="margin-bottom: 15px">
                    <div class="col-lg-4">
                        <select id="ddlPatientDepartment" runat="server"></select>
                    </div>
                    <div class="col-lg-4">
                        <select id="ddldocname" onchange="fillPendingPatientsList();" runat="server"></select>
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
    </div>
    <asp:TextBox ID="txtOut_Patient_ID" runat="server" ReadOnly="True" style="display:none;"></asp:TextBox>
    <asp:TextBox ID="txtPatient_ID" runat="server" class="form-control" style="display:none" />
    <asp:HiddenField ID="hdfPatient_ID" Value="(New)" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hdfReg_ID" Value="(New)" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hdfPatient_No" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hdfdhischarge" Value="false" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hdfFetch_ID" runat="server" ClientIDMode="Static" />

</asp:Content>
