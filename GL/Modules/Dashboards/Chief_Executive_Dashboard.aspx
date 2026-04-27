<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Chief_Executive_Dashboard.aspx.cs" Inherits="PMS.Modules.Dashboards.Chief_Executive_Dashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
            // Initial load for both cards
            LoadHospitalRevenue("today");
            LoadOPDSaleRevenue("today");
            LoadPharmacyRevenue("today");


            $("#ddlPeriod").change(function () {
                var period = $(this).val();
                LoadHospitalRevenue(period);
                LoadOPDSaleRevenue(period);
                LoadPharmacyRevenue(period);
            });
        });

        function LoadHospitalRevenue(period) {
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetHospitalRevenue",
                data: JSON.stringify({ 'period': period }),
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
                error: function (xhr, status, error) {
                    $('#lblRevenue').text('0');
                }
            });
        }

        function LoadOPDSaleRevenue(period) {
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetOPDSaleRevenue",
                data: JSON.stringify({ 'period': period }),
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

        function LoadPharmacyRevenue(period) {
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetPharmacyRevenue",
                data: JSON.stringify({ 'period': period }),
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
    </script>

     <style type="text/css">
        .revenue-card {
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            border-left: 4px solid #28a745;
            margin: 20px 0;
        }
        .card-title { font-size: 12px; color: #6c757d; text-transform: uppercase; margin-bottom: 8px; }
        .card-value { font-size: 28px; font-weight: bold; color: #212529; }
        .card-date { font-size: 11px; color: #6c757d; margin-top: 5px; }
    </style>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-2">
            <label>Select Period</label>
            <select id="ddlPeriod" class="form-control">
                <option value="today">Today</option>
                <option value="week">This Week</option>
                <option value="month">This Month</option>
                <option value="year">This Year</option>
            </select>
        </div>
    </div>
    <div class="row">
        <div class="col-lg-3 col-md-6">
            <div class="revenue-card">
                <div class="card-title">Total Hospital Revenue</div>
                <div class="card-value">Rs. <span id="lblRevenue">0</span></div>
                <div class="card-date" id="lblRevenueDate">Loading...</div>
            </div>
        </div>
        <div class="col-lg-3 col-md-6">
        <div class="revenue-card" style="border-left-color: #007bff;"> <div class="card-title">OPD Sale Revenue</div>
            <div class="card-value">Rs. <span id="lblOPDRevenue">0</span></div>
            <div class="card-date" id="lblOPDDate">Loading...</div>
        </div>
    </div>
        <div class="col-lg-3 col-md-6">
            <div class="revenue-card" style="border-left-color: #dc3545;">
                <div class="card-title">Pharmacy Sale Revenue</div>
                <div class="card-value">Rs. <span id="lblPharmacyRevenue">0</span></div>
                <div class="card-date" id="lblPharmacyDate">Loading...</div>
            </div>
        </div>
    </div>
</asp:Content>
