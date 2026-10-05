/* Shared date-picker behaviour for every page (look: datepicker-modern.css).
   1. jQuery UI datepicker defaults: month + year drop-downs. Options a page passes to
      .datepicker({...}) still win, so minDate / maxDate / dateFormat / onSelect logic is untouched.
   2. Native <input type="date"> boxes (list-page filters) get the same jQuery UI picker.
      The box becomes a text box that still holds / returns "yyyy-mm-dd", exactly what the native
      date box returned, so .val(), change handlers and disabled toggling keep working.
      Opt out with class="no-hmis-dp". */
(function (window, document) {
    function jq() {
        var $ = window.jQuery;
        return ($ && $.datepicker && typeof $.datepicker.setDefaults === 'function') ? $ : null;
    }

    function applyDefaults() {
        var $ = jq();
        if (!$) { return; }
        $.datepicker.setDefaults({
            changeMonth: true,
            changeYear: true,
            yearRange: 'c-100:c+20'
        });
    }

    function parseIso(v) {
        var $ = jq();
        if (!$ || !v) { return null; }
        try { return $.datepicker.parseDate('yy-mm-dd', v); } catch (e) { return null; }
    }

    function convertNativeDates(root) {
        var $ = jq();
        if (!$) { return; }
        var list = (root || document).querySelectorAll('input[type="date"]:not(.no-hmis-dp)');
        for (var i = 0; i < list.length; i++) {
            var el = list[i];
            var opts = { dateFormat: 'yy-mm-dd' };
            var min = parseIso(el.getAttribute('min')), max = parseIso(el.getAttribute('max'));
            if (min) { opts.minDate = min; }
            if (max) { opts.maxDate = max; }
            var val = el.value;
            try { el.type = 'text'; } catch (e) { continue; }
            el.value = val;
            el.setAttribute('autocomplete', 'off');
            if (!el.getAttribute('placeholder')) { el.setAttribute('placeholder', 'yyyy-mm-dd'); }
            el.className += (el.className ? ' ' : '') + 'hmis-dp-date';
            $(el).datepicker(opts);
        }
    }

    function init() {
        applyDefaults();
        convertNativeDates(document);
        if (window.MutationObserver && document.body) {
            new MutationObserver(function (muts) {
                for (var i = 0; i < muts.length; i++) {
                    if (muts[i].addedNodes && muts[i].addedNodes.length) { convertNativeDates(document); break; }
                }
            }).observe(document.body, { childList: true, subtree: true });
        }
    }

    applyDefaults();
    if (document.readyState === 'loading') { document.addEventListener('DOMContentLoaded', init); }
    else { init(); }
})(window, document);
