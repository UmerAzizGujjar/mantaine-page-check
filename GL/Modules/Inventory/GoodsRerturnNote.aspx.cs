using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

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
        [WebMethod]
        public static string GetGIN()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from SIN_NO in db.Store_Issues
                         where SIN_NO.Status == "Approved"
                         select new
                         {
                             S_No = SIN_NO.Store_Issue_No,
                             S_Id = SIN_NO.Store_Issue_Id,
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
        public static string LoadSINDetail(string GIN_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from data in db.Store_Issue_Details.Where(x => x.Store_Issue_Id.Equals(GIN_id))
                         select new
                         {   
                             SIN_No = (from si in db.Store_Issues where si.Store_Issue_Id == Convert.ToInt32(GIN_id) select si.Store_Issue_No).FirstOrDefault(),
                             Approvedate = DBClass.getField("select Replace(convert(varchar, Approved_Time, 106), ' ','-') from Store_Issues where Store_Issue_Id=" + Convert.ToInt32(GIN_id)),
                             //Approvedate = (from si in db.Store_Issues where si.Store_Issue_Id == Convert.ToInt32(GIN_id) select si.Approved_Time).FirstOrDefault(),
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
                             SaveTimeStock = data.Store_Stock,
                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(query);
        }
    }
}