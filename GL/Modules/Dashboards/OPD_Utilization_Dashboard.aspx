<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OPD_Utilization_Dashboard.aspx.cs" Inherits="PMS.Modules.Dashboards.OPD_Utilization_Dashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/echarts@5.4.3/dist/echarts.min.js"></script>
    <style>
        .row-dash { margin: 0; }
        .row-dash > [class^="col-"] { padding: 0 8px; }
        .card-dash { border-radius: 12px; border: 1px solid #e4e7ec; background: #fff; margin-bottom: 16px; position:relative; }
        .card-dash .card-body { padding: 22px 24px; }
        .period-bar { background:#fff; border-radius:10px; border:1px solid #f0f0f0; display:flex; align-items:center; gap:12px; padding:10px 14px; }
        .period-bar label { margin:0; font-weight:600; font-size:13px; color:#374151; white-space:nowrap; }
        .dept-filter-box { display:flex; align-items:center; gap:6px; }
        .dept-filter-box label { font-size:12px; font-weight:700; color:#000; text-transform:uppercase; margin:0; white-space:nowrap; }
        .dept-filter-box select { width:150px; height:30px; padding:2px 6px; font-size:12px; border:1px solid #d1d5db; border-radius:6px; }
        .select2-container--default .select2-selection--single { border:1px solid #d1d5db !important; border-radius:6px !important; height:30px !important; }
        .period-pills { display: flex; gap: 6px; }
        .period-pill { border:1px solid #d1d5db; border-radius:20px; padding:4px 16px; font-size:12px; font-weight:600; background:#fff; color:#374151; cursor:pointer; transition:all .2s; }
        .period-pill:hover { border-color:#8e0016; color:#8e0016; }
        .period-pill.active { background:#8e0016; border-color:#8e0016; color:#fff; }
        .custom-date-range { display:none; gap:8px; align-items:center; }
        .custom-date-range.visible { display:flex !important; }
        .filter-label { font-size:12px; font-weight:600; color:#667085; text-transform:uppercase; letter-spacing:.5px; margin-bottom:6px; }
        .kpi-row > [class^="col-"] { display: flex; }
        .kpi-row .card-dash { width:100%; height:100%; display:flex; flex-direction:column; }
        .kpi-row .card-dash .card-body { flex:1; }
        .kpi-label { font-size:12px; font-weight:600; color:#667085; text-transform:uppercase; letter-spacing:.5px; margin-bottom:4px; }
        .kpi-value { font-size:28px; font-weight:700; color:#1a1a2e; line-height:1.2; }
        .kpi-trend { font-size:12px; margin-top:4px; }
        .kpi-trend.up { color:#12b76a; }
        .kpi-trend.down { color:#f04438; }
        .bento-chart { height:320px; width:100%; }
        .chart-title { font-size:15px; font-weight:700; color:#000 !important; margin:0 0 12px 0; }
        .no-data-msg { padding:40px; text-align:center; color:#999; font-size:14px; }
        .rev-chart { position:absolute; bottom:6px; right:6px; width:140px; height:50px; z-index:1; }
    </style>
    <script type="text/javascript">
        var _dt = '', _dts = '';
        $(document).ready(function () {
            $(".datepicker").datepicker({ changeMonth: true, changeYear: true, dateFormat: "dd/mm/yy" });
            $(".period-pill").click(function () {
                var period = $(this).data("period");
                $(".period-pill").removeClass("active");
                $(this).addClass("active");
                if (period === "custom") {
                    $(".custom-date-range").addClass("visible");
                } else {
                    $(".custom-date-range").removeClass("visible");
                    setPeriod(period, null, null, true);
                }
            });
            $("#btnApplyCustom").click(function () {
                var s = $("#txtStartDate").val();
                var e = $("#txtEndDate").val();
                if (s && e) setPeriod("custom", s, e, true);
            });
            loadDeptThenInit();
        });
        function loadDeptThenInit() {
            $.ajax({
                type: "POST",
                url: "OPD_Utilization_Dashboard.aspx/LoadDepartment",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var opts = '<option value="0">All</option>';
                    $.each(JSON.parse(response.d), function (k, v) {
                        opts += '<option value="' + v.DataValue_Name + '">' + v.DataValue_Description + '</option>';
                    });
                    $('#ddlDepartemt').html(opts).select2({ dropdownAutoWidth: true, width: '150px' });
                    $('#ddlDepartemt').on('change', function () {
                        if (_dt && _dts) refreshAll();
                    });
                    setPeriod("today", null, null, false);
                }
            });
        }
        function setPeriod(period, startDate, endDate, triggerLoad) {
            $(".period-pill").removeClass("active");
            $(".period-pill[data-period='" + period + "']").addClass("active");
            var today = new Date();
            var fmt = function (d) {
                return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0');
            };
            if (period === "today") {
                _dt = fmt(today); _dts = fmt(today);
                $(".custom-date-range").removeClass("visible");
            } else if (period === "yesterday") {
                var yest = new Date(today); yest.setDate(yest.getDate() - 1);
                _dt = fmt(yest); _dts = fmt(yest);
                $(".custom-date-range").removeClass("visible");
            } else if (period === "custom") {
                if (startDate && endDate) {
                    var p = startDate.split('/');
                    _dt = p[2] + '-' + p[1] + '-' + p[0];
                    p = endDate.split('/');
                    _dts = p[2] + '-' + p[1] + '-' + p[0];
                }
                $(".custom-date-range").addClass("visible");
            }
            if (_dt && _dts && triggerLoad) refreshAll();
        }
        function fmtDate(d) {
            return d.getFullYear() + '-' + String(d.getMonth()+1).padStart(2,'0') + '-' + String(d.getDate()).padStart(2,'0');
        }
        function getPrevDateRange() {
            var s = _dt.split('-');
            var e = _dts.split('-');
            var currFrom = new Date(+s[0], +s[1]-1, +s[2]);
            var currTo = new Date(+e[0], +e[1]-1, +e[2]);
            var days = Math.round((currTo - currFrom) / 86400000) + 1;
            var prevFrom = new Date(currFrom);
            prevFrom.setDate(prevFrom.getDate() - days);
            var prevTo = new Date(currFrom);
            prevTo.setDate(prevTo.getDate() - 1);
            return { from: fmtDate(prevFrom), to: fmtDate(prevTo) };
        }
        function getDep() {
            return $('#ddlDepartemt').val() || '0';
        }
        function refreshAll() {
            LoadKPI();
            LoadBarChart();
            LoadPieChart();
            LoadTrendData();
        }
        function LoadKPI() {
            var prev = getPrevDateRange();
            $.when(
                $.ajax({ type: "POST", url: "OPD_Utilization_Dashboard.aspx/GetTotalDepartmentRevenu", data: JSON.stringify({ txt_sdate: _dt, txt_edate: _dts }), contentType: "application/json" }),
                $.ajax({ type: "POST", url: "OPD_Utilization_Dashboard.aspx/GetTotalDepartmentRevenu", data: JSON.stringify({ txt_sdate: prev.from, txt_edate: prev.to }), contentType: "application/json" })
            ).done(function (curr, prev) {
                var cur = JSON.parse(curr[0].d) || {};
                var prv = JSON.parse(prev[0].d) || {};
                var ptCnt = +cur.Total_patients_Count || 0;
                var rev = +cur.Total_Revenu || 0;
                var pCnt = +prv.Total_patients_Count || 0;
                var pRev = +prv.Total_Revenu || 0;
                $('#txttotalPatients').text(ptCnt);
                $('#txtTotal_Revenu').text(rev.toLocaleString(undefined, { minimumFractionDigits: 0, maximumFractionDigits: 0 }));
                var ptPct = pCnt > 0 ? ((ptCnt - pCnt) / pCnt * 100).toFixed(1) : 0;
                var rvPct = pRev > 0 ? ((rev - pRev) / pRev * 100).toFixed(1) : 0;
                var ptUp = ptCnt >= pCnt;
                var rvUp = rev >= pRev;
                var ptHtml = pCnt > 0 ? '<span class="kpi-trend ' + (ptUp ? 'up' : 'down') + '">' + (ptUp ? '\u25B2' : '\u25BC') + ' ' + Math.abs(ptPct) + '% vs previous</span>' : '';
                var rvHtml = pRev > 0 ? '<span class="kpi-trend ' + (rvUp ? 'up' : 'down') + '">' + (rvUp ? '\u25B2' : '\u25BC') + ' ' + Math.abs(rvPct) + '% vs previous</span>' : '';
                $('#ptTrend').html(ptHtml);
                $('#rvTrend').html(rvHtml);
            });
        }
        var _chartBar = null, _chartPie = null, _sparkCharts = {};
        function renderBar(el, cats, patients, revenues) {
            if (_chartBar) { _chartBar.dispose(); _chartBar = null; }
            if (typeof echarts === 'undefined') { el.innerHTML = '<div class="no-data-msg">Chart library not loaded</div>'; return; }
            _chartBar = echarts.init(el);
            _chartBar.setOption({
                tooltip: { trigger: 'axis' },
                legend: { data: ['Patients', 'Revenue'] },
                grid: { containLabel: true },
                xAxis: { type: 'category', data: cats, axisLabel: { rotate: 20, fontSize: 11 } },
                yAxis: [
                    { type: 'value', name: 'Patients', min: 0, splitNumber: 6 },
                    { type: 'value', name: 'Revenue (Rs)', min: 0, splitNumber: 6 }
                ],
                series: [
                    { name: 'Patients', type: 'bar', data: patients, yAxisIndex: 0, color: '#308665' },
                    { name: 'Revenue', type: 'bar', data: revenues, yAxisIndex: 1, color: '#8e0016' }
                ]
            });
        }
        function renderPie(el, chartData) {
            if (_chartPie) { _chartPie.dispose(); _chartPie = null; }
            if (typeof echarts === 'undefined') { el.innerHTML = '<div class="no-data-msg">Chart library not loaded</div>'; return; }
            _chartPie = echarts.init(el);
            _chartPie.setOption({
                tooltip: { trigger: 'item' },
                series: [{
                    type: 'pie',
                    radius: ['38%', '65%'],
                    avoidLabelOverlap: true,
                    label: { show: true, formatter: '{b}: {d}%', fontSize: 11 },
                    emphasis: { label: { show: true, fontSize: 13 } },
                    data: chartData
                }]
            });
        }
        function renderSparkline(id, values, labels) {
            var el = document.getElementById(id);
            if (!el) return;
            if (_sparkCharts[id]) { _sparkCharts[id].dispose(); delete _sparkCharts[id]; }
            if (typeof echarts === 'undefined') return;
            var chart = echarts.init(el);
            _sparkCharts[id] = chart;
            var up = values.length > 0;
            var pts = values.map(function (v, i) {
                if (i === values.length - 1) return { value: v, itemStyle: { color: up ? '#3b82f6' : '#ef4444' } };
                return { value: v, itemStyle: { color: '#3b82f6' } };
            });
            chart.setOption({
                grid: { left: 3, right: 3, top: 5, bottom: 3 },
                xAxis: { show: false, type: 'category', data: labels },
                yAxis: { show: false, min: function (v) { return Math.max(0, v.min - (v.max - v.min) * 0.15); } },
                tooltip: {
                    trigger: 'item', confine: false, z: 99999,
                    extraCssText: 'z-index:999999;background:#fff;border:1px solid #d1d5db;border-radius:6px;box-shadow:0 4px 12px rgba(0,0,0,0.15);pointer-events:none;',
                    formatter: function (p) {
                        var i = p.dataIndex;
                        var fmt = function (n) { return Math.round(n).toLocaleString(); };
                        var maxVal = Math.max.apply(null, values);
                        var maxIdx = values.indexOf(maxVal);
                        var maxLabel = labels[maxIdx];
                        return '<div style="font-size:12px;line-height:1.6;padding:8px 12px;background:#fff;">' +
                            '<b>' + labels[i] + '</b>: ' + fmt(values[i]) + '<br/>' +
                            '<span style="color:#6b7280;">Peak</span>: <b>' + maxLabel + '</b> ' + fmt(maxVal) + '</div>';
                    }
                },
                series: [{
                    type: 'line', data: pts, smooth: false, showSymbol: true, symbolSize: 5,
                    lineStyle: { width: 2.5, color: '#3b82f6' },
                    animation: false
                }]
            });
        }
        function LoadTrendData() {
            $.ajax({
                type: "POST",
                url: "OPD_Utilization_Dashboard.aspx/GetMonthlyTrends",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var d = typeof res.d === 'string' ? JSON.parse(res.d) : res.d;
                    if (!d || !d.labels) return;
                    renderSparkline("sparkPatients", d.patients, d.labels);
                    renderSparkline("sparkRevenue", d.revenue, d.labels);
                }
            });
        }
        function LoadBarChart() {
            var Dep = getDep();
            $.ajax({
                type: "POST",
                url: "OPD_Utilization_Dashboard.aspx/GetDepartmentWiseRevenu",
                data: JSON.stringify({ txt_sdate: _dt, txt_edate: _dts, Dep: Dep }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var raw = typeof response.d === 'string' ? JSON.parse(response.d) : response.d;
                    if (!raw || !raw.length) {
                        if (_chartBar) { _chartBar.dispose(); _chartBar = null; }
                        document.getElementById('chartBar').innerHTML = '<div class="no-data-msg">No data available</div>';
                        return;
                    }
                    var filtered = raw.filter(function (i) { return i.Patient_Main_Category; });
                    if (!filtered.length) {
                        if (_chartBar) { _chartBar.dispose(); _chartBar = null; }
                        document.getElementById('chartBar').innerHTML = '<div class="no-data-msg">No data available</div>';
                        return;
                    }
                    renderBar(
                        document.getElementById('chartBar'),
                        filtered.map(function (i) { return i.Patient_Main_Category; }),
                        filtered.map(function (i) { return i.Total_patients_Count; }),
                        filtered.map(function (i) { return +i.Total_Revenu || 0; })
                    );
                },
                error: function () {
                    if (_chartBar) { _chartBar.dispose(); _chartBar = null; }
                    document.getElementById('chartBar').innerHTML = '<div class="no-data-msg">Error loading data</div>';
                }
            });
        }
        function LoadPieChart() {
            var Dep = getDep();
            $.ajax({
                type: "POST",
                url: "OPD_Utilization_Dashboard.aspx/GetDepartmentWiseRevenu",
                data: JSON.stringify({ txt_sdate: _dt, txt_edate: _dts, Dep: Dep }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var raw = typeof response.d === 'string' ? JSON.parse(response.d) : response.d;
                    if (!raw || !raw.length) {
                        if (_chartPie) { _chartPie.dispose(); _chartPie = null; }
                        document.getElementById('chartPie').innerHTML = '<div class="no-data-msg">No data available</div>';
                        return;
                    }
                    var chartData = raw.filter(function (i) { return i.Patient_Main_Category; }).map(function (i) { return { value: i.Total_patients_Count, name: i.Patient_Main_Category }; });
                    if (!chartData.length) {
                        if (_chartPie) { _chartPie.dispose(); _chartPie = null; }
                        document.getElementById('chartPie').innerHTML = '<div class="no-data-msg">No data available</div>';
                        return;
                    }
                    renderPie(document.getElementById('chartPie'), chartData);
                },
                error: function () {
                    if (_chartPie) { _chartPie.dispose(); _chartPie = null; }
                    document.getElementById('chartPie').innerHTML = '<div class="no-data-msg">Error loading data</div>';
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row-dash">
        <div class="row" style="margin:0 0 12px 0;">
            <div class="col-lg-12" style="padding:0 8px;">
                <div class="period-bar">
                    <label>Period</label>
                    <div class="period-pills">
                        <button type="button" class="period-pill active" data-period="today">Today</button>
                        <button type="button" class="period-pill" data-period="yesterday">Yesterday</button>
                        <button type="button" class="period-pill" data-period="custom">Custom</button>
                    </div>
                    <div class="custom-date-range">
                        <input type="text" id="txtStartDate" class="form-control datepicker" placeholder="Start Date" style="width:130px;" readonly />
                        <span style="color:#6b7280;">to</span>
                        <input type="text" id="txtEndDate" class="form-control datepicker" placeholder="End Date" style="width:130px;" readonly />
                        <button type="button" id="btnApplyCustom" class="btn btn-sm btn-primry">Apply</button>
                    </div>
                </div>
            </div>
        </div>
        <div class="row kpi-row" style="margin:0 0 12px 0;">
            <div class="col-md-6" style="padding:0 8px;">
                <div class="card-dash">
                    <div class="card-body">
                        <div class="kpi-label">Total Patients</div>
                        <div class="kpi-value" id="txttotalPatients">0</div>
                        <div id="ptTrend"></div>
                        <div class="rev-chart" id="sparkPatients"></div>
                    </div>
                </div>
            </div>
            <div class="col-md-6" style="padding:0 8px;">
                <div class="card-dash">
                    <div class="card-body">
                        <div class="kpi-label">Total Revenue</div>
                        <div class="kpi-value" id="txtTotal_Revenu">0</div>
                        <div id="rvTrend"></div>
                        <div class="rev-chart" id="sparkRevenue"></div>
                    </div>
                </div>
            </div>
        </div>
        <div class="row" style="margin:0 0 8px 0;">
            <div class="col-lg-2" style="padding:0 8px;">
                <div class="dept-filter-box">
                    <label>Dept</label>
                    <select id="ddlDepartemt" class="form-control"></select>
                </div>
            </div>
        </div>
        <div class="row" style="margin:0 0 12px 0;">
            <div class="col-md-6" style="padding:0 8px;">
                <div class="card-dash">
                    <div class="card-body">
                        <h3 class="chart-title">Patients & Revenue by Category</h3>
                        <div id="chartBar" class="bento-chart"></div>
                    </div>
                </div>
            </div>
            <div class="col-md-6" style="padding:0 8px;">
                <div class="card-dash">
                    <div class="card-body">
                        <h3 class="chart-title">Patient Distribution</h3>
                        <div id="chartPie" class="bento-chart"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
