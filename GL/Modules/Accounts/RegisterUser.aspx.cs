using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Accounts
{
    public partial class RegisterUser : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        public static string Create_User(DataFromFrontEnd data)
        {


            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

                //checks for duplicate

                bool userExists = (from u in db.aspnet_Users
                                   where u.LoweredUserName == data.UserName.ToLower()
                                   select u).Any();
                bool emailExists = (from u in db.aspnet_Memberships
                                    where u.LoweredEmail == data.Email.ToLower()
                                    select u).Any();
                if (userExists)
                {
                    return "UserName Already Exists";
                }
                else if (emailExists)
                {
                    return "Email Already Exists";
                }
                aspnet_User newuser = new aspnet_User();
                Guid userID = Guid.NewGuid();
                var appID = (from app in db.aspnet_Applications
                             where app.ApplicationName == "/"
                             select app.ApplicationId).FirstOrDefault();

                //Assign Values to aspnet_user table
                newuser.ApplicationId = appID;
                newuser.UserId = userID;
                newuser.UserName = data.UserName;
                newuser.LoweredUserName = data.UserName.ToLower();
                newuser.AllowPatientDelete = data.AllowPatientDelete;
                newuser.AllPatientRecords = data.AllPatientRecords;
                newuser.AllowPatientEdit = data.AllowPatientEdit;
                newuser.OTPUsers = data.OTPUsers;
                newuser.AllowTestRate = false;
                newuser.OpdAllow = false;
                newuser.allow_lab = false;
                newuser.allow_ultra = false;
                newuser.BlockUser = false;
                newuser.AllowBillDelete = false;
                newuser.allowtestbox = false;
                newuser.allow_ctscan = false;
                newuser.allow_xray = false;
                newuser.allow_b_bank = false;
                newuser.AllowPharmacy = false;
                newuser.AllowGeneralItems = false;
                newuser.IsShowBudget = false;
                newuser.IsInventoryUnApprove = false;
                newuser.AllowToAccessAllTest = false;
                newuser.allow_cardio = false;
                newuser.IsNotificationViewed = false;
                newuser.AllowUnapproveVoucher = data.AllowUnapproveVouchers;
                newuser.IsAnonymous = false;
                newuser.LastActivityDate = new DateTime(1754, 1, 1, 0, 0, 0);
                db.aspnet_Users.InsertOnSubmit(newuser);

                //generate password hashes

                string plainPassword = data.Password;
                string salt = GenerateSalt();
                string encryptedPassword = EncryptPassword(plainPassword, salt);

                //Assign Values to aspnet_membership table

                aspnet_Membership newUser_membership = new aspnet_Membership();
                newUser_membership.ApplicationId = appID;
                newUser_membership.UserId = userID;
                newUser_membership.Password = encryptedPassword;
                newUser_membership.PasswordSalt = salt;
                newUser_membership.IsLockedOut = false;
                newUser_membership.Email = data.Email;
                newUser_membership.LoweredEmail = data.Email.ToLower();
                newUser_membership.IsApproved = true;
                newUser_membership.CreateDate = DateTime.Now;
                newUser_membership.LastPasswordChangedDate = DateTime.Now;
                newUser_membership.LastLoginDate = new DateTime(1754, 1, 1, 0, 0, 0);
                newUser_membership.LastLockoutDate = new DateTime(1754, 1, 1, 0, 0, 0);
                newUser_membership.FailedPasswordAnswerAttemptWindowStart = new DateTime(1754, 1, 1, 0, 0, 0);
                newUser_membership.FailedPasswordAttemptWindowStart = new DateTime(1754, 1, 1, 0, 0, 0);
                newUser_membership.PasswordFormat = 1;
                newUser_membership.FailedPasswordAttemptCount = 0;
                newUser_membership.FailedPasswordAnswerAttemptCount = 0;
                db.aspnet_Memberships.InsertOnSubmit(newUser_membership);
                db.SubmitChanges();

            }
            catch (Exception ex)
            {

                return "Error: " + ex.Message;
            }

            return "success";
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
        public class DataFromFrontEnd
        {
            public string UserName { get; set; }
            public string Email { get; set; }
            public string Password { get; set; }
            public string ConfirmPassword { get; set; }
            public bool AllowPatientEdit { get; set; }
            public bool AllowPatientDelete { get; set; }
            public bool AllPatientRecords { get; set; }

            public bool AllowUnapproveVouchers { get; set; }

            public bool OTPUsers { get; set; }
        }
    }
}