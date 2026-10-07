/*
 * Shared by the tax definition forms (Sales Tax, Withholding Tax, Advance Tax, Further Tax).
 *
 * These forms list every saved tax with two GL-account dropdowns per row. They used to fill each dropdown with the whole
 * level-4 account list (thousands of options x rows) and re-create a Select2 widget for each one, which made the pages slow.
 *
 *  - withAccountList(cb)       loads the account list from the server ONCE (PageMethods.loadAccountList) and then runs cb
 *  - showSavedAccount(sel,id)  puts only the saved account into a dropdown (cheap, enough to show / save the value)
 *  - fillAllAccounts(sel)      gives a dropdown the whole list, keeping the selected account (call it when a row is edited)
 *  - accountOptions()          the whole list as <option> HTML (for new rows)
 */
(function (w, $) {
    'use strict';

    var optionsHtml = '';
    var names = {};
    var loaded = false;
    var waiters = [];

    w.escapeHtml = function (s) {
        return String(s == null ? '' : s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    };

    w.withAccountList = function (callback) {
        if (loaded) { callback(); return; }
        waiters.push(callback);
        if (waiters.length > 1) { return; }          // a request is already running
        w.PageMethods.loadAccountList(function (resp) {
            var html = ['<option value="0">Please Select</option>'];
            $.each(resp ? JSON.parse(resp) : [], function (key, value) {
                names[value.Account_ID] = value.name;
                html.push('<option value="' + value.Account_ID + '">' + w.escapeHtml(value.name) + '</option>');
            });
            optionsHtml = html.join('');
            loaded = true;
            var waiting = waiters;
            waiters = [];
            $.each(waiting, function (i, fn) { fn(); });
        }, function (error) {
            waiters = [];
            alert(error.get_message());
        });
    };

    w.accountOptions = function () { return optionsHtml; };

    w.showSavedAccount = function (selectEl, savedId) {
        var html = '';
        if (savedId === 0 || savedId === '0') {
            html = '<option value="0">Please Select</option>';
        } else if (savedId !== null && savedId !== undefined && savedId !== '') {
            html = '<option value="' + savedId + '">' + w.escapeHtml(names[savedId] || savedId) + '</option>';
        }
        $(selectEl).html(html).val(savedId === null || savedId === undefined ? null : String(savedId));
    };

    w.fillAllAccounts = function (selectEl) {
        var current = $(selectEl).val();
        $(selectEl).html(optionsHtml).val(current === null ? null : current);
    };
})(window, jQuery);
