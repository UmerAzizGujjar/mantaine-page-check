<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="NewOutPatient.aspx.cs" Inherits="PMS.Modules.PatientManagement.NewOutPatient" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <style>


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
            /* Base Select2 Styles */
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
    </style>

    <script>
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
                   '<td> ' + $('#txtDuration').val() + ' </td>' +
                   '<td> ' + $('#ddlDaysMonthsYears').find('option:selected').text() + ' </td>' +
                   '<td> ' + $('#txtRemarks').val() + ' </td>' +
                   '<td> <a href="#" onclick="Edit_Symtom(this)">Edit</a> | <a href="#" onclick="Delete_Symtom(this)">Delete</a></td></tr>';

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
        let searchTimeout; // Declare only once, globally

        $(document).on('input', '#tab01Search', function () {
            clearTimeout(searchTimeout);
            const query = $(this).val().toLowerCase();

            searchTimeout = setTimeout(function () {
                const $rows = $('.symptom-row');
                if (query === '') {
                    $rows.hide();
                    $rows.slice(0, 20).show(); // Show only first 20 when nothing is searched
                } else {
                    $rows.each(function () {
                        const labelText = $(this).find('label').text().toLowerCase();
                        $(this).toggle(labelText.includes(query));
                    });
                }
            }, 100); // Debounce delay
        });

        $(document).ready(function () {
            $('.select2').on('select2:open', function() {
    // Add index to each option for staggered animation
    $('.select2-results__option').each(function(index) {
      $(this).css('--option-index', index);
    });
  });
           $('.enhanced-select2').select2({
    placeholder: '<i class="fas fa-filter"></i> Filter documents',
    allowClear: true,
    escapeMarkup: function(markup) {
      return markup; // Allows HTML
    },
    templateSelection: function(data) {
      // Always show icon, whether placeholder or selected
      if (data.id) {
        return '<i class="fas fa-filter" style="margin-right:8px;color:#3b82f6"></i>' + data.text;
      }
      return data.text; // Placeholder already has icon
    },
    dropdownParent: $('.big-select2')
  });
            $('#dvtblSymtomps').hide();
            fillSymptoms();
            $('#filterSelect').select2();

            // Wait for all AJAX to finish before showing initial 20 rows
            $(document).ajaxStop(function () {
                $('.symptom-row').hide();
                $('.symptom-row').slice(0, 20).show();
            });
        });
        function fillSymptoms() {
    var options = '';
    $.ajax({
        url: 'NewOutPatient.aspx/GetSymptoms',
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (response) {
            var data = response.d ? JSON.parse(response.d) : response;
            $.each(data, function (key, value) {
                
               options += '<div class="symptom-row" style="display: flex; align-items: center; justify-content: space-between;">' +
  '<div style="display: flex; align-items: center;">' +
    '<input type="checkbox" id="chk_' + value.DataValue_Name + '" ' +
    'value="' + value.DataValue_Name + '" ' +
    'class="symptom_checkbox" ' +
    'onclick="this.checked ? Add_SymtomRow(\'' + value.DataValue_Name + '\', \'' + value.DataValue_Description + '\') : Remove_SymtomRow(\'' + value.DataValue_Name + '\')" />' +
    '<label for="chk_' + value.DataValue_Name + '" style="margin-left: 8px;">' + value.DataValue_Description + '</label>' +
  '</div>' +
  '<button type="button" class="symptom-add-btn" ' +
    'onclick="AddByModal(\'' + value.DataValue_Name + '\', \'' + value.DataValue_Description + '\')" ' +
    'style="background: none; border: none; cursor: pointer; padding: 8px;">' +
    '<i class="fas fa-plus-circle" style="font-size: 18px; color: #28a745;"></i>' +
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
        });
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-6">
            <div class="row">
                <div class="col-lg-12">
                    <div class="card">
                        <div class="card-body">
                            <div class="row">
                                <div class="col-lg-3 col-md-3 col-sm-4 text-center">
                                    <div class="image-container">
                                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/Patient.png" alt="Patient Image" class="img-fluid patient-image" />
                                    </div>
                                </div>
                                <div class="col-lg-9 col-md-4 col-sm-3">
                                    <asp:TextBox ID="txtOut_Patient_ID" runat="server" ReadOnly="True" Style="display: none;"></asp:TextBox>

                                    <div class="row mb-3">
                                        <div class="col-lg-5 col-md-5 col-sm-6 top">
                                            <asp:Label ID="lblPatient_Name" CssClass="labels" runat="server" Text="Patient Name:"></asp:Label>
                                        </div>
                                        <div class="col-lg-7 col-md-7 col-sm-6 top">
                                            <asp:Label ID="vlblPatients_Name" CssClass="md" runat="server"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="row mb-3">
                                        <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                            <asp:Label ID="lblPatien_ID" CssClass="labels" runat="server" Text="OPD No *"></asp:Label>
                                        </div>
                                        <%--  <div class="col-lg-5 col-md-5 col-sm-6">
    <asp:TextBox ID="txtPatient_ID" runat="server" class="form-control" />
</div>--%>
                                        <div class="col-lg-7 col-md-7 col-sm-6 top">
                                            <asp:Label ID="Label1" CssClass="md" runat="server"></asp:Label>
                                        </div>
                                    </div>

                                    <div class="row mb-3 mtt">
                                        <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                            <asp:Label ID="lblAge_Years" CssClass="labels" runat="server" Text="Age (Years):"></asp:Label>
                                        </div>
                                        <div class="col-lg-7 col-md-7 col-sm-6 top">
                                            <asp:Label ID="vLbl_Age" CssClass="md" runat="server"></asp:Label>
                                        </div>
                                    </div>

                                    <div class="row mb-3 mtt">
                                        <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                            <asp:Label ID="lblContactNo" CssClass="labels" runat="server" Text="Contact No:"></asp:Label>
                                        </div>
                                        <div class="col-lg-7 col-md-7 col-sm-6 top">
                                            <asp:Label ID="vLbl_Contact" CssClass="md" runat="server"></asp:Label>
                                        </div>
                                    </div>





                                    <div class="row mb-3">
                                        <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                            <asp:Label ID="lblAdress" CssClass="labels" runat="server" Text="Address:"></asp:Label>
                                        </div>
                                        <div class="col-lg-7 col-md-7 col-sm-6 top">
                                            <asp:Label ID="vLbl_Adress" CssClass="md" runat="server"></asp:Label>
                                        </div>
                                    </div>

                                    <div class="row mb-3">
                                        <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                            <asp:Label ID="dlblFollowNo" CssClass="labels" runat="server" Text="Follow Up No:"></asp:Label>
                                        </div>
                                        <div class="col-lg-7 col-md-5 col-sm-6 formrgn">
                                            <asp:Label ID="lblFollow" runat="server"></asp:Label>
                                        </div>
                                    </div>
                                </div>








                            </div>
                        </div>
                    </div>
                </div>

            </div>
            <div class="row">
                <div class="col-lg-4 col-md-2 col-sm-2 p-0">
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
                <div class="col-lg-8">
                    <div class="card">
                        <div class="card-body">
                            <div id="tab01">
                                <div class="row">
                                    <div class="col-lg-5">
                                                                       <div class="big-select2" style="">
  <select class="enhanced-select2" style="">
    <option></option>
    <option value="1">Sales Reports</option>
    <option value="2">Customer Data</option>
    
  </select>
</div>
                                    </div>
                                    <div class="col-lg-7">
                                        <input type="text" class="form-control mb-2" id="tab01Search" placeholder="Search..." style="height:44px !important" />

</div>
                                </div>
                                 
                                
                                <div id="allSymptoms"></div>

                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-6">
            <div class="card">
                <div class="card-body">
                    <div id="dvtblSymtomps" style="overflow-y: scroll">
                        <div class="table-container">
                            <table class="table" id="tblSymtoms">
                                <thead>
                                    <tr>
                                        <th style="display: none;">Row ID</th>
                                        <th style="display: none;">Symtom ID</th>
                                        <th>Symptom </th>
                                        <th>Dur </th>
                                        <th>D/M/Y</th>
                                        <th>Remarks </th>
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




</asp:Content>
