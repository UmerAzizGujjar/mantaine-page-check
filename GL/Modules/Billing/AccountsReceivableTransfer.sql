/* ============================================================
   Accounts Receivable -> ACCRCV Transfer
   1. New proc: SpTransfer_HospitalShare_Receivable
   2. Altered proc: sp_Load_HospitalShare_Receivable_Detail
   (only Approved + isrcvable_Acc = 0 slips show / transfer)
   ============================================================ */

IF OBJECT_ID('dbo.SpTransfer_HospitalShare_Receivable', 'P') IS NOT NULL
    DROP PROCEDURE dbo.SpTransfer_HospitalShare_Receivable;
GO

CREATE PROCEDURE dbo.SpTransfer_HospitalShare_Receivable
    @Type       VARCHAR(10),
    @startDate  VARCHAR(20) = '',
    @endDate    VARCHAR(20) = '',
    @RecvAccount INT,
    @user_id    UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @voucher_Type VARCHAR(10) = 'ACCRCV';
    DECLARE @voucherNo INT;
    DECLARE @period_ID VARCHAR(10);
    DECLARE @maxVoucherId BIGINT;
    DECLARE @total NUMERIC(18,2) = 0;
    DECLARE @slips INT = 0;
    DECLARE @TypeName VARCHAR(50);
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

    SELECT @TypeName = CASE @Type
                           WHEN '01' THEN 'OPD General'
                           WHEN '02' THEN 'OPD Private'
                           ELSE ISNULL(@Type, '')
                       END;

    SELECT
        p.Patient_ID,
        p.Hospital_Share,
        tempAcc = CASE
                      WHEN p.bank_cash = '02' AND ISNULL(p.bank_account_id, 0) > 0
                          THEN ISNULL(p.bank_account_id, 0)
                      ELSE ISNULL(c.CashInHand, 0)
                  END
    INTO #slips
    FROM Patients p
    LEFT JOIN ClinicalAccountCategory c
        ON c.CategoryName = p.Patient_Type AND c.Fn_Department = '001'
    WHERE p.Patient_Type = @Type
        AND ISNULL(p.Hospital_Share, 0) > 0
        AND p.Status = 'Approved'
        AND ISNULL(p.isrcvable_Acc, 0) = 0
        AND ISNULL(p.Voucher_ID, 0) > 0
        AND YEAR(p.Created_Time) > 2025
        AND (@startDate = '' OR CONVERT(date, p.Created_Time) >= CONVERT(date, @startDate))
        AND (@endDate = '' OR CONVERT(date, p.Created_Time) <= CONVERT(date, @endDate));

    SELECT @total = SUM(Hospital_Share), @slips = COUNT(*)
    FROM #slips;

    IF ISNULL(@slips, 0) = 0
    BEGIN
        SELECT 'No pending receivable slips found to transfer.' AS [Message], 0 AS Voucher_ID;
        RETURN;
    END

    IF ISNULL(@total, 0) <= 0
    BEGIN
        SELECT 'Transfer amount is zero.' AS [Message], 0 AS Voucher_ID;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM #slips WHERE ISNULL(tempAcc, 0) = 0)
    BEGIN
        SELECT 'Some slips have no receivable (source) account mapped.' AS [Message], 0 AS Voucher_ID;
        RETURN;
    END

    SELECT @period_ID = Period_ID FROM GL_Periods WHERE GETDATE() BETWEEN Period_start_date AND Period_end_date;

    IF @period_ID IS NULL
    BEGIN
        SELECT 'No active accounting period found for the transaction date.' AS [Message], 0 AS Voucher_ID;
        RETURN;
    END

    SELECT @voucherNo = ISNULL(MAX(Voucher_No), 0) + 1
    FROM GL_Vouchers
    WHERE Voucher_Type = @voucher_Type;

    INSERT INTO GL_Vouchers (
        Voucher_No, Voucher_Date, Voucher_Type, Remarks, Voucher_Status,
        Created_By, Creation_Time, Approved_By, Approved_Time, Period_ID, Company_ID
    )
    VALUES (
        @voucherNo, GETDATE(), @voucher_Type, 'Hospital Share Received - ' + @TypeName, 'Approved',
        @user_id, GETDATE(), @user_id, GETDATE(), @period_ID, 1
    );

    SET @maxVoucherId = SCOPE_IDENTITY();

    INSERT INTO GL_Voucher_Accounts (Voucher_ID, Account_ID, Narration, DR, CR)
    SELECT @maxVoucherId, @RecvAccount, 'Hospital Share Received through - ' + @RecvName, @total, 0;

    INSERT INTO GL_Voucher_Accounts (Voucher_ID, Account_ID, Narration, DR, CR)
    SELECT @maxVoucherId, s.tempAcc, 'Hospital Share Receivable Transfer - ' + @TypeName, 0, SUM(s.Hospital_Share)
    FROM #slips s
    GROUP BY s.tempAcc;

    UPDATE p
    SET p.isrcvable_Acc = 1
    FROM Patients p
    INNER JOIN #slips s ON s.Patient_ID = p.Patient_ID;

    SELECT 'Hospital share receivable transferred successfully.' AS [Message],
           @maxVoucherId AS Voucher_ID,
           @voucherNo AS Voucher_No,
           @total AS Transfer_Amount,
           @slips AS Slip_Count,
           @TypeName AS Type_Name,
           @RecvName AS Received_Through;
END
GO

/* Detail list: only slips still receivable (Approved, not yet transferred) */
IF OBJECT_ID('dbo.sp_Load_HospitalShare_Receivable_Detail', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Load_HospitalShare_Receivable_Detail;
GO

CREATE PROCEDURE dbo.sp_Load_HospitalShare_Receivable_Detail
    @Type VARCHAR(10),
    @startDate VARCHAR(20) = '',
    @endDate VARCHAR(20) = ''
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.Patient_No,
        p.Created_Time AS Slip_Date,
        ISNULL(rp.Full_Name, '') AS Full_Name,
        ISNULL(hr.Emp_Name, '') AS Doctor_Name,
        CASE p.Patient_Type WHEN '01' THEN 'OPD General' WHEN '02' THEN 'OPD Private' ELSE p.Patient_Type END AS Type_Name,
        dbo.GetDataValueName('Patient Main Category', p.Patient_Main_Category) AS Dept,
        p.Hospital_Share,
        p.Receipt_Amount,
        p.Patient_Type,
        p.Status,
        p.Voucher_ID
    FROM Patients p
    LEFT JOIN Reg_patient rp ON rp.pat_id = p.Reg_PatId
    LEFT JOIN HR_Employees hr ON hr.Emp_ID = TRY_CONVERT(int, p.Doctor_ID)
    WHERE p.Patient_Type = @Type
        AND ISNULL(p.Hospital_Share, 0) > 0
        AND ISNULL(p.Status, '') = 'Approved'
        AND ISNULL(p.isrcvable_Acc, 0) = 0
        AND YEAR(p.Created_Time) > 2025
        AND (@startDate = '' OR CONVERT(date, p.Created_Time) >= CONVERT(date, @startDate))
        AND (@endDate = '' OR CONVERT(date, p.Created_Time) <= CONVERT(date, @endDate))
    ORDER BY p.Created_Time DESC;
END
GO
