using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Inventory
{
    public partial class BOM : System.Web.UI.Page
    {

        protected void Page_Load(object sender, EventArgs e)
        {
        }
        [WebMethod]
        public static string GetWareHouse()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Ware House"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();

                return new JavaScriptSerializer().Serialize(result);
            }
        }
        [WebMethod]
        public static string GetUnitSize()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Unit Size"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();

                return new JavaScriptSerializer().Serialize(result);
            }
        }
        [WebMethod]
        public static string LoadProcedures()
        {
            using (var db = new DataBaseDataContext())
            {
                var list = (from p in db.INV_Items
                            where p.Is_Active == true
                            && p.Procedure_Required == true
                            select new
                            {
                                p.Item_ID,
                                p.Description
                            }).ToList();
                return new JavaScriptSerializer().Serialize(list);
            }
        }

        [WebMethod]
        public static string LoadItems()
        {
            using (var db = new DataBaseDataContext())
            {
                var list = (from i in db.INV_Items
                            where i.Is_Active == true
                            && i.InventoryOrg == "002"
                            select new
                            {
                                i.Item_ID,
                                i.Description

                            }).ToList();
                return new JavaScriptSerializer().Serialize(list);
            }
        }
        [WebMethod]
        public static string GetItemDetails(int itemId)
        {
            using (var db = new DataBaseDataContext())
            {

                decimal latestGrnRate = (from g in db.GRN_Details
                                         join inv in db.INV_Items on g.Item_Id equals inv.Item_ID
                                         where g.Item_Id == itemId
                                         
                                           && g.GRNQty.HasValue && g.GRNQty > 0
                                           && g.Amount.HasValue
                                           && inv.UOM_Qty.HasValue && inv.UOM_Qty > 0
                                         orderby g.GRN_detail_Id descending
                                         select (g.Amount.Value / g.GRNQty.Value) / inv.UOM_Qty.Value)
                                        .FirstOrDefault(); 

                decimal purchaseRate = latestGrnRate; 

              
                if (latestGrnRate == 0)
                {
                    
                    var fallbackRate = (from s in db.INV_Stock_Adjustments
                                        where s.Item_Id == Convert.ToString(itemId)
                                   
                                        orderby s.Adjustment_ID descending
                                        select s.Rate.Value)
                                       .FirstOrDefault(); 

                    if (fallbackRate != 0)
                    {
                        purchaseRate = fallbackRate;
                    }
                }

                var item = db.INV_Items.FirstOrDefault(m => m.Item_ID == itemId);
                if (item == null)
                    return new JavaScriptSerializer().Serialize(new { error = "Item not found" });

                decimal stockInBaseUnit = db.GetInventoryItemTotalStock_BaseUnit(item.Item_ID, item.InventoryOrg) ?? 0;
                decimal weighted_avg = db.GetAvgAmount(item.Item_ID) ?? 0;

                // Compute stock in UOM (e.g., tubes, packets)
                decimal stockInUOM = item.UOM_Qty > 0
                   ? Math.Round(stockInBaseUnit / (decimal)item.UOM_Qty, 2)
                   : stockInBaseUnit;

                decimal baseqty = stockInUOM * Convert.ToDecimal(item.Base_Unit_Qty);
                // Get UOM name (e.g., "tube", "packet") — assuming you have a helper or table
                string uomName = db.GetDataValueName("UOM", item.Unit)?.ToLower() ?? "unit"; // e.g., "tube"
                string baseUnitName = db.GetDataValueName("Unit Size", item.Base_Unit)?.ToLower() ?? "gram";
                string baseUnit = item.Base_Unit;
                // Build display string
                string displayText = $"{stockInUOM:0.#} {uomName}(s) ({baseqty:0.#} {baseUnitName})";

                var result = new
                {
                    item.Sale_Rate,
                    Purchase_Rate = purchaseRate,
                    baseUnitName = db.GetDataValueName("Unit Size", item.Base_Unit)?.ToLower() ?? "gram",
                    item.Base_Unit,
                    item.Base_Unit_Qty,
                    StockTotal = stockInUOM,          // 100
                    StockInBaseUnit = baseqty, // 1000
                    StockDisplay = displayText,         // "100 tube(s) (1000 gram)"
                    weighted_avg = weighted_avg

                };

                return new JavaScriptSerializer().Serialize(result);
            }
        }
        public class BOM_Item
        {
            public int ItemID { get; set; }
            public string ItemName { get; set; }
            public decimal Qty { get; set; }
            public string Unit { get; set; }
            public decimal CostPerUnit { get; set; }
            public decimal Total { get; set; }
            //public string Batch_No { get; set; }
            public decimal BaseUnitQty { get; set; }
        }
        //[WebMethod]
        //public static string Getbatch_grn(int med_id)
        //{
        //    string data = string.Empty;

        //    using (DataBaseDataContext db = new DataBaseDataContext())
        //    {
        //        var grnResult = (from dv in db.INV_Items
        //                         join ds in db.GRN_Details
        //                         on dv.Item_ID equals ds.Item_Id
        //                         where ds.Item_Id == med_id
        //                         select new
        //                         {
        //                             BatchNum = ds.BatchNum
        //                         }).ToList();

        //        var stockAdjustmentResult = (from inv in db.INV_Stock_Adjustments
        //                                     where inv.Item_Id == Convert.ToString(med_id)
        //                                      && inv.Status == "Approved"
        //                                     orderby inv.Creation_Time descending
        //                                     select new
        //                                     {
        //                                         BatchNum = inv.Batch_No
        //                                     }).ToList();
        //        var combinedResult = new
        //        {
        //            GRN_Details = grnResult,
        //            Stock_Adjustment_Details = stockAdjustmentResult
        //        };
        //        data = new JavaScriptSerializer().Serialize(combinedResult);
        //    }
        //    return data;
        //}

        [WebMethod]
        public static string LoadBOM(int ID)
        {
            using (var db = new DataBaseDataContext())
            {
                var bom = db.inv_boms.FirstOrDefault(x => x.BOMID == ID);
                if (bom == null)
                    return new JavaScriptSerializer().Serialize(new { error = "BOM not found." });

                var details = (from d in db.inv_bom_details
                               where d.BOMID == ID  
                               join i in db.INV_Items on d.ItemID equals i.Item_ID
                               select new
                               {
                                   d.ItemID,
                                   ItemName = i.Description,
                                   d.Qty,
                                   d.Unit,
                                   UnitText = db.GetDataValueName("Unit Size", d.Unit),
                                   d.CostPerUnit,
                                   d.Total,
                                   d.BaseUnitQty
                               }).ToList();

                string procedureText = db.INV_Items
                    .Where(x => x.Item_ID == bom.ProcedureID)
                    .Select(x => x.Description)
                    .FirstOrDefault() ?? "";

                string warehouseText = db.GetDataValueName("Ware House", bom.warehouse) ?? "";

                var result = new
                {
                    bom.BOMID,
                    bom.ProcedureID,
                    ProcedureText = procedureText,
                    bom.Category,
                    bom.warehouse,
                    WarehouseText = warehouseText,
                    Items = details
                };

                return new JavaScriptSerializer().Serialize(result);
            }
        }
        [WebMethod]
        public static string SaveBOM(int bomId, int procedureId, string category, string warehouse, List<BOM_Item> items)
        {
            if (procedureId <= 0 || items == null || items.Count == 0)
                return "-1";

            foreach (var item in items)
            {
                if (item.Qty <= 0)
                    return "ERROR: Quantity must be greater than zero.";
            }

            using (var db = new DataBaseDataContext())
            {
                try
                {
                    var seen = new HashSet<int>();
                    foreach (var item in items)
                    {
                        if (seen.Contains(item.ItemID))
                            return $"DUPLICATE: Item '{item.ItemName}' added multiple times.";
                        seen.Add(item.ItemID);
                    }

                    inv_bom bom;

                    if (bomId > 0)
                    {
                        bom = db.inv_boms.FirstOrDefault(b => b.BOMID == bomId);
                        if (bom == null) return "-1";

                        bom.ProcedureID = procedureId;
                        bom.Category = string.IsNullOrWhiteSpace(category) ? null : category.Trim();
                        bom.warehouse = warehouse;
                        bom.TotalCost = items.Sum(x => x.Total);
                        bom.UpdatedBy = AppConfig.UserID;
                        bom.UpdatedDate = DateTime.Now;
                    }
                    else
                    {
                        bom = new inv_bom
                        {
                            ProcedureID = procedureId,
                            Category = string.IsNullOrWhiteSpace(category) ? null : category.Trim(),
                            warehouse = warehouse,
                            TotalCost = items.Sum(x => x.Total),
                            CreatedBy = AppConfig.UserID,
                            CreatedDate = DateTime.Now,
                            Company_ID = AppConfig.Company_ID,
                        };
                        db.inv_boms.InsertOnSubmit(bom);
                        db.SubmitChanges();
                    }

                    foreach (var item in items)
                    {
                        var detail = db.inv_bom_details
                            .FirstOrDefault(d => d.BOMID == bom.BOMID && d.ItemID == item.ItemID);

                        if (detail != null)
                        {
                            detail.Qty = item.Qty;
                            detail.Unit = item.Unit ?? "pcs";
                            detail.CostPerUnit = item.CostPerUnit;
                            detail.Total = item.Total;
                            detail.BaseUnitQty = item.BaseUnitQty;
                        }
                        else
                        {
                            detail = new inv_bom_detail
                            {
                                BOMID = bom.BOMID,
                                ItemID = item.ItemID,
                                Qty = item.Qty,
                                Unit = item.Unit ?? "pcs",
                                CostPerUnit = item.CostPerUnit,
                                Total = item.Total,
                                BaseUnitQty = item.BaseUnitQty
                            };
                            db.inv_bom_details.InsertOnSubmit(detail);
                        }
                    }

                    db.SubmitChanges();
                    return bom.BOMID.ToString();
                }
                catch (Exception ex)
                {
                    return "-1";
                }
            }
        }
    }
}

