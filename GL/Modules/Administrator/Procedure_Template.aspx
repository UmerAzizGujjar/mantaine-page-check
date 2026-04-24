<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Procedure_Template.aspx.cs" Inherits="PMS.Modules.Administrator.Procedure_Template" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <script type="text/javascript">
         $(document).ready(function () {
             let isEditMode = false;
             let currentId = "";

           

             const urlParams = new URLSearchParams(window.location.search);
             const idParam = urlParams.get('ID');

             if (idParam) {
                 isEditMode = true;
                 currentId = idParam;
                 $('#btnSaveTemplate').val('Update').removeClass('btn btn-primry').addClass('btn btn-primry');

                 PageMethods.GetProcedureTemplate(parseInt(idParam), function (result) {
                     if (result) {
                         $('#txtTemplateName').val(result.TemplateName);
                         if (CKEDITOR.instances.txtTemplateContent) {
                             CKEDITOR.instances.txtTemplateContent.setData(result.FixValues);
                         }
                     } else {
                         Swal.fire({ icon: 'error', title: 'Not Found', text: 'Template not found!' });
                         setTimeout(() => window.location.href = 'Procedure_Template_list.aspx', 1500);
                     }
                 }, function (err) {
                     alert("Error loading template: " + (err.get_message ? err.get_message() : 'Unknown'));
                 });
             }




             if (typeof CKEDITOR !== 'undefined') {
                 CKEDITOR.replace('txtTemplateContent', { height: 300 });
             }
             $("#btnSaveTemplate").click(function () {
                 if (CKEDITOR.instances.txtTemplateContent) {
                     CKEDITOR.instances.txtTemplateContent.updateElement();
                 }

                 var name = $('#txtTemplateName').val().trim();
                 var content = CKEDITOR.instances.txtTemplateContent ? CKEDITOR.instances.txtTemplateContent.getData() : $('#txtTemplateContent').val();

                 if (name === "") {
                     Swal.fire({ icon: 'warning', title: 'Validation', text: 'Please enter template name' });
                     return;
                 }
                 if (content === "" || content === "<p>&nbsp;</p>") {
                     Swal.fire({ icon: 'warning', title: 'Validation', text: 'Please enter template content' });
                     return;
                 }

                 var procedureData = [{
                     ProcedureLevelID: isEditMode ? currentId : "",
                     TemplateName: name,
                     FixValues: content
                 }];

                 PageMethods.SaveProcedureTemplate(procedureData,
                     function (res) {
                         Swal.fire({
                             icon: 'success',
                             title: isEditMode ? 'Updated!' : 'Saved!',
                             text: isEditMode ? 'Template updated successfully' : 'Template saved successfully',
                             showConfirmButton: false,
                             timer: 2000,
                             customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' }
                         });
                         setTimeout(function () {
                             window.location.href = 'Procedure_Template_list.aspx';
                         }, 2000);
                     },
                     function (err) {
                         Swal.fire({ icon: 'error', title: 'Error', text: err.get_message ? err.get_message() : 'Operation failed' });
                     }
                 );
             });
         });
     </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
     <div class="container mt-4">
    <div class="card">
        <div class="card-body">
            <div class="row">
                <div class="col-lg-4 col-md-4 col-sm-6">
                    <label><strong>Template Name *</strong></label>
                    <input type="text" id="txtTemplateName" class="form-control" placeholder="Enter name..." />
                </div>
                <div class="col-lg-12 col-md-12 col-sm-12 mt-3">
                    <label><strong>Template *</strong></label>
                    <textarea id="txtTemplateContent" class="form-control"></textarea>
                </div>
                <div class="col-lg-2 mt-3">
                    <input type="button" id="btnSaveTemplate" class="btn btn-primry" value="Save"  style="margin-top:4px !important"/>
                </div>
                <div class="col-lg-2 mt-3">
                <input type="button" class="btn btn-gray " id="btnView" value="View" onclick="window.location = 'Procedure_Template_list.aspx'" style="margin-top:4px !important" />
                    </div>
            </div>
        </div>
    </div>
</div>
</asp:Content>
