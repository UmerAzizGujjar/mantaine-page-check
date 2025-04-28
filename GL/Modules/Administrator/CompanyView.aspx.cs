using Infragistics.Web.UI.GridControls;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class CompanyView : System.Web.UI.Page
    {
        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            string qury = "Select * from sys_Companys Left Join GL_SetOfBook on sys_Companys.Book_ID=GL_SetOfBook.Book_ID";
            sqlList.SelectCommand = qury;
            this.sqlList.ConnectionString = DBClass.ConnectionString();
        }
        protected void Page_Load(object sender, EventArgs e)
        {
           
            //if (!IsPostBack)
            //    BindCompany();
        }
        /*
        private void BindCompany()
        {
            DataTable dtbCompanyList = new DataTable();
            dtbCompanyList = DBClass.getDataTable("Select * from sys_Companys");
            grdCompanyList.DataSource = dtbCompanyList;
            grdCompanyList.DataBind();
        }

        protected void grdCompanyList_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Remove") 
            {
                bool rowDeleted = DBClass.deleteRecord("Delete sys_Companys Where Company_ID=" + Convert.ToInt32(e.CommandArgument) + ";Delete GL_Vouchers Where Company_ID=" + Convert.ToInt32(e.CommandArgument));
                if (rowDeleted) 
                {
                    BindCompany();
                    upList.Update();
                }
            }
        }

        protected void grdCompanyList_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow) 
            {
                Label lblSetOfBookID = (Label)e.Row.FindControl("lblSetOfBookID");
                if (lblSetOfBookID != null && lblSetOfBookID.Text!="") 
                {
                    lblSetOfBookID.Text = DBClass.getField("select Name From GL_SetOfBook Where Book_ID=" + Convert.ToInt32(lblSetOfBookID.Text));
                }
            }
        }
         */
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
                    bool rowDeleted = DBClass.exectueQuery("Delete sys_Companys Where Company_ID=" + Convert.ToInt32(e.CommandArgument) + ";Delete GL_Vouchers Where Company_ID=" + Convert.ToInt32(e.CommandArgument), tranObj, con);
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
        void whdgList_RowIslandDataBinding(object sender, RowIslandEventArgs e)
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