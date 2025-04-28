using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Configuration;
using System.Data.SqlClient;

namespace PMS
{
    public partial class InventoryOrgs : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
            }

        }
        protected void btnSave_Click(object sender, EventArgs e)
        {

            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Item_Org item = new Item_Org();
            

                var snumber = Convert.ToInt32(DBClass.getField("select (isnull(max(convert(int,Org_Code)),0)+1) from Item_Org ").ToString());

                item.Org_Code = snumber.ToString();

            if (txtOrg_Name.Text != "")
                item.Org_Name = txtOrg_Name.Text; 
            

                db.Item_Orgs.InsertOnSubmit(item);
                 db.SubmitChanges();
              lblMessage.Text = "Data has been save successfully";
            lblMessage.CssClass = "sucessfullMessage";
            Response.Redirect("~/Inventory/InventoryOrgs.aspx.", true);

        }
    }
}