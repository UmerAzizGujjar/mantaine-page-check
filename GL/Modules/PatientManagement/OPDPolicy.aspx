<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OPDPolicy.aspx.cs" Inherits="PMS.Modules.PatientManagement.OPDPolicy" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
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

        .section-title {
            font-size: 1.5rem;
            font-weight: 600;
            color: #667eea;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .company-form {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 25px;
            margin-bottom: 25px;
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

        .form-group input,
        .form-group select,
        .form-group textarea {
            padding: 12px 15px;
            border: 2px solid #e2e8f0;
            border-radius: 8px;
            font-size: 1rem;
            transition: all 0.3s ease;
            background: white;
        }

            .form-group input:focus,
            .form-group select:focus,
            .form-group textarea:focus {
                outline: none;
                border-color: #667eea;
                box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
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

        .bulk-btn {
            padding: 8px 16px;
            border: 2px solid #e2e8f0;
            background: white;
            border-radius: 6px;
            cursor: pointer;
            font-size: 0.9rem;
            font-weight: 500;
            transition: all 0.3s ease;
        }

            .bulk-btn:hover {
                border-color: #667eea;
                color: #667eea;
            }

        .action-buttons {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 30px;
        }

        .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

            .btn-primary:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 20px rgba(102, 126, 234, 0.3);
            }

        .btn-secondary {
            background: #e2e8f0;
            color: #4a5568;
        }

            .btn-secondary:hover {
                background: #cbd5e0;
            }

        .btn-success {
            background: linear-gradient(135deg, #48bb78 0%, #38a169 100%);
            color: white;
        }

            .btn-success:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 20px rgba(72, 187, 120, 0.3);
            }

        .companies-list {
            background: #f7fafc;
            padding: 20px;
            border-radius: 12px;
            margin-top: 30px;
        }

            .companies-list h3 {
                color: #4a5568;
                margin-bottom: 15px;
                font-size: 1.2rem;
            }

        .company-item {
            display: flex;
            justify-content: between;
            align-items: center;
            padding: 12px 15px;
            background: white;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            margin-bottom: 10px;
        }

        .company-info {
            flex: 1;
        }

        .company-name {
            font-weight: 600;
            color: #2d3748;
        }

        .company-rights-count {
            font-size: 0.9rem;
            color: #718096;
            margin-top: 2px;
        }

        .company-actions {
            display: flex;
            gap: 10px;
        }

        .btn-small {
            padding: 6px 12px;
            font-size: 0.85rem;
            border-radius: 6px;
            border: 1px solid #e2e8f0;
            background: white;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .btn-edit:hover {
            border-color: #667eea;
            color: #667eea;
        }

        .btn-delete:hover {
            border-color: #e53e3e;
            color: #e53e3e;
        }

        .success-message {
            background: linear-gradient(135deg, #48bb78 0%, #38a169 100%);
            color: white;
            padding: 15px 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            display: none;
            align-items: center;
            gap: 10px;
        }

        @media (max-width: 768px) {
            .company-form {
                grid-template-columns: 1fr;
            }

            .rights-grid {
                grid-template-columns: 1fr;
            }

            .action-buttons {
                flex-direction: column;
                align-items: stretch;
            }

            .bulk-actions {
                justify-content: center;
            }

            .header h1 {
                font-size: 2rem;
            }
        }
    </style>

    <script type="text/javascript">
        let companiesData = [];     
        $(document).ready(function () {
            FillCompany(); 
            renderCompanies(); 

            const params = new URLSearchParams(window.location.search);
            const companyId = params.get("Company_ID");

            if (companyId) {
                loadCompanyEdit(companyId);
                $("#saveRights").val("Update");
            }


            $("#saveRights").on("click", function () {
                var companyId = $("#company_name").val();
                var companyCode = $("#company_code").val();
                var description = $("#company_description").val();

                // 
                var allRights = [];
                $('.rights-grid input[type="checkbox"]').each(function () {
                    allRights.push({
                        field_name: $(this).val(),
                        is_enabled: this.checked
                    });
                });

                if (!companyId) {
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
                    url: 'OPDPolicy.aspx/SaveCompanyOpdRights',
                    method: 'POST',
                    data: JSON.stringify({
                        company_id: parseInt(companyId),
                        company_code: companyCode,
                        description: description,
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
                                    timer: 2500,
                                    customClass: {
                                        popup: 'swal-big-popup',
                                        title: 'swal-big-title',
                                        htmlContainer: 'swal-big-text'
                                    }
                                }).then(() => {
                                    window.location.reload();
                                });
                            } else {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Failed!',
                                    text: 'Error: ' + (res.message || 'Unknown error'),
                                    timer: 3000,
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
                            timer: 3000,
                            showConfirmButton: true
                        });
                        console.error("AJAX Error:", xhr, status, err);
                    },
                    complete: function () {
                        $("#saveRights").prop("disabled", false).val("Save");
                    }
                });
            });
        });

        function toggleRight(item) {
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
            const basicFields = ['mr_no', 'opd_no', 'cash_in_hand', 'mode_presentation', 'cnic', 'patient_category','marital_status', 'patient_name', 'last_name', 'mobile', 'age', 'gender', 'address'];
            basicFields.forEach(function (fieldId) {
                const $checkbox = $('#' + fieldId);
                if ($checkbox.length) {
                    $checkbox.prop('checked', true);
                    $checkbox.closest('.right-item').addClass('selected');
                }
            });
        }

    
    
        function clearForm() {
            $('#rightsForm')[0].reset();
            clearAllRights();
        }

        function previewRights() {
            const companyName = $('#company_name').val().trim();
            const selectedRights = [];
            $('.right-item input:checked').each(function () {
                selectedRights.push($(this).next().find('label').text().trim());
            });

            if (!companyName) {
                alert('Please enter company name first');
                return;
            }

            const preview = `Company: ${companyName}\nPermitted Fields: ${selectedRights.length ? selectedRights.join(', ') : 'None selected'}`;
            alert(preview);
        }

        function showSuccessMessage() {
            const $successMsg = $('#success-message');
            $successMsg.show().css('display', 'flex');
            setTimeout(function () {
                $successMsg.hide();
            }, 3000);
        }

        //function renderCompanies() {
        //    const $container = $('#companies-container');

        //    if (companiesData.length === 0) {
        //        $container.html('<p style="color: #718096; text-align: center; padding: 20px;">No companies configured yet. Create your first company above.</p>');
        //        return;
        //    }

        //    const html = companiesData.map(function (company, index) {
        //        return `
        //        <div class="company-item">
        //            <div class="company-info">
        //                <div class="company-name">${company.name} (${company.code})</div>
        //                <div class="company-rights-count">${company.rights.length} fields permitted</div>
        //            </div>
        //            <div class="company-actions">
        //                <button class="btn-small btn-edit" onclick="editCompany(${index})">Edit</button>
        //                <button class="btn-small btn-delete" onclick="deleteCompany(${index})">Delete</button>
        //            </div>
        //        </div>`;
        //    }).join('');

        //    $container.html(html);
        //}

        function editCompany(index) {
            const company = companiesData[index];
            $('#company_name').val(company.name);
            $('#company_code').val(company.code);
            $('#company_description').val(company.description || '');

            clearAllRights();

            $.each(company.rights, function (i, rightValue) {
                const $checkbox = $('#' + rightValue);
                if ($checkbox.length) {
                    $checkbox.prop('checked', true);
                    $checkbox.closest('.right-item').addClass('selected');
                }
            });

            companiesData.splice(index, 1);
            renderCompanies();
        }

        function deleteCompany(index) {
            if (confirm('Are you sure you want to delete this company?')) {
                companiesData.splice(index, 1);
                renderCompanies();
            }
        }

        function FillCompany() {
            let options = '<option value="0">Please Select</option>';
            $.ajax({
                url: 'OPDPolicy.aspx/GetCompany',
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
                },
                error: function (xhr, status, error) {
                    console.error('Error fetching company data:', error);
                }
            });
        }

        $('#rightsForm').on('submit', function (e) {
            e.preventDefault();

            const companyName = $('#company_name').val().trim();
            const companyCode = $('#company_code').val().trim();
            const companyDescription = $('#company_description').val().trim();
            const selectedRights = [];
            $('input[name="rights[]"]:checked').each(function () {
                selectedRights.push($(this).val());
            });

            if (!companyName || !companyCode) {
                alert('Please fill in required fields: Company Name and Company Code');
                return;
            }

            if (selectedRights.length === 0) {
                if (!confirm('No fields selected. This company will have no access to any fields. Continue?')) {
                    return;
                }
            }

            if (companiesData.some(company => company.code === companyCode)) {
                alert('Company code already exists. Please use a unique code.');
                return;
            }

            const companyData = {
                name: companyName,
                code: companyCode,
                description: companyDescription,
                rights: selectedRights,
                createdAt: new Date().toISOString()
            };

            companiesData.push(companyData);
            console.log('Saved Company Rights:', companyData);

            clearForm();
            showSuccessMessage();
            renderCompanies();
        });

        $(document).ready(function () {
            debugger;
            $('#ctl00_lblMessage').hide();
            LoadPage();
        });


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
                            window.location = 'Define_Policy.aspx';
                        }
                    },
                    'copy', 'excel', 'pdf',
                ],
                "filter": true,
                "order": [[1, "asc"]],
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "OPDPolicy.aspx/ViewList",
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



                            var result;
                            result = res + deleteBtn;
                            return result;
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
                    } else {
                        console.log("Length dropdown, label, or container not found");
                    }
                }


            });
        }


        function editOpen(id) {
            window.location.href = "OPDPolicy.aspx?Company_ID=" + id;
        }

        debugger;
        function loadCompanyEdit(companyId) {
            debugger;
            $.ajax({
                url: 'OPDPolicy.aspx/GetCompanyDetails',
                type: 'POST',
                data: JSON.stringify({ company_id: parseInt(companyId) }),
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    const data = response.d ? JSON.parse(response.d) : response;

                    if (data) {
                        if (data.Company_ID) {
                            $("#company_name").val(data.Company_ID).trigger("change");
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

        <div class="row">
            <div class="col-lg-8 col-md-4 col-sm-6">
        <div class="content">
            <div class="company-section">
                <form id="rightsForm">
                    <div class="row">
                        <div class="col-lg-3 col-md-3 col-sm-4">
                            <label for="company_name">Company Name <span class="required">*</span></label>
                            <select id="company_name" name="company_name">
                                <!-- Options will be filled by JavaScript -->
                            </select>
                        </div>
                        <div class="col-lg-3 col-md-3 col-sm-4" style="display:none">
                            <label for="company_code">Company Code</label>
                            <input type="text" id="company_code" name="company_code" placeholder="e.g., HOSP001" />
                        </div>
                        <div class="col-lg-3 col-md-3 col-sm-4" style="display:none">
                            <label for="company_description">Description</label>
                            <input type="text" id="company_description" name="company_description" placeholder="Optional description about the company" />
                        </div>
                    </div>

                    <div class="row">
                        <div class="rights-section">
                            <div class="rights-title">
                                <span>🔐</span>
                                OPD Form Field Permissions
                            </div>

                            <div class="bulk-actions">
                                <div class="col-lg-10 col-md-8 col-sm-8">
                                    <div class="col-lg-2 col-md-2 col-sm-2">
                                        <input type="button" class="btn-gray" onclick="selectAllRights()" value="Select All" />

                                    </div>
                                    <div class="col-lg-2 col-md-2 col-sm-2">
                                        <input type="button" class="btn-gray" onclick="clearAllRights()" value="Clear All" />

                                    </div>
                                    <div class="col-lg-2 col-md-2 col-sm-2">
                                        <input type="button" class="btn-gray" onclick="selectBasicFields()" value="Basic Fields" />

                                    </div>
                                 <%--   <div class="col-lg-2 col-md-2 col-sm-2">
                                        <input type="button" class="btn-gray" onclick="selectAdvancedFields()" value="Advanced Fields Only" />

                                    </div>--%>
                                </div>
                            </div>

                            <div class="rights-grid">
                                <div class="right-item" onclick="toggleRight(this)">
                                    <input type="checkbox" id="mr_no" name="rights[]" value="mr_no" />
                                    <div>
                                        <label for="mr_no">MR Number</label>
                                        <div class="field-desc">Medical Record Number</div>
                                    </div>
                                </div>

                                <div class="right-item" onclick="toggleRight(this)">
                                    <input type="checkbox" id="patient_name" name="rights[]" value="patient_name" />
                                    <div>
                                        <label for="patient_name">Patient Name</label>
                                        <div class="field-desc">First name of patient</div>
                                    </div>
                                </div>

                                <div class="right-item" onclick="toggleRight(this)">
                                    <input type="checkbox" id="last_name" name="rights[]" value="last_name" />
                                    <div>
                                        <label for="last_name">Last Name</label>
                                        <div class="field-desc">Surname of patient</div>
                                    </div>
                                </div>

                                <div class="right-item" onclick="toggleRight(this)">
                                    <input type="checkbox" id="opd_no" name="rights[]" value="opd_no" />
                                    <div>
                                        <label for="opd_no">OPD Number</label>
                                        <div class="field-desc">Outpatient Department Number</div>
                                    </div>
                                </div>

                                <div class="right-item" onclick="toggleRight(this)">
                                    <input type="checkbox" id="cash_in_hand" name="rights[]" value="cash_in_hand" />
                                    <div>
                                        <label for="cash_in_hand">Cash in Hand</label>
                                        <div class="field-desc">Payment method selection</div>
                                    </div>
                                </div>

                                <div class="right-item" onclick="toggleRight(this)">
                                    <input type="checkbox" id="mode_presentation" name="rights[]" value="mode_presentation" />
                                    <div>
                                        <label for="mode_presentation">Mode of Presentation</label>
                                        <div class="field-desc">How patient arrived (OPD/Emergency)</div>
                                    </div>
                                </div>

                                <div class="right-item" onclick="toggleRight(this)">
                                    <input type="checkbox" id="mobile" name="rights[]" value="mobile" />
                                    <div>
                                        <label for="mobile">Mobile Number</label>
                                        <div class="field-desc">Contact phone number</div>
                                    </div>
                                </div>

                                <div class="right-item" onclick="toggleRight(this)">
                                    <input type="checkbox" id="cnic" name="rights[]" value="cnic" />
                                    <div>
                                        <label for="cnic">CNIC</label>
                                        <div class="field-desc">National identity card number</div>
                                    </div>
                                </div>

                                <div class="right-item" onclick="toggleRight(this)">
                                    <input type="checkbox" id="patient_category" name="rights[]" value="patient_category" />
                                    <div>
                                        <label for="patient_category">Patient Category</label>
                                        <div class="field-desc">General/VIP/Staff classification</div>
                                    </div>
                                </div>

                                <div class="right-item" onclick="toggleRight(this)">
                                    <input type="checkbox" id="marital_status" name="rights[]" value="marital_status" />
                                    <div>
                                        <label for="marital_status">Marital Status</label>
                                        <div class="field-desc">Single/Married/Divorced/Widowed</div>
                                    </div>
                                </div>

                                <div class="right-item" onclick="toggleRight(this)">
                                    <input type="checkbox" id="age" name="rights[]" value="age" />
                                    <div>
                                        <label for="age">Age</label>
                                        <div class="field-desc">Patient's age in years</div>
                                    </div>
                                </div>

                                <div class="right-item" onclick="toggleRight(this)">
                                    <input type="checkbox" id="gender" name="rights[]" value="gender" />
                                    <div>
                                        <label for="gender">Gender</label>
                                        <div class="field-desc">Male/Female/Other</div>
                                    </div>
                                </div>

                                <div class="right-item" onclick="toggleRight(this)">
                                    <input type="checkbox" id="fee" name="rights[]" value="fee" />
                                    <div>
                                        <label for="fee">Consultation Fee</label>
                                        <div class="field-desc">Amount to be charged</div>
                                    </div>
                                </div>

                                <div class="right-item" onclick="toggleRight(this)">
                                    <input type="checkbox" id="address" name="rights[]" value="address" />
                                    <div>
                                        <label for="address">Address</label>
                                        <div class="field-desc">Patient's residential address</div>
                                    </div>
                                </div>

                                <div class="right-item" onclick="toggleRight(this)">
                                    <input type="checkbox" id="card" name="rights[]" value="card" />
                                    <div>
                                        <label for="card">Card Options</label>
                                        <div class="field-desc">Card-related checkboxes</div>
                                    </div>
                                </div>

                                <div class="right-item" onclick="toggleRight(this)">
                                    <input type="checkbox" id="follow_up" name="rights[]" value="follow_up" />
                                    <div>
                                        <label for="follow_up">Follow Up</label>
                                        <div class="field-desc">Follow-up appointment options</div>
                                    </div>
                                </div>
                                <div class="right-item" onclick="toggleRight(this)">
                                    <input type="checkbox" id="Services" name="rights[]" value="Services" />
                                    <div>
                                        <label for="Service">Service</label>
                                        <div class="field-desc">Services Related options</div>
                                    </div>
                                </div>
                                <div class="right-item" onclick="toggleRight(this)">
                                    <input type="checkbox" id="FilterClinic" name="rights[]" value="FilterClinic" />
                                    <div>
                                        <label for="FilterClinic">FilterClinic</label>
                                        <div class="field-desc">Clinic Related options</div>
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
                </form>
            </div>

<%--            <div class="companies-list">
                <h3>Saved Companies</h3>
                <div id="companies-container">
                    <p style="color: #718096; text-align: center; padding: 20px;">No companies configured yet. Create your first company above.</p>
                </div>
            </div>--%>
        </div>
    </div>
     <%--<div class="col-lg-4 col-md-6 col-sm-8 company-section">
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
        </div>--%>
</asp:Content>
