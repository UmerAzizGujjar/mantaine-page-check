/* ==========================================================================
   Light / Dark mode toggle
   --------------------------------------------------------------------------
   * Light mode is the default and uses the client's own theme (TIBBIT, CPTH...).
   * Dark mode adds <html data-theme="dark"> and dark-theme.css does the rest.
   * The choice is remembered in this browser (localStorage + a cookie).
   * Works with any button that has  data-theme-toggle  (the header button).
   * A small inline script in <head> applies the saved mode BEFORE the page is
     painted so there is no white flash - see Site.Master.
   ========================================================================== */
(function (win, doc) {
    'use strict';

    var KEY = 'hmis-theme-mode';
    var root = doc.documentElement;

    function read() {
        try { var v = win.localStorage.getItem(KEY); if (v) return v; } catch (e) { }
        var m = doc.cookie.match(/(?:^|;\s*)hmis-theme-mode=(light|dark)/);
        return m ? m[1] : 'light';
    }

    function write(mode) {
        try { win.localStorage.setItem(KEY, mode); } catch (e) { }
        try { doc.cookie = KEY + '=' + mode + ';path=/;max-age=31536000;SameSite=Lax'; } catch (e) { }
    }

    function refreshButtons(mode) {
        var btns = doc.querySelectorAll('[data-theme-toggle]');
        var dark = mode === 'dark';
        for (var i = 0; i < btns.length; i++) {
            btns[i].setAttribute('aria-pressed', dark ? 'true' : 'false');
            btns[i].setAttribute('title', dark ? 'Switch to light mode' : 'Switch to dark mode');
            btns[i].setAttribute('aria-label', dark ? 'Switch to light mode' : 'Switch to dark mode');
        }
    }

    function apply(mode, animate) {
        if (animate) {
            root.classList.add('theme-switching');
            win.setTimeout(function () { root.classList.remove('theme-switching'); }, 350);
        }
        if (mode === 'dark') { root.setAttribute('data-theme', 'dark'); }
        else { root.removeAttribute('data-theme'); }
        refreshButtons(mode);
        try {
            win.dispatchEvent(new CustomEvent('themechange', { detail: { mode: mode } }));
        } catch (e) { }
    }

    function current() { return root.getAttribute('data-theme') === 'dark' ? 'dark' : 'light'; }

    function toggle() {
        var next = current() === 'dark' ? 'light' : 'dark';
        write(next);
        apply(next, true);
    }

    // public API: HmisTheme.set('dark'), HmisTheme.toggle(), HmisTheme.get()
    win.HmisTheme = { set: function (m) { m = m === 'dark' ? 'dark' : 'light'; write(m); apply(m, true); }, toggle: toggle, get: current };

    // tag <html> with the page name and the stylesheets in use so dark-pages.css can target
    // page level styles:  data-page="billingprocess"  data-css="billing tablestyle ..."
    function tagPage() {
        try {
            var p = (win.location.pathname.split('/').pop() || '').toLowerCase().replace(/\.(aspx|html?)$/, '');
            root.setAttribute('data-page', p || 'default');
            var links = doc.querySelectorAll('link[rel~="stylesheet"]'), keys = [], seen = {};
            for (var i = 0; i < links.length; i++) {
                var h = (links[i].getAttribute('href') || '').split('?')[0].split('#')[0].split('/').pop().toLowerCase().replace(/\.css$/, '');
                if (h && !seen[h]) { seen[h] = 1; keys.push(h); }
            }
            var v = keys.join(' ');
            if (root.getAttribute('data-css') !== v) { root.setAttribute('data-css', v); }
        } catch (e) { }
    }
    tagPage();
    if (doc.readyState === 'loading') { doc.addEventListener('DOMContentLoaded', tagPage); }
    win.addEventListener('load', tagPage);

    // make sure the state matches storage (covers the case where the head script was removed)
    apply(read(), false);

    doc.addEventListener('click', function (e) {
        var el = e.target;
        while (el && el !== doc) {
            if (el.hasAttribute && el.hasAttribute('data-theme-toggle')) { e.preventDefault(); toggle(); return; }
            el = el.parentNode;
        }
    });

    // keep several open tabs in sync
    win.addEventListener('storage', function (e) {
        if (e.key === KEY && e.newValue) { apply(e.newValue === 'dark' ? 'dark' : 'light', true); }
    });

    // buttons may be created after this script runs
    if (doc.readyState === 'loading') { doc.addEventListener('DOMContentLoaded', function () { refreshButtons(current()); }); }
    else { refreshButtons(current()); }

    // ---------------------------------------------------------------------------------
    // Safety net for readability in dark mode: text that is (almost) the same colour as
    // the surface behind it (e.g. a "black" utility class on a coloured header) is
    // switched to a readable ink colour. Only touches elements that fail a contrast test,
    // only in dark mode, and everything is undone when switching back to light.
    // ---------------------------------------------------------------------------------
    var FIXATTR = 'data-dk-fix', INK = [27, 42, 65], PAPER = [236, 240, 245], fixTimer = null, fixing = false;
    function rgbOf(s) {
        var m = s && s.match(/rgba?\(([^)]+)\)/);
        if (!m) { var q = s && s.match(/color\(srgb ([^)]+)\)/); if (!q) return null; var u = q[1].split(/[ \/]+/).map(Number); return [u[0] * 255, u[1] * 255, u[2] * 255, u.length > 3 ? u[3] : 1]; }
        var p = m[1].split(/[ ,\/]+/).map(Number); return [p[0], p[1], p[2], p.length > 3 ? p[3] : 1];
    }
    function lum(c) { var f = function (v) { v /= 255; return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4); }; return 0.2126 * f(c[0]) + 0.7152 * f(c[1]) + 0.0722 * f(c[2]); }
    function ratio(a, b) { var x = lum(a), y = lum(b); return (Math.max(x, y) + 0.05) / (Math.min(x, y) + 0.05); }
    function clearFixes() {
        var els = doc.querySelectorAll('[' + FIXATTR + ']');
        for (var i = 0; i < els.length; i++) { els[i].style.removeProperty('color'); els[i].removeAttribute(FIXATTR); }
    }
    function fixContrast() {
        fixTimer = null;
        if (current() !== 'dark' || !doc.body) { return; }
        fixing = true;
        var memo = new Map(), base = [18, 21, 26, 1];
        // background of an element = own colour blended over the parent's; null when an image/gradient is involved
        function bgOf(el) {
            if (!el || el.nodeType !== 1) { return base; }
            if (memo.has(el)) { return memo.get(el); }
            var cs = win.getComputedStyle(el), res;
            if (cs.backgroundImage && cs.backgroundImage !== 'none') { res = null; }
            else {
                var c = rgbOf(cs.backgroundColor), parent = bgOf(el.parentElement);
                if (!c || c[3] === 0) { res = parent; }
                else if (c[3] >= 0.98 || !parent) { res = c[3] >= 0.98 ? c : null; }
                else { res = [c[0] * c[3] + parent[0] * (1 - c[3]), c[1] * c[3] + parent[1] * (1 - c[3]), c[2] * c[3] + parent[2] * (1 - c[3]), 1]; }
            }
            memo.set(el, res); return res;
        }
        var all = doc.body.querySelectorAll('*'), n = 0;
        for (var i = 0; i < all.length && n < 6000; i++) {
            var el = all[i], tag = el.tagName;
            if (tag === 'SCRIPT' || tag === 'STYLE' || tag === 'OPTION' || tag === 'SVG' || tag === 'PATH') { continue; }
            var has = false;
            for (var k = el.firstChild; k; k = k.nextSibling) { if (k.nodeType === 3 && k.nodeValue.replace(/\s+/g, '').length > 1) { has = true; break; } }
            if (!has && !(tag === 'INPUT' || tag === 'TEXTAREA' || tag === 'SELECT')) { continue; }
            n++;
            var cs = win.getComputedStyle(el);
            if (cs.display === 'none' || cs.visibility === 'hidden') { continue; }
            var fg = rgbOf(cs.color), bg = bgOf(el);
            if (!fg || !bg) { continue; }
            if (fg[3] < 1) { continue; }
            if (ratio(fg, bg) >= 3) { if (el.hasAttribute(FIXATTR)) { /* already readable */ } continue; }
            var ink = ratio(INK, bg), paper = ratio(PAPER, bg);
            el.style.setProperty('color', 'rgb(' + ((paper >= 3.5 || paper >= ink) ? PAPER : INK).join(',') + ')', 'important');
            el.setAttribute(FIXATTR, '1');
        }
        win.setTimeout(function () { fixing = false; }, 0);
    }
    function scheduleFix() { if (fixing || fixTimer || current() !== 'dark') { return; } fixTimer = win.setTimeout(fixContrast, 500); }
    win.addEventListener('themechange', function (e) {
        if (e.detail && e.detail.mode === 'dark') { win.setTimeout(fixContrast, 380); } else { clearFixes(); }
    });
    if (doc.readyState === 'loading') { doc.addEventListener('DOMContentLoaded', scheduleFix); } else { scheduleFix(); }
    win.addEventListener('load', function () { win.setTimeout(fixContrast, 300); });
    try {
        new MutationObserver(function (muts) {
            if (fixing || current() !== 'dark') { return; }
            for (var i = 0; i < muts.length; i++) { if (muts[i].type === 'childList' || muts[i].attributeName === 'class' || muts[i].attributeName === 'style') { scheduleFix(); return; } }
        }).observe(doc.documentElement, { childList: true, subtree: true, attributes: true, attributeFilter: ['class', 'style'] });
    } catch (e) { }
})(window, document);
