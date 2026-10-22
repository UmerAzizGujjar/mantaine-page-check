
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

IF COL_LENGTH('dbo.Emergency', 'isrcvable_Acc') IS NULL
    ALTER TABLE dbo.Emergency ADD isrcvable_Acc BIT NULL CONSTRAINT DF_Emergency_isrcvable_Acc DEFAULT (0);
GO

-- Step 2: Accounts Receivable list: hospital share rows (OPD General / OPD Private), one
-- "Pharmacy Bulk Approval" row and one "Emergency Approval" row.
-- Pharmacy: cash received (Received_Amount) of bills approved through BulkApprovePharmacy.
-- Emergency: cash received (Receipt_Amount) of approved slips (ER / ERJV voucher), cash only.
-- Rows already transferred (isrcvable_Acc = 1) are left out; Pharmacy / Emergency rows are hidden when none remain.
-- @Company_ID is optional; the app passes AppConfig.Company_ID.
ALTER PROCEDURE [dbo].[sp_Load_HospitalShare_Receivable]
    @Company_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT r.Type_Code, r.[Name], r.Balance, r.Row_Count
    FROM (
        SELECT
            t.Patient_Type AS Type_Code,
            CASE t.Patient_Type
                WHEN '01' THEN 'OPD General'
                WHEN '02' THEN 'OPD Private'
                ELSE t.Patient_Type
            END AS [Name],
            CAST(ISNULL(SUM(p.Hospital_Share), 0) AS DECIMAL(18,2)) AS Balance,
            COUNT(p.Patient_ID) AS Row_Count
        FROM (SELECT '01' AS Patient_Type UNION SELECT '02') t
        INNER JOIN Patients p
            ON p.Patient_Type = t.Patient_Type
            AND ISNULL(p.Hospital_Share, 0) > 0
            AND p.Status = 'Approved'
            AND ISNULL(p.isrcvable_Acc, 0) = 0
            AND YEAR(p.Created_Time) > 2025
        GROUP BY t.Patient_Type

        UNION ALL

        SELECT
            'PH',
            'Pharmacy Bulk Approval',
            CAST(ISNULL(SUM(ab.Received_Amount), 0) AS DECIMAL(18,2)),
            COUNT(ab.Bill_ID)
        FROM Ar_Billings ab
        INNER JOIN GL_Vouchers v ON v.Voucher_ID = ab.Voucher_ID
        WHERE v.Voucher_Type = 'Pharma'
          AND v.Remarks LIKE 'Bulk pharmacy approval%'
          AND ISNULL(ab.isrcvable_Acc, 0) = 0
          AND ISNULL(ab.Payment_Mode, '') <> 'Bank'
          AND ISNULL(ab.IsBank, 0) = 0
          AND (@Company_ID IS NULL OR ab.Company_ID = @Company_ID)
        HAVING COUNT(ab.Bill_ID) > 0

        UNION ALL

        SELECT
            'ER',
            'Emergency Approval',
            CAST(ISNULL(SUM(e.Receipt_Amount), 0) AS DECIMAL(18,2)),
            COUNT(e.Emer_id)
        FROM Emergency e
        INNER JOIN GL_Vouchers v ON v.Voucher_ID = e.Voucher_ID
        WHERE v.Voucher_Type IN ('ER', 'ERJV')
          AND ISNULL(v.IsDeleted, 0) = 0
          AND e.Status = 'Approved'
          AND ISNULL(e.isCancel, 0) = 0
          AND ISNULL(e.isrcvable_Acc, 0) = 0
          AND ISNULL(e.Receipt_Amount, 0) > 0
          AND ISNULL(e.bank_cash, '') <> '02'
          AND YEAR(e.Created_Time) > 2025
          AND (@Company_ID IS NULL OR e.Company_ID = @Company_ID)
        HAVING COUNT(e.Emer_id) > 0
    ) r
    ORDER BY r.Type_Code;
END
GO

IF OBJECT_ID('dbo.sp_Load_Emergency_Receivable_Detail', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Load_Emergency_Receivable_Detail;
GO

CREATE PROCEDURE dbo.sp_Load_Emergency_Receivable_Detail
    @Company_ID INT = NULL,
    @startDate  VARCHAR(20) = '',
    @endDate    VARCHAR(20) = ''
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.Emergency_No AS Patient_No,
        e.Created_Time AS Slip_Date,
        ISNULL(rp.Full_Name, '') AS Full_Name,
        ISNULL(hr.Emp_Name, '') AS Doctor_Name,
        ISNULL(dbo.GetDataValueName('Patient Type', e.Patient_Type), ISNULL(e.Patient_Type, '')) AS Type_Name,
        ISNULL(dbo.GetDataValueName('Cost Center', e.Cost_Center), '') AS Dept,
        CAST(ISNULL(e.Receipt_Amount, 0) AS DECIMAL(18,2)) AS Transfer_Amount,
        ISNULL(e.Actual_amount, 0) AS Receipt_Amount,
        e.Emer_id,
        v.Voucher_No AS Approval_Voucher_No
    FROM Emergency e
    INNER JOIN GL_Vouchers v ON v.Voucher_ID = e.Voucher_ID
    LEFT JOIN Reg_patient rp ON rp.pat_id = e.Reg_PatId
    LEFT JOIN HR_Employees hr ON hr.Emp_ID = TRY_CONVERT(int, e.Doctor_ID)
    WHERE v.Voucher_Type IN ('ER', 'ERJV')
      AND ISNULL(v.IsDeleted, 0) = 0
      AND e.Status = 'Approved'
      AND ISNULL(e.isCancel, 0) = 0
      AND ISNULL(e.isrcvable_Acc, 0) = 0
      AND ISNULL(e.Receipt_Amount, 0) > 0
      AND ISNULL(e.bank_cash, '') <> '02'
      AND YEAR(e.Created_Time) > 2025
      AND (@Company_ID IS NULL OR e.Company_ID = @Company_ID)
      AND (@startDate = '' OR CONVERT(date, e.Created_Time) >= CONVERT(date, @startDate))
      AND (@endDate = '' OR CONVERT(date, e.Created_Time) <= CONVERT(date, @endDate))
    ORDER BY e.Created_Time DESC;
END
GO

IF OBJECT_ID('dbo.SpTransfer_Emergency_Receivable', 'P') IS NOT NULL
    DROP PROCEDURE dbo.SpTransfer_Emergency_Receivable;
GO

CREATE PROCEDURE dbo.SpTransfer_Emergency_Receivable
    @startDate   VARCHAR(20) = '',
    @endDate     VARCHAR(20) = '',
    @RecvAccount INT,
    @Company_ID  INT,
    @user_id     UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @voucher_Type VARCHAR(10) = 'ACCRCV';
    DECLARE @voucherNo INT;
    DECLARE @period_ID BIGINT;
    DECLARE @maxVoucherId BIGINT;
    DECLARE @total NUMERIC(18,2) = 0;
    DECLARE @slips INT = 0;
    DECLARE @RecvName VARCHAR(200);

    IF @RecvAccount IS NULL OR @RecvAccount = 0
    BEGIN
        SELECT 'Please select Received Through account.' AS [Message], 0 AS Voucher_ID;
        RETURN;
    END

    SELECT @RecvName = a.Account_Name
    FROM GL_Accounts a
    WHERE a.Account_ID = @RecvAccount AND ISNULL(a.Active, 1) = 1;

    IF @RecvName IS NULL
    BEGIN
        SELECT 'Selected Received Through account is invalid or inactive.' AS [Message], 0 AS Voucher_ID;
        RETURN;
    END

    -- same cash in hand the approval voucher debited (per patient type, Emergency tab)
    SELECT e.Emer_id, e.Receipt_Amount, tempAcc = ISNULL(c.CashInHand, 0)
    INTO #slips
    FROM Emergency e
    INNER JOIN GL_Vouchers v ON v.Voucher_ID = e.Voucher_ID
    LEFT JOIN ClinicalAccountCategory c
        ON c.CategoryName = e.Patient_Type AND c.Fn_Department = '003' AND ISNULL(c.IsCancel, 0) = 0
    WHERE v.Voucher_Type IN ('ER', 'ERJV')
      AND ISNULL(v.IsDeleted, 0) = 0
      AND e.Status = 'Approved'
      AND ISNULL(e.isCancel, 0) = 0
      AND ISNULL(e.isrcvable_Acc, 0) = 0
      AND ISNULL(e.Receipt_Amount, 0) > 0
      AND ISNULL(e.bank_cash, '') <> '02'
      AND YEAR(e.Created_Time) > 2025
      AND e.Company_ID = @Company_ID
      AND (@startDate = '' OR CONVERT(date, e.Created_Time) >= CONVERT(date, @startDate))
      AND (@endDate = '' OR CONVERT(date, e.Created_Time) <= CONVERT(date, @endDate));

    SELECT @slips = COUNT(*), @total = ISNULL(SUM(Receipt_Amount), 0)
    FROM #slips;

    IF ISNULL(@slips, 0) = 0
    BEGIN
        SELECT 'No pending emergency receivable slips to transfer.' AS [Message], 0 AS Voucher_ID;
        RETURN;
    END

    IF ISNULL(@total, 0) <= 0
    BEGIN
        SELECT 'Transfer amount is zero.' AS [Message], 0 AS Voucher_ID;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM #slips WHERE tempAcc = 0)
    BEGIN
        SELECT 'Emergency cash in hand account is not set in Clinical Financial (Emergency tab) for some patient types.' AS [Message], 0 AS Voucher_ID;
        RETURN;
    END

    SELECT @period_ID = Period_ID FROM GL_Periods WHERE GETDATE() BETWEEN Period_start_date AND Period_end_date;

    IF @period_ID IS NULL
    BEGIN
        SELECT 'No active accounting period found for the transaction date.' AS [Message], 0 AS Voucher_ID;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @voucherNo = ISNULL(MAX(Voucher_No), 0) + 1
        FROM GL_Vouchers WITH (UPDLOCK, HOLDLOCK)
        WHERE Voucher_Type = @voucher_Type AND Company_ID = @Company_ID;

        INSERT INTO GL_Vouchers (
            Voucher_No, Voucher_Date, Voucher_Type, Remarks, Voucher_Status,
            Created_By, Creation_Time, Approved_By, Approved_Time, Period_ID, Company_ID
        )
        VALUES (
            @voucherNo, GETDATE(), @voucher_Type, 'Emergency Cash Received - ' + CAST(@slips AS VARCHAR(10)) + ' slip(s)', 'Approved',
            @user_id, GETDATE(), @user_id, GETDATE(), @period_ID, @Company_ID
        );

        SET @maxVoucherId = SCOPE_IDENTITY();

        -- DR received-through account (actual account)
        INSERT INTO GL_Voucher_Accounts (Voucher_ID, Account_ID, Narration, DR, CR)
        VALUES (@maxVoucherId, @RecvAccount, 'Emergency Cash Received through - ' + @RecvName, @total, 0);

        -- CR emergency cash in hand (parking), one line per account
        INSERT INTO GL_Voucher_Accounts (Voucher_ID, Account_ID, Narration, DR, CR)
        SELECT @maxVoucherId, s.tempAcc, 'Emergency Cash Transfer from parking', 0, SUM(s.Receipt_Amount)
        FROM #slips s
        GROUP BY s.tempAcc;

        UPDATE e
        SET e.isrcvable_Acc = 1
        FROM Emergency e
        INNER JOIN #slips s ON s.Emer_id = e.Emer_id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        RETURN;
    END CATCH

    SELECT 'Emergency receivable transferred successfully.' AS [Message],
           @maxVoucherId AS Voucher_ID,
           @voucherNo AS Voucher_No,
           @total AS Transfer_Amount,
           @slips AS Slip_Count,
           'Emergency' AS Type_Name,
           @RecvName AS Received_Through;
END
GO
