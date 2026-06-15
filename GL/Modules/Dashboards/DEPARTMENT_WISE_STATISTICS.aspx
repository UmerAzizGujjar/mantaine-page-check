<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DEPARTMENT_WISE_STATISTICS.aspx.cs" Inherits="PMS.DEPARTMENT_WISE_STATISTICS" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="js/select2.min.css" rel="stylesheet" />
    <script src="js/select2.min.js"></script>
    <script src="../../wwwroot/lib/apexcharts/apexchart.js"></script>
  <style>
      select{
          width:200px !important;
      }
  </style>
    <script>
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

            ChartQtyofDoc(date, date);


            $('#ddlDoctor').change(function () {
                debugger
                var dt = $('#StartDate').val();
                var dts = $('#EndDate').val();
                ChartQtyofDoc(dt, dts);

            });
        });
        function SearchDate() {
            debugger;
            var dt = $('#StartDate').val();
            var dts = $('#EndDate').val();

            ChartQtyofDoc(dt, dts);
        }
        function LoadDepartmenr() {
            $.ajax({
                type: "POST",
                url: "DEPARTMENT_WISE_STATISTICS.aspx/LoadDepartmenr",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    debugger;
                    var options = '<option value="All">Please Select </option>';
                    var Parsed_Data = JSON.parse(response.d);
                    $.each(Parsed_Data, function (key, value) {

                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlDoctor').html(options);
                    $("#ddlDoctor").select2();
                },
                failure: function (response) {
                    alert(response.d);
                }
            });

        }

        let chart;
        function ChartQtyofDoc(startdate, Enddate) {
            debugger;
            var txt_sdate = $('#StartDate').val();
            var txt_edate = $('#EndDate').val();
            var Doctor = $('#ddlDoctor').val();
            PageMethods.GetTotalDepartment(txt_sdate, txt_edate, Doctor, function (resp) {
                debugger;
                var data = JSON.parse(resp);
                var labels = [];
                var seriesPatientCount = [];
                var seriesNumDays = [];

                data.forEach(function (item) {
                    labels.push(item.Department);
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
        <h1 id="h1">DEPARTMENT WISE STATISTICS</h1>
    </div>
         <div class="row">
         <div class="col-md-2">
             <label>Department</label>
             <select id="ddlDoctor"></select>
         </div>

         <div class="col-md-2">
             <label>From Date:</label>
             <input type="text" id="StartDate" />
         </div>

         <div class="col-md-2" >
             <label>To Date:</label>
             <input type="text" id="EndDate" />
         </div>
         <div class="col-md-1" >
             <label></label>
             <input type="button" id="btnSearch" value="Search" class="btn btn-primry" onclick="SearchDate()" />
        </div>
     </div>

    <div class="row">
        <div class="col-lg-12">
            <div id="chartDepartmentStatistics" style="height: 420px; width: 100%;"></div>
        </div>
</div>
</asp:Content>
