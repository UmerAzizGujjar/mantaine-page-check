<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CEODashboardNew.aspx.cs" Inherits="PMS.Modules.Dashboards.CEODashboardNew" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="../../wwwroot/lib/apexcharts/apexchart.js"></script>
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/CEODashboardNew.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            $("#loader").show();
            setTimeout(function () {
                $("#loader").fadeOut();
            }, 4000);
            LoadYears();
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
            LoadEmergencyCounts(date, date)
            var date = moment('<%= DateTime.Now%>').format('LL');
            LoadIPDAdmitDischarge(date, date);
            LoadOPDDepartmentWise(date, date);
            LoadEmergencyPatientCountsAndNetAmount(date, date);
            LoadIPDPatientCountsAndNetAmount(date, date);
            LoadEmergencyWardBedOccupancy(date, date);
            LoadIPDWardBedOccupancy(date, date);
            LoadOPDDepartmentWiseWithCounts(date, date);
            LoadEmergencyWardBedCounts(date, date);
            LoadIPDWardBedCounts(date, date);
            LoadTotalIPDAdmitted();
            var year = new Date().getFullYear();
            LoadYearlyInventorySummary(year);
            LoadYearlyPharmecySummary(year);
            LoadYearlyPharmecyRevenu(year);

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
            ChartfDeptPatientCount(dt, dts);
            LoadOverallSatisfaction(dt, dts);
            LoadEmergencyCounts(dt, dts);
            LoadIPDAdmitDischarge(dt, dts);
            LoadOPDDepartmentWise(dt, dts);
            LoadEmergencyPatientCountsAndNetAmount(dt, dts);
            LoadIPDPatientCountsAndNetAmount(dt, dts);
            LoadEmergencyWardBedOccupancy(dt, dts);
            LoadIPDWardBedOccupancy(dt, dts);
            LoadOPDDepartmentWiseWithCounts(dt, dts);
            LoadEmergencyWardBedCounts(dt, dts);
            LoadIPDWardBedCounts(dt, dts);

        }
        function LoadYearlyInventorySummary(year) {
            PageMethods.GetYearlyInventorySummary(year, function (res) {
                var data = JSON.parse(res);

                // Clear previous data
                $('#tblInventorySummary thead').empty();
                $('#tblInventorySummary tbody').empty();

                // 🔹 Table Header (Months)
                var headerRow = '<tr><th style ="text-align : center">Stock Block</th>';
                var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                $.each(months, function (i, m) {
                    headerRow += '<th style ="text-align : center">' + m + '</th>';
                });
                headerRow += '</tr>';
                $('#tblInventorySummary thead').append(headerRow);

                // 🔹 Build rows from pivoted data
                $.each(data, function (i, val) {
                    var row = '<tr><td>' + val.Metric.replace(/_/g, ' ') + '</td>';
                    $.each(months, function (j, m) {
                        var monthValue = val[m] !== null ? parseFloat(val[m]).toFixed(2) : '0.00';
                        row += '<td>' + monthValue + '</td>';
                    });
                    row += '</tr>';
                    $('#tblInventorySummary tbody').append(row);
                });
            });
        }

        function LoadYearlyPharmecyRevenu(year) {
            PageMethods.GetYearlyPharmacyRevenu(year, function (res) {
                var data = JSON.parse(res);
                $('#tblPharmacyRevenu thead').empty();
                $('#tblPharmacyRevenu tbody').empty();

                var headerRow = '<tr><th style ="text-align : center">Stock Block</th>';
                var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                $.each(months, function (i, m) {
                    headerRow += '<th style ="text-align : center">' + m + '</th>';
                });
                headerRow += '</tr>';
                $('#tblPharmacyRevenu thead').append(headerRow);

                // 🔹 Build rows from pivoted data
                $.each(data, function (i, val) {
                    var row = '<tr><td>' + val.Metric.replace(/_/g, ' ') + '</td>';
                    $.each(months, function (j, m) {
                        var monthValue = val[m] !== null ? parseFloat(val[m]).toFixed(2) : '0.00';
                        row += '<td>' + monthValue + '</td>';
                    });
                    row += '</tr>';
                    $('#tblPharmacyRevenu tbody').append(row);
                });
            });
        }

        function LoadYearlyPharmecySummary(year) {
            PageMethods.GetYearlyPharmacySummary(year, function (res) {
                var data = JSON.parse(res);
                $('#tblPharmacySummary thead').empty();
                $('#tblPharmacySummary tbody').empty();

                var headerRow = '<tr><th style ="text-align : center">Stock Block</th>';
                var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                $.each(months, function (i, m) {
                    headerRow += '<th style ="text-align : center">' + m + '</th>';
                });
                headerRow += '</tr>';
                $('#tblPharmacySummary thead').append(headerRow);

                // 🔹 Build rows from pivoted data
                $.each(data, function (i, val) {
                    var row = '<tr><td>' + val.Metric.replace(/_/g, ' ') + '</td>';
                    $.each(months, function (j, m) {
                        var monthValue = val[m] !== null ? parseFloat(val[m]).toFixed(2) : '0.00';
                        row += '<td>' + monthValue + '</td>';
                    });
                    row += '</tr>';
                    $('#tblPharmacySummary tbody').append(row);
                });
            });
        }
        function LoadYears() {
            //var options = ''
            PageMethods.GetYears(function (data) {
                var options = '<option value="0" >Please Select</option>';
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlyears').html(options);
                $('#ddlyears').select2();
            });
        }

        function LoadYears() {

    var currentYear = new Date().getFullYear();
    var options = '<option value="0">Please Select</option>';
    for (var year = currentYear; year >= currentYear - 10; year--) {
        options += '<option value="' + year + '">' + year + '</option>';
    }
    $('#ddlyears').html(options);
    $('#ddlyears').select2();
}
        function LoadPatientsCount(startdate, Enddate) {
            var txt_sdate = startdate;
            var txt_edate = Enddate;
            $.ajax({
                type: "POST",
                url: "CEODashBoardNew.aspx/GetPatientsCount",
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
                    var newOPD = parsedData.NewOPD || 0;
                    var revisitOPD = parsedData.RevisitOPD || 0;

                    $('#lblTotalPatient').text(total);
                    $('#lblFilterPatient').text(newOPD + ' (' + (total > 0 ? ((newOPD / total) * 100).toFixed(2) : 0) + '%)');
                    $('#lblDepartmentPatient').text(revisitOPD + ' (' + (total > 0 ? ((revisitOPD / total) * 100).toFixed(2) : 0) + '%)');

                    renderOPDSummaryChart(total, newOPD, revisitOPD);
                },
                error: function (xhr, status, error) {
                    console.error("Error in LoadPatientsCount: " + error);
                }
            });
        }
        function LoadAppointmentsOPDCount(startdate, Enddate) {
            $.ajax({
                type: "POST",
                url: "CEODashBoardNew.aspx/GetAppointmentsOPDCount",
                data: JSON.stringify({
                    'txt_sdate': startdate,
                    'txt_edate': Enddate
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var parsedData = JSON.parse(data.d);

                    if (parsedData.Error) {
                        console.error("Server error:", parsedData.Error);
                        return;
                    }

                    var newAppointments = parseInt(parsedData.NewAppointments) || 0;
                    var revisits = parseInt(parsedData.Revisits) || 0;
                    var total = newAppointments + revisits;

                    var newPct = total > 0 ? ((newAppointments / total) * 100).toFixed(2) : 0;
                    var revisitPct = total > 0 ? ((revisits / total) * 100).toFixed(2) : 0;

                    $('#lblTotalAppointments').text(total);

                    $('#lblAppPatient').text(newAppointments + ' (' + newPct + '%)');
                    $('#lblWalkInPatient').text(revisits + ' (' + revisitPct + '%)');
                },
                error: function (xhr, status, error) {
                    console.error("AJAX Error: " + status + " - " + error);
                }
            });
        }
        function LoadReferCount(startdate, Enddate) {
            var txt_sdate = startdate;
            var txt_edate = Enddate;
            $.ajax({
                type: "POST",
                url: "CEODashBoardNew.aspx/GetReferCount",
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
                url: "CEODashBoardNew.aspx/GetFootfallCount",
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
                url: "CEODashBoardNew.aspx/GetDialysisPatientsCount",
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
        function loadInventoryandPharmcay() {
            var year = $('#ddlyears').val();

            LoadYearlyPharmecySummary(year);
            LoadYearlyPharmecyRevenu(year);
            LoadYearlyInventorySummary(year);
        }
        function LoadInvestigationCount(startdate, Enddate) {
            var txt_sdate = startdate;
            var txt_edate = Enddate;

            PageMethods.GetInvestigationCount(txt_sdate, txt_edate, function (res) {
                var Investigations = JSON.parse(res);
                var rows = '';

                $('#tabInvestigation tbody').empty();

                $.each(Investigations, function (key, value) {
                    if (value.Department === "Physiotherapy") {
                        value.TotalPerformCount = value.TotalBillCount;
                    }

                    var totalAmount = parseFloat(value.TotalAmount) || 0;
                    var discount = parseFloat(value.TotalDiscount) || 0;
                    var netAmount = parseFloat(value.TotalBillAmount) || 0;

                    rows += '<tr>' +
                        '<td>' + value.Department + '</td>' +
                        '<td>' + (value.TotalBillCount || 0) + '</td>' +
                        '<td>' + (value.TotalPerformCount || 0) + '</td>' +
                        '<td>' + totalAmount.toFixed(2) + '</td>' +
                        '<td>' + discount.toFixed(2) + '</td>' +
                        '<td>' + netAmount.toFixed(2) + '</td>' +
                        '</tr>';
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
                        pct = 100;
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
                url: "CEODashBoardNew.aspx/GetVitalCount",
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
                url: "CEODashBoardNew.aspx/GetTodayPatientsCount",
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
        let departmentCharts = [];

        function LoadTop5TestsByDepartment(startdate, enddate) {
            var txt_sdate = startdate;
            var txt_edate = enddate;

            const container = document.querySelector("#topTestsChartsContainer");
            container.innerHTML = '<div class="text-center py-5"><div class="spinner-border text-primary" role="status"><span class="visually-hidden">Loading...</span></div><p class="mt-2">Loading department data...</p></div>';

            PageMethods.GetTop5TestsByDepartment(txt_sdate, txt_edate, function (resp) {
                try {
                    const data = JSON.parse(resp);

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

                    const chartsRow = document.createElement('div');
                    chartsRow.className = 'row';
                    container.appendChild(chartsRow);

                    data.forEach((deptData, index) => {
                        const col = document.createElement('div');
                        col.className = 'col-xl-2 col-lg-3 col-md-6 col-sm-12 mb-4';

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

                        const labels = deptData.Tests.map(test =>
                            test.TestName.length > 15 ? test.TestName.substring(0, 15) + '...' : test.TestName
                        );
                        const amounts = deptData.Tests.map(test => test.TotalAmount);
                        const counts = deptData.Tests.map(test => test.TestCount);

                        const departmentColors = [
                            ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FECA57'],
                            ['#6A89CC', '#F8C291', '#82CCDD', '#B8E994', '#E55039'],
                            ['#D980FA', '#FDA7DF', '#ED4C67', '#A3CB38', '#1289A7'],
                            ['#FFC312', '#C4E538', '#12CBC4', '#FDA7DF', '#ED4C67'],
                            ['#9980FA', '#833471', '#0652DD', '#EA2027', '#009432']
                        ];
                        const colors = departmentColors[index % departmentColors.length];

                        const options = {
                            series: [{
                                name: 'Test Count',
                                data: counts
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
                                    return Math.round(val).toLocaleString();
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
                                        return Math.round(val).toLocaleString();
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
        debugger;
        let Docchart;
        function ChartfDocPatientCount(startdate, Enddate) {
            PageMethods.GetDocPatientCount(startdate, Enddate, function (resp) {
                try {
                    var parsedData = JSON.parse(resp);

                    var validData = parsedData.filter(item =>
                        item.Doctor_Name != null &&
                        item.Doctor_Name.trim() !== "" &&
                        item.Total_Count != null
                    );

                    if (validData.length === 0) {
                        document.querySelector("#chartGetDocPatientCount").innerHTML =
                            "<div class='text-center text-muted mt-4'>No doctor data available</div>";
                        return;
                    }

                    var PatientCount = validData.map(item => parseInt(item.Total_Count) || 0);
                    var DoctorName = validData.map(item => item.Doctor_Name.trim());

                    var options = {
                        series: PatientCount,
                        chart: {
                            type: 'donut',
                            height: 350
                        },
                        labels: DoctorName,
                        responsive: [{
                            breakpoint: 480,
                            options: {
                                chart: { width: 200 },
                                legend: { position: 'bottom' }
                            }
                        }],
                        title: {
                            text: '',
                            align: 'center'
                        }
                    };

                    if (Docchart) {
                        Docchart.destroy();
                    }
                    Docchart = new ApexCharts(document.querySelector("#chartGetDocPatientCount"), options);
                    Docchart.render();

                } catch (e) {
                    console.error("Error in ChartfDocPatientCount:", e);
                    document.querySelector("#chartGetDocPatientCount").innerHTML =
                        "<div class='text-center text-danger mt-4'>Error loading chart</div>";
                }
            }, function (error) {
                console.error("AJAX error:", error);
                document.querySelector("#chartGetDocPatientCount").innerHTML =
                    "<div class='text-center text-danger mt-4'>Failed to load data</div>";
            });
        }
        let AppointmentChart;

        function ChartAppointmentCountByDoctor(startdate, Enddate) {


            function formatDate(str) {
                let d = new Date(str);
                let month = ("0" + (d.getMonth() + 1)).slice(-2);
                let day = ("0" + d.getDate()).slice(-2);
                return d.getFullYear() + "-" + month + "-" + day;
            }

            PageMethods.GetAppointmentCountByDoctor(formatDate(startdate), formatDate(Enddate), function (resp) {
                debugger;
                try {
                    var parsedData = JSON.parse(resp);

                    document.querySelector("#chartGetDocAppointmentsCount").innerHTML = "";

                    if (parsedData.Error) {
                        console.error("Error:", parsedData.Error);
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
                                return seriesName + ' - ' + appointmentCounts[opts.seriesIndex];
                            }
                        },
                        dataLabels: {
                            enabled: true,
                            formatter: function (val, opts) {
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
                var data = JSON.parse(res);
                var rows = '';
                $('#tabPatientCount tbody').empty();
                $.each(data, function (key, value) {
                    rows += '<tr>' +
                        '<td>' + value.Category + '</td>' +
                        '<td>' + value.Total_Count + '</td>' +
                        '<td>' + value.Receipt_Amount + '</td>' +
                        '<td>' + value.Discount_Amount + '</td>' +
                        '<td>' + value.Gross_Amount + '</td>' +
                        '</tr>';
                });
                $('#tabPatientCount tbody').append(rows);
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
                    const averageValue = parseFloat(data.OverallAverageSatisfaction) || 0;
                    const percentageValue = (averageValue / 5) * 100;

                    if (chart_Avg) {
                        chart_Avg.destroy();
                    }

                    var options = {
                        series: [percentageValue],
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


        function LoadEmergencyCounts(startdate, Enddate) {
            var txt_sdate = startdate;
            var txt_edate = Enddate;
            $.ajax({
                type: "POST",
                url: "CEODashBoardNew.aspx/GetEmergencyCounts",
                data: JSON.stringify({
                    'txt_sdate': txt_sdate,
                    'txt_edate': txt_edate,
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (data) {
                    var parsedData = JSON.parse(data.d);

                    var totalEmer = parsedData.TotalEmergency || 0;
                    var newEmer = parsedData.NewEmergency || 0;
                    var revisitEmer = parsedData.RevisitEmergency || 0;

                    var totalEmerVisits = newEmer + revisitEmer;
                    var newPct = totalEmerVisits > 0 ? ((newEmer / totalEmerVisits) * 100).toFixed(2) : 0;
                    var revisitPct = totalEmerVisits > 0 ? ((revisitEmer / totalEmerVisits) * 100).toFixed(2) : 0;

                    $('#lblTotalEmergency').text(totalEmer);

                    $('#lblNewEmergency').text(newEmer + ' (' + newPct + '%)');
                    $('#lblRevisitEmergency').text(revisitEmer + ' (' + revisitPct + '%)');

                    renderEmergencySummaryChart(totalEmer, newEmer, revisitEmer);
                },
                error: function (xhr, status, error) {
                    console.error("Error in LoadEmergencyCounts: " + error);
                }
            });
        }



        function LoadIPDAdmitDischarge(startdate, Enddate) {
            $.ajax({
                type: "POST",
                url: "CEODashBoardNew.aspx/GetIPDAdmitDischarge",
                data: JSON.stringify({
                    'txt_sdate': startdate,
                    'txt_edate': Enddate
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (data) {
                    var parsedData = JSON.parse(data.d);

                    var admitted = parsedData.Still_Admitted || 0;
                    var discharged = parsedData.Discharged || 0;

                    $('#lblIPDAdmitted').text(admitted);
                    $('#lblIPDDischarged').text(discharged);

                    renderIPDSummaryChart(admitted, discharged);
                },
                error: function (xhr, status, error) {
                    console.error("Error in LoadIPDAdmitDischarge: " + error);
                }
            });
        }

        function LoadTotalIPDAdmitted() {
            $.ajax({
                type: "POST",
                url: "CEODashBoardNew.aspx/GetTotalIPDAdmitted",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var parsedData = JSON.parse(data.d);
                    var totalAdmitted = parsedData.Total_Admitted || 0;
                    $('#lblIPDAdmittedTotal').text(totalAdmitted);
                },
                error: function (xhr, status, error) {
                    console.error("Error in LoadTotalIPDAdmitted: " + error);
                }
            });
        }

        let DeptChart;
        function ChartfDeptPatientCount(startdate, Enddate) {
            PageMethods.GetDepartmentPatientCount(startdate, Enddate, function (resp) {
                debugger;
                var parsedData = JSON.parse(resp);

                var series = parsedData.map(item => item.Total_Count);
                var labels = parsedData.map(item => item.Department_Name);

                var options = {
                    series: series,
                    chart: {
                        type: 'donut',
                        height: 350
                    },
                    labels: labels,
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
                    }],
                    title: {
                        text: '',
                        align: 'center'
                    },
                    tooltip: {
                        y: {
                            formatter: function (val, opts) {
                                return val + " patients";
                            }
                        }
                    }
                };

                if (DeptChart) {
                    DeptChart.destroy();
                }
                DeptChart = new ApexCharts(document.querySelector("#chartGetDeptPatientCount"), options);
                DeptChart.render();
            }, function (error) {
                console.error("Error loading department chart:", error);
            });
        }




        let OPDDepartmentChart;
        function LoadOPDDepartmentWise(startdate, enddate) {
            PageMethods.GetOPDDepartmentWise(startdate, enddate, function (resp) {

                var parsedData = JSON.parse(resp);

                var series = parsedData.map(item => parseFloat(item.OPD_Count) || 0);
                var labels = parsedData.map(item => item.Department_Name);

                var options = {
                    series: series,
                    chart: {
                        type: 'donut',
                        height: 350
                    },
                    labels: labels,
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
                    }],
                    title: {
                        text: '',
                        align: 'center'
                    },
                    tooltip: {
                        y: {
                            formatter: function (val) {
                                return '' + val.toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                            }
                        }
                    },
                    fill: {
                        colors: ['#2E93fA', '#66DA26', '#FF9800', '#FF4560', '#546E7A', '#00E396', '#FEB019']
                    }
                };

                if (OPDDepartmentChart) {
                    OPDDepartmentChart.destroy();
                }
                OPDDepartmentChart = new ApexCharts(document.querySelector("#chartOPDDepartmentWise"), options);
                OPDDepartmentChart.render();
            }, function (error) {
                console.error("Error loading OPD department chart:", error);
            });
        }




        let chartOPDSummary, chartEmergencySummary, chartIPDSummary;

        function renderOPDSummaryChart(total, newOPD, revisitOPD) {
            const options = {
                series: [newOPD, revisitOPD],
                chart: { type: 'donut', height: 300 },
                labels: ['New OPD', 'Revisits'],
                colors: ['#00C49F', '#0088FE'],
                legend: {
                    position: 'bottom',
                    fontSize: '13px',
                    labels: { colors: '#444' }
                },
                plotOptions: {
                    pie: {
                        donut: {
                            size: '70%',
                            labels: {
                                show: true,
                                name: {
                                    show: true,
                                    fontSize: '14px',
                                    color: '#555'
                                },
                                value: {
                                    show: true,
                                    fontSize: '18px',
                                    fontWeight: 'bold',
                                    color: '#111'
                                },
                                total: {
                                    show: true,
                                    label: 'Total OPD',
                                    color: '#8e0016',
                                    formatter: function () {
                                        return total;
                                    }
                                }
                            }
                        }
                    }
                },
                dataLabels: {
                    enabled: false
                },
                title: {
                    text: '',
                    align: 'center'
                },
                responsive: [{
                    breakpoint: 480,
                    options: {
                        chart: { width: 250 },
                        legend: { position: 'bottom' }
                    }
                }]
            };

            if (chartOPDSummary) chartOPDSummary.destroy();
            chartOPDSummary = new ApexCharts(document.querySelector("#chartOPDSummary"), options);
            chartOPDSummary.render();
        }




        function renderEmergencySummaryChart(total, newEmer, revisitEmer) {
            const options = {
                series: [newEmer, revisitEmer],
                chart: { type: 'donut', height: 300 },
                labels: ['New Emergency', 'Revisit'],
                colors: ['#FF4C4C', '#FFB84C'],
                legend: {
                    position: 'bottom',
                    fontSize: '13px',
                    labels: { colors: '#444' }
                },
                plotOptions: {
                    pie: {
                        donut: {
                            size: '70%',
                            labels: {
                                show: true,
                                name: {
                                    show: true,
                                    fontSize: '14px',
                                    color: '#555'
                                },
                                value: {
                                    show: true,
                                    fontSize: '18px',
                                    fontWeight: 'bold',
                                    color: '#111'
                                },
                                total: {
                                    show: true,
                                    label: 'Total Emergency',
                                    color: '#8e0016',
                                    formatter: function () {
                                        return total;
                                    }
                                }
                            }
                        }
                    }
                },
                dataLabels: {
                    enabled: false
                },
                responsive: [{
                    breakpoint: 480,
                    options: {
                        chart: { width: 250 },
                        legend: { position: 'bottom' }
                    }
                }]
            };

            if (chartEmergencySummary) chartEmergencySummary.destroy();
            chartEmergencySummary = new ApexCharts(document.querySelector("#chartEmergencySummary"), options);
            chartEmergencySummary.render();
        }



        function renderIPDSummaryChart(admitted, discharged) {
            const total = admitted + discharged;

            const options = {
                series: [admitted, discharged],
                chart: { type: 'donut', height: 320 },
                labels: ['Admitted', 'Discharged'],
                colors: ['#00B894', '#8E44AD'],
                legend: {
                    position: 'bottom',
                    fontSize: '13px',
                    labels: { colors: '#444' }
                },
                plotOptions: {
                    pie: {
                        donut: {
                            size: '70%',
                            labels: {
                                show: true,
                                name: {
                                    show: true,
                                    fontSize: '14px',
                                    color: '#555'
                                },
                                value: {
                                    show: true,
                                    fontSize: '18px',
                                    fontWeight: 'bold',
                                    color: '#111'
                                },
                                total: {
                                    show: true,
                                    label: 'Total IPD',
                                    color: '#8e0016',
                                    formatter: function () {
                                        return total;
                                    }
                                }
                            }
                        }
                    }
                },
                dataLabels: {
                    enabled: false
                },
                responsive: [{
                    breakpoint: 480,
                    options: {
                        chart: { width: 250 },
                        legend: { position: 'bottom' }
                    }
                }]
            };

            if (chartIPDSummary) chartIPDSummary.destroy();
            chartIPDSummary = new ApexCharts(document.querySelector("#chartIPDSummary"), options);
            chartIPDSummary.render();
        }

        function LoadEmergencyPatientCountsAndNetAmount(startdate, enddate) {
            PageMethods.GetEmergencyPatientCountsAndNetAmount(startdate, enddate, function (res) {
                var data = JSON.parse(res);
                var rows = '';
                $('#tabEmergencyPatientCount tbody').empty();
                $.each(data, function (key, value) {
                    rows += '<tr>' +
                        '<td>' + value.Category + '</td>' +
                        '<td>' + value.Total_Count + '</td>' +
                        '<td>' + value.Receipt_Amount + '</td>' +
                        '<td>' + value.Discount_Amount + '</td>' +
                        '<td>' + value.Gross_Amount + '</td>' +
                        '</tr>';
                });
                $('#tabEmergencyPatientCount tbody').append(rows);
            });
        }

        function LoadIPDPatientCountsAndNetAmount(startdate, enddate) {
            PageMethods.GetIPDPatientCountsAndNetAmount(startdate, enddate, function (res) {
                var data = JSON.parse(res);
                var rows = '';
                $('#tabIPDPatientCount tbody').empty();
                $.each(data, function (key, value) {
                    rows += '<tr>' +
                        '<td>' + value.Category + '</td>' +
                        '<td>' + value.Total_Count + '</td>' +
                        '<td>' + value.Receipt_Amount + '</td>' +
                        '<td>' + value.Discount_Amount + '</td>' +
                        '<td>' + value.Gross_Amount + '</td>' +
                        '</tr>';
                });
                $('#tabIPDPatientCount tbody').append(rows);
            });
        }

        let EmergencyWardChart;
        function LoadEmergencyWardBedOccupancy(startdate, enddate) {
            PageMethods.GetEmergencyWardBedOccupancy(startdate, enddate, function (resp) {
                var parsedData = JSON.parse(resp);

                var series = parsedData.map(item => parseFloat(item.OccupiedBeds) || 0);
                var labels = parsedData.map(item => item.Ward_Name);

                var options = {
                    series: series,
                    chart: {
                        type: 'donut',
                        height: 350
                    },
                    labels: labels,
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
                    }],
                    title: {
                        text: '',
                        align: 'center'
                    },
                    tooltip: {
                        y: {
                            formatter: function (val, opts) {
                                var index = opts.seriesIndex;
                                var totalBeds = parsedData[index]?.TotalBeds || 0;
                                var occupied = Math.round(val);
                                return `${totalBeds} / ${occupied} beds`;
                            }
                        }
                    },
                    fill: {
                        colors: ['#FF4560', '#00E396', '#FEB019', '#2E93fA', '#66DA26', '#546E7A', '#FF9800']
                    }
                };

                if (EmergencyWardChart) {
                    EmergencyWardChart.destroy();
                }
                EmergencyWardChart = new ApexCharts(document.querySelector("#chartEmergencyWard"), options);
                EmergencyWardChart.render();
            }, function (error) {
                console.error("Error loading Emergency Ward chart:", error);
            });
        }


        let IPDWardChart;
        function LoadIPDWardBedOccupancy(startdate, enddate) {
            PageMethods.GetWardBedOccupancy(startdate, enddate, function (resp) {
                var parsedData = JSON.parse(resp);

                var series = parsedData.map(item => parseFloat(item.OccupiedBeds) || 0);
                var labels = parsedData.map(item => item.Ward_Name);

                var options = {
                    series: series,
                    chart: {
                        type: 'donut',
                        height: 350
                    },
                    labels: labels,
                    responsive: [{
                        breakpoint: 480,
                        options: {
                            chart: { width: 200 },
                            legend: { position: 'bottom' }
                        }
                    }],
                    title: {
                        text: '',
                        align: 'center'
                    },
                    tooltip: {
                        y: {
                            formatter: function (val, opts) {
                                var index = opts.seriesIndex;
                                var totalBeds = parsedData[index]?.TotalBeds || 0;
                                var occupied = Math.round(val);
                                return `${totalBeds} / ${occupied} occupied beds`;
                            }
                        }
                    },
                    fill: {
                        colors: ['#00E396', '#FF4560', '#FEB019', '#2E93fA', '#66DA26', '#546E7A', '#FF9800']
                    }
                };

                if (IPDWardChart) {
                    IPDWardChart.destroy();
                }
                IPDWardChart = new ApexCharts(document.querySelector("#chartIPDWard"), options);
                IPDWardChart.render();
            }, function (error) {
                console.error("Error loading IPD Ward chart:", error);
            });
        }


        let OPDDepartmentChartWithCounts;

        function LoadOPDDepartmentWiseWithCounts(startdate, enddate) {
            PageMethods.GetOPDDepartmentWise(startdate, enddate, function (resp) {
                var parsedData = JSON.parse(resp);

                var series = parsedData.map(item => parseFloat(item.OPD_Count) || 0);
                var labels = parsedData.map(item => item.Department_Name);

                var options = {
                    series: series,
                    chart: {
                        type: 'donut',
                        height: 350
                    },
                    labels: labels,
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
                    }],
                    title: {
                        text: '',
                        align: 'center'
                    },
                    tooltip: {
                        y: {
                            formatter: function (val) {
                                return val.toLocaleString('en-IN');
                            }
                        }
                    },
                    fill: {
                        colors: ['#2E93fA', '#66DA26', '#FF9800', '#FF4560', '#546E7A', '#00E396', '#FEB019']
                    },
                    dataLabels: {
                        enabled: true,
                        formatter: function (val, opts) {
                            return parsedData[opts.seriesIndex].OPD_Count;
                        },
                        style: {
                            fontSize: '14px',
                            fontWeight: 'bold',
                            colors: ['#fff']
                        },
                        offset: 10
                    },
                    plotOptions: {
                        pie: {
                            donut: {
                                labels: {
                                    show: false
                                }
                            }
                        }
                    }
                };

                if (OPDDepartmentChartWithCounts) {
                    OPDDepartmentChartWithCounts.destroy();
                }
                OPDDepartmentChartWithCounts = new ApexCharts(
                    document.querySelector("#chartOPDDepartmentWiseWithCounts"),
                    options
                );
                OPDDepartmentChartWithCounts.render();
            }, function (error) {
                console.error("Error loading OPD department chart with counts:", error);
            });
        }

        let EmergencyWardChartCounts;

        function LoadEmergencyWardBedCounts(startdate, enddate) {
            PageMethods.GetEmergencyWardBedOccupancy(startdate, enddate, function (resp) {
                var parsedData = JSON.parse(resp);

                var series = parsedData.map(item => parseFloat(item.OccupiedBeds) || 0);
                var labels = parsedData.map(item => item.Ward_Name);

                var options = {
                    series: series,
                    chart: {
                        type: 'donut',
                        height: 350
                    },
                    labels: labels,
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
                    }],
                    title: {
                        text: '',
                        align: 'center'
                    },
                    tooltip: {
                        y: {
                            formatter: function (val, opts) {
                                var index = opts.seriesIndex;
                                var totalBeds = parsedData[index]?.TotalBeds || 0;
                                var occupied = Math.round(val);
                                return `${totalBeds} / ${occupied} beds`;
                            }
                        }
                    },
                    fill: {
                        colors: ['#FF4560', '#00E396', '#FEB019', '#2E93fA', '#66DA26', '#546E7A', '#FF9800']
                    },
                    dataLabels: {
                        enabled: true,
                        formatter: function (val, opts) {
                            return Math.round(series[opts.seriesIndex]);
                        },
                        style: {
                            fontSize: '14px',
                            fontWeight: 'bold',
                            colors: ['#fff']
                        },
                        offset: 10
                    },
                    plotOptions: {
                        pie: {
                            donut: {
                                labels: {
                                    show: false
                                }
                            }
                        }
                    }
                };

                if (EmergencyWardChartCounts) {
                    EmergencyWardChartCounts.destroy();
                }
                EmergencyWardChartCounts = new ApexCharts(
                    document.querySelector("#chartEmergencyWardCounts"),
                    options
                );
                EmergencyWardChartCounts.render();
            }, function (error) {
                console.error("Error loading Emergency Ward counts chart:", error);
            });
        }

        let IPDWardChartCounts;
        function LoadIPDWardBedCounts(startdate, enddate) {
            PageMethods.GetWardBedOccupancy(startdate, enddate, function (resp) {
                var parsedData = JSON.parse(resp);

                var series = parsedData.map(item => parseFloat(item.OccupiedBeds) || 0);
                var labels = parsedData.map(item => item.Ward_Name);

                var options = {
                    series: series,
                    chart: {
                        type: 'donut',
                        height: 350
                    },
                    labels: labels,
                    responsive: [{
                        breakpoint: 480,
                        options: {
                            chart: { width: 200 },
                            legend: { position: 'bottom' }
                        }
                    }],
                    title: { text: '', align: 'center' },
                    tooltip: {
                        y: {
                            formatter: function (val, opts) {
                                var index = opts.seriesIndex;
                                var totalBeds = parsedData[index]?.TotalBeds || 0;
                                var occupied = Math.round(val);
                                return `${totalBeds} / ${occupied} beds occupied`;
                            }
                        }
                    },
                    fill: {
                        colors: ['#00E396', '#FF4560', '#FEB019', '#2E93fA', '#66DA26', '#546E7A', '#FF9800']
                    },
                    dataLabels: {
                        enabled: true,
                        formatter: function (val, opts) {
                            return Math.round(val);
                        },
                        style: {
                            fontSize: '14px',
                            fontWeight: 'bold',
                            colors: ['#fff']
                        },
                        offset: 10
                    },
                    plotOptions: {
                        pie: {
                            donut: {
                                labels: { show: false }
                            }
                        }
                    }
                };

                if (IPDWardChartCounts) {
                    IPDWardChartCounts.destroy();
                }
                IPDWardChartCounts = new ApexCharts(
                    document.querySelector("#chartIPDWardCounts"),
                    options
                );
                IPDWardChartCounts.render();
            }, function (error) {
                console.error("Error loading IPD Ward counts chart:", error);
            });
        }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="loader" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(255,255,255,0.9); z-index: 9999; display: flex; justify-content: center; align-items: center;">
        <div class="circle-loader">
            <div class="inner-dot"></div>
        </div>
    </div>

    <div class="container">
        <div class="row">
            <div class="col-lg-4">
                <div class="card">
                    <div class="card-header text-center">
                        Patient & Admission Overview
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-lg-4">
                                <label>Start Date</label>
                                <input type="text" id="startDate" class="form-control" />
                            </div>
                            <div class="col-lg-4">
                                <label>End Date</label>
                                <input type="text" id="EndDate" class="form-control" />
                            </div>
                            <div class="col-lg-4 d-flex align-items-end">
                                <input type="button" id="txtSearch" class="btn btn-primry" value="Search" onclick="search()" />
                            </div>
                        </div>

                        <div class="row" id="Paitent_Count_Row">
                            <div class="col-lg-4 styling">
                                <div class="row">
                                    <span id="lblTotalPatient" style="color: #8e0016"></span>
                                </div>
                                <div class="row">
                                    <label style="color: #8e0016">Total OPD</label>
                                </div>
                            </div>
                            <div class="col-lg-4 styling border border-right">
                                <div class="row">
                                    <span id="lblFilterPatient" style="color: #0f008e"></span>
                                </div>
                                <div class="row">
                                    <label style="color: #0f008e">New OPD</label>
                                </div>
                            </div>
                            <div class="col-lg-4 styling border">
                                <div class="row">
                                    <span id="lblDepartmentPatient" style="color: #5f008e"></span>
                                </div>
                                <div class="row">
                                    <label style="color: #5f008e">Revists</label>
                                </div>
                            </div>
                        </div>

                        <div class="row" id="Emergency_Count_Row">
                            <div class="col-lg-4 styling">
                                <div class="row">
                                    <span id="lblTotalEmergency" style="color: #8e0016"></span>
                                </div>
                                <div class="row">
                                    <label style="color: #8e0016">Total Emergency</label>
                                </div>
                            </div>
                            <div class="col-lg-4 styling border border-right">
                                <div class="row">
                                    <span id="lblNewEmergency" style="color: #0f008e"></span>
                                </div>
                                <div class="row">
                                    <label style="color: #0f008e">New Emergency</label>
                                </div>
                            </div>
                            <div class="col-lg-4 styling border">
                                <div class="row">
                                    <span id="lblRevisitEmergency" style="color: #5f008e"></span>
                                </div>
                                <div class="row">
                                    <label style="color: #5f008e">Revisit</label>
                                </div>
                            </div>
                        </div>

                        <div class="row" id="IPD_AdmitDischarge_Row">
                            <div class="col-lg-4 styling">
                                <div class="row">
                                    <span id="lblIPDAdmittedTotal" style="color: #8e0016"></span>
                                </div>
                                <div class="row">
                                    <label style="color: #8e0016">Total Admitted</label>
                                </div>
                            </div>
                            <div class="col-lg-4 styling border border-right">
                                <div class="row">
                                    <span id="lblIPDAdmitted" style="color: #0f008e"></span>
                                </div>
                                <div class="row">
                                    <label style="color: #0f008e">Today Admission</label>
                                </div>
                            </div>
                            <div class="col-lg-4 styling border">
                                <div class="row">
                                    <span id="lblIPDDischarged" style="color: #5f008e"></span>
                                </div>
                                <div class="row">
                                    <label style="color: #5f008e">Today Discharged</label>
                                </div>
                            </div>
                        </div>

                        <div class="row" id="Paitent_Count_Row2">
                            <div class="col-lg-4 styling">
                                <div class="row">
                                    <span id="lblTotalAppointments" style="color: #8e0016"></span>
                                </div>
                                <div class="row">
                                    <label style="color: #8e0016">Total Appointments</label>
                                </div>
                            </div>
                            <div class="col-lg-4 styling border border-right">
                                <div class="row">
                                    <span id="lblAppPatient" style="color: #0f008e"></span>
                                </div>
                                <div class="row">
                                    <label style="color: #0f008e">New Appointments</label>
                                </div>
                            </div>
                            <div class="col-lg-4 styling border">
                                <div class="row">
                                    <span id="lblWalkInPatient" style="color: #5f008e"></span>
                                </div>
                                <div class="row">
                                    <label style="color: #5f008e">Revisits</label>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>

                <div class="row" id="Paitent_Count_Row3" style="display: none">
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
                    <div class="card shadow-sm OPDtable">
                        <div class="card-header">
                            OPD Patients Count
                        </div>
                        <div class="card-body">
                            <div class="table-responsive">
                                <table class="table table-hover table-striped table-bordered mb-0" id="tabPatientCount">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Department</th>
                                            <th>Total Patient</th>
                                            <th>Total Amount</th>
                                            <th>Discount</th>
                                            <th>Net Amount</th>
                                        </tr>
                                    </thead>
                                    <tbody id="pbody">
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-lg-12">
                        <div class="card emergencytable">
                            <div class="card-header">Emergency Patients Count</div>
                            <div class="card-body">
                                <table class="table table-hover table-striped table-bordered" id="tabEmergencyPatientCount">
                                    <thead>
                                        <tr>
                                            <th>Department</th>
                                            <th>Total Patient</th>
                                            <th>Total Amount</th>
                                            <th>Discount</th>
                                            <th>Net Amount</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="card IPDtable">
                    <div class="card-header">
                        IPD Patients Count
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-hover table-striped table-bordered" id="tabIPDPatientCount">
                                <thead>
                                    <tr>
                                        <th>Department</th>
                                        <th>Total Patient</th>
                                        <th>Total Amount</th>
                                        <th>Discount</th>
                                        <th>Net Amount</th>
                                    </tr>
                                </thead>
                                <tbody>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header">
                        Investigation
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-hover table-striped table-bordered mb-0" id="tabInvestigation">
                                <thead class="table-light">
                                    <tr>
                                        <th>Department</th>
                                        <th>Ordered</th>
                                        <th>Performed</th>
                                        <th>Total Amount</th>
                                        <th>Discount</th>
                                        <th>Net Amount</th>
                                    </tr>
                                </thead>
                                <tbody id="ibody">
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <div class="row" style="display: none">
                    <h2>Pharmacy</h2>
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
                <div class="row" style="display: none;">
                    <div class="col-lg-12">
                        <h4>Over All Customer Satisfaction</h4>
                        <div id="chartOverallSatisfaction" style="height: 420px; width: 100%;"></div>
                    </div>
                </div>

            </div>

            <div class="col-lg-8">
                <div class="row">
                    <div class="col-lg-2" style="display: none">
                        <div class="card l-bg-green-dark text-white" id="Box1">
                            <div class="card-header" style="height: 30px; text-align: center;">
                                <h3 id="Vitals" style="padding: 5px;">OPD Visits</h3>
                                <i class="fas fa-book-medical" style="position: relative; float: right; margin-top: -24px; margin-right: -6px; font-size: 18px;"></i>
                            </div>
                            <div class="card-body">

                                <div class="col-12" style="text-align: center; font-size: 25px !important; margin-top: 25px;">
                                    <span id="txtVitals">0</span>
                                </div>

                            </div>

                        </div>
                    </div>
                    <div class="col-lg-2" style="display: none">
                        <div class="card l-bg-green-dark text-white" id="Box4">
                            <div class="card-header" style="height: 30px; text-align: center;">
                                <h3 id="" style="padding: 5px;">Total Footfall</h3>
                                <i class="fas fa-book-medical" style="position: relative; float: right; margin-top: -24px; margin-right: -6px; font-size: 18px;"></i>
                            </div>
                            <div class="card-body">

                                <div class="col-12" style="text-align: center; font-size: 25px !important; margin-top: 25px;">
                                    <span id="txtFootfall">0</span>
                                </div>

                            </div>

                        </div>
                    </div>
                    <div class="col-lg-2" style="display: none">
                        <div class="card l-bg-green-dark text-white" id="Box5">
                            <div class="card-header" style="height: 30px; text-align: center;">
                                <h3 id="" style="padding: 5px;">Referral Rate</h3>
                                <i class="fas fa-book-medical" style="position: relative; float: right; margin-top: -24px; margin-right: -6px; font-size: 18px;"></i>
                            </div>
                            <div class="card-body">

                                <div class="col-12" style="text-align: center; font-size: 25px !important; margin-top: 25px;">
                                    <span id="txtReferRate">0</span>
                                </div>

                            </div>

                        </div>
                    </div>
                    <div class="col-lg-3" style="display: none">
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
                    <div class="col-lg-3" style="display: none">
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
                    <div class="col-lg-12 col-md-12 col-sm-12">
                        <div class="card">
                            <div class="card-header">
                                Hospital Summary Overview
                            </div>
                            <div class="card-body Hospitalchart">
                                <div class="row text-center">
                                    <div class="col-lg-4 col-md-12 mb-4">
                                        <h3 class="fw-bold text-theme mb-3">OPD</h3>
                                        <div id="chartOPDSummary"></div>
                                    </div>
                                    <div class="col-lg-4 col-md-12 mb-4">
                                        <h3 class="fw-bold text-theme mb-3">Emergency</h3>
                                        <div id="chartEmergencySummary"></div>
                                    </div>
                                    <div class="col-lg-4 col-md-12 mb-4">
                                        <h3 class="fw-bold text-theme mb-3">IPD</h3>
                                        <div id="chartIPDSummary"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="card shadow-sm">
                        <div class="card-header opdtablemargin">
                            OPD Department Statistics
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-lg-6 col-md-12  text-center">
                                    <h3 class="fw-bold text-secondary mb-3">OPD Department Wise (Percentage)</h3>
                                    <div id="chartOPDDepartmentWise" ></div>
                                </div>

                                <div class="col-lg-6 col-md-12 text-center">
                                    <h3 class="fw-bold text-secondary mb-3">OPD Department Wise (With Counts)</h3>
                                    <div id="chartOPDDepartmentWiseWithCounts"></div>
                                </div>
                            </div>
                        </div>
                    </div>

                </div>
                <div class="row">
                    <div class="row">
                        <div class="card">
                            <div class="card-header emergencychart">
                                Emergency Ward Statistics
                            </div>
                            <div class="card-body">
                                <div class="row text-center">
                                    <div class="col-lg-6 col-md-12 mb-4">
                                        <h3 class="fw-bold text-secondary mb-3">Emergency Ward Bed Occupancy</h3>
                                        <div id="chartEmergencyWard"></div>
                                    </div>
                                    <div class="col-lg-6 col-md-12 mb-4">
                                        <h3 class="fw-bold text-secondary mb-3">Emergency Ward Bed Counts</h3>
                                        <div id="chartEmergencyWardCounts"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="card">
                        <div class="card-header">
                            IPD Ward Bed Details
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-lg-6 text-center">
                                    <h4>IPD Ward Bed Occupancy</h4>
                                    <div id="chartIPDWard"></div>
                                </div>
                                <div class="col-lg-6 text-center">
                                    <h4>IPD Ward Bed Counts</h4>
                                    <div id="chartIPDWardCounts"></div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="card shadow" style="margin-left: 25px !important;">
                            <div class="card-header d-flex justify-content-center align-items-center  headercolor">
                                <h4 class="card-title mb-0 fw-bold text-white">Top 5 Tests by Department
                                </h4>
                            </div>
                            <div class="card-body">
                                <div id="topTestsChartsContainer"></div>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-6" style="text-align: center; display: none">
                            <h4>Department Statistics</h4>
                            <div id="chartGetDeptPatientCount"></div>
                        </div>
                        <div class="col-lg-6" style="text-align: center; display: none">
                            <h4>Appointment Statistics</h4>
                            <div id="chartGetDocAppointmentsCount"></div>
                        </div>
                        <div class="col-lg-6" style="text-align: center; display: none">
                            <h4>Doctor Statistics</h4>
                            <div id="chartGetDocPatientCount"></div>
                        </div>
                    </div>
                    <div class="row" style="display: none">
                        <div class="col-lg-12">
                            <div id="chartAreaWiseStatistics" style="height: 420px; width: 100%;"></div>
                        </div>
                    </div>
                    <div class="row" style="display: none">
                        <div class="col-lg-12">
                            <div id="chartProcdureStatistics" style="height: 420px; width: 100%;"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

         <div class="row">
     <div class="row">
          <div class="col-lg-1">
         <label>Years</label>
         </div>
         <div class="col-lg-1">
             <select id="ddlyears" onchange="loadInventoryandPharmcay();">
                
             </select>
         </div>
     </div>
     <div class="row">
         <div class="col-lg-12">
             <h2>Inventory Record</h2>
             <table id="tblInventorySummary" class="table table-bordered table-striped text-center">
                 <thead></thead>
                 <tbody></tbody>
             </table>
         </div>
     </div>
     <div class="row">
         <div class="col-lg-12">
             <h2>Pharmacy Record</h2>
             <table id="tblPharmacySummary" class="table table-bordered table-striped text-center">
                 <thead></thead>
                 <tbody></tbody>
             </table>
         </div>
     </div>
     <div class="row">
         <div class="col-lg-12">
             <h2>Pharmacy Revenue</h2>
             <table id="tblPharmacyRevenu" class="table table-bordered table-striped text-center">
                 <thead></thead>
                 <tbody></tbody>
             </table>
         </div>
     </div>
 </div>
    </div>
</asp:Content>



