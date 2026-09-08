<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PatientsTurnOver.aspx.cs" Inherits="PMS.Modules.Dashboards.PatientsTurnOver" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="../../wwwroot/lib/apexcharts/apexchart.js"></script>
    <style type="text/css">
        .pto-card {
            background: #fff;
            border-radius: 14px;
            padding: 1.5rem;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.06);
            margin-top: 1.5rem;
        }
        .pto-title {
            font-size: 1.3rem;
            font-weight: 600;
            color: #212529;
            margin-bottom: 1.25rem;
            display: flex;
            align-items: center;
        }
        .pto-title i { margin-right: .5rem; color: #4361ee; }

        .pto-filter {
            background: #f8f9fa;
            border-radius: 12px;
            padding: 1.25rem;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.04);
            margin-bottom: 1.5rem;
        }
        .pto-filter label { font-weight: 600; font-size: .9rem; color: #495057; margin-bottom: .4rem; }
        .pto-filter .form-control { border-radius: 8px !important; padding: .6rem 1rem; border: 1px solid #dee2e6; }

        .kpi-card {
            border-radius: 14px;
            box-shadow: 0 6px 18px rgba(0, 0, 0, 0.08);
            height: 100%;
            display: flex;
            flex-direction: column;
            background: #fff;
        }
        .kpi-card:hover { transform: translateY(-4px); box-shadow: 0 8px 24px rgba(0,0,0,0.12); transition: all .3s ease; }
        .kpi-header { padding: 1rem 1.25rem; color: #fff; font-weight: 600; font-size: 1rem; display: flex; justify-content: space-between; align-items: center; }
        .kpi-header i { font-size: 1.3rem; opacity: .9; }
        .kpi-body { padding: 1.25rem; text-align: center; flex-grow: 1; display: flex; flex-direction: column; justify-content: center; }
        .kpi-label { font-size: .85rem; color: #6c757d; margin-bottom: .3rem; font-weight: 600; text-transform: uppercase; letter-spacing: .5px; }
        .kpi-value { font-size: 2.5rem; font-weight: 700; color: #212529; line-height: 1.1; }
        .kpi-foot { font-size: .8rem; color: #adb5bd; padding-top: .5rem; border-top: 1px solid #f1f3f5; margin-top: .75rem; }

        .kpi-new .kpi-header    { background: #06d6a0; }
        .kpi-opdnew .kpi-header { background: #4361ee; }
        .kpi-opdrep .kpi-header { background: #7209b7; }
        .kpi-bill .kpi-header   { background: #4cc9f0; }

        .chart-card {
            background: #fff;
            border-radius: 14px;
            padding: 1.5rem;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.06);
            margin-top: 1.5rem;
        }
        .chart-title {
            font-size: 1.15rem;
            font-weight: 600;
            margin-bottom: 1rem;
            color: #212529;
            display: flex; align-items: center;
        }
        .chart-title i { margin-right: .5rem; color: #4361ee; }
    </style>
    <script type="text/javascript">
        $(document).ready(function () {
            var today = new Date();
            var todayStr = pad2(today.getMonth() + 1) + '/' + pad2(today.getDate()) + '/' + today.getFullYear();

            $('#txtFrom, #txtTo').datepicker({
                dateFormat: 'mm/dd/yy',
                changeMonth: true,
                changeYear: true
            }).attr('readonly', 'readonly');

            $('#txtFrom').val(todayStr);
            $('#txtTo').val(todayStr);

            $('#btnShow').on('click', function (e) { e.preventDefault(); loadPatients(); });
            $('#txtFrom, #txtTo').on('keydown', function (e) {
                if (e.key === 'Enter') { e.preventDefault(); loadPatients(); }
            });

            loadPatients();
        });

        function pad2(n) { return n < 10 ? '0' + n : '' + n; }
        function toServerDate(s) {
            var d = new Date(s);
            if (isNaN(d.getTime())) return s;
            return pad2(d.getMonth() + 1) + '/' + pad2(d.getDate()) + '/' + d.getFullYear();
        }
        function fmt(n) { return (n || 0).toLocaleString(); }

        function loadPatients() {
            var fromRaw = $('#txtFrom').val();
            var toRaw = $('#txtTo').val();
            if (!fromRaw || !toRaw) {
                if (typeof Swal !== 'undefined') Swal.fire('Required', 'Please pick both From and To dates.', 'warning');
                else alert('Please pick both From and To dates.');
                return;
            }
            PageMethods.GetPatients(toServerDate(fromRaw), toServerDate(toRaw), function (resp) {
                var k = JSON.parse(resp);
                renderCards(k);
                renderBarChart(k.DailyTrend);
                renderOpdDonut(k);
            }, function (err) {
                console.error('PageMethods error:', err);
                if (typeof Swal !== 'undefined') Swal.fire('Error', err.get_message(), 'error');
                else alert('Error: ' + err.get_message());
            });
        }

        function renderCards(k) {
            $('#kpiNewRegs').text(fmt(k.NewRegistrations));
            $('#kpiOpdNew').text(fmt(k.OpdNew));
            $('#kpiOpdRepeat').text(fmt(k.OpdRepeat));
            $('#kpiTotalBills').text(fmt(k.TotalBills));
        }

        var barChart, opdDonut;

        function renderBarChart(daily) {
            var labels = [], bills = [], opds = [];
            for (var i = 0; i < daily.length; i++) {
                labels.push(daily[i].Date);
                bills.push(daily[i].Billings);
                opds.push(daily[i].OPD);
            }
            var opts = {
                series: [
                    { name: 'Total Bills', data: bills },
                    { name: 'OPD Visits', data: opds }
                ],
                chart: { type: 'bar', height: 350, toolbar: { show: true } },
                plotOptions: { bar: { horizontal: false, columnWidth: '55%', borderRadius: 4 } },
                dataLabels: { enabled: false },
                stroke: { show: true, width: 2, colors: ['transparent'] },
                xaxis: { categories: labels },
                yaxis: { title: { text: 'Count' }, min: 0 },
                fill: { opacity: 1 },
                colors: ['#4cc9f0', '#4361ee'],
                legend: { position: 'top' },
                tooltip: { y: { formatter: function (v) { return v.toLocaleString(); } } }
            };
            if (barChart) barChart.destroy();
            barChart = new ApexCharts(document.querySelector('#chartDaily'), opts);
            barChart.render();
        }

        function renderOpdDonut(k) {
            var series = [k.OpdNew || 0, k.OpdRepeat || 0];
            var labels = ['OPD New', 'OPD Repeat'];
            var colors = ['#4361ee', '#7209b7'];
            var opts = {
                series: series,
                chart: { type: 'donut', height: 320 },
                labels: labels,
                colors: colors,
                legend: { position: 'bottom' },
                plotOptions: {
                    pie: {
                        donut: {
                            labels: {
                                show: true,
                                total: {
                                    show: true,
                                    label: 'Total OPD Patients',
                                    formatter: function (w) {
                                        return w.globals.seriesTotals.reduce(function (a, b) { return a + b; }, 0).toLocaleString();
                                    }
                                }
                            }
                        }
                    }
                },
                dataLabels: { enabled: true, formatter: function (val) { return Math.round(val) + '%'; } },
                tooltip: { y: { formatter: function (v) { return v.toLocaleString() + ' patients'; } } }
            };
            if (opdDonut) opdDonut.destroy();
            opdDonut = new ApexCharts(document.querySelector('#chartOpdDonut'), opts);
            opdDonut.render();
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid py-3">
        <div class="pto-card">
            <div class="pto-title"><i class="fas fa-chart-line"></i>Patients Turnover</div>

            <div class="pto-filter">
                <div class="row align-items-end g-3">
                    <div class="col-md-3">
                        <label for="txtFrom">Start Date</label>
                        <input type="text" id="txtFrom" class="form-control" placeholder="Pick a date" />
                    </div>
                    <div class="col-md-3">
                        <label for="txtTo">End Date</label>
                        <input type="text" id="txtTo" class="form-control" placeholder="Pick a date" />
                    </div>
                    <div class="col-md-3">
                        <button type="button" id="btnShow" class="btn btn-primry" style="margin-top:17px !important;">Show</button>
                    </div>
                </div>
            </div>

            <div class="row g-4 mb-2">
                <div class="col-lg-3 col-md-6">
                    <div class="kpi-card kpi-new">
                        <div class="kpi-header"><span>New Register</span><i class="fas fa-user-plus"></i></div>
                        <div class="kpi-body">
                            <div class="kpi-label">Registrations</div>
                            <div class="kpi-value" id="kpiNewRegs">0</div>
                            <div class="kpi-foot">In date range</div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6">
                    <div class="kpi-card kpi-opdnew">
                        <div class="kpi-header"><span>OPD New</span><i class="fas fa-stethoscope"></i></div>
                        <div class="kpi-body">
                            <div class="kpi-label">First Visit</div>
                            <div class="kpi-value" id="kpiOpdNew">0</div>
                            <div class="kpi-foot">Already registered, OPD new</div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6">
                    <div class="kpi-card kpi-opdrep">
                        <div class="kpi-header"><span>OPD Repeat</span><i class="fas fa-redo-alt"></i></div>
                        <div class="kpi-body">
                            <div class="kpi-label">Returning</div>
                            <div class="kpi-value" id="kpiOpdRepeat">0</div>
                            <div class="kpi-foot">OPD patient seen before</div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6">
                    <div class="kpi-card kpi-bill">
                        <div class="kpi-header"><span>Total Bills</span><i class="fas fa-file-invoice-dollar"></i></div>
                        <div class="kpi-body">
                            <div class="kpi-label">Billings</div>
                            <div class="kpi-value" id="kpiTotalBills">0</div>
                            <div class="kpi-foot">Excludes pharmacy</div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row g-4">
                <div class="col-lg-6">
                    <div class="chart-card">
                        <div class="chart-title"><i class="fas fa-chart-pie"></i>OPD Split (New vs Repeat)</div>
                        <div id="chartOpdDonut" style="height: 320px;"></div>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="chart-card">
                        <div class="chart-title"><i class="fas fa-chart-bar"></i>Daily Bills vs OPD Visits</div>
                        <div id="chartDaily" style="height: 320px;"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
