@AGENTS.md

# CLAUDE.md — Claude Code additions (local only, git-excluded)

AGENTS.md above is the shared rulebook. This file adds DB knowledge + token discipline.

## Token discipline (follow strictly)
- Never open `GL/DataBase.dbml` (1.1 MB) or `GL/DataBase.designer.cs` (8.5 MB) whole. Never read `.rpt`, `ig_res/`, `wwwroot/`, `bin/`, `obj/`, `packages/`, `_Backups/`.
- Schema question → one `sqlcmd` query (below), not the DBML. DBML can lag the DB; the DB wins.
- Read files with `offset/limit` around a grep hit; code-behinds are often 2–5k lines.
- `GL/docs/*.md` are long (200–900 lines). Grep them for the section you need; don't read them whole. `DATABASE_ERD.md` = table relationships.
- Search with Grep + `glob` scoped to one module folder first; widen only if empty.
- No Explore/subagent for a lookup you can do in 1–3 greps. Use one when sweeping >10 files.
- No summaries of what you read, no restating the plan, no re-reading files you just edited.
- Answers: short, file:line refs, no preamble.

## Database
- SQL Server. Test DB `H_P_National_Hospital` on `WIN-7KMENC287FG\SQLEXPRESS` (Windows auth, `-E`). Production is on another PC (`NOUMANPC`) and unreachable.
- Treat the DB as **read-only**. Any `INSERT/UPDATE/DELETE/ALTER/CREATE/DROP` needs the user's explicit OK in this session.
- Size: 334 tables, 748 procs, 76 scalar fns, 40 views, **25 FKs only**, no triggers. Relationships are by column-name convention, enforced in code.
- Tenancy: business rows carry `Company_ID` (→ `sys_Companys`) and often `Book_ID` (→ `GL_SetOfBook`); filter by both from `AppConfig.Company_ID` / `AppConfig.Book_ID`.
- Audit cols: `Created_By/Updated_By/Approved_By` (Guid → `aspnet_Users.UserId`), `Created_Time/Updated_Time`.
- Auth = stock ASP.NET Membership (`aspnet_*`); menu gating `Menus`, `Role_Page`, `aspnet_RolesInMenus`.
- Patient chain: `Reg_patient.pat_id` → `Patients` / `Out_Patient` / `In_Patient` / `Emergency` (via `Reg_PatId`) → bills `Ar_Billings` (`Opd_Id`, `In_Patient_ID`) → `Ar_Billing_Details` → receipts `Ar_PaymentForm(_Details)`, `Receipts`.
- GL: `GL_Accounts` (self-FK tree) → `GL_Vouchers` → `GL_Voucher_Accounts`. Ledgers via `vwGL_Ledger`, `vwGeneral_Ledger`, `spGL_Ledger`.
- Stock: `INV_Items`, `Item_Warehouse_Mapping`, ledgers `vwInv_Stock_Ledger*`, `vwBatch_Ledger*`.
- Approvals: `SpApprove_*` procs, `Sys_Approval_Tempelate_Master`, `Sys_Approval_Logs`.
- Big tables (avoid unfiltered `SELECT`; always `TOP`): `Out_Patient_Eye_Info` 1.3M, `Previous_Dpt` 350k, `Sys_MsgLogs` 257k, `Out_Patient_Slit_Lamp_Exam` 256k, `GL_Voucher_Accounts` 113k.
- Report procs (`sp_*BasePrint`, `sp_*SubReport*`) feed Crystal `.rpt`; changing their column list breaks the report.
- `_claude` / `_BACKUP` suffixed procs and `_Backups/Procs_*` are scratch copies, not live code.

### Lookup recipes (copy, swap the name)
```bash
# columns of a table
sqlcmd -S 'WIN-7KMENC287FG\SQLEXPRESS' -E -d H_P_National_Hospital -W -s '|' -Q "SET NOCOUNT ON; SELECT name,TYPE_NAME(user_type_id) type,max_length,is_nullable FROM sys.columns WHERE object_id=OBJECT_ID('dbo.Ar_Billings')"
# full proc/view/function source
sqlcmd -S 'WIN-7KMENC287FG\SQLEXPRESS' -E -d H_P_National_Hospital -y 0 -Q "SET NOCOUNT ON; SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.spGL_Ledger'))"
# which procs/views touch a table
sqlcmd -S 'WIN-7KMENC287FG\SQLEXPRESS' -E -d H_P_National_Hospital -W -Q "SET NOCOUNT ON; SELECT name FROM sys.objects WHERE type IN('P','V','FN','TF') AND OBJECT_DEFINITION(object_id) LIKE '%Ar_Billings%'"
# find tables/columns by name fragment
sqlcmd -S 'WIN-7KMENC287FG\SQLEXPRESS' -E -d H_P_National_Hospital -W -s '|' -Q "SET NOCOUNT ON; SELECT TABLE_NAME,COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME LIKE '%discount%'"
```
If the DB is unreachable: `Grep pattern='Table Name="dbo.X"' path=GL/DataBase.dbml -A 40`.

## Data access in code
- Two styles coexist; match the file you're in:
  - LINQ to SQL `DataBaseDataContext` (~425 files).
  - `DBClass` raw SQL (~367 files): `getDataTable(sql, params SqlParameter[])`, `getField(sql, params)`, `exectueQueryWithParms`, `Param(name, value)`, `LogError`, `UserHasRight`, `GetNew*No`. Helpers in `GL/App_Themes/App_Data/DBClass.cs`.
- New/edited SQL: always parameterized (`DBClass.Param`), never string-concat user input.
- Session context: `AppConfig.UserID / UserName / Company_ID / Book_ID / DateFormat`.
- Proc → code: `Grep pattern='spName' glob='*.cs'` (also check `.aspx`, `.ashx`, `.asmx`).

## Verify
- Compile: `"C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe" GL/GL.csproj -nologo -p:Configuration=Debug -v:m` (C# 7.3; new .cs files need `<Compile Include>`). `.aspx` markup is compiled only at runtime.
- Never commit or push unless asked. Never paste Web.config secrets into chat, docs, or code.
