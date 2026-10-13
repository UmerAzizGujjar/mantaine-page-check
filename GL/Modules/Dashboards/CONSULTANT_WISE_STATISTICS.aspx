<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CONSULTANT_WISE_STATISTICS.aspx.cs" Inherits="PMS.CONSULTANT_WISE_STATISTICS" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="../../wwwroot/THEME_TIBBIT/Scripts/jquery.canvasjs.min.js" type="text/javascript"></script>

    <link href="../../wwwroot/StandardTheme/CustomCSS/swalalert.css" rel="stylesheet" />
    <script src="../../wwwroot/lib/apexcharts/apexchart.js" type="text/javascript"></script>

    <script type="text/javascript">
        $(document).ready(function () {
            LoadDoctor();
            var date = '<%= DateTime.Now%>';
            $("#StartDate").datepicker({
                dateFormat: 'MM d,yy'
            }).attr('readonly', 'readonly');

            $("#EndDate").datepicker({
                dateFormat: 'MM d,yy'
            }).attr('readonly', 'readonly');

            date = moment(date).format('LL');
            $("#StartDate").val(date);
            $("#EndDate").val(date);

            ChartQtyofDoc(date, date);

            $('#doctorSearch').on('keyup', function () {
                var searchText = $(this).val().toLowerCase();
                $('#ddlDoctor li').filter(function () {
                    $(this).toggle($(this).text().toLowerCase().indexOf(searchText) > -1);
                });
            });
            $(document).on('change', '#ddlDoctor input[type="checkbox"]', function () {
                $('#doctorSearch').val('');
                $('#ddlDoctor li').show();
                updateDoctorButton();
            });
        });

        function updateDoctorButton() {
            var count = $('#ddlDoctor input[type="checkbox"]:checked').length;
            $('#doctorButtonText').text(count === 0 ? 'Select doctors' : count + ' doctor(s) selected');
        }

        function SearchDate() {
            var startdate = $('#StartDate').val();
            var enddate = $('#EndDate').val();
            var selectedDoctors = getSelectedDoctors();
            ChartQtyofDoc(startdate, enddate, selectedDoctors);
        }

        function LoadDoctor() {
            $.ajax({
                type: "POST",
                url: "CONSULTANT_WISE_STATISTICS.aspx/LoadDoctor",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    var options = '';
                    var Parsed_Data = JSON.parse(response.d);
                    $.each(Parsed_Data, function (key, value) {
                        options += '<li><label><input type="checkbox" class="no-switch" value="' + value.Emp_ID + '"> ' + value.Emp_Name + '</label></li>';
                    });
                    $('#ddlDoctor').html(options);
                },
                failure: function (response) {
                    Swal.fire('Error', response.d, 'error');
                }
            });
        }

        function getSelectedDoctors() {
            var selectedDoctors = [];
            $('#ddlDoctor input[type="checkbox"]:checked').each(function () {
                selectedDoctors.push($(this).val());
            });
            return selectedDoctors;
        }

        function formatDate(date) {
            return moment(date).format('YYYY-MM-DD HH:mm:ss');
        }

        let chart;
        function ChartQtyofDoc(startdate, enddate, doctorArray) {
            var txt_sdate = formatDate(startdate);
            var txt_edate = formatDate(enddate);

            if (!doctorArray || doctorArray.length === 0) {
                doctorArray = [];
            }

            var doctorArrayJson = JSON.stringify(doctorArray);

            PageMethods.GetTotalDoctor(txt_sdate, txt_edate, doctorArrayJson, function (resp) {
                var data = JSON.parse(resp);
                var labels = [];
                var seriesPatientCount = [];
                var seriesNumDays = [];

                data.forEach(function (item) {
                    labels.push(item.DoctorName);
                    seriesPatientCount.push(item.PatientCount);
                    seriesNumDays.push(item.NumberOfDays);
                });

                if (chart) {
                    chart.destroy();
                }

                var options = {
                    series: [{
                        name: 'Number Of Days',
                        data: seriesNumDays
                    },
                    {
                        name: 'Patient Count',
                        data: seriesPatientCount
                    }],
                    chart: {
                        type: 'bar',
                        height: 500
                    },
                    colors: ['#4361ee', '#4cc9f0'],
                    plotOptions: {
                        bar: {
                            horizontal: false,
                            columnWidth: '55%',
                            endingShape: 'rounded',
                            borderRadius: 6
                        }
                    },
                    dataLabels: {
                        enabled: false
                    },
                    stroke: {
                        show: true,
                        width: 2,
                        colors: ['transparent']
                    },
                    xaxis: {
                        categories: labels
                    },
                    yaxis: [{
                        title: {
                            text: 'Number Of Days'
                        }
                    }, {
                        opposite: true,
                        title: {
                            text: 'Patient Count'
                        }
                    }],
                    fill: {
                        opacity: 1
                    },
                    legend: { position: 'top', offsetY: 5 },
                    tooltip: {
                        y: {
                            formatter: function (val) {
                                return val;
                            }
                        }
                    }
                };

                chart = new ApexCharts(document.querySelector("#chartDepartmentStatistics"), options);
                chart.render();
            }, function (error) {
                Swal.fire('Chart Error', error.get_message(), 'error');
            });
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="pf-page">

        <header class="pf-header">
            <div>
                <h1 class="pf-title" id="h1">Consultant Wise Statistics</h1>
                <p class="pf-subtitle">Patient count and number of working days for each selected doctor</p>
            </div>
        </header>

        <!-- FILTERS -->
        <section class="pf-card">
            <div class="pf-filters">
                <div class="pf-field pf-field--wide">
                    <span class="pf-field-label">Doctors</span>
                    <div id="ddlDoctorDropdown" class="dropdown pf-doctor-dropdown">
                        <button class="btn btn-primry pf-dropdown-btn dropdown-toggle" type="button" data-toggle="dropdown">
                            <span id="doctorButtonText">Select doctors</span> <span class="caret"></span>
                        </button>
                        <div class="dropdown-menu pf-doctor-menu">
                            <div class="pf-doctor-search">
                                <input type="text" class="form-control" id="doctorSearch" placeholder="Search doctor..." />
                            </div>
                            <ul id="ddlDoctor" class="pf-doctor-list"></ul>
                        </div>
                    </div>
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
                    <input type="button" id="btnSearch" value="Search" onclick="SearchDate()" class="btn btn-primry" />
                </div>
            </div>
        </section>

        <!-- CHART -->
        <section class="pf-card">
            <div class="pf-card-head">
                <span class="pf-card-icon"><i class="fas fa-user-md"></i></span>
                <h2 class="pf-card-title">Patients and working days per doctor</h2>
            </div>
            <div id="chartDepartmentStatistics" style="height: 420px; width: 100%;"></div>
        </section>

    </div>
</asp:Content>
