/* ===== ALTER 4 procs to @Bill_ID-based (H_P_National_Hospital) ===== */
/* Backups: %TEMP%\opencode\proc_backup_before_bill_alter\ */

/* ---------- MAIN ---------- */
ALTER PROCEDURE [dbo].[sp_IPD_Advance_Estimated_Bill_Print_claude]
    @Bill_ID BIGINT
AS
BEGIN
    ;WITH BillAgg AS
    (
        SELECT
            In_Patient_ID,
            SUM(Received_Amount)  AS Received_AmountBAL,
            SUM(Previous_Paid)    AS Pro_Amount,
            SUM(Discount_Amount)  AS BillDiscount_Amount,
            SUM(Over_and_Above)   AS OverAndAbove,
            SUM(Total_Amount)     AS Combined_Total_Amount,
            COUNT(*)              AS Bill_Count,
            STRING_AGG(CAST(Bill_No AS VARCHAR(50)), ', ') AS Bill_No_List,
            Min(Bill_Date)         AS First_Bill_Date,
            Max(CONVERT(varchar(10), Bill_Date, 101)) AS Last_Bill_Date,
            MAX(Panel_ID)          AS Panel_ID
        FROM Ar_Billings
        WHERE Bill_ID = @Bill_ID
        GROUP BY In_Patient_ID
    ),
    ReceivedDetailAgg AS
    (
        SELECT
            ab.In_Patient_ID,
            SUM(abd.Net_Amount) AS Received_Amount
        FROM Ar_Billing_Details abd
        JOIN Ar_Billings ab ON ab.Bill_ID = abd.Bill_ID
        WHERE ab.Bill_ID = @Bill_ID
        GROUP BY ab.In_Patient_ID
    ),
    Details AS
    (
        SELECT
            'Radiology'          AS Trans_type,
            bm.Bill_ID, bm.In_Patient_ID,
            bd.Bill_Details_ID, bd.Discount_Amount AS Bill_Detail_Discount,
            bd.Qty, bd.Amount AS Unit_Rate, (bd.Amount * bd.Qty) AS Line_Amount,
            bd.Net_Amount,
            bd.item_Name, bd.Item_ID, bd.Item_Type,
            bd.Test_Main_Department, bd.Doctor_id,
            'Radiology' AS Item_Category,
            dbo.GetDataValueName('Main Test Departments', bd.Test_Main_Department) AS Item_Sub_Category
        FROM Ar_Billings bm
        JOIN Ar_Billing_Details bd ON bd.Bill_ID = bm.Bill_ID
        LEFT Join inv_items iv on iv.item_id = bd.Item_ID
        WHERE ISNULL(bm.isCancel, 0) = 0
          AND bm.Bill_ID = @Bill_ID
          AND bd.Item_Type = 'Test'

        UNION ALL

        SELECT
            'Hospital Services'  AS Trans_type,
            bm.Bill_ID, bm.In_Patient_ID,
            bd.Bill_Details_ID, bd.Discount_Amount AS Bill_Detail_Discount,
            bd.Qty, bd.Amount AS Unit_Rate, (bd.Amount * bd.Qty) AS Line_Amount,
            bd.Net_Amount,
            bd.item_Name, bd.Item_ID, bd.Item_Type,
            bd.Test_Main_Department, bd.Doctor_id,
            dbo.GetDataValueName('Item Category', iv.Item_Category) AS Item_Category,
            dbo.GetDataValueName('Service Sub Category', iv.Item_Sub_Category) AS Item_Sub_Category
        FROM Ar_Billings bm
        JOIN Ar_Billing_Details bd ON bd.Bill_ID = bm.Bill_ID
        LEFT Join inv_items iv on iv.item_id = bd.Item_ID
        WHERE ISNULL(bm.isCancel, 0) = 0
          AND bm.Bill_ID = @Bill_ID
          AND bd.Item_Type NOT IN ('Test', 'Medicine')
    ),
    Clubbed AS
    (
        SELECT
            d.Trans_type,
            d.In_Patient_ID,
            d.Item_ID,
            d.item_Name,
            d.Item_Type,
            d.Doctor_id,
            d.Item_Category,
            d.Item_Sub_Category,
            MAX(d.Test_Main_Department) AS Test_Main_Department,
            SUM(d.Qty)                  AS No_Of_Times,
            SUM(d.Line_Amount)          AS Total_Amount,
            SUM(d.Net_Amount)           AS Bill_Detail_Net_Amount,
            SUM(d.Bill_Detail_Discount) AS Discount_Amount,
            MAX(d.Unit_Rate)            AS Rate,
            MIN(d.Bill_Details_ID)      AS Sample_Bill_Details_ID
        FROM Details d
        GROUP BY d.Trans_type, d.In_Patient_ID, d.Item_ID, d.item_Name, d.Item_Type, d.Doctor_id, d.Item_Category, d.Item_Sub_Category
    )

    SELECT
        dbo.GetCompanyLogo() AS Company_Logo,
        c.Trans_type,
        c.In_Patient_ID,
        c.Item_ID, c.item_Name,
        CONCAT('', c.item_Name) AS Services,
        c.Item_Type,
        c.No_Of_Times,
        c.Rate,
        c.Total_Amount,
        c.Bill_Detail_Net_Amount,
        c.Discount_Amount,
        c.Item_Category,
        c.Item_Sub_Category,
        dbo.GetDataValueName('Main Test Departments', c.Test_Main_Department) AS Main_Department,
        (SELECT TOP 1 Emp_Name FROM HR_Employees WHERE Emp_ID = c.Doctor_id) AS Performing_Doctor,
        (SELECT TOP 1 lt.Lab_Test_Detail_ID FROM Lab_Test_Detail lt
            WHERE lt.Bill_Details_ID = c.Sample_Bill_Details_ID AND c.Test_Main_Department <> '001') AS Lab_Test_Detail_ID,
        CASE
        WHEN c.Trans_type = 'Radiology' THEN
        (SELECT TOP 1 CAST(lt.Test_ID AS VARCHAR(50))
         FROM Lab_Test_Detail lt
         WHERE lt.Bill_Details_ID = c.Sample_Bill_Details_ID)
        ELSE dbo.GetItemCode(c.Item_ID)
        END AS item_code,

        dbo.GetDataValueName('Item Type', c.Item_Type) AS Group1_ServiceCategory,
        CASE WHEN dbo.GetDataValueName('Item Type', c.Item_Type) = 'Consultation'
             THEN dbo.GetDoctorName(c.Doctor_id)
             ELSE NULL
        END AS Group2_ConsultingDoctor,

        LTRIM(REPLACE(REPLACE(REPLACE(UPPER(rp.Full_Name), 'MR.', ''), 'MRS.', ''), 'MS.', '')) AS Patient_Name,
        rp.Patient_No, rp.mr_no_sequence, rp.Father_Name AS Relation, rp.Mobile1 AS Ph_No,
        rp.Age_years AS Age, rp.filter_clinic, rp.Permanent_Address AS Addresss, rp.pat_id,
        rp.NIC AS CNIC, rp.Created_time AS Reg_Date,
        CASE WHEN rp.Gender = 'M' THEN 'Male' WHEN rp.Gender = 'F' THEN 'Female' END AS Gender,

        CASE
            WHEN ba.Panel_ID IS NULL OR ba.Panel_ID = 0 THEN 'General'
            ELSE pnl.Company_Name
        END AS Patient_Main_Type,

        dbo.GetDataValueName('Patient Type', inp.Patient_Discount_Type) AS IN_Patient_Type,
        dbo.GetDoctorName(inp.Doctor) AS In_patient_Doctor,
        inp.File_No, inp.Discharge, inp.Admission_Date, inp.Prevention_Precaution,
        inp.Discharge_Advice, inp.Discharge_On,
        inp.CompanyName AS inCompanyName, inp.CardHolderName AS inCardHolderName,
        dbo.GetDataValueName('IPD Procedures', inp.IPD_Procedure) AS IPD_Procedure,
        inp.Procedure_Desc as Procedure_description,
        ISNULL(inp.Ward_ID, 0) AS Ward_ID, wd.Ward_Type AS Ward_No,
        inp.Bed_No,
        ISNULL(inp.Room_ID, 0) AS Room_ID, ISNULL(rm.Room_No, 0) AS Room_No,
        dbo.GetDataValueName('Room Type', inp.Room_Type) AS Room_Type,

        ba.Bill_No_List, ba.First_Bill_Date, ba.Last_Bill_Date, ba.Bill_Count,
        ISNULL(ba.Combined_Total_Amount, 0) AS Combined_Total_Amount,
        ISNULL(ba.Received_AmountBAL, 0)    AS Received_AmountBAL,
        ISNULL(rda.Received_Amount, 0)      AS Received_Amount_Detail_Agg,
        ISNULL(ba.Pro_Amount, 0)            AS Pro_Amount,
        ISNULL(ba.BillDiscount_Amount, 0)   AS BillDiscount_Amount,
        ISNULL(ba.OverAndAbove, 0)          AS OverAndAbove

    FROM Clubbed c
        LEFT JOIN In_Patient inp ON inp.In_Patient_ID = c.In_Patient_ID
        JOIN Reg_Patient rp ON rp.pat_id = inp.Patient_ID
        LEFT JOIN Ward_Definition wd ON wd.Ward_ID = inp.Ward_ID
        LEFT JOIN Rooms rm ON rm.Room_ID = inp.Room_ID
        LEFT JOIN BillAgg ba ON ba.In_Patient_ID = c.In_Patient_ID
        LEFT JOIN ReceivedDetailAgg rda ON rda.In_Patient_ID = c.In_Patient_ID
        LEFT JOIN panel pnl ON pnl.Panel_ID = ba.Panel_ID
END
GO

/* ---------- SUB 1: Advances (patient-level via bill) ---------- */
ALTER PROCEDURE [dbo].[sp_IPD_Advance_SubReport]
    @Bill_ID BIGINT
AS
BEGIN
    DECLARE @In_Patient_ID BIGINT = (SELECT In_Patient_ID FROM Ar_Billings WHERE Bill_ID = @Bill_ID);

    SELECT
        CONVERT(varchar(10), Advance_Date, 101) AS [Date],
        aa.Advance_Amount      AS Amount,
        aa.In_Patient_ID,
        aa.Advance_ID,
        aa.STATUS,
        aa.APPROVE_DATE
    FROM AR_Advances aa
    WHERE aa.In_Patient_ID = @In_Patient_ID
      AND ISNULL(aa.IsCancelled, 0) = 0
    ORDER BY aa.Advance_Date
END
GO

/* ---------- SUB 2: Discounts (bill-scoped) ---------- */
ALTER PROCEDURE [dbo].[sp_IPD_Hospital_Discount_SubReport]
    @Bill_ID BIGINT
AS
BEGIN
    SELECT
        bm.Bill_Date                AS [Date],
        bd.item_Name                AS Service_Name,
        bd.Discount_Amount          AS DiscountAmount,
        bd.Discount_Percentage,
        bm.Approved_by,
        dbo.getUserName(bm.Approved_by) AS Approved_By_Name,
        bm.Bill_No,
        bd.Bill_Details_ID
    FROM Ar_Billings bm
    JOIN Ar_Billing_Details bd ON bd.Bill_ID = bm.Bill_ID
    WHERE bm.Bill_ID = @Bill_ID
      AND ISNULL(bm.isCancel, 0) = 0
      AND bd.Discount_Amount > 0
    ORDER BY bm.approve_date, bd.item_Name
END
GO

/* ---------- SUB 3: Summary (bill-scoped lines, patient-level advances) ---------- */
ALTER PROCEDURE [dbo].[sp_IPD_Bill_Summary_SubReport]
    @Bill_ID BIGINT
AS
BEGIN
    DECLARE @In_Patient_ID BIGINT = (SELECT In_Patient_ID FROM Ar_Billings WHERE Bill_ID = @Bill_ID);

    ;WITH LineItems AS
    (
        SELECT
            bd.Bill_Details_ID,
            (bd.Amount * bd.Qty) AS Line_Amount,
            bd.Discount_Amount,
            bd.Doctor_id
        FROM Ar_Billings bm
        JOIN Ar_Billing_Details bd ON bd.Bill_ID = bm.Bill_ID
        WHERE bm.Bill_ID = @Bill_ID
          AND ISNULL(bm.isCancel, 0) = 0
          AND bd.Item_Type <> 'Medicine'
    ),
    AdvanceAgg AS
    (
        SELECT SUM(Advance_Amount) AS Total_Advance
        FROM AR_Advances
        WHERE In_Patient_ID = @In_Patient_ID
          AND ISNULL(IsCancelled, 0) = 0
    )
    SELECT
        ISNULL(SUM(CASE WHEN li.Doctor_id IS NULL OR li.Doctor_id = 0 THEN li.Line_Amount END), 0) AS Hospital_Bill,
        ISNULL(SUM(CASE WHEN li.Doctor_id IS NULL OR li.Doctor_id = 0 THEN li.Discount_Amount END), 0) AS Hospital_Discount,
        ISNULL(SUM(CASE WHEN li.Doctor_id IS NULL OR li.Doctor_id = 0 THEN li.Line_Amount END), 0)
            - ISNULL(SUM(CASE WHEN li.Doctor_id IS NULL OR li.Doctor_id = 0 THEN li.Discount_Amount END), 0) AS Net_Hospital_Bill,
        ISNULL(SUM(CASE WHEN li.Doctor_id IS NOT NULL AND li.Doctor_id <> 0 THEN li.Line_Amount END), 0) AS Consultant_Amount,
        ISNULL(SUM(CASE WHEN li.Doctor_id IS NOT NULL AND li.Doctor_id <> 0 THEN li.Discount_Amount END), 0) AS Consultant_Discount,
        ISNULL(SUM(CASE WHEN li.Doctor_id IS NOT NULL AND li.Doctor_id <> 0 THEN li.Line_Amount END), 0)
            - ISNULL(SUM(CASE WHEN li.Doctor_id IS NOT NULL AND li.Doctor_id <> 0 THEN li.Discount_Amount END), 0) AS Net_Consultant_Amount,
        ISNULL(SUM(li.Line_Amount), 0) AS Total_Bill,
        ISNULL(SUM(li.Discount_Amount), 0) AS Total_Discount,
        ISNULL(SUM(li.Line_Amount), 0) - ISNULL(SUM(li.Discount_Amount), 0) AS Net_Total_Bill,
        ISNULL((SELECT Total_Advance FROM AdvanceAgg), 0) AS Total_Advance
    FROM LineItems li
END
GO

/* ---------- DROP temp procs from probing ---------- */
DROP PROCEDURE IF EXISTS [dbo].[sp_IPD_Final_Bill_Advance_SubReport];
DROP PROCEDURE IF EXISTS [dbo].[sp_IPD_Final_Bill_Discount_SubReport];
DROP PROCEDURE IF EXISTS [dbo].[sp_IPD_Final_Bill_Summary_SubReport];
DROP PROCEDURE IF EXISTS [dbo].[sp_IPD_Final_Bill_AdvSub];
DROP PROCEDURE IF EXISTS [dbo].[sp_IPD_Final_Bill_Discnt_SubReport];
DROP PROCEDURE IF EXISTS [dbo].[sp_IPD_Final_Bill_Summ_Report];
DROP PROCEDURE IF EXISTS [dbo].[sp_IPD_Final_Bill_Print_For_Inpatient_Bill];
GO
