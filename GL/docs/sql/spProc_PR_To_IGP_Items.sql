/*
  spProc_PR_To_IGP_Items
  One row per Purchase_Requisition_Detail line with its PO / IGP / GRN progress.
  Used by Modules/Dashboards/PR_To_IGP_Dashboard.aspx (cards, funnel, charts, detail grid).

  Joins (verified against the schema):
    Purchase_Requisition_Detail.PR_ID            -> Purchase_Requisition.PR_Id
    AP_Purchase_Order_Items.PRDetailId           -> Purchase_Requisition_Detail.PR_Detail_ID
    AP_Purchase_Order_Items.PO_ID                -> AP_Purchase_Orders.PO_ID
    Igp_Detail.PO_Item_ID                        -> AP_Purchase_Order_Items.PO_Item_ID  (Igp_Detail.Igp_Id -> Igp_master.Igp_Id)
    GRN_Detail.PO_Item_Id                        -> AP_Purchase_Order_Items.PO_Item_ID  (GRN_Detail.GRNId -> GRN_Master.GRN_ID)

  Rules:
    - IGP (Igp_master) is a separate document from GRN (GRN_Master); GRN follows IGP + inspection.
    - Cancelled PR  = IsDeleted=1 or Status='Cancelled'. PR has no approved-qty column: Approved Qty = Qty once Status='Approved'.
    - Ordered Qty   = AP_Purchase_Order_Items.Qty of APPROVED, non-deleted POs. Draft ('Created') POs are listed but not counted.
    - Received Qty  = Igp_Detail.IGPQty of APPROVED, non-deleted IGPs (goods physically received at the gate).
    - GRN Qty       = GRN_Detail.GRNQty of APPROVED GRNs (stock posted). Informational.
    - Each level is pre-aggregated per PO item / per PR line before joining, so quantities are never multiplied by fan-out.
    - Purchase returns are NOT netted (Purchase_Return_Detail is keyed to GRN lines, not PO lines).
    - Standalone POs (PRDetailId = 0) never appear: the driving table is the PR detail.

  Optional filters: pass NULL / 0 / '' to skip. @UserId restricts to the user's mapped departments/warehouses
  (Department_Wise_User_Detail / WareHouse_Wise_User_Detail) when the user has any mapping.
*/
IF OBJECT_ID('dbo.spProc_PR_To_IGP_Items', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spProc_PR_To_IGP_Items;
GO
CREATE PROCEDURE dbo.spProc_PR_To_IGP_Items
    @FromDate    datetime         = NULL,
    @ToDate      datetime         = NULL,
    @PRNo        int              = NULL,
    @Department  varchar(50)      = NULL,
    @Warehouse   varchar(50)      = NULL,
    @ItemId      bigint           = NULL,
    @VendorId    int              = NULL,
    @PRStatus    varchar(20)      = NULL,   -- Pending | Approved | Cancelled
    @POStatus    varchar(20)      = NULL,   -- None | Draft | Approved
    @IGPStatus   varchar(20)      = NULL,   -- NotReceived | Partial | Complete
    @UserId      uniqueidentifier = NULL,
    @ProcStatus  varchar(30)      = NULL,   -- Pending Approval | Pending PO | Partially Ordered | Pending IGP | Partially Received | Fully Received | Cancelled/Closed
    @PendingOnly bit              = 0       -- 1 = only items still pending PO or IGP
AS
BEGIN
    SET NOCOUNT ON;

    IF @ToDate IS NOT NULL SET @ToDate = DATEADD(DAY, 1, CAST(CAST(@ToDate AS date) AS datetime));
    IF @FromDate IS NOT NULL SET @FromDate = CAST(CAST(@FromDate AS date) AS datetime);

    -- PO lines linked to a PR line (not cancelled / deleted), IGP and GRN pre-aggregated per PO line
    ;WITH igp AS (
        SELECT d.PO_Item_ID,
               SUM(CASE WHEN m.Status = 'Approved' THEN ISNULL(d.IGPQty, 0) ELSE 0 END) AS RcvQty
        FROM Igp_Detail d
        JOIN Igp_master m ON m.Igp_Id = d.Igp_Id
        WHERE ISNULL(m.IsDeleted, 0) = 0 AND ISNULL(m.Status, '') <> 'Cancelled' AND d.PO_Item_ID > 0
        GROUP BY d.PO_Item_ID
    ), grn AS (
        SELECT d.PO_Item_Id,
               SUM(CASE WHEN m.Status = 'Approved' THEN ISNULL(d.GRNQty, 0) ELSE 0 END) AS GrnQty
        FROM GRN_Detail d
        JOIN GRN_Master m ON m.GRN_ID = d.GRNId
        WHERE d.PO_Item_Id > 0
        GROUP BY d.PO_Item_Id
    )
    SELECT i.PRDetailId, i.PO_Item_ID, o.PO_ID, o.PO_No, o.PO_Date, o.Vendor_ID,
           CASE WHEN o.Status = 'Approved' THEN 'Approved' ELSE 'Draft' END AS PoState,
           CASE WHEN o.Status = 'Approved' THEN ISNULL(i.Qty, 0) ELSE 0 END AS OrdQty,
           CASE WHEN o.Status = 'Approved' THEN ISNULL(g.RcvQty, 0) ELSE 0 END AS RcvQty,
           CASE WHEN o.Status = 'Approved' THEN ISNULL(r.GrnQty, 0) ELSE 0 END AS GrnQty
    INTO #poi
    FROM AP_Purchase_Order_Items i
    JOIN AP_Purchase_Orders o ON o.PO_ID = i.PO_ID
    LEFT JOIN igp g ON g.PO_Item_ID = i.PO_Item_ID
    LEFT JOIN grn r ON r.PO_Item_Id = i.PO_Item_ID
    WHERE i.PRDetailId > 0 AND ISNULL(o.IsDeleted, 0) = 0 AND ISNULL(o.Status, '') <> 'Cancelled';

    CREATE CLUSTERED INDEX IX_poi ON #poi (PRDetailId);

    ;WITH pr_po AS (
        SELECT PRDetailId,
               SUM(OrdQty) AS OrdQty, SUM(RcvQty) AS RcvQty, SUM(GrnQty) AS GrnQty,
               COUNT(DISTINCT CASE WHEN PoState = 'Approved' THEN PO_ID END) AS PoCount,
               COUNT(DISTINCT CASE WHEN PoState = 'Draft' THEN PO_ID END)    AS DraftPoCount
        FROM #poi GROUP BY PRDetailId
    ), base AS (
        SELECT pr.PR_Id, d.PR_Detail_ID, pr.PR_Num, pr.PR_Date, pr.Department, pr.Warehouse,
               CASE WHEN ISNULL(pr.IsDeleted, 0) = 1 OR pr.Status = 'Cancelled' THEN 'Cancelled'
                    WHEN pr.Status = 'Approved' THEN 'Approved' ELSE 'Pending' END AS PRState,
               ISNULL(pr.IsClosed, 0) AS PRClosed,
               d.Item_ID, ISNULL(d.Qty, 0) AS ReqQty,
               ISNULL(p.OrdQty, 0) AS OrdQty, ISNULL(p.RcvQty, 0) AS RcvQty, ISNULL(p.GrnQty, 0) AS GrnQty,
               ISNULL(p.PoCount, 0) AS PoCount, ISNULL(p.DraftPoCount, 0) AS DraftPoCount
        FROM Purchase_Requisition_Detail d
        JOIN Purchase_Requisition pr ON pr.PR_Id = d.PR_ID
        LEFT JOIN pr_po p ON p.PRDetailId = d.PR_Detail_ID
        WHERE (@FromDate IS NULL OR pr.PR_Date >= @FromDate)
          AND (@ToDate   IS NULL OR pr.PR_Date <  @ToDate)
          AND (ISNULL(@PRNo, 0) = 0 OR pr.PR_Num = @PRNo)
          AND (ISNULL(@Department, '') = '' OR pr.Department = @Department)
          AND (ISNULL(@Warehouse, '')  = '' OR pr.Warehouse = @Warehouse)
          AND (ISNULL(@ItemId, 0) = 0 OR d.Item_ID = @ItemId)
          AND (ISNULL(@VendorId, 0) = 0 OR EXISTS (SELECT 1 FROM #poi x WHERE x.PRDetailId = d.PR_Detail_ID AND x.Vendor_ID = @VendorId))
          AND (@UserId IS NULL
               OR NOT EXISTS (SELECT 1 FROM Department_Wise_User_Detail u WHERE u.User_Id = @UserId)
               OR EXISTS (SELECT 1 FROM Department_Wise_User_Detail u WHERE u.User_Id = @UserId AND u.Department = pr.Department))
          AND (@UserId IS NULL
               OR NOT EXISTS (SELECT 1 FROM WareHouse_Wise_User_Detail w WHERE w.User_Id = @UserId)
               OR EXISTS (SELECT 1 FROM WareHouse_Wise_User_Detail w WHERE w.User_Id = @UserId AND w.WareHouse = pr.Warehouse))
    ), calc AS (
        SELECT b.*,
               CASE WHEN b.PRState = 'Approved' THEN b.ReqQty ELSE 0 END AS ApprQty,
               CASE WHEN b.PRState = 'Approved' AND b.OrdQty < b.ReqQty THEN b.ReqQty - b.OrdQty ELSE 0 END AS RemOrder,
               CASE WHEN b.OrdQty > b.RcvQty THEN b.OrdQty - b.RcvQty ELSE 0 END AS RemReceive,
               CASE WHEN b.PoCount > 0 THEN 'Approved' WHEN b.DraftPoCount > 0 THEN 'Draft' ELSE 'None' END AS POState,
               CASE WHEN b.OrdQty > 0 AND b.RcvQty >= b.OrdQty THEN 'Complete'
                    WHEN b.RcvQty > 0 THEN 'Partial' ELSE 'NotReceived' END AS IGPState
        FROM base b
    ), fin AS (
        SELECT c.*,
               CASE WHEN c.PRState = 'Cancelled' OR c.PRClosed = 1 THEN 'Cancelled/Closed'
                    WHEN c.PRState = 'Pending'   THEN 'Pending Approval'
                    WHEN c.OrdQty = 0            THEN 'Pending PO'
                    WHEN c.OrdQty < c.ReqQty     THEN 'Partially Ordered'
                    WHEN c.RcvQty = 0            THEN 'Pending IGP'
                    WHEN c.RcvQty < c.OrdQty     THEN 'Partially Received'
                    ELSE 'Fully Received' END AS ProcStatus
        FROM calc c
    )
    SELECT f.PR_Id, f.PR_Detail_ID, f.PR_Num, f.PR_Date, f.Department,
           dp.Datavalue_description AS DepartmentName,
           f.Warehouse, wh.Datavalue_description AS WarehouseName,
           f.PRState AS PRStatus, f.Item_ID, it.Item_Code, it.Description AS Item_Name,
           f.ReqQty, f.ApprQty, f.OrdQty, f.RcvQty, f.GrnQty, f.RemOrder, f.RemReceive,
           f.PoCount, f.DraftPoCount, f.POState AS POStatus, f.IGPState AS IGPStatus, f.ProcStatus,
           -- document lists as 'id:no' pairs for drill-down links
           STUFF((SELECT DISTINCT ',' + CAST(x.PO_ID AS varchar(20)) + ':' + CAST(x.PO_No AS varchar(20)) + ':' + LEFT(x.PoState, 1)
                  FROM #poi x WHERE x.PRDetailId = f.PR_Detail_ID FOR XML PATH('')), 1, 1, '') AS PODocs,
           STUFF((SELECT DISTINCT ',' + CAST(m.Igp_Id AS varchar(20)) + ':' + CAST(m.Igp_num AS varchar(20)) + ':' + CASE WHEN m.Status = 'Approved' THEN 'A' ELSE 'D' END
                  FROM #poi x
                  JOIN Igp_Detail gd ON gd.PO_Item_ID = x.PO_Item_ID
                  JOIN Igp_master m ON m.Igp_Id = gd.Igp_Id AND ISNULL(m.IsDeleted, 0) = 0 AND ISNULL(m.Status, '') <> 'Cancelled'
                  WHERE x.PRDetailId = f.PR_Detail_ID FOR XML PATH('')), 1, 1, '') AS IGPDocs
    INTO #fin
    FROM fin f
    LEFT JOIN INV_Items it ON it.Item_ID = f.Item_ID
    LEFT JOIN datavalues dp ON dp.DataValue_Name = f.Department
         AND dp.valueset_id = (SELECT ValueSet_ID FROM valueset WHERE valueset_name = 'Department')
         AND (dp.System_Value = 0 OR dp.System_Value IS NULL)
    LEFT JOIN datavalues wh ON wh.DataValue_Name = f.Warehouse
         AND wh.valueset_id = (SELECT ValueSet_ID FROM valueset WHERE valueset_name = 'Ware House')
         AND (wh.System_Value = 0 OR wh.System_Value IS NULL)
    WHERE (ISNULL(@PRStatus, '')  = '' OR f.PRState  = @PRStatus)
      AND (ISNULL(@POStatus, '')  = '' OR f.POState  = @POStatus)
      AND (ISNULL(@IGPStatus, '') = '' OR f.IGPState = @IGPStatus)
      AND (ISNULL(@ProcStatus, '') = '' OR f.ProcStatus = @ProcStatus)
      AND (ISNULL(@PendingOnly, 0) = 0 OR f.ProcStatus IN ('Pending PO', 'Partially Ordered', 'Pending IGP', 'Partially Received'))
;

    SELECT * FROM #fin ORDER BY PR_Date DESC, PR_Num DESC, PR_Detail_ID;

    -- Result set 2: PO lines linked to the PR lines above (for PO-level counts without fan-out)
    SELECT p.PRDetailId, p.PO_Item_ID, p.PO_ID, p.PO_No, p.PO_Date, p.Vendor_ID, v.Vendor_Name,
           p.PoState, p.OrdQty, p.RcvQty, p.GrnQty
    FROM #poi p
    JOIN #fin f ON f.PR_Detail_ID = p.PRDetailId
    LEFT JOIN AP_Vendors v ON v.Vendor_ID = p.Vendor_ID;
END
GO


