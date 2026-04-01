using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection.Emit;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web;

namespace PMS.Modules.Accounts
{
    public partial class RegisterUser : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            

        }

        [WebMethod]
        public static string GetGLAccounts()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from account in db.GL_Accounts
                              where account.Levels == 4
                              select new
                              {
                                  account.Account_ID,
                                  account.Account_Name,
                                  account.Parent_Code,
                              }).ToList();

                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        [WebMethod]
        public static string Populate_Data(string UserID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var users = (from p in db.aspnet_Users
                         join rg in db.aspnet_Memberships on p.UserId equals rg.UserId
                         where p.UserId.ToString() == UserID
                         select new
                         {
                             UserName = p.UserName,
                             mobileno = rg.mobileno,
                             Email = rg.Email,
                             Accounts = p.Gl_Account,
                             AllowPatientDelete = p.AllowPatientDelete,
                             AllPatientRecords = p.AllPatientRecords,
                             AllowPatientEdit = p.AllowPatientEdit,
                             OTPUsers = p.OTPUsers,
                             AllowTestRate = p.AllowTestRate,
                             OpdAllow = p.OpdAllow,
                             allow_lab = p.allow_lab,
                             allow_ultra = p.allow_ultra,
                             BlockUser = p.BlockUser,
                             AllowBillDelete = p.AllowBillDelete,
                             allowtestbox = p.allowtestbox,
                             allow_ctscan = p.allow_ctscan,
                             allow_xray = p.allow_xray,
                             allow_b_bank = p.allow_b_bank,
                             AllowPharmacy = p.AllowPharmacy,
                             AllowGeneralItems = p.AllowGeneralItems,
                             IsShowBudget = p.IsShowBudget,
                             IsInventoryUnApprove = p.IsInventoryUnApprove,
                             AllowToAccessAllTest = p.AllowToAccessAllTest,
                             allow_cardio = p.allow_cardio,
                             IsNotificationViewed = p.IsNotificationViewed,
                             AllowUnapproveVoucher = p.AllowUnapproveVoucher,
                             IsAnonymous = p.IsAnonymous,
                             EditEmergency = p.EditEmergency,
                             Allow_bill_edit = p.Allow_bill_edit,
                             Emergency_adm_dis = p.Emergency_adm_dis,
                             Allow_emer_disc = p.Allow_emer_disc,
                             Allow_Recipe = p.Allow_Recipe,
                             AllowSaleReturn = p.AllowSaleReturn,
                             AllowStudentUpdate = p.Student_Update,
                             RadiologyAllList = p.Allow_RadiologyAllList,
                             Radiology_result_Approval = p.Radiology_result_Approval,
                             AllowActiveItems = p.AllowActiveItems,
                             AllowRateEdit = p.AllowRateEdit,
                             AllowRadiologylist = p.Radiology_result,
                             AllowReferIPD = p.Refer_IPD, 
                             casher = p.cashier,
                             EmpCode=p.Emp_Code
                         }).FirstOrDefault();
            string data = string.Empty;
            data = new JavaScriptSerializer().Serialize(users);
            return data;
        }
        [WebMethod]
        public static string GetCasher()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Casher"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }
        [WebMethod]
        public static string Create_User(DataFromFrontEnd data)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

                //CHECKS

                bool editMode = false;
                bool userExists = (from u in db.aspnet_Users
                                   where u.LoweredUserName == data.UserName.ToLower()
                                   select u).Any();
                bool emailExists = (from u in db.aspnet_Memberships
                                    where u.LoweredEmail == data.Email.ToLower()
                                    select u).Any();

                if(data.UserIDfromURL != "")
                {
                    editMode = true;
                }

                //EDIT MODE

                if (editMode)
                {
                    var userData = (from p in db.aspnet_Users
                                    join rg in db.aspnet_Memberships on p.UserId equals rg.UserId
                                    where p.UserId.ToString() == data.UserIDfromURL
                                    select new { User = p, Membership = rg }).FirstOrDefault();

                    var user = userData?.User;
                    var membership = userData?.Membership;
                    user.UserName = data.UserName;
                    user.LoweredUserName = data.UserName.ToLower();
                    user.mobileno = data.Mobile;
                    if (string.IsNullOrEmpty(data.Accounts) || data.Accounts == "0")
                    {
                        user.Gl_Account = "0";
                    }
                    else
                    {
                        user.Gl_Account = data.Accounts;
                    }


                    user.AllowPatientDelete = data.AllowPatientDelete;
                    user.AllPatientRecords = data.AllPatientRecords;
                    user.AllowPatientEdit = data.AllowPatientEdit;
                    user.OTPUsers = data.OTPUsers;
                    user.AllowTestRate = data.AllowTestRate;
                    user.OpdAllow = data.AllowOPD;
                    user.allow_lab = data.AllowLab;
                    user.allow_ultra = data.AllowUltra;
                    user.BlockUser = data.BlockUser;
                    user.AllowBillDelete = data.AllowBillDelete;
                    user.allowtestbox = data.RateBox;
                    user.allow_ctscan = data.AllowCtscan;
                    user.allow_xray = data.AllowXray;
                    user.allow_b_bank = data.AllowB_Bank;
                    user.AllowPharmacy = data.AllowPharmacy;
                    user.AllowGeneralItems = data.GeneralItems;
                    user.IsShowBudget = data.ShowBudgetBtn;
                    user.IsInventoryUnApprove = data.InventoryUnApprove;
                    user.AllowToAccessAllTest = data.AllowToAccessAllTest;
                    user.allow_cardio = data.AllowCardio;
                    user.IsNotificationViewed = data.PRFsNotifications;
                    user.AllowUnapproveVoucher = data.AllowUnapproveVouchers;
                    user.IsAnonymous = data.IsAnonymous;
                    user.EditEmergency = data.EditEmergency;
                    user.Emergency_adm_dis = data.AllowEmergency_adm_dis;
                    user.Radiology_result = data.AllowRadiologylist;
                    user.Allow_bill_edit = data.AllowBillUpdate;
                    user.Allow_emer_disc = data.AllowemergencyDiscount;
                    user.Refer_IPD = data.AllowReferIPD;
                    user.Allow_Recipe = data.AllowRecipe;
                    user.AllowSaleReturn = data.AllowSaleReturn;
                    user.Student_Update = data.AllowStudentUpdate;
                    user.Allow_RadiologyAllList = data.RadiologyAllList;
                    user.Radiology_result_Approval = data.AllowRadiologyApproval;
                    user.AllowActiveItems = data.AllowActiveItems;
                    user.cashier = data.ddlcasher;
                    user.AllowRateEdit = data.AllowRateEdit;
                    membership.mobileno = data.Mobile;
                    membership.Email = data.Email;
                    membership.LoweredEmail = data.Email.ToLower();

                    db.SubmitChanges();
                    return "User Updated Successfully";

                }


                //NEW CREATE

                else if (userExists)
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

                newuser.ApplicationId = appID;
                newuser.UserId = userID;
                newuser.UserName = data.UserName;
                newuser.LoweredUserName = data.UserName.ToLower();
                newuser.mobileno = data.Mobile;
                if (string.IsNullOrEmpty(newuser.Gl_Account))
                {
                    newuser.Gl_Account = "0";
                }
                else
                {
                    newuser.Gl_Account = data.Accounts;
                }
                newuser.Gl_Account = data.Accounts;
                newuser.AllowPatientDelete = data.AllowPatientDelete;
                newuser.AllPatientRecords = data.AllPatientRecords;
                newuser.AllowPatientEdit = data.AllowPatientEdit;
                newuser.OTPUsers = data.OTPUsers;
                newuser.AllowTestRate = data.AllowTestRate;
                newuser.OpdAllow = data.AllowOPD;
                newuser.allow_lab = data.AllowLab;
                newuser.allow_ultra = data.AllowUltra;
                newuser.BlockUser = data.BlockUser; 
                newuser.AllowBillDelete = data.AllowBillDelete;
                newuser.allowtestbox = data.RateBox;
                newuser.allow_ctscan = data.AllowCtscan;
                newuser.allow_xray = data.AllowXray;
                newuser.allow_b_bank = data.AllowB_Bank;
                newuser.AllowPharmacy = data.AllowPharmacy;
                newuser.AllowGeneralItems = data.GeneralItems;
                newuser.IsShowBudget = data.ShowBudgetBtn;
                newuser.IsInventoryUnApprove = data.InventoryUnApprove;
                newuser.AllowToAccessAllTest = data.AllowToAccessAllTest;
                newuser.allow_cardio = data.AllowCardio;
                newuser.IsNotificationViewed = data.PRFsNotifications;
                newuser.AllowUnapproveVoucher = data.AllowUnapproveVouchers;
                newuser.IsAnonymous = data.IsAnonymous;
                newuser.EditEmergency = data.EditEmergency;
                newuser.Allow_bill_edit = data.AllowBillUpdate;
                newuser.Emergency_adm_dis = data.AllowEmergency_adm_dis;
                newuser.Radiology_result = data.AllowRadiologylist;
                newuser.Allow_emer_disc = data.AllowemergencyDiscount;
                newuser.Refer_IPD = data.AllowReferIPD;
                newuser.Allow_Recipe = data.AllowRecipe;
                newuser.AllowSaleReturn = data.AllowSaleReturn;
                newuser.Student_Update = data.AllowStudentUpdate;
                newuser.Allow_RadiologyAllList = data.RadiologyAllList;
                newuser.Radiology_result_Approval = data.AllowRadiologyApproval;
                newuser.AllowActiveItems = data.AllowActiveItems;
                newuser.cashier = data.ddlcasher;
                newuser.AllowRateEdit = data.AllowRateEdit;
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
                newUser_membership.mobileno = data.Mobile;
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

            return "User Created Successfully";
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
            public string UserIDfromURL { get; set; }
            public string UserName { get; set; }
            public string Email { get; set; }
            public string Password { get; set; }
            public string ConfirmPassword { get; set; }
            public string Mobile { get; set; }          // Added
            public string Accounts { get; set; }          // Added
            public string ddlcasher { get; set; }          // Added
            public string EmpCode { get; set; }         // Added

            public bool AllowPatientEdit { get; set; }
            public bool AllowPatientDelete { get; set; }
            public bool AllPatientRecords { get; set; }
            public bool AllowUnapproveVouchers { get; set; }
            public bool OTPUsers { get; set; }

            public bool AllowBillDelete { get; set; }
            public bool AllowTestRate { get; set; }
            public bool AllowOPD { get; set; }
            public bool AllowLab { get; set; }
            public bool AllowUltra { get; set; }
            public bool AllowCtscan { get; set; }
            public bool AllowXray { get; set; }
            public bool AllowB_Bank { get; set; }
            public bool AllowPharmacy { get; set; }
            public bool GeneralItems { get; set; }
            public bool ShowBudgetBtn { get; set; }
            public bool InventoryUnApprove { get; set; }
            public bool PRFsNotifications { get; set; }
            public bool RateBox { get; set; }
            public bool AllowToAccessAllTest { get; set; }
            public bool AllowCardio { get; set; }
            public bool IsAnonymous { get; set; }
            public bool EditEmergency { get; set; }
            public bool AllowEmergency_adm_dis { get; set; }
            public bool AllowRadiologylist { get; set; }
            public bool AllowReferIPD { get; set; }
            public bool AllowRecipe { get; set; }
            public bool AllowActiveItems { get; set; }
            public bool AllowSaleReturn { get; set; }
            public bool AllowStudentUpdate { get; set; }
            public bool RadiologyAllList { get; set; }
            public bool AllowRadiologyApproval { get; set; }
            public bool AllowRateEdit { get; set; }
            public bool AllowBillUpdate { get; set; }
            public bool BlockUser { get; set; }
            public bool AllowemergencyDiscount { get; set; }
        }

    }
}