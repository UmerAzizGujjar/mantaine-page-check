<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="NewOutPatient.aspx.cs" Inherits="PMS.Modules.PatientManagement.NewOutPatient" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">


    <style title="sidebar">
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
        .select2-container--default .select2-selection--single {
            height: 44px;
            padding: 0 12px;
            font-size: 14px;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
        }

        /* Dropdown Container - Matches Select Height */
        .select2-dropdown {
            border: 1px solid #d1d5db;
            border-radius: 8px;
            font-size: 14px;
        }

        /* Options - Match Select Height */
        .select2-results__option {
            padding: 12px;
            line-height: 20px;
            min-height: 44px;
            display: flex;
            align-items: center;
        }

        /* Permanent Blue Filter Icon */
        .select2-selection__placeholder i,
        .select2-selection__rendered i {
            margin-right: 8px;
            font-size: 14px;
            /* Always blue */
            filter: brightness(0) saturate(100%) invert(44%) sepia(94%) saturate(1352%) hue-rotate(193deg) brightness(101%) contrast(87%);
            vertical-align: middle;
        }

        /* Dropdown Animation */
        .select2-container--open .select2-dropdown {
            animation: slideDown 0.3s ease-out forwards;
            transform-origin: top center;
            opacity: 0;
            display: block !important; /* Ensure it's visible for animation */
        }

        @keyframes slideDown {
            0% {
                transform: translateY(-10px);
                opacity: 0;
            }

            100% {
                transform: translateY(0);
                opacity: 1;
            }
        }

        /* Result Options Animation */
        .select2-results__option {
            animation: fadeIn 0.3s ease-out forwards;
            animation-delay: calc(var(--option-index) * 0.05s);
            opacity: 0;
            transform: translateY(-5px);
        }

        @keyframes fadeIn {
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Search Field Animation */
        .select2-search--dropdown {
            animation: fadeIn 0.2s ease-out 0.1s forwards;
            opacity: 0;
        }

        /* Arrow Rotation Animation */
        .select2-container--default .select2-selection--single .select2-selection__arrow b {
            transition: transform 0.3s ease;
        }

        .select2-container--open .select2-selection--single .select2-selection__arrow b {
            transform: rotate(180deg);
        }

        /* Ensure proper z-index for animations */
        .select2-container--open {
            z-index: 9999;
        }

        th {
            color: white !important
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


        .symptom-row {
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

            .symptom-row:hover {
                background-color: black;
                color: white;
                /* Optional: Add slight scale effect */
                transform: scale(1.02);
                /* Ensure smooth scaling if added */
                transition: background-color 0.3s ease, color 0.3s ease, transform 0.2s ease;
            }

            .symptom-row label {
                margin-left: 10px;
                margin-bottom: 0;
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
                    '<td><a href="#" onclick="RemoveSymtomRowInModal(\'' + id + '\')">Delete</a></td></tr>';


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
                                '<td><a href="#" onclick="RemoveSymtomRowInModal(\'' + symptom.SymptomId + '\')">Delete</a></td>' +
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
            loadDepartments();
            $('#filterDepartments option[value="000"]').prop('selected', true);
            GetSymptomsByDepartment();

            fillSymptoms("000", "");

            // Handle department filter changes
            $('#filterDepartments').change(function () {
                const selectedValue = $(this).val();
                const searchTerm = $('#tab01Search').val().trim();
                fillSymptoms(selectedValue, searchTerm);
            });

            // Handle search input
            $('#tab01Search').on('input', function () {
                const searchTerm = $(this).val().trim();
                const selectedValue = $('#filterDepartments').val();
                fillSymptoms(selectedValue, searchTerm);
            });
            $('.select2').on('select2:open', function () {
                // Add index to each option for staggered animation
                $('.select2-results__option').each(function (index) {
                    $(this).css('--option-index', index);
                });
            });
            $('.enhanced-select2').select2({
                placeholder: '<i class="fa fa-filter"></i> Filter documents',
                allowClear: true,
                escapeMarkup: function (markup) {
                    return markup; // Allows HTML
                },
                templateSelection: function (data) {
                    // Always show icon, whether placeholder or selected
                    if (data.id) {
                        return '<i class="fas fa-filter" style="margin-right:8px;color:#3b82f6"></i>' + data.text;
                    }
                    return data.text; // Placeholder already has icon
                },
                dropdownParent: $('.big-select2')
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
                        '<td> <a href="#" onclick="Delete_Symtom(this)">Delete</a></td></tr>';

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
                    '<td  > <a href="#" onclick="Delete_Symtom(this)">Delete</a></td></tr>';

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

        z


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
                            '<i class="fa fa-plus-circle" style="font-size: 18px; color: #28a745;"></i>' +
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

        // Handle click for items without submenu (e.g., navigation, actions)
        function navigateAction(element) {
            const menuText = element.querySelector('.menu-title span').textContent;

            // Example action: show alert
            alert(`${menuText} clicked! This item has no submenu.`);

            // You can replace this with actual navigation:
            // Example: 
            // if (menuText === 'Profile') {
            //     window.location.href = '/profile';
            // } else if (menuText === 'Help & Support') {
            //     window.location.href = '/help';
            // }
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
        });// Function to open the modal
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
     <div id="AddSymptomsByModal" class="modal fade" data-backdrop="static" tabindex="-1" role="dialog">
     <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable" role="document">
         <div class="modal-content">
             <div class="modal-body">
                 <div class="row">
                       <div class="col-lg-3">
                           <input type="text" id="symptomName" disabled/>
                       </div>
                      <div class="col-lg-3">
                          <input type="text" id="duration" placeholder="Duration"/>
                      </div>
                     
                      <div class="col-lg-3">
                          <select id="durationSuffix">
                              <option selected>H</option>
                              <option >D</option>
                              <option >W</option>
                              <option >M</option>
                              <option >Y</option>
                          </select>
                      </div>
                      <div class="col-lg-3">
                          <input type="text" id="Remarks" placeholder="Remarks" />
                      </div>

                 </div>

             </div>
             <div class="modal-footer">

                 <button type="button" class="btn btn-gray" data-dismiss="modal">Close</button>
                 <button id="saveSymptomByModal" type="button" class="btn btn-primry" >Save</button>
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
                                <input type="text" class="form-control mb-2" id="symptomSearch" placeholder="Search..." style="height: 44px !important" />
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
                        <div class="menu-item no-submenu" onclick="navigateAction(this)">
                            <div class="menu-title">
                                <span>Symptoms</span>
                            </div>
                        </div>

                        <div class="menu-item no-submenu" onclick="navigateAction(this)">
                            <div class="menu-title">
                                <span>History</span>
                            </div>
                        </div>

                        <div class="menu-item" onclick="toggleMenu(this)">
                            <div class="menu-title">
                                <span>Examination</span>
                                <span class="toggle-icon"></span>
                            </div>
                            <div class="submenu">
                                <div class="submenu-item">General</div>
                                <div class="submenu-item">Systematic</div>
                                <div class="submenu-item">Special</div>
                            </div>
                        </div>

                        <div class="menu-item no-submenu" onclick="navigateAction(this)">
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
                            <div id="tab01">
                                <div class="row">
                                    <div class="col-md-5 col-sm-12">
                                        <div class="big-select2">
                                            <select class="enhanced-select2" id="filterDepartments">
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-md-7 col-sm-12">
                                        <input type="text" class="form-control mb-2" id="tab01Search" placeholder="Search..." style="height: 44px !important" />
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6 col-sm-12"></div>
                                    <div class="col-md-3 col-sm-6">
                                        <input type="button" onclick="openAddNewSymptomsModal()" value="Add New" style="width: 30px; border-radius: 5px; background-color: antiquewhite; border: 0px; height: 25px;" />
                                    </div>
                                    <div class="col-md-3 col-sm-6">
                                        <input type="button" onclick="openManageSymptomsModal()" value="Manage Symptoms" style="width: 30px; border-radius: 5px; background-color: antiquewhite; border: 0px; height: 25px;" />
                                    </div>
                                </div>
                                <div id="allSymptoms"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Right Column (6 units) -->
        <div class="col-md-6 col-sm-12">
            <div class="card">
                <div class="card-body">
                    <div class="row">
                        <div class="col-lg-3">
                            <div id="dvtblSymtomps">
                                <div class="table-responsive">
                                    <table class="table" id="tblSymtoms">
                                        <thead>
                                            <tr>
                                                <th style="display: none;">Row ID</th>
                                                <th style="display: none;">Symtom ID</th>
                                                <th>Symptom</th>
                                                <th style="display: none;">Dur</th>
                                                <th style="display: none;">D/M/Y</th>
                                                <th style="display: none;">Remarks</th>
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
    </div>






</asp:Content>
