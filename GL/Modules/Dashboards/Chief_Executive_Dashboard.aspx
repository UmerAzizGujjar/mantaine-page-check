<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Chief_Executive_Dashboard.aspx.cs" Inherits="PMS.Modules.Dashboards.Chief_Executive_Dashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
   
    <script src="https://cdn.jsdelivr.net/npm/echarts@5/dist/echarts.min.js"></script>
    <script type="text/javascript">
        var opdChartInstance = null;
        var billingChartInstance = null;
        var pharmacyChartInstance = null;
        var pharmacyChartInstancehp = null;
        var clinicalChartInstance = null;
        var satisfactionChartInstance = null;
        var deptPctChart = null;
        var deptCountChart = null;
        var deptDoctorChart = null;
        var _sparkCharts = {};

        function setPeriod(period, startDate, endDate) {
            $(".period-pill").removeClass("active");
            $(".period-pill[data-period='" + period + "']").addClass("active");
            if (period === "custom") {
                $(".custom-date-range").addClass("visible");
                if (startDate) $("#txtStartDate").val(startDate);
                if (endDate) $("#txtEndDate").val(endDate);
            } else {
                $(".custom-date-range").removeClass("visible");
            }
            showAllLoading();
            LoadHospitalRevenue(period, startDate, endDate);
            LoadOPDSaleRevenue(period, startDate, endDate);
            LoadEMRSaleRevenue(period, startDate, endDate);
            LoadCardFeeRevenue(period, startDate, endDate);
            LoadPharmacyRevenue(period, startDate, endDate);
            LoadPBRevenue(period, startDate, endDate);
            LoadLabRadiologyRevenue(period, startDate, endDate);
            LoadServicesRevenue(period, startDate, endDate);
            LoadOPDChart(period, startDate, endDate);
            LoadOPDVolume(period, startDate, endDate);
            LoadWaitTimeTrends(period, startDate, endDate);
            LoadDialysisLive(period, startDate, endDate);
            LoadDeptStatsCharts(period, startDate, endDate);
            loadSummaryCards();
            loadRevenueTrends(period, startDate, endDate);
            LoadPharmacySnapshot(period, startDate, endDate);
            LoadPharmacySnapshothp(period, startDate, endDate);
            LoadBillingData(period, startDate, endDate);
            LoadClinicalOutcomes(period, startDate, endDate);
            LoadRegionalHeatmap(period, startDate, endDate);
        }

        function setCardLoading(id, loading) {
            var el = $("#" + id);
            if (el.length) el.toggleClass("card-loading", loading);
        }
        function showAllLoading() {
            $(".bento-item").not(".period-bar").addClass("card-loading");
            setTimeout(function () { $(".bento-item").removeClass("card-loading"); }, 120000);
        }

        $(document).ajaxStop(function () { $(".bento-item").removeClass("card-loading"); });
        $(document).ajaxError(function (e, xhr, settings, error) {
            var match = settings.url ? settings.url.match(/\/(\w+)$/) : null;
            var wm = match ? match[1] : 'unknown';
            console.error("[" + wm + "] AJAX Error: " + error + " | Response: " + (xhr.responseText || '').substring(0, 200));
        });
        $(document).ready(function () {
            $("#trendMonth").val(String(new Date().getMonth()));
            setPeriod("today");
            renderSatisfaction();
            FillWarehouse();
            FillWarehousePharmacy();
            $("#ddlWarehouse").change(function () {
                var pill = $(".period-pill.active");
                var period = pill.data("period");
                var startDate = null, endDate = null;
                if (period === "custom") {
                    startDate = $("#txtStartDate").val();
                    endDate = $("#txtEndDate").val();
                }
                
                loadSummaryCards();
                
                var m = $("#trendMonth").val();
                if (m !== "") {
                    applyTrendFilter();
                }
            });

            $("#ddlWarehousepharmacy").change(function () {
                loadPharmacyData(); 
                var m = $("#trendMonth").val();
                if (m !== "") {
                    applyTrendFilterPharmacy(); 
                }
            });



            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetDepartments",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var depts = JSON.parse(response.d);
                    var opts = '<option value="0">All Departments</option>';
                    depts.forEach(function (d) { opts += '<option value="' + d.DataValue_Name + '">' + d.DataValue_Description + '</option>'; });
                    $("#ddlClinDept").html(opts);
                }
            });

            $(".period-pill").click(function () {
                var period = $(this).data("period");
                $(".card-filter input.datepicker, #txtClinStart, #txtClinEnd").val("");
                $(".card-filter select").val("");
                $("#trendMonth").val(String(new Date().getMonth()));
                $(".period-pill").removeClass("active");
                $(this).addClass("active");
                if (period === "custom") {
                    $(".custom-date-range").addClass("visible");
                } else {
                    $(".custom-date-range").removeClass("visible");
                    setPeriod(period);
                }
            });

            $(".datepicker").datepicker({
                changeMonth: true,
                changeYear: true,
                dateFormat: "dd/mm/yy",
                yearRange: "-100:+0"
            });

            $("#btnApplyCustom").click(function () {
                var s = $("#txtStartDate").val();
                var e = $("#txtEndDate").val();
                if (s && e) {
                    setPeriod("custom", s, e);
                }
            });

            $("#btnClinApply").click(function () {
                var period = $(".period-pill.active").data("period");
                LoadClinicalOutcomes(period, null, null);
            });

            $(".modal-overlay").click(function (e) {
                if ($(e.target).hasClass('modal-overlay')) $(this).removeClass('open');
            });

            function getMasterState() {
                var pill = $(".period-pill.active");
                var p = pill.data("period");
                var s = null, e = null;
                if (p === "custom") { s = $("#txtStartDate").val(); e = $("#txtEndDate").val(); }
                return { period: p, startDate: s, endDate: e };
            }

            $(".card-apply").click(function () {
                var card = $(this).data("card");
                if (card === "trend") { applyTrendFilter(); return; }
                var from = $("#" + card + "From").val();
                var to = $("#" + card + "To").val();
                if (!from || !to) return;
                var targetId = card === "opd" ? "opd-area" : card === "dept" ? "dept-area" : card === "heat" ? "trend-area" : card;
                setCardLoading(targetId, true);
                setTimeout(function () { setCardLoading(targetId, false); }, 120000);
                switch (card) {
                    case "opd":
                        LoadOPDChart("custom", from, to);
                        LoadOPDVolume("custom", from, to);
                        LoadWaitTimeTrends("custom", from, to);
                        break;
                    case "dept": LoadDeptStatsCharts("custom", from, to); break;
                    case "heat": LoadRegionalHeatmap("custom", from, to); break;
                    case "dia": LoadDialysisLive("custom", from, to); break;
                    case "ph": LoadPharmacySnapshot("custom", from, to); break;
                    case "hp": LoadPharmacySnapshothp("custom", from, to); break;
                    case "lab": LoadBillingData("custom", from, to); break;
                }
            });
            function applyTrendFilter() {
                var m = $("#trendMonth").val();
                if (m === "") return;
                setCardLoading("trend-area", true);
                var y = new Date().getFullYear();
                var months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
                var cm = months[parseInt(m)];
                var warehouse = $('#ddlWarehouse').val() || '0';
                var pharmacyWarehouse = $('#ddlWarehousepharmacy').val() || '0';
                $.ajax({
                    type: "POST",
                    url: "Chief_Executive_Dashboard.aspx/GetYearlyInventorySummary",
                    data: JSON.stringify({ year: y, warehouse: warehouse }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (res) {
                        var data = JSON.parse(res.d);
                        if (data.Error) return;
                        var openingRow, purchaseRow, purchaseRetRow, saleRow, closingRow;
                        data.forEach(function (r) {
                            if (r.Metric === 'Opening_Value') openingRow = r;
                            else if (r.Metric === 'Purchase_Value') purchaseRow = r;
                            else if (r.Metric === 'PurchaseReturn_Value') purchaseRetRow = r;
                            else if (r.Metric === 'Sale_Value') saleRow = r;
                            else if (r.Metric === 'Closing_Value') closingRow = r;
                        });
                        $('#invBadge').text('Month-end Closing (' + cm + ')');
                        $('#invOpening').text('Rs. ' + fmt(openingRow ? (openingRow[cm]||0) : 0));
                        $('#invPurchase').text('Rs. ' + fmt(purchaseRow ? (purchaseRow[cm]||0) : 0));
                        $('#invPurchaseReturn').text('Rs. ' + fmt(purchaseRetRow ? (purchaseRetRow[cm]||0) : 0));
                        $('#invSale').text('Rs. ' + fmt(saleRow ? (saleRow[cm]||0) : 0));
                        $('#invClosing').text('Rs. ' + fmt(closingRow ? (closingRow[cm]||0) : 0));
                    }
                });
                $.ajax({
                    type: "POST",
                    url: "Chief_Executive_Dashboard.aspx/GetYearlyPharmacySummary",
                    data: JSON.stringify({ year: y, warehouse: pharmacyWarehouse }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (res) {
                        var data = JSON.parse(res.d);
                        if (data.Error) return;
                        var openingRow, purchaseRow, saleRow, closingRow;
                        data.forEach(function (r) {
                            if (r.Metric === 'Opening_Value') openingRow = r;
                            else if (r.Metric === 'Purchase_Value') purchaseRow = r;
                            else if (r.Metric === 'Sale_Value') saleRow = r;
                            else if (r.Metric === 'Closing_Value') closingRow = r;
                        });
                        var po = openingRow ? (openingRow[cm]||0) : 0;
                        var pp = purchaseRow ? (purchaseRow[cm]||0) : 0;
                        var ps = saleRow ? (saleRow[cm]||0) : 0;
                        var pc = closingRow ? (closingRow[cm]||0) : 0;
                        $('#pharmOpening').text('Rs. ' + fmt(po));
                        $('#pharmPurchase').text('Rs. ' + fmt(pp));
                        $('#pharmSale').text('Rs. ' + fmt(ps));
                        $('#pharmClosing').text('Rs. ' + fmt(pc));
                    }
                });
                $.ajax({
                    type: "POST",
                    url: "Chief_Executive_Dashboard.aspx/GetYearlyPharmacySummaryPB",
                    data: JSON.stringify({ year: y, warehouse: pharmacyWarehouse }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (res) {
                        var data = JSON.parse(res.d);
                        if (data.Error) return;
                        var openingRow, purchaseRow, saleRow, closingRow;
                        data.forEach(function (r) {
                            if (r.Metric === 'Opening_Value') openingRow = r;
                            else if (r.Metric === 'Purchase_Value') purchaseRow = r;
                            else if (r.Metric === 'Sale_Value') saleRow = r;
                            else if (r.Metric === 'Closing_Value') closingRow = r;
                        });
                        var po = openingRow ? (openingRow[cm]||0) : 0;
                        var pp = purchaseRow ? (purchaseRow[cm]||0) : 0;
                        var ps = saleRow ? (saleRow[cm]||0) : 0;
                        var pc = closingRow ? (closingRow[cm]||0) : 0;
                        $('#pharmOpeningPB').text('Rs. ' + fmt(po));
                        $('#pharmPurchasePB').text('Rs. ' + fmt(pp));
                        $('#pharmSalePB').text('Rs. ' + fmt(ps));
                        $('#pharmClosingPB').text('Rs. ' + fmt(pc));
                    }
                });
                $.ajax({
                    type: "POST",
                    url: "Chief_Executive_Dashboard.aspx/GetYearlyPharmacyRevenue",
                    data: JSON.stringify({ year: y, warehouse: pharmacyWarehouse }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (res) {
                        var data = JSON.parse(res.d);
                        if (data.Error) return;
                        var grossRow, discRow, adjRow, retRow, netRow, cogsRow, gpRow;
                        data.forEach(function (r) {
                            if (r.Metric === 'Gross_Sale') grossRow = r;
                            else if (r.Metric === 'Discount_Value') discRow = r;
                            else if (r.Metric === 'Adjustment_Value') adjRow = r;
                            else if (r.Metric === 'SaleReturn') retRow = r;
                            else if (r.Metric === 'Net_Sale') netRow = r;
                            else if (r.Metric === 'CGS_Value') cogsRow = r;
                            else if (r.Metric === 'Gross_Profit') gpRow = r;
                        });
                        $('#revBadge').text('Month-end Closing (' + cm + ')');
                        $('#revGrossSale').text('Rs. ' + fmt(grossRow ? (grossRow[cm]||0) : 0));
                        $('#revDiscount').text('Rs. ' + fmt(discRow ? (discRow[cm]||0) : 0));
                        $('#revAdjustment').text('Rs. ' + fmt(adjRow ? (adjRow[cm]||0) : 0));
                        $('#revSaleReturn').text('Rs. ' + fmt(retRow ? (retRow[cm]||0) : 0));
                        $('#revNetSale').text('Rs. ' + fmt(netRow ? (netRow[cm]||0) : 0));
                        $('#revCogs').text('Rs. ' + fmt(cogsRow ? (cogsRow[cm]||0) : 0));
                        $('#revGrossProfit').text('Rs. ' + fmt(gpRow ? (gpRow[cm]||0) : 0));
                    }
                });
            }

            $(".card-trash").click(function () {
                var card = $(this).data("card");
                if (card === "trend") { $("#trendMonth").val(""); loadSummaryCards(); return; }
                $("#" + card + "From, #" + card + "To").val("");
                var m = getMasterState();
                switch (card) {
                    case "opd":
                        LoadOPDChart(m.period, m.startDate, m.endDate);
                        LoadOPDVolume(m.period, m.startDate, m.endDate);
                        LoadWaitTimeTrends(m.period, m.startDate, m.endDate);
                        break;
                    case "dept": LoadDeptStatsCharts(m.period, m.startDate, m.endDate); break;
                    case "heat": LoadRegionalHeatmap(m.period, m.startDate, m.endDate); break;
                    case "dia": LoadDialysisLive(m.period, m.startDate, m.endDate); break;
                    case "ph": LoadPharmacySnapshot(m.period, m.startDate, m.endDate); break;
                    case "hp": LoadPharmacySnapshothp(m.period, m.startDate, m.endDate); break;
                    case "lab": LoadBillingData(m.period, m.startDate, m.endDate); break;
                }
            });

            $("#clinTrash").click(function () {
                $("#txtClinStart, #txtClinEnd").val("");
                var m = getMasterState();
                LoadClinicalOutcomes(m.period, m.startDate, m.endDate);
            });
        });


        function loadPharmacyData() {
            var y = new Date().getFullYear();
            var m = new Date().getMonth();
            var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            var curMon = months[m];
            var pharmacyWarehouse = $('#ddlWarehousepharmacy').val() || '0';

            // Load Pharmacy Summary with pharmacy warehouse
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetYearlyPharmacySummary",
                data: JSON.stringify({ year: y, warehouse: pharmacyWarehouse }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var data = JSON.parse(res.d);
                    if (data.Error) return;
                    var openingRow, purchaseRow, saleRow, closingRow;
                    data.forEach(function (r) {
                        if (r.Metric === 'Opening_Value') openingRow = r;
                        else if (r.Metric === 'Purchase_Value') purchaseRow = r;
                        else if (r.Metric === 'Sale_Value') saleRow = r;
                        else if (r.Metric === 'Closing_Value') closingRow = r;
                    });
                    var po = openingRow ? (openingRow[curMon] || 0) : 0;
                    var pp = purchaseRow ? (purchaseRow[curMon] || 0) : 0;
                    var ps = saleRow ? (saleRow[curMon] || 0) : 0;
                    var pc = closingRow ? (closingRow[curMon] || 0) : 0;
                    $('#pharmOpening').text('Rs. ' + fmt(po));
                    $('#pharmPurchase').text('Rs. ' + fmt(pp));
                    $('#pharmSale').text('Rs. ' + fmt(ps));
                    $('#pharmClosing').text('Rs. ' + fmt(pc));
                }
            });

        }

        function LoadHospitalRevenue(period, startDate, endDate) {
            var data = { 'period': period, 'startDate': startDate || null, 'endDate': endDate || null };
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetHospitalRevenue",
                data: JSON.stringify(data),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var result = JSON.parse(data.d);
                    if (result.Error) {
                        $('#lblRevenue').text('0');
                        $('#lblRevenueDate').text('Error loading data');
                    } else {
                        var formatted = parseFloat(result.TotalHospitalRevenue).toLocaleString('en-PK', {
                            minimumFractionDigits: 0,
                            maximumFractionDigits: 0
                        });
                        $('#lblRevenue').text(formatted);
                        $('#lblRevenueDate').text(result.DateRange);
                    }
                },
                error: function () {
                    $('#lblRevenue').text('0');
                }
            });
        }

        function LoadOPDSaleRevenue(period, startDate, endDate) {
            var data = { 'period': period, 'startDate': startDate || null, 'endDate': endDate || null };
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetOPDSaleRevenue",
                data: JSON.stringify(data),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var result = JSON.parse(data.d);
                    if (result.Error) {
                        $('#lblOPDRevenue').text('0');
                        $('#lblOPDDate').text('Error loading data');
                    } else {
                        var formatted = parseFloat(result.OPDRevenue).toLocaleString('en-PK', {
                            minimumFractionDigits: 0,
                            maximumFractionDigits: 0
                        });
                        $('#lblOPDRevenue').text(formatted);
                        $('#lblOPDDate').text(result.DateRange);
                    }
                },
                error: function () {
                    $('#lblOPDRevenue').text('0');
                }
            });
        }

        function LoadEMRSaleRevenue(period, startDate, endDate) {
            var data = { 'period': period, 'startDate': startDate || null, 'endDate': endDate || null };
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetEMRSaleRevenue",
                data: JSON.stringify(data),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var result = JSON.parse(data.d);
                    if (result.Error) {
                        $('#lblEMRRevenue').text('0');
                        $('#lblEMRDate').text('Error loading data');
                    } else {
                        var formatted = parseFloat(result.OPDRevenue).toLocaleString('en-PK', {
                            minimumFractionDigits: 0,
                            maximumFractionDigits: 0
                        });
                        $('#lblEMRRevenue').text(formatted);
                        $('#lblEMRDate').text(result.DateRange);
                    }
                },
                error: function () {
                    $('#lblEMRRevenue').text('0');
                }
            });
        }

        function LoadCardFeeRevenue(period, startDate, endDate) {
            var data = { 'period': period, 'startDate': startDate || null, 'endDate': endDate || null };
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetCardFeeRevenue",
                data: JSON.stringify(data),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var result = JSON.parse(data.d);
                    if (result.Error) {
                        $('#lblCardfeeRevenue').text('0');
                        $('#lblCardfeeDate').text('Error loading data');
                    } else {
                        var formatted = parseFloat(result.OPDRevenue).toLocaleString('en-PK', {
                            minimumFractionDigits: 0,
                            maximumFractionDigits: 0
                        });
                        $('#lblCardfeeRevenue').text(formatted);
                        $('#lblCardfeeDate').text(result.DateRange);
                    }
                },
                error: function () {
                    $('#lblCardfeeRevenue').text('0');
                }
            });
        }

        function LoadPharmacyRevenue(period, startDate, endDate) {
            var data = { 'period': period, 'startDate': startDate || null, 'endDate': endDate || null };
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetPharmacyRevenue",
                data: JSON.stringify(data),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var result = JSON.parse(data.d);
                    if (result.Error) {
                        $('#lblPharmacyRevenue').text('0');
                        $('#lblPharmacyDate').text('Error loading data');
                    } else {
                        var formatted = parseFloat(result.PharmacyRevenue).toLocaleString('en-PK', {
                            minimumFractionDigits: 0,
                            maximumFractionDigits: 0
                        });
                        $('#lblPharmacyRevenue').text(formatted);
                        $('#lblPharmacyDate').text(result.DateRange);
                    }
                },
                error: function () {
                    $('#lblPharmacyRevenue').text('0');
                }
            });
        }

        function LoadPBRevenue(period, startDate, endDate) {
            var data = { 'period': period, 'startDate': startDate || null, 'endDate': endDate || null };
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetPBRevenue",
                data: JSON.stringify(data),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var result = JSON.parse(data.d);
                    if (result.Error) {
                        $('#lblPB1Revenue').text('0');
                        $('#lblPharmacyDate').text('Error loading data');
                    } else {
                        var formatted = parseFloat(result.PharmacyRevenue).toLocaleString('en-PK', {
                            minimumFractionDigits: 0,
                            maximumFractionDigits: 0
                        });
                        $('#lblPB1Revenue').text(formatted);
                        $('#lblPharmacyDate').text(result.DateRange);
                    }
                },
                error: function() {
                    $('#lblPB1Revenue').text('0');
                }
            });
        }

        function LoadLabRadiologyRevenue(period, startDate, endDate) {
            var data = { 'period': period, 'startDate': startDate || null, 'endDate': endDate || null };
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetLabRadiologyRevenue",
                data: JSON.stringify(data),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var result = JSON.parse(data.d);
                    if (result.Error) {
                        $('#lblLabRevenue').text('0');
                        $('#lblLabDate').text('Error loading data');
                    } else {
                        var formatted = parseFloat(result.LabRevenue).toLocaleString('en-PK', {
                            minimumFractionDigits: 0,
                            maximumFractionDigits: 0
                        });
                        $('#lblLabRevenue').text(formatted);
                        $('#lblLabDate').text(result.DateRange);
                    }
                },
                error: function () {
                    $('#lblLabRevenue').text('0');
                }
            });
        }

        function LoadServicesRevenue(period, startDate, endDate) {
            var data = { 'period': period, 'startDate': startDate || null, 'endDate': endDate || null };
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetServicesRevenue",
                data: JSON.stringify(data),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var result = JSON.parse(data.d);
                    if (result.Error) {
                        $('#lblServicesRevenue').text('0');
                        $('#lblServicesDate').text('Error loading data');
                    } else {
                        var formatted = parseFloat(result.LabRevenue).toLocaleString('en-PK', {
                            minimumFractionDigits: 0,
                            maximumFractionDigits: 0
                        });
                        $('#lblServicesRevenue').text(formatted);
                        $('#lblServicesDate').text(result.DateRange);
                    }
                },
                error: function () {
                    $('#lblServicesRevenue').text('0');
                }
            });
        }

        function LoadOPDChart(period, startDate, endDate) {
            var data = { 'period': period, 'startDate': startDate || null, 'endDate': endDate || null };
            return $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetOPDChartData",
                data: JSON.stringify(data),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var result = JSON.parse(data.d);
                    if (!result.Error) {
                        renderOPDSummaryChart(result.TotalPatients, result.NewOPD, result.RevisitOPD);
                    }
                }
            });
        }

        function renderOPDSummaryChart(total, newOPD, revisitOPD) {
            $('#lblOPDTotal').text(total);
            $('#lblNewOPD').text(newOPD);
            $('#lblReturnOPD').text(revisitOPD);
            if (total > 0) {
                $('#lblNewPct').text('(' + Math.round(newOPD / total * 100) + '%)');
                $('#lblReturnPct').text('(' + Math.round(revisitOPD / total * 100) + '%)');
            } else {
                $('#lblNewPct').text('');
                $('#lblReturnPct').text('');
            }

            var dom = document.querySelector("#chartOPDSummary");
            if (opdChartInstance) opdChartInstance.dispose();
            opdChartInstance = echarts.init(dom);
            var option = {
                tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
                series: [{
                    type: 'pie',
                    radius: ['55%', '75%'],
                    avoidLabelOverlap: false,
                    label: { show: false },
                    data: [
                        { value: newOPD, name: 'New Patients', itemStyle: { color: '#00C49F' } },
                        { value: revisitOPD, name: 'Returning', itemStyle: { color: '#0088FE' } }
                    ]
                }],
                graphic: [{
                    type: 'text',
                    left: 'center',
                    top: 'center',
                    style: {
                        text: total,
                        fill: '#8e0016',
                        fontSize: 16,
                        fontWeight: 'bold',
                        textAlign: 'center',
                        lineHeight: 20
                    },
                    z: 100
                }]
            };
            opdChartInstance.setOption(option);
        }

        function LoadOPDVolume(period, startDate, endDate) {
            var data = { 'period': period, 'startDate': startDate || null, 'endDate': endDate || null };
            return $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetOPDVolumeData",
                data: JSON.stringify(data),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var r = JSON.parse(response.d);
                    if (!r.Error) {
                        $('#lblTotalVolume').text(r.Total.toLocaleString());
                        $('#lblGeneralCount').text(r.GeneralCount + ' PTS');
                        $('#lblPrivateCount').text(r.PrivateCount + ' PTS');
                        $('#barGeneral').css('width', r.GeneralPerc + '%');
                        $('#barPrivate').css('width', r.PrivatePerc + '%');
                    }
                }
            });
        }

        function LoadWaitTimeTrends(period, startDate, endDate) {
            var data = { 'period': period, 'startDate': startDate || null, 'endDate': endDate || null };
            return $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetWaitTimeAndSnapshot",
                data: JSON.stringify(data),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = typeof response.d === 'string' ? JSON.parse(response.d) : response.d;
                    if (data.Error) { console.error("Dashboard Error: " + data.Error); return; }
                    $('#lblAvgGeneral').text(data.AvgGeneral);
                    $('#lblAvgPrivate').text(data.AvgPrivate);
                    $('#lblDiagCount').text(data.DiagCount);
                    $('#lblPhysioCount').text(data.PhysioCount);
                },
                error: function (xhr, status, error) { console.error("AJAX Error: " + error); }
            });
        }

        function LoadBillingData(period, startDate, endDate) {
            var data = { 'period': period, 'startDate': startDate || null, 'endDate': endDate || null };
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetBillingSnapshot",
                data: JSON.stringify(data),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var r = JSON.parse(response.d);
                    $('#lblLabOrders').text(r.LabCount);
                    $('#lblUltrasoundOrders').text(r.UltrasoundCount);
                    $('#lblXRayOrders').text(r.XRayCount);
                    $('#lblCardioOrders').text(r.CardioCount);
                    var totalDiag = r.LabCount + r.UltrasoundCount + r.XRayCount + r.CardioCount;
                    $('#lblDiagCount').text(totalDiag);
                    var dom = document.querySelector("#billingChart");
                    if (billingChartInstance) billingChartInstance.dispose();
                    billingChartInstance = echarts.init(dom);
                    var option = {
                        tooltip: { trigger: 'axis' },
                        grid: { left: 0, right: 0, top: 5, bottom: 20 },
                        xAxis: {
                            type: 'category',
                            data: ['LAB', 'U/S', 'X-RAY', 'CARDIO'],
                            axisLabel: { fontSize: 9 },
                            axisLine: { show: false },
                            axisTick: { show: false }
                        },
                        yAxis: { type: 'value', show: false, min: 0 },
                        series: [{
                            type: 'bar',
                            data: [
                                { value: r.LabCount, itemStyle: { color: '#5c6bc0' } },
                                { value: r.UltrasoundCount, itemStyle: { color: '#5c6bc0' } },
                                { value: r.XRayCount, itemStyle: { color: '#5c6bc0' } },
                                { value: r.CardioCount, itemStyle: { color: '#5c6bc0' } }
                            ],
                            barWidth: '45%',
                            itemStyle: { borderRadius: [4, 4, 0, 0] }
                        }]
                    };
                    billingChartInstance.setOption(option);
                },
                error: function () { console.error("Billing AJAX Error"); }
            });
        }

        function LoadPharmacySnapshot(period, startDate, endDate) {
            var data = { 'period': period, 'startDate': startDate || null, 'endDate': endDate || null };
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetPharmacySnapshotPB",
                data: JSON.stringify(data),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var r = JSON.parse(response.d);
                    $('#lblPhHospital').text(r.HospitalCount);
                    $('#lblPhWalkin').text(r.WalkinCount);

                    var dom = document.querySelector("#chartPharmacyDistribution");
                    if (pharmacyChartInstance) pharmacyChartInstance.dispose();
                    pharmacyChartInstance = echarts.init(dom);
                    var option = {
                        tooltip: { trigger: 'item', formatter: '{b}: {c}' },
                        legend: { bottom: 0, left: 'center', icon: 'circle', itemWidth: 8, itemHeight: 8, textStyle: { fontSize: 10 } },
                        series: [{
                            type: 'pie',
                            radius: ['45%', '60%'],
                            center: ['50%', '45%'],
                            avoidLabelOverlap: false,
                            label: { show: false },
                            data: [
                                { value: r.HospitalCount, name: 'Hospital', itemStyle: { color: '#10b981' } },
                                { value: r.WalkinCount, name: 'Walk-in', itemStyle: { color: '#94a3b8' } }
                            ]
                        }]
                    };
                    pharmacyChartInstance.setOption(option);
                }
            });
        }

        function LoadPharmacySnapshothp(period, startDate, endDate) {
            var data = { 'period': period, 'startDate': startDate || null, 'endDate': endDate || null };
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetPharmacySnapshot",
                data: JSON.stringify(data),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var r = JSON.parse(response.d);
                    $('#lblPhHospitalhp').text(r.HospitalCount);
                    $('#lblPhWalkinhp').text(r.WalkinCount);

                    var dom = document.querySelector("#chartPharmacyDistributionhp");
                    if (pharmacyChartInstancehp) pharmacyChartInstancehp.dispose();
                    pharmacyChartInstancehp = echarts.init(dom);
                    var option = {
                        tooltip: { trigger: 'item', formatter: '{b}: {c}' },
                        legend: { bottom: 0, left: 'center', icon: 'circle', itemWidth: 8, itemHeight: 8, textStyle: { fontSize: 10 } },
                        series: [{
                            type: 'pie',
                            radius: ['45%', '60%'],
                            center: ['50%', '45%'],
                            avoidLabelOverlap: false,
                            label: { show: false },
                            data: [
                                { value: r.HospitalCount, name: 'Hospital', itemStyle: { color: '#10b981' } },
                                { value: r.WalkinCount, name: 'Walk-in', itemStyle: { color: '#94a3b8' } }
                            ]
                        }]
                    };
                    pharmacyChartInstancehp.setOption(option);
                }
            });
        }

        function LoadClinicalOutcomes(period, startDate, endDate) {
            var dept = $("#ddlClinDept").val() || "0";
            var s = startDate, e = endDate, p = period;
            var ms = $("#txtClinStart").val(), me = $("#txtClinEnd").val();
            if (ms && me) { s = ms; e = me; p = 'custom'; }
            var data = { 'period': p, 'department': dept, 'startDate': s || null, 'endDate': e || null };
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetClinicalOutcomes",
                data: JSON.stringify(data),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var r = JSON.parse(response.d);
                    if (r.Error) { console.error(r.Error); return; }
                    renderClinicalOutcomes(r);
                },
                error: function () { console.error("Clinical Outcomes Error"); }
            });
        }

        function renderClinicalOutcomes(r) {
            var categories = ["IPD", "ER"];
            var ipdD = r.IPD ? r.IPD.Discharges : 0;
            var ipdR = r.IPD ? r.IPD.Referrals : 0;
            var ipdDe = r.IPD ? r.IPD.Deaths : 0;
            var erD = r.ER ? r.ER.Discharges : 0;
            var erR = r.ER ? r.ER.Referrals : 0;
            var erDe = r.ER ? r.ER.Deaths : 0;
            var discharges = [ipdD, erD];
            var referrals = [ipdR, erR];
            var deaths = [ipdDe, erDe];
            var dom = document.querySelector("#chartClinicalOutcomes");
            if (clinicalChartInstance) clinicalChartInstance.dispose();
            clinicalChartInstance = echarts.init(dom);
            var option = {
                tooltip: { trigger: 'axis', formatter: function (params) {
                    var s = params[0].axisValue + '<br/>';
                    params.forEach(function (p) { s += p.marker + ' ' + p.seriesName + ': ' + p.value + '<br/>'; });
                    return s;
                } },
                legend: { data: ['Discharges', 'Referrals', 'Deaths'], top: 0, right: 0, icon: 'circle', itemWidth: 6, itemHeight: 6, textStyle: { fontSize: 9 } },
                grid: { left: 28, right: 5, top: 20, bottom: 5 },
                xAxis: {
                    type: 'category',
                    data: categories,
                    axisLine: { show: false },
                    axisTick: { show: false },
                    axisLabel: { fontSize: 10, fontWeight: 600 }
                },
                yAxis: { type: 'value', show: false, min: 0 },
                series: [
                    { name: 'Discharges', type: 'bar', data: discharges, itemStyle: { color: '#10b981', borderRadius: [2,2,0,0] }, barWidth: 14, barGap: '10%' },
                    { name: 'Referrals', type: 'bar', data: referrals, itemStyle: { color: '#f97316', borderRadius: [2,2,0,0] }, barWidth: 14 },
                    { name: 'Deaths', type: 'bar', data: deaths, itemStyle: { color: '#ef4444', borderRadius: [2,2,0,0] }, barWidth: 14 }
                ]
            };
            clinicalChartInstance.setOption(option);
        }

        function LoadDeptStatsCharts(period, startDate, endDate) {
            var today = new Date();
            if (period === "today" || period === "yesterday") {
                if (period === "yesterday") today.setDate(today.getDate() - 1);
                startDate = $.datepicker.formatDate('MM d, yy', today);
                endDate = startDate;
            } else if (period === "custom" && startDate && endDate) {
                var ps = startDate.split("/"), pe = endDate.split("/");
                startDate = $.datepicker.formatDate('MM d, yy', new Date(ps[2], ps[1] - 1, ps[0]));
                endDate = $.datepicker.formatDate('MM d, yy', new Date(pe[2], pe[1] - 1, pe[0]));
            } else if (!startDate || !endDate) {
                startDate = $.datepicker.formatDate('MM d, yy', today);
                endDate = startDate;
            }
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetOPDDepartmentWise",
                data: JSON.stringify({ txt_sdate: startDate, txt_edate: endDate }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var parsedData = typeof response.d === 'string' ? JSON.parse(response.d) : response.d;
                    if (parsedData && parsedData.Error) { console.error("Dept Stats Error:", parsedData.Error); return; }
                    var labels = [], counts = [];
                    if (parsedData && parsedData.length > 0) {
                        labels = parsedData.map(function (item) { return item.Department_Name; });
                        counts = parsedData.map(function (item) { return parseFloat(item.OPD_Count) || 0; });
                    }
                    var colors = ['#2E93fA', '#66DA26', '#FF9800', '#FF4560', '#546E7A', '#00E396', '#FEB019', '#A45DE8', '#26a69a', '#FF9F43'];
                    var chartData = labels.length > 0 ? labels.map(function (l, i) {
                        return { value: counts[i], name: l, itemStyle: { color: colors[i % colors.length] } };
                    }) : [{ value: 1, name: 'No Data', itemStyle: { color: '#e5e7eb' } }];

                    if (deptPctChart) deptPctChart.dispose();
                    deptPctChart = echarts.init(document.querySelector("#chartDeptPct"));
                    deptPctChart.setOption({
                        tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
                        series: [{
                            type: 'pie', radius: ['45%', '75%'], center: ['50%', '50%'],
                            avoidLabelOverlap: false,
                            label: {
                                show: labels.length > 0,
                                formatter: function (p) { return Math.round(p.percent) + '%'; },
                                fontSize: 11, fontWeight: 'bold', color: '#000'
                            },
                            labelLine: { show: labels.length > 0 },
                            data: chartData
                        }]
                    });

                    if (deptCountChart) deptCountChart.dispose();
                    deptCountChart = echarts.init(document.querySelector("#chartDeptCount"));
                    deptCountChart.setOption({
                        tooltip: { trigger: 'item', formatter: '{b}: {c}' },
                        series: [{
                            type: 'pie', radius: ['45%', '75%'], center: ['50%', '50%'],
                            avoidLabelOverlap: false,
                            label: { show: labels.length > 0, formatter: function (p) { return p.value; }, fontSize: 11, fontWeight: 'bold', color: '#000' },
                            labelLine: { show: labels.length > 0 },
                            data: chartData
                        }]
                    });
                },
                error: function (xhr, status, error) {
                    console.error("Dept Stats AJAX Error:", status, error, xhr.responseText);
                }
            });

            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetDoctorWise",
                data: JSON.stringify({ txt_sdate: startDate, txt_edate: endDate }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var parsedData = typeof response.d === 'string' ? JSON.parse(response.d) : response.d;
                    if (parsedData && parsedData.Error) { console.error("Doctor Stats Error:", parsedData.Error); return; }
                    var dLabels = [], dCounts = [];
                    if (parsedData && parsedData.length > 0) {
                        parsedData.forEach(function (item) {
                            var n = item.Doctor_Name ? item.Doctor_Name.trim() : '';
                            if (n !== '') { dLabels.push(n); dCounts.push(parseFloat(item.Total_Count) || 0); }
                        });
                    }
                    var colors = ['#2E93fA', '#66DA26', '#FF9800', '#FF4560', '#546E7A', '#00E396', '#FEB019', '#A45DE8', '#26a69a', '#FF9F43'];
                    var docData = dLabels.length > 0 ? dLabels.map(function (l, i) {
                        return { value: dCounts[i], name: l, itemStyle: { color: colors[i % colors.length] } };
                    }) : [{ value: 1, name: 'No Data', itemStyle: { color: '#e5e7eb' } }];

                    if (deptDoctorChart) deptDoctorChart.dispose();
                    deptDoctorChart = echarts.init(document.querySelector("#chartDeptDoctor"));
                    deptDoctorChart.setOption({
                        tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
                        legend: { bottom: 0, left: 'center', type: 'scroll', icon: 'circle', itemWidth: 8, itemHeight: 8, textStyle: { fontSize: 9 }, pageIconSize: 10 },
                        series: [{
                            type: 'pie', radius: ['45%', '75%'], center: ['50%', '45%'],
                            avoidLabelOverlap: false,
                            label: {
                                show: dLabels.length > 0,
                                formatter: function (p) {
                                    return p.name.length > 18 ? p.name.substring(0, 17) + '…' : p.name;
                                },
                                fontSize: 10, fontWeight: 'bold', color: '#000'
                            },
                            labelLine: { show: dLabels.length > 0 },
                            data: docData
                        }]
                    });
                },
                error: function (xhr, status, error) {
                    console.error("Doctor Stats AJAX Error:", status, error, xhr.responseText);
                }
            });
        }

        function renderSatisfaction() {
            var dom = document.querySelector("#chartSatisfaction");
            if (satisfactionChartInstance) satisfactionChartInstance.dispose();
            satisfactionChartInstance = echarts.init(dom);
            var option = {
                tooltip: { trigger: 'item', formatter: '{b}: {c}%' },
                series: [{
                    type: 'pie',
                    radius: ['30%', '80%'],
                    center: ['50%', '50%'],
                    avoidLabelOverlap: false,
                    label: { show: false },
                    data: [
                        { value: 75, name: 'Satisfied', itemStyle: { color: '#10b981' } },
                        { value: 18, name: 'Neutral', itemStyle: { color: '#f59e0b' } },
                        { value: 7, name: 'Unsatisfied', itemStyle: { color: '#ef4444' } }
                    ]
                }]
            };
            satisfactionChartInstance.setOption(option);
        }

        function LoadDialysisLive(period, startDate, endDate) {
            var loadData = { 'period': period, 'startDate': startDate || null, 'endDate': endDate || null };
            let periodLabel = "Today's Snapshot";
            if (period === 'week') periodLabel = "Weekly Overview";
            if (period === 'month') periodLabel = "Monthly Overview";
            $('#lblPeriodText').text(periodLabel);

            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetDialysisSnapshot",
                data: JSON.stringify(loadData),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    const data = JSON.parse(response.d);
                    $('#txtActiveCount').text(data.ActiveSessions);
                    $('#txtPerformedCount').text(data.PerformedToday);
                    $('#lblLargeActive').text(data.ActiveNow);
                    let maxVal = data.PerformedToday > 0 ? data.PerformedToday : 10;
                    let activeWidth = (data.ActiveSessions / maxVal) * 100;
                    $('#barActive').css('width', Math.min(activeWidth, 100) + '%');
                    $('#barPerformed').css('width', '100%');
                },
                error: function () { console.error("Dialysis AJAX Error"); }
            });
        }

        function LoadRegionalHeatmap(period, startDate, endDate) {
            var data = { 'period': period, 'startDate': startDate || null, 'endDate': endDate || null };
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetRegionalHeatmap",
                data: JSON.stringify(data),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    const data = JSON.parse(response.d);
                    const container = $('#heatmapContainer');
                    container.empty();
                    if (data.length === 0) {
                        container.append('<div style="text-align:center;padding:20px;color:#94a3b8;">No data available for this period</div>');
                        return;
                    }
                    const maxCount = data[0].Counts;
                    data.forEach(item => {
                        const percentage = (item.Counts / maxCount) * 100;
                        const rowHtml = `
                            <div class="heat-row">
                                <span class="heat-label" title="${item.AreaName}">${item.AreaName}</span>
                                <div class="heat-bar-bg">
                                    <div class="heat-bar-fill" style="width:${percentage}%"></div>
                                </div>
                                <span class="heat-count">${item.Counts}</span>
                            </div>`;
                        container.append(rowHtml);
                    });
                },
                error: function () { console.error("Heatmap Error"); }
            });
        }

        function renderSparkline(id, values, labels) {
            var el = document.getElementById(id);
            if (!el) return;
            if (_sparkCharts[id]) _sparkCharts[id].dispose();
            var chart = echarts.init(el);
            _sparkCharts[id] = chart;
            var up = values.length > 1 && values[values.length-1] >= values[values.length-2];
            var pts = values.map(function(v,i){
                if (i === values.length-1) return {value:v, itemStyle:{color:up?'#3b82f6':'#ef4444'}};
                return {value:v, itemStyle:{color:'#3b82f6'}};
            });
            var cum = [], s = 0;
            values.forEach(function(v){ s += v; cum.push(s); });
            chart.setOption({
                grid: { left:0, right:0, top:0, bottom:0 },
                xAxis: { show:false, type:'category', data:labels },
                yAxis: { show:false, min:function(v){return Math.max(0,v.min-(v.max-v.min)*0.15);} },
                tooltip: {
                    trigger:'item', confine:false, z:9999,
                    extraCssText:'z-index:99999;background:#fff;border:1px solid #d1d5db;border-radius:6px;box-shadow:0 4px 12px rgba(0,0,0,0.15);pointer-events:none;',
                    formatter:function(p){
                        var i = p.dataIndex;
                        var fmt = function(n){ return Math.round(n).toLocaleString(); };
                        return '<div style="font-size:12px;line-height:1.6;padding:8px 12px;background:#fff;">' +
                            '<b>' + labels[i] + '</b>: RS ' + fmt(values[i]) + '<br/>' +
                            labels[0] + '\u2013' + labels[i] + ': <b>RS ' + fmt(cum[i]) + '</b></div>';
                    }
                },
                series: [{
                    type:'line', data:pts, smooth:false, showSymbol:true, symbolSize:5,
                    lineStyle:{width:2.5,color:'#3b82f6'},
                    animation:false
                }]
            });
        }

        function checkBlink(id, values) {
            if (values.length < 4) return;
            var last = values.length - 1;
            var recent = (values[last] + values[last-1]) / 2;
            var prior = values.slice(0, last-1).reduce(function(a,b){return a+b;},0) / (values.length - 2);
            if (recent > 0 && recent < prior * 0.85)
                $("#" + id).closest(".rev-item").addClass("blink-red");
        }

        function loadRevenueTrends(period, startDate, endDate) {
            $.ajax({
                type:"POST",
                url:"Chief_Executive_Dashboard.aspx/GetRevenueTrends",
                data:JSON.stringify({period:period, startDate:startDate||null, endDate:endDate||null}),
                contentType:"application/json; charset=utf-8",
                dataType:"json",
                success:function(res){
                    var d = JSON.parse(res.d);
                    if (d.Error) return;
                    renderSparkline("sparkRevenue", d.hospital, d.labels);
                    renderSparkline("sparkOPD", d.opd, d.labels);
                    renderSparkline("sparkEMR", d.EMR, d.labels);
                    renderSparkline("sparkCard", d.card, d.labels);
                    renderSparkline("sparkPharmacy", d.pharmacy, d.labels);
                    renderSparkline("sparkPB", d.PB, d.labels);
                    renderSparkline("sparkLab", d.lab, d.labels);
                    renderSparkline("sparkServices", d.Services, d.labels);
                    checkBlink("sparkRevenue", d.hospital);
                    checkBlink("sparkOPD", d.opd);
                    checkBlink("sparkEMR", d.EMR);
                    checkBlink("sparkCard", d.card);
                    checkBlink("sparkPharmacy", d.pharmacy);
                    checkBlink("sparkPB", d.PB);
                    checkBlink("sparkLab", d.lab);
                    checkBlink("sparkServices", d.Services);
                }
            });
        }

        function fmt(n) { return parseFloat(n).toLocaleString('en-PK', { minimumFractionDigits: 2, maximumFractionDigits: 2 }); }

        function loadYearSelect(selId) {
            var y = new Date().getFullYear();
            var opts = '';
            for (var i = y; i >= y - 10; i--) opts += '<option value="' + i + '">' + i + '</option>';
            $('#' + selId).html(opts).val(y);
        }

        function loadSummaryCards() {
            var y = new Date().getFullYear();
            var m = new Date().getMonth();
            var months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
            var curMon = months[m];
            var warehouse = $('#ddlWarehouse').val() || '0';
            var pharmacyWarehouse = $('#ddlWarehousepharmacy').val() || '0';


            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetYearlyInventorySummary",
                data: JSON.stringify({ year: y, warehouse: warehouse }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var data = JSON.parse(res.d);
                    if (data.Error) return;
                    $('#invBadge').text('Month-end Closing (' + curMon + ')');
                    var openingRow, purchaseRow, purchaseRetRow, saleRow, closingRow;
                    data.forEach(function (r) {
                        if (r.Metric === 'Opening_Value') openingRow = r;
                        else if (r.Metric === 'Purchase_Value') purchaseRow = r;
                        else if (r.Metric === 'PurchaseReturn_Value') purchaseRetRow = r;
                        else if (r.Metric === 'Sale_Value') saleRow = r;
                        else if (r.Metric === 'Closing_Value') closingRow = r;
                    });
                    $('#invOpening').text('Rs. ' + fmt(openingRow ? (openingRow[curMon] || 0) : 0));
                    $('#invPurchase').text('Rs. ' + fmt(purchaseRow ? (purchaseRow[curMon] || 0) : 0));
                    $('#invPurchaseReturn').text('Rs. ' + fmt(purchaseRetRow ? (purchaseRetRow[curMon] || 0) : 0));
                    $('#invSale').text('Rs. ' + fmt(saleRow ? (saleRow[curMon] || 0) : 0));
                    $('#invClosing').text('Rs. ' + fmt(closingRow ? (closingRow[curMon] || 0) : 0));
                }
            });

            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetYearlyPharmacySummary",
                data: JSON.stringify({ year: y, warehouse: pharmacyWarehouse }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var data = JSON.parse(res.d);
                    if (data.Error) return;
                    var openingRow, purchaseRow, saleRow, closingRow;
                    data.forEach(function (r) {
                        if (r.Metric === 'Opening_Value') openingRow = r;
                        else if (r.Metric === 'Purchase_Value') purchaseRow = r;
                        else if (r.Metric === 'Sale_Value') saleRow = r;
                        else if (r.Metric === 'Closing_Value') closingRow = r;
                    });
                    var po = openingRow ? (openingRow[curMon]||0) : 0;
                    var pp = purchaseRow ? (purchaseRow[curMon]||0) : 0;
                    var ps = saleRow ? (saleRow[curMon]||0) : 0;
                    var pc = closingRow ? (closingRow[curMon]||0) : 0;
                    $('#pharmOpening').text('Rs. ' + fmt(po));
                    $('#pharmPurchase').text('Rs. ' + fmt(pp));
                    $('#pharmSale').text('Rs. ' + fmt(ps));
                    $('#pharmClosing').text('Rs. ' + fmt(pc));
                }
            });

            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetYearlyPharmacyRevenue",
                data: JSON.stringify({ year: y, warehouse: pharmacyWarehouse }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var data = JSON.parse(res.d);
                    if (data.Error) return;
                    $('#revBadge').text('Month-end Closing (' + curMon + ')');

                    var grossRow, discRow, adjRow, retRow, netRow, cogsRow, gpRow;
                    data.forEach(function (r) {
                        if (r.Metric === 'Gross_Sale') grossRow = r;
                        else if (r.Metric === 'Discount_Value') discRow = r;
                        else if (r.Metric === 'Adjustment_Value') adjRow = r;
                        else if (r.Metric === 'SaleReturn') retRow = r;
                        else if (r.Metric === 'Net_Sale') netRow = r;
                        else if (r.Metric === 'CGS_Value') cogsRow = r;
                        else if (r.Metric === 'Gross_Profit') gpRow = r;
                    });

                    var gs = grossRow ? (grossRow[curMon] || 0) : 0;
                    var dc = discRow ? (discRow[curMon] || 0) : 0;
                    var ad = adjRow ? (adjRow[curMon] || 0) : 0;
                    var rt = retRow ? (retRow[curMon] || 0) : 0;
                    var ns = netRow ? (netRow[curMon] || 0) : 0;
                    var cg = cogsRow ? (cogsRow[curMon] || 0) : 0;
                    var gp = gpRow ? (gpRow[curMon] || 0) : 0;

                    $('#revGrossSale').text('Rs. ' + fmt(gs));
                    $('#revDiscount').text('Rs. ' + fmt(dc));
                    $('#revAdjustment').text('Rs. ' + fmt(ad));
                    $('#revSaleReturn').text('Rs. ' + fmt(rt));
                    $('#revNetSale').text('Rs. ' + fmt(ns));
                    $('#revCogs').text('Rs. ' + fmt(cg));
                    $('#revGrossProfit').text('Rs. ' + fmt(gp));
                }
            });
        }

        function buildFullYearTable(tblId, data, metricLabels) {
            var allMonths = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
            var maxMonth = new Date().getMonth();
            var months = allMonths.slice(0, maxMonth + 1);
            var $tbl = $('#' + tblId);
            $tbl.find('thead').empty();
            $tbl.find('tbody').empty();

            var hdr = '<tr><th style="text-align:left;">Metric</th>';
            months.forEach(function (m) { hdr += '<th>' + m + '</th>'; });
            hdr += '</tr>';
            $tbl.find('thead').append(hdr);

            data.forEach(function (r) {
                var label = metricLabels[r.Metric] || r.Metric.replace(/_/g, ' ');
                var row = '<tr><td class="metric-label">' + label + '</td>';
                months.forEach(function (m) {
                    var v = r[m] !== null && r[m] !== undefined ? parseFloat(r[m]) : 0;
                    row += '<td>' + fmt(v) + '</td>';
                });
                row += '</tr>';
                $tbl.find('tbody').append(row);
            });
        }

        function openInventoryModal() {
            $('#invModal').addClass('open');
            loadYearSelect('invYear');
            loadInventoryModal();
        }
        function closeInventoryModal() { $('#invModal').removeClass('open'); }
        function loadInventoryModal() {
            var y = $('#invYear').val();
            var warehouse = $('#ddlWarehouse').val() || '0';
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetYearlyInventorySummary",
                data: JSON.stringify({ year: parseInt(y), warehouse: warehouse }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var data = JSON.parse(res.d);
                    if (data.Error) return;
                    buildFullYearTable('tblInventory', data, {
                        'Opening_Value': 'Opening Value',
                        'Purchase_Value': 'Purchase Value',
                        'PurchaseReturn_Value': 'Purchase Return',
                        'Sale_Value': 'Sale Value',
                        'Closing_Value': 'Closing Value'
                    });
                }
            });
        }

        function openPharmacyModal() {
            $('#pharmModal').addClass('open');
            loadYearSelect('pharmYear');
            loadPharmacyModal();
        }
        function closePharmacyModal() { $('#pharmModal').removeClass('open'); }
        function loadPharmacyModal() {
            var y = $('#pharmYear').val();
            var pharmacyWarehouse = $('#ddlWarehousepharmacy').val() || '0';
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetYearlyPharmacySummary",
                data: JSON.stringify({ year: parseInt(y), warehouse: pharmacyWarehouse }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var data = JSON.parse(res.d);
                    if (data.Error) return;
                    buildFullYearTable('tblPharmacy', data, {
                        'Opening_Value': 'Opening Stock Value',
                        'Purchase_Value': 'Purchase Value',
                        'Sale_Value': 'Sale Value',
                        'Closing_Value': 'Closing Value'
                    });
                }
            });
        }

        function openPharmacyPBModal() {
            $('#pharmModal').addClass('open');
            loadYearSelect('pharmYear');
            loadPharmacyPBModal();
        }
        function closePharmacyPBModal() { $('#pharmModal').removeClass('open'); }
        function loadPharmacyPBModal() {
            var y = $('#pharmYear').val();
            var pharmacyWarehouse = $('#ddlWarehousepharmacy').val() || '0';
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetYearlyPharmacySummaryPB",
                data: JSON.stringify({ year: parseInt(y), warehouse: pharmacyWarehouse }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var data = JSON.parse(res.d);
                    if (data.Error) return;
                    buildFullYearTable('tblPharmacy', data, {
                        'Opening_Value': 'Opening Stock Value',
                        'Purchase_Value': 'Purchase Value',
                        'Sale_Value': 'Sale Value',
                        'Closing_Value': 'Closing Value'
                    });
                }
            });
        }

        function openRevenueModal() {
            $('#revModal').addClass('open');
            loadYearSelect('revYear');
            loadRevenueModal();
        }
        function closeRevenueModal() { $('#revModal').removeClass('open'); }
        function loadRevenueModal() {
            var y = $('#revYear').val();
            var pharmacyWarehouse = $('#ddlWarehousepharmacy').val() || '0';
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetYearlyPharmacyRevenue",
                data: JSON.stringify({ year: parseInt(y), warehouse: pharmacyWarehouse }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var data = JSON.parse(res.d);
                    if (data.Error) return;
                    buildFullYearTable('tblRevenue', data, {
                        'Gross_Sale': 'Gross Sale',
                        'Discount_Value': 'Discount',
                        'Adjustment_Value': 'Adjustment',
                        'SaleReturn': 'Sale Return',
                        'Net_Sale': 'Net Sale',
                        'CGS_Value': 'COGS',
                        'Gross_Profit': 'Gross Profit'
                    });
                }
            });
        }

        function FillWarehouse() {
            var optionInv = '';
            PageMethods.fillWarehouse(function (Tests) {
                optionInv = '<option value="0">Please Select</option>';
                var parsedTests = JSON.parse(Tests);

                $.each(parsedTests, function (key, value) {
                    optionInv += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddlWarehouse').html(optionInv);

                
                if ($('#ddlWarehouse option[value="008"]').length > 0) {
                    $('#ddlWarehouse').val("008");
                    $('#ddlWarehouse').trigger('change');
                } else {
                    var firstVal = $('#ddlWarehouse option:not([value="0"])').first().val();
                    if (firstVal) {
                        $('#ddlWarehouse').val(firstVal);
                        $('#ddlWarehouse').trigger('change');
                    }
                }
            });
        }

        function FillWarehousePharmacy() {
            var optionInv = '';
            PageMethods.fillWarehouse(function (Tests) {
                optionInv = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {

                    if (value.DataValueName === "008" || value.DataValueName === "009") {
                        optionInv += '<option value="' + value.DataValueName + '">' +
                            value.DataValueDescription +
                            '</option>';
                    }
                });

                $('#ddlWarehousepharmacy').html(optionInv);
            });
        }
    </script>

    <style type="text/css">
        .bento-grid {
            display: grid;
            grid-template-columns: 0.9fr 1.8fr 1fr 1fr;
            gap: 12px;
            grid-template-areas:
                "period period period period"
                "left opd opd dia"
                "left dept dept hp"
                "left trend trend ph"
                "left trend trend lab";
        }
        #left-stack { grid-area: left; align-self: start; display: flex; flex-direction: column; gap: 10px; }
        #left-stack .rev-item { min-height: auto; }
        #left-stack .rev-item .rev-label {
            font-size: 10px;
            color: #6b7280;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 4px;
        }
        #left-stack .rev-item .rev-value {
            font-size: 19px;
            font-weight: 700;
            color: #111827;
        }
        #left-stack .rev-item .rev-date {
            display: none;
        }
        .bento-item {
            background: #fff;
            border-radius: 10px;
            padding: 14px;
            border: 1px solid #f0f0f0;
            transition: box-shadow 0.25s ease, transform 0.25s ease, border-color 0.25s ease;
        }
        .bento-item:hover {
            box-shadow: 0 8px 25px rgba(0,0,0,0.08);
            border-color: #e5e7eb;
            transform: translateY(-1px);
        }
        .bento-item.period-bar {
            grid-area: period;
            display: flex;
            align-items: center;
            gap: 12px;
            min-height: auto;
            padding: 10px 14px;
        }
        .bento-item.period-bar label {
            margin: 0;
            font-weight: 600;
            font-size: 13px;
            color: #374151;
            white-space: nowrap;
        }
        .bento-item.period-bar select {
            max-width: 180px;
        }
        .bento-item.rev-item .rev-label {
            font-size: 10px;
            color: #6b7280;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 4px;
        }
        .bento-item.rev-item .rev-value {
            font-size: 19px;
            font-weight: 700;
            color: #111827;
        }
        .bento-item.rev-item .rev-date {
            display: none;
        }
        .rev-chart { position:absolute; bottom:4px; right:4px; width:100px; height:35px; z-index:1; }
        .bento-item.rev-item { position:relative; }
        @keyframes blink-red-border {
            0%, 100% { border-color:#ef4444!important; box-shadow:0 0 8px rgba(239,68,68,0.5)!important; }
            50% { border-color:transparent!important; box-shadow:none!important; }
        }
        .rev-item.blink-red {
            animation:blink-red-border 1s infinite;
            border:2px solid #ef4444;
        }

        #opd-area { grid-area: opd; align-self: start; }
        #dept-area { grid-area: dept; align-self: start; }
        #dept-area .dept-chart-wrap { height: 220px; width: 100%; }
        #dept-area .dept-chart-wrap > div { height: 100% !important; width: 100% !important; }
        #dept-area .dept-labels { font-size: 9px; color: #6b7280; text-transform: uppercase; font-weight: 600; text-align: center; margin-top: 4px; }
        #trend-area { grid-area: trend; align-self: start; display: flex; flex-direction: column; }
        #trend-area .main-inner { flex: 1; }
        #trend-area .heat-card {
            margin-top: 12px;
            padding: 12px;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            background: #fff;
            transition: box-shadow 0.2s;
        }
        #trend-area .heat-card:hover {
            box-shadow: 0 1px 4px rgba(0,0,0,0.08);
            border-color: #d1d5db;
        }
        .main-heading {
            font-size: 14px;
            font-weight: 700;
            color: #1f2937;
            margin-bottom: 8px;
        }
        .main-inner {
            display: flex;
            gap: 10px;
            align-items: stretch;
        }
        .main-sub {
            flex: 1;
            background: #f9fafb;
            border-radius: 8px;
            padding: 8px;
            display: flex;
            flex-direction: column;
        }
        .main-sub .ms-title {
            font-size: 11px;
            font-weight: 700;
            color: #374151;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 4px;
        }

        .hub-stats-top {
            display: flex;
            gap: 8px;
            margin-bottom: 6px;
        }
        .hub-stat-box {
            flex: 1;
            text-align: center;
            padding: 4px 6px;
            border-radius: 6px;
            background: #fff;
        }
        .hub-stat-box .hs-label {
            font-size: 9px;
            color: #6b7280;
            text-transform: uppercase;
            font-weight: 600;
        }
        .hub-stat-box .hs-value {
            font-size: 16px;
            font-weight: 700;
        }
        .hub-stat-box .hs-value.total-c { color: #8e0016; }
        .hub-stat-box .hs-value.new-c { color: #00C49F; }
        .hub-stat-box .hs-value.return-c { color: #0088FE; }
        .hub-stat-box .hs-pct {
            font-size: 9px;
            color: #9ca3af;
            margin-left: 2px;
        }
        .hub-chart-wrap {
            height: 100px;
            width: 100%;
        }

        .vol-sub .vs-number {
            font-size: 20px;
            font-weight: 700;
            color: #111827;
            margin-bottom: 2px;
        }
        .vol-sub .vs-visits {
            font-size: 9px;
            color: #9ca3af;
            text-transform: uppercase;
            margin-bottom: 8px;
        }
        .vol-bar-group { margin-bottom: 6px; }
        .vol-bar-group:last-child { margin-bottom: 0; }
        .vol-bar-header {
            display: flex;
            justify-content: space-between;
            font-size: 10px;
            font-weight: 600;
            margin-bottom: 3px;
            color: #4b5563;
        }
        .vol-bar-track {
            background: #e5e7eb;
            height: 6px;
            border-radius: 3px;
            overflow: hidden;
        }
        .vol-bar-fill {
            height: 100%;
            border-radius: 3px;
            transition: width 0.5s;
        }
        .vol-bar-fill.general { background: #3b71ca; }
        .vol-bar-fill.private { background: #9fa8da; }

        .wtf-row {
            display: flex;
            justify-content: space-between;
            font-size: 11px;
            color: #4b5563;
            margin-bottom: 4px;
        }
        .wtf-row .wtf-label { color: #6b7280; }
        .wtf-row .wtf-value { font-weight: 700; color: #00234b; }
        .wtf-divider {
            border: none;
            border-top: 1px solid #e5e7eb;
            margin: 6px 0;
        }
        .footfall-pills {
            display: flex;
            gap: 6px;
            flex-wrap: wrap;
        }
        .footfall-pill {
            border: 1px solid #e5e7eb;
            border-radius: 14px;
            padding: 2px 10px;
            font-size: 10px;
            font-weight: 600;
            background: #fff;
            color: #374151;
            display: flex;
            align-items: center;
        }
        .footfall-pill .dot {
            width: 5px;
            height: 5px;
            border-radius: 50%;
            margin-right: 5px;
        }
        .footfall-pill .dot.diag { background: #3b71ca; }
        .footfall-pill .dot.physio { background: #9fa8da; }

        .trend-sub .ts-badge {
            font-size: 9px;
            color: #8e0016;
            background: #fce4ec;
            padding: 1px 8px;
            border-radius: 10px;
            display: inline-block;
            align-self: flex-start;
            margin-bottom: 8px;
            font-weight: 600;
        }
        .trend-sub .ts-metrics {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 5px;
        }
        .trend-sub .ts-row {
            display: flex;
            justify-content: space-between;
            font-size: 11px;
            padding: 4px 6px;
            background: #fff;
            border-radius: 4px;
        }
        .trend-sub .ts-lbl {
            color: #6b7280;
        }
        .trend-sub .ts-val {
            font-weight: 600;
            color: #374151;
        }
        .trend-sub .ts-total {
            background: #f0fdf4;
        }
        .trend-sub .ts-total .ts-lbl {
            color: #166534;
            font-weight: 700;
        }
        .trend-sub .ts-total .ts-val {
            color: #16a34a;
        }
        .trend-sub .ts-expand {
            font-size: 9px;
            color: #2563eb;
            cursor: pointer;
            margin-top: 8px;
            align-self: flex-start;
            font-weight: 600;
        }
        .trend-sub .ts-expand:hover {
            text-decoration: underline;
        }
        #dia { grid-area: dia; align-self: start; }
        #ph { grid-area: ph; align-self: start; }
        #hp { grid-area: hp; align-self: start; }
        #lab { grid-area: lab; align-self: start; }


        .bento-item .sect-title {
            font-size: 11px;
            font-weight: 700;
            color: #374151;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 8px;
        }
        .bento-item .sect-title i { margin-right: 6px; }

        .dia-header {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 10px;
        }
        .dia-icon {
            background: #fff1f2;
            padding: 8px;
            border-radius: 8px;
            color: #e11d48;
        }
        .dia-header-text small { color: #94a3b8; font-weight: 600; font-size: 11px; display: block; }

        .dia-bar-group { margin-bottom: 10px; }
        .dia-bar-header {
            display: flex;
            justify-content: space-between;
            font-size: 11px;
            font-weight: 700;
            color: #64748b;
            text-transform: uppercase;
            margin-bottom: 5px;
        }
        .dia-bar-header .dia-count { font-size: 14px; }
        .dia-bar-track {
            background: #f1f5f9;
            height: 8px;
            border-radius: 4px;
            overflow: hidden;
        }
        .dia-bar-fill { height: 100%; border-radius: 4px; transition: width 1s; }
        .dia-bar-fill.active { background: linear-gradient(90deg, #fb7185, #e11d48); }
        .dia-bar-fill.performed { background: linear-gradient(90deg, #34d399, #10b981); }

        .dia-live-box {
            background: #fff1f2;
            border-radius: 12px;
            padding: 12px;
            border: 1px solid #ffe4e6;
            position: relative;
            overflow: hidden;
            margin-top: 10px;
        }
        .dia-live-box .live-badge {
            font-size: 10px;
            font-weight: 800;
            color: #e11d48;
            text-transform: uppercase;
            display: flex;
            align-items: center;
            gap: 6px;
            margin-bottom: 4px;
        }
        .dia-live-box .live-dot {
            width: 8px;
            height: 8px;
            background: #e11d48;
            border-radius: 50%;
            animation: pulse 1.5s infinite;
        }
        .dia-live-box .live-number {
            font-size: 36px;
            font-weight: 900;
            color: #1f2937;
            letter-spacing: -1px;
        }
        .dia-live-box .live-bg-icon {
            position: absolute;
            right: -5px;
            bottom: -5px;
            font-size: 60px;
            color: #fb7185;
            opacity: 0.1;
            transform: rotate(-15deg);
        }
        @keyframes pulse { 0%,100% { opacity: 1; } 50% { opacity: 0.3; } }

        .ph-chart-wrap { height: 130px; margin-bottom: 6px; }
        .ph-stats {
            display: flex;
            gap: 8px;
        }
        .ph-stat-box {
            flex: 1;
            background: #f9fafb;
            padding: 8px;
            border-radius: 8px;
            text-align: center;
            border: 1px solid #f3f4f6;
        }
        .ph-stat-box .ph-stat-label {
            font-size: 9px;
            color: #9ca3af;
            text-transform: uppercase;
            font-weight: 800;
            margin-bottom: 4px;
        }
        .ph-stat-box .ph-stat-value {
            font-size: 18px;
            font-weight: 800;
            color: #1f2937;
        }

        .hp-chart-wrap { height: 130px; margin-bottom: 6px; }
        .hp-stats {
            display: flex;
            gap: 8px;
        }
        .hp-stat-box {
            flex: 1;
            background: #f9fafb;
            padding: 8px;
            border-radius: 8px;
            text-align: center;
            border: 1px solid #f3f4f6;
        }
        .hp-stat-box .hp-stat-label {
            font-size: 9px;
            color: #9ca3af;
            text-transform: uppercase;
            font-weight: 800;
            margin-bottom: 4px;
        }
        .hp-stat-box .hp-stat-value {
            font-size: 18px;
            font-weight: 800;
            color: #1f2937;
        }

        #lab { grid-area: lab; }
        .lab-icon-header {
            display: flex;
            align-items: center;
            gap: 8px;
            color: #5c6bc0;
            font-weight: 700;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 12px;
        }
        .lab-chart-wrap { height: 90px; margin-bottom: 10px; }
        .lab-order-row {
            display: flex;
            justify-content: space-between;
            font-size: 11px;
            margin-bottom: 4px;
        }
        .lab-order-row .lab-order-label { color: #6b7280; font-weight: 500; }
        .lab-order-row .lab-order-value { font-weight: 700; }

        .heat-header {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 12px;
        }
        .heat-icon {
            background: #fef2f2;
            padding: 8px;
            border-radius: 8px;
            color: #ef4444;
        }
        .heat-title {
            font-size: 13px;
            font-weight: 800;
            color: #4b5563;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .heat-subtitle {
            font-size: 11px;
            color: #94a3b8;
            font-weight: 600;
        }
        .heat-row {
            display: grid;
            grid-template-columns: 120px 1fr 40px;
            align-items: center;
            gap: 14px;
            margin-bottom: 6px;
        }
        .heat-label {
            font-size: 12px;
            font-weight: 700;
            color: #64748b;
            text-overflow: ellipsis;
            white-space: nowrap;
            overflow: hidden;
        }
        .heat-bar-bg {
            width: 100%;
            background: #f8fafc;
            height: 10px;
            border-radius: 5px;
            overflow: hidden;
        }
        .heat-bar-fill {
            height: 100%;
            background: #6366f1;
            border-radius: 5px;
            transition: width 1s ease;
        }
        .heat-count {
            font-size: 12px;
            font-weight: 800;
            color: #1e293b;
            text-align: right;
        }

        .period-pills {
            display: flex;
            gap: 6px;
        }
        .period-pill {
            border: 1px solid #d1d5db;
            border-radius: 20px;
            padding: 4px 16px;
            font-size: 12px;
            font-weight: 600;
            background: #fff;
            color: #374151;
            cursor: pointer;
            transition: all 0.2s;
        }
        .period-pill:hover {
            border-color: #8e0016;
            color: #8e0016;
        }
        .period-pill.active {
            background: #8e0016;
            border-color: #8e0016;
            color: #fff;
        }
        .custom-date-range {
            display: none;
            gap: 8px;
            align-items: center;
        }
        .custom-date-range.visible {
            display: flex !important;
        }
        .ui-datepicker { z-index: 9999 !important; }

        .ts-big-number {
            font-size: 22px;
            font-weight: 900;
            color: #111827;
            margin: 6px 0 10px 0;
            line-height: 1.2;
        }
        .modal-overlay {
            display: none;
            position: fixed;
            z-index: 10000;
            left: 0; top: 0;
            width: 100%; height: 100%;
            background: rgba(0,0,0,0.5);
            overflow: auto;
        }
        .modal-overlay.open { display: flex; }
        .modal-overlay.open { display: flex; align-items: center; justify-content: center; }
        .modal-box {
            background: #fff;
            padding: 20px;
            width: 90%;
            max-width: 1000px;
            max-height: 85vh;
            border-radius: 10px;
            position: relative;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
        }
        .modal-close {
            position: absolute;
            right: 16px; top: 12px;
            font-size: 24px;
            font-weight: 700;
            color: #6b7280;
            cursor: pointer;
            line-height: 1;
        }
        .modal-close:hover { color: #111; }
        .modal-header {
            font-size: 16px;
            font-weight: 800;
            color: #1f2937;
            margin-bottom: 12px;
            padding-right: 30px;
        }
        .modal-header .year-select {
            margin-left: 12px;
            padding: 4px 8px;
            font-size: 13px;
            border: 1px solid #d1d5db;
            border-radius: 6px;
            font-weight: 600;
        }

        .modal-table-wrap {
            max-height: 65vh;
            overflow-y: auto;
        }
        .modal-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 10px;
        }
        .modal-table th {
            background: #f3f4f6;
            color: #374151;
            font-weight: 700;
            padding: 5px 3px;
            text-align: center;
            border: 1px solid #e5e7eb;
            position: sticky;
            top: 0;
        }
        .modal-table td {
            padding: 4px 3px;
            text-align: center;
            border: 1px solid #e5e7eb;
            color: #4b5563;
        }
        .modal-table tr:nth-child(even) td { background: #f9fafb; }
        .modal-table .metric-label {
            text-align: left;
            font-weight: 600;
            color: #1f2937;
        }
        .card-filter {
            display: flex;
            gap: 6px;
            align-items: center;
            margin-bottom: 8px;
            justify-content: flex-end;
        }
        .card-filter .datepicker,
        .card-filter select,
        .card-filter .btn,
        .card-filter button {
            vertical-align: middle;
        }
        .btn-trash {
            background: none !important;
            border: none !important;
            box-shadow: none !important;
            color: #ef4444;
            cursor: pointer;
            padding: 0;
            font-size: 13px;
            line-height: 1;
            display: inline;
            opacity: 0.6;
            width: auto;
            height: auto;
        }
        .btn-trash:hover { opacity: 1; }

        .card-loading { opacity: 0.35; pointer-events: none; transition: opacity 0.2s; position: relative; }
        .card-loading::after {
            content: '';
            position: absolute; inset: 50% auto auto 50%;
            width: 28px; height: 28px; margin: -14px 0 0 -14px;
            border: 3px solid #e5e7eb; border-top-color: #3b82f6;
            border-radius: 50%; animation: spin 0.7s linear infinite;
            z-index: 10;
        }
        @keyframes spin { to { transform: rotate(360deg); } }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="bento-grid">
        <div class="bento-item period-bar">
            <label>Select Period</label>
            <div class="period-pills">
                <button type="button" class="period-pill active" data-period="today">Today</button>
                <button type="button" class="period-pill" data-period="yesterday">Yesterday</button>
                <button type="button" class="period-pill" data-period="custom">Custom</button>
            </div>
            <div class="custom-date-range" style="display:none;margin-left:12px;">
                <input type="text" id="txtStartDate" class="form-control datepicker" placeholder="Start Date" style="width:130px;" readonly />
                <span style="color:#6b7280;">to</span>
                <input type="text" id="txtEndDate" class="form-control datepicker" placeholder="End Date" style="width:130px;" readonly />
                <button type="button" id="btnApplyCustom" class="btn btn-sm btn-primry">Apply</button>
            </div>
        </div>

        <div id="left-stack">
            <div class="bento-item rev-item">
                <div class="rev-label">Total Hospital Revenue</div>
                <div class="rev-value">Rs. <span id="lblRevenue">0</span></div>
                <div class="rev-chart" id="sparkRevenue"></div>
            </div>
            <div class="bento-item rev-item">
                <div class="rev-label">OPD Sale Revenue</div>
                <div class="rev-value">Rs. <span id="lblOPDRevenue">0</span></div>
                <div class="rev-chart" id="sparkOPD"></div>
            </div>
            <div class="bento-item rev-item">
                <div class="rev-label">EMR Sale Revenue</div>
                <div class="rev-value">Rs. <span id="lblEMRRevenue">0</span></div>
                <div class="rev-chart" id="sparkEMR"></div>
            </div>
            <div class="bento-item rev-item">
                <div class="rev-label">Card Fee Revenue</div>
                <div class="rev-value">Rs. <span id="lblCardfeeRevenue">0</span></div>
                <div class="rev-chart" id="sparkCard"></div>
            </div>
            <div class="bento-item rev-item">
                <div class="rev-label">Pharmacy Revenue</div>
                <div class="rev-value">Rs. <span id="lblPharmacyRevenue">0</span></div>
                <div class="rev-chart" id="sparkPharmacy"></div>
            </div>
            <div class="bento-item rev-item">
                <div class="rev-label">PB-1 Revenue</div>
                <div class="rev-value">Rs. <span id="lblPB1Revenue">0</span></div>
                <div class="rev-chart" id="sparkPB"></div>
            </div>
            <div class="bento-item rev-item">
                <div class="rev-label">Lab & Radiology Revenue</div>
                <div class="rev-value">Rs. <span id="lblLabRevenue">0</span></div>
                <div class="rev-chart" id="sparkLab"></div>
            </div>
            <div class="bento-item rev-item">
                <div class="rev-label">Services Revenue</div>
                <div class="rev-value">Rs. <span id="lblServicesRevenue">0</span></div>
                <div class="rev-chart" id="sparkServices"></div>
            </div>
            <div class="bento-item" style="padding:10px;">
                <div class="sect-title" style="margin:0 0 6px 0;">Clinical Outcomes (IPD/ER)</div>
                <select id="ddlClinDept" class="form-control" style="width:100%;font-size:10px;padding:2px 4px;height:24px;margin-bottom:6px;">
                    <option value="0">All Dept</option>
                </select>
                <div class="card-filter">
                    <input type="text" id="txtClinStart" class="form-control datepicker" placeholder="From" style="width:85px;font-size:10px;padding:2px 4px;height:24px;" readonly />
                    <span style="font-size:10px;color:#6b7280;">-</span>
                    <input type="text" id="txtClinEnd" class="form-control datepicker" placeholder="To" style="width:85px;font-size:10px;padding:2px 4px;height:24px;" readonly />
                    <button type="button" id="btnClinApply" class="btn btn-sm btn-primry" style="font-size:10px;height:24px;display:flex;align-items:center;justify-content:center;padding:0 10px;">Apply</button>
                    <button type="button" class="btn btn-sm btn-trash" id="clinTrash" title="Reset to master"><i class="fa fa-trash"></i></button>
                </div>
                <div id="chartClinicalOutcomes" style="height:130px;width:100%;"></div>
                <div style="display:flex;justify-content:space-around;margin-top:4px;font-size:10px;font-weight:700;color:#374151;">
                    <span>IPD</span>
                    <span>ER</span>
                </div>
            </div>
            <div class="bento-item" style="padding:10px;">
                <div style="display:flex;align-items:center;gap:10px;">
                    <div style="flex-shrink:0;">
                        <div style="font-size:9px;color:#6b7280;text-transform:uppercase;font-weight:600;margin-bottom:2px;">Executive Cast</div>
                        <div style="display:flex;align-items:baseline;gap:4px;">
                            <span style="font-size:32px;font-weight:900;color:#111827;line-height:1;">4.8</span>
                            <span style="color:#10b981;font-size:12px;">&#9650;</span>
                            <span style="font-size:10px;color:#10b981;font-weight:600;">Highly Satisfied</span>
                        </div>
                    </div>
                    <div style="flex:1;height:80px;"><div id="chartSatisfaction" style="height:100%;width:100%;"></div></div>
                </div>
            </div>
        </div>

        <div class="bento-item" id="opd-area">
            <div class="main-heading">OPD Operation Hub</div>
            <div class="card-filter">
                <input type="text" class="form-control datepicker" id="opdFrom" placeholder="From" style="width:85px;font-size:10px;padding:2px 4px;height:24px;" readonly />
                <span style="font-size:10px;color:#6b7280;">-</span>
                <input type="text" class="form-control datepicker" id="opdTo" placeholder="To" style="width:85px;font-size:10px;padding:2px 4px;height:24px;" readonly />
                <button type="button" class="btn btn-sm btn-primry card-apply" data-card="opd" style="font-size:10px;height:24px;display:flex;align-items:center;justify-content:center;padding:0 10px;">Apply</button>
                <button type="button" class="btn btn-sm btn-trash card-trash" data-card="opd" title="Reset to master"><i class="fa fa-trash"></i></button>
            </div>
            <div class="main-inner">
                <div class="main-sub">
                    <div class="ms-title">New vs Returning Patients</div>
                    <div class="hub-stats-top">
                        <div class="hub-stat-box">
                            <div class="hs-label">New</div>
                            <div><span class="hs-value new-c" id="lblNewOPD">0</span><span class="hs-pct" id="lblNewPct"></span></div>
                        </div>
                        <div class="hub-stat-box">
                            <div class="hs-label">Returning</div>
                            <div><span class="hs-value return-c" id="lblReturnOPD">0</span><span class="hs-pct" id="lblReturnPct"></span></div>
                        </div>
                        <div class="hub-stat-box">
                            <div class="hs-label">Total</div>
                            <div><span class="hs-value total-c" id="lblOPDTotal">0</span></div>
                        </div>
                    </div>
                    <div class="hub-chart-wrap"><div id="chartOPDSummary" style="height:100%;width:100%;"></div></div>
                </div>
                <div class="main-sub vol-sub">
                    <div class="ms-title">OPD Volume</div>
                    <div class="vs-number" id="lblTotalVolume">0</div>
                    <div class="vs-visits">Visits</div>
                    <div class="vol-bar-group">
                        <div class="vol-bar-header">
                            <span>GENERAL FC</span>
                            <span id="lblGeneralCount">0 PTS</span>
                        </div>
                        <div class="vol-bar-track">
                            <div id="barGeneral" class="vol-bar-fill general" style="width: 0%;"></div>
                        </div>
                    </div>
                    <div class="vol-bar-group">
                        <div class="vol-bar-header">
                            <span>PRIVATE FC</span>
                            <span id="lblPrivateCount">0 PTS</span>
                        </div>
                        <div class="vol-bar-track">
                            <div id="barPrivate" class="vol-bar-fill private" style="width: 0%;"></div>
                        </div>
                    </div>
                </div>
                <div class="main-sub">
                    <div class="ms-title">Wait Time Trends</div>
                    <div class="wtf-row">
                        <span class="wtf-label">AVG General (FC)</span>
                        <span class="wtf-value"><span id="lblAvgGeneral">0</span> MIN</span>
                    </div>
                    <div class="wtf-row">
                        <span class="wtf-label">AVG Private (CC)</span>
                        <span class="wtf-value"><span id="lblAvgPrivate">0</span> MIN</span>
                    </div>
                    <hr class="wtf-divider" />
                    <div class="ms-title" style="font-size:10px;margin-bottom:4px;margin-top:4px;">Footfall Snapshot</div>
                    <div class="footfall-pills">
                        <span class="footfall-pill">
                            <span class="dot diag"></span>
                            DIAG: <strong style="margin-left:3px;"><span id="lblDiagCount">0</span></strong>
                        </span>
                        <span class="footfall-pill">
                            <span class="dot physio"></span>
                            PHYSIO: <strong style="margin-left:3px;"><span id="lblPhysioCount">0</span></strong>
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <div class="bento-item" id="dept-area">
            <div class="main-heading">Department Wise Statistics</div>
            <div class="card-filter">
                <input type="text" class="form-control datepicker" id="deptFrom" placeholder="From" style="width:85px;font-size:10px;padding:2px 4px;height:24px;" readonly />
                <span style="font-size:10px;color:#6b7280;">-</span>
                <input type="text" class="form-control datepicker" id="deptTo" placeholder="To" style="width:85px;font-size:10px;padding:2px 4px;height:24px;" readonly />
                <button type="button" class="btn btn-sm btn-primry card-apply" data-card="dept" style="font-size:10px;height:24px;display:flex;align-items:center;justify-content:center;padding:0 10px;">Apply</button>
                <button type="button" class="btn btn-sm btn-trash card-trash" data-card="dept" title="Reset to master"><i class="fa fa-trash"></i></button>
            </div>
            <div class="main-inner">
                <div class="main-sub">
                    <div class="ms-title">Department Wise (Percentage)</div>
                    <div class="dept-chart-wrap"><div id="chartDeptPct" style="height:100%;width:100%;"></div></div>
                </div>
                <div class="main-sub">
                    <div class="ms-title">Department Wise (With Counts)</div>
                    <div class="dept-chart-wrap"><div id="chartDeptCount" style="height:100%;width:100%;"></div></div>
                </div>
                <div class="main-sub">
                    <div class="ms-title">Doctor Wise</div>
                    <div class="dept-chart-wrap"><div id="chartDeptDoctor" style="height:100%;width:100%;"></div></div>
                </div>
            </div>
        </div>

        <div class="bento-item" id="trend-area">
    <div class="main-heading">Trend Records &amp; Stock Analytics</div>
    
    <!-- Filter row with all selectors in one line -->
    <div class="card-filter" style="display: flex; gap: 12px; align-items: center; flex-wrap: wrap; margin-bottom: 12px;">
        <!-- Inventory Warehouse -->
        <div style="display: flex; align-items: center; gap: 6px;">
            <label id="LblWarehouse" style="font-size: 11px; font-weight: 600; color: #374151; white-space: nowrap; margin: 0;">WareHouse Inventory</label>
            <select id="ddlWarehouse" class="form-control" style="width:140px;font-size:10px;padding:2px 4px;height:26px;">
                <option value="0">Please Select</option>
            </select>
        </div>
        
        <!-- Pharmacy Warehouse -->
        <div style="display: flex; align-items: center; gap: 6px;">
            <label id="LblWarehousepharmacy" style="font-size: 11px; font-weight: 600; color: #374151; white-space: nowrap; margin: 0;">WareHouse Pharmacy</label>
            <select id="ddlWarehousepharmacy" class="form-control" style="width:140px;font-size:10px;padding:2px 4px;height:26px;">
                <option value="0">Please Select</option>
            </select>
        </div>
        
        <!-- Month Selector -->
        <div style="display: flex; align-items: center; gap: 6px;">
            <label style="font-size: 11px; font-weight: 600; color: #374151; white-space: nowrap; margin: 0;">Month</label>
            <select id="trendMonth" class="form-control" style="width:90px;font-size:10px;padding:2px 4px;height:26px;">
                <option value="">All</option>
                <option value="0">Jan</option><option value="1">Feb</option><option value="2">Mar</option>
                <option value="3">Apr</option><option value="4">May</option><option value="5">Jun</option>
                <option value="6">Jul</option><option value="7">Aug</option><option value="8">Sep</option>
                <option value="9">Oct</option><option value="10">Nov</option><option value="11">Dec</option>
            </select>
        </div>
        
        <!-- Buttons -->
        <button type="button" class="btn btn-sm btn-primry card-apply" data-card="trend" style="font-size:10px;height:26px;display:flex;align-items:center;justify-content:center;padding:0 12px;">Apply</button>
        <button type="button" class="btn btn-sm btn-trash card-trash" data-card="trend" title="Reset to master" style="font-size:13px;height:26px;display:flex;align-items:center;"><i class="fa fa-trash"></i></button>
    </div>
    
    <div class="main-inner">
        <div class="main-sub trend-sub" id="invRecordCard">
            <div class="ms-title">Inventory Record</div>
            <div class="ts-badge" id="invBadge">Month-end Closing</div>
            <div class="ts-big-number" id="invOpening">Rs. 0.00</div>
            <div class="ts-metrics" id="invMetrics">
                <div class="ts-row"><span class="ts-lbl">Purchase Value</span><span class="ts-val" id="invPurchase">Rs. 0.00</span></div>
                <div class="ts-row"><span class="ts-lbl">Purchase Return</span><span class="ts-val" id="invPurchaseReturn">Rs. 0.00</span></div>
                <div class="ts-row"><span class="ts-lbl">Sale Value</span><span class="ts-val" id="invSale">Rs. 0.00</span></div>
                <div class="ts-row ts-total"><span class="ts-lbl">Closing Value</span><span class="ts-val" id="invClosing">Rs. 0.00</span></div>
            </div>
            <div class="ts-expand" onclick="openInventoryModal()">&#9655; View Detailed Report</div>
        </div>
        
        <div class="main-sub trend-sub" id="pharmStockCard">
            <div class="ms-title">Pharmacy Stock Analytics</div>
            <div class="ts-badge" id="pharmBadge">HP</div>
            <div class="ts-big-number" id="pharmOpening">Rs. 0.00</div>
            <div class="ts-metrics" id="pharmMetrics">
                <div class="ts-row"><span class="ts-lbl">Purchase Value</span><span class="ts-val" id="pharmPurchase">Rs. 0.00</span></div>
                <div class="ts-row"><span class="ts-lbl">Sale Value</span><span class="ts-val" id="pharmSale">Rs. 0.00</span></div>
                <div class="ts-row ts-total"><span class="ts-lbl">Closing Value</span><span class="ts-val" id="pharmClosing">Rs. 0.00</span></div>
            </div>
            <div class="ts-expand" onclick="openPharmacyModal()">&#9655; Stock Movement Report</div>
        </div>
        
        <div class="main-sub trend-sub" id="pharmStockCardPB">
            <div class="ms-title">Pharmacy Stock Analytics</div>
            <div class="ts-badge" id="pharmBadgePB">PB-1</div>
            <div class="ts-big-number" id="pharmOpeningPB">Rs. 0.00</div>
            <div class="ts-metrics" id="pharmMetricsPB">
                <div class="ts-row"><span class="ts-lbl">Purchase Value</span><span class="ts-val" id="pharmPurchasePB">Rs. 0.00</span></div>
                <div class="ts-row"><span class="ts-lbl">Sale Value</span><span class="ts-val" id="pharmSalePB">Rs. 0.00</span></div>
                <div class="ts-row ts-total"><span class="ts-lbl">Closing Value</span><span class="ts-val" id="pharmClosingPB">Rs. 0.00</span></div>
            </div>
            <div class="ts-expand" onclick="openPharmacyPBModal()">&#9655; Stock Movement Report</div>
        </div>
        
<%--        <div class="main-sub trend-sub" id="revPnLCard">
            <div class="ms-title">Revenue P&amp;L Summary</div>
            <div class="ts-badge" id="revBadge">Month-end Closing</div>
            <div class="ts-big-number" id="revGrossSale">Rs. 0.00</div>
            <div class="ts-metrics" id="revMetrics">
                <div class="ts-row"><span class="ts-lbl">Discount</span><span class="ts-val" id="revDiscount">Rs. 0.00</span></div>
                <div class="ts-row"><span class="ts-lbl">Adjustment</span><span class="ts-val" id="revAdjustment">Rs. 0.00</span></div>
                <div class="ts-row"><span class="ts-lbl">Sale Return</span><span class="ts-val" id="revSaleReturn">Rs. 0.00</span></div>
                <div class="ts-row"><span class="ts-lbl">Net Sale</span><span class="ts-val" id="revNetSale">Rs. 0.00</span></div>
                <div class="ts-row"><span class="ts-lbl">COGS</span><span class="ts-val" id="revCogs">Rs. 0.00</span></div>
                <div class="ts-row ts-total"><span class="ts-lbl">Gross Profit</span><span class="ts-val" id="revGrossProfit">Rs. 0.00</span></div>
            </div>
            <div class="ts-expand" onclick="openRevenueModal()">&#9655; View 12-Month Report</div>
        </div>--%>
    </div>
    
    <div class="heat-card">
        <div class="heat-header">
            <div class="heat-icon"><i class="fa fa-map-marker"></i></div>
            <div>
                <div class="heat-title">Regional Patient Heatmap</div>
                <div class="heat-subtitle">Distribution by Location</div>
            </div>
        </div>
        <div class="card-filter">
            <input type="text" class="form-control datepicker" id="heatFrom" placeholder="From" style="width:85px;font-size:10px;padding:2px 4px;height:24px;" readonly />
            <span style="font-size:10px;color:#6b7280;">-</span>
            <input type="text" class="form-control datepicker" id="heatTo" placeholder="To" style="width:85px;font-size:10px;padding:2px 4px;height:24px;" readonly />
            <button type="button" class="btn btn-sm btn-primry card-apply" data-card="heat" style="font-size:10px;height:24px;display:flex;align-items:center;justify-content:center;padding:0 10px;">Apply</button>
            <button type="button" class="btn btn-sm btn-trash card-trash" data-card="heat" title="Reset to master"><i class="fa fa-trash"></i></button>
        </div>
        <div id="heatmapContainer"></div>
    </div>
</div>

        <div class="bento-item" id="dia">
            <div class="dia-header">
                <div class="dia-icon"><i class="fa fa-heartbeat"></i></div>
                <div>
                    <div style="font-size: 13px; font-weight: 800; color: #4b5563; text-transform: uppercase; letter-spacing: 0.5px;">Dialysis</div>
                    <small id="lblPeriodText">Today's Snapshot</small>
                </div>
            </div>
            <div class="card-filter">
                <input type="text" class="form-control datepicker" id="diaFrom" placeholder="From" style="width:85px;font-size:10px;padding:2px 4px;height:24px;" readonly />
                <span style="font-size:10px;color:#6b7280;">-</span>
                <input type="text" class="form-control datepicker" id="diaTo" placeholder="To" style="width:85px;font-size:10px;padding:2px 4px;height:24px;" readonly />
                <button type="button" class="btn btn-sm btn-primry card-apply" data-card="dia" style="font-size:10px;height:24px;display:flex;align-items:center;justify-content:center;padding:0 10px;">Apply</button>
                <button type="button" class="btn btn-sm btn-trash card-trash" data-card="dia" title="Reset to master"><i class="fa fa-trash"></i></button>
            </div>
            <div class="dia-bar-group">
                <div class="dia-bar-header">
                    <span>Active Sessions</span>
                    <span class="dia-count" style="color:#e11d48;" id="txtActiveCount">0</span>
                </div>
                <div class="dia-bar-track">
                    <div id="barActive" class="dia-bar-fill active" style="width: 0%;"></div>
                </div>
            </div>
            <div class="dia-bar-group">
                <div class="dia-bar-header">
                    <span>Performed Sessions</span>
                    <span class="dia-count" style="color:#10b981;" id="txtPerformedCount">0</span>
                </div>
                <div class="dia-bar-track">
                    <div id="barPerformed" class="dia-bar-fill performed" style="width: 100%;"></div>
                </div>
            </div>
            <div class="dia-live-box">
                <div class="live-badge">
                    <span class="live-dot"></span> Live Now
                </div>
                <div class="live-number" id="lblLargeActive">0</div>
                <i class="fa fa-area-chart live-bg-icon"></i>
            </div>
        </div>

        <div class="bento-item" id="hp">
            <div class="sect-title"><i class="fa fa-database" style="color:#10b981;"></i>Hospital Branch</div>
            <div class="card-filter">
                <input type="text" class="form-control datepicker" id="hpFrom" placeholder="From" style="width:85px;font-size:10px;padding:2px 4px;height:24px;" readonly />
                <span style="font-size:10px;color:#6b7280;">-</span>
                <input type="text" class="form-control datepicker" id="hpTo" placeholder="To" style="width:85px;font-size:10px;padding:2px 4px;height:24px;" readonly />
                <button type="button" class="btn btn-sm btn-primry card-apply" data-card="hp" style="font-size:10px;height:24px;display:flex;align-items:center;justify-content:center;padding:0 10px;">Apply</button>
                <button type="button" class="btn btn-sm btn-trash card-trash" data-card="hp" title="Reset to master"><i class="fa fa-trash"></i></button>
            </div>
            <div class="hp-chart-wrap"><div id="chartPharmacyDistributionhp" style="height: 100%; width: 100%;"></div></div>
            <div class="hp-stats">
                <div class="hp-stat-box">
                    <div class="hp-stat-label">Hospital</div>
                    <div class="hp-stat-value" id="lblPhHospitalhp">0</div>
                </div>
                <div class="hp-stat-box">
                    <div class="hp-stat-label">Walk-in</div>
                    <div class="hp-stat-value" id="lblPhWalkinhp">0</div>
                </div>
            </div>
        </div>

        <div class="bento-item" id="ph">
            <div class="sect-title"><i class="fa fa-database" style="color:#10b981;"></i>Pharmacy Branch 1</div>
            <div class="card-filter">
                <input type="text" class="form-control datepicker" id="phFrom" placeholder="From" style="width:85px;font-size:10px;padding:2px 4px;height:24px;" readonly />
                <span style="font-size:10px;color:#6b7280;">-</span>
                <input type="text" class="form-control datepicker" id="phTo" placeholder="To" style="width:85px;font-size:10px;padding:2px 4px;height:24px;" readonly />
                <button type="button" class="btn btn-sm btn-primry card-apply" data-card="ph" style="font-size:10px;height:24px;display:flex;align-items:center;justify-content:center;padding:0 10px;">Apply</button>
                <button type="button" class="btn btn-sm btn-trash card-trash" data-card="ph" title="Reset to master"><i class="fa fa-trash"></i></button>
            </div>
            <div class="ph-chart-wrap"><div id="chartPharmacyDistribution" style="height: 100%; width: 100%;"></div></div>
            <div class="ph-stats">
                <div class="ph-stat-box">
                    <div class="ph-stat-label">Hospital</div>
                    <div class="ph-stat-value" id="lblPhHospital">0</div>
                </div>
                <div class="ph-stat-box">
                    <div class="ph-stat-label">Walk-in</div>
                    <div class="ph-stat-value" id="lblPhWalkin">0</div>
                </div>
            </div>
        </div>

        <div class="bento-item" id="lab">
            <div class="lab-icon-header"><i class="fa fa-file-text-o"></i>Lab & Radiology</div>
            <div class="card-filter">
                <input type="text" class="form-control datepicker" id="labFrom" placeholder="From" style="width:85px;font-size:10px;padding:2px 4px;height:24px;" readonly />
                <span style="font-size:10px;color:#6b7280;">-</span>
                <input type="text" class="form-control datepicker" id="labTo" placeholder="To" style="width:85px;font-size:10px;padding:2px 4px;height:24px;" readonly />
                <button type="button" class="btn btn-sm btn-primry card-apply" data-card="lab" style="font-size:10px;height:24px;display:flex;align-items:center;justify-content:center;padding:0 10px;">Apply</button>
                <button type="button" class="btn btn-sm btn-trash card-trash" data-card="lab" title="Reset to master"><i class="fa fa-trash"></i></button>
            </div>
            <div class="lab-chart-wrap"><div id="billingChart" style="height: 100%; width: 100%;"></div></div>
            <div class="lab-order-row">
                <span class="lab-order-label">LAB</span>
                <span class="lab-order-value"><span id="lblLabOrders">0</span> ORDERS</span>
            </div>
            <div class="lab-order-row">
                <span class="lab-order-label">ULTRASOUND</span>
                <span class="lab-order-value"><span id="lblUltrasoundOrders">0</span> ORDERS</span>
            </div>
            <div class="lab-order-row">
                <span class="lab-order-label">X-RAY</span>
                <span class="lab-order-value"><span id="lblXRayOrders">0</span> ORDERS</span>
            </div>
            <div class="lab-order-row">
                <span class="lab-order-label">CARDIOLOGY</span>
                <span class="lab-order-value"><span id="lblCardioOrders">0</span> ORDERS</span>
            </div>
        </div>


    </div>

    <!-- Inventory Record Modal -->
    <div class="modal-overlay" id="invModal">
        <div class="modal-box">
            <span class="modal-close" onclick="closeInventoryModal()">&times;</span>
            <div class="modal-header">
                <span>Inventory Report <select class="year-select" id="invYear" onchange="loadInventoryModal()"></select></span>
            </div>
            <div class="modal-table-wrap">
                <table class="modal-table" id="tblInventory">
                    <thead></thead>
                    <tbody></tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Pharmacy Stock Modal -->
    <div class="modal-overlay" id="pharmModal">
        <div class="modal-box">
            <span class="modal-close" onclick="closePharmacyModal()">&times;</span>
            <div class="modal-header">
                <span>Pharmacy Stock Report <select class="year-select" id="pharmYear" onchange="loadPharmacyModal()"></select></span>
            </div>
            <div class="modal-table-wrap">
                <table class="modal-table" id="tblPharmacy">
                    <thead></thead>
                    <tbody></tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Revenue P&L Modal -->
    <div class="modal-overlay" id="revModal">
        <div class="modal-box">
            <span class="modal-close" onclick="closeRevenueModal()">&times;</span>
            <div class="modal-header">
                <span>Revenue P&L Report <select class="year-select" id="revYear" onchange="loadRevenueModal()"></select></span>
            </div>
            <div class="modal-table-wrap">
                <table class="modal-table" id="tblRevenue">
                    <thead></thead>
                    <tbody></tbody>
                </table>
            </div>
        </div>
    </div>
</asp:Content>
