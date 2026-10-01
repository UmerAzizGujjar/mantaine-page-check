<%@ Page Title="Log In" Language="C#" MasterPageFile="~/SiteNoMenu.master" AutoEventWireup="true"
    CodeBehind="Login.aspx.cs" Inherits="PMS.Login" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<asp:Content ID="HeaderContent" runat="server" ContentPlaceHolderID="HeadContent">

    <link href="wwwroot/THEME_TIBBIT/CustomCSS/login.css" rel="stylesheet" />
    <link href="wwwroot/THEME_TIBBIT/theme-colors.css" rel="stylesheet" />
    <script src="wwwroot/lib/sweetalert/swalalert.js"></script>
    <link href="wwwroot/lib/sweetalert/swalalert.css" rel="stylesheet" />
    
    <!-- Font Awesome for eye icon -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    
    <style type="text/css">
        /* Hide upper elements to reduce space */
        .failureNotification {
            display: none !important;
        }
        
        .login {
            margin-top: -10px !important;
        }
        
        .header_login {
            margin-top: 0px !important;
            margin-bottom: 5px !important;
        }
        
        .login hr {
            margin-top: 5px !important;
            margin-bottom: 10px !important;
        }
        
        /* Password container with eye icon */
        .password-container {
            position: relative;
            width: 100%;
        }
        
        .password-container .passwordEntry {
            width: 100%;
            padding-right: 35px !important;
        }
        
   .toggle-password {
    position: absolute;
    right: 16px;
    top: 59%;
    transform: translateY(-50%);
    cursor: pointer;
    color: #999;
    z-index: 10;
   color:black;
    padding: 0 5px;
}
        
        .toggle-password:hover {
            color: #333;
        }
    </style>

    <style type="text/css">
        /* ===== Modern login card ===== */
        html body#contbod {
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            justify-content: center;
            padding: 24px 8vw;
            min-height: 100vh;
        }

        html body#contbod .wrapper {
            position: relative !important;
            top: auto !important;
            right: auto !important;
            left: auto !important;
            transform: none !important;
            margin: 0 !important;
            width: 100% !important;
            max-width: 440px !important;
            padding: 30px 34px 22px !important;
            background: linear-gradient(var(--theme-accent, #EFA63E), var(--theme-accent, #EFA63E)) top / 100% 5px no-repeat, #ffffff;
            border: 0 !important;
            border-radius: 18px !important;
            box-shadow: 0 24px 60px rgba(20, 32, 60, 0.20), 0 2px 8px rgba(20, 32, 60, 0.08);
            text-align: left;
        }

        /* undo the old fixed 455px table + row hacks */
        #ctl00_MainContent_UserLogin,
        #ctl00_MainContent_UserLogin table {
            width: 100% !important;
            background: transparent !important;
            border: 0 !important;
        }

        #ctl00_MainContent_UserLogin td { padding: 0 !important; }

        .main .login .row,
        .login .row { margin-left: 0 !important; margin-right: 0 !important; }

        .login [class*="col-"] { padding-left: 0; padding-right: 0; }

        .login { margin-top: 0 !important; border: 0; padding: 0; min-width: 0; }
        .login hr, .login br { display: none !important; }

        .login img { display: block; margin: 0 auto 4px; max-width: 200px !important; }

        .login .header_login {
            font-family: "Open Sans", sans-serif;
            font-size: 28px !important;
            font-weight: 700;
            color: #1b2a41 !important;
            text-align: center;
            margin: 6px 0 4px !important;
        }

        .login .login-sub {
            text-align: center;
            font-size: 14px;
            color: #6b7686;
            margin: 0 0 18px !important;
        }

        .login .labels {
            display: block;
            margin: 14px 0 0;
            font-size: 13px;
            font-weight: 600;
            color: #1b2a41 !important;
        }

        .login select,
        .login input.textEntry,
        .login input.passwordEntry {
            display: block;
            width: 100% !important;
            height: 46px;
            margin-top: 6px;
            padding: 0 14px;
            font-size: 15px;
            color: #1b2a41;
            background: #f6f8fb;
            border: 1.5px solid #d6dce5 !important;
            border-radius: 10px !important;
            box-shadow: none;
            transition: border-color .15s ease, box-shadow .15s ease, background-color .15s ease;
        }

        .login input.passwordEntry { padding-right: 44px !important; }

        .login select:hover,
        .login input.textEntry:hover,
        .login input.passwordEntry:hover { border: 1.5px solid #c3ccd8 !important; }

        .login select:focus,
        .login input.textEntry:focus,
        .login input.passwordEntry:focus {
            outline: 0;
            background: #ffffff;
            border: 1.5px solid var(--theme-accent, #EFA63E) !important;
            box-shadow: 0 0 0 4px var(--theme-accent-ring, rgba(239, 166, 62, 0.22));
        }

        .password-container { position: relative; }

        .toggle-password {
            top: calc(50% + 3px);
            right: 14px;
            color: #6b7686 !important;
            font-size: 15px;
        }

        .toggle-password:hover { color: #1b2a41 !important; }

        /* validation messages */
        .login span[id*="Required"], .login span[id*="RequiredFieldValidator"] {
            display: block;
            margin-top: 4px;
            font-size: 12px;
            color: #c0392b;
        }

        .login .forgot-password-link {
            display: block;
            margin-top: 10px;
            text-align: right;
            font-size: 13px;
            text-decoration: none;
        }

            .login .forgot-password-link span {
                font-weight: 600;
                color: #2b6cb0;
            }

            .login .forgot-password-link:hover span { color: #1b2a41; text-decoration: underline; }

        /* sign in button */
        .main .submitButton { margin: 20px 0 0; }

        html body#contbod .main .submitButton input,
        html body#contbod #ctl00_MainContent_UserLogin_LoginButton {
            display: block;
            width: 100% !important;
            height: 48px !important;
            margin: 0 !important;
            border: 0 !important;
            border-radius: 10px !important;
            background: linear-gradient(180deg, var(--theme-accent-light, #F4B653) 0%, var(--theme-accent, #EFA63E) 100%) !important;
            color: var(--theme-on-accent, #1b2a41) !important;
            font-size: 15px;
            font-weight: 700;
            letter-spacing: 1.2px;
            text-transform: uppercase;
            box-shadow: 0 6px 16px var(--theme-accent-shadow, rgba(239, 166, 62, 0.45)) !important;
            transition: transform .12s ease, box-shadow .12s ease, background .12s ease, color .12s ease;
        }

        html body#contbod .main .submitButton input:hover,
        html body#contbod #ctl00_MainContent_UserLogin_LoginButton:hover {
            background: #1b2a41 !important;
            color: #ffffff !important;
            transform: translateY(-1px);
            box-shadow: 0 8px 20px rgba(27, 42, 65, 0.35) !important;
        }

        /* contact footer inside the card */
        html body#contbod .wrapper #toBeHidden {
            display: block !important;
            border: 0 !important;
            border-top: 1px solid #e6eaf0 !important;
            margin: 22px 0 12px !important;
        }

        html body#contbod .wrapper .center {
            margin-top: 0 !important;
            text-align: center !important;
            font-size: 12.5px;
            line-height: 1.7;
            color: #6b7686 !important;
        }

            html body#contbod .wrapper .center strong { color: #1b2a41; }

            html body#contbod .wrapper .center a { color: #2b6cb0 !important; }

        /* OTP / forgot-password panels */
        #otpContainer, #changepassowrd { display: flex; justify-content: center; gap: 12px; margin: 12px 0; }

        #otp1, #otp2, #otp3, #otp4, #pass1, #pass2, #pass3, #pass4 {
            height: 52px;
            border: 1.5px solid #d6dce5 !important;
            border-radius: 10px !important;
        }

        html body#contbod .wrapper form br { display: none; }

        /* mid and small screens: centre the card on a soft background */
        @media (max-width: 1280px) {
            html body#contbod {
                align-items: center;
                padding: 24px 16px;
                background: linear-gradient(135deg, #fff6e6 0%, #eef2f8 100%) !important;
            }

            /* developer credit: flow under the card instead of floating over it */
            html body#contbod > div[style*="position: fixed"] {
                position: static !important;
                margin-top: 16px;
                text-align: center !important;
            }
        }

        @media (max-width: 480px) {
            html body#contbod .wrapper { padding: 24px 20px 18px !important; border-radius: 14px !important; }
            .login .header_login { font-size: 24px !important; }
        }
    </style>
   
</asp:Content>
<asp:Content ID="BodyContent" runat="server" ContentPlaceHolderID="MainContent">
    <asp:ToolkitScriptManager ID="ToolkitScriptManager1" runat="server"></asp:ToolkitScriptManager>

    <asp:UpdatePanel runat="server" ID="upForm" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:ModalPopupExtender ID="PasswordChangeAlter_ModalPopupExtender" runat="server" DynamicServicePath=""
                BackgroundCssClass="popupBackground" TargetControlID="hdnmessageCancel"
                PopupControlID="messagePanel">
            </asp:ModalPopupExtender>
            <div runat="server" id="loginportion">
                <asp:Login ID="UserLogin" runat="server" Width="455px" BackColor="#EFF3FB" BorderColor="#B5C7DE" BorderPadding="4" BorderStyle="Solid" BorderWidth="1px" Font-Names="Verdana" Font-Size="0.8em" ForeColor="#333333" OnAuthenticate="LoginUser_Authenticate">
                    <InstructionTextStyle Font-Italic="True" ForeColor="Black" />
                    <LayoutTemplate>
                        <span class="failureNotification">
                            <asp:Literal ID="FailureText" runat="server"></asp:Literal>
                        </span>
                    
                        <div class="accountInfo" style="">
                            <fieldset class="login">
                                <div style="text-align: center; margin-bottom: 10px;">
                                    <asp:Image ID="imgCompanyLogo" runat="server" 
                                        ImageUrl="~/wwwroot/THEME_TIBBIT/images/LOGOS/logo.png" 
                                        AlternateText="Company Logo" 
                                        Visible="true"
                                        Style="max-width: 250px; height: auto;" />
                                </div>
                                <h2 class="header_login">Welcome Back</h2>
                                <p class="login-sub">Enter your username and password to sign in.</p>
                                <hr />
                                <div class="row">
                                    <div class="col-lg-2 col-md-4 col-sm-6">
                                        <asp:Label ID="UserNameLabel" CssClass="labels" runat="server" AssociatedControlID="UserName">Username:</asp:Label>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-lg-12 col-md-12 col-sm-12">
                                        <asp:TextBox ID="UserName" runat="server" autocomplete="off" CssClass="textEntry"></asp:TextBox>
                                        <p id="ErrorUserName"></p>
                                        <asp:RequiredFieldValidator ID="UserNameRequired" runat="server" ControlToValidate="UserName"
                                            CssClass="" ErrorMessage="UserName is required." ToolTip="User Name is required." ValidationGroup="LoginUserValidationGroup" Display="Dynamic" EnableClientScript="false"></asp:RequiredFieldValidator>
                                    </div>

                                </div>
                                <div class="row">
                                    <div class="col-lg-2 col-md-4 col-sm-6">
                                        <asp:Label ID="PasswordLabel"  CssClass="labels" runat="server" AssociatedControlID="Password">Password:</asp:Label>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-lg-12 col-md-12 col-sm-12">
                                        <div class="password-container">
                                            <asp:TextBox ID="Password" autocomplete="off" runat="server" CssClass="passwordEntry" TextMode="Password"></asp:TextBox>
                                            <i class="fas fa-eye toggle-password" id="togglePasswordIcon"></i>
                                        </div>
                                        <br />
                                        <p id="ErrorPassword"></p>
                                        <asp:RequiredFieldValidator ID="PasswordRequired" runat="server" ControlToValidate="Password"
                                            CssClass="" ErrorMessage="Password is required." ToolTip="Password is required."
                                            ValidationGroup="LoginUserValidationGroup" Display="Dynamic" EnableClientScript="false"></asp:RequiredFieldValidator>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-lg-2 col-md-4 col-sm-6">
                                        <asp:Label ID="Label1" runat="server"  CssClass="labels" AssociatedControlID="ddlCompany">Company:</asp:Label>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-lg-12 col-md-12 col-sm-12">
                                        <asp:DropDownList runat="server"  ID="ddlCompany" AppendDataBoundItems="true">
                                        </asp:DropDownList>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" ErrorMessage="Company is required." Text="*"
                                            ControlToValidate="ddlCompany" runat="server" ValidationGroup="LoginUserValidationGroup" ToolTip="Company is required." InitialValue="0" />

                                    </div>
                                </div>
                                <div>
                                  <a>
                                    <asp:LinkButton ID="forgetPassword" runat="server" OnClick="forgetPassword_Click" CssClass="forgot-password-link">
                                     
                                        <i class=""></i>
                                        <span>Forgot Password ?</span>
                                        
                                    </asp:LinkButton>
                                </a>

                                </div>
                            </fieldset>
                          
                            <p class="submitButton">
                                <asp:Button ID="LoginButton" Style="border-radius: 5px;" runat="server" CommandName="Login" Text="LOGIN" ValidationGroup="LoginUserValidationGroup" OnClick="LoginButton_Click" />
                            </p>
                        </div>

                    </LayoutTemplate>
                    <LoginButtonStyle BackColor="White" BorderColor="#507CD1" BorderStyle="Solid" BorderWidth="1px" Font-Names="Verdana" Font-Size="0.8em" ForeColor="#284E98" />
                    <TextBoxStyle Font-Size="0.8em" />
                    <TitleTextStyle BackColor="#507CD1" Font-Bold="True" Font-Size="0.9em" ForeColor="White" />
                </asp:Login>
            </div>
            <asp:Panel ID="VerifyPanel" runat="server">
                <p style="color: #438eb9  !important; font-size: 12px;">Enter One Time PassCode Sent To You</p>
               <div id="otpContainer" class="d-flex justify-content-between">
                    <asp:TextBox ID="otp1" runat="server" ClientIDMode="Static" MaxLength="1" 
                            oninput="moveToNext(this, 'otp2')" onkeydown="handleBackspace(this, null)" autocomplete="off"
                            Style="width: 40px !important; text-align: center; font-size: 20px; background-color: #EAEAEA" />

                        <asp:TextBox ID="otp2" runat="server" ClientIDMode="Static" MaxLength="1" 
                            oninput="moveToNext(this, 'otp3')" onkeydown="handleBackspace(this, 'otp1')" autocomplete="off"
                            Style="width: 40px !important; text-align: center; font-size: 20px; background-color: #EAEAEA" />

                        <asp:TextBox ID="otp3" runat="server" ClientIDMode="Static" MaxLength="1" 
                            oninput="moveToNext(this, 'otp4')" onkeydown="handleBackspace(this, 'otp2')" autocomplete="off"
                            Style="width: 40px !important; text-align: center; font-size: 20px; background-color: #EAEAEA" />

                        <asp:TextBox ID="otp4" runat="server" ClientIDMode="Static" MaxLength="1" 
                            oninput="moveToNext(this, '')" onkeydown="handleBackspace(this, 'otp3')" autocomplete="off"
                            Style="width: 40px !important; text-align: center; font-size: 20px; background-color: #EAEAEA" />
                  </div>

                <span id="otpError" runat="server" style="color: red; font-size: 12px;"></span>   
               
             
                <asp:Button ID="btncancel" Style="border-radius: 5px; border: none; width: 60px; background-color: #484B4D; height: 25px; color: white;" runat="server" Text="Cancel" OnClick="btnCancel_Click" />
                <asp:Button ID="btnverify" Style="border-radius: 5px; border: none; width: 60px; background-color: #438eb9 ; height: 25px; color: white;" runat="server" Text="Next" OnClick="btnverify_Click" />
            </asp:Panel>
            <asp:Panel ID="forgot_pass_Panel" runat="server">           
               <div id="forgot_pass_viv">
                   <p style="font-size:20px;color:red">Forgot Password</p>
                
                            <label  for="lblphone" >Phone Number:</label>
                             <asp:TextBox style="margin-left:15px;width:65% !important" ID="txtPhone" runat="server"  />
                        </div>
                <span id="Span1" runat="server" style="color: red; font-size: 12px;"></span>
             
                <asp:Button ID="Button1" Style="margin-left:110px;width:125px" Cssclass="btn-gray" runat="server" Text="Cancel" OnClick="btnCancel_Click" />
                <asp:Button ID="Button2" Style="width:125px" Cssclass="btn-primry" runat="server" Text="Request OTP" OnClick="btnrequestOTP" />
            </asp:Panel>
             <asp:Panel ID="Panel_changePasword" runat="server">
             <p style="color: black  !important; font-size: 12px;">Enter One Time PassCode Sent To You</p>
        <div id="changepassowrd" class="d-flex justify-content-between">
            <asp:TextBox ID="pass1" runat="server" ClientIDMode="Static" MaxLength="1" 
                oninput="moveToNext(this, 'pass2')" onkeydown="handleBackspace(this, null)" autocomplete="off"
                Style="width: 40px !important; text-align: center; font-size: 20px; background-color: #EAEAEA" />

            <asp:TextBox ID="pass2" runat="server" ClientIDMode="Static" MaxLength="1" 
                oninput="moveToNext(this, 'pass3')" onkeydown="handleBackspace(this, 'pass1')" autocomplete="off"
                Style="width: 40px !important; text-align: center; font-size: 20px; background-color: #EAEAEA" />

            <asp:TextBox ID="pass3" runat="server" ClientIDMode="Static" MaxLength="1" 
                oninput="moveToNext(this, 'pass4')" onkeydown="handleBackspace(this, 'pass2')" autocomplete="off"
                Style="width: 40px !important; text-align: center; font-size: 20px; background-color: #EAEAEA" />

            <asp:TextBox ID="pass4" runat="server" ClientIDMode="Static" MaxLength="1" 
                oninput="moveToNext(this, '')" onkeydown="handleBackspace(this, 'pass3')" autocomplete="off"
                Style="width: 40px !important; text-align: center; font-size: 20px; background-color: #EAEAEA" />
        </div>

                  <span id="otpChangePassError" runat="server" style="color: red; font-size: 12px;"></span>
                
              
                 <asp:Button ID="Button3" Cssclass="btn-gray" runat="server" Text="Cancel" OnClick="btnCancel_Click" />
                 <asp:Button ID="Button4" cssclass="btn-primry" runat="server" Text="Next" OnClick="btnverify_Click_changePass" />
             </asp:Panel>
            <asp:Panel ID="messagePanel" runat="server" Width="200px" CssClass="popupContainer">
                <div class="popupHeaderWraper">
                    <h3>Message</h3>
                </div>
                <div class="contentsWraper">
                    <asp:Label ID="lblChangePasswordAlter" runat="server" Text="Your Password age is more than one month. It is recommended to change your password for security reason...!" />
                </div>
                <div class="popupButtonWraper">
                    <asp:Button ID="btnmessageOk" runat="server" Text="Ok" CssClass="popupButton" OnClick="btnmessageOk_Click" />
                    <asp:HiddenField ID="hdnmessageCancel" runat="server" />
                </div>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>

<script type="text/javascript">
    // Move to next field when input length reaches max
    function moveToNext(current, nextFieldID) {
        if (current.value.length === 1 && nextFieldID) {
            var nextField = document.getElementById(nextFieldID);
            if (nextField) {
                nextField.focus();
            }
        }
    }

    // Handle backspace to move to previous field
    function handleBackspace(current, prevFieldID) {
        if (event.key === "Backspace" && current.value === "" && prevFieldID) {
            var prevField = document.getElementById(prevFieldID);
            if (prevField) {
                prevField.focus();
                prevField.value = ""; // Clear previous field
            }
        }
    }

    // Password toggle functionality
    document.addEventListener('DOMContentLoaded', function () {
        var togglePassword = document.getElementById('togglePasswordIcon');
        if (togglePassword) {
            togglePassword.addEventListener('click', function () {
                var passwordField = document.getElementById('<%= ((Login)UserLogin).FindControl("Password").ClientID %>');
                if (passwordField) {
                    var type = passwordField.getAttribute('type') === 'password' ? 'text' : 'password';
                    passwordField.setAttribute('type', type);
                    this.classList.toggle('fa-eye');
                    this.classList.toggle('fa-eye-slash');
                }
            });
        }
    });
</script>

</asp:Content>