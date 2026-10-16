-- Adds system parameter controlling PB1 / Pharmacy display in Chief_Executive_Dashboard.aspx
-- Code = '01'  -> PB1 shown, Pharmacy shown separately (current behaviour)
-- Code <> '01' -> PB1 hidden, Pharmacy merged into Services Revenue
IF NOT EXISTS (SELECT 1 FROM dbo.Sys_Parms WHERE Name = 'Show Pharmacy in CEO Dashboard')
    INSERT INTO dbo.Sys_Parms (Name, Code, Company_ID)
    VALUES ('Show Pharmacy in CEO Dashboard', '01', 1);
