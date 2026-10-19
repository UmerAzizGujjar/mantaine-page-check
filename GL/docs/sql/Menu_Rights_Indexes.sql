-- Menu_Rights_Indexes.sql
-- Speeds up the sidebar menu and page-access checks that run on every page (Site.Master).
-- aspnet_RolesInMenus has only its primary key; the menu queries join it on RoleId and Menu_Id,
-- which SQL Server reported as the top missing indexes. Safe to run more than once.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.aspnet_RolesInMenus') AND name = 'IX_aspnet_RolesInMenus_RoleId_MenuId')
    CREATE NONCLUSTERED INDEX IX_aspnet_RolesInMenus_RoleId_MenuId ON dbo.aspnet_RolesInMenus (RoleId, Menu_Id) INCLUDE (Access);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.aspnet_RolesInMenus') AND name = 'IX_aspnet_RolesInMenus_MenuId_RoleId')
    CREATE NONCLUSTERED INDEX IX_aspnet_RolesInMenus_MenuId_RoleId ON dbo.aspnet_RolesInMenus (Menu_Id, RoleId) INCLUDE (Access);
