<%@ Page Language="C#"  MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="UltrasoundFooter.aspx.cs" Inherits="PMS.UltrasoundFooter" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

 <script type="text/javascript">
     $(document).ready(function () {
         $('#btnSaveLab').click(function () {
             debugger;
             var Labfooter = CKEDITOR.instances.labFooter.getData();
             var LabfooterTwo = CKEDITOR.instances.labFooterTwo.getData();
             var dataToPass = JSON.stringify({
                 "Labfooter": Labfooter,
                 "LabfooterTwo": LabfooterTwo
             });
             $.ajax({
                 type: "POST",
                 url: "UltrasoundFooter.aspx/SaveLabFooter",
                 data: dataToPass,
                 contentType: "application/json; charset=utf-8",
                 dataType: "json",
                 success: function (data) {
                     debugger;
                     if (data.d == 'Successfull') {
                         alert("Save Successfully ");
                     }
                 },
                 failure: function (response) {
                     alert("Not Successfull");
                 }
             });
         });
     loadLabFooter();
     loadLabFooterTwo();
     });

     function loadLabFooter() {
         PageMethods.LoadLabFooter(function (data) {
             debugger;
             var result = JSON.parse(data);
             $('#labFooter').text(result);
             CKEDITOR.instances.labFooter.setData(result);
         });
     }
     function loadLabFooterTwo() {
         PageMethods.LoadLabFooterTwo(function (data) {
             debugger;
             var Footertwo = JSON.parse(data);
             $('#labFooterTwo').text(Footertwo);
             CKEDITOR.instances.labFooterTwo.setData(Footertwo);
         });

     }
         </script>
        <style type="text/css">
            .ckeditor3 {
                width: 50%;
                display: flex;
                float: left;
            }
            .ckeditor4 {
                display: flex;
            }
        </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row" style="margin-top:20px">
        <div class="col">
            <legend>Ultrasound Footer</legend>
            <div class="ckeditor3">
                    <textarea name="labFooter" id="labFooter" rows="10" cols="80"></textarea>
                     <script type="text/javascript">
                         CKEDITOR.replace('labFooter');
              </script>
            </div>
            <div class="ckeditor4">
                    <textarea name="labFooterTwo" id="labFooterTwo" rows="10" cols="80"></textarea>
                     <script type="text/javascript">
                         CKEDITOR.replace('labFooterTwo');
              </script>
            </div>
        </div>
    </div>
    <div class="row" style="margin-top:1%">
        <div class="col-lg-1 col-md-4 col-sm-6">
    <input type="button" class="btn btn btn-primry"  value="Save" id="btnSaveLab"  />
        </div>
        </div>
</asp:Content>
