using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web;
using static PMS.Inventory.GoodsIssuanceNote;

namespace PMS.Modules.Inventory
{
    public partial class GoodsRerturnNote : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string GetNewSRNNo()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var SRN_No = DBClass.GetNewNumber("Store_Return_NO", "Goods_Return_Notes", "");
            return SRN_No.ToString();
        }
        [WebMethod]
        public static string LoadDepartments()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Department"
                         select new
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static string LoadOrganizations()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Ware House"
                         select new
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,

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
        //[WebMethod]
        //public static string GetGIN()
        //{
        //    DataBaseDataContext db = new DataBaseDataContext();
        //    var query = (from SIN_NO in db.Store_Issues join SID in db.Store_Issue_Details
        //                 on SIN_NO.Store_Issue_Id equals SID.Store_Issue_Id
        //                 where SIN_NO.Status == "Approved"
        //                 orderby SIN_NO.Store_Issue_Id descending
        //                 select new
        //                 {
        //                     S_No = SIN_NO.Store_Issue_No,
        //                     S_Id = SIN_NO.Store_Issue_Id,
        //                     Issue_Qty =SID.Issue_Qty - (db.Goods_Return_Details
        //                            .Where(gr => gr.SIN_Details == SID.Store_Issue_Detail_Id)
        //                            .Sum(gr => (decimal?)gr.Stock_Return_Qty) ?? 0)
        //                 }).ToList();
        //    return (new JavaScriptSerializer()).Serialize(query);
        //}
        [WebMethod]
        public static string GetGIN()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var query =
                (from si in db.Store_Issues
                 join sid in db.Store_Issue_Details
                     on si.Store_Issue_Id equals sid.Store_Issue_Id
                 where si.Status == "Approved"
                 group sid by new
                 {
                     si.Store_Issue_Id,
                     si.Store_Issue_No
                 } into g
                 let NetQty =
                     g.Sum(x =>
                         x.Issue_Qty -
                         (db.Goods_Return_Details
                             .Where(gr => gr.SIN_Details == x.Store_Issue_Detail_Id)
                             .Sum(gr => (decimal?)gr.Stock_Return_Qty) ?? 0)
                     )
                 where NetQty > 0
                 orderby g.Key.Store_Issue_Id descending
                 select new
                 {
                     S_No = g.Key.Store_Issue_No,
                     S_Id = g.Key.Store_Issue_Id,
                     Issue_Qty = NetQty
                 }).ToList();

            return new JavaScriptSerializer().Serialize(query);
        }


        [WebMethod]
        public static string LoadMaster(string SR_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from data in db.Goods_Return_Notes.Where(x => x.Store_Return_Id.Equals(SR_ID))
                         select new
                         {
                             data.Store_Return_Id,
                             data.WareHouse,
                             data.Department_Id,
                             data.Store_Return_NO,
                             data.Store_Issue_No,
                             data.Create_Date,
                             data.Status,

                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static string LoadSINMaster(string GIN_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from data in db.Store_Issues.Where(x => x.Store_Issue_Id.Equals(GIN_id))
                         select new
                         {
                             data.Store_Issue_Id,
                             data.Organization_Id,
                             data.Department_Id,
                             data.Store_Issue_No,
                             data.Created_Time,

                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static string LoadDetail(string SR_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from data in db.Goods_Return_Details.Where(x => x.SR_Id.Equals(SR_ID))
                         select new
                         {   
                             SIN_No = (from si in db.Store_Issues join gr in db.Goods_Return_Notes on si.Store_Issue_Id equals gr.Store_Issue_No
                                       where gr.Store_Return_Id == Convert.ToInt32(SR_ID) select si.Store_Issue_No).FirstOrDefault(),
                             Approvedate = DBClass.getField("select Replace(convert(varchar, SI.Approved_Time, 106), ' ','-') from Store_Issue Si join Goods_Return_Notes gr on Si.Store_Issue_Id = gr.Store_Issue_No where gr.Store_Return_Id=" + Convert.ToInt32(SR_ID)),
                             data.Department,
                             data.Store_Issue_Qty,
                             data.Item_Id,
                             data.SIN_Details,
                             data.Batch_Number,
                             Item_code = DBClass.getField("select Item_Code from inv_items where Item_Id=" + data.Item_Id),
                             Unit = (from st in db.Store_Issue_Details
                                     join item in db.INV_Items on st.Item_Id equals item.Item_ID
                                     select db.GetDataValueName("UOM", item.Unit)).FirstOrDefault(),
                             Description = DBClass.getField("select Description from inv_items where Item_Id=" + data.Item_Id),
                             IsBatch = DBClass.getField("select IsBatch from inv_items where Item_Id=" + data.Item_Id),
                             Store_Stock = DBClass.getField("Select dbo.GetItemBatchStock(" + data.Item_Id + ", '','')"),
                             data.Rate,
                             data.Stock_Return_Qty,
                             data.Remarks,
                             data.Amount,
                             data.BalanceStock
                             //SaveTimeStock = data.Store_Stock,
                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(query);
        }
        //[WebMethod]
        //public static string LoadSINDetail(string GIN_id)
        //{
        //    DataBaseDataContext db = new DataBaseDataContext();
        //    var query = (from data in db.Store_Issue_Details.Where(x => x.Store_Issue_Id.Equals(GIN_id))
        //                 select new
        //                 {   
        //                     SIN_No = (from si in db.Store_Issues where si.Store_Issue_Id == Convert.ToInt32(GIN_id) select si.Store_Issue_No).FirstOrDefault(),
        //                     Approvedate = DBClass.getField("select Replace(convert(varchar, Approved_Time, 106), ' ','-') from Store_Issue where Store_Issue_Id=" + Convert.ToInt32(GIN_id)),
        //                     //Approvedate = (from si in db.Store_Issues where si.Store_Issue_Id == Convert.ToInt32(GIN_id) select si.Approved_Time).FirstOrDefault(),
        //                     data.Department,
        //                     data.Issue_Qty,
        //                     data.Item_Id,
        //                     data.Store_Issue_Detail_Id,
        //                     data.BatchNum,
        //                     Item_code = DBClass.getField("select Item_Code from inv_items where Item_Id=" + data.Item_Id),
        //                     Unit = (from st in db.Store_Issue_Details
        //                             join item in db.INV_Items on st.Item_Id equals item.Item_ID
        //                             select db.GetDataValueName("UOM", item.Unit)).FirstOrDefault(),
        //                     Description = DBClass.getField("select Description from inv_items where Item_Id=" + data.Item_Id),
        //                     IsBatch = DBClass.getField("select IsBatch from inv_items where Item_Id=" + data.Item_Id),
        //                     Store_Stock = DBClass.getField("Select dbo.GetItemBatchStock(" + data.Item_Id + ", '','')"),
        //                     data.Rate,
        //                     data.Amount,
        //                     SaveTimeStock = data.Store_Stock,
        //                     Balance_Stock = db.Goods_Return_Details
        //                            .Where(gr => gr.SIN_Details == data.Store_Issue_Detail_Id)
        //                            .Sum(gr => (decimal?)gr.Stock_Return_Qty) ?? 0
        //                 }).ToList();
        //    return (new JavaScriptSerializer()).Serialize(query);
        //}
        [WebMethod]
        public static string LoadSINDetail(string GIN_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            int ginId = Convert.ToInt32(GIN_id);

            var query =
    (from data in db.Store_Issue_Details
     let ReturnedQty =
         db.Goods_Return_Details
           .Where(gr => gr.SIN_Details == data.Store_Issue_Detail_Id)
           .Sum(gr => (decimal?)gr.Stock_Return_Qty) ?? 0

     let BalanceStock = data.Issue_Qty - ReturnedQty

     where data.Store_Issue_Id == ginId
           && BalanceStock > 0
     select new
                 {
                     SIN_No = db.Store_Issues
                                .Where(si => si.Store_Issue_Id == ginId)
                                .Select(si => si.Store_Issue_No)
                                .FirstOrDefault(),

                     Approvedate = DBClass.getField(
                         "select Replace(convert(varchar, Approved_Time, 106), ' ','-') from Store_Issue where Store_Issue_Id=" + ginId
                     ),

                     data.Department,
                     data.Issue_Qty,
                     data.Item_Id,
                     data.Store_Issue_Detail_Id,
                     data.BatchNum,

                     Item_code = DBClass.getField("select Item_Code from inv_items where Item_Id=" + data.Item_Id),

                     Unit = (from st in db.Store_Issue_Details
                             join item in db.INV_Items on st.Item_Id equals item.Item_ID
                             select db.GetDataValueName("UOM", item.Unit)).FirstOrDefault(),

                     Description = DBClass.getField("select Description from inv_items where Item_Id=" + data.Item_Id),
                     IsBatch = DBClass.getField("select IsBatch from inv_items where Item_Id=" + data.Item_Id),
                     Store_Stock = DBClass.getField("Select dbo.GetItemBatchStock(" + data.Item_Id + ", '','')"),

                     data.Rate,
                     data.Amount,
                     SaveTimeStock = data.Store_Stock,
                     Balance_Stock = BalanceStock
                 }).ToList();

            return new JavaScriptSerializer().Serialize(query);
        }

        [WebMethod]
        public static int Save(string btnSave, string AllItemDetail)
        {
            string store_Return_id = "";
            Goods_Return_Note si = new Goods_Return_Note();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<StoreReturn>(AllItemDetail);
            var lstItem = (from t in db.Goods_Return_Notes
                           where t.Store_Return_Id == int.Parse(record.StoreReturn_id)
                           select t).FirstOrDefault();
            if (btnSave == "Update")
            {
                lstItem.WareHouse = record.inventory_id;
                lstItem.Department_Id = record.department_id;
                lstItem.Updated_Date = DateTime.Now;
                lstItem.Updated_By = AppConfig.UserID;
                lstItem.Store_Return_NO = Convert.ToInt32(record.Store_Return_No);
                db.SubmitChanges();
                store_Return_id = record.StoreReturn_id;
            }
            else
            {
                si.WareHouse = record.inventory_id;
                si.Department_Id = record.department_id;
                si.Create_Date = DateTime.Now;
                si.Created_BY = AppConfig.UserID;
                si.Store_Issue_No = Convert.ToInt32( record.GIN);
                si.Store_Return_NO = DBClass.GetNewNumber("Store_Return_NO", "Goods_Return_Notes", "");
                si.Status = "Created";
                si.isDeleted = false;
                db.Goods_Return_Notes.InsertOnSubmit(si);
                db.SubmitChanges();
                store_Return_id = si.Store_Return_Id.ToString();
            }
            if (btnSave == "Update")
            {
                List<Goods_Return_Detail> lstItemDetails = db.Goods_Return_Details.Where(t => t.SR_Id == int.Parse(store_Return_id)).ToList();
                db.Goods_Return_Details.DeleteAllOnSubmit(lstItemDetails);
                db.SubmitChanges();
            }
            foreach (var item in record.ItemList)
            {
                Goods_Return_Detail sid = new Goods_Return_Detail();
                sid.SIN_Details = Convert.ToInt32(item.Store_Issue_Detail_Id);
                sid.SR_Id = int.Parse(store_Return_id);
                sid.Item_Id = Convert.ToInt32(item.item_Id);
                sid.Store_Issue_Qty = item.IssueQty;
                sid.Stock_Return_Qty = item.Return_Qty;
                sid.Department = item.txtDepartment;
                sid.Amount = item.total_amount;
                sid.Rate = item.txtRate;
                sid.Remarks = item.Remarks;
                sid.Batch_Number = item.BatchNum;
                sid.BalanceStock = item.balance_Qty;
                db.Goods_Return_Details.InsertOnSubmit(sid);
                db.SubmitChanges();
            }
            return int.Parse(store_Return_id);
        }

        public class StoreReturn
        {
            public string StoreReturn_id { get; set; }
            public string Store_Return_No { get; set; }
            public string inventory_id { get; set; }
            public string department_id { get; set; }
            public string GIN { get; set; }
            public List<StoreReturnDetail> ItemList { get; set; }
        }
        public class StoreReturnDetail
        {
            public string Store_Issue_Detail_Id { get; set; }
            public string item_Id { get; set; }
            public decimal Return_Qty { get; set; }
            public decimal IssueQty { get; set; }
            public decimal balance_Qty { get; set; }
            public string Remarks { get; set; }
            public string txtDepartment { get; set; }
            public string BatchNum { get; set; }
            public decimal txtRate { get; set; }
            public decimal total_amount { get; set; }
        }
    }
}