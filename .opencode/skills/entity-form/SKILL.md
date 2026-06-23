---
name: entity-form
description: Standard data-entry form pattern for Vendor/Supplier/Customer/Entity pages — meta bar, bento grid cards, pr-primary-settings sections, hidden field sync, clean white inputs
---

# Vendor / Entity Form Pattern

Reused for any Supplier/Customer/Entity data-entry form.

## Meta Bar (Top)
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

## 2×2 Bento Grid Cards
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

## Related Skills
- Load `@theme-colors` for card border and section-title gradient colors per theme
- Load `@form-buttons` for the Save/New/View button trio
