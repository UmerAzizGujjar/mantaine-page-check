using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
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
        public static string GetItemCodes(int out_Patient_Id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var itemCodes = (from op in db.Out_Patients
                             join ip in db.In_Patient_Medicines on op.Out_Patient_ID equals ip.Patient_ID
                             where ip.Patient_ID == out_Patient_Id
                             select ip.Item_Code).ToList();
            return (new JavaScriptSerializer()).Serialize(itemCodes); ;

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
        public static string Getbatch_grn(int med_id)
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var grnResult = (from dv in db.INV_Items
                                 join ds in db.GRN_Details
                                 on dv.Item_ID equals ds.Item_Id
                                 where ds.Item_Id == med_id
                                 select new
                                 {
                                     BatchNum = ds.BatchNum
                                 }).ToList();

                var stockAdjustmentResult = (from inv in db.INV_Stock_Adjustments
                                             where inv.Item_Id == Convert.ToString(med_id)
                                              && inv.Status == "Approved"
                                             orderby inv.Creation_Time descending
                                             select new
                                             {
                                                 BatchNum = inv.Batch_No
                                             }).ToList();
                var combinedResult = new
                {
                    GRN_Details = grnResult,
                    Stock_Adjustment_Details = stockAdjustmentResult
                };
                data = new JavaScriptSerializer().Serialize(combinedResult);
            }
            return data;
        }

        [WebMethod]
        public static string GetBatchNumbers(int itemId)
        {
            string data = string.Empty;
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
                var stockAdjustmentResult = (from inv in db.INV_Stock_Adjustments
                                             where inv.Item_Id == Convert.ToString(itemId)
                                            && inv.Status == "Approved"
                                             select new
                                             {
                                                 BatchNum = inv.Batch_No
                                             }).ToList();
                var combinedResult = new
                {
                    GRN_Details = grnResult,
                    Stock_Adjustment_Details = stockAdjustmentResult
                };
                data = new JavaScriptSerializer().Serialize(combinedResult);
            }
            return data;
        }
        [WebMethod]
        public static string loadPrescrpition(int Opd_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var itemCodes = (from rg in db.Reg_patients
                             join p in db.Patients
                             on rg.pat_id equals p.Reg_PatId
                             join opd in db.Out_Patients
                             on p.Patient_ID equals opd.Patient_ID
                             where rg.Patient_No == Opd_ID
                             orderby opd.Created_Time descending
                             select new
                             {
                                 opd.Out_Patient_ID,
                                 p.Opd_No
                             }
                             ).Take(3).ToList();

            return (new JavaScriptSerializer()).Serialize(itemCodes); ;
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
        public static string MedicineDetail(int itemId, string Batch)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.spMedicinesDetails(itemId,Batch).ToList();
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
                var query = db.spMedicinesDetailsfromopd(itemId).ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
        }
        public class BatchStock
        {
            public string BatchNum { get; set; }
            public string Source { get; set; }
        }
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
        public static string GetStockByBatch(int itemId, string batchNumber)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.spMedicinesDetails(itemId, batchNumber).ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
        }
        public class Medicines
        {
            public int Bill_ID { get; set; }
            public string Patient_ID { get; set; }
            public string CustomerName { get; set; }
            public string ReferBy { get; set; }
            public string Dept { get; set; }
            public decimal totalPayable { get; set; }
            public decimal DiscAmnt { get; set; }
            public decimal flatdisc { get; set; }
            public decimal DiscPercent { get; set; }
            public decimal AmntReceived { get; set; }
            public decimal BalanceAmount { get; set; }
            public decimal linediscount { get; set; }
            public string invNumber { get; set; }
            public List<Medicindetails> Save_list { get; set; }
        }

        public class Medicindetails
        {
            public int Itemid { get; set; }
            public string ItemName { get; set; }
            public decimal Amount { get; set; }
            public decimal DiscPer { get; set; }
            public decimal DiscAmount { get; set; }
            public decimal NetAmount { get; set; }
            public int Qty { get; set; }
            public decimal Stock { get; set; }
            public string batchno { get; set; }
            public decimal CGSAmount { get; set; }
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
                                  && p.IsPharmacy == true
                                  && p.Creation_Date.Value.Month == DateTime.Now.Month
                                  && p.Creation_Date.Value.Day == DateTime.Now.Day).Count() + 1;
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
            newBill.Disc_Adjustment = data.flatdisc;
            newBill.Total_Amount = data.totalPayable;
            newBill.Received_Amount = data.AmntReceived;
            newBill.Balance_Amount = data.BalanceAmount;
            newBill.Referred_By = data.ReferBy;
            newBill.line_disc = data.linediscount;
            newBill.pharmacy_Department = data.Dept;
            newBill.Patient_ID = patId;
            var PharmacyCodes = db.sys_Parms.Where(x => x.Name == "Pharmacy WareHouse").Select(x => x.Code).FirstOrDefault().ToString();
            newBill.Ware_House =Convert.ToString(PharmacyCodes);
            newBill.Sale_Return = "Return Against" + '-' + data.invNumber;
            newBill.UserID = Convert.ToInt32(UserId);
            newBill.IsPharmacy = true;
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
                Ar_Billing_Detail newBillDetails = new Ar_Billing_Detail();
                newBillDetails.Bill_ID = newBill.Bill_ID;
                newBillDetails.ParentTrans_Name = "IssueMedicine";
                newBillDetails.ParentTrans_Type = "Medicine";
                newBillDetails.Item_ID = dtls.Itemid;                
                newBillDetails.Item_Name = dtls.ItemName;
                var Item_Id = (from aac in db.INV_Items where (aac.Description == dtls.ItemName) select aac.Item_ID).FirstOrDefault();
                newBillDetails.Item_ID = Item_Id;
                newBillDetails.Amount = dtls.Amount;
                newBillDetails.Item_Type = "Medicine";
                newBillDetails.Discount_Percentage = dtls.DiscPer;
                newBillDetails.Discount_Amount = dtls.DiscAmount;
                newBillDetails.Net_Amount = dtls.NetAmount;
                newBillDetails.Qty = dtls.Qty;
                newBillDetails.Batch_No = dtls.batchno;
                var TotalRemainStock = dtls.Stock - dtls.Qty;
                newBillDetails.CGS = dtls.CGSAmount;
                var getttlStock = DBClass.getField("update INV_Items set Total_Qty= '" + TotalRemainStock + "' where Item_ID =" + dtls.Itemid);

                ListOfDetails.Add(newBillDetails);
                db.Ar_Billing_Details.InsertAllOnSubmit(ListOfDetails);
            }

            db.SubmitChanges();
            return newBill.Bill_ID.ToString();
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

        [WebMethod]
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
        public static string AllInvoiceNumbers()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var panel = (from data in db.Ar_Billings
                         where data.IsPharmacy == true && data.Invoice_No != null && (data.isCancel == false || data.isCancel == null)
                         select new
                         {
                             Bill_ID = data.Bill_ID,
                             Seq_InvoiceNo = data.Seq_InvoiceNo,
                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(panel);
        }

        [WebMethod]
        public static string SaleReturnItems()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var panel = (from data in db.INV_Items
                         where data.IsPharmacyItem == true
                         select new
                         {
                             Item_ID = data.Item_ID,
                             Description = data.Description,
                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(panel);
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
        public static string SaleReturnInvoiceDetail(int BillId)
        {
            string result = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.spSaleReturnInvoiceDetails(BillId).ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
        }

        [WebMethod]
        public static int SaveSaleReturnData(string AllItemDetail,string UserId)
        {

            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer js = new JavaScriptSerializer();
            var record = js.Deserialize<SaleReturnMaster>(AllItemDetail);
            Pharmacy_SaleReturn saleReturn = new Pharmacy_SaleReturn();
            saleReturn.Bill_ID = int.Parse(record.BillId);
            saleReturn.Seq_InvoiceNo = record.InvNo;
            saleReturn.Return_NO = DBClass.GetNewNumber("Return_NO", "Pharmacy_SaleReturns", "").ToString();
            saleReturn.Disc_Percentage = record.DisPer;
            saleReturn.Master_Discount_Amt = record.TotalDisAmt;
            saleReturn.UserId = UserId;
            saleReturn.TotalLine_Wise_Discount = record.TotalLineDisc;
            saleReturn.TotalDisc_Amount = record.TotalDisAmt;
            saleReturn.Disc_Adjustment = record.AdjustmentAmt;
            saleReturn.Net_Amount = record.Total;
            saleReturn.Ware_House = "008";
            saleReturn.Total_Amount = record.TotalPayable;
            saleReturn.Company_ID = AppConfig.Company_ID;
            saleReturn.Created_Date = DateTime.Now;
            saleReturn.Created_By = AppConfig.UserID;
            saleReturn.IsDeleted = false;
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
                    CGS = item.CGSAmount
                };
                db.Pharmacy_SaleReturn_Details.InsertOnSubmit(detail);
                db.SubmitChanges();
            }

            return saleReturnID;
        }
        public class SaleReturnMaster
        {
            public string BillId { get; set; }
            public string InvNo { get; set; }
            public decimal TotalPayable { get; set; }
            public decimal TotalLineDisc { get; set; }
            public decimal DisPer { get; set; }
            public decimal TotalDisAmt { get; set; }
            public decimal AdjustmentAmt { get; set; }
            public decimal Total { get; set; }
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
        }

    }
}