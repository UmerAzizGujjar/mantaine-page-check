/* Companion of modal-modern.css (one size for every Bootstrap modal).
   Fixes what a stylesheet cannot, only when a modal is built / opened. Layout only - content, ids,
   events and page logic are never touched. Opt out with class="modal-free-size" on the .modal element.

   1. .modal-dialog / .modal-content: removes hard-coded sizes and offsets from the page, e.g.
      style="width:1140px !important; margin-left:-306px; height:604px" (inline !important beats any stylesheet).
   2. Inside .modal-body, to stop content overlapping or being cut off:
        - big negative margins (margin-top:-420px, margin-left:-244px ...) are removed, together with the
          matching big positive margin-left used to put one block next to another (they only worked for
          the old, wider modal and made blocks overlap in the new one);
        - overflow:scroll (empty scrollbars always visible) becomes overflow:auto;
        - a plain block with a fixed inline height keeps it as a minimum, so content longer than that
          grows downwards instead of spilling over the next block. Scroll boxes, editors, tables,
          inputs, images and plugin widgets are left alone.
   3. DataTables inside the modal are re-aligned once the modal is visible (their column widths are
      measured while the modal is still hidden). */
(function (window, document) {
    var DIALOG = ['width', 'min-width', 'max-width', 'height', 'min-height', 'max-height', 'margin', 'margin-left', 'margin-right', 'margin-top', 'margin-bottom', 'left', 'top', 'right', 'bottom'];
    var CONTENT = DIALOG.concat(['position']);
    var BODY = ['height', 'max-height', 'min-height'];
    var SIDES = ['margin-top', 'margin-right', 'margin-bottom', 'margin-left'];
    var KEEP_CLASS = /(^|\s)(close|cke[\w-]*|select2[\w-]*|dataTables[\w-]*|dt-[\w-]*|token-input[\w-]*|ui-[\w-]*|ptTime[\w-]*|dropdown[\w-]*|modal-(dialog|content|header|body|footer)|swal2[\w-]*)(\s|$)/;
    var BLOCK_TAGS = { DIV: 1, SECTION: 1, FIELDSET: 1, FORM: 1, UL: 1, OL: 1, P: 1 };

    function strip(el, props) {
        if (!el || !el.style || !el.style.length) { return; }
        for (var i = 0; i < props.length; i++) { el.style.removeProperty(props[i]); }
    }

    function px(v) { var n = parseFloat(v); return (v && /px\s*$/.test(v) && !isNaN(n)) ? n : null; }

    function fixInner(el) {
        var st = el.style;
        if (!st || !st.length) { return; }
        var cls = (typeof el.className === 'string') ? el.className : '';
        var i, v, n;

        // 1) block placed with big negative margins -> back into normal flow
        var removedNegative = false;
        for (i = 0; i < SIDES.length; i++) {
            v = st.getPropertyValue(SIDES[i]); n = px(v);
            if (n !== null && n <= -40) { st.removeProperty(SIDES[i]); removedNegative = true; }
        }
        if (removedNegative) {
            n = px(st.getPropertyValue('margin-left'));
            if (n !== null && n >= 200) { st.removeProperty('margin-left'); }   // "put it next to the other block" offset
            n = px(st.getPropertyValue('margin-right'));
            if (n !== null && n >= 200) { st.removeProperty('margin-right'); }
        }

        // 2) permanent empty scrollbars
        if (st.getPropertyValue('overflow') === 'scroll') { st.setProperty('overflow', 'auto', st.getPropertyPriority('overflow')); }
        if (st.getPropertyValue('overflow-x') === 'scroll') { st.setProperty('overflow-x', 'auto', st.getPropertyPriority('overflow-x')); }
        if (st.getPropertyValue('overflow-y') === 'scroll') { st.setProperty('overflow-y', 'auto', st.getPropertyPriority('overflow-y')); }

        // 3) fixed inline height on a plain block -> minimum height (content grows instead of overlapping)
        if (BLOCK_TAGS[el.tagName] && !KEEP_CLASS.test(cls)) {
            v = st.getPropertyValue('height'); n = px(v);
            if (n !== null && n > 0 && !/hidden|auto|scroll/.test(st.getPropertyValue('overflow') + ' ' + st.getPropertyValue('overflow-y'))) {
                var ov = window.getComputedStyle(el).overflowY;
                if (ov === 'visible') {
                    st.removeProperty('height');
                    st.setProperty('min-height', v, st.getPropertyPriority('height') || '');
                }
            }
        }
    }

    function normaliseModal(modal) {
        if (!modal || modal.nodeType !== 1 || (modal.classList && modal.classList.contains('modal-free-size'))) { return; }
        var i, list;
        list = modal.querySelectorAll('.modal-dialog, .modal-dialogue');
        for (i = 0; i < list.length; i++) { strip(list[i], DIALOG); }
        list = modal.querySelectorAll('.modal-content');
        for (i = 0; i < list.length; i++) { strip(list[i], CONTENT); }
        list = modal.querySelectorAll('.modal-body');
        for (i = 0; i < list.length; i++) { strip(list[i], BODY); }
        list = modal.querySelectorAll('.modal-body [style], .modal-header .modal-body [style]');
        for (i = 0; i < list.length; i++) { fixInner(list[i]); }
    }

    function normaliseAll(root) {
        var list = (root || document).querySelectorAll('.modal');
        for (var i = 0; i < list.length; i++) { normaliseModal(list[i]); }
    }

    function owningModal(node) {
        while (node && node !== document) {
            if (node.nodeType === 1 && node.classList && node.classList.contains('modal')) { return node; }
            node = node.parentNode;
        }
        return null;
    }

    function alignTables(modal) {
        try {
            var $ = window.jQuery;
            if (!$ || !$.fn || !$.fn.dataTable || !$.fn.dataTable.tables) { return; }
            var tables = $.fn.dataTable.tables({ visible: true, api: true });
            if (tables && tables.columns) { tables.columns.adjust(); }
        } catch (e) { }
    }

    function isShown(modal) {
        return modal.classList.contains('in') || modal.classList.contains('show') || (modal.style && modal.style.display === 'block');
    }

    function init() {
        normaliseAll(document);
        if (!window.MutationObserver) { return; }
        var shownState = typeof WeakMap === 'function' ? new WeakMap() : null;
        new MutationObserver(function (muts) {
            for (var i = 0; i < muts.length; i++) {
                var m = muts[i], t = m.target, j, n, modal;
                if (m.type === 'attributes') {
                    modal = owningModal(t);
                    if (modal) {
                        normaliseModal(modal);
                        if (shownState && modal === t) {
                            var now = isShown(modal);
                            if (now && !shownState.get(modal)) { window.setTimeout(function () { alignTables(); }, 60); window.setTimeout(function () { alignTables(); }, 400); }
                            shownState.set(modal, now);
                        }
                    }
                } else if (m.type === 'childList') {
                    for (j = 0; j < m.addedNodes.length; j++) {
                        n = m.addedNodes[j];
                        if (n.nodeType !== 1) { continue; }
                        modal = owningModal(n);
                        if (modal) { normaliseModal(modal); }
                        else if (n.querySelectorAll) { normaliseAll(n); }
                    }
                }
            }
        }).observe(document.documentElement, { childList: true, subtree: true, attributes: true, attributeFilter: ['style', 'class'] });
    }

    if (document.readyState === 'loading') { document.addEventListener('DOMContentLoaded', init); }
    else { init(); }
})(window, document);
