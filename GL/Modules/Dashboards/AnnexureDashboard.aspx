<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="AnnexureDashboard.aspx.cs"
    Inherits="PMS.Modules.Dashboards.AnnexureDashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <style>

        :root {
            --ad-primary: #c89b2c;
            --ad-primary-soft: #f6efd9;
            --ad-bg: #f4f6fa;
            --ad-card: #ffffff;
            --ad-border: #e6e9ef;
            --ad-text: #1f2937;
            --ad-muted: #6b7280;
            --ad-success: #16a34a;
            --ad-row-hover: #f9fafb;
        }

        body {
            background: var(--ad-bg);
        }

        .ad-page {
            padding: 18px 22px 28px;
        }

        /* ========================================
           HEADER
        ======================================== */

        .ad-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 14px;
            margin-bottom: 14px;
            flex-wrap: wrap;
        }

        .ad-title {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .ad-title h2 {
            margin: 0;
            font-size: 20px;
            font-weight: 700;
            color: var(--ad-text);
            letter-spacing: .2px;
        }

        .ad-title .ad-sub {
            font-size: 12px;
            color: var(--ad-muted);
        }

        .ad-title .ad-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: var(--ad-primary);
            box-shadow: 0 0 0 4px var(--ad-primary-soft);
        }

        .ad-actions {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }

        /* ========================================
           CARD
        ======================================== */

        .ad-card {
            background: var(--ad-card);
            border: 1px solid var(--ad-border);
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(15,23,42,.04);
            overflow: hidden;
        }

        /* ========================================
           MODE BUTTONS
        ======================================== */

        .search-mode-bar {
            padding: 12px 14px;
            border-bottom: 1px solid var(--ad-border);
            background: linear-gradient(180deg, #fbfbfd, #f5f7fb);
        }

        .mode-button-group {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            width: 100%;
        }

        .mode-btn {
            flex: 1 1 0;
            min-width: 150px;
            padding: 10px 16px;
            font-size: 14px;
            font-weight: 600;
            text-align: center;
            white-space: nowrap;
            border: 1px solid var(--ad-border);
            border-radius: 8px;
            background: #ffffff;
            color: var(--ad-text);
            cursor: pointer;
            transition: all 0.15s ease;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.03);
        }

        .mode-btn:hover {
            background: var(--ad-primary-soft);
            border-color: var(--ad-primary);
        }

        .mode-btn.active {
            background: var(--ad-primary);
            border-color: var(--ad-primary);
            color: #ffffff;
            box-shadow: 0 2px 8px rgba(200, 155, 44, 0.30);
        }

        /* ========================================
           SEARCH AREA
        ======================================== */

        .search-area {
            width: 100% !important;
            height: 42px !important;
            min-height: 42px !important;
            max-height: 42px !important;
            padding: 6px 0 !important;
            display: flex !important;
            flex-direction: row !important;
            align-items: center !important;
            gap: 10px !important;
            box-sizing: border-box !important;
            background: #fff !important;
            border: 1px solid var(--ad-border) !important;
            border-radius: 6px !important;
            overflow: visible !important;
        }

        .search-area .select2-container {
            width: 100% !important;
            max-width: 100% !important;
            flex: 1 1 100% !important;
            height: 30px !important;
            min-height: 30px !important;
            max-height: 30px !important;
            margin: 0 !important;
        }

        .search-area .select2-container .select2-selection--multiple {
            width: 100% !important;
        }


/* Select2 multiple box */

.search-area
.select2-container--default
.select2-selection--multiple {

    width: 100% !important;

    min-height: 30px !important;

    padding: 0 5px !important;
    margin: 0 !important;

    border: 1px solid var(--ad-border) !important;
    border-radius: 4px !important;

    box-sizing: border-box !important;

    background: #fff !important;
}


/* Selected items area */

.search-area
.select2-container--default
.select2-selection--multiple
.select2-selection__rendered {

    display: flex !important;
    flex-wrap: nowrap !important;
    width: 100% !important;

    padding: 0 !important;
    margin: 0 !important;

    line-height: 26px !important;

    box-sizing: border-box !important;

    overflow: visible !important;
}


/* Selected tag */

.search-area
.select2-container--default
.select2-selection--multiple
.select2-selection__choice {

    flex-shrink: 0 !important;

    height: 22px !important;

    margin-top: 3px !important;
    margin-bottom: 0 !important;

    padding: 0 6px !important;

    line-height: 20px !important;

    font-size: 11px !important;

    border-radius: 3px !important;

    box-sizing: border-box !important;
}


/* Search input inside Select2 */

.search-area
.select2-container--default
.select2-selection--multiple
.select2-search--inline {

    flex: 1 1 0 !important;
    min-width: 80px !important;

    height: 26px !important;

    margin: 0 !important;
    padding: 0 !important;
}


.search-area
.select2-container--default
.select2-selection--multiple
.select2-search--inline
.select2-search__field {

    height: 26px !important;

    margin: 0 !important;
    padding: 0 4px !important;

    line-height: 26px !important;

    box-sizing: border-box !important;

    border: none !important;

    outline: none !important;
}




        /* ========================================
           SINGLE SELECT2
        ======================================== */

        .search-area
        .select2-container--default
        .select2-selection--single {

            height: 28px !important;

            min-height: 28px !important;

            max-height: 28px !important;

            border-color: var(--ad-border) !important;


            border-radius: 4px !important;

            box-sizing: border-box !important;
        }

        .search-area
        .select2-container--default
        .select2-selection--single
        .select2-selection__rendered {

            line-height: 26px !important;

            height: 26px !important;

            padding-left: 6px !important;

            font-size: 12px !important;
        }

        .search-area
        .select2-container--default
        .select2-selection--single
        .select2-selection__arrow {

            height: 26px !important;
        }

        .search-area
        .select2-container--default
        .select2-selection--single
        .select2-selection__arrow b {

            margin-top: 1px;
        }

        /* ========================================
           SELECT2 SEARCH INPUT
        ======================================== */

        .select2-search--dropdown .select2-search__field {

            padding: 3px 6px !important;

            font-size: 12px !important;

            height: 26px !important;

            box-sizing: border-box !important;
        }

        /* ========================================
           SEARCH BUTTON
        ======================================== */

        /* ========================================
           RESULTS CONTAINER
        ======================================== */

        #resultsContainer {

            padding: 0 14px 12px;
        }

        .ad-results-head {
            padding: 14px 0 10px;
            border-bottom: 1px dashed var(--ad-border);
            margin-bottom: 10px;
        }

        .ad-results-head h4 {
            margin: 0 0 4px;
            font-size: 15px;
            font-weight: 700;
            color: var(--ad-primary);
            letter-spacing: .2px;
        }

        .ad-results-head .ad-results-sub {
            font-size: 12px;
            color: var(--ad-muted);
            margin: 0;
        }

        .ad-results-head .ad-results-user-name {
            color: var(--ad-primary);
            font-weight: 600;
            margin-left: 4px;
        }

        #resultsContainer .table {

            width: 100%;

            border-collapse: collapse;

            font-size: 13px;

            color: var(--ad-text);

            margin: 0;
        }

        #resultsContainer .table th {

            background: #f8f9fc;

            font-weight: 600;

            text-transform: uppercase;

            font-size: 11px;

            letter-spacing: 0.3px;

            padding: 8px 10px;

            border-bottom: 2px solid var(--ad-border);
        }

        #resultsContainer .table td {

            padding: 7px 10px;

            border-bottom: 1px solid var(--ad-border);

            vertical-align: middle;
        }

        #resultsContainer .table tr:hover td {

            background: var(--ad-row-hover);
        }

        #resultsContainer .table .toggle-perms {

            color: var(--ad-primary);

            text-decoration: none;

            font-weight: 600;

            cursor: pointer;

            display: inline-flex;

            align-items: center;

            gap: 4px;

            background: transparent;

            border: none;

            padding: 0;

            font-size: 12px;
        }

        #resultsContainer .table .toggle-perms:hover {

            text-decoration: underline;
        }

        #resultsContainer .table .toggle-perms .fa {
            transition: transform .15s ease;
            display: inline-block;
            margin-left: 4px;
        }

        #resultsContainer .table tr.role-row.expanded td {
            background: #fbfaf3;
        }

        #resultsContainer .table tr.perms-row td {
            padding: 0;
            background: #fafbfc;
            border-bottom: 1px solid var(--ad-border);
        }

        #resultsContainer .table .perms-cell {
            padding: 10px 14px;
            font-size: 12px;
        }

        #resultsContainer .table .perms-cell .perms-title {
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            color: var(--ad-muted);
            letter-spacing: .3px;
            margin: 0 0 6px;
        }

        #resultsContainer .table .perms-cell .perms-table {
            width: 100%;
            border-collapse: collapse;
            margin: 0;
        }

        #resultsContainer .table .perms-cell .perms-table th {
            background: #fff;
            border-bottom: 1px solid var(--ad-border);
            font-size: 10px;
            text-transform: uppercase;
            color: var(--ad-muted);
            padding: 6px 8px;
            letter-spacing: .3px;
        }

        #resultsContainer .table .perms-cell .perms-table td {
            padding: 5px 8px;
            border-bottom: 1px dashed var(--ad-border);
            font-size: 12px;
        }

        #resultsContainer .table .status-badge {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 10px;
            font-size: 10px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .3px;
        }

        #resultsContainer .table .status-badge.active {
            background: #e7f6ec;
            color: #16a34a;
        }

        #resultsContainer .table .status-badge.inactive {
            background: #fdecec;
            color: #c0392b;
        }

        #resultsContainer .text-muted {

            color: var(--ad-muted);

            font-style: italic;

            padding: 12px 0;

            text-align: center;
        }

        #resultsContainer .ad-table-wrap {
            max-height: 460px;
            overflow: auto;
            border: 1px solid var(--ad-border);
            border-radius: 8px;
        }

        #resultsContainer .ad-table-wrap .table {
            border: none;
        }

        #resultsContainer .ad-table-wrap .table thead th {
            position: sticky;
            top: 0;
            z-index: 2;
        }

        /* ========================================
           RESULTS FOOTER
        ======================================== */

        .ad-results-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
            padding: 10px 14px;
            border-top: 1px solid var(--ad-border);
            background: #fafbfc;
        }

        .ad-results-footer .total-roles {
            font-size: 12px;
            color: var(--ad-text);
            font-weight: 500;
        }

        .ad-results-footer .total-roles b {
            color: var(--ad-primary);
            font-weight: 700;
        }

        #exportBtn {

            padding: 6px 20px;

            border: none;

            border-radius: 6px;

            background: var(--ad-primary);

            color: #fff;

            font-weight: 500;

            font-size: 13px;

            cursor: pointer;

            transition: background 0.15s;
        }

        #exportBtn:hover {

            background: #b0861e;
        }

        .export-wrapper {

            padding: 6px 14px 14px;

            border-top: 1px solid var(--ad-border);

            text-align: right;
        }

        /* ========================================
           RESPONSIVE
        ======================================== */

        @media (max-width: 768px) {

            .ad-page {
                padding: 12px;
            }

            /*
                Keep search controls on the same row
                instead of stacking them vertically.
            */

            .search-area {
                flex-direction: row !important;
                align-items: center !important;
                flex-wrap: nowrap !important;
                height: 42px !important;
                min-height: 42px !important;
                max-height: 42px !important;
                padding: 6px 0 !important;
            }

            .search-area .select2-container {
                flex: 1 1 100% !important;
                min-width: 0 !important;
                height: 30px !important;
                min-height: 30px !important;
                max-height: 30px !important;
            }

            #resultsContainer {

                max-height: 400px;
            }

            #resultsContainer .table {

                font-size: 12px;
            }

            #resultsContainer .table th,
            #resultsContainer .table td {

                padding: 5px 6px;
            }

            .ad-header {

                flex-direction: column;

                align-items: flex-start;
            }

            .export-wrapper {

                text-align: center;
            }

            .mode-btn {

                min-width: 100px;

                padding: 8px 10px;

                font-size: 12px;
            }
        }

        /* ========================================
           VERY SMALL SCREENS
        ======================================== */

        @media (max-width: 500px) {

            .search-area {
                padding: 3px 0 !important;
                gap: 5px !important;
            }

            .search-area .select2-container {
                min-width: 0 !important;
            }
        }

        /* ========================================
           HIDDEN
        ======================================== */

        .hidden {

            display: none !important;
        }

    </style>

</asp:Content>


<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <!-- ========================================
         LOADING
    ======================================== -->

    <div id="loading">

        <div id="loading-center">

            <div id="loading-center-absolute">

                <div class="object" id="object_one"></div>
                <div class="object" id="object_two"></div>
                <div class="object" id="object_three"></div>
                <div class="object" id="object_four"></div>
                <div class="object" id="object_five"></div>
                <div class="object" id="object_six"></div>
                <div class="object" id="object_seven"></div>
                <div class="object" id="object_eight"></div>
                <div class="object" id="object_big"></div>

            </div>

        </div>

    </div>


    <!-- ========================================
         PAGE
    ======================================== -->

    <div class="ad-page">

        <!-- Header -->

        <div class="ad-header">

            <div class="ad-title">

                <span class="ad-dot"></span>

                <div>

                    <h2>
                        Annexure Dashboard
                    </h2>

                    <div class="ad-sub">
                        Search Roles, Users &amp; Permissions
                    </div>

                </div>

            </div>

        </div>


        <!-- ========================================
             CARD
        ======================================== -->

        <div class="ad-card">


            <!-- ====================================
                 MODE BUTTONS
            ==================================== -->

            <div class="search-mode-bar">

                <div class="mode-button-group">

                    <button
                        type="button"
                        class="btn mode-btn active"
                        data-mode="roles-by-user">

                        Search Roles by User

                    </button>


                    <button
                        type="button"
                        class="btn mode-btn"
                        data-mode="users-by-role">

                        Search Users by Role

                    </button>


                    <button
                        type="button"
                        class="btn mode-btn"
                        data-mode="roles-users-by-module">

                        Search Roles &amp; Users by Module

                    </button>

                </div>

            </div>


            <!-- ====================================
                 SEARCH BAR
            ==================================== -->

            <div class="search-area">

                <select
                    id="searchSelect"
                    style="width:100%;">
                </select>

            </div>


            <!-- ====================================
                 RESULTS
            ==================================== -->

            <div id="resultsContainer">

                <div class="ad-results-head">

                    <h4>Search Results</h4>

                    <p class="ad-results-sub">
                        Show role, rights, module access assigned to user:<span id="adResultsUserName" class="ad-results-user-name hidden"></span>
                    </p>

                </div>


                <div class="ad-table-wrap">

                    <table class="table" id="tblResults">

                        <thead>

                            <tr>

                                <th style="width: 50px;">#</th>

                                <th>Role Name</th>

                                <th>Role Description</th>

                                <th>Module/Department</th>

                                <th style="width: 90px;">Status</th>

                                <th style="width: 120px;">Action</th>

                            </tr>

                        </thead>

                        <tbody id="tblResultsBody">

                            <tr>

                                <td colspan="6" class="text-muted">
                                    Select a search mode and pick an option to view results.
                                </td>

                            </tr>

                        </tbody>

                    </table>

                </div>

            </div>


            <!-- ====================================
                 RESULTS FOOTER
            ==================================== -->

            <div class="ad-results-footer">

                <div class="total-roles">
                    Total Roles: <b id="totalRolesCount">0</b>
                </div>

                <button
                    id="exportBtn"
                    class="btn btn-primary"
                    style="display: none;">

                    Export as Excel

                </button>

            </div>


        </div>

    </div>


    <!-- ========================================
         JAVASCRIPT
    ======================================== -->
    <script type="text/javascript">

        /* ========================================
           STATE
        ======================================== */

        var currentMode = 'roles-by-user';
        var currentSelection = null;
        var cachedSelect2Items = [];
        var select2Ready = false;


        var MODE_PLACEHOLDERS = {
            'roles-by-user': 'Search User',
            'users-by-role': 'Search Role',
            'roles-users-by-module': 'Search Module'
        };

        var MODE_LABELS = {
            'roles-by-user': 'roles',
            'users-by-role': 'users',
            'roles-users-by-module': 'roles'
        };


        /* ========================================
           MODE BUTTONS
        ======================================== */

        $('.mode-btn').on('click', function () {
            $('.mode-btn').removeClass('active');
            $(this).addClass('active');
            currentMode = $(this).data('mode');
            loadSelect2Options(currentMode);
            resetResults();
        });


        /* ========================================
           SELECT2 OPTIONS LOADER
        ======================================== */

        var currentVal = null;

        function forceWidth() {
            var $area = $('#searchSelect').closest('.search-area');
            var w = $area.width();
            var $sel = $('#searchSelect');
            if (!$sel.data('select2')) return;
            var $c = $sel.data('select2').$container;
            $c.css({ width: w + 'px', 'max-width': w + 'px' });
        }

        $(window).on('resize', forceWidth);
        $('#searchSelect').on('select2:open', function () {
            setTimeout(forceWidth, 0);
        });

        function loadSelect2Options(mode) {
            var $sel = $('#searchSelect');

            if (select2Ready && $sel.data('select2')) {
                $sel.select2('destroy');
            }
            $sel.empty().append('<option value=""></option>');

            $.ajax({
                type: "POST",
                url: "AnnexureDashboard.aspx/GetSearchOptions",
                data: JSON.stringify({ mode: mode }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    cachedSelect2Items = response.d || [];
                    cachedSelect2Items.forEach(function (item) {
                        $sel.append(
                            '<option value="' + item.id + '">' +
                            escapeHtml(item.text) + '</option>'
                        );
                    });

                    $sel.select2({
                        placeholder: MODE_PLACEHOLDERS[mode] || "Search",
                        allowClear: true
                    });
                    select2Ready = true;
                    forceWidth();

                    if (currentVal && cachedSelect2Items.some(function (i) { return i.id === currentVal; })) {
                        $sel.val(currentVal).trigger('change.select2');
                    } else {
                        $sel.val(null).trigger('change.select2');
                    }
                },
                error: function (xhr, status, err) {
                    console.error('Failed to load search options for mode: ' + mode, err, xhr.responseText);
                }
            });
        }


        /* ========================================
           RESET
        ======================================== */

        function resetResults() {
            currentSelection = null;
            $('#adResultsUserName').text('').addClass('hidden');
            $('#tblResultsBody').html(
                '<tr><td colspan="6" class="text-muted">' +
                'Select a search mode and pick an option to view results.' +
                '</td></tr>'
            );
            $('#totalRolesCount').text('0');
            $('#exportBtn').hide();
        }


        /* ========================================
           RENDER HELPERS
        ======================================== */

        function statusBadge(status) {
            var cls = (status || '').toLowerCase() === 'active' ? 'active' : 'inactive';
            return '<span class="status-badge ' + cls + '">' + escapeHtml(status || '') + '</span>';
        }


        /* ========================================
           RENDER RESULTS — Mode 1 & 3 (role rows)
        ======================================== */

        function renderRoleRows(roles, userLabel) {
            var $body = $('#tblResultsBody');
            $body.empty();

            if (!roles || !roles.length) {
                $body.html(
                    '<tr><td colspan="6" class="text-muted">' +
                    'No roles found for the selected option.' +
                    '</td></tr>'
                );
                $('#totalRolesCount').text('0');
                $('#exportBtn').hide();
                return;
            }

            if (userLabel) {
                $('#adResultsUserName').text(userLabel).removeClass('hidden');
            }
            $('#totalRolesCount').text(roles.length);
            $('#exportBtn').show();

            roles.forEach(function (r, idx) {
                var $row = $(
                    '<tr class="role-row" data-role-idx="' + idx + '">' +
                    '<td>' + (idx + 1) + '</td>' +
                    '<td>' + escapeHtml(r.roleName || '') + '</td>' +
                    '<td>' + escapeHtml(r.roleDescription || '') + '</td>' +
                    '<td>' + escapeHtml(r.module || '') + '</td>' +
                    '<td>' + statusBadge(r.status) + '</td>' +
                    '<td>' +
                    '<button type="button" class="toggle-perms">' +
                    '<span class="label">View Rights</span>' +
                    '<i class="fa fa-chevron-down"></i>' +
                    '</button>' +
                    '</td>' +
                    '</tr>'
                );

                var $permsRow = $(
                    '<tr class="perms-row" data-role-idx="' + idx + '" style="display:none;">' +
                    '<td colspan="6">' +
                    '<div class="perms-cell">' +
                    '<p class="perms-title">Role Rights / Permissions</p>' +
                    '<table class="perms-table">' +
                    '<thead><tr>' +
                    '<th style="width:30%;">Module / Menu</th>' +
                    '<th style="width:25%;">Right / Permission</th>' +
                    '<th>Description</th>' +
                    '</tr></thead>' +
                    '<tbody></tbody>' +
                    '</table>' +
                    '</div>' +
                    '</td>' +
                    '</tr>'
                );

                var $pBody = $permsRow.find('tbody');
                (r.rights || []).forEach(function (p) {
                    $pBody.append(
                        '<tr>' +
                        '<td>' + escapeHtml(p.module || '') + '</td>' +
                        '<td>' + escapeHtml(p.right || '') + '</td>' +
                        '<td>' + escapeHtml(p.desc || '') + '</td>' +
                        '</tr>'
                    );
                });

                if (r.users && r.users.length) {
                    $permsRow.find('.perms-cell').append(
                        '<p class="perms-title" style="margin-top:10px;">Users in this Role</p>' +
                        '<table class="perms-table">' +
                        '<thead><tr>' +
                        '<th>User Name</th>' +
                        '<th style="width:120px;">Status</th>' +
                        '</tr></thead>' +
                        '<tbody></tbody>' +
                        '</table>'
                    );
                    var $uBody = $permsRow.find('.perms-table').eq(1).find('tbody');
                    r.users.forEach(function (u) {
                        $uBody.append(
                            '<tr>' +
                            '<td>' + escapeHtml(u.userName || '') + '</td>' +
                            '<td>' + statusBadge(u.status) + '</td>' +
                            '</tr>'
                        );
                    });
                }

                $body.append($row);
                $body.append($permsRow);
            });
        }


        /* ========================================
           RENDER RESULTS — Mode 2 (user rows)
        ======================================== */

        function renderUserRows(users, roleLabel) {
            var $body = $('#tblResultsBody');
            $body.empty();

            if (!users || !users.length) {
                $body.html(
                    '<tr><td colspan="6" class="text-muted">' +
                    'No users found for the selected role.' +
                    '</td></tr>'
                );
                $('#totalRolesCount').text('0');
                $('#exportBtn').hide();
                return;
            }

            if (roleLabel) {
                $('#adResultsUserName').text(roleLabel).removeClass('hidden');
            }
            $('#totalRolesCount').text(users.length);
            $('#exportBtn').show();

            users.forEach(function (u, idx) {
                var $row = $(
                    '<tr class="role-row" data-role-idx="' + idx + '">' +
                    '<td>' + (idx + 1) + '</td>' +
                    '<td>' + escapeHtml(u.userName || '') + '</td>' +
                    '<td>&mdash;</td>' +
                    '<td>' + escapeHtml(currentSelectionRoleLabel || '') + '</td>' +
                    '<td>' + statusBadge(u.status) + '</td>' +
                    '<td><span class="text-muted" style="font-size:11px;">No rights</span></td>' +
                    '</tr>'
                );
                $body.append($row);
            });
        }


        /* ========================================
           TOGGLE RIGHTS
        ======================================== */

        $(document).on('click', '.toggle-perms', function () {
            var $btn = $(this);
            var idx = $btn.closest('tr').data('role-idx');
            var $permsRow = $('.perms-row[data-role-idx="' + idx + '"]');
            var expanded = $btn.hasClass('expanded');

            if (expanded) {
                $permsRow.hide();
                $btn.removeClass('expanded');
                $btn.find('.label').text('View Rights');
                $btn.find('.fa').removeClass('fa-chevron-up').addClass('fa-chevron-down');
            } else {
                $permsRow.show();
                $btn.addClass('expanded');
                $btn.find('.label').text('Hide Rights');
                $btn.find('.fa').removeClass('fa-chevron-down').addClass('fa-chevron-up');
            }
        });


        /* ========================================
           SEARCH HANDLER
        ======================================== */

        var searchTimer;
        var currentSelectionRoleLabel = '';

        $('#searchSelect').on('select2:select select2:unselect', function () {
            clearTimeout(searchTimer);
            searchTimer = setTimeout(handleSelection, 250);
        });


        function handleSelection() {
            var firstVal = $('#searchSelect').val();
            if (!firstVal) {
                resetResults();
                return;
            }

            var item = cachedSelect2Items.find(function (i) { return i.id === firstVal; });
            var label = item ? item.text : firstVal;
            currentSelection = firstVal;
            currentSelectionRoleLabel = label;

            if (currentMode === 'roles-by-user') {
                runSearch('SearchRolesByUser', { selectedValue: firstVal }, label, 'roles');
            } else if (currentMode === 'users-by-role') {
                runSearch('SearchUsersByRole', { selectedValue: firstVal }, label, 'users');
            } else if (currentMode === 'roles-users-by-module') {
                runSearch('SearchRolesUsersByModule', { selectedValue: firstVal }, label, 'roles');
            }
        }


        function runSearch(method, payload, label, kind) {
            $.ajax({
                type: "POST",
                url: "AnnexureDashboard.aspx/" + method,
                data: JSON.stringify(payload),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = response.d || {};
                    if (kind === 'users') {
                        renderUserRows(data.users || [], label);
                    } else {
                        renderRoleRows(data.roles || [], label);
                    }
                },
                error: function (xhr, status, err) {
                    console.error('Search failed: ' + method, err, xhr.responseText);
                    if (kind === 'users') {
                        renderUserRows([], label);
                    } else {
                        renderRoleRows([], label);
                    }
                }
            });
        }


        /* ========================================
           EXPORT
        ======================================== */

        $('#exportBtn').on('click', function () {
            var rows = $('#tblResultsBody tr.role-row');
            if (!rows.length) return;

            var html =
                '<table border="1">' +
                '<thead><tr>' +
                '<th>#</th><th>Role Name</th><th>Role Description</th>' +
                '<th>Module/Department</th><th>Status</th>' +
                '</tr></thead><tbody>';

            rows.each(function () {
                var $tds = $(this).find('td');
                html += '<tr>' +
                    '<td>' + $tds.eq(0).text() + '</td>' +
                    '<td>' + $tds.eq(1).text() + '</td>' +
                    '<td>' + $tds.eq(2).text() + '</td>' +
                    '<td>' + $tds.eq(3).text() + '</td>' +
                    '<td>' + $tds.eq(4).text() + '</td>' +
                    '</tr>';
            });

            html += '</tbody></table>';

            var blob = new Blob([html], { type: 'application/vnd.ms-excel' });
            var url = URL.createObjectURL(blob);
            var a = document.createElement('a');
            a.href = url;
            a.download = 'RoleSearchResults.xls';
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
        });


        /* ========================================
           SELECT2 ENTER KEY
        ======================================== */

        $(document).on('keydown', '.select2-search__field', function (e) {
            if (e.which === 13) {
                e.preventDefault();
            }
        });


        /* ========================================
           DOCUMENT READY
        ======================================== */

        $(document).ready(function () {
            loadSelect2Options(currentMode);
            $('#loading').hide();
        });


        /* ========================================
           ESCAPE HTML
        ======================================== */

        function escapeHtml(str) {
            if (!str) return '';
            var div = document.createElement('div');
            div.appendChild(document.createTextNode(str));
            return div.innerHTML;
        }

    </script>

</asp:Content>