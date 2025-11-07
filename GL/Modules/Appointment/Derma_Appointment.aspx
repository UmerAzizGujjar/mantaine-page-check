<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Derma_Appointment.aspx.cs" Inherits="PMS.Modules.Appointment.Derma_Appointment" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
  <script type="text/javascript">
      $(document).ready(function () {
          $("#PatientsSearchModel").modal('show');

          var App_ids = '<%= Request.QueryString["APPID"]%>';
            if (App_ids != "") {
                $("#PatientsSearchModel").modal('hide');
            }

            jQuery(function ($) {
                MaskedInput({
                    elm: document.getElementById('txtSearch'),
                    format: '+92__________',
                    separator: '-'
                });
                var phoneInput = document.getElementById('txtSearch');
                var cursorPosition = 3;
                phoneInput.setSelectionRange(cursorPosition, cursorPosition);
            });

            FillPatientsList();
        });

      function fillDropdown($dropdown, methodName) {
          if ($dropdown.data('filled')) return;
          $dropdown.data('filled', false);
          $.ajax({
              type: "POST",
              url: "Derma_Appointment.aspx/" + methodName,
              data: '{}',
              contentType: "application/json; charset=utf-8",
              dataType: "json",
              success: function (response) {
                  try {
                      const data = JSON.parse(response.d);
                      var options = '<option value="">Please Select</option>';
                      $.each(data, function (key, value) {
                          options += `<option value="${value.DataValue_Name}">
                                    ${value.DataValue_Description}
                                </option>`;
                      });
                      $dropdown.html(options)
                          .data('filled', true)
                          .trigger('change');
                      if ($dropdown.hasClass('select2-hidden-accessible')) {
                          $dropdown.select2('close').select2('open');
                      }
                  } catch (e) {
                      console.error(`Error parsing data from ${methodName}:`, e);
                      $dropdown.data('filled', false);
                  }
              },
              error: function (xhr, status, error) {
                  console.error(`Error fetching ${methodName}:`, error);
                  $dropdown.data('filled', false);
              }
          });
      }

      function initializePatientModalDropdowns() {
          var dropdowns = [
              { id: '#ddl_Gender', method: 'GetGender' },
              { id: '#ddl_status', method: 'GetMartailStatus' },
              { id: '#ddlCountry', method: 'GetCountry' },       
              { id: '#ddl_Province', method: 'GetProvince' },    
              { id: '#txtcity', method: 'GetCity' },
              { id: '#txtarea', method: 'GetArea' }
          ];

          dropdowns.forEach(item => {
              const $element = $(item.id);
              $element.select2();
              $element.on('select2:open', function () {
                  fillDropdown($element, item.method);
              });
          });

          MaskedInput({
              elm: document.getElementById('txt_cnic'),
              format: '_____-_______-_',
              separator: '-'
          });
      }

      function CalculateDateOfBirth() {
          debugger;
          var now = moment();
          var year = $('#txt_dob').val();
          var calculateDate = now.subtract(year, 'years');
          var finalDate = calculateDate.format("DD/MM/YYYY");
          var $datepicker = $('#txtAge_yearss');

          $datepicker.datepicker({
              changeMonth: true,
              changeYear: true,
              yearRange: "-50:+50",
              dateFormat: "dd/mm/yy"
          });

          $('#txtAge_yearss').unmask("99/99/9999");
          $datepicker.datepicker('setDate', finalDate);
          $('#txtAge_yearss').unmask("99/99/9999");
          $("#txtAge_yearss").mask("99/99/9999");
      }


      function FillPatientsList() {
          $('#tblPatientsResult tbody').empty();
          var SearchString = '';
          PageMethods.SearchPatients(SearchString, OnFilterPatients, OnFailPatients);
      }

      function OnFilterPatients(data) {
          ClearPatientResults();
          for (var i = 0; i < data.length; i++) {
              AddPatientsResult(data[i].Reg_Patient_ID, data[i].Patient_No, data[i].Full_Name, data[i].NIC, data[i].Mobile1, data[i].Father_Name);
          }
      }

      function OnFailPatients(exc) {
          alert(exc.get_message());
      }

      function AddPatientsResult(Reg_Patient_ID, Patient_No, Full_Name, NIC, Mobile1, Father_Name) {
          var row = iPatientsBody.insertRow(-1);
          var cell;

          cell = row.insertCell(-1);
          cell.innerHTML = '<span>' + Reg_Patient_ID + '</span>';
          cell.className = "hide";

          cell = row.insertCell(-1);
          cell.innerHTML = '<span class="HRcontent">' + Patient_No + '</span>';

          cell = row.insertCell(-1);
          cell.innerHTML = '<span class="HRcontent">' + Full_Name + '</span>';

          cell = row.insertCell(-1);
          cell.innerHTML = '<span class="HRcontent">' + Father_Name + '</span>';

          cell = row.insertCell(-1);
          cell.innerHTML = '<span class="HRcontent">' + NIC + '</span>';

          cell = row.insertCell(-1);
          cell.innerHTML = '<span class="HRcontent">' + Mobile1 + '</span>';

          cell = row.insertCell(-1);
          var actions = '<a class="tooltips" href="#" onclick="AddPatientDetail(' + Reg_Patient_ID + ')"><i class="fa fa-plus-circle"></i><span class="tooltiptxt">Add</span></a>';
          cell.innerHTML = actions;
      }

      function ClearPatientResults() {
          while (tblPatientsResult.rows.length > 1) {
              tblPatientsResult.deleteRow(1);
          }
      }

      var isAdd = false;
      function AddPatientDetail(Reg_Patient_ID) {
          try {
              isAdd = true;
              window.location.href = "Derma_Appointment.aspx?ID=" + Reg_Patient_ID + "&isAdd=" + isAdd;
          } catch (err) {
              alert(err.message);
          }
      }

      function addfunc() {
          debugger;
          var maskedValue = $('#txtSearch').val();
          var unmaskedValue = maskedValue.replace(/_/g, '');
          var Ph_sNOs = unmaskedValue.length;
          if (Ph_sNOs === 13) {
              $('#addNewbtn').attr("disabled", false);
              AddNewPatient();
          }
          else {
              Swal.fire({
                  icon: 'error',
                  title: 'Error!',
                  text: 'Please Enter Complete Mobile Number First',
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
          debugger;
          $('#patmodalClose').click();
          $('#PatientsSearchModel').hide();
          fillmrno();
          setTimeout(function () {
              $('#txt_mobile').val(unmaskedValue);
          }, 100);
          $('#txt_name').focus();
      }

      function fillmrno() {
          var data = {};
          $.ajax({
              type: "POST",
              url: "Derma_Appointment.aspx/Getmr",
              data: data,
              contentType: "application/json; charset=utf-8",
              dataType: "json",
              success: function (data) {
                  debugger;
                  var max_mr = data.d;
                  $('#txt_Mrnos').val(max_mr);
              },
              error: function (xhr, status, error) {
                  console.error("AJAX request failed:", status, error);
              }
          });
      }

      function AddNewPatient() {
          clearPatient();
          $('#hdfPatient_ID').val('(New)');
          $('#PatientModel').modal({
              backdrop: 'static'
          });
          $("#ddl_name").focus();
          initializePatientModalDropdowns();
          MaskedInput({
              elm: document.getElementById('txt_cnic'),
              format: '_____-_______-_',
              separator: '-'
          });
      }

      function clearPatient() {
          $('#txt_name').val("");
          $('#txt_relation').val("");
          $('#txt_mobile').val("");
          $('#txt_dob').val("");
          $('#txt_cnic').val("");
          $('#txt_Address').val('');
          $('#updatePatient_Data').hide();
          $('#RevistPat').hide();
      }

      function SavePatient() {
          debugger;
          $('#SavePatient_Data').attr('disabled', true);
          var Prefix_PatientName = $('#ddl_name').val();
          var PatientName = $('#txt_name').val();
          var PatientID = $('#hdfPatient_ID').val();
          var Full_Name = Prefix_PatientName + PatientName;
          var RelationType = $('#ddlRelation').val();
          var Relation = $('#txt_relation').val();
          var Gender = $('#ddl_Gender').val();
          var reg_pat_id = $('#hdfreg_ini_id').val();
          var Mobile = $('#txt_mobile').val();
          var PreFix_DOB = $('#ddl_dob').val();
          var Age = $('#txt_dob').val();
          var Date_Of_Birth = $('#txtAge_yearss').val();
          var CNIC = $('#txt_cnic').val();
          var Address = $('#txt_Address').val();
          var martail_status = $('#ddl_status').val();
          var houseno = $('#txt_house').val();
          var stno = $('#txtstrm').val();
          var city = $('#txtcity :selected').text();
          var area = $('#txtarea :selected').text();
          var Country = $('#ddlCountry :selected').val();
          var city_val = $('#txtcity').val();
          var area_val = $('#txtarea').val();
          var Province = $('#ddl_Province :selected').val();

          if ((PatientName == "" || Mobile == "" || Age == "" || martail_status == "0" || Gender == "0" || Relation == "" || CNIC == "_____-_______-_" || houseno == "" || city_val == "0" || area_val == "0")) {
              Swal.fire({
                  icon: 'error',
                  title: 'Error!',
                  text: 'Please Enter compulsory Fields',
                  showConfirmButton: false,
                  timer: 2000,
                  customClass: {
                      popup: 'swal-big-popup',
                      title: 'swal-big-title',
                      htmlContainer: 'swal-big-text'
                  }
              });
              $('#SavePatient_Data').attr('disabled', false);
              return;
          }

          var data = JSON.stringify({
              "Full_Name": Full_Name,
              "RelationType": RelationType,
              "Relation": Relation,
              "Gender": Gender,
              "Mobile": Mobile,
              "Date_Of_Birth": Date_Of_Birth,
              "CNIC": CNIC,
              "Address": Address,
              "houseno": houseno,
              "stno": stno,
              "city": city,
              "city_val": city_val,
              "area_val": area_val,
              "area": area,
              "PatientID": PatientID,
              "martail_status": martail_status,
              "reg_pat_id": reg_pat_id,
              "Age": Age,
              "Country": Country,
              "Age": Age,
              "Province": Province,
          });

          $.ajax({
              type: "POST",
              url: "Derma_Appointment.aspx/SavePatientDetails",
              data: data,
              contentType: "application/json; charset=utf-8",
              dataType: "json",
              success: function (data) {
                  debugger;
                  var ini_patientID = data.d;
                  Swal.fire({
                      icon: 'success',
                      title: 'Success!',
                      text: 'Your Record Save and Load Successfully.',
                      showConfirmButton: false,
                      timer: 2500,
                      customClass: {
                          popup: 'swal-big-popup',
                          title: 'swal-big-title',
                          htmlContainer: 'swal-big-text'
                      }
                  });
                  $('#PatientModel').modal('hide');
                  get_pat_initial_info(ini_patientID);
              },
              error: function (response) {
                  alert("Error");
              }
          });
      }

      function get_pat_initial_info(ini_patientID) {
          debugger;
          try {
              isAdd = true;
              window.location.href = "Derma_Appointment.aspx?ID=" + ini_patientID + "&isAdd=" + isAdd;
          } catch (err) {
              alert(err.message);
          }
      }

      function closemodal() {
          window.location.href = "Derma_Appointment.aspx";
      }

      if (typeof Swal === 'undefined') {
          console.warn('SweetAlert not loaded. Include Swal CSS/JS for better UX.');
      }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:HiddenField runat="server" ID="hdfPatient_ID" ClientIDMode="Static" />
    <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12">
            <div class="row">
                <div class="col-lg-2 col-md-2 col-sm-6">
                    <label>Patient Name</label>
                    <input type="text" id="txt_pt_name" class="form-control" style="text-transform: capitalize;" autocomplete="off" />
                </div>
                <div class="col-lg-2 col-md-2 col-sm-6">
                    <label>Phone</label>
                    <input type="text" id="txt_phone_no" class="form-control" maxlength="11" autocomplete="off" />
                </div>
                <div class="col-lg-2 col-md-2 col-sm-6">
                    <label>Age</label>
                    <input type="text" id="txt_age" class="form-control" autocomplete="off" />
                </div>
                <div class="col-lg-3 col-md-3 col-sm-6">
                    <label>Procedure</label>
                    <select class="form-control" id="ddlProcedure">
                        <option value="">Select Procedure</option>
                        <option value="Consultation">Consultation</option>
                        <option value="Skin Test">Skin Test</option>
                        <option value="Laser Treatment">Laser Treatment</option>
                    </select>
                </div>
                <div class="col-lg-3 col-md-3 col-sm-6">
                    <label>Date</label>
                    <input type="text" id="txt_date" class="form-control" autocomplete="off" />
                </div>
            </div>
        </div>
        <div class="col-lg-12 col-md-12 col-sm-12 mt-3">
            <div class="row">
                <div class="col-lg-3 col-md-3 col-sm-6">
                    <label>Doctor</label>
                    <select class="ddldoc form-control" id="ddl_colstnt">
                        <option></option>
                    </select>
                    <div class="mt-1">
                        <small class="text-success"><i class="fa fa-check"></i> Free all day</small>
                    </div>
                    <div class="mt-1">
                        <input type="text" id="txt_doc_time_from" class="form-control" placeholder="12:01 AM" readonly />
                        <input type="text" id="txt_doc_time_to" class="form-control mt-1" placeholder="01:02 PM" readonly />
                    </div>
                    <div class="mt-1">
                        <small class="text-success"><i class="fa fa-check"></i> Available</small>
                    </div>
                </div>
                <div class="col-lg-3 col-md-3 col-sm-6">
                    <label>Helper</label>
                    <select class="form-control" id="ddlHelper">
                        <option value="">Select Helper</option>
                        <option value="Nurse Alice">Nurse Alice</option>
                        <option value="Nurse Bob">Nurse Bob</option>
                    </select>
                    <div class="mt-1">
                        <small class="text-success"><i class="fa fa-check"></i> Free all day</small>
                    </div>
                    <div class="mt-1">
                        <input type="text" id="txt_helper_time_from" class="form-control" placeholder="--:--" readonly />
                        <input type="text" id="txt_helper_time_to" class="form-control mt-1" placeholder="--:--" readonly />
                    </div>
                </div>
                <div class="col-lg-3 col-md-3 col-sm-6">
                    <label>Machine</label>
                    <select class="form-control" id="ddlMachine">
                        <option value="">Select Machine</option>
                        <option value="X-Ray Machine A">X-Ray Machine A</option>
                        <option value="MRI Machine B">MRI Machine B</option>
                    </select>
                    <div class="mt-1">
                        <small class="text-success"><i class="fa fa-check"></i> Free all day</small>
                    </div>
                    <div class="mt-1">
                        <input type="text" id="txt_machine_time_from" class="form-control" placeholder="12:06 AM" readonly />
                        <input type="text" id="txt_machine_time_to" class="form-control mt-1" placeholder="04:06 AM" readonly />
                    </div>
                    <div class="mt-1">
                        <small class="text-success"><i class="fa fa-check"></i> Available</small>
                    </div>
                </div>
                <div class="col-lg-3 col-md-3 col-sm-6">
                    <label>Room</label>
                    <select class="form-control" id="ddlRoom">
                        <option value="">Select Room</option>
                        <option value="Room 101">Room 101</option>
                        <option value="Room 202">Room 202</option>
                    </select>
                    <div class="mt-1">
                        <small class="text-success"><i class="fa fa-check"></i> Free all day</small>
                    </div>
                    <div class="mt-1">
                        <input type="text" id="txt_room_time_from" class="form-control" placeholder="--:--" readonly />
                        <input type="text" id="txt_room_time_to" class="form-control mt-1" placeholder="--:--" readonly />
                    </div>
                </div>
            </div>
        </div>

        <div class="col-lg-12 col-md-12 col-sm-12 mt-4 text-center">
            <button type="button" id="btnBookAppointment" class="btn btn-primary btn-lg">Book Appointment</button>
        </div>
    </div>
    <div id="PatientsSearchModel" class="modal fade" data-backdrop="static" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable" role="document">
            <div class="modal-content">
                <div class="modal-body">
                    <fieldset class="form-group">
                        <div class="row">
                            <div class="col-lg-3 col-md-3 col-sm-4">
                                <h5>Search Your Patients:</h5>
                                <input type="text" id="txtSearch" class="form-control" autocomplete="off" placeholder="Enter patient name or MR No." />
                            </div>
                            <div class="col-md-2 ">
                                <h5></h5>
                                <input type="button" id="addNewbtn" class="btn-primry" onclick="addfunc()" value="Add New" />
                            </div>
                        </div>
                    </fieldset>
                    <div class="table-responsive">
                        <table class="table table-hover table-striped table-bordered" id="tblPatientsResult">
                            <thead>
                                <tr>
                                    <th style="display: none;">Patient ID</th>
                                    <th>MR No</th>
                                    <th>Patient Name</th>
                                    <th>Father Name</th>
                                    <th>CNIC</th>
                                    <th>Contact No</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="iPatientsBody">
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" id="patmodalClose" class="btn btn-gray" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <div id="PatientModel" class="modal fade-in" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Add New Patient</h5>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="row">                
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <label>MR No</label>
                        <input type="text" id="txt_Mrnos" class="form-control" disabled />
                    </div>
                    <div class="col-lg-1 col-md-4 col-sm-6">
                        <label>Name<span style="color: red;">*</span></label>
                        <select id="ddl_name" class="form-control">
                            <option value="Mr.">Mr.</option>
                            <option value="Mrs.">Mrs.</option>
                            <option value="Ms.">Ms.</option>
                            <option value="B/O.">B/O.</option>
                        </select>
                    </div>
                    <div class="col-lg-3 col-md-4 col-sm-6">
                        <label></label>
                        <input type="text" id="txt_name" class="form-control" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <label>Relation<span style="color: red;">*</span></label>
                        <select id="ddlRelation" class="form-control">
                            <option value="S/O">S/O</option>
                            <option value="W/O">W/O</option>
                            <option value="D/O">D/O</option>
                        </select>
                    </div>
                    <div class="col-lg-3 col-md-4 col-sm-6">
                        <label></label>
                        <input type="text" id="txt_relation" class="form-control" />
                    </div>
                </div>

                <div class="row mt-2">
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <label>Age/DOB<span style="color: red;">*</span></label>
                        <select id="PrefixAge" class="form-control">
                            <option value="Year">Year</option>
                            <option value="Month">Month</option>
                            <option value="Day">Day</option>
                        </select>
                    </div>
                    <div class="col-lg-1 col-md-4 col-sm-6">
                        <label></label>
                        <input type="text" id="txt_dob" class="form-control" placeholder="DOB" onchange="CalculateDateOfBirth();" />
                    </div>
                    <div class="col-lg-3 col-md-4 col-sm-6">
                        <label></label>
                        <input type="text" id="txtAge_yearss" class="form-control" placeholder="dd mmyy" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <label>Gender<span style="color: red;">*</span></label>
                        <select id="ddl_Gender" class="form-control"></select>
                    </div>
                    <div class="col-lg-3 col-md-4 col-sm-6">
                        <label>CNIC<span style="color: red;">*</span></label>
                        <input type="text" id="txt_cnic" class="form-control" />
                    </div>
                </div>

                <div class="row mt-2">
                    <div class="col-lg-3 col-md-4 col-sm-6">
                        <label>Mobile<span style="color: red;">*</span></label>
                        <input type="text" id="txt_mobile" class="form-control" />
                    </div>
                    <div class="col-lg-3 col-md-4 col-sm-6">
                        <label>Marital Status<span style="color: red;">*</span></label>
                        <select id="ddl_status" class="form-control"></select>
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <label>Country</label>
                        <select id="ddlCountry" class="form-control"></select>
                    </div>
                    <div class="col-lg-3 col-md-4 col-sm-6">
                        <label>Province</label>
                        <select id="ddl_Province" class="form-control"></select>
                    </div>
                </div>

                <div class="row mt-2">
                    <div class="col-lg-3 col-md-4 col-sm-6">
                        <label>City</label>
                        <select id="txtcity" class="form-control"></select>
                    </div>
                    <div class="col-lg-3 col-md-4 col-sm-6">
                        <label>Area</label>
                        <select id="txtarea" class="form-control"></select>
                    </div>
                    <div class="col-lg-5 col-md-4 col-sm-6">
                        <label>Address</label>
                        <input type="text" id="txt_house" class="form-control" />
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primry" id="SavePatient_Data" onclick="SavePatient();">Save</button>
                <button type="button" class="btn btn-gray" onclick="closemodal" data-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>
</asp:Content>
