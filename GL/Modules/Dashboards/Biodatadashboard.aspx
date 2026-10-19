<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Biodatadashboard.aspx.cs" Inherits="PMS.Modules.Dashboards.Biodatadashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/echarts@5.4.3/dist/echarts.min.js"></script>
    <style>
        .row-dash { margin: 0; }
        .row-dash > [class^="col-"] { padding: 0 8px; }
        .card-dash { border-radius: 12px; border: 1px solid #e4e7ec; background: #fff; margin-bottom: 16px; }
        .card-dash .card-body { padding: 18px 20px; }
        .period-pills { display: flex; gap: 6px; }
        .period-pill { border:1px solid #d1d5db; border-radius:20px; padding:4px 16px; font-size:12px; font-weight:600; background:#fff; color:#374151; cursor:pointer; transition:all .2s; }
        .period-pill:hover { border-color:#8e0016; color:#8e0016; }
        .period-pill.active { background:#8e0016; border-color:#8e0016; color:#fff; }
        .custom-date-range { display:none; gap:8px; align-items:center; }
        .custom-date-range.visible { display:flex !important; }
        .filter-label { font-size:12px; font-weight:600; color:#667085; text-transform:uppercase; letter-spacing:.5px; margin-bottom:6px; }
        .table-container { overflow-x: auto; }
        .kpi-row > [class^="col-"] { display: flex; }
        .kpi-row .card-dash { width:100%; height:100%; display:flex; flex-direction:column; }
        .kpi-row .card-dash .card-body { flex:1; }
        .table-nb { border-collapse: collapse !important; border: none !important; }
        .table-nb thead th, .table-nb tbody td { border: none !important; }
        .select2-container .select2-selection--multiple,
        .select2-container .select2-selection--single { border: 1px solid #d1d5db; border-radius: 6px; min-height: 32px; background: #fff; }
        .select2-container .select2-selection--multiple .select2-selection__choice { background: #f0f1f3; border: none; border-radius: 4px; padding: 1px 8px; margin-top: 3px; font-size: 12px; }
        .select2-container .select2-search--inline .select2-search__field { margin-top: 3px; font-size: 13px; }
        .select2-dropdown { border: 1px solid #d1d5db; border-radius: 6px; }
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
            fillCity();
            fillArea();
            fillgender();
            fillsymptoms();
            $('#ddlgender, #ddlarea, #ddlcity, #ddlsymptom').on('change', function () {
                refreshAll();
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
        function getFilters() {
            var g = $('#ddlgender').val() || '0';
            var a = $('#ddlarea').val();
            a = a && a.length ? a.join(',') : '0';
            var c = $('#ddlcity').val();
            c = c && c.length ? c.join(',') : '0';
            var s = $('#ddlsymptom').val();
            s = s && s.length ? s.join(',') : '0';
            return { gender: g, area: a, city: c, symptoms: s };
        }
        function refreshAll() {
            if ($.fn.DataTable.isDataTable('#tbl')) {
                $('#tbl').DataTable().ajax.reload();
            } else {
                LoadTable();
            }
            ChartQtyofDoc();
        }
        function fillCity() {
            PageMethods.GetCity(function (data) {
                var opts = '<option value="0">All</option>';
                $.each(JSON.parse(data), function (k, v) {
                    opts += '<option value="' + v.DataValue_Name + '">' + v.DataValue_Description + '</option>';
                });
                $('#ddlcity').html(opts).select2();
            });
        }
        function fillArea() {
            PageMethods.GetArea(function (data) {
                var opts = '';
                $.each(JSON.parse(data), function (k, v) {
                    opts += '<option value="' + v.DataValue_Name + '">' + v.DataValue_Description + '</option>';
                });
                $('#ddlarea').html(opts).select2();
            });
        }
        function fillgender() {
            PageMethods.GetGender(function (data) {
                var opts = '<option value="0">All</option>';
                $.each(JSON.parse(data), function (k, v) {
                    opts += '<option value="' + v.DataValue_Name + '">' + v.DataValue_Description + '</option>';
                });
                $('#ddlgender').html(opts).select2();
            });
        }
        function fillsymptoms() {
            PageMethods.Getsymptoms(function (data) {
                var opts = '';
                $.each(JSON.parse(data), function (k, v) {
                    opts += '<option value="' + v.DataValue_Name + '">' + v.DataValue_Description + '</option>';
                });
                $('#ddlsymptom').html(opts).select2();
            });
        }
        function ChartQtyofDoc() {
            var f = getFilters();
            PageMethods.LoadPaiDashboard(_dt, _dts, f.gender, f.symptoms, f.city, f.area, function (resp) {
                var parsedData = JSON.parse(resp);
                var chartData = parsedData.map(function (item) { return { value: item.symtom_count, name: item.symtom_name }; });
                if (window.bioChart) bioChart.dispose();
                bioChart = echarts.init(document.getElementById('chartContainer_Qty'));
                bioChart.setOption({
                    tooltip: { trigger: 'item' },
                    series: [{
                        type: 'pie',
                        radius: ['42%', '68%'],
                        avoidLabelOverlap: true,
                        label: { show: true, formatter: '{b}: {d}%', fontSize: 11 },
                        emphasis: { label: { show: true, fontSize: 13 } },
                        data: chartData
                    }]
                });
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
                "pageLength": 100,
                "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
                "ajax": function (data, callback, settings) {
                    var f = getFilters();
                    var sortCol = data.order.length ? data.columns[data.order[0].column].name : '';
                    var sortDir = data.order.length ? data.order[0].dir : '';
                    $.ajax({
                        type: "POST",
                        url: "Biodatadashboard.aspx/ViewList",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length,
                            sortColumn: sortCol,
                            sortColumnDirection: sortDir,
                            searchValue: data.search.value,
                            txt_sdate: _dt,
                            txt_edate: _dts,
                            gender: f.gender,
                            symptoms: f.symptoms,
                            city: f.city,
                            area: f.area
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
                    { "data": "srNo", "name": "srNo", "width": "5%", "orderable": false },
                    { "data": "mrNo", "name": "mrNo", "width": "10%", "orderable": true },
                    { "data": "regDate", "name": "regDateSort", "width": "15%", "orderable": true },
                    { "data": "name", "name": "name", "width": "18%", "orderable": true },
                    { "data": "age", "name": "age", "width": "5%", "orderable": true },
                    { "data": "gender", "name": "gender", "width": "7%", "orderable": true },
                    { "data": "address", "name": "address", "width": "18%", "orderable": true },
                    { "data": "phone", "name": "phone", "width": "12%", "orderable": true },
                    { "data": "diagnosis", "name": "diagnosis", "width": "10%", "orderable": true }
                ],
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
    <div class="pf-page">
    <header class="pf-header">
        <div>
            <h1 class="pf-title">Biodata Dashboard</h1>
            <p class="pf-subtitle">Registered patients and symptom distribution, filtered by date, gender, area, city and symptom</p>
        </div>
    </header>
    <div class="row-dash">
        <div class="row" style="margin:0 0 12px 0;">
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
        <div class="row kpi-row" style="margin:0 0 12px 0;">
            <div class="col-md-3" style="padding:0 8px;">
                <div class="card-dash">
                    <div class="card-body">
                        <div class="filter-label">Gender</div>
                        <select id="ddlgender" class="form-control" style="width:100%;"></select>
                    </div>
                </div>
            </div>
            <div class="col-md-3" style="padding:0 8px;">
                <div class="card-dash">
                    <div class="card-body">
                        <div class="filter-label">Area</div>
                        <select id="ddlarea" class="form-control" multiple="multiple" style="width:100%;"></select>
                    </div>
                </div>
            </div>
            <div class="col-md-3" style="padding:0 8px;">
                <div class="card-dash">
                    <div class="card-body">
                        <div class="filter-label">City</div>
                        <select id="ddlcity" class="form-control" multiple="multiple" style="width:100%;"></select>
                    </div>
                </div>
            </div>
            <div class="col-md-3" style="padding:0 8px;">
                <div class="card-dash">
                    <div class="card-body">
                        <div class="filter-label">Symptom</div>
                        <select id="ddlsymptom" class="form-control" multiple="multiple" style="width:100%;"></select>
                    </div>
                </div>
            </div>
        </div>
        <div class="row" style="margin:0 0 12px 0;">
            <div class="col-lg-12" style="padding:0 8px;">
                <div class="card-dash">
                    <div class="table-container">
                        <table id="tbl" class="table table-hover table-striped table-nb" style="width:100%">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>MR No</th>
                                    <th>Registration Date</th>
                                    <th>Name</th>
                                    <th>Age</th>
                                    <th>Gender</th>
                                    <th>Address</th>
                                    <th>Phone</th>
                                    <th>Diagnosis</th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        <div class="row" style="margin:0;">
            <div class="col-lg-6" style="padding:0 8px;">
                <div class="card-dash">
                    <div class="card-body" style="text-align:center;">
                        <h3 style="font-size:15px;font-weight:700;color:#000;margin:0 0 12px 0;text-align:left;">Symptoms Distribution</h3>
                        <div id="chartContainer_Qty" style="height:280px;"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    </div>
</asp:Content>
