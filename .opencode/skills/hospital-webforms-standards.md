---
name: hospital-webforms-standards
description: Core UI, JavaScript, and Grid standards for the Hospital ERP Web Forms project. Triggers on any frontend, UI, list view, dashboard, or JS generation.
---

# Hospital ERP Frontend — OpenCode Rules

> ASP.NET Web Forms project using jQuery, Bootstrap, DataTables, and ECharts.
> **Never add CDN links.** All libraries are already loaded in `Site.Master`.

---

## Theme Primary Colors Reference
When updating CSS files (`CustomCSS/PR.css`, `CustomCSS/vendor.css`, etc.) across multiple themes, map the primary color to the following hex values per theme:
- `THEME_TIBBIT`: `#EFA63E` (Gold)
- `THEME_ASSIRAAT`: `#308665` (Green)
- `THEME_PAKRED`: `#c11718` (Red)
- `THEME_STANDARD`: `#438eb9` (Blue)
- `THEME_KHURSHID`: `#c11718` (Red)
- `THEME_NOOR`: `#438eb9` (Blue)
- `THEME_SKINSTUDIO`: `#308665` (Green)
- `THEME_KALEEM`: `#308665` (Green)
- `THEME_DEMO`: `#308665` (Green)
- `THEME_IITH`: `#438eb9` (Blue)
- `THEME_CPTH`: `#c11718` (Red)
- `THEME_NHMC`: `#308665` (Green)

---

## Input Controls

Initialize all controls inside `$(document).ready()`.

**Date picker:**
```javascript
$('#txtYourDate').datepicker({
    changeMonth: true, changeYear: true, dateFormat: "dd/mm/yy", yearRange: "-100:+0"
});
$('#txtYourDate').mask("99/99/9999");
```

**Time picker:**
```javascript
$('#txtYourTime').ptTimeSelect();
```

**Dropdowns — always use `select2()`, lazy-loaded via AJAX on focus:**
```javascript
$element.off('focus.fill').on('focus.fill', function () {
    if (!$element.data('filled')) {
        fillDropdown($element, 'YourWebMethodName');
    }
});
```

Data comes from static `[WebMethod]` functions called via jQuery AJAX.

---

## Form Buttons

Every data entry form requires exactly these three buttons:

```html
<!-- Save: redirects to list page on success -->
<input type="button" class="btn-primry" id="btnsave" value="Save" onclick="SaveData()" />

<!-- New: reloads current page -->
<input type="button" class="btn btn-yellow" id="btnNew" value="New" onclick="window.location = 'CurrentPage.aspx'" />

<!-- View: navigates to the DataTables list page -->
<input type="button" class="btn btn-gray" id="btnView" value="View" onclick="window.location = 'FormView.aspx'" />
```

After a successful AJAX save, redirect with `window.location.href = "FormView.aspx"`.

---

## List / View Pages (DataTables)

All `*View.aspx` pages use server-side DataTables. **Never use `<asp:GridView>`.**

```javascript
const table = $("#tblResult").DataTable({
    "processing": true,
    "serverSide": true,
    "dom": 'lBfrtip',
    "lengthChange": true,
    "buttons": [
        {
            text: 'Add',
            className: 'dt-button buttons-copy buttons-html5',
            action: function () { window.location = 'TargetForm.aspx'; }
        },
        'copy', 'excel', 'pdf',
        { extend: 'colvis', text: '<i class="fa fa-columns"></i> Columns' }
    ],
    "ajax": {
        type: "POST",
        url: "CurrentView.aspx/ViewList",
        data: function (data) {
            return JSON.stringify({
                draw: data.draw,
                start: data.start,
                length: data.length,
                sortColumn: data.columns[data.order[0].column].name,
                sortColumnDirection: data.order[0].dir,
                searchValue: data.search.value
            });
        },
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        dataFilter: function (response) { return response.d; } // unwrap ASP.NET 'd' wrapper
    }
    // add columns array mapped to JSON response fields
});
```

---

## Modals

### Standard PR-quality Modal Pattern

Use this design for all data-entry picker modals (Browse Items, GIR selection, etc.).

**HTML structure:**
```html
<div class="modal fade" id="yourModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg custom-modal-dialog">
        <div class="modal-content custom-modal-content">

            <!-- Gold gradient header with icon -->
            <div class="modal-header custom-modal-header">
                <div class="custom-modal-title-wrap">
                    <span class="custom-modal-icon"><i class="fa fa-cubes"></i></span>
                    <h4 class="modal-title custom-modal-title">Modal Title</h4>
                </div>
                <button type="button" class="custom-modal-close" data-dismiss="modal">
                    <i class="fa fa-times"></i>
                </button>
            </div>

            <div class="modal-body custom-modal-body">
                <!-- Optional: search bar -->
                <div class="custom-modal-search-wrap">
                    <span class="custom-modal-search-icon"><i class="fa fa-search"></i></span>
                    <input type="text" id="searchInput" class="custom-modal-search" placeholder="Search..." />
                </div>

                <!-- Scrollable table area -->
                <div class="custom-modal-table-wrap">
                    <table class="table custom-modal-table">
                        <thead>
                            <tr>
                                <th style="width:50px;">Add</th>
                                <th>Column</th>
                            </tr>
                        </thead>
                        <tbody id="modalTableBody"></tbody>
                    </table>
                </div>
            </div>

            <div class="modal-footer custom-modal-footer">
                <span class="custom-modal-count" id="modalCount"></span>
                <button type="button" class="custom-modal-btn-close" data-dismiss="modal">
                    <i class="fa fa-times"></i> Close
                </button>
            </div>

        </div>
    </div>
</div>
```

**Row add button** — circular gold `+` button, auto-closes modal on click:
```html
<button type="button" class="btn-item-pick" onclick="addRow(this)">
    <i class="fa fa-plus"></i>
</button>
```

**Required CSS classes** (add to the page's `.css` file):

```css
/* Dialog sizing */
.custom-modal-dialog     { max-width: 720px; margin: 40px auto; }
.custom-modal-dialog-xl  { max-width: 960px; }

/* Content shell */
.custom-modal-content {
    border: none; border-radius: 10px;
    overflow: hidden; box-shadow: 0 8px 32px rgba(0,0,0,0.18);
}

/* Gold gradient header */
.custom-modal-header {
    background: linear-gradient(135deg, #EFA63E 0%, #d4882a 100%);
    padding: 12px 18px; display: flex; align-items: center;
    justify-content: space-between; border-bottom: none;
}
.custom-modal-title-wrap { display: flex; align-items: center; gap: 10px; }
.custom-modal-icon {
    width: 32px; height: 32px; background: rgba(255,255,255,0.25);
    border-radius: 50%; display: flex; align-items: center;
    justify-content: center; color: #fff; font-size: 15px;
}
.custom-modal-title { color: #fff !important; font-size: 15px !important; font-weight: 700; margin: 0; }
.custom-modal-close {
    background: rgba(255,255,255,0.20); border: none; border-radius: 50%;
    width: 30px; height: 30px; display: flex; align-items: center;
    justify-content: center; color: #fff; font-size: 14px; cursor: pointer;
    transition: background 0.15s; padding: 0;
}
.custom-modal-close:hover { background: rgba(255,255,255,0.40); }

/* Body */
.custom-modal-body { padding: 16px 18px 10px; background: #fff; }

/* Search bar */
.custom-modal-search-wrap { position: relative; margin-bottom: 12px; }
.custom-modal-search-icon {
    position: absolute; left: 10px; top: 50%;
    transform: translateY(-50%); color: #aaa; font-size: 13px;
}
.custom-modal-search {
    width: 100%; padding: 7px 12px 7px 32px !important;
    border: 1px solid #ddd !important; border-radius: 20px !important;
    font-size: 13px !important; background: #f8f9fa !important;
    box-shadow: none !important; font-weight: normal !important; color: #333 !important;
}
.custom-modal-search:focus { border-color: #EFA63E !important; background: #fff !important; }

/* Scrollable table container */
.custom-modal-table-wrap {
    max-height: 340px; overflow-y: auto;
    border: 1px solid #eee; border-radius: 6px;
}
.custom-modal-table { margin-bottom: 0; font-size: 12px; width: 100%; }
.custom-modal-table thead th {
    background: #f4f6f9; font-weight: 700; font-size: 11px;
    text-transform: uppercase; letter-spacing: 0.03em; padding: 8px 10px;
    border-bottom: 2px solid #e0e0e0; position: sticky; top: 0; z-index: 1;
    white-space: nowrap;
}
.custom-modal-table tbody tr:hover { background: #fff8ec !important; }
.custom-modal-table tbody td {
    padding: 7px 10px; vertical-align: middle;
    border-color: #f0f0f0; font-size: 12px;
}

/* Circular gold Add button */
.btn-item-pick {
    display: inline-flex; align-items: center; justify-content: center;
    width: 26px; height: 26px; background: #EFA63E; color: #fff;
    border: none; border-radius: 50%; font-size: 12px; cursor: pointer;
    transition: background 0.15s, transform 0.1s; padding: 0;
}
.btn-item-pick:hover { background: #d4882a; transform: scale(1.12); }

/* Footer */
.custom-modal-footer {
    display: flex; align-items: center; justify-content: space-between;
    padding: 10px 18px; background: #f8f9fa; border-top: 1px solid #eee;
}
.custom-modal-count { font-size: 12px; color: #888; font-style: italic; }
.custom-modal-btn-close {
    display: inline-flex; align-items: center; gap: 5px;
    background: #6c757d; color: #fff; border: none; border-radius: 20px;
    padding: 5px 16px; font-size: 12px; font-weight: 600; cursor: pointer;
}
.custom-modal-btn-close:hover { background: #545b62; color: #fff; }
```

**JavaScript pattern for populating and showing:**
```javascript
function openPickerModal(searchText) {
    $.ajax({
        type: "POST", url: "Page.aspx/GetItems",
        data: JSON.stringify({ searchText: searchText }),
        contentType: "application/json; charset=utf-8", dataType: "json",
        success: function (response) {
            var items = JSON.parse(response.d);
            var tbody = $('#modalTableBody').empty();
            if (items.length === 0) {
                tbody.html('<tr><td colspan="3" class="text-center text-muted" style="padding:18px;">No items found.</td></tr>');
                $('#modalCount').text('');
            } else {
                $.each(items, function (i, item) {
                    tbody.append(
                        '<tr><td style="text-align:center;">' +
                        '<button type="button" class="btn-item-pick" onclick="pickItem(this)">' +
                        '<i class="fa fa-plus"></i></button></td>' +
                        '<td>' + item.Code + '</td><td>' + item.Name + '</td></tr>'
                    );
                });
                $('#modalCount').text(items.length + ' item(s) found');
            }
            $('#yourModal').modal('show');
        }
    });
}

function pickItem(btn) {
    var row = $(btn).closest('tr');
    // read data from row cells, add to main table
    $('#yourModal').modal('hide');
    checkToggleLock(); // if applicable
}
```

---

## Dashboards

- **Layout:** CSS Grid with `grid-template-areas` — dense bento-box style.
- **Charts:** ECharts (`echarts.min.js`) only — no other chart libraries.
- **Loading state:** Add a `.card-loading` CSS class with an animated spinner overlay during AJAX calls.
- **Alerts:** Never use `alert()` — always use `Swal.fire()` (SweetAlert2).

```css
.card-loading {
    position: relative;
    pointer-events: none;
}
.card-loading::after {
    content: '';
    position: absolute;
    inset: 0;
    background: rgba(255,255,255,0.6);
    display: flex;
    align-items: center;
    justify-content: center;
    /* add spinner animation here */
}
```

---

## Vendor / Entity Form Pattern (Vendor.aspx)

Reused for any Supplier/Customer/Entity data-entry form.

### Meta Bar (Top)
```html
<div class="pr-meta-bar">
    <div class="meta-left">
        <span class="meta-title"><i class="fa fa-building"></i> Entity Name</span>
    </div>
    <div class="meta-right">
        <div class="meta-badge">
            <span class="badge-label">Code:</span>
            <span class="badge-value" id="codeDisplay">---</span>
        </div>
        <div class="meta-badge" id="activeBadge" onclick="$('#Active').click();">
            <i class="fa fa-check-circle" id="activeIcon"></i> <span id="activeText">Active</span>
        </div>
    </div>
</div>
```
- Hidden fields: `#EntityCode`, `#Active` (checkbox), `#EntityId`
- `.val()` interceptor syncs code display; `#Active` change toggles badge class/icon/text

### 2×2 Bento Grid Cards
```html
<div class="row">
    <div class="col-lg-6 col-md-12 pr-cards-column">
        <div class="pr-primary-settings">
            <h5 class="pr-section-title"><i class="fa fa-icon"></i> Card Title</h5>
            <!-- fields in .row > .col-* -->
        </div>
        <!-- second card -->
    </div>
    <div class="col-lg-6 col-md-12 pr-cards-column">
        <!-- card 3 + card 4 -->
    </div>
</div>
```
- `.pr-cards-column` = flex column, cards get `flex:1` for equal height
- `.pr-primary-settings`: white bg, 3px left theme-color border, hover lift
- `.pr-section-title`: full-width gradient band with FA icon + uppercase label
- Input-group icons on key fields only (Name, CNIC, Address, Phone, Mobile, Email)
- Placeholders on all inputs
- No colored/golden input backgrounds — use `#fff` with clean border

### Tab Tables (jQuery UI tabs)
```html
<div id="tabs">
    <ul><li><a href="#Tab-1">Tab Name</a></li></ul>
    <div id="Tab-1">
        <div class="tab-toolbar"><!-- circular + button --></div>
        <div class="tab-table-wrap">
            <table class="table pr-tab-table table-bordered table-striped">
                <thead><tr><th>Columns</th><th style="width:5%;">Action</th></tr></thead>
                <tbody><!-- empty-state-row + dynamic rows --></tbody>
            </table>
        </div>
    </div>
</div>
```
- `.pr-tab-table thead th`: `background:#f1f4f8`, `font-size:10px`, sticky header
- Delete icon: `<i class="fa fa-trash" style="color:#f30a0a;">`
- Delete confirm: use `Swal.fire()` not `confirm()`
- Empty state: `<tr class="empty-state-row"><td colspan="N"><span class="empty-state-icon"><i class="fa fa-icon-o"></i></span><span class="empty-state-text">No records added yet</span></td></tr>`
- `tbody:has(tr:not(.empty-state-row)) .empty-state-row { display:none; }`

### Action Buttons
```html
<div class="pr-action-buttons">
    <div class="pr-btn-group">
        <input type="button" class="btn btn-primry" onclick="SaveData()" value="Save" id="btnSave" />
        <input type="button" class="btn btn-gray" value="List" onclick="window.location='ViewPage.aspx'" />
        <input type="button" class="btn btn-yellow" value="New" onclick="window.location='FormPage.aspx'" />
    </div>
</div>
```
- `.pr-btn-group`: flex `nowrap` centered, buttons `flex:0 0 auto` with `white-space:nowrap`
- Icons via CSS `::before` pseudo-elements using FontAwesome unicode

### Quick Reference

| Concern | Rule |
|---|---|
| CDN links | ❌ Never — all libs in `Site.Master` |
| Grid control | ❌ Never `<asp:GridView>` — use DataTables |
| Alerts | ❌ Never `alert()` — use `Swal.fire()` |
| Dropdowns | ✅ Always `select2()` + lazy AJAX load |
| Modals | ✅ Use `custom-modal-*` CSS pattern (gold header, circular + button, scrollable table, count footer) |
| Charts | ✅ ECharts only |
| Save button class | `btn-primry` (note spelling) |
| New entity default | `#Active` checked by default in `$(document).ready` else branch |
