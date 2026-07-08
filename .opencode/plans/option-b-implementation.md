# Option B Implementation Plan

## What's changing

For InPatientDischarge only:
- `Out_Patient.Patient_ID` = InPatientID (e.g., 122277)
- `Out_Patient.Reg_PatId` = In_Patient.Patient_ID (e.g., 57762) for EMR link
- `sp_FillOutPatientForm` will fail (INNER JOIN), so we use a fallback

Normal OPD flow stays 100% unchanged.

## Changes Required

### 1. Fix SaveRecord — Set Patient_ID correctly
**File:** `NewOutPatient.aspx.cs` (lines 197-201)

```csharp
OPD.Patient_ID = Convert.ToInt32(data.Patient_ID);
if (data.FormType == "InPatientDischarge")
{
    OPD.Reg_PatId = Convert.ToInt32(data.reg_ID);
}
else
{
    OPD.Reg_PatId = Convert.ToInt32(data.reg_ID);
}
```

Actually wait - both branches do the same thing for Reg_PatId! Let me fix this properly:

```csharp
if (data.FormType == "InPatientDischarge")
{
    OPD.Patient_ID = data.InPatientID;  // Store InPatientID
    OPD.Reg_PatId = Convert.ToInt32(data.reg_ID);  // Store Reg_patient.pat_id for EMR
}
else
{
    OPD.Patient_ID = Convert.ToInt32(data.Patient_ID);
    OPD.Reg_PatId = Convert.ToInt32(data.reg_ID);
}
```

### 2. Modify GetPatientFormData — Add fallback when SP fails
**File:** `NewOutPatient.aspx.cs` (lines 1556-1561)

When `sp_FillOutPatientForm(PatientID)` returns null (because INNER JOIN fails for InPatientDischarge), fall back to loading Out_Patient directly:

```csharp
var qry = db.sp_FillOutPatientForm(PatientID).FirstOrDefault();
if (qry == null)
{
    return GetOutPatientFormDataFallback(db, PatientID);
}
```

Create new method `GetOutPatientFormDataFallback`:
- Loads Out_Patient by Out_Patient_ID
- Returns JSON with form fields from Out_Patient + empty patient info fields
- Patient info (name, age, etc.) will be loaded separately by `loadInPatientFormData`

### 3. Update document.ready — Add loadInPatientFormData to update block
**File:** `NewOutPatient.aspx` (lines 241-264)

Add `loadInPatientFormData(inPatientID)` to the update block:

```javascript
if (formType == "InPatientDischarge" && id != "") {
    // ...existing code...
    loadPatientFormData(id);
    loadInPatientFormData(inPatientID);  // ADD THIS
    // ...rest of existing code...
}
```

This ensures patient info labels (name, age, contact, address) get filled from Reg_patient table.

## Flow Summary

| Step | Action |
|---|---|
| Save | `Patient_ID` = InPatientID, `Reg_PatId` = Reg_patient.pat_id |
| Load (update) | `loadPatientFormData` → SP fails → fallback returns form fields from Out_Patient |
| Load (update) | `loadInPatientFormData(inPatientID)` → fills patient info from Reg_patient |
| EMR | `Reg_PatId` = Reg_patient.pat_id → EMR works correctly |
| Normal OPD | Unchanged — all logic stays the same |

## Files to Modify

1. **NewOutPatient.aspx.cs** — 3 changes:
   - SaveRecord: Patient_ID = InPatientID for InPatientDischarge
   - GetPatientFormData: add fallback when SP returns null
   - New: GetOutPatientFormDataFallback method

2. **NewOutPatient.aspx** — 1 change:
   - Add `loadInPatientFormData(inPatientID)` in update block
