<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Shift_Assign_Policy.aspx.cs" Inherits="PMS.Modules.Administrator.Shift_Assign_Policy" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
  <script type="text/javascript">

      $(document).ready(function () {
          initPercentageValidation();
      });


      function loadPolicyDropdowns() {
          $.ajax({
              type: "POST",
              url: "Shift_Assign_Policy.aspx/GetAllPolicies",
              data: '{}',
              contentType: "application/json; charset=utf-8",
              dataType: "json",
              success: function (response) {
                  var policies = response.d;
                  var options = '<option value="">Select</option>';

                  $.each(policies, function (index, policy) {
                      options += `<option value="${policy.Policy_ID}">${policy.Policy_Name}</option>`;
                  });

                  window.policyOptions = options;
                  populateDropdowns();
              }
          });
      }

      function initPercentageValidation() {
          $("#policyTable").on("input", '[name="Hospital_Share"], [name="Doctor_Share"]', function () {
              let row = $(this).closest("tr");
              let hospital = Number(row.find('[name="Hospital_Share"]').val()) || 0;
              let doctor = Number(row.find('[name="Doctor_Share"]').val()) || 0;

              if (hospital + doctor !== 100) {
                  row.addClass("invalid-share");
                  row.find('[name="Hospital_Share"], [name="Doctor_Share"]').css("border", "2px solid red");
              } else {
                  row.removeClass("invalid-share");
                  row.find('[name="Hospital_Share"], [name="Doctor_Share"]').css("border", "");
              }
          });
      }


      function populateDropdowns() {
          $(".policyName").each(function () {
              $(this).html(window.policyOptions);
          });
      }

      function createRow() {
          return `
    <tr>
        <td>
            <select name="Policy_ID" class="form-select">
                ${window.policyOptions || '<option value="">Loading...</option>'}
            </select>
        </td>
        <td><input type="text" name="Fees" class="form-control" placeholder="En"></td>
        <td><input type="text" name="Hospital_Share" class="form-control" placeholder="Hospital"></td>
        <td><input type="text" name="Doctor_Share" class="form-control" placeholder="Doctor"></td>
        <td><input type="text" name="Expiry_Date" class="form-control" placeholder="Select Date" readonly></td>
        <td><input type="checkbox" name="IsTime"></td>
        <td><input type="time" name="Start_Time" class="form-control"></td>
        <td><input type="checkbox" name="Next_Day"></td>
        <td><input type="time" name="End_Time" class="form-control"></td>
        <td>
            <i class="fa fa-trash text-danger btnDeleteRow" 
               style="cursor:pointer; font-size:18px;" 
               title="Delete Row"></i>
        </td>
    </tr>`;
      }


      function attachDatepickers() {
          $(".expiryDate").datepicker({
              dateFormat: 'dd M yy',
              changeMonth: true,
              changeYear: true,
              minDate: 0 
          });
      }

      function addRow() {
          $("#policyTable tbody").append(createRow());
          attachDatepickers();
      }

      $(function () {
          attachDatepickers();
      });

      function deleteRow() {
          $(this).closest("tr").remove();
      }

      function collectPolicies() {
          let policies = [];
          $("#policyTable tbody tr").each(function () {
              let selectedPolicy = $(this).find('[name="Policy_ID"] option:selected');
              policies.push({
                  Policy_ID: selectedPolicy.val(),
                  Policy_Name: selectedPolicy.text(),
                  Fees: $(this).find('[name="Fees"]').val(),
                  Hospital_Share: $(this).find('[name="Hospital_Share"]').val(),
                  Doctor_Share: $(this).find('[name="Doctor_Share"]').val(),
                  Expiry_Date: $(this).find('[name="Expiry_Date"]').val(),
                  IsTime: $(this).find('[name="IsTime"]').is(":checked"),
                  Start_Time: $(this).find('[name="Start_Time"]').val(),
                  End_Time: $(this).find('[name="End_Time"]').val(),
                  Next_Day: $(this).find('[name="Next_Day"]').is(":checked")
              });
          });
          return policies;
      }

      function attachDatepickers() {
          $('[name="Expiry_Date"]').datepicker({
              dateFormat: 'dd M yy',
              changeMonth: true,
              changeYear: true,
              minDate: 0
          });
      }

      function savePolicies() {
          let policies = collectPolicies();

          if ($("#policyTable tbody tr.invalid-share").length > 0) {
              Swal.fire({
                  icon: 'error',
                  title: 'Error!',
                  text: 'Hospital + Doctor Share must equal 100%',
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

          if (policies.length === 0) {
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

          $.ajax({
              type: "POST",
              url: "Shift_Assign_Policy.aspx/SaveMultiplePolicies",
              data: JSON.stringify({ policies }),
              contentType: "application/json; charset=utf-8",
              dataType: "json",
              success: function (response) {
                  Swal.fire({
                      icon: 'success',
                      title: 'Success!',
                      text: 'Data Saved successfully.',
                      showConfirmButton: false,
                      timer: 2500,
                      customClass: {
                          popup: 'swal-big-popup',
                          title: 'swal-big-title',
                          htmlContainer: 'swal-big-text'
                      }
                  });
              },
              error: function (xhr, status, error) {
                  Swal.fire({
                      icon: 'error',
                      title: 'Error',
                      text: error
                  });
              }
          });
      }

      function bindEvents() {
          $("#btnAddRow").on("click", addRow);
          $("#policyTable").on("click", ".btnDeleteRow", deleteRow);
          $("#btnSave").on("click", savePolicies);
      }

      function initPolicyModule() {
          loadPolicyDropdowns();
          bindEvents();
      }

      window.addEventListener('DOMContentLoaded', initPolicyModule);
  </script>


</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
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
            </div>
        </div>
    </div>
</asp:Content>
