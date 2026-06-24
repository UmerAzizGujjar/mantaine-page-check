---
name: modal-design
description: How to build and style modals using custom-modal-* CSS classes, btn-item-pick buttons, search inputs, tables inside modals, and synchronizing CSS changes across all THEME_* folders with correct per-theme colors
---

# Modal Design Guidelines

When creating or designing modals in the application, you must follow this standardized design pattern.

## 1. Include the Custom Modal CSS

Before defining the modal in your form/page, include the `custom-modals.css` stylesheet for the active theme:

```html
<link href="../../wwwroot/THEME_TIBBIT/CustomCSS/custom-modals.css" rel="stylesheet" />
```

Path pattern: `@wwwroot/THEME_*/CustomCSS/custom-modals.css`

## 2. Reference Implementation

Refer to `@Modules/AP/PurchaseRequistion.aspx` as the golden standard for modal construction — HTML structure, table, search inputs, and buttons.

## 3. Modal HTML Structure

```html
<div class="modal fade" id="myModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg custom-modal-dialog">
        <div class="modal-content custom-modal-content">

            <!-- Header -->
            <div class="modal-header custom-modal-header">
                <div class="custom-modal-title-wrap">
                    <span class="custom-modal-icon"><i class="fa fa-cubes"></i></span>
                    <h4 class="modal-title custom-modal-title">Modal Title</h4>
                </div>
                <button type="button" class="custom-modal-close" data-dismiss="modal" aria-label="Close">
                    <i class="fa fa-times"></i>
                </button>
            </div>

            <!-- Body -->
            <div class="modal-body custom-modal-body">

                <!-- Search Bar -->
                <div class="custom-modal-search-wrap">
                    <span class="custom-modal-search-icon"><i class="fa fa-search"></i></span>
                    <input type="text" class="custom-modal-search" placeholder="Search..." />
                </div>

                <!-- Table -->
                <div class="custom-modal-table-wrap">
                    <table class="table custom-modal-table">
                        <thead>
                            <tr>
                                <th style="width:50px;">Add</th>
                                <th>Column 1</th>
                                <th>Column 2</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td style="text-align:center;">
                                    <button type="button" class="btn-item-pick"><i class="fa fa-plus"></i></button>
                                </td>
                                <td>Data 1</td>
                                <td>Data 2</td>
                            </tr>
                        </tbody>
                    </table>
                </div>

            </div>
        </div>
    </div>
</div>
```

### Key CSS Classes
- **Search bar:** `custom-modal-search-wrap` > `custom-modal-search-icon` + `custom-modal-search`
- **Table container:** `custom-modal-table-wrap`
- **Table:** `custom-modal-table`
- **Action buttons:** `btn-item-pick`
- **Dialog sizes:** `custom-modal-dialog` (default ~720px) or `custom-modal-dialog-xl` (~960px)

## 4. Theme Colors & CSS Synchronization

Load the `@theme-colors` skill for the full per-theme color reference (primary hex, gradients, hover values).

**CRITICAL:** If you edit `custom-modals.css` to add new colored elements, you MUST replicate those changes across ALL `wwwroot/THEME_*/CustomCSS/custom-modals.css` files, adapting colors to match each theme's palette using the `@theme-colors` mapping.
