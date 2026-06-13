using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Script.Serialization;
using System.Data;
using System.Diagnostics.Eventing.Reader;

namespace PMS
{
    public partial class Jason : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
           

            if (Session["Book_ID"] != null && Request.QueryString["Table"] == null && Request.QueryString["StartCode"] == null && Request.QueryString["EndCode"] == null && Request.QueryString["Bank"] == null && Request.QueryString["Levels"] == null)
            {
                string sqlQuery = "Select * from GL_Accounts Where Book_ID=" + AppConfig.Book_ID + " AND Levels=4 AND (Account_Name like '" + Request.QueryString["q"].Replace("'", "''") + "%' OR Account_Code like '" + Request.QueryString["q"].Replace("'", "''") + "%')";

                sqlQuery = "select distinct * from (Select * from GL_Accounts Where Book_ID=1 and Levels=4 AND (Account_Name like '" + Request.QueryString["q"].Replace("'", "''") + "%' OR Account_Code like '" + Request.QueryString["q"].Replace("'", "''") + "%') union all Select * from GL_Accounts Where Book_ID=1 and Levels=4 and Parent_Code in (Select Account_ID from GL_Accounts Where Book_ID=1 AND (Account_Name like '" + Request.QueryString["q"].Replace("'", "''") + "%' OR Account_Code like '" + Request.QueryString["q"].Replace("'", "''") + "%')))t";

                string result = "";
                DataTable dt = DBClass.getDataTable(sqlQuery);
                foreach (DataRow dr in dt.Rows)
                {
                    result += (result == "") ? "" : ",";
                    result += @"{""id"":""" + dr["Account_ID"].ToString() + @""",""name"": """ + dr["Account_Code"].ToString() + " - " + dr["Account_Name"].ToString() + @"""}";
                }
                Response.Write("[" + result + "]");
            }
            else if (Request.QueryString["Table"] == "BillingBarcode")
            {
                string sqlQuery;
                if (Request.QueryString["q"] != null)
                    sqlQuery = "Select top 1 Bill_No, * From Ar_Billings WHERE Bill_No= '" + Request.QueryString["q"].ToString() + "'";
                else
                    sqlQuery = "SELECT * FROM Ar_Billings";
                string result = "";
                DataTable dt = DBClass.getDataTable(sqlQuery);
                foreach (DataRow dr in dt.Rows)
                {
                    result += (result == "") ? "" : ",";
                    result += @"{""id"":""" + dr["Bill_Id"].ToString() + @""",""name"": """ + dr["Bill_No"].ToString() + @"""}";
                }
                Response.Write("[" + result + "]");
            }
            else if (Session["Book_ID"] != null && Request.QueryString["Bank"] != null && Request.QueryString["Cash"] != null && Request.QueryString["Table"] == null && Request.QueryString["StartCode"] == null && Request.QueryString["EndCode"] == null && Request.QueryString["Bank"] == null)
            {
                string sqlQuery = "Select * from GL_Accounts Where Book_ID=" + AppConfig.Book_ID + " AND Levels=4 AND Cash=1 OR Bank=1 AND (Account_Name like '" + Request.QueryString["q"].Replace("'", "''") + "%' OR Account_Code like '" + Request.QueryString["q"].Replace("'", "''") + "%')";
                string result = "";
                DataTable dt = DBClass.getDataTable(sqlQuery);
                foreach (DataRow dr in dt.Rows)
                {
                    result += (result == "") ? "" : ",";
                    result += @"{""id"":""" + dr["Account_ID"].ToString() + @""",""name"": """ + dr["Account_Code"].ToString() + " - " + dr["Account_Name"].ToString() + @"""}";
                }
                Response.Write("[" + result + "]");
            }
            else if (Session["Book_ID"] != null && Request.QueryString["Bank"] != null)
            {
                string sqlQuery = "Select * from GL_Accounts Where Book_ID=" + AppConfig.Book_ID + " AND Levels=4 AND Bank=1 AND (Account_Name like '" + Request.QueryString["q"].Replace("'", "''") + "%' OR Account_Code like '" + Request.QueryString["q"].Replace("'", "''") + "%')";
                string result = "";
                DataTable dt = DBClass.getDataTable(sqlQuery);
                foreach (DataRow dr in dt.Rows)
                {
                    result += (result == "") ? "" : ",";
                    result += @"{""id"":""" + dr["Account_ID"].ToString() + @""",""name"": """ + dr["Account_Code"].ToString() + " - " + dr["Account_Name"].ToString() + @"""}";
                }
                Response.Write("[" + result + "]");
            }
            else if (Session["Book_ID"] != null && Request.QueryString["StartCode"] != null)
            {
                string sqlQuery = "select top 1 account_Id,Account_Code,account_Name From GL_Accounts Where Book_ID=" + AppConfig.Book_ID + " AND Levels=4 AND (Account_Name like '" + Request.QueryString["q"].Replace("'", "''") + "%' OR Account_Code like '" + Request.QueryString["q"].Replace("'", "''") + "%') Order By Account_ID Asc";
                string result = "";
                DataTable dt = DBClass.getDataTable(sqlQuery);
                foreach (DataRow dr in dt.Rows)
                {
                    result += (result == "") ? "" : ",";
                    result += @"{""id"":""" + dr["Account_ID"].ToString() + @""",""name"": """ + dr["Account_Code"].ToString() + " - " + dr["Account_Name"].ToString() + @"""}";
                }
                Response.Write("[" + result + "]");
            }
            else if (Session["Book_ID"] != null && Request.QueryString["EndCode"] != null)
            {
                string sqlQuery = "select top 1 account_Id,Account_Code,account_Name From GL_Accounts Where Book_ID=" + AppConfig.Book_ID + " AND Levels=4 AND (Account_Name like '" + Request.QueryString["q"].Replace("'", "''") + "%' OR Account_Code like '" + Request.QueryString["q"].Replace("'", "''") + "%') Order By Account_ID desc";
                string result = "";
                DataTable dt = DBClass.getDataTable(sqlQuery);
                foreach (DataRow dr in dt.Rows)
                {
                    result += (result == "") ? "" : ",";
                    result += @"{""id"":""" + dr["Account_ID"].ToString() + @""",""name"": """ + dr["Account_Code"].ToString() + " - " + dr["Account_Name"].ToString() + @"""}";
                }
                Response.Write("[" + result + "]");
            }
            else if (Session["Book_ID"] != null && Request.QueryString["Table"] == "GL_Accounts" && Request.QueryString["Item_ID"] != null && Request.QueryString["AccountType"] != null)
            {
                string sqlQuery = "";
                int Category_ID = Convert.ToInt32(Request.QueryString["Item_ID"]);
                switch (Request.QueryString["AccountType"])
                {
                    case "Stock_Account":
                        sqlQuery = "Select * from GL_Accounts inner join INV_Item_Account_Category item on GL_Accounts.Account_ID=item.Stock_Account_ID Where GL_Accounts.Book_ID=" + AppConfig.Book_ID + " AND Levels=4 AND item.Category_ID=" + Category_ID;

                        break;

                    case "Sales_Account":
                        sqlQuery = "Select * from GL_Accounts inner join INV_Item_Account_Category item on GL_Accounts.Account_ID=item.Sales_Account_ID Where GL_Accounts.Book_ID=" + AppConfig.Book_ID + " AND Levels=4 AND item.Category_ID=" + Category_ID;
                        break;

                    case "Cost_Of_Sales_Account":
                        sqlQuery = "Select * from GL_Accounts inner join INV_Item_Account_Category item on GL_Accounts.Account_ID=item.Cost_Of_Sales_Account_ID Where GL_Accounts.Book_ID=" + AppConfig.Book_ID + " AND Levels=4 AND item.Category_ID=" + Category_ID;
                        break;

                    default:
                        break;
                }

                string result = "";
                DataTable dt = DBClass.getDataTable(sqlQuery);
                foreach (DataRow dr in dt.Rows)
                {
                    result += (result == "") ? "" : ",";
                    result += @"{""id"":""" + dr["Account_ID"].ToString() + @""",""name"": """ + dr["Account_Code"].ToString() + " - " + dr["Account_Name"].ToString() + @"""}";
                }
                Response.Write("[" + result + "]");
            }
            else if (Session["Book_ID"] != null && Request.QueryString["Table"] == "GL_Accounts")
            {
                string sqlQuery = "Select * from GL_Accounts Where Book_ID=" + AppConfig.Book_ID + " AND Levels=4 AND (Account_Name like '" + Request.QueryString["q"].Replace("'", "''") + "%' OR Account_Code like '" + Request.QueryString["q"].Replace("'", "''") + "%')";                
                string result = "";
                DataTable dt = DBClass.getDataTable(sqlQuery);
                foreach (DataRow dr in dt.Rows)
                {
                    result += (result == "") ? "" : ",";
                    result += @"{""id"":""" + dr["Account_ID"].ToString() + @""",""name"": """ + dr["Account_Code"].ToString() + " - " + dr["Account_Name"].ToString() + @"""}";
                }
                Response.Write("[" + result + "]");
            }

            else if (Request.QueryString["Table"] != null)
            {
                if (Request.QueryString["Customer_ID"] != null && Request.QueryString["Table"] == "Customer")
                {
                    string sqlQuery = "Select * from Ar_Customers Where Company_ID=" + AppConfig.Company_ID + " and Customer_ID=" + Request.QueryString["Customer_ID"] + "";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Customer_ID"].ToString() + @""",""name"": """ + dr["Customer_Name"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["Plot_ID"] != null && Request.QueryString["Table"] == "Plots")
                {
                    string sqlQuery = "Select Plot_ID,Plot_Number,dbo.GetDataValueName('Block',Block) as Block,dbo.GetDataValueName('Area',Area) as Area,dbo.GetDataValueName('Sector',Sector) as Sector,dbo.GetDataValueName('Plot Type',Plot_Type) as Plot_Type,dbo.GetDataValueName('Sector',Sector) as Sector,dbo.GetDataValueName('Category',Category) as Category from Plots Where Company_ID=" + AppConfig.Company_ID + " and  Plot_ID=" + Request.QueryString["Plot_ID"] + "";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Plot_ID"].ToString() + @""",""name"": """ + dr["Plot_Number"].ToString() + " - " + dr["Sector"].ToString() + " - " + dr["Block"].ToString() + " - " + dr["Area"].ToString() + " - " + dr["Plot_Type"].ToString() + " - " + dr["Category"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["Account_ID"] != null)
                {
                    string sqlQuery;
                    if (Request.QueryString["Account_ID"] != null && Request.QueryString["Table"] == "Account")
                        sqlQuery = "Select * from GL_Accounts Where Book_ID=" + AppConfig.Book_ID + " AND Account_ID=" + Request.QueryString["Account_ID"] + "";
                    else
                        sqlQuery = "Select * from GL_Accounts Where Book_ID=" + AppConfig.Book_ID + "";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Account_ID"].ToString() + @""",""name"": """ + dr["Account_Code"].ToString() + " - " + dr["Account_Name"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["SaleID"] == null && Request.QueryString["Table"] == "Customer")
                {
                    string sqlQuery = "Select * from Ar_Customers Where Company_ID=" + AppConfig.Company_ID + " and  Customer_Name like '" + Request.QueryString["q"].Replace("'", "''") + "%'";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Customer_ID"].ToString() + @""",""name"": """ + dr["Customer_Name"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["SaleID"] != null && Request.QueryString["Table"] == "Customer")
                {
                    int SaleID = Convert.ToInt32(Request.QueryString["SaleID"]);
                    string sqlQuery = "Select c.Customer_ID as Customer_ID,c.Customer_Name as Customer_Name from Ar_Customers c inner join Ar_Sales s on c.Customer_ID=s.Customer_ID Where c.Company_ID=" + AppConfig.Company_ID + " and s.Company_ID=" + AppConfig.Company_ID + " and  s.Sales_ID=" + SaleID;
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Customer_ID"].ToString() + @""",""name"": """ + dr["Customer_Name"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
               
                else if (Request.QueryString["Table"] == "INV_ItemsForMIRByWarehouse")
                {
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    string warehouseID = Request.QueryString["WarehouseID"];
                    var userPermissions = (from data in db.aspnet_Users
                                           where data.UserId == AppConfig.UserID
                                           select new
                                           {
                                               data.AllowPharmacy,
                                               data.AllowGeneralItems
                                           }).FirstOrDefault();

                    bool allowPharmacy = userPermissions != null && Convert.ToBoolean(userPermissions.AllowPharmacy);
                    bool allowGeneralItem = userPermissions != null && Convert.ToBoolean(userPermissions.AllowGeneralItems);
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                    {
                        if (allowPharmacy && allowGeneralItem)
                        {
                            sqlQuery = "Select * from INV_Items i Where Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID + " and InventoryOrg=" + warehouseID + "  AND (Description like '%" + Request.QueryString["q"] + "%' OR Item_Code like '%" + Request.QueryString["q"] + "%')";
                        }
                        else if (allowPharmacy)
                        {
                            sqlQuery = "Select * from INV_Items i Where Pharmacy_Item=1 and IsPharmacyItem=1 and Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID + " and InventoryOrg=" + warehouseID + " AND (Description like '%" + Request.QueryString["q"] + "%' OR Item_Code like '%" + Request.QueryString["q"] + "%')";
                        }                        
                        else
                        {
                            sqlQuery = "Select * from INV_Items i Where Pharmacy_Item<>1 and IsPharmacyItem<>1 and Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID + " and InventoryOrg=" + warehouseID + " AND (Description like '%" + Request.QueryString["q"] + "%' OR Item_Code like '%" + Request.QueryString["q"] + "%')";
                        }
                    }
                    else
                    {
                        if (allowPharmacy && allowGeneralItem)
                        {
                            sqlQuery = "Select * from INV_Items Where Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID;
                        }
                        else if (allowPharmacy)
                        {
                            sqlQuery = "Select * from INV_Items Where Pharmacy_Item=1 and IsPharmacyItem=1 and Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID;
                        }                        
                        else
                        {
                            sqlQuery = "Select * from INV_Items Where Pharmacy_Item<>1 and IsPharmacyItem<>1 and Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID;
                        }
                    }
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);

                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";                       
                        result += @"{""id"":""   " + dr["Item_ID"].ToString() + @""",""name"": ""    " + dr["Item_Code"].ToString() + " -- " + dr["Description"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
               
                else if (Request.QueryString["Table"] == "INV_ItemsForMIR")
                {
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                   // string warehouseID = Request.QueryString["WarehouseID"];
                    var userPermissions = (from data in db.aspnet_Users
                                           where data.UserId == AppConfig.UserID
                                           select new
                                           {
                                               data.AllowPharmacy,
                                               data.AllowGeneralItems
                                           }).FirstOrDefault();

                    bool allowPharmacy = userPermissions != null && Convert.ToBoolean(userPermissions.AllowPharmacy);
                    bool allowGeneralItem = userPermissions != null && Convert.ToBoolean(userPermissions.AllowGeneralItems);
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                    {
                        if (allowPharmacy && allowGeneralItem)
                        {
                            sqlQuery = "Select * from INV_Items i Where Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID + "   AND (Description like '%" + Request.QueryString["q"] + "%' OR Item_Code like '%" + Request.QueryString["q"] + "%')";
                        }
                        else if (allowPharmacy)
                        {
                            sqlQuery = "Select * from INV_Items i Where Pharmacy_Item=1 and IsPharmacyItem=1 and Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID + "  AND (Description like '%" + Request.QueryString["q"] + "%' OR Item_Code like '%" + Request.QueryString["q"] + "%')";
                        }                        
                        else
                        {
                            sqlQuery = "Select * from INV_Items i Where Pharmacy_Item<>1 and IsPharmacyItem<>1 and Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID + " AND (Description like '%" + Request.QueryString["q"] + "%' OR Item_Code like '%" + Request.QueryString["q"] + "%')";
                        }
                    }
                    else
                    {
                        if (allowPharmacy && allowGeneralItem)
                        {
                            sqlQuery = "Select * from INV_Items Where Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID;
                        }
                        else if (allowPharmacy)
                        {
                            sqlQuery = "Select * from INV_Items Where Pharmacy_Item=1 and IsPharmacyItem=1 and Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID;
                        }                        
                        else
                        {
                            sqlQuery = "Select * from INV_Items Where Pharmacy_Item<>1 and IsPharmacyItem<>1 and Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID;
                        }
                    }
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);

                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";                       
                        result += @"{""id"":""   " + dr["Item_ID"].ToString() + @""",""name"": ""    " + dr["Item_Code"].ToString() + " -- " + dr["Description"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["Table"] == "INV_Items")
                {
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    var userPermissions = (from data in db.aspnet_Users
                                           where data.UserId == AppConfig.UserID
                                           select new
                                           {
                                               data.AllowPharmacy,
                                               data.AllowGeneralItems
                                           }).FirstOrDefault();

                    bool allowPharmacy = userPermissions != null && Convert.ToBoolean(userPermissions.AllowPharmacy);
                    bool allowGeneralItem = userPermissions != null && Convert.ToBoolean(userPermissions.AllowGeneralItems);
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                    {
                        if (allowPharmacy && allowGeneralItem)
                        {
                            sqlQuery = "Select * from INV_Items i Where Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID + " AND Description like '%" + Request.QueryString["q"] + "%'";
                        }
                        else if (allowPharmacy)
                        {
                            sqlQuery = "Select * from INV_Items i Where Pharmacy_Item=1 and IsPharmacyItem=1 and Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID + " AND Description like '%" + Request.QueryString["q"] + "%'";
                        }
                        else
                        {
                            sqlQuery = "Select * from INV_Items i Where Pharmacy_Item<>1 and IsPharmacyItem<>1 and Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID + " AND Description like '%" + Request.QueryString["q"] + "%'";
                        }
                    }
                    else
                    {
                        if (allowPharmacy && allowGeneralItem)
                        {
                            sqlQuery = "Select * from INV_Items Where Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID;
                        }
                        else if (allowPharmacy)
                        {
                            sqlQuery = "Select * from INV_Items Where Pharmacy_Item=1 and IsPharmacyItem=1 and Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID;
                        }
                        else
                        {
                            sqlQuery = "Select * from INV_Items Where Pharmacy_Item<>1 and IsPharmacyItem<>1 and Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID;
                        }
                    }

                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Item_ID"].ToString() + @""",""name"": """ + dr["Item_Code"].ToString() + " - " + dr["Description"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["Table"] == "INV_Items_STN")
                {
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                        sqlQuery = "Select * from INV_Items Where Book_ID=" + AppConfig.Book_ID + " and Hospital_Services= 0 and Services<>1 and Active=1 AND Item_Code like'%" + Request.QueryString["q"] + "%'";
                    else
                        sqlQuery = "Select * from INV_Items Where Book_ID=" + AppConfig.Book_ID + "";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Item_ID"].ToString() + @""",""name"": """ + dr["Item_Code"].ToString() + " - " + dr["Description"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["Table"] == "INV_ItemsforStockAdj")
                {
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    var userPermissions = (from data in db.aspnet_Users
                                           where data.UserId == AppConfig.UserID
                                           select new
                                           {
                                               data.AllowPharmacy,
                                               data.AllowGeneralItems
                                           }).FirstOrDefault();

                    bool allowPharmacy = userPermissions != null && Convert.ToBoolean(userPermissions.AllowPharmacy);
                    bool allowGeneralItem = userPermissions != null && Convert.ToBoolean(userPermissions.AllowGeneralItems);
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                    {
                        if (allowPharmacy && allowGeneralItem)
                        {                           
                            sqlQuery = "Select *, isnull(dbo.GetDataValueName('UOM', i.Unit),'NIL') as UOM, (select top 1 CAST(ISNULL(Rate,0) as DECIMAL(18,2)) from AP_Purchase_Order_Items where Item_Id = i.Item_ID order by PO_Item_ID desc) as LastRate, (select ISNULL(sum(Qty),0) from vwBatch_Ledger where Item_ID = i.Item_ID) as Stock from INV_Items i Where Hospital_Services= 0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID + " AND Description like'%" + Request.QueryString["q"] + "%'";
                        }
                        else if (allowPharmacy)
                        {
                            sqlQuery = "Select *, isnull(dbo.GetDataValueName('UOM', i.Unit),'NIL') as UOM, (select top 1 CAST(ISNULL(Rate,0) as DECIMAL(18,2)) from AP_Purchase_Order_Items where Item_Id = i.Item_ID order by PO_Item_ID desc) as LastRate, (select ISNULL(sum(Qty),0) from vwBatch_Ledger where Item_ID = i.Item_ID) as Stock from INV_Items i Where Pharmacy_Item=1 and IsPharmacyItem=1 and Hospital_Services= 0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID + " AND Description like'%" + Request.QueryString["q"] + "%'";
                        }
                        else
                        {
                            sqlQuery = "Select *, isnull(dbo.GetDataValueName('UOM', i.Unit),'NIL') as UOM, (select top 1 CAST(ISNULL(Rate,0) as DECIMAL(18,2)) from AP_Purchase_Order_Items where Item_Id = i.Item_ID order by PO_Item_ID desc) as LastRate, (select ISNULL(sum(Qty),0) from vwBatch_Ledger where Item_ID = i.Item_ID) as Stock from INV_Items i Where Pharmacy_Item<>1 and IsPharmacyItem<>1 and Hospital_Services= 0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID + " AND Description like'%" + Request.QueryString["q"] + "%'";                            
                        }
                    }
                    else
                    {
                        if (allowPharmacy && allowGeneralItem)
                        {
                            sqlQuery = "Select * from INV_Items Where Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID;
                        }
                        else if (allowPharmacy)
                        {
                            sqlQuery = "Select * from INV_Items Where Pharmacy_Item=1 and IsPharmacyItem=1 and Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID;
                        }
                        else
                        {
                            sqlQuery = "Select * from INV_Items Where Pharmacy_Item<>1 and IsPharmacyItem<>1 and Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID;
                        }
                    }
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);

                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Item_ID"].ToString() + @""",""name"": """ + dr["Item_Code"].ToString() + " - " + dr["Description"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["Table"] == "INV_ItemsforStockAdjWareHouse")
                {
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    string warehouseID = Request.QueryString["WarehouseID"];
                    var userPermissions = (from data in db.aspnet_Users
                                           where data.UserId == AppConfig.UserID
                                           select new
                                           {
                                               data.AllowPharmacy,
                                               data.AllowGeneralItems
                                           }).FirstOrDefault();

                    bool allowPharmacy = userPermissions != null && Convert.ToBoolean(userPermissions.AllowPharmacy);
                    bool allowGeneralItem = userPermissions != null && Convert.ToBoolean(userPermissions.AllowGeneralItems);
                    string sqlQuery;

                    if (Request.QueryString["q"] != null)
                    {
                        string searchTerm = Request.QueryString["q"].Replace("'", "''"); // Basic SQL injection mitigation

                        if (allowPharmacy && allowGeneralItem)
                        {
                            sqlQuery = "Select *, isnull(dbo.GetDataValueName('UOM', i.Unit),'NIL') as UOM, (select top 1 CAST(ISNULL(Rate,0) as DECIMAL(18,2)) from AP_Purchase_Order_Items where Item_Id = i.Item_ID order by PO_Item_ID desc) as LastRate, (select ISNULL(sum(Qty),0) from vwBatch_Ledger where Item_ID = i.Item_ID) as Stock from INV_Items i Where Hospital_Services= 0 and Services<>1 and Active=1 and InventoryOrg=" + warehouseID + " and Book_ID=" + AppConfig.Book_ID + " AND (Description like '%" + searchTerm + "%' OR Generic_Name like '%" + searchTerm + "%')";
                        }
                        else if (allowPharmacy)
                        {
                            sqlQuery = "Select *, isnull(dbo.GetDataValueName('UOM', i.Unit),'NIL') as UOM, (select top 1 CAST(ISNULL(Rate,0) as DECIMAL(18,2)) from AP_Purchase_Order_Items where Item_Id = i.Item_ID order by PO_Item_ID desc) as LastRate, (select ISNULL(sum(Qty),0) from vwBatch_Ledger where Item_ID = i.Item_ID) as Stock from INV_Items i Where Pharmacy_Item=1 and IsPharmacyItem=1 and Hospital_Services= 0 and Services<>1 and Active=1 and InventoryOrg=" + warehouseID + " and Book_ID=" + AppConfig.Book_ID + " AND (Description like '%" + searchTerm + "%' OR Generic_Name like '%" + searchTerm + "%')";
                        }
                        else
                        {
                            sqlQuery = "Select *, isnull(dbo.GetDataValueName('UOM', i.Unit),'NIL') as UOM, (select top 1 CAST(ISNULL(Rate,0) as DECIMAL(18,2)) from AP_Purchase_Order_Items where Item_Id = i.Item_ID order by PO_Item_ID desc) as LastRate, (select ISNULL(sum(Qty),0) from vwBatch_Ledger where Item_ID = i.Item_ID) as Stock from INV_Items i Where Pharmacy_Item<>1 and IsPharmacyItem<>1 and Hospital_Services= 0 and Services<>1 and Active=1 and InventoryOrg=" + warehouseID + " and Book_ID=" + AppConfig.Book_ID + " AND (Description like '%" + searchTerm + "%' OR Generic_Name like '%" + searchTerm + "%')";
                        }
                    }
                    else
                    {
                        if (allowPharmacy && allowGeneralItem)
                        {
                            sqlQuery = "Select * from INV_Items Where Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID;
                        }
                        else if (allowPharmacy)
                        {
                            sqlQuery = "Select * from INV_Items Where Pharmacy_Item=1 and IsPharmacyItem=1 and Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID;
                        }
                        else
                        {
                            sqlQuery = "Select * from INV_Items Where Pharmacy_Item<>1 and IsPharmacyItem<>1 and Hospital_Services=0 and Services<>1 and Active=1  and Book_ID=" + AppConfig.Book_ID;
                        }
                    }

                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);

                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Item_ID"].ToString() + @""",""name"": """ + dr["Item_Code"].ToString() + " - " + dr["Description"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }

                else if (Request.QueryString["Table"] == "INV_ItemsForPO")
                {
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                        sqlQuery = "Select *, isnull(dbo.GetDataValueName('UOM', i.Unit),'NIL') as UOM, (select top 1 CAST(ISNULL(Rate,0) as DECIMAL(18,2)) from AP_Purchase_Order_Items where Item_Id = i.Item_ID order by PO_Item_ID desc) as LastRate, (select ISNULL(sum(Qty),0) from vwBatch_Ledger where Item_ID = i.Item_ID) as Stock from INV_Items i Where Hospital_Services= 0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID + " AND Description like'%" + Request.QueryString["q"] + "%'";

                    else
                        sqlQuery = "Select * from INV_Items Where Book_ID=" + AppConfig.Book_ID + "";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);

                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Item_ID"].ToString() + @""",""name"": """ + dr["Item_Code"].ToString() + " - " + dr["Description"].ToString()+@"""}";
                    }
                    Response.Write("[" + result + "]");
                }



                else if (Request.QueryString["Table"] == "INV_ItemsForPR")
                {
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    string warehouseID = Request.QueryString["WarehouseID"];
                    var userPermissions = (from data in db.aspnet_Users
                                           where data.UserId == AppConfig.UserID
                                           select new
                                           {
                                               data.AllowPharmacy,
                                               data.AllowGeneralItems
                                           }).FirstOrDefault();

                    bool allowPharmacy = userPermissions != null && Convert.ToBoolean(userPermissions.AllowPharmacy);
                    bool allowGeneralItem = userPermissions != null && Convert.ToBoolean(userPermissions.AllowGeneralItems);
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                    {
                        if (allowPharmacy && allowGeneralItem)
                        {
                            sqlQuery = "Select *, isnull(dbo.GetDataValueName('UOM', i.Unit),'NIL') as UOM, (select top 1 CAST(ISNULL(Rate,0) as DECIMAL(18,2)) from AP_Purchase_Order_Items where Item_Id = i.Item_ID order by PO_Item_ID desc) as LastRate, (select ISNULL(sum(Qty),0) from vwBatch_Ledger where Item_ID = i.Item_ID) as Stock from INV_Items i Where Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID + " AND Description like'%" + Request.QueryString["q"] + "%'";                           
                        }
                        else if (allowPharmacy)
                        {
                            sqlQuery = "Select *, isnull(dbo.GetDataValueName('UOM', i.Unit),'NIL') as UOM, (select top 1 CAST(ISNULL(Rate,0) as DECIMAL(18,2)) from AP_Purchase_Order_Items where Item_Id = i.Item_ID order by PO_Item_ID desc) as LastRate, (select ISNULL(sum(Qty),0) from vwBatch_Ledger where Item_ID = i.Item_ID) as Stock from INV_Items i Where Pharmacy_Item=1 and IsPharmacyItem=1 and Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID +  " AND Description like'%" + Request.QueryString["q"] + "%'";                          
                        }
                        else
                        {
                            sqlQuery = "Select *, isnull(dbo.GetDataValueName('UOM', i.Unit),'NIL') as UOM, (select top 1 CAST(ISNULL(Rate,0) as DECIMAL(18,2)) from AP_Purchase_Order_Items where Item_Id = i.Item_ID order by PO_Item_ID desc) as LastRate, (select ISNULL(sum(Qty),0) from vwBatch_Ledger where Item_ID = i.Item_ID) as Stock from INV_Items i Where Pharmacy_Item<>1 and IsPharmacyItem<>1  and Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID + "  AND Description like'%" + Request.QueryString["q"] + "%'";                           
                        }
                    }
                    else
                    {
                        if (allowPharmacy && allowGeneralItem)
                        {
                            sqlQuery = "Select * from INV_Items Where Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID;
                        }
                        else if (allowPharmacy)
                        {
                            sqlQuery = "Select * from INV_Items Where Pharmacy_Item=1 and IsPharmacyItem=1 and Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID;
                        }
                        else
                        {
                            sqlQuery = "Select * from INV_Items Where Pharmacy_Item<>1 and IsPharmacyItem<>1 and Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID;
                        }
                    }                   
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);

                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Item_ID"].ToString() + @""",""name"": """ + dr["Item_Code"].ToString() + " - " + dr["Description"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }

                //else if (Request.QueryString["Table"] == "INV_ItemsForPRwithWarehouse")
                //{
                //    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                //    string warehouseID = Request.QueryString["WarehouseID"];
                //    var userPermissions = (from data in db.aspnet_Users
                //                           where data.UserId == AppConfig.UserID
                //                           select new
                //                           {
                //                               data.AllowPharmacy,
                //                               data.AllowGeneralItems
                //                           }).FirstOrDefault();

                //    bool allowPharmacy = userPermissions != null && Convert.ToBoolean(userPermissions.AllowPharmacy);
                //    bool allowGeneralItem = userPermissions != null && Convert.ToBoolean(userPermissions.AllowGeneralItems);
                //    string sqlQuery;
                //    if (Request.QueryString["q"] != null)
                //    {
                //        if (allowPharmacy && allowGeneralItem)
                //        {
                //            sqlQuery = "Select *, isnull(dbo.GetDataValueName('UOM', i.Unit),'NIL') as UOM, (select top 1 CAST(ISNULL(Rate,0) as DECIMAL(18,2)) from AP_Purchase_Order_Items where Item_Id = i.Item_ID order by PO_Item_ID desc) as LastRate, (select ISNULL(sum(Qty),0) from vwBatch_Ledger where Item_ID = i.Item_ID) as Stock from INV_Items i Where Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID + " and InventoryOrg = " + warehouseID + " AND Description like'%" + Request.QueryString["q"] + "%'";
                //        }
                //        else if (allowPharmacy)
                //        {
                //            sqlQuery = "Select *, isnull(dbo.GetDataValueName('UOM', i.Unit),'NIL') as UOM, (select top 1 CAST(ISNULL(Rate,0) as DECIMAL(18,2)) from AP_Purchase_Order_Items where Item_Id = i.Item_ID order by PO_Item_ID desc) as LastRate, (select ISNULL(sum(Qty),0) from vwBatch_Ledger where Item_ID = i.Item_ID) as Stock from INV_Items i Where Pharmacy_Item=1 and IsPharmacyItem=1 and Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID + " and InventoryOrg = " + warehouseID + " AND Description like'%" + Request.QueryString["q"] + "%'";
                //        }
                //        else
                //        {
                //            sqlQuery = "Select *, isnull(dbo.GetDataValueName('UOM', i.Unit),'NIL') as UOM, (select top 1 CAST(ISNULL(Rate,0) as DECIMAL(18,2)) from AP_Purchase_Order_Items where Item_Id = i.Item_ID order by PO_Item_ID desc) as LastRate, (select ISNULL(sum(Qty),0) from vwBatch_Ledger where Item_ID = i.Item_ID) as Stock from INV_Items i Where Pharmacy_Item<>1 and IsPharmacyItem<>1  and Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID + " and InventoryOrg = " + warehouseID + " AND Description like'%" + Request.QueryString["q"] + "%'";
                //        }
                //    }
                //    else
                //    {
                //        if (allowPharmacy && allowGeneralItem)
                //        {
                //            sqlQuery = "Select * from INV_Items Where Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID;
                //        }
                //        else if (allowPharmacy)
                //        {
                //            sqlQuery = "Select * from INV_Items Where Pharmacy_Item=1 and IsPharmacyItem=1 and Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID;
                //        }
                //        else
                //        {
                //            sqlQuery = "Select * from INV_Items Where Pharmacy_Item<>1 and IsPharmacyItem<>1 and Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID;
                //        }
                //    }
                //    string result = "";
                //    DataTable dt = DBClass.getDataTable(sqlQuery);

                //    foreach (DataRow dr in dt.Rows)
                //    {
                //        result += (result == "") ? "" : ",";
                //        result += @"{""id"":""" + dr["Item_ID"].ToString() + @""",""name"": """ + dr["Item_Code"].ToString() + " - " + dr["Description"].ToString() + @"""}";
                //    }
                //    Response.Write("[" + result + "]");
                //}
                else if (Request.QueryString["Table"] == "INV_ItemsForPRwithWarehouse")
                {
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    string warehouseID = Request.QueryString["WarehouseID"];
                    var userPermissions = (from data in db.aspnet_Users
                                           where data.UserId == AppConfig.UserID
                                           select new
                                           {
                                               data.AllowPharmacy,
                                               data.AllowGeneralItems
                                           }).FirstOrDefault();

                    bool allowPharmacy = userPermissions != null && Convert.ToBoolean(userPermissions.AllowPharmacy);
                    bool allowGeneralItem = userPermissions != null && Convert.ToBoolean(userPermissions.AllowGeneralItems);
                    string sqlQuery;

                    if (Request.QueryString["q"] != null)
                    {
                        string searchTerm = Request.QueryString["q"].Replace("'", "''"); // Basic SQL injection mitigation

                        if (allowPharmacy && allowGeneralItem)
                        {
                            sqlQuery = @"Select *, isnull(dbo.GetDataValueName('UOM', i.Unit),'NIL') as UOM, 
                        (select top 1 CAST(ISNULL(Rate,0) as DECIMAL(18,2)) from AP_Purchase_Order_Items where Item_Id = i.Item_ID order by PO_Item_ID desc) as LastRate, 
                        (select ISNULL(sum(Qty),0) from vwBatch_Ledger where Item_ID = i.Item_ID) as Stock 
                        from INV_Items i 
                        Where Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID + @" 
                        and InventoryOrg = " + warehouseID + @" 
                        AND (Description like '%" + searchTerm + @"%' OR Generic_Name like '%" + searchTerm + @"%')";
                        }
                        else if (allowPharmacy)
                        {
                            sqlQuery = @"Select *, isnull(dbo.GetDataValueName('UOM', i.Unit),'NIL') as UOM, 
                        (select top 1 CAST(ISNULL(Rate,0) as DECIMAL(18,2)) from AP_Purchase_Order_Items where Item_Id = i.Item_ID order by PO_Item_ID desc) as LastRate, 
                        (select ISNULL(sum(Qty),0) from vwBatch_Ledger where Item_ID = i.Item_ID) as Stock 
                        from INV_Items i 
                        Where Pharmacy_Item=1 and IsPharmacyItem=1 and Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID + @" 
                        and InventoryOrg = " + warehouseID + @" 
                        AND (Description like '%" + searchTerm + @"%' OR Generic_Name like '%" + searchTerm + @"%')";
                        }
                        else
                        {
                            sqlQuery = @"Select *, isnull(dbo.GetDataValueName('UOM', i.Unit),'NIL') as UOM, 
                        (select top 1 CAST(ISNULL(Rate,0) as DECIMAL(18,2)) from AP_Purchase_Order_Items where Item_Id = i.Item_ID order by PO_Item_ID desc) as LastRate, 
                        (select ISNULL(sum(Qty),0) from vwBatch_Ledger where Item_ID = i.Item_ID) as Stock 
                        from INV_Items i 
                        Where Pharmacy_Item<>1 and IsPharmacyItem<>1 and Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID + @" 
                        and InventoryOrg = " + warehouseID + @" 
                        AND (Description like '%" + searchTerm + @"%' OR Generic_Name like '%" + searchTerm + @"%')";
                        }
                    }
                    else
                    {
                        // No search term — return all matching items (no Generic_Name filter needed here)
                        if (allowPharmacy && allowGeneralItem)
                        {
                            sqlQuery = "Select * from INV_Items Where Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID;
                        }
                        else if (allowPharmacy)
                        {
                            sqlQuery = "Select * from INV_Items Where Pharmacy_Item=1 and IsPharmacyItem=1 and Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID;
                        }
                        else
                        {
                            sqlQuery = "Select * from INV_Items Where Pharmacy_Item<>1 and IsPharmacyItem<>1 and Hospital_Services=0 and Services<>1 and Active=1 and Book_ID=" + AppConfig.Book_ID;
                        }
                    }

                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);

                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Item_ID"].ToString() + @""",""name"": """ + dr["Item_Code"].ToString() + " - " + dr["Description"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }

                else if (Request.QueryString["Table"] == "Patients" && Request.QueryString["Record"] == "Edit")
                {
                    string sqlQuery;
                    string result = "";
                    if (Request.QueryString["q"].ToString() != "End of expression expected" && Request.QueryString["q"] != null)
                    {
                        if (Request.QueryString["q"] != "undefined" || Request.QueryString["q"] != null)
                        {
                            int id = 0;
                            string d = Request.QueryString["q"];
                            if (d != "undefined")

                                id = Convert.ToInt32(Request.QueryString["q"]);

                            sqlQuery = "Select * from reg_patient where pat_id = " + id + ""; 
                            DataTable dt = DBClass.getDataTable(sqlQuery);
                            foreach (DataRow dr in dt.Rows)
                            {
                                result += (result == "") ? "" : ",";
                                result += @"{""id"":""" + dr["pat_id"].ToString() + @""",""name"": """ + dr["Patient_No"].ToString() + ""  + @"""}";
                            }
                        }

                    }
                    Response.Write("[" + result + "]");
                }


                else if (Request.QueryString["Table"] == "Out_Patients" && Request.QueryString["Record"] == "Edit")
                {
                    string sqlQuery;
                    string result = "";
                    if (Request.QueryString["q"].ToString() != "End of expression expected" && Request.QueryString["q"] != null)
                    {
                        if (Request.QueryString["q"] != "undefined" || Request.QueryString["q"] != null)
                        {
                            int id = 0;
                            string d = Request.QueryString["q"];
                            if (d != "undefined")

                                id = Convert.ToInt32(Request.QueryString["q"]);

                            sqlQuery = "Select * from Patients where Patient_ID = " + Request.QueryString["q"].ToString() + ""; 
                            DataTable dt = DBClass.getDataTable(sqlQuery);
                            foreach (DataRow dr in dt.Rows)
                            {
                                result += @"{""id"":""" + dr["Patient_ID"].ToString() + @""",
                                ""name"":""" + dr["Opd_No"].ToString() + " - " + dr["Full_Name"].ToString() + @""",
                                ""regPatId"":""" + dr["Reg_PatId"].ToString() + @"""}";
                            }

                        }

                    }
                    Response.Write("[" + result + "]");
                }
             
                else if (Request.QueryString["Table"] == "PatientsForDonor")
                {
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                        sqlQuery = "Select  top 1 pat_id,Patient_No,Full_Name from Reg_patient Where  Patient_No = '" + Request.QueryString["q"].ToString() + "' order by Created_Time desc";
                    else
                        sqlQuery = "Select distinct (select top 1 pat_id from Reg_patient where Patient_No=p.Patient_No)Patient_ID,Patient_No,Full_Name from Reg_patient p  order by Created_Time desc";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["pat_id"].ToString() + @""",""name"": """ + dr["Patient_No"].ToString() + " - " + dr["Full_Name"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["Table"] == "Patients")
                {
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                        sqlQuery = "Select top 1 pat_id as Patient_ID, mr_no_sequence as  Patient_No from Reg_patient Where mr_no_sequence = '" + Request.QueryString["q"].ToString() + "' order by Created_time desc";
                    else
                        sqlQuery = "Select distinct (select top 1 Patient_ID from Patients where Patient_No=p.Patient_No) Patient_ID, Patient_No from Patients p where isnull(IsRevisit,'0')=0 order by Created_Time desc";

                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Patient_ID"].ToString() + @""",""name"": """ + dr["Patient_No"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["Table"] == "In_Patients")
                {
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                        sqlQuery = "Select top 1 pat_id as Patient_ID, mr_no_sequence as  Patient_No from Reg_patient rg inner join In_Patient ipd  on rg.pat_id=ipd.Patient_ID Where mr_no_sequence = '" + Request.QueryString["q"].ToString() + "' order by rg.Created_time desc";
                    else
                        sqlQuery = "Select distinct pat_id as Patient_ID, mr_no_sequence as Patient_No from Reg_patient rg inner join In_Patient ipd on rg.pat_id = ipd.Patient_ID where ISNULL(ipd.Discharge,0)=0 order by rg.Created_time desc";

                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Patient_ID"].ToString() + @""",""name"": """ + dr["Patient_No"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["Table"] == "In_Patients_discharge")
                {
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                        sqlQuery = "Select top 1 pat_id as Patient_ID, mr_no_sequence as  Patient_No from Reg_patient rg inner join In_Patient ipd  on rg.pat_id=ipd.Patient_ID Where mr_no_sequence = '" + Request.QueryString["q"].ToString() + "' and isnull(ipd.Discharge,0)=0 order by rg.Created_time desc";
                    else
                        sqlQuery = "Select distinct pat_id as Patient_ID, mr_no_sequence as Patient_No from Reg_patient rg inner join In_Patient ipd on rg.pat_id = ipd.Patient_ID where ISNULL(ipd.Discharge,0)=0 order by rg.Created_time desc";

                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Patient_ID"].ToString() + @""",""name"": """ + dr["Patient_No"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["Table"] == "PatientsForPharmacy")
                {
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                        sqlQuery = "Select top 1 pat_id as Pat_id, Patient_No,mr_no_sequence from Reg_patient  Where mr_no_sequence = '" + Request.QueryString["q"].ToString() + "' order by Created_time desc";
                    else
                        sqlQuery = "Select distinct (select top 1 Patient_ID from Patients where Patient_No=p.Patient_No) Patient_ID, Patient_No from Patients p where isnull(IsRevisit,'0')=0 order by Created_Time desc";

                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Pat_id"].ToString() + @""",""name"": """ + dr["mr_no_sequence"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["Table"] == "PatientsPharmacy")
                {
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                        sqlQuery = "Select top 1 p.Patient_ID as Out_Patient_ID,ipm.Item_Code,rg.mr_no_sequence,rg.Full_Name,rg.Patient_No,op.Out_Patient_ID as opdid,rg.pat_id as Pat_id from Reg_patient rg inner join  Patients p on rg.pat_id = p.Reg_PatId inner join Out_Patient op on p.Patient_ID = op.Patient_ID inner join In_Patient_Medicines ipm on op.Out_Patient_ID = ipm.Patient_ID Where rg.Patient_No = '" + Request.QueryString["q"].ToString() + "' order by op.Created_Time desc ";
                    else
                        sqlQuery = "Select  top 1 op.Out_Patient_ID,ipm.Item_Code,rg.mr_no_sequence from Reg_patient rg inner join  Patients p on rg.pat_id = p.Reg_PatId inner join Out_Patient op on p.Patient_ID = op.Patient_ID inner join In_Patient_Medicines ipm on op.Out_Patient_ID = ipm.Patient_ID Where  isnull(IsRevisit,'0')=0  order by op.Created_Time desc ";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Out_Patient_ID"].ToString() + @""",""name"": """ + dr["mr_no_sequence"].ToString() + " - " + dr["Full_Name"].ToString() + @""",""patno"": """ + dr["Patient_No"].ToString()+ @""",""Pat_id"": """ + dr["Pat_id"].ToString() + @""",""Opd_id"": """ + dr["opdid"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
              
                else if (Request.QueryString["Table"] == "LabResultPatient")
                {
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                        sqlQuery = "Select  top 1 pat_id as Patient_ID,mr_no_sequence as Patient_No,Full_Name from Reg_patient Where mr_no_sequence = '" + Request.QueryString["q"].ToString() + "' order by Created_time desc";
                    else
                        sqlQuery = "Select distinct (select top 1 Patient_ID from Patients where Patient_No=p.Patient_No)Patient_ID,Patient_No,Full_Name from Patients p where isnull(IsRevisit,'0')=0  order by Created_Time desc";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Patient_ID"].ToString() + @""",""name"": """ + dr["Patient_No"].ToString() + " - " + dr["Full_Name"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }

                //else if (Request.QueryString["Table"] == "SampleNo")
                //{
                //    string sqlQuery;
                //    if (Request.QueryString["q"] != null)
                //    {
                //        string q = Request.QueryString["q"].ToString().Replace("'", "''");
                //        sqlQuery = @" SELECT TOP 1 sm.Sample_No,sm.Patient_ID, p.Patient_No, p.Full_Name
                //       FROM Sample_Master sm INNER JOIN Reg_patient p ON sm.Patient_ID = p.pat_id WHERE sm.Sample_No = '" + q + @"' ORDER BY sm.Created_Time DESC";
                //    }
                //    else
                //    {
                //        sqlQuery = @" SELECT DISTINCT TOP 20 sm.Sample_No, sm.Patient_ID, p.Patient_No, p.Full_Name
                //      FROM Sample_Master sm INNER JOIN Reg_patient p ON sm.Patient_ID = p.pat_id ORDER BY sm.Created_Time DESC";
                //    }

                //    string result = "";
                //    DataTable dt = DBClass.getDataTable(sqlQuery);
                //    foreach (DataRow dr in dt.Rows)
                //    {
                //        if (result != "") result += ",";
                //        result += @"{""id"":""" + dr["Sample_No"].ToString() + @""",""name"":""" + dr["Sample_No"].ToString() + " - " + dr["Full_Name"].ToString() + @""",
                //        ""patient_id"":""" + dr["Patient_ID"].ToString() + @"""}";
                //    }
                //    Response.Write("[" + result + "]");
                //}

                else if (Request.QueryString["Table"] == "SampleNo")
                {
                    string sqlQuery;
                    if (!string.IsNullOrEmpty(Request.QueryString["q"]))
                    {
                        string q = Request.QueryString["q"].Replace("'", "''");
                        sqlQuery = @"
            SELECT TOP 1 
                sm.Sample_No,
                sm.Patient_ID,
                p.Patient_No,
                p.Full_Name,
                ISNULL(b.Bill_ID, '') AS Bill_ID
            FROM Sample_Master sm
            INNER JOIN Reg_patient p ON sm.Patient_ID = p.pat_id
            INNER JOIN Sample_Detail sd ON sm.Sample_ID = sd.Sample_ID
            INNER JOIN Ar_Billing_Details bd ON sd.Bill_Detail_ID = bd.Bill_Details_ID
            INNER JOIN Ar_Billings b ON bd.Bill_ID = b.Bill_ID
            WHERE sm.Sample_No = '" + q + @"'";
                    }
                    else
                    {
                        sqlQuery = @"
            SELECT DISTINCT TOP 20
                sm.Sample_No,
                sm.Patient_ID,
                p.Patient_No,
                p.Full_Name,
                ISNULL(b.Bill_ID, '') AS Bill_ID
            FROM Sample_Master sm
            INNER JOIN Reg_patient p ON sm.Patient_ID = p.pat_id
            INNER JOIN Sample_Detail sd ON sm.Sample_ID = sd.Sample_ID
            INNER JOIN Ar_Billing_Details bd ON sd.Bill_Detail_ID = bd.Bill_Details_ID
            INNER JOIN Ar_Billings b ON bd.Bill_ID = b.Bill_ID
            ORDER BY sm.Sample_No DESC";
                    }

                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        if (result != "") result += ",";
                        string billId = dr["Bill_ID"].ToString();
                        string displayName = dr["Sample_No"].ToString() + " - " + dr["Full_Name"].ToString();

                        result += @"{""id"":""" + dr["Sample_No"].ToString() + @""",""name"":""" + displayName + @""",""patient_id"":""" + dr["Patient_ID"].ToString() + @""",""bill_id"":""" + billId + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }



                else if (Request.QueryString["Table"] == "Out_Patients")
                {
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                        sqlQuery = "Select  top 1 Patient_ID,Opd_No,Full_Name,Reg_PatId from Patients Where Opd_No = '" + Request.QueryString["q"].ToString() + "' order by Created_Time desc";
                    else
                        sqlQuery = "Select distinct (select top 1 Patient_ID from Patients where Patient_No=p.Patient_No)Patient_ID,Patient_No,Full_Name from Patients p where isnull(IsRevisit,'0')=0  order by Created_Time desc";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Patient_ID"].ToString() + @""",
                        ""name"":""" + dr["Opd_No"].ToString() + " - " + dr["Full_Name"].ToString() + @""",
                        ""regPatId"":""" + dr["Reg_PatId"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["Table"] == "Out_PatientsbyMrNo")
                {
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                        sqlQuery = "Select  top 1 p.Patient_ID,p.Opd_No,p.Full_Name,rp.pat_id,rp.mr_no_sequence  as Patient_No,p.Reg_PatId from Patients p join Reg_patient rp on p.Reg_PatId = rp.pat_id   Where rp.mr_no_sequence = '" + Request.QueryString["q"].ToString() + "' order by p.Created_Time desc";
                    else
                        sqlQuery = "Select distinct (select top 1 Patient_ID from Patients where Patient_No=p.Patient_No)Patient_ID,Patient_No,Full_Name from Patients p where isnull(IsRevisit,'0')=0  order by Created_Time desc";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Patient_ID"].ToString() + @"""," +
                                  @"""name"": """ + dr["Patient_No"].ToString() + " - " + dr["Full_Name"].ToString() + @"""," +
                                  @"""reg_patId"": """ + dr["Reg_PatId"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["Table"] == "Patients")
                {
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                        sqlQuery = "Select  top 1 pat_id as Patient_ID,Patient_No,Full_Name from Reg_patient  Where Patient_No = '" + Request.QueryString["q"].ToString() + "' order by Created_Time desc";
                    else
                        sqlQuery = "Select distinct (select top 1 Patient_ID from Patients where Patient_No=p.Patient_No)Patient_ID,Patient_No,Full_Name from Patients p where isnull(IsRevisit,'0')=0  order by Created_Time desc";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Patient_ID"].ToString() + @""",""name"": """ + dr["Patient_No"].ToString() + " - " + dr["Full_Name"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }

                //else if (Request.QueryString["Table"] == "PatientsByMr")
                //{
                //    string sqlQuery;

                //    if (Request.QueryString["q"] != null)
                //    {
                //        sqlQuery = @"SELECT TOP 1 
                //            Patient_ID,
                //            mr_no_sequence,
                //            Full_Name
                //     FROM Patients
                //     WHERE mr_no_sequence = '" + Request.QueryString["q"].ToString() + @"'
                //     ORDER BY Created_Time DESC";
                //    }
                //    else
                //    {
                //        sqlQuery = @"SELECT DISTINCT 
                //            Patient_ID,
                //            mr_no_sequence,
                //            Full_Name
                //     FROM Patients
                //     WHERE ISNULL(IsRevisit,'0') = '0'
                //     ORDER BY Created_Time DESC";
                //    }

                //    string result = "";
                //    DataTable dt = DBClass.getDataTable(sqlQuery);

                //    foreach (DataRow dr in dt.Rows)
                //    {
                //        result += (result == "") ? "" : ",";
                //        result += @"{""id"":""" + dr["Patient_ID"].ToString() +
                //                  @""",""name"": """ +
                //                  dr["mr_no_sequence"].ToString() + " - " +
                //                  dr["Full_Name"].ToString() + @"""}";
                //    }

                //    Response.Write("[" + result + "]");
                //}
                else if (Request.QueryString["Table"] == "PatientsByMr")
                {
                    string sqlQuery;

                    if (Request.QueryString["q"] != null)
                    {
                        sqlQuery = @"SELECT TOP 1
                        rp.Patient_No,
                        rp.Pat_Id,
                        rp.mr_no_sequence,
                        rp.Full_Name
                     FROM reg_patient rp
                     WHERE rp.mr_no_sequence = '" + Request.QueryString["q"].ToString() + @"'
                     ORDER BY rp.Created_Time DESC";
                    }
                    else
                    {
                        sqlQuery = @"SELECT DISTINCT
                        rp.Patient_No,
                        rp.Pat_Id,
                        rp.mr_no_sequence,
                        rp.Full_Name
                     FROM reg_patient rp
                     WHERE ISNULL(rp.IsRevisit,'0') = '0'
                     ORDER BY rp.Created_Time DESC";
                    }

                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);

                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Pat_Id"].ToString() +
                                  @""",""name"": """ +
                                  dr["mr_no_sequence"].ToString() + " - " +
                                  dr["Full_Name"].ToString() + @"""}";
                    }

                    Response.Write("[" + result + "]");
                }


                else if (Request.QueryString["Table"] == "Emergency_Patients")
                {
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                        sqlQuery = "Select  top 1 pat_id,Patient_No,Full_Name from Reg_patient Where  Patient_No = '" + Request.QueryString["q"].ToString() + "' order by Created_Time desc";
                    else
                        sqlQuery = "Select distinct (select top 1 pat_id from Reg_patient where Patient_No=p.Patient_No)Patient_ID,Patient_No,Full_Name from Reg_patient p  order by Created_Time desc";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["pat_id"].ToString() + @""",""name"": """ + dr["Patient_No"].ToString() + " - " + dr["Full_Name"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["Table"] == "PatientsByCNIC")
                {
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                        sqlQuery = "Select  top 1 Patient_ID,Patient_No,Full_Name,NIC from Patients Where NIC = '" + Request.QueryString["q"].ToString() + "' order by Entry_Date desc";
                    else
                        sqlQuery = "Select distinct (select top 1 Patient_ID from Patients where Patient_No=p.Patient_No)Patient_ID,Patient_No,Full_Name from Patients p where IsRevisit='False'  order by Entry_Date desc";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Patient_ID"].ToString() + @""",""name"": """ + dr["NIC"].ToString() + " - " + dr["Full_Name"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["Table"] == "PatientsByContectNO")
                {
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                        sqlQuery = "Select  top 1 Patient_ID,Patient_No,Full_Name,Mobile1 from Patients Where Mobile1 = '" + Request.QueryString["q"].ToString() + "' order by Entry_Date desc";
                    else
                        sqlQuery = "Select distinct (select top 1 Patient_ID from Patients where Patient_No=p.Patient_No)Patient_ID,Patient_No,Full_Name from Patients p where IsRevisit='False'  order by Entry_Date desc";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Patient_ID"].ToString() + @""",""name"": """ + dr["Mobile1"].ToString() + " - " + dr["Full_Name"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["Table"] == "PatientsFetchByID")
                {
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                        sqlQuery = "Select  top 1 pat_id as Patient_ID,Patient_No,Full_Name from Reg_patient Where pat_id ='" + Request.QueryString["q"].ToString() + "' order by Created_time desc";
                    else
                        sqlQuery = "Select distinct (select top 1 pat_id as Patient_ID from Reg_patient where Patient_No=p.Patient_No)Patient_ID,Patient_No,Full_Name  from Reg_patient p    order by Created_time desc";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Patient_ID"].ToString() + @""",""name"": """ + dr["Patient_No"].ToString() + " - " + dr["Full_Name"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["Table"] == "PatientsFetchByREgID")
                {
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                        sqlQuery = "Select  top 1 pat_id as Patient_ID,Patient_No,Full_Name from Reg_patient Where pat_id ='" + Request.QueryString["q"].ToString() + "' order by Created_time desc";
                    else
                        sqlQuery = "Select distinct (select top 1 pat_id as Patient_ID from Patients where Patient_No=p.Patient_No)Patient_ID,Patient_No,Full_Name from Reg_patient p where   order by Created_time desc";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Patient_ID"].ToString() + @""",""name"": """ + dr["Patient_No"].ToString() + " - " + dr["Full_Name"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["Table"] == "BillNoFetchByID")
                {
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                        sqlQuery = "Select  * from Ar_Billings Where Bill_No ='" + Request.QueryString["q"].ToString() + "'";
                    else
                        sqlQuery = "Select  * from Ar_Billings";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Bill_ID"].ToString() + @""",""name"": """ + dr["Bill_No"].ToString() + @""",""type"": """ + dr["Patient_ID"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }

                else if (Request.QueryString["Table"] == "OutPatients")
                {
                    string sqlQuery;
                    if (Request.QueryString["Patient_ID"] != null)
                        sqlQuery = "Select  top 1 Patient_ID,Opd_No,Full_Name from Patients Where Patient_ID = '" + Request.QueryString["Patient_ID"].ToString() + "' and IsRevisit='False'";
                    else
                        sqlQuery = "Select distinct (select top 1 Patient_ID from Patients where Patient_No=p.Patient_No)Patient_ID,Opd_No,Full_Name from Patients p where IsRevisit='False'"; string result = "";

                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    // It is for the patients coming from patient waiting select list.
                    if (dt.Rows.Count == 0)
                    {
                        if (Request.QueryString["Patient_ID"] != null)
                            sqlQuery = "Select  top 1 Patient_ID, Opd_No,Full_Name from Patients Where Patient_ID = '" + Request.QueryString["Patient_ID"].ToString() + "' ";
                        else
                            sqlQuery = "Select distinct (select top 1 Patient_ID from Patients where Patient_No=p.Patient_No)Patient_ID,Opd_No,Full_Name from Patients p where IsRevisit='False'";
                        dt = DBClass.getDataTable(sqlQuery);
                    }
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Patient_ID"].ToString() + @""",""name"": """ + dr["Opd_No"].ToString() + " - " + dr["Full_Name"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["Table"] == "OutPatients_MrNo")
                {
                    string sqlQuery;
                    if (Request.QueryString["Patient_ID"] != null)
                        sqlQuery = "Select  top 1 Patient_ID,rp.Patient_No,rp.Full_Name from Patients p join Reg_patient rp on p.Reg_PatId = rp.pat_id Where p.Patient_ID = '" + Request.QueryString["Patient_ID"].ToString() + "' and IsRevisit='False'";
                    else
                        sqlQuery = "Select distinct (select top 1 Patient_ID from Patients where Patient_No=p.Patient_No)Patient_ID,Patient_No,Full_Name from Patients p where IsRevisit='False'"; string result = "";

                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    // It is for the patients coming from patient waiting select list.
                    if (dt.Rows.Count == 0)
                    {
                        if (Request.QueryString["Patient_ID"] != null)
                            sqlQuery = "Select  top 1 Patient_ID,rp.Patient_No,rp.Full_Name from Patients p join Reg_patient rp on p.Reg_PatId = rp.pat_id Where p.Patient_ID = '" + Request.QueryString["Patient_ID"].ToString() + "' ";
                        else
                            sqlQuery = "Select distinct (select top 1 Patient_ID from Patients where Patient_No=p.Patient_No)Patient_ID,Patient_No,Full_Name from Patients p where IsRevisit='False'";
                        dt = DBClass.getDataTable(sqlQuery);
                    }
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Patient_ID"].ToString() + @""",""name"": """ + dr["Patient_No"].ToString() + " - " + dr["Full_Name"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }

                else if (Request.QueryString["Table"] == "Appointments")
                {
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                        sqlQuery = "select top 1 pat.*,app.Appointment_ID from Appointment_Form app,patients pat where app.Appointment_Code like '%" + Request.QueryString["q"].ToString() + "%'";
                    else
                        sqlQuery = "select pat.*,app.Appointment_ID from Patient_Appointment app,patients pat where pat.Patient_ID=app.Patient_ID";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Patient_ID"].ToString() + @""",""name"": """ + dr["Patient_No"].ToString() + " - " + dr["Full_Name"].ToString() + @""",""Appointment_ID"": """ + dr["Appointment_ID"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }

                else if (Request.QueryString["Table"] == "Laboratory_Test" && Request.QueryString["Record"] == "Edit")
                {
                    string sqlQuery;
                    string result = "";
                    if (Request.QueryString["q"].ToString() != "End of expression expected" && Request.QueryString["q"] != null)
                    {
                        int id = Convert.ToInt32(Request.QueryString["q"]);
                        sqlQuery = "Select * from Laboratory_Test where Lab_Test_ID = " + id + "";

                        DataTable dt = DBClass.getDataTable(sqlQuery);
                        foreach (DataRow dr in dt.Rows)
                        {
                            result += (result == "") ? "" : ",";
                            result += @"{""id"":""" + dr["Lab_Test_ID"].ToString() + @""",""name"": """ + dr["Lab_Test_ID"].ToString() + @"""}";
                        }

                    }
                    Response.Write("[" + result + "]");
                }

                else if (Request.QueryString["Table"] == "Laboratory_Test")
                {
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                        sqlQuery = "Select * from Laboratory_Test Where Lab_Test_ID like '%" + Request.QueryString["q"].ToString() + "%'";
                    else
                        sqlQuery = "Select * from Laboratory_Test ";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Lab_Test_ID"].ToString() + @""",""name"": """ + dr["Lab_Test_ID"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["Table"] == "Billing")
                {
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                        sqlQuery = "Select * From Ar_Billings WHERE Bill_No= '" + Request.QueryString["q"].ToString() + "'";
                    else
                        sqlQuery = "SELECT * FROM Ar_Billings";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Bill_Id"].ToString() + @""",""name"": """ + dr["Bill_No"].ToString() + @""",""PaientID"": """ + dr["Patient_ID"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }

                else if (Request.QueryString["Table"] == "Symtoms" && Request.QueryString["Mode"] == "Edit")
                {
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                    {
                        sqlQuery = "select DataValue_Name,DataValue_Description from DataValues dv, ValueSet vs where dv.ValueSet_ID=vs.ValueSet_ID and vs.ValueSet_Name='Symtoms' and DataValue_Name like '%" + Request.QueryString["q"].ToString() + "%'";
                    }
                    else
                        sqlQuery = "select DataValue_Name,DataValue_Description from DataValues dv, ValueSet vs where dv.ValueSet_ID=vs.ValueSet_ID and vs.ValueSet_Name='Symtoms'";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["DataValue_Name"].ToString() + @""",""name"": """ + dr["DataValue_Description"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["Table"] == "Symtoms")
                {
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                    {
                        sqlQuery = "select DataValue_Name,DataValue_Description from DataValues dv, ValueSet vs where dv.ValueSet_ID=vs.ValueSet_ID and vs.ValueSet_Name='Symtoms' and DataValue_Description like '%" + Request.QueryString["q"].ToString() + "%'";
                    }
                    else
                        sqlQuery = "select DataValue_Name,DataValue_Description from DataValues dv, ValueSet vs where dv.ValueSet_ID=vs.ValueSet_ID and vs.ValueSet_Name='Symtoms'";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["DataValue_Name"].ToString() + @""",""name"": """ + dr["DataValue_Description"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["Table"] == "Pacakges")
                {
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                    {
                        sqlQuery = "select * from Packages where Package_Name like '%" + Request.QueryString["q"].ToString() + "%'";
                    }
                    else
                        sqlQuery = "select * from Packages ";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Package_ID"].ToString() + @""",""name"": """ + dr["Package_Name"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["Table"] == "Donor")
                {
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                    {
                        sqlQuery = "select * from Donor where Donor_Id=" + Request.QueryString["q"].ToString();
                    }
                    else
                        sqlQuery = "select * from Donor ";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["Donor_Id"].ToString() + @""",""name"": """ + dr["Donor_Id"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["Table"] == "INV_ItemsForBilling")
                {
                    string sqlQuery;
                    var s = Request.QueryString["Panel"];
                    if (Request.QueryString["q"] != null)
                        sqlQuery = "Select top 1000 Item_ID as ItemID,Item_Code as ItemCode,Description as ItemName,Pharmacy_Item, Sale_Rate as Amount,case when Services = 1 then 'Service' when Services = 0 then 'Item' else '' end ItemType from INV_Items Where (Services = 1)  and Book_ID = 1  and Active=1 and Description like'%" + Request.QueryString["q"] + "%'";
                    else
                        sqlQuery = "Select  top 1000  Item_ID as ItemID,Item_Code as ItemCode,Description as ItemName,Sale_Rate as Amount,case when Services=1 then 'Service' when Services=0 then 'Item' else '' end ItemType from INV_Items Where (Pharmacy_Item=0 or Pharmacy_Item is null) and Active=1 and Book_ID=" + AppConfig.Book_ID + "";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["ItemID"].ToString() + @""",""name"": """ + dr["ItemName"].ToString() + @""",""Type"": """ + dr["ItemType"].ToString() + @""",""Amount"": """ + dr["Amount"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }


               
                else if (Request.QueryString["Table"] == "INV_ItemsPayment")
                {
                    string sqlQuery;
                    var s = Request.QueryString["Panel"];
                    if (Request.QueryString["q"] != null)
                        sqlQuery = "Select   top 1000 Item_ID as ItemID,Item_Code as ItemCode,Description as ItemName,Sale_Rate as Amount,case when Services=1 then 'Service' when Services=0 then 'Item' else '' end ItemType from INV_Items Where (Pharmacy_Item=0 or Pharmacy_Item is null) and  ISNULL(Payment,'0')=1 and Book_ID=1 and Description like'%" + Request.QueryString["q"] + "%'";
                    else
                        sqlQuery = "Select  top 1000  Item_ID as ItemID,Item_Code as ItemCode,Description as ItemName,Sale_Rate as Amount,case when Services=1 then 'Service' when Services=0 then 'Item' else '' end ItemType from INV_Items Where (Pharmacy_Item=0 or Pharmacy_Item is null) and Book_ID=" + AppConfig.Book_ID + "";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["ItemID"].ToString() + @""",""name"": """ + dr["ItemName"].ToString() + @""",""Type"": """ + dr["ItemType"].ToString() + @""",""Amount"": """ + dr["Amount"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["Table"] == "Inv_Items_Panel")
                {
                    string sqlQuery;
                    var Panel = Request.QueryString["Panel"];
                    if (Request.QueryString["q"] != null)
                        sqlQuery = "Select   top 1000 inv.Item_ID as ItemID,inv.Item_Code as ItemCode,Description as ItemName,pnl.Rate as Amount,case when Services=1 then 'Service' when Services=0 then 'Item' else '' end ItemType from INV_Items inv,Panel_Detail_Services pnl Where (Pharmacy_Item=0 or Pharmacy_Item is null)and inv.Item_ID = pnl.Item_ID and Book_ID=1 and ISNULL(IsBill_Item,'0')=1 and pnl.Panel_ID='" + Panel + "' and Description like'%" + Request.QueryString["q"] + "%'";
                    else
                        sqlQuery = "Select  top 1000  inv.Item_ID as ItemID,inv.Item_Code as ItemCode,Description as ItemName,pnl.Rate as Amount,case when Services=1 then 'Service' when Services=0 then 'Item' else '' end ItemType from INV_Items inv,Panel_Detail_Services pnl Where (Pharmacy_Item=0 or Pharmacy_Item is null) and inv.Item_ID = pnl.Item_ID and Book_ID=" + AppConfig.Book_ID + "";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["ItemID"].ToString() + @""",""name"": """ + dr["ItemName"].ToString() + @""",""Type"": """ + dr["ItemType"].ToString() + @""",""Amount"": """ + dr["Amount"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["Table"] == "Inv_Items_Panel_Private")
                {
                    string sqlQuery;
                    var s = Request.QueryString["Panel"];
                    if (Request.QueryString["q"] != null)
                        sqlQuery = "Select   top 1000 inv.Item_ID as ItemID,inv.Item_Code as ItemCode,Description as ItemName,pnl.Rate as Amount,case when Services=1 then 'Service' when Services=0 then 'Item' else '' end ItemType from INV_Items inv,Panel_Detail_Services pnl Where (Pharmacy_Item=0 or Pharmacy_Item is null)and inv.Item_ID = pnl.Item_ID and Book_ID=1 and ISNULL(IsBill_Item,'0')=1 and pnl.Panel_ID=36 and Description like'%" + Request.QueryString["q"] + "%'";
                    else
                        sqlQuery = "Select  top 1000  inv.Item_ID as ItemID,inv.Item_Code as ItemCode,Description as ItemName,pnl.Rate as Amount,case when Services=1 then 'Service' when Services=0 then 'Item' else '' end ItemType from INV_Items inv,Panel_Detail_Services pnl Where (Pharmacy_Item=0 or Pharmacy_Item is null) and inv.Item_ID = pnl.Item_ID and Book_ID=" + AppConfig.Book_ID + "";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["ItemID"].ToString() + @""",""name"": """ + dr["ItemName"].ToString() + @""",""Type"": """ + dr["ItemType"].ToString() + @""",""Amount"": """ + dr["Amount"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["Table"] == "Inv_Items_Panel_Sehat_Sahulat")
                {
                    string sqlQuery;
                    var s = Request.QueryString["Panel"];
                    if (Request.QueryString["q"] != null)
                        sqlQuery = "Select   top 1000 inv.Item_ID as ItemID,inv.Item_Code as ItemCode,Description as ItemName,pnl.Rate as Amount,case when Services=1 then 'Service' when Services=0 then 'Item' else '' end ItemType from INV_Items inv,Panel_Detail_Services pnl Where (Pharmacy_Item=0 or Pharmacy_Item is null)and inv.Item_ID = pnl.Item_ID and Book_ID=1 and ISNULL(IsBill_Item,'0')=1 and pnl.Panel_ID=35 and Description like'%" + Request.QueryString["q"] + "%'";
                    else
                        sqlQuery = "Select  top 1000  inv.Item_ID as ItemID,inv.Item_Code as ItemCode,Description as ItemName,pnl.Rate as Amount,case when Services=1 then 'Service' when Services=0 then 'Item' else '' end ItemType from INV_Items inv,Panel_Detail_Services pnl Where (Pharmacy_Item=0 or Pharmacy_Item is null) and inv.Item_ID = pnl.Item_ID and Book_ID=" + AppConfig.Book_ID + "";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["ItemID"].ToString() + @""",""name"": """ + dr["ItemName"].ToString() + @""",""Type"": """ + dr["ItemType"].ToString() + @""",""Amount"": """ + dr["Amount"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["Table"] == "INV_ItemsForPharmacy")
                {
                    string sqlQuery;
                    var data = Request.QueryString["Editdata"];
                    if (data == null)
                    {
                        sqlQuery = "Select   top 1000 Item_ID as ItemID,Item_Code as ItemCode,Description as ItemName,Salt,Purchase_Rate as Amount,case when Services=1 then 'Service' when Services=0 then 'Item' else '' end ItemType from INV_Items Where Pharmacy_Item=1 and  Book_ID=" + AppConfig.Book_ID + " AND (Description like'%" + Request.QueryString["q"] + "%' OR Item_Code like'%" + Request.QueryString["q"] + "%' OR Salt like'%" + Request.QueryString["q"] + "%')";
                    }
                    else
                    {
                        sqlQuery = "Select   top 1000 Item_ID as ItemID,Item_Code as ItemCode,Description as ItemName,Salt,Purchase_Rate as Amount,case when Services=1 then 'Service' when Services=0 then 'Item' else '' end ItemType from INV_Items Where Pharmacy_Item=1 and  Book_ID=" + AppConfig.Book_ID + " AND Item_Code=" + Request.QueryString["Editdata"] + "";
                    }

                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["ItemCode"].ToString() + @""",""name"": """ +
                            dr["ItemCode"].ToString() + "-" + dr["ItemName"].ToString() + "-" + dr["Salt"].ToString() + @""",""Type"": """ + dr["ItemType"].ToString() + @""",""Amount"": """ + dr["Amount"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }

                else if (Request.QueryString["Table"] == "POForPharmacy")
                {
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                        sqlQuery = "select PO_ID as PO_ID,PO_No as PO_No,op.Vendor_ID as VendorID,PO_Date as Date,(select vendor_Name from AP_Vendors where Vendor_ID=op.Vendor_ID) as Vendor_ID from AP_Purchase_Orders op where (PO_No like'%" + Request.QueryString["q"] + "%' or dbo.GetVendorName(Vendor_ID) like'%" + Request.QueryString["q"] + "%')";
                    else
                        sqlQuery = "select PO_ID,PO_No,Vendor_ID from AP_Purchase_Orders";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["PO_No"].ToString() + @""",""Venderid"":""" + dr["VendorID"].ToString() + @""",""name"": """ +
                            dr["PO_No"].ToString() + "-" + "-" + "-" + "-" + dr["Vendor_ID"].ToString() + "-" + "-" + "-" + "-" + dr["Date"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }




                else if (Request.QueryString["Table"] == "INV_ItemsPharmacy")
                {
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                        sqlQuery = "Select Item_ID as ItemID,Item_Code as ItemCode,Description as ItemName,Sale_Rate as Amount,case when Services=1 then 'Service' when Services=0 then 'Item' else '' end ItemType from INV_Items Where Pharmacy_Item=1 and Book_ID=" + AppConfig.Book_ID + " AND Description like'%" + Request.QueryString["q"] + "%'";
                    else
                        sqlQuery = "Select Item_ID as ItemID,Item_Code as ItemCode,Description as ItemName,Sale_Rate as Amount,case when Services=1 then 'Service' when Services=0 then 'Item' else '' end ItemType from INV_Items Where Pharmacy_Item=1 and Book_ID=" + AppConfig.Book_ID + "";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["ItemID"].ToString() + @""",""name"": """ + dr["ItemName"].ToString() + @""",""Type"": """ + dr["ItemType"].ToString() + @""",""Amount"": """ + dr["Amount"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
                else if (Request.QueryString["Table"] == "PacakgesForBilling")
                {
                    string sqlQuery;
                    if (Request.QueryString["q"] != null)
                        sqlQuery = "Select  Packages_ID as ItemID,Package_Name as ItemName,'Packages' ItemType from Packages m where m.Package_Name like'%" + Request.QueryString["q"] + "%'";
                    else
                        sqlQuery = "Select Packages_ID as ItemID,Package_Name as ItemName,'Packages' ItemType from Packages m";
                    string result = "";
                    DataTable dt = DBClass.getDataTable(sqlQuery);
                    foreach (DataRow dr in dt.Rows)
                    {
                        result += (result == "") ? "" : ",";
                        result += @"{""id"":""" + dr["ItemID"].ToString() + @""",""name"": """ + dr["ItemName"].ToString() + @""",""Type"": """ + dr["ItemType"].ToString() + @"""}";
                    }
                    Response.Write("[" + result + "]");
                }
            }
        }
    }
}