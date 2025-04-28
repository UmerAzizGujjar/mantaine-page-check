using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Security;

namespace PMS.Account
{
    public partial class UserView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindGrid();
            }
        }

        private void BindGrid()
        {
            if (txtSearch.Text == "")
            {
                DataTable dt = DBClass.getDataTable("SELECT aspnet_Membership.UserID, UserName, Email, aspnet_Users.mobileno, AllowUnapproveVoucher, AllowPatientEdit, AllowPatientDelete, AllowBillDelete, AllPatientRecords, Emp_Code, AllowTestRate, allowtestbox, OpdAllow, allow_ultra, allow_lab, allow_ctscan, allow_xray, allow_b_bank, BlockUser, AllowPharmacy, AllowGeneralItems, IsShowBudget, IsInventoryUnApprove, IsNotificationViewed,OTPUsers FROM aspnet_Users INNER JOIN aspnet_Membership ON aspnet_Users.UserID = aspnet_Membership.UserID ORDER BY UserName;");

                gvUsers.DataSource = dt;
                gvUsers.DataBind();
            }
            else
            {
                string adputsignOperator = !chkExactSearching.Checked ? "%" : "";

                DataTable dt = DBClass.getDataTable("select aspnet_Membership.UserID,UserName,Email,aspnet_Users.mobileno,AllowUnapproveVoucher,AllowPatientEdit,AllPatientRecords,AllowPatientDelete,AllowBillDelete,Emp_Code,AllowTestRate,allowtestbox,OpdAllow,allow_ultra,allow_lab,allow_ctscan,allow_xray,allow_b_bank,BlockUser,AllowPharmacy,AllowGeneralItems,IsShowBudget,IsInventoryUnApprove,IsNotificationViewed,OTPUsers from aspnet_Users inner join aspnet_Membership on aspnet_Users.UserID=aspnet_Membership.UserID and username like '" + adputsignOperator + "" + txtSearch.Text + "" + adputsignOperator + "'");
                gvUsers.DataSource = dt;
                gvUsers.DataBind();
            }
        }
        protected void gvUsers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            try
            {
                if (e.CommandName == "Remove")
                {
                    string UserName = Convert.ToString(e.CommandArgument);
                    Membership.DeleteUser(UserName, true);
                    lblMessage.Text = "User has been deleted successfully.";
                    lblMessage.CssClass = "sucessfullMessage";
                    BindGrid();
                }
                if (e.CommandName == "Reset")
                {
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    string UserName = Convert.ToString(e.CommandArgument);
                    if (UserName != null)
                    {
                        Guid userExists = (Guid)(from m in db.aspnet_Users
                                                  where m.UserName == Convert.ToString(UserName)
                                                  select m.UserId).FirstOrDefault();
                        if (userExists != null)
                        {
                            aspnet_Membership Rest = (from m in db.aspnet_Memberships
                                                      where m.UserId == userExists
                                                     select m).FirstOrDefault();
                            Rest.Password = "sFzZ/5lcW5h8v+EWSCYpApN1Izc=";
                            Rest.PasswordSalt = "+F9MPo0sk8oAOfWVLlX1FQ==";
                            Rest.IsLockedOut = false;
                            db.SubmitChanges();
                        }
                    }
                    BindGrid();
                }
               
            }
            catch (Exception ex)
            {
                lblMessage.Text = ex.Message;
                lblMessage.CssClass = "errorMessage";
            }
        }

        protected void gvUsers_RowEditing(object sender, GridViewEditEventArgs e)
        {
            
         gvUsers.EditIndex = e.NewEditIndex;
         BindGrid();
        }

        protected void gvUsers_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                aspnet_User user = new aspnet_User();
                TextBox txtUserName = gvUsers.Rows[e.RowIndex].FindControl("txtUserName") as TextBox;
                TextBox txtMobile = gvUsers.Rows[e.RowIndex].FindControl("txtMobile") as TextBox;
                TextBox txtEmpCode = gvUsers.Rows[e.RowIndex].FindControl("txtEmpCode") as TextBox;
                CheckBox cbApprvVoucher = gvUsers.Rows[e.RowIndex].FindControl("cbApprvVoucher") as CheckBox;
                CheckBox cbAllowPatientEdit = gvUsers.Rows[e.RowIndex].FindControl("cbApprovePatientEdit") as CheckBox;
                CheckBox cbAllowPatientDelete = gvUsers.Rows[e.RowIndex].FindControl("cbApprovePatientDelete") as CheckBox;
                CheckBox cbAllowOPD = gvUsers.Rows[e.RowIndex].FindControl("cbAllowOPD") as CheckBox;

                CheckBox cbtestrate = gvUsers.Rows[e.RowIndex].FindControl("cbtestrate") as CheckBox;
                CheckBox cbAllowlab = gvUsers.Rows[e.RowIndex].FindControl("cbAllowlab") as CheckBox;
                CheckBox cbAllowultra = gvUsers.Rows[e.RowIndex].FindControl("cbAllowultra") as CheckBox;
                CheckBox cbAllowctscan = gvUsers.Rows[e.RowIndex].FindControl("cbAllowctscan") as CheckBox;
                CheckBox cbAllowxray = gvUsers.Rows[e.RowIndex].FindControl("cbAllowxray") as CheckBox;
                CheckBox cbAllowBloodbank = gvUsers.Rows[e.RowIndex].FindControl("cbAllowBloodbank") as CheckBox;

                //new Billdelete
                CheckBox cbAllowBillDelete = gvUsers.Rows[e.RowIndex].FindControl("cbApproveBillDelete") as CheckBox;
                CheckBox cbAllPatientRecords = gvUsers.Rows[e.RowIndex].FindControl("cbAllPatientRecords") as CheckBox;
                CheckBox cbotpuser = gvUsers.Rows[e.RowIndex].FindControl("cbOTPUser") as CheckBox;
                CheckBox cbBlockUser = gvUsers.Rows[e.RowIndex].FindControl("cbBlockUser") as CheckBox;               
                CheckBox cbAllowTestRate = gvUsers.Rows[e.RowIndex].FindControl("cbAllowTestRate") as CheckBox;
                Label lblUserID = gvUsers.Rows[e.RowIndex].FindControl("lblUserID") as Label;
                //Pharmcay Rights
                CheckBox cbAllowPharmacy = gvUsers.Rows[e.RowIndex].FindControl("cbAllowPharmacy") as CheckBox;
                CheckBox cbAllowGeneralItems = gvUsers.Rows[e.RowIndex].FindControl("cbAllowGeneralItems") as CheckBox;
                CheckBox cbIsShowBudget = gvUsers.Rows[e.RowIndex].FindControl("cbIsShowBudget") as CheckBox;
                CheckBox cbIsInventoryUnApprove = gvUsers.Rows[e.RowIndex].FindControl("cbIsInventoryUnApprove") as CheckBox;
                CheckBox cbIsNotificationViewed = gvUsers.Rows[e.RowIndex].FindControl("cbIsNotificationViewed") as CheckBox;
                Guid userID = new Guid(lblUserID.Text);
                user = (from m in db.aspnet_Users
                        where m.UserId == userID
                        select m).FirstOrDefault();
                if (user != null)
                {
                    aspnet_User userExists = (from m in db.aspnet_Users
                                              where m.UserId != userID && m.UserName == txtUserName.Text
                                              select m).FirstOrDefault();
                    if (userExists == null)
                    {
                        user.UserName = txtUserName.Text;
                        user.Emp_Code = txtEmpCode.Text;
                        user.LoweredUserName = txtUserName.Text.ToLower();
                        user.AllowUnapproveVoucher = cbApprvVoucher.Checked;
                        user.AllowPatientEdit = cbAllowPatientEdit.Checked;
                        user.allowtestbox = cbtestrate.Checked;
                        user.OpdAllow = cbAllowOPD.Checked;
                        user.AllowPatientDelete = cbAllowPatientDelete.Checked;
                        user.AllowBillDelete = cbAllowBillDelete.Checked;
                        user.AllPatientRecords = cbAllPatientRecords.Checked;
                        user.AllowTestRate = cbAllowTestRate.Checked;
                        user.allow_lab = cbAllowlab.Checked;
                        user.allow_ultra = cbAllowultra.Checked;
                        user.allow_ctscan = cbAllowctscan.Checked;
                        user.allow_xray = cbAllowxray.Checked;
                        user.allow_b_bank = cbAllowBloodbank.Checked;
                        user.BlockUser = cbBlockUser.Checked;
                        user.AllowPharmacy = cbAllowPharmacy.Checked;
                        user.AllowGeneralItems = cbAllowGeneralItems.Checked;
                        user.IsShowBudget = cbIsShowBudget.Checked;  
                        user.IsInventoryUnApprove = cbIsInventoryUnApprove.Checked;  
                        user.IsNotificationViewed = cbIsNotificationViewed.Checked;
                        user.mobileno = txtMobile.Text;
                        user.OTPUsers = cbotpuser.Checked;

                        db.SubmitChanges();
                    }

                    //MembershipUser User = Membership.GetUser(txtMobile.Text);
                    ////User.mob = txte.Text;
                    //Membership.UpdateUser(User);
                    lblMessage.Text = "User has been updated successfully.";
                    lblMessage.CssClass = "sucessfullMessage";
                    gvUsers.EditIndex = -1;
                    BindGrid();
                }
            }
            catch (Exception ex)
            {
                lblMessage.Text = ex.Message;
                lblMessage.CssClass = "errorMessage";
            }
        }

        protected void gvUsers_RestPass(object sender, GridViewUpdateEventArgs e)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                aspnet_User user = new aspnet_User();
                TextBox txtUserName = gvUsers.Rows[e.RowIndex].FindControl("txtUserName") as TextBox;
                TextBox txtEmail = gvUsers.Rows[e.RowIndex].FindControl("txtEmail") as TextBox;
                CheckBox cbApprvVoucher = gvUsers.Rows[e.RowIndex].FindControl("cbApprvVoucher") as CheckBox;
                CheckBox cbAllowPatientEdit = gvUsers.Rows[e.RowIndex].FindControl("cbApprovePatientEdit") as CheckBox;
                CheckBox cbAllowPatientDelete = gvUsers.Rows[e.RowIndex].FindControl("cbApprovePatientDelete") as CheckBox;
                CheckBox cbotpuser = gvUsers.Rows[e.RowIndex].FindControl("cbOTPUser") as CheckBox;
                //newBillDelete
                TextBox txtMobile = gvUsers.Rows[e.RowIndex].FindControl("txtMobile") as TextBox;
                CheckBox cbAllowBillDelete = gvUsers.Rows[e.RowIndex].FindControl("cbApproveBillDelete") as CheckBox;
                CheckBox cbtestrate = gvUsers.Rows[e.RowIndex].FindControl("cbtestrate") as CheckBox;
                CheckBox cbAllowOPD = gvUsers.Rows[e.RowIndex].FindControl("cbAllowOPD") as CheckBox;
                CheckBox cbAllPatientRecords = gvUsers.Rows[e.RowIndex].FindControl("cbAllPatientRecords") as CheckBox;
                CheckBox cbAllowTestRate = gvUsers.Rows[e.RowIndex].FindControl("cbAllowTestRate") as CheckBox;
                CheckBox allow_lab = gvUsers.Rows[e.RowIndex].FindControl("allow_lab") as CheckBox;
                CheckBox cbAllowultra = gvUsers.Rows[e.RowIndex].FindControl("cbAllowultra") as CheckBox;
                CheckBox cbAllowctscan = gvUsers.Rows[e.RowIndex].FindControl("cbAllowctscan") as CheckBox;
                CheckBox cbAllowxray = gvUsers.Rows[e.RowIndex].FindControl("cbAllowxray") as CheckBox;
                CheckBox cbAllowBloodbank = gvUsers.Rows[e.RowIndex].FindControl("cbAllowBloodbank") as CheckBox;
                Label lblUserID = gvUsers.Rows[e.RowIndex].FindControl("lblUserID") as Label;
                Guid userID = new Guid(lblUserID.Text);
                user = (from m in db.aspnet_Users
                        where m.UserId == userID
                        select m).FirstOrDefault();
                if (user != null)
                {
                    aspnet_User userExists = (from m in db.aspnet_Users
                                              where m.UserId != userID && m.UserName == txtUserName.Text
                                              select m).FirstOrDefault();
                    if (userExists == null)
                    {
                        user.UserName = txtUserName.Text;
                        user.LoweredUserName = txtUserName.Text.ToLower();
                        user.AllowUnapproveVoucher = cbApprvVoucher.Checked;
                        user.AllowPatientEdit = cbAllowPatientEdit.Checked;
                        user.AllowPatientDelete = cbAllowPatientDelete.Checked;
                        user.allowtestbox = cbtestrate.Checked;
                        user.OpdAllow = cbAllowOPD.Checked;
                        user.AllowBillDelete = cbAllowBillDelete.Checked;
                        user.allow_lab = cbAllowOPD.Checked;
                        user.allow_ultra = cbAllowultra.Checked;
                        user.allow_ctscan = cbAllowctscan.Checked;
                        user.allow_xray = cbAllowxray.Checked;
                        user.allow_b_bank = cbAllowxray.Checked;
                        user.AllPatientRecords = cbAllPatientRecords.Checked;
                        user.AllowTestRate = cbAllowTestRate.Checked;
                        user.mobileno = txtMobile.Text;
                        user.OTPUsers = cbotpuser.Checked;
                        db.SubmitChanges();
                    }

                    MembershipUser User = Membership.GetUser(txtUserName.Text);
                    User.Email = txtEmail.Text;
                    Membership.UpdateUser(User);
                    lblMessage.Text = "User has been updated successfully.";
                    lblMessage.CssClass = "sucessfullMessage";
                    gvUsers.EditIndex = -1;
                    BindGrid();
                }
            }
            catch (Exception ex)
            {
                lblMessage.Text = ex.Message;
                lblMessage.CssClass = "errorMessage";
            }
        }

        protected void gvUsers_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvUsers.EditIndex = -1;
            BindGrid();
        }
        protected void gvUsers_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvUsers.PageIndex = e.NewPageIndex;
            BindGrid();
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            BindGrid();
        }

        protected void chkExactSearching_CheckedChanged(object sender, EventArgs e)
        {
            txtSearch_TextChanged(sender,e);
        }
    }
}