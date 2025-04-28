using Infragistics.Web.UI.GridControls;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class MarkedDeliveredPurchase : System.Web.UI.Page
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
                bindGrid();
            }
        }
        protected void Page_Load(object sender, EventArgs e)
        {
           
        }

        private void bindGrid()
        {
            //DataTable dtPurchase = DBClass.getDataTable("Select * from Ap_Purchases where delivered = 'false' and Purchases_Status = 'Approved' and company_ID=" + AppConfig.Company_ID);
            //gvUnDeliveredPurchase.DataSource = dtPurchase;
            //gvUnDeliveredPurchase.DataBind();
            string qury = "Select * from Ap_Purchases where delivered = 'false' and Purchases_Status = 'Approved' and company_ID = " + AppConfig.Company_ID + " ORDER BY Purchases_Date DESC;";
            sqlList.SelectCommand = qury;
            this.sqlList.ConnectionString = DBClass.ConnectionString();
        }

        //protected void btnApprove_Click(object sender, EventArgs e)
        //{
        //    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
        //    foreach (GridRecord row in whdgList.Rows)
        //    {
        //        CheckBox checkBox = row.Items[0].FindControl("cbSelect") as CheckBox;
        //        Label purchaseId = row.Items[0].FindControl("lblPurchase_ID") as Label;
        //        if (checkBox.Checked)
        //        {
        //            AP_Purchase purchase = (from tbl in db.AP_Purchases
        //                             where tbl.Purchases_ID == Convert.ToInt32(purchaseId.Text)
        //                             select tbl).SingleOrDefault();
        //            purchase.Delivered = true;
        //            //sales.Approved_Time = DateTime.Now;
        //            //sales.Approved_By = AppConfig.UserID;
        //            db.SubmitChanges();
        //        }
        //    }
        //    Response.Redirect(Request.RawUrl);
        //}

        protected void whdgList_RowIslandsPopulating(object sender, Infragistics.Web.UI.GridControls.ContainerRowCancelEventArgs e)
        {
            whdgList.RowIslandDataBinding += new RowIslandEventHandler(whdgList_RowIslandDataBinding);
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
               && e.RowIsland.ParentRow == whdgList.GridView.Rows[1])
            {
                Sorting sort = e.RowIsland.Behaviors.Sorting;
                sort.SortedColumns.Add(e.RowIsland.Columns[1], Infragistics.Web.UI.SortDirection.Ascending);
            }
        }

        //protected void gvUnDeliveredPurchase_PageIndexChanging(object sender, GridViewPageEventArgs e)
        //{
        //    gvUnDeliveredPurchase.PageIndex = e.NewPageIndex;
        //    bindGrid();
        //}
    }
}