<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Inventory_ProcurementDashboard.aspx.cs" Inherits="PMS.Modules.Dashboards.Inventory_ProcurementDashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">


    <style type="text/css">
    

        .dashboard-header {
            text-align: center;
            margin-bottom: 20px;
            padding: 15px;
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }

        .dashboard-header h1 {
            color: #e67e22;
            font-weight: 600;
            font-size: 1.8rem;
            margin: 0;
        }

        .dashboard-header p {
            color: #6c757d;
            font-size: 0.9rem;
            margin: 5px 0 0;
        }

        .date-controls {
            display: flex;
            gap: 15px;
            align-items: end;
            margin-bottom: 20px;
            flex-wrap: wrap;
            background: white;
            padding: 15px;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }

        .date-controls label {
            font-weight: 500;
            margin-bottom: 5px;
            display: block;
        }

        .date-controls input {
            width: 100%;
            max-width: 200px;
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 0.9rem;
        }

        .btn-search {
            background: #007bff;
            color: white;
            border: none;
            padding: 8px 20px;
            border-radius: 6px;
            font-weight: 500;
            cursor: pointer;
            transition: background 0.2s;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .btn-search:hover {
            background: #0056b3;
        }

        .card-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 16px;
            margin-top: 10px;
        }

        .stat-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.06);
            overflow: hidden;
            transition: transform 0.2s, box-shadow 0.2s;
            height: 100%;
            display: flex;
            flex-direction: column;
        }

        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 6px 16px rgba(0,0,0,0.1);
        }

        .card-header {
            padding: 12px 16px;
            font-weight: 600;
            font-size: 1.1rem;
            color: white;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .card-body {
            padding: 16px;
            flex-grow: 1;
        }

        .stat-item {
            display: flex;
            justify-content: space-between;
            padding: 6px 0;
            border-bottom: 1px dashed #eee;
            font-size: 0.95rem;
        }

        .stat-item:last-child {
            border-bottom: none;
        }

        .stat-label {
            font-weight: 500;
            color: #555;
        }

        .stat-value {
            font-weight: 600;
            color: #222;
            min-width: 40px;
            text-align: right;
        }

        .status-created { color: #ffc107; }
        .status-approved { color: #28a745; }
        .status-cancelled { color: #dc3545; }
        .status-total { color: #343a40; font-weight: 700; }

        .card-link {
            display: block;
            text-decoration: none;
            color: inherit;
            transition: opacity 0.2s;
        }

        .card-link:hover {
            opacity: 0.9;
        }

        /* Color Themes */
        .bg-pr { background: linear-gradient(135deg, #6f42c1, #9b59b6); }
        .bg-po { background: linear-gradient(135deg, #007bff, #4b7bec); }
        .bg-cs { background: linear-gradient(135deg, #fd79a8, #e84393); }
        .bg-igp { background: linear-gradient(135deg, #00cec9, #81ecec); }
        .bg-grn { background: linear-gradient(135deg, #2ecc71, #27ae60); }
        .bg-gir { background: linear-gradient(135deg, #e67e22, #d35400); }
        .bg-gin { background: linear-gradient(135deg, #f39c12, #e67e22); }

        @media (max-width: 768px) {
            .date-controls {
                flex-direction: column;
            }
            .date-controls > div {
                width: 100%;
            }
            .card-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>



    <script type="text/javascript">
        $(document).ready(function () {
            var today = moment().format('LL');
            $("#txtsdate, #txtedate").datepicker({
                dateFormat: 'MM d, yy',
                maxDate: 0
            }).val(today);

            LoadInventoryDashboard(today, today);
        });

        function search() {
            var sDate = $('#txtsdate').val().trim();
            var eDate = $('#txtedate').val().trim();
            if (!sDate || !eDate) {
                alert('Please select both start and end dates.');
                return;
            }
            LoadInventoryDashboard(sDate, eDate);
        }

        function LoadInventoryDashboard(startDate, endDate) {
            $.ajax({
                type: "POST",
                url: "Inventory_ProcurementDashboard.aspx/LaodDashBoard",
                data: JSON.stringify({ txt_sdate: startDate, txt_edate: endDate }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                beforeSend: function () {
                    $('.stat-value').text('…');
                },
                success: function (response) {
                    var data = JSON.parse(response.d);
                    var map = {};
                    data.forEach(item => map[item.Category] = item.CountValue || 0);

                    // Update values
                    $('#total_GIR').text(map['Total_GIR'] || 0);
                    $('#created_GIR').text(map['Total_GIR_Created'] || 0);
                    $('#approved_GIR').text(map['Total_GIR_Approved'] || 0);
                    $('#cancelled_GIR').text(map['Total_GIR_Cancelled'] || 0);

                    $('#total_GIN').text(map['Total_GIN'] || 0);
                    $('#created_GIN').text(map['Total_GIN_Created'] || 0);
                    $('#approved_GIN').text(map['Total_GIN_Approved'] || 0);
                    $('#cancelled_GIN').text(map['Total_GIN_Cancelled'] || 0);

                    $('#total_PR').text(map['Total_PR'] || 0);
                    $('#created_PR').text(map['Total_PR_Created'] || 0);
                    $('#approved_PR').text(map['Total_PR_Approved'] || 0);
                    $('#cancelled_PR').text(map['Total_PR_Cancelled'] || 0);

                    $('#total_CS').text(map['Total_CS'] || 0);
                    $('#created_CS').text(map['Total_CS_Created'] || 0);
                    $('#approved_CS').text(map['Total_CS_Approved'] || 0);
                    $('#cancelled_CS').text(map['Total_CS_Cancelled'] || 0);

                    $('#total_PO').text(map['Total_PO'] || 0);
                    $('#created_PO').text(map['Total_PO_Created'] || 0);
                    $('#approved_PO').text(map['Total_PO_Approved'] || 0);
                    $('#cancelled_PO').text(map['Total_PO_Cancelled'] || 0);

                    $('#total_IGP').text(map['Total_IGP'] || 0);
                    $('#created_IGP').text(map['Total_Created_IGP'] || 0);
                    $('#approved_IGP').text(map['Total_Approved_IGP'] || 0);
                    $('#cancelled_IGP').text(map['Total_Cancelled_IGP'] || 0);

                    $('#total_GRN').text(map['Total_GRN'] || 0);
                    $('#created_GRN').text(map['Total_GRN_Created'] || 0);
                    $('#approved_GRN').text(map['Total_GRN_Approved'] || 0);
                    $('#cancelled_GRN').text(map['Total_GRN_Cancelled'] || 0);
                },
                error: function () {
                    alert('Failed to load dashboard data.');
                }
            });
        }

        function gotoPage(page) {
            var urls = {
                'PR': 'AP/PurchaseRequistionView.aspx',
                'PO': 'AP/PurchaseOrderView.aspx',
                'CS': 'AP/PurchaseRequistionView.aspx',
                'IGP': 'Inventory/InversionGatePassView.aspx',
                'GRN': 'Inventory/GRNView.aspx',
                'GIR': 'Inventory/GoodsIssuanceRequestView.aspx',
                'GIN': 'Inventory/GoodsIssuanceNoteView.aspx'
            };
            window.location = urls[page];
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="dashboard-header">
        <h1><i class="fas fa-box-open me-2"></i> Inventory & Procurement Dashboard</h1>
        <p>Track purchase lifecycle from requisition to goods receipt</p>
    </div>

    <div class="date-controls">
        <div>
            <label>Start Date</label>
            <input type="text" id="txtsdate" />
        </div>
        <div>
            <label>End Date</label>
            <input type="text" id="txtedate" />
        </div>
      <input type="button" class="btn btn-primry" value="Search" onclick="search(); return false;" />
    </div>

    <div class="card-grid">

        <!-- GIR -->
        <div class="stat-card" onclick="gotoPage('GIR')">
            <div class="card-header bg-gir">
                <i class="fas fa-file-invoice"></i> Goods Issuance Request (GIR)
            </div>
            <div class="card-body">
                <div class="stat-item"><span class="stat-label">Total</span><span id="total_GIR" class="stat-value status-total">0</span></div>
                <div class="stat-item"><span class="stat-label">Created</span><span id="created_GIR" class="stat-value status-created">0</span></div>
                <div class="stat-item"><span class="stat-label">Approved</span><span id="approved_GIR" class="stat-value status-approved">0</span></div>
                <div class="stat-item"><span class="stat-label">Cancelled</span><span id="cancelled_GIR" class="stat-value status-cancelled">0</span></div>
            </div>
        </div>

        <!-- GIN -->
        <div class="stat-card" onclick="gotoPage('GIN')">
            <div class="card-header bg-gin">
                <i class="fas fa-truck-moving"></i> Goods Issuance Note (GIN)
            </div>
            <div class="card-body">
                <div class="stat-item"><span class="stat-label">Total</span><span id="total_GIN" class="stat-value status-total">0</span></div>
                <div class="stat-item"><span class="stat-label">Created</span><span id="created_GIN" class="stat-value status-created">0</span></div>
                <div class="stat-item"><span class="stat-label">Approved</span><span id="approved_GIN" class="stat-value status-approved">0</span></div>
                <div class="stat-item"><span class="stat-label">Cancelled</span><span id="cancelled_GIN" class="stat-value status-cancelled">0</span></div>
            </div>
        </div>

        <!-- PR -->
        <div class="stat-card" onclick="gotoPage('PR')">
            <div class="card-header bg-pr">
                <i class="fas fa-list-check"></i> Purchase Requisition (PR)
            </div>
            <div class="card-body">
                <div class="stat-item"><span class="stat-label">Total</span><span id="total_PR" class="stat-value status-total">0</span></div>
                <div class="stat-item"><span class="stat-label">Created</span><span id="created_PR" class="stat-value status-created">0</span></div>
                <div class="stat-item"><span class="stat-label">Approved</span><span id="approved_PR" class="stat-value status-approved">0</span></div>
                <div class="stat-item"><span class="stat-label">Cancelled</span><span id="cancelled_PR" class="stat-value status-cancelled">0</span></div>
            </div>
        </div>

        <!-- CS -->
        <div class="stat-card" onclick="gotoPage('CS')">
            <div class="card-header bg-cs">
                <i class="fas fa-scale-balanced"></i> Comparative Statement (CS)
            </div>
            <div class="card-body">
                <div class="stat-item"><span class="stat-label">Total</span><span id="total_CS" class="stat-value status-total">0</span></div>
                <div class="stat-item"><span class="stat-label">Created</span><span id="created_CS" class="stat-value status-created">0</span></div>
                <div class="stat-item"><span class="stat-label">Approved</span><span id="approved_CS" class="stat-value status-approved">0</span></div>
                <div class="stat-item"><span class="stat-label">Cancelled</span><span id="cancelled_CS" class="stat-value status-cancelled">0</span></div>
            </div>
        </div>

        <!-- PO -->
        <div class="stat-card" onclick="gotoPage('PO')">
            <div class="card-header bg-po">
                <i class="fas fa-file-contract"></i> Purchase Order (PO)
            </div>
            <div class="card-body">
                <div class="stat-item"><span class="stat-label">Total</span><span id="total_PO" class="stat-value status-total">0</span></div>
                <div class="stat-item"><span class="stat-label">Created</span><span id="created_PO" class="stat-value status-created">0</span></div>
                <div class="stat-item"><span class="stat-label">Approved</span><span id="approved_PO" class="stat-value status-approved">0</span></div>
                <div class="stat-item"><span class="stat-label">Cancelled</span><span id="cancelled_PO" class="stat-value status-cancelled">0</span></div>
            </div>
        </div>

        <!-- IGP -->
        <div class="stat-card" onclick="gotoPage('IGP')">
            <div class="card-header bg-igp">
                <i class="fas fa-truck-ramp-box"></i> Inward Gate Pass (IGP)
            </div>
            <div class="card-body">
                <div class="stat-item"><span class="stat-label">Total</span><span id="total_IGP" class="stat-value status-total">0</span></div>
                <div class="stat-item"><span class="stat-label">Created</span><span id="created_IGP" class="stat-value status-created">0</span></div>
                <div class="stat-item"><span class="stat-label">Approved</span><span id="approved_IGP" class="stat-value status-approved">0</span></div>
                <div class="stat-item"><span class="stat-label">Cancelled</span><span id="cancelled_IGP" class="stat-value status-cancelled">0</span></div>
            </div>
        </div>

        <!-- GRN -->
        <div class="stat-card" onclick="gotoPage('GRN')">
            <div class="card-header bg-grn">
                <i class="fas fa-warehouse"></i> Goods Receipt Note (GRN)
            </div>
            <div class="card-body">
                <div class="stat-item"><span class="stat-label">Total</span><span id="total_GRN" class="stat-value status-total">0</span></div>
                <div class="stat-item"><span class="stat-label">Created</span><span id="created_GRN" class="stat-value status-created">0</span></div>
                <div class="stat-item"><span class="stat-label">Approved</span><span id="approved_GRN" class="stat-value status-approved">0</span></div>
                <div class="stat-item"><span class="stat-label">Cancelled</span><span id="cancelled_GRN" class="stat-value status-cancelled">0</span></div>
            </div>
        </div>

    </div>

</asp:Content>