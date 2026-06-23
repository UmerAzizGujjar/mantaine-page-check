---
description: Use when creating or editing server-side list pages (DataTables) with ASP.NET WebForms, especially for Modules/PatientManagement. This covers the exact DataTable + WebMethod pattern used across the project (OPDView, Physiotherapy assessments, etc.). Use ONLY for list page tasks — form pages use a different pattern.
mode: all
---

# List Pages (Server-Side DataTables)

This agent documents the Standard Hospital project's standard pattern for building **server-side DataTable list pages**. The canonical reference implementation is `OPDView.aspx` + `OPDView.aspx.cs` in `Modules/PatientManagement/`.

## Project Context

- **Tech stack:** ASP.NET WebForms (.NET Framework), Bootstrap 3.3.6, jQuery, DataTables, LINQ-to-SQL
- **Database:** LINQ-to-SQL via `DataBaseDataContext(DBClass.ConnectionString())`
- **Master page:** `~/Site.Master` (content placeholders `HeadContent` and `MainContent`)
- **CSS:** `../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css`
- **Icons:** Font Awesome (`<i class="fa fa-pencil"></i>`, `<i class="fa fa-print"></i>`, etc.)
- **Modal:** SweetAlert2 (`Swal.fire()`)

## ASPX Pattern

### HeadContent (JS + CSS)

```aspx
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            $('#tblList').DataTable({
                processing: true,
                serverSide: true,
                dom: 'lBfrtip',
                lengthChange: true,
                buttons: [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () { window.location = 'YourForm.aspx'; }
                    },
                    'copy',
                    'excel',
                    'pdf',
                    {
                        extend: 'colvis',
                        text: '<i class="fa fa-columns"></i> Columns',
                        className: 'dt-button buttons-colvis',
                        collectionLayout: 'fixed two-column',
                        postfixButtons: ['colvisRestore']
                    }
                ],
                ajax: function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "YourListPage.aspx/GetList",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length,
                            sortColumn: data.columns[data.order[0].column].name,
                            sortColumnDirection: data.order[0].dir,
                            searchValue: data.search.value
                        }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            callback({
                                draw: response.d.draw,
                                recordsTotal: response.d.recordsTotal,
                                recordsFiltered: response.d.recordsFiltered,
                                data: response.d.data
                            });
                        },
                        error: function (xhr) { console.log(xhr.responseText); }
                    });
                },
                columns: [
                    { data: 'Col1', name: 'Col1', width: '10%' },
                    { data: 'Col2', name: 'Col2', width: '20%' },
                    {
                        data: 'DateCol', name: 'DateCol', width: '12%',
                        render: function (data, type, full) {
                            return full.DateCol ? moment(full.DateCol, 'DD/MM/YYYY').format('DD-MMM-YYYY') : '';
                        }
                    },
                    {
                        data: null, width: '14%', orderable: false, searchable: false,
                        render: function (data, type, full) {
                            return '<a href="#" onclick="window.open(\'YourForm.aspx?ID=' + full.KeyId + '\',\'_blank\')" class="editListBtn" style="border-radius:4px;padding:5px 8px"><i class="fa fa-pencil"></i></a>' +
                                   '<a href="#" onclick="window.open(\'YourForm.aspx?ID=' + full.KeyId + '&print=1\',\'_blank\')" class="printListBtn" style="border-radius:4px;margin-left:4px;color:white;padding:5px 8px"><i class="fa fa-print"></i></a>';
                        }
                    }
                ]
            });
        });
    </script>
</asp:Content>
```

### MainContent (HTML table only — no bento cards, no headings)

```aspx
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="POdetails" style="margin-top: 15px;">
        <div class="row">
            <div class="table-container col-lg-12 col-md-12 col-sm-10">
                <table class="table table-hover table-striped table-bordered" id="tblList" style="overflow: scroll; height: auto;">
                    <thead>
                        <tr>
                            <th>Column 1</th>
                            <th>Column 2</th>
                            <th>Date</th>
                            <th style="width:14%">Actions</th>
                        </tr>
                    </thead>
                </table>
            </div>
        </div>
    </div>
</asp:Content>
```

**Important:** Delete any `.designer.cs` file for the new list page (it's not needed for pure server-side DataTable pages).

## Code-Behind Pattern

### Namespaces required

```csharp
using System;
using System.Linq;
using System.Web.Services;
using System.Web.Script.Services;
```

### GetList WebMethod

```csharp
[WebMethod]
[ScriptMethod(ResponseFormat = ResponseFormat.Json)]
public static object GetList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
{
    try
    {
        using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
        {
            // 1. Build the JOIN query
            var query = from main in db.MainTable
                        join other in db.OtherTable on main.Key equals other.Key
                        select new
                        {
                            KeyId = main.Id,
                            Col1 = main.Field1,
                            Col2 = other.Field2,
                            DateCol = main.DateField,
                            Computed = db.GetDataValueName("ValueSetName", main.CodeField)
                        };

            // 2. Get total count BEFORE filtering
            int total = query.Count();

            // 3. Apply search filter
            if (!string.IsNullOrWhiteSpace(searchValue))
            {
                query = query.Where(x => x.Col1.Contains(searchValue) || x.Col2.Contains(searchValue));
            }

            // 4. Get filtered count
            int filtered = query.Count();

            // 5. Apply sorting using string column names
            switch (sortColumn)
            {
                case "Col1":
                    query = sortColumnDirection == "asc" ? query.OrderBy(x => x.Col1) : query.OrderByDescending(x => x.Col1);
                    break;
                case "DateCol":
                    query = sortColumnDirection == "asc" ? query.OrderBy(x => x.DateCol) : query.OrderByDescending(x => x.DateCol);
                    break;
                default:
                    query = query.OrderByDescending(x => x.DateCol);
                    break;
            }

            // 6. Apply pagination and format data
            var page = query.Skip(start).Take(length).ToList().Select(x => new
            {
                x.KeyId,
                x.Col1,
                x.Col2,
                DateCol = x.DateCol.HasValue ? x.DateCol.Value.ToString("dd/MM/yyyy") : "",
            }).ToList();

            // 7. Return DataTable-compatible response
            return new { draw, recordsTotal = total, recordsFiltered = filtered, data = page };
        }
    }
    catch (Exception ex)
    {
        throw new Exception("Error fetching list data", ex);
    }
}
```

## Optimization Rules

1. **Count BEFORE filter:** Always call `.Count()` on the raw query first to get `recordsTotal`.
2. **Filter then count again:** Call `.Count()` on the filtered query for `recordsFiltered`.
3. **Sort using string column names:** The `sortColumn` parameter is a string from `data.columns[data.order[0].column].name` (not an integer).
4. **Paginate AFTER sort:** Chain `.Skip(start).Take(length)` as the LAST operation before `.ToList()`.
5. **Format dates AFTER ToList:** Use `.ToList()` first, then `.Select()` to format dates — LINQ-to-SQL cannot translate `DateTime.ToString()`.
6. **Search on computed columns:** Use `GetDataValueName()` inside the query for computed fields, but search those fields via string `.Contains()` on the query result.
7. **Use `throw new Exception(message, ex)` in catch** to preserve the stack trace while passing a meaningful message.
8. **Date search:** When searchValue might be a date, use `DateTime.TryParse()` and add date-range filtering.

## Key Project Conventions

- **Master page placeholders:** `HeadContent` (CSS/JS), `MainContent` (HTML)
- **CSS for tables:** Import `tablestyle.css` from CustomCSS folder
- **Action button CSS classes:** `editListBtn` (orange bg, pencil icon), `printListBtn` (orange bg, print icon) — defined in `styleMaster.css`
- **No bento cards on list pages:** Lists use clean table containers only (no `.bento-card`, no `.bento-title`)
- **Edit links always open in new tab:** `window.open('Form.aspx?ID=' + id, '_blank')`
- **Print links also open in new tab:** Same pattern with `&print=1` query param
- **Date format:** Display as `DD-MMM-YYYY`, send as `dd/MM/yyyy` from server

## Reference Files

- `Modules/PatientManagement/OPDView.aspx` + `OPDView.aspx.cs` — Master reference for ALL list pages
- `Modules/PatientManagement/Physiotherapy_Assessment_List.aspx` + `.cs` — Secondary reference
- `wwwroot/THEME_TIBBIT/styleMaster.css` — Action button CSS classes
- `wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css` — Table styling
