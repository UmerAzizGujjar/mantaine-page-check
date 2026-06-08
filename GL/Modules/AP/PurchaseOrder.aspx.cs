using AjaxControlToolkit.HTMLEditor.ToolbarButton;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Security.Cryptography;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web.Data.Extensions;

namespace PMS.AP
{
    public partial class PurchaseOrder : System.Web.UI.Page
    {

        DataTable dt;

        DataBaseDataContext db;
        protected void Page_Load(object sender, EventArgs e)
        {
            HyperLink1.Visible = false;
            if (!IsPostBack)
            {
                db = new DataBaseDataContext();
                BindSupplier();
                BindTerm();
                BindPaymentTerms();
                BindDeliveryTerms();
                BindPOType();
                //LoadPRNum();
                if (Request.QueryString["PO_ID"] != null)
                {
                    var getID = Request.QueryString["PO_ID"];
                    var gettype = (from a in db.AP_Purchase_Orders where a.PO_ID == Convert.ToInt32(getID) select a.File_Path).FirstOrDefault();
                    if (!string.IsNullOrEmpty(gettype))
                    {
                        HyperLink1.NavigateUrl = gettype;
                        HyperLink1.Visible = true;
                    }
                }
            }

        }
        [WebMethod]
        public static string getAdvanceTaxType()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from a in db.Advance_Taxes
                         where a.Active == true
                         select new
                         {
                             a.Advance_Tax_ID,
                             a.Advance_Tax_Perc,
                         }).ToList();

            return (new JavaScriptSerializer()).Serialize(query);
        }

        [WebMethod]
        public static string getFurtherTaxType()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from a in db.Further_Taxes
                         where a.Active == true
                         select new
                         {
                             a.Further_Tax_ID,
                             a.Further_Tax_Perc,
                         }).ToList();

            return (new JavaScriptSerializer()).Serialize(query);
        }



        [WebMethod]
        public static string GetWareHouseCondition()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dept = (from data in db.sys_Parms
                        where data.Name == "WareHouse For PO"
                        select
                          data.Code
                        ).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(dept);
        }
        [WebMethod]
        public static string Getprojection()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dept = (from data in db.sys_Parms
                        where data.Name == "Projection"
                        select
                          data.Code
                        ).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(dept);
        }

        [WebMethod]
        public static string getwtaxtype()

        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from a in db.Sales_Taxes
                         select new
                         {
                             a.Sales_Tax_ID,
                             a.Sales_Tax_Perc,
                         }).ToList();
            string data = string.Empty;
            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static bool UserEntryRights()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var uid = AppConfig.UserID;
                var hasEntryRights = db.Sys_Inv_OrignatorTempelate_Masters
                                  .Join(db.Sys_Inv_OrignatorTempelate_Detail_Forms,
                                        SATM => SATM.OrignatorTempelate_ID,
                                        SATDF => SATDF.OrignatorTempelate_ID,
                                        (SATM, SATDF) => new { SATM, SATDF })
                                  .Join(db.Sys_Inv_OrignatorTempelate_Details,
                                        temp => temp.SATM.OrignatorTempelate_ID,
                                        SATDO => SATDO.OrignatorTempelate_ID,
                                        (temp, SATDO) => new { temp.SATM, temp.SATDF, SATDO })
                                  .Any(temp => temp.SATM.IsActive == true && temp.SATM.IsDeleted == false && temp.SATDF.FormId == 3 && temp.SATDO.UserId == uid);

                return hasEntryRights;
            }
        }

        [WebMethod]
        public static string fillWarehouse()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Ware House"
                         select new ddlListItems
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(listItems);
        }

        [WebMethod]
        public static bool UserUnApproveEntryRights()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var userPermissions = (from data in db.aspnet_Users
                                       where data.UserId == AppConfig.UserID
                                       select new
                                       {
                                           data.IsInventoryUnApprove
                                       }).FirstOrDefault();
                bool UnApproveRight = userPermissions?.IsInventoryUnApprove ?? false;
                return UnApproveRight;
            }
        }
        [WebMethod]
        public static string LoadPOHeaderDetail(int PO_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Header = (from m in db.AP_Purchase_Orders
                          where m.PO_ID == PO_ID
                          select new
                          {
                              m.CS_Master_ID,
                              m.PO_ID,
                              m.Ware_House,
                              Ware_HouseText = (db.GetDataValueName("Ware House", m.Ware_House)),
                              m.PO_No,
                              m.PO_Date,
                              m.Due_Date,
                              m.Ref_No,
                              m.Term_ID,
                              m.Remarks,
                              m.Sub_Total,
                              m.Discount,
                              m.PO_Amount,
                              m.Vendor_ID,
                              m.Payment_Terms,
                              m.Delivery_Terms,
                              m.Frieght_Charges,
                              m.PO_Type,
                              m.Transaction_Type,
                              m.Warranty,
                              m.Disclaimer,
                              m.Status,
                              m.Total_ST_Amount,
                              m.Total_Adv_Amt,
                              m.Total_Further_Amt,
                              m.IsManual,
                              m.IsByDefault,
                              Vendor_Name = db.AP_Vendors.Where(po => po.Vendor_ID == m.Vendor_ID).Select(po => po.Vendor_Name),
                          }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(Header);
        }
        [WebMethod]
        public static string LoadPOItemDetail(int PO_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = (from d in db.AP_Purchase_Order_Items
                           join m in db.AP_Purchase_Orders
                            on d.PO_ID equals m.PO_ID
                           where m.PO_ID == PO_ID
                           select new
                           {
                               d.Item_Code,
                               Pack_Quantity = (from t in db.INV_Items where t.Item_Code == d.Item_Code.ToString() select t.Pack_Quantity).FirstOrDefault(),
                               d.Item_Name,
                               d.Unit,
                               UnitName = db.GetDataValueName("UOM", d.Unit),
                               d.Batch_No,
                               d.Expire_Date,
                               d.Qty,
                               d.UOM_Qty,
                               d.Rate,
                               d.Amount,
                               d.Discount_Amount,
                               d.Discount_Percentage,
                               d.SalTax_Amount,
                               d.AdvanceTax_Amount,
                               d.FurtherTax_Amount,
                               d.FurtherTax_Percentage,
                               d.FurtherTax_Id,
                               m.Total_Adv_Amt,
                               d.Fed_Percentage,
                               d.Delivery_Date,
                               d.SalTax_Id,
                               d.FedPercent_Id,
                               d.PRDetailId,
                               d.CS_Ven_No,
                               d.AdvanceTax_ID,
                               d.Bonus_Tax,
                               d.Bonus_Qty,
                               pr_id = DBClass.getField("select PR.PR_Num from Purchase_Requisition PR join Purchase_Requisition_Detail PRD on PR.PR_Id = PRD.PR_ID where PRD.PR_Detail_ID = " + d.PRDetailId),
                               TotalStock = db.GetInvenrtoryItemUomTotalStock(d.Item_Id ?? 0, m.Ware_House)
                           }).ToList();

            return (new JavaScriptSerializer()).Serialize(Details);
        }

        private void BindSupplier()
        {
            #region "Bind Supplier in Dropdown"
            DataTable dt = new DataTable();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var vendor = (from tbl in db.AP_Vendors
                          where tbl.IsActive == true
                          select new
                          {
                              VendorID = tbl.Vendor_ID,
                              VendorName = tbl.Vendor_Name,
                              IsActive = tbl.IsActive,
                          }).ToList();
            ddlVendor.DataSource = vendor;
            ddlVendor.DataTextField = "VendorName";
            ddlVendor.DataValueField = "VendorID";
            ddlVendor.Items.Add(new ListItem("Please Select", "0"));
            ddlVendor.DataBind();
            for (int i = 0; i < vendor.Count; i++)
            {
                for (int j = 0; j < ddlVendor.Items.Count; j++)
                {
                    if (Convert.ToInt32(vendor[i].VendorID) == Convert.ToInt32(ddlVendor.Items[j].Value) && vendor[i].IsActive == false)
                    {
                        ddlVendor.Items[j].Attributes.Add("disabled", "disabled");
                    }
                }
            }
            #endregion
        }

        private void BindTerm()
        {
            #region "Bind Terms and Conditions"
            object valueset;
            valueset = DBClass.GetValueSet("Terms and Conditions");
            ddlTerm.DataSource = valueset;
            ddlTerm.DataTextField = "DataValue_Description";
            ddlTerm.DataValueField = "DataValue_Name";
            ddlTerm.Items.Add(new ListItem("Please Select", "0"));
            ddlTerm.DataBind();
            #endregion
        }

        private void BindPaymentTerms()
        {
            #region "Bind Payment Terms"
            object valueset; //declare a single object for all valueset     
            valueset = DBClass.GetValueSet("PaymentTerms");
            ddlpayment.DataSource = valueset;
            ddlpayment.DataTextField = "DataValue_Description";
            ddlpayment.DataValueField = "DataValue_Name";
            ddlpayment.Items.Add(new ListItem("Please Select", "0"));
            ddlpayment.DataBind();
            valueset = DBClass.GetValueSet("Projection Type");
            ddlprojection.DataSource = valueset;
            ddlprojection.DataTextField = "DataValue_Description";
            ddlprojection.DataValueField = "DataValue_Name";
            ddlprojection.Items.Add(new ListItem("Please Select", "0"));
            ddlprojection.DataBind();
            #endregion
        }

        private void BindDeliveryTerms()
        {
            #region "Bind Delivery Terms"
            object valueset; //declare a single object for all valueset     
            valueset = DBClass.GetValueSet("DeliveryTerms");
            ddlDelivery.DataSource = valueset;
            ddlDelivery.DataTextField = "DataValue_Description";
            ddlDelivery.DataValueField = "DataValue_Name";
            ddlDelivery.Items.Add(new ListItem("Please Select", "0"));
            ddlDelivery.DataBind();
            #endregion
        }

        private void BindPOType()
        {
            #region "Bind POType"
            object valueset; //declare a single object for all valueset     
            valueset = DBClass.GetValueSet("PO Type");
            ddlPOType.DataSource = valueset;
            ddlPOType.DataTextField = "DataValue_Description";
            ddlPOType.DataValueField = "DataValue_Name";
            ddlPOType.Items.Add(new ListItem("Please Select", "0"));
            ddlPOType.DataBind();
            #endregion
        }

        //private void LoadPRNum()
        //{
        //    #region "Bind PRNUM in Dropdown"
        //    DataTable dt = new DataTable();
        //    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
        //    var vendor = db.sp_LoadPRNum();
        //    ddlPrNo.DataSource = vendor;
        //    ddlPrNo.DataTextField = "PR_Num";
        //    ddlPrNo.DataValueField = "PR_Id";
        //    ddlPrNo.DataBind();
        //    if (!IsPostBack)
        //    {
        //        ddlPrNo.Items.Insert(0, new ListItem("Please Select", "0"));
        //    }
        //    #endregion
        //}

        [WebMethod]
        public static string getDDLlist()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Sales Tax" || v.ValueSet_Description == "Fed Percentage"
                         select new ddlListItems
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                             Type = v.ValueSet_Description == "Sales Tax" ? "Sal" : "Fed"
                         }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);
        }
        [WebMethod]
        public static string GetPRNoByWarehouse(string Warehouse)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var POList = db.sp_LoadPRNumByWarehouse(Warehouse);
            return (new JavaScriptSerializer()).Serialize(POList);
        }
        [WebMethod]
        public static string GetPRNoBy()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var POList = db.sp_LoadPRNum();
            return (new JavaScriptSerializer()).Serialize(POList);
        }
        private class ddlListItems
        {
            public string DataValueName;
            public string DataValueDescription;
            public string Type;
        }
        public class MasterItemList
        {
            public string transtype { get; set; }
            public string txtst_amou { get; set; }
            public string Adv_amount { get; set; }
            public string PO_ID { get; set; }
            public string txtcsmasterid { get; set; }
            public string Purchase_No { get; set; }
            public string Date { get; set; }
            public string Due_Date { get; set; }
            public string RefNo { get; set; }
            public string VendorName { get; set; }
            public string Term_ID { get; set; }
            public string Remarks { get; set; }
            public string Warranty { get; set; }
            public string Disclaimer { get; set; }
            public string SubTotal { get; set; }
            public string DiscountAmount { get; set; }
            public string NetAmount { get; set; }
            public string Purchase_Date { get; set; }
            public string PaymentTerms { get; set; }
            public string DeliveryTerms { get; set; }
            public string FreightCharges { get; set; }
            public string ImagePath { get; set; }
            public string POType { get; set; }
            public string WareHouse { get; set; }
            public string Further_amount { get; set; }
            public bool IsManual { get; set; }
            public bool IsByDefault { get; set; }
            public List<DetailItemList> ItemList { get; set; }
        }
        public class DetailItemList
        {
            public string ItemCode { get; set; }
            public string ItemName { get; set; }

            public string AdvanceTax_Amount { get; set; }
            public string Unit { get; set; }
            public string BatchNo { get; set; }
            public string ExpireDate { get; set; }
            public string Qty { get; set; }
            public string Rate { get; set; }
            public string Amount { get; set; }
            public string DisPer { get; set; }
            public string DisAmount { get; set; }
            public string DateTime { get; set; }
            public string SalTax_Amount { get; set; }
            public string FedPercentId { get; set; }
            public string SalTax_Id { get; set; }
            public string AdvanceTax_ID { get; set; }
            public string Fed_Percentage { get; set; }
            public int PRDetailId { get; set; }
            public string FurtherTax_Amount { get; set; }
            public string FurtherTax_Percentage { get; set; }
            public int FurtherTax_Id { get; set; }
            public string BonusQty { get; set; }
            public string BonusTax { get; set; }
            public string UOM_Qty { get; set; }

        }
        [WebMethod]
        public static int SavePurchaseItemDetail(string btnSave, string AllItemDetail)
        {

            string PoNo = "";
            AP_Purchase_Order PO = new AP_Purchase_Order();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<MasterItemList>(AllItemDetail);

            if (btnSave == "Update")
            {
                // Retrieve the existing record
                AP_Purchase_Order existingItem = db.AP_Purchase_Orders.SingleOrDefault(t => t.PO_No == int.Parse(record.Purchase_No));
                if (existingItem != null)
                {
                    if (record.RefNo != "")
                    {
                        existingItem.Ref_No = record.RefNo;
                    }
                    existingItem.Update_Time = DateTime.Now;
                    existingItem.Updated_By = AppConfig.UserID;
                    existingItem.Vendor_ID = Convert.ToInt32(record.VendorName);
                    existingItem.Remarks = record.Remarks;
                    existingItem.Warranty = record.Warranty;
                    existingItem.Disclaimer = record.Disclaimer;
                    existingItem.Ware_House = record.WareHouse;
                    if (record.txtcsmasterid != "")
                    {
                        existingItem.CS_Master_ID = Convert.ToInt32(record.txtcsmasterid);
                    }
                    if (record.SubTotal != "")
                    {
                        existingItem.Sub_Total = Convert.ToDecimal(record.SubTotal);
                    }
                    if (record.txtst_amou != "")
                    {
                        existingItem.Total_ST_Amount = Convert.ToDecimal(record.txtst_amou);
                    }
                    if (record.Adv_amount != "")
                    {
                        existingItem.Total_Adv_Amt = Convert.ToDecimal(record.Adv_amount);
                    }
                    if (record.DiscountAmount != "")
                    {
                        existingItem.Discount = Convert.ToDecimal(record.DiscountAmount);
                    }
                    if (record.NetAmount != "")
                    {
                        existingItem.PO_Amount = Convert.ToDecimal(record.NetAmount);
                    }
                    if (record.Further_amount != "")
                    {
                        existingItem.Total_Further_Amt = Convert.ToDecimal(record.Further_amount);
                    }

                    existingItem.PO_Date = Convert.ToDateTime(record.Purchase_Date);
                    existingItem.Due_Date = Convert.ToDateTime(record.Due_Date);
                    existingItem.PO_No = int.Parse(record.Purchase_No);
                    if (record.transtype != "")
                    {
                        existingItem.Transaction_Type = record.transtype;
                    }
                    existingItem.Payment_Terms = record.PaymentTerms;
                    existingItem.Delivery_Terms = record.DeliveryTerms;
                    existingItem.Term_ID = record.Term_ID;
                    existingItem.IsManual = record.IsManual;
                    existingItem.IsByDefault = record.IsByDefault;
                    if (record.FreightCharges != "")
                    {
                        existingItem.Frieght_Charges = Convert.ToDecimal(record.FreightCharges);
                    }
                    existingItem.PO_Type = record.POType;
                    db.SubmitChanges();
                    PoNo = existingItem.PO_ID.ToString();
                }
            }
            else
            {
                PO.Company_ID = AppConfig.Company_ID;
                PO.Ref_No = record.RefNo;
                PO.Creation_Time = DateTime.Now;
                PO.Created_By = AppConfig.UserID;
                PO.Vendor_ID = Convert.ToInt32(record.VendorName);
                PO.Remarks = record.Remarks;
                PO.Warranty = record.Warranty;
                PO.Disclaimer = record.Disclaimer;
                PO.Ware_House = record.WareHouse;
                if (record.SubTotal != "")
                {
                    PO.Sub_Total = Convert.ToDecimal(record.SubTotal);
                }
                PO.Discount = Convert.ToDecimal(record.DiscountAmount);
                if (record.NetAmount != "")
                {
                    PO.PO_Amount = Convert.ToDecimal(record.NetAmount);
                }
                if (record.txtst_amou != "")
                {
                    PO.Total_ST_Amount = Convert.ToDecimal(record.txtst_amou);
                }
                if (record.Adv_amount != "")
                {
                    PO.Total_Adv_Amt = Convert.ToDecimal(record.Adv_amount);
                }
                if (record.Further_amount != "")
                {
                    PO.Total_Further_Amt = Convert.ToDecimal(record.Further_amount);
                }
                PO.PO_Date = Convert.ToDateTime(record.Purchase_Date);
                PO.Due_Date = Convert.ToDateTime(record.Due_Date);
                PO.PO_No = DBClass.GetNewNumber("PO_No", "AP_Purchase_Orders", "");
                PO.Transaction_Type = "PO";
                PO.Term_ID = record.Term_ID;
                PO.Payment_Terms = record.PaymentTerms;
                if (record.FreightCharges != "")
                {
                    PO.Frieght_Charges = Convert.ToDecimal(record.FreightCharges);
                }
                PO.Delivery_Terms = record.DeliveryTerms;
                PO.PO_Type = record.POType;
                PO.Status = "Created";
                PO.IsClosed = false;
                PO.IsDeleted = false;
                PO.IsManual = record.IsManual;
                PO.IsByDefault = record.IsByDefault;
                db.AP_Purchase_Orders.InsertOnSubmit(PO);
                db.SubmitChanges();
                PoNo = PO.PO_ID.ToString();
            }
            var existingItems = db.AP_Purchase_Order_Items.Where(t => t.PO_ID == int.Parse(PoNo)).ToList();
            if (existingItems != null)
            {
                db.AP_Purchase_Order_Items.DeleteAllOnSubmit(existingItems);
                db.SubmitChanges();
            }
            foreach (var POitem in record.ItemList)
            {
                AP_Purchase_Order_Item ltd = new AP_Purchase_Order_Item();
                ltd.Discount_Percentage = Convert.ToDecimal(POitem.DisPer);
                
                if (POitem.DisAmount != "")
                {
                    ltd.Discount_Amount = Convert.ToDecimal(POitem.DisAmount);
                }
                else
                {
                    ltd.Discount_Amount = 0;
                }
                    ltd.Item_Code = Convert.ToInt32(POitem.ItemCode);
                ltd.Item_Name = POitem.ItemName;
                if (btnSave == "Save")
                    ltd.Purchase_Qty = 0;
                ltd.Stock_Status = false;
                ltd.PO_ID = int.Parse(PoNo);
                ltd.Unit = POitem.Unit;
                ltd.Qty = Convert.ToDecimal(POitem.Qty);
                ltd.Bonus_Qty = !string.IsNullOrEmpty(POitem.BonusQty) ? Convert.ToDecimal(POitem.BonusQty): 0;
                if (!string.IsNullOrEmpty(POitem.UOM_Qty))
                {
                    ltd.UOM_Qty = Convert.ToDecimal(POitem.UOM_Qty);
                }
                else
                {
                    ltd.UOM_Qty = null;
                }
                ltd.Rate = Convert.ToDecimal(POitem.Rate);
                ltd.Amount = Convert.ToDecimal(POitem.Amount);
                //if (POitem.Fed_Percentage != "")
                //{
                //    ltd.Fed_Percentage = Convert.ToDecimal(POitem.Fed_Percentage);
                //}
                if (!string.IsNullOrEmpty(POitem.Fed_Percentage) &&
               decimal.TryParse(POitem.Fed_Percentage, out decimal fedPerc))
                {
                    ltd.Fed_Percentage = fedPerc; 
                }
                else
                {
                    ltd.Fed_Percentage = null; 
                }
                if (POitem.DateTime != "")
                {
                    ltd.Delivery_Date = Convert.ToDateTime(POitem.DateTime);
                }
                if (POitem.SalTax_Amount != "")
                {
                    ltd.SalTax_Amount = Convert.ToDecimal(POitem.SalTax_Amount);
                }
                if (POitem.AdvanceTax_Amount != "")
                {
                    ltd.AdvanceTax_Amount = Convert.ToDecimal(POitem.AdvanceTax_Amount);
                }
                if (POitem.FurtherTax_Amount != "")
                {
                    ltd.FurtherTax_Amount = Convert.ToDecimal(POitem.FurtherTax_Amount);
                }
                if (POitem.FurtherTax_Percentage != "")
                {
                    ltd.FurtherTax_Percentage = Convert.ToDecimal(POitem.FurtherTax_Percentage);
                }
                if (!string.IsNullOrEmpty(POitem.BonusTax))
                {
                    ltd.Bonus_Tax = Convert.ToDecimal(POitem.BonusTax);
                }
                else
                {
                    ltd.Bonus_Tax = 0;
                }
                ltd.FurtherTax_Id = Convert.ToInt32(POitem.FurtherTax_Id);
                ltd.FedPercent_Id = POitem.FedPercentId;
                ltd.SalTax_Id = Convert.ToInt32(POitem.SalTax_Id);
                ltd.AdvanceTax_ID = Convert.ToInt32(POitem.AdvanceTax_ID);
                ltd.PRDetailId = Convert.ToInt32(POitem.PRDetailId);
                ltd.Item_Id = Convert.ToInt32(DBClass.getField("select Item_Id from inv_items where Item_Code=" + Convert.ToInt32(POitem.ItemCode)));
                db.AP_Purchase_Order_Items.InsertOnSubmit(ltd);
                db.SubmitChanges();
            }
            return int.Parse(PoNo);
        }

        public struct RequisitionItem
        {
            public string Item_Code;
            public int Item_ID;
            public string Description;
            public string Unit;
            public string UnitName;
            public string SalPercentageName;
            public string FedPercentageName;
            public decimal Sale_Rate;
            public string Item_Type;
            public string Internal_Part_No;
            public bool Pack;
            public int Pack_Quantity;
            public string Pack_Unit;
            public bool Active;
        }
        [WebMethod]
        public static string PerformPrNoSearch(int pr_id)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var query = db.sp_getItemsAgainstPrNo(pr_id).ToList();
            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]

        public static string SearchItem(int ItemCode)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            List<RequisitionItem> listItem = new List<RequisitionItem>();
            var items = (from tbl in db.INV_Items
                         where tbl.Item_ID == ItemCode
                         select tbl).ToList();
            foreach (var item in items)
            {
                RequisitionItem invItems = new RequisitionItem();
                invItems.Item_Code = item.Item_Code;
                invItems.Item_ID = item.Item_ID;
                invItems.Description = item.Description;
                invItems.Sale_Rate = Convert.ToDecimal(item.Purchase_Rate);
                invItems.Unit = item.Unit;
                if (item.Pack == null)
                {
                    invItems.Pack = false;
                    invItems.Pack_Quantity = (Int32)0.00;
                }
                else
                {
                    invItems.Pack = (bool)item.Pack;
                    invItems.Pack_Quantity = (int)item.Pack_Quantity;
                }
                invItems.Pack_Unit = item.Pack_Unit;
                invItems.UnitName = db.GetDataValueName("UOM", item.Unit); //updated Unit to UOM
                invItems.Internal_Part_No = item.Internal_Part_No;
                invItems.Active = item.Active ?? false;
                listItem.Add(invItems);
            }
            return (new JavaScriptSerializer()).Serialize(listItem);

        }
        [WebMethod]
        public static string GetPODetail(int PO_No)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var PODetail = (from m in db.AP_Purchase_Orders
                            join d in db.AP_Purchase_Order_Items
                            on m.PO_ID equals d.PO_ID
                            where m.PO_No == PO_No
                            select new
                            {
                                d.Item_Code,
                                d.Item_Name,
                                Unit = db.GetDataValueName("UOM", d.Unit),
                                d.Qty,
                                d.Rate,
                                d.Discount_Amount,
                                d.Discount_Percentage,
                                d.Amount,

                            }).ToList();

            return ((new JavaScriptSerializer()).Serialize(PODetail));
        }
        [WebMethod]
        public static string GetNewPurchaseNo()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var PO_No = DBClass.GetNewNumber("PO_No", "AP_Purchase_Orders", "");
            return PO_No.ToString();
        }
        [WebMethod]
        public static string getPurchaseByID(string PRID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            int PRId = Convert.ToInt32(PRID);
            var listPurchaseDetails = db.sp_GetPRDetailByPRID(PRId).ToList();
            return (new JavaScriptSerializer()).Serialize(listPurchaseDetails);
        }
        [WebMethod]
        public static string ApprovePO(string POid)
        {
            var userid = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.spApprovePurchaseOrder(Convert.ToInt32(POid), userid);
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string UnApprovePO(string POid)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.spUnApprovePurchaseOrder(Convert.ToInt32(POid));
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string CancelEntry(string POid)
        {
            try
            {
                var userid = Convert.ToString(AppConfig.UserID);
                DataBaseDataContext db = new DataBaseDataContext();
                var result = db.spCancelPO(Convert.ToInt32(POid), userid);
                var resultList = result.ToList();
                if (resultList.Any())
                {
                    var serializedResult = (new JavaScriptSerializer()).Serialize(resultList);
                    return serializedResult;
                }
                else
                {
                    return "{ 'error': 'No data returned from the stored procedure.' }";
                }
            }
            catch (Exception ex)
            {
                return "{ 'error': '" + ex.Message + "' }";
            }
        }
        [WebMethod]
        public static string GetBatchProjectedQuantities(string itemIdsJson, string projectionDate, string warehouseId)
        {
            try
            {
                List<int> itemIds = new List<int>();
                if (!string.IsNullOrEmpty(itemIdsJson))
                {
                    itemIds = new JavaScriptSerializer().Deserialize<List<int>>(itemIdsJson);
                }

                Dictionary<int, decimal> projectedQtys = new Dictionary<int, decimal>();

                if (itemIds.Count > 0 && !string.IsNullOrEmpty(projectionDate) && !string.IsNullOrEmpty(warehouseId) && warehouseId != "0")
                {
                    using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                    {
                        // Convert front-end date (DD MMM YYYY) to SQL format (YYYY-MM-DD)
                        DateTime parsedDate = DateTime.ParseExact(projectionDate, "dd MMM yyyy", System.Globalization.CultureInfo.InvariantCulture);
                        string sqlDate = parsedDate.ToString("yyyy-MM-dd");
                        string currentDate = DateTime.Now.ToString("yyyy-MM-dd");

                        // Create a comma-separated list of IDs for the IN clause
                        string idList = string.Join(",", itemIds);

                        // Query for bills between projection date and current date
                        string query = $@"
                               SELECT bd.Item_ID, ISNULL(SUM(bd.Qty), 0) as TotalQty
                    FROM AR_Billing_Details bd
                    INNER JOIN Ar_Billings b ON bd.Bill_ID = b.Bill_ID
                    WHERE bd.Item_ID IN (5952)
                    AND b.Ware_House = '008'
                  AND CONVERT(DATE, b.Invoice_Date) BETWEEN CONVERT(DATE, '2026-05-01') AND CONVERT(DATE, '2026-06-08')
                    AND (b.isCancel = 0 OR b.isCancel IS NULL)
                    and b.IsPharmacy =1
                    GROUP BY bd.Item_ID";

                        DataTable dt = DBClass.getDataTable(query);

                        foreach (DataRow row in dt.Rows)
                        {
                            int itemId = Convert.ToInt32(row["Item_ID"]);
                            decimal qty = Convert.ToDecimal(row["TotalQty"]);
                            projectedQtys[itemId] = qty;
                        }
                    }

                    // Set default 0 for items without projected quantity
                    foreach (int itemId in itemIds)
                    {
                        if (!projectedQtys.ContainsKey(itemId))
                        {
                            projectedQtys[itemId] = 0;
                        }
                    }
                }

                return new JavaScriptSerializer().Serialize(projectedQtys);
            }
            catch (Exception ex)
            {
                return "{}";
            }
        }

        [WebMethod]
        public static string GetVendorItems(string vendorId)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

                // Get items from AP_Vendor_Pharmacy_Items table for this vendor
                var query = (from vi in db.AP_Vendor_Pharmacy_Items
                             join i in db.INV_Items on vi.ItemId equals i.Item_ID
                             where vi.Vendor_Id == Convert.ToInt32(vendorId)
                                   && i.Active == true
                                   && (i.Services == null || i.Services != true)
                             select new
                             {
                                 i.Item_ID,
                                 i.Item_Code,
                                 Description = i.Description,
                                 Unit = db.GetDataValueName("UOM", i.Unit) ?? "",
                                 Purchase_Rate = i.Purchase_Rate != null ? i.Purchase_Rate : 0,
                                 UOM_Qty = i.UOM_Qty != null ? i.UOM_Qty : 1,
                                 Qty = 1, // Default quantity
                                 TotalStock = db.GetInvenrtoryItemUomTotalStock(i.Item_ID, i.InventoryOrg) ?? 0,
                                 vi.Vendor_Id
                             })
                             .Distinct()
                             .OrderBy(x => x.Item_Code)
                             .ToList();

                return (new JavaScriptSerializer()).Serialize(query);
            }
            catch (Exception ex)
            {
                // Log the error
                return (new JavaScriptSerializer()).Serialize(new List<object>());
            }
        }
        [WebMethod]
        public static string GetAllitem(string searchText, string warehouseId)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext();

                var Details = db.INV_Items
                    .Where(x => (string.IsNullOrEmpty(searchText)
                                || x.Item_Code.Contains(searchText)
                                || x.Description.Contains(searchText))
                             
                             && x.Active == true
                             && x.Services != true
                             && (string.IsNullOrEmpty(warehouseId) || x.InventoryOrg == warehouseId)
                         )
                    .OrderBy(x => x.Item_Code) 
                    .Take(200)
                    .Select(x => new
                    {
                        Item_ID = x.Item_ID,
                        Item_Code = x.Item_Code,
                        Description = x.Description,
                        Unit = db.GetDataValueName("UOM", x.Unit) ?? "",
                        Purchase_Rate = x.Purchase_Rate != null ? x.Purchase_Rate : 0,
                        UOM_Qty = x.UOM_Qty != null ? x.UOM_Qty : 1,
                        TotalStock = db.GetInvenrtoryItemUomTotalStock(x.Item_ID, x.InventoryOrg)
                    })
                    .ToList();

                return (new JavaScriptSerializer()).Serialize(Details);
            }
            catch (Exception)
            {
                return (new JavaScriptSerializer()).Serialize(new List<object>());
            }
        }
    }
}