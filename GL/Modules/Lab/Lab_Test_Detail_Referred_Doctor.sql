-- Referring doctor (HR_Employees.Emp_ID) per lab / radiology test, saved from RadiologyTestResult.aspx.
-- Refer_Doctor on the same table holds the PERFORMING doctor, so this is a separate column.
IF COL_LENGTH('dbo.Lab_Test_Detail', 'Referred_Doctor_ID') IS NULL
    ALTER TABLE dbo.Lab_Test_Detail ADD Referred_Doctor_ID int NULL;
GO
