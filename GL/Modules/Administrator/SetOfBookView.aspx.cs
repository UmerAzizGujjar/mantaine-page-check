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
    public partial class SetOfBookView : System.Web.UI.Page
    {
        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            string qury = "Select * from GL_SetOfBook";
            sqlList.SelectCommand = qury;
            this.sqlList.ConnectionString = DBClass.ConnectionString();
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            
            //if (!IsPostBack)
            //    BindSetOfBooks();
        }
        /*
        private void BindSetOfBooks()
        {
            DataTable dtbCompanyList = new DataTable();
            dtbCompanyList = DBClass.getDataTable("Select * from GL_SetOfBook");
            grdBookList.DataSource = dtbCompanyList;
            grdBookList.DataBind();
        }

        protected void grdBookList_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Remove")
            {
                bool rowDeleted = DBClass.deleteRecord("Delete GL_SetOfBook Where Book_ID=" + Convert.ToInt32(e.CommandArgument));
                if (rowDeleted)
                {
                    BindSetOfBooks();
                    upList.Update();
                }
            }
        }

        protected void grdBookList_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            grdBookList.PageIndex = e.NewPageIndex;
            BindSetOfBooks();
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
                    bool rowDeleted = DBClass.exectueQuery("Delete GL_SetOfBook Where Book_ID=" + Convert.ToInt32(e.CommandArgument), tranObj, con);

                    if (rowDeleted)
                    {
                        tranObj.Commit();
                        Response.Redirect(Request.RawUrl, false);
                        upList.Update();
                    }
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