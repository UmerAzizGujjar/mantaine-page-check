<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="PR_To_IGP_Dashboard.aspx.cs" Inherits="PMS.Modules.Dashboards.PR_To_IGP_Dashboard" %>
<%@ Assembly Name="System.Data.Linq, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="../../wwwroot/lib/echarts/echarts.min.js" type="text/javascript"></script>
    <style type="text/css">
        :root { --pi-ink: #1e293b; --pi-mute: #64748b; --pi-line: #e2e8f0; --pi-bg: #f8fafc; --pi-brand: #4f46e5; }
        .pi-hero { background: linear-gradient(120deg, #312e81 0%, #4f46e5 55%, #0ea5e9 100%); border-radius: 16px; padding: 20px 26px; color: #fff; margin-bottom: 16px; box-shadow: 0 10px 28px rgba(79,70,229,.25); }
        .pi-hero h1 { margin: 0; font-size: 1.5rem; font-weight: 700; letter-spacing: .2px; }
        .pi-hero p { margin: 5px 0 0; opacity: .9; font-size: .85rem; max-width: 900px; }
        .pi-filters { display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: 12px 14px; background: #fff; border: 1px solid var(--pi-line); border-radius: 14px; padding: 16px; margin-bottom: 8px; box-shadow: 0 1px 3px rgba(15,23,42,.05); }
        .pi-filters label { display: block; font-size: .68rem; font-weight: 700; color: var(--pi-mute); margin-bottom: 4px; text-transform: uppercase; letter-spacing: .4px; }
        .pi-filters input[type=text], .pi-filters input[type=number], .pi-filters select { width: 100%; height: 34px; border: 1px solid #cbd5e1; border-radius: 8px; padding: 2px 10px; font-size: .85rem; background: #fff; }
        .pi-filters input:focus, .pi-filters select:focus { outline: none; border-color: var(--pi-brand); box-shadow: 0 0 0 3px rgba(79,70,229,.15); }
        .pi-check { display: flex; align-items: center; gap: 8px; height: 34px; font-size: .85rem; color: var(--pi-ink); cursor: pointer; font-weight: 600; text-transform: none; letter-spacing: 0; }
        .pi-check input { width: 16px; height: 16px; }
        .pi-filter-actions { display: flex; gap: 8px; align-items: end; }
        .pi-btn { height: 34px; padding: 0 18px; border-radius: 8px; border: 1px solid transparent; font-weight: 700; font-size: .85rem; cursor: pointer; }
        .pi-btn.primary { background: var(--pi-brand); color: #fff; }
        .pi-btn.primary:hover { background: #4338ca; }
        .pi-btn.ghost { background: #fff; border-color: #cbd5e1; color: var(--pi-ink); }
        .pi-section { display: flex; align-items: center; gap: 10px; font-size: .78rem; font-weight: 800; text-transform: uppercase; letter-spacing: .7px; color: var(--pi-mute); margin: 22px 0 10px; }
        .pi-section::after { content: ''; flex: 1; height: 1px; background: var(--pi-line); }
        .pi-cards { display: grid; grid-template-columns: repeat(auto-fit, minmax(190px, 1fr)); gap: 12px; }
        .pi-card { position: relative; background: #fff; border: 1px solid var(--pi-line); border-radius: 14px; padding: 14px 14px 12px 14px; cursor: pointer; transition: box-shadow .15s, transform .15s, border-color .15s; display: grid; grid-template-columns: 1fr auto; gap: 2px 8px; box-shadow: 0 1px 3px rgba(15,23,42,.05); }
        .pi-card:hover { box-shadow: 0 8px 22px rgba(15,23,42,.12); transform: translateY(-2px); }
        .pi-card.active { border-color: var(--c); box-shadow: 0 0 0 2px var(--c); }
        .pi-card .ico { grid-row: 1 / span 3; grid-column: 2; width: 38px; height: 38px; border-radius: 10px; display: flex; align-items: center; justify-content: center; color: var(--c); background: color-mix(in srgb, var(--c) 14%, #fff); font-size: 17px; }
        .pi-card .lbl { font-size: .72rem; color: var(--pi-mute); font-weight: 700; }
        .pi-card .val { font-size: 1.7rem; font-weight: 800; color: var(--pi-ink); line-height: 1.15; }
        .pi-card .sub { font-size: .7rem; color: #94a3b8; min-height: 1em; }
        .pi-tag { display: inline-block; font-size: .58rem; font-weight: 800; padding: 1px 6px; border-radius: 6px; margin-left: 5px; vertical-align: middle; background: #eef2ff; color: #4338ca; letter-spacing: .3px; }
        .pi-tag.q { background: #ecfeff; color: #0e7490; }
        .pi-funnel { background: #fff; border: 1px solid var(--pi-line); border-radius: 14px; padding: 16px 18px; box-shadow: 0 1px 3px rgba(15,23,42,.05); }
        .pi-fstage { display: grid; grid-template-columns: 120px 1fr 260px; gap: 12px; align-items: center; margin-bottom: 10px; font-size: .82rem; }
        .pi-fbar { height: 30px; border-radius: 8px; background: linear-gradient(90deg, var(--c), color-mix(in srgb, var(--c) 65%, #fff)); color: #fff; font-weight: 800; display: flex; align-items: center; padding-left: 10px; min-width: 40px; cursor: pointer; transition: filter .15s; }
        .pi-fbar:hover { filter: brightness(1.08); }
        .pi-fmeta { color: #475569; font-size: .75rem; line-height: 1.3; }
        .pi-strip { display: flex; flex-wrap: wrap; gap: 8px; }
        .pi-pill { display: inline-flex; align-items: center; gap: 8px; background: #fff; border: 1px solid var(--pi-line); border-radius: 999px; padding: 4px 12px 4px 4px; cursor: pointer; font-size: .8rem; transition: box-shadow .15s; }
        .pi-pill:hover { box-shadow: 0 3px 10px rgba(15,23,42,.1); }
        .pi-pill b { font-size: .9rem; }
        .pi-charts { display: grid; grid-template-columns: repeat(auto-fit, minmax(400px, 1fr)); gap: 14px; }
        .pi-chart { background: #fff; border: 1px solid var(--pi-line); border-radius: 14px; padding: 12px 14px; box-shadow: 0 1px 3px rgba(15,23,42,.05); }
        .pi-chart h4 { margin: 0 0 4px; font-size: .84rem; font-weight: 800; color: var(--pi-ink); }
        .pi-chart .box { height: 270px; }
        .pi-table-wrap { background: #fff; border: 1px solid var(--pi-line); border-radius: 14px; padding: 14px; margin-top: 6px; overflow-x: auto; box-shadow: 0 1px 3px rgba(15,23,42,.05); }
        .pi-tabs { display: flex; gap: 6px; align-items: center; margin-bottom: 10px; flex-wrap: wrap; }
        .pi-tab { border: 1px solid var(--pi-line); background: var(--pi-bg); border-radius: 999px; padding: 4px 16px; font-size: .8rem; font-weight: 700; cursor: pointer; color: var(--pi-mute); }
        .pi-tab.on { background: var(--pi-brand); border-color: var(--pi-brand); color: #fff; }
        .pi-chip { background: #eef2ff; border: 1px solid #c7d2fe; color: #3730a3; border-radius: 999px; padding: 3px 12px; font-size: .78rem; font-weight: 600; display: none; }
        .pi-chip a { margin-left: 8px; color: #3730a3; font-weight: 800; cursor: pointer; }
        .pi-banner { display: none; background: linear-gradient(90deg, #eef2ff, #f0f9ff); border: 1px solid #c7d2fe; border-radius: 12px; padding: 10px 16px; margin-bottom: 10px; font-size: .85rem; color: #1e1b4b; }
        .pi-banner b { font-weight: 800; }
        .pi-badge { display: inline-block; padding: 3px 10px; border-radius: 999px; font-size: .7rem; font-weight: 700; color: #fff; white-space: nowrap; }
        .pi-none { display: inline-block; padding: 2px 8px; border-radius: 6px; font-size: .72rem; font-weight: 700; color: #b45309; background: #fffbeb; border: 1px dashed #fbbf24; white-space: nowrap; }
        .pi-prog { height: 5px; border-radius: 3px; background: #e2e8f0; margin-top: 3px; min-width: 60px; overflow: hidden; }
        .pi-prog span { display: block; height: 100%; background: #22c55e; }
        table.pi-grid thead th { font-size: .7rem; text-transform: uppercase; letter-spacing: .4px; color: var(--pi-mute); background: var(--pi-bg); }
        table.pi-grid th, table.pi-grid td { font-size: .78rem; vertical-align: middle; }
        table.pi-grid td.num { text-align: right; font-variant-numeric: tabular-nums; }
        .pi-doc { display: inline-block; margin: 0 4px 2px 0; padding: 1px 8px; border-radius: 6px; background: #eef2ff; font-size: .74rem; font-weight: 600; text-decoration: none; color: #4338ca; }
        .pi-doc:hover { background: #e0e7ff; text-decoration: none; }
        .pi-doc.draft { background: #fef9c3; color: #854d0e; }
        #piLoader { display: none; position: fixed; inset: 0; background: rgba(248,250,252,.7); z-index: 9999; align-items: center; justify-content: center; font-weight: 700; color: var(--pi-brand); }
    </style>

    <script type="text/javascript">
        var PAGE = "PR_To_IGP_Dashboard.aspx";
        var DATA = null, dtItems = null, dtPos = null;
        var drill = { tab: 'items', key: 'all', label: '' };
        var charts = {};
        var COLORS = { Pending: '#94a3b8', 'Pending Approval': '#94a3b8', 'Pending PO': '#ef4444', 'Partially Ordered': '#f97316', 'Pending IGP': '#8b5cf6', 'Partially Received': '#f59e0b', 'Fully Received': '#22c55e', 'Cancelled/Closed': '#64748b',
                       'Draft': '#94a3b8', 'Completed': '#22c55e' };
        function noteHtml(t) { return '<span class="pi-none">' + t + '</span>'; }
        function bar(v, max) { var p = max > 0 ? Math.min(100, Math.round(v * 100 / max)) : 0; return '<div class="pi-prog"><span style="width:' + p + '%"></span></div>'; }

        function esc(s) { return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]; }); }
        function fmt(n) { return Number(n || 0).toLocaleString(undefined, { maximumFractionDigits: 2 }); }
        function dateOut(iso) { if (!iso) return ''; var m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'], p = iso.split('-'); return p[2] + '-' + m[+p[1] - 1] + '-' + p[0]; }
        function badge(t) { return '<span class="pi-badge" style="background:' + (COLORS[t] || '#6c757d') + '">' + esc(t) + '</span>'; }
        function prLink(id, no) { return '<a class="pi-doc" target="_blank" href="../AP/PurchaseRequistion.aspx?ID=' + id + '">PR ' + esc(no) + '</a>'; }
        function poLink(d) { return '<a class="pi-doc' + (d[2] === 'D' ? ' draft' : '') + '" target="_blank" title="' + (d[2] === 'D' ? 'Draft PO (not counted)' : 'Approved PO') + '" href="../AP/PurchaseOrder.aspx?PO_ID=' + d[0] + '">PO ' + esc(d[1]) + '</a>'; }
        function igpLink(d) { return '<a class="pi-doc' + (d[2] === 'D' ? ' draft' : '') + '" target="_blank" title="' + (d[2] === 'D' ? 'IGP not approved (not counted)' : 'Approved IGP') + '" href="../Inventory/InversionGatePass.aspx?IGP_Id=' + d[0] + '">IGP ' + esc(d[1]) + '</a>'; }

        var ITEM_PRED = {
            all: function (r) { return true; },
            pr_pending: function (r) { return r.PrStatus === 'Pending'; },
            pr_approved: function (r) { return r.PrStatus === 'Approved'; },
            pr_cancelled: function (r) { return r.PrStatus === 'Cancelled'; },
            pr_pendpo: function (r) { return r.PrStatus === 'Approved' && r.RemOrder > 0 && r.Proc !== 'Cancelled/Closed'; },
            po_created: function (r) { return r.Ord > 0; },
            po_pendigp: function (r) { return r.RemReceive > 0; },
            igp_created: function (r) { return r.IgpDocs.length > 0; },
            complete: function (r) { return r.Proc === 'Fully Received'; },
            live: function (r) { return r.PrStatus !== 'Cancelled'; }
        };
        var PO_PRED = {
            pos_all: function (p) { return p.Status !== 'Draft'; },
            pos_pending: function (p) { return p.Status !== 'Draft' && p.Status !== 'Completed'; },
            pos_complete: function (p) { return p.Status === 'Completed'; },
            pos_draft: function (p) { return p.Status === 'Draft'; }
        };

        function filters() {
            return {
                sdate: $('#fFrom').val(), edate: $('#fTo').val(), prNo: $('#fPRNo').val(), dept: $('#fDept').val(), warehouse: $('#fWh').val(),
                itemId: $('#fItemId').val(), vendorId: $('#fVendor').val(), prStatus: $('#fPRStatus').val(), poStatus: $('#fPOStatus').val(), igpStatus: $('#fIGPStatus').val(),
                procStatus: $('#fProc').val(), pendingOnly: $('#fPending').is(':checked')
            };
        }

        function api(method, data, ok) {
            $.ajax({
                type: 'POST', url: PAGE + '/' + method, data: JSON.stringify(data || {}),
                contentType: 'application/json; charset=utf-8', dataType: 'json',
                success: function (r) {
                    var res = JSON.parse(r.d);
                    if (res && res.Denied) { Swal.fire('Access Denied', 'You do not have permission to view this dashboard.', 'error').then(function () { window.location = '../../Default.aspx'; }); return; }
                    ok(res);
                },
                error: function () { $('#piLoader').hide(); Swal.fire('Error', 'Failed to load procurement data (' + method + ').', 'error'); }
            });
        }

        $(document).ready(function () {
            $('#fFrom, #fTo').datepicker({ dateFormat: 'yy-mm-dd' });
            var d = new Date(); d.setDate(d.getDate() - 90);
            $('#fFrom').val($.datepicker.formatDate('yy-mm-dd', d));
            $('#fTo').val($.datepicker.formatDate('yy-mm-dd', new Date()));

            dtItems = $('#tblItems').DataTable({
                data: [], deferRender: true, pageLength: 25, lengthMenu: [[25, 50, 100, -1], [25, 50, 100, 'All']], order: [[1, 'desc']],
                dom: 'Blfrtip', buttons: ['copy', 'excel'],
                language: { emptyTable: 'No PR items for the selected filters.' },
                columns: [
                    { data: 'PrNo', render: function (v, t, r) { return t === 'display' ? prLink(r.PrId, v) : v; } },
                    { data: 'PrDate', render: function (v, t) { return t === 'display' ? dateOut(v) : v; } },
                    { data: 'PrStatus' },
                    { data: 'ItemCode', render: function (v, t, r) { return t === 'display' ? '<b>' + esc(v) + '</b><br/><span style="color:#6c757d">' + esc(r.ItemName) + '</span>' : v + ' ' + r.ItemName; } },
                    { data: 'Req', className: 'num', render: function (v, t) { return t === 'display' ? fmt(v) : v; } },
                    { data: 'Appr', className: 'num', render: function (v, t) { return t === 'display' ? fmt(v) : v; } },
                    { data: 'PoDocs', render: function (v, t) { return t === 'display' ? (v.length ? v.map(poLink).join('') : noteHtml('No PO Created')) : v.map(function (x) { return x[1]; }).join(' '); } },
                    { data: 'Ord', className: 'num', render: function (v, t, r) { return t === 'display' ? fmt(v) + bar(v, r.Appr || r.Req) : v; } },
                    { data: 'IgpDocs', render: function (v, t, r) { return t === 'display' ? (v.length ? v.map(igpLink).join('') : (r.PoDocs.length ? noteHtml('No IGP Created') : '<span style="color:#94a3b8">&mdash;</span>')) : v.map(function (x) { return x[1]; }).join(' '); } },
                    { data: 'Rcv', className: 'num', render: function (v, t, r) { return t === 'display' ? fmt(v) + bar(v, r.Ord) : v; } },
                    { data: 'RemOrder', className: 'num', render: function (v, t) { return t === 'display' ? fmt(v) : v; } },
                    { data: 'RemReceive', className: 'num', render: function (v, t) { return t === 'display' ? fmt(v) : v; } },
                    { data: 'Proc', render: function (v, t) { return t === 'display' ? badge(v) : v; } }
                ]
            });
            dtPos = $('#tblPos').DataTable({
                data: [], deferRender: true, pageLength: 25, order: [[0, 'desc']],
                language: { emptyTable: 'No POs for the selected filters.' },
                columns: [
                    { data: 'PoNo', render: function (v, t, r) { return t === 'display' ? poLink([r.PoId, v, r.Status === 'Draft' ? 'D' : 'A']) : v; } },
                    { data: 'PoDate', render: function (v, t) { return t === 'display' ? dateOut(v) : v; } },
                    { data: 'Vendor', render: function (v, t) { return t === 'display' ? esc(v) : v; } },
                    { data: 'PRs', render: function (v, t) { return t === 'display' ? v.map(function (x) { return prLink(x[0], x[1]); }).join('') : v.map(function (x) { return x[1]; }).join(' '); } },
                    { data: 'Items', className: 'num' },
                    { data: 'ItemsPending', className: 'num' },
                    { data: 'Ord', className: 'num', render: function (v, t) { return t === 'display' ? fmt(v) : v; } },
                    { data: 'Rcv', className: 'num', render: function (v, t) { return t === 'display' ? fmt(v) : v; } },
                    { data: 'Remaining', className: 'num', render: function (v, t) { return t === 'display' ? fmt(v) : v; } },
                    { data: 'Status', render: function (v, t) { return t === 'display' ? badge(v) : v; } }
                ]
            });

            ['trend', 'conv', 'qty', 'dept', 'pend', 'gauge'].forEach(function (k) { charts[k] = echarts.init(document.getElementById('ch_' + k)); });
            window.addEventListener('resize', function () { for (var k in charts) charts[k].resize(); });

            api('GetLookups', {}, function (l) {
                function fill(sel, arr, all) { var h = '<option value="">' + all + '</option>'; arr.forEach(function (x) { h += '<option value="' + esc(x.Id) + '">' + esc(x.Name) + '</option>'; }); $(sel).html(h); }
                fill('#fDept', l.Departments, 'All'); fill('#fWh', l.Warehouses, 'All'); fill('#fVendor', l.Vendors, 'All');
            });

            var itemMap = {}, timer = null;
            $('#fItem').on('input', function () {
                var v = $(this).val();
                if (itemMap[v]) { $('#fItemId').val(itemMap[v]); return; }
                $('#fItemId').val('');
                clearTimeout(timer);
                if (v.length < 2) return;
                timer = setTimeout(function () {
                    api('SearchItems', { term: v }, function (list) {
                        var h = ''; itemMap = {};
                        list.forEach(function (x) { var label = x.Code + ' - ' + x.Name; itemMap[label] = x.Id; h += '<option value="' + esc(label) + '"></option>'; });
                        $('#itemList').html(h);
                    });
                }, 250);
            });

            load();
        });

        function load() {
            $('#piLoader').css('display', 'flex');
            api('GetDashboard', filters(), function (res) {
                DATA = res;
                renderCards(res.Summary);
                renderBanner(res.Rows);
                renderFunnel(res.Funnel);
                renderCharts(res);
                applyDrill();
                $('#piLoader').hide();
            });
        }

        function clearFilters() {
            $('.pi-filters input[type=text], .pi-filters input[type=number], .pi-filters select, #fItemId').val('');
            $('#fPending').prop('checked', false);
            load();
        }

        var ICONS = { 'Total PRs Created': 'fa-file-text-o', 'Approved PRs': 'fa-check-circle', 'Pending PRs': 'fa-clock-o', 'Rejected / Cancelled PRs': 'fa-ban', 'PRs Pending PO': 'fa-hourglass-half',
                      'Total POs Created': 'fa-shopping-cart', 'POs Pending IGP': 'fa-truck', 'Completed IGPs (POs)': 'fa-check-square-o', 'Total Items Requested': 'fa-list-ul', 'Total Items Ordered': 'fa-cubes', 'Total Items Received': 'fa-inbox' };
        function card(key, tab, label, value, sub, color, tag) {
            return '<div class="pi-card" data-key="' + key + '" style="--c:' + color + '" onclick="setDrill(\'' + tab + '\',\'' + key + '\',\'' + label.replace(/'/g, '') + '\')">' +
                '<div class="lbl">' + esc(label) + (tag ? '<span class="pi-tag' + (tag === 'QTY' ? ' q' : '') + '">' + tag + '</span>' : '') + '</div><div class="ico"><i class="fa ' + (ICONS[label] || 'fa-circle') + '"></i></div><div class="val">' + value + '</div><div class="sub">' + (sub || '&nbsp;') + '</div></div>';
        }

        function renderBanner(rows) {
            var no = $('#fPRNo').val();
            if (!no || !rows.length) { $('#prBanner').hide(); return; }
            var items = rows.length, withPO = rows.filter(function (r) { return r.PoDocs.length; }).length, withIGP = rows.filter(function (r) { return r.IgpDocs.length; }).length;
            $('#prBanner').html('<b>PR ' + esc(no) + '</b> &mdash; ' + items + ' items: <b>' + withPO + '</b> with PO, <b>' + (items - withPO) + '</b> without PO, <b>' + withIGP + '</b> with IGP, <b>' + (withPO - withIGP) + '</b> ordered but no IGP.').show();
        }

        function renderCards(s) {
            var h = '';
            h += card('live', 'items', 'Total PRs Created', fmt(s.TotalPRs), 'incl. ' + fmt(s.CancelledPRs) + ' cancelled', '#0d6efd', 'DOCS');
            h += card('pr_approved', 'items', 'Approved PRs', fmt(s.ApprovedPRs), '', '#28a745', 'DOCS');
            h += card('pr_pending', 'items', 'Pending PRs', fmt(s.PendingPRs), 'awaiting approval', '#6c757d', 'DOCS');
            h += card('pr_cancelled', 'items', 'Rejected / Cancelled PRs', fmt(s.CancelledPRs), '', '#dc3545', 'DOCS');
            h += card('pr_pendpo', 'items', 'PRs Pending PO', fmt(s.PRsPendingPO), fmt(s.PRItemsPendingPO) + ' PR items without full PO', '#fd7e14', 'DOCS');
            h += card('pos_all', 'pos', 'Total POs Created', fmt(s.TotalPOs), fmt(s.DraftPOs) + ' draft PO(s) not counted', '#6f42c1', 'DOCS');
            h += card('pos_pending', 'pos', 'POs Pending IGP', fmt(s.POsPendingIGP), fmt(s.POItemsPendingIGP) + ' PO items open', '#dc3545', 'DOCS');
            h += card('pos_complete', 'pos', 'Completed IGPs (POs)', fmt(s.CompletedPOs), fmt(s.CompletedPOItems) + ' PR items fully received', '#28a745', 'DOCS');
            h += card('live', 'items', 'Total Items Requested', fmt(s.ItemsRequested), fmt(s.ItemLines) + ' PR item lines', '#0d6efd', 'QTY');
            h += card('po_created', 'items', 'Total Items Ordered', fmt(s.ItemsOrdered), 'approved POs only', '#6f42c1', 'QTY');
            h += card('igp_created', 'items', 'Total Items Received', fmt(s.ItemsReceived), 'approved IGPs only', '#28a745', 'QTY');
            $('#cards').html(h);
        }

        function renderFunnel(f) {
            var max = Math.max.apply(null, f.map(function (x) { return x.Docs; }).concat([1]));
            var colors = ['#0d6efd', '#17a2b8', '#6f42c1', '#fd7e14', '#28a745'];
            var keys = ['live', 'pr_approved', 'po_created', 'igp_created', 'complete'];
            var h = '';
            f.forEach(function (x, i) {
                var w = Math.max(6, Math.round(x.Docs * 100 / max));
                var conv = i === 0 ? '' : '<b>' + x.DocPct + '%</b> docs / <b>' + x.ItemPct + '%</b> items vs previous';
                h += '<div class="pi-fstage"><div><b>' + esc(x.Stage) + '</b></div>' +
                    '<div><div class="pi-fbar" style="--c:' + colors[i] + ';width:' + w + '%;cursor:pointer" onclick="setDrill(\'items\',\'' + keys[i] + '\',\'' + x.Stage + '\')">' + fmt(x.Docs) + ' docs</div></div>' +
                    '<div class="pi-fmeta">' + fmt(x.Items) + ' PR items &middot; qty ' + fmt(x.Qty) + '<br/>' + conv + '</div></div>';
            });
            $('#funnel').html(h);
        }

        function opt(title, extra) { return $.extend(true, { title: { show: false }, tooltip: { trigger: 'axis' }, grid: { left: 44, right: 16, top: 30, bottom: 30, containLabel: true }, legend: { top: 0, textStyle: { fontSize: 11 } } }, extra); }

        function renderCharts(d) {
            var s = d.Summary, live = d.Rows.filter(ITEM_PRED.live), appr = live.filter(function (r) { return r.PrStatus === 'Approved'; });

            charts.trend.setOption(opt('', {
                xAxis: { type: 'category', data: d.Trend.map(function (x) { return x.Period; }) }, yAxis: { type: 'value', minInterval: 1 },
                series: [{ name: 'PRs Created', type: 'bar', data: d.Trend.map(function (x) { return x.Created; }), itemStyle: { color: '#0d6efd' } },
                         { name: 'PRs Approved', type: 'line', smooth: true, data: d.Trend.map(function (x) { return x.Approved; }), itemStyle: { color: '#28a745' } }]
            }), true);

            var po0 = appr.filter(function (r) { return r.Ord <= 0; }).length, poP = appr.filter(function (r) { return r.Ord > 0 && r.RemOrder > 0; }).length, poF = appr.length - po0 - poP;
            var ordered = live.filter(function (r) { return r.Ord > 0; });
            var ig0 = ordered.filter(function (r) { return r.Rcv <= 0; }).length, igF = ordered.filter(function (r) { return r.Rcv >= r.Ord; }).length, igP = ordered.length - ig0 - igF;
            charts.conv.setOption(opt('', {
                tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
                xAxis: { type: 'category', data: ['PR items -> PO', 'PO items -> IGP'] }, yAxis: { type: 'value' },
                series: [{ name: 'Not started', type: 'bar', stack: 's', data: [po0, ig0], itemStyle: { color: '#dc3545' } },
                         { name: 'Partial', type: 'bar', stack: 's', data: [poP, igP], itemStyle: { color: '#f39c12' } },
                         { name: 'Complete', type: 'bar', stack: 's', data: [poF, igF], itemStyle: { color: '#28a745' } }]
            }), true);

            charts.qty.setOption(opt('', {
                tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
                xAxis: { type: 'category', data: ['Requested', 'Ordered', 'Received'] }, yAxis: { type: 'value' }, legend: { show: false },
                series: [{ type: 'bar', barMaxWidth: 60, label: { show: true, position: 'top', formatter: function (p) { return fmt(p.value); } },
                           data: [{ value: s.ItemsRequested, itemStyle: { color: '#0d6efd' } }, { value: s.ItemsOrdered, itemStyle: { color: '#6f42c1' } }, { value: s.ItemsReceived, itemStyle: { color: '#28a745' } }] }]
            }), true);

            charts.dept.setOption(opt('', {
                tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
                xAxis: { type: 'value', minInterval: 1 }, yAxis: { type: 'category', inverse: true, data: d.DeptPending.map(function (x) { return x.Dept; }) },
                series: [{ name: 'Pending approval', type: 'bar', stack: 's', data: d.DeptPending.map(function (x) { return x.PendingApproval; }), itemStyle: { color: '#adb5bd' } },
                         { name: 'Approved, PO pending', type: 'bar', stack: 's', data: d.DeptPending.map(function (x) { return x.PendingPO; }), itemStyle: { color: '#dc3545' } }]
            }), true);

            charts.pend.setOption(opt('', {
                tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
                xAxis: { type: 'category', data: ['Pending PO items', 'Pending IGP items'] }, yAxis: { type: 'value' }, legend: { show: false },
                series: [{ type: 'bar', barMaxWidth: 70, label: { show: true, position: 'top' },
                           data: [{ value: s.PRItemsPendingPO, itemStyle: { color: '#fd7e14' } }, { value: s.POItemsPendingIGP, itemStyle: { color: '#dc3545' } }] }]
            }), true);

            charts.gauge.setOption({
                series: [{ type: 'gauge', min: 0, max: 100, progress: { show: true, width: 14 }, axisLine: { lineStyle: { width: 14 } }, pointer: { show: false },
                           axisTick: { show: false }, splitLine: { show: false }, axisLabel: { show: false },
                           detail: { valueAnimation: true, fontSize: 30, offsetCenter: [0, 0], formatter: '{value}%' }, itemStyle: { color: '#28a745' },
                           data: [{ value: d.Completion }] }]
            }, true);

            charts.dept.off('click').on('click', function () { setDrill('items', 'pr_pending', 'Pending PRs'); });
            charts.pend.off('click').on('click', function (p) { setDrill('items', p.dataIndex === 0 ? 'pr_pendpo' : 'po_pendigp', p.name); });
            charts.conv.off('click').on('click', function (p) { setDrill('items', p.dataIndex === 0 ? 'pr_pendpo' : 'po_pendigp', p.name); });
            charts.qty.off('click').on('click', function (p) { setDrill('items', ['live', 'po_created', 'igp_created'][p.dataIndex], p.name); });

            var sc = d.StatusCounts, h = '';
            ['Pending Approval', 'Pending PO', 'Partially Ordered', 'Pending IGP', 'Partially Received', 'Fully Received', 'Cancelled/Closed'].forEach(function (k) {
                h += '<span class="pi-pill" onclick="setDrill(\'items\',\'status:' + k + '\',\'' + k + '\')">' + badge(k) + ' <b>' + fmt(sc[k] || 0) + '</b></span>';
            });
            $('#statusStrip').html(h);
        }

        function setDrill(tab, key, label) {
            drill = { tab: tab, key: key, label: label };
            $('#tabItems').toggleClass('on', tab === 'items'); $('#tabPos').toggleClass('on', tab === 'pos');
            applyDrill();
            $('html, body').animate({ scrollTop: $('#detailArea').offset().top - 70 }, 250);
        }

        function applyDrill() {
            if (!DATA) return;
            var key = drill.key, pred;
            if (drill.tab === 'items') {
                if (key.indexOf('status:') === 0) { var st = key.substring(7); pred = function (r) { return r.Proc === st; }; } else pred = ITEM_PRED[key] || ITEM_PRED.all;
                dtItems.clear().rows.add(DATA.Rows.filter(pred)).draw();
                $('#wrapItems').show(); $('#wrapPos').hide();
            } else {
                pred = PO_PRED[key] || PO_PRED.pos_all;
                dtPos.clear().rows.add(DATA.POs.filter(pred)).draw();
                $('#wrapItems').hide(); $('#wrapPos').show();
            }
            $('.pi-card').removeClass('active'); $('.pi-card[data-key="' + key + '"]').addClass('active');
            var showChip = drill.label && key !== 'all';
            $('#chip').toggle(!!showChip).find('span').text('Showing: ' + drill.label);
        }

        function clearDrill() { drill.key = 'all'; drill.label = ''; applyDrill(); }
        function switchTab(tab) { setDrill(tab, tab === 'items' ? 'all' : 'pos_all', ''); }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="piLoader"><div>Loading procurement data...</div></div>

    <div class="pi-hero">
        <h1>Procurement Lifecycle &mdash; PR &#8594; PO &#8594; IGP</h1>
        <p>Purchase Requisition to Purchase Order to Inward Gate Pass, tracked per PR item. Only PR-linked POs are counted; ordered = approved POs, received = approved IGPs.</p>
    </div>

    <div class="pi-filters">
        <div><label>From (PR date)</label><input type="text" id="fFrom" autocomplete="off" /></div>
        <div><label>To (PR date)</label><input type="text" id="fTo" autocomplete="off" /></div>
        <div><label>PR Number</label><input type="number" id="fPRNo" min="0" /></div>
        <div><label>Department</label><select id="fDept"><option value="">All</option></select></div>
        <div><label>Store / Warehouse</label><select id="fWh"><option value="">All</option></select></div>
        <div><label>Item</label><input type="text" id="fItem" list="itemList" placeholder="Type code or name" autocomplete="off" /><datalist id="itemList"></datalist><input type="hidden" id="fItemId" /></div>
        <div><label>Supplier / Vendor</label><select id="fVendor"><option value="">All</option></select></div>
        <div><label>PR Status</label><select id="fPRStatus"><option value="">All</option><option value="Pending">Pending approval</option><option value="Approved">Approved</option><option value="Cancelled">Cancelled</option></select></div>
        <div><label>PO Status</label><select id="fPOStatus"><option value="">All</option><option value="None">No PO</option><option value="Draft">Draft only</option><option value="Approved">Approved PO</option></select></div>
        <div><label>IGP / GRN Status</label><select id="fIGPStatus"><option value="">All</option><option value="NotReceived">Not received</option><option value="Partial">Partially received</option><option value="Complete">Fully received</option></select></div>
        <div><label>Procurement Status</label><select id="fProc"><option value="">All</option><option>Pending Approval</option><option>Pending PO</option><option>Partially Ordered</option><option>Pending IGP</option><option>Partially Received</option><option>Fully Received</option><option>Cancelled/Closed</option></select></div>
        <div><label>&nbsp;</label><label class="pi-check"><input type="checkbox" id="fPending" /> Only items pending PO or IGP</label></div>
        <div class="pi-filter-actions">
            <button type="button" class="pi-btn primary" onclick="load(); return false;">Search</button>
            <button type="button" class="pi-btn ghost" onclick="clearFilters(); return false;">Clear</button>
        </div>
    </div>

    <div class="pi-banner" id="prBanner"></div>
    <div class="pi-section">Summary <span class="pi-tag">DOCS</span> document counts <span class="pi-tag q">QTY</span> item quantities</div>
    <div class="pi-cards" id="cards"></div>

    <div class="pi-section">Procurement lifecycle</div>
    <div class="pi-funnel" id="funnel"></div>

    <div class="pi-section">PR item status</div>
    <div id="statusStrip"></div>

    <div class="pi-charts">
        <div class="pi-chart"><h4>PR creation &amp; approval trend (by PR date)</h4><div class="box" id="ch_trend"></div></div>
        <div class="pi-chart"><h4>PR &#8594; PO and PO &#8594; IGP conversion (item lines)</h4><div class="box" id="ch_conv"></div></div>
        <div class="pi-chart"><h4>Requested vs ordered vs received quantity</h4><div class="box" id="ch_qty"></div></div>
        <div class="pi-chart"><h4>Pending PRs by department</h4><div class="box" id="ch_dept"></div></div>
        <div class="pi-chart"><h4>Pending PO items &amp; pending IGP items</h4><div class="box" id="ch_pend"></div></div>
        <div class="pi-chart"><h4>Procurement completion (received / approved qty)</h4><div class="box" id="ch_gauge"></div></div>
    </div>

    <div class="pi-table-wrap" id="detailArea">
        <div class="pi-tabs">
            <span class="pi-tab on" id="tabItems" onclick="switchTab('items')">PR items</span>
            <span class="pi-tab" id="tabPos" onclick="switchTab('pos')">Purchase orders</span>
            <span class="pi-chip" id="chip"><span></span><a onclick="clearDrill()">&times;</a></span>
        </div>

        <div id="wrapItems">
            <table id="tblItems" class="display pi-grid" style="width:100%">
                <thead><tr>
                    <th>PR No</th><th>PR Date</th><th>PR Status</th><th>Item</th><th>Requested</th><th>Approved</th>
                    <th>PO No(s)</th><th>Ordered</th><th>IGP No(s)</th><th>Received</th><th>Remaining to Order</th><th>Remaining to Receive</th><th>Status</th>
                </tr></thead>
            </table>
        </div>
        <div id="wrapPos" style="display:none">
            <table id="tblPos" class="display pi-grid" style="width:100%">
                <thead><tr>
                    <th>PO No</th><th>PO Date</th><th>Vendor</th><th>PR(s)</th><th>Items</th><th>Items Open</th><th>Ordered</th><th>Received</th><th>Remaining</th><th>Status</th>
                </tr></thead>
            </table>
        </div>
    </div>
</asp:Content>

