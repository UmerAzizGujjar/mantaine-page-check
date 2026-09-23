-- =============================================================================
-- spMedicineLabelPrint
-- One row per medicine line of a pharmacy bill, used by the Crystal report
-- Reports\Pharmacy\rptMedicineLabel.rpt (ReportViewer.aspx?ReportName=MedicineLabel)
-- to print one small medicine label per issued medicine.
-- =============================================================================
IF OBJECT_ID('dbo.spMedicineLabelPrint', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spMedicineLabelPrint;
GO

CREATE PROCEDURE [dbo].[spMedicineLabelPrint]
    @BillId int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        AB.Bill_ID,
        ISNULL(AB.Seq_InvoiceNo, '')                                        AS BillNo,
        ISNULL(CONVERT(varchar(10), COALESCE(bd.Issue_Date, AB.Invoice_Date, AB.Creation_Date), 103)
             + ' ' + CONVERT(varchar(8), COALESCE(bd.Issue_Date, AB.Invoice_Date, AB.Creation_Date), 108), '') AS IssueDate,
        ISNULL(P.Full_Name, ISNULL(AB.Customer_Name, ''))                   AS PatientName,
        ISNULL(P.mr_no_sequence, '')                                        AS MRNo,
        ISNULL(bd.Item_Name, '')                                            AS DrugName,
        ISNULL(NULLIF(IT.Generic_Name, ''), ISNULL(IT.Salt, ''))            AS GenericName,
        CONVERT(varchar(20), CAST(CAST(ISNULL(bd.Qty, 0) AS decimal(18,2)) AS float)) AS Qty,
        ISNULL(bd.Batch_No, '')                                             AS BatchNo,
        ISNULL(NULLIF(bd.Expiry_Date, ''), CONVERT(varchar(10), IT.Expiry_Date, 103)) AS ExpiryDate,
        ISNULL(bd.Frequency, '')                                            AS Frequency,
        LTRIM(RTRIM(
            CASE
                WHEN IP.In_Patient_ID IS NULL
                    THEN ISNULL(dbo.GetDataValueName('Ware House', AB.Ware_House), '')
                ELSE ISNULL(WD.Department, '')
                     + CASE WHEN ISNULL(WD.Ward_No, '') <> '' THEN ' - ' + WD.Ward_No ELSE '' END
                     + CASE WHEN ISNULL(R.Room_No, '') <> '' THEN ' - ' + R.Room_No ELSE '' END
                     + CASE WHEN IP.Bed_No IS NOT NULL THEN ' - Bed ' + CONVERT(varchar(10), IP.Bed_No) ELSE '' END
            END))                                                            AS Location,
        ISNULL(AB.Referred_By_value, '')                                    AS PrescribedBy,
        ISNULL(AB.Customer_Type, '')                                        AS CustomerType,
        ISNULL((SELECT TOP 1 PU.UserName FROM Pharmacy_Users PU WHERE PU.UserID = AB.UserID), '') AS UserName,
        ISNULL(dbo.GetDataValueName('Patient Main Category', AB.pharmacy_Department), '') AS Department,
        ISNULL((SELECT TOP 1 SC.Company_Name FROM Sys_Companys SC WHERE SC.Company_ID = 1), '') AS CompanyName
    FROM Ar_Billings AB
    INNER JOIN Ar_Billing_Details bd ON bd.Bill_ID = AB.Bill_ID
    LEFT JOIN Reg_patient P       ON P.pat_id = AB.Patient_ID
    LEFT JOIN In_Patient IP       ON IP.In_Patient_ID = AB.In_Patient_ID
    LEFT JOIN Ward_Definition WD  ON WD.Ward_ID = IP.Ward_ID
    LEFT JOIN Rooms R             ON R.Room_ID = IP.Room_ID
    LEFT JOIN INV_Items IT        ON IT.Item_ID = bd.Item_ID
    WHERE AB.Bill_ID = @BillId
    ORDER BY bd.Bill_Details_ID;
END
GO
