using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Security;
using System.Data.SqlClient;

namespace PMS.Account
{
    public partial class UserRolesView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                lblMessage.Text = "";
                fillGridView();
            }

        }

        private void fillGridView()
        {
            DataTable dt = DBClass.getDataTable("select users.userid,users.username,members.Email,members.RoleId,aspnet_Roles.RoleName from aspnet_Users users, aspnet_Membership members " +
                                    "left outer join aspnet_Roles " +
                                    "on aspnet_Roles.roleid=members.roleid " +
                                    "where users.userid=members.userid");
            gvRoles.DataSource = dt;
            gvRoles.DataBind();
            gvRoles.Columns[1].Visible = false;
        }

        protected void gvRoles_RowEditing(object sender, GridViewEditEventArgs e)
        {
            //gvRoles.ShowFooter = false;            
            gvRoles.EditIndex = e.NewEditIndex;
            fillGridView();
        }

        protected void gvRoles_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            lblMessage.Text = "";
            try
            {
                if (e.Row.RowType == DataControlRowType.DataRow)
                {
                    Label lblUserName = (Label)e.Row.FindControl("lblUserName");
                    Label lblRole = (Label)e.Row.FindControl("lblRole");
                    if (lblUserName != null && lblRole != null)
                    {
                        string[] roles = System.Web.Security.Roles.GetRolesForUser(lblUserName.Text);
                        foreach (string role in roles)
                        {
                            if (lblRole.Text != "")
                                lblRole.Text += ", ";
                            lblRole.Text += role;
                        }
                    }
                    HyperLink hlEdit = (HyperLink)e.Row.FindControl("hlEdit");
                    LinkButton lbtnRemoveRoles = (LinkButton)e.Row.FindControl("lbtnRemoveRoles");
                    if (lblRole != null && lblRole.Text == "")
                    {
                        lbtnRemoveRoles.Visible = false;
                        //    hlEdit.NavigateUrl = "~/Account/ManageRoles.aspx";
                        hlEdit.Text = "Add Role";
                        hlEdit.ToolTip = "Add Role";
                    }
                }
            }
            catch (Exception exc)
            {
                lblMessage.Text = exc.Message;
            }
        }

        protected void lblUpdate_Click(object sender, EventArgs e)
        {

        }

        protected void gvRoles_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            try
            {
                lblMessage.Text = "";
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                DropDownList ddlRoles;
                Label lbluser;
                ddlRoles = gvRoles.Rows[e.RowIndex].FindControl("ddlRole") as DropDownList;
                lbluser = gvRoles.Rows[e.RowIndex].FindControl("lblUserName") as Label;
                //Guid userId = new Guid(lbluser.Text);
                //Guid RoleId = new Guid(ddlRoles.SelectedValue);
                /*
                aspnet_Membership member = (from m in db.aspnet_Memberships
                                            where m.UserId == userId
                                            select m).FirstOrDefault();
                //member.RoleId = RoleId;
                db.SubmitChanges();
                 * */

                System.Web.Security.Roles.AddUserToRole(lbluser.Text, ddlRoles.SelectedItem.Text);

                gvRoles.EditIndex = -1;
                fillGridView();
            }
            catch (Exception exc)
            {
                lblMessage.Text = exc.Message;
            }
        }

        protected void gvRoles_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvRoles.EditIndex = -1;
            fillGridView();
        }

        protected void gvRoles_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Remove")
            {
                SqlTransaction tranObj = null;
                SqlConnection con = new SqlConnection(DBClass.ConnectionString());
                con.Open();
                tranObj = con.BeginTransaction();
                try
                {
                    Guid userid = new Guid(e.CommandArgument.ToString());
                    bool result = DBClass.exectueQuery("Delete aspnet_usersinroles where UserID='" + userid + "'", tranObj, con);
                    lblMessage.Text = "Record has been deleted successfully.";
                    tranObj.Commit();
                    fillGridView();
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
    }
}