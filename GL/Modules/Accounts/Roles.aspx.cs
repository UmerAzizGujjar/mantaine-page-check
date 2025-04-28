using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Web.Services;
using System.Web.Script.Serialization;

namespace PMS.Account
{
    public partial class Roles : System.Web.UI.Page
    {
        DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                BindDropDowns();
                if (!Page.IsPostBack)
                {
                    tvMenus.Attributes.Add("onclick", "OnTreeClick(event)");
                    if (Request.QueryString["RoleId"] != null)
                        fill(Request.QueryString["RoleId"], "aspnet_roles");
                    loadMenus();
                }
            }
            catch (Exception exc)
            {
                lblMessage.Text = exc.Message;
                lblMessage.CssClass = "errorMessage";
            }
        }

        public void BindDropDowns()
        {
            object valueset;
            valueset = DBClass.GetValueSet("Patient Main Category");
            ddlDepartment.DataSource = valueset;
            ddlDepartment.DataTextField = "DataValue_Description";
            ddlDepartment.DataValueField = "DataValue_Name";
            ddlDepartment.Items.Add(new ListItem("Please Select", "0"));
            ddlDepartment.Items.Add(new ListItem("All Departments", "All_Departments"));
            ddlDepartment.DataBind();
        }

        private void loadMenus()
        {
            tvMenus.Nodes.Clear();

            var qry = from mnu in db.Menus
                      where mnu.Parent_ID == 0
                      orderby mnu.Order_By
                      select mnu;
            foreach (var item in qry)
            {
                TreeNode tn = new TreeNode(item.Menu_Description, item.Menu_ID.ToString());
                tn.SelectAction = TreeNodeSelectAction.Select;
                tn.Checked = false;
                if (txtRoleId.Text != "(New)")
                {
                    Guid RoleId = new Guid(txtRoleId.Text);
                    var qryAccess = from acc in db.aspnet_RolesInMenus
                                    where acc.Menu_Id == item.Menu_ID && acc.RoleId == RoleId
                                    select acc;
                    foreach (var itemAccess in qryAccess)
                        tn.Checked = itemAccess.Access.Value;
                }
                tvMenus.Nodes.Add(tn);
                addMenuLevel(tn, item.Menu_ID);
            }
        }
        private void addMenuLevel(TreeNode parentTn, int parentId)
        {

            var qry = from mnu in db.Menus
                      where mnu.Parent_ID == parentId
                      orderby mnu.Order_By
                      select mnu;
            foreach (var item in qry)
            {
                TreeNode tn = new TreeNode(item.Menu_Description, item.Menu_ID.ToString());
                tn.SelectAction = TreeNodeSelectAction.Select;
                tn.Checked = false;
                if (txtRoleId.Text != "(New)")
                {
                    Guid RoleId = new Guid(txtRoleId.Text);
                    var qryAccess = from acc in db.aspnet_RolesInMenus
                                    where acc.Menu_Id == item.Menu_ID && acc.RoleId == RoleId
                                    select acc;
                    foreach (var itemAccess in qryAccess)
                        tn.Checked = itemAccess.Access.Value;
                }
                parentTn.ChildNodes.Add(tn);
                addMenuLevel(tn, item.Menu_ID);
            }
        }

        protected void tvMenus_TreeNodeCheckChanged(object sender, TreeNodeEventArgs e)
        {
            Page.Title = e.Node.Text;

            foreach (TreeNode item in e.Node.ChildNodes)
            {
                item.Checked = e.Node.Checked;
            }
        }

        protected void tvMenus_SelectedNodeChanged(object sender, EventArgs e)
        {
            //Page.Title = "Selected node change";
        }
        public void RenameRoleAndUsers(string OldRoleName, string NewRoleName,string RoleId)
        {
            string[] users = System.Web.Security.Roles.GetUsersInRole(OldRoleName);
            if (users.Count() > 0)
            {
                Guid RoleIdGuid = new Guid(RoleId);
                string str = "select * from aspnet_UsersInRoles where RoleId='" + RoleIdGuid + "'";
                DataTable dt = DBClass.getDataTable(str);

                System.Web.Security.Roles.RemoveUsersFromRole(users, OldRoleName);
                System.Web.Security.Roles.DeleteRole(OldRoleName);
                System.Web.Security.Roles.CreateRole(NewRoleName);
                System.Web.Security.Roles.AddUsersToRole(users, NewRoleName);
               
                foreach (DataRow dr in dt.Rows)
                {
                    var usr = from q in db.aspnet_UsersInRoles
                              where q.UserId == new Guid(dr["UserId"].ToString())
                              select q;
                    foreach (var u in usr)
                    {
                        u.AllCompany = Convert.ToBoolean(dr["AllCompany"]);
                        u.Company_ID = Convert.ToInt32(dr["Company_ID"]);
                       
                    }
                    
                    db.SubmitChanges();
                }
            }
            else
            {
                System.Web.Security.Roles.DeleteRole(OldRoleName);
                System.Web.Security.Roles.CreateRole(NewRoleName);
            }
        }
        protected void btnSave_Click(object sender, EventArgs e)
        {
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            db.Connection.Open();
            db.Transaction = db.Connection.BeginTransaction();
            tranObj = con.BeginTransaction();
            try
            {
                Guid ui = Guid.NewGuid();
                aspnet_Role rol;
                lblMessage.Text = "";
                if (hdfOldRoleName.Value != "")
                {
                    RenameRoleAndUsers(hdfOldRoleName.Value, txtRoleName.Text, txtRoleId.Text);
                }
                else
                    System.Web.Security.Roles.CreateRole(txtRoleName.Text);


                rol = (from r in db.aspnet_Roles
                       where r.RoleName == txtRoleName.Text
                       select r).FirstOrDefault();

                rol.Department_ID = ddlDepartment.SelectedValue.ToString();
                rol.iscancel = false;
              //  rol.Test_Rates = chkTestRate.Checked;
                db.SubmitChanges();
               
                if (Request.QueryString["RoleId"] != null)
                {
                    DBClass.exectueQueryWithTransaction("Delete aspnet_RolesInMenus where roleID='" + Request.QueryString["RoleId"] + "'", tranObj, con);

                }
                List<aspnet_RolesInMenus> menulist = new List<aspnet_RolesInMenus>();

                foreach (TreeNode rootNode in tvMenus.Nodes)
                {
                    if (rootNode.Checked)
                    {
                        Guid RoleMenuid = Guid.NewGuid();
                        aspnet_RolesInMenus rolMenus = new aspnet_RolesInMenus();
                        rolMenus.RoleId = rol.RoleId;
                        rolMenus.RoleMenuId = RoleMenuid;
                        rolMenus.Menu_Id = Convert.ToInt32(rootNode.Value);
                        rolMenus.Access = rootNode.Checked;
                        menulist.Add(rolMenus);
                        ParseNode(rootNode, rol.RoleId);
                    }
                    else
                        ParseNode(rootNode, rol.RoleId);
                }
                if (menulist != null && menulist.Count > 0)
                {
                    db.aspnet_RolesInMenus.InsertAllOnSubmit(menulist);
                    db.SubmitChanges();
                }

                lblMessage.CssClass = "sucessfullMessage";
                lblMessage.Text = "Data has been sucessfully save";
                tranObj.Commit();
                db.Transaction.Commit();
                Response.Redirect("~/Modules/Accounts/RolesView.aspx",false);
            }
            catch (Exception exc)
            {
                if (tranObj != null)
                    tranObj.Rollback();
                lblMessage.CssClass = "errorMessage";
                lblMessage.Text = exc.Message;
            }
            finally
            {
                con.Close();
                db.Connection.Close();
            }
           
        }
        private void ParseNode(TreeNode node, Guid RoleId)
        {
            foreach (TreeNode child in node.ChildNodes)
            {
                if (child.Checked)
                {
                    Guid RoleMenuid = Guid.NewGuid();
                    aspnet_RolesInMenus rolMenus = new aspnet_RolesInMenus();
                    rolMenus.RoleId = RoleId;

                    rolMenus.Menu_Id = Convert.ToInt32(child.Value);//Convert.ToInt32(node.Value);
                    rolMenus.Access = child.Checked;
                    rolMenus.RoleMenuId = RoleMenuid;
                    db.aspnet_RolesInMenus.InsertOnSubmit(rolMenus);
                    db.SubmitChanges();
                    ParseNode(child, RoleId);
                }
            }
          

        }
      

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            
        }
        public void fill(string id, string tblname)
        {
            try
            {

                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                if (tblname == "aspnet_roles")
                {
                  
                    Guid roleId = new Guid(id);
                    var qry = (from p in db.aspnet_Roles
                               where p.RoleId == roleId
                               select p).FirstOrDefault();

                    txtRoleId.Text = qry.RoleId.ToString();
                    txtRoleName.Text = qry.RoleName;
                    ddlDepartment.SelectedValue = qry.Department_ID;
          
                    hdfOldRoleName.Value = qry.RoleName;

                }

            }
            catch (Exception ex)
            {

                lblMessage.Text = ex.Message;
                lblMessage.CssClass = "errorMessage";
            }
        }

        protected void btnNew_Click(object sender, EventArgs e)
        {
            ddlDepartment.SelectedIndex = 0;
            txtRoleId.Text = "(New)";
            txtRoleName.Text = "";
        }        
    }
}