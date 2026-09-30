<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="EMRLookup.aspx.cs" Inherits="PMS.Modules.Administrator.EMRLookup" %>

<asp:Content ID="HeaderContent" runat="server" ContentPlaceHolderID="HeadContent">
    <link href="../../wwwroot/lib/sweetalert/swalalert.css" rel="stylesheet" />
    <script type="text/javascript" src="../../wwwroot/THEME_TIBBIT/js/swalalert.js"></script>

    <style type="text/css">
        .emr-wrap {
            padding: 0 15px;
        }

        .emr-toolbar,
        .emr-section {
            background: #fff;
            border: 1px solid #e3e3e3;
            border-radius: 8px;
            padding: 12px 15px;
            margin-bottom: 15px;
            box-shadow: 0 1px 2px rgba(0, 0, 0, .04);
        }

        .emr-toolbar-title {
            margin: 0 0 2px;
            font-size: 18px;
            font-weight: bold;
        }

        .emr-toolbar-sub {
            margin: 0 0 12px;
            color: #888;
            font-size: 12px;
        }

        .emr-search-row {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 6px;
        }

        .emr-search-row label {
            margin: 0;
            font-size: 13px;
            font-weight: 600;
            color: #555;
        }

        .emr-search-row .textEntry {
            flex: 1 1 240px;
            max-width: 340px;
            height: 30px;
            border-radius: 8px !important;
        }

        .emr-section h4 {
            margin: 0 0 10px;
            font-size: 15px;
            font-weight: bold;
        }
        /*aak*/
        .emr-count {
            margin-left: 6px;
            color: #999;
            font-size: 12px;
            font-weight: normal;
        }

        .emr-kv {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            gap: 4px 14px;
        }

        .emr-kv-item {
            display: flex;
            flex-direction: column;
            min-width: 0;
            padding: 3px 0;
            border-bottom: 1px solid #f0f0f0;
        }

        .emr-kv-k {
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: .3px;
            color: #999;
        }

        .emr-kv-v {
            font-size: 13px;
            color: #333;
            overflow-wrap: anywhere;
        }

        .emr-kv-empty {
            color: #aaa;
            font-size: 13px;
        }

        .emr-table-wrap .table {
            margin-bottom: 0;
        }

        .emr-table-scroll {
            overflow-x: auto;
            clear: both;
        }

        #tblServices th,
        #tblServices td {
            padding: 5px 8px;
            font-size: 12px;
            white-space: nowrap;
        }

        #tblServices th {
            padding-right: 26px;
        }

        .emr-table-wrap .dataTables_wrapper {
            font-size: 12px;
        }

        .emr-table-wrap .dataTables_length,
        .emr-table-wrap .dataTables_filter {
            margin-bottom: 8px;
        }

        .emr-table-wrap .dataTables_length label,
        .emr-table-wrap .dataTables_filter label {
            display: flex;
            align-items: center;
            gap: 6px;
            margin: 0;
        }

        .emr-table-wrap .dataTables_length select {
            display: inline-block;
            width: 70px;
            height: 28px;
            padding: 2px 6px;
            margin: 0;
            font-size: 12px;
        }

        .emr-table-wrap .dataTables_filter input {
            display: inline-block;
            width: 220px !important;
            height: 28px;
            padding: 2px 12px;
            margin: 0;
            box-sizing: border-box;
            font-size: 12px;
            border-radius: 15px !important;
        }

        .emr-btn {
            width: auto !important;
            flex: 0 0 auto;
        }
    </style>

    <script type="text/javascript">
        function escapeHtml(v) {
            if (v === null || v === undefined) { return ''; }
            return String(v)
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#39;');
        }

        function swalMsg(icon, title, text) {
            Swal.fire({
                icon: icon,
                title: title,
                text: text,
                showConfirmButton: false,
                timer: 2500,
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            });
        }

        function showLoader(title, text) {
            Swal.fire({
                title: title,
                text: text,
                allowOutsideClick: false,
                allowEscapeKey: false,
                showConfirmButton: false,
                didOpen: function () {
                    Swal.showLoading();
                }
            });
        }

        $(document).ready(function () {
            $('#txtKey').on('keypress', function (e) {
                if (e.which === 13) {
                    e.preventDefault();
                    SearchPatient();
                }
            });
        });

        function SearchPatient() {
            var key = $('#txtKey').val().trim();

            if (key === '') {
                swalMsg('warning', 'Required', 'Please enter the patient number.');
                return;
            }

            $('#btnSearch').prop('disabled', true).val('Searching...');

            showLoader('Searching...', 'Fetching patient information, please wait.');

            $.ajax({
                type: "POST",
                url: "EMRLookup.aspx/GetPatientLookup",
                data: JSON.stringify({ key: key }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    Swal.close();

                    var res = response.d || {};
                    var rows = res.Patient || [];

                    if (rows.length === 0) {
                        renderHeader(null);
                        swalMsg('info', 'Not Found', 'No patient found for: ' + key);
                    } else {
                        renderHeader(rows[0]);
                    }

                    renderDataTable('#tblServices', res.Services || []);

                    if (res.ServicesError) {
                        swalMsg('error', 'Services Error', res.ServicesError);
                    }
                },
                error: function () {
                    Swal.close();
                    swalMsg('error', 'Error!', 'Failed to fetch patient information from the client database.');
                },
                complete: function () {
                    $('#btnSearch').prop('disabled', false).val('Search');
                }
            });
        }

        function TestConnection() {
            $('#btnTest').prop('disabled', true).val('Testing...');

            showLoader('Testing...', 'Checking client Oracle database connection.');

            $.ajax({
                type: "POST",
                url: "EMRLookup.aspx/TestConnection",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    Swal.close();

                    var res = response.d;
                    if (res === 'success') {
                        swalMsg('success', 'Connected', 'Client Oracle database connection successful.');
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Connection Failed',
                            text: res,
                            showConfirmButton: true,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                    }
                },
                error: function () {
                    Swal.close();
                    swalMsg('error', 'Error!', 'Connection test request failed.');
                },
                complete: function () {
                    $('#btnTest').prop('disabled', false).val('Test Connection');
                }
            });
        }

        function renderHeader(row) {
            var $t = $('#tblHeader');

            if (!row) {
                $t.html('<span class="emr-kv-empty">No patient loaded.</span>');
                $('#lblHeaderCount').text('');
                return;
            }

            var html = '';
            var count = 0;
            $.each(row, function (k, v) {
                count++;
                html += '<div class="emr-kv-item">' +
                        '<span class="emr-kv-k">' + escapeHtml(String(k).replace(/_/g, ' ')) + '</span>' +
                        '<span class="emr-kv-v">' + escapeHtml(v) + '</span>' +
                        '</div>';
            });

            $t.html(html);
            $('#lblHeaderCount').text(count + ' fields');
        }

        function renderDataTable(selector, rows) {
            var $t = $(selector);

            if ($.fn.DataTable.isDataTable(selector)) {
                $t.DataTable().destroy();
            }

            $t.empty();

            if (!rows || rows.length === 0) {
                $t.html('<tbody><tr><td>No record found</td></tr></tbody>');
                return;
            }

            var cols = [];
            $.each(rows[0], function (k) { cols.push(k); });

            var thead = '<thead><tr>';
            $.each(cols, function (i, c) { thead += '<th>' + escapeHtml(c) + '</th>'; });
            thead += '</tr></thead>';

            var tbody = '<tbody>';
            $.each(rows, function (i, r) {
                tbody += '<tr>';

                $.each(cols, function (j, c) {
                    tbody += '<td>' + escapeHtml(r[c]) + '</td>';
                });

                tbody += '</tr>';
            });
            tbody += '</tbody>';

            $t.html(thead + tbody);

            $t.DataTable({
                "paging": true,
                "pageLength": 10,
                "lengthMenu": [10, 25, 50, 100],
                "searching": true,
                "ordering": true,
                "info": true,
                "dom": 'lf<"emr-table-scroll"t>ip',
                "order": []
            });
        }
    </script>
</asp:Content>

<asp:Content ID="BodyContent" runat="server" ContentPlaceHolderID="MainContent">
    <div class="emr-wrap">
        <div class="emr-toolbar">
            <h3 class="emr-toolbar-title">Client EMR Patient Lookup</h3>
            <p class="emr-toolbar-sub">Read-only lookup of patient information from the client's Oracle EMR database.</p>

            <div class="emr-search-row">
                <label for="txtKey">Patient Number:</label>
                <input autocomplete="off" type="text" id="txtKey" name="txtKey" class="textEntry"
                       placeholder="e.g. 001000071011" />
                <input class="btn-primry emr-btn" type="button" id="btnSearch" value="Search" onclick="SearchPatient()" />
                <input class="btn-primry emr-btn" type="button" id="btnTest" value="Test Connection" onclick="TestConnection()" />
            </div>
        </div>

        <div class="emr-section">
            <h4>Patient Information<span class="emr-count" id="lblHeaderCount"></span></h4>
            <div id="tblHeader" class="emr-kv">
                <span class="emr-kv-empty">Search a patient number to load information.</span>
            </div>
        </div>

        <div class="emr-section">
            <h4>Patient Services</h4>
            <div class="emr-table-wrap">
                <table id="tblServices" class="table table-bordered table-striped" style="width: 100%;"></table>
            </div>
        </div>
    </div>
</asp:Content>