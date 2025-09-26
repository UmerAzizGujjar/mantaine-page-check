using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.PeerToPeer;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web.UI;
using static System.Net.Mime.MediaTypeNames;
using System.Security.Cryptography;
using System.Text;

namespace PMS.Account
{
    public partial class ChangePassword : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        protected void ChangePasswordPushButton_Click(object sender, EventArgs e)
        {
            var userName = Session["UNChnagePassword"];
            if (userName == null)
                userName = AppConfig.UserName;

            var password = ChangeUserPassword.ConfirmNewPassword;
            var oldpassword = ChangeUserPassword.CurrentPassword;

            if (string.IsNullOrEmpty(oldpassword))
            {
                ShowAlert("Error!", "Old password is required!", "error");
                return;
            }

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var userExists = (from u in db.aspnet_Users
                                  where u.UserName == userName
                                  select u.UserId).FirstOrDefault();

                if (userExists != null)
                {
                    var membershipRecord = (from m in db.aspnet_Memberships
                                            where m.UserId == userExists
                                            select new { m.Password, m.PasswordSalt }).FirstOrDefault();

                    if (membershipRecord != null)
                    {
                        string hashedInputPassword = EncryptPassword(oldpassword, membershipRecord.PasswordSalt);
                        if (hashedInputPassword == membershipRecord.Password)
                        {
                            aspnet_Membership Rest = (from m in db.aspnet_Memberships
                                                      where m.UserId == userExists
                                                      select m).FirstOrDefault();
                            if (Rest != null)
                            {
                                string salt = GenerateSalt();
                                string encryptedPassword = EncryptPassword(password, salt);
                                Rest.Password = encryptedPassword;
                                Rest.PasswordSalt = salt;
                                Rest.IsLockedOut = false;
                                db.SubmitChanges();

                                ShowAlertWithRedirect("Success!", "Password changed successfully!", "success", "~/Login.aspx");
                            }
                        }
                        else
                        {
                            ShowAlert("Error!", "Old Password is incorrect!", "error");
                        }
                    }
                }
                else
                {
                    ShowAlert("Error!", "User not found!", "error");
                }
            }
        }
        private void ShowAlert(string title, string message, string icon)
        {
            string script = $"Swal.fire('{title}', '{message}', '{icon}');";
            ClientScript.RegisterStartupScript(this.GetType(), "alert", script, true);
        }

        private void ShowAlertWithRedirect(string title, string message, string icon, string redirectUrl)
        {
            string script = $@"
                            Swal.fire('{title}', '{message}', '{icon}').then((result) => {{
                                if (result.isConfirmed) {{
                                    window.location.href = '{redirectUrl}';
                                }}
                            }});
                            ";
            ClientScript.RegisterStartupScript(this.GetType(), "alert", script, true);
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

    }
}

