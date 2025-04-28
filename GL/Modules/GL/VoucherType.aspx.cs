using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace PMS.GL
{
    public partial class VoucherType : System.Web.UI.Page
    {
        
        DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
        protected void Page_Load(object sender, EventArgs e)
        {
          
            if (!IsPostBack)
            {
                BindGrid();
            }
        }

        private void BindGrid()
        {
            string cmd = "Select * from [GL_Voucher_Types]";
            DataTable dt = DBClass.getDataTable(cmd);
            
            gvVouchertype.DataSource = dt;
            gvVouchertype.DataBind();
            Session["VoucherType"] = dt;
        }
        private void refreshGrid()
        {
            DataTable dt = Session["VoucherType"] as DataTable;
            gvVouchertype.DataSource = dt;
            gvVouchertype.DataBind();
        }
        protected void gvVouchertype_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvVouchertype.ShowFooter = false;
            gvVouchertype.EditIndex = e.NewEditIndex;
            lblMessage.Text = "";
            e.Cancel = true;
            refreshGrid();
        }

        protected void gvVouchertype_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            string id = ((Label)gvVouchertype.Rows[e.RowIndex].FindControl("lblVouchertypeId")).Text;
            string voctype = Convert.ToString(e.NewValues["Voucher_Type"]);
            string description = Convert.ToString(e.NewValues["Description"]);
            var qry = from voc in db.GL_Voucher_Types
                     // where voc.Voucher_Type_Id == Convert.ToInt32(id)
                      select voc;
            foreach (var item in qry)
            {
                item.Voucher_Type = voctype;
               // item.Description = description;
                db.SubmitChanges();
            }
            gvVouchertype.EditIndex = -1;
            e.Cancel = true;
            BindGrid();
        }

        protected void gvVouchertype_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvVouchertype.EditIndex = -1;
            e.Cancel = true;
            refreshGrid();
        }

        protected void gvVouchertype_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            gvVouchertype.EditIndex = -1;
            string id = ((Label)gvVouchertype.Rows[e.RowIndex].FindControl("lblVouchertypeId")).Text;
            var qry = from voc in db.GL_Voucher_Types
                    //  where voc.Voucher_Type_Id == Convert.ToInt32(id)
                      select voc;
            foreach (var item in qry)
            {
                db.GL_Voucher_Types.DeleteOnSubmit(item);
                db.SubmitChanges();
            }
            lblMessage.Text = "";
            gvVouchertype.ShowFooter = false;
            BindGrid();
            e.Cancel = true;
        }

        protected void gvVouchertype_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName.Equals("addnew"))
            {
                gvVouchertype.EditIndex = -1;
                TextBox txt_Voucher_type = gvVouchertype.FooterRow.FindControl("txtVouchertype") as TextBox;
                TextBox txt_Description = gvVouchertype.FooterRow.FindControl("txtDescription") as TextBox;
                if (txt_Voucher_type.Text != "" && txt_Description.Text != "")
                {
                    string Voucher_Type = txt_Voucher_type.Text;
                    string Description = txt_Description.Text;
                    GL_Voucher_Type vt = new GL_Voucher_Type();
                    vt.Voucher_Type = Voucher_Type;
                 //  vt.Description = Description;
                    db.GL_Voucher_Types.InsertOnSubmit(vt);
                    db.SubmitChanges();
                    lblMessage.Text = "";
                    gvVouchertype.ShowFooter = false;
                    BindGrid();
                }
                else
                {
                    lblMessage.Text = "Voucher Type and Description are required...!";
                }
            }
            else if (e.CommandName.Equals("emptyaddnew"))
            {
                TextBox txt_Voucher_type = gvVouchertype.Controls[0].Controls[0].FindControl("txtVouchertype") as TextBox;
                TextBox txt_Description = gvVouchertype.Controls[0].Controls[0].FindControl("txtDescription") as TextBox;
                if (txt_Voucher_type.Text != "" && txt_Description.Text != "")
                {
                    string Voucher_Type = txt_Voucher_type.Text;
                    string Description = txt_Description.Text;
                    GL_Voucher_Type vt = new GL_Voucher_Type();
                    vt.Voucher_Type = Voucher_Type;
                  //  vt.Description = Description;
                    db.GL_Voucher_Types.InsertOnSubmit(vt);
                    db.SubmitChanges();
                    BindGrid();
                    lblMessage.Text = "";
                }
                else
                {
                    lblMessage.Text = "Voucher Type and Description are required...!";
                }
            }
            else if (e.CommandName.Equals("addnewcancel"))
            {
                gvVouchertype.ShowFooter = false;
                lblMessage.Text = "";
                refreshGrid();
            }
        }

        protected void btnAddnew_Click(object sender, EventArgs e)
        {
            gvVouchertype.EditIndex = -1;
            gvVouchertype.ShowFooter = true;
            refreshGrid();
        }
    }
}