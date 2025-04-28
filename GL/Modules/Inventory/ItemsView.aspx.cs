using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class WebForm4 : System.Web.UI.Page
    {

        public static string ItemType = "";

   
         public class Result
        {
            public string Item_ID;
            public string Item_Code;
            public string Description;
            public string UOM;
            public string Sale_Rate;
            public string Category_Name;
            public string Item_Type;            
        }
          [WebMethod]
        public static List<Result> Search()
        {
            var SearchSql = "";
            //if (ItemType == "Pharmacy")
            //{

            SearchSql = "SELECT Item_ID,Item_Code,Description,dbo.GetDataValueName('UOM',Unit)as Unit,Sale_Rate,'' Category_Name,case when Services='False' then'Item'when Services='True' then 'Service' else '' end Service FROM INV_Items  inv  where ISNULL(IsPharmacyItem,0)=0 order by 1 desc";
            //}
            //else
            //{
            //    SearchSql = "SELECT Item_ID,Item_Code,Description,dbo.GetDataValueName('UOM',Unit)as Unit,Sale_Rate,'' Category_Name,case when Services='False' then'Item'when Services='True' then 'Service' else '' end Service FROM INV_Items  inv where Pharmacy_Item !=1 order by 1 desc";
            //}



            DataTable dt = DBClass.getDataTable(SearchSql);

            List<Result> list = new List<Result>();

            foreach (DataRow dr in dt.Rows)
            {
                var totalamount = "1";

                totalamount = totalamount + 1;

                Result rslt = new Result()
                {
                   
                    Item_ID = dr[0] == DBNull.Value ? "" : dr[0].ToString(),
                    Item_Code = dr[1] == DBNull.Value ? "" : (string)dr[1].ToString(),
                    Description = dr[2] == DBNull.Value ? "" : dr[2].ToString(),
                    UOM = dr[3] == DBNull.Value ? "" : dr[3].ToString(),
                    Sale_Rate = dr[4] == DBNull.Value ? "" : dr[4].ToString(),
                    Category_Name = dr[5] == DBNull.Value ? "" : (string)dr[5].ToString(),
                    Item_Type = ((string)dr[6])
                };
               
                list.Add(rslt);
            }
            return list;
        }        
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {

                //ItemType = (Request.QueryString["ID_Type"].ToString());
                //Test_id = Convert.ToInt32(Request.QueryString["ID"].ToString());
                
            } 
        }

        [WebMethod]
        public static void DeleteRecord(int ItemID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            INV_Item item =db.INV_Items.Where(i => i.Item_ID == ItemID).FirstOrDefault();
            db.INV_Items.DeleteOnSubmit(item);
            db.SubmitChanges();
        }
    }
}