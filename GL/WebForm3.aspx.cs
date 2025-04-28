using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace PMS
{
    public partial class WebForm3 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                DataTable dt = new DataTable();
                dt.Columns.Add("Children_ID");
                dt.Columns.Add("Children_Name");
                dt.Columns.Add("Age");
                gv.DataSource = dt;
                gv.DataBind();
                Session["dt_Children"] = dt;
            }
        }

        protected void gv_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            Console.WriteLine(e.CommandName);
            Page.Title = e.CommandName;
            if (e.CommandName == "Update Cancel")
            {
                gv.ShowFooter = false;
                gv.EditIndex = -1;
                refreshgrid();
            }
            else if (e.CommandName == "Add New")
            {
                DataTable dt = new DataTable();
                dt = (DataTable)Session["dt_Children"];
                DataRow dr = dt.NewRow();
                TextBox txtChildren_Name = gv.FooterRow.FindControl("txtNewChildren_Name") as TextBox;//gv.Controls[0].Controls[0].FindControl("txtNewChildren_Name") as TextBox;
                TextBox txtAge = gv.FooterRow.FindControl("txtNewAge") as TextBox;
                dr["Children_ID"] = "-1";
                dr["Children_Name"] = txtChildren_Name.Text;
                dr["Age"] = txtAge.Text;
                dt.Rows.Add(dr);
                gv.DataSource = dt;
                gv.DataBind();
                Session["dt_Children"] = dt;
            }

        }

        protected void btnChildren_Save_Click(object sender, EventArgs e)
        {
            DataTable dt = new DataTable();
            dt = (DataTable)Session["dt_Children"];
            DataRow dr = dt.NewRow();
            TextBox txtChildren_Name = gv.Controls[0].Controls[0].FindControl("txtNewChildren_Name") as TextBox;
            TextBox txtAge = gv.Controls[0].Controls[0].FindControl("txtNewAge") as TextBox;
            dr["Children_ID"] = "-1";
            dr["Children_Name"] = txtChildren_Name.Text;
            dr["Age"] = txtAge.Text;
            dt.Rows.Add(dr);
            gv.DataSource = dt;
            gv.DataBind();
            Session["dt_Children"] = dt;
        }

        protected void gv_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gv.ShowFooter = false;
            gv.EditIndex = e.NewEditIndex;
            e.Cancel = true;
            refreshgrid();
        }
        private void refreshgrid()
        {
            DataTable dt = Session["dt_Children"] as DataTable;
            gv.DataSource = dt;
            gv.DataBind();
            Session["dt_Children"] = dt;
        }

        protected void gv_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gv.EditIndex = -1;
            e.Cancel = true;
            refreshgrid();
        }

        protected void gv_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {            
            //Page.Title = "Row updating event";
            GridViewRow row = (GridViewRow)gv.Rows[e.RowIndex];
            ////string Children_Name = Convert.ToString(e.NewValues["Children_Name"]);
            TextBox Child = row.FindControl("txtChildren_Name") as TextBox; //gv.Controls[0].Controls[0].FindControl("txtChildren_Name") as TextBox;            
            //string Age = Convert.ToString(e.NewValues["Age"]);
            //DataTable dt = Session["dt_Children"] as DataTable;
            //dt.Rows[e.RowIndex]["Children_Name"] = Child.Text;
            //dt.Rows[e.RowIndex]["Age"] = Age;
            //dt.AcceptChanges();
            //gv.EditIndex = -1;
            //e.Cancel = true;
            //gv.DataSource = dt;
            //gv.DataBind();
            //Session["dt_Children"] = dt;
            Page.Title = Child.Text;
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            gv.EditIndex = -1;
            gv.ShowFooter = true;
            refreshgrid();
        }
    }
}