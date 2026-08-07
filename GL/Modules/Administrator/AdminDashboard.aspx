<%@ Page Title="Admin Dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="PMS.Modules.Administrator.AdminDashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/echarts@5/dist/echarts.min.js"></script>
    <script type="text/javascript">
        var chartInstances = {};

        $(document).ready(function () {
            var yesterday = new Date(); yesterday.setDate(yesterday.getDate() - 1);
            var yStr = $.datepicker.formatDate('dd/mm/yy', yesterday);
            $(".datepicker").datepicker({
                changeMonth: true, changeYear: true,
                dateFormat: "dd/mm/yy", yearRange: "-100:+0"
            });
            $("#txtStartDate").datepicker("setDate", yStr);
            $("#txtEndDate").datepicker("setDate", yStr);
            $("#ddlDepartment").select2({ placeholder: "Select Department", allowClear: true, width: '100%' });
            $("#ddlDoctor").select2({ placeholder: "Select Doctor", allowClear: true, width: '100%' });
            $("#btnApplyFilters").click(function () { applyFilters(); });
            loadDepartments();
            loadAllData();
        }); 

        function getFilters() {
            return {
                startDate: $("#txtStartDate").val(),
                endDate: $("#txtEndDate").val(),
                department: $("#ddlDepartment").val() || "0",
                doctor: $("#ddlDoctor").val() || "0"
            };
        }

        function post(method, data, callback) {
            $.ajax({
                type: "POST",
                url: "AdminDashboard.aspx/" + method,
                data: JSON.stringify(data),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    try {
                        var r = JSON.parse(res.d);
                        if (r.success && callback) callback(r.data);
                        else if (!r.success) console.error(method + " error: " + (r.error || "unknown"));
                    } catch (ex) {
                        console.error(method + " parse error: " + ex);
                    }
                },
                error: function (xhr, s, e) { console.error(method + ": " + e); }
            });
        }

        function loadDepartments() {
            post("GetDepartments", {}, function (data) {
                var opts = "";
                data.forEach(function (d) { opts += '<option value="' + d.value + '">' + d.text + '</option>'; });
                $("#ddlDepartment").html(opts).val("0").trigger("change");
            });
            post("GetDoctors", { department: "0" }, function (data) {
                var opts = "";
                data.forEach(function (d) { opts += '<option value="' + d.value + '">' + d.text + '</option>'; });
                $("#ddlDoctor").html(opts).val("0").trigger("change");
            });
        }

        function loadAllData() {
            $(".bento-item").addClass("card-loading");
            var f = getFilters();
            post("GetDashboardData", f, function (d) {
                if (!d) { $(".bento-item").removeClass("card-loading"); return; }
                renderKpis(d.kpi);
                renderAppointmentFunnel(d.funnel);
                renderNewVsFollowUp(d.retention);
                renderBarChart("chartConsultantBar", d.specialist);
                renderBarChart("chartWalkInBar", d.walkIn);
                renderOPDTrends(d.opdTrends);
                renderAgeGroup(d.ageGroup);
                renderConsultDistribution(d.distribution);
                renderGenderData(d.gender);
                renderSpecialistTable(d.specialist);
                renderWalkInTable(d.walkIn);
                renderRevenueTable(d.revenue);
                renderBillingTable(d.billing);
                renderInvestigationTable(d.investigation);
                renderDeptTiles(d.deptTiles);
                $(".bento-item").removeClass("card-loading");
                $("#pageLoader").addClass("hidden");
            });
        }

        $(document).ajaxStop(function () {
            $(".bento-item").removeClass("card-loading");
            $("#pageLoader").addClass("hidden");
        });

        function disposeChart(id) { if (chartInstances[id]) { chartInstances[id].dispose(); delete chartInstances[id]; } }
        function initChart(id) {
            disposeChart(id);
            var dom = document.getElementById(id);
            if (!dom) return null;
            chartInstances[id] = echarts.init(dom);
            return chartInstances[id];
        }

        function fmt(n) { return typeof n === 'number' ? n.toLocaleString() : n; }

        /* ─── KPI ─── */
        function renderKpis(d) {
            $("#lblTotalVisited").text(d.totalVisited);
            $("#lblWalkInVolume").text(d.walkInVolume);
            $("#lblTotalAppointments").text(d.totalAppointments);
            $("#lblConsultantCheckups").text(d.consultantCheckups);
            $("#lblCancellationRate").text(d.cancellationRate || "0%");
            $("#lblRevenueYield").text(d.revenueYield);
            if (d.todayDiff !== undefined) {
                var trendingUp = d.todayDiff >= 0;
                var arrow = trendingUp ? '&#9650;' : '&#9660;';
                $(".kpi-status .vs-text").text('vs Yesterday');
                $(".kpi-status").each(function (i) {
                    var label = "";
                    if (i === 0) label = "totalVisitedDiff";
                    else if (i === 1) label = "walkInDiff";
                    else if (i === 2) label = "appointmentsDiff";
                    else if (i === 3) label = "checkupsDiff";
                    else if (i === 4) label = "cancellationDiff";
                    else if (i === 5) label = "revenueDiff";
                    if (d[label] !== undefined) {
                        var up = d[label] >= 0;
                        $(this).html((up ? '&#9650;' : '&#9660;') + ' <span class="vs-text">vs Yesterday</span>');
                        if (up) { $(this).removeClass('caution').addClass('normal'); }
                        else { $(this).removeClass('normal').addClass('caution'); }
                    }
                });
            }
        }

        /* ─── APPOINTMENT FUNNEL ─── */
        function renderAppointmentFunnel(d) {
            var chart = initChart("chartAppointmentDonut");
            if (!chart) return;
            chart.setOption({
                tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
                series: [{
                    type: 'pie', radius: ['50%', '70%'],
                    avoidLabelOverlap: false, label: { show: false },
                    data: [
                        { value: d.visited, name: 'Visited', itemStyle: { color: '#1a4332' } },
                        { value: d.noShow, name: 'No-Show', itemStyle: { color: '#f59e0b' } },
                        { value: d.cancelled, name: 'Cancelled', itemStyle: { color: '#ef4444' } }
                    ]
                }]
            });
            $("#lblFunnelVisited").text(fmt(d.visited));
            $("#lblFunnelNoShow").text(fmt(d.noShow));
            $("#lblFunnelCancelled").text(fmt(d.cancelled));
        }

        /* ─── NEW VS FOLLOW-UP ─── */
        function renderNewVsFollowUp(data) {
            var chart = initChart("chartNewVsFollowUp");
            if (!chart) return;
            var weeks = data.map(function (d) { return d.week; });
            var newP = data.map(function (d) { return d.newPatients; });
            var rtn = data.map(function (d) { return d.returning; });
            var allVals = newP.concat(rtn);
            var maxV = allVals.length > 0 ? Math.max.apply(null, allVals) * 1.35 : 10;
            chart.setOption({
                tooltip: { trigger: 'axis' },
                legend: { data: ['New Patients', 'Returning (7d)'], bottom: 0, left: 'center', icon: 'circle', itemWidth: 8, itemHeight: 8, textStyle: { fontSize: 10 } },
                grid: { left: 50, right: 50, top: 50, bottom: 40 },
                xAxis: { type: 'category', data: weeks, axisLabel: { fontSize: 10, fontWeight: 600 }, axisLine: { show: false }, axisTick: { show: false } },
                yAxis: { type: 'value', splitLine: { lineStyle: { color: '#f1f5f9', type: 'dashed' } }, axisLabel: { fontSize: 9 }, max: maxV },
                series: [
                    { name: 'New Patients', type: 'bar', barWidth: 18, barGap: '20%', data: newP.map(function (v) { return { value: v, itemStyle: { color: '#1a4332', borderRadius: [4, 4, 0, 0] } }; }), label: { show: true, position: 'top', color: '#1a4332', fontSize: 9, fontWeight: 'bold', offset: [0, 6] } },
                    { name: 'Returning (7d)', type: 'bar', barWidth: 18, data: rtn.map(function (v) { return { value: v, itemStyle: { color: '#10b981', borderRadius: [4, 4, 0, 0] } }; }), label: { show: true, position: 'top', color: '#10b981', fontSize: 9, fontWeight: 'bold', offset: [0, 6] } }
                ]
            });
        }

        function renderBarChart(chartId, data) {
            var chart = initChart(chartId);
            if (!chart) return;
            var names = data.map(function (d) { return d.name; }).slice(0, 10);
            var vals = data.map(function (d) { return d.patientsSeen; }).slice(0, 10);
            chart.setOption({
                tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
                grid: { left: 100, right: 60, top: 10, bottom: 25 },
                xAxis: { type: 'value', axisLabel: { fontSize: 9 }, splitLine: { show: false } },
                yAxis: { type: 'category', data: names.reverse(), axisLabel: { fontSize: 9, fontWeight: 600, width: 95, overflow: 'truncate' }, axisLine: { show: false }, axisTick: { show: false } },
                series: [{ type: 'bar', barWidth: 14, data: vals.reverse().map(function (v) { return { value: v, itemStyle: { color: '#1a4332', borderRadius: [0, 4, 4, 0] } }; }), label: { show: true, position: 'right', color: '#1a4332', fontSize: 10, fontWeight: 'bold', offset: [10, 0] } }]
            });
        }

        /* ─── OPD TRENDS ─── */
        function renderOPDTrends(data) {
            var chart = initChart("chartOPDTrends");
            if (!chart) return;
            var hrs = data.map(function (d) { return d.hour; });
            var vals = data.map(function (d) { return d.value; });
            var maxV = Math.max.apply(null, vals) * 1.25;
            chart.setOption({
                tooltip: { trigger: 'axis' },
                grid: { left: 40, right: 30, top: 35, bottom: 25 },
                xAxis: { type: 'category', data: hrs, axisLabel: { fontSize: 10, fontWeight: 600 }, axisLine: { show: false }, axisTick: { show: false } },
                yAxis: { type: 'value', splitLine: { lineStyle: { color: '#f1f5f9', type: 'dashed' } }, axisLabel: { fontSize: 9 }, max: maxV },
                series: [{ type: 'line', smooth: true, data: vals, lineStyle: { color: '#1a4332', width: 3 }, itemStyle: { color: '#1a4332' }, areaStyle: { color: 'rgba(26,67,50,0.08)' }, symbol: 'circle', symbolSize: 6, label: { show: true, position: 'top', color: '#1a4332', fontSize: 9, fontWeight: 'bold', offset: [0, 6] } }]
            });
        }

        /* ─── AGE GROUP ─── */
        function renderAgeGroup(data) {
            var chart = initChart("chartAgeGroup");
            if (!chart) return;
            var colors = ['#1a4332', '#2d5a47', '#4a8268', '#6ba88a', '#92cea9', '#b8e4c7', '#d6f2e1'];
            var ranges = data.map(function (d) { return d.range; });
            var vals = data.map(function (d) { return d.value; });
            var maxV = Math.max.apply(null, vals) * 1.25;
            chart.setOption({
                tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
                grid: { left: 40, right: 30, top: 50, bottom: 30 },
                xAxis: { type: 'category', data: ranges, axisLabel: { fontSize: 10, fontWeight: 600 }, axisLine: { show: false }, axisTick: { show: false } },
                yAxis: { type: 'value', splitLine: { lineStyle: { color: '#f1f5f9', type: 'dashed' } }, axisLabel: { fontSize: 9 }, max: maxV },
                series: [{ type: 'bar', barWidth: 28, data: vals.map(function (v, i) { return { value: v, itemStyle: { color: colors[i], borderRadius: [8, 8, 0, 0] } }; }), label: { show: true, position: 'top', color: '#1a4332', fontSize: 9, fontWeight: 'bold', offset: [0, 6] } }]
            });
        }

        /* ─── CONSULTATION DISTRIBUTION ─── */
        function renderConsultDistribution(data) {
            var chart = initChart("chartConsultDistribution");
            if (!chart) return;
            var ranges = data.map(function (d) { return d.range; });
            var vals = data.map(function (d) { return d.count; });
            var maxIdx = 0;
            for (var i = 0; i < vals.length; i++) { if (vals[i] > vals[maxIdx]) maxIdx = i; }
            chart.setOption({
                tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
                grid: { left: 55, right: 50, top: 10, bottom: 25 },
                xAxis: { type: 'value', axisLabel: { fontSize: 9 }, splitLine: { show: false } },
                yAxis: { type: 'category', data: ranges, axisLabel: { fontSize: 11, fontWeight: 800 }, axisLine: { show: false }, axisTick: { show: false } },
                series: [{ type: 'bar', barWidth: 20, data: vals.map(function (v) { return { value: v, itemStyle: { color: '#1a4332', borderRadius: [0, 4, 4, 0] } }; }), label: { show: true, position: 'right', color: '#1a4332', fontSize: 11, fontWeight: 'bold', offset: [10, 0] } }]
            });
            $("#lblMostCommonRange").text(ranges[maxIdx]);
            $("#lblMostCommonCount").text(fmt(vals[maxIdx]));
        }

        /* ─── GENDER ─── */
        function renderGenderData(d) {
            var chart = initChart("chartGender");
            if (!chart) return;
            var maxP = Math.max(d.male.patients, d.female.patients) * 1.25;
            var maxT = Math.max(d.male.avgTime, d.female.avgTime) * 1.35;
            chart.setOption({
                tooltip: { trigger: 'axis' },
                legend: { data: ['Patients', 'Avg Time (min)'], bottom: 0, left: 'center', icon: 'circle', itemWidth: 8, itemHeight: 8, textStyle: { fontSize: 10 } },
                grid: { left: 50, right: 50, top: 50, bottom: 35 },
                xAxis: { type: 'category', data: ['Male', 'Female'], axisLabel: { fontSize: 11, fontWeight: 800 }, axisLine: { show: false }, axisTick: { show: false } },
                yAxis: [
                    { type: 'value', splitLine: { lineStyle: { color: '#f1f5f9', type: 'dashed' } }, axisLabel: { fontSize: 9 }, max: maxP },
                    { type: 'value', splitLine: { show: false }, axisLabel: { fontSize: 9 }, max: maxT }
                ],
                series: [
                    { name: 'Patients', type: 'bar', barWidth: 28, barGap: '20%', data: [{ value: d.male.patients, itemStyle: { color: '#1a4332', borderRadius: [4, 4, 0, 0] } }, { value: d.female.patients, itemStyle: { color: '#10b981', borderRadius: [4, 4, 0, 0] } }], label: { show: true, position: 'top', color: '#1a4332', fontSize: 9, fontWeight: 'bold', offset: [0, 6] } },
                    { name: 'Avg Time (min)', type: 'bar', barWidth: 18, yAxisIndex: 1, data: [{ value: d.male.avgTime, itemStyle: { color: '#9333ea', borderRadius: [4, 4, 0, 0] } }, { value: d.female.avgTime, itemStyle: { color: '#9333ea', borderRadius: [4, 4, 0, 0] } }], label: { show: true, position: 'top', color: '#9333ea', fontSize: 9, fontWeight: 'bold', offset: [0, 6] } }
                ]
            });
        }

        /* ─── SPECIALIST TABLE ─── */
        function renderSpecialistTable(data) {
            var html = "";
            (data || []).forEach(function (d) {
                var name = d.name || "Unknown";
                var initial = name.split(' ').pop().charAt(0) || 'D';
                var appts = d.appointments || 0;
                var seen = d.patientsSeen || 0;
                var avg = d.avgPerDay || 0;
                var growth = d.growth || 0;
                var arrow = growth >= 0 ? '&#9650;' : '&#9660;';
                var cls = growth >= 0 ? 'growth-up' : 'growth-down';
                html += '<tr><td><div class="dept-badge"><span class="avatar">' + initial + '</span>' + name + '</div></td><td>' + fmt(appts) + '</td><td>' + fmt(seen) + '</td><td>' + avg + '</td><td class="' + cls + '">' + (growth >= 0 ? '+' : '') + growth + '% ' + arrow + '</td></tr>';
            });
            $("#tblSpecialist tbody").html(html);
        }

        /* ─── WALK-IN TABLE ─── */
        function renderWalkInTable(data) {
            var html = "";
            (data || []).forEach(function (d) {
                var name = d.name || "Unknown";
                var initial = name.split(' ').pop().charAt(0) || 'D';
                var seen = d.patientsSeen || 0;
                var avg = d.avgPerDay || 0;
                var growth = d.growth || 0;
                var arrow = growth >= 0 ? '&#9650;' : '&#9660;';
                var cls = growth >= 0 ? 'growth-up' : 'growth-down';
                html += '<tr><td><div class="dept-badge"><span class="avatar">' + initial + '</span>' + name + '</div></td><td>' + fmt(seen) + '</td><td>' + avg + '</td><td class="' + cls + '">' + (growth >= 0 ? '+' : '') + growth + '% ' + arrow + '</td></tr>';
            });
            $("#tblWalkIn tbody").html(html);
        }

        /* ─── REVENUE TABLE ─── */
        function renderRevenueTable(data) {
            var html = "", tG = 0, tD = 0, tR = 0, tN = 0;
            data.forEach(function (d) {
                html += '<tr><td>' + d.category + '</td><td>' + fmt(d.grossAmount) + '</td><td style="color:#d97706;">-' + fmt(d.discount) + '</td><td style="color:#dc2626;">' + (d.refund > 0 ? '-' + fmt(d.refund) : '0') + '</td><td>' + fmt(d.netCollection) + '</td></tr>';
                tG += d.grossAmount; tD += d.discount; tR += d.refund; tN += d.netCollection;
            });
            $("#tblRevenue tbody").html(html);
            $("#tblRevenue tfoot td:eq(0)").text('GRAND TOTAL');
            $("#tblRevenue tfoot td:eq(1)").text(fmt(tG));
            $("#tblRevenue tfoot td:eq(2)").text('-' + fmt(tD));
            $("#tblRevenue tfoot td:eq(3)").text('-' + fmt(tR));
            $("#tblRevenue tfoot td:eq(4)").text(fmt(tN));
            $("#lblNetCollection").text('Rs. ' + fmt(tN));
            var eff = tG > 0 ? ((tN / tG) * 100).toFixed(1) : '0.0';
            $("#lblCollectionEff").text(eff + '%');
        }

        /* ─── BILLING TABLE ─── */
        function renderBillingTable(data) {
            var html = "", tR = 0, tN = 0, tC = 0, tA = 0;
            data.forEach(function (d) {
                html += '<tr><td>' + d.department + '</td><td>' + fmt(d.registeredPatient) + '</td><td style="color:#059669;font-weight:800;">' + fmt(d.newPatient) + '</td><td>' + fmt(d.cardFee) + '</td><td>' + fmt(d.totalAmount) + '</td></tr>';
                tR += d.registeredPatient; tN += d.newPatient; tC += d.cardFee; tA += d.totalAmount;
            });
            $("#tblBilling tbody").html(html);
            $("#tblBilling tfoot td:eq(0)").text('Total');
            $("#tblBilling tfoot td:eq(1)").text(fmt(tR));
            $("#tblBilling tfoot td:eq(2)").text(fmt(tN));
            $("#tblBilling tfoot td:eq(3)").text(fmt(tC));
            $("#tblBilling tfoot td:eq(4)").text(fmt(tA));
            $("#lblTotalVisitedSum").text(fmt(tR + tN));
            $("#lblGrandCollection").text(fmt(tA));
        }

        /* ─── INVESTIGATION TABLE ─── */
        function renderInvestigationTable(data) {
            var html = "", tO = 0, tP = 0, tA = 0;
            data.forEach(function (d) {
                html += '<tr><td>' + d.departmentName + '</td><td>' + fmt(d.ordered) + '</td><td>' + fmt(d.performed) + '</td><td>' + fmt(d.amount) + '</td></tr>';
                tO += d.ordered; tP += d.performed; tA += d.amount;
            });
            $("#tblInvestigation tbody").html(html);
            $("#tblInvestigation tfoot td:eq(0)").text('Total');
            $("#tblInvestigation tfoot td:eq(1)").text(fmt(tO));
            $("#tblInvestigation tfoot td:eq(2)").text(fmt(tP));
            $("#tblInvestigation tfoot td:eq(3)").text(fmt(tA));
        }

        /* ─── DEPT TILES ─── */
        function renderDeptTiles(data) {
            var html = "";
            data.forEach(function (d) {
                var arrow = d.isUp ? '&#9650;' : '&#9660;';
                var bgCls = d.isUp ? 'normal' : 'caution';
                html += '<div class="kpi-card" style="border-left-color:' + (d.isUp ? '#059669' : '#d97706') + ';"><div class="kpi-label">' + d.name + '</div><div class="kpi-value" style="font-size:22px;">' + fmt(d.count) + '</div><div class="kpi-status ' + bgCls + '">' + arrow + ' ' + (d.isUp ? '+' : '-') + d.change + '% <span class="vs-text">vs Prev</span></div></div>';
            });
            $("#deptTiles").html(html);
        }

        function applyFilters() {
            $("#pageLoader").removeClass("hidden");
            loadAllData();
        }

        $(window).resize(function () {
            Object.keys(chartInstances).forEach(function (k) {
                if (chartInstances[k]) chartInstances[k].resize();
            });
        });
    </script>

    <style type="text/css">
        *, *::before, *::after { box-sizing: border-box; }
        .admin-dashboard { padding: 20px; background: #f8fafc; min-height: 100vh; max-width: 100%; overflow-x: hidden; }

        .filter-bar {
            display: flex; align-items: center; gap: 16px; flex-wrap: wrap; margin-bottom: 24px;
            background: #fff; border-radius: 12px; padding: 16px 20px;
            border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.04);
            position: sticky; top: 0; z-index: 50;
        }
        .filter-bar .filter-group { display: flex; flex-direction: column; gap: 4px; }
        .filter-bar .filter-group label {
            font-size: 11px; font-weight: 700; color: #64748b;
            text-transform: uppercase; letter-spacing: 0.5px; margin: 0;
        }
        .filter-bar .filter-group input, .filter-bar .filter-group select {
            font-size: 13px; padding: 6px 10px; border: 1px solid #e2e8f0;
            border-radius: 6px; background: #fff; width: 170px;
        }
        .filter-bar .filter-group input:focus, .filter-bar .filter-group select:focus {
            border-color: #1a4332; outline: none; box-shadow: 0 0 0 2px rgba(26,67,50,0.15);
        }
        .select2-container--default .select2-selection--single {
            height: 36px; border: 1px solid #e2e8f0 !important; border-radius: 6px !important;
        }
        .select2-container--default .select2-selection--single .select2-selection__rendered {
            line-height: 36px; font-size: 13px;
        }

        .kpi-strip {
            display: grid; grid-template-columns: repeat(6, 1fr); gap: 14px; margin-bottom: 28px;
        }
        @media (max-width: 1400px) { .kpi-strip { grid-template-columns: repeat(3, 1fr); } }
        @media (max-width: 900px) { .kpi-strip { grid-template-columns: repeat(2, 1fr); } }

        .kpi-card {
            background: #fff; border-radius: 12px; padding: 20px 18px;
            border: 1px solid #e2e8f0; border-left: 4px solid #1a4332;
            transition: box-shadow 0.25s ease, transform 0.25s ease;
        }
        .kpi-card:hover { box-shadow: 0 8px 25px rgba(0,0,0,0.08); transform: translateY(-2px); }
        .kpi-card .kpi-label {
            font-size: 10px; font-weight: 700; color: #94a3b8;
            text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 6px;
        }
        .kpi-card .kpi-value { font-size: 26px; font-weight: 800; color: #1a4332; line-height: 1.2; }
        .kpi-card .kpi-subtitle { font-size: 10px; color: #94a3b8; font-weight: 500; margin: 2px 0 8px 0; }
        .kpi-card .kpi-status {
            display: inline-flex; align-items: center; gap: 4px;
            font-size: 10px; font-weight: 700; padding: 2px 10px; border-radius: 12px;
        }
        .kpi-card .kpi-status.normal { background: #ecfdf5; color: #059669; }
        .kpi-card .kpi-status.caution { background: #fef3c7; color: #d97706; }
        .kpi-card .kpi-status .vs-text { font-weight: 400; color: #94a3b8; }

        .section-header {
            display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px;
        }
        .section-header h2 {
            font-size: 14px; font-weight: 800; color: #1e293b;
            text-transform: uppercase; letter-spacing: 0.5px; margin: 0;
        }
        .cohort-badge {
            font-size: 9px; font-weight: 800; color: #1a4332;
            background: rgba(26,67,50,0.06); padding: 4px 14px; border-radius: 20px;
            border: 1px solid rgba(26,67,50,0.12); text-transform: uppercase; letter-spacing: 1px;
        }

        .grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 24px; min-width: 0; }
        .grid-4-8 { display: grid; grid-template-columns: 4fr 8fr; gap: 16px; margin-bottom: 24px; min-width: 0; }
        .grid-2x2 { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; min-width: 0; }
        @media (max-width: 1200px) { .grid-2, .grid-4-8, .grid-2x2 { grid-template-columns: 1fr; } }
        .kpi-strip, .dept-tiles { max-width: 100%; }
        .grid-2 > *, .grid-4-8 > *, .grid-2x2 > *, .kpi-strip > *, .dept-tiles > * { min-width: 0; max-width: 100%; }

        .bento-item {
            background: #fff; border-radius: 12px; border: 1px solid #e2e8f0;
            min-width: 0; transition: box-shadow 0.25s ease;
        }
        .bento-item:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.05); }

        .bento-header {
            padding: 14px 18px 10px 18px; border-bottom: 1px solid #f1f5f9;
            display: flex; align-items: center; justify-content: space-between;
        }
        .bento-header .bh-title { font-size: 12px; font-weight: 800; color: #1e293b; text-transform: uppercase; letter-spacing: 0.3px; }
        .bento-header .bh-sub { font-size: 10px; color: #94a3b8; font-weight: 500; margin-top: 2px; }

        .bento-body { padding: 14px 18px 18px 18px; }

        .chart-container { width: 100%; }

        .table-wrap { overflow-x: auto; max-width: 100%; }
        .table-wrap table { width: 100%; border-collapse: collapse; font-size: 12px; }
        .table-wrap th {
            background: #1a4332; color: #fff; white-space: nowrap;
            font-size: 10px; font-weight: 800; text-transform: uppercase; letter-spacing: 0.5px;
            padding: 10px 12px; text-align: left; border-right: 1px solid rgba(255,255,255,0.12);
        }
        .table-wrap th:last-child { border-right: none; text-align: right; }
        .table-wrap td {
            padding: 8px 12px; border-bottom: 1px solid #f1f5f9; white-space: nowrap;
            font-weight: 600; color: #475569;
        }
        .table-wrap td:last-child { text-align: right; }
        .table-wrap th:first-child, .table-wrap td:first-child { min-width: 140px; }
        .table-wrap th:nth-child(2), .table-wrap td:nth-child(2),
        .table-wrap th:nth-child(3), .table-wrap td:nth-child(3),
        .table-wrap th:nth-child(4), .table-wrap td:nth-child(4) { text-align: center; }
        .table-wrap th:last-child, .table-wrap td:last-child { text-align: right; }
        .table-wrap th {
            background: #1a4332; color: #fff; font-size: 10px; font-weight: 800;
            text-transform: uppercase; letter-spacing: 0.5px; padding: 10px 12px;
            text-align: left; border-right: 1px solid rgba(255,255,255,0.12);
        }
        .table-wrap th:last-child { border-right: none; text-align: right; }
        .table-wrap td {
            padding: 8px 12px; border-bottom: 1px solid #f1f5f9;
            font-weight: 600; color: #475569;
        }
        .table-wrap td:last-child { text-align: right; }
        .table-wrap tr:hover td { background: #f8fafc; }
        .table-wrap tfoot td {
            background: #f1f5f9; font-weight: 900; color: #1e293b;
            border-top: 2px solid #e2e8f0; padding: 10px 12px;
        }
        .table-wrap .dept-badge {
            display: inline-flex; align-items: center; gap: 6px;
        }
        .table-wrap .dept-badge .avatar {
            width: 28px; height: 28px; border-radius: 50%;
            background: #d1fae5; color: #1a4332;
            display: flex; align-items: center; justify-content: center;
            font-size: 10px; font-weight: 900;
        }
        .table-wrap .growth-up { color: #059669; }
        .table-wrap .growth-down { color: #dc2626; }

        .summary-strip {
            display: flex; gap: 12px; margin-top: 12px;
        }
        .summary-strip .sum-box {
            flex: 1; padding: 12px 16px; border-radius: 10px;
            text-align: center;
        }
        .summary-strip .sum-box .sum-label {
            font-size: 9px; font-weight: 800; color: #94a3b8;
            text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 4px;
        }
        .summary-strip .sum-box .sum-value { font-size: 16px; font-weight: 900; }
        .summary-strip .sum-box.light { background: #f8fafc; border: 1px solid #e2e8f0; }
        .summary-strip .sum-box.dark { background: #1a4332; border: 1px solid #1a4332; }
        .summary-strip .sum-box.dark .sum-label { color: rgba(255,255,255,0.5); }
        .summary-strip .sum-box.dark .sum-value { color: #fff; }
        .summary-strip .sum-box.dark .sum-sub { color: #10b981; font-size: 11px; font-weight: 700; }
        .dept-tiles {
            display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px; margin-top: 12px;
        }
        @media (max-width: 1400px) { .dept-tiles { grid-template-columns: repeat(3, 1fr); } }
        @media (max-width: 1100px) { .dept-tiles { grid-template-columns: repeat(2, 1fr); } }
        .dept-tiles .kpi-card { min-width: 0; }

        .empty-state {
            text-align: center; padding: 40px 20px; color: #94a3b8;
            font-size: 12px; font-weight: 700; text-transform: uppercase;
            letter-spacing: 1px; font-style: italic;
        }
        #pageLoader {
            position: fixed; inset: 0; z-index: 99999;
            background: rgba(248, 250, 252, 0.4);
            display: flex;
            align-items: center; justify-content: center;
            transition: opacity 0.4s;
            backdrop-filter: blur(2px);
            -webkit-backdrop-filter: blur(2px);
        }
        #pageLoader.hidden { opacity: 0; pointer-events: none; }
        #pageLoader .spinner {
            width: 40px; height: 40px;
            border: 4px solid #e2e8f0; border-top-color: #1a4332;
            border-radius: 50%; animation: spin 0.7s linear infinite;
        }

        .card-loading { opacity: 0.35; pointer-events: none; transition: opacity 0.2s; position: relative; }
        .card-loading::after {
            content: ''; position: absolute; inset: 50% auto auto 50%;
            width: 28px; height: 28px; margin: -14px 0 0 -14px;
            border: 3px solid #e2e8f0; border-top-color: #1a4332;
            border-radius: 50%; animation: spin 0.7s linear infinite; z-index: 10;
        }
        @keyframes spin { to { transform: rotate(360deg); } }

        .btn-primry { background: #1a4332; color: #fff; border: none; }
        .btn-primry:hover { background: #143326; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="admin-dashboard">
        <div id="pageLoader"><div class="spinner"></div></div>

        <!-- === FILTER BAR (Sticky) === -->
        <div class="filter-bar">
            <div class="filter-group">
                <label>Start Date</label>
                <input type="text" id="txtStartDate" class="form-control datepicker" placeholder="DD/MM/YYYY" readonly />
            </div>
            <div class="filter-group">
                <label>End Date</label>
                <input type="text" id="txtEndDate" class="form-control datepicker" placeholder="DD/MM/YYYY" readonly />
            </div>
            <div class="filter-group" style="min-width:200px;">
                <label>Department</label>
                <select id="ddlDepartment"><option value="0">All Departments</option></select>
            </div>
            <div class="filter-group" style="min-width:200px;">
                <label>Doctor</label>
                <select id="ddlDoctor"><option value="0">All Doctors</option></select>
            </div>
            <div class="filter-group" style="align-self:flex-end;">
                <button type="button" id="btnApplyFilters" class="btn btn-primry" style="padding:7px 24px;font-size:13px;font-weight:700;">Apply</button>
            </div>
        </div>

        <!-- === KPI OVERVIEW === -->
        <div class="section-header">
            <h2>System-Wide Performance Summary</h2>
            <span class="cohort-badge" id="lblCohort">Cohort: All Departments</span>
        </div>
        <div class="kpi-strip">
            <div class="kpi-card"><div class="kpi-label">Total Visited Patients</div><div class="kpi-value" id="lblTotalVisited">—</div><div class="kpi-subtitle">Aggregated throughput for selected filters</div><div class="kpi-status normal"><span>&#9650;</span> <span class="vs-text">vs Yesterday</span></div></div>
            <div class="kpi-card"><div class="kpi-label">Walk-In Patient Volume</div><div class="kpi-value" id="lblWalkInVolume">—</div><div class="kpi-subtitle">Filter Clinic &amp; FRU</div><div class="kpi-status normal"><span>&#9650;</span> <span class="vs-text">vs Yesterday</span></div></div>
            <div class="kpi-card"><div class="kpi-label">Total Appointments</div><div class="kpi-value" id="lblTotalAppointments">—</div><div class="kpi-subtitle">Consultant bookings</div><div class="kpi-status normal"><span>&#9650;</span> <span class="vs-text">vs Yesterday</span></div></div>
            <div class="kpi-card"><div class="kpi-label">Consultant Checkups</div><div class="kpi-value" id="lblConsultantCheckups">—</div><div class="kpi-subtitle">Specialist throughput</div><div class="kpi-status normal"><span>&#9650;</span> <span class="vs-text">vs Yesterday</span></div></div>
            <div class="kpi-card" style="border-left-color:#d97706;"><div class="kpi-label">Cancellation Rate</div><div class="kpi-value" id="lblCancellationRate">—</div><div class="kpi-subtitle">Missed specialist slots</div><div class="kpi-status caution"><span>&#9650;</span> <span class="vs-text">vs Yesterday</span></div></div>
            <div class="kpi-card"><div class="kpi-label">Revenue Yield (Est)</div><div class="kpi-value" id="lblRevenueYield">—</div><div class="kpi-subtitle">Estimated collection</div><div class="kpi-status normal"><span>&#9650;</span> <span class="vs-text">vs Yesterday</span></div></div>
        </div>

        <!-- === SPECIALIST CLINIC PRODUCTIVITY === -->
        <div class="grid-4-8">
            <div class="bento-item">
                <div class="bento-header"><div><div class="bh-title">Appointment Funnel</div><div class="bh-sub">SLOT UTILIZATION &amp; LIFECYCLE</div></div></div>
                <div class="bento-body">
                    <div id="chartAppointmentDonut" class="chart-container" style="height:250px;"></div>
                    <div style="display:flex;justify-content:center;gap:40px;margin-top:12px;">
                        <div style="text-align:center;"><span id="lblFunnelVisited" style="font-size:22px;font-weight:900;color:#1e293b;">0</span><br><span style="display:inline-flex;align-items:center;gap:4px;"><span style="width:10px;height:10px;border-radius:50%;background:#1a4332;display:inline-block;"></span><span style="font-size:9px;font-weight:800;color:#64748b;text-transform:uppercase;letter-spacing:1px;">Visited</span></span></div>
                        <div style="text-align:center;"><span id="lblFunnelNoShow" style="font-size:22px;font-weight:900;color:#1e293b;">0</span><br><span style="display:inline-flex;align-items:center;gap:4px;"><span style="width:10px;height:10px;border-radius:50%;background:#f59e0b;display:inline-block;"></span><span style="font-size:9px;font-weight:800;color:#64748b;text-transform:uppercase;letter-spacing:1px;">No-Show</span></span></div>
                        <div style="text-align:center;"><span id="lblFunnelCancelled" style="font-size:22px;font-weight:900;color:#1e293b;">0</span><br><span style="display:inline-flex;align-items:center;gap:4px;"><span style="width:10px;height:10px;border-radius:50%;background:#ef4444;display:inline-block;"></span><span style="font-size:9px;font-weight:800;color:#64748b;text-transform:uppercase;letter-spacing:1px;">Cancelled</span></span></div>
                    </div>
                </div>
            </div>
            <div class="bento-item">
                <div class="bento-header"><div><div class="bh-title">Specialist Clinic Productivity</div><div class="bh-sub">APPOINTMENT-BASED CONSULTANT METRICS</div></div></div>
                <div class="bento-body" style="padding:0;">
                    <div class="table-wrap" style="max-height:380px;overflow-y:auto;">
                        <table id="tblSpecialist">
                            <thead><tr><th>Consultant / Staff</th><th>Appointments</th><th>Patients Seen</th><th>Avg/Day</th><th>Performance</th></tr></thead>
                            <tbody></tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- === WALK-IN CLINIC PRODUCTIVITY === -->
        <div class="bento-item" style="margin-bottom:24px;">
            <div class="bento-header"><div><div class="bh-title">General &amp; Support Clinic Tracking</div><div class="bh-sub">WALK-IN THROUGHPUT (FILTER CLINIC &amp; FRU)</div></div></div>
            <div class="bento-body" style="padding:0;">
                <div class="table-wrap" style="max-height:320px;overflow-y:auto;">
                        <table id="tblWalkIn">
                            <thead><tr><th>Consultant / Staff</th><th>Patients Seen</th><th>Avg/Day</th><th>Performance</th></tr></thead>
                            <tbody></tbody>
                        </table>
                </div>
            </div>
        </div>

        <!-- === REVENUE SUMMARIES + PATIENT BILLING === -->
        <div class="grid-2">
            <div class="bento-item">
                <div class="bento-header"><div><div class="bh-title">Revenue Stream Breakdown</div><div class="bh-sub">CATEGORY-WISE FINANCIALS</div></div></div>
                <div class="bento-body" style="padding:0;">
                    <div class="table-wrap">
                        <table id="tblRevenue">
                            <thead><tr><th>Category</th><th>Gross (Rs.)</th><th style="color:#fcd34d;">Discount</th><th style="color:#fca5a5;">Refund</th><th>Net Collection</th></tr></thead>
                            <tbody></tbody>
                            <tfoot><tr><td>GRAND TOTAL</td><td>0</td><td style="color:#b45309;">0</td><td style="color:#b91c1c;">0</td><td>0</td></tr></tfoot>
                        </table>
                    </div>
                    <div class="bento-body">
                        <div style="background:#1a4332;border-radius:10px;padding:14px 18px;display:flex;justify-content:space-between;align-items:center;">
                            <div><span style="font-size:9px;font-weight:800;color:rgba(255,255,255,0.5);text-transform:uppercase;letter-spacing:1px;display:block;">Net Collection Summary</span><span style="font-size:20px;font-weight:900;color:#fff;" id="lblNetCollection">Rs. 0</span></div>
                            <div style="text-align:right;"><span style="font-size:8px;font-weight:900;color:#10b981;text-transform:uppercase;letter-spacing:1px;display:block;">Collection Efficiency</span><span style="font-size:12px;font-weight:700;color:#fff;" id="lblCollectionEff">0%</span></div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="bento-item">
                <div class="bento-header"><div><div class="bh-title">Patient Billing Matrix</div><div class="bh-sub">REGISTRATION VS NET REVENUE</div></div></div>
                <div class="bento-body" style="padding:0;">
                    <div class="table-wrap">
                        <table id="tblBilling">
                            <thead><tr><th>Dept</th><th>Registered</th><th style="color:#059669;">New</th><th>Card Fee</th><th>Total (Rs.)</th></tr></thead>
                            <tbody></tbody>
                            <tfoot><tr><td>Total</td><td>0</td><td style="color:#059669;">0</td><td>0</td><td>0</td></tr></tfoot>
                        </table>
                    </div>
                    <div class="bento-body">
                        <div class="summary-strip">
                            <div class="sum-box light"><div class="sum-label">Total Visited</div><div class="sum-value" id="lblTotalVisitedSum">0</div><span style="font-size:9px;font-weight:700;color:#94a3b8;">PATIENTS</span></div>
                            <div class="sum-box dark"><div class="sum-label">Grand Total Collection</div><div><span class="sum-sub">Rs.</span> <span class="sum-value" id="lblGrandCollection">0</span></div></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- === RETENTION & LOYALTY MATRIX + INVESTIGATION === -->
        <div class="grid-2">
            <div class="bento-item">
                <div class="bento-header"><div><div class="bh-title">Retention &amp; Loyalty Matrix</div><div class="bh-sub">NEW VS RETURNING (7-DAY)</div></div></div>
                <div class="bento-body">
                    <div id="chartNewVsFollowUp" class="chart-container" style="height:320px;"></div>
                </div>
            </div>
            <div class="bento-item">
                <div class="bento-header"><div><div class="bh-title">Investigation Summary</div><div class="bh-sub">DIAGNOSTIC ORDER EFFICIENCY</div></div></div>
                <div class="bento-body" style="padding:0;">
                    <div class="table-wrap">
                        <table id="tblInvestigation">
                            <thead><tr><th>Department</th><th>Ordered</th><th>Performed</th><th>Net Amount (Rs.)</th></tr></thead>
                            <tbody></tbody>
                            <tfoot><tr><td>Total</td><td>0</td><td>0</td><td>0</td></tr></tfoot>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- === DEMOGRAPHICS & WAIT TIMES === -->
        <div class="grid-2">
            <div class="bento-item">
                <div class="bento-header"><div><div class="bh-title">Consultation Time Benchmarks</div><div class="bh-sub">DISTRIBUTION ACROSS POPULATION</div></div></div>
                <div class="bento-body">
                    <div id="chartConsultDistribution" class="chart-container" style="height:280px;"></div>
                        <div style="margin-top:10px;background:linear-gradient(135deg,#1a4332,#2d5a47);border-radius:10px;padding:14px 18px;text-align:center;">
                            <div style="font-size:9px;font-weight:800;color:rgba(255,255,255,0.5);text-transform:uppercase;letter-spacing:1px;margin-bottom:4px;">Most common: <span id="lblMostCommonRange">0</span> minutes</div>
                            <div style="font-size:14px;font-weight:700;color:#fff;">(<span id="lblMostCommonCount">0</span> patients)</div>
                        </div>
                </div>
            </div>
            <div class="bento-item">
                <div class="bento-header"><div><div class="bh-title">Gender-Wise Dynamics</div><div class="bh-sub">PATIENT VOLUME BY DEMOGRAPHIC</div></div></div>
                <div class="bento-body">
                    <div id="chartGender" class="chart-container" style="height:330px;"></div>
                </div>
            </div>
        </div>

        <!-- === DETAILED OPERATIONS === -->
        <div class="grid-2" style="margin-bottom:16px;">
            <div class="bento-item">
                <div class="bento-header"><div><div class="bh-title">Age Group Matrix</div><div class="bh-sub">SEGMENTATION BY LIFE STAGE</div></div></div>
                <div class="bento-body">
                    <div id="chartAgeGroup" class="chart-container" style="height:300px;"></div>
                </div>
            </div>
            <div class="bento-item">
                <div class="bento-header"><div><div class="bh-title">OPD Hourly Flux</div><div class="bh-sub">TRAFFIC DENSITY PATTERNS</div></div></div>
                <div class="bento-body">
                    <div id="chartOPDTrends" class="chart-container" style="height:300px;"></div>
                </div>
            </div>
        </div>

        <div class="grid-2" style="margin-bottom:24px;">
            <div class="bento-item">
                <div class="bento-header"><div><div class="bh-title">Productivity Ranking (Private)</div><div class="bh-sub">TOP PERFORMING SPECIALISTS</div></div></div>
                <div class="bento-body">
                    <div id="chartConsultantBar" class="chart-container" style="height:320px;"></div>
                </div>
            </div>
            <div class="bento-item">
                <div class="bento-header"><div><div class="bh-title">Productivity Ranking (General)</div><div class="bh-sub">TOP PERFORMING WALK-IN STAFF</div></div></div>
                <div class="bento-body">
                    <div id="chartWalkInBar" class="chart-container" style="height:320px;"></div>
                </div>
            </div>
        </div>

        <!-- === DEPARTMENTAL OVERVIEWS === -->
        <div style="margin-top:8px;">
            <div class="section-header">
                <h2>Departmental Overviews</h2>
                <button type="button" class="cohort-badge" style="cursor:pointer;background:rgba(26,67,50,0.08);border-color:rgba(26,67,50,0.15);" onclick="$('#ddlDepartment').val('0').trigger('change');applyFilters();">Show All Units</button>
            </div>
            <div class="dept-tiles" id="deptTiles"></div>
        </div>

    </div>
</asp:Content>
