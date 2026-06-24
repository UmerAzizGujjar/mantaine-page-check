---
name: form-buttons
description: Standard three-button pattern for data entry forms — Save (btn-primry), New (btn-yellow), View (btn-gray) with correct onclick handlers and post-save redirect
---

# Form Buttons

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

Show save feedback using `Swal.fire()` (never `alert()`):

```javascript
Swal.fire({ icon: 'success', title: 'Success!', text: 'Data saved successfully.', showConfirmButton: false, timer: 2000 });
```

## Related Skills
- Load `@input-controls` for dropdowns, datepickers, and other form input patterns
