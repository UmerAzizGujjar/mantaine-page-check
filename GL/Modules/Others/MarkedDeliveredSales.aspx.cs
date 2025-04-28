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
    public partial class MarkedDeliveredSales : System.Web.UI.Page
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
            //DataTable dtSales = DBClass.getDataTable("Select * from ar_Sales where delivered = 'false' and Sales_Status = 'Approved' and company_ID=" + AppConfig.Company_ID);
            //gvUnDeliveredSales.DataSource = dtSales;
            //gvUnDeliveredSales.DataBind();
            //foreach (GridViewRow row in gvUnDeliveredSales.Rows)
            //{
            //    CheckBox chechkSelect = (CheckBox)row.FindControl("cbSelect");
            //    if (chechkSelect != null)
            //        chechkSelect.Checked = true;
            //}
            string qury = "Select * from ar_Sales where delivered = 'false' and Sales_Status = 'Approved' and company_ID = " + AppConfig.Company_ID + " ORDER BY Sales_Date DESC;";
            sqlList.SelectCommand = qury;
            sqlList.ConnectionString = DBClass.ConnectionString();
        }

        protected void btnApprove_Click(object sender, EventArgs e)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            foreach (GridRecord row in whdgList.Rows)
            {
                CheckBox checkBox = row.Items[0].FindControl("cbSelect") as CheckBox;
                Label salesID = row.Items[0].FindControl("lblSales_ID") as Label;
                if (checkBox.Checked)
                {
                    Ar_Sale sales = (from tbl in db.Ar_Sales
                                     where tbl.Sales_ID == Convert.ToInt32(salesID.Text)
                                     select tbl).SingleOrDefault();
                    sales.Delivered = true;
                    //sales.Approved_Time = DateTime.Now;
                    //sales.Approved_By = AppConfig.UserID;
                    db.SubmitChanges();
                }
            }
            Response.Redirect(Request.RawUrl);
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            foreach (GridRecord row in whdgList.Rows)
            {
                CheckBox checkBox = row.Items[0].FindControl("cbSelect") as CheckBox;
                Label salesID = row.Items[0].FindControl("lblSales_ID") as Label;
                if (checkBox.Checked)
                {
                    Ar_Sale sales = (from tbl in db.Ar_Sales
                                     where tbl.Sales_ID == Convert.ToInt32(salesID.Text)
                                     select tbl).SingleOrDefault();
                    sales.Delivered = false;
                    //sales.Approved_Time = DateTime.Now;
                    //sales.Approved_By = AppConfig.UserID;
                    db.SubmitChanges();
                }
            }
            Response.Redirect(Request.RawUrl);
        }

        //protected void gvUnDeliveredSales_PageIndexChanging(object sender, GridViewPageEventArgs e)
        //{
        //    gvUnDeliveredSales.PageIndex = e.NewPageIndex;
        //    bindGrid();
        //}
    }
}