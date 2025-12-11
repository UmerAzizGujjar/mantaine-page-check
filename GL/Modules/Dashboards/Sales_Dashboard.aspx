<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Sales_Dashboard.aspx.cs" Inherits="PMS.Modules.Dashboards.Sales_Dashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
         <script src="../../wwwroot/Tibbit_theme/Scripts/jquery.canvasjs.min.js"  type="text/javascript"></script>

    <link href="../../wwwroot/StandardTheme/css/CustomCss/swalalert.css" rel="stylesheet" />
    <script src="../../wwwroot/Tibbit_theme/js/apexchart.js" type="text/javascript"></script>
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
            0% {
                transform: rotate(0deg);
            }

            100% {
                transform: rotate(360deg);
            }
        }

        .card-body.text-center {
            height: 103px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        h6 {
            margin-left: 20px;
        }

        .card2 {
            height: 50px !important;
        }

        .card2 {
            height: 354px !important;
            display: flex;
            flex-direction: column;
        }

            

        .chart-heading {
            text-align: left;
            margin-bottom: 10px;
            font-size: 20px;
            font-weight: bold;
        }

        .spinner {
            border: 8px solid #f3f3f3;
            border-top: 8px solid #308665;
            border-radius: 50%;
            width: 60px;
            height: 60px;
            animation: spin 1s linear infinite;
        }
    </style>
    <script type="text/javascript">

        $(document).ready(function () {
            $("#loader").show();

            loadSalesSummary();
            loadTopSalesMedicines();
            loadDailySales();
            loadYearlySalesComparison();
            loadMedicinesDepartmentWise();
            loadPharmacyStockSummary();
            loadPendingPO();

            setTimeout(function () {
                $("#loader").fadeOut();
            }, 7000);
        });

        function loadSalesSummary() {
            $.ajax({
                type: "POST",
                url: "Sales_Dashboard.aspx/GetSalesSummary",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var d = response.d;

                    function formatNumber(num) {
                        return Math.floor(num).toLocaleString();
                    }

                    $("#weekSale").text(formatNumber(d.This_Week_Sale));
                    $("#weekDiscount").text(formatNumber(d.This_Week_Discount));
                    $("#weekProfit").text(formatNumber(d.This_Week_Profit));
                    $("#prevWeekSale").text(formatNumber(d.Previous_Week_Sale));

                    $("#monthSale").text(formatNumber(d.This_Month_Sale));
                    $("#monthDiscount").text(formatNumber(d.This_Month_Discount));
                    $("#monthProfit").text(formatNumber(d.This_Month_Profit));
                    $("#prevMonthSale").text(formatNumber(d.Previous_Month_Sale));

                    $("#yearSale").text(formatNumber(d.This_Year_Sale));
                    $("#yearDiscount").text(formatNumber(d.This_Year_Discount));
                    $("#yearProfit").text(formatNumber(d.This_Year_Profit));
                    $("#prevYearSale").text(formatNumber(d.Previous_Year_Sale));
                },
                error: function (xhr, status, error) {
                    console.error("Error loading sales summary: ", error);
                    alert("Failed to load sales data.");
                }
            });
        }


        function loadTopSalesMedicines() {
            $.ajax({
                type: "POST",
                url: "Sales_Dashboard.aspx/GetTopSalesMedicines",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = response.d;
                    var tbody = $("#tblTopSalesMedicines tbody");
                    tbody.empty();

                    var labels = [];
                    var amounts = [];

                    $.each(data, function (i, item) {
                        tbody.append(
                            "<tr><td>" + item.Item_Name + "</td>" +
                            '<td style="text-align: right;">' + Math.round(item.TotalNetAmount) + "</td></tr>"
                        );

                        labels.push(item.Item_Name);
                        amounts.push(item.TotalNetAmount);
                    });
                },
                error: function (xhr, status, error) {
                    alert("Error: " + error);
                }
            });
        }

        function loadMedicinesDepartmentWise() {
            $.ajax({
                type: "POST",
                url: "Sales_Dashboard.aspx/GetSalesMedicinesDepartmentWise",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = response.d;
                    var tbody = $("#tblTopMedicinesDepartment tbody");
                    tbody.empty();

                    var labels = [];
                    var amounts = [];

                    $.each(data, function (i, item) {
                        tbody.append(
                            "<tr>" +
                            "<td>" + item.MedicineCategory + "</td>" +     
                            '<td style="text-align: right;">' +
                            Math.round(item.TotalNetAmount).toLocaleString('en-IN') +
                            "</td>" +
                            "</tr>"
                        );

                        labels.push(item.MedicineCategory);
                        amounts.push(Math.round(item.TotalNetAmount));
                    });

                    var total = amounts.reduce((a, b) => a + b, 0);
                    $("#totalMedicineSales").text("₹" + total.toLocaleString('en-IN'));
                },
                error: function (xhr, status, error) {
                    alert("Error loading medicine categories: " + error);
                }
            });
        }


        function loadDailySales() {
            $.ajax({
                type: "POST",
                url: "Sales_Dashboard.aspx/GetLastMonthDailySales",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = response.d;

                    var dates = [];
                    var amounts = [];

                    $.each(data, function (i, item) {
                        dates.push(item.SaleDate);
                        amounts.push(item.TotalNetAmount);
                    });

                    var options = {
                        chart: {
                            type: 'line',
                            height: 350,
                            zoom: { enabled: false }
                        },
                        series: [{
                            name: "Total Sales",
                            data: amounts
                        }],
                        xaxis: {
                            categories: dates,
                            title: { text: "Date (dd/MM)" }
                        },
                        yaxis: {
                            title: { text: "Sales Amount" }
                        },
                        stroke: {
                            curve: 'smooth'
                        },
                        markers: {
                            size: 4
                        }
                    };

                    var chart = new ApexCharts(document.querySelector("#chartDailySales"), options);
                    chart.render();
                },
                error: function (xhr, status, error) {
                    alert("Error: " + error);
                }
            });
        }

        function loadDailySales() {
            $.ajax({
                type: "POST",
                url: "Sales_Dashboard.aspx/GetLastMonthDailySales",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = response.d;

                    var dates = [];
                    var amounts = [];

                    $.each(data, function (i, item) {
                        dates.push(item.SaleDate);
                        amounts.push(item.TotalNetAmount);
                    });

                    var options = {
                        chart: {
                            type: 'bar',
                            height: 350
                        },
                        series: [{
                            name: "Total Sales",
                            data: amounts
                        }],
                        xaxis: {
                            categories: dates,
                            title: { text: "Date (dd/MM)" }
                        },
                        yaxis: {
                            title: { text: "Sales Amount" }
                        },
                        plotOptions: {
                            bar: {
                                horizontal: false,
                                columnWidth: '55%',
                                endingShape: 'rounded'
                            }
                        },
                        dataLabels: {
                            enabled: false
                        },
                        colors: ["#308665"],
                    };

                    var chart = new ApexCharts(document.querySelector("#barChart"), options);
                    chart.render();
                },
                error: function (xhr, status, error) {
                    alert("Error: " + error);
                }
            });
        }

        function loadYearlySalesComparison() {
            $.ajax({
                type: "POST",
                url: "Sales_Dashboard.aspx/GetSalesComparisonYearly",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = response.d;

                    var months = [];
                    var prevYear = [];
                    var currYear = [];

                    $.each(data, function (i, item) {
                        months.push(item.MonthName);
                        prevYear.push(item.PrevYearAmount);
                        currYear.push(item.CurrentYearAmount);
                    });

                    var options = {
                        chart: {
                            type: 'bar',
                            height: 400
                        },
                        series: [
                            {
                                name: (new Date().getFullYear() - 1).toString(),
                                data: prevYear
                            },
                            {
                                name: new Date().getFullYear().toString(),
                                data: currYear
                            }
                        ],
                        xaxis: {
                            categories: months,
                            title: { text: "Months" }
                        },
                        yaxis: {
                            title: { text: "Sales Amount" }
                        },
                        plotOptions: {
                            bar: {
                                horizontal: false,
                                columnWidth: '45%',
                                endingShape: 'rounded'
                            }
                        },
                        dataLabels: {
                            enabled: false
                        },
                        colors: ["#308665", "#4bc0c0"],
                        legend: {
                            position: 'top'
                        },
                        title: {
                            text: "Month Wise Sales Comparison",
                            align: "center"
                        }
                    };

                    var chart = new ApexCharts(document.querySelector("#yearlyBarChart"), options);
                    chart.render();
                },
                error: function (xhr, status, error) {
                    alert("Error: " + error);
                }
            });
        }

        function loadPharmacyStockSummary() {
            $.ajax({
                type: "POST",
                url: "Sales_Dashboard.aspx/GetPharmacyStockSummary",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var d = response.d[0];

                    function formatNumber(num) {
                        if (num == null) return 0;
                        return Math.floor(num).toLocaleString();
                    }

                    $("#currentStockQty").text(formatNumber(d.GrandTotalQty));
                    $("#currentStockAmount").text(formatNumber(d.GrandTotalAmount));
                    $("#deadStockQty").text(formatNumber(d.DeadStockQty));
                    $("#deadStockAmount").text(formatNumber(d.DeadStockAmount));
                }

            });
        }

        function loadPendingPO() {
            $.ajax({
                type: "POST",
                url: "Sales_Dashboard.aspx/GetPendingPO",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var d = response.d[0];

                    function formatNumber(num) {
                        return Math.floor(num).toLocaleString();
                    }

                    $("#pendingPOQty").text(formatNumber(d.TotalPendingQty));
                    $("#pendingPOAmount").text(formatNumber(d.TotalPendingAmount));
                },
                error: function (xhr, status, error) {
                    console.error("Error loading pending PO summary: ", error);
                    alert("Failed to load pending PO summary.");
                }
            });
        }


    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="loader" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(255,255,255,0.8); z-index: 9999; display: flex; justify-content: center; align-items: center;">
        <div class="spinner"></div>
    </div>
    <div class="container mt-4">
        <div class="row">
           <div class="col-lg-9 col-md-8 col-sm-12">
    <div class="card shadow-lg border-primary">
        <div class="card-header bg-primary text-white text-center">
            <h4>Sales</h4>
        </div>
        <div class="card-body">
            <div class="row mb-3">
                <div class="col-lg-2 col-md-6 col-sm-12">
                    <div class="card shadow-sm border-secondary">
                        <div class="card-body text-center">
                            <h4>Week</h4>
                        </div>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6 col-sm-12">
                    <div class="card shadow-sm border-info">
                        <div class="card-body text-center">
                            <h6>This Sale: <span id="weekSale">0</span></h6>
                            <h6>Prev Sale: <span id="prevWeekSale">0</span></h6>
                        </div>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6 col-sm-12">
                    <div class="card shadow-sm border-success">
                        <div class="card-body text-center">
                            <h6>This Discount: <span id="weekDiscount">0</span></h6>
                        </div>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6 col-sm-12">
                    <div class="card shadow-sm border-warning">
                        <div class="card-body text-center">
                            <h6>This Profit: <span id="weekProfit">0</span></h6>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row ">
                <div class="col-lg-2 col-md-6 col-sm-12">
                    <div class="card shadow-sm border-secondary">
                        <div class="card-body text-center">
                            <h4>Month</h4>
                        </div>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6 col-sm-12">
                    <div class="card shadow-sm border-info">
                        <div class="card-body text-center">
                            <h6>This Sale: <span id="monthSale">0</span></h6>
                            <h6>Prev Sale: <span id="prevMonthSale">0</span></h6>
                        </div>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6 col-sm-12">
                    <div class="card shadow-sm border-success">
                        <div class="card-body text-center">
                            <h6>This Discount: <span id="monthDiscount">0</span></h6>
                        </div>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6 col-sm-12">
                    <div class="card shadow-sm border-warning">
                        <div class="card-body text-center">
                            <h6>This Profit: <span id="monthProfit">0</span></h6>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-2 col-md-6 col-sm-12">
                    <div class="card shadow-sm border-secondary">
                        <div class="card-body text-center">
                            <h4>Year</h4>
                        </div>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6 col-sm-12">
                    <div class="card shadow-sm border-info">
                        <div class="card-body text-center">
                            <h6>This Sale: <span id="yearSale">0</span></h6>
                            <h6>Prev Sale: <span id="prevYearSale">0</span></h6>
                        </div>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6 col-sm-12">
                    <div class="card shadow-sm border-success">
                        <div class="card-body text-center">
                            <h6>This Discount: <span id="yearDiscount">0</span></h6>
                        </div>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6 col-sm-12">
                    <div class="card shadow-sm border-warning">
                        <div class="card-body text-center">
                            <h6>This Profit: <span id="yearProfit">0</span></h6>
                        </div>
                    </div>
                </div>
            </div>
        </div> 
    </div>
</div>

            <div class="col-lg-3 cl-md-6 col-sm-12">
                <div class="card2">
                    <div class="card-header">
                        Top 10 Sales Medicines (Last 30 Days)
                    </div>
                    <div class="card-body">
                        <table class="table table-borderless" id="tblTopSalesMedicines">
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
            <div class="col-lg-12 col-md-6 sm-12">
                <div class="card">
                    <div class="card-header">
                        Month Wise Sales Dashboard
                    </div>
                    <div class="card-body">
                        <div id="barChart"></div>
                    </div>
                </div>
            </div>
        </div>
       
        <div class="row">
            <div class="col-lg-9 col-md-10 col-sm-12">
                <div class="card">
                    <div class="card-header">
                        Yearly Sales Comparison
           
                    </div>
                    <div class="card-body">
                        <div id="yearlyBarChart"></div>
                    </div>
                </div>
            </div>
            <div class="col-lg-3 cl-md-6 col-sm-12">
                <div class="card2">
                    <div class="card-header">
                        Category Wise Medicines (Last 30 Days)
                    </div>
                    <div class="card-body">
                        <table class="table table-borderless" id="tblTopMedicinesDepartment">
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
    <div class="col-lg-6 col-md-12 col-sm-12">
        <div class="card shadow-sm">
            <div class="card-header bg-primary text-white">
                <h4 class="mb-0">Stock</h4>
            </div>
            <div class="card-body">
                <div class="row">
                    <div class="col-lg-4 col-md-6 col-sm-12">
                        <div class="card mb-3 shadow-sm border-secondary">
                            <div class="card-body text-center">
                                <h5 class="card-title">Current Stock</h5>
                            </div>
                        </div>

                        <div class="card shadow-sm border-secondary">
                            <div class="card-body text-center">
                                <h5 class="card-title">Dead Stock<br>
                                    <small>(Not Sold in Last 30 Days)</small></h5>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-8 col-md-10 col-sm-12">
                        <div class="card mb-3 shadow-sm border-info">
                            <div class="card-body text-center">
                                <h6><b>Total Qty:</b> <span id="currentStockQty">0</span></h6>
                                <h6><b>Total Amount:</b> <span id="currentStockAmount">0</span></h6>
                            </div>
                        </div>

                        <div class="card shadow-sm border-danger">
                            <div class="card-body text-center">
                                <h6><b>Total Qty:</b> <span id="deadStockQty">0</span></h6>
                                <h6><b>Total Amount:</b> <span id="deadStockAmount">0</span></h6>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-lg-4 col-md-6 col-sm-12">
                        <div class="card mb-3 shadow-sm border-secondary">
                            <div class="card-body text-center">
                                <h5 class="card-title">Pending PO</h5>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-8 col-md-10 col-sm-12">
                        <div class="card mb-3 shadow-sm border-info">
                            <div class="card-body text-center">
                                <h6><b>Total Qty:</b> <span id="pendingPOQty">0</span></h6>
                                <h6><b>Total Amount:</b> <span id="pendingPOAmount">0</span></h6>
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
