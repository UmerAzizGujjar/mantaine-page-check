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

    // ---------------------------------------------------------------------------------
    // Dark-mode accent colour (one colour for every client).
    //   HmisTheme.setAccent('teal')      - a preset name
    //   HmisTheme.setAccent('#e8742a')   - any hex colour
    //   HmisTheme.setAccent('client')    - the client's own light-mode colour (TIBBIT orange, ...)
    //   HmisTheme.setAccent('')          - back to the default (teal)
    //   open any page with  ?darkpicker=1  for a small on-screen picker (?darkpicker=0 hides it)
    // The choice is remembered in this browser. All 7 --dk-accent* values come from one colour.
    // ---------------------------------------------------------------------------------
    var ACCENT_KEY = 'hmis-dark-accent';
    var PRESETS = {
        blue: '#3574e8', indigo: '#5560e8', violet: '#7c4ddf', pink: '#d9467f', red: '#d94545',
        orange: '#e8742a', amber: '#f0a020', green: '#1f9d55', teal: '#0f9488', cyan: '#1596c9', slate: '#64748b'
    };
    var VARS = ['--dk-accent', '--dk-accent-rgb', '--dk-accent-light', '--dk-accent-strong', '--dk-accent-text', '--dk-on-accent', '--dk-accent-soft'];
    var clientAccent = null;

    function hexToRgb(h) {
        h = String(h).replace('#', '');
        if (h.length === 3) { h = h.charAt(0) + h.charAt(0) + h.charAt(1) + h.charAt(1) + h.charAt(2) + h.charAt(2); }
        if (!/^[0-9a-f]{6}$/i.test(h)) { return null; }
        return [parseInt(h.substr(0, 2), 16), parseInt(h.substr(2, 2), 16), parseInt(h.substr(4, 2), 16)];
    }
    function rgbToHsl(r, g, b) {
        r /= 255; g /= 255; b /= 255;
        var mx = Math.max(r, g, b), mn = Math.min(r, g, b), l = (mx + mn) / 2, h = 0, s = 0, d = mx - mn;
        if (d) {
            s = l > 0.5 ? d / (2 - mx - mn) : d / (mx + mn);
            if (mx === r) { h = ((g - b) / d + (g < b ? 6 : 0)); } else if (mx === g) { h = (b - r) / d + 2; } else { h = (r - g) / d + 4; }
            h *= 60;
        }
        return [h, s, l];
    }
    function hsl(h, s, l) { return 'hsl(' + Math.round(h) + ',' + Math.round(Math.max(0, Math.min(1, s)) * 100) + '%,' + Math.round(Math.max(0, Math.min(1, l)) * 100) + '%)'; }
    function clamp(v, a, b) { return Math.max(a, Math.min(b, v)); }

    function accentVars(hex) {
        var c = hexToRgb(hex); if (!c) { return null; }
        var t = rgbToHsl(c[0], c[1], c[2]), h = t[0], s = clamp(t[1], 0.35, 0.95), l = clamp(t[2], 0.36, 0.62);
        var acc = (t[2] >= 0.3 && t[2] <= 0.62) ? '#' + [c[0], c[1], c[2]].map(function (x) { return ('0' + x.toString(16)).slice(-2); }).join('') : hsl(h, s, l);
        var white = ratio(c, [255, 255, 255]) >= 3.2;
        return {
            '--dk-accent': acc,
            '--dk-accent-rgb': c[0] + ' ' + c[1] + ' ' + c[2],
            '--dk-accent-light': hsl(h, s, clamp(l + 0.08, 0, 0.75)),
            '--dk-accent-strong': hsl(h, s, clamp(l - 0.08, 0.2, 1)),
            '--dk-accent-text': hsl(h, clamp(s, 0.5, 1), 0.74),
            '--dk-on-accent': white ? '#ffffff' : '#111827',
            '--dk-accent-soft': hsl(h, clamp(s * 0.55, 0.2, 0.5), 0.2)
        };
    }
    function readClientAccent() {
        if (clientAccent) { return clientAccent; }
        var had = root.getAttribute('data-theme');
        if (had) { root.removeAttribute('data-theme'); }
        var v = win.getComputedStyle(root).getPropertyValue('--theme-accent').trim();
        if (had) { root.setAttribute('data-theme', had); }
        var m = v.match(/^#([0-9a-f]{3}|[0-9a-f]{6})$/i);
        clientAccent = m ? v : '#EFA63E';
        return clientAccent;
    }
    function applyAccent(val) {
        var i, hex = null;
        for (i = 0; i < VARS.length; i++) { root.style.removeProperty(VARS[i]); }
        val = (val || '').trim();
        if (!val) { return; }
        if (val === 'client') { hex = readClientAccent(); }
        else if (PRESETS[val.toLowerCase()]) { hex = PRESETS[val.toLowerCase()]; }
        else if (hexToRgb(val)) { hex = val.charAt(0) === '#' ? val : '#' + val; }
        var v = hex && accentVars(hex); if (!v) { return; }
        for (i = 0; i < VARS.length; i++) { root.style.setProperty(VARS[i], v[VARS[i]]); }
    }
    function getAccent() { try { return win.localStorage.getItem(ACCENT_KEY) || ''; } catch (e) { return ''; } }
    function setAccent(val) {
        try { if (val) { win.localStorage.setItem(ACCENT_KEY, val); } else { win.localStorage.removeItem(ACCENT_KEY); } } catch (e) { }
        applyAccent(val);
        markPicker();
        try { win.dispatchEvent(new CustomEvent('accentchange', { detail: { accent: val } })); } catch (e) { }
        // surfaces whose text colour was auto-fixed may need re-checking against the new accent
        clearFixes(); scheduleFix();
    }
    win.HmisTheme.setAccent = setAccent;
    win.HmisTheme.getAccent = getAccent;
    win.HmisTheme.accents = function () { var o = { client: readClientAccent() }; for (var k in PRESETS) { o[k] = PRESETS[k]; } return o; };
    applyAccent(getAccent());
    win.addEventListener('storage', function (e) { if (e.key === ACCENT_KEY) { applyAccent(e.newValue || ''); markPicker(); } });

    // ---- on-screen test picker (only when asked for with ?darkpicker=1) ----
    var pickerEl = null;
    function markPicker() {
        if (!pickerEl) { return; }
        var cur = getAccent().toLowerCase(), b = pickerEl.querySelectorAll('[data-acc]');
        for (var i = 0; i < b.length; i++) { b[i].style.outline = (b[i].getAttribute('data-acc').toLowerCase() === cur || (!cur && b[i].getAttribute('data-acc') === 'teal')) ? '2px solid #fff' : 'none'; }
    }
    function buildPicker() {
        if (pickerEl || !doc.body) { return; }
        var wrap = doc.createElement('div');
        wrap.id = 'dk-accent-picker';
        wrap.setAttribute('style', 'position:fixed;right:14px;bottom:14px;z-index:99999;background:#0e131b;color:#e6ebf2;border:1px solid #3a475c;border-radius:12px;padding:10px 12px;font:12px/1.3 Segoe UI,Arial,sans-serif;box-shadow:0 8px 30px rgba(0,0,0,.5);max-width:260px');
        var html = '<div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px"><b>Dark accent colour</b><a href="#" data-close style="color:#8db4ff;text-decoration:none">hide</a></div><div style="display:flex;flex-wrap:wrap;gap:6px">';
        var all = win.HmisTheme.accents();
        for (var k in all) {
            html += '<button type="button" data-acc="' + k + '" title="' + k + ' ' + all[k] + '" style="width:26px;height:26px;border-radius:50%;border:2px solid #0e131b;cursor:pointer;padding:0;background:' + all[k] + (k === 'client' ? ';background-image:linear-gradient(135deg,transparent 45%,#fff 45%,#fff 55%,transparent 55%)' : '') + '"></button>';
        }
        html += '</div><div style="margin-top:8px;display:flex;align-items:center;gap:8px"><input type="color" data-custom value="' + (hexToRgb(getAccent()) ? getAccent() : '#0f9488') + '" style="width:34px!important;min-width:34px;height:26px!important;padding:0!important;border:0!important;background:none!important;cursor:pointer;flex:none"><span>custom colour</span><a href="#" data-reset style="margin-left:auto;color:#8db4ff;text-decoration:none">reset</a></div>';
        wrap.innerHTML = html;
        wrap.addEventListener('click', function (e) {
            var t = e.target;
            if (t.hasAttribute('data-acc')) { setAccent(t.getAttribute('data-acc') === 'teal' ? '' : t.getAttribute('data-acc')); if (current() !== 'dark') { HmisTheme.set('dark'); } }
            else if (t.hasAttribute('data-reset')) { e.preventDefault(); setAccent(''); }
            else if (t.hasAttribute('data-close')) { e.preventDefault(); wrap.style.display = 'none'; try { win.sessionStorage.setItem('hmis-darkpicker', '0'); } catch (x) { } }
        });
        wrap.addEventListener('input', function (e) { if (e.target.hasAttribute('data-custom')) { setAccent(e.target.value); if (current() !== 'dark') { HmisTheme.set('dark'); } } });
        doc.body.appendChild(wrap); pickerEl = wrap; markPicker();
    }
    function maybePicker() {
        var q = /[?&]darkpicker=(\d)/.exec(win.location.search), on = null;
        try {
            if (q) { win.sessionStorage.setItem('hmis-darkpicker', q[1]); }
            on = win.sessionStorage.getItem('hmis-darkpicker');
        } catch (e) { on = q ? q[1] : null; }
        if (on === '1') { buildPicker(); }
    }
    if (doc.readyState === 'loading') { doc.addEventListener('DOMContentLoaded', maybePicker); } else { maybePicker(); }
})(window, document);
