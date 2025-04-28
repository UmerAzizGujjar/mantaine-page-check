<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CEODashBorad.aspx.cs" Inherits="PMS.Modules.Dashboards.CEODashBorad" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">



    <script src="../../wwwroot/js/apexchart.js"></script>


    <style type="text/css">
        h3 {
            color: dodgerblue;
        }

        input {
            width: 105px !important;
            border-radius: 10px !important;
        }

            input[type="button"] {
                margin-top: 27px !important
            }

        #Box1 {
            width: 250px;
            height: 125px;
            border-radius: 30px !important
        }

        #Box2 {
            width: 250px;
            height: 125px;
            border-radius: 30px !important
        }

        #Box3 {
            width: 250px;
            height: 125px;
            border-radius: 30px !important
        }

            #Box1 h3, #Box2 h3, #Box3 h3 {
                color: #eee;
            }

        .l-bg-orange-dark {
            background: linear-gradient(to right, #8e0b4d, #9f10abf2) !important;
            color: #fff;
        }

        .l-bg-green-dark {
            background: linear-gradient(to right, #888, #555) !important;
            color: #fff;
        }

        .l-bg-blue-dark {
            background: linear-gradient(to right, #710d2b,#a2070f) !important;
            color: #fff;
        }

        #Paitent_Count_Row {
            height: 80px;
            margin-top: 20px;
        }

        .styling {
            text-align: center;
            font-size: 25px;
        }

        .border-right {
            border-left: 1px solid #0033ff;
        }

        .border {
            border-bottom: 1px solid #0b5398;
        }
    </style>
    <script type="text/javascript">
        $(document).ready(function () {
            var date = '<%= DateTime.Now%>';
         $("#startDate").datepicker({
             dateFormat: 'MM d,yy',
         }).attr('readonly', 'readonly');
         $("#EndDate").datepicker({
             dateFormat: 'MM d,yy',
         }).attr('readonly', 'readonly');
         date = moment(date).format('LL');
         $("#startDate").val(date);
         $("#EndDate").val(date);

         LoadTodayPatientsCount();
         LoadPatientsCount(date, date);
         LoadInvestigationCount(date, date)
         LoadPharmacyCount(date, date)
         LoadAreaWiseCount(date, date)
         LoadDialysisCount(date, date)
         LoadVitalsCount(date, date)
         LoadProcedureCount(date, date)
         LoadOverallSatisfaction(date, date)
     });
        function search() {
            var dt = $('#startDate').val();
            var dts = $('#EndDate').val();

            LoadPatientsCount(dt, dts);
            LoadAreaWiseCount(dt, dts);
            LoadDialysisCount(dt, dts);
            LoadProcedureCount(dt, dts);
            LoadVitalsCount(dt, dts);
            LoadInvestigationCount(dt, dts);
            LoadPharmacyCount(dt, dts);
            LoadOverallSatisfaction(dt, dts);
        }

        function LoadPatientsCount(startdate, Enddate) {
            var txt_sdate = startdate;
            var txt_edate = Enddate;
            $.ajax({
                type: "POST",
                url: "CEODashBorad.aspx/GetPatientsCount",
                data: JSON.stringify({
                    'txt_sdate': txt_sdate,
                    'txt_edate': txt_edate,
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (data) {
                    var parsedData = JSON.parse(data.d);
                    $('#lblTotalPatient').text(parsedData.TotalPatients || 0);
                    $('#lblFilterPatient').text(parsedData.Filter_Clinic || 0);
                    $('#lblDepartmentPatient').text(parsedData.Patient_Main_Category || 0);
                },
                error: function (xhr, status, error) {
                    console.error("Error occurred: " + status + " " + error);
                }
            });
        }
        function LoadDialysisCount(startdate, Enddate) {
            var txt_sdate = startdate;
            var txt_edate = Enddate;
            $.ajax({
                type: "POST",
                url: "CEODashBorad.aspx/GetDialysisPatientsCount",
                data: JSON.stringify({
                    'txt_sdate': txt_sdate,
                    'txt_edate': txt_edate,
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (data) {
                    var parsedData = JSON.parse(data.d);
                    console.log(parsedData);
                    $('#txtActiveDialysis').text(parsedData.Active || 0);
                    $('#txtTotalDialysis').text(parsedData.performed || 0);
                },
                error: function (xhr, status, error) {
                    console.error("Error occurred: " + status + " " + error);
                }
            });
        }
        function LoadInvestigationCount(startdate, Enddate) {
            var txt_sdate = startdate;
            var txt_edate = Enddate;
            PageMethods.GetInvestigationCount(txt_sdate, txt_edate, function (res) {
                debugger;
                var Investigations = JSON.parse(res);
                var rows = '';
                $('#tabInvestigation tbody').empty();
                $.each(Investigations, function (key, value) {
                    debugger;
                    rows += '<tr> <td>' + value.Department + ' </td><td> ' + value.TotalBillCount + ' </td><td> ' + value.TotalPerformCount + ' </td><td> ' + value.TotalBillAmount + ' </td></tr>';
                });
                $('#tabInvestigation tbody').append(rows);
            })
        }

        function LoadPharmacyCount(startdate, Enddate) {
            var txt_sdate = startdate;
            var txt_edate = Enddate;
            PageMethods.GetPharmacyCount(txt_sdate, txt_edate, function (res) {
                debugger;
                var Investigations = JSON.parse(res);
                var rows = '';
                $('#tabPharmacy tbody').empty();
                $.each(Investigations, function (key, value) {
                    debugger;
                    rows += '<tr> <td>' + value.CustomerType + ' </td><td> ' + value.TotalCount + ' </td><td> ' + value.TotalReceivedAmount + ' </td></tr>';
                });
                $('#tabPharmacy tbody').append(rows);
            })
        }
        function LoadVitalsCount(startdate, Enddate) {
            var txt_sdate = startdate;
            var txt_edate = Enddate;
            $.ajax({
                type: "POST",
                url: "CEODashBorad.aspx/GetVitalCount",
                data: JSON.stringify({
                    'txt_sdate': txt_sdate,
                    'txt_edate': txt_edate,
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (data) {
                    var parsedData = JSON.parse(data.d);
                    $('#txtVitals').text(parsedData.VitalCount || 0);
                },
                error: function (xhr, status, error) {
                    console.error("Error occurred: " + status + " " + error);
                }
            });
        }
        function LoadTodayPatientsCount() {

            $.ajax({
                type: "POST",
                url: "CEODashBorad.aspx/GetTodayPatientsCount",
                data: JSON.stringify({
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (data) {
                    var parsedData = JSON.parse(data.d);
                    $('#txttodayFC').text(parsedData.Filter_Clinic || 0);
                    $('#txtTodayCC').text(parsedData.Patient_Main_Category || 0);
                },
                error: function (xhr, status, error) {
                    console.error("Error occurred: " + status + " " + error);
                }
            });
        }

        let chart;
        function LoadAreaWiseCount(startdate, Enddate) {
            debugger;
            var txt_sdate = startdate
            var txt_edate = Enddate
            var Area_Count = [];
            PageMethods.GetAreaWisePatientsCount(txt_sdate, txt_edate, function (resp) {
                debugger;
                const data = JSON.parse(resp);
                const labels = data.map(item => item.Area_Name);
                const areaCounts = data.map(item => item.Counts);
                const barColors = [
                    '#1E90FF', '#FF7F50', '#32CD32', '#FFD700', '#FF69B4',
                    '#8A2BE2', '#00CED1', '#DC143C', '#00FA9A', '#FF8C00'
                ];

                if (chart) {
                    chart.destroy();
                }

                const options = {
                    series: [{
                        name: 'Area Wise Count',
                        data: areaCounts
                    }],
                    chart: {
                        type: 'bar',
                        height: 500
                    },
                    plotOptions: {
                        bar: {
                            horizontal: false,
                            columnWidth: '55%',
                            endingShape: 'rounded',
                            distributed: true
                        }
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
                        categories: labels,
                        labels: {
                            style: {
                                colors: barColors.slice(0, labels.length),
                                fontSize: '10px',
                                fontWeight: 600
                            }
                        }
                    },
                    yaxis: [{
                        title: {
                            text: 'Area Wise Count'
                        },
                        min: 0
                    }],
                    fill: {
                        opacity: 1,
                        colors: barColors.slice(0, labels.length)
                    },
                    colors: barColors.slice(0, labels.length),
                    tooltip: {
                        y: {
                            formatter: val => val
                        }
                    }
                };
                chart = new ApexCharts(document.querySelector("#chartAreaWiseStatistics"), options);
                chart.render();
            }, function (error) {
                alert(error.get_message());
            });
        }
        let chart_proc;
        function LoadProcedureCount(startdate, Enddate) {
            debugger;
            var txt_sdate = startdate
            var txt_edate = Enddate
            var Area_Count = [];
            PageMethods.GetProcdureCount(txt_sdate, txt_edate, function (resp) {
                debugger;
                const data = JSON.parse(resp);
                const labels = data.map(item => item.Item_Name);
                const ItemCounts = data.map(item => item.TotalCount);
                const barColors = [
                    '#1E90FF', '#FF7F50', '#32CD32', '#FFD700', '#FF69B4',
                    '#8A2BE2', '#00CED1', '#DC143C', '#00FA9A', '#FF8C00'
                ];

                if (chart_proc) {
                    chart_proc.destroy();
                }

                const options = {
                    series: [{
                        name: 'Procedure Count',
                        data: ItemCounts
                    }],
                    chart: {
                        type: 'bar',
                        height: 500
                    },
                    plotOptions: {
                        bar: {
                            horizontal: true,
                            columnWidth: '55%',
                            endingShape: 'rounded',
                            distributed: true
                        }
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
                        categories: labels,
                        labels: {
                            style: {
                                colors: barColors.slice(0, labels.length),
                                fontSize: '10px',
                                fontWeight: 600
                            }
                        }
                    },
                    yaxis: [{
                        title: {
                            text: 'Procedure Count'
                        },
                        min: 0
                    }],
                    fill: {
                        opacity: 1,
                        colors: barColors.slice(0, labels.length)
                    },
                    colors: barColors.slice(0, labels.length),
                    tooltip: {
                        y: {
                            formatter: val => val
                        }
                    }
                };
                chart_proc = new ApexCharts(document.querySelector("#chartProcdureStatistics"), options);
                chart_proc.render();
            }, function (error) {
                alert(error.get_message());
            });
        }


        let chart_Avg;

        function LoadOverallSatisfaction(startdate, Enddate) {
            debugger;
            var txt_sdate = startdate;
            var txt_edate = Enddate;

            PageMethods.GetGetOverallSatisfaction(txt_sdate, txt_edate, function (resp) {
                debugger;
                try {
                    const data = JSON.parse(resp);

                    // Ensure we have a numeric value for the average
                    const averageValue = parseFloat(data.OverallAverageSatisfaction) || 0;

                    // Convert to percentage (assuming 5 is max value)
                    const percentageValue = (averageValue / 5) * 100;

                    // Destroy previous chart if it exists
                    if (chart_Avg) {
                        chart_Avg.destroy();
                    }

                    var options = {
                        series: [percentageValue], // Single value array for radial bar
                        chart: {
                            type: 'radialBar',
                            height: 350,
                            offsetY: -20,
                        },
                        plotOptions: {
                            radialBar: {
                                startAngle: -135,
                                endAngle: 135,
                                hollow: {
                                    margin: 0,
                                    size: '70%',
                                },
                                track: {
                                    background: "#e7e7e7",
                                    strokeWidth: '97%',
                                    margin: 5,
                                    dropShadow: {
                                        enabled: true,
                                        top: 2,
                                        left: 0,
                                        color: '#444',
                                        opacity: 1,
                                        blur: 2
                                    }
                                },
                                dataLabels: {
                                    name: {
                                        offsetY: -10,
                                        color: '#333',
                                        fontSize: '13px'
                                    },
                                    value: {
                                        color: '#111',
                                        fontSize: '30px',
                                        show: true,
                                        formatter: function (val) {
                                            // Display the actual average value (1-5) instead of percentage
                                            return (val * 5 / 100).toFixed(1);
                                        }
                                    }
                                }
                            }
                        },
                        fill: {
                            type: 'gradient',
                            gradient: {
                                shade: 'dark',
                                shadeIntensity: 0.15,
                                inverseColors: false,
                                opacityFrom: 1,
                                opacityTo: 1,
                                stops: [0, 50, 65, 91]
                            },
                        },
                        stroke: {
                            dashArray: 4
                        },
                        labels: ['Average Satisfaction (1-5 scale)'],
                    };

                    chart_Avg = new ApexCharts(document.querySelector("#chartOverallSatisfaction"), options);
                    chart_Avg.render();

                } catch (e) {
                    console.error("Error parsing or displaying chart data:", e);
                    alert("Error loading chart data. Please check console for details.");
                }
            }, function (error) {
                alert("Error: " + error.get_message());
            });
        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="container">
        <div class="row">
            <div class="col-lg-4">
                <div class="row">
                    <h3>CEO Dashborad</h3>
                </div>
                <div class="row">
                    <div class="col-lg-4">
                        <label>Start Date</label>
                        <input type="text" id="startDate" />
                    </div>
                    <div class="col-lg-4">
                        <label>End Date</label>
                        <input type="text" id="EndDate" />
                    </div>
                    <div class="col-lg-4">
                        <input type="button" id="txtSearch" value=" Search" onclick="search()" />
                    </div>
                </div>
                <div class="row" id="Paitent_Count_Row">
                    <div class="col-lg-4 styling">
                        <div class="row">
                            <span id="lblTotalPatient" style="color: #8e0016"></span>
                        </div>
                        <div class="row">
                            <label style="color: #8e0016">Total Patients</label>
                        </div>
                    </div>
                    <div class="col-lg-4 styling border border-right">
                        <div class="row">
                            <span id="lblFilterPatient" style="color: #0f008e"></span>
                        </div>
                        <div class="row">
                            <label style="color: #0f008e">F C</label>
                        </div>
                    </div>
                    <div class="col-lg-4 styling border">
                        <div class="row">
                            <span id="lblDepartmentPatient" style="color: #5f008e"></span>
                        </div>
                        <div class="row">
                            <label style="color: #5f008e">CC</label>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <h4>Investigation</h4>
                    <table class="table table-hover table-striped table-bordered" id="tabInvestigation">
                        <thead id="ihead">
                            <tr>
                                <th>Department</th>
                                <th>Ordered</th>
                                <th>Performed</th>
                                <th>Net Amount</th>
                            </tr>
                        </thead>
                        <tbody id="ibody">
                        </tbody>
                    </table>
                </div>
                <div class="row">
                    <h4>Pharmacy</h4>
                    <table class="table table-hover table-striped table-bordered" id="tabPharmacy">
                        <thead id="ipharmacyhead">
                            <tr>
                                <th>Customer Type</th>
                                <th>Ordered</th>
                                <th>Net Amount</th>
                            </tr>
                        </thead>
                        <tbody id="ipharmacybody">
                        </tbody>
                    </table>
                </div>
                <div class="row">
                    <div class="col-lg-12">
                        <h4>Over All Customer Satisfaction</h4>
                        <div id="chartOverallSatisfaction" style="height: 420px; width: 100%;"></div>
                    </div>
                </div>

            </div>

            <div class="col-lg-8">
                <div class="row">
                    <div class="col-lg-4">
                        <div class="card l-bg-green-dark text-white" id="Box1">
                            <div class="card-header" style="height: 30px; text-align: center;">
                                <h3 id="Vitals" style="padding: 5px;">OPD Visits</h3>
                                <i class="fas fa-book-medical" style="position: relative; float: right; margin-top: -24px; margin-right: -6px; font-size: 18px;"></i>
                            </div>
                            <div class="card-body">

                                <div class="col-12" style="text-align: center; font-size: 25px !important;">
                                    <span id="txtVitals">0</span>
                                </div>

                            </div>

                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="card l-bg-orange-dark text-white" id="Box2">
                            <div class="card-header" style="height: 30px; text-align: center;">
                                <h3 id="Dialysis" style="padding: 5px;">Dialysis Sessions</h3>
                                <i class="fas fa-book-medical" style="position: relative; float: right; margin-top: -24px; margin-right: -6px; font-size: 18px;"></i>
                            </div>
                            <div class="card-body">

                                <div class="col-lg-6" style="text-align: center; font-size: 25px !important;">
                                    <span id="txtActiveDialysis">0</span>
                                    <h5>Active</h5>
                                </div>
                                <div class="col-lg-6" style="text-align: center; font-size: 25px !important; border-left: 1px solid;">
                                    <span id="txtTotalDialysis">0</span>
                                    <h5>Performed</h5>
                                </div>

                            </div>

                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="card l-bg-blue-dark text-white" id="Box3">
                            <div class="card-header" style="height: 30px; text-align: center;">
                                <h3 id="Dpt2" style="padding: 5px;">Today Satatus</h3>
                                <i class="fas fa-book-medical" style="position: relative; float: right; margin-top: -24px; margin-right: -6px; font-size: 18px;"></i>
                            </div>
                            <div class="card-body">

                                <div class="col-lg-6" style="text-align: center; font-size: 25px !important;">
                                    <span id="txttodayFC">0</span>
                                    <h5>FC</h5>
                                </div>
                                <div class="col-lg-6" style="text-align: center; font-size: 25px !important; border-left: 1px solid;">
                                    <span id="txtTodayCC">0</span>
                                    <h5>CC</h5>
                                </div>

                            </div>

                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-lg-12">
                        <div id="chartAreaWiseStatistics" style="height: 420px; width: 100%;"></div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-lg-12">
                        <div id="chartProcdureStatistics" style="height: 420px; width: 100%;"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
