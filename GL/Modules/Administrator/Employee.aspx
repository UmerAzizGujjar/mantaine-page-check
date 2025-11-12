<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Employee.aspx.cs" Inherits="PMS.Employee" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/Employee.css" rel="stylesheet" />
        <link href="../../wwwroot/Tibbit_theme/css/CustomCss/Toaster.css" rel="stylesheet" />
      <script type="text/javascript">

          var Panels = '';
          $(document).ready(function () {
              debugger;
              $('#TxtTime_In').ptTimeSelect();
              $("#TxtTime_Out").ptTimeSelect();
              filldepartment();
              fillDesignation();
              GetPatientType();
              fillBuildingType();
              fillDoctorBuilding();
              fillusers();
              fillroom();
              fillPolicy();
              var time = new Date();
              var t = time.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });



              $('#txtDoctorShare, #txtHospital_Share').on('keyup', function () {
                  var docShare = parseFloat($('#txtDoctorShare').val()) || 0; // Parse as float and handle NaN
                  var hosShare = parseFloat($('#txtHospital_Share').val()) || 0; // Parse as float and handle NaN
                  var conCharges = docShare + hosShare;
                  $('#txtConsultant_Charges').val(conCharges);
              });



              var id = '<%= Request.QueryString["ID"] %>';
          if (id !== "") {

              populatedata(id);

          }
          else {
              loadnewaccountToCreate();
              $('#TxtTime_In').val(t);
              $("#TxtTime_Out").val(t);

          }
      });





          $(function () {
              Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(function (evt, args) {
                  $("#txtEmployee_Date_of_Birth").datepicker({ dateFormat: 'mm/dd/yy' });
                  $("#txtEmployee_DOJ").datepicker({ dateFormat: 'mm/dd/yy' });
                  $("#txtEmployee_Resign").datepicker({ dateFormat: 'mm/dd/yy' });

              });
          });

         




          function filldepartment() {
              var options = '<option value="0">Please Select</option>';
              PageMethods.GetDepartment(function (data) {
                  $.each(JSON.parse(data), function (key, value) {
                      options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                  });
                  $('#ddlDepartment').html(options);
                  //$('#ddl_Gender').select2();

              });
              return options;
          }
          function GetPatientType() {
              var options = '<option value="0">Please Select</option>';
              PageMethods.GetPatientType(function (data) {
                  $.each(JSON.parse(data), function (key, value) {
                      options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                  });
                  $('#ddlPatientType').html(options);
                  //$('#ddl_Gender').select2();

              });
              return options;
          }
          function fillDesignation() {
              var options = '<option value="0">Please Select</option>';
              PageMethods.GetDesignation(function (data) {
                  $.each(JSON.parse(data), function (key, value) {
                      options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                  });
                  $('#ddlDesignation').html(options);
                  //$('#ddl_Gender').select2();

              });
              return options;
          }
          function fillBuildingType() {
              var options = '<option value="0">Please Select</option>';
              PageMethods.GetBuildingType(function (data) {
                  $.each(JSON.parse(data), function (key, value) {
                      options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                  });
                  $('#ddlFloor').html(options);
                  //$('#ddl_Gender').select2();

              });
              return options;
          }
          function fillDoctorBuilding() {
              var options = '<option value="0">Please Select</option>';
              PageMethods.GetDoctorBuilding(function (data) {
                  $.each(JSON.parse(data), function (key, value) {
                      options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                  });
                  $('#ddlDoctorBuilding').html(options);
                  //$('#ddl_Gender').select2();

              });
              return options;
          }
          function fillusers() {
              var options = '<option value="0">Please Select</option>';
              PageMethods.GetUsers(function (data) {
                  $.each(JSON.parse(data), function (key, value) {
                      options += '<option value="' + value.UserId + '" >' + value.UserName + '</option>';
                  });
                  $('#ddluser').html(options);
                  //$('#ddl_Gender').select2();

              });
              return options;
          }
          function fillroom() {
              var options = '<option value="0">Please Select</option>';
              PageMethods.GetRoom(function (data) {
                  $.each(JSON.parse(data), function (key, value) {
                      options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                  });
                  $('#ddlRoom').html(options);
                  //$('#ddl_Gender').select2();

              });
              return options;
          }

          function populatedata(empID) {
              PageMethods.PopulateEmployeeData(parseInt(empID), function (data) {
                  var empData = JSON.parse(data);
                  debugger;
                  console.log(empData);
                  // Now populate form fields
                  // Textboxes and Dropdowns
                  $("#txtEmployeeID").val(empData.txtEmployeeID);
                  $("#txtEmployeeCode").val(empData.txtEmployeeCode);
                  $("#txtEmployee_Name").val(empData.txtEmployee_Name);
                  $("#txtFather_Name").val(empData.txtFather_Name);
                  $("#txtEmployee_Date_of_Birth").val(empData.txtEmployee_Date_of_Birth);

                  $("#ddlDoctorBuilding").val(empData.ddlDoctorBuilding);
                  $("#txtEmployee_Address").val(empData.txtEmployee_Address);
                  $("#txtEmployee_Phone1").val(empData.txtEmployee_Phone1);
                  $("#txtEmployee_Phone2").val(empData.txtEmployee_Phone2);
                  $("#txtGovt_Hospital").val(empData.txtGovt_Hospital);
                  $("#ddluser").val(empData.user);
                  $("#txtdependent").val(empData.dependent);

                  $("#txtdoc_qualification").val(empData.Doc_qualification);
                  $("#txtPanelAmount").val(empData.panelrate);


                  debugger;
                    setTimeout(function () {
                        $("#ddluser").val(empData.user);
                        }, 2500)
                  
                  $("#ddluser").val(empData.ddluser);
                  $("#txtPatient_Time").val(empData.txtPatient_Time);
                  $("#TxtTime_In").val(empData.TxtTime_In);
                  $("#TxtTime_Out").val(empData.TxtTime_Out);
                  $("#ddlRoom").val(empData.ddlRoom);
                  $("#Ext_txt").val(empData.Ext_txt);
                  $("#txtEmployee_NTN_No").val(empData.txtEmployee_NTN_No);
                  $("#txtEmployee_Email").val(empData.txtEmployee_Email);
                  $("#txtEmployee_DOJ").val(empData.txtEmployee_DOJ);
                  $("#txtDoctorShare").val(empData.txtDoctorShare);
                  $("#txtHospital_Share").val(empData.txtHospital_Share);
                  $("#txtEmployee_Resign").val(empData.txtEmployee_Resign);
                  $("#txtGrossPay").val(empData.txtGrossPay);
                  $("#txtRemarks").val(empData.txtRemarks);
                  $("#txtConsultant_Charges").val(empData.txtConsultant_Charges);

                  // Checkboxes


                  // Set button text


                  setTimeout(function () {
                      $("#ddlDesignation").val(empData.ddlDesignation);
                      $("#ddlFloor").val(empData.ddlFloor);
                      $("#ddlDepartment").val(empData.ddlDepartment);
                      $("#ddlPolicy").val(empData.ddlPolicy).trigger('change');
                      $("#ddlPatientType").val(empData.ddlPatientType);
                      $("#btnSave").val(empData.btnSave);
                      $("#ChkDoctor").prop("checked", empData.ChkDoctor);
                      $("#ChkVisting").prop("checked", empData.ChkVisting);
                      $("#ChkEmployee").prop("checked", empData.ChkEmployee);
                      $("#sun").prop("checked", empData.isSun);
                      $("#mon").prop("checked", empData.isMon);
                      $("#tue").prop("checked", empData.isTue);
                      $("#wed").prop("checked", empData.isWed);
                      $("#thur").prop("checked", empData.isThur);
                      $("#fri").prop("checked", empData.isFri);
                      $("#sat").prop("checked", empData.isSat);
                  }, 2500)


                  if (empData.Account_ID != null) {
                      PageMethods.LoadGLAccount(parseInt(empData.Account_ID), function (data) {
                          var AccountData = JSON.parse(data);

                          $("#txtAccount_Code_Name").val(AccountData.txtAccount_Code_Name);
                          $("#hdfAccount_Name").val(AccountData.hdfAccount_Name);
                          $("#hdfAccount_Code").val(AccountData.hdfAccount_Code);
                          $("#hdfParent_Code").val(AccountData.hdfParent_Code);
                          $("#hdfAccount_Serial").val(AccountData.hdfAccount_Serial);
                          $("#hdfLevel").val(AccountData.hdfLevel);
                          $("#hdfAccount_ID").val(AccountData.hdfAccount_ID);


                      }
                          , function (err) {
                              alert("Error: " + err.get_message());
                          });
                  }

              },
                  function (err) {
                      alert("Error: " + err.get_message());
                  });
          }

          function toasterMessage(isError = false, title, message) {
              debugger;
              toastr.options = {
                  "closeButton": true,
                  "debug": false,
                  "preventDuplicates": false,
                  "positionClass": "toast-center-screen", // Custom class for center
                  "onclick": null,
                  "showDuration": "551500",
                  "hideDuration": "2000",
                  "timeOut": "4000",
                  "extendedTimeOut": "1000",
                  "showEasing": "swing",
                  "hideEasing": "linear",
                  "showMethod": "fadeIn",
                  "hideMethod": "fadeOut",
                  onclick: function () {
                      $('#right-sidebar').toggleClass('sidebar-open');
                  }
              };

              if (isError)
                  toastr.error(message, title);
              else
                  toastr.success(message, title);
          }


          function loadnewaccountToCreate() {

              PageMethods.LoadNewAccountToCreate(function (data) {
                  var NewAccountData = JSON.parse(data);

                  $("#hdfParent_Code").val(NewAccountData.NewhdfParent_Code);
                  $("#hdfAccount_Code").val(NewAccountData.NewhdfAccount_Code);
                  $("#hdfAccount_Serial").val(NewAccountData.NewhdfAccount_Serial);
                  $("#hdfLevel").val(NewAccountData.NewhdfLevel);



              }
                  , function (err) {
                      alert("Error: " + err.get_message());
                  });


          }
          function saveData() {             
              debugger;          
              var hdfAccount_ID = $('#hdfAccount_ID').val();
              var buttonVal = $('#btnSave').val();
              var txtEmployeeID = $('#txtEmployeeID').val();
              var txtEmployee_Name = $('#txtEmployee_Name').val();
              var txtFather_Name = $('#txtFather_Name').val();
              var txtEmployee_Date_of_Birth = $('#txtEmployee_Date_of_Birth').val();
              var txtPanelAmount = $('#txtPanelAmount').val();
              var ddlPatientType = $('#ddlPatientType').val();
              var ddlDepartment = $('#ddlDepartment').val();
              var ddlPolicy = $('#ddlPolicy').val();
              if (ddlPolicy == null || ddlPolicy === "" || ddlPolicy === "null") {
                  ddlPolicy = "0";
              }
              var ddlDesignation = $('#ddlDesignation').val();
              var txtEmployee_Phone2 = $('#txtEmployee_Phone2').val();
              var txtEmployee_Phone1 = $('#txtEmployee_Phone1').val();
              var txtEmployee_Email = $('#txtEmployee_Email').val();
              var txtPatient_Time = $('#txtPatient_Time').val();
              var TxtTime_In = $('#TxtTime_In').val();
              var TxtTime_Out = $('#TxtTime_Out').val();
              var txtEmployee_NTN_No = $('#txtEmployee_NTN_No').val();
              var ddlRoom = $('#ddlRoom').val();
              var txtEmployee_DOJ = $('#txtEmployee_DOJ').val();
              var txtEmployee_Resign = $('#txtEmployee_Resign').val();
              var ddlFloor = $('#ddlFloor').val();
              var txtDoctorShare = $('#txtDoctorShare').val();
              var txtHospital_Share = $('#txtHospital_Share').val();
              var Ext_txt = $('#Ext_txt').val();
              var txtGrossPay = $('#txtGrossPay').val();
              var txtConsultant_Charges = $('#txtConsultant_Charges').val();
              var ddlDoctorBuilding = $('#ddlDoctorBuilding').val();
              var txtEmployee_Address = $('#txtEmployee_Address').val();
              var txtRemarks = $('#txtRemarks').val();
              var ddluser = $('#ddluser').val();
              var txtdependent = $('#txtdependent').val();
              var txtdoc_qualification = $('#txtdoc_qualification').val();
              var isSun = $('#sun').prop('checked');
              var isMon = $('#mon').prop('checked');
              var isTue = $('#tue').prop('checked');
              var isWed = $('#wed').prop('checked');
              var isThur = $('#thur').prop('checked');
              var isFri = $('#fri').prop('checked');
              var isSat = $('#sat').prop('checked');
              var isDoc = $('#ChkDoctor').prop('checked');
              var isVisiting = $('#ChkVisting').prop('checked');
              var IsEmployee = $('#ChkEmployee').prop('checked');

              var hdfParent_Code = $('#hdfParent_Code').val();
              var hdfAccount_Serial = $('#hdfAccount_Serial').val();
              var hdfLevel = $('#hdfLevel').val();
              var hdfAccount_Code = $('#hdfAccount_Code').val();
              var txtGovt_Hospital = $('#txtGovt_Hospital').val();
              var hdnEmp = $('#hdnEmp').val();
              var lblMessage = $('#lblMessage').val();
              var CustomerJSON = $('#CustomerJSON').val() || '';

              if (!txtEmployee_Date_of_Birth || txtEmployee_Date_of_Birth.trim() === '') {
                  Swal.fire({
                      icon: 'error',
                      title: 'Error!',
                      text: 'Please select Date of birth',
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

              if (!txtEmployee_DOJ || txtEmployee_DOJ.trim() === '') {
                  Swal.fire({
                      icon: 'error',
                      title: 'Error!',
                      text: 'Please select Date of Joining',
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

              
              var dataObj = {
                  "buttonVal": buttonVal,
                  "txtEmployeeID": txtEmployeeID,
                  "txtEmployee_Name": txtEmployee_Name,
                  "txtFather_Name": txtFather_Name,
                  "txtEmployee_Date_of_Birth": txtEmployee_Date_of_Birth,
                  "txtPanelAmount": txtPanelAmount,
                  "ddlPatientType": ddlPatientType,
                  "ddlDepartment": ddlDepartment,
                  "ddlPolicy": ddlPolicy,
                  "ddlDesignation": ddlDesignation,
                  "txtEmployee_Phone2": txtEmployee_Phone2,
                  "txtEmployee_Phone1": txtEmployee_Phone1,
                  "txtEmployee_Email": txtEmployee_Email,
                  "txtPatient_Time": txtPatient_Time,
                  "TxtTime_In": TxtTime_In,
                  "TxtTime_Out": TxtTime_Out,
                  "txtEmployee_NTN_No": txtEmployee_NTN_No,
                  "ddlRoom": ddlRoom,
                  "txtEmployee_DOJ": txtEmployee_DOJ,
                  "txtEmployee_Resign": txtEmployee_Resign,
                  "ddlFloor": ddlFloor,
                  "txtDoctorShare": txtDoctorShare,
                  "txtHospital_Share": txtHospital_Share,
                  "Ext_txt": Ext_txt,
                  "txtGrossPay": txtGrossPay,
                  "txtConsultant_Charges": txtConsultant_Charges,
                  "ddlDoctorBuilding": ddlDoctorBuilding,
                  "txtEmployee_Address": txtEmployee_Address,
                  "txtRemarks": txtRemarks,
                  "ddluser": ddluser,
                  "txtdependent": txtdependent,
                  "txtdoc_qualification": txtdoc_qualification,
                  "isSun": isSun,
                  "isMon": isMon,
                  "isTue": isTue,
                  "isWed": isWed,
                  "isThur": isThur,
                  "isFri": isFri,
                  "isSat": isSat,
                  "isDoc": isDoc,
                  "isVisiting": isVisiting,
                  "hdfAccount_ID": hdfAccount_ID,
                  "hdfParent_Code": hdfParent_Code,
                  "hdfAccount_Serial": hdfAccount_Serial,
                  "hdfLevel": hdfLevel,
                  "hdfAccount_Code": hdfAccount_Code,
                  "txtGovt_Hospital": txtGovt_Hospital,
                  "IsEmployee": IsEmployee,
                  "hdnEmp": hdnEmp,
                  "lblMessage": lblMessage,
                  "CustomerJSON": CustomerJSON

              };


              var data = JSON.stringify({ dataa: dataObj });


              debugger;
              $.ajax({
                  type: "POST",
                  url: "Employee.aspx/SaveData",
                  data: data,
                  contentType: "application/json; charset=utf-8",
                  dataType: "json",
                  success: function (data) {
                      debugger;
                      var ini_patientID = data.d;
                      Swal.fire({
                          icon: 'success',
                          title: 'Success!',
                          text: 'Data Saved Successfully',
                          showConfirmButton: false,
                          timer: 2500,
                          customClass: {
                              popup: 'swal-big-popup',
                              title: 'swal-big-title',
                              htmlContainer: 'swal-big-text'
                          }
                      });

                      window.location.href = "EmployeeView.aspx";

                  },
                  error: function (xhr, status, error) {
                      console.log("XHR:", xhr);
                      console.log("Status:", status);
                      console.log("Error:", error);

                      // Try to show server response if it's plain text
                      if (xhr.responseText) {
                          alert("Server Error: " + xhr.responseText);
                      } else {
                          alert("AJAX Error: " + error);
                      }
                  }
              });
          }

          function redirect() {
              window.location.href = "EmployeeView.aspx";
          }


          function fillPolicy() {
              $.ajax({
                  url: 'Employee.aspx/GetAllPolicies',
                  type: 'POST',
                  contentType: 'application/json; charset=utf-8',
                  dataType: 'json',
                  success: function (res) {
                      let data = res.d ? JSON.parse(res.d) : res;
                      $('#ddlPolicy')
                          .empty()
                          .append('<option value="0">Please Select</option>')
                          .append($.map(data, function (v) {
                              return $('<option>', { value: v.Policy_ID, text: v.Policy_Name });
                          }))
                          .select2({ placeholder: "Please Select", allowClear: true, width: "90%" });
                  }
              });
          }


      </script>
  

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
            <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Employee ID</label>
               
                <input readonly type="text" id="txtEmployeeID" value="(New)"  />

            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Employee Code **</label>
                <input type="text" id="txtEmployeeCode" name="txtEmployeeCode" disabled="disabled" />

            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Employee Name *</label>
               <input type="text" id="txtEmployee_Name" name="txtEmployee_Name" autocomplete="off" />

                <span id="errorEmployee_Name" class="validation" style="color:red; display:none;">
  Employee Name is required.
</span>
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Father Name</label>
                <input type="text" id="txtFather_Name" name="txtFather_Name" autocomplete="off" />

            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Date of Birth</label>
                <input type="text" id="txtEmployee_Date_of_Birth" name="txtEmployee_Date_of_Birth" />

            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Panel Rate</label>
                <input type="text" id="txtPanelAmount" name="txtPanelAmount" />
            </div>
        </div>
        <br />
        <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Patient type</label>
                <select id="ddlPatientType" name="ddlPatientType">
                  <!-- Add <option> elements here -->
                </select>

            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Department *</label>
                <select id="ddlDepartment" name="ddlDepartment" >
                  <!-- Add <option> elements here -->
                </select>

                
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Designation</label>
                <select id="ddlDesignation" name="ddlDesignation">
                  <!-- Add <option> elements here -->
                </select>

            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Mobile No</label>
                
                <input
                  type="text"
                  id="txtEmployee_Phone2"
                  name="txtEmployee_Phone2"
                  maxlength="11"
                  autocomplete="off"
                  oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');"
                />

            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Home Phone</label>
                <input
                  type="text"
                  id="txtEmployee_Phone1"
                  name="txtEmployee_Phone1"
                  maxlength="11"
                  autocomplete="off"
                  oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');"
                />

            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Email</label>
                <input type="text" id="txtEmployee_Email" name="txtEmployee_Email" autocomplete="off" />

            </div>
        </div>
        <br />

        <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Patient Time</label>
                <input type="text" id="txtPatient_Time" name="txtPatient_Time" />

            </div>
            <div class="col-lg-1 col-md-4 col-sm-6">
                <label>Time In</label>
                <input type="text" id="TxtTime_In" name="TxtTime_In" />

            </div>
            <div class="col-lg-1 col-md-4 col-sm-6">
                <label>Time Out</label>
                <input type="text" id="TxtTime_Out" name="TxtTime_Out" />


            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>NTN No.</label>
                <input type="text" id="txtEmployee_NTN_No" name="txtEmployee_NTN_No" autocomplete="off" />

            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Room #</label>
                <select id="ddlRoom" name="ddlRoom">
                  <!-- Add your <option> elements here -->
                </select>

            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Date of Joining</label>
                <input type="text" id="txtEmployee_DOJ" name="txtEmployee_DOJ" />

            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Resign Date</label>
                <input type="text" id="txtEmployee_Resign" name="txtEmployee_Resign" autocomplete="off" />

            </div>
        </div>
        <br />
        <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Floor #</label>
               <select id="ddlFloor" name="ddlFloor">
                  <!-- Add your <option> elements here -->
                </select>

            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Doctor Share</label>
                <input type="text" id="txtDoctorShare" name="txtDoctorShare" autocomplete="off" />

            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Hospital Share</label>
                <input type="text" id="txtHospital_Share" name="txtHospital_Share" />

            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Extension No</label>
                <input type="text" id="Ext_txt" name="Ext_txt" />

            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Gross Pay</label>
                <input type="text" id="txtGrossPay" name="txtGrossPay" autocomplete="off" />

            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Consultant Charges</label>
                <input type="text" id="txtConsultant_Charges" name="txtConsultant_Charges" readonly autocomplete="off" />

            </div>
        </div>
        <br />
        <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>GL Account</label>
                <input type="text" id="txtAccount_Code_Name" name="txtAccount_Code_Name" readonly />

                <input type="hidden" id="hdfAccount_Name" name="hdfAccount_Name" />
                <input type="hidden" id="hdfAccount_Code" name="hdfAccount_Code" />
                <input type="hidden" id="hdfParent_Code" name="hdfParent_Code" />
                <input type="hidden" id="hdfAccount_Serial" name="hdfAccount_Serial" />
                <input type="hidden" id="hdfLevel" name="hdfLevel" />
                <input type="hidden" id="hdfAccount_ID" name="hdfAccount_ID" />
                <input type="hidden" id="hdfAccountExists" name="hdfAccountExists" />

            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Building</label>
                <select id="ddlDoctorBuilding" name="ddlDoctorBuilding">
                  <!-- Add your <option> elements here -->
                </select>
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Address</label>
                <textarea
                  id="txtEmployee_Address"
                  name="txtEmployee_Address"
                  rows="1"
                  cols="50"
                  style="width: 100%; height: 34px !important; border-radius: 5px !important;">
                </textarea>



            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Remarks</label>
                <textarea
                  id="txtRemarks"
                  name="txtRemarks"
                  rows="1"
                  cols="50"
                  style="width: 100%; height: 34px !important; border-bottom-right-radius: 5px !important;">
                </textarea>
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Users</label>
                <select id="ddluser" name="ddluser">
                  <!-- Add your <option> elements here -->
                </select>
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <div class="row">
                <label id="Off_txt" for="">
                  Off Days
                </label>
                </div>
                <div class="row">
                    <div class="col-lg-3 col-md-4 col-sm-6">
                        Sun 
                        <input type="checkbox" id="sun" name="sun" />

                    </div>
                    <div class="col-lg-3 col-md-4 col-sm-6">
                        Mon 
                <input type="checkbox" id="mon" name="mon" />

                    </div>
                    <div class="col-lg-3 col-md-4 col-sm-6">
                        Tue 
                      <input type="checkbox" id="tue" name="mon" />
                    </div>
                    <div class="col-lg-3 col-md-4 col-sm-6">
                        Wed 
                            <input type="checkbox" id="wed" name="mon" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-lg-3 col-md-4 col-sm-6">
                        Thur 
                         <input type="checkbox" id="thur" name="mon" />
                    </div>
                    <div class="col-lg-3 col-md-4 col-sm-6">
                        Fri 
                <input type="checkbox" id="fri" name="mon" />
                    </div>
                    <div class="col-lg-3 col-md-4 col-sm-6">
                        Sat 
                        <input type="checkbox" id="sat" name="mon" />
                    </div>
                </div>
            </div>
        </div>
        <div class="row">
        </div>
        <div class="row">
              <div class="col-lg-2 col-md-4 col-sm-6">
                  <label>Qualification</label>
                   <input type="text" id="txtdoc_qualification" name="txtdoc_qualification" />
              </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Dependent</label>
                 <input type="text" id="txtdependent" name="txtdependent" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Policy</label>
                <select id="ddlPolicy" name="ddlPolicy" class="form-control">
                    <option value="">Please Select</option>
                </select>
            </div>
                  <div class="col-lg-1 col-md-4 col-sm-6 custom-label-checkbox">
                 <input type="checkbox" id="ChkDoctor" name="ChkDoctor" class="chkwdth" />
                <label id="LblIsDoctor" for="ChkDoctor">Doctor</label>
                

            </div>
            <div class="col-lg-1 col-md-4 col-sm-6 custom-label-checkbox">
                <input type="checkbox" id="ChkVisting" name="ChkVisting" class="chkwdth" />
                <label id="LblIsVisting" for="ChkVisting">Visting</label>
            </div>

            <div class="col-lg-1 col-md-4 col-sm-6 custom-label-checkbox">
                <input type="checkbox" id="ChkEmployee" name="ChkEmployee" class="chkwdth" />
                <label id="LblEmployee" for="ChkEmployee">Employee</label>
            </div>


            <div class="col-lg-8 col-md-4 col-sm-6">
            </div>
        </div>

    <div class="row">
        <div class="col-lg-8 col-md-9 col-sm-6">
            <div class="row">
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" class="btn btn-primry" onclick="saveData()" id="btnSave" value="Save" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6 ">
                    <input type="button" class="btn btn-gray" onclick="redirect()" id="btnBack" value="View" />
                </div>
            </div>
        </div>
    </div>


    <div class="row">
        <div class="col-lg-0 col-md-4 col-sm-6" style="visibility: hidden">
            <label>Govt.Hospital</label>
            <input type="text" id="txtGovt_Hospital" name="txtGovt_Hospital" />

        </div>
    </div>
        <span id="errorDepartment" style="color:red; display:none;">Department is required.</span>
    
    <table style="padding: 20px; width: 1130px; height: 210px;">
        <tr>
            <td colspan="6">
               <span id="lblMessage"></span>

            </td>
        </tr>
    </table>
    <input type="hidden" id="hdnEmp" name="hdnEmp" />
</asp:Content>
