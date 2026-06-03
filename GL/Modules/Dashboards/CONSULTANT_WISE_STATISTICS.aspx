<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CONSULTANT_WISE_STATISTICS.aspx.cs" Inherits="PMS.CONSULTANT_WISE_STATISTICS" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
      <script src="../../wwwroot/THEME_TIBBIT/Scripts/jquery.canvasjs.min.js"  type="text/javascript"></script>

<link href="../../wwwroot/StandardTheme/CustomCSS/swalalert.css" rel="stylesheet" />
<script src="../../wwwroot/THEME_TIBBIT/js/apexchart.js" type="text/javascript"></script>
    <style>
    select{
        width:200px !important;
    }
    #ddlDoctorDropdown .dropdown-menu {
    width: 210px; 
}

#ddlDoctorDropdown .dropdown-menu li {
    padding: 5px; 
}

#ddlDoctorDropdown .dropdown-menu input#doctorSearch {
    margin-bottom: 10px;
}
</style>


  <script type="text/javascript">
      $(document).ready(function () {
          LoadDoctor();
          var date = '<%= DateTime.Now%>';
          $("#StartDate").datepicker({
              dateFormat: 'MM d,yy',

          }).attr('readonly', 'readonly');

          $("#EndDate").datepicker({
              dateFormat: 'MM d,yy',

          }).attr('readonly', 'readonly');

          date = moment(date).format('LL');
          $("#StartDate").val(date);
          $("#EndDate").val(date);

          ChartQtyofDoc(date, date);
          $('#ddlDoctor').on('change', 'input[type="checkbox"]', function () {
              var selectedValues = [];
              $('#ddlDoctor input[type="checkbox"]:checked').each(function () {
                  selectedValues.push($(this).val());
              });
              console.log("Selected Doctor IDs: " + selectedValues.join(', '));

          });
          $('#doctorSearch').on('keyup', function () {
              var searchText = $(this).val().toLowerCase();
              $('#ddlDoctor li').filter(function () {
                  $(this).toggle($(this).text().toLowerCase().indexOf(searchText) > -1);
              });
          });
          $(document).on('change', '#ddlDoctor input[type="checkbox"]', function () {
              $('#doctorSearch').val('');
              $('#ddlDoctor li').show();
          });

      });
      function SearchDate() {
          debugger;
          var startdate = $('#StartDate').val();
          var enddate = $('#EndDate').val();
          var selectedDoctors = getSelectedDoctors();
          ChartQtyofDoc(startdate, enddate, selectedDoctors);
      }

      function LoadDoctor() {
          $.ajax({
              type: "POST",
              url: "CONSULTANT_WISE_STATISTICS.aspx/LoadDoctor",
              contentType: "application/json; charset=utf-8",
              dataType: "json",
              async: false,
              success: function (response) {
                  debugger;
                  var options = '';
                  var Parsed_Data = JSON.parse(response.d);
                  $.each(Parsed_Data, function (key, value) {
                      options += '<li><input type="checkbox" value="' + value.Emp_ID + '"> ' + value.Emp_Name + '</label></li>';
                  });
                  $('#ddlDoctor').html(options);
              },
              failure: function (response) {
                  alert(response.d);
              }
          });
      }
      function getSelectedDoctors() {
          var selectedDoctors = [];
          $('#ddlDoctor input[type="checkbox"]:checked').each(function () {
              selectedDoctors.push($(this).val());
          });
          return selectedDoctors;
      }
      function formatDate(date) {
          return moment(date).format('YYYY-MM-DD HH:mm:ss');
      }


      let chart;
      function ChartQtyofDoc(startdate, enddate, doctorArray) {
          debugger;
          var txt_sdate = formatDate(startdate);
          var txt_edate = formatDate(enddate);


          if (!doctorArray || doctorArray.length === 0) {
              doctorArray = [];
          }


          var doctorArrayJson = JSON.stringify(doctorArray);

          PageMethods.GetTotalDoctor(txt_sdate, txt_edate, doctorArrayJson, function (resp) {
              debugger;
              var data = JSON.parse(resp);
              var labels = [];
              var seriesPatientCount = [];
              var seriesNumDays = [];

              data.forEach(function (item) {
                  labels.push(item.DoctorName);
                  seriesPatientCount.push(item.PatientCount);
                  seriesNumDays.push(item.NumberOfDays);
              });

              if (chart) {
                  chart.destroy();
              }

              var options = {
                  series: [{
                      name: 'Number Of Days',
                      data: seriesNumDays
                  },
                  {
                      name: 'Patient Count',
                      data: seriesPatientCount
                  }],
                  chart: {
                      type: 'bar',
                      height: 500
                  },
                  plotOptions: {
                      bar: {
                          horizontal: false,
                          columnWidth: '55%',
                          endingShape: 'rounded'
                      },
                  },
                  dataLabels: {
                      enabled: false
                  },
                  stroke: {
                      show: true,
                      width: 2,
                      colors: ['transparent']
                  },
                  xaxis: {
                      categories: labels
                  },
                  yaxis: [{
                      title: {
                          text: 'Number Of Days'
                      }
                  }, {
                      opposite: true,
                      title: {
                          text: 'Patient Count'
                      }
                  }],
                  fill: {
                      opacity: 1
                  },
                  tooltip: {
                      y: {
                          formatter: function (val) {
                              return val;
                          }
                      }
                  }
              };

              chart = new ApexCharts(document.querySelector("#chartDepartmentStatistics"), options);
              chart.render();
          }, function (error) {
              alert(error.get_message());
          });
      }


  </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        <div class="row">
        <h1 id="h1">CONSULTANT WISE STATISTICS</h1>
    </div>
    <br />
    <br />
         <div class="row" style="margin-top: 25px">
             <div class="col-md-4" >
                 <label></label>
              
                 <div id="ddlDoctorDropdown" class="dropdown">
      <button class="btn btn-lg btn btn-primry  dropdown-toggle" type="button" data-toggle="dropdown" >
          Please Select Doctor <span class="caret"></span>
      </button>
      <div class="dropdown-menu" style="width: 210px;">
          <div style="padding: 5px;">
              <input type="text" class="form-control" id="doctorSearch" placeholder="Search..." />
          </div>
          <ul id="ddlDoctor" style="max-height: 200px; overflow-y: auto; padding: 0;">
            
          </ul>
      </div>
  </div>


             </div>

         <div class="col-md-2" style="margin-left: -50px;">
             <label>From Date:</label>
             <input type="text" id="StartDate" style="border-radius: 5px!important" />
         </div>

         <div class="col-md-2" >
             <label>To Date:</label>
             <input type="text" id="EndDate" style="border-radius: 5px!important" />
         </div>

         <div class="col-md-2" style="padding-left:60px!important;" >
             <label></label>
             <input type="button" id="btnSearch" value="Search" onclick="SearchDate()"  class="btn btn-primry"/>
         </div>

     </div>

    <div class="row">
        <div class="col-lg-12">
            <div id="chartDepartmentStatistics" style="height: 420px; width: 100%;"></div>
        </div>
</div>
</asp:Content>
