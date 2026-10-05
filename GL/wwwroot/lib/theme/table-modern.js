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
        for (var i = 0; i < list.length; i++) { wrap(list[i]); }
    }

    /* every time DataTables finishes building a table (also after a postback re-init) */
    if (window.jQuery) {
        window.jQuery(document).on('init.dt', function (e) { wrap(e.target); });
    }

    /* tables that were built before this script ran */
    if (document.readyState === 'loading') { document.addEventListener('DOMContentLoaded', function () { sweep(); }); }
    else { sweep(); }
    window.addEventListener('load', function () { sweep(); });
})();
