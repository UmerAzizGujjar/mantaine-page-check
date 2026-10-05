<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="PR_PO_IGP_Dashboard.aspx.cs" Inherits="PMS.Modules.Dashboards.PR_PO_IGP_Dashboard" %>
<%@ Assembly Name="System.Data.Linq, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="../../wwwroot/lib/echarts/echarts.min.js" type="text/javascript"></script>
    <style type="text/css">

        .hero {
            display: flex;
            align-items: center;
            gap: 18px;
            background: linear-gradient(135deg, #e67e22 0%, #d35400 60%, #c0392b 100%);
            border-radius: 16px;
            padding: 22px 26px;
            color: #fff;
            box-shadow: 0 8px 24px rgba(211, 84, 0, 0.25);
            margin-bottom: 18px;
            position: relative;
            overflow: hidden;
        }

        .hero::after {
            position: absolute;
            right: -40px;
            top: -70px;
            width: 230px;
            height: 230px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.08);
        }

        .hero-icon {
            width: 58px;
            height: 58px;
            border-radius: 14px;
            background: rgba(255, 255, 255, 0.18);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
            flex: 0 0 auto;
        }

        .hero h1 {
            margin: 0;
            font-size: 1.55rem;
            font-weight: 700;
            letter-spacing: 0.2px;
        }

        .hero p {
            margin: 4px 0 0;
            opacity: 0.92;
            font-size: 0.88rem;
        }

        .filter-bar {
            display: flex;
            gap: 15px;
            align-items: end;
            margin-bottom: 18px;
            flex-wrap: wrap;
            background: #fff;
            padding: 15px 18px;
            border-radius: 14px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
        }

        .filter-bar label {
            font-weight: 600;
            font-size: 0.8rem;
            color: #5a6472;
            text-transform: uppercase;
            letter-spacing: 0.3px;
            margin-bottom: 6px;
            display: block;
        }

        .filter-bar input[type=text] {
            width: 100%;
            max-width: 200px;
            padding: 8px 12px;
            border: 1px solid #dde1e6;
            border-radius: 8px;
            font-size: 0.9rem;
            transition: border-color 0.15s, box-shadow 0.15s;
        }

        .filter-bar input[type=text]:focus {
            outline: none;
            border-color: #e67e22;
            box-shadow: 0 0 0 3px rgba(230, 126, 34, 0.15);
        }

        .kpi-grid {
            display: -ms-flexbox;
            display: flex;
            -ms-flex-wrap: wrap;
            flex-wrap: wrap;
            margin-bottom: 0;
        }

        .kpi-grid > div {
            -ms-flex: 1 1 220px;
            flex: 1 1 220px;
            min-width: 195px;
            margin: 0 14px 14px 0;
            box-sizing: border-box;
        }

        /* ---- pipeline (gradient) cards ---- */
        .grad-card {
            display: -ms-flexbox;
            display: flex;
            -ms-flex-align: center;
            align-items: center;
            gap: 14px;
            border-radius: 14px;
            padding: 18px;
            color: #fff;
            cursor: pointer;
            min-height: 96px;
            background: #6f42c1;
            box-shadow: 0 6px 16px rgba(0, 0, 0, 0.12);
            transition: transform 0.15s, box-shadow 0.15s;
        }

        .grad-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 22px rgba(0, 0, 0, 0.18);
        }

        .grad-card .card-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            background: rgba(255, 255, 255, 0.22);
            display: -ms-flexbox;
            display: flex;
            -ms-flex-align: center;
            align-items: center;
            -ms-flex-pack: center;
            justify-content: center;
            font-size: 20px;
            color: #fff;
            -ms-flex: 0 0 auto;
            flex: 0 0 auto;
        }

        .grad-card .card-text {
            min-width: 0;
        }

        .grad-card .label,
        .status-card .label {
            display: block;
            font-size: 0.72rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 0;
            margin: 0 0 2px;
            border-radius: 0;
            background: transparent !important;
            background-color: transparent !important;
            border: none;
            line-height: 1.2;
            width: auto;
            height: auto;
        }

        .grad-card .label {
            color: rgba(255, 255, 255, 0.85);
        }

        .grad-card .value {
            font-size: 2rem;
            font-weight: 800;
            line-height: 1.1;
            color: #fff;
        }

        .grad-pr { background: #6f42c1; background: linear-gradient(135deg, #6f42c1, #9b59b6); }
        .grad-po { background: #007bff; background: linear-gradient(135deg, #007bff, #4b7bec); }
        .grad-igp { background: #00b894; background: linear-gradient(135deg, #00b894, #00cec9); }
        .grad-direct { background: #636e72; background: linear-gradient(135deg, #636e72, #2d3436); }

        /* ---- status cards ---- */
        .status-card {
            background: #fff;
            border-radius: 14px;
            padding: 16px 18px 14px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.07);
            cursor: pointer;
            border-left: 5px solid #ced4da;
            transition: transform 0.15s, box-shadow 0.15s;
        }

        .status-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
        }

        .status-card.active-filter {
            outline: 2px solid #007bff;
            outline-offset: 1px;
        }

        .status-top {
            display: -ms-flexbox;
            display: flex;
            -ms-flex-align: center;
            align-items: center;
            gap: 12px;
        }

        .status-icon {
            width: 42px;
            height: 42px;
            border-radius: 11px;
            display: -ms-flexbox;
            display: flex;
            -ms-flex-align: center;
            align-items: center;
            -ms-flex-pack: center;
            justify-content: center;
            font-size: 17px;
            background: rgba(108, 117, 125, 0.12);
            color: #6c757d;
            -ms-flex: 0 0 auto;
            flex: 0 0 auto;
        }

        .status-card .label {
            color: #8a94a6;
        }

        .status-card .value {
            font-size: 1.7rem;
            font-weight: 800;
            color: #343a40;
            line-height: 1.15;
        }

        .status-card .bar {
            height: 5px;
            border-radius: 3px;
            background: #eef0f3;
            margin-top: 10px;
            overflow: hidden;
        }

        .status-card .bar span {
            display: block;
            height: 100%;
            border-radius: 3px;
            width: 0;
            transition: width 0.6s ease;
        }

        .sc-blue { border-left-color: #007bff; }
        .sc-blue .status-icon { background: rgba(0, 123, 255, 0.12); color: #007bff; }
        .sc-blue .bar span { background: #007bff; }
        .sc-grey { border-left-color: #adb5bd; }
        .sc-grey .status-icon { background: rgba(173, 181, 189, 0.18); color: #6c757d; }
        .sc-grey .value { color: #6c757d; }
        .sc-grey .bar span { background: #adb5bd; }
        .sc-red { border-left-color: #dc3545; }
        .sc-red .status-icon { background: rgba(220, 53, 69, 0.12); color: #dc3545; }
        .sc-red .value { color: #dc3545; }
        .sc-red .bar span { background: #dc3545; }
        .sc-amber { border-left-color: #f39c12; }
        .sc-amber .status-icon { background: rgba(243, 156, 18, 0.15); color: #e67e22; }
        .sc-amber .value { color: #e67e22; }
        .sc-amber .bar span { background: #f39c12; }
        .sc-green { border-left-color: #28a745; }
        .sc-green .status-icon { background: rgba(40, 167, 69, 0.12); color: #28a745; }
        .sc-green .value { color: #28a745; }
        .sc-green .bar span { background: #28a745; }

        .progress-strip {
            background: #fff;
            border-radius: 14px;
            padding: 14px 18px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
            margin-bottom: 14px;
        }

        .progress-head {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 0.82rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.4px;
            color: #5a6472;
            margin-bottom: 8px;
        }

        .progress-head b { color: #28a745; font-size: 1rem; }

        .progress-track {
            height: 12px;
            border-radius: 6px;
            background: #eef0f3;
            overflow: hidden;
        }

        .progress-fill {
            height: 100%;
            width: 0;
            border-radius: 6px;
            background: linear-gradient(90deg, #2ecc71, #28a745);
            transition: width 0.7s ease;
        }

        .stage-badge {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 12px;
            font-size: 0.78rem;
            font-weight: 600;
            color: #fff;
            white-space: nowrap;
        }

        .stage-red { background: #dc3545; }
        .stage-green { background: #28a745; }
        .stage-amber { background: #f39c12; }
        .stage-grey { background: #adb5bd; }

        .table-card {
            background: #fff;
            border-radius: 14px;
            padding: 18px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
        }

        #tblPipeline thead th {
            background: #f4f6f8;
            color: #5a6472;
            font-size: 0.78rem;
            text-transform: uppercase;
            letter-spacing: 0.4px;
            white-space: nowrap;
            vertical-align: middle;
        }

        #tblPipeline tbody tr:hover {
            background: #fff8ef;
        }

        #tblPipeline_wrapper .dataTables_filter input {
            border: 1px solid #dde1e6;
            border-radius: 8px;
            padding: 5px 10px;
        }

        #pipelineLoader {
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(255, 255, 255, 0.65);
            z-index: 9999;
            display: none;
        }

        #pipelineLoader .spinner {
            position: absolute;
            top: 45%; left: 50%;
            width: 46px; height: 46px;
            margin: -23px 0 0 -23px;
            border: 5px solid #f3f3f3;
            border-top: 5px solid #e67e22;
            border-radius: 50%;
            animation: pipeline-spin 0.8s linear infinite;
        }

        #pipelineLoader .loader-text {
            position: absolute;
            top: 50%; left: 0; right: 0;
            text-align: center;
            color: #d35400;
            font-weight: 600;
            font-size: 0.9rem;
        }

        @keyframes pipeline-spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .chart-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 14px;
            margin-bottom: 14px;
        }

        .chart-card {
            background: #fff;
            border-radius: 14px;
            padding: 16px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
        }

        .chart-card h3 {
            font-size: 0.85rem;
            font-weight: 700;
            color: #5a6472;
            text-transform: uppercase;
            letter-spacing: 0.4px;
            margin: 0 0 6px;
        }

        .chart-box {
            width: 100%;
            height: 300px;
        }

        @media (max-width: 900px) {
            .chart-grid { grid-template-columns: 1fr; }
        }

        @media (max-width: 768px) {
            .filter-bar { flex-direction: column; }
            .filter-bar > div { width: 100%; }
            .filter-bar input[type=text] { max-width: 100%; }
            .hero { flex-direction: column; text-align: center; }
        }
    </style>

    <script type="text/javascript">
        var dtPipeline = null;
        var chartStage = null, chartMonth = null, chartItems = null;

        $(document).ready(function () {
            $("#txtsdate, #txtedate").datepicker({
                dateFormat: 'MM d, yy',
                maxDate: 0
            });

            dtPipeline = $('#tblPipeline').DataTable({
                data: [],
                columns: [
                    { data: 'PR_No' },
                    {
                        data: 'PR_DateISO',
                        render: function (data, type, row) {
                            if (type !== 'display') return data;
                            var m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                            var p = (data || '').split('-');
                            if (p.length !== 3) return data;
                            return p[2] + '-' + m[parseInt(p[1], 10) - 1] + '-' + p[0];
                        }
                    },
                    { data: 'PRStatus' },
                    {
                        data: 'Item_Code',
                        render: function (data, type, row) {
                            if (type !== 'display') return data;
                            var desc = row.Item_Desc || '';
                            return data ? ('<b>' + data + '</b>' + (desc ? '<br/><span style="color:#6c757d;font-size:0.85em;">' + desc + '</span>' : '')) : desc;
                        }
                    },
                    { data: 'Qty' },
                    { data: 'PO_Nos' },
                    { data: 'PO_Status' },
                    { data: 'IGP_Nos' },
                    { data: 'IGP_Date' },
                    { data: 'Recv_Qty' },
                    {
                        data: 'Stage',
                        render: function (data, type, row) {
                            if (type !== 'display') return data;
                            var cls = 'stage-red';
                            if (data === 'Completed') cls = 'stage-green';
                            else if (data === 'Partially Received') cls = 'stage-amber';
                            else if (data === 'Pending Approval') cls = 'stage-grey';
                            return '<span class="stage-badge ' + cls + '">' + data + '</span>';
                        }
                    }
                ],
                order: [[1, 'desc']],
                pageLength: 25,
                lengthMenu: [[25, 50, 100, -1], [25, 50, 100, 'All']],
                deferRender: true,
                language: {
                    emptyTable: 'No PR items found for the selected filter.',
                    zeroRecords: 'No matching records found.',
                    search: 'Search:',
                    lengthMenu: 'Show _MENU_ entries'
                }
            });

            LoadPipeline();

            chartStage = echarts.init(document.getElementById('chartStage'));
            chartMonth = echarts.init(document.getElementById('chartMonth'));
            chartItems = echarts.init(document.getElementById('chartItems'));

            window.addEventListener('resize', function () {
                chartStage.resize();
                chartMonth.resize();
                chartItems.resize();
            });
        });

        function search() {
            LoadPipeline($('#txtsdate').val(), $('#txtedate').val());
        }

        function clearFilter() {
            $('#txtsdate, #txtedate').val('');
            $('.status-card').removeClass('active-filter');
            LoadPipeline('', '');
        }

        function filterTable(stage, el) {
            $('.status-card').removeClass('active-filter');
            if (el) $(el).addClass('active-filter');
            if (!stage) {
                dtPipeline.column(10).search('').draw();
            } else {
                dtPipeline.column(10).search('^' + stage + '$', true, false).draw();
            }
        }

        function setKpi(valueId, value, total, barId) {
            $('#' + valueId).text(value || 0);
            if (barId) {
                var pct = total > 0 ? Math.round(((value || 0) / total) * 100) : 0;
                $('#' + barId).css('width', pct + '%');
            }
        }

        function renderCharts(rows, s) {
            chartStage.setOption({
                tooltip: { trigger: 'item' },
                legend: { bottom: 0, icon: 'circle', textStyle: { fontSize: 11 } },
                series: [{
                    type: 'pie',
                    radius: ['46%', '70%'],
                    center: ['50%', '43%'],
                    avoidLabelOverlap: true,
                    itemStyle: { borderRadius: 6, borderColor: '#fff', borderWidth: 2 },
                    label: { formatter: '{b}\n{c}' },
                    data: [
                        { value: s.PendingApproval || 0, name: 'Pending Approval', itemStyle: { color: '#adb5bd' } },
                        { value: s.PendingPO || 0, name: 'Pending PO', itemStyle: { color: '#dc3545' } },
                        { value: s.PendingIGP || 0, name: 'Pending IGP', itemStyle: { color: '#c0392b' } },
                        { value: s.Partial || 0, name: 'Partially Received', itemStyle: { color: '#f39c12' } },
                        { value: s.Completed || 0, name: 'Completed', itemStyle: { color: '#28a745' } }
                    ]
                }]
            }, true);

            var monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            var monthPending = {}, monthCompleted = {};
            rows.forEach(function (r) {
                var parts = (r.PR_Date || '').split('-');
                if (parts.length !== 3) return;
                var mi = monthNames.indexOf(parts[1]);
                if (mi < 0) return;
                var key = parts[2] + '-' + ('0' + (mi + 1)).slice(-2);
                if (r.Stage === 'Completed') monthCompleted[key] = (monthCompleted[key] || 0) + 1;
                else monthPending[key] = (monthPending[key] || 0) + 1;
            });

            var keySet = {};
            Object.keys(monthPending).forEach(function (k) { keySet[k] = 1; });
            Object.keys(monthCompleted).forEach(function (k) { keySet[k] = 1; });
            var mkeys = Object.keys(keySet).sort();

            chartMonth.setOption({
                tooltip: { trigger: 'axis' },
                legend: { bottom: 0, icon: 'circle', textStyle: { fontSize: 11 } },
                grid: { left: 40, right: 15, top: 20, bottom: 45 },
                xAxis: {
                    type: 'category',
                    data: mkeys.map(function (k) {
                        var p = k.split('-');
                        return monthNames[parseInt(p[1], 10) - 1] + ' ' + p[0];
                    }),
                    axisLabel: { fontSize: 11 }
                },
                yAxis: { type: 'value', minInterval: 1 },
                series: [
                    { name: 'Pending', type: 'bar', stack: 'total', data: mkeys.map(function (k) { return monthPending[k] || 0; }), itemStyle: { color: '#dc3545' } },
                    { name: 'Completed', type: 'bar', stack: 'total', data: mkeys.map(function (k) { return monthCompleted[k] || 0; }), itemStyle: { color: '#28a745' } }
                ]
            }, true);

            var itemAgg = {};
            rows.forEach(function (r) {
                if (r.Stage === 'Completed') return;
                var key = r.Item_Code || '(No Code)';
                if (!itemAgg[key]) itemAgg[key] = { name: r.Item_Desc || key, qty: 0 };
                itemAgg[key].qty += (parseFloat(r.Qty) || 0);
            });

            var top = Object.keys(itemAgg)
                .map(function (k) { return { name: itemAgg[k].name, qty: itemAgg[k].qty }; })
                .sort(function (a, b) { return b.qty - a.qty; })
                .slice(0, 10)
                .reverse();

            function shortName(n) {
                return n.length > 30 ? n.substring(0, 29) + 'â€¦' : n;
            }

            chartItems.setOption({
                tooltip: {
                    trigger: 'axis',
                    axisPointer: { type: 'shadow' },
                    formatter: function (params) {
                        var p = params[0];
                        return top[p.dataIndex].name + '<br/>Pending Qty: <b>' + p.value + '</b>';
                    }
                },
                grid: { left: 150, right: 40, top: 15, bottom: 30 },
                xAxis: { type: 'value' },
                yAxis: {
                    type: 'category',
                    data: top.map(function (t) { return shortName(t.name); }),
                    axisLabel: { fontSize: 11 }
                },
                series: [{
                    type: 'bar',
                    data: top.map(function (t) { return t.qty; }),
                    itemStyle: { color: '#e67e22', borderRadius: [0, 6, 6, 0] },
                    barMaxWidth: 22,
                    label: { show: true, position: 'right', fontSize: 11 }
                }]
            }, true);
        }

        function LoadPipeline(sdate, edate) {
            $.ajax({
                type: "POST",
                url: "PR_PO_IGP_Dashboard.aspx/GetPipeline",
                data: JSON.stringify({ sdate: sdate || '', edate: edate || '' }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                beforeSend: function () {
                    $('#pipelineLoader').show();
                },
                success: function (response) {
                    var res = JSON.parse(response.d);

                    if (res.Denied) {
                        $('#pipelineLoader').hide();
                        Swal.fire('Access Denied', 'You do not have permission to view this dashboard.', 'error')
                            .then(function () { window.location = '../../Default.aspx'; });
                        return;
                    }

                    var s = res.Summary;
                    var total = s.TotalItems || 0;

                    $('#kpiTotalPRs').text(s.TotalPRs || 0);
                    $('#kpiTotalPOs').text(s.TotalPOs || 0);
                    $('#kpiTotalIGPs').text(s.TotalIGPs || 0);
                    $('#kpiDirectPOs').text(s.DirectPOs || 0);

                    setKpi('kpiTotalItems', s.TotalItems, total, null);
                    setKpi('kpiPendingApproval', s.PendingApproval, total, 'barPendingApproval');
                    setKpi('kpiPendingPO', s.PendingPO, total, 'barPendingPO');
                    setKpi('kpiPendingIGP', s.PendingIGP, total, 'barPendingIGP');
                    setKpi('kpiPartial', s.Partial, total, 'barPartial');
                    setKpi('kpiCompleted', s.Completed, total, 'barCompleted');

                    var pct = total > 0 ? Math.round(((s.Completed || 0) / total) * 100) : 0;
                    $('#pctComplete').text(pct + '%');
                    $('#progressFill').css('width', pct + '%');

                    dtPipeline.clear().rows.add(res.Rows).draw();
                    renderCharts(res.Rows, s);
                    $('#pipelineLoader').hide();
                },
                error: function () {
                    $('#pipelineLoader').hide();
                    Swal.fire('Error', 'Failed to load PR / PO / IGP pipeline data.', 'error');
                }
            });
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div id="pipelineLoader">
        <div class="spinner"></div>
        <div class="loader-text">Loading pipeline data...</div>
    </div>

    <div class="hero">
        <div class="hero-icon"><i class="fa fa-sitemap"></i></div>
        <div>
            <h1>PR &#8594; PO &#8594; IGP Pipeline</h1>
            <p>Purchase Requisition &#8594; Purchase Order &#8594; Inward Gate Pass &mdash; pending red, completed green</p>
        </div>
    </div>

    <div class="filter-bar">
        <div>
            <label>Start Date (PR Date)</label>
            <input type="text" id="txtsdate" placeholder="All" />
        </div>
        <div>
            <label>End Date (PR Date)</label>
            <input type="text" id="txtedate" placeholder="All" />
        </div>
        <div>
            <input type="button" class="btn btn-primry" value="Search" onclick="search(); return false;" />
            <input type="button" class="btn btn-gray" value="Clear" onclick="clearFilter(); return false;" />
        </div>
    </div>

    <div class="kpi-grid">
        <div class="grad-card grad-pr" onclick="filterTable('', this)">
            <div class="card-icon"><i class="fa fa-file-text-o"></i></div>
            <div class="card-text">
                <div class="label">Total PRs</div>
                <div class="value" id="kpiTotalPRs">0</div>
            </div>
        </div>
        <div class="grad-card grad-po" onclick="filterTable('', this)">
            <div class="card-icon"><i class="fa fa-file-text"></i></div>
            <div class="card-text">
                <div class="label">Total POs</div>
                <div class="value" id="kpiTotalPOs">0</div>
            </div>
        </div>
        <div class="grad-card grad-igp" onclick="filterTable('', this)">
            <div class="card-icon"><i class="fa fa-truck"></i></div>
            <div class="card-text">
                <div class="label">Total IGPs</div>
                <div class="value" id="kpiTotalIGPs">0</div>
            </div>
        </div>
        <div class="grad-card grad-direct" onclick="filterTable('', this)">
            <div class="card-icon"><i class="fa fa-cart-plus"></i></div>
            <div class="card-text">
                <div class="label">Direct POs (No PR)</div>
                <div class="value" id="kpiDirectPOs">0</div>
            </div>
        </div>
    </div>

    <div class="kpi-grid">
        <div class="status-card sc-blue" onclick="filterTable('', this)">
            <div class="status-top">
                <div class="status-icon"><i class="fa fa-list"></i></div>
                <div>
                    <div class="label">Total PR Items</div>
                    <div class="value" id="kpiTotalItems">0</div>
                </div>
            </div>
            <div class="bar"><span></span></div>
        </div>
        <div class="status-card sc-grey" onclick="filterTable('Pending Approval', this)">
            <div class="status-top">
                <div class="status-icon"><i class="fa fa-clock-o"></i></div>
                <div>
                    <div class="label">Pending Approval</div>
                    <div class="value" id="kpiPendingApproval">0</div>
                </div>
            </div>
            <div class="bar"><span id="barPendingApproval"></span></div>
        </div>
        <div class="status-card sc-red" onclick="filterTable('Pending PO', this)">
            <div class="status-top">
                <div class="status-icon"><i class="fa fa-file-text-o"></i></div>
                <div>
                    <div class="label">Pending PO</div>
                    <div class="value" id="kpiPendingPO">0</div>
                </div>
            </div>
            <div class="bar"><span id="barPendingPO"></span></div>
        </div>
        <div class="status-card sc-red" onclick="filterTable('Pending IGP', this)">
            <div class="status-top">
                <div class="status-icon"><i class="fa fa-truck"></i></div>
                <div>
                    <div class="label">Pending IGP</div>
                    <div class="value" id="kpiPendingIGP">0</div>
                </div>
            </div>
            <div class="bar"><span id="barPendingIGP"></span></div>
        </div>
        <div class="status-card sc-amber" onclick="filterTable('Partially Received', this)">
            <div class="status-top">
                <div class="status-icon"><i class="fa fa-cubes"></i></div>
                <div>
                    <div class="label">Partially Received</div>
                    <div class="value" id="kpiPartial">0</div>
                </div>
            </div>
            <div class="bar"><span id="barPartial"></span></div>
        </div>
        <div class="status-card sc-green" onclick="filterTable('Completed', this)">
            <div class="status-top">
                <div class="status-icon"><i class="fa fa-check-circle"></i></div>
                <div>
                    <div class="label">Completed</div>
                    <div class="value" id="kpiCompleted">0</div>
                </div>
            </div>
            <div class="bar"><span id="barCompleted"></span></div>
        </div>
    </div>

    <div class="progress-strip">
        <div class="progress-head">
            <span>Pipeline Completion</span>
            <b id="pctComplete">0%</b>
        </div>
        <div class="progress-track">
            <div class="progress-fill" id="progressFill"></div>
        </div>
    </div>

    <div class="chart-grid">
        <div class="chart-card">
            <h3>Stage Distribution</h3>
            <div id="chartStage" class="chart-box"></div>
        </div>
        <div class="chart-card">
            <h3>Monthly PR Items &mdash; Pending vs Completed</h3>
            <div id="chartMonth" class="chart-box"></div>
        </div>
    </div>

    <div class="chart-card" style="margin-bottom: 14px;">
        <h3>Top 10 Pending Items (by PR Qty)</h3>
        <div id="chartItems" class="chart-box"></div>
    </div>

    <div class="table-card">
        <table id="tblPipeline" class="table table-striped table-bordered" style="width: 100%;">
            <thead>
                <tr>
                    <th>PR No</th>
                    <th>PR Date</th>
                    <th>PR Status</th>
                    <th>Item</th>
                    <th>PR Qty</th>
                    <th>PO No</th>
                    <th>PO Status</th>
                    <th>IGP No</th>
                    <th>IGP Date</th>
                    <th>Received Qty</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody></tbody>
        </table>
    </div>

</asp:Content>
