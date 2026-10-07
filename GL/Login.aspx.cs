using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Security;
using System.Data;
using System.Configuration;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web.Configuration;
using DB;
using System.Net;
using Newtonsoft.Json.Linq;
using System.Security.Cryptography;

namespace PMS
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Session.Abandon();
                BindCompanies();
                VerifyPanel.Visible = false;
                forgot_pass_Panel.Visible = false;
                Panel_changePasword.Visible = false;
            }
        }

        private void BindCompanies()
        {
            DataTable dtbCompanies = DBClass.getDataTable("Select * from sys_Companys");
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
                ddlCompany.Attributes.Add("onchange", "javascript:__doPostBack('" + ddlCompany.UniqueID + "','')");
            }
        }


        protected void LoginUser_Authenticate(object sender, AuthenticateEventArgs e)
        {
            // Not used — logic handled in LoginButton_Click
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            ApplyCompanyBranding();
        }

        // Brand panel (logo + company name) follows the company chosen in the dropdown.
        // The logo is the file the Add Company form saves in ~/wwwroot/CompanyImages
        // (path kept in sys_Companys.ImageURL). Falls back to the active theme's own logo
        // when the company has no uploaded image or the file is missing.
        protected global::System.Web.UI.WebControls.Image imgBrandLogo;
        protected global::System.Web.UI.WebControls.Label lblBrandCompany;
        private void ApplyCompanyBranding()
        {
            if (imgBrandLogo == null) return;

            string defaultLogoUrl = CompanyLogo.GetDefaultUrl(true);   // active theme's own logo
            string logoUrl = defaultLogoUrl;
            string companyName = string.Empty;

            DropDownList ddlCompany = UserLogin.FindControl("ddlCompany") as DropDownList;
            int companyId;
            if (ddlCompany != null && int.TryParse(ddlCompany.SelectedValue, out companyId) && companyId > 0)
            {
                companyName = ddlCompany.SelectedItem.Text;
                logoUrl = CompanyLogo.GetUrlOrNull(companyId) ?? defaultLogoUrl;
            }

            imgBrandLogo.ImageUrl = logoUrl;
            imgBrandLogo.AlternateText = string.IsNullOrEmpty(companyName) ? "Company logo" : companyName;
            lblBrandCompany.Text = Server.HtmlEncode(companyName);
        }

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
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Invalid username or password.');", true);
                    return;
                }

                var membershipRecord = (from m in db.aspnet_Memberships
                                        where m.UserId == userExists.UserId
                                        select m).FirstOrDefault();

                if (membershipRecord == null)
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Invalid username or password.');", true);
                    return;
                }

                if (membershipRecord.IsLockedOut)
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "accountLockedAlert", @"
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

                string hashedInputPassword = EncryptPassword(pass, membershipRecord.PasswordSalt);
                if (hashedInputPassword == membershipRecord.Password)
                {
                    // ✅ SUCCESS → RESET COUNTER
                    membershipRecord.FailedPasswordAttemptCount = 0;
                    membershipRecord.LastLoginDate = DateTime.Now;
                    if (membershipRecord.IsLockedOut)
                        membershipRecord.IsLockedOut = false;

                    var userRecord = db.aspnet_Users.FirstOrDefault(u => u.UserId == userExists.UserId);
                    if (userRecord != null)
                    {
                        userRecord.LastActivityDate = DateTime.Now;
                    }
                    db.SubmitChanges();

                    // 👇 PROCEED WITH LOGIN FLOW
                    ViewState["usrname"] = userName;
                    ViewState["psword"] = pass;

                    if (userExists.BlockUser == true)
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('User Blocked');", true);
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
                                ScriptManager.RegisterStartupScript(this, GetType(), "alert", $"alert('SMS failed: {response}');", true);
                                return;
                            }
                        }
                        return;
                    }

                    string Book_ID = DBClass.getField("Select Book_ID From sys_Companys Where Company_ID=" + Convert.ToInt32(((DropDownList)UserLogin.FindControl("ddlCompany")).SelectedValue));

                    Session["MenuLoaded"] = false;
                    Session["UNChnagePassword"] = userName;
                    Session["UserName"] = ((TextBox)UserLogin.FindControl("UserName")).Text;
                    Session["Company_Name"] = ((DropDownList)UserLogin.FindControl("ddlCompany")).SelectedItem.Text;
                    Session["Company_ID"] = ((DropDownList)UserLogin.FindControl("ddlCompany")).SelectedValue;
                    Session["Book_ID"] = Book_ID;
                    Session["PwdStamp"] = membershipRecord.Password;

                    MembershipUser user = Membership.GetUser(userName);
                    if (user != null)
                    {
                        Session["UserID"] = user.ProviderUserKey.ToString();
                    }

                    string[] roleList = Roles.GetRolesForUser(userName);
                    string roles = string.Join(",", roleList);

                    int duration = 50;
                    string LoginDuration = WebConfigurationManager.AppSettings["LoginDuration"];
                    if (!string.IsNullOrEmpty(LoginDuration))
                        duration = Convert.ToInt32(LoginDuration);

                    Session.Timeout = duration;

                    FormsAuthenticationTicket ticket = new FormsAuthenticationTicket(
                        1,
                        userName,
                        DateTime.Now,
                        DateTime.Now.AddMinutes(duration),
                        false,
                        roles,
                        "/");

                    string hashCookies = FormsAuthentication.Encrypt(ticket);
                    HttpCookie authCookie = new HttpCookie(FormsAuthentication.FormsCookieName, hashCookies)
                    {
                        HttpOnly = true,
                        Secure = Request.IsSecureConnection,
                        Path = "/",
                        Expires = ticket.Expiration,
                        SameSite = System.Web.SameSiteMode.Strict
                    };

                    Response.Cookies.Set(authCookie);

                    object ReferrerUrl = ViewState["ReferrerUrl"];
                    string redirectUrl = "~/Modules/Dashboards/ShortCuts.aspx";
                    if (ReferrerUrl != null && !string.IsNullOrEmpty(Convert.ToString(ReferrerUrl)) && !ReferrerUrl.ToString().Contains("Login.aspx"))
                    {
                        redirectUrl = (string)ReferrerUrl;
                    }

                    Response.Redirect(redirectUrl, true);
                }
                else
                {
                    // ❌ WRONG PASSWORD
                    membershipRecord.FailedPasswordAttemptCount += 1;
                    membershipRecord.LastLoginDate = DateTime.Now;

                    int currentAttempt = membershipRecord.FailedPasswordAttemptCount;

                    if (currentAttempt >= 7)
                    {
                        membershipRecord.IsLockedOut = true;

                        string lockScript = @"
Swal.fire({
    icon: 'error',
    title: 'Account Locked',
    text: 'Account locked after 7 failed attempts.',
    timer: 2000,
    showConfirmButton: false,
    customClass: {
        popup: 'swal-big-popup',
        title: 'swal-big-title',
        htmlContainer: 'swal-big-text'
    }
});";

                        ScriptManager.RegisterStartupScript(this, GetType(), "accountLocked", lockScript, true);
                    }
                    else if (currentAttempt >= 5) // 5th and 6th attempt
                    {
                        // ✅ SHOW "Too many attempts" + DISABLE BUTTON FOR 60s
                        string message = "Too many login attempts. Please wait 1 minute.";

                        string script = $@"
setTimeout(function() {{
    if (typeof Swal !== 'undefined') {{
        Swal.fire({{
            icon: 'error',
            title: 'Too Many Attempts',
            text: '{message.Replace("'", "\\'")}',
            timer: 60000,
            showConfirmButton: false,
            customClass: {{
                popup: 'swal-big-popup',
                title: 'swal-big-title',
                htmlContainer: 'swal-big-text'
            }}
        }});
    }} else {{
        alert('{message.Replace("'", "\\'")}');
    }}

    var loginButton = document.getElementById('{((Button)sender).ClientID}');
    if (loginButton) {{
        loginButton.disabled = true;
        loginButton.value = 'Wait 60s...';

        let timeLeft = 60;
        const timer = setInterval(() => {{
            timeLeft--;
            loginButton.value = 'Wait ' + timeLeft + 's...';
            if (timeLeft <= 0) {{
                clearInterval(timer);
                loginButton.disabled = false;
                loginButton.value = 'LOGIN';
                if (typeof Swal !== 'undefined') {{
                    Swal.fire({{
                        icon: 'success',
                        title: 'Ready to Try Again',
                        text: 'You may now attempt to log in.',
                        timer: 3000,
                        showConfirmButton: false
                    }});
                }}
            }}
        }}, 1000);
    }}
}}, 100);";

                        ScriptManager.RegisterStartupScript(this, GetType(), "rateLimit5", script, true);
                    }
                    else // 1st to 4th attempt
                    {
                        int remaining = 7 - currentAttempt;

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

                        ScriptManager.RegisterStartupScript(this, GetType(), "passwordWarning", script, true);
                    }

                    db.SubmitChanges();
                    return;
                }
            }
        }

        private string EncryptPassword(string password, string salt)
        {
            var combinedPasswordSalt = password + salt;
            using (var sha1 = SHA1.Create())
            {
                byte[] bytes = Encoding.UTF8.GetBytes(combinedPasswordSalt);
                byte[] hash = sha1.ComputeHash(bytes);
                return Convert.ToBase64String(hash);
            }
        }

        private void LoadUserDetail()
        {
            string username = Convert.ToString(ViewState["usrname"]);
            string password = Convert.ToString(ViewState["psword"]);
            Session["UNChnagePassword"] = username;

            TextBox userNameTextBox = (TextBox)UserLogin.FindControl("UserName");
            DropDownList ddlCompany = (DropDownList)UserLogin.FindControl("ddlCompany");

            if (ddlCompany == null || userNameTextBox == null)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "controlError", "alert('Required login controls not found.');", true);
                return;
            }
            // UPDATE LAST ACTIVITY DATE IN DATABASE FOR OTP USERS
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var userRecord = db.aspnet_Users.FirstOrDefault(u => u.UserName == username);
                if (userRecord != null)
                {
                    userRecord.LastActivityDate = DateTime.Now;
                    Session["PwdStamp"] = (from m in db.aspnet_Memberships
                                           where m.UserId == userRecord.UserId
                                           select m.Password).FirstOrDefault();
                    db.SubmitChanges();
                }
            }
            string Book_ID = DBClass.getField("Select Book_ID From sys_Companys Where Company_ID=" + Convert.ToInt32(ddlCompany.SelectedValue));

            Session["UserName"] = userNameTextBox.Text;
            Session["Company_Name"] = ddlCompany.SelectedItem.Text;
            Session["Company_ID"] = ddlCompany.SelectedValue;
            Session["Book_ID"] = Book_ID;

            MembershipUser user = Membership.GetUser(username);
            if (user != null)
            {
                Session["UserID"] = user.ProviderUserKey.ToString();
            }

            string[] roleList = Roles.GetRolesForUser(username);
            string roles = string.Join(",", roleList);

            int duration = 50;
            string LoginDuration = WebConfigurationManager.AppSettings["LoginDuration"];
            if (!string.IsNullOrEmpty(LoginDuration))
                duration = Convert.ToInt32(LoginDuration);

            Session.Timeout = duration;

            FormsAuthenticationTicket ticket = new FormsAuthenticationTicket(
                1,
                username,
                DateTime.Now,
                DateTime.Now.AddMinutes(duration),
                false,
                roles,
                FormsAuthentication.FormsCookiePath);

            string hashCookies = FormsAuthentication.Encrypt(ticket);
            HttpCookie cookie = new HttpCookie(FormsAuthentication.FormsCookieName, hashCookies);
            Response.Cookies.Add(cookie);

            object ReferrerUrl = ViewState["ReferrerUrl"];
            string redirectUrl = "~/Modules/Dashboards/ShortCuts.aspx";
            if (ReferrerUrl != null && !string.IsNullOrEmpty(Convert.ToString(ReferrerUrl)) && !ReferrerUrl.ToString().Contains("Login.aspx"))
            {
                redirectUrl = (string)ReferrerUrl;
            }

            Response.Redirect(redirectUrl, false);
        }

        protected void btnmessageOk_Click(object sender, EventArgs e)
        {
        }

        protected void btnverify_Click(object sender, EventArgs e)
        {
            string enteredOtp = otp1.Text + otp2.Text + otp3.Text + otp4.Text;
            if (enteredOtp == Session["OTP"].ToString())
            {
                LoadUserDetail();
            }
            else
            {
                otpError.InnerText = "Invalid PassCode.";
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect(Request.RawUrl);
        }

        protected void forgetPassword_Click(object sender, EventArgs e)
        {
            string userName = UserLogin.UserName.Trim();
            VerifyPanel.Visible = false;
            loginportion.Visible = false;
            forgot_pass_Panel.Visible = true;
            using (var db = new DataBaseDataContext())
            {
                txtPhone.Text = (from a in db.aspnet_Users where a.UserName == userName.Trim() select a.mobileno).FirstOrDefault();
                txtPhone.ReadOnly = true;
            }
        }

        protected void btnrequestOTP(object sender, EventArgs e)
        {
            string userName = UserLogin.UserName.Trim();
            using (var db = new DataBaseDataContext())
            {
                var mblnumber = (from a in db.aspnet_Users where a.UserName == userName.Trim() select a.mobileno).FirstOrDefault();

                if (!string.IsNullOrEmpty(mblnumber))
                {
                    int value = new Random().Next(1001, 9999);
                    string masking = "TibbIT";
                    string message = HttpUtility.UrlEncode("Verification Code: " + value);
                    string url = $"https://connect.jazzcmt.com/sendsms_url.html?Username=03091893765&Password=XQoQwxAc&From={masking}&To={mblnumber}&Message={message}";

                    string response = new MyWebRequest(url).GetResponse();

                    if (response.Contains("Message Sent"))
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('SMS Sent Successfully');", true);
                        Session["OTP"] = value;
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "alert", $"alert('SMS failed: {response}');", true);
                        return;
                    }
                }
            }

            VerifyPanel.Visible = false;
            forgot_pass_Panel.Visible = false;
            Panel_changePasword.Visible = true;
        }

        protected void btnverify_Click_changePass(object sender, EventArgs e)
        {
            string enteredOtp = pass1.Text + pass2.Text + pass3.Text + pass4.Text;
            if (enteredOtp == Session["OTP"].ToString())
            {
                Session["UNChnagePassword"] = UserLogin.UserName.Trim();
                Response.Redirect("~/Modules/Accounts/ChangePassword.aspx", true);
            }
            else
            {
                otpChangePassError.InnerText = "Invalid PassCode.";
            }
        }
    }
}
