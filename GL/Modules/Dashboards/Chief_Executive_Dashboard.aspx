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


            $("#ddlPeriod").change(function () {
                var period = $(this).val();
                LoadHospitalRevenue(period);
                LoadOPDSaleRevenue(period);
                LoadPharmacyRevenue(period);
                LoadLabRadiologyRevenue(period);
                LoadOPDChart(period);
                LoadOPDVolume(period);
                LoadWaitTimeTrends(period);
                LoadWaitTimeTrends(period);
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
        <div class="card" style="border-radius: 15px; padding: 20px; background: #fff; border: 1px solid #f0f0f0;">
            <div style="display: flex; align-items: center; margin-bottom: 20px; color: #5c6bc0;">
                <i class="fa fa-file-text-o" style="margin-right: 10px;"></i>
                <span style="font-weight: bold; text-transform: uppercase; font-size: 13px;">Lab & Radiology</span>
            </div>

            <div id="chartContainer" style="height: 150px; margin-bottom: 20px;"></div>

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
</asp:Content>
