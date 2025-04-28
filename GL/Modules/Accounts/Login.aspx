<%@ Page Title="Log In" Language="C#" MasterPageFile="~/SiteNoMenu.master" AutoEventWireup="true"
    CodeBehind="Login.aspx.cs" Inherits="PMS.Account.Login" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<asp:Content ID="HeaderContent" runat="server" ContentPlaceHolderID="HeadContent">
    <style type="text/css">
        .login {
            font-family: "Open Sans";
        }

        .header h1 {
            padding-left: 10px;
            color: #fff;
        }

        .main table {
            border: none !important;
            background-color: transparent !important;
        }

        fieldset p {
            margin: 0;
        }

        select, input.textEntry,
        input.passwordEntry {
            width: 100% !important;
            height: 40px;
        }

        input.textEntry,
        input.passwordEntry {
            font-weight: 400 !important;
        }

        p.submitButton {
            padding-top: 15px;
        }

        .main .submitButton input {
            border-radius: 3px;
            font-size: 12px;
            line-height: 1.5;
            padding: 5px 10px;
            background-color: #438eb9 ;
            border-color: #357ebd;
            color: white;
            text-align: center;
            vertical-align: middle;
            white-space: nowrap;
            margin-bottom: 0;
            font-weight: normal;
            box-shadow: none;
            text-shadow: none;
            border: 0;
            width: 75px;
            height: 29px;
            cursor: pointer;
            display: inline-block;
            background-image: none;
            margin-right: 14%;
        }

            .main .submitButton input:focus {
                background-color: #484B4D;
            }

        .toolbar {
            padding-left: 20px;
            left: -36px;
            margin: 0 !important;
            position: relative;
            top: 16px;
            width: 340px;
        }

        .popupContainer {
            color: #fff;
        }

        /*input.textEntry,
        input.passwordEntry {
            position: relative;
            left: 50px;
            top: -1px;
        }*/

        input:hover {
            border: 2px solid #FFC000 !important;
        }

        select:hover {
            border: 2px solid #FFC000 !important;
        }

        select {
            margin-left: 0 !important;
            position: relative;
            top: 7px;
        }

        .input-field label {
            color: black !important;
        }

        #ctl00_MainContent_ErrorUserName, #ErrorUserName {
            margin-top: 11px !important;
        }

        ctl00_MainContent_ErrorPassword, #ErrorPassword {
            margin-top: 10px !important;
        }
           #ctl00_MainContent_UserLogin_LoginButton {}
         #ctl00_MainContent_UserLogin_LoginButton {
         text-align: center;
            text-transform: uppercase;
            transition: 0.5s;
            background-size: 200% auto;
            color: white;            
            box-shadow: 0 0 20px #eee;
            border-radius: 14px !important;
            display: block;
            width: 100% !important;
            height:40px;
             /*margin-left: 99px;*/
          }

          #ctl00_MainContent_UserLogin_LoginButton:hover {
           background-position: right center; /* change the direction of the change here */
            color: #fff;
            text-decoration: none;
          }
          .h2 {
              color:#438eb9 ;
              margin-left:-80%;
          }
          .labels {
              color:#438eb9  !important;

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
                                <h2 style="text-align: left;color:#438eb9 ">Log In</h2>
                                <span style="    margin-left: -6px;font-size: 14px;">Enter Your username and Password to sign in!</span>
                                <hr />
                                <div class="row">
                                    <div class="col-lg-2 col-md-4 col-sm-6">
                                        <asp:Label ID="UserNameLabel" CssClass="labels" runat="server" AssociatedControlID="UserName">Username:</asp:Label>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-lg-12 col-md-12 col-sm-12">
                                        <asp:TextBox ID="UserName" runat="server" autocomplete="off" CssClass="textEntry" Style="border: 1px solid gray;margin-top:10px;width:100% !important;border-radius:12px !important;height:40px"></asp:TextBox>
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
                                        <asp:TextBox ID="Password" autocomplete="off" Style="border: 1px solid gray;margin-top: 10px;width:100% !important;border-radius:12px !important;height:40px" runat="server" CssClass="passwordEntry" TextMode="Password"></asp:TextBox><br />
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
                                        <asp:DropDownList runat="server" Style="border: 1px solid gray;width:100% !important;border-radius:12px !important;height:40px" ID="ddlCompany" AppendDataBoundItems="true">
                                        </asp:DropDownList>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" ErrorMessage="Company is required." Text="*"
                                            ControlToValidate="ddlCompany" runat="server" ValidationGroup="LoginUserValidationGroup" ToolTip="Company is required." InitialValue="0" />

                                    </div>
                                </div>
                                <div>
                                  <a>
                                    <asp:LinkButton ID="forgetPassword" runat="server" OnClick="forgetPassword_Click" Style="color: black !important; font-size: 12px;margin-right:-60% !important" CssClass="forgot-password-link">
                                        <br />
                                        <i class="ace-icon fa fa-arrow-left"></i>
                                        Forgot Password ?
                                        
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
               
                <br />
                <asp:Button ID="btncancel" Style="border-radius: 5px; border: none; width: 60px; background-color: #484B4D; height: 25px; color: white;" runat="server" Text="Cancel" OnClick="btnCancel_Click" />
                <asp:Button ID="btnverify" Style="border-radius: 5px; border: none; width: 60px; background-color: #438eb9 ; height: 25px; color: white;" runat="server" Text="Next" OnClick="btnverify_Click" />
            </asp:Panel>
            <asp:Panel ID="forgot_pass_Panel" runat="server">           
               <div id="forgot_pass_viv">
                   <p style="font-size:20px;color:red">Forgot Password</p>
                   <br />
                            <label style="margin-left:-88px" for="lblphone" >Phone Number:</label>
                             <asp:TextBox style="margin-left:15px;width:65% !important" ID="txtPhone" runat="server"  />
                        </div>
                <span id="Span1" runat="server" style="color: red; font-size: 12px;"></span>
                <br />
                <asp:Button ID="Button1" Style="border-radius: 5px; border: none; width: 60px; background-color: #a9a9a9; height: 25px; color: white;margin-left:25%" runat="server" Text="Cancel" OnClick="btnCancel_Click" />
                <asp:Button ID="Button2" Style="border-radius: 5px; border: none; width: 88px; background-color: #438eb9 ; height: 25px; color: white;" runat="server" Text="Request OTP" OnClick="btnrequestOTP" />
            </asp:Panel>
             <asp:Panel ID="Panel_changePasword" runat="server">
             <p style="color: #438eb9  !important; font-size: 12px;">Enter One Time PassCode Sent To You</p>
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
                
                 <br />
                 <asp:Button ID="Button3" Style="border-radius: 5px; border: none; width: 60px; background-color: #484B4D; height: 25px; color: white;" runat="server" Text="Cancel" OnClick="btnCancel_Click" />
                 <asp:Button ID="Button4" Style="border-radius: 5px; border: none; width: 60px; background-color: #438eb9 ; height: 25px; color: white;" runat="server" Text="Next" OnClick="btnverify_Click_changePass" />
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
</script>


</asp:Content>

