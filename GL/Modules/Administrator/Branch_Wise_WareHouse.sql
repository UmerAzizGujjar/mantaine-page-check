-- Branch Wise Ware House: table + menus (BranchWiseWareHouse.aspx / BranchWiseWareHouseList.aspx)
-- Safe to re-run.

IF OBJECT_ID('dbo.Branch_Wise_WareHouse') IS NULL
CREATE TABLE dbo.Branch_Wise_WareHouse(
    Branch_WareHouse_Id int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Branch_Wise_WareHouse PRIMARY KEY,
    Branch_ID int NOT NULL,                 -- Branch.branch_ID
    WareHouse varchar(100) NOT NULL,        -- DataValues.DataValue_Name (ValueSet 'Ware House')
    Company_ID int NULL,
    Book_ID int NULL,
    Created_By uniqueidentifier NULL,
    Created_Time datetime NULL,
    Updated_By uniqueidentifier NULL,
    Updated_Time datetime NULL,
    CONSTRAINT UQ_Branch_Wise_WareHouse UNIQUE (Branch_ID, WareHouse));
GO

-- Menus under Administration > User Management (Parent_ID 14071), granted to administrator role
SET XACT_ABORT ON;
BEGIN TRAN;
DECLARE @admin uniqueidentifier = (SELECT RoleId FROM aspnet_Roles WHERE RoleName = 'administrator');

IF NOT EXISTS (SELECT 1 FROM Menus WHERE URL = '~/Modules/Administrator/BranchWiseWareHouse.aspx')
BEGIN
    INSERT INTO Menus(Menu_Name, Menu_Description, URL, Parent_ID, Order_By, IsActive)
    VALUES('mnuBranchWiseWareHouse', 'Add Branch Wise Ware House', '~/Modules/Administrator/BranchWiseWareHouse.aspx', 14071, 11, 1);
    INSERT INTO aspnet_RolesInMenus(RoleMenuId, RoleId, Menu_Id, Access) VALUES(NEWID(), @admin, SCOPE_IDENTITY(), 1);
END

IF NOT EXISTS (SELECT 1 FROM Menus WHERE URL = '~/Modules/Administrator/BranchWiseWareHouseList.aspx')
BEGIN
    INSERT INTO Menus(Menu_Name, Menu_Description, URL, Parent_ID, Order_By, IsActive)
    VALUES('mnuBranchWiseWareHouseList', 'Branch Wise Ware House List', '~/Modules/Administrator/BranchWiseWareHouseList.aspx', 14071, 12, 1);
    INSERT INTO aspnet_RolesInMenus(RoleMenuId, RoleId, Menu_Id, Access) VALUES(NEWID(), @admin, SCOPE_IDENTITY(), 1);
END
COMMIT;
GO

-- Inventory/AP warehouse dropdowns: Code '01' = load warehouses by selected branch; '02'/NULL/other = old behaviour
INSERT INTO sys_Parms(Name, Code, Company_ID)
SELECT 'Branch Wise Ware House', '02', c.Company_ID
FROM (SELECT DISTINCT Company_ID FROM sys_Parms WHERE Company_ID IS NOT NULL) c
WHERE NOT EXISTS (SELECT 1 FROM sys_Parms p WHERE p.Name = 'Branch Wise Ware House' AND p.Company_ID = c.Company_ID);
GO
