---
name: crystal-report-workflow
description: Use for ALL Crystal Reports tasks — creating or modifying .rpt reports, report stored procedures, report datasets, and ASPX/C# report integration (Report.aspx → ReportViewer.aspx). Enforces the mandatory order (requirements → stored procedure → SQL test → Crystal Report → ASPX/C# → end-to-end test), database safety, and SDK-only .rpt changes. Pair with the crystal-reports rule.
---

# Crystal Report Workflow

Reusable workflow for report tasks in this project: ASP.NET Web Forms (.NET 4.8), C#, SQL Server, Crystal Reports 2013. The `.opencode/rules/crystal-reports.md` rule auto-loads with this skill — this file is the step-by-step execution path.

## 1. Required Task Inputs

Before starting, confirm with the user (ask if missing):
- **Exact database name** — never assume; never switch silently
- **Report objective and required columns**
- **Reference screenshot or existing `.rpt` path** (`GL/Reports/`)
- **Stored procedure:** existing one to reuse, or explicit authorization to create a new one
- **Filters and parameters** (date ranges, IDs, status flags, etc.)
- **Existing ASPX and C# page paths**, if known (`GL/Report.aspx` → `GL/ReportViewer.aspx(.cs)` for the viewer)

## 2. Mandatory Execution Order

1. Inspect existing project patterns and relevant documentation (`GL/docs/`, ERD, table comments)
2. Confirm the exact target database
3. Inspect only relevant database objects (tables, columns, relationships, procedures) — never repeatedly scan the whole database
4. Create or update the stored procedure (only as explicitly authorized)
5. Test the SQL output BEFORE proceeding — never build a report on unverified SQL
6. Create or modify the Crystal Report
7. Implement the ASPX frontend and C# code-behind
8. Test the integrated report and summarize results

Do not skip ahead. Each step gates the next.

## 3. SQL Verification

Before touching the report, verify the procedure output:
- Output columns present, correctly named, correct data types
- Joins return expected row counts (no accidental fan-out)
- Date filters applied as specified
- NULL handling (empty strings / defaults where the report expects them)
- No duplicate rows; grouping and totals correct where applicable

Do NOT change unrelated procedures or database schemas — no exceptions without explicit authorization.

## 4. Crystal Reports Safety

- Verify installed SDK capabilities BEFORE programmatic design changes (Crystal Reports 2013 / `CrystalDecisions` assemblies)
- Use ONLY supported Crystal Reports APIs (`ReportDocument`, `ReportClientDocument`, `ReportDefController`, `ReportObjectController` with `Clone()` + `Modify()`)
- Back up the `.rpt` to `_Backups/` BEFORE any modification
- Save through supported APIs, then reopen the saved report and verify the change persisted
- NEVER parse, patch, hex-edit, or rewrite `.rpt` binary bytes directly — no unofficial binary-editing libraries
- If an operation is unsupported by the SDK, explain the limitation and provide manual Crystal Reports Designer steps instead

## 5. Web Forms Integration

- Follow existing project patterns (`GL/Report.aspx` → `GL/ReportViewer.aspx(.cs)` viewer chain)
- Preserve the existing connection configuration (`GL/Web.config`) — never hardcode credentials
- Validate report parameters, data binding, and report viewer integration (parameter prompt, export, print paths)
- Keep diffs small; touch only files needed

## 6. Completion Report

Every report task ends with a summary listing:
- Files changed
- Database objects changed
- Tests ACTUALLY executed and their results (never claim a test passed unless it ran and output was observed)
- Failures, unsupported operations, and remaining manual work (e.g., steps needing Crystal Designer)

## Related Skills
- Rules: `.opencode/rules/crystal-reports.md` (mandatory, auto-loaded)
- List-style report pages: load `@list-pages` for server-side DataTable patterns
