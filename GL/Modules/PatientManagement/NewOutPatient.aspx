<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="NewOutPatient.aspx.cs" Inherits="PMS.Modules.PatientManagement.NewOutPatient" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        th{
            color:white !important
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

        .page-header {
            display: none;
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
            margin-bottom: 8px;
        }

            .symptom-row label {
                margin-left: 10px;
                margin-bottom: 0;
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
            $('#dvtblSymtomps').hide();
            fillSymptoms();

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
                
                options += '<div class="symptom-row">' +
  '<input type="checkbox" id="chk_' + value.DataValue_Name + '" ' +
  'value="' + value.DataValue_Name + '" ' +
  'class="symptom_checkbox" ' +
  'onclick="this.checked ? Add_SymtomRow(\'' + value.DataValue_Name + '\', \'' + value.DataValue_Description + '\') : Remove_SymtomRow(\'' + value.DataValue_Name + '\')" />' +
  '<label for="chk_' + value.DataValue_Name + '">' + value.DataValue_Description + '</label>' +
'</div>';
;
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
            <div class="card">
                <div class="card-body">
                    <div class="row">
                        <div class="col-lg-2 col-md-3 col-sm-4 text-center">
                            <div class="image-container">
                                <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/Patient.png" alt="Patient Image" class="img-fluid rounded-circle patient-image" />
                            </div>
                        </div>
                        <div class="col-lg-5 col-md-4 col-sm-3">
                            <asp:TextBox ID="txtOut_Patient_ID" runat="server" ReadOnly="True" Style="display: none;"></asp:TextBox>

                            <div class="row mb-3">
                                <div class="col-lg-5 col-md-5 col-sm-6 top">
                                    <asp:Label ID="lblPatient_Name" CssClass="labels" runat="server" Text="Patient Name:"></asp:Label>
                                </div>
                                <div class="col-lg-7 col-md-7 col-sm-6 top">
                                    <asp:Label ID="vlblPatients_Name" CssClass="md" runat="server"></asp:Label>
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

                            <div class="row mb-3 mtt">
                                <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                    <asp:Label ID="lblGender" CssClass="labels" runat="server" Text="Gender:"></asp:Label>
                                </div>
                                <div class="col-lg-7 col-md-7 col-sm-6 top">
                                    <asp:Label ID="vLbl_Gender" CssClass="md" runat="server"></asp:Label>
                                </div>
                            </div>

                            <div class="row mb-3 mtt">
                                <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                    <asp:Label ID="Label10" CssClass="labels" runat="server" Text="Category:"></asp:Label>
                                </div>
                                <div class="col-lg-7 col-md-7 col-sm-6 top">
                                    <asp:Label ID="lblPatient_Category" CssClass="md" runat="server"></asp:Label>
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
                        </div>
                        <div class="col-lg-5">
                            <div class="row mb-3">
                                <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                    <asp:Label ID="LblOut_Patient_ID" CssClass="labels" runat="server" Text="MR No:"></asp:Label>
                                </div>
                                <div class="col-lg-5 col-md-5 col-sm-6">
                                    <asp:TextBox ID="txtPatNO" runat="server" class="form-control" />
                                </div>
                            </div>

                            <div class="row mb-3">
                                <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                    <asp:Label ID="lblPatien_ID" CssClass="labels" runat="server" Text="OPD No *"></asp:Label>
                                </div>
                                <div class="col-lg-5 col-md-5 col-sm-6">
                                    <asp:TextBox ID="txtPatient_ID" runat="server" class="form-control" />
                                </div>
                            </div>

                            <div class="row mb-3">
                                <div class="col-lg-5 col-md-5 col-sm-6">
                                    <asp:Label ID="LblReg_Date" CssClass="labels" runat="server" Text="Reg. Date:"></asp:Label>
                                </div>
                                <div class="col-lg-7 col-md-5 col-sm-6">
                                    <asp:Label ID="vLbl_RegDate" CssClass="md" runat="server"></asp:Label>
                                </div>
                            </div>

                            <div class="row mb-3">
                                <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                    <asp:Label ID="dlbldpt" CssClass="labels" runat="server" Text="Department:"></asp:Label>
                                </div>
                                <div class="col-lg-7 col-md-5 col-sm-6 detail">
                                    <asp:Label ID="lblDpt" runat="server"></asp:Label>
                                </div>
                            </div>
                            <div class="row mb-3">
                                <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                    <asp:Label ID="dlbdoc" CssClass="labels" runat="server" Text="Doctor:"></asp:Label>
                                </div>
                                <div class="col-lg-7 col-md-5 col-sm-6 detail">
                                    <asp:Label ID="lblDoc" runat="server"></asp:Label>
                                </div>
                            </div>

                            <div class="row mb-3">
                                <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                    <asp:Label ID="dlblFollowNo" CssClass="labels" runat="server" Text="Follow No:"></asp:Label>
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
        <div class="col-6">
            <div class="card">
                <div class="card-body">
                </div>
            </div>
        </div>
    </div>
    <div class="row">

        <div class="col-lg-2 col-md-2 col-sm-2 p-0">
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
        <div class="col-lg-4">
            <div class="card">
                <div class="card-body">
                    <div id="tab01">
                        <input type="text" class="form-control mb-2" id="tab01Search" placeholder="Search..." />
                        <div id="allSymptoms"></div>

                    </div>
                </div>
            </div>
        </div>
        <div class="col-lg-6">
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
