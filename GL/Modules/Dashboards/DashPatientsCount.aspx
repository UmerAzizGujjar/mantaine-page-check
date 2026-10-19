<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DashPatientsCount.aspx.cs" Inherits="PMS.Modules.Dashboards.DashPatientsCount" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="../../wwwroot/THEME_TIBBIT/Scripts/jquery.canvasjs.min.js"></script>
    <script src="../../wwwroot/lib/apexcharts/apexchart.js"></script>

    <script type="text/javascript">
        $(document).ready(function () {
            LoadDepartmenr();
            var date = '<%= DateTime.Now.ToString("MMMM d, yyyy") %>';

            $("#StartDate, #EndDate").datepicker({
                dateFormat: 'MM d, yy',
                changeMonth: true,
                changeYear: true
            }).attr('readonly', 'readonly');

            $("#StartDate").val(date);
            $("#EndDate").val(date);

            $('#ddlDepartemt').select2({ placeholder: "Select Department", allowClear: true });

            LoadDashboard(date, date);
            ChartQtyofDoc(date, date);

            $('#ddlDepartemt').on('change', function () {
                var dt = $('#StartDate').val();
                var dts = $('#EndDate').val();
                LoadDashboard(dt, dts);
                ChartQtyofDoc(dt, dts);
            });
        });

        function SearchDate() {
            var dt = $('#StartDate').val();
            var dts = $('#EndDate').val();
            if (!dt || !dts) {
                Swal.fire('Missing date', 'Please select a valid date range.', 'warning');
                return;
            }
            LoadDashboard(dt, dts);
            ChartQtyofDoc(dt, dts);
        }

        function LoadDepartmenr() {
            $.ajax({
                type: "POST",
                url: "DashPatientsCount.aspx/LoadDepartmenr",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var options = '<option value="">All Departments</option>';
                    var Parsed_Data = JSON.parse(response.d);
                    $.each(Parsed_Data, function (key, value) {
                        options += `<option value="${value.DataValue_Name}">${value.DataValue_Description}</option>`;
                    });
                    $('#ddlDepartemt').html(options).trigger('change.select2');
                },
                error: function (xhr, status, error) {
                    console.error("LoadDepartmenr failed:", error);
                    Swal.fire('Error', 'Failed to load departments.', 'error');
                }
            });
        }

        function LoadDashboard(startdate, Enddate) {
            var Dep = $('#ddlDepartemt').val() || '';
            $.ajax({
                type: "POST",
                url: "DashPatientsCount.aspx/ViewList",
                data: JSON.stringify({ 'txt_sdate': startdate, 'txt_edate': Enddate }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var parsedData = JSON.parse(data.d);
                    $('#txtTotalPatientCount').text((parsedData.Total_Patients || 0).toLocaleString());
                    $('#txtRepeatedPatientCount').text((parsedData.Repeated_Patients || 0).toLocaleString());
                    $('#txtWalkinPatientCount').text((parsedData.Non_Repeated_Patients || 0).toLocaleString());
                    $('#txtTPAmount').text((parsedData.Total_Receipt_Amount || 0).toLocaleString());
                    $('#txtRPAmount').text((parsedData.Repeated_Receipt_Amount || 0).toLocaleString());
                    $('#txtWIPAmount').text((parsedData.Non_Repeated_Receipt_Amount || 0).toLocaleString());
                },
                error: function (xhr, status, error) {
                    console.error("LoadDashboard error:", error);
                    Swal.fire('Error', 'Failed to load dashboard data.', 'error');
                }
            });
        }

        let chart;
        function ChartQtyofDoc(startdate, Enddate) {
            var txt_sdate = $('#StartDate').val();
            var txt_edate = $('#EndDate').val();
            var Dep = $('#ddlDepartemt').val() || '';

            PageMethods.GetTotalDepartment(txt_sdate, txt_edate, Dep, function (resp) {
                var data = JSON.parse(resp);
                var labels = [];
                var Total_Patients = [], Repeated_Patients = [], Non_Repeated_Patients = [];

                data.forEach(function (item) {
                    labels.push(item.Patient_Main_Category || 'Unknown');
                    Total_Patients.push(item.Total_Patients || 0);
                    Repeated_Patients.push(item.Repeated_Patients || 0);
                    Non_Repeated_Patients.push(item.Non_Repeated_Patients || 0);
                });

                if (chart) chart.destroy();

                var options = {
                    series: [
                        { name: 'Total Patients', data: Total_Patients },
                        { name: 'Repeated', data: Repeated_Patients },
                        { name: 'New', data: Non_Repeated_Patients }
                    ],
                    chart: { type: 'bar', height: 450, toolbar: { show: true } },
                    plotOptions: {
                        bar: { horizontal: false, columnWidth: '50%', borderRadius: 6 }
                    },
                    dataLabels: { enabled: false },
                    stroke: { show: true, width: 2, colors: ['transparent'] },
                    xaxis: { categories: labels },
                    yaxis: {
                        title: { text: 'Patient Count' },
                        min: 0,
                        tickAmount: 5
                    },
                    fill: { opacity: 1 },
                    colors: ['#4361ee', '#4cc9f0', '#7209b7'],
                    tooltip: {
                        y: { formatter: function (val) { return val.toLocaleString(); } }
                    },
                    legend: { position: 'top', offsetY: 5 }
                };

                chart = new ApexCharts(document.querySelector("#chartDepartmentStatistics"), options);
                chart.render();
            }, function (error) {
                console.error("Chart error:", error.get_message());
                Swal.fire('Chart Error', error.get_message(), 'error');
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="pf-page">

        <header class="pf-header">
            <div>
                <h1 class="pf-title">Patient Count</h1>
                <p class="pf-subtitle">New, repeated and total patients with receipt amounts, by department</p>
            </div>
        </header>

        <!-- FILTERS -->
        <section class="pf-card">
            <div class="pf-filters">
                <div class="pf-field pf-field--wide">
                    <label class="pf-field-label" for="ddlDepartemt">Department</label>
                    <select id="ddlDepartemt" class="form-select"></select>
                </div>
                <div class="pf-field">
                    <label class="pf-field-label" for="StartDate">From date</label>
                    <input type="text" id="StartDate" class="form-control" />
                </div>
                <div class="pf-field">
                    <label class="pf-field-label" for="EndDate">To date</label>
                    <input type="text" id="EndDate" class="form-control" />
                </div>
                <div class="pf-field pf-field--action">
                    <input type="button" class="btn btn-primry" value="Search" onclick="SearchDate()" />
                </div>
            </div>
        </section>

        <!-- KPI CARDS -->
        <div class="pf-kpis">
            <article class="pf-kpi pf-kpi--new">
                <div class="pf-kpi-head">
                    <span class="pf-kpi-title">New patients</span>
                    <span class="pf-kpi-icon"><i class="fas fa-user-plus"></i></span>
                </div>
                <div class="pf-kpi-body">
                    <div>
                        <div class="pf-metric-label">Patients</div>
                        <div class="pf-metric-value" id="txtWalkinPatientCount">0</div>
                    </div>
                    <div>
                        <div class="pf-metric-label">Amount (PKR)</div>
                        <div class="pf-metric-value" id="txtWIPAmount">0</div>
                    </div>
                </div>
            </article>

            <article class="pf-kpi pf-kpi--repeat">
                <div class="pf-kpi-head">
                    <span class="pf-kpi-title">Repeated patients</span>
                    <span class="pf-kpi-icon"><i class="fas fa-redo-alt"></i></span>
                </div>
                <div class="pf-kpi-body">
                    <div>
                        <div class="pf-metric-label">Patients</div>
                        <div class="pf-metric-value" id="txtRepeatedPatientCount">0</div>
                    </div>
                    <div>
                        <div class="pf-metric-label">Amount (PKR)</div>
                        <div class="pf-metric-value" id="txtRPAmount">0</div>
                    </div>
                </div>
            </article>

            <article class="pf-kpi pf-kpi--total">
                <div class="pf-kpi-head">
                    <span class="pf-kpi-title">Total patients</span>
                    <span class="pf-kpi-icon"><i class="fas fa-users"></i></span>
                </div>
                <div class="pf-kpi-body">
                    <div>
                        <div class="pf-metric-label">Patients</div>
                        <div class="pf-metric-value" id="txtTotalPatientCount">0</div>
                    </div>
                    <div>
                        <div class="pf-metric-label">Amount (PKR)</div>
                        <div class="pf-metric-value" id="txtTPAmount">0</div>
                    </div>
                </div>
            </article>
        </div>

        <!-- CHART -->
        <section class="pf-card">
            <div class="pf-card-head">
                <span class="pf-card-icon"><i class="fas fa-chart-bar"></i></span>
                <h2 class="pf-card-title">Patient distribution by department</h2>
            </div>
            <div id="chartDepartmentStatistics" style="height: 450px;"></div>
        </section>

    </div>
</asp:Content>
