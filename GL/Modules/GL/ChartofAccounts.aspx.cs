using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web.UI;
using System.Drawing;
using System.Data.SqlClient;
using System.Configuration;
using PMS;
namespace Salon.GL
{
    public partial class ChartofAccounts : System.Web.UI.Page
    {
        string connectionString = ConfigurationManager.ConnectionStrings["ASPGLConnectionString"].ConnectionString;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserName"] == null || Session["Company_Name"] == null || Session["Company_ID"] == null || Session["Book_ID"] == null)
            {
                Session.Abandon();
                Response.Redirect("~/Account/Login.aspx", true);
            }
            if (!IsPostBack)
            {
                if (Session["Book_ID"] != null)
                {
                    btnAdd.Enabled = false;
                    btnAddChild.Enabled = false;
                    btnDelete.Enabled = false;
                    btnEditSave.Enabled = false;
                    btnAdd.CssClass = "buttonDisabled";
                    btnAddChild.CssClass = "buttonDisabled";
                    btnDelete.CssClass = "buttonDisabled";
                    btnEditSave.CssClass = "buttonDisabled";
                    DataBaseDataContext db = new DataBaseDataContext(connectionString);
                    RadTreeView1.Nodes.Clear();
                    var qry = from coa in db.GL_Accounts
                              where coa.Levels == 1 && coa.Book_ID == AppConfig.Book_ID
                              orderby coa.Account_Code
                              select coa;
                    foreach (var item in qry)
                    {
                        RadTreeNode tn = new RadTreeNode(item.Account_Code + " - " + item.Account_Name, item.Account_ID.ToString());
                        tn.ExpandMode = TreeNodeExpandMode.ServerSideCallBack;
                        RadTreeView1.Nodes.Add(tn);
                    }
                }
            }
        }
        private void loadChartofAccount(int Book_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext(connectionString);
            RadTreeView1.Nodes.Clear();
            var qry = from coa in db.GL_Accounts
                      where coa.Levels == 1 && coa.Book_ID == Book_ID
                      orderby coa.Account_Code
                      select coa;
            foreach (var item in qry)
            {
                RadTreeNode tn = new RadTreeNode(item.Account_Code + " - " + item.Account_Name, item.Account_ID.ToString());
                tn.ExpandMode = TreeNodeExpandMode.ServerSideCallBack;
                RadTreeView1.Nodes.Add(tn);
                addChildNodesLevel(tn, item.Account_ID);
            }

        }
        private void addChildNodesLevel(RadTreeNode parentTn, int parentId)
        {
            DataBaseDataContext db = new DataBaseDataContext(connectionString);
            var qry = from coa in db.GL_Accounts
                      where coa.Parent_Code == parentId && coa.Levels > 1 && coa.Levels != 4
                      orderby coa.Account_Code
                      select coa;
            foreach (var item in qry)
            {
                RadTreeNode tn = new RadTreeNode(item.Account_Code + " - " + item.Account_Name, item.Account_ID.ToString());
                tn.ExpandMode = TreeNodeExpandMode.ServerSideCallBack;
                parentTn.Nodes.Add(tn);
               addChildNodesLevel(tn, item.Account_ID);
            }
            db.Dispose();
        }        
        protected void btnaddSave_Click(object sender, EventArgs e)
        {
        }
        protected void btnaddCancel_Click(object sender, EventArgs e)
        {
        }
        protected void btnEditSave_Click(object sender, EventArgs e)
        {
            try
            {
                lblMessage.Text = "";
                int accountId = Convert.ToInt32(RadTreeView1.SelectedNode.Value);
                DataBaseDataContext db = new DataBaseDataContext(connectionString);
                if (hdnAddOrEdit.Value == "Edit")
                {
                    RadTreeNode tn = RadTreeView1.SelectedNode;
                    var qry = (from acc in db.GL_Accounts
                               where acc.Account_ID == accountId
                               select acc);
                    foreach (var item in qry)
                    {
                        item.Account_Name = txtAccount_Name.Text;
                        item.Bank = rbtnBank.Checked;
                        item.Cash = rbtnCash.Checked;
                        item.Updated_Time = DateTime.Now;
                    }
                    db.SubmitChanges();
                    tn.Text = txtParent_Code.Text + "" + txtAccount_Code.Text + " - " + txtAccount_Name.Text;
                    tn.Value = accountId.ToString();
                }
                else if (hdnAddOrEdit.Value == "Add" || hdnAddOrEdit.Value == "Add Child")
                {
                    string accountCode = txtParent_Code.Text + "" + txtAccount_Code.Text;
                    int rec = (from acc in db.GL_Accounts
                               where ((acc.Account_Code == accountCode)&&(acc.Book_ID == AppConfig.Book_ID))
                               select acc).Count();
                    if (rec != 0)
                    {
                        lblMessage.Text = "Account code already exist!";
                        return;
                    }
                    else
                    {
                        GL_Account acc = new GL_Account();
                        acc.Account_Code = accountCode;
                        acc.Parent_Code = Convert.ToInt32(hdnParentId.Value);
                        acc.Levels = Convert.ToInt32(hdnLevel.Value);
                        acc.Account_Serial = txtAccount_Code.Text;
                        acc.Account_Name = txtAccount_Name.Text;
                        acc.Book_ID = AppConfig.Book_ID;
                        acc.Bank = rbtnBank.Checked;
                        acc.Cash = rbtnCash.Checked;
                        acc.Active = true;
                        acc.Created_Time = DateTime.Now;
                        db.GL_Accounts.InsertOnSubmit(acc);
                        db.SubmitChanges();
                        if (hdnAddOrEdit.Value == "Add")
                        {
                            RadTreeNode parentnode = RadTreeView1.SelectedNode.ParentNode;
                            RadTreeNode tn = new RadTreeNode();
                            tn.Text = accountCode + " - " + txtAccount_Name.Text;
                            tn.Value = acc.Account_ID.ToString();
                            parentnode.Nodes.Add(tn);
                            hdnAddOrEdit.Value = "Edit";
                        }
                        else if (hdnAddOrEdit.Value == "Add Child")
                        {
                            RadTreeNode parentnode = RadTreeView1.SelectedNode;
                            RadTreeNode tn = new RadTreeNode();
                            tn.Text = accountCode + " - " + txtAccount_Name.Text;
                            tn.Value = acc.Account_ID.ToString();
                            parentnode.Nodes.Add(tn);
                            hdnAddOrEdit.Value = "Edit";
                        }
                        Cleartxt();
                    }
                }
                btnEditSave.Text = "Update";
            }
            catch (Exception exc)
            {
                lblMessage.Text = exc.Message;
            }
        }
        protected void btnEditCancel_Click(object sender, EventArgs e)
        {
        }
        protected void btnAddChild_Click(object sender, EventArgs e)
        {
            DataBaseDataContext db = new DataBaseDataContext(connectionString);
            int parentId = Convert.ToInt32(RadTreeView1.SelectedNode.Value);
            int level;
            string parentCode;
            string[] accountLength;
           
            var qry = (from c in db.GL_Accounts
                       where c.Account_ID == parentId
                       select c).SingleOrDefault();
            parentCode = qry.Account_Code;
            level = Convert.ToInt32(qry.Levels) + 1; 

            if (level == 4)
            {
                rbtnBank.Visible = true;
                rbtnCash.Visible = true;
                if (qry.Bank != null)
                    rbtnBank.Checked = Convert.ToBoolean(qry.Bank);
                if (qry.Cash != null)
                    rbtnCash.Checked = Convert.ToBoolean(qry.Cash);
            }
            else
            {
                rbtnBank.Visible = false;
                rbtnCash.Visible = false;
            }
            var tbl = (from config in db.Configurations
                       where config.Configuration_Name == "Chart of Accounts Level"
                       select config).SingleOrDefault();
            accountLength = tbl.Configuration_Value.Split(',');                 
            string maxcode = DBClass.getField("select isnull(max(account_serial),0) from gl_accounts where parent_code=" + parentId + " and Levels>1");
            int newcode = Convert.ToInt32(maxcode);
            newcode += 1;
            txtParent_Code.Text = parentCode;
            txtAccount_Code.Text = newcode.ToString(accountLength[level - 1]);
            txtAccount_Name.Text = "";
            txtAccount_Code.ReadOnly = false;
            hdnParentId.Value = parentId.ToString();
            hdnLevel.Value = level.ToString();
            txtAccount_Name.Focus();
            hdnAddOrEdit.Value = "Add Child";
            btnEditSave.Text = "Save";
            btnAdd.Enabled = true;
            btnAdd.CssClass = "";
            btnEditSave.Enabled = true;
            btnEditSave.CssClass = "";
        }

        protected void btnEditAccount_Click(object sender, EventArgs e)
        {
            DataBaseDataContext db = new DataBaseDataContext(connectionString);
            int accountId = Convert.ToInt32(RadTreeView1.SelectedNode.Value);
            var qry = (from c in db.GL_Accounts
                       from p in db.GL_Accounts
                       where c.Parent_Code == p.Account_ID &&
                       c.Account_ID == accountId
                       select new
                       {
                           c.Account_ID,
                           c.Account_Code,
                           c.Account_Name,
                           c.Levels,
                           c.Account_Serial,
                           Parent = p.Account_Code
                       }).SingleOrDefault();
            if (qry.Levels == 1)
                txtAccount_Code.Text = "";
            else
                txtAccount_Code.Text = qry.Account_Serial;
            txtAccount_Code.ReadOnly = true;
            txtParent_Code.Text = qry.Parent;
            txtAccount_Name.Text = qry.Account_Name;
            hdnAddOrEdit.Value = "Edit";
        }

        protected void btnDelete_Click(object sender, EventArgs e)
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
                int accountId = Convert.ToInt32(RadTreeView1.SelectedNode.Value);
                var qry = (from c in db.GL_Accounts
                           from p in db.GL_Accounts
                           where c.Parent_Code == p.Account_ID &&
                           c.Account_ID == accountId
                           select c);
                db.GL_Accounts.DeleteAllOnSubmit(qry);
                db.SubmitChanges();
                string query = "";
                query += "Update AR_CUstomers set account_ID=Null where account_ID=" + accountId + ";";
                query += "Update AP_Vendors set account_ID=null where account_ID=" + accountId + ";";
                query += "Update GL_Voucher_Accounts set account_ID=Null where account_ID=" + accountId + "; ";
                DBClass.exectueQueryWithTransaction(query, tranObj, con);
                RadTreeNode tn = RadTreeView1.SelectedNode;
                RadTreeView1.SelectedNode.ParentNode.Nodes.Remove(RadTreeView1.SelectedNode);
                tranObj.Commit();
                db.Transaction.Commit();
                Cleartxt();
            }
            catch (Exception ex)
            {
                if (tranObj != null)
                    tranObj.Rollback();
                throw;
            }
            finally
            {
                con.Close();
                db.Connection.Close();
            }
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            DataBaseDataContext db = new DataBaseDataContext(connectionString);
            int accountId = Convert.ToInt32(RadTreeView1.SelectedNode.Value);
            int parentId;
            int level;
            string[] accountLength;
            var qry = (from c in db.GL_Accounts
                       where c.Account_ID == accountId
                       select c).SingleOrDefault();
            parentId = qry.Parent_Code.Value;
            level = Convert.ToInt32(qry.Levels) - 1;
            if (level == 4)
            {
                rbtnBank.Visible = true;
                rbtnCash.Visible = true;
                if (qry.Bank != null)
                    rbtnBank.Checked = Convert.ToBoolean(qry.Bank);
                if (qry.Cash != null)
                    rbtnCash.Checked = Convert.ToBoolean(qry.Cash);
            }
            else
            {
                rbtnBank.Visible = false;
                rbtnCash.Visible = false;
            }
            
            var parentCode = (from c in db.GL_Accounts
                              where c.Account_ID == parentId
                              select new { c.Account_Code }).SingleOrDefault();

            
            var tbl = (from config in db.Configurations
                       where config.Configuration_Name == "Chart of Accounts Level"
                       select config).SingleOrDefault();
            accountLength = tbl.Configuration_Value.Split(',');                 
            string maxcode = DBClass.getField("select Isnull(max(account_serial),0) from gl_accounts where parent_code=" + parentId + " and Levels>1");
            int newcode = Convert.ToInt32(maxcode);
            newcode += 1;
            txtParent_Code.Text = parentCode.Account_Code;
            txtAccount_Code.Text = newcode.ToString(accountLength[level]);
            txtAccount_Name.Text = "";
            txtAccount_Code.ReadOnly = false;
            hdnParentId.Value = parentId.ToString();
            hdnLevel.Value = qry.Levels.ToString();
            txtAccount_Name.Focus();
            hdnAddOrEdit.Value = "Add";
            btnEditSave.Text = "Save";
           
        }

        protected void RadTreeView1_NodeEdit(object sender, RadTreeNodeEditEventArgs e)
        {
            int accountId = Convert.ToInt32(RadTreeView1.SelectedNode.Value);
            DataBaseDataContext db = new DataBaseDataContext(connectionString);
            RadTreeNode tn = e.Node;            
            var qry = (from acc in db.GL_Accounts
                       where acc.Account_ID == accountId
                       select acc);
            foreach (var item in qry)
            {
                item.Account_Name = txtAccount_Name.Text;
                item.Updated_Time = DateTime.Now;
                db.SubmitChanges();
            }
            tn.Text = e.Text;
            tn.Value = accountId.ToString();
        }

        protected void RadTreeView1_NodeExpand(object sender, RadTreeNodeEventArgs e)
        {
            RadTreeNode tn = e.Node;
            int account_ID = Convert.ToInt32(e.Node.Value);
            addChildNodesLevel4NodeExpand(tn, account_ID);
        }
        private void addChildNodesLevel4NodeExpand(RadTreeNode parentTn, int parentId)
        {
            DataBaseDataContext db = new DataBaseDataContext(connectionString);
            var qry = from coa in db.GL_Accounts
                      where coa.Parent_Code == parentId && coa.Levels > 1
                      orderby coa.Account_Code
                      select coa;
            foreach (var item in qry)
            {
                RadTreeNode tn = new RadTreeNode(item.Account_Code + " - " + item.Account_Name, item.Account_ID.ToString());
                if(item.Levels != 4)
                    tn.ExpandMode = TreeNodeExpandMode.ServerSideCallBack;
                parentTn.Nodes.Add(tn);
            }
            db.Dispose();
        }

        protected void RadTreeView1_NodeClick(object sender, RadTreeNodeEventArgs e)
        {
            DataBaseDataContext db = new DataBaseDataContext(connectionString);
            int accountId = Convert.ToInt32(RadTreeView1.SelectedNode.Value);
            var lvl = (from c in db.GL_Accounts
                       where c.Account_ID == accountId
                       select c).SingleOrDefault();
            if (lvl.Levels != 1)
            {
                var qry = (from c in db.GL_Accounts
                           from p in db.GL_Accounts
                           where c.Parent_Code == p.Account_ID &&
                           c.Account_ID == accountId
                           select new
                           {
                               c.Account_ID,
                               c.Account_Code,
                               c.Account_Name,
                               c.Levels,
                               c.Account_Serial,
                               Parent = p.Account_Code,
                               c.Bank,
                               c.Cash
                           }).SingleOrDefault();
                if (qry.Levels == 4)
                {
                    rbtnBank.Visible = true;
                    rbtnCash.Visible = true;
                    if (qry.Bank != null)
                        rbtnBank.Checked = Convert.ToBoolean(qry.Bank);
                    if (qry.Cash != null)
                        rbtnCash.Checked = Convert.ToBoolean(qry.Cash);
                }
                else
                {
                    rbtnBank.Visible = false;
                    rbtnCash.Visible = false;
                }
                txtAccount_Code.Text = qry.Account_Serial;
                txtAccount_Code.ReadOnly = true;
                txtParent_Code.Text = qry.Parent;
                txtAccount_Name.Text = qry.Account_Name;
            }
            else
            {
                txtParent_Code.Text = lvl.Account_Serial;
                txtAccount_Name.Text = lvl.Account_Name;
            }
            hdnAddOrEdit.Value = "Edit";
            RadTreeNode tn = RadTreeView1.SelectedNode;
            int count = (from coa in db.GL_Accounts
                         where coa.Parent_Code == Convert.ToInt32(tn.Value)
                         orderby coa.Account_Code
                         select coa).Count();
            if (count > 0)
            {
                btnDelete.Enabled = false;
                btnDelete.CssClass= "buttonDisabled";
            }
            else
            {
                btnDelete.Enabled = true;
                btnDelete.CssClass = "btn btn-primry";
            }
            var query = (from coa in db.GL_Accounts
                         where coa.Account_ID == Convert.ToInt32(tn.Value)
                         select new { coa.Levels }).FirstOrDefault();
            if (query.Levels == 1)
            {
                btnAdd.Enabled = false;
                btnAdd.CssClass = "buttonDisabled";
                btnEditSave.Enabled = false;
                btnEditSave.CssClass = "buttonDisabled";
            }
            else
            {
                btnAdd.Enabled = true;
                btnAdd.CssClass = "btn btn-primry";
                btnEditSave.Enabled = true;
                btnEditSave.CssClass = "btn btn-primry";
            }
            if (query.Levels == 4)
            {
                btnAddChild.Enabled = false;
                btnAddChild.CssClass = "buttonDisabled";
            }
            else
            {
                btnAddChild.Enabled = true;
                btnAddChild.CssClass = "btn btn-primry";
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Cleartxt();
            RadTreeView1.SelectedNode.Selected = false;
        }
        public void Cleartxt()
        {
            rbtnBank.Checked = false;
            rbtnCash.Checked = false;
            hdnAddOrEdit.Value = "";
            txtParent_Code.Text = "";
            txtAccount_Code.Text = "";
            txtAccount_Name.Text = "";
            btnEditSave.Text = "Update";
            upRadTreeview.Update();
        }
    }
}