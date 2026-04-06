<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="UserWiseDoctor.aspx.cs" Inherits="PMS.Modules.Administrator.UserWiseDoctor" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <script type="text/javascript">
       var id = '<%= Request.QueryString["ID"] %>';
       var currentDepartment = '';

       $(document).ready(function () {
           FillUsers();
           loadRadiologyDepartment();
           $('#ddl_users').select2();
           $('#ddl_template').select2();
           $('#ddlDepartment').select2();

           if (id != '') {
               LoadDetail(id);
               $("#btn_Save").val('Update');
               $('#ddl_users').attr('disabled', 'disabled');
           }

           $('#ddlDepartment').on('change', function () {
               var selectedDept = $(this).find('option:selected').text();
               currentDepartment = selectedDept;
               
               if (selectedDept != 'Please Select' && selectedDept != '0') {
                   LoadTemplatesByDepartment(selectedDept);
                   $('#ddl_template').prev('label').text(selectedDept + ' Template');
               } else {
                   $('#ddl_template').html('<option value="0">Please Select</option>');
                   $('#ddl_template').prev('label').text('Template');
               }
           });
       });

       function LoadTemplatesByDepartment(department) {
           var options = '<option value="0">Please Select</option>';
           PageMethods.LoadTemplatesByDepartment(department, function (result) {
               var templates = JSON.parse(result);
               $.each(templates, function (key, value) {
                   options += '<option value="' + value.TemplateValue + '">' + value.DataValue_Description + '</option>';
               });
               $('#ddl_template').html(options);
           }, function (error) {
               console.log("Error loading templates for department: " + department);
               Swal.fire({
                   icon: 'error',
                   title: 'Error!',
                   text: 'Error loading templates for selected department',
                   timer: 2000,
                   showConfirmButton: false
               });
           });
       }

       function loadRadiologyDepartment() {
           var options = '<option value="0">Please Select</option>';
           PageMethods.FillTestMainDepartment(function (result) {
               var templates = JSON.parse(result);
               $.each(templates, function (key, value) {
                   options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
               });
               $('#ddlDepartment').html(options);
           }, function (error) {
               console.log("Error loading departments");
           });
       }

       function validateSave() {
           var table = $('#tblItemDescriptionDetail');
           var proceed = true;
           var main_type = $('#ddl_users').val();

           if (main_type == '0' || main_type == '') {
               $('#ddl_users').addClass('ErrorAlert');
               proceed = false;
               Swal.fire({
                   icon: 'error', title: 'Error!', text: 'Please Select User', timer: 2000, showConfirmButton: false
               });
               return proceed;
           } else {
               $('#ddl_users').removeClass('ErrorAlert');
           }
           
           if ($('#tblItemDescriptionDetail tr').length == 0) {
               proceed = false;
               Swal.fire({
                   icon: 'error', title: 'Error!', text: 'Please Add Details', timer: 2000, showConfirmButton: false
               });
               return proceed;
           }

           table.find('tr').each(function (key, value) {
               var tmplId = $(value).find('input[name=txt_template_id]').val();
               var dept = $(value).find('input[name=txt_department]').val();
               
               if (tmplId == "" || tmplId == "0") {
                   proceed = false;
                   Swal.fire({
                       icon: 'error', title: 'Error!', text: 'Please add Template', timer: 2000, showConfirmButton: false
                   });
                   return false;
               }
               
               if (dept == "" || dept == "0") {
                   proceed = false;
                   Swal.fire({
                       icon: 'error', title: 'Error!', text: 'Department missing for template', timer: 2000, showConfirmButton: false
                   });
                   return false;
               }
           });
           return proceed;
       }

       function LoadDetail(id) {
           var rows = '';
           PageMethods.LoadDetail(id, function (res) {
               var result = JSON.parse(res);
               $.each(result, function (key, value) {
                   setTimeout(function () {
                       $("#ddl_users").val(value.User_Id).trigger('change').attr('disabled', 'disabled');
                   }, 1000);

                   rows +=
                       '<tr>' +
                       '<td class="th_Sp_Color" style="display:none;">' + value.User_Id + '</td>' +
                       '<td style="display:none;"><input type="text" name="txt_department" value="' + value.Department + '" /></td>' +
                       '<td class="th_Sp_Color">' +
                       '<input type="text" name="txt_UserName" style="width: 100%;" readonly value="' + value.user_name + '" />' +
                       '</td>' +
                       '<td class="th_Sp_Color" style="display:none;"><input type="text" name="txt_template_id" value="' + value.Template_Id + '" /></td>' +
                       '<td class="th_Sp_Color">' +
                       '<input type="text" name="txt_template_display" style="width: 100%;" value="' + value.Template_Description + '" readonly/>' +
                       '</td>' +
                       '<td class="th_Sp_Color">' +
                       '<input type="text" name="txt_department_display" style="width: 100%;" value="' + value.Department + '" readonly/>' +
                       '</td>' +
                       '<td><a href="#" onclick="Delete(this)"><i class="glyphicon glyphicon-trash" style="color:#f30a0a;"></i></a></td>' +
                       '</tr>';
               });
               $('#tblItemDescriptionDetail').append(rows);
           });
       }

       function Delete(row) {
           if (confirm("Are you sure you want to delete?")) {
               $(row).closest('tr').remove();
               
               if ($('#tblItemDescriptionDetail tr').length == 0) {
                   $('#ddl_users').removeAttr('disabled');
               }
           }
       }

       function SaveAllRecord() {
    if (!validateSave()) return;

    var idParam = id === "" ? 0 : parseInt(id);
    var btnSave = $('#btn_Save').val();
    var userid = $("#ddl_users").val();
    var AllItemDetail = [];

    $('#tblItemDescriptionDetail tr').each(function () {
        var tmplIdVal = $(this).find('input[name=txt_template_id]').val();
        var department = $(this).find('input[name=txt_department]').val();
        
        AllItemDetail.push({ 
            userid: userid, 
            templateId: tmplIdVal, 
            department: department
        });
    });

    $.ajax({
        type: "POST",
        contentType: "application/json; charset=utf-8",
        url: "UserWiseDoctor.aspx/SaveSegment",
        data: JSON.stringify({ userid: userid, btnSave: btnSave, EditId: idParam, AllItemDetail: AllItemDetail }),
        success: function (data) {
            var returnedId = data.d;
            
            if (returnedId == "DepartmentExists") {
                Swal.fire({
                    icon: 'warning',
                    title: 'Cannot Save!',
                    text: 'This user already has a template for this department. Only one template per department is allowed.',
                    confirmButtonText: 'OK'
                });
            } 
            else if (returnedId.indexOf("Error") >= 0) {
                Swal.fire({
                    icon: 'error', 
                    title: 'Error!', 
                    text: 'An error occurred while saving.', 
                    timer: 2000, 
                    showConfirmButton: false
                });
            } 

            else {
                Swal.fire({
                    icon: 'success',
                    title: 'Success!',
                    text: 'Data saved successfully',
                    showConfirmButton: false,
                    timer: 2500
                });
                window.location.href = "UserWiseDoctor.aspx";
            }
        },
        error: function () { 
            Swal.fire({
                icon: "error", 
                title: "Error!", 
                text: "An error occurred while processing your request.", 
                confirmButtonText: "OK"
            }); 
        }
    });
}

       function FillUsers() {
           var options = '<option value="0">Please Select</option>';
           PageMethods.FillUsers(function (result) {
               $.each(JSON.parse(result), function (key, value) {
                   options += '<option value="' + value.UserId + '">' + value.UserName + '</option>';
               });
               $('#ddl_users').html(options);
           });
       }

        function Addrow() {
            var user_id = $('#ddl_users').val();
            var username = $('#ddl_users :selected').text();
            var template_id = $('#ddl_template').val();
            var template_display = $('#ddl_template :selected').text();
            var department = $('#ddlDepartment').val();
            var department_display = $('#ddlDepartment :selected').text();

            if (user_id == "0" || user_id == "") {
                Swal.fire({
                    icon: 'error', title: 'Error!', text: 'Please Select User', timer: 2000, showConfirmButton: false
                });
                return;
            }

            if (department == "0" || department == "") {
                Swal.fire({
                    icon: 'error', title: 'Error!', text: 'Please Select Department', timer: 2000, showConfirmButton: false
                });
                return;
            }

            if (template_id == "0" || template_id == "") {
                Swal.fire({
                    icon: 'error', title: 'Error!', text: 'Please Select Template', timer: 2000, showConfirmButton: false
                });
                return;
            }

            // Check if this department is already added (only ONE template per department)
            var departmentExists = false;
            $('#tblItemDescriptionDetail tr').each(function () {
                var existingDept = $(this).find('input[name=txt_department]').val();

                if (existingDept == department) {
                    departmentExists = true;
                    return false;
                }
            });

            if (departmentExists) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Warning!',
                    text: 'This department already has a template assigned. Only one template per department is allowed.',
                    timer: 3000,
                    showConfirmButton: false
                });
                return;
            }

            var rows = '<tr>' +
                '<td style="display:none;">' + user_id + '</td>' +
                '<td style="display:none;"><input type="text" name="txt_department" value="' + department + '" /></td>' +
                '<td><input type="text" name="txt_UserName" style="width:100%;" readonly value="' + username + '" /></td>' +
                '<td style="display:none;"><input type="text" name="txt_template_id" value="' + template_id + '" /></td>' +
                '<td><input type="text" name="txt_template_display" style="width:100%;" readonly value="' + template_display + '" /></td>' +
                '<td><input type="text" name="txt_department_display" style="width:100%;" readonly value="' + department_display + '" /></td>' +
                '<td><a href="#" onclick="Delete(this)"><i class="glyphicon glyphicon-trash" style="color:#f30a0a;"></i></a></td>' +
                '</tr>';

            $('#tblItemDescriptionDetail').append(rows);
            $('#ddl_users').attr('disabled', 'disabled');

            $('#ddl_template').val('0').trigger('change');
        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
   <div class="mt-4">
        <div class="row mb-3">
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label for="ddl_users">User Name</label>
                <select id="ddl_users" class="form-control"></select>
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label for="ddlDepartment">Department</label>
                <select id="ddlDepartment" class="form-control"></select>
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label for="ddl_template">Template</label>
                <select id="ddl_template" class="form-control"></select>
            </div>
            <div class="col-lg-1 col-md-4 col-sm-6">
                <input type="button" onclick="Addrow()" value="+" class="btn btn-primry" style="margin-top: 20px;" />
            </div>
        </div>
    </div>

    <div class="table-container">
        <div class="col-12">
            <table class="table Container" id="tblItemDescription" style="width: 60%">
                <thead>
                    <tr>
                        <th style="display: none;"></th>
                        <th style="display: none;"></th>
                        <th class="td_bcolor">Username</th>
                        <th style="display: none;"></th>
                        <th class="td_bcolor">Template Name</th>
                        <th class="td_bcolor">Department</th>
                        <th class="td_bcolor">Actions</th>
                    </tr>
                </thead>
                <tbody id="tblItemDescriptionDetail"></tbody>
            </table>

            <div class="row mt-3">
                <div class="col-lg-8">
                    <div class="row">
                        <div class="col-lg-2">
                            <input type="button" class="btn btn-primry" id="btn_Save" value="Save" onclick="SaveAllRecord()" />
                        </div>
                        <div class="col-lg-2">
                            <input type="button" class="btn btn-primry" value="View" onclick="window.location='UserWiseDoctorList.aspx'" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
