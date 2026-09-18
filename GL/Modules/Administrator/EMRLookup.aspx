<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="EMRLookup.aspx.cs" Inherits="PMS.Modules.Administrator.EMRLookup" %>

<asp:Content ID="HeaderContent" runat="server" ContentPlaceHolderID="HeadContent">
    <link href="../../wwwroot/lib/sweetalert/swalalert.css" rel="stylesheet" />
    <script type="text/javascript" src="../../wwwroot/THEME_TIBBIT/js/swalalert.js"></script>

    <style type="text/css">
        .emr-wrap {
            padding: 0 15px;
        }

        .emr-search {
            max-width: 520px;
            margin: 0 auto 15px auto;
        }

        .emr-section {
            margin-top: 25px;
        }

        .emr-section h4 {
            margin-bottom: 10px;
            font-weight: bold;
        }

        #tblHeader th {
            width: 260px;
            text-align: left;
            vertical-align: top;
        }

        #tblServices th, #tblRadiology th {
            white-space: nowrap;
        }

        .emr-btn {
            border-radius: 50px;
            width: 170px;
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

        function escapeAttr(v) {
            return escapeHtml(v).replace(/"/g, '&quot;');
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

            $.ajax({
                type: "POST",
                url: "EMRLookup.aspx/GetPatient",
                data: JSON.stringify({ key: key }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var rows = response.d || [];
                    if (rows.length === 0) {
                        renderHeader(null);
                        swalMsg('info', 'Not Found', 'No patient found for: ' + key);
                    } else {
                        renderHeader(rows[0]);
                    }
                },
                error: function () {
                    swalMsg('error', 'Error!', 'Failed to fetch patient information from the client database.');
                },
                complete: function () {
                    $('#btnSearch').prop('disabled', false).val('Search');
                }
            });

            loadServices(key);
        }

        function loadServices(key) {
            $.ajax({
                type: "POST",
                url: "EMRLookup.aspx/GetServices",
                data: JSON.stringify({ key: key }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    renderDataTable('#tblServices', response.d || [], true);
                },
                error: function () {
                    renderDataTable('#tblServices', [], true);
                }
            });
        }

        function loadRadiology(btn) {
            var orderNo = $(btn).attr('data-order');
            var detailId = $(btn).attr('data-detail');

            $('#tblRadiology').html('<tbody><tr><td>Loading...</td></tr></tbody>');

            $.ajax({
                type: "POST",
                url: "EMRLookup.aspx/GetRadiology",
                data: JSON.stringify({ orderNo: orderNo, detailId: detailId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var rows = response.d || [];
                    renderDataTable('#tblRadiology', rows, false);
                    if (rows.length === 0) {
                        swalMsg('info', 'No Result', 'No radiology result for order ' + orderNo);
                    }
                },
                error: function () {
                    renderDataTable('#tblRadiology', [], false);
                    swalMsg('error', 'Error!', 'Failed to fetch radiology results.');
                }
            });
        }

        function TestConnection() {
            $('#btnTest').prop('disabled', true).val('Testing...');

            $.ajax({
                type: "POST",
                url: "EMRLookup.aspx/TestConnection",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
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
                $t.html('');
                return;
            }

            var html = '<tbody>';
            $.each(row, function (k, v) {
                html += '<tr><th>' + escapeHtml(k) + '</th><td>' + escapeHtml(v) + '</td></tr>';
            });
            html += '</tbody>';

            $t.html(html);
        }

        function renderDataTable(selector, rows, withAction) {
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
            if (withAction) { thead += '<th>Action</th>'; }
            $.each(cols, function (i, c) { thead += '<th>' + escapeHtml(c) + '</th>'; });
            thead += '</tr></thead>';

            var tbody = '<tbody>';
            $.each(rows, function (i, r) {
                tbody += '<tr>';

                if (withAction) {
                    tbody += '<td><input type="button" class="btn-primry" value="Radiology" ' +
                             'style="width:100px;border-radius:50px;" ' +
                             'data-order="' + escapeAttr(r['COMPLETE_ORDER_NO']) + '" ' +
                             'data-detail="' + escapeAttr(r['ORDER_DETAIL_ID']) + '" ' +
                             'onclick="loadRadiology(this)" /></td>';
                }

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
                "scrollX": true,
                "order": []
            });
        }
    </script>
</asp:Content>

<asp:Content ID="BodyContent" runat="server" ContentPlaceHolderID="MainContent">
    <div class="emr-wrap">
        <h2 style="text-align: center; margin-bottom: 5px;">Client EMR Patient Lookup</h2>
        <p style="text-align: center; color: #888; margin-bottom: 20px;">
            Read-only lookup of patient information from the client's Oracle EMR database.
        </p>

        <div class="emr-search">
            <div class="label-field">
                <label for="txtKey" style="font-size: 16px;">Patient Number:</label>
            </div>
            <div class="input-field">
                <input autocomplete="off" type="text" id="txtKey" name="txtKey" class="textEntry"
                       style="border-radius: 10px !important;" placeholder="e.g. 001000071011" />
            </div>
        </div>

        <div style="text-align: center; margin-bottom: 10px;">
            <input class="btn-primry emr-btn" type="button" id="btnSearch" value="Search" onclick="SearchPatient()" />
            <input class="btn-primry emr-btn" type="button" id="btnTest" value="Test Connection" onclick="TestConnection()" />
        </div>

        <div class="emr-section">
            <h4>Patient Information</h4>
            <div class="table-container">
                <table id="tblHeader" class="table table-bordered table-striped" style="width: 100%;"></table>
            </div>
        </div>

        <div class="emr-section">
            <h4>Patient Services</h4>
            <div class="table-container">
                <table id="tblServices" class="table table-bordered table-striped" style="width: 100%;"></table>
            </div>
        </div>

        <div class="emr-section">
            <h4>Radiology Results</h4>
            <div class="table-container">
                <table id="tblRadiology" class="table table-bordered table-striped" style="width: 100%;"></table>
            </div>
        </div>
    </div>
</asp:Content>
