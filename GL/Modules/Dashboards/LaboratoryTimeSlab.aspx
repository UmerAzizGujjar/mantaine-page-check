<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LaboratoryTimeSlab.aspx.cs" Inherits="PMS.Modules.Dashboards.LaboratoryTimeSlab" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
    /* Base Styling */
    body { font-family: 'Inter', sans-serif; background-color: #f8fafc; color: #334155; }
    
    /* CRITICAL FIX: Force datepicker above everything */
    .ui-datepicker, #ui-datepicker-div {
        z-index: 999999 !important;
        position: absolute !important;
    }
    
    /* Header */
    .dashboard-header {
        background: linear-gradient(135deg, #0f766e 0%, #0d9488 100%);
        color: white;
        padding: 24px 30px;
        border-radius: 12px;
        margin-bottom: 25px;
        box-shadow: 0 8px 20px rgba(13, 148, 136, 0.15);
        display: flex;
        align-items: center;
        gap: 15px;
    }
    .dashboard-header h1 { margin: 0; font-size: 26px; font-weight: 700; letter-spacing: -0.5px; }
    .dashboard-header i { font-size: 28px; opacity: 0.9; }

    /* Stat Cards */
    .stat-card {
        background: white;
        border-radius: 16px;
        padding: 24px;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.03), 0 2px 4px -1px rgba(0, 0, 0, 0.02);
        border: 1px solid #e2e8f0;
        transition: all 0.3s ease;
        position: relative;
        overflow: visible !important; /* Changed from hidden to visible */
        z-index: 1;
    }
    .stat-card:hover { transform: translateY(-4px); box-shadow: 0 12px 24px -4px rgba(0, 0, 0, 0.08); }
    .stat-card::before { content: ''; position: absolute; top: 0; left: 0; width: 4px; height: 100%; }
    .stat-card.blue::before { background: #3b82f6; }
    .stat-card.teal::before { background: #14b8a6; }

    .stat-icon {
        width: 50px; height: 50px; border-radius: 12px;
        display: flex; align-items: center; justify-content: center;
        font-size: 22px; margin-bottom: 16px;
    }
    .stat-card.blue .stat-icon { background: #eff6ff; color: #3b82f6; }
    .stat-card.teal .stat-icon { background: #f0fdfa; color: #14b8a6; }

    .stat-value { font-size: 32px; font-weight: 700; color: #0f172a; line-height: 1; }
    .stat-label { font-size: 14px; color: #64748b; font-weight: 600; margin-top: 6px; text-transform: uppercase; letter-spacing: 0.5px; }

    /* Filter Panel - CRITICAL: Make it visible above table */
    .filter-panel {
        background: white;
        padding: 20px 24px;
        border-radius: 12px;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.03);
        border: 1px solid #e2e8f0;
        margin-bottom: 25px;
        display: flex;
        align-items: flex-end;
        gap: 20px;
        flex-wrap: wrap;
        position: relative;
        z-index: 100; /* Higher than table header */
    }
    .filter-group { display: flex; flex-direction: column; gap: 6px; flex: 1; min-width: 180px; position: relative; z-index: 100; }
    .filter-group label { font-size: 12px; font-weight: 700; color: #475569; text-transform: uppercase; letter-spacing: 0.5px; }
    .filter-group input {
        padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px;
        font-size: 14px; font-family: 'Inter', sans-serif; transition: all 0.2s;
        position: relative;
        z-index: 100;
    }
    .filter-group input:focus { outline: none; border-color: #0d9488; box-shadow: 0 0 0 3px rgba(13, 148, 136, 0.1); }
    
    .btn-search {
        background: #0d9488; color: white; border: none; padding: 10px 24px;
        border-radius: 8px; font-weight: 600; font-size: 14px; cursor: pointer;
        transition: all 0.2s; display: flex; align-items: center; gap: 8px; height: 42px;
        position: relative;
        z-index: 100;
    }
    .btn-search:hover { background: #0f766e; transform: translateY(-1px); }

    /* Modern Table */
    .table-container {
        background: white; border-radius: 12px;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.03);
        border: 1px solid #e2e8f0; overflow: visible !important; /* Changed to visible */
        position: relative;
        z-index: 1; /* Lower than filter panel */
    }
    .table-scroll { 
        overflow-x: auto; 
        max-height: 600px; 
        overflow-y: auto; 
        position: relative;
    }
    .modern-table { width: 100%; border-collapse: collapse; font-size: 14px; min-width: 1000px; }
    .modern-table thead { background: #f8fafc; border-bottom: 2px solid #e2e8f0; }
    .modern-table th {
        padding: 16px; text-align: left; font-weight: 700; color: #475569;
        text-transform: uppercase; font-size: 12px; letter-spacing: 0.5px;
        position: sticky; 
        top: 0; 
        z-index: 10 !important; /* Keep sticky but lower than datepicker */
        background: #f8fafc;
    }
    .modern-table td { padding: 16px; border-bottom: 1px solid #f1f5f9; color: #334155; vertical-align: middle; }
    .modern-table tbody tr { transition: background-color 0.15s; }
    .modern-table tbody tr:hover { background-color: #f8fafc; }
    .modern-table tbody tr:last-child td { border-bottom: none; }

    /* Dynamic Time Badges */
    .time-badge {
        display: inline-flex; align-items: center; padding: 5px 12px;
        border-radius: 20px; font-size: 12px; font-weight: 700; letter-spacing: 0.3px;
    }
    .time-badge.fast { background: #dcfce7; color: #166534; }
    .time-badge.normal { background: #fef3c7; color: #92400e; }
    .time-badge.slow { background: #fee2e2; color: #991b1b; }

    /* Loading Spinner */
    .loading-spinner {
        border: 3px solid #f1f5f9; border-top: 3px solid #0d9488;
        border-radius: 50%; width: 32px; height: 32px;
        animation: spin 0.8s linear infinite; margin: 30px auto;
    }
    @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
</style>



    <script type="text/javascript">



        $(document).ready(function () {
            
            var today = new Date();
            var formattedToday = today.getFullYear() + '-' +
                String(today.getMonth() + 1).padStart(2, '0') + '-' +
                String(today.getDate()).padStart(2, '0');

            $("#txtsdate").val(formattedToday).datepicker({
                dateFormat: 'yy-mm-dd',
                changeMonth: true,
                changeYear: true
            }).attr('readonly', 'readonly');

            $("#txtedate").val(formattedToday).datepicker({
                dateFormat: 'yy-mm-dd',
                changeMonth: true,
                changeYear: true
            }).attr('readonly', 'readonly');



            
            LoadDashboard(formattedToday, formattedToday);
        });


        function Loadsearchboard() {
            var dt = $('#txtsdate').val();
            var dts = $('#txtedate').val();

            if (dt === "" || dts === "") {
                alert("Please select both Start and End dates.");
                return;
            }

            LoadDashboard(dt, dts);
        }

        $("#txtsdate, #txtedate").datepicker({
            dateFormat: 'yy-mm-dd',
            changeMonth: true,
            changeYear: true,
            showOn: "both",
            buttonImageOnly: null,
            beforeShow: function (input, inst) {
                setTimeout(function () {
                    $('#ui-datepicker-div').css({
                        'z-index': '999999',
                        'position': 'absolute'
                    });
                }, 0);
            }
        }).attr('readonly', 'readonly').css('z-index', '100');
        function LoadDashboard(startdate, Enddate) {
            
            $('#regdetail tbody').html('<tr><td colspan="9" style="text-align:center; padding: 20px;">Loading data...</td></tr>');

            $.ajax({
                type: "POST",
                url: "LaboratoryTimeSlab.aspx/ViewList",
                data: JSON.stringify({ 'txt_sdate': startdate, 'txt_edate': Enddate }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    
                    var parsedData = JSON.parse(response.d);
                    var rows = '';
                    var srNo = 1;
                    var totalTests = parsedData.length;
                    var totalTimeSpentMinutes = 0;

                    $('#regdetail tbody').empty();

                    if (totalTests === 0) {
                        $('#regdetail tbody').html('<tr><td colspan="9" style="text-align:center; padding: 20px; color: #666;">No records found for the selected date range.</td></tr>');
                    } else {
                        $.each(parsedData, function (key, value) {
                            
                            var mins = parseInt(value.Total_Time_Spent_Minutes) || 0;
                            totalTimeSpentMinutes += mins;

                            rows += '<tr>' +
                                '<td>' + srNo + '</td>' +
                                '<td style="text-align:left; font-weight:600;">' + (value.MR_No || '-') + '</td>' +
                                '<td style="text-align:left;">' + (value.Patient_Name || '-') + '</td>' +
                                '<td>' + (value.Bill_Date || '-') + '</td>' +
                                '<td>' + (value.Sample_Date || '-') + '</td>' +
                                '<td>' + (value.Lab_Date || '-') + '</td>' +
                                '<td>' + (value.Report_Date || '-') + '</td>' +
                                '<td>' + (value.Approve_Date || '-') + '</td>' +
                                '<td><span class="badge badge-info" style="background-color: #17a2b8; color: white; padding: 5px 10px; border-radius: 4px;">' + value.Total_Time_Spent + '</span></td>' +
                                '</tr>';
                            srNo++;
                        });

                        $('#regdetail tbody').append(rows);
                    }

                    
                    var avgMinutes = totalTests > 0 ? Math.round(totalTimeSpentMinutes / totalTests) : 0;
                    var avgHours = Math.floor(avgMinutes / 60);
                    var avgMins = avgMinutes % 60;
                    var avgTimeFormatted = avgHours + 'h ' + avgMins + 'm';

                    
                    $('#totalPatients').text(totalTests);
                    $('#avgTimeSpent').text(avgTimeFormatted);
                },
                error: function (xhr, status, error) {
                    console.error("Error occurred: " + status + " " + error);
                    $('#regdetail tbody').html('<tr><td colspan="9" style="text-align:center; padding: 20px; color: red;">Error loading data. Please check console for details.</td></tr>');
                }
            });
        }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid">
        <div class="row" style="text-align: center;">
            <h1 id="h1">Laboratory Turnaround Time Slab</h1>
        </div>
        <div class="row mb-4">
            <div class="col-md-4 offset-md-2">
                <div class="card l-bg-orange-dark text-white" id="Box1">
                    <div class="card-header">
                        <h3>Total Lab Tests</h3>
                        <i class="fas fa-flask" style="position: absolute; right: 15px; font-size: 20px; opacity: 0.8;"></i>
                    </div>
                    <div class="card-body">         
                        <span id="totalPatients" class="stat-value">0</span>
                    </div>
                </div>
            </div>
            
            <div class="col-md-4">
                <div class="card l-bg-green-dark text-white" id="Box2">
                    <div class="card-header">
                        <h3>Avg Turnaround Time</h3>
                        <i class="fas fa-clock" style="position: absolute; right: 15px; font-size: 20px; opacity: 0.8;"></i>
                    </div>
                    <div class="card-body">
                        <span id="avgTimeSpent" class="stat-value">0h 0m</span>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="row mb-3 align-items-end">
            <div class="col-lg-2 col-md-4">
                <label class="font-weight-bold">Start Date:</label>
                <input type="text" id="txtsdate" class="form-control" placeholder="YYYY-MM-DD" />
            </div>
            <div class="col-lg-2 col-md-4">
                <label class="font-weight-bold">End Date:</label>
                <input type="text" id="txtedate" class="form-control" placeholder="YYYY-MM-DD" />
            </div>
            <div class="col-lg-1 col-md-4">
                <label></label>
                <input type="button" id="btnSearch" class="btn btn-primry" value="Search" onclick="Loadsearchboard()" />
            </div>
        </div>

        <!-- Data Table -->
        <div class="row">
            <div class="col-lg-12">
                <div class="card shadow-sm">
                    <div class="card-body p-0">
                        <div style="overflow-x: auto; max-height: 600px; overflow-y: auto;">
                            <table class="table table-hover mb-0" id="regdetail" style="min-width: 1000px;">
                                <thead style="position: sticky; top: 0; z-index: 10;">
                                    <tr>
                                        <th style="width: 50px;">SR No</th>
                                        <th style="width: 120px;">MR No</th>
                                        <th style="width: 200px;">Patient Name</th>
                                        <th>Bill Date</th>
                                        <th>Sample Date</th>
                                        <th>Lab Date</th>
                                        <th>Report Date</th>
                                        <th>Approve Date</th>
                                        <th style="width: 120px;">Total Time</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
