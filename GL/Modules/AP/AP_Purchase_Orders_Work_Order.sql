/* Purchase Order "Work Order" (001 = normal PO -> IGP -> GRN flow, 002 = invoice created directly from PO, no IGP).
   Run against the target database once before deploying this feature.
   NULL / empty Work_Order on existing rows is treated as 001 by the application. */

IF COL_LENGTH('dbo.AP_Purchase_Orders', 'Work_Order') IS NULL
BEGIN
    ALTER TABLE dbo.AP_Purchase_Orders ADD Work_Order VARCHAR(10) NULL;
END
GO

/* Value set that feeds the Work Order dropdown (ValueSets / DataValues). */
IF NOT EXISTS (SELECT 1 FROM dbo.ValueSets WHERE ValueSet_Name = 'Work Order')
BEGIN
    INSERT INTO dbo.ValueSets (ValueSet_Name, ValueSet_Description)
    VALUES ('Work Order', 'Work Order');
END
GO

DECLARE @VsId INT = (SELECT TOP 1 ValueSet_ID FROM dbo.ValueSets WHERE ValueSet_Name = 'Work Order');

IF NOT EXISTS (SELECT 1 FROM dbo.DataValues WHERE ValueSet_ID = @VsId AND DataValue_Name = '001')
    INSERT INTO dbo.DataValues (ValueSet_ID, DataValue_Name, DataValue_Description)
    VALUES (@VsId, '001', '001');

IF NOT EXISTS (SELECT 1 FROM dbo.DataValues WHERE ValueSet_ID = @VsId AND DataValue_Name = '002')
    INSERT INTO dbo.DataValues (ValueSet_ID, DataValue_Name, DataValue_Description)
    VALUES (@VsId, '002', '002');
GO
