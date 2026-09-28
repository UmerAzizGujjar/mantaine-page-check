# AGENTS.md — Standard Hospital (GL)

## Repo
ASP.NET WebForms (.NET 4.8), app root `GL/`. SQL Server + Crystal Reports. No test project; `GL/compile_check.ps1` for compile checks.

## Fast routes
- Auth/session/login: `GL/Login.aspx(.cs)`, `GL/Site.Master(.cs)`, `GL/Modules/Accounts/`
- Patient: `GL/Modules/PatientManagement/` (+ root `Patients.aspx`, `OutPatients.aspx`)
- Billing: `GL/Modules/Billing/`, `GL/Modules/AR/`
- Purchasing/stock/pharmacy: `GL/Modules/Inventory/`, `GL/Modules/AP/`
- Lab/radiology: `GL/Modules/Lab/`
- Reports: `GL/Report.aspx` → `GL/ReportViewer.aspx(.cs)`; `.rpt` in `GL/Reports/` (don't read unless asked)
- Dashboards: `GL/Modules/Dashboards/`
- Shared helpers: `GL/App_Themes/App_Data/` (AppConfig, DBClass, EMRDb)
- DB model: `GL/DataBase.dbml` / `DataBase.designer.cs` (generated)
- Docs: `GL/docs/` (ERD, HOW_THE_SYSTEM_WORKS, FLAWS_AND_RISKS, PROMPT_TEMPLATE)

## Page anatomy
- Page = 3 files: `X.aspx`, `X.aspx.cs`, `X.aspx.designer.cs` (generated, don't hand-edit).
- Form `X.aspx`; list `XView.aspx`; shell `GL/Site.Master`; minimal shell `GL/SiteNoMenu.Master`.
- Hidden logic: `[WebMethod]` statics, `.ashx`, `.asmx`, `GL/Json.aspx` — check these when tracing features.
- Follow `.opencode/rules/ui-conventions.md` (auto-loaded). Skills: entity-form, form-buttons, modal-design, dashboard-design, theme-colors.
- Subagents: `db-schema` for schema lookups, `webform-scaffold` for new page trios, `css-sync` for theme CSS.

## Search hygiene
- Exclude: `GL/ig_res/`, `GL/wwwroot/`, `GL/bin/`, `GL/obj/`, `GL/Reports/`, `GL/Dependencies/`, `_Backups/`, `.opencode/`.
- Avoid `DataBase.designer.cs` and `*.designer.cs`; ask db-schema agent instead.

## Rules of engagement
- Small diffs; touch only files needed; no drive-by refactors or reformatting.
- No DB schema changes unless asked.
- Auth/upload/report/backup: state risk, keep behavior, ask before changing.
- Match the PATTERN page named in the task.
- Never put credentials or patient data in code, docs, or rules.
- Verify: compile in VS/msbuild; state manual checks (no test suite).