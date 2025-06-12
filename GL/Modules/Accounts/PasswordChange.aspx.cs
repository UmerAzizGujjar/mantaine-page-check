using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
namespace PMS.Modules.Accounts
{
    public partial class PasswordChange : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string ChangePassword(DataFromFrontend data)
        {
            var userName = AppConfig.UserName;
            var response = "";
            var password = data.ConfirmNewPassword;
            var oldpassword = data.OldPassword;

            if (string.IsNullOrEmpty(oldpassword))
            {


                response = "Old password is required!";

                return response;

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
                                response = "Password changed successfully!";
                                return response;

                            }
                        }
                        else
                        {
                            response = "Old Password is incorrect!";
                            return response;

                        }
                    }
                }
                else
                {
                    response = "User not found!";


                }
            }
            return response;
        }

        private static string GenerateSalt()
        {
            byte[] saltBytes = new byte[16];
            using (var rng = new System.Security.Cryptography.RNGCryptoServiceProvider())
            {
                rng.GetBytes(saltBytes);
            }
            return Convert.ToBase64String(saltBytes);
        }

        private static string EncryptPassword(string password, string salt)
        {
            var combinedPasswordSalt = password + salt;

            using (SHA1 sha1 = SHA1.Create())
            {
                byte[] bytes = Encoding.UTF8.GetBytes(combinedPasswordSalt);
                byte[] hash = sha1.ComputeHash(bytes);

                return Convert.ToBase64String(hash);
            }
        }
        public class DataFromFrontend
        {
            public string OldPassword { get; set; }
            public string NewPassword { get; set; }
            public string ConfirmNewPassword { get; set; }
        }
    }
}
    