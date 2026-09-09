/* IGP change-log table — mirrors dbo.AP_Purchase_Order_Logs / dbo.Ar_Billing_Logs.
   One row written BEFORE every IGP update in SaveIgpDetail, snapshotting previous
   Master + Detail state. Run once against the target database. */

IF OBJECT_ID('dbo.IGP_Logs', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.IGP_Logs
    (
        Log_Id       INT IDENTITY(1, 1) NOT NULL CONSTRAINT PK_IGP_Logs PRIMARY KEY,
        Igp_Id       INT                NULL,
        Master_Log   NVARCHAR(MAX)      NULL,
        Details_Log  NVARCHAR(MAX)      NULL,
        Loged_By     UNIQUEIDENTIFIER   NULL,
        Log_Time     DATETIME           NULL
    );

    CREATE NONCLUSTERED INDEX IX_IGP_Logs_Igp_Id
        ON dbo.IGP_Logs (Igp_Id ASC, Log_Time ASC);
END
GO
