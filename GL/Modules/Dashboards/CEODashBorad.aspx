<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CEODashBorad.aspx.cs" Inherits="PMS.Modules.Dashboards.CEODashBorad" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="../../wwwroot/lib/apexcharts/apexchart.js"></script>
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/CEODashboard.css" rel="stylesheet" />
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
        LoadAppointmentsOPDCount(date, date);
        LoadFootfallCount(date, date);
        LoadReferCount(date, date);
        LoadInvestigationCount(date, date)
        LoadPatientCountsAndNetAmount(date, date)
        LoadPharmacyCount(date, date)
        LoadAreaWiseCount(date, date)
        LoadTop5TestsByDepartment(date, date)
        LoadDialysisCount(date, date)
        LoadVitalsCount(date, date)
        LoadProcedureCount(date, date)
        ChartfDocPatientCount(date, date)
        LoadOverallSatisfaction(date, date)

    });
        function search() {
            var dt = $('#startDate').val();
            var dts = $('#EndDate').val();
            LoadFootfallCount(dt, dts);
            LoadReferCount(dt, dts);
            LoadPatientsCount(dt, dts);
            LoadAppointmentsOPDCount(dt, dts);
            LoadAreaWiseCount(dt, dts);
            LoadTop5TestsByDepartment(dt, dts);
            LoadDialysisCount(dt, dts);
            LoadProcedureCount(dt, dts);
            LoadVitalsCount(dt, dts);
            LoadInvestigationCount(dt, dts);
            LoadPatientCountsAndNetAmount(dt, dts);
            LoadPharmacyCount(dt, dts);
            ChartfDocPatientCount(dt, dts);
            ChartAppointmentCountByDoctor(dt, dts);
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
                    var total = parsedData.TotalPatients || 0;

                    $('#lblTotalPatient').text(total);

                    var filterCount = parsedData.Filter_Clinic || 0;
                    var deptCount = parsedData.Patient_Main_Category || 0;

                    var filterPercent = total > 0 ? ((filterCount / total) * 100).toFixed(2) : 0;
                    var deptPercent = total > 0 ? ((deptCount / total) * 100).toFixed(2) : 0;

                    $('#lblFilterPatient').text(filterCount + ' (' + filterPercent + '%)');
                    $('#lblDepartmentPatient').text(deptCount + ' (' + deptPercent + '%)');



                },
                error: function (xhr, status, error) {
                    console.error("Error occurred: " + status + " " + error);
                }
            });
        }
        function LoadAppointmentsOPDCount(startdate, Enddate) {
            var txt_sdate = startdate;
            var txt_edate = Enddate;
            $.ajax({
                type: "POST",
                url: "CEODashBorad.aspx/GetAppointmentsOPDCount",
                data: JSON.stringify({
                    'txt_sdate': txt_sdate,
                    'txt_edate': txt_edate,
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (data) {
                    var parsedData = JSON.parse(data.d);
                    // total comes from DOM
                    var total = parseInt($('#lblTotalPatient').text()) || 0;
                    var deptpats = parseInt($('#lblDepartmentPatient').text()) || 0;
                    var appointments = parseInt(parsedData.AppointmentsOPDCount) || 0;

                    // Walk-in = total - appointments (clamped at 0)
                    var walkin = deptpats >= appointments ? (deptpats - appointments) : 0;

                    // Percentages
                    var appPct = total > 0 ? ((appointments / deptpats) * 100).toFixed(2) : 0;
                    var walkPct = total > 0 ? ((walkin / deptpats) * 100).toFixed(2) : 0;

                    // Update UI
                    $('#lblAppPatient').text(appointments + ' (' + appPct + '%)');
                    $('#lblWalkInPatient').text(walkin + ' (' + walkPct + '%)');
                },
                error: function (xhr, status, error) {
                    console.error("Error occurred: " + status + " " + error);
                }
            });
        }
        function LoadReferCount(startdate, Enddate) {
            var txt_sdate = startdate;
            var txt_edate = Enddate;
            $.ajax({
                type: "POST",
                url: "CEODashBorad.aspx/GetReferCount",
                data: JSON.stringify({
                    'txt_sdate': txt_sdate,
                    'txt_edate': txt_edate,
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (data) {
                    var parsedData = JSON.parse(data.d);

                    var ReferCount = parsedData.ReferCount || 0;
                    var TotalCount = parsedData.TotalCount || 0;
                    var Percentage = parsedData.Percentage || 0;



                    $('#txtReferRate').text(ReferCount + ' (' + Percentage + '%)');



                },
                error: function (xhr, status, error) {
                    console.error("Error occurred: " + status + " " + error);
                }
            });
        }
        function LoadFootfallCount(startdate, Enddate) {
            var txt_sdate = startdate;
            var txt_edate = Enddate;
            $.ajax({
                type: "POST",
                url: "CEODashBorad.aspx/GetFootfallCount",
                data: JSON.stringify({
                    'txt_sdate': txt_sdate,
                    'txt_edate': txt_edate,
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (data) {
                    var parsedData = JSON.parse(data.d);
                    setTimeout(function () {
                        var total = parseInt($('#lblTotalPatient').text()) || 0;
                        var newPatients = parsedData.FootfallCount || 0;
                        var returning = total - newPatients;

                        // Calculate %
                        var newPct = total > 0 ? ((newPatients / total) * 100).toFixed(2) : 0;
                        var retPct = total > 0 ? ((returning / total) * 100).toFixed(2) : 0;

                        $('#txtFootfall').text(newPatients);
                        $('#lblNewPatient').text(newPatients + ' (' + newPct + '%)');
                        $('#lblReturningPatient').text((returning >= 0 ? returning : 0) + ' (' + retPct + '%)');
                    }, 500);



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
                var Investigations = JSON.parse(res);
                var rows = '';

                $('#tabInvestigation tbody').empty();

                $.each(Investigations, function (key, value) {
                    // For Physiotherapy: Ordered == Performed
                    if (value.Department === "Physiotherapy") {
                        value.TotalPerformCount = value.TotalBillCount;
                    }

                    rows += '<tr>'
                        + '<td>' + value.Department + '</td>'
                        + '<td>' + value.TotalBillCount + '</td>'
                        + '<td>' + value.TotalPerformCount + '</td>'
                        + '<td>' + value.TotalBillAmount + '</td>'
                        + '</tr>';
                });

                $('#tabInvestigation tbody').append(rows);
            });
        }



        function LoadPharmacyCount(startdate, Enddate) {
            var txt_sdate = startdate;
            var txt_edate = Enddate;
            PageMethods.GetPharmacyCount(txt_sdate, txt_edate, function (res) {
                var Investigations = JSON.parse(res);
                var rows = '';

                // calculate total ordered from all rows except "Total"
                var totalOrdered = 0;
                $.each(Investigations, function (key, value) {
                    if (value.CustomerType.toLowerCase() !== "total") {
                        totalOrdered += parseInt(value.TotalCount) || 0;
                    }
                });

                $('#tabPharmacy tbody').empty();

                $.each(Investigations, function (key, value) {
                    var count = parseInt(value.TotalCount) || 0;
                    var pct = 0;

                    if (value.CustomerType.toLowerCase() === "total") {
                        pct = 100; // force total row = 100%
                    } else {
                        pct = totalOrdered > 0 ? ((count / totalOrdered) * 100).toFixed(2) : 0;
                    }

                    rows += '<tr>' +
                        '<td>' + value.CustomerType + '</td>' +
                        '<td>' + count + '</td>' +
                        '<td>' + value.TotalReceivedAmount + '</td>' +
                        '<td>' + pct + '%</td>' +
                        '</tr>';
                });

                $('#tabPharmacy tbody').append(rows);
            });
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
            var txt_sdate = startdate
            var txt_edate = Enddate
            var Area_Count = [];
            PageMethods.GetAreaWisePatientsCount(txt_sdate, txt_edate, function (resp) {
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
        let departmentCharts = [];

        function LoadTop5TestsByDepartment(startdate, enddate) {
            var txt_sdate = startdate;
            var txt_edate = enddate;

            // Show loading indicator
            const container = document.querySelector("#topTestsChartsContainer");
            container.innerHTML = '<div class="text-center py-5"><div class="spinner-border text-primary" role="status"><span class="visually-hidden">Loading...</span></div><p class="mt-2">Loading department data...</p></div>';

            PageMethods.GetTop5TestsByDepartment(txt_sdate, txt_edate, function (resp) {
                try {
                    const data = JSON.parse(resp);

                    // Clear previous charts
                    departmentCharts.forEach(chart => {
                        if (chart) chart.destroy();
                    });
                    departmentCharts = [];

                    container.innerHTML = '';

                    if (data.length === 0) {
                        container.innerHTML = `
                <div class="col-12">
                    <div class="alert alert-info text-center">
                        <i class="fas fa-info-circle me-2"></i>
                        No test data found for the selected date range.
                    </div>
                </div>`;
                        return;
                    }

                    // Create a single row for all 5 charts
                    const chartsRow = document.createElement('div');
                    chartsRow.className = 'row';
                    container.appendChild(chartsRow);

                    // Create charts for each department
                    data.forEach((deptData, index) => {
                        const col = document.createElement('div');
                        col.className = 'col-xl-2 col-lg-4 col-md-6 col-sm-12 mb-4';

                        const card = document.createElement('div');
                        card.className = 'card h-100 shadow-sm';

                        const cardHeader = document.createElement('div');
                        cardHeader.className = 'card-header bg-primary text-white text-center';
                        cardHeader.innerHTML = `<h6 class="mb-0">${deptData.Department}</h6>`;

                        const cardBody = document.createElement('div');
                        cardBody.className = 'card-body p-2';

                        const chartDiv = document.createElement('div');
                        chartDiv.id = `chart-${deptData.Department.replace(/\s+/g, '-')}-${index}`;
                        chartDiv.style.minHeight = '300px';

                        cardBody.appendChild(chartDiv);
                        card.appendChild(cardHeader);
                        card.appendChild(cardBody);
                        col.appendChild(card);
                        chartsRow.appendChild(col);

                        // Prepare chart data
                        // Prepare chart data
                        const labels = deptData.Tests.map(test =>
                            test.TestName.length > 15 ? test.TestName.substring(0, 15) + '...' : test.TestName
                        );
                        const amounts = deptData.Tests.map(test => test.TotalAmount);
                        const counts = deptData.Tests.map(test => test.TestCount);

                        // Different color palette for each department
                        const departmentColors = [
                            ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FECA57'],
                            ['#6A89CC', '#F8C291', '#82CCDD', '#B8E994', '#E55039'],
                            ['#D980FA', '#FDA7DF', '#ED4C67', '#A3CB38', '#1289A7'],
                            ['#FFC312', '#C4E538', '#12CBC4', '#FDA7DF', '#ED4C67'],
                            ['#9980FA', '#833471', '#0652DD', '#EA2027', '#009432']
                        ];
                        const colors = departmentColors[index % departmentColors.length];

                        // Create chart
                        const options = {
                            series: [{
                                name: 'Test Count',
                                data: counts   // ✅ use count for bars
                            }],
                            chart: {
                                type: 'bar',
                                height: 280,
                                toolbar: { show: false }
                            },
                            plotOptions: {
                                bar: {
                                    horizontal: false,
                                    columnWidth: '50%',
                                    endingShape: 'rounded',
                                    distributed: true
                                }
                            },
                            dataLabels: {
                                enabled: true,
                                formatter: function (val) {
                                    return Math.round(val).toLocaleString(); // show counts on bars
                                },
                                style: {
                                    fontSize: '10px',
                                    fontWeight: 'bold',
                                    colors: ['#000']
                                },
                                offsetY: -5
                            },
                            stroke: {
                                show: true,
                                width: 2,
                                colors: ['transparent']
                            },
                            xaxis: {
                                categories: labels,
                                labels: {
                                    style: { fontSize: '9px', fontWeight: '600' },
                                    rotate: -45
                                }
                            },
                            yaxis: {
                                labels: {
                                    formatter: function (val) {
                                        return Math.round(val).toLocaleString(); // y-axis shows counts
                                    }
                                }
                            },
                            fill: { opacity: 1, colors: colors },
                            colors: colors,
                            tooltip: {
                                y: {
                                    formatter: function (val, opts) {
                                        const index = opts.dataPointIndex;
                                        return `Count: ${val.toLocaleString()} | Rs. ${amounts[index].toLocaleString()}`;
                                    }
                                }
                            }
                            // ❌ removed annotations for total tests
                        };


                        const chart = new ApexCharts(document.querySelector(`#chart-${deptData.Department.replace(/\s+/g, '-')}-${index}`), options);
                        chart.render();
                        departmentCharts.push(chart);
                    });

                } catch (error) {
                    console.error('Error parsing response:', error);
                    container.innerHTML = `
            <div class="col-12">
                <div class="alert alert-danger text-center">
                    <i class="fas fa-exclamation-triangle me-2"></i>
                    Error loading data. Please try again.
                </div>
            </div>`;
                }

            }, function (error) {
                console.error('Error loading top tests:', error);
                container.innerHTML = `
        <div class="col-12">
            <div class="alert alert-danger text-center">
                <i class="fas fa-exclamation-triangle me-2"></i>
                Error loading department data.
            </div>
        </div>`;
            });
        }
        let chart_proc;
        function LoadProcedureCount(startdate, Enddate) {
            var txt_sdate = startdate
            var txt_edate = Enddate
            var Area_Count = [];
            PageMethods.GetProcdureCount(txt_sdate, txt_edate, function (resp) {
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

        let Docchart;
        function ChartfDocPatientCount(startdate, Enddate) {
            var txt_sdate = startdate;
            var txt_edate = Enddate;

            PageMethods.GetDocPatientCount(txt_sdate, txt_edate, function (resp) {
                var parsedData = JSON.parse(resp);
                var series = [];
                var label = [];
                var PatientCount = parsedData.map(function (item) {
                    return item.Total_Count;
                });

                var DoctorName = parsedData.map(function (item) {
                    return item.Doctor_Name;
                });

                var options = {
                    series: PatientCount,
                    chart: {
                        type: 'donut',
                    },
                    labels: DoctorName,
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
                if (Docchart) {
                    Docchart.destroy();
                }
                Docchart = new ApexCharts(document.querySelector("#chartGetDocPatientCount"), options);
                Docchart.render();

            });
        }
        let AppointmentChart;

        function ChartAppointmentCountByDoctor(startdate, Enddate) {


            function formatDate(str) {
                let d = new Date(str);   // convert string → Date
                let month = ("0" + (d.getMonth() + 1)).slice(-2);
                let day = ("0" + d.getDate()).slice(-2);
                return d.getFullYear() + "-" + month + "-" + day;
            }

            PageMethods.GetAppointmentCountByDoctor(formatDate(startdate), formatDate(Enddate), function (resp) {
                try {
                    var parsedData = JSON.parse(resp);

                    // Clear any previous error messages
                    document.querySelector("#chartGetDocAppointmentsCount").innerHTML = "";

                    if (parsedData.Error) {
                        console.error("Error:", parsedData.Error);
                        // Don't show alert, just log to console
                        document.querySelector("#chartGetDocAppointmentsCount").innerHTML =
                            "<div class='no-data'>Unable to load appointment data</div>";
                        return;
                    }

                    if (!parsedData || parsedData.length === 0) {
                        console.warn("No appointment data found for the selected date range");
                        document.querySelector("#chartGetDocAppointmentsCount").innerHTML =
                            "<div class='no-data'>No appointments found for the selected period</div>";
                        return;
                    }

                    var appointmentCounts = parsedData.map(function (item) {
                        return item.Appointment_Count;
                    });

                    var doctorNames = parsedData.map(function (item) {
                        return item.Doctor_Name;
                    });

                    var totalAppointments = appointmentCounts.reduce((a, b) => a + b, 0);

                    // If total appointments is 0, show message instead of chart
                    if (totalAppointments === 0) {
                        document.querySelector("#chartGetDocAppointmentsCount").innerHTML =
                            "<div class='no-data'>No appointments found for the selected period</div>";
                        return;
                    }

                    var options = {
                        series: appointmentCounts,
                        chart: {
                            type: 'donut',
                            height: 400,
                            animations: {
                                enabled: true
                            }
                        },
                        labels: doctorNames,
                        colors: ['#008FFB', '#00E396', '#FEB019', '#FF4560', '#775DD0',
                            '#546E7A', '#26a69a', '#D10CE8', '#FF9F43', '#546E7A'],
                        responsive: [{
                            breakpoint: 480,
                            options: {
                                chart: {
                                    width: 300
                                },
                                legend: {
                                    position: 'bottom',
                                    fontSize: '12px'
                                }
                            }
                        }],
                        plotOptions: {
                            pie: {
                                donut: {
                                    size: '65%',
                                    labels: {
                                        show: true,
                                        total: {
                                            show: true,
                                            label: 'Total Appointments',
                                            color: '#373d3f',
                                            fontSize: '16px',
                                            formatter: function (w) {
                                                return totalAppointments;
                                            }
                                        },
                                        value: {
                                            fontSize: '15px',
                                            fontWeight: 'bold',
                                            formatter: function (val) {
                                                // Show only percentage, not the count
                                                return Math.round((val / totalAppointments) * 100) + '%';
                                            }
                                        }
                                    }
                                }
                            }
                        },
                        legend: {
                            position: 'right',
                            horizontalAlign: 'center',
                            fontSize: '10px',
                            markers: {
                                width: 12,
                                height: 12
                            },
                            formatter: function (seriesName, opts) {
                                // Show doctor name with count in legend only
                                return seriesName + ' - ' + appointmentCounts[opts.seriesIndex];
                            }
                        },
                        dataLabels: {
                            enabled: true,
                            formatter: function (val, opts) {
                                // Show only percentage in the pie slices
                                return Math.round(val) + '%';
                            },
                            style: {
                                fontSize: '12px',
                                fontWeight: 'bold',
                                colors: ['#fff']
                            },
                            dropShadow: {
                                enabled: true,
                                top: 1,
                                left: 1,
                                blur: 2,
                                opacity: 0.8
                            }
                        },
                        tooltip: {
                            y: {
                                formatter: function (value) {
                                    var percentage = ((value / totalAppointments) * 100).toFixed(1);
                                    return value + ' appointments (' + percentage + '%)';
                                }
                            }
                        }
                    };

                    if (AppointmentChart) {
                        AppointmentChart.destroy();
                    }

                    AppointmentChart = new ApexCharts(document.querySelector("#chartGetDocAppointmentsCount"), options);
                    AppointmentChart.render();

                } catch (error) {
                    console.error("Error parsing response:", error, resp);
                    document.querySelector("#chartGetDocAppointmentsCount").innerHTML =
                        "<div class='no-data'>Error loading chart data</div>";
                }
            });
        }

        function LoadPatientCountsAndNetAmount(startdate, Enddate) {
            var txt_sdate = startdate;
            var txt_edate = Enddate;
            PageMethods.GetPatientCountsAndNetAmount(txt_sdate, txt_edate, function (res) {
                var Investigations = JSON.parse(res);
                var rows = '';
                $('#tabPatientCount tbody').empty();
                $.each(Investigations, function (key, value) {
                    rows += '<tr> <td>' + value.Category + ' </td><td> ' + value.Total_Count + ' </td><td> ' + value.Card_Receipt_Amount + ' </td><td> ' + value.Receipt_Amount + ' </td></tr>';
                });
                $('#tabPatientCount tbody').append(rows);
            })
        }


        let chart_Avg;

        function LoadOverallSatisfaction(startdate, Enddate) {
            var txt_sdate = startdate;
            var txt_edate = Enddate;

            PageMethods.GetGetOverallSatisfaction(txt_sdate, txt_edate, function (resp) {
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
                        <input type="button" id="txtSearch" class="btn btn-primry" value=" Search" onclick="search()" />
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
                <div class="row" id="Paitent_Count_Row2">
                    <div class="col-lg-4 styling">
                    </div>
                    <div class="col-lg-4 styling border border-right">
                        <div class="row">
                            <span id="lblAppPatient" style="color: #0f008e"></span>
                        </div>
                        <div class="row">
                            <label style="color: #0f008e">Appointments</label>
                        </div>
                    </div>
                    <div class="col-lg-4 styling border">
                        <div class="row">
                            <span id="lblWalkInPatient" style="color: #5f008e"></span>
                        </div>
                        <div class="row">
                            <label style="color: #5f008e">Walk-In</label>
                        </div>
                    </div>
                </div>
                <div class="row" id="Paitent_Count_Row3">
    <div class="col-lg-4 styling">
    </div>
    <div class="col-lg-4 styling border border-right">
        <div class="row">
            <span id="lblNewPatient" style="color: #0f008e"></span>
        </div>
        <div class="row">
            <label style="color: #0f008e">New</label>
        </div>
    </div>
    <div class="col-lg-4 styling border">
        <div class="row">
            <span id="lblReturningPatient" style="color: #5f008e"></span>
        </div>
        <div class="row">
            <label style="color: #5f008e">Returning</label>
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
                    <h4>Patients Count</h4>
                    <table class="table table-hover table-striped table-bordered" id="tabPatientCount">
                        <thead>
                            <tr>
                                <th>Department</th>
                                <th>Total Patient</th>
                                <th>Card Fee</th>
                                <th>Total Amount</th>
                            </tr>
                        </thead>
                        <tbody id="pbody">
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
            <th>%</th>
        </tr>
    </thead>
    <tbody id="ipharmacybody"></tbody>
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
                    <div class="col-lg-2">
                        <div class="card l-bg-green-dark text-white" id="Box1">
                            <div class="card-header" style="height: 30px; text-align: center;">
                                <h3 id="Vitals" style="padding: 5px;">OPD Visits</h3>
                                <i class="fas fa-book-medical" style="position: relative; float: right; margin-top: -24px; margin-right: -6px; font-size: 18px;"></i>
                            </div>
                            <div class="card-body">

                                <div class="col-12" style="text-align: center; font-size: 25px !important;margin-top: 25px;">
                                    <span id="txtVitals">0</span>
                                </div>

                            </div>

                        </div>
                    </div>
                    <div class="col-lg-2">
                        <div class="card l-bg-green-dark text-white" id="Box4">
                            <div class="card-header" style="height: 30px; text-align: center;">
                                <h3 id="" style="padding: 5px;">Total Footfall</h3>
                                <i class="fas fa-book-medical" style="position: relative; float: right; margin-top: -24px; margin-right: -6px; font-size: 18px;"></i>
                            </div>
                            <div class="card-body">

                                <div class="col-12" style="text-align: center; font-size: 25px !important;margin-top: 25px;">
                                    <span id="txtFootfall">0</span>
                                </div>

                            </div>

                        </div>
                    </div>
                    <div class="col-lg-2">
    <div class="card l-bg-green-dark text-white" id="Box5">
        <div class="card-header" style="height: 30px; text-align: center;">
            <h3 id="" style="padding: 5px;">Referral Rate</h3>
            <i class="fas fa-book-medical" style="position: relative; float: right; margin-top: -24px; margin-right: -6px; font-size: 18px;"></i>
        </div>
        <div class="card-body">

            <div class="col-12" style="text-align: center; font-size: 25px !important;margin-top: 25px;">
                <span id="txtReferRate">0</span>
            </div>

        </div>

    </div>
</div>
                    <div class="col-lg-3">
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
                    <div class="col-lg-3">
                        <div class="card l-bg-blue-dark text-white" id="Box3">
                            <div class="card-header" style="height: 30px; text-align: center;">
                                <h3 id="Dpt2" style="padding: 5px;">Today Status</h3>
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
                    <div class="col-lg-6" style="text-align: center">
                        <h4>Doctor Statistics</h4>
                        <div id="chartGetDocPatientCount"></div>
                    </div>
                    <div class="col-lg-6" style="text-align: center">
                        <h4>Appointment Statistics</h4>
                        <div id="chartGetDocAppointmentsCount"></div>
                    </div>
                </div>
                 <div class="row mb-3">
        <div class="col-12">
            <div class="card shadow">
         <div class="card-header d-flex justify-content-center align-items-center cardheader">
    <h4 class="card-title mb-0 fw-bold text-white">
        Top 5 Tests by Department
    </h4>
</div>




                <div class="card-body">
                    <div id="topTestsChartsContainer"></div>
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
