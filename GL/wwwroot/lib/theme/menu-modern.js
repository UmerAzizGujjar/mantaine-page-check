/* ==========================================================================
   MODERN MAIN MENU - behaviour (shared by every client theme)
   Pair of  menu-modern.css.  Plain JavaScript, no dependencies.

   What it does
   - cleans up the menu HTML the server writes (marks parents, hides empty sub lists)
   - gives every top level item an icon (picked from its text, see ICONS below)
   - desktop: dropdowns flip to the other side when they would leave the screen,
              first tap opens / second tap follows the link on touch screens
   - phone / tablet: hamburger -> slide-in drawer, backdrop, accordion sub menus,
              Esc / backdrop / close button / link tap closes the drawer
   ========================================================================== */
(function () {
    'use strict';

    var ROOT_SELECTOR = '.sidebar.h-sidebar.mm';
    var MOBILE_QUERY = '(max-width: 991px)';

    /* keyword -> Font Awesome 4 icon. First match wins. Edit freely. */
    var ICONS = [
        [/dashboard/i, 'fa-tachometer'],
        [/emergency|casualty|\ber\b/i, 'fa-ambulance'],
        [/patient/i, 'fa-bed'],
        [/\bopd\b|out.?patient|consult/i, 'fa-stethoscope'],
        [/\bipd\b|in.?patient|admission|ward/i, 'fa-hospital-o'],
        [/appointment|schedul|roster/i, 'fa-calendar'],
        [/billing|invoice|receipt|cash|payment|refund/i, 'fa-credit-card'],
        [/\blab|patholog|sample|test/i, 'fa-flask'],
        [/radiolog|imaging|x-?ray|ultrasound|\bct\b|\bmri\b/i, 'fa-camera'],
        [/pharmac|medicine|drug/i, 'fa-medkit'],
        [/blood/i, 'fa-tint'],
        [/operation|theat|\bot\b|surg/i, 'fa-heartbeat'],
        [/inventor|store|stock|purchase|procure|supplier|vendor/i, 'fa-cubes'],
        [/ledger|account|financ|voucher|budget|bank/i, 'fa-bank'],
        [/\bhr\b|human|employee|payroll|staff|attendance|leave/i, 'fa-users'],
        [/doctor|physician/i, 'fa-user-md'],
        [/asset|fixed/i, 'fa-building-o'],
        [/report|analytic|statistic|\bmis\b/i, 'fa-bar-chart'],
        [/setting|setup|admin|config|security|user|role|master/i, 'fa-cogs']
    ];
    var DEFAULT_ICON = 'fa-th-large';

    function qs(sel, ctx) { return (ctx || document).querySelector(sel); }
    function qsa(sel, ctx) { return Array.prototype.slice.call((ctx || document).querySelectorAll(sel)); }
    function childByTag(el, tag) {
        for (var c = el.firstElementChild; c; c = c.nextElementSibling) { if (c.tagName === tag) { return c; } }
        return null;
    }
    function isMobile() { return window.matchMedia ? window.matchMedia(MOBILE_QUERY).matches : window.innerWidth < 992; }
    function canHover() { return window.matchMedia ? window.matchMedia('(hover: hover)').matches : true; }
    function text(el) { return (el.textContent || '').replace(/\s+/g, ' ').trim(); }
    function realHref(a) {
        var h = a ? (a.getAttribute('href') || '').trim() : '';
        return h && h !== '#' && h.toLowerCase().indexOf('javascript:') !== 0 ? h : '';
    }

    function init() {
        var root = qs(ROOT_SELECTOR);
        if (!root || root.getAttribute('data-mm-ready')) { return; }
        var list = qs('ul.nav-list', root);
        if (!list) { return; }
        root.setAttribute('data-mm-ready', '1');

        var burger = qs('#hamburger');
        var title = qs('#mmToolbarTitle');
        var backdrop;

        /* ---------- 1. tidy up the markup ---------- */
        qsa('li', list).forEach(function (li) {
            var a = childByTag(li, 'A');
            var ul = childByTag(li, 'UL');
            if (!ul) { return; }
            ul.classList.add('submenu');
            if (childByTag(ul, 'LI')) {
                li.classList.add('mm-has-sub');
                if (a) { a.setAttribute('aria-haspopup', 'true'); a.setAttribute('aria-expanded', 'false'); }
            } else {
                ul.classList.add('mm-empty');           /* leaf page: server wrote an empty <ul> */
            }
        });

        /* long single-level dropdowns scroll; ones with flyouts must not (it would clip them) */
        qsa('ul.nav-list > li.mm-has-sub > ul', root).forEach(function (ul) {
            if (!qs('li.mm-has-sub', ul)) { ul.classList.add('mm-scroll'); }
        });

        /* ---------- 2. icons for the top level ---------- */
        qsa('ul.nav-list > li', root).forEach(function (li) {
            var a = childByTag(li, 'A');
            if (!a) { return; }
            var i = qs('i.menu-icon', a);
            if (!i) {
                i = document.createElement('i');
                i.className = 'menu-icon fa';
                a.insertBefore(i, a.firstChild);
            }
            if (/\bfa-[a-z0-9-]+/.test(i.className.replace(/\bfa-fw\b/, ''))) { return; }   /* already has an icon */
            var label = text(a), icon = DEFAULT_ICON;
            for (var k = 0; k < ICONS.length; k++) {
                if (ICONS[k][0].test(label)) { icon = ICONS[k][1]; break; }
            }
            i.classList.add('fa', icon);
            i.setAttribute('aria-hidden', 'true');
        });

        /* ---------- 3. mobile extras: drawer header, backdrop, "Open <section>" rows ---------- */
        var head = document.createElement('div');
        head.className = 'mm-drawer-head';
        head.innerHTML = '<span class="mm-drawer-title">Menu</span>' +
            '<button type="button" class="mm-close" aria-label="Close menu"><i class="fa fa-times" aria-hidden="true"></i></button>';
        root.insertBefore(head, root.firstChild);

        backdrop = document.createElement('div');
        backdrop.className = 'mm-backdrop';
        document.body.appendChild(backdrop);

        qsa('li.mm-has-sub', list).forEach(function (li) {
            var a = childByTag(li, 'A'), ul = childByTag(li, 'UL'), href = realHref(a);
            if (!href || !ul) { return; }
            var o = document.createElement('li');
            o.className = 'mm-overview';
            var oa = document.createElement('a');
            oa.setAttribute('href', href);
            oa.textContent = 'Open ' + text(a);
            o.appendChild(oa);
            ul.insertBefore(o, ul.firstChild);
        });

        if (title) {
            var cur = qs('ul.nav-list > li.active > a', root);
            if (cur) { title.textContent = text(cur); }
        }
        if (burger) {
            burger.setAttribute('aria-expanded', 'false');
            if (root.id) { burger.setAttribute('aria-controls', root.id); }
        }

        /* ---------- helpers ---------- */
        function closeSiblings(li) {
            var p = li.parentNode;
            for (var s = p.firstElementChild; s; s = s.nextElementSibling) {
                if (s !== li && s.classList.contains('mm-open')) { setOpen(s, false); }
            }
        }
        function setOpen(li, open) {
            li.classList.toggle('mm-open', open);
            var a = childByTag(li, 'A');
            if (a && li.classList.contains('mm-has-sub')) { a.setAttribute('aria-expanded', open ? 'true' : 'false'); }
            if (!open) {
                qsa('li.mm-open', li).forEach(function (x) { x.classList.remove('mm-open'); });
            }
        }
        function closeAllItems() {
            qsa('li.mm-open', list).forEach(function (li) { setOpen(li, false); });
        }
        function expandActivePath() {
            qsa('li.active', list).forEach(function (li) {
                for (var p = li.parentNode; p && p !== list; p = p.parentNode) {
                    if (p.tagName === 'LI' && p.classList.contains('mm-has-sub')) { setOpen(p, true); }
                }
                if (li.classList.contains('mm-has-sub') && li.parentNode === list) { setOpen(li, true); }
            });
        }
        function openDrawer() {
            document.body.classList.add('mm-open');
            if (burger) { burger.setAttribute('aria-expanded', 'true'); }
            expandActivePath();
            var c = qs('.mm-close', root);
            if (c) { try { c.focus({ preventScroll: true }); } catch (e) { } }
        }
        function closeDrawer(returnFocus) {
            if (!document.body.classList.contains('mm-open')) { return; }
            document.body.classList.remove('mm-open');
            if (burger) {
                burger.setAttribute('aria-expanded', 'false');
                if (returnFocus) { burger.focus(); }
            }
        }

        /* keep dropdowns on screen (desktop) */
        function fit(li) {
            var ul = childByTag(li, 'UL');
            if (!ul || isMobile()) { return; }
            var topLevel = li.parentNode === list;
            ul.classList.remove('mm-right');
            li.classList.remove('mm-flip');
            /* closed panels are display:none - show it invisibly for a moment to measure it */
            ul.style.setProperty('display', 'block', 'important');
            ul.style.setProperty('visibility', 'hidden', 'important');
            var vw = document.documentElement.clientWidth, r = ul.getBoundingClientRect();
            ul.style.removeProperty('display');
            ul.style.removeProperty('visibility');
            if (r.right > vw - 8) {
                if (topLevel) { ul.classList.add('mm-right'); } else { li.classList.add('mm-flip'); }
            }
        }

        /* ---------- events ---------- */
        if (burger) {
            burger.addEventListener('click', function (e) {
                e.preventDefault();
                e.stopPropagation();
                if (document.body.classList.contains('mm-open')) { closeDrawer(); } else { openDrawer(); }
            });
        }
        backdrop.addEventListener('click', function () { closeDrawer(true); });
        qs('.mm-close', root).addEventListener('click', function () { closeDrawer(true); });

        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape' || e.keyCode === 27) {
                if (document.body.classList.contains('mm-open')) { closeDrawer(true); } else { closeAllItems(); }
            }
        });

        /* desktop: measure just before a dropdown appears */
        qsa('li.mm-has-sub', list).forEach(function (li) {
            li.addEventListener('mouseenter', function () { fit(li); });
            li.addEventListener('focusin', function () { fit(li); });
        });

        /* clicks on menu links */
        list.addEventListener('click', function (e) {
            var a = e.target;
            while (a && a !== list && a.tagName !== 'A') { a = a.parentNode; }
            if (!a || a === list) { return; }
            var li = a.parentNode;
            if (li.tagName !== 'LI') { return; }
            var hasSub = li.classList.contains('mm-has-sub');

            if (hasSub) {
                if (isMobile()) {                                   /* accordion */
                    e.preventDefault();
                    var open = !li.classList.contains('mm-open');
                    if (open) { closeSiblings(li); }
                    setOpen(li, open);
                    return;
                }
                if (!canHover()) {                                  /* touch screen with a wide viewport */
                    if (!li.classList.contains('mm-open')) {
                        e.preventDefault();
                        closeSiblings(li);
                        fit(li);
                        setOpen(li, true);
                        return;
                    }
                }
                if (!realHref(a)) { e.preventDefault(); }           /* "#" parents just open */
                return;
            }
            if (isMobile() && realHref(a)) { closeDrawer(); }       /* leaf link: go and close the drawer */
        });

        /* tap / click outside closes touch-opened dropdowns */
        document.addEventListener('click', function (e) {
            if (isMobile()) { return; }
            if (!root.contains(e.target)) { closeAllItems(); }
        });

        /* breakpoint changes (rotate phone, resize window) */
        function onBreakpoint() {
            closeDrawer();
            closeAllItems();
            if (isMobile()) { expandActivePath(); }
        }
        var mq = window.matchMedia ? window.matchMedia(MOBILE_QUERY) : null;
        if (mq) {
            if (mq.addEventListener) { mq.addEventListener('change', onBreakpoint); }
            else if (mq.addListener) { mq.addListener(onBreakpoint); }
        } else {
            window.addEventListener('resize', onBreakpoint);
        }
    }

    if (document.readyState === 'loading') { document.addEventListener('DOMContentLoaded', init); }
    else { init(); }
})();
