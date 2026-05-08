using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static PMS.IssueMedicine;

namespace PMS.Inventory
{
    public partial class Product : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        private class ddlListItems
        {
            public string DataValue_Name;
            public string DataValue_Description;
            public string Type;
        }
        [WebMethod]
        public static string CheckActiveAllow()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var ups = (from St in db.aspnet_Users
                       where St.UserName == AppConfig.UserName
                       select St.AllowActiveItems).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(ups);
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
        public static string GetManufacturers()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Manufacture Company"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();

                return new JavaScriptSerializer().Serialize(result);
            }
        }

        [WebMethod]
        public static string GetPackUnits()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "UOM"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();

                return new JavaScriptSerializer().Serialize(result);
            }
        }

        [WebMethod]
        public static string GetItemTypes()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Item Type"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();

                return new JavaScriptSerializer().Serialize(result);
            }
        }

        [WebMethod]
        public static string GetProcedureTypes()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Procedure Types"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();

                return new JavaScriptSerializer().Serialize(result);
            }
        }

        [WebMethod]
        public static string GetAConstant()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "A-Constant"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();

                return new JavaScriptSerializer().Serialize(result);
            }
        }

        [WebMethod]
        public static string GetCategories()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "item Category"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();

                return new JavaScriptSerializer().Serialize(result);
            }
        }

        [WebMethod]
        public static string GetItemGroups()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Item Group"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();

                return new JavaScriptSerializer().Serialize(result);
            }
        }

        [WebMethod]
        public static string GetWarehouses()
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
        public static int GetItemNum()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            int max = Convert.ToInt32(DBClass.getField("Select max(convert(int, SubString(Item_Code, PATINDEX('%[0-9]%',Item_Code), Len(Item_Code)))+1) from INV_Items"));


            return max;
        }
        [WebMethod]
        public static string Getbatch_grn(int item_id,string warehouse)
        {
            string data = string.Empty;
            var batchStockListgrn = new List<BatchStock>();
            var batchStockListst = new List<BatchStock>();

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var PICondition = (from sys in db.sys_Parms where sys.Name == "Direct PO ON Purchase Invoice" select sys.Code).FirstOrDefault();

                if (PICondition == "01")
                {
                    var grnResult = (from dv in db.INV_Items
                                     join ds in db.Purchase_Invoice_Details
                                     on dv.Item_ID equals ds.ItemId
                                     where ds.ItemId == item_id

                                     select new
                                     {
                                         BatchNum = ds.BatchNum,
                                         uomqty = Convert.ToInt32(dv.UOM_Qty),
                                     }).ToList();
                    foreach (var batchNum in grnResult)
                    {
                        var PharmacyCodes = db.sys_Parms.Where(x => x.Name == "Pharmacy WareHouse").Select(x => x.Code).FirstOrDefault().ToString();
                        int stock = Convert.ToInt32(db.GetPharmcyItemUomTotalStock(item_id, warehouse, batchNum.BatchNum));
                        if (stock > 0)
                        {
                            batchStockListgrn.Add(new BatchStock
                            {
                                BatchNum = batchNum.BatchNum,
                                uomqty = batchNum.uomqty,

                            });
                        }
                    }
                }
                else
                {
                    var grnResult = (from dv in db.INV_Items
                                     join ds in db.GRN_Details
                                     on dv.Item_ID equals ds.Item_Id
                                     where ds.Item_Id == item_id

                                     select new
                                     {
                                         BatchNum = ds.BatchNum,
                                         uomqty = ds.UOM_Qty,
                                     }).ToList();
                    foreach (var batchNum in grnResult)
                    {
                        var PharmacyCodes = db.sys_Parms.Where(x => x.Name == "Pharmacy WareHouse").Select(x => x.Code).FirstOrDefault().ToString();
                        int stock = Convert.ToInt32(db.GetPharmcyItemUomTotalStock(item_id, warehouse, batchNum.BatchNum));
                        if (stock > 0)
                        {
                            batchStockListgrn.Add(new BatchStock
                            {
                                BatchNum = batchNum.BatchNum,
                                uomqty = batchNum.uomqty,

                            });
                        }
                    }
                }
                    var stockAdjustmentResult = (from inv in db.INV_Stock_Adjustments
                                                 where inv.Item_Id == Convert.ToString(item_id)
                                                  && inv.Status == "Approved"
                                                 orderby inv.Creation_Time descending
                                                 select new
                                                 {
                                                     BatchNum = inv.Batch_No
                                                 }).ToList();
                foreach (var batchNum in stockAdjustmentResult)
                {
                    int stock = Convert.ToInt32(db.GetPharmcyItemUomTotalStock(item_id, warehouse, batchNum.BatchNum));
                    if (stock > 0)
                    {
                        batchStockListst.Add(new BatchStock
                        {
                            BatchNum = batchNum.BatchNum,
                        });
                    }
                }
                var combinedResult = new
                {
                    GRN_Details = batchStockListgrn,
                    Stock_Adjustment_Details = batchStockListst
                };
                data = new JavaScriptSerializer().Serialize(combinedResult);
            }
           return data;
        }

        [WebMethod]
        public static string LoadBatchsRate(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var details = (from m in db.INV_Item_RateBatchWises
                           where m.Item_Id == id
                           select new
                           {
                               m.Item_Rate_Id,
                               m.Item_Sale_Rate,
                               m.Sehat_card_rate_batch,
                               m.Batch_Num,
                               m.Uom_Qty
                           }).ToList();

            return (new JavaScriptSerializer()).Serialize(details);
        }

        [WebMethod]
        public static string LoadRateCategory(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var details = (from m in db.INV_Item_PatientWises
                           where m.Item_Id == id
                           select new
                           {
                               m.Item_Rate_Id,
                               m.Patient_Type,
                               Patient_Type_text = db.GetDataValueName("Patient Type", m.Patient_Type),
                               m.Item_Sale_Rate,
                           }).ToList();

            return (new JavaScriptSerializer()).Serialize(details);
        }
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static string AddItems(
string Item_Code, string Desc, string Active, string PackUnit, string UomQty, string Menu, string ItemType, string ItemCategory,
string FianceIntegration, string locatorAddress, string Lenght, string Width, string Heigth, string basesize, string baseqty, string SalesRate, string PurchRate,
string Remarks, string FinshProduct, string Consumable, string Saleable, string ItemGroup, string Warehouse, string Purchaseable,
string Locator, string NonStockItem, string Fixasset, string MinimumStock, string Batch, string ReorderStock, string MaximumStock, string Procedure_Time,
string ATC, string GenericName, string ControllerDrug, string Narcotics, string Refregrator, string PharmacyItem, string ProcedureTypes,
string Notes, string RadioCharges, string DentalItem, string Procedure, string LensRequired, string BedServices, string LabRequired,
string PattHistoryRequired, string FitnessCertificate, string OtherServices, string Billing, string OTProcedure,string ShortItem, string btnValue,
string ItemId, string DepartmentId, string IsHospital, string IsService, string SehatSahulat, string SehatCardRate, string Discount_Block,
List<BatchNum> batchList, List<PatientTypeList> PatientTypeList)
        {
            string Id = "";
            DataBaseDataContext db = new DataBaseDataContext();
            INV_Item obj = null;

            try
            {
                if (btnValue == "Save")
                {
                    obj = new INV_Item();

                    obj.Item_Code = Item_Code;
                    obj.Description = Desc;
                    obj.Active = Convert.ToBoolean(Active);
                    obj.Is_Active = Convert.ToBoolean(Active);
                    obj.Unit = PackUnit;
                    obj.Manufacture_Company = Menu;
                    obj.Item_Type = ItemType;
                    obj.Item_Category = ItemCategory;
                    obj.Financial_Integration = FianceIntegration;
                    obj.Item_Account_category = int.TryParse(FianceIntegration, out int finCat) ? finCat : 0;
                    obj.UOM_Qty = decimal.TryParse(UomQty, out decimal uomQty) ? uomQty : 0;
                    obj.Length = decimal.TryParse(Lenght, out decimal length) ? length : 0;
                    obj.Width = decimal.TryParse(Width, out decimal width) ? width : 0;
                    obj.Height = decimal.TryParse(Heigth, out decimal height) ? height : 0;
                    obj.Sale_Rate = decimal.TryParse(SalesRate, out decimal saleRate) ? saleRate : 0;
                    obj.Purchase_Rate = decimal.TryParse(PurchRate, out decimal purchRate) ? purchRate : 0;
                    obj.Remarks = Remarks;
                    obj.locatorAddress = locatorAddress;
                    obj.Locator = Convert.ToBoolean(Locator);
                    obj.IsBatch = Convert.ToBoolean(Batch);
                    obj.Finished_Product = Convert.ToBoolean(FinshProduct);
                    obj.Consumable = Convert.ToBoolean(Consumable);
                    obj.Saleable = Convert.ToBoolean(Saleable);
                    obj.Purchaseable = Convert.ToBoolean(Purchaseable);
                    obj.IsNonStockItem = Convert.ToBoolean(NonStockItem);
                    obj.Isfixasset = Convert.ToBoolean(Fixasset);
                    obj.Mini_Stock = MinimumStock;
                    obj.Reorder_Stock = ReorderStock;
                    obj.Max_Stock = MaximumStock;
                    obj.Procedure_Time = Procedure_Time;
                    obj.ATC = ATC;
                    obj.Generic_Name = GenericName;
                    obj.Controller_Drug = Convert.ToBoolean(ControllerDrug);
                    obj.Narcotics = Convert.ToBoolean(Narcotics);
                    obj.Refregrator = Convert.ToBoolean(Refregrator);
                    obj.IsPharmacyItem = Convert.ToBoolean(PharmacyItem);
                    obj.Pharmacy_Item = Convert.ToBoolean(PharmacyItem);
                    obj.Procedure_Type = ProcedureTypes;
                    obj.Notes = Notes;
                    obj.Base_Unit = basesize;
                    obj.Base_Unit_Qty = Convert.ToInt32(baseqty);
                    obj.LabOR_RadiologyCharges = Convert.ToBoolean(RadioCharges);
                    obj.Dental_Item = Convert.ToBoolean(DentalItem);
                    obj.Procedure_Required = Convert.ToBoolean(Procedure);
                    obj.Lense_Required = Convert.ToBoolean(LensRequired);
                    obj.Bed_Services = Convert.ToBoolean(BedServices);
                    obj.Fitness_Certificate = Convert.ToBoolean(FitnessCertificate);
                    obj.Lab_Required = Convert.ToBoolean(LabRequired);
                    obj.Pat_History_Required = Convert.ToBoolean(PattHistoryRequired);
                    obj.Other_Services = Convert.ToBoolean(OtherServices);
                    obj.Billing_Required = Convert.ToBoolean(Billing);
                    obj.OTProcedure = Convert.ToBoolean(OTProcedure);
                    obj.Short_Item = Convert.ToBoolean(ShortItem);
                    obj.Book_ID = AppConfig.Book_ID;
                    obj.Company_ID = AppConfig.Company_ID;
                    obj.DepartmentId = DepartmentId;
                    obj.ItemGroupId = ItemGroup;
                    obj.InventoryOrg = Warehouse;
                    obj.Hospital_Services = Convert.ToBoolean(IsHospital);
                    obj.Services = Convert.ToBoolean(IsService);
                    obj.issehatCard_item = Convert.ToBoolean(SehatSahulat);
                    obj.sehatCard_Rate = decimal.TryParse(SehatCardRate, out decimal sehatRate) ? sehatRate : 0;
                    obj.Created_By = AppConfig.UserID;
                    obj.Created_Time = DateTime.Now;
                    obj.Discount_Block = Convert.ToBoolean(Discount_Block);

                    bool itemExists = db.INV_Items.Any(x => x.Item_Code == obj.Item_Code);
                    if (itemExists)
                    {
                        var maxCode = DBClass.getField(@"
                SELECT ISNULL(MAX(CONVERT(INT, 
                    SUBSTRING(Item_Code, PATINDEX('%[0-9]%', Item_Code), LEN(Item_Code)))), 0) + 1 
                FROM INV_Items");
                        obj.Item_Code = maxCode;
                    }

                    db.INV_Items.InsertOnSubmit(obj);
                    db.SubmitChanges();
                    Id = obj.Item_ID.ToString();

                    if (batchList != null)
                    {
                        foreach (var bth in batchList)
                        {
                            if (string.IsNullOrEmpty(bth.ddlBatch)) continue;

                            INV_Item_RateBatchWise btch = new INV_Item_RateBatchWise
                            {
                                Item_Id = obj.Item_ID,
                                Batch_Num = bth.ddlBatch,
                                Item_Sale_Rate = bth.txtBatchRate,
                                Sehat_card_rate_batch = bth.txtSCRate,
                                Uom_Qty = bth.txtUom_Qty,
                            };
                            db.INV_Item_RateBatchWises.InsertOnSubmit(btch);
                        }
                    }

                    if (PatientTypeList != null)
                    {
                        foreach (var ptr in PatientTypeList)
                        {
                            if (string.IsNullOrEmpty(ptr.pat_type)) continue;

                            INV_Item_PatientWise ratewise = new INV_Item_PatientWise
                            {
                                Item_Id = obj.Item_ID,
                                Patient_Type = ptr.pat_type,
                                Item_Sale_Rate = ptr.SaleRate,
                            };
                            db.INV_Item_PatientWises.InsertOnSubmit(ratewise);
                        }
                    }

                    db.SubmitChanges();
                }
                else
                {
                    int itemId = Convert.ToInt32(ItemId);
                    obj = db.INV_Items.FirstOrDefault(x => x.Item_ID == itemId);
                    if (obj == null)
                        return "Error";

                    obj.Description = Desc;
                    obj.Active = Convert.ToBoolean(Active);
                    obj.Is_Active = Convert.ToBoolean(Active);
                    obj.Unit = PackUnit;
                    obj.Manufacture_Company = Menu;
                    obj.Item_Type = ItemType;
                    obj.Item_Category = ItemCategory;
                    obj.Financial_Integration = FianceIntegration;
                    obj.Updated_By = AppConfig.UserID;
                    obj.Updated_Time = DateTime.Now;
                    obj.Base_Unit = basesize;
                    obj.Base_Unit_Qty = Convert.ToInt32(baseqty);
                    obj.Item_Account_category = int.TryParse(FianceIntegration, out int finCat) ? finCat : 0;
                    obj.UOM_Qty = decimal.TryParse(UomQty, out decimal uomQty) ? uomQty : 0;
                    obj.Length = decimal.TryParse(Lenght, out decimal length) ? length : 0;
                    obj.Width = decimal.TryParse(Width, out decimal width) ? width : 0;
                    obj.Height = decimal.TryParse(Heigth, out decimal height) ? height : 0;
                    obj.Sale_Rate = decimal.TryParse(SalesRate, out decimal saleRate) ? saleRate : 0;
                    obj.Purchase_Rate = decimal.TryParse(PurchRate, out decimal purchRate) ? purchRate : 0;
                    obj.Remarks = Remarks;
                    obj.locatorAddress = locatorAddress;
                    obj.Locator = Convert.ToBoolean(Locator);
                    obj.IsBatch = Convert.ToBoolean(Batch);
                    obj.Finished_Product = Convert.ToBoolean(FinshProduct);
                    obj.Consumable = Convert.ToBoolean(Consumable);
                    obj.Saleable = Convert.ToBoolean(Saleable);
                    obj.Purchaseable = Convert.ToBoolean(Purchaseable);
                    obj.IsNonStockItem = Convert.ToBoolean(NonStockItem);
                    obj.Isfixasset = Convert.ToBoolean(Fixasset);
                    obj.Mini_Stock = MinimumStock;
                    obj.Reorder_Stock = ReorderStock;
                    obj.Max_Stock = MaximumStock;
                    obj.Procedure_Time = Procedure_Time;
                    obj.ATC = ATC;
                    obj.Generic_Name = GenericName;
                    obj.Controller_Drug = Convert.ToBoolean(ControllerDrug);
                    obj.Narcotics = Convert.ToBoolean(Narcotics);
                    obj.Refregrator = Convert.ToBoolean(Refregrator);
                    obj.IsPharmacyItem = Convert.ToBoolean(PharmacyItem);
                    obj.Pharmacy_Item = Convert.ToBoolean(PharmacyItem);
                    obj.Procedure_Type = ProcedureTypes;
                    obj.Notes = Notes;
                    obj.LabOR_RadiologyCharges = Convert.ToBoolean(RadioCharges);
                    obj.Dental_Item = Convert.ToBoolean(DentalItem);
                    obj.Procedure_Required = Convert.ToBoolean(Procedure);
                    obj.Lense_Required = Convert.ToBoolean(LensRequired);
                    obj.Bed_Services = Convert.ToBoolean(BedServices);
                    obj.Fitness_Certificate = Convert.ToBoolean(FitnessCertificate);
                    obj.Lab_Required = Convert.ToBoolean(LabRequired);
                    obj.Pat_History_Required = Convert.ToBoolean(PattHistoryRequired);
                    obj.Other_Services = Convert.ToBoolean(OtherServices);
                    obj.Billing_Required = Convert.ToBoolean(Billing);
                    obj.OTProcedure = Convert.ToBoolean(OTProcedure);
                    obj.Short_Item = Convert.ToBoolean(ShortItem);
                    obj.DepartmentId = DepartmentId;
                    obj.InventoryOrg = Warehouse;
                    obj.Hospital_Services = Convert.ToBoolean(IsHospital);
                    obj.Services = Convert.ToBoolean(IsService);
                    obj.issehatCard_item = Convert.ToBoolean(SehatSahulat);
                    obj.sehatCard_Rate = decimal.TryParse(SehatCardRate, out decimal sehatRate) ? sehatRate : 0;

                    var pkg = db.Packages_Details.FirstOrDefault(y => y.Item_Code == obj.Item_ID);
                    if (pkg != null && !string.IsNullOrEmpty(SalesRate))
                    {
                        pkg.Price = Convert.ToDecimal(SalesRate);
                        pkg.Amount = Convert.ToDecimal(SalesRate);
                    }

                    if (batchList != null && batchList.Count > 0)
                    {
                        int currentItemId = Convert.ToInt32(ItemId);

                        var cleanBatchList = batchList
                            .Where(b => !string.IsNullOrEmpty(b.ddlBatch))
                            .GroupBy(b => b.ddlBatch.Trim())
                            .Select(g => g.Last())
                            .ToList();

                        var existingBatches = db.INV_Item_RateBatchWises
                            .Where(x => x.Item_Id == currentItemId)
                            .ToList();

                        var submittedBatchNums = cleanBatchList.Select(b => b.ddlBatch).ToList();

                        var toDelete = existingBatches
                            .Where(x => !submittedBatchNums.Contains(x.Batch_Num))
                            .ToList();

                        db.INV_Item_RateBatchWises.DeleteAllOnSubmit(toDelete);

                        foreach (var bth in cleanBatchList)
                        {
                            string batchNum = bth.ddlBatch;

                            var existingBatch = existingBatches
                                .FirstOrDefault(x => x.Batch_Num == batchNum);

                            if (existingBatch != null)
                            {
                                existingBatch.Item_Sale_Rate = bth.txtBatchRate;
                                existingBatch.Sehat_card_rate_batch = bth.txtSCRate;
                                existingBatch.Uom_Qty = bth.txtUom_Qty;
                            }
                            else
                            {
                                INV_Item_RateBatchWise btch = new INV_Item_RateBatchWise
                                {
                                    Item_Id = currentItemId,
                                    Batch_Num = batchNum,
                                    Item_Sale_Rate = bth.txtBatchRate,
                                    Sehat_card_rate_batch = bth.txtSCRate,
                                    Uom_Qty = bth.txtUom_Qty,
                                };
                                db.INV_Item_RateBatchWises.InsertOnSubmit(btch);
                            }
                        }
                        db.SubmitChanges();
                    }

                    if (PatientTypeList != null && PatientTypeList.Count > 0)
                    {
                        var submittedRateIds = new List<int>();
                        foreach (var ptr in PatientTypeList)
                        {
                        }

                       

                        var validRateIds = PatientTypeList
                            .Where(p => p.Item_Rate_Id.HasValue)
                            .Select(p => p.Item_Rate_Id.Value)
                            .ToList();

                        var existingRates = db.INV_Item_PatientWises.Where(x => x.Item_Id == itemId);
                        if (validRateIds.Any())
                        {
                            var toDelete = existingRates.Where(x => !validRateIds.Contains(x.Item_Rate_Id)).ToList();
                            db.INV_Item_PatientWises.DeleteAllOnSubmit(toDelete);
                        }
                        else
                        {
                            db.INV_Item_PatientWises.DeleteAllOnSubmit(existingRates);
                        }

                        foreach (var ptr in PatientTypeList)
                        {
                            if (string.IsNullOrEmpty(ptr.pat_type)) continue;

                            if (ptr.Item_Rate_Id.HasValue)
                            {
                                var existing = db.INV_Item_PatientWises
                                    .FirstOrDefault(x => x.Item_Rate_Id == ptr.Item_Rate_Id.Value);
                                if (existing != null)
                                {
                                    existing.Item_Sale_Rate = ptr.SaleRate;
                                }
                            }
                            else
                            {
                                db.INV_Item_PatientWises.InsertOnSubmit(new INV_Item_PatientWise
                                {
                                    Item_Id = itemId,
                                    Patient_Type = ptr.pat_type,
                                    Item_Sale_Rate = ptr.SaleRate,
                                });
                            }
                        }
                    }

                    db.SubmitChanges();
                    Id = itemId.ToString();
                    return "Update-" + Id;
                }

                return "Success-" + Id;
            }
            catch (Exception ex)
            {
                return "Error";
            }
        }

        [WebMethod]
        public static string LoadItemInventory(int ID)
        {
            string result = string.Empty;
            if (ID > 0)
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var query = (from obj in db.INV_Items
                                 where obj.Item_ID == ID
                                 select new
                                 {
                                     obj.Item_Code,
                                     obj.Description,
                                     obj.Active,
                                     obj.Unit,
                                     Unit_Text = db.GetDataValueName("UOM", obj.Unit),
                                     obj.UOM_Qty,
                                     Manufacture_Text = db.GetDataValueName("Manufacture Company", obj.Manufacture_Company),
                                     obj.Manufacture_Company,
                                     obj.Item_Type,
                                     Itemtype_Text = db.GetDataValueName("Item Type", obj.Item_Type),
                                     obj.Item_Category,
                                     Item_Category_Text = db.GetDataValueName("item Category", obj.Item_Category),
                                     obj.Item_Account_category,
                                     AccountCategory_Text = db.Account_Categories
                                     .Where(a => a.Account_Category_Id == obj.Item_Account_category)
                                     .Select(a => a.CategoryName)
                                     .Distinct()  // ← Prevent duplicates
                                     .FirstOrDefault(),
                                     obj.Financial_Integration,
                                     obj.locatorAddress,
                                     obj.Length,
                                     obj.Width,
                                     obj.Height,
                                     obj.Base_Unit,
                                     Base_Unit_Text = db.GetDataValueName("Unit Size", obj.Base_Unit),
                                     obj.Base_Unit_Qty,
                                     obj.Sale_Rate,
                                     obj.Purchase_Rate,
                                     obj.Remarks,
                                     obj.Finished_Product,
                                     obj.Consumable,
                                     obj.Saleable,
                                     obj.Serial,
                                     obj.Purchaseable,
                                     obj.IsNonStockItem,
                                     obj.Isfixasset,
                                     obj.Pack,
                                     obj.IsBatch,
                                     obj.Locator,
                                     obj.Mini_Stock,
                                     obj.Reorder_Stock,
                                     obj.Max_Stock,
                                     obj.Procedure_Time,
                                     obj.ATC,
                                     obj.Generic_Name,
                                     obj.Controller_Drug,
                                     obj.Narcotics,
                                     obj.Refregrator,
                                     obj.IsPharmacyItem,
                                     obj.Procedure_Type,
                                     Procedure_Type_Text = db.GetDataValueName("Procedure Types", obj.Procedure_Type),
                                     obj.Notes,
                                     obj.Services,
                                     obj.Liability_Item,
                                     obj.LabOR_RadiologyCharges,
                                     obj.Physio_Item,
                                     obj.Dental_Item,
                                     obj.Derma_Item,
                                     obj.Procedure_Required,
                                     obj.Lense_Required,
                                     obj.Bed_Services,
                                     obj.Fitness_Certificate,
                                     obj.Lab_Required,
                                     obj.Pat_History_Required,
                                     obj.Other_Services,
                                     obj.Billing_Required,
                                     obj.ItemGroupId,
                                     ItemGroup_Text = db.GetDataValueName("Item Group", obj.ItemGroupId),
                                     obj.InventoryOrg,
                                     InventoryOrg_Text = db.GetDataValueName("Ware House", obj.InventoryOrg),
                                     obj.DepartmentId,
                                     DepartmentId_Text = db.GetDataValueName("Patient Main Category", obj.DepartmentId),
                                     obj.Hospital_Services,
                                     obj.OTProcedure,
                                     obj.Short_Item,
                                     obj.issehatCard_item,
                                     obj.sehatCard_Rate,
                                     obj.Discount_Block,
                                 }).FirstOrDefault();


                    result = (new JavaScriptSerializer()).Serialize(query).ToString();
                }
            }
            return result;
        }
        [WebMethod]
        public static string GetDiscountSysParams()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var Discount_Detail = (from prms in db.sys_Parms
                                  where prms.Name == "Block Discount"
                                  select prms.Code
                ).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(Discount_Detail);
        }
        [WebMethod]
        public static string getAccountCategory()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var accountcategory = (from p in db.Account_Categories
                                   select new
                                   {
                                       DataValue_Name = p.Account_Category_Id,
                                       DataValue_Description =  p.CategoryName
                                   }).ToList();
            return (new JavaScriptSerializer()).Serialize(accountcategory);
        } 
        [WebMethod]
        public static string GetPatientType()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Patient Type"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }
        [WebMethod]
        public static string GetDepartments()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Patient Main Category"
                         select new ddlListItems
                         {
                             DataValue_Name = p.DataValue_Name,
                             DataValue_Description = p.DataValue_Description,
                             Type = v.ValueSet_Description == "Patient Main Category" ? "Dept" : "Fed"
                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(listItems);
        }
        public class BatchNum
        {
            public string Item_Id { get; set; }
            public string ddlBatch { get; set; }
            public decimal txtBatchRate { get; set; }
            public decimal txtSCRate { get; set; }
            public decimal txtUom_Qty { get; set; }
        }
        public class PatientTypeList
        {
            public string Item_Id { get; set; }
            public string pat_type { get; set; }
            public decimal SaleRate { get; set; }

            public int? Item_Rate_Id { get; set; }

        }
    }
}