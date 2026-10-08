-- Stores the payment mode chosen on Issue Medicine (Cash / Bank / Panel / Credit).
-- Run on every database BEFORE deploying the matching IssueMedicine build.
-- Older rows stay NULL (mode unknown); IsCash / IsBank / IsHospital_Pharmacy are unchanged.
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Ar_Billings') AND name = 'Payment_Mode')
    ALTER TABLE dbo.Ar_Billings ADD Payment_Mode varchar(20) NULL;
