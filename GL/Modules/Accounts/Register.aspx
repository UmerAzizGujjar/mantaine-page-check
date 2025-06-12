<%@ Page Title="Register" Language="C#" MasterPageFile="~/SiteNoMenu.master" AutoEventWireup="true"
    CodeBehind="Register.aspx.cs" Inherits="PMS.Account.Register" %>
        
<asp:Content ID="HeaderContent" runat="server" ContentPlaceHolderID="HeadContent">
    <link href="../../wwwroot/StandardTheme/css/CustomCss/registeruser.css" rel="stylesheet" />
</asp:Content>
<asp:Content ID="BodyContent" runat="server" ContentPlaceHolderID="MainContent">

    <div class="card">
      
        <div class="card-body">
            <asp:CreateUserWizard ID="RegisterUser" runat="server" EnableViewState="true" OnCreatedUser="RegisterUser_CreatedUser" RequireEmail="true" InvalidPasswordErrorMessage="Password length minimum: {0}. Numeric characters <br /> required: 1">
    <WizardSteps>
        <asp:CreateUserWizardStep ID="RegisterUserWizardStep" runat="server">
            <ContentTemplate>
                <span class="failureNotification">
                    <asp:Literal ID="ErrorMessage" runat="server"></asp:Literal>
                </span>
                <asp:ValidationSummary ID="RegisterUserValidationSummary" runat="server" CssClass="failureNotification"
                    ValidationGroup="RegisterUserValidationGroup" />
                <div class="accountInfo">
                    <fieldset class="register">
                        <table style="width: 350px !important; margin-top: -22px;">
                            <div class="label-field">
                                <asp:Label ID="Label1" runat="server"  Font-Size="16px" AssociatedControlID="UserName">User Name:</asp:Label>
                            </div>
                            <div class="input-field">
                                <asp:TextBox ID="UserName" runat="server" CssClass="textEntry" Style="border-radius: 10px !important;"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="UserNameRequired" runat="server" ControlToValidate="UserName"
                                    CssClass="failureNotification" ErrorMessage="User Name is required." ToolTip="User Name is required."
                                    ValidationGroup="RegisterUserValidationGroup">*</asp:RequiredFieldValidator>
                            </div>
                            <div class="label-field">
                                <asp:Label ID="EmailLabel" runat="server"  Font-Size="16px" AssociatedControlID="Email">E-mail:</asp:Label>
                            </div>
                            <div class="input-field">
                                <asp:TextBox ID="Email" runat="server" CssClass="textEntry" Style="border-radius: 10px !important;"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="EmailRequired" runat="server" ControlToValidate="Email"
                                    CssClass="failureNotification" ErrorMessage="E-mail is required." ToolTip="E-mail is required."
                                    ValidationGroup="RegisterUserValidationGroup">*</asp:RequiredFieldValidator>
                            </div>
                            <div class="label-field">
                                <asp:Label ID="Label2"  runat="server"  Font-Size="16px" AssociatedControlID="Password">Password:</asp:Label>
                             </div>
                            <div class="input-field">
                                <asp:TextBox ID="Password" runat="server" CssClass="passwordEntry" TextMode="Password" Style="border-radius: 10px !important;"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="PasswordRequired" runat="server" ControlToValidate="Password"
                                    CssClass="failureNotification" ErrorMessage="Password is required." ToolTip="Password is required."
                                    ValidationGroup="RegisterUserValidationGroup">*</asp:RequiredFieldValidator>
                            </div>
                            <div class="label-field">
                                 <asp:Label ID="ConfirmPasswordLabel"  Font-Size="16px" runat="server" AssociatedControlID="ConfirmPassword">Confirm Password:</asp:Label>
                             </div>
                            <div class="input-field">
                                <asp:TextBox ID="ConfirmPassword" runat="server" CssClass="passwordEntry" TextMode="Password" Style="border-radius: 10px !important;"></asp:TextBox>
                                <asp:RequiredFieldValidator ControlToValidate="ConfirmPassword" CssClass="failureNotification" Display="Dynamic"
                                    ErrorMessage="Confirm Password is required." ID="ConfirmPasswordRequired" runat="server"
                                    ToolTip="Confirm Password is required." ValidationGroup="RegisterUserValidationGroup">*</asp:RequiredFieldValidator>
                                <asp:CompareValidator ID="PasswordCompare" runat="server" ControlToCompare="Password" ControlToValidate="ConfirmPassword"
                                    CssClass="failureNotification" Display="Dynamic" ErrorMessage="The Password and Confirmation Password must match."
                                    ValidationGroup="RegisterUserValidationGroup">*</asp:CompareValidator>
                            </div>
                            <div>
                                <asp:CheckBox ID="AllowPatientEdit" runat="server" />
                                <asp:Label ID="lblAllowPatientEdit" AssociatedControlID="AllowPatientEdit" CssClass="inline" runat="server">Edit Patient</asp:Label>&nbsp;&nbsp;
                                <asp:CheckBox ID="AllowPatientDelete" runat="server" />
                                <asp:Label ID="lblAllowPatientDelete" AssociatedControlID="AllowPatientDelete"  runat="server" CssClass="inline">Cancel Patient</asp:Label>&nbsp;&nbsp;
                                <asp:CheckBox ID="AllPatientRecords" runat="server" />
                                <asp:Label ID="lblAllPatientRecord" AssociatedControlID="AllPatientRecords" runat="server" CssClass="inline" >All Patients</asp:Label>&nbsp;&nbsp;
                                <asp:CheckBox ID="OTPUsers" runat="server" />
                                <asp:Label ID="lblOTPUsers" AssociatedControlID="OTPUsers" runat="server" CssClass="inline" >OTP Users</asp:Label>
                            </div>
                            <br>
                            <br>
                            <tr>
                                <td>
                                    <asp:Button ID="CreateUserButton" CssClass="mybutton" Style="border-radius: 50px; width: 150px;" runat="server" CommandName="MoveNext" Text="Create User" ValidationGroup="RegisterUserValidationGroup" />
                                </td>
                                <td>
                                    <asp:Button Text="Back" CssClass="mybutton" runat="server" ID="btnBack" Style="border-radius: 50px; width: 150px;" CausesValidation="false" PostBackUrl="UserView.aspx" />
                                </td>
                            </tr>
                        </table>
                    </fieldset>


                </div>
            </ContentTemplate>
            <CustomNavigationTemplate>
            </CustomNavigationTemplate>
        </asp:CreateUserWizardStep>
        <asp:CompleteWizardStep runat="server"></asp:CompleteWizardStep>
    </WizardSteps>
</asp:CreateUserWizard>
        </div>
    </div>
</asp:Content>

