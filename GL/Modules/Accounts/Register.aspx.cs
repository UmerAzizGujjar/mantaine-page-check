using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Account
{
    public partial class Register : System.Web.UI.Page
    {

        protected void Page_Load(object sender, EventArgs e)
        {
            RegisterUser.ContinueDestinationPageUrl = Request.QueryString["ReturnUrl"];
        }

        protected void RegisterUser_CreatedUser(object sender, EventArgs e)
        {
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                CheckBox AllowUnapproveVoucher = (CheckBox)RegisterUser.CreateUserStep.ContentTemplateContainer.FindControl("AllowUnapproveVoucher");
                CheckBox AllowPatientEdit = (CheckBox)RegisterUser.CreateUserStep.ContentTemplateContainer.FindControl("AllowPatientEdit");
                CheckBox AllowPatientDelete = (CheckBox)RegisterUser.CreateUserStep.ContentTemplateContainer.FindControl("AllowPatientDelete");
                CheckBox AllPatientRecords = (CheckBox)RegisterUser.CreateUserStep.ContentTemplateContainer.FindControl("AllPatientRecords");
                CheckBox OTPUsers = (CheckBox)RegisterUser.CreateUserStep.ContentTemplateContainer.FindControl("OTPUsers");
                
                string userID = DBClass.getField("SELECT UserID FROM aspnet_Users WHERE UserName = '" + RegisterUser.UserName + "'");
                TextBox passwordTextbox = (TextBox)RegisterUser.CreateUserStep.ContentTemplateContainer.FindControl("Password");
                string plainPassword = passwordTextbox.Text;
                string salt = GenerateSalt();  
                string encryptedPassword = EncryptPassword(plainPassword, salt); 

                using (DataBaseDataContext db = new DataBaseDataContext()) 
                {
                    Guid userGuid = Guid.Parse(userID);
                    aspnet_Membership Rest = (from m in db.aspnet_Memberships
                                              where m.UserId == userGuid
                                              select m).FirstOrDefault();


                    if (Rest != null)
                    {
                        Rest.Password = encryptedPassword;
                        Rest.PasswordSalt = salt;
                        Rest.IsLockedOut = false; 

                       
                        db.SubmitChanges();
                    }
                }
         
                if (AllowUnapproveVoucher != null)
                {
                    if (AllowUnapproveVoucher.Checked)
                        DBClass.exectueQuery("Update aspnet_Users set AllowUnapproveVoucher=1 where UserName='" + RegisterUser.UserName + "'", tranObj, con);
                    else
                        DBClass.exectueQuery("Update aspnet_Users set AllowUnapproveVoucher=0 where UserName='" + RegisterUser.UserName + "'", tranObj, con);

                   
                }
                DBClass.exectueQuery(
                "Update aspnet_Users set AllowPatientEdit='" + AllowPatientEdit.Checked +
                "', AllPatientRecords='" + AllPatientRecords.Checked +
                "', AllowPatientDelete='" + AllowPatientDelete.Checked +
                "', OTPUsers='" + OTPUsers.Checked +
                "' where username='" + RegisterUser.UserName + "'",
                tranObj, con
            );
                DBClass.exectueQuery("Update aspnet_Users set AllowTestRate=0 where UserName='" + RegisterUser.UserName + "'", tranObj, con);
                DBClass.exectueQuery("Update aspnet_Users set OpdAllow=0 where UserName='" + RegisterUser.UserName + "'", tranObj, con);
                DBClass.exectueQuery("Update aspnet_Users set allow_lab=0 where UserName='" + RegisterUser.UserName + "'", tranObj, con);
                DBClass.exectueQuery("Update aspnet_Users set allow_ultra=0 where UserName='" + RegisterUser.UserName + "'", tranObj, con);
                DBClass.exectueQuery("Update aspnet_Users set BlockUser=0 where UserName='" + RegisterUser.UserName + "'", tranObj, con);
                DBClass.exectueQuery("Update aspnet_Users set AllowBillDelete=0 where UserName='" + RegisterUser.UserName + "'", tranObj, con);
                DBClass.exectueQuery("Update aspnet_Users set Allowtestbox=0 where UserName='" + RegisterUser.UserName + "'", tranObj, con);
                DBClass.exectueQuery("Update aspnet_Users set AllowTestRate=0 where UserName='" + RegisterUser.UserName + "'", tranObj, con);
                DBClass.exectueQuery("Update aspnet_Users set allow_ctscan=0 where UserName='" + RegisterUser.UserName + "'", tranObj, con);
                DBClass.exectueQuery("Update aspnet_Users set allow_xray=0 where UserName='" + RegisterUser.UserName + "'", tranObj, con);
                DBClass.exectueQuery("Update aspnet_Users set allow_b_bank=0 where UserName='" + RegisterUser.UserName + "'", tranObj, con);
                DBClass.exectueQuery("Update aspnet_Users set AllowPharmacy=0 where UserName='" + RegisterUser.UserName + "'", tranObj, con);
                DBClass.exectueQuery("Update aspnet_Users set AllowGeneralItems=0 where UserName='" + RegisterUser.UserName + "'", tranObj, con);
                DBClass.exectueQuery("Update aspnet_Users set IsShowBudget=0 where UserName='" + RegisterUser.UserName + "'", tranObj, con);
                DBClass.exectueQuery("Update aspnet_Users set IsInventoryUnApprove=0 where UserName='" + RegisterUser.UserName + "'", tranObj, con);
            
                tranObj.Commit();

                string continueUrl = RegisterUser.ContinueDestinationPageUrl;
                if (String.IsNullOrEmpty(continueUrl))
                {
                    continueUrl = "~/";
                }
                Response.Redirect("~/Modules/Accounts/Login.aspx", false);

            }
            catch (Exception ex)
            {
                if (tranObj != null)
                    tranObj.Rollback();
            }
            finally
            {
                con.Close();
            }
        }
        private string GenerateSalt()
        {
            byte[] saltBytes = new byte[16];
            using (var rng = new System.Security.Cryptography.RNGCryptoServiceProvider())
            {
                rng.GetBytes(saltBytes);
            }
            return Convert.ToBase64String(saltBytes);
        }

        private string EncryptPassword(string password, string salt)
        {
            var combinedPasswordSalt = password + salt;

            using (SHA1 sha1 = SHA1.Create())
            {
                byte[] bytes = Encoding.UTF8.GetBytes(combinedPasswordSalt);
                byte[] hash = sha1.ComputeHash(bytes);

                return Convert.ToBase64String(hash);
            }
        }
        protected void RegisterUser_CreatingUser(object sender, LoginCancelEventArgs e)
        {
            
        }

        protected void CreateUserButton_Click(object sender, EventArgs e)
        {
            
        }
    }
}
