using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class Menu : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindParentMenu();
                Cleartxt();
                if (Request.QueryString["ID"] != null)
                {
                    PopulateMenuData(Convert.ToInt32(Request.QueryString["ID"]));
                }
            }
        }

        private void BindParentMenu()
        {
            DataTable dt = new DataTable();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var menu = from tbl in db.Menus
                       select new
                       {
                           ParentID = tbl.Menu_ID,
                           ParentName = tbl.Menu_Description,
                       };

            ddlParent_Menu.DataSource = menu;
            ddlParent_Menu.DataTextField = "ParentName";
            ddlParent_Menu.DataValueField = "ParentID";
            ddlParent_Menu.Items.Add(new ListItem("Please Select", "0"));
            ddlParent_Menu.DataBind();
            ddlParent_Menu.Items.Insert(0, new ListItem("Please Select", "0"));
        }

        public void Cleartxt()
        {
            txtMenu_Name.Text = string.Empty;
            txtMenu_Discription.Text = string.Empty;
            txtMenu_Url.Text = string.Empty;
            txtOrder_By.Text = string.Empty;
            cbActive.Checked = true;
            ddlParent_Menu.SelectedValue = "0";
        }

        private void PopulateMenuData(int Menu_ID)
        {
            DataTable dt = new DataTable();
            string qury = "select * from Menus where Menu_ID = " + Menu_ID;
            dt = DBClass.getDataTable(qury);

            txtMenu_Name.Text = dt.Rows[0]["Menu_Name"].ToString();
            txtMenu_Discription.Text = dt.Rows[0]["Menu_Description"].ToString();
            txtMenu_Url.Text = dt.Rows[0]["URL"].ToString();
            ddlParent_Menu.SelectedValue = dt.Rows[0]["Parent_ID"].ToString();
            txtOrder_By.Text = dt.Rows[0]["Order_By"].ToString();
            cbActive.Checked = Convert.ToBoolean(dt.Rows[0]["IsActive"]);
            btnSave.Text = "Update";
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;

            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                Menus menu;

                if (btnSave.Text == "Save")
                {
                    menu = new Menus();
                }
                else
                {
                    menu = (from tbl in db.Menus
                            where tbl.Menu_ID == Convert.ToInt32(Request.QueryString["ID"])
                            select tbl).FirstOrDefault();
                }

                menu.Menu_Name = txtMenu_Name.Text;
                menu.Menu_Description = txtMenu_Discription.Text;
                menu.URL = txtMenu_Url.Text;
                menu.Parent_ID = Convert.ToInt32(ddlParent_Menu.SelectedValue);
                menu.Order_By = Convert.ToInt32(txtOrder_By.Text);
                if (cbActive.Checked)
                    menu.IsActive = true;
                else
                    menu.IsActive = false;

                if (btnSave.Text == "Save")
                {
                    db.Menus.InsertOnSubmit(menu);
                    lblMessage.CssClass = "Menu Added Successfully";
                }
                else
                {
                    lblMessage.CssClass = "menu Updated Successfully";
                }
                db.SubmitChanges();

                Response.Redirect("~/Modules/Administrator/MenuView.aspx", false);

            }
            catch (Exception exc)
            {
                lblMessage.CssClass = "errorMessage";
                lblMessage.Text = exc.Message;
            }
        }
    }
}