using Infragistics.Web.UI.GridControls;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class AssetSelectionView : System.Web.UI.Page
    {
        protected override void OnInit(EventArgs e)
        {
            if (Session["Company_ID"] != null)
            {
                base.OnInit(e);

                string qury = "Select AstSlct.Asset_Selection_ID, AstCtg.Asset_Cat_Name As Category_Name, AstSubCtg.Asset_SubCat_Name As SubCategory_Name, AstSlct.Item_Serial, Comp.Company_Name, CONCAT (Loc.Location_ID, ' - ', Loc.Location_Description) As Branch From Asset_Selection As AstSlct Join Asset_Category As AstCtg On AstSlct.Asset_Cat_ID=AstCtg.Asset_Category_Id Join Asset_SubCategory As AstSubCtg On AstSlct.Asset_SubCat_ID=AstSubCtg.Asset_SubCat_ID Join sys_Companys As Comp On AstSlct.Company_ID=Comp.Company_ID join Location As Loc On AstSlct.Location_ID=Loc.Location_ID";
                sqlList.SelectCommand = qury;
                this.sqlList.ConnectionString = DBClass.ConnectionString();
            }
            else
            {
                Session.Abandon();
                Response.Redirect("~/Account/Login.aspx", true);
            }
        }
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        protected void whdgList_ItemCommand(object sender, Infragistics.Web.UI.GridControls.HandleCommandEventArgs e)
        {
            if (e.CommandName == "Remove")
            {
                SqlTransaction tranObj = null;
                SqlConnection con = new SqlConnection(DBClass.ConnectionString());
                con.Open();
                tranObj = con.BeginTransaction();
                try
                {
                    var Userid = AppConfig.UserID;
                    bool rowDeleted = DBClass.exectueQuery("Update Asset_Selection Set IsDeleted=1,Deleted_By='"+ Userid + "',Deleted_Time=GetDate() Where Asset_Selection_ID=" + Convert.ToInt32(e.CommandArgument) + "", tranObj, con);
                    if (rowDeleted)
                    {
                        Response.Redirect(Request.RawUrl, false);
                        upList.Update();
                    }
                    tranObj.Commit();
                }
                catch (Exception exc)
                {
                    if (tranObj != null)
                        tranObj.Rollback();
                    throw new Exception(exc.Message);
                }
                finally
                {
                    con.Close();
                }
            }
        }
        protected void whdgList_RowIslandsPopulating(object sender, Infragistics.Web.UI.GridControls.ContainerRowCancelEventArgs e)
        {
            this.whdgList.RowIslandDataBinding += new RowIslandEventHandler(whdgList_RowIslandDataBinding);
        }
        protected void whdgList_RowIslandDataBinding(object sender, RowIslandEventArgs e)
        {
            // Sort a Column in PARENT BAND
            if (e.RowIsland.DataMember == "whdsList")
            {
                Sorting sort = e.RowIsland.Behaviors.Sorting;
                sort.SortedColumns.Add("ItemName", Infragistics.Web.UI.SortDirection.Descending);
            }

            // Sort a Column in CHILD BAND
            if (e.RowIsland.DataMember == "whdsList"
               && e.RowIsland.ParentRow == this.whdgList.GridView.Rows[1])
            {
                Sorting sort = e.RowIsland.Behaviors.Sorting;
                sort.SortedColumns.Add(e.RowIsland.Columns[1], Infragistics.Web.UI.SortDirection.Ascending);
            }
        }
    }
}