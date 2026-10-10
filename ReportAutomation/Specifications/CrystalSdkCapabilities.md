# Crystal Reports SDK Capability Assessment

**Project:** Standard Hospital (GL) — ASP.NET Web Forms (.NET 4.8), C#
**Assessment date:** 2026-10-10
**Method:** Read-only inspection (file versions, registry, GAC, .NET reflection) + one safe proof of concept on a **disposable copy** of `GL/Reports/rpt_IPD_Discharge.rpt` (original hash-verified unchanged; temp copy deleted after).
**Databases touched:** none. Original `.rpt` files: not modified. Application code: not modified.

**Status legend:** `VERIFIED` = observed executing (PoC) or directly evidenced. `UNVERIFIED` = exists but not executed/confirmed. `UNSUPPORTED` = unavailable or prohibited by policy.

---

## 1. Installed Assemblies, Versions, Locations

**Status: VERIFIED**

### Runtime assemblies (deployed with app)

Location: `GL/bin/`

| Assembly | FileVersion |
|---|---|
| CrystalDecisions.CrystalReports.Engine.dll | 13.0.12.1494 |
| CrystalDecisions.Shared.dll | 13.0.12.1494 |
| CrystalDecisions.ReportSource.dll | 13.0.12.1494 |
| CrystalDecisions.Web.dll | 13.0.12.1494 |
| CrystalDecisions.ReportAppServer.* (ClientDoc, Controllers, ReportDefModel, DataDefModel, CommLayer, CommonControls, CommonObjectModel, CubeDefModel, DataSetConversion, ObjectFactory, Prompting, XmlSerialize) | 13.0.16.1954 |

Also registered in the .NET GAC (both GAC_32/GAC_64 trees scanned — all 13 assemblies present).

**Limitation (risk):** Engine/Shared/Web are SP12-level (13.0.12) while ReportAppServer assemblies are SP16-level (13.0.16). Mixed SP levels loaded side-by-side may cause subtle binding/behavior issues. Evidence: file versions above. Registry confirms runtime key `CRRuntime64Version = 13.0.12`.

### Native runtime

- `crpe32.dll` 13.0.12.1494 at `C:\Program Files (x86)\SAP BusinessObjects\Crystal Reports for .NET Framework 4.0\Common\SAP BusinessObjects Enterprise XI 4.0\win64_x64\` — **VERIFIED** (64-bit runtime available; process must run x64 or x86-matched).

### Design-time (Crystal Reports Designer)

- `crw32.exe` **14.1.5.1501** (Crystal Reports 2013 SP5) at `C:\Program Files (x86)\SAP BusinessObjects\SAP BusinessObjects Enterprise XI 4.0\win32_x86\` — **VERIFIED**.

### Registry keys

- `HKLM\SOFTWARE\SAP BusinessObjects\Crystal Reports for .NET Framework 4.0\Crystal Reports` — **VERIFIED** (Path, BuildNum 99, CRRuntime64Version 13.0.12, CommonFiles).
- `HKLM\SOFTWARE\WOW6432Node\SAP BusinessObjects\Suite XI 4.0\Crystal Reports` Version 14.0 — **VERIFIED**.

## 2. `CrystalDecisions.CrystalReports.Engine` APIs

**Status: VERIFIED (via reflection on `GL/bin` assemblies)**

`ReportDocument` members confirmed present: `Load`, `SaveAs`, `Close`, `Refresh`, `VerifyDatabase`, `Export`, `ExportToDisk`, `ExportToHttpResponse`, `ExportToStream`.

Key properties confirmed: `IsLoaded`, `HasSavedData`, `ReportClientDocument` (→ `ISCDReportClientDocument`), `Database`, `DataDefinition`, `ReportDefinition`, `SummaryInfo`, `PrintOptions`, `ExportOptions`, `ParameterFields`, `DataSourceConnections`.

Executed in PoC: `Load`, `Close`, `ReportDefinition.Sections` read (6 sections), `SummaryInfo.ReportTitle` read after reopen. — **VERIFIED**.
Not executed (need DB or render host): `VerifyDatabase`, `Export*`, parameter binding — **UNVERIFIED** (presence ≠ operation support).

## 3. RAS Bridge and Controllers

**Status: VERIFIED**

- `ReportDocument.ReportClientDocument` returns `CrystalDecisions.ReportAppServer.ClientDoc.ISCDReportClientDocument` — **VERIFIED** (reflection + PoC: `IsOpen = True` on loaded report).
- Controller properties on `ISCDReportClientDocument` (reflection): `ReportDefController` (`ReportDefController2`), `DatabaseController`, `DataDefController`, `RowsetController`, `SubreportController`, `PrintOutputController`, `CubeDefController`, `SearchController`, `CustomFunctionController` — **VERIFIED presence**.
- `Controllers.dll` exports object controllers incl. `ReportObjectController`, `ReportAreaController`, `ReportSectionController`, `FormulaFieldController`, `ParameterFieldController`, `GroupController`, `SortController`, `ResultFieldController`, `SummaryFieldController`, `FilterController`, `RunningTotalFieldController` — **VERIFIED presence**.
- `ReportDefModel.dll` exports report object classes: `TextObject`, `FieldObject`, `FieldHeadingObject`, `BoxObject`, `LineObject`, `ChartObject`, `CrossTabObject`, `PictureObject`, `SubreportObject`, `Section`, etc. — **VERIFIED presence**.

### PoC execution through RAS controllers

On the disposable copy: read `ReportDefController.ReportDefinition` — **VERIFIED** (5 areas, report objects enumerated through controller).

## 4. Inspect and Modify via Supported APIs

**Status: VERIFIED (PoC on disposable copy)**

- Inspect: Engine `ReportDefinition.Sections[n].ReportObjects` and RAS controller reads both returned live object counts. — **VERIFIED**
- Modify: `ISCDReportClientDocument.ModifySummaryInfo(SummaryInfo)` executed successfully on the copy. — **VERIFIED**
- Deeper object edits (`ReportObjectController` add/modify/delete via `Clone()` + `Modify()` pattern, `FormulaFieldController`, `DatabaseController` logon changes): APIs present — **UNVERIFIED** (not exercised; verify per-operation on a disposable copy before relying on them).

### PoC notes / API gotchas (recorded so they are not rediscovered)

1. `ModifySummaryInfo` parameter type is `CrystalDecisions.ReportAppServer.DataDefModel.SummaryInfoClass` — **not** `ReportDefModel` (easy to get wrong; first PoC attempt failed here).
2. `ISCDReportClientDocument.SaveAs(DisplayName, ref ParentFolderPath, Options)` targets a folder object, **not** a filesystem path. For file save use RAS `Save()` (in place on the loaded file) or Engine `ReportDocument.SaveAs(path, overwrite)`.
3. RAS area object counts via `Area.Sections[0].ReportObjects` cover only the first section per area; use Engine enumeration (all sections) for full counts (PoC: RAS partial 31 vs Engine full 38).

## 5. Save and Reopen

**Status: VERIFIED**

PoC sequence executed: modify summary info → `Save()` → `Close()` → fresh `ReportDocument.Load()` on saved file → `IsLoaded = True`, `SummaryInfo.ReportTitle` returned the new value (`SDK-PoC-2026-10-10`), section structure intact (6 sections). Saved report reopened and verified — **VERIFIED**.

## 6. Limitations

| Item | Status | Evidence |
|---|---|---|
| Mixed SP levels (Engine 13.0.12 vs RAS 13.0.16) | Risk — UNVERIFIED impact | File versions; recommend aligning SPs if anomalies appear |
| Licensing state | UNVERIFIED | `license` folder exists under designer install; key/status not inspected (read-only scope) |
| DB-connected operations (`VerifyDatabase`, live data binding, parameter set-then-fetch) | UNVERIFIED | PoC intentionally DB-free; requires a safe test database to verify |
| Rendering/export throughput in production app | UNVERIFIED | Needs runtime observation, not SDK surface |
| Direct binary patching / hex-editing of `.rpt` | **UNSUPPORTED** | Prohibited by project rule `.opencode/rules/crystal-reports.md` §5; never attempted |
| Unofficial binary-editing libraries | **UNSUPPORTED** | Prohibited by same rule |

## Proof of Concept Record

- Source report: `GL/Reports/rpt_IPD_Discharge.rpt` (224,768 bytes) — read only.
- Working copy: `C:\Users\syedm\AppData\Local\Temp\opencode\crpoc\poc_copy.rpt` — modified, saved, reopened, verified, then **deleted** (temp dir removed).
- Original integrity: SHA-256 hash identical before and after PoC — **VERIFIED original untouched**.
- No database connection made at any point.

## What Is Needed to Close UNVERIFIED Items

1. **DB-connected operations:** a safe/dev database named explicitly by the user, plus a disposable report copy — then `VerifyDatabase`, logon via `DatabaseController`, and parameter binding can be PoC'd the same way.
2. **Deep object-controller edits:** per-operation PoC (clone + modify one `TextObject`) on a disposable copy before relying on them.
3. **Licensing:** inspect the SAP license folder/keys (read-only) if license state becomes relevant.
