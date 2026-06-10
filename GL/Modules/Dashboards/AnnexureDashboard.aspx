<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AnnexureDashboard.aspx.cs" Inherits="PMS.Modules.Dashboards.AnnexureDashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        #tblPermissions { width: 100%; border-collapse: collapse; }
        #tblPermissions th, #tblPermissions td { border: 1px solid #ddd; padding: 8px; text-align: left; white-space: nowrap; }
        #tblPermissions th { background-color: #f5f5f5; font-weight: 600; }
        #tblPermissions tbody tr:nth-child(even) { background-color: #fafafa; }
        #tblPermissions .cat-name { font-size: 16px; font-weight: 700; background-color: #e8e8e8; }
        #tblPermissions .menu-name { padding-left: 24px !important; }
        #tblPermissions .check-mark { color: #28a745; font-size: 18px; font-weight: bold; text-align: center; }
        #tblPermissions .search-match td:first-child { background-color: #fff9c4 !important; }
        #tblPermissions .search-mismatch { opacity: 0.35; }
        .col-select { width: 180px; }
        .table-wrap { overflow-x: auto; margin: 0; }
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

    <div style="margin-bottom: 6px;">
        <button class="btn btn-primry btn-sm" onclick="exportExcel('User'); return false;" style="padding: 6px 20px; width: auto;"><i class="fa fa-file-excel-o"></i> Export Excel (User Wise)</button>
        <button class="btn btn-primry btn-sm" onclick="exportExcel('Role'); return false;" style="padding: 6px 20px; width: auto;"><i class="fa fa-file-excel-o"></i> Export Excel (Role Wise)</button>
    </div>

    <div class="table-wrap">
        <table id="tblPermissions" class="table table-bordered table-condensed">
            <thead>
                <tr>
                    <th style="min-width: 260px;">
                        <input type="text" id="txtSearch" placeholder="Search menu..." style="width: 200px; padding: 3px 6px; border: 1px solid #ccc; border-radius: 3px; float: right; margin-top: -2px;" />
                    </th>
                </tr>
            </thead>
            <tbody></tbody>
        </table>
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
                    $sel.select2({ placeholder: "Select Role / User", allowClear: true, width: 180 });
                },
                error: function () {
                    $sel.select2({ placeholder: "Error loading", width: 180 });
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
                                $cell.html('<span class="check-mark">&#10003;</span>');
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

                    categories.forEach(function (cat) {
                        var $catRow = $('<tr class="cat-row"></tr>');
                        $catRow.append('<td class="cat-name">' + escapeHtml(cat.CategoryName) + '</td>');
                        $tbody.append($catRow);
                        originalRows.push($catRow[0]);

                        cat.Menus.forEach(function (menu) {
                            var $mRow = $('<tr data-menu-id="' + menu.Menu_ID + '"></tr>');
                            $mRow.append('<td class="menu-name">' + escapeHtml(menu.Menu_Name) + '</td>');
                            $tbody.append($mRow);
                            originalRows.push($mRow[0]);
                        });
                    });

                    for (var i = 0; i < TOTAL_COLUMNS; i++) {
                        addColumn(i);
                    }

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
