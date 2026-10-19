<%@ Page EnableSessionState="ReadOnly" Language="C#"  MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="UltrasoundFooter.aspx.cs" Inherits="PMS.UltrasoundFooter" %>

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
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/ultrasound-footer.css" rel="stylesheet" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="uf-page">

        <!-- Title line: the master page puts the page title in the empty left side; the badges sit on the right -->
        <div class="pr-meta-bar">
            <div class="meta-left"></div>
            <div class="meta-right">
                <div class="uf-badge"><span class="uf-badge-label">Doctor</span><span class="uf-badge-value" id="badgeUfDoctor">---</span></div>
                <div class="uf-badge"><span class="uf-badge-label">Template</span><span class="uf-badge-value" id="badgeUfTemplate">---</span></div>
            </div>
        </div>

        <section class="uf-card">
            <h5 class="uf-card-title"><i class="fa fa-user-md"></i> Footer Template</h5>
            <div class="uf-grid">
                <div class="uf-field">
                    <label for="ddlDoctor">Doctor</label>
                    <select id="ddlDoctor" class="uf-input">
                    </select>
                </div>
                <div class="uf-field">
                    <label for="templateName">Template Name</label>
                    <input type="text" id="templateName" class="uf-input" />
                </div>
            </div>
        </section>

        <div class="uf-layout2">
            <section class="uf-card">
                <h5 class="uf-card-title"><i class="fa fa-file-text-o"></i> Footer (left)</h5>
                <div class="uf-editor">
                    <textarea name="labFooter" id="labFooter" rows="10" cols="80"></textarea>
                    <script type="text/javascript">
                        CKEDITOR.replace('labFooter');
                    </script>
                </div>
            </section>
            <section class="uf-card">
                <h5 class="uf-card-title"><i class="fa fa-file-text-o"></i> Footer (right)</h5>
                <div class="uf-editor">
                    <textarea name="labFooterTwo" id="labFooterTwo" rows="10" cols="80"></textarea>
                    <script type="text/javascript">
                        CKEDITOR.replace('labFooterTwo');
                    </script>
                </div>
            </section>
        </div>

        <div class="uf-actions">
            <div>
                <input type="button" class="btn btn btn-primry" value="Save" id="btnSaveLab" />
            </div>
        </div>
    </div>

    <script type="text/javascript">
        // title-line badges follow the form (the page script fills the fields in after loading)
        function syncFooterBadges() {
            var d = $('#ddlDoctor').val() && $('#ddlDoctor').val() !== '0' ? $.trim($('#ddlDoctor option:selected').text()) : '';
            $('#badgeUfDoctor').text(d || '---');
            $('#badgeUfTemplate').text($('#templateName').val() || '---');
        }
        $(function () {
            syncFooterBadges();
            setInterval(syncFooterBadges, 600);
        });
    </script>
</asp:Content>
