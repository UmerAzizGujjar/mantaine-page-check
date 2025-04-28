<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ck.aspx.cs" Inherits="PMS.ck" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
   
    <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.3/js/select2.min.js"></script>
    
 <%--<script type="text/javascript"  src="//cdn.ckeditor.com/4.6.2/full/ckeditor.js"></script>--%>
    <script type="text/javascript" src="Scripts/jquery-1.11.1.js"></script>
  <%--  <script type="text/javascript" src="Scripts/ckeditor/config.js"></script>
    <script  type="text/javascript" src="Scripts/ckeditor/adapters/jquery.js"></script>
    <link rel="stylesheet" href="assets/css/bootstrap.min.css" />--%>
   <%-- <script type="text/javascript"  src="Scripts/bootstrap-wysihtml5.js"></script>
    <link href="Styles/bootstrap-wysihtml5.css" rel="stylesheet" />
        <script type="text/javascript" src="//cloud.tinymce.com/stable/tinymce.min.js"></script>--%>

      <script type="text/javascript">
          //tinymce.init({ selector: 'editor1' });
          //CKEDITOR.replace('editor1',
          //{
          //    language: 'he'
          //});
          
          // Replace the <textarea id="editor1"> with a CKEditor
          // instance, using default configuration.
          
            </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
  
            <textarea name="editor1" id="editor23" rows="10" cols="80">
                This is my textarea to be replaced with CKEditor.
            </textarea>
    <div class="widget-main no-padding">
												<div class="wysiwyg-editor" id="editor2"></div>
											</div>
          
      
</asp:Content>
