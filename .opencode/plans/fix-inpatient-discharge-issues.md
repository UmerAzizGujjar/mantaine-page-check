# Fix InPatientDischarge Issues - Implementation Plan

## Problem Summary

When clicking "Add Discharge Details" button, the following issues occur:
1. Patient details (name, age, contact, address) don't load
2. EMR button passes `RegID=(New)` instead of actual Reg_PatId
3. Save fails with error: "(New) is not a valid value for Int32"
4. Investigation and Diagnostics tabs remain visible

## Root Cause Analysis

### Database Schema
- `In_Patient.Patient_ID` (e.g., 57758) links to `Reg_patient.pat_id`
- `Reg_patient` table contains patient details (Full_Name, Mobile1, Age_years, etc.)
- `Patients` table is separate and may not have corresponding records
- `Out_Patient.Reg_PatId` should be set to `In_Patient.Patient_ID`

### Current Code Issues

#### Issue 1: Wrong JOIN in GetInPatientFormData WebMethod
**File:** `NewOutPatient.aspx.cs` (lines 1016-1028)

**Current code:**
```csharp
join p in db.Patients on ip.Patient_ID equals p.Patient_ID
```

**Problem:** Joins with `Patients` table, but patient data is in `Reg_patient` table

**Fix:** Join with `Reg_patient` table instead:
```csharp
join rp in db.Reg_patients on ip.Patient_ID equals rp.pat_id
```

#### Issue 2: Incorrect RegId mapping
**File:** `NewOutPatient.aspx.cs` (lines 1044-1045)

**Current code:**
```csharp
PatientId = qry.Patient_ID.ToString(),
RegId = qry.Reg_PatId.ToString(),
```

**Problem:** Uses `p.Reg_PatId` from `Patients` table (which doesn't exist)

**Fix:** Use `In_Patient.Patient_ID` as RegId:
```csharp
PatientId = qry.pat_id.ToString(),
RegId = qry.pat_id.ToString(),  // Use In_Patient.Patient_ID as Reg_PatId
```

#### Issue 3: SaveRecord doesn't handle InPatientDischarge
**File:** `NewOutPatient.aspx.cs` (line 201)

**Current code:**
```csharp
OPD.Reg_PatId = Convert.ToInt32(data.reg_ID);
```

**Problem:** When `data.reg_ID` is "(New)", Convert.ToInt32 throws exception

**Fix:** For InPatientDischarge, use `data.InPatientID` as Reg_PatId:
```csharp
if (data.FormType == "InPatientDischarge")
{
    OPD.Reg_PatId = data.InPatientID;
}
else
{
    OPD.Reg_PatId = Convert.ToInt32(data.reg_ID);
}
```

#### Issue 4: hideInPatientDischargeElements() called too early
**File:** `NewOutPatient.aspx` (lines 264, 273)

**Current code:**
```javascript
hideInPatientDischargeElements();  // Called inside if-else blocks
```

**Problem:** Called before all async initialization completes

**Fix:** Move to end of `$(document).ready()` after all initialization:
```javascript
// At the end of $(document).ready(), around line 592
if (formType == "InPatientDischarge") {
    hideInPatientDischargeElements();
}
```

## Implementation Steps

### Step 1: Fix GetInPatientFormData WebMethod
**File:** `NewOutPatient.aspx.cs` (lines 1016-1045)

**Changes:**
1. Change JOIN from `Patients` to `Reg_patients`
2. Update field mappings to use `Reg_patient` columns
3. Return `In_Patient.Patient_ID` as `RegId`

**Before:**
```csharp
var qry = (from ip in db.In_Patients
           join p in db.Patients on ip.Patient_ID equals p.Patient_ID
           where ip.In_Patient_ID == InPatientID
           select new
           {
               p.Full_Name,
               p.Age_years,
               p.Mobile1,
               p.Permanent_Address,
               p.Patient_ID,
               Reg_PatId = p.Reg_PatId ?? 0,
               p.Gender
           }).FirstOrDefault();

if (qry == null)
{
    return JsonConvert.SerializeObject(new { success = false, message = "InPatient data not found" });
}

var patientData = new
{
    success = true,
    data = new
    {
        PatientName = qry.Full_Name ?? "",
        Age = qry.Age_years ?? "",
        Contact = qry.Mobile1 ?? "",
        Address = qry.Permanent_Address ?? "",
        PatientId = qry.Patient_ID.ToString(),
        RegId = qry.Reg_PatId.ToString(),
        Gender = qry.Gender ?? ""
    }
};
```

**After:**
```csharp
var qry = (from ip in db.In_Patients
           join rp in db.Reg_patients on ip.Patient_ID equals rp.pat_id
           where ip.In_Patient_ID == InPatientID
           select new
           {
               rp.Full_Name,
               rp.Age_years,
               rp.Mobile1,
               rp.Permanent_Address,
               rp.pat_id,
               rp.Gender
           }).FirstOrDefault();

if (qry == null)
{
    return JsonConvert.SerializeObject(new { success = false, message = "InPatient data not found" });
}

var patientData = new
{
    success = true,
    data = new
    {
        PatientName = qry.Full_Name ?? "",
        Age = qry.Age_years ?? "",
        Contact = qry.Mobile1 ?? "",
        Address = qry.Permanent_Address ?? "",
        PatientId = qry.pat_id.ToString(),
        RegId = qry.pat_id.ToString(),  // Use In_Patient.Patient_ID as Reg_PatId
        Gender = qry.Gender ?? ""
    }
};
```

### Step 2: Fix SaveRecord method
**File:** `NewOutPatient.aspx.cs` (line 201)

**Before:**
```csharp
OPD.Patient_ID = Convert.ToInt32(data.Patient_ID);
OPD.Reg_PatId = Convert.ToInt32(data.reg_ID);
```

**After:**
```csharp
OPD.Patient_ID = Convert.ToInt32(data.Patient_ID);
if (data.FormType == "InPatientDischarge")
{
    OPD.Reg_PatId = data.InPatientID;
}
else
{
    OPD.Reg_PatId = Convert.ToInt32(data.reg_ID);
}
```

### Step 3: Move hideInPatientDischargeElements() to end of document.ready
**File:** `NewOutPatient.aspx`

**Remove from:**
- Line 264 (inside first if block)
- Line 273 (inside second if block)

**Add to:**
- End of `$(document).ready()` (around line 592), after all initialization:
```javascript
// At the very end of $(document).ready()
if (formType == "InPatientDischarge") {
    hideInPatientDischargeElements();
}
```

## Files to Modify

1. **NewOutPatient.aspx.cs**
   - Lines 1016-1028: Fix JOIN in GetInPatientFormData
   - Lines 1044-1045: Update response mapping
   - Line 201: Handle InPatientDischarge in SaveRecord

2. **NewOutPatient.aspx**
   - Line 264: Remove hideInPatientDischargeElements() call
   - Line 273: Remove hideInPatientDischargeElements() call
   - Line 592: Add hideInPatientDischargeElements() call at end of document.ready

## Expected Behavior After Fix

1. **Patient details load correctly:**
   - Full_Name: "Mr.M AMIR"
   - Mobile1: "+923156777715"
   - Age_years: "45Y"
   - Gender: "M"

2. **EMR button works:**
   - `hdfReg_ID` set to "57758"
   - EMR URL: `NewEMR.aspx?RegID=57758`

3. **Tabs hidden:**
   - Investigation tab (#09, #tab09) hidden
   - Diagnostics tab (#10, #tab10) hidden

4. **Save succeeds:**
   - No "(New) is not a valid value for Int32" error
   - `Out_Patient.Reg_PatId` set to 57758

## Testing Checklist

- [ ] Open InPatientsCase page
- [ ] Select an existing InPatient
- [ ] Click "Add Discharge Details" button
- [ ] Verify new tab opens with correct URL
- [ ] Verify patient details load (name, age, contact, address)
- [ ] Verify EMR button works with correct RegID
- [ ] Verify Investigation/Diagnostics tabs are hidden
- [ ] Save the record and verify no conversion error
- [ ] Verify Out_Patient.Reg_PatId is set correctly in database
