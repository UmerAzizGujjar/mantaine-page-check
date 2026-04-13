<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="TokenListIITH.aspx.cs" Inherits="PMS.Modules.Administrator.TokenListIITH" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* Table Header Gradient */
        .table > thead > tr {
            background: linear-gradient(to right, #667eea, #764ba2) !important;
            color: white;
        }
        
        .table-header th {
            font-size: 20px;
            font-weight: 600;
            padding: 12px !important;
        }
        
        /* Doctor Header Card */
        .doctor-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px 25px;
            border-radius: 10px;
            margin-bottom: 25px;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
        }
        
        .doctor-header h3 {
            margin: 0;
            font-weight: 600;
        }
        
        .doctor-header small {
            opacity: 0.9;
            font-size: 14px;
        }
        
        /* Table Cell Styling */
        #tblDoctorPatients tbody td {
            font-size: 18px;
            vertical-align: middle;
            padding: 12px !important;
        }
        
        #tblDoctorPatients tbody td:first-child {
            font-weight: bold;
            color: #667eea;
            text-align: center;
            font-size: 20px;
        }
        
        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: #6c757d;
        }
        
        .empty-state i {
            font-size: 48px;
            margin-bottom: 15px;
            opacity: 0.5;
        }
        
        /* Loading Spinner */
        .loading-spinner {
            text-align: center;
            padding: 30px;
        }
        
        .spinner-border {
            width: 3rem;
            height: 3rem;
            color: #667eea;
        }
        
        /* Refresh Badge */
        .refresh-badge {
            position: fixed;
            bottom: 20px;
            right: 20px;
            background: #28a745;
            color: white;
            padding: 8px 15px;
            border-radius: 20px;
            font-size: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.15);
            z-index: 1000;
            display: none;
        }
        
        .refresh-badge.show {
            display: block;
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0% { opacity: 1; }
            50% { opacity: 0.7; }
            100% { opacity: 1; }
        }
        
        /* Responsive Table */
        @media (max-width: 768px) {
            #tblDoctorPatients tbody td {
                font-size: 16px;
                padding: 10px !important;
            }
            #tblDoctorPatients tbody td:first-child {
                font-size: 18px;
            }
        }
    </style>


    <script type="text/javascript">
        PageMethods = PageMethods || {};

        $(document).ready(function () {
            $('#currentDateLabel').text(getFormattedDate(new Date()));
            LoadDoctorName();
            GetLatestDoctorToken();
            startAutoRefresh(180);
            $('#btnRefresh').click(function () {
                $(this).prop('disabled', true).html('⏳ Refreshing...');
                GetLatestDoctorToken();
                setTimeout(() => {
                    $('#btnRefresh').prop('disabled', false).html('🔄 Refresh');
                }, 2000);
            });
        });

        function getFormattedDate(date) {
            const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
            return date.toLocaleDateString('en-US', options);
        }

        function LoadDoctorName() {
            $.ajax({
                url: 'TokenListIITH.aspx/GetCurrentDoctorName',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    var data = response.d ? JSON.parse(response.d) : response;
                    $('#doctorNameLabel').text(data.doctorName || 'Doctor');
                },
                error: function () {
                    $('#doctorNameLabel').text('Doctor');
                }
            });
        }

        function GetLatestDoctorToken() {
            $('#ibody_doctor').html(`
                <tr>
                    <td colspan="4" class="loading-spinner">
                        <div class="spinner-border" role="status"></div>
                        <p class="mt-2 mb-0">Loading patients...</p>
                    </td>
                </tr>
            `);

            $.ajax({
                url: 'TokenListIITH.aspx/LoadDoctorTokenPatients',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    var data = response.d ? JSON.parse(response.d) : response;
                    var tableBody = $('#ibody_doctor');
                    tableBody.empty();
                    if (data && data.error) {
                        tableBody.append(`
                            <tr>
                                <td colspan="4" class="text-center text-danger py-4">
                                    ⚠️ Error: ${data.error}
                                </td>
                            </tr>
                        `);
                        return;
                    }

                    // Handle empty list
                    if (!data || data.length === 0) {
                        tableBody.append(`
                            <tr>
                                <td colspan="4" class="empty-state">
                                    <div>📋</div>
                                    <h5 class="mb-1">No Patients Today</h5>
                                    <small class="text-muted">No private patients assigned to you for today.</small>
                                </td>
                            </tr>
                        `);
                        return;
                    }

                    // Render each patient row
                    $.each(data, function (key, value) {
                        // Safe value extraction with fallbacks
                        var tokenNo = value.tokenNo || value.Doc_Token || '-';
                        var mrNo = value.mr_no_sequence || value.Opd_No || '-';
                        var patientName = value.Full_Name || 'N/A';
                        var clinic = value.filter_clinic || '-';

                        // Map clinic code to name (optional customization)
                        var clinicName = getClinicName(clinic);

                        var row = `<tr>
                            <td style="text-align: center;">${escapeHtml(tokenNo)}</td>
                            <td style="text-align: center;">${escapeHtml(mrNo)}</td>
                            <td><strong>${escapeHtml(patientName)}</strong></td>
                            <td style="text-align: center;">
                                <span class="badge bg-secondary">${escapeHtml(clinicName)}</span>
                            </td>
                        </tr>`;
                        tableBody.append(row);
                    });

                    // Update last refresh time
                    updateLastRefreshTime();

                },
                error: function (xhr, status, error) {
                    console.error('Error loading patients:', error);
                    $('#ibody_doctor').html(`
                        <tr>
                            <td colspan="4" class="text-center text-danger py-4">
                                ❌ Failed to load patients. Please try refreshing.
                            </td>
                        </tr>
                    `);
                }
            });
        }

        // Map clinic codes to readable names (customize as needed)
        function getClinicName(code) {
            const clinicMap = {
                '001': 'Clinic 1',
                '002': 'Clinic 2',
                '003': 'Clinic 3',
                'OPD': 'General OPD'
            };
            return clinicMap[code] || code || 'N/A';
        }

        // Simple HTML escape to prevent XSS
        function escapeHtml(text) {
            if (!text) return '';
            const map = {
                '&': '&amp;',
                '<': '&lt;',
                '>': '&gt;',
                '"': '&quot;',
                "'": '&#039;'
            };
            return String(text).replace(/[&<>"']/g, function (m) { return map[m]; });
        }

        // Update "Last Refresh" label
        function updateLastRefreshTime() {
            const now = new Date();
            const timeStr = now.toLocaleTimeString('en-US', {
                hour: '2-digit',
                minute: '2-digit',
                hour12: true
            });
            $('#lastRefreshLabel').text('Last: ' + timeStr);
        }

        // Auto-refresh with countdown badge
        let refreshInterval;
        let countdown = 180; // 3 minutes in seconds

        function startAutoRefresh(seconds) {
            countdown = seconds;

            // Show badge
            $('#refreshBadge').addClass('show');
            $('#countdown').text(countdown);

            // Update countdown every second
            refreshInterval = setInterval(function () {
                countdown--;
                $('#countdown').text(countdown);

                if (countdown <= 0) {
                    // Time to refresh
                    GetLatestDoctorToken();
                    countdown = seconds; // Reset
                    $('#countdown').text(countdown);

                    // Visual feedback
                    $('#refreshBadge').fadeOut(200).fadeIn(200);
                }
            }, 1000);
        }

        $(window).on('beforeunload', function () {
            if (refreshInterval) {
                clearInterval(refreshInterval);
            }
        });
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="container-fluid py-4">
        <div class="doctor-header d-flex justify-content-between align-items-center">
            <div>
                <h3>🩺 Dr. <span id="doctorNameLabel">Loading...</span></h3>
                <small id="currentDateLabel"></small>
            </div>
            <div class="text-end">
                <button id="btnRefresh" class="btn btn-light btn-sm" onclick="GetLatestDoctorToken();">
                    🔄 Refresh
                </button>
                <div class="mt-1 small opacity-75">
                    <span id="lastRefreshLabel">Last: --:--</span>
                </div>
            </div>
        </div>

        <div class="card shadow-sm border-0">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover table-striped mb-0" id="tblDoctorPatients">
                        <thead class="table-header">
                            <tr>
                                <th style="width: 15%; text-align: center;">Token No</th>
                                <th style="width: 15%; text-align: center;">MR No</th>
                                <th>Patient Name</th>
                                <th style="width: 20%; text-align: center;">Clinic</th>
                            </tr>
                        </thead>
                        <tbody id="ibody_doctor">
                            <tr>
                                <td colspan="4" class="loading-spinner">
                                    <div class="spinner-border" role="status">
                                        <span class="visually-hidden">Loading...</span>
                                    </div>
                                    <p class="mt-2 mb-0">Loading patients...</p>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <div id="refreshBadge" class="refresh-badge">
            ⏱ Auto-refresh in <span id="countdown">180</span>s
        </div>

    </div>

</asp:Content>
