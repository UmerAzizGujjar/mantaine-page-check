<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DashPatientsCount.aspx.cs" Inherits="PMS.Modules.Dashboards.DashPatientsCount" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <style type="text/css">
     #Box1 {
         width: 250px;
     }

     #Box2 {
         width: 250px;
     }

     select {
         width: 200px !important;
     }

     input {
         width: 200px !important;
     }

     #Box3 {
         width: 250px;
     }

     .h3, h3 {
         font-size: 15px;
         font-weight: 600;
     }

     #h1 {
         font-weight: 600;
         position: relative;
         margin-left: 38%;
         font-size: 37px;
         font-family: revert;
         color: #438eb9;
     }

     .l-bg-orange-dark {
         background: linear-gradient(to right, #032c7a, #1d78ddf2) !important;
         color: #fff;
     }

     .l-bg-cyan {
         background: linear-gradient(135deg, #289cf5, #84c0ec) !important;
         color: #fff;
     }

     .l-bg-green {
         background: linear-gradient(135deg, #23bdb8 0%, #43e794 100%) !important;
         color: #fff;
     }

     .l-bg-blue-dark {
         background: linear-gradient(to right, #06000a, #9100ff) !important;
         color: #fff;
     }

     .l-bg-cherry {
         background: linear-gradient(to right, #02443f, #1fefb6) !important;
         color: #fff;
     }

     .l-bg-green-dark {
         background: linear-gradient(to right, #602222, #b50716) !important;
         color: #fff;
     }
 </style>
       <script type="text/javascript">
       $(document).ready(function () {
           LoadDepartmenr();
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
           LoadDashboard(date, date);
           ChartQtyofDoc(date, date);
           $('#ddlDepartemt').change(function () {
               debugger
               var dt = $('#StartDate').val();
               var dts = $('#EndDate').val();
               LoadDashboard(dt, dts);
               ChartQtyofDoc(dt, dts);
           });
       })
       debugger;
       function SearchDate() {
           debugger;
           var dt = $('#StartDate').val();
           var dts = $('#EndDate').val();
           LoadDashboard(dt, dts);
           ChartQtyofDoc(dt, dts);
       }
       function LoadDepartmenr() {
           $.ajax({
               type: "POST",
               url: "DashPatientsCount.aspx/LoadDepartmenr",
               contentType: "application/json; charset=utf-8",
               dataType: "json",
               async: false,
               success: function (response) {
                   debugger;
                   var options = '<option value="0">Please Select </option>';
                   var Parsed_Data = JSON.parse(response.d);
                   $.each(Parsed_Data, function (key, value) {
                       options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                   });
                   $('#ddlDepartemt').html(options);
                   $("#ddlDepartemt").select2();
               },
               failure: function (response) {
                   alert(response.d);
               }
           });
       }
       function LoadDashboard(startdate, Enddate) {
           var txt_sdate = startdate;
           var txt_edate = Enddate;
           var Dep = $('#ddlDepartemt').val();
           $.ajax({
               type: "POST",
               url: "DashPatientsCount.aspx/ViewList",
               data: JSON.stringify({
                   'txt_sdate': txt_sdate,
                   'txt_edate': txt_edate,
               }),
               contentType: "application/json; charset=utf-8",
               dataType: "json",
               async: false,
               success: function (data) {
                   var parsedData = JSON.parse(data.d);
                   $('#txtTotalPatientCount').text(parsedData.Total_Patients || 0);
                   $('#txtRepeatedPatientCount').text(parsedData.Repeated_Patients || 0);
                   $('#txtWalkinPatientCount').text(parsedData.Non_Repeated_Patients || 0);
                   $('#txtTPAmount').text(parsedData.Total_Receipt_Amount || 0);
                   $('#txtRPAmount').text(parsedData.Repeated_Receipt_Amount || 0);
                   $('#txtWIPAmount').text(parsedData.Non_Repeated_Receipt_Amount || 0);
               },
               error: function (xhr, status, error) {
                   console.error("Error occurred: " + status + " " + error);
               }
           });
       }
       let chart;
       function ChartQtyofDoc(startdate, Enddate) {
           debugger;
           var txt_sdate = $('#StartDate').val();
           var txt_edate = $('#EndDate').val();
           var Dep = $('#ddlDepartemt').val();
           // Declare arrays for storing data
           var Total_Patients = [];
           var Repeated_Patients = [];
           var Non_Repeated_Patients = [];
           PageMethods.GetTotalDepartment(txt_sdate, txt_edate, Dep, function (resp) {
               debugger;
               var data = JSON.parse(resp);
               console.log(data)
               var labels = [];
               data.forEach(function (item) {
                   labels.push(item.Patient_Main_Category);
                   Total_Patients.push(item.Total_Patients);
                   Repeated_Patients.push(item.Repeated_Patients);
                   Non_Repeated_Patients.push(item.Non_Repeated_Patients);
               });
               if (chart) {
                   chart.destroy();
               }
               var options = {
                   series: [
                       {
                           name: 'Total Patient',
                           data: Total_Patients
                       },
                       {
                           name: 'Repeated Patients',
                           data: Repeated_Patients
                       },
                       {
                           name: 'New Patients',
                           data: Non_Repeated_Patients
                       }
                   ],
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
                       },
                       min: 0
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
        <h1 id="h1">OPD Patients & Turn Over</h1>
    </div>
    <br />
    <div class="row">
        <div class="col-lg-12">
            <div class="row">
                <div class="col-lg-12 " style="">
                    <div class="col-md-4">
                        <div class="card l-bg-orange-dark text-white" id="Box1">
                            <div class="card-header" style="height: 30px; background-color: #2222">
                                <h3 id="Dpt">New Patients</h3>
                                <i class="fas fa-thin  fa-sack-dollar" style="position: relative; float: right; margin-top: -25px; margin-right: 1px; font-size: 18px;"></i>
                            </div>
                            <div class="card-body">
                                <div class="col-12" style="text-align: center;">
                                    <h3>Total Patient
                                    </h3>
                                </div>
                                <div class="col-12" style="text-align: center; font-size: 15px !important;">
                                    <span id="txtWalkinPatientCount">0</span>
                                </div>
                            </div>
                            <div class="card-body">
                                <div class="col-12" style="text-align: center;">
                                    <h3>Total Amount
                                    </h3>
                                </div>
                                <div class="col-12" style="text-align: center; font-size: 15px !important;">
                                    <span id="txtWIPAmount">0</span>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4" style="padding-left: 72px!important;">
                        <div class="card l-bg-green-dark text-white" id="Box2">
                            <div class="card-header" style="height: 30px; background-color: #2222">
                                <h3 id="Dpt2" style="margin-left: -8px;">Repeated Patients</h3>
                                <i class="fas fa-book-medical" style="position: relative; float: right; margin-top: -24px; margin-right: -6px; font-size: 18px;"></i>
                            </div>
                            <div class="card-body">
                                <div class="col-12" style="text-align: center;">
                                    <h3>Total Patient
                                    </h3>
                                </div>
                                <div class="col-12" style="text-align: center; font-size: 15px !important;">
                                    <span id="txtRepeatedPatientCount">0</span>
                                </div>
                            </div>
                            <div class="card-body">
                                <div class="col-12" style="text-align: center;">
                                    <h3>Total Amount
                                    </h3>
                                </div>
                                <div class="col-12" style="text-align: center; font-size: 15px !important;">
                                    <span id="txtRPAmount">0</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-4" style="padding-left: 130px!important;">
                        <div class="card l-bg-cherry text-black" id="Box3">
                            <div class="card-header" style="height: 30px; background-color: #2222">
                                <h3 id="Dpt3">Total Patients</h3>
                                <i class="fas fa-hospital" style="position: relative; float: right; margin-top: -24px; margin-right: -3px; font-size: 18px;"></i>
                            </div>
                            <div class="card-body">
                                <div class="col-12" style="text-align: center;">
                                    <h3>Total Patient
                                    </h3>
                                </div>
                                <div class="col-12" style="text-align: center; font-size: 15px !important;">
                                    <span id="txtTotalPatientCount"></span>
                                </div>
                            </div>
                            <div class="card-body">
                                <div class="col-12" style="text-align: center;">
                                    <h3>Total Amount
                                    </h3>
                                </div>
                                <div class="col-12" style="text-align: center; font-size: 15px !important;">
                                    <span id="txtTPAmount">0</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row" style="margin-top: 25px; padding: 0 20px 0 10px;">
                <div class="col-md-3">
                    <label>Department</label>
                    <select id="ddlDepartemt"></select>
                </div>
                <div class="col-md-3">
                    <label>From Date:</label>
                    <input type="text" id="StartDate" style="border-radius: 5px!important" />
                </div>
                <div class="col-md-3">
                    <label>To Date:</label>
                    <input type="text" id="EndDate" style="border-radius: 5px!important" />
                </div>
                <div class="col-md-3" style="padding-left: 90px!important;">
                    <input type="button" id="btnSearch" value="Search" onclick="SearchDate()" style="margin-top: 25px; border-radius: 5px!important;" />
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <div id="chartDepartmentStatistics" style="height: 420px; width: 100%;"></div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>


