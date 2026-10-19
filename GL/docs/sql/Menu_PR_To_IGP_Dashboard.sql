-- Registers the PR -> PO -> IGP dashboard under the same parent as the Inventory & Procurement dashboard.
-- Then grant access per role in aspnet_RolesInMenus (Access = 1) via the existing role/menu admin screen.
IF NOT EXISTS (SELECT 1 FROM Menus WHERE URL = '~/Modules/Dashboards/PR_To_IGP_Dashboard.aspx')
BEGIN
    DECLARE @Parent int = (SELECT TOP 1 Parent_ID FROM Menus WHERE URL = '~/Modules/Dashboards/Inventory_ProcurementDashboard.aspx');
    INSERT INTO Menus (Menu_Name, Menu_Description, URL, Parent_ID, Order_By, IsActive)
    VALUES ('mnuprtoigp', 'PR to IGP Procurement', '~/Modules/Dashboards/PR_To_IGP_Dashboard.aspx', @Parent, 11, 1);
END
GO
