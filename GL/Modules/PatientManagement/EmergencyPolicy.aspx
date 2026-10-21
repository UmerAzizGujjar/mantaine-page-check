<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="EmergencyPolicy.aspx.cs" Inherits="PMS.Modules.PatientManagement.EmergencyPolicy" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/responsive-pages.css?v=<%= ((PMS.SiteMaster)Master).Ver("~/wwwroot/THEME_TIBBIT/CustomCSS/responsive-pages.css") %>" rel="stylesheet" />
    <style type="text/css">
        .dt-buttons {
            display:none;
        }

        .company-section {
            padding: 25px;
            border-radius: 12px;
            margin-bottom: 30px;
            border: 2px solid #e0e4ff;
        }

        .form-group {
            display: flex;
            flex-direction: column;
        }

            .form-group label {
                font-weight: 600;
                margin-bottom: 8px;
                color: #4a5568;
            }

        .required {
            color: #e53e3e;
            margin-left: 4px;
        }

        .rights-section {
            margin-top: 25px;
        }

        .rights-title {
            font-size: 1.2rem;
            font-weight: 600;
            color: #4a5568;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .rights-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }

        .right-item {
            display: flex;
            align-items: center;
            padding: 15px;
            background: white;
            border: 2px solid #e2e8f0;
            border-radius: 8px;
            transition: all 0.3s ease;
            cursor: pointer;
        }

            .right-item:hover {
                border-color: #667eea;
                transform: translateY(-2px);
                box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            }

            .right-item.selected {
                border-color: #667eea;
                background: linear-gradient(135deg, #667eea10 0%, #764ba210 100%);
            }

            .right-item input[type="checkbox"] {
                width: 20px !important;
                height: 20px;
                margin-right: 12px;
                accent-color: #667eea;
                cursor: pointer;
            }

            .right-item label {
                font-weight: 500;
                color: #4a5568;
                cursor: pointer;
                flex: 1;
            }

            .right-item .field-desc {
                font-size: 0.85rem;
                color: #718096;
                margin-top: 2px;
            }

        .bulk-actions {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }

        @media (max-width: 768px) {
            .rights-grid {
                grid-template-columns: 1fr;
            }

            .bulk-actions {
                justify-content: center;
            }
        }
    </style>

    <script type="text/javascript">
        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            FillCompany();
            LoadPage();

            const params = new URLSearchParams(window.location.search);
            const companyId = params.get("Company_ID");

            if (companyId) {
                loadCompanyEdit(companyId);
                $("#saveRights").val("Update");
            }

            $('.right-item input[type="checkbox"]').on('change', function () {
                $(this).closest('.right-item').toggleClass('selected', this.checked);
            });

            $("#saveRights").on("click", function () {
                var companyId = $("#company_name").val();

                var allRights = [];
                $('.rights-grid input[type="checkbox"]').each(function () {
                    allRights.push({
                        field_name: $(this).val(),
                        is_enabled: this.checked
                    });
                });

                if (!companyId || companyId === '0') {
                    Swal.fire({
                        icon: 'warning',
                        title: 'Oops...',
                        text: 'Please select a company.',
                        timer: 2000,
                        showConfirmButton: false
                    });
                    return;
                }

                $(this).prop("disabled", true).val("Saving...");

                $.ajax({
                    url: 'EmergencyPolicy.aspx/SaveCompanyEmergencyRights',
                    method: 'POST',
                    data: JSON.stringify({
                        company_id: parseInt(companyId),
                        rights: allRights
                    }),
                    contentType: 'application/json; charset=utf-8',
                    dataType: 'json',
                    success: function (response) {
                        try {
                            var res = JSON.parse(response.d);

                            if (res.success) {
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Saved!',
                                    text: 'Permissions saved successfully.',
                                    showConfirmButton: false,
                                    timer: 2500
                                }).then(() => {
                                    window.location.href = 'EmergencyPolicy.aspx';
                                });
                            } else {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Failed!',
                                    text: 'Error: ' + (res.message || 'Unknown error'),
                                    showConfirmButton: true
                                });
                            }
                        } catch (e) {
                            Swal.fire({
                                icon: 'error',
                                title: 'Parse Error',
                                text: 'Invalid response from server.',
                                timer: 3000
                            });
                        }
                    },
                    error: function (xhr, status, err) {
                        Swal.fire({
                            icon: 'error',
                            title: 'Request Failed',
                            text: 'Could not connect to server.',
                            showConfirmButton: true
                        });
                        console.error("AJAX Error:", xhr, status, err);
                    },
                    complete: function () {
                        $("#saveRights").prop("disabled", false).val(params.get("Company_ID") ? "Update" : "Save");
                    }
                });
            });
        });

        function toggleRight(item, e) {
            // the checkbox and its label already toggle natively
            if (e && $(e.target).is('input, label')) return;
            const $item = $(item);
            const $checkbox = $item.find('input[type="checkbox"]');
            const isChecked = !$checkbox.prop('checked');

            $checkbox.prop('checked', isChecked);
            $item.toggleClass('selected', isChecked);
        }

        function selectAllRights() {
            $('.right-item input[type="checkbox"]').each(function () {
                $(this).prop('checked', true);
                $(this).closest('.right-item').addClass('selected');
            });
        }

        function clearAllRights() {
            $('.right-item input[type="checkbox"]').each(function () {
                $(this).prop('checked', false);
                $(this).closest('.right-item').removeClass('selected');
            });
        }

        function selectBasicFields() {
            clearAllRights();
            const basicFields = ['mr_no', 'emergency_no', 'cash_in_hand', 'mode_presentation', 'cnic', 'patient_category', 'marital_status', 'patient_name', 'last_name', 'mobile', 'age', 'gender', 'address'];
            basicFields.forEach(function (fieldId) {
                const $checkbox = $('#' + fieldId);
                if ($checkbox.length) {
                    $checkbox.prop('checked', true);
                    $checkbox.closest('.right-item').addClass('selected');
                }
            });
        }

        function FillCompany() {
            let options = '<option value="0">Please Select</option>';
            $.ajax({
                url: 'EmergencyPolicy.aspx/GetCompany',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    const data = response.d ? JSON.parse(response.d) : response;
                    $.each(data, function (key, value) {
                        options += `<option value="${value.Company_ID}">${value.Company_Name}</option>`;
                    });
                    $('#company_name').html(options);
                    $('#company_name').select2();
                    if ($('#company_name').data('pending')) {
                        $('#company_name').val($('#company_name').data('pending')).trigger('change');
                    }
                },
                error: function (xhr, status, error) {
                    console.error('Error fetching company data:', error);
                }
            });
        }

        function LoadPage() {
            $("#example").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            window.location = 'EmergencyPolicy.aspx';
                        }
                    },
                    'copy', 'excel', 'pdf',
                ],
                "filter": true,
                "order": [[1, "asc"]],
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "EmergencyPolicy.aspx/ViewList",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length,
                            sortColumn: data.columns[data.order[0].column].name,
                            sortColumnDirection: data.order[0].dir,
                            searchValue: data.search.value
                        }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            callback({
                                draw: response.d.draw,
                                recordsTotal: response.d.recordsTotal,
                                recordsFiltered: response.d.recordsFiltered,
                                data: response.d.data
                            });
                        },
                        error: function (xhr, status, error) {
                            console.log(xhr.responseText);
                        }
                    });
                },
                "columns": [
                    { "data": "Company_ID", "visible": false, "width": "0%", "orderable": false },
                    { "data": "Company_Name", "name": "Company_Name", "width": "8%", "orderable": true },
                    {
                        render: function (data, type, full) {
                            var res = '<a href="#" class="editListBtn" onclick="editOpen(' + full.Company_ID + ')" style="border-radius: 4px;   padding: 5px 8px 5px 8px;"><i  class="fa fa-pencil"></i></a>';

                            var deleteBtn = '<a href="#" class="delListBtn" ' + 'onclick="cancelPolicy(' + full.Company_ID + ')" ' + 'style="border-radius: 4px; margin-left: 4px; color: white; background-color: red; padding: 5px 8px;">' + '<i class="fa fa-trash"></i></a>';

                            return res + deleteBtn;
                        }, "width": "8%", "orderable": false
                    }
                ],
                "initComplete": function (settings, json) {
                    var lengthContainer = document.querySelector('#example_length');
                    var lengthDropdown = document.querySelector('#example_length select');
                    var label = document.querySelector('#example_length label');

                    if (lengthDropdown && label && lengthContainer) {
                        var labelText = document.createElement('span');
                        labelText.textContent = 'Show entries ';
                        labelText.style.marginTop = '10px';
                        labelText.style.display = 'inline-block';

                        lengthDropdown.style.width = '60px';
                        label.innerHTML = '';
                        label.style.display = 'inline-flex';
                        label.style.marginTop = '17px';
                        label.appendChild(labelText);
                        label.appendChild(lengthDropdown);
                    }
                }
            });
        }

        function editOpen(id) {
            window.location.href = "EmergencyPolicy.aspx?Company_ID=" + id;
        }

        function cancelPolicy(id) {
            Swal.fire({
                title: 'Delete Policy?',
                text: 'Emergency Form will go back to its default fields for this company.',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                confirmButtonText: 'Yes, Delete'
            }).then((result) => {
                if (!result.isConfirmed) return;
                $.ajax({
                    url: 'EmergencyPolicy.aspx/DeleteCompanyEmergencyRights',
                    type: 'POST',
                    data: JSON.stringify({ company_id: parseInt(id) }),
                    contentType: 'application/json; charset=utf-8',
                    dataType: 'json',
                    success: function (response) {
                        var res = JSON.parse(response.d);
                        if (res.success) {
                            window.location.href = 'EmergencyPolicy.aspx';
                        } else {
                            Swal.fire({ icon: 'error', title: 'Failed!', text: res.message || 'Unknown error' });
                        }
                    }
                });
            });
        }

        function loadCompanyEdit(companyId) {
            $.ajax({
                url: 'EmergencyPolicy.aspx/GetCompanyDetails',
                type: 'POST',
                data: JSON.stringify({ company_id: parseInt(companyId) }),
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    const data = response.d ? JSON.parse(response.d) : response;

                    if (data) {
                        if (data.Company_ID) {
                            // company list may still be loading
                            $("#company_name").data('pending', data.Company_ID).val(data.Company_ID).trigger("change");
                        }
                        if (data.Rights) {
                            clearAllRights();
                            data.Rights.forEach(function (right) {
                                const $checkbox = $('#' + right.field_name);
                                if ($checkbox.length) {
                                    $checkbox.prop('checked', right.is_enabled);
                                    $checkbox.closest('.right-item')
                                        .toggleClass('selected', right.is_enabled);
                                }
                            });
                        }
                    }
                },
                error: function (xhr, status, error) {
                    console.error("Error loading company:", error);
                }
            });
        }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-8 col-md-12 col-sm-12">
            <div class="company-section">
                <div class="row">
                    <div class="col-lg-3 col-md-4 col-sm-6">
                        <label for="company_name">Company Name <span class="required">*</span></label>
                        <select id="company_name" name="company_name">
                        </select>
                    </div>
                </div>

                <div class="row">
                    <div class="rights-section">
                        <div class="rights-title">
                            <i class="fa fa-lock"></i>
                            Emergency Form Field Permissions
                        </div>

                        <div class="bulk-actions">
                            <div class="col-lg-10 col-md-8 col-sm-8">
                                <div class="col-lg-2 col-md-2 col-sm-2">
                                    <input type="button" class="btn-gray" onclick="selectAllRights()" value="Select All" />
                                </div>
                                <div class="col-lg-2 col-md-2 col-sm-2">
                                    <input type="button" class="btn-gray" onclick="clearAllRights()" value="Clear All" />
                                </div>
                                <div class="col-lg-3 col-md-2 col-sm-2">
                                    <input type="button" class="btn-gray" onclick="selectBasicFields()" value="Basic Fields" />
                                </div>
                            </div>
                        </div>

                        <div class="rights-grid">
                            <div class="right-item" onclick="toggleRight(this, event)">
                                <input type="checkbox" id="mr_no" name="rights[]" value="mr_no" />
                                <div>
                                    <label for="mr_no">MR Number</label>
                                    <div class="field-desc">Medical Record Number</div>
                                </div>
                            </div>

                            <div class="right-item" onclick="toggleRight(this, event)">
                                <input type="checkbox" id="patient_name" name="rights[]" value="patient_name" />
                                <div>
                                    <label for="patient_name">Patient Name</label>
                                    <div class="field-desc">First name of patient</div>
                                </div>
                            </div>

                            <div class="right-item" onclick="toggleRight(this, event)">
                                <input type="checkbox" id="last_name" name="rights[]" value="last_name" />
                                <div>
                                    <label for="last_name">Last Name</label>
                                    <div class="field-desc">Surname of patient</div>
                                </div>
                            </div>

                            <div class="right-item" onclick="toggleRight(this, event)">
                                <input type="checkbox" id="emergency_no" name="rights[]" value="emergency_no" />
                                <div>
                                    <label for="emergency_no">Emergency Number</label>
                                    <div class="field-desc">Emergency visit number</div>
                                </div>
                            </div>

                            <div class="right-item" onclick="toggleRight(this, event)">
                                <input type="checkbox" id="cash_in_hand" name="rights[]" value="cash_in_hand" />
                                <div>
                                    <label for="cash_in_hand">Cash in Hand</label>
                                    <div class="field-desc">Payment method selection</div>
                                </div>
                            </div>

                            <div class="right-item" onclick="toggleRight(this, event)">
                                <input type="checkbox" id="mode_presentation" name="rights[]" value="mode_presentation" />
                                <div>
                                    <label for="mode_presentation">Mode of Presentation</label>
                                    <div class="field-desc">How patient arrived</div>
                                </div>
                            </div>

                            <div class="right-item" onclick="toggleRight(this, event)">
                                <input type="checkbox" id="mobile" name="rights[]" value="mobile" />
                                <div>
                                    <label for="mobile">Mobile Number</label>
                                    <div class="field-desc">Contact phone number</div>
                                </div>
                            </div>

                            <div class="right-item" onclick="toggleRight(this, event)">
                                <input type="checkbox" id="cnic" name="rights[]" value="cnic" />
                                <div>
                                    <label for="cnic">CNIC</label>
                                    <div class="field-desc">National identity card number</div>
                                </div>
                            </div>

                            <div class="right-item" onclick="toggleRight(this, event)">
                                <input type="checkbox" id="patient_category" name="rights[]" value="patient_category" />
                                <div>
                                    <label for="patient_category">Patient Category</label>
                                    <div class="field-desc">General/Private/Panel classification</div>
                                </div>
                            </div>

                            <div class="right-item" onclick="toggleRight(this, event)">
                                <input type="checkbox" id="marital_status" name="rights[]" value="marital_status" />
                                <div>
                                    <label for="marital_status">Marital Status</label>
                                    <div class="field-desc">Single/Married/Divorced/Widowed</div>
                                </div>
                            </div>

                            <div class="right-item" onclick="toggleRight(this, event)">
                                <input type="checkbox" id="age" name="rights[]" value="age" />
                                <div>
                                    <label for="age">Age</label>
                                    <div class="field-desc">Patient's age in years</div>
                                </div>
                            </div>

                            <div class="right-item" onclick="toggleRight(this, event)">
                                <input type="checkbox" id="gender" name="rights[]" value="gender" />
                                <div>
                                    <label for="gender">Gender</label>
                                    <div class="field-desc">Male/Female/Other</div>
                                </div>
                            </div>

                            <div class="right-item" onclick="toggleRight(this, event)">
                                <input type="checkbox" id="fee" name="rights[]" value="fee" />
                                <div>
                                    <label for="fee">Emergency Fee</label>
                                    <div class="field-desc">Amount to be charged</div>
                                </div>
                            </div>

                            <div class="right-item" onclick="toggleRight(this, event)">
                                <input type="checkbox" id="address" name="rights[]" value="address" />
                                <div>
                                    <label for="address">Address</label>
                                    <div class="field-desc">Patient's residential address</div>
                                </div>
                            </div>

                            <div class="right-item" onclick="toggleRight(this, event)">
                                <input type="checkbox" id="remarks" name="rights[]" value="remarks" />
                                <div>
                                    <label for="remarks">Remarks</label>
                                    <div class="field-desc">Remarks</div>
                                </div>
                            </div>

                            <div class="right-item" onclick="toggleRight(this, event)">
                                <input type="checkbox" id="RefferedBy" name="rights[]" value="RefferedBy" />
                                <div>
                                    <label for="RefferedBy">Refer Patient</label>
                                    <div class="field-desc">Refer an existing patient</div>
                                </div>
                            </div>

                            <div class="right-item" onclick="toggleRight(this, event)">
                                <input type="checkbox" id="CostCenter" name="rights[]" value="CostCenter" />
                                <div>
                                    <label for="CostCenter">Cost Center</label>
                                    <div class="field-desc">Cost Center dropdown</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-lg-8 col-md-8 col-sm-8">
                        <div class="col-lg-2 col-md-2 col-sm-2">
                            <input type="button" value="Save" id="saveRights" class="btn-primry" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-lg-4 col-md-12 col-sm-12 company-section">
            <table id="example" class="table table-striped table-bordered display">
                <thead>
                    <tr>
                        <th style="display: none; width: 0%;">Company ID</th>
                        <th>Company Name</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody id="tblbody">
                </tbody>
            </table>
        </div>
    </div>
</asp:Content>
