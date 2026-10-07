/*
 * Item search booster for the token-input item boxes on Purchase Requisition / Purchase Order,
 * Goods Issuance Request and Stock Adjustment.
 * Include it once, after jQuery. It only touches json.aspx item searches listed in ITEM_SEARCH below;
 * every other ajax call is left alone.
 *
 *  1. A newer search cancels the one still running, so slow old answers never pile up.
 *  2. Item search ignores the page-wide ajax events (global loaders / error loggers), so cancelling is silent.
 *  3. Where allowed (LOCAL_OK): when the previous answer was complete (fewer than MAX_ROWS rows), a longer
 *     query that contains the previous one is answered from that list in the browser - no server call.
 *     Searches that also match Generic_Name (or description only) always ask the server.
 *  4. The "no warehouse selected" placeholder request (ReturnEmpty=1) is answered locally with an empty list.
 */
(function ($) {
    'use strict';

    var MAX_ROWS = 10;                      // keep in step with TOP 10 in json.aspx.cs
    // item searches this script speeds up (Purchase Requisition / Order, Goods Issuance Request, Stock Adjustment)
    var ITEM_SEARCH = /(^|&)Table=(INV_ItemsForPR|INV_ItemsForPRwithWarehouse|INV_ItemsForMIR|INV_ItemsForMIRByWarehouse|INV_ItemsforStockAdj|INV_ItemsforStockAdjWareHouse)(&|$)/;
    // only these match "item code OR description", which the returned name carries, so a longer query can be
    // answered from a complete earlier list. The others also match Generic_Name / description only: always ask the server.
    var LOCAL_OK = /(^|&)Table=(INV_ItemsForPR|INV_ItemsForMIR|INV_ItemsForMIRByWarehouse)(&|$)/;
    var SPECIAL = /[%_\[\]]| -/;            // SQL wildcards / the " - " or " -- " joiner: let the server decide
    var inflight = null;
    var memory = {};                        // endpoint (url + params without q) -> { query, rows }

    function isItemSearch(opts) {
        return typeof opts.data === 'string' &&
            /json\.aspx$/i.test((opts.url || '').split('?')[0]) &&
            ITEM_SEARCH.test(opts.data);
    }

    function queryOf(data) {
        var m = /(^|&)q=([^&]*)/.exec(data);
        return m ? decodeURIComponent(m[2].replace(/\+/g, ' ')) : '';
    }

    function endpointOf(opts) {
        return opts.url + '?' + opts.data.replace(/(^|&)q=[^&]*/, '');
    }

    // Prefilters run while opts.data is still the "a=b&q=..." string (by transport time jQuery has
    // moved it into the URL), so the local answer is worked out here and handed to the transport.
    $.ajaxPrefilter(function (opts, orig, jqXHR) {
        if (!isItemSearch(opts)) return;

        opts.global = false;
        if (inflight && inflight.readyState !== 4) { inflight.abort(); }
        inflight = jqXHR;

        var key = endpointOf(opts);
        var q = queryOf(opts.data);

        if (/(^|&)ReturnEmpty=1(&|$)/.test(opts.data)) {
            opts.itemSearchAnswer = [];
        } else if (LOCAL_OK.test(opts.data)) {
            var lower = q.toLowerCase();
            var mem = memory[key];
            if (mem && lower && !SPECIAL.test(lower) && lower.indexOf(mem.query.toLowerCase()) !== -1) {
                opts.itemSearchAnswer = $.grep(mem.rows, function (row) {
                    return String(row.name).toLowerCase().indexOf(lower) !== -1;
                });
            }
        }

        jqXHR.done(function (rows) {
            if ($.isArray(rows) && rows.length < MAX_ROWS && q && !SPECIAL.test(q)) {
                memory[key] = { query: q, rows: rows };
            } else {
                delete memory[key];
            }
        });
    });

    $.ajaxTransport('+*', function (opts) {
        var answer = opts.itemSearchAnswer;
        if (!$.isArray(answer)) return;     // not answerable locally: normal network transport

        var timer;
        return {
            send: function (headers, complete) {
                timer = setTimeout(function () {
                    complete(200, 'OK', { text: JSON.stringify(answer) });
                }, 0);
            },
            abort: function () { clearTimeout(timer); }
        };
    });
})(jQuery);
