<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="StudentAffairDashboard.aspx.cs" Inherits="PMS.Modules.Dashboards.StudentAffairDashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <script src="<%= Page.ResolveClientUrl("~/wwwroot/lib/echarts/echarts.min.js") %>"></script>
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
                "recent recent recent recent"
                "enrol enrol enrol enrol";
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
        #enrol-area { grid-area: enrol; align-self: start; }

        .enrol-head { display: flex; flex-direction: column; align-items: flex-start; gap: 8px; }
        .enrol-filters { display: flex; gap: 8px; align-items: center; flex-wrap: nowrap; }
        .enr-pills { display: flex; gap: 4px; }
        .enr-pill { border: 1px solid #d1d5db; border-radius: 16px; padding: 3px 12px; font-size: 11px; font-weight: 600; background: #fff; color: #374151; cursor: pointer; }
        .enr-pill.active { background: #8e0016; border-color: #8e0016; color: #fff; }
        .enrol-counts { display: flex; gap: 10px; margin: 10px 0; flex-wrap: wrap; }
        .ec-box { flex: 1; min-width: 100px; background: #f9fafb; border-radius: 8px; padding: 8px 12px; border-left: 3px solid #d1d5db; }
        .ec-box.ec-active { border-left-color: #10b981; }
        .ec-box.ec-inactive { border-left-color: #c11718; }
        .ec-box .ec-n { font-size: 20px; font-weight: 800; color: #111827; }
        .ec-box .ec-l { font-size: 9px; color: #6b7280; text-transform: uppercase; letter-spacing: 0.5px; }
        .stu-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)); gap: 8px; max-height: 240px; overflow-y: auto; padding-right: 2px; }
        .stu-card { position: relative; background: #fff; border: 1px solid #eef0f2; border-radius: 8px; padding: 8px 10px; }
        .stu-card.active { border-left: 3px solid #10b981; }
        .stu-card.inactive { border-left: 3px solid #c11718; opacity: 0.85; }
        .stu-card .stu-name { font-size: 12px; font-weight: 700; color: #1f2937; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .stu-card .stu-meta { font-size: 10px; color: #6b7280; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .stu-card .stu-badge { position: absolute; top: 8px; right: 8px; font-size: 8px; font-weight: 700; text-transform: uppercase; padding: 1px 6px; border-radius: 8px; }
        .stu-card.active .stu-badge { background: #d1fae5; color: #047857; }
        .stu-card.inactive .stu-badge { background: #fee2e2; color: #b91c1c; }

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
        .att-class-row .ac-bar-bg { flex: 1; display: flex; background: #f3f4f6; border-radius: 4px; height: 8px; overflow: hidden; }
        .att-class-row .ac-bar-fill { height: 100%; background: #10b981; }
        .att-class-row .ac-bar-abs { background: #ef4444; }
        .att-class-row .ac-txt { width: 112px; text-align: right; color: #6b7280; white-space: nowrap; }
        .att-class-row .ac-txt .ac-p { color: #10b981; font-weight: 700; }
        .att-class-row .ac-txt .ac-a { color: #ef4444; font-weight: 700; }
        .att-class-row .ac-txt .ac-t { color: #9ca3af; }

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
            <div class="sc-sub" id="subActive">Overall &mdash; all students</div>
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

        <div class="bento-item" id="recent-area" style="display:none;">
            <div class="main-heading">Recent Approved Receipts</div>
            <div class="sub-heading">Latest 8</div>
            <table id="recent-table">
                <thead>
                    <tr><th>Receipt No</th><th>Date</th><th>Student</th><th>Received</th><th>Balance</th></tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>

        <div class="bento-item" id="enrol-area">
            <div class="enrol-head">
                <div>
                    <div class="main-heading">Student Enrolment</div>
                    <div class="sub-heading">Active &amp; inactive students</div>
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
