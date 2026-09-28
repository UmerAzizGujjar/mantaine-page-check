-- =====================================================================
-- Item Wise Net Sales  (H_P_National_Hospital)
-- Report : Reports/Inventory/rptItemWiseNetSale.rpt
-- Loader : ReportViewer.aspx?ReportName=ItemWiseNetSale
--
-- One row per item. Empty / NULL / '0' filters return all data.
-- No cancellation / refund adjustments.
--   Total Qty  = SUM(Ar_Billing_Details.Qty)                       (pharmacy bills)
--   @TP        = SUM(CGS)                                          (total purchase price)
--   @SP        = SUM(Net_Amount)                                   (total sales price)
--   @NP        = SUM(Net_Amount - Net_Amount/100 * bill discount)  (net sales price)
--   Sales      = @NP
--   Sales Tax  = SUM(AP_Purchase_Order_Items.SalTax_Amount) in range
--   Averages   = totals / NULLIF(Total Qty, 0)                     (divide-by-zero safe)
--
-- NOTE: the result columns are aliased to the cached field names of
-- rptItemWiseNetSale.rpt (table alias 'stock_consumption_detail;1'),
-- so the report binds without any schema refresh:
--   Item_Code        -> Item ID             (string)
--   ItemName         -> Item Name           (string)
--   Manufacture_Name -> Manufacturer        (string)
--   uom              -> Supplier Name       (string)
--   Item_Category    -> Warehouse           (string)
--   total_qty        -> Total Qty
--   Purchase_Rate    -> Sales Value @TP
--   Sale_Rate        -> Sale Value @SP
--   Avg_Amount       -> Sales Value @NP
--   TotalPrice       -> Sales Tax
--   TotalAvg         -> Sales
--   Rate             -> Average TP
--   ClosingBalance   -> Average Sale Price
--   Period_Qty       -> Average Net Price
--
-- First four parameters keep the exact signature the report calls
-- (@FromDate/@ToDate/@Stock/@Warehouse); @Stock is unused (compat).
-- =====================================================================
IF OBJECT_ID('dbo.sp_ItemWiseNetSale', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_ItemWiseNetSale;
GO
CREATE PROCEDURE dbo.sp_ItemWiseNetSale
    @FromDate     VARCHAR(50)  = NULL,
    @ToDate       VARCHAR(50)  = NULL,
    @Stock        VARCHAR(50)  = NULL,   -- report compatibility, not used
    @Warehouse    VARCHAR(50)  = NULL,   -- code or description of 'Ware house'
    @Item         VARCHAR(100) = NULL,   -- Item_ID or Item_Code
    @Manufacturer VARCHAR(150) = NULL,   -- code or description of 'Manufacture Company'
    @Supplier     VARCHAR(250) = NULL    -- Vendor_ID or Vendor_Name
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @dtFrom DATETIME = TRY_CONVERT(DATETIME, NULLIF(LTRIM(RTRIM(@FromDate)), ''), 120);
    DECLARE @dtTo   DATETIME = TRY_CONVERT(DATETIME, NULLIF(LTRIM(RTRIM(@ToDate)), ''), 120);
    IF @dtFrom IS NULL SET @dtFrom = '1900-01-01';
    IF @dtTo   IS NULL SET @dtTo   = '2999-12-31 23:59:59';

    -- date-only ToDate covers the whole day
    IF @dtTo = CONVERT(DATETIME, CONVERT(DATE, @dtTo))
        SET @dtTo = DATEADD(SECOND, -1, DATEADD(DAY, 1, CONVERT(DATETIME, CONVERT(DATE, @dtTo))));

    -- empty / '0' filters mean "all"
    SET @Item         = NULLIF(NULLIF(LTRIM(RTRIM(@Item)), ''), '0');
    SET @Supplier     = NULLIF(NULLIF(LTRIM(RTRIM(@Supplier)), ''), '0');
    SET @Manufacturer = NULLIF(NULLIF(LTRIM(RTRIM(@Manufacturer)), ''), '0');
    SET @Warehouse    = NULLIF(NULLIF(LTRIM(RTRIM(@Warehouse)), ''), '0');

    -- Resolve filter values passed as friendly descriptions once (no per-row UDF)
    DECLARE @MfgCode VARCHAR(150) = NULL, @WhCode VARCHAR(50) = NULL;

    IF @Manufacturer IS NOT NULL
        SET @MfgCode = ISNULL((SELECT TOP (1) dv.DataValue_Name
                               FROM DataValues dv
                               INNER JOIN ValueSet vs ON vs.ValueSet_ID = dv.ValueSet_ID
                               WHERE vs.ValueSet_Name = 'Manufacture Company'
                                 AND dv.DataValue_Description = @Manufacturer), @Manufacturer);

    IF @Warehouse IS NOT NULL
        SET @WhCode = ISNULL((SELECT TOP (1) dv.DataValue_Name
                              FROM DataValues dv
                              INNER JOIN ValueSet vs ON vs.ValueSet_ID = dv.ValueSet_ID
                              WHERE vs.ValueSet_Name = 'Ware house'
                                AND dv.DataValue_Description = @Warehouse), @Warehouse);

    ;WITH SaleIH AS   -- sales grouped by item + warehouse, single pass
    (
        SELECT
            abd.Item_ID,
            ar.Ware_House,
            SUM(abd.Qty)                                                       AS Qty,
            SUM(ISNULL(abd.CGS, 0))                                            AS TP,
            SUM(ISNULL(abd.Net_Amount, 0))                                     AS SP,
            SUM(ISNULL(abd.Net_Amount, 0)
                - (ISNULL(abd.Net_Amount, 0) / 100.0) * ISNULL(ar.Discount_Percentage, 0)) AS NP,
            ROW_NUMBER() OVER (PARTITION BY abd.Item_ID
                               ORDER BY SUM(abd.Qty) DESC, ar.Ware_House)      AS wh_rn
        FROM Ar_Billings ar
        INNER JOIN Ar_Billing_Details abd ON abd.Bill_ID = ar.Bill_ID
        WHERE ar.IsPharmacy = 1
          AND ar.Creation_Date >= @dtFrom
          AND ar.Creation_Date <= @dtTo
          AND (@WhCode IS NULL OR ar.Ware_House = @WhCode)
        GROUP BY abd.Item_ID, ar.Ware_House
    ),
    SaleAgg AS
    (
        SELECT Item_ID,
               SUM(Qty) AS Total_Qty,
               SUM(TP)  AS TP,
               SUM(SP)  AS SP,
               SUM(NP)  AS NP
        FROM SaleIH
        GROUP BY Item_ID
    ),
    WhDominant AS      -- warehouse with the highest sold qty per item (report label)
    (
        SELECT Item_ID, Ware_House
        FROM SaleIH
        WHERE wh_rn = 1
    ),
    WarehouseMap AS
    (
        SELECT dv.DataValue_Name AS Code, dv.DataValue_Description AS Name
        FROM DataValues dv
        INNER JOIN ValueSet vs ON vs.ValueSet_ID = dv.ValueSet_ID
        WHERE vs.ValueSet_Name = 'Ware house'
    ),
    MfgMap AS
    (
        SELECT dv.DataValue_Name AS Code, dv.DataValue_Description AS Name
        FROM DataValues dv
        INNER JOIN ValueSet vs ON vs.ValueSet_ID = dv.ValueSet_ID
        WHERE vs.ValueSet_Name = 'Manufacture Company'
    ),
    POInRange AS       -- purchase order lines in range (tax source + supplier attribution)
    (
        SELECT pod.Item_Id, pod.PO_ID, po.Vendor_ID, po.PO_Date,
               ISNULL(pod.SalTax_Amount, 0) AS SalTax
        FROM AP_Purchase_Orders po
        INNER JOIN AP_Purchase_Order_Items pod ON pod.PO_ID = po.PO_ID
        WHERE ISNULL(po.IsDeleted, 0) = 0
          AND po.PO_Date >= @dtFrom
          AND po.PO_Date <= @dtTo
    ),
    POLatestVendor AS  -- latest purchase order vendor per item
    (
        SELECT Item_Id, Vendor_ID
        FROM (
            SELECT Item_Id, Vendor_ID,
                   ROW_NUMBER() OVER (PARTITION BY Item_Id ORDER BY PO_Date DESC, PO_ID DESC) AS rn
            FROM POInRange
        ) x
        WHERE rn = 1
    ),
    POTax AS
    (
        SELECT Item_Id, SUM(SalTax) AS Sales_Tax
        FROM POInRange
        GROUP BY Item_Id
    )
    SELECT
        CAST(i.Item_Code AS VARCHAR(32))                                     AS Item_Code,
        i.Description                                                        AS ItemName,
        ISNULL(mm.Name, '')                                                  AS Manufacture_Name,
        ISNULL(v.Vendor_Name, '')                                            AS uom,
        ISNULL(wm.Name, '')                                                  AS Item_Category,
        s.Total_Qty                                                          AS total_qty,
        s.TP                                                                 AS Purchase_Rate,
        s.SP                                                                 AS Sale_Rate,
        s.NP                                                                 AS Avg_Amount,
        ISNULL(pt.Sales_Tax, 0)                                              AS TotalPrice,
        s.NP                                                                 AS TotalAvg,
        CONVERT(DECIMAL(18, 2), s.TP / NULLIF(s.Total_Qty, 0))               AS Rate,
        CONVERT(DECIMAL(18, 2), s.SP / NULLIF(s.Total_Qty, 0))               AS ClosingBalance,
        CONVERT(DECIMAL(18, 2), s.NP / NULLIF(s.Total_Qty, 0))               AS Period_Qty
    FROM SaleAgg s
    INNER JOIN INV_Items i ON i.Item_ID = s.Item_ID
    LEFT JOIN WhDominant wd ON wd.Item_ID = s.Item_ID
    LEFT JOIN WarehouseMap wm ON wm.Code = wd.Ware_House
    LEFT JOIN MfgMap mm ON mm.Code = i.Manufacturer_Name
    LEFT JOIN POLatestVendor lv ON lv.Item_Id = s.Item_ID
    LEFT JOIN AP_Vendors v ON v.Vendor_ID = lv.Vendor_ID
    LEFT JOIN POTax pt ON pt.Item_Id = s.Item_ID
    WHERE
        (@Item IS NULL
             OR i.Item_Code = @Item OR CAST(i.Item_ID AS VARCHAR(20)) = @Item)
        AND (@MfgCode IS NULL
             OR i.Manufacturer_Name = @MfgCode OR i.Manufacturer_Name = @Manufacturer)
        AND (@Supplier IS NULL
             OR v.Vendor_Name = @Supplier OR CAST(v.Vendor_ID AS VARCHAR(20)) = @Supplier)
    ORDER BY i.Item_ID
    OPTION (RECOMPILE);

    SET NOCOUNT OFF;
END;
GO

-- ---------------------------------------------------------------------
-- Menu entry (parent 12980 = Inventory reports)
-- ---------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM Menus WHERE URL = '~/Modules/Accounts/StockLedgerReport.aspx?rptTitle=IWNSR')
BEGIN
    INSERT INTO Menus (Menu_Name, Menu_Description, URL, Parent_ID, Order_By, IsActive)
    VALUES ('Item Wise Net Sales',
            'Item Wise Net Sales',
            '~/Modules/Accounts/StockLedgerReport.aspx?rptTitle=IWNSR',
            12980, 4, 1);
END
GO

-- ---------------------------------------------------------------------
-- Role access (same roles as Item Wise Net Sale Report Concised)
-- ---------------------------------------------------------------------
DECLARE @MenuId INT = (SELECT Menu_ID FROM Menus WHERE URL = '~/Modules/Accounts/StockLedgerReport.aspx?rptTitle=IWNSR');

IF @MenuId IS NOT NULL
BEGIN
    INSERT INTO aspnet_RolesInMenus (RoleMenuId, RoleId, Menu_Id, Access)
    SELECT NEWID(), r.RoleId, @MenuId, 1
    FROM aspnet_Roles r
    WHERE r.RoleName IN ('administrator', 'Senior Pharmacist', 'Pur-Inv (General Store)', 'Purchase (Ph)')
      AND NOT EXISTS (SELECT 1 FROM aspnet_RolesInMenus x WHERE x.Menu_Id = @MenuId AND x.RoleId = r.RoleId);
END
GO