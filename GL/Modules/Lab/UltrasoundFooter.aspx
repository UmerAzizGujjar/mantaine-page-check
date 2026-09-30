<%@ Page Language="C#"  MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="UltrasoundFooter.aspx.cs" Inherits="PMS.UltrasoundFooter" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

 <script type="text/javascript">
     $(document).ready(function () {
         FillDoctors();

         $('#btnSaveLab').click(function () {
             var Labfooter = CKEDITOR.instances.labFooter.getData();
             var LabfooterTwo = CKEDITOR.instances.labFooterTwo.getData();
             var DoctorName = $('#ddlDoctor option:selected').text();
             var DoctorId = $('#ddlDoctor').val();
             var TemplateName = $('#templateName').val();
             var dataToPass = JSON.stringify({
                 "Labfooter": Labfooter,
                 "LabfooterTwo": LabfooterTwo,
                 "DoctorName": DoctorName,
                 "DoctorId": DoctorId,
                 "TemplateName": TemplateName
             });
             $.ajax({
                 type: "POST",
                 url: "UltrasoundFooter.aspx/SaveLabFooter",
                 data: dataToPass,
                 contentType: "application/json; charset=utf-8",
                 dataType: "json",
                 success: function (data) {
                     if (data.d == 'Successfull') {
                         alert("Save Successfully ");
                     }
                 },
                 failure: function (response) {
                     alert("Not Successfull");
                 }
             });
             window.location.href = "UltraSoundfooterList.aspx";
         });
    

     });
     function FillDoctors() {
         var options = '<option value="0">Select Doctor</option>';

         // Using AJAX instead of PageMethods for better control
         $.ajax({
             type: "POST",
             url: "UltrasoundFooter.aspx/GetDoctors",
             contentType: "application/json; charset=utf-8",
             dataType: "json",
             success: function (response) {
                 var doctors = JSON.parse(response.d);
                 $.each(doctors, function (key, value) {
                     options += '<option value="' + value.Emp_ID + '" >' + value.Emp_Name + '</option>';
                 });
                 $('#ddlDoctor').html(options);
                 $('#ddlDoctor').select2();
             },
             error: function (error) {
                 console.log("Error loading doctors: " + error);
                 $('#ddlDoctor').html(options);
                 $('#ddlDoctor').select2();
             }

         });
         var id = '<%= Request.QueryString["id"] %>'
         if (id != "") {
             loadLabFooterTem(id)
             //loadLabFooter(id);
             //loadLabFooterTwo(id);
         }
     }
     function loadLabFooterTem(id) {
         PageMethods.LoadLabFooterTEmandid(id,function (data) {
             var res = JSON.parse(data);
             $('#templateName').val(res.TemplateName);
             $('#ddlDoctor').val(res.DoctorId).trigger('change');
         });
         loadLabFooter(id)
     }
     function loadLabFooter(id) {
         PageMethods.LoadLabFooter(id,function (data) {
             var res = JSON.parse(data);
             // Set footer
             $('#labFooter').text(res.DataValue_Description);
             CKEDITOR.instances.labFooter.setData(res.DataValue_Description);
         });
         loadLabFooterTwo(id)
     }
     function loadLabFooterTwo(id) {
         PageMethods.LoadLabFooterTwo(id,function (data) {
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
            <div class="row">

                <div class="col-lg-2">
                    <label>Doctor</label>
                    <select id="ddlDoctor">

                    </select>
                </div>
                
                <div class="col-lg-2">
                    <label>Template Name</label>
                    <input type="text" id="templateName" />
                </div>
            </div>
            <div class="row">
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
    </div>
    <div class="row" style="margin-top:1%">
        <div class="col-lg-1 col-md-4 col-sm-6">
    <input type="button" class="btn btn btn-primry"  value="Save" id="btnSaveLab"  />
        </div>
        </div>
</asp:Content>
