<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Inventory_Dashboard.aspx.cs" Inherits="PMS.Modules.Dashboards.Inventory_Dashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
   
         <script src="../../wwwroot/THEME_TIBBIT/Scripts/jquery.canvasjs.min.js"  type="text/javascript"></script>

    <link href="../../wwwroot/StandardTheme/CustomCSS/swalalert.css" rel="stylesheet" />
    <script src="../../wwwroot/lib/apexcharts/apexchart.js" type="text/javascript"></script>
    <style type="text/css">
        .apexcharts-data-labels text {
            font-weight: bold !important;
            font-size: 10px !important;
        }

        .apexcharts-xaxis text {
            font-size: 9px !important;
        }

        .apexcharts-yaxis text {
            font-size: 9px !important;
        }


        .container {
            width: 100% !important
        }

        h3 {
            color: dodgerblue;
        }





        #Box1 {
            height: 125px;
            border-radius: 30px !important
        }

        #Box2 {
            height: 125px;
            border-radius: 30px !important
        }

        #Box3 {
            height: 125px;
            border-radius: 30px !important
        }

        #Box4 {
            height: 125px;
            border-radius: 30px !important
        }

        #Box5 {
            height: 125px;
            border-radius: 30px !important
        }

            #Box1 h3, #Box2 h3, #Box3 h3, #Box4 h3, #Box5 h3 {
                color: #eee;
            }

        .l-bg-orange-dark {
            background: linear-gradient(to right, #8e0b4d, #9f10abf2) !important;
            color: #fff;
        }

        .l-bg-green-dark {
            background: linear-gradient(to right, #888, #555) !important;
            color: #fff;
        }

        .l-bg-blue-dark {
            background: linear-gradient(to right, #710d2b,#a2070f) !important;
            color: #fff;
        }

        #Paitent_Count_Row {
            height: 80px;
            margin-top: 20px;
        }

        .styling {
            text-align: center;
            font-size: 25px;
        }

        #ctl00_sidebar, .page-header {
            display: none !important
        }


        .card {
            border-radius: 12px;
            border: none;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            background: #fff;
            margin-bottom: 20px;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

            .card:hover {
                transform: translateY(-3px);
                box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
            }

        .card-header {
            background: linear-gradient(90deg, #4bc0c0, #308665db );
            color: #fff;
            font-weight: 600;
            font-size: 2.1rem;
            border-top-left-radius: 12px;
            border-top-right-radius: 12px;
            padding: 12px 18px;
        }

        .card-body {
            padding: 20px;
        }

        .table-borderless th,
        .table-borderless td {
            border: none !important;
            padding: 8px 12px;
        }

        .table-borderless th {
            font-weight: bold;
            color: #555;
        }

        .table-borderless td {
            color: #333;
        }

        .spinner {
        border: 8px solid #f3f3f3; 
        border-top: 8px solid #308665;
        border-radius: 50%;
        width: 60px;
        height: 60px;
        animation: spin 1s linear infinite;
    }

    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }
    </style>

    <script type="text/javascript">
        $(document).ready(function () {
            $("#loader").show();

            loadChart();
            loadTopGRNItems();
            loadGRNChart();
            loadTopGRNVendors();
            loadTopPaidVendors();
            loadPOSummary();
            loadGRNSummary();
            loadPaymentSummary();

            setTimeout(function () {
                $("#loader").fadeOut();
            }, 4000);
        });

        function loadChart() {
            $.ajax({
                type: "POST",
                url: "Inventory_Dashboard.aspx/GetPurchaseOrderChart",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = response.d;

                    var labels = [];
                    var totalPOs = [];
                    var totalAmount = [];

                    for (var i = 0; i < data.length; i++) {
                        labels.push(data[i].MonthName);
                        totalPOs.push(data[i].TotalPOs);
                        totalAmount.push(data[i].TotalAmount);
                    }

                    var options = {
                        series: [
                            {
                                name: "Total POs",
                                data: totalPOs,
                                color: "#4bc0c0"
                            },
                            {
                                name: "Total Amount",
                                data: totalAmount,
                                color: "#308665db"
                            }
                        ],
                        chart: {
                            type: "bar",
                            height: 350
                        },
                        plotOptions: {
                            bar: {
                                horizontal: false,
                                columnWidth: "55%",
                                endingShape: "rounded"
                            }
                        },
                        dataLabels: {
                            enabled: false
                        },
                        stroke: {
                            show: true,
                            width: 2,
                            colors: ["transparent"]
                        },
                        xaxis: {
                            categories: labels
                        },
                        yaxis: [
                            {
                                title: {
                                    text: "Total POs"
                                }
                            },
                            {
                                opposite: true,
                                title: {
                                    text: "Total Amount"
                                }
                            }
                        ],
                        legend: {
                            position: "top"
                        },
                        title: {
                            text: "Purchase Orders Overview (Last 12 Months)",
                            align: "center"
                        },
                        tooltip: {
                            y: {
                                formatter: function (val) {
                                    return val;
                                }
                            }
                        }
                    };

                    var chart = new ApexCharts(document.querySelector("#purchaseOrderChart"), options);
                    chart.render();
                },
                error: function (xhr, status, error) {
                    alert("Error: " + error);
                }
            });
        }

        function loadTopGRNItems() {
            $.ajax({
                type: "POST",
                url: "Inventory_Dashboard.aspx/GetTopGRNItems",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = response.d;
                    var tbody = $("#tblTopGRNItems tbody");
                    tbody.empty();

                    var labels = [];
                    var amounts = [];

                    $.each(data, function (i, item) {
                        tbody.append(
                            "<tr><td>" + item.Description + "</td>" +
                            '<td style="text-align: right;">' + Math.round(item.TotalAmount) + "</td>"


                        );

                        labels.push(item.Description);
                        amounts.push(item.TotalAmount);
                    });

                    var options = {
                        series: [{
                            name: "Total Amount",
                            data: amounts
                        }],
                        chart: {
                            type: 'bar',
                            height: 350
                        },
                        plotOptions: {
                            bar: {
                                horizontal: false,
                                columnWidth: '55%',
                                endingShape: 'rounded'
                            }
                        },
                        dataLabels: { enabled: false },
                        xaxis: { categories: labels }
                    };

                    var chart = new ApexCharts(document.querySelector("#chartTopGRNItems"), options);
                    chart.render();
                },
                error: function (xhr, status, error) {
                    alert("Error: " + error);
                }
            });
        }

        function loadGRNChart() {
            $.ajax({
                type: "POST",
                url: "Inventory_Dashboard.aspx/GetGRNChart",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = response.d;

                    var labels = [];
                    var amounts = [];
                    var counts = [];

                    $.each(data, function (i, item) {
                        labels.push(item.MonthName);
                        amounts.push(item.TotalAmount);
                        counts.push(item.TotalGRNs);
                    });

                    var options = {
                        series: [
                            {
                                name: "Total Amount",
                                type: 'column',
                                data: amounts
                            },
                            {
                                name: "Total GRNs",
                                type: 'line',
                                data: counts
                            }
                        ],
                        chart: {
                            height: 350,
                            type: 'line'
                        },
                        stroke: {
                            width: [0, 4],
                            colors: ['#308665db', '#308665db'] // line color
                        },
                        colors: ['#308665db', '#308665db'], // bar + line colors
                        title: {
                            text: "Purchase For (Last 12 Months)"
                        },
                        dataLabels: {
                            enabled: true,
                            enabledOnSeries: [1]
                        },
                        labels: labels,
                        xaxis: {
                            type: 'category'
                        },
                        yaxis: [
                            {
                                title: {
                                    text: "Amount"
                                }
                            },
                            {
                                opposite: true,
                                title: {
                                    text: "Number of GRNs"
                                }
                            }
                        ]
                    };

                    var chart = new ApexCharts(document.querySelector("#chartGRN"), options);
                    chart.render();
                },
                error: function (xhr, status, error) {
                    alert("Error: " + error);
                }
            });
        }


        function loadTopGRNVendors() {
            $.ajax({
                type: "POST",
                url: "Inventory_Dashboard.aspx/GetTopGRNVendors",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = response.d;
                    var tbody = $("#tblTopGRNVendors tbody");
                    tbody.empty();

                    $.each(data, function (i, vendor) {
                        tbody.append(
                            "<tr><td>" + vendor.Vendor_Name + "</td>" +
                            '<td style="text-align: right;">' + Math.round(vendor.TotalAmount) + "</td>"
                        );
                    });
                },
                error: function (xhr, status, error) {
                    alert("Error: " + error);
                }
            });
        }

        function loadTopPaidVendors() {
            $.ajax({
                type: "POST",
                url: "Inventory_Dashboard.aspx/GetTopPaidVendors",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = response.d;
                    var tbody = $("#tblTopPaidVendors tbody");
                    tbody.empty();

                    $.each(data, function (i, vendor) {
                        tbody.append(
                            "<tr><td>" + vendor.Vendor_Name + "</td>" +
                            '<td style="text-align: right;">' + Math.round(vendor.TotalPaid) + "</td>"
                        );
                    });
                },
                error: function (xhr, status, error) {
                    alert("Error: " + error);
                }
            });
        }

        function loadPOSummary() {
            $.ajax({
                type: "POST",
                url: "Inventory_Dashboard.aspx/GetPOSummary",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = response.d;

                    $("#weekPO").text(data.TotalPO_Last7Days);
                    $("#weekAmount").text(
                        Math.floor(data.TotalAmount_Last7Days).toLocaleString()
                    );

                    $("#monthPO").text(data.TotalPO_LastMonth);
                    $("#monthAmount").text(
                        Math.floor(data.TotalAmount_LastMonth).toLocaleString()
                    );

                    $("#yearPO").text(data.TotalPO_LastYear);
                    $("#yearAmount").text(
                        Math.floor(data.TotalAmount_LastYear).toLocaleString()
                    );
                },
                error: function (xhr, status, error) {
                    alert("Error: " + error);
                }
            });
        }


        function loadGRNSummary() {
            $.ajax({
                type: "POST",
                url: "Inventory_Dashboard.aspx/GetGRNSummary",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = response.d;

                    $("#weekGRN").text(data.TotalGRN_Last7Days);
                    $("#weekGRNAmount").text(
                        Math.floor(data.TotalAmount_Last7Days).toLocaleString()
                    );

                    $("#monthGRN").text(data.TotalGRN_LastMonth);
                    $("#monthGRNAmount").text(
                        Math.floor(data.TotalAmount_LastMonth).toLocaleString()
                    );

                    $("#yearGRN").text(data.TotalGRN_LastYear);
                    $("#yearGRNAmount").text(
                        Math.floor(data.TotalAmount_LastYear).toLocaleString()
                    );
                },
                error: function (xhr, status, error) {
                    alert("Error: " + error);
                }
            });
        }


        function loadPaymentSummary() {
            $.ajax({
                type: "POST",
                url: "Inventory_Dashboard.aspx/GetPaymentSummary",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = response.d;

                    $("#weekPayment").text(data.TotalPayments_Last7Days);
                    $("#weekPaymentAmount").text(
                        Math.floor(data.TotalAmount_Last7Days).toLocaleString()
                    );

                    $("#monthPayment").text(data.TotalPayments_LastMonth);
                    $("#monthPaymentAmount").text(
                        Math.floor(data.TotalAmount_LastMonth).toLocaleString()
                    );

                    $("#yearPayment").text(data.TotalPayments_LastYear);
                    $("#yearPaymentAmount").text(
                        Math.floor(data.TotalAmount_LastYear).toLocaleString()
                    );
                },
                error: function (xhr, status, error) {
                    alert("Error: " + error);
                }
            });
        }



    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
  <div id="loader" style="display: none;position: fixed;top: 0; left: 0;width: 100%; height: 100%;background: rgba(255,255,255,0.8);z-index: 9999;
    display: flex;justify-content: center;align-items: center;">
    <div class="spinner"></div>
</div>
    <div class="container">
        <div class="row">
            <div class="col-lg-8 col-md-6 sm-12">
                <div class="card">
                    <div class="card-header">
                        Purchase Orders (Last 12 Months)
                    </div>
                    <div class="card-body">
                        <div id="purchaseOrderChart"></div>
                    </div>
                </div>
            </div>


            <div class="col-lg-3 col-md-6 sm-12">
                <div class="card">
                    <div class="card-header">
                        Top 10 GRN Items (Last 90 Days)
                    </div>
                    <div class="card-body">
                        <table class="table table-borderless" id="tblTopGRNItems">
                            <thead>
                                <tr>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

        </div>
        <div class="row">
            <div class="col-lg-8 col-md-6 sm-12">
                <div class="card">
                    <div class="card-header">
                        Purchase For (Last 12 Months)
                    </div>
                    <div class="card-body">
                        <div id="chartGRN"></div>
                    </div>
                </div>
            </div>
            <div class="col-lg-3">
                <div class="card shadow-sm">
                    <div class="card-header">
                        Top 10 Vendors (Last 90 Days)
                    </div>
                    <div class="card-body">
                        <table class="table table-borderless" id="tblTopGRNVendors">
                            <thead>
                                <tr>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>
                </div>
            </div>


        </div>
       <div class="row">
    <div class="col-lg-4 col-md-6 col-md-12">
        <div class="card shadow-sm">
            <div class="card-header">
                Top 10 Paid Vendors (Last 90 Days)
            </div>
            <div class="card-body">
                <table class="table table-borderless" id="tblTopPaidVendors">
                    <tbody></tbody>
                </table>
            </div>
        </div>
    </div>

    <div class="col-lg-7 col-md-7 col-md-12">
        <div class="row mb-3">
            <div class="col-md-2">
                <div class="card shadow-sm border-secondary">
                    <div class="card-body text-center">
                        <h4>Week</h4>
                    </div>
                </div>
            </div>
            <div class="col-md-10">
                <div class="row">
                    <div class="col-md-4">
                        <div class="card shadow-sm border-info">
                            <div class="card-body text-center">
                                <h6>GRNs: <span id="weekGRN">0</span> | Amount: <span id="weekGRNAmount">0</span></h6>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card shadow-sm border-success">
                            <div class="card-body text-center">
                                <h6>Payments: <span id="weekPayment">0</span> | Amount: <span id="weekPaymentAmount">0</span></h6>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card shadow-sm border-warning">
                            <div class="card-body text-center">
                                <h6>POs: <span id="weekPO">0</span> | Amount: <span id="weekAmount">0</span></h6>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row mb-3">
            <div class="col-md-2">
                <div class="card shadow-sm border-secondary">
                    <div class="card-body text-center">
                        <h4>Month</h4>
                    </div>
                </div>
            </div>
            <div class="col-md-10">
                <div class="row">
                    <div class="col-md-4">
                        <div class="card shadow-sm border-dark">
                            <div class="card-body text-center">
                                <h6>GRNs: <span id="monthGRN">0</span> | Amount: <span id="monthGRNAmount">0</span></h6>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card shadow-sm border-primary">
                            <div class="card-body text-center">
                                <h6>Payments: <span id="monthPayment">0</span> | Amount: <span id="monthPaymentAmount">0</span></h6>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card shadow-sm border-success">
                            <div class="card-body text-center">
                                <h6>POs: <span id="monthPO">0</span> | Amount: <span id="monthAmount">0</span></h6>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-md-2">
                <div class="card shadow-sm border-danger">
                    <div class="card-body text-center">
                        <h4>Year</h4>
                    </div>
                </div>
            </div>
            <div class="col-md-10">
                <div class="row">
                    <div class="col-md-4">
                        <div class="card shadow-sm border-warning">
                            <div class="card-body text-center">
                                <h6>GRNs: <span id="yearGRN">0</span> | Amount: <span id="yearGRNAmount">0</span></h6>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card shadow-sm border-secondary">
                            <div class="card-body text-center">
                                <h6>Payments: <span id="yearPayment">0</span> | Amount: <span id="yearPaymentAmount">0</span></h6>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card shadow-sm border-info">
                            <div class="card-body text-center">
                                <h6>POs: <span id="yearPO">0</span> | Amount: <span id="yearAmount">0</span></h6>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

    </div>
</asp:Content>
