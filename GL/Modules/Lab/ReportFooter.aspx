<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ReportFooter.aspx.cs" Inherits="PMS.ReportFooter" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

 <script type="text/javascript">
     $(document).ready(function () {
     $('#btn_Save').click(function () {
         var Reportfooter = CKEDITOR.instances.editor.getData();
         var ReportfooterTow = CKEDITOR.instances.txtFooterTow.getData();
         var data = JSON.stringify({
             "Reportfooter": Reportfooter,
             "ReportfooterTow": ReportfooterTow,
         });
         $.ajax({
             type: "POST",
             url: "ReportFooter.aspx/Save",
             data: data,
             contentType: "application/json; charset=utf-8",
             dataType: "json",
             success: function (data) {
                 if (data.d == 'Successfull') {
                     alert("Save Successfully ");
                 }
             },
             failure: function (response) {
                 alert(response.d);
             }
         });

     });
     LoadFooter();
     loadFooterTow();
     });

     function LoadFooter() {
         PageMethods.LoadReportFooter(function (data) {
             var FooterTxT = JSON.parse(data);
             $('#editor').text(FooterTxT);
             CKEDITOR.instances.editor.setData(FooterTxT);
         });

     }
     function loadFooterTow() {
         PageMethods.LoadReportFooterTow(function (data) {
             var Footer = JSON.parse(data);
             $('#txtFooterTow').text(Footer);
             CKEDITOR.instances.txtFooterTow.setData(Footer);
         });

     }
         </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
     <legend>Patho Lab Footer</legend>
    <div class="ckeditor1">
        <textarea name="editor" id="editor" rows="10" cols="80"></textarea>
        <script type="text/javascript">
            CKEDITOR.replace('editor');
        </script>
    </div>
    <div class="ckeditor2">
        <textarea name="txtFooterTow" id="txtFooterTow" rows="10" cols="80"></textarea>
        <script type="text/javascript">
            CKEDITOR.replace('txtFooterTow');
        </script>
    </div>
    <div class="row" style="margin-top:1%">
        <div class="col-lg-1 col-md-4 col-sm-6">
    <input type="button" class="btn btn-primry"  value="Save" id="btn_Save"  />
        </div>
        </div>
</asp:Content>
