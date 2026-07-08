# InPatient Discharge Details — Final Plan (v3)

## Approach
- Add new `In_Patient_ID` column to child tables that have OutPatientID columns
- In_Patient_Medicines: use `Transaction_Type = "InPatient Discharge"` + `Patient_ID = InPatientID` (no new column)
- EyeDetails: use `TransactionType = "InPatient Discharge"` + `TransactionID = InPatientID` (no new column)
- Laboratory_Tests/Details: hide tabs in JS, no save/load changes needed
- Normal OPD flow: completely unchanged

---

## Part 1: SQL Queries

```sql
-- 1. Out_Patient: add Type column
ALTER TABLE Out_Patient ADD Type VARCHAR(50) NULL;

-- 2. sys_parms: button toggle
INSERT INTO sys_Parms (Name, Code, Company_ID) 
VALUES ('InPatient Discharge Details', '1', <your_company_id>);

-- 3. Add In_Patient_ID to tables that need it (don't already have it):
ALTER TABLE OutPatients_Protos ADD In_Patient_ID INT NULL;
ALTER TABLE OutPatientPrimaryDiagnosis ADD In_Patient_ID INT NULL;
ALTER TABLE OutPatientFinalDiagnosis ADD In_Patient_ID INT NULL;
ALTER TABLE OutPatientComplaints ADD In_Patient_ID INT NULL;

-- Tables that ALREADY have In_Patient_ID (no ALTER needed):
-- InPatientServices (In_Patient_Id), Lab_Resultrpt (In_Patient_ID), Sysmtopms (In_Patient_ID)

-- NO column needed for:
-- In_Patient_Medicines (use Transaction_Type = "InPatient Discharge")
-- EyeDetails (use TransactionType = "InPatient Discharge")
-- Laboratory_Test / Lab_Test_Detail (tabs hidden, no data saved)
```

---

## Part 2: DBML (user adds manually)

Add `Type` column to `Out_Patient` in DBML + designer.cs. Uncomment C# `// OPD.Type` lines after.

---

## Part 3: `InPatientsCase.aspx.cs` — No changes needed

`CheckFinalBillAndDischargePermission` already returns `existingOutPatientID`.

---

## Part 4: `InPatientsCase.aspx` — No changes needed

Button, click handler, permission check — all done.

---

## Part 5: `NewOutPatient.aspx.cs` — Changes

### 5a. Revert Patient_ID override in SaveRecord

**New record block (line ~188):**
```csharp
// CHANGE FROM:
if (data.FormType == "InPatientDischarge")
{
    OPD.Patient_ID = data.InPatientID;  // ← REMOVE
    // OPD.Type = "InPatientDischarge";
}
// CHANGE TO:
if (data.FormType == "InPatientDischarge")
{
    // OPD.Type = "InPatientDischarge";
}
```

**Update block (line ~212):** Same change — remove `OPD.Patient_ID = data.InPatientID`.

### 5b. Change UpdateRelatedRecords call in SaveRecord

```csharp
if (data.FormType == "InPatientDischarge")
{
    UpdateRelatedRecordsForInPatientDischarge(db, data.InPatientID);
}
else
{
    UpdateRelatedRecords(db, OPD.Out_Patient_ID);  // original
}
```

### 5c. New method: `UpdateRelatedRecordsForInPatientDischarge`

```csharp
private static void UpdateRelatedRecordsForInPatientDischarge(DataBaseDataContext db, int inPatientId)
{
    // In_Patient_Medicines: set Transaction_Type + Patient_ID
    var medicines = db.In_Patient_Medicines
        .Where(p => p.Patient_ID == 0 && p.Transaction_Type == "OutPatient").ToList();
    foreach (var m in medicines)
    {
        m.Patient_ID = inPatientId;
        m.Transaction_Type = "InPatient Discharge";
    }

    // InPatientServices: use In_Patient_Id
    var services = db.InPatientServices
        .Where(p => p.Ou_Patient_Id == "0" && p.PatientType == "OutPatient").ToList();
    foreach (var s in services) { s.In_Patient_Id = inPatientId; }

    // Lab_Resultrpts: use In_Patient_ID
    var rpts = db.Lab_Resultrpts
        .Where(p => p.Out_Patient_ID == 0 && p.Transaction_Type == "OutPatient").ToList();
    foreach (var r in rpts) { r.In_Patient_ID = inPatientId; }

    // EyeDetails: set TransactionType + TransactionID
    var eyes = db.EyeDetails
        .Where(t => t.TransactionType == "OutPatient" && t.TransactionID == 0).ToList();
    foreach (var e in eyes)
    {
        e.TransactionID = inPatientId;
        e.TransactionType = "InPatient Discharge";
    }

    // OutPatients_Protos: use In_Patient_ID
    var protos = db.OutPatients_Protos
        .Where(t => t.Outpatient_id == 0).ToList();
    foreach (var p in protos) { p.In_Patient_ID = inPatientId; }

    // OutPatientPrimaryDiagnosis: use In_Patient_ID
    var primaryDiag = db.OutPatientPrimaryDiagnosis
        .Where(t => t.OutPatientID == 0).ToList();
    foreach (var pd in primaryDiag) { pd.In_Patient_ID = inPatientId; }

    // OutPatientFinalDiagnosis: use In_Patient_ID
    var finalDiag = db.OutPatientFinalDiagnosis
        .Where(t => t.OutPatientID == 0).ToList();
    foreach (var fd in finalDiag) { fd.In_Patient_ID = inPatientId; }

    // OutPatientComplaints: use In_Patient_ID
    var complaints = db.OutPatientComplaints
        .Where(t => t.OutPatientID == 0).ToList();
    foreach (var c in complaints) { c.In_Patient_ID = inPatientId; }

    // Sysmtopms: use In_Patient_ID
    var symptoms = db.Sysmtopms
        .Where(t => t.Out_Patient_ID == 0).ToList();
    foreach (var s in symptoms) { s.In_Patient_ID = inPatientId; }

    db.SubmitChanges();
}
```

### 5d. Modify 7 child save methods — add `string formType` param

| Method | Change for InPatientDischarge |
|---|---|
| `SaveServices` | `In_Patient_Id = PatientID, Ou_Patient_Id = "0"` |
| `SaveLabResultrpt` | `In_Patient_ID = OutPatientID, Out_Patient_ID = 0` |
| `SaveSymtoms` | `In_Patient_ID = OutPatientID, Out_Patient_ID = 0` |
| `SaveProto` | `In_Patient_ID = opdid` (Outpatient_id stays 0) |
| `SaveComplaintsOfPatient` | `In_Patient_ID = outPatientId, OutPatientID = 0` |
| `SavePrimaryDiagnosisOfPatient` | `In_Patient_ID = outPatientId, OutPatientID = 0` |
| `SaveFinalDiagnosisOfPatient` | `In_Patient_ID = outPatientId, OutPatientID = 0` |

**NOT modified** (per user instruction):
- `SaveMedicines` — uses `Transaction_Type = "InPatient Discharge"` + `Patient_ID = InPatientID` (handled by adding formType check)
- `SaveTest` — tabs hidden, no save happens

**SaveMedicines special handling:**
```csharp
[WebMethod]
public static string SaveMedicines(string MedicineDetails, string formType)
{
    // ... deserialize ...
    foreach (var med in medicineList)
    {
        var entity = new In_Patient_Medicine();
        if (formType == "InPatientDischarge")
        {
            entity.Patient_ID = MedicineDetail.PatientID; // InPatientID
            entity.Transaction_Type = "InPatient Discharge";
        }
        else
        {
            entity.Patient_ID = Convert.ToInt32(MedicineDetail.PatientID); // OutPatientID
            entity.Transaction_Type = "OutPatient";
        }
        // ... rest of fields ...
    }
}
```

**Delete logic in SaveMedicines also needs formType check:**
```csharp
if (formType == "InPatientDischarge")
    // Delete where Patient_ID == inPatientID && Transaction_Type == "InPatient Discharge"
else
    // Delete where Patient_ID == outPatientID && Transaction_Type == "OutPatient"
```

### 5e. Modify 6 child load methods — add `string formType` param

| Method | Change for InPatientDischarge |
|---|---|
| `LoadMedicines` | `Transaction_Type == "InPatient Discharge"` instead of `"OutPatient"` |
| `LoadComplaints` | `In_Patient_ID == OutPatientID` instead of `OutPatientID ==` |
| `LoadPrimaryDiagnosis` | `In_Patient_ID == OutPatientID` |
| `LoadFinalDiagnosis` | `In_Patient_ID == OutPatientID` |
| `LoadLabResultrptDetail` | `In_Patient_ID == PatientID` |
| `LoadServicesDetail` | `In_Patient_Id == outPatientId` |

**NOT modified** (per user instruction):
- `LoadSymtompsHistory` — add formType check: `In_Patient_ID ==` for InPatientDischarge
- Lab test load methods — tabs hidden

Actually, symptoms DO need modification. Let me add it:

| Method | Change for InPatientDischarge |
|---|---|
| `LoadSymtompsHistory` | `In_Patient_ID == OutPatientID` |

So 7 load methods modified total.

---

## Part 6: `NewOutPatient.aspx` — JS Changes

### 6a. Add global variable
```javascript
var globalFormType = '<%=Request.QueryString["Type"]%>' || '';
```

### 6b. Hide investigation/diagnostics tabs for InPatientDischarge
In `$(document).ready()`, when `formType == "InPatientDischarge"`:
```javascript
if (formType == "InPatientDischarge") {
    // Hide lab test / investigation tabs
    // (hide the relevant tab links and content)
}
```

### 6c. Modify 8 child save JS functions — pass `globalFormType`
Add `globalFormType` as last arg to `PageMethods.*` calls:
- SaveMedicines, SaveServices, SaveLabResult, SaveSymtoms (via SaveHistoryTab),
- SaveComplaintsTab, SavePrimaryDiagnosisTab, SaveFinalDiagnosisTab, SaveProtos

### 6d. Modify 7 child load JS functions — pass `globalFormType`
The load functions are called from `AppendComplaintsHistory()`, `AppendPrimaryDiagnosisHistory()`, etc. Need to pass `globalFormType` to the underlying `PageMethods.Load*` calls.

### 6e. Fix save callback
For InPatientDischarge, redirect with both IDs:
```javascript
if (formTypeId === 'InPatientDischarge') {
    var inPatID = $('#<%= hdfInPatientID.ClientID %>').val();
    window.location = "NewOutPatient.aspx?Type=InPatientDischarge&InPatientID=" + inPatID + "&ID=" + response.d;
    return;
}
```

### 6f. Update mode — set txtOut_Patient_ID to InPatientID
In the `formType == "InPatientDischarge" && id != ""` block:
```javascript
$('#<%= txtOut_Patient_ID.ClientID%>').val(inPatientID);
```
This ensures child save/load functions pass InPatientID as the ID value.

---

## Summary

| File | Changes |
|---|---|
| SQL | 2 setup + 4 ALTER TABLE = 6 queries |
| `NewOutPatient.aspx.cs` | Revert Patient_ID (2 spots), new UpdateRelatedRecordsForInPatientDischarge, modify 8 save methods + 7 load methods |
| `NewOutPatient.aspx` | globalFormType var, hide tabs, pass formType in 8 save + 7 load calls, fix callback |
| `InPatientsCase.*` | No changes (already done) |
