using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class StockLedgerReport : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                if (Request.QueryString["Type"] != null)
                {
                    if (Request.QueryString["Type"] == "ITL")
                    {
                        //rowDates.Visible = false;
                        //rowItem.Visible = false;
                        //rowWareHouse.Visible = false;

                        //rowItemGroup.Visible = true;
                        //rowInventory_Org.Visible = true;
                        //rowItemCategory.Visible = true;
                        //rowItemType.Visible = true;
                        //rowProcedureType.Visible = true;
                        ////Fill Inventory Org
                        //fillDropDownFromDatavalues(2126, ddlInventoryOrg);
                        ////Fill Item Group
                        //fillDropDownFromDatavalues(3139, ddlItemGroup);
                        ////Fill Item Type
                        //fillDropDownFromDatavalues(4, ddlItemType);
                        ////Fill Item Category
                        //fillDropDownFromDatavalues(5, ddlItemCategory);
                        ////Fill Procedure Type
                        //fillDropDownFromDatavalues(1117, ddlProcedureType);

                        rowDates.Visible = false;
                        rowItem.Visible = false;
                        rowWareHouse.Visible = false;

                        rowItemGroup.Visible = true;
                        rowInventory_Org.Visible = true;
                        rowItemCategory.Visible = true;
                        rowItemType.Visible = true;
                        rowProcedureType.Visible = true;
                        //Fill Inventory Org
                        fillDropDownFromDatavalues(3167, ddlInventoryOrg);
                        //Fill Item Group
                        fillDropDownFromDatavalues(3166, ddlItemGroup);
                        //Fill Item Type
                        fillDropDownFromDatavalues(4, ddlItemType);
                        //Fill Item Category
                        fillDropDownFromDatavalues(5, ddlItemCategory);
                        //Fill Procedure Type
                        fillDropDownFromDatavalues(1108, ddlProcedureType);
                    }
                }
                rowInventory_Org.Visible = true;
            }
        }

        private void fillDropDownFromDatavalues(int valuesetID, DropDownList ddlObject)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            //var d = (from p in db.DataValues where p.ValueSet_ID == valuesetID select new { p.DataValue_Name, p.DataValue_Description }).ToList();
            System.Data.DataTable d = DBClass.getDataTable("Select '0' as [DataValue_Name], 'Please Select' as [DataValue_Description] " +
                " union all" +
                " Select Datavalue_Name, DataValue_Description from Datavalues where Valueset_ID = " + valuesetID + "");
            ddlObject.DataSource = d;
            ddlObject.DataTextField = "DataValue_Description";
            ddlObject.DataValueField = "DataValue_Name";
            ddlObject.DataBind();
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
        private class ddlListItems
        {
            public string DataValueName;
            public string DataValueDescription;
            public string Type;
        }
        [WebMethod]

        public static string GetDepartments()
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
                             Type = v.ValueSet_Description == "Ware House" ? "InvOrg" : "Fed"
                         }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);
        }


        [WebMethod]

        public static string loadItemList()
        {
            string result = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            //var itemsList = (from i in db.INV_Items where i.Book_ID == 1 select new { i.Item_ID, name = i.Item_ID.ToString() + '-' + i.Description }).ToList();
            var itemsList = (from i in db.INV_Items
                             where i.Book_ID == 1
                             select new { i.Item_ID, name = i.Item_ID.ToString() + '-' + i.Description })
                 .ToList();
            if (itemsList != null)
            {
                result = (new JavaScriptSerializer()).Serialize(itemsList);
            }
            return result;
        }

    }
}