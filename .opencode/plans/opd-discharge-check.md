# OPD Active Patient Discharge Check - Implementation Plan

## Overview
When a user selects a patient, category, and then department in OPD.aspx, the system should check if the patient already has an active (non-discharged) OPD record. If yes, show a warning and prevent department selection.

## Requirements
- **Check timing**: Only for NEW OPD (when `hdn_opdId` is empty)
- **Swal message**: "Patient has active OPD. Please discharge first."
- **Behavior**: Don't select the department, reset dropdown, don't load doctors
- **Control**: Use sys_parms table - if value is "01" then check, if "00" then skip

---

## 1. SQL Query for sys_parms

```sql
INSERT INTO sys_parms (Name, Code, Description, Company_ID) 
VALUES ('OPD Discharge Check', '01', 'Check if patient has active OPD before allowing department selection', 1)
```

**Note**: Adjust Company_ID as needed. Set Code to '00' to disable the check.

---

## 2. WebMethod in OPD.aspx.cs

Add new WebMethod near line 2863 (after CheckPatientAdmissionStatus):

```csharp
[WebMethod]
public static string CheckOutPatientDischarge(int regPatId)
{
    try
    {
        using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
        {
            // Check if feature is enabled in sys_parms
            var sysParm = db.sys_Parms.FirstOrDefault(p => p.Name == "OPD Discharge Check" && p.Code == "01");
            
            if (sysParm == null)
            {
                // Feature disabled
                return new JavaScriptSerializer().Serialize(new { hasActiveOPD = false });
            }

            // Check if patient has active OPD record
            var activeOPD = (from opd in db.Out_Patients
                            where opd.Reg_PatId == regPatId
                                  && opd.Discharge == false
                            select opd).FirstOrDefault();

            return new JavaScriptSerializer().Serialize(new 
            { 
                hasActiveOPD = activeOPD != null 
            });
        }
    }
    catch (Exception ex)
    {
        return new JavaScriptSerializer().Serialize(new 
        { 
            hasActiveOPD = false, 
            error = ex.Message 
        });
    }
}
```

---

## 3. JavaScript Changes

### 3.1 Add check function in OPD.aspx (inline script section, around line 1200)

```javascript
function checkOutPatientDischarge(callback) {
    var regid = $('#hdn_regid').val();
    var opdid = $('#hdn_opdId').val();
    
    // Only check for NEW OPD
    if (opdid !== "" || !regid) {
        callback(false);
        return;
    }
    
    $.ajax({
        type: "POST",
        url: "OPD.aspx/CheckOutPatientDischarge",
        data: JSON.stringify({ regPatId: parseInt(regid) }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (response) {
            var result = JSON.parse(response.d);
            if (result.hasActiveOPD) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Active OPD Found',
                    text: 'Patient has active OPD. Please discharge first.',
                    confirmButtonText: 'OK',
                    confirmButtonColor: '#3085d6',
                    allowOutsideClick: false,
                    allowEscapeKey: false
                });
                
                // Reset department dropdown
                $('#ddlDepartment').val('').trigger('change');
                
                callback(true);
            } else {
                callback(false);
            }
        },
        error: function (xhr, status, error) {
            console.error("Error checking OPD discharge status:", error);
            callback(false);
        }
    });
}
```

### 3.2 Modify OPD.js department handler (lines 124-134)

Change from:
```javascript
if (item.id === '#ddlDepartment') {
    $element.prop('disabled', false);
    const deptHandler = function () {
        loaddoctor();
    };
    if (!isInsideModal) {
        $element.off('select2:select').on('select2:select', deptHandler);
    } else {
        $element.off('change').on('change', deptHandler);
    }
}
```

To:
```javascript
if (item.id === '#ddlDepartment') {
    $element.prop('disabled', false);
    const deptHandler = function () {
        checkOutPatientDischarge(function(hasActiveOPD) {
            if (!hasActiveOPD) {
                loaddoctor();
            }
        });
    };
    if (!isInsideModal) {
        $element.off('select2:select').on('select2:select', deptHandler);
    } else {
        $element.off('change').on('change', deptHandler);
    }
}
```

---

## 4. Testing Checklist

- [ ] Insert sys_parms record with Code='01'
- [ ] Select a patient who has an active OPD (Discharge=false)
- [ ] Select a category
- [ ] Try to select a department
- [ ] Verify Swal appears with correct message
- [ ] Verify department dropdown is reset
- [ ] Verify doctors are NOT loaded
- [ ] Change sys_parms Code to '00'
- [ ] Repeat steps - verify check is skipped
- [ ] Test with patient who has NO active OPD - verify normal flow works
- [ ] Test with existing OPD (hdn_opdId not empty) - verify check is skipped

---

## 5. Files to Modify

1. **OPD.aspx.cs** - Add `CheckOutPatientDischarge` WebMethod
2. **OPD.aspx** - Add `checkOutPatientDischarge` function (inline script)
3. **OPD.js** - Modify department handler to call check before loading doctors
4. **Database** - Insert sys_parms record

---

## 6. Database Query to Verify Setup

```sql
-- Check if parameter exists
SELECT * FROM sys_parms WHERE Name = 'OPD Discharge Check'

-- Check active OPDs for a patient (replace 123 with actual Reg_PatId)
SELECT * FROM Out_Patients 
WHERE Reg_PatId = 123 AND Discharge = 0
ORDER BY Out_Patient_ID DESC
```

---

## 7. Notes

- The check uses `Reg_PatId` (not Patient_ID) to match the pattern in EmergencyCase.aspx.cs line 2234
- `Discharge == false` means the OPD is still active (not discharged)
- The check is synchronous (`async: false`) to block the flow until result is received
- Only applies to NEW OPD creation, not editing existing OPDs
