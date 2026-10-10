# Crystal Reports Rules

These rules are MANDATORY for all Crystal Reports work (.rpt files, report stored procedures, report datasets, ASPX/C# report integration). Stack: ASP.NET Web Forms, C#, SQL Server, Crystal Reports 2013.

## 1. Database Selection
- Use ONLY the exact database specified in the current task.
- NEVER switch databases silently.
- If the specified database is missing or unreachable, STOP and ask.

## 2. Reuse Documentation
- Inspect existing documentation first (GL/docs/, ERD, table comments).
- Query only the relevant tables, columns, relationships, and stored procedures for the task.
- Do NOT repeatedly scan the entire database.

## 3. Mandatory Order
1. Understand requirements
2. Create/update the stored procedure (as authorized)
3. Test SQL results
4. Create/modify the Crystal Report
5. Implement ASPX/C#
6. Test the complete workflow end to end

## 4. Existing Architecture
- Follow existing Web Forms pages, code-behind conventions, connection configuration (`GL/Web.config`), and report viewer patterns (`GL/Report.aspx` → `GL/ReportViewer.aspx(.cs)`).
- Keep changes small; touch only files needed.

## 5. Crystal SDK Only
- Verify the installed Crystal Reports SDK and available APIs BEFORE attempting programmatic report design changes.
- NEVER directly parse, hex-edit, patch, or rewrite `.rpt` binary bytes.
- NEVER use unofficial binary-editing libraries.

## 6. Safe Report Changes
- Back up an existing report BEFORE modifying it (`_Backups/`).
- Save through supported Crystal APIs only.
- Reopen and verify the saved report after saving.
- If an operation is unsupported by the SDK, explain the limitation and provide manual Crystal Designer steps instead.

## 7. Database Safety
- Do NOT modify schemas, production data, or unrelated procedures without explicit authorization.
- Test with safe, representative inputs.

## 8. Verification
- Test report parameters, filters, grouping, totals, null handling, duplicate rows, and output where applicable.
- NEVER claim a test passed unless it actually ran and output was observed.

## 9. Final Summary
Every report task ends with a summary listing:
- Files changed
- Database objects changed
- Tests executed and results
- Remaining manual steps
