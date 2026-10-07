/* ==========================================================================
   MODERN DATA TABLES - behaviour (pair of table-modern.css). Plain JavaScript.
   Wraps every DataTable in a .tm-scroll box so a wide table scrolls sideways
   inside its own frame (the page itself never gets a horizontal scrollbar).
   If this file does not load, the tables still look right - they just scroll
   with the page like before.
   ========================================================================== */
(function () {
    'use strict';

    function wrap(table) {
        if (!table || !table.parentNode) { return; }
        var parent = table.parentNode;
        /* only the main table of a normal DataTables wrapper; skip scrollY copies, nested tables, already wrapped */
        if (!parent.classList || !parent.classList.contains('dataTables_wrapper')) { return; }
        var box = document.createElement('div');
        box.className = 'tm-scroll';
        parent.insertBefore(box, table);
        box.appendChild(table);
    }

    function sweep(root) {
        var list = (root || document).querySelectorAll('.dataTables_wrapper > table.dataTable');
        for (var i = 0; i < list.length; i++) { wrap(list[i]); tidy(list[i]); }
    }

    /* ---- column tidy-up: right-align number columns, let long text wrap ------------------------
       Purely visual: only adds the classes tm-num / tm-wrap (see table-modern.css); no cell text,
       sort order, data or events are touched.                                                    */
    var NUM_RE = /^[\-+(]?\s*[\d,]+(\.\d+)?\s*%?\)?$/;
    var AMOUNT_HEAD_RE = /qty|quantity|amount|total|price|cost|rate|balance|debit|credit|stock|tax|discount|bonus|paid|payable|receiv|value|count|salary|charges|fee/i;
    var LONG_TEXT = 26;     /* characters; longer than this the cell may wrap */

    function tidy(table) {
        try {
            if (!table || !table.tBodies || !table.tBodies.length || !table.tHead || !table.tHead.rows.length) { return; }
            var rows = table.tBodies[0].rows;
            if (!rows.length) { return; }
            var headRow = table.tHead.rows[table.tHead.rows.length - 1];
            var cols = headRow.cells.length;
            var limit = Math.min(rows.length, 300);
            for (var c = 0; c < cols; c++) {
                var th = headRow.cells[c];
                var seen = 0, nums = 0, decimals = 0, skip = false;
                for (var r = 0; r < limit; r++) {
                    var row = rows[r];
                    if (row.cells.length !== cols) { continue; }               /* "no data" row, child rows */
                    var td = row.cells[c];
                    if (td.querySelector('a, button, input, select, textarea, img, i.fa')) { skip = true; break; }   /* action / editor columns */
                    var txt = (td.textContent || '').trim();
                    if (txt === '') { continue; }
                    if (txt.length > LONG_TEXT) { td.classList.add('tm-wrap'); }
                    seen++;
                    if (NUM_RE.test(txt)) { nums++; if (/[.,]/.test(txt)) { decimals++; } }
                }
                if (skip || !seen) { continue; }
                /* leave columns that the page deliberately centres alone */
                var al = window.getComputedStyle(th).textAlign;
                if (al === 'center') { continue; }
                var head = (th.textContent || '').trim();
                var isNumber = nums === seen && (decimals > 0 || AMOUNT_HEAD_RE.test(head));
                if (isNumber) {
                    th.classList.add('tm-num');
                    for (var k = 0; k < limit; k++) {
                        var rw = rows[k];
                        if (rw.cells.length === cols) { rw.cells[c].classList.add('tm-num'); }
                    }
                }
            }
        } catch (err) { /* cosmetic only - never break the page */ }
    }

    /* every time DataTables finishes building / redrawing a table (also after a postback re-init) */
    if (window.jQuery) {
        window.jQuery(document).on('init.dt', function (e) { wrap(e.target); tidy(e.target); });
        window.jQuery(document).on('draw.dt', function (e) { tidy(e.target); });
    }

    /* tables that were built before this script ran */
    if (document.readyState === 'loading') { document.addEventListener('DOMContentLoaded', function () { sweep(); }); }
    else { sweep(); }
    window.addEventListener('load', function () { sweep(); });
})();
