--EXEC [sp_IPD_Advance_Receipts_SubReport]    126292

    CREATE   PROCEDURE [dbo].[sp_IPD_Advance_SubReport]
    @In_Patient_ID BIGINT
AS
BEGIN

    SELECT
            CONVERT(varchar(10), Advance_Date, 101) AS [Date],
        aa.Advance_Amount      AS Amount,
        aa.In_Patient_ID,
        aa.Advance_ID,
        AA.STATUS, 
        AA.APPROVE_DATE
    FROM AR_Advances aa
    WHERE aa.In_Patient_ID = @In_Patient_ID
      AND ISNULL(aa.IsCancelled, 0) = 0

    ORDER BY aa.Advance_Date;

END




