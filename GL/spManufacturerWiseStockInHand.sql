CREATE OR ALTER PROCEDURE dbo.spManufacturerWiseStockInHand
    @ItemName NVARCHAR(250) = NULL,
    @Manufacturer VARCHAR(250) = NULL,
    @Warehouse VARCHAR(250) = NULL,
    @EndDate DATE = NULL,
    @CompanyID INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    SET @EndDate = COALESCE(@EndDate, CONVERT(date, GETDATE()));

    ;WITH StockData AS
    (
        SELECT v.Item_ID, SUM(v.Qty) AS Stock_Qty, AVG(v.Rate) AS Avg_Rate, SUM(v.Amount) AS Stock_Value
        FROM dbo.vwBatch_Ledger AS v
        WHERE v.Trans_Date < DATEADD(day, 1, @EndDate)
          AND ISNULL(v.isCancel, 0) = 0
          AND ISNULL(v.Is_Active, 0) = 1
          AND (NULLIF(LTRIM(RTRIM(@Warehouse)), '') IS NULL
               OR LTRIM(RTRIM(@Warehouse)) IN ('0', 'All')
               OR v.Ware_House = LTRIM(RTRIM(@Warehouse)))
        GROUP BY v.Item_ID
    ), ReportRows AS
    (
        SELECT
            i.Item_ID,
            i.Item_Code AS Alias_Name,
            i.Description AS Item_Name,
            CAST(ISNULL(s.Avg_Rate, 0) AS decimal(19,4)) AS Unit_Price,
            CAST(ISNULL(s.Stock_Qty, 0) AS decimal(19,4)) AS Stock_Qty,
            ISNULL(dbo.GetDataValueName('Item Category', i.Item_Category), '') AS Item_Category,
            ISNULL(dbo.GetDataValueName('Item Group', i.ItemGroupId), '') AS Item_Class,
            CAST(ISNULL(i.Purchase_Rate, 0) AS decimal(19,4)) AS Purchase_Price,
            CAST(ISNULL(i.Sale_Rate, 0) AS decimal(19,4)) AS Sale_Price,
            CAST(ISNULL(i.UOM_Qty, 1) AS decimal(19,4)) AS Pack_Unit,
            CAST(ISNULL(s.Stock_Value, 0) AS decimal(19,4)) AS Stock_Value,
            COALESCE(NULLIF(LTRIM(RTRIM(dbo.GetDataValueName('Manufacture Company', NULLIF(NULLIF(LTRIM(RTRIM(i.Manufacture_Company)), ''), '0')))), ''),
                     NULLIF(NULLIF(LTRIM(RTRIM(i.Manufacture_Company)), ''), '0'),
                     NULLIF(LTRIM(RTRIM(dbo.GetDataValueName('Manufacture Company', NULLIF(NULLIF(LTRIM(RTRIM(i.Manufacturer_Name)), ''), '0')))), ''),
                     NULLIF(NULLIF(LTRIM(RTRIM(i.Manufacturer_Name)), ''), '0'),
                     'Unassigned') AS Manufacturer_Name
        FROM dbo.INV_Items AS i
        INNER JOIN StockData AS s ON s.Item_ID = i.Item_ID
        WHERE ISNULL(i.IsPharmacyItem, 0) = 1
          AND ISNULL(i.Active, 0) = 1
          AND ISNULL(i.Is_Active, 0) = 1
          AND ISNULL(i.isCancel, 0) = 0
          AND ISNULL(s.Stock_Qty, 0) <> 0
          AND (NULLIF(LTRIM(RTRIM(@ItemName)), '') IS NULL
               OR LTRIM(RTRIM(@ItemName)) IN ('0', 'All')
               OR i.Description LIKE N'%' + LTRIM(RTRIM(@ItemName)) + N'%'
               OR i.Item_Code LIKE '%' + LTRIM(RTRIM(@ItemName)) + '%')
          AND (NULLIF(LTRIM(RTRIM(@Manufacturer)), '') IS NULL
               OR LTRIM(RTRIM(@Manufacturer)) IN ('0', 'All')
               OR LTRIM(RTRIM(@Manufacturer)) = NULLIF(NULLIF(LTRIM(RTRIM(i.Manufacture_Company)), ''), '0')
               OR LTRIM(RTRIM(@Manufacturer)) = NULLIF(NULLIF(LTRIM(RTRIM(i.Manufacturer_Name)), ''), '0')
               OR LTRIM(RTRIM(@Manufacturer)) = NULLIF(LTRIM(RTRIM(dbo.GetDataValueName('Manufacture Company', NULLIF(NULLIF(LTRIM(RTRIM(i.Manufacture_Company)), ''), '0')))), '')
               OR LTRIM(RTRIM(@Manufacturer)) = NULLIF(LTRIM(RTRIM(dbo.GetDataValueName('Manufacture Company', NULLIF(NULLIF(LTRIM(RTRIM(i.Manufacturer_Name)), ''), '0')))), '')
               OR (LTRIM(RTRIM(@Manufacturer)) = 'Unassigned'
                   AND NULLIF(NULLIF(LTRIM(RTRIM(i.Manufacture_Company)), ''), '0') IS NULL
                   AND NULLIF(NULLIF(LTRIM(RTRIM(i.Manufacturer_Name)), ''), '0') IS NULL))
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY Manufacturer_Name, Item_Name, Alias_Name) AS Serial_No,
        Item_ID,
        Alias_Name,
        Item_Name AS Description,
        Unit_Price AS Rate,
        Stock_Qty AS Qty,
        Item_Category,
        Item_Class,
        Purchase_Price AS Purchase_Rate,
        Sale_Price AS Sale_Rate,
        Pack_Unit AS UOM_Qty,
        Stock_Value AS Amount,
        Manufacturer_Name AS wareHouse_Name,
        Manufacturer_Name,
        CONVERT(varchar(10), @EndDate, 103) AS Report_Date,
        (SELECT TOP 1 Company_Address FROM dbo.sys_Companys WHERE Company_ID = @CompanyID) AS Company_Address
    FROM ReportRows
    ORDER BY Manufacturer_Name, Item_Name, Alias_Name;
END;