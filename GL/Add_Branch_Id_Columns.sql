/* Adds the user-wise Branch column to every form wired with the branch dropdown.
   Guarded with COL_LENGTH so it is safe to re-run.
   Run against the target database once before deploying the branch feature. */

/* ---------- AP forms (Branch_Id) ---------- */
IF COL_LENGTH('dbo.Purchase_Requisition', 'Branch_Id') IS NULL
    ALTER TABLE dbo.Purchase_Requisition ADD Branch_Id INT NULL;
GO

IF COL_LENGTH('dbo.AP_Purchase_Orders', 'Branch_Id') IS NULL
    ALTER TABLE dbo.AP_Purchase_Orders ADD Branch_Id INT NULL;
GO

IF COL_LENGTH('dbo.CS_Vendor_Master', 'Branch_Id') IS NULL
    ALTER TABLE dbo.CS_Vendor_Master ADD Branch_Id INT NULL;
GO

IF COL_LENGTH('dbo.AP_RequestForQuotations', 'Branch_Id') IS NULL
    ALTER TABLE dbo.AP_RequestForQuotations ADD Branch_Id INT NULL;
GO

/* ---------- Inventory forms (Branch_Id) ---------- */
IF COL_LENGTH('dbo.Igp_master', 'Branch_Id') IS NULL
    ALTER TABLE dbo.Igp_master ADD Branch_Id INT NULL;
GO

IF COL_LENGTH('dbo.GRN_Master', 'Branch_Id') IS NULL
    ALTER TABLE dbo.GRN_Master ADD Branch_Id INT NULL;
GO

IF COL_LENGTH('dbo.MaterialIssueRequest', 'Branch_Id') IS NULL
    ALTER TABLE dbo.MaterialIssueRequest ADD Branch_Id INT NULL;
GO

IF COL_LENGTH('dbo.Store_Issue', 'Branch_Id') IS NULL
    ALTER TABLE dbo.Store_Issue ADD Branch_Id INT NULL;
GO

IF COL_LENGTH('dbo.INV_Stock_Adjustment', 'Branch_Id') IS NULL
    ALTER TABLE dbo.INV_Stock_Adjustment ADD Branch_Id INT NULL;
GO

/* ---------- Purchase / Payment Invoice (existing lowercase Branch_id) ---------- */
IF COL_LENGTH('dbo.Purchase_Invoice_Master', 'Branch_id') IS NULL
    ALTER TABLE dbo.Purchase_Invoice_Master ADD Branch_id INT NULL;
GO

IF COL_LENGTH('dbo.Payment_Invoice', 'Branch_id') IS NULL
    ALTER TABLE dbo.Payment_Invoice ADD Branch_id INT NULL;
GO
