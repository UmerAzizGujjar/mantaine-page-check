<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Chief_Executive_Dashboard.aspx.cs" Inherits="PMS.Modules.Dashboards.Chief_Executive_Dashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/echarts@5/dist/echarts.min.js"></script>
    <script type="text/javascript">
        var opdChartInstance = null;
        var billingChartInstance = null;
        var pharmacyChartInstance = null;
        var clinicalChartInstance = null;
        var satisfactionChartInstance = null;

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
            LoadRegionalHeatmap("today");
            renderClinicalOutcomes();
            renderSatisfaction();

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
                LoadRegionalHeatmap(period);
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
                error: function () {
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

        function renderOPDSummaryChart(total, newOPD, revisitOPD) {
            $('#lblOPDTotal').text(total);
            $('#lblNewOPD').text(newOPD);
            $('#lblReturnOPD').text(revisitOPD);
            if (total > 0) {
                $('#lblNewPct').text('(' + Math.round(newOPD / total * 100) + '%)');
                $('#lblReturnPct').text('(' + Math.round(revisitOPD / total * 100) + '%)');
            } else {
                $('#lblNewPct').text('');
                $('#lblReturnPct').text('');
            }

            var dom = document.querySelector("#chartOPDSummary");
            if (opdChartInstance) opdChartInstance.dispose();
            opdChartInstance = echarts.init(dom);
            var option = {
                tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
                series: [{
                    type: 'pie',
                    radius: ['55%', '75%'],
                    avoidLabelOverlap: false,
                    label: { show: false },
                    data: [
                        { value: newOPD, name: 'New Patients', itemStyle: { color: '#00C49F' } },
                        { value: revisitOPD, name: 'Returning', itemStyle: { color: '#0088FE' } }
                    ]
                }],
                graphic: [{
                    type: 'text',
                    left: 'center',
                    top: 'center',
                    style: {
                        text: total,
                        fill: '#8e0016',
                        fontSize: 16,
                        fontWeight: 'bold',
                        textAlign: 'center',
                        lineHeight: 20
                    },
                    z: 100
                }]
            };
            opdChartInstance.setOption(option);
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
                    if (data.Error) { console.error("Dashboard Error: " + data.Error); return; }
                    $('#lblAvgGeneral').text(data.AvgGeneral);
                    $('#lblAvgPrivate').text(data.AvgPrivate);
                    $('#lblDiagCount').text(data.DiagCount);
                    $('#lblPhysioCount').text(data.PhysioCount);
                },
                error: function (xhr, status, error) { console.error("AJAX Error: " + error); }
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
                    var totalDiag = r.LabCount + r.UltrasoundCount + r.XRayCount + r.CardioCount;
                    $('#lblDiagCount').text(totalDiag);
                    var dom = document.querySelector("#billingChart");
                    if (billingChartInstance) billingChartInstance.dispose();
                    billingChartInstance = echarts.init(dom);
                    var option = {
                        tooltip: { trigger: 'axis' },
                        grid: { left: 0, right: 0, top: 5, bottom: 20 },
                        xAxis: {
                            type: 'category',
                            data: ['LAB', 'U/S', 'X-RAY', 'CARDIO'],
                            axisLabel: { fontSize: 9 },
                            axisLine: { show: false },
                            axisTick: { show: false }
                        },
                        yAxis: { type: 'value', show: false, min: 0 },
                        series: [{
                            type: 'bar',
                            data: [
                                { value: r.LabCount, itemStyle: { color: '#5c6bc0' } },
                                { value: r.UltrasoundCount, itemStyle: { color: '#5c6bc0' } },
                                { value: r.XRayCount, itemStyle: { color: '#5c6bc0' } },
                                { value: r.CardioCount, itemStyle: { color: '#5c6bc0' } }
                            ],
                            barWidth: '45%',
                            itemStyle: { borderRadius: [4, 4, 0, 0] }
                        }]
                    };
                    billingChartInstance.setOption(option);
                },
                error: function () { console.error("Billing AJAX Error"); }
            });
        }

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

                    var dom = document.querySelector("#chartPharmacyDistribution");
                    if (pharmacyChartInstance) pharmacyChartInstance.dispose();
                    pharmacyChartInstance = echarts.init(dom);
                    var option = {
                        tooltip: { trigger: 'item', formatter: '{b}: {c}' },
                        legend: { bottom: 0, left: 'center', icon: 'circle', itemWidth: 8, itemHeight: 8, textStyle: { fontSize: 10 } },
                        series: [{
                            type: 'pie',
                            radius: ['45%', '60%'],
                            center: ['50%', '45%'],
                            avoidLabelOverlap: false,
                            label: { show: false },
                            data: [
                                { value: r.HospitalCount, name: 'Hospital', itemStyle: { color: '#10b981' } },
                                { value: r.WalkinCount, name: 'Walk-in', itemStyle: { color: '#94a3b8' } }
                            ]
                        }]
                    };
                    pharmacyChartInstance.setOption(option);
                }
            });
        }

        function renderClinicalOutcomes() {
            var dom = document.querySelector("#chartClinicalOutcomes");
            if (clinicalChartInstance) clinicalChartInstance.dispose();
            clinicalChartInstance = echarts.init(dom);
            var option = {
                tooltip: { trigger: 'axis' },
                legend: { data: ['Deaths', 'Discharges', 'Referrals'], top: 0, right: 0, icon: 'circle', itemWidth: 6, itemHeight: 6, textStyle: { fontSize: 9 } },
                grid: { left: 25, right: 5, top: 18, bottom: 5 },
                xAxis: {
                    type: 'category',
                    data: ['IPD', 'ER'],
                    axisLine: { show: false },
                    axisTick: { show: false },
                    axisLabel: { fontSize: 10, fontWeight: 600 }
                },
                yAxis: { type: 'value', show: false, min: 0 },
                series: [
                    {
                        name: 'Deaths',
                        type: 'bar',
                        data: [5, 3],
                        itemStyle: { color: '#ef4444', borderRadius: [2,2,0,0] },
                        barWidth: 18,
                        barGap: '15%'
                    },
                    {
                        name: 'Discharges',
                        type: 'bar',
                        data: [120, 85],
                        itemStyle: { color: '#10b981', borderRadius: [2,2,0,0] },
                        barWidth: 18
                    },
                    {
                        name: 'Referrals',
                        type: 'bar',
                        data: [15, 10],
                        itemStyle: { color: '#f97316', borderRadius: [2,2,0,0] },
                        barWidth: 18
                    }
                ]
            };
            clinicalChartInstance.setOption(option);
        }

        function renderSatisfaction() {
            var dom = document.querySelector("#chartSatisfaction");
            if (satisfactionChartInstance) satisfactionChartInstance.dispose();
            satisfactionChartInstance = echarts.init(dom);
            var option = {
                tooltip: { trigger: 'item', formatter: '{b}: {c}%' },
                series: [{
                    type: 'pie',
                    radius: ['30%', '80%'],
                    center: ['50%', '50%'],
                    avoidLabelOverlap: false,
                    label: { show: false },
                    data: [
                        { value: 75, name: 'Satisfied', itemStyle: { color: '#10b981' } },
                        { value: 18, name: 'Neutral', itemStyle: { color: '#f59e0b' } },
                        { value: 7, name: 'Unsatisfied', itemStyle: { color: '#ef4444' } }
                    ]
                }]
            };
            satisfactionChartInstance.setOption(option);
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
                error: function () { console.error("Dialysis AJAX Error"); }
            });
        }

        function LoadRegionalHeatmap(period) {
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetRegionalHeatmap",
                data: JSON.stringify({ 'period': period }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    const data = JSON.parse(response.d);
                    const container = $('#heatmapContainer');
                    container.empty();
                    if (data.length === 0) {
                        container.append('<div style="text-align:center;padding:20px;color:#94a3b8;">No data available for this period</div>');
                        return;
                    }
                    const maxCount = data[0].Counts;
                    data.forEach(item => {
                        const percentage = (item.Counts / maxCount) * 100;
                        const rowHtml = `
                            <div class="heat-row">
                                <span class="heat-label" title="${item.AreaName}">${item.AreaName}</span>
                                <div class="heat-bar-bg">
                                    <div class="heat-bar-fill" style="width:${percentage}%"></div>
                                </div>
                                <span class="heat-count">${item.Counts}</span>
                            </div>`;
                        container.append(rowHtml);
                    });
                },
                error: function () { console.error("Heatmap Error"); }
            });
        }
    </script>

    <style type="text/css">
        .bento-grid {
            display: grid;
            grid-template-columns: 0.9fr 1.8fr 1fr 1fr;
            gap: 12px;
            grid-template-areas:
                "period period period period"
                "left opd opd dia"
                "left trend trend ph"
                "left trend trend lab"
                "left trend trend lab";
        }
        #left-stack { grid-area: left; align-self: start; display: flex; flex-direction: column; gap: 10px; }
        #left-stack .rev-item { min-height: auto; }
        #left-stack .rev-item .rev-label {
            font-size: 10px;
            color: #6b7280;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 4px;
        }
        #left-stack .rev-item .rev-value {
            font-size: 19px;
            font-weight: 700;
            color: #111827;
        }
        #left-stack .rev-item .rev-date {
            font-size: 9px;
            color: #9ca3af;
            margin-top: 3px;
        }
        .bento-item {
            background: #fff;
            border-radius: 10px;
            padding: 14px;
            border: 1px solid #f0f0f0;
            transition: box-shadow 0.25s ease, transform 0.25s ease, border-color 0.25s ease;
        }
        .bento-item:hover {
            box-shadow: 0 8px 25px rgba(0,0,0,0.08);
            border-color: #e5e7eb;
            transform: translateY(-1px);
        }
        .bento-item.period-bar {
            grid-area: period;
            display: flex;
            align-items: center;
            gap: 12px;
            min-height: auto;
            padding: 10px 14px;
        }
        .bento-item.period-bar label {
            margin: 0;
            font-weight: 600;
            font-size: 13px;
            color: #374151;
            white-space: nowrap;
        }
        .bento-item.period-bar select {
            max-width: 180px;
        }
        .bento-item.rev-item .rev-label {
            font-size: 10px;
            color: #6b7280;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 4px;
        }
        .bento-item.rev-item .rev-value {
            font-size: 19px;
            font-weight: 700;
            color: #111827;
        }
        .bento-item.rev-item .rev-date {
            font-size: 9px;
            color: #9ca3af;
            margin-top: 3px;
        }

        #opd-area { grid-area: opd; align-self: start; }
        #trend-area { grid-area: trend; align-self: start; display: flex; flex-direction: column; }
        #trend-area .main-inner { flex: 1; }
        #trend-area .heat-card {
            margin-top: 12px;
            padding: 12px;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            background: #fff;
            transition: box-shadow 0.2s;
        }
        #trend-area .heat-card:hover {
            box-shadow: 0 1px 4px rgba(0,0,0,0.08);
            border-color: #d1d5db;
        }
        .main-heading {
            font-size: 14px;
            font-weight: 700;
            color: #1f2937;
            margin-bottom: 8px;
        }
        .main-inner {
            display: flex;
            gap: 10px;
            align-items: stretch;
        }
        .main-sub {
            flex: 1;
            background: #f9fafb;
            border-radius: 8px;
            padding: 8px;
            display: flex;
            flex-direction: column;
        }
        .main-sub .ms-title {
            font-size: 11px;
            font-weight: 700;
            color: #374151;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 4px;
        }

        .hub-stats-top {
            display: flex;
            gap: 8px;
            margin-bottom: 6px;
        }
        .hub-stat-box {
            flex: 1;
            text-align: center;
            padding: 4px 6px;
            border-radius: 6px;
            background: #fff;
        }
        .hub-stat-box .hs-label {
            font-size: 9px;
            color: #6b7280;
            text-transform: uppercase;
            font-weight: 600;
        }
        .hub-stat-box .hs-value {
            font-size: 16px;
            font-weight: 700;
        }
        .hub-stat-box .hs-value.total-c { color: #8e0016; }
        .hub-stat-box .hs-value.new-c { color: #00C49F; }
        .hub-stat-box .hs-value.return-c { color: #0088FE; }
        .hub-stat-box .hs-pct {
            font-size: 9px;
            color: #9ca3af;
            margin-left: 2px;
        }
        .hub-chart-wrap {
            height: 100px;
            width: 100%;
        }

        .vol-sub .vs-number {
            font-size: 20px;
            font-weight: 700;
            color: #111827;
            margin-bottom: 2px;
        }
        .vol-sub .vs-visits {
            font-size: 9px;
            color: #9ca3af;
            text-transform: uppercase;
            margin-bottom: 8px;
        }
        .vol-bar-group { margin-bottom: 6px; }
        .vol-bar-group:last-child { margin-bottom: 0; }
        .vol-bar-header {
            display: flex;
            justify-content: space-between;
            font-size: 10px;
            font-weight: 600;
            margin-bottom: 3px;
            color: #4b5563;
        }
        .vol-bar-track {
            background: #e5e7eb;
            height: 6px;
            border-radius: 3px;
            overflow: hidden;
        }
        .vol-bar-fill {
            height: 100%;
            border-radius: 3px;
            transition: width 0.5s;
        }
        .vol-bar-fill.general { background: #3b71ca; }
        .vol-bar-fill.private { background: #9fa8da; }

        .wtf-row {
            display: flex;
            justify-content: space-between;
            font-size: 11px;
            color: #4b5563;
            margin-bottom: 4px;
        }
        .wtf-row .wtf-label { color: #6b7280; }
        .wtf-row .wtf-value { font-weight: 700; color: #00234b; }
        .wtf-divider {
            border: none;
            border-top: 1px solid #e5e7eb;
            margin: 6px 0;
        }
        .footfall-pills {
            display: flex;
            gap: 6px;
            flex-wrap: wrap;
        }
        .footfall-pill {
            border: 1px solid #e5e7eb;
            border-radius: 14px;
            padding: 2px 10px;
            font-size: 10px;
            font-weight: 600;
            background: #fff;
            color: #374151;
            display: flex;
            align-items: center;
        }
        .footfall-pill .dot {
            width: 5px;
            height: 5px;
            border-radius: 50%;
            margin-right: 5px;
        }
        .footfall-pill .dot.diag { background: #3b71ca; }
        .footfall-pill .dot.physio { background: #9fa8da; }

        .trend-sub .ts-badge {
            font-size: 9px;
            color: #8e0016;
            background: #fce4ec;
            padding: 1px 8px;
            border-radius: 10px;
            display: inline-block;
            align-self: flex-start;
            margin-bottom: 8px;
            font-weight: 600;
        }
        .trend-sub .ts-metrics {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 5px;
        }
        .trend-sub .ts-row {
            display: flex;
            justify-content: space-between;
            font-size: 11px;
            padding: 4px 6px;
            background: #fff;
            border-radius: 4px;
        }
        .trend-sub .ts-lbl {
            color: #6b7280;
        }
        .trend-sub .ts-val {
            font-weight: 600;
            color: #374151;
        }
        .trend-sub .ts-total {
            background: #f0fdf4;
        }
        .trend-sub .ts-total .ts-lbl {
            color: #166534;
            font-weight: 700;
        }
        .trend-sub .ts-total .ts-val {
            color: #16a34a;
        }
        .trend-sub .ts-expand {
            font-size: 9px;
            color: #2563eb;
            cursor: pointer;
            margin-top: 8px;
            align-self: flex-start;
            font-weight: 600;
        }
        .trend-sub .ts-expand:hover {
            text-decoration: underline;
        }
        #dia { grid-area: dia; align-self: start; }
        #ph { grid-area: ph; align-self: start; }
        #lab { grid-area: lab; align-self: start; }


        .bento-item .sect-title {
            font-size: 11px;
            font-weight: 700;
            color: #374151;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 8px;
        }
        .bento-item .sect-title i { margin-right: 6px; }

        .dia-header {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 10px;
        }
        .dia-icon {
            background: #fff1f2;
            padding: 8px;
            border-radius: 8px;
            color: #e11d48;
        }
        .dia-header-text small { color: #94a3b8; font-weight: 600; font-size: 11px; display: block; }

        .dia-bar-group { margin-bottom: 10px; }
        .dia-bar-header {
            display: flex;
            justify-content: space-between;
            font-size: 11px;
            font-weight: 700;
            color: #64748b;
            text-transform: uppercase;
            margin-bottom: 5px;
        }
        .dia-bar-header .dia-count { font-size: 14px; }
        .dia-bar-track {
            background: #f1f5f9;
            height: 8px;
            border-radius: 4px;
            overflow: hidden;
        }
        .dia-bar-fill { height: 100%; border-radius: 4px; transition: width 1s; }
        .dia-bar-fill.active { background: linear-gradient(90deg, #fb7185, #e11d48); }
        .dia-bar-fill.performed { background: linear-gradient(90deg, #34d399, #10b981); }

        .dia-live-box {
            background: #fff1f2;
            border-radius: 12px;
            padding: 12px;
            border: 1px solid #ffe4e6;
            position: relative;
            overflow: hidden;
            margin-top: 10px;
        }
        .dia-live-box .live-badge {
            font-size: 10px;
            font-weight: 800;
            color: #e11d48;
            text-transform: uppercase;
            display: flex;
            align-items: center;
            gap: 6px;
            margin-bottom: 4px;
        }
        .dia-live-box .live-dot {
            width: 8px;
            height: 8px;
            background: #e11d48;
            border-radius: 50%;
            animation: pulse 1.5s infinite;
        }
        .dia-live-box .live-number {
            font-size: 36px;
            font-weight: 900;
            color: #1f2937;
            letter-spacing: -1px;
        }
        .dia-live-box .live-bg-icon {
            position: absolute;
            right: -5px;
            bottom: -5px;
            font-size: 60px;
            color: #fb7185;
            opacity: 0.1;
            transform: rotate(-15deg);
        }
        @keyframes pulse { 0%,100% { opacity: 1; } 50% { opacity: 0.3; } }

        .ph-chart-wrap { height: 130px; margin-bottom: 6px; }
        .ph-stats {
            display: flex;
            gap: 8px;
        }
        .ph-stat-box {
            flex: 1;
            background: #f9fafb;
            padding: 8px;
            border-radius: 8px;
            text-align: center;
            border: 1px solid #f3f4f6;
        }
        .ph-stat-box .ph-stat-label {
            font-size: 9px;
            color: #9ca3af;
            text-transform: uppercase;
            font-weight: 800;
            margin-bottom: 4px;
        }
        .ph-stat-box .ph-stat-value {
            font-size: 18px;
            font-weight: 800;
            color: #1f2937;
        }

        #lab { grid-area: lab; }
        .lab-icon-header {
            display: flex;
            align-items: center;
            gap: 8px;
            color: #5c6bc0;
            font-weight: 700;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 12px;
        }
        .lab-chart-wrap { height: 90px; margin-bottom: 10px; }
        .lab-order-row {
            display: flex;
            justify-content: space-between;
            font-size: 11px;
            margin-bottom: 4px;
        }
        .lab-order-row .lab-order-label { color: #6b7280; font-weight: 500; }
        .lab-order-row .lab-order-value { font-weight: 700; }

        .heat-header {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 12px;
        }
        .heat-icon {
            background: #fef2f2;
            padding: 8px;
            border-radius: 8px;
            color: #ef4444;
        }
        .heat-title {
            font-size: 13px;
            font-weight: 800;
            color: #4b5563;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .heat-subtitle {
            font-size: 11px;
            color: #94a3b8;
            font-weight: 600;
        }
        .heat-row {
            display: grid;
            grid-template-columns: 120px 1fr 40px;
            align-items: center;
            gap: 14px;
            margin-bottom: 6px;
        }
        .heat-label {
            font-size: 12px;
            font-weight: 700;
            color: #64748b;
            text-overflow: ellipsis;
            white-space: nowrap;
            overflow: hidden;
        }
        .heat-bar-bg {
            width: 100%;
            background: #f8fafc;
            height: 10px;
            border-radius: 5px;
            overflow: hidden;
        }
        .heat-bar-fill {
            height: 100%;
            background: #6366f1;
            border-radius: 5px;
            transition: width 1s ease;
        }
        .heat-count {
            font-size: 12px;
            font-weight: 800;
            color: #1e293b;
            text-align: right;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="bento-grid">
        <div class="bento-item period-bar">
            <label>Select Period</label>
            <select id="ddlPeriod" class="form-control">
                <option value="today">Today</option>
                <option value="week">This Week</option>
                <option value="month">This Month</option>
                <option value="year">This Year</option>
            </select>
        </div>

        <div id="left-stack">
            <div class="bento-item rev-item">
                <div class="rev-label">Total Hospital Revenue</div>
                <div class="rev-value">Rs. <span id="lblRevenue">0</span></div>
                <div class="rev-date" id="lblRevenueDate">Loading...</div>
            </div>
            <div class="bento-item rev-item">
                <div class="rev-label">OPD Sale Revenue</div>
                <div class="rev-value">Rs. <span id="lblOPDRevenue">0</span></div>
                <div class="rev-date" id="lblOPDDate">Loading...</div>
            </div>
            <div class="bento-item rev-item">
                <div class="rev-label">Pharmacy Revenue</div>
                <div class="rev-value">Rs. <span id="lblPharmacyRevenue">0</span></div>
                <div class="rev-date" id="lblPharmacyDate">Loading...</div>
            </div>
            <div class="bento-item rev-item">
                <div class="rev-label">Lab & Radiology Revenue</div>
                <div class="rev-value">Rs. <span id="lblLabRevenue">0</span></div>
                <div class="rev-date" id="lblLabDate">Loading...</div>
            </div>
            <div class="bento-item">
                <div class="sect-title" style="margin-bottom:6px;">Clinical Outcomes (IPD/ER)</div>
                <div id="chartClinicalOutcomes" style="height:140px;width:100%;"></div>
            </div>
            <div class="bento-item" style="padding:10px;">
                <div style="display:flex;align-items:center;gap:10px;">
                    <div style="flex-shrink:0;">
                        <div style="font-size:9px;color:#6b7280;text-transform:uppercase;font-weight:600;margin-bottom:2px;">Executive Cast</div>
                        <div style="display:flex;align-items:baseline;gap:4px;">
                            <span style="font-size:32px;font-weight:900;color:#111827;line-height:1;">4.8</span>
                            <span style="color:#10b981;font-size:12px;">&#9650;</span>
                            <span style="font-size:10px;color:#10b981;font-weight:600;">Highly Satisfied</span>
                        </div>
                    </div>
                    <div style="flex:1;height:80px;"><div id="chartSatisfaction" style="height:100%;width:100%;"></div></div>
                </div>
            </div>
        </div>

        <div class="bento-item" id="opd-area">
            <div class="main-heading">OPD Operation Hub</div>
            <div class="main-inner">
                <div class="main-sub">
                    <div class="ms-title">New vs Returning Patients</div>
                    <div class="hub-stats-top">
                        <div class="hub-stat-box">
                            <div class="hs-label">New</div>
                            <div><span class="hs-value new-c" id="lblNewOPD">0</span><span class="hs-pct" id="lblNewPct"></span></div>
                        </div>
                        <div class="hub-stat-box">
                            <div class="hs-label">Returning</div>
                            <div><span class="hs-value return-c" id="lblReturnOPD">0</span><span class="hs-pct" id="lblReturnPct"></span></div>
                        </div>
                        <div class="hub-stat-box">
                            <div class="hs-label">Total</div>
                            <div><span class="hs-value total-c" id="lblOPDTotal">0</span></div>
                        </div>
                    </div>
                    <div class="hub-chart-wrap"><div id="chartOPDSummary" style="height:100%;width:100%;"></div></div>
                </div>
                <div class="main-sub vol-sub">
                    <div class="ms-title">OPD Volume</div>
                    <div class="vs-number" id="lblTotalVolume">0</div>
                    <div class="vs-visits">Visits</div>
                    <div class="vol-bar-group">
                        <div class="vol-bar-header">
                            <span>GENERAL FC</span>
                            <span id="lblGeneralCount">0 PTS</span>
                        </div>
                        <div class="vol-bar-track">
                            <div id="barGeneral" class="vol-bar-fill general" style="width: 0%;"></div>
                        </div>
                    </div>
                    <div class="vol-bar-group">
                        <div class="vol-bar-header">
                            <span>PRIVATE FC</span>
                            <span id="lblPrivateCount">0 PTS</span>
                        </div>
                        <div class="vol-bar-track">
                            <div id="barPrivate" class="vol-bar-fill private" style="width: 0%;"></div>
                        </div>
                    </div>
                </div>
                <div class="main-sub">
                    <div class="ms-title">Wait Time Trends</div>
                    <div class="wtf-row">
                        <span class="wtf-label">AVG General (FC)</span>
                        <span class="wtf-value"><span id="lblAvgGeneral">0</span> MIN</span>
                    </div>
                    <div class="wtf-row">
                        <span class="wtf-label">AVG Private (CC)</span>
                        <span class="wtf-value"><span id="lblAvgPrivate">0</span> MIN</span>
                    </div>
                    <hr class="wtf-divider" />
                    <div class="ms-title" style="font-size:10px;margin-bottom:4px;margin-top:4px;">Footfall Snapshot</div>
                    <div class="footfall-pills">
                        <span class="footfall-pill">
                            <span class="dot diag"></span>
                            DIAG: <strong style="margin-left:3px;"><span id="lblDiagCount">0</span></strong>
                        </span>
                        <span class="footfall-pill">
                            <span class="dot physio"></span>
                            PHYSIO: <strong style="margin-left:3px;"><span id="lblPhysioCount">0</span></strong>
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <div class="bento-item" id="trend-area">
            <div class="main-heading">Trend Records &amp; Stock Analytics</div>
            <div class="main-inner">
                <div class="main-sub trend-sub">
                    <div class="ms-title">Inventory Record</div>
                    <div class="ts-badge">Month-end Closing</div>
                    <div class="ts-metrics">
                        <div class="ts-row"><span class="ts-lbl">Opening Value</span><span class="ts-val">Rs. 12,50,000</span></div>
                        <div class="ts-row"><span class="ts-lbl">Purchase Value</span><span class="ts-val">Rs. 3,20,000</span></div>
                        <div class="ts-row"><span class="ts-lbl">Purchase Return</span><span class="ts-val">Rs. 12,000</span></div>
                        <div class="ts-row"><span class="ts-lbl">Sale Value</span><span class="ts-val">Rs. 4,80,000</span></div>
                        <div class="ts-row ts-total"><span class="ts-lbl">Closing Value</span><span class="ts-val">Rs. 11,58,000</span></div>
                    </div>
                    <div class="ts-expand">&#9655; View Detailed Report</div>
                </div>
                <div class="main-sub trend-sub">
                    <div class="ms-title">Pharmacy Stock Analytics</div>
                    <div class="ts-badge">PB-1</div>
                    <div class="ts-metrics">
                        <div class="ts-row"><span class="ts-lbl">Opening Stock Value</span><span class="ts-val">Rs. 5,80,000</span></div>
                        <div class="ts-row"><span class="ts-lbl">Purchase Value</span><span class="ts-val">Rs. 1,90,000</span></div>
                        <div class="ts-row"><span class="ts-lbl">Sale Value</span><span class="ts-val">Rs. 2,60,000</span></div>
                        <div class="ts-row ts-total"><span class="ts-lbl">Closing Stock Value</span><span class="ts-val">Rs. 5,10,000</span></div>
                    </div>
                    <div class="ts-expand">&#9655; Stock Movement Report</div>
                </div>
                <div class="main-sub trend-sub">
                    <div class="ms-title">Revenue P&amp;L Summary</div>
                    <div class="ts-badge">Last 2 Months</div>
                    <div class="ts-metrics">
                        <div class="ts-row"><span class="ts-lbl">Gross Sale</span><span class="ts-val">Rs. 15,80,000</span></div>
                        <div class="ts-row"><span class="ts-lbl">Discount</span><span class="ts-val">Rs. 1,05,000</span></div>
                        <div class="ts-row"><span class="ts-lbl">Net Sale</span><span class="ts-val">Rs. 14,75,000</span></div>
                        <div class="ts-row"><span class="ts-lbl">COGS</span><span class="ts-val">Rs. 9,80,000</span></div>
                        <div class="ts-row ts-total"><span class="ts-lbl">Gross Profit</span><span class="ts-val">Rs. 4,95,000</span></div>
                    </div>
                    <div class="ts-expand">&#9655; View 12-Month Report</div>
                </div>
            </div>
            <div class="heat-card">
                <div class="heat-header">
                    <div class="heat-icon"><i class="fa fa-map-marker"></i></div>
                    <div>
                        <div class="heat-title">Regional Patient Heatmap</div>
                        <div class="heat-subtitle">Distribution by Location</div>
                    </div>
                </div>
                <div id="heatmapContainer"></div>
            </div>
        </div>

        <div class="bento-item" id="dia">
            <div class="dia-header">
                <div class="dia-icon"><i class="fa fa-heartbeat"></i></div>
                <div>
                    <div style="font-size: 13px; font-weight: 800; color: #4b5563; text-transform: uppercase; letter-spacing: 0.5px;">Dialysis</div>
                    <small id="lblPeriodText">Today's Snapshot</small>
                </div>
            </div>
            <div class="dia-bar-group">
                <div class="dia-bar-header">
                    <span>Active Sessions</span>
                    <span class="dia-count" style="color:#e11d48;" id="txtActiveCount">0</span>
                </div>
                <div class="dia-bar-track">
                    <div id="barActive" class="dia-bar-fill active" style="width: 0%;"></div>
                </div>
            </div>
            <div class="dia-bar-group">
                <div class="dia-bar-header">
                    <span>Performed Sessions</span>
                    <span class="dia-count" style="color:#10b981;" id="txtPerformedCount">0</span>
                </div>
                <div class="dia-bar-track">
                    <div id="barPerformed" class="dia-bar-fill performed" style="width: 100%;"></div>
                </div>
            </div>
            <div class="dia-live-box">
                <div class="live-badge">
                    <span class="live-dot"></span> Live Now
                </div>
                <div class="live-number" id="lblLargeActive">0</div>
                <i class="fa fa-area-chart live-bg-icon"></i>
            </div>
        </div>

        <div class="bento-item" id="ph">
            <div class="sect-title"><i class="fa fa-database" style="color:#10b981;"></i>Pharmacy Branch 1</div>
            <div class="ph-chart-wrap"><div id="chartPharmacyDistribution" style="height: 100%; width: 100%;"></div></div>
            <div class="ph-stats">
                <div class="ph-stat-box">
                    <div class="ph-stat-label">Hospital</div>
                    <div class="ph-stat-value" id="lblPhHospital">0</div>
                </div>
                <div class="ph-stat-box">
                    <div class="ph-stat-label">Walk-in</div>
                    <div class="ph-stat-value" id="lblPhWalkin">0</div>
                </div>
            </div>
        </div>

        <div class="bento-item" id="lab">
            <div class="lab-icon-header"><i class="fa fa-file-text-o"></i>Lab & Radiology</div>
            <div class="lab-chart-wrap"><div id="billingChart" style="height: 100%; width: 100%;"></div></div>
            <div class="lab-order-row">
                <span class="lab-order-label">LAB</span>
                <span class="lab-order-value"><span id="lblLabOrders">0</span> ORDERS</span>
            </div>
            <div class="lab-order-row">
                <span class="lab-order-label">ULTRASOUND</span>
                <span class="lab-order-value"><span id="lblUltrasoundOrders">0</span> ORDERS</span>
            </div>
            <div class="lab-order-row">
                <span class="lab-order-label">X-RAY</span>
                <span class="lab-order-value"><span id="lblXRayOrders">0</span> ORDERS</span>
            </div>
            <div class="lab-order-row">
                <span class="lab-order-label">CARDIOLOGY</span>
                <span class="lab-order-value"><span id="lblCardioOrders">0</span> ORDERS</span>
            </div>
        </div>


    </div>
</asp:Content>
