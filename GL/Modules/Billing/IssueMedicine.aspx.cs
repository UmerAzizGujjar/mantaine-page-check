using Newtonsoft.Json;
using PMS.Modules.PatientManagement;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static PMS.Inventory.Product;
using static Telerik.Web.UI.OrgChartStyles;
namespace PMS
{
    public partial class IssueMedicine : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }
        [WebMethod]
        public static string loadDoctors()
        {
            string result = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            var itemsList = (from i in db.HR_Employees select new { i.Emp_ID, name = i.Emp_Name.ToString() }).ToList();
            if (itemsList != null)
            {
                result = (new JavaScriptSerializer()).Serialize(itemsList);
            }
            return result;
        }
        [WebMethod]
        public static string GetSRQty()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var Qty = (from data in db.sys_Parms
                        where data.Name == "Sale Return Qty field"
                        select
                          data.Code
                        ).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(Qty);
        }
        [WebMethod]
        public static string CheckSaleReturnAllow()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var ups = (from St in db.aspnet_Users
                       where St.UserName == AppConfig.UserName
                       select St.AllowSaleReturn).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(ups);
        }
        [WebMethod]
        public static string CheckSaleReturnQueue()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var ups = (from St in db.aspnet_Users
                       where St.UserName == AppConfig.UserName
                       select St.Allow_Return_Queue).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(ups);
        }
        [WebMethod]
        public static string GetWardAndBed(int Pat_Id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var itemCodes = (from  ip in db.In_Patients 
                             where ip.In_Patient_ID == Pat_Id
                             select new
                             {
                                 Ward_Name =(from w in db.Ward_Definitions where w.Ward_ID == ip.Ward_ID select w.Ward_Type).FirstOrDefault(),
                                 ip.Bed_No,
                                 Patient_Discount_Type = db.GetDataValueName("Patient Type", ip.Patient_Discount_Type)
                             }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(itemCodes); 

        }

        [WebMethod]
        public static string CheckEditAdjustment()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var ups = (from St in db.aspnet_Users
                       where St.UserId == AppConfig.UserID
                       select St.adjustment_Allow).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(ups);
        }

        [WebMethod(EnableSession = true)]
        public static List<object> GetUserWarehouses()
        {
            if (HttpContext.Current.Session["UserId"] == null)
            {
                return new List<object>();
            }

            string userId = HttpContext.Current.Session["UserId"].ToString();

            Guid userGuid;
            if (!Guid.TryParse(userId, out userGuid))
            {
                return new List<object>();
            }

            using (var db = new DataBaseDataContext())
            {
                var list = (from wu in db.WareHouse_Wise_Users
                            join wud in db.WareHouse_Wise_User_Details
                                on wu.WareHouse_wise_User_Id equals wud.WareHouse_wise_User_Id
                            join dv in db.DataValues
                                on wud.WareHouse equals dv.DataValue_Name
                            where wu.User_Id == userGuid
                                  && dv.ValueSet_ID == 8
                            select new
                            {
                                Value = dv.DataValue_Name,  
                                Text = dv.DataValue_Description 
                            }).ToList();

                return list.Cast<object>().ToList();
            }
        }


        [WebMethod]
        public static string GetItemSalesHistory(int itemId)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var data = (from bd in db.Ar_Billing_Details
                                join b in db.Ar_Billings on bd.Bill_ID equals b.Bill_ID
                                where bd.Item_ID == itemId
                                   && bd.Item_Type == "Medicine"
                                   && (b.isCancel == false || b.isCancel == null)
                                orderby b.Bill_Date descending
                                select new
                                {
                                    Bill_No = b.Bill_No,
                                    Bill_Date = b.Bill_Date,
                                    Qty = bd.Qty,
                                    Rate = bd.Amount,
                                    Batch_No = bd.Batch_No,
                                    Patient_ID = b.Patient_ID,
                                    PatientName = (from p in db.Patients
                                                   where p.Patient_ID == b.Patient_ID
                                                   select p.Full_Name).FirstOrDefault()
                                }).Take(50).ToList();
                    return JsonConvert.SerializeObject(data);
                }
            }
            catch (Exception ex)
            {
                return "[]";
            }
        }


        [WebMethod]
        public static string GetItemCodesIPD(int Pat_Id)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var depAndDoc = (from ip in db.In_Patients
                             where ip.In_Patient_ID == Pat_Id
                             
                             select new
                             {
                                 ip.Doctor,
                                 ip.Department,
                                 ip.Panel_Company,
                                 ip.MR_No
                             }).FirstOrDefault();

            var itemCodes = (from ip in db.In_Patient_Medicines
                             where ip.Patient_ID == Pat_Id
                             && ip.Item_Code != null
                             && ip.Item_Code != "0"
                             && ip.Item_Code != ""
                                && (ip.is_rejected == false || ip.is_rejected == null)
                             select ip.Item_Code).ToList();

            var result = new
            {
                DoctorInfo = depAndDoc,
                ItemCodes = itemCodes
            };
            return (new JavaScriptSerializer()).Serialize(result); ;

        }
        [WebMethod]
        public static string GetItemCodesEMR(int Pat_Id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var itemCodes = (from  ip in db.In_Patient_Medicines 
                             where ip.Patient_ID == Pat_Id
                             && ip.Item_Code != null
                             && ip.Item_Code != "0"
                             && ip.Item_Code != ""
                             && (ip.is_rejected == false || ip.is_rejected == null)
                             select ip.Item_Code).ToList();
            return (new JavaScriptSerializer()).Serialize(itemCodes); ;

        }
        //[WebMethod]
        //public static string GetItemCodesOPD(int Pat_Id)
        //{
        //    DataBaseDataContext db = new DataBaseDataContext();

        //    var DepAndDoc = (from o in db.Out_Patients 
        //                     join p in db.Patients on o.Patient_ID equals p.Patient_ID
        //                     where o.Out_Patient_ID == Pat_Id
        //                     select new { o.Doctor_ID ,p.Patient_Main_Category}).FirstOrDefault();

        //    var itemCodes = (from  ip in db.In_Patient_Medicines join o in db.Out_Patients on ip.Patient_ID equals o.Out_Patient_ID                       
        //                     where o.Out_Patient_ID == Pat_Id
        //                     select ip.Item_Code).ToList();
        //    return (new JavaScriptSerializer()).Serialize(itemCodes); ;

        //}

        [WebMethod]
        public static string GetItemCodesfrombilling(int Bill_Id)
        {
            DataBaseDataContext db = new DataBaseDataContext();


            var itemCodes = (from ip in db.Ar_Billing_Details
                            
                             where ip.Bill_ID == Bill_Id && ip.Item_Type == "Medicine"
                                
                             select ip.Item_ID).ToList();

            var result = new
            {
                ItemCodes = itemCodes
            };

            return new JavaScriptSerializer().Serialize(result);
        }

        [WebMethod]
        public static string GetItemCodesfromTemplate(int Temp_Id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var itemCodes = (from ip in db.Pharmacy_Template_Details
                             where ip.Pharmacy_Template_Master_ID == Temp_Id     
                             select ip.ItemID).ToList();
            var result = new
            {
                ItemCodes = itemCodes
            };

            return new JavaScriptSerializer().Serialize(result);
        }

        [WebMethod]
        public static string GetItemCodesOPD(int Pat_Id)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var depAndDoc = (from o in db.Out_Patients
                             join p in db.Patients on o.Patient_ID equals p.Patient_ID
                             where o.Out_Patient_ID == Pat_Id
                             select new
                             {
                                 Doctor_ID = o.Doctor_ID,
                                 Patient_Main_Category = p.Patient_Main_Category
                             }).FirstOrDefault();

            var itemCodes = (from ip in db.In_Patient_Medicines
                             join o in db.Out_Patients
                                on ip.Patient_ID equals o.Out_Patient_ID
                             where o.Out_Patient_ID == Pat_Id
                             && ip.Item_Code != ""
                             && ip.Item_Code != "0"
                             && ip.Item_Code != null
                                && (ip.is_rejected == false || ip.is_rejected == null)
                             select ip.Item_Code).ToList();

            var result = new
            {
                DoctorInfo = depAndDoc,
                ItemCodes = itemCodes
            };

            return new JavaScriptSerializer().Serialize(result);
        }

        [WebMethod]
        public static string GetinvBatch(int med_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var ups = (from dv in db.INV_Items
                       where dv.Item_ID == med_id
                       select dv.IsBatch).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(ups);
        }


        [WebMethod]
        public static string GetOPDandIPDNO(int pat_id)
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                DateTime last24Hours = DateTime.Now.AddHours(-24);
                var OPD_NO = (from opd in db.Patients  join
                              ou in db.Out_Patients on opd.Patient_ID equals ou.Patient_ID
                           
                              where opd.Reg_PatId == pat_id                     

                              select new
                                 {
                                     Patient_No = "OPD-" + opd.Opd_No,
                                     Patient_ID = ou.Out_Patient_ID

                                 }).ToList();

                var IPD_NO = (from ipd in db.In_Patients
                              where ipd.Patient_ID == pat_id
                                             && (ipd.Discharge == null || ipd.Discharge == false)

                                             select new
                                             {
                                                 Patient_No = "IPD-" + ipd.IPD_No,
                                                 Patient_ID = ipd.In_Patient_ID
                                             }).ToList();
                var Emergency_NO = (from ipd in db.Emergencies
                                    join ep in db.Emergency_Patients on ipd.Reg_PatId equals ep.Patient_ID
                                    where ipd.Reg_PatId == pat_id
                                          && (ipd.Discharge == null || ipd.Discharge == false)
                                    select new
                                    {
                                        Patient_No = "EMR-" + ipd.Emergency_No,
                                        Patient_ID = ep.Emergency_ID
                                    }).ToList();

                var combinedResult = new
                {
                    OPD_NO = OPD_NO,
                    IPD_NO = IPD_NO,
                    Emergency_NO = Emergency_NO
                };
                data = new JavaScriptSerializer().Serialize(combinedResult);
            }
            return data;
        }


        public class BatchStock
        {
            public string BatchNum { get; set; }
            public int? uomqty { get; set; }
            //public string Source { get; set; }
        }
        [WebMethod]
        public static string Getbatch_grn(int med_id, string warehouse)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                HashSet<string> batchSet = new HashSet<string>();

                // Get blocked batches for this item and warehouse
                var blockedBatches = new HashSet<string>(
                    (from wb in db.Warehouse_Item_Batches
                     where wb.Item_ID == med_id
                     && wb.Warehouse_Id == warehouse
                     && wb.IsBlocked == true
                     select wb.Batch_Number).ToList()
                );

                var PICondition = (from sys in db.sys_Parms
                                   where sys.Name == "Direct PO ON Purchase Invoice"
                                   select sys.Code).FirstOrDefault();

                if (PICondition == "01")
                {
                    var grnBatches = (from ds in db.Purchase_Invoice_Details
                                      join grn in db.Purchase_Invoice_Masters on ds.PurchaseInvoiceId equals grn.PurchaseInvoiceId
                                      where ds.ItemId == med_id
                                      select ds.BatchNum).ToList();

                    foreach (var batch in grnBatches)
                    {
                        if (string.IsNullOrEmpty(batch)) continue;
                        if (blockedBatches.Contains(batch)) continue;

                        int stock = Convert.ToInt32(
                            db.GetPharmcyItemUomTotalStock(med_id, warehouse, batch)
                        );

                        if (stock > 0)
                            batchSet.Add(batch);
                    }
                }
                else
                {
                    var grnBatches = (from ds in db.GRN_Details
                                      join grn in db.GRN_Masters on ds.GRNId equals grn.GRN_ID
                                      where ds.Item_Id == med_id && grn.InvOrgId == warehouse
                                      select ds.BatchNum).ToList();

                    foreach (var batch in grnBatches)
                    {
                        if (string.IsNullOrEmpty(batch)) continue;
                        if (blockedBatches.Contains(batch)) continue;

                        int stock = Convert.ToInt32(
                            db.GetPharmcyItemUomTotalStock(med_id, warehouse, batch)
                        );

                        if (stock > 0)
                            batchSet.Add(batch);
                    }
                }

                // ---------- Stock Adjustment Batches ----------
                var stockAdjBatches = (from inv in db.INV_Stock_Adjustments
                                       where inv.Item_Id == med_id.ToString()
                                       && inv.Ware_House == warehouse
                                       && inv.Status == "Approved"
                                       select inv.Batch_No).ToList();

                foreach (var batch in stockAdjBatches)
                {
                    if (string.IsNullOrEmpty(batch)) continue;
                    if (blockedBatches.Contains(batch)) continue;

                    int stock = Convert.ToInt32(
                        db.GetPharmcyItemUomTotalStock(med_id, warehouse, batch)
                    );

                    if (stock > 0)
                        batchSet.Add(batch);
                }

                // ------------------------- Stock Transfer Batch -------------------
                var stocktransBatches = (from sti in db.Stock_Transfer_Items
                                         join st in db.Stock_Transfers on sti.Stock_Transfer_ID equals st.Stock_Transfer_ID
                                         where sti.Item_Id == med_id && st.Ware_House_To == warehouse
                                         && st.Status == "Approved"
                                         select sti.Batch_No).ToList();

                foreach (var batch in stocktransBatches)
                {
                    if (string.IsNullOrEmpty(batch)) continue;
                    if (blockedBatches.Contains(batch)) continue;

                    int stock = Convert.ToInt32(
                        db.GetPharmcyItemUomTotalStock(med_id, warehouse, batch)
                    );

                    if (stock > 0)
                        batchSet.Add(batch);
                }

                // ---------- Final Result ----------
                var result = batchSet.Select(b => new BatchStock
                {
                    BatchNum = b
                }).ToList();

                return new JavaScriptSerializer().Serialize(result);
            }
        }
        //[WebMethod]
        //public static string Getbatch_grn(int med_id,string warehouse)
        //{
        //    using (DataBaseDataContext db = new DataBaseDataContext())
        //    {
        //        HashSet<string> batchSet = new HashSet<string>();

        //        var PICondition = (from sys in db.sys_Parms where sys.Name == "Direct PO ON Purchase Invoice" select sys.Code).FirstOrDefault();

        //        if (PICondition == "01")
        //        {
        //            var grnBatches = (from ds in db.Purchase_Invoice_Details
        //                              join grn in db.Purchase_Invoice_Masters on ds.PurchaseInvoiceId equals grn.PurchaseInvoiceId
        //                              where ds.ItemId == med_id 
        //                              select ds.BatchNum).ToList();

        //            foreach (var batch in grnBatches)
        //            {
        //                int stock = Convert.ToInt32(
        //                    db.GetPharmcyItemUomTotalStock(med_id, warehouse, batch)
        //                );

        //                if (stock > 0)
        //                    batchSet.Add(batch);
        //            }

        //        }
        //        else
        //        {
        //            var grnBatches = (from ds in db.GRN_Details
        //                              join grn in db.GRN_Masters on ds.GRNId equals grn.GRN_ID
        //                              where ds.Item_Id == med_id && grn.InvOrgId == warehouse
        //                              select ds.BatchNum).ToList();

        //            foreach (var batch in grnBatches)
        //            {
        //                int stock = Convert.ToInt32(
        //                    db.GetPharmcyItemUomTotalStock(med_id, warehouse, batch)
        //                );

        //                if (stock > 0)
        //                    batchSet.Add(batch);
        //            }

        //        }


        //        // ---------- Stock Adjustment Batches ----------
        //        var stockAdjBatches = (from inv in db.INV_Stock_Adjustments
        //                               where inv.Item_Id == med_id.ToString() && inv.Ware_House == warehouse
        //                               && inv.Status == "Approved"
        //                               select inv.Batch_No).ToList();

        //        foreach (var batch in stockAdjBatches)
        //        {
        //            int stock = Convert.ToInt32(
        //                db.GetPharmcyItemUomTotalStock(med_id, warehouse, batch)
        //            );

        //            if (stock > 0)
        //                batchSet.Add(batch);
        //        }


        //        // ------------------------- Stock Transfer Batch -------------------
        //        var stocktransBatches = (from sti in db.Stock_Transfer_Items
        //                                 join st in db.Stock_Transfers on sti.Stock_Transfer_ID equals st.Stock_Transfer_ID
        //                               where sti.Item_Id == med_id && st.Ware_House_To == warehouse
        //                               && st.Status == "Approved"
        //                               select sti.Batch_No).ToList();

        //        foreach (var batch in stocktransBatches)
        //        {
        //            int stock = Convert.ToInt32(
        //                db.GetPharmcyItemUomTotalStock(med_id, warehouse, batch)
        //            );

        //            if (stock > 0)
        //                batchSet.Add(batch);
        //        }
        //        // ---------- Final Result ----------
        //        var result = batchSet.Select(b => new BatchStock
        //        {
        //            BatchNum = b
        //        }).ToList();

        //        return new JavaScriptSerializer().Serialize(result);
        //    }
        //}



        [WebMethod]
        public static string GetBatchNumbers(int itemId, string warehouse)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                HashSet<string> batchSet = new HashSet<string>();

                // Get blocked batches for this item and warehouse
                var blockedBatches = new HashSet<string>(
                    (from wb in db.Warehouse_Item_Batches
                     where wb.Item_ID == itemId
                     && wb.Warehouse_Id == warehouse
                     && wb.IsBlocked == true
                     select wb.Batch_Number).ToList()
                );

                var PICondition = (from sys in db.sys_Parms
                                   where sys.Name == "Direct PO ON Purchase Invoice"
                                   select sys.Code).FirstOrDefault();

                if (PICondition == "01")
                {
                    var grnBatches = (from ds in db.Purchase_Invoice_Details
                                      join grn in db.Purchase_Invoice_Masters on ds.PurchaseInvoiceId equals grn.PurchaseInvoiceId
                                      where ds.ItemId == itemId
                                      select ds.BatchNum).ToList();

                    foreach (var batch in grnBatches)
                    {
                        if (string.IsNullOrEmpty(batch)) continue;
                        if (blockedBatches.Contains(batch)) continue;

                        int stock = Convert.ToInt32(
                            db.GetPharmcyItemUomTotalStock(itemId, warehouse, batch)
                        );

                        if (stock > 0)
                            batchSet.Add(batch);
                    }
                }
                else
                {
                    var grnBatches = (from ds in db.GRN_Details
                                      join grn in db.GRN_Masters on ds.GRNId equals grn.GRN_ID
                                      where ds.Item_Id == itemId && grn.InvOrgId == warehouse
                                      select ds.BatchNum).ToList();

                    foreach (var batch in grnBatches)
                    {
                        if (string.IsNullOrEmpty(batch)) continue;
                        if (blockedBatches.Contains(batch)) continue;

                        int stock = Convert.ToInt32(
                            db.GetPharmcyItemUomTotalStock(itemId, warehouse, batch)
                        );

                        if (stock > 0)
                            batchSet.Add(batch);
                    }
                }

                // ---------- Stock Adjustment Batches ----------
                var stockAdjBatches = (from inv in db.INV_Stock_Adjustments
                                       where inv.Item_Id == itemId.ToString()
                                       && inv.Ware_House == warehouse
                                       && inv.Status == "Approved"
                                       select inv.Batch_No).ToList();

                foreach (var batch in stockAdjBatches)
                {
                    if (string.IsNullOrEmpty(batch)) continue;
                    if (blockedBatches.Contains(batch)) continue;

                    int stock = Convert.ToInt32(
                        db.GetPharmcyItemUomTotalStock(itemId, warehouse, batch)
                    );

                    if (stock > 0)
                        batchSet.Add(batch);
                }

                // ------------------------- Stock Transfer Batch -------------------
                var stocktransBatches = (from sti in db.Stock_Transfer_Items
                                         join st in db.Stock_Transfers on sti.Stock_Transfer_ID equals st.Stock_Transfer_ID
                                         where sti.Item_Id == itemId && st.Ware_House_To == warehouse
                                         && st.Status == "Approved"
                                         select sti.Batch_No).ToList();

                foreach (var batch in stocktransBatches)
                {
                    if (string.IsNullOrEmpty(batch)) continue;
                    if (blockedBatches.Contains(batch)) continue;

                    int stock = Convert.ToInt32(
                        db.GetPharmcyItemUomTotalStock(itemId, warehouse, batch)
                    );

                    if (stock > 0)
                        batchSet.Add(batch);
                }

                // ---------- Final Result ----------
                var result = batchSet.Select(b => new BatchStock
                {
                    BatchNum = b
                }).ToList();

                return new JavaScriptSerializer().Serialize(result);
            }
        }

        [WebMethod]
        public static string PendingPatients(string SearchString)
        {
            string result;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.Sp_GetLast24Hours_Medicines(SearchString).ToList();
                var ids = query.Select(x => x.In_Patient_Medicine_ID).ToList();
                var meta = db.In_Patient_Medicines
                    .Where(m => ids.Contains(m.In_Patient_Medicine_ID))
                    .Select(m => new { m.In_Patient_Medicine_ID, m.Remarks, m.Status })
                    .ToDictionary(m => m.In_Patient_Medicine_ID);

                var jsonArr = Newtonsoft.Json.Linq.JArray.FromObject(query);
                foreach (var item in jsonArr)
                {
                    int id = (int)item["In_Patient_Medicine_ID"];
                    if (meta.ContainsKey(id))
                    {
                        item["Remarks"] = meta[id].Remarks ?? "";
                        item["IsHold"] = meta[id].Status == "Hold";
                    }
                    else
                    {
                        item["Remarks"] = "";
                        item["IsHold"] = false;
                    }
                }
                result = jsonArr.ToString(Newtonsoft.Json.Formatting.None);
            }
            return result;
        }

        [WebMethod]
        public static string GetMedicineRemark(int MedicineId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var med = db.In_Patient_Medicines.FirstOrDefault(m => m.In_Patient_Medicine_ID == MedicineId);
                if (med == null)
                {
                    return JsonConvert.SerializeObject(new { Remarks = "", IsHold = false, Status = "" });
                }
                return JsonConvert.SerializeObject(new
                {
                    Remarks = med.Remarks ?? "",
                    IsHold = med.Status == "Hold",
                    Status = med.Status ?? ""
                });
            }
        }

        [WebMethod]
        public static string SaveMedicineRemark(int MedicineId, string Remarks, bool IsHold)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var med = db.In_Patient_Medicines.FirstOrDefault(m => m.In_Patient_Medicine_ID == MedicineId);
                    if (med == null)
                    {
                        return JsonConvert.SerializeObject(new { Success = false, Message = "Record not found." });
                    }
                    med.Remarks = Remarks ?? "";
                    if (med.Status != "rejected")
                    {
                        med.Status = IsHold ? "Hold" : null;
                    }
                    db.SubmitChanges();
                    return JsonConvert.SerializeObject(new { Success = true, Message = "Remarks saved successfully." });
                }
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new { Success = false, Message = "Error: " + ex.Message });
            }
        }
       
        [WebMethod]
        public static string GetItemList_WareHouseWise(string warehouse, string SearchString)
        {
            // Same rows/columns as sp_GetItemList_WareHouseWise, but the first 100 (200 when searching) items are picked
            // BEFORE their stock is totalled from vwBatch_Ledger - the proc totalled every pharmacy item of the warehouse
            // first and then kept 100 (3-6 s per search). Purchase_Rate (a heavy running-average function per row) is
            // not computed here any more; the page asks for it separately through GetItemListRates so the list appears at once.
            string search = (SearchString ?? "").Trim();
            bool hasSearch = search != "";
            string sql = @"
DECLARE @wh varchar(50) = @WareHouse;   -- same type as the ledger column so the comparison can use its indexes
;WITH Sel AS (
    SELECT TOP (" + (hasSearch ? 200 : 100) + @") i.Item_ID, i.Description, i.Item_Code, i.InventoryOrg, i.Manufacture_Company, i.locatorAddress
    FROM INV_Items i
    WHERE i.IsPharmacyItem = 1
      AND (i.InventoryOrg = @WareHouse
           OR EXISTS (SELECT 1 FROM Item_Warehouse_Mapping m WHERE m.Item_ID = i.Item_ID AND m.Warehouse_Id = @WareHouse))"
      + (hasSearch ? @"
      AND (i.Description LIKE '%' + @Search + '%' OR i.Item_Code LIKE '%' + @Search + '%')" : "") + @"
    ORDER BY i.Item_Code, i.Item_ID
),
-- stock is totalled on the raw ledger columns first; the warehouse NAME (a function call) is then looked up once per
-- group instead of once per ledger row (the view calls it for every row when WareHouse_Name is selected)
Agg AS (
    -- only the stock of the SELECTED warehouse (the ledger rows of the item's other warehouses are not listed)
    SELECT s.Item_ID, vl.UOM_Qty, SUM(vl.Qty) AS Qty
    FROM Sel s
    LEFT JOIN vwBatch_Ledger vl ON vl.Item_ID = s.Item_ID AND vl.Ware_House = @wh
    GROUP BY s.Item_ID, vl.UOM_Qty
)
SELECT i.Description,
       i.Item_Code,
       i.Item_ID,
       ISNULL(dbo.GetDataValueName('Ware house', @wh), '') AS WareHouse_Name,
       @WareHouse AS Ware_House,   -- the warehouse being browsed (= InventoryOrg for the item's own warehouse; an item mapped in from another warehouse is sold from this one)
       ISNULL(a.Qty, 0) AS Qty,
       ISNULL(dbo.GetDataValueName('Manufacture Company', i.Manufacture_Company), '') AS Manufacturer_Name,
       CAST(0 AS float) AS Purchase_Rate,
       ISNULL(i.locatorAddress, '') AS Locator,
       ISNULL(a.UOM_Qty, 0) AS UOM_Qty,
       @wh AS Ledger_Ware_House
FROM Sel i
JOIN Agg a ON a.Item_ID = i.Item_ID
ORDER BY i.Item_Code, i.Item_ID";

            DataTable dt = DBClass.getDataTable(sql, DBClass.Param("@WareHouse", warehouse), DBClass.Param("@Search", search));

            var rows = new List<Dictionary<string, object>>();
            foreach (DataRow dr in dt.Rows)
            {
                var row = new Dictionary<string, object>();
                foreach (DataColumn col in dt.Columns)
                {
                    row[col.ColumnName] = dr[col] == DBNull.Value ? null : dr[col];
                }
                rows.Add(row);
            }
            return new JavaScriptSerializer().Serialize(rows);
        }

        // Purchase rate (last average rate) for the rows shown in the Item List. pairs = "itemId|ledgerWarehouse;itemId|ledgerWarehouse"
        [WebMethod]
        public static string GetItemListRates(string pairs)
        {
            var list = new List<KeyValuePair<int, string>>();
            foreach (string p in (pairs ?? "").Split(new[] { ';' }, StringSplitOptions.RemoveEmptyEntries))
            {
                string[] a = p.Split('|');
                int id;
                if (a.Length == 2 && int.TryParse(a[0], out id))
                {
                    list.Add(new KeyValuePair<int, string>(id, a[1]));
                }
            }
            if (list.Count == 0 || list.Count > 500) return "[]";

            var values = new List<string>();
            var prm = new List<SqlParameter>();
            for (int i = 0; i < list.Count; i++)
            {
                values.Add("(@i" + i + ", @w" + i + ")");
                prm.Add(DBClass.Param("@i" + i, list[i].Key));
                prm.Add(DBClass.Param("@w" + i, string.IsNullOrEmpty(list[i].Value) ? null : list[i].Value));
            }

            string sql = "SELECT x.Item_ID, x.Wh AS Ware_House, ISNULL(dbo.fn_GetLastAvgRate(x.Item_ID, x.Wh), 0) AS Purchase_Rate FROM (VALUES "
                         + string.Join(",", values) + ") x(Item_ID, Wh)";
            DataTable dt = DBClass.getDataTable(sql, prm.ToArray());

            var rows = new List<Dictionary<string, object>>();
            foreach (DataRow dr in dt.Rows)
            {
                rows.Add(new Dictionary<string, object>
                {
                    { "Item_ID", dr["Item_ID"] },
                    { "Ware_House", dr["Ware_House"] == DBNull.Value ? "" : dr["Ware_House"] },
                    { "Purchase_Rate", dr["Purchase_Rate"] }
                });
            }
            return new JavaScriptSerializer().Serialize(rows);
        }
        [WebMethod]
        public static string GetReturnMedicineDetail(int Bill_Id, int Item_Id)
        {
            string result = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.spMedicineReturnfromIPDDetails(Bill_Id, Item_Id).ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
        }
        [WebMethod]
        public static string GetReturnMedicine(int Bill_Id)
        {
            string result = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            var billdetails = (from i in db.Ar_Billings
                               where i.Bill_ID == Bill_Id && (i.isCancel == false || i.isCancel == null)
                               select new
                               {
                                   i.Bill_No,
                                   i.Patient_ID,
                                   i.Ware_House,
                                   i.Bill_ID

                               }).ToList();
            if (billdetails != null)
            {
                result = (new JavaScriptSerializer()).Serialize(billdetails);
            }
            return result;
        }

        [WebMethod]
        public static string ReturnPatients(string SearchString)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = from ipm in db.In_Patient_Medicines
                            join ipd in db.In_Patients
                                on ipm.Patient_ID equals ipd.In_Patient_ID

                            join rp in db.Reg_patients
                                on ipd.Patient_ID equals rp.pat_id

                            join ab in db.Ar_Billings
                                on ipd.In_Patient_ID equals ab.In_Patient_ID

                            // bill line must be the same medicine (matches spMedicineReturnfromIPDDetails)
                            join abd in db.Ar_Billing_Details
                                on ab.Bill_ID equals abd.Bill_ID
                            where abd.Item_ID == Convert.ToInt32(ipm.Item_Code)
                                  && (ab.isCancel == false || ab.isCancel == null)

                            join wd in db.Ward_Definitions
                                on ipd.Ward_ID equals wd.Ward_ID into wdGroup
                            from wd in wdGroup.DefaultIfEmpty()

                            where (ipm.Rtn_Qty ?? 0) > 0
                                  && ipm.Transaction_Type == "InPatient"

                                  // ✅ NOT EXISTS equivalent
                                  && !db.Pharmacy_SaleReturns
                                        .Join(db.Pharmacy_SaleReturn_Details,
                                              pr => pr.Return_ID,
                                              prd => prd.Return_ID,
                                              (pr, prd) => new { pr, prd })
                                        .Any(x =>
                                            x.pr.Patient_id == ipd.Patient_ID
                                            && x.prd.Item_ID == Convert.ToInt32(ipm.Item_Code)
                                            && x.prd.Qty == ipm.Rtn_Qty
                                        )

                                  // ✅ SEARCH FILTER
                                  && (
                                        string.IsNullOrEmpty(SearchString)
                                        || rp.Full_Name.Contains(SearchString)
                                        || rp.Father_Name.Contains(SearchString)
                                        || ab.Bill_No.Contains(SearchString)
                                        || abd.Item_Name.Contains(SearchString)
                                        || rp.pat_id.ToString().Contains(SearchString)
                                        || rp.mr_no_sequence.ToString().Contains(SearchString)
                                  )

                            select new
                            {
                                ipm.In_Patient_Medicine_ID,
                                ipm.Item_Code,
                                ipd.In_Patient_ID,
                                rp.pat_id,
                                rp.Full_Name,
                                rp.Father_Name,
                                Bill_ID = (int?)ab.Bill_ID,
                                ab.Bill_No,
                                Bill_Details_ID = (int?)abd.Bill_Details_ID,
                                abd.Item_Name,
                                rp.mr_no_sequence,
                                ab.Invoice_Date,
                                ab.Seq_InvoiceNo,
                                Ward_Name = wd.Ward_Type,
                                ipd.Bed_No
                            };

                return JsonConvert.SerializeObject(query.ToList());
            }
        }
        //[WebMethod]
        //public static string ReturnPatients(string SearchString)
        //{
        //    using (DataBaseDataContext db = new DataBaseDataContext())
        //    {
        //        var query = from ipm in db.In_Patient_Medicines
        //                    join ipd in db.In_Patients
        //                        on ipm.Patient_ID equals ipd.In_Patient_ID

        //                    join rp in db.Reg_patients
        //                        on ipd.Patient_ID equals rp.pat_id

        //                    join ab in db.Ar_Billings
        //                        on ipd.In_Patient_ID equals ab.In_Patient_ID into abGroup
        //                    from ab in abGroup.DefaultIfEmpty()

        //                    join abd in db.Ar_Billing_Details
        //                        on ab.Bill_ID equals abd.Bill_ID into abdGroup
        //                    from abd in abdGroup.DefaultIfEmpty()

        //                    where (ipm.Rtn_Qty ?? 0) > 0
        //                          && ipm.Transaction_Type == "InPatient"
        //                          && ipm.Item_Code ==Convert.ToString( abd.Item_ID)
        //                          && (
        //                                string.IsNullOrEmpty(SearchString)
        //                                || rp.Full_Name.Contains(SearchString)
        //                                || rp.Father_Name.Contains(SearchString)
        //                                || ab.Bill_No.Contains(SearchString)
        //                                || abd.Item_Name.Contains(SearchString)
        //                                || rp.pat_id.ToString().Contains(SearchString)
        //                                || rp.mr_no_sequence.ToString().Contains(SearchString)
        //                             )

        //                    select new
        //                    {
        //                        ipm.In_Patient_Medicine_ID,
        //                        ipm.Item_Code,
        //                        ipd.In_Patient_ID,
        //                        rp.pat_id,
        //                        rp.Full_Name,
        //                        rp.Father_Name,
        //                        ab.Bill_ID,
        //                        ab.Bill_No,
        //                        abd.Bill_Details_ID,
        //                        abd.Item_Name,
        //                        rp.mr_no_sequence,
        //                        ab.Invoice_Date,
        //                        ab.Seq_InvoiceNo,
        //                        Ward_Name = (from w in db.Ward_Definitions where w.Ward_ID == ipd.Ward_ID select w.Ward_Type).FirstOrDefault(),
        //                        ipd.Bed_No
        //                    };

        //        return JsonConvert.SerializeObject(query.ToList());
        //    }
        //}
        [WebMethod]
        public static string RejectMedicineRequest(string MedicineId)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    int medicineID = Convert.ToInt32(MedicineId);

                    // First, get the medicine to find its Patient_ID (which is the Visit ID)
                    var medicineRecord = db.In_Patient_Medicines
                        .FirstOrDefault(m => m.In_Patient_Medicine_ID == medicineID);

                    if (medicineRecord == null)
                    {
                        return new JavaScriptSerializer().Serialize(new
                        {
                            Success = false,
                            Message = "Record not found."
                        });
                    }

                    // Get ALL medicines for the SAME visit (same Patient_ID)
                    var allMedicinesForVisit = db.In_Patient_Medicines
                        .Where(m => m.Patient_ID == medicineRecord.Patient_ID
                                 && (m.Status == null || m.Status != "rejected"))
                        .ToList();

                    if (!allMedicinesForVisit.Any())
                    {
                        return new JavaScriptSerializer().Serialize(new
                        {
                            Success = false,
                            Message = "No pending medicines found for this visit."
                        });
                    }

                    // Check if already rejected
                    bool alreadyRejected = allMedicinesForVisit.All(m => m.Status == "rejected");
                    if (alreadyRejected)
                    {
                        return new JavaScriptSerializer().Serialize(new
                        {
                            Success = false,
                            Message = "Already rejected."
                        });
                    }

                    // Reject ALL medicines for this visit
                    int rejectedCount = 0;
                    foreach (var med in allMedicinesForVisit)
                    {
                        med.Status = "rejected";
                        med.is_rejected = true;
                        med.reject_by = AppConfig.UserID;
                        med.close_time = DateTime.Now;
                      
                    }

                    db.SubmitChanges();

                    return new JavaScriptSerializer().Serialize(new
                    {
                        Success = true,
                        Message = $"{rejectedCount} medicine request(s) Closed successfully.",
                        RejectedCount = rejectedCount
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new
                {
                    Success = false,
                    Message = "Error: " + ex.Message
                });
            }
        }
        [WebMethod]
        public static string Preview(string search)
        {
            string result;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.SpPharmacyList(search).ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();

            }
            return result;
        }

        [WebMethod]
        public static string loadMedicine(string ItemName)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.spPharmacyitem(ItemName).ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
        }

        [WebMethod]
        public static string MedicineDetail(int itemId, string hdndiscountType, string Batch,string warehouse)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.spMedicinesDetails(itemId, hdndiscountType, Batch, warehouse).ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
        }

        [WebMethod]
        public static string MedicineDetailforListItems(int itemId, string warehouse)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.spMedicinesDetailsforListitems(itemId, warehouse).ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
        }

     
        [WebMethod]
        public static string MedicineDetailgetfromOPD(int itemId,string warehouse, int patientId = 0, string visitType = "")
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.spMedicinesDetailsfromopd(itemId,patientId,warehouse,visitType).ToList();
                result = (new JavaScriptSerializer()).Serialize(query);
            }
            return result;
        }

        public static bool IsValidQuantity(int itemId, int sellingQty, int inPatientId, string transType)
        {
            // ONLY validate for IPD Patient
            if (transType != "IPD Patient")
            {
                return true;
            }

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var medicineRecord = db.In_Patient_Medicines
                    .FirstOrDefault(m => m.Patient_ID == inPatientId
                        && m.Item_Code == itemId.ToString()
                        && (m.is_rejected == null || m.is_rejected == false));

                if (medicineRecord == null) return true;

                int requestedQty = Convert.ToInt32(medicineRecord.Req_Qty ?? 0);

                // If no quantity requested, skip validation
                if (requestedQty == 0) return true;

                int receivedQty = Convert.ToInt32(medicineRecord.Rcv_Qty ?? 0);
                int availableQty = requestedQty - receivedQty;

                // Check if already fully received
                if (availableQty <= 0)
                {
                    return false; // All requested quantity has already been issued
                }

                // Check if selling quantity exceeds available quantity
                return sellingQty <= availableQty;
            }
        }
        [WebMethod]
        public static string ValidateIPDQuantities(string Parameters)
        {
            try
            {
                JavaScriptSerializer JSS = new JavaScriptSerializer();
                var data = JSS.Deserialize<Medicines>(Parameters);

                // ONLY validate for IPD Patients
                if (data.TransType != "IPD Patient")
                {
                    return (new JavaScriptSerializer()).Serialize(new { Success = true, Message = "" });
                }

                // Check if there are any items with Req_Qty > 0
                bool hasReqQty = false;
                foreach (var dtls in data.Save_list)
                {
                    if (dtls.Req_qty > 0)
                    {
                        hasReqQty = true;
                        break;
                    }
                }

                // If no items have Req_Qty > 0, skip validation
                if (!hasReqQty)
                {
                    return (new JavaScriptSerializer()).Serialize(new { Success = true, Message = "" });
                }

                // Validate each item using the database
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    foreach (var dtls in data.Save_list)
                    {
                        int Item_Id = dtls.Itemid == 0 ? dtls.hdnItemid : dtls.Itemid;
                        int qty = dtls.Qty;
                        int reqQty = dtls.Req_qty ?? 0;

                        // Only validate items that have requested quantity > 0
                        if (reqQty > 0 && Item_Id > 0 && qty > 0)
                        {
                            // Get the actual record from database to check received quantity
                            var medicineRecord = db.In_Patient_Medicines
                                .FirstOrDefault(m => m.Patient_ID == data.In_Patient_ID
                                    && m.Item_Code == Item_Id.ToString()
                                    && (m.is_rejected == null || m.is_rejected == false));

                            if (medicineRecord != null)
                            {
                                int dbRequestedQty = Convert.ToInt32(medicineRecord.Req_Qty ?? 0);
                                int receivedQty = Convert.ToInt32(medicineRecord.Rcv_Qty ?? 0);
                                int availableQty = dbRequestedQty - receivedQty;

                                // Check if already fully issued
                                if (availableQty <= 0)
                                {
                                    return (new JavaScriptSerializer()).Serialize(new
                                    {
                                        Success = false,
                                        Message = $"Cannot issue {dtls.ItemName}. All requested quantity ({dbRequestedQty} units) has already been issued."
                                    });
                                }

                                // Check if selling quantity exceeds available quantity
                                if (qty > availableQty)
                                {
                                    return (new JavaScriptSerializer()).Serialize(new
                                    {
                                        Success = false,
                                        Message = $"Cannot sell {qty} units of {dtls.ItemName}. Only {availableQty} units remaining (Requested: {dbRequestedQty}, Already Issued: {receivedQty})."
                                    });
                                }
                            }
                            else
                            {
                                // If no record found in database but Req_qty > 0 from frontend
                                return (new JavaScriptSerializer()).Serialize(new
                                {
                                    Success = false,
                                    Message = $"Cannot issue {dtls.ItemName}. Request not found or already processed."
                                });
                            }
                        }
                    }
                }

                return (new JavaScriptSerializer()).Serialize(new { Success = true, Message = "" });
            }
            catch (Exception ex)
            {
                return (new JavaScriptSerializer()).Serialize(new { Success = false, Message = ex.Message });
            }
        }
        // Method 2: Update received quantity (only for IPD with Req_Qty > 0)
        public static void UpdateReceivedQuantity(int itemId, int receivedQty, int inPatientId)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var medicineRecord = db.In_Patient_Medicines
                        .FirstOrDefault(m => m.Patient_ID == inPatientId
                            && m.Item_Code == itemId.ToString()
                            && (m.is_rejected == null || m.is_rejected == false));

                    if (medicineRecord != null)
                    {
                        int requestedQty = Convert.ToInt32(medicineRecord.Req_Qty ?? 0);

                        // Only update if requested quantity > 0
                        if (requestedQty > 0)
                        {
                            decimal currentRcv = medicineRecord.Rcv_Qty ?? 0;
                            medicineRecord.Rcv_Qty = currentRcv + receivedQty;
                            if (medicineRecord.Issue_Date == null)
                            {
                                medicineRecord.Issue_Date = DateTime.Now;
                            }
                            db.SubmitChanges();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error: {ex.Message}");
            }
        }
        [WebMethod]
        public static string GetOutPatientIDByOPDNo(string opdNo)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

                // Single query with join
                var outPatientID = (from p in db.Patients
                                    join op in db.Out_Patients on p.Patient_No equals op.Patient_ID
                                    where p.Opd_No.ToString() == opdNo
                                    orderby op.Out_Patient_ID descending
                                    select op.Out_Patient_ID)
                                   .FirstOrDefault();

                return   outPatientID.ToString() ;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"GetOutPatientIDByOPDNo Error: {ex.Message}");
                return "0";
            }
        }
        //public class BatchStock
        //{
        //    public string BatchNum { get; set; }
           
        //}
        [WebMethod]
        public static string GetBatchNumbersforReturn(int itemId)
        {
            var batchStockListgrn = new List<BatchStock>();
            var batchStockListst = new List<BatchStock>();

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var grnResult = (from dv in db.INV_Items
                                 join ds in db.GRN_Details
                                 on dv.Item_ID equals ds.Item_Id
                                 where ds.Item_Id == itemId
                                 select new
                                 {
                                     BatchNum = ds.BatchNum
                                 }).ToList();

                foreach (var batchNum in grnResult)
                {

                    batchStockListgrn.Add(new BatchStock
                    {
                        BatchNum = batchNum.BatchNum,

                    });

                }
                var stockAdjustmentResult = (from inv in db.INV_Stock_Adjustments
                                             where inv.Item_Id == Convert.ToString(itemId)
                                             && inv.Status == "Approved"
                                             select new
                                             {
                                                 BatchNum = inv.Batch_No
                                             }).ToList();

                foreach (var batchNum in stockAdjustmentResult)
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

            return new JavaScriptSerializer().Serialize(combinedResult);
        }
        [WebMethod]
        public static string GetStockByBatch(int itemId, string hdndiscountType, string batchNumber,string warehouse)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.spMedicinesDetails(itemId, hdndiscountType, batchNumber, warehouse).ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
        }

        [WebMethod]
        public static string GetMedicineDetailsBatch(string itemIds, string warehouse, int patientId, string visitType, string hdndiscountType)
        {
            var ids = new List<int>();
            foreach (string s in (itemIds ?? "").Split(','))
            {
                int itemId;
                if (int.TryParse((s ?? "").Trim(), out itemId) && itemId > 0) ids.Add(itemId);
            }

            // key by position so duplicate item codes keep producing duplicate rows (same as old serial loop)
            var map = new System.Collections.Concurrent.ConcurrentDictionary<int, Newtonsoft.Json.Linq.JObject>();
            System.Threading.Tasks.Parallel.For(0, ids.Count,
                new System.Threading.Tasks.ParallelOptions { MaxDegreeOfParallelism = 8 },
                i =>
                {
                    int itemId = ids[i];
                    try
                    {
                        var detail = Newtonsoft.Json.Linq.JArray.Parse(MedicineDetailgetfromOPD(itemId, warehouse, patientId, visitType));
                        if (detail.Count == 0) return;
                        var batches = Newtonsoft.Json.Linq.JArray.Parse(GetBatchNumbers(itemId, warehouse));
                        string firstBatch = batches.Count > 0 ? (string)batches[0]["BatchNum"] : "";
                        var stock = Newtonsoft.Json.Linq.JArray.Parse(GetStockByBatch(itemId, hdndiscountType ?? "", firstBatch, warehouse));
                        map[i] = new Newtonsoft.Json.Linq.JObject
                        {
                            ["detail"] = detail[0],
                            ["batches"] = batches,
                            ["stock"] = stock.Count > 0 ? stock[0] : new Newtonsoft.Json.Linq.JObject()
                        };
                    }
                    catch { }
                });

            var arr = new Newtonsoft.Json.Linq.JArray();
            for (int i = 0; i < ids.Count; i++)
            {
                Newtonsoft.Json.Linq.JObject obj;
                if (map.TryGetValue(i, out obj)) arr.Add(obj);
            }
            return arr.ToString(Newtonsoft.Json.Formatting.None);
        }

        public class Medicines
        {
            public int Bill_ID { get; set; }
            public string Patient_ID { get; set; }
            public string CustomerName { get; set; }
            public string warehouse { get; set; }
            public string TransType { get; set; }
            public string ReferBy { get; set; }
            public string Dept { get; set; }
            public decimal totalPayable { get; set; }
            public decimal DiscAmnt { get; set; }
            public decimal MasterDiscount { get; set; }
            public decimal flatdisc { get; set; }
            public decimal DiscPercent { get; set; }
            public decimal AmntReceived { get; set; }
            public decimal Total_CGS { get; set; }
            public decimal BalanceAmount { get; set; }
            public decimal linediscount { get; set; }
            public string invNumber { get; set; }
            public int In_Patient_ID { get; set; }

            public string Panel_Id { get; set; }
            public int BankAccountId { get; set; }
            public List<Medicindetails> Save_list { get; set; }
        }

        public class Medicindetails
        {
            public int Itemid { get; set; }
            public int hdnItemid { get; set; }
            public string ItemName { get; set; }
            public decimal Amount { get; set; }
            public decimal DiscPer { get; set; }
            public decimal DiscAmount { get; set; }
            public decimal LineDiscount { get; set; }
            public decimal NetAmount { get; set; }
            public int Qty { get; set; }
            public decimal Stock { get; set; }
            public string batchno { get; set; }
            public decimal CGSAmount { get; set; }

            public string Remarks { get; set; }
            public int? Req_qty { get; set; }
        }

        [WebMethod]
        public static string SaveRecord(string Parameters, string Rbtn, string UserId, int patId)
        {
            SaveResult result = new SaveResult();
            try
            {
                string billId = Save(Parameters, Rbtn, UserId, patId);
                result.Success = true;
                result.BillId = billId;
            }
            catch (Exception ex)
            {
                result.Success = false;
                result.Message = ex.Message;
            }
            return (new JavaScriptSerializer()).Serialize(result);
        }

        public class SaveResult
        {
            public bool Success { get; set; }
            public string BillId { get; set; }
            public string Message { get; set; }
        }

        private const string PharmacyStockLockResource = "Pharmacy_Stock_Save";
        private const int PharmacyLockMaxRetries = 3;
        private const int PharmacyLockRetryDelayMs = 400;
        private const int PharmacyLockTimeoutMs = 5000;

        public static string Save(string Parameters, string Rbtn, string UserId, int patId)
        {
            Exception lastError = null;
            for (int attempt = 1; attempt <= PharmacyLockMaxRetries; attempt++)
            {
                try
                {
                    return SaveInternal(Parameters, Rbtn, UserId, patId);
                }
                catch (Exception ex) when (IsLockContention(ex))
                {
                    lastError = ex;
                    System.Threading.Thread.Sleep(PharmacyLockRetryDelayMs);
                }
            }
            throw new Exception("Another pharmacy bill is being saved by a different user. Please try again in a moment.", lastError);
        }

        private static bool IsLockContention(Exception ex)
        {
            if (ex == null || ex.Message == null) return false;
            string msg = ex.Message;
            return msg.Contains("Pharmacy stock is currently locked") ||
                   msg.Contains("Lock request time out period exceeded") ||
                   msg.Contains("could not be obtained");
        }

        private static string SaveInternal(string Parameters, string Rbtn, string UserId, int patId)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            JavaScriptSerializer JSS = new JavaScriptSerializer();
            var data = JSS.Deserialize<Medicines>(Parameters);
            decimal Total_CGSS = 0;
            Ar_Billing newBill;

            // sys_param: "approval pharmacy" = "01" -> run approve pharmacy,
            // otherwise skip the approval function.
            bool approvePharmacy = db.sys_Parms.Any(p => p.Name == "approval pharmacy" && p.Code == "01");

            if (db.Connection.State != ConnectionState.Open)
                db.Connection.Open();

            using (db.Transaction = db.Connection.BeginTransaction(IsolationLevel.Serializable))
            {
                try
                {
                    AcquirePharmacyLock(db);

                    int getmaxno = db.Ar_Billings.Where(p => p.Creation_Date.Value.Year == DateTime.Now.Year
                                          && p.IsPharmacy == true
                                          && p.Creation_Date.Value.Month == DateTime.Now.Month
                                          && p.Creation_Date.Value.Day == DateTime.Now.Day).Count() + 1;

                    newBill = SaveBillCore(db, data, Rbtn, UserId, patId, getmaxno, ref Total_CGSS, out int newBillId);

                    db.Transaction.Commit();

                    // sys_param "approval pharmacy" = "01" -> approve pharmacy, otherwise skip
                    if (approvePharmacy)
                    {
                        ApprovePhramcy(newBillId.ToString());
                    }

                    PostToFBRIfEnabled(newBillId);

                    return newBillId.ToString();
                }
                catch
                {
                    try
                    {
                        if (db.Transaction != null) db.Transaction.Rollback();
                    }
                    catch { }
                    throw;
                }
                finally
                {
                    ReleasePharmacyLock(db);
                }
            }
        }

        private static void PostToFBRIfEnabled(int billId)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var FBR_Pharmacy = db.sys_Parms.FirstOrDefault(p => p.Name == "FBR_Pharmacy")?.Code;
                    if (FBR_Pharmacy != "01") return;

                    var detailIds = db.Ar_Billing_Details
                        .Where(b => b.Bill_ID == billId)
                        .Select(b => b.Bill_Details_ID)
                        .ToList();

                    if (detailIds.Count > 0)
                    {
                        FBRBillingView.PostToFBR(billId, detailIds);
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("FBR post failed: " + ex.Message);
            }
        }

        private static void AcquirePharmacyLock(DataBaseDataContext db)
        {
            int lockResult;
            using (SqlCommand cmd = (SqlCommand)db.Connection.CreateCommand())
            {
                cmd.Transaction = (SqlTransaction)db.Transaction;
                cmd.CommandText = "DECLARE @r INT; EXEC @r = sp_getapplock @Resource=@res, @LockMode='Exclusive', @LockOwner='Session', @LockTimeout=@lt; SELECT @r;";
                cmd.Parameters.AddWithValue("@res", PharmacyStockLockResource);
                cmd.Parameters.AddWithValue("@lt", PharmacyLockTimeoutMs);
                lockResult = Convert.ToInt32(cmd.ExecuteScalar());
            }
            if (lockResult < 0)
            {
                throw new Exception("Pharmacy stock is currently locked by another save operation. Please try again.");
            }
        }

        private static void ReleasePharmacyLock(DataBaseDataContext db)
        {
            try
            {
                if (db.Transaction == null) return;
                using (SqlCommand cmd = (SqlCommand)db.Connection.CreateCommand())
                {
                    cmd.Transaction = (SqlTransaction)db.Transaction;
                    cmd.CommandText = "EXEC sp_releaseapplock @Resource=@res, @LockOwner='Session';";
                    cmd.Parameters.AddWithValue("@res", PharmacyStockLockResource);
                    cmd.ExecuteNonQuery();
                }
            }
            catch { }
        }

        private static Ar_Billing SaveBillCore(DataBaseDataContext db, Medicines data, string Rbtn, string UserId, int patId, int getmaxno, ref decimal Total_CGSS, out int newBillId)
        {
            Ar_Billing newBill;

            if (data.Bill_ID == 0)
            {
                newBill = new Ar_Billing();
                newBill.Company_ID = AppConfig.Company_ID;
                newBill.Created_By = AppConfig.UserID;
                newBill.Creation_Date = DateTime.Now;
                newBill.Bill_No = DBClass.GetNewNumber("Bill_No", "Ar_Billings", "").ToString();
            }
            else
            {
                newBill = db.Ar_Billings.Where(b => b.Bill_ID == data.Bill_ID).FirstOrDefault();
                newBill.Company_ID = AppConfig.Company_ID;
                newBill.Updated_By = AppConfig.UserID;
                newBill.Updation_Date = DateTime.Now;
            }

            newBill.Invoice_No = getmaxno;
            newBill.Invoice_Date = DateTime.Now;
            newBill.Seq_InvoiceNo = db.GetSale_InoviceNo();
            newBill.Discount_Percentage = data.DiscPercent;
            newBill.Discount_Amount = data.DiscAmnt;
            newBill.Master_Discount = data.MasterDiscount;
            newBill.Disc_Adjustment = data.flatdisc;
            newBill.Total_Amount = data.totalPayable;
            newBill.Received_Amount = data.AmntReceived;
            newBill.Balance_Amount = data.BalanceAmount;
            newBill.Referred_By = data.ReferBy;
            newBill.line_disc = data.linediscount;
            newBill.pharmacy_Department = data.Dept;
            newBill.Patient_ID = patId;
            newBill.Ware_House = data.warehouse;
            newBill.In_Patient_ID = data.In_Patient_ID;
            newBill.Panel_Id = Convert.ToInt32(data.Panel_Id);
            newBill.Sale_Return = "Return Against" + '-' + data.invNumber;
            newBill.UserID = Convert.ToInt32(UserId);
            newBill.IsPharmacy = true;

            var checkingcondition = db.sys_Parms
                .Where(a => a.Name == "Amount Recevied For Pharmcay")
                .Select(a => a.Code)
                .FirstOrDefault();

            if (checkingcondition == "002")
            {
                newBill.Balance_Amount = 0;
                newBill.Received_Amount = data.AmntReceived;
            }
            newBill.Received_Amount = data.AmntReceived;
            if (Rbtn == "rbtnHospital")
                newBill.Received_Amount = 0; // panel bills are settled with the panel, nothing received at the counter
            newBill.Pharma_trans_Type = data.TransType;
            newBill.Main_Department = GetPharmacyMainDepartment(data.TransType);

            var Inpat = "";
            if (data.Patient_ID != "")
            {
                var inpatientid = db.In_Patients.Where(x => x.Patient_ID == Convert.ToInt32(data.Patient_ID)).Select(x => x.In_Patient_ID).FirstOrDefault().ToString();
                Inpat = inpatientid;
            }

            if ((data.Patient_ID != "") && (Rbtn == "rbtncash" || Rbtn == "rbtnbank" || Rbtn == "rbtnbankacc"))
            {
                newBill.Customer_Type = "Hospital-Patient";
                newBill.Patient_ID = Convert.ToInt32(data.Patient_ID);
            }
            else if (Rbtn == "rbtnHospital" && data.Patient_ID != "" && Inpat != "")
            {
                newBill.Patient_ID = Convert.ToInt32(data.Patient_ID);
                newBill.Customer_Type = "Panel-Patient";
                newBill.PatientDischargeBilling = false;
                newBill.In_Patient_ID = Convert.ToInt32(Inpat);
                newBill.BillType = "PanelMedicine";
            }

            if (patId == 0)
            {
                newBill.Customer_Type = "Walk-in";
            }
            else
            {
                newBill.Customer_Type = "Hospital-Patient";
            }

            newBill.Customer_Name = data.CustomerName;

            var AccIdCash = (from aac in db.GL_Accounts where (aac.Account_Name == "Cash In Hand-Store") select aac.Account_ID).FirstOrDefault();
            if (Rbtn == "rbtncash")
            {
                newBill.IsCash = true;
                newBill.AccountId = AccIdCash;
            }

            var AccIdBank = (from aac in db.GL_Accounts where (aac.Account_Name == "Bank Alfalah Current Account") && (aac.Bank == true) select aac.Account_ID).FirstOrDefault();
            if (Rbtn == "rbtnbank")
            {
                newBill.IsBank = true;
                newBill.AccountId = AccIdBank;
            }

            // "Bank" mode: payment goes to the bank account picked from the dropdown
            if (Rbtn == "rbtnbankacc")
            {
                var isValidBank = data.BankAccountId > 0 && db.GL_Accounts.Any(a =>
                    a.Account_ID == data.BankAccountId && a.Levels == 4 && a.Bank == true && a.Active == true);
                if (!isValidBank)
                    throw new Exception("Please select a valid bank account.");

                newBill.IsBank = true;
                newBill.Bank_Account = data.BankAccountId.ToString();
            }

            if (Rbtn == "rbtnHospital")
            {
                newBill.IsHospital_Pharmacy = true;
            }

            newBill.Company_ID = AppConfig.Company_ID;

            newBill.Payment_Mode = Rbtn == "rbtncash" ? "Cash"
                                 : Rbtn == "rbtnbankacc" ? "Bank"
                                 : Rbtn == "rbtnHospital" ? "Panel"
                                 : Rbtn == "rbtnbank" ? "Credit" : null;

            // ============ IMPORTANT: Save Bill Header FIRST ============
            if (data.Bill_ID == 0)
                db.Ar_Billings.InsertOnSubmit(newBill);

            db.SubmitChanges(); // THIS GIVES YOU THE Bill_ID

            // ============ NOW DELETE OLD DETAILS ============
            List<Ar_Billing_Detail> ListOfDetails_Previous = db.Ar_Billing_Details.Where(b => b.Bill_ID == newBill.Bill_ID).ToList();
            db.Ar_Billing_Details.DeleteAllOnSubmit(ListOfDetails_Previous);
            db.SubmitChanges();

            // ============ INSERT NEW DETAILS ============
            List<Ar_Billing_Detail> ListOfDetails = new List<Ar_Billing_Detail>();

            foreach (Medicindetails dtls in data.Save_list)
            {
                int Item_Id;
                if (dtls.Itemid == 0)
                {
                    Item_Id = dtls.hdnItemid;
                }
                else
                {
                    Item_Id = dtls.Itemid;
                }
                if (dtls.Itemid == 0 && dtls.hdnItemid == 0)
                {
                    Item_Id = (from inv in db.INV_Items where inv.Description == dtls.ItemName && inv.Is_Active == true && (inv.isCancel == null || inv.isCancel == false) select inv.Item_ID).FirstOrDefault();
                }

                Ar_Billing_Detail newBillDetails = new Ar_Billing_Detail();
                newBillDetails.Bill_ID = newBill.Bill_ID; // Now this has correct value
                newBillDetails.ParentTrans_Name = "IssueMedicine";
                newBillDetails.ParentTrans_Type = "Medicine";
                newBillDetails.Item_ID = Item_Id;
                newBillDetails.Item_Name = dtls.ItemName;
                newBillDetails.Amount = dtls.Amount;
                newBillDetails.Item_Type = "Medicine";
                newBillDetails.Discount_Percentage = dtls.DiscPer;
                newBillDetails.Discount_Amount = dtls.DiscAmount;
                newBillDetails.Line_Discount = dtls.LineDiscount;
                newBillDetails.Net_Amount = dtls.NetAmount;
                newBillDetails.Qty = dtls.Qty;
                newBillDetails.Batch_No = dtls.batchno;
                newBillDetails.Remarks = dtls.Remarks;
                newBillDetails.Req_qty = dtls.Req_qty;
                newBillDetails.CGS = dtls.CGSAmount;

                bool isBacth = (from inv in db.INV_Items
                                where inv.Description == dtls.ItemName
                                   && inv.Is_Active == true
                                   && (inv.isCancel == null || inv.isCancel == false)
                                select inv.IsBatch ?? false)
                 .FirstOrDefault();
                // decimal currentDbStock = ReadCurrentStock(db, Item_Id , dtls.batchno);
                if (isBacth == true)
                {
                    if (dtls.batchno != "" || dtls.batchno != null)
                    {
                        decimal currentDbStock = ReadCurrentStock(db, Item_Id, dtls.batchno, data.warehouse);
                        if (currentDbStock < dtls.Qty)
                        {
                            throw new Exception(
                                "Insufficient stock for " + dtls.ItemName +
                                ". Available: " + currentDbStock +
                                ", Requested: " + dtls.Qty + ".");
                        }
                        decimal newStock = currentDbStock - dtls.Qty;
                        UpdateStockAtomic(db, Item_Id, newStock);
                    }
                }
                else
                {
                    decimal currentDbStock = ReadCurrentStockWithoutBatch(db, Item_Id,  data.warehouse);
                    if (currentDbStock < dtls.Qty)
                    {
                        throw new Exception(
                            "Insufficient stock for " + dtls.ItemName +
                            ". Available: " + currentDbStock +
                            ", Requested: " + dtls.Qty + ".");
                    }
                    decimal newStock = currentDbStock - dtls.Qty;
                    UpdateStockAtomic(db, Item_Id, newStock);

                }
                Total_CGSS += dtls.CGSAmount;
                ListOfDetails.Add(newBillDetails);
            }

            db.Ar_Billing_Details.InsertAllOnSubmit(ListOfDetails);
            newBill.Total_CGS = Total_CGSS;
            db.SubmitChanges(); // Save details

            // ============ UPDATE IPD RECEIVED QUANTITIES ============
            // Update Rcv_Qty for IPD Patients only (NO VALIDATION HERE, JUST UPDATE)
            if (data.In_Patient_ID > 0 && data.Save_list != null && data.Save_list.Any() && data.TransType == "IPD Patient")
            {
                // Only update quantities, no validation
                foreach (var dtls in data.Save_list)
                {
                    int Item_Id = dtls.Itemid == 0 ? dtls.hdnItemid : dtls.Itemid;
                    int qty = dtls.Qty;

                    if (Item_Id > 0 && qty > 0)
                    {
                        UpdateReceivedQuantity(Item_Id, qty, data.In_Patient_ID);
                    }
                }
            }

            newBillId = newBill.Bill_ID;
            return newBill;
        }

      
        private static decimal ReadCurrentStock(DataBaseDataContext db, int itemId, string batchNo, string warehouse)
        {
            using (SqlCommand cmd = (SqlCommand)db.Connection.CreateCommand())
            {
                cmd.Transaction = (SqlTransaction)db.Transaction;

                cmd.CommandText = @"
            SELECT ISNULL(SUM(Qty), 0)
            FROM vwBatch_Ledger
            WHERE Item_ID = @id
              AND Batch_No = @batch
              AND Ware_House = @warehouse";

                cmd.Parameters.AddWithValue("@id", itemId);
                cmd.Parameters.AddWithValue("@batch", batchNo);
                cmd.Parameters.AddWithValue("@warehouse", warehouse);

                object result = cmd.ExecuteScalar();

                if (result == null || result == DBNull.Value)
                    return 0m;

                return Convert.ToDecimal(result);
            }
        }
      
        private static decimal ReadCurrentStockWithoutBatch(DataBaseDataContext db, int itemId, string warehouse)
        {
            using (SqlCommand cmd = (SqlCommand)db.Connection.CreateCommand())
            {
                cmd.Transaction = (SqlTransaction)db.Transaction;

                cmd.CommandText = @"
            SELECT ISNULL(SUM(Qty), 0)
            FROM vwBatch_Ledger
            WHERE Item_ID = @id
              AND Ware_House = @warehouse";

                cmd.Parameters.AddWithValue("@id", itemId);
                cmd.Parameters.AddWithValue("@warehouse", warehouse);

                object result = cmd.ExecuteScalar();

                if (result == null || result == DBNull.Value)
                    return 0m;

                return Convert.ToDecimal(result);
            }
        }

        private static void UpdateStockAtomic(DataBaseDataContext db, int itemId, decimal newStock)
        {
            using (SqlCommand cmd = (SqlCommand)db.Connection.CreateCommand())
            {
                cmd.Transaction = (SqlTransaction)db.Transaction;
                cmd.CommandText = "UPDATE INV_Items SET Total_Qty = @qty WHERE Item_ID = @id";
                cmd.Parameters.AddWithValue("@qty", newStock);
                cmd.Parameters.AddWithValue("@id", itemId);
                cmd.ExecuteNonQuery();
            }
        }
        // Patient category saved in Ar_Billings.Main_Department: OPD = 01, Emergency = 02, IPD = 03.
        // Walk-in sales (no IPD/OPD/Emergency transaction type) stay empty.
        public static string GetPharmacyMainDepartment(string transType)
        {
            if (string.IsNullOrEmpty(transType)) return null;
            if (transType.StartsWith("IPD")) return "03";
            if (transType == "OPD Patient") return "01";
            if (transType == "EMR Patient") return "02";
            return null;
        }

        [WebMethod]
        public static string ApprovePhramcy(string billid)
        {
            var userid = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var details = db.SpApprovePharmacy(Convert.ToInt32(billid), userid);
            return (new JavaScriptSerializer()).Serialize(details);
        }
        [WebMethod]
        public static string GetDepartment()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Patient Main Category"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }
        public class PatientDetail
        {

            public string Name;
            public string Mobile;
            public string MRNo;
            public string PatientID;

        }
        [WebMethod]
        public static string GetUserFromSysParams()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var PharmacyDetail = (from prms in db.sys_Parms
                                  where prms.Name == "Pharmacy User"
                                  select prms.Code
                ).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(PharmacyDetail);
        }
        // Rates agreed with a panel (Panel Agreement screen) for the given items (Item_ID, comma separated).
        // A rate of 0 means "not set", so the normal sale rate applies.
        [WebMethod]
        public static string GetPanelRates(int panelId, string itemIds)
        {
            var ids = (itemIds ?? "").Split(',').Select(s => s.Trim()).Where(s => s != "").Distinct().ToList();
            var result = new Dictionary<string, decimal>();
            if (panelId > 0 && ids.Count > 0)
            {
                DataBaseDataContext db = new DataBaseDataContext();
                var rates = (from p in db.Panel_Detail_Services
                             where p.Panel_ID == panelId && p.Test_ID == null && p.Rate > 0 && ids.Contains(p.Item_ID)
                             select new { p.Item_ID, Rate = p.Rate.Value }).ToList();
                foreach (var r in rates)
                    result[r.Item_ID] = r.Rate;
            }
            return (new JavaScriptSerializer()).Serialize(result);
        }

        [WebMethod]
        public static string GetBankAccounts()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var bankList = (from i in db.GL_Accounts
                            where i.Levels == 4 && i.Bank == true && i.Active == true
                            orderby i.Account_Name
                            select new
                            {
                                i.Account_ID,
                                Name = i.Account_Code + "-" + i.Account_Name
                            }).ToList();

            return (new JavaScriptSerializer()).Serialize(bankList);
        }

        [WebMethod]
        public static string GetBalanceAmountCondition()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var PharmacyDetail = (from prms in db.sys_Parms
                                  where prms.Name == "Amount Recevied For Pharmcay"
                                  select prms.Code
                ).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(PharmacyDetail);
        }

        [WebMethod]
        public static PatientDetail LoadPatientDetails(string PatientID)
        {
            int Patient_No = DBClass.GetMRNOBy_PatientID(Convert.ToInt32(PatientID));
            PatientDetail pt = new PatientDetail();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var pat = (
                from tbl in db.Patients
                where tbl.Patient_No == Patient_No
                orderby tbl.Entry_Date descending
                select new
                {
                    tbl.Full_Name,
                    tbl.Mobile1,
                    tbl.Patient_No,
                    tbl.Patient_ID
                }).FirstOrDefault();

            if (pat != null)
            {
                pt.Name = pat.Full_Name;
                pt.Mobile = pat.Mobile1;
                pt.PatientID = pat.Patient_ID.ToString();
                pt.MRNo = pat.Patient_No.ToString();

                return pt;
            }
            else
                return pt;
        }
        [WebMethod]
        public static string CheckSehatCardPatient(string patid)
        {
            if (!int.TryParse(patid, out int patientId))
                return string.Empty;

            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var discountType = (
                from tbl in db.In_Patients
                where tbl.Patient_ID == patientId
                      && tbl.Discharge == false
                orderby tbl.Created_Time descending
                select tbl.Patient_Discount_Type
            ).FirstOrDefault();
            var typeName = (from d in db.DataValues
                            join v in db.ValueSets
                           on d.ValueSet_ID equals v.ValueSet_ID
                            where v.ValueSet_ID == 26 && d.DataValue_Name == discountType
                            select d.DataValue_Description).FirstOrDefault();

            var result = new
            {
                DiscountType = discountType ?? string.Empty,
                TypeName = typeName ?? string.Empty
            };

            return new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(result);
        }
     
        [WebMethod]
        public static string CheckOPDPatient(string patid)
        {
            // Validate input
            if (!int.TryParse(patid, out int regPatId))
                return string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var opdId = (
                    from op in db.Out_Patients
                    where op.Reg_PatId == regPatId
                          && op.Discharge == false  
            orderby op.Created_Time descending
                    select op.Out_Patient_ID
                ).FirstOrDefault();

                return opdId > 0 ? opdId.ToString() : string.Empty;
            }
        }
        [WebMethod]
        public static string CheckEmergencyPatient(string patid)
        {
            // Validate input
            if (!int.TryParse(patid, out int regPatId))
                return string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var emergencyId = (
                    from op in db.Emergency_Patients
                    where op.Patient_ID == regPatId
                          && (op.Discharge == false || op.Discharge == null)
                    orderby op.Created_Time descending
                    select op.Emergency_ID
                ).FirstOrDefault();

                return emergencyId > 0 ? emergencyId.ToString() : string.Empty;
            }
        }
        [WebMethod]
        public static string GetInvoiceNumber()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            DateTime startDate = System.DateTime.Now.AddDays(-1);
            var getmaxno = DBClass.getField("Select isnull(MAX(Invoice_No),0)+1 from Ar_billings where Invoice_Date >='" + startDate + "'");
            return getmaxno.ToString();
        }


        [WebMethod]
        public static string GetAllCashierUsers()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from pds in db.Pharmacy_Users
                         where pds.IsActive == true
                         select new
                         {
                             pds.User_Code,
                             pds.UserName
                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static string loadData(string userC)
        {
            string result = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            var itemsList = (from i in db.Pharmacy_Users
                             where i.User_Code == userC && i.IsActive == true
                             select new
                             {
                                 i.UserID,
                                 i.UserName,
                                 i.Password,
                                 i.User_Code
                             }).ToList();
            if (itemsList != null)
            {
                result = (new JavaScriptSerializer()).Serialize(itemsList);
            }
            return result;
        }
        [WebMethod]
        public static string AllInvoiceNumbers(string searchTerm, int reg_id)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var query = db.Ar_Billings
                .Where(data => data.IsPharmacy == true
                            && data.Invoice_No != null
                            && (data.isCancel == false || data.isCancel == null));

            if (reg_id > 0)
            {
                query = query.Where(x => x.Patient_ID == reg_id);
            }

            else if (string.IsNullOrEmpty(searchTerm))
            {
                return new JavaScriptSerializer().Serialize(new object[0]);
            }

            // If user is searching
            if (!string.IsNullOrEmpty(searchTerm))
            {
                query = query.Where(x => x.Seq_InvoiceNo.Contains(searchTerm));
            }

            var result = query
                .OrderByDescending(x => x.Bill_ID)
                .Select(x => new
                {
                    id = x.Bill_ID,
                    text = x.Seq_InvoiceNo
                })
                .Take(string.IsNullOrEmpty(searchTerm) ? 100 : 200) // 100 default, more if searching
                .ToList();

            return new JavaScriptSerializer().Serialize(result);
        }
        [WebMethod]
        public static string GetInvoiceNo(string searchTerm)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var query = db.Ar_Billings
                    .Where(x => x.IsPharmacy == true
                             && x.Invoice_No != null
                             && (x.isCancel == false || x.isCancel == null));

                if (!string.IsNullOrWhiteSpace(searchTerm))
                {
                    query = query.Where(x => x.Seq_InvoiceNo.Contains(searchTerm));
                }

                var result = query
                    .OrderByDescending(x => x.Bill_ID)
                    .Select(x => new
                    {
                        id = x.Bill_ID,
                        text = x.Seq_InvoiceNo
                    })
                    .Take(string.IsNullOrWhiteSpace(searchTerm) ? 50 : 200)
                    .ToList();

                return new JavaScriptSerializer().Serialize(result);
            }
        }
        [WebMethod]
        public static string GetPatientName(int patientId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                //var regPatient = (from p in db.Reg_patients
                //                  where p.pat_id == patientId
                //                  select p.Full_Name).FirstOrDefault();

        

                //if (!string.IsNullOrEmpty(regPatient))
                //{
                //    return (new JavaScriptSerializer()).Serialize(regPatient);
                //}

                var inPatient = (from ip in db.In_Patients
                                 join rp in db.Reg_patients on ip.Patient_ID equals rp.pat_id
                                 where ip.In_Patient_ID == patientId
                                 select rp.Full_Name).FirstOrDefault();

                if (!string.IsNullOrEmpty(inPatient))
                {
                    return (new JavaScriptSerializer()).Serialize(inPatient);
                }

                var outPatient = (from op in db.Out_Patients
                                  join rp in db.Reg_patients on op.Reg_PatId equals rp.pat_id
                                  where op.Out_Patient_ID == patientId
                                  select rp.Full_Name).FirstOrDefault();

                if (!string.IsNullOrEmpty(outPatient))
                {
                    return (new JavaScriptSerializer()).Serialize(outPatient);
                }

                var emergencyPatient = (from ep in db.Emergency_Patients
                                        join rp in db.Reg_patients on ep.Patient_ID equals rp.pat_id
                                        where ep.Emergency_ID == patientId
                                        select rp.Full_Name).FirstOrDefault();

                return (new JavaScriptSerializer()).Serialize(emergencyPatient ?? "");
            }
        }

        [WebMethod]
        public static string GetPatientNameByRegId(int regPatId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var patient = (from p in db.Reg_patients
                               where p.pat_id == regPatId
                               select p.Full_Name).FirstOrDefault();

                return (new JavaScriptSerializer()).Serialize(patient ?? "");
            }
        }
        //[WebMethod]
        //public static string AllInvoiceNumbers()
        //{
        //    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
        //    var panel = (from data in db.Ar_Billings
        //                 where data.IsPharmacy == true && data.Invoice_No != null && (data.isCancel == false || data.isCancel == null) orderby data.Bill_ID descending
        //                 select new
        //                 {
        //                     Bill_ID = data.Bill_ID,
        //                     Seq_InvoiceNo = data.Seq_InvoiceNo,
        //                 }).ToList().Take(200);
        //    return (new JavaScriptSerializer()).Serialize(panel);
        //}
        [WebMethod]
        public static string GetTemplate()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var panel = (from data in db.Pharmacy_Template_Masters
                         where  (data.IsCancel == false || data.IsCancel == null)
                         orderby data.ID descending
                         select new
                         {
                             id = data.ID,
                             Name = data.TemplateName,
                         }).ToList().Take(200);
            return (new JavaScriptSerializer()).Serialize(panel);
        }
        [WebMethod]
        public static string AllPharmaPatients()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var panel = (from patient in db.Reg_patients
                         join billing in db.Ar_Billings
                         on patient.pat_id equals billing.Patient_ID into billingJoin
                         from bill in billingJoin.DefaultIfEmpty()  // LEFT JOIN
                         where bill != null  // Only patients who have billing records
                            && bill.IsPharmacy == true
                            && bill.Invoice_No != null
                            && (bill.isCancel == false || bill.isCancel == null)
                         orderby bill.Bill_ID descending
                         select new
                         {
                             id = patient.pat_id,           // For TokenInput
                             mr_no_sequence = patient.mr_no_sequence,              // For TokenInput display
                           
                         }).ToList();

            return (new JavaScriptSerializer()).Serialize(panel);
        }
        [WebMethod]
        public static List<object> GetInvoiceNoByPatient(int reg_id)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var invoicenumber = (
                from billing in db.Ar_Billings
                where billing.Patient_ID == reg_id
                   && billing.IsPharmacy == true
                   && billing.Invoice_No != null
                   && (billing.isCancel == false || billing.isCancel == null)
                orderby billing.Bill_ID descending
                select new
                {
                    bill_id = billing.Bill_ID,
                    Seq_InvoiceNo = billing.Seq_InvoiceNo
                }).ToList();

            return invoicenumber.Cast<object>().ToList();  // Return as List<object>
        }

        [WebMethod]
        public static string SaleReturnItems(string searchTerm)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var query = db.INV_Items.Where(data => data.IsPharmacyItem == true);

            if (!string.IsNullOrWhiteSpace(searchTerm))
            {
                var term = searchTerm.Trim();
                query = query.Where(x => x.Description.Contains(term));
            }

            var result = query
                .OrderBy(x => x.Description)
                .Select(x => new
                {
                    id = x.Item_ID,
                    text = x.Description
                })
                .Take(string.IsNullOrWhiteSpace(searchTerm) ? 100 : 200)
                .ToList();

            return (new JavaScriptSerializer()).Serialize(result);
        }

        [WebMethod]
        public static string SaleReturnMedicineDetail(int itemId)
        {
            string result = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.spSaleReturnMedicinesDetails(itemId).ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
        }
        [WebMethod]
        public static string GetPanel()
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {

                var result = (from gl in db.Panels

                              select new
                              {
                                  gl.Panel_ID,
                                  gl.Company_Name,
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);

            }
            return data;
        }
        [WebMethod]
        public static string SaleReturnInvoiceMaster(int invNo)
        {
            string result = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            var billdetails = (from i in db.Ar_Billings
                               where i.Bill_ID == invNo && (i.isCancel == false || i.isCancel == null)
                               select new
                               {
                                   i.Bill_No,
                                   Discount_Percentage = (i.Discount_Percentage ?? 0),
                                   Discount_Amount = (i.Discount_Amount ?? 0),
                                   Total_Amount = (i.Total_Amount ?? 0),
                                   i.Creation_Date,
                                   i.Created_By,
                                   i.Invoice_Date,
                                   Line_Wise_Discount = (i.line_disc ?? 0),
                                   Received_Amount = (i.Received_Amount ?? 0)
                               }).ToList();
            if (billdetails != null)
            {
                result = (new JavaScriptSerializer()).Serialize(billdetails);
            }
            return result;
        }
        [WebMethod]
        public static string SaleReturnInvoiceDetail(int BillId, string wareHouse)
        {
            string result = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.spSaleReturnInvoiceDetails(BillId,wareHouse).ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
        }
        [WebMethod]
        public static string GetPendingPatientsCount()
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    DateTime last24Hours = DateTime.Now.AddHours(-24);

                    // Get distinct patient IDs with pending medicines in last 24 hours
                    var query = (from pm in db.In_Patient_Medicines
                                 where pm.Medicine_Date >= last24Hours
                                       && (pm.is_rejected == null || pm.is_rejected == false)
                                 join ipd in db.In_Patients on pm.Patient_ID equals ipd.In_Patient_ID
                                 join rp in db.Reg_patients on ipd.Patient_ID equals rp.pat_id
                                 select rp.pat_id)
                                .Union(
                                    from pm in db.In_Patient_Medicines
                                    where pm.Medicine_Date >= last24Hours
                                          && (pm.is_rejected == null || pm.is_rejected == false)
                                    join opd in db.Out_Patients on pm.Patient_ID equals opd.Out_Patient_ID
                                    join rp in db.Reg_patients on opd.Reg_PatId equals rp.pat_id
                                    select rp.pat_id
                                )
                                .Union(
                                    from pm in db.In_Patient_Medicines
                                    where pm.Medicine_Date >= last24Hours
                                          && (pm.is_rejected == null || pm.is_rejected == false)
                                    join ep in db.Emergency_Patients on pm.Patient_ID equals ep.Emergency_ID
                                    join rp in db.Reg_patients on ep.Patient_ID equals rp.pat_id
                                    select rp.pat_id
                                )
                                .Distinct();

                    int count = query.Count();
                    return (new JavaScriptSerializer()).Serialize(new { Count = count });
                }
            }
            catch (Exception ex)
            {
                return (new JavaScriptSerializer()).Serialize(new { Count = 0, Error = ex.Message });
            }
        }
        [WebMethod]
        public static string GetShowTemplateOnSale()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var showTemplate = (from prms in db.sys_Parms
                                where prms.Name == "ShowTemplateOnSale"
                                select prms.Code).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(showTemplate ?? "0");
        }
        [WebMethod]
        public static int SaveSaleReturnData(string AllItemDetail,string UserId)
        {

            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer js = new JavaScriptSerializer();
            var record = js.Deserialize<SaleReturnMaster>(AllItemDetail);
            Pharmacy_SaleReturn saleReturn = new Pharmacy_SaleReturn();
            saleReturn.Bill_ID = int.Parse(record.BillId);
            saleReturn.Patient_id = int.Parse(record.Patient_id);
            saleReturn.Seq_InvoiceNo = record.InvNo;
            saleReturn.Return_NO = DBClass.GetNewNumber("Return_NO", "Pharmacy_SaleReturns", "").ToString();
            saleReturn.Disc_Percentage = record.DisPer;
            saleReturn.Master_Discount_Amt = record.TotalDisAmt;
            saleReturn.UserId = UserId;
            saleReturn.TotalLine_Wise_Discount = record.TotalLineDisc;
            saleReturn.TotalDisc_Amount = record.TotalDisAmt;
            saleReturn.Disc_Adjustment = record.AdjustmentAmt;
            saleReturn.Net_Amount = record.Total;
            saleReturn.Is_Pharmacy = true;
            saleReturn.Is_CathLab = false;
        
            saleReturn.Ware_House = record.warehouse;
            saleReturn.Total_Amount = record.TotalPayable;
            saleReturn.Company_ID = AppConfig.Company_ID;
            saleReturn.Created_Date = DateTime.Now;
            saleReturn.Created_By = AppConfig.UserID;
            saleReturn.IsDeleted = false;
            saleReturn.Remarks = record.Remarks;
            db.Pharmacy_SaleReturns.InsertOnSubmit(saleReturn);
            db.SubmitChanges();

            int saleReturnID = saleReturn.Return_ID;

            foreach (var item in record.ItemList)
            {
                Pharmacy_SaleReturn_Detail detail = new Pharmacy_SaleReturn_Detail
                {
                    Return_ID = saleReturnID,
                    Bill_Details_ID = int.Parse(item.Bill_Details_ID),
                    Item_ID = int.Parse(item.ItemID),
                    Item_Name = item.ItemName,
                    Qty = decimal.Parse(item.Qty),
                    Amount = decimal.Parse(item.Rate),
                    Disc_Per = decimal.Parse(item.DisPer),
                    Disc_Amount = decimal.Parse(item.DisAmt),
                    Net_Amount = decimal.Parse(item.NetAmt),
                    Batch_No = item.Batch_No,
                    CGS = item.CGSAmount,
                    LineDiscount =Convert.ToDecimal( item.LineDiscount)
                };
                db.Pharmacy_SaleReturn_Details.InsertOnSubmit(detail);
                db.SubmitChanges();
            }

            return saleReturnID;
        }
        public class SaleReturnMaster
        {
            public string BillId { get; set; }
            public string Patient_id { get; set; }
            public string InvNo { get; set; }
            public string warehouse { get; set; }
            public decimal TotalPayable { get; set; }
            public decimal TotalLineDisc { get; set; }
            public decimal DisPer { get; set; }
            public decimal TotalDisAmt { get; set; }
            public decimal AdjustmentAmt { get; set; }
            public decimal Total { get; set; }
            public string Remarks { get; set; }
            public List<SaleReturnDetail> ItemList { get; set; }
        }

        public class SaleReturnDetail
        {
            public string ItemID { get; set; }
            public string Bill_Details_ID { get; set; }
            public string ItemName { get; set; }
            public string Qty { get; set; }
            public string Rate { get; set; }
            public string DisPer { get; set; }
            public string DisAmt { get; set; }
            public string NetAmt { get; set; }
            public string Batch_No { get; set; }
            public decimal CGSAmount { get; set; }
            public string LineDiscount { get; set; }
        }

    }
}