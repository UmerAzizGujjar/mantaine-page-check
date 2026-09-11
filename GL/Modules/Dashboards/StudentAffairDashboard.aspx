<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="StudentAffairDashboard.aspx.cs" Inherits="PMS.Modules.Dashboards.StudentAffairDashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <script src="https://cdn.jsdelivr.net/npm/echarts@5/dist/echarts.min.js"></script>
    <style type="text/css">
        .bento-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 12px;
            grid-template-areas:
                "period period period period"
                "s1 s2 s3 s4"
                "trend trend status classdist"
                "att att out out"
                "recent recent recent recent";
        }
        .bento-item {
            background: #fff;
            border-radius: 10px;
            padding: 14px;
            border: 1px solid #f0f0f0;
            transition: box-shadow 0.25s ease, transform 0.25s ease, border-color 0.25s ease;
        }
        .bento-item:hover {
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.08);
            border-color: #e5e7eb;
            transform: translateY(-1px);
        }
        .bento-item.period-bar { grid-area: period; display: flex; align-items: center; gap: 12px; flex-wrap: wrap; padding: 10px 14px; min-height: auto; }
        .bento-item.period-bar label { margin: 0; font-weight: 600; font-size: 13px; color: #374151; }
        #stat-s1 { grid-area: s1; } #stat-s2 { grid-area: s2; } #stat-s3 { grid-area: s3; } #stat-s4 { grid-area: s4; }
        #trend-area { grid-area: trend; align-self: start; }
        #status-area { grid-area: status; align-self: start; }
        #classdist-area { grid-area: classdist; align-self: start; }
        #att-area { grid-area: att; align-self: start; }
        #out-area { grid-area: out; align-self: start; }
        #recent-area { grid-area: recent; align-self: start; }

        .main-heading { font-size: 13px; font-weight: 700; color: #1f2937; margin-bottom: 4px; }
        .sub-heading { font-size: 10px; color: #9ca3af; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 10px; }
        .chart-box { width: 100%; }
        #chartTrend { height: 220px; }
        #chartFeeStatus { height: 190px; }
        #chartClass { height: 190px; }
        #chartAtt { height: 110px; }

        .stat-card .sc-label { font-size: 10px; color: #6b7280; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 4px; }
        .stat-card .sc-value { font-size: 22px; font-weight: 800; color: #111827; line-height: 1.15; }
        .stat-card .sc-sub { font-size: 10px; color: #9ca3af; margin-top: 3px; }
        .sc-value.money { font-size: 19px; }
        .stat-card .sc-ic { font-size: 10px; font-weight: 700; }

        .fee-status-meta { display: flex; gap: 10px; flex-wrap: wrap; margin-top: 6px; }
        .fs-chip { flex: 1; min-width: 90px; background: #f9fafb; border-radius: 6px; padding: 6px 8px; }
        .fs-chip .fs-n { font-size: 12px; font-weight: 800; }
        .fs-chip .fs-l { font-size: 9px; color: #6b7280; text-transform: uppercase; letter-spacing: 0.4px; }

        .att-wrap { display: flex; gap: 12px; align-items: stretch; }
        .att-donut { width: 120px; flex: none; }
        .att-list { flex: 1; }
        .att-rate { font-size: 20px; font-weight: 800; color: #10b981; }
        .att-class-row { display: flex; align-items: center; gap: 8px; font-size: 10px; margin-bottom: 5px; }
        .att-class-row .ac-label { width: 96px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; color: #4b5563; }
        .att-class-row .ac-bar-bg { flex: 1; background: #f3f4f6; border-radius: 4px; height: 8px; overflow: hidden; }
        .att-class-row .ac-bar-fill { height: 100%; background: #10b981; border-radius: 4px; }
        .att-class-row .ac-txt { width: 74px; text-align: right; color: #6b7280; }

        .out-total { display: flex; align-items: baseline; gap: 8px; }
        .out-total .ot-value { font-size: 22px; font-weight: 800; color: #c11718; }
        .out-list { margin-top: 10px; }
        .out-row { display: flex; align-items: center; gap: 8px; font-size: 10px; margin-bottom: 5px; }
        .out-row .o-label { width: 100px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; color: #4b5563; }
        .out-row .o-bar-bg { flex: 1; background: #f3f4f6; border-radius: 4px; height: 8px; overflow: hidden; }
        .out-row .o-bar-fill { height: 100%; background: #8e0016; border-radius: 4px; }
        .out-row .o-txt { width: 70px; text-align: right; color: #6b7280; }

        .period-pills { display: flex; gap: 6px; flex-wrap: wrap; }
        .period-pill { border: 1px solid #d1d5db; border-radius: 20px; padding: 4px 14px; font-size: 12px; font-weight: 600; background: #fff; color: #374151; cursor: pointer; transition: all 0.2s; }
        .period-pill:hover { border-color: #8e0016; color: #8e0016; }
        .period-pill.active { background: #8e0016; border-color: #8e0016; color: #fff; }
        .custom-date-range { display: none; gap: 8px; align-items: center; }
        .custom-date-range.visible { display: flex !important; }
        .ui-datepicker { z-index: 9999 !important; }

        #recent-table { width: 100%; border-collapse: collapse; font-size: 11px; }
        #recent-table th { text-align: left; background: #f9fafb; color: #6b7280; text-transform: uppercase; font-size: 9px; letter-spacing: 0.5px; padding: 6px 8px; }
        #recent-table td { padding: 5px 8px; border-top: 1px solid #f3f4f6; color: #374151; }
        #recent-table tr:hover td { background: #fafafa; }

        .card-loading { opacity: 0.35; pointer-events: none; transition: opacity 0.2s; position: relative; }
        .card-loading::after {
            content: '';
            position: absolute; inset: 50% auto auto 50%;
            width: 28px; height: 28px; margin: -14px 0 0 -14px;
            border: 3px solid #e5e7eb; border-top-color: #3b82f6;
            border-radius: 50%; animation: spin 0.7s linear infinite;
            z-index: 10;
        }
        @keyframes spin { to { transform: rotate(360deg); } }

        .no-data { text-align: center; color: #cbd5e1; font-size: 12px; padding: 30px 0; }
    </style>

    <script type="text/javascript">
        var saCharts = {};

        function saDispose(id) {
            if (saCharts[id]) { saCharts[id].dispose(); saCharts[id] = null; }
        }
        function saInit(id) {
            saDispose(id);
            var dom = document.getElementById(id);
            if (!dom) return null;
            saCharts[id] = echarts.init(dom);
            return saCharts[id];
        }
        function saFmt(v) {
            try { return Number(v || 0).toLocaleString('en-PK', { maximumFractionDigits: 0 }); }
            catch (e) { return Number(v || 0).toLocaleString('en-US', { maximumFractionDigits: 0 }); }
        }
        function saMoney(v) { return 'Rs. ' + saFmt(v); }

        function saAjax(url, data, fn) {
            $.ajax({
                type: "POST",
                url: "StudentAffairDashboard.aspx/" + url,
                data: JSON.stringify(data),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var r = JSON.parse(res.d);
                    if (r && r.Error) { console.error("[" + url + "] " + r.Error); return; }
                    if (fn) fn(r);
                },
                error: function (xhr, status, err) {
                    console.error("[" + url + "] AJAX Error: " + err + " | " + (xhr.responseText || '').substring(0, 200));
                }
            });
        }
        function saPillState() {
            var pill = $(".period-pill.active");
            var p = pill.data("period");
            var s = null, e = null;
            if (p === "custom") { s = $("#saStartDate").val(); e = $("#saEndDate").val(); }
            return { period: p, startDate: s, endDate: e };
        }

        function saLoadStats(p, s, e) {
            saAjax("GetStats", { period: p, startDate: s, endDate: e }, function (r) {
                $("#valActive").text(saFmt(r.ActiveStudents));
                $("#valAdm").text(saFmt(r.NewAdmissions));
                $("#valFees").text(saMoney(r.FeesGenerated));
                $("#valColl").text(saMoney(r.Collections));
                $("#outTotal").text(saMoney(r.Outstanding));
                var list = r.ClassOutstanding || [];
                var maxV = list.length ? list[0].Value : 0;
                var html = list.length ? "" : '<div class="no-data">No outstanding receivables</div>';
                list.forEach(function (o) {
                    html += '<div class="out-row"><span class="o-label" title="' + o.Label + '">' + o.Label + '</span>' +
                        '<div class="o-bar-bg"><div class="o-bar-fill" style="width:' + (maxV ? Math.round(o.Value / maxV * 100) : 0) + '%"></div></div>' +
                        '<span class="o-txt">' + saMoney(o.Value) + '</span></div>';
                });
                $("#outList").html(html);
            });
        }

        function saLoadTrend(p, s, e) {
            saAjax("GetFeeTrend", { period: p, startDate: s, endDate: e }, function (r) {
                var ch = saInit("chartTrend");
                if (!ch) return;
                var months = r.Months || [];
                ch.setOption({
                    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' }, formatter: function (ps) {
                        var t = ps[0].axisValue + '<br/>';
                        ps.forEach(function (x) { t += x.marker + ' ' + x.seriesName + ': Rs. ' + saFmt(x.value) + '<br/>'; });
                        return t;
                    } },
                    legend: { data: ['Fees Generated', 'Collections'], top: 0, right: 0, icon: 'circle', itemWidth: 8, itemHeight: 8, textStyle: { fontSize: 10 } },
                    grid: { left: 8, right: 8, top: 30, bottom: 5, containLabel: true },
                    xAxis: { type: 'category', data: months, axisLine: { show: false }, axisTick: { show: false }, axisLabel: { fontSize: 9 } },
                    yAxis: { type: 'value', show: false, min: 0 },
                    series: [
                        { name: 'Fees Generated', type: 'bar', data: r.Fees || [], itemStyle: { color: '#8e0016', borderRadius: [3, 3, 0, 0] }, barWidth: '28%' },
                        { name: 'Collections', type: 'bar', data: r.Collections || [], itemStyle: { color: '#10b981', borderRadius: [3, 3, 0, 0] }, barWidth: '28%' }
                    ]
                });
            });
        }

        function saLoadFeeStatus(p, s, e) {
            saAjax("GetFeeStatus", { period: p, startDate: s, endDate: e }, function (r) {
                $("#fsAppr").text(saFmt(r.ApprovedCnt) + ' / ' + saMoney(r.ApprovedAmt));
                $("#fsUnappr").text(saFmt(r.UnapprovedCnt) + ' / ' + saMoney(r.UnapprovedAmt));
                $("#fsCanc").text(saFmt(r.CancelledCnt) + ' / ' + saMoney(r.CancelledAmt));
                var total = r.ApprovedCnt + r.UnapprovedCnt + r.CancelledCnt;
                var ch = saInit("chartFeeStatus");
                if (!ch) return;
                if (!total) {
                    ch.setOption({ title: { text: 'No fees\nin period', left: 'center', top: 'center', textStyle: { fontSize: 11, color: '#cbd5e1' } } });
                    return;
                }
                ch.setOption({
                    tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
                    series: [{
                        type: 'pie', radius: ['45%', '70%'], center: ['50%', '46%'],
                        avoidLabelOverlap: false, label: { show: false }, emphasis: { label: { show: false } },
                        data: [
                            { value: r.ApprovedCnt, name: 'Approved', itemStyle: { color: '#10b981' } },
                            { value: r.UnapprovedCnt, name: 'Unapproved', itemStyle: { color: '#EFA63E' } },
                            { value: r.CancelledCnt, name: 'Cancelled', itemStyle: { color: '#c11718' } }
                        ]
                    }],
                    graphic: [{
                        type: 'text', left: 'center', top: '38%',
                        style: { text: String(total), fill: '#111827', fontSize: 20, fontWeight: 800, textAlign: 'center' },
                        z: 100
                    }, {
                        type: 'text', left: 'center', top: '58%',
                        style: { text: 'FEE VOUCHERS', fill: '#9ca3af', fontSize: 8, fontWeight: 600, textAlign: 'center' },
                        z: 100
                    }]
                });
            });
        }

        function saLoadAttendance(p, s, e) {
            saAjax("GetAttendanceStats", { period: p, startDate: s, endDate: e }, function (r) {
                var total = r.Total || 0;
                $("#attRate").text(total ? r.AttendanceRate + '%' : '--');
                $("#attMeta").text(total ? (saFmt(r.Present) + ' present / ' + saFmt(total) + ' entries') : 'No attendance marked in period');
                var list = r.ByClass || [];
                var html = list.length ? "" : '<div class="no-data" style="padding:8px 0;">No data</div>';
                list.forEach(function (c) {
                    var pct = c.Total ? Math.round(c.Present / c.Total * 100) : 0;
                    html += '<div class="att-class-row"><span class="ac-label" title="' + c.Label + '">' + c.Label + '</span>' +
                        '<div class="ac-bar-bg"><div class="ac-bar-fill" style="width:' + pct + '%"></div></div>' +
                        '<span class="ac-txt">P:' + c.Present + ' A:' + c.Absent + ' L:' + c.Leave + '</span></div>';
                });
                $("#attList").html(html);

                var ch = saInit("chartAtt");
                if (!ch) return;
                if (!total) {
                    ch.setOption({ title: { text: 'No data', left: 'center', top: 'center', textStyle: { fontSize: 10, color: '#cbd5e1' } } });
                    return;
                }
                ch.setOption({
                    tooltip: { trigger: 'item', formatter: '{b}: {c}' },
                    series: [{
                        type: 'pie', radius: ['55%', '78%'], center: ['50%', '48%'],
                        avoidLabelOverlap: false, label: { show: false },
                        data: [
                            { value: r.Present, name: 'Present', itemStyle: { color: '#10b981' } },
                            { value: r.Absent, name: 'Absent', itemStyle: { color: '#ef4444' } },
                            { value: r.Leave, name: 'Leave', itemStyle: { color: '#f59e0b' } }
                        ]
                    }],
                    graphic: [{
                        type: 'text', left: 'center', top: '40%',
                        style: { text: String(r.Present), fill: '#10b981', fontSize: 16, fontWeight: 800, textAlign: 'center' },
                        z: 100
                    }]
                });
            });
        }

        function saLoadDistribution() {
            saAjax("GetStudentDistribution", {}, function (r) {
                var dist = r.Distribution || [];
                var ch = saInit("chartClass");
                if (!ch) return;
                if (!dist.length) {
                    ch.setOption({ title: { text: 'No students', left: 'center', top: 'center', textStyle: { fontSize: 11, color: '#cbd5e1' } } });
                    return;
                }
                var palette = ['#8e0016', '#EFA63E', '#438eb9', '#10b981', '#c11718', '#f59e0b', '#5c6bc0', '#ef4444', '#26a69a', '#FF9F43'];
                ch.setOption({
                    tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
                    legend: { bottom: 0, left: 'center', type: 'scroll', icon: 'circle', itemWidth: 8, itemHeight: 8, textStyle: { fontSize: 9 }, pageIconSize: 10 },
                    series: [{
                        type: 'pie', radius: ['35%', '62%'], center: ['50%', '42%'],
                        avoidLabelOverlap: false,
                        label: { show: false },
                        data: dist.map(function (d, i) { return { value: d.Count, name: d.Label, itemStyle: { color: palette[i % palette.length] } }; })
                    }],
                    graphic: [{
                        type: 'text', left: 'center', top: '34%',
                        style: { text: String(r.Total), fill: '#111827', fontSize: 18, fontWeight: 800, textAlign: 'center' },
                        z: 100
                    }]
                });
            });
        }

        function saLoadRecent() {
            saAjax("GetRecentReceipts", {}, function (list) {
                var $tb = $("#recentTable tbody");
                $tb.empty();
                if (!list || !list.length) {
                    $tb.append('<tr><td colspan="5" class="no-data">No approved receipts yet</td></tr>');
                    return;
                }
                list.forEach(function (r) {
                    $tb.append('<tr><td>' + (r.No || '') + '</td><td>' + (r.Date || '') + '</td><td>' + (r.Student || '') + '</td>' +
                        '<td>' + saMoney(r.Received) + '</td><td>' + saMoney(r.Balance) + '</td></tr>');
                });
            });
        }

        function saSetPeriod(p, s, e) {
            $(".period-pill").removeClass("active");
            $(".period-pill[data-period='" + p + "']").addClass("active");
            if (p === "custom") {
                $(".custom-date-range").addClass("visible");
                if (s) $("#saStartDate").val(s);
                if (e) $("#saEndDate").val(e);
            } else {
                $(".custom-date-range").removeClass("visible");
            }
            $(".bento-item:not(.period-bar)").addClass("card-loading");
            setTimeout(function () { $(".bento-item").removeClass("card-loading"); }, 120000);
            saLoadStats(p, s, e);
            saLoadTrend(p, s, e);
            saLoadFeeStatus(p, s, e);
            saLoadAttendance(p, s, e);
        }

        $(document).ajaxStop(function () { $(".bento-item").removeClass("card-loading"); });
        $(document).ajaxError(function (e, xhr, settings) {
            var m = settings.url ? settings.url.match(/\/(\w+)$/) : null;
            console.error("[" + (m ? m[1] : 'unknown') + "] " + (xhr.responseText || '').substring(0, 300));
        });

        $(document).ready(function () {
            $(".datepicker").datepicker({ changeMonth: true, changeYear: true, dateFormat: "dd/mm/yy", yearRange: "-5:+0" });

            $(".period-pill").click(function () {
                var p = $(this).data("period");
                if (p === "custom") {
                    $(".period-pill").removeClass("active");
                    $(this).addClass("active");
                    $(".custom-date-range").addClass("visible");
                    return;
                }
                saSetPeriod(p);
            });

            $("#btnSaApply").click(function () {
                var s = $("#saStartDate").val();
                var e = $("#saEndDate").val();
                if (s && e) saSetPeriod("custom", s, e);
            });

            $(window).on("resize", function () {
                for (var k in saCharts) { if (saCharts[k] && saCharts[k].resize) saCharts[k].resize(); }
            });

            saLoadDistribution();
            saLoadRecent();
            saSetPeriod("today");
        });
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="bento-grid">

        <div class="bento-item period-bar">
            <label>Period</label>
            <div class="period-pills">
                <button type="button" class="period-pill active" data-period="today">Today</button>
                <button type="button" class="period-pill" data-period="yesterday">Yesterday</button>
                <button type="button" class="period-pill" data-period="week">This Week</button>
                <button type="button" class="period-pill" data-period="month">This Month</button>
                <button type="button" class="period-pill" data-period="year">This Year</button>
                <button type="button" class="period-pill" data-period="custom">Custom</button>
            </div>
            <div class="custom-date-range">
                <input type="text" id="saStartDate" class="form-control datepicker" placeholder="Start Date" style="width: 130px;" readonly />
                <span style="color:#6b7280;">to</span>
                <input type="text" id="saEndDate" class="form-control datepicker" placeholder="End Date" style="width: 130px;" readonly />
                <button type="button" class="btn btn-sm btn-primry" id="btnSaApply">Apply</button>
            </div>
        </div>

        <div class="bento-item stat-card" id="stat-s1">
            <div class="sc-label">Active Students</div>
            <div class="sc-value" id="valActive">0</div>
            <div class="sc-sub">Currently enrolled</div>
        </div>

        <div class="bento-item stat-card" id="stat-s2">
            <div class="sc-label">New Admissions</div>
            <div class="sc-value" id="valAdm">0</div>
            <div class="sc-sub" id="subAdm">In selected period</div>
        </div>

        <div class="bento-item stat-card" id="stat-s3">
            <div class="sc-label">Fees Generated</div>
            <div class="sc-value money" id="valFees">Rs. 0</div>
            <div class="sc-sub" id="subFees">Selected period</div>
        </div>

        <div class="bento-item stat-card" id="stat-s4">
            <div class="sc-label">Collections</div>
            <div class="sc-value money" id="valColl">Rs. 0</div>
            <div class="sc-sub" id="subColl">Amount received</div>
        </div>

        <div class="bento-item" id="trend-area">
            <div class="main-heading">Monthly Fees vs Collections</div>
            <div class="sub-heading">Year to date</div>
            <div class="chart-box" id="chartTrend"></div>
        </div>

        <div class="bento-item" id="status-area">
            <div class="main-heading">Fee Voucher Status</div>
            <div class="sub-heading">Selected period</div>
            <div class="chart-box" id="chartFeeStatus"></div>
            <div class="fee-status-meta">
                <div class="fs-chip"><div class="fs-l">Approved</div><div class="fs-n" id="fsAppr" style="color:#10b981;">0</div></div>
                <div class="fs-chip"><div class="fs-l">Unapproved</div><div class="fs-n" id="fsUnappr" style="color:#EFA63E;">0</div></div>
                <div class="fs-chip"><div class="fs-l">Cancelled</div><div class="fs-n" id="fsCanc" style="color:#c11718;">0</div></div>
            </div>
        </div>

        <div class="bento-item" id="classdist-area">
            <div class="main-heading">Students by Class</div>
            <div class="sub-heading">Active enrolments</div>
            <div class="chart-box" id="chartClass"></div>
        </div>

        <div class="bento-item" id="att-area">
            <div class="main-heading">Attendance Snapshot</div>
            <div class="sub-heading" id="attMeta">Selected period</div>
            <div class="att-wrap">
                <div class="att-donut">
                    <div class="att-rate" id="attRate">--</div>
                    <div class="chart-box" id="chartAtt"></div>
                </div>
                <div class="att-list" id="attList"></div>
            </div>
        </div>

        <div class="bento-item" id="out-area">
            <div class="main-heading">Outstanding Receivables</div>
            <div class="sub-heading">Approved fees less collected</div>
            <div class="out-total"><span class="ot-value" id="outTotal">Rs. 0</span><span class="sc-sub">By class</span></div>
            <div class="out-list" id="outList"></div>
        </div>

        <div class="bento-item" id="recent-area">
            <div class="main-heading">Recent Approved Receipts</div>
            <div class="sub-heading">Latest 8</div>
            <table id="recent-table">
                <thead>
                    <tr><th>Receipt No</th><th>Date</th><th>Student</th><th>Received</th><th>Balance</th></tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>

    </div>
</asp:Content>
