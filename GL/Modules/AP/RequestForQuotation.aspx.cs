using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.AP
{
    public partial class RequestForQuotation : System.Web.UI.Page
    {
        DataTable dt;
        DataBaseDataContext db;
        protected void Page_Load(object sender, EventArgs e)
        {
            HyperLink1.Visible = false;
            if (!IsPostBack)
            {
                db = new DataBaseDataContext();
                BindPaymentTerms();
                BindTerm();
                BindVendors();
                Bindwarehouse();
               
                if (Request.QueryString["RFQ_ID"] != null)
                {
                    var getID = Request.QueryString["RFQ_ID"];
                    var gettype = (from a in db.AP_RequestForQuotations where a.RFQ_ID == Convert.ToInt32(getID) select a.File_Path).FirstOrDefault();
                    if (!string.IsNullOrEmpty(gettype))
                    {
                        HyperLink1.NavigateUrl = gettype;
                        HyperLink1.Visible = true;
                    }

                }
            }
        }
        [WebMethod]
        public static string GetNewRFQNo()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var PO_No = DBClass.GetNewNumber("RFQ_No", "AP_RequestForQuotations", "");
            return PO_No.ToString();
        }
        private void BindPaymentTerms()
        {
            #region "Bind Payment Terms"
            object valueset;
            valueset = DBClass.GetValueSet("PaymentTerms");
            ddlPaymentTerms.DataSource = valueset;
            ddlPaymentTerms.DataTextField = "DataValue_Description";
            ddlPaymentTerms.DataValueField = "DataValue_Name";
            ddlPaymentTerms.Items.Add(new ListItem("Please Select", "0"));
            ddlPaymentTerms.DataBind();
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
        private void Bindwarehouse()
        {
            #region "Bind Terms and Conditions"
            object valueset;
            valueset = DBClass.GetValueSet("Ware House");
            ddlWareHouse.DataSource = valueset;
            ddlWareHouse.DataTextField = "DataValue_Description";
            ddlWareHouse.DataValueField = "DataValue_Name";
            ddlWareHouse.Items.Add(new ListItem("Please Select", "0"));
            ddlWareHouse.DataBind();
            #endregion
        }
        private void BindVendors()
        {
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
            ddlVendors.DataSource = vendor;
            ddlVendors.DataTextField = "VendorName";
            ddlVendors.DataValueField = "VendorID";
            ddlVendors.Items.Add(new ListItem("Please Select", "0"));
            ddlVendors.DataBind();
            for (int i = 0; i < vendor.Count; i++)
            {
                for (int j = 0; j < ddlVendors.Items.Count; j++)
                {
                    if (Convert.ToInt32(vendor[i].VendorID) == Convert.ToInt32(ddlVendors.Items[j].Value) && vendor[i].IsActive == false)
                    {
                        ddlVendors.Items[j].Attributes.Add("disabled", "disabled");
                    }
                }
            }
        }
      
        [WebMethod]
        public static string gettaxtype()

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
        public static string GetWareHouseCondition()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dept = (from data in db.sys_Parms
                        where data.Name == "WareHouse For PR"
                        select
                          data.Code
                        ).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(dept);
        }


        [WebMethod]
        public static string GetPRNoByWarehouse_RFQ()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var RFQ = db.sp_LoadPRNumOnRFQ();
            return (new JavaScriptSerializer()).Serialize(RFQ);
        }
        [WebMethod]
        public static string getPRByID(string PRID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            int PRId = Convert.ToInt32(PRID);
            var listPRDetails = db.sp_GetPRDetailByPRID(PRId).ToList();
            return (new JavaScriptSerializer()).Serialize(listPRDetails);
        }
        [WebMethod]
        public static string getPRNos()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Department"
                         select new ddlListItems
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                             Type = v.ValueSet_Description == "Department" ? "DPT" : "INV"
                         }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);
        }

        [WebMethod]
        public static string LoadRFQHeaderDetail(int RFQ_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Header = (from m in db.AP_RequestForQuotations
                          where m.RFQ_ID == RFQ_ID
                          select new
                          {
                              m.RFQ_ID,
                              m.RFQ_No,
                              m.RFQ_Date,
                              m.Ref_No,
                              m.Remarks,
                              m.DueDate,
                              m.PaymentTerms,
                              m.Ware_House,
                              m.Term_ID,
                              m.QuotationValidty,
                              m.Status,
                              Vendor_Name = db.AP_Vendors.Where(po => po.Vendor_ID == m.Vendor_ID).Select(po => po.Vendor_Name),
                          }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(Header);
        }
        [WebMethod]
        public static string GetwarehousebyPrno(int prno)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Header = (from m in db.Purchase_Requisitions
                          where m.PR_Id == prno
                          select new
                          {
                              m.Warehouse,
                          }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(Header);
        }
        [WebMethod]
        public static string LoadRFQItemDetail(int RFQ_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = (from d in db.AP_RequestForQuotation_Items
                           join m in db.AP_RequestForQuotations
                            on d.RFQ_ID equals m.RFQ_ID
                           where m.RFQ_ID == RFQ_ID
                           select new
                           {
                               d.Item_Code,
                               d.Item_Name,
                               d.Qty,
                               d.UnitPrice,
                               d.SalTax_Id,
                               d.PRDetailId,
                               d.Required_Date,
                               d.TotalPrice,
                               PR_Num = DBClass.getField("select PR.PR_Num from Purchase_Requisition PR join Purchase_Requisition_Detail PRD on PR.PR_Id = PRD.PR_ID where PRD.PR_Detail_ID = " + d.PRDetailId),
                               PR_ID = DBClass.getField("select PR.PR_Id from Purchase_Requisition PR join Purchase_Requisition_Detail PRD on PR.PR_Id = PRD.PR_ID where PRD.PR_Detail_ID = " + d.PRDetailId),
                               ItemID = Convert.ToInt32(DBClass.getField("select Item_Id from inv_items where Item_Code=" + Convert.ToInt32(d.Item_Code))),
                               Unit = Convert.ToString(DBClass.getField("select isnull(dbo.GetDataValueName('UOM',inv_items.Unit),'') as Unit from inv_items where Item_Code=" + Convert.ToInt32(d.Item_Code))),
                           }).ToList();

            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string LoadRFQVendors(int RFQ_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = (from d in db.AP_RequestForQuotation_Vendors
                           join m in db.AP_RequestForQuotations
                            on d.RFQ_ID equals m.RFQ_ID
                           where m.RFQ_ID == RFQ_ID
                           select new
                           {
                               d.VendorId,
                               d.VendorName,
                           }).ToList();

            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string GetVendorsforReports(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = (from d in db.AP_RequestForQuotation_Vendors
                           where d.RFQ_ID == id
                           select new
                           {
                               d.VendorId,

                           }).ToList();

            return (new JavaScriptSerializer()).Serialize(Details);
        }
        public class MasterItemList
        {
            public string RFQ_ID { get; set; }
            public string RFQ_No { get; set; }
            public string RefNo { get; set; }
            public string VendorName { get; set; }
            public string Remarks { get; set; }
            public string RFQ_Date { get; set; }
            public string DueDate { get; set; }
            public string Term_ID { get; set; }
            public string PaymentTerms { get; set; }
            public string wareHouse { get; set; }
            public string QuotationValidty { get; set; }
            public List<DetailItemList> ItemList { get; set; }
            public List<VendorItemList> Vendorlist { get; set; }
        }
        public class DetailItemList
        {
            public string ItemCode { get; set; }
            public string ItemName { get; set; }
            public string Unit { get; set; }
            public string Qty { get; set; }
            public string UnitPrice { get; set; }
            public string TotalPrice { get; set; }
            public string Required_Date { get; set; }
            public string SalTax_Id { get; set; }
            public int PRDetailId { get; set; }

        }
        public class VendorItemList
        {
            public string VendorID { get; set; }
            public string VendorName { get; set; }
        }
        [WebMethod]
        public static int SaveRFQItemDetail(string btnSave, string AllItemDetail)
        {
            string RFQNo = "";
            AP_RequestForQuotation RFQ = new AP_RequestForQuotation();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<MasterItemList>(AllItemDetail);
            if (btnSave == "Update")
            {
                AP_RequestForQuotation lstItemexist = db.AP_RequestForQuotations.SingleOrDefault(t => t.RFQ_ID == int.Parse(record.RFQ_ID));
                if (lstItemexist != null)
                {
                    if (record.RefNo != "")
                    {
                        lstItemexist.Ref_No = record.RefNo;
                    }
                    lstItemexist.Remarks = record.Remarks;
                    lstItemexist.RFQ_Date = Convert.ToDateTime(record.RFQ_Date);
                    lstItemexist.DueDate = Convert.ToDateTime(record.DueDate);
                    lstItemexist.PaymentTerms = Convert.ToString(record.PaymentTerms);
                    lstItemexist.Term_ID = record.Term_ID;
                    lstItemexist.Ware_House = record.wareHouse;
                    lstItemexist.QuotationValidty = Convert.ToString(record.QuotationValidty);
                    lstItemexist.RFQ_No = int.Parse(record.RFQ_No);

                    lstItemexist.Update_Time = DateTime.Now;
                    lstItemexist.Updated_By = AppConfig.UserID;
                    db.SubmitChanges();
                    RFQNo = lstItemexist.RFQ_ID.ToString();
                }
            }
            else
            {
                RFQ.Company_ID = AppConfig.Company_ID;
                RFQ.Ref_No = record.RefNo;
                RFQ.Remarks = record.Remarks;
                RFQ.RFQ_Date = Convert.ToDateTime(record.RFQ_Date);
                RFQ.RFQ_No = DBClass.GetNewNumber("RFQ_No", "AP_RequestForQuotations", "");
                RFQ.DueDate = Convert.ToDateTime(record.DueDate);
                RFQ.Term_ID = record.Term_ID;
                RFQ.Ware_House = record.wareHouse;
                RFQ.PaymentTerms = Convert.ToString(record.PaymentTerms);
                RFQ.QuotationValidty = Convert.ToString(record.QuotationValidty);
                RFQ.Creation_Time = DateTime.Now;
                RFQ.Created_By = AppConfig.UserID;
                RFQ.Status = "Created";
                RFQ.IsDeleted = false;
                db.AP_RequestForQuotations.InsertOnSubmit(RFQ);
                db.SubmitChanges();
                RFQNo = RFQ.RFQ_ID.ToString();
            }
            ///**********Deleting Previous details**************/
            if (btnSave == "Update")
            {
                List<AP_RequestForQuotation_Item> lstRFQItemDetails = db.AP_RequestForQuotation_Items.Where(t => t.RFQ_ID == int.Parse(record.RFQ_ID)).ToList();
                db.AP_RequestForQuotation_Items.DeleteAllOnSubmit(lstRFQItemDetails);
                db.SubmitChanges();
            }
            foreach (var RFQitem in record.ItemList)
            {
                AP_RequestForQuotation_Item ltd = new AP_RequestForQuotation_Item();
                ltd.Item_Code = Convert.ToInt32(RFQitem.ItemCode);
                ltd.Item_Name = RFQitem.ItemName;
                ltd.RFQ_ID = int.Parse(RFQNo);
                ltd.Qty = Convert.ToDecimal(RFQitem.Qty);
                ltd.UnitPrice = Convert.ToDecimal(RFQitem.UnitPrice);
                ltd.TotalPrice = Convert.ToDecimal(RFQitem.TotalPrice);
                if (RFQitem.Required_Date != "")
                {
                    ltd.Required_Date = Convert.ToDateTime(RFQitem.Required_Date);
                }
                ltd.SalTax_Id = Convert.ToInt32(RFQitem.SalTax_Id);
                ltd.PRDetailId = Convert.ToInt32(RFQitem.PRDetailId);
                ltd.Item_Id = Convert.ToInt32(DBClass.getField("select Item_Id from inv_items where Item_Code=" + Convert.ToInt32(RFQitem.ItemCode)));
                db.AP_RequestForQuotation_Items.InsertOnSubmit(ltd);
                db.SubmitChanges();
            }
            if (btnSave == "Update")
            {
                List<AP_RequestForQuotation_Vendor> lstRFQVendorDetails = db.AP_RequestForQuotation_Vendors.Where(t => t.RFQ_ID == int.Parse(record.RFQ_ID)).ToList();
                db.AP_RequestForQuotation_Vendors.DeleteAllOnSubmit(lstRFQVendorDetails);
                db.SubmitChanges();
            }
            foreach (var RFQvendor in record.Vendorlist)
            {
                AP_RequestForQuotation_Vendor ltd = new AP_RequestForQuotation_Vendor();
                ltd.VendorId = Convert.ToInt32(RFQvendor.VendorID);
                ltd.VendorName = RFQvendor.VendorName;
                ltd.RFQ_ID = int.Parse(RFQNo);
                db.AP_RequestForQuotation_Vendors.InsertOnSubmit(ltd);
                db.SubmitChanges();
            }
            return int.Parse(RFQNo);
        }

        [WebMethod]
        public static string ApprovePO(string RFQid)
        {
            var userid = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.spApproveRFQ(Convert.ToInt32(RFQid), userid);
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string UnApprovePO(string RFQid)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.spUnApproveRFQ(Convert.ToInt32(RFQid));
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        private class ddlListItems
        {
            public string DataValueName;
            public string DataValueDescription;
            public string Type;
        }
    }
}