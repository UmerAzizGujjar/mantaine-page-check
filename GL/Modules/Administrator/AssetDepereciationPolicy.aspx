<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AssetDepereciationPolicy.aspx.cs" Inherits="PMS.Modules.Administrator.AssetDepereciationPolicy" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <script type="text/javascript">

         $(document).ready(function () {





             $('#fiscalYearStart').datepicker({ dateFormat: 'dd M yy' });
             $('#fiscalYearEnd').datepicker({ dateFormat: 'dd M yy' });

             $('#saveBtn').click(function () {
                 var isMonthly = $('#monthlyRadio').is(':checked');
                 var isYearly = $('#yearlyRadio').is(':checked');
                 var fiscalStart = $('#fiscalYearStart').val();
                 var fiscalEnd = $('#fiscalYearEnd').val();
                 var btnsave = $("#saveBtn").val();
                 $.ajax({
                     type: "POST",
                     url: "AssetDepereciationPolicy.aspx/SavePolicy",
                     data: JSON.stringify({
                         isMonthly: isMonthly,
                         isYearly: isYearly,
                         fiscalStart: fiscalStart,
                         fiscalEnd: fiscalEnd,
                         btnsave: btnsave
                     }),
                     contentType: "application/json; charset=utf-8",
                     dataType: "json",
                     success: function (response) {
                         alert(response.d);
                         location.reload();
                     },
                     error: function (xhr, status, error) {
                         console.log("XHR:", xhr);
                         console.log("Status:", status);
                         console.log("Error:", error);
                         alert("Error: " + xhr.responseText);
                     }
                 });
             });

             GetPolicyRecord();
         });
         function GetPolicyRecord() {
             $.ajax({
                 type: "POST",
                 url: "AssetDepereciationPolicy.aspx/getRecords",
                 data: "",
                 contentType: "application/json; charset=utf-8",
                 dataType: "json",
                 success: function (response) {
                     var data = JSON.parse(response.d);
             

                     $("#monthlyRadio").prop('checked', data[0].Monthly);
                     $("#yearlyRadio").prop('checked', data[0].Yearly);
   
                     var formattedDatestart = $.datepicker.formatDate('dd M yy', new Date(parseInt(data[0].Fiscal_Year_Start.substring(6, 19))));
                     $("#fiscalYearStart").val(formattedDatestart);

                     var formattedDateEnd = $.datepicker.formatDate('dd M yy', new Date(parseInt(data[0].Fiscal_Year_End.substring(6, 19))));
                     $("#fiscalYearEnd").val(formattedDateEnd);


                     $("#saveBtn").val('Update');
                 


                  
                 },
                 error: function (xhr, status, error) {
                     console.error("Error loading record:", error);
                 }
             });
         }
     </script>



</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="row">
   <div class="col-md-1 d-flex align-items-center">
    <label class="d-flex align-items-center">
        <input type="radio" name="depreciationType" id="monthlyRadio" value="Monthly" /> Monthly
    </label>
</div>
<div class="col-md-1 d-flex align-items-center">
    <label class="d-flex align-items-center">
        <input type="radio" name="depreciationType" id="yearlyRadio" value="Yearly" /> Yearly
    </label>
</div>
   <div class="col-md-2">
       <label>Fiscal Year Start:</label>
       <input type="text" id="fiscalYearStart" class="form-control" />
   </div>
   <div class="col-md-2">
       <label>Fiscal Year End:</label>
       <input type="text" id="fiscalYearEnd" class="form-control" />
   </div>
   <div class="col-md-1 d-flex align-items-center">
       <label></label>
        <input type="button" id="saveBtn" value="Save" class="btn btn-primry" />
   </div>
</div>

</asp:Content>
