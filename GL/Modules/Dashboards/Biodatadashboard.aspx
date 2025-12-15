<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Biodatadashboard.aspx.cs" Inherits="PMS.Modules.Dashboards.Biodatadashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
       <style type="text/css">
       .table tr {
           border: 1px solid #D9E4E6;
           height:55px !important;
       }

           .table tr th {
               text-align: center;
                border: 1px solid #FFF;
background-color: #308665db;
color: white;
           }
                      .table tr td {
              text-align: center;
               border: 1px solid #009b05;

          }

   </style>
     <script type="text/javascript">

     $(document).ready(function () {

         var date = '<%= DateTime.Now%>';
         $("#txtsdate").datepicker({
             dateFormat: 'MM d,yy',

         }).attr('readonly', 'readonly');

         $("#txtedate").datepicker({
             dateFormat: 'MM d,yy',

         }).attr('readonly', 'readonly');

         date = moment(date).format('LL');
         $("#txtsdate").val(date);
         $("#txtedate").val(date);


         Load_DashBoard();
         fillCity();
         fillArea();
         fillgender();
         fillsymptoms();
         ChartQtyofDoc();
     });
     function fillCity() {
         var options = '<option value="0">Please Select</option>';
         PageMethods.GetCity(function (data) {
             $.each(JSON.parse(data), function (key, value) {
                 options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
             });
             $('#ddlcity').html(options);
             $('#ddlcity').select2();

         });
         return options;
     }
     function fillArea() {
         var options = '<option value="0">Please Select</option>';
         PageMethods.GetArea(function (data) {
             $.each(JSON.parse(data), function (key, value) {
                 options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
             });
             $('#ddlarea').html(options);
             $('#ddlarea').select2();

         });
         return options;
     }
     function fillgender() {
         var options = '<option value="0">Please Select</option>';
         PageMethods.GetGender(function (data) {
             $.each(JSON.parse(data), function (key, value) {
                 options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
             });
             $('#ddlgender').html(options);
             $('#ddlgender').select2();

         });
         return options;
     }
     function fillsymptoms() {
         var options = '<option value="0">Please Select</option>';
         PageMethods.Getsymptoms(function (data) {
             $.each(JSON.parse(data), function (key, value) {
                 options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
             });
             $('#ddlsymptom').html(options);
             $('#ddlsymptom').select2();

         });
         return options;
     }
     debugger;

     function Loadsearchboard() {
         Load_DashBoard();
         ChartQtyofDoc();
     }
     let chart;

     function ChartQtyofDoc() {
         debugger;
         var gender = $('#ddlgender').val() || '0';
         var area = $('#ddlarea').val() || '0';
         var city = $('#ddlcity').val() || '0';
         var symptoms = $('#ddlsymptom').val() || '0';
         var startdate = $('#txtsdate').val();
         var enddate = $('#txtedate').val();

         $('#loadingSpinner').show();  

         PageMethods.LoadPaiDashboard(startdate, enddate, gender, symptoms, city, area, function (resp) {
             debugger;
             var parsedData = JSON.parse(resp);
             var series = [];
             var label = [];

             var symptomCounts = parsedData.map(function (item) {
                 return item.symtom_count;  
             });

             var symptomLabels = parsedData.map(function (item) {
                 return item.symtom_name;  
             });

             var options = {
                 series: symptomCounts,
                 chart: {
                     type: 'donut',
                 },
                 labels: symptomLabels,
                 responsive: [{
                     breakpoint: 480,
                     options: {
                         chart: {
                             width: 200
                         },
                         legend: {
                             position: 'bottom'
                         }
                     }
                 }]
             };

             if (chart) {
                 chart.destroy();
             }

             chart = new ApexCharts(document.querySelector("#chartContainer_Qty"), options);
             chart.render().then(function () {
                 $('#loadingSpinner').hide(); 
             });
         });
     }
     function Load_DashBoard() {
         debugger;
         var gender = $('#ddlgender').val() || '0';
         var area = $('#ddlarea').val() || '0';
         var city = $('#ddlcity').val() || '0';
         var symptoms = $('#ddlsymptom').val() || '0';
         var startdate = $('#txtsdate').val();
         var enddate = $('#txtedate').val();

         
         $('#regdetail tbody').children('tr').remove();
         $('#patinfo tbody').children('tr').remove();
         $('#conInfo tbody').children('tr').remove();
         $('#biodata tbody').children('tr').remove();

         PageMethods.LoadDashboard(startdate, enddate, gender, symptoms, city, area, function (response) {
             debugger;
             var Services = JSON.parse(response);
             var rows1 = "";
             var rows2 = "";
             var rows3 = "";
             var rows4 = "";
             
           

             $.each(Services, function (key, value) {
                 var TrnsDate = new Date(parseInt(value.Created_time.substr(6)));
                 var datetime = moment(TrnsDate).format('LLLL');
                 rows1 += '<tr><td style="text-align:left;">' + value.mr_no_sequence + '</td><td style="text-align:left;">' + datetime + '</td></tr>';
                 rows2 += '<tr><td style="text-align:left;">' + value.Full_Name + '</td><td style="text-align:left;">' + value.Age_years + '</td><td style="text-align:left;">' + value.Gender + '</td></tr>';
                 rows3 += '<tr><td style="text-align:left;">' + value.Patient_Address + '</td><td style="text-align:left;">' + value.Mobile1 + '</td></tr>';
                 rows4 += '<tr><td style="text-align:left;">' + value.Symptoms + '</td></tr>';
             });

             
             $('#regdetail tbody').append(rows1);
             $('#patinfo tbody').append(rows2);
             $('#conInfo tbody').append(rows3);
             $('#biodata tbody').append(rows4);
         });
     }


  
     </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
       <div class="Container">
       <div class="row">
           <div class="col-lg-2">
               <label>
                   Gender:
               </label>
               <select id="ddlgender"></select>
           </div>
           <div class="col-lg-2">
               <label>
                   Area:
               </label>
               <select id="ddlarea"></select>
           </div>

           <div class="col-lg-2">
               <label>
                   City:
               </label>
               <select id="ddlcity"></select>
           </div>

           <div class="col-lg-2">
               <label>
                   Symptom:
               </label>
               <select id="ddlsymptom"></select>
           </div>


           <div class="col-lg-2">
               <label>
                   Start Date:
               </label>
               <input type="text" id="txtsdate" />
           </div>

           <div class="col-lg-2">
               <label>
                   End Date:
               </label>
               <input type="text" id="txtedate" />
           </div>

       </div>
       <div class="row" style="float: right; margin-top: 20px!important">
           <div class="col-lg-1">

               <input type="button" id="serach" value="Search" onclick="Loadsearchboard()" />
           </div>
       </div>

       <div class="row" style="margin-top: 60px; overflow: scroll!important; height: 700px !important;">
           <div class="col-lg-3">
               <h3>Registartion Details</h3>
               <table class="table" id="regdetail">
                   <thead>
                       <tr>
                           <th>MR No</th>
                           <th>Registartion Date</th>
                       </tr>
                   </thead>
                   <tbody></tbody>
               </table>
           </div>
           <div class="col-lg-3">
               <h3>Patient Information</h3>
               <table class="table" id="patinfo">
                   <thead>
                       <tr>
                           <th style="width: 110px;">Name</th>
                           <th>Age</th>
                           <th>Gender</th>
                       </tr>

                   </thead>
                   <tbody></tbody>
               </table>
           </div>
           <div class="col-lg-4">
               <h3>Contact Information</h3>
               <table class="table" id="conInfo">
                   <thead>
                       <tr>
                           <th>Address</th>
                           <th>Phone</th>

                       </tr>

                   </thead>
                   <tbody></tbody>
               </table>
           </div>
           <div class="col-lg-2">
               <h3>Bio Data</h3>
               <table class="table" id="biodata">
                   <thead>
                       <tr>
                           <th>Diagnosis</th>
                       </tr>
                   </thead>
                   <tbody></tbody>
               </table>
           </div>
       </div>

        <div class="row"  style="margin-top:60px;">
    <div class="col-lg-12">
        <%--<div id="chartContainer_Qty" style="height: 320px; width: 70%;"></div>--%>
        <div id="loadingSpinner" style="display: none;">Loading...</div>
        <div id="chartContainer_Qty" style="height: 320px; width: 70%;"></div>

    </div>
</div>

   </div>
</asp:Content>
