<%@ Page Title="Change Password" Language="C#" MasterPageFile="~/SiteNoMenu.Master" AutoEventWireup="true"
    CodeBehind="ChangePassword.aspx.cs" Inherits="PMS.Account.ChangePassword" %>

<asp:Content ID="HeaderContent" runat="server" ContentPlaceHolderID="HeadContent">
    <link href="../../wwwroot/StandardTheme/css/CustomCss/registeruser.css" rel="stylesheet" />

    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

      
</asp:Content>
<asp:Content ID="BodyContent" runat="server" ContentPlaceHolderID="MainContent">
     
    <asp:ChangePassword ID="ChangeUserPassword" runat="server" CancelDestinationPageUrl="~/" EnableViewState="false" RenderOuterTable="false"
        SuccessPageUrl="ChangePasswordSuccess.aspx" ChangePasswordFailureText="Password incorrect or New Password invalid. New Password length minimum: {0}. Numeric characters required: 1.">
        <ChangePasswordTemplate>
            <span class="failureNotification">
                <asp:Literal ID="FailureText" runat="server"></asp:Literal>
            </span>
            <asp:ValidationSummary ID="ChangeUserPasswordValidationSummary" runat="server" CssClass="failureNotification"
                ValidationGroup="ChangeUserPasswordValidationGroup" />
            <div class="accountInfo">
                <fieldset class="changePassword">
                    <div class="label-field" >
                         <asp:Label ID="CurrentPasswordLabel" runat="server" Font-Size="16px" Style="border-radius: 10px !important;" AssociatedControlID="CurrentPassword">Old Password:</asp:Label>
                    </div>
                    <div class="input-field">
                         <asp:TextBox ID="CurrentPassword" Style="border-radius: 10px !important;" runat="server" CssClass="passwordEntry" TextMode="Password"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="CurrentPassword" CssClass="failureNotification" ErrorMessage="Old Password is required." ToolTip="Old Password is required."  ValidationGroup="ChangeUserPasswordValidationGroup">*</asp:RequiredFieldValidator>
                        
                    </div>
                    <div class="label-field">
                        <asp:Label ID="NewPasswordLabel" runat="server" AssociatedControlID="NewPassword"  Font-Size="16px">New Password:</asp:Label>
                    </div>
                    <div class="input-field">
                        <asp:TextBox ID="NewPassword" Style="border-radius: 10px !important;" runat="server" CssClass="passwordEntry" TextMode="Password"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="NewPasswordRequired" runat="server" ControlToValidate="NewPassword"
                            CssClass="failureNotification" ErrorMessage="New Password is required." ToolTip="New Password is required."
                            ValidationGroup="ChangeUserPasswordValidationGroup">*</asp:RequiredFieldValidator>
                    </div>

                    <div class="label-field">
                        <asp:Label ID="ConfirmNewPasswordLabel" runat="server" AssociatedControlID="ConfirmNewPassword"  Font-Size="16px">Confirm New Password:</asp:Label>
                    </div>
                    <div class="input-field">
                        <asp:TextBox ID="ConfirmNewPassword" Style="border-radius: 10px !important;" runat="server" CssClass="passwordEntry" TextMode="Password"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="ConfirmNewPasswordRequired" runat="server" ControlToValidate="ConfirmNewPassword"
                            CssClass="failureNotification" Display="Dynamic" ErrorMessage="Confirm New Password is required."
                            ToolTip="Confirm New Password is required." ValidationGroup="ChangeUserPasswordValidationGroup">*</asp:RequiredFieldValidator>
                        <asp:CompareValidator ID="NewPasswordCompare" runat="server" ControlToCompare="NewPassword" ControlToValidate="ConfirmNewPassword"
                            CssClass="failureNotification" Display="Dynamic" ErrorMessage="The Confirm New Password must match the New Password entry."
                            ValidationGroup="ChangeUserPasswordValidationGroup">*</asp:CompareValidator>
                    </div>
                </fieldset>
                <br />
                <p class="submitButton">
                    <td>
                     <asp:Button ID="ChangePasswordPushButton" OnClick="ChangePasswordPushButton_Click" runat="server" CommandName="ChangePassword" Text="Change Password" ValidationGroup="ChangeUserPasswordValidationGroup" />
                    </td>
                   <td>
                       <asp:Button ID="CancelPushButton" style="width:120px;" runat="server" CausesValidation="False" CommandName="Cancel" Text="Cancel" />  
                   </td>
                    
                </p>
            </div>
        </ChangePasswordTemplate>
    </asp:ChangePassword>
    <%--<script type="text/javascript">

        window.onload = function () {
            var messageType = '<%= Session["MessageType"] != null ? Session["MessageType"].ToString() : "" %>';
            var loginMessage = '<%= Session["LoginSuccess"] != null ? Session["LoginSuccess"].ToString() : "" %>';

            if (messageType && loginMessage) {
                Swal.fire({
                    title: messageType === 'success' ? 'Success!' : 'Error!',
                    text: loginMessage,
                    icon: messageType === 'success' ? 'success' : 'error',
                    confirmButtonText: 'Okay'
                }).then((result) => {
                    if (messageType === 'success' && result.isConfirmed) {
                        window.location.href = 'Login.aspx';
                    }
                });
            }
        };

    </script>--%>
</asp:Content>
