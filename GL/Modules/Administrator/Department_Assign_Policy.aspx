<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Department_Assign_Policy.aspx.cs" Inherits="PMS.Modules.Administrator.Department_Assign_Policy" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">

        $(document).ready(function () {
            fillDepartment();
            let depID = '<%= Request.QueryString["Dep_ID"] %>';

            fillPolicy(function () {
                bindEvents();
                DepartmentPercentageValidation();

                if (depID && depID !== "null" && depID !== "") {
                    loadDepartmentEdit(depID);
                    $("#btnSave").val("Update");
                } else {
                    addRow();
                    $("#btnSave").val("Save");
                }
            });
        });


        var departmentOptions = "";
        var policyOptions = "";

        function fillDepartment() {
            $.ajax({
                type: "POST",
                url: "Department_Assign_Policy.aspx/GetAllDepartments",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = response.d;
                    departmentOptions = '<option value="0">Please Select</option>';
                    $.each(data, function (key, value) {
                        departmentOptions += '<option value="' + value.Department_ID + '">' + value.Department_Name + '</option>';
                    });
                    $("#ddlDepartment").html(departmentOptions).select2();
                    // addRow();
                },
                error: function (xhr, status, error) {
                    console.error("Failed to load departments: ", error);
                    $("#ddlDepartment").html('<option value="0">Load Error</option>');
                    addRow();
                }
            });
        }

        function loadDepartmentEdit(depId) {
            $.ajax({
                type: "POST",
                url: "Department_Assign_Policy.aspx/GetDepartmentAssignments",
                data: JSON.stringify({ dep_id: depId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    const data = JSON.parse(response.d);
                    $("#policyTable tbody").empty();

                    $.each(data, function (index, d) {
                        const row = $(createRow());

                        $("#policyTable tbody").append(row);

                        row.data('id', d.Dep_ID);
                        row.find('[name="Fees"]').val(d.Fees);
                        row.find('[name="Hospital_Share"]').val(d.Hospital_Share);
                        row.find('[name="Doctor_Share"]').val(d.Doctor_Share);
                        row.find('[name="Expiry_Date"]').val(d.Expiry_Date);
                        row.find('[name="Active"]').prop("checked", d.IsActive);

                        row.find('[name="Department"]').select2({ width: '100%' });
                        row.find('[name="Policy_ID"]').select2({ width: '100%' });

                        setTimeout(() => {
                            row.find('[name="Department"]').val(d.Department_ID).trigger('change');
                            row.find('[name="Policy_ID"]').val(d.Policy_ID).trigger('change');
                        }, 200);

                        row.find('.expiryDate').datepicker({ dateFormat: 'dd M yy', minDate: 0 });
                    });
                }
            });
        }






        function fillPolicy(callback) {
            $.ajax({
                type: "POST",
                url: "Department_Assign_Policy.aspx/GetAllPolicies",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = response.d;
                    policyOptions = '<option value="0">Please Select</option>';
                    $.each(data, function (key, value) {
                        policyOptions += '<option value="' + value.Policy_ID + '">' + value.Policy_Name + '</option>';
                    });
                    if (callback) callback();
                },
                error: function (xhr, status, error) {
                    console.error("Failed to load policies: ", error);
                }
            });
        }




        function DepartmentPercentageValidation() {
            $("#policyTable").on("input", '[name="Hospital_Share"], [name="Doctor_Share"]', function () {
                let row = $(this).closest("tr");
                let hospital = Number(row.find('[name="Hospital_Share"]').val()) || 0;
                let doctor = Number(row.find('[name="Doctor_Share"]').val()) || 0;

                if (hospital + doctor !== 100) {
                    row.find('[name="Hospital_Share"], [name="Doctor_Share"]')
                        .attr("data-invalid-share", "true")
                        .css("border", "2px solid red");
                } else {
                    row.find('[name="Hospital_Share"], [name="Doctor_Share"]')
                        .removeAttr("data-invalid-share")
                        .css("border", "");
                }
            });
        }

        function createRow() {
            return `
    <tr>
        <td>
            <select name="Department" class="form-select department-select">
                ${departmentOptions || '<option>Loading...</option>'}
            </select>
        </td>
        <td>
            <select name="Policy_ID" class="form-select policy-select">
                ${policyOptions || '<option>Loading...</option>'}
            </select>
        </td>
        <td><input type="text" name="Fees" class="form-control" placeholder="Enter Fees"></td>
        <td><input type="text" name="Hospital_Share" class="form-control" placeholder="Hospital %"></td>
        <td><input type="text" name="Doctor_Share" class="form-control" placeholder="Doctor %"></td>
        <td><input type="text" name="Expiry_Date" class="form-control expiryDate" placeholder="Select Date" readonly></td>
        <td><input type="checkbox" name="Active"></td>
        <td>
            <i class="fa fa-trash text-danger btnDeleteRow" 
               style="cursor:pointer; font-size:18px;" 
               title="Delete Row"></i>
        </td>
    </tr>`;
        }

        function addRow() {
            if (!policyOptions) {
                setTimeout(addRow, 200);
                return;
            }

            var $row = $(createRow());
            $("#policyTable tbody").append($row);
            $row.find(".department-select").select2();
            $row.find(".policy-select").select2();

            $(".expiryDate").datepicker({
                dateFormat: 'dd M yy',
                changeMonth: true,
                changeYear: true,
                minDate: 0
            });
        }


        function deleteRow() {
            var $tableBody = $("#policyTable tbody");
            var rowCount = $tableBody.children("tr").length;

            if (rowCount <= 1) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Hold on!',
                    text: 'You must have at least one policy row.',
                    showConfirmButton: true,
                    confirmButtonText: 'OK',
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                return;
            }

            $(this).closest("tr").remove();
        }

        function collectPolicies() {
            let data = [];
            $("#policyTable tbody tr").each(function () {
                let dept = $(this).find('[name="Department"] option:selected');
                let policy = $(this).find('[name="Policy_ID"] option:selected');
                data.push({
                    Dep_ID: $(this).data("id") || 0,
                    Department_ID: dept.val(),
                    Department_Name: dept.text(),
                    Policy_ID: policy.val(),
                    Policy_Name: policy.text(),
                    Fees: $(this).find('[name="Fees"]').val(),
                    Hospital_Share: $(this).find('[name="Hospital_Share"]').val(),
                    Doctor_Share: $(this).find('[name="Doctor_Share"]').val(),
                    Expiry_Date: $(this).find('[name="Expiry_Date"]').val(),
                    IsActive: $(this).find('[name="Active"]').prop("checked")
                });
            });
            return data;
        }

        function savePolicies() {
            let data = collectPolicies();
            if (data.length === 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please add at least one policy.',
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

            if ($('[name="Hospital_Share"][data-invalid-share="true"], [name="Doctor_Share"][data-invalid-share="true"]').length > 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Hospital and Doctor share must total 100%',
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

            let invalidExpiry = false;
            $('#policyTable tbody tr').each(function () {
                const expiryDate = $(this).find('[name="Expiry_Date"]').val();
                if (!expiryDate) {
                    invalidExpiry = true;
                    $(this).find('[name="Expiry_Date"]').css("border", "2px solid red");
                } else {
                    $(this).find('[name="Expiry_Date"]').css("border", "");
                }
            });

            if (invalidExpiry) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Expiry Date is required for all policies.',
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

            $.ajax({
                type: "POST",
                url: "Department_Assign_Policy.aspx/SaveMultipleDepartmentPolicies",
                data: JSON.stringify({ departmentPolicies: data }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function () {
                    Swal.fire({
                        icon: 'success',
                        title: 'Success!',
                        text: 'Data saved successfully.',
                        showConfirmButton: false,
                        timer: 2500,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                    window.location.reload();
                },
                error: function () {
                    Swal.fire("Error", "Failed to save.", "error");
                }
            });
        }

        function bindEvents() {
            $("#btnAddRow").on("click", addRow);
            $("#policyTable").on("click", ".btnDeleteRow", deleteRow);
            $("#btnSave").on("click", savePolicies);
        }


        


    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <input type="hidden" name="Dep_ID" value="0" />
    <div class="row">
        <div class="col-lg-1 col-md-4 col-sm-6">
            <input id="btnAddRow" type="button" class="btn btn-primry" value="+" />
        </div>
    </div>

    <table class="table table-hover table-striped table-bordered" id="policyTable">
        <thead class="table-primary">
            <tr>
                <th>Department</th>
                <th>Policy</th>
                <th>Fees</th>
                <th>Hospital Share</th>
                <th>Doctor Share</th>
                <th>Expiry Date</th>
                <th>Active</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody></tbody>
    </table>
    <div class="row">
        <div class="col-lg-8">
            <div class="row">
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input id="btnSave" type="button" class="btn btn-primry" value="Save Data" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-4">
                    <input type="button" class="btn btn-primry" id="View" value="View" onclick="window.location = 'Department_Assign_View.aspx'" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-4">
                    <input type="button" class="btn btn-yellow" id="btnNew" value="New" onclick="window.location = 'Department_Assign_Policy.aspx'" />
                </div>
            </div>
        </div>
    </div>

</asp:Content>
