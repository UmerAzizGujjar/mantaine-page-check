# Remaining InPatientDischarge Fixes - Part 3

## Remaining Issues

### 1. Services not loading
**Root cause:** `LoadServicesDetail` has `PatientType == "OutPatient"` filter, but InPatientDischarge uses `PatientType = "InPatient Discharge"` (Fix 2). So saved services are never loaded.

**Fix:** Change PatientType filter in `LoadServicesDetail` (line 739-740):
```csharp
// BEFORE:
.Where(s => (formType == "InPatientDischarge" ? s.In_Patient_Id.ToString() == outPatientId : s.Ou_Patient_Id == outPatientId) && s.PatientType == "OutPatient")

// AFTER:
.Where(s => (formType == "InPatientDischarge" ? s.In_Patient_Id.ToString() == outPatientId : s.Ou_Patient_Id == outPatientId) && (formType == "InPatientDischarge" ? s.PatientType == "InPatient Discharge" : s.PatientType == "OutPatient"))
```

### 2. Services accumulating duplicates
**Root cause:** `SaveServices` has NO delete logic. Old records are never removed. For InPatientDischarge, every save adds new records on top of old ones.

**Fix:** Add delete logic to `SaveServices` (around line 994):
```csharp
// BEFORE:
if (formType == "InPatientDischarge")
{
    newService.In_Patient_Id = outPatientId;
    newService.Ou_Patient_Id = "0";
    newService.PatientType = "InPatient Discharge";
}
else
...

// AFTER: Before the foreach, add delete logic
if (formType == "InPatientDischarge")
{
    var existingServices = db.InPatientServices
        .Where(s => s.In_Patient_Id == outPatientId && s.PatientType == "InPatient Discharge").ToList();
    db.InPatientServices.DeleteAllOnSubmit(existingServices);
}
```

### 3. Protos not loading/showing
**Root cause:** `LoadProtoDetails` (line 2460) queries by `Outpatient_id == patients_id` only. InPatientDischarge saves protos with `In_Patient_ID` but `Outpatient_id = 0`. So protos are never loaded back.

**Fix:** Add `formType` parameter to `LoadProtoDetails` and query by correct column. Also update the JS call.

**C# method (line 2455):**
```csharp
// BEFORE:
public static string LoadProtoDetails(string patients_id)
{
    ...
    var OutPatients_Proto = db.OutPatients_Protos.DefaultIfEmpty()
        .Where(w => w.Outpatient_id == Convert.ToInt32(patients_id)).ToList();

// AFTER:
public static string LoadProtoDetails(string patients_id, string formType)
{
    ...
    var pid = Convert.ToInt32(patients_id);
    var OutPatients_Proto = formType == "InPatientDischarge"
        ? db.OutPatients_Protos.Where(w => w.In_Patient_ID == pid).ToList()
        : db.OutPatients_Protos.Where(w => w.Outpatient_id == pid).ToList();
```

**JS call (line 4554):**
```javascript
// BEFORE:
PageMethods.LoadProtoDetails(patients_id, function (response) {
// AFTER:
PageMethods.LoadProtoDetails(patients_id, globalFormType, function (response) {
```

### 4. Tab #09 and #10 not hiding
**Root cause:** `loadPolicyVisibility()` runs an async AJAX that completes AFTER `hideInPatientDischargeElements()`, and re-shows the tabs.

**Fix:** Add a setTimeout re-hide at the end of document.ready (around line 591):
```javascript
if (formType == "InPatientDischarge") {
    hideInPatientDischargeElements();
    setTimeout(function() {
        $('#09, #10, #tab09, #tab10, #dvtblResultrpt').hide();
    }, 200);
}
```

## Files to Modify

### NewOutPatient.aspx.cs — 3 changes:
1. `LoadServicesDetail` (line ~739): Fix PatientType filter
2. `SaveServices` (line ~993): Add delete logic
3. `LoadProtoDetails` (line ~2455): Add formType, fix query

### NewOutPatient.aspx — 2 changes:
1. `Load_Proto` (line ~4554): Pass globalFormType
2. Document ready (line ~591): Add setTimeout re-hide for tabs
