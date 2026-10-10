# Database Documentation Framework

Documentation for SQL Server databases used by this project (ASP.NET Web Forms + Crystal Reports). This folder documents schemas and existing procedures — it does not contain application code.

## Folder Organization

Documentation is kept **separately per database**. Never mix two databases' details in one file.

```
Database/
├── README.md                          ← this file
├── Templates/                         ← blank templates (copy per object)
│   ├── Tables.md
│   ├── Relationships.md
│   ├── Views.md
│   └── ExistingProcedures.md
├── Schema/
│   └── <DatabaseName>/                ← one folder per database, exact name
│       ├── Tables.md
│       ├── Relationships.md
│       └── Views.md
└── Procedures/
    └── <DatabaseName>/                ← one folder per database, exact name
        └── ExistingProcedures.md
```

`<DatabaseName>` must exactly match the SQL Server database name (e.g. `Schema/HospitalGL/Tables.md`).

## Rules

1. **Reuse before inspecting.** Check existing documentation first (`GL/docs/` ERD, this folder) before querying the database.
2. **Inspect only what the task needs.** Query only tables/columns/procedures relevant to the current task. Never repeatedly scan the whole database.
3. **Never copy across databases.** Schema details from one database must never be copied into another database's docs without direct verification against that database.
4. **Verified vs assumed.** Every entry must state whether it was **verified** (observed in the database) or is an **assumption** (inferred from code, naming, or unconfirmed docs). Mark unverified items clearly.
5. **Record date + source.** Where practical, note the date the fact was verified and the source (query result, sys catalog view, ERD doc, code inspection).
6. **Never modify.** Documentation tasks are read-only: no schema changes, no data changes, no procedure changes.
7. **Exact database only.** Document the database named in the task — never a different one.

## How to Use

1. Copy the relevant template from `Templates/` into the correct `Schema/<DatabaseName>/` or `Procedures/<DatabaseName>/` folder.
2. Fill in only the objects relevant to the current task.
3. Mark each fact **Verified** or **Assumption**, with date + source where practical.
4. Append to existing files rather than overwriting them.
