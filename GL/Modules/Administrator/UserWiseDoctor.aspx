<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="UserWiseDoctor.aspx.cs" Inherits="PMS.Modules.Administrator.UserWiseDoctor" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

   <script type="text/javascript">
       var id = '<%= Request.QueryString["ID"] %>';

       $(document).ready(function () {
           FillUsers();
           LoadTemplates();
           $('#ddl_users').select2();
           $('#ddl_template').select2();

           if (id != '') {
               LoadDetail(id);
               $("#btn_Save").val('Update');
               $('#ddl_users').attr('disabled', 'disabled');
           }
       });

       function LoadTemplates() {
           var options = '<option value="0">Please Select</option>';
           PageMethods.LoadTemplates(function (result) {
               var templates = JSON.parse(result);
               $.each(templates, function (key, value) {
                   options += '<option value="' + value.TemplateValue + '">' + value.DataValue_Description + '</option>';
               });
               $('#ddl_template').html(options);
           }, function (error) {
               console.log("Error loading templates");
           });
       }

       function validateSave() {
           var table = $('#tblItemDescriptionDetail');
           var proceed = true;
           var main_type = $('#ddl_users').val();

           if (main_type == '0' || main_type == '') {
               $('#ddl_users').addClass('ErrorAlert');
           } else {
               $('#ddl_users').removeClass('ErrorAlert');
           }
           if ($('#tblItemDescriptionDetail tr').length == 0) {
               proceed = false;
               Swal.fire({
                   icon: 'error', title: 'Error!', text: 'Please Add Details', timer: 2000, showConfirmButton: false, customClass: {
                       popup: 'swal-big-popup',
                       title: 'swal-big-title',
                       htmlContainer: 'swal-big-text'
                   }
               });
               return proceed;
           }

           table.find('tr').each(function (key, value) {
               var tmplId = $(value).find('input[name=txt_template_id]').val();
               if (tmplId == "" || tmplId == "0") {
                   proceed = false;
                   Swal.fire({
                       icon: 'error', title: 'Error!', text: 'Please add Template', timer: 2000, showConfirmButton: false,
                       customClass: {
                           popup: 'swal-big-popup',
                           title: 'swal-big-title',
                           htmlContainer: 'swal-big-text'
                       }
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
                       '<td class="th_Sp_Color">' +
                       '<input type="text" name="txt_UserName" style="width: 100%;" readonly value="' + value.user_name + '" />' +
                       '</td>' +
                       '<td class="th_Sp_Color" style="display:none;"><input type="text" name="txt_template_id" value="' + value.Template_Id + '" /></td>' +
                       '<td class="th_Sp_Color">' +
                       '<input type="text" name="txt_template_display" style="width: 100%;" value="' + value.Template_Description + '" readonly/>' +
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
               AllItemDetail.push({ userid: userid, templateId: parseInt(tmplIdVal) });
           });

           $.ajax({
               type: "POST",
               contentType: "application/json; charset=utf-8",
               url: "UserWiseDoctor.aspx/SaveSegment",
               data: JSON.stringify({ userid: userid, btnSave: btnSave, EditId: idParam, AllItemDetail: AllItemDetail }),
               success: function (data) {
                   var returnedId = data.d;
                   if (returnedId == "-1") {
                       Swal.fire({
                           icon: 'error', title: 'Error!', text: 'User already exists', timer: 2000, showConfirmButton: false, customClass: {
                               popup: 'swal-big-popup',
                               title: 'swal-big-title',
                               htmlContainer: 'swal-big-text'
                           }
                       });
                   } else if (returnedId == "Error") {
                       Swal.fire({
                           icon: 'error', title: 'Error!', text: 'An error occurred while saving.', timer: 2000, showConfirmButton: false
                       });
                   } else {
                       Swal.fire({
                           icon: 'success',
                           title: 'Success!',
                           text: 'Data saved successfully',
                           showConfirmButton: false,
                           timer: 2500,
                           customClass: {
                               popup: 'swal-big-popup',
                               title: 'swal-big-title',
                               htmlContainer: 'swal-big-text'
                           }
                       });
                       window.location.href = "UserWiseDoctor.aspx";
                   }
               },
               error: function () { Swal.fire("Error", "An error occurred.", "error"); }
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

           if (user_id == "0" || user_id == "") {
               Swal.fire({
                   icon: 'error',
                   title: 'Error!',
                   text: 'Please Select User',
                   timer: 2000,
                   showConfirmButton: false,
                   customClass: {
                       popup: 'swal-big-popup',
                       title: 'swal-big-title',
                       htmlContainer: 'swal-big-text'
                   }
               });
               return;
           }

           if (template_id == "0" || template_id == "") {
               Swal.fire({
                   icon: 'error',
                   title: 'Error!',
                   text: 'Please Select Template',
                   timer: 2000,
                   showConfirmButton: false,
                   customClass: {
                       popup: 'swal-big-popup',
                       title: 'swal-big-title',
                       htmlContainer: 'swal-big-text'
                   }
               });
               return;
           }

           var exists = false;
           $('#tblItemDescriptionDetail tr').each(function () {
               if ($(this).find('input[name=txt_template_id]').val() == template_id) {
                   exists = true;
                   return false; 
               }
           });

           if (exists) {
               Swal.fire({
                   icon: 'warning',
                   title: 'Warning!',
                   text: 'Template already added to list',
                   timer: 2000,
                   showConfirmButton: false
               });
               return;
           }

           var rows = '<tr>' +
               '<td style="display:none;">' + user_id + '</td>' +
               '<td><input type="text" name="txt_UserName" style="width:100%;" readonly value="' + username + '" /></td>' +
               '<td style="display:none;"><input type="text" name="txt_template_id" value="' + template_id + '" /></td>' +
               '<td><input type="text" name="txt_template_display" style="width:100%;" readonly value="' + template_display + '" /></td>' +
               '<td><a href="#" onclick="Delete(this)"><i class="glyphicon glyphicon-trash" style="color:#f30a0a;"></i></a></td>' +
               '</tr>';
           $('#tblItemDescriptionDetail').append(rows);
           $('#ddl_users').attr('disabled', 'disabled');
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
                <label for="ddl_template">X-Ray Template</label>
                <select id="ddl_template" class="form-control"></select>
            </div>
            <div class="col-lg-1 col-md-4 col-sm-6">
                <input type="button" onclick="Addrow()" value="+" class="btn btn-primry" style="margin-top: 20px;" />
            </div>
        </div>
    </div>

    <div class="table-container">
        <div class="col-12">
            <table class="table Container" id="tblItemDescription" style="width:45%">
                <thead>
                    <tr>
                        <th style="display:none;"></th>
                        <th class="td_bcolor">Username</th>
                        <th class="td_bcolor">Template Name</th>
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
