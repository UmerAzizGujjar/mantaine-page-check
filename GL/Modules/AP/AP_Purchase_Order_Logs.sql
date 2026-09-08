/* AP Purchase Order change-log table.
   Mirrors dbo.Ar_Billing_Logs: one row is written BEFORE every PO update in
   SavePurchaseItemDetail, snapshotting the previous Master + Detail state.
   Run against the target database once before deploying this feature. */

IF OBJECT_ID('dbo.AP_Purchase_Order_Logs', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AP_Purchase_Order_Logs
    (
        Log_Id       INT IDENTITY(1, 1) NOT NULL CONSTRAINT PK_AP_Purchase_Order_Logs PRIMARY KEY,
        PO_Id        INT                NULL,
        Master_Log   NVARCHAR(MAX)      NULL,
        Details_Log  NVARCHAR(MAX)      NULL,
        Loged_By     UNIQUEIDENTIFIER   NULL,
        Log_Time     DATETIME           NULL
    );

    CREATE NONCLUSTERED INDEX IX_AP_Purchase_Order_Logs_PO_Id
        ON dbo.AP_Purchase_Order_Logs (PO_Id ASC, Log_Time ASC);
END
GO
