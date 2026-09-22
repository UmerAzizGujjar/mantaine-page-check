

--   EXEC [sp_IPD_Bill_Summary_SubReport]   126292
CREATE   PROCEDURE [dbo].[sp_IPD_Bill_Summary_SubReport]
    @In_Patient_ID BIGINT
AS
BEGIN

    ;WITH LineItems AS
    (
        SELECT
            bd.Bill_Details_ID,
            (bd.Amount * bd.Qty) AS Line_Amount,
            bd.Discount_Amount,
            bd.Doctor_id
        FROM Ar_Billings bm
        JOIN Ar_Billing_Details bd ON bd.Bill_ID = bm.Bill_ID
        WHERE bm.In_Patient_ID = @In_Patient_ID
          AND ISNULL(bm.isCancel, 0) = 0
          AND bd.Item_Type <> 'Medicine'
    ),
    AdvanceAgg AS
    (
        SELECT SUM(Advance_Amount) AS Total_Advance
        FROM AR_Advances
        WHERE In_Patient_ID = @In_Patient_ID
          AND ISNULL(IsCancelled, 0) = 0
    )

    SELECT
        -- Hospital Bill = only lines WITHOUT a doctor
        ISNULL(SUM(CASE WHEN li.Doctor_id IS NULL OR li.Doctor_id = 0
                         THEN li.Line_Amount END), 0) AS Hospital_Bill,

        ISNULL(SUM(CASE WHEN li.Doctor_id IS NULL OR li.Doctor_id = 0
                         THEN li.Discount_Amount END), 0) AS Hospital_Discount,

        ISNULL(SUM(CASE WHEN li.Doctor_id IS NULL OR li.Doctor_id = 0
                         THEN li.Line_Amount END), 0)
        - ISNULL(SUM(CASE WHEN li.Doctor_id IS NULL OR li.Doctor_id = 0
                          THEN li.Discount_Amount END), 0) AS Net_Hospital_Bill,

        -- Consultant Amount = only lines WITH a doctor
        ISNULL(SUM(CASE WHEN li.Doctor_id IS NOT NULL AND li.Doctor_id <> 0
                         THEN li.Line_Amount END), 0) AS Consultant_Amount,

        ISNULL(SUM(CASE WHEN li.Doctor_id IS NOT NULL AND li.Doctor_id <> 0
                         THEN li.Discount_Amount END), 0) AS Consultant_Discount,

        ISNULL(SUM(CASE WHEN li.Doctor_id IS NOT NULL AND li.Doctor_id <> 0
                         THEN li.Line_Amount END), 0)
        - ISNULL(SUM(CASE WHEN li.Doctor_id IS NOT NULL AND li.Doctor_id <> 0
                          THEN li.Discount_Amount END), 0) AS Net_Consultant_Amount,

        -- Total Bill = Hospital Bill + Consultant Amount (i.e. sum of ALL lines)
        ISNULL(SUM(li.Line_Amount), 0) AS Total_Bill,

        ISNULL(SUM(li.Discount_Amount), 0) AS Total_Discount,

        ISNULL(SUM(li.Line_Amount), 0) - ISNULL(SUM(li.Discount_Amount), 0) AS Net_Total_Bill,

        ISNULL((SELECT Total_Advance FROM AdvanceAgg), 0) AS Total_Advance

    FROM LineItems li;

END
