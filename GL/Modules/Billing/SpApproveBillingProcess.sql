/* ============================================================
   SpApproveBillingProcess
   ------------------------------------------------------------
   CHANGE: GL_Voucher_Accounts item lines (Revenue CR + Discount DR)
   now take Cost_Center line-wise from ClinicalAccountCategory
   instead of the Ar_Billings master header Cost_Center.

   Mapping already used for accounts in #FinalData (UniqueAccounts):
     - Test  (Fn_Department_Lookup '002') -> match CategoryName = Test_Main_Department
       (lab / radiology / diagnostic tab rows)
     - Service ('004' / '006' special / '007' procedure) -> Fn_Department row

   Fallback to Ar_Billings header Cost_Center when the matched
   ClinicalAccountCategory row has no CostCenter.

   NOTE: voucher header, panel, advance and cash-in-hand lines still
   use the Ar_Billings header @Cost_Center.
   ============================================================ */

IF OBJECT_ID('dbo.SpApproveBillingProcess', 'P') IS NULL
    EXEC ('CREATE PROCEDURE dbo.SpApproveBillingProcess AS BEGIN SET NOCOUNT ON; END');
GO

CREATE OR ALTER PROCEDURE [dbo].[SpApproveBillingProcess]
    @BillId BIGINT,
    @user_id UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
 
    BEGIN TRY
        BEGIN TRAN;
 
        DECLARE 
            @maxVoucherId BIGINT,
            @oldVoucherId BIGINT,
            @PatientID BIGINT,
            @BillNo VARCHAR(50),
            @MainDepartment VARCHAR(50),
            @BillDate DATETIME,
            @period_ID BIGINT,
            @RefferDoc INT,
            @doc_id INT,
            @Panel_Account INT,
            @TotalAmount DECIMAL(18,2) = 0,
            @Balance_amount DECIMAL(18,2) = 0,
            @Received_Amount DECIMAL(18,2) = 0,
            @Previous_Paid DECIMAL(18,2) = 0,
            @voucher_Type VARCHAR(50) = 'BIJV',
            @remarks NVARCHAR(MAX) = 'Voucher From AR Billing',
            @CompanyID BIGINT = 1,
            @PanelID BIGINT,
            @IsFinalBill INT,
            @IsPanelProcessed BIT = 0,
            @InPatientID BIGINT,
            @Cost_Center VARCHAR(100) ,
            @Bill_Department VARCHAR(100) ,
            @AdvanceAmount DECIMAL(18,2) = 0,
            @AdvanceAccount BIGINT = 0,
            @CashInHandAccount BIGINT = 0,
            @PatientMRNo VARCHAR(50),
            @PatientName VARCHAR(200),
            @Patientcategory VARCHAR(200);

        ----------------------------------------
        -- Fetch Bill Header (including Cash_In_Hand_Account)
        ----------------------------------------
        SELECT 
            @PatientID = Patient_ID,
            @BillNo = Bill_No,
            @BillDate = Bill_Date,
            @oldVoucherId = Voucher_ID,
            @RefferDoc = Referred_By,
            @MainDepartment = Main_Department,
            @TotalAmount = Total_Amount,
            @Balance_amount = Balance_Amount,
            @Received_Amount = Received_Amount,
            @Previous_Paid = Previous_Paid,
            @doc_id = Doctor_ID,
            @PanelID = Panel_ID,
            @IsFinalBill = final_bill_ipd,
            @InPatientID = In_Patient_ID,
            @CashInHandAccount = Cash_In_Hand_Account,
            @Cost_Center = Cost_Center,
            @Bill_Department =Bill_Department,
            @Patientcategory = dbo.GetDataValueName('Patient Type',Patient_Type)
        FROM Ar_Billings 
        WHERE Bill_ID = @BillId
          AND Seq_InvoiceNo IS NULL;
 
        IF @BillNo IS NULL
        BEGIN
            RAISERROR('Bill not found or already processed', 16, 1);
            ROLLBACK;
            RETURN;
        END

        ----------------------------------------
        -- Get Patient MR No and Name
        ----------------------------------------
        SELECT 
            @PatientMRNo = mr_no_sequence,
            @PatientName = ISNULL(Full_Name, '')
        FROM Reg_patient
        WHERE pat_id = @PatientID;

        -- Update remarks to include Patient MR No, Name, and Bill No
        SET @remarks = 'MR No - ' + 
                       ISNULL(@PatientMRNo, '') + ' - ' + 
                       ISNULL(@PatientName, '') + ' - ' + 
                       'Bill No' +' - ' +
                       ISNULL(@BillNo, '') + ' - ' + 
                       Isnull(@Patientcategory,'');
 
        ----------------------------------------
        -- For department '03', only allow if IsFinalBill = 1
        ----------------------------------------
        IF @MainDepartment = '03' AND (@IsFinalBill IS NULL OR @IsFinalBill != 1)
        BEGIN
            RAISERROR('For department IPD, voucher can only be created when IsFinalBill = 1.', 16, 1);
            ROLLBACK;
            RETURN;
        END
 
        ----------------------------------------
        -- Soft Delete Old Voucher
        ----------------------------------------
        IF (@oldVoucherId IS NOT NULL AND @oldVoucherId > 0)
        BEGIN
            UPDATE GL_Vouchers 
            SET IsDeleted = 1 
            WHERE Voucher_ID = @oldVoucherId;
        END
 
        ----------------------------------------
        -- Get Period
        ----------------------------------------
        SELECT @period_ID = Period_ID 
        FROM GL_Periods 
        WHERE @BillDate BETWEEN Period_start_date AND Period_end_date;
 
        IF @period_ID IS NULL
        BEGIN
            RAISERROR('No GL Period Found', 16, 1);
            ROLLBACK;
            RETURN;
        END
 
        ----------------------------------------
        -- Create Voucher
        ----------------------------------------
        INSERT INTO GL_Vouchers (
            Voucher_No, Voucher_Date, Voucher_Type, Remarks,
            Voucher_Status, Created_By, Creation_Time,
            Approved_By, Approved_Time, Period_ID, Company_ID,Cost_Center,Department
        )
        VALUES (
            @BillNo, @BillDate, @voucher_Type, @remarks,
            'Approved', @user_id, GETDATE(),
            @user_id, GETDATE(), @period_ID, @CompanyID,@Cost_Center,@Bill_Department
        );
 
        SET @maxVoucherId = SCOPE_IDENTITY();
 
        ----------------------------------------
        -- Build Aggregated Data (include Test_Main_Department for tests)
        ----------------------------------------
        IF OBJECT_ID('tempdb..#FinalData') IS NOT NULL
            DROP TABLE #FinalData;
 
        ;WITH BillingAgg AS
        (
            SELECT 
                d.Item_Type,
                d.Item_ID,
                d.Test_Main_Department,
                d.Doctor_id,
                SUM(ISNULL(d.Net_Amount,0))      AS NetAmount,
                SUM(ISNULL(d.Discount_Amount,0)) AS DiscAmount,
                SUM(ISNULL(d.Net_Amount,0)) +     SUM(ISNULL(d.Discount_Amount,0)) AS TotalAmount
            FROM Ar_Billing_Details d
            WHERE d.Bill_ID = @BillId
              AND ISNULL(d.Is_Approval, 1) = 1
            GROUP BY d.Item_Type, d.Item_ID, d.Test_Main_Department, d.Doctor_id
        ),
        ItemFlags AS
        (
            SELECT 
                b.*,
                ISNULL(i.Procedure_Required,0) AS Procedure_Required,
                ISNULL(i.IsSpecialService,0)   AS IsSpecialService,
                CASE 
                    WHEN b.Item_Type = 'Service' AND (b.Doctor_id IS NULL OR b.Doctor_id = 0)
                    THEN i.Account_ID
                    ELSE NULL
                END AS ServiceRevenueAccount
            FROM BillingAgg b
            LEFT JOIN INV_Items i
                ON TRY_CAST(b.Item_ID AS BIGINT) = i.Item_ID
        ),
        DeptCodeMap AS
        (
            SELECT *,
                CASE 
                    WHEN Item_Type = 'Service' AND Procedure_Required = 1 THEN '007'
                    WHEN Item_Type = 'Service' AND IsSpecialService = 1 THEN '006'
                    WHEN Item_Type = 'Service' THEN '004'
                    WHEN Item_Type = 'Test' THEN '002'
                    ELSE '002'
                END AS Fn_Department_Lookup
            FROM ItemFlags
        ),
        UniqueAccounts AS
        (
            SELECT 
                Fn_Department,
                CategoryName,
                MIN(CashInHand) AS CashInHand_Acc,
                MIN(Discount)   AS Discount_Acc,
                MIN(Revenue)    AS Revenue_Acc,
                MIN(CostCenter) AS CostCenter_Acc
            FROM ClinicalAccountCategory
            GROUP BY  CategoryName,Fn_Department
        )
SELECT 
    d.*,
    ISNULL(u.CashInHand_Acc,0) AS CashInHand_Acc,
    ISNULL(u.Discount_Acc,0)   AS Discount_Acc,
    ISNULL(u.Revenue_Acc,0)    AS Revenue_Acc,
    ISNULL(u.CostCenter_Acc,'') AS CostCenter_Acc
INTO #FinalData
FROM DeptCodeMap d
LEFT JOIN UniqueAccounts u
    ON u.Fn_Department = d.Fn_Department_Lookup
   AND (
        -- For '002', match Category with Test_Main_Department
        (d.Fn_Department_Lookup = '002' 
            AND u.CategoryName = d.Test_Main_Department)
        OR
        -- For all other departments, ignore Category (original behavior)
        (d.Fn_Department_Lookup <> '002')
   )

 
        ----------------------------------------
        -- VALIDATION: Ensure no missing revenue account
        ----------------------------------------
        IF EXISTS (SELECT 1 FROM #FinalData WHERE Revenue_Acc = 0 AND TotalAmount > 0)
        BEGIN
            DECLARE @MissingItems NVARCHAR(MAX);
            SELECT @MissingItems = STRING_AGG(
                CONCAT(
                    'Item_ID=', ISNULL(CAST(Item_ID AS VARCHAR), 'NULL'),
                    ' (Type=', ISNULL(Item_Type, 'NULL'),
                    ', Fn=', ISNULL(Fn_Department_Lookup, 'NULL'),
                    ', DeptCat=', ISNULL(Test_Main_Department, 'NULL'),
                    ', Doctor=', ISNULL(CAST(Doctor_id AS VARCHAR), 'NULL'),
                    ', Amount=', CAST(TotalAmount AS VARCHAR(20)),
                    ')'
                ),
                ', '
            )
            FROM #FinalData
            WHERE Revenue_Acc = 0 AND TotalAmount > 0;
 
            RAISERROR('Missing revenue account mapping for items: %s.', 16, 1, @MissingItems);
            ROLLBACK;
            RETURN;
        END
 
        ----------------------------------------
        -- Conditional GL Entries
        ----------------------------------------
        -- Panel handling for '01' (panel exists)
        IF (@MainDepartment = '01' AND (@PanelID IS NOT NULL AND @PanelID != 0))
        BEGIN
            SET @Panel_Account = ISNULL((SELECT gl_account FROM panel WHERE Panel_ID = @PanelID), 0);
 
            IF (@Panel_Account IS NOT NULL AND @Panel_Account > 0 AND @Balance_amount > 0)
            BEGIN
                INSERT INTO GL_Voucher_Accounts (Voucher_ID, Account_ID, Narration, DR, CR, Cost_Center)
                VALUES (@maxVoucherId, @Panel_Account, @remarks, @Balance_amount, 0, @Cost_Center);
            END
 
            SET @IsPanelProcessed = 1;
        END
 
        -- Panel handling for '03' (panel exists and IsFinalBill already = 1)
        IF (@MainDepartment = '03' AND (@PanelID IS NOT NULL AND @PanelID != 0))
        BEGIN
            SET @Panel_Account = ISNULL((SELECT gl_account FROM panel WHERE Panel_ID = @PanelID), 0);
 
            IF (@Panel_Account IS NOT NULL AND @Panel_Account > 0 AND @Balance_amount > 0)
            BEGIN
                INSERT INTO GL_Voucher_Accounts (Voucher_ID, Account_ID, Narration, DR, CR, Cost_Center)
                VALUES (@maxVoucherId, @Panel_Account, @remarks, @Balance_amount, 0, @Cost_Center);
            END
 
            SET @IsPanelProcessed = 1;
        END
 
        ----------------------------------------
        -- Common entries: always insert Discount and Revenue
        ----------------------------------------
        IF (@MainDepartment = '03' AND @IsFinalBill = 1)
        BEGIN
            -- Aggregated discount debit (sum of all discounts, grouped per cost center)
            INSERT INTO GL_Voucher_Accounts (Voucher_ID, Account_ID, Narration, DR, CR, Cost_Center)
            SELECT 
                @maxVoucherId, 
                Discount_Acc, 
                @remarks, 
                SUM(DiscAmount), 
                0,
                ISNULL(NULLIF(CostCenter_Acc, ''), @Cost_Center)
            FROM #FinalData 
            WHERE DiscAmount > 0
            GROUP BY Discount_Acc, CostCenter_Acc;
        END
        ELSE
        BEGIN
            -- Per-item discount debit with line-wise cost center from ClinicalAccountCategory
            INSERT INTO GL_Voucher_Accounts (Voucher_ID, Account_ID, Narration, DR, CR, Item_ID, Item_Type, Doctor_ID, Cost_Center)
            SELECT @maxVoucherId, Discount_Acc, @remarks, DiscAmount, 0, Item_ID, Item_Type, Doctor_id,
                   ISNULL(NULLIF(CostCenter_Acc, ''), @Cost_Center)
            FROM #FinalData 
            WHERE DiscAmount > 0;
        END
 
        -- Credit revenue (per item, line-wise cost center from ClinicalAccountCategory)
        INSERT INTO GL_Voucher_Accounts (Voucher_ID, Account_ID, Narration, DR, CR, Item_ID, Item_Type, Doctor_ID, Cost_Center)
        SELECT @maxVoucherId, Revenue_Acc, @remarks, 0, TotalAmount, Item_ID, Item_Type, Doctor_id,
               ISNULL(NULLIF(CostCenter_Acc, ''), @Cost_Center)
        FROM #FinalData 
        WHERE TotalAmount > 0;
 
        ----------------------------------------
        -- CashInHand debit logic (modified)
        ----------------------------------------
        IF @MainDepartment = '03' AND @IsFinalBill = 1 AND (@PanelID IS NULL OR @PanelID = 0)
        BEGIN
            SELECT @AdvanceAmount = ISNULL(SUM(Advance_Amount), 0)
            FROM AR_Advances
            WHERE In_Patient_ID = @InPatientID;

            SET @AdvanceAccount = ISNULL(
                (SELECT TOP 1 Revenue FROM ClinicalAccountCategory WHERE Fn_Department = '013'),
                0
            );

            DECLARE @SumAmount DECIMAL(18,2);
            SET @SumAmount = @AdvanceAmount + @Received_Amount + @Previous_Paid;
    
            INSERT INTO GL_Voucher_Accounts (Voucher_ID, Account_ID, Narration, DR, CR, Cost_Center)
            VALUES (@maxVoucherId, @AdvanceAccount, @remarks, @SumAmount, 0, @Cost_Center);
        END
        ELSE
        BEGIN
            -- Original logic: grouped cash debit if no panel and received > 0
            IF @IsPanelProcessed = 0 AND @Received_Amount > 0
            BEGIN
                INSERT INTO GL_Voucher_Accounts (Voucher_ID, Account_ID, Narration, DR, CR, Cost_Center)
                SELECT @maxVoucherId, CashInHand_Acc, @remarks, SUM(NetAmount), 0, @Cost_Center
                FROM #FinalData WHERE NetAmount > 0 GROUP BY CashInHand_Acc;
            END
        END
 
        ----------------------------------------
        -- *** NEW VALIDATION: Ensure DR = CR ***
        ----------------------------------------
        DECLARE @TotalDR DECIMAL(18,2) = 0,
                @TotalCR DECIMAL(18,2) = 0,
                @Diff    DECIMAL(18,2) = 0;

        SELECT 
            @TotalDR = ISNULL(SUM(DR), 0),
            @TotalCR = ISNULL(SUM(CR), 0)
        FROM GL_Voucher_Accounts
        WHERE Voucher_ID = @maxVoucherId;

        SET @Diff = @TotalDR - @TotalCR;

        IF @Diff <> 0
        BEGIN
            DECLARE @ErrMsg NVARCHAR(4000);
            SET @ErrMsg = CONCAT(
                'Voucher not saved. Debit and Credit are not equal. ',
                'Total DR = ', CAST(@TotalDR AS VARCHAR(30)),
                ', Total CR = ', CAST(@TotalCR AS VARCHAR(30)),
                ', Difference = ', CAST(@Diff AS VARCHAR(30))
            );
            RAISERROR(@ErrMsg, 16, 1);
            ROLLBACK;
            RETURN;
        END
        ----------------------------------------
 
        ----------------------------------------
        -- Cleanup and Update Bill
        ----------------------------------------
        DROP TABLE #FinalData;
 
        UPDATE Ar_Billings
        SET Voucher_ID = @maxVoucherId, Status = 'Approved'
        WHERE Bill_ID = @BillId;

        --IF @MainDepartment = '03' AND @IsFinalBill = 1 
        --BEGIN
        --    EXEC SpApproveBillingRevenue @BillId, @user_id;
        --END

        COMMIT;
 
        SELECT 'SUCCESS' AS Msg, @maxVoucherId AS VoucherID;
 
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        DECLARE @Err NVARCHAR(MAX) = ERROR_MESSAGE();
        RAISERROR(@Err, 16, 1);
    END CATCH
END
GO
