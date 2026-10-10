# Crystal Report Request

> **Instructions for OpenCode:** When a request is filled in below:
> 1. Follow `.opencode/rules/crystal-reports.md` and `.opencode/skills/crystal-report-workflow/SKILL.md` at all times.
> 2. Use ONLY the explicitly named database — never assume or switch silently.
> 3. Follow the mandatory order: stored procedure → SQL testing → Crystal Report → ASPX/C# → end-to-end testing.
> 4. NEVER parse, patch, hex-edit, or rewrite `.rpt` binary bytes directly — Crystal SDK APIs only.
> 5. Ask questions only when essential information is missing. Nonessential fields may be left blank.

---

## Request Details

### Report
- **Report name:**
- **Objective:**

### Database
- **Exact target database name:** *(required — task will not start without it)*

### Reference
- **Reference screenshot path:** or
- **Existing `.rpt` path:**

### Stored Procedure
- **Existing procedure name:** *(or state "new procedure required")*
- **May the existing procedure be modified?** Yes / No

### Output
- **Required output columns:**
- **Grouping:**
- **Sorting:**
- **Calculations / totals:**

### Filters & Parameters
- **Filters:**
- **Parameter types:** *(date, string, integer, multi-value, etc.)*

### Integration Paths (if known)
- **ASPX page:**
- **C# code-behind:**
- **Report viewer:** *(default: `GL/Report.aspx` → `GL/ReportViewer.aspx`)*
- **Menu parent ID:**

### Testing
- **Expected output:**
- **Representative test cases:**

### Notes
- **Special requirements:**
- **Exclusions:**
