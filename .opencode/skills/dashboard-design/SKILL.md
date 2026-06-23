---
name: dashboard-design
description: Dashboard layout patterns using CSS Grid bento-box layout, ECharts (echarts.min.js), card-loading spinner overlay, SweetAlert2 (Swal.fire), period pills, card filters with datepickers, sparkline revenue cards, and detail modals with full-year tables
---

# Dashboard Design

Reference implementation: `@Modules/Dashboards/Chief_Executive_Dashboard.aspx`

## Layout

CSS Grid with `grid-template-areas` — dense bento-box style:

```css
.bento-grid {
    display: grid;
    grid-template-columns: 0.9fr 1.8fr 1fr 1fr;
    gap: 12px;
    grid-template-areas:
        "period period period period"
        "left opd opd dia"
        "left trend trend ph"
        "left trend trend lab";
}
.bento-item {
    background: #fff;
    border-radius: 10px;
    padding: 14px;
    border: 1px solid #f0f0f0;
    transition: box-shadow 0.25s ease, transform 0.25s ease;
}
.bento-item:hover {
    box-shadow: 0 8px 25px rgba(0,0,0,0.08);
    border-color: #e5e7eb;
    transform: translateY(-1px);
}
```

## Charts

Use **ECharts** (`echarts.min.js`) only — no other chart libraries. Each chart instance should be tracked globally and disposed before re-init:

```js
var chartInstance = null;
// ...in success callback:
if (chartInstance) chartInstance.dispose();
chartInstance = echarts.init(dom);
chartInstance.setOption({ /* ECharts option */ });
```

Common chart types used:
- **Donut pie** for OPD new vs returning, pharmacy distribution, satisfaction
- **Bar** for billing snapshot, clinical outcomes
- **Line** for sparkline revenue trends

## Loading State

```css
.card-loading {
    opacity: 0.35;
    pointer-events: none;
    transition: opacity 0.2s;
    position: relative;
}
.card-loading::after {
    content: '';
    position: absolute;
    inset: 50% auto auto 50%;
    width: 28px;
    height: 28px;
    margin: -14px 0 0 -14px;
    border: 3px solid #e5e7eb;
    border-top-color: #3b82f6;
    border-radius: 50%;
    animation: spin 0.7s linear infinite;
    z-index: 10;
}
@keyframes spin { to { transform: rotate(360deg); } }
```

Toggle loading with JS:
```js
function setCardLoading(id, loading) {
    $("#" + id).toggleClass("card-loading", loading);
}
// Auto-clear on any AJAX completion:
$(document).ajaxStop(function () { $(".bento-item").removeClass("card-loading"); });
```

## Alerts

Never use `alert()` — always use `Swal.fire()` (SweetAlert2).

## Period Pills (Date Range Filter)

```html
<div class="period-pills">
    <button type="button" class="period-pill active" data-period="today">Today</button>
    <button type="button" class="period-pill" data-period="yesterday">Yesterday</button>
    <button type="button" class="period-pill" data-period="custom">Custom</button>
</div>
```
CSS: pills with border-radius 20px, active state uses theme primary color background.

Custom date range toggles visibility of datepicker inputs + Apply button.

## Card-Level Filters

Each bento card can have its own filter row with From/To datepickers, Apply, and Reset (trash) buttons:

```html
<div class="card-filter">
    <input type="text" class="form-control datepicker" id="cardFrom" placeholder="From" />
    <span>-</span>
    <input type="text" class="form-control datepicker" id="cardTo" placeholder="To" />
    <button type="button" class="btn btn-sm btn-primry card-apply" data-card="card">Apply</button>
    <button type="button" class="btn btn-sm btn-trash card-trash" data-card="card"><i class="fa fa-trash"></i></button>
</div>
```

## Sparkline Revenue Cards

Compact revenue cards with embedded sparkline chart (100×35px positioned absolute bottom-right):

```html
<div class="bento-item rev-item">
    <div class="rev-label">Total Hospital Revenue</div>
    <div class="rev-value">Rs. <span id="lblRevenue">0</span></div>
    <div class="rev-chart" id="sparkRevenue"></div>
</div>
```
Use `renderSparkline(id, values, labels)` helper to initialize ECharts line chart with minimal grid and tooltip.

## Detail Modals (Full-Year Tables)

Use overlay modals (not Bootstrap modals) for detailed reports:

```html
<div class="modal-overlay" id="invModal">
    <div class="modal-box">
        <span class="modal-close" onclick="closeModal()">&times;</span>
        <div class="modal-header">
            <span>Title <select class="year-select" id="yearSelect" onchange="loadData()"></select></span>
        </div>
        <div class="modal-table-wrap">
            <table class="modal-table" id="tblData">
                <thead></thead>
                <tbody></tbody>
            </table>
        </div>
    </div>
</div>
```

Use `buildFullYearTable(tblId, data, metricLabels)` to dynamically build month columns (Jan–current month) from API data.

## Related Skills
- Load `@theme-colors` for period-pill active state and card filter button colors per theme
