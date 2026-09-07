<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AnnexureDashboard.aspx.cs" Inherits="PMS.Modules.Dashboards.AnnexureDashboard" %>

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

        body { background: var(--ad-bg); }

        .ad-page { padding: 18px 22px 28px; }

        .ad-header {
            display: flex; align-items: center; justify-content: space-between;
            gap: 14px; margin-bottom: 14px; flex-wrap: wrap;
        }
        .ad-title {
            display: flex; align-items: center; gap: 12px;
        }
        .ad-title h2 {
            margin: 0; font-size: 20px; font-weight: 700; color: var(--ad-text);
            letter-spacing: .2px;
        }
        .ad-title .ad-sub {
            font-size: 12px; color: var(--ad-muted);
        }
        .ad-title .ad-dot {
            width: 10px; height: 10px; border-radius: 50%;
            background: var(--ad-primary); box-shadow: 0 0 0 4px var(--ad-primary-soft);
        }
        .ad-actions { display: flex; gap: 8px; flex-wrap: wrap; }

        .ad-card {
            background: var(--ad-card); border: 1px solid var(--ad-border);
            border-radius: 12px; box-shadow: 0 2px 10px rgba(15,23,42,.04);
            overflow: hidden;
        }

        .ad-toolbar {
            display: flex; align-items: center; justify-content: space-between;
            gap: 12px; padding: 12px 14px; border-bottom: 1px solid var(--ad-border);
            background: linear-gradient(180deg, #fbfbfd, #f5f7fb);
        }
        .ad-toolbar .ad-search {
            position: relative; flex: 0 0 280px; max-width: 100%;
        }
        .ad-toolbar .ad-search i {
            position: absolute; left: 10px; top: 50%; transform: translateY(-50%);
            color: var(--ad-muted); font-size: 13px;
        }
        .ad-toolbar .ad-search input {
            width: 100%; padding: 7px 10px 7px 30px;
            border: 1px solid var(--ad-border); border-radius: 8px;
            background: #fff; font-size: 13px; color: var(--ad-text);
            transition: border-color .15s, box-shadow .15s;
        }
        .ad-toolbar .ad-search input:focus {
            outline: none; border-color: var(--ad-primary);
            box-shadow: 0 0 0 3px var(--ad-primary-soft);
        }
        .ad-toolbar .ad-meta {
            font-size: 12px; color: var(--ad-muted);
        }

        .ad-table-wrap { overflow: auto; max-height: calc(100vh - 230px); }

        #tblPermissions {
            width: 100%; border-collapse: separate; border-spacing: 0;
            font-size: 13px; color: var(--ad-text);
        }
        #tblPermissions thead th {
            position: sticky; top: 0; z-index: 3;
            background: #fff; color: var(--ad-text);
            font-weight: 600; font-size: 12px; text-transform: uppercase;
            letter-spacing: .4px; padding: 10px 12px;
            border-bottom: 1px solid var(--ad-border);
            white-space: nowrap; vertical-align: middle;
        }
        #tblPermissions thead th:first-child {
            text-align: left; left: 0; z-index: 4; min-width: 260px;
            background: #fff;
        }
        #tblPermissions thead th .col-select { width: 160px; }

        #tblPermissions tbody td {
            padding: 8px 12px; border-bottom: 1px solid var(--ad-border);
            vertical-align: middle; white-space: nowrap;
        }
        #tblPermissions tbody td:first-child {
            position: sticky; left: 0; z-index: 1; background: #fff;
            border-right: 1px solid var(--ad-border);
        }
        #tblPermissions tbody tr:hover td { background: var(--ad-row-hover); }
        #tblPermissions tbody tr:hover td:first-child { background: var(--ad-row-hover); }

        #tblPermissions .cat-name {
            background: var(--ad-primary-soft) !important;
            color: #6b5313; font-weight: 700; font-size: 13px;
            letter-spacing: .2px; text-transform: uppercase;
            border-left: 3px solid var(--ad-primary);
        }
        #tblPermissions .cat-name td { padding: 10px 12px; }

        #tblPermissions .menu-name { padding-left: 22px !important; color: #374151; }

        #tblPermissions .check-mark {
            display: inline-flex; align-items: center; justify-content: center;
            width: 22px; height: 22px; border-radius: 50%;
            background: rgba(22,163,74,.12); color: var(--ad-success);
            font-weight: 700; font-size: 12px;
        }
        #tblPermissions .check-mark::before { content: "\f00c"; font-family: FontAwesome; }

        #tblPermissions .search-match td:first-child {
            background: #fff9c4 !important;
        }
        #tblPermissions .search-mismatch { opacity: .35; }

        .col-select { width: 180px; }

        @media (max-width: 768px) {
            .ad-toolbar .ad-search { flex: 1 1 100%; }
            .ad-table-wrap { max-height: calc(100vh - 280px); }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

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

    <div class="ad-page">
        <div class="ad-header">
            <div class="ad-title">
                <span class="ad-dot"></span>
                <div>
                    <h2>Permission Matrix</h2>
                    <div class="ad-sub">Roles &amp; Users vs. Menu Access</div>
                </div>
            </div>
            <div class="ad-actions">
                <button class="btn btn-primry btn-sm" onclick="exportExcel('User'); return false;">
                    <i class="fa fa-file-excel-o"></i> Export User Wise
                </button>
                <button class="btn btn-primry btn-sm" onclick="exportExcel('Role'); return false;">
                    <i class="fa fa-file-excel-o"></i> Export Role Wise
                </button>
            </div>
        </div>

        <div class="ad-card">
            <div class="ad-toolbar">
                <div class="ad-search">
                    <i class="fa fa-search"></i>
                    <input type="text" id="txtSearch" placeholder="Search menu..." />
                </div>
                <div class="ad-meta" id="adMeta">Loading...</div>
            </div>

            <div class="ad-table-wrap">
                <table id="tblPermissions" class="table table-bordered table-condensed">
                    <thead>
                        <tr>
                            <th>Menu</th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        var TOTAL_COLUMNS = 5;

        function addColumn(colIdx) {
            var $th = $('<th data-col="' + colIdx + '"><select class="col-select" data-col="' + colIdx + '"><option value=""></option></select></th>');
            $('#tblPermissions thead tr').append($th);

            $('#tblPermissions tbody tr').each(function () {
                $(this).append('<td data-col="' + colIdx + '" class="text-center"></td>');
            });

            var $sel = $th.find('select');

            $.ajax({
                type: "POST",
                url: "AnnexureDashboard.aspx/GetSelect2Data",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var items = response.d;
                    $sel.empty().append('<option value=""></option>');
                    items.forEach(function (item) {
                        $sel.append('<option value="' + item.id + '">' + escapeHtml(item.text) + '</option>');
                    });
                    $sel.select2({ placeholder: "Select Role / User", allowClear: true, width: 160, dropdownParent: $th });
                },
                error: function () {
                    $sel.select2({ placeholder: "Error loading", width: 160, dropdownParent: $th });
                }
            });

            $sel.on('change', function () {
                var val = $(this).val();
                if (!val) {
                    $('#tblPermissions tbody tr').each(function () {
                        $(this).find('td[data-col="' + colIdx + '"]').html('');
                    });
                    return;
                }

                $.ajax({
                    type: "POST",
                    url: "AnnexureDashboard.aspx/GetAllowedMenuIds",
                    data: JSON.stringify({ selectedValue: val }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        var allowedIds = response.d;
                        $('#tblPermissions tbody tr').each(function () {
                            var menuId = $(this).data('menu-id');
                            var $cell = $(this).find('td[data-col="' + colIdx + '"]');
                            if (allowedIds.indexOf(menuId) > -1) {
                                $cell.html('<span class="check-mark"></span>');
                            } else {
                                $cell.html('');
                            }
                        });
                    },
                    error: function () {
                        console.error("Failed to get allowed menu IDs");
                    }
                });
            });
        }

        var originalRows = [];

        function buildMenuSkeleton() {
            $.ajax({
                type: "POST",
                url: "AnnexureDashboard.aspx/GetMenuSkeleton",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var categories = response.d;
                    var $tbody = $('#tblPermissions tbody');
                    $tbody.empty();
                    originalRows = [];

                    var menuCount = 0;
                    categories.forEach(function (cat) {
                        var $catRow = $('<tr class="cat-row"></tr>');
                        $catRow.append('<td class="cat-name">' + escapeHtml(cat.CategoryName) + '</td>');
                        $tbody.append($catRow);
                        originalRows.push($catRow[0]);

                        cat.Menus.forEach(function (menu) {
                            menuCount++;
                            var $mRow = $('<tr data-menu-id="' + menu.Menu_ID + '"></tr>');
                            $mRow.append('<td class="menu-name">' + escapeHtml(menu.Menu_Name) + '</td>');
                            $tbody.append($mRow);
                            originalRows.push($mRow[0]);
                        });
                    });

                    for (var i = 0; i < TOTAL_COLUMNS; i++) {
                        addColumn(i);
                    }

                    $('#adMeta').text(menuCount + ' menus across ' + categories.length + ' categories');
                    $('#loading').hide();
                },
                error: function (xhr, status, error) {
                    console.error("Failed to load menu skeleton:", error);
                    $('#loading').hide();
                }
            });
        }

        var searchTimer;

        $('#txtSearch').on('input', function () {
            clearTimeout(searchTimer);
            var $input = $(this);
            searchTimer = setTimeout(function () {
                var q = $input.val().trim().toLowerCase();

                var $tbody = $('#tblPermissions tbody');
                var $allRows = $tbody.children('tr');

                if (!q) {
                    $allRows.removeClass('search-match search-mismatch').show();
                    if (originalRows.length) {
                        $.each(originalRows, function (i, el) { $tbody.append(el); });
                    }
                    return;
                }

                var $matching = $();
                var $nonMatching = $();

                $allRows.each(function () {
                    var $tr = $(this);
                    var txt = $tr.find('td:first').text().toLowerCase();
                    if (txt.indexOf(q) > -1) {
                        $matching = $matching.add(this);
                    } else {
                        $nonMatching = $nonMatching.add(this);
                    }
                });

                $allRows.removeClass('search-match search-mismatch').hide();

                if ($matching.length) {
                    $matching.addClass('search-match');
                    $nonMatching.addClass('search-mismatch');
                    $matching.prependTo($tbody);
                    $nonMatching.appendTo($tbody);
                } else {
                    $nonMatching.addClass('search-mismatch');
                }

                $matching.fadeIn(250);
                $nonMatching.fadeIn(500);
            }, 300);
        });

        function exportExcel(type) {
            var method = type === 'User' ? 'GetAllUsersExportData' : 'GetAllRolesExportData';
            $.ajax({
                type: "POST",
                url: "AnnexureDashboard.aspx/" + method,
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = response.d;

                    var html = '<table border="1"><thead><tr><th>Category</th><th>Menu</th>';
                    data.permissions.forEach(function (p) {
                        html += '<th>' + escapeHtml(p.Name) + '</th>';
                    });
                    html += '</tr></thead><tbody>';

                    var currentCategory = '';
                    data.menus.forEach(function (m) {
                        var cat = m.CategoryName || '';
                        if (cat !== currentCategory) {
                            currentCategory = cat;
                            html += '<tr><td style="font-weight:bold;background:#e8e8e8;">' + escapeHtml(cat) + '</td><td style="background:#e8e8e8;"></td>';
                            data.permissions.forEach(function () {
                                html += '<td style="background:#e8e8e8;"></td>';
                            });
                            html += '</tr>';
                        }
                        html += '<tr><td></td><td>' + escapeHtml(m.Menu_Name) + '</td>';
                        data.permissions.forEach(function (p) {
                            if (p.AllowedIds.indexOf(m.Menu_ID) > -1) {
                                html += '<td style="background:#c6efce;color:#006100;text-align:center;">YES</td>';
                            } else {
                                html += '<td style="text-align:center;">-</td>';
                            }
                        });
                        html += '</tr>';
                    });

                    html += '</tbody></table>';

                    var blob = new Blob([html], { type: 'application/vnd.ms-excel' });
                    var url = URL.createObjectURL(blob);
                    var a = document.createElement('a');
                    a.href = url;
                    a.download = type + '_Permissions.xls';
                    document.body.appendChild(a);
                    a.click();
                    document.body.removeChild(a);
                    URL.revokeObjectURL(url);
                },
                error: function () {
                    alert('Failed to export ' + type + ' data.');
                }
            });
        }

        $(document).on('keydown', '.select2-search__field', function (e) {
            if (e.which === 13) {
                e.preventDefault();
            }
        });

        $(document).ready(function () {
            buildMenuSkeleton();
        });

        function escapeHtml(str) {
            if (!str) return '';
            var div = document.createElement('div');
            div.appendChild(document.createTextNode(str));
            return div.innerHTML;
        }
    </script>

</asp:Content>
