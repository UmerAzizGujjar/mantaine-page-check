CREATE OR ALTER PROCEDURE dbo.spGL_AllVoucherList
    @Start int = 0,
    @Length int = 10,
    @SortColumn varchar(50) = '',
    @SortDir varchar(4) = 'desc',
    @Search nvarchar(200) = '',
    @VoucherType varchar(50) = '',
    @VoucherName varchar(200) = '',
    @UnbalancedOnly bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @s nvarchar(202) = N'%' + ISNULL(@Search, N'') + N'%';
    DECLARE @hasSearch bit = CASE WHEN LEN(ISNULL(@Search, N'')) > 0 THEN 1 ELSE 0 END;

    -- one pass over the lines: a narration, all narrations (for search), totals
    SELECT ac.Voucher_ID,
           MIN(ac.Narration) AS Narration,
           MAX(CASE WHEN @hasSearch = 1 AND ac.Narration LIKE @s THEN 1 ELSE 0 END) AS NarrationHit,
           SUM(ISNULL(ac.DR, 0)) AS TotalDR,
           SUM(ISNULL(ac.CR, 0)) AS TotalCR
    INTO #agg
    FROM dbo.GL_Voucher_Accounts ac
    WHERE ac.Voucher_ID IS NOT NULL
    GROUP BY ac.Voucher_ID;

    CREATE CLUSTERED INDEX ix_agg ON #agg(Voucher_ID);

    SELECT v.Voucher_ID, v.Voucher_No, v.Voucher_Type, t.Voucher_Name,
           a.Narration, ISNULL(a.TotalDR, 0) AS TotalDR, ISNULL(a.TotalCR, 0) AS TotalCR
    INTO #f
    FROM dbo.GL_Vouchers v
    LEFT JOIN dbo.GL_Voucher_Types t ON t.Voucher_Type = v.Voucher_Type
    LEFT JOIN #agg a ON a.Voucher_ID = v.Voucher_ID
    WHERE (@VoucherType = '' OR v.Voucher_Type = @VoucherType)
      AND (@VoucherName = '' OR t.Voucher_Name = @VoucherName)
      AND (@UnbalancedOnly = 0 OR ISNULL(a.TotalDR, 0) <> ISNULL(a.TotalCR, 0))
      AND (@hasSearch = 0
           OR CONVERT(varchar(20), v.Voucher_No) LIKE @s
           OR v.Voucher_Type LIKE @s
           OR t.Voucher_Name LIKE @s
           OR v.Remarks LIKE @s
           OR v.Voucher_Status LIKE @s
           OR v.Pay_To_Name LIKE @s
           OR v.Ref_Num LIKE @s
           OR v.Doc_No LIKE @s
           OR CONVERT(varchar(11), v.Voucher_Date, 106) LIKE @s
           OR CONVERT(varchar(10), v.Voucher_Date, 103) LIKE @s
           OR CONVERT(varchar(10), v.Voucher_Date, 120) LIKE @s
           OR a.NarrationHit = 1
           OR CONVERT(varchar(40), a.TotalDR) LIKE @s
           OR CONVERT(varchar(40), a.TotalCR) LIKE @s);

    DECLARE @total int = (SELECT COUNT(*) FROM dbo.GL_Vouchers);
    DECLARE @filtered int = (SELECT COUNT(*) FROM #f);

    SELECT Voucher_ID, Voucher_No, Voucher_Type, Voucher_Name, Narration, TotalDR, TotalCR,
           @total AS RecordsTotal, @filtered AS RecordsFiltered
    FROM #f
    ORDER BY
        CASE WHEN @SortColumn = 'Voucher_No'   AND @SortDir = 'asc'  THEN Voucher_No END ASC,
        CASE WHEN @SortColumn = 'Voucher_No'   AND @SortDir <> 'asc' THEN Voucher_No END DESC,
        CASE WHEN @SortColumn = 'Voucher_Type' AND @SortDir = 'asc'  THEN Voucher_Type END ASC,
        CASE WHEN @SortColumn = 'Voucher_Type' AND @SortDir <> 'asc' THEN Voucher_Type END DESC,
        CASE WHEN @SortColumn = 'Voucher_Name' AND @SortDir = 'asc'  THEN Voucher_Name END ASC,
        CASE WHEN @SortColumn = 'Voucher_Name' AND @SortDir <> 'asc' THEN Voucher_Name END DESC,
        CASE WHEN @SortColumn = 'Narration'    AND @SortDir = 'asc'  THEN Narration END ASC,
        CASE WHEN @SortColumn = 'Narration'    AND @SortDir <> 'asc' THEN Narration END DESC,
        CASE WHEN @SortColumn = 'TotalDR'      AND @SortDir = 'asc'  THEN TotalDR END ASC,
        CASE WHEN @SortColumn = 'TotalDR'      AND @SortDir <> 'asc' THEN TotalDR END DESC,
        CASE WHEN @SortColumn = 'TotalCR'      AND @SortDir = 'asc'  THEN TotalCR END ASC,
        CASE WHEN @SortColumn = 'TotalCR'      AND @SortDir <> 'asc' THEN TotalCR END DESC,
        Voucher_ID DESC
    OFFSET @Start ROWS FETCH NEXT @Length ROWS ONLY;
END




