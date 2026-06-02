<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OPD_Utilization_Dashboard.aspx.cs" Inherits="PMS.Modules.Dashboards.OPD_Utilization_Dashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
         <script src="../../wwwroot/THEME_TIBBIT/Scripts/jquery.canvasjs.min.js"  type="text/javascript"></script>

    <link href="../../wwwroot/StandardTheme/css/CustomCss/swalalert.css" rel="stylesheet" />
    <script src="../../wwwroot/THEME_TIBBIT/js/apexchart.js" type="text/javascript"></script>

<style type="text/css">
        #Box1 {
            width: 250px;
            height: 70px;
        }

        #Box2 {
            width: 250px;
            height: 70px;
        }

        select {
            width: 200px !important;
        }



        #h1 {
            font-weight: 600;
            position: relative;        
            font-size: 37px;
            font-family: revert;
            color: #438eb9;
        }

        .l-bg-orange-dark {
            background: linear-gradient(to right, #032c7a, #1d78ddf2) !important;
            color: #fff;
        }
        .l-bg-green-dark {
            background: linear-gradient(to right, #602222, #b50716) !important;
            color: #fff;
        }
    </style>

    <script type="text/javascript">

        $(document).ready(function () {

            LoadDepartment()

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

            LoadRevenu(date, date);
            LoadDepartmentWiseChart(date, date);
            LoadDepartmentWisePieChart(date, date);

            $('#ddlDepartemt').change(function () {
                debugger
                var dt = $('#txtsdate').val();
                var dts = $('#txtedate').val();
                LoadDepartmentWiseChart(dt, dts);
                LoadDepartmentWisePieChart(dt, dts);

            });

        });

        function search() {
            var dt = $('#txtsdate').val();
            var dts = $('#txtedate').val();

            LoadRevenu(dt, dts);
            LoadDepartmentWiseChart(dt, dts);
            LoadDepartmentWisePieChart(dt, dts);
        }
        function LoadDepartment() {
            $.ajax({
                type: "POST",
                url: "OPD_Utilization_Dashboard.aspx/LoadDepartment",
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

        function LoadRevenu(startdate, Enddate) {
            var txt_sdate = startdate;
            var txt_edate = Enddate;
            $.ajax({
                type: "POST",
                url: "OPD_Utilization_Dashboard.aspx/GetTotalDepartmentRevenu",
                data: JSON.stringify({
                    'txt_sdate': txt_sdate,
                    'txt_edate': txt_edate,
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (data) {
                    var parsedData = JSON.parse(data.d);
                    $('#txttotalPatients').text(parsedData.Total_patients_Count || 0);
                    $('#txtTotal_Revenu').text(parsedData.Total_Revenu || 0);
                },
                error: function (xhr, status, error) {
                    console.error("Error occurred: " + status + " " + error);
                }
            });
        }

        let chart;
        function LoadDepartmentWiseChart(startdate, Enddate) {
            debugger;
            var txt_sdate = startdate
            var txt_edate = Enddate
            var Dep = $('#ddlDepartemt').val();
            var Total_Patients = [];
            var Total_Revenu = [];

            PageMethods.GetDepartmentWiseRevenu(txt_sdate, txt_edate, Dep, function (resp) {
                debugger;
                var data = JSON.parse(resp);
                var labels = [];

                data.forEach(function (item) {
                    labels.push(item.Patient_Main_Category);
                    Total_Patients.push(item.Total_patients_Count);
                    Total_Revenu.push(item.Total_Revenu);

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
                            name: 'Revenue',
                            data: Total_Revenu
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
                            text: 'Patient Count'
                        },
                        min: 0
                    }, {
                        opposite: true,
                        title: {
                            text: 'Revenue'
                        },
                        min: 0
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


        let piechart;

        function LoadDepartmentWisePieChart(startdate, Enddate) {
            debugger;
            var txt_sdate = startdate;
            var txt_edate = Enddate;
            var Dep = $('#ddlDepartemt').val();

            $('#loadingSpinner').show();

            PageMethods.GetDepartmentWiseRevenu(txt_sdate, txt_edate, Dep, function (resp) {
                debugger;
                console.log(resp);  // Check if valid data is returned
                var parsedData = JSON.parse(resp);
                console.log(parsedData);  // Check parsed data

                var series = [];
                var label = [];

                var Total_patients_Count = parsedData.map(function (item) {
                    return item.Total_patients_Count;
                });

                var Patient_Main_Category = parsedData.map(function (item) {
                    return item.Patient_Main_Category;
                });

                var options = {
                    series: Total_patients_Count,
                    chart: {
                        type: 'donut',  // Updated to "chart"
                    },
                    labels: Patient_Main_Category,
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

                if (piechart) {
                    piechart.destroy();  // Destroy previous chart if exists
                }

                piechart = new ApexCharts(document.querySelector("#chartContainer_Qty"), options);
                piechart.render().then(function () {
                    $('#loadingSpinner').hide();
                });
            });
        }

    </script>

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="row" style="text-align: center;">
        <h1 id="h1">OPD Utilization</h1>
    </div>
    <br />

    <div class="row">
        <div class="col-lg-12 ">
            <div class="col-md-4" style="margin-left: 200px !important;">
                <div class="card l-bg-orange-dark text-white" id="Box1">
                    <div class="card-header" style="height: 30px; background-color: #2222; text-align: center;">
                        <h3 id="Dpt" style="padding: 5px;">Total Patients</h3>
                        <i class="fas fa-thin  fa-sack-dollar" style="position: relative; float: right; margin-top: -25px; margin-right: 1px; font-size: 18px;"></i>
                    </div>

                    <div class="card-body">

                        <div class="col-12" style="text-align: center; font-size: 15px !important;">
                            <span id="txttotalPatients">0</span>
                        </div>

                    </div>
                </div>
            </div>
            <div class="col-md-4" style="padding-left: 72px!important;">

                <div class="card l-bg-green-dark text-white" id="Box2">
                    <div class="card-header" style="height: 30px; background-color: #2222; text-align: center;">
                        <h3 id="Dpt2" style="padding: 5px;">Total Revenue</h3>
                        <i class="fas fa-book-medical" style="position: relative; float: right; margin-top: -24px; margin-right: -6px; font-size: 18px;"></i>
                    </div>
                    <div class="card-body">

                        <div class="col-12" style="text-align: center; font-size: 15px !important;">
                            <span id="txtTotal_Revenu">0</span>
                        </div>

                    </div>

                </div>
            </div>

        </div>
    </div>

    <div class="row">
        <div class="col-md-2">
            <label>Department</label>
            <select id="ddlDepartemt"></select>
        </div>
        <div class="col-lg-2">
            <label> Start Date:</label>
            <input type="text" id="txtsdate" />
        </div>

        <div class="col-lg-2">
            <label>End Date:</label>
            <input type="text" id="txtedate" />
        </div>
        <div class="col-lg-2">
            <label></label>
            <input type="button" id="serach" value="Search" class="btn btn-primry" onclick="search()" />
        </div>
    </div>
    <div class="row">
        <div class="col-lg-12">
            <div id="chartDepartmentStatistics" style="height: 420px; width: 100%;"></div>
        </div>
    </div>
    <div class="row" style="margin-top: 60px;">
        <div class="col-lg-3 col-md-6 col-sm-12"></div>
        <div class="col-lg-6">
            <div id="loadingSpinner" style="display: none;">Loading...</div>
            <div id="chartContainer_Qty" style="height: 320px; width: 70%;"></div>
        </div>
    </div>
</asp:Content>
