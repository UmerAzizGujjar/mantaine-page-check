<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DashPatientsCountertoClinic.aspx.cs" Inherits="PMS.Modules.Dashboards.DashPatientsCountertoClinic" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/echarts@5.4.3/dist/echarts.min.js"></script>
    <style>
        .row-dash { margin: 0; }
        .row-dash > [class^="col-"] { padding: 0 8px; }
        .dash-title { font-size: 22px; font-weight: 700; color: #1a1a2e; margin: 0; }
        .card-dash { border-radius: 12px; border: 1px solid #e4e7ec; background: #fff; margin-bottom: 16px; position:relative; }
        .card-dash .card-body { padding: 18px 20px; }
        .kpi-label { font-size: 12px; font-weight: 600; color: #667085; text-transform: uppercase; letter-spacing: .5px; margin-bottom: 4px; }
        .kpi-value { font-size: 28px; font-weight: 700; color: #1a1a2e; line-height: 1.2; }
        .kpi-sub { font-size: 12px; color: #667085; margin-top: 2px; }
        .kpi-trend { font-size: 12px; margin-top: 4px; }
        .kpi-trend.up { color: #12b76a; }
        .kpi-trend.down { color: #f04438; }
        .kpi-warn .kpi-value { color: #dc6803; }
        .wf-section { padding: 16px 20px; }
        .wf-section h3 { font-size: 15px; font-weight: 700; color: #000 !important; margin: 0 0 16px 0; }
        .wf-bar { display: flex; height: 44px; border-radius: 8px; }
        .wf-seg { display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 600; color: #fff; position: relative; min-width: 56px; cursor: default; transition: transform .2s, box-shadow .2s, z-index 0s; border-radius: 6px; margin: 0 2px; }
        .wf-seg:hover { transform: scale(1.08); z-index: 10; box-shadow: 0 4px 16px rgba(0,0,0,.25); }
        .wf-seg .wf-time { font-size: 11px; opacity: .9; margin-left: 3px; }
        .wf-reg { background: #98a2b3; }
        .wf-cons { background: #667085; }
        .wf-lab { background: #475467; }
        .wf-pharm { background: #344054; }
        .wf-serv { background: #dc6803; }
        .wf-disc { background: #b54708; }
        .wf-seg.highest { background: #dc6803 !important; box-shadow: inset 0 0 0 2px rgba(255,255,255,.3); }
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
                url: "DashPatientsCountertoClinic.aspx/GetDashboardData",
                data: JSON.stringify({ txt_sdate: _dt, txt_edate: _dts }),
                contentType: "application/json; charset=utf-8",
                success: function (r) {
                    var d = JSON.parse(r.d);
                    $('#totalPatients').text(d.totalPatients);
                    var ptArrow = d.ptTrend === 'up' ? '\u25B2' : '\u25BC';
                    var ptCls = d.ptTrend === 'up' ? 'up' : 'down';
                    $('#ptTrend').html(d.ptTrendPercent > 0 ? '<span class="kpi-trend ' + ptCls + '">' + ptArrow + ' ' + d.ptTrendPercent + '% vs previous</span>' : '');
                    $('#avgTotalTime').text(d.avgTotalTime);
                    var avgArrow = d.avgTrend === 'up' ? '\u25B2' : '\u25BC';
                    var avgCls = d.avgTrend === 'up' ? 'up' : 'down';
                    $('#avgTrend').html(d.avgTrendPercent > 0 ? '<span class="kpi-trend ' + avgCls + '">' + avgArrow + ' ' + d.avgTrendPercent + '% vs previous</span>' : '');
                    if (d.highestStage === 'No Data') {
                        $('#highestStage').text('No Data').css('color', '#12b76a');
                        $('#highestStageTime').text('');
                        $('#highestStage').closest('.card-body').find('.kpi-label').css('color', '#12b76a').text('Most Time Stage');
                    } else {
                        $('#highestStage').text(d.highestStage).css('color', '#dc6803');
                        $('#highestStageTime').text(d.highestStageTime + ' avg');
                        $('#highestStage').closest('.card-body').find('.kpi-label').css('color', '#dc6803').text('Most Time Stage');
                    }
                    renderWF(d.stages);
                },
                error: function (xhr) { console.log(xhr.responseText); }
            });
        }
        function renderWF(stages) {
            var clsMap = { Registration: 'wf-reg', Consultation: 'wf-cons', Lab: 'wf-lab', Pharmacy: 'wf-pharm', Service: 'wf-serv', Discharge: 'wf-disc' };
            var total = stages.reduce(function (s, st) { return s + Math.max(st.minutes, 1); }, 0) || 1;
            var html = '';
            $.each(stages, function (i, s) {
                var pct = Math.max(8, (s.minutes / total) * 100);
                var c = clsMap[s.name] || '';
                if (s.isHighest) c += ' highest';
                var label = s.name;
                if (s.avgTime) label += ' <span class="wf-time">' + s.avgTime + '</span>';
                html += '<div class="wf-seg ' + c + '" style="flex:' + pct + '">' + label + '</div>';
            });
            $('#wfBar').html(html);
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
                        url: "DashPatientsCountertoClinic.aspx/ViewList",
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
                    { "data": "patientName", "name": "patientName", "width": "14%", "orderable": true },
                    { "data": "regTime", "name": "regTime", "width": "10%", "orderable": true },
                    { "data": "opdTime", "name": "opdTime", "width": "10%", "orderable": true },
                    { "data": "vitalsTime", "name": "vitalsTime", "width": "10%", "orderable": true },
                    { "data": "outPatientTime", "name": "outPatientTime", "width": "10%", "orderable": true },
                    { "data": "labTime", "name": "labTime", "width": "10%", "orderable": true },
                    { "data": "medicineTime", "name": "medicineTime", "width": "10%", "orderable": true },
                    { "data": "serviceTime", "name": "serviceTime", "width": "10%", "orderable": true },
                    { "data": "dischargeDate", "name": "dischargeDate", "width": "10%", "orderable": true },
                    { "data": "totalTime", "name": "totalTime", "width": "8%", "orderable": true }
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
                        <div class="kpi-label">Total Patients</div>
                        <div class="kpi-value" id="totalPatients">0</div>
                        <div id="ptTrend"></div>
                    </div>
                </div>
            </div>
            <div class="col-md-4" style="padding:0 8px;">
                <div class="card-dash">
                    <div class="card-body">
                        <div class="kpi-label">Avg. Total Time</div>
                        <div class="kpi-value" id="avgTotalTime">0</div>
                        <div id="avgTrend"></div>
                    </div>
                </div>
            </div>
            <div class="col-md-4" style="padding:0 8px;">
                <div class="card-dash">
                    <div class="card-body" style="border-left:4px solid #dc6803;">
                        <div class="kpi-label" style="color:#dc6803;">Most Time Stage</div>
                        <div class="kpi-value" style="color:#dc6803;" id="highestStage">--</div>
                        <div class="kpi-sub" id="highestStageTime"></div>
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
                            <div class="wf-seg wf-reg" style="flex:1">Loading...</div>
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
                                    <th>Reg Date</th>
                                    <th>OPD Date</th>
                                    <th>Vitals Date</th>
                                    <th>Out Patient</th>
                                    <th>Lab Date</th>
                                    <th>Medicine Date</th>
                                    <th>Service Date</th>
                                    <th>Discharge Date</th>
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
