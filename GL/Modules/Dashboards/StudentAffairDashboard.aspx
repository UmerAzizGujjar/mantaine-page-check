<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="StudentAffairDashboard.aspx.cs" Inherits="PMS.Modules.Dashboards.StudentAffairDashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <script src="<%= Page.ResolveClientUrl("~/wwwroot/lib/echarts/echarts.min.js") %>"></script>
    <style type="text/css">
        /* ---------- Layout: 12-column grid, one gutter everywhere ---------- */
        .bento-grid {
            --sa-maroon: #8e0016;
            --sa-gold: #EFA63E;
            --sa-green: #10b981;
            --sa-red: #c11718;
            --sa-blue: #438eb9;
            --sa-ink: #111827;
            --sa-muted: #6b7280;
            --sa-line: #e8ebf0;
            display: grid;
            grid-template-columns: repeat(12, minmax(0, 1fr));
            gap: 16px;
            align-items: stretch;
        }
        .sa-span-3 { grid-column: span 3; }
        .sa-span-4 { grid-column: span 4; }
        .sa-span-8 { grid-column: span 8; }
        .sa-span-12 { grid-column: span 12; }

        /* ---------- Card base ---------- */
        .bento-item {
            background: #fff;
            border: 1px solid var(--sa-line);
            border-radius: 14px;
            padding: 18px 20px;
            box-shadow: 0 1px 2px rgba(16, 24, 40, 0.04);
            display: flex;
            flex-direction: column;
            min-width: 0;
            transition: box-shadow 0.2s ease;
        }
        .bento-item:hover { box-shadow: 0 6px 20px rgba(16, 24, 40, 0.07); }

        .main-heading { font-size: 14px; font-weight: 700; color: var(--sa-ink); margin: 0; }
        .sub-heading { font-size: 11px; color: #9ca3af; margin: 2px 0 14px; }
        .sc-sub { font-size: 11px; color: #9ca3af; margin-top: 6px; }

        /* ---------- Header / period selector ---------- */
        .period-bar { flex-direction: row; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: 12px 20px; padding: 14px 20px; }
        .ph-title h1 { font-size: 18px; font-weight: 800; color: var(--sa-ink); margin: 0; line-height: 1.2; }
        .ph-title p { font-size: 12px; color: var(--sa-muted); margin: 3px 0 0; }
        .ph-controls { display: flex; flex-wrap: wrap; align-items: center; justify-content: flex-end; gap: 10px; }
        .period-pills { display: inline-flex; flex-wrap: wrap; gap: 4px; background: #f3f4f6; padding: 4px; border-radius: 999px; }
        .period-pill { border: 0; border-radius: 999px; padding: 6px 14px; font-size: 12px; font-weight: 600; background: transparent; color: #4b5563; cursor: pointer; transition: background 0.2s, color 0.2s; }
        .period-pill:hover { color: var(--sa-maroon); }
        .period-pill.active { background: var(--sa-maroon); color: #fff; box-shadow: 0 2px 6px rgba(142, 0, 22, 0.25); }
        .custom-date-range { display: none; gap: 8px; align-items: center; flex-wrap: wrap; }
        .custom-date-range.visible { display: flex !important; }
        .custom-date-range .form-control { width: 130px; height: 32px; font-size: 12px; }
        .ui-datepicker { z-index: 9999 !important; }

        /* ---------- KPI cards ---------- */
        .stat-card { position: relative; overflow: hidden; }
        .stat-card::before { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: var(--accent, var(--sa-maroon)); }
        .stat-card .sc-head { display: flex; align-items: center; justify-content: space-between; gap: 10px; margin-bottom: 12px; }
        .stat-card .sc-label { font-size: 11px; font-weight: 700; color: var(--sa-muted); text-transform: uppercase; letter-spacing: 0.6px; }
        .stat-card .sc-icon { width: 34px; height: 34px; border-radius: 10px; display: flex; align-items: center; justify-content: center; flex: none; background: var(--accent-soft, #fbeaec); color: var(--accent, var(--sa-maroon)); font-size: 15px; }
        .stat-card .sc-value { font-size: 26px; font-weight: 800; color: var(--sa-ink); line-height: 1.1; font-variant-numeric: tabular-nums; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .stat-card .sc-value.money { font-size: 22px; }

        /* ---------- Charts ---------- */
        .chart-box { width: 100%; flex: 1; min-height: 220px; }
        #chartTrend { min-height: 260px; }
        #chartFeeStatus, #chartClass { min-height: 230px; }
        #chartAtt { flex: none; min-height: 0; height: 120px; }

        .fee-status-meta { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 8px; margin-top: 12px; }
        .fs-chip { background: #f9fafb; border: 1px solid #f1f3f5; border-radius: 10px; padding: 8px 10px; min-width: 0; }
        .fs-chip .fs-l { font-size: 10px; color: var(--sa-muted); text-transform: uppercase; letter-spacing: 0.5px; font-weight: 600; }
        .fs-chip .fs-n { font-size: 12px; font-weight: 800; margin-top: 2px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

        /* ---------- Attendance ---------- */
        .att-wrap { display: flex; gap: 14px; align-items: center; flex: 1; }
        .att-donut { width: 120px; flex: none; text-align: center; }
        .att-rate { font-size: 20px; font-weight: 800; color: var(--sa-green); line-height: 1.1; }
        .att-list { flex: 1; min-width: 0; }
        .att-class-row { display: flex; align-items: center; gap: 8px; font-size: 11px; margin-bottom: 7px; }
        .att-class-row .ac-label { width: 90px; flex: none; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; color: #4b5563; }
        .att-class-row .ac-bar-bg { flex: 1; display: flex; background: #f3f4f6; border-radius: 4px; height: 8px; overflow: hidden; }
        .att-class-row .ac-bar-fill { height: 100%; background: var(--sa-green); }
        .att-class-row .ac-bar-abs { background: var(--sa-red); }
        .att-class-row .ac-txt { width: 100px; flex: none; text-align: right; color: var(--sa-muted); white-space: nowrap; }
        .att-class-row .ac-txt .ac-p { color: var(--sa-green); font-weight: 700; }
        .att-class-row .ac-txt .ac-a { color: var(--sa-red); font-weight: 700; }
        .att-class-row .ac-txt .ac-t { color: #9ca3af; }

        /* ---------- Outstanding ---------- */
        .out-total { display: flex; align-items: baseline; gap: 8px; }
        .out-total .ot-value { font-size: 22px; font-weight: 800; color: var(--sa-red); }
        .out-list { margin-top: 14px; }
        .out-row { display: flex; align-items: center; gap: 8px; font-size: 11px; margin-bottom: 7px; }
        .out-row .o-label { width: 96px; flex: none; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; color: #4b5563; }
        .out-row .o-bar-bg { flex: 1; background: #f3f4f6; border-radius: 4px; height: 8px; overflow: hidden; }
        .out-row .o-bar-fill { height: 100%; background: var(--sa-maroon); border-radius: 4px; }
        .out-row .o-txt { width: 96px; flex: none; text-align: right; color: var(--sa-muted); white-space: nowrap; }

        /* ---------- Recent receipts ---------- */
        #recent-table { width: 100%; border-collapse: collapse; font-size: 12px; }
        #recent-table th { text-align: left; background: #f9fafb; color: var(--sa-muted); text-transform: uppercase; font-size: 10px; letter-spacing: 0.5px; padding: 8px 10px; }
        #recent-table td { padding: 7px 10px; border-top: 1px solid #f3f4f6; color: #374151; }
        #recent-table tr:hover td { background: #fafafa; }

        /* ---------- Enrolment ---------- */
        .enrol-head { display: flex; flex-wrap: wrap; align-items: flex-end; justify-content: space-between; gap: 12px; margin-bottom: 16px; }
        .enrol-filters { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; }
        .enrol-filters .form-control { height: 32px; padding: 4px 10px; font-size: 12px; width: 170px; }
        .enr-pills { display: inline-flex; gap: 4px; background: #f3f4f6; padding: 3px; border-radius: 999px; }
        .enr-pill { border: 0; border-radius: 999px; padding: 4px 12px; font-size: 11px; font-weight: 600; background: transparent; color: #4b5563; cursor: pointer; transition: background 0.2s, color 0.2s; }
        .enr-pill:hover { color: var(--sa-maroon); }
        .enr-pill.active { background: var(--sa-maroon); color: #fff; }
        .enrol-counts { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 12px; margin-bottom: 16px; }
        .ec-box { background: #f9fafb; border-radius: 10px; padding: 10px 14px; border-left: 3px solid #d1d5db; }
        .ec-box.ec-active { border-left-color: var(--sa-green); }
        .ec-box.ec-inactive { border-left-color: var(--sa-red); }
        .ec-box .ec-n { font-size: 20px; font-weight: 800; color: var(--sa-ink); line-height: 1.1; }
        .ec-box .ec-l { font-size: 10px; color: var(--sa-muted); text-transform: uppercase; letter-spacing: 0.5px; margin-top: 2px; }
        .stu-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(190px, 1fr)); gap: 10px; max-height: 320px; overflow-y: auto; padding: 2px 4px 2px 2px; }
        .stu-card { position: relative; background: #fff; border: 1px solid #eef0f2; border-radius: 10px; padding: 10px 12px; min-width: 0; }
        .stu-card.active { border-left: 3px solid var(--sa-green); }
        .stu-card.inactive { border-left: 3px solid var(--sa-red); opacity: 0.85; }
        .stu-card .stu-name { font-size: 12px; font-weight: 700; color: #1f2937; padding-right: 58px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .stu-card .stu-meta { font-size: 11px; color: var(--sa-muted); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; margin-top: 2px; }
        .stu-card .stu-badge { position: absolute; top: 9px; right: 9px; font-size: 9px; font-weight: 700; text-transform: uppercase; padding: 2px 7px; border-radius: 8px; }
        .stu-card.active .stu-badge { background: #d1fae5; color: #047857; }
        .stu-card.inactive .stu-badge { background: #fee2e2; color: #b91c1c; }

        /* ---------- Loading / empty ---------- */
        .card-loading { opacity: 0.35; pointer-events: none; transition: opacity 0.2s; position: relative; }
        .card-loading::after {
            content: '';
            position: absolute; inset: 50% auto auto 50%;
            width: 28px; height: 28px; margin: -14px 0 0 -14px;
            border: 3px solid #e5e7eb; border-top-color: var(--sa-blue);
            border-radius: 50%; animation: spin 0.7s linear infinite;
            z-index: 10;
        }
        @keyframes spin { to { transform: rotate(360deg); } }
        .no-data { text-align: center; color: #9ca3af; font-size: 12px; padding: 30px 0; }

        /* ---------- Responsive ---------- */
        @media (max-width: 1199px) {
            .sa-span-3, .sa-span-4 { grid-column: span 6; }
            .sa-span-8 { grid-column: span 12; }
            .enrol-counts { grid-template-columns: repeat(2, minmax(0, 1fr)); }
        }
        @media (max-width: 767px) {
            .bento-grid { gap: 12px; }
            .bento-item { padding: 16px; }
            .sa-span-3 { grid-column: span 6; }
            .sa-span-4 { grid-column: span 12; }
            .stat-card .sc-value { font-size: 20px; }
            .stat-card .sc-value.money { font-size: 16px; }
            .ph-controls { justify-content: flex-start; width: 100%; }
            .custom-date-range .form-control { width: 120px; }
            .enrol-filters { width: 100%; }
            .enrol-filters .form-control { flex: 1 1 150px; width: auto; }
        }
        @media (max-width: 575px) {
            .sa-span-3 { grid-column: span 12; }
            .stat-card .sc-value { font-size: 24px; }
            .stat-card .sc-value.money { font-size: 20px; }
            .enrol-counts { gap: 8px; }
        }
    </style>

    <script type="text/javascript">
        var saCharts = {};

        function saDispose(id) {
            if (saCharts[id]) { saCharts[id].dispose(); saCharts[id] = null; }
        }
        function saInit(id) {
            saDispose(id);
            var dom = document.getElementById(id);
            if (!dom || typeof echarts === 'undefined') return null;
            saCharts[id] = echarts.init(dom);
            return saCharts[id];
        }
        function saFmt(v) {
            try { return Number(v || 0).toLocaleString('en-PK', { maximumFractionDigits: 0 }); }
            catch (e) { return Number(v || 0).toLocaleString('en-US', { maximumFractionDigits: 0 }); }
        }
        function saMoney(v) { return 'Rs. ' + saFmt(v); }

        function saAjax(url, data, fn) {
            data = data || {};
            for (var k in data) { if (data[k] === undefined) data[k] = null; }
            $.ajax({
                type: "POST",
                url: "StudentAffairDashboard.aspx/" + url,
                data: JSON.stringify(data),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var r = JSON.parse(res.d);
                    if (r && r.Error) { return; }
                    if (fn) fn(r);
                },
                error: function () { }
            });
        }
        function saPillState() {
            var pill = $(".period-pill.active");
            var p = pill.data("period");
            var s = null, e = null;
            if (p === "custom") { s = $("#saStartDate").val(); e = $("#saEndDate").val(); }
            return { period: p, startDate: s, endDate: e };
        }

        function saLoadOverall() {
            saAjax("GetOverallStats", {}, function (r) {
                $("#valActive").text(saFmt(r.ActiveStudents));
                $("#subActive").text(saFmt(r.InactiveStudents) + ' inactive / ' + saFmt(r.TotalStudents) + ' total');
            });
        }

        function saLoadStats(p, s, e) {
            saAjax("GetStats", { period: p, startDate: s, endDate: e }, function (r) {
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
                    legend: { data: ['Fees Generated', 'Collections'], top: 0, right: 0, icon: 'circle', itemWidth: 8, itemHeight: 8, textStyle: { fontSize: 11, color: '#6b7280' } },
                    grid: { left: 8, right: 8, top: 36, bottom: 4, containLabel: true },
                    xAxis: { type: 'category', data: months, axisLine: { lineStyle: { color: '#e5e7eb' } }, axisTick: { show: false }, axisLabel: { fontSize: 10, color: '#6b7280' } },
                    yAxis: { type: 'value', show: false, min: 0 },
                    series: [
                        { name: 'Fees Generated', type: 'bar', data: r.Fees || [], itemStyle: { color: '#8e0016', borderRadius: [4, 4, 0, 0] }, barWidth: '26%' },
                        { name: 'Collections', type: 'bar', data: r.Collections || [], itemStyle: { color: '#10b981', borderRadius: [4, 4, 0, 0] }, barWidth: '26%' }
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
                    var tot = c.Total || 0;
                    var pp = tot ? Math.round(c.Present / tot * 100) : 0;
                    var ap = tot ? Math.round(c.Absent / tot * 100) : 0;
                    html += '<div class="att-class-row"><span class="ac-label" title="' + c.Label + '">' + c.Label + '</span>' +
                        '<div class="ac-bar-bg"><div class="ac-bar-fill" style="width:' + pp + '%"></div>' +
                        '<div class="ac-bar-fill ac-bar-abs" style="width:' + ap + '%"></div></div>' +
                        '<span class="ac-txt"><span class="ac-p">' + pp + '%</span> / <span class="ac-a">' + ap + '%</span> <span class="ac-t">(' + tot + ')</span></span></div>';
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
                    legend: { bottom: 0, left: 'center', type: 'scroll', icon: 'circle', itemWidth: 8, itemHeight: 8, textStyle: { fontSize: 10, color: '#6b7280' }, pageIconSize: 10 },
                    series: [{
                        type: 'pie', radius: ['40%', '62%'], center: ['50%', '42%'],
                        avoidLabelOverlap: false,
                        label: { show: false },
                        data: dist.map(function (d, i) { return { value: d.Count, name: d.Label, itemStyle: { color: palette[i % palette.length] } }; })
                    }],
                    graphic: [{
                        type: 'text', left: 'center', top: '36%',
                        style: { text: String(r.Total), fill: '#111827', fontSize: 18, fontWeight: 800, textAlign: 'center' },
                        z: 100
                    }]
                });
            });
        }

        function saLoadRecent() {
            saAjax("GetRecentReceipts", {}, function (list) {
                var $tb = $("#recent-table tbody");
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

        function saLoadEnrolmentFilters() {
            saAjax("GetEnrolmentFilters", {}, function (r) {
                var cOpts = '<option value="0">All Classes</option>';
                (r.Classes || []).forEach(function (o) { cOpts += '<option value="' + o.Value + '">' + o.Label + '</option>'; });
                var pOpts = '<option value="0">All Programs</option>';
                (r.Programs || []).forEach(function (o) { pOpts += '<option value="' + o.Value + '">' + o.Label + '</option>'; });
                $("#saClass").html(cOpts);
                $("#saProgram").html(pOpts);
                if ($.fn.select2) { $("#saClass, #saProgram").select2({ width: '170px' }); }
                saLoadEnrolment();
            });
        }

        function saLoadEnrolment() {
            var cls = $("#saClass").val() || "0";
            var prog = $("#saProgram").val() || "0";
            var status = $(".enr-pill.active").data("status") || "";
            saAjax("GetEnrolmentList", { cls: cls, prog: prog, status: status }, function (r) {
                $("#enrTotal").text(saFmt(r.Total));
                $("#enrActive").text(saFmt(r.Active));
                $("#enrInactive").text(saFmt(r.Inactive));
                $("#enrShown").text(saFmt(r.Shown));
                var list = r.Students || [];
                var html = list.length ? "" : '<div class="no-data" style="grid-column:1/-1;">No students match this filter</div>';
                list.forEach(function (s) {
                    var cls2 = s.Active ? "active" : "inactive";
                    html += '<div class="stu-card ' + cls2 + '">' +
                        '<span class="stu-badge">' + (s.Active ? 'Active' : 'Inactive') + '</span>' +
                        '<div class="stu-name" title="' + s.Name + '">' + s.Name + '</div>' +
                        '<div class="stu-meta">Roll: ' + (s.Roll || '-') + ' &bull; ' + (s.Class || '-') + '</div>' +
                        '<div class="stu-meta">' + (s.Program || '-') + '</div></div>';
                });
                $("#stuGrid").html(html);
            });
        }

        function saFmtDate(d) {
            var dd = ('0' + d.getDate()).slice(-2);
            var mm = ('0' + (d.getMonth() + 1)).slice(-2);
            return dd + '/' + mm + '/' + d.getFullYear();
        }
        function saPeriodRange(period) {
            var today = new Date(), s = null, e = null, d;
            if (period === "today") { s = saFmtDate(today); e = s; }
            else if (period === "yesterday") { d = new Date(today); d.setDate(d.getDate() - 1); s = saFmtDate(d); e = s; }
            else if (period === "week") {
                d = new Date(today);
                d.setDate(d.getDate() - ((today.getDay() + 6) % 7));
                s = saFmtDate(d); e = saFmtDate(today);
            }
            else if (period === "month") { s = saFmtDate(new Date(today.getFullYear(), today.getMonth(), 1)); e = saFmtDate(today); }
            else if (period === "year") { s = saFmtDate(new Date(today.getFullYear(), 0, 1)); e = saFmtDate(today); }
            return { startDate: s, endDate: e };
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
                var r = saPeriodRange(p);
                if (r.startDate) { s = r.startDate; e = r.endDate; }
            }
            $(".bento-item:not(.period-bar)").addClass("card-loading");
            setTimeout(function () { $(".bento-item").removeClass("card-loading"); }, 120000);
            saLoadStats(p, s, e);
            saLoadTrend(p, s, e);
            saLoadFeeStatus(p, s, e);
            saLoadAttendance(p, s, e);
        }

        $(document).ajaxStop(function () { $(".bento-item").removeClass("card-loading"); });

        $(document).ready(function () {
            if ($.fn.datepicker) {
                $(".datepicker").datepicker({ changeMonth: true, changeYear: true, dateFormat: "dd/mm/yy", yearRange: "-5:+0" });
            }

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

            $("#saClass, #saProgram").on("change", function () { saLoadEnrolment(); });

            $(".enr-pill").click(function () {
                $(".enr-pill").removeClass("active");
                $(this).addClass("active");
                saLoadEnrolment();
            });

            $(window).on("resize", function () {
                for (var k in saCharts) { if (saCharts[k] && saCharts[k].resize) saCharts[k].resize(); }
            });

            saLoadDistribution();
            saLoadRecent();
            saLoadOverall();
            saLoadEnrolmentFilters();
            saSetPeriod("today");
        });
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="bento-grid">

        <div class="bento-item period-bar sa-span-12">
            <div class="ph-title">
                <h1>Student Affairs</h1>
                <p>Admissions, fees, attendance and enrolment at a glance</p>
            </div>
            <div class="ph-controls">
                <div class="period-pills">
                    <button type="button" class="period-pill active" data-period="today">Today</button>
                    <button type="button" class="period-pill" data-period="yesterday">Yesterday</button>
                    <button type="button" class="period-pill" data-period="week">This Week</button>
                    <button type="button" class="period-pill" data-period="month">This Month</button>
                    <button type="button" class="period-pill" data-period="year">This Year</button>
                    <button type="button" class="period-pill" data-period="custom">Custom</button>
                </div>
                <div class="custom-date-range">
                    <input type="text" id="saStartDate" class="form-control datepicker" placeholder="Start Date" readonly />
                    <span style="color:#6b7280;">to</span>
                    <input type="text" id="saEndDate" class="form-control datepicker" placeholder="End Date" readonly />
                    <button type="button" class="btn btn-sm btn-primry" id="btnSaApply">Apply</button>
                </div>
            </div>
        </div>

        <div class="bento-item stat-card sa-span-3" style="--accent:#8e0016; --accent-soft:rgba(142,0,22,0.08);">
            <div class="sc-head">
                <span class="sc-label">Active Students</span>
                <span class="sc-icon"><i class="fa fa-graduation-cap"></i></span>
            </div>
            <div class="sc-value" id="valActive">0</div>
            <div class="sc-sub" id="subActive">Overall &mdash; all students</div>
        </div>

        <div class="bento-item stat-card sa-span-3" style="--accent:#438eb9; --accent-soft:rgba(67,142,185,0.10);">
            <div class="sc-head">
                <span class="sc-label">New Admissions</span>
                <span class="sc-icon"><i class="fa fa-user-plus"></i></span>
            </div>
            <div class="sc-value" id="valAdm">0</div>
            <div class="sc-sub" id="subAdm">In selected period</div>
        </div>

        <div class="bento-item stat-card sa-span-3" style="--accent:#EFA63E; --accent-soft:rgba(239,166,62,0.12);">
            <div class="sc-head">
                <span class="sc-label">Fees Generated</span>
                <span class="sc-icon"><i class="fa fa-file-text-o"></i></span>
            </div>
            <div class="sc-value money" id="valFees">Rs. 0</div>
            <div class="sc-sub" id="subFees">Selected period</div>
        </div>

        <div class="bento-item stat-card sa-span-3" style="--accent:#10b981; --accent-soft:rgba(16,185,129,0.10);">
            <div class="sc-head">
                <span class="sc-label">Collections</span>
                <span class="sc-icon"><i class="fa fa-money"></i></span>
            </div>
            <div class="sc-value money" id="valColl">Rs. 0</div>
            <div class="sc-sub" id="subColl">Amount received</div>
        </div>

        <div class="bento-item sa-span-8" id="trend-area">
            <div class="main-heading">Monthly Fees vs Collections</div>
            <div class="sub-heading">Year to date</div>
            <div class="chart-box" id="chartTrend"></div>
        </div>

        <div class="bento-item sa-span-4" id="status-area">
            <div class="main-heading">Fee Voucher Status</div>
            <div class="sub-heading">Selected period</div>
            <div class="chart-box" id="chartFeeStatus"></div>
            <div class="fee-status-meta">
                <div class="fs-chip"><div class="fs-l">Approved</div><div class="fs-n" id="fsAppr" style="color:#10b981;">0</div></div>
                <div class="fs-chip"><div class="fs-l">Unapproved</div><div class="fs-n" id="fsUnappr" style="color:#b7791f;">0</div></div>
                <div class="fs-chip"><div class="fs-l">Cancelled</div><div class="fs-n" id="fsCanc" style="color:#c11718;">0</div></div>
            </div>
        </div>

        <div class="bento-item sa-span-4" id="att-area">
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

        <div class="bento-item sa-span-4" id="classdist-area">
            <div class="main-heading">Students by Class</div>
            <div class="sub-heading">Active enrolments</div>
            <div class="chart-box" id="chartClass"></div>
        </div>

        <div class="bento-item sa-span-4" id="out-area">
            <div class="main-heading">Outstanding Receivables</div>
            <div class="sub-heading">Approved fees less collected</div>
            <div class="out-total"><span class="ot-value" id="outTotal">Rs. 0</span><span class="sc-sub">By class</span></div>
            <div class="out-list" id="outList"></div>
        </div>

        <div class="bento-item sa-span-12" id="recent-area" style="display:none;">
            <div class="main-heading">Recent Approved Receipts</div>
            <div class="sub-heading">Latest 8</div>
            <table id="recent-table">
                <thead>
                    <tr><th>Receipt No</th><th>Date</th><th>Student</th><th>Received</th><th>Balance</th></tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>

        <div class="bento-item sa-span-12" id="enrol-area">
            <div class="enrol-head">
                <div>
                    <div class="main-heading">Student Enrolment</div>
                    <div class="sub-heading" style="margin-bottom:0;">Active &amp; inactive students</div>
                </div>
                <div class="enrol-filters">
                    <select id="saClass" class="form-control"></select>
                    <select id="saProgram" class="form-control"></select>
                    <div class="enr-pills">
                        <button type="button" class="enr-pill active" data-status="">All</button>
                        <button type="button" class="enr-pill" data-status="active">Active</button>
                        <button type="button" class="enr-pill" data-status="inactive">Inactive</button>
                    </div>
                </div>
            </div>
            <div class="enrol-counts">
                <div class="ec-box"><div class="ec-n" id="enrTotal">0</div><div class="ec-l">Total</div></div>
                <div class="ec-box ec-active"><div class="ec-n" id="enrActive">0</div><div class="ec-l">Active</div></div>
                <div class="ec-box ec-inactive"><div class="ec-n" id="enrInactive">0</div><div class="ec-l">Inactive</div></div>
                <div class="ec-box"><div class="ec-n" id="enrShown">0</div><div class="ec-l">Showing</div></div>
            </div>
            <div class="stu-grid" id="stuGrid"></div>
        </div>

    </div>
</asp:Content>
