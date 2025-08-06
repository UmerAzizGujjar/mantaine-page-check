<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="NewOutPatient.aspx.cs" Inherits="PMS.Modules.PatientManagement.NewOutPatient" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">


    <style title="sidebar">
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
            /* Remove overflow-y and height */
        }

        .menu-item {
            cursor: pointer;
            padding: 15px 20px;
            border-bottom: 1px solid #dee2e6;
            transition: background-color 0.3s;
            font-size: 15px
        }

            .menu-item:hover {
                background-color: #e9ecef;
            }

        .menu-title {
            display: flex;
            justify-content: space-between;
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

            .card:hover {
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
            }

        .page-header, #ctl00_sidebar {
            display: none !important;
        }


        .symptom-row, .vital-row, .history-row, .exam-row, .exam-text-row, .Systematic-Exam-Row, .refer-row {
            display: flex;
            align-items: center;
            margin-bottom: 2px;
            height: 45px;
            background-color: white;
            border-radius: 13px;
            color: black;
            /* Transition properties */
            transition: background-color 0.3s ease, color 0.3s ease;
            /* Optional: Add padding for better spacing */
            padding: 0 16px;
            /* Optional: Add cursor pointer to indicate interactivity */
            cursor: pointer;
        }

        .history-row, .exam-text-row, .Systematic-Exam-Row {
            height: 60px !important;
        }

            .symptom-row:hover, .vital-row:hover, .history-row:hover, .exam-row:hover, .exam-text-row:hover, .Systematic-Exam-Row:hover, .refer-row:hover {
                background-color: black;
                color: white;
                /* Optional: Add slight scale effect */
                transform: scale(1.02);
                /* Ensure smooth scaling if added */
                transition: background-color 0.3s ease, color 0.3s ease, transform 0.2s ease;
            }

                .symptom-row:hover .fa-plus-circle {
                    color: white !important;
                }

        .symptom-row label {
            margin-left: 10px;
            margin-bottom: 0;
        }

        .mybutton {
            width: fit-content !important;
            height: 30px;
            background-color: #f0f1f3;
            padding: 3px 12px;
            border-radius: 8px;
            margin: 0;
            color: #EFA63E !important;
            font-weight: bold !important;
            font-size: 16px;
            transition: all 0.3s ease; /* Smooth transition for all properties */
            margin-bottom: 5px;
            border: 0px !important;
            margin-left: 5px;
            margin-right: 5px;
        }

            .mybutton:hover {
                background-color: #000; /* Black background on hover */
                color: #fff !important; /* White text on hover */
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
                $('#symptomspreview').hide();
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
                $('#symptomspreview').show();


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
                        $('#symptomspreview').hide();
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




    <script>
        $(document).ready(function () {
            const $patientCategory = $('#ctl00_MainContent_ddlPatient_Main_Category');
            const $doctorsDropdown = $('#ddldoctors');
            const $referTextbox = $('.refer-textbox');
            const $referTable = $('#tblRefer tbody');
            const $divRefer = $('#divtblRefer');

            // Constants for row positions
            const ROW_DEPARTMENT = 0;
            const ROW_DOCTOR = 1;
            const ROW_NOTE = 2;

            // Initialize table with empty rows if needed
            function initializeTable() {
                while ($referTable.find('tr').length < 3) {
                    $referTable.append('<tr style="display:none"><td></td></tr>');
                }
            }

            // Update table visibility based on content
            function updateTableVisibility() {
                const hasContent = $referTable.find('td').text().trim() !== '';
                $divRefer.toggle(hasContent);
            }

            // Handle patient category change
            $patientCategory.on('change', function () {
                const selectedValue = $(this).val();
                const selectedText = $(this).find('option:selected').text();

                initializeTable();
                const $deptRow = $referTable.find(`tr:eq(${ROW_DEPARTMENT})`);

                if (selectedValue && selectedValue !== "0") {
                    // Update department row
                    $deptRow.find('td').text("Department: " + selectedText);
                    $deptRow.show();
                } else {
                    // Remove department row and all other rows if department is 0
                    $referTextbox.empty();
                    $referTable.empty();
                    $divRefer.hide();
                    return;
                }

                updateTableVisibility();
            });

            // Handle doctors dropdown change
            $doctorsDropdown.on('change', function () {
                if ($patientCategory.val() === "0") return;

                initializeTable();
                var $doctorRow = $referTable.find(`tr:eq(${ROW_DOCTOR})`);
                var selectedValue = $(this).val();
                var selectedText = $(this).find('option:selected').text();

                if (selectedValue && selectedValue !== "0") {
                    // Update doctor row
                    $doctorRow.find('td').text("Doctor: " + selectedText);
                    $doctorRow.show();
                } else {
                    // Remove doctor row

                    $doctorRow.find('td').empty();
                    $doctorRow.hide();
                }

                updateTableVisibility();
            });

            // Handle refer textbox input
            $referTextbox.on('input', function () {
                if ($patientCategory.val() === "0") return;

                initializeTable();
                const $noteRow = $referTable.find(`tr:eq(${ROW_NOTE})`);
                const inputValue = $(this).val().trim();

                if (inputValue) {
                    // Update note row
                    $noteRow.find('td').text("Note: " + inputValue);
                    $noteRow.show();
                } else {
                    // Remove note row
                    $noteRow.find('td').empty();
                    $noteRow.hide();
                }

                updateTableVisibility();
            });
            $('#filterExaminations').change(filterExaminations);
            updateHistoryTable();
            loadDepartments();
            $('#filterDepartments option[value="000"]').prop('selected', true);
            GetSymptomsByDepartment();
            fillSymptoms("000", "");
            $('#filterDepartments').select2();
            // Handle department filter changes
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
                        $('#divtblGeneralExam').hide();
                    }

                    return; // Exit
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
                $('#divtblGeneralExam').show();
            });
            // Handle search input
            $('#tab01Search').on('input', function () {
                const searchTerm = $(this).val().trim();
                const selectedValue = $('#filterDepartments').val();
                fillSymptoms(selectedValue, searchTerm);
            });

            $('#dvtblSymtomps').hide();

            $('#filterSelect').select2();

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


        });

        $(document).on('input', '.history-row textarea, .history-row input[type="text"]', function () {
            updateHistoryTable();
        });
        $(document).on('input', '.Systematic-Exam-Row textarea, .Systematic-Exam-Row input[type="text"]', function () {
            updateSystematicExamTable();
        });
        function Remove_CustomInputRow() {
            const examName = 'CustomInput';

            // Remove the row
            $(`#tblGeneralExam tbody tr[data-exam="${examName}"]`).remove();

            // Clear textbox
            $('#ctl00_MainContent_txtInputBox1').val('');

            // Hide table if no rows
            if ($('#tblGeneralExam tbody tr').length === 0) {
                $('#divtblGeneralExam').hide();
            }
        }
        function filterExaminations() {

            const selectedValue = $('#filterExaminations').val();

            $('.subtabs').hide();

            if (selectedValue === '001') {
                $('#subTab001').show();
            }

            else if (selectedValue === '002') {
                $('#subTab002').show();
            }
            else {
                $('#subTab003').show();
            }
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
        function AddNewSymptom() {
            $('#AddNewSymptom').modal('show');

            $('#saveNewSymptom').off('click').on('click', function () {
                var name = $('#SymptomName').val();
                $.ajax({
                    type: "POST",
                    url: "NewOutPatient.aspx/SaveNewSymptom",
                    data: JSON.stringify({ name: name }),
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
            });
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
                        $('#dvtblSymtomps').show(); // 👈 Show the table container
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
                    $('#dvtblSymtomps').show(); // 👈 Show the table container
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
                $('#dvtblSymtomps').hide();
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
                    $('#dvtblSymtomps').hide();
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
        // Toggle submenu for items with dropdowns
        function toggleMenu(element) {
            // Toggle active class (expand/collapse submenu)
            element.classList.toggle('active');
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
            tableContainer.show();
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
                historyContainer.show();
            } else {
                historyContainer.hide();
            }
        }
        function updateSystematicExamTable() {
            const SystematicExamTable = $('#SystematicExam tbody');
            const SystematicExam = $('#divtblSystematicExam');
            let hasData = false;

            // Clear existing rows
            SystematicExamTable.empty();

            // Process each examination field
            $('.Systematic-Exam-Row').each(function () {
                // Get the label - ASP.NET renders it as a span with ID ending with "_LabelXX"
                const labelSpan = $(this).find('span[id*="_Label"]');
                const label = labelSpan.length ? labelSpan.text().trim() : '';

                // Get the textbox value
                const textbox = $(this).find('textarea, input[type="text"]');
                const value = textbox.length ? textbox.val().trim() : '';

                if (value) {
                    // Append new row with formatted text
                    SystematicExamTable.append(`
                <tr>
                    <td><strong>${label}:</strong> ${value}</td>
                </tr>
            `);
                    hasData = true;
                }
            });

            // Show/hide container based on whether there's data
            SystematicExam.toggle(hasData);
        }
        // Handle click for items without submenu (e.g., navigation, actions)
        function navigateAction(element) {
            // Hide all tabs first
            const allTabs = document.querySelectorAll('.tabs');
            allTabs.forEach(tab => {
                tab.style.display = 'none';
            });

            // Get the ID of the tab to show (e.g., "tab02" for "Vitals")
            const tabId = 'tab' + element.id;

            // Show the selected tab
            const selectedTab = document.getElementById(tabId);
            if (selectedTab) {
                selectedTab.style.display = 'block';
            }

            // You can add additional navigation logic here if needed
        }
        function Add_GeneralExamRow(examName) {
            const $tableBody = $('#tblGeneralExam tbody');

            // Check if the row already exists
            if ($tableBody.find(`tr[data-exam="${examName}"]`).length > 0) return;

            // Create new row
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
            $('#divtblGeneralExam').show();
        }
        function Remove_GeneralExamRow(examName) {
            // Remove the row
            $(`#tblGeneralExam tbody tr[data-exam="${examName}"]`).remove();

            // Uncheck the corresponding checkbox
            $(`input[type="checkbox"][onclick*="'${examName}'"]`).prop('checked', false);

            // Hide the table container if no rows
            if ($('#tblGeneralExam tbody tr').length === 0) {
                $('#divtblGeneralExam').hide();
            }
        }


        // Optional: Close all open submenus when clicking outside the sidebarr
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

        function openManageSymptomsModal() {
            $('#manageSymptomsModal').modal('show');
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
                            <div class="card">
                                <div class="card-body">
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
        <!-- Left Column (6 units) -->
        <div class="col-md-6">
            <!-- Patient Card -->
            <div class="row">
                <div class="col-12">
                    <div class="card">
                        <div class="card-body">
                            <div class="row">
                                <div class="col-lg-3 col-md-3 col-sm-4 text-center">
                                    <div class="image-container">
                                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/Patient.png" alt="Patient Image" class="img-fluid patient-image" />
                                    </div>
                                </div>
                                <div class="col-lg-9 col-md-9 col-sm-8">
                                    <asp:TextBox ID="txtOut_Patient_ID" runat="server" ReadOnly="True" Style="display: none;"></asp:TextBox>

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
                                            <asp:Label ID="lblPatien_ID" CssClass="labels" runat="server" Text="OPD No *"></asp:Label>
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
            </div>

            <!-- Sidebar and Content Area -->
            <div class="row">
                <!-- Sidebar (4 units) -->
                <div class="col-md-4 col-sm-12 p-0">
                    <div class="sidebarr">
                        <div class="menu-item no-submenu" id="01" onclick="navigateAction(this)">
                            <div class="menu-title">
                                <span>Symptoms</span>
                            </div>
                        </div>
                        <div class="menu-item no-submenu" id="02" onclick="navigateAction(this)">
                            <div class="menu-title">
                                <span>Vitals</span>
                            </div>
                        </div>

                        <div class="menu-item no-submenu" id="03" onclick="navigateAction(this)">
                            <div class="menu-title">
                                <span>History</span>
                            </div>
                        </div>

                        <div class="menu-item no-submenu" id="04" onclick="navigateAction(this)">
                            <div class="menu-title">
                                <span>Examination</span>
                            </div>
                        </div>

                        <div class="menu-item no-submenu" id="05" onclick="navigateAction(this)">
                            <div class="menu-title">
                                <span>Refer To</span>
                            </div>
                        </div>

                        <div class="menu-item" onclick="toggleMenu(this)">
                            <div class="menu-title">
                                <span>Tests</span>
                                <span class="toggle-icon"></span>
                            </div>
                            <div class="submenu">
                                <div class="submenu-item">By Template</div>
                                <div class="submenu-item">Add New</div>
                            </div>
                        </div>

                        <div class="menu-item no-submenu" onclick="navigateAction(this)">
                            <div class="menu-title">
                                <span>Services</span>
                            </div>
                        </div>

                        <div class="menu-item" onclick="toggleMenu(this)">
                            <div class="menu-title">
                                <span>Medication</span>
                                <span class="toggle-icon"></span>
                            </div>
                            <div class="submenu">
                                <div class="submenu-item">By Template</div>
                                <div class="submenu-item">Add New</div>
                            </div>
                        </div>

                        <div class="menu-item no-submenu" onclick="navigateAction(this)">
                            <div class="menu-title">
                                <span>Follow Up</span>
                            </div>
                        </div>

                        <div class="menu-item no-submenu" onclick="navigateAction(this)">
                            <div class="menu-title">
                                <span>Disposal</span>
                            </div>
                        </div>

                        <div class="menu-item no-submenu" onclick="navigateAction(this)">
                            <div class="menu-title">
                                <span>Test Results</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Content Area (8 units) -->
                <div class="col-md-8 col-sm-12">
                    <div class="card">
                        <div class="card-body">
                            <div class="tabs" id="tab01" style="display: none">
                                <div style="display: flex; justify-content: flex-end;">
                                    <input type="button" class="mybutton" value="Add New" onclick="AddNewSymptom()" />
                                    <input style="margin-left: 5px" type="button" class="mybutton" value="Manage Symptoms" onclick="openManageSymptomsModal()" />
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
                                    <input type="button" class="mybutton" value="Add Vitals" onclick="AddVitals()" />
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
                            <div class="tabs" id="tab05">
                                <div class="refer-row" style="display: flex; align-items: center; justify-content: space-between; ">
                                    <div style="display: flex; align-items: center;width:100%">
                                        <asp:Label Style="width: 200px;" ID="Label14" runat="server" Text="Refered To"></asp:Label>
                                        <asp:DropDownList ID="ddlPatient_Main_Category" onchange="loaddoctor_byDep()" Width="80%" runat="server" AppendDataBoundItems="true" TabIndex="21"></asp:DropDownList>
                                    </div>
                                </div>
                                <div class="refer-row" style="display: flex; align-items: center; justify-content: space-between;">
                                    <div style="display: flex; align-items: center;width:100%">
                                        <asp:Label Style="width: 200px;" ID="Label18" runat="server" Text="Doctor"></asp:Label>
                                        <select style="width:80%" id="ddldoctors"></select>
                                    </div>
                                </div>
                                <div class="refer-row" style="display: flex; align-items: center; justify-content: space-between;">
                                    <div style="display: flex; align-items: center;width:100%">
                                        <asp:Label Style="width: 200px;" ID="Label19" runat="server" Text="Referral Note"></asp:Label>
                                        <asp:TextBox ID="txtRefferNote" TextMode="SingleLine" Width="80%" CssClass="refer-textbox" runat="server" TabIndex="22"></asp:TextBox>
                                    </div>
                                </div>
                            </div>

                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Right Column (6 units) -->
        <div class="col-md-6 col-sm-12">

            <div style="display: flex; justify-content: flex-end;">
                <input type="button" class="mybutton" value="History" onclick="AddNewSymptom()" />
                <input type="button" class="mybutton" value="Queue" onclick="openManageSymptomsModal()" />
                <input type="button" class="mybutton" value="Discharge" onclick="AddNewSymptom()" />
                <input type="button" class="mybutton" value="Reset" onclick="openManageSymptomsModal()" />
                <input type="button" class="mybutton" value="Save" onclick="AddNewSymptom()" />

            </div>
            <div class="card">
                <div class="card-body">
                    <div class="row">
                        <div class="col-lg-3" id="dvtblSymtomps">
                            <div>
                                <div class="table-responsive">
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
                        <div id="divtblVitals" style="display: none" class="col-lg-9">
                            <div>
                                <div class="table-responsive">
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
                        <div id="divtblHistory" style="display: none" class="col-lg-6">
                            <div>
                                <div class="table-responsive">
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
                        <div id="divtblGeneralExam" style="display: none" class="col-lg-3">
                            <div>
                                <div class="table-responsive">
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
                        <div id="divtblSystematicExam" style="display: none" class="col-lg-6">
                            <div>
                                <div class="table-responsive">
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
                        <div id="divtblRefer" style="display: none" class="col-lg-4">
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
                    </div>
                </div>
            </div>
        </div>
    </div>






</asp:Content>
