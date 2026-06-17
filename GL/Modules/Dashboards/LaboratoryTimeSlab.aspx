<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LaboratoryTimeSlab.aspx.cs" Inherits="PMS.Modules.Dashboards.LaboratoryTimeSlab" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <style>
        .row-dash { margin: 0; }
        .row-dash > [class^="col-"] { padding: 0 8px; }
        .dash-title { font-size: 22px; font-weight: 700; color: #1a1a2e; margin: 0; }
        .card-dash { border-radius: 12px; border: 1px solid #e4e7ec; background: #fff; margin-bottom: 16px; position:relative; }
        .rev-chart { position:absolute; bottom:4px; right:4px; width:100px; height:35px; z-index:1; }
        .card-dash .card-body { padding: 18px 20px; }
        .kpi-label { font-size: 12px; font-weight: 600; color: #667085; text-transform: uppercase; letter-spacing: .5px; margin-bottom: 4px; }
        .kpi-value { font-size: 28px; font-weight: 700; color: #1a1a2e; line-height: 1.2; }
        .kpi-sub { font-size: 12px; color: #667085; margin-top: 2px; }
        .kpi-trend { font-size: 12px; margin-top: 4px; }
        .kpi-trend.up { color: #12b76a; }
        .kpi-trend.down { color: #f04438; }
        .kpi-warn .kpi-value { color: #dc6803; }
        .wf-section { padding: 16px 20px; }
        .wf-section h3 { font-size: 15px; font-weight: 700; color: #000; margin: 0 0 16px 0; }
        .wf-bar { display: flex; height: 44px; border-radius: 8px; }
        .wf-seg { display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 600; color: #fff; position: relative; min-width: 56px; cursor: default; transition: transform .2s, box-shadow .2s, z-index 0s; border-radius: 6px; margin: 0 2px; }
        .wf-seg:hover { transform: scale(1.08); z-index: 10; box-shadow: 0 4px 16px rgba(0,0,0,.25); }
        .wf-seg .wf-time { font-size: 11px; opacity: .9; margin-left: 3px; }
        .wf-bill { background: #98a2b3; }
        .wf-samp { background: #667085; }
        .wf-lab { background: #475467; }
        .wf-rept { background: #344054; }
        .wf-appr { background: #dc6803; }
        .wf-appr.bn { background: #dc6803; box-shadow: inset 0 0 0 2px rgba(255,255,255,.3); }
        .table-container { overflow-x: auto; max-height: 600px; }
        .kpi-row > [class^="col-"] { display: flex; }
        .kpi-row .card-dash { width: 100%; height: 100%; display: flex; flex-direction: column; }
        .kpi-row .card-dash .card-body { flex: 1; }
        .table-nb { border-collapse: collapse !important; border: none !important; }
        .table-nb thead th, .table-nb tbody td { border: none !important; }
        .period-pills { display: flex; gap: 6px; }
        .period-pill { border:1px solid #d1d5db; border-radius:20px; padding:4px 16px; font-size:12px; font-weight:600; background:#fff; color:#374151; cursor:pointer; transition:all .2s; }
        .period-pill:hover { border-color:#8e0016; color:#8e0016; }
        .period-pill.active { background:#8e0016; border-color:#8e0016; color:#fff; }
        .custom-date-range { display:none; gap:8px; align-items:center; }
        .custom-date-range.visible { display:flex !important; }
    </style>
    <script type="text/javascript">
        var _dt = '', _dts = '', _sparkCharts = {};
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
                    setPeriod(period);
                }
            });
            $("#btnApplyCustom").click(function () {
                var s = $("#txtStartDate").val();
                var e = $("#txtEndDate").val();
                if (s && e) setPeriod("custom", s, e);
            });
            setPeriod("today");
        });
        function setPeriod(period, startDate, endDate) {
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
            if (_dt && _dts) refreshAll();
        }
        function refreshAll() {
            LoadDashboard();
            if ($.fn.DataTable.isDataTable('#tbl')) {
                $('#tbl').DataTable().ajax.reload();
            } else {
                LoadTable();
            }
        }
        function LoadDashboard() {
            $.ajax({
                type: "POST",
                url: "LaboratoryTimeSlab.aspx/GetDashboardData",
                data: JSON.stringify({ txt_sdate: _dt, txt_edate: _dts }),
                contentType: "application/json; charset=utf-8",
                success: function (r) {
                    var d = JSON.parse(r.d);
                    $('#totalTests').text(d.totalTests);
                    var th = d.testTrend === 'up'
                        ? '<span class="kpi-trend up">\u25B2 ' + d.testTrendPercent + '%</span>'
                        : '<span class="kpi-trend down">\u25BC ' + d.testTrendPercent + '%</span>';
                    $('#testTrend').html(th);
                    $('#avgTat').text(d.avgTat);
                    var tatArrow = d.tatTrend === 'up' ? '\u25B2' : '\u25BC';
                    var tatCls = d.tatTrend === 'up' ? 'up' : 'down';
                    $('#tatTrend').html('<span class="kpi-trend ' + tatCls + '">' + tatArrow + ' ' + d.tatTrendPercent + '% vs previous</span>');
                    if (d.bottleneckMinutes === 0) {
                        $('#bottleneck').text('No Bottleneck').css('color', '#12b76a');
                        $('#bottleneckTime').text('');
                        $('#bottleneck').closest('.card-body').css('border-left-color', '#12b76a');
                        $('#bottleneck').siblings('.kpi-label').css('color', '#12b76a').text('Critical Bottleneck');
                    } else {
                        $('#bottleneck').text(d.bottleneckName).css('color', '#dc6803');
                        $('#bottleneckTime').text(d.bottleneckTime + ' avg');
                        $('#bottleneck').closest('.card-body').css('border-left-color', '#dc6803');
                        $('#bottleneck').siblings('.kpi-label').css('color', '#dc6803').text('Critical Bottleneck');
                    }
                    renderWF(d.workflowStages);
                    LoadTrendData();
                },
                error: function (xhr) { console.log(xhr.responseText); }
            });
        }
        function renderWF(stages) {
            var total = stages.reduce(function (s, st) { return s + Math.max(st.minutes, 1); }, 0) || 1;
            var cls = ['wf-bill', 'wf-samp', 'wf-lab', 'wf-rept', 'wf-appr'];
            var html = '';
            $.each(stages, function (i, s) {
                var pct = Math.max(8, (s.minutes / total) * 100);
                var c = cls[i] || '';
                if (s.isBottleneck) c += ' bn';
                var segHtml = '<div class="wf-seg ' + c + '" style="flex:' + pct + '">';
                segHtml += s.name;
                if (s.avgTime) segHtml += ' <span class="wf-time">' + s.avgTime + '</span>';
                segHtml += '</div>';
                html += segHtml;
            });
            $('#wfBar').html(html);
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
                grid: { left: 0, right: 0, top: 0, bottom: 0 },
                xAxis: { show: false, type: 'category', data: labels },
                yAxis: { show: false, min: function (v) { return Math.max(0, v.min - (v.max - v.min) * 0.15); } },
                tooltip: {
                    trigger: 'item', confine: false, z: 9999,
                    extraCssText: 'z-index:99999;background:#fff;border:1px solid #d1d5db;border-radius:6px;box-shadow:0 4px 12px rgba(0,0,0,0.15);pointer-events:none;',
                    formatter: function (p) {
                        var i = p.dataIndex;
                        var fmt = function (n) { return Math.round(n).toLocaleString(); };
                        return '<div style="font-size:12px;line-height:1.6;padding:8px 12px;background:#fff;">' +
                            '<b>' + labels[i] + '</b>: ' + fmt(values[i]) + '</div>';
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
                url: "LaboratoryTimeSlab.aspx/GetMonthlyTrends",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var d = typeof res.d === 'string' ? JSON.parse(res.d) : res.d;
                    if (!d || !d.labels) return;
                    renderSparkline("sparkLabTests", d.tests, d.labels);
                    renderSparkline("sparkLabTat", d.avgTat, d.labels);
                }
            });
        }
        function LoadTable() {
            if ($.fn.DataTable.isDataTable('#tbl')) {
                $('#tbl').DataTable().destroy();
            }
            $('#tbl').DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "LaboratoryTimeSlab.aspx/ViewList",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length,
                            sortColumn: data.columns[data.order[0].column].name,
                            sortColumnDirection: data.order[0].dir,
                            searchValue: data.search.value,
                            txt_sdate: _dt,
                            txt_edate: _dts
                        }),
                        contentType: "application/json; charset=utf-8",
                        success: function (response) {
                            callback({
                                draw: response.d.draw,
                                recordsTotal: response.d.recordsTotal,
                                recordsFiltered: response.d.recordsFiltered,
                                data: response.d.data
                            });
                        },
                        error: function (xhr) { console.log(xhr.responseText); }
                    });
                },
                "columns": [
                    { "data": "srNo", "name": "srNo", "width": "5%", "orderable": true },
                    { "data": "mrNo", "name": "mrNo", "width": "8%", "orderable": true },
                    { "data": "patientName", "name": "patientName", "width": "16%", "orderable": true },
                    { "data": "billDate", "name": "billDate", "width": "10%", "orderable": true },
                    { "data": "sampleDate", "name": "sampleDate", "width": "10%", "orderable": true },
                    { "data": "labDate", "name": "labDate", "width": "10%", "orderable": true },
                    { "data": "reportDate", "name": "reportDate", "width": "10%", "orderable": true },
                    { "data": "approveDate", "name": "approveDate", "width": "10%", "orderable": true },
                    { "data": "totalTime", "name": "totalTimeMinutes", "width": "11%", "orderable": true,
                        "render": function (data, type, full) {
                            if (type === 'display') {
                                var mins = full.totalTimeMinutes || 0;
                                var c = mins > 120 ? 'badge-red' : (mins > 90 ? 'badge-orange' : 'badge-green');
                                return '<span class="time-badge ' + c + '">' + data + '</span>';
                            }
                            return data;
                        }
                    }
                ],
                "order": [[0, "asc"]],
                "initComplete": function () {
                    var dd = document.querySelector('#tbl_length select');
                    var lbl = document.querySelector('#tbl_length label');
                    if (dd && lbl) {
                        var s = document.createElement('span');
                        s.textContent = 'Show entries ';
                        s.style.marginTop = '10px';
                        s.style.display = 'inline-block';
                        dd.style.width = '60px';
                        lbl.innerHTML = '';
                        lbl.style.display = 'inline-flex';
                        lbl.style.marginTop = '17px';
                        lbl.appendChild(s);
                        lbl.appendChild(dd);
                    }
                }
            });
        }
    </script>
    <style>
        .time-badge { display: inline-block; padding: 3px 12px; border-radius: 20px; font-size: 12px; font-weight: 600; }
        .time-badge.badge-green { background: #ecfdf3; color: #067647; }
        .time-badge.badge-orange { background: #fffaeb; color: #b54708; }
        .time-badge.badge-red { background: #fef3f2; color: #b42318; }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row-dash">
        <div class="row" style="margin:0 0 16px 0;">
            <div class="col-lg-12" style="padding:0 8px;">
                <div class="card-dash">
                    <div class="card-body" style="display:flex;align-items:center;flex-wrap:wrap;gap:12px;">
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
        </div>
        <div class="row kpi-row" style="margin:0 0 16px 0;">
            <div class="col-md-4" style="padding:0 8px;">
                <div class="card-dash">
                    <div class="card-body">
                        <div class="kpi-label">Total Tests</div>
                        <div class="kpi-value" id="totalTests">0</div>
                        <div id="testTrend"></div>
                        <div class="rev-chart" id="sparkLabTests"></div>
                    </div>
                </div>
            </div>
            <div class="col-md-4" style="padding:0 8px;">
                <div class="card-dash">
                    <div class="card-body">
                        <div class="kpi-label">Avg. Turnaround Time</div>
                        <div class="kpi-value" id="avgTat">0</div>
                        <div id="tatTrend"></div>
                        <div class="rev-chart" id="sparkLabTat"></div>
                    </div>
                </div>
            </div>
            <div class="col-md-4" style="padding:0 8px;">
                <div class="card-dash">
                    <div class="card-body" style="border-left:4px solid #dc6803;">
                        <div class="kpi-label" style="color:#dc6803;">Critical Bottleneck</div>
                        <div class="kpi-value" style="color:#dc6803;" id="bottleneck">--</div>
                        <div class="kpi-sub" id="bottleneckTime"></div>
                    </div>
                </div>
            </div>
        </div>
        <div class="row" style="margin:0 0 16px 0;">
            <div class="col-lg-12" style="padding:0 8px;">
                <div class="card-dash">
                    <div class="wf-section">
                        <h3>Average Time by Stage</h3>
                        <div class="wf-bar" id="wfBar">
                            <div class="wf-seg wf-bill" style="flex:1">Loading...</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="row" style="margin:0;">
            <div class="col-lg-12" style="padding:0 8px;">
                <div class="card-dash">
                    <div class="table-container">
                        <table id="tbl" class="table table-hover table-striped table-nb" style="width:100%">
                            <thead>
                                <tr>
                                    <th>SR No</th>
                                    <th>MR No</th>
                                    <th>Patient Name</th>
                                    <th>Bill Date</th>
                                    <th>Sample Date</th>
                                    <th>Lab Date</th>
                                    <th>Report Date</th>
                                    <th>Approve Date</th>
                                    <th>Total Time</th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
