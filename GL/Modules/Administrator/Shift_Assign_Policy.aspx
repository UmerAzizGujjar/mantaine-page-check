<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Shift_Assign_Policy.aspx.cs" Inherits="PMS.Modules.Administrator.Shift_Assign_Policy" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
<script type="text/javascript">
    $(document).ready(function () {

        let PolicyID = '<%= Request.QueryString["Policy_ID"] %>';

        if (PolicyID && PolicyID !== "null" && PolicyID !== "") {
            loadPolicyEdit(PolicyID);
            $("#btnSave").val("Update");
        } else {
            $("#btnSave").val("Save");
        }


        let policyOptions = '<option value="">Select</option>';

        initPolicyModule();

        function initPolicyModule() {
            loadPolicy();
            bindEvents();
        }

        $('#btnView').click(function () {
            window.location.href = 'Shift__Policy_View.aspx';
        });

        function bindEvents() {
            $(document).on('click', '#btnAddRow', addRow);
            $(document).on('click', '.btnDeleteRow', deleteRow);
            $(document).on('click', '#btnSave', savePolicies);

            $(document).on('input', '[name="Hospital_Share"], [name="Doctor_Share"]', function () {
                validateShare($(this).closest('tr'));
            });
        }

        function loadPolicy() {
            $.ajax({
                type: "POST",
                url: "Shift_Assign_Policy.aspx/GetAllPolicies",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json"
            })
                .done(function (response) {
                    const policies = response.d || [];
                    policyOptions = '<option value="">Select</option>';

                    $.each(policies, function (index, policy) {
                        policyOptions += `<option value="${policy.Policy_ID}">${policy.Policy_Name}</option>`;
                    });

                    populateDropdowns();

                    if ($("#policyTable tbody tr").length === 0) {
                        addRow();
                    }
                })
                .fail(function (xhr, status, error) {
                    console.error("Failed to load policies:", error);
                    Swal.fire({
                        icon: 'error',
                        title: 'Load Failed',
                        text: 'Could not load policies. Please refresh the page.',
                        confirmButtonText: 'OK'
                    });
                });
        }

        function loadPolicyEdit(policyId) {
            $.ajax({
                type: "POST",
                url: "Shift_Assign_Policy.aspx/GetPolicies",
                data: JSON.stringify({ policy_id: policyId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    const policies = JSON.parse(response.d);
                    $("#policyTable tbody").empty();

                    $.each(policies, function (index, policy) {
                        const newRow = $(createRow());

                        $("#policyTable tbody").append(newRow);

                        newRow.data('id', policy.Policy_Detail_ID);
                        newRow.find('[name="Policy_Detail_ID"]').val(policy.Policy_Detail_ID);
                        newRow.find('[name="Policy_ID"]').val(policy.Policy_ID);
                        newRow.find('[name="Fees"]').val(policy.Fees);
                        newRow.find('[name="Hospital_Share"]').val(policy.Hospital_Share);
                        newRow.find('[name="Doctor_Share"]').val(policy.Doctor_Share);
                        newRow.find('[name="Expiry_Date"]').val(policy.Expiry_Date);
                        newRow.find('[name="IsTime"]').prop("checked", policy.IsTime);
                        newRow.find('[name="Start_Time"]').val(policy.Start_Time);
                        newRow.find('[name="End_Time"]').val(policy.End_Time);
                        newRow.find('[name="Next_Day"]').prop("checked", policy.Next_Day);

                        newRow.find('.expiryDate').datepicker({
                            dateFormat: 'dd M yy',
                            changeMonth: true,
                            changeYear: true,
                            minDate: 0
                        });
                        setTimeout(() => {
                            newRow.find('.select2-policy').select2({
                                placeholder: "Select Policy",
                                allowClear: true,
                                width: '100%'
                            });
                            newRow.find('.select2-policy').val(policy.Policy_ID).trigger('change');
                        }, 200); 
                    });
                },
                error: function (xhr, status, error) {
                    console.error("Error loading policies for edit:", error);
                    Swal.fire({
                        icon: 'error',
                        title: 'Load Error',
                        text: 'Could not load policy details for editing.',
                        confirmButtonText: 'OK'
                    });
                }
            });
        }



        function populateDropdowns() {
            $('.policyName, [name="Policy_ID"]').each(function () {
                const selected = $(this).val();
                $(this).html(policyOptions);
                if (selected) {
                    $(this).val(selected).trigger('change'); 
                }
            });

            $('.select2-policy').select2({
                placeholder: "Select Policy",
                allowClear: true,
                width: '100%'
            });
        }

        function createRow() {
            return `
                <tr>
                    <td>
                        <select name="Policy_ID" class="form-select select2-policy">
                            ${policyOptions || '<option value="">Loading...</option>'}
                        </select>
                    </td>
                    <td><input type="text" name="Fees" class="form-control" placeholder="Fees"></td>
                    <td><input type="number" name="Hospital_Share" class="form-control" placeholder="Hospital %" min="0" max="100"></td>
                    <td><input type="number" name="Doctor_Share" class="form-control" placeholder="Doctor %" min="0" max="100"></td>
                    <td><input type="text" name="Expiry_Date" class="form-control expiryDate" placeholder="Select Date" readonly></td>
                    <td><input type="checkbox" name="IsTime"></td>
                    <td><input type="time" name="Start_Time" class="form-control"></td>
                    <td><input type="checkbox" name="Next_Day"></td>
                    <td><input type="time" name="End_Time" class="form-control"></td>
                    <td>
                        <i class="fa fa-trash text-danger btnDeleteRow" style="cursor:pointer; font-size:18px;" title="Delete Row"></i>
                    </td>
                </tr>`;
        }

        function addRow() {
            const newRow = $(createRow());
            $("#policyTable tbody").append(newRow);

            newRow.find('.expiryDate').datepicker({
                dateFormat: 'dd M yy',
                changeMonth: true,
                changeYear: true,
                minDate: 0
            });

            newRow.find('.select2-policy').select2({
                placeholder: "Select Policy",
                allowClear: true,
                width: '100%'
            });
        }

        function deleteRow() {
            if ($("#policyTable tbody tr").length > 1) {
                $(this).closest("tr").remove();
            } else {
                Swal.fire({
                    icon: 'warning',
                    title: 'At least one row required',
                    text: 'You cannot delete the last row.',
                    timer: 2000,
                    showConfirmButton: false
                });
            }
        }

        function validateShare($row) {
            const hospital = parseFloat($row.find('[name="Hospital_Share"]').val()) || 0;
            const doctor = parseFloat($row.find('[name="Doctor_Share"]').val()) || 0;
            const total = hospital + doctor;

            if (total !== 100) {
                $row.addClass("invalid-share");
                $row.find('[name="Hospital_Share"], [name="Doctor_Share"]')
                    .css("border", "2px solid red");
            } else {
                $row.removeClass("invalid-share");
                $row.find('[name="Hospital_Share"], [name="Doctor_Share"]')
                    .css("border", "");
            }
        }

        function collectPolicies() {
            const policies = [];

            $("#policyTable tbody tr").each(function () {
                const $row = $(this);
                const $policySelect = $row.find('[name="Policy_ID"]');
                const policyId = $policySelect.val();

                if (!policyId) return true;

                policies.push({
                    Policy_Detail_ID: $row.data('id') || 0,
                    Policy_ID: policyId,
                    Policy_Name: $policySelect.find('option:selected').text(),
                    Fees: $row.find('[name="Fees"]').val().trim(),
                    Hospital_Share: $row.find('[name="Hospital_Share"]').val().trim(),
                    Doctor_Share: $row.find('[name="Doctor_Share"]').val().trim(),
                    Expiry_Date: $row.find('[name="Expiry_Date"]').val(),
                    IsTime: $row.find('[name="IsTime"]').is(":checked"),
                    Start_Time: $row.find('[name="Start_Time"]').val(),
                    End_Time: $row.find('[name="End_Time"]').val(),
                    Next_Day: $row.find('[name="Next_Day"]').is(":checked")
                });
            });

            return policies;
        }


        function savePolicies() {
            $("#policyTable tbody tr").each(function () {
                validateShare($(this));
            });

            if ($("#policyTable tbody tr.invalid-share").length > 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Validation Error',
                    text: 'Each row must have Hospital + Doctor Share = 100%',
                    timer: 2500,
                    showConfirmButton: true
                });
                return;
            }

            const policies = collectPolicies();

            if (policies.length === 0) {
                Swal.fire({
                    icon: 'warning',
                    title: 'No Data',
                    text: 'Please add at least one valid policy.',
                    timer: 2000
                });
                return;
            }

            $.ajax({
                type: "POST",
                url: "Shift_Assign_Policy.aspx/SaveMultiplePolicies",
                data: JSON.stringify({ policies: policies }),
                contentType: "application/json; charset=utf-8",
                dataType: "json"
            })
                .done(function (response) {
                    Swal.fire({
                        icon: 'success',
                        title: 'Saved!',
                        text: 'All policies saved successfully.',
                        timer: 2500,
                        showConfirmButton: false
                    }).then(() => {
                    });
                })
                .fail(function (xhr, status, error) {
                    let errorMsg = error;
                    if (xhr.responseJSON && xhr.responseJSON.message) {
                        errorMsg = xhr.responseJSON.message;
                    }

                    Swal.fire({
                        icon: 'error',
                        title: 'Save Failed',
                        text: `Error: ${errorMsg}`,
                        confirmButtonText: 'Retry'
                    });
                });
        }
    });
</script>


</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <input type="hidden" name="Policy_Detail_ID" value="0" />
    <div class="row">
        <div class="col-lg-1 col-md-4 col-sm-6">
            <input id="btnAddRow" type="button" class="btn btn-primry" value="+" />
        </div>
    </div>
    <table class="table table-hover table-striped table-bordered" id="policyTable">
        <thead class="table-primary">
            <tr>
                <th>Policy Name</th>
                <th>Fees</th>
                <th>Hospital Share</th>
                <th>Doctor Share</th>
                <th>Expiry Date</th>
                <th>Time Check</th>
                <th>Start Time</th>
                <th>Next Day</th>
                <th>End Time</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody></tbody>
    </table>
    <div class="row">
        <div class="col-lg-8">
            <div class="row">
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input id="btnSave" type="button" class="btn btn-primry" value="Save Policies" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input id="btnView" type="button" class="btn btn-primry" value="View" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>
