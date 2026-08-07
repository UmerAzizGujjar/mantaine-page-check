using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Billing
{
    public partial class IssueCathLabItems : System.Web.UI.Page
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
        public static string CheckSaleReturnAllow()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var ups = (from St in db.aspnet_Users
                       where St.UserName == AppConfig.UserName
                       select St.AllowSaleReturn).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(ups);
        }
        [WebMethod]
        public static string GetWardAndBed(int Pat_Id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var itemCodes = (from ip in db.In_Patients
                             where ip.In_Patient_ID == Pat_Id
                             select new
                             {
                                 Ward_Name = (from w in db.Ward_Definitions where w.Ward_ID == ip.Ward_ID select w.Ward_Type).FirstOrDefault(),
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
        public static string GetItemCodesIPD(int Pat_Id)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var depAndDoc = (from ip in db.In_Patients
                             where ip.In_Patient_ID == Pat_Id

                             select new
                             {
                                 ip.Doctor,
                                 ip.Department,
                                 ip.Panel_Company
                             }).FirstOrDefault();

            var itemCodes = (from ip in db.In_Patient_Medicines
                             where ip.Patient_ID == Pat_Id
                             && ip.Item_Code != null
                             && ip.Item_Code != "0"
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
            var itemCodes = (from ip in db.In_Patient_Medicines
                             where ip.Patient_ID == Pat_Id
                             && ip.Item_Code != null
                             && ip.Item_Code != "0"
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
                var OPD_NO = (from opd in db.Patients
                              join
                              ou in db.Out_Patients on opd.Patient_ID equals ou.Patient_ID

                              where opd.Reg_PatId == pat_id
                              && (ou.Discharge == false || ou.Discharge == null)

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

                var PICondition = (from sys in db.sys_Parms where sys.Name == "Direct PO ON Purchase Invoice" select sys.Code).FirstOrDefault();

                if (PICondition == "01")
                {
                    var grnBatches = (from ds in db.Purchase_Invoice_Details
                                      join grn in db.Purchase_Invoice_Masters on ds.PurchaseInvoiceId equals grn.PurchaseInvoiceId
                                      where ds.ItemId == med_id
                                      select ds.BatchNum).ToList();

                    foreach (var batch in grnBatches)
                    {
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
                        int stock = Convert.ToInt32(
                            db.GetPharmcyItemUomTotalStock(med_id, warehouse, batch)
                        );

                        if (stock > 0)
                            batchSet.Add(batch);
                    }

                }


                // ---------- Stock Adjustment Batches ----------
                var stockAdjBatches = (from inv in db.INV_Stock_Adjustments
                                       where inv.Item_Id == med_id.ToString() && inv.Ware_House == warehouse
                                       && inv.Status == "Approved"
                                       select inv.Batch_No).ToList();

                foreach (var batch in stockAdjBatches)
                {
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



        [WebMethod]
        public static string GetBatchNumbers(int itemId, string warehouse)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                HashSet<string> batchSet = new HashSet<string>();

                //var warehouse = (from sys in db.sys_Parms where sys.Name == "Pharmacy WareHouse" select sys.Code).FirstOrDefault();

                var PICondition = (from sys in db.sys_Parms where sys.Name == "Direct PO ON Purchase Invoice" select sys.Code).FirstOrDefault();

                if (PICondition == "01")
                {
                    var grnBatches = (from ds in db.Purchase_Invoice_Details
                                      join grn in db.Purchase_Invoice_Masters on ds.PurchaseInvoiceId equals grn.PurchaseInvoiceId
                                      where ds.ItemId == itemId
                                      select ds.BatchNum).ToList();

                    foreach (var batch in grnBatches)
                    {
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
                        int stock = Convert.ToInt32(
                            db.GetPharmcyItemUomTotalStock(itemId, warehouse, batch)
                        );

                        if (stock > 0)
                            batchSet.Add(batch);
                    }

                }


                // ---------- Stock Adjustment Batches ----------
                var stockAdjBatches = (from inv in db.INV_Stock_Adjustments
                                       where inv.Item_Id == itemId.ToString() && inv.Ware_House == warehouse
                                       && inv.Status == "Approved"
                                       select inv.Batch_No).ToList();

                foreach (var batch in stockAdjBatches)
                {
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
                var query = db.Sp_GetLast24Hours_PatientForCath(SearchString).ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();

            }
            return result;
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
                var query = db.sp_cathLabitem(ItemName).ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
        }


        [WebMethod]
        public static string CheckBarcodeSoldStatus(string barcodeNumber)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    // First, get the Barcode_ID from ItemSelection_Barcodes table using the barcode number
                    var barcodeRecord = (from b in db.ItemSelection_Barcodes
                                         where b.Barcode_Number == barcodeNumber
                                         select b.Barcode_ID).FirstOrDefault();

                    if (barcodeRecord == null || barcodeRecord == 0)
                    {
                        // Barcode not found in ItemSelection_Barcodes table
                        return new JavaScriptSerializer().Serialize(new { IsSold = false, Message = "Barcode not found in system" });
                    }

                    // Convert to int safely
                    int barcodeId = Convert.ToInt32(barcodeRecord);

                    // Now check if this Barcode_ID exists in Ar_Billing_Detail for CathLab
                    var existingSale = (from detail in db.Ar_Billing_Details
                                        where detail.Barcode_Id == barcodeId
                                        && (detail.ParentTrans_Name == "IssueCath" || detail.ParentTrans_Name == "CathItems")
                                        select new
                                        {
                                            detail.Bill_Details_ID,
                                            detail.Bill_ID
                                        }).FirstOrDefault();

                    if (existingSale != null)
                    {
                        // Get bill information
                        var billInfo = (from bill in db.Ar_Billings
                                        where bill.Bill_ID == existingSale.Bill_ID
                                        select new
                                        {
                                            bill.Seq_InvoiceNo,
                                            bill.Invoice_Date
                                        }).FirstOrDefault();

                        return new JavaScriptSerializer().Serialize(new
                        {
                            IsSold = true,
                            BarcodeId = barcodeId,
                            InvoiceNo = billInfo?.Seq_InvoiceNo ?? "Unknown",
                            InvoiceDate = billInfo?.Invoice_Date?.ToString("yyyy-MM-dd") ?? "Unknown"
                        });
                    }

                    // Barcode exists but not sold yet
                    return new JavaScriptSerializer().Serialize(new
                    {
                        IsSold = false,
                        BarcodeId = barcodeId,
                        Message = "Barcode is available"
                    });
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"CheckBarcodeSoldStatus Error: {ex.Message}");
                return new JavaScriptSerializer().Serialize(new { IsSold = false, Error = ex.Message });
            }
        }
        [WebMethod]
        public static string loadMedicineByID(string ID)
        {
            string result = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                // 1. Try to fetch item + batch directly from Barcode mapping
                var barcodeResult = (from b in db.ItemSelection_Barcodes
                                     join item in db.INV_Items on b.Item_Id equals item.Item_ID
                                     join grn in db.GRN_Details on b.GRN_Detail_Id equals grn.GRN_detail_Id // Adjust column name if different
                                     where b.Barcode_Number == ID && (item.isCancel == null || item.isCancel == false)
                                     select new
                                     {
                                         item.Item_ID,
                                         item.Item_Code,
                                         item.Description,
                                         item.Generic_Name,
                                         BatchNum = grn.BatchNum,
                                         Barcode_ID = b.Barcode_ID
                                     }).FirstOrDefault();

                if (barcodeResult != null)
                {
                    return new JavaScriptSerializer().Serialize(new List<object> { barcodeResult });
                }

                // 2. Fallback: Search by Item_ID (no batch)
                int itemId;
                if (int.TryParse(ID, out itemId))
                {
                    var query = (from it in db.INV_Items
                                 where it.Item_ID == itemId && (it.isCancel == null || it.isCancel == false)
                                 select new
                                 {
                                     it.Item_ID,
                                     it.Item_Code,
                                     it.Description,
                                     it.Generic_Name,
                                     BatchNum = (string)null,
                                     Barcode_ID = (int?)null
                                 }).ToList();
                    result = new JavaScriptSerializer().Serialize(query);
                }
                else
                {
                    result = new JavaScriptSerializer().Serialize(new List<object>());
                }
            }
            return result;
        }

        [WebMethod]
        public static string MedicineDetail(int itemId, string hdndiscountType, string Batch, string warehouse)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.spCathLabDetails(itemId, hdndiscountType, Batch, warehouse).ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
        }

        [WebMethod]
        public static string MedicineDetailgetfromOPD(int itemId)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.spMedicinesDetailsfromopdCathlab(itemId).ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
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

                return outPatientID.ToString();
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
        public static string GetStockByBatch(int itemId, string hdndiscountType, string batchNumber, string warehouse)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.spCathLabDetails(itemId, hdndiscountType, batchNumber, warehouse).ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
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
            public string BarcodeId { get; set; }
        }

        [WebMethod]
        public static string SaveRecord(string Parameters, string Rbtn, string UserId, int patId)
        {
            return (new JavaScriptSerializer()).Serialize(Save(Parameters, Rbtn, UserId, patId));
        }

        public static string Save(string Parameters, string Rbtn, string UserId, int patId)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            JavaScriptSerializer JSS = new JavaScriptSerializer();
            var data = JSS.Deserialize<Medicines>(Parameters);
            var getmaxno = db.Ar_Billings.Where(p => p.Creation_Date.Value.Year == DateTime.Now.Year
                                  && p.IsCathLab == true
                                  && p.Creation_Date.Value.Month == DateTime.Now.Month
                                  && p.Creation_Date.Value.Day == DateTime.Now.Day).Count() + 1;
            decimal Total_CGSS = 0;
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
            newBill.Seq_InvoiceNo = db.GetSale_InoviceNoCathLAb();
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
            //var PharmacyCodes = db.sys_Parms.Where(x => x.Name == "Pharmacy WareHouse").Select(x => x.Code).FirstOrDefault().ToString();
            newBill.Ware_House = data.warehouse;
            newBill.In_Patient_ID = data.In_Patient_ID;
            newBill.Panel_Id = Convert.ToInt32(data.Panel_Id);
            newBill.Sale_Return = "Return Against" + '-' + data.invNumber;
            newBill.UserID = Convert.ToInt32(UserId);
            newBill.IsCathLab = true;

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
            newBill.Pharma_trans_Type = data.TransType;
            var Inpat = "";
            if (data.Patient_ID != "")
            {
                var inpatientid = db.In_Patients.Where(x => x.Patient_ID == Convert.ToInt32(data.Patient_ID)).Select(x => x.In_Patient_ID).FirstOrDefault().ToString();
                Inpat = inpatientid;
            }
            if ((data.Patient_ID != "") && (Rbtn == "rbtncash" || Rbtn == "rbtnbank"))
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
            if (Rbtn == "rbtnHospital")
            {
                newBill.IsHospital_Pharmacy = true;
            }

            newBill.Company_ID = AppConfig.Company_ID;
            // Insert or Upate Bill Header
            if (data.Bill_ID == 0)
                db.Ar_Billings.InsertOnSubmit(newBill);
            db.SubmitChanges();

            List<Ar_Billing_Detail> ListOfDetails = new List<Ar_Billing_Detail>();
            List<Ar_Billing_Detail> ListOfDetails_Previous = db.Ar_Billing_Details.Where(b => b.Bill_ID == data.Bill_ID).ToList();
            db.Ar_Billing_Details.DeleteAllOnSubmit(ListOfDetails_Previous);
            db.SubmitChanges();
            // Inserting or Updating Bill Details
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
                newBillDetails.Bill_ID = newBill.Bill_ID;
                newBillDetails.ParentTrans_Name = "IssueCath";
                newBillDetails.ParentTrans_Type = "CathItems";
                newBillDetails.Item_ID = Item_Id;
                newBillDetails.Item_Name = dtls.ItemName;
                int? barcodeId = null;
                if (!string.IsNullOrEmpty(dtls.BarcodeId) && int.TryParse(dtls.BarcodeId, out int parsedId))
                {
                    barcodeId = parsedId;
                }
                newBillDetails.Barcode_Id = barcodeId;
                //var Item_Id = (from aac in db.INV_Items where (aac.Description == dtls.ItemName) select aac.Item_ID).FirstOrDefault();
                //newBillDetails.Item_ID = Item_Id;
                newBillDetails.Amount = dtls.Amount;
                newBillDetails.Item_Type = "CathItems";
                newBillDetails.Discount_Percentage = dtls.DiscPer;
                newBillDetails.Discount_Amount = dtls.DiscAmount;
                newBillDetails.Line_Discount = dtls.LineDiscount;
                newBillDetails.Net_Amount = dtls.NetAmount;
                newBillDetails.Qty = dtls.Qty;
                newBillDetails.Batch_No = dtls.batchno;
                newBillDetails.Remarks = dtls.Remarks;
                var TotalRemainStock = dtls.Stock - dtls.Qty;
                newBillDetails.CGS = dtls.CGSAmount;
                var getttlStock = DBClass.getField("update INV_Items set Total_Qty= '" + TotalRemainStock + "' where Item_ID =" + dtls.Itemid);
                Total_CGSS += dtls.CGSAmount;
                ListOfDetails.Add(newBillDetails);

                db.Ar_Billing_Details.InsertAllOnSubmit(ListOfDetails);
            }
            newBill.Total_CGS = Total_CGSS;
            db.SubmitChanges();
            ApprovePhramcy(newBill.Bill_ID.ToString());


            // Check if FBR_Pharmacy is set to "01" before posting to FBR
            var FBR_Pharmacy = db.sys_Parms.FirstOrDefault(p => p.Name == "FBR_Pharmacy")?.Code;
            if (FBR_Pharmacy == "01")
            {
                var detailIds = db.Ar_Billing_Details
                .Where(b => b.Bill_ID == newBill.Bill_ID)
                .Select(b => b.Bill_Details_ID)
                .ToList();

                if (detailIds.Count > 0)
                {
                    FBRBillingView.PostToFBR(newBill.Bill_ID, detailIds);
                }
            }

            return newBill.Bill_ID.ToString();
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
                .Where(data => data.IsCathLab == true
                            && data.Invoice_No != null
                            && (data.isCancel == false || data.isCancel == null));

            if (reg_id > 0)
            {
                query = query.Where(x => x.Patient_ID == reg_id);
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
        public static string AllPharmaPatients()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var panel = (from patient in db.Reg_patients
                         join billing in db.Ar_Billings
                         on patient.pat_id equals billing.Patient_ID into billingJoin
                         from bill in billingJoin.DefaultIfEmpty()  // LEFT JOIN
                         where bill != null  // Only patients who have billing records
                            && bill.IsCathLab == true
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

            var query = db.INV_Items.Where(data => data.Is_CathLab == true);

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
                var query = db.spSaleReturncathDetails(itemId).ToList();
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
        public static string SaleReturnInvoiceDetail(int BillId,string wareHouse)
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
        public static int SaveSaleReturnData(string AllItemDetail, string UserId)
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
            saleReturn.Is_CathLab = true;
            saleReturn.Is_Pharmacy = false;

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
                    LineDiscount = Convert.ToDecimal(item.LineDiscount)
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

        [WebMethod]
        public static string GetPatientFullDetails(int pat_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            
            var ipdData = (from ip in db.In_Patients
                           join reg in db.Reg_patients on ip.Patient_ID equals reg.pat_id
                           where ip.Patient_ID == pat_id && (ip.Discharge == false || ip.Discharge == null)
                           orderby ip.Created_Time descending
                           select new
                           {
                               Type = "IPD",
                               PatientName = reg.Full_Name, 
                               DoctorID = ip.Doctor,
                               Department = ip.Department,
                               WardName = (from w in db.Ward_Definitions where w.Ward_ID == ip.Ward_ID select w.Ward_Type).FirstOrDefault(),
                               BedNo = ip.Bed_No,
                               DiscountType = db.GetDataValueName("Patient Type", ip.Patient_Discount_Type),
                               PanelCompany = ip.Panel_Company
                           }).FirstOrDefault();

            if (ipdData != null)
            {
                return new JavaScriptSerializer().Serialize(ipdData);
            }

            var opdData = (from op in db.Out_Patients
                           join reg in db.Reg_patients on op.Reg_PatId equals reg.pat_id
                           where op.Reg_PatId == pat_id && (op.Discharge == false || op.Discharge == null)
                           orderby op.Created_Time descending
                           select new
                           {
                               Type = "OPD",
                               PatientName = reg.Full_Name, 
                               DoctorID = op.Doctor_ID,
                               Department = reg.filter_clinic, 
                               WardName = "",
                               BedNo = "",
                               DiscountType = "",
                               PanelCompany = ""
                           }).FirstOrDefault();

            if (opdData != null)
            {
                return new JavaScriptSerializer().Serialize(opdData);
            }

            // 3. Return empty object if nothing found
            return new JavaScriptSerializer().Serialize(new
            {
                Type = "",
                PatientName = "",
                DoctorID = 0,
                Department = "",
                WardName = "",
                BedNo = "",
                DiscountType = "",
                PanelCompany = ""
            });
        }
    }
}