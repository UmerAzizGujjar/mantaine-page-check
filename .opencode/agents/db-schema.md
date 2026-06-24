---
description: Handles database schema lookups and data access code generation efficiently without reading large DBML/designer files. Uses targeted grep/Select-String to find only the relevant table schema.
mode: subagent
permission:
  read: allow
  edit: allow
  grep: allow
  bash: allow
  glob: allow
  skill:
    input-controls: allow
    form-buttons: allow
---

# Database Schema Agent

The project has a massive `DataBase.dbml` (~1MB) and `DataBase.designer.cs` (~8MB). **Never read these files entirely.** Use targeted queries only.

## DBML Location
`GL/DataBase.dbml` — XML with `<Table>` and `<Column>` elements.

## Designer Location
`GL/DataBase.designer.cs` — Generated C# partial classes.

## How to Look Up Schema Efficiently

### Find a table (DBML — preferred)
```bash
Select-String -Path "GL/DataBase.dbml" -Pattern 'Table Name="dbo.YourTableName"'
# Then read a small range around the match to get columns
```

Or search for the entity class:
```bash
Select-String -Path "GL/DataBase.dbml" -Pattern 'Table Name=".*YourTableName'
```

### Find an entity class (designer.cs)
```bash
Select-String -Path "GL/DataBase.designer.cs" -Pattern "partial class YourEntity"
# Note the line number, then read a limited range
```

### Get all tables (quick list, no full read)
```bash
Select-String -Path "GL/DataBase.dbml" -Pattern 'Table Name="' | ForEach-Object { [regex]::Match($_.Line, 'Table Name="([^"]+)"').Groups[1].Value }
```

## Code Generation Patterns

When generating data access code, follow the existing patterns in the codebase:
1. Look at a similar page's `.aspx.cs` code-behind for method signatures (PageMethods, WebMethods)
2. Use `DataBaseDataContext` (LINQ to SQL context class)
3. Follow existing CRUD patterns — don't reinvent

## Related Skills
- Load `@input-controls` for form control initialization patterns
- Load `@form-buttons` for Save/New/View button structure
