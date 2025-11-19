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
                            select new
                            {
                                i.Item_ID,
                                i.Description
                               
                            }).ToList();
                return new JavaScriptSerializer().Serialize(list);
            }
        }

    }
}

//using System;
//using System.Collections.Generic;
//using System.Linq;
//using System.Web;
//using System.Web.Script.Serialization;
//using System.Web.Services;
//using System.Web.UI;
//using System.Web.UI.WebControls;

//namespace PMS.Inventory
//{
//    public partial class BOM : System.Web.UI.Page
//    {
//        protected void Page_Load(object sender, EventArgs e) { }

//        // DTO for detail items (like Dep_Fill)
//        public class BOM_Item
//        {
//            public int ItemID { get; set; }
//            public string ItemName { get; set; }
//            public decimal Qty { get; set; }
//            public string Unit { get; set; }
//            public decimal CostPerUnit { get; set; }
//            public decimal Total { get; set; }
//        }

//        [WebMethod]
//        public static string LoadProcedures()
//        {
//            using (var db = new DataBaseDataContext())
//            {
//                var list = (from p in db.inv_procedures
//                            where p.IsActive == true
//                            select new
//                            {
//                                p.ProcedureID,
//                                p.ProcedureName
//                            }).ToList();
//                return new JavaScriptSerializer().Serialize(list);
//            }
//        }

//        [WebMethod]
//        public static string LoadItems()
//        {
//            using (var db = new DataBaseDataContext())
//            {
//                var list = (from i in db.inv_item
//                            where i.IsActive == true
//                            select new
//                            {
//                                i.ItemID,
//                                i.ItemName,
//                                Cost = i.Cost ?? 0m
//                            }).ToList();
//                return new JavaScriptSerializer().Serialize(list);
//            }
//        }

//        [WebMethod]
//        public static string SaveBOM(int procedureId, string category, List<BOM_Item> items)
//        {
//            // Validate
//            if (procedureId <= 0 || items == null || items.Count == 0)
//                return "-1";

//            using (var db = new DataBaseDataContext())
//            {
//                try
//                {
//                    // Check duplicate: e.g., same Procedure + same ItemID already in BOM? (optional)
//                    // Example: prevent same item added twice in same BOM
//                    var seenItemIDs = new HashSet<int>();
//                    foreach (var item in items)
//                    {
//                        if (seenItemIDs.Contains(item.ItemID))
//                        {
//                            return $"DUPLICATE: Item '{item.ItemName}' added multiple times.";
//                        }
//                        seenItemIDs.Add(item.ItemID);
//                    }

//                    // Create master
//                    var bom = new inv_bom
//                    {
//                        ProcedureID = procedureId,
//                        Category = string.IsNullOrWhiteSpace(category) ? null : category.Trim(),
//                        TotalCost = items.Sum(x => x.Total),
//                        CreatedBy = AppConfig.UserID,
//                        CreatedDate = DateTime.Now
//                    };
//                    db.inv_bom.InsertOnSubmit(bom);
//                    db.SubmitChanges(); // Get BOMID

//                    // Insert details
//                    foreach (var item in items)
//                    {
//                        var detail = new inv_bom_detail
//                        {
//                            BOMID = bom.BOMID,
//                            ItemID = item.ItemID,
//                            ItemName = item.ItemName, // denormalized
//                            Qty = item.Qty,
//                            Unit = item.Unit ?? "pcs",
//                            CostPerUnit = item.CostPerUnit,
//                            Total = item.Total
//                        };
//                        db.inv_bom_detail.InsertOnSubmit(detail);
//                    }
//                    db.SubmitChanges();

//                    return bom.BOMID.ToString(); // success → return ID (like your depreciation SaveRecord)
//                }
//                catch (Exception ex)
//                {
//                    return "-1"; // or ex.Message — but you return "-1" on failure in depreciation
//                }
//            }
//        }

//        // Optional: Get for Edit (if you later add ?ID= support)
//        /*
//        [WebMethod]
//        public static string GetBOM(string id)
//        {
//            using (var db = new DataBaseDataContext())
//            {
//                var master = db.inv_bom.FirstOrDefault(x => x.BOMID == Convert.ToInt32(id));
//                if (master == null) return "[]";

//                var details = db.inv_bom_detail.Where(x => x.BOMID == master.BOMID).ToList();
//                return new JavaScriptSerializer().Serialize(new { master, details });
//            }
//        }
//        */
//    }
//}