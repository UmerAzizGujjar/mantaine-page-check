# Fix InPatientDischarge Issues - Part 2

## Issues and Root Causes

### 1. Diagnoses, Medicines, Services saved with Patient_ID = 0
**Root cause:** In the "new" InPatientDischarge block, `txtOut_Patient_ID` is set to `"(New)"`. Child save methods convert this to `0` and pass to WebMethods which set `In_Patient_ID = 0`.

### 2. Services saved as PatientType = "OutPatient"
**Root cause:** `SaveServices` always sets `PatientType = "OutPatient"` regardless of form type.

### 3. Lab Results section not hiding
**Root cause:** `hideInPatientDischargeElements()` doesn't hide the Lab Results div (`#dvtblResultrpt`).

### 4. Patient details get overwritten on load
**Root cause:** `loadPatientFormData` AJAX and `loadInPatientFormData` AJAX run in parallel. If `loadPatientFormData` completes second, it overwrites patient info with empty strings from the fallback.

### 5. MR No not showing
**Root cause:** `GetInPatientFormData` doesn't return `Patient_No` (MR No), and the JS doesn't set it.

## Fixes

### Fix 1: Set txtOut_Patient_ID to inPatientID in new block
**File:** `NewOutPatient.aspx` (lines 269-270)
```javascript
// BEFORE:
$('#ctl00_MainContent_txtOut_Patient_ID').val("(New)");
$('#<%= txtOut_Patient_ID.ClientID%>').val("(New)");

// AFTER:
$('#ctl00_MainContent_txtOut_Patient_ID').val(inPatientID);
$('#<%= txtOut_Patient_ID.ClientID%>').val(inPatientID);
```

This ensures child save methods send InPatientID instead of 0.

### Fix 2: Fix SaveServices PatientType for InPatientDischarge
**File:** `NewOutPatient.aspx.cs` (line 975)

Add to the InPatientDischarge block in SaveServices:
```csharp
if (formType == "InPatientDischarge")
{
    newService.In_Patient_Id = outPatientId;
    newService.Ou_Patient_Id = "0";
    newService.PatientType = "InPatient Discharge";
}
else
{
    newService.Ou_Patient_Id = outPatientId.ToString();
    newService.In_Patient_Id = null;
}
```

### Fix 3: Hide Lab Results div in hide function
**File:** `NewOutPatient.aspx` (line 1044)

Add to `hideInPatientDischargeElements()`:
```javascript
$('#dvtblResultrpt').hide();
```

### Fix 4: Load patient info after form data loads
**File:** `NewOutPatient.aspx` (lines 633-648)

Modify `loadPatientFormData` success handler to call `loadInPatientFormData` after populating when in InPatientDischarge mode:

```javascript
success: function (response) {
    hideLoading();
    var result = JSON.parse(response.d);
    if (result.success) {
        populatePatientForm(result.data);
        if (result.data.Discharge == "true") {
            $('#btnSave').hide();
            $('.mybutton2-wrapper').hide();
        }
        // For InPatientDischarge, load patient info after form data
        if (globalFormType === 'InPatientDischarge') {
            var inPatID = $('#<%= hdfInPatientID.ClientID %>').val();
            if (inPatID) {
                loadInPatientFormData(inPatID);
            }
        }
    }
}
```

Then remove the separate `loadInPatientFormData(inPatientID)` call from the update block (line 248).

### Fix 5: Add MR No to WebMethod and display
**File:** `NewOutPatient.aspx.cs` (line 1016-1028)

Add `rp.Patient_No` to the query:
```csharp
select new
{
    rp.Full_Name,
    rp.Age_years,
    rp.Mobile1,
    rp.Permanent_Address,
    rp.pat_id,
    rp.Gender,
    rp.Patient_No
}
```

Add `MR_No` to the response:
```csharp
PatientName = qry.Full_Name ?? "",
Age = qry.Age_years ?? "",
Contact = qry.Mobile1 ?? "",
Address = qry.Permanent_Address ?? "",
PatientId = qry.pat_id.ToString(),
RegId = qry.pat_id.ToString(),
Gender = qry.Gender ?? "",
MR_No = qry.Patient_No?.ToString() ?? ""
```

**File:** `NewOutPatient.aspx` (line 1022)

Add MR No display in `loadInPatientFormData` success handler:
```javascript
$('#<%= Label200.ClientID %>').text(data.MR_No);
```

## Files to Modify

1. **NewOutPatient.aspx** — 5 changes:
   - Line 269-270: Change "(New)" to `inPatientID`
   - Line 633-648: Call `loadInPatientFormData` in success handler
   - Line 248: Remove standalone `loadInPatientFormData` call
   - Line 1044: Add `$('#dvtblResultrpt').hide()`
   - Line 1022: Add MR No display

2. **NewOutPatient.aspx.cs** — 3 changes:
   - Line 975: Add `PatientType = "InPatient Discharge"` for InPatientDischarge
   - Line 1016-1028: Add `rp.Patient_No` to query
   - Line 1044-1046: Add `MR_No` to response
