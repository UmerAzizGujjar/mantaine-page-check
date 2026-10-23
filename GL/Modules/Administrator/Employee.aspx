<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Employee.aspx.cs" Inherits="PMS.Employee" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/Employee.css" rel="stylesheet" />
        <link href="../../wwwroot/lib/sweetalert/Toaster.css" rel="stylesheet" />
      <script type="text/javascript">

          var Panels = '';
          var autoAccountId = '0';
          $(document).ready(function () {
              $('#ddlAccount').prop("disabled", true);
              $("#chkmanual").change(function () {
                  if (this.checked) {
                      $('#ddlAccount').prop("disabled", false);
                  } else {
                      $('#ddlAccount').val(autoAccountId).prop("disabled", true).trigger('change');
                  }
              });
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
              // Accounts first, so the employee's Account_ID can be selected
              fillAccounts(function () {
                  populatedata(id);
              });
          }
          else {
              fillAccounts();
              $('#TxtTime_In').val(t);
              $("#TxtTime_Out").val(t);

          }
      });





          $(function () {
              Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(function (evt, args) {
                  $("#txtEmployee_Date_of_Birth").datepicker({ dateFormat: 'mm/dd/yy' });
                  $("#txtEmployee_DOJ").datepicker({ dateFormat: 'mm/dd/yy' });
                  $("#txtEmployee_Resign").datepicker({ dateFormat: 'mm/dd/yy' });
                  $("#txtStartDate").datepicker({ dateFormat: 'mm/dd/yy' });
                  $("#txtEndDate").datepicker({ dateFormat: 'mm/dd/yy' });

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

          function fillAccounts(callback) {
              PageMethods.LoadAccounts(function (data) {
                  var options = '<option value="0">Please Select</option>';
                  $.each(JSON.parse(data), function (key, value) {
                      options += '<option value="' + value.Account_ID + '" >' + value.name + '</option>';
                  });
                  $('#ddlAccount').html(options).select2({ width: "100%" });
                  if (callback) callback();
              });
          }

          function to12Hour(time24) {
              if (!time24) return '';
              const [h, m] = time24.split(':');
              let hour = parseInt(h, 10);
              const ampm = hour >= 12 ? 'PM' : 'AM';
              hour = hour % 12;
              hour = hour ? hour : 12;
              return `${hour}:${m} ${ampm}`;
          }

          function populatedata(empID) {
              PageMethods.PopulateEmployeeData(parseInt(empID), function (data) {
                  var empData = JSON.parse(data);
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
                  $("#txtPMDC").val(empData.txtPMDC);

                  $("#txtdoc_qualification").val(empData.txtdoc_qualification);
                  $("#txtPanelAmount").val(empData.panelrate);


                    setTimeout(function () {
                        $("#ddluser").val(empData.user);
                        }, 2500)
                  
                  $("#ddluser").val(empData.ddluser);
                  $("#txtPatient_Time").val(empData.txtPatient_Time);
                  $("#TxtTime_In").val(to12Hour(empData.TxtTime_In));
                  $("#TxtTime_Out").val(to12Hour(empData.TxtTime_Out));
                  $("#ddlRoom").val(empData.ddlRoom);
                  $("#Ext_txt").val(empData.Ext_txt);
                  $("#txtEmployee_NTN_No").val(empData.txtEmployee_NTN_No);
                  $("#txtEmployee_Email").val(empData.txtEmployee_Email);
                  $("#txtEmployee_DOJ").val(empData.txtEmployee_DOJ);
                  $("#txtStartDate").val(empData.txtStartDate);
                  $("#txtEndDate").val(empData.txtEndDate);
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
                      $("#ChkBlockCategory").prop("checked", empData.ChkBlockCategory);
                      $("#sun").prop("checked", empData.isSun);
                      $("#mon").prop("checked", empData.isMon);
                      $("#tue").prop("checked", empData.isTue);
                      $("#wed").prop("checked", empData.isWed);
                      $("#thur").prop("checked", empData.isThur);
                      $("#fri").prop("checked", empData.isFri);
                      $("#sat").prop("checked", empData.isSat);
                  }, 2500)


                  // A missing/deleted account just leaves the dropdown on "Please Select"
                  $("#hdfAccount_ID").val(empData.Account_ID || '');
                  $("#chkmanual").prop("checked", empData.Ismanual);
                  if (!empData.Ismanual) {
                      autoAccountId = empData.Account_ID || '0';
                  }
                  $("#ddlAccount").val(empData.Account_ID || '0').prop("disabled", !empData.Ismanual).trigger('change');

              },
                  function (err) {
                      alert("Error: " + err.get_message());
                  });
          }

          function toasterMessage(isError = false, title, message) {
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


          function to24Hour(timeStr) {
              if (!timeStr) return '';
              const [time, modifier] = timeStr.split(' ');
              let [hours, minutes] = time.split(':');
              if (hours === '12') {
                  hours = '00';
              }
              if (modifier === 'PM') {
                  hours = (parseInt(hours, 10) + 12).toString();
              }
              return `${hours.padStart(2, '0')}:${minutes.padStart(2, '0')}`;
          }
          function saveData() {             
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
              var TxtTime_In = to24Hour($('#TxtTime_In').val());  
              var TxtTime_Out = to24Hour($('#TxtTime_Out').val());
              var txtEmployee_NTN_No = $('#txtEmployee_NTN_No').val();
              var ddlRoom = $('#ddlRoom').val();
              var txtEmployee_DOJ = $('#txtEmployee_DOJ').val();
              var txtStartDate = $('#txtStartDate').val();
              var txtEndDate = $('#txtEndDate').val();
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
              var txtPMDC = $('#txtPMDC').val();
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
              var BlockCategory = $('#ChkBlockCategory').prop('checked');

              var hdfParent_Code = $('#hdfParent_Code').val();
              var hdfAccount_Serial = $('#hdfAccount_Serial').val();
              var hdfLevel = $('#hdfLevel').val();
              var hdfAccount_Code = $('#hdfAccount_Code').val();
              var txtGovt_Hospital = $('#txtGovt_Hospital').val();
              var hdnEmp = $('#hdnEmp').val();
              var lblMessage = $('#lblMessage').val();
              var CustomerJSON = $('#CustomerJSON').val() || '';
              var Ismanual = $('#chkmanual').prop('checked');
              var ddlAccount = $('#ddlAccount').val() || '0';

              if (Ismanual == true && ddlAccount == '0') {
                  Swal.fire({
                      icon: 'error',
                      title: 'Error!',
                      text: 'Please select GL Account',
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

              //if (!txtEmployee_Date_of_Birth || txtEmployee_Date_of_Birth.trim() === '') {
              //    Swal.fire({
              //        icon: 'error',
              //        title: 'Error!',
              //        text: 'Please select Date of birth',
              //        showConfirmButton: false,
              //        timer: 2000,
              //        customClass: {
              //            popup: 'swal-big-popup',
              //            title: 'swal-big-title',
              //            htmlContainer: 'swal-big-text'
              //        }
              //    });
              //    return;
              //}

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

              if (!TxtTime_In || TxtTime_In.trim() === '') {
                  Swal.fire({
                      icon: 'error',
                      title: 'Error!',
                      text: 'Please select Time In',
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

              if (!TxtTime_Out || TxtTime_Out.trim() === '') {
                  Swal.fire({
                      icon: 'error',
                      title: 'Error!',
                      text: 'Please select Time Out',
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
                  "txtStartDate": txtStartDate,
                  "txtEndDate": txtEndDate,
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
                  "txtPMDC": txtPMDC,
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
                  "Ismanual": Ismanual,
                  "ddlAccount": ddlAccount,
                  "hdfParent_Code": hdfParent_Code,
                  "hdfAccount_Serial": hdfAccount_Serial,
                  "hdfLevel": hdfLevel,
                  "hdfAccount_Code": hdfAccount_Code,
                  "txtGovt_Hospital": txtGovt_Hospital,
                  "IsEmployee": IsEmployee,
                  "BlockCategory": BlockCategory,
                  "hdnEmp": hdnEmp,
                  "lblMessage": lblMessage,
                  "CustomerJSON": CustomerJSON

              };


              var data = JSON.stringify({ dataa: dataObj });


              $.ajax({
                  type: "POST",
                  url: "Employee.aspx/SaveData",
                  data: data,
                  contentType: "application/json; charset=utf-8",
                  dataType: "json",
                  success: function (data) {
                      var result = data.d;
                      if (result !== "Saved Successfully!") {
                          Swal.fire({
                              icon: 'error',
                              title: 'Error!',
                              text: result || 'Save failed. Please try again.',
                              showConfirmButton: true,
                              customClass: {
                                  popup: 'swal-big-popup',
                                  title: 'swal-big-title',
                                  htmlContainer: 'swal-big-text'
                              }
                          });
                          return;
                      }
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
<div class="emp-page">

    <!-- ============ META BAR ============ -->
    <div class="emp-meta-bar">
        <div class="emp-meta-title">
            <i class="fa fa-user-md"></i>
            <span>Employee</span>
            <span class="emp-meta-badge" id="empMetaBadge">New</span>
        </div>
        <div class="emp-meta-actions">
            <span class="emp-meta-badge"><i class="fa fa-calendar"></i> <%= DateTime.Now.ToString("dd MMM yyyy") %></span>
        </div>
    </div>

    <!-- ============ HIDDEN FIELDS ============ -->
    <input type="hidden" id="hdnEmp" name="hdnEmp" />
    <input type="hidden" id="hdfAccount_Name" name="hdfAccount_Name" />
    <input type="hidden" id="hdfAccount_Code" name="hdfAccount_Code" />
    <input type="hidden" id="hdfParent_Code" name="hdfParent_Code" />
    <input type="hidden" id="hdfAccount_Serial" name="hdfAccount_Serial" />
    <input type="hidden" id="hdfLevel" name="hdfLevel" />
    <input type="hidden" id="hdfAccount_ID" name="hdfAccount_ID" />
    <input type="hidden" id="hdfAccountExists" name="hdfAccountExists" />
    <input type="hidden" id="CustomerJSON" />

    <!-- ============ ROW 1: BASIC INFO + CONTACT ============ -->
    <div class="emp-cards-grid">

    <!-- ============ BASIC INFO CARD ============ -->
    <div class="emp-card">
        <div class="emp-card-header">
            <i class="fa fa-id-card"></i>
            <span>Basic Information</span>
            <span class="emp-card-badge">Identity</span>
        </div>
        <div class="emp-card-body">
            <div class="emp-bento emp-bento--3">
                <div class="emp-field">
                    <label class="emp-label">Employee ID</label>
                    <input readonly type="text" id="txtEmployeeID" value="(New)" class="emp-input emp-input--readonly" />
                </div>
                <div class="emp-field">
                    <label class="emp-label">Employee Code <span class="emp-required">*</span></label>
                    <input type="text" id="txtEmployeeCode" name="txtEmployeeCode" disabled="disabled" class="emp-input emp-input--readonly" />
                </div>
                <div class="emp-field">
                    <label class="emp-label">Employee Name <span class="emp-required">*</span></label>
                    <input type="text" id="txtEmployee_Name" name="txtEmployee_Name" autocomplete="off" class="emp-input" />
                    <span id="errorEmployee_Name" class="emp-validation">Employee Name is required.</span>
                </div>
                <div class="emp-field">
                    <label class="emp-label">Father Name</label>
                    <input type="text" id="txtFather_Name" name="txtFather_Name" autocomplete="off" class="emp-input" />
                </div>
                <div class="emp-field">
                    <label class="emp-label">Date of Birth</label>
                    <input type="text" id="txtEmployee_Date_of_Birth" name="txtEmployee_Date_of_Birth" class="emp-input" />
                </div>
                <div class="emp-field">
                    <label class="emp-label">Panel Rate</label>
                    <input type="text" id="txtPanelAmount" name="txtPanelAmount" class="emp-input" />
                </div>
            </div>
        </div>
    </div>

    <!-- ============ CONTACT & DEPARTMENT CARD ============ -->
    <div class="emp-card">
        <div class="emp-card-header">
            <i class="fa fa-address-book"></i>
            <span>Contact &amp; Department</span>
        </div>
        <div class="emp-card-body">
            <div class="emp-bento emp-bento--3">
                <div class="emp-field">
                    <label class="emp-label">Patient Type</label>
                    <select id="ddlPatientType" name="ddlPatientType" class="emp-select"></select>
                </div>
                <div class="emp-field">
                    <label class="emp-label">Department <span class="emp-required">*</span></label>
                    <select id="ddlDepartment" name="ddlDepartment" class="emp-select"></select>
                    <span id="errorDepartment" class="emp-validation">Department is required.</span>
                </div>
                <div class="emp-field">
                    <label class="emp-label">Designation</label>
                    <select id="ddlDesignation" name="ddlDesignation" class="emp-select"></select>
                </div>
                <div class="emp-field">
                    <label class="emp-label">Mobile No</label>
                    <input type="text" id="txtEmployee_Phone2" name="txtEmployee_Phone2" maxlength="11" autocomplete="off" class="emp-input" oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');" />
                </div>
                <div class="emp-field">
                    <label class="emp-label">Home Phone</label>
                    <input type="text" id="txtEmployee_Phone1" name="txtEmployee_Phone1" maxlength="11" autocomplete="off" class="emp-input" oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');" />
                </div>
                <div class="emp-field">
                    <label class="emp-label">Email</label>
                    <input type="text" id="txtEmployee_Email" name="txtEmployee_Email" autocomplete="off" class="emp-input" />
                </div>
            </div>
        </div>
    </div>

    </div>

    <!-- ============ ROW 2: SCHEDULE + COMPENSATION ============ -->
    <div class="emp-cards-grid">

    <!-- ============ SCHEDULE CARD ============ -->
    <div class="emp-card">
        <div class="emp-card-header">
            <i class="fa fa-clock-o"></i>
            <span>Schedule</span>
        </div>
        <div class="emp-card-body">
            <div class="emp-bento emp-bento--3">
                <div class="emp-field">
                    <label class="emp-label">Patient Time</label>
                    <input type="text" id="txtPatient_Time" name="txtPatient_Time" class="emp-input" />
                </div>
                <div class="emp-field">
                    <label class="emp-label">Time In</label>
                    <input type="text" id="TxtTime_In" name="TxtTime_In" class="emp-input" />
                </div>
                <div class="emp-field">
                    <label class="emp-label">Time Out</label>
                    <input type="text" id="TxtTime_Out" name="TxtTime_Out" class="emp-input" />
                </div>
                <div class="emp-field">
                    <label class="emp-label">Start Date</label>
                    <input type="text" id="txtStartDate" name="txtStartDate" class="emp-input" />
                </div>
                <div class="emp-field">
                    <label class="emp-label">End Date</label>
                    <input type="text" id="txtEndDate" name="txtEndDate" class="emp-input" />
                </div>
                <div class="emp-field">
                    <label class="emp-label">Room #</label>
                    <select id="ddlRoom" name="ddlRoom" class="emp-select"></select>
                </div>
                <div class="emp-field">
                    <label class="emp-label">Date of Joining</label>
                    <input type="text" id="txtEmployee_DOJ" name="txtEmployee_DOJ" class="emp-input" />
                </div>
                <div class="emp-field">
                    <label class="emp-label">Resign Date</label>
                    <input type="text" id="txtEmployee_Resign" name="txtEmployee_Resign" autocomplete="off" class="emp-input" />
                </div>
            </div>
        </div>
    </div>

    <!-- ============ COMPENSATION CARD ============ -->
    <div class="emp-card">
        <div class="emp-card-header">
            <i class="fa fa-money"></i>
            <span>Compensation</span>
        </div>
        <div class="emp-card-body">
            <div class="emp-bento emp-bento--3">
                <div class="emp-field">
                    <label class="emp-label">Floor #</label>
                    <select id="ddlFloor" name="ddlFloor" class="emp-select"></select>
                </div>
                <div class="emp-field">
                    <label class="emp-label">Doctor Share</label>
                    <input type="text" id="txtDoctorShare" name="txtDoctorShare" autocomplete="off" class="emp-input" />
                </div>
                <div class="emp-field">
                    <label class="emp-label">Hospital Share</label>
                    <input type="text" id="txtHospital_Share" name="txtHospital_Share" class="emp-input" />
                </div>
                <div class="emp-field">
                    <label class="emp-label">Extension No</label>
                    <input type="text" id="Ext_txt" name="Ext_txt" class="emp-input" />
                </div>
                <div class="emp-field">
                    <label class="emp-label">Gross Pay</label>
                    <input type="text" id="txtGrossPay" name="txtGrossPay" autocomplete="off" class="emp-input" />
                </div>
                <div class="emp-field">
                    <label class="emp-label">Consultant Charges</label>
                    <input type="text" id="txtConsultant_Charges" name="txtConsultant_Charges" readonly autocomplete="off" class="emp-input emp-input--readonly" />
                </div>
            </div>
        </div>
    </div>

    </div>

    <!-- ============ ROW 3: ACCOUNT + MEDICAL ============ -->
    <div class="emp-cards-grid">

    <!-- ============ ACCOUNT & LOCATION CARD ============ -->
    <div class="emp-card">
            <div class="emp-card-header">
                <i class="fa fa-building"></i>
                <span>Account &amp; Location</span>
            </div>
            <div class="emp-card-body">
                <div class="emp-bento emp-bento--3">
                    <div class="emp-field">
                        <label class="emp-label">
                            GL Account
                            <span style="float:right; font-weight:normal; cursor:pointer;">
                                <input type="checkbox" id="chkmanual" name="chkmanual" style="vertical-align:middle; margin:0 3px 0 0; cursor:pointer;" />Manual
                            </span>
                        </label>
                        <select id="ddlAccount" name="ddlAccount" class="emp-select"></select>
                    </div>
                    <div class="emp-field">
                        <label class="emp-label">Building</label>
                        <select id="ddlDoctorBuilding" name="ddlDoctorBuilding" class="emp-select"></select>
                    </div>
                    <div class="emp-field">
                        <label class="emp-label">Users</label>
                        <select id="ddluser" name="ddluser" class="emp-select"></select>
                    </div>
                </div>
                <div class="emp-bento emp-bento--2">
                    <div class="emp-field">
                        <label class="emp-label">Address</label>
                        <textarea id="txtEmployee_Address" name="txtEmployee_Address" rows="2" class="emp-textarea"></textarea>
                    </div>
                    <div class="emp-field">
                        <label class="emp-label">Remarks</label>
                        <textarea id="txtRemarks" name="txtRemarks" rows="2" class="emp-textarea"></textarea>
                    </div>
                </div>
            </div>
        </div>

    <!-- ============ MEDICAL & MISC CARD ============ -->
    <div class="emp-card">
        <div class="emp-card-header">
            <i class="fa fa-medkit"></i>
            <span>Medical &amp; Miscellaneous</span>
        </div>
        <div class="emp-card-body">
            <div class="emp-bento emp-bento--3">
                <div class="emp-field">
                    <label class="emp-label">Qualification</label>
                    <input type="text" id="txtdoc_qualification" name="txtdoc_qualification" class="emp-input" />
                </div>
                <div class="emp-field">
                    <label class="emp-label">Dependent</label>
                    <input type="text" id="txtdependent" name="txtdependent" class="emp-input" />
                </div>
                <div class="emp-field">
                    <label class="emp-label">Policy</label>
                    <select id="ddlPolicy" name="ddlPolicy" class="emp-select">
                        <option value="">Please Select</option>
                    </select>
                </div>
                <div class="emp-field">
                    <label class="emp-label">NTN No.</label>
                    <input type="text" id="txtEmployee_NTN_No" name="txtEmployee_NTN_No" autocomplete="off" class="emp-input" />
                </div>
                <div class="emp-field">
                    <label class="emp-label">PMDC</label>
                    <input type="text" id="txtPMDC" name="txtPMDC" class="emp-input" />
                </div>
            </div>
        </div>
    </div>

    </div>

    <!-- ============ ROW 4: OFF DAYS & FLAGS (SINGLE CARD) ============ -->
    <div class="emp-cards-grid">

    <!-- ============ OFF DAYS & FLAGS CARD ============ -->
    <div class="emp-card">
        <div class="emp-card-header">
            <i class="fa fa-calendar-times-o"></i>
            <span>Off Days &amp; Flags</span>
        </div>
        <div class="emp-card-body">
            <div class="emp-check-group-title">
                <i class="fa fa-calendar"></i> Mark Days Off
            </div>
            <div class="emp-day-chips">
                <label class="emp-day-chip"><input type="checkbox" id="sun" name="sun" /> Sun</label>
                <label class="emp-day-chip"><input type="checkbox" id="mon" name="mon" /> Mon</label>
                <label class="emp-day-chip"><input type="checkbox" id="tue" name="tue" /> Tue</label>
                <label class="emp-day-chip"><input type="checkbox" id="wed" name="wed" /> Wed</label>
                <label class="emp-day-chip"><input type="checkbox" id="thur" name="thur" /> Thu</label>
                <label class="emp-day-chip"><input type="checkbox" id="fri" name="fri" /> Fri</label>
                <label class="emp-day-chip"><input type="checkbox" id="sat" name="sat" /> Sat</label>
            </div>

            <div class="emp-check-group-title" style="margin-top:10px;">
                <i class="fa fa-flag"></i> Employee Flags
            </div>
            <div class="emp-flag-grid">
                <label class="emp-flag-item">
                    <input type="checkbox" id="ChkDoctor" name="ChkDoctor" class="chkwdth" />
                    <span class="emp-flag-label">Doctor</span>
                </label>
                <label class="emp-flag-item">
                    <input type="checkbox" id="ChkVisting" name="ChkVisting" class="chkwdth" />
                    <span class="emp-flag-label">Visiting</span>
                </label>
                <label class="emp-flag-item">
                    <input type="checkbox" id="ChkEmployee" name="ChkEmployee" class="chkwdth" />
                    <span class="emp-flag-label">Employee</span>
                </label>
                <label class="emp-flag-item">
                    <input type="checkbox" id="ChkBlockCategory" name="ChkBlockCategory" class="chkwdth" />
                    <span class="emp-flag-label">Block Category</span>
                </label>
            </div>
        </div>
    </div>

    </div>

    <!-- ============ BUTTON ROW (TOP - unchanged design) ============ -->
    <div class="emp-actions row">
        <div class="col-lg-8">
            <div class="row">
                <div class="col-lg-2 col-md-4 col-sm-6">
                       <input type="button" class="btn btn-primry" onclick="saveData()" id="btnSave" value="Save" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" class="btn btn-gray" onclick="redirect()" id="btnBack" value="View" />
                </div>
            </div>
        </div>
     
        
    </div>

    <div style="display:none">
        <span id="lblMessage"></span>
    </div>

</div>

</asp:Content>
