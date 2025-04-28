using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using Infragistics.Web.UI.GridControls;
using System.Data.SqlClient;

namespace PMS
{
    public partial class CustomerView : System.Web.UI.Page
    {
        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            if (Session["UserName"] == null || Session["Company_Name"] == null || Session["Company_ID"] == null || Session["Book_ID"] == null)
            {
                Session.Abandon();
                Response.Redirect("~/Account/Login.aspx", true);
            }
            else
            {
                string qury = "Select [Customer_ID],[Customer_Name],[Father_Name]" +
                              ",[Customer_Address],[Custoemer_Permanet_Address] ,[Custoemer_Resident_Number]" +
                              ",[Custoemer_Office_Number],[Customer_Email],[Customer_Fax_Number] ,[Customer_CNIC]" +
                              ",[Customer_Occupation] ,dbo.GetDataValueName('City',City) as City from Ar_Customers where Company_ID=" + AppConfig.Company_ID + " and Book_ID=" + AppConfig.Book_ID;
                sqlList.SelectCommand = qury;
                this.sqlList.ConnectionString = DBClass.ConnectionString();
            }
        }
        protected void Page_Load(object sender, EventArgs e)
        {
         
            //if (!IsPostBack)
            //    BindCustomerList();
        }
        /*
        private void BindCustomerList()
        {
            DataTable dtbCustomerList = new DataTable();
            dtbCustomerList = DBClass.getDataTable("Select [Customer_ID],[Customer_Name],[Father_Name]" +
             ",[Customer_Address],[Custoemer_Permanet_Address] ,[Custoemer_Resident_Number]" +
             ",[Custoemer_Office_Number],[Customer_Email],[Customer_Fax_Number] ,[Customer_CNIC]" +
             ",[Customer_Occupation] ,dbo.GetDataValueName('City',City) as City from Ar_Customers");
            grdCustomerList.DataSource = dtbCustomerList;
            grdCustomerList.DataBind();
        }
        protected void grdCustomerList_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
            }
        }

        protected void grdCustomerList_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Remove")
            {
                string Account_ID = "";
                Account_ID = DBClass.getField("Select Account_ID from AR_Customers where Customer_ID=" + Convert.ToInt32(e.CommandArgument));
                if (Account_ID != "")
                    DBClass.deleteRecord("Delete GL_Accounts Where Account_ID=" + Convert.ToInt32(Account_ID));
           
                bool rowDeleted = DBClass.deleteRecord("Delete Ar_Customers Where Customer_ID=" + Convert.ToInt32(e.CommandArgument) + ";Delete AR_Sales Where Customer_ID=" + Convert.ToInt32(e.CommandArgument));
              
                if (rowDeleted)
                {
                    BindCustomerList();
                    upList.Update();
                }
            }
        }

        protected void grdCustomerList_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            grdCustomerList.PageIndex = e.NewPageIndex;
            BindCustomerList();
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
                    string Account_ID = "";
                    string SQlQuery = "";
                    Account_ID = DBClass.getField("Select Account_ID from AR_Customers where Customer_ID=" + Convert.ToInt32(e.CommandArgument));
                    if (Account_ID != "")
                        SQlQuery += "Delete GL_Accounts Where Account_ID=" + Convert.ToInt32(Account_ID) + " ;";
                    SQlQuery += "Delete Ar_Customers Where Customer_ID=" + Convert.ToInt32(e.CommandArgument) + ";Delete AR_Sales Where Customer_ID=" + Convert.ToInt32(e.CommandArgument);
                    bool rowDeleted = DBClass.exectueQuery(SQlQuery, tranObj, con);
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