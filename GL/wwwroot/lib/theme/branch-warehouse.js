// Branch-wise warehouse dropdowns.
// sys_Parms "Branch Wise Ware House": Code = 01 -> the warehouse dropdown starts empty and, when a branch
// is selected, lists only that branch's warehouses (Administrator > Branch Wise Ware House).
// Any other code (02, NULL, missing) -> attach() does nothing and the form keeps its own warehouse loading.
//
// Usage on a form (inside $(document).ready):  BranchWareHouse.attach('#ddlBranch', '#ddlInv_org');
// The form's own code may keep filling / setting the warehouse dropdown; the list is re-filtered after each refill.
(function (window, $) {
    var url = window.BranchWareHouseUrl || '/Modules/Inventory/BranchWareHouse.ashx';

    function fetch(branchId) {
        return $.ajax({ url: url, data: { branchId: branchId || 0 }, dataType: 'json', cache: false });
    }

    function esc(s) {
        return String(s == null ? '' : s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }

    function isBlank(v) {
        return v == null || v === '' || v === '0' || v === '-1';
    }

    // opts.onLoaded(items) (optional) runs after each branch's warehouse list has been rendered.
    function attach(branchSel, wareHouseSel, opts) {
        var $branch = $(branchSel), $wh = $(wareHouseSel);
        if (!$branch.length || !$wh.length || !window.MutationObserver) return;

        fetch(0).done(function (res) {
            if (!res || !res.enabled) return;

            var items = [];
            var loadedBranch = null;
            var placeholder = { value: '0', text: 'Please Select' };

            var whObserver = new MutationObserver(render);
            var branchObserver = new MutationObserver(checkBranch);

            function render() {
                var cur = $wh.val();
                var first = $wh.find('option').first();
                if (first.length && isBlank(first.val())) {
                    placeholder = { value: first.val(), text: first.text() };
                }

                var html = '<option value="' + esc(placeholder.value) + '">' + esc(placeholder.text) + '</option>';
                var keep = false;
                $.each(items, function (i, it) {
                    if (it.value === cur) keep = true;
                    html += '<option value="' + esc(it.value) + '">' + esc(it.text) + '</option>';
                });
                $wh.html(html).val(keep ? cur : placeholder.value);
                whObserver.takeRecords(); // ignore our own write

                $wh.trigger('change.select2');
                if (!keep && !isBlank(cur)) $wh.trigger('change');
            }

            function checkBranch() {
                var b = $branch.val();
                if (b === loadedBranch) return;
                loadedBranch = b;
                if (isBlank(b)) {
                    items = [];
                    render();
                    return;
                }
                fetch(b).done(function (r) {
                    if (loadedBranch !== b) return; // branch changed again meanwhile
                    items = (r && r.items) || [];
                    render();
                    if (opts && opts.onLoaded) opts.onLoaded(items);
                });
            }

            whObserver.observe($wh[0], { childList: true });
            branchObserver.observe($branch[0], { childList: true });
            $branch.on('change', checkBranch);

            render();
            checkBranch();
        });
    }

    window.BranchWareHouse = { attach: attach };
})(window, jQuery);
