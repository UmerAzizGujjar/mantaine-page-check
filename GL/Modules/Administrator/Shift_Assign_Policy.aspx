<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Shift_Assign_Policy.aspx.cs" Inherits="PMS.Modules.Administrator.Shift_Assign_Policy" %>
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
        $(document).on('keyup', 'input[name="Discount_Percentage"]', function () {
            let $row = $(this).closest('tr');

            let fees = parseFloat($row.find('input[name="Fees"]').val()) || 0;
            let discountPercentage = parseFloat($(this).val()) || 0;

            let discountAmount = (fees * discountPercentage) / 100;

            $row.find('input[name="Discount_Amount"]').val(discountAmount.toFixed(2));
        });

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

            $(document).on('change', '[name="Start_Time"], [name="End_Time"], [name="Next_Day"]', function () {
                validateTimeRange($(this).closest('tr'));
            });

            $(document).on('change', '[name="IsTime"]', function () {
                const $row = $(this).closest('tr');
                const isChecked = $(this).is(':checked');

                $row.find('[name="Start_Time"]').prop('disabled', !isChecked);
                $row.find('[name="End_Time"]').prop('disabled', !isChecked);
                $row.find('[name="Extra_Time"]').prop('disabled', !isChecked);

            });
            $(document).on('change', '[name="IsDay"]', function () {
                const $row = $(this).closest('tr');
                const isChecked = $(this).is(':checked');

                $row.find('[name="St_Day"]').prop('disabled', !isChecked);
                $row.find('[name="En_Day"]').prop('disabled', !isChecked);


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
                        newRow.find('[name="Fees"]').val(policy.Fees);
                        newRow.find('[name="Hospital_Share"]').val(policy.Hospital_Share);
                        newRow.find('[name="Discount_Amount"]').val(policy.Discount_Amount);
                        newRow.find('[name="Discount_Percentage"]').val(policy.Discount_Percentage); 

                        newRow.find('[name="Doctor_Share"]').val(policy.Doctor_Share);
                        newRow.find('[name="Expiry_Date"]').val(policy.Expiry_Date);

                        newRow.find('[name="IsTime"]').prop("checked", policy.IsTime);
                        newRow.find('[name="Start_Time"], [name="End_Time"]')
                            .prop("disabled", !policy.IsTime); // Clean and simple


                        newRow.find('[name="IsDay"]').prop("checked", policy.Day_Check);
                        newRow.find('[name="St_Day"], [name="En_Day"]')
                            .prop("disabled", !policy.Day_Check); // Clean and simple

                        newRow.find('[name="Start_Time"]').val(policy.Start_Time);
                        newRow.find('[name="End_Time"]').val(policy.End_Time);
                        newRow.find('[name="Next_Day"]').prop("checked", policy.Next_Day);
                        newRow.find('[name="Extra_Time"]').val(policy.Extra_Time ?? 0);
                        newRow.find('[name="Extra_Time"]').prop("disabled", !policy.IsTime);

                        newRow.find('[name="St_Day"]').val(policy.St_Day);
                        newRow.find('[name="En_Day"]').val(policy.En_Day);

                        newRow.find('.expiryDate').datepicker({
                            dateFormat: 'dd M yy',
                            changeMonth: true,
                            changeYear: true,
                            minDate: 0
                        });

                        const $select = newRow.find('[name="Policy_ID"]');
                        $select.select2({
                            placeholder: "Select Policy",
                            allowClear: true,
                            width: '100%',
                            dropdownParent: $(document.body)
                        });

                        if (!$select.find('option[value="' + policy.Policy_ID + '"]').length) {
                            const option = new Option(policy.Policy_Name, policy.Policy_ID, true, true);
                            $select.append(option).trigger('change');
                        } else {
                            $select.val(policy.Policy_ID).trigger('change');
                        }
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
            const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
            const dayOptions = days.map(day => `<option value="${day}">${day}</option>`).join('');

            return `
    <tr>
        <td>
            <select name="Policy_ID" class="form-select select2-policy">
                ${policyOptions || '<option value="">Loading...</option>'}
            </select>
        </td>
        <td><input type="text" name="Fees" class="form-control" placeholder="Fees"></td>
        <td><input type="text" name="Discount_Percentage" class="form-control" placeholder="Discount %"></td>
        <td style="display:none;"><input type="hidden" name="Discount_Amount" class="form-control"></td>
        <td><input type="number" name="Hospital_Share" class="form-control" placeholder="Hospital %" min="0" max="100"></td>
        <td><input type="number" name="Doctor_Share" class="form-control" placeholder="Doctor %" min="0" max="100"></td>
        <td><input type="text" name="Expiry_Date" class="form-control expiryDate" placeholder="Select Date" readonly></td>
         <td><input type="checkbox" name="IsDay" class="isDayCheck"></td>
                <td>
            <div style="display: flex; align-items: center; gap: 8px; flex-wrap: nowrap;">
                <span>From</span>
                <select name="St_Day" disabled class="form-control form-select" style="width: auto; min-width: 70px; flex: none;">
                    <option value="">Select</option>
                    ${dayOptions}
                </select>
                <span>To</span>               
                <select name="En_Day" disabled class="form-control form-select" style="width: auto; min-width: 70px; flex: none;">
                    <option value="">Select</option>
                    ${dayOptions}
                </select>
            </div>
        </td>
        <td><input type="checkbox" name="IsTime" class="isTimeCheck"></td>
        <td><input type="time" name="Start_Time" class="form-control" disabled></td>
        <td><input type="checkbox" name="Next_Day"></td>
        <td><input type="time" name="End_Time" class="form-control" disabled></td>
        <td><input type="number" name="Extra_Time" class="form-control" placeholder="0" min="0" value="0" disabled></td>
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
                    icon: 'error',
                    title: 'Error!',
                    text: 'At least one row required',
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
                    Discount_Percentage: $row.find('[name="Discount_Percentage"]').val().trim(),
                    Discount_Amount: $row.find('[name="Discount_Amount"]').val().trim(),
                    Hospital_Share: $row.find('[name="Hospital_Share"]').val().trim(),
                    Doctor_Share: $row.find('[name="Doctor_Share"]').val().trim(),
                    Expiry_Date: $row.find('[name="Expiry_Date"]').val(),
                    IsTime: $row.find('[name="IsTime"]').is(":checked"),
                    IsDay: $row.find('[name="IsDay"]').is(":checked"),
                    Start_Time: $row.find('[name="Start_Time"]').val(),
                    End_Time: $row.find('[name="End_Time"]').val(),
                    St_Day: $row.find('[name="St_Day"]').val(),  
                    En_Day: $row.find('[name="En_Day"]').val(),
                    Next_Day: $row.find('[name="Next_Day"]').is(":checked"),
                    Extra_Time: parseInt($row.find('[name="Extra_Time"]').val()) || 0
                });
            });

            return policies;
        }

        function validateTimeRange($row) {
            const startTime = $row.find('[name="Start_Time"]').val();
            const endTime = $row.find('[name="End_Time"]').val();
            const isNextDay = $row.find('[name="Next_Day"]').is(":checked");

            if (startTime && endTime) {
                const start = new Date(`1970-01-01T${startTime}:00`);
                const end = new Date(`1970-01-01T${endTime}:00`);

                if (start > end && !isNextDay) {
                    $row.addClass("invalid-time");
                    $row.find('[name="Start_Time"], [name="End_Time"], [name="Next_Day"]').css("border", "2px solid red");
                } else {
                    $row.removeClass("invalid-time");
                    $row.find('[name="Start_Time"], [name="End_Time"], [name="Next_Day"]').css("border", "");
                }
            } else {
                $row.removeClass("invalid-time");
                $row.find('[name="Start_Time"], [name="End_Time"], [name="Next_Day"]').css("border", "");
            }
        }




        function savePolicies() {
            let hasInvalidExpiry = false;
            let hasInvalidTimeFields = false;

            $("#policyTable tbody tr").each(function () {
                validateShare($(this));
                validateTimeRange($(this));

                const $row = $(this);
                const expiryDate = $row.find('[name="Expiry_Date"]').val();

                // Expiry date validation
                if (!expiryDate) {
                    $row.addClass("invalid-expiry");
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Expiry Date is Required for all Policies',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                    hasInvalidExpiry = true;
                    return false; 
                } else {
                    $row.removeClass("invalid-expiry");
                    $row.find('[name="Expiry_Date"]').css("border", "");
                }

                if ($row.find('[name="IsTime"]').is(":checked")) {
                    const startTime = $row.find('[name="Start_Time"]').val();
                    const endTime = $row.find('[name="End_Time"]').val();

                    if (!startTime || !endTime) {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Start Time and End Time are required when "Is Time" is checked.',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                        hasInvalidTimeFields = true;
                        return false; 
                    }
                }
                if ($row.find('[name="IsDay"]').is(":checked")) {
                    const startday = $row.find('[name="St_Day"]').val();
                    const endday = $row.find('[name="En_Day"]').val();

                    if (!startday || !endday) {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Start Day and End Day are required when "Is Day" is checked.',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                        hasInvalidTimeFields = true;
                        return false;
                    }
                }
            });

            if ($("#policyTable tbody tr.invalid-share").length > 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Each row must have Hospital + Doctor Share = 100%',
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


            if (hasInvalidExpiry || hasInvalidTimeFields) {
                return;
            }

            

            if ($("#policyTable tbody tr.invalid-time").length > 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Start Time must be greater than End Time',
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

            const policies = collectPolicies();
            if (policies.length === 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Add Policy',
                    showConfirmButton: false,
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
                .done(function () {
                    Swal.fire({
                        icon: 'success',
                        title: 'Success!',
                        text: 'All policies saved successfully.',
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
                <th>Discount_Percentage</th>
                <th style ="display:none">Fees</th>
                <th>Hospital Share</th>
                <th>Doctor Share</th>
                <th>Expiry Date</th>
                <th>Day Check</th>
                 <th>Day Range</th>
                <th>Time Check</th>
                <th>Start Time</th>              
                <th>Next Day</th>
                <th>End Time</th>
                <th>Extra Time (min)</th>
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
                <div class="col-lg-2 col-md-4 col-sm-4">
                    <input type="button" class="btn btn-yellow" id="btnNew" value="New" onclick="window.location = 'Shift_Assign_Policy.aspx'" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>
