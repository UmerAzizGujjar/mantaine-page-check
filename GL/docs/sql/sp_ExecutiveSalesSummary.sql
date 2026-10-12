CREATE OR ALTER PROCEDURE [dbo].[sp_ExecutiveSalesSummary]
    @StartDate DATETIME,
    @EndDate   DATETIME,
    @Warehouse VARCHAR(50) = '0'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @From DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, @StartDate), 0),
            @To   DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, @EndDate) + 1, 0); -- exclusive

    ;WITH Sales AS (
        SELECT
            CAST(b.Invoice_Date AS DATE)                                  AS Sale_Date,
            COUNT(DISTINCT CASE WHEN ISNULL(b.Patient_ID, 0) = 0 OR b.Customer_Type = 'Walk-in'
                                THEN b.Bill_ID END)                       AS Walk_In_Customers,
            COUNT(DISTINCT CASE WHEN ISNULL(b.Patient_ID, 0) <> 0 AND ISNULL(b.Customer_Type, '') <> 'Walk-in'
                                THEN b.Patient_ID END)                    AS MR_Patient_Count,
            SUM(ISNULL(b.Total_Amount, 0))                                AS Gross_Sales,
            SUM(ISNULL(b.Total_Amount, 0) - ISNULL(b.Disc_Adjustment, 0) - ISNULL(b.Received_Amount, 0)) AS Discounts,
            SUM(ISNULL(b.Total_CGS, 0))                                   AS Cost_Of_Sales
        FROM Ar_Billings b
        WHERE ISNULL(b.IsPharmacy, 0) = 1
          AND ISNULL(b.isCancel, 0) = 0
          AND b.Invoice_Date >= @From AND b.Invoice_Date < @To
          AND (@Warehouse = '0' OR b.Ware_House = @Warehouse)
        GROUP BY CAST(b.Invoice_Date AS DATE)
    ),
    Returns AS (
        SELECT
            CAST(r.Created_Date AS DATE)  AS Sale_Date,
            SUM(ISNULL(r.Net_Amount, 0))  AS Sale_Return,
            SUM(ISNULL(d.CGS, 0))         AS Return_CGS
        FROM Pharmacy_SaleReturns r
        OUTER APPLY (SELECT SUM(ISNULL(x.CGS, 0)) AS CGS
                     FROM Pharmacy_SaleReturn_Details x
                     WHERE x.Return_ID = r.Return_ID) d
        WHERE ISNULL(r.IsDeleted, 0) = 0
          AND r.Created_Date >= @From AND r.Created_Date < @To
          AND (@Warehouse = '0' OR r.Ware_House = @Warehouse)
        GROUP BY CAST(r.Created_Date AS DATE)
    ),
    Combined AS (
        SELECT
            COALESCE(s.Sale_Date, r.Sale_Date)       AS Sale_Date,
            ISNULL(s.Walk_In_Customers, 0)           AS Walk_In_Customers,
            ISNULL(s.MR_Patient_Count, 0)            AS MR_Patient_Count,
            ISNULL(s.Gross_Sales, 0)                 AS Gross_Sales,
            ISNULL(s.Discounts, 0)                   AS Discounts,
            ISNULL(s.Gross_Sales, 0) - ISNULL(s.Discounts, 0) AS Total_Sales,
            ISNULL(r.Sale_Return, 0)                 AS Total_Sale_Return,
            ISNULL(s.Cost_Of_Sales, 0) - ISNULL(r.Return_CGS, 0) AS Cost_Of_Sales
        FROM Sales s
        FULL OUTER JOIN Returns r ON r.Sale_Date = s.Sale_Date
    )
    SELECT
        Sale_Date,
        Walk_In_Customers,
        MR_Patient_Count,
        Gross_Sales,
        Discounts,
        Total_Sales,
        Total_Sale_Return,
        Total_Sales - Total_Sale_Return                                   AS Net_Sale,
        Cost_Of_Sales,
        Total_Sales - Total_Sale_Return - Cost_Of_Sales                   AS GP_Amount,
        CASE WHEN Total_Sales - Total_Sale_Return = 0 THEN 0
             ELSE ROUND((Total_Sales - Total_Sale_Return - Cost_Of_Sales) * 100.0
                        / (Total_Sales - Total_Sale_Return), 2) END       AS GP_Percent
    FROM Combined
    ORDER BY Sale_Date;
END
