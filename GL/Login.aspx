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

    <link href="wwwroot/THEME_TIBBIT/CustomCSS/LoginModern.css?v=20261014" rel="stylesheet" />
   
</asp:Content>
<asp:Content ID="BodyContent" runat="server" ContentPlaceHolderID="MainContent">
    <asp:ToolkitScriptManager ID="ToolkitScriptManager1" runat="server"></asp:ToolkitScriptManager>

    <asp:UpdatePanel runat="server" ID="upForm" UpdateMode="Conditional">
        <ContentTemplate>
            <div class="brand-panel">
                <div class="brand-top">
                    <div class="brand-logo-plate">
                        <asp:Image ID="imgBrandLogo" runat="server" CssClass="brand-logo" AlternateText="Company logo" />
                    </div>
                    <div class="brand-company">
                        <asp:Label ID="lblBrandCompany" runat="server" />
                        <small>Hospital Management System</small>
                    </div>
                </div>
                <div class="brand-hero">
                    <h1 class="brand-title">Smarter care.<br /><span>Simpler</span> hospital management.</h1>
                    <p class="brand-text">Patients, labs, pharmacy, billing and finance &mdash; connected in one secure platform for your whole hospital.</p>
                </div>
                <ul class="brand-points">
                    <li><i class="fas fa-stethoscope"></i>Clinical records</li>
                    <li><i class="fas fa-vial"></i>Lab &amp; pharmacy</li>
                    <li><i class="fas fa-chart-line"></i>Billing &amp; dashboards</li>
                </ul>
                <img class="brand-art" src="wwwroot/THEME_TIBBIT/images/LOGOS/LoginIllustration.jpg" alt="" />
                <div class="brand-credit">
                    Application developed by <a href="http://www.visionplus.com.pk" target="_blank">VisionPlus Technologies (Pvt) LTD.</a>
                </div>
            </div>
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
                                <p class="login-eyebrow">Secure sign in</p>
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
