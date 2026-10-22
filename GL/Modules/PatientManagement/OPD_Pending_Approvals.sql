-- OPD Pending Approvals: no Patient Type filtering; all Created OPD patients
-- (Private and every other type) go through the single SpApprove_Pending_OPD_Bulk (OPDJV) voucher.
-- @pat_type is kept (optional, ignored) so existing callers do not break.

ALTER PROCEDURE [dbo].[sp_Load_OPDPendingApprovals]
    @pat_type NVARCHAR(50) = NULL,
    @search NVARCHAR(50) = NULL,
    @cost_center NVARCHAR(50) = NULL,
    @start_date DATETIME = NULL,
    @end_date DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @search      = ISNULL(@search, '');
    SET @cost_center = ISNULL(@cost_center, '0');
    SELECT TOP 1000
        p.Patient_ID,
        p.mr_no_sequence,
        p.Opd_No,
        p.Full_Name,
        dbo.GetDataValueName('Patient Type', p.Patient_Type) AS Pat_type,
        dbo.GetDataValueName('Patient Main Category', p.Patient_Main_Category) AS DeptName,
        dbo.GetDataValueName('Cost Center', p.Cost_Center) AS CostCenter,
        p.Status,
        p.Patient_Type,
        ISNULL(p.Actual_amount, 0) AS Actual_Amount,
        ISNULL(p.Receipt_Amount, 0) AS Receipt_Amount,
        ISNULL(p.Hospital_share, 0) AS Hospital_Share,
        ISNULL(p.doc_share, 0) AS Doctor_Share,
        ISNULL(p.Actual_amount, 0) - ISNULL(p.Receipt_Amount, 0) AS Discount_Amount
    FROM Reg_patient rg
    INNER JOIN Patients p ON rg.pat_id = p.Reg_PatId
    WHERE p.Status = 'Created'
      AND p.Cost_Center = (CASE WHEN @cost_center = '0' THEN p.Cost_Center ELSE @cost_center END)
      AND (@start_date IS NULL OR p.Created_Time >= @start_date)
      AND (@end_date IS NULL OR p.Created_Time <= @end_date)
      AND (@search = ''
           OR p.mr_no_sequence LIKE '%' + @search + '%'
           OR p.Full_Name LIKE '%' + @search + '%'
           OR p.Status LIKE '%' + @search + '%')
    ORDER BY p.Patient_ID DESC;
END
GO

-- SpApprove_Pending_OPD_Bulk: no change needed in the CPTH_Test version (groups by Cost_Center, no Patient_Type
-- branching, one OPDJV voucher). Older copies (e.g. H_P_National_Hospital, Pakred_Live) still contain the
-- General(01)/Private(02) split and must be replaced with the CPTH_Test definition of that proc.
