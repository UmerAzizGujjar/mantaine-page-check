<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Chief_Executive_Dashboard.aspx.cs" Inherits="PMS.Modules.Dashboards.Chief_Executive_Dashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
            var today = moment().format('LL');

            $("#startDate, #EndDate").datepicker({
                dateFormat: 'MM d, yy'
            }).attr('readonly', 'readonly').val(today);
            LoadHospitalRevenue(today, today);
            $("#txtSearch").click(function () {
                var dt = $('#startDate').val();
                var dts = $('#EndDate').val();
                LoadHospitalRevenue(dt, dts);
            });
        });

        function search() {
            var dt = $('#startDate').val();
            var dts = $('#EndDate').val();
            LoadHospitalRevenue(dt, dts);
        }

        function LoadHospitalRevenue(startdate, enddate) {
            $.ajax({
                type: "POST",
                url: "Chief_Executive_Dashboard.aspx/GetHospitalRevenue",
                data: JSON.stringify({ 'txt_sdate': startdate, 'txt_edate': enddate }),
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
                        $('#lblRevenueDate').text(startdate + ' - ' + enddate);
                    }
                },
                error: function (xhr, status, error) {
                    console.error("Revenue Error: " + error);
                    $('#lblRevenue').text('0');
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
            <label>Start Date</label>
            <input type="text" id="startDate" class="form-control" />
        </div>
        <div class="col-lg-2">
            <label>End Date</label>
            <input type="text" id="EndDate" class="form-control" />
        </div>
        <div class="col-lg-1">
            <label></label>
            <input type="button" id="txtSearch" class="btn btn-primry" value="Search" onclick="search()" />
        </div>
    </div>
    <div class="row">
        <div class="col-lg-4 col-md-6">
            <div class="revenue-card">
                <div class="card-title">Total Hospital Revenue</div>
                <div class="card-value">Rs. <span id="lblRevenue">0</span></div>
                <div class="card-date" id="lblRevenueDate">Loading...</div>
            </div>
        </div>
    </div>
</asp:Content>
