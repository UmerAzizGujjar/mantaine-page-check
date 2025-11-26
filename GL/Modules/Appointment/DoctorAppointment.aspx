<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DoctorAppointment.aspx.cs" Inherits="PMS.DoctorAppointment" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .pagination-container {
            margin-top: 10px;
            text-align: right;
        }

        .page-link {
            display: inline-block;
            margin: 0 5px;
            padding: 5px 10px;
            border: 1px solid #ddd;
            cursor: pointer;
            color: #007bff;
        }

            .page-link:hover {
                background-color: #f1f1f1;
            }

            .page-link.active {
                background-color: #007bff;
                color: white;
                border-color: #007bff;
            }
    </style>
    <script type="text/javascript">
    $(document).ready(function () {
        loaddoctor();
        var now = new Date();
        var today = moment(now).format('L'); // Locale date, e.g., MM/DD/YYYY

        $("#txt_datefrom, #txt_dateto")
            .datepicker({
                dateFormat: 'mm/dd/yy',
                changeMonth: true,
                changeYear: true,
                yearRange: "-50:+50"
            })
            .attr('readonly', 'readonly')
            .val(today);

        // Handle query string overrides
        var stDate = '<%= Request.QueryString["stDate"] ?? "" %>';
        var endDate = '<%= Request.QueryString["endDate"] ?? "" %>';
        if (stDate) $("#txt_datefrom").val(stDate);
        if (endDate) $("#txt_dateto").val(endDate);

        $('#btnSearch').click(getpage);
        getpage(); // Load default (last 24h) on page load
    });

    function toTitleCase(str) {
        return (str || "").replace(/(?:^|\s)\w/g, function (match) {
            return match.toUpperCase();
        }).replace(/_/g, ' ');
    }

    function formatTime(rawTime) {
        if (!rawTime || typeof rawTime !== 'string') return "—";
        var trimmed = rawTime.trim();
        if (!trimmed || trimmed === "—" || trimmed === "-") return "—";

        // Try multiple formats strictly
        var formats = ["h:mm A", "hh:mm A", "H:mm", "HH:mm", "HH:mm:ss", "LT"];
        var m = moment(trimmed, formats, true);
        return m.isValid() ? m.format('h:mm a') : trimmed; // fallback to raw if unparseable
    }

    function getpage() {
        var stDate = $('#txt_datefrom').val() || "";
        var endDate = $('#txt_dateto').val() || "";
        var doc_id = $('#chk_Doc').val() || "0";

        // Clear table & pagination before request
        $('#t_body').empty();
        $('#pagination').empty();

        PageMethods.getlist(stDate, endDate, doc_id, function (response) {
            try {
                var data = JSON.parse(response);
                if (data.error) {
                    alert("Error: " + data.error);
                    return;
                }

                if (!Array.isArray(data) || data.length === 0) {
                    $('#t_body').html('<tr><td colspan="7" class="text-center text-muted">No appointments found.</td></tr>');
                    return;
                }

                const rowsPerPage = 10;
                let currentPage = 1;

                function displayTable(page) {
                    const start = (page - 1) * rowsPerPage;
                    const end = start + rowsPerPage;
                    const paginatedData = data.slice(start, end);

                    let rows = '';
                    paginatedData.forEach((item, index) => {
                        var serial = start + index + 1;
                        var appDate = item.App_Date ? moment(item.App_Date).format('LL') : "—";
                        var time = formatTime(item.Time);
                        var status = item.Status || "—";

                        rows += `<tr>
                            <td>${serial}</td>
                            <td>${item.Appointment_No || "—"}</td>
                            <td>${toTitleCase(item.Patient_Name)}</td>
                            <td>${item.emp_name || "—"}</td>
                            <td>${appDate}</td>
                            <td>${time}</td>
                            <td>${status}</td>
                        </tr>`;
                    });

                    $('#t_body').html(rows);
                    applyRowStyles();
                }

                function applyRowStyles() {
                    $('#t_body tr').each(function () {
                        var $row = $(this);
                        var status = $row.find('td:eq(6)').text().trim().toLowerCase();
                        $row.css('background-color', '');
                        if (status.includes('visited')) {
                            $row.css('background-color', 'rgba(39, 174, 96, 0.25)');
                        } else if (status.includes('not visited') || status.includes('missed')) {
                            $row.css('background-color', 'rgba(231, 76, 60, 0.2)');
                        }
                    });
                }

                function setupPagination() {
                    const totalPages = Math.ceil(data.length / rowsPerPage);
                    if (totalPages <= 1) {
                        $('#pagination').empty();
                        return;
                    }

                    let paginationHTML = '';
                    // Show first, current ±2, last
                    const maxVisible = 5;
                    let startPage = Math.max(1, currentPage - 2);
                    let endPage = Math.min(totalPages, startPage + maxVisible - 1);
                    if (endPage - startPage + 1 < maxVisible) {
                        startPage = Math.max(1, endPage - maxVisible + 1);
                    }

                    if (startPage > 1) {
                        paginationHTML += `<span class="page-link" data-page="1">1</span>`;
                        if (startPage > 2) paginationHTML += `<span class="page-link disabled">...</span>`;
                    }

                    for (let i = startPage; i <= endPage; i++) {
                        paginationHTML += `<span class="page-link${i === currentPage ? ' active' : ''}" data-page="${i}">${i}</span>`;
                    }

                    if (endPage < totalPages) {
                        if (endPage < totalPages - 1) paginationHTML += `<span class="page-link disabled">...</span>`;
                        paginationHTML += `<span class="page-link" data-page="${totalPages}">${totalPages}</span>`;
                    }

                    $('#pagination').html(paginationHTML);

                    $('.page-link:not(.disabled)').off('click').on('click', function () {
                        currentPage = parseInt($(this).data('page'));
                        displayTable(currentPage);
                        setupPagination(); // refresh active state
                    });
                }

                displayTable(currentPage);
                setupPagination();
            } catch (ex) {
                console.error("Parse error:", ex);
                $('#t_body').html(`<tr><td colspan="7" class="text-danger">Failed to load data: ${ex.message}</td></tr>`);
            }
        }, function (error) {
            console.error("AJAX error:", error);
            $('#t_body').html(`<tr><td colspan="7" class="text-danger">Server error. Please try again.</td></tr>`);
        });

        return false;
    }

    function loaddoctor() {
        PageMethods.LoadDoctor(function (res) {
            try {
                var doctors = JSON.parse(res);
                var options = '<option value="0">Select Doctor</option>';
                $.each(doctors, function (i, doc) {
                    options += `<option value="${doc.Emp_ID}">${doc.Emp_Name}</option>`;
                });

                $('#chk_Doc').html(options).prop('disabled', false);
                if (doctors.length > 0) {
                    $('#chk_Doc').val(doctors[0].Emp_ID); // Auto-select first
                }
            } catch (ex) {
                console.error("Doctor load failed:", ex);
            }
        }, function (err) {
            console.error("LoadDoctor failed:", err);
        });
    }

    function ddldocchange() {
        getpage(); // Simpler: just reload — avoids client-side filtering bugs
    }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">

        <div class=" col-lg-3 col-md-6 col-sm-12">
            <label>Doctor</label>
            <select id="chk_Doc" onchange="ddldocchange()">
            </select>
        </div>

        <div class=" col-lg-3 col-md-6 col-sm-12">
            <label>From</label>
            <input type="text" id="txt_datefrom" />
        </div>

        <div class=" col-lg-3 col-md-6 col-sm-12">
            <label>To</label>
            <input type="text" id="txt_dateto" />
        </div>

        <div class=" col-lg-1 col-md-6 col-sm-12">
            <input type="button" id="btnSearch" class="btn btn-primry mar-btn" style="top: 21px;" value="Search" />
        </div>
    </div>

    <div class="table-container">
        <table class="table table-hover table-striped table-bordered" id="table_res">
            <tr id="row_sample">
                <th>S No.</th>
                <th>APPT NO</th>
                <th>PATIENT NAME</th>
                <th>DOCTOR NAME</th>
                <th>DATE</th>
                <th>TIME</th>
                <th>STATUS</th>
            </tr>
            <tbody id="t_body"></tbody>
        </table>
    </div>
    <!-- Pagination Controls -->
    <div id="pagination" class="pagination-container"></div>




</asp:Content>
