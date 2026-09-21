using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web.Script.Serialization;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace PMS
{
    public static class INVItemLogHelper
    {
        private static string StrVal(object v)
        {
            if (v == null) return "";
            return Convert.ToString(v, CultureInfo.InvariantCulture);
        }

        private static string NumVal(object v)
        {
            if (v == null) return "";
            try { return Convert.ToDecimal(v).ToString("0.##", CultureInfo.InvariantCulture); }
            catch { return ""; }
        }

        private static string BoolVal(object v)
        {
            if (v == null) return "";
            try { return Convert.ToBoolean(v) ? "Yes" : "No"; }
            catch { return ""; }
        }

        private static string NameVal(DataBaseDataContext db, string valueSet, string code)
        {
            if (string.IsNullOrEmpty(code)) return "";
            try
            {
                var name = db.GetDataValueName(valueSet, code);
                return string.IsNullOrEmpty(name) ? code : name;
            }
            catch { return code; }
        }

        private static string AccountName(DataBaseDataContext db, int? accountId)
        {
            if (!accountId.HasValue) return "";
            try
            {
                var acc = (from a in db.GL_Accounts where a.Account_ID == accountId.Value
                           select new { a.Account_Code, a.Account_Name }).FirstOrDefault();
                if (acc == null) return accountId.Value.ToString();
                return StrVal(acc.Account_Code) + "-" + StrVal(acc.Account_Name);
            }
            catch { return accountId.Value.ToString(); }
        }

        public static Dictionary<string, string> BuildItemMasterSnapshot(INV_Item i, DataBaseDataContext db)
        {
            var s = new Dictionary<string, string>();

            s["Item_Code"] = StrVal(i.Item_Code);
            s["Description"] = StrVal(i.Description);
            s["Unit"] = NameVal(db, "UOM", i.Unit);
            s["Item_Type"] = NameVal(db, "Item Type", i.Item_Type);
            s["Item_Category"] = NameVal(db, "item Category", i.Item_Category);
            s["Item_Sub_Category"] = StrVal(i.Item_Sub_Category);
            s["Service_Sub_Category"] = StrVal(i.Service_Sub_Category);
            s["Manufacturer_Name"] = StrVal(i.Manufacturer_Name);
            s["Manufacture_Company"] = StrVal(i.Manufacture_Company);
            s["Account_Category"] = StrVal(i.Item_Account_category);
            s["Account"] = AccountName(db, i.Account_ID);
            s["Financial_Integration"] = StrVal(i.Financial_Integration);

            s["Purchase_Rate"] = NumVal(i.Purchase_Rate);
            s["Sale_Rate"] = NumVal(i.Sale_Rate);
            s["UOM_Qty"] = NumVal(i.UOM_Qty);
            s["Base_Unit"] = StrVal(i.Base_Unit);
            s["Base_Unit_Qty"] = StrVal(i.Base_Unit_Qty);
            s["Sehat_Card_Rate"] = NumVal(i.sehatCard_Rate);

            s["Pack"] = BoolVal(i.Pack);
            s["Pack_Quantity"] = StrVal(i.Pack_Quantity);
            s["Pack_Unit"] = StrVal(i.Pack_Unit);
            s["Salt"] = StrVal(i.Salt);
            s["ATC"] = StrVal(i.ATC);
            s["Generic_Name"] = StrVal(i.Generic_Name);
            s["Notes"] = StrVal(i.Notes);
            s["Remarks"] = StrVal(i.Remarks);
            s["Mini_Stock"] = StrVal(i.Mini_Stock);
            s["Max_Stock"] = StrVal(i.Max_Stock);
            s["Reorder_Stock"] = StrVal(i.Reorder_Stock);
            s["Length"] = NumVal(i.Length);
            s["Width"] = NumVal(i.Width);
            s["Height"] = NumVal(i.Height);
            s["Locator_Address"] = StrVal(i.locatorAddress);

            s["Department"] = NameVal(db, "Department", i.DepartmentId);
            s["Warehouse"] = NameVal(db, "Ware House", i.InventoryOrg);
            s["Item_Group"] = NameVal(db, "Item Group", i.ItemGroupId);
            s["Procedure_Type"] = NameVal(db, "Procedure Type", i.Procedure_Type);
            s["Procedure_Time"] = StrVal(i.Procedure_Time);

            s["Doctor_Share"] = NumVal(i.Doctor_Share);
            s["Hospital_Share"] = NumVal(i.Hospital_Share);

            s["Active"] = BoolVal(i.Active);
            s["Services"] = BoolVal(i.Services);
            s["Is_Pharmacy_Item"] = BoolVal(i.IsPharmacyItem);
            s["Pharmacy_Item"] = BoolVal(i.Pharmacy_Item);
            s["Lab_OR_Radiology"] = BoolVal(i.LabOR_RadiologyCharges);
            s["Dental_Item"] = BoolVal(i.Dental_Item);
            s["Is_Batch"] = BoolVal(i.IsBatch);
            s["Saleable"] = BoolVal(i.Saleable);
            s["Purchaseable"] = BoolVal(i.Purchaseable);
            s["Consumable"] = BoolVal(i.Consumable);
            s["Finished_Product"] = BoolVal(i.Finished_Product);
            s["Is_Fixed_Asset"] = BoolVal(i.Isfixasset);
            s["Non_Stock_Item"] = BoolVal(i.IsNonStockItem);
            s["Locator"] = BoolVal(i.Locator);
            s["Refrigerator"] = BoolVal(i.Refregrator);
            s["Narcotics"] = BoolVal(i.Narcotics);
            s["Controller_Drug"] = BoolVal(i.Controller_Drug);
            s["OT_Procedure"] = BoolVal(i.OTProcedure);
            s["Hospital_Services"] = BoolVal(i.Hospital_Services);
            s["Billing_Required"] = BoolVal(i.Billing_Required);
            s["Lab_Required"] = BoolVal(i.Lab_Required);
            s["Pat_History_Required"] = BoolVal(i.Pat_History_Required);
            s["Fitness_Certificate"] = BoolVal(i.Fitness_Certificate);
            s["Bed_Services"] = BoolVal(i.Bed_Services);
            s["Lense_Required"] = BoolVal(i.Lense_Required);
            s["Procedure_Required"] = BoolVal(i.Procedure_Required);
            s["Other_Services"] = BoolVal(i.Other_Services);
            s["Infusion_Fluid"] = BoolVal(i.Infusion_Fluid);
            s["Additive_Dose"] = BoolVal(i.Additive_Dose);
            s["Short_Item"] = BoolVal(i.Short_Item);
            s["CathLab_Item"] = BoolVal(i.Is_CathLab);
            s["High_Risk"] = BoolVal(i.High_risk);
            s["Discount_Block"] = BoolVal(i.Discount_Block);
            s["Sehat_Card_Item"] = BoolVal(i.issehatCard_item);
            s["Pharmacy_Billing"] = BoolVal(i.IsPharmacyBilling);
            s["Doctor_Compulsory"] = BoolVal(i.Doctor_Compulsory);
            s["Share_Service"] = BoolVal(i.Is_ShareService);

            return s;
        }

        public static void WriteItemChangeLog(DataBaseDataContext db, INV_Item item, JavaScriptSerializer serializer)
        {
            if (item == null) return;

            var log = new INV_Item_Log
            {
                Item_ID = item.Item_ID,
                Master_Log = serializer.Serialize(BuildItemMasterSnapshot(item, db)),
                Details_Log = serializer.Serialize(new { Items = new List<object>() }),
                Loged_By = AppConfig.UserID,
                Log_Time = DateTime.Now
            };

            db.INV_Item_Logs.InsertOnSubmit(log);
        }

        private static JToken ParseLogJson(string json)
        {
            if (string.IsNullOrWhiteSpace(json)) return null;
            try { return JsonConvert.DeserializeObject<JToken>(json); }
            catch { return null; }
        }

        public static string GetItemLogsPayload(long itemId)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var logRows = (from l in db.INV_Item_Logs
                                   join u in db.aspnet_Users on l.Loged_By equals u.UserId into userJoin
                                   from u in userJoin.DefaultIfEmpty()
                                   where l.Item_ID == itemId
                                   orderby l.Log_Time, l.Log_Id
                                   select new
                                   {
                                       l.Log_Id,
                                       l.Log_Time,
                                       l.Master_Log,
                                       l.Details_Log,
                                       UserName = u != null ? u.UserName : null
                                   }).ToList();

                    var logs = logRows.Select(r => new
                    {
                        Log_Id = r.Log_Id,
                        TimeText = r.Log_Time.HasValue ? r.Log_Time.Value.ToString("dd MMM yyyy hh:mm tt") : "",
                        UserName = string.IsNullOrEmpty(r.UserName) ? "" : r.UserName,
                        Master = ParseLogJson(r.Master_Log),
                        Details = ParseLogJson(r.Details_Log)
                    }).ToList();

                    var item = db.INV_Items.FirstOrDefault(x => x.Item_ID == itemId);

                    object currentMaster = null;
                    if (item != null)
                    {
                        currentMaster = BuildItemMasterSnapshot(item, db);
                    }

                    return JsonConvert.SerializeObject(new
                    {
                        logs = logs,
                        current = new { master = currentMaster, details = new { Items = new List<object>() } }
                    });
                }
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new { error = ex.Message });
            }
        }
    }
}
