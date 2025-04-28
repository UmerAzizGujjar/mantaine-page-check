using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.GL
{
    public partial class PostVouchers : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            
            if (!Page.IsPostBack)
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                var qry = from tbl in db.GL_Vouchers
                          where tbl.Voucher_Status == "Created" && tbl.Company_ID == AppConfig.Company_ID
                          orderby tbl.Voucher_Type
                          select new { tbl.Voucher_ID, tbl.Voucher_No, tbl.Voucher_Type, tbl.Voucher_Date, tbl.Remarks };
                GridView1.DataSource = qry;
                GridView1.DataBind();
            }
        }

        protected void btnApprove_Click(object sender, EventArgs e)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            foreach (GridViewRow row in GridView1.Rows)
            {
                CheckBox chk = row.FindControl("chkSelect") as CheckBox;
                Label voucher_id = row.FindControl("lblVoucher_ID") as Label;
                if (chk.Checked)
                {
                    GL_Voucher voucher = (from tbl in db.GL_Vouchers
                                          where tbl.Voucher_ID == Convert.ToInt32(voucher_id.Text)
                                          select tbl).SingleOrDefault();
                    voucher.Voucher_Status = "Approved";
                    voucher.Approved_Time = DateTime.Now;
                    voucher.Approved_By = AppConfig.UserID;
                    db.SubmitChanges();
                }
            }
            Response.Redirect(Request.RawUrl);
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            foreach (GridViewRow row in GridView1.Rows)
            {
                CheckBox chk = row.FindControl("chkSelect") as CheckBox;
                Label voucher_id = row.FindControl("lblVoucher_ID") as Label;
                if (chk.Checked)
                {
                    GL_Voucher voucher = (from tbl in db.GL_Vouchers
                                          where tbl.Voucher_ID == Convert.ToInt32(voucher_id.Text)
                                          select tbl).SingleOrDefault();
                    voucher.Voucher_Status = "Cancalled";
                    voucher.Approved_Time = DateTime.Now;
                    voucher.Approved_By = AppConfig.UserID;
                    db.SubmitChanges();
                }
            }
            Response.Redirect(Request.RawUrl);
        }
    }
}