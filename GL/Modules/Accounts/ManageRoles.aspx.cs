using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Account
{
    public partial class ManageRoles : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindLists();
                rfvCompany.Enabled = false;
                if (Request.QueryString["UserID"] != null)
                {
                    FillUserRoles(Request.QueryString["UserID"]);
                }
            }
        }

        private void BindLists()
        {
            //MembershipUserCollection users = Membership.GetAllUsers();
            //ddlUsers.DataSource = users;
            DataTable dtUser = DBClass.getDataTable("select UserId,UserName from aspnet_Users");
            ddlUsers.DataSource = dtUser;
            ddlUsers.DataTextField = "UserName";
            ddlUsers.DataValueField = "UserID";
            ddlUsers.Items.Add(new ListItem("Please Select", "0"));
            ddlUsers.DataBind();

            //DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            //var qry = from p in db.aspnet_Roles
            //          select p;
            DataTable dtRoles = new DataTable();
            dtRoles = DBClass.getDataTable("SELECT [RoleId] ,[LoweredRoleName] as RoleName FROM [aspnet_Roles] order by LoweredRoleName ");
            // string[] roles = System.Web.Security.Roles.GetAllRoles();
            // cbRolesList.DataSource = roles;
            cbRolesList.DataSource = dtRoles;
            cbRolesList.DataTextField = "RoleName";
            cbRolesList.DataValueField = "RoleId";
            cbRolesList.DataBind();

            DataTable dtbCompanies = new DataTable();
            dtbCompanies = DBClass.getDataTable("Select * from sys_Companys");
            ddlCompany.DataSource = dtbCompanies;
            ddlCompany.DataTextField = "Company_Name";
            ddlCompany.DataValueField = "Company_ID";
            ddlCompany.Items.Add(new ListItem("ALL", "0"));
            ddlCompany.DataBind();

        }

        private void FillUserRoles(string UserID)
        {
            try
            {
                Guid userid = new Guid(UserID);
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                aspnet_UsersInRole userinRoles = new aspnet_UsersInRole();

                var qry = (from u in db.aspnet_Users
                           where u.UserId == userid
                           select u.UserName).FirstOrDefault();
                if (qry != null)
                {
                    string UserName = qry;
                    ViewState["UserName"] = UserName;
                    //if (ddlUsers.Items.FindByText(UserName) != null)
                    ddlUsers.SelectedValue = UserID;
                    var UserRoles = System.Web.Security.Roles.GetRolesForUser(UserName);
                    foreach (var item in UserRoles)
                    {
                        foreach (ListItem chRole in cbRolesList.Items)
                        {
                            if (chRole.Text == item.ToLower())
                                chRole.Selected = true;
                        }
                    }
                    userinRoles = (from u in db.aspnet_UsersInRoles
                                   where u.UserId == userid
                                   select u).FirstOrDefault();
                    if (userinRoles != null)
                    {
                        if (userinRoles.AllCompany != null && userinRoles.AllCompany == true)
                        {
                            cbAllCompany.Checked = true;
                            ddlCompany.SelectedValue = "0";
                            ddlCompany.Enabled = false;
                            rfvCompany.Enabled = true;
                        }
                        else
                        {
                            cbAllCompany.Checked = false;
                            rfvCompany.Enabled = true;
                            ddlCompany.Enabled = true;
                            if (ddlCompany.Items.FindByValue(Convert.ToString(userinRoles.Company_ID)) != null)
                                ddlCompany.SelectedValue = Convert.ToString(userinRoles.Company_ID);
                        }
                    }
                    cbAllCompany_CheckedChanged(cbAllCompany, null);
                    btnSave.Text = "Update";
                    ddlUsers.Enabled = false;
                    upForm.Update();
                }
            }
            catch (Exception ex)
            {

                throw;
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            string sqlQuery = "";
            try
            {
                if (btnSave.Text == "Update" && ViewState["UserName"] != null)
                {
                    //  Guid userid = new Guid(Request.QueryString["UserID"]);
                    //DBClass.deleteRecord("Delete aspnet_usersinroles where UserID='" + userid + "'");
                    string UserName = ViewState["UserName"].ToString();
                    string[] UserRoles = System.Web.Security.Roles.GetRolesForUser(UserName);
                    if (UserRoles.Count() > 0)
                        System.Web.Security.Roles.RemoveUserFromRoles(UserName, UserRoles);
                    foreach (ListItem chRole in cbRolesList.Items)
                    {
                        if (chRole.Selected)
                        {
                            //System.Web.Security.Roles.AddUserToRole(UserName, chRole.Value);
                            if (cbAllCompany.Checked)
                                sqlQuery += "INSERT INTO [aspnet_UsersInRoles]([UserId],[RoleId] ,[AllCompany],[Company_ID])  VALUES('" + ddlUsers.Items.FindByText(UserName).Value + "','" + chRole.Value + "',1,0) ;";
                            else
                                sqlQuery += "INSERT INTO [aspnet_UsersInRoles]([UserId],[RoleId] ,[AllCompany],[Company_ID])  VALUES('" + ddlUsers.Items.FindByText(UserName).Value + "','" + chRole.Value + "',0," + ddlCompany.SelectedValue + ") ;";
                        }
                    }

                }
                else
                {

                    foreach (ListItem chRole in cbRolesList.Items)
                    {
                        if (chRole.Selected)
                        {
                            if (System.Web.Security.Roles.IsUserInRole(ddlUsers.SelectedValue, chRole.Value))
                            {
                                lblMessage.Text = "User already assigned with roles.";
                                return;
                            }
                        }
                    }
                    foreach (ListItem chRole in cbRolesList.Items)
                    {
                        if (chRole.Selected)
                        {
                            //System.Web.Security.Roles.AddUserToRole(ddlUsers.SelectedValue, chRole.Value);
                            if (cbAllCompany.Checked)
                                sqlQuery += "INSERT INTO [aspnet_UsersInRoles]([UserId],[RoleId] ,[AllCompany],[Company_ID])  VALUES('" + ddlUsers.SelectedValue + "','" + chRole.Value + "',1,0) ;";
                            else
                                sqlQuery += "INSERT INTO [aspnet_UsersInRoles]([UserId],[RoleId] ,[AllCompany],[Company_ID])  VALUES('" + ddlUsers.SelectedValue + "','" + chRole.Value + "',0," + ddlCompany.SelectedValue + ") ;";

                        }
                    }
                }
                if (sqlQuery != "")
                    DBClass.exectueQuery(sqlQuery, tranObj, con);
                tranObj.Commit();
                Response.Redirect("~/Modules/Accounts/RoleAssignment.aspx", false);
            }
            catch (Exception ex)
            {
                if (tranObj != null)
                    tranObj.Rollback();
                lblMessage.Text = ex.Message;
            }
            finally
            {
                con.Close();
            }
        }

        protected void cbAllCompany_CheckedChanged(object sender, EventArgs e)
        {
            if (cbAllCompany.Checked)
            {
                ddlCompany.Enabled = false;
                rfvCompany.Enabled = false;
            }
            else
            {
                ddlCompany.Enabled = true;
                rfvCompany.Enabled = true;
            }
        }
    }
}