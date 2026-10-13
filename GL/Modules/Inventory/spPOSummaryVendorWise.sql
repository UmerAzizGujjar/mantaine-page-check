-- Vendor Wise PO Summary: adds optional Start Date / End Date (on PO_Date) and Warehouse (AP_Purchase_Orders.Ware_House) filters.
-- New parameters are optional, so the existing call (@Vendor_ID only) returns the same rows as before.
ALTER Procedure [dbo].[spPOSummaryVendorWise]
(
	@Vendor_ID int,
	@StartDate datetime = NULL,
	@EndDate datetime = NULL,
	@Warehouse varchar(100) = '0'
)
as
select
m.PO_No,
m.PO_Date,
m.Ref_No,
m.Vendor_ID,
v.Vendor_Name,
v.Vendor_Address,
m.Status,
d.Item_Code,
d.Rate,
d.qty,
d.Amount,
d.Discount_Amount,
d.Delivery_Date as ShipDate,
i.Item_Code,
i.Description,
(dbo.GetDataValueName('UOM',i.unit)) as unit
 from AP_Purchase_Orders m,AP_Purchase_Order_Items d,INV_Items i,AP_Vendors v
where
m.PO_ID =d.PO_ID
and d.Item_Id =i.Item_ID
and m.Vendor_ID =v.Vendor_ID
and m.Vendor_ID =(case when @Vendor_ID =0 then m.Vendor_ID else @Vendor_ID end)
and (@StartDate is null or m.PO_Date >= @StartDate)
and (@EndDate is null or m.PO_Date < DATEADD(day, 1, @EndDate))
and (@Warehouse is null or @Warehouse = '0' or m.Ware_House = @Warehouse)
order by Vendor_ID

--exec spPOSummaryVendorWise 0
--exec spPOSummaryVendorWise 0, '01 Oct 2026', '13 Oct 2026', '0'
