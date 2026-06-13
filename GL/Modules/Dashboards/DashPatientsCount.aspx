<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DashPatientsCount.aspx.cs" Inherits="PMS.Modules.Dashboards.DashPatientsCount" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
        <script src="../../wwwroot/THEME_TIBBIT/Scripts/jquery.canvasjs.min.js"></script>
    <script src="../../wwwroot/lib/apexcharts/apexchart.js"></script>

    <style type="text/css">
        /* ===== CARD METRICS ===== */
        .metric-card {
            border-radius: 14px;
            box-shadow: 0 6px 18px rgba(0,0,0,0.08);
            transition: all 0.3s ease;
            height: 100%;
            display: flex;
            flex-direction: column;
        }
        .metric-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 24px rgba(0,0,0,0.12);
        }

        .metric-header {
            padding: 1rem 1.25rem;
            color: #fff;
            font-weight: 600;
            font-size: 1.1rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .metric-header i {
            font-size: 1.4rem;
            opacity: 0.9;
        }

        .metric-body {
            padding: 1.25rem;
            text-align: center;
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        .metric-title {
            font-size: 0.95rem;
            font-weight: 600;
            color: #6c757d;
            margin-bottom: 0.3rem;
        }
        .metric-value {
            font-size: 2.2rem;
            font-weight: 700;
            color: #212529;
        }

        /* Header colors */
        .card-walkin .metric-header { background: Black ; }
        .card-repeated .metric-header { background: Black; }
        .card-total .metric-header { background: Black; }

        /* ===== FILTER BAR ===== */
        .filter-bar {
            background: #f8f9fa;
            border-radius: 12px;
            padding: 1.25rem;
            box-shadow: 0 2px 6px rgba(0,0,0,0.04);
            margin-top: 1.5rem;
        }
        .filter-bar .form-label {
            font-weight: 600;
            font-size: 0.9rem;
            margin-bottom: 0.4rem;
            color: #495057;
        }
        .filter-bar .form-control,
        .filter-bar .form-select {
            border-radius: 8px !important;
            padding: 0.6rem 1rem;
            border: 1px solid #dee2e6;
        }
     

        /* ===== CHART CONTAINER ===== */
        .chart-container {
            background: #fff;
            border-radius: 14px;
            padding: 1.5rem;
            box-shadow: 0 4px 16px rgba(0,0,0,0.06);
            margin-top: 1.5rem;
        }
        .chart-title {
            font-size: 1.3rem;
            font-weight: 600;
            margin-bottom: 1.25rem;
            color: #212529;
            display: flex;
            align-items: center;
        }
        .chart-title i {
            margin-right: 0.5rem;
            color: #4361ee;
        }

        /* Responsive Fixes */
        @media (max-width: 991px) {
            .metric-card { margin-bottom: 1.25rem; }
        }
        @media (max-width: 767px) {
            .filter-bar .row > [class*="col-"] {
                margin-bottom: 1rem;
            }
            .filter-bar .row > [class*="col-"]:last-child {
                margin-bottom: 0;
            }
        }
    </style>

    <script type="text/javascript">
        $(document).ready(function () {
            LoadDepartmenr();
            var date = '<%= DateTime.Now.ToString("MMMM d, yyyy") %>'; // Safer server-side formatting

            $("#StartDate, #EndDate").datepicker({
                dateFormat: 'MM d, yy',
                changeMonth: true,
                changeYear: true
            }).attr('readonly', 'readonly');

            $("#StartDate").val(date);
            $("#EndDate").val(date);

            // Initialize Select2 after loading options
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
                alert("Please select valid date range.");
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
    <div class="container-fluid py-3">
        
        <!-- METRICS CARDS -->
        <div class="row g-4 mb-4">
            <!-- New Patients -->
            <div class="col-lg-4 col-md-6">
                <div class="card metric-card card-walkin">
                    <div class="metric-header">
                        <span>New Patients</span>
                        <i class="fas fa-user-plus"></i>
                    </div>
                    <div class="metric-body">
                        <div class="metric-title">Total Patients</div>
                        <div class="metric-value" id="txtWalkinPatientCount">0</div>
                        <div class="metric-title mt-3">Total Amount (PKR)</div>
                        <div class="metric-value" id="txtWIPAmount">0</div>
                    </div>
                </div>
            </div>

            <!-- Repeated Patients -->
            <div class="col-lg-4 col-md-6">
                <div class="card metric-card card-repeated">
                    <div class="metric-header">
                        <span>Repeated Patients</span>
                        <i class="fas fa-redo-alt"></i>
                    </div>
                    <div class="metric-body">
                        <div class="metric-title">Total Patients</div>
                        <div class="metric-value" id="txtRepeatedPatientCount">0</div>
                        <div class="metric-title mt-3">Total Amount (PKR)</div>
                        <div class="metric-value" id="txtRPAmount">0</div>
                    </div>
                </div>
            </div>

            <!-- Total Patients -->
            <div class="col-lg-4 col-md-6">
                <div class="card metric-card card-total">
                    <div class="metric-header">
                        <span>Total Patients</span>
                        <i class="fas fa-users"></i>
                    </div>
                    <div class="metric-body">
                        <div class="metric-title">Total Patients</div>
                        <div class="metric-value" id="txtTotalPatientCount">0</div>
                        <div class="metric-title mt-3">Total Amount (PKR)</div>
                        <div class="metric-value" id="txtTPAmount">0</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- FILTER BAR -->
        <div class="filter-bar">
            <div class="row align-items-end g-3">
                <div class="col-md-2">
                    <label class="form-label">Department</label>
                    <select id="ddlDepartemt" class="form-select"></select>
                </div>
                <div class="col-md-2">
                    <label class="form-label">From Date</label>
                    <input type="text" id="StartDate" class="form-control" />
                </div>
                <div class="col-md-2">
                    <label class="form-label">To Date</label>
                    <input type="text" id="EndDate" class="form-control" />
                </div>
                <div class="col-md-2">
                    <input type="button" class="btn btn-primry" value="Search" style="margin-top:17px !important;" onclick="SearchDate()" />
                      
                   
                </div>
            </div>
        </div>

        <!-- CHART SECTION -->
        <div class="chart-container mt-4">
            <div class="chart-title">
                <i class="fas fa-chart-bar"></i> Patient Distribution by Department
            </div>
            <div id="chartDepartmentStatistics" style="height: 450px;"></div>
        </div>
    </div>
</asp:Content>