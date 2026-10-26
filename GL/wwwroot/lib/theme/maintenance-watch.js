/* =============================================================================================
   maintenance-watch.js
   Watches the static maintenance status file from every already-open page.

     RUNNING     -> nothing shown, poll every 4 s
     WARNING     -> amber banner: "update starting soon", poll every 1 s
     MAINTENANCE -> full-screen frame showing the real offline page (app_offline.htm), poll every 1 s

   Why a frame: the offline page is the body of the 503 response, so it cannot exist inside a page
   that is already open. Loading it in a full-screen frame shows the exact same design the user
   gets on the next request, without waiting for a manual refresh and without keeping a second
   copy of the design in this file.

   Fail-open by design: a missing file, a 404, a timeout or a proxy error changes nothing on the
   page. The real write-protection is server-side (app_offline.htm returns 503 for every managed
   request), never this script.

   URL is supplied by the master page: window.HMSMaintenanceUrl = '<%= ResolveUrl("~/maintenance/status.txt") %>';
   ============================================================================================= */
(function () {
    "use strict";

    if (window.top !== window.self) { return; }   // never run inside report/iframe content

    var url = window.HMSMaintenanceUrl;
    if (!url) { return; }

    var TIMEOUT_MS = 4000;
    var MS_RUNNING = 4000;
    var MS_ACTIVE = 1000;
    var MS_HIDDEN = 15000;

    var state = "RUNNING";        // last state the server confirmed
    var runningReads = 0;
    var submittedAt = 0;
    var banner = null;
    var overlay = null;
    var savedOverflow = null;
    var lastFallbackReload = 0;

    /* ---------- helpers ------------------------------------------------------------------ */

    function pollDelay() {
        if (document.hidden) { return MS_HIDDEN; }
        return (state === "WARNING" || state === "MAINTENANCE") ? MS_ACTIVE : MS_RUNNING;
    }

    function readStatus(done) {
        var xhr = new XMLHttpRequest();
        var sep = url.indexOf("?") >= 0 ? "&" : "?";
        try {
            xhr.open("GET", url + sep + "t=" + new Date().getTime(), true);
            xhr.timeout = TIMEOUT_MS;
            xhr.onreadystatechange = function () {
                if (xhr.readyState !== 4) { return; }
                var token = "";
                if (xhr.status >= 200 && xhr.status < 300) {
                    token = String(xhr.responseText || "").replace(/\s+/g, "").toUpperCase();
                    if (token !== "RUNNING" && token !== "WARNING" && token !== "MAINTENANCE") { token = ""; }
                }
                done(token);
            };
            xhr.ontimeout = function () { done(""); };
            xhr.onerror = function () { done(""); };
            xhr.send();
        } catch (e) {
            done("");
        }
    }

    function el(tag, className) {
        var node = document.createElement(tag);
        if (className) { node.className = className; }
        return node;
    }

    /* "…/maintenance/status.txt" -> "…/" (the application root), so the offline page can be found
       no matter how deep the page the user is on happens to be. */
    function appRoot() {
        var i = url.toLowerCase().indexOf("/maintenance/");
        return i > -1 ? url.substring(0, i + 1) : "/";
    }

    /* ---------- WARNING banner ------------------------------------------------------------ */

    function showBanner() {
        if (banner || overlay || !document.body) { return; }
        banner = el("div", "hms-mt-banner");
        banner.setAttribute("role", "status");
        banner.innerHTML =
            '<span class="hms-mt-banner-dot" aria-hidden="true"></span>' +
            "<strong>Scheduled update:</strong> the system will close in a few minutes. " +
            "Please save your work and do not start new entries.";
        document.body.appendChild(banner);
    }

    function hideBanner() {
        if (banner && banner.parentNode) { banner.parentNode.removeChild(banner); }
        banner = null;
    }

    /* ---------- MAINTENANCE overlay: the real offline page, full screen -------------------- */

    function showOverlay() {
        if (overlay || !document.body) { return; }

        var frame = document.createElement("iframe");
        frame.className = "hms-mt-frame";
        frame.setAttribute("title", "System update in progress");
        frame.setAttribute("src", appRoot() + "app_offline.htm");

        frame.onload = function () {
            var title = "";
            try {
                title = String((frame.contentDocument && frame.contentDocument.title) || "");
            } catch (e) {
                title = "";
            }
            if (/maintenance/i.test(title)) { return; }

            // Not the offline page (file missing or an error page): fall back to a normal reload,
            // throttled so a half-finished deployment cannot put the tab into a reload loop.
            var now = new Date().getTime();
            if (now - lastFallbackReload > 3000) {
                lastFallbackReload = now;
                window.location.reload();
            }
        };

        overlay = el("div", "hms-mt-overlay");
        overlay.appendChild(frame);

        savedOverflow = document.body.style.overflow;
        document.body.style.overflow = "hidden";
        document.body.appendChild(overlay);

        try { frame.focus(); } catch (ignore) { }
    }

    function hideOverlay() {
        if (overlay && overlay.parentNode) { overlay.parentNode.removeChild(overlay); }
        overlay = null;
        if (document.body) { document.body.style.overflow = savedOverflow || ""; }
    }

    /* ---------- state machine -------------------------------------------------------------- */

    function apply(next) {
        state = next;

        if (next === "WARNING") {
            hideOverlay();
            showBanner();
            runningReads = 0;
            return;
        }

        if (next === "MAINTENANCE") {
            hideBanner();
            showOverlay();
            runningReads = 0;
            return;
        }

        // RUNNING
        hideBanner();
        if (!overlay) { return; }

        runningReads += 1;
        if (runningReads >= 2 && Date.now() - submittedAt > 5000) { window.location.reload(); }
    }

    function tick() {
        readStatus(function (token) {
            if (token) { apply(token); }
            window.setTimeout(tick, pollDelay());
        });
    }

    /* A submit in the last few seconds wins over an automatic reload: let the postback finish. */
    document.addEventListener("submit", function () { submittedAt = Date.now(); }, true);

    /* The master page puts this script in <head>, so the body may not exist yet. */
    function boot() {
        tick();
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", boot);
    } else {
        boot();
    }
}());
