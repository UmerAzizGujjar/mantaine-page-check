-- Registered Patient Print (OPD card fee slip, report: Patients/rptRegisteredPatientPrint.rpt)
-- Keyed on Reg_patient.pat_id; the reg fee is read from Reg_patient.Card_fee.
-- Returns the same result-set layout as spPatientSlip_OPD so the Crystal report's
-- field mapping is preserved. @OPD_ID keeps the legacy name of the report's parameter
-- field - Crystal's SetTableLocation fails when a stored procedure's parameter is renamed.
CREATE OR ALTER PROCEDURE [dbo].[spRegisteredPatientPrint]
    @OPD_ID int   -- registered patient id (Reg_patient.pat_id)
AS
BEGIN
    SET NOCOUNT ON;

    -- latest open OPD visit of this registered patient (may not exist yet)
    DECLARE @opd int;
    SELECT @opd = MAX(Patient_ID) FROM patients WHERE Reg_PatId = @OPD_ID AND ISNULL(isCancel, 0) = 0;

    SELECT
        dbo.GetCompanyLogo()                                        AS [Company_Logo],
        ISNULL(p.Patient_ID, 0)                                     AS Patient_ID,
        rp.mr_no_sequence,
        rp.Full_Name,
        rp.Father_Name,
        CASE
            WHEN UPPER(rp.Gender) IN ('M', 'MALE') THEN 'Male'
            WHEN UPPER(rp.Gender) IN ('F', 'FEMALE') THEN 'Female'
            WHEN UPPER(rp.Gender) IN ('T', 'TRANSGENDER') THEN 'Transgender'
            ELSE 'New Born Baby'
        END                                                         AS Gender,
        ISNULL(p.Opd_No, 0)                                         AS Opd_No,
        ISNULL(dbo.GetDataValueName('Patient Main Category', p.Patient_Main_Category), '') AS Department,
        (SELECT emp.Emp_Name FROM HR_Employees emp WHERE emp.Emp_ID = p.doctor_id)         AS Consultant,
        ISNULL(p.Created_Time, rp.Created_time)                     AS Created_Time,
        (SELECT AU.UserName FROM aspnet_Users AU WHERE AU.UserId = ISNULL(p.Created_By, rp.Created_by)) AS Operator,
        ISNULL(p.Actual_amount, 0)                                  AS total_amount,
        ISNULL(dbo.GetDataValueName('Mode Of Registration', p.Mode_Of_Registration), '')   AS Reg_Type,
        ISNULL(dbo.GetDataValueName('Patient Type', p.Patient_Type), '')                   AS Patient_Type,
        (CASE WHEN ISNULL(p.filter_clinic, 0) = 0 THEN ''
              ELSE dbo.GetDataValueName('Filter Clinic', p.filter_clinic)
         END)                                                       AS filter,
        CASE
            WHEN ISNULL(p.Patient_Main_Category, 0) = 0
                THEN CASE WHEN ISNULL(p.filter_clinic, 0) = 0 THEN ''
                          ELSE dbo.GetDataValueName('Filter Clinic', p.filter_clinic) END
            ELSE ISNULL(dbo.GetDataValueName('Patient Main Category', p.Patient_Main_Category), 'OPD')
        END                                                         AS [filter clinic],
        ISNULL(dbo.GetDoctorName(p.Doctor_ID), '')                  AS DoctorName,
        ISNULL((p.Doctor_Amount + p.Receipt_Amount), 0)             AS total_receipt_amount,
        CASE
            WHEN rp.DOB IS NULL THEN ''
            ELSE CONVERT(VARCHAR(2), DAY(rp.DOB)) + '-' + CONVERT(VARCHAR(3), DATENAME(MONTH, rp.DOB)) + '-' + CONVERT(VARCHAR(4), YEAR(rp.DOB))
        END                                                         AS Age_years,
        ISNULL(rp.Mobile1, ISNULL(p.Mobile1, ''))                   AS Mobile1,
        ISNULL(rp.NIC, p.NIC)                                       AS NIC,
        ISNULL(rp.Permanent_Address, p.permanent_address)           AS permanent_address,
        ISNULL(rp.Card_fee, 0)                                      AS CARD_RECEIPT_AMOUNT,
        ISNULL(rp.Card_fee, 0)                                      AS REG_FEE,
        ISNULL(CASE WHEN p.tokenNo = 0 THEN p.Doc_Token ELSE p.tokenNo END, 0)             AS tokenno,
        ISNULL((ISNULL(p.discount_amt, 0) / 100) * p.Actual_amount, 0)                     AS discount_amt,
        (SELECT SC.Company_Address FROM sys_Companys SC
          WHERE SC.Company_ID = ISNULL(p.Company_ID, (SELECT TOP 1 Company_ID FROM sys_Companys))) AS Company_Address,
        (SELECT SC.Company_Phone1 FROM sys_Companys SC
          WHERE SC.Company_ID = ISNULL(p.Company_ID, (SELECT TOP 1 Company_ID FROM sys_Companys))) AS Company_Phone,
        (SELECT Company_Name FROM Panel PL WHERE pl.Panel_ID = p.Panel_Companies)          AS Panel_Name
    FROM reg_patient rp
    LEFT JOIN patients p ON p.Patient_ID = @opd
    WHERE rp.pat_id = @OPD_ID;
END