<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Chief_Executive_Dashboard.aspx.cs" Inherits="PMS.Modules.Dashboards.Chief_Executive_Dashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="../../wwwroot/Tibbit_theme/js/apexchart.js"></script>
    <script type="text/javascript">
        $(document).ready(function () {
            LoadHospitalRevenue("today");
            LoadOPDSaleRevenue("today");
            LoadPharmacyRevenue("today");
            LoadLabRadiologyRevenue("today");
            LoadOPDChart("today");
            LoadOPDVolume("today");
            LoadWaitTimeTrends("today");
            LoadBillingData("today");
            LoadPharmacySnapshot("today");
            LoadDialysisLive("today");


            $("#ddlPeriod").change(function () {
                var period = $(this).val();
                LoadHospitalRevenue(period);
                LoadOPDSaleRevenue(period);
                LoadPharmacyRevenue(period);
                LoadLabRadiologyRevenue(period);
                LoadOPDChart(period);
                LoadOPDVolume(period);
                LoadWaitTimeTrends(period);
                LoadBillingData(period);
                LoadPharmacySnapshot(period);
                LoadDialysisLive(period);
            });
        });

        function LoadHospitalRevenue(period) {
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetHospitalRevenue",
                data: JSON.stringify({ 'period': period }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var result = JSON.parse(data.d);
                    if (result.Error) {
                        $('#lblRevenue').text('0');
                        $('#lblRevenueDate').text('Error loading data');
                    } else {
                        var formatted = parseFloat(result.TotalHospitalRevenue).toLocaleString('en-PK', {
                            minimumFractionDigits: 0,
                            maximumFractionDigits: 0
                        });
                        $('#lblRevenue').text(formatted);
                        $('#lblRevenueDate').text(result.DateRange);
                    }
                },
                error: function (xhr, status, error) {
                    $('#lblRevenue').text('0');
                }
            });
        }

        function LoadOPDSaleRevenue(period) {
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetOPDSaleRevenue",
                data: JSON.stringify({ 'period': period }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var result = JSON.parse(data.d);
                    if (result.Error) {
                        $('#lblOPDRevenue').text('0');
                        $('#lblOPDDate').text('Error loading data');
                    } else {
                        var formatted = parseFloat(result.OPDRevenue).toLocaleString('en-PK', {
                            minimumFractionDigits: 0,
                            maximumFractionDigits: 0
                        });
                        $('#lblOPDRevenue').text(formatted);
                        $('#lblOPDDate').text(result.DateRange);
                    }
                },
                error: function () {
                    $('#lblOPDRevenue').text('0');
                }
            });
        }

        function LoadPharmacyRevenue(period) {
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetPharmacyRevenue",
                data: JSON.stringify({ 'period': period }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var result = JSON.parse(data.d);
                    if (result.Error) {
                        $('#lblPharmacyRevenue').text('0');
                        $('#lblPharmacyDate').text('Error loading data');
                    } else {
                        var formatted = parseFloat(result.PharmacyRevenue).toLocaleString('en-PK', {
                            minimumFractionDigits: 0,
                            maximumFractionDigits: 0
                        });
                        $('#lblPharmacyRevenue').text(formatted);
                        $('#lblPharmacyDate').text(result.DateRange);
                    }
                },
                error: function () {
                    $('#lblPharmacyRevenue').text('0');
                }
            });
        }

        function LoadLabRadiologyRevenue(period) {
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetLabRadiologyRevenue",
                data: JSON.stringify({ 'period': period }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var result = JSON.parse(data.d);
                    if (result.Error) {
                        $('#lblLabRevenue').text('0');
                        $('#lblLabDate').text('Error loading data');
                    } else {
                        var formatted = parseFloat(result.LabRevenue).toLocaleString('en-PK', {
                            minimumFractionDigits: 0,
                            maximumFractionDigits: 0
                        });
                        $('#lblLabRevenue').text(formatted);
                        $('#lblLabDate').text(result.DateRange);
                    }
                },
                error: function () {
                    $('#lblLabRevenue').text('0');
                }
            });
        }

        function LoadOPDChart(period) {
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetOPDChartData",
                data: JSON.stringify({ 'period': period }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var result = JSON.parse(data.d);
                    if (!result.Error) {
                        renderOPDSummaryChart(result.TotalPatients, result.NewOPD, result.RevisitOPD);
                    }
                }
            });
        }

        var chartOPDSummary; 

        function renderOPDSummaryChart(total, newOPD, revisitOPD) {
            const options = {
                series: [newOPD, revisitOPD],
                chart: {
                    type: 'donut',
                    height: 300,
                    toolbar: { show: false }
                },
                labels: ['New OPD', 'Revisit OPD'],
                colors: ['#00C49F', '#0088FE'],
                plotOptions: {
                    pie: {
                        donut: {
                            size: '70%',
                            labels: {
                                show: true,
                                total: {
                                    show: true,
                                    label: 'Total Visits',
                                    color: '#8e0016',
                                    formatter: function () { return total; }
                                }
                            }
                        }
                    }
                },
                legend: { position: 'bottom' },
                dataLabels: { enabled: false }
            };

            if (chartOPDSummary) {
                chartOPDSummary.destroy();
            }
            chartOPDSummary = new ApexCharts(document.querySelector("#chartOPDSummary"), options);
            chartOPDSummary.render();
        }

        function LoadOPDVolume(period) {
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetOPDVolumeData",
                data: JSON.stringify({ 'period': period }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var r = JSON.parse(response.d);
                    if (!r.Error) {

                        $('#lblTotalVolume').text(r.Total.toLocaleString());
                        $('#lblGeneralCount').text(r.GeneralCount + ' PTS');
                        $('#lblPrivateCount').text(r.PrivateCount + ' PTS');

                        $('#barGeneral').css('width', r.GeneralPerc + '%');
                        $('#barPrivate').css('width', r.PrivatePerc + '%');
                    }
                }
            });
        }

        function LoadWaitTimeTrends(period) {
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetWaitTimeAndSnapshot",
                data: JSON.stringify({ 'period': period }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = typeof response.d === 'string' ? JSON.parse(response.d) : response.d;

                    if (data.Error) {
                        console.error("Dashboard Error: " + data.Error);
                        return;
                    }

                    $('#lblAvgGeneral').text(data.AvgGeneral);
                    $('#lblAvgPrivate').text(data.AvgPrivate);


                    $('#lblDiagCount').text(data.DiagCount);
                    $('#lblPhysioCount').text(data.PhysioCount);
                },
                error: function (xhr, status, error) {
                    console.error("AJAX Error: " + error);
                }
            });
        }

        var chartBilling = null; // Variable to hold the ApexChart instance

        function LoadBillingData(period) {
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetBillingSnapshot",
                data: JSON.stringify({ 'period': period }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var r = JSON.parse(response.d);
                    $('#lblLabOrders').text(r.LabCount);
                    $('#lblUltrasoundOrders').text(r.UltrasoundCount);
                    $('#lblXRayOrders').text(r.XRayCount);
                    $('#lblCardioOrders').text(r.CardioCount);
                    $('#lblPhysioCount').text(r.PhysioCount);

                    var totalDiag = r.LabCount + r.UltrasoundCount + r.XRayCount + r.CardioCount;
                    $('#lblDiagCount').text(totalDiag);
                    var options = {
                        series: [{
                            name: 'Orders',
                            data: [r.LabCount, r.UltrasoundCount, r.XRayCount, r.CardioCount]
                        }],
                        chart: {
                            type: 'bar',
                            height: 150,
                            toolbar: { show: false }
                        },
                        colors: ['#5c6bc0'],
                        plotOptions: {
                            bar: {
                                borderRadius: 4,
                                columnWidth: '45%',
                                distributed: false,
                            }
                        },
                        dataLabels: { enabled: false },
                        xaxis: {
                            categories: ['LAB', 'U/S', 'X-RAY', 'CARDIO'],
                            axisBorder: { show: false },
                            axisTicks: { show: false }
                        },
                        yaxis: { show: false },
                        grid: { show: false }
                    };

                    if (chartBilling) {
                        chartBilling.destroy();
                    }

                    chartBilling = new ApexCharts(document.querySelector("#billingChart"), options);
                    chartBilling.render();
                },
                error: function (xhr, status, error) {
                    console.error("AJAX Error: " + error);
                }
            });
        }

        var pharmacyDistChart = null;

        function LoadPharmacySnapshot(period) {
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetPharmacySnapshot",
                data: JSON.stringify({ 'period': period }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var r = JSON.parse(response.d);

                    $('#lblPhHospital').text(r.HospitalCount);
                    $('#lblPhWalkin').text(r.WalkinCount);

                    var options = {
                        series: [r.HospitalCount, r.WalkinCount],
                        chart: {
                            type: 'donut',
                            height: 280,
                            toolbar: { show: false }
                        },
                        labels: ['Hospital', 'Walk-in'],
                        colors: ['#10b981', '#94a3b8'],
                        stroke: {
                            show: true,
                            width: 5, 
                            colors: ['#ffffff']
                        },
                        plotOptions: {
                            pie: {
                                startAngle: 0,
                                endAngle: 360,
                                expandOnClick: false,
                                donut: {
                                    size: '75%',
                                    labels: {
                                        show: false
                                    }
                                }
                            }
                        },
                        fill: {
                            type: 'solid'
                        },
                        dataLabels: { enabled: false },
                        legend: {
                            position: 'bottom',
                            markers: { radius: 12 }
                        },
                        tooltip: { enabled: true }
                    };

                    if (pharmacyDistChart) {
                        pharmacyDistChart.destroy();
                    }
                    pharmacyDistChart = new ApexCharts(document.querySelector("#chartPharmacyDistribution"), options);
                    pharmacyDistChart.render();
                }
            });
        }

        function LoadDialysisLive(period) {
            let periodLabel = "Today's Snapshot";
            if (period === 'week') periodLabel = "Weekly Overview";
            if (period === 'month') periodLabel = "Monthly Overview";
            $('#lblPeriodText').text(periodLabel);

            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetDialysisSnapshot",
                data: JSON.stringify({ 'period': period }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    const data = JSON.parse(response.d);
                    $('#txtActiveCount').text(data.ActiveSessions);
                    $('#txtPerformedCount').text(data.PerformedToday);
                    $('#lblLargeActive').text(data.ActiveNow);
                    let maxVal = data.PerformedToday > 0 ? data.PerformedToday : 10;
                    let activeWidth = (data.ActiveSessions / maxVal) * 100;

                    $('#barActive').css('width', Math.min(activeWidth, 100) + '%');
                    $('#barPerformed').css('width', '100%');
                },
                error: function (error) {
                    console.error("Dialysis AJAX Error:", error);
                }
            });
        }

    </script>

     <style type="text/css">
        .revenue-card {
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            border-left: 4px solid #28a745;
            margin: 20px 0;
        }
        .card-title { font-size: 12px; color: #6c757d; text-transform: uppercase; margin-bottom: 8px; }
        .card-value { font-size: 28px; font-weight: bold; color: #212529; }
        .card-date { font-size: 11px; color: #6c757d; margin-top: 5px; }
    </style>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-2">
            <label>Select Period</label>
            <select id="ddlPeriod" class="form-control">
                <option value="today">Today</option>
                <option value="week">This Week</option>
                <option value="month">This Month</option>
                <option value="year">This Year</option>
            </select>
        </div>
    </div>
    <div class="row">
        <div class="col-lg-3 col-md-6">
            <div class="revenue-card">
                <div class="card-title">Total Hospital Revenue</div>
                <div class="card-value">Rs. <span id="lblRevenue">0</span></div>
                <div class="card-date" id="lblRevenueDate">Loading...</div>
            </div>
        </div>
        <div class="col-lg-3 col-md-6">
        <div class="revenue-card" style="border-left-color: #007bff;"> <div class="card-title">OPD Sale Revenue</div>
            <div class="card-value">Rs. <span id="lblOPDRevenue">0</span></div>
            <div class="card-date" id="lblOPDDate">Loading...</div>
        </div>
    </div>
        <div class="col-lg-3 col-md-6">
            <div class="revenue-card" style="border-left-color: #dc3545;">
                <div class="card-title">Pharmacy Sale Revenue</div>
                <div class="card-value">Rs. <span id="lblPharmacyRevenue">0</span></div>
                <div class="card-date" id="lblPharmacyDate">Loading...</div>
            </div>
        </div>
        <div class="col-lg-3 col-md-6">
            <div class="revenue-card" style="border-left-color: #6610f2;">
                <div class="card-title">Lab & Radiology Revenue</div>
                <div class="card-value">Rs. <span id="lblLabRevenue">0</span></div>
                <div class="card-date" id="lblLabDate">Loading...</div>
            </div>
        </div>
        </div>
    <div class="row">
        <div class="col-lg-4">
            <div class="revenue-card">
                <h4 style="font-size: 16px; font-weight: bold; margin-bottom: 20px; color: #333;">OPD Operation HUB
                </h4>
                <div id="chartOPDSummary"></div>
            </div>
        </div>
        <div class="col-lg-4">
            <div class="revenue-card" style="border-left: none;">
                <div class="card-title">Total OPD Volume</div>
                <div class="card-value" id="lblTotalVolume">0</div>
                <div class="card-date" style="text-transform: uppercase; margin-bottom: 20px;">Visits</div>

                <div style="margin-bottom: 15px;">
                    <div style="display: flex; justify-content: space-between; font-size: 12px; font-weight: bold; margin-bottom: 5px;">
                        <span>GENERAL FC</span>
                        <span id="lblGeneralCount">0 PTS</span>
                    </div>
                    <div style="background: #f0f0f0; height: 8px; border-radius: 4px;">
                        <div id="barGeneral" style="background: #3b71ca; height: 100%; width: 0%; border-radius: 4px; transition: width 0.5s;"></div>
                    </div>
                </div>

                <div>
                    <div style="display: flex; justify-content: space-between; font-size: 12px; font-weight: bold; margin-bottom: 5px;">
                        <span>PRIVATE FC</span>
                        <span id="lblPrivateCount">0 PTS</span>
                    </div>
                    <div style="background: #f0f0f0; height: 8px; border-radius: 4px;">
                        <div id="barPrivate" style="background: #9fa8da; height: 100%; width: 0%; border-radius: 4px; transition: width 0.5s;"></div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-lg-4">
            <div class="revenue-card" style="border-left: none; background-color: #f8faff; border: 1px solid #e0e0e0; border-radius: 8px; padding: 20px;">
                <div style="padding-bottom: 15px;">
                    <h4 style="font-size: 14px; font-weight: bold; color: #333; margin-bottom: 15px; text-transform: uppercase; letter-spacing: 0.5px;">Wait Time Trends
                    </h4>
                    <div style="display: flex; justify-content: space-between; margin-top: 10px;">
                        <span style="color: #6c757d; font-size: 13px;">AVG General (FC)</span>
                        <span style="font-weight: bold; color: #00234b;"><span id="lblAvgGeneral">0</span> MIN</span>
                    </div>
                    <div style="display: flex; justify-content: space-between; margin-top: 10px;">
                        <span style="color: #6c757d; font-size: 13px;">AVG Private (CC)</span>
                        <span style="font-weight: bold; color: #00234b;"><span id="lblAvgPrivate">0</span> MIN</span>
                    </div>
                </div>

                <hr style="border-top: 1px solid #e9ecef; margin: 15px 0;" />

                <div style="padding-top: 5px;">
                    <h4 style="font-size: 14px; font-weight: bold; color: #333; margin-bottom: 15px; text-transform: uppercase; letter-spacing: 0.5px;">Footfall Snapshot
                    </h4>
                    <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                        <div style="border: 1px solid #dee2e6; border-radius: 20px; padding: 4px 15px; font-size: 11px; font-weight: bold; background: #fff; color: #333; display: flex; align-items: center;">
                            <span style="height: 6px; width: 6px; background-color: #3b71ca; border-radius: 50%; margin-right: 8px;"></span>
                            DIAG: <span id="lblDiagCount" style="margin-left: 5px;">0</span>
                        </div>
                        <div style="border: 1px solid #dee2e6; border-radius: 20px; padding: 4px 15px; font-size: 11px; font-weight: bold; background: #fff; color: #333; display: flex; align-items: center;">
                            <span style="height: 6px; width: 6px; background-color: #9fa8da; border-radius: 50%; margin-right: 8px;"></span>
                            PHYSIO: <span id="lblPhysioCount" style="margin-left: 5px;">0</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-lg-4">
    <div class="dashboard-card dialysis-card" style="border-radius: 20px; padding: 25px; background: #fff; border: 1px solid #f0f0f0; box-shadow: 0 4px 20px rgba(0,0,0,0.02); min-height: 400px;">
        
        <div style="display: flex; align-items: center; margin-bottom: 30px;">
            <div style="background: #fff1f2; padding: 10px; border-radius: 10px; margin-right: 15px; color: #e11d48;">
                <i class="fa fa-heartbeat" style="font-size: 18px;"></i>
            </div>
            <div>
                <h4 style="margin: 0; font-size: 14px; font-weight: 800; color: #4b5563; text-transform: uppercase; letter-spacing: 1px;">Dialysis Monitoring</h4>
                <small style="color: #94a3b8; font-weight: 600;" id="lblPeriodText">Today's Snapshot</small>
            </div>
        </div>

        <div style="margin-bottom: 35px;">
            <div style="margin-bottom: 20px;">
                <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 8px;">
                    <span style="font-size: 12px; color: #64748b; font-weight: 700; text-transform: uppercase;">Active Sessions</span>
                    <span id="txtActiveCount" style="font-size: 16px; color: #e11d48; font-weight: 800;">0</span>
                </div>
                <div style="width: 100%; background: #f1f5f9; height: 10px; border-radius: 5px; overflow: hidden;">
                    <div id="barActive" style="width: 0%; background: linear-gradient(90deg, #fb7185, #e11d48); height: 100%; transition: width 1s cubic-bezier(0.17, 0.67, 0.83, 0.67);"></div>
                </div>
            </div>

            <div>
                <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 8px;">
                    <span style="font-size: 12px; color: #64748b; font-weight: 700; text-transform: uppercase;">Performed Sessions</span>
                    <span id="txtPerformedCount" style="font-size: 16px; color: #10b981; font-weight: 800;">0</span>
                </div>
                <div style="width: 100%; background: #f1f5f9; height: 10px; border-radius: 5px; overflow: hidden;">
                    <div id="barPerformed" style="width: 0%; background: linear-gradient(90deg, #34d399, #10b981); height: 100%; transition: width 1s cubic-bezier(0.17, 0.67, 0.83, 0.67);"></div>
                </div>
            </div>
        </div>

        <div style="background: #fff1f2; border-radius: 18px; padding: 22px; border: 1px solid #ffe4e6; position: relative; overflow: hidden;">
            <div style="position: relative; z-index: 2;">
                <div style="font-size: 11px; font-weight: 800; color: #e11d48; text-transform: uppercase; margin-bottom: 5px; display: flex; align-items: center;">
                    <span style="display: inline-block; width: 8px; height: 8px; background: #e11d48; border-radius: 50%; margin-right: 8px; animation: pulse 1.5s infinite;"></span>
                    Live Now
                </div>
                <div style="font-size: 42px; font-weight: 900; color: #1f2937; letter-spacing: -1px;" id="lblLargeActive">0</div>
            </div>
            <i class="fa fa-area-chart" style="position: absolute; right: -10px; bottom: -10px; font-size: 80px; color: #fb7185; opacity: 0.1; transform: rotate(-15deg);"></i>
        </div>
    </div>
</div>
        <div class="col-lg-4">
        <div class="card" style="border-radius: 15px; padding: 20px; background: #fff; border: 1px solid #f0f0f0;">
            <div style="display: flex; align-items: center; margin-bottom: 20px; color: #5c6bc0;">
                <i class="fa fa-file-text-o" style="margin-right: 10px;"></i>
                <span style="font-weight: bold; text-transform: uppercase; font-size: 13px;">Lab & Radiology</span>
            </div>

            <div style="height: 150px; margin-bottom: 20px;">
                <div id="billingChart"></div>
            </div>

            <div style="display: flex; flex-direction: column; gap: 12px;">
                <div style="display: flex; justify-content: space-between; font-size: 12px;">
                    <span style="color: #6c757d; font-weight: 500;">LAB</span>
                    <span style="font-weight: bold;"><span id="lblLabOrders">0</span> ORDERS</span>
                </div>
                <div style="display: flex; justify-content: space-between; font-size: 12px;">
                    <span style="color: #6c757d; font-weight: 500;">ULTRASOUND</span>
                    <span style="font-weight: bold;"><span id="lblUltrasoundOrders">0</span> ORDERS</span>
                </div>
                <div style="display: flex; justify-content: space-between; font-size: 12px;">
                    <span style="color: #6c757d; font-weight: 500;">X-RAY</span>
                    <span style="font-weight: bold;"><span id="lblXRayOrders">0</span> ORDERS</span>
                </div>
                <div style="display: flex; justify-content: space-between; font-size: 12px;">
                    <span style="color: #6c757d; font-weight: 500;">CARDIOLOGY</span>
                    <span style="font-weight: bold;"><span id="lblCardioOrders">0</span> ORDERS</span>
                </div>
            </div>
        </div>
    </div>
        <div class="col-lg-4">
    <div class="revenue-card" style="border-radius: 20px; padding: 25px; background: #fff; border: 1px solid #f0f0f0; border-left: none; box-shadow: 0 4px 20px rgba(0,0,0,0.02);">
        
        <div style="display: flex; align-items: center; margin-bottom: 25px;">
            <div style="background: #ecfdf5; padding: 8px; border-radius: 8px; margin-right: 12px; color: #10b981;">
                <i class="fa fa-database"></i>
            </div>
            <span style="font-weight: 800; text-transform: uppercase; font-size: 13px; color: #4b5563; letter-spacing: 0.5px;">Pharmacy Branch 1</span>
        </div>

        <div style="height: 250px; margin-bottom: 30px;">
            <div id="chartPharmacyDistribution"></div>
        </div>

        <div style="display: flex; gap: 15px;">
            <div style="flex: 1; background: #f9fafb; padding: 15px; border-radius: 12px; text-align: center; border: 1px solid #f3f4f6;">
                <div style="font-size: 10px; color: #9ca3af; text-transform: uppercase; font-weight: 800; margin-bottom: 5px;">Hospital</div>
                <div style="font-size: 22px; font-weight: 800; color: #1f2937;" id="lblPhHospital">0</div>
            </div>
            <div style="flex: 1; background: #f9fafb; padding: 15px; border-radius: 12px; text-align: center; border: 1px solid #f3f4f6;">
                <div style="font-size: 10px; color: #9ca3af; text-transform: uppercase; font-weight: 800; margin-bottom: 5px;">Walk-in</div>
                <div style="font-size: 22px; font-weight: 800; color: #1f2937;" id="lblPhWalkin">0</div>
            </div>
        </div>

    </div>
</div>

        </div>
    <div class="row">
        <div class="col-lg-8">
            <div class="dashboard-card" style="border-radius: 20px; padding: 25px; background: #fff; border: 1px solid #f0f0f0; min-height: 400px;">

                <div style="display: flex; align-items: center; margin-bottom: 25px;">
                    <div style="background: #fef2f2; padding: 10px; border-radius: 10px; margin-right: 15px; color: #ef4444;">
                        <i class="fa fa-map-marker" style="font-size: 18px;"></i>
                    </div>
                    <div>
                        <h4 style="margin: 0; font-size: 14px; font-weight: 800; color: #4b5563; text-transform: uppercase; letter-spacing: 1px;">Regional Patient Heatmap</h4>
                        <small style="color: #94a3b8; font-weight: 600;">Distribution by Location</small>
                    </div>
                </div>

                <div id="heatmapContainer" style="display: flex; flex-direction: column; gap: 15px;">
                </div>
            </div>
        </div>
    </div>
</asp:Content>
