

--   EXEC [sp_IPD_Hospital_Discount_SubReport]   126292

CREATE   PROCEDURE [dbo].[sp_IPD_Hospital_Discount_SubReport]
    @In_Patient_ID BIGINT
AS
BEGIN

    SELECT
        bm.Bill_Date                     AS [Date],
        bd.item_Name                        AS Service_Name,
        bd.Discount_Amount                  AS DiscountAmount,
        bd.Discount_Percentage,
        bm.Approved_by,
        dbo.getUserName(bm.Approved_by)      AS Approved_By_Name,
        bm.Bill_No,
        bd.Bill_Details_ID

    FROM Ar_Billings bm
    JOIN Ar_Billing_Details bd ON bd.Bill_ID = bm.Bill_ID
    WHERE bm.In_Patient_ID = @In_Patient_ID
      AND ISNULL(bm.isCancel, 0) = 0
      AND bd.Discount_Amount > 0

    ORDER BY bm.approve_date, bd.item_Name;

END



