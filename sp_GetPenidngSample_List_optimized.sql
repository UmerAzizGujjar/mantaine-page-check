-- Proposed rewrite of dbo.sp_GetPenidngSample_List (NOT yet applied; needs approval).
-- Same output columns/order/semantics as the original; changes:
--   * per-row correlated subquery on Lab_Tests -> LEFT JOIN
--   * old comma-joins + left join on Sample_Detail -> NOT EXISTS
--   * dbo.GetDataValueName() now runs once per distinct row, not once per bill-detail row
-- Optional (check first it doesn't already exist):
--   CREATE INDEX IX_Sample_Detail_Bill_Detail_ID ON dbo.Sample_Detail (Bill_Detail_ID);
--   CREATE INDEX IX_Ar_Billing_Details_Bill_ID   ON dbo.Ar_Billing_Details (Bill_ID) INCLUDE (Item_ID, Item_Type, Bill_Details_ID);

ALTER PROCEDURE [dbo].[sp_GetPenidngSample_List]
AS
SET NOCOUNT ON;
BEGIN
    SELECT DISTINCT
           t.pat_id AS Patient_ID,
           t.Patient_No,
           t.Full_Name,
           dbo.GetDataValueName('Patient Type', t.Patient_Type) AS Patient_Category,
           t.Bill_No,
           t.Creation_Date
    FROM (
        SELECT DISTINCT
               p.pat_id, p.Patient_No, p.Full_Name, ps.Patient_Type,
               bm.Bill_No, bm.Creation_Date
        FROM dbo.AR_Billings bm
        INNER JOIN dbo.AR_Billing_Details bd ON bd.Bill_ID = bm.Bill_ID
        INNER JOIN dbo.Reg_patient p        ON p.pat_id = bm.Patient_ID
        LEFT  JOIN dbo.patients ps          ON ps.Patient_No = p.Patient_No
        LEFT  JOIN dbo.Lab_Tests lt         ON lt.Test_ID = bd.Item_ID
        WHERE bd.Item_Type LIKE '%Test%'
          AND NOT EXISTS (SELECT 1 FROM dbo.Sample_Detail sd WHERE sd.Bill_Detail_ID = bd.Bill_Details_ID)
          AND (CASE WHEN bd.Item_ID = 0 THEN 1 ELSE lt.Qty END) > 0
    ) t;
END
