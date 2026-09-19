/* Shared INV_Items change-history modal (Service / Product / Pharmacy Items) */
(function () {
    var ItemLogLabels = {
        "Item_Code": "Item Code",
        "Description": "Description",
        "Unit": "UOM",
        "Item_Type": "Item Type",
        "Item_Category": "Item Category",
        "Item_Sub_Category": "Item Sub Category",
        "Service_Sub_Category": "Service Sub Category",
        "Manufacturer_Name": "Manufacturer",
        "Manufacture_Company": "Manufacturer",
        "Account_Category": "Account Category",
        "Account": "Account",
        "Financial_Integration": "Financial Integration",
        "Purchase_Rate": "Purchase Rate",
        "Sale_Rate": "Sale Rate",
        "UOM_Qty": "UOM Qty",
        "Base_Unit": "Base Unit",
        "Base_Unit_Qty": "Base Unit Qty",
        "Sehat_Card_Rate": "Sehat Card Rate",
        "Pack": "Pack",
        "Pack_Quantity": "Pack Quantity",
        "Pack_Unit": "Pack Unit",
        "Salt": "Generic / Salt",
        "ATC": "ATC",
        "Generic_Name": "Generic Name",
        "Notes": "Notes",
        "Remarks": "Remarks",
        "Mini_Stock": "Minimum Stock",
        "Max_Stock": "Maximum Stock",
        "Reorder_Stock": "Reorder Stock",
        "Length": "Length",
        "Width": "Width",
        "Height": "Height",
        "Locator_Address": "Locator Address",
        "Department": "Department",
        "Warehouse": "Warehouse",
        "Item_Group": "Item Group",
        "Procedure_Type": "Procedure Type",
        "Procedure_Time": "Procedure Time",
        "Doctor_Share": "Doctor Share",
        "Hospital_Share": "Hospital Share",
        "Active": "Active",
        "Services": "Services Item",
        "Is_Pharmacy_Item": "Is Pharmacy Item",
        "Pharmacy_Item": "Pharmacy Item",
        "Lab_OR_Radiology": "Lab / Radiology Charges",
        "Dental_Item": "Dental Item",
        "Is_Batch": "Batch Item",
        "Saleable": "Saleable",
        "Purchaseable": "Purchaseable",
        "Consumable": "Consumable",
        "Finished_Product": "Finished Product",
        "Is_Fixed_Asset": "Fixed Asset",
        "Non_Stock_Item": "Non Stock Item",
        "Locator": "Locator",
        "Refrigerator": "Refrigerator",
        "Narcotics": "Narcotics",
        "Controller_Drug": "Controller Drug",
        "OT_Procedure": "OT Procedure",
        "Hospital_Services": "Hospital Services",
        "Billing_Required": "Billing Required",
        "Lab_Required": "Lab Required",
        "Pat_History_Required": "Patient History Required",
        "Fitness_Certificate": "Fitness Certificate",
        "Bed_Services": "Bed Services",
        "Lense_Required": "Lens Required",
        "Procedure_Required": "Procedure Required",
        "Other_Services": "Other Services",
        "Infusion_Fluid": "Infusion Fluid",
        "Additive_Dose": "Additive Dose",
        "Short_Item": "Short Item",
        "CathLab_Item": "Cath Lab Item",
        "High_Risk": "High Risk",
        "Discount_Block": "Discount Block",
        "Sehat_Card_Item": "Sehat Card Item",
        "Pharmacy_Billing": "Pharmacy Billing",
        "Doctor_Compulsory": "Doctor Compulsory",
        "Share_Service": "Share Service"
    };

    function escHtml(s) {
        return String(s == null ? '' : s)
            .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
    }

    function diffMaster(before, after) {
        var rows = [];
        if (!before || !after) return rows;
        var keys = {};
        Object.keys(before.master || {}).forEach(function (k) { keys[k] = 1; });
        Object.keys(after.master || {}).forEach(function (k) { keys[k] = 1; });
        Object.keys(keys).forEach(function (k) {
            var b = String(before.master[k] == null ? '' : before.master[k]);
            var a = String(after.master[k] == null ? '' : after.master[k]);
            if (b !== a) rows.push({ label: ItemLogLabels[k] || k, prev: b, cur: a });
        });
        return rows;
    }

    function buildRevisionHTML(evt, idx, total) {
        var d = diffMaster(evt.before, evt.after);
        var noCurrent = (evt.after === null);

        var html = '<div class="bl-card">';
        html += '<div class="bl-card-head">';
        html += '<span class="bl-seq ' + (idx === 0 ? 'bl-seq-newest' : '') + '">' + (idx === 0 ? 'Latest Update' : 'Update #' + (total - idx)) + '</span>';
        html += '<span class="bl-meta"><i class="fa fa-user-o"></i> ' + escHtml(evt.user) + '</span>';
        html += '<span class="bl-meta"><i class="fa fa-clock-o"></i> ' + escHtml(evt.time) + '</span>';
        html += '<span class="bl-chips">' + (d.length > 0 ? '<span class="bl-chip bl-chip-mod">' + d.length + ' field' + (d.length > 1 ? 's' : '') + '</span>' : '') + '</span>';
        html += '</div>';

        html += '<div class="bl-card-body">';
        if (noCurrent) {
            html += '<div class="bl-note">Current item data is no longer available (record may have been deleted). Only the stored snapshot is shown.</div>';
        }
        if (d.length > 0) {
            html += '<div class="bl-sec-label">Changed Fields</div>';
            html += '<div style="overflow-x:auto;"><table class="bl-table bl-table-cmp"><thead><tr><th>Field</th><th>Previous Value</th><th></th><th>Updated Value</th></tr></thead><tbody>';
            d.forEach(function (row) {
                html += '<tr><td class="bl-fld">' + escHtml(row.label) + '</td>'
                    + '<td class="bl-val bl-val-old">' + (row.prev === '' ? '&mdash;' : escHtml(row.prev)) + '</td>'
                    + '<td class="bl-arrow"><i class="fa fa-long-arrow-right"></i></td>'
                    + '<td class="bl-val bl-val-new">' + (row.cur === '' ? '&mdash;' : escHtml(row.cur)) + '</td></tr>';
            });
            html += '</tbody></table></div>';
        } else {
            html += '<div class="bl-none">No field changes detected in this update.</div>';
        }
        html += '</div>';
        html += '</div>';
        return html;
    }

    function renderItemLogs(payload) {
        var $body = $('#itemLogBody');
        if (!payload || payload.error) {
            $body.html('<div class="bl-empty"><i class="fa fa-exclamation-triangle bl-empty-ico" style="color:#d8a25a;"></i><span class="bl-empty-title">Unable to load history</span><span class="bl-empty-sub">' + escHtml(payload && payload.error ? payload.error : 'No data returned.') + '</span></div>');
            return;
        }

        var logs = payload.logs || [];
        var current = payload.current;

        if (logs.length === 0) {
            $body.html('<div class="bl-empty"><i class="fa fa-history bl-empty-ico"></i><span class="bl-empty-title">No update history found</span><span class="bl-empty-sub">Changes are logged automatically each time this item is edited and saved.</span></div>');
            $('#itemLogCount').text('');
            return;
        }

        var snapshots = logs.map(function (l) { return { master: l.Master, details: l.Details }; });
        if (current && current.master) {
            snapshots.push({ master: current.master, details: current.details });
        }

        var events = [];
        for (var i = 0; i < logs.length; i++) {
            events.push({
                user: logs[i].UserName,
                time: logs[i].TimeText,
                before: snapshots[i],
                after: (i + 1 < snapshots.length) ? snapshots[i + 1] : null
            });
        }
        events.reverse();

        var total = events.length;
        var html = '';
        for (var j = 0; j < events.length; j++) {
            html += buildRevisionHTML(events[j], j, total);
        }
        $body.html(html);
        $('#itemLogCount').text(total + ' recorded update' + (total > 1 ? 's' : ''));
    }

    window.openItemLogsModal = function (url, itemId, itemCode) {
        var $body = $('#itemLogBody');
        $body.html('<div class="bl-loading"><i class="fa fa-spinner fa-spin"></i>Loading change history&hellip;</div>');
        $('#itemLogCount').text('');
        $('#itemLogTitle').text('Item Change History' + (itemCode ? ' - ' + itemCode : ''));
        $('#itemLogModal').modal({ backdrop: 'static' });

        $.ajax({
            type: "POST",
            url: url,
            data: JSON.stringify({ itemId: itemId }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                try {
                    renderItemLogs(JSON.parse(response.d));
                } catch (ex) {
                    $body.html('<div class="bl-empty"><i class="fa fa-exclamation-triangle bl-empty-ico" style="color:#d8a25a;"></i><span class="bl-empty-title">Unable to load history</span><span class="bl-empty-sub">' + escHtml(ex.message) + '</span></div>');
                }
            },
            error: function () {
                $body.html('<div class="bl-empty"><i class="fa fa-exclamation-triangle bl-empty-ico" style="color:#d8a25a;"></i><span class="bl-empty-title">Unable to load history</span><span class="bl-empty-sub">Server error occurred while reading logs.</span></div>');
            }
        });
    };
})();
