using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Security;
using System.Data;
using System.Configuration;
using System;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web.Configuration;
using DB;
using System.Net;
using Newtonsoft.Json.Linq;
using System.Security.Cryptography;
using System.Net.PeerToPeer;

namespace PMS
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Session.Abandon();
                //ViewState["ReferrerUrl"] = Convert.ToString(Request.UrlReferrer);
                BindCompanies();
                VerifyPanel.Visible = false;
                forgot_pass_Panel.Visible = false;
                Panel_changePasword.Visible = false;
            }
        }

        private void BindCompanies()
        {
            DataTable dtbCompanies = new DataTable();
            dtbCompanies = DBClass.getDataTable("Select * from sys_Companys");
            DropDownList ddlCompany = (DropDownList)UserLogin.FindControl("ddlCompany");
            if (ddlCompany != null)
            {
                ddlCompany.DataSource = dtbCompanies;
                ddlCompany.DataTextField = "Company_Name";
                ddlCompany.DataValueField = "Company_ID";
                ddlCompany.Items.Add(new ListItem("Please Select", "0"));
                ddlCompany.DataBind();
                if (dtbCompanies.Rows.Count > 0)
                {
                    ddlCompany.SelectedValue = dtbCompanies.Rows[0]["Company_ID"].ToString();
                }
            }
        }


        protected void LoginUser_Authenticate(object sender, AuthenticateEventArgs e)
        {

        }
        //protected void LoginButton_Click(object sender, EventArgs e)
        //{
        //    string userName = UserLogin.UserName.Trim();
        //    string pass = UserLogin.Password.ToString();

        //    using (DataBaseDataContext db = new DataBaseDataContext())
        //    {
        //        var userExists = (from u in db.aspnet_Users
        //                          where u.UserName == userName
        //                          select u.UserId).FirstOrDefault();

        //        if (userExists != null)
        //        {
        //            var membershipRecord = (from m in db.aspnet_Memberships
        //                                    where m.UserId == userExists
        //                                    select new { m.Password, m.PasswordSalt }).FirstOrDefault();

        //            if (membershipRecord != null)
        //            {
        //                string hashedInputPassword = EncryptPassword(pass, membershipRecord.PasswordSalt);
        //                if (hashedInputPassword == membershipRecord.Password)
        //                {
        //                    ViewState["usrname"] = userName.Trim();
        //                    ViewState["psword"] = pass;

        //                    var block_user = (from a in db.aspnet_Users where a.UserName == userName.Trim() select a.BlockUser).FirstOrDefault();
        //                    var otp_user = (from a in db.aspnet_Users where a.UserName == userName.Trim() select a.OTPUsers).FirstOrDefault();
        //                    var mblnumber = (from a in db.aspnet_Users where a.UserName == userName.Trim() select a.mobileno).FirstOrDefault();

        //                    if (block_user == true)
        //                    {
        //                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", $"alert('{"User Blocked"}');", true);
        //                        return;

        //                    }

        //                    if (otp_user == true)
        //                    {
        //                        loginportion.Visible = false;
        //                        VerifyPanel.Visible = true;
        //                        if (!string.IsNullOrEmpty(mblnumber))
        //                        {
        //                            string session = "";
        //                            bool sentStatus = false;
        //                            string statusMsg = string.Empty;
        //                            Random random = new Random();
        //                            int value = random.Next(1001, 9999);
        //                            string masking = "TibbIT";
        //                            string message = "Verification Code:  " + value + "";
        //                            string message1 = HttpUtility.UrlEncode(message);
        //                            MyWebRequest myRequest = new MyWebRequest("https://connect.jazzcmt.com/sendsms_url.html?Username=03091893765&Password=XQoQwxAc&From=" + masking + "&To=" + mblnumber + "&Message=" + message1 + "");


        //                            string s = myRequest.GetResponse();


        //                            session = s;
        //                            Console.WriteLine(session); // Display in console
        //                            if (session.Contains("Message Sent"))
        //                            {
        //                                sentStatus = true;
        //                                session = "SMS Sent Successfully";
        //                            }
        //                            else
        //                            {
        //                                Console.WriteLine(session);
        //                                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", $"alert('{session}');", true);
        //                                session = "Error";
        //                                sentStatus = false;

        //                            }

        //                            // Display in console again
        //                            Console.WriteLine(session);

        //                            Session["OTP"] = value;
        //                        }
        //                        return;
        //                    }

        //                    var user_detail = Membership.GetUser(userName.Trim());
        //                    Session["MenuLoaded"] = false;
        //                    PasswordChangeAlter_ModalPopupExtender.Hide();

        //                    LoadUserDetail();
        //                }
        //                else
        //                {
        //                    // Password mismatch
        //                    // Show error message (e.g., "Invalid username or password.")
        //                }
        //            }
        //        }
        //    }
        //}
        protected void LoginButton_Click(object sender, EventArgs e)
        {
            string userName = UserLogin.UserName.Trim();
            string pass = UserLogin.Password.ToString();

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var userExists = (from u in db.aspnet_Users
                                  where u.UserName == userName
                                  select new { u.UserId, u.BlockUser, u.OTPUsers, u.mobileno }).FirstOrDefault();

                if (userExists == null)
                {
                    // No such user
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Invalid username or password.');", true);
                    return;
                }

                var membershipRecord = (from m in db.aspnet_Memberships
                                        where m.UserId == userExists.UserId
                                        select m).FirstOrDefault();

                if (membershipRecord == null)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Invalid username or password.');", true);
                    return;
                }

                // ✅ Check if account is already locked out
                // Check if account is locked out
                if (membershipRecord.IsLockedOut)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "accountLockedAlert", @"
                        Swal.fire({
                            icon: 'error',
                            title: 'Account Locked',
                            text: 'Account is locked due to too many failed login attempts. Contact administrator.',
                            timer: 2000,
                            showConfirmButton: false,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });", true);

                    return;
                }

                // ✅ Validate password manually
                string hashedInputPassword = EncryptPassword(pass, membershipRecord.PasswordSalt);
                if (hashedInputPassword == membershipRecord.Password)
                {
                    // ✅ CORRECT PASSWORD: Reset failed attempts and unlock if needed
                    membershipRecord.FailedPasswordAttemptCount = 0;
                    membershipRecord.LastLoginDate = DateTime.Now;
                    membershipRecord.LastLoginDate = DateTime.Now;
                    if (membershipRecord.IsLockedOut)
                        membershipRecord.IsLockedOut = false;

                    db.SubmitChanges(); // Save reset

                    // Store in ViewState (avoid storing password ideally)
                    ViewState["usrname"] = userName;
                    ViewState["psword"] = pass;

                    // Check block/OTP status
                    if (userExists.BlockUser == true)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('User Blocked');", true);
                        return;
                    }

                    if (userExists.OTPUsers == true)
                    {
                        loginportion.Visible = false;
                        VerifyPanel.Visible = true;

                        if (!string.IsNullOrEmpty(userExists.mobileno))
                        {
                            Random random = new Random();
                            int otp = random.Next(1001, 9999);
                            string message = "Verification Code: " + otp;
                            string encodedMessage = HttpUtility.UrlEncode(message);
                            string masking = "TibbIT";
                            string apiUrl = $"https://connect.jazzcmt.com/sendsms_url.html?Username=03091893765&Password=XQoQwxAc&From={masking}&To={userExists.mobileno}&Message={encodedMessage}";

                            MyWebRequest myRequest = new MyWebRequest(apiUrl);
                            string response = myRequest.GetResponse();

                            if (response.Contains("Message Sent"))
                            {
                                Session["OTP"] = otp;
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", $"alert('SMS failed: {response}');", true);
                                return;
                            }
                        }
                        return;
                    }

                    // Load user session
                    Session["MenuLoaded"] = false;
                    PasswordChangeAlter_ModalPopupExtender.Hide();
                    LoadUserDetail();
                }
                else
                {
                    // ❌ WRONG PASSWORD: Increment failed attempts
                    membershipRecord.FailedPasswordAttemptCount += 1;
                    membershipRecord.LastLoginDate = DateTime.Now;

                    // Lock account if 10 or more failed attempts
                    if (membershipRecord.FailedPasswordAttemptCount >= 10)
                    {
                        membershipRecord.IsLockedOut = true;

                        string lockScript = @"
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Account Locked',
                                    text: 'Account locked after 10 failed attempts.',
                                    timer: 2000,
                                    showConfirmButton: false,
                                    customClass: {
                                        popup: 'swal-big-popup',
                                        title: 'swal-big-title',
                                        htmlContainer: 'swal-big-text'
                                    }
                                });";

                        ScriptManager.RegisterStartupScript(this, this.GetType(), "accountLocked", lockScript, true);
                    }
                    else
                    {
                        int remaining = 10 - membershipRecord.FailedPasswordAttemptCount;

                        string script = $@"
                            Swal.fire({{
                                icon: 'warning',
                                title: 'Invalid Password',
                                text: 'Invalid password. {remaining} attempt(s) remaining.',
                                timer: 2000,
                                showConfirmButton: false,
                                customClass: {{
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }}
                            }});";

                        ScriptManager.RegisterStartupScript(this, this.GetType(), "passwordWarning", script, true);
                    }

                    // Save changes to DB
                    db.SubmitChanges();
                }
            }
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




        private void LoadUserDetail()
        {
            MembershipUser u = Membership.GetUser("");
            

            string username = Convert.ToString(ViewState["usrname"]);
            string password = Convert.ToString(ViewState["psword"]);
            Session["UNChnagePassword"] = username;
            string Book_ID = DBClass.getField("Select Book_ID From sys_Companys Where Company_ID=" + Convert.ToInt32(((DropDownList)UserLogin.FindControl("ddlCompany")).SelectedValue));

                Session.Add("UserName", ((TextBox)UserLogin.FindControl("UserName")).Text);
                Session.Add("Company_Name", ((DropDownList)UserLogin.FindControl("ddlCompany")).SelectedItem.Text);
                Session.Add("Company_ID", ((DropDownList)UserLogin.FindControl("ddlCompany")).SelectedValue);
                Session.Add("Book_ID", Book_ID);

                System.Web.Security.MembershipUser user = System.Web.Security.Membership.GetUser(AppConfig.UserName);
                Session.Add("UserID", user.ProviderUserKey.ToString());
                String[] roleList = System.Web.Security.Roles.GetRolesForUser(UserLogin.UserName);

                string roles = "";
                foreach (string role in roleList)
                {
                    roles = roles + "," + role;

                }
                if (roles != "")
                {
                    string LoginDuration = WebConfigurationManager.AppSettings["LoginDuration"].ToString();
                    int duration = 50;
                    if (LoginDuration != "")

                        duration = Convert.ToInt32(LoginDuration);
                    Session.Timeout = duration;

                    FormsAuthenticationTicket ticket = new FormsAuthenticationTicket(1, Session["UserName"].ToString(), DateTime.Now,
                           DateTime.Now.AddMinutes(duration), false, roles.Substring(1, roles.Length - 1), FormsAuthentication.FormsCookiePath);

                    string hashCookies = FormsAuthentication.Encrypt(ticket);
                    HttpCookie cookie = new HttpCookie(FormsAuthentication.FormsCookieName, hashCookies);
                    Response.Cookies.Add(cookie);
                }
                else
                {
                    FormsAuthenticationTicket ticket = new FormsAuthenticationTicket(1, Session["UserName"].ToString(), DateTime.Now,
                           DateTime.Now.AddMinutes(360), false, "User", FormsAuthentication.FormsCookiePath);

                    string hashCookies = FormsAuthentication.Encrypt(ticket);
                    HttpCookie cookie = new HttpCookie(FormsAuthentication.FormsCookieName, hashCookies);
                    Response.Cookies.Add(cookie);
                }
                object ReferrerUrl = ViewState["ReferrerUrl"];
                if (ReferrerUrl != null && Convert.ToString(ViewState["ReferrerUrl"]) != "")
                {
                    if (!ReferrerUrl.ToString().Contains("Login.aspx"))
                    {
                        Response.Redirect((string)ReferrerUrl, false);
                    }
                    else
                    {
                        Response.Redirect("~/Modules/Dashboards/ShortCuts.aspx", false);
                    }
                }
                else
                {
                Response.Redirect("~/Modules/Dashboards/ShortCuts.aspx", false);
            }
            //}
        }

        protected void btnmessageOk_Click(object sender, EventArgs e)
        {

        }

        protected void btnverify_Click(object sender, EventArgs e)
        {
            string enteredOtp = otp1.Text + otp2.Text + otp3.Text + otp4.Text;
            if (enteredOtp == Session["OTP"].ToString())
            {
                //txtOtp.Visible = false;
                //ScriptManager.RegisterStartupScript(this, typeof(string), "Message", "confirm('Your Mobilenumber has been verify sccessfully.');", true);
                LoadUserDetail();
            }
            else
            {
                otpError.InnerText = "Invalid PassCode.";
            }
        }
        protected void btnCancel_Click(object sender, EventArgs e)
        {
            // Reload the current page
            Response.Redirect(Request.RawUrl);
        }
        protected void forgetPassword_Click(object sender, EventArgs e)
        {
            string userName = UserLogin.UserName.Trim();
            VerifyPanel.Visible = false;
            loginportion.Visible = false;
            forgot_pass_Panel.Visible = true;
            DataBaseDataContext db = new DataBaseDataContext();
            txtPhone.Text = (from a in db.aspnet_Users where a.UserName == userName.Trim() select a.mobileno).FirstOrDefault();
            txtPhone.ReadOnly = true;
        }

        protected void btnrequestOTP(object sender, EventArgs e)
        {
            string userName = UserLogin.UserName.Trim();
            string userid = UserLogin.ID.Trim();


            DataBaseDataContext db = new DataBaseDataContext();

            var block_user = (from a in db.aspnet_Users where a.UserName == userName.Trim() select a.BlockUser).FirstOrDefault();
            var otp_user = (from a in db.aspnet_Users where a.UserName == userName.Trim() select a.OTPUsers).FirstOrDefault();
            var mblnumber = (from a in db.aspnet_Users where a.UserName == userName.Trim() select a.mobileno).FirstOrDefault();

            if (block_user == true)
            {

                return;
            }
            if(block_user == false)
            {
                VerifyPanel.Visible = false;
                forgot_pass_Panel.Visible = false;
                Panel_changePasword.Visible = true;

                if (!string.IsNullOrEmpty(mblnumber))
                {
                    string session = "";
                    bool sentStatus = false;
                    string statusMsg = string.Empty;
                    Random random = new Random();
                    int value = random.Next(1001, 9999);
                    string masking = "TibbIT";
                    string message = "Verification Code:  " + value + "";
                    string message1 = HttpUtility.UrlEncode(message);
                    MyWebRequest myRequest = new MyWebRequest("https://connect.jazzcmt.com/sendsms_url.html?Username=03091893765&Password=XQoQwxAc&From=" + masking + "&To=" + mblnumber + "&Message=" + message1 + "");


                    string s = myRequest.GetResponse();
                    

                    session = s;
                    Console.WriteLine(session); // Display in console
                    if (session.Contains("Message Sent"))
                    {
                        sentStatus = true;
                        session = "SMS Sent Successfully";
                        Console.WriteLine(session);
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", $"alert('{session}');", true);
                    }
                    else
                    {
                        Console.WriteLine(session);
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", $"alert('{session}');", true);
                        session = "Error";
                        sentStatus = false;

                    }

                    // Display in console again
                    Console.WriteLine(session);

                    // Show alert in browser
                  

                    Session["OTP"] = value;
                }


                return;
            }
            
              
         

            var user_detail = Membership.GetUser(userName.Trim());
            Session["MenuLoaded"] = false;
            PasswordChangeAlter_ModalPopupExtender.Hide();
          


            LoadUserDetail();

        }

        protected void btnverify_Click_changePass(object sender, EventArgs e)
        {
            string enteredOtp = pass1.Text + pass2.Text + pass3.Text + pass4.Text;
            if (enteredOtp == Session["OTP"].ToString())
            {
                string userName = UserLogin.UserName.Trim();
                Session["UNChnagePassword"] = userName;
                //txtOtp.Visible = false;
                //ScriptManager.RegisterStartupScript(this, typeof(string), "Message", "confirm('Your Mobilenumber has been verify sccessfully.');", true);
                Response.Redirect("~/Modules/Accounts/ChangePassword.aspx", true);
            }
            else
            {
                otpChangePassError.InnerText = "Invalid PassCode.";
            }
        }

    }
}
