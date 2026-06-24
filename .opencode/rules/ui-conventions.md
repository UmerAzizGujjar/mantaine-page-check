# Project UI Conventions

These rules apply to ALL pages — form pages and list pages alike.

## Controls
- Use **Select2** for ALL dropdowns (`<select>` elements) — never native `<select>` styling
- Use **jQuery UI Datepicker** with input mask for ALL date fields — never `<input type="date">`
- Use **ptTimeSelect** for ALL time picker fields — never `<input type="time">`
- Use **Swal.fire()** (SweetAlert2) for ALL alerts, confirmations, and modals — never `alert()`, `confirm()`, or `prompt()`
- Use **DataTables** for ALL table displays — never ASP.NET GridView
- Use **`btn-primry`** CSS class (note: intentional misspelling) for primary action buttons

## New Entities
- Default `Active` / `Status` field to `true` / `"Active"` for new records
