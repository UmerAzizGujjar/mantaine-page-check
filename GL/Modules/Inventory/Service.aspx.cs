using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Inventory
{
    public partial class Service : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        private class ddlListItems
        {
            public string DataValueName;
            public string DataValueDescription;
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
        public static string getDDLlist()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Manufacture Company" || v.ValueSet_Description == "UOM" || v.ValueSet_Description == "Item Type" || v.ValueSet_Description == "Procedure Types" || v.ValueSet_Description == "A-Constant" || v.ValueSet_Description == "Surgery" || v.ValueSet_Description == "item Category" || v.ValueSet_Description == "Item Group" || v.ValueSet_Description == "Ware House"
                         select new ddlListItems
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                             Type = v.ValueSet_Description == "item Category" ? "item Category" : v.ValueSet_Description == "Manufacture Company" ? "Manu" : v.ValueSet_Description == "UOM" ? "PUnit" : v.ValueSet_Description == "Item Type" ? "ItemTyp" : v.ValueSet_Description == "Procedure Types" ? "ProcType" : v.ValueSet_Description == "A - Constant" ? "Aconst" : v.ValueSet_Description == "Item Group" ? "ItmGrp" : v.ValueSet_Description == "Ware House" ? "Warehouse" : "surg",
                         }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);
        }


        [WebMethod]
        public static int GetItemNum()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            int max = Convert.ToInt32(DBClass.getField("Select max(convert(int, SubString(Item_Code, PATINDEX('%[0-9]%',Item_Code), Len(Item_Code)))+1) from INV_Items"));


            return max;
        }
        //
        [WebMethod]
        public static string SaveItem(string Item_Code, string Desc, string Active, string PackUnit, string UomQty, string Menu, string ItemType, string ItemCategory, string FianceIntegration, string locatorAddress, string Lenght, string Width, string Heigth, string SalesRate, string PurchRate, string Remarks, string FinshProduct, string Consumable, string Saleable, string ItemGroup, string Warehouse, string Purchaseable, string Locator, string NonStockItem, string Fixasset, string MinimumStock, string Batch, string ReorderStock, string MaximumStock, string ATC, string GenericName, string ControllerDrug, string Narcotics, string Refregrator, string PharmacyItem, string ProcedureTypes, string Notes, string RadioCharges, string DentalItem, string Procedure, string LensRequired, string BedServices, string LabRequired, string PattHistoryRequired, string DoctorShare, string HospitalShare, string FitnessCertificate, string OtherServices, string Billing, string OTProcedure, string btnValue, string ItemId, string DepartmentId, string IsHospital, string IsService,string fluid, string Procedure_Time)
        {
            string result = string.Empty;
            string Id = "";
            var item_codes = "";
            DataBaseDataContext db = new DataBaseDataContext();
            INV_Item obj = new INV_Item();
            if (btnValue == "Save")
            {
                obj.Item_Code = Item_Code;
                obj.Description = Desc;
                obj.Active = Convert.ToBoolean(Active);
                obj.Unit = PackUnit;
                obj.Manufacture_Company = Menu;
                obj.Item_Type = ItemType;
                obj.Item_Category = ItemCategory;
                obj.Financial_Integration = FianceIntegration;
                if (UomQty != "")
                {
                    obj.UOM_Qty = Convert.ToDecimal(UomQty);
                }
                obj.Item_Account_category = int.Parse(FianceIntegration);
                if (Lenght != "")
                {
                    obj.Length = Convert.ToDecimal(Lenght);
                }
                if (Width != "")
                {
                    obj.Width = Convert.ToDecimal(Width);
                }
                if (Heigth != "")
                {
                    obj.Height = Convert.ToDecimal(Heigth);
                }
                if (SalesRate != "")
                {
                    obj.Sale_Rate = Convert.ToDecimal(SalesRate);
                }
                if (PurchRate != "")
                {
                    obj.Purchase_Rate = Convert.ToDecimal(PurchRate);
                }
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
                obj.Infusion_Fluid = Convert.ToBoolean(fluid);
                obj.Procedure_Time = Procedure_Time;
                if (MinimumStock == "")
                {
                    MinimumStock = null;
                }
                else
                {

                    obj.Mini_Stock = MinimumStock;
                }

                obj.Reorder_Stock = ReorderStock;
                obj.Max_Stock = MaximumStock;
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
                obj.Book_ID = AppConfig.Book_ID;
                obj.Company_ID = AppConfig.Company_ID;
                obj.DepartmentId = DepartmentId;
                obj.ItemGroupId = ItemGroup;
                obj.InventoryOrg = Warehouse;
                obj.Hospital_Services = Convert.ToBoolean(IsHospital);
                obj.Services = Convert.ToBoolean(IsService);
                if (DoctorShare != "")
                {
                    obj.Doctor_Share = Convert.ToDecimal(DoctorShare);
                }
                if (HospitalShare != "")
                {
                    obj.Hospital_Share = Convert.ToDecimal(HospitalShare);
                }
                //obj.Is_ShareService = Convert.ToBoolean(isShareService);
                var Item = Item_Code;

                DataTable dt = DBClass.getDataTable("select Item_Code from INV_Items where Item_Code='" + Item + "'");


                if (dt.Rows.Count == 0) // Item does not exist
                {
                    string newItemCode = DBClass.getField(@"
                    SELECT 
                        ISNULL(MAX(CONVERT(INT, 
                            SUBSTRING(Item_Code, PATINDEX('%[0-9]%', Item_Code), LEN(Item_Code)))), 0) + 1 
                    FROM INV_Items
                ");

                    obj.Item_Code = newItemCode;
                }
                db.INV_Items.InsertOnSubmit(obj);
                try
                {
                    db.SubmitChanges();
                    Id = Convert.ToString(obj.Item_ID);
                }
                catch (Exception)
                {
                    return "Error";
                }
                try
                {
                    db.SubmitChanges();
                }
                catch (Exception)
                {
                    return "Error";
                }
            }
            else
            {
                int id = Convert.ToInt32(ItemId);
                obj = db.INV_Items.Where(x => x.Item_ID == id).FirstOrDefault();
                Packages_Detail pkg = new Packages_Detail();
                pkg = db.Packages_Details.Where(y => y.Item_Code == obj.Item_ID).FirstOrDefault();
                obj.Description = Desc;
                obj.Active = Convert.ToBoolean(Active);
                obj.Unit = PackUnit;
                obj.Manufacture_Company = Menu;
                obj.Item_Type = ItemType;
                obj.Item_Category = ItemCategory;
                if (FianceIntegration == null) FianceIntegration = "0";
                obj.Item_Account_category = int.Parse(FianceIntegration);
                obj.Book_ID = AppConfig.Book_ID;
                obj.Financial_Integration = FianceIntegration;
                obj.locatorAddress = locatorAddress;
                if (UomQty != "")
                {
                    obj.UOM_Qty = Convert.ToDecimal(UomQty);
                }
                if (Lenght != "")
                {
                    obj.Length = Convert.ToDecimal(Lenght);
                }
                if (Width != "")
                {
                    obj.Width = Convert.ToDecimal(Width);
                }
                if (Heigth != "")
                {
                    obj.Height = Convert.ToDecimal(Heigth);
                }
                if (SalesRate != "")
                {
                    obj.Sale_Rate = Convert.ToDecimal(SalesRate);
                    if (pkg != null)
                    {
                        pkg.Price = Convert.ToDecimal(SalesRate);
                        pkg.Amount = Convert.ToDecimal(SalesRate);
                    }
                }
                if (PurchRate != "")
                {
                    obj.Purchase_Rate = Convert.ToDecimal(PurchRate);
                }
                obj.ItemGroupId = ItemGroup;
                obj.InventoryOrg = Warehouse;
                obj.Remarks = Remarks;
                obj.Finished_Product = Convert.ToBoolean(FinshProduct);
                obj.Locator = Convert.ToBoolean(Locator);
                obj.IsBatch = Convert.ToBoolean(Batch);
                obj.Consumable = Convert.ToBoolean(Consumable);
                obj.Saleable = Convert.ToBoolean(Saleable);
                obj.Purchaseable = Convert.ToBoolean(Purchaseable);
                obj.IsNonStockItem = Convert.ToBoolean(NonStockItem);
                obj.Isfixasset = Convert.ToBoolean(Fixasset);
                if (DoctorShare != "")
                {
                    obj.Doctor_Share = Convert.ToDecimal(DoctorShare);
                }
                if (HospitalShare != "")
                {
                    obj.Hospital_Share = Convert.ToDecimal(HospitalShare);
                }

                if (MinimumStock == "")
                {
                    MinimumStock = null;
                }
                else
                {

                    obj.Mini_Stock = MinimumStock;
                }


                obj.Reorder_Stock = ReorderStock;
                obj.Max_Stock = MaximumStock;
                obj.ATC = ATC;
                obj.Generic_Name = GenericName;
                obj.Controller_Drug = Convert.ToBoolean(ControllerDrug);
                obj.Narcotics = Convert.ToBoolean(Narcotics);
                obj.Infusion_Fluid = Convert.ToBoolean(fluid);
                obj.Procedure_Time = Procedure_Time;
                obj.IsPharmacyItem = Convert.ToBoolean(PharmacyItem);
                obj.Pharmacy_Item = Convert.ToBoolean(PharmacyItem);
                obj.Refregrator = Convert.ToBoolean(Refregrator);
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
                obj.DepartmentId = DepartmentId;
                obj.InventoryOrg = Warehouse;
                obj.Hospital_Services = Convert.ToBoolean(IsHospital);
                obj.Company_ID = AppConfig.Company_ID;
                obj.Book_ID = AppConfig.Book_ID;
                obj.Services = Convert.ToBoolean(IsService);
                try
                {
                    db.SubmitChanges();
                    Id = Convert.ToString(obj.Item_ID);
                    return "Update-" + Id;
                }
                catch (Exception)
                {
                    return "Error";

                }
            }
            return "Success-" + Id;
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
                                     obj.UOM_Qty,
                                     obj.Manufacture_Company,
                                     obj.Item_Type,
                                     obj.Item_Category,
                                     obj.Item_Account_category,
                                     obj.Financial_Integration,
                                     obj.locatorAddress,
                                     obj.Length,
                                     obj.Width,
                                     obj.Height,
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
                                     obj.ATC,
                                     obj.Generic_Name,
                                     obj.Controller_Drug,
                                     obj.Narcotics,
                                     obj.Infusion_Fluid,
                                     obj.Procedure_Time,
                                     obj.Refregrator,
                                     obj.IsPharmacyItem,
                                     obj.Procedure_Type,
                                     obj.Hospital_Share,
                                     //obj.Is_OpenBill,
                                     obj.Is_ShareService,
                                     obj.Notes,
                                     obj.Services,
                                     obj.Doctor_Share,
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
                                     obj.InventoryOrg,
                                     obj.DepartmentId,
                                     obj.Hospital_Services,
                                     obj.OTProcedure,
                                 }).FirstOrDefault();
                    result = (new JavaScriptSerializer()).Serialize(query).ToString();
                }
            }
            return result;
        }
        [WebMethod]
        public static string getAccountCategory()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var accountcategory = (from p in db.Account_Categories
                                   select new
                                   {
                                       p.Account_Category_Id,
                                       p.CategoryName
                                   }).ToList();
            return (new JavaScriptSerializer()).Serialize(accountcategory);
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
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                             Type = v.ValueSet_Description == "Patient Main Category" ? "Dept" : "Fed"
                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(listItems);
        }
    }
}