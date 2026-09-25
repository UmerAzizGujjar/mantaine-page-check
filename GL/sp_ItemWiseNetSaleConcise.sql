-- =====================================================================
-- Item Wise Net Sale Report (Concised)
-- Adds SP + menu + role mapping for
--   ~/Modules/Accounts/StockLedgerReport.aspx?rptTitle=IWNSRC
-- Report: Reports/Inventory/rptItemWiseNetSaleConcise.rpt
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) Stored Procedure
--    Data source:
--      total_qty      = SUM(Ar_Billing_Details.qty) for pharmacy bills
--                       (Ar_Billings.IsPharmacy = 1) within @FromDate..@ToDate
--      ClosingBalance = SUM(vwBatch_Ledger.Qty) warehouse '008' (pharmacy)
--      Manufacture_Name decoded from INV_Items.Manufacturer_Name
--    Parameter signature matches Reports/Inventory/rptOverallStockConsumptionDetail.rpt
--    (@FromDate/@ToDate/@Stock/@Warehouse), used as the template for
--    rptItemWiseNetSaleConcise.rpt.
-- ---------------------------------------------------------------------
IF OBJECT_ID('dbo.sp_ItemWiseNetSaleConcise', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_ItemWiseNetSaleConcise;
GO
CREATE PROCEDURE [dbo].[sp_ItemWiseNetSaleConcise]
    @FromDate  VARCHAR(50),
    @ToDate    VARCHAR(50),
    @Stock     VARCHAR(50),
    @Warehouse VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @startDate DATETIME = CONVERT(DATETIME, @FromDate);
    DECLARE @endDate   DATETIME = CONVERT(DATETIME, @ToDate);

    ;WITH SaleData AS
    (
        SELECT abd.Item_ID, SUM(abd.qty) AS total_qty
        FROM Ar_Billings ab
        JOIN Ar_Billing_Details abd ON ab.Bill_ID = abd.Bill_ID
        WHERE ab.IsPharmacy = 1
          AND ab.Creation_Date BETWEEN @startDate AND @endDate
        GROUP BY abd.Item_ID
    ),
    StockData AS
    (
        SELECT Item_ID, SUM(Qty) AS ClosingBalance
        FROM vwBatch_Ledger
        WHERE Ware_House = '008'
        GROUP BY Item_ID
    )
    SELECT
        i.Item_Code,
        i.Description                                  AS ItemName,
        dbo.GetDataValueName('Manufacture Company', i.Manufacturer_Name) AS Manufacture_Name,
        ISNULL(sd.total_qty, 0)                        AS total_qty,
        ISNULL(st.ClosingBalance, 0)                   AS ClosingBalance
    FROM INV_Items i
    JOIN SaleData sd ON sd.Item_ID = i.Item_ID
    LEFT JOIN StockData st ON st.Item_ID = i.Item_ID
    WHERE ISNULL(i.isCancel, 0) = 0
      AND ISNULL(i.Is_Active, 0) = 1
      AND (
            @Stock = 'All' OR @Stock IS NULL OR @Stock = ''
            OR (@Stock = '1' AND ISNULL(st.ClosingBalance, 0) > 0)
            OR (@Stock = '0' AND ISNULL(st.ClosingBalance, 0) <= 0)
          )
    ORDER BY i.Item_Code;

    SET NOCOUNT OFF;
END;
GO

-- ---------------------------------------------------------------------
-- 2) Menu entry (parent 12980 = Inventory reports)
-- ---------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM Menus WHERE URL = '~/Modules/Accounts/StockLedgerReport.aspx?rptTitle=IWNSRC')
BEGIN
    INSERT INTO Menus (Menu_Name, Menu_Description, URL, Parent_ID, Order_By, IsActive)
    VALUES ('Item wise Net Sale Report Consiced',
            'Item Wise Net Sale Report Consiced',
            '~/Modules/Accounts/StockLedgerReport.aspx?rptTitle=IWNSRC',
            12980, 5, 1);
END
GO

-- ---------------------------------------------------------------------
-- 3) Role access (same roles as Sale Summary Item Wise = 1929596)
-- ---------------------------------------------------------------------
DECLARE @MenuId INT = (SELECT Menu_ID FROM Menus WHERE URL = '~/Modules/Accounts/StockLedgerReport.aspx?rptTitle=IWNSRC');

IF @MenuId IS NOT NULL
BEGIN
    INSERT INTO aspnet_RolesInMenus (RoleMenuId, RoleId, Menu_Id, Access)
    SELECT NEWID(), r.RoleId, @MenuId, 1
    FROM aspnet_Roles r
    WHERE r.RoleName IN ('administrator', 'Senior Pharmacist', 'Pur-Inv (General Store)', 'Purchase (Ph)')
      AND NOT EXISTS (SELECT 1 FROM aspnet_RolesInMenus x WHERE x.Menu_Id = @MenuId AND x.RoleId = r.RoleId);
END
GO