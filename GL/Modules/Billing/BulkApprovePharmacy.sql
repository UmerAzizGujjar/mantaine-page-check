IF OBJECT_ID('dbo.BulkApprovePharmacy', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[BulkApprovePharmacy];
GO

-- Bulk approval of selected pharmacy bills into ONE GL voucher.
-- The voucher carries the totals of the selected bills (the same totals shown in the page text boxes):
--   DR Cash        = total Received
--   DR Discount    = total Discount (Discount_Amount + Disc_Adjustment)
--   DR Balance     = total Balance
--   CR Sale        = total Amount, to ItemAccount (ClinicalAccountCategory 001/005);
--                    bills with Payment_Mode 'Bank' go to their Bank_Account instead, as in SpApprovePharmacy
--   DR CGS         = total CGS, to ClinicalAccountCategory.CGS (001/005)
--   CR Inventory   = total CGS per item category (Account_Category.CgsAccount)
-- Stock is updated per bill (spCstinvoicepharma), as in SpApprovePharmacy.
-- All bills succeed or none do; a bill that is already approved stops the whole batch.
CREATE PROCEDURE [dbo].[BulkApprovePharmacy]
    @BillIds  VARCHAR(MAX),          -- comma separated Bill_IDs, e.g. '101,102,103'
    @user_id  UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Ids TABLE (Bill_ID BIGINT PRIMARY KEY);
    DECLARE @Income TABLE (Account_ID BIGINT PRIMARY KEY, Amount NUMERIC(18,2));
    DECLARE @CGSCredit TABLE (Account_ID BIGINT PRIMARY KEY, Amount NUMERIC(18,2));

    DECLARE
        @pos                    INT,
        @token                  VARCHAR(50),
        @msg                    NVARCHAR(4000),
        @BillId                 BIGINT,
        @BillNo                 VARCHAR(50),
        @oldVoucherId           BIGINT,
        @warehouse              VARCHAR(100),
        @company_id             INT,
        @creationdate           DATETIME,
        @period_ID              BIGINT,
        @billCount              INT = 0,
        @voucherNo              INT,
        @maxVoucherId           BIGINT,
        @voucher_Type           VARCHAR(50) = 'Pharma',
        @remarks                NVARCHAR(MAX),
        @total_amt              NUMERIC(18,2) = 0,
        @Rcv_total              NUMERIC(18,2) = 0,
        @discount_total         NUMERIC(18,2) = 0,
        @balance_total          NUMERIC(18,2) = 0,
        @CGS_total              NUMERIC(18,2) = 0,
        @cashinhandpharmacy     BIGINT,
        @Discount_Pharmacy      BIGINT,
        @Item_Account_Pharmacy  BIGINT,
        @balance_acct           BIGINT,
        @CGS_Account            BIGINT,
        @unBalanced             INT = 0;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Split the comma separated list (STRING_SPLIT needs compatibility level 130)
        SET @BillIds = ISNULL(@BillIds, '') + ',';
        WHILE CHARINDEX(',', @BillIds) > 0
        BEGIN
            SET @pos   = CHARINDEX(',', @BillIds);
            SET @token = LTRIM(RTRIM(LEFT(@BillIds, @pos - 1)));
            SET @BillIds = SUBSTRING(@BillIds, @pos + 1, LEN(@BillIds));

            IF @token <> ''
               AND NOT EXISTS (SELECT 1 FROM @Ids WHERE Bill_ID = CAST(@token AS BIGINT))
                INSERT INTO @Ids (Bill_ID) VALUES (CAST(@token AS BIGINT));
        END

        IF NOT EXISTS (SELECT 1 FROM @Ids)
            RAISERROR('No bills were selected for approval.', 16, 1);

        -- 2. Accounts from ClinicalAccountCategory (same row as SpApprovePharmacy)
        SET @cashinhandpharmacy    = ISNULL((SELECT CashInHand     FROM ClinicalAccountCategory WHERE CategoryName = '001' AND Fn_Department = '005'), 0);
        SET @Discount_Pharmacy     = ISNULL((SELECT Discount       FROM ClinicalAccountCategory WHERE CategoryName = '001' AND Fn_Department = '005'), 0);
        SET @Item_Account_Pharmacy = ISNULL((SELECT ItemAccount    FROM ClinicalAccountCategory WHERE CategoryName = '001' AND Fn_Department = '005'), 0);
        SET @balance_acct          = ISNULL((SELECT BalanceAccount FROM ClinicalAccountCategory WHERE CategoryName = '001' AND Fn_Department = '005'), 0);
        SET @CGS_Account           = ISNULL((SELECT CGS            FROM ClinicalAccountCategory WHERE CategoryName = '001' AND Fn_Department = '005'), 0);

        IF @cashinhandpharmacy = 0 OR @Discount_Pharmacy = 0 OR @Item_Account_Pharmacy = 0
            RAISERROR('One or more pharmacy GL accounts are not configured in ClinicalAccountCategory (CategoryName=001, Fn_Department=005): CashInHand, Discount, ItemAccount.', 16, 1);

        IF @balance_acct = 0
            RAISERROR('Balance account not configured in ClinicalAccountCategory (CategoryName=001, Fn_Department=005).', 16, 1);

        IF @CGS_Account = 0
            RAISERROR('CGS (costing) account not configured in ClinicalAccountCategory (CategoryName=001, Fn_Department=005).', 16, 1);

        -- 3. Check every bill and update its stock (one bill at a time)
        DECLARE bill_cursor CURSOR LOCAL FAST_FORWARD FOR
            SELECT Bill_ID FROM @Ids ORDER BY Bill_ID;

        OPEN bill_cursor;
        FETCH NEXT FROM bill_cursor INTO @BillId;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @oldVoucherId = NULL;

            SELECT
                @BillNo       = Bill_No,
                @oldVoucherId = Voucher_ID,
                @company_id   = Company_ID,
                @warehouse    = Ware_House,
                @creationdate = Creation_Date
            FROM Ar_Billings
            WHERE Bill_ID = @BillId
              AND Seq_InvoiceNo IS NOT NULL
              AND Received_Amount >= 0;

            IF @@ROWCOUNT = 0
            BEGIN
                SET @msg = 'Bill ' + CAST(@BillId AS VARCHAR(20)) + ' not found or invalid.';
                RAISERROR(@msg, 16, 1);
            END

            IF @oldVoucherId IS NOT NULL
            BEGIN
                SET @msg = 'Bill ' + ISNULL(@BillNo, CAST(@BillId AS VARCHAR(20))) + ' is already approved. Reload the list and try again.';
                RAISERROR(@msg, 16, 1);
            END

            -- stock update, same call as SpApprovePharmacy
            EXEC [dbo].[spCstinvoicepharma]
                @InvoiceId  = @BillId,
                @company_id = @company_id,
                @warehouse  = @warehouse;

            SET @billCount = @billCount + 1;
            FETCH NEXT FROM bill_cursor INTO @BillId;
        END

        CLOSE bill_cursor;
        DEALLOCATE bill_cursor;

        -- 4. Totals of the selected bills (these are the totals shown in the page text boxes)
        SELECT
            @total_amt      = ISNULL(SUM(Total_Amount), 0),
            @Rcv_total      = ISNULL(SUM(Received_Amount), 0),
            @discount_total = ISNULL(SUM(ISNULL(Discount_Amount, 0) + ISNULL(Disc_Adjustment, 0)), 0),
            @balance_total  = ISNULL(SUM(Balance_Amount), 0)
        FROM Ar_Billings
        WHERE Bill_ID IN (SELECT Bill_ID FROM @Ids);

        SELECT @CGS_total = ISNULL(SUM(ISNULL(abd.CGS, 0)), 0)
        FROM Ar_Billing_Details abd
        WHERE abd.Bill_ID IN (SELECT Bill_ID FROM @Ids);

        -- sale credit per account: ItemAccount, or the bank account for bank bills
        INSERT INTO @Income (Account_ID, Amount)
        SELECT x.Account_ID, SUM(x.Amount)
        FROM (
            SELECT
                CASE WHEN ab.Payment_Mode = 'Bank'
                     THEN CAST(ab.Bank_Account AS BIGINT)
                     ELSE @Item_Account_Pharmacy
                END AS Account_ID,
                ab.Total_Amount AS Amount
            FROM Ar_Billings ab
            WHERE ab.Bill_ID IN (SELECT Bill_ID FROM @Ids)
        ) x
        GROUP BY x.Account_ID;

        -- inventory credit per item category (CGS of items)
        INSERT INTO @CGSCredit (Account_ID, Amount)
        SELECT CAST(ac.CgsAccount AS BIGINT), SUM(ISNULL(abd.CGS, 0))
        FROM Ar_Billing_Details abd
        JOIN INV_Items i ON i.Item_ID = abd.Item_ID
        JOIN Account_Category ac ON ac.Account_Category_Id = i.Item_Account_category
        WHERE abd.Bill_ID IN (SELECT Bill_ID FROM @Ids)
        GROUP BY CAST(ac.CgsAccount AS BIGINT);

        -- 5. One voucher for the whole selection
        SET @voucherNo = ISNULL((SELECT MAX(Voucher_No) FROM GL_Vouchers
                                 WHERE Voucher_Type = @voucher_Type AND Company_ID = @company_id), 0) + 1;

        SELECT @period_ID = Period_ID
        FROM GL_Periods
        WHERE GETDATE() BETWEEN Period_start_date AND Period_end_date;

        IF @period_ID IS NULL
            RAISERROR('No active period found for today.', 16, 1);

        SET @remarks = 'Bulk pharmacy approval: ' + CAST(@billCount AS VARCHAR(10)) + ' bill(s)';

        INSERT INTO GL_Vouchers (
            Voucher_No, Voucher_Date, Voucher_Type, Remarks, Voucher_Status,
            Created_By, Creation_Time, Approved_By, Approved_Time, Period_ID, Company_ID
        )
        VALUES (
            @voucherNo, GETDATE(), @voucher_Type, @remarks, 'Approved',
            @user_id, GETDATE(), @user_id, GETDATE(), @period_ID, @company_id
        );

        SET @maxVoucherId = SCOPE_IDENTITY();

        -- DR Cash
        IF @Rcv_total > 0
            INSERT INTO GL_Voucher_Accounts (Voucher_ID, Account_ID, Narration, DR, CR)
            VALUES (@maxVoucherId, @cashinhandpharmacy, 'Pharmacy Cash Received', @Rcv_total, 0);

        -- DR Discount
        IF @discount_total > 0
            INSERT INTO GL_Voucher_Accounts (Voucher_ID, Account_ID, Narration, DR, CR)
            VALUES (@maxVoucherId, @Discount_Pharmacy, 'Pharmacy Discount', @discount_total, 0);

        -- DR Balance (receivable)
        IF @balance_total > 0
            INSERT INTO GL_Voucher_Accounts (Voucher_ID, Account_ID, Narration, DR, CR)
            VALUES (@maxVoucherId, @balance_acct, 'Pharmacy Balance Amount', @balance_total, 0);

        -- CR Sale income
        INSERT INTO GL_Voucher_Accounts (Voucher_ID, Account_ID, Narration, DR, CR)
        SELECT @maxVoucherId, Account_ID, 'Pharmacy Sale Income', 0, Amount
        FROM @Income;

        -- DR CGS (costing account)
        IF @CGS_total > 0
            INSERT INTO GL_Voucher_Accounts (Voucher_ID, Account_ID, Narration, DR, CR)
            VALUES (@maxVoucherId, @CGS_Account, 'CGS Debit', @CGS_total, 0);

        -- CR inventory per item category
        INSERT INTO GL_Voucher_Accounts (Voucher_ID, Account_ID, Narration, DR, CR)
        SELECT @maxVoucherId, Account_ID, 'CGS of pharmacy items', 0, Amount
        FROM @CGSCredit;

        -- 6. The voucher must balance
        SELECT @unBalanced = CASE WHEN SUM(DR) - SUM(CR) = 0 THEN 1 ELSE 0 END
        FROM GL_Voucher_Accounts
        WHERE Voucher_ID = @maxVoucherId;

        IF @unBalanced = 0
            RAISERROR('Bulk voucher is unbalanced. Check the bills totals and the item CGS account mapping.', 16, 1);

        -- 7. Mark every selected bill as approved under this voucher
        UPDATE Ar_Billings
        SET Voucher_ID = @maxVoucherId,
            Status     = 'Approved'
        WHERE Bill_ID IN (SELECT Bill_ID FROM @Ids);

        COMMIT TRANSACTION;

        SELECT @billCount AS ApprovedCount, @voucherNo AS VoucherNo, 'Pharmacy Bills Approved Successfully...' AS [Message];
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO
